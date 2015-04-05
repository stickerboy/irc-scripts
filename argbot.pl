#ARGbot
#
#What is this?
#
#A bot to handle specific tasks relating to the halo4ARG
#
#
#usage   
#
#!ARG
#
#!ARG xxxx
#
use strict;
use vars qw($VERSION %IRSSI);

use Irssi qw(command_bind signal_add);
use IO::File;
$VERSION = 'A girl never tells her age ;)';
%IRSSI = (
	authors		=> 'Kenny Cameron',
	contact		=> 'halo"stckr.co.uk',
	name		=> 'ARGbot',
	description	=> 'You know in some galactic timezones, it\'s still Yanumas!',
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

	if (!/^!ARG/i) { return 0; }

	if (/^!ARG help$/i){
		$server->command('msg '.$target.' Use !ARG <command> - Available commands: nick, regnick, irc, site, ruby, yanumas, radialsim, hydrai, grollo, orkid, munge, n00b, tools, decode');
		return 0;
	} elsif (/^!ARG cmd$/i){
		$server->command('msg '.$target.' Command List: http://p.stckr.co.uk/6eCjDYKx?raw');
		return 0;
	} elsif (/^!ARG nick$/i){
		$server->command('msg '.$target.' Please use your Halo Waypoint Gamertag as your nickname in the chat. You can use /nick to change your nickname. Make sure not to use spaces, as they won\'t work, use dashes (-) or underscores (_) or simply remove the space :)');
		return 0;
	} elsif (/^!ARG regnick$/i){
		$server->command('msg '.$target.' It is advisable to register your nickname. See here for details: http://wiki.mibbit.com/index.php/Create_your_own_nickname');
		return 0;
	}  elsif (/^!ARG irc$/i){
		$server->command('msg '.$target.' server: irc.mibbit.net, port: 6667');
		return 0;
	} elsif (/^!ARG site$/i){
		$server->command('msg '.$target.' http://section3.info');
		return 0;
	} elsif (/^!ARG ruby$/i){
		$server->command('msg '.$target.' ONI.rb: http://p.stckr.co.uk/447iQUaY?raw');
		return 0;
	} elsif (/^!ARG yanumas$/i){
		$server->command('msg '.$target.' Yanumas is celebrated each year on the 15th of November. You know, I hear that in some galactic timezones it is still Yanumas!');
		return 0;
	} elsif (/^!ARG radialsim$/i){
		$server->command('msg '.$target.' Radialsim was a dearly beloved AI, taken from us far too early. He is remembered each year on the 18th of November');
		return 0;
	} elsif (/^!ARG hydrai$/i){
		$server->command('msg '.$target.' | CURIOUS |');
		return 0;
	} elsif (/^!ARG grollo$/i){
		$server->command('msg '.$target.' Do not speak of the Grollow, for they may hear you. Guard your HP wisely OP');
		return 0;
	} elsif (/^!ARG orkid$/i){
		$server->command('msg '.$target.' | REDACTED |');
		return 0;
	} elsif (/^!ARG munge$/i){
		$server->command('action '.$target.' slaps '.$nick.' with munge munge munge');
		return 0;
	} elsif (/^!ARG n00b$/i){
		$server->command('msg '.$target.' http://arg.furiousn00b.com/HUNTtheTRUTH');
		return 0;
	} elsif (/^!ARG tools$/i){
		$server->command('msg '.$target.' ONI Tools - http://www.furiousn00b.com/');
		return 0;
	} elsif (/^!ARG decode$/i){
		$server->command('msg '.$target.' Convertr - http://code.stckr.co.uk');
		return 0;
	} else {
		if(!/^ARG/i){ 
			$server->command('msg '.$target.' Use !ARG <command> - Available commands: nick, regnick, irc, site, ruby, yanumas, radialsim, hydrai, grollo, orkid, munge, n00b, tools, decode');
			return 0;
		}
	}

}

signal_add("message public", "public_question");
signal_add("message own_public", "own_question");
