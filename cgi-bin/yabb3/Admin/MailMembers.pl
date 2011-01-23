###############################################################################
# MailMembers.pl                                                              #
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

$mailmembersplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

if ($iamguest) { &fatal_error("no_access"); }

&LoadLanguage('Main');
&LoadLanguage('MemberList');

$reused = 0;

sub Mailing {
	if ($iamguest) { &fatal_error("no_access"); }
	$yymain .= qq~
<div style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
	<table border="0" width="100%" cellspacing="1" cellpadding="3" class="bordercolor">
	<tr>
		<td width="100%" valign="middle" class="titlebg">
		<span style="float: left;">
		<img src="$imagesdir/register.gif" alt="" border="0" style="vertical-align: middle;" /><b> $admintxt{'19'}</b>
		</span>
		<form action="$adminurl?action=mailinggrps" method="post" name="mailgrps" style="display: inline;">
		<span style="float: right;">
			<input type="submit" value="$amv_txt{'53'}" class="button" />
		</span>
		</form>
		</td>
	</tr>
	</table>
	<script language="JavaScript1.2" src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
	<form name="adv_membermail" action="$adminurl?action=mailing2" method="post" style="display: inline;" onsubmit="return checkIfChecked(this); return submitproc();">

	<div class="windowbg2" style="width: 100%; border: 1px #cccccc solid;">
	<div class="windowbg2" style="float: left; width: 44%; height: 260px; margin: 1%; border: 1px #cccccc solid;">
	<table border="0" width="98%" cellspacing="0" cellpadding="3" align="center" class="windowbg2">
	<tr>
		<td align="left" width="100%"><label for="field1"><b>$amv_txt{'40'}:</b><br /><span class="small">$amv_txt{'46'}</span></label></td>
	</tr>
	<tr>
		<td align="left" width="100%">
	~;
	my $grpselect;
	my $groupcnt = 0;
	foreach (sort { $a cmp $b } keys %Group) {
		unless($_ eq "Moderator") {
			($title, $dummy) = split(/\|/, $Group{$_}, 2);
			$grpselect .= qq~\n<option value="$_"> $title</option>~;
			$groupcnt++;
		}
	}
	foreach (@nopostorder) {
		($title, $dummy) = split(/\|/, $NoPost{$_}, 2);
		$grpselect .= qq~\n<option value="$_"> $title</option>~;
		$groupcnt++;
	}
	foreach (sort { $b <=> $a } keys %Post) {
		($title, $dummy) = split(/\|/, $Post{$_}, 2);
		$grpselect .= qq~\n<option value="$title"> $title</option>~;
		$groupcnt++;
	}
	if ($groupcnt > 12) { $groupcnt = 12; }
	$yymain .= qq~
	<select name="field1" id="field1" size="$groupcnt" multiple="multiple" style="width: 100%; font-size: 11px;">
	$grpselect
	</select>
	<label for="check_all"><b>$amv_txt{"42a"}: </b></label><input type="checkbox" name="check_all" id="check_all" value="1" class="windowbg2" style="border: 0; vertical-align: middle;" onclick="javascript: if (this.checked) selectCheckAll(true); else selectCheckAll(false);" />
	</td>
	</tr>
	</table>
	</div>
	~;

	unless ($groupcnt == 0) {

		$yymain .= qq~
	<div class="windowbg2" style="float: left; width: 50%; height: 260px; margin: 1%; border: 1px #cccccc solid;">

	<table border="0" width="98%" cellspacing="0" cellpadding="3" align="center" class="windowbg2">
        <tr>
           <td align="left" width="100%"><label for="emailsubject"><b>$amv_txt{'1'}:</b></label></td>
        </tr>
        <tr>
           <td align="left" width="100%"><input type="text" value="" size="40" name="emailsubject" id="emailsubject" style="width: 100%" /></td>
        </tr>
        <tr>
           <td align="left" width="100%"><label for="emailtext"><b>$amv_txt{'2'}:</b></label></td>
        </tr>
        <tr>
           <td align="left" width="100%"><textarea cols="38" rows="9" name="emailtext" id="emailtext" style="width:100%"></textarea></td>
        </tr>
        <tr>
		<td align="left" width="100%"><span class="small">$amv_txt{'39'}</span></td>
        </tr>
	</table>
		<input type="hidden" name="reused" value="$reused" />
	</div>

	<div class="windowbg2" style="float: left; width: 44%; margin: 1%; margin-top: 0; margin-bottom: 0; border: 0;">
	<table border="0" width="98%" cellspacing="0" cellpadding="3" align="center" class="windowbg2">
	<tr>
	<td class="windowbg2" align="left" valign="top"><b>$amv_txt{'49'}:</b></td>
	</tr>
	</table>
	</div>

	<div class="windowbg2" style="float: left; width: 50%; margin: 1%; margin-top: 0; margin-bottom: 0; border: 0;">
	<table border="0" width="98%" cellspacing="0" cellpadding="3" align="center" class="windowbg2">
	<tr>
	<td class="windowbg2" align="left" valign="top"><b>$amv_txt{'47'}:</b></td>
	</tr>
	</table>
	</div>

	<div class="windowbg2" style="float: left; width: 44%; height: 145px; margin: 1%; border: 1px #cccccc solid;">
	<table border="0" width="98%" style="height: 100%" cellspacing="0" cellpadding="3" align="center" class="windowbg2">
	<tr>
	<td class="windowbg2" align="left" valign="top">
		<span class="small">$amv_txt{'50'}</span>
	</td>
	</tr>
	<tr>
	<td class="windowbg2" align="center" valign="top">
		<input type="submit" name="convert" value="$amv_txt{'49'}" style="width: 100%;" class="button" />
	</td>
	</tr>~;

		if (&checkfor_DBorFILE("$vardir/yabbaddress.csv")) {
			$yymain .= qq~
	<tr>
	<td class="windowbg2" align="center" valign="top">
		<input type="button" value="$amv_txt{'51'}" class="button" onclick="MailListWin('$adminurl?action=mailing3');" />
	</td>
	</tr>~;
		}

		$yymain .= qq~
	</table>
	</div>
<script language="JavaScript1.2" type="text/javascript">
<!--
	function MailListWin(FileName,WindowName) {
		WindowFeature="resizable=no,scrollbars=yes,menubar=yes,directories=no,toolbar=no,location=no,status=no,width=400,height=400,screenX=0,screenY=0,top=0,left=0"
		newWindow=open(FileName,WindowName,WindowFeature);
		if (newWindow.opener == null) { newWindow.opener = self; }
		if (newWindow.focus) { newWindow.focus(); }
	}
// -->
</script>

	<div class="windowbg2" style="float: left; width: 50%; height: 145px; margin: 1%; border: 1px #cccccc solid; overflow: auto;">
	~;
		if (&checkfor_DBorFILE("$vardir/maillist.dat")) {
			$yymain .= qq~
		<table border="0" width="99%" cellspacing="0" cellpadding="3" align="center" class="windowbg2">
		~;
			foreach my $curmail (&read_DBorFILE(0,'',$vardir,'maillist','dat')) {
				chomp $curmail;
				($otime, $osubject, $otext, $osender) = split(/\|/, $curmail);
				&LoadUser($osender);
				$thetime = &timeformat($otime);

				$jsubject = $osubject;
				$jtext = $otext;
				&ToJS($jsubject);
				&ToJS($jtext);

				$yymain .= qq~
			<tr>
				<td class="windowbg2" align="left" valign="middle">
					<input type="radio" name="usemail" value="$otime" class="windowbg2" style="border: 0; vertical-align: middle;" onclick="showMail('$jsubject', '$jtext', '$otime');" />
				</td>
				<td class="windowbg2" align="left" valign="top"><span class="small">$thetime<br />${$uid.$osender}{'realname'}</span></td>
				<td class="windowbg2" align="left" valign="top"><span class="small">$osubject</span></td>
				<td class="windowbg2" align="left" valign="middle"><a href="$adminurl?action=deletemail;delmail=$otime"><img src="$imagesdir/admin_rem.gif" border="0" alt="del" /></a></td>
			</tr>
			~;
			}
			$yymain .= qq~
		</table>
		~;
		}
		$yymain .= qq~
	</div>

	<div class="windowbg2" style="float: left; width: 44%; margin: 1%; margin-top: 0; border: 0;">
	&nbsp;
	</div>

	<div class="windowbg2" style="float: left; width: 50%; margin: 1%; margin-top: 0; border: 0;">
	<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
	<td align="center">
		<input type="submit" name="mailsend" value="$amv_txt{'41'}" style="width: 100%;" class="button" />
	</td>
	</tr>
	</table>
	</div>

<div style="clear: both;"></div>
</div>

</form>

<script language="JavaScript1.2" type="text/javascript">
<!--
function selectCheckAll(tchecked) {
	for(var x = 0; x < document.adv_membermail.field1.options.length; x++) document.adv_membermail.field1.options[x].selected = tchecked;
}

function showMail(thesubject, thetext, thetime) {
	thetext=thetext.replace(/\<br \\/\>/g, "\\n");
	document.adv_membermail.emailsubject.value = thesubject;
	document.adv_membermail.emailtext.value = thetext;
	document.adv_membermail.reused.value = thetime;
}
//-->
</script>
</div>
	~;
	}

	$yytitle = $admin_txt{'6'};
	$action_area = 'mailing';
	&AdminTemplate;
}

sub Mailing2 {
	if ($iamguest) { &fatal_error('no_access'); }
	if (!$FORM{'mailsend'} && !$FORM{'convert'}) { &fatal_error('no_access'); }
	@convlist = ();
	if ($FORM{'mailsend'} && $FORM{'emailtext'} ne '') {
		$FORM{'emailsubject'} =~ s~\|~&#124;~g;
		$FORM{'emailtext'} =~ s~\|~&#124;~g;
		$FORM{'emailtext'} =~ s~\r~~g;
		$mailline = qq~$date|$FORM{'emailsubject'}|$FORM{'emailtext'}|$username~;
		&MailList($mailline);
	}
	(@mailgroups) = split(/\, /, $FORM{'field1'});
	&ManageMemberinfo("load");
	$i = 0;
	my ($emailsubject,$emailtext);
	foreach my $user (keys %memberinf) {
		(undef, $memrealname, $mememail, $memposition, $memposts, $memaddgrp, undef) = split(/\|/, $memberinf{$user}, 7);
		&FromHTML($memrealname);

		if ($FORM{'mailsend'} && $FORM{'emailtext'} ne '') {
			$emailsubject = $FORM{'emailsubject'};
			$emailsubject =~ s~\[name\]~$memrealname~ig;
			$emailsubject =~ s~\[username\]~$user~ig;
			$emailtext = $FORM{'emailtext'};
			$emailtext =~ s~\[name\]~$memrealname~ig;
			$emailtext =~ s~\[username\]~$user~ig;
		}

		$mailit = 0;
		foreach $element (@mailgroups) {
			chomp $element;
			if ($element eq $memposition) { $mailit = 1; }
			foreach $memberaddgroups (split(/, /, $memaddgrp)) {
				chomp $memberaddgroups;
				if ($element eq $memberaddgroups) { $mailit = 1; last; }
			}
			if ($mailit) { last; }
		}
		if ($mailit && $FORM{'mailsend'}) {
			require "$sourcedir/Mailer.pl";
			&sendmail($mememail, $emailsubject, $emailtext);
		} elsif ($mailit && $FORM{'convert'}) {
			if ($memrealname =~ /&#(\d{3,}?)\;/ig) { $memrealname = $user; }
			$convlist[$i] = qq~$memrealname\;$mememail\n~;
			$i++;
		}
	}
	undef %memberinf;
	if (@convlist) {
		&write_DBorFILE(0,'',$vardir,'yabbaddress','csv',("Name\;E-mail Address\n",@convlist));
	} elsif ($FORM{'convert'}) {
		&delete_DBorFILE("$vardir/yabbaddress.csv");
	}

	$yySetLocation = qq~$adminurl?action=mailing~;
	&redirectexit;
}

sub Mailing3 {
	print qq~Content-disposition: inline; filename=yabbaddress.csv\n\n~;
	foreach $curadd (&read_DBorFILE(1,'',$vardir,'yabbaddress','csv')) {
		chomp $curadd;
		print qq~$curadd\n~;
	}
}

sub MailingMembers {
	$sortmode = "";
	$selPos   = "";
	$selUser  = "";

	if ($FORM{'sortform'} eq "position") { $selPos = qq~ selected="selected"~; }
	else { $selUser = qq~ selected="selected"~; }

	if    ($INFO{'sort'}     ne "") { $sortmode = ";sort=" . $INFO{'sort'}; }
	elsif ($FORM{'sortform'} ne "") { $sortmode = ";sort=" . $FORM{'sortform'}; }

	if ($iamguest) { &fatal_error("no_access"); }
	$yymain .= qq~
<div style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
	<table border="0" width="100%" cellspacing="1" cellpadding="3" class="bordercolor">
	<tr>
		<td width="100%" valign="middle" class="titlebg">
		<span style="float: left;">
		<img src="$imagesdir/register.gif" alt="" border="0" style="vertical-align: middle;" /><b> $admintxt{'19'}</b>
		</span>
		<form action="$adminurl?action=mailinggrps" method="post" name="selsort" style="display: inline">
		<span style="float: right;">
		<label for="sortform"><b>$ml_txt{'1'}</b></label>
		<select name="sortform" id="sortform" style="font-size: 9pt;" onchange="submit()">
			<option value="username"$selUser>$ml_txt{'35'}</option>
			<option value="position"$selPos>$ml_txt{'87'}</option>
		</select>
		&nbsp;
		<input type="button" value="$amv_txt{'54'}" class="button" onclick="window.location.href=\'$adminurl?action=mailing\'" />
		</span>
		</form>
		</td>
	</tr>
	</table>
	<script language="JavaScript1.2" src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
	<form name="adv_membermail" action="$adminurl?action=mailmultimembers;$sortmode" method="post" style="display: inline" onsubmit="return checkIfChecked(this); return submitproc()">
	<input type="hidden" name="button" value="1" />

	<div class="windowbg2" style="width: 100%; border: 1px #cccccc solid;">

	<div class="windowbg" style="float: left; width: 44%; height: 260px; margin: 1%; border: 1px #cccccc inset; overflow: auto;">
	<table border="0" width="99%" cellspacing="0" cellpadding="3" class="windowbg">
	~;

	%TopMembers = ();

	&ManageMemberinfo("load");
	foreach my $membername (keys %memberinf) {
		(undef, $memberrealname, undef, $memposition, $memposts, undef) = split(/\|/, $memberinf{$membername}, 6);
		$pstsort    = 99999999 - $memposts;
		$sortgroups = "";
		$j          = 0;

		if ($membername eq $username) {
			$sortgroups = "!!!";
		} else {
			if ($FORM{'sortform'} eq "position" || $INFO{'sort'} eq "position") {
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

			} else {
				$sortgroups = $memberrealname;
			}
		}
		$TopMembers{$membername} = $sortgroups;
	}
	my @toplist = sort { lc $TopMembers{$a} cmp lc $TopMembers{$b} } keys %TopMembers;

	$memcount = @toplist;

	$b         = 0;
	$numshown  = 0;
	$actualnum = 0;

	while (($numshown < $memcount)) {
		$user = $toplist[$b];

		(undef, $memrealname, $mememail, $memposition, $memposts, undef) = split(/\|/, $memberinf{$user}, 6);

		if ($user eq $username) { $bagcolor = "windowbg2"; }
		else { $bagcolor = "windowbg"; }
		if ($memrealname ne "") {

			$addel = qq~<input type="checkbox" name="member$actualnum" value="$user" class="windowbg" style="border: 0;" />~;
			$actualnum++;

			my $memberinfo = $memposition;
			if ($memberinfo eq "Administrator") {
				($memberinfo, undef) = split(/\|/, $Group{"Administrator"}, 2);
			} elsif ($memberinfo eq "Global Moderator") {
				($memberinfo, undef) = split(/\|/, $Group{"Global Moderator"}, 2);
			} else {
				foreach my $key (sort { $a <=> $b } keys %NoPost) {
					if ($key eq $memberinfo) {
						($memberinfo, undef) = split(/\|/, $NoPost{$key}, 2);
					}
				}
			}

			$viewmembinfo = $memberinfo;
			&ToJS($memberinfo);
			$tmp_postcount = $memposts;
			$checkinfo     = $memberinfo;
			$checkinfo =~ s/\, /\'\|\'/g;
			$CheckingAll .= qq~"'$checkinfo'", ~;

			if ($do_scramble_id) { $cloakusername = &cloak($user); } else { $cloakusername = $user; }
			$linkuser = qq~<a href="$scripturl?action=viewprofile;username=$cloakusername"><b>$memrealname</b></a>~;

			$yymain .= qq~
			<tr>
			<td class="$bagcolor" align="center" valign="middle">$addel</td>
			<td class="$bagcolor" align="left" valign="middle">$linkuser - $viewmembinfo</td>
			</tr>~;
		}

		$numshown++;
		$b++;
	}
	undef @toplist;
	undef %memberinf;

	$yymain .= qq~
	</table>
	</div>
	~;

	unless ($memcount == 0) {
		if ($FORM{'sortform'} eq "") { $FORM{'sortform'} = $INFO{'sort'}; }
		if (!$FORM{'reversed'}) { $FORM{'reversed'} = $INFO{'reversed'}; }

		@groupinfo = ();
		$i         = 0;
		$z         = 0;

		($title, $dummy) = split(/\|/, $Group{"Administrator"}, 2);
		&ToJS($title);
		$groupinfo[$i] = $title;
		$i++;
		$grp_data = qq~"'$title'", ~;
		($title, $dummy) = split(/\|/, $Group{"Global Moderator"}, 2);
		&ToJS($title);
		$groupinfo[$i] = $title;
		$i++;
		$grp_data .= qq~"'$title'", ~;

		foreach (@nopostorder) {
			($title, $dummy) = split(/\|/, $NoPost{$_}, 2);
			&ToJS($title);
			$groupinfo[$i] = $title;
			$grp_data .= qq~"'$title'", ~;
			$i++;
			$z++;
		}

		$groupcnt = $i;
		$grp_data .= qq~""~;

		$yymain .= qq~
	<div class="windowbg2" style="float: left; width: 50%; height: 260px; margin: 1%; padding: 4px; border: 1px #cccccc solid;">

	<table border="0" width="100%" cellspacing="0" cellpadding="2" class="windowbg2">
        <tr>
           <td align="left" width="100%"><label for="emailsubject"><b>$amv_txt{'1'}:</b></label></td>
        </tr>
        <tr>
           <td align="left" width="100%"><input type="text" value="" size="40" name="emailsubject" id="emailsubject" style="width: 100%" /></td>
        </tr>
        <tr>
           <td align="left" width="100%"><label for="emailtext"><b>$amv_txt{'2'}:</b></label></td>
        </tr>
        <tr>
           <td align="left" width="100%"><textarea cols="38" rows="9" name="emailtext" id="emailtext" style="width:100%"></textarea></td>
        </tr>
        <tr>
		<td align="left" width="100%"><span class="small">$amv_txt{'39'}</span></td>
        </tr>
	</table>
		<input type="hidden" name="reused" value="$reused" />
	</div>

	<div class="windowbg2" style="float: left; width: 44%; margin: 1%; margin-top: 0; border: 0;">
	<table border="0" width="100%" cellspacing="0" cellpadding="3" class="windowbg2">
	<tr>
	<td class="windowbg2" align="left" valign="top" nowrap="nowrap"><label for="check_all"><b>$amv_txt{'42'}:</b></label></td>
	<td class="windowbg2" align="left" valign="top"><input type="checkbox" name="check_all" id="check_all" value="1" class="windowbg2" style="border: 0;" onclick="javascript: if (this.checked) selectCheckAllmemb(true); else selectCheckAllmemb(false);" /></td>
	</tr>
	<tr>
	<td class="windowbg2" align="left" valign="top" nowrap="nowrap"><label for="field1"><b>$amv_txt{'40'}:</b></label></td>
	<td class="windowbg2" align="left" valign="top">
		<label for="field1"><span class="small">$amv_txt{'46'}</span></label><br />
		<select name="field1" id="field1" size="$groupcnt" multiple="multiple" onchange="selectCheck()">~;

		$i = 0;
		while ($i < $groupcnt) {
			$yymain .= qq~
			<option value="$i">$groupinfo[$i]</option>~;
			$i++;
		}

		$yymain .= qq~
		</select>
	</td>
	</tr>
	</table>
	</div>

	<div class="windowbg2" style="float: left; width: 50%; margin: 1%; margin-top: 0; margin-bottom: 0; border: 0;">
	<table border="0" width="100%" cellspacing="0" cellpadding="3" class="windowbg2">
	<tr>
	<td class="windowbg2" align="left" valign="top"><b>$amv_txt{'47'}:</b></td>
	</tr>
	</table>
	</div>

	<div class="windowbg2" style="float: left; width: 50%; height: 115px; margin: 1%; border: 1px #cccccc solid; overflow: auto;">
	~;
		if (&checkfor_DBorFILE("$vardir/maillist.dat")) {
			$yymain .= qq~
		<table border="0" width="99%" cellspacing="0" cellpadding="3" class="windowbg2">
		~;
			foreach my $curmail (&read_DBorFILE(0,'',$vardir,'maillist','dat')) {
				chomp $curmail;
				($otime, $osubject, $otext, $osender) = split(/\|/, $curmail);
				&LoadUser($osender);
				$thetime = &timeformat($otime);

				$jsubject = $osubject;
				$jtext    = $otext;
				&ToJS($jsubject);
				&ToJS($jtext);

				$yymain .= qq~
			<tr>
				<td class="windowbg2" align="left" valign="middle">
					<input type="radio" name="usemail" value="$otime" class="windowbg2" style="border: 0; vertical-align: middle;" onclick="showMailmemb('$jsubject', '$jtext', '$otime');" />
				</td>
				<td class="windowbg2" align="left" valign="top"><span class="small">$thetime<br />${$uid.$osender}{'realname'}</span></td>
				<td class="windowbg2" align="left" valign="top"><span class="small">$osubject</span></td>
				<td class="windowbg2" align="left" valign="middle"><a href="$adminurl?action=deletemail;delmail=$otime"><img src="$imagesdir/admin_rem.gif" border="0" alt="del" /></a></td>
			</tr>
			~;
			}
			$yymain .= qq~
		</table>
		~;
		}
		$yymain .= qq~
	</div>


	<div class="windowbg2" style="float: left; width: 44%; margin: 1%; margin-top: 0; border: 0;">
	<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
	<td align="center">
		&nbsp;
	</td>
	</tr>
	</table>
	</div>

	<div class="windowbg2" style="float: left; width: 50%; margin: 1%; margin-top: 0; border: 0;">
	<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
	<td align="center">
		<input type="submit" name="mailsend" value="$amv_txt{'41'}" style="width: 100%;" class="button" />
	</td>
	</tr>
	</table>
	</div>

<div style="clear: both;"></div>
</div>

</form>

<script language="JavaScript1.2" type="text/javascript">
<!--
mem_data = new Array ( $CheckingAll"" );
group_data = new Array ( $grp_data );

function selectCheckAllmemb(tchecked) {
	for(var x = 0; x < document.adv_membermail.field1.options.length; x++) document.adv_membermail.field1.options[x].selected = tchecked;
	for(var i = 1; i <= $actualnum; i++) document.adv_membermail.elements[i].checked = tchecked;
}

function selectCheck() {
var z = 1;
var grpcnt = 0;
grp_data = new Array ();

	for(x = 0; x < document.adv_membermail.field1.options.length; x++) {
		if (document.adv_membermail.field1.options[x].selected) {
			grp_data[grpcnt] = group_data[document.adv_membermail.field1.options[x].value];
			grpcnt++;
		}
	}

	if (grpcnt < document.adv_membermail.field1.options.length) { document.adv_membermail.check_all.checked = false; }

	for (var i = 0; i < $actualnum; i++) {
		var check = 0;
		for(x = 0; x < grpcnt; x++) {
			var limit = grp_data[x];
			var value = mem_data[i].split("|");
			var j = 0;
			while(value[j]) {
				if (value[j] == limit) { check = 1; x = grpcnt; }
				j++;
			}
		}
		if (check == 1) {document.adv_membermail.elements[z].checked = true;}
		else {document.adv_membermail.elements[z].checked = false;}
		z++;
	}
}

function checkIfChecked(theForm) {
	var nonechecked = true;
	for(var i = 1; i <= $actualnum; i++) {
		if (document.adv_membermail.elements[i].checked) nonechecked = false;
	}
	if (nonechecked) { alert("$amv_txt{'48'}"); return false }
	return true
}

function showMailmemb(thesubject, thetext, thetime) {
	thetext=thetext.replace(/\<br \\/\>/g, "\\n");
	document.adv_membermail.emailsubject.value = thesubject;
	document.adv_membermail.emailtext.value = thetext;
	document.adv_membermail.reused.value = thetime;
}
//-->
</script>
</div>
	~;
	}

	$yytitle     = "$admin_txt{'6'}";
	$action_area = "mailing";
	&AdminTemplate;
}

sub ToJS {
	$_[0] =~ s~;~&#059;~g;
	$_[0] =~ s~\!~&#33;~g;
	$_[0] =~ s~\(~&#40;~g;
	$_[0] =~ s~\)~&#41;~g;
	$_[0] =~ s~\-~&#45;~g;
	$_[0] =~ s~\.~&#46;~g;
	$_[0] =~ s~\:~&#58;~g;
	$_[0] =~ s~\?~&#63;~g;
	$_[0] =~ s~\[~&#91;~g;
	$_[0] =~ s~\\~&#92;&#92;~g;
	$_[0] =~ s~\]~&#93;~g;
	$_[0] =~ s~\^~&#94;~g;
	$_[0] =~ s~\"~&#34;~g;
	$_[0] =~ s~\'~&#96;~g;
	$_[0] =~ s~\<~&#60;~g;
	$_[0] =~ s~\>~&#62;~g;
}

1;