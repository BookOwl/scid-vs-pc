############################################################
# Start of pgn.tcl
#

namespace eval pgn {
  ################################################################################
  #
  ################################################################################
  proc ChooseColor {type name} {
    global pgnColor
    set x [tk_chooseColor -initialcolor $pgnColor($type) \
        -title "PGN $name color"  -parent .pgnWin]
    if {$x != ""} { set pgnColor($type) $x; ::pgn::ResetColors }
  }
  ################################################################################
  #
  ################################################################################
  proc ConfigMenus {{lang ""}} {
    if {! [winfo exists .pgnWin]} { return }
    if {$lang == ""} { set lang $::language }
    set m .pgnWin.menu
    foreach idx {0 1 2 3} tag {PgnFile PgnOpt PgnColor PgnHelp} {
      configMenuText $m $idx $tag $lang
    }
    foreach idx {0 1 3} tag {PgnFilePrint PgnFileCopy PgnFileClose} {
      configMenuText $m.file $idx $tag $lang
    }
    foreach idx {1 2 3 4 5 6 7 8 9} tag {
      PgnOptShort PgnOptColumn PgnOptColor PgnOptIndentC PgnOptIndentV PgnOptBoldMainLine PgnOptSpace PgnOptSymbols PgnOptStripMarks
    } {
      configMenuText $m.opt $idx $tag $lang
    }
    foreach idx {1 2 3 4 5} tag {PgnColorHeader PgnColorAnno PgnColorComments PgnColorVars PgnColorBackground} {
      configMenuText $m.color $idx $tag $lang
    }
    foreach idx {0 1} tag {PgnHelpPgn PgnHelpIndex} {
      configMenuText $m.help $idx $tag $lang
    }
  }
  ################################################################################
  #
  ################################################################################
  proc OpenClose {} {
    global pgnWin pgnHeight pgnWidth pgnColor
    set w .pgnWin

    if {[winfo exists $w]} {
      focus .
      destroy $w
      set pgnWin 0
      return
    }
    toplevel $w
    setWinLocation $w
    setWinSize $w

    menu $w.menu
    $w configure -menu $w.menu

    foreach i {file opt color help} label {PgnFile PgnOpt PgnColor PgnHelp} tear {0 1 1 0} {
      $w.menu add cascade -label $label -menu $w.menu.$i -underline 0
      menu $w.menu.$i -tearoff $tear
    }
    # alter ConfigMenus if changing tearoffs S.A

    $w.menu.file add command -label PgnFilePrint -command "::pgn::savePgn $w"

    $w.menu.file add command -label PgnFileCopy -command ::pgn::copyPgn

    $w.menu.file add separator

    $w.menu.file add command -label PgnFileClose -accelerator Esc \
        -command "focus .; destroy $w"

    $w.menu.opt add checkbutton -label PgnOptShort \
        -variable ::pgn::shortHeader -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptColumn \
        -variable ::pgn::columnFormat -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptColor \
        -variable ::pgn::showColor -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptIndentC \
        -variable ::pgn::indentComments -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptIndentV \
        -variable ::pgn::indentVars -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptBoldMainLine \
        -variable ::pgn::boldMainLine -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptSpace \
        -variable ::pgn::moveNumberSpaces -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptSymbols \
        -variable ::pgn::symbolicNags -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptStripMarks \
        -variable ::pgn::stripMarks -command {updateBoard -pgn}

    $w.menu.opt add separator

    $w.menu.opt add command -label [tr OptionsFonts] -command "FontDialogRegular $w"

    $w.menu.color add command -label PgnColorHeader \
        -command {::pgn::ChooseColor Header "header text"}
    $w.menu.color add command -label PgnColorAnno \
        -command {::pgn::ChooseColor Nag annotation}
    $w.menu.color add command -label PgnColorComments \
        -command {::pgn::ChooseColor Comment comment}
    $w.menu.color add command -label PgnColorVars \
        -command {::pgn::ChooseColor Var variation}
    $w.menu.color add command -label PgnColorBackground \
        -command {::pgn::ChooseColor Background background}

    $w.menu.help add command -label PgnHelpPgn \
        -accelerator F1 -command {helpWindow PGN}
    $w.menu.help add command -label PgnHelpIndex -command {helpWindow Index}

    ::pgn::ConfigMenus

    text $w.text -width $::winWidth($w) -height $::winHeight($w) -wrap word \
        -cursor {} -setgrid 1 -tabs {1c right 2c 4c}
    if {$pgnColor(Background) != {white} && $pgnColor(Background) != {#ffffff}} {
	$w.text configure -background $pgnColor(Background)
    }
    if { $::pgn::boldMainLine } {
      $w.text configure -font font_Bold
    }

    pack [frame $w.buttons] -side bottom -fill x
    pack $w.text -fill both -expand yes
    button $w.buttons.help -textvar ::tr(Help) -command { helpWindow PGN }
    button $w.buttons.close -textvar ::tr(Close) -command { focus .; destroy .pgnWin }
    #pack $w.buttons.close $w.buttons.help -side right -padx 5 -pady 2
    set pgnWin 1
    bind $w <Destroy> { set pgnWin 0 }

    # Left button closes context menu
    bind $w <ButtonPress-1> {
      if {[winfo exists .pgnWin.text.ctxtMenu]} { destroy .pgnWin.text.ctxtMenu; focus .pgnWin }
    }

    # Middle button popups a PGN board
    bind $w <ButtonPress-2> "::pgn::ShowBoard .pgnWin.text 5 %x %y %X %Y"
    bind $w <ButtonRelease-2> ::pgn::HideBoard

    # Right button draws context menu
    bind $w <ButtonPress-3> "::pgn::contextMenu .pgnWin.text 5 %x %y %X %Y"

    bind $w <F1> { helpWindow PGN }
    bind $w <Escape> {
      if {[winfo exists .pgnWin.text.ctxtMenu]} {
        destroy .pgnWin.text.ctxtMenu
        focus .pgnWin
      } else {
        focus .
        destroy .pgnWin
      }
    }
    standardShortcuts $w
    bindMouseWheel $w $w.text
    bind $w <Control-s> "::pgn::savePgn $w"

    # Add variation navigation bindings:
    bind $w <KeyPress-v> [bind . <KeyPress-v>]
    bind $w <KeyPress-z> [bind . <KeyPress-z>]
    if {$::windowsOS} {
      bind $w <Control-MouseWheel> {
	if {[expr -%D] < 0} {FontBigger ; break}
	if {[expr -%D] > 0} {FontSmaller ; break}
      }
    } else {
      bind $w <Control-Button-4> {FontBigger ; break}
      bind $w <Control-Button-5> {FontSmaller ; break}
    }
    bind $w <Configure> "recordWinSize $w"

    $w.text tag add Current 0.0 0.0

    # Populate text widget &&&
    ::pgn::ResetColors
  }

  ################################################################################
  #
  ################################################################################
  proc savePgn {parent} {
    global env

    set ftype {
      { "PGN files"  {".pgn"} }
      { "Text files" {".txt"} }
      { "All files"  {"*"}    }
    }
    # -initialdir $env(HOME)

    ### Only suggest a filename if this is not a multiple pgn file
    if {[info exists ::initialDir(file)] && [sc_filter count] <= 1} {
      set tail $::initialDir(file)
    } else {
      set tail {}
    }
    set fname [tk_getSaveFile -parent $parent \
                 -initialdir $::initialDir(base) -initialfile $tail \
                 -filetypes $ftype -defaultextension .pgn -title {Save PGN}]
    if {$fname != ""} {
      if {[file extension $fname] != ".txt" && [file extension $fname] != ".pgn" } {
	append fname ".pgn"
      }
      if {[catch {set tempfile [open $fname w]}]} {
	tk_messageBox -title "Scid: Error saving file" -parent $parent -type ok \
                      -icon warning -message "Unable to save file $fname\n\n"
      } else {
        ### This currently only saves a single game,
        ### ... possibily/easily overwriting a multiple game pgn file S.A
	puts $tempfile \
	    [sc_game pgn -width 75 -symbols $::pgn::symbolicNags \
	    -indentVar $::pgn::indentVars -indentCom $::pgn::indentComments \
	    -space $::pgn::moveNumberSpaces -format plain -column $::pgn::columnFormat \
	    -markCodes $::pgn::stripMarks]
	close $tempfile
        ::recentFiles::add $fname
        set ::initialDir(file) [file tail $fname]
        set ::initialDir(base) [file dirname $fname]
        updateMenuStates
      }
      set initialDir(base) [file dirname $fname]
    }
  }

  proc copyPgn {} {
    setLanguageTemp E
    set pgnStr [sc_game pgn -width 75 -indentComments $::pgn::indentComments \
	-indentVariations $::pgn::indentVars -space $::pgn::moveNumberSpaces]
    setLanguageTemp $::language
    
    setClipboard $pgnStr
  }

  # These two bindings are done in a bad way in htext.tcl.
  # Each text object has separate bindings, but they should 
  # be handled in a general bind to the pgn text widget ala
  # contextMenu

  proc move {moveTag} {
    set ::pause 1
    sc_move pgn [string range $moveTag 2 end]
    updateBoard
  }

  proc comment {commentTag} {
    sc_move pgn [string range $commentTag 2 end]
    updateBoard
    ::commenteditor::Open
  }

  proc contextMenu {win startLine x y xc yc} {

    update idletasks

    set mctxt $win.ctxtMenu
    if { [winfo exists $mctxt] } { destroy $mctxt }
    if {[sc_var level] == 0} {
      set state disabled
    } else  {
      set state normal
    }
    set varnum [sc_var number]
    menu $mctxt
    $mctxt add command -label [tr EditDelete] -state $state -command "::pgn::deleteVar $varnum"
    $mctxt add command -label [tr EditFirst] -state $state -command "::pgn::firstVar $varnum"
    $mctxt add command -label [tr EditMain] -state $state -command "::pgn::mainVar $varnum"
    $mctxt add separator
    $mctxt add command -label "[tr EditStrip] [tr EditStripComments]" -command {::game::Strip comments .pgnWin}
    $mctxt add command -label "[tr EditStrip] [tr EditStripVars]" -command {::game::Strip variations .pgnWin}
    $mctxt add command -label "[tr EditStrip] [tr EditStripBegin]" -command ::game::TruncateBegin
    $mctxt add command -label "[tr EditStrip] [tr EditStripEnd]" -command ::game::Truncate
    $mctxt add separator
    $mctxt add command -label "[tr WindowsComment]" -command ::commenteditor::Open

    $mctxt post [winfo pointerx .] [winfo pointery .]
  }

  proc deleteVar { var } {
    sc_var exit
    sc_var delete $var
    updateBoard -pgn
  }

  proc firstVar { var } {
    sc_var exit
    sc_var first $var
    updateBoard -pgn
  }

  proc mainVar { var } {
    sc_var exit
    sc_var promote $var
    updateBoard -pgn
  }
  ################################################################################
  # removes the comments in text widget (or parsing in sc_pos pgnBoard will fail
  # and return a wrong position
  ################################################################################
  proc removeCommentTag { win startline lastpos } {
    set ret ""
    if {[scan $lastpos "%d.%d" lastline lastcol] != 2} {
      return $ret
    }
    for {set line $startline} {$line < $lastline} {incr line} {
      if { [ scan [$win index $line.end ] "%d.%d" dummy colend ] != 2 } {
        return $ret
      }
      for {set col 0} {$col <= $colend} {incr col} {
        set t [$win tag names $line.$col]
        if {[lsearch -glob $t "c_*"] == -1} {
          append ret [$win get $line.$col]
        }
      }
    }

    for {set col 0} {$col <= $lastcol} {incr col} {
      set t [$win tag names $lastline.$col]
      if {[lsearch -glob $t "c_*"] == -1} {
        append ret [$win get $lastline.$col]
      }
    }

    return $ret
  }
  ################################################################################
  # ::pgn::ShowBoard:
  #    Produces a popup window showing the board position in the
  #    game at the current mouse location in the PGN window.
  #
  ################################################################################
  proc ShowBoard {win startLine x y xc yc} {
    global lite dark

    # unpost context menu
    set mctxt $win.ctxtMenu
    if { [winfo exists $mctxt] } { destroy $mctxt }

    set txt [removeCommentTag $win $startLine [ $win index @$x,$y]]
    # set bd [sc_pos pgnBoard [::untrans [$win get $startLine.0 @$x,$y]] ]
    set bd [ sc_pos pgnBoard [::untrans $txt ] ]
    set w .pgnPopup
    set psize 30
    if {$psize > $::boardSize} { set psize $::boardSize }

    if {! [winfo exists $w]} {
      toplevel $w -relief solid -borderwidth 2
      wm withdraw $w
      wm overrideredirect $w 1
      ::board::new $w.bd $psize
      pack $w.bd -side top -padx 2 -pady 2
      wm withdraw $w
    }

    ::board::update $w.bd $bd

    # Make sure the popup window can fit on the screen:
    incr xc 5
    incr yc 5
    update idletasks
    set dx [winfo width $w]
    set dy [winfo height $w]
    if {($xc+$dx) > [winfo screenwidth $w]} {
      set xc [expr {[winfo screenwidth $w] - $dx}]
    }
    if {($yc+$dy) > [winfo screenheight $w]} {
      set yc [expr {[winfo screenheight $w] - $dy}]
    }
    wm geometry $w "+$xc+$yc"
    wm deiconify $w
    raiseWin $w
  }

  ################################################################################
  # ::pgn::HideBoard
  #
  #    Hides the window produced by ::pgn::ShowBoard.
  #
  ################################################################################
  proc HideBoard {} {
    wm withdraw .pgnPopup
  }

  ################################################################################
  # # ::pgn::ResetColors
  #
  #    Reconfigures the pgn Colors, after a color is changed by the user
  #
  ################################################################################
  proc ResetColors {} {
    global pgnColor
    if {![winfo exists .pgnWin]} { return }
    .pgnWin.text tag configure Current -background $pgnColor(Current)
    ::htext::init .pgnWin.text
    ::htext::updateRate .pgnWin.text 60
    ::pgn::Refresh 1
    if {$pgnColor(Background) != {white} && $pgnColor(Background) != {#ffffff}} {
	.pgnWin.text configure -background $pgnColor(Background)
	.pgnWin.text tag configure Current -background $pgnColor(Current)
    }
  }
  ################################################################################
  # ::pgn::Refresh
  #
  #    Updates the PGN window. If $pgnNeedsUpdate == 0, then the
  #    window text is not regenerated; only the current and next move
  #    tags will be updated.
  ################################################################################
  proc Refresh {{pgnNeedsUpdate 0}} {

    if {![winfo exists .pgnWin]} { return }

    set format plain
    if {$::pgn::showColor} {set format color}

    set pgnStr [sc_game pgn -symbols $::pgn::symbolicNags \
        -indentVar $::pgn::indentVars -indentCom $::pgn::indentComments \
        -space $::pgn::moveNumberSpaces -format $format -column $::pgn::columnFormat \
        -short $::pgn::shortHeader -markCodes $::pgn::stripMarks]
    # debug puts $pgnStr

    if {$pgnNeedsUpdate} {
      set windowTitle [format $::tr(PgnWindowTitle) [sc_game number]]
      wm title .pgnWin "Scid: $windowTitle"
      .pgnWin.text configure -state normal
      .pgnWin.text delete 0.0 end
      if {$::pgn::showColor} {
        if {$::pgn::indentComments} {
	  ::htext::display .pgnWin.text $pgnStr {} 2
        } else {
	  ::htext::display .pgnWin.text $pgnStr
        }
      } else {
        .pgnWin.text insert 1.0 $pgnStr
      }
    }

    if {$::pgn::showColor} {
      if { $::pgn::boldMainLine } {
        .pgnWin.text configure -font font_Bold
      } else {
        .pgnWin.text configure -font font_Regular
      }
      ### set Current tag and adjust text window view if necessary

      .pgnWin.text tag remove Current 1.0 end

      set offset [sc_pos pgnOffset]
      set moveRange [.pgnWin.text tag nextrange m_$offset 1.0]
      if {[llength $moveRange] == 2} {
       .pgnWin.text tag add Current [lindex $moveRange 0] [lindex $moveRange 1]

       ### There's a bottleneck here when large pgn files are shown on one line
       ### Slowdown is internal to Tk. (from the text manpage)
       # <q> Very  long  text  lines  can be expensive, especially if they have
       # many marks and tags within them. </q>

       .pgnWin.text see [lindex $moveRange 0]
       .pgnWin.text see [lindex $moveRange 1]
      }
      .pgnWin.text configure -state disabled
    } else {
      # Highlight current move in text only widget

      # This is not going to work because generally [sc_pos pgnOffset] returns
      # 2 * (move number), but when we have variations this is not the case!
      # Needs some magic somehow.

      set move [sc_pos pgnOffset].
      # seek to after first blank line
      set offset [expr [string first \n\n $pgnStr] + 2]
      #.pgnWin.text tag add Current UMMMM....
    }
    return
  }
}

### End of pgn.tcl
