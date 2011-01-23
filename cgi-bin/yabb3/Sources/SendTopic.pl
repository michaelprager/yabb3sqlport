###############################################################################
# SendTopic.pl                                                                #
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

$sendtopicplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

if ($regcheck) { require "$sourcedir/Decoder.pl"; }

&LoadLanguage('SendTopic');

sub SendTopic {
	$topic = $INFO{'topic'};
	&MessageTotals("load", $topic);
	$board = ${$topic}{'board'};
	&fatal_error("no_board_send") unless ($board ne '' && $board ne '_' && $board ne ' ');
	&fatal_error("no_topic_send") unless ($topic ne '' && $topic ne '_' && $topic ne ' ');

	unless (ref($thread_arrayref{$topic})) {
		@{$thread_arrayref{$topic}} = &read_DBorFILE(0,'',$datadir,$topic,'txt');
	}
	$subject = (split(/\|/, ${$thread_arrayref{$topic}}[0], 2))[0];

	$yymain .= qq~
<form action="$scripturl?action=sendtopic2" method="post">
<table width="70%" border="0" align="center" cellspacing="0" cellpadding="3" class="tabtitle">
	<tr>
		<td width="1%" class="round_top_left">&nbsp;</td>
		<td align="center">
			<img src="$imagesdir/email.gif" alt="" border="0" />
			<span class="text1"><b>$sendtopic_txt{'707'}&nbsp; &#171; $subject &#187; &nbsp;$sendtopic_txt{'708'}</b></span>
		</td>
		<td width="1%" class="round_top_right">&nbsp;</td>
	</tr>
	<tr>
	<td class="bordercolor" colspan="3" style="padding:1px">
<table width="100%" border="0" align="center" cellspacing="0" cellpadding="3">
	<tr>
		<td width="30%" class="windowbg" align="left"><label for="y_name"><b>$sendtopic_txt{'335'}:</b></label></td>
		<td width="70%" class="windowbg" align="left"><input type="text" name="y_name" id="y_name" size="50" maxlength="50" value="${$uid.$username}{'realname'}" /></td>
	</tr><tr>
		<td width="30%" class="windowbg" align="left"><label for="y_email"><b>$sendtopic_txt{'336'}:</b></label></td>
		<td width="70%" class="windowbg" align="left"><input type="text" name="y_email" id="y_email" size="50" maxlength="50" value="${$uid.$username}{'email'}" /></td>
	</tr><tr>
		<td class="windowbg" align="center" valign="top" colspan="2">
			<hr width="100%" size="1" class="hr" />
		</td>
	</tr><tr>
		<td width="30%" class="windowbg" align="left"><label for="r_name"><b>$sendtopic_txt{'717'}:</b></label></td>
		<td width="70%" class="windowbg" align="left"><input type="text" name="r_name" id="r_name" size="50" maxlength="50" /></td>
	</tr><tr>
		<td width="30%" class="windowbg" align="left"><label for="r_email"><b>$sendtopic_txt{'718'}:</b></label></td>
		<td width="70%" class="windowbg" align="left"><input type="text" name="r_email" id="r_email" size="50" maxlength="50" /></td>
	</tr>
~;

	if ($regcheck) {
		&validation_code;
		$yymain .= qq~
	<tr>
		<td class="windowbg" align="center" valign="top" colspan="2">
			<hr width="100%" size="1" class="hr" />
		</td>
	</tr><tr>
		<td width="30%" class="windowbg" align="left" valign="middle"><label for="verification"><b>$floodtxt{'1'}:</b></label></td>
		<td width="70%" class="windowbg" align="left" valign="middle">$showcheck<br /><label for="verification"><span class="small">$floodtxt{'casewarning'}</span></label></td>
	</tr><tr>
		<td width="30%" class="windowbg" align="left"><label for="verification"><b>$floodtxt{'3'}:</b></label></td>
		<td width="70%" class="windowbg" align="left"><input type="text" maxlength="30" name="verification" id="verification" size="50" /></td>
	</tr>
~;
	}
	$yymain .= qq~
	<tr>
		<td class="windowbg" align="center" valign="top" colspan="2">
			<hr width="100%" size="1" class="hr" />
		</td>
	</tr><tr>
		<td class="windowbg" align="center" colspan="2">
			<input type="hidden" name="board" value="$board" />
			<input type="hidden" name="topic" value="$topic" />
			<input type="submit" name="Send" value="$sendtopic_txt{'339'}" class="button" />
		</td>
	</tr>
</table>
	</td>
	</tr>
</table>
</form>
~;
	$yytitle = "$sendtopic_txt{'707'}&nbsp; &#171; $subject &#187; &nbsp;$sendtopic_txt{'708'}";
	$yynavigation = qq~&rsaquo; $sendtopic_txt{'707'}~;
	&template;
}

sub SendTopic2 {
	$topic = $FORM{'topic'};
	$board = $FORM{'board'};
	&fatal_error("no_board_send") unless ($board ne '' && $board ne '_' && $board ne ' ');
	&fatal_error("no_topic_send") unless ($topic ne '' && $topic ne '_' && $topic ne ' ');

	$yname  = $FORM{'y_name'};
	$rname  = $FORM{'r_name'};
	$yemail = $FORM{'y_email'};
	$remail = $FORM{'r_email'};
	$yname =~ s/\A\s+//;
	$yname =~ s/\s+\Z//;
	$yemail =~ s/\A\s+//;
	$yemail =~ s/\s+\Z//;
	$rname =~ s/\A\s+//;
	$rname =~ s/\s+\Z//;
	$remail =~ s/\A\s+//;
	$remail =~ s/\s+\Z//;

	if ($regcheck) {
		&validation_check($FORM{'verification'});
	}

	&fatal_error("no_name","$sendtopic_txt{'335'}") unless ($yname ne '' && $yname ne '_' && $yname ne ' ');
	&fatal_error("sendname_too_long","$sendtopic_txt{'335'}") if (length($yname) > 25);
	&fatal_error("no_email","$sendtopic_txt{'336'}") if ($yemail eq '');
	&fatal_error("invalid_character","$sendtopic_txt{'336'} $sendtopic_txt{'241'}") if ($yemail !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/);
	&fatal_error("invalid_email","$sendtopic_txt{'336'}") if (($yemail =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($yemail !~ /^.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?$/));
	&fatal_error("no_name","$sendtopic_txt{'717'}") unless ($rname ne '' && yname ne '_' && $rname ne ' ');
	&fatal_error("sendname_too_long","$sendtopic_txt{'717'}") if (length($rname) > 25);
	&fatal_error("no_email","$sendtopic_txt{'718'}") if ($remail eq '');
	&fatal_error("invalid_character","$sendtopic_txt{'718'} $sendtopic_txt{'241'}") if ($remail !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/);
	&fatal_error("invalid_email","$sendtopic_txt{'718'}")                                            if (($remail =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($remail !~ /^.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?$/));

	unless (ref($thread_arrayref{$topic})) {
		@{$thread_arrayref{$topic}} = &read_DBorFILE(0,'',$datadir,$topic,'txt');
	}
	$subject = (split(/\|/, ${$thread_arrayref{$topic}}[0], 2))[0];
	&FromHTML($subject);
	require "$sourcedir/Mailer.pl";
	&LoadLanguage('Email');
		my $message = &template_email($sendtopicemail, {'toname' => $rname, 'subject' => $subject, 'displayname' => $yname, 'num' => $topic});
	&sendmail($remail, "$sendtopic_txt{'118'}: $subject ($sendtopic_txt{'318'} $yname)", $message, $yemail);

	$yySetLocation = qq~$scripturl?num=$topic~;
	&redirectexit;
}

1;