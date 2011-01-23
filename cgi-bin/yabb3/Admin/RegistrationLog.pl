###############################################################################
# RegistrationLog.pl                                                          #
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

$registrationlogplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('Register');

sub view_reglog {
	&is_admin_or_gmod;

	$yytitle = $prereg_txt{'15a'};

	my @logentries;
	if (&checkfor_DBorFILE("$vardir/registration.log")) {
		@logentries = &read_DBorFILE(0,'',$vardir,'registration','log');
		@logentries = reverse @logentries;

		&ManageMemberinfo("load");

		# If a pre-registration list exists load it
		if (&checkfor_DBorFILE("$memberdir/memberlist.inactive")) {
			@reglist = &read_DBorFILE(0,'',$memberdir,'memberlist','inactive');
		}
		# grab pre regged user activationkey for admin activation
		foreach (@reglist) {
			(undef, $actcode, $regmember, undef) = split(/\|/, $_, 4);
			$actkey{$regmember} = $actcode;
		}
	} else {
		$servertime = $date;
		push(@logentries, "$servertime|LD|$username|$username|$user_ip");
	}

	if (@logentries > 0) {
		$logcount = @logentries;
		my $newstart = $INFO{'newstart'} || 0;

		$postdisplaynum = 8;
		$max = $logcount;
		$newstart = (int($newstart / 25)) * 25;
		$tmpa = 1;
		if ($newstart >= (($postdisplaynum - 1) * 25)) { $startpage = $newstart - (($postdisplaynum - 1) * 25); $tmpa = int( $startpage / 25 ) + 1; }
		if ($max >= $newstart + ($postdisplaynum * 25)) { $endpage = $newstart + ($postdisplaynum * 25); } else { $endpage = $max }
		if ($startpage > 0) { $pageindex = qq~<a href="$adminurl?action=$action;newstart=0" style="font-weight: normal;">1</a>&nbsp;...&nbsp;~; }
		if ($startpage == 25) { $pageindex = qq~<a href="$adminurl?action=$action;newstart=0" style="font-weight: normal;">1</a>&nbsp;~;}
		for ($counter = $startpage; $counter < $endpage; $counter += 25) {
			$pageindex .= $newstart == $counter ? qq~<b>$tmpa</b>&nbsp;~ : qq~<a href="$adminurl?action=$action;newstart=$counter" style="font-weight: normal;">$tmpa</a>&nbsp;~;
			$tmpa++;
		}
		$lastpn = int($logcount / 25) + 1;
		$lastptn = ($lastpn - 1) * 25;
		if ($endpage < $max - (25) ) { $pageindexadd = qq~...&nbsp;~; }
		if ($endpage != $max) { $pageindexadd .= qq~<a href="$adminurl?action=$action;newstart=$lastptn">$lastpn</a>~; }
		$pageindex .= $pageindexadd;

		$pageindex = qq~
			<tr>
				<td class="windowbg" colspan="4"><span class="small" style="float: left;">$admin_txt{'139'}: $pageindex</span></td>
			</tr>
		~;

		$numbegin = ($newstart + 1);
		$numend = ($newstart + 25);
		if ($numend > $logcount) { $numend  = $logcount; }
		if ($logcount == 0) { $numshow = ''; }
		else { $numshow = qq~($numbegin - $numend)~; }

		@logentries = splice(@logentries, $newstart, 25);
	}

	foreach $logentry (@logentries) {
		chomp $logentry;
		my ($logtime, $status, $userid, $actid, $ipadd) = split(/\|/, $logentry);
		if ($do_scramble_id) {
			$cryptactid = &cloak($actid);
			$cryptuserid = &cloak($userid);
		} else {
			$cryptactid = $actid;
			$cryptuserid = $userid;
		}
		if ($userid ne $actid && $actid ne '') {
			&LoadUser($actid);
			$actadminlink = qq~ $prereg_txt{'by'} <a href="$scripturl?action=viewprofile;username=$cryptactid">${$uid.$actid}{'realname'}</a>~;
		} else {
			$actadminlink = '';
		}
		if ($status eq 'AA' && &LoadUser($userid)){
			$linkuserid = qq~$userid (<a href="$scripturl?action=viewprofile;username=$cryptuserid">${$uid.$userid}{'realname'}</a>)~;
		} else {
			$linkuserid = $userid; 
		}
		if ($do_scramble_id){ $cryptid = &cloak($userid); } else { $cryptid = $userid; }
		$reclogtime = &timeformat($logtime);
		if ($status eq 'N' && !exists $memberinf{$userid} && &checkfor_DBorFILE("$memberdir/$userid.pre")) {
			$delrecord = qq~<a href="$adminurl?action=del_regentry;username=$cryptid">$prereg_txt{'del'}</a>~;
			$delrecord .= qq~<br /><a href="$adminurl?action=view_regentry;username=$cryptid~ . ($actkey{$userid} ne '' ? ";activationkey=$actkey{$userid};type=validate" : "") . qq~">$prereg_txt{'view'}</a>~;
			$delrecord .= qq~<br /><a href="$scripturl?action=activate;username=$cryptid;activationkey=$actkey{$userid}">$prereg_txt{'act'}</a>~;
		} elsif ($status eq 'W' && !exists $memberinf{$userid} && &checkfor_DBorFILE("$memberdir/$userid.wait")) {
			$delrecord = qq~<a href="$adminurl?action=rej_regentry;username=$cryptid">$prereg_txt{'reject'}</a>~;
			$delrecord .= qq~<br /><a href="$adminurl?action=view_regentry;username=$cryptid;type=approve">$prereg_txt{'view'}</a>~;
			$delrecord .= qq~<br /><a href="$adminurl?action=apr_regentry;username=$cryptid">$prereg_txt{'apr'}</a>~;
		} else {
			$delrecord = '---';
		}
		$loglist .= qq~
		<tr>
		<td class="windowbg" width="20%" align="center">$reclogtime</td>
		<td class="windowbg2" width="35%" align="center">$prereg_txt{$status}$actadminlink<br />IP: $ipadd</td>
		<td class="windowbg" width="25%" align="center">$linkuserid</td>
		<td class="windowbg2" width="20%" align="center">$delrecord</td>
		</tr>~;
	}

	$yymain .= qq~
	<script language="JavaScript1.2" src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
	<form name="reglog_form" action="$adminurl?action=clean_reglog" method="post" onsubmit="return submitproc();">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
	<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td align="left" class="titlebg" colspan="4"><img src="$imagesdir/xx.gif" alt="" border="0" /> <b>$yytitle</b></td>
	</tr>
	<tr valign="middle">
		<td align="left" class="windowbg2" colspan="4"><br />$prereg_txt{'20'}<br /><br /></td>
	</tr>
	$pageindex
	<tr valign="middle">
		<td align="center" class="catbg" width="20%"><b>$prereg_txt{'17'}</b></td>
		<td align="center" class="catbg" width="35%"><b>$prereg_txt{'18'}</b></td>
		<td align="center" class="catbg" width="25%"><b>$prereg_txt{'19'}</b></td>
		<td align="center" class="catbg" width="20%"><b>$prereg_txt{'action'}</b></td>
	</tr>
	$loglist
	</table>
 </div>

<br />
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="center" class="catbg">
		 <input type="submit" value="$prereg_txt{'9'}" onclick="return confirm('$prereg_txt{'9'}');" class="button" />
       </td>
     </tr>
   </table>
 </div>

</form>
~;
	$action_area = 'view_reglog';
	&AdminTemplate;
}

sub clean_reglog {
	&is_admin_or_gmod;
	my (@outlist, @reglist, $reguser, $regstatus);
	@reglist = &read_DBorFILE(0,'',$vardir,'registration','log');
	## depending on registration type only leave uncompleted entries in the log for completion and remove the failed or completed ones ##
	foreach (@reglist) {
		(undef, $regstatus, $reguser, undef) = split(/\|/, $_, 4);
		if (($regtype == 1 || $regtype == 2) && $regstatus eq "N" && &checkfor_DBorFILE("$memberdir/$reguser.pre")) {
			push(@outlist, $_);
		}
		if ($regtype == 1 && $regstatus eq "W" && &checkfor_DBorFILE("$memberdir/$reguser.wait")) {
			push(@outlist, $_);
		}
	}
	&write_DBorFILE(0,'',$vardir,'registration','log',@outlist);

	$yySetLocation = qq~$adminurl?action=view_reglog~;
	&redirectexit;
}

sub kill_registration {
	&is_admin_or_gmod;
	my $changed;
	my $deluser = $_[0] || $INFO{'username'};
	if ($do_scramble_id) { $deluser = &decloak($deluser); }

	@actlist = &read_DBorFILE(0,'',$memberdir,'memberlist','inactive');

	# check if user is in pre-registration and check activation key
	foreach (@actlist) {
		($regtime, undef, $regmember, undef) = split(/\|/, $_, 4);
		if ($deluser eq $regmember) {
			$changed = 1;
			&delete_DBorFILE("$memberdir/$regmember.pre");

			# add entry to registration log
			&write_DBorFILE(0,REG,$vardir,'registration','log',(&read_DBorFILE(0,REG,$vardir,'registration','log'),"$date|D|$regmember|$username|$user_ip\n"));
		} else {
			# update non activate user list
			# write valid registration to the list again
			push(@outlist, $_);
		}
	}
	if ($changed) {
		# re-open inactive list for update if changed
		&write_DBorFILE(0,'',$memberdir,'memberlist','inactive',@outlist);
	}
	$yySetLocation = qq~$adminurl?action=view_reglog~;
	&redirectexit;
}

sub view_registration {
	&is_admin_or_gmod;
	my $viewuser = $INFO{'username'} || $FORM{'username'};
	my $readuser = $viewuser;
	my $viewtype = $INFO{'type'};
	my $actkey = $INFO{'activationkey'};
	if ($do_scramble_id) { $readuser = &decloak($viewuser); }
	&LoadUser($readuser);
	$yymain .= qq~
<form action="$adminurl?action=admin_descision;activationkey=$actkey" method="post" name="creator">
<input type="hidden" name="username" value="$viewuser" />
<table cellspacing="1" cellpadding="4" width="100%" align="center" class="bordercolor" border="0">
 <tr>
   <td colspan="2" class="catbg"><img src="$imagesdir/profile.gif" alt="" border="0" /> <b>$prereg_txt{'view'}</b>
	<input type="hidden" name="type" value="$viewtype" />
	<input type="hidden" name="activationkey" value="$actkey" />
  </td>
 </tr><tr class="windowbg">
   <td width="320" align="left"><b>$prereg_txt{'apr_id'}: </b></td>
   <td align="left">$readuser</td>
 </tr><tr class="windowbg">
   <td width="320" align="left"><b>$prereg_txt{'apr_name'}: </b></td>
   <td align="left">${$uid.$readuser}{'realname'}</td>
 </tr>~;

	if ($viewtype eq "validate"){
		$yymain .= qq~<tr class="windowbg">
   <td width="320" align="left"><b>$prereg_txt{'apr_email_invalid'}: </b></td>
   <td align="left">${$uid.$readuser}{'email'}</td>
 </tr>~;
	} elsif ($viewtype eq "approve"){
		$yymain .= qq~<tr class="windowbg">
   <td width="320" align="left"><b>$prereg_txt{'apr_email_valid'}: </b></td>
   <td align="left">${$uid.$readuser}{'email'}</td>
 </tr>~;
	}

	if ($addmemgroup_enabled == 2 || $addmemgroup_enabled == 3) {
		my @usergroup;
		foreach (split(/,/, ${$uid.$readuser}{'addgroups'})) {
			push(@usergroup, (split(/\|/, $NoPost{${$uid.$readuser}{'addgroups'}}, 2))[0]);
		}
		$yymain .= qq~<tr class="windowbg">
   <td width="320" align="left"><b>$register_txt{'765'}:</b></td>
   <td align="left">~ . join(', ', @usergroup) . qq~</td>
 </tr>~;
	}

	$yymain .= qq~<tr class="windowbg">
   <td width="320" align="left"><b>$prereg_txt{'apr_language'}: </b></td>
   <td align="left">${$uid.$readuser}{'language'}</td>
 </tr><tr class="windowbg">
   <td width="320" align="left"><b>$prereg_txt{'apr_ip'}: </b></td>
   <td align="left">${$uid.$readuser}{'lastips'}</td>
 </tr>~;

	if ($regtype == 1){
		$yymain .= qq~<tr class="windowbg">
   <td width="320" align="left"><b>$prereg_txt{'apr_reason'}: </b></td>
   <td align="left">${$uid.$readuser}{'regreason'}</td>
 </tr>~;
	}

	if ($viewtype eq "approve"){
		$yymain .= qq~<tr>
   <td colspan="2" class="catbg"><img src="$imagesdir/profile.gif" alt="" border="0" /> <b>$prereg_txt{'apr_admin_reason_title'}</b></td>
 </tr>
 <tr class="windowbg">
   <td width="320" align="left"><b>$prereg_txt{'apr_admin_reason'}: </b></td>
   <td align="left"><textarea rows="4" cols="50" id="admin_reason" name="admin_reason">$admin_reason</textarea></td>
 </tr>
 <tr class="catbg">
    <td height="30" valign="middle" align="center" colspan="2">
	<input type="submit" name="moda" value="$prereg_txt{'apr_admin_reject'}" onclick="return confirm('$prereg_txt{'apr_admin_reject'} ?')" class="button" />
	<input type="submit" name="moda" value="$prereg_txt{'apr_admin_approve'}" onclick="return confirm('$prereg_txt{'apr_admin_approve'} ?')" class="button" />
    </td>
 </tr>~;
 
	} elsif ($viewtype eq "validate"){
		$yymain .= qq~<tr class="catbg">
    <td height="30" valign="middle" align="center" colspan="2">
	<input type="submit" name="moda" value="$prereg_txt{'apr_admin_delete'}" onclick="return confirm('$prereg_txt{'apr_admin_delete'} ?')" class="button" />
	<input type="submit" name="moda" value="$prereg_txt{'apr_admin_validate'}" onclick="return confirm('$prereg_txt{'apr_admin_validate'} ?')" class="button" />
    </td>
 </tr>~;
	}

	$yymain .= qq~
</table>
</form>~;

	$yytitle = "$prereg_txt{'view'}";
	&AdminTemplate;
}

sub process_registration_review {
	&is_admin_or_gmod;
	my $descuser  = $FORM{'username'};
	my $desctype  = $FORM{'type'};
	my $descision = $FORM{'moda'};
	my $actkey    = $FORM{'activationkey'};
	$admin_reason = $FORM{'admin_reason'};
	if ($desctype eq "validate") {
		if ($descision eq $prereg_txt{'apr_admin_validate'}) {
			require "$sourcedir/Register.pl";
			&user_activation($descuser,$actkey);
		} elsif ($descision eq $prereg_txt{'apr_admin_delete'}) {
			&kill_registration($descuser);
		}
	} elsif ($desctype eq "approve") {
		if ($descision eq $prereg_txt{'apr_admin_approve'}) {
			&approve_registration($descuser);
		} elsif ($descision eq $prereg_txt{'apr_admin_reject'}) {
			&reject_registration($descuser);
		}
	}
}

sub reject_registration {
	&is_admin_or_gmod;
	my $deluser = $_[0] || $INFO{'username'};
	if (!$admin_reason) { $admin_reason = $FORM{'admin_reason'}; }
	if ($do_scramble_id) { $deluser = &decloak($deluser); }

	if (&checkfor_DBorFILE("$memberdir/memberlist.approve") && $regtype == 1) {
		@aprlist = &read_DBorFILE(0,'',$memberdir,'memberlist','approve');
	}
	# check if waiting user exists
	if (&checkfor_DBorFILE("$memberdir/$deluser.wait")) {
		&LoadUser($deluser);
		## send a rejection email ##
		my $templanguage = $language;
		$language = ${$uid.$deluser}{'language'};
		&LoadLanguage('Email');
		require "$sourcedir/Mailer.pl";
		if ($admin_reason ne "") {
			$message = &template_email($reviewrejectedemail, {'displayname' => ${$uid.$deluser}{'realname'}, 'username' => $deluser, 'reviewer' => ${$uid.$username}{'realname'}, 'reason' => $admin_reason });
		} else {
			$message = &template_email($instantrejectedemail, {'displayname' => ${$uid.$deluser}{'realname'}, 'username' => $deluser, 'reviewer' => ${$uid.$username}{'realname'}});
		}
		&sendmail(${$uid.$deluser}{'email'}, "$mailreg_txt{'apr_result_reject'} $mbname", $message,'',$emailcharset);
		$language = $templanguage;

		## remove the registration data for the rejected user ##
		&delete_DBorFILE("$memberdir/$deluser.wait");
		foreach (@aprlist) {
			(undef, undef, $regmember, undef) = split(/\|/, $_, 4);
			if ($regmember ne $deluser) {
				push(@aprchnglist, $_);
			}
		}
		# update approval user list
		&write_DBorFILE(0,'',$memberdir,'memberlist','approve',@aprchnglist);

		## add entry to registration log ##
		&write_DBorFILE(0,REG,$vardir,'registration','log',(&read_DBorFILE(0,REG,$vardir,'registration','log'),"$date|AR|$deluser|$username|$user_ip\n"));
	}
	$yySetLocation = qq~$adminurl?action=view_reglog~;
	&redirectexit;
}

sub approve_registration {
	&is_admin_or_gmod;
	my $apruser = $_[0] || $INFO{'username'};
	if (!$admin_reason) { $admin_reason = $FORM{'admin_reason'}; }
	if ($do_scramble_id) { $apruser = &decloak($apruser); }

	## load the list with waiting approvals ##
	@aprlist = &read_DBorFILE(0,'',$memberdir,'memberlist','approve');

	foreach (@aprlist) {
		(undef, undef, $regmember, $regpassword) = split(/\|/, $_);
		if ($regmember ne $apruser) {
			push(@aprchnglist, $_);
		} else {
			$foundmember = $regmember;
			$foundpassword = $regpassword;
		}
	}

	## check if waiting user exists and was indeed in the waiting list ##
	if (&checkfor_DBorFILE("$memberdir/$apruser.wait") && $foundmember ne "") {
		&LoadUser($apruser);
		# ckeck if email is allready in active use
		if (lc ${$uid.$apruser}{'email'} eq lc &MemberIndex("check_exist", ${$uid.$apruser}{'email'})) {
			$yymain .= qq~<font color="red"><b>$prereg_txt{'email_taken'} <i>${$uid.$apruser}{'email'}</i> ($prereg_txt{'35'}: $apruser)</b></font>~;
			&view_reglog;
		}

		## user is approved, so let him/her in ##
		if ($use_MySQL) {
			&UserAccount($apruser);
			${$uid.$apruser}{'mysql'} = 1;
			&delete_DBorFILE("$memberdir/$apruser.wait");
		} else { rename("$memberdir/$apruser.wait", "$memberdir/$apruser.vars"); }
		&MemberIndex("add", $apruser);

		## send a approval email ##
		my $templanguage = $language;
		$language = ${$uid.$apruser}{'language'};
		&LoadLanguage('Email');
		require "$sourcedir/Mailer.pl";
		if ($emailpassword) {
			if ($admin_reason ne "") {
				$message = &template_email($pwreviewapprovedemail, {'displayname' => ${$uid.$apruser}{'realname'}, 'username' => $apruser, 'reviewer' => ${$uid.$username}{'realname'}, 'reason' => $admin_reason, 'password' => $foundpassword });
			} else {
				$message = &template_email($pwinstantapprovedemail, {'displayname' => ${$uid.$apruser}{'realname'}, 'username' => $apruser, 'reviewer' => ${$uid.$username}{'realname'}, 'password' => $foundpassword});
			}
		} else {
			if ($admin_reason ne "") {
				$message = &template_email($reviewapprovedemail, {'displayname' => ${$uid.$apruser}{'realname'}, 'username' => $apruser, 'reviewer' => ${$uid.$username}{'realname'}, 'reason' => $admin_reason });
			} else {
				$message = &template_email($instantapprovedemail, {'displayname' => ${$uid.$apruser}{'realname'}, 'username' => $apruser, 'reviewer' => ${$uid.$username}{'realname'}});
			}
		}
		&sendmail(${$uid.$apruser}{'email'}, "$mailreg_txt{'apr_result_approved'} $mbname", $message,'',$emailcharset);
		$language = $templanguage;

		if ($send_welcomeim == 1) {
			# new format msg file:
			# messageid|(from)user|(touser(s))|(ccuser(s))|(bccuser(s))|subject|date|message|(parentmid)|reply#|ip|messagestatus|flags|storefolder|attachment
			$messageid = $^T . $$;
			&write_DBorFILE(${$uid.$apruser}{'mysql'},'',$memberdir,$apruser,'msg',"$messageid|$sendname|$apruser|||$imsubject|$date|$imtext|$messageid|0|$ENV{'REMOTE_ADDR'}|s|u||\n");
		}

		# update approval user list
		&write_DBorFILE(0,'',$memberdir,'memberlist','approve',@aprchnglist);

		## add entry to registration log ##
		&write_DBorFILE(0,REG,$vardir,'registration','log',(&read_DBorFILE(0,REG,$vardir,'registration','log'),"$date|AA|$apruser|$username|$user_ip\n"));
	}
	$yySetLocation = qq~$adminurl?action=view_reglog~;
	&redirectexit;
}

1;