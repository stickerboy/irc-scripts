#Potato Bot
#
#What is this?
#
#For Lordhookocho
#
#
#usage   
#
#!potato
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
	name		=> 'potato',
	description	=> 'potato',
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

	if (!/^!potato/i) { return 0; }

	if(!/^potato/i){ 
		$server->command('msg '.$target.' Hi, how are you holding up? Because I\'m a potato - http://halo.stckr.co.uk/media/img/halo5-potato.png');
		return 0;
	}

}

signal_add("message public", "public_question");
signal_add("message own_public", "own_question");
