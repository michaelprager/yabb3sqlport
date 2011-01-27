#!/usr/bin/perl --

###############################################################################
# YaBB.pl                                                                     #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 3.0 Beta                                               #
# Packaged:       October 05, 2010                                            #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2010 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################

### Version Info ###
$YaBBversion = 'YaBB 3.0 Beta';
$YaBBplver = 'YaBB 3.0 Beta $Revision: 100 $';

if ($action eq 'detailedversion') { return 1; }

# use CGI::Carp qw(fatalsToBrowser); # used only for tests

BEGIN {
	# Make sure the module path is present
	push(@INC, "./Modules");

	if ($ENV{'SERVER_SOFTWARE'} =~ /IIS/) {
		$yyIIS = 1;
		$0 =~ m~(.*)(\\|/)~;
		$yypath = $1;
		$yypath =~ s~\\~/~g;
		chdir($yypath);
		push(@INC, $yypath);
	}

	# Modify the following line if your forum main scriptname must be different.
	# The default is: "YaBB". Do this also in AdminIndex.pl!!!
	# Don't forget to modify also all index.html files in the folders!!!
	$yyexec = "YaBB";
	$script_root = $ENV{'SCRIPT_FILENAME'};
	$script_root =~ s/\/$yyexec\.(pl|cgi)//ig;

	require "Paths.pl";
	require "$vardir/Settings.pl";

	# Check for Time::HiRes if debugmodus is on
	if ($debug) { eval { require Time::HiRes; import Time::HiRes qw(time); }; }
	$START_TIME = time();

	require "$sourcedir/Subs.pl";
	require "$sourcedir/System.pl";
	require "$sourcedir/DateTime.pl";
	require "$sourcedir/Load.pl";

	require "$sourcedir/Guardian.pl";
	&get_forum_master;
} # END of BEGIN block

# If enabled: check if hard drive has enough space to safely operate the board
my $hostchecked = &freespace;

# Auto Maintenance Hook
$maintenance = 2 if !$maintenance && -e "$vardir/maintenance.lock";

&LoadCookie;       # Load the user's cookie (or set to guest)
&LoadUserSettings; # Load user settings
&WhatTemplate;     # Figure out which template to be using.
&WhatLanguage;     # Figure out which language file we should be using! :D

# Do this now that language is available
$yyfreespace = $hostchecked < 0 ? $error_txt{'module_missing'} : (($yyfreespace && (($debug == 1 && !$iamguest) || ($debug == 2 && $iamgmod) || $iamadmin)) ? qq~<div>~ . ($hostchecked > 0 ? $maintxt{'freeuserspace'} : $maintxt{'freediskspace'}) . qq~ $yyfreespace</div>~ : '');

if (-e "$vardir/gmodsettings.txt" && $iamgmod) { require "$vardir/gmodsettings.txt"; }
if (!$masterkey) {
	if ($iamadmin || ($iamgmod && $allow_gmod_admin eq 'on' && $gmod_access{"newsettings\;page\=security"} eq 'on')) {
		$yyadmin_alert = $reg_txt{'no_masterkey'};
	}
	$masterkey = $mbname;
}

$formsession = &cloak("$mbname$username");

# check for valid form sessionid in any POST request
if ($ENV{REQUEST_METHOD} =~ /post/i) {
	if ($CGI_query && $CGI_query->cgi_error()) { &fatal_error("denial_of_service", $CGI_query->cgi_error()); }
	if (&decloak($FORM{'formsession'}) ne "$mbname$username" && $action ne 'openidvalidate') {
		&fatal_error("logged_in_already",$username) if $action eq 'login2' && $username ne 'Guest';
		&fatal_error("form_spoofing",$user_ip);
	}
}

if ($is_perm && $accept_permalink) {
	&fatal_error("no_topic_found","$permtitle|C:$permachecktime|T:$threadpermatime") if $permtopicfound == 0;
	&fatal_error("no_board_found","$permboard|C:$permachecktime|T:$threadpermatime") if $permboardfound == 0;
}

&guard;

# Check if the action is allowed from an external domain
if ($referersecurity) { &referer_check; }

if ($regtype == 1 || $regtype == 2) {
	if (-s "$memberdir/memberlist.inactive" > 2) {
		&RegApprovalCheck; &activation_check;
	} elsif (-s "$memberdir/memberlist.approve" > 2) {
		&RegApprovalCheck;
	}
}

require "$sourcedir/Security.pl";

&banning;  # Check for banned people
&LoadIMs;  # Load IM's
&WriteLog; # write into the logfile

$SIG{__WARN__} = sub { &fatal_error("error_occurred","@_"); };
eval { &yymain; };
if ($@) { &fatal_error("untrapped",":<br />$@"); }

sub yymain {
	# Choose what to do based on the form action
	if ($maintenance) {
		if    ($action eq 'login2')    { require "$sourcedir/LogInOut.pl"; &Login2; }
		# Allow password reminders in case admins forgets their admin password
		elsif ($action eq 'reminder')  { require "$sourcedir/LogInOut.pl"; &Reminder; }
		elsif ($action eq 'validate')  { require "$sourcedir/Decoder.pl"; &convert; }
		elsif ($action eq 'reminder2') { require "$sourcedir/LogInOut.pl"; &Reminder2; }
		elsif ($action eq 'resetpass') { require "$sourcedir/LogInOut.pl"; &Reminder3; }

		if (!$iamadmin) { require "$sourcedir/LogInOut.pl"; &InMaintenance; }
	}

	# Guest can do the very few following actions
	&KickGuest if $iamguest && !$guestaccess && $action !~ /^(login|register|reminder|validate|activate|resetpass|guestpm|checkavail|$randaction)2?$/;

	if ($action ne "") {
		if ($action eq $randaction) {
			require "$sourcedir/Decoder.pl"; &convert;
		} else {
			require "$sourcedir/SubList.pl";
			if ($director{$action}) {
				my @act = split(/&/, $director{$action});
				require "$sourcedir/$act[0]";
				&{$act[1]};
			} else {
				require "$sourcedir/BoardIndex.pl";
				&BoardIndex;
			}
		}
	} elsif ($INFO{'num'} ne "") {
		require "$sourcedir/Display.pl";
		&Display;
	} elsif ($currentboard eq "") {
		require "$sourcedir/BoardIndex.pl";
		&BoardIndex;
	} else {
		require "$sourcedir/MessageIndex.pl";
		&MessageIndex;
	}
}

# Those who write software only for pay should go hurt some other field.
# - Erik Naggum

1;