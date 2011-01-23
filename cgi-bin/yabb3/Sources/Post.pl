###############################################################################
# Post.pl                                                                     #
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

$postplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('Post');
&LoadLanguage('Display');
&LoadLanguage('FA');
&LoadLanguage('UserSelect');

require "$sourcedir/Notify.pl";
require "$sourcedir/SpamCheck.pl";

if ($iamguest && $gpvalid_en && ($enable_guestposting || $PMenableGuestButton|| $PMAlertButtonGuests)) {
	require "$sourcedir/Decoder.pl";
}
$set_subjectMaxLength ||= 50;

&LoadCensorList;

sub Post {
	if ($iamguest && $enable_guestposting == 0) { &fatal_error("not_logged_in"); }
	if (!$staff && $speedpostdetection && ${$uid.$username}{'spamcount'} >= $post_speed_count) {
		$detention_time = ${$uid.$username}{'spamtime'} + $spd_detention_time;
		if($date <= $detention_time){
			$detention_left = $detention_time - $date;
			&fatal_error("speedpostban");
		} else {
			${$uid.$username}{'spamcount'} = 0;
			&UserAccount($username,"update");
		}
	}
	if ($currentboard eq '' && !$iamguest) { &fatal_error("no_access"); }
	my ($filetype_info, $filesize_info);
	my ($subtitle, $x, $mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate, $msubject, $mreplyno, $mip, $mmessage, $mns);
	my $quotemsg = $INFO{'quote'};
	$threadid = $INFO{'num'};

	($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $yyThreadLine);

	## only if bypass switched on
	if ($mstate =~ /l/i) { &fatal_error('topic_locked') unless ($bypass_lock_perm && &checkUserLockBypass) }
	#if ($mstate =~ /a/i && !$iamadmin && !$iamgmod) { &fatal_error('no_access'); }

	# Determine category
	$curcat = ${$uid.$currentboard}{'cat'};
	&BoardTotals("load", $currentboard);

	# Figure out the name of the category
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	($cat, $catperms) = split(/\|/, $catinfo{$curcat});
	&ToChars($cat);

	$pollthread = 0;
	$postthread = 0;
	$INFO{'title'} =~ tr/+/ /;

	if    ($INFO{'title'} eq 'CreatePoll') { $pollthread = 1; $t_title = $post_polltxt{'1a'}; }
	elsif ($INFO{'title'} eq 'AddPoll')    { $pollthread = 2; $t_title = $post_polltxt{'2a'}; }
	elsif ($INFO{'title'} eq 'PostReply')  { $postthread = 2; $t_title = $display_txt{'116'}; }
	else { $postthread = 1; $t_title = $post_txt{'33'}; }
	if ($FORM{'title'} eq 'PostReply')  { $postthread = 2;}
	if ($pollthread == 2 && $useraddpoll == 0) { &fatal_error("no_access"); }

	$name_field = $iamguest ? qq~      <tr>
    <td class="windowbg" align="left" width="23%"><label for="name"><b>$post_txt{'68'}:</b></label></td>
    <td class="windowbg" align="left" width="77%"><input type="text" name="name" id="name" size="25" value="$FORM{'name'}" maxlength="25" tabindex="2" /></td>
      </tr>~
	  : qq~~;

	$email_field = $iamguest ? qq~      <tr>
    <td class="windowbg" width="23%"><label for="email"><b>$post_txt{'69'}:</b></label></td>
    <td class="windowbg" width="77%"><input type="text" name="email" id="email" size="25" value="$FORM{'email'}" maxlength="40" tabindex="3" /></td>
      </tr>~
	  : qq~~;

	if ($iamguest && $gpvalid_en) {
		&validation_code;
		$verification_field = $verification eq ''
		? qq~
			<tr>
				<td class="windowbg" width="23%" valign="top"><label for="verification"><b>$floodtxt{'1'}:</b></label></td>
				<td class="windowbg" width="77%">$showcheck<br /><label for="verification"><span class="small">$floodtxt{'casewarning'}</span></label></td>
			</tr>
			<tr>
				<td class="windowbg" width="23%" valign="top"><label for="verification"><b>$floodtxt{'3'}:</b></label></td>
				<td class="windowbg" width="77%">
				<input type="text" maxlength="30" name="verification" id="verification" size="30" />
				</td>
			</tr>
		~
		: qq~~;
	}

	$sub = '';
	$settofield = 'subject';
	if ($threadid ne '') {
		unless (ref($thread_arrayref{$threadid})) {
			@{$thread_arrayref{$threadid}} = &read_DBorFILE(0,'',$datadir,$threadid,'txt');
		}
		if ($quotemsg ne '') {
			($msubject, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $mmessage, $mns) = split(/\|/, ${$thread_arrayref{$threadid}}[$quotemsg]);
			$message = $mmessage;
			$message =~ s~<br.*?>~\n~ig;
			$message =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/ig;
			if (!$nestedquotes) {
				$message =~ s~\n{0,1}\[quote([^\]]*)\](.*?)\[/quote([^\]]*)\]\n{0,1}~\n~isg;
			}
			$mname ||= $musername || $post_txt{'470'};
			my $hidename = $musername;
			$hidename = $mname if $musername eq 'Guest';
			$hidename = &cloak($hidename) if $do_scramble_id;
			$usernames_life_quote{$hidename} = $mname; # for display names in Quotes in LivePreview
			my $maxlengthofquote = $MaxMessLen - length(qq~[quote author=$hidename link=$threadid/$quotemsg#$quotemsg date=$mdate\]\[/quote\]\n~) - 3;
			my $mess_len = $message;
			&ToChars($mess_len);
			$mess_len =~ s/[\r\n ]//ig;
			$mess_len =~ s/&#\d{3,}?\;/X/ig;
			if (length $mess_len >= $maxlengthofquote) {
				&LoadLanguage('Error');
				&alertbox($error_txt{'quote_too_long'});
				$message = substr($message, 0, $maxlengthofquote) . '...';
			}
			undef $mess_len;
			$message = qq~[quote author=$hidename link=$threadid/$quotemsg#$quotemsg date=$mdate\]$message\[/quote\]\n~;
			if ($mns eq 'NS') { $nscheck = qq~ checked="checked"~; }
		} else {
			($msubject, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $mmessage, $mns) = split(/\|/, ${$thread_arrayref{$threadid}}[0]);
		}
		$msubject =~ s/\bre:\s+//ig;
		$sub = "Re: $msubject";
		$settofield = 'message';
	}

	if ($ENV{'HTTP_USER_AGENT'} =~ /(MSIE) (\d)/) {
		if ($2 >= 7.0) { $iecopycheck = ''; } else { $iecopycheck = qq~ checked="checked"~; }
	}
	$submittxt   = "$post_txt{'105'}";
	$destination = "post2";
	$icon        = "xx";
	$is_preview  = 0;
	$post        = "post";
	$prevmain    = "";
	$preview     = "preview";
	$yytitle     = "$t_title" unless $Quick_Post;
	&Postpage;
	&doshowthread unless $Quick_Post;
	if (%usernames_life_quote) { # for display names in Quotes in LivePreview
		$yymain .= qq~
	<script language="JavaScript" type="text/javascript">
	<!-- //
		~ . join(';', map { qq~LivePrevDisplayNames['$_'] = "$usernames_life_quote{$_}"~ } keys %usernames_life_quote) . qq~;
	// -->
	</script>\n~;
	}
	&template;
}

##  post message page
sub Postpage {
	my $extra;
	my ($filetype_info, $filesize_info, $extensions);
	$extensions = join(" ", @ext);
	$filetype_info = $checkext == 1 ? qq~$fatxt{'2'} $extensions~ : qq~$fatxt{'2'} $fatxt{'4'}~;
	$filesize_info = $limit != 0    ? qq~$fatxt{'3'} $limit KB~   : qq~$fatxt{'3'} $fatxt{'5'}~;
	$normalquot = $post_txt{'599'};
	$simpelquot = $post_txt{'601'};
	$simpelcode = $post_txt{'602'};
	$edittext   = $post_txt{'603'};
	if (!$fontsizemax) { $fontsizemax = 72; }
	if (!$fontsizemin) { $fontsizemin = 6; }

	if ($postid eq 'Poll')  { $sub = "$post_txt{'66a'}"; }

	$message =~ s~<\/~\&lt\;/~isg;
	&ToChars($message);
	$message = &Censor($message);
	&ToChars($sub);
	$sub = &Censor($sub);

	if ($action eq "modify" || $action eq "modify2") {
		$displayname = qq~$mename~;
	} else {
		$displayname = ${$uid.$username}{'realname'};
	}
	require "$sourcedir/ContextHelp.pl";
	&ContextScript("post");
	$yymain .= $ctmain;

	# this defines what the top area of the post box will look like: option 1 ) IM area
	# option 2) all other post areas
	#  im stuff now separate
	if ($postid ne 'Poll' && $destination ne 'modalert2' && $destination ne 'guestpm2') {
		$extra = qq~
	<tr id="feature_status_1">
		<td class="windowbg" width="23%"><label for="icon"><b>$post_txt{'71'}:</b></label></td>
		<td width="77%" class="windowbg">
			<select name="icon" id="icon" onchange="showimage(); updatTopic();">
			<option value="xx"$ic1>$post_txt{'281'}</option>
			<option value="thumbup"$ic2>$post_txt{'282'}</option>
			<option value="thumbdown"$ic3>$post_txt{'283'}</option>
			<option value="exclamation"$ic4>$post_txt{'284'}</option>
			<option value="question"$ic5>$post_txt{'285'}</option>
			<option value="lamp"$ic6>$post_txt{'286'}</option>
			<option value="smiley"$ic7>$post_txt{'287'}</option>
			<option value="angry"$ic8>$post_txt{'288'}</option>
			<option value="cheesy"$ic9>$post_txt{'289'}</option>
			<option value="grin"$ic10>$post_txt{'290'}</option>
			<option value="sad"$ic11>$post_txt{'291'}</option>
			<option value="wink"$ic12>$post_txt{'292'}</option>
			</select>
			<img src="$defaultimagesdir/$icon.gif" name="icons" border="0" hspace="15" alt="" />
		</td>
	</tr>
	 	~;
		if ($iamguest && $threadid ne '') { $settofield = "name"; }
	}

	if ($pollthread && $iamguest) { $guest_vote = 1; }
	if ($pollthread == 2) { $settofield = "question"; }

	# this defines if the notify on reply is shown or not.
	if ($iamguest || $destination eq "modalert2" || $destination eq "guestpm2") {
		$notification = '';
	} else {
		# check if you are already being notified and if so we check the checkbox.
		# if the mail file exists then we have to check it otherwise we continue on
		my $notify = "";
		my $hasnotify = 0;
		$notifytext = qq~$post_txt{'750'}~;
		if (!$FORM{'notify'} && !exists $FORM{'hasnotify'}) {
			&ManageThreadNotify("load", $threadid);
			if (exists $thethread{$username}) {
				$notify    = qq~ checked="checked"~;
				$hasnotify = 1;
			}
			undef %thethread;

			&ManageBoardNotify("load", $currentboard);
			if (exists $theboard{$username} && (split(/\|/, $theboard{$username}))[1] == 2) {
				$notify     = qq~ disabled="disabled" checked="checked"~;
				$hasnotify  = 2;
				$notifytext = qq~$post_txt{'132'}~;
			}
			undef %theboard;

		} else {
			$notify = qq~ checked="checked"~ if $FORM{'notify'} eq 'x';
			$hasnotify = $FORM{'hasnotify'};
			if ($hasnotify == 2) {
				$notify     = qq~ disabled="disabled" checked="checked"~;
				$notifytext = qq~$post_txt{'132'}~;
			}
		}


		if ($postid ne 'Poll') {
			$notification = qq~
	<tr id="feature_status_2">
		<td width="23%"><label for="notify"><b>$post_txt{'131'}:</b></label></td>
		<td width="77%"><input type="hidden" name="hasnotify" value="$hasnotify" /><input type="checkbox" name="notify" id="notify" value="x"$notify /> <span class="small"><label for="notify">$notifytext</label></span></td>
	</tr>~;
		}
	}

	#add to favorites checkbox code
	$favoriteadd = '';
	if (!$iamguest && $currentboard ne $annboard && $destination ne 'modalert2') {
		$favoritetext = $post_txt{'notfav'};
		require "$sourcedir/Favorites.pl";
		$nofav = &IsFav($threadid, '', 1);
		if ($FORM{'favorite'}) {
			$favorite = qq~ checked="checked"~;
		}
		if (!$nofav) {
			$favorite = qq~ disabled="disabled" checked="checked"~;
			$favoritetext = $post_txt{'alreadyfav'};
			$hasfavorite = 1;
		} elsif ($nofav == 2){
			$favorite = qq~ disabled="disabled"~;
			$favoritetext = $post_txt{'maximumfav'};
		}
		$favoriteadd = qq~
	<tr id="feature_status_3">
		<td width="23%"><label for="favorite"><b>$post_txt{'favorite'}:</b></label></td>
		<td width="77%"><input type="checkbox" name="favorite" id="favorite" value="x"$favorite /> <span class="small"><label for="favorite">$favoritetext</label></span></td>
	</tr>~;
	}

	if (!$sub) { $subtitle = "<i>$post_txt{'33'}</i>"; }
	else { $subtitle = "<i>$sub</i>"; }
	# this is shown every post page except the IM area.
	if ($destination ne 'modalert2' && $destination ne 'guestpm2' && !$Quick_Post) {
		if ($threadid) {
			$threadlink = qq~<a href="$scripturl?num=$threadid" class="nav">$subtitle</a>~;
		} else {
			$threadlink = "$subtitle";
		}
		&ToChars($boardname);
		&ToChars($cat);
		$yynavigation = qq~&rsaquo; <a href="$scripturl?catselect=$catid" class="nav">$cat</a> &rsaquo; <a href="$scripturl?board=$currentboard" class="nav">$boardname</a> &rsaquo; $t_title ( $threadlink )~;
	} elsif (!$Quick_Post) {
		$yynavigation = qq~&rsaquo; $t_title~;
	}
	#this is the end of the upper area of the post page.
	$yymain .= qq~

<script language="JavaScript1.2" type="text/javascript">
<!--

function alertqq() {
	alert("$post_txt{'alertquote'}");
}
function quick_quote_confirm(ahref) {
	if (document.postmodify.message.value == "") {
		window.location.href = ahref;
	} else {
		var Check = confirm('$post_txt{'quote_confirm'}');
		if (Check == true) {
			window.location.href = ahref;
		} else {
			document.postmodify.message.focus();
		}
	}
}

var postas = '$post';
function checkForm(theForm) {
	var isError = 0;
	var msgError = "$post_txt{'751'}\\n";
	if (navigator.appName == "Microsoft Internet Explorer" && document.getElementById('iecopy').checked == true) { theForm.message.createTextRange().execCommand("Copy"); }
	~ . ($iamguest && $post ne "imsend" && $post ne "imsend2" ? qq~if (theForm.name.value == "" || theForm.name.value == "_" || theForm.name.value == " ") { msgError += "\\n - $post_txt{'75'}"; if (isError == 0) isError = 2; }
	if (theForm.name.value.length > 25)  { msgError += "\\n - $post_txt{'568'}"; if (isError == 0) isError = 2; }
	if (theForm.email.value == "") { msgError += "\\n - $post_txt{'76'}"; if (isError == 0) isError = 3; }
	if (! checkMailaddr(theForm.email.value)) { msgError += "\\n - $post_txt{'500'}"; if (isError == 0) isError = 3; }~ : qq~if (postas == "imsend" || postas == "imsend2") {
		if (theForm.toshow.options.length == 0 ) { msgError += "\\n - $post_txt{'752'}"; isError = 1; }
		else { selectNames(); }

	}~) . qq~

	if (theForm.subject.value == "") { msgError += "\\n - $post_txt{'77'}"; if (isError == 0) isError = 4; }
	else if ($checkallcaps && theForm.subject.value.search(/[A-Z]{$checkallcaps,}/g) != -1) {
		if (isError == 0) { msgError = " - $post_txt{'79'}"; isError = 4; }
		else { msgError += "\\n - $post_txt{'79'}"; }
	}
	if (theForm.message.value == "") { msgError += "\\n - $post_txt{'78'}"; if (isError == 0) isError = 5; }
	else if ($checkallcaps && theForm.message.value.search(/[A-Z]{$checkallcaps,}/g) != -1) {
		if (isError == 0) { msgError = " - $post_txt{'79'}"; isError = 5; }
		else { msgError += "\\n - $post_txt{'79'}"; }
	}
	if (isError > 0) {
		alert(msgError);
		if (isError == 1) imWin();
		else if (isError == 2) theForm.name.focus();
		else if (isError == 3) theForm.email.focus();
		else if (isError == 4) theForm.subject.focus();
		else if (isError == 5) theForm.message.focus();
		return false;
	}
	return true
}

//-->
</script>

~;

	# if this is an IM from the admin or to groups declare where it goes.
	if ($INFO{'adminim'} || $INFO{'action'} eq "imgroups") {
		$yymain .= qq~<form action="$scripturl?action=imgroups" method="post" name="postmodify" onsubmit="return submitproc()">~;
	} else {
		if ($curnum) { $thecurboard = qq~num=$curnum\;action=$destination~; }
		elsif ($destination eq "guestpm2") { $thecurboard = qq~action=$destination~; }
		else { $thecurboard = qq~board=$currentboard\;action=$destination~; }
		
		# Change the target of the form submit to the parent if this is a pop up
		$target_pop_up = $INFO{'popup'} ? qq~target="_parent"~ : "";
		if (&AccessCheck($currentboard, 4) eq 'granted' && $allowattach && ${$uid.$currentboard}{'attperms'} == 1 && -d "$uploaddir" && $action =~ /^(post|modify)2?$/ && (($allowguestattach == 0 && !$iamguest) || $allowguestattach == 1)) {
			$yymain .= qq~<form action="$scripturl?$thecurboard" $target_pop_up method="post" id="postmodify" name="postmodify" enctype="multipart/form-data" onsubmit="if(!checkForm(this)) {return false} else {return submitproc()}">~;
		} else {
			$yymain .= qq~<form action="$scripturl?$thecurboard" $target_pop_up method="post" id="postmodify" name="postmodify" enctype="application/x-www-form-urlencoded" onsubmit="if(!checkForm(this)) {return false} else {return submitproc()}">~;
		}
	}
	if ($postthread == 2) { $yymain .= qq~<input type="hidden" id="title" name="PostReply" value="title" />~; }
	# this declares the beginning of the UBBC section
	$yymain .= qq~

	<script language="JavaScript1.2" src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
	<script language="JavaScript1.2" type="text/javascript">
	<!--
	~;

	$moresmilieslist = '';
	$more_smilie_array = '';
	$i = 0;
	if ($showadded == 1) {
		while ($SmilieURL[$i]) {
			if ($SmilieURL[$i] =~ /\//i) { $tmpurl = $SmilieURL[$i]; }
			else { $tmpurl = qq~$imagesdir/$SmilieURL[$i]~; }
			$moresmilieslist .= qq~				document.write('<img src="$tmpurl" align="bottom" alt="$SmilieDescription[$i]" title="$SmilieDescription[$i]" border="0" onclick="javascript: MoreSmilies($i);" style="cursor: pointer;" />$SmilieLinebreak[$i] ');\n~;
			$tmpcode = $SmilieCode[$i];
			$tmpcode =~ s/\&quot;/"+'"'+"/g;    #" Adding that because if not it screws up my syntax view'
			&FromHTML($tmpcode);
			$tmpcode =~ s/&#36;/\$/g;
			$tmpcode =~ s/&#64;/\@/g;
			$more_smilie_array .= qq~" $tmpcode", ~;
			$i++;
		}
	}

	if ($showsmdir == 1) {
		opendir(DIR, "$smiliesdir");
		@contents = readdir(DIR);
		closedir(DIR);
		foreach $line (sort { uc($a) cmp uc($b) } @contents) {
			($name, $extension) = split(/\./, $line);
			if ($extension =~ /gif/i || $extension =~ /jpg/i || $extension =~ /jpeg/i || $extension =~ /png/i) {
				if ($line !~ /banner/i) {
					$moresmilieslist .= qq~				document.write('<img src="$smiliesurl/$line" align="bottom" alt="$name" title="$name" border="0" onclick="javascript: MoreSmilies($i);" style="cursor: hand;" />$SmilieLinebreak[$i] ');\n~;
					$more_smilie_array .= qq~" [smiley=$line]", ~;
					$i++;
				}
			}
		}
	}

	$more_smilie_array .= qq~""~;

	$yymain .= qq~
	moresmiliecode = new Array($more_smilie_array)
	function MoreSmilies(i) {
		AddTxt=moresmiliecode[i];
		AddText(AddTxt);
	}
	~;

	if ($smiliestyle == 1) { $smiliewinlink = qq~$scripturl?action=smilieput~; }
	else { $smiliewinlink = qq~$scripturl?action=smilieindex~; }

	$yymain .= qq~
	function smiliewin() {
		window.open("$smiliewinlink", 'list', 'width=$winwidth, height=$winheight, scrollbars=yes');
	}
	~;

	if ($destination ne 'modalert2' && $destination ne 'guestpm2') {
		$yymain .= qq~
	function showimage() {
		document.images.icons.src="$imagesdir/"+document.postmodify.icon.options[document.postmodify.icon.selectedIndex].value+".gif";
	}~;
	}
	
	# no round corners if this is a popup
	if (!$INFO{'popup'}) {
		$roundtopright = qq~class="round_top_right"~;
		$roundtopleft = qq~class="round_top_left"~;
		$roundbottomright = qq~class="round_bottom_right"~;
		$roundbottomleft = qq~class="round_bottom_left"~;
	}
	
	# Add a call in here to resize the popup when collapsable features are altered
	$call_pop_up_resize = qq~ResizeIFrame();~;

	$yymain .= qq~
//-->
</script>
<input type="hidden" name="threadid" value="$threadid" />
<input type="hidden" name="postid" value="$postid" />
<input type="hidden" name="info" value="$idinfo" />
<input type="hidden" name="mename" value="$mename" />
<input type="hidden" name="post_entry_time" value="$date" />
<input type="hidden" name="virboard" value="$INFO{'virboard'}$FORM{'virboard'}" />

<div style="width:100%">
<table class="tabtitle" border="0" width="100%" cellpadding="3" cellspacing="0">
	<tr>
		<td $roundtopleft height="18" width="98%">
			<img src="$imagesdir/$icon.gif" name="icons2" border="0" alt="" style="vertical-align:middle;" /> $yytitle
		</td>
		<td $roundtopright width="1%">&nbsp;</td>
	</tr>
</table>
<div class="bordercolor">
<table border="0" width="100%" cellpadding="3" cellspacing="0" style="table-layout: fixed;">
~;

	$iammod = 0;
	if (keys(%moderators) > 0) {
		while ($_ = each(%moderators)) {
			if ($username eq $_) { $iammod = 1; }
		}
	}
	if (keys(%moderatorgroups) > 0) {
		while ($_ = each(%moderatorgroups)) {
			if (${$uid.$username}{'position'} eq $_) { $iammod = 1; }
			foreach $memberaddgroups (split(/,/, ${$uid.$username}{'addgroups'})) {
				if ($memberaddgroups eq $_) { $iammod = 1; last; }
			}
		}
	}

	if ($threadid && (!$Quick_Post || $is_preview) && $postthread == 2 && $username ne "Guest") {
		my ($reptime, $repuser, $isreplying, @tmprepliers, $isrep, $template_viewers, $topviewers);
		chomp(@repliers);
		for (my $i = 0; $i < @repliers; $i++) {
			($reptime, $repuser, $isreplying) = split(/\|/, $repliers[$i]);
			next if ($date - $reptime) > 600;
			if ($repuser eq $username) { push(@tmprepliers, qq~$date|$repuser|1~); $isrep = 1; $isreplying = 1;}
			else { push(@tmprepliers, $repliers[$i]); }
			if ($isreplying) {
				&LoadUser($repuser);
				$template_viewers .= qq~$link{$repuser}, ~;
				$topviewers++;
			}
		}
		if (!$isrep) {
			push(@tmprepliers, qq~$date|$username|1~);
			$template_viewers .= qq~$link{$username}, ~;
			$topviewers++;
		}
		&MessageTotals("load", $curnum);
		@repliers = @tmprepliers;
		&MessageTotals("update", $curnum);

		if (($showtopicviewers == 1 && $staff) || ($showtopicviewers == 2 && !$iamguest) || $showtopicviewers == 3) {
			$template_viewers =~ s/\, \Z/\./;
			$yymain .= qq~
	<tr>
		<td class="windowbg" valign="middle" align="left">
			$display_txt{'646'} ($topviewers): $template_viewers
		</td>
	</tr>~;
		}
	}

	$yymain .= qq~
</table>
	~;

	if ($pollthread) {
		$maxpq          ||= 60;
		$maxpo          ||= 50;
		$maxpc          ||= 0;
		$numpolloptions ||= 8;
		$vote_limit     ||= 0;
		$pie_radius     ||= 100;

		if ($iamadmin || $iamgmod) {
			$scchecked = ' checked="checked"' if $threadid == (&read_DBorFILE(1,'',$datadir,'poll','showcase'))[0];
		}
		if ($guest_vote)   { $gvchecked = ' checked="checked"'; }
		if ($hide_results) { $hrchecked = ' checked="checked"'; }
		if ($multi_choice) { $mcchecked = ' checked="checked"'; }
		if ($pie_legends)  { $legchecked = ' checked="checked"'; }

		$yymain .= qq~
<table border="0" width="100%" cellpadding="3" cellspacing="0" class="windowbg" style="table-layout: fixed;">
	<tr>
		<td width="250" class="catbg"><label for="question"><b>$post_polltxt{'6'}:</b></label></td>
		<td width="240" class="catbg">&nbsp;</td>
		<td width="60" class="catbg">&nbsp;</td>
		<td width="60" class="catbg">&nbsp;</td>
		<td class="catbg">&nbsp;</td>
	</tr>
	<tr>
		<td class="windowbg2" colspan="5" style="font-size: 3px;">&nbsp;</td>
	</tr>
	<tr>
	<td align="left" class="windowbg2">&nbsp;</td>
	<td colspan="4" align="left" class="windowbg2">
		<input type="text" size="60" name="question" id="question" value="$poll_question" maxlength="$maxpq" />
		<input type="hidden" name="pollthread" value="$pollthread" />
	</td>
	</tr>
	<tr>
		<td class="windowbg2" colspan="5" style="font-size: 3px;">&nbsp;</td>
	</tr>
	<tr>
		<td align="left" class="catbg"><b>$post_polltxt{'polloptions'}</b></td>
		<td align="left" class="catbg"><b>$post_polltxt{'polloptionstext'}</b></td>
		<td align="center" class="catbg"><b>$post_polltxt{'pieslicecolor'}</b></td>
		<td align="center" class="catbg"><b>$post_polltxt{'pieslicesplit'}</b></td>
		<td class="catbg">&nbsp;</td>
	</tr>
	<tr>
		<td class="windowbg2" colspan="5" style="font-size: 3px;">&nbsp;</td>
	</tr>~;

		$piecolarray = qq~["",~;
		for (my $i = 1; $i <= $numpolloptions; $i++) {
			if ($split[$i]) { $splitchecked[$i] = ' checked="checked"'; }
			if($FORM{"slicecol$i"}) { $slicecolor[$i] = $FORM{"slicecol$i"}; }
			$yymain .= qq~
	<tr>
		<td align="right" class="windowbg2"><label for="option$i"> &nbsp; $post_polltxt{'7'} $i: &nbsp;</label></td>
		<td align="left" class="windowbg2">
			<input type="text" size="35" maxlength="$maxpo" name="option$i" id="option$i" value="$options[$i]" />
		</td>
		<td align="center" class="windowbg2">
			<input type="text" size="3" name="slicecolor$i" id="slicecolor$i" value="" style="background-color: $slicecolor[$i]; border: 1px outset $slicecolor[$i]; cursor: pointer;" readonly="readonly" onclick="getSlicecolor($i)" />
			<input type="hidden" name="slicecol$i" id="slicecol$i" value="$slicecolor[$i]" />
		</td>
		<td align="center" class="windowbg2">
			<input type="checkbox" name="split$i" value="1"$splitchecked[$i] /> <span  class="small">$post_polltxt{'splitslice'}</span>
		</td>
		<td align="left" class="windowbg2">
			&nbsp;
		</td>
	</tr>~;
			$piecolarray .= qq~"$slicecolor[$i]", ~;
		}
		$piecolarray =~ s/\, $//i;
		$piecolarray .= qq~]~;

		if ($maxpc > 0) {
			$yymain .= qq~
	<tr>
		<td valign=top class="windowbg2"><b>$post_polltxt{'59'}:</b></td>
		<td class="windowbg2" colspan="4"><textarea name="poll_comment" rows="3" cols="60" wrap="soft" onkeyup="if (document.postmodify.poll_comment.value.length > $maxpc) {document.postmodify.poll_comment.value = document.postmodify.poll_comment.value.substring(0,$maxpc)}">$poll_comment</textarea></td>
	</tr>~;
		}

		if ($poll_end) {
			my $x = $poll_end - $date;
			if ($x <= 0) {
				$poll_end_min = 1;
			} else {
				$poll_end_days = int($x / 86400);
				$poll_end_min = int(($x - ($poll_end_days * 86400)) / 60);
			}
		}

		$yymain .= qq~
	<tr>
		<td class="windowbg2" colspan="5" style="font-size: 3px;">
			<script language="JavaScript1.2" type="text/javascript">
			<!--
			var tmpslicecolor;
			var itohex = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"];
			var slice_col = $piecolarray;
			var defslice_col = new Array();
			function tohex(i) {
				a2 = ''
				ihex = Math.floor(eval(i +'/16'));
				idiff = eval(i + '-(' + ihex + '*16)')
				a2 = itohex[idiff] + a2;
				while( ihex >= 16) {
					itmp = Math.floor(eval(ihex +'/16'));
					idiff = eval(ihex + '-(' + itmp + '*16)');
					a2 = itohex[idiff] + a2;
					ihex = itmp;
				} 
				a1 = itohex[ihex];
				return a1 + a2;
			}

			for (var tz = 0; tz < 256; tz += 63)
				for (var ty = 0; ty < 256; ty += 85)
					for (var tx = 0; tx < 256; tx += 127) defslice_col.push('#' + tohex(tx) + tohex(ty) + tohex(tz));

			for(var i = 1; i <= $numpolloptions; i++) {
				if(!slice_col[i]) slice_col[i] = defslice_col[i]
				document.getElementById('slicecolor' + i).style.backgroundColor = slice_col[i];
				document.getElementById('slicecolor' + i).style.borderColor = slice_col[i];
				document.getElementById('slicecol' + i).value = slice_col[i];
			}

			function getSlicecolor(slicenum) {
				tmpslicecolor = slicenum;
				window.open('$scripturl?action=palette;task=templ', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no');
			}

			function previewColor(newsilcecolor) {
				document.getElementById('slicecolor' + tmpslicecolor).style.backgroundColor = newsilcecolor;
				document.getElementById('slicecolor' + tmpslicecolor).style.borderColor = newsilcecolor;
				document.getElementById('slicecol' + tmpslicecolor).value = newsilcecolor;
			}
			//-->
			</script>
		</td>
	</tr>~ . ($poll_locked ? '' : qq~
	<tr>
		<td align="left" valign="top"><label for="poll_end_days"><b>$post_polltxt{'31'}</b></label></td>
		<td align="left" valign="top" colspan="4"><span  class="small"><input type="text" name="poll_end_days" id="poll_end_days" value="$poll_end_days" size="4" /> $post_polltxt{'31a'} <input type="text" name="poll_end_min" value="$poll_end_min" size="4" /> $post_polltxt{'31b'} $post_polltxt{'31c'}</span></td>
	</tr>~) . (($iamadmin || $iamgmod) ? qq~
	<tr>
		<td align="left" valign="top"><label for="scpoll"><b>$post_polltxt{'30'}</b></label></td>
		<td align="left" valign="top" colspan="4"><input type="checkbox" name="scpoll" id="scpoll" value="1"$scchecked /> <span  class="small"><label for="scpoll">$post_polltxt{'30a'}</label></span></td>
	</tr>~ : '') . qq~
	<tr>
		<td align="left" valign="top"><label for="guest_vote"><b>$post_polltxt{'32'}</b></label></td>
		<td align="left" valign="top" colspan="4"><input type="checkbox" name="guest_vote" id="guest_vote" value="1"$gvchecked /> <span  class="small"><label for="guest_vote">$post_polltxt{'54'}</label></span></td>
	</tr>
	<tr>
		<td align="left" valign="top"><label for="hide_results"><b>$post_polltxt{'26'}</b></label></td>
		<td align="left" valign="top" colspan="4"><input type="checkbox" name="hide_results" id="hide_results" value="1"$hrchecked /> <span  class="small"><label for="hide_results">$post_polltxt{'55'}</label></span></td>
	</tr>
	<tr>
		<td align="left" valign="top"><label for="multi_choice"><b>$post_polltxt{'58'}</b></label></td>
		<td align="left" valign="top" colspan="4"><input type="checkbox" name="multi_choice" id="multi_choice" value="1"$mcchecked /> <span  class="small"><label for="multi_choice">$post_polltxt{'56'}</label></span></td>
	</tr>
	<tr>
		<td align="left" valign="top"><label for="vote_limit"><b>$post_polltxt{'60'}</b></label></td>
		<td align="left" valign="top" colspan="4"><input type="text" size="6" name="vote_limit" id="vote_limit" value="$vote_limit" /> <span  class="small"><label for="vote_limit">$post_polltxt{'61'}</label></span></td>
	</tr>
	<tr>
		<td align="left" valign="top"><label for="pie_legends"><b>$post_polltxt{'pielegends'}</b></label></td>
		<td align="left" valign="top" colspan="4"><input type="checkbox" name="pie_legends" id="pie_legends" value="1"$legchecked /> <span  class="small"><label for="pie_legends">$post_polltxt{'pielegends_descr'}</label></span></td>
	</tr>
	<tr>
		<td align="left" valign="top"><label for="pie_radius"><b>$post_polltxt{'pieradius'}</b></label></td>
		<td align="left" valign="top" colspan="4"><input type="text" size="4" name="pie_radius" id="pie_radius" value="$pie_radius" /> <span  class="small"><label for="pie_radius">$post_polltxt{'pieradius_descr'}</label></span></td>
	</tr>
</table>~;
	}


	$yymain .= qq~
<table border="0" width="100%" cellpadding="3" cellspacing="0" class="windowbg" style="table-layout: fixed;">~;

	my ($threadclass,$hidestatus);
	if ($postid ne 'Poll') {
		$yymain .= qq~
		<tr>
			<td width="23%" align="left" valign="top" class="windowbg"><b>$post_txt{'507'}</b></td>
			<td width="77%" class="windowbg">$prevmain</td>
		</tr>
		~ if $prevmain;

		$yymain .= qq~
	<tr>
		<td width="23%" class="windowbg" valign="top">
			<div id="SaveInfo" style="height:16px;">
			<img name="prevwin" id="prevwin" src="$defaultimagesdir/cat_expand.gif" alt="$npf_txt{'01'}" title="$npf_txt{'01'}" border="0" style="cursor:pointer; cursor:hand;" onclick="enabPrev();" /> <b>$npf_txt{'04'}</b>
			</div>
		</td>
		<td width="77%" class="windowbg">
			<div id="savetable" class="bordercolor" style="padding:1px; width:100%; margin:auto; visibility:hidden;">
			<table border="0" width="100%" cellpadding="3" cellspacing="0" style="table-layout:fixed;">
			  <tr>
			    <td class="titlebg">
			     <div id="savetopic" style="height:0px; text-align:left; vertical-align:middle; font-weight:bold; overflow:auto;">&nbsp;</div>
			    </td>
			  </tr>
			  <tr>
			    <td class="windowbg2">
			     <div id="saveframe" class="message" style="height:0px; text-align:left; vertical-align:top; overflow:auto;">&nbsp;</div>
			    </td>
			  </tr>
			</table>
			</div>
		</td>
	</tr>~;

		$threadclass = 'thread';
		($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $yyThreadLine);
		if ($FORM{'topicstatus'}) { $thestatus = $FORM{'topicstatus'}; }
		else { $thestatus = $mstate; }
		if ($currentboard eq $annboard) {
			$threadclass = 'announcement';
		} else {
			if ($mreplies >= $VeryHotTopic) { $threadclass = 'veryhotthread'; }
			elsif ($mreplies >= $HotTopic) { $threadclass = 'hotthread'; }
		}
		if($action ne "modalert") {
			if ($staff) {
				my $stselect = $thestatus =~ /s/ ? qq~ selected="selected"~ : '';
				my $lcselect = $thestatus =~ /l/ ? qq~ selected="selected"~ : '';
				my $hdselect = $thestatus =~ /h/ ? qq~ selected="selected"~ : '';

				# check if user can bypass locked threads
				my $icanbypass = &checkUserLockBypass;
				my $size = $currentboard ne $annboard ? 3 : 2;
				$size-- unless $icanbypass;

				$yymain .= qq~
	<tr id="feature_status_4">
		<td class="windowbg" align="left" valign="top" width="23%"><label for="topicstatus"><b>$post_txt{'34'}:</b></label></td>
		<td class="windowbg" align="left" valign="middle" width="77%">
			<select multiple="multiple" name="topicstatus" id="topicstatus" size="$size" style="vertical-align: middle;" onchange="showtpstatus()">~ . ($currentboard ne $annboard ? qq~
			<option value="s"$stselect>$post_txt{'35'}</option>~ : "") . ($icanbypass ? qq~
			<option value="l"$lcselect>$post_txt{'36'}</option>~ : "") . qq~
			<option value="h"$hdselect>$post_txt{'37'}</option>
			</select>
			<img src="$imagesdir/$threadclass.gif" name="thrstat" border="0" hspace="15" alt="" style="vertical-align: middle;" />
		</td>
	</tr>~;

			} else {
				$hidestatus = qq~<input type="hidden" value="$thestatus" name="topicstatus" />~;
			}
		}
		$yymain .= qq~
	$extra
	$name_field
	$email_field
	$verification_field
	<tr>
		<td align="left" class="windowbg2" width="23%">
			<label for="subject"><b>$post_txt{'70'}:</b></label>
		</td>
		<td align="left" class="windowbg2" width="77%">
			<input type="text" name="subject" id="subject" value="$sub" size="50" maxlength="~ . ($set_subjectMaxLength + ($sub =~ /^Re: / ? 4 : 0)) . qq~" tabindex="1" style="width: 437px;" onkeyup="updatTopic()" />
		</td>
	</tr>
	<tr>
		<td class="windowbg2" width="23%" align="left" valign="top">
			<label for="message"><b>$post_txt{'72'}:</b></label><br /><span class="small">$post_txt{'resizedescript'}</span>
		</td>
		<td rowspan="~ . ((!$removenormalsmilies || ($showadded == 3 && $showsmdir != 2) || ($showsmdir == 3 && $showadded != 2)) ? 2 : 3) . qq~" valign="middle" class="windowbg2" width="77%">
		~;
		if ($enable_ubbc && $showyabbcbutt) {
			$yymain .= qq~
			<div style="float: left; width: 440px;">
			<script language="JavaScript1.2" type="text/javascript">
			<!--
			HAND = "style='cursor: pointer;'";
			HAND += " onmouseover='contextTip(event, this.alt)' onmouseout='contextTip(event, this.alt)' oncontextmenu='if(!showcontexthelp(this.src, this.alt)) return false;'";
			document.write('<div style="width: 437px; float: left;">');
			document.write("<img src='$imagesdir/url.gif' onclick='hyperlink();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'257'}' title='$post_txt{'257'}' border='0' />");
			document.write("<img src='$imagesdir/ftp.gif' onclick='ftp();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'434'}' title='$post_txt{'434'}' border='0' />");
			document.write("<img src='$imagesdir/img.gif' onclick='image();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'435'}' title='$post_txt{'435'}' border='0' />");
			document.write("<img src='$imagesdir/email2.gif' onclick='emai1();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'258'}' title='$post_txt{'258'}' border='0' />");
			document.write("<img src='$imagesdir/media.gif' onclick='flash();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'433'}' title='$post_txt{'433'}' border='0' />");
			document.write("<img src='$imagesdir/table.gif' onclick='table();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'436'}' title='$post_txt{'436'}' border='0' />");
			document.write("<img src='$imagesdir/tr.gif' onclick='trow();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'449'}' title='$post_txt{'449'}' border='0' />");
			document.write("<img src='$imagesdir/td.gif' onclick='tcol();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'437'}' title='$post_txt{'437'}' border='0' />");
			document.write("<img src='$imagesdir/hr.gif' onclick='hr();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'531'}' title='$post_txt{'531'}' border='0' />");
			document.write("<img src='$imagesdir/tele.gif' onclick='teletype();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'440'}' title='$post_txt{'440'}' border='0' />");
			document.write("<img src='$imagesdir/code.gif' onclick='selcodelang();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'259'}' title='$post_txt{'259'}' border='0' />");
			document.write("<img src='$imagesdir/quote2.gif' onclick='quote();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'260'}' title='$post_txt{'260'}' border='0' />");
			document.write("<img src='$imagesdir/edit.gif' onclick='edit();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'603'}' title='$post_txt{'603'}' border='0' />");
			document.write("<img src='$imagesdir/sup.gif' onclick='superscript();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'447'}' title='$post_txt{'447'}' border='0' />");
			document.write("<img src='$imagesdir/sub.gif' onclick='subscript();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'448'}' title='$post_txt{'448'}' border='0' />");
			document.write("<img src='$imagesdir/list.gif' onclick='bulletset();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'261'}' title='$post_txt{'261'}' border='0' />");
			document.write("<img src='$imagesdir/me.gif' onclick='me();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'604'}' title='$post_txt{'604'}' border='0' />");
			document.write("<img src='$imagesdir/move.gif' onclick='move();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'439'}' title='$post_txt{'439'}' border='0' />");
			document.write("<img src='$imagesdir/timestamp.gif' onclick='timestamp($date);' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'245'}' title='$post_txt{'245'}' border='0' /><br />");
			document.write('</div>');
			document.write('<div style="width: 115px; float: left;">');
			document.write("<img src='$imagesdir/bold.gif' onclick='bold();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'253'}' title='$post_txt{'253'}' border='0' />");
			document.write("<img src='$imagesdir/italicize.gif' onclick='italicize();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'254'}' title='$post_txt{'254'}' border='0' />");
			document.write("<img src='$imagesdir/underline.gif' onclick='underline();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'255'}' title='$post_txt{'255'}' border='0' />");
			document.write("<img src='$imagesdir/strike.gif' onclick='strike();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'441'}' title='$post_txt{'441'}' border='0' />");
			document.write("<img src='$imagesdir/highlight.gif' onclick='highlight();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'246'}' title='$post_txt{'246'}' border='0' />");
			document.write('</div>');
			document.write('<div style="width: 139px; float: left; text-align: center;">');
			document.write('<select name="fontface" id="fontface" onchange="if(this.options[this.selectedIndex].value) fontfce(this.options[this.selectedIndex].value);" style="width: 90px; margin-top: 2px; margin-left: 2px; margin-right: 1px; font-size: 9px;">');
			document.write('<option value="">Verdana</option>');
			document.write('<option value="">-\\-\\-\\-\\-\\-\\-\\-\\-</option>');
			document.write('<option value="Arial" style="font-family: Arial">Arial</option>');
			document.write('<option value="Bitstream Vera Sans Mono" style="font-family: Bitstream Vera Sans Mono">Bitstream</option>');
			document.write('<option value="Bradley Hand ITC" style="font-family: Bradley Hand ITC">Bradley Hand ITC</option>');
			document.write('<option value="Comic Sans MS" style="font-family: Comic Sans MS">Comic Sans MS</option>');
			document.write('<option value="Courier" style="font-family: Courier">Courier</option>');
			document.write('<option value="Courier New" style="font-family: Courier New">Courier New</option>');
			document.write('<option value="Georgia" style="font-family: Georgia">Georgia</option>');
			document.write('<option value="Impact" style="font-family: Impact">Impact</option>');
			document.write('<option value="Lucida Sans" style="font-family: Lucida Sans">Lucida Sans</option>');
			document.write('<option value="Microsoft Sans Serif" style="font-family: Microsoft Sans Serif">MS Sans Serif</option>');
			document.write('<option value="Papyrus" style="font-family: Papyrus">Papyrus</option>');
			document.write('<option value="Tahoma" style="font-family: Tahoma">Tahoma</option>');
			document.write('<option value="Tempus Sans ITC" style="font-family: Tempus Sans ITC">Tempus Sans ITC</option>');
			document.write('<option value="Times New Roman" style="font-family: Times New Roman">Times New Roman</option>');
			document.write('<option value="Verdana" style="font-family: Verdana">Verdana</option>');
			document.write('</select>');
			var fntoptions = ["6", "7", "8", "9", "10", "11", "12", "14", "16", "18", "20", "22", "24", "36", "48", "56", "72"]
			document.write('<select name="fontsize" id="fontsize" onchange="if(this.options[this.selectedIndex].value) fntsize(this.options[this.selectedIndex].value);" style="width: 39px; margin-top: 2px; margin-left: 1px; margin-right: 2px; font-size: 9px;">');
			document.write('<option value="">11</option>');
			document.write('<option value="">-\\-</option>');
			for(var i = 0; i < fntoptions.length; i++) {
				if(fntoptions[i] >= $fontsizemin && fntoptions[i] <= $fontsizemax) {
					if(fntoptions[i] == 11) document.write('<option value="11" selected="selected">11</option>');
					else document.write('<option value=' + fntoptions[i] + '>' + fntoptions[i] + '</option>');
				}
			}
			document.write('</select>');
			document.write('</div>');


			function selcodelang() {
				if (document.getElementById("codelang").style.display == "none")
				document.getElementById("codelang").style.display = "inline-block";
				else
				document.getElementById("codelang").style.display = "none";
				document.getElementById("codelang").style.zIndex = "100";

				var openbox = document.getElementsByTagName("div");
				for (var i = 0; i < openbox.length; i++) {
					if (openbox[i].className == "ubboptions" && openbox[i].id != "codelang") {
						openbox[i].style.display = "none";
					}
				}
			}

			function syntaxlang(lang, optnum) {
				AddSelText("[code"+lang+"]","[/code]");
				document.getElementById("codesyntax").options[optnum].selected = false;
				document.getElementById("codelang").style.display = "none";
			}

			function bulletset() {
				if (document.getElementById("bullets").style.display == "none")
				document.getElementById("bullets").style.display = "block";
				else
				document.getElementById("bullets").style.display = "none";
				document.getElementById("bullets").style.zIndex = "100";

				var openbox = document.getElementsByTagName("div");
				for (var i = 0; i < openbox.length; i++) {
					if (openbox[i].className == "ubboptions" && openbox[i].id != "bullets") {
						openbox[i].style.display = "none";
					}
				}
			}
		
			function showbullets(bullet) {
				AddSelText("[list "+bullet+"][*]", "\\n[/list]");
			}

			function olist() {
				AddSelText("[olist][*]", "\\n[/olist]");
			}
			function ulist() {
				AddSelText("[list][*]", "\\n[/list]");
			}

			// Palette
			var thistask = 'post';
			function tohex(i) {
				a2 = ''
				ihex = hexQuot(i);
				idiff = eval(i + '-(' + ihex + '*16)')
				a2 = itohex(idiff) + a2;
				while( ihex >= 16) {
					itmp = hexQuot(ihex);
					idiff = eval(ihex + '-(' + itmp + '*16)');
					a2 = itohex(idiff) + a2;
					ihex = itmp;
				} 
				a1 = itohex(ihex);
				return a1 + a2 ;
			}

			function hexQuot(i) {
				return Math.floor(eval(i +'/16'));
			}

			function itohex(i) {
				if( i == 0) { aa = '0' }
				else { if( i == 1 ) { aa = '1' }
				else { if( i == 2 ) { aa = '2' }
				else { if( i == 3 ) { aa = '3' }
				else { if( i == 4 ) { aa = '4' }
				else { if( i == 5 ) { aa = '5' }
				else { if( i == 6 ) { aa = '6' }
				else { if( i == 7 ) { aa = '7' }
				else { if( i == 8 ) { aa = '8' }
				else { if( i == 9 ) { aa = '9' }
				else { if( i == 10) { aa = 'a' }
				else { if( i == 11) { aa = 'b' }
				else { if( i == 12) { aa = 'c' }
				else { if( i == 13) { aa = 'd' }
				else { if( i == 14) { aa = 'e' }
				else { if( i == 15) { aa = 'f' }
				}}}}}}}}}}}}}}}
				return aa;
			}

			function ConvShowcolor(color) {
				if ( c=color.match(/rgb\\((\\d+?)\\, (\\d+?)\\, (\\d+?)\\)/i) ) {
					var rhex = tohex(c[1]);
					var ghex = tohex(c[2]);
					var bhex = tohex(c[3]);
					var newcolor = '#'+rhex+ghex+bhex;
				}
				else {
					var newcolor = color;
				}
				if(thistask == "post") showcolor(newcolor);
				if(thistask == "templ") previewColor(newcolor);
			}
			//-->
			</script>
			<div style="float: left; height: 22px; width: 91px;">
			<div style="height: 20px; width: 66px; padding-left: 1px; padding-top: 1px; margin-top: 1px; float: left;">
				<span style="float: left; background-color: #000000; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor('#000000')">&nbsp;</span>
				<span style="float: left; background-color: #333333; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor('#333333')">&nbsp;</span>
				<span style="float: left; background-color: #666666; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor('#666666')">&nbsp;</span>
				<span style="float: left; background-color: #999999; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor('#999999')">&nbsp;</span>
				<span style="float: left; background-color: #cccccc; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor('#cccccc')">&nbsp;</span>
				<span style="float: left; background-color: #ffffff; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor('#ffffff')">&nbsp;</span>
				<span id="defaultpal1" style="float: left; background-color: $pallist[0]; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
				<span id="defaultpal2" style="float: left; background-color: $pallist[1]; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
				<span id="defaultpal3" style="float: left; background-color: $pallist[2]; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
				<span id="defaultpal4" style="float: left; background-color: $pallist[3]; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
				<span id="defaultpal5" style="float: left; background-color: $pallist[4]; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
				<span id="defaultpal6" style="float: left; background-color: $pallist[5]; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
			</div>
			<div style="height: 22px; width: 23px; padding-left: 1px; float: right;">
				<img src="$imagesdir/palette1.gif" style="cursor: pointer" onclick="window.open('$scripturl?action=palette;task=post', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" alt="" border="0" />
			</div>
			</div>
			<script language="JavaScript1.2" type="text/javascript">
			<!--
			HAND = "style='cursor: pointer;'";
			HAND += " onmouseover='contextTip(event, this.alt)' onmouseout='contextTip(event, this.alt)' oncontextmenu='if(!showcontexthelp(this.src, this.alt)) return false;'";
			document.write('<div style="width: 92px; float: left;">');
			document.write("<img src='$imagesdir/pre.gif' onclick='pre();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'444'}' title='$post_txt{'444'}' border='0' />");
			document.write("<img src='$imagesdir/left.gif' onclick='left();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'445'}' title='$post_txt{'445'}' border='0' />");
			document.write("<img src='$imagesdir/center.gif' onclick='center();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'256'}' title='$post_txt{'256'}' border='0' />");
			document.write("<img src='$imagesdir/right.gif' onclick='right();' "+HAND+" align='top' width='23' height='22' alt='$post_txt{'446'}' title='$post_txt{'446'}' border='0' />");
			document.write('</div>');
			//-->
			</script>
			<noscript>
			<span class="small">$maintxt{'noscript'}</span>
			</noscript>
			</div>~;
		}

		if (!${$uid.$username}{'postlayout'}) {
			$pheight = 130; $pwidth = 425; $textsize = 10;
		} else {
			($pheight, $pwidth, $textsize, $col_row) = split(/\|/, ${$uid.$username}{'postlayout'});
		}
		$col_row ||= 0;
		if(!$textsize || $textsize < 6) { $textsize = 6; }
		if($textsize > 16) { $textsize = 16; }
		if($pheight > 400) { $pheight = 400; }
		if($pheight < 130) { $pheight = 130; }
		if($pwidth > 855) { $pwidth = 855; }
		if($pwidth < 425) { $pwidth = 425; }
		$mtextsize = $textsize . "pt";
		$mheight = $pheight . "px";
		$mwidth = $pwidth . "px";
		$dheight = ($pheight + 12) . "px";
		$dwidth = ($pwidth + 12) . "px";
		$jsdragwpos = $pwidth - 425;
		$dragwpos = ($pwidth - 425) . "px";
		$jsdraghpos = $pheight - 130;
		$draghpos = ($pheight - 130) . "px";

		$yymain .= qq~

			<div id="spell_container"></div>
			<div style="float: left; width: 99%;">
			<input type="hidden" name="messagewidth" id="messagewidth" value="$pwidth" />
			<input type="hidden" name="messageheight" id="messageheight" value="$pheight" />
			<div id="dragcanvas" style="position: relative; top: 0px; left: 0px; height: $dheight; width: $dwidth; border: 0; z-index: 1;">
			<textarea name="message" id="message" rows="8" cols="68" style="position: absolute; top: 0px; left: 0px; z-index: 2; height: $mheight; width: $mwidth; font-size: $mtextsize; padding: 5px; margin: 0px; visibility: visible;" onclick="storeCaret(this);" onkeyup="storeCaret(this);" onchange="storeCaret(this);" tabindex="4">$message</textarea>
			<div id="dragbgw" style="position: absolute; top: 0px; left: 437px; width: 3px; height: $dheight; border: 0; z-index: 3;">
			<img id="dragImg1" src="$defaultimagesdir/resize_wb.gif" class="drag" style="position: absolute; top: 0px; left: $dragwpos; z-index: 4; width: 3px; height: $dheight; cursor: e-resize;" alt= "" />
			</div>
			<div id="dragbgh" style="position: absolute; top: 142px; left: 0px; width: $dwidth; height: 3px; border: 0; z-index: 3;">
			<img id="dragImg2" src="$defaultimagesdir/resize_hb.gif" class="drag" style="position: absolute; top: $draghpos; left: 0px; z-index: 4; width: $dwidth; height: 3px; cursor: n-resize;" alt= "" />
			</div>
			<div class="ubboptions" id="bullets" style="position: absolute; top: -22px; left: 345px; width: 63px; border: 1px solid #666666; padding: 2px; text-align: center; background-color: #CCCCCC; display: none;">
			<input type="button" value="$npf_txt{'default'}" style="width: 56px; margin: 3px 0px 0px 0px; font-size: 9px; padding: 0px; text-align: center;" onclick="ulist(), bulletset()" /><br />
			<input type="button" value="$npf_txt{'ordered'}" style="width: 56px; margin: 3px 0px 3px 0px; font-size: 9px; padding: 0px; text-align: center;" onclick="olist(), bulletset()" /><br />
			<img src="$defaultimagesdir/bull-redball.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-redball'), bulletset()" /><img src="$defaultimagesdir/bull-greenball.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-greenball'), bulletset()" /><img src="$defaultimagesdir/bull-blueball.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-blueball'), bulletset()" /><img src="$defaultimagesdir/bull-blackball.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-blackball'), bulletset()" /><br />
			<img src="$defaultimagesdir/bull-redsq.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-redsq'), bulletset()" /><img src="$defaultimagesdir/bull-greensq.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-greensq'), bulletset()" /><img src="$defaultimagesdir/bull-bluesq.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-bluesq'), bulletset()" /><img src="$defaultimagesdir/bull-blacksq.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-blacksq'), bulletset()" /><br />
			<img src="$defaultimagesdir/bull-redpin.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-redpin'), bulletset()" /><img src="$defaultimagesdir/bull-greenpin.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-greenpin'), bulletset()" /><img src="$defaultimagesdir/bull-bluepin.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-bluepin'), bulletset()" /><img src="$defaultimagesdir/bull-blackpin.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-blackpin'), bulletset()" /><br />
			<img src="$defaultimagesdir/bull-redcheck.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-redcheck'), bulletset()" /><img src="$defaultimagesdir/bull-greencheck.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-greencheck'), bulletset()" /><img src="$defaultimagesdir/bull-bluecheck.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-bluecheck'), bulletset()" /><img src="$defaultimagesdir/bull-blackcheck.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-blackcheck'), bulletset()" /><br />
			<img src="$defaultimagesdir/bull-redarrow.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-redarrow'), bulletset()" /><img src="$defaultimagesdir/bull-greenarrow.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-greenarrow'), bulletset()" /><img src="$defaultimagesdir/bull-bluearrow.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-bluearrow'), bulletset()" /><img src="$defaultimagesdir/bull-blackarrow.gif" style="width: 8px; height: 8px; background-color: #CCCCCC; margin: 3px; cursor: pointer;" onclick="showbullets('bull-blackarrow'), bulletset()" /><br />
			</div>
			<div class="ubboptions" id="codelang" style="position: absolute; top: -22px; left: 230px; width: 92px; padding: 0px; background-color: #CCCCCC; display: none;">
				<select size="10" name="codesyntax" id="codesyntax" onchange="syntaxlang(this.options[this.selectedIndex].value, this.selectedIndex);" style="margin:0px; font-size: 9px; width: 92px;">
				<option value="" title="$npf_txt{'default'}">$npf_txt{'default'}</option>
				<option value=" c++" title="C++">C++</option>
				<option value=" css" title="CSS">CSS</option>
				<option value=" html" title="HTML">HTML</option>
				<option value=" java" title="Java">Java</option>
				<option value=" javascript" title="Javascript">Javascript</option>
				<option value=" pascal" title="Pascal">Pascal</option>
				<option value=" perl" title="Perl">Perl</option>
				<option value=" php" title="PHP">PHP</option>
				<option value=" sql" title="SQL">SQL</option>
				</select>
			</div>
			</div>
			<div style="float: left; width: 315px; text-align: left;"> 
			<img src="$imagesdir/green1.gif" name="chrwarn" height="8" width="8" border="0" vspace="0" hspace="0" alt="" align="middle" />
			<span class="small">$npf_txt{'03'} <input value="$MaxMessLen" size="3" name="msgCL" class="windowbg2" style="border: 0px; font-size: 11px; width: 40px; padding: 1px" readonly="readonly" /></span>
			</div>
			<div style="float: left; width: 127px; text-align: right;">
				<span class="small">$post_txt{'textsize'} <input value="$textsize" size="2" name="txtsize" id="txtsize" class="windowbg2" style="border: 0px; font-size: 11px; width: 15px; padding: 1px" readonly="readonly" />pt <img src="$imagesdir/smaller.gif" height="11" width="11" border="0" alt="" align="middle" onclick="sizetext(-1);" /><img src="$imagesdir/larger.gif" height="11" width="11" border="0" alt="" align="middle" onclick="sizetext(1);" /></span>
			</div>
			</div>
		</td>
	</tr>
	<tr>
		<td valign="top" class="windowbg2" width="23%">
		~;

		# SpellChecker start
		if ($enable_spell_check) {
			$yyinlinestyle .= qq~<link href="$yyhtml_root/googiespell/googiespell.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="$yyhtml_root/AJS.js"></script>
<script type="text/javascript" src="$yyhtml_root/googiespell/googiespell.js"></script>
<script type="text/javascript" src="$yyhtml_root/googiespell/cookiesupport.js"></script>~;
			my $userdefaultlang = (split(/-/, $abbr_lang))[0];
			$userdefaultlang ||= 'en';
			$yymain .= qq~
			<script type="text/javascript">
			<!--
			GOOGIE_DEFAULT_LANG = '$userdefaultlang';
			var googie1 = new GoogieSpell("$yyhtml_root/googiespell/", "$boardurl/Sources/SpellChecker.pl?lang=");
			googie1.lang_chck_spell = '$spell_check{'chck_spell'}';
			googie1.lang_revert = '$spell_check{'revert'}';
			googie1.lang_close = '$spell_check{'close'}';
			googie1.lang_rsm_edt = '$spell_check{'rsm_edt'}';
			googie1.lang_no_error_found = '$spell_check{'no_error_found'}';
			googie1.lang_no_suggestions = '$spell_check{'no_suggestions'}';
			googie1.setSpellContainer("spell_container");
			googie1.decorateTextarea("message");
			//-->
			</script>~;
		}
		# SpellChecker end

		if ($showadded == 2 || $showsmdir == 2) {
			$yymain .= qq~
			<script language="JavaScript1.2" type="text/javascript">
			<!--
			function Smiliextra() {
				AddTxt=smiliecode[document.postmodify.smiliextra_list.value];
				AddText(AddTxt);
			}~;

			$smilieslist = '';
			$smilie_url_array = '';
			$smilie_code_array = '';
			$i = 0;
			if ($showadded eq 2) {
				while ($SmilieURL[$i]) {
					$smilieslist .= qq~	document.write('<option value="$i"~ . ($SmilieDescription[$i] eq $showinbox ? ' selected="selected"' : '') . qq~>$SmilieDescription[$i]</option>');\n~;
					if ($SmilieURL[$i] =~ /\//i) { $tmpurl = $SmilieURL[$i]; }
					else { $tmpurl = qq~$defaultimagesdir/$SmilieURL[$i]~; }
					$smilie_url_array .= qq~"$tmpurl", ~;
					$tmpcode = $SmilieCode[$i];
					$tmpcode =~ s/\&quot;/"+'"'+"/g;    # "'
					&FromHTML($tmpcode);
					$tmpcode =~ s/&#36;/\$/g;
					$tmpcode =~ s/&#64;/\@/g;
					$smilie_code_array .= qq~" $tmpcode", ~;
					$i++;
				}
			}
			if ($showsmdir eq 2) {
				opendir(DIR, "$smiliesdir");
				@contents = readdir(DIR);
				closedir(DIR);
				foreach $line (sort { uc($a) cmp uc($b) } @contents) {
					($name, $extension) = split(/\./, $line);
					if ($extension =~ /gif/i || $extension =~ /jpg/i || $extension =~ /jpeg/i || $extension =~ /png/i) {
						if ($line !~ /banner/i) {
							$smilieslist .= qq~	document.write('<option value="$i"~ . ($name eq $showinbox ? ' selected="selected"' : '') . qq~>$name</option>');\n~;
							$smilie_url_array .= qq~"$smiliesurl/$line", ~;
							$smilie_code_array .= qq~" [smiley=$line]", ~;
							$i++;
						}
					}
				}
			}
			$smilie_url_array  .= qq~""~;
			$smilie_code_array .= qq~""~;

			$yymain .= qq~
			smilieurl = new Array($smilie_url_array)
			smiliecode = new Array($smilie_code_array)
			document.write('<table class="bordercolor" height="90" width="120" border="0" cellpadding="2" cellspacing="1" align="center"><tr>');
			document.write('<td height="15" align="center" valign="middle" class="titlebg"><span class="small"><b>$post_smiltxt{'1'}</b></span></td>');
			document.write('</tr><tr>');
			document.write('<td height="20" align="center" valign="top" class="windowbg2"><select name="smiliextra_list" onchange="document.images.smiliextra_image.src= smilieurl[document.postmodify.smiliextra_list.value]" style="width:114px; font-size:7pt;">');
			$smilieslist
			document.write('</select></td>');
			document.write('</tr><tr>');
			document.write('<td height="70" align="center" valign="middle" class="windowbg2"><img name="smiliextra_image" src="'+smilieurl[0]+'" alt="" border="0" onclick="javascript: Smiliextra();" style="cursor: pointer;"></td>');
			document.write('</tr><tr>');
			document.write('<td height="15" align="center" valign="middle" class="windowbg2"><span class="small"><a href="javascript: smiliewin();">$post_smiltxt{'17'}</a></span></td>');
			document.write('</tr></table>');
			document.images.smiliextra_image.src = smilieurl[document.postmodify.smiliextra_list.value];
			//-->
			</script>
			~;
		} else {
			$yymain .= qq~
			&nbsp;
			~;
		}

		$yymain .= qq~
		</td>
	</tr>
	<tr>
		<td class="windowbg2" width="23%" valign="bottom">
			<span  class="small"><img name="feature_col" id="feature_col" src="$defaultimagesdir/cat_collapse.gif" alt="$npf_txt{'collapse_features'}" title="$npf_txt{'collapse_features'}" border="0" style="cursor:pointer;" onclick="show_features(0);" /> $npf_txt{'features_text'}</span>
			<input type="hidden" name="col_row" id="col_row" value="$col_row" />~;

		$yymain .= qq~
		</td>
		<td width="77%" valign="middle" class="windowbg2">
			<script language="JavaScript1.2" type="text/javascript">
			<!--
			HAND = "style='cursor: pointer;'";
			document.write("<div style='float: left; width: 440px;'>");
			document.write("<img src='$imagesdir/smiley.gif' onclick='smiley();' "+HAND+" align='bottom' alt='$post_txt{'287'}' title='$post_txt{'287'}' border='0'> ");
			document.write("<img src='$imagesdir/wink.gif' onclick='wink();' "+HAND+" align='bottom' alt='$post_txt{'292'}' title='$post_txt{'292'}' border='0'> ");
			document.write("<img src='$imagesdir/cheesy.gif' onclick='cheesy();' "+HAND+" align='bottom' alt='$post_txt{'289'}' title='$post_txt{'289'}' border='0'> ");
			document.write("<img src='$imagesdir/grin.gif' onclick='grin();' "+HAND+" align='bottom' alt='$post_txt{'293'}' title='$post_txt{'293'}' border='0'> ");
			document.write("<img src='$imagesdir/angry.gif' onclick='angry();' "+HAND+" align='bottom' alt='$post_txt{'288'}' title='$post_txt{'288'}' border='0'> ");
			document.write("<img src='$imagesdir/sad.gif' onclick='sad();' "+HAND+" align='bottom' alt='$post_txt{'291'}' title='$post_txt{'291'}' border='0'> ");
			document.write("<img src='$imagesdir/shocked.gif' onclick='shocked();' "+HAND+" align='bottom' alt='$post_txt{'294'}' title='$post_txt{'294'}' border='0'> ");
			document.write("<img src='$imagesdir/cool.gif' onclick='cool();' "+HAND+" align='bottom' alt='$post_txt{'295'}' title='$post_txt{'295'}' border='0'> ");
			document.write("<img src='$imagesdir/huh.gif' onclick='huh();' "+HAND+" align='bottom' alt='$post_txt{'296'}' title='$post_txt{'296'}' border='0'> ");
			document.write("<img src='$imagesdir/rolleyes.gif' onclick='rolleyes();' "+HAND+" align='bottom' alt='$post_txt{'450'}' title='$post_txt{'450'}' border='0'> ");
			document.write("<img src='$imagesdir/tongue.gif' onclick='tongue();' "+HAND+" align='bottom' alt='$post_txt{'451'}' title='$post_txt{'451'}' border='0'> ");
			document.write("<img src='$imagesdir/embarassed.gif' onclick='embarassed();' "+HAND+" align='bottom' alt='$post_txt{'526'}' title='$post_txt{'526'}' border='0'> ");
			document.write("<img src='$imagesdir/lipsrsealed.gif' onclick='lipsrsealed();' "+HAND+" align='bottom' alt='$post_txt{'527'}' title='$post_txt{'527'}' border='0'> ");
			document.write("<img src='$imagesdir/undecided.gif' onclick='undecided();' "+HAND+" align='bottom' alt='$post_txt{'528'}' title='$post_txt{'528'}' border='0'> ");
			document.write("<img src='$imagesdir/kiss.gif' onclick='kiss();' "+HAND+" align='bottom' alt='$post_txt{'529'}' title='$post_txt{'529'}' border='0'> ");
			document.write("<img src='$imagesdir/cry.gif' onclick='cry();' "+HAND+" align='bottom' alt='$post_txt{'530'}' title='$post_txt{'530'}' border='0'> ");$moresmilieslist
			document.write("</div>");
			//-->
			</script>\n~ if !$removenormalsmilies && (!${$uid.$username}{'hide_smilies_row'} || !$user_hide_smilies_row);

		if (($showadded == 3 && $showsmdir != 2) || ($showsmdir == 3 && $showadded != 2)) {
			$yymain .= qq~
			&nbsp;
		</td>
		<td width="77%" valign="middle" class="windowbg2">~ if $removenormalsmilies;
			$yymain .= qq~
			<a href="javascript: smiliewin();">$post_smiltxt{'1'}</a>\n~;
		}

		$yymain .= qq~
			<noscript>
			<span class="small">$maintxt{'noscript'}</span>
			</noscript>
		</td>
	</tr>~;

		# File Attachment's Browse Box Code
		if (&AccessCheck($currentboard, 4) eq 'granted' && $allowattach && ${$uid.$currentboard}{'attperms'} == 1 && -d "$uploaddir" && $action =~ /^(post|modify)2?$/ && (($allowguestattach == 0 && !$iamguest) || $allowguestattach == 1)) {
			$mfn = $mfn || $FORM{'oldattach'};
			my @files = split(/,/, $mfn);

			$yymain .= qq~
	<tr id="feature_status_5">
		<td width="23%" align="left">
			<b>$fatxt{'80'}</b>
			<input type="hidden" name="oldattach" id="oldattach" value="$mfn" />~;

			$yymain .= qq~
			<img name="attform_add" id="attform_add" src="$defaultimagesdir/cat_expand.gif" alt="$fatxt{'80a'}" title="$fatxt{'80a'}" border="0" style="cursor:pointer;" onclick="enabPrev2(1);" />
			<img name="attform_sub" id="attform_sub" src="$defaultimagesdir/cat_collapse.gif" alt="$fatxt{'80s'}" title="$fatxt{'80s'}" border="0" style="cursor:pointer; visibility:hidden;" onclick="enabPrev2(-1);" />~ if $allowattach > 1;

			$yymain .= qq~
		</td>
		<td width="77%"><span class="small">$filetype_info<br />$filesize_info</span></td>
	</tr>
	<tr id="feature_status_6">
		<td colspan="2">~;

			my $startcount;
			for (my $y = 1; $y <= $allowattach; $y++) {
				if (($action eq 'modify' || $action eq 'modify2') && $files[$y-1] ne "" && &checkfor_DBorFILE("$uploaddir/$files[$y-1]")) {
					$startcount++;
					$yymain .= qq~
			<div id="attform_a_$y" style="float:left; width:23%;~ . ($y > 1 ? qq~ padding-top:5px~ : '') . qq~"><b>$fatxt{'6'} $y:</b></div>
			<div id="attform_b_$y" style="float:left; width:76%;~ . ($y > 1 ? qq~ padding-top:5px~ : '') . qq~">
				<input type="file" name="file$y" id="file$y" size="50" onchange="selectNewattach($y);" /><br />
				<font size="1">
				<input type="hidden" id="w_filename$y" name="w_filename$y" value="$files[$y-1]" />
				<select id="w_file$y" name="w_file$y" size="1">
				<option value="attachdel">$fatxt{'6c'}</option>
				<option value="attachnew">$fatxt{'6b'}</option>
				<option value="attachold" selected="selected">$fatxt{'6a'}</option>
				</select>&nbsp;$fatxt{'40'}: <a href="$uploadurl/$files[$y-1]" target="_blank">$files[$y-1]</a>
				</font>~;
				} else {
					$yymain .= qq~
			<div id="attform_a_$y" style="float:left; width:23%;~ . ($y > 1 ? qq~ visibility:hidden; height:0px~ : '') . qq~"><b>$fatxt{'6'} $y:</b></div>
			<div id="attform_b_$y" style="float:left; width:76%;~ . ($y > 1 ? qq~ visibility:hidden; height:0px~ : '') . qq~">\n				<input type="file" name="file$y" id="file$y" size="50" />~;
				}
				$yymain .= qq~\n			</div>\n~;

				$is_preview = 2 if $is_preview == 1 && $CGI_query->upload("file$y");
			}
			$startcount = 1 if !$startcount;

			$yymain .= qq~
			<script language="JavaScript1.2" type="text/javascript">
			<!--
			var countattach = $startcount;~ . ($startcount > 1 ? qq~\n			document.getElementById("attform_sub").style.visibility = "visible";~ : '') . qq~
			function enabPrev2(add_sub) {
				if (add_sub == 1) {
					countattach = countattach + add_sub;
					document.getElementById("attform_a_" + countattach).style.visibility = "visible";
					document.getElementById("attform_a_" + countattach).style.height = "auto";
					document.getElementById("attform_a_" + countattach).style.paddingTop = "5px";
					document.getElementById("attform_b_" + countattach).style.visibility = "visible";
					document.getElementById("attform_b_" + countattach).style.height = "auto";
					document.getElementById("attform_b_" + countattach).style.paddingTop = "5px";
				} else {
					document.getElementById("attform_a_" + countattach).style.visibility = "hidden";
					document.getElementById("attform_a_" + countattach).style.height = "0px";
					document.getElementById("attform_a_" + countattach).style.paddingTop = "0px";
					document.getElementById("attform_b_" + countattach).style.visibility = "hidden";
					document.getElementById("attform_b_" + countattach).style.height = "0px";
					document.getElementById("attform_b_" + countattach).style.paddingTop = "0px";
					countattach = countattach + add_sub;
				}
				if (countattach > 1) {
					document.getElementById("attform_sub").style.visibility = "visible";
				} else {
					document.getElementById("attform_sub").style.visibility = "hidden";
				}
				if ($allowattach <= countattach) {
					document.getElementById("attform_add").style.visibility = "hidden";
				} else {
					document.getElementById("attform_add").style.visibility = "visible";
				}
				$call_pop_up_resize
			}
			//-->
			</script>~ if $allowattach > 1;

			$yymain .= qq~
		</td>
	</tr>~;

			if ($is_preview == 2) {
				$is_preview = 1;
				$yymain .= qq~
	<tr>
		<td colspan="2" style="color:red;"><br /><b>$fatxt{'7'}</b><br /><br /></td>
	</tr>~;
			}
		}
		# /File Attachment's Browse Box Code

		$yymain .= qq~
$notification
$favoriteadd
	<tr id="feature_status_7">
		<td class="windowbg" width="23%">
			<label for="ns"><b>$post_txt{'276'}:</b></label>
		</td>
		<td class="windowbg" width="77%">
			<input type="checkbox" name="ns" id="ns" value="NS"$nscheck /> <span class="small"> <label for="ns">$post_txt{'277'}</label></span>
		</td>
	</tr>

	<tr id="feature_status_8">
		<td class="windowbg" width="23%">
			<div id="enable_iecopytext" style="display: none;">
				<label for="iecopy"><b>$post_txt{'iecopytext'}:</b></label><br /><br />
			</div>
		</td>
		<td class="windowbg" width="77%">
			<div id="enable_iecopy" style="display: none;">
				<input type="checkbox" name="iecopy" id="iecopy"$iecopycheck /> <span class="small"> <label for="iecopy">$post_txt{'iecopycheck'}</label></span><br /><br />
			</div>
		</td>
	</tr>

$lastmod
~;
	}

	#these are the buttons to submit
	if ($is_preview) { $post_txt{'507'} = $post_txt{'771'}; }
	$yymain .= qq~
	<tr>
		<td align="center" class="titlebg" colspan="2">
			$hidestatus
			<script language="JavaScript1.2" type="text/javascript">
			<!--
			if (/Opera/.test(navigator.userAgent) == false) {
				if (/mac/i.test(navigator.platform)) {
					document.write("<br /><span class='small'>~ . ($postid ne 'Poll' ? $post_txt{'331'} : $post_txt{'331a'}) . qq~</span>");
				} else if (/MSIE [7-9]/.test(navigator.userAgent) || /\\/[3-9]\\.\\d+\\.\\d+ Safari/.test(navigator.userAgent)) {
					document.write("<br /><span class='small'>~ . ($postid ne 'Poll' ? $post_txt{'329'} : $post_txt{'329a'}) . qq~</span>");
				} else if (/Firefox\\/[2-9]/.test(navigator.userAgent) || /Chrome/.test(navigator.userAgent)) {
					document.write("<br /><span class='small'>~ . ($postid ne 'Poll' ? $post_txt{'330'} : $post_txt{'330a'}) . qq~</span>");
				}
			}
			//-->
			</script>
			<br />
		</td>
	</tr>
</table>
</div>
<table class="tabtitle" cellspacing="0" cellpadding="0" border="0" width="100%">
	<tr>
		<td $roundbottomleft width="1%">
		<td width="99%" height="25" align="center">
			<input type="submit" name="$post" id="$post" value="$submittxt" accesskey="s" tabindex="5" class="button" />~ . ($postid ne 'Poll' ? qq~&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="submit" id="$preview" name="$preview" value="$post_txt{'507'}" accesskey="p" tabindex="6" class="button" />~ : '') . qq~
		</td>
		<td $roundbottomright width="1%">&nbsp;</td>
	</tr>
	
</table>
</div>
</form>
~;

	if ($speedpostdetection){
		$yymain .= qq~
		<script language="JavaScript1.2" type="text/javascript">
			<!--
			var postdelay = $min_post_speed*1000;
			document.postmodify.$post.value='$post_txt{"delay"}';
			document.postmodify.$post.disabled=true;
			document.postmodify.$post.style.cursor='default';
			var delay = window.setInterval('releasepost()',postdelay );
			function releasepost() {
				document.postmodify.$post.value='$submittxt';
				document.postmodify.$post.disabled=false;
				document.postmodify.$post.style.cursor='pointer';
				window.clearInterval(delay);
			}
			//-->
		</script>~;
	}


	if($postid ne 'Poll') {
		$yymain .= qq~
<script type="text/javascript" language="JavaScript1.2">
<!--
	// set size of messagebox and text START
	var oldwidth = parseInt(document.getElementById('message').style.width) - $jsdragwpos;
	var olddragwidth = parseInt(document.getElementById('dragbgh').style.width) - $jsdragwpos;
	var oldheight = parseInt(document.getElementById('message').style.height) - $jsdraghpos;
	var olddragheight = parseInt(document.getElementById('dragbgw').style.height) - $jsdraghpos;
	var orgsize = $textsize;
	skydobject.initialize();
	// set size of messagebox and text END

	// Collapse/Expand additional features START
	var col_row = $col_row;
	function show_features() {
		document.getElementById('col_row').value = col_row;
		if (col_row == 1) {
			for (var i = 1; 14 > i; i++) {
				try {
					if (typeof(document.getElementById("feature_status_" + i).style)) throw "1";
				} catch (e) {
					if (e == "1") {
						document.getElementById("feature_status_" + i).style.display = "none";
					}
				}
			}
			document.images.feature_col.alt = "$npf_txt{'expand_features'}";
			document.images.feature_col.title = "$npf_txt{'expand_features'}";
			document.images.feature_col.src = "$defaultimagesdir/cat_expand.gif";
			col_row = 0;
		} else {
			for (var i = 1; 14 > i; i++) {
				try {
					if (typeof(document.getElementById("feature_status_" + i).style)) throw "1";
				} catch (e) {
					if (e == "1") {
						document.getElementById("feature_status_" + i).style.display = "";
					}
				}
			}
			document.images.feature_col.alt = "$npf_txt{'collapse_features'}";
			document.images.feature_col.title = "$npf_txt{'collapse_features'}";
			document.images.feature_col.src = "$defaultimagesdir/cat_collapse.gif";
			col_row = 1;
		}
		$call_pop_up_resize	
	}
	show_features();
	// Collapse/Expand additional features END
//-->
</script>~;
	}

	if ($postid ne 'Poll' && $post ne 'imsend' && $staff) {
		$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript">
<!--
function showtpstatus() {
	var z = 0;
	var x = 0;
	var theimg = '$threadclass';
	for(var i=0; i<document.postmodify.topicstatus.length; i++) {
		if (document.postmodify.topicstatus[i].selected) { z++; x += i; }
	}~;
		if ($currentboard ne $annboard) {
			$yymain .= qq~
	if(z == 1 && x == 0) theimg = 'sticky';
	if(z == 1 && x == 1) theimg = 'locked';
	if(z == 2 && x == 1) theimg = 'stickylock';
	if(z == 1 && x == 2) theimg = 'hide';
	if(z == 2 && x == 2) theimg = 'hidesticky';
	if(z == 2 && x == 3) theimg = 'hidelock';
	if(z == 3 && x == 3) theimg = 'hidestickylock';~;
		} else {
			$yymain .= qq~
	if(z == 1 && x == 0) theimg = 'announcementlock';
	if(z == 1 && x == 1) theimg = 'hide';
	if(z == 2 && x == 1) theimg = 'hidelock';~;
		}
		$yymain .= qq~
	document.images.thrstat.src='$defaultimagesdir/'+theimg+'.gif';
}
showtpstatus();
//-->
</script>~;
	}

	if ($action eq "modify" || $action eq "modify2") {
		$displayname = qq~$mename~;
	} else {
		$displayname = ${$uid.$username}{'realname'};
	}

	require "$templatesdir/$usedisplay/Display.template";

	foreach (@months) { $jsmonths .= qq~'$_',~; }
	$jsmonths =~ s~\,\Z~~;
	$jstimeselected = ${$uid.$username}{'timeselect'} || $timeselected;

	if($postid ne 'Poll') {
		$yymain .= qq~
<script language="JavaScript1.2" src="$yyhtml_root/yabbc.js" type="text/javascript"></script>
<script type="text/javascript" language="JavaScript">
<!--
var noalert = true, gralert = false, rdalert = false, clalert = false;
var prevsec = 5
var prevtxt
var cntsec = 0

function tick() {
  cntsec++
  calcCharLeft()
  var timerID = setTimeout("tick()",1000)
}

var autoprev = false
var topicfirst = true;

post_txt_807 = "$post_txt{'807'}";

function enabPrev() {
	if ( autoprev == false ) {
		autoprev = true
		topicfirst = true
		document.getElementById("savetable").style.visibility = "visible";
		document.getElementById("SaveInfo").style.height = "auto";
		document.getElementById("savetopic").style.height = "auto";
		document.getElementById("saveframe").style.height = "auto";
		document.images.prevwin.alt = "$npf_txt{'02'}";
		document.images.prevwin.title = "$npf_txt{'02'}";
		document.images.prevwin.src="$defaultimagesdir/cat_collapse.gif";
		autoPreview();
	}
	else {
		autoprev = false;
		ubbstr = '';
		document.getElementById("savetable").style.visibility = "hidden";
		document.getElementById("SaveInfo").style.height = "16px";
		document.getElementById("savetopic").style.height = "0px";
		document.getElementById("saveframe").style.height = "0px";
		document.postmodify.message.focus();
		document.images.prevwin.alt = "$npf_txt{'01'}";
		document.images.prevwin.title = "$npf_txt{'01'}";
		document.images.prevwin.src="$defaultimagesdir/cat_expand.gif";
	}
	calcCharLeft();
	$call_pop_up_resize
}

function calcCharLeft() {
  var clipped = false
  var maxLength = $MaxMessLen
  if (document.postmodify.message.value.length > maxLength) {
	document.postmodify.message.value = document.postmodify.message.value.substring(0,maxLength)
	var charleft = 0
	clipped = true
  } else {
	charleft = maxLength - document.postmodify.message.value.length
  }
  prevsec++
  if(autoprev && prevsec > 5 && prevtxt != document.postmodify.message.value) {
	autoPreview()
	prevtxt = document.postmodify.message.value
  }
  document.postmodify.msgCL.value = charleft
  if (charleft >= 100 && noalert) { noalert = false; gralert = true; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/green1.gif"; }
  if (charleft < 100 && charleft >= 50 && gralert) { noalert = true; gralert = false; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/green0.gif"; }
  if (charleft < 50 && charleft > 0 && rdalert) { noalert = true; gralert = true; rdalert = false; clalert = true; document.images.chrwarn.src="$defaultimagesdir/red0.gif" }
  if (charleft == 0 && clalert) { noalert = true; gralert = true; rdalert = true; clalert = false; document.images.chrwarn.src="$defaultimagesdir/red1.gif"; }
  return clipped
}

var codestr = '$simpelcode';
var quotstr = '$normalquot';
var squotstr = '$simpelquot';
var fontsizemax = '$fontsizemax';
var fontsizemin = '$fontsizemin';
var edittxt = '$edittext';
var dispname = '$displayname';
var scrpurl = '$scripturl';
var imgdir = '$defaultimagesdir';
var ubsmilieurl = '$smiliesurl';
var parseflash = '$parseflash';
var autolinkurl = '$autolinkurls';
var Month = new Array($jsmonths);
var timeselected = '$jstimeselected';
var splittext = "$maintxt{'107'}";
var dontusetoday = '';
var todaytext = "$maintxt{'769'}";
var yesterdaytext = "$maintxt{'769a'}";
var timetext1 = "$timetxt{'1'}";
var timetext2 = "$timetxt{'2'}";
var timetext3 = "$timetxt{'3'}";
var timetext4 = "$timetxt{'4'}";
var jsmilieurl = new Array($smilie_url_array);
var jsmiliecode = new Array($smilie_code_array);
var showimageinquote = $showimageinquote;

function autoPreview() {
	if (topicfirst)  { updatTopic(); }
	var scrlto = parseInt(180) + 5;
	var vismessage = document.postmodify.message.value;
	while ( c=vismessage.match(/date=(\\d+?)\\]/i) ) {
		var qudate=c[1];
		qudate=qudate * 1000;
		qdate=new Date()
		qdate.setTime(qudate);
		qdate=qdate.toLocaleString();
		vismessage=vismessage.replace(/(date=)\\d+?(\\])/i, "\$1"+qdate+"\$2");
	}
	if($enable_ubbc) {
		var ubbstr = jsDoUbbc(vismessage,codestr,quotstr,squotstr,edittxt,dispname,scrpurl,imgdir,ubsmilieurl,parseflash,fontsizemax,fontsizemin,autolinkurl,Month,timeselected,splittext,dontusetoday,todaytext,yesterdaytext,timetext1,timetext2,timetext3,timetext4,jsmilieurl,jsmiliecode,showimageinquote);
	}
	else {
		var ubbstr = vismessage;
	}
	document.getElementById("saveframe").innerHTML=ubbstr;
	sh_highlightDocument();
	LivePrevImgResize();
	scrlto += parseInt(document.getElementById("saveframe").scrollTop) + parseInt(document.getElementById("saveframe").offsetHeight);
	document.getElementById("saveframe").scrollTop = scrlto;
	prevsec = 0;
	$call_pop_up_resize
}

var visikon = '';

function LivePrevImgResize() {
	var max_w = $max_post_img_width;
	var max_h = $max_post_img_height;
	var images = document.getElementById("saveframe").getElementsByTagName("img");
	for (var i = 0; i < images.length; i++) {
		if (max_w != 0 && images[i].width > max_w) {
			images[i].height = images[i].height * max_w / images[i].width;
			images[i].width = max_w;
		}
		if (max_h != 0 && images[i].height > max_h) {
			images[i].width  = images[i].width * max_h / images[i].height;
			images[i].height = max_h;
		}
	}
}

function updatTopic() {
	var topicfirst = false;
	~;

		if ($destination ne 'modalert2' && $destination ne 'guestpm2') {
			$yymain .= qq~
	var visicon = document.postmodify.icon.value;
	visicon=visicon.replace(/http\\:\\/\\/.*\\/(.*?)\\.gif/g, "\$1");
	visicon=visicon.replace(/[^A-Za-z]/g, "");
	visicon=visicon.replace(/\\\\/g, "");
	visicon=visicon.replace(/\\//g, "");
	if (visicon != "xx" && visicon != "thumbup" && visicon != "thumbdown" && visicon != "exclamation") {
		if (visicon != "question" && visicon != "lamp" && visicon != "smiley" && visicon != "angry") {
			if (visicon != "cheesy" && visicon != "grin" && visicon != "sad" && visicon != "wink") {
				visicon = "xx";
			}
		}
	}
	visikon = "<img border='0' src='$imagesdir/"+visicon+".gif' alt='"+visicon+"' /> ";~;
		}

		$yymain .= qq~
	var vistopic = document.postmodify.subject.value;
	var htmltopic = jsDoTohtml(vistopic);
	document.getElementById("savetopic").innerHTML=visikon+htmltopic;
	//document.postmodify.message.focus();
}

~ . (!$Quick_Post ? "document.postmodify.$settofield.focus();" : "") . qq~\n\n~;

		if ($post eq 'imsend') {
			$yymain .= qq~
if(document.getElementById('toshowcc').length > 0) document.getElementById('toshowcc').style.display = 'inline';
if(document.getElementById('toshowbcc').length > 0) document.getElementById('toshowbcc').style.display = 'inline';
~;
		}
		$yymain .= qq~
if (navigator.appName == "Microsoft Internet Explorer") {
	document.getElementById('enable_iecopytext').style.display = 'inline';
	document.getElementById('enable_iecopy').style.display = 'inline';
}
tick();
//-->
</script>
~;
	}
	
	if ($INFO{'popup'}) {
		&print_output_header;

		$output = qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
		<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
		<head>
		<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />
		<title></title>
		<link rel="stylesheet" href="$forumstylesurl/$usestyle.css" type="text/css" />
		<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/YaBB.js"></script>
		<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/shjs/sh_main.js"></script>
		<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/shjs/sh_cpp.js"></script>
		<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/shjs/sh_css.js"></script>
		<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/shjs/sh_html.js"></script>
		<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/shjs/sh_java.js"></script>
		<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/shjs/sh_javascript.js"></script>
		<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/shjs/sh_pascal.js"></script>
		<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/shjs/sh_perl.js"></script>
		<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/shjs/sh_php.js"></script>
		<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/shjs/sh_sql.js"></script>
		<script language="JavaScript1.2" type="text/javascript">
		function ResizeIFrame() {
			var height = document.body.scrollHeight;
			if(typeof parent.window !== 'undefined' && typeof parent.window.IFrameShrink === 'function'){
				parent.window.IFrameShrink();
				parent.window.ResizeIFrame(height);
			} else {
				parent.IFrameShrink();
				parent.ResizeIFrame(height);
			}
		}
		</script>
		$yyinlinestyle
		</head>
		<body onload="ResizeIFrame(); parent.InsertQuote()" style="background-color:#2f7dce; height: 100%; width: 100%">
		$yymain
		</body>
		</html>~;
		
		$output =~ s~</form>~<input type="hidden" name="formsession" value="$formsession" /></form>~g;

		&print_HTML_output_and_finish;
	}
}

##  preview message
sub Preview {
	my $error = $_[0];
	&ToHTML($error);

	# allows the following HTML-tags in error messages: <br /> <b>
	$error =~ s/&lt;br( \/)&gt;/<br \/>/ig;
	$error =~ s/&lt;(\/?)b&gt;/<$1b>/ig;

	$maxpq ||= 60;
	$maxpo ||= 50;
	$maxpc ||= 0;
	$numpolloptions ||= 8;
	$vote_limit ||= 0;
	$pie_radius ||= 100;

	for (my $i = 1; $i <= $numpolloptions; $i++) {
		$options[$i] = $FORM{"option$i"};
		&FromChars($options[$i]);
		$convertstr = $options[$i];
		$convertcut = $maxpo;
		&CountChars;
		$options[$i] = $convertstr;
		&ToHTML($options[$i]);
		&ToChars($options[$i]);
		$slicecolor[$i] = $FORM{"slicecol$i"};
		$split[$i] = $FORM{"split$i"};
	}

	$guest_vote    = $FORM{'guest_vote'};
	$hide_results  = $FORM{'hide_results'};
	$multi_choice  = $FORM{'multi_choice'};
	$poll_comment  = $FORM{'poll_comment'};
	$vote_limit    = $FORM{'vote_limit'};
	$pie_legends   = $FORM{'pie_legends'};
	$pie_radius    = $FORM{'pie_radius'};
	$poll_end_days = $FORM{'poll_end_days'};
	$poll_end_min  = $FORM{'poll_end_min'};

	$poll_end_days = '' if !$poll_end_days || $poll_end_days =~ /\D/;
	$poll_end_min  = '' if !$poll_end_min  || $poll_end_min =~ /\D/;

	if ($pie_radius =~ /\D/) { $pie_radius = 100; }
	if ($pie_radius < 100) { $pie_radius = 100; }
	if ($pie_radius > 200) { $pie_radius = 200; }

	$pollthread = $FORM{'pollthread'} || 0;

	$poll_question = $FORM{'question'};
	&FromChars($poll_question);
	$convertstr = $poll_question;
	$convertcut = $maxpq;
	&CountChars;
	$poll_question = $convertstr;
	&ToHTML($poll_question);
	&ToChars($poll_question);

	&FromChars($poll_comment);
	$convertstr = $poll_comment;
	$convertcut = $maxpc;
	&CountChars;
	$poll_comment = $convertstr;
	&ToHTML($poll_comment);
	&ToChars($poll_comment);

	$name = $FORM{'name'};
	$email = $FORM{'email'};
	$sub = $FORM{'subject'};
	$FORM{'message'} =~ s~\r~~g;
	$message = $FORM{'message'};
	$icon = $FORM{'icon'};
	$ns = $FORM{'ns'};
	$threadid = $FORM{'threadid'};
	$postid = $FORM{'postid'};
	$thestatus = $FORM{'topicstatus'};
	$isBMess = $FORM{'isBMess'};
	if (!$iamguest && ${$uid.$username}{'postlayout'} ne qq~$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}~) {
		${$uid.$username}{'postlayout'} = qq~$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}~;
		&UserAccount($username, "update");
	}
	$postthread = 2 if $threadid;

	$sub =~ s/[\r\n]//g;
	my $testsub = $sub;
	$testsub =~ s/ |\&nbsp;//g;
	if ($sub && !$testsub && $pollthread != 2) { $error = $post_txt{'77'}; }

	&FromChars($sub);
	$convertstr = $sub;
	$convertcut = $set_subjectMaxLength + ($sub =~ /^Re: / ? 4 : 0);
	&CountChars;
	$sub = $convertstr;
	&ToHTML($sub);

	$csubject = $sub;
	&ToChars($csubject);
	$csubject = &Censor($csubject);

	my $testmessage = $message;
	$testmessage =~ s/[\r\n\ ]//g;
	$testmessage =~ s/\&nbsp;//g;
	$testmessage =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
	$testmessage =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;
	$testmessage =~ s/\[.*?\]//g;
	if ($testmessage eq "" && $message ne "" && $pollthread != 2) { fatal_error("useless_post","$testmessage"); }

	&FromChars($message);
	&ToHTML($message);
	my $mess = $message;
	$message =~ s/\cM//g;
	$message =~ s~\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[$1$2\]~g;
	$message =~ s~\[/([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[/$1$2\]~g;
	$message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/g;
	$message =~ s/\n/<br \/>/g;
	$message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/g;

	&CheckIcon;

	if    ($icon eq "xx")           { $ic1  = " selected=\"selected\" "; }
	elsif ($icon eq "thumbup")      { $ic2  = " selected=\"selected\" "; }
	elsif ($icon eq "thumbdown")    { $ic3  = " selected=\"selected\" "; }
	elsif ($icon eq "exclamation")  { $ic4  = " selected=\"selected\" "; }
	elsif ($icon eq "no_postcount") { $ic4  = " selected=\"selected\" "; }
	elsif ($icon eq "question")     { $ic5  = " selected=\"selected\" "; }
	elsif ($icon eq "lamp")         { $ic6  = " selected=\"selected\" "; }
	elsif ($icon eq "smiley")       { $ic7  = " selected=\"selected\" "; }
	elsif ($icon eq "angry")        { $ic8  = " selected=\"selected\" "; }
	elsif ($icon eq "cheesy")       { $ic9  = " selected=\"selected\" "; }
	elsif ($icon eq "grin")         { $ic10 = " selected=\"selected\" "; }
	elsif ($icon eq "sad")          { $ic11 = " selected=\"selected\" "; }
	elsif ($icon eq "wink")         { $ic12 = " selected=\"selected\" "; }
	if ($FORM{'status'} eq 'c')     { $icon = 'confidential'; }
	elsif ($FORM{'status'} eq 'u')  { $icon = 'urgent'; }
	elsif ($FORM{'status'} eq 's')  { $icon = 'standard'; }

	$name_field = $iamguest ? qq~      <tr>
    <td class="windowbg" align="left" width="23%"><label for="name"><b>$post_txt{'68'}:</b></label></td>
    <td class="windowbg" align="left" width="77%"><input type="text" name="name" id="name" size="25" value="$FORM{'name'}" maxlength="25" tabindex="2" /></td>
      </tr>~
	  : qq~~;

	$email_field = $iamguest ? qq~      <tr>
    <td class="windowbg" width="23%"><label for="email"><b>$post_txt{'69'}:</b></label></td>
    <td class="windowbg" width="77%"><input type="text" name="email" id="email" size="25" value="$FORM{'email'}" maxlength="40" tabindex="3" /></td>
      </tr>~
	  : qq~~;
	if ($iamguest && $gpvalid_en) {
		$usename = substr($date,1,length($date)-4);
		$sesname = substr($date,0,length($date)-4);
		$verification = $FORM{'verification'};
		$sessionid = $FORM{'sessionid'};
		$verification_field = $verification ne ''
		? qq~
			<tr>
				<td class="windowbg" width="23%" valign="top"><label for="verification"><b>$floodtxt{'3'}:</b></label></td>
				<td class="windowbg" width="77%">$verification
				<input type="hidden" name="verification" id="verification" value="$verification" />
				<input type="hidden" name="sessionid" id="sessionid" value="$sessionid" />
				</td>
			</tr>
		~
			: '';
	}
	if ($FORM{'ns'} eq 'NS') { $nscheck = qq~ checked="checked"~; }
	if ($FORM{'iecopy'}) { $iecopycheck = qq~ checked="checked"~; }

	if ($iamguest) {
		$name .= "($post_txt{'772'})";
	}

	if ($action eq 'modify2') {
		$displayname = $FORM{'mename'};
	} else {
		$displayname = ${$uid.$username}{'realname'};
	}

	&wrap;
	($message, undef) = &Split_Splice_Move($message,$threadid);
	if ($enable_ubbc) {
		if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
		&DoUBBC;
	}
	&wrap2;

	if ($FORM{'previewmodify'} || $FORM{'postmodify'}) {
		$submittxt = $post_txt{'10'};
		$is_preview = 1;
		$post = 'postmodify';
		$preview = 'previewmodify';
		$destination = 'modify2';
	} elsif (!$FORM{'previewim'} && $INFO{'action'} ne 'modalert2' && $INFO{'action'} ne 'guestpm2') {
		$destination = 'post2';
		$submittxt = $post_txt{'105'};
		$is_preview = 1;
		$post = 'post';
		$preview = 'preview';
	}

	if ($INFO{'action'} eq 'imgroups') { $destination = 'imgroups'; }

	if ($INFO{'action'} eq 'modalert2') {
		$t_title = $post_txt{'alertmod'};
		$destination = 'modalert2';
		$submittxt = $post_txt{'148'};
		$is_preview = 1;
		$post = 'modalert';
		$preview = 'preview';
		$yytitle = $post_txt{'alertmod'};
	}

	if ($INFO{'action'} eq 'guestpm2') {
		$t_title = $post_txt{'sendmessguest'};
		$destination = 'guestpm2';
		$submittxt = $post_txt{'148'};
		$is_preview = 1;
		$post = 'guestpm';
		$preview = 'preview';
		$yytitle = $post_txt{'sendmessguest'};
	}

	require "$templatesdir/$usedisplay/Display.template";

	&ToChars($message);
	$message = &Censor($message);
	$prevmain .= qq~
		<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/ubbc.js"></script>
		<div class="bordercolor" style="padding: 1px; width: 100%; margin-left: auto; margin-right: auto;">
		<table border="0" width="100%" cellpadding="3" cellspacing="0" class="windowbg" style="table-layout: fixed;">
		 <tr>
		  <td class="titlebg">
		   <img src="$imagesdir/$icon.gif" name="icons2" border="0" alt="" /> $csubject
		  </td>
		 </tr>
		</table>
		<table border="0" width="100%" cellpadding="3" cellspacing="0" class="windowbg" style="table-layout: fixed;">
		 <tr>
		  <td class="windowbg2">
		   <div class="message" style="overflow:auto;">$message</div>
		  </td>
		 </tr>
		</table>
		</div>\n~;

	if ($error) {
		&LoadLanguage('Error');
		$prevmain .= qq~
		<div class="bordercolor" style="padding: 1px; width: 100%; margin-left: auto; margin-right: auto;">
		<table border="0" width="100%" cellpadding="3" cellspacing="0" class="windowbg" style="table-layout: fixed;">
		 <tr>
		  <td class="titlebg">
		   <img src="$imagesdir/exclamation.gif" border="0" alt="" /> $error_txt{'error_occurred'}
		  </td>
		 </tr>
		</table>
		<table border="0" width="100%" cellpadding="3" cellspacing="0" class="windowbg" style="table-layout: fixed;">
		 <tr>
		  <td class="windowbg2">
		   <div class="message" style="overflow:auto; color: red"><br />$error<br /><br /></div>
		  </td>
		 </tr>
		</table>
		</div>\n~;
	}

	$message = $mess;

	if ($error) { $csubject = $error; }

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

	$yytitle = $error ? "$error_txt{'error_occurred'} $csubject" : "$post_txt{'507'} - $csubject";
	$settofield = "message";
	$postthread = 2;

	if (!$view) {
		&Postpage;
		if ($threadid ne '' && $post eq 'post') { &doshowthread; }
		if (%usernames_life_quote) { # for display names in Quotes in LivePreview
			$yymain .= qq~
		<script language="JavaScript" type="text/javascript">
		<!-- //
			~ . join(';', map { qq~LivePrevDisplayNames['$_'] = "$usernames_life_quote{$_}"~ } keys %usernames_life_quote) . qq~;
		// -->
		</script>\n~;
		}
		&template;
	}
}

sub Post2 {
	if ($iamguest && $enable_guestposting == 0) { &fatal_error("not_logged_in"); }
	#if ($currentboard eq $annboard && !$iamadmin && !$iamgmod) { &fatal_error('not_allowed'); }
	if (!$staff && $speedpostdetection && ${$uid.$username}{'spamcount'} >= $post_speed_count) {
		$detention_time = ${$uid.$username}{'spamtime'} + $spd_detention_time;
		if($date <= $detention_time){
			$detention_left = $detention_time - $date;
			&fatal_error("speedpostban");
		} else {
			${$uid.$username}{'spamcount'} = 0;
			&UserAccount($username,"update");
		}
	}
	if ($iamguest && $gpvalid_en) {
		&validation_check($FORM{'verification'});
	}
	my ($email, $ns, $notify, $hasnotify, $i, $membername, $testname, @reserve, @reservecfg, $matchword, $matchcase, $matchuser, $matchname, $namecheck, $reserved, $reservecheck, $mnum, $msub, $mname, $memail, $mdate, $musername, $micon, $mstate, $pageindex, $tempname);

	&BoardTotals("load", $currentboard);

	# If poster is a Guest then evaluate the legality of name and email
	if (!${$uid.$username}{'email'}) {
		$FORM{'name'} =~ s/\A\s+//;
		$FORM{'name'} =~ s/\s+\Z//;
		&Preview($post_txt{'75'}) unless ($FORM{'name'} ne '' && $FORM{'name'} ne '_' && $FORM{'name'} ne ' ');
		&Preview($post_txt{'568'}) if (length($FORM{'name'}) > 25);
		&Preview("$post_txt{'76'}") if ($FORM{'email'} eq '');
		&Preview("$post_txt{'240'} $post_txt{'69'} $post_txt{'241'}") if ($FORM{'email'} !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/);
		&Preview("$post_txt{'500'}") if (($FORM{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($FORM{'email'} !~ /^.+@\[?(\w|[-.])+\.([a-zA-Z]{2,4}|[0-9]{1,4})\]?$/));
	}

	# Get the form values
	$name         = $FORM{'name'};
	$email        = $FORM{'email'};
	$subject      = $FORM{'subject'};
	$message      = $FORM{'message'};
	$icon         = $FORM{'icon'};
	$ns           = $FORM{'ns'};
	$ann          = $FORM{'ann'};
	$threadid     = $FORM{'threadid'};
	if ($threadid =~ /\D/) { &fatal_error("only_numbers_allowed"); }
	$pollthread   = $FORM{'pollthread'} || 0;
	$posttime     = $FORM{'post_entry_time'};
	$notify       = $FORM{'notify'};
	$hasnotify    = $FORM{'hasnotify'};
	$favorite     = $FORM{'favorite'};
	$thestatus    = $FORM{'topicstatus'};
	$thestatus    =~ s/\, //g;
	chomp $thestatus;

	# Check if poster isn't using a distilled email domain
	&email_domain_check($email);
	my $spamdetected = &spamcheck("$name $subject $message");
	if (!${$uid.$FORM{$username}}{'spamcount'}) { ${$uid.$FORM{$username}}{'spamcount'} = 0; }
	$postspeed = $date - $posttime;
	if (!$staff){
		if (($speedpostdetection && $postspeed < $min_post_speed) || $spamdetected == 1) {
			${$uid.$username}{'spamcount'}++;
			${$uid.$username}{'spamtime'} = $date;
			&UserAccount($username,"update");
			$spam_hits_left_count = $post_speed_count - ${$uid.$username}{'spamcount'};
			if($spamdetected == 1){ &fatal_error("tsc_alert"); } else { &fatal_error("speed_alert"); }
		}
	}
	# Permission checks for posting.
	if (!$threadid) {
		# Check for ability to post new threads
		unless (&AccessCheck($currentboard, 1) eq 'granted' || $pollthread) { &fatal_error('no_perm_post'); }
	} else {
		# Check for ability to reply to threads
		unless (&AccessCheck($currentboard, 2) eq 'granted' || $pollthread) { &fatal_error('no_perm_reply'); }
		$postthread = 2;
	}
	if ($pollthread) {
		# Check for ability to post polls
		unless (&AccessCheck($currentboard, 3) eq 'granted') { &fatal_error('no_perm_poll'); }
	}
	for (my $y = 1; $y <= $allowattach; ++$y) {
		if ($CGI_query && $CGI_query->upload("file$y")) {
			# Check once for ability to post attachments
			unless (&AccessCheck($currentboard, 4) eq 'granted') { &fatal_error('no_perm_att'); }
			last;
		}
	}
	# End Permission Checks

	## clean name and email - remove | from name and turn any _ to spaces fro amil
	if ($name && $email) {
		&ToHTML($name);
		$email =~ s/\|//g;
		&ToHTML($email);
		$tempname = $name;
		$name =~ s/\_/ /g;
	}

	# Fixes a bug with posting hexed characters.
	$name =~ s~amp;~~g;

	&Preview($post_txt{'75'}) unless ($username || $name);
	&Preview($post_txt{'76'}) unless (${$uid.$username}{'email'} || $email);
	&Preview($post_txt{'77'}) unless ($subject && $subject !~ m~\A[\s_.,]+\Z~);
	&Preview($post_txt{'78'}) unless ($message);

	# Check Message Length Precisely
	my $mess_len = $message;
	$mess_len =~ s/[\r\n ]//ig;
	$mess_len =~ s/&#\d{3,}?\;/X/ig;
	if (length($mess_len) > $MaxMessLen) {
		&Preview($post_txt{'536'} . " " . (length($mess_len) - $MaxMessLen) . " " . $post_txt{'537'});
	}
	undef $mess_len;

	if ($FORM{'preview'}) { &Preview; }
	&spam_protection;

	$subject =~ s/[\r\n]//g;
	my $testsub = $subject;
	$testsub =~ s/ |\&nbsp;//g;
	if ($testsub eq "" && $pollthread != 2) { fatal_error("useless_post","$testsub"); }

	my $testmessage = $message;
	$testmessage =~ s/[\r\n\ ]//g;
	$testmessage =~ s/\&nbsp;//g;
	$testmessage =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
	$testmessage =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;
	$testmessage =~ s/\[.*?\]//g;
	if ($testmessage eq "" && $message ne "" && $pollthread != 2) { fatal_error("useless_post","$testmessage"); }

	if (!$minlinkpost){ $minlinkpost = 0 ;}
	if (${$uid.$username}{'postcount'} < $minlinkpost && !$staff) { 
		if ($message =~ m~http:\/\/~ || $message =~ m~https:\/\/~ || $message =~ m~ftp:\/\/~ || $message =~ m~www.~ || $message =~ m~ftp.~ =~ m~\[url~ || $message=~ m~\[link~ || $message=~ m~\[img~ || $message=~ m~\[ftp~) {
			&fatal_error("no_links_allowed");
		}
	}

	&FromChars($subject);
	$convertstr = $subject;
	$convertcut = $set_subjectMaxLength + ($subject =~ /^Re: / ? 4 : 0);
	&CountChars;
	$subject = $convertstr;
	&ToHTML($subject);
	$doadsubject = $subject;

	$message =~ s/\cM//g;
	$message =~ s~\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[$1$2\]~g;
	$message =~ s~\[/([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[/$1$2\]~g;
	&FromChars($message);
	&ToHTML($message);
	$message =~ s~\t~ \&nbsp; \&nbsp; \&nbsp;~g;
	$message =~ s~\n~<br />~g;
	$message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/g;
	&CheckIcon;

	if (!$use_MySQL) { &delete_DBorFILE("$datadir/.txt"); }

	if (!$iamguest) {
		# If not guest, get name and email.
		$name  = ${$uid.$username}{'realname'};
		$email = ${$uid.$username}{'email'};

	} else {
		# If user is Guest, then make sure the chosen name and email
		# is not reserved or used by a member.
		if (lc $name eq lc &MemberIndex("check_exist", $name)) { &fatal_error("guest_taken","($name)"); }
		if (lc $email eq lc &MemberIndex("check_exist", $email)) { &fatal_error("guest_taken","($email)"); }
	}

	my @poll_data;
	if ($pollthread) {
		$maxpq          ||= 60;
		$maxpo          ||= 50;
		$maxpc          ||= 0;
		$numpolloptions ||= 8;

		my $numcount = 0;
		my $testspaces = $FORM{"question"};
		$testspaces =~ s/[\r\n\ ]//g;
		$testspaces =~ s/\&nbsp;//g;
		$testspaces =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
		$testspaces =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;
		$testspaces =~ s/\[.*?\]//g;
		if (length($testspaces) == 0 && length($FORM{"question"}) > 0) { fatal_error("useless_post","$testspaces"); }

		&FromChars($FORM{'question'});
		$convertstr = $FORM{'question'};
		$convertcut = $maxpq;
		&CountChars;
		$FORM{'question'} = $convertstr;
		if ($cliped) { &Preview("$post_polltxt{'40'} $post_polltxt{'34a'} $maxpq $post_polltxt{'34b'} $post_polltxt{'36'}"); }
		unless ($FORM{"question"}) { &Preview("$post_polltxt{'37'}"); }
		&ToHTML($FORM{'question'});

		$guest_vote    = $FORM{'guest_vote'}   || 0;
		$hide_results  = $FORM{'hide_results'} || 0;
		$multi_choice  = $FORM{'multi_choice'} || 0;
		$poll_comment  = $FORM{'poll_comment'} || "";
		$vote_limit    = $FORM{'vote_limit'}   || 0;
		$pie_legends   = $FORM{'pie_legends'}  || 0;
		$pie_radius    = $FORM{'pie_radius'}   || 100;
		$poll_end_days = $FORM{'poll_end_days'};
		$poll_end_min  = $FORM{'poll_end_min'};

		if ($pie_radius =~ /\D/) { $pie_radius = 100; }
		if ($pie_radius < 100)   { $pie_radius = 100; }
		if ($pie_radius > 200)   { $pie_radius = 200; }

		if ($vote_limit =~ /\D/) { $vote_limit = 0; &Preview("$post_polltxt{'62'}"); }

		&FromChars($poll_comment);
		$convertstr = $poll_comment;
		$convertcut = $maxpc;
		&CountChars;
		$poll_comment = $convertstr;
		if ($cliped) { &Preview("$post_polltxt{'57'} $post_polltxt{'34a'} $maxpc $post_polltxt{'34b'} $post_polltxt{'36'}"); }
		&ToHTML($poll_comment);
		$poll_comment =~ s~\n~<br />~g;
		$poll_comment =~ s~\r~~g;

		$poll_end_days = '' if !$poll_end_days || $poll_end_days =~ /\D/;
		$poll_end_min  = '' if !$poll_end_min  || $poll_end_min =~ /\D/;
		my $poll_end = $poll_end_days * 86400 if $poll_end_days;
		$poll_end += $poll_end_min * 60 if $poll_end_min;
		$poll_end += $date if $poll_end;

		push(@poll_data, qq~$FORM{"question"}|0|$username|$name|$email|$date|$guest_vote|$hide_results|$multi_choice|||$poll_comment|$vote_limit|$pie_radius|$pie_legends|$poll_end\n~);

		for ($i = 1; $i <= $numpolloptions; $i++) {
			if ($FORM{"option$i"}) {
				$FORM{"option$i"} =~ s/\&nbsp;/ /g;
				my $testspaces = $FORM{"option$i"};
				$testspaces =~ s/[\r\n\ ]//g;
				$testspaces =~ s/\&nbsp;//g;
				$testspaces =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
				$testspaces =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;
				$testspaces =~ s/\[.*?\]//g;
				if (length($testspaces) == 0 && length($FORM{"option$i"}) > 0) { fatal_error("useless_post","$testspaces"); }

				&FromChars($FORM{"option$i"});
				$convertstr = $FORM{"option$i"};
				$convertcut = $maxpo;
				&CountChars;
				$FORM{"option$i"} = $convertstr;
				if ($cliped) { &Preview("$post_polltxt{'7'} $i  $post_polltxt{'34a'} $maxpo $post_polltxt{'34b'} $post_polltxt{'36'}"); }
				&ToHTML($FORM{"option$i"});

				$numcount++;
				$split[$i] = $FORM{"split$i"} ? 1 : 0;
				push(@poll_data, qq~0|$FORM{"option$i"}|$FORM{"slicecol$i"}|$split[$i]\n~);
			}
		}
		if ($numcount < 2) { &Preview("$post_polltxt{'38'}"); }
	}

	my ($file,$fixfile,@filelist,%filesizekb);
	for (my $y = 1; $y <= $allowattach; ++$y) {
		$file = $CGI_query->upload("file$y") if $CGI_query;
		if ($file) {
			$fixfile = $file;
			$fixfile =~ s/.+\\([^\\]+)$|.+\/([^\/]+)$/$1/;
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

			# replace . with _ in the filename except for the extension
			my $fixname = $fixfile;
			$fixname =~ s/(.+)(\..+?)$/$1/;
			my $fixext = $2;

			my $spamdetected = &spamcheck("$fixname");
			if (!$staff){
				if ($spamdetected == 1) {
					${$uid.$username}{'spamcount'}++;
					${$uid.$username}{'spamtime'} = $date;
					&UserAccount($username,"update");
					$spam_hits_left_count = $post_speed_count - ${$uid.$username}{'spamcount'};
					foreach (@filelist) { &delete_DBorFILE("$uploaddir/$_"); }
					&fatal_error("tsc_alert");
				}
			}

			$fixext  =~ s/\.(pl|pm|cgi|php)/._$1/i;
			$fixname =~ s/\.(?!tar$)/_/g;
			$fixfile = qq~$fixname$fixext~;

			if (!$overwrite) { $fixfile = &check_existence($uploaddir, $fixfile); }
			elsif ($overwrite == 2 && &checkfor_DBorFILE("$uploaddir/$fixfile")) {
				foreach (@filelist) { &delete_DBorFILE("$uploaddir/$_"); }
				&fatal_error("file_overwrite");
			}

			my $match = 0;
			if (!$checkext) { $match = 1; }
			else {
				foreach $ext (@ext) {
					if (grep /$ext$/i, $fixfile) { $match = 1; last; }
				}
			}
			if ($match) {
				unless ($allowattach && (($allowguestattach == 0 && !$iamguest) || $allowguestattach == 1)) {
					foreach (@filelist) { &delete_DBorFILE("$uploaddir/$_"); }
					&fatal_error("no_perm_att");
				}
			} else {
				foreach (@filelist) { &delete_DBorFILE("$uploaddir/$_"); }
				&Preview("$fixfile $fatxt{'20'} @ext");
			}

			my ($size,$buffer,$filesize,$file_buffer);
			while ($size = read($file, $buffer, 512)) { $filesize += $size; $file_buffer .= $buffer; }
			if ($limit && $filesize > (1024 * $limit)) {
				foreach (@filelist) { &delete_DBorFILE("$uploaddir/$_"); }
				&Preview("$fatxt{'21'} $fixfile (" . int($filesize / 1024) . " KB) $fatxt{'21b'} " . $limit);
			}
			if ($dirlimit) {
				my $dirsize = &dirsize($uploaddir);
				if ($filesize > ((1024 * $dirlimit) - $dirsize)) {
					foreach (@filelist) { &delete_DBorFILE("$uploaddir/$_"); }
					&Preview("$fatxt{'22'} $fixfile (" . (int($filesize / 1024) - $dirlimit + int($dirsize / 1024)) . " KB) $fatxt{'22b'}");
				}
			}

			# create a new file on the server using the formatted ( new instance ) filename
			if (fopen(NEWFILE, ">$uploaddir/$fixfile")) {
				binmode NEWFILE; # needed for operating systems (OS) Windows, ignored by Linux
				print NEWFILE $file_buffer; # write new file on HD
				fclose(NEWFILE);

			} else { # return the server's error message if the new file could not be created
				foreach (@filelist) { &delete_DBorFILE("$uploaddir/$_"); }
				&fatal_error("file_not_open","$uploaddir");
			}

			# check if file has actually been uploaded, by checking the file has a size
			$filesizekb{$fixfile} = -s "$uploaddir/$fixfile";
			unless ($filesizekb{$fixfile}) {
				foreach (qw("@filelist" $fixfile)) { &delete_DBorFILE("$uploaddir/$_"); }
				&fatal_error("file_not_uploaded",$fixfile);
			}
			$filesizekb{$fixfile} = int($filesizekb{$fixfile} / 1024);

			if ($fixfile =~ /\.(jpg|gif|png|jpeg)$/i) {
				my $okatt = 1;
				if ($fixfile =~ /gif$/i) {
					my $header;
					fopen(ATTFILE, "$uploaddir/$fixfile");
					read(ATTFILE, $header, 10);
					my $giftest;
					($giftest, undef, undef, undef, undef, undef) = unpack("a3a3C4", $header);
					fclose(ATTFILE);
					if ($giftest ne "GIF") { $okatt = 0; }
				}
				fopen(ATTFILE, "$uploaddir/$fixfile");
				while ( read(ATTFILE, $buffer, 1024) ) {
					if ($buffer =~ /<(html|script|body)/ig) { $okatt = 0; last; }
				}
				fclose(ATTFILE);
				if(!$okatt) { # delete the file as it contains illegal code
					foreach (qw("@filelist" $fixfile)) { &delete_DBorFILE("$uploaddir/$_"); }
					&fatal_error("file_not_uploaded","$fixfile <= illegal code inside image file!");
				}
			}

			push(@filelist, $fixfile);

		}
	}
	#Create the list of files
	$fixfile = join(",", @filelist);

	# If no thread specified, this is a new thread.
	# Find a valid random ID for it.
	if ($threadid eq '') {
		$newthreadid = &getnewid;
	} else {
		$newthreadid = '';
	}

	# This is only for update, when comming from YaBB lower or equal version 2.2.3
	# I think it can be deleted around version 2.4.0 without causing mayor issues (deti).
	if ($enable_notifications eq '') { $enable_notifications = $enable_notification ? 3 : 0; }
	# End update workaround

	# set announcement flag according to status of current board
	if ($newthreadid) {
		$mreplies = 0;
		if ($iammod || $iamgmod || $iamadmin) { $mstate = $currentboard eq $annboard ? "0a$thestatus" : "0$thestatus"; }
		else { $mstate = "0"; }

		# This is a new thread. Save it.
		my @buffer = &read_DBorFILE(0,FILE,$boardsdir,$currentboard,'txt');
		&write_DBorFILE(0,FILE,$boardsdir,$currentboard,'txt',(qq~$newthreadid|$subject|$name|$email|$date|$mreplies|$username|$icon|$mstate\n~,@buffer));

		&write_DBorFILE(0,'',$datadir,$newthreadid,'txt',(qq~$subject|$name|$email|$date|$username|$icon|0|$user_ip|$message|$ns|||$fixfile\n~));

		if (@filelist) {
			my @temp = &read_DBorFILE(0,AMP,$vardir,'attachments','txt');
			foreach $fixfile (@filelist) {
				push(@temp, qq~$newthreadid|$mreplies|$subject|$name|$currentboard|$filesizekb{$fixfile}|$date|$fixfile|0\n~);
			}
			&write_DBorFILE(0,AMP,$vardir,'attachments','txt',@temp);
		}

		## write the ctb file for the new thread
		${$newthreadid}{'board'}        = $currentboard;
		${$newthreadid}{'replies'}      = 0;
		${$newthreadid}{'views'}        = 0;
		${$newthreadid}{'lastposter'}   = $iamguest ? "Guest-$name" : $username;
		${$newthreadid}{'lastpostdate'} = $newthreadid;
		${$newthreadid}{'threadstatus'} = $mstate;
		&MessageTotals("update", $newthreadid);

		if ($pollthread) { # Save Poll data of new thread AFTER ctb is created (for SQL)!!!
			if (($iamadmin || $iamgmod) && $FORM{'scpoll'}) { # Save ShowcasePoll
					&write_DBorFILE(1,'',$datadir,'poll','showcase',($newthreadid));
			}

			&write_DBorFILE(1,'',$datadir,$newthreadid,'poll',@poll_data);
		}

		if (($enable_notifications == 1 || $enable_notifications == 3) && &checkfor_DBorFILE("$boardsdir/$currentboard.mail")) {
			&ToChars($subject);
			$subject = &Censor($subject);
			&NewNotify($newthreadid, $subject);
		}

	} else {
		# This is an existing thread.
		($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $yyThreadLine);

		if ($mstate =~ /l/i) { # locked thread
			unless (!$bypass_lock_perm || &checkUserLockBypass) { &fatal_error('topic_locked'); }
		}
		if ($staff) { $mstate = $currentboard eq $annboard ? "0a$thestatus" : "0$thestatus"; } # Leave the status as is if the user isn't allowed to change it

		# ctb START
		# Load the current .ctb info but don't close the file befor saving the changed data
		# or you can get wrong .ctb files if two users save at the exact same moment.
		# Therfore we can't use &MessageTotals("load", $threadid); her.
		# File locking should be enabled in AdminCenter!
		# Changes here on @tag must also be done in System.pl -> sub MessageTotals -> my @tag = ...
		# and in Subs.pl in the SQL/File management block: my %db_table = (...
		my @tag = qw(board replies views lastposter lastpostdate threadstatus repliers);

		my $i = 0;
		foreach (&read_DBorFILE(0,'UPDATE_CTB',$datadir,$threadid,'ctb')) {
			if ($use_MySQL) { ${$threadid}{$tag[$i]} = $_; $i++; }
			else { if ($_ =~ /^'(.*?)',"(.*?)"/) { ${$threadid}{$1} = $2; } }
		}

		${$threadid}{'mysql'} = ($use_MySQL && ${$threadid}{'lastpostdate'}) ? 1 : 0;

		# Check if thread has moved. And do necessary access check
		if (${$threadid}{'board'} ne $currentboard) {
			if (&AccessCheck(${$threadid}{'board'}, 2) ne "granted") {
				if ($use_MySQL) {
					# no need to write back to DB
					&mysql_process(0,'do',"UNLOCK TABLES");
				} else {
					@tag = map { qq~'$_',"${$threadid}{$_}"\n~ } @tag;
					unshift(@tag, "### ThreadID: $threadid ###\n\n");
					&write_DBorFILE(0,'UPDATE_CTB',$datadir,$threadid,'ctb',@tag);
				}
				&fatal_error("no_perm_reply");
			}

			# Thread has moved, but we can still post
			# the current board is now the new board.
			$currentboard = ${$threadid}{'board'};
		}

		# update the ctb file for the existing thread with number of replies and lastposter
		${$threadid}{'board'} = $currentboard;
		${$threadid}{'replies'}++;
		${$threadid}{'lastposter'} = $iamguest ? "Guest-$name" : $username;
		${$threadid}{'lastpostdate'} = $date;
		${$threadid}{'threadstatus'} = $mstate;

		if ($use_MySQL) {
			@tag = map { ${$threadid}{$_} } @tag;
		} else {
			@tag = map { qq~'$_',"${$threadid}{$_}"\n~ } @tag;
			unshift(@tag, "### ThreadID: $threadid ###\n\n");
		}

		&write_DBorFILE(${$threadid}{'mysql'},'UPDATE_CTB',$datadir,$threadid,'ctb',@tag);
		# ctb END

		$mreplies = ${$threadid}{'replies'};

		if ($pollthread) { # Save new Poll data
			if (($iamadmin || $iamgmod) && $FORM{'scpoll'}) { # Save ShowcasePoll
					&write_DBorFILE(1,'',$datadir,'poll','showcase',($threadid));
			}
			&write_DBorFILE(1,'',$datadir,$threadid,'poll',@poll_data);
		}

		my @buffer = &read_DBorFILE(0,BOARDFILE,$boardsdir,$currentboard,'txt');
		for ($i = 0; $i < @buffer; $i++) {
			if ($buffer[$i] =~ m~\A$mnum\|~o) { $buffer[$i] = ""; last; }
		}
		&write_DBorFILE(0,BOARDFILE,$boardsdir,$currentboard,'txt',(qq~$mnum|$msub|$mname|$memail|$date|$mreplies|$musername|$micon|$mstate\n~,@buffer));

		&write_DBorFILE(0,'',$datadir,$threadid,'txt',(@{$thread_arrayref{$threadid}},qq~$subject|$name|$email|$date|$username|$icon|~ . scalar(@{$thread_arrayref{$threadid}}) . qq~|$user_ip|$message|$ns|||$fixfile\n~));

		if (@filelist) {
			my @temp = &read_DBorFILE(0,AMP,$vardir,'attachments','txt');
			foreach $fixfile (@filelist) {
				push(@temp, qq~$mnum|$mreplies|$subject|$name|$currentboard|$filesizekb{$fixfile}|$date|$fixfile|0\n~);
			}
			&write_DBorFILE(0,AMP,$vardir,'attachments','txt',@temp);
		}

		&ToChars($subject);
		$subject = &Censor($subject);
		&ReplyNotify($threadid, $subject, $mreplies) if ($enable_notifications == 1 || $enable_notifications == 3);
	} # end else

	if (!$iamguest) {
		${$uid.$username}{'postlayout'} = qq~$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}~;

		# Increment post count and lastpost date for the member.
		# Check whether zeropost board
		if (!${$uid.$currentboard}{'zero'}) {
			${$uid.$username}{'postcount'}++;

			if (${$uid.$username}{'position'}) {
				$grp_after = qq~${$uid.$username}{'position'}~;
			} else {
				foreach $postamount (sort { $b <=> $a } keys %Post) {
					if (${$uid.$username}{'postcount'} >= $postamount) {
						($title, undef) = split(/\|/, $Post{$postamount}, 2);
						$grp_after = $title;
						last;
					}
				}
			}
			&ManageMemberinfo("update", $username, '', '', '', $grp_after, ${$uid.$username}{'postcount'});
		}
		&UserAccount($username, "update", "lastpost+lastonline");
	}

	# The thread ID, regardless of whether it's a new thread or not.
	$thread = $newthreadid || $threadid;

	# Let's figure out what page number to show
	$pageindex = int($mreplies / $maxmessagedisplay);
	$start     = $pageindex * $maxmessagedisplay;

	${$uid.$currentboard}{'messagecount'}++;
	unless ($FORM{'threadid'}) {
		${$uid.$currentboard}{'threadcount'}++;
		++$threadcount;
	}
	$myname = $iamguest ? qq~Guest-$name~ : $username;
	${$uid.$currentboard}{'lastposttime'} = $date;
	${$uid.$currentboard}{'lastposter'} = $myname;
	${$uid.$currentboard}{'lastpostid'} = $thread;
	${$uid.$currentboard}{'lastreply'} = $mreplies;
	${$uid.$currentboard}{'lastsubject'} = $doadsubject;
	${$uid.$currentboard}{'lasttopicstate'} = $mstate;
	${$uid.$currentboard}{'lasticon'} = $icon;
	&BoardTotals("update", $currentboard);

	if(!$iamguest) { &Recent_Write("incr", $thread, $username, $date); }

	if ($favorite && !$hasfavorite) {
		require "$sourcedir/Favorites.pl";
		&AddFav($thread, $mreplies, 1);
	}

	if ($notify && !$hasnotify) {
		&ManageThreadNotify("add", $thread, $username, ${$uid.$username}{'language'}, 1, 1);
	} elsif (!$notify && $hasnotify == 1) {
		&ManageThreadNotify("delete", $thread, $username);
	}

	if ($currentboard eq $annboard) {
		$yySetLocation = qq~$scripturl?virboard=$FORM{'virboard'};num=$thread/$start#$mreplies~;
	} else {
		$yySetLocation = qq~$scripturl?num=$thread/$start#$mreplies~;
	}

	&redirectexit;
}

# We load all the notification strings from a given language and store them in memory
sub LoadNotifyMessages {
	my $languages = shift;
	my $currentlang = $language;
	${$languages}{$currentlang} = 1; # Load the current language too

	foreach my $lang (keys %{$languages}) {
		next if $notifystrings{$lang}{'boardnewtopicnotificationemail'}; # next if allready loaded
		$language = $lang;
		&LoadLanguage('Email');
		$notifystrings{$lang} = {
			'boardnewtopicnotificationemail' => $boardnewtopicnotificationemail,
			'boardnotificationemail' => $boardnotificationemail,
			'topicnotificationemail' => $topicnotificationemail,
		};
		&LoadLanguage('Notify');
		$notifysubjects{$lang} = {
			'118' => $notify_txt{'118'},
			'136' => $notify_txt{'136'},
		};
		$notifycharset{$lang} = {
			'emailcharset' => $emailcharset,
		};
	}
	$language = $currentlang;
}

sub NewNotify {
	my $thisthread = $_[0];
	my $thissubject = $_[1];

	my $boardname;
	($boardname, undef) = split(/\|/, $board{$currentboard}, 2);
	&ToChars($boardname);

	$thissubject .= " ($boardname)";
	$thissubject =~ s/<.*?>//g;
	&FromHTML($thissubject);

	require "$sourcedir/Mailer.pl";

	&ManageMemberinfo("load");
	&ManageBoardNotify("load", $currentboard);
	my %languages;
	foreach (keys %theboard) {
		$languages{(split(/\|/, $theboard{$_}, 2))[0]} = 1;
	}
	&LoadNotifyMessages(\%languages);

	while (my($curuser, $value) = each(%theboard)) {
		my ($curlang, undef) = split(/\|/, $value, 2);
		if ($curuser ne $username) {
			&LoadUser($curuser);
 			if (${$uid.$curuser}{'notify_me'} == 1 || ${$uid.$curuser}{'notify_me'} == 3) {
				(undef, undef, $curmail, undef) = split(/\|/, $memberinf{$curuser}, 4);
				&sendmail($curmail, "$notifysubjects{$curlang}{'136'}: $thissubject", &template_email($notifystrings{$curlang}{'boardnewtopicnotificationemail'}, {'subject' => $thissubject, 'num' => $thisthread}), '', $notifycharset{$curlang}{'emailcharset'});
 			}
			undef %{$uid.$curuser};
 		}
	}
	undef %theboard;
	undef %memberinf;
}

sub ReplyNotify {
	my $thisthread = $_[0];
	my $thissubject = $_[1];
	my $page = qq~$_[2]#$_[2]~;

	my $boardname;
	($boardname, undef) = split(/\|/, $board{$currentboard}, 2);
	&ToChars($boardname);

	$thissubject .= " ($boardname)";
	$thissubject =~ s/<.*?>//g;
	&FromHTML($thissubject);

	require "$sourcedir/Mailer.pl";

	my %mailsent;
	&ManageMemberinfo("load");
	if (&checkfor_DBorFILE("$boardsdir/$currentboard.mail")) {
		&ManageBoardNotify("load", $currentboard);
		my %languages;
		foreach (keys %theboard) {
			$languages{(split(/\|/, $theboard{$_}, 2))[0]} = 1;
		}
		&LoadNotifyMessages(\%languages);

		while (my($curuser, $value) = each(%theboard)) {
			my($curlang, $notify_type, undef) = split(/\|/, $value);
			if ($curuser ne $username && $notify_type == 2) {
				&LoadUser($curuser);
 				if (${$uid.$curuser}{'notify_me'} == 1 || ${$uid.$curuser}{'notify_me'} == 3) {
					(undef, undef, $curmail, undef) = split(/\|/, $memberinf{$curuser}, 4);
					&sendmail($curmail, "$notifysubjects{$curlang}{'136'}: $thissubject", &template_email($notifystrings{$curlang}{'boardnotificationemail'}, {'subject' => $thissubject, 'num' => $thisthread, 'start' => $page}), '', $notifycharset{$curlang}{'emailcharset'});
					$mailsent{$curuser} = 1;
 				}
				undef %{$uid.$curuser};
 			}
		}
		undef %theboard;
	}
	if (&checkfor_DBorFILE("$datadir/$thisthread.mail")) {
		&ManageThreadNotify("load", $thisthread);
		my %languages;
		foreach (keys %thethread) {
			$languages{(split(/\|/, $thethread{$_}, 2))[0]} = 1;
		}
		&LoadNotifyMessages(\%languages);

		while (my($curuser, $value) = each(%thethread)) {
			my($curlang, $notify_type, $hasviewed) = split(/\|/, $value);
			if ($curuser ne $username && !exists $mailsent{$curuser} && $hasviewed) {
				&LoadUser($curuser);
 				if (${$uid.$curuser}{'notify_me'} == 1 || ${$uid.$curuser}{'notify_me'} == 3) {
					(undef, undef, $curmail, undef) = split(/\|/, $memberinf{$curuser}, 4);
					&sendmail($curmail, "$notifysubjects{$curlang}{'118'}: $thissubject", &template_email($notifystrings{$curlang}{'topicnotificationemail'}, {'subject' => $thissubject, 'num' => $thisthread, 'start' => $page}), '', $notifycharset{$curlang}{'emailcharset'});
					$thethread{$curuser} = qq~$curlang|$notify_type|0~;
				}
				undef %{$uid.$curuser};
			}
		}
		&ManageThreadNotify("save", $thisthread);
	}
	undef %memberinf;
}

sub doshowthread {
	my ($line, $tempname, $tempdate, $temppost,$amounter);
	if ($INFO{'start'}) { $INFO{'start'} = "/$INFO{'start'}"; }

	unless (ref($thread_arrayref{$threadid}) || !$threadid) {
		@{$thread_arrayref{$threadid}} = &read_DBorFILE(0,'',$datadir,$threadid,'txt');
	}
	my @messages = @{$thread_arrayref{$threadid}};

	if (@messages) {
		if (@messages < $cutamount) { $cutamount = @messages; }
		$yymain .= qq~
	<br /><br />
<table cellspacing="0" cellpadding="4" width="100%" class="tabtitle">
	<tr><td align="left" class="round_top_left" width="99%">
~;
		$showall = $post_cutts{'3'};

		if (@messages => $cutamount && $showpageall) {
			$showall .= qq~ $post_cutts{'3a'} <a href="$scripturl?action=post;num=$threadid;title=PostReply$INFO{'start'};showall=yes" style="text-decoration: underline;">$post_cutts{'4'}</a> $post_cutts{'5'} ~;
		}

		if ($INFO{'showall'} ne '' || $cutamount eq 'all') {
			$origcutamount = $cutamount;
			$cutamount = $pidtxt{'01'};
			$showall = qq~$post_cutts{'3'} $post_cutts{'3a'} <a href="$scripturl?action=post;num=$threadid;title=PostReply/$INFO{'start'}" style="text-decoration: underline;"> $post_cutts{'4'}</a> $post_cutts{'6'} ~;
		}
		$yymain .= qq~
		<b>$post_txt{'468'} - $post_cutts{'2'} $cutamount $showall</b>
		</td>
		<td class="round_top_right" width="1%">&nbsp;</td>
		</tr>
		</table>
		<table cellspacing="1" cellpadding="4" width="100%" align="center" class="bordercolor" style="table-layout: fixed;">
		~;
		
		if ($tsreverse == 1) { @messages = reverse(@messages); }
		if ($INFO{'showall'} ne '' || $cutamount eq "all") { $cutamount = 1000; }
		for ($amounter = 0; $amounter < $cutamount; $amounter++) {
			(undef, $temprname, undef, $tempdate, $tempname, undef, undef, undef, $message, $ns) = split(/\|/, $messages[$amounter]);
			$messagedate = $tempdate;
			$tempdate = &timeformat($tempdate);
			$parseflash = 0;

			if ($tempname ne 'Guest' && &checkfor_DBorFILE("$memberdir/$tempname.vars")) { &LoadUser($tempname); }
			if (${$uid.$tempname}{'regtime'}) {
				$registrationdate = ${$uid.$tempname}{'regtime'};
			} else {
				$registrationdate = int(time);
			}
			if (${$uid.$tempname}{'regdate'} && $messagedate > $registrationdate) {
				$displaynamelink = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$tempname}" rel="nofollow">${$uid.$tempname}{'realname'}</a>~;
			} elsif ($tempname !~ m~Guest~ && $messagedate < $registrationdate) {
				$displaynamelink = qq~$tempname - $display_txt{'470a'}~;
			} else {
				$displaynamelink = $temprname;
			}

			$usernames_life_quote{$useraccount{$tempname}} = ${$uid.$tempname}{'realname'}; # for display names in Quotes in LivePreview

			my $quickmessage = $message;
			$quickmessage =~ s/<(br|p).*?>/\\r\\n/ig;
			$quickmessage =~ s/'/\\'/g;
			my $quote_mname = $useraccount{$tempname};
			$quote_mname =~ s/'/\\'/g;
			my $quote_msg_id = $tsreverse == 1 ? (@messages - $amounter -1) : $amounter;

			&wrap;
			($message, undef) = &Split_Splice_Move($message,$threadid);
			if ($enable_ubbc) {
				if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
				$displayname = ${$uid.$tempname}{'realname'};
				&DoUBBC;
			}
			&wrap2;
			&ToChars($message);
			$message = &Censor($message);

			unless ($message eq '') {
				$yymain .= qq~
<tr>
	<td align="left" class="titlebg">
		<span class="small">$post_txt{'279'}: $displaynamelink~ . ($enable_markquote ? qq~&nbsp;&nbsp;<a href="javascript:void(quoteSelection('$quote_mname',$threadid,$quote_msg_id,$messagedate,''))">$img{'mquote'}</a>~ : '') . (($enable_quickjump && length($quickmessage) <= $quick_quotelength) ? qq~$menusep<a href="javascript:void(quoteSelection('$quote_mname',$threadid,$quote_msg_id,$messagedate,'$quickmessage'))">$img{'quote'}</a>~ : '') . qq~</span>
		<div style="float:right"><span class="small">$post_txt{'280'}: $tempdate</span></div>
	</td>
</tr>
<tr>
	<td class="windowbg2">
		<div onmouseup="get_selection($quote_msg_id);" style="max-height: 150px; overflow: auto;">
		$message
		</div>
	</td>
</tr>~;
			}
		}
		$yymain .= "</table>\n";
	} else {
		$yymain .= "<!--no summary-->";
	}
}

## Guest can send a PM to FA
## this is a hybrid broadcast message, with fixed audience of FA
## and some guest posting elements in, where id/email are required.
sub sendGuestPM {
	if (!$iamguest) { $yySetLocation = $scripturl; &redirectexit; }
	if (!$PMenableGuestButton) { &fatal_error('no_access'); }
	if ($PMenableBm_level == 0) { &fatal_error('no_access'); }

	$INFO{'title'} = 'PostReply';
	$postthread = 2;

	$name_field = qq~      <tr>
    <td class="windowbg" align="left" width="23%"><label for="name"><b>$post_txt{'68'}:</b></label></td>
    <td class="windowbg" align="left" width="77%"><input type="text" name="name" id="name" size="25" value="$FORM{'name'}" maxlength="25" tabindex="2" /></td>
      </tr>~;
	$email_field = qq~      <tr>
    <td class="windowbg" width="23%"><label for="email"><b>$post_txt{'69'}:</b></label></td>
    <td class="windowbg" width="77%"><input type="text" name="email" id="email" size="25" value="$FORM{'email'}" maxlength="40" tabindex="3" /></td>
      </tr>~;

	if ($gpvalid_en) {
		&validation_code;
		$verification_field = $verification eq ''
		? qq~
			<tr>
				<td class="windowbg" width="23%" valign="top"><label for="verification"><b>$floodtxt{'1'}:</b></label></td>
				<td class="windowbg" width="77%">$showcheck<br /><label for="verification"><span class="small">$floodtxt{'casewarning'}</span></label></td>
			</tr>
			<tr>
				<td class="windowbg" width="23%" valign="top"><label for="verification"><b>$floodtxt{'3'}:</b></label></td>
				<td class="windowbg" width="77%">
				<input type="text" maxlength="30" name="verification" id="verification" size="30" />
				</td>
			</tr>
		~
		: qq~~;
	}
	$sub = '';
	$settofield = 'subject';
	if ($ENV{'HTTP_USER_AGENT'} =~ /(MSIE) (\d)/) {
		if ($2 >= 7.0) { $iecopycheck = ''; } else { $iecopycheck = qq~ checked="checked"~; }
	}
	$t_title = $post_txt{'sendmessguest'};
	$submittxt = $post_txt{'148'};
	$destination = 'guestpm2';
	$icon = 'exclamation';
	$is_preview  = 0;
	$post = 'guestpm';
	$prevmain = '';
	$preview = 'preview';
	$yytitle = $post_txt{'sendmessguest'};
	&Postpage;
	&template;
}

sub sendGuestPM2 {
	if (!$iamguest) { $yySetLocation = $scripturl; &redirectexit; }
	if (!$PMenableGuestButton) { &fatal_error('no_access'); }
	if ($PMenableBm_level == 0) { &fatal_error('no_access'); }
	if ($gpvalid_en) {
		&validation_check($FORM{'verification'});
	}

	# Poster is a Guest then evaluate the legality of name and email
	$FORM{'name'} =~ s/\A\s+//;
	$FORM{'name'} =~ s/\s+\Z//;
	&Preview($post_txt{'75'}) unless ($FORM{'name'} ne '' && $FORM{'name'} ne '_' && $FORM{'name'} ne ' ');
	&Preview($post_txt{'568'}) if (length($FORM{'name'}) > 25);
	&Preview($post_txt{'76'}) if ($FORM{'email'} eq '');
	&Preview("$post_txt{'240'} $post_txt{'69'} $post_txt{'241'}") if ($FORM{'email'} !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/);
	&Preview($post_txt{'500'}) if (($FORM{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($FORM{'email'} !~ /^.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?$/));

	# Get the form values
	$name = $FORM{'name'};
	$email = $FORM{'email'};
	$subject = $FORM{'subject'};
	$message = $FORM{'message'};
	$ns = $FORM{'ns'};
	$threadid = $FORM{'threadid'};
	$posttime = $FORM{'post_entry_time'};
	if ($threadid =~ /\D/) { &fatal_error("only_numbers_allowed"); }

	# Check if poster isn't using a distilled email domain
	&email_domain_check($email);
	my $spamdetected = &spamcheck("$name $subject $message");
	${$uid.$username}{'spamcount'} = 0;
	$postspeed = $date - $posttime;
	if (($speedpostdetection && $postspeed < $min_post_speed) || $spamdetected == 1) {
		${$uid.$username}{'spamcount'}++;
		$spam_hits_left_count = $post_speed_count - ${$uid.$username}{'spamcount'};
		if ($spamdetected == 1) { &fatal_error('tsc_alert'); } else { &fatal_error('speed_alert'); }
	}

	## clean name and email - remove | from name and turn any _ to spaces fro amil
	if ($name && $email) {
		&ToHTML($name);
		$tempname = $name;
		$name =~ s/\_/ /g;
		$email =~ s/\|//g;
		&ToHTML($email);
	}

	# Fixes a bug with posting hexed characters.
	$name =~ s~amp;~~g;

	&Preview($post_txt{'75'}) unless ($username || $name);
	&Preview($post_txt{'76'}) unless (${$uid.$username}{'email'} || $email);
	&Preview($post_txt{'77'}) unless ($subject && $subject !~ m~\A[\s_.,]+\Z~);
	&Preview($post_txt{'78'}) unless ($message);

	# Check Message Length Precisely
	my $mess_len = $message;
	$mess_len =~ s/[\r\n ]//ig;
	$mess_len =~ s/&#\d{3,}?\;/X/ig;
	if (length($mess_len) > $MaxMessLen) {
		&Preview($post_txt{'536'} . " " . (length($mess_len) - $MaxMessLen) . " " . $post_txt{'537'});
	}
	undef $mess_len;

	if ($FORM{'preview'}) { &Preview; }
	&spam_protection;

	my $testsub = $subject;
	$testsub =~ s/[\r\n\ ]|\&nbsp;//g;
	if ($testsub eq '') { fatal_error('useless_post', $testsub); }

	my $testmessage = $message;
	$testmessage =~ s/[\r\n\ ]//g;
	$testmessage =~ s/\&nbsp;//g;
	$testmessage =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
	$testmessage =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;
	$testmessage =~ s/\[.*?\]//g;
	if ($testmessage eq '' && $message ne '') { fatal_error('useless_post', $testmessage); }

	$subject =~ s/[\r\n]//g;
	&FromChars($subject);
	$convertstr = $subject;
	$convertcut = $set_subjectMaxLength + ($subject =~ /^Re: / ? 4 : 0);
	&CountChars;
	$subject = $convertstr;
	&ToHTML($subject);

	$message =~ s/\cM//g;
	$message =~ s~\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[$1$2\]~g;
	$message =~ s~\[/([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[/$1$2\]~g;
	&FromChars($message);
	&ToHTML($message);
	$message =~ s~\t~ \&nbsp; \&nbsp; \&nbsp;~g;
	$message =~ s~\n~<br />~g;
	$message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/g;
	&CheckIcon;

	if (-e ("$datadir/.txt")) { &delete_DBorFILE("$datadir/.txt"); }

	# User is Guest, then make sure the chosen name and email is not reserved or used by a member
	if (lc $name eq lc &MemberIndex('check_exist', $name)) { &fatal_error('guest_taken', "($name)"); }
	if (lc $email eq lc &MemberIndex('check_exist', $email)) { &fatal_error('guest_taken', "($email)"); }

	# Find a valid random ID for it
	$newthreadid = &getnewid;
	# Encode spaces in name, to avoid confusing bm
	$name =~ s/ /%20/g;
	$mreplies = 0;

	# set announcement flag according to status of current board
	@bmessages = &read_DBorFILE(1,'',$memberdir,'broadcast','messages');
	# new format:  #messageid|from user|touser(s)|(ccuser(s))|(bccuser(s))|
	#    subject|date|message|(parentmid)|(reply#)|ip|
	#		messagestatus|flags|storefolder|attachment
	&write_DBorFILE(0,'',$memberdir,'broadcast','messages',("$newthreadid|$name $email|admin|||$subject|$date|$message|$newthreadid|0|$ENV{'REMOTE_ADDR'}|g|||\n",@bmessages));
	undef @bmessages;

	# The thread ID, regardless of whether it's a new thread or not
	$thread = $newthreadid || $threadid;
	$yySetLocation = $scripturl;
	&redirectexit;
}

sub modAlert {
	if ($iamguest && !$PMAlertButtonGuests) { &fatal_error('not_logged_in'); }
	if (!$iamguest && !$PMenableAlertButton) { &fatal_error('no_access'); }
	if ($currentboard eq '' && !$iamguest) { &fatal_error('no_access'); }
	if (!$PM_level) { &fatal_error('no_access'); }

	my $quotemsg = $INFO{'quote'};
	$postid = $INFO{'quote'};
	$threadid = $INFO{'num'};
	my ($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $yyThreadLine);

	# Determine category
	$curcat = ${$uid.$currentboard}{'cat'};
	&BoardTotals("load", $currentboard);

	# Figure out the name of the category
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	($cat, $catperms) = split(/\|/, $catinfo{$curcat});
	&ToChars($cat);

	$INFO{'title'} =~ tr/+/ /;
	$postthread = 2;

	$name_field = $iamguest ? qq~      <tr>
    <td class="windowbg" align="left" width="23%"><label for="name"><b>$post_txt{'68'}:</b></label></td>
    <td class="windowbg" align="left" width="77%"><input type="text" name="name" id="name" size="25" value="$FORM{'name'}" maxlength="25" tabindex="2" /></td>
      </tr>~ : '';

	$email_field = $iamguest ? qq~      <tr>
    <td class="windowbg" width="23%"><label for="email"><b>$post_txt{'69'}:</b></label></td>
    <td class="windowbg" width="77%"><input type="text" name="email" id="email" size="25" value="$FORM{'email'}" maxlength="40" tabindex="3" /></td>
      </tr>~ : '';

	if ($iamguest && $gpvalid_en) {
		&validation_code;
		$verification_field = $verification eq '' ? qq~
			<tr>
				<td class="windowbg" width="23%" valign="top"><label for="verification"><b>$floodtxt{'1'}:</b></label></td>
				<td class="windowbg" width="77%">$showcheck<br /><label for="verification"><span class="small">$floodtxt{'casewarning'}</span></label></td>
			</tr>
			<tr>
				<td class="windowbg" width="23%" valign="top"><label for="verification"><b>$floodtxt{'3'}:</b></label></td>
				<td class="windowbg" width="77%">
				<input type="text" maxlength="30" name="verification" id="verification" size="30" />
				</td>
			</tr>
		~ : '';
	}

	$sub = '';
	$settofield = 'subject';
	if ($threadid ne '') {
		unless (ref($thread_arrayref{$threadid})) {
			@{$thread_arrayref{$threadid}} = &read_DBorFILE(0,'',$datadir,$threadid,'txt');
		}
		if ($quotemsg ne '') {
			($msubject, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $mmessage, $mns) = split(/\|/, ${$thread_arrayref{$threadid}}[$quotemsg]);
			$message = $mmessage;
			$message =~ s~<br.*?>~\n~ig;
			$message =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/ig;
			if (!$nestedquotes) {
				$message =~ s~\n{0,1}\[quote([^\]]*)\](.*?)\[/quote([^\]]*)\]\n{0,1}~\n~isg;
			}
			$mname ||= $musername || $post_txt{'470'};
			my $hidename = $musername;
			$hidename = $mname if $musername eq 'Guest';
			$hidename = &cloak($hidename) if $do_scramble_id;
			my $maxlengthofquote = $MaxMessLen - length(qq~[quote author=$hidename link=$threadid/$quotemsg#$quotemsg date=$mdate\]\[/quote\]\n~) - 3;
			if (length $message >= $maxlengthofquote) {
				require "$sourcedir/System.pl";
				&LoadLanguage('Error'); &alertbox($error_txt{'quote_too_long'});
				$message = substr($message, 0, $maxlengthofquote) . '...';
			}
			$message    = qq~[quote author=$hidename link=$threadid/$quotemsg#$quotemsg date=$mdate\]$message\[/quote\]\n~;
			$msubject =~ s/\bre:\s+//ig;
			if ($mns eq 'NS') { $nscheck = 'checked'; }
		} else {
			($msubject, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $mmessage, $mns) = split(/\|/, ${$thread_arrayref{$threadid}}[0]);
			$msubject =~ s/\bre:\s+//ig;
		}
		$sub = "Re: $msubject";
		$settofield = 'message';
	}

	if ($ENV{'HTTP_USER_AGENT'} =~ /(MSIE) (\d)/) {
		if($2 >= 7.0) { $iecopycheck = ''; } else { $iecopycheck = qq~ checked="checked"~; }
	}

	$t_title = $post_txt{'alertmod'};
	$submittxt = $post_txt{'148'};
	$destination = 'modalert2';
	$icon = 'exclamation';
	$is_preview  = 0;
	$post = 'modalert';
	$prevmain = '';
	$preview = 'preview';
	$yytitle = $post_txt{'alertmod'};
	&Postpage;
	&template;
}

sub modAlert2 {
	if ($iamguest && !$PMAlertButtonGuests) { &fatal_error('not_logged_in'); }
	if (!$iamguest && !$PMenableAlertButton) { &fatal_error('no_access'); }
	if (!$PM_level) { &fatal_error('no_access'); }
	if ($iamguest && $gpvalid_en) {
		&validation_check($FORM{'verification'});
	}

	# Get the form values
	$name = $FORM{'name'};
	$email = $FORM{'email'};
	$subject = $FORM{'subject'};
	$message = $FORM{'message'};
	$ns = $FORM{'ns'};
	$threadid = $FORM{'threadid'};
	$postid = $FORM{'postid'};
	$posttime = $FORM{'post_entry_time'};
	if ($threadid =~ /\D/) { &fatal_error('only_numbers_allowed'); }

	if ($iamguest) {
		$name =~ s/\A\s+//;
		$name =~ s/\s+\Z//;
		&Preview($post_txt{'75'}) unless ($name ne '' && $name ne '_' && $name ne ' ');
		&Preview($post_txt{'568'}) if (length($name) > 25);
		&Preview($post_txt{'76'}) if ($email eq '');
		&Preview("$post_txt{'240'} $post_txt{'69'} $post_txt{'241'}") if ($email !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/);
		&Preview($post_txt{'500'}) if (($email =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($email !~ /^.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?$/));

		## clean name and email - remove | from name and turn any _ to spaces fro amil
		&ToHTML($name);
		$tempname = $name;
		$name =~ s/_/ /g;
		$email =~ s/\|//g;
		&ToHTML($email);

		# Fixes a bug with posting hexed characters
		$name =~ s~amp;~~g;

		# If user is Guest, then make sure the chosen name and email is not reserved or used by a member
		if (lc $name eq lc &MemberIndex('check_exist', $name)) { &fatal_error('guest_taken',"($name)"); }
		if (lc $email eq lc &MemberIndex('check_exist', $email)) { &fatal_error('guest_taken',"($email)"); }

		# Encode spaces in name, to avoid confusing!
		$name =~ s/ /%20/g;
		$name .= qq~ $email~;
	} else {
		$name = $username;
	}

	# Check if poster isn't using a distilled email domain
	&email_domain_check($email);
	my $spamdetected = &spamcheck("$name $subject $message");
	if (!${$uid.$FORM{$username}}{'spamcount'}) { ${$uid.$FORM{$username}}{'spamcount'} = 0; }
	$postspeed = $date - $posttime;
	if (!$staff){
		if (($speedpostdetection && $postspeed < $min_post_speed) || $spamdetected == 1) {
			${$uid.$username}{'spamcount'}++;
			${$uid.$username}{'spamtime'} = $date;
			&UserAccount($username,"update");
			$spam_hits_left_count = $post_speed_count - ${$uid.$username}{'spamcount'};
			if ($spamdetected == 1){ &fatal_error('tsc_alert'); } else { &fatal_error('speed_alert'); }
		}
	}

	&Preview($post_txt{'75'}) unless ($username || $name);
	&Preview($post_txt{'76'}) unless (${$uid.$username}{'email'} || $email);
	&Preview($post_txt{'77'}) unless ($subject && $subject !~ m~\A[\s_.,]+\Z~);
	&Preview($post_txt{'78'}) unless ($message);

	# Check Message Length Precisely
	my $mess_len = $message;
	$mess_len =~ s/[\r\n ]//ig;
	$mess_len =~ s/&#\d{3,}?\;/X/ig;
	if (length($mess_len) > $MaxMessLen) {
		&Preview($post_txt{'536'} . " " . (length($mess_len) - $MaxMessLen) . " " . $post_txt{'537'});
	}
	undef $mess_len;

	if ($FORM{'preview'}) { &Preview; }
	&spam_protection;

	$subject =~ s/[\r\n]//g;
	my $tstsubject = $subject;
	my $testsub = $subject;
	$testsub =~ s/ |\&nbsp;//g;
	if ($testsub eq '') { fatal_error('useless_post', $testsub); }

	my $testmessage = $message;
	$testmessage =~ s/[\r\n\ ]//g;
	$testmessage =~ s/\&nbsp;//g;
	$testmessage =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
	$testmessage =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;
	$testmessage =~ s/\[.*?\]//g;
	if ($testmessage eq '' && $message ne '') { fatal_error('useless_post', $testmessage); }

	&FromChars($subject);
	$convertstr = $subject;
	$convertcut = $set_subjectMaxLength + ($subject =~ /^Re: / ? 4 : 0);

	&CountChars;
	$subject = $convertstr;
	&ToHTML($subject);

	$message =~ s/\cM//g;
	$message =~ s~\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[$1$2\]~g;
	$message =~ s~\[/([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[/$1$2\]~g;
	&FromChars($message);
	&ToHTML($message);
	$message =~ s~\t~ \&nbsp; \&nbsp; \&nbsp;~g;
	$message =~ s~\n~<br />~g;
	$message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/g;

	if (-e ("$datadir/.txt")) { &delete_DBorFILE("$datadir/.txt"); }
	
	# Find a valid random ID for it
	$newthreadid = &getnewid;

	# This is only for update, when comming from YaBB lower or equal version 2.2.3
	# I think it can be deleted around version 2.4.0 without causing mayor issues (deti).
	if ($enable_notifications eq '') { $enable_notifications = $enable_notification ? 3 : 0; }
	# End update workaround

	my $x;
	my $mods = ${$uid.$currentboard}{'mods'};
	my $modgrps = ${$uid.$currentboard}{'modgroups'};
	$modgrps =~ s/, /,/g; # because modgroups are saved with ' ' and this MyCenter.pl does not understand ;-)
	# If no BM is allowed and no mods is assigned => send the "AlertMod" to admin
	if (!$PMenableBm_level && !$mods) {
		$mods = $mods ? $mods : 'admin';
	# If BM is allowed and no mods and no moderator group is assigned => send the "AlertMod" to admin and gmods via BM
	} elsif ($PMenableBm_level && !$mods && !$modgrps) {
		$modgrps = $PMenableBm_level == 3 ? "admins" : "admins,gmods";
	}
	# Check if there is at least one user in the moderator group
	# if not and no mod is assigned too => send the "AlertMod" to admin via PM
	if ($PMenableBm_level && $modgrps) {
		if ($modgrps =~ /admins|gmods|mods/) { $x = 1; }
		else {
			&ManageMemberinfo("load");
			manageinfo: foreach (keys %memberinf) {
				map { if ($_ && $modgrps =~ /\b$_\b/) { $x = 1; last manageinfo; } } split(/,/, (split(/\|/, $memberinf{$_}, 7))[5]);
			}
			$mods = 'admin' if !$x && !$mods;
		}
	}
	if ($mods) {
		managemods: foreach my $toBoardMod (split(/, ?/, $mods)) {
			chomp $toBoardMod;
			# Send notification (Will only work if Admin has allowed the Email Notification)
			&LoadUser($toBoardMod);
			if (${$uid.$toBoardMod}{'notify_me'} > 1 && $enable_notifications > 1 && ${$uid.$toBoardMod}{'email'} ne '') {
				require "$sourcedir/Mailer.pl";
				$language = ${$uid.$toBoardMod}{'language'};
				&LoadLanguage('Email');
				&LoadLanguage('Notify');
				&LoadLanguage('InstantMessage');
				my $msubject = $tstsubject ? $tstsubject : $inmes_txt{'767'};
				&ToChars($msubject);
				my $chmessage = $message;
				&ToChars($chmessage);
				$chmessage =~ s~\[b\](.*?)\[/b\]~*$1*~isg;
				$chmessage =~ s~\[i\](.*?)\[/i\]~/$1/~isg;
				$chmessage =~ s~\[u\](.*?)\[/u\]~_$1_~isg;
				$chmessage =~ s~\[.*?\]~~g;
				$chmessage =~ s~<br.*?>~\n~ig;
				$chmessage = &template_email($privatemessagenotificationemail, {'date' => &timeformat($date), 'subject' => $msubject, 'sender' => ${$uid.$username}{'realname'}, 'message' => $chmessage});
				&sendmail(${$uid.$toBoardMod}{'email'}, $notify_txt{'145'}, $chmessage, '', $emailcharset);

			} elsif ($PMenableBm_level && $x) {
				&ManageMemberinfo("load");
				map { if ($_ && $modgrps =~ /\b$_\b/) { next managemods; } } split(/,/, (split(/\|/, $memberinf{$toBoardMod}, 7))[5]);
			}

			# Send message to user
			my @inmessages = &read_DBorFILE(0,'',$memberdir,$toBoardMod,'msg');
			# new format: messageid|from user|touser(s)|(ccuser(s))|(bccuser(s))|
			#	subject|date|message|(parentmid)|(reply#)|ip|
			#		messagestatus|flags|storefolder|attachment
			&write_DBorFILE(0,'',$memberdir,$toBoardMod,'msg',("$newthreadid|$name|$toBoardMod|||$subject|$date|$message|$newthreadid|0|$ENV{'REMOTE_ADDR'}|a|u||\n", @inmessages));
		}
	}

	if ($PMenableBm_level && $x) {
		# set announcement flag according to status of current board
		my @inmessages = &read_DBorFILE(0,'',$memberdir,'broadcast','messages');
		# new format:  #messageid|from user|touser(s)|(ccuser(s))|(bccuser(s))|
		#    subject|date|message|(parentmid)|(reply#)|ip|
		#		messagestatus|flags|storefolder|attachment
		&write_DBorFILE(0,'',$memberdir,'broadcast','messages',("$newthreadid|$name|$modgrps|||$subject|$date|$message|$newthreadid|0|$ENV{'REMOTE_ADDR'}|ab|||\n",@inmessages));
	}

	$yySetLocation = qq~$scripturl?num=$threadid/$postid#$postid~;
	&redirectexit;
}

1;