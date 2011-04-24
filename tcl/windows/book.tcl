###
### book.tcl: part of Scid.
### Copyright (C) 2007  Pascal Georges
###
######################################################################
### Book window

namespace eval book {
  set isOpen 0
  set isReadonly 0
  set bookList ""
  set bookPath ""
  set currentBook1 "" ; # book in form abc.bin
  set currentBook2 ""
  set currentTuningBook ""
  set bookMoves ""
  set cancelBookExport 0
  set exportCount 0
  set exportMax 3000
  set hashList ""
  set bookSlot1 0
  set bookSlot2 1
  # Whats the significance of "bookTuningSlot 2"
  set bookTuningSlot 2

  ################################################################################
  # open a book, closing any previously opened one (called by annotation analysis)
  # arg name : gm2600.bin for example
  ################################################################################
  proc scBookOpen {n name slot} {
    if {$slot == [set ::book::bookSlot1]} {
      if {$::book::currentBook1 != ""} {
        sc_book close $::book::bookSlot1
      }
      set ::book::currentBook1 $name
    }
    if {$slot == [set ::book::bookSlot2]} {
      if {$::book::currentBook2 != ""} {
        sc_book close $::book::bookSlot2
      }
      set ::book::currentBook2 $name
    }
    if {$slot == $::book::bookTuningSlot} {
      if {$::book::currentTuningBook != ""} {
        sc_book close $::book::bookTuningSlot
      }
      set ::book::currentTuningBook $name
    }

    set bn [ file join $::scidBooksDir $name ]
    set ::book::isReadonly [sc_book load $bn $slot]
  }

  ################################################################################
  # Return a move in book for position fen. If there is no move in book, returns ""
  # Is used by engines, not book windows
  ################################################################################
  proc getMove {book fen slot {n 1}} {
    set tprob 0
    ::book::scBookOpen $n $book $slot
    set bookmoves [sc_book moves $slot]
    if {[llength $bookmoves] == 0} {
      return ""
    }
    set r [expr {(int (rand() * 100))} ]
    for {set i 0} {$i<[llength $bookmoves]} {incr i 2} {
      set m [lindex $bookmoves $i]
      set prob [string range [lindex $bookmoves [expr $i + 1] ] 0 end-1 ]
      incr tprob $prob
      if { $tprob >= $r } {
        break
      }
    }
    sc_book close $slot
    return $m
  }
  ################################################################################
  #  Show moves leading to book positions
  ################################################################################
  proc togglePositionsDisplay {} {
    global ::book::oppMovesVisible
    if { $::book::oppMovesVisible} {
      pack .bookWin.1.opptext  ;# -expand yes -fill both
      pack .bookWin.2.opptext  ;# -expand yes -fill both
    } else {
      pack forget .bookWin.1.opptext
      pack forget .bookWin.2.opptext
    }
  }

  ################################################################################
  #  Open a window to select book and display book moves
  # arg name : gm2600.bin for example
  ################################################################################
  proc OpenClose {} {
    global ::book::bookList ::book::bookPath ::book::currentBook1 ::book::currentBook2 ::book::isOpen ::book::lastBook1 ::book::lastBook2

    set w .bookWin

    if {[winfo exists $w]} {
      destroy $w
      set ::book::isOpen 0
      return
    }

    set ::book::isOpen 1

    toplevel $w
    wm title $w $::tr(Book)
wm minsize $w 50 200
    wm resizable $w 0 1

    setWinLocation $w
    # setWinSize $w
    bind $w <F1> {helpWindow Book}
    bind $w <F11>  ::book::OpenClose

    frame $w.main 
    bind $w.main <Button-4> ::move::Back
    bind $w.main <Button-5> ::move::Forward
    pack $w.main -fill both -side left

    set name1 $lastBook1
    set name2 $lastBook2

    set bookPath $::scidBooksDir
    set bookList [ lsort -dictionary [ glob -nocomplain -directory $bookPath *.bin ] ]

    if { [llength $bookList] == 0 } {
      # No book found
      destroy $w
      set ::book::isOpen 0
      set ::book::currentBook1 {}
      set ::book::currentBook2 {}
      tk_messageBox -title "Scid" -type ok -icon error -message "No books found in books directory \"$bookPath\""
      return
    }

    set i 0
    set idx1 0
    set idx2 0
    set tmp {}
    foreach file  $bookList {
      set f [ file tail $file ]
      lappend tmp $f
      if {$name1 == $f} { set idx1 $i }
      if {$name2 == $f} { set idx2 $i }
      incr i
    }
    ttk::combobox $w.main.combo1 -width 12 -values $tmp
    ttk::combobox $w.main.combo2 -width 12 -values $tmp

    catch { $w.main.combo1 current $idx1 }
    catch { $w.main.combo2 current $idx2 }

    pack $w.main.combo1 -side top -pady 5
    pack $w.main.combo2 -side top -pady 5

    if {!$::book::showTwo} {
      $w.main.combo2 configure -state disabled
    }
    
    checkbutton $w.main.alpha -text {Alphabetical} -variable ::book::sortAlpha  -command ::book::refresh

    checkbutton $w.main.showtwo -text {Two Books} -variable ::book::showTwo  -command {
      if {$::book::showTwo} {
        .bookWin.main.combo2 configure -state normal
	pack .bookWin.2 -fill both -side right
      } else {
        .bookWin.main.combo2 configure -state disabled
        pack forget .bookWin.2
      }
      ::book::refresh
    }

    checkbutton $w.main.showopp -text {Opponent's Book} -variable ::book::oppMovesVisible \
       -command { ::book::togglePositionsDisplay }
    ::utils::tooltip::Set $w.main.showopp {Moves to which the opponent has a reply}

    pack $w.main.alpha   -side top -anchor w -pady 5
    pack $w.main.showtwo     -side top -anchor w -pady 5
    pack $w.main.showopp -side top -anchor w -pady 5

    frame $w.main.buttons
    pack $w.main.buttons -side bottom -pady 10

    button $w.main.buttons.back -image tb_prev -command ::move::Back -relief flat
    button $w.main.buttons.next -image tb_next -command ::move::Forward -relief flat

    pack $w.main.buttons.back -side left  -padx 3
    pack $w.main.buttons.next -side right -padx 3

    dialogbutton $w.main.help -textvariable ::tr(Help) -command {helpWindow Book}
    dialogbutton $w.main.close -textvariable ::tr(Close) -command "destroy $w"

    pack $w.main.close -side bottom -pady 5
    pack $w.main.help -side bottom -pady 5

    frame $w.1
    frame $w.2
    
    pack $w.1 -fill both -side left
    pack $w.2 -fill both -side right

    if {!$::book::showTwo} {
      pack forget $w.2
    }

    # The width of "12" is not enough for larger fonts ?!

    label $w.1.label -font font_Fixed -width 10
    label $w.2.label -font font_Fixed -width 10
    text $w.1.booktext -wrap none -state disabled -width 10 -cursor top_left_arrow -font font_Fixed
    text $w.2.booktext -wrap none -state disabled -width 10 -cursor top_left_arrow -font font_Fixed

    pack $w.1.label -side top
    pack $w.2.label -side top

    pack $w.1.booktext -expand yes -fill both
    pack $w.2.booktext -expand yes -fill both
    
    text $w.1.opptext -wrap none -state disabled -height 6 -width 10 -cursor top_left_arrow -font font_Fixed
    text $w.2.opptext -wrap none -state disabled -height 6 -width 10 -cursor top_left_arrow -font font_Fixed

    bind $w.main.combo1 <<ComboboxSelected>> {::book::bookSelect}
    bind $w.main.combo2 <<ComboboxSelected>> {::book::bookSelect}
    bind $w <Destroy> "::book::closeMainBook"
    bind $w <Escape> {destroy .bookWin}
    bind $w <Left> ::move::Back 
    bind $w <Right> ::move::Forward

# Why
if {0} {
    # we make a redundant check here, another one is done a few line above
    if { [catch {bookSelect} ] } {
      tk_messageBox -title "Scid" -type ok -icon error -message "No books found. Check books directory"
      set ::book::isOpen 0
      set ::book::currentBook1 ""
      set ::book::currentBook2 ""
      destroy  .bookWin
    }
}
    bind $w <Configure> "recordWinSize $w"
    ::book::bookSelect
  }

  ################################################################################
  #
  ################################################################################
  proc closeMainBook {} {
focus .
    if { $::book::currentBook1 != "" } {
      sc_book close $::book::bookSlot1
      set ::book::currentBook1 ""
    }
    if { $::book::currentBook2 != "" } {
      sc_book close $::book::bookSlot2
      set ::book::currentBook2 ""
    }
    set ::book::isOpen 0
  }
  ################################################################################
  #   updates book display when board changes
  ################################################################################
  proc refresh {} {
    global ::book::bookMoves

    set height 0
    set nextmove [sc_game info nextMove]

    if {$::book::showTwo} {
      # Two books !
      set games {1 2}
    } else {
      set games 1
    }

    set moves1 [sc_book moves $::book::bookSlot1]
    set moves2 [sc_book moves $::book::bookSlot2]
    if {$::book::sortAlpha} {
      ### Parse the moves to insert empty lines and make the moves line up
      # should be doing this in C
      set m1 {}
      set m2 {}
      array set a1 $moves1
      array set a2 $moves2
      set ids [lsort -unique [concat [array names a1] [array names a2]]]
      foreach id $ids {
	if {[info exists a1($id)]} {
	  lappend m1 $id $a1($id)
	  if {[info exists a2($id)]} {
	    lappend m2 $id $a2($id)
	  } else {
	    lappend m2 {} {}
	  }
	} else {
	  lappend m1 {} {}
	  lappend m2 $id $a2($id)
	}
      }
      set moves1 $m1
      set moves2 $m2
    }

    foreach z $games {
      foreach t [.bookWin.$z.booktext tag names] {
	  .bookWin.$z.booktext tag delete $t
      }
      foreach t [.bookWin.$z.opptext tag names] {
	  .bookWin.$z.opptext tag delete $t
      }

      set bookMoves [set moves$z]

      .bookWin.$z.booktext configure -state normal
      .bookWin.$z.booktext delete 1.0 end
      set line 1
      foreach {x y} $bookMoves {
        if {$x == {}} {
	  .bookWin.$z.booktext insert end [format "%5s %3s\n" $x $y]
          incr line
          continue
        }
        if {[string length $y] < 3} {set y " $y"}
	if {$x == $nextmove} {
	  ### (why do i have to configure this here and not above ?)
	  .bookWin.$z.booktext tag configure nextmove -background lemonchiffon
	  .bookWin.$z.booktext insert end [format "%5s %3s\n" [::trans $x] $y] nextmove
	} else {
	  .bookWin.$z.booktext insert end [format "%5s %3s\n" [::trans $x] $y]
	  # .bookWin.$z.booktext insert end "[::trans $x]\t$y\n"
	}
	.bookWin.$z.booktext tag add bookMove$line $line.0 $line.end
	.bookWin.$z.booktext tag add $x            $line.0 $line.end
	.bookWin.$z.booktext tag bind bookMove$line <ButtonPress-1> "::book::makeBookMove $x"
	.bookWin.$z.booktext tag bind bookMove$line <Any-Enter> "
	  .bookWin.$z.booktext tag configure bookMove$line -background grey
	  .bookWin.1.booktext tag configure $x -background grey
	  .bookWin.2.booktext tag configure $x -background grey"
	.bookWin.$z.booktext tag bind bookMove$line <Any-Leave> "
	  .bookWin.$z.booktext tag configure bookMove$line -background {}
	  .bookWin.1.booktext tag configure $x -background {}
	  .bookWin.2.booktext tag configure $x -background {}"
	incr line
      }
      incr height [llength $bookMoves]

      set oppBookMoves [sc_book positions [set ::book::bookSlot$z]]
      .bookWin.$z.opptext configure -state normal
      .bookWin.$z.opptext delete 1.0 end

      set line 1
      foreach x $oppBookMoves {
	.bookWin.$z.opptext insert end [format "%5s\n" [::trans $x]]
	.bookWin.$z.opptext tag add bookMove$line $line.0 $line.end
	.bookWin.$z.opptext tag bind bookMove$line <ButtonPress-1> "::book::makeBookMove $x"
	incr line
      }

      .bookWin.$z.opptext configure -state disabled
togglePositionsDisplay
    }
    set height [expr $height / 4]
    .bookWin.1.booktext configure -state disabled -height $height
    .bookWin.2.booktext configure -state disabled -height $height

  }
  ################################################################################
  #
  ################################################################################
  proc makeBookMove { move } {
    set action "replace"
    if {![sc_pos isAt vend]} { set action [confirmReplaceMove] }
    if {$action == "replace"} {
      sc_move addSan $move
    } elseif {$action == "var"} {
      sc_var create
      sc_move addSan $move
    } elseif {$action == "mainline"} {
      sc_var create
      sc_move addSan $move
      sc_var exit
      sc_var promote [expr {[sc_var count] - 1}]
      sc_move forward 1
    }
    updateBoard -pgn -animate
    ::utils::sound::AnnounceNewMove $move
    if {$action == "replace"} { ::tree::doTraining }
  }
  ################################################################################
  #
  ################################################################################
  proc bookSelect {} {
    set w .bookWin
    set ::book::lastBook1 [$w.main.combo1 get]
    set ::book::lastBook2 [$w.main.combo2 get]
    $w.1.label configure -text [file rootname $::book::lastBook1]
    $w.2.label configure -text [file rootname $::book::lastBook2]
    scBookOpen 1 [$w.main.combo1 get] $::book::bookSlot1
    scBookOpen 2 [$w.main.combo2 get] $::book::bookSlot2
    refresh
  }

  ################################################################################
  #
  ################################################################################
  proc tuning { {name ""} } {
    global ::book::bookList ::book::bookPath ::book::currentBook ::book::isOpen

    set w .bookTuningWin

    if {[winfo exists $w]} {
      return
    }

    toplevel $w
    wm title $w $::tr(Book)
    # wm resizable $w 0 0

    bind $w <F1> { helpWindow BookTuningWindow }
    setWinLocation $w

    frame $w.fcombo
    frame $w.f
    # load book names
    set bookPath $::scidBooksDir
    set bookList [  lsort -dictionary [ glob -nocomplain -directory $bookPath *.bin ] ]
    # No book found
    if { [llength $bookList] == 0 } {
      tk_messageBox -title "Scid" -type ok -icon error -message "No books found. Check books directory"
      set ::book::isOpen 0
      set ::book::currentBook ""
      destroy $w
      return
    }
    set i 0
    set idx 0
    set tmp {}
    foreach file  $bookList {
      set f [ file tail $file ]
      lappend tmp $f
      if {$name == $f} {
        set idx $i
      }
      incr i
    }

    ttk::combobox $w.fcombo.combo -width 12 -values $tmp
    catch { $w.fcombo.combo current $idx }
    pack $w.fcombo.combo -expand yes -fill x

    frame $w.fbutton
   menubutton $w.fbutton.mbAdd -text $::tr(AddMove) -menu $w.fbutton.mbAdd.otherMoves
    menu $w.fbutton.mbAdd.otherMoves
    
    button $w.fbutton.bExport -text $::tr(Export) -command ::book::export
    button $w.fbutton.bSave -text $::tr(Save) -command ::book::save
    
    pack $w.fbutton.mbAdd $w.fbutton.bExport $w.fbutton.bSave -side top -fill x -expand yes

    pack $w.fcombo $w.f $w.fbutton -side top

    bind $w.fcombo.combo <<ComboboxSelected>> ::book::bookTuningSelect
    bind $w <Destroy> "::book::closeTuningBook"
    bind $w <Escape> { destroy  .bookTuningWin }
    bind $w <F1> { helpWindow BookTuning }
    bind $w <Configure> "recordWinSize $w"

    bookTuningSelect

  }
  ################################################################################
  #
  ################################################################################
  proc closeTuningBook {} {
    if { $::book::currentTuningBook == "" } { return }
    focus .
    sc_book close $::book::bookTuningSlot
    set ::book::currentTuningBook ""
  }
  ################################################################################
  #
  ################################################################################
  proc bookTuningSelect {} {
    set w .bookTuningWin

    scBookOpen 1 [.bookTuningWin.fcombo.combo get] $::book::bookTuningSlot

    if { $::book::isReadonly > 0 } {
      $w.fbutton.bSave configure -state disabled
    } else {
      $w.fbutton.bSave configure -state normal
    }
    refreshTuning
  }
  ################################################################################
  #   add a move to displayed bookmoves
  ################################################################################
  proc addBookMove { move } {
    global ::book::bookTuningMoves
    
    if { $::book::isReadonly > 0 } { return }
    
    set w .bookTuningWin
    set children [winfo children $w.f]
    set count [expr [llength $children] / 2]
    label $w.f.m$count -text [::trans $move]
    bind $w.f.m$count <ButtonPress-1> " ::book::makeBookMove $move"
    spinbox $w.f.sp$count -from 0 -to 100 -width 3
    $w.f.sp$count set 0
    grid $w.f.m$count -row $count -column 0 -sticky w
    grid $w.f.sp$count -row $count -column 1 -sticky w
    $w.fbutton.mbAdd.otherMoves delete [::trans $move]
    lappend ::book::bookTuningMoves $move
  }

  ################################################################################
  #   updates book display when board changes
  ################################################################################
  proc refreshTuning {} {
    if { $::book::isReadonly > 0 } { return }
    
    #unfortunately we need this as the moves on the widgets are translated
    #and widgets have no clientdata in tcl/tk
    global ::book::bookTuningMoves
    set ::book::bookTuningMoves {}
    set moves [sc_book moves $::book::bookTuningSlot]

    set w .bookTuningWin
    bind $w <Destroy> "" ;# avoid the closing of the book
    # erase previous children
    set children [winfo children $w.f]
    foreach c $children {
      destroy $c
    }

    set row 0
    for {set i 0} {$i<[llength $moves]} {incr i 2} {
      lappend ::book::bookTuningMoves [lindex $moves $i]
      label $w.f.m$row -text [::trans [lindex $moves $i]]
      bind $w.f.m$row <ButtonPress-1> " ::book::makeBookMove [lindex $moves $i] "
      spinbox $w.f.sp$row -from 0 -to 100 -width 3
      set pct [lindex $moves [expr $i+1] ]
      set value [string replace $pct end end ""]
      $w.f.sp$row set $value
      grid $w.f.m$row -row $row -column 0 -sticky w
      grid $w.f.sp$row -row $row -column 1 -sticky w
      incr row
    }

    # load legal moves
    $w.fbutton.mbAdd.otherMoves delete 0 end
    $w.fbutton.mbAdd.otherMoves add command -label $::tr(None)
    set moveList [ sc_pos moves ]
    foreach move $moveList {
      if { [ lsearch  $moves $move ] == -1 } {
        $w.fbutton.mbAdd.otherMoves add command -label [::trans $move] -command "::book::addBookMove $move"
      }
    }
    bind $w <Destroy> "::book::closeTuningBook"
  }
  ################################################################################
  # sends to book the list of moves and probabilities.
  ################################################################################
  proc save {} {
    global ::book::bookTuningMoves
    if { $::book::isReadonly > 0 } { return }

    set prob {}
    set w .bookTuningWin
    set children [winfo children $w.f]
    set count [expr [llength $children] / 2]
    for {set row 0} {$row < $count} {incr row} {
      lappend prob [$w.f.sp$row get]
    }
    set tempfile [file join $::scidUserDir tempfile.[pid]]
    sc_book movesupdate $::book::bookTuningMoves $prob $::book::bookTuningSlot $tempfile
    file delete $tempfile
    if {  [ winfo exists .bookWin ] } {
      ::book::refresh
    }
  }
  ################################################################################
  #
  ################################################################################
  proc export {} {
    ::windows::gamelist::Refresh
    updateTitle
    progressWindow "Scid" "ExportingBook..." $::tr(Cancel) "::book::sc_progressBar"
    set ::book::cancelBookExport 0
    set ::book::exportCount 0
    ::book::book2pgn
    set ::book::hashList ""
    closeProgressWindow
    if { $::book::exportCount >= $::book::exportMax } {
      tk_messageBox -title "Scid" -type ok -icon info \
          -message "$::tr(Movesloaded)  $::book::exportCount\n$::tr(BookPartiallyLoaded)"
    } else  {
      tk_messageBox -title "Scid" -type ok -icon info -message "$::tr(Movesloaded)  $::book::exportCount"
    }
    updateBoard -pgn
  }
  ################################################################################
  #
  ################################################################################
  proc book2pgn { } {
    global ::book::hashList

    if {$::book::cancelBookExport} { return  }
    if { $::book::exportCount >= $::book::exportMax } {
      return
    }
    set hash [sc_pos hash]
    if {[lsearch -sorted -integer -exact $hashList $hash] != -1} {
      return
    } else  {
      lappend hashList $hash
      set hashList [lsort -integer -unique $hashList]
    }

    updateBoard -pgn

    set bookMoves [sc_book moves $::book::bookTuningSlot]
    incr ::book::exportCount
    if {[expr $::book::exportCount % 50] == 0} {
      updateProgressWindow $::book::exportCount $::book::exportMax
      update
    }
    if {[llength $bookMoves] == 0} { return }

    for {set i 0} {$i<[llength $bookMoves]} {incr i 2} {
      set move [lindex $bookMoves $i]
      if {$i == 0} {
        sc_move addSan $move
        book2pgn
        sc_move back
      } else  {
        sc_var create
        sc_move addSan $move
        book2pgn
        sc_var exit
      }
    }

  }
  ################################################################################
  # cancel book export
  ################################################################################
  proc sc_progressBar {} {
    set ::book::cancelBookExport 1
  }
}
###
### End of file: book.tcl
###
