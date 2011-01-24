#!/usr/bin/perl --

###############################################################################
# FixFile.pl                                                                  #
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
# Sponsored by: Xnull Internet Media, Inc. - http://www.ximinc.com            #
#               Your source for web hosting, web design, and domains.         #
###############################################################################

if ($ENV{'SERVER_SOFTWARE'} =~ /IIS/) {
	$yyIIS = 1;
	$0 =~ m~(.*)(\\|/)~;
	$yypath = $1;
	$yypath =~ s~\\~/~g;
	chdir($yypath);
	push(@INC, $yypath);
}

$script_root = $ENV{'SCRIPT_FILENAME'};
$script_root =~ s/\/Setup\.(pl|cgi)//ig;

if (-e "./Paths.pl") { require "./Paths.pl"; }
elsif (-e "./Variables/Paths.pl") { require "./Variables/Paths.pl"; }
else {
	$boardsdir = "./Boards";
	$sourcedir = "./Sources";
	$memberdir = "./Members";
	$vardir = "./Variables";
}

$thisscript = "$ENV{'SCRIPT_NAME'}";
if (-e ("YaBB.cgi")) { $yyext = 'cgi'; }
else { $yyext = 'pl'; }
if ($boardurl) { $set_cgi = "$boardurl/FixFile.$yyext"; }
else { $set_cgi = "FixFile.$yyext"; }

# Make sure the module path is present
push(@INC, "./Modules");

require "$sourcedir/Subs.pl";
require "$sourcedir/System.pl";
require "$sourcedir/Load.pl";
require "$sourcedir/DateTime.pl";
require "$admindir/Admin.pl";

$yytabmenu = '';
$yymenu = '';
$yymain = '';

if (!$action) {
	&tempstarter;
	$yytabmenu = qq~$tabsep<span onclick="location.href='$set_cgi?action=members2';"><a href="$set_cgi?action=members2" title="Update file structure">$tabfill Update file structure $tabfill</a></span>$tabsep~;
	$yyim = 'Update file structure';
	$yytitle = 'YaBB 3 Beta';
	&FixFileTemplate;
}

if ($action eq 'members2') {
	&tempstarter;
	&FixNopost;
	$yytabmenu = qq~$tabsep<span onclick="location.href='$scripturl?action=login';"><a href="$scripturl?action=login" title="$img_txt{'34'}">$tabfill$img_txt{'34'}$tabfill</a></span>$tabsep~;
	$yyim = 'File structure updated!';
	$yytitle = 'YaBB 3 Beta';
	&FixFileTemplate;
}

sub FixNopost {
	if ($NoPost[0]) {
		$i = 0;
		$z = 1;

		fopen(FORUMCONTROL, "$boardsdir/forum.control");
		@boardcontrols = <FORUMCONTROL>;
		fclose(FORUMCONTROL);

		while ($NoPost[$i]) {
			($grptitle, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $NoPost[$i]);
			$grptitle =~ s~\'~&#39;~g;
			while (exists $NoPost{$z}) { $z++; }
			foreach my $key (keys %catinfo) {
				($catname, $catperms, $catcol) = split(/\|/, $catinfo{$key});
				@allperms = split(/\, /, $catperms);
				$newperm = "";
				foreach $theperm (@allperms) {
					if ($theperm eq $grptitle) { $theperm = $z; }
					$newperm .= qq~$theperm, ~;
				}
				$newperm =~ s/, \Z//;
				$catinfo{$key} = qq~$catname|$newperm|$catcol~;
			}
			foreach my $key (keys %board) {
				($boardname, $boardperms, $boardshow) = split(/\|/, $board{$key});
				@allperms = split(/, /, $boardperms);
				$newperm = "";
				foreach $theperm (@allperms) {
					if ($theperm eq $grptitle) { $theperm = $z; }
					$newperm .= qq~$theperm, ~;
				}
				$newperm =~ s/, \Z//;
				$board{$key} = qq~$boardname|$newperm|$boardshow~;
			}
			for ($j = 0; $j < @boardcontrols; $j++) {
				chomp $boardcontrols[$j];
				($cntcat, $cntboard, $cntpic, $cntdescription, $cntmods, $cntmodgroups, $cnttopicperms, $cntreplyperms, $cntpollperms, $cntzero, $cntmembergroups, $cntann, $cntrbin, $cntattperms, $cntminageperms, $cntmaxageperms, $cntgenderperms) = split(/\|/, $boardcontrols[$j]);
				@allmodgroups = split(/, /, $cntmodgroups);
				$newmodgroups = "";
				foreach my $theperm (@allmodgroups) {
					if ($theperm eq $grptitle) { $theperm = $z; }
					$newmodgroups .= qq~$theperm, ~;
				}
				$newmodgroups =~ s/, \Z//;
				@alltopicperms = split(/, /, $cnttopicperms);
				$newtopicperms = "";
				foreach my $theperm (@alltopicperms) {
					if ($theperm eq $grptitle) { $theperm = $z; }
					$newtopicperms .= qq~$theperm, ~;
				}
				$newtopicperms =~ s/, \Z//;
				@allreplyperms = split(/, /, $cntreplyperms);
				$newreplyperms = "";
				foreach my $theperm (@allreplyperms) {
					if ($theperm eq $grptitle) { $theperm = $z; }
					$newreplyperms .= qq~$theperm, ~;
				}
				$newreplyperms =~ s/, \Z//;
				@allpollperms = split(/, /, $cntpollperms);
				$newpollperms = "";
				foreach my $theperm (@allpollperms) {
					if ($theperm eq $grptitle) { $theperm = $z; }
					$newpollperms .= qq~$theperm, ~;
				}
				$newpollperms =~ s/, \Z//;
				$boardcontrols[$j] = qq~$cntcat|$cntboard|$cntpic|$cntdescription|$cntmods|$newmodgroups|$newtopicperms|$newreplyperms|$newpollperms|$cntzero|$cntmembergroups|$cntann|$cntrbin|$cntattperms|$cntminageperms|$cntmaxageperms|$cntgenderperms\n~;
			}
			$NoPost{$z} = "$grptitle|$stars|$starpic|$color|$noshow|$viewperms|$topicperms|$replyperms|$pollperms|$attachperms";
			$z++;
			$i++;
		}
		&Write_ForumMaster;
		fopen(FORUMCONTROL, ">$boardsdir/forum.control");
		print FORUMCONTROL @boardcontrols;
		fclose(FORUMCONTROL);
	}
	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl'); # save %Group, %NoPost, %Post and &delete_DBorFILE("$vardir/membergroups.txt")

	opendir(MEMBERS, $memberdir) || die "Unable to open ($memberdir) :: $!";
	@contents = grep { /\.vars$/ } readdir(MEMBERS);
	closedir(MEMBERS);
	&ManageMemberinfo("load");
	foreach $member (@contents) {
		$member =~ s/\.vars$//g;
		if ($member) {
			$newaddigrp  = "";
			$actposition = "";
			&LoadUser($member);
			if (${$uid.$member}{'position'}) {
				$actposition = ${$uid.$member}{'position'};
				chomp $actposition;
				foreach my $key (keys %NoPost) {
					($NoPostname, undef) = split(/\|/, $NoPost{$key});
					if ($actposition eq $NoPostname) { $actposition = $key; }
				}
			}
			if (${$uid.$member}{'addgroups'}) {
				foreach $addigrp (split(/, ?/, ${$uid.$member}{'addgroups'})) {
					foreach my $key (keys %NoPost) {
						($NoPostname, undef) = split(/\|/, $NoPost{$key});
						if ($addigrp eq $NoPostname) { $addigrp = $key; }
					}
					$newaddigrp .= qq~$addigrp,~;
				}
				$newaddigrp =~ s/,$//;
			}
			if ($newaddigrp || $actposition) {
				${$uid.$member }{'position'}  = $actposition;
				${$uid.$member }{'addgroups'} = $newaddigrp;
				&UserAccount($member, "update");
			}
			$formatregdate = sprintf("%010d", &stringtotime(${$uid.$member}{'regdate'}));
			if (!$actposition) { $actposition = &MemberPostGroup(${$uid.$member}{'postcount'}); }
			$memberinf{$member}  = qq~$formatregdate|${$uid.$member}{'realname'}|${$uid.$member}{'email'}|$actposition|${$uid.$member}{'postcount'}|$newaddigrp|${$uid.$member}{'bday'}~;
			undef %{$uid.$member};
			$regcounter++;
		}
	}
	&ManageMemberinfo("save");

	require "$sourcedir/Notify.pl";
	&getMailFiles; # to get @bmaildir and @tmaildir

	my ($boardfile, $threadfile, @allboards, @allthreads);
	foreach $boardfile (@bmaildir) {
		chomp $boardfile;
		fopen(FILE, "$boardsdir/$boardfile.mail");
		@allboardnot = <FILE>;
		fclose(FILE);
		fopen(FILE, ">$boardsdir/$boardfile.mail", 1);
		foreach $bline (@allboardnot) {
			chomp $bline;
			if ($bline !~ /\t/) {
				($bheuser, undef, $bhelang, $bhetype) = split(/\|/, $bline, 4);
				if (!$bhelang) { $bhelang = $lang; }
				print FILE "$bheuser\t$bhelang|$bhetype|1\n";
			} else {
				print FILE "$bline\n";
			}
		}
		fclose(FILE);
		if (!-s "$boardsdir/$boardfile.mail") { &delete_DBorFILE("$boardsdir/$boardfile.mail"); }
	}
	foreach $threadfile (@tmaildir) {
		chomp $threadfile;
		fopen(FILE, "$datadir/$threadfile.mail");
		@allthreadsnot = <FILE>;
		fclose(FILE);
		fopen(FILE, ">$datadir/$threadfile.mail", 1);
		foreach $tline (@allthreadsnot) {
			chomp $tline;
			if ($tline !~ /\t/) {
				($theuser, undef, $thelang, $thetype) = split(/\|/, $tline, 4);
				if (!$thelang) { $thelang = $lang; }
				print FILE "$theuser\t$thelang|1|1\n";
			} else {
				print FILE "$tline\n";
			}
		}
		fclose(FILE);
		if (!-s "$datadir/$threadfile.mail") { &delete_DBorFILE("$datadir/$threadfile.mail"); }
	}
}

sub tempstarter {
	require "Paths.pl";

	$YaBBversion = 'YaBB 3 Beta';

	# Make sure the module path is present
	# Some servers need all the subdirs in @INC too.
	push(@INC, "./Modules");
	push(@INC, "./Modules/Upload");
	push(@INC, "./Modules/Digest");

	if ($ENV{'SERVER_SOFTWARE'} =~ /IIS/) {
		$yyIIS = 1;
		$0 =~ m~(.*)(\\|/)~;
		$yypath = $1;
		$yypath =~ s~\\~/~g;
		chdir($yypath);
		push(@INC, $yypath);
	}

	require "$vardir/Settings.pl";
	require "$vardir/membergroups.txt";
	require "$sourcedir/Subs.pl";
	require "$sourcedir/DateTime.pl";
	require "$sourcedir/Load.pl";
	require "$sourcedir/System.pl";
	require "$admindir/Admin.pl";
	require "$boardsdir/forum.master";

	&LoadCookie;          # Load the user's cookie (or set to guest)
	&LoadUserSettings;    # Load user settings
	&WhatTemplate;        # Figure out which template to be using.
	&WhatLanguage;        # Figure out which language file we should be using! :D

	require "$sourcedir/Security.pl";

	&WriteLog;            # Write to the log

	$tabsep = qq~<img src="$imagesdir/tabsep211.png" border="0" alt="" style="float: left; vertical-align: middle;" />~;
	$tabfill = qq~<img src="$imagesdir/tabfill.gif" border="0" alt="" style="vertical-align: middle;" />~;

}

sub SetupImgLoc {
	if (!-e "$forumstylesdir/$useimages/$_[0]") { $thisimgloc = qq~img src="$forumstylesurl/default/$_[0]"~; }
	else { $thisimgloc = qq~img src="$imagesdir/$_[0]"~; }
	return $thisimgloc;
}

sub FixFileTemplate {
	$gzcomp = 0;
	&print_output_header;

	$yyposition = $yytitle;
	$yytitle = "$mbname - $yytitle";

	$yyimages = $imagesdir;
	$yydefaultimages = $defaultimagesdir;
	$yystyle = qq~<link rel="stylesheet" href="$forumstylesurl/$usestyle.css" type="text/css" />~;
	$yystyle =~ s~$usestyle\/~~g;

	$yytemplate = "$templatesdir/$usehead/$usehead.html";
	fopen(TEMPLATE, "$yytemplate") || die("$maintxt{'23'}: $testfile");
	@yytemplate = <TEMPLATE>;
	fclose(TEMPLATE);

	my $output = '';
	$yyboardname = "$mbname";
	$yytime = &timeformat($date, 1);
	$yyuname = $iamguest ? qq~~ : qq~$maintxt{'247'} ${$uid.$username}{'realname'}, ~;
	if ($enable_news) {
		fopen(NEWS, "$vardir/news.txt");
		@newsmessages = <NEWS>;
		fclose(NEWS);
	}
	for (my $i = 0; $i <= $#yytemplate; $i++) {
		$curline = $yytemplate[$i];
		if (!$yycopyin && $curline =~ m~({|<)yabb copyright(}|>)~) { $yycopyin = 1; }
		if ($curline =~ m~({|<)yabb newstitle(}|>)~ && $enable_news) {
			$yynewstitle = qq~<b>$maintxt{'102'}:</b> ~;
		}
		if ($curline =~ m~({|<)yabb news(}|>)~ && $enable_news) {
			srand;
			if ($shownewsfader == 1) {
				#$yynews = qq~$newsmessages[int rand(@newsmessages)] ~;
				$fadedelay = ($maxsteps * $stepdelay);
				$yynews .= qq~
				<script language="JavaScript1.2" type="text/javascript">
					<!--
						var maxsteps = "$maxsteps";
						var stepdelay = "$stepdelay";
						var fadelinks = $fadelinks;
						var delay = "$fadedelay";
						var fcontent = new Array();
						var begintag = "";~;
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
						fcontent[$j] = "$message";\n~;
				}
				$yynews .= qq~
						var closetag = '';
						//window.onload = fade;
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
		$curline =~ s~<yabb\s+(\w+)>~${"yy$1"}~g;
		$curline =~ s~{yabb\s+(\w+)}~${"yy$1"}~g; ## new tag template style decoding ##
		$curline =~ s~img src\=\"$imagesdir\/(.+?)\"~&SetupImgLoc($1)~eisg;
		$curline =~ s~alt\=\"(.*?)\"~alt\=\"$1\" title\=\"$1\"~ig;
		$output .= $curline;
	}
	if ($yycopyin == 0) {
		$output = q~<center><h1><b>Sorry, the copyright tag <yabb copyright> must be in the template.<br />Please notify this forum's administrator that this site is using an ILLEGAL copy of YaBB!</b></h1></center>~;
	}
	print $output;
	exit;
}

1;