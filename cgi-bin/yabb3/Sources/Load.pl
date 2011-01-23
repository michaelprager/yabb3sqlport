###############################################################################
# Load.pl                                                                     #
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

$loadplver = 'YaBB 3.0 Beta $Revision: 100 $';

sub LoadBoardControl {
	my ($cntcat, $cntboard, $cntpic, $cntdescription, $cntmods, $cntmodgroups, $cnttopicperms, $cntreplyperms, $cntpollperms, $cntzero, $dummy, $dummy, $dummy, $cnttotals, $cntcanpost, $cntparent);
	$binboard = "";
	$annboard = "";

	my @boardcontrols = &read_DBorFILE(0,'',$boardsdir,'forum','control');
	$maxboards = $#boardcontrols;

	foreach my $boardline (@boardcontrols) {
		$boardline =~ s/[\r\n]//g; # Built in chomp

		($cntcat, $cntboard, $cntpic, $cntdescription, $cntmods, $cntmodgroups, $cnttopicperms, $cntreplyperms, $cntpollperms, $cntzero, $cntmembergroups, $cntann, $cntrbin, $cntattperms, $cntminageperms, $cntmaxageperms, $cntgenderperms, $cntcanpost, $cntparent) = split(/\|/, $boardline);
		## create a global boards array
		push(@allboards, $cntboard);

		$cntdescription =~ s/\&/\&amp;/g;

		%{ $uid . $cntboard } = (
			'cat'          => $cntcat,
			'description'  => $cntdescription,
			'pic'          => $cntpic,
			'mods'         => $cntmods,
			'modgroups'    => $cntmodgroups,
			'topicperms'   => $cnttopicperms,
			'replyperms'   => $cntreplyperms,
			'pollperms'    => $cntpollperms,
			'zero'         => $cntzero,
			'membergroups' => $cntmembergroups,
			'ann'          => $cntann,
			'rbin'         => $cntrbin,
			'attperms'     => $cntattperms,
			'minageperms'  => $cntminageperms,
			'maxageperms'  => $cntmaxageperms,
			'genderperms'  => $cntgenderperms,
			'canpost'      => $cntcanpost,
			'parent'       => $cntparent,);
		if ($cntann == 1)  { $annboard = $cntboard; }
		if ($cntrbin == 1) { $binboard = $cntboard; }
	}
}

sub LoadIMs {
	return if ($iamguest || $PM_level == 0 || ($maintenance && !$iamadmin) || ($PM_level == 2 && (!$iamadmin && !$iamgmod && !$iammod)) || ($PM_level == 3 && (!$iamadmin && !$iamgmod)));

	&buildIMS($username, 'load') unless exists ${$username}{'PMmnum'};

	my $imnewtext;
	if (${$username}{'PMimnewcount'} == 1) { $imnewtext = qq~<a href="$scripturl?action=imshow;caller=1;id=-1">1 $load_txt{'155'}</a>~; }
	elsif (!${$username}{'PMimnewcount'}) { $imnewtext = $load_txt{'nonew'}; }
	else { $imnewtext = qq~<a href="$scripturl?action=imshow;caller=1;id=-1">${$username}{'PMimnewcount'} $load_txt{'154'}</a>~; }

	if (${$username}{'PMmnum'} == 1) { $yyim = qq~$load_txt{'152'} <a href="$scripturl?action=im">${$username}{'PMmnum'} $load_txt{'471'}</a>, $imnewtext~; }
	elsif (!${$username}{'PMmnum'} && !${$username}{'PMimnewcount'}) { $yyim = qq~$load_txt{'152'} <a href="$scripturl?action=im">${$username}{'PMmnum'} $load_txt{'153'}</a>~; }
	else { $yyim = qq~$load_txt{'152'} <a href="$scripturl?action=im">${$username}{'PMmnum'} $load_txt{'153'}</a>, $imnewtext~; }

	if (!$user_ip && $iamadmin) { $yyim .= qq~<br /><b>$load_txt{'773'}</b>~; }
}

sub LoadCensorList {
	if ($#censored > 0 || -s "$langdir/$language/censor.txt" < 3 || !-e "$langdir/$language/censor.txt") { return; }
	foreach my $buffer (&read_DBorFILE(0,'',"$langdir/$language",'censor','txt')) {
		$buffer =~ s/\r(?=\n*)//g;
		if ($buffer =~ m/\~/) {
			($tmpa, $tmpb) = split(/\~/, $buffer);
			$tmpc = 0;
		} else {
			($tmpa, $tmpb) = split(/=/, $buffer);
			$tmpc = 1;
		}
		push(@censored, [$tmpa, $tmpb, $tmpc]);
	}
}

sub LoadUserSettings {
	&LoadBoardControl;

	($iamadmin,$iamgmod,$iammod,$staff,$iamguest,$iambot) = (0,0,0,0,0,0);

	&GetBotlist; # Here because some users can be bots :-(
	$iambot = 1 if &Is_Bot("$user_host#$ENV{'HTTP_USER_AGENT'}");

	if ($username ne 'Guest') {
		&LoadUser($username);
		# Make sure that if the password doesn't match,
		# or the forum is in maintenace and you are not the admin,
		# you get FULLY Logged out
		if (${$uid.$username}{'password'} eq $password && (!$maintenance || ${$uid.$username}{'position'} eq 'Administrator')) {
			if    (${$uid.$username}{'position'} eq 'Administrator')    { $staff = $iamadmin = 1; }
			elsif (${$uid.$username}{'position'} eq 'Global Moderator') { $staff = $iamgmod  = 1; }
			$iammod = &is_moderator($username);
			$staff = $staff || $iammod;

			$sessionvalid = 1;
			if ($sessions && $staff) {
				my $cursession = &encode_password($user_ip);
				if (${$uid.$username}{'session'} !~ /^($cursession|$cookiesession)$/) {
					$staff = $iammod = $iamgmod = $iamadmin = $sessionvalid = 0;
				}
			}

			&CalcAge($username, "calc");
			# Set the order how Topic summaries are displayed
			$ttsreverse = ${$uid.$username}{'reversetopic'} if !$adminscreen && $ttsureverse;
			return;
		}
	}

	&FormatUserName('');
	&UpdateCookie("delete");
	$username           = 'Guest';
	$iamguest           = 1;
	$password           = '';
	$ENV{'HTTP_COOKIE'} = '';
	$yyim               = '';
	$yyuname            = '';
}

sub FormatUserName {
	my $user = $_[0];
	return if $useraccount{$user};
	$useraccount{$user} = $do_scramble_id ? &cloak($user) : $user;
}

sub LoadUser {
	my ($user,$userextension) = @_;
	return 1 if exists ${$uid.$user}{'realname'};
	return 0 if $user eq '' || $user eq 'Guest';

	if (!$userextension){ $userextension = 'vars'; }
	if (($regtype == 1 || $regtype == 2) && &checkfor_DBorFILE("$memberdir/$user.pre")) { $userextension = 'pre'; }
	elsif ($regtype == 1 && &checkfor_DBorFILE("$memberdir/$user.wait")) { $userextension = 'wait'; }

	if (&checkfor_DBorFILE("$memberdir/$user.$userextension")) {
		if ($use_MySQL || $user ne $username) {
			my $i = 0;
			foreach (&read_DBorFILE(0,'',$memberdir,$user,$userextension)) {
				if ($use_MySQL && $userextension eq 'vars') {
					${$uid.$user}{$db_vars_tabs_order[$i]} = $_; $i++;
				} else {
					if ($_ =~ /'(.*?)',"(.*?)"/) { ${$uid.$user}{$1} = $2; }
				}
			}
		} else {
			my @settings = &read_DBorFILE(0,LOADUSER,$memberdir,$user,$userextension);
			for (my $i = 0; $i < @settings; $i++) {
				if ($settings[$i] =~ /'(.*?)',"(.*?)"/) {
					${$uid.$user}{$1} = $2;
					if($1 eq 'lastonline' && $INFO{'action'} ne "login2") {
						${$uid.$user}{$1} = $date;
						$settings[$i] = qq~'lastonline',"$date"\n~;
					}
				}
			&write_DBorFILE(${$uid.$user}{'mysql'},LOADUSER,$memberdir,$user,$userextension,@settings);
		}
	}

	if (${$uid.$user}{'realname'} ne "") {
		if ($use_MySQL) {
			${$uid.$user}{'mysql'} = 1;
			if ($user eq $username && $userextension eq 'vars' && $INFO{'action'} ne "login2") {
				&write_DBorFILE(${$uid.$user}{'mysql'},'',$memberdir,$user,'lastonline',($date));
			}

			if (${$uid.$user}{'additional_variables'}) { # only in SQL-DB
				foreach (split(/\n/, ${$uid.$user}{'additional_variables'})) {
					if ($_ =~ /'(.*?)',"(.*?)"/) { ${$uid.$user}{$1} = $2; }
				}
				undef ${$uid.$user}{'additional_variables'};
			}
		}

		&ToChars(${$uid.$user}{'realname'});
		&FormatUserName($user);
		&LoadMiniUser($user);

		return 1;
	}

	undef %{$uid.$user};
	return 0; # user not found
}

sub is_moderator {
	my $user = $_[0];
	my @checkboards;
	if ($_[1]) { @checkboards = ($_[1]); }
	else { @checkboards = @allboards; }

	foreach (@checkboards) {
		# check if user is in the moderator list
		foreach (split(/, ?/, ${$uid.$_}{'mods'})) {
			if ($_ eq $user) { return 1; }
		}

		# check if user is member of a moderatorgroup
		foreach my $testline (split(/, /, ${$uid.$_}{'modgroups'})) {
			if ($testline eq ${$uid.$user}{'position'}) { return 1; }

			foreach (split(/,/, ${$uid.$user}{'addgroups'})) {
				if ($testline eq $_) { return 1; }
			}
		}
	}
	return 0;
}

sub KillModerator {
	my $killmod = $_[0];
	my ($cntcat, $cntboard, $cntpic, $cntdescription, $cntmods, $cntmodgroups, $cnttopicperms, $cntreplyperms, $cntpollperms, $cntzero, $dummy, $dummy, $dummy, $cnttotals, @boardcontrol, @newmods);

	foreach $boardline (&read_DBorFILE(0,FORUMCONTROL,$boardsdir,'forum','control')) {
		chomp $boardline;
		if ($boardline ne "") {
			@newmods = ();
			($cntcat, $cntboard, $cntpic, $cntdescription, $cntmods, $cntmodgroups, $cnttopicperms, $cntreplyperms, $cntpollperms, $cntzero, $cntpassword, $cnttotals, $cntattperms, $spare, $cntminageperms, $cntmaxageperms, $cntgenderperms) = split(/\|/, $boardline);
			foreach (split(/, /, $cntmods)) {
				if ($killmod ne $_) { push(@newmods, $_); }
			}
			$cntmods = join(", ", @newmods);
			push(@boardcontrol, "$cntcat|$cntboard|$cntpic|$cntdescription|$cntmods|$cntmodgroups|$cnttopicperms|$cntreplyperms|$cntpollperms|$cntzero|$cntpassword|$cnttotals|$cntattperms|$spare|$cntminageperms|$cntmaxageperms|$cntgenderperms\n");
		}
	}
	&write_DBorFILE(0,FORUMCONTROL,$boardsdir,'forum','control',&undupe(@boardcontrol));
}

sub KillModeratorGroup {
	my $killmod = $_[0];
	my ($cntcat, $cntboard, $cntpic, $cntdescription, $cntmods, $cntmodgroups, $cnttopicperms, $cntreplyperms, $cntpollperms, $cntzero, $dummy, $dummy, $dummy, $cnttotals, @boardcontrol, @newmods);

	foreach $boardline (&read_DBorFILE(0,FORUMCONTROL,$boardsdir,'forum','control')) {
		chomp $boardline;
		if ($boardline ne "") {
			@newmods = ();
			($cntcat, $cntboard, $cntpic, $cntdescription, $cntmods, $cntmodgroups, $cnttopicperms, $cntreplyperms, $cntpollperms, $cntzero, $cntpassword, $cnttotals, $cntattperms, $spare, $cntminageperms, $cntmaxageperms, $cntgenderperms) = split(/\|/, $boardline);
			foreach (split(/, /, $cntmodgroups)) {
				if ($killmod ne $_) { push(@newmods, $_); }
			}
			$cntmodgroups = join(", ", @newmods);
			push(@boardcontrol, "$cntcat|$cntboard|$cntpic|$cntdescription|$cntmods|$cntmodgroups|$cnttopicperms|$cntreplyperms|$cntpollperms|$cntzero|$cntpassword|$cnttotals|$cntattperms|$spare|$cntminageperms|$cntmaxageperms|$cntgenderperms\n");
		}
	}
	&write_DBorFILE(0,FORUMCONTROL,$boardsdir,'forum','control',&undupe(@boardcontrol));
}

sub LoadUserDisplay {
	my $user = $_[0];
	if (exists ${$uid.$user}{'password'}) {
		if ($yyUDLoaded{$user}) { return 1; }
	} else {
		&LoadUser($user);
	}
	&LoadCensorList;

	${$uid.$user}{'weburl'} = ${$uid.$user}{'weburl'} ? qq~<a href="${$uid.$user}{'weburl'}" target="_blank">~ . ($sm ? $img{'website_sm'} : $img{'website'}) . '</a>' : '';

	if (${$uid.$user}{'signature'}) {
		$message = ${$uid.$user}{'signature'};

		if ($enable_ubbc) {
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC(1);
		}

		&ToChars($message);

		${$uid.$user}{'signature'} = &Censor($message);

		# use height like code boxes do. Set to 200px at > 15 newlines
		if (15 < ${$uid.$user}{'signature'} =~ /<br \/>|<tr>/g) {
			${$uid.$user}{'signature'} = qq~<div style="float: left; font-size: 10px; font-family: verdana, sans-serif; overflow: auto; max-height: 200px; height: 200px; width: 99%;">${$uid.$user}{'signature'}</div>~;
		} else {
			${$uid.$user}{'signature'} = qq~<div style="float: left; font-size: 10px; font-family: verdana, sans-serif; overflow: auto; max-height: 200px; width: 99%;">${$uid.$user}{'signature'}</div>~;
		}
	}

	${$uid.$user}{'aim'} = ${$uid.$user}{'aim'} ? qq~<a href="aim:goim?screenname=${$uid.$user}{'aim'}&#38;message=Hi.+Are+you+there?">$img{'aim'}</a>~ : '';
	${$uid.$user}{'facebook'} = ${$uid.$user}{'facebook'} ? qq~<a href="http://www.facebook.com/~ . (${$uid.$user}{'facebook'} !~ /\D/ ? "profile.php?id=" : "") . qq~${$uid.$user}{'facebook'}" target="_blank">$img{'facebook'}</a>~ : '';
	${$uid.$user}{'gtalk'} = ${$uid.$user}{'gtalk'} ? qq~<a href="javascript:void(window.open('$scripturl?action=setgtalk;gtalkname=$useraccount{$user}','','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'))">$img{'gtalk'}</a>~ : '';
	${$uid.$user}{'icq'} = ${$uid.$user}{'icq'} ? qq~<a href="http://web.icq.com/${$uid.$user}{'icq'}" title="${$uid.$user}{'icq'}" target="_blank">$img{'icq'}</a>~ : '';
	${$uid.$user}{'msn'} = ${$uid.$user}{'msn'} ? qq~<a href="javascript:void(window.open('$scripturl?action=setmsn;msnname=$useraccount{$user}','','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'))">$img{'msn'}</a>~ : '';
	${$uid.$user}{'myspace'} = ${$uid.$user}{'myspace'} ? qq~<a href="http://www.myspace.com/${$uid.$user}{'myspace'}" target="_blank">$img{'myspace'}</a>~ : '';
	${$uid.$user}{'skype'} = ${$uid.$user}{'skype'} ? qq~<a href="javascript:void(window.open('callto://${$uid.$user}{'skype'}','skype','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'))">$img{'skype'}</a>~ : '';
	${$uid.$user}{'yim'} = ${$uid.$user}{'yim'} ? qq~<a href="http://edit.yahoo.com/config/send_webmesg?.target=${$uid.$user}{'yim'}" target="_blank">$img{'yim'}</a>~ : '';

	if ($showgenderimage && ${$uid.$user}{'gender'}) {
		${$uid.$user}{'gender'} = ${$uid.$user}{'gender'} =~ m~Female~i ? 'female' : 'male';
		${$uid.$user}{'gender'} = ${$uid.$user}{'gender'} ? qq~$load_txt{'231'}: <img src="$imagesdir/${$uid.$user}{'gender'}.gif" border="0" alt="${$uid.$user}{'gender'}" title="${$uid.$user}{'gender'}" /><br />~ : '';
	} else {
		${$uid.$user}{'gender'} = '';
	}

	if ($showusertext && ${$uid.$user}{'usertext'}) { # Censor the usertext and wrap it
		${$uid.$user}{'usertext'} = &WrapChars(&Censor(${$uid.$user}{'usertext'}),20);
	} else {
		${$uid.$user}{'usertext'} = "";
	}

	# Create the userpic / avatar html
	if ($showuserpic && $allowpics && $iamguest) {
		${$uid.$user}{'userpic'} ||= 'blank.gif';
		${$uid.$user}{'userpic'} = qq~<img src="~ .(${$uid.$user}{'userpic'} =~ m~\A[\s\n]*https?://~i ? ${$uid.$user}{'userpic'} : "$facesurl/${$uid.$user}{'userpic'}") . qq~" name="avatar_img_resize" alt="" border="0" style="display:none" /><br />~;
	} elsif ($showuserpic && $allowpics) {
		${$uid.$user}{'userpic'} ||= 'blank.gif';
		${$uid.$user}{'userpic'} = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$user}" rel="nofollow"><img src="~ .(${$uid.$user}{'userpic'} =~ m~\A[\s\n]*https?://~i ? ${$uid.$user}{'userpic'} : "$facesurl/${$uid.$user}{'userpic'}") . qq~" name="avatar_img_resize" alt="" border="0" style="display:none" /></a><br />~;
	} else {
		${$uid.$user}{'userpic'} = '<br />';
	}

	&LoadMiniUser($user);

	$yyUDLoaded{$user} = 1;
}

sub LoadMiniUser {
	my $user = $_[0];
	my $load = '';
	my $key  = '';
	$g = 0;
	my $dg = 0;
	my ($tempgroup, $temp_postgroup);
	my $noshow = 0;
	my $bold   = 0;

	$tempgroupcheck = ${$uid.$user}{'position'} || "";

	if (exists $Group{$tempgroupcheck} && $tempgroupcheck ne "") {
		($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $Group{$tempgroupcheck});
		$temptitle = $title;
		$tempgroup = $Group{$tempgroupcheck};
		if ($noshow == 0) { $bold = 1; }
		$memberunfo{$user} = $tempgroupcheck;
	} elsif ($moderators{$user}) {
		($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $Group{'Moderator'});
		$temptitle         = $title;
		$tempgroup         = $Group{'Moderator'};
		$memberunfo{$user} = $tempgroupcheck;
	} elsif (exists $NoPost{$tempgroupcheck} && $tempgroupcheck ne "") {
		($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $NoPost{$tempgroupcheck});
		$temptitle         = $title;
		$tempgroup         = $NoPost{$tempgroupcheck};
		$memberunfo{$user} = $tempgroupcheck;
	}

	if (!$tempgroup) {
		foreach $postamount (sort { $b <=> $a } keys %Post) {
			if (${$uid.$user}{'postcount'} >= $postamount) {
				($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $Post{$postamount});
				$tempgroup = $Post{$postamount};
				last;
			}
		}
		$memberunfo{$user} = $title;
	}

	if ($noshow == 1) {
		$temptitle = $title;
		foreach $postamount (sort { $b <=> $a } keys %Post) {
			if (${$uid.$user}{'postcount'} > $postamount) {
				($title, $stars, $starpic, $color, undef) = split(/\|/, $Post{$postamount},5);
				last;
			}
		}
	}

	if (!$tempgroup) {
		$temptitle   = "no group";
		$title       = "";
		$stars       = 0;
		$starpic     = "";
		$color       = "";
		$noshow      = 1;
		$viewperms   = "";
		$topicperms  = "";
		$replyperms  = "";
		$pollperms   = "";
		$attachperms = "";
	}

	# The following puts some new has variables in if this user is the user browsing the board
	if ($user eq $username) {
		if ($tempgroup) {
			($trash, $trash, $trash, $trash, $trash, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $tempgroup);
		}
		${$uid.$user}{'perms'} = "$viewperms|$topicperms|$replyperms|$pollperms|$attachperms";
	}

	$userlink = ${$uid.$user}{'realname'} || $user;
	$userlink = qq~<b>$userlink</b>~;
	if (!$scripturl) { $scripturl = qq~$boardurl/$yyexec.$yyext~; }
	if ($bold != 1) { $memberinfo{$user} = qq~$title~; }
	else { $memberinfo{$user} = qq~<b>$title</b>~; }

	if ($color ne "") {
		$link{$user}      = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$user}" rel="nofollow" style="color:$color;">$userlink</a>~;
		$format{$user}    = qq~<span style="color: $color;">$userlink</span>~;
		$col_title{$user} = qq~<span style="color: $color;">$memberinfo{$user}</span>~;
	} else {
		$link{$user}      = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$user}" rel="nofollow">$userlink</a>~;
		$format{$user}    = qq~$userlink~;
		$col_title{$user} = qq~$memberinfo{$user}~;
	}
	$addmembergroup{$user} = "<br />";
	foreach $addgrptitle (split(/,/, ${$uid.$user}{'addgroups'})) {
		foreach $key (sort { $a <=> $b } keys %NoPost) {
			($atitle, $t, $t, $t, $anoshow, $aviewperms, $atopicperms, $areplyperms, $apollperms, $aattachperms) = split(/\|/, $NoPost{$key});
			if ($addgrptitle eq $key && $atitle ne $title) {
				if ($user eq $username && !$iamadmin) {
					if ($aviewperms == 1)   { $viewperms   = 1; }
					if ($atopicperms == 1)  { $topicperms  = 1; }
					if ($areplyperms == 1)  { $replyperms  = 1; }
					if ($apollperms == 1)   { $pollperms   = 1; }
					if ($aattachperms == 1) { $attachperms = 1; }
					${$uid.$user}{'perms'} = "$viewperms|$topicperms|$replyperms|$pollperms|$attachperms";
				}
				if ($anoshow && ($iamadmin || ($iamgmod && $gmod_access2{"profileAdmin"}))) {
					$addmembergroup{$user} .= qq~($atitle)<br />~;
				} elsif (!$anoshow) {
					$addmembergroup{$user} .= qq~$atitle<br />~;
				}
			}
		}
	}
	$addmembergroup{$user} =~ s/<br \/>\Z//;

	if ($username eq "Guest") { $memberunfo{$user} = "Guest"; }

	$topicstart{$user} = "";
	$viewnum = "";
	if ($INFO{'num'} || $FORM{'threadid'} && $user eq $username) {
		if ($INFO{'num'}) {
			$viewnum = $INFO{'num'};
		} elsif ($FORM{'threadid'}) {
			$viewnum = $FORM{'threadid'};
		}
		if ($viewnum =~ m~/~) { ($viewnum, undef) = split('/', $viewnum); }

		# No need to open the message file so many times.
		# Opening it once is enough to do the access checks.
		unless ($topicstarter) {
			if (&checkfor_DBorFILE("$datadir/$viewnum.txt")) {
				unless (ref($thread_arrayref{$viewnum})) {
					@{$thread_arrayref{$viewnum}} = &read_DBorFILE(1,'',$datadir,$viewnum,'txt');
				}
				(undef, undef, undef, undef, $topicstarter, undef) = split(/\|/, ${$thread_arrayref{$viewnum}}[0], 6);
			}
		}

		if ($user eq $topicstarter) { $topicstart{$user} = "Topic Starter"; }
	}
	$memberaddgroup{$user} = ${$uid.$user}{'addgroups'};

	my $starnum = $stars;
	my $memberstartemp = '';
	if ($starpic !~ /\//) { $starpic = "$imagesdir/$starpic"; }
	while ($starnum-- > 0) {
		$memberstartemp .= qq~<img src="$starpic" border="0" alt="*" />~;
	}
	$memberstar{$user} = $memberstartemp ? "$memberstartemp<br />" : "";
}

sub QuickLinks {
	my $user = $_[0];
	my $lastonline;
	if ($iamguest) { return ($_[1] ? ${$uid.$user}{'realname'} : $format{$user}); }

	if ($iamadmin || $iamgmod || $lastonlineinlink) {
		if(${$uid.$user}{'lastonline'}) {
			$lastonline = $date - ${$uid.$user}{'lastonline'};
			my $days  = int($lastonline / 86400);
			my $hours = sprintf("%02d", int(($lastonline - ($days * 86400)) / 3600));
			my $mins  = sprintf("%02d", int(($lastonline - ($days * 86400) - ($hours * 3600)) / 60));
			my $secs  = sprintf("%02d", ($lastonline - ($days * 86400) - ($hours * 3600) - ($mins * 60)));
			if (!$mins) {
				$lastonline = "00:00:$secs";
			} elsif (!$hours) {
				$lastonline = "00:$mins:$secs";
			} elsif (!$days) {
				$lastonline = "$hours:$mins:$secs";
			} else {
				$lastonline = "$days $maintxt{'11'} $hours:$mins:$secs";
			}
				$lastonline = qq~ title="$maintxt{'10'} $lastonline $maintxt{'12'}."~;
		} else {
			$lastonline = qq~ title="$maintxt{'13'}."~;
		}
	}
	if ($usertools) {
		$qlcount++;
		my $display = "display:inline";
		if ($ENV{'HTTP_USER_AGENT'} =~ /opera/i) {
			$display = "display:inline-block";
		} elsif ($ENV{'HTTP_USER_AGENT'} =~ /firefox/i) {
			$display = "display:inline-block";
		}
		my $quicklinks = qq~<div style="position:relative;$display">
			<ul id="ql$useraccount{$user}$qlcount" class="QuickLinks" onmouseover="keepLinks('ql$useraccount{$user}$qlcount')" onmouseout="TimeClose('ql$useraccount{$user}$qlcount')">
				<li>~ . &userOnLineStatus($user) . qq~<a href="javascript:closeLinks('ql$useraccount{$user}$qlcount')" style="position:absolute;right:3px"><b>X</b></a></li>\n~;
		if ($user ne $username) {
			$quicklinks .= qq~				<li><a href="$scripturl?action=viewprofile;username=$useraccount{$user}" rel="nofollow">$maintxt{'2'} ${$uid.$user}{'realname'}$maintxt{'3'}</a></li>\n~;
			&CheckUserPM_Level($user);
			if ($PM_level == 1 || ($PM_level == 2 && $UserPM_Level{$user} > 1 && $staff) || ($PM_level == 3 && $UserPM_Level{$user} == 3 && ($iamadmin || $iamgmod))) {
				if (1) {#links_impopup
					$quicklinks .= qq~
				<li><a href="javascript://" onclick="IMPage('$scripturl?action=imsend;to=$useraccount{$user}','${$uid.$user}{'realname'}','$useraccount{$user}')">$maintxt{'0'} ${$uid.$user}{'realname'}</a></li>\n~;
				} else {
					$quicklinks .= qq~
				<li><a href="$scripturl?action=imsend;to=$useraccount{$user}">$maintxt{'0'} ${$uid.$user}{'realname'}</a></li>\n~;
				}
			}
			if (!${$uid.$user}{'hidemail'} || $iamadmin) {
				$quicklinks .= "
				<li>" . &enc_eMail("$maintxt{'1'} ${$uid.$user}{'realname'}",${$uid.$user}{'email'},'','') . "</li>\n";
			}
			if (!%mybuddie) { &loadMyBuddy; }
			if ($buddyListEnabled && !$mybuddie{$user}) {
				$quicklinks .= qq~
				<li><a href="$scripturl?action=addbuddy;name=$useraccount{$user}">$maintxt{'4'} ${$uid.$user}{'realname'} $maintxt{'5'}</a></li>\n~;
			}

		} else {
			$quicklinks .= qq~				<li><a href="$scripturl?action=viewprofile;username=$useraccount{$user}" rel="nofollow">$maintxt{'6'}</a></li>\n~;
		}
		$quicklinks .= qq~			</ul><a href="javascript:quickLinks('ql$useraccount{$user}$qlcount')"$lastonline>~;
		$quicklinks .= $_[1] ? ${$uid.$user}{'realname'} : $format{$user};
		qq~$quicklinks</a></div>~;

	} else {
		qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$user}"$lastonline>~ . ($_[1] ? ${$uid.$user}{'realname'} : $format{$user}) . qq~</a>~;
	}
}
sub LoadTools {
	my($where, @buttons) = @_;
	
	# Load Icon+Text for tool drop downs
	my @tools;
	
	if(!%tmpimg) { %tmpimg = %img; }
	require "$vardir/Menu3.def";
				
	for (my $i=0; $i <= $#buttons; $i++) {
		$tools[$i] = $def_img{$buttons[$i]};
	}

	for (my $i=0; $i <= $#tools; $i++) {
		my ($img_url, $img_txt) = split(/\|/, $tools[$i]);
		$tools[$i] = qq~[tool=$buttons[$i]]<div style="display:inline-block; cursor: pointer; background-image: url($img_url); padding-top: 2px; background-repeat: no-repeat; padding-left: 22px; height: 17px; text-align: left">$img_txt</div>[/tool]~;
	}

	for (my $i=0; $i <= $#tools; $i++) {
		$img{$buttons[$i]} = $tools[$i];
	}
}

sub MakeTools {
	
	my ($counter, $text, $template) = @_;
	
	my $list_item = "</li><li>";
	$template = qq~<li>$template</li>~;
	$template =~ s/\|\|\|/$list_item/g;
	$template =~ s/<li>[\s]*<\/li>//g;
	
	my $tools_template = $template ? qq~
	<div class="post_tools_a">
		<a href="javascript:quickLinks('threadtools$counter')">$text</a>
	</div>
	</td>
	<td width="1" align="center" valign="bottom" style="padding:0px">
	<div style="cursor: pointer; position:relative; float:right; display:inline-block; height:10px;" align="right">

		<ul class="post_tools_menu" id="threadtools$counter" onmouseover="keepLinks('threadtools$counter')" onmouseout="TimeClose('threadtools$counter')">
			$template
		</ul>
	</div>
	~ : qq~<img src="$imagesdir/actionslock.png" alt="$maintxt{'64'}" title="$maintxt{'64'}" border="0" />~;
	
	return $tools_template;
}


sub LoadCookie {
	foreach (split(/; /, $ENV{'HTTP_COOKIE'})) {
		$_ =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		($cookie, $value) = split(/=/);
		$yyCookies{$cookie} = $value;
	}
	if ($yyCookies{$cookiepassword}) {
		$password      = $yyCookies{$cookiepassword};
		$username      = $yyCookies{$cookieusername} || 'Guest';
		$cookiesession = $yyCookies{$cookiesession_name};
	} else {
		$password = '';
		$username = 'Guest';
	}
	if ($yyCookies{'guestlanguage'} && $enable_guestlanguage) {
		$language = $guestLang = $yyCookies{'guestlanguage'};
	}
}

sub UpdateCookie {
	my ($what, $user, $passw, $sessionval, $pathval, $expire) = @_;
	my ($valid, $expiration);
	if ($what eq "delete") {
		$expiration = "Thursday, 01-Jan-1970 00:00:00 GMT";
		$valid = 1;
	} elsif ($what eq "write") {
		$expiration = $expire;
		$valid = 1;
	}

	if ($valid) {
		if ($pathval eq "") { $pathval = '/'; }
		if ($expire eq "persistent") { $expiration = "Sunday, 17-Jan-2038 00:00:00 GMT"; }
		$yySetCookies1 = &write_cookie(
			-name    => $cookieusername,
			-value   => $user,
			-path    => $pathval,
			-expires => $expiration);
		$yySetCookies2 = &write_cookie(
			-name    => $cookiepassword,
			-value   => $passw,
			-path    => $pathval,
			-expires => $expiration);
		$yySetCookies3 = &write_cookie(
			-name    => $cookiesession_name,
			-value   => $sessionval,
			-path    => $pathval,
			-expires => $expiration);
		my ($catid, $boardlist, @bdlist, $curboard);
		foreach $catid (@categoryorder) {
		unless( $catid ) { next; }
		$boardlist = $cat{$catid};
		(@bdlist) = split(/\,/, $boardlist);
			foreach $curboard (@bdlist) {
				chomp $curboard;
				my $tsortcookie = "tsort$curboard$username";
				if ($yyCookies{$tsortcookie}) {
					push @otherCookies, write_cookie(
						-name    =>   "$tsortcookie",
						-value   =>   "",
						-path    =>   "/",
						-expires =>   "Thursday, 01-Jan-1970 00:00:00 GMT");
					$yyCookies{$tsortcookie} = "";
				}
			}
		}
	}
}

sub LoadAccess {
	$yesaccesses .= "$load_txt{'805'} $load_txt{'806'} $load_txt{'808'}<br />";
	$noaccesses = "";

	# Reply Check
	my $rcaccess = &AccessCheck($currentboard, 2) || 0;
	if ($rcaccess eq "granted") { $yesaccesses .= "$load_txt{'805'} $load_txt{'806'} $load_txt{'809'}<br />"; }
	else { $noaccesses .= "$load_txt{'805'} $load_txt{'807'} $load_txt{'809'}<br />"; }

	# Topic Check
	my $tcaccess = &AccessCheck($currentboard, 1) || 0;
	if ($tcaccess eq "granted") { $yesaccesses .= "$load_txt{'805'} $load_txt{'806'} $load_txt{'810'}<br />"; }
	else { $noaccesses .= "$load_txt{'805'} $load_txt{'807'} $load_txt{'810'}<br />"; }

	# Poll Check
	my $access = &AccessCheck($currentboard, 3) || 0;
	if ($access eq "granted") { $yesaccesses .= "$load_txt{'805'} $load_txt{'806'} $load_txt{'811'}<br />"; }
	else { $noaccesses .= "$load_txt{'805'} $load_txt{'807'} $load_txt{'811'}<br />"; }

	# Zero Post Check
	if ($username ne 'Guest') {
		if ($INFO{'zeropost'} != 1 && $rcaccess eq "granted") { $yesaccesses .= "$load_txt{'805'} $load_txt{'806'} $load_txt{'812'}<br />"; }
		else { $noaccesses .= "$load_txt{'805'} $load_txt{'807'} $load_txt{'812'}<br />"; }
	}

	$accesses = qq~$yesaccesses<br />$noaccesses~;
}

sub WhatTemplate {
	$found = 0;
	while (($curtemplate, $value) = each(%templateset)) {
		if ($curtemplate eq $default_template) { $template = $curtemplate; $found = 1; }
	}
	if (!$found) { $template = 'Forum default'; }
	if (${$uid.$username}{'template'} ne '') {
		if (!exists $templateset{${$uid.$username}{'template'}}) {
			${$uid.$username}{'template'} = 'Forum default';
			&UserAccount($username, "update");
		}
		while (($curtemplate, $value) = each(%templateset)) {
			if ($curtemplate eq ${$uid.$username}{'template'}) { $template = $curtemplate; }
		}
	}
	($usestyle, $useimages, $usehead, $useboard, $usemessage, $usedisplay, $usemycenter, $UseMenuType) = split(/\|/, $templateset{$template});

	if (!-e "$forumstylesdir/$usestyle.css") { $usestyle = 'default'; }
	if (!-e "$templatesdir/$usehead/$usehead.html") { $usehead = 'default'; }
	if (!-e "$templatesdir/$useboard/BoardIndex.template") { $useboard = 'default'; }
	if (!-e "$templatesdir/$usemessage/MessageIndex.template") { $usemessage = 'default'; }
	if (!-e "$templatesdir/$usedisplay/Display.template") { $usedisplay = 'default'; }
	if (!-e "$templatesdir/$usemycenter/MyCenter.template") { $usemycenter = 'default'; }

	if ($UseMenuType eq '') { $UseMenuType = $MenuType; }

	if (-d "$forumstylesdir/$useimages") { $imagesdir = "$forumstylesurl/$useimages"; }
	else { $imagesdir = "$forumstylesurl/default"; }
	$defaultimagesdir = "$forumstylesurl/default";
	$extpagstyle = qq~$forumstylesurl/$usestyle.css~;
	$extpagstyle =~ s~$usestyle\/~~g;
}

sub WhatLanguage {
	if (${$uid.$username}{'language'} ne '') {
		$language = ${$uid.$username}{'language'};
	} elsif ($FORM{'guestlang'} && $enable_guestlanguage) {
		$language = $FORM{'guestlang'};
	} elsif ($guestLang && $enable_guestlanguage) {
		$language = $guestLang;
	} else {
		$language = $lang;
	}

	&LoadLanguage('Main');
	&LoadLanguage('Menu');

	if ($adminscreen) {
		&LoadLanguage('Admin');
		&LoadLanguage('FA');
	}

}

# build the .ims file from scratch
# here because its needed by admin and user
#messageid|[blank]|touser(s)|(ccuser(s))|(bccuser(s))|
#	subject|date|message|(parentmid)|(reply#)|ip|
#		messagestatus|flags|storefolder|attachment
# messagestatus = c(confidential)/h(igh importance)/s(tandard)
# parentmid stays same, reply# increments for replies, so we can build conversation threads
# storefolder = name of storage folder. Start with in & out for everyone. 
# flags - u(nread)/f(orward)/q(oute)/r(eply)/c(alled back)
#
# old file
#1	$mnum = 3;
#2	$imnewcount = 0;
#3	$moutnum = 17;
#4	$storenum = 0;
#5	$draftnum = 0;
#6	@folders  (name1|name2|name3);

# new .ims file format
#	### YaBB UserIMS ###
#	'${$username}{'PMmnum'}',"value"
#	'${$username}{'PMimnewcount'}',"value"
#	'${$username}{'PMmoutnum'}',"value"
#	'${$username}{'PMstorenum'}',"value"
#	'${$username}{'PMdraftnum'}',"value"
#	'${$username}{'PMfolders'}',"value"
#	'${$username}{'PMfoldersCount'}',"value"
#	'${$username}{'PMbcRead'}',"value"

# usage: &buildIMS(<user>, 'tasks');
# tasks: load, update, '' [= rebuild]
sub buildIMS {
	my ($incurr, $inunr, $outcurr, $draftcount, @imstore, $storetotal, @storefoldersCount, $storeCounts);
	my ($builduser,$job) = @_;

	if ($job) {
		if ($job eq 'load') {
			&load_IMS($builduser);
		} else {
			&update_IMS($builduser);
		}
		return;
	}

	## inbox if it exists, either load and count totals or parse and update format.
	if (&checkfor_DBorFILE("$memberdir/$builduser.msg")) {
		my @messages = &read_DBorFILE(0,'',$memberdir,$builduser,'msg');

		# test the data for version. 16 elements in new format, no more than 8 in old.
		if (split(/\|/, $messages[0]) > 8) { # new format, so just need to check the flags
			foreach my $message (@messages) {
				# If the message is flagged as u(nopened), add to the new count
				if ((split /\|/, $message)[12] =~ /u/) { $inunr++; }
			}
			$incurr = @messages;

		} elsif (length($messages[0]) > 7) { # old format, needs rearranging
			($inunr,$incurr) = &convert_MSG($builduser);
		}
	}

	## do the outbox
	if (&checkfor_DBorFILE("$memberdir/$builduser.outbox")) {
		my @outmessages = &read_DBorFILE(0,'',$memberdir,$builduser,'outbox');
		if (split(/\|/, $outmessages[0]) > 8) { # > 10 elements in new format, no more than 8 in old
			$outcurr = @outmessages;
		} elsif (length($outmessages[0]) > 7) {
			$outcurr = &convert_OUTBOX($builduser);
		}
	}

	## do the draft store - slightly easier - only exists in y22
	if (&checkfor_DBorFILE("$memberdir/$builduser.imdraft")) {
		$draftcount = scalar &read_DBorFILE(0,'',$memberdir,$builduser,'imdraft');
	}

	## grab the current list of store folders
	## else, create an entry for the two 'default ones' for the in/out status stuff
	my $storefolders = ${$builduser}{'PMfolders'} || "in|out";
	my @currStoreFolders = split(/\|/, $storefolders);
	if (&checkfor_DBorFILE("$memberdir/$builduser.imstore")) {
		@imstore = &read_DBorFILE(0,'',$memberdir,$builduser,'imstore');
		if (@imstore) {
			# > 10 elements in new format, no more than 8 in old
			#messageid0|[blank]1|touser(s)2|(ccuser(s))3|(bccuser(s))4|
			#        subject5|date6|message7|(parentmid)8|(reply#)9|ip10|messagestatus11|flags12|storefolder13|attachment14
			if (split(/\|/, $imstore[0]) <= 8 && length($imstore[0]) > 7) { @imstore = &convert_IMSTORE($builduser); }

			my ($storeUpdated,$storeMessLine) = (0,0);
			foreach my $message (@imstore) {
				my @messLine = split(/\|/, $message);
				## look through list for folder name
				if ($messLine[13] eq '') { # some folder missing within imstore
					if ($messLine[1] ne '') { # 'from' name so inbox
						$messLine[13] = 'in';
					} else { # no 'from' so outbox
						$messLine[13] = 'out';
					}
					$imstore[$storeMessLine] = join('|', @messLine);
					$storeUpdated = 1;
				}
				unless ($storefolders =~ /\b$messLine[13]\b/) {
					push(@currStoreFolders, $messLine[13]);
					$storefolders = join('|', @currStoreFolders);
				}
				$storeMessLine++;
			}
			if ($storeUpdated == 1) {
				&write_DBorFILE(${$uid.$builduser}{'mysql'},'',$memberdir,$builduser,'imstore',@imstore);
			}
			$storetotal = @imstore;
			$storefolders = join('|', @currStoreFolders);

		} elsif (!$use_MySQL) {
			&delete_DBorFILE("$memberdir/$builduser.imstore");
		}
	}
	## run through the messages and count against the folder name
	for (my $y = 0; $y < @currStoreFolders; $y++) {
		$storefoldersCount[$y] = 0;
		for (my $x = 0; $x < @imstore; $x++) {
			if ((split(/\|/, $imstore[$x]))[13] eq $currStoreFolders[$y]) {
				$storefoldersCount[$y]++;
			}
		} 
	}
	$storeCounts = join('|', @storefoldersCount);

	&LoadBroadcastMessages($builduser);

	${$builduser}{'PMmnum'} = $incurr || 0;
	${$builduser}{'PMimnewcount'} = $inunr || 0;
	${$builduser}{'PMmoutnum'} = $outcurr || 0;
	${$builduser}{'PMdraftnum'} = $draftcount || 0;
	${$builduser}{'PMstorenum'} = $storetotal || 0;
	${$builduser}{'PMfolders'} = $storefolders;
	${$builduser}{'PMfoldersCount'} = $storeCounts || 0;
	&update_IMS($builduser);
}

sub update_IMS {
	my $builduser = shift;
	my @tag = qw(PMmnum PMimnewcount PMmoutnum PMstorenum PMdraftnum PMfolders PMfoldersCount PMbcRead);

	my @PM = (qq~### YaBB UserIMS ###\n\n~);
	for (my $cnt = 0; $cnt < @tag; $cnt++) {
		push(@PM, qq~'$tag[$cnt]',"${$builduser}{$tag[$cnt]}"\n~);
	}
	&write_DBorFILE(${$uid.$builduser}{'mysql'},'',$memberdir,$builduser,'ims',@PM);
}

sub load_IMS {
	my $builduser = shift;
	my @ims;
	if (&checkfor_DBorFILE("$memberdir/$builduser.ims")) { @ims = &read_DBorFILE(0,'',$memberdir,$builduser,'ims'); }

	if ($ims[0] =~ /###/) {
		foreach (@ims) { if ($_ =~ /'(.*?)',"(.*?)"/) { ${$builduser}{$1} = $2; } }
	} else {
		&buildIMS($builduser, '');
	}
}

sub LoadBroadcastMessages { #check broadcast messages
	return if ($iamguest || $PM_level == 0 || ($maintenance && !$iamadmin) || ($PM_level == 2 && !$staff) || ($PM_level == 3 && (!$iamadmin && !$iamgmod)));

	my $builduser = shift;
	$BCnewMessage = 0;
	$BCCount = 0;
	if (&checkfor_DBorFILE("$memberdir/broadcast.messages")) {
		my %PMbcRead;
		map { $PMbcRead{$_} = 0; } split(/,/, ${$builduser}{'PMbcRead'});

		foreach (&read_DBorFILE(0,'',$memberdir,'broadcast','messages')) {
			my ($mnum, $mfrom, $mto, undef) = split (/\|/, $_, 4);
			if ($mfrom eq $username) { $BCCount++; $PMbcRead{$mnum} = 1; }
			elsif (&BroadMessageView($mto)) {
				$BCCount++;
				if (exists $PMbcRead{$mnum}) { $PMbcRead{$mnum} = 1; }
				else { $BCnewMessage++; }
			}
		}
		${$builduser}{'PMbcRead'} = '';
		foreach (keys %PMbcRead) {
			if ($PMbcRead{$_}) {
				${$builduser}{'PMbcRead' . $_} = 1;
				${$builduser}{'PMbcRead'} .= ${$builduser}{'PMbcRead'} ? ",$_" : $_;
			}
		}
	} else {
		${$builduser}{'PMbcRead'} = '';
	}
}

sub convert_MSG {
	my $builduser = shift;
	my ($inunr,@newmess);
	# clean out msg file and rebuild in new format
	# new format:
	# messageid(0)|from(1)|touser(2)|ccuser(3)|bccuser(4)|subject(5)|date(6)|message(7)|parentmid(8)|reply#(9)|ip(10)|messagestatus(11)|flags(12)|storefolder(13)|attachment(14)
	# old format:
	# from(0)|subject(1)|date(2)|message(3)|messageid(4)|ip(5)|read/replied(6)
	my @oldmessages = &read_DBorFILE(0,OLDMESS,$memberdir,$builduser,'msg');
	chomp @oldmessages;
	foreach my $oldmessage (@oldmessages) { # parse messages for flags
		my @oldformat = split(/\|/,$oldmessage);
		# under old format, unread,and replied are exclusive, so no need to go mixing them
		if ($oldformat[6] == 1) { $oldformat[6] = 'u' ; $inunr++; } # if 6 (status) is 1 then change to u(nread) flag
		elsif ($oldformat[6] == 2) { $oldformat[6] = 'r'; } # if 6 (status) is 2 then change to r(eplied) flag
		# if any old style message ids still there, or odd blank ones, correct them to = date value
		if ($oldformat[4] < 101) { $oldformat[4] = $oldformat[2]; }
		# reassemble to new format and print back to file
		push(@newmess, "$oldformat[4]|$oldformat[0]|$builduser|||$oldformat[1]|$oldformat[2]|$oldformat[3]|$oldformat[4]|0|$oldformat[5]|s|$oldformat[6]||\n");
	}
	&write_DBorFILE(${$uid.$builduser}{'mysql'},OLDMESS,$memberdir,$builduser,'msg',@newmess);
	($inunr,scalar @newmess);
}

sub convert_OUTBOX {
	my $builduser = shift;
	## clean out msg file and rebuild in new format
	my @oldoutmessages = &read_DBorFILE(0,OLDOUTBOX,$memberdir,$builduser,'outbox');
	chomp @oldoutmessages;
	# clean out msg file and rebuild in new format
	# new format:
	# messageid(0)|from(1)|touser(2)|ccuser(3)|bccuser(4)|subject(5)|date(6)|message(7)|parentmid(8)|reply#(9)|ip(10)|messagestatus(11)|flags(12)|storefolder(13)|attachment(14)
	# old format:
	# from(0)|subject(1)|date(2)|message(3)|messageid(4)|ip(5)|read/replied(6)
	my @newout;
	foreach my $oldmessage (@oldoutmessages) {
		my @oldformat = split(/\|/, $oldmessage);
		## if any old style message ids still there, or odd blank ones, correct them to = date value
		if ($oldformat[4] < 101 || $oldformat[4] eq '') { $oldformat[4] = $oldformat[2]; }
		## outbox can't be replied to ;) and forwarding doesn't exist in old format
		if (!$oldformat[6]) { $oldformat[6] = 'u'; }
		elsif ($oldformat[6] == 1) { $oldformat[6] = ''; }
		push(@newout, "$oldformat[4]|$builduser|$oldformat[0]|||$oldformat[1]|$oldformat[2]|$oldformat[3]|$oldformat[4]|0|$oldformat[5]|s|$oldformat[6]||\n");
	}
	&write_DBorFILE(${$uid.$builduser}{'mysql'},OLDOUTBOX,$memberdir,$builduser,'outbox',@newout);
	return scalar @newout;
}

sub convert_IMSTORE {
	my $builduser = shift;
	my @imstore;
	my @oldstoremessages = &read_DBorFILE(0,OLDIMSTORE,$memberdir,$builduser,'imstore');
	chomp @oldstoremessages;
	# new format:
	# messageid(0)|from(1)|touser(2)|ccuser(3)|bccuser(4)|subject(5)|date(6)|message(7)|parentmid(8)|reply#(9)|ip(10)|messagestatus(11)|flags(12)|storefolder(13)|attachment(14)
	# old format:
	# from(0)|subject(1)|date(2)|message(3)|messageid(4)|ip(5)|read/replied(6)|folder/imwhere(7)
	foreach my $oldmessage (@oldstoremessages) {
		my @oldformat = split(/\|/, $oldmessage);
		my ($touser, $fromuser);
		if ($oldformat[7] eq 'outbox') { 
			$oldformat[7] = 'out';
			$touser = $oldformat[0];
			$fromuser = $builduser;
			if (!$oldformat[6]) { $oldformat[6] = 'u'; }
			elsif ($oldformat[6] == 1) { $oldformat[6] = 'r'; }
		} elsif ($oldformat[7] eq 'inbox') { 
			$oldformat[7] = 'in';
			$touser = $builduser;
			$fromuser = $oldformat[0];
			if ($oldformat[6] == 1) { $oldformat[6] = 'u'; }
			elsif ($oldformat[6] == 2) { $oldformat[6] = 'r'; }
		} 
		push (@imstore, "$oldformat[4]|$fromuser|$touser|||$oldformat[1]|$oldformat[2]|$oldformat[3]|$oldformat[4]|0|$oldformat[5]|s|$oldformat[6]|$oldformat[7]|\n");
	}
	&write_DBorFILE(${$uid.$builduser}{'mysql'},OLDIMSTORE,$memberdir,$builduser,'imstore',@imstore);
	@imstore;
}

1;