# E3 2015 countdown

# adds public countdown command

# ver 1.0 
#   - initial release

use Irssi;
use strict;
use Time::Local;
use vars qw($VERSION %IRSSI);

$VERSION = "1.0";
%IRSSI = (
    authors     => 'Mikko \'Quidz\' Salmi',
    name        => 'E3',
    contact	=> 'mikko@quidz.net',
    description => 'adds public channel command for counting down something',
    license     => 'Public Domain',
    changed	=> 'Mon Mar 30 18:59:17 EET 2015'
);

Irssi::settings_add_str('misc','e3_target','2015 06 16 09 00 00');
Irssi::settings_add_str('misc','e3_message','Countdown to E3 2015 - June 16th to 18th:');
Irssi::settings_add_str('misc','e3_command','!e3');
Irssi::settings_add_str('misc','e3_chan','#Halo5');

sub sig_public {
	my ($server, $msg, $nick, $address, $target) = @_;
	my $ctarget = Irssi::settings_get_str("e3_target");
	my $cinfo = Irssi::settings_get_str("e3_message");
	my $ccmd = Irssi::settings_get_str("e3_command");
	my $cchan = Irssi::settings_get_str("e3_chan");
	if ($msg eq $ccmd and lc($target) eq lc($cchan))
	{
		if ($ctarget =~ /^(\d+?) (\d+?) (\d+?) (\d+?) (\d+?) (\d+?)$/)
		{
			my $sec = timelocal($6,$5,$4,$3,$2-1,$1-1900);
			$sec -= time;
			my $min = ($sec/60)-(($sec%60)/60);
			my $hour = ($min/60)-(($min%60)/60);
			my $day = ($hour/24)-(($hour%24)/24);
			$sec = ($sec%60);
			$min = ($min%60);
			$hour = ($hour%24);
			if ($day) { $cinfo = $cinfo." $day"."d"; }
			if ($hour) { $cinfo = $cinfo." $hour"."h"; }
			if ($min) { $cinfo = $cinfo." $min"."m"; }
			if ($sec) { $cinfo = $cinfo." $sec"."s"; }
			$server->command("msg $target $cinfo");
		} else
		{
			Irssi::print("Error: e3.pl misc.countdown_target should be format <year> <month> <day> <hour> <minute> <second>");
		}
	}
}

Irssi::signal_add_last('message public', 'sig_public');
Irssi::print("Script : e3.pl loaded");
