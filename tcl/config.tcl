# config.tcl: Some embedded configuration for Scid

namespace eval ::config {}

if {$windowsOS} {
  set scidShareDir $scidExeDir
} else {
  set scidShareDir [file normalize [file join $scidExeDir "../share/scid"]]
}

# also reset BooksDir if the variable is set, but doesn't exist S.A.
if {![info exists scidBooksDir] || ![file isdirectory $scidBooksDir]} {
  set scidBooksDir [file nativename [file join $scidShareDir "books"]]
}

if {![info exists scidBasesDir] || ![file isdirectory $scidBasesDir]} {
  set scidBasesDir [file nativename [file join $scidShareDir "bases"]]
}

# ecoFile: the ECO file for opening classification. Scid will try to load
# this first, and if that fails, it will try to load  "scid.eco" in the
# current directory.
if {$ecoFile == ""} {
  if {$windowsOS} {
    set ecoFile [file join $scidDataDir "scid.eco"]
  } else {
    set ecoFile [file join [file join $scidShareDir "data"] "scid.eco"]
  }
}

# Spell-checking file: default is "spelling.ssp".
if {$windowsOS} {
  set spellCheckFile [file join $scidDataDir "spelling.ssp"]
} else {
  set spellCheckFile [file join $scidShareDir "spelling.ssp"]
}

