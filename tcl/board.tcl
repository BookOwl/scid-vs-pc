# board.tcl: part of Scid
# Copyright (C) 2001-2003 Shane Hudson. All rights reserved.

# letterToPiece
#    Array that maps piece letters to their two-character value.
#
array set ::board::letterToPiece [list \
    "R" wr "r" br "N" wn "n" bn "B" wb "b" bb \
    "Q" wq "q" bq "K" wk "k" bk "P" wp "p" bp "." e \
    ]

#   "name (unused), lite, dark, highcolor, bestcolor"

set colorSchemes {
  { "Blue-white" "#f3f3f3" "#7389b6" "#f3f484" "#b8cbf8" "#ffffff" "#000000" "#000000" "#ffffff" }
  { "Blue-ish" "#d0e0d0" "#80a0a0" "#b0d0e0" "#f0f0a0" }
  { "M. Thomas" "#d3d9a8" "#51a068" "#e0d873" "#86a000" }
  { "Green-Yellow" "#e0d070" "#70a070" "#b0d0e0" "#bebebe" }
  { "Brown" "#d0c0a0" "#a08050" "#b0d0e0" "#bebebe" }
}
array set newColors {}

proc SetBackgroundColour {} {
  global defaultBackground
  set temp [tk_chooseColor -initialcolor $defaultBackground -title Scid]
  if {$temp != {}} {
    set defaultBackground $temp
    option add *Text*background $temp widgetDefault
    .gameInfo configure -bg $temp
    if {[winfo exists .pgnWin.text]} { .pgnWin.text configure -bg $temp }
    if {[winfo exists .helpWin.text]} { .helpWin.text configure -bg $temp }
  }
}

proc SetBoardTextures {} {
  global boardfile_dark boardfile_lite
  # handle cases of old configuration files
  image create photo bgl20 -height 20 -width 20
  image create photo bgd20 -height 20 -width 20
  if { [ catch { bgl20 copy $boardfile_lite -from 0 0 20 20 ; bgd20 copy $boardfile_dark -from 0 0 20 20 } ] } {
    set boardfile_dark emptySquare
    set boardfile_lite emptySquare
    bgl20 copy $boardfile_lite -from 0 0 20 20
    bgd20 copy $boardfile_dark -from 0 0 20 20
  }

  foreach size $::boardSizes {
    # create lite and dark squares
    image create photo bgl$size -width $size -height $size
    image create photo bgd$size -width $size -height $size
    bgl$size copy $boardfile_lite -from 0 0 $size $size
    bgd$size copy $boardfile_dark -from 0 0 $size $size
  }
}

SetBoardTextures

# chooseBoardTextures:
#   Dialog for selecting board textures.

proc chooseBoardTextures {i} {
  global boardfile_dark boardfile_lite

  set prefix [lindex $::textureSquare $i]
  set boardfile_dark ${prefix}-d
  set boardfile_lite ${prefix}-l
  SetBoardTextures
}

proc setBoardColor {choice} {

  global colorSchemes newColors

  set list [lindex $colorSchemes $choice]
  set newColors(lite) [lindex $list 1]
  set newColors(dark) [lindex $list 2]
  set newColors(highcolor) [lindex $list 3]
  set newColors(bestcolor) [lindex $list 4]
}

proc applyBoardColors {} {

  global newColors lite dark highcolor bestcolor borderwidth

  set w .boardOptions
  set colors {lite dark highcolor bestcolor}

  foreach i $colors {
    set $i $newColors($i)
  }

  foreach i {wr bn wb bq wk bp} {
    $w.bd.$i configure -background $newColors(dark)
  }
  foreach i {br wn bb wq bk wp} {
    $w.bd.$i configure -background $newColors(lite)
  }
  $w.bd.bb configure -background $newColors(highcolor)
  $w.bd.wk configure -background $newColors(bestcolor)
  foreach i $colors {
    $w.select.b$i configure -background $newColors($i)
  }

  ### too noisy to always change the border width widget

  # foreach i {0 1 2 3} {
  #  set c $w.border.c$i
  #  $c itemconfigure dark -fill $newColors(dark) -outline $newColors(dark)
  #  $c itemconfigure lite -fill $newColors(lite) -outline $newColors(lite)
  # }

  ::board::resize .board redraw
}

proc applyBorderWidth {new} {

  global borderwidth 

  set borderwidth $new
  set ::board::_border(.board) $borderwidth

  ::board::resize .board redraw
}

proc chooseAColor {w c} {
  global colorSchemes newColors

  set x [tk_chooseColor -initialcolor $newColors($c) -title Scid -parent $w]

  if {$x != ""} {
    set newColors($c) $x
    applyBoardColors
  }
}

proc chooseBoardColors {} {

  if {[winfo exists .boardOptions]} {
    focus .
    destroy .boardOptions
  } else {
    initBoardColors
  }
}

###############
# main widget #
###############

proc initBoardColors {} {

  # These procedures re-written by S.A.

  global lite dark highcolor bestcolor
  global colorSchemes newColors boardStyles boardStyle boardSizes

  set colors {lite dark highcolor bestcolor}
  set w .boardOptions

  if { [winfo exists $w] } {
    wm deiconify $w
    raise $w .
    return
  }

  toplevel $w
  standardShortcuts $w

  wm title $w "Scid: [tr OptionsBoard]"
  wm resizable $w 0 0

  setWinLocation $w
  bind $w <Configure> "recordWinSize $w"

  ### Main widgets ordered here ###

  frame $w.pieces
  frame $w.sizes
  pack $w.sizes -side top -padx 3 -expand 1 -fill x -padx 20
  pack $w.pieces -side top

  ### Piece type and size ###

  label  $w.sizes.label -text {Piece Style} -font font_Regular
  pack   $w.sizes.label -side left

  frame $w.sizes.frame
  pack $w.sizes.frame -side right
  label  $w.sizes.frame.label -text Size -font font_Regular
  pack   $w.sizes.frame.label -side left -anchor center

  button $w.sizes.frame.smaller -text - -font font_Small -relief flat \
    -command {::board::resize .board -1}
  button $w.sizes.frame.larger -text + -font font_Small -relief flat \
    -command {::board::resize .board +1}
  pack $w.sizes.frame.larger $w.sizes.frame.smaller -side right

  foreach i $boardStyles {
    set j [string tolower $i]
    button $w.pieces.$j -text $i -font font_Small -relief flat -command "
      set boardStyle $i
      setPieceFont $i"
    pack $w.pieces.$j -side left
  }

  foreach i $colors { set newColors($i) [set $i] }

  ### Chess pieces at top of screen frame

  set bd $w.bd
  pack [frame $bd] -side top -padx 2 -pady 15

  # pack [label $w.l1 -text Colours -font font_H4]
  pack [frame $w.select] -side top -padx 5

  # addHorizontalRule $w
  pack [frame $w.preset] -side top 
  addHorizontalRule $w

  # pack [label $w.l2 -text Tiles -font font_H4]
  pack [frame $w.texture] -side top -padx 20
  ### humph. Using "-fill x" makes the gridded canvases left allign ! S.A.

  addHorizontalRule $w

  # pack [label $w.l3 -text Grid -font font_H4]
  pack [frame $w.border] -side top
  addHorizontalRule $w
  pack [frame $w.buttons] -side top -fill x

  set psize [boardSize_plus_n -2]
  set p2size [expr $psize / 2]

  ### Chess pieces at top of screen - packed above

  set column 0
  foreach j {r n b q k p} {
    label $bd.w$j -image w${j}$psize
    label $bd.b$j -image b${j}$psize
    grid $bd.b$j -row 0 -column $column
    grid $bd.w$j -row 1 -column $column
    incr column
  }

  set f $w.select
  foreach row {0 1 0 1} column {0 0 2 2} c {
    lite dark highcolor bestcolor
  } n {
    LightSquares DarkSquares SelectedSquares SuggestedSquares
  } {
    button $f.b$c -image e20 -background [set $c] -command "chooseAColor $w $c"

    button $f.l$c -text "$::tr($n)  " -command "
      chooseAColor $w $c
    " -relief flat
    grid $f.b$c -row $row -column $column
    grid $f.l$c -row $row -column [expr {$column + 1} ] -sticky w
  }

  ### Color schemes ###

  set count 0

  foreach list $colorSchemes {
    set f $w.preset.p$count
    set c1 [lindex $list 1]
    set c2 [lindex $list 2]

    canvas $f -height $psize -width $psize
    $f create rectangle 0 0 $p2size $p2size -tag dark -fill $c1 -outline $c1
    $f create rectangle $p2size $p2size $psize $psize -tag dark -fill $c1 -outline $c1
    $f create rectangle 0 $p2size $p2size $psize -tag lite -fill $c2 -outline $c2
    $f create rectangle $p2size 0 $psize $p2size -tag lite -fill $c2 -outline $c2
    pack $f -side left -padx 10 -pady 10

    bind $f <Button-1> "
      setBoardColor $count
      set ::boardfile_dark emptySquare
      set ::boardfile_lite emptySquare
      ::SetBoardTextures
      applyBoardColors"

    incr count
  }

  ### Textures ###

  set f $w.texture
  set count 0
  set row 0
  set col 0
  # pack [frame $f] -side top -padx 2 -pady 15
  foreach tex $::textureSquare {
    set f $w.texture.p$count

    ### Grids are required to easily allign in rows of five

    canvas $f -width $psize -height $psize
    grid $f -row $row -column $col -padx 10 -pady 10

    $f create image 0 0 -image ${tex}-l -anchor nw
    $f create image [expr $p2size + 1] 0 -image ${tex}-d -anchor nw
    $f create image 0 [expr $p2size + 1] -image ${tex}-d -anchor nw
    $f create image [expr $p2size + 1] [expr $p2size + 1] -image ${tex}-l -anchor nw
    bind $f <Button-1> "chooseBoardTextures $count"
    # pack $f -side top -fill x

    incr count
    incr col
    if {$col > 4} { set col 0 ; incr row }
  }

  ### Border width ###

  set f $w.border
  foreach i {0 1 2 3} {
    if {$i != 0} { pack [frame $f.gap$i -width $p2size] -side left -padx 1 }
    set c $f.c$i
    canvas $c -height $psize -width $psize -background black
    $c create rectangle 0 0 [expr {$p2size - $i}] [expr {$p2size - $i}] -tag dark
    $c create rectangle [expr {$p2size + $i}] [expr {$p2size + $i}] $psize $psize -tag dark
    $c create rectangle 0 [expr {$p2size + $i}] [expr $p2size - $i] $psize -tag lite
    $c create rectangle [expr {$p2size + $i}] 0 $psize [expr {$p2size - $i}] -tag lite
    pack $c -side left -padx 2 -pady 10
    bind $c <Button-1> "applyBorderWidth $i"

    $c itemconfigure dark -fill $dark -outline $dark
    $c itemconfigure lite -fill $lite -outline $lite
  }
  set ::newborderwidth $::borderwidth

  ### Button

  dialogbutton $w.buttons.ok -text "OK" -command "destroy $w"

  bind $w <Escape> "destroy $w"
  packbuttons top $w.buttons.ok

  applyBoardColors
}


############################################################
### Toolbar and game movement buttons:

image create photo tb_open -data {
  R0lGODdhEQARAMIAANnZ2QAAAKmpqf///76+vgAAAAAAAAAAACwAAAAAEQARAAADSQi63B0w
  RuFAGDjfQF/WGOd9g9RZEPlFSkC4RCwTpYVKuMtxqgoJu8FsSAAaL8ThjoJMxoCipvMlsgwE
  2KzW2Mp5T9twtkJWJAAAOw==
}

image create photo tb_new -data {
  R0lGODlhEQARAMIAANnZ2ampqf///wAAAP///////////////yH5BAEKAAAA
  LAAAAAARABEAAANECLoaLY5JAEGodSo4RHdDKI5C6QVBZ5qdurpvqQ4ozIqe
  oNhrjuq8mOMSZEUsRdkRkDwxmrRnrxddQJejrGi5QHm/ywQAOw==
}

image create photo tb_save -data {
  R0lGODdhEQARAKEAANnZ2QAAAJmZAP///ywAAAAAEQARAAACPISPecHtvkQYtNIAsAnS2hZN
  3iWFI6ll3cml7Tm0kfQwQrnd+q67d93AqWgQlY8IMs5quVQG+FBIp1RFAQA7
}

image create photo tb_close -data {
R0lGODlhEAAQAIABAIsAAP///yH5BAEKAAEALAAAAAAQABAAAAIljI9pAIq8
oGMt1icPxZdbZ21gOGriSJ2KqJpd2wZn/MndepdGAQA7
}

image create photo tb_finder -data {
R0lGODlhEQARAMIFAAAAAKmpqb6+vrDE3tnZ2f///////////yH5BAEKAAcA
LAAAAAARABEAAANSeLrcDTBG4Q4oOF9AX9YY4FxfITFR+UUKxwlwLJiBKEmC
FNSWag7AAYB3keUGmCCnZwQgg0JFriBzQqMtasz6xB6mux1XGEDdbjVRpcJa
NwiQBAA7
}

image create photo tb_bkm -data {
R0lGODlhEAARAMIEAAAAAIsAAKmpqbDE3v///////////////yH5BAEKAAcA
LAAAAAAQABEAAANMeKrR+w+AFqQFkRCqOxDKRV3EFw4ohQ5ACR7AqqKtCQ9U
zrpnrtavGE63swmHgRXwJFsVg87o8hZV8g6Co/Tzwl6+gq4iTC6LIehHAgA7
}

image create photo tb_cut -data {
R0lGODlhEQARAKEDAAAAAKmpqb+/v////yH5BAEKAAMALAAAAAARABEAAAI2
nI+pkBB6HJLQMPsq3toO2n0BGJIdgGbamJlTaqGQw2LCNQl3G+yNTnH4GrRI
MRFIIpKqEKQAADs=
}

image create photo tb_copy -data {
R0lGODlhEQARAMIDAAAAAKmpqdnZ2f///////////////////yH5BAEKAAQA
LAAAAAARABEAAANASLrcCzBKR8C4+ILgrPxTlVkZBiheNIArR2ql6a4qu4lm
rM3QSkstHEx3s712ioAycBxxGAKQ5OlYWpWUrHabAAA7
}

image create photo tb_paste -data {
R0lGODlhEQARAMIEAAAAAFFR+6mpqb6+vv///////////////yH5BAEKAAcA
LAAAAAARABEAAANSeHoBvjAyBySkITcnIiADRQkC0C3fIKgsaV7EWoq0kq4f
oe9EdXyyD03YuYV4vBdQJaT1iiAccqeMMXvOKqk01b1+Iizye9jmpmTUcGQp
b9+dBAA7
}

image create photo tb_gprev -data {
  R0lGODlhEQARAMIAANnZ2RwyggAAAP///6mpqampqampqampqSwAAAAAEQARAAADQgi63P4w
  wrCEvViFrcT44CcAWwl4mDUIRMl5Ichq1ZquBN3Fck7WKZSPsuPhdCdbbPYr8pjEU/DicxCu
  WKxkywUkAAA7
}

image create photo tb_gnext -data {
  R0lGODlhEQARAMIAANnZ2RwyggAAAP///6mpqampqampqampqSwAAAAAEQARAAADQQi63P4w
  wrCEvXhRJYb/nqBVA2aVhLIBHfgJKbB2Jh3P7nuTNRr8P1YuRAAGaS2dLCgcwlSV2iXmIFiv
  V4l2C0gAADs=
}

image create photo tb_rfilter -data {
R0lGODlhEAAQAMIFAAAAAIsAAJkiIr6+vrDE3v///////////yH+FUNyZWF0
ZWQgd2l0aCBUaGUgR0lNUAAh+QQBCgAHACwAAAAAEAAQAAADOxh6fBotPjaj
fMtarDXvDZZ1VSAAKHBBDUC8hEqxjFsUsKzZcAy6PV8HSMAJhz3AAFRLDVBM
SyoaQSUAADs=
}

image create photo tb_bsearch -data {
  R0lGODlhEQARACIAACH5BAkAAAAALAAAAAARABEAotnZ2aCAUNDAoAAAALDE
  3v///76+vgAAAANJKBqswmGACRy0TNK7mtIT93gCCIiiiQWr2rGvO8LlYFMn
  mRE8AaIDQqHQ0wCFPd/ExmQmeSYcIMgjKqU4KtSAlTYNt26XKR4PEgA7
}

image create photo tb_hsearch -data {
  R0lGODlhEQARACIAACH5BAkAAAAALAAAAAARABEAotnZ2QAngbDE3gAAAP//
  /76+vgAAAAAAAAM+CLrcvuFJECetFwcMVY0ftHkkR5HnGXrgNbzDOA1CLQwW
  TRA2Lum22yxY8z1oNZ5w2CtYALBB4fVkwKqLVwIAOw==
}

image create photo tb_msearch -data {
R0lGODlhEAAQAKUtAAAAAAUFBAcHBwgICAkJCRsZFR4dHCEfGywpIi0tLDEv
KzU1NElDOEpEOUZGRk9JPVZWVldXV2tjUmxkU25mVYtubnt7e4d8aIeHh5aN
e46OjpmZmaaZgJ2dnaqdg5+fn6+vr7S0tL29vb6+vrDE3sHBwcrKytXV1djY
2ODg4Ozs7Pn5+fz8/P//////////////////////////////////////////
/////////////////////////////////yH5BAEKAD8ALAAAAAAQABAAAAZ0
wJ8wIZEkhMjkj5NItVonhTLJAD2fGslUiEBdW6HH9tf4fC2UsccQYq06h7Fw
AiAIAhmAHpC8FBwbJSIVACSGJHxCCyZfAyRPh4kWXy2FLYeIQpNfhZiZP5tX
nY+GiREREKkQGKOIIypyewAjenJKe7ZJekEAOw==
}

image create photo tb_switcher -data {
  R0lGODdhFAAUAMIAANnZ2QAngf///wAAAP/tuMvFxosAAAAAACwAAAAAFAAUAAADWQi63B0w
  ykmrvZiKzbvn0DaMZPmFwkCsLDGkHqqWs9jJLVsWYCC6pdaAt8HlhEQBjjZaDXu/I6uQlDFH
  BYOh6ttQv2CtAdoRm8/KLufMHqM+ZS0Zvh73MpYEADs=
}

image create photo tb_pgn -data {
R0lGODlhFAAUAMZGAAAAAAUFBQYGBgcHBwsLCwwMDA0NDRUVFQAdYhwcHB8f
HwAicSEhIQAngScnJyoqKjIyMjU1NTo6Ojs7Oz8/P0NDQ0RERFdXV1paWlxc
XGBgYGFhYWhoaHBwcHFxcXJycn5+fn9/f4CAgIGBgYeHh4yMjI2NjY+Pj5KS
kpOTk56enqCgoKGhoaampqenp7KysrW1tby8vMHBwcPDw8nJycvLy9HR0dPT
09fX19jY2N7e3uDg4OHh4efn5+vr6+7u7u/v7/Hx8fLy8vn5+fv7+/7+/v//
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
/////////////////////////////////////////////////yH5BAEKAH8A
LAAAAAAUABQAAAepgH+Cg4SFhQ2IiYqLjI2Oj5CMRpOUlZaUiJealpmbnp2e
mg0LISEjKUBGPiQZGB45PCJCRjcsDQgAJiYJF0AMFDAxKDUzAB1GLhW3AD1G
GhElBEGVMwUCNsnLIx4DJxsQRkQ4OEIzDhwSLcq4ICk0Rh8KqhUALuY/Bxbr
zJQyACuT6pkzogLAvmaUTBh4ICHAi4FFJihroImIjh1DRFEMpZFjR4+cIj0K
BAA7
}

image create photo tb_glist -data {
  R0lGODdhFAAUAMIAANnZ2QAngf///wAAAIsAAAAAAAAAAAAAACwAAAAAFAAUAAADQgi63B0w
  ykmrvZiKzbvnkDAMX7mFo6AJRNuqgSnDIjl3KCl17hvenxwQFEutegTaEFe0DYUTDlK5PAUc
  2Mc1y81gEgA7
}

image create photo tb_tmt -data {
R0lGODlhFAAUAMIFAAAAAAAngYsAALDE3tnZ2f///////////yH5BAEKAAcA
LAAAAAAUABQAAANbSLrcHTDKSau9mJbNu+dQAYxiIZjoeRahB3xeOL4nnaJs
AJe7TKql2WvT2gEGyMHQZ6sNNslX8XMsJJU50Q91vGKnrqT1q5vdRFcAIbvb
CAkjcNsdn8PimQogAQA7
}

image create photo tb_maint -data {
R0lGODlhFAAUAMZPAAAngZBdLYRsWYlwWrtmEY9zWK9xIJJ4XLxwFa90JJV4
Wn5+h5d6Wn5+ipx9W6KBWMKAGqiHW8mIGs+HGM6JG8WLLuaCCM+JJc+LKOmG
BtKPG9SQGv6ABNqSF/6FBv2GBpubrv6JB/OPC7Cej/6RBv6RCbOhlvGcDfyY
C/ikEP6iEL2qmv6jEP6kEP2mEK+vv/6pE/6sE7OzwrK2zv61GLm5yLy8yf68
Gb29yv6+G76+y8PG2v7OINLS3NjY4NjY4dra4tzc4t7e5ODg5ODg5uHh5+Li
5+Pj6Onp7uvr7u3t8vf3+fj4+fv7+/7+/v//////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
/////////////////////////////////////////////////yH5BAEKAH8A
LAAAAAAUABQAAAe8gH+Cg4SFhQCIiYqLjI2Oj5CMT5NPRjUNmEaUm0+Im5c7
TpeclJ6cC01ODZqkppsLSaINpJ0AlbOTNUxLo622DTsLCzVBSEqrtJ6rPThH
RENFlxG+Tw0gQkU/QD46MyMV05umDTUvNTI2OysXFh0P4raVC5gNNiYYGR8i
Gw6l8ZwNEpxgwUJFCg0MJrnipIDCjRw0YLiYcKAWrUkFJPCIEcIDCgMWLz4Z
AKFFCQ4kEIQUKYAAg5cBakVyFAgAOw==
}

image create photo tb_eco -data {
R0lGODlhFAAUAKUAAAAAAAgICA0NDRERERISEhMTExgYGBsbGxwcHB0dHSMj
IwAngYsAACoqKiwsLC0tLTc3Nz8/P0BAQEdHR0pKSktLS09PT1NTU1ZWVlpa
WjZki1xcXF1dXV9fX2JiYmRkZGZmZm5ubnJycnh4eH5+fn9/f4CAgIeHh5GR
kaOjo7Ozs7y8vMLCwsPDw83NzdXV1d7e3uPj4+Xl5efn5+np6fDw8Pb29v39
/f///wAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEKAD8ALAAAAAAUABQAAAab
wJ9wSCwWF8ikcslsOp9QJm5KrVqpSNwp0em4WgJP4bUacAixafY0icVuHxCO
JduIcBKUeqEdQCA1FyRUFSc4GCV7WhZUIxQ4JiohGTcNKYonAQcHKDMPCA40
MAoGETaKV6k4Gho4WQCrrVessa58sLSzrbSvDKwMwMG+GsO2OLiyVrS8t7W5
U8utr8671bWvANna29zGqt9RUEEAOw==
}

image create photo tb_tree -data {
  R0lGODdhFAAUAKEAANnZ2QAngf///6CAUCwAAAAAFAAUAAACRISPmcHtD6OcFIqLs8Zsi4GB
  WheK5kZm4BpywSXC7EC7pXlm6U3HtlwKXnafnnH08tQ8RCEquVk+lT0mlCf9ebaCCqUAADs=
}

image create photo tb_engine -data {
  R0lGODdhFAAUAMIAANnZ2QAngf///7i4uAAAAAAAAAAAAAAAACwAAAAAFAAUAAADUwi63B0w
  ykmrvZiKzcXooAB1Q/mdnveNnLmZpSoGHGGHISvcOKjbwKCQ8BsaibSdDTYIwljHIzQ6hMKW
  JuxA1yRcvVlkDVhydsXjDm9j0/VwGUwCADs=
}

image create photo tb_crosst -data {
  R0lGODdhFAAUAMIAANnZ2QAngf///wAAAIsAAAAAAAAAAAAAACwAAAAAFAAUAAADSQi63B0w
  ykmrvZiKzbvnkDCMo1h+QoiuW1iS5qqyaDilApHvehrILJtk99MZW79g7Xc7Fnc+WssjjPCI
  0Jk0GW1edUmtFJS5JAAAOw==
}

image create photo tb_help -data {
  R0lGODdhEQARAIQAANnZ2QAAAKa/ovD07+vx6uHp4MvayfP289Lf0MPUwazDqLzPuCsrK+bt
  5CEuH2WLXoythpa0kbjMtY2tiAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
  ACwAAAAAEQARAAAFSSAgjkFZjigaCANRGEGqGsdQ3EgsB8mgmIuCgiEDBBoO0k2XgqmEzKIo
  cHtEi9QC5Lq7baWkiJbbjZB3JrB6bTx3JW6VZBJXnUMAOw==
}

image create photo b_bargraph -data {
  R0lGODdhGAAYAMIAANnZ2QAngf///wAAAIsAAAAAAAAAAAAAACwAAAAAGAAYAAADYwi63P4w
  ygmDvThnpnvnXmhxQmmeqBmQaXuuS+DOAqzIwkCjNoDrlhfuxQIOa8dS70ewEJ7NAJSgLCKF
  12qsZLwGg9ob1yv7DpdjM1llVavDPu5gTq/T4ckdXp9aikIUgYITCQA7
}

image create photo b_list -data {
  R0lGODdhGAAYAKEAANnZ2QAngf///wAAACwAAAAAGAAYAAACT4SPqcvtz4KctFZkc8a6SyyE
  4kiKATgM5RqeRyCkgjfNIIu7BizjpA7gqWgS28vHAgqRI2VsSDTumCVnj2qF0qRB6g8DUSjD
  CSVxQ06rEQUAOw==
}

set tb .tb
frame $tb -relief raised -border 1
button $tb.new -image tb_new -command ::file::New
button .tb.open -image tb_open -command ::file::Open
button .tb.save -image tb_save -command {
  if {[sc_game number] != 0} {
    #busyCursor .
    gameReplace
    # catch {.save.buttons.save invoke}
    #unbusyCursor .
  } else {
    gameAdd
  }
}
button .tb.close -image tb_close -command ::file::Close
button .tb.finder -image tb_finder -command ::file::finder::Open
menubutton .tb.bkm -image tb_bkm -menu .tb.bkm.menu
menu .tb.bkm.menu
bind .tb.bkm <ButtonPress-1> "+.tb.bkm configure -relief flat"


frame .tb.space1 -width 12
button .tb.cut -image tb_cut -command ::game::Clear
button .tb.copy -image tb_copy \
    -command {catch {sc_clipbase copy}; updateBoard}
button .tb.paste -image tb_paste \
    -command {catch {sc_clipbase paste}; updateBoard -pgn}
frame .tb.space2 -width 12
button .tb.gprev -image tb_gprev -command {::game::LoadNextPrev previous}
button .tb.gnext -image tb_gnext -command {::game::LoadNextPrev next}
frame .tb.space3 -width 12
button .tb.rfilter -image tb_rfilter -command ::search::filter::reset
button .tb.bsearch -image tb_bsearch -command ::search::board
button .tb.hsearch -image tb_hsearch -command ::search::header
button .tb.msearch -image tb_msearch -command ::search::material
frame .tb.space4 -width 12
button .tb.switcher -image tb_switcher -command ::windows::switcher::Open
button .tb.glist -image tb_glist -command ::windows::gamelist::Open
button .tb.pgn -image tb_pgn -command ::pgn::OpenClose
button .tb.tmt -image tb_tmt -command ::tourney::toggle
button .tb.maint -image tb_maint -command ::maint::OpenClose
button .tb.eco -image tb_eco -command ::windows::eco::OpenClose
button .tb.tree -image tb_tree -command ::tree::make
button .tb.crosst -image tb_crosst -command ::crosstab::OpenClose
button .tb.engine -image tb_engine -command makeAnalysisWin
# button .tb.help -image tb_help -command {helpWindow Index} ; # seems unused

# Set toolbar help status messages:
foreach {b m} {
  new FileNew open FileOpen finder FileFinder
  save GameReplace close FileClose bkm FileBookmarks
  gprev GamePrev gnext GameNext
  cut GameNew copy EditCopy paste EditPaste
  rfilter SearchReset bsearch SearchCurrent
  hsearch SearchHeader msearch SearchMaterial
  switcher WindowsSwitcher glist WindowsGList pgn WindowsPGN tmt WindowsTmt
  maint WindowsMaint eco WindowsECO tree WindowsTree crosst WindowsCross
  engine ToolsAnalysis
} {
  set helpMessage(.tb.$b) $m
  # ::utils::tooltip::Set $tb.$b $m
}
set helpMessage(.button.addVar) EditAdd
set helpMessage(.button.trial) EditTrial

foreach i {new open save close finder bkm cut copy paste gprev gnext \
      rfilter bsearch hsearch msearch switcher glist pgn tmt maint \
      eco tree crosst engine} {
  .tb.$i configure -relief flat -border 1 -highlightthickness 0 -anchor n -takefocus 0
  ::utils::tooltip::Set .tb.$i [tr $::helpMessage(.tb.$i)]
}

#pack .tb -side top -fill x -before .button

proc changeToolbar {} {
    array set ::toolbar [array get ::toolbar_temp]
    redrawToolbar
}

proc bindToolbarRadio {frame i} {
  bind .tbconfig.$frame.$i <Any-Enter> \
    ".tbconfig.bar configure -text \"[tr $::helpMessage(.tb.$i)]\""
  bind .tbconfig.$frame.$i <Any-Leave> \
    ".tbconfig.bar configure -text {}"
}

proc configToolbar {} {
  set w .tbconfig
  if {[winfo exists $w]} {
    wm deiconify $w
    focus $w
    raise $w .
    return
  }
  toplevel $w
  wm state $w withdrawn
  wm title $w "Scid: [tr OptionsToolbar]"

  array set ::toolbar_temp [array get ::toolbar]

  set button_options {-height 20 -width 22 -command changeToolbar}

  set pack_options {-side left -ipadx 1 -padx 3 -ipady 1}

  pack [frame $w.f1] -side top -fill x
  foreach i {new open save close finder bkm} {
    eval checkbutton $w.f1.$i -image tb_$i -variable toolbar_temp($i) $button_options
    eval pack $w.f1.$i $pack_options
    bindToolbarRadio f1 $i
  }

  pack [frame $w.f2] -side top -fill x
  foreach i {gprev gnext} {
    eval checkbutton $w.f2.$i -image tb_$i -variable toolbar_temp($i) $button_options
    eval pack $w.f2.$i $pack_options
    bindToolbarRadio f2 $i
  }

  pack [frame $w.f3] -side top -fill x
  foreach i {cut copy paste} {
    eval checkbutton $w.f3.$i -image tb_$i -variable toolbar_temp($i) $button_options
    eval pack $w.f3.$i $pack_options
    bindToolbarRadio f3 $i
  }

  pack [frame $w.f4] -side top -fill x
  foreach i {rfilter bsearch hsearch msearch} {
    eval checkbutton $w.f4.$i -image tb_$i -variable toolbar_temp($i) $button_options
    eval pack $w.f4.$i $pack_options
    bindToolbarRadio f4 $i
  }

  pack [frame $w.f5] -side top -fill x
  foreach i {switcher glist pgn tmt maint eco tree crosst engine} {
    eval checkbutton $w.f5.$i -image tb_$i -variable toolbar_temp($i) $button_options
    eval pack $w.f5.$i $pack_options
    bindToolbarRadio f5 $i
  }

  addHorizontalRule $w
  pack [frame $w.b] -side bottom -fill x
  dialogbutton $w.on -text "+ [::utils::string::Capital $::tr(all)]" -command {
    foreach i [array names toolbar_temp] { set toolbar_temp($i) 1 }
    changeToolbar
  }
  dialogbutton $w.off -text "- [::utils::string::Capital $::tr(all)]" -command {
    foreach i [array names toolbar_temp] { set toolbar_temp($i) 0 }
    changeToolbar
  }
  dialogbutton $w.ok -text OK -command {
    array set toolbar [array get toolbar_temp]
    catch {grab release .tbconfig}
    destroy .tbconfig
    redrawToolbar
  }
  pack $w.ok -side right -padx 5 -pady 5
  pack $w.on $w.off -side left -padx 5 -pady 5

  pack [label $w.bar -text label] -side bottom -pady 5

  update
  placeWinOverParent $w .
  wm state $w normal

  # catch {grab $w}
  # ?? S.A.
}

proc redrawToolbar {} {
  global toolbar
  foreach i [winfo children .tb] { pack forget $i }
  set seenAny 0
  set seen 0
  foreach i {new open save close finder bkm} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .tb.space1 -side left }
  set seen 0
  foreach i {gprev gnext} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .tb.space2 -side left }
  set seen 0
  foreach i {cut copy paste} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .tb.space3 -side left }
  set seen 0
  foreach i {rfilter bsearch hsearch msearch} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .tb.space4 -side left }
  set seen 0
  foreach i {switcher glist pgn tmt maint eco tree crosst engine} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seenAny} {
    grid .tb -row 0 -column 0 -columnspan 3 -sticky we
  } else {
    grid forget .tb
  }
}

proc setToolbar {x} {
  if {$x} {
    grid .tb -row 0 -column 0 -columnspan 3 -sticky we
  } else {
    grid forget .tb
  }
}


image create photo tb_start -data {
R0lGODlhHgAeAKUoAD09/0FB/0JC/0RE/kZG/kpK/UxM/E1N/E5O+05O/E9P
+1BQ+1FR+1JS+lRU+lZW+VdX+VlZ+V1d915e92Ji9nBw83Jy84mJ7YqK7Y2N
7I+P65CQ65GR65WV6pqa6Jyc6J+f56Cg57e34ri44bm54rq64b6+4MXF3dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2SH5BAEKAD8ALAAAAAAeAB4AAAbx
wJ9wSCwaj8ikcslsOp/QJ6fx61CRH47nSNpoRMJp9WocQQKP4yUA0ISp1mMo
ojBIjBbHgdB5j40hFQULB3dDJRh6C3x+cUQjEQUKDIVEGAMHCwyMP2KOQnMK
mpSGP3kHDKmcnmSBg6mUEz8miZmwq3BXkJKwDAgTJxmYo6p9nbk/IBCivQwL
ChQQqM24fx0CCcSpCwkH2c2bxqzJy9rO0NLg1Y67k7C/wcO9662CxAeytIq3
4shDoaMqCTnFrxEZIe1IWZJHD5A9gUIQKWoIiI4dPHooljmTxsiaNgaTZNli
pMuXkFFSqlzJsqXLl0mCAAA7
}

image create photo tb_prev -data {
R0lGODlhHgAeAIQaAEBA/0FB/0ND/kZG/khI/UtL/EtL/U1N/E5O/E9P+1BQ
+1FR+1ZW+VhY+V1d92Fh9nFx8oqK7ZCQ65GR65OT6pWV6pqa6Jqa6aCg57m5
4tnZ2dnZ2dnZ2dnZ2dnZ2dnZ2SH5BAEKAB8ALAAAAAAeAB4AAAWE4CeOZGme
aKqubOu+cCzPaiZVlEWXUTAIjN0H03gwDouDY2a7QAiIhCK5lPUIhcRiS4UR
jUguV9lqPqNT8ZbMumbVajbKwgDD7/LTBGA4pO9ieSZ0doCBVStuWoaCKGZQ
UniILV9HkjOKh0wSTpBTjV5FlqBWPkBCIzY4Oqitrq+wsR8hADs=
}


image create photo tb_next -data {
R0lGODlhHgAeAIQaAEBA/0FB/0ND/kZG/khI/UtL/EtL/U1N/E5O/E9P+1BQ
+1FR+1ZW+VhY+V1d92Fh9nFx8oqK7ZCQ65GR65OT6pWV6pqa6Jqa6aCg57m5
4tnZ2dnZ2dnZ2dnZ2dnZ2dnZ2SH5BAEKAB8ALAAAAAAeAB4AAAWH4CeOZGme
aKqubOu+cCy7FlVJ2WwywhBEupLjsDgwHg1M8DNcKBIIAuSCmzUX2ESB8LMS
seDiMQm7hp1QKTXHMp+z2277+z4bHwyLyl3HKg4GABN7dH1Yd3mEhgtaXEBz
dU9RU1WQb3dkL26NcjFNkmqVnkSYSkE8Po9LHzU3bKuwsbKztC8hADs=
}

image create photo tb_end -data {
R0lGODlhHgAeAKUoAD09/0FB/0JC/0RE/kZG/kpK/UxM/E1N/E5O+05O/E9P
+1BQ+1FR+1JS+lRU+lZW+VdX+VlZ+V1d915e92Ji9nBw83Jy84mJ7YqK7Y2N
7I+P65CQ65GR65WV6pqa6Jyc6J+f56Cg57e34ri44bm54rq64b6+4MXF3dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2SH5BAEKAD8ALAAAAAAeAB4AAAb2
wJ9wSCwaj8ikcslsOp/QqHTY6PwaHKFIsyEdPZxPsnrN/jSAwOX4CEBGSDJW
2CEcHBajxKCIhI5yZnULdxglRBIHCwUVf0WBdAQMhAMYiAcMCgURcESQP3UM
ond5QomiC32OQp+hqIUmPxOYqIyrrZKikwcDGScTCLqZm524wqMQFAoLx6kQ
IFdWc6C5wgsJBwnM1gkC0tKC1boHycvNCs/RZZHWvL7AwpqcrODsrw4YsbO6
i41U9dTG4RlyapIqTwBDUbJEEJO8Tv/WUSOE71DDfqsiTqtDSg8fP4AAolHD
xg3ERwC3dPkSZgzAKTBjypxJE2YQADs=
}

image create photo tb_invar -data {
R0lGODlhHgAeAMZIAAAAAAQEBAcHBwkJCQsLCwwMDA0NDQ8PDxERERQUFBYW
FhcXFxgYGBkZGRsbGxwcHCIiIi4uLjo6OkREREZGRk5OTk9PT1JSUlVVVUFB
/1dXV0RE/llZWUhI/VxcXExM/GBgYE1N/GFhYWJiYlBQ+2NjY1FR+1RU+mdn
Z1lZ+Vtb+F1d93Nzc2tr9W5u9H9/f3Jy84ODg4mJiYuLi5OTk4mJ7YqK7ZaW
lpeXl5qampCQ652dnaCgoKSkpKampqenp6mpqaqqqqurq6ysrLi4uLm54rq6
4cLCwtnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2SH5BAEKAH8A
LAAAAAAeAB4AAAf9gH+Cg4SFhoeIiYqLjI2Oj5CRkootKS6JIACaP4cymgCC
Kh0nNkaHP58ghxMACIMrHyEbNogKmgyHAgAXryEmIScwhx6fQIU0mji9JiTA
pYU9nyKFFQADhCu+zLK0hQmaDYUGABTY2ia/wYUcn0GDO5oz5ujozSc1RYM8
nyODGgABCmWjVy9EBh2EEGhyMOibBIHnCh4khOGTkD8+NL2ASNAePkLwNJX4
I0LTEY70gAkzdEDTgz8PAEQwNHDbLEQXPsXQxIKmL3vPDuX4VEATEZ/pViYa
9wnCIVjcGFn4BADFIVGkTC26QXXIoUqXHBHQtGCS2bNo06pdy/ZQIAA7
}

image create photo tb_outvar -data {
R0lGODlhHgAeAMZQAAAAAAQEBAcHBwkJCQsLCwwMDA0NDQ8PDxERERQUFBYW
FhcXFxgYGBkZGRsbGxwcHCIiIi4uLjo6OkREREZGRk5OTk9PT1JSUj09/1VV
VUFB/1dXV0RE/llZWUZG/lxcXEpK/WBgYE1N/GFhYWJiYlBQ+2NjY1FR+1RU
+mdnZ1pa+XNzc25u9H9/f3Jy84ODg4mJiYuLi5OTk4mJ7YqK7ZaWlpeXl4+P
65qampCQ652dnZWU7pWV6paW6qCgoJiX65qZ7KOjo6SkpKampqenp6mpqaqq
qqurq6ysrLi4uLe34rm54rq64by85MLCwsbJ0NnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2SH5BAEKAH8A
LAAAAAAeAB4AAAf+gH+Cg4SFhoeIiYqLjI2Oj5CRkpFLOTdNT38hAJxEhzCc
QYgzGhg7gkScACGHEwAIiC4oIh5AgwqcDIcCABeGTDSzJR4/gx+qRYUynDaG
NBwiJScePYNCqiOFFQADhrIiJ+EePIQJnA2FBgAUhMDC4dPkgx2qRoM6nDGE
z9Hw8YQ+VJEYtAFAAEIsZvkTJ28QAk4OBpmTQEgFCGkLxxXKoOrInyGcWiBU
mLGhIHycTPwZwclJIX4YGRo6wOnBnwcAIvwK1k9moQuqXnBaEYvkv0I4VBXg
lCQRzKPpVAGAoMhdNI2GLEhNwegb1kI1pCJpRArDDUQEOC1wVOmGkkkJcOPK
nUu3rqNAADs=
}

image create photo tb_addvar -data {
R0lGODlhHgAeAMZFAAAAAAQEBAcHBwkJCQsLCwwMDA0NDQ8PDxERERQUFBYW
FhcXFxgYGBkZGRsbGxwcHCIiIi4uLjo6Os0AI80AJ80CKUREREZGRs4HLs4N
Mk5OTk9PT88WOc8WOlJSUlVVVVdXV1lZWVxcXGBgYGFhYWJiYmNjY2dnZ9FC
XXNzc39/f4ODg4mJiYuLi9RxhNR0hpOTk5aWlpeXl9N9jdV8jZqamp2dnaCg
oKOjo6SkpKampqenp6mpqaqqqqurq6ysrLi4uMLCwtjCxtjCx9r38nJycnJy
cnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJy
cnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJy
cnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJy
cnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJycnJyciH5BAEKAH8A
LAAAAAAeAB4AAAf+gH+Cg4SFhoeIiYqLjI2Oj5CRkpODIwCXO4cslziOO5cA
I4cWAAiIQ0OGCpcMhwIAHoczHR0zhSKgPIUwlzKHLhMTLoU5oCSFGgADiC8U
FC+GCZcNhQYAF4dENBUVNESFIaA9gzaXLYQzLi80KBgYKDQvLrZ/N6AlgyAA
AYRDHRMUKmDIkAFDBQoTOgxCcMnBIGkS+v0LOLDgwYSDPoDy8UfHJRWF0q1r
9y7ePHKgTPwhcSkIIm3cvB06cOnBnwcAIihq9gyRB1ArLqVQBEwYohqgClwC
omgGBw70DlkDBYGRECGKNoACcIISoRhbf3glRODSgrFo06pdy7Yto0AAOw==
}

# S.A. here it is
# frame .button -border 0
frame .button -relief raised -border 1
button .button.start -image tb_start -command ::move::Start
button .button.back -image tb_prev -command ::move::Back
button .button.forward -image tb_next -command ::move::Forward
button .button.end -image tb_end -command ::move::End
bind .button.end <Button-3> ::tactics::findBestMove
frame .button.space -width 15

# The go-into-variation button is a menubutton:
menubutton .button.intoVar -image tb_invar -menu .button.intoVar.menu \
    -relief raised
menu .button.intoVar.menu -tearoff 0 -font font_Regular

button .button.exitVar -image tb_outvar \
    -command {
       set ::pause 1
       sc_var exit; updateBoard -animate
    }
button .button.addVar -image tb_addvar \
    -command {sc_var create; updateBoard -pgn -animate}
frame .button.space2 -width 15

image create photo tb_flip -data {
R0lGODlhHgAeAOfaAAAAAAEAAAIAAAMBAAMCAIMAAIUAAIYAAIcAAIgAAIkA
AIoAAIsAAIkDAIsDAI0CAooEAYsEA40EA4oHA4sIA4sIBYsJBI0IBYwJBIsK
BowKB44JB40KBowLBo0LBo4MCY0NCY8MCY4OCpAOCpAODZEODZAPDpAQDpIP
DpIQDZERDpESEJISEJMSEI0WDJITD5MVEpQVEo8bEJQZFJIdFpMdFpQeF5Qf
GJkpIpopIpAwGpIwHJE9I2FhYmJiYmZnZ2ZnaGdnaGdoaWdoamhoaWdpamhp
aqlQRGlqaqpSRoJoQqtWSqtXSa1ZTJxlQK1bTZhuQY9yRZluQZpwQ5F0SJF1
SZtxRpxxRptyRZxzR5x0Rpx0SJ5zSJR4S5l3Rp11SZ12SZ52SZp5R5t5SKF3
TahzUpd8UZx7Spx8S6J5T51+TJ5+Tp9+TqB+TKF9UKN8UaGATaCAUJ+BUKOB
UKCDUqSDUqOEVKCGU6SFUqWGU6SGVqiGVLN/Y6WKWaSLWqmKWbSCZqaMW6mM
W6qOXLWIaraJa6iSbbORbbORbrWRbbWYcraYcqmcgrigeKOjo7ihebiiesOc
grmjesScgrmke7mle72ke7qmfL2lfLqnfbqofbqofruofrupgLqqf7qpisek
isSniMimjMWpisapisapi76vhb6vkb6wk8mtkMCzlsGzlMqvksuvksyylsu0
lsy0ls20ls20l820mM60mM+2ms64nMy6mcy8mc27nM+7nM2+nM2+nc3AndG+
nc7AntDAoNHAntHCotLDodLDo9LEo9HFo9TFptbFpNPHptXGqNfHptXIqdfI
p9bIq9XJqtbJqtnKqtfLrdvKqNbMq9nLqtbNrNXOrNrMrNjRsNnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2SH5BAEKAP8ALAAAAAAeAB4AAAj+AAEQGBBgAICD
BwMIKIgw4UKDDQH4IMBo1SlVhqJUoWLmE6qLGTd2/IhRYxclAJAMWDUNWTRL
cPLgGTSsWjNsltrUmfPH1zKXOevs6QLASIBTyIAde4SGS5Y3o1qlYgbpTJw1
em4JU9rIap0qAIoMUBXtmLROWmRc0KCiBA5bmsScGWMnl7Jjzhp5OdMmCgAh
AAxZetSpzA4GCRIneHAEUKVGkCNLtmToL4AocNBo2ZEgxQoVGjJQKPAk2zFl
ueyMOeOlkbNj0VQNCAKgSh4uMhikmASL1BswTg40uQZM2C09a+KcaXQMGLJT
AX4AoIInS4UEK15R+xXoDhsefKz+FUvGq48cOmooPSO2DJUAIADMDHqjIYGK
UMZ2pbECxk+mXqy0MsobW3yBRSKu4BLMJwEEEcAnw5CiggIguGGKLDU4YEMp
l5BBAwqgceABBiHckIYgZvwlACrVsEJCAhHoQIguJyBgAi2bQDFBAgos4KMC
CUBwBR5UADDEUc2kkoMECRywBCgvJHDCLJtM0cECDDDgYwwiuMBFHmCJpQo2
zNiShAEIbDDDAgqwUAsnUFiApZYziKKIFGjA4RdghmAiiSeFMLFBjz6KgAgn
iIjgI5sbMFGIJ5JgUhlgmKEhxSKirJnlAhZAwUktLPQ4wwYIGJCELcxgIxtt
tnHhwgj+MPi4aQdTbDLLCQm8AMoSByQgQQ6pNAOddNRdAQGPiyqgwARQbEKL
CQicoAshOkSQAAmsVOMefGYIksYNH1jQQQZsmVADGZeUYkMDNchiihsgKKAC
KcMw6OAnweDiyiFYfLHFG6SwwkovmfgBhhVp7GJMKCokoMEbg6QoxIrLEAMN
JWrQIUcfvCRTjDV88MDGHYH8Qs0rKyRQQRZEGnlUUsd0dVVWW13TxAFOhAFV
LJGkwIAMX4Y5Vll57UWXXcdk80QBFHDAVgspJLCDFnnuGZglkmXdSCWAHPGA
YgkwsEMZnTxCmWVRtMGaa6eltpoYmtiSAwmgVSCDFp1IA9uGqrXVoRxzxR2X
3BmQMJMKK75lwQUajzT3XHQAdLFHHW1YEg0yy/jyxxyUW4JNM9UMMwgeecBh
OTLTrDIbAEp0UUUUhqhyCiqfmEHF67HPXvvtsMu+CiMEEBERAAQtFFHxARxf
EAEA9OADEkYUIYQQQfwARBBCDCE99dZjr/301QdBRA+OBAQAOw==
}

image create photo tb_gameinfo -data {
R0lGODlhHgAeAOMJAAAAAHBeQmRkZKCAUKyQZaSkpM69nNDAoO7k5PDf3/Df
3/Df3/Df3/Df3/Df3/Df3yH5BAEKAA8ALAAAAAAeAB4AAASwUMhJq7XgPTGO
P8Ygih84kp+Qbd0XnuU7lqrGETh+Drl+9rWNDOUZtoqnoMAY2zVHSqbLOYWu
llQkrCpSEk6BgrjwHYXH5e71aNpqZ6n1E/4mHpRsaZ2Nn9v1d1cBBoQGBWCF
hoiFUVltdI8DjW6ReUlXgJmXNpqUQ0oXoaISVwCmp6ipqqoara6vsLGys7S1
tretCLq7vL2+vrm/wsO6wcTHvMbIyMrLxM3OwrjTrREAOw==}

image create photo tb_coords -data {
R0lGODlhHgAeAOeNAAAAAAEAAAIAAAEBAQICAgMDAwIDBgMDBQIEBwQEBAUF
BQQGCQYGBgUHCwYIDAgICAYJDAkJCQoKCgoMDg4ODhMTExkZGR8fHyIiIicn
JyoqKisrKy4uLjExMTIyMjY2NkQ0Hjg4OEg4H0o6I0w8JEZGRkdHR1ZKNk1N
TU5OTk9PT1pSQFNTU1VVVVZWVmJbSmRdTl5eXl5fX2BgYGZmZmdnZ2dnaGdo
aGdoaWdoamhoaGdpamhpaWhpamlpaWlpamlqamxsbG1ta29vb3BwcHFxcXNz
c3R0dHZ2dnd3d5dzPJF0SJF1SZh0QJp3RHx8fJt5RZt5SJd8UZx7Spp8ToKC
gp5+TqCAUKGATqOBUKSDUqOEVKSGVoqKiqqGUamKWa2KV7CNWLWbcKCgobig
eKOjo6ampreoibmoj7qpiqurq7qpkaysrLyslMetgr6vkb6wk7a2tsq2k8y6
mby8vM27nMi8qL6+vs++m9G+ndDAncHBwdDAoNHCotPCodTCn8TExMXFxcvF
tdTFptbFpNXGqNfHpt3LptTMvNbOv9fOvuHQreTUstnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2SH5BAEKAP8ALAAAAAAeAB4AAAj+AP8JHEiwoMGD
BmNYuPNvD4AVh/BInIhHjxwsTqBohKIEDcENRAgaeLGIj8mTfPrM4WLlissr
UNoILMMCAIciM8z8G1kSpUmVLF/ClPlvCAAJERIAMLKTpM+fK1u+jDlwT1WB
CGAwGsS166BCdbZEmUJ2SpM1CAUuOOGGjNu3cOOKsUOQIcEGIryU3RtlS51C
Xv0kIojhCEEHI8AIfWmFy5w+KPEgmtkCAI3DiRe7bPw48uR/RQYA8IFZsWbO
kE9KHqgmgY7Smq+g9kywQA3Ypx2nNrl64IDLAxGbXjxb9WeBEobgJq6b9r8y
lTc8GQiBRBgt2LNryfIljyFC4Amj/VEk0KgEBhfsTgBBhYn790yWSEkD5439
N2cEXQ0ESOCeAwAEAMCABBIYgAABJCigEGn9g4QNPewg4YQ75ICDDTbwAMQP
N8gwRoMghijiiCSCCEASJYZ4YolsXMBABwgBgAIHFdBRIgBVHGTTPyF4IGIc
GjywokErFqGAiBaU8M+QBa0YBAUiUuDCkkHoWMQ/GaQgYhcPqGDCAzoCQMAH
KY4YEAA7
}

image create photo tb_showmenu -data {
R0lGODlhHgAeAIQZAAAAABAQEBcXFyIiIiMjIzAwMElJSVxVR2hTNHBeQmRk
ZHZ2dnh4eIZ7Zoh9aI6DbaCAUIqKiqyQZaSkpKamps69nNDAoNTU1Pv7+///
/////////////////////////yH5BAEKAB8ALAAAAAAeAB4AAAX+4CWOZGme
JsNMFoVeFBPB72Ux4rRc0VwylApjcetdJiSLATicKBJIUkOxoFQjisfEJ7L4
hhTjb7RoUBRKF0lNcVGiyRHFMnEpShMVF6WSrdU1gS8fhIWGh4iJiouMhwCP
kJGSk5SECpeYmZqbmwCWFRChoRakFqCiEKWmqAqeHwqnoqqxo6W0rZ+oqba6
s6yusL28qL6iuK8JFcoVE6jJy82iz8rHCruktNerxKXV2tnFst3A38LY5hbe
4bXn3KTVEs4T8xPx0vT1v7nu2+LtodXADfPXD0JAdAL/GQSWsGA5Y+QkSJSo
ayJFVBbVDWTnUJVGhQ8JVuNEsuQlVyEBAAA7}

image create photo tb_trial -data {
R0lGODlhHgAeAMZuAAAAAAQAAAMEBgMFCQcHBwYIDAoKCgsLCwwMDA4QExIS
EhYUDxsbGycfEh8hI38AAIEAAIIAAIMAAIQAAIUAAIcAAIoAAIsAAI0EBI4H
B40ICDEyMo8KCpEQEJISEks6IJQYGE8+JFA/J1VDKFtMNpsuLpwuLp0wMFtb
W11dXV5eXmNkZGRkZGVlZ2VmZ2ZmZmdpamlpaWxsbG1ucHBxcqtYWKtaWnR0
da5fX3d3d3h4eK5jY69jY69kZJl2QLFoaLFpaZ17SZt8S558SoGBgbJsbJ59
S6B+T5+AULRxcZ2CWbRzc6KDVaOEVqWFU7V3d6OGWqSGWrV4eKSIXKWIXKaI
XqaJXriAgKqQaqWnqampqaurq7qqkMajo8ampsempr6wm7+xnLS0tL6+wMDA
wsHBwcTExMXFxdHExNLFxdDJv+Ly8uPz8/Pz89nZ2dnZ2dnZ2dnZ2dnZ2dnZ
2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2SH5BAEKAH8A
LAAAAAAeAB4AAAf+gH+Cg4SFhoeEaGmCaWiIj4cmHR4eHSaQmH9fNRgVnhUY
NV+ZiD0QFRogIBoVED2khzwPETaCOxUURbCGXTw9o39JFBNAu5g4FBxSg2XM
xn8nFhlegzkECtgEObCbFyVXhC8A4+MvsKYSS4U6BuQGOrBFFLmGYgwADGK7
QBISxYRaUhwAcEDFFlhPMmR4UogFuXEoEJ0xQ0rGQwACEhTYyLHAAAdkBn35
8QPYIIsPG4wIwbJliA8kCMl6wKMQSnIinCDZyROJECUyH9C0eRFAgKLjFowZ
1ItHl0IxLm6gAaOqVRgubpBiRw4BkWeH7OHTB7ZQwIEHUmgpS8jhQxZPbAet
uLiiLBguYf5kaTGjb4ssf8JwAbOLiY8mag6paeKDyS4qRo5UsUKlcmUrVY4Y
obIrShAjQ4KIHh1kiJEgUXZhgTKltevXU6BgiWssEAA7}

image create photo tb_trial_on -data {
R0lGODlhHgAeAMZsAAAAAAQAAAMEBgMFCQcHBwYIDAoKCgsLCwwMDA4QExIS
EhYUDxsbGycfEh8hI38AAIEAAIIAAIMAAIQAAIUAAIcAAIoAAIsAAI0EBI4H
B40ICDEyMo8KCpEQEJISEks6IJQYGE8+JFA/J1VDKFtMNpsuLpwuLp0wMFtb
W11dXV5eXmNkZGRkZGVlZ2VmZ2ZmZmdpamlpaWxsbG1ucHBxcqtYWKtaWnR0
da5fX3d3d3h4eK5jY69jY69kZJl2QLFoaLFpaZ17SZt8S558SoGBgbJsbJ59
S6B+T5+AULRxcZ2CWbRzc6KDVaOEVqWFU7V3d6OGWqSGWrV4eKSIXKWIXKaI
XqaJXriAgKqQaqWnqampqaurq7qqkMajo8ampsempr6wm7+xnLS0tL6+wMDA
wsHBwcTExMXFxdHExNLFxdDJv9vTzf//////////////////////////////
/////////////////////////////////////////////////yH5BAEKAH8A
LAAAAAAeAB4AAAf+gF+Cg4SFhoeIiYqHJh0eHh0mi5M1GBWXFRg1k4k9EBUa
ICAaFRA9nIc8DxE2gjsVFEWohl08p4JJFBNAs4s4FBxSg2XDvV8nFhlegzkE
Cs8EObM1FyVXhC8A2tovqJ4SS4U6BtsGOqhFFLGGYgwADGKzQBISvIRaKQcA
BypbqE8ZMjwpxGKbNhSIzpjhJMMgAAEJCkicWGCAAzKEfvww1NBggxEhQooM
8YHEn0GqHvAo1HGbCCdIYspEIkTJSUEpVxJquS2Aw20LxgyqxaNLoRgON9CA
wbQpDBc3OI3bhoCIsUPt3sW7WgifvgMptHAlVNAgi7GDVjhcwRUMlzBDX7K0
mEG3RZYvYbiAmcXER5NETXwwmUXFyJEqVqgoVmylyhEjVGZFCWJkSJDLmIMM
MRIkyiwsUKaIHk16ChQsaHsFAgA7}



##############################

namespace eval ::board {

  namespace export sq san recolor colorSquare isFlipped

  # List of square names in order; used by sq procedure.
  variable squareIndex [list a1 b1 c1 d1 e1 f1 g1 h1 a2 b2 c2 d2 e2 f2 g2 h2 \
      a3 b3 c3 d3 e3 f3 g3 h3 a4 b4 c4 d4 e4 f4 g4 h4 \
      a5 b5 c5 d5 e5 f5 g5 h5 a6 b6 c6 d6 e6 f6 g6 h6 \
      a7 b7 c7 d7 e7 f7 g7 h7 a8 b8 c8 d8 e8 f8 g8 h8]
}

# ::board::sq:
#    Given a square name, returns its index as used in board
#    representations, or -1 if the square name is invalid.
#    Examples: [sq h8] == 63; [sq a1] = 0; [sq notASquare] = -1.
#
proc ::board::sq {sqname} {
  variable squareIndex
  return [lsearch -exact $squareIndex $sqname]
}

# ::board::san --
#
#	Convert a square number (0-63) used in board representations
#	to the SAN square name (a1, a2, ..., h8).
#
# Arguments:
#	sqno	square number 0-63.
# Results:
#	Returns square name "a1"-"h8".
#
proc ::board::san {sqno} {
  if {($sqno < 0) || ($sqno > 63)} { return }
  return [format %c%c \
      [expr {($sqno % 8) + [scan a %c]}] \
      [expr {($sqno / 8) + [scan 1 %c]}]]

}

# ::board::new
#   Creates a new board in the specified frame.
#   The psize option should be a piece bitmap size supported
#   in Scid (see the boardSizes variable in start.tcl).
#   The showmat parameter adds a frame to display material balance
#
proc ::board::new {w {psize 40} {showmat "nomat"} } {
  if {[winfo exists $w]} { return }

  set ::board::_size($w) $psize
  set ::board::_border($w) $::borderwidth
  set ::board::_coords($w) 0
  set ::board::_flip($w) 0
  set ::board::_data($w) [sc_pos board]
  set ::board::_stm($w) 1
  set ::board::_showMarks($w) 0
  set ::board::_mark($w) {}
  set ::board::_drag($w) -1
  set ::board::_showmat($w) [expr {"$showmat" != "nomat"}]

  set border $::board::_border($w)
  set bsize [expr {$psize * 8 + $border * 9} ]

  ### Main board initialised S.A
  # moved the side to move column from the right to the left

  frame $w -class Board
  canvas $w.bd -width $bsize -height $bsize -background black -borderwidth 0 -highlightthickness 0
  if {[info tclversion] == 8.5} {
    grid anchor $w center
  }

  grid $w.bd -row 1 -column 3 -rowspan 8 -columnspan 8
  set bd $w.bd

  # Create empty board:
  for {set i 0} {$i < 64} {incr i} {
    set xi [expr {$i % 8} ]
    set yi [expr {int($i/8)} ]
    set x1 [expr {$xi * ($psize + $border) + $border +1 } ]
    set y1 [expr {(7 - $yi) * ($psize + $border) + $border +1 } ]
    set x2 [expr {$x1 + $psize }]
    set y2 [expr {$y1 + $psize }]

    $bd create rectangle $x1 $y1 $x2 $y2 -tag sq$i -outline ""
    ::board::colorSquare $w $i
  }

  # Set up coordinate labels:
  for {set i 1} {$i <= 8} {incr i} {
    label $w.lrank$i -text [expr {9 - $i}]
    grid $w.lrank$i -row $i -column 2 -sticky e
    label $w.rrank$i -text [expr {9 - $i}]
    grid $w.rrank$i -row $i -column 11 -sticky w
  }
  foreach i {1 2 3 4 5 6 7 8} file {a b c d e f g h} {
    label $w.tfile$file -text $file
    grid $w.tfile$file -row 0 -column [expr $i + 2] -sticky s
    label $w.bfile$file -text $file
    grid $w.bfile$file -row 9 -column [expr $i + 2] -sticky n
  }

  # Set up side-to-move icons:
  frame $w.stmgap -width 3
  frame $w.stm
  # frame $w.mat
  frame $w.wtm -background white -relief solid -borderwidth 1
  frame $w.btm -background black -relief solid -borderwidth 1
  grid $w.stmgap -row 1 -column 1
  grid $w.stm -row 2 -column 0 -rowspan 5 -padx 2

  # Material canvas init
  set ::materialwidth [boardSize_plus_n -7]
  if {$::board::_showmat($w)} {
    canvas $w.mat -width $::materialwidth -height [expr $::board::_size($w) * 8] -insertborderwidth 0 -borderwidth 0 -highlightthickness 0
  }

  if {"$w" == ".board"} {
    set ::board::_showmat($w) $::gameInfo(showMaterial)
  }

  grid $w.wtm -row 8 -column 0
  grid $w.btm -row 1 -column 0
  if {$::board::_showmat($w)} {
    grid $w.mat -row 1 -column 12 -rowspan 8
  }

  ::board::togglestm $w
  ::board::coords $w
  ::board::resize $w redraw
  return $w
}

# ::board::defaultColor
#   Returns the color (the value of the global
#   variable "lite" or "dark") depending on whether the
#   specified square number (0=a1, 1=b1, ..., 63=h8) is
#   a light or dark square.
#
proc ::board::defaultColor {sq} {
  return [expr {($sq + ($sq / 8)) % 2 ? "$::lite" : "$::dark"}]
}

# ::board::size
#   Returns the current board size.
#
proc ::board::size {w} {
  return $::board::_size($w)
}

# doesn't change boardSize

proc boardSize_plus_n {n {w .board}} {

  global boardSizes

  set index [lsearch -exact $boardSizes $::board::_size($w)]
    incr index $n
    if {$index < 0} {
      set index 0
    }
    if {$index >= [llength $boardSizes]} {
      set index [llength $boardSizes]
      incr index -1
    }
    return [lindex $boardSizes $index]
}

proc ::board::resize {w psize} {
  if { ! [ ::board::isFlipped $w ] } {
    ::board::resize2 $w $psize
  }  else {
    ::board::flip $w
    ::board::resize2 $w $psize
    ::board::flip $w
  }
}

#   Resizes the board. Takes a numeric piece size (which should
#   be in the global boardSizes list variable), or "-1" or "+1".
#   If the size argument is "redraw", the board is redrawn.
#
#   No longer returns the new size of the board, but sets
#   ::boardSize explicitly, which is much safer.

proc ::board::resize2 {w psize} {
  global boardSize boardSizes

  ### When changing the border width, widget flickers but can't fix it - S.A.
  # $w.bd configure -state disabled

  set oldsize $::board::_size($w)
  if {$psize == $oldsize} { return }
  if {$psize == "redraw"} {
    set psize $oldsize
  } elseif {$psize == -1 || $psize == +1} {
    set psize [boardSize_plus_n $psize $w]
  }

  # Verify that we have a valid size:
  if {[lsearch -exact $boardSizes $psize] < 0} {
    puts "Scid: invalid psize"
    return
  }

  set border $::board::_border($w)
  set bsize [expr {$psize * 8 + $border * 9} ]

  $w.bd configure -width $bsize -height $bsize
  set ::board::_size($w) $psize

  # Resize each square:
  for {set i 0} {$i < 64} {incr i} {
    set xi [expr {$i % 8}]
    set yi [expr {int($i/8)}]
    set x1 [expr {$xi * ($psize + $border) + $border }]
    set y1 [expr {(7 - $yi) * ($psize + $border) + $border }]
    set x2 [expr {$x1 + $psize }]
    set y2 [expr {$y1 + $psize }]
    $w.bd coords sq$i $x1 $y1 $x2 $y2
  }

  # Resize the side-to-move icons:
  set stmsize [expr {round($psize / 4) + 5}]
  $w.stm configure -width $stmsize
  $w.wtm configure -height $stmsize -width $stmsize
  $w.btm configure -height $stmsize -width $stmsize

  if {$w == ".board"} {set boardSize $psize}

  # resize the material canvas &
  if {$::board::_showmat($w)} {
    set ::materialwidth [boardSize_plus_n -7]
    $w.mat configure -height [expr $::board::_size($w) * 8]
    $w.mat configure -width $::materialwidth
    ::board::material $w
  }

  ::board::update $w {} 0 1

  # ::update
  # $w.bd configure -state normal
}

# ::board::getSquare
#   Given a board frame and root-window X and Y screen coordinates,
#   returns the square number (0-63) containing that screen location,
#   or -1 if the location is outside the board.
#
proc ::board::getSquare {w x y} {
  if {[winfo containing $x $y] != "$w.bd"} {
    return -1
  }
  set x [expr {$x - [winfo rootx $w.bd]}]
  set y [expr {$y - [winfo rooty $w.bd]}]
  set psize $::board::_size($w)
  set border $::board::_border($w)
  set x [expr {int($x / ($psize+$border))}]
  set y [expr {int($y / ($psize+$border))}]

  if {$x < 0  ||  $y < 0  ||  $x > 7  ||  $y > 7} {
    set sq -1
  } else {
    set sq [expr {(7-$y)*8 + $x}]
    if {$::board::_flip($w)} { set sq [expr {63 - $sq}] }
  }
  return $sq
}

# ::board::showMarks
#   Turns on/off the showing of marks (colored squares).
#
proc ::board::showMarks {w value} {
  set ::board::_showMarks($w) $value
}

# ::board::recolor
#   Recolor every square on the board.
#
#not needed anymore (?)
proc ::board::recolor {w} {
  # for {set i 0} {$i < 64} {incr i} {
  # ::board::colorSquare $w $i
  # }
}

# ::board::colorSquare
#   Colors the specified square (0-63) of the board.
#   If the color is the empty string, the appropriate
#   color for the square (light or dark) is used.
#
proc ::board::colorSquare {w i {color ""}} {
  if {$i < 0  ||  $i > 63} { return }
  if {$color != ""} {
    $w.bd delete br$i
    $w.bd itemconfigure sq$i -fill $color -outline "" ;# -outline $color
    return
  }
  set color [::board::defaultColor $i]
  $w.bd itemconfigure sq$i -fill $color -outline "" ; #-outline $color
  #this inserts a textures on a square and restore piece
  set midpoint [::board::midSquare $w $i]
  set xc [lindex $midpoint 0]
  set yc [lindex $midpoint 1]
  set psize $::board::_size($w)
  set boc bgd$psize
  if { ($i + ($i / 8)) % 2 } { set boc bgl$psize }
  $w.bd delete br$i
  $w.bd create image $xc $yc -image $boc -tag br$i
  set piece [string index $::board::_data($w) $i]
  if { $piece != "." } {
    set flip $::board::_flip($w)
    $w.bd delete p$i
    $w.bd create image $xc $yc -image $::board::letterToPiece($piece)$psize -tag p$i
  }

  #if {$::board::_showMarks($w) && [info exists ::board::_mark($w)]} {}
  if {[info exists ::board::_mark($w)]} {
    set color ""
    foreach mark $::board::_mark($w) {
      set type   [lindex $mark 0]
      set square [lindex $mark 1]
      if {$square == $i} {
        if {$type == "full"} { set color [lindex $mark 3] }
        if {$type == "DEL"}  { set color "" }
      }
    }
    if {![string equal $color ""]} {
      catch {$w.bd itemconfigure sq$i -outline "" -fill $color } ; # -outline $color
    }
  }
}

# ::board::midSquare
#   Given a board and square number, returns the canvas X/Y
#   coordinates of the midpoint of that square.
#
proc ::board::midSquare {w sq} {
  set c [$w.bd coords sq$sq]
  #Klimmek: calculation change, because some sizes are odd and then some squares are shifted by 1 pixel
  # set x [expr {([lindex $c 0] + [lindex $c 2]) / 2} ]
  # set y [expr {([lindex $c 1] + [lindex $c 3]) / 2} ]
  set psize $::board::_size($w)
  if { $psize % 2 } { incr psize -1 }
  set x [expr {[lindex $c 0] + $psize/2} ]
  set y [expr {[lindex $c 1] + $psize/2} ]
  return [list $x $y]
}

### Namespace ::board::mark

namespace eval ::board::mark {

  namespace export getEmbeddedCmds
  namespace export add drawAll clear remove

  namespace import [namespace parent]::sq
  #namespace import [namespace parent]::isFlipped

  # Regular expression constants for
  # matching Scid's embedded commands in PGN files.

  variable StartTag {\[%}
  variable ScidKey  {mark|arrow}
  variable Command  {draw}
  variable Type     {full|square|arrow|circle|disk|tux}
  variable Text     {[-+=?!A-Za-z0-9]}
  variable Square   {[a-h][1-8]\M}
  variable Color    {[\w#][^]]*\M}	;# FIXME: too lax for #nnnnnn!
  variable EndTag   {\]}

  # Current (non-standard) version:
  variable ScidCmdRegex \
      "$StartTag              # leading tag
  ($ScidKey)\\\ +        # (old) command name + space chars
  ($Square)              # mandatory square (e.g. 'a4')
  (?:\\ +($Square))?     # optional: another (destination) square
  (?:\\ *($Color))?      # optional: color name
  $EndTag                # closing tag
  "
  # Proposed new version, according to the
  # PGN Specification and Implementation Guide (Supplement):
  variable StdCmdRegex \
      "${StartTag}            # leading tag
  ${Command}             # command name
  \\                     # a space character
  (?:(${Type}|$Text),)?  # keyword, e.g. 'arrow' (may be omitted)
  # or single char (indicating type 'text')
  ($Square)              # mandatory square (e.g. 'a4')
  (?:,($Square))?        # optional: (destination) square
  (?:,($Color))?         # optional: color name
  $EndTag                # closing tag
  "
}

# ::board::mark::getEmbeddedCmds --
#
#	Scans a game comment string and extracts embedded commands
#	used by Scid to mark squares or draw arrows.
#
# Arguments:
#	comment     The game comment string, containing
#	            embedded commands, e.g.:
#	            	[%mark e4 green],
#	            	[%arrow c4 f7],
#	            	[%draw e4],
#	            	[%draw circle,f7,blue].
# Results:
#	Returns a list of embedded Scid commands,
#		{command indices ?command indices...?},
#	where 'command' is a list representing the embedded command:
#		'{type square ?arg? color}',
#		e.g. '{circle f7 red}' or '{arrow c4 f7 green}',
#	and 'indices' is a list containing start and end position
#	of the command string within the comment.
#
proc ::board::mark::getEmbeddedCmds {comment} {
  if {$comment == ""} {return}
  variable ScidCmdRegex
  variable StdCmdRegex
  set result {}

  # Build regex and search script for embedded commands:
  set regex  ""
  foreach r [list $ScidCmdRegex $StdCmdRegex] {
    if {[string equal $regex ""]} {set regex $r} else {append regex "|$r"}
  }
  set locateScript  {regexp -expanded -indices -start $start \
        $regex $comment indices}

  # Loop over all embedded commands contained in comment string:

  for {set start 0} {[eval $locateScript]} {incr start} {
    foreach {first last} $indices {}	;# just a multi-assign
    foreach re [list $ScidCmdRegex $StdCmdRegex] {
      # Assing matching subexpressions to variables:
      if {![regexp -expanded $re [string range $comment $first $last] \
            match type arg1 arg2 color]} {
        continue
      }
      # Settings of (default) type and arguments:
      if {[string equal $color ""]} { set color "red" }
      switch -glob -- $type {
        ""   {set type [expr {[string length $arg2] ? "arrow" : "full"}]}
        mark {set type "full"	;# new syntax}
        ?    {if {[string length $arg2]} break else {
            set arg2 $type; set type "text"}
        }
      }
      # Construct result list:
      lappend result [list $type $arg1 $arg2 $color]
      lappend result $indices
      set start $last	;# +1 by for-loop
    }
  }
  return $result
}

# ::board::mark::drawAll --
#
#	Draws all kind of marks for the board.
#
# Arguments:
#	win	A frame containing a board '$win.bd'.
# Results:
#	Reads the current marked square information of the
#	board and adds (i.e. draws) them to the board.
#
proc ::board::mark::drawAll {win} {
  if {![info exists ::board::_mark($win)]} {return}
  foreach mark $::board::_mark($win) {
    # 'mark' is a list: {type arg1 ?arg2? color}
    eval add $win $mark "false"
  }
}

# ::board::mark::remove --
#
#	Removes a specified mark.
#
# Arguments:
#	win	A frame containing a board '$win.bd'.
#	args	List of one or two squares.
# Results:
#	Appends a dummy mark to the bord's list of marks
#	which causes the add routine to delete all marks for
#	the specified square(s).
#
proc ::board::mark::remove {win args} {
  if {[llength $args] == 2} {
    eval add $win arrow $args nocolor 1
  } else {
    add $win DEL [lindex $args 0] "" nocolor 1
  }
}

# ::board::mark::clear --
#
#	Clears all marked square information for the board:
#	colored squares, arrows, circles, etc.
#
# Arguments:
#	win	A frame containing a board '$win.bd'.
# Results:
#	Removes all marked squares information, recolors
#	squares (set to default square colors), but does not
#	delete the canvas objects drawn on the board.
#	Returns nothing.
#
proc ::board::mark::clear {win} {
  # Clear all marked square information:
  set ::board::_mark($win) {}
  for {set square 0} {$square < 64} {incr square} {
    ::board::colorSquare $win $square
  }
}

# ::board::mark::add --
#
#	Draws arrow or mark on the specified square(s).
#
# Arguments:
#	win		A frame containing a board 'win.bd'.
#	args		What kind of mark:
#	  type  	  Either type id (e.g., square, circle) or
#			    a single character, which is of type 'text'.
#	  square	  Square number 0-63 (0=a1, 1=a2, ...).
#	  ?arg2?	  Optional: additional type-specific parameter.
#	  color 	  Color to use for marking the square (mandatory).
#	  ?new? 	  Optional: whether or not this mark should be
#			    added to the list of marks; defaults to 'true'.
# Results:
#	For a given square, mark type, color, and optional (type-specific)
#	destination arguments, creates the proper canvas object.
#
proc ::board::mark::add {win args} {
  # Rearrange list if "type" is simple character:
  if {[string length [lindex $args 0]] == 1} {
    # ... e.g.,  {c e4 red} --> {text e4 c red}
    set args [linsert $args 1 "text"]
    set args [linsert [lrange $args 1 end] 2 [lindex $args 0]]
  }
  # Add default arguments:
  if {![regexp true|false|1|0 [lindex $args end]]} {
    lappend args "true"
  }
  if {[llength $args] == 4} { set args [linsert $args 2 ""]}

  # Here we (should) have: args == <type> <square> ?<arg>? <color> <new>
  foreach {type square dest color new} $args {break}	;# assign
  if {[llength $args] != 5 } { return }

  set board $win.bd
  set type  [lindex $args 0]

  # Remove existing marks:
  if {$type == "arrow"} {
    $board delete "mark${square}:${dest}" "mark${dest}:${square}"
    if {[string equal $color "nocolor"]} { set type DEL }
  } else {
    $board delete "mark${square}"
    #not needed anymore
    #    ::board::colorSquare $win $square [::board::defaultColor $square]
  }

  switch -- $type {
    full    { ::board::colorSquare $win $square $color }
    DEL     { set new 1 }
    default {
      # Find a subroutine to draw the canvas object:
      set drawingScript "Draw[string totitle $type]"
      if {![llength [info procs $drawingScript]]} { return }
      
      # ... and try it:
      if {[catch {eval $drawingScript $board $square $dest $color}]} {
        return
      }
    }
  }
  if {$new} { lappend ::board::_mark($win) [lrange $args 0 end-1] }
}

# ::board::mark::DrawXxxxx --
#
#	Draws specified canvas object,
#	where "Xxxxx" is some required type, e.g. "Circle".
#
# Arguments:
#	pathName	Name of the canvas widget.
#	args		Type-specific arguments, e.g.
#				<square> <color>,
#				<square> <square> <color>,
#				<square> <char> <color>.
# Results:
#	Constructs and evaluates the proper canvas command
#	    "pathName create type coordinates options"
#	for the specified object.
#

# ::board::mark::DrawCircle --
#
proc ::board::mark::DrawCircle {pathName square color} {
  # Some "constants":
  set size 0.6	;# inner (enclosing) box size, 0.0 <  $size < 1.0
  set width 0.1	;# outline around circle, 0.0 < $width < 1.0

  set box [GetBox $pathName $square $size]
  lappend pathName create oval [lrange $box 0 3] \
      -tag [list mark circle mark$square p$square]
  if {$width > 0.5} {
    ;# too thick, draw a disk instead
    lappend pathName -fill $color
  } else {
    set width [expr {[lindex $box 4] * $width}]
    if {$width <= 0.0} {set width 1.0}
    lappend pathName -fill "" -outline $color -width $width
  }
  eval $pathName
}

# ::board::mark::DrawDisk --
#
proc ::board::mark::DrawDisk {pathName square color} {
  # Size of the inner (enclosing) box within the square:
  set size 0.6	;# 0.0 <  $size < 1.0 = size of rectangle

  set box [GetBox $pathName $square $size]
  eval $pathName \
      {create oval [lrange $box 0 3]} \
      -fill $color -outline $color \
      {-tag [list mark disk mark$square p$square]}
}

# ::board::mark::DrawText --
# Pascal Georges : if shadow!="", try to make the text visible even if fg and bg colors are close
proc ::board::mark::DrawText {pathName square char color {size 0} {shadowColor ""}} {
  set box [GetBox $pathName $square 0.8]
  set len [expr {($size > 0) ? $size : int([lindex $box 4])}]
  # Using a different font to helvetica alligns text better S.A.
  # {courier 10 pitch} also looks good, but sounds too exotic (?).
  set font "{courier 10 pitch} $len"
  set x   [lindex $box 5]
  set y   [lindex $box 6]
  $pathName delete text$square mark$square
  if {$shadowColor!=""} {
    eval $pathName \
        create text [expr $x+1] [expr $y+1] -fill $shadowColor \
        {-font $font} \
        {-text [string index $char 0]}     \
        {-anchor c} \
        {-tag  [list mark text text$square mark$square p$square]}

  }
  eval $pathName \
      create text $x $y -fill $color     \
      {-font $font} \
      {-text [string index $char 0]}     \
      {-anchor c} \
      {-tag  [list mark text text$square mark$square p$square]}
}

# ::board::mark::DrawArrow --
#
proc ::board::mark::DrawArrow {pathName from to color} {
  if {$from < 0  ||  $from > 63} { return }
  if {$to   < 0  ||  $to   > 63} { return }
  set coord [GetArrowCoords $pathName $from $to]
  eval $pathName \
      {create line $coord} \
      -fill $color -arrow last -width 2 \
      {-tag [list mark arrows "mark${from}:${to}"]}
}

# ::board::mark::DrawRectangle --
# Draws a rectangle surrounding the square
proc ::board::mark::DrawRectangle { pathName square color pattern } {
  if {$square < 0  ||  $square > 63} { puts "error square = $square" ; return }
  set box [::board::mark::GetBox $pathName $square]
  $pathName create rectangle [lindex $box 0] [lindex $box 1] [lindex $box 2] [lindex $box 3] \
      -outline $color -width $::highlightLastMoveWidth -dash $pattern -tag highlightLastMove
}
# ::board::mark::DrawTux --
#
image create photo tux16x16 -data \
    {R0lGODlhEAAQAPUyAAAAABQVFiIcBi0tLTc0Kj4+PkQ3CU9ADVVFD1hJFV1X
      P2pXFWJUKHttLnttOERERVVWWWRjYWlqcYNsGJR5GrSUIK6fXsKdGMCdI8er
      ItCuNtm2KuS6KebAKufBOvjJIfnNM/3TLP/aMP/lM+/We//lQ//jfoGAgJaU
      jpiYmqKipczBmv/wk97e3v//3Ojo6f/96P7+/v///wAAAAAAAAAAAAAAAAAA
      AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEBADIALAAAAAAQABAAAAbm
      QJlMJpMBAAAAQCaTyWQymUwmAwQAAQAAIJPJZDKZTCYDQCInCQAgk8lkMplM
      JgMwOBoHACCTyYAymUwmkwEao5IFAADIZDKZTCaTAVQu2GsAAMhkMplMJgMU
      YrFY7AQAAGQymUwmA6RisVjsFQAAATKZTCYDBF6xWCwWewAAAJlMJjMoYrFY
      LBaDAAAAmUwW+oBWsVgsxlokFgCZTBYChS6oWCxmAn5CHYNMJhOJQiFS7JXS
      iEQjCkAmw3BCow0hAMiMNggAQCYDAAyTAwAASEwEAABAJpPJAAAAAACUAQAA
      gEwmCwIAOw==}
set ::board::mark::tux16x16 tux16x16

image create photo tux32x32 -data \
    {R0lGODlhIAAgAPU0AAAAABANAxERESAaBiwkCDAnCSQkJEM2DEA3GVBBDllJ
      EFNKLG5aFHBbFHpkFnZoMkBAQFBQUGBgYHBwcIBpF4xyGZ+DHZ+GKqmKHq+T
      Lb+hNsynJNSuJtu0J9+6NeW8Kc+wQPnMLPTJMP7QLv/UO//aVf/dYv/ifIiI
      hp+fn6+vr7+/v//lif/ol//rpM/Pz9/f3//22O/u6v/55f///////wAAAAAA
      AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEBADUALAAAAAAgACAAAAb+
      wFqtVqvVarVarQYAAAAAAABQq9VqtVqtVqvVarVarVar1Wq1Wg0AAAAAAAAA
      AKjVarVarVar1YC1Wq1Wq9VqtVqtBgAAAAAAAAAAAGq1Wq1Wq9VqtVqtVqvV
      arVaDQAAAAAAAAAAAABqtVqtVqsBa7VarVar1Wq1Wq0GMMgighdtAgAAALVa
      rVar1Wq1Wq1Wq9VqtVqtBphEUpCUQQUAAAC1Wq1WA9ZqtVqtVqvVarVarVYD
      RBYejwahAgAAgFqtVqvVarVarVar1Wq1Wq1WAxRIIdFolAEAAABArQas1Wq1
      Wq1Wq9VqtVqtVqvVGqPRaDTSAAAAAKBWq9VqtVr+rVar1Wq1Wq1Wq9UMp9Fo
      xJIJAAAAAFir1Wq1Wq1Wq9VqtVqtVqvVABGaqzWj0SYAAAAAqNVqtVqtVqvV
      arVarVarAQQyGo1Go9FgAAAQAAAAarVarVar1Wq1Wq1WqwEAExqNRqPRaDSD
      AAAAAGq1Wq1Wq9VqtVqtVqsBAC8ajUaj0Wg0oAoAAAAAgFqtVqvVarVarVar
      AQACGo1Go9FoNBpNAAAAAIBarVar1Wq1Wq1WqwEAKhqNRqPRaEAajYYCAAAA
      AKBWq9VqtVqtVqvVAAIajUaj0Wg0Go22AgAAAACgVqvVarVarVarAQARGo1G
      o9GANBqNRpMBAAAAAAD+qNVqtVqtVqvVAAAUjUaj0Wg0Go1GowkAAAAAAKjV
      arVarVar1QgUFI1GowFpNBqNRqPRDAZDAAAA1Gq1Wq1Wq9VGo1HpRaPRaDQa
      jUY7iQAAwUMBANRqtVqtVhuFRqPR6LIC0mg0Go1Go5lGiYBlVAEAarVarVar
      jUaj0Wg0KqRoNBqNRqOZRqPRaPQBAGq1Wq1Wq41Go9FoBBxtADIajUaj0Uyj
      0Wg0Gn0YgFqtVqvVRqPRaDQajVw0Go1Go6VGo9FoNBqNOABArVar1Uaj0Qg4
      Go1GoxiNRntFBqPRaDQajT4KAKBWq9Vqo9FoNBqNRiOHASIAAAqj0Wg0CmGW
      AAAAoFar1WoYDlAUGo1Go1FFAAAAAInRaDT6EAAAAABQq9VqNQAAAHB0QqNO
      AQAAAACA0Gi0AQAAAECtVqvVajUgAAAAAAAAAAAAAAAAAAAAAAAAAIBarVar
      1Wq1Wq1WqwEAAAAAAKjVarUaAAAAAAC1Wq1Wq9VqwFqtVqvVarVarVar1Wq1
      Wq1Wq9VqtVqtVqvVarUgADs=
    }
set ::board::mark::tux32x32 tux32x32

proc ::board::mark::DrawTux {pathName square discard} {
  variable tux16x16
  variable tux32x32
  set box [::board::mark::GetBox $pathName $square]
  for {set len [expr {int([lindex $box 4])}]} {$len > 0} {incr len -1} {
    if {[info exists tux${len}x${len}]} break
  }
  if {!$len} return
  $pathName create image [lrange $box 5 6] \
      -image tux${len}x${len} \
      -tag [list mark "mark$square" tux]
}

# ::board::mark::GetArrowCoords --
#
#	Auxiliary function:
#	Similar to '::board::midSquare', but this function returns
#	coordinates of two (optional adjusted) squares.
#
# Arguments:
#	board	A board canvas ('win.bd' for a frame 'win').
#	from	Source square number (0-63).
#	to	Destination square number (0-63).
#	shrink	Optional shrink factor (0.0 - 1.0):
#		  0.0 = no shrink, i.e. just return midpoint coordinates,
#		  1.0 = start and end at edge (unless adjacent squares).
# Results:
#	Returns a list of coodinates {x1 y1 x2 y2} for drawing
#	an arrow "from" --> "to".
#
proc ::board::mark::GetArrowCoords {board from to {shrink 0.6}} {
  if {$shrink < 0.0} {set shrink 0.0}
  if {$shrink > 1.0} {set shrink 1.0}

  # Get left, top, right, bottom, length, midpoint_x, midpoint_y:
  set fromXY [GetBox $board $from]
  set toXY   [GetBox $board $to]
  # Get vector (dX,dY) = to(x,y) - from(x,y)
  # (yes, misusing the foreach multiple features)
  foreach {x0 y0} [lrange $fromXY 5 6] {x1 y1} [lrange $toXY 5 6] {break}
  set dX [expr {$x1 - $x0}]
  set dY [expr {$y1 - $y0}]

  # Check if we have good coordinates and shrink factor:
  if {($shrink == 0.0) || ($dX == 0.0 && $dY == 0.0)} {
    return [list $x0 $y0 $x1 $y1]
  }

  # Solve equation: "midpoint + (lamda * vector) = edge point":
  if {abs($dX) > abs($dY)} {
    set edge [expr {($dX > 0) ? [lindex $fromXY 2] : [lindex $fromXY 0]}]
    set lambda [expr {($edge - $x0) / $dX}]
  } else {
    set edge [expr {($dY > 0) ? [lindex $fromXY 3] : [lindex $fromXY 1]}]
    set lambda [expr {($edge - $y0) / $dY}]
  }

  # Check and adjust shrink factor for adjacent squares
  # (i.e. don't make arrows too short):
  set maxShrinkForAdjacent 0.667
  if {$shrink > $maxShrinkForAdjacent} {
    set dFile [expr {($to % 8) - ($from % 8)}]
    set dRank [expr {($from / 8) - ($to / 8)}]
    if {(abs($dFile) <= 1) && (abs($dRank) <= 1)} {
      set shrink $maxShrinkForAdjacent
    }
  }

  # Return shrinked line coordinates {x0', y0', x1', y1'}:
  set shrink [expr {$shrink * $lambda}]
  return [list [expr {$x0 + $shrink * $dX}] [expr {$y0 + $shrink * $dY}]\
      [expr {$x1 - $shrink * $dX}] [expr {$y1 - $shrink * $dY}]]
}

# ::board::mark::GetBox --
#
#	Auxiliary function:
#	Get coordinates of an inner box for a specified square.
#
# Arguments:
#	pathName	Name of a canvas widget containing squares.
#	square		Square number (0..63).
#	portion		Portion (length inner box) / (length square)
#			(1.0 means: box == square).
# Results:
#	Returns a list whose elements are upper left and lower right
#	corners, length, and midpoint (x,y) of the inner box.
#
proc ::board::mark::GetBox {pathName square {portion 1.0}} {
  set coord [$pathName coords sq$square]
  set len [expr {[lindex $coord 2] - [lindex $coord 0]}]
  if {$portion < 1.0} {
    set dif [expr {$len * (1.0 -$portion) * 0.5}]
    foreach i {0 1} { lappend box [expr {[lindex $coord $i] + $dif}] }
    foreach i {2 3} { lappend box [expr {[lindex $coord $i] - $dif}] }
  } else {
    set box $coord
  }
  lappend box [expr { [lindex $box 2] - [lindex $box 0]     }]
  lappend box [expr {([lindex $box 0] + [lindex $box 2]) / 2}]
  lappend box [expr {([lindex $box 1] + [lindex $box 3]) / 2}]
  return $box
}

### End of namespace ::board::mark

# ::board::piece {w sq}
#   Given a board and square number, returns the piece type
#   (e for empty, wp for White Pawn, etc) of the square.
proc ::board::piece {w sq} {
  set p [string index $::board::_data($w) $sq]
  return $::board::letterToPiece($p)
}

# ::board::setDragSquare
#   Sets the square from whose piece should be dragged.
#   To drag nothing, the square value should be -1.
#   If the previous value is a valid square (0-63), the
#   piece being dragged is returned to its home square first.
#
proc ::board::setDragSquare {w sq} {
  set oldSq $::board::_drag($w)
  if {$oldSq >= 0  &&  $oldSq <= 63} {
    ::board::drawPiece $w $oldSq [string index $::board::_data($w) $oldSq]
    $w.bd raise arrows
  }
  set ::board::_drag($w) $sq
}

# ::board::dragPiece
#   Drags the piece of the drag-square (as set above) to
#   the specified global (root-window) screen cooordinates.
#
proc ::board::dragPiece {x y} {
  set w .board
  set sq $::board::_drag($w)
  if {$sq < 0} { return }
  set x [expr {$x - [winfo rootx $w.bd]} ]
  set y [expr {$y - [winfo rooty $w.bd]} ]
  $w.bd coords p$sq $x $y
  $w.bd raise p$sq
}

# ::board::bind
#   Binds the given event on the given square number to
#   the specified action.
#
proc ::board::bind {w sq event action} {
  if {$sq == "all"} {
    for {set i 0} {$i < 64} {incr i} {
      $w.bd bind p$i $event $action
    }
  } else {
    $w.bd bind p$sq $event $action
  }
}

# ::board::drawPiece
#   Draws a piece on a specified square.
#
proc ::board::drawPiece {w sq piece} {
  set psize $::board::_size($w)
  set flip $::board::_flip($w)
  # Compute the XY coordinates for the centre of the square:
  set midpoint [::board::midSquare $w $sq]
  set xc [lindex $midpoint 0]
  set yc [lindex $midpoint 1]
  # Delete any old image for this square, and add the new one:
  $w.bd delete p$sq
  $w.bd create image $xc $yc -image $::board::letterToPiece($piece)$psize -tag p$sq
}

# ::board::clearText
#   Remove all text annotations from the board.
#
proc ::board::clearText {w} {
  $w.bd delete texts
}

# ::board::drawText
#   Draws the specified text on the specified square.
#   Additional arguments are treated as canvas text parameters.
#
proc ::board::drawText {w sq text color args {shadow ""} } {
  mark::DrawText ${w}.bd $sq $text $color \
      [expr {[catch {font actual font_Bold -size} size] ? 11 : $size}] \
      $shadow
  #if {[llength $args] > 0} {
  #  catch {eval $w.bd itemconfigure text$sq $args}
  #}
}

# Highlight last move played by drawing a coloured rectangle around the two squares
proc  ::board::lastMoveHighlight {w} {
  $w.bd delete highlightLastMove
  if { ! $::highlightLastMove } {return}
  set moveuci [ sc_game info previousMoveUCI ]
  if {[string length $moveuci] >= 4} {
    set moveuci [ string range $moveuci 0 3 ]
    set square1 [ ::board::sq [string range $moveuci 0 1 ] ]
    set square2 [ ::board::sq [string range $moveuci 2 3 ] ]
    ::board::mark::DrawRectangle $w.bd $square1 $::highlightLastMoveColor $::highlightLastMovePattern
    ::board::mark::DrawRectangle $w.bd $square2 $::highlightLastMoveColor $::highlightLastMovePattern
  }
}

# ::board::update
#   Update the board given a 64-character board string as returned
#   by the "sc_pos board" command. If the board string is empty, it
#   defaults to the previous value for this board.
#   If the optional paramater "animate" is 1 and the changes from
#   the previous board state appear to be a valid chess move, the
#   move is animated.
#   N.B. resize (and update) is also called when changing background tiles

proc ::board::update {w {board ""} {animate 0} {resize 0}} {
  global highcolor currentSq bestSq bestcolor selectedSq

  set oldboard $::board::_data($w)
  if {$board == {}} {
    set board $::board::_data($w)
  } else {
    set ::board::_data($w) $board
  }
  set psize $::board::_size($w)

  # Cancel any current animation:
  after cancel "::board::_animate $w"

  # Remove all marks (incl. arrows) from the board:
  $w.bd delete mark

  # Draw each square
  set light 0
  set sq -1
  # for {set sq 0} { $sq < 64 } { incr sq } 
  foreach piece [lrange [split $board {}] 0 63] {
    incr sq

    # Compute the XY coordinates for the centre of the square:
    foreach {xc yc} [::board::midSquare $w $sq] {}

    if {$resize} {
      #update every square with color and texture
      set color [::board::defaultColor $sq]
      $w.bd itemconfigure sq$sq -fill $color -outline {} ; # -outline $color

      if { $light } {
        set boc bgl$psize
      } else {
        set boc bgd$psize
      }
      if {($sq % 8) != 7} {
        set light [expr {! $light}]
      }

      $w.bd delete br$sq
      $w.bd create image $xc $yc -image $boc -tag br$sq
    }

    # Delete any old image for this square, and add the new one:
    $w.bd delete p$sq
    $w.bd create image $xc $yc -image $::board::letterToPiece($piece)$psize -tag p$sq
  }

  # Update side-to-move icon:
  grid remove $w.wtm $w.btm
  if {$::board::_stm($w)} {
    set side [string index $::board::_data($w) 65]
    if {$side == "w"} { grid configure $w.wtm }
    if {$side == "b"} { grid configure $w.btm }
  }

  # Redraw marks and arrows
  if {$::board::_showMarks($w)} {
    ::board::mark::drawAll $w
  }

  # Redraw last move highlight if mainboard
  if { $w == ".board"} {
    ::board::lastMoveHighlight $w
  }

  # ::board::update is called twice mostly :<
  # On second call, "animate" is 0, so don't update this widget superfluously
  # ... and it probably isn't necessary. More important is proc togglematerial
  if {$animate && $::gameInfo(showMaterial)} {
    ::board::material $w
  }

  # Animate board changes if requested:
  if {$animate  &&  $board != $oldboard} {
    ::board::animate $w $oldboard $board
  }
}

proc ::board::isFlipped {w} {
  return $::board::_flip($w)
}

# ::board::flip
#   Rotate the board 180 degrees.

proc ::board::flip {w {newstate -1}} {
  if {! [info exists ::board::_flip($w)]} { return }
  if {$newstate == $::board::_flip($w)} { return }
  set flip [expr {1 - $::board::_flip($w)} ]
  set ::board::_flip($w) $flip

  # Swap squares:
  for {set i 0} {$i < 32} {incr i} {
    set swap [expr {63 - $i}]
    set coords(South) [$w.bd coords sq$i]
    set coords(North) [$w.bd coords sq$swap]
    $w.bd coords sq$i    $coords(North)
    $w.bd coords sq$swap $coords(South)
  }

  # Change coordinate labels:
  for {set i 1} {$i <= 8} {incr i} {
    set value [expr {9 - [$w.lrank$i cget -text]} ]
    $w.lrank$i configure -text $value
    $w.rrank$i configure -text $value
  }
  if {$flip} {
    foreach file {a b c d e f g h} newvalue {h g f e d c b a} {
      $w.tfile$file configure -text $newvalue
      $w.bfile$file configure -text $newvalue
      grid configure $w.wtm -row 1
      grid configure $w.btm -row 8
    }
  } else {
    foreach file {a b c d e f g h} {
      $w.tfile$file configure -text $file
      $w.bfile$file configure -text $file
      grid configure $w.wtm -row 8
      grid configure $w.btm -row 1
    }
  }
  ::board::update $w
  if {$w == ".board"} {::board::togglematerial}
  return $w
}

proc ::board::togglematerial {} {
  # gameInfo(showMaterial) is specifically for the .board, 
  # while ::board::_showmat($w) is window specific.

  if {$::gameInfo(showMaterial)} {
    grid configure .board.mat -row 1 -column 12 -rowspan 8
    ::board::material .board
    # ::board::update .board {} 1
  } else {
    grid remove .board.mat
  }
}


################################################################################
# ::board::material
# displays material balance
################################################################################
proc ::board::material {w} {

  set f $w.mat

  if {![winfo exists $f]} {
    return
  }

  $f delete material

  if {! $::gameInfo(showMaterial)} { return }
  set fen [lindex [sc_pos fen] 0]

  # Evaluate piece differences
  # Negative values mean black is ahead
  # (Uppercase chars in fen are white)
  set p [expr {[regexp -all P $fen] - [regexp -all p $fen]}]
  set n [expr {[regexp -all N $fen] - [regexp -all n $fen]}]
  set b [expr {[regexp -all B $fen] - [regexp -all b $fen]}]
  set r [expr {[regexp -all R $fen] - [regexp -all r $fen]}]
  set q [expr {[regexp -all Q $fen] - [regexp -all q $fen]}]

  # Flesh out differences into white and black lists
  set matwhite {}
  set matblack {}
  foreach piece {q r b n p} {
    set c [expr abs($[set piece])]
    set minus [expr $[set piece] < 0]
    if {$minus} {
      while {$c > 0} {
        lappend matblack $piece
        incr c -1
      }
    } else {
      while {$c > 0} {
        lappend matwhite $piece
        incr c -1
      }
    }
  }

  ### Display material

  set width $::materialwidth
  set h [$f cget -height]
  set x [expr {$width / 2}]

  if {[ ::board::isFlipped $w ]} {
    set sign1 + ; set sign2 -
  } else {
    set sign1 - ; set sign2 +
  }

  # Material is drawn either side of half-way unless one side has too much
  set halfway [expr {$h / 2}]
  if {[expr {[llength $matblack] * $width > $halfway}]} {
    if {[ ::board::isFlipped $w ]} {
      set halfway [expr {$h - ([llength $matblack] * $width)}]
      if {$halfway < 0} {set halfway 0}
    } else {
      set halfway [expr {[llength $matblack] * $width}]
      if {$halfway > $h} {set halfway $h}
    }
  } else {

  if {[expr {[llength $matwhite] * $width > $halfway}]} {
    if {[ ::board::isFlipped $w ]} {
      set halfway [expr {[llength $matwhite] * $width}]
      if {$halfway > $h} {set halfway $h}
    } else {
      set halfway [expr {$h - ([llength $matwhite] * $width)}]
      if {$halfway < 0} {set halfway 0}
    }
  }

  }
  set offset [expr $halfway $sign1 $x ]
  foreach pi $matblack {
    $f create image $x $offset -image b${pi}$width -tag material
    set offset [expr $offset $sign1 $width]
  }

  set offset [expr $halfway $sign2 $x]
  foreach pi $matwhite {
    $f create image $x $offset -image w${pi}$width -tag material
    set offset [expr $offset $sign2 $width]
  }
}

################################################################################
#
################################################################################

# These procs are not quite sorted out properly.
# They work, but were f-ed up before. S.A.

#   Add or remove the side-to-move icon.

proc ::board::togglestm {w} {
  set ::board::_stm($w) [expr {! $::board::_stm($w)} ]
  ::board::stm $w
}

proc ::board::stm {w} {
  set stm $::board::_stm($w)
  if {$stm} {
    grid configure $w.stmgap
    grid configure $w.stm
    set side [string index $::board::_data($w) 65]
    if {$side == "w"} { grid configure $w.wtm }
    if {$side == "b"} { grid configure $w.btm }
  } else {
    grid remove $w.stmgap $w.stm $w.wtm $w.btm
  }

}

# ::board::coords
#   Add or remove coordinates around the edge of the board.
#   Klimmek: Toggle between 0,1,2.

proc ::board::coords {w} {
  set coords [expr {1 + $::board::_coords($w)} ]
  if { $coords > 2 } { set coords 0 }
  set ::board::_coords($w) $coords

  if {$coords == 0 } {
    for {set i 1} {$i <= 8} {incr i} {
      grid configure $w.lrank$i
      grid configure $w.rrank$i
    }
    foreach i {a b c d e f g h} {
      grid configure $w.tfile$i
      grid configure $w.bfile$i
    }
  } elseif {$coords == 1 } {
    for {set i 1} {$i <= 8} {incr i} {
      grid remove $w.lrank$i
      grid remove $w.rrank$i
    }
    foreach i {a b c d e f g h} {
      grid remove $w.tfile$i
      grid remove $w.bfile$i
    }
  } else { #Klimmek: coords == 2 then show left and bottom
    for {set i 1} {$i <= 8} {incr i} {
      grid configure $w.lrank$i
      grid remove $w.rrank$i
    }
    foreach i {a b c d e f g h} {
      grid remove $w.tfile$i
      grid configure $w.bfile$i
    }
  }
}

# ::board::animate
#   Check for board changes that appear to be a valid chess move,
#   and start animating the move if applicable.
#
proc ::board::animate {w oldboard newboard} {
  global animateDelay
  if {$animateDelay <= 0} { return }

  # Find which squares differ between the old and new boards:
  # Mate this looks slow... but it's only performed once per move

  set difflist {}
  for {set i 0} {$i < 64} {incr i} {
    if {[string index $oldboard $i] != [string index $newboard $i]} {
      lappend difflist $i
    }
  }
  set diffcount [llength $difflist]

  # Check the number of differences could mean a valid move:
  if {$diffcount < 2  ||  $diffcount > 4} { return }

  for {set i 0} {$i < $diffcount} {incr i} {
    set sq($i) [lindex $difflist $i]
    set old($i) [string index $oldboard $sq($i)]
    set new($i) [string index $newboard $sq($i)]
  }

  set from -1
  set to -1
  set captured -1
  set capturedPiece "."

  if {$diffcount == 4} {
    # Check for making/unmaking a castling move:
    set castlingList [list [sq e1] [sq g1] [sq h1] [sq f1] \
        [sq e8] [sq g8] [sq h8] [sq f8] \
        [sq e1] [sq c1] [sq a1] [sq d1] \
        [sq e8] [sq c8] [sq a8] [sq d8]]

    foreach {kfrom kto rfrom rto} $castlingList {
      if {[lsort $difflist] == [lsort [list $kfrom $kto $rfrom $rto]]} {
        if {[string tolower [string index $oldboard $kfrom]] == "k"  &&
          [string tolower [string index $oldboard $rfrom]] == "r"  &&
          [string tolower [string index $newboard $kto]] == "k"  &&
          [string tolower [string index $newboard $rto]] == "r"} {
          # A castling move animation.
          # Move the rook back to initial square until animation is complete:
          # TODO: It may look nicer if the rook was animated as well...
          eval $w.bd coords p$rto [::board::midSquare $w $rfrom]
          set from $kfrom
          set to $kto
        } elseif {[string tolower [string index $newboard $kfrom]] == "k"  &&
          [string tolower [string index $newboard $rfrom]] == "r"  &&
          [string tolower [string index $oldboard $kto]] == "k"  &&
          [string tolower [string index $oldboard $rto]] == "r"} {
          # An undo-castling animation. No need to move the rook.
          set from $kto
          set to $kfrom
        }
      }
    }
  }

  if {$diffcount == 3} {
    # Three squares are different, so check for an En Passant capture:
    foreach i {0 1 2} {
      foreach j {0 1 2} {
        foreach k {0 1 2} {
          if {$i == $j  ||  $i == $k  ||  $j == $k} { continue }
          # Check for an en passant capture from i to j with the enemy
          # pawn on k:
          if {$old($i) == $new($j) && $old($j) == "." && $new($k) == "."  &&
            (($old($i) == "p" && $old($k) == "P") ||
            ($old($i) == "P" && $old($k) == "p"))} {
            set from $sq($i)
            set to $sq($j)
          }
          # Check for undoing an en-passant capture from j to i with
          # the enemy pawn on k:
          if {$old($i) == $new($j) && $old($k) == "." && $new($i) == "."  &&
            (($old($i) == "p" && $new($k) == "P") ||
            ($old($i) == "P" && $new($k) == "p"))} {
            set from $sq($i)
            set to $sq($j)
            set captured $sq($k)
            set capturedPiece $new($k)
          }
        }
      }
    }
  }

  if {$diffcount == 2} {
    # Check for a regular move or capture: one old square should have the
    # same (non-empty) piece as the other new square, and at least one
    # of the old or new squares should be empty.

    if {$old(0) != "." && $old(1) != "." && $new(0) != "." && $new(1) != "."} {
      return
    }

    foreach i {0 1} {
      foreach j {0 1} {
        if {$i == $j} { continue }
        if {$old($i) == $new($j)  &&  $old($i) != "."} {
          set from $sq($i)
          set to $sq($j)
          set captured $sq($j)
          set capturedPiece $old($j)
        }
        
        # Check for a (white or black) pawn promotion from i to j:
        if {($old($i) == "P"  &&  [string is upper $new($j)]  &&
          $sq($j) >= [sq a8]  &&  $sq($j) <= [sq h8])  ||
          ($old($i) == "p"  &&  [string is lower $new($j)]  &&
          $sq($j) >= [sq a1]  &&  $sq($j) <= [sq h1])} {
          set from $sq($i)
          set to $sq($j)
        }
        
        # Check for undoing a pawn promotion from j to i:
        if {($new($j) == "P"  &&  [string is upper $old($i)]  &&
          $sq($i) >= [sq a8]  &&  $sq($i) <= [sq h8])  ||
          ($new($j) == "p"  &&  [string is lower $old($i)]  &&
          $sq($i) >= [sq a1]  &&  $sq($i) <= [sq h1])} {
          set from $sq($i)
          set to $sq($j)
          set captured $sq($j)
          set capturedPiece $old($j)
        }
      }
    }
  }

  # Check that we found a valid-looking move to animate:
  if {$from < 0  ||  $to < 0} { return }

  # Redraw the captured piece during the animation if necessary:
  if {$capturedPiece != "."  &&  $captured >= 0} {
    ::board::drawPiece $w $from $capturedPiece
    eval $w.bd coords p$from [::board::midSquare $w $captured]
  }

  # Move the animated piece back to its starting point:
  eval $w.bd coords p$to [::board::midSquare $w $from]
  $w.bd raise p$to

  # Remove side-to-move icon while animating:
  grid remove $w.wtm $w.btm

  # Start the animation:
  set start [clock clicks -milli]
  set ::board::_animate($w,start) $start
  set ::board::_animate($w,end) [expr {$start + $::animateDelay} ]
  set ::board::_animate($w,from) $from
  set ::board::_animate($w,to) $to
  ::board::_animate $w
}

# ::board::_animate
#   Internal procedure for updating a board move animation.
#
proc ::board::_animate {w} {
  if {! [winfo exists $w]} { return }
  set from $::board::_animate($w,from)
  set to $::board::_animate($w,to)
  set start $::board::_animate($w,start)
  set end $::board::_animate($w,end)
  set now [clock clicks -milli]
  if {$now > $end} {
    ::board::update $w
    return
  }

  # Compute where the moving piece should be displayed and move it:
  set ratio [expr {double($now - $start) / double($end - $start)} ]
  set fromMid [::board::midSquare $w $from]
  set toMid [::board::midSquare $w $to]
  set fromX [lindex $fromMid 0]
  set fromY [lindex $fromMid 1]
  set toX [lindex $toMid 0]
  set toY [lindex $toMid 1]
  set x [expr {$fromX + round(($toX - $fromX) * $ratio)} ]
  set y [expr {$fromY + round(($toY - $fromY) * $ratio)} ]
  $w.bd coords p$to $x $y
  $w.bd raise p$to

  # Schedule another animation update in a few milliseconds:
  after 5 "::board::_animate $w"
}

# Capture board screenshot.
# Based on code from David Easton:
# http://wiki.tcl.tk/9127

set window_image_support 1
if { [catch {package require img::window}] } {
  set window_image_support 0
}

if {!$png_image_support || !$window_image_support} {
  .menu.tools entryconfig {Board Screenshot} -state disabled
  if {!$png_image_support} {
    ::splash::add "Board screenshot disabled - no png support"
  } else {
    ::splash::add "Board screenshot disabled - no image window support"
  }
}

proc boardToFile { format filepath } {

  set w .board
  set board $w.bd

  if { $format == "" } {
    set format png
  }
  set filename $filepath

  # Make the base image based on the board
  ::board::update $w
  update idletask
  set image [image create photo -format window -data $board]

  if { $filename == "" } {
 
    set filename "[sc_game tag get White]-[sc_game tag get Black]"
    if {[regexp {\?} $filename] || [regexp {\*} $filename]} {
      set filename [string trim [string map {? {} * {}} [wm title .]]]
    }

    if {[sc_pos side] == {white} && [sc_pos moveNumber] != {1} } {
      set move [sc_pos moveNumber]..[sc_game info previousMove]
    } else {
      set move [sc_pos moveNumber][sc_game info previousMove]
    }
    set filename "$filename ($move)"

    if {[file exists $::env(HOME)/$filename.$format]} {
      set i 1
      while {[file exists $::env(HOME)/$filename-$i.$format]} {
        incr i
      }
      set filename $filename-$i
    }

    # set types {{"Image Files" {.$format}}}
    set types {{"All Files" {*}}}
    set filename [tk_getSaveFile \
	-filetypes $types \
	-parent . \
	-initialfile $filename.$format \
	-initialdir $::env(HOME) \
	-defaultextension .$format \
	-title {Scid: Board Screenshot}]
  }

  if {[llength $filename]} {
    if {[catch {$image write -format $format $filename} result ]} {
      tk_messageBox -type ok -icon error -title "Scid" -message $result -parent .
    }
  }
  image delete $image
}


###
### End of file: board.tcl
###
