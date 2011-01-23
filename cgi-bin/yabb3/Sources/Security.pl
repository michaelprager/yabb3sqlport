###############################################################################
# Security.pl                                                                 #
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

$securityplver = 'YaBB 3.0 Beta $Revision: 100 $';

# Updates profile with current IP, if changed from last IP.
# Will only actually update the file when .vars is being updated anyway to save extra load on server.
if (${$uid.$username}{'lastips'} !~ /^$user_ip\|/) {
	${$uid.$username}{'lastips'} = "$user_ip|${$uid.$username}{'lastips'}";
	${$uid.$username}{'lastips'} =~ s/^(.*?\|.*?\|.*?)\|.*/$1/;
}

$scripturl = "$boardurl/$yyexec.$yyext";
$adminurl  = "$boardurl/AdminIndex.$yyaext";

# BIG board check
if ($INFO{'board'}  =~ m~/~) { ($INFO{'board'},  $INFO{'start'}) = split('/', $INFO{'board'}); }
if ($INFO{'num'}    =~ m~/~) { ($INFO{'num'},    $INFO{'start'}) = split('/', $INFO{'num'}); }
if ($INFO{'letter'} =~ m~/~) { ($INFO{'letter'}, $INFO{'start'}) = split('/', $INFO{'letter'}); }
if ($INFO{'thread'} =~ m~/~) { ($INFO{'thread'}, $INFO{'start'}) = split('/', $INFO{'thread'}); }

# BIG thread check
$curnum = $INFO{'num'} || $INFO{'thread'} || $FORM{'threadid'};
if ($curnum ne '') {
	if ($curnum =~ /\D/) { &fatal_error("only_numbers_allowed","Thread ID: '$curnum'"); }
	if (!&checkfor_DBorFILE("$datadir/$curnum.txt")) {
		eval { require "$datadir/movedthreads.cgi" };
		&fatal_error("not_found","$datadir/$curnum.txt") if !$moved_file{$curnum};
		while (exists $moved_file{$curnum}) {
			$curnum = $moved_file{$curnum};
			next if exists $moved_file{$curnum};
			if (!&checkfor_DBorFILE("$datadir/$curnum.txt")) { &fatal_error("not_found","$datadir/$curnum.txt"); }
		}
		$INFO{'num'} = $INFO{'thread'} = $FORM{'threadid'} = $curnum;
	}

	&MessageTotals('load', $curnum);
	$currentboard = ${$curnum}{'board'};
} else {
	$currentboard = $INFO{'board'};
}

if ($currentboard ne '') {
	if ($currentboard !~ /\A[\s0-9A-Za-z#%+,-\.:=?@^_]+\Z/) { &fatal_error("invalid_character","$maintxt{'board'}"); }
	if (!&checkfor_DBorFILE("$boardsdir/$currentboard.txt")) { &fatal_error("cannot_open","$boardsdir/$currentboard.txt"); }
	($boardname, $boardperms, $boardview) = split(/\|/, $board{"$currentboard"});
	my $access = &AccessCheck($currentboard, '', $boardperms);
	if (!$iamadmin && $access ne "granted" && $boardview != 1) { &fatal_error("no_access"); }

	# Determine what category we are in.
	$catid = ${$uid.$currentboard}{'cat'};
	($cat, $catperms) = split(/\|/, $catinfo{"$catid"});
	$cataccess = &CatAccess($catperms);
	unless ($annboard ne "" && $currentboard eq $annboard) {
		if (!$cataccess) { &fatal_error("no_access"); }
	}

	$bdescrip = ${$uid.$currentboard}{'description'};

	# Create Hash %moderators and %moderatorgroups with all Moderators of the current board
	foreach (split(/, ?/, ${$uid.$currentboard}{'mods'})) {
		&LoadUser($_);
		$moderators{$_} = ${$uid.$_}{'realname'};
	}
	foreach (split(/, /, ${$uid.$currentboard}{'modgroups'})) {
		$moderatorgroups{$_} = $_;
	}

	if ($staff) {
		$iammod = &is_moderator($username,$currentboard);
		$staff = 0 if !$iammod && !$iamadmin && !$iamgmod;
	}

	unless ($iamadmin) {
		my $accesstype = "";
		if ($action eq "post") {
			if ($INFO{'title'} eq 'CreatePoll' || $INFO{'title'} eq 'AddPoll') {
				$accesstype = 3;    # Post Poll
			} elsif ($INFO{'num'}) {
				$accesstype = 2;    # Post Reply
			} else {
				$accesstype = 1;    # Post Thread
			}
		}
		my $access = &AccessCheck($currentboard, $accesstype);
		if ($access ne "granted") { &fatal_error("no_access"); }
	}

	foreach (&read_DBorFILE(0,'',$boardsdir,$currentboard,'txt')) {
		if ($_ =~ m~\A$curnum\|~o) { $yyThreadLine = $_; last; }
	}
	chomp $yyThreadLine;

} else {
	### BIG category check
	$currentcat = $INFO{'cat'} || $INFO{'catselect'};
	if ($currentcat ne '') {
		if ($currentcat =~ m~/~)  { &fatal_error("no_cat_slash"); }
		if ($currentcat =~ m~\\~) { &fatal_error("no_cat_backslash"); }
		if ($currentcat ne '' && $currentcat !~ /\A[\s0-9A-Za-z#%+,-\.:=?@^_]+\Z/) { &fatal_error("invalid_character","$maintxt{'cat'}"); }
		if (!$cat{$currentcat}) { &fatal_error("cannot_open","$currentcat"); }

		#  and need cataccess check!
		$cataccess = &CatAccess($catperms);
		if (!$cataccess) { &fatal_error("no_access"); }
	}
}

sub is_admin { if (!$iamadmin) { &fatal_error("no_access"); } }

sub is_admin_or_gmod {
	if (!$iamadmin && !$iamgmod) { &fatal_error("no_access"); }

	if ($iamgmod && $action ne "") {
		require "$vardir/gmodsettings.txt";
		if ($gmod_access{"$action"} ne "on" && $gmod_access2{"$action"} ne "on") {
			&fatal_error("no_access");
		}
	}
}

sub banning {
	my $ban_user   = $_[0] || $username;
	my $ban_email  = $_[1] || ${$uid.$username}{'email'};
	my $admincheck = $_[2];

	if (!$admincheck && $username eq "admin" && $iamadmin) { return; }

	foreach (split(/,/, $ip_banlist)) { # IP BANNING
		&write_banlog("$user_ip") if $user_ip =~ /^$_/;
	}
	if (!$iamguest || $action eq 'register2') {
		foreach (split(/,/, $email_banlist)) { # EMAIL BANNING
			&write_banlog("$_ ($user_ip)") if $ban_email =~ /$_/i;
		}
		foreach (split(/,/, $user_banlist)) { # USERNAME BANNING
			&write_banlog("$_ ($user_ip)") if $ban_user =~ m/^$_$/;
		}
	}

	sub write_banlog {
		&fatal_error("banned","$register_txt{'678'}$register_txt{'430'}!") if $admincheck;
		&write_DBorFILE(0,LOG,$vardir,'ban_log','txt',(&read_DBorFILE(0,LOG,$vardir,'ban_log','txt'),"$date|$_[0]\n"));
		&UpdateCookie("delete", $ban_user);
		$username = "Guest";
		$iamguest = 1;
		&fatal_error("banned","$security_txt{'678'}$security_txt{'430'}!");
	}
}

sub check_banlist {
	# &check_banlist("email","IP","username"); - will return true if banned by any means
	# This sub can be passed email address, IP, unencoded username or any combination thereof

	# Returns E if banned by email address
	# Returns I if banned by IP address
	# Returns U if banned by username
	# Returns all banning methods, unseperated (eg "EIU" if banned by all methods)

	my ($e_ban, $ip_ban, $u_ban) = @_;
	my $ban_rtn;

	if ($e_ban && $email_banlist) {
		foreach (split(/,/, $email_banlist)) { if ($_ eq $e_ban)  { $ban_rtn .= 'E'; last; } }
	}
	if ($ip_ban && $ip_banlist) {
		foreach (split(/,/, $ip_banlist))    { if ($_ eq $ip_ban) { $ban_rtn .= 'I'; last; } }
	}
	if ($u_ban && $user_banlist) {
		foreach (split(/,/, $user_banlist))  { if ($_ eq $u_ban)  { $ban_rtn .= 'U'; last; } }
	}

	$ban_rtn;
}

sub CheckIcon {
	# Check the icon so HTML cannot be exploited.
	$icon =~ s~\Ahttp://.*\/(.*?)\..*?\Z~$1~;
	$icon =~ s~[^A-Za-z]~~g;
	$icon =~ s~\\~~g;
	$icon =~ s~\/~~g;
	$icon = "xx" if $icon !~ /^(xx|thumbup|thumbdown|exclamation|no_postcount|question|lamp|smiley|angry|cheesy|grin|sadwink)$/;
}

sub AccessCheck {
	my ($curboard, $checktype, $boardperms) = @_;

	# Put whether it's a zero post count board in global variable
	# to save need to reopen file many times.
	unless (exists $memberunfo{$username}) { &LoadUser($username); }
	my $boardmod = 0;
	foreach $curuser (split(/, ?/, ${$uid.$curboard}{'mods'})) {
		if ($username eq $curuser) { $boardmod = 1; }
	}
	@board_modgrps = split(/, /, ${$uid.$curboard}{'modgroups'});
	@user_addgrps  = split(/,/, ${$uid.$username}{'addgroups'});
	foreach $curgroup (@board_modgrps) {
		if (${$uid.$username}{'position'} eq $curgroup) { $boardmod = 1; }
		foreach $curaddgroup (@user_addgrps) {
			if ($curaddgroup eq $curgroup) { $boardmod = 1; }
		}
	}
	$INFO{'zeropost'} = ${$uid.$curboard}{'zero'};
	if ($iamadmin) { $access = "granted"; return $access; }
	my ($viewperms, $topicperms, $replyperms, $pollperms, $attachperms);
	if ($username ne "Guest") {
		($viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, ${$uid.$username}{'perms'});
	}
	if ($username eq "Guest" && !$enable_guestposting) {
		$viewperms   = 0;
		$topicperms  = 1;
		$replyperms  = 1;
		$pollperms   = 1;
		$attachperms = 1;
	}
	my $access = "denied";
	if ($checktype == 1) {    # Post access check
		@allowed_groups = split(/, /, ${$uid.$curboard}{'topicperms'});
		if (${$uid.$curboard}{'topicperms'} eq "") { $access = "granted"; }
		if ($topicperms == 1) { $access = "notgranted"; }
	} elsif ($checktype == 2) {    # Reply access check
		if ($iamgmod || $boardmod) { $access = "granted"; }
		else {
			@allowed_groups = split(/, /, ${$uid.$curboard}{'replyperms'});
			if (${$uid.$curboard}{'replyperms'} eq "") { $access = "granted"; }
			if ($replyperms == 1 && !$topicstart{$username}) { $access = "notgranted"; }
		}
	} elsif ($checktype == 3) {    # Poll access check
		@allowed_groups = split(/, /, ${$uid.$curboard}{'pollperms'});
		if (${$uid.$curboard}{'pollperms'} eq "") { $access = "granted"; }
		if ($pollperms == 1) { $access = "notgranted"; }
	} elsif ($checktype == 4) {    # Attachment access check
		if (${$uid.$curboard}{'attperms'} == 1) { $access = "granted"; }
		if ($attachperms == 1) { $access = "notgranted"; }
	} else {                       # Board access check
		@allowed_groups = split(/, /, $boardperms);
		if ($boardperms eq "") { $access = "granted"; }
		if ($viewperms == 1) { $access = "notgranted"; }
	}

	# age and gender check
	unless ($iamadmin || $iamgmod || $boardmod) {
		if ((${$uid.$curboard}{'minageperms'} || ${$uid.$curboard}{'maxageperms'}) && (!$age || $age == 0)) {
			$access = "notgranted";
		} elsif (${$uid.$curboard}{'minageperms'} && $age < ${$uid.$curboard}{'minageperms'}) {
			$access = "notgranted";
		} elsif (${$uid.$curboard}{'maxageperms'} && $age > ${$uid.$curboard}{'maxageperms'}) {
			$access = "notgranted";
		}
		if (${$uid.$curboard}{'genderperms'} && !${$uid.$username}{'gender'}) {
			$access = "notgranted";
		} elsif (${$uid.$curboard}{'genderperms'} eq "M" && ${$uid.$username}{'gender'} eq "Female") {
			$access = "notgranted";
		} elsif (${$uid.$curboard}{'genderperms'} eq "F" && ${$uid.$username}{'gender'} eq "Male") {
			$access = "notgranted";
		}
	}
	unless ($access eq "granted" || $access eq "notgranted") {
		$memberinform = $memberunfo{$username};
		foreach $element (@allowed_groups) {
			chomp $element;
			if ($element eq $memberinform) { $access = "granted"; }
			foreach (split(/,/, $memberaddgroup{$username})) {
				if ($element eq $_) { $access = "granted"; last; }
			}
			if ($element eq $topicstart{$username}) { $access = "granted"; }
			if ($element eq "Global Moderator" && ($iamadmin || $iamgmod)) { $access = "granted"; }
			if ($element eq "Moderator" && ($iamadmin || $iamgmod || $boardmod)) { $access = "granted"; }
			if ($access eq "granted") { last; }
		}
	}

	$access;
}

sub CatAccess {
	my ($cataccess) = @_;
	if ($iamadmin || $cataccess eq "") { return 1; }

	my $access = 0;
	@allow_groups = split(/, /, $cataccess);
	unless (exists $memberunfo{$username}) { &LoadUser($username); }
	$memberinform = $memberunfo{$username};
	foreach $element (@allow_groups) {
		chomp $element;
		if ($element eq $memberinform) { $access = 1; }
		foreach (split(/,/, $memberaddgroup{$username})) {
			if ($element eq $_) { $access = 1; last; }
		}
		if ($element eq "Moderator" && ($iamgmod || exists $moderators{$username})) { $access = 1; }
		if ($element eq "Global Moderator" && $iamgmod) { $access = 1; }
		if ($access == 1) { last; }
	}
	$access;
}

sub email_domain_check {
	### Based upon Distilled Email Domains mod by AstroPilot ###
	my $checkdomain = $_[0];
	if ($checkdomain) {
		if (&checkfor_DBorFILE("$vardir/email_domain_filter.txt")) { require "$vardir/email_domain_filter.txt"; }
		if ($bdomains) {
			foreach (split (/,/, $bdomains)) {
				if ($_ !~ /\@/) {$_ = "\@$_";}
				elsif ($_ !~ /^\./) {$_ = ".$_";}
				&fatal_error("domain_not_allowed","$_") if $checkdomain =~ m/$_/i;
			}
		}
	}
	### Distilled Email Domains mod end ###
}

1;