###############################################################################
# InstantMessage.pl                                                           #
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

$instantmessageplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

## create the send IM section of the screen

####
# new format:  for  msg file:
#messageid|(from)user|(touser(s))|(ccuser(s))|(bccuser(s))|
#	subject|date|message|(parentmid)|reply#|ip|messagestatus|
#		flags|storefolder|attachment

# (optional) [placeholder]

# for outbox:
#messageid|(from)user|(touser(s))|(ccuser(s))|(bccuser(s))|
#	subject|date|message|(parentmid)|reply#|ip|messagestatus|
#		flags|storefolder|attachment

## messagestatus = c(onfidential)/h(igh importance)/s(tandard)/a(lert)/g(uest)/(b)roadcast/(n)otify of post
## flags = u(nread)/f(orward)/q(oute)/r(eply)/c(alled back)
## parentmid = stays same
## reply# = increments for replies, so we can build conversation threads

## storefolder = name of storage folder. Start with in & out for everyone. 
#1	$mnum = 3;
#2	$imnewcount = 0;
#3	$moutnum = 17;
#4	$storenum = 0;
#5	$draftnum = 0;
#6	@folders  (name1|name2|name3)

# MF-B: new .ims file format
#	### YaBB UserIMS ###
#	'${$username}{'PMmnum'}',"value"
#	'${$username}{'PMimnewcount'}',"value"
#	'${$username}{'PMmoutnum'}',"value"
#	'${$username}{'PMstorenum'}',"value"
#	'${$username}{'PMdraftnum'}',"value"
#	'${$username}{'PMfolders'}',"value"
#	'${$username}{'PMfoldersCount'}',"value"

#	@storecurrentin = qw/ /; # list of messages in .imstore from msg
#	@storecurrentout = qw/ /; # list of messages in .imstore from outbox



sub buildIMsend {
	&LoadLanguage('InstantMessage');
	&LoadLanguage('Post');
	&LoadCensorList;

	if ($FORM{'previewim'}) {
		require "$sourcedir/Post.pl";
		if (!$error){ &Preview; $subject = $csubject; }
		else { &Preview($error); }
		&FromHTML($message);
		&FromHTML($subject);
	}
	$mctitle = $inmes_txt{'775'};
	## check for a draft being opened
	if ($INFO{'caller'} == 4 && $INFO{'id'}) {
		my @draftPM = &read_DBorFILE(0,'',$memberdir,$username,'imdraft');
		chomp(@draftPM);
		my $flagfound;
		foreach my $draftMess (@draftPM) {
			my ($checkId, undef) = split(/\|/, $draftMess, 2);
			if ($checkId eq $INFO{'id'}){
				($dmessageid, $dmusername, $userto, $usernamecc, $usernamebcc, $subject, $dmdate, $message, $dmpmessageid, $dmreplyno, $dmips, $dmessageStatus, $dmessageFlags, $dstoreFolder, $dmessageAttachment) = split(/\|/, $draftMess);
				$flagfound = 1;
				last;
			}
		}
		if (!$flagfound) { &fatal_error('cannot_find_draftmess'); }
		&FromHTML($message);
		&FromHTML($subject);
	}

	my $pmicon = 'standard';
	$stselect = '';
	$urselect = '';
	$cnselect = '';
	if ($FORM{'status'} || $INFO{'status'}) { $thestatus = $FORM{'status'} || $INFO{'status'}; }
	elsif ($dmessageStatus){ $thestatus = $dmessageStatus; }
	else { $thestatus = 's'; }

	if ($thestatus eq 's') { $stselect = qq~ selected="selected"~; }
	elsif ($thestatus eq 'u') { $urselect = qq~ selected="selected"~; }
	elsif ($thestatus eq 'c') { $cnselect = qq~ selected="selected"~; }
	elsif ($thestatus eq 'sb') { $stselect = qq~ selected="selected"~; $sendBMess = 1; }
	elsif ($thestatus eq 'ub') { $urselect = qq~ selected="selected"~; $sendBMess = 1; }
	elsif ($thestatus eq 'cb') { $cnselect = qq~ selected="selected"~; $sendBMess = 1; }
	$sendBMess = 0 unless $sendBMess == 1 && (($PMenableBm_level == 1 && $staff) || ($PMenableBm_level == 2 && ($iamadmin || $iamgmod)) || ($PMenableBm_level == 3 && $iamadmin));

	##########   post code   #########
	if (!$staff && ${$uid.$username}{'postcount'} < $numposts) {
		&fatal_error('im_low_postcount');
	}

	if (!$replyguest) {
		if ($is_preview) { $post_txt{'507'} = $post_txt{'771'}; }
		$normalquot = $post_txt{'599'};
		$simpelquot = $post_txt{'601'};
		$simpelcode = $post_txt{'602'};
		$edittext = $post_txt{'603'};
		if (!$fontsizemax) { $fontsizemax = 72; }
		if (!$fontsizemin) { $fontsizemin = 6; }

		# this defines what the top area of the post box will look like: 
		## if this is a reply , load the 'from' name off the message
		if ($INFO{'reply'} || $INFO{'quote'}) { $INFO{'to'} = $mfrom; }
		if (!$INFO{'to'} && $FORM{'to'} ne '') { $INFO{'to'} = $FORM{'to'}; }

		## if cloaking is enabled, and 'to' is not a blank
		if ($do_scramble_id && $INFO{'to'} ne '') {
			&decloak($INFO{'to'});
		}

		if (!$sendBMess) { &LoadUser($INFO{'to'}); }
	}


	$message =~ s~<br.*?>~\n~gi;
	$message =~ s/&nbsp;/ /g;
	&ToChars($message);
	$message = &Censor($message);
	&ToHTML($message);
	$message =~ s/ &nbsp; &nbsp; &nbsp;/\t/ig;

	if ($msubject) { $subject = $msubject; }
	&ToChars($subject);
	$subject = &Censor($subject);
	&ToHTML($subject);


	if ($action eq "modify" || $action eq "modify2") {
		$displayname = qq~$mename~;
	} else {
		$displayname = ${$uid.$username}{'realname'};
	}
	require "$sourcedir/ContextHelp.pl";
	&ContextScript("post");

	$MCGlobalFormStart .= qq~
	$ctmain
	<script language="JavaScript1.2" src="$yyhtml_root/yabbc.js" type="text/javascript"></script>
	<script language="JavaScript1.2" src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
	<script language="JavaScript1.2" type="text/javascript">
	var displayNames = new Object();
	$template_names
	</script>
	~;

	if ($prevmain && !$replyguest) {
		$imsend .= qq~
	<tr>
		<td class="windowbg">
		$prevmain
		</td>
	</tr>
	~;
	}

	if (((!$enable_PMcontrols && $enable_PMActprev) || ($enable_PMcontrols && ${$uid.$username}{'pmactprev'})) && !$replyguest) {
		$imsend .= qq~
	<tr>
		<td class="windowbg" valign="top">
			<table width="95%" align="left" cellpadding="2">
			 <tr>
			  <td align="left">
			   <img name="prevwin" id="prevwin" src="$defaultimagesdir/cat_expand.gif" alt="$npf_txt{'01'}" title="$npf_txt{'01'}" border="0" style="cursor:pointer; cursor:hand;" onclick="enabPrev();" /> <b>$npf_txt{'04'}</b>
			  </td>
			 </tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="windowbg">
			<div id="savetable" class="bordercolor" style="height:0px; padding:1px; width:100%; margin:auto; visibility:hidden;">
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
	</tr>
		~;
	}
	
	if ($replyguest) {
		$imsend .= qq~
	<tr>
		<td class="windowbg2">
		$guest_reply{'guesttext'}
		</td>
	</tr>
		~;
	}

	$imsend .= qq~
	<tr>
		<td class="windowbg" width="50%">
			<table width="95%" align="left" cellpadding="2">~;

	if (!$replyguest && !$sendBMess && ($PMenable_cc || $PMenable_bcc)) {
		$yyjavascripttoform = qq~

			<script language="JavaScript1.2" type="text/javascript">
			<!--
			function changeRecepientTab(tabto) {
				document.getElementById('usersto').style.display = 'none';
				document.getElementById('bnttoto').className = 'windowbg';
		~;

		$imsend .= qq~
				<tr>
					<td align="left">
					<div id="bnttoto" style="float: left; padding: 5px;" class="windowbg2"><a href="javascript:void(0);" onclick="changeRecepientTab('to'); return false;">$inmes_txt{'324'}:</a></div>
		~;	
		if ($PMenable_cc) {
			$yyjavascripttoform .= qq~
				document.getElementById('userscc').style.display = 'none';
				document.getElementById('bnttocc').className = 'windowbg';
			~;
			$imsend .= qq~
					<div id="bnttocc" style="float: left; padding: 5px;" class="windowbg"><a href="javascript:void(0);" onclick="changeRecepientTab('cc'); return false;">$inmes_txt{'325'}:</a></div>
			~;	
		}
		if ($PMenable_bcc) {
			$yyjavascripttoform .= qq~
				document.getElementById('usersbcc').style.display = 'none';
				document.getElementById('bnttobcc').className = 'windowbg';
			~;
			$imsend .= qq~
					<div id="bnttobcc" style="float: left; padding: 5px;" class="windowbg"><a href="javascript:void(0);" onclick="changeRecepientTab('bcc'); return false;">$inmes_txt{'326'}:</a></div>
			~;	
		}
		$yyjavascripttoform .= qq~
				document.getElementById('users' + tabto).style.display = 'inline';
				document.getElementById('bntto' + tabto).className = 'windowbg2';
			}
		//-->
		</script>
		~;
		$imsend .= qq~$yyjavascripttoform
					</td>
				</tr>
		~;
	}

	$imsend .= qq~
				<tr>
					<td width="60%" valign="top" align="left">\n~;

	# now uses a multi-line select 
	&ProcIMrecs;

	$toname = $INFO{'forward'} ? '' : $INFO{'to'};

	my $toUsersTitle = $inmes_txt{'torecepients'};

	my ($onchangeText, $onchangeText2);
	if (((!$enable_PMcontrols && $enable_PMActprev) || ($enable_PMcontrols && ${$uid.$username}{'pmactprev'})) && !$replyguest) {
		$onchangeText = qq~ onkeyup="updatTopic();"~;
		$onchangeText2 = qq~ updatTopic();~;
	}

	if (!$replyguest) {
		if ($sendBMess) { $toUsersTitle = $inmes_txt{'togroups'}; }
		if ($PMenable_cc || $PMenable_bcc) {
			$us_winhight = 370;
		} else {
			$us_winhight = 345;
		}

		my $toIdtext = $sendBMess ? 'groups' : 'toshow';

		$imsend  .= qq~
		<script language="JavaScript1.2" type="text/javascript">
		<!--
		function imWin() {
			window.open('$scripturl?action=imlist;sort=recentpm;toid=$toIdtext','imWin','status=no,height=$us_winhight,width=464,menubar=no,toolbar=no,top=50,left=50,scrollbars=no');
		}
		function imWinCC() {
			window.open('$scripturl?action=imlist;sort=recentpm;toid=toshowcc','imWin','status=no,height=$us_winhight,width=464,menubar=no,toolbar=no,top=50,left=50,scrollbars=no');
		}
		function imWinBCC() {
			window.open('$scripturl?action=imlist;sort=recentpm;toid=toshowbcc','imWin','status=no,height=$us_winhight,width=464,menubar=no,toolbar=no,top=50,left=50,scrollbars=no');
		}
		function removeUser(oElement) {
			var indexToRemove = oElement.options.selectedIndex;
			if (confirm("$post_txt{'768'}")) { oElement.remove(indexToRemove); }
		}
		//-->
		</script>
		<div id="usersto" style="width: 98%; display: inline; float: left;">
		<b>$inmes_txt{'324'} $toUsersTitle:</b>&nbsp;<a href="javascript: void(0);" onclick="imWin();" tabindex="1"><span class="small">$inmes_txt{'clickto1'} <i>$inmes_txt{'324'}</i> $toUsersTitle $inmes_txt{'clickto2'}</span></a><br />
		<select name="toshow" id="toshow" multiple="multiple" size="6" style="width: 100%;" ondblclick="removeUser(this);">\n~;

		my $usefields;
		if (!$sendBMess) {
			if ($toname) {
				&LoadUser($toname);
				if(${$uid.$toname}{'realname'}) {
					$imsend  .= qq~<option selected="selected" value="$useraccount{$toname}">${$uid.$toname}{'realname'}</option>\n~;
				}
			}
			if ($FORM{'toshow'}) {
				foreach my $touser (split(/,/, $FORM{'toshow'})) {
					&LoadUser($touser);
					$imsend .= qq~<option selected="selected" value="$useraccount{$touser}">${$uid.$touser}{'realname'}</option>\n~;
				}
			}
			if ($userto) {
				foreach my $touser (split(/,/, $userto)) {
					&LoadUser($touser);
					$imsend .= qq~<option selected="selected" value="$useraccount{$touser}">${$uid.$touser}{'realname'}</option>\n~;
				}
			}

		} else {
			$FORM{'toshow'} = $mto || $FORM{'toshow'};
			if ($FORM{'toshow'}) {
				foreach my $touser (split(/,/, $FORM{'toshow'})) {
					if ($touser eq 'all') { $imsend .= qq~<option selected="selected" value="all">$inmes_txt{'bmallmembers'}</option>\n~;
					} elsif ($touser eq 'admins') { $imsend .= qq~<option selected="selected" value="admins">$inmes_txt{'bmadmins'}</option>\n~;
					} elsif ($touser eq 'gmods') { $imsend .= qq~<option selected="selected" value="gmods">$inmes_txt{'bmgmods'}</option>\n~;
					} elsif ($touser eq 'mods') { $imsend .= qq~<option selected="selected" value="mods">$inmes_txt{'bmmods'}</option>\n~;
					} else {
						foreach (keys %NoPost) {
							my ($title, undef) = split(/\|/, $NoPost{$_}, 2);
							if ($touser eq $_) { $imsend .= qq~<option selected="selected" value="$_">$title</option>\n~; }
						}
					}
				}
			}
		}

		$imsend .= qq~			</select><input type="hidden" name="immulti" value="yes" />
			</div>
		~;

		$JSandInput = qq~
		<script language="JavaScript1.2" type="text/javascript">
		<!--
		// this function forces all users listed on IM mult to be selected for processing
		function selectNames() {
			var oList = document.getElementById('toshow')
			for (var i = 0; i < oList.options.length; i++) { oList.options[i].selected = true; }
		~;

		if (!$sendBMess) {
			if ($PMenable_cc) {
				$JSandInput .= qq~
					var oList = document.getElementById('toshowcc') 
					for (var i = 0; i < oList.options.length; i++){ oList.options[i].selected = true; }
				~;
				$imsend .= qq~
				<div id="userscc" style="width: 98%; display: none; float: left;">
				<b>$inmes_txt{'325'} $toUsersTitle:</b>&nbsp;<a href="javascript: void(0);" onclick="imWinCC();"><span class="small">$inmes_txt{'clickto1'} <i>$inmes_txt{'325'}</i> $toUsersTitle $inmes_txt{'clickto2'}</span></a><br />
				<select name="toshowcc" id="toshowcc" multiple="multiple" size="6" style="width: 100%;" ondblclick="removeUser(this);">\n~;
				if ($FORM{'toshowcc'}) {
					foreach my $touser (split(/\,/, $FORM{'toshowcc'})) {
						&LoadUser($touser);
						$imsend .= qq~<option selected="selected" value="$useraccount{$touser}">${$uid.$touser}{'realname'}</option>\n~;
					}
				}
				if ($usernamecc) {
					foreach my $touser (split(/\,/, $usernamecc)) {
						&LoadUser($touser);
						$imsend .= qq~<option selected="selected" value="$useraccount{$touser}">${$uid.$touser}{'realname'}</option>\n~;
					}
				}
				$imsend .= qq~				</select>
				</div>
				~;
			}

			if ($PMenable_bcc) {
				$JSandInput .= qq~
					var oList = document.getElementById('toshowbcc')
					for (var i = 0; i < oList.options.length; i++) { oList.options[i].selected = true; }
				~;
				$imsend .= qq~
				<div id="usersbcc" style="width: 98%; display: none; float: left;">
				<b>$inmes_txt{'326'} $toUsersTitle:</b>&nbsp;<a href="javascript: void(0);" onclick="imWinBCC();"><span class="small">$inmes_txt{'clickto1'} <i>$inmes_txt{'326'}</i> $toUsersTitle $inmes_txt{'clickto2'}</span></a><br />
				<select name="toshowbcc" id="toshowbcc" multiple="multiple" size="6" style="width: 100%;" ondblclick="removeUser(this);">\n~;
				if ($FORM{'toshowbcc'}) {
					foreach my $touser (split(/\,/, $FORM{'toshowbcc'})) {
						&LoadUser($touser);
						$imsend .= qq~<option selected="selected" value="$useraccount{$touser}">${$uid.$touser}{'realname'}</option>\n~;
					}
				}
				if ($usernamebcc) {
					foreach my $touser (split(/\,/, $usernamebcc)) {
						&LoadUser($touser);
						$imsend .= qq~<option selected="selected" value="$useraccount{$touser}">${$uid.$touser}{'realname'}</option>\n~;
					}
				}
				$imsend .= qq~				</select> 
				</div>
				~;
			}
		}

		$JSandInput .= qq~
			}
		//-->
		</script>
		~;

		$imsend .= qq~
					</td>
					<td width="40%" valign="top" align="left">
						<label for="status"><b>$inmes_txt{'status'}:</b></label><br />
						<select name="status" id="status" tabindex="2" size="3" onchange="showtpstatus();$onchangeText2">
						<option value="s"$stselect>$im_message_status{'standard'}</option>
						<option value="c"$cnselect>$im_message_status{'confidential'}</option>
						<option value="u"$urselect>$im_message_status{'urgent'}</option>
						</select><img src="$imagesdir/$pmicon.gif" name="icons" border="0" hspace="10" alt="$im_message_status{'$pmicon'}" title="$im_message_status{'$pmicon'}" />
					</td>
					</tr>
				</table>
			</td> 
		</tr>
		~;

	} else {

		$imsend .= qq~						<b>$inmes_txt{'324'} $toUsersTitle:</b> <input type="text" name="toguest" id="toguest" value="$guestName" size="50" maxlength="25" style="width: 95%;" /><input type="hidden" name="toshow" id="toshow" value="$guestName" />
					</td>
					<td width="40%" valign="top" align="left">
						&nbsp;
					</td>
				</tr>
				<tr>
					<td width="60%" valign="top" align="left">
						<b>$post_txt{'69'}:</b> <input type="text" name="guestemail" id="guestemail" value="$guestEmail" size="50" maxlength="40" style="width: 95%;" />
						<input type="hidden" name="replyguest" id="replyguest" value="1" />
					</td>
					<td width="40%" valign="top" align="left">
						&nbsp;
					</td>
				</tr>
				</table>
			</td> 
		</tr>
		~;
	}

	$subtitle = "<i>$subject</i>";
	#this is the end of the upper area of the post page.

	# this declares the beginning of the UBBC section
	$JSandInput .= qq~
	<script language="JavaScript1.2" type="text/javascript">
	<!--
	function showimage() {
		document.images.status.src=document.postmodify.status.options[document.postmodify.images.status.selectedIndex].value;
	}
	//-->
	</script>
	~;

	$JSandInput .= qq~
	<input type="hidden" name="threadid" id="threadid" value="$threadid" />
	<input type="hidden" name="postid" id="postid" value="$postid" />
	<input type="hidden" name="info" id="info" value="$INFO{'id'}$FORM{'info'}" />
	<input type="hidden" name="mename" id="mename" value="$mename" />
	<input type="hidden" name="post_entry_time" id="post_entry_time" value="$date" />
	~;

	if ($FORM{'draftid'} || $INFO{'caller'} == 4) {
		$JSandInput .= qq~<input type="hidden" name="draftid" id="draftid" value="~ . ($FORM{'draftid'} || $INFO{'id'}) . qq~" />~;
	}

	$imsend .= qq~
	<tr>
		<td align="left" class="windowbg2">
			$JSandInput
			<label for="subject"><b>$inmes_txt{'70'}:</b></label><br /><input type="text" name="subject" id="subject" value="$subject" size="50" maxlength="~ . ($set_subjectMaxLength + ($subject =~ /^Re: / ? 4 : 0)) . qq~" tabindex="3" style="width: 437px;"$onchangeText />
		</td>

	</tr>
	<tr>
		<td class="windowbg2">
	~;

	# this is for the ubbc buttons
	if (!$replyguest) {
		if ($enable_ubbc && $showyabbcbutt) {
			$imsend .= qq~<b>$post_txt{'252'}:</b><br />
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
			document.write('<option value="Verdana" style="font-family: Verdana" selected="selected">Verdana</option>');
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
			</div><div id="spell_container" style="float: left;"></div>
			~;
		}
	}

	if ($replyguest) {
		$tmpmtext =qq~<b>$post_txt{'72'}:</b> ~;
	}

	# set size of messagebox and text
	if (!${$uid.$username}{'postlayout'}) { $pheight = 130; $pwidth = 425; $textsize = 10; }
	else { ($pheight, $pwidth, $textsize, $col_row) = split(/\|/, ${$uid.$username}{'postlayout'}); }
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

	$imsend .= qq~
		<div style="float: left; width: 99%;">
		<div style="float: left; text-align: left;">
		<input type="hidden" name="col_row" value="$col_row" />
		<input type="hidden" name="messagewidth" id="messagewidth" value="$pwidth" />
		<input type="hidden" name="messageheight" id="messageheight" value="$pheight" />
		<div id="dragcanvas" style="position: relative; top: 0px; left: 0px; height: $dheight; width: $dwidth; border: 0; z-index: 1;">
		<textarea name="message" id="message" rows="8" cols="68" style="position: absolute; top: 0px; left: 0px; z-index: 2; height: $mheight; width: $mwidth; font-size: $mtextsize; padding: 5px; margin: 0px; visibility: visible;" onclick="storeCaret(this);" onkeyup="storeCaret(this);" onchange="storeCaret(this);" tabindex="4">$message</textarea>
		<div id="dragbgw" style="position: absolute; top: 0px; left: 437px; width: 3px; height: $dheight; border: 0; z-index: 3;">
		<img id="dragImg1" src="$defaultimagesdir/resize_wb.gif" class="drag" style="position: absolute; top: 0px; left: $dragwpos; z-index: 4; width: 3px; height: $dheight; cursor: e-resize;" alt="resize_wb" />
		</div>

		<div id="dragbgh" style="position: absolute; top: 142px; left: 0px; width: $dwidth; height: 3px; border: 0; z-index: 3;">
		<img id="dragImg2" src="$defaultimagesdir/resize_hb.gif" class="drag" style="position: absolute; top: $draghpos; left: 0px; z-index: 4; width: $dwidth; height: 3px; cursor: n-resize;"  alt="resize_hb" />
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
			<option value="" title="$npf_txt{'default'}" selected="selected">$npf_txt{'default'}</option>
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
		</div>
		<script type="text/javascript" language="JavaScript1.2">
		<!--

		// set size of messagebox and text

		var oldwidth = parseInt(document.getElementById('message').style.width) - $jsdragwpos;
		var olddragwidth = parseInt(document.getElementById('dragbgh').style.width) - $jsdragwpos;
		var oldheight = parseInt(document.getElementById('message').style.height) - $jsdraghpos;
		var olddragheight = parseInt(document.getElementById('dragbgw').style.height) - $jsdraghpos;
		var orgsize = $textsize;
		skydobject.initialize()
		//-->
		</script>
		</td>
	</tr>
	~;

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

	if (!$replyguest) {
		$imsend .= qq~
	<tr>
		<td valign="middle" class="windowbg2">
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
				$moresmilieslist .= qq~				document.write('<img src="$tmpurl" align="bottom" alt="$SmilieDescription[$i]" border="0" onclick="javascript: MoreSmilies($i);" style="cursor: pointer;" />$SmilieLinebreak[$i] ');\n~;
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
						$moresmilieslist .= qq~				document.write('<img src="$smiliesurl/$line" align="bottom" alt="$name" border="0" onclick="javascript: MoreSmilies($i);" style="cursor: pointer; cursor: hand;" />$SmilieLinebreak[$i] ');\n~;
						$more_smilie_array .= qq~" [smiley=$line]", ~;
						$i++;
					}
				}
			}
		}

		$more_smilie_array .= qq~""~;

		$imsend .= qq~
				moresmiliecode = new Array($more_smilie_array)
				function MoreSmilies(i) {
					AddTxt=moresmiliecode[i];
					AddText(AddTxt);
				}

				HAND = "style='cursor: pointer; cursor: hand;'";
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
			//-->
			</script>\n~;

		if (($showadded == 3 && $showsmdir != 2) || ($showsmdir == 3 && $showadded != 2)) {
			$imsend .= qq~
			<a href="javascript: smiliewin();">$post_smiltxt{'1'}</a>~;
		}

		# SpellChecker start
		if ($enable_spell_check) {
			$yyinlinestyle .= qq~<link href="$yyhtml_root/googiespell/googiespell.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="$yyhtml_root/AJS.js"></script>
<script type="text/javascript" src="$yyhtml_root/googiespell/googiespell.js"></script>
<script type="text/javascript" src="$yyhtml_root/googiespell/cookiesupport.js"></script>~;
			my $userdefaultlang = (split(/-/, $abbr_lang))[0];
			$userdefaultlang ||= 'en';
			$imsend .= qq~
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

		$imsend .= qq~
			<noscript>
				<span class="small">$maintxt{'noscript'}</span>
			</noscript>
		</td>
	</tr>~;
	}

	$imsend .= qq~
	<tr>
		<td class="windowbg">~;

	if ($INFO{'quote'} || $INFO{'reply'} || $FORM{'reply'}) { # if this is a reply, need to pass the reply # forward 
		$imsend .= qq~
			<input type="hidden" name="reply" id="reply" value="$INFO{'quote'}$INFO{'reply'}$FORM{'reply'}" />~;
	}

	if (!$replyguest) {
		$imsend .= qq~
			<input type="checkbox" name="ns" id="ns" value="NS"$nscheck /> <label for="ns"><span class="small">$post_txt{'277'}</span></label><br />~;
		if ($FORM{'draftid'} || $INFO{'caller'} == 4) {
			$imsend .= qq~
			<input type="checkbox" name="draftleave" id="draftleave" value="1" /> <span class="small"> $post_txt{'draftleave'}</span><br />~;
		}
		$imsend .= qq~
			<input type="checkbox" name="dontstoreinoutbox" id="dontstoreinoutbox" value="1"~ . ($FORM{'dontstoreinoutbox'} ? ' checked="checked"' : '') . qq~ /> <label for="dontstoreinoutbox"><span class="small">$inmes_txt{'320'}</span></label><br />~;
	}

	$imsend .= qq~
			<div id="enable_iecopy" style="display: none;">
			<input type="checkbox" name="iecopy" id="iecopy"$iecopycheck /> <span class="small"> $post_txt{'iecopycheck'}</span>
			</div>
			<script language="JavaScript1.2" type="text/javascript">
			<!--
			if (navigator.appName == "Microsoft Internet Explorer") {
				document.getElementById('enable_iecopy').style.display = 'inline';
			}
			//-->
			</script>
		</td>
	</tr>
	~;
	
	#these are the buttons to submit
	my $sendBMessFlag;
	if ($sendBMess || $isBMess) {
		$sendBMessFlag = qq~<input type="hidden" name="isBMess" id="isBMess" value="yes" />~;
	}

	$imsend .= qq~
	<tr>
		<td align="center" class="titlebg">
			$hidestatus
			$sendBMessFlag
	~;
	
	if ($INFO{'popup'}) {
		$imsend .= qq~
			<input onclick="postQuery()" type="button" name="$post" value="$submittxt" accesskey="s" tabindex="5" class="button" />~;
	} else {
		$imsend .= qq~
			<input type="submit" name="$post" value="$submittxt" accesskey="s" tabindex="5" class="button" />~;
	}

	if ($speedpostdetection) {
		$imsend .= qq~
			<script language="JavaScript1.2" type="text/javascript">
			<!--
			var postdelay = $min_post_speed*1000;
			document.postmodify.$post.value = '$post_txt{"delay"}';
			document.postmodify.$post.disabled = true;
			document.postmodify.$post.style.cursor = 'default';
			var delay = window.setInterval('releasepost()',postdelay);
			function releasepost() {
				document.postmodify.$post.value = '$submittxt';
				document.postmodify.$post.disabled = false;
				document.postmodify.$post.style.cursor = 'pointer';
				window.clearInterval(delay);
			}
			//-->
			</script>~;
	}

	my %accesskey;
	if (!$replyguest) {
		$imsend .= qq~&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="submit" name="$draft" id="$draft" value="$inmes_txt{'savedraft'}" accesskey="d" tabindex="7" class="button" />~;
		$accesskey{'MSIE_Safari'}     = $post_txt{'329b'};
		$accesskey{'FireFox'}         = $post_txt{'330b'};
		$accesskey{'Browsers_on_Mac'} = $post_txt{'331b'};
		if ((!$enable_PMcontrols && $enable_PMprev) || ($enable_PMcontrols && ${$uid.$username}{'pmmessprev'})) {
			$imsend .= qq~&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="submit" name="$preview" id="$preview" value="$inmes_txt{'507'}" accesskey="p" tabindex="6" class="button" />~;
			$accesskey{'MSIE_Safari'}     = $post_txt{'329c'};
			$accesskey{'FireFox'}         = $post_txt{'330c'};
			$accesskey{'Browsers_on_Mac'} = $post_txt{'331c'};
		}
	}

	$smilie_url_array  = "";
	$smilie_code_array = "";
	$i = 0;
	if ($showadded eq 2) {
		while ($SmilieURL[$i]) {
			if ($SmilieURL[$i] =~ /\//i) { $tmpurl = $SmilieURL[$i]; }
			else { $tmpurl = qq~$defaultimagesdir/$SmilieURL[$i]~; }
			$smilie_url_array .= qq~"$tmpurl", ~;
			$tmpcode = $SmilieCode[$i];
			$tmpcode =~ s/\&quot;/"+'"'+"/g; # "'
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
					$smilie_url_array  .= qq~"$smiliesurl/$line", ~;
					$smilie_code_array .= qq~" [smiley=$line]", ~;
					$i++;
				}
			}
		}
	}

	$imsend .= qq~
		<script type="text/javascript" language="JavaScript">
		<!--
			if (/Opera/.test(navigator.userAgent) == false) {
				if (/mac/i.test(navigator.platform)) {
					document.write("<br /><span class='small'>$accesskey{'Browsers_on_Mac'}</span>");
				} else if (/MSIE [7-9]/.test(navigator.userAgent) || /\\/[3-9]\\.\\d+\\.\\d+ Safari/.test(navigator.userAgent)) {
					document.write("<br /><span class='small'>$accesskey{'MSIE_Safari'}</span>");
				} else if (/Firefox\\/[2-9]/.test(navigator.userAgent) || /Chrome/.test(navigator.userAgent)) {
					document.write("<br /><span class='small'>$accesskey{'FireFox'}</span>");
				}
			}

			var noalert = true, gralert = false, rdalert = false, clalert = false;
			var prevsec = 5;
			var prevtxt;
			var cntsec = 0;
			function tick() {
				cntsec++;
				calcCharLeft();
				timerID = setTimeout("tick()",1000);
			}
			var autoprev = false;
			var topicfirst = true;\n~;

	if (((!$enable_PMcontrols && $enable_PMActprev) || ($enable_PMcontrols && ${$uid.$username}{'pmactprev'})) && !$replyguest) {
		$imsend .= qq~
			post_txt_807 = "$post_txt{'807'}";

			function enabPrev() {
				if ( autoprev == false ) {
					autoprev = true
					topicfirst = true
					document.getElementById("savetable").style.visibility = "visible";
					document.getElementById("savetable").style.height = "auto";
					document.getElementById("savetopic").style.height = "auto";
					document.getElementById("saveframe").style.height = "auto";
					document.images.prevwin.alt = "$npf_txt{'02'}";
					document.images.prevwin.title = "$npf_txt{'02'}";
					document.images.prevwin.src="$defaultimagesdir/cat_collapse.gif";
					autoPreview();
				} else {
					autoprev = false;
					ubbstr = '';
					document.getElementById("savetable").style.visibility = "hidden";
					document.getElementById("savetable").style.height = "0px";
					document.getElementById("savetopic").style.height = "0px";
					document.getElementById("saveframe").style.height = "0px";
					document.postmodify.message.focus();
					document.images.prevwin.alt = "$npf_txt{'01'}";
					document.images.prevwin.title = "$npf_txt{'01'}";
					document.images.prevwin.src="$defaultimagesdir/cat_expand.gif";
				}
				calcCharLeft();
			}\n~;
	}

	$imsend .= qq~
			function calcCharLeft() {
				clipped = false;
				maxLength = $MaxMessLen;
				if (document.postmodify.message.value.length > maxLength) {
					document.postmodify.message.value = document.postmodify.message.value.substring(0,maxLength);
					charleft = 0;
					clipped = true;
				} else {
					charleft = maxLength - document.postmodify.message.value.length;
				}
				prevsec++
				if(autoprev && prevsec > 5 && prevtxt != document.postmodify.message.value) {
					autoPreview();
					prevtxt = document.postmodify.message.value;
				}
				document.postmodify.msgCL.value = charleft;
				if (charleft >= 100 && noalert) { noalert = false; gralert = true; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/green1.gif"; }
				if (charleft < 100 && charleft >= 50 && gralert) { noalert = true; gralert = false; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/green0.gif"; }
				if (charleft < 50 && charleft > 0 && rdalert) { noalert = true; gralert = true; rdalert = false; clalert = true; document.images.chrwarn.src="$defaultimagesdir/red0.gif" }
				if (charleft == 0 && clalert) { noalert = true; gralert = true; rdalert = true; clalert = false; document.images.chrwarn.src="$defaultimagesdir/red1.gif"; }
				return clipped;
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
			var jsmilieurl = new Array($smilie_url_array"");
			var jsmiliecode = new Array($smilie_code_array"");

			function autoPreview() {
				if (topicfirst)  { updatTopic(); }
				var scrlto = parseInt(180) + 5;
				vismessage = document.postmodify.message.value;
				while ( c=vismessage.match(/date=(\\d+?)\\]/i) ) {
					var qudate=c[1];
					qudate=qudate * 1000;
					qdate=new Date();
					qdate.setTime(qudate);
					qdate=qdate.toLocaleString();
					vismessage=vismessage.replace(/(date=)\\d+?(\\])/i, "\$1"+qdate+"\$2");
				}
				if($enable_ubbc) {
					var ubbstr = jsDoUbbc(vismessage,codestr,quotstr,squotstr,edittxt,dispname,scrpurl,imgdir,ubsmilieurl,parseflash,fontsizemax,fontsizemin,autolinkurl,Month,timeselected,splittext,dontusetoday,todaytext,yesterdaytext,timetext1,timetext2,timetext3,timetext4,jsmilieurl,jsmiliecode);
				} else {
					var ubbstr = vismessage;
				}
				document.getElementById("saveframe").innerHTML=ubbstr;
				sh_highlightDocument();
				LivePrevImgResize();
				scrlto += parseInt(document.getElementById("saveframe").scrollTop) + parseInt(document.getElementById("saveframe").offsetHeight);
				document.getElementById("saveframe").scrollTop = scrlto;
				prevsec = 0;
			}

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
			}\n~;

	if (((!$enable_PMcontrols && $enable_PMActprev) || ($enable_PMcontrols && ${$uid.$username}{'pmactprev'})) && !$replyguest) {
		$imsend .= qq~
			var visikon = '';
			function updatTopic() {
				topicfirst = false;

				var visicon = document.images.icons.src;
				visicon=visicon.replace(/http\\:\\/\\/.*\\/(.*?)\\.gif/g, "\$1");
				visicon=visicon.replace(/[^A-Za-z]/g, "");
				visicon=visicon.replace(/\\\\/g, "");
				visicon=visicon.replace(/\\//g, "");
				if (visicon != "standard" && visicon != "confidential" && visicon != "urgent") {
					visicon = "xx";
				}
				visikon = "<img border='0' src='$defaultimagesdir/"+visicon+".gif' alt='"+visicon+"' /> ";

				var vistopic = document.postmodify.subject.value;
				var htmltopic = jsDoTohtml(vistopic);
				document.getElementById("savetopic").innerHTML=visikon+htmltopic;
				//document.postmodify.message.focus();
			}\n~;
	}

	if (!$replyguest) {
		$imsend .= qq~
			function showtpstatus() {
				var theimg = '$pmicon';
				var objIconSelected = document.postmodify.status[document.postmodify.status.selectedIndex].value;
				if (objIconSelected == 's') { theimg = 'standard'; }
				if (objIconSelected == 'c') { theimg = 'confidential'; }
				if (objIconSelected == 'u') { theimg = 'urgent'; }
				document.images.icons.src='$imagesdir/'+theimg+'.gif';
				if (autoprev == true) updatTopic();
			}
			showtpstatus();\n~;
	}

	$imsend .= qq~
			tick();

			// -->
			</script>
		</td>
	</tr>\n~;

	require "$templatesdir/$usedisplay/Display.template";

	foreach (@months) { $jsmonths .= qq~'$_',~; }
	$jsmonths =~ s~\,\Z~~;
	$jstimeselected = ${$uid.$username}{'timeselect'} || $timeselected;

	##########  end post code
}

##  process and send the IM to whomever
sub IMsendMessage {
	# This is only for update, when comming from YaBB lower or equal version 2.2.3
	# I think it can be deleted around version 2.4.0 without causing mayor issues (deti).
	if ($enable_notifications eq '') { $enable_notifications = $enable_notification ? 3 : 0; }
	# End update workaround

	&LoadLanguage('Post');
	&LoadLanguage('InstantMessage');
	##  load error strings
	&LoadLanguage('Error');

	##  sorry - no guests
	if ($iamguest) { &fatal_error("im_members_only"); }

	my (@ignore, $igname, $messageid, $subject, $message, @recipient, $ignored);
	$isBMess = $FORM{'isBMess'};

	# set size of messagebox and text
	${$uid.$username}{'postlayout'} = qq~$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}~;

	# receipts for IM are now handled by "toshow" only, so we need to switch to the right 
	# test for no recipient. also switch on flag to stop us going back to the form all the time
	# if there is only the one (intended) recipient, 'to' must contain the name
	if ((!$FORM{'toshow'} && !$INFO{'to'}) && !$FORM{'draft'}) { $error = $error_txt{'no_recipient'}; }
	$toshow = $FORM{'toshow'} || $INFO{'to'};
	# if there are several intended - can be one of course ;)

	$subject = $FORM{'subject'};
	$subject =~ s/^\s+|\s+$//g;

	$message = $FORM{'message'};
	$message =~ s/^\s+|\s+$//g;

	# no subject/no message are bad!
	$error = $error_txt{'no_subject'} if !$subject;
	$error = $error_txt{'no_message'} if !$message;

	&FromChars($subject);
	&FromChars($message);

	&ToHTML($subject);
	&ToHTML($message);

	# manage line returns and tabs
	$subject =~ s/\s+/ /g;
	$message =~ s~\n~<br />~g;
	$message =~ s~\t~ \&nbsp; \&nbsp; \&nbsp;~g;

	# Check Length
	$convertstr = $subject;
	$convertcut = $set_subjectMaxLength + ($subject =~ /^Re: / ? 4 : 0);
	&CountChars;
	$subject = $convertstr;

	$convertstr = $message;
	$convertcut = $MaxMessLen;
	&CountChars;
	if ($cliped) { $error = "$inmes_txt{'536'} " . (length($message) - length($convertstr)) . " $inmes_txt{'537'}"; }
	$message = $convertstr;

	if ($FORM{'ns'} eq 'NS') { $message .= "#nosmileys"; }

	if ($error) {
		$IM_box = $inmes_txt{'148'};
		$FORM{'previewim'} = 1;
		&IMPost;
		&buildIMsend;
		return;
	}

	&ProcIMrecs;

	# no need to check for spam if its a broadcast, as this only creates the one post
	if (!$iamadmin && !$isBMess && $imspam && @allto * 100 / $members_total > $imspam) { &fatal_error("im_spam_alert"); }

	# go through each member in list
	# add to each msg (inbox) but only one to outbox
	# Create unique Message ID
	$messageid = &getnewid;
	$actlang = $language;
	my $UserTo;
	if (!$FORM{'draft'} && !$isBMess && !$replyguest) {
		foreach $UserTo (@allto) {
			$addnr++;
			chomp $UserTo;
			my($status, $UserTo) = split(/:/, $UserTo);
			my $ignored = 0;
			$UserTo =~ s/\A\s+//;
			$UserTo =~ s/\s+\Z//;
			$UserTo =~ s/[^0-9A-Za-z#%+,-\.@^_]//g;

			# Check Ignore-List, unless sender is FA
			&LoadUser($UserTo);
			if (!$isBMess) {
				if (${$uid.$UserTo}{'im_ignorelist'} && !$iamadmin && !$iamgmod) {
					# Build Ignore-List
					@ignore = split(/\|/, ${$uid.$UserTo}{'im_ignorelist'});

					# If User is on Recipient's Ignore-List, show Error Message
					foreach $igname (@ignore) {
						# adds ignored user's name to array which error list will be built from later
						chomp $igname;
						if ($igname eq $username) { push(@nouser, $UserTo); $ignored = 1; }
						if ($igname eq '*') { push(@nouser, "$inmes_txt{'761'} $UserTo $inmes_txt{'762'};"); $ignored = 1; }
					}
				}
			}
			## check and see if 1) username is marked 'away' 2) they left a message 3) you haven't already had an auto-reply
			my $sendAutoReply = 1;
			if (${$uid.$UserTo}{'offlinestatus'} eq 'away' && ${$uid.$UserTo}{'awayreply'} ne '' && ${$uid.$UserTo}{'awaysubj'} ne '') {
				if (${$uid.$UserTo}{'awayreplysent'} eq '') {
					${$uid.$UserTo}{'awayreplysent'} = $username;
					&UserAccount($UserTo, 'update');
				} else {
					foreach my $replyListName (split(/,/ ,${$uid.$UserTo}{'awayreplysent'})) {
						if ($replyListName eq $username) {
							$sendAutoReply = 0;
							last;
						}
					}
					if ($sendAutoReply) {
						${$uid.$UserTo}{'awayreplysent'} .= qq~,$username~;
						&UserAccount($UserTo, 'update');
					}
				}
			} else { $sendAutoReply = 0; }

			if (!&checkfor_DBorFILE("$memberdir/$UserTo.vars")) { 
				# adds invalid user's name to array which error list will be built from later
				push(@nouser, $UserTo);
				$ignored = 1;
			}

			if (!$ignored) {
				# Send message to user
				my @inmessages = &read_DBorFILE(0,'',$memberdir,$UserTo,'msg');
				&write_DBorFILE(${$uid.$UserTo}{'mysql'},'',$memberdir,$UserTo,'msg',("$messageid|$username|$FORM{'toshow'}|$FORM{'toshowcc'}|$FORM{'toshowbcc'}|$subject|$date|$message|$messageid|0|$ENV{'REMOTE_ADDR'}|$FORM{'status'}|u||\n", @inmessages));

				# we've added the msg to the inbox, now update the ims file
				&updateIMS($UserTo, $messageid, 'messagein');
				## if we need to drop the 'away' reply in....
				if ($sendAutoReply) {
					my $rmessageid = &getnewid;

					@inmessages = &read_DBorFILE(0,'',$memberdir,$username,'msg');
					&write_DBorFILE(${$uid.$username}{'mysql'},'',$memberdir,$username,'msg',("$rmessageid|$UserTo|$username|||${$uid.$UserTo}{'awaysubj'}|$date|${$uid.$UserTo}{'awayreply'}|$messageid|1|$ENV{'REMOTE_ADDR'}|s|u||\n", @inmessages));
				}
				## relocated sender's msg out of the loop

				# Send notification (Will only work if Admin has allowed the Email Notification)
				if (${$uid.$UserTo}{'notify_me'} > 1 && $enable_notifications > 1) {
					require "$sourcedir/Mailer.pl";
					$language = ${$uid.$UserTo}{'language'};
					&LoadLanguage('Email');
					&LoadLanguage('Notify');
					$useremail = ${$uid.$UserTo}{'email'};
					$useremail =~ s/[\n\r]//g;
					if ($useremail ne '') {
						my $msubject = $subject ? $subject : $inmes_txt{'767'};
						$fromname = ${$uid.$username}{'realname'};
						&FromHTML($msubject);
						&ToChars($msubject);
						my $chmessage = $message;
						&FromHTML($chmessage);
						&ToChars($chmessage);
						$chmessage =~ s~<br.*?>~\n~gi;
						$chmessage =~ s~\[b\](.*?)\[/b\]~*$1*~isg;
						$chmessage =~ s~\[i\](.*?)\[/i\]~/$1/~isg;
						$chmessage =~ s~\[u\](.*?)\[/u\]~_$1_~isg;
						$chmessage =~ s~\[.*?\]~~g;
						&sendmail($useremail, $notify_txt{'145'}, &template_email($privatemessagenotificationemail, {'sender' => $fromname, 'subject' => $msubject, 'message' => $chmessage}), '', $emailcharset);
					}
				}
			}	#end add PM to outbox
		}	#end foreach loop
		if ($#allto == $#nouser) {
			my $badusers;
			foreach my $baduser (@nouser) {
				&LoadUser($baduser);
				$badusers .= qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$baduser}" rel="nofollow">${$uid.$baduser}{'realname'}</a>, ~;
			}
			$badusers =~ s/, \Z//;
			&fatal_error('im_bad_users', $badusers);
		}
	}

	##  moved sender's reply marker here, open the sender's inbox and mark 'replied'
	if (!$FORM{'draft'} && $isBMess) {
		&write_DBorFILE(0,'',$memberdir,'broadcast','messages',("$messageid|$username|$FORM{'toshow'}|||$subject|$date|$message|$messageid|0|$ENV{'REMOTE_ADDR'}|$FORM{'status'}b|u||\n",&read_DBorFILE(1,'',$memberdir,'broadcast','messages')));
	}

	if ($FORM{'reply'} && $FORM{'info'}) { # mark msg replied
		&updateMessageFlag($username, $FORM{'info'}, 'msg', '', 'r');
	}

	## this now outside the foreach, to allow just one write in the outbox
	# Add message to outbox, read outbox

	my $savetofile = 'outbox';
	if ($FORM{'draft'}) { $savetofile = 'imdraft'; }
	@outmessages = &read_DBorFILE(0,'',$memberdir,$username,$savetofile);

	# add the PM to the outbox
	# the sep users now live together
	my $messFlag = '';
	if ($isBMess) { $messFlag = 'b'; }
	if ($replyguest) { 
		$messFlag = 'gr';

		$FORM{'toguest'} =~ s/ /%20/g;
		$FORM{'toshow'} = $FORM{'toguest'} . ' ' . $FORM{'guestemail'};
		$FORM{'toshow'} =~ s/[\n\r]//g;
		$FORM{'guestemail'} =~ s/[\n\r]//g;

		$fromname = ${$uid.$username}{'realname'};

		my $msubject = $subject;
		&FromHTML($msubject);
		&ToChars($msubject);

		$chmessage = $message;
		&FromHTML($chmessage);
		&ToChars($chmessage);
		$chmessage =~ s~<br.*?>~\n~gi;
		$chmessage =~ s~\[b\](.*?)\[/b\]~*$1*~isg;
		$chmessage =~ s~\[i\](.*?)\[/i\]~/$1/~isg;
		$chmessage =~ s~\[u\](.*?)\[/u\]~_$1_~isg;
		$chmessage =~ s~\[.*?\]~~g;
		$chmessage =~ s/\r(?=\n*)//g;

		require "$sourcedir/Mailer.pl";
		&sendmail($FORM{'guestemail'}, $msubject, $chmessage, ${$uid.$username}{'email'});
	}

	if (!$FORM{'dontstoreinoutbox'} || $FORM{'draft'}) {
		## all but drafts being resaved just get added to their file
		if (!$FORM{'draft'} || ($FORM{'draft'} && !$FORM{'draftid'})) {
			&write_DBorFILE(${$uid.$username}{'mysql'},'',$memberdir,$username,$savetofile,("$messageid|$username|$FORM{'toshow'}|$FORM{'toshowcc'}|$FORM{'toshowbcc'}|$subject|$date|$message|$messageid|$FORM{'reply'}|$ENV{'REMOTE_ADDR'}|$FORM{'status'}$messFlag|||\n",@outmessages));

		} elsif ($FORM{'draft'} && $FORM{'draftid'}) {
			## resaving draft - find draft message id and amend the entry
			my @new_outmessages;
			foreach (@outmessages) {
				if ((split /\|/, $_, 2)[0] != $FORM{'draftid'}) {
					push(@new_outmessages, $_);
				} else {
					push(@new_outmessages, "$messageid|$username|$FORM{'toshow'}|$FORM{'toshowcc'}|$FORM{'toshowbcc'}|$subject|$date|$message|$messageid|$FORM{'reply'}|$ENV{'REMOTE_ADDR'}|$FORM{'status'}$messFlag|||\n");
				}
			}
			&write_DBorFILE(${$uid.$username}{'mysql'},'',$memberdir,$username,$savetofile,@new_outmessages);
		}

		## pdate ims for sent
		if (!$FORM{'draft'}) { &updateIMS($username, $messageid, 'messageout'); }
		elsif (!$FORM{'draftid'}) { &updateIMS($username, $messageid, 'draftadd'); }
	}

	## if this is a draft being sent, remove it from the draft file
	if ($FORM{'draftid'} && $FORM{'draft'} ne $inmes_txt{'savedraft'}) {
		&updateIMS($username, $messageid, 'draftsend');
		my @draftPM;
		foreach my $draftmess (&read_DBorFILE(0,'',$memberdir,$username,'imdraft')) {
			chomp $draftmess; 
			if ((split /\|/, $draftmess)[0] != $FORM{'draftid'}) {
				push(@draftPM, "$draftmess\n");
			} elsif ($FORM{'draftleave'}) {
				push(@draftPM, "$messageid|$username|$FORM{'toshow'}|$FORM{'toshowcc'}|$FORM{'toshowbcc'}|$subject|$date|$message|$messageid|$FORM{'reply'}|$ENV{'REMOTE_ADDR'}|$FORM{'status'}$messFlag|||\n");
			}
		}
		&write_DBorFILE(${$uid.$username}{'mysql'},'',$memberdir,$username,'imdraft',@draftPM);
	}
	# invalid users 
	#if there were invalid usernames in the recipient list, these names are listed after all valid users have been IMed
	if (!$FORM{'draft'}) {
		if (@nouser) {
			my $badusers;
			foreach my $baduser (@nouser) {
				&LoadUser($baduser);
				$badusers .= qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$baduser}" rel="nofollow">${$uid.$baduser}{'realname'}</a>, ~;
			}
			$badusers =~ s/, \Z//;
			&fatal_error('im_bad_users', $badusers);
		}
	}

	## saving a draft doesn't count as sending
	if (!$FORM{'draft'}) { &UserAccount($username, 'update', 'lastim+lastonline'); }
	else { &UserAccount($username, 'update', 'lastonline'); }

	if ($INFO{'popup'}) {
		print "Content-type: text/plain\n\n";
		print qq~Complete~;
		CORE::exit; # This is here only to avoid server error log entries!
	} else {
		if ($FORM{'dontstoreinoutbox'}) { $yySetLocation = qq~$scripturl?action=im~; }
		elsif ($FORM{'draft'}) { $yySetLocation = qq~$scripturl?action=imdraft~; }
		else { $yySetLocation = qq~$scripturl?action=imoutbox~; }
		&redirectexit;
	}
}


##  process the to/cc/bcc lists
sub ProcIMrecs {
	$FORM{'toshow'} =~ s/ //g;

	if (!$isBMess) {
		my $multiUser;
		my $countMulti = 0;
		@multiple = split(/,/, $FORM{'toshow'});
		if ($do_scramble_id) {
			foreach $multiUser (@multiple) {
				$multiple[$countMulti] = &decloak($multiUser);
				$countMulti++;
			}
		}
		push(@allto, split(/,/, ("to:" . join(',to:', @multiple))));
		$FORM{'toshow'} = join(',', @multiple);
		$FORM{'toshowcc'} =~ s/ //g;
		$FORM{'toshowbcc'} =~ s/ //g;

		if ($FORM{'toshowcc'}) {
			@multiplecc = split(/,/, $FORM{'toshowcc'});
			if ($do_scramble_id) {
				$countMulti = 0;
				foreach $multiUser (@multiplecc) {
					$multiplecc[$countMulti] = &decloak($multiUser);
					$countMulti++;
				}
			}
			push(@allto, split(/,/, ("cc:" . join(',cc:', @multiplecc))));
			$FORM{'toshowcc'} = join(',', @multiplecc);
		}
		if ($FORM{'toshowbcc'}) {
			@multiplebcc = split(/,/, $FORM{'toshowbcc'});
			if ($do_scramble_id) {
				$countMulti = 0;
				foreach $multiUser (@multiplebcc) {
					$multiplebcc[$countMulti] = &decloak($multiUser);
					$countMulti++;
				}
			}
			push(@allto, split(/,/, ("bcc:" . join(',bcc:', @multiplebcc))));
			$FORM{'toshowbcc'} = join(',', @multiplebcc);
		}
	}
}

sub pageLinksList {
	# Build the page links list.
	$maxmessagedisplay ||= 10;
	my $userthreadpage = (split /\|/, ${$uid.$username}{'pageindex'})[3];
	my ($pagetxtindex, $pagetextindex, $pagedropindex1, $pagedropindex2, $all, $allselected, $bmesslink);
	$postdisplaynum = 3; # max number of pages to display
	$dropdisplaynum = 10;
	$startpage = 0;
	if ($INFO{'viewfolder'} ne '') { $viewfolderinfo = qq~;viewfolder=$INFO{'viewfolder'}~; }
	if ($INFO{'focus'} eq 'bmess') { $bmesslink = qq~;focus=bmess~;}
	my @tempim = @dimmessages;
	if ($action eq 'imstorage') {
		my $i = 0;
		foreach (@dimmessages) {
			if ((split(/\|/, $_))[13] ne $INFO{'viewfolder'}) {
				splice(@tempim,$i,1);
				next;
			}
			$i++;
		}
	}
	$max = $#tempim + 1;
	if ($INFO{'start'} eq "all") { $maxmessagedisplay = $max; $all = 1; $allselected = qq~ selected="selected"~; $start = 0; }
	else { $start = $INFO{'start'} || 0; }
	$start = $start > $#tempim ? $#tempim : $start;
	$start = (int($start / $maxmessagedisplay)) * $maxmessagedisplay;
	$tmpa = 1;
	$pagenumb = int(($max - 1) / $maxmessagedisplay) + 1;
	if ($start >= (($postdisplaynum - 1) * $maxmessagedisplay)) {
		$startpage = $start - (($postdisplaynum - 1) * $maxmessagedisplay);
		$tmpa = int($startpage / $maxmessagedisplay) + 1;
	}
	if ($max >= $start + ($postdisplaynum * $maxmessagedisplay)) { $endpage = $start + ($postdisplaynum * $maxmessagedisplay); }
	else { $endpage = $max; }
	$lastpn = int($#tempim / $maxmessagedisplay) + 1;
	$lastptn = ($lastpn - 1) * $maxmessagedisplay;
	$pageindex1 = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;"><img src="$imagesdir/index_togl.png" border="0" alt="$display_txt{'19'}" title="$display_txt{'19'}" style="vertical-align: middle;" /> $display_txt{'139'}: $pagenumb</span>~;
	if ($pagenumb > 1 || $all) {
		if ($userthreadpage == 1 ) {
			$pagetxtindexst = qq~<span class="small" style="float: left; height: 21px; margin: 0px; margin-top: 2px;">~;
			$pagetxtindexst .= qq~<a href="$scripturl?pmaction=$action$bmesslink;start=$start;action=pmpagetext$viewfolderinfo"><img src="$imagesdir/index_togl.png" border="0" alt="$display_txt{'19'}" title="$display_txt{'19'}" style="vertical-align: middle;" /></a> $display_txt{'139'}: ~; 
			if ($startpage > 0) { $pagetxtindex = qq~<a href="$scripturl?action=$action$bmesslink/0$viewfolderinfo" style="font-weight: normal;">1</a>&nbsp;...&nbsp;~; }
			if ($startpage == $maxmessagedisplay) { $pagetxtindex = qq~<a href="$scripturl?action=$action$bmesslink;start=0$viewfolderinfo" style="font-weight: normal;">1</a>&nbsp;~; }
			for ($counter = $startpage; $counter < $endpage; $counter += $maxmessagedisplay) {
				$pagetxtindex .= $start == $counter ? qq~<b>$tmpa</b>&nbsp;~ : qq~<a href="$scripturl?action=$action$bmesslink;start=$counter$viewfolderinfo" style="font-weight: normal;">$tmpa</a>&nbsp;~;
				$tmpa++;
			}
			if ($endpage < $max - ($maxmessagedisplay)) { $pageindexadd = qq~...&nbsp;~; }
			if ($endpage != $max) { $pageindexadd .= qq~<a href="$scripturl?action=$action$bmesslink;start=$lastptn$viewfolderinfo" style="font-weight: normal;">$lastpn</a>~; }
			$pagetxtindex .= qq~$pageindexadd~;
			$pageindex1 = qq~$pagetxtindexst$pagetxtindex</span>~;
			$pageindex2 = $pageindex1;
		} else {
			$pagedropindex1 = qq~<span style="float: left; width: 350px; margin: 0px; margin-top: 2px; border: 0px;">~;
			$pagedropindex1 .= qq~<span style="float: left; height: 21px; margin: 0; margin-right: 4px;"><a href="$scripturl?pmaction=$action$bmesslink;start=$start;action=pmpagedrop$viewfolderinfo"><img src="$imagesdir/index_togl.png" border="0" alt="$display_txt{'19'}" title="$display_txt{'19'}" /></a></span>~;
			$pagedropindex2 = $pagedropindex1;
			$tstart = $start;
			if (substr($INFO{'start'}, 0, 3) eq "all") { ($tstart, $start) = split(/\-/, $INFO{'start'}); }
			$d_indexpages = $pagenumb / $dropdisplaynum;
			$i_indexpages = int($pagenumb / $dropdisplaynum);
			if ($d_indexpages > $i_indexpages) { $indexpages = int($pagenumb / $dropdisplaynum) + 1; }
			else { $indexpages = int($pagenumb / $dropdisplaynum) }
			$selectedindex = int(($start / $maxmessagedisplay) / $dropdisplaynum);
			if ($pagenumb > $dropdisplaynum) {
				$pagedropindex1 .= qq~<span style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector1" id="decselector1" style="font-size: 9px; border: 2px inset;" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
				$pagedropindex2 .= qq~<span style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector2" id="decselector2" style="font-size: 9px; border: 2px inset;" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
			}
			for ($i = 0; $i < $indexpages; $i++) {
				$indexpage = ($i * $dropdisplaynum) * $maxmessagedisplay;
				$indexstart = ($i * $dropdisplaynum) + 1;
				$indexend = $indexstart + ($dropdisplaynum - 1);
				if ($indexend > $pagenumb) { $indexend   = $pagenumb; }
				if ($indexstart == $indexend) { $indxoption = qq~$indexstart~; }
				else { $indxoption = qq~$indexstart-$indexend~; }
				$selected = "";
				if ($i == $selectedindex) {
					$selected    = qq~ selected="selected"~;
					$pagejsindex = qq~$indexstart|$indexend|$maxmessagedisplay|$indexpage~;
				}
				if ($pagenumb > $dropdisplaynum) {
					$pagedropindex1 .= qq~<option value="$indexstart|$indexend|$maxmessagedisplay|$indexpage"$selected>$indxoption</option>\n~;
					$pagedropindex2 .= qq~<option value="$indexstart|$indexend|$maxmessagedisplay|$indexpage"$selected>$indxoption</option>\n~;
				}
			}
			if ($pagenumb > $dropdisplaynum) {
				$pagedropindex1 .= qq~</select>\n</span>~;
				$pagedropindex2 .= qq~</select>\n</span>~;
			}
			$pagedropindex1 .= qq~<span id="ViewIndex1" class="droppageindex" style="height: 14px; visibility: hidden;">&nbsp;</span>~;
			$pagedropindex2 .= qq~<span id="ViewIndex2" class="droppageindex" style="height: 14px; visibility: hidden;">&nbsp;</span>~;
			$tmpmaxmessagedisplay = $maxmessagedisplay;
			if (substr($INFO{'start'}, 0, 3) eq "all") { $maxmessagedisplay = $maxmessagedisplay * $dropdisplaynum; }
			$prevpage = $start - $tmpmaxmessagedisplay;
			$nextpage = $start + $maxmessagedisplay;
			$pagedropindexpvbl = qq~<img src="$imagesdir/index_left0.gif" height="14" width="13" border="0" alt="" style="margin: 0px; display: inline; vertical-align: middle;" />~;
			$pagedropindexnxbl = qq~<img src="$imagesdir/index_right0.gif" height="14" width="13" border="0" alt="" style="margin: 0px; display: inline; vertical-align: middle;" />~;
			if ($start < $maxmessagedisplay) { $pagedropindexpv .= qq~<img src="$imagesdir/index_left0.gif" height="14" width="13" border="0" alt="" style="display: inline; vertical-align: middle;" />~; }
			else { $pagedropindexpv .= qq~<img src="$imagesdir/index_left.gif" border="0" height="14" width="13" alt="$pidtxt{'02'}" title="$pidtxt{'02'}" style="display: inline; vertical-align: middle; cursor: pointer;" onclick="location.href=\\'$scripturl?action=$action$bmesslink;start=$prevpage\\'" ondblclick="location.href=\\'$scripturl?action=$action$bmesslink;start=0\\'" />~; }
			if ($nextpage > $lastptn) { $pagedropindexnx .= qq~<img src="$imagesdir/index_right0.gif" border="0" height="14" width="13" alt="" style="display: inline; vertical-align: middle;" />~; }
			else { $pagedropindexnx .= qq~<img src="$imagesdir/index_right.gif" height="14" width="13" border="0" alt="$pidtxt{'03'}" title="$pidtxt{'03'}" style="display: inline; vertical-align: middle; cursor: pointer;" onclick="location.href=\\'$scripturl?action=$action$bmesslink;start=$nextpage\\'" ondblclick="location.href=\\'$scripturl?action=$action$bmesslink;start=$lastptn\\'" />~; }
			$pageindex1 = qq~$pagedropindex1</span>~;
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
				if (visel == 'xx' && decparam == '$pagejsindex') visel = '$tstart';
				var pagedropindex = '<table border="0" cellpadding="0" cellspacing="0"><tr>';
				for (i=vistart; i<=viend; i++) {
					if (visel == pagstart) pagedropindex += '<td class="titlebg" height="14" style="height: 14px; padding-left: 1px; padding-right: 1px; font-size: 9px; font-weight: bold;">' + i + '</td>';
					else pagedropindex += '<td height="14" class="droppages"><a href="$scripturl?action=$action$bmesslink;start=' + pagstart + '">' + i + '</a></td>';
					pagstart += maxpag;
				}
				~;
				if ($showpageall) {
					$pageindexjs .= qq~
					if (vistart != viend) {
						if(visel == 'all') pagedropindex += '<td class="titlebg" height="14" style="height: 14px; padding-left: 1px; padding-right: 1px; font-size: 9px; font-weight: normal;"><b>$pidtxt{"01"}</b></td>';
						else pagedropindex += '<td height="14" class="droppages"><a href="$scripturl?action=$action$bmesslink;start=all-' + allpagstart + '">$pidtxt{"01"}</a></td>';
					}
					~;
				}
				$pageindexjs .= qq~
				if (visel != 'xx') pagedropindex += '<td height="14" class="small" style="height: 14px; padding-left: 4px;">$pagedropindexpv$pagedropindexnx</td>';
				else pagedropindex += '<td height="14" class="small" style="height: 14px; padding-left: 4px;">$pagedropindexpvbl$pagedropindexnxbl</td>';
				pagedropindex += '</tr></table>';
				document.getElementById('ViewIndex1').innerHTML=pagedropindex;
				document.getElementById('ViewIndex1').style.visibility = 'visible';
				~;
				if ($pagenumb > $dropdisplaynum) {
				$pageindexjs .= qq~
				document.getElementById('decselector1').value = decparam;
				~;
			}
			$pageindexjs .= qq~
		}
		SelDec('$pagejsindex', '$tstart');
		//-->
		</script>
		~;
		}
	}
}

##  output one or all IM - detailed view
sub DoShowIM {
	$messfound = 0;
	if ($callerid < 5) { &updateIMS($username, $_[0], 'inread'); }

	my ($showIM, $fromTitle, $toTitle, $toTitleCC, $toTitleBCC, $usernamelinkfrom, $usernamelinkto, $usernamelinkcc, $usernamelinkbcc, $userOnline, $prevMessId, $nextMessid, $PMnav);
	$messcount = 0;
	foreach my $messagesim (@dimmessages) {
		$nextMessid = $messageid;
		($messageid, $musername, $mtousers, $mccusers, $mbccusers, $msub, $mdate, $immessage, $mpmessageid, $mreplyno, $imip, $mstatus, $mflags, $mstorefolder, $mattach) = split(/\|/, $messagesim);
		$messcount++;
		if ($messageid == $_[0]) { $messfound = 1; last; }
	}

	if (!$messfound) {
		my $redirect;
		if ($INFO{'caller'} == 1) { $redirect = 'im'; }
		elsif ($INFO{'caller'} == 2) { $redirect = 'imoutbox'; }
		elsif ($INFO{'caller'} == 3) { $redirect = 'imstorage'; }
		elsif ($INFO{'caller'} == 4) { $redirect = 'imdraft'; }
		elsif ($INFO{'caller'} == 5) { $redirect = 'im;focus=bmess'; }
		$yySetLocation = qq~$scripturl?action=$redirect~;
		&redirectexit;
	}

	## if not at the end of the list, catch the 'previoous' id
	if ($messcount <= $#dimmessages){
		($prevMessId, undef) = split(/\|/, $dimmessages[$messcount]);
	}
	## wrap the URL in
	if ($INFO{'id'} ne 'all' && $prevMessId ne '') { $previd = qq~&laquo; <a href="$scripturl?action=imshow;caller=$INFO{'caller'};id=$prevMessId">$inmes_imtxt{'40'}</a>~; }
	if ($INFO{'id'} ne 'all' && $nextMessid ne '') { $nextid = qq~<a href="$scripturl?action=imshow;caller=$INFO{'caller'};id=$nextMessid">$inmes_imtxt{'41'}</a> &raquo;~; }
	if ($INFO{'id'} ne 'all' && $#dimmessages > 0) { $allid = qq~<a href="$scripturl?action=imshow;caller=$INFO{'caller'};id=all">$inmes_txt{'190'}</a>~; }

	my $mydate = &timeformat($mdate);
	if ($INFO{'caller'} == 1) {
		if ($mtousers) {
			foreach my $uname (split(/,/, $mtousers)) {
				&LoadValidUserDisplay($uname);
				$usernamelinkto .= (${$uid.$uname}{'realname'} ? &CreateUserDisplayLine($uname) : ($uname ? qq~$uname ($maintxt{'470a'})~ : $maintxt{'470a'})) . ', '; # 470a == Ex-Member
			}
			$usernamelinkto =~ s/, $//;
			$toTitle = qq~$inmes_txt{'324'}:~;
		}
		if ($mccusers) {
			foreach my $uname (split(/,/, $mccusers)) {
				&LoadValidUserDisplay($uname);
				$usernamelinkcc .= (${$uid.$uname}{'realname'} ? &CreateUserDisplayLine($uname) : ($uname ? qq~$uname ($maintxt{'470a'})~ : $maintxt{'470a'})) . ', ';
			}
			$usernamelinkcc =~ s/, $//;
			$toTitleCC = qq~$inmes_txt{'325'}:~;
		}
		if ($mbccusers) {
			foreach my $uname (split(/,/, $mbccusers)) {
				if ($uname eq $username) {
					&LoadValidUserDisplay($uname);
					$usernamelinkbcc = ${$uid.$uname}{'realname'} ? &CreateUserDisplayLine($uname) : ($uname ? qq~$uname ($maintxt{'470a'})~ : $maintxt{'470a'});
				}
			}
			if ($usernamelinkbcc) {
				$toTitleBCC = qq~$inmes_txt{'326'}:~;
			}
		}

		if ($mstatus eq 'g') {
			my ($guestName, $guestEmail) = split(/ /, $musername);
			$guestName =~ s/%20/ /g; 
			$usernamelinkfrom = qq~$guestName (<a href="mailto:$guestEmail">$guestEmail</a>)~;
		} else {
			&LoadValidUserDisplay($musername);
			$usernamelinkfrom = ${$uid.$musername}{'realname'} ? &CreateUserDisplayLine($musername) : ($musername ? qq~$musername ($maintxt{'470a'})~ : $maintxt{'470a'}); # 470a == Ex-Member
		}
		$fromTitle = qq~$inmes_txt{'318'}:~;

	} elsif ($INFO{'caller'} == 2) {
		&LoadValidUserDisplay($musername);
		$usernamelinkfrom = ${$uid.$musername}{'realname'} ? &CreateUserDisplayLine($musername) : ($musername ? qq~$musername ($maintxt{'470a'})~ : $maintxt{'470a'}); # 470a == Ex-Member
		$fromTitle = qq~$inmes_txt{'318'}:~;

		if ($mstatus !~ /b/) {
			if ($mstatus !~ /gr/) {
				foreach my $uname (split(/,/, $mtousers)) {
					&LoadValidUserDisplay($uname);
					$usernamelinkto .= (${$uid.$uname}{'realname'} ? &CreateUserDisplayLine($uname) : ($uname ? qq~$uname ($maintxt{'470a'})~ : $maintxt{'470a'})) . ', '; # 470a == Ex-Member
				}
			} else {
				my ($guestName, $guestEmail) = split(/ /, $mtousers);
				$guestName =~ s/%20/ /g; 
				$usernamelinkto = qq~$guestName (<a href="mailto:$guestEmail">$guestEmail</a>)~;
			}
			$toTitle = qq~$inmes_txt{'324'}:~;
		} else {
			foreach my $uname (split(/,/, $mtousers)) {
				if ($uname eq 'all') { $usernamelinkto .= qq~<b>$inmes_txt{'bmallmembers'}</b>~ . ', ';
				} elsif ($uname eq 'mods') { $usernamelinkto .= qq~<b>$inmes_txt{'bmmods'}</b>~ . ', ';
				} elsif ($uname eq 'gmods') { $usernamelinkto .= qq~<b>$inmes_txt{'bmgmods'}</b>~ . ', ';
				} elsif ($uname eq 'admins') { $usernamelinkto .= qq~<b>$inmes_txt{'bmadmins'}</b>~ . ', ';				
				} else {
					my ($title, undef) = split(/\|/, $NoPost{$uname}, 2);
					$usernamelinkto .= qq~<b>$title</b>~ . ', ';
				}
			}
			$toTitle = qq~$inmes_txt{'324'} $inmes_txt{'327'}:~;
		}
		$usernamelinkto =~ s/, $//;
		if ($mccusers) {
			foreach my $uname (split(/,/, $mccusers)) {
				&LoadValidUserDisplay($uname);
				$usernamelinkcc .= (${$uid.$uname}{'realname'} ? &CreateUserDisplayLine($uname) : ($uname ? qq~$uname ($maintxt{'470a'})~ : $maintxt{'470a'})) . ', '; # 470a == Ex-Member
			}
			$usernamelinkcc =~ s/, $//;
			$toTitleCC = qq~$inmes_txt{'325'}:~;
		}
		if ($mbccusers) {
			foreach my $uname (split(/,/, $mbccusers)) {
				&LoadValidUserDisplay($uname);
				$usernamelinkbcc .= (${$uid.$uname}{'realname'} ? &CreateUserDisplayLine($uname) : ($uname ? qq~$uname ($maintxt{'470a'})~ : $maintxt{'470a'})) . ', '; # 470a == Ex-Member
			}
			$usernamelinkbcc =~ s/, $//;
			$toTitleBCC = qq~$inmes_txt{'326'}:~;
		}

	} elsif ($INFO{'caller'} == 3) {
		if ($mstatus !~ /b/) {
			if ($mstatus !~ /gr/) {
				foreach my $uname (split(/,/, $mtousers)) {
					&LoadValidUserDisplay($uname);
					$usernamelinkto .= (${$uid.$uname}{'realname'} ? &CreateUserDisplayLine($uname) : ($uname ? qq~$uname ($maintxt{'470a'})~ : $maintxt{'470a'})) . ', '; # 470a == Ex-Member
				}
			} else {
				my ($guestName, $guestEmail) = split(/ /, $mtousers);
				$guestName =~ s/%20/ /g; 
				$usernamelinkto = qq~$guestName (<a href="mailto:$guestEmail">$guestEmail</a>)~;
			}
			$toTitle = qq~$inmes_txt{'324'}:~;
			if ($mccusers && $musername eq $username) {
				foreach my $uname (split(/,/, $mccusers)) {
					&LoadValidUserDisplay($uname);
					$usernamelinkcc .= (${$uid.$uname}{'realname'} ? &CreateUserDisplayLine($uname) : ($uname ? qq~$uname ($maintxt{'470a'})~ : $maintxt{'470a'})) . ', '; # 470a == Ex-Member
				}
				$usernamelinkcc =~ s/, $//;
				$toTitleCC = qq~$inmes_txt{'325'}:~;
			}
			if ($mbccusers && $musername eq $username) {
				foreach my $uname (split(/,/, $mbccusers)) {
					&LoadValidUserDisplay($uname);
					$usernamelinkbcc .= (${$uid.$uname}{'realname'} ? &CreateUserDisplayLine($uname) : ($uname ? qq~$uname ($maintxt{'470a'})~ : $maintxt{'470a'})) . ', '; # 470a == Ex-Member
				}
				$usernamelinkbcc =~ s/, $//;
				$toTitleBCC = qq~$inmes_txt{'326'}:~;
			}
		} else {
			foreach my $uname (split(/,/, $mtousers)) {
				if ($uname eq 'all') { $usernamelinkto .= qq~<b>$inmes_txt{'bmallmembers'}</b>~ . ', ';
				} elsif ($uname eq 'mods') { $usernamelinkto .= qq~<b>$inmes_txt{'bmmods'}</b>~ . ', ';
				} elsif ($uname eq 'gmods') { $usernamelinkto .= qq~<b>$inmes_txt{'bmgmods'}</b>~ . ', ';
				} elsif ($uname eq 'admins') { $usernamelinkto .= qq~<b>$inmes_txt{'bmadmins'}</b>~ . ', ';
				} else {
					my ($title, undef) = split(/\|/, $NoPost{$uname}, 2);
					$usernamelinkto .= qq~<b>$title</b>~ . ', ';
				}
			}
			$toTitle = qq~$inmes_txt{'324'} $inmes_txt{'327'}:~;
		}
		$usernamelinkto =~ s/, $//;

		if ($mstatus eq 'g') {
			my ($guestName, $guestEmail) = split(/ /, $musername);
			$guestName =~ s/%20/ /g; 
			$usernamelinkfrom = qq~$guestName (<a href="mailto:$guestEmail">$guestEmail</a>)~;
		} else {
			&LoadValidUserDisplay($musername);
			$usernamelinkfrom = ${$uid.$musername}{'realname'} ? &CreateUserDisplayLine($musername) : ($musername ? qq~$musername ($maintxt{'470a'})~ : $maintxt{'470a'}); # 470a == Ex-Member
		}
		$fromTitle = qq~$inmes_txt{'318'}:~;

	} elsif ($INFO{'caller'} == 5 && $mstatus eq 'g') {
		my ($guestName, $guestEmail) = split(/ /, $musername);
		$guestName =~ s/%20/ /g;
		$usernamelinkfrom = qq~$guestName (<a href="mailto:$guestEmail">$guestEmail</a>)~;
		$fromTitle = qq~$inmes_txt{'318'}:~;

	} elsif ($INFO{'caller'} == 5 && $mstatus =~ /b/) {
		if ($mtousers) {
			foreach my $uname (split(/,/, $mtousers)) {
				if ($uname eq 'all') { $usernamelinkto .= qq~<b>$inmes_txt{'bmallmembers'}</b>~ . ', ';
				} elsif ($uname eq 'mods') { $usernamelinkto .= qq~<b>$inmes_txt{'bmmods'}</b>~ . ', ';
				} elsif ($uname eq 'gmods') { $usernamelinkto .= qq~<b>$inmes_txt{'bmgmods'}</b>~ . ', ';
				} elsif ($uname eq 'admins') { $usernamelinkto .= qq~<b>$inmes_txt{'bmadmins'}</b>~ . ', ';
				} else {
					my ($title, undef) = split(/\|/, $NoPost{$uname}, 2);
					$usernamelinkto .= qq~<b>$title</b>~ . ', ';
				}
			}
			$usernamelinkto =~ s/, $//;
			$toTitle = qq~$inmes_txt{'324'} $inmes_txt{'327'}:~;
		}

		&LoadValidUserDisplay($musername);
		$usernamelinkfrom = ${$uid.$musername}{'realname'} ? &CreateUserDisplayLine($musername) : ($musername ? qq~$musername ($maintxt{'470a'})~ : $maintxt{'470a'}); # 470a == Ex-Member

		$fromTitle = qq~$inmes_txt{'318'}:~;
	}

	$PMnav = &buildPMNavigator;

	&ToChars($msub);
	$msub = &Censor($msub);

	$message = $immessage;
	&wrap;
	if ($enable_ubbc) {
		if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
		&DoUBBC;
	}
	&wrap2;
	&ToChars($message);
	$message = &Censor($message);

	$avstyle = '';

	$showIM = qq~
<table border="0" width="100%" cellspacing="1" cellpadding="1" class="bordercolor" style="table-layout: fixed">
<tr>
	<td class="windowbg" align="left" valign="top" colspan="2">
		<div style="width: 99%; padding: 2px; margin: 2px;">
	~;

	if ($fromTitle) {
		$showIM .= qq~
		<span class="small" style="width: 99%;">
		<b>$fromTitle</b> $usernamelinkfrom
		</span><br />
		~;
	}

	if ($toTitle) {
		$showIM .= qq~
		<span class="small" style="width: 99%;">
		<b>$toTitle</b> $usernamelinkto
		</span><br />
		~;
	}

	if ($toTitleCC) {
		$showIM .= qq~
		<span class="small" style="width: 99%;">
		<b>$toTitleCC</b> $usernamelinkcc
		</span><br />
		~;
	}

	if ($toTitleBCC) {
		$showIM .= qq~
		<span class="small" style="width: 99%;">
		<b>$toTitleBCC</b> $usernamelinkbcc
		</span><br />
		~;
	}

	$showIM .= qq~
		</div>
	</td>
</tr>
<tr>
	<td class="windowbg2" align="left" valign="top" colspan="2">
		<div style="width: 99%; padding: 2px; margin: 2px;">
		<span class="small" style="width: 99%;">
		<b>$inmes_txt{'70'}: $msub</b><br />
		<b>$inmes_txt{'317'}:</b> $mydate
		</span>
		</div>
	</td>
</tr>
<tr>
	<td class="windowbg2" align="left" valign="top" colspan="2">
		<div style="width: 99%; padding: 2px; margin: 2px;">
		<span class="message" style="float: left; width: 99%; overflow: auto; padding-bottom: 10px; margin-bottom: 10px;">
		$message
		</span>
		</div>
	</td>
</tr>
~;

	if ($signature) {
		$showIM .= qq~
<tr>
	<td class="windowbg2" align="right" colspan="2">
	<div style="float: left; width: 99%; padding-top: 2px; margin-top: 2px; text-align: left;">
		<span class="small">$signature</span>
	</div>
	</td>
</tr>~;
	}

	if ($iamadmin || $iamgmod && $gmod_access2{'ipban2'} eq 'on') { $imip = $imip; }
	else { $imip = $inmes_txt{'511'}; }

	my $postMenuTemp = $sendEmail . $sendPM . $membAdInfo . "&nbsp;"; 
	$postMenuTemp =~ s/\Q$menusep//i;

	$showIM .= qq~
<tr>
	<td class="windowbg" align="right" colspan="2">
	<div style="float: left; width: 99%; padding-top: 5px; margin-top: 2px; text-align: right;">
		<span class="small"><img src="$imagesdir/ip.gif" border="0" alt="" /> $imip</span>
	</div>
	</td>
</tr>
<tr>
	<td class="windowbg2" align="left" valign="middle" colspan="2">
	<div style="float: left; text-align: left; width: 55%; padding: 2px; margin: 2px;">
		<span class="small">$postMenuTemp</span>
	</div>
	<div style="float: right; text-align: right; width: 40%; padding: 2px; margin: 2px;">
	<span class="small">~;

	$mreplyno++;
	if ($INFO{'caller'} == 1 || ($INFO{'caller'} == 3 && $musername ne '') || ($INFO{'caller'} == 5 && $musername ne '')) { ## inbox / stored inbox can reply/quote
		if ($mstatus eq 'g') {
			$showIM .= qq~<a href="$scripturl?action=imsend;caller=$INFO{'caller'};quote=$mreplyno;replyguest=1;id=$messageid">$img{'reply_ims'}</a>~;
		} else {
			$showIM .= qq~
			<a href="$scripturl?action=imsend;caller=$INFO{'caller'};quote=$mreplyno;to=$useraccount{$musername};id=$messageid">$img{'quote'}</a>$menusep
			<a href="$scripturl?action=imsend;caller=$INFO{'caller'};reply=$mreplyno;to=$useraccount{$musername};id=$messageid">$img{'reply_ims'}</a>$menusep~;
		}
	}

	if ($INFO{'caller'} != 5) {
		$showIM .= qq~
			<a href="$scripturl?action=imsend;caller=$INFO{'caller'};quote=$mreplyno;forward=1;id=$messageid">$img{'forward'}</a>$menusep~;
	}

	if ($INFO{'caller'} != 5 || ($INFO{'caller'} == 5 && ($iamadmin || $username eq $musername))) {
		$showIM .= qq~
			<a href="$scripturl?action=deletemultimessages;caller=$INFO{'caller'};deleteid=$messageid" onclick="return confirm('$inmes_txt{'770'}');">$img{'im_remove'}</a>
		~;
	}

	my $notme = $musername eq $username ? $mtousers : $musername;
	$notme = ${$uid.$notme}{'realname'};
	$showIM .= qq~
	</span>
	</div>
	</td>
</tr>
<tr>
<td align="right" class="windowbg2" colspan="2">
	<div style="float: left; text-align: left; padding: 2px; margin: 2px;"><span class="small">~ . ($notme ? qq~<a href="$scripturl?action=pmsearch;searchtype=user;search=$notme">$inmes_imtxt{'42'} <i>$notme</i></a>~ : "&nbsp;") . qq~</span></div>
	<div style="float: right; text-align: right; padding: 2px; margin: 2px;"><span class="small">$PMnav</span></div>
</td>
</tr>
</table>

</div>
~;

	return $showIM;
}

## build the links for single PM display
sub buildPMNavigator {
	if ($previd ne '') { $PMnav = qq~$previd~; }
	if ($allid ne '' && $previd ne '') { $PMnav .= qq~ | $allid~; }
	elsif ($allid ne '') { $PMnav = qq~$allid~; }
	if ($nextid ne '' && $allid ne '') { $PMnav .= qq~ | $nextid~; }
	return $PMnav;
}

## show original PM/BM or the PM/BM before Preview at the bottom of the massage field
sub doshowims {
	my $tempdate;
	if ($INFO{'id'} && !$INFO{'replyguest'}) {
		my $messageCount = 0;
		my $messageFoundFlag = 0;
		foreach my $message (@messages) {
			my $tmnum = (split /\|/, $message)[0];
			if ($tmnum == $INFO{'id'}) { $messageFoundFlag = 1; last; }
			else	{$messageCount ++;}
		}
		## as a backup, if its not found that way, revert to the list member
		if (!$messageFoundFlag) { $messageCount = $INFO{'num'}; }
		($messageid, $musername, $mto, $mtocc, $mtobcc, $msub, $mdate, $message, $mparid, $mreplyno, $mip, $mstatus, $mflags, $mstore, $mattach) = split(/\|/, $messages[$messageCount]);
		$tempdate = &timeformat($mdate);

	} else {
		return;
	}

	&ToChars($msub);
	$msub = &Censor($msub);

	&wrap;
	if ($enable_ubbc) {
		if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
		&DoUBBC;
	}
	&wrap2;
	&ToChars($message);
	$message = &Censor($message);

	if (!${$uid.$musername}{'password'}) { &LoadUser($musername); }
	my $musernameRealName = ${$uid.$musername}{'realname'};
	if(!$musernameRealName) { $musernameRealName = $musername; }

	$imsend .= qq~
	<tr>
	  <td class="windowbg">
		<table cellspacing="1" cellpadding="0" width="100%" align="center" class="bordercolor"><tr><td>
			<table class="windowbg" cellspacing="0" cellpadding="2" width="100%" align="center" style="table-layout:fixed">
				<tr><td class="titlebg" colspan="2"><b>$inmes_txt{'70'}: $msub</b></td></tr>
				<tr><td align="left" class="catbg"><span class="small">$inmes_txt{'318'}: $musernameRealName</span></td><td class="catbg" align="right"><span class="small">~ . (($INFO{'id'} && $INFO{'caller'} != 4) ? "$inmes_txt{'30'}: " : ($INFO{'id'} ? "$inmes_txt{'savedraft'} $inmes_txt{'30'}: " : "")) . qq~$tempdate</span></td></tr>
				<tr><td class="windowbg2" colspan="2"><div class="message" style="float:left; width:100%;">$message</div></td></tr>
			</table></td></tr>
		</table>
	  </td>
	</tr>\n
	~;
}

1;