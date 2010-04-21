########################################
### utils/font.tcl: part of Scid.
#
# The following procs implement a font selection dialog. I found the code
# at codearchive.com (I dont think there was an author listed for it) and
# simplified it for use with Scid.

proc FontDialogFixed {parent} {
  global fontOptions

  set fontOptions(temp) [FontDialog Fixed $parent]
  if {$fontOptions(temp) != {}} { set fontOptions(Fixed) $fontOptions(temp) }
}

proc FontDialogRegular {parent} {
  global fontOptions

  set fontOptions(temp) [FontDialog Regular $parent]
  if {$fontOptions(temp) != {}} { set fontOptions(Regular) $fontOptions(temp) }

  set font [font configure font_Regular -family]
  set fontsize [font configure font_Regular -size]
  font configure font_Bold -family $font -size $fontsize
  font configure font_Italic -family $font -size $fontsize
  font configure font_BoldItalic -family $font -size $fontsize
  font configure font_H1 -family $font -size [expr {$fontsize + 8} ]
  font configure font_H2 -family $font -size [expr {$fontsize + 6} ]
  font configure font_H3 -family $font -size [expr {$fontsize + 4} ]
  font configure font_H4 -family $font -size [expr {$fontsize + 2} ]
  font configure font_H5 -family $font -size [expr {$fontsize + 0} ]
}

proc FontDialogMenu {parent} {
  global fontOptions

  set fontOptions(temp) [FontDialog Menu $parent]
  if {$fontOptions(temp) != ""} { set fontOptions(Menu) $fontOptions(temp) }
}

proc FontDialogSmall {parent} {
  global fontOptions

  set fontOptions(temp) [FontDialog Small $parent]
  if {$fontOptions(temp) != ""} { set fontOptions(Small) $fontOptions(temp) }

  set font [font configure font_Small -family]
  set fontsize [font configure font_Small -size]
  font configure font_SmallBold -family $font -size $fontsize
  font configure font_SmallItalic -family $font -size $fontsize
}

# FontDialog:
#   Creates a font dialog to select a font.
#   Returns 1 if user chose a font, 0 otherwise.
#   Returns ... something S.A

proc FontDialog {name {parent .}} {
  global fd_family fd_style fd_size fd_close
  global fd_strikeout fd_underline fontOptions

  set options $fontOptions($name)
  set fixedOnly [expr {$name == "Fixed"}]
  set title $name
  set font_name font_$name

  set fd_family {}; set fd_style {}; set fd_size {}
  set fd_close  -1

  set unsorted_fam [font families]
  set families [lsort $unsorted_fam]
  if {$fixedOnly} {
    set fams $families
    set families {}
    foreach f $fams {
      if {[font metrics [list $f] -fixed] == 1} { lappend families $f }
    }
  }

  # Get current font's family and so on.
  if {[llength $options] == 4} {
    # Use provided font settings:
    set family [lindex $options 0]
    set size [lindex $options 1]
    set weight [lindex $options 2]
    set slant [lindex $options 3]
  } else {
    # Get options using [font actual]:
    set family [font actual $font_name -family]
    set size   [font actual $font_name -size]
    set weight    [font actual $font_name -weight]
    set slant     [font actual $font_name -slant]
  }

  # Default style.
  set fd_style "Regular"
  if { $slant == "italic" } {
    if { $weight == "bold" } {
      set fd_style "Bold Italic"
    } else {
      set fd_style "Italic"
    }
  } else {
    if { $weight == "bold" } {
      set fd_style "Bold"
    }
  }

  set fd_family $family
  set fd_size   $size

  # Create font dialog.
  set w .fontdialog
  toplevel $w
  wm state $w withdrawn
  wm protocol $w WM_DELETE_WINDOW "set fd_close 0"
  wm title $w "Scid: $title font"

  label $w.family_lbl -text "Font:" -anchor w
  entry $w.family_ent -textvariable fd_family -background white
  bind  $w.family_ent <Key-Return> "FontDialogRegen $font_name"
  grid config $w.family_lbl -column 0 -row 0 -sticky w
  grid config $w.family_ent -column 0 -row 1 -sticky snew

  label $w.style_lbl  -text "Font Style:" -anchor w
  entry $w.style_ent  -textvariable fd_style -width 11 -background white
  bind  $w.style_ent  <Key-Return>  "FontDialogRegen $font_name"
  grid config $w.style_lbl  -column 1 -row 0 -sticky w
  grid config $w.style_ent  -column 1 -row 1 -sticky snew

  label $w.size_lbl   -text "Size:" -anchor w
  entry $w.size_ent   -textvariable fd_size -width 4 -background white
  bind  $w.size_ent   <Key-Return> "FontDialogRegen $font_name"
  grid config $w.size_lbl   -column 2 -row 0 -sticky w
  grid config $w.size_ent   -column 2 -row 1 -sticky snew

  # Font family listbox.
  set fr $w.family_list
  frame $fr -bd 0
  listbox $fr.list -height 6 -selectmode single -width 30 \
    -background white -yscrollcommand "$fr.scroll set"
  scrollbar $fr.scroll -command "$fr.list yview"

  foreach f $families {
    $fr.list insert end $f
  }

  bind $fr.list <Double-Button-1> \
    "FontDialogFamily $fr.list $font_name $w.family_ent"

  pack $fr.scroll -side right -fill y
  pack $fr.list -side left
  grid config $fr -column 0 -row 2 -rowspan 16

  # Font style listbox.
  set fr $w.style_list
  frame $fr -bd 0
  listbox $fr.list -height 6 -selectmode single -width 11 \
    -background white -yscrollcommand "$fr.scroll set"
  scrollbar $fr.scroll -command "$fr.list yview"

  $fr.list insert end "Regular"
  $fr.list insert end "Bold"
  $fr.list insert end "Italic"
  $fr.list insert end "Bold Italic"

  bind $fr.list <Double-Button-1> \
    "FontDialogStyle $fr.list $font_name $w.style_ent"

  pack $fr.scroll -side right -fill y
  pack $fr.list -side left
  grid config $fr -column 1 -row 2 -rowspan 16

  # Font size listbox.
  set fr $w.size_list
  frame $fr -bd 0
  listbox $fr.list -height 6 -selectmode single -width 4 \
    -background white -yscrollcommand "$fr.scroll set"
  scrollbar $fr.scroll -command "$fr.list yview"

  for {set i 7} {$i <= 20} {incr i} {
    $fr.list insert end $i
  }

  bind $fr.list <Double-Button-1> "FontDialogSize $fr.list $font_name $w.size_ent"

  pack $fr.scroll -side right -fill y
  pack $fr.list -side left
  grid config $fr -column 2 -row 2 -rowspan 16

  # Buttons
  set fr $w.buttons
  frame $fr -bd 0

  # God f-ing knows what's happening here
  # Tcl sucks so bad when design is bad
  # Fonts are powerful... but a mess S.A.

  button $fr.ok -text OK -command "
    FontDialogRegen $font_name
    set fd_close 1
  "
  button $fr.cancel  -text Cancel -command {
    set fd_close 0
  }
  button $fr.default -text Default -command "
    reinitFont $name
    FontDialogFamily $fr.list $font_name $w.family_ent
    FontDialogStyle $fr.list $font_name $w.style_ent
    FontDialogSize $fr.list $font_name $w.size_ent
    set fd_close 2
  "
  pack $fr.ok -side top -fill x
  pack $fr.default -side top -fill x -pady 10
  pack $fr.cancel -side top -fill x -pady 2
  grid config $fr -column 4 -row 1 -rowspan 2 -sticky snew -padx 12

  # Sample text
  set fr $w.sample
  frame $fr -bd 3 -relief groove
  label $fr.l_sample -text "Sample" -anchor w

  label $fr.sample -font $font_name -bd 2 -relief sunken -text \
    "This is some sample text\nAaBbCcDdEeFfGgHhIiJjKkLlMm\n 0123456789. +=-"

  pack  $fr.l_sample -side top -fill x -pady 4
  pack  $fr.sample -side top -pady 4 -ipadx 10 -ipady 10

  grid config $fr -column 0 -columnspan 3 -row 20 \
    -rowspan 2 -sticky snew -pady 10 -padx 2

  bind $w <Escape> "$w.buttons.cancel invoke"
  update
  placeWinOverParent $w $parent
  wm state $w normal

  ### Tried to change this thing... but gave up ! S.A

  # Make this a modal dialog. 

  tkwait variable fd_close

  destroy $w

  # Cancel button
  # Restore old font characteristics
  if { $fd_close == 0 } {
    font configure $font_name -family $family \
      -size $size -slant $slant -weight $weight
    return {}
  }

  # Ok button
  if { $fd_close == 1 } {
    return [list $fd_family $fd_size [FontWeight $fd_style] [FontSlant $fd_style]]
  } else {
  # Default button
    return {}
  }
}


proc FontDialogFamily { listname font_name entrywidget } {
  # Get selected text from list.
  catch {
    set item_num [$listname curselection]
    set item [$listname get $item_num]

    # Set selected list item into entry for font family.
    $entrywidget delete 0 end
    $entrywidget insert end $item

    # Use this family in the font and regenerate font.
    FontDialogRegen $font_name
  }
}


proc FontDialogStyle { listname font_name entrywidget } {
  # Get selected text from list.
  catch {
    set item_num [$listname curselection]
    set item [$listname get $item_num]

    # Set selected list item into entry for font family.
    $entrywidget delete 0 end
    $entrywidget insert end $item

    # Use this family in the font and regenerate font.
    FontDialogRegen $font_name
  }
}


proc FontDialogSize { listname font_name entrywidget } {
  # Get selected text from list.
  catch {
    set item_num [$listname curselection]
    set item [$listname get $item_num]

    # Set selected list item into entry for font family.
    $entrywidget delete 0 end
    $entrywidget insert end $item

    # Use this family in the font and regenerate font.
    FontDialogRegen $font_name
  }
}

proc FontWeight {style} {
  if { $style == "Bold Italic" || $style == "Bold" } {
    return "bold"
  }
  return "normal"
}

proc FontSlant {style} {
  if { $style == "Bold Italic" || $style == "Italic" } {
    return "italic"
  }
  return "roman"
}

# FontDialogRegen: Regenerates font from attributes.
proc FontDialogRegen { font_name } {
  global fd_family fd_style fd_size

  set weight "normal"
  if { $fd_style == "Bold Italic" || $fd_style == "Bold" } {
    set weight "bold"
  }

  set slant "roman"
  if { $fd_style == "Bold Italic" || $fd_style == "Italic" } {
    set slant "italic"
  }

  # Change font to have new characteristics.
  font configure $font_name -family $fd_family \
    -size $fd_size -slant $slant -weight $weight
}

## End of file: fontsel.tcl
