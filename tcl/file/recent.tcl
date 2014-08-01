
####################
# Recent files list:

set recentFiles(limit) 10   ;# Maximum number of recent files to remember.
set recentFiles(menu)   5   ;# Maximum number of files to show in File menu.
set recentFiles(extra)  5   ;# Maximum number of files to show in extra menu.
set recentFiles(gamehistory) 5 ;# Maximum number of files to show in Game History
set recentFiles(data)  {}   ;# List of recently used files.

catch {source [scidConfigFile recentfiles]}

namespace eval ::recentFiles {}

# ::recentFiles::save
#   Saves the recent-file-list file, reporting any error in a message box
#   if reportError is true.

proc ::recentFiles::save {{reportError 0}} {
  global recentFiles
  set f {}
  set filename [scidConfigFile recentfiles]
  if  {[catch {open $filename w} f]} {
    if {$reportError} {
      tk_messageBox -title "Scid" -type ok -icon warning \
          -message "Unable to write file: $filename\n$f"
    }
    return
  }
  puts $f "# $::scidName recent files list\n"
  foreach i {limit menu extra gamehistory data} {
    puts $f "set recentFiles($i) [list [set recentFiles($i)]]"
    puts $f ""
  }
  close $f
}

proc ::recentFiles::remove {fname} {
  ::recentFiles::add $fname 1
}

# ::recentFiles::add
#   Adds a file to the recent files list, or moves it to the front
#   if that file is already in the list.

proc ::recentFiles::add {fname {delete 0}} {
  global recentFiles
  set rlist $recentFiles(data)

  # Remove file to be added from its current place in the list (if any)
  while {1} {
    set idx [lsearch -exact $rlist $fname]
    if {$idx < 0} { break }
    set rlist [lreplace $rlist $idx $idx]
  }

  if {!$delete} {
    # Insert the current file at the start of the list:
    set rlist [linsert $rlist 0 $fname]

    # Trim the list if necessary:
    if {[llength $rlist] < $recentFiles(limit)} {
      set rlist [lrange $rlist 0 [expr {$recentFiles(limit) - 1} ]]
    }
  }

  set recentFiles(data) $rlist
  # ::recentFiles::save

  ### Start the finder and ::file::Open from here
  set ::file::finder::data(dir) [file dirname $fname]
}

# ::recentFiles::load
#   Loads the selected recent file, or swtches to its database slot
#   if it is already open.
#
proc ::recentFiles::load {fname} {
  set rname $fname
  if {[file extension $rname] == ".si4"} {
    set rname [file rootname $rname]
  }
  for {set i 1} {$i <= [sc_base count total]} {incr i} {
    if {$rname == [sc_base filename $i]} {
      ::file::SwitchToBase $i
      ::recentFiles::add $fname
      return
    }
  }
  ::file::Open $fname
}

#################################################################################
proc ::recentFiles::treeshow {menu} {
  global recentFiles
  set rlist $recentFiles(data)
  $menu delete 0 end
  set nfiles [llength $rlist]
  if {$nfiles > $recentFiles(limit)} { set nfiles $recentFiles(limit) }

  for {set i 0} {$i<$nfiles} {incr i} {
    set name [lindex $rlist $i]
    $menu add command -label "$name" -command [list ::file::openBaseAsTree $name]
  }
}

#################################################################################
# ::recentFiles::show
#   Adds the recent files to the end of the specified menu.
#   Returns the number of menu entries added.
#
proc ::recentFiles::show {menu} {
  global recentFiles
  set idx [$menu index end]
  incr idx
  set rlist $recentFiles(data)
  set nfiles [llength $rlist]
  set nExtraFiles [expr {$nfiles - $recentFiles(menu)} ]
  if {$nfiles > $recentFiles(menu)} { set nfiles $recentFiles(menu) }
  if {$nExtraFiles > $recentFiles(extra)} {
    set nExtraFiles $recentFiles(extra)
  }
  if {$nExtraFiles < 0} { set nExtraFiles 0 }

  # Add menu commands for the most recent files:

  for {set i 0} {$i < $nfiles} {incr i} {
    set fname [lindex $rlist $i]
    set mname [::recentFiles::menuname $fname]
    set text [file tail $fname]
    set num [expr {$i + 1} ]
    set underline -1
    if {$num <= 9} { set underline 0 }
    if {$num == 10} { set underline 1 }
    $menu add command -label "$num: [file tail $mname]" -underline $underline \
        -command [list ::recentFiles::load $fname]
    set ::helpMessage($menu,$idx) "  [file nativename $fname]"
    incr idx
  }

  # If no extra submenu of recent files is needed, return now:
  if {$nExtraFiles <= 0} { return $nfiles }

  # Now add the extra submenu of files:
  catch {destroy $menu.recentFiles}
  menu $menu.recentFiles
  $menu add cascade -label ". . ." -menu $menu.recentFiles
  set i $nfiles
  for {set extra 0} {$extra < $nExtraFiles} {incr extra} {
    set fname [lindex $rlist $i]
    incr i
    set mname [::recentFiles::menuname $fname]
    set text [file tail $fname]
    set num [expr {$extra + 1} ]
    set underline -1
    if {$num <= 9} { set underline 0 }
    if {$num == 10} { set underline 1 }
    $menu.recentFiles add command -label "$num: [file tail $mname]" -underline $underline \
        -command [list ::recentFiles::load $fname]
    set ::helpMessage($menu.recentFiles,$extra) "  $fname"
  }
  return [expr {$nfiles + 1} ]
}

# ::recentFiles::menuname
#   Given a full-path filename, returns a possibly shortened
#   version suitable for displaying in a menu, such as
#   "..../my/files/abc.pgn" instead of "/long/path/to/my/files/abc.pgn"
#
proc ::recentFiles::menuname {fname} {
  set mname $fname
  set mname [file nativename $mname]
  if {[file extension $mname] == [sc_info suffix index]} {
    set mname [file rootname $mname]
  }
  if {[string length $mname] < 25} { return $mname }

  # Generate a menu name " ..../path/filename" for the file:
  set dir [file dirname $fname]
  while {1} {
    set tail [file join [file tail $dir] $mname]
    set dir [file dirname $dir]
    if {[string length $tail] > 20} { break }
    set mname $tail
  }
  set mname [file join .... $mname]
  set mname [file nativename $mname]
  return $mname
}

#   Produces a dialog box for configuring the number of recent files
#   to display in the File menu and in a submenu.

proc ::recentFiles::configure {} {
  global recentFiles
  set w .recentFilesDlg
  if {[winfo exists $w]} {
    raiseWin $w
    return
  }

  toplevel $w
  wm withdraw $w
  wm title $w "Scid: [tr OptionsRecent]"

  set recentFiles(temp_menu) $recentFiles(menu)
  set recentFiles(temp_extra) $recentFiles(extra)
  set recentFiles(temp_gamehistory) $recentFiles(gamehistory)

  label $w.lmenu -text $::tr(RecentFilesMenu)
  scale $w.menu -variable recentFiles(temp_menu) -from 0 -to 20 -length 250 \
      -orient horizontal -showvalue 0 -tickinterval 2 -font font_Small

  frame $w.sep -height 4

  label $w.lextra -text $::tr(RecentFilesExtra)
  scale $w.extra -variable recentFiles(temp_extra) -from 0 -to 20 -length 250 \
      -orient horizontal -showvalue 0 -tickinterval 2 -font font_Small

  frame $w.sep2 -height 4

  label $w.lgames -text {Number of games in Game History}
  scale $w.games -variable recentFiles(temp_gamehistory) -from 0 -to 20 -length 250 \
      -orient horizontal -showvalue 0 -tickinterval 2 -font font_Small

  pack $w.lmenu $w.menu $w.sep $w.lextra $w.extra $w.sep2 $w.lgames $w.games -side top -padx 10
  addHorizontalRule $w
  pack [frame $w.b] -side bottom

  dialogbutton $w.b.ok -text "OK" -command {
    set recentFiles(menu) $recentFiles(temp_menu)
    set recentFiles(extra) $recentFiles(temp_extra)
    set recentFiles(gamehistory) $recentFiles(temp_gamehistory)
    destroy .recentFilesDlg
    ::recentFiles::save
    updateMenuStates
    ::bookmarks::RefreshMenuGame .menu.game
  }

  dialogbutton $w.b.cancel -text $::tr(Cancel) -command "destroy $w"

  pack $w.b.cancel $w.b.ok -side right -padx 5 -pady 5

  placeWinOverParent $w .
  wm state $w normal
}

