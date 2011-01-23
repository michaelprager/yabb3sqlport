#!/usr/bin/perl --

###############################################################################
# Setup.pl                                                                    #
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

$setupplver = 'YaBB 3.0 Beta $Revision: 100 $';

# use CGI::Carp qw(fatalsToBrowser); # used only for tests

# conversion will stop after $max_process_time
# in seconds, than the browser will call the script
# again until all is done. Don't put it too high
# or you will run into server or browser timeout
$max_process_time = 20;
$time_to_jump = time() + $max_process_time;

if ($ENV{'SERVER_SOFTWARE'} =~ /IIS/) {
	$yyIIS = 1;
	$0 =~ m~(.*)(\\|/)~;
	$yypath = $1;
	$yypath =~ s~\\~/~g;
	chdir($yypath);
	push(@INC, $yypath);
}

### Requirements and Errors ###
$script_root = $ENV{'SCRIPT_FILENAME'};
$script_root =~ s/\/Setup\.(pl|cgi)//ig;

if (-e "./Paths.pl") { require "./Paths.pl"; }
elsif (-e "$script_root/Paths.pl") { require "$script_root/Paths.pl"; }
elsif (-e "$script_root/Variables/Paths.pl") { require "$script_root/Variables/Paths.pl"; }

# Check if it's blank Paths.pl or filled in one
unless ($lastsaved) {
	$boardsdir = "./Boards";
	$sourcedir = "./Sources";
	$memberdir = "./Members";
	$vardir    = "./Variables";
}

if (-e "YaBB.cgi") { $yyext = "cgi"; }
else { $yyext = "pl"; }
if ($boardurl) { $set_cgi = "$boardurl/Setup.$yyext"; }
else { $set_cgi = "Setup.$yyext"; }

# Make sure the module path is present
push(@INC, "./Modules");

require "$sourcedir/Subs.pl";
require "$sourcedir/System.pl";
require "$sourcedir/Load.pl";
require "$sourcedir/DateTime.pl";

$windowbg = '#FEFEFE';
$windowbg2 = '#DDE3EB';
$header = '#6699CC';
$catbg = '#ADC7E1';
$maintext_23 = 'Unable to open';

$yymenu = '';
$yytabmenu = qq~&nbsp;~;

#############################################
# Conversion starts here                    #
#############################################

# Conversion was rewritten and fixed for xx-large
# forums by Detlef Pilzecker (deti) in June 2008

# The 'our' function is avaliable sincee Perl v5.6.0
# If your Perl version is lower, then comment the 'our'-lines out and use this:
# use vars qw(@categoryorder,@catboards,@catdata,@boarddata,@allboards,%catinfo,%cat,%board,%boarddata,$catfile,$boardfile,$key,$value,$cnt);
our (@categoryorder, @catboards, @catdata, @boarddata, @allboards);
our (%catinfo, %cat, %board, %boarddata);
our ($catfile, $boardfile, $key, $value, $cnt);
our (%fixed_users);

if (-e "$vardir/Setup.lock") {
	&FoundConvLock if -e "$vardir/Converter.lock";

	if (-e "$vardir/fixusers.txt") {
		fopen(FIXUSER, "$vardir/fixusers.txt") || &setup_fatal_error("$maintext_23 $vardir/fixusers.txt: ", 1);
		my @fixed = <FIXUSER>;
		fclose(FIXUSER);
		foreach (@fixed) {
			my ($user, $fixedname, undef, $displayedname, undef) = split(/\|/, $_);
			@{$fixed_users{$user}} = ($fixedname,$displayedname);
		}
	}

	&tempstarter;
	&tabmenushow;

	if ($action && !$INFO{'convert'}) {
		# needed for: sub conv_stringtotime
		require Time::Local;
		import Time::Local 'timelocal';

	} elsif (!$action || $INFO{'convert'}) {
		$yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink4 . $NavLink5 . $NavLink6;

		$yymain = qq~
	<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
	<form action="$set_cgi?action=prepare" method="post">
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr valign="middle">
			<td width="100%" colspan="2" class="titlebg" align="left">
			YaBB 2 Converter
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/thread.gif" alt="" />
			</td>
			<td class="windowbg2" align="left" style="font-size: 11px;">
			Make sure your YaBB 2 installation is running and that it has all the correct folder paths and URLs.<br />
			Proceed through the following steps to convert your YaBB 1 Gold - SP 1.x forum to YaBB 2!<br /><br />
			<b>If</b> your YaBB 1 Gold - SP 1.x forum is located on the same server as your YaBB 2 installation:
			<ol>
			<li>Insert the path to your YaBB 1 Gold - SP 1.x forum in the input field below</li>
			<li>Click on the 'Continue' button</li>
			</ol>
			<b>Else</b> if your YaBB 1 Gold - SP 1.x forum is located on a different server than your YaBB 2 installation or if you dont know the path to your SP 1.x forum:
			<ol>
			<li>Copy all files in the /Boards, /Members, and /Messages folders from your YaBB 1 Gold - SP 1.x installation, to the corresponding Convert/Boards,
			Convert/Members, and Convert/Messages folders of your YaBB 2 installation, and chmod them 777.</li>
			<li>Copy cat.txt from the /Variables folder of your YaBB 1 Gold - SP 1.x installation to the Convert/Variables folder of your YaBB 2 installation, and chmod it 666.</li>
			<li>If you have 'Add More Membergroups' installed on your YaBB 1 Gold - SP 1.x, copy MemberStats.txt from the /Variables folder of your YaBB 1 Gold - SP 1.x installation to the Convert/Variables folder of your YaBB 2 installation, and chmod it 666.</li>

			<li>Click on the 'Continue' button</li>
			</ol>
			<div style="width: 100%; text-align: center;">
			<b>Path to your YaBB 1 Gold - SP 1.x files: </b> <input type="text" name="convertdir" value="$convertdir" size="50" />
			</div>
			<br />
			</td>
		</tr>
		<tr valign="middle">
			<td width="100%" colspan="2" class="catbg" align="center">
			<input type="submit" value="Continue" />
			</td>
		</tr>
		</table>
	</form>
	</div>
		~;
	}

	if ($action eq "prepare") {
		&UpdateCookie("delete");

		$username = 'Guest';
		$iamguest = '1';
		$iamadmin = '';
		$iamgmod = '';
		$password = '';
		$yyim = '';
		$ENV{'HTTP_COOKIE'} = '';
		$yyuname = '';

		$convertdir = $FORM{'convertdir'};

		if (!-d "$convertdir/Boards") { &setup_fatal_error("Directory: $convertdir/Boards", 1); }
		else { $convboardsdir = "$convertdir/Boards"; }
		if (!-e "$convertdir/Members/memberlist.txt") { &setup_fatal_error("Directory: $convertdir/Members", 1); }
		else { $convmemberdir = "$convertdir/Members"; }
		if (!-d "$convertdir/Messages") { &setup_fatal_error("Directory: $convertdir/Messages", 1); }
		else { $convdatadir = "$convertdir/Messages"; }
		if (!-e "$convertdir/Variables/cat.txt") { &setup_fatal_error("Directory: $convertdir/Variables", 1); }
		else { $convvardir = "$convertdir/Variables"; }


		my $setfile = << "EOF";
\$convertdir = qq~$convertdir~;
\$convboardsdir = qq~$convertdir/Boards~;
\$convmemberdir = qq~$convertdir/Members~;
\$convdatadir = qq~$convertdir/Messages~;
\$convvardir = qq~$convertdir/Variables~;

1;
EOF

		fopen(SETTING, ">$vardir/ConvSettings.txt") || &setup_fatal_error("$maintext_23 $vardir/ConvSettings.txt: ", 1);
		print SETTING &nicely_aligned_file($setfile);
		fclose(SETTING);

		$yytabmenu = $NavLink1a . $NavLink2 . $NavLink3 . $NavLink4 . $NavLink5 . $NavLink6;

		$yymain = qq~
	<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr valign="middle">
			<td width="100%" colspan="2" class="titlebg" align="left">
			YaBB 2 Converter
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/thread.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left" style="font-size: 11px;">
			<ul>
			<li>Members info found in: <b>$convmemberdir</b></li>
			<li>Board and Category info found in: <b>$convboardsdir</b></li>
			<li>Messages info found in: <b>$convdatadir</b></li>
			<li>cat.txt found in: <b>$convvardir</b></li>
			</ul>
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/info.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left" style="font-size: 11px;">
			- Conversion can take a long time depending on the size of your forum (30 seconds to a couple hours).<br />
			- Your browser will be refreshed automaticly every $max_process_time seconds and you will see the ongoing process in the status bar.<br />
			- Some internet connections refresh their IP-Adress automaticly every 24 hours.<br />
			&nbsp; Make sure that your IP-Adress will not change during conversion, or you must restart the conversion after that! <br />
			- Your forum will be set to maintenance while converting.
			<p id="memcontinued">Click on 'Members' in the menu to start.<br />&nbsp;</p>
			</td>
		</tr>
		</table>
	</div>

	<script type="text/javascript">
	<!--
		function PleaseWait() {
			document.getElementById("memcontinued").innerHTML = '<font color="red"><b>Converting - please wait!<br />If you want to stop \\'Members\\' conversion, click here on STOP before this red message apears again on next page.</b></font>';
		}
	// -->
	</script>
		~;


	} elsif ($action eq "members") {
		unless (exists $INFO{'mstart1'}) { &PrepareConv; }

		$INFO{'mstart2'} ? &ConvertMembers2 : &ConvertMembers1;

		$yytabmenu = $NavLink1 . $NavLink2a . $NavLink3 . $NavLink4 . $NavLink5 . $NavLink6;

		$yymain = qq~
	<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr valign="middle">
			<td width="100%" colspan="2" class="titlebg" align="left">
			YaBB 2 Converter
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/thread.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left">
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Member Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Board and Category Conversion.</div>
			$ConvNotDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Message Conversion.</div>
			$ConvNotDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Date & Time Conversion.</div>
			$ConvNotDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Final Cleanup.</div>
			$ConvNotDone
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/info.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left" style="font-size: 11px;">
			New User data files have been created.<br />
			Password encryption is done for each user the first time he/she logs in.<br />
			<br />
			You are converting <i>~ . int(($INFO{'st'} + 60)/60) . qq~ minutes</i>.<br />
			<br />
			<p id="memcontinued">Click on 'Boards & Categories' in the menu to continue.<br />
			If you don't do that the script will continue itself in 5 Minutes.</p>
			</td>
		</tr>
		</table>
	</div>

	<script type="text/javascript">
	<!--
		function PleaseWait() {
			document.getElementById("memcontinued").innerHTML = '<font color="red"><b>Converting - please wait!<br />If you want to stop \\'Boards & Categories\\' conversion, click here on STOP before this red message apears again on next page.</b></font>';
		}

		function membtick() {
			 PleaseWait();
			 location.href="$set_cgi?action=cats;st=$INFO{'st'}";
		}

		setTimeout("membtick()",300000);
	// -->
	</script>
		~;

		if (-e "$vardir/fixusers.txt") {

			fopen(FIXUSER, "$vardir/fixusers.txt") || &setup_fatal_error("$maintext_23 $vardir/fixusers.txt: ", 1);
			my @fixed = <FIXUSER>;
			fclose(FIXUSER);
			chomp(@fixed);

			$yymain .= qq~
	<br />
	<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
	<table width="100%" cellspacing="1" cellpadding="4">
		<tr>
		<td align="left" class="windowbg" colspan="5">
		 Member(s) with illegal username(s) were found and converted to legal name(s).<br />
		 You can find this informations in the <i>$vardir/fixusers.txt</i> file. If you don't need it, you can delete it later.
		</td>
		<tr>
		<td align="center" class="catbg">Invalid name</td>
		<td align="center" class="catbg">Fixed name</td>
		<td align="center" class="catbg">Reg. date</td>
		<td align="center" class="catbg">Displayed name</td>
		<td align="center" class="catbg">E-mail</td>
		</tr>
			~;
			foreach $userfixed (@fixed) {
				($inname, $fxname, $rgdate, $dspname, $tmail) = split(/\|/, $userfixed);
				$yymain .= qq~
		<tr>
		<td align="left" class="windowbg2">$inname</td>
		<td align="left" class="windowbg2">$fxname</td>
		<td align="left" class="windowbg2">$rgdate</td>
		<td align="left" class="windowbg2">$dspname</td>
		<td align="left" class="windowbg2">$tmail</td>
		</tr>
				~;
			}
			$yymain .= qq~
	</table>
	</div>
			~;
		}


	} elsif ($action eq "members2") {
		&setup_fatal_error("Member conversion (members2) 'mstart1' ($INFO{'mstart1'}), 'mstart2' ($INFO{'mstart2'}) error!") if $INFO{'mstart1'} <= 0 || $INFO{'mstart2'} < 0;

		$yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink4 . $NavLink5 . $NavLink6;

		my $mwidth = int((($INFO{'mstart2'} + $INFO{'mstart1'}) / 2) / $INFO{'mtotal'} * 100);

		$yymain = qq~
	<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr valign="middle">
			<td width="100%" colspan="2" class="titlebg" align="left">
			YaBB 2 Converter
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/thread.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left">
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Member Conversion.</div>
			<div style="float: left; width: 102px; height: 10px; margin: 1px; background-color: #dddddd; border: 1px black solid; font-size: 5px;">
			<div style="position: relative; top: 0px; left: 0px; width: $mwidth\px; height: 10px; margin: 0px; background-color: #6699cc; border: 0px; font-size: 5px;">&nbsp;</div>
			</div>
			<div style="float: left; width: 50px; height: 14px; text-align: right; color: #FF3333;">$mwidth %</div><br />
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Board and Category Conversion.</div>
			$ConvNotDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Message Conversion.</div>
			$ConvNotDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Date & Time Conversion.</div>
			$ConvNotDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Final Cleanup.</div>
			$ConvNotDone
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/info.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left" style="font-size: 11px;">
			To prevent server time-out due to the amount of members to be converted, the conversion is split into more steps.<br />
			<br />
			The time-step (\$max_process_time) is set to <i>$max_process_time seconds</i>.<br />
			The last step took <i>~ . ($time_to_jump - $INFO{'starttime'}) . qq~ seconds</i>.<br />
			You are converting <i>~ . int(($INFO{'st'} + 60)/60) . qq~ minutes</i>.<br />
			<br />
			There are <b>~ . int($INFO{'mtotal'} - (($INFO{'mstart2'} + $INFO{'mstart1'}) / 2)) . qq~/$INFO{'mtotal'}</b> Members left to be converted.<br />

			<p id="memcontinued">If nothing happens in 5 seconds <a href="$set_cgi?action=members;st=$INFO{'st'};mstart1=$INFO{'mstart1'};mstart2=$INFO{'mstart2'}" onclick="PleaseWait();">click here to continue</a>...<br />If you want to <a href="javascript:stoptick();">STOP 'Members' conversion click here</a>. Then copy the actual browser adress and type it in when you are going to continue the conversion.</p>
			</td>
		</tr>
		</table>
	</div>

	<script type="text/javascript">
	<!--
		function PleaseWait() {
			document.getElementById("memcontinued").innerHTML = '<font color="red"><b>Converting - please wait!<br />If you want to stop \\'Members\\' conversion, click here on STOP before this red message apears again on next page.</b></font>';
		}

		function stoptick() { stop = 1; }

		stop = 0;
		function membtick() {
			if (stop != 1) {
				PleaseWait();
				location.href="$set_cgi?action=members;st=$INFO{'st'};mstart1=$INFO{'mstart1'};mstart2=$INFO{'mstart2'}";
			}
		}

		setTimeout("membtick()",2000);
	// -->
	</script>
		~;


	} elsif ($action eq "cats") {
		unless (exists $INFO{'bstart'} && exists $INFO{'bfstart'}) {
			&GetCats;
			&CreateControl;
		}
		&ConvertBoards;

		$yytabmenu = $NavLink1 . $NavLink2 . $NavLink3a . $NavLink4 . $NavLink5 . $NavLink6;

		$yymain = qq~
	<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr valign="middle">
			<td width="100%" colspan="2" class="titlebg" align="left">
			YaBB 2 Converter
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/thread.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left">
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Member Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Board and Category Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Message Conversion.</div>
			$ConvNotDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Date & Time Conversion.</div>
			$ConvNotDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Final Cleanup.</div>
			$ConvNotDone
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/info.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left" style="font-size: 11px;">
			New forum.master file has been created.<br />
			New forum.control file has been created.<br />
			All dates in files have been converted to timestamps.<br />
			All threads have been converted.<br />
			<br />
			You are converting <i>~ . int(($INFO{'st'} + 60)/60) . qq~ minutes</i>.<br />
			<br />
			<p id="memcontinued">Click on 'Messages' in the menu to continue.<br />
			If you don't do that the script will continue itself in 5 Minutes.</p>
			</td>
		</tr>
		</table>
	</div>

	<script type="text/javascript">
	<!--
		function PleaseWait() {
			document.getElementById("memcontinued").innerHTML = '<font color="red"><b>Converting - please wait!<br />If you want to stop \\'Messages\\' conversion, click here on STOP before this red message apears again on next page.</b></font>';
		}

		function membtick() {
			 PleaseWait();
			 location.href="$set_cgi?action=messages;st=$INFO{'st'}";
		}

		setTimeout("membtick()",300000);
	// -->
	</script>
		~;


	} elsif ($action eq "cats2") {
		&setup_fatal_error("Boards conversion (cats2) 'bstart' ($INFO{'bstart'}) or 'bfstart' ($INFO{'bfstart'}) error!") if (!$INFO{'bstart'} && !$INFO{'bfstart'}) || $INFO{'bstart'} < 0 || $INFO{'bfstart'} < 0;

		$yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink4 . $NavLink5 . $NavLink6;

		my $bwidth = int($INFO{'bstart'} / $INFO{'btotal'} * 100);

		$yymain = qq~
	<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr valign="middle">
			<td width="100%" colspan="2" class="titlebg" align="left">
			YaBB 2 Converter
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/thread.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left">
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Member Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Board and Category Conversion.</div>
			<div style="float: left; width: 102px; height: 10px; margin: 1px; background-color: #dddddd; border: 1px black solid; font-size: 5px;">
			<div style="position: relative; top: 0px; left: 0px; width: $bwidth\px; height: 10px; margin: 0px; background-color: #6699cc; border: 0px; font-size: 5px;">&nbsp;</div>
			</div>
			<div style="float: left; width: 50px; height: 14px; text-align: right; color: #FF3333;">$bwidth %</div><br />
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Message Conversion.</div>
			$ConvNotDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Date & Time Conversion.</div>
			$ConvNotDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Final Cleanup.</div>
			$ConvNotDone
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/info.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left" style="font-size: 11px;">
			<div>
			To prevent server time-out due to the amount of boards to be converted, the conversion is split into more steps.<br />
			<br />
			The time-step (\$max_process_time) is set to <i>$max_process_time seconds</i>.<br />
			The last step took <i>~ . ($time_to_jump - $INFO{'starttime'}) . qq~ seconds</i>.<br />
			You are converting <i>~ . int(($INFO{'st'} + 60)/60) . qq~ minutes</i>.<br />
			<br />
			There are <b>~ . ($INFO{'btotal'} - $INFO{'bstart'}) . qq~/$INFO{'btotal'}</b> Boards left to be converted.<br />
			</div>
			<p id="memcontinued">If nothing happens in 5 seconds <a href="$set_cgi?action=cats;st=$INFO{'st'};bstart=$INFO{'bstart'};bfstart=$INFO{'bfstart'}" onclick="PleaseWait();">click here to continue</a>...<br />If you want to <a href="javascript:stoptick();">STOP 'Boards & Categories' conversion click here</a>. Then copy the actual browser adress and type it in when you are going to continue the conversion.</p>
			</td>
		</tr>
		</table>
	</div>

	<script type="text/javascript">
	<!--
		function PleaseWait() {
			document.getElementById("memcontinued").innerHTML = '<font color="red"><b>Converting - please wait!<br />If you want to stop \\'Boards & Categories\\' conversion, click here on STOP before this red message apears again on next page.</b></font>';
		}

		function stoptick() { stop = 1; }

		stop = 0;
		function membtick() {
			if (stop != 1) {
				PleaseWait();
				location.href="$set_cgi?action=cats;st=$INFO{'st'};bstart=$INFO{'bstart'};bfstart=$INFO{'bfstart'}";
			}
		}

		setTimeout("membtick()",2000);
	// -->
	</script>
		~;


	} elsif ($action eq "messages") {
		&ConvertMessages;

		$yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink4a . $NavLink5 . $NavLink6;

		$yymain = qq~
	<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr valign="middle">
			<td width="100%" colspan="2" class="titlebg" align="left">
			YaBB 2 Converter
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/thread.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left">
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Member Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Board and Category Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Message Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Date & Time Conversion.</div>
			$ConvNotDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Final Cleanup.</div>
			$ConvNotDone
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/info.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left" style="font-size: 11px;">
			New style message files have been created.<br />
			<br />
			<i>$INFO{'total_threads'}</i> Threads have been converted.<br />
			<i>$INFO{'total_mess'}</i> Messages have been converted.<br />
			<br />
			You are converting <i>~ . int(($INFO{'st'} + 60)/60) . qq~ minutes</i>.<br />
			<br />
			<p id="memcontinued">Click on 'Date & Time' in the menu to continue.<br />
			If you don't do that the script will continue itself in 5 Minutes.</p>
			</td>
		</tr>
		</table>
	</div>

	<script type="text/javascript">
	<!--
		function PleaseWait() {
			document.getElementById("memcontinued").innerHTML = '<font color="red"><b>Converting - please wait!<br />If you want to stop \\'Date & Time\\' conversion, click here on STOP before this red message apears again on next page.</b></font>';
		}

		function membtick() {
			 PleaseWait();
			 location.href="$set_cgi?action=dates;st=$INFO{'st'}";
		}

		setTimeout("membtick()",300000);
	// -->
	</script>
		~;


	} elsif ($action eq "messages2") {
		&setup_fatal_error("Message conversion (messages2) 'count' ($INFO{'count'}) or 'tcount' ($INFO{'tcount'}) error!", 1) if (!$INFO{'count'} && !$INFO{'tcount'}) || $INFO{'count'} < 0 || $INFO{'tcount'} < 0;

		my $bwidth = int($INFO{'count'} / $INFO{'totboard'} * 100);
		my $mwidth = $INFO{'totmess'} ? int($INFO{'tcount'} / $INFO{'totmess'} * 100) : 0;

		$yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink4 . $NavLink5 . $NavLink6;

		$yymain = qq~
	<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr valign="middle">
			<td width="100%" colspan="2" class="titlebg" align="left">
			YaBB 2 Converter
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/thread.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left">
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Member Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Board and Category Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Message Conversion.</div>
			<div style="float: left; width: 102px; height: 10px; margin: 1px; background-color: #dddddd; border: 1px black solid; font-size: 5px;">
			<div style="position: relative; top: 0px; left: 0px; width: $bwidth\px; height: 10px; margin: 0px; background-color: #6699cc; border: 0px; font-size: 5px;">&nbsp;</div>
			</div>
			<div style="float: left; width: 50px; height: 14px; text-align: right; color: #FF3333;">$bwidth %</div><br />
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Date & Time Conversion.</div>
			$ConvNotDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Final Cleanup.</div>
			$ConvNotDone
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/info.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left" style="font-size: 11px;">
			To prevent server time-out due to the amount of messages to be converted, the conversion is split into more steps.<br />
			<br />
			The time-step (\$max_process_time) is set to <i>$max_process_time seconds</i>.<br />
			The last step took <i>~ . ($time_to_jump - $INFO{'starttime'}) . qq~ seconds</i>.<br />
			You are converting <i>~ . int(($INFO{'st'} + 60)/60) . qq~ minutes</i>.<br />
			<br />
			<i>$INFO{'total_threads'}</i> Threads where converted until now.<br />
			<i>$INFO{'total_mess'}</i> Messages where converted until now.<br />
			<br />
			There are <b>~ . ($INFO{'totboard'} - $INFO{'count'}) . qq~/$INFO{'totboard'}</b> Boards left, to convert the Messages in.<br />
			<div style="float: left;">There are <b>~ . ($INFO{'totmess'} - $INFO{'tcount'}) . qq~/$INFO{'totmess'}</b> Threads left in the actual Board to be converted. &nbsp; </div>
			<div style="float: left; width: 100px; height: 10px; margin: 1px; background-color: #dddddd; border: 1px black solid; font-size: 5px;">
			<div style="position: relative; top: 0px; left: 0px; width: $mwidth\px; height: 10px; margin: 0px; background-color: #6699cc; border: 0px; font-size: 5px;">&nbsp;</div>
			</div>
			<div style="float: left; width: 50px; height: 14px; text-align: right; color: #FF3333;">$mwidth %</div><br />

			<p id="memcontinued">If nothing happens in 5 seconds <a href="$set_cgi?action=messages;st=$INFO{'st'};count=$INFO{'count'};tcount=$INFO{'tcount'};total_mess=$INFO{'total_mess'};total_threads=$INFO{'total_threads'}" onclick="PleaseWait();">click here to continue</a>...<br />If you want to <a href="javascript:stoptick();">STOP 'Messages' conversion click here</a>. Then copy the actual browser adress and type it in when you are going to continue the conversion.</p>
			</td>
		</tr>
		</table>
	</div>

	<script type="text/javascript">
	<!--
		function PleaseWait() {
			document.getElementById("memcontinued").innerHTML = '<font color="red"><b>Converting - please wait!<br />If you want to stop \\'Messages\\' conversion, click here on STOP before this red message apears again on next page.</b></font>';
		}

		function stoptick() { stop = 1; }

		stop = 0;
		function membtick() {
			if (stop != 1) {
				PleaseWait();
				location.href="$set_cgi?action=messages;st=$INFO{'st'};count=$INFO{'count'};tcount=$INFO{'tcount'};total_mess=$INFO{'total_mess'};total_threads=$INFO{'total_threads'}";
			}
		}

		setTimeout("membtick()",2000);
	// -->
	</script>
		~;


	} elsif ($action eq "dates") {
		&ConvertTimeToString;

		$yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink4 . $NavLink5a . $NavLink6;

		$yymain = qq~
	<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr valign="middle">
			<td width="100%" colspan="2" class="titlebg" align="left">
			YaBB 2 Converter
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/thread.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left">
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Member Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Board and Category Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Message Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Date & Time Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Final Cleanup.</div>
			$ConvNotDone
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/info.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left" style="font-size: 11px;">
			New style timestamps have been created throughout the board. All old style dates have been converted.<br />
			<br />
			You are converting <i>~ . int(($INFO{'st'} + 60)/60) . qq~ minutes</i>.<br />
			<br />
			<p id="memcontinued">Click on 'Clean Up' in the menu to continue.<br />
			If you don't do that the script will continue itself in 5 Minutes.</p>
			</td>
		</tr>
		</table>
	</div>

	<script type="text/javascript">
	<!--
		function PleaseWait() {
			document.getElementById("memcontinued").innerHTML = '<font color="red"><b>Converting - please wait!<br />If you want to stop \\'Clean Up\\', click here on STOP before this red message apears again on next page.</b></font>';
		}

		function membtick() {
			 PleaseWait();
			 location.href="$set_cgi?action=cleanup;st=$INFO{'st'}";
		}

		setTimeout("membtick()",300000);
	// -->
	</script>
		~;


	} elsif ($action eq "dates2") {
		&setup_fatal_error("Date & Time conversion (dates2) error! pollfile($INFO{'pollfile'}), polledfile($INFO{'polledfile'})", 1) if $INFO{'pollfile'} <= 0 && $INFO{'polledfile'} <= 0;

		my $pollwidth = ($INFO{'totalpolls'} && $INFO{'pollfile'}) ? int($INFO{'pollfile'} / $INFO{'totalpolls'} * 100) : 100;
		$INFO{'pollfile'} = $INFO{'pollfile'} ? $INFO{'pollfile'} : $INFO{'totalpolls'};
		my $polledwidth = ($INFO{'totalpolled'} && $INFO{'polledfile'}) ? int($INFO{'polledfile'} / $INFO{'totalpolled'} * 100) : 0;
		$INFO{'polledfile'} = $INFO{'polledfile'} ? $INFO{'polledfile'} : $INFO{'totalpolled'};

		$yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink4 . $NavLink5 . $NavLink6;

		$yymain = qq~
	<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr valign="middle">
			<td width="100%" colspan="2" class="titlebg" align="left">
			YaBB 2 Converter
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/thread.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left">
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Member Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Board and Category Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Message Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Date & Time Conversion.</div>
			<div style="float: left; width: 102px; height: 10px; margin: 1px; background-color: #dddddd; border: 1px black solid; font-size: 10px;text-align :center;">
			See info below!
			</div>
			<div style="float: left; width: 50px; height: 14px; text-align: right; color: #FF3333;">--- %</div><br />
			<div style="float: left; width: 250px; height: 14px; color: #bbbbbb;">Final Cleanup.</div>
			$ConvNotDone
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/info.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left" style="font-size: 11px;">
			To prevent server time-out due to the amount of Date & Time conversion, the conversion is split into more steps.<br />
			<br />
			The time-step (\$max_process_time) is set to <i>$max_process_time seconds</i>.<br />
			The last step took <i>~ . ($time_to_jump - $INFO{'starttime'}) . qq~ seconds</i>.<br />
			You are converting <i>~ . int(($INFO{'st'} + 60)/60) . qq~ minutes</i>.<br />
			<br />

			<div style="float: left; width: 350px; height: 14px;">There are <b>~ . ($INFO{'totalpolls'} - $INFO{'pollfile'}) . qq~/$INFO{'totalpolls'}</b> Polls left to be converted. &nbsp; </div>
			<div style="float: left; width: 100px; height: 10px; margin: 1px; background-color: #dddddd; border: 1px black solid; font-size: 5px;">
			<div style="position: relative; top: 0px; left: 0px; width: $pollwidth\px; height: 10px; margin: 0px; background-color: #6699cc; border: 0px; font-size: 5px;">&nbsp;</div>
			</div>
			<div style="float: left; width: 50px; height: 14px; text-align: right; color: #FF3333;">$pollwidth %</div>
			</div><br /><br />

			<div style="float: left; width: 350px; height: 14px;">There are <b>~ . ($INFO{'totalpolled'} - $INFO{'polledfile'}) . qq~/$INFO{'totalpolled'}</b> Polled-Files left to be converted. &nbsp; </div>
			<div style="float: left; width: 100px; height: 10px; margin: 1px; background-color: #dddddd; border: 1px black solid; font-size: 5px;">
			<div style="position: relative; top: 0px; left: 0px; width: $polledwidth\px; height: 10px; margin: 0px; background-color: #6699cc; border: 0px; font-size: 5px;">&nbsp;</div>
			</div>
			<div style="float: left; width: 50px; height: 14px; text-align: right; color: #FF3333;">$polledwidth %</div>
			</div><br /><br />

			<p id="memcontinued">If nothing happens in 5 seconds <a href="$set_cgi?action=dates;st=$INFO{'st'};timeconv=$INFO{'timeconv'};pollfile=$INFO{'pollfile'};totalpolls=$INFO{'totalpolls'};polledfile=$INFO{'polledfile'}" onclick="PleaseWait();">click here to continue</a>...<br />If you want to <a href="javascript:stoptick();">STOP 'Date & Time' conversion click here</a>. Then copy the actual browser adress and type it in when you are going to continue the conversion.</p>
			</td>
		</tr>
		</table>
	</div>

	<script type="text/javascript">
	<!--
		function PleaseWait() {
			document.getElementById("memcontinued").innerHTML = '<font color="red"><b>Converting - please wait!<br />If you want to stop \\'Date & Time\\' conversion, click here on STOP before this red message apears again on next page.</b></font>';
		}

		function stoptick() { stop = 1; }

		stop = 0;
		function membtick() {
			if (stop != 1) {
				PleaseWait();
				location.href="$set_cgi?action=dates;st=$INFO{'st'};timeconv=$INFO{'timeconv'};pollfile=$INFO{'pollfile'};totalpolls=$INFO{'totalpolls'};polledfile=$INFO{'polledfile'}";
			}
		}

		setTimeout("membtick()",2000);
	// -->
	</script>
		~;


	} elsif ($action eq "cleanup") {
		require "$boardsdir/forum.master";

		if (!$INFO{'clean'}) {
			fopen(FORUMTOTALS, ">>$boardsdir/forum.totals") || &setup_fatal_error("Can not open $boardsdir/forum.totals", 1);
			foreach my $testboard (@allboards) {
				chomp $testboard;
				if (-e "$boardsdir/$testboard.ttl") {
					fopen(BOARDTTL, "$boardsdir/$testboard.ttl") || &setup_fatal_error("Can not open $boardsdir/$testboard.ttl", 1);
					my $line = <BOARDTTL>;
					fclose(BOARDTTL);
					chomp $line;
					print FORUMTOTALS "$testboard|$line|\n";
					#&delete_DBorFILE("$boardsdir/$testboard.ttl");
				}
			}
			fclose(FORUMTOTALS);

			$yySetLocation = qq~$set_cgi?action=cleanup2;st=~ . int($INFO{'st'} + time() - $time_to_jump + $max_process_time) . qq~;starttime=$time_to_jump;clean=1;pass_error=1;total_boards=~ . @allboards;
			&redirectexit;
		}
		&MyReCountTotals if $INFO{'clean'} == 1;

		&MyMemberIndex if $INFO{'clean'} == 2;
		&MyMailNotify if $INFO{'clean'} == 3;
		&FixNopost if $INFO{'clean'} == 4;

		if ($INFO{'tmp_firstforum'} > $INFO{'firstforum'}) {
			$setforumstart  = &timeformat($INFO{'tmp_firstforum'});
			$firstmember    = &timeformat($INFO{'firstforum'});
			$forumstarttext = qq~The Forum Start date was set to $setforumstart but the first member was registered $firstmember. So we changed the Forum Start Date to $firstmember.~;
		}

		$yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink4 . $NavLink5 . $NavLink6a;

		$formsession = &cloak("$mbname$username");

		if (-e "Convert/Members/admin.dat") {
			$convtext .= qq~<br /><br />After you have tested your forum and made sure everything was converted correctly you can go to your Admin Center and delete /Convert/Boards, /Convert/Members, /Convert/Messages and /Convert/Variables folders and their contents.~;
		}

		if (-e "$vardir/fixusers.txt") {
			$convtext .= qq~<br /><br />There were some illegal usernames. Their names were changed. Please inform them. You can find the list in the $vardir/fixusers.txt~;
		}

		$yymain = qq~
	<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr valign="middle">
			<td width="100%" colspan="2" class="titlebg" align="left">
			YaBB 2 Converter
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/thread.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left">
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Member Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Board and Category Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Message Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Date & Time Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Final Cleanup.</div>
			$ConvDone
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/info.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left" style="font-size: 11px;">
			$forumstarttext
			$convtext<br />
			<br />
			The conversion took <i>~ . int(($INFO{'st'} + 60)/60) . qq~ minutes</i>.<br />
			<br />
			<br />
			<font color"red">We recommend you delete the file "$ENV{'SCRIPT_NAME'}". This is to prevent someone else running the converter and damaging your files.<br />
			<br />
			Further more, we strongly recomend to run the following "Maintenance Controls" in the "Admin Center" before you start doing other things:<br />
			- Rebuild Message Index<br />
			- Recount Board Totals<br />
			- Rebuild Members List<br />
			- Recount Membership<br />
			- Rebuild Members History<br />
			- Rebuild Notifications Files<br />
			- Clean Users Online Log<br />
			- Attachment Functions => Rebuild Attachments<br /></font>
			<br />
			<br />
			You may now login to your forum. Enjoy using YaBB 2!
			</td>
		</tr>
		<tr>
			<td width="100%" class="catbg" colspan="2" align="center">
			<form action="YaBB.$yyext" method="post" style="display: inline;">
				<input type="submit" value="Start" />
				<input type="hidden" name="formsession" value="$formsession" />
			</form>
			</td>
		</tr>
		</table>
	</div>~;

		&CreateConvLock;


	} elsif ($action eq "cleanup2") {
		&setup_fatal_error("Clean Up (cleanup2) error! pass_error($INFO{'pass_error'}), my_re_tot($INFO{'my_re_tot'}), memb_index($INFO{'memb_index'}), my_mail_n($INFO{'my_mail_n'})", 1) if (!$INFO{'pass_error'} && $INFO{'my_re_tot'} <= 0) && $INFO{'memb_index'} <= 0 && $INFO{'my_mail_n'} <= 0 && $INFO{'fix_nopost'} <= 1;

		my $re_tot_width = ($INFO{'total_re_tot'} && $INFO{'my_re_tot'}) ? int($INFO{'my_re_tot'} / $INFO{'total_re_tot'} * 100) : ($INFO{'total_re_tot'} ? 100 : 0);
		$INFO{'my_re_tot'} = $INFO{'my_re_tot'} ? $INFO{'my_re_tot'} : $INFO{'total_re_tot'};
		my $memb_index_width = ($INFO{'total_memb'} && $INFO{'memb_index'}) ? int($INFO{'memb_index'} / $INFO{'total_memb'} * 100) : ($INFO{'total_memb'} ? 100 : 0);
		$INFO{'memb_index'} = $INFO{'memb_index'} ? $INFO{'memb_index'} : $INFO{'total_memb'};
		my $mail_not_width = ($INFO{'total_mail_n'} && $INFO{'my_mail_n'}) ? int($INFO{'my_mail_n'} / $INFO{'total_mail_n'} * 100) : ($INFO{'total_mail_n'} ? 100 : 0);
		$INFO{'my_mail_n'} = $INFO{'my_mail_n'} ? $INFO{'my_mail_n'} : $INFO{'total_mail_n'};
		my $nopost_width = $INFO{'total_nopost'} ? int($INFO{'fix_nopost'} / $INFO{'total_nopost'} * 100) : 0;

		$yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink4 . $NavLink5 . $NavLink6;

		$yymain = qq~
	<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
		<table width="100%" cellspacing="1" cellpadding="4">
		<tr valign="middle">
			<td width="100%" colspan="2" class="titlebg" align="left">
			YaBB 2 Converter
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/thread.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left">
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Member Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Board and Category Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Message Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Date & Time Conversion.</div>
			$ConvDone
			<div style="float: left; width: 250px; height: 14px; color: #FF3333;">Final Cleanup.</div>
			<div style="float: left; width: 102px; height: 10px; margin: 1px; background-color: #dddddd; border: 1px black solid; font-size: 10px;text-align :center;">
			See info below!
			</div>
			<div style="float: left; width: 50px; height: 14px; text-align: right; color: #FF3333;">--- %</div>
			</td>
		</tr>
		<tr valign="middle">
			<td width="5%" class="windowbg" align="center">
			<img src="$imagesdir/info.gif" alt="" />
			</td>
			<td width="95%" class="windowbg2" align="left" style="font-size: 11px;">
			To prevent server time-out due to the amount to Clean Up, the Cleanup is split into more steps.<br />
			<br />
			The time-step (\$max_process_time) is set to <i>$max_process_time seconds</i>.<br />
			The last step took <i>~ . ($time_to_jump - $INFO{'starttime'}) . qq~ seconds</i>.<br />
			You are converting <i>~ . int(($INFO{'st'} + 60)/60) . qq~ minutes</i>.<br />
			<br />

			<div style="float: left; width: 350px; height: 14px;">There are <b>0/$INFO{'total_boards'}</b> Boards (1) left to be recounted. &nbsp; </div>
			<div style="float: left; width: 100px; height: 10px; margin: 1px; background-color: #dddddd; border: 1px black solid; font-size: 5px;">
			<div style="position: relative; top: 0px; left: 0px; width: $100px; height: 10px; margin: 0px; background-color: #6699cc; border: 0px; font-size: 5px;">&nbsp;</div>
			</div>
			<div style="float: left; width: 50px; height: 14px; text-align: right; color: #FF3333;">100 %</div>
			</div><br /><br />

			<div style="float: left; width: 350px; height: 14px;">There are <b>~ . ($INFO{'total_re_tot'} - $INFO{'my_re_tot'}) . qq~/$INFO{'total_re_tot'}</b> Boards (2) left to be recounted. &nbsp; </div>
			<div style="float: left; width: 100px; height: 10px; margin: 1px; background-color: #dddddd; border: 1px black solid; font-size: 5px;">
			<div style="position: relative; top: 0px; left: 0px; width: $re_tot_width\px; height: 10px; margin: 0px; background-color: #6699cc; border: 0px; font-size: 5px;">&nbsp;</div>
			</div>
			<div style="float: left; width: 50px; height: 14px; text-align: right; color: #FF3333;">$re_tot_width %</div>
			</div><br /><br />

			<div style="float: left; width: 350px; height: 14px;">There are <b>~ . ($INFO{'total_memb'} - $INFO{'memb_index'}) . qq~/$INFO{'total_memb'}</b> Members left to be recounted. &nbsp; </div>
			<div style="float: left; width: 100px; height: 10px; margin: 1px; background-color: #dddddd; border: 1px black solid; font-size: 5px;">
			<div style="position: relative; top: 0px; left: 0px; width: $memb_index_width\px; height: 10px; margin: 0px; background-color: #6699cc; border: 0px; font-size: 5px;">&nbsp;</div>
			</div>
			<div style="float: left; width: 50px; height: 14px; text-align: right; color: #FF3333;">$memb_index_width %</div>
			</div><br /><br />

			<div style="float: left; width: 350px; height: 14px;">There are <b>~ . ($INFO{'total_mail_n'} - $INFO{'my_mail_n'}) . qq~/$INFO{'total_mail_n'}</b> Notifications left to be written new. &nbsp; </div>
			<div style="float: left; width: 100px; height: 10px; margin: 1px; background-color: #dddddd; border: 1px black solid; font-size: 5px;">
			<div style="position: relative; top: 0px; left: 0px; width: $mail_not_width\px; height: 10px; margin: 0px; background-color: #6699cc; border: 0px; font-size: 5px;">&nbsp;</div>
			</div>
			<div style="float: left; width: 50px; height: 14px; text-align: right; color: #FF3333;">$mail_not_width %</div>
			</div><br /><br />

			<div style="float: left; width: 350px; height: 14px;">There are <b>~ . ($INFO{'total_nopost'} - $INFO{'fix_nopost'}) . qq~/$INFO{'total_nopost'}</b> NoPost-Membergroups left to be updated. &nbsp; </div>
			<div style="float: left; width: 100px; height: 10px; margin: 1px; background-color: #dddddd; border: 1px black solid; font-size: 5px;">
			<div style="position: relative; top: 0px; left: 0px; width: $nopost_width\px; height: 10px; margin: 0px; background-color: #6699cc; border: 0px; font-size: 5px;">&nbsp;</div>
			</div>
			<div style="float: left; width: 50px; height: 14px; text-align: right; color: #FF3333;">$nopost_width %</div>
			</div><br /><br />

			<p id="memcontinued">If nothing happens in 5 seconds <a href="$set_cgi?action=cleanup;st=$INFO{'st'};clean=$INFO{'clean'};total_boards=$INFO{'total_boards'};total_re_tot=$INFO{'total_re_tot'};my_re_tot=$INFO{'my_re_tot'};tmp_firstforum=$INFO{'tmp_firstforum'};firstforum=$INFO{'firstforum'};siglength=$INFO{'siglength'};total_memb=$INFO{'total_memb'};memb_index=$INFO{'memb_index'};total_mail_n=$INFO{'total_mail_n'};my_mail_n=$INFO{'my_mail_n'};total_nopost=$INFO{'total_nopost'};fix_nopost=$INFO{'fix_nopost'}" onclick="PleaseWait();">click here to continue</a>...<br />If you want to <a href="javascript:stoptick();">STOP 'Clean Up' conversion click here</a>. Then copy the actual browser adress and type it in when you are going to continue the conversion.</p>
			</td>
		</tr>
		</table>
	</div>

	<script type="text/javascript">
	<!--
		function PleaseWait() {
			document.getElementById("memcontinued").innerHTML = '<font color="red"><b>Converting - please wait!<br />If you want to stop \\'Clean Up\\', click here on STOP before this red message apears again on next page.</b></font>';
		}

		function stoptick() { stop = 1; }

		stop = 0;
		function membtick() {
			if (stop != 1) {
				PleaseWait();
				location.href="$set_cgi?action=cleanup;st=$INFO{'st'};clean=$INFO{'clean'};total_boards=$INFO{'total_boards'};total_re_tot=$INFO{'total_re_tot'};my_re_tot=$INFO{'my_re_tot'};tmp_firstforum=$INFO{'tmp_firstforum'};firstforum=$INFO{'firstforum'};siglength=$INFO{'siglength'};total_memb=$INFO{'total_memb'};memb_index=$INFO{'memb_index'};total_mail_n=$INFO{'total_mail_n'};my_mail_n=$INFO{'my_mail_n'};total_nopost=$INFO{'total_nopost'};fix_nopost=$INFO{'fix_nopost'}";
			}
		}

		setTimeout("membtick()",2000);
	// -->
	</script>
		~;
	}

	$yyim    = 'You are running the YaBB 2 Converter.';
	$yytitle = 'YaBB 2 Converter';
	&SetupTemplate;
}


# Prepare Conversion ##

sub PrepareConv {
	fopen(FILE, ">$boardsdir/dummy.testfile") || &setup_fatal_error("The CHMOD of the $boardsdir are not set correct! Can't write this directory!", 1);
	print FILE "dummy testfile\n";
	fclose(FILE);
	opendir(BDIR, $boardsdir) || &setup_fatal_error("The CHMOD of the $boardsdir are not set correct! Can't read this directory! ", 1);
	@boardlist = readdir(BDIR);
	closedir(BDIR);

	fopen(FILE, ">$memberdir/dummy.testfile") || &setup_fatal_error("The CHMOD of the $memberdir are not set correct! Can't write this directory!", 1);
	print FILE "dummy testfile\n";
	fclose(FILE);
	opendir(MBDIR, $memberdir) || &setup_fatal_error("The CHMOD of the $memberdir are not set correct! Can't read this directory! ", 1);
	@memblist = readdir(MBDIR);
	closedir(MBDIR);

	fopen(FILE, ">$datadir/dummy.testfile") || &setup_fatal_error("The CHMOD of the $datadir are not set correct! Can't write this directory!", 1);
	print FILE "dummy testfile\n";
	fclose(FILE);
	opendir(MSDIR, $datadir) || &setup_fatal_error("The CHMOD of the $datadir are not set correct! Can't read this directory! ", 1);
	@msglist = readdir(MSDIR);
	closedir(MSDIR);

	&automaintenance('on');

	&delete_DBorFILE("$vardir/fixusers.txt");

	foreach $file (@boardlist) {
		unless ($file eq ".htaccess" || $file eq "index.html" || $file eq "forum.control" || $file eq "." || $file eq "..") { &delete_DBorFILE("$boardsdir/$file"); }
	}
	foreach $file (@memblist) {
		unless ($file eq ".htaccess" || $file eq "index.html" || $file eq "admin.vars" || $file eq "." || $file eq "..") { &delete_DBorFILE("$memberdir/$file"); }
	}
	foreach $file (@msglist) {
		unless ($file eq ".htaccess" || $file eq "index.html" || $file eq "." || $file eq "..") { &delete_DBorFILE("$datadir/$file"); }
	}
}

# / Prepare Conversion ##


# Member Conversion ##

sub ConvertMembers1 {
	fopen(MEMDIR, "$convmemberdir/memberlist.txt") || &setup_fatal_error("$maintext_23 $convmemberdir/memberlist.txt: ", 1);
	my @memlist = <MEMDIR>;
	fclose(MEMDIR);

	for (my $i = ($INFO{'mstart1'} || 0); $i < @memlist; $i++) {
		$uname = $memlist[$i];
		chomp $uname;

		next if !-e "$convmemberdir/$uname.dat";

		if ($uname =~ /[^\w\+\-\.\@]|guest/i) {
			&IllegalUser($uname);
		} else {
			&MyUpdateUser($uname);
		}

		if (time() > $time_to_jump && ($i + 1) < @memlist) {
			$yySetLocation = qq~$set_cgi?action=members2;st=~ . int($INFO{'st'} + time() - $time_to_jump + $max_process_time) . qq~;starttime=$time_to_jump;mtotal=~ . @memlist . qq~;mstart1=~ . ($i + 1);
			&redirectexit;
		}
	}

	$INFO{'mstart1'} = @memlist;

	if (-e "$convvardir/MemberStats.txt") { &groupconvert; }

	if (-e "$vardir/fixusers.txt") {
		fopen(FIXUSER, "$vardir/fixusers.txt") || &setup_fatal_error("$maintext_23 $vardir/fixusers.txt: ", 1);
		my @fixed = <FIXUSER>;
		fclose(FIXUSER);
		foreach (@fixed) {
			my ($user, $fixedname, undef, $displayedname, undef) = split(/\|/, $_);
			@{$fixed_users{$user}} = ($fixedname,$displayedname);
		}
	}

	&ConvertMembers2;
}

sub IllegalUser {
	my $user = $_[0];

	my $fixeduser = $user;
	$fixeduser =~ s/[^\w\+\-\.\@]|guest//gi;
	if (!$fixeduser) { $fixeduser = "fixeduser"; }
	$fixeduser = &check_existence($memberdir, "$fixeduser.vars");
	$fixeduser =~ s/(\S+?)(\.\S+$)/$1/;

	fopen(LOADOLDUSER, "$convmemberdir/$user.dat") || &setup_fatal_error("$maintext_23 $convmemberdir/$user.dat: ", 1);
	my @settings = <LOADOLDUSER>;
	fclose(LOADOLDUSER);
	chomp(@settings);

	my ($pmignorelist, $pmnotify, $pmpopup, $pmspop);
	if (-e "$convmemberdir/$user.imconfig") {
		fopen(PMUSER, "$convmemberdir/$user.imconfig") || &setup_fatal_error("$maintext_23 $convmemberdir/$user.imconfig: ", 1);
		@pmconfics = <PMUSER>;
		fclose(PMUSER);
		chomp($pmconfics[0], $pmconfics[1], $pmconfics[3], $pmconfics[5]);
		$pmignorelist = $pmconfics[0];
		$pmnotify = $pmconfics[1] ? 3 : 0;
		$pmpopup = $pmconfics[3];
		$pmspop = $pmconfics[5];
	}

	my $msnaddress = "";
	if (-e "$convmemberdir/$user.om") {
		fopen(MSNFILE, "$convmemberdir/$user.om") || &setup_fatal_error("$maintext_23 $convmemberdir/$user.om: ", 1);
		my @msnsettings = <MSNFILE>;
		fclose(MSNFILE);
		chomp $msnsettings[0];
		$msnaddress = $msnsettings[0];
	}

	my ($lastonline, $lastpost, $lastim);
	if (-e "$convmemberdir/$user.ll") {
		fopen(LLFILE, "$convmemberdir/$user.ll") || &setup_fatal_error("$maintext_23 $convmemberdir/$user.ll: ", 1);
		($lastonline, $lastpost, $lastim) = <LLFILE>;
		fclose(LLFILE);
		chomp($lastonline, $lastpost, $lastim);
		$lastonline =~ s~(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})~&conv_stringtotime("$1 at $2")~eis;
		$lastpost =~ s~(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})~&conv_stringtotime("$1 at $2")~eis;
		$lastim =~ s~(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})~&conv_stringtotime("$1 at $2")~eis;
	}

	if (-e "$convmemberdir/$user.yam") {
		fopen(YAMFILE, "$convmemberdir/$user.yam") || &setup_fatal_error("$maintext_23 $convmemberdir/$user.yam: ", 1);
		my @ipsettings = <YAMFILE>;
		fclose(YAMFILE);
		chomp $ipsettings[1];
		($c_ip_one, $c_ip_two, $c_ip_three) = split (/\|/, $ipsettings[1]);
		if ($c_ip_one eq '0') { $c_ip_one = ''; }
		if ($c_ip_two eq '0') { $c_ip_two = ''; }
		if ($c_ip_three eq '0') { $c_ip_three = ''; }
	}

	$settings[14] = &format_timestring($settings[14]);

	$regitime = "$settings[14]";
	$regitime =~ s~(\d{2}\/\d{2}\/\d{2,4}).*?(\d{2}\:\d{2}\:\d{2})~&conv_stringtotime("$1 at $2")~eis;

	if ($default_template) { $new_template = $default_template; }
	else { $new_template = qq~Forum default~; }

	if ($settings[1] eq "") { $settings[1] = $user; }

	if ($settings[5]) {
		$settings[5] =~ s/&&/&amp;&amp;/g;
		$settings[5] =~ s/\"/&quot;/g;
		$settings[5] =~ s~\[size=([+-]?\d)\](.*?)\[/size\]~ "\[size=" . &conv_size($1) . "\]$2\[/size\]" ~ige;
		$settings[5] =~ s~<br>~<br />~ig;
	}

	my @location = split(/,|\|/, $settings[15]);
	shift(@location);

	%{$uid.$fixeduser} = (
		'password'      => "$settings[0]",
		'realname'      => "$settings[1]",
		'email'         => "$settings[2]",
		'webtitle'      => "$settings[3]",
		'weburl'        => (($settings[4] && $settings[4] !~ m~\Ahttps?://~) ? "http://" : "") . $settings[4],
		'signature'     => "$settings[5]",
		'postcount'     => "$settings[6]",
		'position'      => "$settings[7]",
		'icq'           => "$settings[8]",
		'aim'           => "$settings[9]",
		'yim'           => "$settings[10]",
		'gender'        => "$settings[11]",
		'usertext'      => "$settings[12]",
		'userpic'       => "$settings[13]",
		'regdate'       => "$settings[14]",
		'regtime'       => "$regitime",
		'location'      => join(', ', grep($_, @location)),
		'bday'          => "$settings[16]",
		'timeselect'    => "$settings[17]",
		'timeoffset'    => "$timeoffset",
		'hidemail'      => ($settings[19] ? 1 : 0),
		'msn'           => "$msnaddress",
		'gtalk'         => "$settings[32]",
		'template'      => "$new_template",
		'language'      => "$language",
		'lastonline'    => "$lastonline",
		'lastpost'      => "$lastpost",
		'lastim'        => "$lastim",
		'im_ignorelist' => "$pmignorelist",
		'notify_me'     => "$pmnotify",
		'im_popup'      => ($pmpopup ? 1 : 0),
		'im_imspop'     => ($pmspop ? 1 : 0),
		'cathide'       => "$settings[30]",
		'postlayout'    => ($settings[31] ? "$settings[31]|0" : ''),
		'dsttimeoffset' => "$dstoffset",
		'pageindex'     => "1|1|1|0",
		'lastips'       => "$c_ip_one|$c_ip_two|$c_ip_three",
	);

	&UserAccount($fixeduser,"update");

	fopen(FIXUSER, ">>$vardir/fixusers.txt") || &setup_fatal_error("$maintext_23 $vardir/fixusers.txt: ", 1);
	print FIXUSER "$user|$fixeduser|$settings[14]|$settings[1]|$settings[2]\n";
	fclose(FIXUSER);

	undef %{$uid.$fixeduser} if $fixeduser ne $username;
}

sub MyUpdateUser {
	my $user = $_[0];

	fopen(LOADOLDUSER, "$convmemberdir/$user.dat") || &setup_fatal_error("$maintext_23 $convmemberdir/$user.dat: ", 1);
	my @settings = <LOADOLDUSER>;
	fclose(LOADOLDUSER);
	chomp(@settings);

	my ($pmignorelist, $pmnotify, $pmpopup, $pmspop);
	if (-e "$convmemberdir/$user.imconfig") {
		fopen(PMUSER, "$convmemberdir/$user.imconfig") || &setup_fatal_error("$maintext_23 $convmemberdir/$user.imconfig: ", 1);
		@pmconfics = <PMUSER>;
		fclose(PMUSER);
		chomp($pmconfics[0], $pmconfics[1], $pmconfics[3], $pmconfics[5]);
		$pmignorelist = $pmconfics[0];
		$pmnotify = $pmconfics[1] ? 3 : 0;
		$pmpopup = $pmconfics[3];
		$pmspop = $pmconfics[5];
	}

	my $msnaddress = "";
	if (-e "$convmemberdir/$user.om") {
		fopen(MSNFILE, "$convmemberdir/$user.om") || &setup_fatal_error("$maintext_23 $convmemberdir/$user.om: ", 1);
		my @msnsettings = <MSNFILE>;
		fclose(MSNFILE);
		chomp $msnsettings[0];
		$msnaddress = $msnsettings[0];
	}

	my ($lastonline, $lastpost, $lastim);
	if (-e "$convmemberdir/$user.ll") {
		fopen(LLFILE, "$convmemberdir/$user.ll") || &setup_fatal_error("$maintext_23 $convmemberdir/$user.ll: ", 1);
		($lastonline, $lastpost, $lastim) = <LLFILE>;
		fclose(LLFILE);
		chomp($lastonline, $lastpost, $lastim);
		$lastonline =~ s~(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})~&conv_stringtotime("$1 at $2")~eis;
		$lastpost =~ s~(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})~&conv_stringtotime("$1 at $2")~eis;
		$lastim =~ s~(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})~&conv_stringtotime("$1 at $2")~eis;
	}

	if (-e "$convmemberdir/$user.yam") {
		fopen(YAMFILE, "$convmemberdir/$user.yam") || &setup_fatal_error("$maintext_23 $convmemberdir/$user.yam: ", 1);
		my @ipsettings = <YAMFILE>;
		fclose(YAMFILE);
		chomp $ipsettings[1];
		($c_ip_one, $c_ip_two, $c_ip_three) = split (/\|/, $ipsettings[1]);
		if ($c_ip_one eq '0') { $c_ip_one = ''; }
		if ($c_ip_two eq '0') { $c_ip_two = ''; }
		if ($c_ip_three eq '0') { $c_ip_three = ''; }
	}

	$settings[14] = &format_timestring($settings[14]);

	$regitime = "$settings[14]";
	$regitime =~ s~(\d{2}\/\d{2}\/\d{2,4}).*?(\d{2}\:\d{2}\:\d{2})~&conv_stringtotime("$1 at $2")~eis;

	if ($default_template) { $new_template = $default_template; }
	else { $new_template = qq~Forum default~; }

	if ($settings[1] eq "") { $settings[1] = $user; }

	if ($settings[5]) {
		$settings[5] =~ s/&&/&amp;&amp;/g;
		$settings[5] =~ s/\"/&quot;/g;
		$settings[5] =~ s~\[size=([+-]?\d)\](.*?)\[/size\]~ "\[size=" . &conv_size($1) . "\]$2\[/size\]" ~ige;
		$settings[5] =~ s~<br>~<br />~ig;
	}

	my @location = split(/,|\|/, $settings[15]);
	shift(@location);

	%{$uid.$user} = (
		'password'      => "$settings[0]",
		'realname'      => "$settings[1]",
		'email'         => "$settings[2]",
		'webtitle'      => "$settings[3]",
		'weburl'        => (($settings[4] && $settings[4] !~ m~\Ahttps?://~) ? "http://" : "") . $settings[4],
		'signature'     => "$settings[5]",
		'postcount'     => "$settings[6]",
		'position'      => "$settings[7]",
		'icq'           => "$settings[8]",
		'aim'           => "$settings[9]",
		'yim'           => "$settings[10]",
		'gender'        => "$settings[11]",
		'usertext'      => "$settings[12]",
		'userpic'       => "$settings[13]",
		'regdate'       => "$settings[14]",
		'regtime'       => "$regitime",
		'location'      => join(', ', grep($_, @location)),
		'bday'          => "$settings[16]",
		'timeselect'    => "$settings[17]",
		'timeoffset'    => "$timeoffset",
		'hidemail'      => ($settings[19] ? 1 : 0),
		'msn'           => "$msnaddress",
		'gtalk'         => "$settings[32]",
		'template'      => "$new_template",
		'language'      => "$language",
		'lastonline'    => "$lastonline",
		'lastpost'      => "$lastpost",
		'lastim'        => "$lastim",
		'im_ignorelist' => "$pmignorelist",
		'notify_me'     => "$pmnotify",
		'im_popup'      => ($pmpopup ? 1 : 0),
		'im_imspop'     => ($pmspop ? 1 : 0),
		'cathide'       => "$settings[30]",
		'postlayout'    => "$settings[31]|0",
		'dsttimeoffset' => "$dstoffset",
		'pageindex'     => "1|1|1|0",
		'lastips'       => "$c_ip_one|$c_ip_two|$c_ip_three",
	);

	&UserAccount($user,"update");

	undef %{$uid.$user} if $user ne $username;
}

sub groupconvert {
	require "$convvardir/MemberStats.txt";
	my $i = 0;
	my $z = 1;
	undef %Post;

	$Post{'-1'} = qq~$MemStatNewbie|$MemStarNumNewbie|$MemStarPicNewbie|$MemTypeColNewbie|0|0|0|0|0|0~;

	while ($MemStat[$i]) {
		if ($MemPostNum[$i] eq "x") {
			$NoPost{$z} = qq~$MemStat[$i]|$MemStarNum[$i]|$MemStarPic[$i]|$MemTypeCol[$i]|0|0|0|0|0|0~;
			$z++;
		} else {
			$Post{$MemPostNum[$i]} = qq~$MemStat[$i]|$MemStarNum[$i]|$MemStarPic[$i]|$MemTypeCol[$i]|0|0|0|0|0|0~;
		}
		$i++;
	}

	foreach my $key (keys %Group) {
		my $value = $Group{$key};
		$value =~ s~'~&#39;~g;
		$Group{'$key'} = $value;
	}
	foreach my $key (keys %NoPost) {
		my $value = $NoPost{$key};
		$value =~ s~'~&#39;~g;
		$NoPost{'$key'} = $value;
	}
	foreach my $key (keys %Post) {
		my $value = $Post{$key};
		$value =~ s~'~&#39;~g;
		$Post{'$key'} = $value;
	}
	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl'); # save %Group, %NoPost and %Post
}

sub ConvertMembers2 {
	fopen(MEMDIR, "$convmemberdir/memberlist.txt") || &setup_fatal_error("$maintext_23 $convmemberdir/memberlist.txt: ", 1);
	my @memlist = <MEMDIR>;
	fclose(MEMDIR);

	for (my $i = ($INFO{'mstart2'} || 0); $i < @memlist; $i++) {
		my $user = $memlist[$i];
		chomp $user;

		next if !-e "$convmemberdir/$user.dat";

		my $newuser = exists $fixed_users{$user} ? ${$fixed_users{$user}}[0] : $user;

		my @xtn = qw(msg ims imstore log outbox);
		for (my $cnt = 0; $cnt < @xtn; $cnt++) {
			if (-e "$convmemberdir/$user.$xtn[$cnt]") {
				fopen(FILEUSER, "$convmemberdir/$user.$xtn[$cnt]") || &setup_fatal_error("$maintext_23 $convmemberdir/$user.$xtn[$cnt]: ", 1);
				my @divfiles = <FILEUSER>;
				fclose(FILEUSER);

				if ($cnt == 0 || $cnt == 2 || $cnt == 4) { # msg || imstore || outbox
					chomp(@divfiles);
					for (my $i = 0; $i < @divfiles; $i++) {
						if ($cnt == 2) { # imstore
							my ($name, $subject, $date, $message, $id, $ip, $read_flag, $folder) = split(/\|/, $divfiles[$i]);
							$name = exists $fixed_users{$name} ? ${$fixed_users{$name}}[0] : $name;
							$date =~ s~(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})~&conv_stringtotime("$1 at $2")~ei;
							$message =~ s~<br>~<br />~ig;
							if ($folder eq 'outbox') {
								$folder = 'out';
								if (!$read_flag) { $read_flag = 'u'; }
								elsif ($read_flag == 1) { $read_flag = 'r'; }
								$divfiles[$i] = "$id|$newuser|$name|||$subject|$date|$message|$id|0|$ip|s|$read_flag|$folder|\n";
							} elsif ($folder eq 'inbox') {
								$folder = 'in';
								if ($read_flag == 1) { $read_flag = 'u'; }
								elsif ($read_flag == 2) { $read_flag = 'r'; }
								$divfiles[$i] = "$id|$name|$newuser|||$subject|$date|$message|$id|0|$ip|s|$read_flag|$folder|\n";
							}

						} else  { # msg || outbox
							my ($name, $subject, $date, $message, $id, $ip, $read_flag) = split(/\|/, $divfiles[$i]);
							$name = exists $fixed_users{$name} ? ${$fixed_users{$name}}[0] : $name;
							$date =~ s~(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})~&conv_stringtotime("$1 at $2")~ei;
							$message =~ s~<br>~<br />~ig;
							if ($id < 101 || $id eq '') { $id = $date; }
							if ($cnt == 0) { # msg
								if ($read_flag == '1') { $read_flag = 'u' ; } # u(nread)
								elsif ($read_flag == '2') { $read_flag = 'r'; } # r(eplied)
								$divfiles[$i] = "$id|$name|$newuser|||$subject|$date|$message|$id|0|$ip|s|$read_flag||\n";
							} else { # outbox
								if (!$read_flag) { $read_flag = 'u' ; } # u(rgent)
								elsif ($read_flag == 1) { $read_flag = 's'; } # s(tandard)
								$divfiles[$i] = "$id|$newuser|$name|||$subject|$date|$message|$id|0|$ip|s|$read_flag||\n";
							}
						}
					}
				}

				fopen(FILEUSER, ">$memberdir/$newuser.$xtn[$cnt]") || &setup_fatal_error("$maintext_23 $memberdir/$newuser.$xtn[$cnt]: ", 1);
				print FILEUSER @divfiles;
				fclose(FILEUSER);
			}
		}

		if (time() > $time_to_jump && ($i + 1) < @memlist) {
			$yySetLocation = qq~$set_cgi?action=members2;st=~ . int($INFO{'st'} + time() - $time_to_jump + $max_process_time) . qq~;starttime=$time_to_jump;mtotal=~ . @memlist . qq~;mstart1=$INFO{'mstart1'};mstart2=~ . ($i + 1);
			&redirectexit;
		}
	}
}

# / Member Conversion ##


# Board + Category Conversion ##

sub GetCats {
	fopen(VDIR, "$convvardir/cat.txt") || &setup_fatal_error("$maintext_23 $convvardir/cat.txt: ", 1);
	@categoryorder = <VDIR>;
	fclose(VDIR);
	chomp(@categoryorder);

	my @allboards;
	foreach $fcat (@categoryorder) {
		fopen(VCAT, "$convboardsdir/$fcat.cat") || &setup_fatal_error("$maintext_23 $convboardsdir/$fcat.cat: ", 1);
		@catdata = <VCAT>;
		fclose(VCAT);
		chomp(@catdata);

		$catinfo{$fcat} = qq~$catdata[0]|$catdata[1]|1~;

		my @catboards = ();
		for ($cnt = 2; $cnt < @catdata; $cnt++) {
			unless (!$catdata[$cnt]) { push(@catboards, $catdata[$cnt]); }
		}
		push(@allboards, @catboards);
		$cat{$fcat} = join(',', @catboards);
	}
	foreach $fboard (@allboards) {
		fopen(VBRD, "$convboardsdir/$fboard.dat") || &setup_fatal_error("$maintext_23 $convboardsdir/$fboard.dat: ", 1);
		@bdata = <VBRD>;
		fclose(VBRD);
		chomp $bdata[0];

		# get board access data
		if (-e "$convboardsdir/$fboard.mbo") {
			require "$convboardsdir/$fboard.mbo";
		}
		$board{$fboard} = qq~$bdata[0]|$view_groups{$fboard}|$showprivboards{$fboard}~;
	}

	# add trash if not exists
	unless (exists $cat{'staff'}) {
		push(@categoryorder, 'staff');
		$cat{'staff'} = "recycle";
		$catinfo{'staff'} = "Forum Staff|Administrator, Global Moderator|0";
	} else {
		my @temp;
		foreach (split(/,/, $cat{'staff'})) {
			push(@temp, $_) if $_ ne 'recycle';
		}
		push(@temp, 'recycle');
		$cat{'staff'} = join(',', @temp);
	}
	$board{'recycle'} = "Recycle Bin||" unless exists $board{'recycle'};

	@temparray = ();
	while (($key, $value) = each(%cat)) {
		# Strip membergroups with a ~ from them
		$value =~ s/~//g;
		push(@temparray, qq~\$cat{'$key'} = qq\~$value\~;\n~);
	}
	while (($key, $value) = each(%catinfo)) {
		# Strip membergroups with a ~ from them
		$value =~ s/~//g;
		$value =~ s/,/, /g;
		push(@temparray, qq~\$catinfo{'$key'} = qq\~$value\~;\n~);
	}
	while (($key, $value) = each(%board)) {
		# Strip membergroups with a ~ from them
		$value =~ s/~//g;
		$value =~ s/,/, /g;
		push(@temparray, qq~\$board{'$key'} = qq\~$value\~;\n~);
	}
	fopen(FILE, ">$boardsdir/forum.master") || &setup_fatal_error("$maintext_23 $boardsdir/forum.master: ", 1);
	print FILE qq~\$mloaded = 1;\n~, qq~\@categoryorder = qw(@categoryorder);\n~, @temparray, "\n1;";
	fclose(FILE);
}

sub CreateControl {
	require "$boardsdir/forum.master";

	foreach $foundboard (keys %board) {
		# get category
		fopen("CINFO", "$convboardsdir/$foundboard.ctb");
		@category = <CINFO>;
		fclose("CINFO");
		chomp $category[0];
		$cntcat = $category[0];

		# get boardinfo
		fopen("BINFO", "$convboardsdir/$foundboard.dat");
		@boardinfo = <BINFO>;
		fclose("BINFO");
		chomp(@boardinfo);

		$boardinfo[2]   =~ s/^\||\|$//g;
		$boardinfo[2]   =~ s/\|(\S?)/,$1/g;
		$cntmods        = join(',', grep { exists $fixed_users{$_} ? ${$fixed_users{$_}}[0] : $_; } split(/,/, $boardinfo[2]));
		$cntpic         = "";
		$cntdescription = $boardinfo[1];

		# get board access data
		if (-e "$convboardsdir/$foundboard.mbo") {
			require "$convboardsdir/$foundboard.mbo";
		}

		$cntstartperms = "$start_groups{$foundboard}";
		$cntreplyperms = "$reply_groups{$foundboard}";
		$cntpollperms  = "";
		$cntstartperms =~ s/,/, /g;
		$cntreplyperms =~ s/,/, /g;
		$cntpollperms  =~ s/,/, /g;
		$cntpic        = "$boardpic{$foundboard}";
		$cntzero       = "";
		$cntpassword   = "";
		$cnttotals     = "";
		$cntattperms   = "";
		$spare         = "";

		if ($cntcat && $foundboard) {
			push(@boardcontrol, "$cntcat|$foundboard|$cntpic|$cntdescription|$cntmods|$cntmodgroups|$cntstartperms|$cntreplyperms|$cntpollperms|$cntzero|$cntpassword|$cnttotals|$cntattperms|$spare|||\n");
		} elsif (!$cntcat && $foundboard eq 'recycle') { # add trash if not exists
			push(@boardcontrol, "staff|recycle||If the Recycle Bin is turned on, removed topics will be moved to this board. This will allow you to recover them if it is necessary.  You should purge messages in this board frequently to keep it clean.|admin|||||1|||1||||\n");
			if (!-e "$convboardsdir/recycle.txt") {
				fopen(BOARDFILE, ">$convboardsdir/recycle.txt") || &setup_fatal_error("$maintext_23 $convboardsdir/recycle.txt: ", 1);
				print BOARDFILE '';
				fclose(BOARDFILE);
			}
		}
	}

	fopen(CONTROL, ">$boardsdir/forum.control") || &setup_fatal_error("$maintext_23 $boardsdir/forum.control: ", 1);
	@boardcontrol = sort(@boardcontrol);
	print CONTROL @boardcontrol;
	fclose(CONTROL);
}

sub ConvertBoards {
	require "$boardsdir/forum.master";

	my %stickies;
	if (open(DATADIR, "$convboardsdir/sticky.stk")) {
		my @stickies = <DATADIR>;
		close(DATADIR);
		chomp(@stickies);
		foreach (@stickies) { $stickies{$_} = 1; }
	}

	@boards = sort(keys %board);

	for (my $i = ($INFO{'bstart'} || 0); $i < @boards; $i++) {
		fopen(BOARDFILE, "$convboardsdir/$boards[$i].txt") || &setup_fatal_error("$maintext_23 $convboardsdir/$boards[$i].txt: ", 1);
		@boardfile = <BOARDFILE>;
		fclose(BOARDFILE);

		@temparray = ();
		for (my $j = ($INFO{'bfstart'} || 0); $j < @boardfile; $j++) {
			my $line = $boardfile[$j];
			chomp $line;
			my ($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $line);

			next if (!-e "$convdatadir/$mnum.txt" || -s "$convdatadir/$mnum.txt" < 35);

			$mname = exists $fixed_users{$mname} ? ${$fixed_users{$mname}}[1] : $mname;
			$musername = exists $fixed_users{$musername} ? ${$fixed_users{$musername}}[0] : $musername;
			$mdate =~ s~(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})~&conv_stringtotime("$1 at $2")~eis;
			$mstate =~ s/1/l/;
			$mstate .= "s" if exists $stickies{$mnum};
			push(@temparray, "$mnum|$msub|$mname|$memail|$mdate|$mreplies|$musername|$micon|$mstate\n");

			if (time() > $time_to_jump && ($j + 1) < @boardfile) {
					fopen(BOARDFILE, ">>$boardsdir/$boards[$i].txt") || &setup_fatal_error("$maintext_23 $boardsdir/$boards[$i].txt: ", 1);
					print BOARDFILE @temparray;
					fclose(BOARDFILE);
					$yySetLocation = qq~$set_cgi?action=cats2;st=~ . int($INFO{'st'} + time() - ($time_to_jump - $max_process_time)) . qq~;starttime=$time_to_jump;bfstart=~ . ($j + 1) . qq~;bstart=$i;btotal=~ . @boards;
					&redirectexit;
			}
		}
		fopen(BOARDFILE, ">>$boardsdir/$boards[$i].txt") || &setup_fatal_error("$maintext_23 $boardsdir/$boards[$i].txt: ", 1);
		print BOARDFILE @temparray;
		fclose(BOARDFILE);

		if (time() > $time_to_jump && ($i + 1) < @boards) {
			$yySetLocation = qq~$set_cgi?action=cats2;st=~ . int($INFO{'st'} + time() - $time_to_jump + $max_process_time) . qq~;starttime=$time_to_jump;mtotal=~ . @memlist . qq~;bfstart=0;bstart=~ . ($i + 1);
			&redirectexit;
		}
		$INFO{'bfstart'} = 0;
	}
}

# / Board + Category Conversion ##


# Message Conversion ##

sub ConvertMessages {
	require "$boardsdir/forum.master";

	${$uid.$username}{'timeformat'} = 'SDT, DD MM YYYY HH:mm:ss zzz'; # the .ctb time format
	${$uid.$username}{'timeselect'} = 7;
	my $ctbtime = &timeformat($date,1,"rfc");

	my %stickies;
	if (open(DATADIR, "$convboardsdir/sticky.stk")) {
		my @stickies = <DATADIR>;
		close(DATADIR);
		chomp(@stickies);
		foreach (@stickies) { $stickies{$_} = 1; }
	}

	my @boards = sort(keys %board);

	my $totalbdr = @boards;
	for (my $next_board = ($INFO{'count'} || 0); $next_board < $totalbdr; $next_board++) {
		my $boardname = $boards[$next_board];

		fopen(BRDFILE, "$boardsdir/$boardname.txt") || &setup_fatal_error("$maintext_23 $boardsdir/$boardname.txt: ", 1);
		my @brdmessageline = <BRDFILE>;
		fclose(BRDFILE);

		my %newreply = ();
		my $totalmess = @brdmessageline;
		for (my $tops = ($INFO{'tcount'} || 0); $tops < $totalmess; $tops++) {
			($thread,undef,undef,undef,undef,$replies,undef) = split(/\|/, $brdmessageline[$tops], 7);

			fopen(MSGFILE, "$convdatadir/$thread.txt") || &setup_fatal_error("$maintext_23 $convdatadir/$thread.txt: ", 1);
			@messagelines = <MSGFILE>;
			fclose(MSGFILE);
			chomp(@messagelines);

			$INFO{'total_mess'} += @messagelines;
			$INFO{'total_threads'}++;

			@temparray = ();
			my ($subject, $name, $email, $mdate, $musername, $icon, $dummy, $user_ip, $message, $ns, $editdate, $editby, $attachment);
			foreach $msgline (@messagelines) {
				($subject, $name, $email, $mdate, $musername, $icon, $dummy, $user_ip, $message, $ns, $editdate, $editby, undef, $attachment) = split(/\|/, $msgline);
				$name = exists $fixed_users{$name} ? ${$fixed_users{$name}}[1] : $name;
				$musername = exists $fixed_users{$musername} ? ${$fixed_users{$musername}}[0] : $musername;
				$editby = exists $fixed_users{$editby} ? ${$fixed_users{$editby}}[0] : $editby;
				if ($message =~ /\[[qgs]/i) { # too many RegExpr take too much time!!!
					$message =~ s~\[quote(\s+author=(.*?)\s+link=(.*?)\s+date=(.*?)\s*)?\](.*?)\[/quote\]~&QuoteFix($2,$3,$4,$5)~eig;
					$message =~ s~\[(glow|shadow)=.*?\](.*?)\[/(glow|shadow)\]~\[glb\]$2\[/glb\]~ig;
					$message =~ s~\[size=([+-]?\d)\](.*?)\[/size\]~ "\[size=" . &conv_size($1) . "\]$2\[/size\]" ~ige;
				}
				$message  =~ s~<br>~<br />~ig;
				$mdate    =~ s~(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2}).*~&conv_stringtotime("$1 at $2")~ei;
				$editdate =~ s~(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2}).*~&conv_stringtotime("$1 at $2")~ei;
				push(@temparray, "$subject|$name|$email|$mdate|$musername|$icon|$dummy|$user_ip|$message|$ns|$editdate|$editby|$attachment\n");
				if ($musername ne "Guest") {
					${$uid.$thread}{$musername}++;
					${$uid.$thread.'time'}{$musername} = $mdate;
				}
			}
			fopen(MSGFILE, ">$datadir/$thread.txt") || &setup_fatal_error("$maintext_23 $datadir/$thread.txt: ", 1);
			print MSGFILE @temparray;
			fclose(MSGFILE);

			# do the .ctb
			my $views = 1;
			if (-e "$convdatadir/$thread.data") {
				fopen(DATA, "$convdatadir/$thread.data") || &setup_fatal_error("$maintext_23 $convdatadir/$thread.data: ", 1);
				$data = <DATA>;
				fclose(DATA);
				chomp $data;
				($views, undef) = split(/\|/, $data, 2);
			}

			my $trstate = exists $stickies{$thread} ? "s" : "";
			$lastposter = $musername eq "Guest" ? "Guest-$name" : $musername;

			fopen(CTB, ">$datadir/$thread.ctb") || &setup_fatal_error("$maintext_23 $datadir/$thread.ctb: ", 1);
			print CTB qq~### ThreadID: $thread, LastModified: $ctbtime ###\n\n'board',"$boardname"\n'replies',"$#messagelines"\n'views',"$views"\n'lastposter',"$lastposter"\n'lastpostdate',"$mdate"\n'threadstatus',"$trstate"\n'repliers',""\n~;
			fclose(CTB);

			if ($replies != $#messagelines) {
				$newreply{$tops} = $#messagelines;
			}

			if (time() > $time_to_jump && ($tops + 1) < $totalmess) {
					&writerecentlog(($INFO{'tcount'} || 0),$totalmess,\@brdmessageline);

					if (%newreply) { # fix reply display
						foreach (keys %newreply) {
							my @temp = split(/\|/, $brdmessageline[$_]);
							$temp[5] = $newreply{$_};
							$brdmessageline[$_] = join('|', @temp);
						}

						fopen(BOARDFILE, ">$boardsdir/$boardname.txt") || &setup_fatal_error("$maintext_23 $boardsdir/$boardname.txt: ", 1);
						print BOARDFILE @brdmessageline;
						fclose(BOARDFILE);
					}

					$yySetLocation = qq~$set_cgi?action=messages2;st=~ . int($INFO{'st'} + time() - ($time_to_jump - $max_process_time)) . qq~;starttime=$time_to_jump;count=$next_board;tcount=~ . ($tops + 1) . qq~;total_mess=$INFO{'total_mess'};total_threads=$INFO{'total_threads'};totboard=$totalbdr;totmess=$totalmess~;
					&redirectexit;
			}
		}

		&writerecentlog(($INFO{'tcount'} || 0),$totalmess,\@brdmessageline);

		if (%newreply) { # fix reply display
			foreach (keys %newreply) {
				my @temp = split(/\|/, $brdmessageline[$_]);
				$temp[5] = $newreply{$_};
				$brdmessageline[$_] = join('|', @temp);
			}

			fopen(BOARDFILE, ">$boardsdir/$boardname.txt") || &setup_fatal_error("$maintext_23 $boardsdir/$boardname.txt: ", 1);
			print BOARDFILE @brdmessageline;
			fclose(BOARDFILE);
		}

		if (time() > $time_to_jump && ($next_board + 1) < $totalbdr) {
			$yySetLocation = qq~$set_cgi?action=messages2;st=~ . int($INFO{'st'} + time() - ($time_to_jump - $max_process_time)) . qq~;starttime=$time_to_jump;count=~ . ($next_board + 1) . qq~;tcount=0;total_mess=$INFO{'total_mess'};total_threads=$INFO{'total_threads'};totboard=$totalbdr;totmess=0~;
			&redirectexit;
		}
		$INFO{'tcount'} = 0;
	}
}

sub QuoteFix {
	my ($qauthor, $qlink, $qdate, $qmessage) = @_;
	if ($qauthor eq "" || $qlink eq "" || $qdate eq "") {
		"\[quote\]$qmessage\[/quote\]";
	} else {
		$qdate = &conv_stringtotime($qdate);
		(undef, $threadlink, $start) = split(/;/, $qlink);
		(undef, $num)   = split(/=/, $threadlink);
		(undef, $start) = split(/=/, $start);
		"\[quote author=$qauthor link=$num/$start date=$qdate\]$qmessage\[/quote\]";
	}
}

sub conv_size {
	my $size = shift;
	if    ($size eq '1' || $size eq '-2') { $size = 10; }
	elsif ($size eq '2' || $size eq '-1') { $size = 13; }
	elsif ($size eq '3')                  { $size = 16; }
	elsif ($size eq '4' || $size eq '+1') { $size = 18; }
	elsif ($size eq '5' || $size eq '+2') { $size = 24; }
	elsif ($size eq '6' || $size eq '+3') { $size = 32; }
	elsif ($size eq '7' || $size eq '+4') { $size = 48; }
	$size;
}

sub writerecentlog {
	my ($start,$total,$messageref) = @_;

	for (my $t = $start; $t < $total; $t++) {
		($thread, undef) = split(/\|/, ${$messageref}[$t], 2);
		foreach my $user (keys %{$uid.$thread}) {
			fopen(RLOG, ">>$memberdir/$user.rlog") || &setup_fatal_error("$maintext_23 $memberdir/$user.rlog: ", 1);
			print RLOG "$thread\t${$uid.$thread}{$user},${$uid.$thread.'time'}{$user}\n";
			fclose(RLOG);
		}
		undef %{$uid.$thread};
		undef %{$uid.$thread.'time'};
	}
}

# / Message Conversion ##


# Date Conversion ##

sub ConvertTimeToString {
	if ($INFO{'timeconv'} < 1) {
		opendir(DATADIR, $convdatadir) || &setup_fatal_error("Directory: $convdatadir: ", 1);
		my @polls = sort( grep { /\.poll$/ } readdir(DATADIR) );
		closedir(DATADIR);

		my $totalpolls = @polls;
		for (my $i = ($INFO{'pollfile'} || 0); $i < $totalpolls; $i++) {
			$file = $polls[$i];
			fopen("POLLFILE", "$convdatadir/$file") || &setup_fatal_error("$maintext_23 $convdatadir/$file: ", 1);
			@pollsfile = <POLLFILE>;
			fclose("POLLFILE");

			chomp($pollsfile[0]);
			my ($dummy1, $dummy2, $polluname, $dummy4, $dummy5, $pdate, $dummy6, $dummy7, $dummy8, $epdate, $dummy10, $dummy11) = split(/\|/, shift(@pollsfile));
			$polluname = exists $fixed_users{$polluname} ? ${$fixed_users{$polluname}}[0] : $polluname;
			$pdate  =~ s~(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})~&conv_stringtotime("$1 at $2")~ei;
			$epdate =~ s~(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2}).*~&conv_stringtotime("$1 at $2")~ei;

			fopen("POLLFILE", ">$datadir/$file") || &setup_fatal_error("$maintext_23 $datadir/$file: ", 1);
			print POLLFILE "$dummy1|$dummy2|$polluname|$dummy4|$dummy5|$pdate|$dummy6|$dummy7|$dummy8|$epdate|$dummy10|$dummy11\n", @pollsfile;
			fclose("POLLFILE");

			if (time() > $time_to_jump && ($i + 1) < $totalpolls) {
				$yySetLocation = qq~$set_cgi?action=dates2;st=~ . int($INFO{'st'} + time() - $time_to_jump + $max_process_time) . qq~;starttime=$time_to_jump;timeconv=0;totalpolls=$totalpolls;pollfile=~ . ($i + 1);
				&redirectexit;
			}
		}
		$INFO{'totalpolls'} = $totalpolls;
	}

	if ($INFO{'timeconv'} < 2) {
		opendir(DATADIR, $convdatadir) || &setup_fatal_error("Directory: $convdatadir: ", 1);
		my @polled = sort( grep { /\.polled$/ } readdir(DATADIR) );
		closedir(DATADIR);

		my $totalpolled = @polled;
		for (my $i = ($INFO{'polledfile'} || 0); $i < $totalpolled; $i++) {
			$file = $polled[$i];
			fopen("POLLEDFILE", "$convdatadir/$file") || &setup_fatal_error("$maintext_23 $convdatadir/$file: ", 1);
			@polledfile = <POLLEDFILE>;
			fclose("POLLEDFILE");
			chomp(@polledfile);

			@temparray = ();
			foreach $line (@polledfile) {
				my ($dummy1, $pollername, $dummy3, $pdate) = split(/\|/, $line);
				$pollername = exists $fixed_users{$pollername} ? ${$fixed_users{$pollername}}[0] : $pollername;
				$pdate =~ s~(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})~&conv_stringtotime("$1 at $2")~ei;
				push(@temparray, "$dummy1|$pollername|$dummy3|$pdate\n");
			}
			fopen("POLLEDFILE", ">$datadir/$file") || &setup_fatal_error("$maintext_23 $datadir/$file: ", 1);
			print POLLEDFILE @temparray;
			fclose("POLLEDFILE");

			if (time() > $time_to_jump && ($i + 1) < $totalpolled) {
				$yySetLocation = qq~$set_cgi?action=dates2;st=~ . int($INFO{'st'} + time() - $time_to_jump + $max_process_time) . qq~;starttime=$time_to_jump;timeconv=1;totalpolls=$INFO{'totalpolls'};totalpolled=$totalpolled;polledfile=~ . ($i + 1);
				&redirectexit;
			}
		}
	}
}

# / Date Conversion ##


# Cleanup ##

sub MyReCountTotals {
	@boards = sort( keys %board );

	my $totalboards = @boards;
	for (my $j = ($INFO{'my_re_tot'} || 0); $j < $totalboards; $j++) {
		my $cntboard = $boards[$j];
		next unless $cntboard;

		fopen(BOARD, "$boardsdir/$cntboard.txt") || &setup_fatal_error("$maintext_23 $boardsdir/$cntboard.txt: ", 1);
		my @threads = <BOARD>;
		fclose(BOARD);

		my $threadcount  = @threads;
		my $messagecount = $threadcount;
		if ($threadcount) {
			for (my $i = 0; $i < @threads; $i++) {
				$messagecount += (split(/\|/, $threads[$i]))[5];
			}
		}
		&BoardTotals("load", $cntboard);
		${ $uid . $cntboard }{'threadcount'}  = $threadcount;
		${ $uid . $cntboard }{'messagecount'} = $messagecount;
		# &BoardTotals("update", ...) is done in &BoardSetLastInfo
		&BoardSetLastInfo($cntboard,\@threads);

		if (time() > $time_to_jump && ($j + 1) < $totalboards) {
			$yySetLocation = qq~$set_cgi?action=cleanup2;st=~ . int($INFO{'st'} + time() - $time_to_jump + $max_process_time) . qq~;starttime=$time_to_jump;clean=1;total_boards=$INFO{'total_boards'};total_re_tot=$totalboards;my_re_tot=~ . ($j + 1);
			&redirectexit;
		}
	}
	$INFO{'total_re_tot'} = $totalboards;
	$INFO{'clean'} = 2;
}

sub MyMemberIndex {
	if ($INFO{'memb_index'} > 0) {
		&ManageMemberinfo("load");
		$siglength = $INFO{'siglength'};
	} else {
		$INFO{'tmp_firstforum'} = $INFO{'firstforum'} = &conv_stringtotime($forumstart);
		$siglength = 200;
	}

	opendir(MEMBERS, $memberdir) || &setup_fatal_error("Directory: $memberdir: ", 1);
	@members = sort( grep { /.\.vars$/ } readdir(MEMBERS) );
	closedir(MEMBERS);

	$totalmemb = @members;
	for (my $j = ($INFO{'memb_index'} || 0); $j < $totalmemb; $j++) {
		$member = $members[$j];
		$member =~ s/\.vars$//g;

		&LoadUser($member);

		&Recent_Load($member);
		${$uid.$member}{'postcount'} = 0;
		foreach (keys %recent) {
			${$uid.$member}{'postcount'} += ${$recent{$_}}[0];
		}

		if ($INFO{'firstforum'} > ${$uid.$member}{'regtime'}) { $INFO{'firstforum'} = ${$uid.$member}{'regtime'}; }

		if (length(${$uid.$member}{'signature'}) > $siglength) { $siglength = length(${$uid.$member}{'signature'}); }

		if (${$uid.$member}{'position'}) {
			foreach my $key (keys %NoPost) {
				($NoPostname, undef) = split(/\|/, $NoPost{$key}, 2);
				if (${$uid.$member}{'position'} eq $NoPostname) { ${$uid.$member}{'position'} = $key; last; }
			}
		}
		if (!${$uid.$member}{'position'}) { ${$uid.$member}{'position'} = &MyMemberPostGroup(${$uid.$member}{'postcount'}); }

		if (${$uid.$member}{'addgroups'}) {
			my $newaddigrp = "";
			foreach $addigrp (split(/, ?/, ${$uid.$member}{'addgroups'})) {
				foreach my $key (keys %NoPost) {
					($NoPostname, undef) = split(/\|/, $NoPost{$key}, 2);
					if ($addigrp eq $NoPostname) { $addigrp = $key; last; }
				}
				$newaddigrp .= qq~$addigrp,~;
			}
			$newaddigrp =~ s/,$//;
			${$uid.$member}{'addgroups'} = $newaddigrp;
		}

		&UserAccount($member, "update");

		$memberinf{$member} = sprintf("%010d", ${$uid.$member}{'regtime'}) . qq~|${$uid.$member}{'realname'}|${$uid.$member}{'email'}|${$uid.$member}{'position'}|${$uid.$member}{'postcount'}|${$uid.$member}{'bday'}~;

		if (time() > $time_to_jump && ($j + 1) < $totalmemb) {
			&ManageMemberinfo("save");
			$yySetLocation = qq~$set_cgi?action=cleanup2;st=~ . int($INFO{'st'} + time() - $time_to_jump + $max_process_time) . qq~;starttime=$time_to_jump;clean=2;total_boards=$INFO{'total_boards'};total_re_tot=$INFO{'total_re_tot'};tmp_firstforum=$INFO{'tmp_firstforum'};firstforum=$INFO{'firstforum'};siglength=$siglength;total_memb=$totalmemb;memb_index=~ . ($j + 1);
			&redirectexit;
		}
	}
	&ManageMemberinfo("save");

	$INFO{'total_memb'} = $totalmemb;
	$INFO{'clean'} = 3;

	fopen(MEMBERINFOREAD, "$memberdir/memberinfo.txt") || &setup_fatal_error("$maintext_23 $memberdir/memberinfo.txt: ", 1);
	my @num = <MEMBERINFOREAD>;
	fclose(MEMBERINFOREAD);

	$members_total = @num;
	($last_member, undef) = split(/\t/, $num[$#num], 2);

	&SetInstall2;
}

sub MyMemberPostGroup {
	$userpostcnt = $_[0];
	$grtitle     = "";
	foreach $postamount (sort { $b <=> $a } keys %Post) {
		if ($userpostcnt >= $postamount) {
			($grtitle, undef) = split(/\|/, $Post{$postamount}, 2);
			last;
		}
	}
	return $grtitle;
}

sub MyMailNotify {
	require "$sourcedir/Notify.pl";
	&ManageMemberinfo("load");

	opendir(DIRECTORY, $convdatadir) || &setup_fatal_error("Directory: $convdatadir: ", 1);
	my @files = sort( grep { /\.mail$/ } readdir(DIRECTORY) );
	closedir(DIRECTORY);

	my $totalfiles = @files;
	my ($j,$filename,@mailaddresses,$mailaddress);
	for ($j = ($INFO{'my_mail_n'} || 0); $j < $totalfiles; $j++) {
		$filename = (split(/\./, $files[$j], 2))[0];

		fopen(MAILFILE, "$convdatadir/$filename.mail") || &setup_fatal_error("$maintext_23 $convdatadir/$filename.mail: ", 1);
		@mailaddresses = <MAILFILE>;
		fclose(MAILFILE);
		chomp(@mailaddresses);

		foreach $mailaddress (@mailaddresses) {
			foreach (keys %memberinf) {
				if ($mailaddress eq (split(/\|/, $memberinf{$_}, 4))[2]) {
					&ManageThreadNotify("add", $filename, $_, $language, 1, 1);
					undef %{$uid.$_} if $_ ne $username;
					last;
				}
			}
		}

		if (time() > $time_to_jump && ($j + 1) < $totalfiles) {
			$yySetLocation = qq~$set_cgi?action=cleanup2;st=~ . int($INFO{'st'} + time() - $time_to_jump + $max_process_time) . qq~;starttime=$time_to_jump;clean=3;total_boards=$INFO{'total_boards'};total_re_tot=$INFO{'total_re_tot'};total_memb=$INFO{'total_memb'};tmp_firstforum=$INFO{'tmp_firstforum'};firstforum=$INFO{'firstforum'};total_mail_n=$totalfiles;my_mail_n=~ . ($j + 1);
			&redirectexit;
		}
	}
	undef %memberinf;

	$INFO{'total_mail_n'} = $totalfiles;
	$INFO{'clean'} = 4;
}

sub FixNopost {
	if ($NoPost{'1'}) {
		fopen(FORUMCONTROL, "$boardsdir/forum.control") || &setup_fatal_error("$maintext_23 $boardsdir/forum.control: ", 1);
		@boardcontrols = <FORUMCONTROL>;
		fclose(FORUMCONTROL);
		chomp(@boardcontrols);

		my $totalnoposts = keys %NoPost;
		for (my $i = ($INFO{'fix_nopost'} || 1); $i <= $totalnoposts; $i++) {
			($grptitle, undef) = split(/\|/, $NoPost{$i}, 2);

			foreach my $key (keys %catinfo) {
				($catname, $catperms, $catcol) = split(/\|/, $catinfo{$key}, 3);
				$newperm = "";
				foreach $theperm (split(/, /, $catperms)) {
					if ($theperm eq $grptitle) { $theperm = $i; }
					$newperm .= qq~$theperm, ~;
				}
				$newperm =~ s/, $//;
				$catinfo{$key} = qq~$catname|$newperm|$catcol~;
			}
			foreach my $key (keys %board) {
				($boardname, $boardperms, $boardshow) = split(/\|/, $board{$key}, 3);
				$newperm = "";
				foreach $theperm (split(/, /, $boardperms)) {
					if ($theperm eq $grptitle) { $theperm = $i; }
					$newperm .= qq~$theperm, ~;
				}
				$newperm =~ s/, $//;
				$board{$key} = qq~$boardname|$newperm|$boardshow~;
			}
			for ($j = 0; $j < @boardcontrols; $j++) {
				($cntcat, $cntboard, $cntpic, $cntdescription, $cntmods, $cntmodgroups, $cnttopicperms, $cntreplyperms, $cntpollperms, $cntzero, $cntmembergroups, $cntann, $cntrbin, $cntattperms, $cntminageperms, $cntmaxageperms, $cntgenderperms) = split(/\|/, $boardcontrols[$j]);

				$newmodgroups = "";
				foreach my $theperm (split(/, /, $cntmodgroups)) {
					if ($theperm eq $grptitle) { $theperm = $i; }
					$newmodgroups .= qq~$theperm, ~;
				}
				$newmodgroups =~ s/, $//;

				$newtopicperms = "";
				foreach my $theperm (split(/, /, $cnttopicperms)) {
					if ($theperm eq $grptitle) { $theperm = $i; }
					$newtopicperms .= qq~$theperm, ~;
				}
				$newtopicperms =~ s/, $//;

				$newreplyperms = "";
				foreach my $theperm (split(/, /, $cntreplyperms)) {
					if ($theperm eq $grptitle) { $theperm = $i; }
					$newreplyperms .= qq~$theperm, ~;
				}
				$newreplyperms =~ s/, $//;

				$newpollperms = "";
				foreach my $theperm (split(/, /, $cntpollperms)) {
					if ($theperm eq $grptitle) { $theperm = $i; }
					$newpollperms .= qq~$theperm, ~;
				}
				$newpollperms =~ s/, $//;

				$boardcontrols[$j] = qq~$cntcat|$cntboard|$cntpic|$cntdescription|$cntmods|$newmodgroups|$newtopicperms|$newreplyperms|$newpollperms|$cntzero|$cntmembergroups|$cntann|$cntrbin|$cntattperms|$cntminageperms|$cntmaxageperms|$cntgenderperms\n~;
			}

			if (time() > $time_to_jump && ($i + 1) < $totalnoposts) {
				&Write_ForumMaster;

				fopen(FORUMCONTROL, ">$boardsdir/forum.control") || &setup_fatal_error("$maintext_23 $boardsdir/forum.control: ", 1);
				print FORUMCONTROL @boardcontrols;
				fclose(FORUMCONTROL);

				$yySetLocation = qq~$set_cgi?action=cleanup2;st=~ . int($INFO{'st'} + time() - $time_to_jump + $max_process_time) . qq~;starttime=$time_to_jump;clean=4;total_boards=$INFO{'total_boards'};total_re_tot=$INFO{'total_re_tot'};total_memb=$INFO{'total_memb'};tmp_firstforum=$INFO{'tmp_firstforum'};firstforum=$INFO{'firstforum'};total_mail_n=$INFO{'total_mail_n'};total_nopost=$totalnoposts;fix_nopost=~ . ($i + 1);
				&redirectexit;
			}
		}
		&Write_ForumMaster;

		fopen(FORUMCONTROL, ">$boardsdir/forum.control") || &setup_fatal_error("$maintext_23 $boardsdir/forum.control: ", 1);
		print FORUMCONTROL @boardcontrols;
		fclose(FORUMCONTROL);
	}
}

# / Cleanup ##


sub format_timestring {
	$time_string = $_[0];

	if($time_string !~ m~(\d{1,2})\/(\d{1,2})\/(\d{2,4}).*?(\d{1,2})\:(\d{1,2})\:(\d{1,2})~is) {
		$time_string = "$forumstart";
	}

	$time_string =~ m~(\d{1,2})\/(\d{1,2})\/(\d{2,4}).*?(\d{1,2})\:(\d{1,2})\:(\d{1,2})~is;

	$dr_month = $1;
	$dr_day = $2;
	$dr_year = $3;
	$dr_hour = $4;
	$dr_minute = $5;
	$dr_secund = $6;

	if($dr_month > 12) { $dr_month = 12; }
	if($dr_month < 1) { $dr_month = 1; }
	if($dr_day > 31) { $dr_day = 31; }
	if($dr_day < 1) { $dr_day = 1; }
	if(length($dr_year) > 2) { $dr_year = substr($dr_year , length($dr_year) - 2, 2); }
	if($dr_year < 90 && $dr_year > 20) { $dr_year = 90; }
	if($dr_year > 20 && $dr_year < 90) { $dr_year = 20; }
	if($dr_hour > 23) { $dr_hour = 23; }
	if($dr_minute > 59) { $dr_minute = 59; }
	if($dr_secund > 59) { $dr_secund = 59; }

	if($dr_month == 4 || $dr_month == 6 || $dr_month == 9 || $dr_month == 11) {
		$max_days = 30;
	}
	elsif($dr_month == 2 && $dr_year % 4 == 0) {
		$max_days = 29;
	}
	elsif($dr_month == 2 && $dr_year % 4 != 0) {
		$max_days = 28;
	}
	else {
		$max_days = 31;
	}
	if($dr_day > $max_days) { $dr_day = $max_days; }

	$dr_month = sprintf("%02d", $dr_month);
	$dr_day = sprintf("%02d", $dr_day);
	$dr_year = sprintf("%02d", $dr_year);
	$dr_hour = sprintf("%02d", $dr_hour);
	$dr_minute = sprintf("%02d", $dr_minute);
	$dr_secund = sprintf("%02d", $dr_secund);
	qq~$dr_month/$dr_day/$dr_year $maintxt{'107'} $dr_hour:$dr_minute:$dr_secund~;
}

sub conv_stringtotime {
	unless ($_[0]) { return 0; }
	$splitvar = $_[0];
	$splitvar =~ m~(\d{1,2})\/(\d{1,2})\/(\d{2,4}).*?(\d{1,2})\:(\d{1,2})\:(\d{1,2})~;
	$amonth = int($1) || 1;
	$aday   = int($2) || 1;
	$ayear  = int($3) || 0;
	$ahour  = int($4) || 0;
	$amin   = int($5) || 0;
	$asec   = int($6) || 0;

	if    ($ayear >= 36 && $ayear <= 99) { $ayear += 1900; }
	elsif ($ayear >= 00 && $ayear <= 35) { $ayear += 2000; }
	if    ($ayear < 1904) { $ayear = 1904; }
	elsif ($ayear > 2036) { $ayear = 2036; }

	if    ($amonth < 1)  { $amonth = 0; }
	elsif ($amonth > 12) { $amonth = 11; }
	else { --$amonth; }

	if($amonth == 3 || $amonth == 5 || $amonth == 8 || $amonth == 10) { $max_days = 30; }
	elsif($amonth == 1 && $ayear % 4 == 0) { $max_days = 29; }
	elsif($amonth == 1 && $ayear % 4 != 0) { $max_days = 28; }
	else { $max_days = 31; }
	if($aday > $max_days) { $aday = $max_days; }

	if    ($ahour < 1)  { $ahour = 0; }
	elsif ($ahour > 23) { $ahour = 23; }
	if    ($amin < 1)   { $amin  = 0; }
	elsif ($amin > 59)  { $amin  = 59; }
	if    ($asec < 1)   { $asec  = 0; }
	elsif ($asec > 59)  { $asec  = 59; }

	timelocal($asec, $amin, $ahour, $aday, $amonth, $ayear);
}


#############################################
# Setup starts here                         #
#############################################

if (!$action) {
	$rand_integer   = int(rand(99999));
	$rand_cook_user = "Y2User-$rand_integer";
	$rand_cook_pass = "Y2Pass-$rand_integer";
	$rand_cook_sess = "Y2Sess-$rand_integer";

	fopen(COOKFILE, ">$vardir/cook.txt") || &setup_fatal_error("$maintext_23 $vardir/cook.txt: ", 1);
	print COOKFILE "$rand_cook_user\n";
	print COOKFILE "$rand_cook_pass\n";
	print COOKFILE "$rand_cook_sess\n";
	fclose(COOKFILE);

	&adminlogin;
}

fopen(COOKFILE, "$vardir/cook.txt") || &setup_fatal_error("$maintext_23 $vardir/cook.txt: ", 1);
@cookinfo = <COOKFILE>;
fclose(COOKFILE);
chomp @cookinfo;

$cookieusername = "$cookinfo[0]";
$cookiepassword = "$cookinfo[1]";
$cookiesession_name = "$cookinfo[2]";

if    ($action eq "adminlogin2") { &adminlogin2; }
elsif ($action eq "setup1")      { &autoconfig; }
elsif ($action eq "setup2")      {
	&BrdInstall;
	&MemInstall;
	&MesInstall;
	&VarInstall;
	&save_paths;
}
elsif ($action eq "checkmodules") { &SetInstall2; &checkmodules; }
elsif ($action eq "setinstall")   { &SetInstall; }
elsif ($action eq "setinstall2")  { &SetInstall2; }
elsif ($action eq "setup3")       { &CheckInstall; }
elsif ($action eq "ready")        { &ready; }

$yymain = "End of script reached without action: $action";
&SimpleOutput;


#############################################
# setup subroutines start here              #
#############################################

sub adminlogin {
	$yymain .= qq~
	<br /><br /><br /><form action="$set_cgi?action=adminlogin2" method="post" name="loginform"><center>
	<table width="20%" border="0" bgcolor= "#000000" cellspacing="1" cellpadding="0">
	<tr><td>
	<table width="100%" border="0" bgcolor= "$windowbg" cellspacing="1" cellpadding="3">
	<tr>
		<td width="100%" align="center">
		<label for="password"><span style="font-family: Arial; font-size: 13px; color: #000000;">
		Enter the password for user <b>admin</b><br />to gain access to the Setup Utility
		</span></label>
		</td>
	</tr>
	<tr>
		<td width="100%" align="center">
		<span style="font-family: Arial; font-size: 13px; color: #000000;">
		<input type="password" name="password" id="password" size="30" />
		<input type="hidden" name="username" value="admin" />
		<input type="hidden" name="cookielength" value="1500" />
		</span>
		</td>
	</tr>
	<tr>
		<td width="100%" align="center">
		<span style="font-family: Arial; font-size: 13px; color: #000000;">
		<input type="submit" value="Submit" />
		</span>
		</td>
	</tr>
	</table>
	</td></tr>
	</table>
	</center></form>
	<script language="JavaScript1.2" type="text/javascript">
		<!--
			document.loginform.password.focus();
		//-->
	</script>
	~;

	&SimpleOutput;
}

sub adminlogin2 {
	if ($FORM{'password'} eq "") { &setup_fatal_error("Setup Error: You should fill in your password!"); }

	# No need to pass a form variable setup is only used by user: admin
	$username = "admin";

	if (-e "$memberdir/$username.vars") {
		$Group{'Administrator'} = "YaBB Administrator|5|staradmin.gif|red|0|0|0|0|0|0";
		&LoadUser($username);
		my $spass = ${$uid.$username}{'password'};
		$cryptpass = &encode_password($FORM{'password'});
		if ($spass ne $cryptpass && $spass ne $FORM{'password'}) {  &setup_fatal_error("Setup Error: Login Failed!"); }
	} else {
		&setup_fatal_error("Setup Error: Could not find the admin data file in $memberdir! Please check your access rights.");
	}

	if ($FORM{'cookielength'} < 1 || $FORM{'cookielength'} > 9999) { $FORM{'cookielength'} = $Cookie_Length; }
	if (!$FORM{'cookieneverexp'}) { $ck{'len'} = "\+$FORM{'cookielength'}m"; }
	else { $ck{'len'} = 'Sunday, 17-Jan-2038 00:00:00 GMT'; }
	$password = &encode_password("$FORM{'password'}");
	${$uid.$username}{'session'} = &encode_password($user_ip);
	chomp ${$uid.$username}{'session'};

	# check if forum.control can be open (needed in &LoadBoardControl used by &LoadUserSettings)
	fopen(FORUMCONTROL, "$boardsdir/forum.control") || &setup_fatal_error("$maintext_23 $boardsdir/forum.control: ", 1);
	fclose(FORUMCONTROL);

	&UpdateCookie("write", "$username", "$password", "${$uid.$username}{'session'}", "/", "$ck{'len'}");
	&LoadUserSettings;
	$yymain .= qq~
	<br /><br /><br /><form action="$set_cgi?action=setup1" method="post"><center>
	<table width="50%" border="0" bgcolor= "#000000" cellspacing="1" cellpadding="0">
	<tr><td>
	<table width="100%" border="0" bgcolor= "$windowbg" cellspacing="1" cellpadding="3">
	<tr>
		<td width="100%" align="center">
		<span style="font-family: Arial; font-size: 13px; color: #000000;">
		You are now logged in, <i>${$uid.$username}{'realname'}</i>!<br />Click Continue to proceed with the Setup.
		</span>
		</td>
	</tr>
	<tr>
		<td width="100%" align="center">
		<span style="font-family: Arial; font-size: 13px; color: #000000;">
		<input type="submit" value="Continue Set Up" />
		</span>
		</td>
	</tr>
	</table>
	</td></tr></table></center></form>
	~;

	&SimpleOutput;
}

sub autoconfig {
	&LoadCookie; # Load the user's cookie (or set to guest)
	&LoadUserSettings;
	if (!$iamadmin) { &setup_fatal_error(qq~Setup Error: You have no access rights to this function. Only user "admin" has if logged in!~); }
	# do some fancy auto sensing
	$template   = "default";
	#$forumstyle = "Forum";
	#$adminstyle = "Admin";
	$yabbfiles  = "yabbfiles";

	# find the script url
	# Getting the last known url one way or another
	if ($ENV{HTTP_REFERER}) {
		$tempboardurl = $ENV{HTTP_REFERER};
	} elsif ($ENV{HTTP_HOST} && $ENV{REQUEST_URI}) {
		$tempboardurl = qq~http://$ENV{HTTP_HOST}$ENV{REQUEST_URI}~;
	}
	$lastslash = rindex($tempboardurl, "/");
	$foundboardurl = substr($tempboardurl, 0, $lastslash);

	## find the webroot ##
	if ($ENV{'SERVER_SOFTWARE'} =~ /IIS/) {
		$this_script = "$ENV{'SCRIPT_NAME'}";
		$_ = $0;
		s~\\~/~g;
		s~$this_script~~;
		$searchroot = $_ . '/';
	} else {
		$searchroot = $ENV{'DOCUMENT_ROOT'};
		s~\\~/~g;
	}
	$firstslash = index($tempboardurl, "/", 8);
	$html_baseurl = substr($tempboardurl, 0, $firstslash);

	# try to find the yabb html basedir directly
	if (-d "$searchroot/$yabbfiles") {
		$fnd_html_root = "$html_baseurl/$yabbfiles";
		$fnd_htmldir = "$searchroot/$yabbfiles";
		$fnd_htmldir =~ s~//~/~g;
		opendir(HTMLDIR, $fnd_htmldir);
		@contents = readdir(HTMLDIR);
		closedir(HTMLDIR);
		foreach $name (@contents) {
			if (lc($name) eq "avatars" && -d "$fnd_htmldir/$name") {
				$fnd_facesdir = "$fnd_htmldir/$name";
				$fnd_facesurl = "$fnd_html_root/$name"; }
			#if (lc($name) eq "modimages" && -d "$fnd_htmldir/$name") {
			#	$fnd_modimgdir = "$fnd_htmldir/$name";
			#	$fnd_modimgurl = "$fnd_html_root/$name"; }
			#if (lc($name) eq "templates" && -d "$fnd_htmldir/$name/$forumstyle") {
			#	$fnd_forumstylesdir = "$fnd_htmldir/$name/$forumstyle";
			#	$fnd_forumstylesurl = "$fnd_html_root/$name/$forumstyle"; }
			#if (lc($name) eq "templates" && -d "$fnd_htmldir/$name/$adminstyle") {
			#$fnd_adminstylesdir = "$fnd_htmldir/$name/$adminstyle";
			#	$fnd_adminstylesurl = "$fnd_html_root/$name/$adminstyle"; }
			#if (lc($name) eq "smilies" && -d "$fnd_htmldir/$name") {
			#	$fnd_smiliesdir = "$fnd_htmldir/$name";
			#	$fnd_smiliesurl = "$fnd_html_root/$name"; }
			if (lc($name) eq "attachments" && -d "$fnd_htmldir/$name") {
				$fnd_uploaddir = "$fnd_htmldir/$name";
				$fnd_uploadurl = "$fnd_html_root/$name"; }
			#if (-d "$fnd_forumstylesdir/$template") { $fnd_imagesdir   = "$fnd_forumstylesurl/$template"; }
		}
	} else {
		opendir(HTMLDIR, $searchroot);
		@contents = readdir(HTMLDIR);
		closedir(HTMLDIR);
		foreach $name (@contents) {
			if (-d "$searchroot/$name") {
				opendir(HTMLDIR, "$searchroot/$name");
				@subcontents = readdir(HTMLDIR);
				closedir(HTMLDIR);
				foreach $subname (@subcontents) {
					if (lc($subname) eq lc($yabbfiles) && (-d "$searchroot/$name/$subname")) {
						$fnd_htmldir = "$searchroot/$name/$subname";
						$fnd_htmldir =~ s~//~/~g;
						$fnd_html_root = "$html_baseurl/$name/$subname";
					}
				}
			}
		}
		opendir(HTMLDIR, $fnd_htmldir);
		@tcontents = readdir(HTMLDIR);
		closedir(HTMLDIR);
		foreach $tname (@tcontents) {
			if (lc($tname) eq "avatars" && -d "$fnd_htmldir/$tname") {
				$fnd_facesdir = "$fnd_htmldir/$tname";
				$fnd_facesurl = "$fnd_html_root/$tname"; }
			#if (lc($tname) eq "modimages"   && -d "$fnd_htmldir/$tname") {
			#	$fnd_modimgdir = "$fnd_htmldir/$tname";
			#	$fnd_modimgurl = "$fnd_html_root/$tname"; }
			#if (lc($tname) eq "templates"   && -d "$fnd_htmldir/$tname/$forumstyle") {
			#	$fnd_forumstylesdir = "$fnd_htmldir/$tname/$forumstyle";
			#	$fnd_forumstylesurl = "$fnd_html_root/$tname/$forumstyle"; }
			#if (lc($tname) eq "templates"   && -d "$fnd_htmldir/$tname/$adminstyle") {
			#	$fnd_adminstylesdir = "$fnd_htmldir/$tname/$adminstyle";
			#	$fnd_adminstylesurl = "$fnd_html_root/$tname/$adminstyle"; }
			#if (lc($tname) eq "smilies" && -d "$fnd_htmldir/$tname") {
			#	$fnd_smiliesdir = "$fnd_htmldir/$tname";
			#	$fnd_smiliesurl = "$fnd_html_root/$tname"; }
			if (lc($tname) eq "attachments" && -d "$fnd_htmldir/$tname") {
				$fnd_uploaddir = "$fnd_htmldir/$tname";
				$fnd_uploadurl = "$fnd_html_root/$tname"; }
			#if (-d "$fnd_forumstylesdir/$template") { $fnd_imagesdir   = "$fnd_forumstylesurl/$template"; }
		}
	}
	$fnd_boardurl = $foundboardurl;
	$fnd_boarddir = ".";
	if (-d "$fnd_boarddir/Boards")    { $fnd_boardsdir    = "$fnd_boarddir/Boards"; }
	if (-d "$fnd_boarddir/Messages")  { $fnd_datadir      = "$fnd_boarddir/Messages"; }
	if (-d "$fnd_boarddir/Members")   { $fnd_memberdir    = "$fnd_boarddir/Members"; }
	if (-d "$fnd_boarddir/Sources")   { $fnd_sourcedir    = "$fnd_boarddir/Sources"; }
	if (-d "$fnd_boarddir/Admin")     { $fnd_admindir     = "$fnd_boarddir/Admin"; }
	if (-d "$fnd_boarddir/Variables") { $fnd_vardir       = "$fnd_boarddir/Variables"; }
	if (-d "$fnd_boarddir/Languages") { $fnd_langdir      = "$fnd_boarddir/Languages"; }
	if (-d "$fnd_boarddir/Help")      { $fnd_helpfile     = "$fnd_boarddir/Help"; }
	if (-d "$fnd_boarddir/Templates") { $fnd_templatesdir = "$fnd_boarddir/Templates"; }

	unless ($lastsaved) {
		$boardurl       = $fnd_boardurl;
		$boarddir       = $fnd_boarddir;
		$htmldir        = $fnd_htmldir;
		$uploaddir      = $fnd_uploaddir;
		$uploadurl      = $fnd_uploadurl;
		$yyhtml_root    = $fnd_html_root;
		$datadir        = $fnd_datadir;
		$boardsdir      = $fnd_boardsdir;
		$memberdir      = $fnd_memberdir;
		$sourcedir      = $fnd_sourcedir;
		$admindir       = $fnd_admindir;
		$vardir         = $fnd_vardir;
		$langdir        = $fnd_langdir;
		$helpfile       = $fnd_helpfile;
		$templatesdir   = $fnd_templatesdir;
		#$forumstylesdir = $fnd_forumstylesdir;
		#$forumstylesurl = $fnd_forumstylesurl;
		#$adminstylesdir = $fnd_adminstylesdir;
		#$adminstylesurl = $fnd_adminstylesurl;
		$facesdir       = $fnd_facesdir;
		$facesurl       = $fnd_facesurl;
		#$smiliesdir     = $fnd_smiliesdir;
		#$smiliesurl     = $fnd_smiliesurl;
		#$modimgdir      = $fnd_modimgdir;
		#$modimgurl      = $fnd_modimgurl;
	}

	# Simple output of env variables, for troubleshooting
	if    ($ENV{'SCRIPT_FILENAME'} ne "") { $support_env_path = $ENV{'SCRIPT_FILENAME'}; }
	elsif ($ENV{'PATH_TRANSLATED'} ne "") { $support_env_path = $ENV{'PATH_TRANSLATED'}; }

	# Remove Setupl.pl and cgi - and also nph- for buggy IIS.
	$support_env_path =~ s~(nph-)?Setup.(pl|cgi)~~ig;
	$support_env_path =~ s~\/\Z~~;

	# replace \'s with /'s for Windows Servers
	$support_env_path =~ s~\\~/~g;


	# Generate Screen
	if (-e "$langdir/$language/Main.lng") {
		require "$langdir/$use_lang/Main.lng";
	} elsif (-e "$langdir/$lang/Main.lng") {
		require "$langdir/$lang/Main.lng";
	} elsif (-e "$langdir/English/Main.lng") {
		require "$langdir/English/Main.lng";
	}

	$mylastdate = &timeformat($lastdate);

	$yymain .= qq~
<form action="$set_cgi?action=setup2" method="post" name="auto_settings" style="display: inline;">
<script language="JavaScript1.2" type="text/javascript">
<!--
function abspathfill(brddir) {
	document.auto_settings.preboarddir.value = brddir;
}
function autofill() {
	var boardurl = document.auto_settings.preboardurl.value || "$boardurl";
	var boarddir = document.auto_settings.preboarddir.value || ".";
	var htmldir = document.auto_settings.prehtmldir.value || "";
	var htmlurl = document.auto_settings.prehtml_root.value || "";
	if(!htmldir) {return 0;}
	if(!htmlurl) {return 0;}
	htmldir = htmldir.replace(/\\/+\$/, "");
	htmlurl = htmlurl.replace(/\\/+\$/, "");
	var confirmvalue = confirm("Do autofill the forms in the right colum below (Saved:) with the basic values in here?");
	if(!confirmvalue) {return 0;}
	else {
		// Board URL
		document.auto_settings.boardurl.value = boardurl;

		// cgi Directories
		document.auto_settings.boarddir.value = boarddir;
		document.auto_settings.boardsdir.value = boarddir + "/Boards";
		document.auto_settings.datadir.value = boarddir + "/Messages";
		document.auto_settings.vardir.value = boarddir + "/Variables";
		document.auto_settings.memberdir.value = boarddir + "/Members";
		document.auto_settings.sourcedir.value = boarddir + "/Sources";
		document.auto_settings.admindir.value = boarddir + "/Admin";
		document.auto_settings.langdir.value = boarddir + "/Languages";
		document.auto_settings.templatesdir.value = boarddir + "/Templates";
		document.auto_settings.helpfile.value = boarddir + "/Help";

		// HTML URLs
		document.auto_settings.html_root.value = htmlurl;
		//document.auto_settings.forumstylesurl.value = htmlurl + "/Templates/Forum";
		//document.auto_settings.adminstylesurl.value = htmlurl + "/Templates/Admin";
		document.auto_settings.uploadurl.value = htmlurl + "/Attachments";
		document.auto_settings.facesurl.value = htmlurl + "/avatars";
		//document.auto_settings.smiliesurl.value = htmlurl + "/Smilies";
		//document.auto_settings.modimgurl.value = htmlurl + "/ModImages";

		// HTML Directories
		document.auto_settings.uploaddir.value = htmldir + "/Attachments";
		document.auto_settings.htmldir.value = htmldir;
		//document.auto_settings.forumstylesdir.value = htmldir + "/Templates/Forum";
		//document.auto_settings.adminstylesdir.value = htmldir + "/Templates/Admin";
		document.auto_settings.facesdir.value = htmldir + "/avatars";
		//document.auto_settings.smiliesdir.value = htmldir + "/Smilies";
		//document.auto_settings.modimgdir.value = htmldir + "/ModImages";
	}
}
//-->
</script>

	<table width="80%" bgcolor="#000000" border="0" cellspacing="1" cellpadding="3" align="center">
	<tr>
		<td colspan="2" bgcolor="$header" align="left">
		<span style="font-family: arial; font-size: 13px; color: #fefefe;">&nbsp;<b>Absolute Path to the main script directory</b></span>
		</td>
	</tr>
	<tr>
		<td width="43%" bgcolor= "$windowbg2" align="left">
			<div style="float: left; width: 80%; text-align: left; font-family: Arial; font-size: 11px; color: #000000;">Only click on the insert button if your server needs the absolute path to the YaBB main script</div>
			<div style="float: left; width: 20%; text-align: right;"><input type="button" onclick="abspathfill('$support_env_path')" value="Insert" style="font-size: 11px;" /></div>
		</td>
		<td width="57%" bgcolor="$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$support_env_path</span></td>
	</tr>
	<tr>
		<td colspan="2" bgcolor= "$header" align="left">
		<span style="font-family: Arial; font-size: 13px; color: #fefefe;">&nbsp;<b>Change this form if changes are necessary.</b></span>
		</td>
	</tr>
	<tr>
		<td width="43%" bgcolor= "$windowbg2" align="left">
			<label for="preboarddir"><span style="font-family: Arial; font-size: 13px; color: #000000;">
			Main Script Directory:
			</span><br />
			<span style="font-family: Arial; font-size: 11px; color: #000000;">
			The server path to the board's folder (usually can be left as '.')
			</span></label>
		</td>
		<td width="57%" bgcolor= "$windowbg" align="left">
			<input type="text" size="60" name ="preboarddir" id ="preboarddir" value="$boarddir" />
		</td>
	</tr>
	<tr>
		<td width="43%" bgcolor= "$windowbg2" align="left">
			<label for="preboardurl"><span style="font-family: Arial; font-size: 13px; color: #000000;">
			Board URL:
			</span><br />
			<span style="font-family: Arial; font-size: 11px; color: #000000;">
			URL of your board's folder (without trailing '/')
			</span></label>
		</td>
		<td width="57%" bgcolor= "$windowbg" align="left">
			<input type="text" size="60" name ="preboardurl" id ="preboardurl" value="$boardurl" />
		</td>
	</tr>
	<tr>
		<td width="43%" bgcolor= "$windowbg2" align="left">
			<label for="prehtmldir"><span style="font-family: Arial; font-size: 13px; color: #000000;">
			HTML Root Directory:
			</span><br />
			<span style="font-family: Arial; font-size: 11px; color: #000000;">
			Base Path for all /html/css files and folders
			</span></label>
		</td>
		<td width="57%" bgcolor= "$windowbg" align="left">
			<input type="text" size="60" name ="prehtmldir" id ="prehtmldir" value="$htmldir" />
		</td>
	</tr>
	<tr>
		<td width="43%" bgcolor= "$windowbg2" align="left">
			<label for="prehtml_root"><span style="font-family: Arial; font-size: 13px; color: #000000;">
			HTML Root URL:
			</span><br />
			<span style="font-family: Arial; font-size: 11px; color: #000000;">
			Base URL for all /html/css files and folders
			</span></label>
		</td>
		<td width="57%" bgcolor= "$windowbg" align="left">
			<input type="text" size="60" name ="prehtml_root" id ="prehtml_root" value="$yyhtml_root" />
		</td>
	</tr>
	<tr>
		<td colspan="2" bgcolor= "$catbg" align="center">
			<br />
			<input type="button" onclick="autofill()" value="Autofill the forms below" style="width: 200px;" />
			<br /><br />
		</td>
	</tr>
</table>
<br /><br />

<table width="80%" bgcolor="#000000" border="0" cellspacing="1" cellpadding="3" align="center">
	<tr>
		<td colspan="4" bgcolor= "$header" width="100%" align="left">
		<input type="hidden" name="lastsaved" value="${$uid.$username}{'realname'}" />
		<input type="hidden" name="lastdate" value="$date" />
		<span style="font-family: Arial; font-size: 13px; color: #fefefe;">&nbsp;<b>These are the settings detected on your server and the last saved settings.</b></span>
		</td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$catbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">&nbsp;</span></td>
		<td width="35%" bgcolor= "$catbg" align="center"><span style="font-family: arial; font-size: 13px; color: #000000;"><b>Detected Values</b></span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><span style="font-family: arial; font-size: 13px; color: #000000;"><b>Transfer</b></span></td>
		<td width="35%" bgcolor= "$catbg" align="center"><span style="font-family: arial; font-size: 13px; color: #000000;"><b>Saved: $mylastdate</b></span></td>
	</tr>
	<tr>
		<td colspan="4" bgcolor= "$header" width="100%" align="left">
		<span style="font-family: arial; font-size: 13px; color: #fefefe;">&nbsp; <b>CGI-BIN Settings</b></span>
		</td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Board URL:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_boardurl</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.boardurl.value = '$fnd_boardurl';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="boardurl" value="$boardurl" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Main Script Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_boarddir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.boarddir.value = '$fnd_boarddir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="boarddir" value="$boarddir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Admin Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_admindir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.admindir.value = '$fnd_admindir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="admindir" value="$admindir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Boards Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_boardsdir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.boardsdir.value = '$fnd_boardsdir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="boardsdir" value="$boardsdir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Help Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_helpfile</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.helpfile.value = '$fnd_helpfile';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="helpfile" value="$helpfile" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Languages Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_langdir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.langdir.value = '$fnd_langdir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="langdir" value="$langdir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Member Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_memberdir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.memberdir.value = '$fnd_memberdir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="memberdir" value="$memberdir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Message Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_datadir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.datadir.value = '$fnd_datadir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="datadir" value="$datadir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Sources Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_sourcedir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.sourcedir.value = '$fnd_sourcedir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="sourcedir" value="$sourcedir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Template Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_templatesdir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.templatesdir.value = '$fnd_templatesdir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="templatesdir" value="$templatesdir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Variables Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_vardir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.vardir.value = '$fnd_vardir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="vardir" value="$vardir" /></span></td>
	</tr>
	<tr>
		<td colspan="4" bgcolor= "$header" width="100%" align="left">
		<span style="font-family: arial; font-size: 13px; color: #fefefe;">&nbsp; <b>HTML Settings</b></span>
		</td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">HTML Root Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_htmldir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.htmldir.value = '$fnd_htmldir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="htmldir" value="$htmldir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">HTML Root URL:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_html_root</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.html_root.value = '$fnd_html_root';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="html_root" value="$yyhtml_root" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Attachment Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_uploaddir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.uploaddir.value = '$fnd_uploaddir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="uploaddir" value="$uploaddir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Attachment URL:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_uploadurl</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.uploadurl.value = '$fnd_uploadurl';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="uploadurl" value="$uploadurl" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Avatar Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_facesdir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.facesdir.value = '$fnd_facesdir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="facesdir" value="$facesdir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Avatar URL:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_facesurl</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.facesurl.value = '$fnd_facesurl';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="facesurl" value="$facesurl" /></span></td>
	</tr>
	<!-- <tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Mod Images Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_modimgdir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.modimgdir.value = '$fnd_modimgdir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="modimgdir" value="$modimgdir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Mod Images URL:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_modimgurl</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.modimgurl.value = '$fnd_modimgurl';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="modimgurl" value="$modimgurl" /></span></td>
	</tr> -->
	<!-- <tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Smilies Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_smiliesdir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.smiliesdir.value = '$fnd_smiliesdir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="smiliesdir" value="$smiliesdir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Smilies URL:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_smiliesurl</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.smiliesurl.value = '$fnd_smiliesurl';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="smiliesurl" value="$smiliesurl" /></span></td>
	</tr> -->
	<!-- <tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Admin Style Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_adminstylesdir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.adminstylesdir.value = '$fnd_adminstylesdir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="adminstylesdir" value="$adminstylesdir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Admin Style URL:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_adminstylesurl</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.adminstylesurl.value = '$fnd_adminstylesurl';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="adminstylesurl" value="$adminstylesurl" /></span></td>
	</tr> -->
	<!-- <tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Forum Style Dir.:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_forumstylesdir</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.forumstylesdir.value = '$fnd_forumstylesdir';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="forumstylesdir" value="$forumstylesdir" /></span></td>
	</tr>
	<tr>
		<td width="20%" bgcolor= "$windowbg2" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">Forum Style URL:</span></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;">$fnd_forumstylesurl</span></td>
		<td width="10%" bgcolor= "$catbg" align="center"><input type="button" OnClick="javascript: document.auto_settings.forumstylesurl.value = '$fnd_forumstylesurl';return false;" value="->" /></td>
		<td width="35%" bgcolor= "$windowbg" align="left"><span style="font-family: arial; font-size: 13px; color: #000000;"><input type="text" size="40" name ="forumstylesurl" value="$forumstylesurl" /></span></td>
	</tr> -->
	<tr>
		<td colspan="4" bgcolor= "$catbg" width="100%" align="center">
		<br />
		<span style="font-family: arial; font-size: 13px; color: #000000;">
		<input type="submit" value="Save Settings" />
		</span>
		<br />
		<br />
		</td>
	</tr>
</table>
</form>
<br />
<br />
	~;
	$yytitle = "Results of Auto-Sensing";
	&SimpleOutput;
}

sub save_paths {
	&LoadCookie; # Load the user's cookie (or set to guest)
	&LoadUserSettings;
	if (!$iamadmin) { &setup_fatal_error(qq~Setup Error: You have no access rights to this function. Only user "admin" has if logged in!~); }

	$lastsaved      = $FORM{'lastsaved'};
	$lastdate       = $FORM{'lastdate'};
	$boardurl       = $FORM{'boardurl'};
	$boarddir       = $FORM{'boarddir'};
	$htmldir        = $FORM{'htmldir'};
	$uploaddir      = $FORM{'uploaddir'};
	$uploadurl      = $FORM{'uploadurl'};
	$yyhtml_root    = $FORM{'html_root'};
	$datadir        = $FORM{'datadir'};
	$boardsdir      = $FORM{'boardsdir'};
	$memberdir      = $FORM{'memberdir'};
	$sourcedir      = $FORM{'sourcedir'};
	$admindir       = $FORM{'admindir'};
	$vardir         = $FORM{'vardir'};
	$langdir        = $FORM{'langdir'};
	$helpfile       = $FORM{'helpfile'};
	$templatesdir   = $FORM{'templatesdir'};
	#$forumstylesdir = $FORM{'forumstylesdir'};
	#$forumstylesurl = $FORM{'forumstylesurl'};
	#$adminstylesdir = $FORM{'adminstylesdir'};
	#$adminstylesurl = $FORM{'adminstylesurl'};
	$facesdir       = $FORM{'facesdir'};
	$facesurl       = $FORM{'facesurl'};
	#$smiliesdir     = $FORM{'smiliesdir'};
	#$smiliesurl     = $FORM{'smiliesurl'};
	#$modimgdir      = $FORM{'modimgdir'};
	#$modimgurl      = $FORM{'modimgurl'};

	my $setfile = << "EOF";
###############################################################################
# Paths.pl                                                                    #
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

\$lastsaved = "$lastsaved";
\$lastdate = "$lastdate";

########## Directories ##########

\$boardurl = "$boardurl";                                         # URL of your board's folder (without trailing '/')
\$boarddir = "$boarddir";                                         # The server path to the board's folder (usually can be left as '.')
\$boardsdir = "$boardsdir";                                       # Directory with board data files
\$datadir = "$datadir";                                           # Directory with messages
\$memberdir = "$memberdir";                                       # Directory with member files
\$sourcedir = "$sourcedir";                                       # Directory with YaBB source files
\$admindir = "$admindir";                                         # Directory with YaBB admin source files
\$vardir = "$vardir";                                             # Directory with variable files
\$langdir = "$langdir";                                           # Directory with Language files and folders
\$helpfile = "$helpfile";                                         # Directory with Help files and folders
\$templatesdir = "$templatesdir";                                 # Directory with template files and folders
\$htmldir = "$htmldir";                                           # Base Path for all public-html files and folders
\$facesdir = "$facesdir";                                         # Base Path for all avatar files
\$uploaddir = "$uploaddir";                                       # Base Path for all attachment files

########## URL's ##########

\$yyhtml_root = "$yyhtml_root";                                   # Base URL for all html/css files and folders
\$facesurl = "$facesurl";                                         # Base URL for all avatar files
\$uploadurl = "$uploadurl";                                       # Base URL for all attachment files

########## Old Path Settings ################################
########## The following variables are deprecated! ##########
########## Don't use them for new code! #####################

\$forumstylesdir = \$htmldir . "/Templates/Forum";                # Directory with forum style files and folders
\$adminstylesdir = \$htmldir . "/Templates/Admin";                # Directory with admin style files and folders
\$smiliesdir = \$htmldir . "/Smilies";                            # Base Path for all smilie files
\$modimgdir = \$htmldir . "/ModImages";                           # Base Path for all mod images

\$forumstylesurl = \$yyhtml_root . "/Templates/Forum";            # Default Forum Style Directory
\$adminstylesurl = \$yyhtml_root . "/Templates/Admin";            # Default Admin Style Directory
\$smiliesurl = \$yyhtml_root . "/Smilies";                        # Base URL for all smilie files
\$modimgurl = \$yyhtml_root . "/ModImages";                       # Base URL for all mod images

1;
EOF

	fopen(FILE, ">./Paths.pl") || &setup_fatal_error("$maintext_23 ./Paths.pl: ", 1);
	print FILE &nicely_aligned_file($setfile);
	fclose(FILE);

	if (-e "$vardir/Paths.pl") { &delete_DBorFILE("$vardir/Paths.pl"); }

	$yySetLocation = qq~$set_cgi?action=checkmodules~;
	&redirectexit;
}

sub BrdInstall {
	$no_brddir = 0;
	if (!-d "$boardsdir") { $no_brddir = "1"; return 1; }
}

sub MesInstall {
	$no_mesdir = 0;
	if (!-d "$datadir") { $no_mesdir = "1"; return 1; }
}

sub MemInstall {
	$no_memdir = 0;
	if (!-d "$memberdir") { $no_memdir = "1"; return 1; }
}

sub VarInstall {
	my $varsdir = "$vardir";
	$no_vardir = 0;

	if (!-d "$varsdir") { $no_vardir = "1"; return 1; }

	if (!-e "$varsdir/adminlog.txt") {
		fopen(ADMLOGFILE, ">$varsdir/adminlog.txt") || &setup_fatal_error("$maintext_23 $varsdir/adminlog.txt: ", 1);
		print ADMLOGFILE "";
		fclose(ADMLOGFILE);
	}

	if (!-e "$varsdir/ConvSettings.txt") {
		my $setfile = << "EOF";
\$convertdir = qq~./Convert~;
\$convboardsdir = qq~./Convert/Boards~;
\$convmemberdir = qq~./Convert/Members~;
\$convdatadir = qq~./Convert/Messages~;
\$convvardir = qq~./Convert/Variables~;

1;
EOF

		fopen(SETTING, ">$vardir/ConvSettings.txt") || &setup_fatal_error("$maintext_23 $vardir/ConvSettings.txt: ", 1);
		print SETTING &nicely_aligned_file($setfile);
		fclose(SETTING);
	}

	if (!-e "$varsdir/allowed.txt") {
		fopen(ALLOWFILE, ">$varsdir/allowed.txt") || &setup_fatal_error("$maintext_23 $varsdir/allowed.txt: ", 1);
		print ALLOWFILE "login\n";
		print ALLOWFILE "logout\n";
		print ALLOWFILE "display\n";
		print ALLOWFILE "messageindex\n";
		print ALLOWFILE "pages\n";
		print ALLOWFILE "profile\n";
		print ALLOWFILE "register\n";
		print ALLOWFILE "resetpass\n";
		print ALLOWFILE "viewprofile";
		fclose(ALLOWFILE);
	}

	if (!-e "$varsdir/attachments.txt") {
		fopen(ATTFILE, ">$varsdir/attachments.txt") || &setup_fatal_error("$maintext_23 $varsdir/attachments.txt: ", 1);
		print ATTFILE "";
		fclose(ATTFILE);
	}

	if (!-e "$varsdir/ban_log.txt") {
		fopen(BANFILE, ">$varsdir/ban_log.txt") || &setup_fatal_error("$maintext_23 $varsdir/ban_log.txt: ", 1);
		print BANFILE "";
		fclose(BANFILE);
	}

	if (!-e "$varsdir/clicklog.txt") {
		fopen(CLICKFILE, ">$varsdir/clicklog.txt") || &setup_fatal_error("$maintext_23 $varsdir/clicklog.txt: ", 1);
		print CLICKFILE "";
		fclose(CLICKFILE);
	}

	if (!-e "$varsdir/errorlog.txt") {
		fopen(ERRORFILE, ">$varsdir/errorlog.txt") || &setup_fatal_error("$maintext_23 $varsdir/errorlog.txt: ", 1);
		print ERRORFILE "";
		fclose(ERRORFILE);
	}

	if (!-e "$varsdir/flood.txt") {
		fopen(FLOODFILE, ">$varsdir/flood.txt") || &setup_fatal_error("$maintext_23 $varsdir/flood.txt: ", 1);
		print FLOODFILE "255.255.255.255|1119313741";
		fclose(FLOODFILE);
	}

	if (!-e "$varsdir/gmodsettings.txt") {
		my $setfile = << "EOF";
### Gmod Related Setttings ###

\$allow_gmod_admin = "on"; #
\$gmod_newfile = "on"; #

### Areas Gmods can Access ###

\%gmod_access = (
'ext_admin',"",

'newsettings;page=main',"",
'newsettings;page=advanced',"on",
'editbots', "",

'newsettings;page=news',"on",
'smilies',"on",
'setcensor',"on",
'modagreement',"on",

'referer_control',"",
'newsettings;page=security',"",
'setup_guardian',"",
'newsettings;page=antispam',"",

'managecats',"",
'manageboards',"",
'helpadmin',"on",
'editemailtemplates',"",

'addmember',"",
'viewmembers',"on",
'modmemgr',"",
'mailing',"on",
'ipban',"on",
'setreserve',"on",

'modskin',"",
'modcss',"",
'modtemp',"",

'clean_log',"on",
'boardrecount',"",
'rebuildmesindex',"",
'rebuildmemlist',"",
'rebuildmemhist',"",
'deleteoldthreads',"",
'manageattachments',"on",

'detailedversion',"on",
'stats',"on",
'showclicks',"on",
'errorlog',"on",
'view_reglog',"on",

'modlist',"",
);

\%gmod_access2 = (
admin => "on",

newsettings => "on",
newsettings2 => "on",

deleteattachment => "on",
manageattachments2 => "on",
removeoldattachments => "on",
removebigattachments => "on",
rebuildattach => "on",
remghostattach => "on",

profile => "",
profile2 => "",
profileAdmin => "",
profileAdmin2 => "",
profileContacts => "",
profileContacts2 => "",
profileIM => "",
profileIM2 => "",
profileOptions => "",
profileOptions2 => "",

ext_edit => "",
ext_edit2 => "",
ext_create => "",
ext_reorder => "",
ext_convert => "",

myprofileAdmin => "",
myprofileAdmin2 => "",

delgroup => "",
editgroup => "",
editAddGroup2 => "",
modmemgr2 => "",
assigned => "",
assigned2 => "",

reordercats => "",
modifycatorder => "",
modifycat => "",
createcat => "",
catscreen => "",
reordercats2 => "",
addcat => "",
addcat2 => "",

modtemplate2 => "",
modtemp2 => "",
modstyle => "",
modstyle2 => "",
modcss => "",
modcss2 => "",

modifyboard => "",
addboard => "",
addboard2 => "",
reorderboards2 => "",
boardscreen => "",

smilieput => "on",
smilieindex => "on",
smiliemove => "on",
addsmilies => "on",

addmember => "on",
addmember2 => "on",
deletemultimembers => "on",
ml => "on",

mailmultimembers => "on",
mailing2 => "on",

activate => "on",
admin_descision => "on",
apr_regentry => "on",
del_regentry => "on",
rej_regentry => "on",
view_regentry => "on",
clean_reglog => "on",

cleanerrorlog => "on",
deleteerror => "on",

modagreement2 => "on",
modsettings2 => "on",
advsettings2 => "on",
referer_control2 => "",
removeoldthreads => "",
ipban2 => "on",
ipban3 => "on",
setcensor2 => "on",
setreserve2 => "on",

editbots2 => "",
);

1;
EOF

		fopen(SETTING, ">$varsdir/gmodsettings.txt") || &setup_fatal_error("$maintext_23 $varsdir/gmodsettings.txt: ", 1);
		print SETTING &nicely_aligned_file($setfile);
		fclose(SETTING);
	}

	if (!-e "$varsdir/log.txt") {
		fopen(LOGFILE, ">$varsdir/log.txt") || &setup_fatal_error("$maintext_23 $varsdir/log.txt: ", 1);
		print LOGFILE "admin|1105634411|127.0.0.1|";
		fclose(LOGFILE);
	}

	if (!-e "$varsdir/modlist.txt") {
		fopen(MODSFILE, ">$varsdir/modlist.txt") || &setup_fatal_error("$maintext_23 $varsdir/modlist.txt: ", 1);
		print MODSFILE "admin\n";
		fclose(MODSFILE);
	}

	if (!-e "$varsdir/news.txt") {
		fopen(NEWSFILE, ">$varsdir/news.txt") || &setup_fatal_error("$maintext_23 $varsdir/news.txt: ", 1);
		print NEWSFILE "Welcome to our forum.\n";
		print NEWSFILE "We've upgraded to YaBB 2!\n";
		print NEWSFILE "Visit [url=http://www.yabbforum.com]YaBB[/url] today \;\)\n";
		print NEWSFILE "Signup for free on our forum and benefit from new features!\n";
		print NEWSFILE "Latest info can be found on the [url=http://www.yabbforum.com/community/]YaBB Chat and Support Community[/url].\n";
		fclose(NEWSFILE);
	}

	if (!-e "$varsdir/oldestmes.txt") {
		fopen(OLDFILE, ">$varsdir/oldestmes.txt") || &setup_fatal_error("$maintext_23 $varsdir/oldestmes.txt: ", 1);
		print OLDFILE "1\n";
		fclose(OLDFILE);
	}

	if (!-e "$varsdir/registration.log") {
		fopen(REGLOG, ">$varsdir/registration.log") || &setup_fatal_error("$maintext_23 $varsdir/registration.log: ", 1);
		print REGLOG "";
		fclose(REGLOG);
	}

	if (!-e "$varsdir/reserve.txt") {
		fopen(RESERVEFILE, ">$varsdir/reserve.txt") || &setup_fatal_error("$maintext_23 $varsdir/reserve.txt: ", 1);
		print RESERVEFILE "yabb\n";
		print RESERVEFILE "YaBBadmin\n";
		print RESERVEFILE "administrator\n";
		print RESERVEFILE "admin\n";
		print RESERVEFILE "y2\n";
		print RESERVEFILE "xnull\n";
		print RESERVEFILE "yabb2\n";
		print RESERVEFILE "yabbforum\n";
		fclose(RESERVEFILE);
	}

	if (!-e "$varsdir/reservecfg.txt") {
		fopen(RESERVEFILE, ">$varsdir/reservecfg.txt") || &setup_fatal_error("$maintext_23 $varsdir/reservecfg.txt: ", 1);
		print RESERVEFILE "checked\n";
		print RESERVEFILE "\n";
		print RESERVEFILE "checked\n";
		print RESERVEFILE "checked\n";
		fclose(RESERVEFILE);
	}
}

sub checkmodules {
	LoadLanguage("Admin");

	&tempstarter;

	$yymain .= qq~
<form action="$set_cgi?action=setinstall" method="post">~;

	require "$admindir/ModuleChecker.pl";
	$yymain =~ s/float: left; |<\/div>$//g;

	if ($dont_continue_setup) {
		$yymain .= qq~
	<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td width="100%" class="windowbg2" align="center">
			<br />
			<font color="red" size="+2">Sorry, you can't continue until you insatlled at least the "Digest::MD5" module.</font><br />
			<br />
		</td>
	</tr>
	</table>~;
	} else {
		$yymain .= qq~
	<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td width="100%" class="catbg" align="center">
			<br />
			You can see the above informations allways on the start page of your AdminCenter.<br />
			Therefore you can continue now and install missing modules later if you really needed them.<br />
			<br />
			<input type="submit" value="Continue" /><br />
			<br />
		</td>
	</tr>
	</table>~;
	}

	$yymain .= qq~
</div>
</form>
~;

	$yyim    = "You are running YaBB 2 Setup.";
	$yytitle = "YaBB 2 Setup";
	&SetupTemplate;
}

sub SetInstall {
	LoadLanguage("Admin");

	&tempstarter;

	# show avaliable languages
	opendir(DIR, $langdir) || &setup_fatal_error("Directory: $langdir: ", 1);
	my @lfilesanddirs = readdir(DIR);
	close(DIR);
	my $drawnldirs;
	foreach my $fld (sort {lc($a) cmp lc($b)} @lfilesanddirs) {
		if (-d "$langdir/$fld" && -e "$langdir/$fld/Main.lng" && $fld =~ m^\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@/]+\Z^) {
			if ('English' eq $fld) { $drawnldirs .= qq~<option value="$fld" selected="selected">$fld</option>\n~; }
			else { $drawnldirs .= qq~<option value="$fld">$fld</option>\n~; }
		}
	}

	$yymain .= qq~
<form action="$set_cgi?action=setinstall2" method="post">
 <div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
   <table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td width="100%" class="titlebg" align="left">
		System Setup
		</td>
	</tr><tr valign="middle">
		<td width="100%" class="windowbg" align="left">
		Here you can set some of the default settings for your new YaBB 2 forum.<br />
		After finishing the setup procedure, you should login to your forum and go to your 'Admin Center' -&gt; 'Forum Settings' where you can modify this and other settings.
		</td>
	</tr><tr valign="middle">
		<td width="100%" class="windowbg2" align="left">
		<div style="float: left; font-family: verdana; width: 45%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		<label for="mbname">Message Board Name</label>
		</div>
		<div style="float: left; font-family: verdana; width: 55%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		<input type="text" name="mbname" id="mbname" size="35" value="My Perl YaBB Forum" />
		</div>
	<br />
		<div style="float: left; font-family: verdana; width: 45%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		<label for="webmaster_email">Webmaster E-mail Address</label>
		</div>
		<div style="float: left; font-family: verdana; width: 55%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		<input type="text" name="webmaster_email" id="webmaster_email" size="35" value="webmaster\@mysite.com" />
		</div>
	<br />
		<div style="float: left; font-family: verdana; width: 45%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		<label for="defaultlanguage">Admin Language / Forum Default Language</label>
		</div>
		<div style="float: left; font-family: verdana; width: 55%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		<select name="defaultlanguage" id="defaultlanguage">$drawnldirs</select>
		</div>
	<br />
		<div style="float: left; font-family: verdana; width: 45%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		<label for="timeselect">Default Time Format</label>
		</div>
		<div style="float: left; font-family: verdana; width: 55%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		<select name="timeselect" id="timeselect" size="1">
			<option value="1">01/31/01 at 13:15:17</option>
			<option value="5">01/31/01 at 1:15pm</option>
			<option value="4" selected="selected">Jan 12th, 2001 at 1:15pm</option>
			<option value="8"> 12th Jan, 2001 at 1:15pm</option>
			<option value="2">31.01.01 at 13:15:17</option>
			<option value="3">31.01.2001 at 13:15:17</option>
			<option value="6">31. Jan at 13:15</option>
		</select>
		</div>
	<br />
		<div style="float: left; font-family: verdana; width: 45%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
		Forum Time Zone<br />
		<span style="font-size:small">If the time displayed here differ from your local time, then ajust it by changing the settings.</span>
		</div>
		<div style="float: left; font-family: verdana; width: 55%; text-align: left; font-size: 12px; padding-top: 2px; padding-bottom: 2px;">
			<span style="font-size:small">Your actually displayed local time:<br /><b>~ . &timeformat($date,4) . qq~<br /><br /></span><select name="usertimesign"><option value="">+</option><option value="-">-</option></select>
			<select name="usertimehour">~;
	for (my $i = 0; 15 > $i; $i++) {
		$i = sprintf("%02d", $i);
		$yymain .= qq~<option value="$i">$i</option>~;
	}
	$yymain .= qq~</select> : <select name="usertimemin">~;
	for (my $i = 0; 60 > $i; $i++) {
		my $j = $i / 60;
		$j = (split(/\./, $j))[1] || 0;
		$yymain .= qq~<option value="$j">~ . sprintf("%02d", $i) . qq~</option>~;
	}
	$yymain .= qq~</select>
		</div>
		<input type="hidden" name="dstoffset" value="1" />
	<br />
		</td>
	</tr>
	<tr valign="middle">
		<td width="100%" class="catbg" align="center">
		<input type="submit" value="Continue" />
		</td>
	</tr>
	</table>
</div>
</form>
~;

	$yyim    = "You are running YaBB 2 Setup.";
	$yytitle = "YaBB 2 Setup";
	&SetupTemplate;
}

sub SetInstall2 {
	if ($action eq "checkmodules" || $action eq "setinstall2") {
		$settings_file_version = "YaBB 0.0.0";
		$maintenance = 1;
		$members_total = 1;
		$last_member = "admin";  
		$rememberbackup = 0;
		$guestaccess = 1;
		$mbname = $FORM{'mbname'} || 'My Perl YaBB Forum';
		$mbname =~ s/\"/\'/g;
		$forumstart = &timetostring(int(time));
		$Cookie_Length = 1;
		$regtype = 3;
		$RegAgree = 1;
		$RegReasonSymbols = 500;
		$preregspan = 24;
		$emailpassword = 0;
		$emailnewpass = 0;
		$emailwelcome = 0;
		$name_cannot_be_userid = 1;
		$gender_on_reg = 0;
		$lang = $FORM{'defaultlanguage'} || 'English';
		$default_template = 'Forum default';
		$mailprog = '/usr/sbin/sendmail';
		$smtp_server = "127.0.0.1";
		$smtp_auth_required  = 1;
		$authuser = q^admin^;
		$authpass = q^admin^;
		$webmaster_email = $FORM{'webmaster_email'} || 'webmaster@mysite.com';
		$mailtype = 0;
		$maintenancetext = 'We are currently upgrading our forum again. Please check back shortly!';
		$MenuType = 2;
		$profilebutton = 0;
		$allow_hide_email = 1;
		$user_hide_avatars = 0;
		$user_hide_user_text = 0;
		$user_hide_attach_img = 0;
		$user_hide_signat = 0;
		$user_hide_smilies_row = 0;
		$showlatestmember = 1;
		$shownewsfader = 0;
		$Show_RecentBar = 1;
		$showmodify = 1;
		$ShowBDescrip = 1;
		$showuserpic = 1;
		$showusertext = 1;
		$showtopicviewers = 1;
		$showgenderimage = 1;
		$showyabbcbutt = 1;
		$nestedquotes = 1;
		$parseflash = 0;
		$enableclicklog = 0;
		$showimageinquote = 0;
		$enable_ubbc = 1;
		$enable_news = 1;
		$allowpics = 1;
		$upload_useravatar = 0;
		$upload_avatargroup = '';
		$avatar_limit = 100;
		$avatar_dirlimit = 10000;
		$enable_guestposting = 0;
		$ML_Allowed = 1;
		$enable_quickpost = 0;
		$enable_quickreply = 0;
		$enable_quickjump = 0;
		$enable_markquote = 0;
		$quick_quotelength = 1000;
		$enable_quoteuser = 0;
		$quoteuser_color = "#0033cc";
		$display_postpopup = 0;
		$mindex_postpopup = 0;
		$mdrop_postpopup = 0;
		$guest_media_disallowed = 0;
		$enable_guestlanguage = 1;
		$enable_notifications = 0;
		$NewNotificationAlert = 0;
		$autolinkurls = 1;
		$forumnumberformat = $FORM{'forumnumberformat'} || 1;
		$timeselected = $FORM{'timeselect'} || 0;
		$timecorrection = 0;
		$timeoffset = "$FORM{'usertimesign'}$FORM{'usertimehour'}.$FORM{'usertimemin'}";
		$dstoffset = $FORM{'dstoffset'} || 0;
		$dynamic_clock = 1;
		$TopAmmount = 15;
		$maxdisplay = 20;
		$maxfavs = 20;
		$maxrecentdisplay = 25;
		$maxsearchdisplay = 15;
		$maxmessagedisplay = 15;
		$MaxMessLen = 5500;
		$fontsizemin = 6;
		$fontsizemax = 32;
		$MaxSigLen = 200;
		$MaxAwayLen = 200;
		$ClickLogTime = 100;
		$max_log_days_old = 90;
		$fadertime = 1000;
		$color{'fadertext'} = '#000000';
		$color{'faderbg'} = '#FFFFFF';
		$defaultusertxt = 'I Love YaBB 3.0!';
		$timeout = 5;
		$HotTopic = 10;
		$VeryHotTopic = 25;
		$barmaxdepend = 0;
		$barmaxnumb = 500;
		$defaultml = 'regdate';
		$max_avatar_width = 65;
		$max_avatar_height = 65;
		$fix_avatar_img_size = 0;
		$max_post_img_width = 0;
		$max_post_img_height = 0;
		$fix_post_img_size = 0;
		$max_signat_img_width = 0;
		$max_signat_img_height = 0;
		$fix_signat_img_size = 0;
		$max_attach_img_width = 0;
		$max_attach_img_height = 0;
		$fix_attach_img_size = 0;
		$img_greybox = 1;
		$extendedprofiles = 0;
		$enable_freespace_check = 0;
		if (-e "/bin/gzip" && open(GZIP, "| gzip -f")) {
			$gzcomp = 1;
		} else {
			eval { require Compress::Zlib; Compress::Zlib::memGzip("test"); };
			$gzcomp = $@ ? 0 : 2;
		}
		$gzforce = 0;
		$cachebehaviour = 0;
		$use_flock = 1;
		$faketruncation = 0;
		$debug = 0;

		$checkallcaps = 6;
		$set_subjectMaxLength = 50;
		$MaxMessLen = 2000;
		$speedpostdetection = 1;
		$spd_detention_time = 300;
		$min_post_speed = 2;
		$post_speed_count = 3;
		$minlinkpost = 0;
		$minlinksig = 0;

		$maxsteps = 40;
		$stepdelay = 75;
		$fadelinks = 0;

		# Let's generate them a masterkey at setup time.
		my @chars = ('A' .. 'Z', 'a' .. 'z', 0 .. 9);
		$masterkey .= $chars[rand @chars] for 1 .. 24;

	} else {
		$forumstart = &timetostring($INFO{'firstforum'});
		$MaxSigLen  = $siglength || 200;
		$fadertime  = 1000;
	}

	my $setfile = << "EOF";
###############################################################################
# Settings.pl                                                                 #
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

########## Board Info ##########
# Note: these settings must be properly changed for YaBB to work

\$settings_file_version = "$settings_file_version"; # If not equal actual YaBBversion then the updating process is run through

\%templateset = (
'Forum default' => "default|default|default|default|default|default|default|",
'Old YaBB 2.1 style' => "yabb21|yabb21|yabb21|yabb21|yabb21|yabb21|yabb21|",
'Old YaBB 2.4 style' => "yabb24|yabb24|yabb24|yabb24|yabb24|yabb24|yabb24|",
);                                                  # Forum templates settings

\$members_total = $members_total;                   # Total number of Members
\$last_member = "\Q$last_member\E";                 # Name of the last Member

\$maintenance = $maintenance;                       # Set to 1 to enable Maintenance mode
\$rememberbackup = $rememberbackup;                 # seconds past since last backup until alert is displayed
\$guestaccess = $guestaccess;                       # Set to 0 to disallow guests from doing anything but login or register

\$mbname = q^$mbname^;                              # The name of your YaBB forum
\$forumstart = "$forumstart";                       # The start date of your YaBB Forum
\$Cookie_Length = $Cookie_Length;                   # Default minutes to set login cookies to stay for
\$cookieusername = "$cookieusername";               # Name of the username cookie
\$cookiepassword = "$cookiepassword";               # Name of the password cookie
\$cookiesession_name = "$cookiesession_name";       # Name of the Session cookie

\$regtype = $regtype;                               # 0 = registration closed (only admin can register),
                                                    # 1 = pre registration with admin approval,
                                                    # 2 = pre registration and email activation, 3 = open registration

\$RegAgree = $RegAgree;                             # Set to 1 to display the registration agreement when registering
\$RegReasonSymbols = $RegReasonSymbols;             # Maximum allowed symbols in User reason(s) for registering
\$preregspan = $preregspan;                         # Time span in hours for users to account activation before cleanup.
\$pwstrengthmeter_scores = "10,15,30,40";           # Password-Strength-Meter Scores
\$pwstrengthmeter_common = qq~"123","123456"~;      # Password-Strength-Meter common words
\$pwstrengthmeter_minchar = 5;                      # Password-Strength-Meter minimum characters
\$emailpassword = $emailpassword;                   # 0 - instant registration. 1 - password emailed to new members
\$emailnewpass = $emailnewpass;                     # Set to 1 to email a new password to members if
                                                    # they change their email address
\$emailwelcome = $emailwelcome;                     # Set to 1 to email a welcome message to users even
                                                    # when you have mail password turned off
\$name_cannot_be_userid = $name_cannot_be_userid;   # Set to 1 to require users to have different usernames and display names

\$gender_on_reg = $gender_on_reg;                   # 0: don't ask for gender on registration
                                                    # 1: ask for gender, no input required
                                                    # 2: ask for gender, input required
\$lang = "$lang";                                   # Default Forum Language
\$default_template = "$default_template";           # Default Forum Template

\$mailprog = "$mailprog";                           # Location of your sendmail program
\$smtp_server = "$smtp_server";                     # Address of your SMTP-Server (for Net::SMTP::TLS, specify the port number with a ":<portnumber>" at the end)
\$smtp_auth_required = $smtp_auth_required;         # Set to 1 if the SMTP server requires Authorisation
\$authuser = q^$authuser^;                          # Username for SMTP authorisation
\$authpass = q^$authpass^;                          # Password for SMTP authorisation
\$webmaster_email = q^$webmaster_email^;            # Your email address. (eg: \$webmaster_email = q^admin\@host.com^;)
\$mailtype = $mailtype;                             # Mail program to use: 0 = sendmail, 1 = SMTP, 2 = Net::SMTP, 3 = Net::SMTP::TLS

\$UseHelp_Perms = 1;                                # Help Center: 1 == use permissions, 0 == don't use permissions

########## MemberGroups ##########

\$Group{'Administrator'} = "YaBB Administrator|5|staradmin.gif|red|0|0|0|0|0|0";
\$Group{'Global Moderator'} = "Global Moderator|5|stargmod.gif|blue|0|0|0|0|0|0";
\$Group{'Moderator'} = "YaBB Moderator|5|starmod.gif|green|0|0|0|0|0|0";
\$Post{'500'} = "God Member|5|starsilver.gif||0|0|0|0|0|0";
\$Post{'250'} = "Senior Member|4|stargold.gif||0|0|0|0|0|0";
\$Post{'100'} = "Full Member|3|starblue.gif||0|0|0|0|0|0";
\$Post{'50'} = "Junior Member|2|stargold.gif||0|0|0|0|0|0";
\$Post{'-1'} = "YaBB Newbies|1|stargold.gif||0|0|0|0|0|0";

########## Layout ##########

\$maintenancetext = "$maintenancetext";             # User-defined text for Maintenance mode (leave blank for default text)
\$MenuType = $MenuType;                             # 1 for text menu or anything else for images menu
\$profilebutton = $profilebutton;                   # 1 to show view profile button under post, or 0 for blank
\$threadtools = 0;                                  # Enable dropdown for post actions
\$posttools = 0;                                    # Enable dropdown for post actions
\$userinfostyle = 0;                                # 1 for old user info on left, 0 for new user info above posts
\$allow_hide_email = $allow_hide_email;             # Allow users to hide their email from public. Set 0 to disable
\$user_hide_avatars = $user_hide_avatars;           # Allow users to hide Avatars in threads. Set 0 to disable
\$user_hide_user_text = $user_hide_user_text;       # Allow users to hide User Text in threads. Set 0 to disable
\$user_hide_attach_img = $user_hide_attach_img;     # Allow users to hide Attached Images in threads. Set 0 to disable
\$user_hide_signat = $user_hide_signat;             # Allow users to hide User Signatures in threads. Set 0 to disable
\$user_hide_smilies_row = $user_hide_smilies_row;   # Allow users to hide Smilies row below the Post-Message-inputarea. Set 0 to disable
\$showlatestmember = $showlatestmember;             # Set to 1 to display "Welcome Newest Member" on the Board Index
\$shownewsfader = $shownewsfader;                   # 1 to allow or 0 to disallow NewsFader javascript on the Board Index
                                                    # If 0, you'll have no news at all unless you put <yabb news> tag
                                                    # back into template.html!!!
\$Show_RecentBar = $Show_RecentBar;                 # Set to 1 to display the Recent Post on Board Index
\$showmodify = $showmodify;                         # Set to 1 to display "Last modified: Realname - Date" under each message
\$ShowBDescrip = $ShowBDescrip;                     # Set to 1 to display board descriptions on the topic (message) index for each board
\$showuserpic = $showuserpic;                       # Set to 1 to display each member's picture in the
                                                    # message view (by the ICQ.. etc.)
\$showusertext = $showusertext;                     # Set to 1 to display each member's personal text
                                                    # in the message view (by the ICQ.. etc.)
\$showtopicviewers = $showtopicviewers;             # Set to 1 to display members viewing/replying a topic for staff
                                                    # Set to 2 for all members; 3 for all; 0 for none
\$showgenderimage = $showgenderimage;               # Set to 1 to display each member's gender in the
                                                    # message view (by the ICQ.. etc.)
\$showyabbcbutt = $showyabbcbutt;                   # Set to 1 to display the yabbc buttons on Posting and IM Send Pages
\$nestedquotes = $nestedquotes;                     # Set to 1 to allow quotes within quotes
                                                    # (0 will filter out quotes within a quoted message)
\$parseflash = $parseflash;                         # Set to 1 to parse the flash tag
\$enableclicklog = $enableclicklog;                 # Set to 1 to track stats in Clicklog (this may slow your board down)
\$showimageinquote = $showimageinquote;             # Set to 1 to shows images in quotes, 0 displays a link to the image

\@pallist = ("#ff0000","#00ff00","#0000ff","#00ffff","#ff00ff","#ffff00"); # color settings of the palette

########## Feature Settings ##########

\$enable_ubbc = $enable_ubbc;                       # Set to 1 if you want to enable UBBC (Uniform Bulletin Board Code)
\$enable_news = $enable_news;                       # Set to 1 to turn news on, or 0 to set news off
\$allowpics = $allowpics;                           # set to 1 to allow members to choose avatars in their profile
\$upload_useravatar = $upload_useravatar;           # set to 1 to allow members to upload avatars for their profile
\$upload_avatargroup = '$upload_avatargroup';       # membergroups allowed to upload avatars for their profile, '' == all members
\$avatar_limit = $avatar_limit;                     # set to the maximum size of the uploaded avatar, 0 == no limit
\$avatar_dirlimit = $avatar_dirlimit;               # set to the maximum size of the upload avatar directory, 0 == no limit

\$enable_guestposting = $enable_guestposting;       # Set to 0 if do not allow 1 is allow.
\$guest_media_disallowed = $guest_media_disallowed; # disallow browsing guests to see media files or
                                                    # have clickable auto linked urls in messages.
\$enable_guestlanguage = $enable_guestlanguage;     # allow browsing guests to select their language
                                                    # - requires more than one language pack!
                                                    # - Set to 0 if do not allow 1 is allow.

\$enable_notifications = $enable_notifications;     # - Allow e-mail notification for boards/threads
                                                    #   listed in "My Notifications" => value == 1
                                                    # - Allow e-mail notification when new PM comes in
                                                    #   => value == 2
                                                    # - value == 0 => both disabled | value == 3 => both enabled

\$NewNotificationAlert = $NewNotificationAlert;     # enable notification alerts (popup) for new notifications
\$autolinkurls = $autolinkurls;                     # Set to 1 to turn URLs into links, or 0 for no auto-linking.

\$forumnumberformat = $forumnumberformat;           # Select your preferred output Format for Numbers
\$timeselected = $timeselected;                     # Select your preferred output Format of Time and Date
\$timecorrection = $timecorrection;                 # Set time correction for server time in seconds
\$timeoffset = "$timeoffset";                       # Time Offset to GMT/UTC (0 for GMT/UTC)
\$dstoffset = $dstoffset;                           # Time Offset (for daylight savings time, 0 to disable DST)
\$dynamic_clock = $dynamic_clock;                   # Set to a value enables the dynamic clock at the top of the page
\$TopAmmount = $TopAmmount;                         # No. of top posters to display on the top members list
\$maxdisplay = $maxdisplay;                         # Maximum of topics to display
\$maxfavs = $maxfavs;                               # Maximum of favorite topics to save in a profile
\$maxrecentdisplay = $maxrecentdisplay;             # Maximum of topics to display on recent posts by a user (-1 to disable)
\$maxsearchdisplay = $maxsearchdisplay;             # Maximum of messages to display in a search query  (-1 to disable search)
\$maxmessagedisplay = $maxmessagedisplay;           # Maximum of messages to display
\$MaxMessLen = $MaxMessLen;                         # Maximum Allowed Characters in a Posts
\$fontsizemin = $fontsizemin;                       # Minimum Allowed Font height in pixels
\$fontsizemax = $fontsizemax;                       # Maximum Allowed Font height in pixels
\$checkallcaps = $checkallcaps;                     # Set to 0 to allow ALL CAPS in posts (subject and message) or set to a value > 0 to open a JS-alert if more characters in ALL CAPS were there.
\$set_subjectMaxLength = $set_subjectMaxLength;     # Maximum Allowed Characters in a Posts Subject
\$MaxMessLen = $MaxMessLen;                         # Maximum Allowed Characters in a Posts
\$speedpostdetection = $speedpostdetection;         # Set to 1 to detect speedposters and delay their spam actions
\$spd_detention_time = $spd_detention_time;         # Time in seconds before a speedposting ban is lifted again
\$min_post_speed = $min_post_speed;                 # Minimum time in seconds between entering a post form and submitting a post
\$minlinkpost = $minlinkpost;                       # Minimum amount of posts a member needs to post links and images
\$minlinksig = $minlinksig;			    # Minimum amount of posts a member needs to create links and images in signature
\$post_speed_count = $post_speed_count;             # Maximum amount of abuses befor a user gets banned
\$MaxSigLen = $MaxSigLen;                           # Maximum Allowed Characters in Signatures
\$MaxAwayLen = $MaxAwayLen;                         # Maximum Allowed Characters in Away message
\$ClickLogTime = $ClickLogTime;                     # Time in minutes to log every click to your forum
                                                    # (longer time means larger log file size)
\$max_log_days_old = $max_log_days_old;             # If an entry in the user's log is older than ... days remove it

\$maxsteps = $maxsteps;                             # Number of steps to take to change from start color to endcolor
\$stepdelay = $stepdelay;                           # Time in miliseconds of a single step
\$fadelinks = $fadelinks;                           # Fade links as well as text?

\$color{'fadertext'}  = "$color{'fadertext'}";      # Color of text in the NewsFader (news color)
\$color{'faderbg'}  = "$color{'faderbg'}";          # Color of background in the NewsFader (news color)
\$defaultusertxt = qq~$defaultusertxt~;             # The dafault usertext visible in users posts
\$timeout = $timeout;                               # Minimum time between 2 postings from the same IP
\$HotTopic = $HotTopic;                             # Number of posts needed in a topic for it to be classed as "Hot"
\$VeryHotTopic = $VeryHotTopic;                     # Number of posts needed in a topic for it to be classed as "Very Hot"
\$barmaxdepend = $barmaxdepend;                     # Set to 1 to let bar-max-length depend on top poster
                                                    # or 0 to depend on a number of your choise
\$barmaxnumb = $barmaxnumb;                         # Select number of post for max. bar-length in memberlist
\$defaultml = "$defaultml";

\$ML_Allowed = $ML_Allowed;                         # allow browse MemberList

########## Quick Reply configuration ##########
\$enable_quickpost = $enable_quickpost;             # Set to 1 if you want to enable the quick post box
\$enable_quickreply = $enable_quickreply;           # Set to 1 if you want to enable the quick reply box
\$enable_quickjump = $enable_quickjump;             # Set to 1 if you want to enable the jump to quick reply box
\$enable_markquote = $enable_markquote;             # Set to 1 if you want to enable the mark&quote feature
\$quick_quotelength = $quick_quotelength;           # Set the max length for Quick Quotes
\$enable_quoteuser = $enable_quoteuser;             # Set to 1 if you want to enable userquote
\$quoteuser_color = "$quoteuser_color";             # Set the default color of @ in userquote

########## Post Popup configuration ##########

\$display_postpopup = $display_postpopup;		# Set to 1 if you want to enable the post popup on the display page
\$mindex_postpopup = $mindex_postpopup;			# Set to 1 if you want to enable the post popup on the message index page
\$mdrop_postpopup = $mdrop_postpopup;			# Set to 1 if you want to enable the post popup on the message drop downs

########## MemberPic Settings ##########

\$max_avatar_width = $max_avatar_width;             # Set maximum pixel width to which the selfselected userpics are resized,
                                                    # 0 disables this limit
\$max_avatar_height = $max_avatar_height;           # Set maximum pixel height to which the selfselected userpics are resized,
                                                    # 0 disables this limit
\$fix_avatar_img_size = $fix_avatar_img_size;       # Set to 1 disable the image resize feature and sets the image size to the
                                                    # max_... values. If one of the max_... values is 0 the image is shown in his
                                                    # proportions to the other value. If both are 0 the image is shown at his original size.
\$max_post_img_width = $max_post_img_width;         # Set maximum pixel width for images, 0 disables this limit
\$max_post_img_height = $max_post_img_height;       # Set maximum pixel height for images, 0 disables this limit
\$fix_post_img_size = $fix_post_img_size;           # Set to 1 disable the image resize feature and sets the image size to the
                                                    # max_... values. If one of the max_... values is 0 the image is shown in his
                                                    # proportions to the other value. If both are 0 the image is shown at his original size.
\$max_signat_img_width = $max_signat_img_width;     # Set maximum pixel width for images in the signature, 0 disables this limit
\$max_signat_img_height = $max_signat_img_height;   # Set maximum pixel height for images in the signature, 0 disables this limit
\$fix_signat_img_size = $fix_signat_img_size;       # Set to 1 disable the image resize feature and sets the image size to the
                                                    # max_... values. If one of the max_... values is 0 the image is shown in his
                                                    # proportions to the other value. If both are 0 the image is shown at his original size.
\$max_attach_img_width = $max_attach_img_width;     # Set maximum pixel width for attached images, 0 disables this limit
\$max_attach_img_height = $max_attach_img_height;   # Set maximum pixel height for attached images, 0 disables this limit
\$fix_attach_img_size = $fix_attach_img_size;       # Set to 1 disable the image resize feature and sets the image size to the
                                                    # max_... values. If one of the max_... values is 0 the image is shown in his
                                                    # proportions to the other value. If both are 0 the image is shown at his original size.
\$img_greybox = $img_greybox;                       # Set to 0 to disable "greybox" (each image is shown in a new window)
                                                    # Set to 1 to enable the attachment and post image "greybox" (one image/page)
                                                    # Set to 2 to enable the attachment and post image "greybox" =>
                                                    # attachmet images: (all images/page), post images: (one image/page)

########## Extended Profiles ##########
\$extendedprofiles = $extendedprofiles;             # Set to 1 to enabled 'Extended Profiles'. Turn it off (0) to save server load.

########## File Locking ##########
\$enable_freespace_check = $enable_freespace_check; # Enable the free disk space check on every pageview?
\$gzcomp = $gzcomp;                                 # GZip compression: 0 = No Compression,
                                                    # 1 = External gzip, 2 = Zlib::Compress
\$gzforce = $gzforce;                               # Don't try to check whether browser supports GZip
\$cachebehaviour = $cachebehaviour;                 # Browser Cache Control: 0 = No Cache must revalidate, 1 = Allow Caching
\$use_flock = $use_flock;                           # Set to 0 if your server doesn't support file locking,
                                                    # 1 for Unix/Linux and WinNT, 2 for Windows 95/98/ME and 3 for NFSLock (Unix based only)
\$faketruncation = $faketruncation;                 # Enable this option only if YaBB fails with the error:
                                                    # "truncate() function not supported on this platform."
                                                    # 0 to disable, 1 to enable.
\$debug = $debug;                                   # If set to 1 debug info is added to the template
                                                    # tags are <yabb fileactions> and <yabb filenames>



###############################################################################
# Advanced Settings (old AdvSettings.txt                                      #
###############################################################################

########## New Member Notification Settings ##########
\$new_member_notification = 0;                    # Set to 1 to enable the new member notification
\$new_member_notification_mail = '';              # Your "New Member Notification"-email address.

\$sendtopicmail = 2;                              # Set to 0 for send NO topic email to friend
                                                  # Set to 1 to send topic email to friend via YaBB
                                                  # Set to 2 to send topic email to friend via user program
                                                  # Set to 3 to let user decide between 1 and 2

########## In-Thread Multi Delete ##########

\$mdadmin = 1;
\$mdglobal = 1;
\$mdmod = 1;
\$adminbin = 0;                                   # Skip recycle bin step for admins and delete directly

########## Moderation Update ##########

\$adminview = 2;                                  # Multi-admin settings for Administrators:
                                                  # 0=none, 1=icons 2=single checkbox 3=multiple checkboxes
\$gmodview = 2;                                   # Multi-admin settings for Global Moderators:
                                                  # 0=none, 1=icons 2=single checkbox 3=multiple checkboxes
\$modview = 2;                                    # Multi-admin settings for Moderators:
                                                  # 0=none, 1=icons 2=single checkbox 3=multiple checkboxes

########## Advanced Memberview Plus ##########

\$showallgroups = 1;
\$OnlineLogTime = 15;                             # Time in minutes before Users are removed from the Online Log
\$lastonlineinlink = 0;                           # Show "Last online X days and XX:XX:XX hours ago." to all members == 1

########## Polls ##########

\$numpolloptions = 8;                             # Number of poll options
\$maxpq = 60;                                     # Maximum Allowed Characters in a Poll Qestion?
\$maxpo = 50;                                     # Maximum Allowed Characters in a Poll Option?
\$maxpc = 0;                                      # Maximum Allowed Characters in a Poll Comment?
\$useraddpoll = 1;                                # Allow users to add polls to existing threads? (1 = yes)
\$ubbcpolls = 1;                                  # Allow UBBC tags and smilies in polls? (1 = yes)

########## Advanced Instant Message Box ##########

\$PM_level = 1;
\$numposts = 1;                                   # Number of posts required to send Instant Messages
\$imspam = 0;                                     # Percent of Users a user is a allowed to send a message at once
\$numibox = 20;                                   # Number of maximum Messages in the IM-Inbox
\$numobox = 20;                                   # Number of maximum Messages in the IM-Outbox
\$numstore = 20;                                  # Number of maximum Messages in the Storage box
\$numdraft = 20;                                  # Number of maximum Messages in the Draft box
\$enable_imlimit = 0;                             # Set to 1 to enable limitation of incoming and outgoing im messages
\$enable_storefolders = 0;                        # enable additonal store folders - in/out are default for all
                                                  # 0=no > 1 = number, max 25
\$imtext = qq~Welcome to my boards~;
\$sendname = admin;
\$imsubject = "Hey Hey :)";
\$send_welcomeim = 1;

########## Topic Summary Cutter ##########

\$cutamount  = "15";                              # Number of posts to list in topic summary
\$ttsreverse = 0;                                 # Reverse Topic Summaries in Topic (most recent becomes first)
\$ttsureverse = 0;                                # Reverse Topic Summaries in Topic (most recent becomes first) allowed as user wishes? Yes == 1
\$tsreverse = 1;                                  # Reverse Topic Summaries (So most recent is first

########## Time Lock ##########

\$tlnomodflag = 1;                                # Set to 1 limit time users may modify posts
\$tlnomodtime = 1;                                # Time limit on modifying posts (days)
\$tlnodelflag = 1;                                # Set to 1 limit time users may delete posts
\$tlnodeltime = 5;                                # Time limit on deleting posts (days)
\$tllastmodflag = 1;                              # Set to 1 allow users to modify posts up to
                                                  # the specified time limit w/o showing "last Edit" message
\$tllastmodtime = 60;                             # Time limit to modify posts w/o triggering "last Edit" message (in minutes)

########## bypass post for locked thread ##########

\$bypass_lock_perm = "fa";                        # set level of permission - fa / fa+gmod / fa+gmod+mod

########## File Attachment Settings ##########

\$limit = 250;                                    # Set to the maximum number of kilobytes an attachment can be.
                                                  # Set to 0 to disable the file size check.
\$dirlimit = 10000;                               # Set to the maximum number of kilobytes the attachment directory can hold.
                                                  # Set to 0 to disable the directory size check.
\$overwrite = 0;                                  # Set to 0 to auto rename attachments if they exist,
                                                  # 1 to overwrite them or 2 to generate an error if the file exists already.
\@ext = qw(txt doc docx psd pdf bmp jpe jpg jpeg gif png swf zip rar tar); # The allowed file extensions for file attachements.
                                                  # The variable should be set in the form of "jpg bmp gif" and so on.
\$checkext = 1;                                   # Set to 1 to enable file extension checking,
                                                  # set to 0 to allow all file types to be uploaded
\$amdisplaypics = 1;                              # Set to 1 to display attached pictures in posts,
                                                  # set to 0 to only show a link to them.
\$allowattach = 1;                                # Set to the number of maximum files attaching a post,
                                                  # set to 0 to disable file attaching.
\$allowguestattach = 0;                           # Set to 1 to allow guests to upload attachments, 0 to disable guest attachment uploading.

########## Error Logger ##########

\$elmax  = "50";                                  # Max number of log entries before rotation
\$elenable = 1;                                   # allow for error logging
\$elrotate = 1;                                   # Allow for log rotation

########## Advanced Tabs ##########

\@AdvancedTabs = qw(home help search ml eventcal birthdaylist admin revalidatesession login register guestpm mycenter logout); # Advanced Tabs order and infos

########## Smilies ##########

\@SmilieURL = ("exclamation.gif","question.gif"); # Additional Smilies URL
\@SmilieCode = (":exclamation",":question");      # Additional Smilies Code
\@SmilieDescription = ("Exclaim","Questioning");  # Additional Smilies Description
\@SmilieLinebreak = ("","");                      # Additional Smilies Linebreak

\$smiliestyle = "1";                              # smiliestyle
\$showadded = "2";                                # showadded
\$showsmdir = "2";                                # showsmdir
\$detachblock = "1";                              # detachblock
\$winwidth = "400";                               # winwidth
\$winheight = "400";                              # winheight
\$popback = "FFFFFF";                             # popback
\$poptext = "000000";                             # poptext



###############################################################################
# Security Settings (old SecSettings.txt)                                     #
###############################################################################

\$regcheck = 0;                             # Set to 1 if you want to enable automatic flood protection enabled
\$codemaxchars = 6;                         # Set max length of validation code (15 is max)
\$rgb_foreground = "\#0000EE";              # Set hex RGB value for validation image foreground color
\$rgb_shade = "\#999999";                   # Set hex RGB value for validation image shade color
\$rgb_background = "\#FFFFFF";              # Set hex RGB value for validation image background color
\$translayer = 0;                           # Set to 1 background for validation image should be transparent
\$randomizer = 0;                           # Set 0 to 3 to create background random noise
                                            # based on foreground or shade color or both
\$stealthurl = 0;                           # Set to 1 to mask referer url to hosts if a hyperlink is clicked.
\$referersecurity = 0;                      # Set to 1 to activate referer security checking.
\$do_scramble_id = 1;                       # Set to 1 scambles all visible links containing user ID's
\$sessions = 1;                             # Set to 1 to activate session id protection.
\$show_online_ip_admin = 1;                 # Set to 1 to show online IP's to admins.
\$show_online_ip_gmod = 1;                  # Set to 1 to show online IP's to global moderators.
\$masterkey = '$masterkey';                 # Seed for encryption of captcha's



###############################################################################
# Guardian Settings (old Guardian.banned and Guardian.settings)               #
###############################################################################

\$banned_harvesters = qq~alexibot|asterias|backdoorbot|black.hole|blackwidow|blowfish|botalot|builtbottough|bullseye|bunnyslippers|cegbfeieh|cheesebot|cherrypicker|chinaclaw|copyrightcheck|cosmos |crescent|custo|disco|dittospyder|download demon|ecatch|eirgrabber|emailcollector|emailsiphon|emailwolf|erocrawler|eseek-larbin|express webpictures|extractorpro|eyenetie|fast|flashget|foobot|frontpage|fscrawler|getright|getweb|go!zilla|go-ahead-got-it|grabnet|grafula|gsa-crawler|harvest|hloader|hmview|httplib|httrack|humanlinks|ia_archiver|image stripper|image sucker|indy library|infonavirobot|interget|internet ninja|jennybot|jetcar|joc web spider|kenjin.spider|keyword.density|larbin|leechftp|lexibot|libweb/clshttp|linkextractorpro|linkscan/8.1a.unix|linkwalker|lwp-trivial|mass downloader|mata.hari|microsoft.url|midown tool|miixpc|mister pix|moget|mozilla.*newt|mozilla/3.mozilla/2.01|navroad|nearsite|net vampire|netants|netmechanic|netspider|netzip|nicerspro|npbot|octopus|offline explorer|offline navigator|openfind|pagegrabber|papa foto|pavuk|pcbrowser|propowerbot/2.14|prowebwalker|queryn.metasearch|realdownload|reget|repomonkey|sitesnagger|slysearch|smartdownload|spankbot|spanner |spiderzilla|steeler|superbot|superhttp|surfbot|suzuran|szukacz|takeout|teleport pro|telesoft|the.intraformant|thenomad|tighttwatbot|titan|tocrawl/urldispatcher|true_robot|turingos|turnitinbot|urly.warning|vci|voideye|web image collector|web sucker|web.image.collector|webauto|webbandit|webbandit|webcopier|webemailextrac.*|webenhancer|webfetch|webgo is|webleacher|webmasterworldforumbot|webreaper|websauger|website extractor|website quester|webster.pro|webstripper|webwhacker|webzip|wget|widow|www-collector-e|wwwoffle|xaldon webspider|xenu link sleuth|zeus~;
\$banned_referers = qq~hotsex.com|porn.com~;
\$banned_requests = qq~~;
\$banned_strings = qq~pussy|cunt~;
\$whitelist = qq~~;

\$use_guardian = 1;
\$use_htaccess = 0;

\$disallow_proxy_on = 0;
\$referer_on = 1;
\$harvester_on = 0;
\$request_on = 0;
\$string_on = 1;
\$union_on = 1;
\$clike_on = 1;
\$script_on = 1;

\$disallow_proxy_notify = 1;
\$referer_notify = 0;
\$harvester_notify = 1;
\$request_notify = 0;
\$string_notify = 1;
\$union_notify = 1;
\$clike_notify = 1;
\$script_notify = 1;



###############################################################################
# Banning Settings (old ban.txt)                                              #
###############################################################################

\$ip_banlist = "";                          # IP banlist
\$email_banlist = "";                       # EMAIL banlist
\$user_banlist = "";                        # USER banlist



###############################################################################
# Backup Settings (old BackupSettings.cgi)                                    #
###############################################################################

\@backup_paths = qw();
\$backupmethod = '';
\$compressmethod = '';
\$backupdir = '';
\$lastbackup = 0;
\$backupsettingsloaded = 0;

1;
EOF

	fopen(SETTING, ">$vardir/Settings.pl") || &setup_fatal_error("$maintext_23 $vardir/Settings.pl: ", 1);
	print SETTING &nicely_aligned_file($setfile);
	fclose(SETTING);
	if ($action eq "setinstall2") {
		&LoadUser('admin');
		${$uid.'admin'}{'email'} = $webmaster_email;
		${$uid.'admin'}{'timeoffset'} = $timeoffset; # must set before &timetostring($date)
		${$uid.'admin'}{'regdate'} = &timetostring($date);
		${$uid.'admin'}{'regtime'} = $date;
		${$uid.'admin'}{'timeselect'} = $timeselected;
		${$uid.'admin'}{'language'} = $lang;
		&UserAccount('admin', "update");
		&ManageMemberinfo('update', 'admin', $date, '', $webmaster_email);
		$yySetLocation = qq~$set_cgi?action=setup3~;
		&redirectexit;
	}
}

sub tempstarter {
	return if !-e "$vardir/Settings.pl";

	$YaBBversion = 'YaBB 3.0';

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

	# Requirements and Errors
	require "$vardir/Settings.pl";
	if (-e "$vardir/ConvSettings.txt") { require "$vardir/ConvSettings.txt"; }
	else { $convertdir = "./Convert"; }

	&LoadCookie; # Load the user's cookie (or set to guest)
	&LoadUserSettings;
	&WhatTemplate;
	&WhatLanguage;
	require "$sourcedir/Security.pl";
	&WriteLog;
}

sub CheckInstall {
	&tempstarter;

	my $install_error;
	$windowbg = "#FAFAFA";
	$header   = "#5488BA";
	$catbg    = "#DDDDDD";

	$set_missing = "";
	$set_created = "";
	if (!-e "$vardir/Settings.pl") { $set_missing = qq~Settings.pl~; }
	else { $set_created = qq~Settings.pl~; }

	$brd_missing = "";
	$brd_created = "";
	if (!-e "$boardsdir/forum.control") { $brd_missing .= qq~forum.control, ~; }
	else { $brd_created .= qq~forum.control, ~; }
	if (!-e "$boardsdir/forum.master") { $brd_missing .= qq~forum.master, ~; }
	else { $brd_created .= qq~forum.master, ~; }
	if (!-e "$boardsdir/forum.totals") { $brd_missing .= qq~forum.totals, ~; }
	else {
		$brd_created .= qq~forum.totals, ~;
		fopen(FORUMTOT, "$boardsdir/forum.totals") || &setup_fatal_error("$maintext_23 $boardsdir/forum.totals: ", 1);
		@totboards = <FORUMTOT>;
		fclose(FORUMTOT);
	}
	foreach $boardstot (@totboards) {
		chomp $boardstot;
		($brdname, undef, undef, undef, undef, $msgname, undef) = split(/\|/, $boardstot, 7);
		if (!-e "$boardsdir/$brdname.txt") { $brd_missing .= qq~$brdname.txt, ~; }
		else { $brd_created .= qq~$brdname.txt, ~; }
	}
	$brd_missing =~ s/, $//;
	$brd_created =~ s/, $//;

	$mem_missing = "";
	$mem_created = "";
	if (!-e "$memberdir/admin.outbox") { $mem_missing .= qq~admin.outbox, ~; }
	else { $mem_created .= qq~admin.outbox, ~; }
	if (!-e "$memberdir/admin.vars") { $mem_missing .= qq~admin.vars, ~; }
	else { $mem_created .= qq~admin.vars, ~; }
	if (!-e "$memberdir/memberinfo.txt") { $mem_missing .= qq~memberinfo.txt, ~; }
	else { $mem_created .= qq~memberinfo.txt, ~; }
	$mem_missing =~ s/, $//;
	$mem_created =~ s/, $//;

	$msg_missing = "";
	$msg_created = "";

	if (-e "$boardsdir/forum.totals") {
		fopen(FORUMTOT, "$boardsdir/forum.totals") || &setup_fatal_error("$maintext_23 $boardsdir/forum.totals: ", 1);
		@totboards = <FORUMTOT>;
		fclose(FORUMTOT);
	}
	foreach $boardstot (@totboards) {
		chomp $boardstot;
		($brdname, undef, undef, undef, undef, $msgname, undef) = split(/\|/, $boardstot, 7);
		next if !$msgname;
		if (!-e "$datadir/$msgname.ctb") { $msg_missing .= qq~$msgname.ctb, ~; }
		else { $msg_created .= qq~$msgname.ctb, ~; }
		if (!-e "$datadir/$msgname.txt") { $msg_missing .= qq~$msgname.txt, ~; }
		else { $msg_created .= qq~$msgname.txt~; }
	}
	$msg_missing =~ s/, $//;
	$msg_created =~ s/, $//;

	$var_missing = "";
	$var_created = "";
	if (!-e "$vardir/adminlog.txt") { $var_missing .= qq~adminlog.txt, ~; }
	else { $var_created .= qq~adminlog.txt, ~; }
	if (!-e "$vardir/allowed.txt") { $var_missing .= qq~allowed.txt, ~; }
	else { $var_created .= qq~allowed.txt, ~; }
	if (!-e "$vardir/attachments.txt") { $var_missing .= qq~attachments.txt, ~; }
	else { $var_created .= qq~attachments.txt, ~; }
	if (!-e "$vardir/ban_log.txt") { $var_missing .= qq~ban_log.txt, ~; }
	else { $var_created .= qq~ban_log.txt, ~; }
	if (!-e "$vardir/clicklog.txt") { $var_missing .= qq~clicklog.txt, ~; }
	else { $var_created .= qq~clicklog.txt, ~; }
	if (!-e "$vardir/errorlog.txt") { $var_missing .= qq~errorlog.txt, ~; }
	else { $var_created .= qq~errorlog.txt, ~; }
	if (!-e "$vardir/flood.txt") { $var_missing .= qq~flood.txt, ~; }
	else { $var_created .= qq~flood.txt, ~; }
	if (!-e "$vardir/gmodsettings.txt") { $var_missing .= qq~gmodsettings.txt, ~; }
	else { $var_created .= qq~gmodsettings.txt, ~; }
	if (!-e "$vardir/log.txt") { $var_missing .= qq~log.txt, ~; }
	else { $var_created .= qq~log.txt, ~; }
	if (!-e "$vardir/modlist.txt") { $var_missing .= qq~modlist.txt, ~; }
	else { $var_created .= qq~modlist.txt, ~; }
	if (!-e "$vardir/news.txt") { $var_missing .= qq~news.txt, ~; }
	else { $var_created .= qq~news.txt, ~; }
	if (!-e "$vardir/oldestmes.txt") { $var_missing .= qq~oldestmes.txt, ~; }
	else { $var_created .= qq~oldestmes.txt, ~; }
	if (!-e "$vardir/registration.log") { $var_missing .= qq~registration.log, ~; }
	else { $var_created .= qq~registration.log, ~; }
	if (!-e "$vardir/reserve.txt") { $var_missing .= qq~reserve.txt, ~; }
	else { $var_created .= qq~reserve.txt, ~; }
	if (!-e "$vardir/reservecfg.txt") { $var_missing .= qq~reservecfg.txt, ~; }
	else { $var_created .= qq~reservecfg.txt, ~; }
	$var_missing =~ s/, $//;
	$var_created =~ s/, $//;

	$yymain .= qq~
<div class="boardcontainer">
	<table width="100%" border="0" cellspacing="1" cellpadding="4">
	<tr><td width="100%" colspan="2" class="titlebg" align="left">
	Checking System Files
	</td></tr>
	<tr><td width="100%" class="catbg" colspan="2" align="left">
	~;
	if ($no_brddir) {
		$install_error = 1;
		$yymain .= qq~
	A problem has occurred in the /Boards folder!
	</td></tr>
	<tr><td width="6%" class="windowbg" align="center">
	<img src="$imagesdir/on.gif" alt="" />
	</td><td width="94%" class="windowbg2" align="left">
	No /Boards folder available!
	</td></tr>
		~;
	} else {
		if ($brd_missing) {
			$install_error = 1;
			$yymain .= qq~
	A problem has occurred in the /Boards folder!
	</td></tr>
	<tr><td width="6%" class="windowbg" align="left">
	<img src="$imagesdir/on.gif" alt="" />
	</td><td width="94%" class="windowbg2" align="left">
	<b>Missing: </b><br />
	$brd_missing
	</td></tr>
			~;
		}
		if ($brd_created) {
			if (!$brd_missing) {
				$yymain .= qq~
	Successfully checked the /Boards folder!
	</td></tr>
~				;
			}
			$yymain .= qq~
	<tr><td width="6%" class="windowbg" align="center">
	<img src="$imagesdir/off.gif" alt="" />
	</td><td width="94%" class="windowbg2" align="left">
	<b>Installed: </b><br />
	$brd_created
	</td></tr>
			~;
		}
	}
	$yymain .= qq~
	<tr><td width="100%" class="catbg" colspan="2" align="left">
	~;

	if ($no_memdir) {
		$install_error = 1;
		$yymain .= qq~
	A Problem has occurred in the /Members folder!
	</td></tr>
	<tr><td width="6%" class="windowbg" align="center">
	<img src="$imagesdir/on.gif" alt="" />
	</td><td width="94%" class="windowbg2" align="left">
	No /Members folder available!
	</td></tr>
		~;
	} else {
		if ($mem_missing) {
			$install_error = 1;
			$yymain .= qq~
	A problem has occurred in the /Members folder!
	</td></tr>
	<tr><td width="6%" class="windowbg" align="center">
	<img src="$imagesdir/on.gif" alt="" />
	</td><td width="94%" class="windowbg2" align="left">
	<b>Missing: </b><br />
	$mem_missing
	</td></tr>
			~;
		}
		if ($mem_created) {
			if (!$mem_missing) {
				$yymain .= qq~
	Successfully checked the /Members folder!
	</td></tr>
				~;
			}
			$yymain .= qq~
	<tr><td width="6%" class="windowbg" align="center">
	<img src="$imagesdir/off.gif" alt="" />
	</td><td width="94%" class="windowbg2" align="left">
	<b>Installed: </b><br />
	$mem_created
	</td></tr>
			~;
		}
	}
	$yymain .= qq~
	<tr><td width="100%" class="catbg" colspan="2" align="left">
	~;

	if ($no_mesdir) {
		$install_error = 1;
		$yymain .= qq~
	A problem has occurred in the /Messages folder!
	</td></tr>
	<tr><td width="6%" class="windowbg" align="center">
	<img src="$imagesdir/on.gif" alt="" />
	</td><td width="94%" class="windowbg2" align="left">
	No /Messages folder available!
	</td></tr>
		~;
	} else {
		if ($msg_missing) {
			$install_error = 1;
			$yymain .= qq~
	A problem has occurred in the /Messages folder!
	</td></tr>
	<tr><td width="6%" class="windowbg" align="center">
	<img src="$imagesdir/on.gif" alt="" />
	</td><td width="94%" class="windowbg2" align="left">
	<b>Missing: </b><br />
	$msg_missing
	</td></tr>
			~;
		}
		if ($msg_created) {
			if (!$msg_missing) {
				$yymain .= qq~
	Successfully checked the /Messages folder!
	</td></tr>
				~;
			}
			$yymain .= qq~
	<tr><td width="6%" class="windowbg" align="center">
	<img src="$imagesdir/off.gif" alt="" />
	</td><td width="94%" class="windowbg2" align="left">
	<b>Installed: </b><br />
	$msg_created
	</td></tr>
			~;
		}
	}
	$yymain .= qq~
	<tr><td width="100%" class="catbg" colspan="2" align="left">
	~;
	if ($no_vardir) {
		$install_error = 1;
		$yymain .= qq~
	A problem has occurred in the /Variables folder!
	</td></tr>
	<tr><td width="6%" class="windowbg" align="center">
	<img src="$imagesdir/on.gif" alt="" />
	</td><td width="94%" class="windowbg2" align="left">
	No /Variables folder available!
	</td></tr>
		~;
	} else {
		if ($var_missing) {
			$install_error = 1;
			$yymain .= qq~
	A problem has occurred in the /Variables folder!
	</td></tr>
	<tr><td width="6%" class="windowbg" align="center">
	<img src="$imagesdir/on.gif" alt="" />
	</td><td width="94%" class="windowbg2" align="left">
	<b>Missing: </b><br />
	$var_missing
	</td></tr>
			~;
		}
		if ($var_created) {
			if (!$var_missing) {
				$yymain .= qq~
	Successfully checked the /Variables folder!
	</td></tr>
				~;
			}
			$yymain .= qq~
	<tr><td width="6%" class="windowbg" align="center">
	<img src="$imagesdir/off.gif" alt="" />
	</td><td width="94%" class="windowbg2" align="left">
	<b>Installed: </b><br />
	$var_created
	</td></tr>
			~;
		}
	}

	$yymain .= qq~
	<tr><td width="100%" class="catbg" colspan="2" align="left">
	~;

	if ($set_missing) {
		$install_error = 1;
		$yymain .= qq~
	A problem has occurred while creating Settings.pl!
	</td></tr>
		~;
	}
	if ($set_created) {
		$yymain .= qq~
	Successfully checked Settings.pl!
	</td></tr>
	<tr><td width="6%" class="windowbg" align="center">
	<img src="$imagesdir/off.gif" alt="" />
	</td><td width="94%" class="windowbg2" align="left">
	Click on 'Continue' and go to your <i>Admin Center - Forum Settings</i> to set the options for your YaBB 2.<br />
	Click on 'Convert' to convert your YaBB 1 Gold - SP 1.x forum to YaBB 2.
	</td></tr>
		~;
	}

	if (!$install_error) {

		$yymain .= qq~
	<tr><td width="100%" class="catbg" colspan="2" align="center">
	<form action="$set_cgi?action=ready;nextstep=YaBB" method="post" style="display: inline;">
		<input type="submit" value="Continue" />
	</form>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<form action="$set_cgi?action=ready;convert=1;nextstep=Setup" method="post" style="display: inline;">
		<input type="submit" value="Convert" />
	</form>
	</td></tr>
		~;
	} else {
		$yymain .= qq~
	<tr><td width="100%" class="catbg" colspan="2" align="left">
	<div style="float: left; width: 98%; font-family: verdana; color: #900000; font-size: 11px; padding: 2px;"><b>One or more errors occurred while checking the system files. The problems must be solved before you may continue.</b></div>
	</td></tr>
		~;
	}
	$yymain .= qq~
	</table>
</div>
	~;
	$yyim    = "You are running YaBB 2 Setup.";
	$yytitle = "YaBB 2 Setup";
	&SetupTemplate;
}

sub ready {
	if ($INFO{'nextstep'} eq 'Setup') { $yySetLocation = qq~$INFO{'nextstep'}.$yyext?convert=1~; }
	elsif (-e "$INFO{'nextstep'}.$yyext") { $yySetLocation = qq~$INFO{'nextstep'}.$yyext?action=revalidatesession~; }

	&CreateSetupLock;
	&delete_DBorFILE("$vardir/cook.txt");
	&redirectexit;
}

sub CreateConvLock {
	fopen("LOCKFILE", ">$vardir/Converter.lock") || &setup_fatal_error("$maintext_23 $vardir/Converter.lock: ", 1);
	print LOCKFILE q~This is a lockfile for the Converter.\n~;
	print LOCKFILE q~It prevents it being run again after it has been run once.\n~;
	print LOCKFILE q~Delete this file if you want to run the Converter again.~;
	fclose("LOCKFILE");

	&delete_DBorFILE("$vardir/ConvSettings.txt");
}

sub CreateSetupLock {
	fopen("LOCKFILE", ">$vardir/Setup.lock") || &setup_fatal_error("$maintext_23 $vardir/Setup.lock: ", 1);
	print LOCKFILE q~This is a lockfile for the Setup Utility.\n~;
	print LOCKFILE q~It prevents it being run again after it has been run once.\n~;
	print LOCKFILE q~Delete this file if you want to run the Setup Utility again.~;
	fclose("LOCKFILE");
}

sub SetupImgLoc {
	if (!-e "$forumstylesdir/$useimages/$_[0]") { $thisimgloc = qq~img src="$forumstylesurl/default/$_[0]"~; }
	else { $thisimgloc = qq~img src="$imagesdir/$_[0]"~; }
	return $thisimgloc;
}

sub tabmenushow { # used by the converter
	if (-e "$vardir/Setup.lock") {
		$tabsep = qq~<img src="$imagesdir/tabsep211.png" border="0" alt="" style="float: left; vertical-align: middle;" />~;
		$tabfill = qq~<img src="$imagesdir/tabfill.gif" border="0" alt="" style="vertical-align: middle;" />~;

		$NavLink1 = qq~<span>$tabfill Members $tabfill</span>~;
		$NavLink2 = qq~$tabsep<span>$tabfill Boards & Categories $tabfill</span>~;
		$NavLink3 = qq~$tabsep<span>$tabfill Messages $tabfill</span>~;
		$NavLink4 = qq~$tabsep<span>$tabfill Date & Time $tabfill</span>~;
		$NavLink5 = qq~$tabsep<span>$tabfill Clean Up $tabfill</span>~;
		$NavLink6 = qq~$tabsep<span>$tabfill Login $tabfill</span>$tabsep&nbsp;~;

		$NavLink1a = qq~<span class="selected"><a href="$set_cgi?action=members;st=$INFO{'st'}" style="color: #FF3333;" class="selected" onClick="PleaseWait();">$tabfill Members $tabfill</a></span>~;
		$NavLink2a = qq~$tabsep<span class="selected"><a href="$set_cgi?action=cats;st=$INFO{'st'}" style="color: #FF3333;" class="selected" onClick="PleaseWait();">$tabfill Boards & Categories $tabfill</a></span>~;
		$NavLink3a = qq~$tabsep<span class="selected"><a href="$set_cgi?action=messages;st=$INFO{'st'}" style="color: #FF3333;" class="selected" onClick="PleaseWait();">$tabfill Messages $tabfill</a></span>~;
		$NavLink4a = qq~$tabsep<span class="selected"><a href="$set_cgi?action=dates;st=$INFO{'st'}" style="color: #FF3333;" class="selected" onClick="PleaseWait();">$tabfill Date & Time $tabfill</a></span>~;
		$NavLink5a = qq~$tabsep<span class="selected"><a href="$set_cgi?action=cleanup;st=$INFO{'st'}" style="color: #FF3333;" class="selected" onClick="PleaseWait();">$tabfill Clean Up $tabfill</a></span>~;
		$NavLink6a = qq~$tabsep<span class="selected"><a href="$boardurl/YaBB.$yyext?action=login" style="color: #FF3333;" class="selected">$tabfill Login $tabfill</a></span>$tabsep&nbsp;~;

		$ConvDone = qq~
		<div style="float: left; width: 102px; height: 10px; margin: 1px; background-color: #6699cc; border: 1px black solid; font-size: 5px;">&nbsp;</div>
		<div style="float: left; width: 50px; height: 14px; text-align: right; color: #FF3333;">100 %</div><br />
		~;

		$ConvNotDone = qq~
		<div style="float: left; width: 102px; height: 10px; margin: 1px; background-color: #dddddd; border: 1px black solid; font-size: 5px;">&nbsp;</div>
		<div style="float: left; width: 50px; height: 14px; text-align: right; color: #bbbbbb;">0 %</div><br />
		~;
	}
}

sub FoundConvLock {
	&tempstarter;
	&tabmenushow;

	$yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink4 . $NavLink5 . $NavLink6;

	$formsession = &cloak("$mbname$username");

	$yymain = qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
	<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td width="100%" colspan="2" class="titlebg" align="left">
		YaBB 2 Converter
		</td>
	</tr>
	<tr valign="middle">
		<td width="5%" class="windowbg" align="center">
		<img src="$imagesdir/info.gif" alt="" />
		</td>
		<td width="95%" class="windowbg2" align="left" style="font-size: 11px;">
		Setup and Converter has already been run, attempting to run them again will cause damage to your files.<br />
		<br />
		To run Setup again, remove the file "$vardir/Setup.lock" then re-visit this page.<br />
		To run Converter again, remove the file "$vardir/Converter.lock," then re-visit this page.
		</td>
	</tr>
	<tr>
		<td width="100%" class="catbg" colspan="2" align="center">
		<form action="$boardurl/YaBB.$yyext" method="post" style="display: inline;">
			<input type="submit" value="Go to your Forum" />
			<input type="hidden" name="formsession" value="$formsession" />
		</form>
		</td>
	</tr>
	</table>
</div>
	~;

	$yyim    = "YaBB 2 Setup and Converter has already been run.";
	$yytitle = "YaBB 2 Setup/Converter";
	&SetupTemplate;
}

sub setup_fatal_error {
	my $e = $_[0];
	my $v = $_[1];
	$e .= "\n";
	if ($v) { $e .= $! . "\n"; }

	$yymenu = qq~Boards & Categories | ~;
	$yymenu .= qq~Members | ~;
	$yymenu .= qq~Messages | ~;
	$yymenu .= qq~Date & Time | ~;
	$yymenu .= qq~Clean Up | ~;
	$yymenu .= qq~Login~;

	$yymain .= qq~
<table border="0" width="80%" cellspacing="1" class="bordercolor" align="center" cellpadding="4">
  <tr>
    <td class="titlebg"><span class="text1"><b>An Error Has Occurred!</b></span></td>
  </tr><tr>
    <td class="windowbg"><br /><span class="text1">$e</span><br /><br /></td>
  </tr>
</table>
<center><br /><a href="javascript:history.go(-1)">Back</a></center>
	~;
	$yyim    = "YaBB 2 Convertor Error.";
	$yytitle = "YaBB 2 Convertor Error.";

	&SimpleOutput if !-e "$vardir/Settings.pl";

	&tempstarter;
	&SetupTemplate;
}

sub SimpleOutput {
	$gzcomp = 0;
	&print_output_header;

	print qq~
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>YaBB 2 Setup</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
</head>
<body>

<!-- Main Content -->
<div style="height: 40px;">&nbsp;</div>
<center>$yymain</center>
</body>
</html>
	~;
	exit;
}

sub SetupTemplate {
	$gzcomp = fileno GZIP ? 1 : 0;
	&print_output_header;

	$yyposition = $yytitle;
	$yytitle = "$mbname - $yytitle";

	$yyimages = $imagesdir;
	$yydefaultimages = $defaultimagesdir;
	$yystyle = qq~<link rel="stylesheet" href="$forumstylesurl/$usestyle.css" type="text/css" />~;
	$yystyle =~ s~$usestyle\/~~g;

	$yytemplate = "$templatesdir/$usehead/$usehead.html";
	fopen(TEMPLATE, "$yytemplate") || &setup_fatal_error("$maintext_23 $yytemplate: ", 1);
	@yytemplate = <TEMPLATE>;
	fclose(TEMPLATE);

	my $output = '';
	$yyboardname = $mbname;
	$yytime = &timeformat($date, 1);
	$yyuname = $iamguest ? '' : qq~$maintxt{'247'} ${$uid.$username}{'realname'}, ~;

	if ($enable_news) {
		fopen(NEWS, "$vardir/news.txt");
		@newsmessages = <NEWS>;
		fclose(NEWS);
	}
	for (my $i = 0; $i < @yytemplate; $i++) {
		$curline = $yytemplate[$i];
		if (!$yycopyin && ($curline =~ m~<yabb copyright>~ || $curline =~ /{yabb copyright}/)) { $yycopyin = 1; }
		if ($curline =~ m~<yabb newstitle>~ && $enable_news) {
			$yynewstitle = qq~<b>$maintxt{'102'}:</b> ~;
		}
		if ($curline =~ m~<yabb news>~ && $enable_news) {
			srand;
			if ($shownewsfader == 1) {

				$fadedelay = ($maxsteps * $stepdelay);
				$yynews .= qq~
				<script language="JavaScript1.2" type="text/javascript">
					<!--
						var maxsteps = "$maxsteps";
						var stepdelay = "$stepdelay";
						var fadelinks = $fadelinks;
						var delay = "$fadedelay";
						var bcolor = "$color{'faderbg'}";
						var tcolor = "$color{'fadertext'}";
						var fcontent = new Array();
						var begintag = "";
				~;
				fopen(NEWS, "$vardir/news.txt");
				@newsmessages = <NEWS>;
				fclose(NEWS);
				for (my $j = 0; $j < @newsmessages; $j++) {
					$newsmessages[$j] =~ s/\n|\r//g;
					if ($newsmessages[$j] eq '') { next; }
					if ($i != 0) { $yymain .= qq~\n~; }
					$message = $newsmessages[$j];
					if ($enable_ubbc) {
						if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
						&DoUBBC;
					}
					$message =~ s/"/\\"/g;
					$yynews .= qq~
						fcontent[$j] = "$message";\n
					~;
				}
				$yynews .= qq~
						var closetag = '';
					// -->
				</script>
				~;
			} else {
				$message = $newsmessages[int rand(@newsmessages)];
				if ($enable_ubbc) {
					if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
					&DoUBBC;
				}
				$yynews = $message;
			}
		}
		$yyurl = $scripturl;
		$curline =~ s~{yabb\s+(\w+)}~${"yy$1"}~g;
		$curline =~ s~<yabb\s+(\w+)>~${"yy$1"}~g;
		$curline =~ s~img src\=\"$imagesdir\/(.+?)\"~&SetupImgLoc($1)~eisg;
		$output .= $curline;
	}
	if ($yycopyin == 0) {
		$output = q~<center><h1><b>Sorry, the copyright tag <yabb copyright> must be in the template.<br />Please notify this forum's administrator that this site is using an ILLEGAL copy of YaBB!</b></h1></center>~;
	}
	if (fileno GZIP) {
		$| = 1;
		print GZIP $output;
		close(GZIP);
	} else {
		print $output;
	}
	exit;
}

sub nicely_aligned_file {
	my $filler = ' ' x 50; # Make files look nicely aligned. The comment starts after 50 Col

	my $setfile = shift;
	$setfile =~ s~(.+;)[ \t]+(#.+$)~ $1 . substr($filler,(length $1 < 50 ? length $1 : 49)) . $2 ~gem;
	$setfile =~ s~\t+(#.+$)~$filler$1~gm;
	$setfile =~ s~(.+)(#.+$)~ $1 . &cut_comment($1,$2) ~gem;
	$setfile;

	sub cut_comment { # line brake of too long comments
		my ($comment,$length) = ('',120); # 120 Col is the max width of page
		my $var_length = length($_[0]);
		while ($length < $var_length) { $length += 120; }
		foreach (split(/ +/, $_[1])) {
			if (($var_length + length($comment) + length($_)) > $length) {
				$comment =~ s/ $//;
				$comment .= "\n$filler#  $_ ";
				$length += 120;
			} else { $comment .= "$_ "; }
		}
		$comment =~ s/ $//;
		$comment; 
	}
}

1;