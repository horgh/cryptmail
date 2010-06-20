#!/usr/bin/env tclsh8.5
#
# June 18 2010
#
# Read from stdin, encrypt with gpg, and mail to configured address using
# given server
#
# e.g. use to encrypt and mail result of a script:
# ./script 2>&1 | ./cryptmail.tcl "this goes in subject after hostname"
#

package require smtp
package require mime

namespace eval cryptmail {
	variable subject "[info hostname]: [lindex $argv 0]"
	variable to will@summercat.com

	# mail server settings
	variable from will@summercat.com
	variable server shawmail.vc.shawcable.net
	variable port 25
	variable tls 0
	variable username {}
	variable password {}

	# gpg settings
	variable gpg_path /usr/bin/gpg
	variable key 0A6B501F
	# set to 0 to not encrypt
	variable encrypt 1
}

proc cryptmail::sendmail {recipient subject body} {
	set token [mime::initialize -canonical text/plain -string $body]
	mime::setheader $token Subject $subject
	smtp::sendmessage $token -servers $cryptmail::server -recipients $recipient -originator $cryptmail::from -ports $cryptmail::port -usetls $cryptmail::tls -username $cryptmail::username -password $cryptmail::password
	mime::finalize $token
}

proc cryptmail::encrypt {text} {
	# -o - makes output go to stdout
	# -ignorestderr makes no error raised on exec if stderr input
	return [exec -ignorestderr $cryptmail::gpg_path --recipient $cryptmail::key -o - --armor --encrypt << $text]
}

set body [read -nonewline stdin]
if {$cryptmail::encrypt} {
	set body [cryptmail::encrypt $body]
}
set result [cryptmail::sendmail $cryptmail::to $cryptmail::subject $body]
#puts "result of cryptmail: $result"
