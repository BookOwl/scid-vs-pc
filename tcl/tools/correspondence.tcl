###
### Correspondence.tcl: part of Scid.
### Copyright (C) 2008 Alexander Wagner
###
### $Id: correspondence.tcl,v 1.21 2008/10/08 18:28:33 arwagner Exp $
###
### Last change: <Wed, 2008/10/08 20:01:52 arwagner ingata>
###
### Add correspondence chess via eMail or external protocol to scid
###
#======================================================================

# http and tdom are required for the Xfcc protocol

#======================================================================
#
# Xfcc interface for scid
#
#======================================================================
namespace eval Xfcc {

	#----------------------------------------------------------------------
	# Header and footer of the SOAP-messages. Linebreaking is imporant
	#
	set SOAPstart {<?xml version="1.0" encoding="utf-8"?>
	<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
	<soap:Body>
	}

	set SOAPend {</soap:Body>
	</soap:Envelope>}
	#
	#----------------------------------------------------------------------

	set xfccrc     ""
	set xfccstate  {}

	# list of server names for config dialog
	set lsrvname   {}

	# when was the last update was retrieved online?
	set lastupdate 0
	set update     0

	array unset xfccsrv
	# entry values for config dialog
	set Oldnum     0
	set Server     ""
	set Username   ""
	set Password   ""
	set URI        ""

	# To pass on directories on windows with a backslash
	set xfccrcfile ""

	#----------------------------------------------------------------------
	# Replace XML entities by their normal characters
	#----------------------------------------------------------------------
	proc xmldecrypt {chdata} {

		foreach from {{\&amp;} {\&lt;} {\&gt;} {\&quot;} {\&apos;}}   \
			to {{\&} < > {"} {'}} {
				regsub -all $from $chdata $to chdata
		 }   
		 return $chdata
	}

	#----------------------------------------------------------------------
	# Configure Xfcc by means of rewriting the .xfccrc in xml
	#----------------------------------------------------------------------
	proc SaveXfcc {} {
		global ::Xfcc::xfccrc ::Xfcc::xfccrcfile
		# file delete $xfccrcfile
		if {[catch {open $xfccrcfile w} optionF]} {
			puts stderr "error"
		} else {
			# devide by 4 as the size function returns all subarray entries
			set size [expr [ array size ::Xfcc::xfccsrv ] / 4]

			puts $optionF "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
			puts $optionF "<xfcc>"
			for {set i 0} {$i < $size } {incr i} {
				if { [regexp {^# } $::Xfcc::xfccsrv($i,0)] && \
					  [regexp {^# } $::Xfcc::xfccsrv($i,1)] && \
					  [regexp {^# } $::Xfcc::xfccsrv($i,2)] && \
					  [regexp {^# } $::Xfcc::xfccsrv($i,3)] } {
					if {$size == 1} {
						puts $optionF "\t<server>"
						puts $optionF "\t\t<name>Server</name>"
						puts $optionF "\t\t<uri>http://</uri>"
						puts $optionF "\t\t<user>User_Name</user>"
						puts $optionF "\t\t<pass>Password</pass>"
						puts $optionF "\t</server>"
					}
				} else {
					puts $optionF "\t<server>"
					puts $optionF "\t\t<name>$::Xfcc::xfccsrv($i,0)</name>"
					puts $optionF "\t\t<uri>$::Xfcc::xfccsrv($i,1)</uri>"
					puts $optionF "\t\t<user>$::Xfcc::xfccsrv($i,2)</user>"
					puts $optionF "\t\t<pass>$::Xfcc::xfccsrv($i,3)</pass>"
					puts $optionF "\t</server>"
				}
			}
			puts $optionF "</xfcc>"
			close $optionF
			::Xfcc::ReadConfig $xfccrcfile
		}
	}

	#----------------------------------------------------------------------
	# Delete the currently selected server entry
	#----------------------------------------------------------------------
	proc DeleteServer {} {
		# mark a deleted server by # allows the user to manually
		# undelete by removing the # again before hitting ok.
		set ::Xfcc::Server   "# $::Xfcc::xfccsrv($::Xfcc::Oldnum,0)"
		set ::Xfcc::Username "# $::Xfcc::xfccsrv($::Xfcc::Oldnum,2)"
		set ::Xfcc::Password "# $::Xfcc::xfccsrv($::Xfcc::Oldnum,3)"
		set ::Xfcc::URI      "# $::Xfcc::xfccsrv($::Xfcc::Oldnum,1)"
		set ::Xfcc::xfccsrv($::Xfcc::Oldnum) $::Xfcc::Server
		}

	#----------------------------------------------------------------------
	# Add a new, empty server entry to xfccsrv array
	#----------------------------------------------------------------------
	proc AddServer {} {

		set ::Xfcc::xfccsrv($::Xfcc::Oldnum,0) $::Xfcc::Server
		set ::Xfcc::xfccsrv($::Xfcc::Oldnum,2) $::Xfcc::Username
		set ::Xfcc::xfccsrv($::Xfcc::Oldnum,3) $::Xfcc::Password
		set ::Xfcc::xfccsrv($::Xfcc::Oldnum,1) $::Xfcc::URI

 		set size [expr [ array size ::Xfcc::xfccsrv ] / 4]

		# increement the list box with a new server entry
		.configXfccSrv.xfccSrvList configure -height [expr $size+2]

 		set ::Xfcc::xfccsrv($size,0) "Unique_ServerName"
 		set ::Xfcc::xfccsrv($size,2) "Your_Login"
 		set ::Xfcc::xfccsrv($size,3) "SeCrEt!"
 		set ::Xfcc::xfccsrv($size,1) "http://"

 		set ::Xfcc::Server    $::Xfcc::xfccsrv($size,0)
 		set ::Xfcc::Username  $::Xfcc::xfccsrv($size,2)
 		set ::Xfcc::Password  $::Xfcc::xfccsrv($size,3)
 		set ::Xfcc::URI       $::Xfcc::xfccsrv($size,1)

 		lappend ::Xfcc::lsrvname [list $::Xfcc::xfccsrv($size,0)]

 		set ::Xfcc::Oldnum    $size
	}

	#----------------------------------------------------------------------
	# Store the current values to the xfccsrv-array
	#----------------------------------------------------------------------
	proc xfccsrvstore {} {

		set number [ .configXfccSrv.xfccSrvList curselection ]
		if {!($number > 0)} {
			set number 0
		}
		set ::Xfcc::xfccsrv($::Xfcc::Oldnum,0) $::Xfcc::Server
		set ::Xfcc::xfccsrv($::Xfcc::Oldnum,2) $::Xfcc::Username
		set ::Xfcc::xfccsrv($::Xfcc::Oldnum,3) $::Xfcc::Password
		set ::Xfcc::xfccsrv($::Xfcc::Oldnum,1) $::Xfcc::URI

		set ::Xfcc::Server    $::Xfcc::xfccsrv($number,0)
		set ::Xfcc::Username  $::Xfcc::xfccsrv($number,2)
		set ::Xfcc::Password  $::Xfcc::xfccsrv($number,3)
		set ::Xfcc::URI       $::Xfcc::xfccsrv($number,1)

		set ::Xfcc::Oldnum    $number
		.configXfccSrv.xfccSrvList selection set $number
	}

	#----------------------------------------------------------------------
	# Configure Xfcc by means of rewriting the .xfccrc in xml
	#----------------------------------------------------------------------
	proc config {configfile} {
		global ::Xfcc::xfccrc ::Xfcc::xfccrcfile

		set xfccrcfile $configfile

		::Xfcc::ReadConfig $xfccrcfile
		set size [expr [array size ::Xfcc::xfccsrv ] / 4]

		set w ".configXfccSrv"
		if {[winfo exists $w]} {
			focus $w
			return
		}

		set number            1
		set ::Xfcc::Oldnum    0
		set ::Xfcc::Server    $::Xfcc::xfccsrv($::Xfcc::Oldnum,0)
		set ::Xfcc::Username  $::Xfcc::xfccsrv($::Xfcc::Oldnum,2)
		set ::Xfcc::Password  $::Xfcc::xfccsrv($::Xfcc::Oldnum,3)
		set ::Xfcc::URI       $::Xfcc::xfccsrv($::Xfcc::Oldnum,1)

		# create the window and buttons
		toplevel $w
		wm title $w "\[$xfccrcfile\]"
		button $w.bOk     -text OK -command "::Xfcc::xfccsrvstore; ::Xfcc::SaveXfcc; destroy .configXfccSrv"
		button $w.bAdd    -text  [::tr "GlistAddField"] -command {
			::Xfcc::AddServer
		}

		button $w.bDelete -text [::tr "GlistDeleteField"] -command {
			::Xfcc::DeleteServer
		}
		button $w.bCancel -text [::tr "Cancel"] -command "destroy $w"

		listbox $w.xfccSrvList -height [expr [ array size ::Xfcc::xfccsrv ] / 4 + 1] -width 60 -selectmode single -list ::Xfcc::lsrvname
		# select the first entry
		$w.xfccSrvList selection set $::Xfcc::Oldnum

		label  $w.lxfccSrv -text "Server name:"
		label  $w.lxfccUid -text "Login name:"
		label  $w.lxfccPas -text "Password:"
		label  $w.lxfccURI -text "URL:"

		entry  .configXfccSrv.xfccSrv  -width 60 -textvariable ::Xfcc::Server
		entry  .configXfccSrv.xfccUid  -width 60 -textvariable ::Xfcc::Username
		entry  .configXfccSrv.xfccPas  -width 60 -textvariable ::Xfcc::Password
		entry  .configXfccSrv.xfccURI  -width 60 -textvariable ::Xfcc::URI

		# Bind the change of selection to a proper update of variables and internal representatio
		bind .configXfccSrv.xfccSrvList <<ListboxSelect>> {
			::Xfcc::xfccsrvstore
		}

		grid $w.xfccSrvList  -stick e -columnspan 6 -column  0 -row 0 -rowspan $number

		grid $w.lxfccSrv     -stick e -columnspan 2 -column  0 -row [expr {$number + 1}]
		grid $w.lxfccUid     -stick e -columnspan 2 -column  0 -row [expr {$number + 2}]
		grid $w.lxfccPas     -stick e -columnspan 2 -column  0 -row [expr {$number + 3}]
		grid $w.lxfccURI     -stick e -columnspan 2 -column  0 -row [expr {$number + 4}]

		grid $w.xfccSrv      -stick w -columnspan 4 -column  2 -row [expr {$number + 1}]
		grid $w.xfccUid      -stick w -columnspan 4 -column  2 -row [expr {$number + 2}]
		grid $w.xfccPas      -stick w -columnspan 4 -column  2 -row [expr {$number + 3}]
		grid $w.xfccURI      -stick w -columnspan 4 -column  2 -row [expr {$number + 4}]

		# Add the buttons to the window
		grid $w.bOk     -column 2 -row [expr {$number + 5}]
		grid $w.bAdd    -column 3 -row [expr {$number + 5}]
		grid $w.bDelete -column 4 -row [expr {$number + 5}]
		grid $w.bCancel -column 5 -row [expr {$number + 5}]

		bind $w <Escape> "$w.bCancel invoke"
		bind $w <F1> { helpWindow CCXfccSetupDialog}
	}

	#----------------------------------------------------------------------
	# Read xfccrcfile (xml) config file and stores the xml structure as
	# is to the global $xfccrc
	#----------------------------------------------------------------------
	proc ReadConfig {xfccrcfile} {
		global xfccrc

		::CorrespondenceChess::updateConsole "info This is Scids internal Xfcc-interface"
		::CorrespondenceChess::updateConsole "info Using $xfccrcfile..."
		if {[catch {open $xfccrcfile r} optionF]} {
			::CorrespondenceChess::updateConsole "info ERROR: Unable ot open config file $xfccrcfile";
		} else {
			set xfccrc [read $optionF]

			set dom [dom parse $xfccrc]
			set doc [$dom documentElement]
			set aNodes [$doc selectNodes {/xfcc/server}]
			set number   0

			# reset the servernames before reading them in again
			set ::Xfcc::lsrvname {}

			foreach srv $aNodes {
				set name     [$srv selectNodes {string(name)}]
				set uri      [$srv selectNodes {string(uri)}]
				set username [$srv selectNodes {string(user)}]
				set password [$srv selectNodes {string(pass)}]

				set ::Xfcc::xfccsrv($number,0) $name
				set ::Xfcc::xfccsrv($number,1) $uri
				set ::Xfcc::xfccsrv($number,2) $username
				set ::Xfcc::xfccsrv($number,3) $password

				lappend ::Xfcc::lsrvname [list $name ]

				incr number
			}
			close $optionF
		}
	}

	#----------------------------------------------------------------------
	# SOAPError: parses $xml and searches for error messages from the
	# server to report them to the user.
	#----------------------------------------------------------------------
	proc SOAPError {server xml} {
		# Remove the SOAP-Envelope and make all server responses to a
		# common XML format as they use the same error messages anyway.
		regsub -all {.*<soap:Fault>} $xml {<error>} xml
		regsub -all {</soap:Fault>.*} $xml {</error>} xml

		regsub -all {.*<MakeAMoveResponse.*\">} $xml {<error>} xml
		regsub -all {</MakeAMoveResponse>.*} $xml {</error>} xml
		regsub -all {<MakeAMoveResult>} $xml {<faultstring>} xml
		regsub -all {</MakeAMoveResult>} $xml {</faultstring>} xml

		set dom [dom parse $xml]
		set doc [$dom documentElement]

		set aNodes [$doc selectNodes //error]
		foreach game $aNodes {
			set fcode   [$game selectNodes {string(faultcode)}]
			set fstring [$game selectNodes {string(faultstring)}]
			switch -regexp -- $fstring \
			"Success" {
				::CorrespondenceChess::updateConsole "info Processing successfull!"
			} \
			"ServerError" {
				::CorrespondenceChess::updateConsole "info Server Error!"
				set Title "Scid Error"
				set Error "$server reported an unknown error."
				tk_messageBox -icon warning -type ok -parent . \
					-title $Title -message $Error
			} \
			"FeatureUnavailable" {
				::CorrespondenceChess::updateConsole "info Feature unavailable!"
			} \
			"AuthenticationFailed" {
				::CorrespondenceChess::updateConsole "info Authentication failed!"
				set Title "Scid Authentication Failure!"
				set Error "Could not authenticate to the Xfcc-Server.\nPlease check Username and Password for $server."
				tk_messageBox -icon warning -type ok -parent . \
					-title $Title -message $Error
			} \
			"InvalidGameID" {
				::CorrespondenceChess::updateConsole "info Invalid Game-ID!"
			} \
			"NotYourGame" {
				::CorrespondenceChess::updateConsole "info Not your game!"
			} \
			"NotYourTurn" {
				::CorrespondenceChess::updateConsole "info Not your turn!"
			} \
			"InvalidMove" {
				::CorrespondenceChess::updateConsole "info Invalid move!"
			} \
			"InvalidMoveNumber" {
				::CorrespondenceChess::updateConsole "info Invalid move number!"
			} \
			"NoDrawWasOffered" {
				::CorrespondenceChess::updateConsole "info No draw was offered!"
			} \
			"LostOnTime" {
				::CorrespondenceChess::updateConsole "info Lost on time!"
			} \
			"YouAreOnLeave" {
				::CorrespondenceChess::updateConsole "info You are on leave!"
			} \
			"MoveIsAmbigous" {
				::CorrespondenceChess::updateConsole "info Move is ambigous!"
			}
		}
	}

	#----------------------------------------------------------------------
	# Process all servers found in the global xfccrc and store the
	# games in path/.
	#----------------------------------------------------------------------
	proc ProcessAll {path} {
		global xfccrc

		set dom [dom parse $xfccrc]
		set doc [$dom documentElement]

		set aNodes [$doc selectNodes {/xfcc/server}]

		foreach srv $aNodes {
			set name     [$srv selectNodes {string(name)}]
			set uri      [$srv selectNodes {string(uri)}]
			set username [$srv selectNodes {string(user)}]
			set password [$srv selectNodes {string(pass)}]

			::CorrespondenceChess::updateConsole "info Processing $username\@$name..."
			set xml [::Xfcc::Receive $uri $username $password]
			::Xfcc::SOAPError $name $xml
			::Xfcc::WritePGN $path $name $xml
			::Xfcc::PrintStatus $path $name $xml
		}
	}

	#----------------------------------------------------------------------
	# Recieve games via XFCC from the web service at uri using username
	# and password provided
	#----------------------------------------------------------------------
	proc Receive {uri username password} {
		# construct the SOAP-message for Xfcc Webservice
		set xmlmessage $::Xfcc::SOAPstart
			# generate the "Get my Games" call
			append xmlmessage {<GetMyGames xmlns="http://www.bennedik.com/webservices/XfccBasic">}
			append xmlmessage "<username>$username</username>"
			append xmlmessage "<password>$password</password>"
			append xmlmessage "</GetMyGames>"
		append xmlmessage $::Xfcc::SOAPend

		# send it to the web service note the space before the charset
		set token [::http::geturl $uri \
						-type "text/xml; charset=\"utf-8\"" \
						-query $xmlmessage]

		# retrieve result
		set xmlresult [::http::data $token]
		return $xmlresult
	}

	#----------------------------------------------------------------------
	# Send move via XFCC to the web service at uri using username
	# and password provided. Gameid is the unique id on the server,
	# move count the current move number, move the move to send in SAN,
	# comment the comment sent to the opponent. The other variables are
	# flags that might be true/false.
	#----------------------------------------------------------------------
	proc SendMove {uri username password gameid movecount move comment \
						resign acceptdraw offerdraw claimdraw} {
		set xmlmessage $::Xfcc::SOAPstart
			append xmlmessage {<MakeAMove xmlns="http://www.bennedik.com/webservices/XfccBasic">}
			append xmlmessage "<username>$username</username>"
			append xmlmessage "<password>$password</password>"
			append xmlmessage "<gameId>$gameid</gameId>"
			append xmlmessage "<resign>$resign</resign>"
			append xmlmessage "<acceptDraw>$acceptdraw</acceptDraw>"
			append xmlmessage "<movecount>$movecount</movecount>"
			append xmlmessage "<myMove>$move</myMove>"
			append xmlmessage "<offerDraw>$offerdraw</offerDraw>"
			append xmlmessage "<claimDraw>$claimdraw</claimDraw>"
			append xmlmessage "<myMessage>$comment</myMessage>"
			append xmlmessage "</MakeAMove>"
		append xmlmessage $::Xfcc::SOAPend

		# send it to the web service note the space before the charset
		set token [::http::geturl $uri \
						-type "text/xml; charset=\"utf-8\"" \
						-query $xmlmessage]

		# retrieve result
		set xmlresult [::http::data $token]
		return $xmlresult
	}

	#----------------------------------------------------------------------
	# Send move to server, extracting login data first from config file
	#----------------------------------------------------------------------
	proc Send {name gameid movecount move comment \
				  resign acceptdraw offerdraw claimdraw} {
		global xfccrc

		set dom [dom parse $xfccrc]
		set doc [$dom documentElement]

		set aNodes [$doc selectNodes {/xfcc/server}]

		foreach srv $aNodes {
			set server   [$srv selectNodes {string(name)}]
			set uri      [$srv selectNodes {string(uri)}]
			set username [$srv selectNodes {string(user)}]
			set password [$srv selectNodes {string(pass)}]

			if {$name == $server} {
				::CorrespondenceChess::updateConsole "info Processing $gameid for $username\@$name..."
				::CorrespondenceChess::updateConsole "info Sending $movecount\. $move \{$comment\}"

				if {$resign == "true"} {
					::CorrespondenceChess::updateConsole "info Resigning..."
				}
				if {$acceptdraw == "true"} {
					::CorrespondenceChess::updateConsole "info Accepting draw..."
				}
				if {$claimdraw == "true"} {
					::CorrespondenceChess::updateConsole "info Claiming draw..."
				}
				if {$offerdraw == "true"} {
					::CorrespondenceChess::updateConsole "info Offering draw..."
				}

				set xml [::Xfcc::SendMove $uri $username $password \
							$gameid $movecount $move $comment \
							$resign $acceptdraw $offerdraw $claimdraw]
				::Xfcc::SOAPError $name $xml
			}
		}
	}

	#----------------------------------------------------------------------
	# Given the name of the Xfcc-Server and the XML-result from the web
	# server. name is the name of the server used for generation of the
	# CmailGameID, xml is the result from the web service
	#----------------------------------------------------------------------
	proc WritePGN {path name xml} {

		# The following removes the SOAP-Envelope. tDOM does not seem to
		# like it for whatever reason, but it's not needed anyway.
		regsub -all {.*<GetMyGamesResult>} $xml {<GetMyGamesResult>} xml
		regsub -all {</GetMyGamesResult>.*} $xml {</GetMyGamesResult>} xml

		set dom [dom parse $xml]
		set doc [$dom documentElement]

		set aNodes [$doc selectNodes //XfccGame]
		foreach game $aNodes {
			set id          [::Xfcc::xmldecrypt [$game selectNodes {string(id)}]]
			set Event       [::Xfcc::xmldecrypt [$game selectNodes {string(event)}]]
			set Site        [::Xfcc::xmldecrypt [$game selectNodes {string(site)}]]
			set Date        [::Xfcc::xmldecrypt [$game selectNodes {string(eventDate)}]]
			set White       [::Xfcc::xmldecrypt [$game selectNodes {string(white)}]]
			set Black       [::Xfcc::xmldecrypt [$game selectNodes {string(black)}]]
			set WhiteElo    [::Xfcc::xmldecrypt [$game selectNodes {string(whiteElo)}]]
			set BlackElo    [::Xfcc::xmldecrypt [$game selectNodes {string(blackElo)}]]
			set TimeControl [::Xfcc::xmldecrypt [$game selectNodes {string(timeControl)}]]
			set GameId      [::Xfcc::xmldecrypt [$game selectNodes {string(id)}]]
			set Source      [::Xfcc::xmldecrypt [$game selectNodes {string(gameLink)}]]
			set Result      [::Xfcc::xmldecrypt [$game selectNodes {string(result)}]]

			# These values may not be set, they were first introduced by
			# SchemingMind as extension to Xfcc
			set whiteCountry [::Xfcc::xmldecrypt [$game selectNodes {string(whiteCountry)}]]
			set blackCountry [::Xfcc::xmldecrypt [$game selectNodes {string(blackCountry)}]]
			set whiteIccfID  [::Xfcc::xmldecrypt [$game selectNodes {string(whiteIccfID)}]]
			set blackIccfID  [::Xfcc::xmldecrypt [$game selectNodes {string(blackIccfID)}]]
			set whiteFideID  [::Xfcc::xmldecrypt [$game selectNodes {string(whiteFideID)}]]
			set blackFideID  [::Xfcc::xmldecrypt [$game selectNodes {string(blackFideID)}]]

			# White/BlackNA are normally left blank but if the user
			# allwos contain the mail addresses of the player
			set WhiteNA     [::Xfcc::xmldecrypt [$game selectNodes {string(whiteNA)}]]
			set BlackNA     [::Xfcc::xmldecrypt [$game selectNodes {string(blackNA)}]]

			set myTurn          [$game selectNodes {string(myTurn)}]

			if {$WhiteNA == ""} {
				set WhiteNA "white@unknown.org"
			}
			if {$BlackNA == ""} {
				set BlackNA "black@unknown.org"
			}

			set moves       [::Xfcc::xmldecrypt [$game selectNodes {string(moves)}]]
			set mess        [::Xfcc::xmldecrypt [$game selectNodes {string(message)}]]

			# get the variant as scid can not handle many of them.
			# a list of all possible tags can be found here:
			# http://wiki.schemingmind.com/PGNVariantValues
			# http://wiki.schemingmind.com/Variants
			set variant         [$game selectNodes {string(variant)}]

			set filename [file nativename [file join $path "$name-$id.pgn"]]
			file delete $filename

			# Drop games that are not "normal" chess as scid can not
			# handle variants. Note that the ICCF does not set the
			# variant flag. Additionally, it is enough to drop variant
			# games from the inbox to get proper playlists.
			if {($variant == "chess") || ($variant == "")} {
				if {[catch {open $filename w} pgnF]} {
					::CorrespondenceChess::updateConsole "info ERROR: Unable ot open config file $filename";
				} else {
					::CorrespondenceChess::updateConsole "info $name-$id..."
					puts $pgnF "\[Event \"$Event\"\]";
					puts $pgnF "\[Site \"$Site\"\]";
					puts $pgnF "\[Date \"$Date\"\]";
					puts $pgnF "\[White \"$White\"\]";
					puts $pgnF "\[Black \"$Black\"\]";
					puts $pgnF "\[WhiteElo \"$WhiteElo\"\]";
					puts $pgnF "\[BlackElo \"$BlackElo\"\]";
					puts $pgnF "\[TimeControl \"$TimeControl\"\]";
					puts $pgnF "\[GameId \"$GameId\"\]";
					puts $pgnF "\[Source \"$Source\"\]";
					puts $pgnF "\[WhiteNA \"$WhiteNA\"]";
					puts $pgnF "\[BlackNA \"$BlackNA\"]";
					puts $pgnF "\[Mode \"XFCC\"\]";
					puts $pgnF "\[CmailGameName \"$name-$id\"\]";

					if {$whiteCountry != ""} {
						puts $pgnF "\[whiteCountry \"$whiteCountry\"\]";
					}
					if {$blackCountry != ""} {
						puts $pgnF "\[blackCountry \"$blackCountry\"\]";
					}
					if {$whiteIccfID > 0} {
						puts $pgnF "\[whiteIccfID \"$whiteIccfID\"\]";
					}
					if {$blackIccfID > 0} {
						puts $pgnF "\[blackIccfID \"$blackIccfID\"\]";
					}
					if {$whiteFideID  > 0} {
						puts $pgnF "\[whiteFideID \"$whiteFideID\"\]";
					}
					if {$blackFideID > 0} {
						puts $pgnF "\[blackFideID \"$blackFideID\"\]";
					}

					# add result to the header
					# Adjudication is handled like normal game results, that
					# is WhiteWins == WhiteWinAdjudicated etc.
					switch -regexp -- $Result \
					"Ongoing" {
						puts $pgnF "\[Result \"*\"\]\n";
					} \
					"AdjudicationPending" {
						puts $pgnF "\[Result \"*\"\]\n";
					} \
					"WhiteWin*" {
						puts $pgnF "\[Result \"1-0\"\]\n";
					} \
					"BlackWin*" {
						puts $pgnF "\[Result \"0-1\"\]\n";
					} \
					"Draw*" {
						puts $pgnF "\[Result \"1/2-1/2\"\]\n";
					} \
					"WhiteDefaulted" {
						puts $pgnF "\[Result \"0-1\"\]\n";
					} \
					"BlackDefaulted" {
						puts $pgnF "\[Result \"1-0\"\]\n";
					} \
					"BothDefaulted" {
						puts $pgnF "\[Result \"1/2-1/2\"\]\n";
					} \
					default {
						puts $pgnF "\[Result \"$Result\"\]\n";
					}

					# Add the game-id as comment before starting the game.
					# This might be helpfull on certain mobile devices, that
					# can not deal with extensive header information, e.g.
					# OpenChess on PalmOS.
					puts $pgnF "{$name-$id}"
					puts $pgnF $moves

					# If the PGN already ends with a comment, do not place
					# the message string afterwards as scid will then
					# discard the comment in the movelist.
					if {[string range $moves end end] != "\}"} {
						if {($myTurn == "true") && ($mess != "")} {
							puts "writing comment from mess"
							puts -nonewline $pgnF "\{"
							puts -nonewline $pgnF $mess
							puts $pgnF "\}"
						}
					}
					# If a game has finished and a message is sent allways
					# add it here.
					if {($Result != "Ongoing") && ($mess != "")} {
						puts -nonewline $pgnF "\{"
						puts -nonewline $pgnF $mess
						puts $pgnF "\}"
					}

					# add result at the end
					switch -regexp -- $Result \
					"Ongoing" {
						puts $pgnF "*";
					} \
					"AdjudicationPending" {
						puts $pgnF "*";
					} \
					"WhiteWin*" {
						puts $pgnF "1-0\n";
					}\
					"BlackWin*" {
						puts $pgnF "0-1\n";
					}\
					"Draw*" {
						puts $pgnF "1/2-1/2\n";
					} \
					"WhiteDefaulted" {
						puts $pgnF "\{White Defaultet\} 0-1\n";
					}\
					"BlackDefaulted" {
						puts $pgnF "\{Black Defaultet\} 1-0\n";
					}\
					"BothDefaulted" {
						puts $pgnF "\{Both Defaultet\} 1/2-1/2\n";
					}
					close $pgnF
				}
			}
		}
	}

	#----------------------------------------------------------------------
	# Prints all status flags of the games in xml for server name.
	#----------------------------------------------------------------------
	proc PrintStatus {path name xml} {
		regsub -all {.*<GetMyGamesResult>} $xml {<GetMyGamesResult>} xml
		regsub -all {</GetMyGamesResult>.*} $xml {</GetMyGamesResult>} xml

		set dom [dom parse $xml]
		set doc [$dom documentElement]

		set aNodes [$doc selectNodes //XfccGame]
		foreach game $aNodes {
			set id              [$game selectNodes {string(id)}]
			set myTurn          [$game selectNodes {string(myTurn)}]
			set daysPlayer      [$game selectNodes {string(daysPlayer)}]
			set hoursPlayer     [$game selectNodes {string(hoursPlayer)}]
			set minutesPlayer   [$game selectNodes {string(minutesPlayer)}]
			set daysOpponent    [$game selectNodes {string(daysOpponent)}]
			set hoursOpponent   [$game selectNodes {string(hoursOpponent)}]
			set minutesOpponent [$game selectNodes {string(minutesOpponent)}]
			set drawOffered     [$game selectNodes {string(drawOffered)}]
			set setup           [$game selectNodes {string(setup)}]
			set variant         [$game selectNodes {string(variant)}]
			set noOpeningBooks  [$game selectNodes {string(noOpeningBooks)}]
			set noDatabases     [$game selectNodes {string(noDatabases)}]
			set noTablebases    [$game selectNodes {string(noTablebases)}]
			set noEngines       [$game selectNodes {string(noEngines)}]
			set Result          [$game selectNodes {string(result)}]
			set mess            [::Xfcc::xmldecrypt [$game selectNodes {string(message)}]]

			if {[$game selectNodes {string(hasWhite)}] == "true"} {
				set clockW [format "%2ud %2u:%2u" $daysPlayer $hoursPlayer $minutesPlayer]
				set clockB [format "%2ud %2u:%2u" $daysOpponent $hoursOpponent $minutesOpponent]
			} else {
				set clockB [format "%2ud %2u:%2u" $daysPlayer $hoursPlayer $minutesPlayer]
				set clockW [format "%2ud %2u:%2u" $daysOpponent $hoursOpponent $minutesOpponent]
			}
			lappend ::Xfcc::xfccstate [list \
				"$name-$id" \
				[list "myTurn" $myTurn] \
				[list "clockW" $clockW] \
				[list "clockB" $clockB] \
				[list "drawOffered"  $drawOffered ]\
				[list "setup" $setup] \
				[list "variant" $variant] \
				[list "noOpeningBooks" $noOpeningBooks] \
				[list "noTablebases" $noTablebases] \
				[list "noDatabases" $noDatabases] \
				[list "noEngines" $noEngines] \
				[list "result" $Result] \
				[list "message" $mess] ]
		}

		set filename [scidConfigFile xfccstate]
		file delete $filename

		if {[catch {open $filename w} stateF]} {
			::CorrespondenceChess::updateConsole "info ERROR: Unable to open state file $filename";
		} else {
			puts $stateF "# Scid options file"
			puts $stateF "# State file for correspondence chess"
			puts $stateF "# Version: $::scidVersion, $::scidVersionDate"
			puts $stateF "# This file is generated automatically. Do NOT edit."

			set ::Xfcc::update 1
			set ::Xfcc::lastupdate [clock seconds]
			set curtime [clock format $::Xfcc::lastupdate]
			puts $stateF "#"
			puts $stateF "# Last Update: $curtime"
			puts $stateF "#"
			foreach i { ::Xfcc::lastupdate     \
							::Xfcc::xfccstate } {
				puts $stateF "set $i [list [set $i]]"
			}
		}
		close $stateF

	}

	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# source the options file to overwrite the above setup
	set scidConfigFiles(xfccstate) "xfccstate.dat"
	if {[catch {source [scidConfigFile xfccstate]} ]} {
	} else {
	  ::splash::add "Xfcc state found and restored."
	}

}

#======================================================================
#
# Correspondence chess menues, dialogs and functions
#
#======================================================================
image create photo tb_CC_Prev -data {
	R0lGODlhGAAYAMZIAAAAAAEBAQMDAwYGBh0dHWB8U2eEWGiFWWmHW2qHW3GOYnKQY3OSZHOTZHWS
	Z3qVbYWfdommfIykgIqmf4qseourfoqteo6qgYute4uue42tf5GqhZSpiZKrh4+ugZCugZCug5Ku
	hZGxgpewjZW0h5m0jJ21kbm+tbu/t73BuL7Cur7Cu7/Du9bZ1dnZ19zd2uLg4OLh4ePi4uTj4+Xk
	4+fn5+no6Orp6erp6uvq6uzq6+zr6+7s7u/s7u/s7/Ds8PHt8PDu8PLv8vPv8vPv8/Tw9PXx9fby
	9v//////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////yH+
	FUNyZWF0ZWQgd2l0aCBUaGUgR0lNUAAh+QQBCgB/ACwAAAAAGAAYAAAHjIB/goOEhYaHiImKi4yN
	jo+LAACQhpKUhAQtHAOXggAvHZOXADAyIwmikAI2OCYSqY4AMjw/JRsGsIwBOUFEJCEOuYoAMz1D
	RyIfEAfCiAA6QEVHGRgXD82VMT5CRkUWFBoTCNiEAC40Ozc1HiAVEQrknicoKSwqKwwMDQsHBfGS
	AAMK7ESwoMGDBAMBADs=
}


image create photo tb_CC_Next -data {
	R0lGODlhGAAYAMZHAAAAAAEBAQMDAwQEBAUFBQYGBggICAoKCl97UmN/VWeEWWeFWGqIXG6LYHOP
	ZXKRY3ORZHaVaH2ZcH+dcYakeIeje4aodoaod4mme4mseYqteouue5Crg42ufY6ufo+tgY+vgI+v
	gZGvgpOzhaOsnpq1kKO6l6a9m7DEprvAuNLU0NTV0dTV0tvb2tvc2eDg3+Hh4OPj4eTk4uno6Onq
	6Ovp6uzr6+7s7u7t7e7u7fDu7/Hv8fDw8PLv8vHw8fPv8/Lw8vPw8/Tw9PXx9fPz8vPz8/by9v//
	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////yH+
	FUNyZWF0ZWQgd2l0aCBUaGUgR0lNUAAh+QQBCgB/ACwAAAAAGAAYAAAHjIB/goOEhYaHiImKi4yN
	jo+FAAWTBgcElwQGAJuKAC40OUVEPCgnJiUVDgCLATI6PkA+IyEgFxCriwMtNT9DQxoaGRQMuIsA
	Lz1CRhsaFhHFxis4QL8dGMSPADE7QR4fD9CMACw2NyITCuGMAjAzHA3q4iouEgnx4ikL9+IkCPvi
	/wBCGkiwoMGDBgMBADs=
}

image create photo tb_CC_Send -data {
	R0lGODlhGAAYAKU4AAAAAE8/Cj4+PkNDQ01NTU9PT1NTU3NdEHVfEHxkEWNjY2pqapB0E3Nzc3x8
	fIGBga+NGJWVlaCgoMukHNGoHKysrK6urrm5ueS/Pby8vMbGxsjIyO3TfO3VgO3Vgu3WhNTU1O7W
	he7Yie7Yi+/ZjO/akvDbk/Dcl+Pj4/Tls+Tk5PTmtezs7O3t7e7u7u/v7/Dw8PPz8/T09PX19fb2
	9vj4+Pv7+/39/f///////////////////////////////yH5BAEKAD8ALAAAAAAYABgAAAbjwJ9w
	SCwaj8cAclkErABMJiD1QUCjxmknBLFiiVPSyAPpXrFTUUlELnuXgLjc9OlADnJ51oDr4wAnHx93
	ADQzMigGZ0IALgU4hwAiHIN4Li0oBRaLPwA4KgM3MQAYExQMCQCYBRUbnJ4zKgU2eXIoAxIgrk04
	NrEDNTAvlyyZESAqu2CQM7ECM8QoBA8aKsmvvc0qCwMxxQULGhqxykOwsQo4FwUwBREaDePXvDYq
	6bEgrNUqDtbljJ8aMNOmolmsfv864XDwyZrDh9YcJATQIIPFixgzKuDUqZZHj19CihxJMggAOw==
}

image create photo tb_CC_Retrieve -data {
	R0lGODlhGAAYAMY/AAAAAC0tLT4+PkNDQ01NTU9PT1NTU01nRE1oRGNjY1RxSlh1TWpqalt5UHNz
	c3x8fIGBgYGaeZWVlaCgoKysrK6urqnEp7m5uarHqK3Gq7y8vK7HrK3Iq7DHrrDJsLHJsLLJsLPK
	sbTLsrXOtbnOt8bGxrvQucjIyMnax8nbx9TU1M3ey8/fzOPj4+Tk5Ozs7O3t7e7u7u/v7/Dw8PHx
	8fLy8vPz8/T09PX19fb29vf39/j4+Pv7+/39/f7+/v//////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////yH5
	BAEKAEAALAAAAAAYABgAAAf+gECCg4IAhocAhIqLhSkoKBELiYyUQAAgFhwNB5OViwAmGxubnZ6W
	hyQbGKSHppYrHyMeGQ21CKWeACsiIbQNt6aIhisYHb/CuJYGP8w/ProcCgA6OTg3LQa4ADEFP9Y2
	NQAsADMyMTAtBRXaPy4DPeA1NAHm5+kUJ+w4LgU8NDPlzqEbMEFFPkUAfvDYN2BHQBgv0klQ4eIg
	oYQ4MroQgONcRAIQSrioyG7hPgYDbEQswKBEiX0WB2Hcl+DHhQIzCkgo4eAlSYQKXdTcp6IABZEu
	HoyMWaidA28Z97mImvTnxR8P2o3cynXkA6aWHGgYS7as2QTJkKkV5qqt27cEcBUFAgA7
}

image create photo tb_CC_yourmove -data {
	R0lGODlhEgASALMLAPv7+wAAAP+9AJlmM8yZM2ZmZv///5mZM2YzM8zMZv//M////wAAAAAAAAAA
	AAAAACH/C05FVFNDQVBFMi4wAwEJAAAh+QQJFgALACwAAAAAEgASAAAEgnBJiaqdeNakeq8ZdXBe
	iWTIWCYpeWrJUQ3C0B2fNiKKECsqz6s1AAQGB0DKJEo4n86SYqgSCKQKgiJRKMhGB0KCcKABrwWD
	odDSlggDbSFhOFCiV2x63UwIxFJ7c309XlcHe3wUCE6CTmpqBSgVc5AxdJIhC1wGMQeQmZqXC11d
	BxEAIfkECRYACwAsAAAAABIAEgAABH9wSYmqnXjWpHqvGXVwXolkyFgmKXlqyVENwtAdnzYiihAr
	Ks+rNQAEBgdAyiRKOJ/OkmKoEgikCoIiUSjIRgdCgnCgAa8Fg6HQ0pYIA20hYThQoldset1MCMRS
	e3N9Cl4EZF5qfBQIXGpOiooFKAhzijEjiyEHXQeekiGhXZ0RACH5BAkWAAsALAAAAAASABIAAAR9
	cEmJqp141qR6rxl1cF6JZMhYJil5aslRDcLQHZ82IooQKyrPqzUABAYHQMokSjifzpJiqBIIpAqC
	IlEoyEYHQoJwoAGvBYOh0NKWCANtIWE4UKJXbHrdTAjEUntzfV1dBwdeanwUCHuKj2oFKF4jajGV
	kiESl4mRmiGFXhEAIfkECRYACwAsAAAAABIAEgAABH9wSYmqnXjWpHqvGXVwXolkyFgmKXlqyVEN
	wtAdnzYiihArKs+rNQAEBgdAyiRKOJ/OkmKoEgikCoIiUSjIRgdCgnCgAa8Fg6HQ0pYIA20hYThQ
	oldset1MCMRSe3N9Cl4EZF5qfBQIXGpOiooFKAhzijEjiyEHXQeekiGhXZ0RADs=
}

image create photo tb_CC_oppmove -data {
	R0lGODlhGAAYAOevAAAAAAUAAAYAAAYBAAcBAAcCAAcCAQUFBScCACgDASkDASoEATEMBTMNBjMO
	BjQOBhoaGh0dHUsSD3MCAnIDAk4VDXkCACYmJncEAk8WEHYHA4ADAHwFAoEEAYUDAYEFAnkKBIYE
	AW4PDFUbEH0JBCwsLFYcE4QIBIkGAi0tLYUJBHASD34OBoMMBVofEpAIA40KBJAKBJMJBJYIA4oO
	BpcJA5ENBV4kFo4QB4oSCJkLBYYUCpUOBnscFJ8NBYoXCnwdEZ0PBqINBZgTCKMOBqIPBp0SCJcV
	CZYXCo4bDKMUCaYTCYMjFZsZC5IfDoUlFJscDaMZC5gfDpIiD58cDKoXC6wYDa4ZD64aDq4aD6Mg
	DpgnEpsmEaoeE0dHR6IjEJ8mEZspFJEvGZIwGrAiFaArE54tFLMlGawpHrYmGaQwFrcmGqUxFrgn
	GrcoGrcpG1NTU7IwIL1BNb9CNcFCNsBEN2hoaMNEN8REN8NFN75RRsNXSMlbULtiVcxdUM5dUM5e
	UM5fUMxgUc5gUMBnVsNxYMVzYclxZs9zZs11Z9V0Z9Z0Z9d1aNR3aMp7b9d2aNZ3aNd3aM1+cMyG
	eM+HetaHfNqJfdiLfd2Kfd2Lfd6Lfd+LfaysrNmbkNudkd+ckOCdkeKdkeOdkeKekeSekduiltyj
	l9+qoeGroeOroeOtouWsouWtouW3rcfHx///////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////yH5BAEKAP8ALAAAAAAYABgA
	AAj+AP8JHEiwoMGDCBMqXMhwIICHEBs6NHBjDBs1YlwUiNAQwAMzhky1alWqUJgGKRYCcFCGEipV
	rFalOjWJCwM4CglsIeQJ1ChSokJ96tRnCgFOCAGMACPpUiZNmzRhslTJkRQTdpI++ZKoEaRIjxgt
	UoToEBQmF14dBOBEyx5BgwYFAvTHDx89TX4cUGsQQBIqcerkwYPnDp05ctAc2bF3LRAkUci8cdNm
	TZozXYzg6JF2bYUcQ5RUwZLlipUlQWy0yGCHr8EBLGjwCFKEiBAfOmKcACHAleuCEBaQUAFDRo0Z
	L1B8wJCgtcISCjRw6BDCwwYLFBB4efX7IBwBEkQgTJiwQkKA1t0RcrJz4cCBC3Z8p1fIvf58ifjz
	69+vPyAAOw==
}

image create photo tb_CC_draw -data {
	R0lGODlhFAAUAPdyAP//////AP8A//8AAAD//wD/AAAA/wAAAP/GGP/OMf/OOf/WWv/GIfe9If/G
	Kf/OQvfGQv/OSv/WY//ee//ehN6lGPe9Kf/GMfe9Mee1Of/OUv/Wa//Wc//ejP/nrcaMEK17EMaU
	Kee1Qv/OWvfOc//We//elLWEIdacKeetOee1Uv/WhKWMWvfWlP/enO/Wpf/ntbV7EL2EGLWEKdal
	Sue9c//epa1zELV7GK1zGJxrGLWMSr2UUsacWtata+e9e/fetYxaEKVrGJRjGK17MbWEOcalc+fG
	lPfWpf/erYxaGJxrKYxjKaVzMa17OZRrMbWEQr2MSqV7Qq2ESsacY6WMa5RjKZxzQq2EUtala5x7
	Utate8ale+/OpYxaIaVzOaV7SntKGIRaMYxjOa2EWrWMY72Ua9athK2Ma961jHNCGIxaMaVzSpRr
	Sq2EY6V7Wr2chKVzUv///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEA
	AAAh+QQJFAByACwAAAAAFAAUAAAI8ADlCBxIsKDBgwgTKlwo543DN2QYymnDBYZFi20yGqQCRYqU
	M2nOlCljpotFLm7QvIEjkIKEDRx47MjiwsaWOGQ8JNmZBIjACRoWwCyxooMJF0mOjGnhoukLgRse
	aBjxkkMJCkdtIBnzo0OHFgIjKHgQIehLokZrsulRooRABg4ujC1blcSTGiZsGIkiRqAMBHATKChL
	dQOJLz2OXhkIRscHwHLJamiiggPiDj4GYoEwQ0iMBg4ShIAgIgyNDU7WrCEoRgmGEzlwNLAwJEUG
	NUSKsDg4ZQkDIUIqNFCCwkqVhV6YgAhyQ4cWidCjS08YEAAh+QQFFAByACwAAAAAFAAUAAAI7wDl
	CBxIsKDBgwgTKlzIMOGbh2/INGzDBYZFi20yGqQCRYqUM2nOlCljpotFLm7QvIEjkIKEDRx47Mji
	wsaWOGQ8JNmZBIjACRoWwCyxooMJF0mOjGnhoukLgRseaBjxkkMJCkdtIBnzo0OHFgIjKHgQIehL
	okZrsulRooRABg4ujC1blcSTGiZsGIkiRqAMBHATKChLdQOJLz2OXhkIRscHwHLJamiiggPiDj4G
	YoEwQ0iMBg4ShIAgIgyNDU7WrCEoRgmGEzlwNLAwJEUGNUSKsDg4ZQkDIUIqNFCCwkqVhV6YgAhy
	Q4eWhtCjFwwIADs=
}

image create photo tb_CC_envelope -data {
	R0lGODlhGAAYAKUyAAAAACAgIExIPG5mWHJsWn50ZH94ZIB4ZoF5ZoZ9aIh+aoh/a4uBbJCFb5WJ
	c56dlbmtk8Kyk8Szk8S0lcW1lsm5lsm6mMK/uM+/nNPCntTEoMnIxN7Ko+DOqOzYrfDbs/Xesvbf
	s/nisvrjs/zmtf/ot//ouP/puv/qvf/rwv/tx/3uzfXu7vXx8frz7Pj07fX19fz16v//////////
	/////////////////////////////////////////////yH5BAEKAD8ALAAAAAAYABgAAAarwJ9w
	SCwaj8ikcslsIgEBgHRKXQIusKx2+wAoAbADSwVTqVwq0iDjTYJViNbq9VKNCCNL+1lWFWJmJQQq
	H3pfZSgNAlBUjXtDYCkLKldbljBdRWAMKiBgYmRmaGpsmhsREhJvcXN1d3mPQo19f4GDhbGaiA0E
	WQQKJB4VuUSRkyoGBiUmCR3Dh5wgJyIiJiEcDhjEkKepEhERExMUGhDbkI6NTuvs7e7v8EVBADs=
}

image create photo tb_CC_book     -data {
	R0lGODlhGAAYAOewAAAAAAEBAAICAAQDAAcGAQsIARURAxYSAxoVAyggBSoiBiwjBi0lBzAmBjEo
	BzkuCDswCD0xCDMzM0E0CEM2CUk7Ck0+CkhISF1LDF5MDUtLS2BODWZSDmlVEWxXD1ZWVm5ZD1hY
	WHJcD3NdEF5eXndgEF9fX3pjEWNjY35lFWdnZ4JpFINqEoVrEoduFYluEm1tbYpwE25uboxxE45y
	E5B0E5F1FHR0dJN3FJR3FpV4FJd5FHh4eJh7FZp8FXp6epx+FZx/GJ5/FX5+fqGCFqODFoGBgaWF
	FqWGGaaGF6OGIYWFhaiIF6qJF6iJHq2MGK+NGK+NG7GPGLCQILOQGLKQHbSSGZCQkLaTGbaUHriU
	GbqWGbuXGpWVlb2ZGpaWlpeXl7+aGsGcGsOdGsSeG8agG8ihG8qjG8ukHM2lHM+nHNGoHKamptSr
	HaioqNatHdiuHduxHq+vr9+0HrGxsda2ROG3JuG4KrW1teK6MeK7M+O8NOO8NuO9OOO9Orq6uuS+
	O+S/P+TAQeTAQ+XCSOXDSsLCwsPDw+fGUufHWMXFxejIW+jJXejKX+nLYurMZ+nNa+rNacvLy+rO
	a+rObevPbs7OzuzSd9LS0u3Ufu3VgO7Whe7Yi9ra2tvb29zc3PDent7e3t/f3+Dg4OHh4eLi4uTk
	5OXl5ebm5urq6uvr6+/v7/Ly8vPz8/n5+f39/f//////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////yH5BAEKAP8ALAAAAAAYABgA
	AAj+AP8JHEiwoMGDAwEoXMiQIcJ/CSIN0mMnjpoxWjJmFANEwUEAexj1OcPliZAaL17UqNGjhggH
	Bw9QIrSGjJUkPWKkTLmjhIWPWyjxQcMFChEbO1/M2AGCAwCDACgValMGCxMfM1Lq1FHigZEMBQFs
	acQnTRgpRXQkjeEDBAUNV8JCIvTGzJYmQGgkxXECwgcVEggCQCNSjRgqR3YkfdFjRIULgZ4mnIRo
	DkmTKHfSYBFBhYwTkv8BKONID1WrWJO2tRACkIHQAOokumMWrdqkLSZouBEEthpQnDJdqvQoUZ89
	yPfYsZKBhKDXAwls8rChuvXr1TGg4MEk9D8EgUZ8mLjxhY4cRZb+GDokCVOnLnkWeD8Ap8cQU6ZI
	iRLF6lWr/27gAQMTARQ0gRlwcHGEJ6mssgoqoZCiXyk/+MGAdwIBUEAKSkyxhRhgfHKKKq64sgQb
	iwjwEEMr5FBFFl5oMkoqizSAIUIMdeACElE4McBDKzoE5JBEFvlQQAA7
}

image create photo tb_CC_database -data {
	R0lGODlhGAAYAMZnAAAAAAEBAQICAgMDAwUFBQYGBgcHBwgICAwMDA4ODhERERMTExUVFRYWFhkZ
	GRwcHCEhISIiIiUlJScnJy0tLS8vLzIyMjU1NTY2Njw8PEBAQEFBQUREREVFRUZGRkdHR0hISE5O
	Tk9PT1JSUlNTU1RUVFVVVVlZWVtbW1xcXF9fX2JiYmZmZmdnZ2hoaGlpaWpqamtra2xsbG5ubm9v
	b3BwcHFxcXJycnNzc3V1dXd3d3h4eHl5eXp6ent7e3x8fH19fX5+fn9/f4CAgIGBgYODg4WFhYeH
	h4iIiImJiYqKiouLi4yMjI2NjY+Pj5CQkJKSkpSUlJWVlZeXl5iYmJmZmZubm52dnZ6enp+fn6Cg
	oKKioqOjo6SkpKampqenp6urq66urrGxsbq6uru7u7+/v8LCwv//////////////////////////
	/////////////////////////////////////////////////////////////////////////yH5
	BAEKAH8ALAAAAAAYABgAAAf+gH+Cg4SFhoeEFhsHAQEGGBKIhg0fOUxSUE5KQisZCpJ/EwA7WldV
	UU9NSUZEQCkAAIgAUV1ZVlOZS0dFQz87LbGGFjZfW6aoqqxBPTo4IRSGA1y1t7m7vTs5NTAChgJe
	xqepq0TLzTMyAYYB1LhOury+2jI5wYQEWVviyeXMODM0gBly8AMLF2vxstXQIcODvUEFbgyJIoYK
	EmU+fhA5wgIEhIeCCECpMWMIGDNlyIwZE8aFiQsRTID8gwBIFB4oULy4kQOHjBWwRqjoMBMAjiFP
	sPwooQEWABEudqzwWPQJSZMoVbJ0CbPETAUPbubc2fNnUBUKZv5JwCHp0qYpsKBKFSULAIMgJ1Ou
	bFmiAixQsBacsNEzBgmnagshXpwYlOPHkCM7DgQAOw==
}

image create photo tb_CC_tablebase -data {
	R0lGODlhGAAXAMZAAAAAACc/V0dHRzFObEBTaFhYWFNrg1ZuhXNzc2Z7kXKGmI2NjYGTpK6urra2
	tre3t7i4uLm5ubu7u7y8vL6+vr+/v8HBwcLCwsPDw8TExMXFxcbGxsfHx8nJydDQ0NLS0tPT09XV
	1dbW1tfX19jY2NnZ2dra2tvb29zc3N3d3d7e3t/f3+Dg4OHh4eLi4uPj4+Tk5OXl5ebm5ufn5+jo
	6Onp6erq6uvr6+zs7O3t7e7u7u/v7/Dw8PHx8fPz8/X19f//////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////yH5
	BAEKAEAALAAAAAAYABcAAAfjgECCg4SFhoeIiYUAjI2Oj46LCgUMB5aXlpSXBACLBgUJA6KjoqCj
	AZ2EAJ+hpKOmoqiLCAW1tre4AqmDAA0FHh8gISMlJigqBS0vMTITu4K9BcHDJMYqKwUvMDI0FM9A
	0cIj1SgpKy0F2zQ13rO477e6i74i1SfmLS4wBTM1NzkWvkWzh0+fjAL+cOi4INCXiXsrWBicUeCG
	Qh4ZBNKCB0+eKl8pVEiEEaOfjQI6ePTwsaFhAZEulpnEUWDHyh8cBC4Q4OABhAgSJlCoYEEABg0b
	OHQQCKnpI0VQo0qdSrUqokAAOw==
}

image create photo tb_CC_engine -data {
	R0lGODlhGAAYAOfwAAwMDBAQEBIQEBISEhQSEhQUFBYWFhgYGBoaGhgbGxwaHBwcHB4cHhweHB4e
	HiAgICIiIiQiIiQiJCQkJCgmJigoKCooKCwqLCwsLC4sLiwuLjAsMC4uLjAuMDAwMDAwMjgwODQ0
	NDY0Njg0ODY2Njc2Nzg2ODo4Ojs4Ozw4PDo6Oj04PTs7Ozo9Oj07PTw8PD09Pz88Pz8+P0A/QEFB
	QUFBQ0NAQ0JBQkRARERCQkNDQ0NDRUZDQ0VFRUVFR0dHR0lHR0lJSUpJSktJSUtJS0tLS01LS0xM
	TE9LS01NTU9NTU9NT01PTU5PTlFOTk9PT1FPT1FRUVNRU1NTU1RTVFVTVVdTV1VVVVZVVldVV1dX
	V1lXWVpZWltZWVtbW1xbXF1bW11dXV9dXV9dX2BeYF9fX2BfYGFhYWNhYWVjY2VlZWZlZmdlZWdl
	Z2dnZ2hnaGlnZ2lnaWtpa21pbWxqbG1rbW9rb29sb29tb3FvcXRvcnRydHNzc3V0dnZ0dnV1dXh2
	eHd3d3h3eHl5e3x5eX55enx7fH98f4B+gIKAgoOAg4SChIiChoiEhomGiYqGiIyGiIuIi4yIio6I
	io2KjY6KjI6KkI6Kko+Mj5CMkpCMlpKOlJSQlpaSlpaUlpiUmJiWmJiWmpmWmZqWmpmYm5qYmpqY
	nJyYnJyanp6anp6coKCcoKKeoqCgpKSgpKago6SipqWip6aipqWkp6akpqakqKikpqikqKqmqKyo
	qqyorK6qrK6qrq6ssLCssLCusrGusbCwtLKwtLSwtLSytra0uLi0uLq2urq4vLy4vL66vr66wMC8
	wMK8wMK+wsDBxcLBxcXBxcfBxcfDx8nDx8nFycvFycrGysvHy8rIzM3Hy8/Jzc/Lz9HNz9PP0dXR
	09XR1djU29nV2drY3N3Z3d/b3+Hd4ePf4+Xh4+fj5+nl5+nl6e3p7e/r7+/t8ffz9///////////
	/////////////////////////////////////////////////////yH5BAEKAP8ALAAAAAAYABgA
	AAj+AP8JHDhwT5Z/R0bgIMiwoUASARhcCECRABWHDNMtoYiIC8UABQqcwCiw3Dt3ngIsaIdOnB4D
	FDuQ/Bdr3TlrRPqc00bt0ccAHnQsOMRwTAJl5MR522YtGrMxH0NSzEAw3CxB575149lMmbFaN4SA
	KvCTxUB259QtrQZN2bFhvXTJQtbqRlQeJc1944ZNGrNkxX7twuVK1ahOkSYEMCCDIKBp1J55FUYK
	UapVqD5psgSJDswGDP0sS0bMFyYMCDxQ4nRJUqM1Bz5yICjKWLBeuMbADJCo0iNFhLT8DBBCoLls
	vXLZYoUlwqIAM3ghCsSnzU8HQf4dG7frVmFTdS7RDCLr7E+eOm6iqEBAAcgU47ZWnfq0ydEbAwAC
	3LIDJ00ZL1eIkAQMZAiUziqhcJLJJIy8YkYAawDDxhlgaCHFEyqgUKBAvEhRwhe/GRIILNfQooYY
	W1QBhQ82SKCAQ04UQh0ecqjxXxZSKAEEBgcMEMALDYHDRx5zuIFGGFtMAUURPZBAVgBROFRKHP2V
	0YUVUSDxgw4xiACBAFFi1IQRIdDAxBND7NCCCSR8UEEcMyEkUA4+1LBCAQNYoMEdcRKUwwsnpFDA
	Ai702RAIGzwQZ0AAOw==
}

image create photo tb_CC_delete -data {
	R0lGODlhGAAYAOfyAAAAAAgICA8PDxMTExYWExsbGxwcHB4eGiEhISMjISQkJCYmICkoIyoqIisr
	IzAwJzExLjQ0KzU0MTU1LDc3LTg3NDw8Mj4+Mz8/NEBANUFBNUBAPkFBNkJCN0JCOkNDN0JCQkRD
	OkREOEVEQkVFP0dGPkhHPUlJPElJSUxMSU5NRU5OQE5OQU5ORVFRQ1FRRlJRRlNSRlRURVRUS1VV
	RlRUUVZWR1dWSldXSFdXSldXS1hYSVlZUVpaSltbTVtbUV1cT1xcVV1dVF9fT2BgUmFhU2JhVWJi
	UWVkVmZmVGhoVmlpV2pqWGppXmtrX2xrXW1sXG1sXW5tXW1tYW9vZ3FwYHFxXXFxXnR0Z3V1a3d2
	ZXZ2aXZ2a3h3ZnZ2dnp5aHh4dXp6ZXt7ZXx6aXp6cXt7c3x8bX18a3x8cn19bX59d4B+b4B/bX9/
	dIKCeISEcIWFboWFdoWFe4eGc4uJdoqJfoqKgIyLd46MeI+NeZCPepCPipGRgpGRhZOSfZCQkJKR
	iZOTipSTipWUhJmYgpqYg5iYjpmYk52di5+ei6GfiJ+flqOhiqGhlKOik6OjmqSkk6WllKemjqim
	j6qpk6qpmKyqkqqqnqqqo62sk6ysnK+tl6yspq6to6+unbCvlrGvlrOxm7GxorOypLWzmrOzpbOz
	qLa1m7i2nLi2obe2prm3nbm4nbi3pra2srq4prq4qL27obu6rbu7s728rb69p8C+o8C/scHAtcLB
	r8HBtsTCqcLCt8XErMTDtsPDvsPDw8bFucbFvcjIw8rJvMzLtczLvs3Mv87NwNDOutDPw9HQwdHQ
	wtPRvtLRx9PSytXTwdPTydPT09bVw9bVxNjX0NnYzNnZztrZztvaz9va0dvb1Nzb0t/e0d7e3OLh
	2uLi3+Xk2ebm5urp4+np6Orp5uvq5fHx8PLy7vLy7/T08Pb18vn59/r6+Pv7+vz7+v39/P39/f//
	/////////////////////////////////////////////////////yH+FUNyZWF0ZWQgd2l0aCBU
	aGUgR0lNUAAh+QQBCgD/ACwAAAAAGAAYAAAI/gD/CRw4EIDBgwQTKvwHwIAXcdKA/UFhcCHBgyZe
	gTtXDp05XDdgIFQIYFIsW4ygoElBIgSVYKeihJKkB0BCAJSKJYPWSdCIBBIYHIiRCVAuUJb82BwY
	YFkxat2QcdqjJkgJJFrW1CJ1ipSipQIBWFunDVs4ZdGIqUr1SRGrVah2baIDlmElV+zaqft2LRu0
	Zrts9Zp2TNaYKnUHEPL0yxs5d/DivWOXbpy2W4O6SPFRFwAQP45aVdv2bJgwWrAS4bmD58sTFSRB
	lFnkjJsxZr5A6S7E5kyTDXXDUhBQAcyhOqMuMZqTx0gNCAAcBGdoRYeHBQgKAFBwEACBBg8wpkwH
	EOZHHC6GsrxowyTDERkXaERwMR6OED5uMJFpYcdMByI9WMDCBDLU94MmcszyyAyB9PGfEhww8QET
	BkIihy6iOCEKIjK8ccWEExoYiRy8ZLhhhx9KSCFJcPyAyIUmcughiCveJMYPFmKooYwpfjDEeEng
	6IaOJ87IxAk4TMdQDmlsYUojU5Qi4xIa2CCCkmEZxMMOK2BRBAsnnDCSRVl2191CAQEAOw==
}

image create photo tb_CC_outoftime -data {
	R0lGODlhEAAQAMZJAAAAABcQAR0UASofCzAkDD0uDzIyMj09PUVFRUZGRkhISElJSUpJSmZNGldX
	V2VlZW1tbXR0dKd+KoODg4iIiJiYmMuZNJ6enqysrMircK6urrO0tLW0tOuxPbW2tri3t925b8LC
	wu7AY8nJyczMzM7OzfDMgdHR0tPT0/bLwvTdrOfn5+fo5+vq6+vr6+zr7O3t7O3t7e7t7e3u7e7u
	7e/u7u7v7+/v7+/v8PDw7/Dw8PHx8PHx8fLy8vLy8/Lz8vPz8/T09PX19Pb29vf29/f39/n5+fr5
	+fv7+///////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////yH+
	FUNyZWF0ZWQgd2l0aCBUaGUgR0lNUAAh+QQBCgB/ACwAAAAAEAAQAAAHkYB/goOEhYYAiIiGgwAL
	JC8WHRIGAIcUPUM/BSImIBGVhAxCQ0VDAx0dKhkHhAAlQ0ZIRwSoHYmgADlESElIArUASSm4PQ9H
	SEYBDajBw4IAMkGkQxgGFzPNuCM7PkA+OiEINNmDCig2NzUxLTArACnOzxMnLjwQOCwct60JGh4f
	Gyo4IFfoVqV38RYxSqSwYSAAOw==
}

image create photo tb_CC_message -data {
	R0lGODlhDAAQAKUxAAAAACAgIG5mWHJsWn50ZH94ZIB4ZoF5ZoZ9aIh+aoh/a4uBbJCFb5WJc56d
	lbmtk8Kyk8Szk8S0lcW1lsm5lsm6mMK/uM+/nNPCntTEoMnIxN7Ko+DOqOzYrfDbs/Xesvbfs/ni
	svrjs/zmtf/ot//ouP/puv/qvf/rwv/tx/3uzfXu7vXx8frz7Pj07fX19fz16v//////////////
	/////////////////////////////////////////////yH+FUNyZWF0ZWQgd2l0aCBUaGUgR0lN
	UAAh+QQBCgA/ACwAAAAADAAQAAAGbsCfcEgkAo7I4xDgwFQqFMrlARACXgKRp8NpZKq/62iQGiE2
	E/A1JRokSiCJ+tVKkQakktz6SrlSLwUhEHN+gIKEfC8qMGQmEYUsBAwpH5B8KwcpJwoplz8BLwYp
	pCgLiWEWL6usGmBhSUhFs0NBADs=
}

image create photo tb_CC_online -data {
	R0lGODlhIAAQAKU3AAAAAA8PDV1ZT2JeVGRgVmVgVmplW2xoXnBsYnJtY3h1a314bn56cIB9dIF9
	c4qFe4uHfYuHfoyJgY2JgZOOhJeTipiTiZyXjZ+ck6CdlKeimKaim6eknqqnoLGtpLKwq7Oxqrez
	qry5sr67tcTCvcbCusXDvcjFv87Kw9HQzOHf2+Lh3ePh3ejn5Oro4+vq5uzr6O7s6vDu6/Dv7PLw
	7fPy8Pn5+P///////////////////////////////////yH+FUNyZWF0ZWQgd2l0aCBUaGUgR0lN
	UAAh+QQBCgA/ACwAAAAAIAAQAAAGj8CfcEgsGo/IpHLJbDqLAMAv+kxGAZYGoKSlVocAR4jk0pYv
	oonUem0DGqtZpwyQNT42U9e9Brj+gIA0Lw8wWjENGDUtLIGAfQ2Rkg0KCiMgCyoKACkNFCcak5N9
	fFEKEhsJKJscDQwZDgela0kBBREIHrIVDQMGArRfAAEBFgQAEHtfR8Q/AcHL0dLT1EVBADs=
}

image create photo tb_CC_offline -data {
	R0lGODlhIAAQAKU4AAAAAA8PDV1ZT2JeVGRgVmVgVmplW2xoXnBsYt9CHnJtY3h1a314bn56cIB9
	dIF9c4qFe4uHfYuHfoyJgY2JgZOOhJeTipiTiZyXjZ+ck6CdlKeimKaim6eknqqnoLGtpLKwq7Ox
	qrezqry5sr67tcTCvcbCusXDvcjFv87Kw9HQzOHf2+Lh3ePh3ejn5Oro4+vq5uzr6O7s6vDu6/Dv
	7PLw7fPy8Pn5+P///////////////////////////////yH+FUNyZWF0ZWQgd2l0aCBUaGUgR0lN
	UAAh+QQBCgA/ACwAAAAAIAAQAAAGosCfcEgsGo/IpHLJbDoBAGEiIaX+oM4r9OKITqtXUxerBDxE
	pVe3+r2qMSNKtAiFOlg0j3o+bQNmDiA3J2NkAC+ILzUwEDFrYEIAMg4ZNi4tiXMADg4LCyQhDCsL
	cz9tVyoOFSgbnJyadQsTHAoppGxWAB0ODRoPB3WlQwEFEggfwLiRFg4DBgLCRwABARcEXlZfABGF
	WdSQbQHRWeTl5udZQQA7
}

image create photo tb_CC_spacer -data {
	R0lGODlhAQAYAIAAAP///////yH5BAEKAAEALAAAAAABABgAAAIEjI+pVwA7
}

#----------------------------------------------------------------------
# Correspnodence Chess functions
namespace eval CorrespondenceChess {

	# wether the console is already open or not
	set isOpen   0

	# default Database
	set CorrBase        [file nativename [file join $scidDataDir "Correspondence.si3"]]

	# incoming PGN files
	set Inbox           [file nativename [file join $scidDataDir "Inbox"]]
	# outgoing PGN files
	set Outbox          [file nativename [file join $scidDataDir "Outbox"]]

	# use internal xfcc-support
	set XfccInternal     1
	set xfccrcfile      [file nativename [file join $scidConfigDir "xfccrc"]]

	# external fetch  tool (eg. Xfcc)
	set XfccFetchcmd     "./Xfcc-Receive.pl"
	# external send tool (eg. Xfcc)
	set XfccSendcmd      "./Xfcc-Send.pl"

	# email-programm capable of SMTP auth and attachements
	set mailer           "/usr/bin/nail"
	# mail a bcc of the outgoing mails to this address
	set bccaddr          ""
	# mailermode might be: mailx, mozilla, claws or mailurl
	set mailermode       "mailx"
	# parameter for attaching a file
	set attache          "-a"
	# parameter for the subject line
	set subject          "-s"

	set CorrSlot         -1
	set LastProcessed    -1

	# current number in game list
	set num              0

	set glccstart        1
	set glgames          0

	#----------------------------------------------------------------------
	# Open a File select dialog and returns the file selected
	# $i: title text after "Scid Correspondence Chess: Select "
	# $filespecs: the specs of the file (currently ignored)
	#----------------------------------------------------------------------
	proc chooseFile {i filespecs} {
		set idir [pwd]

		set fullname [tk_getOpenFile -initialdir $idir -title "Scid Correspondence Chess: Select $i"]
		if {$fullname == ""} { return }

		return $fullname
	}

	#----------------------------------------------------------------------
	# Set the default correspondence base to the file selected.
	# Open Database works on that file, but in principle every other
	# DB of the type "Correspondence" can be used by just loading by
	# hand before using the CC features.
	#----------------------------------------------------------------------
	proc chooseCorrBase {} {
		global ::CorrespondenceChess::CorrBase

		set filetype { "Scid databases" {".si3" ".si"} }
		set CorrBase [chooseFile "default correspondence chess DB..." $filetype]
	}

	#----------------------------------------------------------------------
	# Choose the path where to fetch Xfcc-games to. All pgn-files in
	# this path are used as input so this offers a way to incorporate
	# cmail games as well.
	#----------------------------------------------------------------------
	proc chooseInbox    {} {
		global ::CorrespondenceChess::Inbox

		set filetype { "All files" {".*"} }
		set Inbox [file dirname [chooseFile "default correspondence chess Inbox..." $filetype]]
	}

	#----------------------------------------------------------------------
	# In Outbox a pgn-version of the game after the users move is
	# stored. This includes all variations and comments! For
	# incorporation of cmail they need to be stripped.
	#----------------------------------------------------------------------
	proc chooseOutbox   {} {
		global ::CorrespondenceChess::Outbox               \

		set filetype { "All files" {".*"} }
		set Outbox [file dirname [chooseFile "default correspondence chess Outbox..." $filetype]]
	}

	#----------------------------------------------------------------------
	# Xfcc fetching is done by an external utility, currently perl as
	# this eases up XML parsing a lot. Having it natively would be
	# desireable though. On the other hand an external utility could
	# also fetch cmail games or whatever other source as it will be
	# transparent to scid. It just has to write the CmailGameName extra
	# tag within the header to a unique ID.
	#----------------------------------------------------------------------
	proc chooseFetch    {} {
		global ::CorrespondenceChess::XfccFetchcmd

		set filetype { "All files" {".*"} }
		set XfccFetchcmd [chooseFile "default correspondence chess Fetch Tool..." $filetype]
	}

	#----------------------------------------------------------------------
	# Xfcc send utility. Similar to fetch but just the other way round
	# ;)
	#----------------------------------------------------------------------
	proc chooseSend     {} {
		global ::CorrespondenceChess::XfccSendcmd

		set filetype { "All files" {".*"} }
		set XfccSendcmd [chooseFile "default correspondence chess Send Tool..." $filetype]
	}

	#----------------------------------------------------------------------
	# Check for xfccrc
	#----------------------------------------------------------------------
	proc checkXfccrc {} {
		global ::CorrespondenceChess::xfccrcfile

		if {![file exists $xfccrcfile]} {
			if {[catch {open $xfccrcfile w} optionF]} {
				tk_messageBox -title "Scid: Unable to write file" -type ok -icon warning \
					-message "Unable to write options file: $xfccrcfile\n$optionF"
			} else {
				puts $optionF "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
				puts $optionF "<xfcc>"
				puts $optionF "<server>"
				puts $optionF "   <name>ServerName</name>"
				puts $optionF "   <uri>http://</uri>"
				puts $optionF "   <user>UserName</user>"
				puts $optionF "   <pass>PassWord</pass>"
				puts $optionF "</server>"
				puts $optionF "</xfcc>"
				close $optionF
			}
		}
	}

	#----------------------------------------------------------------------
	# Check for the default DB, create it if it does not exist.
	#----------------------------------------------------------------------
	proc checkCorrBase {} {
		global ::CorrespondenceChess::CorrBase

		if {![file exists $CorrBase]} {
			set fName [file rootname $CorrBase]
			if {[catch {sc_base create $fName} result]} {
					tk_messageBox -icon warning -type ok -parent . \
						-title "Scid: Unable to create base" -message $result
			}
			# Type 6 == Correspondence chess
			sc_base type [sc_base current] 6
			sc_base close
		}
	}

	#----------------------------------------------------------------------
	# Check for In-/Outbox directories and create them if not avaiable
	#----------------------------------------------------------------------
	proc checkInOutbox {} {
		global scidDataDir ::CorrespondenceChess::Inbox ::CorrespondenceChess::Outbox

		if {[file exists $Inbox]} {
			if {[file isfile $Inbox]} {
				file rename -force $Inbox "$Inbox.bak"
				file mkdir $Inbox
			}
		} else {
			if {[catch { file mkdir "$Inbox" } result]} {
				if {$windowsOS} {
					set ::CorrespondenceChess::Inbox "$scidDataDir\\Inbox"
				} else {
					set ::CorrespondenceChess::Inbox "$scidDataDir/Inbox"
				}
				file mkdir $Inbox
			}
		}

		if {[file exists $Outbox]} {
			if {[file isfile $Outbox]} {
				file rename -force $Outbox "$Outbox.bak"
				file mkdir $Outbox
			}
		} else {
			if {[catch { file mkdir "$Outbox" } result]} {
				if {$windowsOS} {
					set ::CorrespondenceChess::Outbox  "$scidDataDir\\Outbox"
				} else {
					set ::CorrespondenceChess::Outbox  "$scidDataDir/Outbox"
				}
				file mkdir $Outbox
			}
		}
	}

	#----------------------------------------------------------------------
	# Save the Correspondence Chess options
	#----------------------------------------------------------------------
	proc saveCCoptions {} {
		set optionF ""
		if {[catch {open [scidConfigFile correspondence] w} optionF]} {
			tk_messageBox -title "Scid: Unable to write file" -type ok -icon warning \
				-message "Unable to write options file: [scidConfigFile correspondence]\n$optionF"
		} else {
			# Check all paths etc. exist and contain valid data
			::CorrespondenceChess::checkInOutbox
			::CorrespondenceChess::checkXfccrc
			::CorrespondenceChess::checkCorrBase

			puts $optionF "# Scid options file"
			puts $optionF "# Version: $::scidVersion, $::scidVersionDate"
			puts $optionF "# This file contains commands in the Tcl language format."
			puts $optionF "# If you edit this file, you must preserve valid its Tcl"
			puts $optionF "# format or it will not set your Scid options properly."
			puts $optionF ""

			foreach i { ::CorrespondenceChess::CorrBase       \
							::CorrespondenceChess::Inbox          \
							::CorrespondenceChess::Outbox         \
							::CorrespondenceChess::xfccrcfile     \
							::CorrespondenceChess::XfccFetchcmd   \
							::CorrespondenceChess::XfccSendcmd    \
							::CorrespondenceChess::mailer         \
							::CorrespondenceChess::bccaddr        \
							::CorrespondenceChess::mailermode     \
							::CorrespondenceChess::attache        \
							::CorrespondenceChess::subject } {
				puts $optionF "set $i [list [set $i]]"
			}
			if {$::CorrespondenceChess::XfccInternal < 0}  {
				puts $optionF {set ::CorrespondenceChess::XfccInternal 0}
			} else {
				puts $optionF "set ::CorrespondenceChess::XfccInternal $::CorrespondenceChess::XfccInternal"
			}

		}
		close $optionF
		set ::statusBar "Correspondence chess options were saved to: [scidConfigFile correspondence]"
	}

	#----------------------------------------------------------------------
	# yset / yview: enable synchronous scrolling of the CC game list, ie.
	# all text widgets involved scroll simultaneously by the same ammount
	# in the vertial direction.
	#----------------------------------------------------------------------
	proc yset {args} {
		set w .ccWindow
		eval [linsert $args 0 $w.bottom.ysc set]
		yview moveto [lindex [$w.bottom.ysc get] 0]
	}

	proc yview {args} {
		set w .ccWindow
		eval [linsert $args 0 $w.bottom.id      yview]
		eval [linsert $args 0 $w.bottom.toMove  yview]
		eval [linsert $args 0 $w.bottom.event   yview]
		eval [linsert $args 0 $w.bottom.site    yview]
		eval [linsert $args 0 $w.bottom.white   yview]
		eval [linsert $args 0 $w.bottom.black   yview]
		eval [linsert $args 0 $w.bottom.clockW  yview]
		eval [linsert $args 0 $w.bottom.clockB  yview]
		eval [linsert $args 0 $w.bottom.var     yview]
		eval [linsert $args 0 $w.bottom.feature yview]
	}

	#----------------------------------------------------------------------
	# Generate the Correspondence Chess Window. This Window offers a
	# console displaying whats going on and which game is displayed
	# plus a gmae list containing current games synced in and their
	# status. Xfcc offers quite some information here whereas eMail
	# relies mostly on the user.
	# Additionally this window contains the buttons for easy navigation
	# and in case of Xfcc the special moves availabe (resign etc.)
	#----------------------------------------------------------------------
	proc CCWindow {} {
		set w .ccWindow
		if {[winfo exists .ccWindow]} {
			focus .
			destroy .ccWindow
			set ::CorrespondenceChess::isOpen 0
			return
		}
		set ::CorrespondenceChess::isOpen 1

		toplevel $w
		wm title $w [::tr "CorrespondenceChess"]
		# the window is not resizable
		wm resizable $w 0 0

		# hook up with scids geometry manager
		setWinLocation $w
		setWinSize $w
		bind $w <Configure> "recordWinSize $w"

		# enable the standard shortcuts
		standardShortcuts $w

		frame $w.top
		frame $w.bottom
		pack $w.top -anchor w -expand 1
		pack $w.bottom -fill both -expand 1

		scrollbar $w.top.ysc        -command { .ccWindow.top.console yview }
		text      $w.top.console    -height 3 -width 80 -wrap word -yscrollcommand "$w.top.ysc set"
		button    $w.top.retrieveCC -image tb_CC_Retrieve        -command {::CorrespondenceChess::FetchGames}
		button    $w.top.prevCC     -image tb_CC_Prev            -command {::CorrespondenceChess::PrevGame}
		button    $w.top.nextCC     -image tb_CC_Next            -command {::CorrespondenceChess::NextGame}
		button    $w.top.sendCC     -image tb_CC_Send            -command {::CorrespondenceChess::SendMove 0 0 0 0}

		button    $w.top.openDB     -text  [::tr "CCOpenDB"]     -command {::CorrespondenceChess::OpenCorrespondenceDB}
		button    $w.top.inbox      -text  [::tr "CCInbox"]      -command {::CorrespondenceChess::ReadInbox}
		button    $w.top.delinbox   -image tb_CC_delete -command {::CorrespondenceChess::EmptyInOutbox}

		button    $w.top.resign     -text  [::tr "CCResign"]     -state disabled -command {::CorrespondenceChess::SendMove 1 0 0 0}
		button    $w.top.claimDraw  -text  [::tr "CCClaimDraw"]  -state disabled -command {::CorrespondenceChess::SendMove 0 1 0 0}
		button    $w.top.offerDraw  -text  [::tr "CCOfferDraw"]  -state disabled -command {::CorrespondenceChess::SendMove 0 0 1 0}
		button    $w.top.acceptDraw -text  [::tr "CCAcceptDraw"] -state disabled -command {::CorrespondenceChess::SendMove 0 0 0 1}

		button    $w.top.help       -image tb_help -height 24 -width 24 -command { helpWindow CCIcons }

		button    $w.top.onoffline  -image tb_CC_offline -relief flat -border 0 -highlightthickness 0 -anchor n -takefocus 0


		::utils::tooltip::Set $w.top.retrieveCC [::tr "CCFetchBtn"]
		::utils::tooltip::Set $w.top.prevCC     [::tr "CCPrevBtn"]
		::utils::tooltip::Set $w.top.nextCC     [::tr "CCNextBtn"]
		::utils::tooltip::Set $w.top.sendCC     [::tr "CCSendBtn"]
		::utils::tooltip::Set $w.top.delinbox   [::tr "CCEmptyBtn"]
		::utils::tooltip::Set $w.top.help       [::tr "CCHelpBtn"]
		::utils::tooltip::Set $w.top.onoffline  [clock format $::Xfcc::lastupdate]

		grid $w.top.console                -column  4 -row 0 -columnspan 8
		grid $w.top.ysc        -stick ns   -column 13 -row 0 
		grid $w.top.help       -stick nsew -column 14 -row 0 -columnspan 2

		grid $w.top.retrieveCC           -column  0 -row 0
# Disable the buttons as they do not act as they should. Probably
# reenable them?
###		grid $w.top.prevCC     -stick e  -column  1 -row 0
###		grid $w.top.nextCC     -stick w  -column  2 -row 0
		grid $w.top.sendCC               -column  2 -row 0

		grid $w.top.openDB               -column  0 -row 1 -columnspan 4
		grid $w.top.inbox                -column  0 -row 2 -columnspan 3
		grid $w.top.delinbox             -column  3 -row 2
		grid $w.top.onoffline            -column  4 -row 2

		grid $w.top.resign               -column  6 -row 1
		grid $w.top.claimDraw            -column  5 -row 2
		grid $w.top.offerDraw            -column  6 -row 2
		grid $w.top.acceptDraw           -column  7 -row 2

		# build the table in the bottom frame. This table of text widgets has to
		# scroll syncronously!
		scrollbar $w.bottom.ysc      -command ::CorrespondenceChess::yview

		text $w.bottom.id       -cursor top_left_arrow -font font_Small -height 25 -width 15 -setgrid 1 -relief flat -wrap none -yscrollcommand ::CorrespondenceChess::yset
		text $w.bottom.toMove   -cursor top_left_arrow -font font_Small -height 25 -width 4  -setgrid 1 -relief flat -wrap none -yscrollcommand ::CorrespondenceChess::yset
		text $w.bottom.event    -cursor top_left_arrow -font font_Small -height 25 -width 10 -setgrid 1 -relief flat -wrap none -yscrollcommand ::CorrespondenceChess::yset
		text $w.bottom.site     -cursor top_left_arrow -font font_Small -height 25 -width 10 -setgrid 1 -relief flat -wrap none -yscrollcommand ::CorrespondenceChess::yset
		text $w.bottom.white    -cursor top_left_arrow -font font_Small -height 25 -width 15 -setgrid 1 -relief flat -wrap none -yscrollcommand ::CorrespondenceChess::yset
		text $w.bottom.black    -cursor top_left_arrow -font font_Small -height 25 -width 15 -setgrid 1 -relief flat -wrap none -yscrollcommand ::CorrespondenceChess::yset
		text $w.bottom.clockW   -cursor top_left_arrow -font font_Small -height 25 -width 10 -setgrid 1 -relief flat -wrap none -yscrollcommand ::CorrespondenceChess::yset
		text $w.bottom.clockB   -cursor top_left_arrow -font font_Small -height 25 -width 10 -setgrid 1 -relief flat -wrap none -yscrollcommand ::CorrespondenceChess::yset
		text $w.bottom.var      -cursor top_left_arrow -font font_Small -height 25 -width 3  -setgrid 1 -relief flat -wrap none -yscrollcommand ::CorrespondenceChess::yset
		text $w.bottom.feature  -cursor top_left_arrow -font font_Small -height 25 -width 16 -setgrid 1 -relief flat -wrap none -yscrollcommand ::CorrespondenceChess::yset

		grid $w.bottom.id       -column  0 -row 1
		grid $w.bottom.toMove   -column  1 -row 1
		grid $w.bottom.event    -column  2 -row 1
		grid $w.bottom.site     -column  3 -row 1
		grid $w.bottom.white    -column  4 -row 1
		grid $w.bottom.black    -column  5 -row 1
		grid $w.bottom.clockW   -column 15 -row 1
		grid $w.bottom.clockB   -column 16 -row 1
		grid $w.bottom.var      -column 17 -row 1
		grid $w.bottom.feature  -column 18 -row 1
		grid $w.bottom.ysc      -column 19 -row 1 -stick ns

		bind $w <F1>   { helpWindow Correspondence}
		bind $w "?"    { helpWindow CCIcons}
	}

	#--------------------------------------------------------------------------
	# Updates the game list with another event and all data available.
	# This just adds another line at the end of the current list, hence
	# the list has to be emptied if all games are resynced in.
	#--------------------------------------------------------------------------
	proc updateGamelist {id toMove event site white black clockW \
								clockB var db books tb engines wc bc mess} {
		set num $::CorrespondenceChess::num
		set w .ccWindow

		#----------------------------------------------------------------------
		# Layout for the gamelist: Xfcc offers more information about
		# the ongoing game then eMail, hence more is presented to the
		# user. ToMove and featrues use icons for easy reading.
		# Xfcc:
		# ID | ToMove? | White | Black | Event | Site | ClockW | ClockB # | Var | features
		# eMail:
		# ID |         | White | Black | Event | Site |        |         |     |

		foreach tag {id toMove event site white black clockW clockB var feature} {
			# enable additions
			$w.bottom.$tag      configure -state normal
			# make each line high enough for the icons to be placed
			$w.bottom.$tag      image create end -align center -image tb_CC_spacer
		}

		if { $::Xfcc::update > 0 } {
			$w.top.onoffline  configure -image tb_CC_online
			::utils::tooltip::Set $w.top.onoffline  [clock format $::Xfcc::lastupdate]
		}

		if {$mess != ""} {
			set curpos [$w.bottom.id index insert]
			$w.bottom.id image create end -align center -image tb_CC_message
			set endpos [$w.bottom.id index insert]

			$w.bottom.id tag add idmsg$id $curpos $endpos
			::utils::tooltip::SetTag $w.bottom.id "$mess" idmsg$id
		}
		# add the game id. Note the \n at the end is necessary!
		set curpos [$w.bottom.id index insert]
		$w.bottom.id      insert end "$id\n"
		set endpos [$w.bottom.id index insert]
		$w.bottom.id tag add id$id $curpos $endpos
		::utils::tooltip::SetTag $w.bottom.id "$id" id$id

		# ToMove may contain a mixture of text for game results plus
		# several icons displayin the current game status.
		if { (($clockW == " 0d  0: 0") || ($clockB == " 0d  0: 0")) && (($toMove == "yes") || ($toMove == "no")) } {
				$w.bottom.toMove image create end -align center -image tb_CC_outoftime
		}

		switch -regexp -- $toMove \
		"1-0" {
			set curpos [$w.bottom.toMove index insert]
			$w.bottom.toMove image create end -align center -image $::board::letterToPiece(K)25
			$w.bottom.toMove  insert end " $toMove"
			set endpos [$w.bottom.toMove index insert]
			$w.bottom.toMove tag add toMove$id $curpos $endpos
			::utils::tooltip::SetTag $w.bottom.toMove "$toMove" toMove$id
		} \
		"0-1" {
			set curpos [$w.bottom.toMove index insert]
			$w.bottom.toMove image create end -align center -image $::board::letterToPiece(k)25
			$w.bottom.toMove  insert end " $toMove"
			set endpos [$w.bottom.toMove index insert]
			$w.bottom.toMove tag add toMove$id $curpos $endpos
			::utils::tooltip::SetTag $w.bottom.toMove "$toMove" toMove$id
		} \
		" = " {
			set curpos [$w.bottom.toMove index insert]
			$w.bottom.toMove image create end -align center -image tb_CC_draw
			$w.bottom.toMove  insert end "$toMove"
			set endpos [$w.bottom.toMove index insert]
			$w.bottom.toMove tag add toMove$id $curpos $endpos
			::utils::tooltip::SetTag $w.bottom.toMove "$toMove" toMove$id
		} \
		"yes" {
			$w.bottom.toMove image create end -align center -image tb_CC_yourmove
		} \
		"no"  {
			$w.bottom.toMove image create end -align center -image tb_CC_oppmove
		} \
		" ? " {
			$w.bottom.toMove  insert end "$toMove"
		} \
		"EML" {
			$w.bottom.toMove image create end -align center -image tb_CC_envelope
		}
		$w.bottom.toMove insert end "\n"

		# Add textual information to the edit fields
		set curpos [$w.bottom.event index insert]
		$w.bottom.event   insert end "$event\n"
		set endpos [$w.bottom.event index insert]
		$w.bottom.event tag add event$id $curpos $endpos
		::utils::tooltip::SetTag $w.bottom.event "$event" event$id

		set curpos [$w.bottom.site index insert]
		$w.bottom.site    insert end "$site\n"
		set endpos [$w.bottom.site index insert]
		$w.bottom.site tag add site$id $curpos $endpos
		::utils::tooltip::SetTag $w.bottom.site "$site" site$id

		if {$wc != ""} {
			if {[lsearch [image names] $wc] > -1} {
				$w.bottom.white   image create end -align center -image $wc
				$w.bottom.white   insert end " "
			} else {
				puts stderr "$wc does not exist"
			}
		}
		$w.bottom.white   insert end "$white\n"

		if {$wc != ""} {
			if {[lsearch [image names] $bc] > -1} {
				$w.bottom.black   image create end -align center -image $bc
				$w.bottom.black   insert end " "
			} else {
				puts stderr "$bc does not exist"
			}
		}
		$w.bottom.black   insert end "$black\n"

		$w.bottom.clockW  insert end "$clockW\n"
		$w.bottom.clockB  insert end "$clockB\n"
		$w.bottom.var     insert end "$var\n"

		# Xfcc defines noDB, noTablebase no etc.pp. Hence check for
		# false to dispaly the icons for allowed features.
		if {$db == "false"} {
			$w.bottom.feature image create end -align center -image tb_CC_database
		}
		if {$books == "false"} {
			$w.bottom.feature image create end -align center -image tb_CC_book
		}
		if {$tb == "false"} {
			$w.bottom.feature image create end -align center -image tb_CC_tablebase
		}
		if {$engines == "false"} {
			$w.bottom.feature image create end -align center -image tb_CC_engine
		}
		$w.bottom.feature insert end "\n"

		# Link the double click on each field to jump to this specific
		# game easily, then lock the entry field from changes by the
		# user. SetSelection just sets the global $num to the actual row
		# the user clicked. This has to be a global variable and it has
		# to be passed to the ProcessServerResult mascaraded to prevent
		# from interpretation. See also Scids gamelist.
		foreach tag {id toMove event site white black clockW clockB var feature} {
			bind $w.bottom.$tag <Button-1> \
				"::CorrespondenceChess::SetSelection %x %y; ::CorrespondenceChess::ProcessServerResult \$num; break"
			# lock the area from changes
			$w.bottom.$tag configure -state disable
		}
	}

	#----------------------------------------------------------------------
	# Set the global $num to the row the user clicked upon
	#----------------------------------------------------------------------
	proc SetSelection {xcoord ycoord} {
		global num 

		set gamecount $::CorrespondenceChess::glgames

		# remove old highlighting
		foreach col {id toMove event site white black clockW clockB var feature} {
			.ccWindow.bottom.$col tag remove highlight 1.0 end
		}

		set num [expr {int([.ccWindow.bottom.id index @$xcoord,$ycoord]) + $::CorrespondenceChess::glccstart - 1 }]

		# Prevent clicking beyond the last game
		if { $num > $gamecount } {
				set num $gamecount
		}

		# highlight current games line
		foreach col {id toMove event site white black clockW clockB var feature} {
			.ccWindow.bottom.$col tag add highlight $num.0 [expr {$num+1}].0 
			.ccWindow.bottom.$col tag configure highlight -background lightYellow2 -font font_Bold
		}
		updateConsole "info: switched to game $num/$gamecount"
	}

	#----------------------------------------------------------------------
	# Empties the gamelist and reset global $num. This should be done
	# once the games are (re)synchronised.
	#----------------------------------------------------------------------
	proc emptyGamelist {} {
		set w .ccWindow
		foreach tag {id toMove event site white black clockW clockB var feature} {
			# unlock the list
			$w.bottom.$tag      configure -state normal
			# delete it
			$w.bottom.$tag      delete 1.0 end
		}
		# reset the number of processed games
		set ::CorrespondenceChess::num 0
	}

	#----------------------------------------------------------------------
	# Add a line to the status console
	#----------------------------------------------------------------------
	proc updateConsole {line} {
		set t .ccWindow.top.console
		if { [winfo exists $t] } {
			$t insert end "$line\n"
			$t yview moveto 1
		}
	}

	#----------------------------------------------------------------------
	# Opens a config dialog to set the default parameters. Currently
	# they are not stored to scids setup though.
	#----------------------------------------------------------------------
	proc config {} {
		set w .correspondenceChessConfig
		if { [winfo exists $w]} { return }
		toplevel $w
		wm title $w [::tr "CCDlgConfigureWindowTitle"]

		button $w.bOk     -text OK -command {
				::CorrespondenceChess::saveCCoptions
				destroy .correspondenceChessConfig
		}
		button $w.bCancel -text [::tr "Cancel"] -command "destroy $w"

		label  $w.lgeneral -text [::tr "CCDlgCGeneraloptions"]
		label  $w.ldb      -text [::tr "CCDlgDefaultDB"]
		label  $w.linbox   -text [::tr "CCDlgInbox"]
		label  $w.loutbox  -text [::tr "CCDlgOutbox"]

		label  $w.lxfccrc  -text [::tr "CCDlgXfcc"]

		label  $w.lxfcc    -text [::tr "CCDlgExternalProtocol"]
		label  $w.lfetch   -text [::tr "CCDlgFetchTool"]
		label  $w.lsend    -text [::tr "CCDlgSendTool"]

		label  $w.lemail   -text [::tr "CCDlgEmailCommunication"]
		label  $w.lmailx   -text [::tr "CCDlgMailPrg"]
		label  $w.lbccaddr -text [::tr "CCDlgBCCAddr"]

		label  $w.lmoderb  -text [::tr "CCDlgMailerMode"]
		label  $w.lmoderb1 -text [::tr "CCDlgThunderbirdEg"]
		label  $w.lmoderb2 -text [::tr "CCDlgMailUrlEg"]
		label  $w.lmoderb3 -text [::tr "CCDlgClawsEg"]
		label  $w.lmoderb4 -text [::tr "CCDlgmailxEg"]

		label  $w.lattache -text [::tr "CCDlgAttachementPar"]
		label  $w.lsubject -text [::tr "CCDlgSubjectPar"]

		checkbutton $w.internalXfcc -text [::tr "CCDlgInternalXfcc"] \
			-variable ::CorrespondenceChess::XfccInternal

		button $w.xfconf  -text [::tr CCConfigure] -command { ::CorrespondenceChess::checkXfccrc
			::Xfcc::config $::CorrespondenceChess::xfccrcfile}

		if {$::CorrespondenceChess::XfccInternal < 0} {
			$w.internalXfcc configure -state disabled
			$w.xfconf       configure -state disabled
		}

		entry  $w.db      -width 60 -textvariable ::CorrespondenceChess::CorrBase
		entry  $w.inbox   -width 60 -textvariable ::CorrespondenceChess::Inbox
		entry  $w.outbox  -width 60 -textvariable ::CorrespondenceChess::Outbox

		entry  $w.xfccrc  -width 60 -textvariable ::CorrespondenceChess::xfccrcfile
		entry  $w.fetch   -width 60 -textvariable ::CorrespondenceChess::XfccFetchcmd
		entry  $w.send    -width 60 -textvariable ::CorrespondenceChess::XfccSendcmd

		entry  $w.mailx   -width 60 -textvariable ::CorrespondenceChess::mailer
		entry  $w.bccaddr -width 60 -textvariable ::CorrespondenceChess::bccaddr
		entry  $w.attache -width 30 -textvariable ::CorrespondenceChess::attache
		entry  $w.subject -width 30 -textvariable ::CorrespondenceChess::subject

		radiobutton $w.moderb1 -text "Mozilla"  -value "mozilla" -variable ::CorrespondenceChess::mailermode
		radiobutton $w.moderb2 -text "Mail-URL" -value "mailurl" -variable ::CorrespondenceChess::mailermode
		radiobutton $w.moderb3 -text "Claws"    -value "claws"   -variable ::CorrespondenceChess::mailermode
		radiobutton $w.moderb4 -text "mailx"    -value "mailx"   -variable ::CorrespondenceChess::mailermode

		button $w.bdb     -text "..." -command {::CorrespondenceChess::chooseCorrBase }
		button $w.binbox  -text "..." -command {::CorrespondenceChess::chooseInbox    }
		button $w.boutbox -text "..." -command {::CorrespondenceChess::chooseOutbox   }
		button $w.bfetch  -text "..." -command {::CorrespondenceChess::chooseFetch    }
		button $w.bsend   -text "..." -command {::CorrespondenceChess::chooseSend     }

		# placing lables
		grid $w.lgeneral               -column 0 -row  0 -columnspan 3 -pady 10
		grid $w.ldb          -sticky e -column 0 -row  1
		grid $w.linbox       -sticky e -column 0 -row  2
		grid $w.loutbox      -sticky e -column 0 -row  3

		grid $w.lxfccrc      -sticky e -column 0 -row  5
		grid $w.lxfcc                  -column 0 -row  6 -columnspan 3 -pady 10
		grid $w.lfetch       -sticky e -column 0 -row  7
		grid $w.lsend        -sticky e -column 0 -row  8

		grid $w.lemail                 -column 0 -row  9 -columnspan 3 -pady 10
		grid $w.lmailx       -sticky e -column 0 -row 10
		grid $w.lbccaddr     -sticky e -column 0 -row 11
		grid $w.lmoderb      -sticky e -column 0 -row 12

		grid $w.lmoderb1     -sticky w -column 2 -row 12 -columnspan 2
		grid $w.lmoderb2     -sticky w -column 2 -row 13 -columnspan 2
		grid $w.lmoderb3     -sticky w -column 2 -row 14 -columnspan 2
		grid $w.lmoderb4     -sticky w -column 2 -row 15 -columnspan 2

		grid $w.lattache     -sticky e -column 0 -row 17
		grid $w.lsubject     -sticky e -column 0 -row 18

		# placing entry fields
		grid $w.db           -sticky w -column 1 -row  1 -columnspan 2
		grid $w.inbox        -sticky w -column 1 -row  2 -columnspan 2
		grid $w.outbox       -sticky w -column 1 -row  3 -columnspan 2

		grid $w.internalXfcc -sticky w -column 1 -row  4 -pady 10
		grid $w.xfconf                 -column 2 -row  4 -columnspan 2

		grid $w.xfccrc       -sticky w -column 1 -row  5 -columnspan 2
		grid $w.fetch        -sticky w -column 1 -row  7 -columnspan 2
		grid $w.send         -sticky w -column 1 -row  8 -columnspan 2

		grid $w.mailx        -sticky w -column 1 -row 10 -columnspan 2
		grid $w.bccaddr      -sticky w -column 1 -row 11 -columnspan 2

		grid $w.moderb1      -sticky w -column 1 -row 12
		grid $w.moderb2      -sticky w -column 1 -row 13
		grid $w.moderb3      -sticky w -column 1 -row 14
		grid $w.moderb4      -sticky w -column 1 -row 15

		grid $w.attache      -sticky w -column 1 -row 17 -columnspan 2
		grid $w.subject      -sticky w -column 1 -row 18 -columnspan 2

		grid $w.bdb          -sticky w -column 3 -row  1
		grid $w.binbox       -sticky w -column 3 -row  2
		grid $w.boutbox      -sticky w -column 3 -row  3
		grid $w.bfetch       -sticky w -column 3 -row  7
		grid $w.bsend        -sticky w -column 3 -row  8

		# Buttons and ESC-key
		grid $w.bOk          -column 0 -row 19 -pady 10 -columnspan 2
		grid $w.bCancel      -column 1 -row 19 -pady 10
		bind $w <Escape> "$w.bCancel invoke"

		bind $w <F1> { helpWindow CCSetupDialog}
	}

	#----------------------------------------------------------------------
	# startEmailGame: create an empty new game and set the header for
	# to a cmail compatible format with the parameters entered by the
	# user (own and opponent names and mail addresses and unique id)
	#----------------------------------------------------------------------
	proc startEmailGame {ownname ownmail oppname oppmail gameid} {
		# the following header tags have to be in this form for cmail to
		# recognise the mail as an eMail correspondence game.
		# Additonally scid searched for some of them to retrieve mail
		# addresses automagically and also to recognise this game as
		# eMail and not Xfcc.
		set Event         "Email correspondence game"
		set Site          "NET"
		set Round         "-"
		set CmailGameName "CmailGameName \"$gameid\""
		set WhiteNA       "WhiteNA \"$ownmail\""
		set BlackNA       "BlackNA \"$oppmail\""
		set Mode          "Mode \"EM\""

		set year          [::utils::date::today year]
		set month         [::utils::date::today month]
		set day           [::utils::date::today day]
		set today         "$year.$month.$day"

		# add a new game
		::game::Clear

		# set the header tags
		sc_game tags set -event     $Event
		sc_game tags set -site      $Site
		sc_game tags set -round     $Round
		sc_game tags set -white     $ownname
		sc_game tags set -black     $oppname
		sc_game tags set -date      $today
		sc_game tags set -eventdate $today

		# add cmails extra header tags
		sc_game tags set -extra [list $CmailGameName $WhiteNA $BlackNA $Mode]

		updateBoard -pgn
		updateTitle
		updateMenuStates

		# Call gameSave with argument 0 to append to the current
		# database. This also gives the Save-dialog for additional user
		# values.
		gameSave 0
	}

	#----------------------------------------------------------------------
	# Generate a new email correspondence game in the style of cmail,
	# but with a friendly dialog presented to the user instead of
	# somewhat cryptic command line parameters.
	# This procedure adds a new game to the Correspondence DB and fills
	# in the header appropriately.
	#----------------------------------------------------------------------
	proc newEMailGame {} {
		global ::CorrespondenceChess::CorrSlot

		# Regardless how the user opend this DB, find it! ;)
		::CorrespondenceChess::CheckForCorrDB
		# Only proceed if a correspondence DB is already loaded
		if {$CorrSlot > -1} {
			set w .wnewEMailGame
			if { [winfo exists $w]} { return }
			toplevel $w
			wm title $w [::tr "CCDlgStartEmail"]

			set ownemail   ::CorrespondenceChess::bccaddr
			set ownname    ""
			set oppemail   ""
			set oppname    ""
			set gameid     ""

			label  $w.lownname -text [::tr CCDlgYourName]
			label  $w.lownmail -text [::tr CCDlgYourMail]
			label  $w.loppname -text [::tr CCDlgOpponentName]
			label  $w.loppmail -text [::tr CCDlgOpponentMail]
			label  $w.lgameid  -text [::tr CCDlgGameID]

			entry  $w.ownname -width 40 -textvariable ownname
			entry  $w.ownmail -width 40 -textvariable $ownemail
			entry  $w.oppname -width 40 -textvariable oppname
			entry  $w.oppmail -width 40 -textvariable oppemail
			entry  $w.gameid  -width 40 -textvariable gameid

			button $w.bOk     -text OK -command {
				::CorrespondenceChess::startEmailGame \
						[.wnewEMailGame.ownname get] \
						[.wnewEMailGame.ownmail get] \
						[.wnewEMailGame.oppname get] \
						[.wnewEMailGame.oppmail get] \
						[.wnewEMailGame.gameid  get]
				destroy .wnewEMailGame
			}
			button $w.bCancel -text [::tr "Cancel"] -command "destroy $w"

			grid $w.lownname   -sticky e -column 0 -row 0
			grid $w.lownmail   -sticky e -column 0 -row 1
			grid $w.loppname   -sticky e -column 0 -row 2
			grid $w.loppmail   -sticky e -column 0 -row 3
			grid $w.lgameid    -sticky e -column 0 -row 4

			grid $w.ownname    -sticky w -column 1 -row 0 -columnspan 2
			grid $w.ownmail    -sticky w -column 1 -row 1 -columnspan 2
			grid $w.oppname    -sticky w -column 1 -row 2 -columnspan 2
			grid $w.oppmail    -sticky w -column 1 -row 3 -columnspan 2
			grid $w.gameid     -sticky w -column 1 -row 4 -columnspan 2

			# Buttons and ESC-key
			grid $w.bOk       -column 1 -row  5 -pady 10
			grid $w.bCancel   -column 2 -row  5 -pady 10
			bind $w <Escape> "$w.bCancel invoke"
			bind $w <F1> { helpWindow CCeMailChess}
		}
	}

	#----------------------------------------------------------------------
	# Call the mailer program to send the game by e-mail
	#----------------------------------------------------------------------
	proc CallExternal {callstring} {
		global windowsOS

		if {$windowsOS} {
			# On Windows, use the "start" command:
			if {[string match $::tcl_platform(os) "Windows NT"]} {
				catch {exec $::env(COMSPEC) /c start "$callstring"}
			} else {
				catch {exec start "$callstring"}
			}
		} else {
			# On Unix just call the shell with the converter tool
			catch {exec /bin/sh -c "$callstring"}
		}
	}

	#----------------------------------------------------------------------
	# Check wether a Correspondence Database is loaded. Note that the
	# first one found is used as reference DB for game processing.
	#----------------------------------------------------------------------
	proc CheckForCorrDB {} {
		global ::windows::switcher::base_types
		global ::CorrespondenceChess::Inbox ::CorrespondenceChess::Outbox
		global ::CorrespondenceChess::CorrSlot

		set CorrSlot -1
		if {$CorrSlot < 0} {
			# check for the status window to exist, if not open it
			if {![winfo exists .ccWindow]} {
				::CorrespondenceChess::CCWindow
			}

			# check for In/Outbox to exist and be accessible
			if { [file exists $Inbox] == 0  && ([file isdirectory $Inbox] == 0) } {
				set Title [::tr CCDlgTitNoInbox]
				set Error [::tr CCErrInboxDir]
				append Error "\n   $Inbox\n"
				append Error [::tr CCErrDirNotUsable]
				tk_messageBox -icon warning -type ok -parent . \
					-title $Title -message $Error
				return
			}
			if { ([file exists $Outbox] == 0) && ([file isdirectory $Outbox] == 0) } {
				set Title [::tr CCDlgTitNoOutbox]
				set Error [::tr CCErrOutboxDir]
				append Error "\n   $Outbox\n"
				append Error [::tr CCErrDirNotUsable]
				tk_messageBox -icon warning -type ok -parent . \
					-title $Title -message $Error
				return
			}

			set typeCorr [lsearch $base_types {Correspondence chess} ]
			for {set x 1} {$x <= [ expr [sc_base count]-1 ]} {incr x} {
					set type [sc_base type $x]
					if {$type == $typeCorr} {
						.ccWindow.top.openDB configure -state disabled
						set CorrSlot $x
						break
					}
			}
			if {$CorrSlot < 0} {
				set Title [::tr CCDlgTitNoCCDB]
				set Error [::tr CCErrNoCCDB]
				tk_messageBox -icon warning -type ok -parent . \
					-title $Title -message $Error
			}
		}
	}

	#----------------------------------------------------------------------
	# Opens the DB holding the correspondence games
	#----------------------------------------------------------------------
	proc OpenCorrespondenceDB {} {
		global ::CorrespondenceChess::CorrBase

		set fName [file rootname $CorrBase]
		if {[catch {openBase $fName} result]} {
			set err 1
			tk_messageBox -icon warning -type ok -parent . \
				-title "Scid: Error opening file" -message $result
		} else {
			set ::initialDir(base) [file dirname $fName]
		}
		::windows::gamelist::Refresh
		::tree::refresh
		::windows::stats::Refresh
		updateMenuStates
		updateBoard -pgn
		updateTitle
		updateStatusBar

		::CorrespondenceChess::CheckForCorrDB
	}

	#----------------------------------------------------------------------
	# Search for a game by Event, Site, White, Black and CmailGameName
	# This has to result in only one game matching the criteria. 
	# No problem with cmail and Xfcc as GameIDs are unique.
	#----------------------------------------------------------------------
	proc SearchGame {Event Site White Black CmailGameName result} {
		global ::CorrespondenceChess::CorrSlot ::CorrespondenceChess::LastProcessed


		# switch to the Correspondence Games DB
		sc_base switch $CorrSlot

		set sPgnlist {}
		lappend sPgnlist [string trim $CmailGameName]

		# Search the header for the game retrieved. Use as much info as
		# possible to get a unique result. In principle $sPgnList should
		# be enough. However searching indexed fields speeds up things
		# a lot in case of large DBs.
		set str [sc_search header \
					-event $Event    \
					-site $Site      \
					-white $White    \
					-black $Black    \
					-pgn $sPgnlist   \
					-gameNumber [list 1 -1] \
					]

		::windows::gamelist::Refresh
		::windows::stats::Refresh

		# There should be only one result. If so, load it and place the
		# game pointer to the end of the game ::game::Load also handles
		# board rotation if Player Names are set up correctly.
		if {[sc_filter count] == 1} {
			set filternum [sc_filter first]

			::game::Load $filternum

			sc_move end
			# Number of moves in the current DB game
			set mnCorr [expr {[sc_pos moveNumber]-1}]
			set side   [sc_pos side]

			if {$side == "white"} {
				set plyStart [expr {$mnCorr*2-1}]
			} else {
				set plyStart [expr {$mnCorr*2}]
			}

			# Number of moves in the new game in Clipbase
			sc_base switch "clipbase"
			sc_move end
			set mnClip [sc_pos moveNumber]
			set side   [sc_pos side]
			if {$side == "white"} {
				set plyEnd [expr {$mnClip*2-1}]
			} else {
				set plyEnd [expr {$mnClip*2}]
			}

			# Add moves from clipbase to the DB game. This keeps
			# comments, but requires that tries are inserted as variants
			# as it is always appended to the end of the game
			for {set x $plyStart} {$x < $plyEnd} {incr x} {
				sc_base switch "clipbase"

				# move to the beginning of the new part
				sc_move start
				sc_move forward [expr {$x+1}]

				# Get the move in _untranslated_ form...
				set move [sc_game info nextMoveNT]
				# ... move on one ply ...
				sc_move forward
				# ... and get the comment
				set comment [sc_pos getComment]
				# switch to Correspondence DB and add the move and comment
				sc_base switch     $CorrSlot
				sc_move addSan     $move
				sc_pos  setComment $comment
			}
			sc_game tags set -result $result
			sc_base switch $CorrSlot
			sc_game save $filternum
			::game::Load $filternum
		} elseif {[sc_filter count] == 0} {
			# No matching game found, add it as a new one
			# Clear the current game first, then just paste the clipboard
			# game as it is. No need to do something as complex as for
			# already existing games above.
			::game::Clear
			sc_clipbase paste
			# gameAdd presents scids "Save" dialog
			gameAdd
			# reload the game and jump to the end
			::game::Reload
		} else {
			::CorrespondenceChess::updateConsole "info Game-ID not unique?"
		}
	}

	#----------------------------------------------------------------------
	# If a Correspondence DB is loaded, switch to the clipbase and
	# use the game with the given id to find headers. 
	# PGN file and jump to the game number given. Then extract the
	# header tags and call "SearchGame" to display the game in question
	# to the user.
	#----------------------------------------------------------------------
	proc ProcessServerResult {game} {
		global ::CorrespondenceChess::CorrSlot
		global emailData

		# Regardless how the user opend this DB, find it! ;)
		::CorrespondenceChess::CheckForCorrDB
		# Only proceed if a correspondence DB is already loaded
		if {$CorrSlot > -1} {
			sc_base switch "clipbase"
			sc_game load $game

			# get the header
			set Event  [sc_game tags get Event]
			set Site   [sc_game tags get Site ]
			set White  [sc_game tags get White]
			set Black  [sc_game tags get Black]
			set Extra  [sc_game tags get Extra]
			set result [sc_game tags get Result]
			# CmailGameName is an extra header :(
			set extraTagsList [split $Extra "\n"]

			# ... extract it as it contains the unique ID
			foreach i $extraTagsList {
				if { [string equal -nocase [lindex $i 0] "CmailGameName" ] } {
					set CmailGameName [string range $i 15 end-1]
				}
			}
			# Search the game in the correspondence DB and display it
			SearchGame $Event $Site $White $Black $CmailGameName $result
			set Mode [::CorrespondenceChess::CheckMode]

			# hook up with the old email manager: this implements the
			# manual timestamping required
			if {$Mode == "EM"} {
				set emailData [::tools::email::readOpponentFile]
				set done 0
				set idx  0
				# search through the whole list and check if the current
				# game was already defined to be an email game.
				foreach dataset $emailData {
					if { [lindex $dataset 0] == $CmailGameName} {
						set done 1
						# add the received flag and date
						::tools::email::addSentReceived $idx r
					}
					incr idx
				}
				if {$done < 1} {
					set idx [llength $emailData]
					lappend emailData [list "" "" "" "" ""]
					set emailData [lreplace $emailData $idx $idx \
									  [list "$CmailGameName" "somewhere@somehost.org" "scid game" [sc_filter first] "-- " ]]
					::tools::email::writeOpponentFile $emailData
					::tools::email::refresh
					# add the received flag and date
					::tools::email::addSentReceived $idx r
				}
			}
			# Jump to the end of the game and update the display
			::move::End

			# Set some basic info also to the button tooltips
			::utils::tooltip::Set .ccWindow.top.resign     "$CmailGameName: $Event\n$Site\n\n$White - $Black"
			::utils::tooltip::Set .ccWindow.top.claimDraw  "$CmailGameName: $Event\n$Site\n\n$White - $Black"
			::utils::tooltip::Set .ccWindow.top.acceptDraw "$CmailGameName: $Event\n$Site\n\n$White - $Black"
			::utils::tooltip::Set .ccWindow.top.offerDraw  "$CmailGameName: $Event\n$Site\n\n$White - $Black"


		}
	}

	#----------------------------------------------------------------------
	# Checks the mode of the current game and return it (EM or XFCC).
	# Additionally update the button status in the Console window
	# accordingly and update the console itself with $Event, Mode and
	# $Site.
	#----------------------------------------------------------------------
	proc CheckMode {} {
		set Event [sc_game tags get Event]
		set Site  [sc_game tags get Site]
		set Extra [sc_game tags get Extra]
		# CmailGameName is an extra header :(
		set extraTagsList [split $Extra "\n"]

		# ... extract it as it contains the unique ID
		foreach i $extraTagsList {
			if { [string equal -nocase [lindex $i 0] "Mode" ] } {
				set Mode [string range $i 6 end-1]
			}
		}

		set m .menu.play.correspondence

		if {$Mode == "EM"} {
			::CorrespondenceChess::updateConsole "info Event: $Event (eMail-based)"

			# eMail games: manual handling for resign and draw is needed,
			# no standard way/protocol exists => disable the buttons and
			# menue entries accordingly
			.ccWindow.top.resign     configure -state disabled
			.ccWindow.top.claimDraw  configure -state disabled
			.ccWindow.top.offerDraw  configure -state disabled
			.ccWindow.top.acceptDraw configure -state disabled

			$m entryconfigure 11 -state disabled
			$m entryconfigure 12 -state disabled
			$m entryconfigure 13 -state disabled
			$m entryconfigure 14 -state disabled
		} else {
			.ccWindow.top.resign     configure -state normal
			.ccWindow.top.claimDraw  configure -state normal
			.ccWindow.top.offerDraw  configure -state normal
			.ccWindow.top.acceptDraw configure -state normal
			::CorrespondenceChess::updateConsole "info Event: $Event (Xfcc-based)"

			$m entryconfigure 11 -state normal
			$m entryconfigure 12 -state normal
			$m entryconfigure 13 -state normal
			$m entryconfigure 14 -state normal
		}
		::CorrespondenceChess::updateConsole "info Site: $Site"

		return $Mode
	}

	#----------------------------------------------------------------------
	# Search the previous game from the input file in the correspondence DB
	# If at last game already nothing happens
	#----------------------------------------------------------------------
	proc PrevGame {} {
		global ::CorrespondenceChess::CorrSlot ::CorrespondenceChess::LastProcessed

		busyCursor .

		# Regardless how the user opend this DB, find it! ;)
		::CorrespondenceChess::CheckForCorrDB
		if {$CorrSlot > -1} {
			sc_base switch "clipbase"
			if {$LastProcessed < 2} { 
				.ccWindow.top.prevCC configure -state disabled
				unbusyCursor .
				return
			}
			.ccWindow.top.nextCC configure -state normal
			set LastProcessed [expr {$LastProcessed - 1}]
			ProcessServerResult $LastProcessed
			if {$LastProcessed < 2} { 
				.ccWindow.top.prevCC configure -state disabled
			}
		}
		unbusyCursor .
	}

	#----------------------------------------------------------------------
	# Search the next game from the input file in the correspondence DB
	# If at last game already nothing happens
	#----------------------------------------------------------------------
	proc NextGame {} {
		global ::CorrespondenceChess::CorrSlot ::CorrespondenceChess::LastProcessed

		busyCursor .
		# Regardless how the user opend this DB, find it! ;)
		::CorrespondenceChess::CheckForCorrDB
		if {$CorrSlot > -1} {
			sc_base switch "clipbase"
			if {$LastProcessed < 0} {
				# for initalisation only
				set LastProcessed 0
				.ccWindow.top.prevCC configure -state disabled
			}
			if {$LastProcessed == [sc_base numGames]} { 
				.ccWindow.top.nextCC configure -state disabled
				unbusyCursor .
				return 
			}
			.ccWindow.top.prevCC configure -state normal
			set LastProcessed [expr {$LastProcessed + 1}]
			ProcessServerResult $LastProcessed
			if {$LastProcessed == [sc_base numGames]} { 
				.ccWindow.top.nextCC configure -state disabled
			}
		}
		unbusyCursor .
	}

	#----------------------------------------------------------------------
	# FetchGames: retrieve games via Xfcc
	#----------------------------------------------------------------------
	proc FetchGames {} {
		global ::CorrespondenceChess::Inbox ::CorrespondenceChess::XfccFetchcmd ::CorrespondenceChess::CorrSlot

		busyCursor .

		# Regardless how the user opend this DB, find it! ;)
		::CorrespondenceChess::CheckForCorrDB
		# Only proceed if a correspondence DB is already loaded
		if {$CorrSlot > -1} {
			if {$::CorrespondenceChess::XfccInternal == 1} {
				# use internal Xfcc-handling
				::Xfcc::ReadConfig $::CorrespondenceChess::xfccrcfile
				::Xfcc::ProcessAll $::CorrespondenceChess::Inbox
			} else {
				# call external protocol handler
				if {[file executable "$XfccFetchcmd"]} {
					::CorrespondenceChess::updateConsole "info Calling external fetch tool $XfccFetchcmd..."
					CallExternal "$XfccFetchcmd $Inbox"
				}
			}
			# process what was just retrieved
			::CorrespondenceChess::ReadInbox 
		}

		unbusyCursor .
	}

	#----------------------------------------------------------------------
	# EmptyInOutbox: remove all pgn files currently stored in in- and
	# outbox directories to get a fresh fetch
	#----------------------------------------------------------------------
	proc EmptyInOutbox {} {
		global ::CorrespondenceChess::Inbox ::CorrespondenceChess::Outbox
		global windowsOS

		if {$windowsOS} {
			set inpath  "$Inbox\\"
			set outpath "$Outbox\\"
		} else {
			set inpath  "$Inbox/"
			set outpath "$Outbox/"
		}

		foreach f [glob -nocomplain [file join $inpath *]] {
			file delete $f
		}
		foreach f [glob -nocomplain [file join $outpath *]] {
			file delete $f
		}
	}

	#----------------------------------------------------------------------
	# ReadInbox: process the inbox game per game by adding them one by
	# one to the clipboard.
	#----------------------------------------------------------------------
	proc ReadInbox {} {
		global ::CorrespondenceChess::Inbox ::CorrespondenceChess::CorrSlot
		global ::CorrespondenceChess::glccstart ::CorrespondenceChess::glgames windowsOS
		global ::Xfcc::lastupdate ::Xfcc::xfccstate

		busyCursor .

		if {$windowsOS} {
			set inpath  "$Inbox\\"
		} else {
			set inpath  "$Inbox/"
		}

		# Regardless how the user opend this DB, find it! ;)
		::CorrespondenceChess::CheckForCorrDB

		set games 0
		if {$CorrSlot > -1} {

			::CorrespondenceChess::emptyGamelist
			sc_clipbase clear
			sc_base switch "clipbase"
			foreach f [glob -nocomplain [file join $inpath *]] {
				if {[catch {sc_base import file $f} result]} {
					::CorrespondenceChess::updateConsole "info Error retrieving server response from $pgnfile"
				} else {
					# count the games processed successfully
					set games [expr {$games+1}]
				}
			}
			set glgames $games

			sc_base switch "clipbase"

			# Sort the clipbase to get a sorted list of games in CC
			# window and process them in sorted order by prev/next
			set sortCriteria "Site, Event, Round, Result, White, Black"
			progressWindow "Scid" "Sorting the database..."
			set err [catch {sc_base sort $sortCriteria \
									{changeProgressWindow "Sorting..."} \
								 } result]
			closeProgressWindow


			if {$glgames > 0} {
				# work through all games processed and fill in the gamelist 
				# in the console window
				for {set game $glccstart} {$game < [expr {$games+1}]} {incr game} {

					set wc "";
					set bc "";

					sc_base switch "clipbase"
					sc_game load $game
					# get the header
					set Event  [sc_game tags get Event]
					set Site   [sc_game tags get Site ]
					set White  [sc_game tags get White]
					set Black  [sc_game tags get Black]
					set Result [sc_game tags get Result]
					set Extra  [sc_game tags get Extra]
					# CmailGameName is an extra header :(
					set extraTagsList [split $Extra "\n"]

					# ... extract it as it contains the unique ID
					foreach i $extraTagsList {
						if { [string equal -nocase [lindex $i 0] "CmailGameName" ] } {
							set CmailGameName [string range $i 15 end-1]
						}
						if { [string equal -nocase [lindex $i 0] "Mode" ] } {
							set Mode [string range $i 6 end-1]
						}
						if { [string equal -nocase [lindex $i 0] "whiteCountry" ] } {
							set wc [string range $i 14 end-1]
							set wc [string tolower $wc]
							set wc "flag_$wc"
						}
						if { [string equal -nocase [lindex $i 0] "blackCountry" ] } {
							set bc [string range $i 14 end-1]
							set bc [string tolower $bc]
							set bc "flag_$bc"
						}
					}

					if {$Mode == "EM"} {
						::CorrespondenceChess::updateGamelist $CmailGameName "EML" \
								$Event $Site $White $Black "" "" "" "" "" "" "" $wc $bc ""

					} else {
						# search for extra information from Xfcc server
						set YM " ? ";  
						set clockW "no update"; set clockB "no update";
						set var "";             set noDB "";
						set noBK "";            set noTB ""; 
						set noENG "";           set mess ""

						# actually check the $xfccstate list for the current
						# values. If it is not set (e.g. only inbox processed
						# buy no current retrieval) set some default values.
						foreach xfccextra $::Xfcc::xfccstate {
							if { [string equal -nocase [lindex $xfccextra 0] "$CmailGameName" ] } {
								foreach i $xfccextra {
									if { [string equal -nocase [lindex $i 0] "myTurn" ] } {
										if {[string range $i 7 end] == "true"} {
											set YM "yes"
										} else {
											set YM "no"
										}
									}
									if { [string equal -nocase [lindex $i 0] "clockW" ] } {
										set clockW [string range $i 7 end]
										regsub -all "\{" $clockW "" clockW
										regsub -all "\}" $clockW "" clockW
									}
									if { [string equal -nocase [lindex $i 0] "clockB" ] } {
										set clockB [string range $i 7 end]
										regsub -all "\{" $clockB "" clockB
										regsub -all "\}" $clockB "" clockB
									}
									if { [string equal -nocase [lindex $i 0] "drawOffered" ] } {
										set drawoffer [string range $i 7 end]
									}
									if { [string equal -nocase [lindex $i 0] "variant" ] } {
										set var [string range $i 8 end]
									}
									if { [string equal -nocase [lindex $i 0] "noDatabases" ] } {
										set noDB [string range $i 12 end]
									}
									if { [string equal -nocase [lindex $i 0] "noOpeningBooks" ] } {
										set noBK [string range $i 15 end]
									}
									if { [string equal -nocase [lindex $i 0] "noTablebases" ] } {
										set noTB [string range $i 13 end]
									}
									if { [string equal -nocase [lindex $i 0] "noEngines" ] } {
										set noENG [string range $i 10 end]
									}
									if { [string equal -nocase [lindex $i 0] "message" ] } {
										set mess [string range $i 9 end-1]
									}
								}
							}
						}
						if {$Result == "1"} {
							set YM "1-0"
						} elseif {$Result == "0"} {
							set YM "0-1"
						} elseif {$Result == "="} {
							set YM " = "
						}
						::CorrespondenceChess::updateGamelist $CmailGameName $YM \
								$Event $Site $White $Black $clockW $clockB $var \
								$noDB $noBK $noTB $noENG $wc $bc $mess
					}
				}
				.ccWindow.top.nextCC configure -state normal
				.ccWindow.top.sendCC configure -state normal

				# ::CorrespondenceChess::num is the game currently shown
				set ::CorrespondenceChess::num 0
				# current game is game 0 -> go to game 1 in the list
				::CorrespondenceChess::NextGame
			} else {
				set Title [::tr CCDlgTitNoGames]
				set Error [::tr CCErrInboxDir]
				append Error "\n   $Inbox\n"
				append Error [::tr CCErrNoGames]
				tk_messageBox -icon warning -type ok -parent . \
					-title $Title -message $Error
			}
		}
		unbusyCursor .
	}

	#----------------------------------------------------------------------
	# Send the move to the opponent via eMail
	# This requires an external MTA that is capable of sending a pgn file
	# as attachement (content-type: application/x-chess-pgn). This can be
	# accomplished by nail with proper /etc/mime.types (default on debian).
	# Additionally the program has to handle SMTP-Auth in all its flavours
	# to be of any use in present days.
	# A stripped version of the game is placed in outbox and sent to the
	# opponent. As nail does not handle empty bodies it is sent as text
	# within the body and once attached for easy extraction with mail
	# programs that do not know a thing about piping.
	# After the mail is sent a full featured version of the pgn is placed
	#----------------------------------------------------------------------
	proc eMailMove { } {
		global ::CorrespondenceChess::Outbox \
			::CorrespondenceChess::mailer  ::CorrespondenceChess::mailermode \
			::CorrespondenceChess::attache ::CorrespondenceChess::subject \
			::CorrespondenceChess::bccaddr ::CorrespondenceChess::CorrSlot
		global emailData

		busyCursor .

		# Regardless how the user opend this DB, find it! ;)
		::CorrespondenceChess::CheckForCorrDB

		if {$CorrSlot > -1} {
			# move to end to show the location to send AND to get the right
			# side to move, ie. for the extraction of the correct To: address
			::move::End
			set Event  [sc_game tags get Event]
			set Site   [sc_game tags get Site ]
			set Date   [sc_game tags get Date]
			set Round  [sc_game tags get Round]
			set Result [sc_game tags get Result]
			set White  [sc_game tags get White]
			set Black  [sc_game tags get Black]
			set Extra  [sc_game tags get Extra]
			set Extra  [sc_game tags get Extra]
			set extraTagsList [split $Extra "\n"]

			foreach i $extraTagsList {
				if { [string equal -nocase [lindex $i 0] "CmailGameName" ] } {
					set CmailGameName [string range $i 15 end-1]
				}
				if { [string equal -nocase [lindex $i 0] "WhiteNA" ] } {
					set WhiteNA [string range $i 9 end-1]
				}
				if { [string equal -nocase [lindex $i 0] "BlackNA" ] } {
					set BlackNA [string range $i 9 end-1]
				}
			}

			# construct a PGN in Outbox, stripped bare of comments and variations
			set pgnfile "[file join $Outbox $CmailGameName].pgn"

			sc_base export "current" "PGN" $pgnfile -append 0 -comments 0 -variations 0 \
						-space 1 -symbols 0 -indentC 0 -indentV 0 -column 0 -noMarkCodes 0 -convertNullMoves 1

			# sc_game pgn -gameNumber $i -width 70 -tags 0 -variations 0 -comments 0]

			# try to handle some obscure problem that the file is not
			# existent yet when calling the mailer
			while {! [file exists $pgnfile]} {
				after 1500 puts "waiting..."
			}
			# send the game to the side to move
			set toMove  [sc_pos side]

			if {$toMove == "white"} {
				set to   $WhiteNA
				set from $BlackNA
			} else {
				set from $WhiteNA
				set to   $BlackNA
			}

			set title   "scid mail 1 game <$CmailGameName>"
			set body    "Final FEN: "
			append body [sc_pos fen]
			append body "\n\n"
			append body "Move List: "
			append body [sc_game moves]
			append body "\n\n"

			# Check what calling convention to use:
			# - mailx  : something like mailx, mutt, nail or whatever via
			#            commandline. This sends the mail without further
			#            intervention by the user
			# - mozilla: call a mozilla or descendent like icedove or
			#            thunderbird. This syntax is found somewhere in the
			#            developers docs and almost entirely undocumented
			# - mailurl: the same syntax as for mailto:-links in webpages
			#            (rfc 2368). This calling convention is supported by
			#            evolution
			# -claws   : Claws mailer, seems to be almost mailurl, but needs
			#            a parameter for attachements
			switch -regexp -- $::CorrespondenceChess::mailermode \
			"mailx" {
				set callstring "$mailer $subject \"$title\" -b $bccaddr $attache $pgnfile $to <$pgnfile &"
			} \
			"mozilla" {
				set callstring "$mailer -compose 'subject=$title,bcc=$bccaddr,attachment=file://$pgnfile,to=$to,body=$body' &"
			} \
			"mailurl" {
				set callstring "$mailer \'mailto:\<$to\>?bcc=$bccaddr\&subject=$title\&attach=$pgnfile\&body=$body\' &"
			} \
			"claws" {
				set callstring "$mailer --compose \'mailto:$to?subject=$title&cc=$bccaddr&body=$body\' --attach $pgnfile &"
			}
			::CorrespondenceChess::updateConsole "info Calling eMail program: $mailer..."
			CallExternal $callstring

			# Save the game once the move is sent
			set num [sc_game number]
			sc_game save $num

			# Hook up with email manager: search the game in its internal
			# list and add the send flag automatically.
			set done 0
			set idx  0
			foreach dataset $emailData {
				if { [lindex $dataset 0] == $CmailGameName} {
					set done 1
					# add the sent flag and date
					::tools::email::addSentReceived $idx s
				}
				incr idx
			}
		}

		unbusyCursor .
	}

	#----------------------------------------------------------------------
	# Send the move to the opponent via XFCC or eMail
	#----------------------------------------------------------------------
	proc SendMove {resign claimDraw offerDraw acceptDraw } {
		global ::CorrespondenceChess::Outbox   ::CorrespondenceChess::XfccSendcmd \
				 ::CorrespondenceChess::CorrSlot num

		busyCursor .

		::CorrespondenceChess::CheckForCorrDB
		if {$CorrSlot > -1} {

			# Go to the last move is important to send the comment for
			# the last move only not the comment for the current game
			# position!
			sc_move end

			set Extra [sc_game tags get Extra]
			set extraTagsList [split $Extra "\n"]

			# ... extract it as it contains the unique ID
			foreach i $extraTagsList {
				if { [string equal -nocase [lindex $i 0] "CmailGameName" ] } {
					set CmailGameName [string range $i 15 end-1]
				}
			}

			set pgnfile "[file join $Outbox $CmailGameName].pgn"

			set IdList    [split $CmailGameName "-"]
			set name      [lindex $IdList 0]
			set gameid    [lindex $IdList 1]
			set movecount [sc_pos moveNumber]
			set move      [sc_game info previousMoveNT]
			set comment   [sc_pos getComment]
			set Event     [sc_game tags get Event]

			# moveNumber gives the number of the next full move. This is
			# one to high in case of playing black. Note that for this
			# ply it is _white_ to move!
			if {[sc_pos side] == "white"} {
					set movecount [expr {$movecount-1}]
			}

			# Mark the ID background:
			# yellow while sending in progress,
			# green if the move was sent in the
			# current session (ie. without update)
			.ccWindow.bottom.id tag add hlsent$CmailGameName $num.0 [expr {$num+1}].0 
			.ccWindow.bottom.id tag configure hlsent$CmailGameName -background yellow -font font_Bold

			# If Event = "Email correspondence game"
			# treat it as cmail game that is send by mail, otherwise it is
			# Xfcc and sent accordingly
			set Mode [::CorrespondenceChess::CheckMode]
			if {$Mode == "EM"} {
				eMailMove
			} else {
				if {$::CorrespondenceChess::XfccInternal == 1} {
					# use internal Xfcc-handling
					::Xfcc::ReadConfig $::CorrespondenceChess::xfccrcfile
					::Xfcc::Send $name $gameid $movecount $move $comment \
							$resign $acceptDraw $offerDraw $claimDraw
				} else {
					if {[file executable "$XfccSendcmd"]} {
						set callstring "$XfccSendcmd $Outbox $name $gameid $movecount $move \"$comment\" $resign $claimDraw $offerDraw $acceptDraw &"

						::CorrespondenceChess::updateConsole "info Spawning external send tool $XfccSendcmd..."
						CallExternal $callstring
					}
				}
			}

			# Save the game once the move is sent
			sc_game save [sc_game number]

			# setting "noMarkCodes" to 1 would drop the timing comments
			# inserted e.g. by SchemingMind. Do not overwrite eMail based
			# games as the mailer might not have sent them and most
			# mailers load the file right before transmission.
			if {!($Mode == "EM")} {
				sc_base export "current" "PGN" $pgnfile -append 0 -comments 1 -variations 1 \
							-space 1 -symbols 1 -indentC 0 -indentV 0 -column 0 -noMarkCodes 0 -convertNullMoves 1
			}

			# Everything done, set background to green
			.ccWindow.bottom.id tag configure hlsent$CmailGameName -background green -font font_Bold

		}
		unbusyCursor .
	}

	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# source the options file to overwrite the above setup

	set scidConfigFiles(correspondence) "correspondence.dat"
	if {[catch {source [scidConfigFile correspondence]} ]} {
	  #::splash::add "Unable to find the options file: [file tail $optionsFile]"
	} else {
	  ::splash::add "Correspondence Chess configuration was found and loaded."
	}

	if {[catch { package require http }]} {
	  ::splash::add "http package not found, disabling internal Xfcc support"
		set XfccInternal -1
	}

	if {[catch {package require tdom}]} {
		::splash::add "tDOM package not found, disabling internal Xfcc support"
		set XfccInternal -1
	}

	::CorrespondenceChess::checkInOutbox
	::CorrespondenceChess::checkXfccrc
	::CorrespondenceChess::checkCorrBase
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
}


###
### End of file: Correspondence.tcl
###
