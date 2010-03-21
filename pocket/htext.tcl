### ScidPocket.
### Copyright (C) 2007  Pascal Georges
###################
# htext.tcl: Online help/hypertext display module for Scid
#
# The htext module implements html-like display in a text widget.
# It is used in Scid for the help and crosstable windows, and for
# the game information area.

namespace eval htext {
  set headingColor "\#990000"
  array set updates {}
  # ##################################################################
  proc updateRate {w rate} {
    set ::htext::updates($w) $rate
  }
  
  # ##################################################################
  proc init {w} {
    set cyan "\#007000"
    set maroon "\#990000"
    set green "darkgreen"
    
    set ::htext::updates($w) 100
    $w tag configure black -foreground black
    $w tag configure white -foreground white
    $w tag configure red -foreground red
    $w tag configure blue -foreground blue
    $w tag configure darkblue -foreground darkBlue
    $w tag configure green -foreground $green
    $w tag configure cyan -foreground $cyan
    $w tag configure yellow -foreground yellow
    $w tag configure maroon -foreground $maroon
    $w tag configure gray -foreground gray20
    
    $w tag configure bgBlack -background black
    $w tag configure bgWhite -background white
    $w tag configure bgRed -background red
    $w tag configure bgBlue -background blue
    $w tag configure bgLightBlue -background lightBlue
    $w tag configure bgGreen -background $green
    $w tag configure bgCyan -background $cyan
    $w tag configure bgYellow -background yellow
    
    $w tag configure tab -lmargin2 20
    $w tag configure li -lmargin2 20
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
    $w tag configure h1 -font font_H1 -foreground $::htext::headingColor \
        -justify center
    $w tag configure h2 -font font_H2 -foreground $::htext::headingColor
    $w tag configure h3 -font font_H3 -foreground $::htext::headingColor
    $w tag configure h4 -font font_H4 -foreground $::htext::headingColor
    $w tag configure h5 -font font_H5 -foreground $::htext::headingColor
    $w tag configure footer -font font_Small -justify center
    
    $w tag configure term -font font_BoldItalic -foreground $::htext::headingColor
    $w tag configure menu -font font_Bold -foreground $cyan
    
    # PGN-window-specific tags:
    $w tag configure tag -foreground $::pgn::pgnColor(Header)
    if { $::pgn::boldMainLine } {
      $w tag configure nag -foreground $::pgn::pgnColor(Nag) -font font_Regular
      $w tag configure var -foreground $::pgn::pgnColor(Var) -font font_Regular
    } else {
      $w tag configure nag -foreground $::pgn::pgnColor(Nag)
      $w tag configure var -foreground $::pgn::pgnColor(Var)
    }
    $w tag configure ip1 -lmargin1 10 -lmargin2 10
    $w tag configure ip2 -lmargin1 20 -lmargin2 20
  }
  
  proc isStartTag {tagName} {
    return [expr {![strIsPrefix "/" $tagName]} ]
  }
  # ##################################################################
  proc isEndTag {tagName} {
    return [strIsPrefix "/" $tagName]
  }
  
  # ##################################################################
  proc isLinkTag {tagName} {
    return [strIsPrefix "a " $tagName]
  }
  
  # ##################################################################
  proc extractLinkName {tagName} {
    if {[::htext::isLinkTag $tagName]} {
      return [lindex [split [string range $tagName 2 end] " "] 0]
    }
    return ""
  }
  
  # ##################################################################
  proc extractSectionName {tagName} {
    if {[::htext::isLinkTag $tagName]} {
      return [lindex [split [string range $tagName 2 end] " "] 1]
    }
    return ""
  }
  
  set interrupt 0
  
  # ##################################################################
  proc display {w helptext {section ""} {fixed 1}} {
    global helpWin
    # set start [clock clicks -milli]
    set helpWin(Indent) 0
    set ::htext::interrupt 0
    $w mark set insert 0.0
    $w configure -state normal
    set linkName ""
    
    set count 0
    set str $helptext
    if {$fixed} {
      regsub -all "\n\n" $str "<p>" str
      regsub -all "\n" $str " " str
    } else {
      regsub -all "\[ \n\]+" $str " " str
      regsub -all ">\[ \n\]+" $str "> " str
      regsub -all "\[ \n\]+<" $str " <" str
    }
    set tagType ""
    set seePoint ""
    
    if {! [info exists ::htext::updates($w)]} {
      set ::htext::updates($w) 100
    }
    
    # Loop through the text finding the next formatting tag:
    
    while {1} {
      set startPos [string first "<" $str]
      if {$startPos < 0} { break }
      set endPos [string first ">" $str]
      if {$endPos < 1} { break }
      
      set tagName [string range $str [expr {$startPos + 1}] [expr {$endPos - 1}]]
      
      # Check if it is a starting tag (no "/" at the start):
      
      if {![strIsPrefix "/" $tagName]} {
        
        # Check if it is a link tag:
        if {[strIsPrefix "a " $tagName]} {
          set linkName [::htext::extractLinkName $tagName]
          set sectionName [::htext::extractSectionName $tagName]
          set linkTag "link ${linkName} ${sectionName}"
          set tagName "a"
          $w tag configure "$linkTag" -foreground blue -underline 1
          $w tag bind "$linkTag" <ButtonRelease-1> \
              "helpWindow $linkName $sectionName"
          $w tag bind $linkTag <Any-Enter> \
              "$w tag configure \"$linkTag\" -background yellow
          # $w configure -cursor hand2"
          $w tag bind $linkTag <Any-Leave> \
              "$w tag configure \"$linkTag\" -background {}
          # $w configure -cursor {}"
        } elseif {[strIsPrefix "url " $tagName]} {
          # Check if it is a URL tag:
          set urlName [string range $tagName 4 end]
          set urlTag "url $urlName"
          set tagName "url"
          $w tag configure "$urlTag" -foreground red -underline 1
          $w tag bind "$urlTag" <ButtonRelease-1> "openURL {$urlName}"
          $w tag bind $urlTag <Any-Enter> \
              "$w tag configure \"$urlTag\" -background yellow
          $w configure -cursor hand2"
          $w tag bind $urlTag <Any-Leave> \
              "$w tag configure \"$urlTag\" -background {}
          $w configure -cursor {}"
        } elseif {[strIsPrefix "run " $tagName]} {
          # Check if it is a Tcl command tag:
          set runName [string range $tagName 4 end]
          set runTag "run $runName"
          set tagName "run"
          $w tag bind "$runTag" <ButtonRelease-1> "catch {$runName}"
          $w tag bind $runTag <Any-Enter> \
              "$w tag configure \"$runTag\" -foreground yellow
          $w tag configure \"$runTag\" -background darkBlue
          $w configure -cursor hand2"
          $w tag bind $runTag <Any-Leave> \
              "$w tag configure \"$runTag\" -foreground {}
          $w tag configure \"$runTag\" -background {}
          $w configure -cursor {}"
        } elseif {[strIsPrefix "go " $tagName]} {
          # Check if it is a goto tag:
          set goName [string range $tagName 3 end]
          set goTag "go $goName"
          set tagName "go"
          $w tag bind "$goTag" <ButtonRelease-1> \
              "catch {$w see \[lindex \[$w tag nextrange $goName 1.0\] 0\]}"
          $w tag bind $goTag <Any-Enter> \
              "$w tag configure \"$goTag\" -foreground yellow
          $w tag configure \"$goTag\" -background maroon
          # $w configure -cursor hand2"
          $w tag bind $goTag <Any-Leave> \
              "$w tag configure \"$goTag\" -foreground {}
          $w tag configure \"$goTag\" -background {}
          # $w configure -cursor {}"
        } elseif {[strIsPrefix "pi " $tagName]} {
          # Check if it is a player info tag:
          set playerTag $tagName
          set playerName [string range $playerTag 3 end]
          set tagName "pi"
          $w tag configure "$playerTag" -foreground darkBlue
          $w tag bind "$playerTag" <ButtonRelease-1> "playerInfo \"$playerName\""
          $w tag bind $playerTag <Any-Enter> \
              "$w tag configure \"$playerTag\" -foreground yellow
          $w tag configure \"$playerTag\" -background darkBlue
          $w configure -cursor hand2"
          $w tag bind $playerTag <Any-Leave> \
              "$w tag configure \"$playerTag\" -foreground darkBlue
          $w tag configure \"$playerTag\" -background {}
          $w configure -cursor {}"
        } elseif {[strIsPrefix "g_" $tagName]} {
          # Check if it is a game-load tag:
          set gameTag $tagName
          set tagName "g"
          set gnum [string range $gameTag 2 end]
          set glCommand "::game::LoadMenu $w [sc_base current] $gnum %X %Y"
          $w tag bind $gameTag <ButtonPress-1> $glCommand
          $w tag bind $gameTag <ButtonPress-3> \
              "::gbrowser::new [sc_base current] $gnum"
          $w tag bind $gameTag <Any-Enter> \
              "$w tag configure $gameTag -foreground yellow
          $w tag configure $gameTag -background darkBlue
          $w configure -cursor hand2"
          $w tag bind $gameTag <Any-Leave> \
              "$w tag configure $gameTag -foreground {}
          $w tag configure $gameTag -background {}
          $w configure -cursor {}"
        } elseif {[strIsPrefix "m_" $tagName]} {
          # Check if it is a move tag:
          set moveTag $tagName
          set tagName "m"
          $w tag bind $moveTag <ButtonRelease-1> \
              "sc_move pgn [string range $moveTag 2 end]; ::board::updateBoard -nolastmove ; ::pgn::Refresh"
          # invoking contextual menu in PGN window
          $w tag bind $moveTag <ButtonPress-3> \
              "sc_move pgn [string range $moveTag 2 end]; ::board::updateBoard  -nolastmove ; ::pgn::Refresh"
          $w tag bind $moveTag <Any-Enter> \
              "$w tag configure $moveTag -underline 1
          $w configure -cursor hand2"
          $w tag bind $moveTag <Any-Leave> \
              "$w tag configure $moveTag -underline 0
          $w configure -cursor {}"
        } elseif {[strIsPrefix "c_" $tagName]} {
          # Check if it is a comment tag:
          set commentTag $tagName
          set tagName "c"
          if { $::pgn::boldMainLine } {
            $w tag configure $commentTag -foreground $::pgn::pgnColor(Comment) \
                -font font_Regular
          } else {
            $w tag configure $commentTag -foreground $::pgn::pgnColor(Comment)
          }
          $w tag bind $commentTag <ButtonRelease-1> \
              "sc_move pgn [string range $commentTag 2 end]; ::board::updateBoard -nolastmove ; ::pgn::Refresh"
          $w tag bind $commentTag <Any-Enter> \
              "$w tag configure $commentTag -underline 1
          $w configure -cursor hand2"
          $w tag bind $commentTag <Any-Leave> \
              "$w tag configure $commentTag -underline 0
          $w configure -cursor {}"
        }
        
        if {$tagName == "h1"} {$w insert end "\n"}
        
      }
      
      # Now insert the text up to the formatting tag:
      $w insert end [string range $str 0 [expr {$startPos - 1}]]
      
      # Check if it is a name tag matching the section we want:
      if {$section != ""  &&  [strIsPrefix "name " $tagName]} {
        set sect [string range $tagName 5 end]
        if {$section == $sect} { set seePoint [$w index insert] }
      }
      
      if {[string index $tagName 0] == "/"} {
        # Get rid of initial "/" character:
        set tagName [string range $tagName 1 end]
        switch -- $tagName {
          h1 - h2 - h3 - h4 - h5  {$w insert end "\n"}
        }
        if {$tagName == "p"} {$w insert end "\n"}
        #if {$tagName == "h1"} {$w insert end "\n"}
        if {$tagName == "menu"} {$w insert end "\]"}
        if {$tagName == "ul"} {
          incr helpWin(Indent) -4
          $w insert end "\n"
        }
        if {[info exists startIndex($tagName)]} {
          switch -- $tagName {
            a {$w tag add $linkTag $startIndex($tagName) [$w index insert]}
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
            $w insert end "\n"
            for {set space 0} {$space < $helpWin(Indent)} {incr space} {
              $w insert end " "
            }
          }
          p  {$w insert end "\n"}
          br {$w insert end "\n"}
          q  {$w insert end "\""}
          lt {$w insert end "<"}
          gt {$w insert end ">"}
          h2 - h3 - h4 - h5  {$w insert end "\n"}
        }
        #Set the start index for this type of tag:
        set startIndex($tagName) [$w index insert]
        if {$tagName == "menu"} {$w insert end "\["}
      }
      
      # Check if it is an image or button tag:
      if {[strIsPrefix "img " $tagName]} {
        set imgName [string range $tagName 4 end]
        set winName $w.$imgName
        while {[winfo exists $winName]} { append winName a }
        label $winName -image $imgName -relief flat -borderwidth 0 -background white
        $w window create end -window $winName
      }
      if {[strIsPrefix "button " $tagName]} {
        set imgName [string range $tagName 7 end]
        set winName $w.$imgName
        while {[winfo exists $winName]} { append winName a }
        button $winName -image $imgName
        $w window create end -window $winName
      }
      if {[strIsPrefix "window " $tagName]} {
        set winName [string range $tagName 7 end]
        $w window create end -window $winName
      }
      
      # Now eliminate the processed text from the string:
      set str [string range $str [expr {$endPos + 1}] end]
      incr count
      if {$count == $::htext::updates($w)} { update idletasks; set count 1 }
      if {$::htext::interrupt} {
        $w configure -state disabled
        return
      }
    }
    
    # Now add any remaining text:
    if {! $::htext::interrupt} { $w insert end $str }
    
    if {$seePoint != ""} { $w yview $seePoint }
    $w configure -state disabled
    # set elapsed [expr {[clock clicks -milli] - $start}]
  }
  
}
