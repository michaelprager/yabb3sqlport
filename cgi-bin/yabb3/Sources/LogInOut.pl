###############################################################################
# LogInOut.pl                                                                 #
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

$loginoutplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

if ($regcheck) { require "$sourcedir/Decoder.pl"; }
&LoadLanguage('LogInOut');

$regstyle = '';
$no_error_page = 0;

sub Login {
	$sharedLogin_title = $loginout_txt{'34'};
	$yymain .= &sharedLogin . qq~<script type="text/javascript" language="JavaScript">
<!--
	document.loginform.username.focus();
//-->
</script>~;
	$yytitle = $loginout_txt{'34'};
	&template;
}

sub Login2 {
	$no_error_page = $INFO{'type'} eq "checkcred";
	&fatal_error("no_username") if ($FORM{'username'} eq "");
	&fatal_error("no_password") if ($FORM{'passwrd'}  eq "" && !$openidvalidated);
	$username = $FORM{'username'};
	$username =~ s/\s/_/g;
	&fatal_error("invalid_character","$loginout_txt{'35'} $loginout_txt{'241'}") if $username =~ /[^ \w\x80-\xFF\[\]\(\)#\%\+,\-\|\.:=\?\@\^]/;
	#&fatal_error("only_numbers_allowed") if $FORM{'cookielength'} !~ /^[0-9]+$/;

	my $user_exists = &checkfor_DBorFILE("$memberdir/$username.vars");

	## Check if login ID is not and email address or screenname ##
	if (!$user_exists) {
		my $test_id = &MemberIndex("who_is", "$FORM{'username'}");
		if ($test_id ne "") {
			$username = $test_id;
			$user_exists = 1;
		} else {
			$username = "Guest";
			&fatal_error("bad_credentials");
		}
	}
	if (&checkfor_DBorFILE("$memberdir/$username.pre")) {
		if ($user_exists) { &delete_DBorFILE("$memberdir/$username.pre"); }
		if ($regtype == 1 || $regtype == 2) { &fatal_error('not_activated'); }
	}

	# Need to do this to get correct case of username,
	# for case insensitive systems. Can cause weird issues otherwise
	&ManageMemberinfo("load");
	my $caseright;
	foreach (keys %memberinf) {
		if ($username =~ m/\A\Q$_\E\Z/) { $caseright = 1; last; }
	}
	undef %memberinf;
	if (!$caseright || !&checkfor_DBorFILE("$memberdir/$username.vars")) {
		$username = "Guest";
		&fatal_error("bad_credentials");
	}

	&LoadUser($username);
	if(!$openidvalidated) {
		my $spass     = ${$uid.$username}{'password'};
		my $cryptpass = &encode_password("$FORM{'passwrd'}");

		# convert non encrypted password to MD5 crypted one
		if ($spass eq $FORM{'passwrd'} && $spass ne $cryptpass) {
			# only encrypt the password if it's not already MD5 encrypted
			# MD5 hashes in YaBB are always 22 chars long (base64)
			if (length(${$uid.$username}{'password'}) != 22) {
				${$uid.$username}{'password'} = $cryptpass;
				&UserAccount($username);
				$spass = $cryptpass;
			}
		}
		if ($spass ne $cryptpass) {
			$username = "Guest";
			&fatal_error("bad_credentials");
		}
	}

	$iamadmin     = ${$uid.$username}{'position'} eq 'Administrator' ? 1 : 0;
	$iamgmod      = ${$uid.$username}{'position'} eq 'Global Moderator' ? 1 : 0;
	$sessionvalid = 1;
	$iamguest = 0;

	if ($maintenance && !$iamadmin) { $username = 'Guest'; &fatal_error("admin_login_only"); }
	&banning;

	if ($FORM{'cookielength'}) { $ck{'len'} = 'Sunday, 17-Jan-2038 00:00:00 GMT'; }
	else { $ck{'len'} = ''; }
	#else { $ck{'len'} = "+$FORM{'cookielength'}m"; }
	${$uid.$username}{'session'} = &encode_password($user_ip);
	&UpdateCookie("write", $username, $openidvalidated ? ${$uid.$username}{'password'} : &encode_password($FORM{'passwrd'}), ${$uid.$username}{'session'}, "/", $ck{'len'});

	&UserAccount($username, "update", "-"); # "-" to not update 'lastonline' here
	&buildIMS($username,'load'); # isn't loaded because was Guest before
	&buildIMS($username,''); # rebuild the Members/$username.ims file on login

	if($FORM{'sredir'}) {
		$FORM{'sredir'} =~ s/\~/\=/g;
		$FORM{'sredir'} =~ s/x3B/;/g;
		$FORM{'sredir'} =~ s/search2/search/g;
		$FORM{'sredir'} = qq~?$FORM{'sredir'}~;
		$FORM{'sredir'} = '' if $FORM{'sredir'} =~ /action=(register|login2)/;
	}

	$yySetLocation = qq~$scripturl$FORM{'sredir'}~;

	if ($no_error_page) {
		&print_output_header;
		print "confirmed$yySetLocation";
		CORE::exit; # This is here only to avoid server error log entries! }
	}
	
	&redirectexit;
}

sub Logout {
	if ($username ne 'Guest') {
		&RemoveUserOnline($username); # Remove user from online log
		&UserAccount($username, "update", "lastonline");
	}

	&UpdateCookie("delete");
	$yySetLocation = $guestaccess ? $scripturl : qq~$scripturl?action=login~;
	$username = 'Guest';
	&redirectexit;
}

sub sharedLogin {
	if ($action eq 'login' || $maintenance) {
		$yynavigation = qq~&rsaquo; $loginout_txt{'34'}~;
	}

	if    ($Cookie_Length == 1)    { $clsel1    = ' selected="selected"'; }
	elsif ($Cookie_Length == 2)    { $clsel2    = ' selected="selected"'; }
	elsif ($Cookie_Length == 60)   { $clsel60   = ' selected="selected"'; }
	elsif ($Cookie_Length == 180)  { $clsel180  = ' selected="selected"'; }
	elsif ($Cookie_Length == 360)  { $clsel360  = ' selected="selected"'; }
	elsif ($Cookie_Length == 480)  { $clsel480  = ' selected="selected"'; }
	elsif ($Cookie_Length == 600)  { $clsel600  = ' selected="selected"'; }
	elsif ($Cookie_Length == 720)  { $clsel720  = ' selected="selected"'; }
	elsif ($Cookie_Length == 1440) { $clsel1440 = ' selected="selected"'; }
	if ($sharedLogin_title ne "") {
		$sharedlog .= qq~
<div style="width: 700px; margin-left: auto; margin-right: auto">
<table cellpadding="0" cellspacing="0" border="0" width="700" align="center" class="tabtitle">
	<tr>
		<td class="round_top_left" width="99%" style="padding:4px"><b>$sharedLogin_title</b></td>
		<td class="round_top_right" width="1%">&nbsp;</td>
	</tr>
</table>
<table class="bordercolor" cellpadding="4" cellspacing="1" border="0" width="100%" align="center">~;
		if ($sharedLogin_text ne "") {
			$sharedlog .= qq~
	<tr><td class="windowbg" colspan="2" align="left">$sharedLogin_text</td></tr>~;
		}
		$sharedlog .= qq~
	<tr>
		<td class="windowbg2" colspan="2" align="center" valign="middle" style="padding: 10px;">~;
	} else {
		$sharedlog .= qq~
<div style="width: 100%">
<table class="tabtitle" align="center" cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td class="round_top_left" width="1%">&nbsp;</td>
		<td width="98%" valign="middle" align="center" height="25">$loginout_txt{'34'}</td>
		<td class="round_top_right" width="1%">&nbsp;</td>
	</tr>
</table>
<table class="bordercolor" align="center" cellpadding="0" cellspacing="1" border="0" width="100%">
	<tr>
		<td class="windowbg" width="5%" valign="middle" align="center"><img src="$imagesdir/login.gif" border="0" alt="" /></td>
		<td class="windowbg2" align="center" valign="middle" style="padding: 10px;">~;
	}
	if ($maintenance || !$regtype) { $dbutton = ' disabled="disabled"'; }
	$sharedlog .= qq~
			<form name="loginform" action="$scripturl?action=login2" method="post">
				<input type="hidden" name="sredir" value="$INFO{'sesredir'}" />
				<div style="width: 535px;">
					<span style="float: left; text-align: left; margin-right: 15px;">
						<label for="username">$loginout_txt{'35'}</label>:<br />
						<input onkeypress="enterKey(event)" type="text" name="username" id="username" size="30" maxlength="100" style="width: 285px;" tabindex="1"$regstyle />
					</span>
					<span style="float: left; text-align: left; margin-right: 15px;">
						<label for="passwrd">$loginout_txt{'36'}</label>:<br />
						<input onkeypress="enterKey(event)" type="password" name="passwrd" id="passwrd" size="15" maxlength="30" style="width: 110px;" tabindex="2" onkeypress="capsLock(event,'shared_login')" />
					</span>
					<span style="float: left; text-align: center;">
						&nbsp;<br />
						<input type="button" name="submitlogin" onclick="CheckCredentials('$scripturl?action=login2;type=checkcred')" value="$loginout_txt{'34'}" tabindex="4" accesskey="l" style="width: 100px;" class="button" />
					</span>
				</div>
				<div style="width: 535px;" class="small">
					<span style="float: left; text-align: left;">
						<input type="checkbox" name="cookielength" id="cookielength" tabindex="3" />
					</span>
					<span style="float: left; text-align: left; margin-top:4px;">
						<label for="cookielength">Keep me logged in.</label>
					</span>
					<span style="float: right; text-align: right; margin-left: 15px; margin-top:4px;">
						<a href="$scripturl?action=reminder">$loginout_txt{'315'}</a>
					</span>
					<span style="float: right; text-align: right; margin-left: 15px; margin-top:4px;">
						<a href="$scripturl?action=register">$maintxt{'97'}</a>
					</span>
					<br /><br />
				</div>
			</form><br /><br /><br />
			<div style="width: 535px; text-align: left">
				<a class="rpxnow" onclick="return false;" href="https://yabb.rpxnow.com/openid/v2/signin?token_url=http%3A%2F%2Fwww.dev.yabbworld.com%2Fcgi-bin%2Fforum%2FYaBB.pl%3Faction%3Dopenidvalidate">
					<img src="$imagesdir/openidsmall.jpg" border="0" /> Login with OpenID
				</a>
			</div>
			<div style="width: 600px; text-align: left; color: red; font-weight: bold;" id="credresults"></div>
			<div style="width: 600px; text-align: left; color: red; font-weight: bold; display: none" id="shared_login">$loginout_txt{'capslock'}</div>
			<div style="width: 600px; text-align: left; color: red; font-weight: bold; display: none" id="shared_login_char">$loginout_txt{'wrong_char'}: <span id="shared_login_character">&nbsp;</span></div>
		</td>
	</tr>
</table>
</div>
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

	$loginform = 1;
	$sharedLogin_title = '';
	$sharedLogin_text = '';
	return $sharedlog;
} 

sub Reminder {
	$yymain .= qq~<br /><br />
<form action="$scripturl?action=reminder2" method="post">
<table border="0" width="400" cellspacing="1" cellpadding="3" align="center" class="bordercolor">
	<tr>
	<td class="titlebg">
	<span class="text1"><b>$mbname $loginout_txt{'36'} $loginout_txt{'194'}</b></span>
	</td>
	</tr><tr>
	<td class="windowbg">
	<label for="user"><span class="text1"><b>$loginout_txt{'35'}:</b></span></label>
	<input type="text" name="user" id="user" $regstyle />
	</td>
	</tr>
~;

	if ($regcheck) {
		&validation_code;
		$yymain .= qq~
	<tr>
	<td class="windowbg">
	<label for="verification"><span class="text1"><b>$floodtxt{'1'}: </b></span>
	$showcheck
	<br /><span class="small">$floodtxt{'casewarning'}</span></label>
	</td>
	</tr><tr>
	<td class="windowbg">
	<label for="verification"><span class="text1"><b>$floodtxt{'3'}: </b></span></label>
	<span class="text1"><input type="text" maxlength="30" name="verification" id="verification" size="20" /></span>
	</td>
	</tr>
~;
	}
	$yymain .= qq~
	<tr>
	<td align="center" class="windowbg">
	<input type="submit" value="$loginout_txt{'339'}" class="button" />
	</td>
	</tr>
</table>
</form>
<br /><br />
~;

	$yytitle = $loginout_txt{'669'};
	$yynavigation = qq~&rsaquo; $loginout_txt{'669'}~;
	&template;
}

sub Reminder2 {
	# generate random ID for password reset.
	my $randid = &keygen(8,"A");

	if ($regcheck) {
		&validation_check($FORM{'verification'});
	}

	my $user = $FORM{'user'};
	$user =~ s/\s/_/g;

	if (!&checkfor_DBorFILE("$memberdir/$user.vars")) {
		my $test_id = &MemberIndex("who_is", $user);
		if ($test_id) { $user = $test_id; }
		else { &fatal_error("bad_credentials"); }
	}

	# Fix to make it load in their own language
	&LoadUser($user);
	&fatal_error("corrupt_member_file") if !${$uid.$user}{'email'};

	$username = $user;
	&WhatLanguage;
	&LoadLanguage('LogInOut');
	&LoadLanguage('Email');
	undef $username;

	$userfound = 0;

	if (-e "$memberdir/forgotten.passes") {
		require "$memberdir/forgotten.passes";
	}
	if (exists $pass{$user}) { delete $pass{$user}; }
	$pass{"$user"} = $randid;

	my @temp;
	while (($key, $value) = each(%pass)) {
		push(@temp, qq~\$pass{"$key"} = '$value';\n~);
	}
	&write_DBorFILE(0,'',$memberdir,'forgotten','passes',(@temp,"\n1;"));

	$subject = "$loginout_txt{'36'} $mbname: ${$uid.$user}{'realname'}";
	if($do_scramble_id){$cryptusername = &cloak($user);} else {$cryptusername = $user; }
	require "$sourcedir/Mailer.pl";
	&LoadLanguage('Email');
	my $message = &template_email($passwordreminderemail, {'displayname' => ${$uid.$user}{'realname'}, 'cryptusername' => $cryptusername, 'remindercode' => $randid});
	&sendmail(${$uid.$user}{'email'}, $subject, $message);

	$yymain .= qq~<br /><br />
<table border="0" width="400" cellspacing="1" cellpadding="3" align="center" class="bordercolor">
	<tr>
	<td class="titlebg">
	<span class="text1"><b>$mbname $loginout_txt{'36'} $loginout_txt{'194'}</b></span>
	</td>
	</tr><tr>
 	<td class="windowbg" align="center">
	<b>$loginout_txt{'192'} $FORM{'user'}</b></td>
      </tr>
</table>
<br /><p align="center"><a href="$scripturl">$loginout_txt{'193'}</a></p><br />
~;
	$yytitle = "$loginout_txt{'669'}";
	&template;
}

sub Reminder3 {
	$id   = $INFO{'ID'};
	if($do_scramble_id){$user = &decloak($INFO{'user'});} else { $user = $INFO{'user'};}

	if ($id !~ /[a-zA-Z0-9]+/) { &fatal_error("invalid_character","ID $loginout_txt{'241'}"); }
	if ($user =~ /[^\w#\%\+\-\.\@\^]/) { &fatal_error("invalid_character","User $loginout_txt{'241'}"); }

	# generate a new random password as the old one is one-way encrypted.
	@chararray = qw(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z);
	my $newpassword;
	for (my $i; $i < 8; $i++) {
		$newpassword .= $chararray[int(rand(61))];
	}

	# load old userdata
	&LoadUser($user);

	# update forgotten passwords database
	require "$memberdir/forgotten.passes";
	if ($pass{$user} ne $id) { &fatal_error("wrong_id"); }
	delete $pass{$user};

	my @temp;
	while (($key, $value) = each(%pass)) {
		push(@temp, qq~\$pass{"$key"} = '$value';\n~);
	}
	&write_DBorFILE(0,'',$memberdir,'forgotten','passes',(@temp,"\n1;"));

	# add newly generated password to user data
	${$uid.$user}{'password'} = &encode_password($newpassword);
	&UserAccount($user, "update");

	$FORM{'username'} = $user;
	$FORM{'passwrd'} = $newpassword;
	$FORM{'cookielength'} = 10;
	$FORM{'sredir'} = qq*action~profileCheck2;redir~myprofile;username~$INFO{'user'};passwrd~$newpassword;newpassword~1*;
	&Login2;
}

sub InMaintenance {
	if ($maintenancetext ne "") { $maintxt{'157'} = $maintenancetext; }
	$sharedLogin_title = "$maintxt{'114'}";
	$sharedLogin_text  = "<b>$maintxt{'156'}</b><br />$maintxt{'157'}";
	$yymain .= &sharedLogin;
	$yytitle = "$maintxt{'155'}";
	&template;
}

sub OpenIDValidate {
	use LWP::UserAgent;
	
	my $ua = LWP::UserAgent->new();
	
	my $resp = $ua->post('https://rpxnow.com/api/v2/auth_info', { apiKey => '033585472587e806e2fb02db0c092fe8a6e1348a' , token => $FORM{'token'} });
	
	my $content = $resp->content;
	
	$content =~ s/:"/=\>'/g;
	$content =~ s/",/',/g;
	$content =~ s/"\}/'\}/g;
	$content =~ s/":/=\>/g;
	$content =~ s/"//g;
	my $c = qq~\$user = $content;~;
	
	eval $c;
	require "$vardir/openid.txt";
	
	$openidvalidated = 0;
	
	$user->{profile}->{identifier} =~ s/\\//g;
	
	foreach my $useroid ( keys %openids ) {
		my @ids = split(/\|/, $openids{$useroid});
		foreach my $id (@ids) {
			if ($user->{profile}->{identifier} eq $id) {
				$openidvalidated = 1;
				$FORM{'username'} = $useroid;
				&Login2;
				last;
			}
		}
		last if ($openidvalidated);
	}
	
	if(!$openidvalidated) {
		&fatal_error("",$user->{profile}->{identifier});
	}
}

1;