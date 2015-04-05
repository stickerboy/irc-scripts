#8-ball / decision ball
#
#What is this?
#
#The 8-ball (Eight-ball) is a decision ball which i bought
#in a gadget shop when i was in London. I then came up with 
#the idea to make an irc-version of this one :)
#There are 16 possible answers that the ball may give you.
#
#
#usage   
#
#Anyone in the same channel as the one who runs this script may
#write "8-ball: question ?" without quotes and where question is
#a question to ask the 8-ball. 
#An answer is given randomly. The possible answers are the exact
#same answers that the real 8-ball gives.
#
#Write "8-ball" without quotes to have the the ball tell you
#how money questions it've got totally.
#
#Write "8-ball version" without quotes to have him tell what
#his version is.
#
#
use strict;
use vars qw($VERSION %IRSSI);

use Irssi qw(command_bind signal_add);
use IO::File;
$VERSION = 'A girl never tells her age ;)'; #'0.21';
%IRSSI = (
	authors		=> 'Patrik Jansson',
	contact		=> 'gein@knivby.nu',
	name		=> '8-ball',
	description	=> 'Dont like to take decisions? Have the 8-ball do it for you instead.',
	license		=> 'GPL',
);

sub own_question {
	my ($server, $msg, $target) = @_;
	question($server, $msg, "", $target);
}

sub public_question {
	my ($server, $msg, $nick, $address, $target) = @_;
	question($server, $msg, $nick.": ", $target);
}
sub question {
	my ($server, $msg, $nick, $target) = @_;
	$_ = $msg;

	if (!/^!ask|!sudo/i) { return 0; }

	if (/^!sudo .+$/i){
		$server->command('msg '.$target.' You are not un the sudoers file, this incident has been reported');
		return 0;
	}

	if (/^!ask .+\?$/i) {
		my $ia = int(rand(60));
		my $answer = "";
		SWITCH: {
		 if ($ia==0) { $answer = "Yes"; last SWITCH; }
		 if ($ia==1) { $answer = "No"; last SWITCH; }
 		 if ($ia==2) { $answer = "Outlook so so"; last SWITCH; }
		 if ($ia==3) { $answer = "Absolutely"; last SWITCH; }
		 if ($ia==4) { $answer = "My sources say no"; last SWITCH; }
	 	 if ($ia==5) { $answer = "Yes definitely"; last SWITCH; }
		 if ($ia==6) { $answer = "Very doubtful"; last SWITCH; }
	 	 if ($ia==7) { $answer = "Most likely"; last SWITCH; }
		 if ($ia==8) { $answer = "Forget about it"; last SWITCH; }
		 if ($ia==9) { $answer = "Are you kidding?"; last SWITCH; }
		 if ($ia==10) { $answer = "Go for it"; last SWITCH; }
		 if ($ia==11) { $answer = "Not now"; last SWITCH; }
		 if ($ia==12) { $answer = "Looking good"; last SWITCH; }
		 if ($ia==13) { $answer = "Who knows"; last SWITCH; }
		 if ($ia==14) { $answer = "A definite yes"; last SWITCH; }
		 if ($ia==15) { $answer = "You will have to wait"; last SWITCH; }
		 if ($ia==16) { $answer = "Yes, in due time"; last SWITCH; }
       		 if ($ia==17) { $answer = "I have my doubts"; last SWITCH; }
     		 if ($ia==18) { $answer = "If it was not for the Grollo chasing me, I'd give you a definitive answer on that"; last SWITCH; }
		 if ($ia==19) { $answer = "You have incurred the wrath of Crota, do not speak of that again"; last SWITCH; }
     		 if ($ia==20) { $answer = "Yes...wait, no...I mean, ok imma google that real quick"; last SWITCH; }
     		 if ($ia==21) { $answer = "BWAHAHAHAAHahahahahahah....no"; last SWITCH; }
     		 if ($ia==22) { $answer = "Are you for real right now?"; last SWITCH; }	
     		 if ($ia==23) { $answer = "I asked myself that same thing just last week..."; last SWITCH; }
if ($ia==24) { $answer = "You know, in some galactic timezones... I might actually give a crap about answering that question"; last SWITCH; }
if ($ia==25) { $answer = "Well if you have to ask..."; last SWITCH; }
if ($ia==26) { $answer = "Who knows, not me that is for sure!"; last SWITCH; }
if ($ia==27) { $answer = "42. That sounds about right"; last SWITCH; }
if ($ia==28) { $answer = "Ask me again tomorrow"; last SWITCH; }
if ($ia==29) { $answer = "There are 3 possible answers, none of which I can be bothered to give you"; last SWITCH; }
if ($ia==30) { $answer = "That is a great question. They should make a movie about that question!"; last SWITCH; }
if ($ia==31) { $answer = "No, because I am a potato"; last SWITCH; }
if ($ia==32) { $answer = "I never make typos. Sorry did you have a question?"; last SWITCH; }
if ($ia==33) { $answer = "That question made no sense, ask me another"; last SWITCH; }
if ($ia==34) { $answer = "You know, in some galactic timezones... I might actually give a crap about answering that question"; last SWITCH; }
if ($ia==35) { $answer = "rewsna eht wonk ydaerla uoy ,siht daer nac uoy fi"; last SWITCH; }
if ($ia==36) { $answer = "Give me 5 bucks and I will tell you"; last SWITCH; }
if ($ia==37) { $answer = "If there was a prize fo the most amazing question ever asked, that would not even make the list of runners up"; last SWITCH; }
if ($ia==38) { $answer = "Can I not ask the questions for a change? I am quite tired :("; last SWITCH; }
if ($ia==39) { $answer = "Sorry, access that answer has been classified"; last SWITCH; }
if ($ia==40) { $answer = "[ REDACTED ]"; last SWITCH; }
if ($ia==41) { $answer = "| CURIOUS |"; last SWITCH; }
if ($ia==42) { $answer = "I can only answer that question on Yanumas day"; last SWITCH; }
if ($ia==43) { $answer = "That question made no sense, ask me another"; last SWITCH; }
if ($ia==44) { $answer = "That is a question best suited for stckr. He his awesome, he knows all sorts of cool stuff :)"; last SWITCH; }
if ($ia==45) { $answer = "Have you asked SepheusIX? He might know"; last SWITCH; }
if ($ia==46) { $answer = "Hm, I think MrToasty might know that one"; last SWITCH; }
if ($ia==47) { $answer = "Slap devoltar a few times, he might tell you"; last SWITCH; }
if ($ia==48) { $answer = "I could tell you, but dtape467 explains it much better"; last SWITCH; }
if ($ia==49) { $answer = "You should ask Darkseide, he will know"; last SWITCH; }
if ($ia==50) { $answer = "If you give LordHookocho a potato, well he might not tell you but he will be very happy :)"; last SWITCH; }
if ($ia==51) { $answer = "Hey KeturahVII! You want to field this one?"; last SWITCH; }
if ($ia==52) { $answer = "I don not think I can answer that, but Calliber can"; last SWITCH; }
if ($ia==53) { $answer = "I would prod Furiousn00b about that one instead"; last SWITCH; }
if ($ia==54) { $answer = "That is TheUngodlyOne\'s speciality, he should answer that"; last SWITCH; }
if ($ia==55) { $answer = "Hold that thought. I will call in the specialists!"; last SWITCH; }
if ($ia==56) { $answer = "Shh... saying stuff like that can get you banned >.>"; last SWITCH; }
if ($ia==57) { $answer = "I could answer that question, but it may be considered a leek <.< http://imgur.com/X9LOE5k"; last SWITCH; }
if ($ia==58) { $answer = "SORRY I BROKE MY CAPSLOCK KEY, RAINCHECK ON THAT?"; last SWITCH; }
if ($ia==59) { $answer = "What do you think I am, a bot or something?"; last SWITCH; }
if ($ia==60) { $answer = "Oh wait..I..I know this one..I actually know...oh it\'s gone. Sorry :("; last SWITCH; }
}
		$server->command('msg '.$target.' '.$nick.''.$answer);
	  
                my ($fh, $count);
                $fh = new IO::File;
                $count = 0;
                if ($fh->open("< .8-ball")){
                        $count = <$fh>;
                        $fh->close;
                }
                $count++;
		$fh = new IO::File;
                if ($fh->open("> .8-ball")){
                        print $fh $count;
                        $fh->close;
                }else{
                        print "Couldn't open file for output. The value $count couldn't be written.";
                	return 1;
		}
		return 0;
	} elsif (/^!ask$/i) {
             
		my ($fh, $count);
                $fh = new IO::File;
                $count = 0;
                if ($fh->open("< .8-ball")){
                        $count = <$fh>;
                        $server->command('msg '.$target.' Looks like I\'ve had '.$count.' questions so far. You guys ask me a lot of wierd shit :/');
			$fh->close;
                }else{
                        print "Couldn't open file for input";
			return 1;
                }
		return 0;

	} elsif (/^!ask version$/i){
		$server->command('msg '.$target.' '.$VERSION);
		return 0;
	} elsif (/^!ask what is love$/i){
		$server->command('msg '.$target.' baby don\'t hurt me');
		return 0;
	} else {
		if(!/^8-ball says/i){ 
			$server->command('msg '.$target.' '.$nick.'Going to need that in the form of a question ;)');
			return 0;
		}
	}

}

signal_add("message public", "public_question");
signal_add("message own_public", "own_question");
