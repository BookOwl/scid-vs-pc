###
### config.tcl: Some embedded configuration for Scid

namespace eval ::config {}

if {$windowsOS} {
  set scidShareDir $scidExeDir
} elseif {$macApp} {
  set scidShareDir [file normalize [file join $scidExeDir "../Resources"]]
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
if {![info exists spellCheckFile]} {
  if {$windowsOS} {
    set spellCheckFile [file join $scidDataDir "spelling.ssp"]
  } else {
    set spellCheckFile [file join $scidShareDir "spelling.ssp"]
  }
}

### Display directories

::splash::add "scidShareDir is $scidShareDir"

if {[file isdirectory $::scidBasesDir]} {
  ::splash::add "scidBasesDir is $scidBasesDir"
} else {
  ::splash::add "scidBasesDir $scidBasesDir not found!" error
}

if {[file isdirectory $::scidBooksDir]} {
  ::splash::add "scidBooksDir is $scidBooksDir"
} else {
  ::splash::add "scidBooksDir $scidBooksDir not found!" error
}

# Install windows fonts if applicable

if {$windowsOS && [file exists "$scidShareDir/fonts/ScidChessBerin.ttf"]} {
    set dest [file join $env(windir) fonts]
    if {[catch {
	foreach i [glob $scidShareDir/fonts/*] {
	    file rename $i $dest
        }
    }]} {
          ::splash::add "Failed to install PGN chess fonts" error
    } else {
          ::splash::add "Successfully installed PGN chess fonts"
    }
}

### Setup for truetype (and PGN figurine) support

set graphFigurineFamily {}
set graphFigurineAvailable [expr $windowsOS || $macOS]
if {[::tk windowingsystem] eq "x11"} {
    catch { if {[::tk::pkgconfig get fontsystem] eq "xft"} { set graphFigurineAvailable 1 } }
}

if {$graphFigurineAvailable} {
    set graphFigurineFamilies {}
    foreach font [font families] {
        if {[string match -nocase {Scid Chess *} $font]} { lappend graphFigurineFamilies $font }
    }
    if {[lsearch $graphFigurineFamilies {Scid Chess Traveller}] >= 0} {
        set graphFigurineFamily {Scid Chess Traveller}
    } elseif {[lsearch $graphFigurineFamilies {Scid Chess Berlin}] >= 0} {
        set graphFigurineFamily {Scid Chess Berlin}
    } elseif {[llength $graphFigurineFamilies] > 0} {
        set graphFigurineFamily [lindex $graphFigurineFamilies 0]
    } else {
        set graphFigurineAvailable 0
        set useGraphFigurine 0
    }
} else {
    set useGraphFigurine 0
}

if {$graphFigurineAvailable} {
  ::splash::add "True type fonts (PGN figurines) enabled."
} else {
  ::splash::add "True type fonts (PGN figurines) disabled." error
}

if {$graphFigurineAvailable} {
        font create font_Figurine -family $graphFigurineFamily -size $fontsize
}

### end of config.tcl

