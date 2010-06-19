#!/usr/bin/env tclsh8.5
#
# June 19 2010
#
# Encrypt data from stdin into stdout
#
# e.g. use to encrypt and mail result of a script:
# ./script | ./cryptmail.tcl | ./sendmail.tcl

set key 0A6B501F
set gpg /usr/bin/gpg

puts [exec $gpg --recipient $key -o - --armor --encrypt]
