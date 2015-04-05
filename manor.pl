#Dark Manor
#
#What is this?
#
#An exciting adventure. Will you take a trip down the Grollo hole?
#
#
#usage   
#
#!fastrun <command>
#
#
use strict;
use vars qw($VERSION %IRSSI);

use Irssi qw(command_bind signal_add);
use IO::File;
$VERSION = 'A girl never tells her age ;)';
%IRSSI = (
	authors		=> 'Kenny Cameron',
	contact		=> 'halo@stckr.co.uk',
	name		=> 'Dark Manor',
	description	=> '| FASTRUN FUN |',
	license		=> 'GPL',
);

sub own_question {
	my ($server, $msg, $target) = @_;
	question($server, $msg, "", $target);
}

sub public_question {
	my ($server, $msg, $nick, $address, $target) = @_;
	question($server, $msg, $nick, $target);
}
sub question {
	my ($server, $msg, $nick, $target) = @_;
	$_ = $msg;

	if (!/^!fastrun/i) { return 0; }

	if (/^!fastrun fun$/i) { 
		$server->command('msg '.$target.' The Darker Manor v3.14159 - Now more darkerer, more manorerer and 1000% more Grollow');
		return 0;
	} elsif (/^!fastrun calc$/i) {
		$server->command('action '.$target.' divides '.$nick.' by 0, it is most effective');
		return 0;
	} elsif (/^!fastrun htaai$/i) {
		$server->command('msg '.$target.' | > |');
		return 0;
	} else {
		if (!/^fastrun/i) {
			$server->command('msg '.$target.' | SYNTAX ERROR |');
			return 0;		
		}
	}
}

signal_add("message public", "public_question");
signal_add("message own_public", "own_question");
