###############################################################################
# ViewMembers.pl                                                              #
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

$viewmembersplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('MemberList');

&is_admin_or_gmod;

my ($sortmode, $sortorder, $spages, $memrealname, $memposts);

$MembersPerPage = $TopAmmount;
$maxbar         = 100;

sub Ml {
# Decides how to sort memberlist, and gives default sort order
	if (!$barmaxnumb) { $barmaxnumb = 500; }
	if ($barmaxdepend == 1) {
		$barmax = 1;
		&ManageMemberinfo("load");
		foreach (keys %memberinf) {
			(undef, undef, undef, undef, $memposts, undef) = split(/\|/, $memberinf{$_}, 6);
			if ($memposts > $barmax) { $barmax = $memposts; }
		}
		undef %memberinf;
	} else {
		$barmax = $barmaxnumb;
	}
	
	$FORM{'sortform'} ||= $INFO{'sortform'};
	if (!$INFO{'sort'} && !$FORM{'sortform'}) { $INFO{'sort'} = $defaultml; $FORM{'sortform'} = $defaultml }
	
	if ($FORM{'sortform'} eq "username" || $INFO{'sort'} eq "mlletter" || $INFO{'sort'} eq "username") {
		$page     = "a";
		$showpage = "A";
		while ($page ne "z") {
			$LetterLinks .= qq(<a href="$adminurl?action=ml;sort=mlletter;letter=$page" class="catbg a"><b>$showpage&nbsp;</b></a> );
			$page++;
			$showpage++;
		}
		$LetterLinks .= qq(<a href="$adminurl?action=ml;sort=mlletter;letter=z" class="catbg a"><b>Z</b></a>  <a href="$adminurl?action=ml;sort=mlletter;letter=other" class="catbg a"><b>$ml_txt{'800'}</b></a> );
	}

	if ($INFO{'start'} eq '') { $start = 0; }
	else { $start = $INFO{'start'}; $spages = ";start=$start"; }

	if ($INFO{'sort'} ne '') { $sortmode = ";sort=" . $INFO{'sort'}; }
	elsif ($FORM{'sortform'} ne '') { $sortmode = ";sort=" . $FORM{'sortform'}; }
	if ($INFO{'reversed'} || $FORM{'reversed'}) { $selReversed = qq~ checked='checked'~; $sortorder = ";reversed=1"; }

	$actualnum = 0;
	$numshown = 0;
	if ($FORM{'sortform'} eq 'posts' || $INFO{'sort'} eq 'posts') { $selPost .= qq~ selected="selected"~; &MLTop; }
	if ($FORM{'sortform'} eq 'regdate' || $INFO{'sort'} eq 'regdate') { $selReg .= qq~ selected="selected"~; &MLDate; }
	if ($FORM{'sortform'} eq 'position' || $INFO{'sort'} eq 'position') { $selPos .= qq~ selected="selected"~; &MLPosition; }
	if ($FORM{'sortform'} eq 'lastonline' || $INFO{'sort'} eq 'lastonline') { $selLastOn .= qq~ selected="selected"~; &MLLastOnline; }
	if ($FORM{'sortform'} eq 'lastpost' || $INFO{'sort'} eq 'lastpost') { $selLastPost .= qq~ selected="selected"~; &MLLastPost; }
	if ($FORM{'sortform'} eq 'lastim' || $INFO{'sort'} eq 'lastim') { $selLastIm .= qq~ selected="selected"~; &MLLastIm; }
	if ($INFO{'sort'} eq '' || $INFO{'sort'} eq 'mlletter' || $INFO{'sort'} eq 'username') { $selUser .= qq~ selected="selected"~; &MLByLetter; }
}

sub MLByLetter {
	$letter = lc($INFO{'letter'});
	$i      = 0;
	&ManageMemberinfo("load");
	foreach $membername (sort { lc $memberinf{$a} cmp lc $memberinf{$b} } keys %memberinf) {
		(undef, $memrealname, undef) = split(/\|/, $memberinf{$membername}, 3);
		if ($letter) {
			$SearchName = lc(substr($memrealname, 0, 1));
			if ($SearchName eq $letter) { $ToShow[$i] = $membername; $i++; }
			elsif ($letter eq "other" && (($SearchName lt "a") || ($SearchName gt "z"))) { $ToShow[$i] = $membername; $i++; }
		} else {
			$ToShow[$i] = $membername;
			$i++;
		}
	}
	undef %memberinf;

	$memcount = @ToShow;
	if (!$memcount && $letter) {
		$pageindex1 = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;"><img src="$imagesdir/index_togl.png" border="0" alt="" style="vertical-align: middle;" /></span>~;
		$pageindex2 = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;"><img src="$imagesdir/index_togl.png" border="0" alt="" style="vertical-align: middle;" /></span>~;
	} else {
		&buildIndex;
	}
	&buildPages(1);
	$b = $start;

	if ($memcount) {
		while ($numshown < $MembersPerPage) {
			&showRows($ToShow[$b]);
			$numshown++;
			$b++;
		}
	} else {
		if ($letter) { $yymain .= qq~<tr><td class="windowbg" colspan="7" align="center"><br /><b>$ml_txt{'760'}</b><br /><br /></td></tr>~; }
	}

	undef @ToShow;
	&buildPages(0);
	$yytitle = "$ml_txt{'312'} $numshow";
	$action_area = 'viewmembers';
	&AdminTemplate;
}

sub MLTop {
	%top_list = ();

	&ManageMemberinfo("load");
	foreach (keys %memberinf) {
		(undef, $memrealname, undef, undef, $memposts, undef) = split(/\|/, $memberinf{$_}, 6);
		$memposts = sprintf("%06d", (999999 - $memposts));
		$top_list{$_} = qq~$memposts|$memrealname~;
	}
	undef %memberinf;
	my @toplist = sort { lc $top_list{$a} cmp lc $top_list{$b} } keys %top_list;

	if ($FORM{'reversed'} || $INFO{'reversed'}) {
		@toplist = reverse @toplist;
	}

	$memcount = @toplist;
	&buildIndex;
	&buildPages(1);
	$b = $start;

	while ($numshown < $MembersPerPage) {
		&showRows($toplist[$b]);
		$numshown++;
		$b++;
	}

	undef @toplist;
	&buildPages(0);
	$yytitle = "$ml_txt{'313'} $ml_txt{'314'} $numshow";
	$action_area = 'viewmembers';
	&AdminTemplate;
}

sub MLPosition {
	%TopMembers = ();

	&ManageMemberinfo("load");
	while (($membername, $value) = each(%memberinf)) {
		(undef, $memberrealname, undef, $memposition, $memposts, undef) = split(/\|/, $value, 6);
		$pstsort    = 99999999 - $memposts;
		$sortgroups = "";
		foreach my $key (keys %Group) {
			if ($memposition eq $key) {
				if    ($key eq "Administrator")    { $sortgroups = "aaa.$pstsort.$memberrealname"; }
				elsif ($key eq "Global Moderator") { $sortgroups = "bbb.$pstsort.$memberrealname"; }
			}
		}
		if (!$sortgroups) {
			foreach (sort { $a <=> $b } keys %NoPost) {
				if ($memposition eq $_) {
					$sortgroups = "ddd.$memposition.$pstsort.$memberrealname";
				}
			}
		}
		if (!$sortgroups) {
			$sortgroups = "eee.$pstsort.$memposition.$memberrealname";
		}
		$TopMembers{$membername} = $sortgroups;
	}
	my @toplist = sort { lc $TopMembers{$a} cmp lc $TopMembers{$b} } keys %TopMembers;

	if ($FORM{'reversed'} || $INFO{'reversed'}) {
		@toplist = reverse @toplist;
	}

	$memcount = @toplist;
	&buildIndex;
	&buildPages(1);
	$b = $start;

	while ($numshown < $MembersPerPage) {
		&showRows($toplist[$b]);
		$numshown++;
		$b++;
	}

	undef @toplist;
	undef %memberinf;
	&buildPages(0);
	$yytitle = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'87'} $numshow";
	$action_area = 'viewmembers';
	&AdminTemplate;
}

sub MLDate {
	my @tempmemlist = &read_DBorFILE(0,'',$memberdir,'memberinfo','txt');
	if ($FORM{'reversed'} || $INFO{'reversed'}) {
		@tempmemlist = reverse @tempmemlist;
	}

	$memcount = @tempmemlist;
	&buildIndex;
	&buildPages(1);
	$b = $start;

	while ($numshown < $MembersPerPage) {
		($membername, undef) = split(/\t/, $tempmemlist[$b], 2);
		&showRows($membername);
		$numshown++;
		$b++;
	}

	$yymain .= $TableFooter;
	&buildPages(0);
	$yytitle = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'233'}";
	$action_area = 'viewmembers';
	&AdminTemplate;
}

sub showRows {
	my ($user) = $_[0];
	if ($user ne "") {
		&LoadUser($user);
		$date2 = $date;

		my $userlastonline = ${$uid.$user}{'lastonline'};
		my $userlastpost   = ${$uid.$user}{'lastpost'};
		my $userlastim     = ${$uid.$user}{'lastim'};

		$date1 = &stringtotime(${$uid.$user}{'regdate'});
		&calcdifference;
		$days_reg = $result;

		my ($tmpa,$tmpb,$tmpc);
		if ($userlastonline eq "") { $userlastonline = "-"; }
		else { $date1 = $userlastonline; &calcdifference; $userlastonline = $result; $tmpa = $userlastonline; }
		if ($userlastpost eq "") { $userlastpost = "-"; }
		else { $date1 = $userlastpost; &calcdifference; $userlastpost = $result; $tmpb = $userlastpost; }
		if ($userlastim eq "") { $userlastim = "-"; }
		else { $date1 = $userlastim; &calcdifference; $userlastim = $result; $tmpc = $userlastim; }
		$userlastonline = &NumberFormat($userlastonline);
		$userlastpost = &NumberFormat($userlastpost);
		$userlastim = &NumberFormat($userlastim);
		$userpostcount = &NumberFormat(${$uid.$user}{'postcount'});

		if ($user ne "admin") {
			$CheckingAll .= qq~"$days_reg|${$uid.$user}{'postcount'}|$tmpa|$tmpb|$tmpc|$user", ~;
		}

		$barchart = ${$uid.$user}{'postcount'};
		$bartemp  = (${$uid.$user}{'postcount'} * $maxbar);
		$barwidth = ($bartemp / $barmax);
		$barwidth = ($barwidth + 0.5);
		$barwidth = int($barwidth);
		if ($barwidth > $maxbar) { $barwidth = $maxbar }
		if ($barchart < 1) { $Bar = "&nbsp;"; }
		else { $Bar = qq~<img src="$imagesdir/bar.gif" width="$barwidth" height="10" alt="" border="0" />~; }

		$dr_regdate = &timeformat(${$uid.$user}{'regtime'});
		$dr_regdate =~ s~(.*)(, 1?[0-9]):[0-9][0-9].*~$1~;

		my $memberinfo = "&nbsp;";
		if (${$uid.$user}{'realname'} eq "") { ${$uid.$user}{'realname'} = $user; }
		if (${$uid.$user}{'position'} eq "" && $showallgroups) {
			foreach $postamount (sort { $b <=> $a } keys %Post) {
				if (${$uid.$user}{'postcount'} > $postamount) {
					($memberinfo, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $Post{$postamount});
					last;
				}
			}
		} elsif (${$uid.$user}{'position'} ne "") {
			$tempgroups = 0;
			foreach (keys %Group) {
				if (${$uid.$user}{'position'} eq $_) {
					($memberinfo, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $Group{$_});
					$tempgroups = 1;
					last;
				}
			}
			if (!$tempgroups) {
				foreach (sort { $a <=> $b } keys %NoPost) {
					if (${$uid.$user}{'position'} eq $_) {
						($memberinfo, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $NoPost{$_});
						$tempgroups = 1;
						last;
					}
				}
			}
			if (!$tempgroups) {
				$memberinfo = ${$uid.$user}{'position'};
			}
		}

		$yymain .= qq~
	<tr>
		<td class="windowbg" width="19%">$link{$user}</td>~;

		if ($user eq "admin") {
			$addel = qq~&nbsp;~;
		} else {
			$addel = qq~<input type="checkbox" name="member$numshown" value="$user" class="windowbg" style="border: 0; vertical-align: middle;" />~;
			$actualnum++;
		}

		$yymain .= qq~
		<td class="windowbg" width="19%">$memberinfo</td>
		<td class="windowbg2" width="5%" align="center">$userpostcount</td>
		<td class="windowbg" width="14%">$Bar</td>
		<td class="windowbg" width="19%" >$dr_regdate &nbsp;</td>
		<td class="windowbg2" width="7%" align="center">$userlastonline</td>
		<td class="windowbg2" width="6%" align="center">$userlastpost</td>
		<td class="windowbg2" width="6%" align="center">$userlastim</td>
		<td class="windowbg" width="5%" align="center">$addel</td>
	</tr>~;
	}
}

sub buildIndex {
	unless ($memcount == 0) {

		(undef, undef, $usermemberpage, undef) = split(/\|/, ${$uid.$username}{'pageindex'},4);

		# Build the page links list.
		my ($pagetxtindex, $pagetextindex, $pagedropindex1, $pagedropindex2, $all, $allselected);
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
		$pageindex1 = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;"><img src="$imagesdir/index_togl.png" border="0" alt="" style="vertical-align: middle;" /> $ml_txt{'139'}: $pagenumb</span>~;
		$pageindex2 = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;"><img src="$imagesdir/index_togl.png" border="0" alt="" style="vertical-align: middle;" /> $ml_txt{'139'}: $pagenumb</span>~;
		if ($pagenumb > 1 || $all) {

			if ($usermemberpage == 1) {
				$pagetxtindexst = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;"><a href="$scripturl?action=memberpagedrop;from=admin;sort=$INFO{'sort'};letter=$INFO{'letter'};start=$INFO{'start'}$sortorder"><img src="$imagesdir/index_togl.png" border="0" alt="$ml_txt{'19'}" title="$ml_txt{'19'}" style="vertical-align: middle;" /></a> $ml_txt{'139'}: ~;
				if ($startpage > 0) { $pagetxtindex = qq~<a href="$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter$sortorder" style="font-weight: normal;">1</a>&nbsp;...&nbsp;~; }
				if ($startpage == $MembersPerPage) { $pagetxtindex = qq~<a href="$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter$sortorder" style="font-weight: normal;">1</a>&nbsp;~; }
				for ($counter = $startpage; $counter < $endpage; $counter += $MembersPerPage) {
					$pagetxtindex .= $start == $counter ? qq~<b>$tmpa</b>&nbsp;~ : qq~<a href="$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$counter$sortorder" style="font-weight: normal;">$tmpa</a>&nbsp;~;
					$tmpa++;
				}
				if ($endpage < $memcount - $MembersPerPage) { $pageindexadd = qq~...&nbsp;~; }
				if ($endpage != $memcount) { $pageindexadd .= qq~<a href="$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$lastptn$sortorder" style="font-weight: normal;">$lastpn</a>~; }
				$pagetxtindex .= qq~$pageindexadd~;
				$pageindex1 = qq~$pagetxtindexst$pagetxtindex</span>~;
				$pageindex2 = qq~$pagetxtindexst$pagetxtindex</span>~;
			} else {
				$pagedropindex1 = qq~<span style="float: left; width: 350px; margin: 0px; margin-top: 2px; border: 0px;">~;
				$pagedropindex1 .= qq~<span style="float: left; height: 21px; margin: 0; margin-right: 4px;"><a href="$scripturl?action=memberpagetext;from=admin;sort=$INFO{'sort'};letter=$INFO{'letter'};start=$INFO{'start'}$sortorder"><img src="$imagesdir/index_togl.png" border="0" alt="$ml_txt{'19'}" title="$ml_txt{'19'}" /></a></span>~;
				$pagedropindex2 = $pagedropindex1;
				$tstart         = $start;
				if (substr($INFO{'start'}, 0, 3) eq "all") { ($tstart, $start) = split(/\-/, $INFO{'start'}); }
				$d_indexpages = $pagenumb / $dropdisplaynum;
				$i_indexpages = int($pagenumb / $dropdisplaynum);
				if ($d_indexpages > $i_indexpages) { $indexpages = int($pagenumb / $dropdisplaynum) + 1; }
				else { $indexpages = int($pagenumb / $dropdisplaynum) }
				$selectedindex = int(($start / $MembersPerPage) / $dropdisplaynum);

				if ($pagenumb > $dropdisplaynum) {
					$pagedropindex1 .= qq~<span style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector1" id="decselector1" style="font-size: 9px; border: 2px inset;" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
					$pagedropindex2 .= qq~<span style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector2" id="decselector2" style="font-size: 9px; border: 2px inset;" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
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
						$pagedropindex1 .= qq~<option value="$indexstart|$indexend|$MembersPerPage|$indexpage"$selected>$indxoption</option>\n~;
						$pagedropindex2 .= qq~<option value="$indexstart|$indexend|$MembersPerPage|$indexpage"$selected>$indxoption</option>\n~;
					}
				}
				if ($pagenumb > $dropdisplaynum) {
					$pagedropindex1 .= qq~</select>\n</span>~;
					$pagedropindex2 .= qq~</select>\n</span>~;
				}
				$pagedropindex1 .= qq~<span id="ViewIndex1" class="droppageindex" style="height: 14px; visibility: hidden">&nbsp;</span>~;
				$pagedropindex2 .= qq~<span id="ViewIndex2" class="droppageindex" style="height: 14px; visibility: hidden">&nbsp;</span>~;
				$tmpMembersPerPage = $MembersPerPage;
				if (substr($INFO{'start'}, 0, 3) eq "all") { $MembersPerPage = $MembersPerPage * $dropdisplaynum; }
				$prevpage          = $start - $tmpMembersPerPage;
				$nextpage          = $start + $MembersPerPage;
				$pagedropindexpvbl = qq~<img src="$imagesdir/index_left0.gif" height="14" width="13" border="0" alt="" style="margin: 0px; display: inline; vertical-align: middle;" />~;
				$pagedropindexnxbl = qq~<img src="$imagesdir/index_right0.gif" height="14" width="13" border="0" alt="" style="margin: 0px; display: inline; vertical-align: middle;" />~;
				if ($start < $MembersPerPage) { $pagedropindexpv .= qq~<img src="$imagesdir/index_left0.gif" height="14" width="13" border="0" alt="" style="display: inline; vertical-align: middle;" />~; }
				else { $pagedropindexpv .= qq~<img src="$imagesdir/index_left.gif" border="0" height="14" width="13" alt="$pidtxt{'02'}" title="$pidtxt{'02'}" style="display: inline; vertical-align: middle; cursor: pointer;" onclick="location.href=\\'$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$prevpage$sortorder\\'" ondblclick="location.href=\\'$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=0$sortorder\\'" />~; }
				if ($nextpage > $lastptn) { $pagedropindexnx .= qq~<img src="$imagesdir/index_right0.gif" border="0" height="14" width="13" alt="" style="display: inline; vertical-align: middle;" />~; }
				else { $pagedropindexnx .= qq~<img src="$imagesdir/index_right.gif" height="14" width="13" border="0" alt="$pidtxt{'03'}" title="$pidtxt{'03'}" style="display: inline; vertical-align: middle; cursor: pointer;" onclick="location.href=\\'$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$nextpage$sortorder\\'" ondblclick="location.href=\\'$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$lastptn$sortorder\\'" />~; }
				$pageindex1 = qq~$pagedropindex1</span>~;
				$pageindex2 = qq~$pagedropindex2</span>~;

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
			if(visel == pagstart) pagedropindex += '<td class="titlebg" height="14" style="height: 14px; padding-left: 1px; padding-right: 1px; font-size: 9px; font-weight: bold;">' + i + '</td>';
			else pagedropindex += '<td height="14" class="droppages"><a href="$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=' + pagstart + '$sortorder">' + i + '</a></td>';
			pagstart += maxpag;
		}
		~;
		if ($showpageall) {
			$pageindexjs .= qq~
			if (vistart != viend) {
				if(visel == 'all') pagedropindex += '<td class="titlebg" height="14" style="height: 14px; padding-left: 1px; padding-right: 1px; font-size: 9px; font-weight: normal;"><b>$pidtxt{"01"}</b></td>';
				else pagedropindex += '<td height="14" class="droppages"><a href="$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=all-' + allpagstart + '$sortorder">$pidtxt{"01"}</a></td>';
			}
			~;
		}
		$pageindexjs .= qq~
		if(visel != 'xx') pagedropindex += '<td height="14" class="small" style="height: 14px; padding-left: 4px;">$pagedropindexpv$pagedropindexnx</td>';
		else pagedropindex += '<td height="14" class="small" style="height: 14px; padding-left: 4px;">$pagedropindexpvbl$pagedropindexnxbl</td>';
		pagedropindex += '</tr></table>';
		document.getElementById("ViewIndex1").innerHTML=pagedropindex;
		document.getElementById("ViewIndex1").style.visibility = "visible";
		document.getElementById("ViewIndex2").innerHTML=pagedropindex;
		document.getElementById("ViewIndex2").style.visibility = "visible";
		~;
				if ($pagenumb > $dropdisplaynum) {
					$pageindexjs .= qq~
		document.getElementById("decselector1").value = decparam;
		document.getElementById("decselector2").value = decparam;
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

	sub buildPages {
		$SortJump .= qq(
 		   <form action="$adminurl?action=ml" method="post" style="display: inline;">
		    <select name="sortform" onchange="submit()">
		    <option value="username"$selcUser>$ml_txt{'35'}</option>
		    <option value="position"$selcPos>$ml_txt{'87'}</option>
		    <option value="posts"$selcPost>$ml_txt{'21'}</option>
		    <option value="regdate"$selcReg>$ml_txt{'233'}</option>
		    </select>
		    </form>
		);

		$TableHeader .= qq~
		<table border="0" width="100%" cellspacing="1" cellpadding="3" class="bordercolor">
		  <tr>
			<td width="100%" valign="middle" class="titlebg">
			<span style="float: left;"><img src="$imagesdir/register.gif" alt="" border="0" style="vertical-align: middle;" /><b> $admintxt{'17'}</b></span>
			</td>
		  </tr>
		  <tr>
			<td width="100%" valign="middle" class="titlebg">
			<form action="$adminurl?action=ml" method="post" name="selsort" style="display: inline">
			<span style="float: right;">
			<label for="sortform"><b>$ml_txt{'1'}</b></label>
			<select name="sortform" id="sortform" style="font-size: 9pt;" onchange="submit()">
			<option value="username"$selUser>$ml_txt{'35'}</option>
			<option value="position"$selPos>$ml_txt{'87'}</option>
			<option value="posts"$selPost>$ml_txt{'21'}</option>
			<option value="regdate"$selReg>$ml_txt{'233'}</option>
			<option value="lastonline"$selLastOn>$amv_txt{'9'}</option>
			<option value="lastpost"$selLastPost>$amv_txt{'10'}</option>
			<option value="lastim"$selLastIm>$amv_txt{'11'}</option>
			</select>
			<label for="reversed"><b>$admintxt{'37'}</b></label>
			<input type="checkbox" onclick="submit()" name="reversed" id="reversed" class="titlebg" style="border: 0;"$selReversed />
			</span>
			</form>
			</td>
		  </tr>
		</table>
		<script language="JavaScript1.2" src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
		if (document.selsort.sortform.options[document.selsort.sortform.selectedIndex].value == 'username') {
		document.selsort.reversed.disabled = true;
		}
		//-->
		</script>
		
		<form name="adv_memberview" action="$adminurl?action=deletemultimembers$sortmode$sortorder$spages" method="post" style="display: inline" onsubmit="return submitproc()">
		<input type="hidden" name="button" value="0" />
		<table border="0" width="100%" cellspacing="1" cellpadding="3" class="bordercolor">
		<tr>
			<td class="catbg" width="19%" align="center"><a href="$adminurl?action=ml;sortform=username"><b>$ml_txt{'35'}</b></a></td>
			<td class="catbg" width="19%" align="center"><a href="$adminurl?action=ml;sortform=position"><b>$ml_txt{'87'}</b></a></td>
			<td class="catbg" width="19%" align="center" colspan="2"><a href="$adminurl?action=ml;sortform=posts"><b>$ml_txt{'21'}</b></a></td>
			<td class="catbg" width="19%" align="center"><a href="$adminurl?action=ml;sortform=regdate"><b>$ml_txt{'234'}</b></a></td>
			<td class="catbg" width="19%" align="center" colspan="3"><b>$amv_txt{'4'}</b><br /><span class="small" style="float: left; text-align: center; width: 34%;"><a href="$adminurl?action=ml;sortform=lastonline">$amv_txt{'5'}</a></span><span class="small" style="float: left; text-align: center; width: 33%;"><a href="$adminurl?action=ml;sortform=lastpost">$amv_txt{'6'}</a></span><span class="small" style="float: left; text-align: center; width: 33%;"><a href="$adminurl?action=ml;sortform=lastim">$amv_txt{'7'}</a></span></td>
			<td class="catbg" width="5%" align="center"><b>$admintxt{'38'}</b></td>
		</tr>
		~;

		if ($LetterLinks ne "") {
			$TableHeader .= qq(<tr>
				<td class="catbg" colspan="9"><span class="small">$LetterLinks</span></td>
			</tr>
			);
		}


		$sel_box = qq~
			<br />
			<table border="0" width="100%" cellpadding="3" cellspacing="1" class="bordercolor">
				<tr>
					<td class="titlebg" colspan="2" align="right">
					<label for="check_all"><b>$amv_txt{'38'}</b></label>
					<select name="field2" id="field2" onchange="document.adv_memberview.check_all.checked=true;checkAll(1);">
						<option value="0">$amv_txt{'35'}</option>
						<option value="1">$amv_txt{'36'}</option>
						<option value="2" selected="selected">$amv_txt{'37'}</option>
					</select> 
					<input type="text" size="5" name="number" value="30" maxlength="5" onkeyup="document.adv_memberview.check_all.checked=true;checkAll(1);" /> 
					<select name="field1" onchange="document.adv_memberview.check_all.checked=true;checkAll(1);">
						<option value="0">$amv_txt{'30'}</option>
						<option value="1">$amv_txt{'31'}</option>
						<option value="2" selected="selected">$amv_txt{'32'}</option>
						<option value="3">$amv_txt{'33'}</option>
						<option value="4">$amv_txt{'34'}</option>
					</select> 
					<br />
					<label for="del_mail">$amv_txt{'45'}:</label> <input type="checkbox" name="del_mail" id="del_mail" value="1" class="titlebg" style="border: 0;" />
					</td>
					<td class="titlebg" align="center" width="5%">
						<input type="checkbox" name="check_all" id="check_all" value="1" class="titlebg" style="border: 0;" onclick="javascript:if(this.checked)checkAll(1);else checkAll(0);" />
					</td>
				</tr>
				<tr>
				  <td class="windowbg" colspan="3" align="center">
						<input type="submit" value="$amv_txt{'15'}" onclick="javascript:window.document.adv_memberview.button.value = '2'; return confirm('$amv_txt{'20'}')" class="button" />
				  </td>
				</tr>
			</table>
		  </form>
		<script language="JavaScript1.2" type="text/javascript">
		<!-- 
		mem_data = new Array ( "", $CheckingAll"" );
		function checkAll(ticked) {
			if(navigator.appName == "Microsoft Internet Explorer") {var alt_pressed = self.event.altKey; var ctrl_pressed = self.event.ctrlKey;}
			else {var alt_pressed = false; var ctrl_pressed = false;}

			var limit = document.adv_memberview.number.value;
			var field1 = document.adv_memberview.field1.value;
			var field2 = document.adv_memberview.field2.value;
			for (var i = 1; i <= $actualnum; i++) {
				if (!ticked) {
					document.adv_memberview.elements[i].checked = false;
				} else {
					var value1 = eval(mem_data[i].split("|")[field1]);
					if (value1 != undefined) {
						var check = 0;
						if (field2 == 0 && value1 <  limit) { check = 1; }
						if (field2 == 1 && value1 == limit) { check = 1; }
						if (field2 == 2 && value1 >  limit) { check = 1; } 
						if (ctrl_pressed == true) { check = 0; }
						if (alt_pressed  == true) { check = 1; }
						if (check == 1) document.adv_memberview.elements[i].checked = true;
						else            document.adv_memberview.elements[i].checked = false;
					}
				}
			}
		}
		//-->
		</script>
	~;

		$numbegin = ($start + 1);
		$numend   = ($start + $MembersPerPage);
		if ($numend > $memcount) { $numend  = $memcount; }
		if ($memcount == 0)      { $numshow = ""; }
		else { $numshow = qq~($numbegin - $numend $ml_txt{'309'} $memcount)~; }
		if ($_[0]) {
			$yymain .= qq~
	<div style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
		<table border="0" width="100%" cellspacing="1" cellpadding="3" class="bordercolor">
		<tr>
		<td class="catbg" colspan="9" width="100%" align="left" valign="middle">
		<div style="float: left; width: 50%; text-align: left;">$pageindex1</div>
		</td>
		</tr>
		</table>
		$TableHeader~;
		} else {
			$yymain .= qq~
		<tr>
		<td class="catbg" colspan="9" width="100%" align="left" valign="middle">
		<div style="float: left; width: 50%; text-align: left;">$pageindex2</div>
		$pageindexjs
		</td>
		</tr>
		</table>
		$sel_box
	</div>~;
		}
	}
}


sub MLLastPost {
	%TopMembers = ();

	&ManageMemberinfo("load");
	foreach (keys %memberinf) {
		&LoadUser($_);
		$TopMembers{$_} = ${$uid.$_}{'lastpost'};
		undef %{ $uid . $_ };
	}
	undef %memberinf;

	my @toplist = sort { $TopMembers{$b} <=> $TopMembers{$a} } keys %TopMembers;
	undef %TopMembers;

	if ($FORM{'reversed'} || $INFO{'reversed'}) {
		@toplist = reverse @toplist;
	}

	$memcount = @toplist;
	&buildIndex;
	&buildPages(1);
	$b = $start;

	while (($numshown < $MembersPerPage)) {
		&showRows($toplist[$b]);
		$numshown++;
		$b++;
	}

	undef @toplist;
	&buildPages(0);

	$yymain .= $TableFooter;
	$yytitle = "$ml_txt{'313'} $TopAmmount $ml_txt{'314'}";
	$action_area = 'viewmembers';
	&AdminTemplate;
}

sub MLLastIm {
	%TopMembers = ();

	&ManageMemberinfo("load");
	foreach (keys %memberinf) {
		&LoadUser($_);
		$TopMembers{$_} = ${$uid.$_}{'lastim'};
		undef %{ $uid . $_ };
	}
	undef %memberinf;

	my @toplist = sort { $TopMembers{$b} <=> $TopMembers{$a} } keys %TopMembers;
	undef %TopMembers;

	if ($FORM{'reversed'} || $INFO{'reversed'}) {
		@toplist = reverse @toplist;
	}

	$memcount = @toplist;
	&buildIndex;
	&buildPages(1);
	$b = $start;

	while (($numshown < $MembersPerPage)) {
		&showRows($toplist[$b]);
		$numshown++;
		$b++;
	}

	undef @toplist;
	&buildPages(0);

	$yymain .= $TableFooter;
	$yytitle = "$ml_txt{'313'} $TopAmmount $ml_txt{'314'}";
	$action_area = 'viewmembers';
	&AdminTemplate;
}

sub MLLastOnline {
	%TopMembers = ();

	&ManageMemberinfo("load");
	foreach (keys %memberinf) {
		&LoadUser($_);
		$TopMembers{$_} = ${$uid.$_}{'lastonline'};
		undef %{ $uid . $_ };
	}
	undef %memberinf;

	my @toplist = sort { $TopMembers{$b} <=> $TopMembers{$a} } keys %TopMembers;
	undef %TopMembers;

	if ($FORM{'reversed'} || $INFO{'reversed'}) {
		@toplist = reverse @toplist;
	}

	$memcount = @toplist;
	&buildIndex;
	&buildPages(1);
	$b = $start;

	while (($numshown < $MembersPerPage)) {
		&showRows($toplist[$b]);
		$numshown++;
		$b++;
	}

	undef @toplist;
	&buildPages(0);

	$yymain .= $TableFooter;
	$yytitle = "$ml_txt{'313'} $TopAmmount $ml_txt{'314'}";
	$action_area = 'viewmembers';
	&AdminTemplate;
}

1;