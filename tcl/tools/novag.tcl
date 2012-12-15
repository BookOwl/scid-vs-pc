###
### novag.tcl: part of Scid.
### Copyright (C) 2007  Pascal Georges
###
######################################################################
### add NOVAG board support

namespace eval novag {
  set fd ""
  set connected 0
  set waitBetweenMessages 0

  ##########################################################
  proc connect {} {
    global ::novag::fd

    set serial $::ExtHardware::port

    set w .novag
    toplevel $w
    text $w.output -width 40 -height 30
    entry $w.input -width 20
    button $w.send -text Send -command {
      ::novag::send [.novag.input get]
      .novag.input delete 0 end
    }
    bind $w.input <Return> " $w.send invoke "
    bind $w <Destroy> { catch ::novag::disconnect }
    bind $w <F1> { helpWindow Novag}

    pack $w.output $w.input $w.send
    update

    # Set button to "connection in progress"
    ::ExtHardware::HWbuttonImg tb_eng_connecting
    
    if {[catch { set fd [open $serial r+ ] } err]} {
        tk_messageBox -type ok -icon error -parent . -title "Novag Citrine" -message "Connection error for $serial \n $err"
        destroy $w
        return
    }

    # 57600 bauds, no parity, 8 bits, 1 stop
    fconfigure $fd -mode 57600,n,8,1 -blocking 0 -buffering line
    fileevent $fd readable ::novag::recv
    # human / human mode
    # get info
    ::novag::send "I"
    wait 200
    # new game
    ::novag::send "N"
    wait 200
    ::novag::send "X ON"
    wait 200
    ::novag::send "U ON"
    set ::novag::connected 1
  }
  ##########################################################
  proc disconnect {} {
    global ::novag::fd
    close $fd
    set ::novag::connected 0
  }

  ##########################################################
  proc addMove {san} {
    # if promotion add "/"
    if {[string length $san] == 5} {
      set san "[string range $san 0 3]/[string range $san 4 end]"
    }

    ::novag::send "M $san"
    if { [ string first "x" [sc_game info previousMove] ] != -1 } {
      wait 3000
    } else {
      wait 200
    }
    # ::novag::send "T"
    ::novag::send "M $san"
  }
  ##########################################################
  proc send {msg} {
    global ::novag::fd
    puts "sending $msg"
    puts $fd "$msg\n\r"
  }
  ##########################################################
  proc recv {} {
    global ::novag::fd
    set l [gets $fd]
    if { $l == "" } { return }
    puts "received $l"
    .novag.output insert end "$l\n"
    .novag.output yview moveto 1

    if {[string match -nocase "New Game*" $l]} {
      sc_game new
      updateBoard -pgn
      ::novag::send "U ON"
      return
    }

    if {[lindex $l 0] == "M"} {
      
      if {[sc_pos side] == "white" && [string index [lindex $l 1] end ] == ","} {  return }
      if {[sc_pos side] == "black" && [string index [lindex $l 1] end ] != ","} {  return }
      
      set m [lindex $l 2]
      set m [regsub -- "-" $m ""]
      set m [regsub -- "/" $m ""]
      if { [ catch { sc_move addSan $m } err ] } {
        puts $err
      } else {
        if {[winfo exists .fics]} {
          if { $::fics::playing == 1} {
            ::fics::writechan [ sc_game info previousMoveNT ]
          }
        }
      }
      updateBoard -pgn
      return
    }

    if {[lindex $l 0] == "T"} {
      sc_move back
      updateBoard -pgn
      return
    }

  }
  ##########################################################
  proc wait {ms} {
    after $ms {set ::novag::waitBetweenMessages 1}
    vwait ::novag::waitBetweenMessages
  }
}

###
### End of file: novag.tcl
###
