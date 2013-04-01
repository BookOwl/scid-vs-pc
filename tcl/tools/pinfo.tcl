###
### pinfo.tcl # Player Info window
###

set playerInfoName ""

proc playerInfo {{player ""} {raise 0}} {
  global playerInfoName
  if {$player == ""} { set player $playerInfoName }
  if {[catch {sc_name info -htext $player} pinfo]} { return }
  set playerInfoName $player
  set ::rgraph(player) $player
  set w .playerInfoWin
  if {! [winfo exists $w]} {
    ::createToplevel $w
    ::setTitle $w "[tr ToolsPInfo]"
    catch {wm state $w withdrawn}
    setWinLocation $w
    wm minsize $w 450 300

    pack [frame $w.b2] -side bottom -expand 1 -fill x
    pack [frame $w.b] -side bottom -expand 1 -fill x -pady 5 

    button $w.b.graph -text [tr ToolsRating] \
      -command {::tools::graphs::rating::Refresh $playerInfoName} 
    button $w.b.edit -text $::tr(PInfoEditRatings) -command {
      makeNameEditor
      setNameEditorType rating
      set editName $playerInfoName
      set editNameSelect crosstable
    }
    button $w.b.match -text {Lookup Name} -command {
      set ::plist::name [lindex $playerInfoName 0]
      if {[winfo exists .plist]} {
	::plist::refresh
        raiseWin .plist
      } else {
	::plist::Open
      }
    }
    button $w.b.nedit -text {Edit Name} -command {
      makeNameEditor
      setNameEditorType player
      set editName $playerInfoName
      set editNameNew $playerInfoName
      set editNameSelect all
    }

    dialogbutton $w.b2.report -text [tr ToolsPlayerReport] -command {::preport::preportDlg $playerInfoName}
    label $w.b2.space -width 2
    dialogbutton $w.b2.update -textvar ::tr(Update) -command {playerInfo $playerInfoName} -width 10
    dialogbutton $w.b2.help -textvar ::tr(Help) -command {helpWindow PInfo} -width 10
    dialogbutton $w.b2.close -textvar ::tr(Close) -command "destroy $w" -width 10

    pack $w.b.graph $w.b.edit $w.b.match $w.b.nedit -padx 5 -pady 5 -side left

    pack $w.b2.report $w.b2.space $w.b2.update $w.b2.help $w.b2.close -padx 5 -pady 10 -side left

    autoscrollframe $w.frame text $w.text -font font_Regular -wrap none

    pack $w.frame -side top -fill both -expand yes
    ::htext::init $w.text
    bind $w <Escape> "focus .main ; destroy $w"
    bind $w <F1> {helpWindow PInfo}
    standardShortcuts $w

    setWinSize $w
    update
    catch {wm state $w normal}
    bind $w <Configure> "recordWinSize $w"
    ::createToplevelFinalize $w
  } else {
    # Generating a player report refreshs stats, which refreshes this proc
    # So only raise if asked to
    if {$raise != {0}} {
      raiseWin $w
    }
  }

  ### Make FIDEID open relevant url
  regsub {FIDEID ([0-9]+)} $pinfo {<run openURL http://ratings.fide.com/card.phtml?event=%\1 ; ::windows::stats::Refresh>FIDEID \1</run>} pinfo

  ### update main window
  $w.text configure -state normal
  $w.text delete 1.0 end
  ::htext::display $w.text $pinfo

  set player [trimEngineName $player]
  if {[info exists ::photo($player)]} {
    image create photo photoPInfo -data $::photo($player)
    if {0} {
      label $w.photo 
      $w.photo configure -image photoPInfo -anchor ne
      place $w.photo -in $w.text -relx 1.0 -x -1 -rely 0.0 -y 1 -anchor ne
    } else {
      # image now scrolls with the widget
      $w.text insert 2.0 "\n"
      $w.text image create 2.0 -image photoPInfo -align top -padx 3 -pady 5
    }
  } else {
    # place forget $w.photo
  }

  $w.text configure -state disabled

  ::windows::gamelist::Refresh
  ::maint::Refresh

  #raiseWin $w
}

# Refresh after hyperlinks in the playerinfo widget are clicked
# eg: <run sc_name info -oaA {}; ::playerInfoRefresh>GAMES</run>

proc playerInfoRefresh {} {
  set ::glstart 1
  ::windows::stats::Refresh
}

###
### end of pinfo.tcl
###
