#Romshot Bot
#
#What is this?
#
#Instant rimshot
#
#
#usage   
#
#!rimshot
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
	name		=> 'rimshot',
	description	=> 'badoomtsh',
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

	if (!/^!rimshot/i) { return 0; }

	if(!/^rimshot/i){ 
		$server->command('action '.$target.' BA DOOM *TSH*');
		return 0;
	}

}

signal_add("message public", "public_question");
signal_add("message own_public", "own_question");
