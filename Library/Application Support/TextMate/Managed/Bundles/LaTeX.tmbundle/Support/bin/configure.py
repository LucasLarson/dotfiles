#!/usr/bin/python

# -- Imports ------------------------------------------------------------------

from os import sys, path
sys.path.insert(1, path.dirname(path.dirname(path.abspath(__file__))) +
                "/lib/Python")

from subprocess import Popen, PIPE, STDOUT

from tmprefs import Preferences

# -- Main ---------------------------------------------------------------------

if __name__ == '__main__':
    prefs = Preferences()
    command = ('"$DIALOG" -mp "" -d \'{}\' '.format(prefs.defaults()) +
               '"$TM_BUNDLE_SUPPORT"/nibs/Preferences')
    Popen(command, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT)
