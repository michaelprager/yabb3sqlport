###############################################################################
# Profile.pl                                                                  #
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

$profileplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('Profile');

if ($iamgmod && -e "$vardir/gmodsettings.txt") { require "$vardir/gmodsettings.txt"; }

# make sure this person has access to this profile
sub PrepareProfile {
	if ($iamguest) { &fatal_error('no_access'); }

	# If someone registers with a '+' in their name It causes problems.
	# Get's turned into a <space> in the query string Change it back here.
	# Users who register with spaces get them replaced with _
	# So no problem there.
	$INFO{'username'} =~ tr/ /+/;

	$user = $INFO{'username'};
	if ($do_scramble_id) { &decloak($user); }
	if ($user =~ m~/~)  { &fatal_error('no_user_slash'); }
	if ($user =~ m~\\~) { &fatal_error('no_user_backslash'); }

	unless (&LoadUser($user)) { &fatal_error('no_profile_exists'); }

	if (($user ne $username && !$iamadmin && (!$iamgmod || !$allow_gmod_profile)) ||
	    ($user eq 'admin' && $username ne 'admin') ||
	    ($iamgmod && ${$uid.$user}{'position'} eq 'Administrator')) { &fatal_error('not_allowed_profile_change'); }

	@menucolors = qw(catbg catbg catbg catbg catbg catbg);
}

# Check that profile-editing session is still valid
sub SidCheck {
	my $cur_sid = &decloak($INFO{'sid'});
	my $sid_check = substr($date, 5, 5);
	if ($sid_check <= 600 && $cur_sid >= 99400) { $sid_check += 100000; }

	$sid_expires = $cur_sid + 600 - $sid_check;

	&ProfileCheck($_[0]) if $sid_expires < 0 || $cur_sid > $sid_check;
}

sub ProfileCheck {
	&PrepareProfile;

	my $sid_descript = $mycenter_profile_txt{siddescript};
	if ($_[0]) {
		$sid_descript = $mycenter_profile_txt{timeoutdescript};
		$redirsid = $_[0];
		$yyjavascript .= qq~\nalert("$profile_txt{'897'}");~ if $redirsid =~ s/2$//;
	} else {
		$redirsid = $INFO{'page'} || 'profile';
	}

	$yymain .= qq~
<div style="width: 500px; margin-bottom: 8px; margin-left: auto; margin-right: auto;">
<table cellpadding="4" cellspacing="0" border="0" width="100%" class="tabtitle">
	<tr>
		<td class="round_top_left" width="1%">&nbsp;</td>
		<td align="center"><b>$profile_txt{'901'}</b></td>
		<td class="round_top_right" width="1%">&nbsp;</td>
	</tr>
</table>
<table cellpadding="4" cellspacing="1" border="0" width="100%" align="center" class="bordercolor">
	<tr>
		<td class="windowbg2" align="center">
			<label for="passwrd"><span class="small"><br />$sid_descript<br /><br /></span></label>
		</td>
	</tr>
	<tr>
		<td class="windowbg2" align="center" valign="middle">
			<form action="$scripturl?action=profileCheck2;username=$useraccount{$user}" method="post" name="confirmform">
			<input type="hidden" name="redir" value="$redirsid" />
			<div style="padding-top: 4px;">
				<div><input type="password" name="passwrd" id="passwrd" size="15" style="width: 150px;" onkeypress="capsLock(event,'cappasswrd')" /></div>
				<div style="color: red; font-weight: bold; display: none" id="cappasswrd">$profile_txt{'capslock'}</div>
				<div style="color: red; font-weight: bold; display: none" id="cappasswrd_char">$profile_txt{'wrong_char'}: <span id="cappasswrd_character">&nbsp;</span></div>
			</div>
			<div style="padding-top: 8px;">
				<input type="submit" value="$profile_txt{'900'}" class="button" />
			</div>
			</form>
		</td>
	</tr>
</table>
</div>
<script type="text/javascript" language="JavaScript">
<!--
	document.confirmform.passwrd.focus();
// -->
</script>
~;

	$yynavigation = qq~&rsaquo; $profile_txt{'900'}~;
	$yytitle = $profile_txt{'900'};
	&template;
}

sub ProfileCheck2 {
	&PrepareProfile;

	my $password = &encode_password($FORM{'passwrd'} || $INFO{'passwrd'});
	if ($user eq $username && $password ne ${$uid.$username}{'password'}) {
		&fatal_error('current_password_wrong');
	}
	if (($iamadmin || ($iamgmod && $allow_gmod_profile)) && $password ne ${$uid.$username}{'password'}) {
		&fatal_error('no_admin_password');
	}
	# Update the sessionID too
	${$uid.$username}{'session'} = &encode_password($user_ip);
	&UserAccount($username, "update");

	# update only this cookie since we don't know when the others will expire
	$yySetCookies3 = &write_cookie(
			-name    => $cookiesession_name,
			-value   => ${$uid.$username}{'session'},
			-path    => "/",
			-expires => "Sunday, 17-Jan-2038 00:00:00 GMT");

	# Get a semi-secure SID - only for profile changes
	# cloak the sid -> no point giving anyone the means.
	$yySetLocation = "$scripturl?action=" . ($FORM{'redir'} || $INFO{'redir'} || 'profile') . ";username=$useraccount{$user};sid=" . &cloak(reverse(substr($date, 5, 5))) . ($INFO{'newpassword'} ? ";newpassword=1" : "");
	&redirectexit;
}

sub ProfileMenu {
	return if $view;

	$yymain .= qq~
<table cellspacing="1" cellpadding="4" width="100%" border="0" class="bordercolor">
	<tr>
		<td class="$menucolors[0]" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=profile;username=$useraccount{$user};sid=$INFO{'sid'}">$profile_txt{79}</a></b></span></td>
		<td class="$menucolors[1]" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=profileContacts;username=$useraccount{$user};sid=$INFO{'sid'}">$profile_txt{819}</a></b></span></td>
		<td class="$menucolors[2]" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=profileOptions;username=$useraccount{$user};sid=$INFO{'sid'}">$profile_txt{818}</a></b></span></td>~;

	if ($buddyListEnabled){
		$yymain .= qq~
		<td class="$menucolors[3]" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=profileBuddy;username=$useraccount{$user};sid=$INFO{'sid'}">$profile_buddy_list{'buddylist'}</a></b></span></td>~;
	}

	if ($PM_level == 1 || ($PM_level == 2 && $staff) || ($PM_level == 3 && ($iamadmin || $iamgmod))) {
		$yymain .= qq~
		<td class="$menucolors[4]" valign="bottom" align="center" width="16%"><span class="small"><b><a href="$scripturl?action=profileIM;username=$useraccount{$user};sid=$INFO{'sid'}">$profile_imtxt{56} $profile_txt{323}</a></b></span></td>~;
	}

	if ($iamadmin || ($iamgmod && $allow_gmod_profile && $gmod_access2{'profileAdmin'} eq 'on')) {
		$yymain .= qq~
		<td class="$menucolors[5]" valign="bottom" width="16%" align="center"><span class="small"><b><a href="$scripturl?action=profileAdmin;username=$useraccount{$user};sid=$INFO{'sid'}">$profile_txt{820}</a></b></span></td>~;
	}
	$yymain .= qq~
	</tr>
</table>
<br />
~;
}

sub ModifyProfile {
	&SidCheck($action);
	&PrepareProfile;

	$menucolors[0] = "titlebg";
	&ProfileMenu;

	if ($iamadmin) {
		$confdel_text = qq~$profile_txt{'775'} $profile_txt{'777'} $user $profile_txt{'778'}~;
		if ($user eq $username) {
			$passtext = $profile_txt{'821'};
		} else {
			$passtext = qq~$profile_txt{'2'} $profile_txt{'36'}~;
		}
	} else {
		$confdel_text = qq~$profile_txt{'775'} $profile_txt{'776'} $profile_txt{'778'}~;
		$passtext = $profile_txt{'821'};
	}

	$passtext .= qq~<br /><span class="small" style="font-weight: normal;">$profile_txt{'895'}</span>~;

	my $scriptAction = qq~profile2~;
	if ($view) {
		$scriptAction = qq~myprofile2~;
		$yytitle = $profile_txt{'editmyprofile'};
		$profiletitle = qq~$profile_txt{'editmyprofile'} ($user)~;
		$yynavigation = qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $profiletitle~;
	} else { 
		$yytitle = $profile_txt{'79'};
		$profiletitle = qq~$profile_txt{'79'} ($user)~;
		$yynavigation = qq~&rsaquo; $profiletitle~;
	}

	if (${$uid.$user}{'gender'} eq 'Male')   { $GenderMale   = ' selected="selected" '; }
	if (${$uid.$user}{'gender'} eq 'Female') { $GenderFemale = ' selected="selected" '; }

	&CalcAge($user, "parse");
	# EventCal Begin
	$selectyear = '';
	$seluyear = qq~$profile_txt{'566'}<select name="bday3" style="font-size=10pt;"><option value="">  </option>\n~;
	for ($e = 1905; $e < ($year-4); $e++) {
		if($uyear == $e) {$selectyear = 'selected';} else {$selectyear = '';}
		$seluyear .= qq~<option value="$e" $selectyear>$e</option>\n~;
	}
	$seluyear .= qq~</select> ~;

	$selectmnth = '';
	$dayormonthm = qq~<label for="bday1">$profile_txt{'564'}</label><select name="bday1" id="bday1" style="font-size=10pt;"><option value="">  </option>\n~;
	for ($b = 1; $b < 13; $b++) {
		if($umonth == $b) {$selectmnth = 'selected';} else {$selectmnth = '';}
		if($b < 10) {$c = "0$b";} else { $c = $b;}
		$dayormonthm .= qq~<option value="$c" $selectmnth>$c</option>\n~;
	}
	$dayormonthm .= qq~</select> ~;

	$selectday = '';
	$dayormonthd = qq~<label for="bday2">$profile_txt{'565'}</label><select name="bday2" id="bday2" style="font-size=10pt;"><option value="">  </option>\n~;
	for ($a = 1; $a < 32; $a++) {
		if($uday == $a) {$selectday = 'selected';} else {$selectday = '';}
		if($a < 10) {$d = "0$a";} else { $d = $a;}
		$dayormonthd .= qq~<option value="$d" $selectday>$d</option>\n~;
	}
	$dayormonthd .= qq~</select> ~;
	# EventCal End
	if (${$uid.$user}{'timeselect'} == 6 || ${$uid.$user}{'timeselect'} == 3 || ${$uid.$user}{'timeselect'} == 2) { $dayormonth = $dayormonthd . $dayormonthm; }
	else { $dayormonth = $dayormonthm . $dayormonthd; }
	$dayormonth =~ s/for="bday\d"/for="birthday"/o;
	$dayormonth =~ s/id="bday\d"/id="birthday"/o;

	&LoadLanguage('Register');
	$showProfile   .= qq~
<form action="$scripturl?action=$scriptAction;username=$useraccount{$INFO{'username'}};sid=$INFO{'sid'}" method="post" name="creator">
<input type="hidden" id="regusername" value="$user" />
<table cellspacing="1" cellpadding="4" width="100%" align="center" class="bordercolor" border="0">
	<tr>
		<td class="catbg" colspan="2"><img src="$imagesdir/profile.gif" alt="" border="0" /> <b>$profiletitle</b><br /><span class="small">$profile_txt{'698'}</span>~ . ($INFO{'newpassword'} ? $profile_txt{'80'} : "") . qq~</td>
	</tr>
	<tr class="windowbg">
		<td width="220" align="left"><label for="passwrd1"><b>$profile_txt{81}: </b><br />
			<span class="small">$profile_txt{'896'}</span></label>
		</td>
		<td align="left">
			<div style="float:left;"><input type="password" maxlength="30" name="passwrd1" id="passwrd1" size="20" onkeyup="runPassword(this.value);" onkeypress="capsLock(event,'cappasswrd1')" /> &nbsp; </div>
			<div style="float:left; width: 150px; height: 20px;">
			<div id="password-strength-meter" style="background: transparent url($imagesdir/empty_bar.gif) repeat-x center left; height: 4px"></div>
			<div class="pstrength-bar" id="passwrd1_bar" style="border: 1px solid #FFFFFF; height: 4px"></div>
			<div class="pstrength-info" id="passwrd1_text">&nbsp;</div>
			</div>
			<div style="clear:left; color: red; font-weight: bold; display: none" id="cappasswrd1">$profile_txt{'capslock'}</div>
			<div style="clear:left; color: red; font-weight: bold; display: none" id="cappasswrd1_char">$profile_txt{'wrong_char'}: <span id="cappasswrd1_character">&nbsp;</span></div>
		</td>
	</tr>
	<tr class="windowbg">
		<td width="220" align="left"><label for="passwrd2"><b>$profile_txt{82}: </b><br />
			<span class="small">$profile_txt{'896'}</span></label>
		</td>
		<td align="left">
			<input type="password" maxlength="30" name="passwrd2" id="passwrd2" size="20" onkeypress="capsLock(event,'cappasswrd2')" />
			<div style="color: red; font-weight: bold; display: none" id="cappasswrd2">$profile_txt{'capslock'}</div>
			<div style="color: red; font-weight: bold; display: none" id="cappasswrd2_char">$profile_txt{'wrong_char'}: <span id="cappasswrd2_character">&nbsp;</span></div>
		</td>
	</tr>
	<tr class="windowbg">
		<td width="220" align="left"><label for="name"><b>$profile_txt{68}: </b><br />~;
	if (!$cannot_change_displayname || $iamadmin) {
		if ($name_cannot_be_userid) {
			$showProfile .= qq~
				<span class="small">$profile_txt{'8'}</span></label>~;
		} else {
			$showProfile .= qq~
				<span class="small">$profile_txt{'9'}</span></label>~;
		}
	}
	$showProfile .= qq~
		</td>
		<td align="left"><input type="text" maxlength="30" onchange="checkAvail('$scripturl',this.value,'display','$name_cannot_be_userid')" name="name" id="name" size="30" value="${$uid.$user}{'realname'}"~ . (($cannot_change_displayname && !$iamadmin) ? ' readonly="readonly"' : '') . qq~ /><div id="displayavailability"></div></td>
	</tr>
	<tr class="windowbg">
		<td width="220" align="left"><label for="gender"><b>$profile_txt{231}: </b></label></td>
		<td align="left"><select name="gender" id="gender" size="1"><option value=""></option><option value="Male"$GenderMale>$profile_txt{'238'}</option><option value="Female"$GenderFemale>$profile_txt{'239'}</option></select></td>
	</tr>
	<tr class="windowbg">
		<td width="220" align="left"><label for="birthday"><b>$profile_txt{'563'}: </b></label></td>
<!-- ## XTC Cal Mod ## -->
   <td align="left"><span class="small">$dayormonth$seluyear</span></td>
<!-- ## XTC Cal Mod ## -->
	</tr>
	<tr class="windowbg">
		<td width="220" align="left"><label for="location"><b>$profile_txt{'227'}: </b></label></td>
		<td align="left"><input type="text" maxlength="30" name="location" id="location" size="30" value="${$uid.$user}{'location'}" /></td>
	</tr>~;

	if ($extendedprofiles) {
		require "$sourcedir/ExtendedProfiles.pl";
		$showProfile .= &ext_editprofile($user, "edit");
	}

	if ($sessions == 1 && $staff && $username eq $user) {
		&LoadLanguage('Sessions');
		require "$sourcedir/Decoder.pl";
		my $decanswer = &descramble(${$uid.$user}{'sesanswer'}, $user);
		$questsel = qq~<select name="sesquest" id="sesquest" size="1">\n~;
		while (($key, $val) = each %sesquest_txt) {
			if (${$uid.$user}{'sesquest'} eq $key && ${$uid.$user}{'sesquest'} ne "") {
				$sessel = qq~ selected="selected"~;
			} elsif ($key eq "password" && ${$uid.$user}{'sesquest'} eq "") {
				$sessel = qq~ selected="selected"~;
			} else {
				$sessel = "";
			}
			$questsel .= qq~<option value="$key"$sessel>$val</option>\n~;
		}
		$questsel .= qq~</select>\n~;
		$showProfile   .= qq~
	<tr>
		<td class="catbg" colspan="2"><img src="$imagesdir/session.gif" alt="" border="0" /> <label for="sesquest"><b>$img_txt{'34a'}</b><br /><span class="small">$session_txt{'9'}<br />$session_txt{'9a'}</span></label></td>
	</tr>
	<tr class="windowbg">
		<td width="220" align="left">$questsel</td>
		<td align="left"><input type="text" maxlength="30" name="sesanswer" size="20" value="$decanswer" /></td>
	</tr>~;
	}
	$showProfile .= qq~
	<tr class="catbg">
		<td height="50" valign="middle" align="center" colspan="2"><input type="submit" name="moda" value="$profile_txt{'88'}" class="button" />~;
	if ($user ne "admin" && ($iamadmin || $allow_self_del)) {
		$showProfile .= qq~ &nbsp; &nbsp; &nbsp; <input type="submit" name="moda" value="$profile_txt{'89'}" onclick="return confirm('$confdel_text')" class="button" />~;
	}
	$showProfile .= qq~<br /><span class="small">$profile_txt{'sid_expires_1'} $sid_expires $profile_txt{'sid_expires_2'}</span>
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

	if (!$view) {
		$yymain .= $showProfile;
		&template;
	}
}

sub ModifyProfileContacts {
	&SidCheck($action);
	&PrepareProfile;

	$menucolors[1] = "titlebg";
	&ProfileMenu;

	my $scriptAction = qq~profileContacts2~;
	if ($view) { 
		$scriptAction = qq~myprofileContacts2~;
		$yytitle = qq~$profile_txt{'editmyprofile'} &rsaquo; $profile_txt{'819'}~;
		$profiletitle = qq~$profile_txt{'editmyprofile'} ($user) &rsaquo; $profile_txt{'819'}~;
		$yynavigation = qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $profiletitle~;
	} else {
		$yytitle = qq~$profile_txt{'79'} &rsaquo; $profile_txt{'819'}~;
		$profiletitle = qq~$profile_txt{'79'} ($user) &rsaquo; $profile_txt{'819'}~;
		$yynavigation = qq~&rsaquo; $profiletitle~;
	}

	${$uid.$user}{'aim'} =~ tr/+/ /;
	${$uid.$user}{'yim'} =~ tr/+/ /;

	$showProfile .= qq~
<form action="$scripturl?action=$scriptAction;username=$useraccount{$INFO{'username'}};sid=$INFO{'sid'}" method="post" name="creator">
<table cellspacing="1" cellpadding="4" width="100%" align="center" class="bordercolor" border="0">
	<tr>
		<td colspan="2" class="catbg"><img src="$imagesdir/profile.gif" alt="" border="0" /> <b>$profiletitle</b></td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><label for="email"><b>$profile_txt{'69'}: </b><br /><span class="small">$profile_txt{'679'} </span></label></td>
		<td align="left"><input type="text" maxlength="100" onchange="checkAvail('$scripturl',this.value,'email')" name="email" id="email" size="40" value="${$uid.$user}{'email'}" /><div id="emailavailability"></div></td>
	</tr>~;
	if ($allow_hide_email) {
		my $checked = '';
		if (${$uid.$user}{'hidemail'}) { $checked = ' checked="checked"'; }
		$showProfile .= qq~
	<tr class="windowbg">
		<td width="320" align="left"><label for="hideemail"><b>$profile_txt{'721'}</b></label></td>
		<td align="left"><input type="checkbox" name="hideemail" id="hideemail" value="1"$checked /></td>
	</tr>~;
	}
	$showProfile .= qq~
	<tr class="windowbg">
		<td width="320" align="left"><label for="icq"><b>$profile_txt{'513'}: </b><br /><span class="small">$profile_txt{'600'}</span></label></td>
		<td align="left"><input type="text" maxlength="10" name="icq" id="icq" size="40" value="${$uid.$user}{'icq'}" /></td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><label for="aim"><b>$profile_txt{'603'}: </b><br /><span class="small">$profile_txt{'601'}</span></label></td>
		<td align="left"><input type="text" maxlength="30" name="aim" id="aim" size="40" value="${$uid.$user}{'aim'}" /></td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><label for="yim"><b>$profile_txt{'604'}: </b><br /><span class="small">$profile_txt{'602'}</span></label></td>
		<td align="left"><input type="text" maxlength="30" name="yim" id="yim" size="40" value="${$uid.$user}{'yim'}" /></td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><label for="msn"><b>$profile_txt{'823'}: </b><br /><span class="small">$profile_txt{'824'}</span></label></td>
		<td align="left"><input type="text" maxlength="50" name="msn" id="msn" size="40" value="${$uid.$user}{'msn'}" /></td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><label for="gtalk"><b>$profile_txt{'825'}: </b><br /><span class="small">$profile_txt{'826'}</span></label></td>
		<td align="left"><input type="text" maxlength="50" name="gtalk" id="gtalk" size="40" value="${$uid.$user}{'gtalk'}" /></td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><label for="skype"><b>$profile_txt{'827'}: </b><br /><span class="small">$profile_txt{'828'}</span></label></td>
		<td align="left"><input type="text" maxlength="50" name="skype" id="skype" size="40" value="${$uid.$user}{'skype'}" /></td>
	</tr>
	<tr class="windowbg">
		<td width="320"><label for="myspace"><b>$profile_txt{'570'}:</b><br /><span class="small">$profile_txt{'571'}</span></label></td>
		<td align="left"><label for="myspace"><span class="small">$profile_txt{'572'}</span></label><br /><input type="text" maxlength="50" name="myspace" id="myspace" size="40" value="${$uid.$user}{'myspace'}" /></td>
	</tr>
	<tr class="windowbg">
		<td width="320"><label for="facebook"><b>$profile_txt{'573'}:</b><br /><span class="small">$profile_txt{'574'}</span></label></td>
		<td align="left"><label for="facebook"><span class="small">$profile_txt{'575'}</span></label><br /><input type="text" maxlength="50" name="facebook" id="facebook" size="40" value="${$uid.$user}{'facebook'}" /></td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><label for="webtitle"><b>$profile_txt{'83'}: </b><br /><span class="small">$profile_txt{'598'}</span></label></td>
		<td align="left"><input type="text" maxlength="30" name="webtitle" id="webtitle" size="40" value="${$uid.$user}{'webtitle'}" /></td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><label for="weburl"><b>$profile_txt{'84'}: </b><br /><span class="small">$profile_txt{'599'}</span></label></td>
		<td align="left"><input type="text" name="weburl" id="weburl" size="40" value="${$uid.$user}{'weburl'}" /></td>
	</tr>~;

	if (($PM_level == 1 || ($PM_level == 2 && $staff) || ($PM_level == 3 && ($iamadmin || $iamgmod))) && ($enable_MCaway > 2 || ($enable_MCaway && (${$uid.$user}{'position'} eq 'Administrator' || ${$uid.$user}{'position'} eq 'Global Moderator' || &is_moderator($user))))) {
		my $offChecked = qq~ selected="selected"~;
		my $awayChecked = '';

		if (${$uid.$user}{'offlinestatus'} eq 'away') {
			$offChecked = '';
			$awayChecked = qq~ selected="selected"~;
		}

		my $awayreply = ${$uid.$user}{'awayreply'};
		$awayreply =~ s~<br />~\n~g;
		$showProfile .= qq~
	<tr class="windowbg">
		<td width="320" align="left"><label for="offlinestatus"><b>$profile_txt{'showstatus'}: </b><br /><span class="small">$profile_txt{'statusexplain'}<br />$profile_txt{'awaydescription'}</span></label></td>
		<td align="left">
			<select name="offlinestatus" id="offlinestatus">
			<option value="offline"$offChecked>$maintxt{'61'}</option>
			<option value="away"$awayChecked>$maintxt{'away'}</option>
			</select><br /><br />
			<label for="awaysubj"><span class="small">$profile_txt{'asubj'}</span></label><br />
			<input type="text" name="awaysubj" id="awaysubj" size="50" maxlength="50" value="${$uid.$user}{'awaysubj'}" /><br /><br />
			<label for="awayreply"><span class="small">$profile_txt{'amess'}</span></label><br />
			<textarea name="awayreply" id="awayreply" rows="4" cols="50">$awayreply</textarea><br />

			<span class="small">$profile_txt{'664a'} <input value="$MaxAwayLen" size="3" name="msgCL" class="windowbg" style="border: 0px; width: 40px; padding: 1px; font-size: 11px;" readonly="readonly" /></span><br />
			<script type="text/javascript" language="JavaScript">
			<!--
				var supportsKeys = false;
				function tick() {
					calcCharLeft(document.forms[0]);
					if (!supportsKeys) { timerID = setTimeout("tick()",200); }
				}
				function calcCharLeft(sig) {
					clipped = false;
					maxLength = $MaxAwayLen;
					if (document.creator.awayreply.value.length > maxLength) {
						document.creator.awayreply.value = document.creator.awayreply.value.substring(0,maxLength);
						charleft = 0;
						clipped = true;
					} else {
						charleft = maxLength - document.creator.awayreply.value.length;
					}
					document.creator.msgCL.value = charleft;
					return clipped;
				}
				tick();
			// -->
			</script>
		</td>
	</tr>~;
	}

	if ((${$uid.$user}{'position'} eq 'Administrator' || ${$uid.$user}{'position'} eq 'Global Moderator') && $enable_MCstatusStealth) {
		my $stealthChecked = '';
		if (${$uid.$user}{'stealth'}) { $stealthChecked = ' checked="checked"'; }
		$showProfile .= qq~
	<tr class="windowbg">
		<td width="320" align="left"><label for="stealth"><b>$profile_txt{'stealth'}: </b><br /><span class="small">$profile_txt{'stealthexplain'}</span></label></td>
		<td align="left"><input type="checkbox" name="stealth" id="stealth" value="1"$stealthChecked /></td>
	</tr>~;
	}

	if ($extendedprofiles) {
		require "$sourcedir/ExtendedProfiles.pl";
		$showProfile .= &ext_editprofile($user,"contact");
	}

	$showProfile .= qq~
	<tr class="catbg">
		<td height="50" valign="middle" align="center" colspan="2"><input type="submit" name="moda" value="$profile_txt{'88'}" class="button" /><br /><span class="small">$profile_txt{'sid_expires_1'} $sid_expires $profile_txt{'sid_expires_2'}</span></td>
	</tr>
</table>
</form>~;

	if (!$view) { 
		$yymain .= $showProfile;
		&template;
	}
}

sub ModifyProfileOptions {
	&SidCheck($action);
	&PrepareProfile;

	$menucolors[2] = "titlebg";
	&ProfileMenu;

	my $scriptAction = qq~profileOptions2~;
	if ($view) { 
		$scriptAction = qq~myprofileOptions2~;
		$yytitle = qq~$profile_txt{'editmyprofile'} &rsaquo; $profile_txt{'818'}~;
		$profiletitle = qq~$profile_txt{'editmyprofile'} ($user) &rsaquo; $profile_txt{'818'}~;
		$yynavigation = qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $profiletitle~;
	} else {
		$yytitle = qq~$profile_txt{'79'} &rsaquo; $profile_txt{'818'}~;
		$profiletitle = qq~$profile_txt{'79'} ($user) &rsaquo; $profile_txt{'818'}~;
		$yynavigation = qq~&rsaquo; $profiletitle~;
	}

	if ($allowpics && $upload_useravatar && $upload_avatargroup) {
		$upload_useravatar = 0;
		foreach my $av_gr (split(/, /, $upload_avatargroup)) {
			if ($av_gr eq ${$uid.$user}{'position'}) { $upload_useravatar = 1; last; }
			foreach (split(/,/, ${$uid.$user}{'addgroups'})) {
				if ($av_gr eq $_) { $upload_useravatar = 1; last; }
			}
		}
	}

	$showProfile .= qq~
<form action="$scripturl?action=$scriptAction;username=$useraccount{$INFO{'username'}};sid=$INFO{'sid'}" method="post" name="creator"~ . (($allowpics && $upload_useravatar) ? qq~ enctype="multipart/form-data"~ : "") . qq~>
<table cellspacing="1" cellpadding="4" width="100%" align="center" class="bordercolor" border="0">
	<tr>
		<td colspan="2" class="catbg"><img src="$imagesdir/profile.gif" alt="" border="0" /> <b>$profiletitle</b></td>
	</tr>
	<tr class="windowbg">~;

	if ($allowpics) {
		opendir(DIR, "$facesdir") || fatal_error("cannot_open_dir","($facesdir)!<br />$profile_txt{'681'}", 1);
		@contents = readdir(DIR);
		closedir(DIR);
		$images = '';
		foreach $line (sort @contents) {
			($name, $extension) = split(/\./, $line);
			$checked = '';
			if ($line eq ${$uid.$user}{'userpic'}) { $checked = ' selected="selected"'; }
			if (${$uid.$user}{'userpic'} =~ m~\Ahttps?://~ && $line eq 'blank.gif') { $checked = ' selected="selected" '; }
			if ($extension =~ /gif/i || $extension =~ /jpg/i || $extension =~ /jpeg/i || $extension =~ /png/i) {
				if ($line eq 'blank.gif') {
					$images = qq~			<option value="$line"$checked>$profile_txt{'422'}</option>\n$images~;
				} else {
					$images .= qq~			<option value="$line"$checked>$name</option>\n~;
				}
			}
		}
		my ($pic,$tmp,$s,$alt);
		$tmp = $facesurl;
		$tmp =~ /^(http(s?):\/\/)/;
		($tmp,$s) = ($1,$2);
		if (${$uid.$user}{'userpic'} =~ m~\Ahttps?://~) {
			$pic = ${$uid.$user}{'userpic'};
			$checked = ' checked="checked" ';
			$tmp = ${$uid.$user}{'userpic'};
			$alt = $profile_txt{'473'} if $upload_useravatar;
		} else {
			$pic = "$facesurl/${$uid.$user}{'userpic'}";
		}

		$showProfile .= qq~
		<td align="left"><label for="userpic"><b>$profile_txt{'229'}:</b></label><br /><span class="small"><label for="userpic">$profile_txt{'474'}</label><label for="userpicpersonalcheck">$profile_txt{'475'}</label>~ . ($upload_useravatar ? qq~<br />
			$profile_txt{'476'} $avatar_limit KB~ : "") . qq~<br />
			$profile_txt{'477'}</span></td>
		<td align="left">
			<script language="JavaScript1.2" type="text/javascript">
			<!--
				function showimage(x) {
					if (!document.images) return;
					var source;
					if (x == 1 && document.getElementsByName('userpicpersonalcheck')[0].checked == true) {
						UserPicUrl = document.getElementsByName('userpicpersonal')[0].value;
						document.getElementsByName('userpicpersonal')[0].value = 'http$s://';
						document.getElementsByName('userpicpersonalcheck')[0].checked = false;
					}
					if (x == 1) {
						source = "$facesurl/"+document.creator.userpic.options[document.creator.userpic.selectedIndex].value;
					} else {
						document.creator.userpic.options[0].selected = true;
						source = document.getElementsByName('userpicpersonal')[0].value;
						if (!source || source == 'http$s://') source = "$facesurl/blank.gif";
					}
					document.images.icons.style.display = 'none';
					document.images.icons.width = '';
					document.images.icons.height = '';
					document.images.icons.src = source;
					resize_time = 2;
					img_resize_names = new Array ('avatar_img_resize_1');
					resize_images();
				}
			// -->
			</script>
			<select name="userpic" id="userpic" size="6" onchange="showimage(1);">
			$images
			</select>&nbsp;&nbsp;<img src="$pic" id="icons" name="avatar_img_resize" alt="$alt" border="0" hspace="15" style="display:none" /><br />
			<br />
			<input type="checkbox" name="userpicpersonalcheck" id="userpicpersonalcheck" $checked onclick="if(this.checked==false){UserPicUrl=document.getElementsByName('userpicpersonal')[0].value;document.getElementsByName('userpicpersonal')[0].value='http$s://';}else{document.getElementsByName('userpicpersonal')[0].value=UserPicUrl;}showimage(2);" />&nbsp;<input type="text" name="userpicpersonal" size="40" value="$tmp" onkeyup="document.getElementsByName('userpicpersonalcheck')[0].checked=true;showimage(2);" />~ . ($upload_useravatar ? qq~<br />
			<br />
			<input type="file" name="file_avatar" size="50" />~ : "") . qq~
		</td>
	</tr>~;
	}

	$signature = ${$uid.$user}{'signature'};
	$signature =~ s/<br.*?>/\n/g;

	$showProfile .= qq~
	<tr class="windowbg">
		<td align="left"><label for="usertext"><b>$profile_txt{'228'}: </b></label></td>
		<td align="left"><input type="text" name="usertext" id="usertext" size="40" value="${$uid.$user}{'usertext'}" maxlength="50" /></td>
	</tr>
	<tr class="windowbg">
		<td align="left"><label for="signature"><b>$profile_txt{'85'}:</b><br /><span class="small">$profile_txt{'606'}</span></label></td>
		<td align="left"><textarea name="signature" id="signature" rows="4" cols="30" style="width: 100%">$signature</textarea><br />
			<span class="small">$profile_txt{'664'} <input value="$MaxSigLen" size="3" name="msgCL" class="windowbg" style="border: 0px; width: 40px; padding: 1px; font-size: 11px;" readonly="readonly" /></span><br /><br />
			<script type="text/javascript" language="JavaScript">
			<!--
				var supportsKeys = false;
				function tick() {
					calcCharLeft(document.forms[0]);
					if (!supportsKeys) { timerID = setTimeout("tick()", 1500); }
				}

				function calcCharLeft(sig) {
					clipped = false;
					maxLength = $MaxSigLen;
					if (document.creator.signature.value.length > maxLength) {
						document.creator.signature.value = document.creator.signature.value.substring(0,maxLength);
						charleft = 0;
						clipped = true;
					} else {
						charleft = maxLength - document.creator.signature.value.length;
					}
					document.creator.msgCL.value = charleft;
					return clipped;
				}
				tick();
			// -->
			</script>
		</td>
	</tr>~;

	if ($addmemgroup_enabled > 1 && %NoPost) {
		my ($addmemgroup, $selsize) = &DrawGroups(${$uid.$user}{'addgroups'}, ${$uid.$user}{'position'}, 0);

		$showProfile .= qq~
	<tr class="windowbg">
		<td align="left"><label for="joinmemgroup"><b>$profile_txt{'910'}:</b><br /><span class="small">$profile_txt{'910a'}</span></label></td>
		<td align="left">
			<select name="joinmemgroup" id="joinmemgroup" size="$selsize" multiple="multiple">
			$addmemgroup
			</select>
		</td>
	</tr>~ if $addmemgroup;
	}

	if    (${$uid.$user}{'numberformat'} == 1) { $unfsl1 = ' selected="selected" '; }
	elsif (${$uid.$user}{'numberformat'} == 2) { $unfsl2 = ' selected="selected" '; }
	elsif (${$uid.$user}{'numberformat'} == 3) { $unfsl3 = ' selected="selected" '; }
	elsif (${$uid.$user}{'numberformat'} == 4) { $unfsl4 = ' selected="selected" '; }
	elsif (${$uid.$user}{'numberformat'} == 5) { $unfsl5 = ' selected="selected" '; }
	elsif ($forumnumberformat == 1) { $unfsl1 = ' selected="selected" '; }
	elsif ($forumnumberformat == 2) { $unfsl2 = ' selected="selected" '; }
	elsif ($forumnumberformat == 3) { $unfsl3 = ' selected="selected" '; }
	elsif ($forumnumberformat == 4) { $unfsl4 = ' selected="selected" '; }
	elsif ($forumnumberformat == 5) { $unfsl5 = ' selected="selected" '; }

	if    (${$uid.$user}{'timeselect'} == 7) { $tsl7 = ' selected="selected" '; }
	elsif (${$uid.$user}{'timeselect'} == 6) { $tsl6 = ' selected="selected" '; }
	elsif (${$uid.$user}{'timeselect'} == 5) { $tsl5 = ' selected="selected" '; }
	elsif (${$uid.$user}{'timeselect'} == 4) { $tsl4 = ' selected="selected" '; }
	elsif (${$uid.$user}{'timeselect'} == 3) { $tsl3 = ' selected="selected" '; }
	elsif (${$uid.$user}{'timeselect'} == 2) { $tsl2 = ' selected="selected" '; }
	elsif (${$uid.$user}{'timeselect'} == 1) { $tsl1 = ' selected="selected" '; }
	elsif (${$uid.$user}{'timeselect'} == 8) { $tsl8 = ' selected="selected" '; }
	elsif ($timeselected == 8) { $tsl8 = ' selected="selected" '; }
	elsif ($timeselected == 7) { $tsl7 = ' selected="selected" '; }
	elsif ($timeselected == 6) { $tsl6 = ' selected="selected" '; }
	elsif ($timeselected == 5) { $tsl5 = ' selected="selected" '; }
	elsif ($timeselected == 4) { $tsl4 = ' selected="selected" '; }
	elsif ($timeselected == 3) { $tsl3 = ' selected="selected" '; }
	elsif ($timeselected == 2) { $tsl2 = ' selected="selected" '; }
	elsif ($timeselected == 1) { $tsl1 = ' selected="selected" '; }

	my @usertimeoffset = split(/\./, ${$uid.$user}{'timeoffset'});

	$showProfile .= qq~
	<tr class="windowbg">
		<td align="left"><label for="usernumberformat"><b>$profile_txt{'usernumbformat'}:</b></label></td>
		<td align="left">
			<select name="usernumberformat" id="usernumberformat" size="1">
			<option value="1"$unfsl1>10987.65</option>
			<option value="2"$unfsl2>10987,65</option>
			<option value="3"$unfsl3>10,987.65</option>
			<option value="4"$unfsl4>10.987,65</option>
			<option value="5"$unfsl5>10 987,65</option>
			</select>
		</td>
	</tr>
	<tr class="windowbg">
		<td align="left"><label for="usertimeselect"><b>$profile_txt{'486'}:</b><br />
			<span class="small">$profile_txt{'479'}</span></label></td>
		<td align="left">
			<select name="usertimeselect" id="usertimeselect" size="1">
			<option value="1"$tsl1>$profile_txt{'480'}</option>
			<option value="5"$tsl5>$profile_txt{'484'}</option>
			<option value="4"$tsl4>$profile_txt{'483'}</option>
			<option value="8"$tsl8>$profile_txt{'483a'}</option>
			<option value="2"$tsl2>$profile_txt{'481'}</option>
			<option value="3"$tsl3>$profile_txt{'482'}</option>
			<option value="6"$tsl6>$profile_txt{'485'}</option>
			<option value="7"$tsl7>$profile_txt{'480a'}</option>
			</select>
		</td>
	</tr>
	<tr class="windowbg">
		<td align="left"><label for="timeformat"><b>$profile_txt{'486a'}:</b></label></td>
		<td align="left"><input type="text" name="timeformat" id="timeformat" size="40" value="${$uid.$user}{'timeformat'}" /></td>
	</tr>
	<tr class="windowbg">
		<td align="left"><label for="usertimesign"><b>$profile_txt{'371'}:</b><br /><span class="small">$profile_txt{'372'}</span></label></td>
		<td align="left"><span class="small">$profile_txt{'373'}:<br /><b>~ . &timeformat($date,1) . qq~</b><br /><br /></span><select name="usertimesign" id="usertimesign"><option value="">+</option><option value="-"~ . ($usertimeoffset[0] < 0 ? ' selected="selected"' : '') . qq~>-</option></select>
			<select name="usertimehour" id="usertimehour">~;
	for (my $i = 0; 15 > $i; $i++) {
		$i = sprintf("%02d", $i);
		$showProfile .= qq~\n			<option value="$i"~ . (($usertimeoffset[0] == $i || $usertimeoffset[0] == -$i) ? ' selected="selected"' : '') . qq~>$i</option>~;
	}
	$showProfile .= qq~
			</select> : <select name="usertimemin">~;
	for (my $i = 0; 60 > $i; $i++) {
		my $j = $i / 60;
		$j = substr((split(/\./, $j))[1] . '0000',0,4);
		$showProfile .= qq~\n			<option value="$j"~ . ($usertimeoffset[1] == $j ? ' selected="selected"' : '') . qq~>~ . sprintf("%02d", $i) . qq~</option>~;
	}
	$showProfile .= qq~
			</select>
		</td>
	</tr>
	<tr class="windowbg">
		<td align="left"><label for="dsttimeoffset"><b>$profile_txt{'519'}</b></label></td>
		<td align="left"><input type="checkbox" name="dsttimeoffset" id="dsttimeoffset" value="1"~ . (${$uid.$user}{'dsttimeoffset'} ? ' checked="checked"' : '') . qq~ /></td>
	</tr>
	<tr class="windowbg">
		<td align="left"><label for="dynamic_clock"><b>$profile_txt{'520'}</b><br /><span class="small">$profile_txt{'521'}</span></label></td>
		<td align="left"><input type="checkbox" name="dynamic_clock" id="dynamic_clock" value="1"~ . (${$uid.$user}{'dynamic_clock'} ? ' checked="checked"' : '') . qq~ /></td>
	</tr>~;

	# This is only for update, when comming from YaBB lower or equal version 2.2.3
	# I think it can be deleted around version 2.4.0 without causing mayor issues (deti).
	if ($enable_notifications eq '') { $enable_notifications = $enable_notification ? 3 : 0; }
	# End update workaround
	if ($NewNotificationAlert || $enable_notifications == 1 || $enable_notifications == 3) {
		$showProfile .= qq~
	<tr class="windowbg">
		<td align="left" valign="top"><label for="onlinealert"><b>$profile_txt{'onlinealert'}:</b></label></td>
		<td align="left">~;

		$showProfile .= qq~
			<input type="checkbox" value="1" name="onlinealert" id="onlinealert"~ . (${$uid.$user}{'onlinealert'} ? ' checked="checked"' : '') . qq~ /> <label for="onlinealert">$profile_txt{'onlinealertexplain'}</label>~ if $NewNotificationAlert;

		if ($enable_notifications == 1 || $enable_notifications == 3) {
			$showProfile .= qq~<br />
			<br />~ if $NewNotificationAlert;

			$showProfile .= qq~
			<label for="notify_N">$profile_txt{'326'}</label>?&nbsp;<select name="notify_N" id="notify_N">
			<option value="0"~ . ((!${$uid.$user}{'notify_me'} || ${$uid.$user}{'notify_me'} == 2) ? '' : ' selected="selected"') . qq~>$profile_txt{'164'}</option>
			<option value="1"~ . ((${$uid.$user}{'notify_me'} == 1 || ${$uid.$user}{'notify_me'} == 3) ? ' selected="selected"' : '') . qq~>$profile_txt{'163'}</option>
			</select>~;
		}

		$showProfile .= qq~
		</td>
	</tr>~;
	}

	if ($ttsureverse) {
		${$uid.$user}{'reversetopic'} = $ttsreverse unless exists(${$uid.$user}{'reversetopic'});
		$showProfile .= qq~
	<tr class="windowbg">
		<td align="left"><label for="reversetopic"><b>$profile_txt{'810'}</b><br /><span class="small">$profile_txt{'811'}</span></label></td>
		<td align="left" valign="top"><input type="checkbox" name="reversetopic" id="reversetopic"~ . (${$uid.$user}{'reversetopic'} ? qq~ checked="checked"~ : '') . qq~ /></td>
	</tr>~;
	}

	foreach my $curtemplate (sort{ $templateset{$a} cmp $templateset{$b} } keys %templateset) {
		$selected = '';
		if ($curtemplate eq ${$uid.$user}{'template'}) { $selected = qq~ selected="selected"~; $akttemplate = $curtemplate; }
		$drawndirs .= qq~<option value="$curtemplate"$selected>$curtemplate</option>\n~;
	}

	$showProfile .= qq~
	<tr class="windowbg">
		<td align="left"><label for="usertemplate"><b>$profile_txt{'814'}</b><br /><span class="small">$profile_txt{'815'}</span></label></td>
		<td align="left"><select name="usertemplate" id="usertemplate">$drawndirs</select></td>
	</tr>~;

	opendir(DIR, $langdir);
	my @lfilesanddirs = readdir(DIR);
	close(DIR);
	foreach my $fld (sort {lc($a) cmp lc($b)} @lfilesanddirs) {
		if (-e "$langdir/$fld/Main.lng") {
			my $displang = $fld;
			$displang =~ s~(.+?)\_(.+?)$~$1 ($2)~gi;
			if (${$uid.$user}{'language'} eq $fld) { $drawnldirs .= qq~<option value="$fld" selected="selected">$displang</option>~; }
			else { $drawnldirs .= qq~<option value="$fld">$displang</option>~; }
		}
	}

	$showProfile .= qq~
	<tr class="windowbg">
		<td align="left"><label for="userlanguage"><b>$profile_txt{'817'}</b><br /><span class="small">$profile_txt{'815'}</span></label></td>
		<td align="left"><select name="userlanguage" id="userlanguage">$drawnldirs</select></td>
	</tr>~;

	if ($user_hide_avatars && $showuserpic && $allowpics) { # checkbox to hide avatars in threads
		$showProfile .= qq~
	<tr class="windowbg">
		<td align="left"><label for="hide_avatars"><b>$profile_display_options{'hide_avatars'}</b></label></td>
		<td align="left"><input type="checkbox" name="hide_avatars" id="hide_avatars" value="1"~ . (${$uid.$user}{'hide_avatars'} ? ' checked="checked"' : '') . qq~ /></td>
	</tr>~;
	}
	if ($user_hide_user_text && $showusertext) { # checkbox to hide user-text in threads
		$showProfile .= qq~
	<tr class="windowbg">
		<td align="left"><label for="hide_user_text"><b>$profile_display_options{'hide_user_text'}</b></label></td>
		<td align="left"><input type="checkbox" name="hide_user_text" id="hide_user_text" value="1"~ . (${$uid.$user}{'hide_user_text'} ? ' checked="checked"' : '') . qq~ /></td>
	</tr>~;
	}
	if ($user_hide_attach_img && $allowattach) { # checkbox to hide attached images in threads
		$showProfile .= qq~
	<tr class="windowbg">
		<td align="left"><label for="hide_attach_img"><b>$profile_display_options{'hide_attach_img'}</b></label></td>
		<td align="left"><input type="checkbox" name="hide_attach_img" id="hide_attach_img" value="1"~ . (${$uid.$user}{'hide_attach_img'} ? ' checked="checked"' : '') . qq~ /></td>
	</tr>~;
	}
	if ($user_hide_signat) { # checkbox to hide signatures in threads
		$showProfile .= qq~
	<tr class="windowbg">
		<td align="left"><label for="hide_signat"><b>$profile_display_options{'hide_signat'}</b></label></td>
		<td align="left"><input type="checkbox" name="hide_signat" id="hide_signat" value="1"~ . (${$uid.$user}{'hide_signat'} ? ' checked="checked"' : '') . qq~ /></td>
	</tr>~;
	}
	if ($user_hide_smilies_row && !$removenormalsmilies) { # checkbox to hide the row of smilies below the the post-message-inputbox
		$showProfile .= qq~
	<tr class="windowbg">
		<td align="left"><label for="hide_smilies_row"><b>$profile_display_options{'hide_smilies_row'}</b></label></td>
		<td align="left"><input type="checkbox" name="hide_smilies_row" id="hide_smilies_row" value="1"~ . (${$uid.$user}{'hide_smilies_row'} ? ' checked="checked"' : '') . qq~ /></td>
	</tr>~;
	}

	if ($extendedprofiles) {
		require "$sourcedir/ExtendedProfiles.pl";
		$showProfile .= &ext_editprofile($user,"options");
	}

	$showProfile .= qq~
	<tr class="catbg">
		<td height="50" valign="middle" align="center" colspan="2"><input type="submit" name="moda" value="$profile_txt{'88'}" class="button" /><br /><span class="small">$profile_txt{'sid_expires_1'} $sid_expires $profile_txt{'sid_expires_2'}</span></td>
	</tr>
</table>
</form>~;

	if (!$view) {
		$yymain .= $showProfile;
		&template;
	}
}

sub ModifyProfileBuddy {
	&SidCheck($action);
	&PrepareProfile;

	$menucolors[3] = "titlebg";
	&ProfileMenu;

	my $scriptAction = qq~profileBuddy2~;
	if ($view) {
		$scriptAction = qq~myprofileBuddy2~;
		$yytitle = qq~$profile_txt{'editmyprofile'} &rsaquo; $profile_buddy_list{'buddylist'}~;
		$profiletitle = qq~$profile_txt{'editmyprofile'} ($user) &rsaquo; $profile_buddy_list{'buddylist'}~;
		$yynavigation = qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $profiletitle~;
	} else {
		$yytitle = qq~$profile_txt{'79'} &rsaquo; $profile_buddy_list{'buddylist'}~;
		$profiletitle = qq~$profile_txt{'79'} ($user) &rsaquo; $profile_buddy_list{'buddylist'}~;
		$yynavigation = qq~&rsaquo; $profiletitle~;
	}

	if (!$yyjavascript) { $yyjavascript = ''; }
	$yyjavascript .= qq~
	function imWin() {
		window.open('$scripturl?action=imlist;sort=mlletter;toid=buddylist','Blist','status=no,height=345,width=464,menubar=no,toolbar=no,top=50,left=50,scrollbars=no');
	}
	// removes a user from the list
	function removeUser(oElement) {
		var oList = oElement.options;
		var indexToRemove = oList.selectedIndex;
		if (oList.length > 1 || (oList.length == 1 && oList[0].value != '0')) {
			//alert('element [' + oElement.options[indexToRemove].value + ']');
			if (confirm("$profile_buddy_list{'removealert'}")) {
				oElement.remove(indexToRemove);
			}
		}
	}
	function selectblNames() {
		var oList = document.getElementById('buddylist');
		for (var i = 0; i < oList.options.length; i++) {
			oList.options[i].selected = true;
		}
	}
	~;

	$showProfile .= qq~
<form action="$scripturl?action=$scriptAction;username=$useraccount{$INFO{'username'}};sid=$INFO{'sid'}" method="post" name="creator" onsubmit="javascript: selectblNames();">
<table cellspacing="1" cellpadding="4" width="100%" align="center" class="bordercolor" border="0">
	<tr>
		<td colspan="2" class="catbg"><img src="$imagesdir/profile.gif" alt="" border="0" /> <b>$profiletitle</b></td>
	</tr>~;

	my $buildBuddyList = '';
	if(${$uid.$user}{'buddylist'}) {
		my @buddies = split(/\|/, ${$uid.$user}{'buddylist'});
		chomp @buddies;
		foreach my $buddy (@buddies) {
			&LoadUser($buddy);
			$buildBuddyList .= qq~<option value="$buddy">${$uid.$buddy}{'realname'}</option>~ if ${$uid.$buddy}{'realname'};
		}
	}

	$showProfile .= qq~
	<tr class="windowbg">
		<td width="320" align="left"><b>$profile_buddy_list{'buddylist'}</b><br /><span class="small">$profile_buddy_list{'explain'}</span></td>
		<td align="left"><select name="buddylist" id="buddylist" multiple="multiple" size="3" style="width: 250px; height: 150px;" ondblclick="removeUser(this);">$buildBuddyList</select>
		<br /><span class="small"><a href="javascript: void(0);" onclick="imWin();" rel="nofollow">$profile_buddy_list{'add'}</a></span>
		</td>
	</tr>
	~;

	$showProfile .= qq~<tr class="catbg">
			<td height="50" valign="middle" align="center" colspan="2"><input type="submit" name="moda" value="$profile_txt{'88'}" class="button" /><br /><span class="small">$profile_txt{'sid_expires_1'} $sid_expires $profile_txt{'sid_expires_2'}</span></td>
		</tr>
	</table>
</form>~;

	if (!$view) {
		$yymain .= $showProfile;
		&template;
	}
}

sub ModifyProfileIM {
	&SidCheck($action);
	&PrepareProfile;

	$menucolors[4] = "titlebg";
	&ProfileMenu;

	$yyjavascript .= qq~
	function imWin() {
		window.open('$scripturl?action=imlist;sort=mlletter;toid=ignore','Ilist','status=no,height=345,width=464,menubar=no,toolbar=no,top=50,left=50,scrollbars=no');
	}
	// removes a user from the list
	function removeUser(oElement) {
		var oList = oElement.options;
		var indexToRemove = oList.selectedIndex;
		if (oList.length > 1 || (oList.length == 1 && oList[0].value != '0')) {
			//alert('element [' + oElement.options[indexToRemove].value + ']');
			if (confirm("$profile_buddy_list{'removealert'}")) {
				oElement.remove(indexToRemove);
			}
		}
	}
	function selectINames()	{
		var oList = document.getElementById('ignore');
		for (var i = 0; i < oList.options.length; i++) {
			oList.options[i].selected = true;
			}
		}
	~;

	my $scriptAction = qq~profileIM2~;
	if ($view) { 
		$scriptAction = qq~myprofileIM2~;
		$yytitle = qq~$profile_txt{'editmyprofile'} &rsaquo; $profile_imtxt{'38'}~;
		$profiletitle = qq~$profile_txt{'editmyprofile'} ($user) &rsaquo; $profile_imtxt{'38'}~;
		$yynavigation = qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $profiletitle~;
	} else {
		$yytitle = qq~$profile_txt{79} &rsaquo; $profile_imtxt{'38'}~;
		$profiletitle = qq~$profile_txt{79} ($user) &rsaquo; $profile_imtxt{'38'}~;
		$yynavigation = qq~&rsaquo; $profiletitle~;
	}

	$showProfile .= qq~
<form action="$scripturl?action=$scriptAction;username=$useraccount{$INFO{'username'}};sid=$INFO{'sid'}" method="post" name="creator" onsubmit="javascript:selectINames();" >
<table cellspacing="1" cellpadding="4" width="100%" align="center" class="bordercolor" border="0">
	<tr>
		<td colspan="2" class="catbg" align="left"><img src="$imagesdir/profile.gif" alt="" border="0" /> <b>$profiletitle</b></td>
	</tr>
	<tr class="windowbg">
		<td width="320" valign="top" align="left"><b>$profile_txt{'325'}:</b><br /><span class="small">$profile_txt{'ignoreexplain'}</span></td>
		<td align="left">
			<select name="ignore" id="ignore" size="4" multiple="multiple" style="width:250px;" ondblclick="removeUser(this);" >~;

	my $ignoreallChecked = "";
	if (${$uid.$user}{'im_ignorelist'} eq "*") { $ignoreallChecked = ' checked="checked"'; }
	if (${$uid.$user}{'im_ignorelist'} && ${$uid.$user}{'im_ignorelist'} ne "*") {
		my @ignoreList = split('\|', ${$uid.$user}{'im_ignorelist'});
		chomp @ignoreList;
		foreach my $ignoreName (@ignoreList) {
			&LoadUser($ignoreName);
			my $ignoreUser;
			if(${$uid.$ignoreName}{'realname'}) {$ignoreUser = ${$uid.$ignoreName}{'realname'};}
			else {$ignoreUser = $ignoreName;}
			$ignoreName = &cloak($ignoreName);
			$showProfile .= qq~\n			<option value="$ignoreName">$ignoreUser</option>~;
		}
	}
	$showProfile .= qq~
			</select>
			<br />
			<input type="checkbox" name="ignoreall" id="ignoreall" $ignoreallChecked /> <label for="ignoreall">$profile_txt{'ignoreall'}</label><br />
			<span class="small"><a href="javascript:void(0);" onclick="imWin();" rel="nofollow">$profile_txt{'ignorelistadd'}</a></span>
		</td>
	</tr>~;

	# This is only for update, when comming from YaBB lower or equal version 2.2.3
	# I think it can be deleted around version 2.4.0 without causing mayor issues (deti).
	if ($enable_notifications eq '') { $enable_notifications = $enable_notification ? 3 : 0; }
	# End update workaround

	if ($enable_notifications > 1) {
		$showProfile .= qq~
	<tr class="windowbg">
		<td align="left" valign="top"><label for="notify_PM"><b>$profile_txt{'327'}:</b></label></td>
		<td align="left">
			<select name="notify_PM" id="notify_PM">
			<option value="0"~ . (${$uid.$user}{'notify_me'} < 2 ? '' : ' selected="selected"') . qq~>$profile_txt{'164'}</option>
			<option value="1"~ . (${$uid.$user}{'notify_me'} > 1 ? ' selected="selected"' : '') . qq~>$profile_txt{'163'}</option>
			</select>
		</td>
	</tr>~;
	}

	if (${$uid.$user}{'im_popup'})  { $enable_userimpopup = ' checked="checked"'; }
	if (${$uid.$user}{'im_imspop'}) { $popup_userim = 'checked="checked"'; }
	$showProfile .= qq~
	<tr class="windowbg">
		<td width="320" align="left"><label for="userpopup"><b>$profile_imtxt{'05'}</b></label></td>
		<td align="left"><input type="checkbox" name="userpopup" id="userpopup" value="1"$enable_userimpopup /></td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><label for="popupims"><b>$profile_imtxt{'53'}</b></label></td>
		<td align="left"><input type="checkbox" name="popupims" id="popupims" value="1"$popup_userim /></td>
	</tr>~;
	if($enable_PMcontrols || $enable_PMprev) {
		my $pmmessprevChecked;
		if (${$uid.$user}{'pmmessprev'}) { $pmmessprevChecked = ' checked="checked"'; }
		$showProfile .= qq~
	<tr class="windowbg">
		<td width="320" align="left"><label for="pmmessprev"><b>$profile_txt{'enabprev'}: </b><br /><span class="small">$profile_txt{'prevexplain'}</span></label></td>
		<td align="left"><input type="checkbox" name="pmmessprev" id="pmmessprev" value="1"$pmmessprevChecked /></td>
	</tr>~;
	}
	if($enable_PMcontrols || $enable_PMviewMess) {
		my $pmviewMessChecked;
		if (${$uid.$user}{'pmviewMess'}) { $pmviewMessChecked = ' checked="checked"'; }
		$showProfile .= qq~
	<tr class="windowbg">
		<td width="320" align="left"><label for="pmviewMess"><b>$profile_txt{'viewmess'}: </b><br /><span class="small">$profile_txt{'viewmessexplain'}</span></label></td>
		<td align="left"><input type="checkbox" name="pmviewMess" id="pmviewMess" value="1"$pmviewMessChecked /></td>
	</tr>~;
	}
	if ($enable_PMcontrols || $enable_PMActprev) {
		my $pmactprevChecked;
		if (${$uid.$user}{'pmactprev'}) { $pmactprevChecked = ' checked="checked"'; }
		$showProfile .= qq~
	<tr class="windowbg">
		<td width="320" align="left"><label for="pmactprev"><b>$profile_txt{'actprev'}: </b><br /><span class="small">$profile_txt{'actprevexplain'}</span></label></td>
		<td align="left"><input type="checkbox" name="pmactprev" id="pmactprev" value="1"$pmactprevChecked /></td>
	</tr>~;
	}

	if ($extendedprofiles) {
		require "$sourcedir/ExtendedProfiles.pl";
		$showProfile .= &ext_editprofile($user,"im");
	}

	$showProfile .= qq~
	<tr class="catbg">
		<td height="50" valign="middle" align="center" colspan="2"><input type="submit" name="moda" value="$profile_txt{'88'}" class="button" /><br /><span class="small">$profile_txt{'sid_expires_1'} $sid_expires $profile_txt{'sid_expires_2'}</span></td>
	</tr>
</table>
</form>~;

	if (!$view) {
		$yymain .= $showProfile;
		&template;
	}
}

sub ModifyProfileAdmin {
	&is_admin_or_gmod;

	&SidCheck($action);
	&PrepareProfile;

	$menucolors[5] = "titlebg";
	&ProfileMenu;

	($MemStatAdmin, $MemStarNumAdmin, $MemStarPicAdmin, $MemTypeColAdmin) = split(/\|/, $Group{"Administrator"});
	($MemStatGMod,  $MemStarNumGMod,  $MemStarPicGMod,  $MemTypeColGMod)  = split(/\|/, $Group{"Global Moderator"});
	($MemStatMod,   $MemStarNumMod,   $MemStarPicMod,   $MemTypeColMod)   = split(/\|/, $Group{"Moderator"});

	if    (${$uid.$user}{'position'} eq 'Administrator') { $tt = $MemStatAdmin; }
	elsif (${$uid.$user}{'position'} eq 'Global Moderator') { $tt = $MemStatGMod; }
	elsif (${$uid.$user}{'position'}) { $ttgrp = ${$uid.$user}{'position'}; ($tt, undef) = split(/\|/, $NoPost{$ttgrp}, 2); }
	else { $tt = ${$uid.$user}{'position'}; }

	$regreason = ${$uid.$user}{'regreason'};
	$regreason =~ s~<br \/>~\n~g;

	my ($tta, $selsize);
	if (%NoPost) {
		($tta, $selsize) = &DrawGroups(${$uid.$user}{'addgroups'}, '', 1);
	}

	$userlastlogin = &timeformat(${$uid.$user}{'lastonline'});
	$userlastpost  = &timeformat(${$uid.$user}{'lastpost'});
	$userlastim    = &timeformat(${$uid.$user}{'lastim'});
	if ($userlastlogin eq '') { $userlastlogin = $profile_txt{'470'}; }
	if ($userlastpost eq '') { $userlastpost = $profile_txt{'470'}; }
	if ($userlastim eq '') { $userlastim = $profile_txt{'470'}; }

	my $scriptAction = qq~profileAdmin2~;
	if ($view) { 
		$scriptAction = qq~myprofileAdmin2~;
		$yytitle = qq~$profile_txt{'editmyprofile'} &rsaquo; $profile_txt{'820'}~;
		$profiletitle = qq~$profile_txt{'editmyprofile'} ($user) &rsaquo; $profile_txt{'820'}~;
		$yynavigation = qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $profiletitle~;
	} else {
		$yytitle = qq~$profile_txt{'79'} &rsaquo; $profile_txt{'820'}~;
		$profiletitle = qq~$profile_txt{'79'} ($user) &rsaquo; $profile_txt{'820'}~;
		$yynavigation = qq~&rsaquo; $profiletitle~;
	}

	$showProfile .= qq~
<form action="$scripturl?action=$scriptAction;username=$useraccount{$user};sid=$INFO{'sid'}" method="post" name="creator">
<table cellspacing="1" cellpadding="4" width="100%" align="center" class="bordercolor" border="0">
	<tr>
		<td colspan="2" class="catbg"><img src="$imagesdir/profile.gif" alt="" border="0" /> <b>$profiletitle</b><input type="hidden" name="username" value="$INFO{'username'}" /></td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><label for="settings6"><b>$profile_txt{'21'}: </b></label></td>
		<td align="left"><input type="text" name="settings6" id="settings6" size="4" value="${$uid.$user}{'postcount'}" /></td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><label for="settings7"><b>$profile_txt{'87'}: </b><br /><span class="small">$profile_txt{'87c'}</span></label></td>
		<td align="left">
			<select name="settings7" id="settings7">
			<option value="${$uid.$user}{'position'}">$tt</option>
			<option value="${$uid.$user}{'position'}">---------------</option>
			<option value=""></option>~;

	unless ($iamgmod) {
		($title, $stars, $starpic, $color) = split(/\|/, $Group{"Administrator"});
		$showProfile .= qq~\n			<option value="Administrator">$title</option>~;
		($title, $stars, $starpic, $color) = split(/\|/, $Group{"Global Moderator"});
		$showProfile .= qq~\n			<option value="Global Moderator">$title</option>~;
	}

	my $z = 0;
	foreach (@nopostorder) {
		($title, $stars, $starpic, $color, undef) = split(/\|/, $NoPost{$_}, 5);
		$showProfile .= qq~<option value="$_">$title</option>~;
		$z++;
	}

	$showProfile .= qq~
			</select>
		</td>
	</tr>~;

	if ($tta ne "") {
		$showProfile .= qq~
	<tr class="windowbg">
		<td width="320" align="left" valign="top"><label for="addgroup"><b>$profile_txt{'87a'}: </b><br /><span class="small">$profile_txt{'87b'}</span></label></td>
		<td align="left">
			<select name="addgroup" id="addgroup" size="$selsize" multiple="multiple">
			$tta
			</select>
		</td>
	</tr>~;
	}

	($dr_secund, $dr_minute, $dr_hour, $dr_day, $dr_month, $dr_year, undef, undef, undef) = localtime(${$uid.$user}{'regtime'} ? ${$uid.$user}{'regtime'} : $forumstart);
	$dr_month++;

	if ($dr_month > 12) { $dr_month = 12; } ## month cannot be above 12!
	if ($dr_month < 1) { $dr_month = 1; } ## neither can it be less than 1
	if ($dr_day > 31) { $dr_day = 31; }  ## day of month over 31
	if ($dr_day < 1) { $dr_day = 1; }
	if (length($dr_year) > 2) { $dr_year = substr($dr_year , length($dr_year) - 2, 2); }
	if ($dr_year < 90 && $dr_year > 50) { $dr_year = 90; } ## a year over 50 is taken to be 1990
	if ($dr_year > 20 && $dr_year < 51) { $dr_year = 20; } ## a year 50 or lower is taken to be 2020 
	if ($dr_hour > 23) { $dr_hour = 23; }
	if ($dr_minute > 59) { $dr_minute = 59; }
	if ($dr_secund > 59) { $dr_secund = 59; }

	$sel_day = qq~
			<select name="dr_day">\n~;
	for($i = 1; $i <= 31; $i++) {
		$day_val = sprintf("%02d", $i);
		if($dr_day == $i) {
			$sel_day .= qq~			<option value="$day_val" selected="selected">$i</option>\n~;
		} else {
			$sel_day .= qq~			<option value="$day_val">$i</option>\n~;
		}
	}
	$sel_day .= qq~			</select>\n~;

	$sel_month = qq~
			<select name="dr_month">\n~;
	for($i = 0; $i < 12; $i++) {
		$z = $i+1;
		$month_val = sprintf("%02d", $z);
		if ($dr_month == $z) {
			$sel_month .= qq~			<option value="$month_val" selected="selected">$months[$i]</option>\n~;
		} else {
			$sel_month .= qq~			<option value="$month_val">$months[$i]</option>\n~;
		}
	}
	$sel_month .= qq~			</select>\n~;

	$sel_year = qq~
			<select name="dr_year">\n~;
	for (my $i = 1990; $i <= $year; $i++) {
		my $year_val = substr($i,2,2);
		if ($dr_year == $year_val) {
			$sel_year .= qq~			<option value="$year_val" selected="selected">$i</option>\n~;
		} else {
			$sel_year .= qq~			<option value="$year_val">$i</option>\n~;
		}
	}
	$sel_year .= qq~			</select>~;

	$time_sel = ${$uid.$username}{'timeselect'};
	if($time_sel == 1 || $time_sel == 4 || $time_sel == 5) { $all_date = qq~$sel_month $sel_day $sel_year~; }
	else { $all_date = qq~$sel_day $sel_month $sel_year~; }
	$all_date =~ s/<select name/<select id="dr_day_month" name/o;

	$sel_hour = qq~\n
			<select name="dr_hour">\n~;
	for($i = 0; $i <= 23; $i++) {
		my $hour_val = sprintf("%02d", $i);
		if($dr_hour == $i) {
			$sel_hour .= qq~			<option value="$hour_val" selected="selected">$hour_val</option>\n~;
		} else {
			$sel_hour .= qq~			<option value="$hour_val">$hour_val</option>\n~;
		}
	}
	$sel_hour .= qq~			</select>\n~;

	$sel_minute = qq~
			<select name="dr_minute">\n~;
	for($i = 0; $i <= 59; $i++) {
		$minute_val = sprintf("%02d", $i);
		if($dr_minute == $i) {
			$sel_minute .= qq~			<option value="$minute_val" selected="selected">$minute_val</option>\n~;
		} else {
			$sel_minute .= qq~			<option value="$minute_val">$minute_val</option>\n~;
		}
	}
	$sel_minute .= qq~			</select>~;

	$showProfile .= qq~
	<tr class="windowbg">
		<td width="320" align="left"><label for="dr_day_month"><b>$profile_txt{'233'}:</b></label></td>
		<td align="left" valign="middle">
			$all_date $maintxt{'107'} $sel_hour $sel_minute <small>(server <b>localtime</b>)</small>
			<input type="hidden" value="$dr_secund" name="dr_secund" />
		</td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><label for="regreason"><b>$profile_txt{'234'}:</b></label></td>
		<td align="left" valign="middle"><textarea rows="4" cols="50" name="regreason" id="regreason">$regreason</textarea></td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><b>$profile_amv_txt{'9'}: </b></td>
		<td align="left">$userlastlogin</td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><b>$profile_amv_txt{'10'}: </b></td>
		<td align="left">$userlastpost</td>
	</tr>
	<tr class="windowbg">
		<td width="320" align="left"><b>$profile_amv_txt{'11'}: </b><br /><br /></td>
		<td align="left">$userlastim<br /><br /></td>
	</tr>~;
 
	if ($extendedprofiles) {
		require "$sourcedir/ExtendedProfiles.pl";
		$showProfile .= &ext_editprofile($user,"admin");
	}

	$showProfile .= qq~
	<tr class="catbg">
		<td height="50" valign="middle" align="center" colspan="2"><input type="submit" name="moda" value="$profile_txt{'88'}" class="button" /><br /><span class="small">$profile_txt{'sid_expires_1'} $sid_expires $profile_txt{'sid_expires_2'}</span></td>
	</tr>
</table>
</form>~;

	if (!$view) {
		$yymain .= $showProfile;
		&template;
	}
}

sub ModifyProfile2 {
	&SidCheck($action);
	&PrepareProfile;

	my (%member, $key, $value);
	while (($key, $value) = each(%FORM)) {
		$value =~ s~\A\s+~~;
		$value =~ s~\s+\Z~~;
		$value =~ s~[\n\r]~~g;
		$member{$key} = $value;
	}

	if ($member{'moda'} eq $profile_txt{'88'}) {
		if ($sessions == 1 && $staff && $username eq $user) {
			if ($member{'sesquest'} eq "password") { $member{'sesanswer'} = ''; }
			elsif ($member{'sesanswer'} eq '') { &fatal_error('no_secret_answer'); }
		}

		if ($member{'passwrd1'} || $member{'passwrd2'}) {
			&fatal_error("no_password") if $member{'passwrd1'} eq '';
			&fatal_error("password_mismatch") if $member{'passwrd1'} ne $member{'passwrd2'};
			&fatal_error("password_is_userid") if $user eq $member{'passwrd1'};
			&fatal_error("invalid_character","$profile_txt{'36'} $profile_txt{'241'}") if $member{'passwrd1'} =~ /[^\s\w!\@#\$\%\^&\*\(\)\+\|`~\-=\\:;'",\.\/\?\[\]\{\}]/;
		}


		if ($member{'bday1'} ne "" || $member{'bday2'} ne "" || $member{'bday3'} ne "") {
			&fatal_error("invalid_birthdate","($member{'bday1'}/$member{'bday2'}/$member{'bday3'})") if ($member{'bday1'} !~ /^[0-9]+$/ || $member{'bday2'} !~ /^[0-9]+$/ || $member{'bday3'} !~ /^[0-9]+$/ || length($member{'bday3'}) < 4);
			&fatal_error("invalid_birthdate","($member{'bday1'}/$member{'bday2'}/$member{'bday3'})") if ($member{'bday1'} < 1 || $member{'bday1'} > 12 || $member{'bday2'} < 1 || $member{'bday2'} > 31 || $member{'bday3'} < 1901 || $member{'bday3'} > $year - 5);
		}
		$member{'bday1'} =~ s/[^0-9]//g;
		$member{'bday2'} =~ s/[^0-9]//g;
		$member{'bday3'} =~ s/[^0-9]//g;
		if ($member{'bday1'}) { $member{'bday'} = "$member{'bday1'}/$member{'bday2'}/$member{'bday3'}"; }
		else { $member{'bday'} = ''; }
		# EventCal Begin
		if (${$uid.$user}{'bday'} ne "$member{'bday'}") { $Update_EventCal = 1; }
		# EventCal End


		if ($extendedprofiles) { # run this before you start to save something!
			require "$sourcedir/ExtendedProfiles.pl";
			my $error = &ext_validate_submition($username,$user);
			if ($error ne "") { &fatal_error("extended_profiles_validation",$error); }
			&ext_saveprofile($user);
		}

		if ((!$cannot_change_displayname || $iamadmin) && ${$uid.$user}{'realname'} ne $member{'name'}) {
			$member{'name'} =~ s~\t+~\ ~g;
			if ($member{'name'} eq '') { &fatal_error("no_name"); }
			if ($name_cannot_be_userid && lc $member{'name'} eq lc $user) { &fatal_error('name_is_userid'); }

			&LoadCensorList;
			if (&Censor($member{'name'}) ne $member{'name'}) { &fatal_error("name_censored", &CheckCensor("$member{'name'}")); }

			if (${$uid.$user}{'password'} eq &encode_password($member{'name'})) { &fatal_error("password_is_userid"); }

			&FromChars($member{'name'});
			$convertstr = $member{'name'};
			$convertcut = 30;
			&CountChars;
			$member{'name'} = $convertstr;
			&fatal_error("name_too_long") if $cliped;
			&fatal_error("invalid_character","$profile_txt{'68'} $profile_txt{'241re'}") if $member{'name'} =~ /[^ \w\x80-\xFF\[\]\(\)#\%\+,\-\|\.:=\?\@\^]/;

			&ToHTML($member{'name'});
			&ToChars($member{'name'});

			if ($user ne "admin") {
				# Check to see if name is reserved
				my @reservecfg = &read_DBorFILE(0,'',$vardir,'reservecfg','txt');
				chomp(@reservecfg);
				my $matchword = $reservecfg[0] eq 'checked';
				my $matchcase = $reservecfg[1] eq 'checked';
				my $matchname = $reservecfg[3] eq 'checked';
				my $namecheck = $matchcase eq 'checked' ? $member{'name'} : lc $member{'name'};

				foreach my $reserved (&read_DBorFILE(0,'',$vardir,'reserve','txt')) {
					chomp $reserved;
					my $reservecheck = $matchcase ? $reserved : lc $reserved;
					if ($matchname) {
						if ($matchword) {
							if ($namecheck eq $reservecheck) { &fatal_error('id_reserved',"$reserved"); }
						} else {
							if ($namecheck =~ $reservecheck) { &fatal_error('id_reserved',"$reserved"); }
						}
					}
				}
			}

			if ((lc &MemberIndex("check_exist", $member{'name'}, $user) eq lc $member{'name'}) && (lc $member{'name'} ne lc $member{'username'})) { &fatal_error('name_taken',"($member{'name'})"); }

			# rewrite attachments.txt with new username
			my @attachments = &read_DBorFILE(0,ATM,$vardir,'attachments','txt');
			for (my $i = 0; $i < @attachments; $i++) {
				$attachments[$i] =~ s/^(\d+\|\d+\|.*?)\|(.*?)\|/ ($2 eq ${$uid.$user}{'realname'} ? "$1|$member{'name'}|" : "$1|$2|") /e;
			}
			&write_DBorFILE(0,ATM,$vardir,'attachments','txt',@attachments);

			#Since we haven't encountered a fatal error, time to rewrite our memberlist.
			&ManageMemberinfo("update", $user, '', $member{'name'}, '', '', '', '', ($Update_EventCal ? ($member{'bday'} ? $member{'bday'} : '-') : ''));

		} else {
			$member{'name'} = ${$uid.$user}{'realname'};
			&ManageMemberinfo("update", $user, '', '', '', '', '', '', ($member{'bday'} ? $member{'bday'} : '-')) if $Update_EventCal;
		}

		&ToHTML($member{'gender'});
		&FromChars($member{'location'});
		&ToHTML($member{'location'});
		&ToChars($member{'location'});
		&ToHTML($member{'bday'});
		&FromChars($member{'sesquest'});
		&ToHTML($member{'sesquest'});
		&ToChars($member{'sesquest'});


		# Time to print the changes to the username.vars file
		if ($member{'passwrd1'}) { ${$uid.$user}{'password'} = &encode_password($member{'passwrd1'}); }
		${$uid.$user}{'realname'} = $member{'name'};
		${$uid.$user}{'gender'} = $member{'gender'};
		${$uid.$user}{'location'} = $member{'location'};
		${$uid.$user}{'bday'} = $member{'bday'};
		${$uid.$user}{'sesquest'} = $member{'sesquest'};

		require "$sourcedir/Decoder.pl";
		${$uid.$user}{'sesanswer'} = &scramble($member{'sesanswer'}, $user);
		${$uid.$username}{'session'} = &encode_password($user_ip);

		# EventCal Begin
		if ($Update_EventCal == 1) {
			my @eventcalbday;
			&ManageMemberinfo("load");
			foreach (keys %memberinf) {
				my (undef, undef, undef, undef, undef, undef, $membday) = split(/\|/, $memberinf{$_}, 7);
				if ($membday) {
					my ($user_month, $user_day, $user_year) = split(/\//, $membday);
					if ($user_month < 10 && length($user_month) == 1) { $user_month = "0$user_month"; }
					if ($user_day < 10 && length($user_day) == 1) { $user_day = "0$user_day"; }
					push(@eventcalbday, qq~$user_year|$user_month|$user_day|$_\n~);				
				}
			}
			&write_DBorFILE(0,'',$vardir,'eventcalbday','db',@eventcalbday);
			undef %memberinf;
		}
		# EventCal End
		&UserAccount($user, "update");

		&UpdateCookie("write", $user, ${$uid.$user}{'password'}, ${$uid.$user}{'session'}, "/", "") if $member{'passwrd1'} && $username eq $user;

		my $scriptAction = $view ? 'myprofileContacts' : 'profileContacts';
		$yySetLocation = qq~$scripturl?action=$scriptAction;username=$useraccount{$user};sid=$INFO{'sid'}~;

	} elsif ($member{'moda'} eq $profile_txt{'89'}) {
		&fatal_error("cannot_kill_admin", $user) if $user eq 'admin' || !($iamadmin || $allow_self_del);

		# For security, remove username from mod position
		&KillModerator($user);

		&delete_DBorFILE("$memberdir/$user.dat");
		# &delete_DBorFILE("$memberdir/$user.vars") does delete also the
		# other files content if in SQL-Database!!! So no further need for &delete_DBorFILE(...)
		&delete_DBorFILE("$memberdir/$user.vars");
		&delete_DBorFILE("$memberdir/$user.ims");
		&delete_DBorFILE("$memberdir/$user.msg");
		&delete_DBorFILE("$memberdir/$user.log");
		&delete_DBorFILE("$memberdir/$user.rlog");
		&delete_DBorFILE("$memberdir/$user.outbox");
		&delete_DBorFILE("$memberdir/$user.imstore");
		&delete_DBorFILE("$memberdir/$user.imdraft");
		&delete_DBorFILE("$facesdir/UserAvatars/$1") if ${$uid.$user}{'userpic'} && ${$uid.$user}{'userpic'} =~ /$facesurl\/UserAvatars\/(.+)/;

		&MemberIndex("remove", $user);
		
		# EventCal Begin
		my @eventcalbday;
		&ManageMemberinfo("load");
		foreach (keys %memberinf) {
			my (undef, undef, undef, undef, undef, undef, $membday) = split(/\|/, $memberinf{$_}, 7);
			if ($membday) {
				my ($user_month, $user_day, $user_year) = split(/\//, $membday);
				if ($user_month < 10 && length($user_month) == 1) { $user_month = "0$user_month"; }
				if ($user_day < 10 && length($user_day) == 1) { $user_day = "0$user_day"; }
				push(@eventcalbday, qq~$user_year|$user_month|$user_day|$_\n~);				
			}
		}
		&write_DBorFILE(0,'',$vardir,'eventcalbday','db',@eventcalbday);
		undef %memberinf;
		# EventCal End


		if (!$iamadmin) {
			&UpdateCookie("delete");
			$username = 'Guest';
			$iamguest = 1;
			$iamadmin = '';
			$iamgmod = '';
			$password = '';
			$yyim = '';
			$ENV{'HTTP_COOKIE'} = '';
			$yyuname = '';
		}
		$yySetLocation = $scripturl;

	} else {
		&fatal_error('not_allowed');
	}

	&redirectexit;
}

sub ModifyProfileContacts2 {
	&SidCheck($action);
	&PrepareProfile;

	my (%member, $key, $value, $newpassemail, $tempname, $stealth);
	while (($key, $value) = each(%FORM)) {
		$value =~ s~\A\s+~~;
		$value =~ s~\s+\Z~~;
		$value =~ s~\r~~g;
		$value =~ s~\n~~g if $key ne 'awayreply';
		$member{$key} = $value;
	}
	$member{'username'} = $user;

	&fatal_error("not_allowed") if $member{'moda'} ne $profile_txt{'88'};

	if ($emailnewpass && lc $member{'email'} ne lc ${$uid.$user}{'email'} && !$iamadmin) {
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
		${$uid.$user}{'password'} = &encode_password($member{'passwrd1'});
		$newpassemail = 1;
	}

	&fatal_error("no_email") if $member{'email'} eq '';
	&fatal_error("invalid_character","$profile_txt{'69'} $profile_txt{'241e'}") if $member{'email'} !~ /^[\w\-\.\+]+\@[\w\-\.\+]+\.\w{2,4}$/;
	&fatal_error("invalid_email") if ($member{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($member{'email'} !~ /^.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?$/);

	$member{'icq'} =~ s/[^0-9]//g;
	$member{'aim'} =~ s/ /\+/g;
	$member{'yim'} =~ s/ /\+/g;
	$member{'msn'} =~ s/ /\+/g;

	&ToHTML($member{'email'});
	&ToHTML($member{'icq'});
	&ToHTML($member{'aim'});
	&ToHTML($member{'yim'});
	&ToHTML($member{'msn'});
	&ToHTML($member{'gtalk'});
	&ToHTML($member{'skype'});
	&ToHTML($member{'myspace'});
	&ToHTML($member{'facebook'});
	&ToHTML($member{'weburl'});
	&FromChars($member{'webtitle'});
	&ToHTML($member{'webtitle'});
	&ToChars($member{'webtitle'});
	&ToHTML($member{'offlinestatus'});
	&FromChars($member{'awaysubj'});
	&ToHTML($member{'awaysubj'});
	&ToChars($member{'awaysubj'});

	&FromChars($member{'awayreply'});
	&ToHTML($member{'awayreply'});
	$member{'awayreply'} =~ s~\n~<br />~g;
	$convertstr = $member{'awayreply'};
	$convertcut = $MaxAwayLen;
	&CountChars;
	$member{'awayreply'} = $convertstr;
	&ToChars($member{'awayreply'});

	if ($extendedprofiles) { # run this before you start to save something!
		require "$sourcedir/ExtendedProfiles.pl";
		my $error = &ext_validate_submition($username,$user);
		if ($error ne "") { &fatal_error("extended_profiles_validation",$error); }
		&ext_saveprofile($user);
	}

	# Check to see if email is already taken
	if (lc ${$uid.$user}{'email'} ne lc $member{'email'}) {
		$testemail = lc $member{'email'};
		my $is_existing = &MemberIndex("check_exist", "$testemail");
		if (lc $is_existing eq $testemail) { &fatal_error("email_taken","($member{'email'})"); }

		# Since we haven't encountered a fatal error, time to rewrite our memberlist a little.
		&ManageMemberinfo("update", $user, '', '', $member{'email'});
	}
	## if enabled but not set, default offline status to 'offline'
	if ($enable_MCaway && $member{'offlinestatus'} eq '') { $member{'offlinestatus'} = 'offline'; }

	# if user is switching 'away' to 'off/on', clean out the away-sent list
	if ($FORM{'offlinestatus'} eq 'offline') { ${$uid.$user}{'awayreplysent'} = ''; }

	# Time to print the changes to the username.vars file
	${$uid.$user}{'email'} = $member{'email'};
	${$uid.$user}{'hidemail'} = $member{'hideemail'} ? 1 : 0;
	${$uid.$user}{'icq'} = $member{'icq'};
	${$uid.$user}{'aim'} = $member{'aim'};
	${$uid.$user}{'yim'} = $member{'yim'};
	${$uid.$user}{'msn'} = $member{'msn'};
	${$uid.$user}{'gtalk'} = $member{'gtalk'};
	${$uid.$user}{'skype'} = $member{'skype'};
	${$uid.$user}{'myspace'} = $member{'myspace'};
	${$uid.$user}{'facebook'} = $member{'facebook'};
	${$uid.$user}{'webtitle'} = $member{'webtitle'};
	${$uid.$user}{'weburl'} = (($member{'weburl'} && $member{'weburl'} !~ m~\Ahttps?://~) ? "http://" : "") . $member{'weburl'};
	${$uid.$user}{'offlinestatus'} = $member{'offlinestatus'};
	${$uid.$user}{'awaysubj'} = $member{'awaysubj'};
	${$uid.$user}{'awayreply'} = $member{'awayreply'};
	${$uid.$user}{'stealth'} = (${$uid.$user}{'position'} eq 'Administrator' || ${$uid.$user}{'position'} eq 'Global Moderator') ? $member{'stealth'} : "";

	&UserAccount($user, "update");

	if ($emailnewpass && $newpassemail == 1) {
		&RemoveUserOnline($user); # Remove user from online log

		if ($username eq $user) {
			&UpdateCookie("delete");
			$username = 'Guest';
			$iamguest = 1;
			$iamadmin = '';
			$iamgmod = '';
			$password = '';
			$yyim = '';
			$ENV{'HTTP_COOKIE'} = '';
			$yyuname = '';
		}
		&FormatUserName($member{'username'});
		require "$sourcedir/Mailer.pl";
		my $scriptAction = $view ? 'myprofile' : 'profile';
		&sendmail($member{'email'}, qq~$profile_txt{'700'} $mbname~, "$profile_txt{'733'} $member{'passwrd1'} $profile_txt{'734'} $member{'username'}.\n\n$profile_txt{'701'} $scripturl?action=$scriptAction;username=$useraccount{$member{'username'}}\n\n$profile_txt{'130'}");
		require "$sourcedir/LogInOut.pl";
		$sharedLogin_title = "$profile_txt{'34'}: $user";
		$sharedLogin_text = $profile_txt{'638'};
		$shared_login = &sharedLogin;
		$yymain .= $shared_login;
		$yytitle = $profile_txt{'245'};
		&template;
	}

	my $scriptAction = $view ? 'myprofileOptions' : 'profileOptions';
	$yySetLocation = qq~$scripturl?action=$scriptAction;username=$useraccount{$member{'username'}};sid=$INFO{'sid'}~;
	&redirectexit;
}

sub ModifyProfileOptions2 {
	&SidCheck($action);
	&PrepareProfile;

	my (%member, $key, $value, $tempname);
	while (($key, $value) = each(%FORM)) {
		$value =~ s~\A\s+~~;
		$value =~ s~\s+\Z~~;
		$value =~ s~\r~~g;
		$value =~ s~\n~~g if $key ne 'signature';
		$member{$key} = $value;
	}
	$member{'username'} = $user;

	&fatal_error("not_allowed") if $member{'moda'} ne $profile_txt{'88'};

	if (!$minlinksig){ $minlinksig = 0 ;}
	if (${$uid.$user}{'postcount'} < $minlinksig && !$iamadmin && !$iamgmod) {
		if ($member{'signature'} =~ m~http:\/\/~ || $member{'signature'} =~ m~https:\/\/~ || $member{'signature'} =~ m~ftp:\/\/~ || $member{'signature'} =~ m~www.~ || $member{'signature'} =~ m~ftp.~ =~ m~\[url~ || $member{'signature'} =~ m~\[link~ || $member{'signature'} =~ m~\[img~ || $member{'signature'} =~ m~\[ftp~) {
			&fatal_error("no_siglinks_allowed");
		}
	}
	&FromChars($member{'usertext'});
	$convertstr = $member{'usertext'};
	$convertcut = 51;
	&CountChars;
	$member{'usertext'} = $convertstr;
	&ToHTML($member{'usertext'});
	&ToChars($member{'usertext'});

	if ($allowpics) {
		opendir(DIR, "$facesdir") || fatal_error("cannot_open_dir","($facesdir)!<br \/>$profile_txt{'681'}", 1);
		closedir(DIR);
	}

	if ($allowpics && $upload_useravatar && $upload_avatargroup) {
		$upload_useravatar = 0;
		foreach my $av_gr (split(/, /, $upload_avatargroup)) {
			if ($av_gr eq ${$uid.$user}{'position'}) { $upload_useravatar = 1; last; }
			foreach (split(/,/, ${$uid.$user}{'addgroups'})) {
				if ($av_gr eq $_) { $upload_useravatar = 1; last; }
			}
		}
	}

	my $file = $CGI_query->upload("file_avatar") if $CGI_query;
	if ($allowpics && $upload_useravatar && $file) {
		if ($file !~ /\.(gif|png|jpe?g)$/i) {
			&LoadLanguage('FA');
			&fatal_error('file_not_uploaded',"$file $fatxt{'20'} gif png jpeg jpg");
		}
		my $ext = $1;
		my $fixfile = ${$uid.$user}{'realname'};
		if ($fixfile =~ /[^0-9A-Za-z\+\-\.:_]/) { # replace all inappropriate characters
			# Transliteration
			my @ISO_8859_1 = qw(A B V G D E JO ZH Z I J K L M N O P R S T U F H C CH SH SHH _ Y _ JE JU JA a b v g d e jo zh z i j k l m n o p r s t u f h c ch sh shh _ y _ je ju ja);
			my $x = 0;
			foreach (qw(À Á Â Ã Ä Å ¨ Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ Ò Ó Ô Õ Ö × Ø Ù Ú Û Ü Ý Þ ß à á â ã ä å ¸ æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ÷ ø ù ú û ü ý þ ÿ)) {
				 $fixfile =~ s/$_/$ISO_8859_1[$x]/ig;
				 $x++;
			}
			# END Transliteration. Thanks to "Velocity" for this contribution.
			$fixfile =~ s/[^0-9A-Za-z\+\-\.:_]/_/g; 
		}
		$fixfile .= ".$ext";

		require "$sourcedir/SpamCheck.pl";
		my $spamdetected = &spamcheck("$fixfile");
		if (!$staff){
			if ($spamdetected == 1) {
				${$uid.$username}{'spamcount'}++;
				${$uid.$username}{'spamtime'} = $date;
				&UserAccount($username,"update");
				$spam_hits_left_count = $post_speed_count - ${$uid.$username}{'spamcount'};
				&fatal_error("tsc_alert");
			}
		}

		my ($size,$buffer,$filesize,$file_buffer);
		while ($size = read($file, $buffer, 512)) { $filesize += $size; $file_buffer .= $buffer; }
		if ($avatar_limit && $filesize > (1024 * $avatar_limit)) {
			&LoadLanguage('FA');
			&fatal_error('file_not_uploaded',"$fatxt{'21'} $file (" . int($filesize / 1024) . " KB) $fatxt{'21b'} " . $avatar_limit);
		}
		if ($avatar_dirlimit) {
			my $dirsize = &dirsize("$facesdir/UserAvatars");
			if ($filesize > ((1024 * $avatar_dirlimit) - $dirsize)) {
				&LoadLanguage('FA');
				&fatal_error('file_not_uploaded',"$fatxt{'22'} $file (" . (int($filesize / 1024) - $avatar_dirlimit + int($dirsize / 1024)) . " KB) $fatxt{'22b'}");
			}
		}

		&delete_DBorFILE("$facesdir/UserAvatars/$1") if ${$uid.$user}{'userpic'} =~ /$facesurl\/UserAvatars\/(.+)/;
		$fixfile = &check_existence("$facesdir/UserAvatars", $fixfile);

		# create a new file on the server using the formatted ( new instance ) filename
		if (fopen(NEWFILE, ">$facesdir/UserAvatars/$fixfile")) {
			binmode NEWFILE; # needed for operating systems (OS) Windows, ignored by Linux
			print NEWFILE $file_buffer; # write new file on HD
			fclose(NEWFILE);

		} else { # return the server's error message if the new file could not be created
			&fatal_error("file_not_open","$facesdir/UserAvatars");
		}

		# check if file has actually been uploaded, by checking the file has a size
		unless (-s "$facesdir/UserAvatars/$fixfile") {
			&fatal_error("file_not_uploaded",$fixfile);
		}

		my $illegal;
		if ($fixfile =~ /gif$/i) {
			my $header;
			fopen(ATTFILE, "$facesdir/UserAvatars/$fixfile");
			read(ATTFILE, $header, 10);
			my $giftest;
			($giftest, undef, undef, undef, undef, undef) = unpack("a3a3C4", $header);
			fclose(ATTFILE);
			if ($giftest ne "GIF") { $illegal = $giftest; }
		}
		fopen(ATTFILE, "$facesdir/UserAvatars/$fixfile");
		while ( read(ATTFILE, $buffer, 1024) ) {
			if ($buffer =~ /<(html|script|body)/ig) { $illegal = $1; last; }
		}
		fclose(ATTFILE);
		if ($illegal) { # delete the file as it contains illegal code
			&delete_DBorFILE("$facesdir/UserAvatars/$fixfile");
			&ToHTML($illegal);
			&fatal_error("file_not_uploaded","$fixfile <= illegal code ($illegal) inside image file!");
		}

		$member{'userpic'} = "$facesurl/UserAvatars/$fixfile";

	} elsif ($member{'userpicpersonalcheck'} && ($member{'userpicpersonal'} =~ /\.gif\Z/i || $member{'userpicpersonal'} =~ /\.jpe?g\Z/i || $member{'userpicpersonal'} =~ /\.png\Z/i)) {
		$member{'userpic'} = $member{'userpicpersonal'};
	}
	if ($member{'userpic'} eq "" || !$allowpics) { $member{'userpic'} = "blank.gif"; }
	&fatal_error("invalid_character","$profile_txt{'592'}") if $member{'userpic'} !~ m^\A[0-9a-zA-Z_\.\#\%\-\:\+\?\$\&\~\.\,\@/]+\Z^;
	&delete_DBorFILE("$facesdir/UserAvatars/$1") if $member{'userpic'} ne ${$uid.$user}{'userpic'} && ${$uid.$user}{'userpic'} =~ /$facesurl\/UserAvatars\/(.+)/;

	if ($member{'usertemplate'} ne '' && !$templateset{$member{'usertemplate'}}) { &fatal_error('invalid_template'); }
	if ($member{'usertemplate'} eq '') { $member{'usertemplate'} = $template; }
	if ($member{'userlanguage'} ne '' && !-e "$langdir/$member{'userlanguage'}/Main.lng") { &fatal_error('invalid_language'); }
	if ($member{'userlanguage'} eq '') { $member{'userlanguage'} = $language; }

	if ($extendedprofiles) { # run this before you start to save something!
		require "$sourcedir/ExtendedProfiles.pl";
		my $error = &ext_validate_submition($username,$user);
		if ($error ne "") { &fatal_error("extended_profiles_validation",$error); }
		&ext_saveprofile($user);
	}

	if ($member{'usertimesign'} !~ /^-?$/ || $member{'usertimehour'} !~ /^\d+$/ || $member{'usertimemin'} !~ /^\d+$/) { &fatal_error("invalid_time_offset","$member{'usertimesign'}$member{'usertimehour'}.$member{'usertimemin'}"); }

	# update notifications if users language is changed
	if (${$uid.$user}{'language'} ne "$member{'userlanguage'}") {
		require "$sourcedir/Notify.pl";
		&updateLanguage($user, $member{'userlanguage'});
	}

	if ($addmemgroup_enabled > 1) {
		my %groups;
		map { $groups{$_} = 2; } split(/,/, ${$uid.$user}{'addgroups'});
		map { $groups{$_} = 1; } split(/, /, $member{'joinmemgroup'});
		my @nopostmember;
		foreach (keys %NoPost) {
			next if ${$uid.$user}{'position'} eq $_;
			if ($groups{$_} == 1 && (split /\|/, $NoPost{$_})[10]) { push(@nopostmember, $_); }
			elsif ($groups{$_} == 2 && !(split /\|/, $NoPost{$_})[10]) { push(@nopostmember, $_); }
		}
		$member{'joinmemgroup'} = join(',', @nopostmember);
		if ($member{'joinmemgroup'} eq '') { $member{'joinmemgroup'} = "###blank###"; }
		if ($member{'joinmemgroup'} ne ${$uid.$user}{'addgroups'}) {
			&ManageMemberinfo("update", $user, '', '', '', '', '', $member{'joinmemgroup'});
		}
		if ($member{'joinmemgroup'} eq "###blank###") { $member{'joinmemgroup'} = ''; }
		${$uid.$user}{'addgroups'} = $member{'joinmemgroup'};
	}

	&FromChars($member{'signature'});
	&ToHTML($member{'signature'});
	$member{'signature'} =~ s~\n~<br />~g;
	$convertstr = $member{'signature'};
	$convertcut = $MaxSigLen;
	&CountChars;
	$member{'signature'} = $convertstr;
	&ToChars($member{'signature'});

	&ToHTML($member{'userpic'});
	&ToHTML($member{'usertemplate'});
	&ToHTML($member{'userlanguage'});
	&ToHTML($member{'timeformat'});

	# Time to print the changes to the username.vars file
	${$uid.$user}{'usertext'} = $member{'usertext'};
	${$uid.$user}{'userpic'} = $member{'userpic'};
	${$uid.$user}{'signature'} = $member{'signature'};
	${$uid.$user}{'timeoffset'} = "$member{'usertimesign'}$member{'usertimehour'}.$member{'usertimemin'}";
	${$uid.$user}{'onlinealert'} = $member{'onlinealert'} ? 1 : 0;
	${$uid.$user}{'notify_me'} = $member{'notify_N'} ? ((!${$uid.$user}{'notify_me'} || ${$uid.$user}{'notify_me'} == 1) ? 1 : 3) : ((${$uid.$user}{'notify_me'} == 2 || ${$uid.$user}{'notify_me'} == 3) ? 2 : 0);
	${$uid.$user}{'reversetopic'} = $member{'reversetopic'} ? 1 : 0;
	${$uid.$user}{'dsttimeoffset'} = $member{'dsttimeoffset'} ? 1 : 0;
	${$uid.$user}{'dynamic_clock'} = $member{'dynamic_clock'} ? 1 : 0;
	${$uid.$user}{'timeselect'} = int($member{'usertimeselect'});
	${$uid.$user}{'template'} = $member{'usertemplate'};
	${$uid.$user}{'language'} = $member{'userlanguage'};
	${$uid.$user}{'timeformat'} = $member{'timeformat'};
	${$uid.$user}{'numberformat'} = int($member{'usernumberformat'});
	${$uid.$user}{'hide_avatars'} = ($member{'hide_avatars'} && $user_hide_avatars) ? 1 : 0;
	${$uid.$user}{'hide_user_text'} = ($member{'hide_user_text'} && $user_hide_user_text) ? 1 : 0;
	${$uid.$user}{'hide_attach_img'} = ($member{'hide_attach_img'} && $user_hide_attach_img) ? 1 : 0;
	${$uid.$user}{'hide_signat'} = ($member{'hide_signat'} && $user_hide_signat) ? 1 : 0;
	${$uid.$user}{'hide_smilies_row'} = ($member{'hide_smilies_row'} && $user_hide_smilies_row) ? 1 : 0;

	&UserAccount($user, "update");

	my $scriptAction;
	if ($iamadmin || ($iamgmod && $allow_gmod_profile && $gmod_access2{'profileAdmin'} eq 'on')) {
		$scriptAction = qq~profileAdmin~;
	} else {
		$scriptAction = qq~viewprofile~;
	}
	if ($PM_level == 1 || ($PM_level == 2 && $staff) || ($PM_level == 3 && ($iamadmin || $iamgmod))) {
		$scriptAction = qq~profileIM~;
	}
	if ($buddyListEnabled) {
		$scriptAction = qq~profileBuddy~;
	}
	if ($view) { $scriptAction = qq~my$scriptAction~; }
	$yySetLocation = qq~$scripturl?action=$scriptAction;username=$useraccount{$member{'username'}};sid=$INFO{'sid'}~;
	&redirectexit;
}

sub ModifyProfileBuddy2 {
	&SidCheck($action);
	&PrepareProfile;

	my (%member, $key, $value, $tempname);
	while (($key, $value) = each(%FORM)) {
		$value =~ s~\A\s+~~;
		$value =~ s~\s+\Z~~;
		$value =~ s~[\n\r]~~g;
		$member{$key} = $value;
	}
	$member{'username'} = $user;

	&fatal_error("not_allowed") if $member{'moda'} ne $profile_txt{'88'};

	if ($member{'buddylist'}) {
		my @buddies = split(/\,/, $member{'buddylist'});
		chomp(@buddies);
		$member{'buddylist'} = '';
		foreach my $cloakedBuddy (@buddies) {
			$cloakedBuddy =~ s/^ //;
			$cloakedBuddy = &decloak($cloakedBuddy);
			&ToHTML($cloakedBuddy);
			$member{'buddylist'} = qq~$member{'buddylist'}\|$cloakedBuddy~;
		}
		$member{'buddylist'} =~ s/^\|//;
	}
	${$uid.$user}{'buddylist'} = $member{'buddylist'};
	&UserAccount($user, "update");

	my $scriptAction;
	if ($iamadmin || ($iamgmod && $allow_gmod_profile && $gmod_access2{'profileAdmin'} eq 'on')) {
		$scriptAction = qq~profileAdmin~;
	} else {
		$scriptAction = qq~viewprofile~;
	}
	if ($PM_level == 1 || ($PM_level == 2 && $staff) || ($PM_level == 3 && ($iamadmin || $iamgmod))) {
		$scriptAction = qq~profileIM~;
	}
	if ($view) { $scriptAction = qq~my$scriptAction~; }
	$yySetLocation = qq~$scripturl?action=$scriptAction;username=$useraccount{$member{'username'}};sid=$INFO{'sid'}~;
	&redirectexit;
}

sub ModifyProfileIM2 {
	&SidCheck($action);
	&PrepareProfile;

	my (%member, $key, $value, $ignorelist);
	while (($key, $value) = each(%FORM)) {
		$value =~ s~\A\s+~~;
		$value =~ s~\s+\Z~~;
		$value =~ s~[\n\r]~~g if $key ne 'ignore';
		$member{$key} = $value;
	}
	$member{'username'} = $user;

	&fatal_error("not_allowed") if $member{'moda'} ne $profile_txt{'88'};

	if (!$member{'ignoreall'}) {
		my @ignoreList = split(/\,/, $member{'ignore'});
		chomp (@ignoreList);
		foreach my $cloakedIgnore (@ignoreList)	{
			$cloakedIgnore =~s/\A //;
			$cloakedIgnore =~s/ \Z//;
			$cloakedIgnore = &decloak($cloakedIgnore);
			&ToHTML ($cloakedIgnore);
			$ignorelist .= qq~\|$cloakedIgnore~;
		}
		$ignorelist =~ s~\A\|~~;
	} else {
		$ignorelist = '*';
	}

	# Time to print the changes to the username.vars file
	${$uid.$user}{'im_ignorelist'} = $ignorelist;
	${$uid.$user}{'notify_me'} = $member{'notify_PM'} ? ((!${$uid.$user}{'notify_me'} || ${$uid.$user}{'notify_me'} == 2) ? 2 : 3) : ((${$uid.$user}{'notify_me'} == 1 || ${$uid.$user}{'notify_me'} == 3) ? 1 : 0);
	${$uid.$user}{'im_popup'} = $member{'userpopup'} ? 1 : 0;
	${$uid.$user}{'im_imspop'} = $member{'popupims'} ? 1 : 0;
	${$uid.$user}{'pmactprev'} = $member{'pmactprev'} ? 1 : 0;
	${$uid.$user}{'pmmessprev'} = $member{'pmmessprev'} ? 1 : 0;
	${$uid.$user}{'pmviewMess'} = $member{'pmviewMess'} ? 1 : 0;

	if ($extendedprofiles) { # run this before you start to save something!
		require "$sourcedir/ExtendedProfiles.pl";
		my $error = &ext_validate_submition($username,$user);
		if ($error ne "") { &fatal_error("extended_profiles_validation",$error); }
		&ext_saveprofile($user);
	}
	&UserAccount($user, "update");

	my $scriptAction = qq~viewprofile~;
	if ($iamadmin || ($iamgmod && $allow_gmod_profile && $gmod_access2{'profileAdmin'} eq 'on')) {
		$scriptAction = qq~profileAdmin~;
	}
	if ($view) { $scriptAction = qq~my$scriptAction~; }
	$yySetLocation = qq~$scripturl?action=$scriptAction;username=$useraccount{$member{'username'}};sid=$INFO{'sid'}~;
	&redirectexit;
}

sub ModifyProfileAdmin2 {
	&is_admin_or_gmod;

	&SidCheck($action);
	&PrepareProfile;

	my (%member, $key, $value);
	while (($key, $value) = each(%FORM)) {
		$value =~ s~\A\s+~~;
		$value =~ s~\s+\Z~~;
		$value =~ s~[\n\r]~~g if $key ne 'regreason';
		$member{$key} = $value;
	}
	$member{'username'} = $user;

	&fatal_error("not_allowed") if $member{'moda'} ne $profile_txt{'88'};

	if (!$iamadmin && ($member{'settings7'} eq "Administrator" || $member{'settings7'} eq "Global Moderator")) {
		$member{'settings7'} = ${$uid.$user}{'position'};
	}

	if ($member{'settings6'} eq '') { $member{'settings6'} = 0; }
	if ($member{'settings6'} !~ /\A[0-9]+\Z/) { &fatal_error('invalid_postcount'); }
	&fatal_error('cannot_regroup_admin') if $member{'username'} eq 'admin' && $member{'settings7'} ne 'Administrator';

	$dr_month  = $member{'dr_month'};
	$dr_day    = $member{'dr_day'};
	$dr_year   = $member{'dr_year'};
	$dr_hour   = $member{'dr_hour'};
	$dr_minute = $member{'dr_minute'};
	$dr_secund = $member{'dr_secund'};

	if ($dr_month == 4 || $dr_month == 6 || $dr_month == 9 || $dr_month == 11) {
		$max_days = 30;
	} elsif ($dr_month == 2 && $dr_year % 4 == 0) {
		$max_days = 29;
	} elsif ($dr_month == 2 && $dr_year % 4 != 0) {
		$max_days = 28;
	} else {
		$max_days = 31;
	}
	if ($dr_day > $max_days) { $dr_day = $max_days; }

	$member{'dr'} = qq~$dr_month/$dr_day/$dr_year $maintxt{'107'} $dr_hour:$dr_minute:$dr_secund~;

	if ($member{'settings6'} != ${$uid.$user}{'postcount'} || $member{'settings7'} ne ${$uid.$user}{'position'}) {
		if ($member{'settings7'}) {
			$grp_after = qq~$member{'settings7'}~;
		} else {
			foreach $postamount (sort { $b <=> $a } keys %Post) {
				if ($member{'settings6'} >= $postamount) {
					($title, undef) = split(/\|/, $Post{$postamount}, 2);
					$grp_after = $title;
					last;
				}
			}
		}
		&ManageMemberinfo("update", $user, '', '', '', $grp_after, $member{'settings6'});
	}

	my %groups;
	map { $groups{$_} = 1; } split(/, /, $member{'addgroup'});
	my @nopostmember;
	foreach (keys %NoPost) {
		next if $member{'settings7'} eq $_;
		push(@nopostmember, $_) if $groups{$_};
	}
	$member{'addgroup'} = join(',', @nopostmember);
	if ($member{'addgroup'} eq '') { $member{'addgroup'} = "###blank###"; }
	if ($member{'addgroup'} ne ${$uid.$user}{'addgroups'}) {
		&ManageMemberinfo("update", $user, '', '', '', '', '', $member{'addgroup'});
	}
	if ($member{'addgroup'} eq "###blank###") { $member{'addgroup'} = ''; }
	${$uid.$user}{'addgroups'} = $member{'addgroup'};

	if ($member{'dr'} ne ${$uid.$user}{'regdate'}) {
		$newreg = &stringtotime($member{'dr'});
		$newreg = sprintf("%010d", $newreg);
		&ManageMemberinfo("update", $user, $newreg);
		${$uid.$user}{'regtime'} = $newreg;
	}

	if (!$iamadmin) { $member{'dr'} = ${$uid.$user}{'regdate'}; }
	&FromChars($member{'regreason'});
	&ToHTML($member{'regreason'});
	&ToChars($member{'regreason'});
	$member{'regreason'} =~ s~[\n\r]{1,2}~<br />~g;
	${$uid.$user}{'regreason'} = $member{'regreason'};
	${$uid.$user}{'postcount'} = $member{'settings6'};
	${$uid.$user}{'position'}  = $member{'settings7'};
	${$uid.$user}{'regdate'}   = $member{'dr'};
	${$uid.$user}{'stealth'}   = "" if ${$uid.$user}{'position'} ne 'Administrator' && ${$uid.$user}{'position'} ne 'Global Moderator';

	if ($extendedprofiles) { # run this before you start to save something!
		require "$sourcedir/ExtendedProfiles.pl";
		my $error = &ext_validate_submition($username,$user);
		if ($error ne "") { &fatal_error("extended_profiles_validation",$error); }
		&ext_saveprofile($user);
	}
	&UserAccount($user, "update");

	my $scriptAction = $view ? 'myviewprofile' : 'viewprofile';
	$yySetLocation = qq~$scripturl?action=$scriptAction;username=$useraccount{$user}~;
	&redirectexit;
}

sub ViewProfile {
	if ($iamguest) { &fatal_error('members_only'); }

	# If someone registers with a '+' in their name It causes problems.
	# Get's turned into a <space> in the query string Change it back here.
	# Users who register with spaces get them replaced with _
	# So no problem there.
	$INFO{'username'} =~ tr/ /+/;

	$user = $INFO{'username'};
	if ($do_scramble_id) { &decloak($user); }
	if ($user =~ m~/~)  { &fatal_error('no_user_slash'); }
	if ($user =~ m~\\~) { &fatal_error('no_user_backslash'); }

	unless (&LoadUser($user)) { &fatal_error('no_profile_exists'); }
	&LoadMiniUser($user) if $user eq $username;

	my ($memberinfo, $modify, $email, $gender, $avstyle, $pic);
	my ($pic_row, $buddybutton, $row_addgrp, $row_gender, $row_age, $row_location, $row_icq, $row_aim, $row_yim, $row_msn, $row_gtalk, $row_skype, $row_myspace, $row_facebook, $row_email, $row_website, $row_signature, $send_PM, $showusertext);

	# Convert forum start date to string, if there is no date set,
	# Defaults to 1st Jan, 2005
	$forumstart = $forumstart ? &stringtotime($forumstart) : "1104537600";

	if (${$uid.$user}{'regtime'}) {
		$dr = &timeformat(${$uid.$user}{'regtime'});
	} else {
		$dr = $profile_txt{'470'};
	}

	&CalcAge($user, "calc");   # How old is he/she?
	&CalcAge($user, "isbday"); # is it the bday?
	if ($isbday) { $isbday = qq~<img src="$imagesdir/bdaycake.gif" width="40" />~; }

	## only show the 'modify' button if not using 'my center' or admin/gmod viewing
	$modify = (!$view && ($user ne "admin" || $username eq "admin") && ($iamadmin || ($iamgmod && $allow_gmod_profile && ${$uid.$user}{'position'} ne "Administrator"))) ? qq~<a href="$scripturl?action=profileCheck;username=$useraccount{$user}">$img{'modify'}</a>~ : "&nbsp;";

	if ($allowpics) {
		if (${$uid.$user}{'userpic'} eq "blank.gif") {
			$pic = qq~<img src="$imagesdir/nn.gif" name="avatar_img_resize" alt="" border="0" style="display:none" />~;
		} elsif (${$uid.$user}{'userpic'} =~ /^https?:\/\//) {
			$pic = qq~<img src="${$uid.$user}{'userpic'}" name="avatar_img_resize" alt="" border="0" style="display:none" />~;
		} else {
			$pic = qq~<img src="$facesurl/${$uid.$user}{'userpic'}" name="avatar_img_resize" alt="" border="0" style="display:none" />~;
		}
		$pic_row = qq~<div style="float: left; width: 20%; text-align: center; padding: 5px 5px 5px 0px;">
			$pic
			</div>~;
	}

	if ($buddyListEnabled && $user ne $username) {
		&loadMyBuddy;
		$buddybutton = "<br />" . ($mybuddie{$user} ? qq~<img src="$imagesdir/buddylist.gif" border="0" align="middle" alt="$display_txt{'isbuddy'}" /> $display_txt{'isbuddy'}~ : qq~<a href="$scripturl?action=addbuddy;name=$useraccount{$user}">$img{'addbuddy'}</a>~);
	}

	# Hide empty profile fields from display
	if ($addmembergroup{$user}) {
		$showaddgr = $addmembergroup{$user};
		$showaddgr =~ s/<br \/>/\, /g;
		$showaddgr =~ s/\A, //;
		$showaddgr =~ s/, \Z//;
		$row_addgrp .= qq~<br /><span class="small">$showaddgr</span>~;
	}
	if (${$uid.$user}{'gender'}) {
		if (${$uid.$user}{'gender'} eq 'Male') { $gender = $profile_txt{'238'}; } 
		elsif (${$uid.$user}{'gender'} eq 'Female') { $gender = $profile_txt{'239'}; }
		$row_gender = qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;">
			<b>$profile_txt{'231'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			$gender
			</div>~;
	}
	if ($age) {
		$row_age = qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;">
			<b>$profile_txt{'420'}:</b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			$age &nbsp; $isbday
			</div>~;
	}
	if (${$uid.$user}{'location'}) {
		$row_location = qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;">
			<b>$profile_txt{'227'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			${$uid.$user}{'location'}
			</div>~;
	}
	if (${$uid.$user}{'icq'} && ${$uid.$user}{'icq'} !~ m/\D/) {
		$row_icq .= qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;">
			<b>$profile_txt{'513'}:</b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			<a href="http://web.icq.com/${$uid.$user}{'icq'}" title="${$uid.$user}{'icq'}" target="_blank">
			<img src="http://web.icq.com/whitepages/online?icq=${$uid.$user}{'icq'}&#38;img=5" alt="${$uid.$user}{'icq'}" border="0" style="vertical-align: middle;" /> ${$uid.$user}{'icq'}</a>
			</div>~;
	}
	if (${$uid.$user}{'aim'}) {
		my $aim_user = ${$uid.$user}{'aim'};
		$aim_user =~ tr/\+/ /;
		$row_aim = qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;">
			<b>$profile_txt{'603'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			<a href="aim:goim?screenname=${$uid.$user}{'aim'}&#38;message=Hi,+are+you+there?">
			<img src="$imagesdir/aim.gif" alt="${$uid.$user}{'aim'}" border="0" style="vertical-align: middle;" /> $aim_user</a>
			</div>~;
	}
	if (${$uid.$user}{'yim'}) {
		my $yim_user = ${$uid.$user}{'yim'};
		$yim_user =~ tr/\+/ /;
		$row_yim = qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;">
			<b>$profile_txt{'604'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			<img src="http://opi.yahoo.com/online?u=${$uid.$user}{'yim'}&#38;m=g&#38;t=0" border="0" alt="${$uid.$user}{'yim'}" style="vertical-align: middle;" />
			<a href="http://edit.yahoo.com/config/send_webmesg?.target=${$uid.$user}{'yim'}" target="_blank"> $yim_user</a>
			</div>~;
	}
	if (${$uid.$user}{'msn'}) {
		$row_msn = qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;">
			<b>$profile_txt{'823'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			<img src="$imagesdir/msn.gif" alt="" border="0" style="vertical-align: middle;" />
			<a href="#" onclick="window.open('$scripturl?action=setmsn;msnname=$user','','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'); return false">$profile_txt{'823'} ${$uid.$user}{'realname'}</a>
			</div>~;
	}
	if (${$uid.$user}{'gtalk'}) {
		$row_gtalk = qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;">
			<b>$profile_txt{'825'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			<img src="$imagesdir/gtalk.gif" alt="" border="0" style="vertical-align: middle;" />
			<a href="#" onclick="window.open('$scripturl?action=setgtalk;gtalkname=$user','','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'); return false">$profile_txt{'825'} ${$uid.$user}{'realname'}</a>
			</div>~;
	}
	if (${$uid.$user}{'skype'}) {
		$row_skype = qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
			<b>$profile_txt{'827'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			<img src="$imagesdir/skype.gif" alt="" border="0" style="vertical-align: middle;" />
			<a href="javascript:void(window.open('callto://${$uid.$user}{'skype'}','skype','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'))">$profile_txt{'827'} ${$uid.$user}{'realname'}</a>
			</div>~;
	}
	if (${$uid.$user}{'myspace'}) {
		$row_myspace = qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
			<b>$profile_txt{'570'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			<img src="$imagesdir/myspace.gif" alt="" border="0" style="vertical-align: middle;" />
			<a href="http://www.myspace.com/${$uid.$user}{'myspace'}" target="_blank">$profile_txt{'570'} ${$uid.$user}{'realname'}</a>
			</div>~;
	}
	if (${$uid.$user}{'facebook'}) {
		$row_facebook = qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
			<b>$profile_txt{'573'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			<img src="$imagesdir/facebook.gif" alt="" border="0" style="vertical-align: middle;" />
			<a href="http://www.facebook.com/~ . (${$uid.$user}{'facebook'} !~ /\D/ ? "profile.php?id=" : "") . qq~${$uid.$user}{'facebook'}" target="_blank"> ${$uid.$user}{'facebook'}</a>
			</div>~;
	}
	if (!${$uid.$user}{'hidemail'} || $iamadmin || !$allow_hide_email || $view) {
		my $rowEmail = '';
		if ($view) {
			if (!${$uid.$user}{'hidemail'}) {
				$rowEmail = $profile_txt{'showingemail'};
			} else {
				my ($admtitle, undef) = split(/\|/, $Group{'Administrator'}, 2);
				$rowEmail = qq~$profile_txt{'notshowingemail'} $admtitle$profile_txt{'notshowingemailend'}~;
			}
		} else {
			$rowEmail = &enc_eMail("$profile_txt{'889'} ${$uid.$user}{'realname'}",${$uid.$user}{'email'},'','');
		}

		$row_email = qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;">
			<b>$profile_txt{'69'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			$rowEmail
			</div>~;
	}
	if (${$uid.$user}{'weburl'} && ${$uid.$user}{'webtitle'}) {
		$row_website = qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;">
			<b>$profile_txt{'96'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			<a href="${$uid.$user}{'weburl'}" target="_blank">${$uid.$user}{'webtitle'}</a>
			</div>~;
	}
	if (${$uid.$user}{'signature'} && (!$hide_signat_for_guests || !$iamguest)) {
		# do some ubbc on the signature to display in the view profile area
		$message     = ${$uid.$user}{'signature'};
		$displayname = ${$uid.$user}{'realname'};

		if ($enable_ubbc) {
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC(1);
		}

		&ToChars($message);

		# Censor the signature.
		&LoadCensorList;
		$message = &Censor($message);

		$row_signature = qq~
	<tr>
		<td class="catbg" align="left">
			<img src="$imagesdir/profile.gif" alt="" border="0" style="vertical-align: middle;" />&nbsp;
			<span class="text1"><b>$profile_txt{'85'}</b></span>
		</td>
	</tr>
	<tr>
		<td align="left" class="windowbg2">
			<div style="float: left; width: 100%; padding-top: 8px; padding-bottom: 8px; overflow: auto;">
			$message
			</div>
		</td>
	</tr>~;

		if ($img_greybox) {
			$yyinlinestyle .= qq~<link href="$yyhtml_root/greybox/gb_styles.css" rel="stylesheet" type="text/css" />\n~;
			$yyjavascript .= qq~
var GB_ROOT_DIR = "$yyhtml_root/greybox/";
// -->
</script>
<script type="text/javascript" src="$yyhtml_root/AJS.js"></script>
<script type="text/javascript" src="$yyhtml_root/AJS_fx.js"></script>
<script type="text/javascript" src="$yyhtml_root/greybox/gb_scripts.js"></script>
<script type="text/javascript">
<!--~;
		}
	}

	# End empty field checking

	# Just maths below...
	my $post_count = ${$uid.$user}{'postcount'} || 0;

	my $string_regdate = &stringtotime(${$uid.$user}{'regdate'});
	my $string_curdate = $date;

	#if ($string_regdate < $forumstart) { $string_regdate = $forumstart }
	if ($string_curdate < $forumstart) { $string_curdate = $forumstart }

	my $member_for_days = int(($string_curdate - $string_regdate) / 86400);
	my $tmpmember_for_days;

	if ($member_for_days < 1) { $tmpmember_for_days = 1; }
	else { $tmpmember_for_days = $member_for_days; }
	my $post_per_day = sprintf("%.2f", ($post_count / $tmpmember_for_days));
	$member_for_days = &NumberFormat($member_for_days);
	$post_per_day = &NumberFormat($post_per_day);
	$post_count = &NumberFormat($post_count);

	# End statistics.
	if (${$uid.$user}{'usertext'}) {
		# Censor the usertext and wrap it
		&LoadCensorList;
		$showusertext = &WrapChars(&Censor(${$uid.$user}{'usertext'}),20);
	}

	if (!$view) {
		$yynavigation = qq~&rsaquo; $profile_txt{'92'}~;
		$showProfile .= qq~
<table border="0" cellpadding="8" cellspacing="0" class="tabtitle" align="center" width="100%">
	<tr>
		<td class="round_top_left" width="99%" align="left">
			<div class="text1" style="float: left; width: 100%;">~;
			if ($iamadmin || $iamgmod) {
				$showProfile .= qq~
			<img src="$imagesdir/profile.gif" alt="" border="0" style="vertical-align: middle;" />&nbsp; <b>$profile_txt{'35'}: $INFO{'username'}</b>~;
			} else {
				$showProfile .= qq~
			<img src="$imagesdir/profile.gif" alt="" border="0" style="vertical-align: middle;" />&nbsp; <b>$profile_txt{'68'}: ${$uid.$INFO{'username'}}{'realname'}</b>~;
			}
			$showProfile .= qq~
			</div>
		</td>
		<td class="round_top_right" width="1%">&nbsp;</td>
	</tr>
</table>
	~;
	}
	$showProfile .= qq~
<table border="0" cellpadding="8" cellspacing="1" class="bordercolor" align="center" width="100%">
	<tr>
		<td class="windowbg" valign="middle">
			$pic_row
			<div style="float: left; width: 60%; padding-top: 5px;  padding-bottom: 5px;">
			<span style="font-size: 18px;">${$uid.$user}{'realname'}</span><br />
			$col_title{$user}
			$row_addgrp<br />
			$memberstar{$user}
			~ . &userOnLineStatus($user) . qq~<br />
			<span class="small">$showusertext</span>
			<span class="small">$buddybutton</span>
			</div>
			<div style="float: right; width: 19%; text-align: right;">
			$modify
			</div>
		</td>
	</tr>
	<tr>
		<td class="windowbg2" align="left" valign="top">
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;">
			<b>$profile_txt{'21'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			<b>$post_count<br />$post_per_day</b> $profile_txt{'893'}
			</div>
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;">
			<b>$profile_txt{'233'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			$dr<br /><b>$member_for_days</b> $profile_txt{'894'}
			</div>
		</td>
	</tr>~;

	if ($row_gender || $row_age || $row_location) {
		$showProfile .= qq~
	<tr>
		<td class="windowbg2" align="left" valign="top">
			$row_gender
			$row_age
			$row_location
		</td>
	</tr>~;
	}

	if ($extendedprofiles) {
		require "$sourcedir/ExtendedProfiles.pl";
		$showProfile .= &ext_viewprofile($user);
	}

	$showProfile .= qq~
	<tr>
		<td class="catbg" align="left">
			<img src="$imagesdir/profile.gif" alt="" border="0" style="vertical-align: middle;" />&nbsp;
			<span class="text1"><b>$profile_txt{'819'}</b></span>
		</td>
	</tr>
	<tr>
		<td class="windowbg2" align="left">~;

	&CheckUserPM_Level($user);
	if (!$view && $user ne $username && ($PM_level == 1 || ($PM_level == 2 && $UserPM_Level{$user} > 1 && ($iamadmin || $iamgmod || $iammod)) || ($PM_level == 3 && $UserPM_Level{$user} == 3 && ($iamadmin || $iamgmod)))) {
		$showProfile .= qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;">
			<b>$profile_txt{'144'}: </b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">
			<a href="$scripturl?action=imsend;to=$useraccount{$user}">$profile_txt{'688'} ${$uid.$user}{'realname'}</a>
			</div>~;
	}

	$showProfile .= qq~
			$row_email
			$row_website
			$row_aim
			$row_msn
			$row_skype
			$row_yim
			$row_gtalk
			$row_myspace
			$row_facebook
			$row_icq
		</td>
	</tr>~;

	$userlastlogin = &timeformat(${$uid.$user}{'lastonline'});
	$userlastpost = &timeformat(${$uid.$user}{'lastpost'});
	$userlastim = &timeformat(${$uid.$user}{'lastim'});
	if ($userlastlogin eq "") { $userlastlogin = "$profile_txt{'470'}"; }
	if ($userlastpost  eq "") { $userlastpost  = "$profile_txt{'470'}"; }
	if ($userlastim    eq "") { $userlastim    = "$profile_txt{'470'}"; }
	my ($lastonline, $lastpost, $lastPM);
	## MF-B's code fix for lpd
	if (${$uid.$user}{'postcount'} > 0) {
		$userlastpost = &usersrecentposts(1);
	}
	####
	if (!$view) {
		$lastonline = qq~$profile_amv_txt{'9'}~;
		$lastpost = qq~$profile_amv_txt{'10'}~;
		$lastPM = qq~$profile_amv_txt{'11'}~;

	} else {
		$lastonline = qq~$profile_amv_txt{'mylastonline'}~;
		$lastpost = qq~$profile_amv_txt{'mylastpost'}~;
		$lastPM = qq~$profile_amv_txt{'mylastpm'}~;
	}

	$showProfile .= qq~
	$row_signature
	<tr>
		<td class="catbg" align="left">
			<img src="$imagesdir/profile.gif" alt="" border="0" style="vertical-align: middle;" />&nbsp;
			<span class="text1"><b>$profile_txt{'459'}</b></span>
		</td>
	</tr>
	<tr>
		<td class="windowbg2" align="left">
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;"><b>$lastonline: </b></div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">$userlastlogin</div>
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;"><b>$lastpost:</b></div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">$userlastpost</div>\n~;

	if ($PM_level == 1 || ($PM_level == 2 && $staff) || ($PM_level == 3 && ($iamadmin || $iamgmod))) {
		$showProfile .= qq~
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;"><b>$lastPM: </b></div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">$userlastim</div>~;
	}

	$showProfile .= qq~
		</td>
	</tr>~;

	if (($iamadmin || $iamgmod && $gmod_access2{'ipban3'}) && !$view && $user ne $username && ${$uid.$user}{'position'} ne 'Administrator') {
		$is_banned = &check_banlist("${$uid.$user}{'email'}","","$user");
		if ($is_banned =~/E/) { $ban_email_link = qq~<a href="$adminurl?action=ipban3;ban_email=${$uid.$user}{'email'};username=$useraccount{$user};unban=1"><span class="small">[$profile_txt{'904'}]</span></a>~; }
		else { $ban_email_link = qq~<a href="$adminurl?action=ipban3;ban_email=${$uid.$user}{'email'};username=$useraccount{$user}"><span class="small">[$profile_txt{'907'}]</span></a>~; }

		if ($is_banned =~/U/) { $ban_user_link = qq~<a href="$adminurl?action=ipban3;ban_memname=$useraccount{$user};username=$useraccount{$user};unban=1"><span class="small">[$profile_txt{'903'}]</span></a>~; }
		else { $ban_user_link = qq~<a href="$adminurl?action=ipban3;ban_memname=$useraccount{$user};username=$useraccount{$user}"><span class="small">[$profile_txt{'906'}]</span></a>~; }

		# Shows the banning stuff for IP's
		if (${$uid.$user}{'lastips'}) {
			($ip_one, $ip_two, $ip_three) = split (/\|/, ${$uid.$user}{'lastips'});

			if (&check_banlist("","$ip_one","")) { $banlink_one = qq~<a href="$adminurl?action=ipban3;ban=$ip_one;username=$useraccount{$user};unban=1"><span class="small">[$profile_txt{'905'}]</span></a>~; }
			else { $banlink_one = qq~<a href="$adminurl?action=ipban3;ban=$ip_one;username=$useraccount{$user}"><span class="small">[$profile_txt{'908'}]</span></a>~; }

			if (&check_banlist("","$ip_two","")) { $banlink_two = qq~<a href="$adminurl?action=ipban3;ban=$ip_two;username=$useraccount{$user};unban=1"><span class="small">[$profile_txt{'905'}]</span></a>~; }
			else { $banlink_two = qq~<a href="$adminurl?action=ipban3;ban=$ip_two;username=$useraccount{$user}"><span class="small">[$profile_txt{'908'}]</span></a>~; }

			if (&check_banlist("","$ip_three","")) { $banlink_three = qq~<a href="$adminurl?action=ipban3;ban=$ip_three;username=$useraccount{$user};unban=1"><span class="small">[$profile_txt{'905'}]</span></a>~; }
			else { $banlink_three = qq~<a href="$adminurl?action=ipban3;ban=$ip_three;username=$useraccount{$user}"><span class="small">[$profile_txt{'908'}]</span></a>~; }

			if ($ip_one) { $ip_ban_options = qq~$ip_one<br />$banlink_one <br />~; }
			if ($ip_two) { $ip_ban_options .= qq~$ip_two<br />$banlink_two <br />~; }
			if ($ip_three) { $ip_ban_options .= qq~$ip_three<br />$banlink_three <br />~; }
		}

		$showProfile .= qq~
	<tr>
		<td class="windowbg2" align="left">
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;"><b>$profile_txt{'902'}:</b></div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">$user<br />$ban_user_link</div>
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;"><b>$profile_txt{'69'}:</b></div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">${$uid.$user}{'email'}<br />$ban_email_link</div>
			<div style="float: left; clear: left; width: 30%; padding-top: 5px; padding-bottom: 5px;"><b>$profile_txt{'909'}:</b></div>
			<div style="float: left; width: 70%; padding-top: 5px; padding-bottom: 5px;">$ip_ban_options</div>
		</td>
	</tr>~;
	}

	if (${$uid.$user}{'postcount'} > 0 && $maxrecentdisplay > 0) {
		$showProfile .= qq~
	<tr>
		<td class="windowbg2" align="left">
			<form action="$scripturl?action=usersrecentposts;username=$useraccount{$user}" method="post">
			~ . ($view ? $inmes_txt{'viewrecentposts'} : $profile_txt{'460'}) . qq~ <select name="viewscount" size="1">~;

		my ($x,$y) = (int($maxrecentdisplay/5),0);
		if ($x) {
			for (my $i = 1; $i <= 5; $i++) {
				$y = $i * $x;
				$showProfile .= qq~
			<option value="$y">$y</option>~;
			}
		}
		$showProfile .= qq~
			<option value="$maxrecentdisplay">$maxrecentdisplay</option>~ if $maxrecentdisplay > $y;

		$showProfile .= qq~
			</select> ~ . ($view ? $inmes_txt{'viewrecentposts2'} : "$profile_txt{'461'} ${$uid.$user}{'realname'}") . qq~.
			<input type="submit" value="$profile_txt{'462'}" class="button" />
			</form>
		</td>
	</tr>~;
	}

	$showProfile .= qq~
</table>
~;

	$yytitle = "$profile_txt{'92'} ${$uid.$user}{'realname'}";
	if (!$view) {
		$yymain .= $showProfile;
		&template;
	}
}

sub usersrecentposts {
	if ($iamguest) { &fatal_error("members_only"); }
	if ($INFO{'username'} =~ /\//) { &fatal_error("no_user_slash"); }
	if ($INFO{'username'} =~ /\\/) { &fatal_error("no_user_backslash"); }
	if (!&checkfor_DBorFILE("$memberdir/$INFO{'username'}.vars")) { &fatal_error("no_profile_exists"); }
	&spam_protection if $action =~ /^(?:my)?usersrecentposts$/;

	my $curuser = $INFO{'username'};
	&LoadUser($curuser);

	my $display = $FORM{'viewscount'} ? $FORM{'viewscount'} : $_[0];
	if (!$display) { $display = 5; }
	elsif ($display =~ /\D/) { &fatal_error("only_numbers_allowed"); }
	if ($display > $maxrecentdisplay) { $display = $maxrecentdisplay; }

	my (%data, $numfound, %threadfound, %boardtxt, %recentthreadfound, $recentfound, $save_recent, $boardperms, $curcat, %boardcat, %catinfos, %catboards, $openmemgr, @membergroups, $tmpa, %openmemgr, $curboard, @threads, @boardinfo, $i, $c, @messages, $tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $mns, $counter, $board, $notify, $catid);

	&Recent_Load($curuser);
	my @recent = sort { ${$recent{$b}}[1] <=> ${$recent{$a}}[1] } grep { ${$recent{$_}}[1] > 0 } keys %recent;
	my $recentcount = keys %recent;
	my @data;
	$#data = $display - 1;
	@data = map(0, @data);

	if (!$mloaded) { require "$boardsdir/forum.master"; }
	foreach $catid (@categoryorder) {
		foreach (split(/\,/, $cat{$catid})) {
			$boardcat{$_} = $catid;
			@{$catinfos{$_}} = split(/\|/, $catinfo{$catid}, 3);
		}
	}
	
	foreach $cbdlist (keys %subboard) {
		foreach $cboard (split(/\|/, $subboard{$cbdlist})) {
			my $catid = ${$uid.$cboard}{'cat'};
			($catname, $catperms) = split(/\|/, $catinfo{$catid});
			$cataccess = &CatAccess($catperms);
			if (!$cataccess) { next; }
			$boardcat{$cboard} = $catid;
			@{$catinfos{$cboard}} = split(/\|/, $catinfo{$catid}, 3);
		}
	}


	recentcheck: foreach $thread (@recent) {
		&MessageTotals("load",$thread);
		if (${$thread}{'board'} eq '') {
			$save_recent = 1;
			delete $recent{$thread};
			$recentcount--;
			next recentcheck;
		}
		$curboard = ${$thread}{'board'};

		if (!$boardtxt{$curboard}) {
			($boardname{$curboard}, $boardperms, undef) = split(/\|/, $board{$curboard});

			if (!$iamadmin && (!&CatAccess(${$catinfos{$curboard}}[1]) || &AccessCheck($curboard,'',$boardperms) ne "granted")) { $recentcount--; next recentcheck; }

			@{$boardtxt{$curboard}} = &read_DBorFILE(1,'',$boardsdir,$curboard,'txt');

			if (!@{$boardtxt{$curboard}}) {
				$save_recent = 1;
				delete $recent{$thread};
				$recentcount--;
				next recentcheck;
			}
		} elsif ($numfound) {
			$recentfound += $recentthreadfound{$thread} if exists $recentthreadfound{$thread};
			last if $recentfound >= $display && $data[$#data] > ${$recent{$thread}}[1];
			next;
		}

		for ($i = 0; $i < @{$boardtxt{$curboard}}; $i++) {
			($tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate) = split(/\|/, ${$boardtxt{$curboard}}[$i]);

			if (($display == 1 && $thread == $tnum) || ($display > 1 && exists $recent{$tnum})) {
				if ($tstate =~ /h/ && !$iamadmin && !$iamgmod) {
					$recentcount--;
				} else {
					@messages = &read_DBorFILE(1,'',$datadir,$tnum,'txt');

					my $usercheck = 0;

					for ($c = $#messages; $c >= 0 ; $c--) {
						($msub, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $message, $mns) = split(/\|/, $messages[$c]);

						if ($curuser eq $musername) {
							my @i = (@data, $mdate);
							@data = sort { $b <=> $a } @i;
							if (pop(@data) < $mdate) {
								chomp $mns;
								if (&checkfor_DBorFILE("$memberdir/$tusername.vars")) {
									&LoadUser($tusername);
									$tname = ${$uid.$tusername}{'realname'};
								}
								$data{$mdate} = [$curboard, $tnum, $c, $tname, $msub, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $message, $mns, $tstate];
								if (!$usercheck) {
									$numfound++;
									$threadfound{$tnum} = 1;
								}
								if (exists $recent{$tnum}) {
									$recentthreadfound{$tnum}++;
									$recentfound++ if $thread == $tnum;
								}
								if (${$recent{$tnum}}[1] < $mdate) {
									$save_recent = 1;
									${$recent{$tnum}}[1] = $mdate;
								}
							}
							$usercheck = 1;
						}
					}
					if (!$usercheck) {
						$save_recent = 1;
						delete $recent{$tnum};
						$recentcount--;
					}
				}
			}
		}
	}

	if ($recentfound < $display && $numfound < $recentcount) {
		categorycheck: foreach $catid (@categoryorder) {
			if (!&CatAccess((split(/\|/, $catinfo{$catid}, 3))[1])) { next categorycheck; }

			&recursive_bds(split(/\,/, $cat{$catid}));
			sub recursive_bds {
				boardcheck: foreach $curboard (@_) {
					if (!$boardtxt{$curboard}) {
						($boardname{$curboard}, $boardperms, undef) = split(/\|/, $board{$curboard});

						if (!$iamadmin && &AccessCheck($curboard,'',$boardperms) ne "granted") { next boardcheck; }

						next boardcheck if !(@{$boardtxt{$curboard}} = &read_DBorFILE(1,'',$boardsdir,$curboard,'txt'));
					}

					for ($i = 0; $i < @{$boardtxt{$curboard}}; $i++) {
						($tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate) = split(/\|/, ${$boardtxt{$curboard}}[$i]);

						if (exists($recent{$tnum}) && !exists $threadfound{$tnum}) {
							unless ($tstate =~ /h/ && !$iamadmin && !$iamgmod) {
								@messages = &read_DBorFILE(0,'',$datadir,$tnum,'txt');

								my $usercheck = 0;

								for ($c = $#messages; $c >= 0 ; $c--) {
									($msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $message, $mns) = split(/\|/, $messages[$c]);

									if ($curuser eq $musername) {
										my @i = @data;
										push(@i, $mdate);
										@data = sort { $b <=> $a } @i;
										if (pop(@data) != $mdate) {
											chomp $mns;
											if (&checkfor_DBorFILE("$memberdir/$tusername.vars")) {
												&LoadUser($tusername);
												$tname = ${$uid.$tusername}{'realname'};
											}
											$data{$mdate} = [$curboard, $tnum, $c, $tname, $msub, $mname, $memail, $mdate, $musername, $micon, $mattach, $mip, $message, $mns, $tstate];
											if (${$recent{$tnum}}[1] < $mdate) {
												$save_recent = 1;
												${$recent{$tnum}}[1] = $mdate;
											}
										}
										$usercheck = 1;
									}
								}

								if (!$usercheck) {
									$save_recent = 1;
									delete $recent{$tnum};
								}
							}
						}
					}
				}
				
				if($subboard{$curboard}) { &recursive_bds(split(/\|/,$subboard{$curboard})); }
			} # end recursive loop
		}
	}

	undef %boardtxt;

	&Recent_Save($curuser) if $save_recent;

	if ($display == 1) {
		return if !$data[0];
		($board, $tnum, $c, $tname, $msub, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $message, $mns, $tstate) = @{$data{$data[0]}};
		&ToChars($msub);
		($msub, undef) = &Split_Splice_Move($msub,0);
		return (&timeformat($mdate) . qq~<br />$profile_txt{'view'} &rsaquo; <a href="$scripturl?num=$tnum/$c#$c">$msub</a>~);
	}

	&LoadCensorList;
	
	my $icanbypass = &checkUserLockBypass;
	
	if(!$view) {
		$round_left = "round_top_left";
		$round_right = "round_top_right";
	}

	for ($i = 0; $i < @data; $i++) {
		next if !$data[$i];

		($board, $tnum, $c, $tname, $msub, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $message, $mns, $tstate) = @{$data{$data[$i]}};
		($msub, undef) = &Split_Splice_Move($msub,0);
		&wrap;
		$displayname = $mname;
		($message, undef) = &Split_Splice_Move($message,$tnum);
		if ($enable_ubbc) {
			$ns = $mns;
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC;
		}
		&wrap2;
		&ToChars($msub);
		&ToChars($message);
		$msub = &Censor($msub);
		$message = &Censor($message);
		&ToChars(${$catinfos{$board}}[0]);
		&ToChars($boardname{$board});

		$mdate = &timeformat($mdate);

		$counter++;
		
		# generate a sub board tree
		my $boardtree = '';
		my $parentboard = $board;
		while($parentboard) {
			my ($pboardname, undef, undef) = split(/\|/, $board{"$parentboard"});
			&ToChars($pboardname);
			if(${$uid.$parentboard}{'canpost'}) {
				$pboardname = qq~<a href="$scripturl?board=$parentboard"><u>$pboardname</u></a>~;
			} else {
				$pboardname = qq~<a href="$scripturl?boardselect=$parentboard&subboards=1"><u>$pboardname</u></a>~;
			}
			$boardtree = qq~ / $pboardname$boardtree~;
			$parentboard = ${$uid.$parentboard}{'parent'};
		}

		$showProfile .= qq~
<table border="0" width="100%" cellspacing="0" class="tabtitle">
	<tr>
		<td align="center" width="5%" class="$round_left">$counter</td>
		<td align="left" width="95%" class="$round_right">&nbsp;<a href="$scripturl?catselect=$boardcat{$board}"><u>${$catinfos{$board}}[0]</u></a>$boardtree / <a href="$scripturl?num=$tnum/$c#$c"><u>$msub</u></a><br />
		&nbsp;<span class="small">$profile_txt{'30'}: $mdate</span>&nbsp;</td>
	</tr>
</table>
<table border="0" width="100%" cellspacing="1" cellpadding="0" class="bordercolor" style="table-layout: fixed;">
	<tr>
		<td>
			<table cellspacing="0" cellpadding="0" border="0" width="100%" class="titlebg">
				<tr>
					<td align="left" style="padding-left: 5px">$maintxt{'109'} $tname | $maintxt{'197'} ${$uid.$curuser}{'realname'}</td>
					<td align="right">&nbsp;~;

		if ($tstate != 1) {
			if (${$uid.$username}{'thread_notifications'} =~ /\b$tnum\b/) {
				$notify = qq~$menusep<a href="$scripturl?action=notify3;num=$tnum/$c;oldnotify=1">$img{'del_notify'}</a>~;
			} else {
				$notify = qq~$menusep<a href="$scripturl?action=notify2;num=$tnum/$c;oldnotify=1">$img{'add_notify'}</a>~;
			}
			$showProfile .= qq~<a href="$scripturl?board=$board;action=post;num=$tnum/$c#$c;title=PostReply">$img{'reply'}</a>$menusep<a href="$scripturl?board=$board;action=post;num=$tnum;quote=$c;title=PostReply">$img{'recentquote'}</a>$notify~;
		}

		if ($staff && ($icanbypass || $tstate !~ /l/i) && (!$iammod || &is_moderator($username,$board))) {
				&LoadLanguage('Display');
				$showProfile .= qq~$menusep<a href="$scripturl?action=multidel;recent=1;thread=$tnum;del$c=$c" onclick="return confirm('~ . (($icanbypass && $tstate =~ /l/i) ? qq~$display_txt{'modifyinlocked'}\\n\\n~ : '') . qq~$display_txt{'rempost'}')">$img{'delete'}</a>~;
		}

		$showProfile .= qq~ &nbsp;
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="left" height="80" class="windowbg2" valign="top" style="padding:5px"><div style="float: left; width: 99%; overflow: auto;">$message</div></td>
	</tr>
</table>~;
		if(!$view) { $showProfile .= "<br />"; }
	}

	if (!$counter) { 
		$showProfile .= qq~<span class="text1"><b>$profile_txt{'755'}</b></span>~;
	} elsif (!$view) {
		$showProfile .= qq~<p align=left><a href="$scripturl?action=viewprofile;username=$useraccount{$curuser}" rel="nofollow"><b>$profile_txt{'92'} ${$uid.$curuser}{'realname'}</b></a></p>~;
	}

	if ($img_greybox) {
		$yyinlinestyle .= qq~<link href="$yyhtml_root/greybox/gb_styles.css" rel="stylesheet" type="text/css" />\n~;
		$yyjavascript .= qq~
var GB_ROOT_DIR = "$yyhtml_root/greybox/";
// -->
</script>
<script type="text/javascript" src="$yyhtml_root/AJS.js"></script>
<script type="text/javascript" src="$yyhtml_root/AJS_fx.js"></script>
<script type="text/javascript" src="$yyhtml_root/greybox/gb_scripts.js"></script>
<script type="text/javascript">
<!--~;
	}

	$yytitle = "$profile_txt{'458'} ${$uid.$curuser}{'realname'}";
	if (!$view) {
		$yynavigation = qq~&rsaquo; $maintxt{'213'}~;
		$yymain .= $showProfile;
		&template;
	}
}

sub DrawGroups {
	my ($availgroups,$position,$show_additional) = @_;
	my (%groups, $groupsel, $name, $additional);
	map { $groups{$_} = 1; } split(/,/, $availgroups);

	foreach my $key (@nopostorder) {
		($name, undef, undef, undef, undef, undef, undef, undef, undef, undef, $additional) = split(/\|/, $NoPost{$key});
		next if (!$show_additional && !$additional) || $position eq $key;

		$groupsel .= qq~<option value="$key"~ . ($groups{$key} ? ' selected="selected"' : '') . qq~>$name</option>~;
		$selsize++;
	}

	($groupsel,($selsize > 6 ? 6 : $selsize));
}

1;