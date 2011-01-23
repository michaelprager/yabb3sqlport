#!/usr/bin/perl --

###############################################################################
# AdminIndex.pl                                                               #
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
$adminindexplver = 'YaBB 3.0 Beta $Revision: 100 $';

# use CGI::Carp qw(fatalsToBrowser); # used only for tests

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

$adminscreen = 1;

# modify the following line if your forum main scriptname is different
# from the default: "YaBB".
$yyexec = "YaBB";
$script_root = $ENV{'SCRIPT_FILENAME'};
$script_root =~ s/\/AdminIndex\.(pl|cgi)//ig;

require "Paths.pl";
require "$vardir/Settings.pl";

# Check allways for Time::HiRes
eval { require Time::HiRes; import Time::HiRes qw(time); };
$START_TIME = time();

if ($settings_file_version ne $YaBBversion) { # If upgrading
	require "$vardir/advsettings.txt" if -e "$vardir/advsettings.txt";
	require "$vardir/secsettings.txt" if -e "$vardir/secsettings.txt";
	require "$vardir/membergroups.txt" if -e "$vardir/membergroups.txt";
}

require "$sourcedir/Subs.pl";
require "$sourcedir/System.pl";
require "$sourcedir/DateTime.pl";
require "$sourcedir/Load.pl";

&LoadCookie;       # Load the user's cookie (or set to guest)
&LoadUserSettings; # Load user settings
&WriteLog;         # write into the logfile
&WhatTemplate;     # Figure out which template to be using.
&WhatLanguage;     # Figure out which language file we should be using!

if ($debug) { require "$sourcedir/Debug.pl"; }
if ($referersecurity) { &referer_check; } # Check if the action is allowed from an external domain

require "$sourcedir/Security.pl";
&banning;          # Check for banned people

$maintenance = 2 if !$maintenance && -e "$vardir/maintenance.lock";

# some maintenance stuff will stop after $max_process_time
# in seconds, than the browser will call the script again
# until all is done. Don't put it too high or you will run
# into server or browser timeout.
$max_process_time = 20;

$action = $INFO{'action'};
$SIG{__WARN__} = sub { &fatal_error("error_occurred","@_"); };
eval { &yymain; };
if ($@) { &fatal_error("untrapped",":<br />$@"); }

sub yymain {
	# Choose what to do based on the form action
	if ($maintenance && $action eq 'login2') { require "$sourcedir/LogInOut.pl"; &Login2; }

	# Do Sessions Checking
	if (!$iamguest && $sessions == 1 && $sessionvalid != 1) {
		$yySetLocation = qq~$scripturl?action=revalidatesession~;
		&redirectexit;
	}

	# Other users can do nothing here.
	if (!$iamadmin && !$iamgmod) {
		if ($maintenance) { require "$sourcedir/LogInOut.pl"; &InMaintenance; }
		$yySetLocation = qq~$scripturl~;
		&redirectexit;
	}

	if ($iamgmod) {
		require "$vardir/gmodsettings.txt";
		if (!$allow_gmod_admin) {
			$yySetLocation = qq~$scripturl~;
			&redirectexit;
		}
	}

	if ($action ne "") {
		if ($action eq $randaction) {
			require "$sourcedir/Decoder.pl"; &convert;
		} else {
			require "$admindir/AdminSubList.pl";
			if ($director{$action}) {
				my @act = split(/&/, $director{$action});
				if ($action =~ /^ext_/) {
					require "$sourcedir/$act[0]";
				} else {
					require "$admindir/$act[0]";
				}
				&{$act[1]};
			} else {
				require "$admindir/Admin.pl";
				&Admin;
			}
		}
	} else {
		&TrackAdminLogins;
		require "$admindir/Admin.pl";
		&Admin;
	}
}

sub ParseNavArray {
	foreach $element (@_) {

		chomp $element;
		($action_to_take, $vistext, $whatitdoes, $isheader) = split(/\|/, $element);

		if ($action_area eq $action_to_take) {
			$currentclass = "class=\"current\"";
		} else {
			$currentclass = "";
		}

		if ($isheader) {
			$started_ul = 1;
			$leftmenu .= qq~		<h3><a href="javascript:toggleList('$isheader')" title="$whatitdoes">$vistext</a></h3>
		  <ul id="$isheader">
~;
			next;
		}

		if ($iamgmod && $gmod_access{$action_to_take} ne "on") {
			next;
		}

		if ($action_to_take ne "#") {
			$leftmenu .= qq~
			<li><a href="$adminurl?action=$action_to_take" title="$whatitdoes" $currentclass>$vistext</a></li>~;
		} else {
			$leftmenu .= qq~
			<li><a name="none" title="none">$vistext</a></li>~;
		}
	}

	if ($started_ul) {
		$leftmenu .= qq~
		  </ul>
~;
	}
}

sub AdmImgLoc {
	if (!-e "$forumstylesdir/$useimages/$_[0]") { $thisimgloc = qq~img src="$forumstylesurl/default/$_[0]"~; }
	else { $thisimgloc = qq~img src="$imagesdir/$_[0]"~; }
	return $thisimgloc;
}

sub AdmImgLoc2 {
	if (!-e "$forumstylesdir/$useimages/$_[0]") { $thisimgloc = qq~$forumstylesurl/default/$_[0]~; }
	else { $thisimgloc = qq~$imagesdir/$_[0]~; }
	return $thisimgloc;
}

sub AdminTemplate {
	$admin_template = ${ $uid . $username }{'template'};
	if (!-d "$adminstylesdir/$admin_template" || $admin_template eq "") { $admin_template = "default"; }

	$adminstyle = qq~<link rel="stylesheet" href="$adminstylesurl/$admin_template.css" type="text/css" />~;
	$adminstyle =~ s~$admin_template\/~~g;

	$adminimages = qq~$adminstylesurl/$admin_template~;
	$adminimages =~ s~$admin_template\/~~g;
	require "$templatesdir/$admin_template/AdminCentre.template";
	require "$vardir/gmodsettings.txt";

	@forum_settings = (
	"|$admintxt{'a1_title'}|$admintxt{'a1_label'} - $admintxt{'34'}|a1",
	"newsettings;page=main|$admintxt{'a1_sub1'}|$admintxt{'a1_label1'}|",
	"newsettings;page=advanced|$admintxt{'a1_sub2'}|$admintxt{'a1_label2'}|",
	"database|$admintxt{'a1_sub2a'}|$admintxt{'a1_label2a'}|",
	"editpaths|$admintxt{'a1_sub3'}|$admintxt{'a1_label3'}|",
	"editbots|$admintxt{'a1_sub4'}|$admintxt{'a1_label4'}|",
	);
	if ($extendedprofiles) {
		splice(@forum_settings,3,0,"ext_admin|$admintxt{'a1_sub_ex'}|$admintxt{'a1_label_ex'}|")
	}

	@general_controls = (
	"|$admintxt{'a2_title'}|$admintxt{'a2_label'} - $admintxt{'34'}|a2",
	"newsettings;page=news|$admintxt{'a2_sub1'}|$admintxt{'a2_label1'}|",
	"smilies|$admintxt{'a2_sub2'}|$admintxt{'a2_label2'}|",
	"setcensor|$admintxt{'a2_sub3'}|$admintxt{'a2_label3'}|",
	"modagreement|$admintxt{'a2_sub4'}|$admintxt{'a2_label4'}|",
	"gmodaccess|$admintxt{'a2_sub5'}|$admintxt{'a2_label5'}|",
	"eventcal_set|$admintxt{'a2_sub6'}|$admintxt{'a2_label6'}|"
	);

	@security_settings = (
	"|$admintxt{'a3_title'}|$admintxt{'a3_label'} - $admintxt{'34'}|a3",
	"newsettings;page=security|$admintxt{'a3_sub2'}|$admintxt{'a3_label2'}|",
	"referer_control|$admintxt{'a3_sub1'}|$admintxt{'a3_label1'}|",
	"setup_guardian|$admintxt{'a3_sub3'}|$admintxt{'a3_label3'}|",
	"newsettings;page=antispam|$admintxt{'a3_sub4'}|$admintxt{'a3_label4'}|",
	);

	@forum_controls = (
	"|$admintxt{'a4_title'}|$admintxt{'a4_label'} - $admintxt{'34'}|a4",
	"managecats|$admintxt{'a4_sub1'}|$admintxt{'a4_label1'}|",
	"manageboards|$admintxt{'a4_sub2'}|$admintxt{'a4_label2'}|",
	"helpadmin|$admintxt{'a4_sub3'}|$admintxt{'a4_label3'}|",
	"editemailtemplates|$admintxt{'a4_sub4'}|$admintxt{'a4_label4'}|",
	);

	@forum_layout = (
	"|$admintxt{'a5_title'}|$admintxt{'a5_label'} - $admintxt{'34'}|a5",
	"modskin|$admintxt{'a5_sub1'}|$admintxt{'a5_label1'}|",
	"modcss|$admintxt{'a5_sub2'}|$admintxt{'a5_label2'}|",
	"modtemp|$admintxt{'a5_sub3'}|$admintxt{'a5_label3'}|",
	);

	@member_controls = (
	"|$admintxt{'a6_title'}|$admintxt{'a6_label'} - $admintxt{'34'}|a6",
	"addmember|$admintxt{'a6_sub1'}|$admintxt{'a6_label1'}|",
	"viewmembers|$admintxt{'a6_sub2'}|$admintxt{'a6_label2'}|",
	"modmemgr|$admintxt{'a6_sub3'}|$admintxt{'a6_label3'}|",
	"mailing|$admintxt{'a6_sub4'}|$admintxt{'a6_label4'}|",
	"ipban|$admintxt{'a6_sub5'}|$admintxt{'a6_label5'}|",
	"setreserve|$admintxt{'a6_sub6'}|$admintxt{'a6_label6'}|",
	);

	@maintence_controls = (
	"|$admintxt{'a7_title'}|$admintxt{'a7_label'} - $admintxt{'34'}|a7",
	"newsettings;page=maintenance|$admin_txt{'67'}|$admin_txt{'67'}|",
	"rebuildmesindex|$admintxt{'a7_sub2a'}|$admintxt{'a7_label2a'}|",
	"boardrecount|$admintxt{'a7_sub2'}|$admintxt{'a7_label2'}|",
	"rebuildmemlist|$admintxt{'a7_sub4'}|$admintxt{'a7_label4'}|",
	"rebuildmemhist|$admintxt{'a7_sub4a'}|$admintxt{'a7_label4a'}|",
	"rebuildnotifications|$admintxt{'a7_sub4b'}|$admintxt{'a7_label4b'}|",
	"clean_log|$admintxt{'a7_sub1'}|$admintxt{'a7_label1'}|",
	"deleteoldthreads|$admintxt{'a7_sub5'}|$admintxt{'a7_label5'}|",
	"manageattachments|$admintxt{'a7_sub6'}|$admintxt{'a7_label6'}|",
	"backupsettings|$admintxt{'a3_sub5'}|$admintxt{'a3_label5'}|",
	);

	@forum_stats = (
	"|$admintxt{'a8_title'}|$admintxt{'a8_label'} - $admintxt{'34'}|a8",
	"detailedversion|$admintxt{'a8_sub1'}|$admintxt{'a8_label1'}|",
	"stats|$admintxt{'a8_sub2'}|$admintxt{'a8_label2'}|",
	"showclicks|$admintxt{'a8_sub3'}|$admintxt{'a8_label3'}|",
	"errorlog|$admintxt{'a8_sub4'}|$admintxt{'a8_label4'}|",
	"view_reglog|$admintxt{'a8_sub5'}|$admintxt{'a8_label5'}|",
	);

	@boardmod_mods = (
	"|$admintxt{'a9_title'}|$admintxt{'a9_label'} - $admintxt{'34'}|a9",
	"modlist|$mod_list{'6'}|$mod_list{'7'}|",
	);

	# To add new items for your mods settings, add a new row below here, pushing
	# your item onto the @boardmod_mods array. Example below:
	# 	$my_mod = "action_to_take|Name_Displayed|Tooltip_Title|";
	#	push (@boardmod_mods, "$my_mod");
	# before the first pipe character is the action that will appear in the URL
	# Next is the text that is displayed in the admin centre
	# Finally, you have the tooltip text, necessary for XHTML compliance

	# Also note, you should pick a unique name instead of "$my_mod".
	# If you mod is called "SuperMod For Doing Cool Things"
	# You could use "$SuperMod_CoolThings"

### BOARDMOD ANCHOR ###

### END BOARDMOD ANCHOR ###

	&ParseNavArray(@forum_settings);
	&ParseNavArray(@general_controls);
	&ParseNavArray(@security_settings);
	&ParseNavArray(@forum_controls);
	&ParseNavArray(@forum_layout);
	&ParseNavArray(@member_controls);
	&ParseNavArray(@maintence_controls);
	&ParseNavArray(@forum_stats);
	&ParseNavArray(@boardmod_mods);

	$topmenu_one  = qq~<a href="$boardurl/$yyexec.$yyext">$admintxt{'15'}</a>~;
	$topmenu_two  = qq~<a href="$adminurl">$admintxt{'33'}</a>~;
	$topmenu_tree = qq~<a href="$scripturl?action=help;section=admin">$admintxt{'35'}</a>~;
	$topmenu_four = qq~<a href="http://www.yabbforum.com">$admintxt{'36'}</a>~;

	if ($maintenance) {
		$yyadmin_alert .= qq~<br /><span style="font-size: 12px; background-color: #FFFF33;"><b>$load_txt{'616'}</b></span><br /><br />~;
	}
	if ($iamadmin && $rememberbackup) {
		if ($lastbackup && $date > $rememberbackup + $lastbackup) {
			require "$sourcedir/DateTime.pl";
			$yyadmin_alert .= qq~<br /><span style="font-size: 12px; background-color: #FFFF33;"><b>$load_txt{'617'} ~ . &timeformat($lastbackup) . qq~</b></span>~;
		}
	}

	&print_output_header;

	my $yytitle = qq~$admin_txt{'208'}: $yytitle~;
	$header =~ s/({|<)yabb title(}|>)/$yytitle/g;
	$header =~ s/({|<)yabb style(}|>)/$adminstyle/g;
	$header =~ s/({|<)yabb charset(}|>)/$yycharset/g;
	$header =~ s/({|<)yabb javascript(}|>)/$yyjavascript/g;	

	$leftmenutop =~ s/({|<)yabb images(}|>)/$adminimages/g;
	$leftmenutop =~ s/({|<)yabb maintenance(}|>)/$yyadmin_alert/g;
	$topnav      =~ s/({|<)yabb topmenu_one(}|>)/$topmenu_one/;
	$topnav      =~ s/({|<)yabb topmenu_two(}|>)/$topmenu_two/;
	$topnav      =~ s/({|<)yabb topmenu_tree(}|>)/$topmenu_tree/;
	$topnav      =~ s/({|<)yabb topmenu_four(}|>)/$topmenu_four/;

	&Debug if $debug;
	$mainbody =~ s/({|<)yabb main(}|>)/$yymain/g;
	$mainbody =~ s/({|<)yabb_admin debug(}|>)/$yydebug/g;

	$mainbody =~ s~img src\=\"$imagesdir\/(.+?)\"~&AdmImgLoc($1)~eisg;
	$mainbody =~ s~img src\=\&quot\;$imagesdir\/(.+?)\&quot;~"img src\=\&quot;" . &AdmImgLoc2($1) . "\&quot;"~eisg; # For the template editing Javascript images

	$output = $header . $leftmenutop . $leftmenu . $leftmenubottom . $topnav . $mainbody;

	&print_HTML_output_and_finish;
}

sub TrackAdminLogins {
	@adminlog = &read_DBorFILE(0,ADMINLOG,$vardir,'adminlog','txt');
	print ADMINLOG qq~$username|$user_ip|$date\n~;
	for ($i = 0; $i < 4; $i++) {
		if ($adminlog[$i]) {
			chomp $adminlog[$i];
			print ADMINLOG qq~$adminlog[$i]\n~;
		}
	}
	&write_DBorFILE(0,ADMINLOG,$vardir,'adminlog','txt',(''));
}