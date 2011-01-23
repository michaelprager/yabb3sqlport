###############################################################################
# UserSelect.pl                                                               #
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

$userselectplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

if ($iamguest && $INFO{'toid'} ne "userspec" && $action ne "checkavail") { &fatal_error("members_only"); }
&LoadLanguage('UserSelect');

$MembersPerPage = 10;

sub FindMem {
	if (&checkfor_DBorFILE("$memberdir/$username.usctmp")) { &delete_DBorFILE("$memberdir/$username.usctmp"); }

	$SearchStr = $FORM{'member'};

	if ($SearchStr eq "" || $SearchStr eq "*") {
		$INFO{'sort'} = "username";
		$INFO{'start'} = 0;
	} elsif($SearchStr =~ /\*/) {
		$SearchStr =~ s/\*+/\*/g;
		if($SearchStr =~ /\*\$/) {
			$SearchStr = substr($SearchStr,0,length($SearchStr)-1);
			$LookFor = qq~\^$SearchStr~;
		} elsif($SearchStr =~ /^\*/) {
			$SearchStr = substr($SearchStr,1);
			$LookFor = qq~$SearchStr\$~;
		} else {
			($before, $after) = split(/\*/,$SearchStr);
			$LookFor = qq~\^($before).*?($after)\$~;
		}
	} else {
		$LookFor = qq~\^$SearchStr\$~;
	}

	&MemberList;
}

sub MemberList {
	if ($iamguest && $INFO{'toid'} ne "userspec") { &fatal_error("members_only"); }

	if (&checkfor_DBorFILE("$memberdir/$username.usctmp") && $INFO{'sort'} ne "pmsearch") { &delete_DBorFILE("$memberdir/$username.usctmp"); }

	if ($INFO{'start'} eq '') { $start = 0; }
	else { $start = $INFO{'start'}; }

	$to_id = $INFO{'toid'};
	$radiobuttons = '';
	my($tosel, $ccsel, $bccsel);
	if ($to_id =~ /toshow/) {
		$page_title = qq~$usersel_txt{'pmpagetitle'}~;
		$instruct_start = qq~$usersel_txt{'instruct'}~;
		$instruct_end = qq~$usersel_txt{'reciepientlist'}~;

		if ($to_id eq 'toshowcc') { $ccsel = qq~ checked="checked"~; }
		elsif ($to_id eq 'toshowbcc') { $bccsel = qq~ checked="checked"~; }
		else { $tosel = qq~ checked="checked"~; }
		if ($PMenable_cc || $PMenable_bcc) {
			$radiobuttons = qq~
			<div class="small" style="float: left; width: 50%; padding-bottom: 3px;">
			<input type="radio" name="selreciepients" id="toshow" value="toshow" class="windowbg" style="border: 0px; vertical-align: middle;" onclick="location.href='$scripturl?action=imlist;sort=$INFO{'sort'};toid=toshow;start=$start;letter=$INFO{'letter'}';"$tosel /><label for="toshow" class="small">$usersel_txt{'pmto'}</label>
			~;
			if ($PMenable_cc) {
				$radiobuttons .= qq~
				<input type="radio" name="selreciepients" id="toshowcc" value="toshowcc" class="windowbg" style="border: 0px; vertical-align: middle;" onclick="location.href='$scripturl?action=imlist;sort=$INFO{'sort'};toid=toshowcc;start=$start;letter=$INFO{'letter'}';"$ccsel /><label for="toshowcc" class="small">$usersel_txt{'pmcc'}</label>
				~;
			}
			if ($PMenable_bcc) {
				$radiobuttons .= qq~
				<input type="radio" name="selreciepients" id="toshowpmbcc" value="toshowbcc" class="windowbg" style="border: 0px; vertical-align: middle;" onclick="location.href='$scripturl?action=imlist;sort=$INFO{'sort'};toid=toshowbcc;start=$start;letter=$INFO{'letter'}';"$bccsel /><label for="toshowpmbcc" class="small">$usersel_txt{'pmbcc'}</label>
				~;
			}
			$radiobuttons .= qq~
			</div>
			~;
		}
	}
	if ($to_id =~ /moderators\d/) {
		$page_title = qq~$usersel_txt{'modpagetitle'}~;
		$instruct_start = qq~$usersel_txt{'instruct'}~;
		$instruct_end = qq~$usersel_txt{'moderatorlist'}~;
	}
	if ($to_id =~ /ignore/) {
		$page_title = qq~$usersel_txt{'ignorepagetitle'}~;
		$instruct_start = qq~$usersel_txt{'instruct'}~;
		$instruct_end = qq~$usersel_txt{'ignorelist'}~;
	}
	if ($to_id =~ /userspec/) {
		$page_title = qq~$usersel_txt{'searchpagetitle'}~;
		$instruct_start = qq~$usersel_txt{'instruct1'}~;
		$instruct_end = qq~$usersel_txt{'searchlist'}~;
	}
	if ($to_id =~ /buddylist/) {
		$page_title = qq~$usersel_txt{'buddypagetitle'}~;
		$instruct_start = qq~$usersel_txt{'instruct'}~;
		$instruct_end = qq~$usersel_txt{'buddylist'}~;
	}
	if ($to_id =~ /groups/) {
		$page_title = qq~$usersel_txt{'grouppagetitle'}~;
		$instruct_start = qq~$usersel_txt{'instruct'}~;
		$instruct_end = qq~$usersel_txt{'groups'}~;
	}
	$page     = "a";
	$showpage = "A";

	while ($page ne "z") {
		if($INFO{'letter'} && $page eq $INFO{'letter'}) {
			$LetterLinks .= qq~<div style="float: left; width: 11px; text-align: center; border: 1px #ffffff solid;"><span class="small"><b>$showpage</b></span></div>~;
		}
		else {
			$LetterLinks .= qq~<div style="float: left; width: 13px; text-align: center; margin-top: 1px; margin-bottom: 1px;"><a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$page"><span class="small"><b>$showpage</b></span></a></div>~;
		}
		$page++;
		$showpage++;
	}
	if($INFO{'letter'} && $INFO{'letter'} eq "z") {
		$LetterLinks .= qq~<div style="float: left; width: 11px; text-align: center; border: 1px #ffffff solid;"><span class="small"><b>Z</b></span></div>~;
	}
	else {
		$LetterLinks .= qq~<div style="float: left; width: 13px; text-align: center; margin-top: 1px; margin-bottom: 1px;"><a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=z"><span class="small"><b>Z</b></span></a></div>~;
	}
	if($INFO{'letter'} && $INFO{'letter'} eq "other") {
		$LetterLinks .= qq~<div style="float: left; text-align: center; border: 1px #ffffff solid; padding-left: 2px; padding-right: 2px;"><span class="small"><b>$usersel_txt{'other'}</b></span></div>~;
	}
	else {
		$LetterLinks .= qq~<div style="float: left; text-align: center; padding-left: 2px; padding-right: 2px; margin-top: 1px; margin-bottom: 1px;"><a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=other"><span class="small"><b>$usersel_txt{'other'}</b></span></a></div>~;
	}

	if ($INFO{'sort'} eq "pmsearch") {
		if($INFO{'letter'} && $INFO{'letter'} eq "all") {
			$LetterLinks .= qq~<div style="float: left; text-align: center; border: 1px #ffffff solid; padding-left: 2px; padding-right: 2px;"><span class="small"><b>$usersel_txt{'allsearch'}</b></span></div>~;
		}
		else {
			$LetterLinks .= qq~<div style="float: left; text-align: center; padding-left: 2px; padding-right: 2px; margin-top: 1px; margin-bottom: 1px;"><a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=all"><span class="small"><b>$usersel_txt{'allsearch'}</b></span></a></div>~;
		}
	}
	if ($to_id eq 'groups') { $LetterLinks = ''; } 
	unless ($INFO{'letter'} eq 'all') { $letter = lc($INFO{'letter'}); }

	$i = 0;
	$recent_exist = 1;
	@recentUsers = ();

	if ($to_id =~ /toshow/ || $to_id =~ /buddylist/ || $to_id =~ /ignore/) { 
		&loadRecentPMs;
	}
	if (!@recentUsers) {
		$recent_exist = 0;
		if ($INFO{'sort'} eq "recentpm") { $INFO{'sort'} = "username"; }
	}
	$myRealname = ${$uid.$username}{'realname'};
	$myEmail = ${$uid.$username}{'email'};
	if ($INFO{'sort'} eq 'recentpm') {
		foreach (@recentUsers) {
			&LoadUser($_);
			$memberinf{$_} = qq~${$uid.$_}{'regtime'}|${$uid.$_}{'realname'}|${$uid.$_}{'email'}~;
		}

	} elsif ($INFO{'sort'} eq 'pmsearch') {
		if (!&checkfor_DBorFILE("$memberdir/$username.usctmp")) {
			&ManageMemberinfo("load");
			my ($membername, $mregdate, $memrealname, $mememail);
			&read_DBorFILE(0,FILE,$memberdir,$username,'usctmp');
			foreach $membername (sort { lc $memberinf{$a} cmp lc $memberinf{$b} } keys %memberinf) {
				($mregdate, $memrealname, $mememail, undef) = split(/\|/, $memberinf{$membername}, 4);
				## don't find own name - unless for search or board mods!
				if ($to_id !~ /moderators\d/ && $to_id !~ /userspec/) {
					if ($memrealname =~ /$LookFor/ig && $membername ne $username  ) {
						print FILE "$membername,$mregdate|$memrealname|$mememail\n";
					} elsif($mememail =~ /$LookFor/ig && $membername ne $username) {
						print FILE "$membername,$mregdate|$memrealname|$mememail\n";
					}
				} else {
					if ($memrealname =~ /$LookFor/ig) {
						print FILE "$membername,$mregdate|$memrealname|$mememail\n";
					} elsif($mememail =~ /$LookFor/ig) {
						print FILE "$membername,$mregdate|$memrealname|$mememail\n";
					}
				}
			}
			&write_DBorFILE(0,FILE,$memberdir,$username,'usctmp',(''));
			undef %memberinf;
		}
		foreach my $line (&read_DBorFILE(0,'',$memberdir,$username,'usctmp')) {
			chomp $line;
			($recentname, $realinfo) = split(/,/, $line);
			$memberinf{$recentname} = $realinfo;
		}

	} elsif ($to_id eq 'groups') {
		$ToShow[0] = 'bmallmembers';
		$ToShow[1] = '';
		$ToShow[2] = 'bmadmins';
		$ToShow[3] = 'bmgmods'; 
		$ToShow[4] = 'bmmods';
		$ToShow[5] = '';
		my $x = 6;
		foreach (@nopostorder) {
			$ToShow[$x] = $_;
			$x++;
		}

	} elsif ($INFO{'sort'} eq "mlletter" || $INFO{'sort'} eq "username") {
		&ManageMemberinfo("load");
	}

	if ($INFO{'sort'} eq "recentpm") { $selRecent = qq~class="windowbg"~; }
	else { $selRecent = qq~class="windowbg2"~; }
	if ($INFO{'sort'} eq "mlletter" || $INFO{'sort'} eq "username") { $selUser = qq~class="windowbg"~; }
	else { $selUser = qq~class="windowbg2"~; }

	unless (($to_id =~ /toshow/ && (!$PM_level || ($PM_level == 2 && !$staff) || ($PM_level == 3 && !$iamadmin && !$iamgmod))) or ($to_id =~ /userspec/ && (($ML_Allowed == 1 && $iamguest) || ($ML_Allowed == 2 && !$staff) || ($ML_Allowed == 3 && !$iamadmin && !$iamgmod)))) {
		foreach my $membername (sort { lc $memberinf{$a} cmp lc $memberinf{$b} } keys %memberinf) {
			if ($to_id =~ /toshow/) {
				if ($PM_level == 2) { &CheckUserPM_Level($membername); next if $UserPM_Level{$membername} < 2; }
				elsif ($PM_level == 3) { &CheckUserPM_Level($membername); next if $UserPM_Level{$membername} != 3; }
			}
			(undef, $memrealname, $mememail, undef) = split(/\|/, $memberinf{$membername}, 4);
			if ($letter) {
				$SearchName = lc(substr($memrealname, 0, 1));
				if ($SearchName eq $letter && ($membername ne $username || ($to_id =~ /moderators\d/ || $to_id =~ /userspec/))) { $ToShow[$i] = $membername; }
				elsif ($letter eq "other" && (($SearchName lt "a") || ($SearchName gt "z")) && ($membername ne $username || ($to_id =~ /moderators\d/ || $to_id =~ /userspec/))) { $ToShow[$i] = $membername; }
			} else {
				if ($to_id =~ /moderators\d/ || $to_id =~ /userspec/) { $ToShow[$i] = $membername; }
				elsif ($membername ne $username) { $ToShow[$i] = $membername; }

			}
			$i++ if $ToShow[$i];
		}
		undef %UserPM_Level;
	}
	undef %memberinf;

	$memcount = @ToShow;
	if($memcount < $MembersPerPage) { $MembersPerPage = $memcount; }
	if (!$memcount && $letter) {
		$pageindex = "";
	} else {
		&buildIndex;
	}
	&buildPages(1);
	$b = $start;
	$numshown = 0;
	$yymain .= qq~
	<tr><td height="156" class="windowbg">
	~;

	if ($memcount) {
		$yymain .= qq~
			$radiobuttons
		~;
		if ($to_id =~ /userspec/) {
		$yymain .= qq~
			<select name="rec_list" id="rec_list" size="10" style="width: 456px; font-size: 11px; font-weight: bold;" ondblclick="copy_option('$to_id')">\n
		~;
		} else {
		$yymain .= qq~
			<select name="rec_list" id="rec_list" multiple="multiple" size="10" style="width: 456px; font-size: 11px; font-weight: bold;" ondblclick="copy_option('$to_id')">\n
		~;
		}
		while ($numshown < $MembersPerPage) {
			$user = $ToShow[$b];
			if ($to_id ne 'groups') {
				my $cloakedUserName;
				if ($user ne '') {
					$color = '';
					$colorstyle = qq~ style="font-weight: bold;~;
					!${$uid.$user}{'password'} ? &LoadUser($user) : &LoadMiniUser($user);
					if ($color) { $colorstyle .= qq~ color: $color;~; }
					$colorstyle .= qq~"~;
					if (${$uid.$user}{'realname'} eq "") { ${$uid.$user}{'realname'} = $user; }
					if ($do_scramble_id) { $cloakedUserName = &cloak($user); } else { $cloakedUserName = $user; }
					$yymain .= qq~<option value="$cloakedUserName"$colorstyle>${$uid.$user}{'realname'}</option>\n~;
				}
			} else {
				my $groupName = '';
				my $groupdisabled = '';
				if ($user ne '') { 
					$groupName = $usersel_txt{$user};
					if ($groupName eq '') { $groupName = (split /\|/, $NoPost{$user})[0]; }
					$user = $user eq 'bmallmembers' ? 'all' : ($user eq 'bmadmins' ? 'admins' : ($user eq 'bmgmods' ? 'gmods' : ($user eq 'bmmods' ? 'mods' : $user)));
					$yymain .= qq~<option value="$user">$groupName</option>\n~;
				} else {
					$groupName = qq~-------~;
					$yymain .= qq~<optgroup label="$groupName"></optgroup>\n~;
				}
			}
			$numshown++;
			$b++;
		}
		$yymain .= qq~
		</select>\n
		<input type="button" class="button" onclick="copy_option('$to_id')" value="$usersel_txt{'addselected'}" style="width: 228px;" /><input type="button" class="button" onclick="window.close()" value="$usersel_txt{'pageclose'}" style="width: 228px;" />
		~;

	} else {
		$yymain .= qq~
		<div style="float: left; width: 456px; height: 139px;">
		<br /><br />
		~;
		if ($letter) {
			$yymain .= qq~<center><b>$usersel_txt{'noentries'}</b><br /></center>~;
		}
		elsif ($INFO{'sort'} eq "pmsearch") {
			$yymain .= qq~<center><b>$usersel_txt{'nofound'} <i>$SearchStr</i></b></center>~;
		}
		$yymain .= qq~
		</div>
		<input type="button" class="button" onclick="window.close()" value="$usersel_txt{'pageclose'}" style="width: 456px;" />
		~;
	}

	$yymain .= qq~
	</td></tr>
	~;

	undef @ToShow;
	&buildPages(0);
	$yytitle = $page_title;
	&userselectTemplate;
}

sub buildIndex {
	unless ($memcount == 0) {
		if (!$iamguest) {
			(undef, undef, $usermemberpage, undef) = split(/\|/, ${$uid.$username}{'pageindex'}, 4);
		}
		my ($pagetxtindex, $pagetextindex, $pagedropindex, $all, $allselected);
		$indexdisplaynum = 3;
		$dropdisplaynum  = 10;
		if ($FORM{'sortform'} eq "") { $FORM{'sortform'} = $INFO{'sort'}; }
		$postdisplaynum = 3;
		$startpage      = 0;
		$max            = $memcount;
		if ($INFO{'start'} eq "all") { $MembersPerPage = $max; $all = 1; $allselected = qq~ selected="selected"~; $start = 0 }
		else { $start = $INFO{'start'} || 0; }
		$start    = $start > $memcount - 1 ? $memcount - 1 : $start;
		$start    = (int($start / $MembersPerPage)) * $MembersPerPage;
		$tmpa     = 1;
		$pagenumb = int(($memcount - 1) / $MembersPerPage) + 1;

		if ($start >= (($postdisplaynum - 1) * $MembersPerPage)) {
			$startpage = $start - (($postdisplaynum - 1) * $MembersPerPage);
			$tmpa = int($startpage / $MembersPerPage) + 1;
		}
		if ($memcount >= $start + ($postdisplaynum * $MembersPerPage)) { $endpage = $start + ($postdisplaynum * $MembersPerPage); }
		else { $endpage = $memcount }
		$lastpn     = int(($memcount - 1) / $MembersPerPage) + 1;
		$lastptn    = ($lastpn - 1) * $MembersPerPage;
		$pageindex = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;">$usersel_txt{'pages'}: $pagenumb</span>~;
		if ($pagenumb > 1 || $all) {
			if ($usermemberpage == 1 || $iamguest) {
				$pagetxtindexst = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;">~;
				$pagetxtindexst .= qq~ $usersel_txt{'pages'}: ~;
				if ($startpage > 0) { $pagetxtindex = qq~<a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter" style="font-weight: normal;">1</a>&nbsp;...&nbsp;~; }
				if ($startpage == $MembersPerPage) { $pagetxtindex = qq~<a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter" style="font-weight: normal;">1</a>&nbsp;~; }
				for ($counter = $startpage; $counter < $endpage; $counter += $MembersPerPage) {
					$pagetxtindex .= $start == $counter ? qq~<b>$tmpa</b>&nbsp;~ : qq~<a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=$counter" style="font-weight: normal;">$tmpa</a>&nbsp;~;
					$tmpa++;
				}
				if ($endpage < $memcount - $MembersPerPage) { $pageindexadd = qq~...&nbsp;~; }
				if ($endpage != $memcount) { $pageindexadd .= qq~<a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=$lastptn" style="font-weight: normal;">$lastpn</a>~; }
				$pagetxtindex .= qq~$pageindexadd~;
				$pageindex = qq~$pagetxtindexst$pagetxtindex</span>~;
			} else {
				$pagedropindex = qq~<div style="float: left; width: 456px; height: 21px; margin: 0px; margin-top: 2px; border: 0px;">~;
				$tstart = $start;
				if (substr($INFO{'start'}, 0, 3) eq "all") { ($tstart, $start) = split(/\-/, $INFO{'start'}); }
				$d_indexpages = $pagenumb / $dropdisplaynum;
				$i_indexpages = int($pagenumb / $dropdisplaynum);
				if ($d_indexpages > $i_indexpages) { $indexpages = int($pagenumb / $dropdisplaynum) + 1; }
				else { $indexpages = int($pagenumb / $dropdisplaynum) }
				$selectedindex = int(($start / $MembersPerPage) / $dropdisplaynum);

				if ($pagenumb > $dropdisplaynum) {
					$pagedropindex .= qq~<div style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector" id="decselector" style="font-size: 9px; border: 2px inset;" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
				}
				for ($i = 0; $i < $indexpages; $i++) {
					$indexpage  = ($i * $dropdisplaynum) * $MembersPerPage;
					$indexstart = ($i * $dropdisplaynum) + 1;
					$indexend   = $indexstart + ($dropdisplaynum - 1);
					if ($indexend > $pagenumb)    { $indexend   = $pagenumb; }
					if ($indexstart == $indexend) { $indxoption = qq~$indexstart~; }
					else { $indxoption = qq~$indexstart-$indexend~; }
					$selected = "";
					if ($i == $selectedindex) {
						$selected    = qq~ selected="selected"~;
						$pagejsindex = qq~$indexstart|$indexend|$MembersPerPage|$indexpage~;
					}
					if ($pagenumb > $dropdisplaynum) {
						$pagedropindex .= qq~<option value="$indexstart|$indexend|$MembersPerPage|$indexpage"$selected>$indxoption</option>\n~;
					}
				}
				if ($pagenumb > $dropdisplaynum) {
					$pagedropindex .= qq~</select>\n</div>~;
				}
				$pagedropindex .= qq~<div id="ViewIndex" class="droppageindex" style="height: 14px; visibility: hidden">&nbsp;</div>~;
				$tmpMembersPerPage = $MembersPerPage;
				if (substr($INFO{'start'}, 0, 3) eq "all") { $MembersPerPage = $MembersPerPage * $dropdisplaynum; }
				$prevpage = $start - $tmpMembersPerPage;
				$nextpage = $start + $MembersPerPage;
				$pagedropindexpvbl = qq~<img src="$imagesdir/index_left0.gif" height="14" width="13" border="0" alt="" style="margin: 0px; display: inline; vertical-align: middle;" />~;
				$pagedropindexnxbl = qq~<img src="$imagesdir/index_right0.gif" height="14" width="13" border="0" alt="" style="margin: 0px; display: inline; vertical-align: middle;" />~;
				if ($start < $MembersPerPage) { $pagedropindexpv .= qq~<img src="$imagesdir/index_left0.gif" height="14" width="13" border="0" alt="" style="display: inline; vertical-align: middle;" />~; }
				else { $pagedropindexpv .= qq~<img src="$imagesdir/index_left.gif" border="0" height="14" width="13" alt="$pidtxt{'02'}" title="$pidtxt{'02'}" style="display: inline; vertical-align: middle; cursor: pointer;" onclick="location.href=\\'$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=$prevpage\\'" ondblclick="location.href=\\'$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=0\\'" />~; }
				if ($nextpage > $lastptn) { $pagedropindexnx .= qq~<img src="$imagesdir/index_right0.gif" border="0" height="14" width="13" alt="" style="display: inline; vertical-align: middle;" />~; }
				else { $pagedropindexnx .= qq~<img src="$imagesdir/index_right.gif" height="14" width="13" border="0" alt="$pidtxt{'03'}" title="$pidtxt{'03'}" style="display: inline; vertical-align: middle; cursor: pointer;" onclick="location.href=\\'$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=$nextpage\\'" ondblclick="location.href=\\'$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=$lastptn\\'" />~; }
				$pageindex = qq~$pagedropindex</div>~;

				$pageindexjs = qq~
<script language="JavaScript1.2" type="text/javascript">
<!-- 
	function SelDec(decparam, visel) {
		splitparam = decparam.split("|");
		var vistart = parseInt(splitparam[0]);
		var viend = parseInt(splitparam[1]);
		var maxpag = parseInt(splitparam[2]);
		var pagstart = parseInt(splitparam[3]);
		var allpagstart = parseInt(splitparam[3]);
		if(visel == 'xx' && decparam == '$pagejsindex') visel = '$tstart';
		var pagedropindex = '<table border="0" cellpadding="0" cellspacing="0"><tr>';
		for(i=vistart; i<=viend; i++) {
			if(visel == pagstart) pagedropindex += '<td class="titlebg" height="14" style="height: 14px; padding-left: 1px; padding-right: 1px; font-size: 9px; font-weight: bold;">' + i + '<\/td>';
			else pagedropindex += '<td height="14" class="droppages" style="height: 14px;"><a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=' + pagstart + '">' + i + '<\/a><\/td>';
			pagstart += maxpag;
		}
		~;
		if ($showpageall) {
			$pageindexjs .= qq~
			if (vistart != viend) {
				if(visel == 'all') pagedropindex += '<td class="titlebg" height="14" style="height: 14px; padding-left: 1px; padding-right: 1px; font-size: 9px; font-weight: normal;"><b>$pidtxt{"01"}<\/b><\/td>';
				else pagedropindex += '<td height="14" class="droppages" style="height: 14px;"><a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=all-' + allpagstart + '">$pidtxt{"01"}<\/a><\/td>';
			}
			~;
		}
		$pageindexjs .= qq~
		if(visel != 'xx') pagedropindex += '<td height="14" class="small" style="height: 14px; padding-left: 4px;">$pagedropindexpv$pagedropindexnx<\/td>';
		else pagedropindex += '<td height="14" class="small" style="height: 14px; padding-left: 4px;">$pagedropindexpvbl$pagedropindexnxbl<\/td>';
		pagedropindex += '<\/tr><\/table>';
		document.getElementById("ViewIndex").innerHTML=pagedropindex;
		document.getElementById("ViewIndex").style.visibility = "visible";
		~;
				if ($pagenumb > $dropdisplaynum) {
					$pageindexjs .= qq~
		document.getElementById("decselector").value = decparam;
		~;
				}
				$pageindexjs .= qq~
	}
	document.onload = SelDec('$pagejsindex', '$tstart');
	//-->
</script>
~;
			}
		}
	}

}

sub buildPages {
	if ($to_id eq 'groups') { $instructtext = $usersel_txt{'instruct4'}; }
	else { $instructtext = qq~<label for="member">$usersel_txt{'instruct2'}</label>~ ; }
	$TableHeader .= qq~
		<tr>
			<td class="titlebg" align="left" valign="middle">
			<div class="small" style="float: left; width: 258px; padding-top: 3px;">
				$instructtext
			</div>
			<div class="small" style="float: left; width: 198px; text-align: right;">
			~;
	unless ($to_id eq 'groups') {
		$TableHeader .= qq~
			<form action="$scripturl?action=findmember;sort=pmsearch;toid=$to_id" method="post" id="form1" name="form1" enctype="application/x-www-form-urlencoded" style="display:inline; vertical-align:middle;">
				<input type="text" name="member" id="member" value="$usersel_txt{'wildcardinfo'}" onfocus="this.value=''" style="font-size: 11px; width: 140px" />
				<input name="submit" type="submit" class="button" style="font-size: 10px;" value="$usersel_txt{'gobutton'}" />
			</form>~;
	}
	$TableHeader .= qq~
			</div>
			</td>
		</tr>
	</table>
	<form method="post" action="" name="selectuser">
	<table border="0" width="464" cellspacing="1" cellpadding="3" class="bordercolor" style="height: 275px; table-layout: fixed;">
		<tr>
			<td class="catbg" align="center">
	~;
	if ($recent_exist && $to_id =~ /toshow/) {
		$TableHeader .= qq~
			<div $selRecent onclick="location.href='$scripturl?action=imlist;sort=recentpm;toid=$to_id';" style="float: left; width: 226px; text-align: center; padding-top: 2px; padding-bottom: 2px; border: 1px; border-style: outset; cursor: pointer;"><b>$usersel_txt{'recentlist'}</b></div>
			<div $selUser onclick="location.href='$scripturl?action=imlist;sort=username;toid=$to_id';" style="float: left; width: 226px; text-align: center; padding-top: 2px; padding-bottom: 2px; border: 1px; border-style: outset; cursor: pointer;"><b>$usersel_txt{'alllist'}</b></div>
		~;
	}
	elsif ($to_id ne 'groups') {
		$TableHeader .= qq~
			<div $selUser onclick="location.href='$scripturl?action=imlist;sort=username;toid=$to_id';" style="float: left; width: 454px; text-align: center; padding-top: 2px; padding-bottom: 2px; border: 1px; border-style: outset; cursor: pointer;"><b>$usersel_txt{'alllist'}</b></div>
		~;
	}
	elsif ($to_id eq 'groups') {
		$TableHeader .= qq~
			<div $selUser onclick="location.href='$scripturl?action=imlist;sort=username;toid=$to_id';" style="float: left; width: 454px; text-align: center; padding-top: 2px; padding-bottom: 2px; border: 1px; border-style: outset; cursor: pointer;"><b>$usersel_txt{'groups'}</b></div>
		~;
		}
	$TableHeader .= qq~
			</td>
		</tr>
	~;
	if ($LetterLinks ne "") {
		$TableHeader .= qq~
		<tr>
			<td class="titlebg">$LetterLinks</td>
		</tr>
		~;
	}
	$numbegin = ($start + 1);
	$numend = ($start + $MembersPerPage);
	if ($numend > $memcount) { $numend  = $memcount; }
	if ($memcount == 0) { $numshow = ''; }
	else { $numshow = qq~($numbegin - $numend $usersel_txt{'of'} $memcount)~; }

	if ($_[0]) {
		$yymain .= qq~
	<table border="0" width="464" cellspacing="1" cellpadding="3" class="bordercolor" style="table-layout: fixed;">
		$TableHeader
		<tr>
		<td class="catbg" width="100%" height="26" align="left" valign="middle">
		$pageindex
		</td>
		</tr>
		~;
	} else {
		$yymain .= qq~
		<tr>
			<td class="windowbg2" height="62" align="left" valign="middle">
			<span class="small">
			$instruct_start $instruct_end
			<br />
		~;

		unless ($to_id eq 'groups') {
			$usersel_txt{'instruct3'}
		}

		$yymain .= qq~
			</span>
			</td>
		</tr>
	</table>
	</form>
	$pageindexjs
		~;
	}
}

sub userselectTemplate {
	&print_output_header;

	$output = qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$yytitle</title>
<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />
<link rel="stylesheet" href="$forumstylesurl/$usestyle.css" type="text/css" />
<script language="JavaScript1.2" src="$yyhtml_root/ajax.js" type="text/javascript"></script>
<script language="JavaScript1.2" type="text/javascript">
<!--
var scripturl = '$scripturl';
var noresults = '$usersel_txt{'noresults'}';
var imageurl = '$imagesdir';

function copy_option(to_select) {
	if (to_select == 'groups') { to_select = 'toshow'; var groupflag = true; }
	if (to_select == 'userspec') {
		opener.document.getElementById(to_select).value = document.selectuser.rec_list.options[document.selectuser.rec_list.selectedIndex].value;
		opener.document.getElementById('userspectext').value = document.selectuser.rec_list.options[document.selectuser.rec_list.selectedIndex].text;
		opener.document.getElementById('usrsel').style.display = 'none';
		opener.document.getElementById('usrrem').style.display = 'inline';
		opener.document.getElementById('searchme').disabled = true;
		window.close();
		return;
	}
	var to_array = new Array();
	var tmp_array = new Array();
	var from_select = 'rec_list';
	var z = 0;
	var pmtoshow = false;
	var alt_select1 = '';
	var alt_select2 = '';
	opener.document.getElementById(to_select).style.display = 'inline';
	if (to_select == 'toshow' || to_select == 'toshowcc' || to_select == 'toshowbcc'  || to_select == 'groups') {
~;

	if ($to_id ne 'groups') {
		if ($PMenable_cc && $PMenable_bcc) {
			$output .= qq~
			alt_select1 = 'toshowcc'; alt_select2 = 'toshowbcc'; pmtoshow = true;
			if (to_select == 'toshowcc') { alt_select1 = 'toshow'; alt_select2 = 'toshowbcc'; }
			if (to_select == 'toshowbcc') { alt_select1 = 'toshow'; alt_select2 = 'toshowcc'; }
			~;
		} elsif ($PMenable_cc) {
			$output .= qq~
			alt_select1 = 'toshowcc'; pmtoshow = true;
			if (to_select == 'toshowcc') { alt_select1 = 'toshow'; pmtoshow = true; }
			~;
		} elsif ($PMenable_bcc) {
			$output .= qq~
			alt_select1 = 'toshowbcc'; pmtoshow = true;
			if (to_select == 'toshowbcc') { alt_select1 = 'toshow'; pmtoshow = true; }
			~;
		}
	}

	$output .= qq~
	}
	if (pmtoshow) {
		for (j = 0; j < document.getElementById(from_select).options.length; j++) {
			if (document.getElementById(from_select).options[j].selected) {
				for (x = 0; x < opener.document.getElementById(alt_select1).options.length; x++) {
					if (document.getElementById(from_select).options[j].text == opener.document.getElementById(alt_select1).options[x].text) document.getElementById(from_select).options[j].selected = false;
				}
				if (alt_select2 > '')	{
					for (y = 0; y < opener.document.getElementById(alt_select2).options.length; y++) {
						if (document.getElementById(from_select).options[j].text == opener.document.getElementById(alt_select2).options[y].text) document.getElementById(from_select).options[j].selected = false;
					}
				}
			}
		}
	}
	for(i = 0; i < opener.document.getElementById(to_select).options.length; i++) {
		keep_this = true;
		for(j = 0; j < document.getElementById(from_select).options.length; j++) {
		if(document.getElementById(from_select).options[j].selected) {
			if(document.getElementById(from_select).options[j].text == opener.document.getElementById(to_select).options[i].text) keep_this = false;
		}
		}
		if(keep_this) {
			tmp_array[opener.document.getElementById(to_select).options[i].text] = opener.document.getElementById(to_select).options[i].value;
			to_array[z] = opener.document.getElementById(to_select).options[i].text;
			z++;
		}
	}
	var from_length = 0;
	var to_length = to_array.length;
	for(i = 0; i < document.getElementById(from_select).options.length; i++) {
		tmp_array[document.getElementById(from_select).options[i].text] = document.getElementById(from_select).options[i].value;
		if(document.getElementById(from_select).options[i].selected && document.getElementById(from_select).options[i].value != "") {
			to_array[to_length] = document.getElementById(from_select).options[i].text;
			to_length++;
		}
	}
	opener.document.getElementById(to_select).length = 0;
	to_array.sort();
	for(i = 0; i < to_array.length; i++) {
		var tmp_option = opener.document.createElement("option");
		opener.document.getElementById(to_select).appendChild(tmp_option);
		tmp_option.value = tmp_array[to_array[i]];
		tmp_option.text = to_array[i];
	}
}
// -->
</script>
</head>
<body class="windowbg" style="margin: 0px; padding: 0px;">
$yymain
</body>
</html>~;

	$addsession = qq~<input type="hidden" name="formsession" value="$formsession" /></form>~;
	$output =~ s~</form>~$addsession~g;

	&print_HTML_output_and_finish;
}

sub loadRecentPMs {
	my ($pack, $file, $line) = caller;
	$yytrace .= qq~<br>loadrecentpms from ($pack, $file, $line)<br />=========================~;

	## put simple, this reads the msg , outbox and storage files to
	## harvest already-used membernames
	my (@userinbox, @useroutbox, @userstore, @usermessages);
	if (&checkfor_DBorFILE("$memberdir/$username.msg")) {
		@userinbox = &read_DBorFILE(0,'',$memberdir,$username,'msg');
		if (@userinbox) { push(@usermessages, @userinbox); }
		undef @userinbox;
	}
	if (&checkfor_DBorFILE("$memberdir/$username.outbox")) {
		@useroutbox = &read_DBorFILE(0,'',$memberdir,$username,'outbox');
		if (@useroutbox) { push(@usermessages, @useroutbox); }
		undef @useroutbox;
	}
	if (&checkfor_DBorFILE("$memberdir/$username.imstore")) {
		@userstore = &read_DBorFILE(0,'',$memberdir,$username,'imstore');
		if (@userstore) { push(@usermessages, @userstore); }
		undef @userstore;
	}
	if (!@usermessages) { return; }
	@recentUsers = ();
	foreach my $usermessage (@usermessages) {
		## split down to all strings of names
		my ($messid, $fromName, $toNames, $toCCNames, $toBCCNames, undef, undef, undef, undef, undef, undef, $messStatus, undef) = split(/\|/, $usermessage); # pull name from PM
		if ($messStatus =~ /b/ || $messStatus =~ /g/) { next; }
		## push all name strings 
		if ($fromName && $fromName ne $username) { push(@recentUsers, $fromName); }
		if ($toNames) {
			foreach my $listItem (split(/\,/, $toNames)) {
				if ($listItem ne $username) { push(@recentUsers, $listItem); }
			}
		}
		if ($toCCNames) {
			foreach $listItem (split(/\,/, $toCCNames)) {
				if ($listItem ne $username) { push(@recentUsers, $listItem); }
			}
		}
		if ($toBCCNames) {
			foreach my $listItem (split(/\,/, $toBCCNames)) {
				if ($listItem ne $username) { push(@recentUsers, $listItem); }
			}
		}
	}	
	@recentUsers = &undupe(@recentUsers);
	@recentUsers = sort @recentUsers;
	return @recentUsers;
}

sub quickSearch {
	&fatal_error("no_access") if !$iamadmin && !$iamgmod;

	$to_id = $INFO{'toid'};
	$yymain = qq~
	<div class="bordercolor" style="width:300px">
	<table cellpadding="3" cellspacing="1" border="0" width="300">
		<tr>
			<td class="titlebg"><label for="letter">$usersel_txt{'qsearch'}</label></td>
		</tr><tr>
			<td class="windowbg2">
				<div style="float:left"><input type="text" name="letter" id="letter" onkeyup="LetterChange(this.value)" style="width:270px" /></div>
				<div style="float:right"><img src="$imagesdir/mozilla_gray.gif" id="load" alt="" /></div>
			</td>
		</tr><tr>
			<td class="windowbg">
				<select name="rec_list" multiple="multiple" id="rec_list" size="10" style="width: 290px; font-size: 11px;" ondblclick="copy_option('$to_id')"><option></option></select>
			</td>
		</tr><tr>
			<td class="windowbg">
				<input type="button" class="button" onclick="copy_option('$to_id')" value="$usersel_txt{'addselected'}" style="width: 145px;" /><input type="button" class="button" onclick="window.close()" value="$usersel_txt{'pageclose'}" style="width: 145px;" />
			</td>
		</tr><tr>
			<td class="windowbg2">
				<br /><span class="small">$usersel_txt{'instruct0'} $usersel_txt{'moderatorlist'}</span><br /><br />
			</td>
		</tr>
	</table>
	</div>
	<div id="response" style="display:none"> </div>
	~;

	$yytitle = $usersel_txt{'modpagetitle'};
	&userselectTemplate;
}

sub doquicksearch {
	&fatal_error("no_access") if !$iamadmin && !$iamgmod;

	&ManageMemberinfo("load");
	my (@matches, $realname, $membername);
	foreach $membername (sort { lc $memberinf{$a} cmp lc $memberinf{$b} } keys %memberinf) {
		(undef, $realname, undef) = split(/\|/, $memberinf{$membername}, 3);
		if ($realname =~ /^$INFO{'letter'}/i) {
			push(@matches, $realname,$membername);
		}
	}
	print "Content-type: text/plain\n\n";
	print join(",", @matches);

	CORE::exit; # This is here only to avoid server error log entries!
}

sub checkUserAvail {

	&LoadLanguage('Register');

	my $taken = "false";


	my @reserve = &read_DBorFILE(0,'',$vardir,'reserve','txt');
	my @reservecfg = &read_DBorFILE(0,'',$vardir,'reservecfg','txt');
	for ($a = 0; $a < @reservecfg; $a++) {
		chomp $reservecfg[$a];
	}
	$matchword = $reservecfg[0] eq 'checked';
	$matchcase = $reservecfg[1] eq 'checked';
	$matchuser = $reservecfg[2] eq 'checked';
	$matchname = $reservecfg[3] eq 'checked';
	$namecheck = $matchcase eq 'checked' ? $INFO{'user'} : lc $INFO{'user'};
	$realnamecheck = $matchcase eq 'checked' ? $INFO{'display'} : lc $INFO{'display'};

	if ($INFO{'type'} eq "email") {
		$INFO{'email'} =~ s~\A\s+|\s+\z~~g;
		$type = $register_txt{'112'};
		if (lc $INFO{'email'} eq lc &MemberIndex("check_exist", $INFO{'email'})) { $taken = "true"; }
	} elsif ($INFO{'type'} eq "display") {
		$INFO{'display'} =~ s~\A\s+|\s+\z~~g;
		$type = $register_txt{'111'};
		if (lc $INFO{'display'} eq lc &MemberIndex("check_exist", $INFO{'display'})) {
			$taken = "true";
		}
		if ($matchname) {
			foreach $reserved (@reserve) {
				chomp $reserved;
				$reservecheck = $matchcase ? $reserved : lc $reserved;
				if ($matchword) {
					if ($realnamecheck eq $reservecheck) { $taken = "reg"; break; }
				} else {
					if ($realnamecheck =~ $reservecheck) { $taken = "reg"; break; }
				}
			}
		}
	} elsif ($INFO{'type'} eq "nouserid") {
		$type = $register_txt{'110'};
		$taken = "notuserid";
	} elsif ($INFO{'type'} eq "nodisplay") {
		$type = $register_txt{'111'};
		$taken = "notdisplay";
	} elsif ($INFO{'type'} eq "user") {
		$INFO{'user'} =~ s~\A\s+|\s+\z~~g;
		$INFO{'user'} =~ s/\s/_/g;
		$type = $register_txt{'110'};
		if (lc $INFO{'user'} eq lc &MemberIndex("check_exist", $INFO{'user'})) {
			$taken = "true";
		}
		if ($matchuser) {
			foreach $reserved (@reserve) {
				chomp $reserved;
				$reservecheck = $matchcase ? $reserved : lc $reserved;
				if ($matchword) {
					if ($namecheck eq $reservecheck) { $taken = "reg"; break; }
				} else {
					if ($namecheck =~ $reservecheck) { $taken = "reg"; break; }
				}
			}
		}
	}

	if ($taken eq "false") {
		$avail = qq~<img src="$imagesdir/check.png">&nbsp;&nbsp;<span style="color:#00dd00">$type$register_txt{'114'}</span>~;
	} elsif ($taken eq "true") {
		$avail = qq~<img src="$imagesdir/cross.png">&nbsp;&nbsp;<span style="color:#dd0000">$type$register_txt{'113'}</span>~;
	} elsif ($taken eq "notuserid") {
		$avail = qq~<img src="$imagesdir/cross.png">&nbsp;&nbsp;<span style="color:#dd0000">$type$register_txt{'117'}</span>~;
		$INFO{'type'} = "user";
	} elsif ($taken eq "notdisplay") {
		$avail = qq~<img src="$imagesdir/cross.png">&nbsp;&nbsp;<span style="color:#dd0000">$type$register_txt{'116'}</span>~;
		$INFO{'type'} = "display";
	} else {
		$avail = qq~<img src="$imagesdir/cross.png">&nbsp;&nbsp;<span style="color:#dd0000">$type$register_txt{'115'}</span>~;
	}

	print "Content-type: text/plain\n\n$INFO{'type'}|$avail";

	CORE::exit; # This is here only to avoid server error log entries!
}

1;