#!/usr/bin/env tclsh8.6
#
# Read from stdin, encrypt with gpg, and mail to configured address using given
# SMTP server (if desired).
#
# e.g. Use to encrypt and mail result of a script:
# ./script 2>&1 | ./cryptmail.tcl "this goes in subject after hostname"
# 2>&1 so we get stderr as well
#
# Requirements:
#  - GPG
#
# BUGS:
#  - TLS connection seems to not work
#
# To set up keys:
# - List the keys you from an existing keyring:
#   gpg --list-keys
# - Export the relevant public key:
#   gpg -a --export will@summercat.com > pubkey.txt
# - Import it into another keyring:
#   gpg --import < pubkey.txt
# - Trust it to avoid warnings:
#   gpg --edit-key will@summercat.com
#   Enter trust, then quit
#

package require smtp
package require mime

namespace eval ::cryptmail {
	# Mail settings.
	variable subject "[info hostname]: [lindex $argv 0]"
	variable to will@summercat.com
	variable from will@summercat.com

	# Mail server settings.
	# For Uniserve:
	#variable server mail.uniserve.com
	variable server shawmail.vc.shawcable.net
	variable port 25
	variable tls 0
	variable username {}
	variable password {}

	# GPG settings
	variable gpg_path /usr/bin/gpg
	variable key 0A6B501F

	# Output plaintext body result to stdout. This is useful to receive plaintext
	# versions in local cron mail.
	variable output_plaintext_to_stdout 0

	# Output encrypted body using SMTP or not.
	variable output_to_smtp 0

	# Output encrypted body to result.
	# This is useful if you don't want to actually send an email, but rely on
	# system mail delivery instead.
	variable output_encrypted_to_stdout 1
}

# Send an email using SMTP.
proc ::cryptmail::sendmail {recipient subject body} {
	set token [mime::initialize -canonical text/plain -string $body]

	mime::setheader $token Subject $subject

	smtp::sendmessage $token -servers $::cryptmail::server \
		-recipients $recipient \
		-originator $::cryptmail::from \
		-ports $::cryptmail::port \
		-usetls $::cryptmail::tls \
		-username $::cryptmail::username \
		-password $::cryptmail::password

	mime::finalize $token
}

# Encrypt the given text using gpg.
proc ::cryptmail::encrypt {text} {
	# -o - makes output go to stdout
	# -ignorestderr makes no error raised on exec if stderr input
	return [exec -ignorestderr $::cryptmail::gpg_path \
		--recipient $::cryptmail::key -o - --armor --encrypt << $text]
}

set body [read stdin]

if {$body == ""} {
	return
}

if {$::cryptmail::output_plaintext_to_stdout} {
	puts $body
}

set encrypted_body [::cryptmail::encrypt $body]

if {$::cryptmail::output_encrypted_to_stdout} {
	puts $encrypted_body
}

if {$::cryptmail::output_to_smtp} {
	::cryptmail::sendmail $::cryptmail::to $::cryptmail::subject \
		$encrypted_body
}
