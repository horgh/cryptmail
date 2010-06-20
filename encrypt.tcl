#!/usr/bin/env tclsh8.5
#
# June 19 2010
#
# Encrypt data from stdin into stdout
#
# e.g. use to encrypt and mail result of a script:
# ./script 2>&1 | ./cryptmail.tcl 2>&1 | ./sendmail.tcl

set key 0A6B501F
set gpg /usr/bin/gpg

puts [exec $gpg --recipient $key -o - --armor --encrypt]
