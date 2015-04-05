#Sitrep
#
#What is this?
#
#ARG situation report
#
#
#usage   
#
#!sitrep
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
	name		=> 'sitrep',
	description	=> 'sitrep',
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

	if (!/^!sitrep/i) { return 0; }

	if(!/^sitrep/i){ 
		$server->command('msg '.$target.' //CLASSIFIED//TRUTH//SITREP - http://j.mp/ONIsitrp');
		return 0;
	}

}

signal_add("message public", "public_question");
signal_add("message own_public", "own_question");
