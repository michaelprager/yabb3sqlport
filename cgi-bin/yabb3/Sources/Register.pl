###############################################################################
# Register.pl                                                                 #
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

$registerplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

require "$sourcedir/Mailer.pl";
&LoadLanguage('Register');

if ($^O =~ /Win/) {
	my $regstyle = qq~ style="text-transform: lowercase"~;
} else {
	my $regstyle = '';
}

sub Register {
	if ($regtype == 0 && $iamguest) { &fatal_error("registration_disabled"); }
	my ($tmpregname, $tmprealname, $tmpregemail, $tmpregpasswrd1, $tmpregpasswrd2, $hidechecked, @birthdate);
	$yytitle = $register_txt{'97'};
	$yynavigation = qq~&rsaquo; $register_txt{'97'}~;
	if ($FORM{'reglanguage'}) {
		$language = $FORM{'reglanguage'};
		#&LoadLanguage('Main');
		#&LoadLanguage('Menu');
		&LoadLanguage('Register');
	}
	if ($FORM{'regusername'}) { $tmpregname     = $FORM{'regusername'}; }
	if ($FORM{'regrealname'}) { $tmprealname    = $FORM{'regrealname'}; }
	if ($FORM{'email'})       { $tmpregemail    = $FORM{'email'}; }
	if ($FORM{'hideemail'} || !exists $FORM{'hideemail'}) { $hidechecked = qq~ checked="checked"~; }
	if ($FORM{'passwrd1'})    { $tmpregpasswrd1 = $FORM{'passwrd1'}; }
	if ($FORM{'passwrd2'})    { $tmpregpasswrd2 = $FORM{'passwrd2'}; }
	if ($FORM{'reason'})      { $reason         = $FORM{'reason'}; }
	if ($FORM{'birth_day'})   { $birthdate[0]   = $FORM{'birth_day'}; }
	if ($FORM{'birth_month'}) { $birthdate[1]   = $FORM{'birth_month'}; }
	if ($FORM{'birth_year'})  { $birthdate[2]   = $FORM{'birth_year'}; }

	## moved langopt setup to subs.pl
	if (!$langopt) { &guestLangSel; }

	if (!$iamguest) { &fatal_error("no_registration_logged_in"); }
	if (&checkfor_DBorFILE("$vardir/email_domain_filter.txt")) { require "$vardir/email_domain_filter.txt"; }
	if ($adomains) {
		@domains = split (/\,/, $adomains);
		$aedomains = qq~<table border="0" width="100%" cellspacing="0" cellpadding="0"><tr><td><input type="text" maxlength="100" name="email" id="email" value="$tmpregemail" size="15" /></td><td><select name="domain" id="domain">~;
		foreach (@domains) { $aedomains .= ($_ =~ m/\@/) ? qq~<option value="$_">$_</option>~ : qq~<option value="\@$_">&#64;$_</option>~; }
		$aedomains .= qq~</select></td></tr></table>~;

	} else {
		$aedomains .= qq~<input type="text" maxlength="100" onchange="checkAvail('$scripturl',this.value,'email')" name="email" id="email" value="$tmpregemail" size="45" />~;
	}

	$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/ajax.js"></script>
<form action="$scripturl?action=register2" method="post" name="creator" onsubmit="return CheckRegFields();">
<table border="0" width="100%" cellpadding="4" cellspacing="0" class="tabtitle">
	<tr>
		<td class="round_top_left" width="99%" align="left">
			<img src="$imagesdir/register.gif" alt="$register_txt{'97'}" title="$register_txt{'97'}" border="0" />
			<span class="text1"><b>$register_txt{'97'}</b> $register_txt{'517'}</span>
		</td>
		<td class="round_top_right" width="1%">&nbsp;</td>
	</tr>
</table>
<table border="0" width="100%" cellpadding="4" cellspacing="1" class="bordercolor">
	<colgroup>
		<col width="45%" />
		<col width="55%" />
	</colgroup>
	<tr>
		<td class="windowbg" colspan="2" align="center">
			$register_txt{'97a'}
		</td>
	</tr>~;

	if ($morelang > 1) {
		$yymain .= qq~
	<tr>
		<td class="windowbg" align="right" valign="top">
			<label for="reglanguage"><b>$register_txt{'101'}</b></label>
		</td>
		<td class="windowbg2" align="left" valign="top">
			<select name="reglanguage" id="reglanguage" onchange="document.creator.action='$scripturl?action=register'; document.creator.submit();">
			$langopt
			</select>
			<noscript><input type="submit" value="$maintxt{'32'}" class="button" /></noscript>
		</td>
	</tr>~;
	}

	$yymain .= qq~
	<tr>
		<td class="windowbg" align="right" valign="top">
			<label for="regusername"><b>$register_txt{'98'}:</b><br />
			<span class="small">$register_txt{'520'}</span></label>
		</td>
		<td class="windowbg2" align="left" valign="top">
			<input type="text" name="regusername" id="regusername" onchange="checkAvail('$scripturl',this.value,'user','$name_cannot_be_userid')" size="30" value="$tmpregname" maxlength="18"$regstyle /> *
			<div id="useravailability"></div>
			<input type="hidden" name="language" id="language" value="$language" />
		</td>
	</tr>
	<tr>
		<td class="windowbg" align="right" valign="top">
			<label for="regrealname"><b>$register_txt{'98a'}:</b>~;
	if ($name_cannot_be_userid) {
		$yymain .= qq~
			<br /><span class="small">$register_txt{'521'}</span>~;
	} else {
		$yymain .= qq~
			<br /><span class="small">$register_txt{'522'}</span>~;
	}
	$yymain .= qq~</label>
		</td>
		<td class="windowbg2" align="left" valign="top">
			<input type="text" name="regrealname" id="regrealname" onchange="checkAvail('$scripturl',this.value,'display','$name_cannot_be_userid')" size="30" value="$tmprealname" maxlength="30" /> *
			<div id="displayavailability"></div>
		</td>
	</tr>
	<tr>
		<td class="windowbg" align="right" valign="top"><label for="email"><b>$register_txt{'69'}:</b>
			<br /><span class="small">$register_txt{'679'}</span></label>
		</td>
		<td class="windowbg2" align="left" valign="top">
			$aedomains *
			<div id="emailavailability"></div>
	~;
	if ($allow_hide_email == 1) {
		$yymain .= qq~
			<br /><input type="checkbox" name="hideemail" id="hideemail" value="1"$hidechecked /> <label for="hideemail">$register_txt{'721'}</label>
		~;
	} 
	$yymain .= qq~
		</td>
	</tr>
	<tr>
		<td class="windowbg" align="right" valign="top">
			<label for="regusername"><b>OpenID:</b><br />
			</label>
		</td>
		<td class="windowbg2" align="left" valign="top">
			<select name="openid" id="openid" size="3" width="150"/></select>
			<a class="rpxnow" onclick="return false;" href="https://yabb.rpxnow.com/openid/v2/signin?token_url=http%3A%2F%2Fwww.dev.yabbworld.com%2Fcgi-bin%2Fforum%2FYaBB.pl%3Faction%3Dopenidvalidate">
				<img src="$imagesdir/openidsmall.jpg" border="0" /> Verify An Id
			</a>
		</td>
	</tr>
	~;

	if ($birthday_on_reg) {
		&timetostring($date);
		if ($timeselected =~ /[145]/) {
			$yymain .= qq~
	<tr>
		<td class="windowbg" align="right" valign="top">
			<label for="birth_month"><b>$register_txt{'birthday'}:</b></label>
		</td>
		<td class="windowbg2" align="left" valign="top"><input type="text" name="birth_month" id="birth_month" size="2" value="$birthdate[1]" maxlength="2" onkeypress="jumpatnext('document.creator.birth_month','document.creator.birth_day',2)" /> <input type="text" name="birth_day" id="birth_day" size="2" value="$birthdate[0]" maxlength="2" onkeypress="jumpatnext('document.creator.birth_day','document.creator.birth_year',2)" /> <input type="text" name="birth_year" id="birth_year" size="4" value="$birthdate[2]" maxlength="4" />~ . ($birthday_on_reg == 2 ? ' *' : '') . qq~ <span class="small">$register_txt{'birthday_a'}</span>~;

		} else {
			$yymain .= qq~
	<tr>
		<td class="windowbg" align="right" valign="top">
			<label for="birth_day"><b>$register_txt{'birthday'}:</b></label>
		</td>
		<td class="windowbg2" align="left" valign="top"><input type="text" name="birth_day" id="birth_day" size="2" value="$birthdate[0]" maxlength="2" onkeypress="jumpatnext('document.creator.birth_day','document.creator.birth_month',2)" /> <input type="text" name="birth_month" id="birth_month" size="2" value="$birthdate[1]" maxlength="2" onkeypress="jumpatnext('document.creator.birth_month','document.creator.birth_year',2)" /> <input type="text" name="birth_year" id="birth_year" size="4" value="$birthdate[2]" maxlength="4" />~ . ($birthday_on_reg == 2 ? ' *' : '') . qq~ <span class="small">$register_txt{'birthday_b'}</span>~;
		}

		$yymain .= qq~
		</td>
	</tr>~;
	}

	if ($gender_on_reg) {
		if ($gender_on_reg == 1) {
			$gender_req = qq~<label for="gender"><b>$register_txt{'gender'}: </b></label>~;
		}
		else {
			$gender_req = qq~* <label for="gender"><b>$register_txt{'gender'}: </b></label>~;
		}
		$yymain .= qq~
		<tr>
			<td class="windowbg" align="right" valign="top">
				$gender_req
			</td>
			<td class="windowbg2" align="left" valign="top">
				<select name="gender" id="gender" size="1">
					<option value=""></option>
					<option value="Male">$register_txt{'gender_male'}</option>
					<option value="Female">$register_txt{'gender_female'}</option>
				</select>
			</td>
		</tr>
		~;
	}
	unless ($emailpassword) {
		$yymain .= qq~
	<tr>
		<td class="windowbg" align="right" valign="top">
			<label for="passwrd1"><b>$register_txt{'81'}:</b>
			<br /><span class="small">Password still required with a registered OpenID.</span></label>
		</td>
		<td class="windowbg2" align="left" valign="top">
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
			<div style="float:left;"><input type="password" maxlength="30" name="passwrd1" id="passwrd1" value="$tmpregpasswrd1" size="30" onkeypress="capsLock(event,'cappasswrd1')" onkeyup="runPassword(this.value);" /> *&nbsp;</div>
			<div style="float:left; width: 150px; height: 20px; text-align:left;">
				<div id="password-strength-meter" style="background: transparent url($imagesdir/empty_bar.gif) repeat-x center left; height: 4px"></div>
				<div class="pstrength-bar" id="passwrd1_bar" style="border: 1px solid #FFFFFF; height: 4px"></div>
				<div class="pstrength-info" id="passwrd1_text">&nbsp;</div>
			</div>
			<div style="clear:left; color: red; font-weight: bold; display: none" id="cappasswrd1">$register_txt{'capslock'}</div>
			<div style="clear:left; color: red; font-weight: bold; display: none" id="cappasswrd1_char">$register_txt{'wrong_char'}: <span id="cappasswrd1_character">&nbsp;</span></div>
		</td>
	</tr>
	<tr>
		<td class="windowbg" align="right" valign="top">
			<label for="passwrd2"><b>$register_txt{'82'}:</b></label>
		</td>
		<td class="windowbg2" align="left" valign="top">
			<input type="password" maxlength="30" name="passwrd2" id="passwrd2" value="$tmpregpasswrd2" size="30" onkeypress="capsLock(event,'cappasswrd2')" /> *
			<div style="color: red; font-weight: bold; display: none" id="cappasswrd2">$register_txt{'capslock'}</div>
			<div style="color: red; font-weight: bold; display: none" id="cappasswrd2_char">$register_txt{'wrong_char'}: <span id="cappasswrd2_character">&nbsp;</span></div>
		</td>
	</tr>~;
	}

	if ($addmemgroup_enabled == 1 || $addmemgroup_enabled == 3) {
		my ($title, $additional, $addmemgroup, $selsize);
		foreach (@nopostorder) {
			($title, undef, undef, undef, undef, undef, undef, undef, undef, undef, $additional) = split(/\|/, $NoPost{$_});
			if ($additional) {
				$addmemgroup .= qq~<option value="$_">$title</option>~;
				$selsize++;
			}
		}
		$selsize = $selsize > 6 ? 6 : $selsize;
		my $additional_explain = $addmemgroup_enabled == 1 ? $register_txt{'766'} : $register_txt{'767'};
		$additional_explain .= $register_txt{'767a'} if $selsize > 1;

		$yymain .= qq~
	<tr>
		<td class="windowbg" align="right" valign="top">
			<label for="joinmemgroup"><b>$register_txt{'765'}:</b>
			<br /><span class="small">$additional_explain</span></label>
		</td>
		<td class="windowbg2" align="left" valign="top">
			<select name="joinmemgroup" id="joinmemgroup" size="$selsize" multiple="multiple">
			$addmemgroup
			</select>
		</td>
	</tr>~ if $addmemgroup;
	}

	if ($regtype == 1) {
		$yymain .= qq~
	<tr>
		<td class="windowbg" align="right" valign="top">
			<label for="reason"><b>$prereg_txt{'regreason'}:</b><br />
			<span class="small">$prereg_txt{'reason_exp'}</span></label><br /><br />
		</td>
		<td class="windowbg2" align="left" valign="top">
			<textarea cols="60" rows="7" name="reason" id="reason">$reason</textarea> *<br />
			<span class="small">$prereg_txt{'16'} <input value="$RegReasonSymbols" size="~ . length($RegReasonSymbols) . qq~" name="msgCL" class="windowbg" style="border: 0px; padding: 1px; font-size: 11px;" readonly="readonly" /></span>
			<script type="text/javascript" language="JavaScript">
			<!--
			var supportsKeys = false;
			function tick() {
				calcCharLeft(document.forms[0]);
				if (!supportsKeys) { timerID = setTimeout("tick()",$RegReasonSymbols); }
			}
			function calcCharLeft(sig) {
				clipped = false;
				maxLength = $RegReasonSymbols;
				if (document.creator.reason.value.length > maxLength) {
					document.creator.reason.value = document.creator.reason.value.substring(0,maxLength);
					charleft = 0;
					clipped = true;
				} else {
					charleft = maxLength - document.creator.reason.value.length;
				}
				document.creator.msgCL.value = charleft;
				return clipped;
			}
			tick();
			//-->
			</script>
		</td>
	</tr>~;
	}

	if ($extendedprofiles) {
		require "$sourcedir/ExtendedProfiles.pl";
		my $reg_ext_prof = &ext_register;
		$reg_ext_prof =~ s/align="left" valign="top"/align="right" valign="top"/g;
		$reg_ext_prof =~ s/<\/td><td align="left">/<\/td><td class="windowbg2" align="left">/g;
		$yymain .= $reg_ext_prof;
	}

	if ($regcheck) {
		require "$sourcedir/Decoder.pl";
		&validation_code;

		$yymain .= qq~
	<tr>
		<td class="windowbg" align="right" valign="top">
			<label for="verification"><b>$floodtxt{'1'}:</b><br />
			<span class="small">$floodtxt{'casewarning'}</span></label>
		</td>
		<td class="windowbg2" align="left" valign="middle">
			$showcheck
		</td>
	</tr>
	<tr>
		<td class="windowbg" align="right" valign="top">
			<label for="verification"><b>$floodtxt{'3'}:</b></label>
		</td>
		<td class="windowbg2" align="left" valign="top">
			<input type="text" maxlength="30" name="verification" id="verification" size="30" /> *
		</td>
	</tr>~;
	}

	if ($RegAgree) {
		my @agreement;
		if ($language) {
			@agreement = &read_DBorFILE(0,'',"$langdir/$language",'agreement','txt');
		} else {
			@agreement = &read_DBorFILE(0,'',"$langdir/$lang",'agreement','txt');
		}
		my $fullagree = join("", @agreement);
		$fullagree =~ s/\n/<br \/>/g;
		$yymain .= qq~
	<tr>
		<td colspan="2" class="titlebg">
			<img src="$imagesdir/xx.gif" alt="$register_txt{'764a'}" title="$register_txt{'764a'}" border="0" /> <b>$register_txt{'764a'}</b>
		</td>
	</tr>
	<tr>
		<td colspan="2" class="windowbg">
			<label for="regagree"><span style="float: left; padding: 5px;">$fullagree</span></label>
		</td>
	</tr>
	<tr>
		<td colspan="2" class="windowbg2" align="center">
			<label for="regagree"><b>$register_txt{'585'}</b></label> <input type="radio" name="regagree" id="regagree" value="yes" /> * &nbsp;&nbsp; <label for="regnoagree"><b>$register_txt{'586'}</b></label> <input type="radio" name="regagree" id="regnoagree" value="no" />
		</td>
	</tr>~;
	}
	$yymain .= qq~
	<tr>
		<td colspan="2" align="center" class="titlebg">
			<br />
			<label for="submitbutton">$register_txt{'95'}</label><br />
			<br />
		</td>
	</tr>
</table>
<table border="0" width="100%" cellpadding="4" cellspacing="0" class="tabtitle">
	<tr>
		<td colspan="2" class="round_bottom_left" width="99%" align="center">
			<input type="submit" id="submitbutton" value="$register_txt{'97'}" class="button" />
		</td>
		<td class="round_bottom_right" width="1%">&nbsp;</td>
	</tr>
</table>
</form>

<script type="text/javascript" language="JavaScript">
<!--
	document.creator.regusername.focus();

	function CheckRegFields() {
		if (document.creator.regusername.value == '') {
			alert("$register_txt{'error_username'}");
			document.creator.regusername.focus();
			return false;
		}
		if (document.creator.regusername.value == document.creator.passwrd1.value || document.creator.regrealname.value == document.creator.passwrd1.value) {
			alert("$register_txt{'error_usernameispass'}");
			document.creator.regusername.focus();
			return false;
		}
		if (document.creator.regrealname.value == '') {
			alert("$register_txt{'error_realname'}");
			document.creator.regrealname.focus();
			return false;
		}~ .

		($name_cannot_be_userid ? qq~
		if (document.creator.regusername.value == document.creator.regrealname.value) {
			alert("$register_txt{'error_name_cannot_be_userid'}");
			document.creator.regrealname.focus();
			return false;
		}~ : '')

		. qq~
		if (document.creator.email.value == '') {
			alert("$register_txt{'error_email'}");
			document.creator.email.focus();
			return false;
		}~ .

		($birthday_on_reg ? qq~
		if (~ . ($birthday_on_reg == 1 ? 'document.creator.birth_day.value.length && ' : '') . qq~(document.creator.birth_day.value.length < 2 || document.creator.birth_day.value < 1 || document.creator.birth_day.value > 31 || /\\D/.test(document.creator.birth_day.value))) {
			alert("$register_txt{'error_birth_day'}");
			document.creator.birth_day.focus();
			return false;
		}
		if (~ . ($birthday_on_reg == 1 ? 'document.creator.birth_month.value.length && ' : '') . qq~(document.creator.birth_month.value.length < 2 || document.creator.birth_month.value < 1 || document.creator.birth_month.value > 12 || /\\D/.test(document.creator.birth_month.value))) {
			alert("$register_txt{'error_birth_month'}");
			document.creator.birth_month.focus();
			return false;
		}
		if (~ . ($birthday_on_reg == 1 ? 'document.creator.birth_year.value.length && ' : '') . qq~(document.creator.birth_year.value.length < 4 || /\\D/.test(document.creator.birth_year.value))) {
			alert("$register_txt{'error_birth_year'}");
			document.creator.birth_year.focus();
			return false;
		}
		if (~ . ($birthday_on_reg == 1 ? 'document.creator.birth_year.value.length && ' : '') . qq~(document.creator.birth_year.value < ($year - 120) || document.creator.birth_year.value > $year)) {
			alert("$register_txt{'error_birth_year_real'}");
			document.creator.birth_year.focus();
			return false;
		}~ : '')

		. qq~
		if ($emailpassword == 0) {
			if (document.creator.passwrd1.value == '' || document.creator.passwrd2.value == '') {
				alert("$register_txt{'error_pass1'}");
				document.creator.passwrd1.focus();
				return false;
			}
			if (document.creator.passwrd1.value != document.creator.passwrd2.value) {
				alert("$register_txt{'error_pass2'}");
				document.creator.passwrd1.focus();
				return false;
			}
		}
		if ($regcheck > 0 && document.creator.verification.value == '') {
			alert("$register_txt{'error_verification'}");
			document.creator.verification.focus();
			return false;
		}
		if ($regtype == 1 && document.creator.reason.value == '') {
			alert("$register_txt{'error_reason'}");
			document.creator.reason.focus();
			return false;
		}
		if ($RegAgree > 0 && document.creator.regagree[0].checked != true) {
			alert("$register_txt{'error_agree'}");
			return false;
		}

		if ($gender_on_reg > 1 && !document.creator.gender.value) { 
			alert("$register_txt{'error_gender'}");
			document.creator.gender.focus();
			return false
		}
		return true;
	}

	function jumpatnext(from,to,length) {
		window.setTimeout('if (' + from + '.value.length == ' + length + ') ' + to + '.focus();', 1);
	}
//-->
</script>
<script type="text/javascript">
  var rpxJsHost = (("https:" == document.location.protocol) ? "https://" : "http://static.");
  document.write(unescape("%3Cscript src='" + rpxJsHost +
"rpxnow.com/js/lib/rpx.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
  RPXNOW.overlay = true;
  RPXNOW.language_preference = 'en';
</script>
	~;
	&template;
}

sub Register2 { 
	if (!$regtype) { &fatal_error("registration_disabled"); } 
	if ($RegAgree && $FORM{'regagree'} ne 'yes') { &fatal_error('no_regagree'); }
	my %member;
	while (($key, $value) = each(%FORM)) {
		$value =~ s~\A\s+~~;
		$value =~ s~\s+\Z~~;
		unless ($key eq "reason") {$value =~ s~[\n\r]~~g;}
		$member{$key} = $value;
	}
	if ($member{'domain'}) { $member{'email'} .= $member{'domain'}; }
	$member{'regusername'} =~ s/\s/_/g;
	$member{'regrealname'} =~ s~\t+~\ ~g;

	# Make sure users can't register with banned details
	&email_domain_check($member{'email'});
	&banning($member{'regusername'}, $member{'email'});

	# check if there is a system hash named like this by checking existence through size
	&fatal_error("system_prohibited_id", "($member{'regusername'})") if keys(%{ $member{'regusername'} }) > 0;
	&fatal_error("id_to_long","($member{'regusername'})") if length($member{'regusername'}) > 25;
	&fatal_error("email_to_long","($member{'email'})") if length($member{'email'}) > 100;
	&fatal_error("no_username","($member{'regusername'})") if $member{'regusername'} eq '';
	&fatal_error("id_alfa_only","($member{'regusername'})") if $member{'regusername'} eq '_';
	&fatal_error("id_reserved","$member{'regusername'}") if $member{'regusername'} =~ /guest/i;
	&fatal_error("invalid_character","$register_txt{'35'} $register_txt{'241re'}") if $member{'regusername'} =~ /[^\w\+\-\.\@]/;
	&fatal_error("no_email","($member{'regusername'})") if $member{'email'} eq "";
	&fatal_error("id_taken","($member{'regusername'})") if &checkfor_DBorFILE("$memberdir/$member{'regusername'}.vars");
	&fatal_error("password_is_userid") if $member{'regusername'} eq $member{'passwrd1'};
	&fatal_error("no_reg_reason") if $member{'reason'} eq "" && $regtype == 1;

	&FromChars($member{'regrealname'});
	$convertstr = $member{'regrealname'};
	$convertcut = 30;
	&CountChars;
	$member{'regrealname'} = $convertstr;
	&fatal_error("realname_to_long","($member{'regrealname'} => $convertstr)") if $cliped;
	&fatal_error('invalid_character', "$register_txt{'38'} $register_txt{'241re'}") if $member{'regrealname'} =~ /[^ \w\x80-\xFF\[\]\(\)#\%\+,\-\|\.:=\?\@\^]/;
 	&fatal_error('TODO: SQLPORT: check if this conversion is valid'); # TODO: SQL Port
	&ToHTML($member{'name'});
	&ToChars($member{'name'});

	if ($name_cannot_be_userid && lc $member{'regusername'} eq lc $member{'regrealname'}) { &fatal_error('name_is_userid'); }

	if (lc $member{'regusername'} eq lc &MemberIndex("check_exist", $member{'regusername'})) { &fatal_error("id_taken","($member{'regusername'})"); }
	if (lc $member{'email'} eq lc &MemberIndex("check_exist", $member{'email'})) { &fatal_error("email_taken","($member{'email'})"); }
	if (lc $member{'regrealname'} eq lc &MemberIndex("check_exist", $member{'regrealname'})) { &fatal_error("name_taken"); }

	if ($regtype == 1) {
		$convertstr = $member{'reason'};
		$convertcut = $RegReasonSymbols;
		&CountChars;
		$member{'reason'} = $convertstr;

		&FromChars($member{'reason'});
		&ToHTML($member{'reason'});
		&ToChars($member{'reason'});
		$member{'reason'} =~ s~[\n\r]{1,2}~<br />~ig;
	}

	if ($regcheck) { require "$sourcedir/Decoder.pl"; &validation_check($member{'verification'}); }

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
		&fatal_error("password_mismatch","($member{'regusername'})") if $member{'passwrd1'} ne $member{'passwrd2'};
		&fatal_error("no_password","($member{'regusername'})") if $member{'passwrd1'} eq '';
		&fatal_error("invalid_character","$register_txt{'36'} $register_txt{'241'}") if $member{'passwrd1'} =~ /[^\s\w!\@#\$\%\^&\*\(\)\+\|`~\-=\\:;'",\.\/\?\[\]\{\}]/;
	}
	&fatal_error("invalid_character","$register_txt{'69'} $register_txt{'241e'}") if $member{'email'} !~ /^[\w\-\.\+]+\@[\w\-\.\+]+\.\w{2,4}$/;
	&fatal_error("invalid_email") if $member{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/ || $member{'email'} !~ /\A.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?\Z/;

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

	if ($default_template) { $new_template = $default_template; }
	else { $new_template = qq~Forum default~; }

	# check if user isn't already registered
	&fatal_error("id_taken") if &checkfor_DBorFILE("$memberdir/$member{'regusername'}.vars");
	# check if user isn't already in pre-registration
	&fatal_error("already_preregged") if (&checkfor_DBorFILE("$memberdir/$member{'regusername'}.pre"));
	&fatal_error("already_preregged") if (&checkfor_DBorFILE("$memberdir/$member{'regusername'}.wait"));

	if ($new_template !~ m^\A[0-9a-zA-Z\_\(\)\ \#\%\-\:\+\?\$\&\~\.\,\@]+\Z^ && $new_template ne '') { &fatal_error('invalid_template'); }
	if ($member{'language'} !~ m^\A[0-9a-zA-Z\_\(\)\ \#\%\-\:\+\?\$\&\~\.\,\@]+\Z^ && $member{'language'} ne '') { &fatal_error('invalid_language'); }

	&ToHTML($member{'language'});

	$reguser = $member{'regusername'};
	$registerdate = &timetostring($date);
	$language = $member{'language'};

	&ToHTML($member{'regrealname'});

	if ($birthday_on_reg) {
		$member{'birth_month'} =~ s/\D//g;
		$member{'birth_day'} =~ s/\D//g;
		$member{'birth_year'} =~ s/\D//g;
		if ($birthday_on_reg == 1) {
			$member{'birth_month'} = '' if length($member{'birth_month'}) < 2 || $member{'birth_month'} < 1 || $member{'birth_month'} > 12;
			$member{'birth_day'} = '' if length($member{'birth_day'}) < 2 || $member{'birth_day'} < 1 || $member{'birth_day'} > 31;
			$member{'birth_year'} = '' if length($member{'birth_year'}) < 4 || $member{'birth_year'} < ($year - 120) || $member{'birth_year'} > $year;
			if ($member{'birth_day'} && $member{'birth_month'} && $member{'birth_year'}) { ${$uid.$reguser}{'bday'} = "$member{'birth_month'}/$member{'birth_day'}/$member{'birth_year'}"; }

		} elsif ($birthday_on_reg == 2) {
			&fatal_error("",$register_txt{'error_birth_month'}) if length($member{'birth_month'}) < 2 || $member{'birth_month'} < 1 || $member{'birth_month'} > 12;
			&fatal_error("",$register_txt{'error_birth_day'}) if length($member{'birth_day'}) < 2 || $member{'birth_day'} < 1 || $member{'birth_day'} > 31;
			&fatal_error("",$register_txt{'error_birth_year'}) if length($member{'birth_year'}) < 4;
			&fatal_error("",$register_txt{'error_birth_year_real'}) if $member{'birth_year'} < ($year - 120) || $member{'birth_year'} > $year;
			${$uid.$reguser}{'bday'} = "$member{'birth_month'}/$member{'birth_day'}/$member{'birth_year'}";
		}
	}
	if ($gender_on_reg) {
		${$uid.$reguser}{'gender'} = $member{'gender'};
	}

	${$uid.$reguser}{'password'} = &encode_password($member{'passwrd1'});
	${$uid.$reguser}{'realname'} = $member{'regrealname'};
	${$uid.$reguser}{'email'} = lc($member{'email'});
	${$uid.$reguser}{'postcount'} = 0;
	${$uid.$reguser}{'regreason'} = $member{'reason'};
	${$uid.$reguser}{'usertext'} = $defaultusertxt; 
	${$uid.$reguser}{'userpic'} = "blank.gif";
	${$uid.$reguser}{'regdate'} = $registerdate;
	${$uid.$reguser}{'regtime'} = $date;
	${$uid.$reguser}{'timeselect'} = $timeselected;
	${$uid.$reguser}{'timeoffset'} = $timeoffset;
	${$uid.$reguser}{'dsttimeoffset'} = $dstoffset;
	${$uid.$reguser}{'lastips'} = $user_ip;
	${$uid.$reguser}{'hidemail'} = $member{'hideemail'} ? 1 : 0;
	${$uid.$reguser}{'timeformat'} = qq~MM D+ YYYY @ HH:mm:ss*~;
	${$uid.$reguser}{'template'} = $new_template;
	${$uid.$reguser}{'language'} = $language;
	${$uid.$reguser}{'pageindex'} = qq~1|1|1|1~;
	# the following values must no be NULL when using SQL backend, so we set default values here
	${$uid.$reguser}{'im_popup'} = 0;
	${$uid.$reguser}{'hide_smilies_row'} = 0;
	${$uid.$reguser}{'hide_user_text'} = 0;
	${$uid.$reguser}{'im_imspop'} = 0;
	${$uid.$reguser}{'hide_signat'} = 0;
	${$uid.$reguser}{'stealth'} = 0;
	${$uid.$reguser}{'dynamic_clock'} = 0;
	${$uid.$reguser}{'pmmessprev'} = 0;
	${$uid.$reguser}{'pmviewMess'} = 0;
	${$uid.$reguser}{'pmactprev'} = 0;
	${$uid.$reguser}{'notify_me'} = 0;
	${$uid.$reguser}{'reversetopic'} = 0;
	${$uid.$reguser}{'onlinealert'} = 0;
	${$uid.$reguser}{'spamcount'} = 0;
	${$uid.$reguser}{'hide_avatars'} = 0;
	${$uid.$reguser}{'hide_attach_img'} = 0;
	${$uid.$reguser}{'numberformat'} = 0;

	if (($addmemgroup_enabled == 1 || $addmemgroup_enabled == 3) && $member{'joinmemgroup'} ne '') {
		my @newmemgr;
		foreach (split(/, /, $member{'joinmemgroup'})) {
			if ($NoPost{$_} && (split /\|/, $NoPost{$_})[10] == 1) { push(@newmemgr, $_); }
		}
		${$uid.$reguser}{'addgroups'} = join(',', @newmemgr);
	}

	if ($regtype == 1 || $regtype == 2) {
		my (@reglist,@x);
		# If a pre-registration list exists load it
		if (&checkfor_DBorFILE("$memberdir/memberlist.inactive")) {
			@reglist = &read_DBorFILE(0,'',$memberdir,'memberlist','inactive');
		}
		# If a approve-registration list exists load it too
		if (&checkfor_DBorFILE("$memberdir/memberlist.approve")) {
			push(@reglist, &read_DBorFILE(0,'',$memberdir,'memberlist','approve'));
		}
		foreach (@reglist) {
			@x = split(/\|/, $_);
			if ($reguser eq $x[2]) { &fatal_error("already_preregged"); }
			if (lc $member{'email'} eq lc $x[4]) { &fatal_error("email_already_preregged"); }
		}

		# create pre-registration .pre file and write log and inactive list
		require "$sourcedir/Decoder.pl";
		&validation_code;
		$activationcode = substr($sessionid, 0, 20);

		if ($extendedprofiles) {
			require "$sourcedir/ExtendedProfiles.pl";
			my $error = &ext_validate_submition($reguser,$reguser);
			if ($error ne "") { &fatal_error("extended_profiles_validation",$error); }
			&ext_saveprofile($reguser);
		}

		&UserAccount($reguser, "preregister");
		if ($do_scramble_id) { $cryptuser = &cloak($reguser); } else { $cryptuser = $reguser; }
		&write_DBorFILE(0,INACT,$memberdir,'memberlist','inactive',(&read_DBorFILE(0,INACT,$memberdir,'memberlist','inactive'),"$date|$activationcode|$reguser|$member{'passwrd1'}|$member{'email'}|\n"));

		&write_DBorFILE(0,REGLOG,$vardir,'registration','log',(&read_DBorFILE(0,REGLOG,$vardir,'registration','log'),"$date|N|$member{'regusername'}||$user_ip\n"));

		## send an e-mail to the user that registration is pending e-mail validation within the given timespan. ##
		my $templanguage = $language;
		$language = $member{'language'};
		&LoadLanguage('Email');
		&sendmail(${$uid.$reguser}{'email'}, "$mailreg_txt{'apr_result_activate'} $mbname", &template_email($preregemail, {'displayname' => $member{'regrealname'}, 'username' => $reguser, 'cryptusername' => $cryptuser, 'password' => $member{'passwrd1'}, 'activationcode' => $activationcode, 'preregspan' => $preregspan}),'',$emailcharset);
		$language = $templanguage;
		$yymain .= qq~
		<table class="tabtitle" align="center" cellpadding="0" cellspacing="0" border="0" width="650">
			<tr>
				<td class="round_top_left" width="1%">&nbsp;</td>
				<td width="98%" valign="middle" align="center" height="25">
					<img src="$imagesdir/register.gif" alt="$prereg_txt{'1a'}" title="$prereg_txt{'1a'}" border="0" /><b>$prereg_txt{'1a'}</b>
				</td>
				<td class="round_top_right" width="1%">&nbsp;</td>
			</tr>
			<tr>
				<td colspan="3" align="left">
					<table cellpadding="4" cellspacing="1" border="0" width="100%" align="center" class="bordercolor">
					<tr><td class="windowbg">$prereg_txt{'1'}</td></tr>
					</table>
				</td>
			</tr>
		</table>~;
		$yytitle = "$prereg_txt{'1a'}";

	} else {
		if ($extendedprofiles) {
			require "$sourcedir/ExtendedProfiles.pl";
			my $error = &ext_validate_submition($reguser,$reguser);
			if ($error ne "") { &fatal_error("extended_profiles_validation",$error); }
			&ext_saveprofile($reguser);
		}
		&UserAccount($reguser, "register");
		${$uid.$reguser}{'mysql'} = 1 if $use_MySQL;
		&MemberIndex("add", $reguser);
		&FormatUserName($reguser);

		if ($send_welcomeim == 1) {
			# new format msg file:
			# messageid|(from)user|(touser(s))|(ccuser(s))|(bccuser(s))|subject|date|message|(parentmid)|reply#|ip|messagestatus|flags|storefolder|attachment
			$messageid = $^T . $$;
			&write_DBorFILE(0,'',$memberdir,$member{'regusername'},'msg',"$messageid|$sendname|$member{'regusername'}|||$imsubject|$date|$imtext|$messageid|0|$ENV{'REMOTE_ADDR'}|s|u||\n");
		}
		if ($new_member_notification) {
			my $templanguage = $language;
			$language = $lang;
			&LoadLanguage('Email');
			&sendmail($new_member_notification_mail, $mailreg_txt{'new_member_info'}, &template_email($newmemberemail, {'displayname' => $member{'regrealname'}, 'username' => $reguser, 'userip' => $user_ip, 'useremail' => ${$uid.$reguser}{'email'}}),'',$emailcharset);
			$language = $templanguage;
		}

		if ($emailpassword) {
			my $templanguage = $language;
			$language = $member{'language'};
			&LoadLanguage('Email');
			&sendmail(${$uid.$reguser}{'email'}, "$mailreg_txt{'apr_result_info'} $mbname", &template_email($passwordregemail, {'displayname' => $member{'regrealname'}, 'username' => $reguser, 'password' => $member{'passwrd1'}}),'',$emailcharset);
			$language = $templanguage;
			$yymain .= qq~
			<table class="tabtitle" align="center" cellpadding="0" cellspacing="0" border="0" width="650">
				<tr>
					<td class="round_top_left" width="1%">&nbsp;</td>
					<td width="98%" valign="middle" align="center" height="25"><b>$register_txt{'97'}</b></td>
					<td class="round_top_right" width="1%">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="3">
						<table cellpadding="4" cellspacing="1" border="0" width="100%" align="center" class="bordercolor">
							<tr><td class="windowbg" align="left">$register_txt{'703'}</td></tr>
							<tr><td class="windowbg2" align="left">$register_txt{'704'}</td></tr>
						</table>
					</td>
				</tr>
			</table>~;
		} else {
			if ($emailwelcome) {
				my $templanguage = $language;
				$language = $member{'language'};
				&LoadLanguage('Email');
				&sendmail(${$uid.$reguser}{'email'}, "$mailreg_txt{'apr_result_info'} $mbname", &template_email($welcomeregemail, {'displayname' => $member{'regrealname'}, 'username' => $reguser, 'password' => $member{'passwrd1'}}),'',$emailcharset);
				$language = $templanguage;
			}
			$yymain .= qq~
		<br /><br />
		<form action="$scripturl?action=login2" method="post">
		<table class="tabtitle" align="center" cellpadding="0" cellspacing="0" border="0" width="300">
			<tr>
				<td class="round_top_left" width="1%">&nbsp;</td>
				<td width="98%" valign="middle" align="center" height="25">
					<img src="$imagesdir/register.gif" alt="$register_txt{'97'}" title="$register_txt{'97'}" border="0" /> <span class="text1"><b>$register_txt{'97'}</b></span>
				</td>
				<td class="round_top_right" width="1%">&nbsp;</td>
			</tr>
			<tr>
				<td colspan="3">
					<table border="0" width="100%" cellspacing="1" class="bordercolor" align="center">
					<tr>
					<td class="windowbg" align="center">
					<br />$register_txt{'431'}<br /><br />
					<input type="hidden" name="username" value="$member{'regusername'}" />
					<input type="hidden" name="passwrd" value="$member{'passwrd1'}" />
					<input type="hidden" name="cookielength" value="$Cookie_Length" />
					<input type="submit" value="$register_txt{'34'}" class="button" />
					</td>
					</tr>
					</table>
				</td>
			</tr>
		</table>
		</form>
		<br /><br />
			~;
		}
		$yytitle = "$register_txt{'245'}";
	}
	&template;
}

sub user_activation {
	$changed       = 0;
	$reguser       = $_[0] || $INFO{'username'};
	$activationkey = $_[1] || $INFO{'activationkey'};
	&fatal_error('wrong_id') unless $reguser;
	if ($do_scramble_id) { $reguser = &decloak($reguser); }
	if (!&checkfor_DBorFILE("$memberdir/$reguser.pre") && &checkfor_DBorFILE("$memberdir/$reguser.vars")) { &fatal_error("already_activated"); }
	if (!&checkfor_DBorFILE("$memberdir/$reguser.pre")) { &fatal_error("prereg_expired"); }
	# If a pre-registration list exists load it
	if (&checkfor_DBorFILE("$memberdir/memberlist.inactive")) {
		@reglist = &read_DBorFILE(0,'',$memberdir,'memberlist','inactive');
	} else {
		# add entry to registration log
		&write_DBorFILE(0,REGLOG,$vardir,'registration','log',(&read_DBorFILE(0,REGLOG,$vardir,'registration','log'),"$date|E|$reguser||$user_ip\n"));
		&fatal_error("prereg_expired");
	}
	if ($regtype == 1 && &checkfor_DBorFILE("$memberdir/memberlist.approve")) {
		@aprlist = &read_DBorFILE(0,'',$memberdir,'memberlist','approve');
	}

	# check if user is in pre-registration and check activation key
	foreach (@reglist) {
		($regtime, $testkey, $regmember, $regpassword, undef) = split(/\|/, $_, 5);

		if ($regmember ne $reguser) {
			push(@chnglist, $_); # update non activate user list
		} else {
			my $templanguage = $language;
			if ($activationkey ne $testkey) {
				# add entry to registration log
				&write_DBorFILE(0,REGLOG,$vardir,'registration','log',(&read_DBorFILE(0,REGLOG,$vardir,'registration','log'),"$date|E|$reguser||$user_ip\n"));
				&fatal_error("wrong_code");

			} elsif ($regtype == 1) {
				# user is in list and the keys match, so move him/her for admin approval
				unshift(@aprlist, $_);

				rename("$memberdir/$reguser.pre", "$memberdir/$reguser.wait");

				# add entry to registration log
				if ($iamadmin || $iamgmod) { $actuser = $username; } else { $actuser = $reguser; }
				# add entry to registration log
				&write_DBorFILE(0,REGLOG,$vardir,'registration','log',(&read_DBorFILE(0,REGLOG,$vardir,'registration','log'),"$date|W|$reguser|$actuser|$user_ip\n"));

				&LoadUser($reguser);
				$language = ${$uid.$reguser}{'language'};
				&LoadLanguage('Email');
				&sendmail(${$uid.$reguser}{'email'}, "$mailreg_txt{'apr_result_wait'} $mbname", &template_email($approveregemail, {'username' => $reguser, 'displayname' => ${$uid.$reguser}{'realname'}}),'',$emailcharset);

			} elsif ($regtype == 2) {
				&LoadUser($reguser);
				# ckeck if email is allready in active use
				if (lc ${$uid.$reguser}{'email'} eq lc &MemberIndex("check_exist", ${$uid.$reguser}{'email'})) {
					&fatal_error("email_taken", "(${$uid.$reguser}{'email'})");
				}

				# user is in list and the keys match, so let him/her in
				if ($use_MySQL) {
					&UserAccount($reguser); 
					${$uid.$reguser}{'mysql'} = 1;
					&delete_DBorFILE("$memberdir/$reguser.pre");
				} else { rename("$memberdir/$reguser.pre", "$memberdir/$reguser.vars"); }
				&MemberIndex("add", $reguser);

				if ($iamadmin || $iamgmod) { $actuser = $username; } else { $actuser = $reguser; }
				# add entry to registration log
				&write_DBorFILE(0,REGLOG,$vardir,'registration','log',(&read_DBorFILE(0,REGLOG,$vardir,'registration','log'),"$date|A|$reguser|$actuser|$user_ip\n"));

				if ($emailpassword) {
					chomp $regpassword;
					$language = ${$uid.$reguser}{'language'};
					&LoadLanguage('Email');
					&sendmail(${$uid.$reguser}{'email'}, "$mailreg_txt{'apr_result_validate'} $mbname", &template_email($activatedpassregemail, {'displayname' => ${$uid.$reguser}{'realname'}, 'username' => $reguser, 'password' => $regpassword}),'',$emailcharset);
					$yymain .= qq~<br /><table border="0" width="100%" cellspacing="1" class="bordercolor" align="center">~;
					$sharedLogin_title = $register_txt{'97'};
					$sharedLogin_text  = $register_txt{'703'};
					$yymain .= qq~</table>~;

				} elsif ($emailwelcome) {
					chomp $regpassword;
					$language = ${$uid.$reguser}{'language'};
					&LoadLanguage('Email');
					&sendmail(${$uid.$reguser}{'email'}, "$mailreg_txt{'apr_result_validate'} $mbname", &template_email($activatedwelcomeregemail, {'displayname' => ${$uid.$reguser}{'realname'}, 'username' => $reguser, 'password' => $regpassword}),'',$emailcharset);
				}
			}

			if ($send_welcomeim == 1) {
				# new format msg file:
				# messageid|(from)user|(touser(s))|(ccuser(s))|(bccuser(s))|subject|date|message|(parentmid)|reply#|ip|messagestatus|flags|storefolder|attachment
				$messageid = $^T . $$;
				&write_DBorFILE(0,'',$memberdir,$reguser,'msg',"$messageid|$sendname|$reguser|||$imsubject|$date|$imtext|$messageid|0|$ENV{'REMOTE_ADDR'}|s|u||\n");
			}
			if ($new_member_notification) {
				$language = $lang;
				&LoadLanguage('Email');
				&sendmail($new_member_notification_mail, $mailreg_txt{'new_member_info'}, &template_email($newmemberemail, {'displayname' => ${$uid.$reguser}{'realname'}, 'username' => $reguser, 'userip' => $user_ip, 'useremail' => ${$uid.$reguser}{'email'}}),'',$emailcharset);
			}
			$language = $templanguage;
			$changed = 1;
		}
	}

	if ($changed) {
		# if changed write new inactive list
		&write_DBorFILE(0,'',$memberdir,'memberlist','inactive',@chnglist);
		# update approval user list
		if ($regtype == 1) {
			&write_DBorFILE(0,'',$memberdir,'memberlist','approve',@aprlist);
		}
	} else {
		# add entry to registration log
		&write_DBorFILE(0,REGLOG,$vardir,'registration','log',(&read_DBorFILE(0,REGLOG,$vardir,'registration','log'),"$date|E|$reguser||$user_ip\n"));
		&fatal_error("wrong_id");
	}

	if ($regtype == 1) {
			$yymain .= qq~
				<div class="bordercolor" style="width: 650px; margin-bottom: 8px; margin-left: auto; margin-right: auto;">
					<div class="bordercolor" style="width: 650px; margin-bottom: 8px; margin-left: auto; margin-right: auto;">
						<table cellpadding="4" cellspacing="1" border="0" width="100%" align="center">
							<tr><td class="titlebg"><img src="$imagesdir/register.gif" alt="$prereg_txt{'1a'}" title="$prereg_txt{'1a'}" border="0" /><b>$prereg_txt{'1a'}</b></td></tr>
							<tr><td class="windowbg" align="left">$prereg_txt{'13'}</td></tr>
						</table>
					</div>
				</div>~;
			$yytitle = "$prereg_txt{'1b'}";

	} elsif ($regtype == 2) {
		$yymain .= qq~
		<br /><br />
		<table border="0" width="650" cellspacing="1" class="bordercolor" align="center">
		<tr>
		<td colspan="2" class="titlebg">
		<img src="$imagesdir/register.gif" alt="$prereg_txt{'1a'}" title="$prereg_txt{'1a'}" border="0" /> <span class="text1"><b>$prereg_txt{'1a'}</b></span></td>
		</tr><tr>
		<td colspan="2" class="windowbg" align="center">
		<br />$prereg_txt{'5'}~;
		$yymain .= $prereg_txt{'5a'} unless $emailpassword;
		$yymain .= qq~$prereg_txt{'5b'}<br /><br />~;
		if ($emailpassword) {
			$yymain .= qq~$register_txt{'703'}<br /> <br />~;
		}
		$yymain .= qq~
		</td>
		</tr>
		</table>
		~;

		if (!$iamadmin && !$iamgmod) {
			unless ($emailpassword) {
				$yymain .= qq~<div class="bordercolor" style="width: 650px; margin-bottom: 8px; margin-left: auto; margin-right: auto;">~;
				require "$sourcedir/LogInOut.pl";
				$yymain .= &sharedLogin;
				$yymain .= qq~</div>~;
			} else {
				$yymain .= qq~<br /><br />~;
			}
		}
		$yytitle = "$prereg_txt{'5'}";
	}

	if ($iamadmin || $iamgmod) {
		$yySetLocation = qq~$adminurl?action=view_reglog~;
		&redirectexit;
	} else {
		&template;
	}
}

1;