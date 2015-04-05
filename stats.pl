#IRC stats
#
#What is this?
#
#Prints a link to IRC stats from Furiousn00b
#
#
#usage   
#
#!stats
#
#
use strict;
use vars qw($VERSION %IRSSI);

use Irssi qw(command_bind signal_add);
use IO::File;
$VERSION = 'A girl never tells her age ;)';
%IRSSI = (
	authors		=> 'Kenny Cameron',
	contact		=> 'halo"stckr.co.uk',
	name		=> 'stats',
	description	=> 'ALL THE STATS',
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

	if (!/^!stats/i) { return 0; }

	if(!/^stats/i){ 
		$server->command('msg '.$target.' http://arg.furiousn00b.com/HUNTtheTRUTH/irc/halo5.html');
		return 0;
	}

}

signal_add("message public", "public_question");
signal_add("message own_public", "own_question");
