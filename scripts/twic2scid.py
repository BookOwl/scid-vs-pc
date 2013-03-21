#!/usr/bin/env python

# Usage: twic2scid.py [database [spellingfile]]

# Download the current week's TWIC games and append them to an existing
# Scid database and perform spellchecking.

# If no args are given, these defaults are used
# (note - database does not include ".si4")

scid_database = "twic"
scid_spelling = "spelling.ssp"

# This version fixes a few bugs, and will use lftp if you have it
# installed, wget if not.  If neither of those work, it will attempt to
# download the URL directly, using Python's urllib.py module (which
# doesn't do regetting, retrying, etc).

# By John Wiegley

# NOTE: This program comes with absolutely NO WARRANTY.  If anything
# goes wrong, it may delete your database entirely instead of adding
# to it!  I recommend backing up your database, trying it out, and
# then adding a "last week rollback" type of copy command to your
# cronjob, just to make sure.

# Modification by Maksim Grinman on 3/20/2013
# Updated to work with the new TWIC site at http://www.theweekinchess.com/twic

import glob
import urllib
import zipfile
import tempfile
import string
import sys
import re
import os


os.environ['PATH'] = os.environ['PATH'] + ":/usr/local/bin"

if len(sys.argv) > 1:
    scid_database = sys.argv[1]
    
if len(sys.argv) > 2:
    scid_spelling = sys.argv[2]

print "Downloading the Week in Chess main page..."

url = urllib.urlopen("http://www.theweekinchess.com/twic")

archive = None
found   = 0
for line in url.readlines():
    match = re.search("http://[^\"]+", line)
    if match:
        pgn = re.search(">PGN<", line)
        if pgn:
            archive = match.group(0)
            found = 1
            break

if not found:
    print "Could not find PGN zipfile name in twic.html!"
    sys.exit(1)

# I prefer to use lftp here, since it does all the retrying and status
# display for me

print "Getting PGN archive \"%s\"..." % archive

afile = tempfile.mktemp(".zip")

if os.path.isfile("/usr/bin/lftp"):
    status = os.system("lftp -c 'get %s -o %s; quit'" % (archive, afile))
else:
    status = os.system("wget -O %s %s" % (afile, archive))

if status != 0:
    print "lftp or wget not working, retrying directly..."
    fd = open(afile, "wb")
    fd.write(urllib.urlretrieve(archive))
    fd.close()

zip = zipfile.ZipFile(afile)

databases = []

print "Unzipping and converting to scid databases..."

for file in zip.namelist():
    if re.search("\.pgn$", file):
        output = tempfile.mktemp(".pgn")
        outfd = open(output, "wb")
        outfd.write(zip.read(file))
        outfd.close()

        database = tempfile.mktemp()
        os.system("pgnscid -f %s %s" % (output, database))
        databases.append(database)

        os.unlink(output)

zip.close()
os.unlink(afile)

print "Merging databases into %s.new..." % scid_database

if databases:
    status = os.system("scmerge %s %s %s" %
                       (scid_database + ".new",
                        scid_database, string.join(databases, " ")))

    for file in databases:
        map(os.unlink, glob.glob("%s.s*" % file))

    if status == 0:
        print "Moving new database to %s..." % scid_database
        map(os.unlink, glob.glob("%s.s*" % scid_database))
        os.system("scmerge %s %s" % (scid_database, scid_database + ".new"))
        map(os.unlink, glob.glob("%s.s*" % (scid_database + ".new")))
        print "Spell checking the new database..."
        os.system("sc_spell %s %s" % (scid_database, scid_spelling))
