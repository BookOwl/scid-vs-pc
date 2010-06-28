###################
# htext.tcl: Online help/hypertext display module for Scid
#
# The htext module implements html-like display in a text widget.
# It is used in Scid for the help and crosstable windows, and for
# the game information area.

namespace eval ::htext {}

set helpWin(Stack) {}
set helpWin(yStack) {}
set helpWin(index) -1
set helpWin(len) 0

set helpWin(Indent) 0

# help_PushStack and help_PopStack:
#   Implements a stack (list) of help windows for the Back and Forward buttons

proc help_PushStack {name {heading {}}} {
  global helpWin

  # truncate in case we've been moving forward
  set helpWin(Stack)  [lrange $helpWin(Stack)  0 $helpWin(index)]
  set helpWin(yStack) [lrange $helpWin(yStack) 0 $helpWin(index)]

  lappend helpWin(Stack) $name

    if {[winfo exists .helpWin]} {
      # Before adding a new 0.0, we can set posi of the previous window
      lset helpWin(yStack) end [lindex [.helpWin.text yview] 0]
    }

  # new windows won't have a posi yet
  lappend helpWin(yStack) 0.0

  set helpWin(len) [llength $helpWin(Stack)]
  set helpWin(index) [expr $helpWin(len) - 1]
}

# set ::htext::headingColor "\#990000"
set ::htext::headingColor darkslateblue
array set ::htext:updates {}

proc help_MoveForward {} {
  global helpWin helpText helpName
  incr helpWin(index)
  set name  [lindex $helpWin(Stack)  $helpWin(index)]
  set yview [lindex $helpWin(yStack) $helpWin(index)]
  updateHelpWindow $name
  .helpWin.text yview moveto $yview
}

proc help_PopStack {} {
  global helpWin helpText helpName

  if {$helpWin(index) < 1} { return }

    if {[winfo exists .helpWin]} {
      # Just set posi of this window first
      # bug: there's some window creep upwards as we keep reading/setting yview

      lset helpWin(yStack) $helpWin(index) [lindex [.helpWin.text yview] 0]
    }

  incr helpWin(index) -1
  set name  [lindex $helpWin(Stack)  $helpWin(index)]
  set yview [lindex $helpWin(yStack) $helpWin(index)]
  updateHelpWindow $name
  .helpWin.text yview moveto $yview
}


proc toggleHelp {} {
  if {[winfo exists .helpWin]} {
    destroy .helpWin
  } else {
    helpWindow Contents
  }
}

proc helpWindow {name {heading {}}} {
  help_PushStack $name
  updateHelpWindow $name $heading
  update
}

proc updateHelpWindow {name {heading {}}} {
  global helpWin helpText helpTitle windowsOS language helpName
  set w .helpWin

  set helpName $name ; # used by forward stack
  set slist [split $name " "]
  if {[llength $slist] > 1} {
    set name [lindex $slist 0]
    set heading [lindex $slist 1]
  }

  if {[info exists helpText($language,$name)] && [info exists helpTitle($language,$name)]} {
    set title $helpTitle($language,$name)
    set helptext $helpText($language,$name)
  } elseif {[info exists helpText($name)] && [info exists helpTitle($name)]} {
    set title $helpTitle($name)
    set helptext $helpText($name)
  } else {
    return
  }

  if {![winfo exists $w]} {
    toplevel $w
    # wm geometry $w -10+0
    # wm minsize $w 40 5
    setWinLocation $w
    setWinSize $w
    text $w.text -setgrid yes -wrap word -width $::winWidth($w) \
        -height $::winHeight($w) -relief sunken -border 2 \
        -yscroll "$w.scroll set"
    scrollbar $w.scroll -relief sunken -command "$w.text yview"

    frame $w.b -relief raised -border 2
    pack $w.b -side bottom -fill x
    button $w.b.contents -textvar ::tr(Contents) -width 6 -command { helpWindow Contents }
    button $w.b.index -textvar ::tr(Index) -width 6 -command { helpWindow Index }
    button $w.b.back -text "  << " -command { help_PopStack }
    button $w.b.forward -text "  >> " -command { help_MoveForward }
    button $w.b.font -text Font -width 6 -command "FontDialogRegular $w"
    button $w.b.close -textvar ::tr(Close) -width 6 -command {
      set ::helpWin(Stack) {}
      set ::helpWin(yStack) {}
      set ::helpWin(index) -1
      set ::helpWin(len) 0
      destroy .helpWin
    }

    pack $w.b.back $w.b.contents $w.b.index $w.b.forward -side left -padx 3 -pady 2
    pack $w.b.close -side right -padx 3 -pady 2
    pack $w.b.font -side right -padx 3 -pady 2
    pack $w.scroll -side right -fill y -padx 2 -pady 2
    pack $w.text -fill both -expand 1 -padx 5

    $w.text configure -font font_Regular
    ::htext::init $w.text
    bind $w <Configure> "recordWinSize $w"
    bind $w <F1> toggleHelp
  } else {
    raise $w .
  }

  $w.text configure -cursor top_left_arrow
  $w.text configure -state normal
  $w.text delete 0.0 end

  $w.b.index configure -state normal
  if {$name == "Index"} { $w.b.index configure -state disabled }
  $w.b.contents configure -state normal
  if {$name == "Contents"} { $w.b.contents configure -state disabled }

  if {$helpWin(index) < 1} {
    $w.b.back configure -state disabled
  } else {
    $w.b.back configure -state normal
  }

  if {$helpWin(len) == [expr $helpWin(index) + 1]} {
    $w.b.forward configure -state disabled
  } else {
    $w.b.forward configure -state normal
  }

  wm title $w "Scid Help: $title"
  wm iconname $w "Scid help"

  $w.text delete 0.0 end
  bind $w <Up> "$w.text yview scroll -1 units"
  bind $w <Down> "$w.text yview scroll 1 units"
  bind $w <Prior> "$w.text yview scroll -1 pages"
  bind $w <Next> "$w.text yview scroll 1 pages"
  bind $w <Key-Home> "$w.text yview moveto 0"
  bind $w <Key-End> "$w.text yview moveto 0.99"
  bind $w <Escape> "$w.b.close invoke"
  bind $w <Key-b> "$w.b.back invoke"
  bind $w <Alt-Left> "$w.b.back invoke"
  bind $w <Alt-Right> "$w.b.forward invoke"
  bind $w <Key-i> "$w.b.index invoke"

  ::htext::display $w.text $helptext $heading 0
  focus $w
}

proc ::htext::updateRate {w rate} {
  set ::htext::updates($w) $rate
}

proc ::htext::init {w} {
  set cyan "\#007000"
  set maroon "\#990000"
  set green "springgreen"

  set ::htext::updates($w) 100
  $w tag configure black -fore black
  $w tag configure white -fore white
  $w tag configure red -fore red
  $w tag configure blue -fore blue
  $w tag configure darkblue -fore darkBlue
  $w tag configure green -fore $green
  $w tag configure cyan -fore $cyan
  $w tag configure yellow -fore yellow
  $w tag configure maroon -fore $maroon
  $w tag configure gray -fore gray20

  # $w tag configure lastmove -fore red
  $w tag configure lastmove -fore royalblue2 -font font_Bold
  # hmmm... salmon4 rosybrown4 royalblue royalblue2 chartreuse4 springgreen4

  $w tag configure bgBlack -back black
  $w tag configure bgWhite -back white
  $w tag configure bgRed -back red
  $w tag configure bgBlue -back blue
  $w tag configure bgLightBlue -back lightBlue
  $w tag configure bgGreen -back $green
  $w tag configure bgCyan -back $cyan
  $w tag configure bgYellow -back yellow

  $w tag configure tab -lmargin2 50
  $w tag configure li -lmargin2 50
  $w tag configure center -justify center

  if {[$w cget -font] == "font_Small"} {
    $w tag configure b -font font_SmallBold
    $w tag configure i -font font_SmallItalic
  } else {
    $w tag configure b -font font_Bold
    $w tag configure i -font font_Italic
  }
  $w tag configure bi -font font_BoldItalic
  $w tag configure tt -font font_Fixed
  $w tag configure u -underline 1
  $w tag configure h1 -font {Arial 24 normal} -fore $::htext::headingColor -justify center
  $w tag configure h2 -font font_H2 -fore $::htext::headingColor
  $w tag configure h3 -font font_H3 -fore $::htext::headingColor
  $w tag configure h4 -font font_H4 -fore $::htext::headingColor
  $w tag configure h5 -font font_H5 -fore $::htext::headingColor
  $w tag configure footer -font font_Small -justify center

  # $w tag configure hc -font font_H5 -fore $::htext::headingColor -justify center
  # doesnt work properly S.A.

  $w tag configure term -font font_BoldItalic -fore $::htext::headingColor
  $w tag configure menu -font font_Bold -fore $cyan

  # PGN-window-specific tags:
  $w tag configure tag -fore $::pgnColor(Header)
  if { $::pgn::boldMainLine } {
    $w tag configure nag -fore $::pgnColor(Nag) -font font_Regular
    $w tag configure var -fore $::pgnColor(Var) -font font_Regular
  } else {
    $w tag configure nag -fore $::pgnColor(Nag)
    $w tag configure var -fore $::pgnColor(Var)
  }
  $w tag configure ip1 -lmargin1 25 -lmargin2 25
  $w tag configure ip2 -lmargin1 50 -lmargin2 50
}

proc ::htext::isStartTag {tagName} {
  return [expr {![strIsPrefix {/} $tagName]} ]
}

proc ::htext::isEndTag {tagName} {
  return [strIsPrefix {/} $tagName]
}

proc ::htext::isLinkTag {tagName} {
  return [strIsPrefix {a } $tagName]
}

proc ::htext::extractLinkName {tagName} {
  if {[::htext::isLinkTag $tagName]} {
    return [lindex [split [string range $tagName 2 end] { }] 0]
  }
  return {}
}

proc ::htext::extractSectionName {tagName} {
  if {[::htext::isLinkTag $tagName]} {
    return [lindex [split [string range $tagName 2 end] { }] 1]
  }
  return {}
}

set ::htext::interrupt 0

### Some tcl string optimisations by S.A. 5/12/2009

proc ::htext::display {w helptext {section {}} {fixed 1}} {
  global helpWin
  # set start [clock clicks -milli]
  set helpWin(Indent) 0
  set ::htext::interrupt 0
  $w mark set insert 0.0
  $w configure -state normal
  set linkName {}

  set count 0
  set str $helptext
  if {$fixed} {
    regsub -all \n\n $str <p> str
    regsub -all \n $str { } str
  } else {
    regsub -all "\[ \n\]+" $str { } str
    regsub -all ">\[ \n\]+" $str {> } str
    regsub -all "\[ \n\]+<" $str { <} str
  }
  set tagType {}
  set seePoint {}

  if {! [info exists ::htext::updates($w)]} {
    set ::htext::updates($w) 100
  }

  # Loop through the text finding the next formatting tag:

  while {1} {
    set startPos [string first < $str]
    if {$startPos < 0} { break }
    set endPos [string first > $str]
    if {$endPos < 1} { break }

    set tagName [string range $str [expr {$startPos + 1}] [expr {$endPos - 1}]]

    # starting tag (no "/" at the start)

    if {![strIsPrefix {/} $tagName]} {
      
      # link tag
      if {[strIsPrefix {a } $tagName]} {
        set linkName [::htext::extractLinkName $tagName]
        set sectionName [::htext::extractSectionName $tagName]
        set linkTag "link ${linkName} ${sectionName}"
        set tagName a
        $w tag configure $linkTag -fore dodgerblue2
        $w tag bind $linkTag <ButtonRelease-1> "helpWindow $linkName $sectionName"
        $w tag bind $linkTag <Any-Enter> \
            "$w tag configure \"$linkTag\" -back gray80
             $w configure -cursor hand2"
        $w tag bind $linkTag <Any-Leave> \
            "$w tag configure \"$linkTag\" -back {}
             $w configure -cursor {}"
      } elseif {[strIsPrefix {url } $tagName]} {
        # URL tag
        set urlName [string range $tagName 4 end]
        set urlTag "url $urlName"
        set tagName url
        $w tag configure $urlTag -fore red -underline 1
        $w tag bind $urlTag <ButtonRelease-1> "openURL {$urlName}"
        $w tag bind $urlTag <Any-Enter> \
            "$w tag configure \"$urlTag\" -back gray
             $w configure -cursor hand2"
        $w tag bind $urlTag <Any-Leave> \
            "$w tag configure \"$urlTag\" -back {}
             $w configure -cursor {}"
      } elseif {[strIsPrefix {run } $tagName]} {
        # Tcl command tag
        set runName [string range $tagName 4 end]
        set runTag "run $runName"
        set tagName run
        $w tag bind $runTag <ButtonRelease-1> "catch {$runName}"
        $w tag bind $runTag <Any-Enter> \
            "$w tag configure \"$runTag\"
             $w tag configure \"$runTag\" -back gray
             $w configure -cursor hand2"
        $w tag bind $runTag <Any-Leave> \
            "$w tag configure \"$runTag\" -fore {}
             $w tag configure \"$runTag\" -back {}
             $w configure -cursor {}"
      } elseif {[strIsPrefix {go } $tagName]} {
        # Goto tag
        set goName [string range $tagName 3 end]
        set goTag "go $goName"
        set tagName go
        $w tag bind $goTag <ButtonRelease-1> \
            "catch {$w see \[lindex \[$w tag nextrange $goName 1.0\] 0\]}"
        $w tag bind $goTag <Any-Enter> \
            "$w tag configure \"$goTag\" -fore gray
             $w tag configure \"$goTag\" -back maroon
             $w configure -cursor hand2"
        $w tag bind $goTag <Any-Leave> \
            "$w tag configure \"$goTag\" -fore {}
             $w tag configure \"$goTag\" -back {}
             $w configure -cursor {}"
      } elseif {[strIsPrefix {pi } $tagName]} {
        # Player info tag
        set playerTag $tagName
        set playerName [string range $playerTag 3 end]
        set tagName pi
        $w tag configure "$playerTag" -fore Blue
        $w tag bind $playerTag <ButtonRelease-1> "playerInfo \"$playerName\""
        $w tag bind $playerTag <Any-Enter> \
            "$w tag configure \"$playerTag\"
             $w tag configure \"$playerTag\" -back gray
             $w configure -cursor hand2"
        $w tag bind $playerTag <Any-Leave> \
            "$w tag configure \"$playerTag\" -fore Blue
             $w tag configure \"$playerTag\" -back {}
             $w configure -cursor {}"
      } elseif {[strIsPrefix g_ $tagName]} {
        # Game-load tag
        set gameTag $tagName
        set tagName g
        set gnum [string range $gameTag 2 end]
        set glCommand "::game::LoadMenu $w [sc_base current] $gnum %X %Y"
        $w tag bind $gameTag <ButtonPress-1> $glCommand
        $w tag bind $gameTag <ButtonPress-3> \
            "::gbrowser::new [sc_base current] $gnum"
        $w tag bind $gameTag <Any-Enter> \
            "$w tag configure $gameTag
             $w tag configure $gameTag -back gray
             $w configure -cursor hand2"
        $w tag bind $gameTag <Any-Leave> \
            "$w tag configure $gameTag -fore {}
             $w tag configure $gameTag -back {}
             $w configure -cursor {}"
      } elseif {[strIsPrefix m_ $tagName]} {
        # Move tag
        set moveTag $tagName
        set tagName m
        $w tag bind $moveTag <ButtonRelease-1> \
            "set ::pause 1
             sc_move pgn [string range $moveTag 2 end]
             updateBoard"
        # invoking contextual menu in PGN window
        $w tag bind $moveTag <ButtonPress-3> \
            "sc_move pgn [string range $moveTag 2 end]; updateBoard"
        $w tag bind $moveTag <Any-Enter> \
            "$w tag configure $moveTag -underline 1
             $w configure -cursor hand2"
        $w tag bind $moveTag <Any-Leave> \
            "$w tag configure $moveTag -underline 0
             $w configure -cursor {}"
      } elseif {[strIsPrefix c_ $tagName]} {
        # Comment tag
        set commentTag $tagName
        set tagName c
        if { $::pgn::boldMainLine } {
          $w tag configure $commentTag -fore $::pgnColor(Comment) \
              -font font_Regular
        } else {
          $w tag configure $commentTag -fore $::pgnColor(Comment)
        }
        $w tag bind $commentTag <ButtonRelease-1> \
            "sc_move pgn [string range $commentTag 2 end]; updateBoard; ::commenteditor::Open"
        $w tag bind $commentTag <Any-Enter> \
            "$w tag configure $commentTag -underline 1
             $w configure -cursor hand2"
        $w tag bind $commentTag <Any-Leave> \
            "$w tag configure $commentTag -underline 0
             $w configure -cursor {}"
      }
      
      if {$tagName == {h1}} {$w insert end \n}
    }

    # Now insert the text up to the formatting tag
    $w insert end [string range $str 0 [expr {$startPos - 1}]]

    # Check if it is a name tag matching the section we want
    if {$section != {}  &&  [strIsPrefix {name } $tagName]} {
      set sect [string range $tagName 5 end]
      if {$section == $sect} { set seePoint [$w index insert] }
    }

    if {[string index $tagName 0] == {/}} {
      ### process tag close, e.g. </menu>
      # Get rid of initial "/" character
      set tagName [string range $tagName 1 end]
      switch -- $tagName {
        h1 - h2 - h3 - h4 - h5  {$w insert end \n}
      }
      if {$tagName == {p}} {$w insert end \n}
      #if {$tagName == {h1}} {$w insert end \n}
      if {$tagName == {menu}} {$w insert end \]}
      if {$tagName == {ul}} {
        incr helpWin(Indent) -4
        $w insert end \n
      }
      if {[info exists startIndex($tagName)]} {
        switch -- $tagName {
          a  {$w tag add $linkTag $startIndex($tagName) [$w index insert]}
          g  {$w tag add $gameTag $startIndex($tagName) [$w index insert]}
          c  {$w tag add $commentTag $startIndex($tagName) [$w index insert]}
          m  {$w tag add $moveTag $startIndex($tagName) [$w index insert]}
          pi {$w tag add $playerTag $startIndex($tagName) [$w index insert]}
          url {$w tag add $urlTag $startIndex($tagName) [$w index insert]}
          run {$w tag add $runTag $startIndex($tagName) [$w index insert]}
          go {$w tag add $goTag $startIndex($tagName) [$w index insert]}
          default {$w tag add $tagName $startIndex($tagName) [$w index insert]}
        }
        unset startIndex($tagName)
      }
    } else {
      switch -- $tagName {
        ul {incr helpWin(Indent) 4}
        li {
          $w insert end \n
          for {set space 0} {$space < $helpWin(Indent)} {incr space} {
            $w insert end { }
          }
        }
        p  {$w insert end \n}
        br {$w insert end \n}
        q  {$w insert end \"}
        lt {$w insert end <}
        gt {$w insert end >}
        h2 - h3 - h4 - h5  {$w insert end \n}
      }
      #Set the start index for this type of tag
      set startIndex($tagName) [$w index insert]
      if {$tagName == {menu}} {$w insert end \[}
    }

    # Image or button tag
    if {[strIsPrefix {img } $tagName]} {
      set imgName [string range $tagName 4 end]
      set winName $w.$imgName
      while {[winfo exists $winName]} { append winName a }
      label $winName -image $imgName -relief flat -borderwidth 0
      $w window create end -window $winName
    }
    if {[strIsPrefix {button } $tagName]} {
      set imgName [string range $tagName 7 end]
      set winName $w.$imgName
      while {[winfo exists $winName]} { append winName a }
      button $winName -image $imgName
      $w window create end -window $winName
    }
    if {[strIsPrefix {window } $tagName]} {
      set winName [string range $tagName 7 end]
      $w window create end -window $winName
    }

    # Now eliminate the processed text from the string
    set str [string replace $str 0 $endPos]
    incr count
    if {$count == $::htext::updates($w)} { update idletasks; set count 1 }
    if {$::htext::interrupt} {
      $w configure -state disabled
      return
    }
  }

  # Now add any remaining text:
  if {! $::htext::interrupt} { $w insert end $str }

  if {$seePoint != {}} { $w yview $seePoint }
  $w configure -state disabled
  # set elapsed [expr {[clock clicks -milli] - $start}]
}


# openURL:
#    Sends a command to the user's web browser to view a webpage given
#    its URL.
#
proc openURL {url} {
  global windowsOS
  busyCursor .
  if {$windowsOS} {
    # On Windows, use the "start" command:
    if {[string match $::tcl_platform(os) "Windows NT"]} {
      catch {exec $::env(COMSPEC) /c start $url &}
    } else {
      catch {exec start $url &}
    }
    unbusyCursor .
    return
  }

  # On Unix systems try Firefox or Mozilla

  if {[file executable /usr/bin/firefox]  ||
    [file executable /usr/local/bin/firefox]} {
    # First, try -remote mode
    if {[catch {exec /bin/sh -c "firefox -remote 'openURL($url)'"}]} {
      # Now try a new firefox process
      catch {exec /bin/sh -c "firefox '$url'" &}
    }
  } else {
    # OK, no Firefox (poor user) so try Mozilla (yuck):
    # First, try -remote mode to avoid starting a new mozilla process
    if {[catch {exec /bin/sh -c "mozilla -raise -remote 'openURL($url)'"}]} {
      # Now just try starting a new mozilla process
      catch {exec /bin/sh -c "mozilla '$url'" &}
    }
  }
  unbusyCursor .
}
