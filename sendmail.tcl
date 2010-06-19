#!/usr/bin/env tclsh8.5
#
# June 18 2010
#
# reads from stdin and sends to configured address using given server
#

package require smtp
package require mime

namespace eval sendmail {
	variable server shawmail.vc.shawcable.net
	variable port 25
	variable tls 0
	variable username {}
	variable password {}
	variable from will@summercat.com
}

proc sendmail::sendmail {recipient subject body} {
	set token [mime::initialize -canonical text/plain -string $body]
	mime::setheader $token Subject $subject
	smtp::sendmessage $token -servers $sendmail::server -recipients $recipient -originator $sendmail::from -ports $sendmail::port -usetls $sendmail::tls -username $sendmail::username -password $sendmail::password
	mime::finalize $token
}

set content [read -nonewline stdin]
set subject "Status update from [info hostname]"
set result [sendmail::sendmail will@summercat.com $subject $content]
#puts "result: $result"
