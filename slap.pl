#Slap!
#
#What is this?
#
#It's a slap bot
#
#usage   
#
#!slap
#
#!slap <user>
#
use strict;
use vars qw($VERSION %IRSSI);

use Irssi qw(command_bind signal_add);
use IO::File;
$VERSION = 'A girl never tells her age ;)'; #'0.21';
%IRSSI = (
	authors		=> 'Kenny Cameron',
	contact		=> 'irc@stckr.co.uk',
	name		=> 'slap',
	description	=> 'Just whatever you do, do not slap a Grollo! 0__o',
	license		=> 'GPL',
);

sub own_question {
	my ($server, $msg, $target) = @_;
	question($server, $msg, "xxx", $target);
}

sub public_question {
	my ($server, $msg, $nick, $address, $target) = @_;
	question($server, $msg, $nick, $target);
}
sub question {
	my ($server, $msg, $nick, $target) = @_;
	$_ = $msg;

	if (!/^!slap/i) { return 0; }

	if (/^!slap (.+)$/i) {
		my $ia = int(rand(46));
		my $answer = "";
		my $old = $msg;
		my $new = $old =~ s/!slap //i;
		SWITCH: {
		 if ($ia==0) { $answer = "a rusty spoon"; last SWITCH; }
		 if ($ia==1) { $answer = "a Grollo"; last SWITCH; }
 		 if ($ia==2) { $answer = "last weeks dinner"; last SWITCH; }
		 if ($ia==3) { $answer = "the moon"; last SWITCH; }
		 if ($ia==4) { $answer = "a large, inflatable, pink rubber penguin"; last SWITCH; }
	 	 if ($ia==5) { $answer = $nick; last SWITCH; }
		 if ($ia==6) { $answer = "a birthday cake"; last SWITCH; }
	 	 if ($ia==7) { $answer = "LIES"; last SWITCH; }
		 if ($ia==8) { $answer = "Crota\'s toilet"; last SWITCH; }
		 if ($ia==9) { $answer = "some common sense"; last SWITCH; }
		 if ($ia==10) { $answer = "very large salty trout"; last SWITCH; }
		 if ($ia==11) { $answer = "the last person to speak"; last SWITCH; }
		 if ($ia==12) { $answer = "the next person that joins"; last SWITCH; }
		 if ($ia==13) { $answer = "googly eyes"; last SWITCH; }
		 if ($ia==14) { $answer = "a smelly sock"; last SWITCH; }
		 if ($ia==15) { $answer = "the greatest pile of jelly this world has ever seen"; last SWITCH; }
		 if ($ia==16) { $answer = "Chuck Norris"; last SWITCH; }
       		 if ($ia==17) { $answer = "a half eaten banana"; last SWITCH; }
     		 if ($ia==18) { $answer = "last years lunch"; last SWITCH; }
		 if ($ia==19) { $answer = "a pie the size of manhattan"; last SWITCH; }
     		 if ($ia==20) { $answer = "One hundred and seventeen pounds of goose fat"; last SWITCH; }
     		 if ($ia==21) { $answer = "the lurgie"; last SWITCH; }
     		 if ($ia==22) { $answer = "... no, it is too horrible, I cannot even tell you"; last SWITCH; }	
     		 if ($ia==23) { $answer = "an infinite loop"; last SWITCH; }
if ($ia==24) { $answer = "Oleg"; last SWITCH; }
if ($ia==25) { $answer = "a counter-slap"; last SWITCH; }
if ($ia==26) { $answer = "a tarp"; last SWITCH; }
if ($ia==27) { $answer = "IOOBI9O4IEIEOIO4O4IB"; last SWITCH; }
if ($ia==28) { $answer = "kitennbees"; last SWITCH; }
if ($ia==29) { $answer = "//Magic HACK!!!"; last SWITCH; }
if ($ia==30) { $answer = "a nice day, my precious puppet"; last SWITCH; }
if ($ia==31) { $answer = "a mouldy tin of beans"; last SWITCH; }
if ($ia==32) { $answer = "a pack of wild ostriches"; last SWITCH; }
if ($ia==33) { $answer = "Halsey\'s Arm"; last SWITCH; }
if ($ia==34) { $answer = "The Game"; last SWITCH; }
if ($ia==35) { $answer = "an unfinished"; last SWITCH; }
if ($ia==36) { $answer = "the absence of everything"; last SWITCH; }
if ($ia==37) { $answer = "42"; last SWITCH; }
if ($ia==38) { $answer = "a guilty spark"; last SWITCH; }
if ($ia==39) { $answer = "the unholiest of trouts"; last SWITCH; }
if ($ia==40) { $answer = "the slappiest slap that ever did slap"; last SWITCH; }
if ($ia==41) { $answer = "a waft of2binary"; last SWITCH; }
if ($ia==42) { $answer = "the last thing you would ever expect"; last SWITCH; }
if ($ia==43) { $answer = "2 sticks and a rock"; last SWITCH; }
if ($ia==44) { $answer = "better fashion sense"; last SWITCH; }
if ($ia==45) { $answer = "a haircut"; last SWITCH; }
if ($ia==46) { $answer = "a slap. How original of me"; last SWITCH; }
		}
		$server->command('action '.$target.' slaps '.$old.' with '.$answer);
		return 0;
	} 

}

signal_add("message public", "public_question");
signal_add("message own_public", "own_question");
