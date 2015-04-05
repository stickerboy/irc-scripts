#IRC Logs
#
#What is this?
#
#A bot to pull IRC logs and stuff
#
#
#usage   
#
#!logs
#
#!logs xxxx
#
#use strict;
use vars qw($VERSION %IRSSI);

use Irssi qw(command_bind signal_add);
use IO::File;
$VERSION = 'A girl never tells her age ;)';
%IRSSI = (
	authors		=> 'Kenny Cameron',
	contact		=> 'halo"stckr.co.uk',
	name		=> 'logs',
	description	=> 'Everyone loves a slinky!',
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

	if (!/^!logs/i) { return 0; }

	if (/^!logs$/i){
		$server->command('msg '.$target.' http://halo.stckr.co.uk/');
		return 0;
	} elsif (/^!logs ([0-9]{2}-[0-9]{2}-[0-9]{4})$/i){
		my $old = $msg;
		my $new = $old =~ s/!logs /http:\/\/halo.stckr.co.uk\/logs\/TRUTH\/2015\/LOGS\//r;
		$server->command('msg '.$target.' '.$new.'.log');
		return 0;
	} else {
		if(!/^logs/i){ 
			# $server->command('msg '.$target.' PLOGS\/uzzles are fun, aren\'t they '.$nick.'? I am trying to decipher yours');
			return 0;
		}
	}

}

signal_add("message public", "public_question");
signal_add("message own_public", "own_question");
