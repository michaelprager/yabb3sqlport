###############################################################################
# Admin.pl                                                                    #
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

$adminplver  = 'YaBB 3.0 Beta $Revision: 100 $';

sub Admin {
	&is_admin_or_gmod;

	$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="2">
        <b>$admintxt{'1'}</b>
      </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
        <img alt="Admin Centre Logo" src="$defaultimagesdir/aarea.jpg" />
       </td>
       <td align="left" class="windowbg2">
        $admintxt{'2'}
      </td>
     </tr>
   </table>
 </div>

<br />

<div style="float: left; width: 49%; text-align: left;">

 <div class="bordercolor" style="padding: 0px; width: 95%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
        <b>$admintxt{'6'}</b>
      </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg">
        <span class="small">YaBB 2</span>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
Ron Hartendorp, Andrew Aitken, Carsten Dalgaard, Ryan Farrington, Zoltan Kovacs, Tim Ceuppens, Shoeb Omar, Torsten Mrotz, Brian Schaefer, Juvenall Wilson, Corey Chapman, Christer Jenson, Adrian Kreher, Steve Brereton, Jeffrey Man, Boris Tjuvanov, Detlef Pilzecker, Calvin Goodman<br /><br />
      </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg">
        <span class="small">$yabbThanks</span>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
Dave Baughman, Bjoern Berg, Corey Chapman, Peter Crouch, ejdmoo, Dave G, Christian Land, Jeff Lewis, Gunther Meyer, Darya Misse, Parham Mofidi, AstroPilot, Torsten Mrotz, Carey P, Popeye, Michael Prager, Matt Siegman, Jay Silverman, StarSaber, Marco van Veelen, Myhailo Danylenko, $yabb2Credits<br /><br />
$noBytesHarmed<br /><br />
      </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 95%; margin-left: 0px; margin-right: auto;">
  <script language="javascript" src="http://www.yabbforum.com/update/versioncheck.js" type="text/javascript"></script>
  <script language="JavaScript" type="text/javascript">
  <!-- //hide from dinosaurs
	document.write('<table width="100%" cellspacing="1" cellpadding="4">');
	document.write('<tr><td colspan="2" class="titlebg"><b>$admintxt{'3'}</b></td></tr>');
	document.write('<tr><td class="windowbg2">$versiontxt{'4'}</td><td class="windowbg2"><b>$YaBBversion</b></td></tr>');
	if (!STABLE) {
		document.write('<tr><td colspan="2" class="titlebg">$rna</b></td></tr>');
	} else {
		document.write('<tr><td class="windowbg2">$versiontxt{'5'}</td><td class="windowbg2"><b>'+STABLE+'</b></td></tr>');
		document.write('<tr><td class="windowbg2">$versiontxt{'7'}</td><td class="windowbg2"><b>'+BETA+'</b></td></tr>');
		document.write('<tr><td class="windowbg2">$versiontxt{'8'}</td><td class="windowbg2"><b>'+ALPHA+'</b></td></tr>');
		if (STABLE == "$YaBBversion") {
			document.write('<tr><td colspan="2" valign="middle" class="windowbg2"><br />$versiontxt{'6'}<br /><br /></td></tr>');
		} else {
			document.write('<tr><td colspan="2" valign="middle" class="windowbg2"><br />$versiontxt{'2'}'+STABLE+'$versiontxt{'3'}<br /><br /></td></tr>');
		}
	}
	document.write('</table>');
  // -->
  </script>
  <noscript>$versiontxt{'1'}</noscript>
 </div>

</div>
<div style="float: left; width: 50%; text-align: right;">

 <div class="bordercolor" style="padding: 0px; width: 100%; margin-left: auto; margin-right: 0px;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
        <b>$admintxt{'4'}</b>
      </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
        <iframe src="http://www.yabbforum.com/update/" frameborder="0" width="100%" height="293">$iFrameSupport</iframe>
      </td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 100%; margin-left: auto; margin-right: 0px;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
        <b>$admintxt{'5'}</b>
      </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">~;

	&GetLastLogins;

	$yymain .= qq~
      </td>
     </tr>
   </table>
 </div>~;

	if (-d "./Convert") {
		$yymain .= qq~
<br />
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: auto; margin-right: 0px;">
<form name="backdelete" action="$adminurl?action=convdelete" method="post">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
	<td align="left" class="titlebg">
		<b>$admintxt{'7'}</b>
	</td>
	</tr>
	<tr valign="middle">
	<td align="left" class="windowbg2"><br />
		$admintxt{'8'}<br /><br />
	</td>
	</tr>
	<tr valign="middle">
	<td align="center" class="catbg">
		<input type="submit" value="$admintxt{'9'}" class="button" />
	</td>
	</tr>
</table>
</form>
</div>~;
	}
  
	$yymain .= qq~
</div>~;

	require "$admindir/ModuleChecker.pl";

	$yymain .= qq~
<div style="float: left; padding: 0px; width: 99%; margin-left: 0px; margin-right: auto; height: 100px;">&nbsp;</div>
~;

	$yytitle = "$admin_txt{'208'}";
	&AdminTemplate;
}

sub DeleteConverterFiles {
	my @convertdir = qw~Boards Members Messages Variables~;

	foreach $cnvdir (@convertdir) {
		$convdir = "./Convert/$cnvdir";
		if (-d "$convdir") {
			opendir("CNVDIR", $convdir) || &fatal_error("cannot_open_dir","$convdir");
			@convlist = readdir("CNVDIR");
			closedir("CNVDIR");
			foreach $file (@convlist) {
				&delete_DBorFILE("$convdir/$file") || &fatal_error("cannot_open_dir","$convdir/$file");
			}
			rmdir("$convdir");
		}
	}
	$convdir = "./Convert";
	if (-d "$convdir") {
		opendir("CNVDIR", $convdir) || &fatal_error("cannot_open_dir","$convdir");
		@convlist = readdir("CNVDIR");
		closedir("CNVDIR");
		foreach $file (@convlist) {
			&delete_DBorFILE("$convdir/$file");
		}
		rmdir("$convdir");
	}
	if (-e "./Setup.pl") { &delete_DBorFILE("./Setup.pl"); }

	$yymain .= qq~<b>$admintxt{'10'}</b>~;
	$yytitle = "$admintxt{'10'}";
	&AdminTemplate;
}

sub GetLastLogins {
	@adminlog = &read_DBorFILE(0,'',$vardir,'adminlog','txt');

	foreach $line (@adminlog) {
		chomp $line;
		@element = split(/\|/, $line);
		if (!${$uid.$element[0]}{'realname'}) { &LoadUser($element[0]); }    # If user is not in memory, s/he must be loaded.
		$element[2] = &timeformat($element[2]);
		$yymain .= qq~
		<a href="$scripturl?action=viewprofile;username=$useraccount{$element[0]}">${$uid.$element[0]}{'realname'}</a> <span class="small">($element[1]) - $element[2]</span><br />
		~;
	}
}

sub FullStats {
	&is_admin_or_gmod;
	my ($numcats, $numboards, $threadcount, $messagecount, $maxdays, $totalt, $totalm, $avgt, $avgm, $memcount);
	&LoadUser($last_member);
	my $thelatestmember = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$last_member}">${$uid.$last_member}{'realname'}</a>~;

	$numcats = 0;

	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	foreach $catid (@categoryorder) {
		$boardlist = $cat{$catid};
		$numcats++;
		(@bdlist) = split(/\,/, $boardlist);
		($catname, $catperms, $catallowcol) = split(/\|/, $catinfo{"$catid"});

		&recursive_boards(@bdlist);
		sub recursive_boards {
			foreach $curboard (@_) {
				chomp $curboard;
				${$uid.$curboard}{'parent'} ? $numsubs++ : $numboards++;
				push(@loadboards, $curboard);
				if($subboard{$curboard}) { &recursive_boards(split(/\|/,$subboard{$curboard})); }
			}
		}
	}

	&BoardTotals("load", @loadboards);
	foreach $curboard (@loadboards) {
		$totalm += ${$uid.$curboard}{'messagecount'};
		$totalt += ${$uid.$curboard}{'threadcount'};
	}

	$avgm = int($totalm / $members_total);
	&LoadAdmins;

	if ($enableclicklog) {
		my (@log);
		@log = &read_DBorFILE(0,'',$vardir,'clicklog','txt');
		$yyclicks    = @log;
		$yyclicks = &NumberFormat($yyclicks);
		$yyclicktext = $admin_txt{'692'};
		$yyclicklink = qq~&nbsp;(<a href="$adminurl?action=showclicks">$admin_txt{'693'}</a>)~;
	} else {
		$yyclicktext = $admin_txt{'692a'};
		$yyclicklink = "";
	}
	my (@elog);
	@elog = &read_DBorFILE(0,'',$vardir,'errorlog','txt');
	$errorslog = @elog;
	$memcount = &NumberFormat($members_total);
	$totalt = &NumberFormat($totalt);
	$totalm = &NumberFormat($totalm);
	$avgm = &NumberFormat($avgm);
	$errorslog = &NumberFormat($errorslog);

	$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
      <td align="left" class="titlebg">
        <img src="$imagesdir/info2.gif" alt="" border="0" /> <b>$admintxt{'28'}</b>
      </td>
     </tr>
     <tr valign="middle">
      <td align="left" class="catbg">
       <i>$admin_txt{'94'}</i>
      </td>
     </tr>
     <tr valign="middle">
      <td align="left" class="windowbg2"><br />
       <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'488'}</div>
       <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$memcount</div>
       <br />
       <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'490'}</div>
       <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$totalt</div>
       <br />
       <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'489'}</div>
       <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$totalm</div>
       <br />
       <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admintxt{'39'}</div>
       <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$avgm</div>
       <br />
       <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'658'}</div>
       <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$numcats</div>
       <br />
       <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'665'}</div>
       <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$numboards</div>
       <br />
       <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'666'}</div>
       <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$numsubs</div>
       <br />
       <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$errorlog{'3'}</div>
       <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$errorslog</div>
       <br />
       <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'691'}&nbsp;<span class="small">($yyclicktext)</span></div>
       <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$yyclicks</div>
       <div style="float: left; width: 55%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$yyclicklink</div>
       <br />&nbsp;<br />
      </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg">
        <i>$admin_txt{'657'}</i>
      </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
        <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'656'}</div>
        <div style="float: left; width: 65%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$thelatestmember</div>
        <br />
        <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'659'}</div>
        <div style="float: left; width: 65%; text-align: left; padding-top: 2px; padding-bottom: 2px;">
        ~;

	# Sorts the threads to find the most recent post
	# No need to check for board access here because only admins have access to this page
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	foreach $catid (@categoryorder) {
		$boardlist = $cat{$catid};
		(@bdlist) = split(/\,/, $boardlist);
		
		&recursive_boards2(@bdlist);
		sub recursive_boards2 {
			foreach $curboard (@_) {
				push(@goodboards, $curboard);
				if($subboard{$curboard}) { &recursive_boards2(split(/\|/,$subboard{$curboard})); }
			}
		}
	}

	&BoardTotals("load", @goodboards);
	# &getlog; not used here !!?
	foreach $curboard (@goodboards) {
		chomp $curboard;
		$lastposttime = ${$uid.$curboard}{'lastposttime'};
		$lastposttime{$curboard} = &timeformat(${$uid.$curboard}{'lastposttime'});
		${$uid.$curboard}{'lastposttime'} = ${$uid.$curboard}{'lastposttime'} eq 'N/A' || !${$uid.$curboard}{'lastposttime'} ? $boardindex_txt{'470'} : ${$uid.$curboard}{'lastposttime'};
		$lastpostrealtime{$curboard} = ${$uid.$curboard}{'lastposttime'} eq 'N/A' || !${$uid.$curboard}{'lastposttime'} ? '' : ${$uid.$curboard}{'lastposttime'};
		if (${$uid.$curboard}{'lastposter'} =~ m~\AGuest-(.*)~) {
			${$uid.$curboard}{'lastposter'} = $1;
			$lastposterguest{$curboard} = 1;
		}
		${$uid.$curboard}{'lastposter'} = ${$uid.$curboard}{'lastposter'} eq 'N/A' || !${$uid.$curboard}{'lastposter'} ? $boardindex_txt{'470'} : ${$uid.$curboard}{'lastposter'};
		${$uid.$curboard}{'messagecount'} = ${$uid.$curboard}{'messagecount'} || 0;
		${$uid.$curboard}{'threadcount'} = ${$uid.$curboard}{'threadcount'} || 0;
		$totalm += ${$uid.$curboard}{'messagecount'};
		$totalt += ${$uid.$curboard}{'threadcount'};

		# determine the true last post on all the boards a user has access to
		if ($lastposttime > $lastthreadtime) {
			$lsdatetime = &timeformat($lastposttime);
			$lsposter = ${$uid.$curboard}{'lastposter'};
			$lssub = ${$uid.$curboard}{'lastsubject'};
			$lspostid = ${$uid.$curboard}{'lastpostid'};
			$lsreply = ${$uid.$curboard}{'lastreply'};
			$lastthreadtime = $lastposttime;
		}
	}
	($lssub, undef) = &Split_Splice_Move($lssub,0);
	&ToChars($lssub);
	$yymain .= qq~<a href="$scripturl?num=$lspostid/$lsreply#$lsreply">$lssub</a> ($lsdatetime)</div>
        <br />
        <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'684'}</div>
        <div style="float: left; width: 65%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$administrators</div>
        <br />
        <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'684a'}</div>
        <div style="float: left; width: 65%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$gmods</div>
        <br />
        <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'425'}</div>
        <div style="float: left; width: 65%; text-align: left; padding-top: 2px; padding-bottom: 2px;">
        <script language="javascript" src="http://www.yabbforum.com/update/versioncheck.js" type="text/javascript"></script>
        <script language="JavaScript" type="text/javascript">  
         <!-- //hide from dinosaurs  
          document.write("$versiontxt{'4'} <b>$YaBBversion</b> - $versiontxt{'5'} <b>"+STABLE+"</b> <p>");  
         // -->
        </script>
        <noscript>$versiontxt{'1'} <img src="http://www.yabbforum.com/images/version/versioncheck.gif" alt="" /></noscript> 
        </div>
        <br />&nbsp;<br />
      </td>
     </tr>
   </table>
 </div>~;

	$yytitle = $admintxt{'28'};
	$action_area = "stats";
	&AdminTemplate;
}

sub LoadAdmins {
	&is_admin_or_gmod;
	my (@members, $curentry, $memdata);
	$administrators = "";
	$gmods          = "";
	&ManageMemberinfo("load");
	my ($memberrealname, $memposition, $membernameCloaked);
	foreach (keys %memberinf) {
		(undef, $memberrealname, undef, $memposition, undef) = split(/\|/, $memberinf{$_}, 5);
		if ($do_scramble_id) { $membernameCloaked = &cloak($_); } else { $membernameCloaked = $_; }
		if ($memposition eq "Administrator") {
			$administrators .= qq~ <a href="$scripturl?action=viewprofile;username=$membernameCloaked">$memberrealname</a><span class="small">,</span> \n~;
		} elsif ($memposition eq "Global Moderator") {
			$gmods .= qq~ <a href="$scripturl?action=viewprofile;username=$membernameCloaked">$memberrealname</a><span class="small">,</span> \n~;
		}
	}
	undef %memberinf;
	$administrators =~ s~<span class="small">,</span> \n\Z~~;
	$gmods          =~ s~<span class="small">,</span> \n\Z~~;
	if ($gmods eq "") { $gmods = qq~&nbsp;~; }
}

sub ShowClickLog {
	&is_admin_or_gmod;

	if ($enableclicklog) { $logtimetext = $admin_txt{'698'}; }
	else { $logtimetext = $admin_txt{'698a'}; }

	my ($totalip, $totalclick, $totalbrow, $totalos, @log, @iplist, $date, @to, @from, @info, @os, @browser, @newiplist, @newbrowser, @newoslist, @newtolist, @newfromlist, $i, $curentry);
	@log = &read_DBorFILE(0,'',$vardir,'clicklog','txt');

	$i = 0;
	foreach $curentry (@log) {
		($iplist[$i], $date, $to[$i], $from[$i], $info[$i]) = split(/\|/, $curentry);
		$i++;
	}
	$i = 0;
	foreach $curentry (@info) {
		if ($curentry !~ /\s\(Win/i || $curentry !~ /\s\(mac/) { $curentry =~ s/\s\((compatible;\s)*/ - /ig; }
		else { $curentry =~ s/(\S)*\(/; /g; }
		if ($curentry =~ /\s-\sWin/i) { $curentry =~ s/\s-\sWin/; win/ig; }
		if ($curentry =~ /\s-\sMac/i) { $curentry =~ s/\s-\sMac/; mac/ig; }
		($browser[$i], $os[$i]) = split(/\;\s/, $curentry);
		if ($os[$i] =~ /\)\s\S/) { ($os[$i], $browser[$i]) = split(/\)\s/, $os[$i]); }
		$os[$i] =~ s/\)//g;
		$i++;
	}

	for ($i = 0; $i < @iplist; $i++) { $iplist{ $iplist[$i] }++; }
	$i = 0;
	while (($key, $val) = each(%iplist)) {
		$newiplist[$i] = [$key, $val];
		$i++;
	}
	$totalclick = @iplist;
	$totalip    = @newiplist;
	for ($i = 0; $i < @newiplist; $i++) {

		if ($newiplist[$i]->[0] =~ /\S+/ && $newiplist[$i]->[0] =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/) {
			$guestiplist .= qq~$newiplist[$i]->[0]&nbsp;<span style="color: #FF0000;">(<i>$newiplist[$i]->[1]</i>)</span><br />~;
		} else {
			&LoadUser($newiplist[$i]->[0]);
			if($do_scramble_id){$cloakedUserName = &cloak($newiplist[$i]->[0]); } else {$cloakedUserName = $newiplist[$i]->[0]; }
			my $displayUserName = $newiplist[$i]->[0];
			if(${$uid.$displayUserName}{'realname'} && (${$uid.$displayUserName}{'realname'} ne $newiplist[$i]->[0])) 	{
				$displayUserName = ${$uid.$displayUserName}{'realname'};}
			$useriplist .= qq~<a href="$scripturl?action=viewprofile;username=$cloakedUserName">$displayUserName</a>&nbsp;<span style="color: #FF0000;">(<i>$newiplist[$i]->[1]</i>)</span><br />~;
		}
	}

	for ($i = 0; $i < @browser; $i++) { $browser{ $browser[$i] }++; }
	$i = 0;
	while (($key, $val) = each(%browser)) {
		$newbrowser[$i] = [$key, $val];
		$i++;
	}
	$totalbrow = @newbrowser;
	for ($i = 0; $i < @newbrowser; $i++) {
		if ($newbrowser[$i]->[0] =~ /\S+/) {
			$browserlist .= qq~$newbrowser[$i]->[0] &nbsp;<span style="color: #FF0000;">(<i>$newbrowser[$i]->[1]</i>)</span><br />~;
		}
	}

	for ($i = 0; $i < @os; $i++) { $os{ $os[$i] }++; }
	$i = 0;
	while (($key, $val) = each(%os)) {
		$newoslist[$i] = [$key, $val];
		$i++;
	}
	$totalos = @newoslist;
	for ($i = 0; $i < @newoslist; $i++) {
		if ($newoslist[$i]->[0] =~ /\S+/) {
			$oslist .= qq~$newoslist[$i]->[0] &nbsp;<span style="color: #FF0000;">(<i>$newoslist[$i]->[1]</i>)</span><br />~;
		}
	}

	for ($i = 0; $i < @to; $i++) { $to{ $to[$i] }++; }
	$i = 0;
	while (($key, $val) = each(%to)) {
		$newtolist[$i] = [$key, $val];
		$i++;
	}
	for ($i = 0; $i < @newtolist; $i++) {
		if ($newtolist[$i]->[0] =~ /\S+/) {
			$scriptcalls .= qq~<a href="$newtolist[$i]->[0]" target="_blank">$newtolist[$i]->[0]</a>&nbsp;<span style="color: #FF0000;">(<i>$newtolist[$i]->[1]</i>)</span><br />~;
		}
	}

	for ($i = 0; $i < @from; $i++) { $from{ $from[$i] }++; }
	$i = 0;
	while (($key, $val) = each(%from)) {
		$newfromlist[$i] = [$key, $val];
		$i++;
	}
	for ($i = 0; $i < @newfromlist; $i++) {
		if ($newfromlist[$i]->[0] =~ /\S+/ && $newfromlist[$i]->[0] !~ m~$boardurl~i) {
		$message = qq~<a href="$newfromlist[$i]->[0]" target="_blank">$newfromlist[$i]->[0]</a>~;
		#	&wrap;
		#	if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
		#	&DoUBBC;
			&wrap2;
			$referlist .= qq~$message&nbsp;<span style="color: #FF0000;">(<i>$newfromlist[$i]->[1]</i>)</span><br />~;
		}
	}

	$yymain .= qq~

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
      <td align="left" class="titlebg">
       <img src="$imagesdir/info2.gif" alt="" border="0" /> <b>$admin_txt{'693'}</b>
      </td>
     </tr>
     <tr valign="middle">
      <td align="left" class="windowbg2"><br />
       $admin_txt{'697'}$logtimetext<br /><br />
      </td>
     </tr>
   </table>
 </div>~;
 
	if ($enableclicklog) {
		$yymain .= qq~

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
    <tr valign="middle">
     <td align="left" class="titlebg" colspan="2">
      <img src="$imagesdir/cat.gif" alt="" border="0" /> <b>$admin_txt{'694'}</b>
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="windowbg2" colspan="2"><br />
      $admin_txt{'691'}: $totalclick<br />
      $admin_txt{'743'}: $totalip<br /><br />
     </td>
    </tr>
    <tr valign="middle">
     <td align="center" class="catbg" width="50%">
      <b>$clicklog_txt{'users'}</b>
     </td>
     <td align="center" class="catbg" width="50%">
      <b>$clicklog_txt{'guests'}</b>
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="windowbg2" valign="top" width="50%"><br />
      $useriplist<br />
     </td>
     <td align="left" class="windowbg2" valign="top" width="50%"><br />
      $guestiplist<br />
     </td>
    </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
    <tr valign="middle">
     <td align="left" class="titlebg">
      <img src="$imagesdir/cat.gif" alt="" border="0" /> <b>$admin_txt{'695'}</b>
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="catbg">
      <i>$admin_txt{'744'}: $totalbrow</i>
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="windowbg2"><br />
      $browserlist<br />
     </td>
    </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
    <tr valign="middle">
     <td align="left" class="titlebg">
      <img src="$imagesdir/cat.gif" alt="" border="0" /> <b>$admin_txt{'696'}</b>
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="catbg">
      <i>$admin_txt{'745'}: $totalos</i>
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="windowbg2"><br />
      $oslist<br />
     </td>
    </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
    <tr valign="middle">
     <td align="left" class="titlebg">
      <img src="$imagesdir/cat.gif" alt="" border="0" /> <b>$admin_txt{'696a'}</b>
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="windowbg2"><br />
      $scriptcalls<br />
     </td>
    </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
    <tr valign="middle">
     <td align="left" class="titlebg">
      <img src="$imagesdir/cat.gif" alt="" border="0" /> <b>$admin_txt{'838'}</b>
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="windowbg2"><br />
      $referlist<br />
     </td>
    </tr>
   </table>
 </div>
~;
	}

	$yytitle     = $admin_txt{'693'};
	$action_area = "showclicks";
	&AdminTemplate;
}

sub DeleteOldMessages {
	&is_admin_or_gmod;

	$maxdays = &read_DBorFILE(0,'',$vardir,'oldestmes','txt');

	$yytitle = "$aduptxt{'04'}";
	$yymain .= qq~
<form action="$adminurl?action=removeoldthreads" method="post">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
    <tr valign="middle">
     <td align="left" class="titlebg">
      <img src="$imagesdir/ban.gif" alt="" border="0" /> <b>$aduptxt{'04'}</b>
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="windowbg2"><br />
      $aduptxt{'05'}<br /><br />
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="windowbg2"><br />
      <label for="keep_them">$admin_txt{'4'}</label> <input type="checkbox" name="keep_them" id="keep_them" value="1" /><br />
      <label for="maxdays">$admin_txt{'124'} <input type=text name="maxdays" id="maxdays" size="4" value="$maxdays" /> $admin_txt{'579'} $admin_txt{'2'}:</label><br /><br />
      <div align="left" style="margin-left: 25px; margin-right: auto;">~;

	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }

	foreach $catid (@categoryorder) {
		$boardlist = $cat{$catid};
		(@bdlist) = split(/\,/, $boardlist);
		($catname, $catperms) = split(/\|/, $catinfo{"$catid"});

		foreach $curboard (@bdlist) {
			($boardname, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});
			&ToChars($boardname);
			$selectname = $curboard . 'check';
			$yymain .= qq~
		<input type="checkbox" name="$selectname" id="$selectname" value="1" />&nbsp;<label for="$selectname">$boardname</label><br />~;
		}
	}
	$yymain .= qq~
      </div><br />
     </td>
    </tr>
    <tr valign="middle">
     <td align="center" class="catbg">
      <input type="submit" value="$admin_txt{'31'}" class="button" />
     </td>
    </tr>
   </table>
 </div>
</form>~;

	$action_area = "deleteoldthreads";
	&AdminTemplate;
}

sub DeleteMultiMembers {
	&is_admin_or_gmod;

	&automaintenance("on");

	my ($count, $currentmem, $start, $sortmode, $sortorder, $deadusers, @userslist);
	chomp $FORM{'button'};
	chomp $FORM{'emailsubject'};
	chomp $FORM{'emailtext'};
	$tmpemailsubject = $FORM{'emailsubject'};
	$tmpemailtext = $FORM{'emailtext'};
	if ($FORM{'button'} != 1 && $FORM{'button'} != 2) { &fatal_error('no_access'); }

	if ($FORM{'del_mail'} || $FORM{'emailtext'} ne '') { require "$sourcedir/Mailer.pl"; }


	if ($FORM{'button'} == 1 && $FORM{'emailtext'} ne "") {
		$FORM{'emailsubject'} =~ s~\|~&#124~g;
		$FORM{'emailtext'}    =~ s~\|~&#124~g;
		$FORM{'emailtext'} =~ s/\r(?=\n*)//g;
		$mailline = qq~$date|$FORM{'emailsubject'}|$FORM{'emailtext'}|$username~;
		&MailList($mailline);
	}

	my $templanguage = $language;

	$count = 0;
	while ($members_total >= $count) {
		$currentmem = $FORM{"member$count"};
		if (exists $FORM{"member$count"}) {
			if (&checkfor_DBorFILE("$memberdir/$currentmem.vars")) { # Bypass dead entries.
				&LoadUser($currentmem);
				if ($FORM{'emailtext'} ne '') {
					$emailsubject = $FORM{'emailsubject'};
					$emailtext = $FORM{'emailtext'};
					$emailsubject =~ s~\[name\]~${$uid.$currentmem}{'realname'}~ig;
					$emailsubject =~ s~\[username\]~$currentmem~ig;
					$emailtext =~ s~\[name\]~${$uid.$currentmem}{'realname'}~ig;
					$emailtext =~ s~\[username\]~$currentmem~ig;
					&sendmail(${$uid.$currentmem}{'email'}, $emailsubject, $emailtext);
				} elsif ($FORM{'del_mail'}) {
					$language = ${$uid.$currentmem}{'language'};
					&LoadLanguage('Email');
					my $message = &template_email($deleteduseremail, {'displayname' => ${$uid.$currentmem}{'realname'}});
					&sendmail(${$uid.$currentmem}{'email'}, "$deletedusersybject $mbname", $message, '', $emailcharset);
				}
				undef %{$uid.$currentmem} if $currentmem ne $username;
			}
			if ($FORM{'button'} == 2) {
				&delete_DBorFILE("$memberdir/$currentmem.dat");
				# &delete_DBorFILE("$memberdir/$currentmem.vars") does delete also the
				# other files content if in SQL-Database!!! So no further need for &delete_DBorFILE(...)
				&delete_DBorFILE("$memberdir/$currentmem.vars");
				&delete_DBorFILE("$memberdir/$currentmem.ims");
				&delete_DBorFILE("$memberdir/$currentmem.msg");
				&delete_DBorFILE("$memberdir/$currentmem.log");
				&delete_DBorFILE("$memberdir/$currentmem.rlog");
				&delete_DBorFILE("$memberdir/$currentmem.outbox");
				&delete_DBorFILE("$memberdir/$currentmem.imstore");
				&delete_DBorFILE("$memberdir/$currentmem.imdraft");
				# save name up
				push (@userslist, $currentmem);
				# For security, remove username from mod position
				&KillModerator($currentmem);
			}
		}
		$count++;
	}
	&automaintenance("off");

	if (@userslist) { &MemberIndex("remove", join(',', @userslist)); }

	$language = $templanguage;
	if ($FORM{'button'} == 1) {
		$yySetLocation = qq~$adminurl?action=mailing;sort=$INFO{'sort'}~;
	} else {
		$yySetLocation = qq~$adminurl?action=viewmembers;start=$INFO{'start'};sort=$INFO{'sort'};reversed=$INFO{'reversed'}~;
	}
	&redirectexit;
}

sub ipban {
	&is_admin_or_gmod;

	my ($eban, $iban, $uban) = ($email_banlist, $ip_banlist, $user_banlist);
	$iban =~ s/,/\n/g;
	$eban =~ s/,/\n/g;
	$uban =~ s/,/\n/g;

	$yymain .= qq~
<form action="$adminurl?action=ipban2" method="post">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
    <tr valign="middle">
     <td align="left" class="titlebg">
      <img src="$imagesdir/ban.gif" alt="" border="0" /><b>$admin_txt{'340'}</b>
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="catbg">
      <label for="ban"><span class="small">$admin_txt{'724'}</span></label>
     </td>
    </tr>
    <tr valign="middle">
     <td align="center" class="windowbg2"><br />
      <textarea cols="60" rows="10" name="ban" id="ban" style="width: 95%">$iban</textarea><br /><br />
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="catbg">
      <label for="ban_email"><span class="small">$admin_txt{'725'}</span></label>
     </td>
    </tr>
    <tr valign="middle">
     <td align="center" class="windowbg2"><br />
      <textarea cols="60" rows="10" name="ban_email" id="ban_email" style="width: 95%">$eban</textarea><br /><br />
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="catbg">
      <label for="ban_memname"><span class="small">$admin_txt{'725a'}</span></label>
     </td>
    </tr>
    <tr valign="middle">
     <td align="center" class="windowbg2"><br />
      <textarea cols="60" rows="10" name="ban_memname" id="ban_memname" style="width: 95%">$uban</textarea><br /><br />
     </td>
    </tr>
    <tr valign="middle">
     <td align="center" class="catbg">
      <input type="submit" value="$admin_txt{'10'}" class="button" />
     </td>
    </tr>
   </table>
 </div>
</form>~;

	$yytitle     = "$admin_txt{'340'}";
	$action_area = "ipban";
	&AdminTemplate;
}

sub ipban2 {
	&is_admin_or_gmod;

	$FORM{'ban'} =~ tr/\r//d;
	$FORM{'ban'} =~ s/\A[\s\n]+| |[\s\n]+\Z//g;
	$FORM{'ban'} =~ s~\n\s*\n~\n~g;
	$FORM{'ban'} =~ s/\n/,/g;
	$FORM{'ban_email'} =~ tr/\r//d;
	$FORM{'ban_email'} =~ s/\A[\s\n]+| |[\s\n]+\Z//g;
	$FORM{'ban_email'} =~ s~\n\s*\n~\n~g;
	$FORM{'ban_email'} =~ s/\n/,/g;
	$FORM{'ban_memname'} =~ tr/\r//d;
	$FORM{'ban_memname'} =~ s/\A[\s\n]+| |[\s\n]+\Z//g;
	$FORM{'ban_memname'} =~ s~\n\s*\n~\n~g;
	$FORM{'ban_memname'} =~ s/\n/,/g;

	($email_banlist, $ip_banlist, $user_banlist) = ($FORM{'ban_email'}, $FORM{'ban'}, $FORM{'ban_memname'});

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');

	$yySetLocation = $adminurl;
	&redirectexit;
}

sub ipban_update {
	# This is for quick updating for banning + unbanning
	&is_admin_or_gmod;

	my ($ban_details, @banlist);
	if ($INFO{'ban'}) {
		foreach (split(/,/, $ip_banlist)) {
			if ($_ ne $INFO{'ban'}) { push(@banlist, $_); }
		}
		push(@banlist, $INFO{'ban'}) unless $INFO{'unban'};
		$ip_banlist = join(',', @banlist);

	} elsif ($INFO{'ban_email'}) {
		foreach (split(/,/, $email_banlist)) {
			if ($_ ne $INFO{'ban_email'}) { push(@banlist, $_); }
		}
		push(@banlist, $INFO{'ban_email'}) unless $INFO{'unban'};
		$email_banlist = join(',', @banlist);

	} elsif ($INFO{'ban_memname'}) {
		$INFO{'ban_memname'} = $do_scramble_id ? &decloak($INFO{'ban_memname'}) : $INFO{'ban_memname'};
		foreach (split(/,/, $user_banlist)) {
			if ($_ ne $INFO{'ban_memname'}) { push(@banlist, $_); }
		}
		push(@banlist, $INFO{'ban_memname'}) unless $INFO{'unban'};
		$user_banlist = join(',', @banlist);
	}

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');

	$yySetLocation = qq~$scripturl?action=viewprofile;username=$INFO{'username'}~;
	&redirectexit;
}

sub ver_detail {
	&is_admin_or_gmod;

	require "$boarddir/$yyexec.$yyext";
	$adminindexplver =~ s/\$Revision\: (.*?) \$/Build $1/ig;
	$YaBBplver =~ s/\$Revision\: (.*?) \$/Build $1/ig;

	$yymain .= qq~
	<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
	<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
			<td align="left" class="titlebg" colspan="3"><img src="$imagesdir/info2.gif" alt="" border="0" /><b>$admin_txt{'429'}</b></td>
     </tr>
	<tr valign="middle">
		<td align="left" class="windowbg2" colspan="3">
		<script language="javascript" src="http://www.yabbforum.com/update/versioncheck.js" type="text/javascript"></script>
		$versiontxt{'4'} <b>$YaBBversion</b><br />
		<script language="JavaScript" type="text/javascript">  
		<!-- //hide from dinosaurs  
			document.write("$versiontxt{'5'} <b>"+STABLE+"</b><br />$versiontxt{'7'} <b>"+BETA+"</b>");  
		// -->
		</script>
		<noscript>$versiontxt{'1'} <img src="http://www.yabbforum.com/images/version/versioncheck.gif" alt="" /></noscript> 
	</td>
	</tr>
	<tr valign="middle">
		<td align="center" class="catbg" width="40%"><b>$admin_txt{'495'}</b><br /></td>
		<td align="center" class="catbg" width="60%"><b>$admin_txt{'494'}</b><br /></td>
	</tr>
	<tr>
		<td class="windowbg2" align="left">$admin_txt{'496'}</td>
		<td class="windowbg2" align="left"><i>$YaBBversion</i></td>
	</tr><tr>
		<td class="windowbg2" align="left">$yyexec.$yyext</td>
		<td class="windowbg2" align="left"><i>$YaBBplver</i></td>
	</tr><tr>
		<td class="windowbg2" align="left">AdminIndex.pl</td>
		<td class="windowbg2" align="left"><i>$adminindexplver</i></td>
	</tr>~;

	opendir(LNGDIR, $langdir);
	my @lfilesanddirs = readdir(LNGDIR);
	close(LNGDIR);
	foreach $fld (@lfilesanddirs) {
		if (-d "$langdir/$fld" && $fld =~ m^\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@/]+\Z^ && -e "$langdir/$fld/Main.lng") {
			my @ver = &read_DBorFILE(0,'',"$langdir/$fld",'version','txt');
			$yymain .= qq~
	<tr>
		<td width="30%" class="windowbg2" align="left">$fld Language Pack</td>
		<td width="35%" class="windowbg2" align="left"><i>$ver[0]</i></td>
	</tr>~;
		}
	}
	$yymain .= qq~
	<tr valign="middle">
		<td align="left" class="titlebg" colspan="3"><b>$admin_txt{'430'}</b></td>
	</tr>~;

	opendir(DIR, $admindir);
	my @adminDIR = readdir(DIR);
	close(DIR);
	@adminDIR = sort (@adminDIR);
	foreach my $fileinDIR (@adminDIR) {
		chomp $fileinDIR;
		if ($fileinDIR =~ m/\.pl\Z/) {
			require "$admindir/$fileinDIR";
			my $txtrevision = lc $fileinDIR;
			$txtrevision =~ s/\.pl/plver/ig;
			$$txtrevision =~ s/\$Revision\: (.*?) \$/Build $1/ig;
			$yymain .= qq~
	<tr>
		<td class="windowbg2" align="left">$fileinDIR</td>
		<td class="windowbg2" align="left"><i>$$txtrevision</i></td>
	</tr>~;
		}
	}
	$yymain .= qq~
	<tr valign="middle">
		<td align="left" class="titlebg" colspan="3"><b>$admin_txt{'431'}</b></td>
	</tr>~;

	opendir(DIR, $sourcedir);
	my @sourceDIR = readdir(DIR);
	close(DIR);
	@sourceDIR = sort (@sourceDIR);
	foreach my $fileinDIR (@sourceDIR) {
		chomp $fileinDIR;
		if ($fileinDIR =~ m/\.pl\Z/) {
			require "$sourcedir/$fileinDIR";
			my $txtrevision = lc $fileinDIR;
			$txtrevision =~ s/\.pl/plver/ig;
			$$txtrevision =~ s/\$Revision\: (.*?) \$/Build $1/ig;
			$yymain .= qq~
			<tr>
				<td class="windowbg2" align="left">$fileinDIR</td>
				<td class="windowbg2" align="left"><i>$$txtrevision</i></td>
			</tr>~;
		}
	}

	$yymain .= qq~
	</table>
	</div>~;

	$yytitle = $admin_txt{'429'};
	$action_area = "detailedversion";
	&AdminTemplate;
}

sub Refcontrol {
	&is_admin_or_gmod;
	&LoadLanguage('RefControl');

	@scriptlines = &read_DBorFILE(0,'',$sourcedir,'SubList','pl');

	@allowed = &read_DBorFILE(0,'',$vardir,'allowed','txt');

	$startread = 0;
	$counter   = 0;

	foreach $scriptline (@scriptlines) {
		chomp $scriptline;
		if (substr($scriptline, 0, 1) eq "'") {
			$scriptline =~ /\'(.*?)\'/;
			$actionfound = $1;
			push(@actfound, $actionfound);
			$counter++;
		}
	}
	$column  = int($counter / 3);
	$counter = 0;
	foreach $actfound (@actfound) {
		$selected = "";
		foreach $allow (@allowed) {
			chomp $allow;
			if ($actfound eq $allow) { $selected = ' checked="checked"'; last; }
		}
		$refexpl_txt{$actfound} =~ s/"/'/g; # XHTML Validation
		$dismenu .= qq~<input type="checkbox" name="$actfound" id="$actfound"$selected />&nbsp;<label for="$actfound"><img src="$imagesdir/question.gif" align="middle" alt="$reftxt{'1a'} $refexpl_txt{$actfound}" title="$reftxt{'1a'} $refexpl_txt{$actfound}" border="0" /> $actfound</label ><br />\n~;
		$counter++;
		if ($counter > $column + 1) {
			$dismenu .= qq~</td><td align="left" class="windowbg2" valign="top" width="33%">~;
			$counter = 0;
		}
	}
	$yymain .= qq~
<form action="$adminurl?action=referer_control2" method="post">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
    <tr valign="middle">
     <td align="left" class="titlebg" colspan="3">
      <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$reftxt{'1'}</b>
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="windowbg2" colspan="3"><br />
      $reftxt{'2'}<br />
      <span class="small">
      $reftxt{'3'}<br /><br />
      </span>
     </td>
    </tr>
    <tr valign="middle">
     <td align="left" class="windowbg2" valign="top" width="33%">
      $dismenu
     </td>
    </tr>
    <tr valign="middle">
     <td align="center" class="catbg" colspan="3">
      <input type="submit" value="$reftxt{'4'}" class="button" />
     </td>
     </tr>
   </table>
 </div>
</form>~;

	$yytitle     = "$reftxt{'1'}";
	$action_area = "referer_control";
	&AdminTemplate;
}

sub Refcontrol2 {
	&is_admin_or_gmod;

	@scriptlines = &read_DBorFILE(0,'',$sourcedir,'SubList','pl');

	$startread = 0;
	$counter   = 0;
	foreach $scriptline (@scriptlines) {
		chomp $scriptline;
		if (substr($scriptline, 0, 1) eq "'") {
			$scriptline =~ /\'(.*?)\'/;
			$actionfound = $1;
			push(@actfound, $actionfound);
			$counter++;
		}
	}

	my @outfile;
	foreach $actfound (@actfound) {
		if ($FORM{$actfound}) { push(@outfile, "$actfound\n"); }
	}

	&write_DBorFILE(0,'',$vardir,'allowed','txt',@outfile);

	$yySetLocation = $adminurl;
	&redirectexit;
}

sub AddMember {
	&is_admin_or_gmod;
	&LoadLanguage('Register');
	if ($regcheck) {
		require "$sourcedir/Decoder.pl";
		&validation_code;
	}

	$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/ajax.js"></script>
<form action="$adminurl?action=addmember2" method="post" name="creator"> 
   <table align="center" border="0" cellspacing="1" cellpadding="3" class="bordercolor">
    <tr>
     <td colspan="2" width="100%" valign="middle" class="titlebg">
      <img src="$imagesdir/register.gif" alt="" border="0" style="vertical-align: middle;" /><b> $admintxt{'17a'}</b>
     </td>
    </tr>
    <tr>
     <td width="30%" class="windowbg"><label for="regusername"><b>$register_txt{'98'}:</b></label></td>
     <td width="70%" class="windowbg"><input type="text" name="regusername" id="regusername" onchange="checkAvail('$scripturl',this.value,'user','$name_cannot_be_userid')" size="30" maxlength="18" /><input type="hidden" name="_session_id_" id="_session_id_" value="$sessionid" /><input type="hidden" name="regdate" id="regdate" value="$regdate" /><div id="useravailability"></div></td>
    </tr>
    <tr>
     <td width="30%" class="windowbg"><label for="regrealname"><b>$register_txt{'98a'}:</b></label></td>
     <td width="70%" class="windowbg"><input type="text" name="regrealname" id="regrealname" onchange="checkAvail('$scripturl',this.value,'display','$name_cannot_be_userid')" size="30" maxlength="30" /><div id="displayavailability"></div></td>
    </tr>
    <tr>
     <td width="30%" class="windowbg"><label for="email"><b>$register_txt{'69'}:</b></label></td>
     <td width="70%" class="windowbg"><input type="text" maxlength="100" name="email" id="email" onchange="checkAvail('$scripturl',this.value,'email')" size="50" /><div id="emailavailability"></div></td>
    </tr>~;
	if ($allow_hide_email == 1) {
		$yymain .= qq~
    <tr>
     <td width="30%" class="windowbg"><label for="hideemail"><b>$register_txt{'721'}</b></label></td>
     <td width="70%" class="windowbg"><input type="checkbox" name="hideemail" id="hideemail" value="1" checked="checked" /></td>
    </tr>~;
	}

	# Language selector
	$yymain .= qq~
    <tr>
     <td width="30%" class="windowbg"><label for="userlang"><b>$register_txt{'101'}</b></label></td>
     <td width="70%" class="windowbg"><select name="userlang" id="userlang">~;
	opendir(LNGDIR, $langdir);
	foreach (sort {lc($a) cmp lc($b)} readdir(LNGDIR)) {
		my $displang = $_;
		$displang =~ s~(.+?)\_(.+?)$~$1 ($2)~gi;
		if (-e "$langdir/$_/Main.lng") { $yymain .= qq~<option value="$_"~ . ($_ eq $language ? ' selected="selected"' : '') . qq~>$displang</option>~; }
	}
	close(LNGDIR);
	$yymain .= qq~</select></td>
    </tr>~;

	unless ($emailpassword) {
		$yymain .= qq~
    <tr>
     <td width="30%" class="windowbg"><label for="passwrd1"><b>$register_txt{'81'}:</b></label></td>
     <td width="70%" class="windowbg">
	<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/YaBB.js"></script>
	<div style="float:left;"><input type="password" maxlength="30" name="passwrd1" id="passwrd1" size="30" onkeyup="runPassword(this.value);" onkeypress="capsLock(event,'cappasswrd1')" /> &nbsp; </div>
	<div style="float:left; width: 150px; height: 20px;">
	<div id="password-strength-meter" style="background: transparent url($imagesdir/empty_bar.gif) repeat-x center left; height: 4px"></div>
	<div class="pstrength-bar" id="passwrd1_bar" style="border: 1px solid #FFFFFF; height: 4px"></div>
	<div class="pstrength-info" id="passwrd1_text">&nbsp;</div>
	</div>
	<div style="clear:left; color: red; font-weight: bold; display: none" id="cappasswrd1">$register_txt{'capslock'}</div>
	<div style="clear:left; color: red; font-weight: bold; display: none" id="cappasswrd1_char">$register_txt{'wrong_char'}: <span id="cappasswrd1_character">&nbsp;</span></div>
     </td>
    </tr>
    <tr>
     <td width="30%" class="windowbg"><label for="passwrd2"><b>$register_txt{'82'}:</b></label></td>
     <td width="70%" class="windowbg">
	<input type="password" maxlength="30" name="passwrd2" id="passwrd2" size="30" onkeypress="capsLock(event,'cappasswrd2')" />
	<div style="color: red; font-weight: bold; display: none" id="cappasswrd2">$register_txt{'capslock'}</div>
	<div style="color: red; font-weight: bold; display: none" id="cappasswrd1_char">$register_txt{'wrong_char'}: <span id="cappasswrd1_character">&nbsp;</span></div>
     </td>
    </tr>~;
	}

	if ($regcheck) {
		$yymain .= qq~
    <tr>
     <td width="30%" class="windowbg"><label for="verification"><b>$floodtxt{'1'}:</b></label></td>
     <td width="70%" class="windowbg">$showcheck<br /><label for="verification"><span class="small">$floodtxt{'casewarning'}</span></label></td>
    </tr>
    <tr>
     <td width="30%" class="windowbg"><label for="verification"><b>$floodtxt{'3'}:</b></label></td>
     <td width="70%" class="windowbg"><input type="text" maxlength="30" name="verification" id="verification" size="30" /></td>
    </tr>~;
	}

	$yymain .= qq~
    <tr>
     <td colspan="2" align="center" class="catbg">
      <input type="submit" value="$register_txt{'97'}" class="button" />
     </td>
    </tr>
   </table>
</form>

<script language="JavaScript1.2" type="text/javascript">
<!--
	// Password_strength_meter start
	var verdects = new Array("$pwstrengthmeter_txt{'1'}","$pwstrengthmeter_txt{'2'}","$pwstrengthmeter_txt{'3'}","$pwstrengthmeter_txt{'4'}","$pwstrengthmeter_txt{'5'}","$pwstrengthmeter_txt{'6'}","$pwstrengthmeter_txt{'7'}","$pwstrengthmeter_txt{'8'}");
	var colors = new Array("#8F8F8F","#BF0000","#FF0000","#00A0FF","#33EE00","#339900");
	var scores = new Array($pwstrengthmeter_scores);
	var common = new Array($pwstrengthmeter_common);
	var minchar = $pwstrengthmeter_minchar;

	function runPassword(D) {
		var nPerc = checkPassword(D);
		if (nPerc > -199 && nPerc < 0) {
			strColor = colors[0];
			strText = verdects[1];
			strWidth = "5%";
		} else if (nPerc == -200) {
			strColor = colors[1];
			strText = verdects[0];
			strWidth = "0%";
		} else if (scores[0] == -1 && scores[1] == -1 && scores[2] == -1 && scores[3] == -1) {
			strColor = colors[4];
			strText = verdects[7];
			strWidth = "100%";
		} else if (nPerc <= scores[0]) {
			strColor = colors[1];
			strText = verdects[2];
			strWidth = "10%";
		} else if (nPerc > scores[0] && nPerc <= scores[1]) {
			strColor = colors[2];
			strText = verdects[3];
			strWidth = "25%";
		} else if (nPerc > scores[1] && nPerc <= scores[2]) {
			strColor = colors[3];
			strText = verdects[4];
			strWidth = "50%";
		} else if (nPerc > scores[2] && nPerc <= scores[3]) {
			strColor = colors[4];
			strText = verdects[5];
			strWidth = "75%";
		} else {
			strColor = colors[5];
			strText = verdects[6];
			strWidth = "100%";
		}
		document.getElementById("passwrd1_bar").style.width = strWidth;
		document.getElementById("passwrd1_bar").style.backgroundColor = strColor;
		document.getElementById("passwrd1_text").style.color = strColor;
		document.getElementById("passwrd1_text").childNodes[0].nodeValue = strText;
	}

	function checkPassword(C) {
		if (C.length == 0 || C.length < minchar) return -100;

		for (var D = 0; D < common.length; D++) {
			if (C.toLowerCase() == common[D]) return -200;
		}

		var F = 0;
		if (C.length >= minchar && C.length <= (minchar+2)) {
			F = (F + 6)
		} else if (C.length >= (minchar + 3) && C.length <= (minchar + 4)) {
			F = (F + 12)
		} else if (C.length >= (minchar + 5)) {
			F = (F + 18)
		}

		if (C.match(/[a-z]/)) {
			F = (F + 1)
		}
		if (C.match(/[A-Z]/)) {
			F = (F + 5)
		}
		if (C.match(/d+/)) {
			F = (F + 5)
		}
		if (C.match(/(.*[0-9].*[0-9].*[0-9])/)) {
			F = (F + 7)
		}
		if (C.match(/.[!,\@,#,\$,\%,^,&,*,?,_,\~]/)) {
			F = (F + 5)
		}
		if (C.match(/(.*[!,\@,#,\$,\%,^,&,*,?,_,\~].*[!,\@,#,\$,\%,^,&,*,?,_,\~])/)) {
			F = (F + 7)
		}
		if (C.match(/([a-z].*[A-Z])|([A-Z].*[a-z])/)){
			F = (F + 2)
		}
		if (C.match(/([a-zA-Z])/) && C.match(/([0-9])/)) {
			F = (F + 3)
		}
		if (C.match(/([a-zA-Z0-9].*[!,\@,#,\$,\%,^,&,*,?,_,\~])|([!,\@,#,\$,\%,^,&,*,?,_,\~].*[a-zA-Z0-9])/)) {
			F = (F + 3)
		}
		return F;
	}
	// Password_strength_meter end
// -->
</script>
~;

	$yymain .= qq~
<script type="text/javascript" language="JavaScript">
 <!--
	document.creator.regusername.focus();
	//function 
 //-->
</script>~;

	$yytitle     = "$register_txt{'97'}";
	$action_area = "addmember";
	&AdminTemplate;
}

sub AddMember2 {
	&is_admin_or_gmod;
	&LoadLanguage('Register');
	&LoadLanguage('Main');
	my %member;
	while (($key, $value) = each(%FORM)) {
		$value =~ s~\A\s+~~;
		$value =~ s~\s+\Z~~;
		$value =~ s~[\n\r]~~g;
		$member{$key} = $value;
	}
	$member{'username'} =~ s/\s/_/g;

	# Make sure users can't register with banned details
	&banning($member{'regusername'}, $member{'email'}, 1);

	# check if there is a system hash named like this by checking existence through size
	my $hsize = keys(%{ $member{'regusername'} });
	if ($hsize > 0) { &fatal_error("system_prohibited_id"); }
	if (length($member{'regusername'}) > 25) { $member{'regusername'} = substr($member{'regusername'}, 0, 25); }
	&fatal_error("no_username","($member{'regusername'})") if $member{'regusername'} eq '';
	&fatal_error("id_alfa_only","($member{'regusername'})") if $member{'regusername'} eq '_' || $member{'regusername'} eq '|';
	&fatal_error("id_reserved","($member{'regusername'})") if $member{'regusername'} =~ /guest/i;
	&fatal_error("invalid_character","$register_txt{'35'} $register_txt{'241re'}") if $member{'regusername'} =~ /[^\w\+\-\.\@]/;
	&fatal_error("no_email","($member{'regusername'})") if $member{'email'} eq "";
	&fatal_error("id_taken","($member{'regusername'})") if &checkfor_DBorFILE("$memberdir/$member{'regusername'}.vars");
	&fatal_error("password_is_userid") if $member{'regusername'} eq $member{'passwrd1'};

	&FromChars($member{'regrealname'});
	$convertstr = $member{'regrealname'};
	$convertcut = 30;
	&CountChars;
	$member{'regrealname'} = $convertstr;
	&fatal_error("realname_to_long","($member{'regrealname'} => $convertstr)") if $cliped;
	&fatal_error("invalid_character", "$register_txt{'38'} $register_txt{'241re'}") if $member{'regrealname'} =~ /[^ \w\x80-\xFF\[\]\(\)#\%\+,\-\|\.:=\?\@\^]/;

	if ($regcheck) {
		require "$sourcedir/Decoder.pl";
		&validation_check($FORM{'verification'});
	}

	if ($emailpassword) {
		srand();
		$member{'passwrd1'} = int(rand(100));
		$member{'passwrd1'} =~ tr/0123456789/ymifxupbck/;
		$_ = int(rand(77));
		$_ =~ tr/0123456789/q8dv7w4jm3/;
		$member{'passwrd1'} .= $_;
		$_ = int(rand(89));
		$_ =~ tr/0123456789/y6uivpkcxw/;
		$member{'passwrd1'} .= $_;
		$_ = int(rand(188));
		$_ =~ tr/0123456789/poiuytrewq/;
		$member{'passwrd1'} .= $_;
		$_ = int(rand(65));
		$_ =~ tr/0123456789/lkjhgfdaut/;
		$member{'passwrd1'} .= $_;

	} else {
		&fatal_error("password_mismatch","($member{'regusername'})") if ($member{'passwrd1'} ne $member{'passwrd2'});
		&fatal_error("no_password","($member{'regusername'})") if ($member{'passwrd1'} eq '');
		&fatal_error("invalid_character","$register_txt{'36'} $register_txt{'241'}") if ($member{'passwrd1'}  =~ /[^\s\w!\@#\$\%\^&\*\(\)\+\|`~\-=\\:;'",\.\/\?\[\]\{\}]/);
	}

	&fatal_error("invalid_character","$register_txt{'69'} $register_txt{'241e'}") if ($member{'email'} !~ /^[\w\-\.\+]+\@[\w\-\.\+]+\.\w{2,4}$/);
	&fatal_error("invalid_email") if (($member{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($member{'email'} !~ /\A.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?\Z/));

	if (lc $member{'regusername'} eq lc &MemberIndex("check_exist", $member{'regusername'})) { &fatal_error("id_taken","($member{'regusername'})"); }
	if (lc $member{'email'} eq lc &MemberIndex("check_exist", $member{'email'})) { &fatal_error("email_taken","($member{'email'})"); }
	if (lc $member{'regrealname'} eq lc &MemberIndex("check_exist", $member{'regrealname'})) { &fatal_error("name_taken","($member{'regrealname'})"); }

	if ($name_cannot_be_userid && lc $member{'regusername'} eq lc $member{'regrealname'}) { &fatal_error("name_is_userid"); }

	@reserve = &read_DBorFILE(0,'',$vardir,'reserve','txt');
	@reservecfg = &read_DBorFILE(0,'',$vardir,'reservecfg','txt');
	for ($a = 0; $a < @reservecfg; $a++) {
		chomp $reservecfg[$a];
	}
	$matchword = $reservecfg[0] eq 'checked';
	$matchcase = $reservecfg[1] eq 'checked';
	$matchuser = $reservecfg[2] eq 'checked';
	$matchname = $reservecfg[3] eq 'checked';
	$namecheck = $matchcase eq 'checked' ? $member{'regusername'} : lc $member{'regusername'};
	$realnamecheck = $matchcase eq 'checked' ? $member{'regrealname'} : lc $member{'regrealname'};

	foreach $reserved (@reserve) {
		chomp $reserved;
		$reservecheck = $matchcase ? $reserved : lc $reserved;
		if ($matchuser) {
			if ($matchword) {
				if ($namecheck eq $reservecheck) { &fatal_error('id_reserved',"$reserved"); }
			} else {
				if ($namecheck =~ $reservecheck) { &fatal_error('id_reserved',"$reserved"); }
			}
		}
		if ($matchname) {
			if ($matchword) {
				if ($realnamecheck eq $reservecheck) { &fatal_error('name_reserved',"$reserved"); }
			} else {
				if ($realnamecheck =~ $reservecheck) { &fatal_error('name_reserved',"$reserved"); }
			}
		}
	}

	&fatal_error("id_taken") if &checkfor_DBorFILE("$memberdir/$member{'username'}.vars");

	if ($send_welcomeim == 1) {
		# new format msg file:
		# messageid|(from)user|(touser(s))|(ccuser(s))|(bccuser(s))|subject|date|message|(parentmid)|reply#|ip|messagestatus|flags|storefolder|attachment
		$messageid = $^T . $$;
		&write_DBorFILE(0,'',$memberdir,$member{'regusername'},'msg',"$messageid|$sendname|$member{'regusername'}|||$imsubject|$date|$imtext|$messageid|0|$ENV{'REMOTE_ADDR'}|s|u||\n");
	}
	$encryptopass = &encode_password($member{'passwrd1'});
	$reguser      = $member{'regusername'};
	$registerdate = timetostring($date);

	if ($default_template) { $new_template = $default_template; }
	else { $new_template = "default"; }

	&ToHTML($member{'regrealname'});

	${$uid.$reguser}{'password'}      = $encryptopass;
	${$uid.$reguser}{'realname'}      = $member{'regrealname'};
	${$uid.$reguser}{'email'}         = lc($member{'email'});
	${$uid.$reguser}{'postcount'}     = 0;
	${$uid.$reguser}{'usertext'}      = $defaultusertxt;
	${$uid.$reguser}{'userpic'}       = "blank.gif";
	${$uid.$reguser}{'regdate'}       = $registerdate;
	${$uid.$reguser}{'regtime'}       = $date;
	${$uid.$reguser}{'timeselect'}    = $timeselected;
	${$uid.$reguser}{'timeoffset'}    = $timeoffset;
	${$uid.$reguser}{'dsttimeoffset'} = $dstoffset;
	${$uid.$reguser}{'hidemail'}      = $FORM{'hideemail'} ? 1 : 0;
	${$uid.$reguser}{'timeformat'}    = qq~MM D+ YYYY @ HH:mm:ss*~;
	${$uid.$reguser}{'template'}      = $new_template;
	${$uid.$reguser}{'language'}      = $member{'userlang'};
	${$uid.$reguser}{'pageindex'}     = qq~1|1|1|0~;

	&UserAccount($reguser, "register") & MemberIndex("add", $reguser) & FormatUserName($reguser);

	if ($emailpassword) {
		my $templanguage = $language;
		$language = $member{'userlang'};
		&LoadLanguage('Email');
		require "$sourcedir/Mailer.pl";
		my $message = &template_email($passwordregemail, {'displayname' => $member{'regrealname'}, 'username' => $reguser, 'password' => $member{'passwrd1'}});
		&sendmail($member{'email'}, "$mailreg_txt{'apr_result_info'} $mbname", $message,'',$emailcharset);
		$language = $templanguage;

	} elsif ($emailwelcome) {
		my $templanguage = $language;
		$language = $member{'userlang'};
		&LoadLanguage('Email');
		require "$sourcedir/Mailer.pl";
		my $message = &template_email($welcomeregemail, {'displayname' => $member{'regrealname'}, 'username' => $reguser, 'password' => $member{'passwrd1'}});
		&sendmail($member{'email'}, "$mailreg_txt{'apr_result_info'} $mbname", $message,'',$emailcharset);
		$language = $templanguage;
	}

	$yytitle       = "$register_txt{'245'}";
	$yymain        = "$register_txt{'245'}";
	$yySetLocation = qq~$adminurl?action=viewmembers;sort=regdate;reversed=on;start=0~;
	&redirectexit;
	$action_area = "addmember";
	&AdminTemplate;
}

1;