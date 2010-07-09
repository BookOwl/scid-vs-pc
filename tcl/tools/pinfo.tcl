###
### pinfo.tcl # Player Info window
###

set playerInfoName ""

proc playerInfo {{player ""}} {
  global playerInfoName
  if {$player == ""} { set player $playerInfoName }
  if {[catch {sc_name info -htext $player} pinfo]} { return }
  set playerInfoName $player
  set ::rgraph(player) $player
  set w .playerInfoWin
  if {! [winfo exists $w]} {
    toplevel $w
    wm title $w "Scid: [tr ToolsPInfo]"
    wm state $w withdrawn
    setWinLocation $w

    # this is a little broke S.A... might be due to autoscroll ?
    wm minsize $w 400 550

    pack [frame $w.b2] -side bottom -fill x
    pack [frame $w.b] -side bottom
    button $w.b.graph -text [tr ToolsRating] \
      -command {::tools::graphs::rating::Refresh player $playerInfoName} -width 10
    button $w.b.edit -text $::tr(PInfoEditRatings) -command {
      makeNameEditor
      setNameEditorType rating
      set editName $playerInfoName
      set editNameSelect crosstable
    } -width 10
    button $w.b.report -text [tr ToolsPlayerReport] \
      -command {::preport::preportDlg $playerInfoName} -width 10
    button $w.b.update -textvar ::tr(Update) -command {playerInfo $playerInfoName} -width 10
    dialogbutton $w.b2.help -textvar ::tr(Help) -command {helpWindow PInfo} -width 10
    dialogbutton $w.b2.close -textvar ::tr(Close) -command "focus .; destroy $w" -width 10

    pack $w.b.report -padx 5 -pady 5 -side left
    pack $w.b.graph  -padx 5 -pady 5 -side left
    pack $w.b.edit   -padx 5 -pady 5 -side left
    pack $w.b.update -padx 5 -pady 5 -side right
    pack $w.b2.close -padx 10 -pady 10 -side right -anchor e
    pack $w.b2.help  -padx 10 -pady 10 -side right -anchor e

    autoscrollframe $w.frame text $w.text -font font_Regular -wrap none

    #scrollbar $w.ybar -command "$w.text yview"
    #pack $w.ybar -side right -fill y
    #text $w.text -font font_Regular \
    #  -width $::winWidth($w) -height $::winHeight($w) \
    #  -setgrid 1 -wrap none -yscrollcommand "$w.ybar set"
    #pack $w.text -side top -fill both -expand yes

    label $w.photo 
    pack $w.frame -side top -fill both -expand yes
    ::htext::init $w.text
    ::htext::updateRate $w.text 0
    bind $w <Escape> "focus .; destroy $w"
    bind $w <F1> {helpWindow PInfo}
    standardShortcuts $w

    setWinSize $w
    update
    wm state $w normal
    bind $w <Configure> "recordWinSize $w"

  } else {
    raiseWin $w
  }
  set player [trimEngineName $player]
  if {[info exists ::photo($player)]} {
    image create photo photoPInfo -data $::photo($player)
    $w.photo configure -image photoPInfo -anchor ne
    place $w.photo -in $w.text -relx 1.0 -x -1 -rely 0.0 -y 1 -anchor ne
  } else {
    place forget $w.photo
  }

  ### update text window contents

  $w.text configure -state normal
  $w.text delete 1.0 end
  ::htext::display $w.text $pinfo
  $w.text configure -state disabled

  ::windows::gamelist::Refresh
  ::maint::Refresh

  #raiseWin $w
}

###
### end of pinfo.tcl
###
