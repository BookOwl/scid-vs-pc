#!/bin/sh

# Scid vs. PC
#
# convert help.tcl into html files

# The next line restarts using tkscid: \
exec tclsh8.5 "$0" "$@"

set ::scidName {Scid vs. PC}
set ::scidVersion 4.7
set ::scidVersionDate {May 27, 2012}
source help.tcl

file mkdir doc
cd doc

foreach topic [array names helpText] {
  set fd [open $topic.htm w]

  # - <a Annotating>
  # + <a href="Annotating.htm">
  regsub -all {<a ([^ ><]*)>} $helpText($topic) {<a href="\1.htm">}  text

  # - <a GameList href="Browsing.htm">
  # + <a href="GameList.htm#Browsing">
  regsub -all {<a ([^ ><]*) ([^ ><]*)>} $text {<a href="\1.htm#\2">}  text

  # - <name Annotating>
  # + <A NAME="s2">
  regsub -all {<name ([^ ><]*)>} $text {<a name="\1">}  text

  # - <img arrow_up>
  # + <IMG SRC="images/arrow_up.gif">
  regsub -all {<img ([^ ><]*)>} $text {<img src="images/\1.gif">}  text

  # - <button tb_pause 32>
  # + <IMG SRC="images/arrow_up.gif">
  regsub -all {<button ([^ ><]*)>} $text {<img src="images/\1.gif">}  text
  regsub -all {<button ([^ ><]*) [^ ><]*>} $text {<img src="images/\1.gif">}  text

  regsub -all {<gt>} $text {> } text
  regsub -all {<lt>} $text {<} text
  regsub -all {<ht>} $text {<ul>} text
  regsub -all {</ht>} $text {</ul>} text

  regsub -all {<run[^>]*>} $text {} text
  regsub -all {</run>} $text {} text

  puts $fd $text
  close $fd
}
