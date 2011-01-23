###############################################################################
# MyCenter.pl                                                                 #
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

$mycenterplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('InstantMessage');
&LoadLanguage('MyCenter');
require "$templatesdir/$usemycenter/MyCenter.template";
if (-e "$vardir/gmodsettings.txt" && $iamgmod) { require "$vardir/gmodsettings.txt"; }
$mycenter_txt{'welcometxt'} =~ s/USERLABEL/${$uid.$username}{'realname'}/g;

$showIM = '';
$IM_box = '';
$showProfile = '';
$PMfileToOpen = '';
$sendBMess = '';
$isBMess = '';
$showFavorites = '';
$showNotifications = '';

##  here begins the user centre, from the old IMIndex
sub mycenter {
	if ($iamguest) { &fatal_error('im_members_only'); }

	&LoadBroadcastMessages($username); # get the BM infos

	$IM_box = '';
	my $PMfileToOpen = '';
	my @otherStoreFolders = ();
	my $otherStoreSelect = '';
	$replyguest = $INFO{'replyguest'} || $FORM{'replyguest'};
	## select view by action
	if ($action =~ /^im/ || $action eq 'deletemultimessages' || $action eq 'pmsearch') { $view = 'pm'; }
	elsif ($action eq 'mycenter') { $view = 'mycenter'; }
	elsif ($action eq 'shownotify' || $action=~ /^notify/ || $action eq 'boardnotify2') { $view = 'notify'; $mctitle = $img_txt{'418'}; }
	elsif ($action eq 'myusersrecentposts') { $view = 'recentposts'; }
	elsif ($action eq 'favorites') { $view = 'favorites'; $mctitle = $img_txt{'70'}; }
	elsif ($action =~ /^my/) { $view = 'profile'; }
	## viewing PMs
	if ($view eq 'pm') { # pm views
		## viewing a message box
		require "$sourcedir/InstantMessage.pl";
		if ($action eq 'im' || $action eq 'imoutbox' || $action eq 'imstorage') {
			my $foundextra = 0;
			foreach my $storefolder (split(/\|/, ${$username}{'PMfolders'})) {
				if($storefolder ne $INFO{'viewfolder'}) {
					push (@otherStoreFolders, $storefolder);
					$foundextra = 1;
				}
			}
			if ($foundextra > 0) {
				$otherStoreSelect = qq~ $inmes_txt{'storein'} <select name="tostorefolder" id="tostorefolder">~;
				foreach my $otherFolder (@otherStoreFolders) {
					my $otherFolderName = $otherFolder;
					if ($otherFolder eq 'in') { $otherFolderName = $im_folders_txt{'in'}; }
					elsif ($otherFolder eq 'out') { $otherFolderName = $im_folders_txt{'out'}; }
					$otherStoreSelect .= qq~<option value="$otherFolder">$otherFolderName</option>~;
				}
				$otherStoreSelect .= qq~</select>~;
			}
		}
		## inbox
		if ($action eq 'im' || ($action eq 'imshow' && $INFO{'caller'} == 1)) {
			$mctitle = $inmes_txt{'inbox'};
			$status = $inmes_imtxt{'status'};
			$senderinfo = $inmes_txt{'318'};
			$callerid = 1;
			$boxtxt = $inmes_txt{'316'};
			$movebutton  = qq~<input type="submit" name="imaction" value="$inmes_imtxt{'store'}" class="button" />$otherStoreSelect $inmes_txt{'storeor'}~;
			$IM_box = $inmes_txt{'inbox'};
			if($INFO{'focus'} eq 'bmess' || $INFO{'bmess'} eq 'yes') { $IM_box = $inmes_txt{'broadcast'}; $callerid = 5; }
			$PMfileToOpen = 'msg';
		}
		##  draft box
		elsif ($action eq 'imdraft') {
			$mctitle = $inmes_txt{'draft'};
			$status = $inmes_imtxt{'status'};
			$senderinfo = $inmes_txt{'324'};
			$callerid = 4;
			$boxtxt = $inmes_txt{'draft'};
			$movebutton = '';
			$IM_box = $inmes_txt{'draft'};
			$PMfileToOpen = 'imdraft';
		}
		## outbox
		elsif ($action eq 'imoutbox' || ($action eq 'imshow' && $INFO{'caller'} == 2)) {
			$mctitle = $inmes_txt{'773'};
			$status = $inmes_imtxt{'status'};
			$senderinfo = $inmes_txt{'324'};
			$callerid = 2;
			$boxtxt = $inmes_txt{'outbox'};
			$movebutton  = qq~<input type="submit" name="imaction" value="$inmes_imtxt{'store'}" class="button" />$otherStoreSelect $inmes_txt{'storeor'}~;
			$IM_box = $inmes_txt{'outbox'};
			$PMfileToOpen = 'outbox';
		}
		# store
		elsif ($action eq 'imstorage' || ($action eq 'imshow' && $INFO{'caller'} == 3)) {
			$mctitle = $inmes_txt{'774'};
			$status = '';
			$senderinfo = $inmes_txt{'318'};
			if ($INFO{'viewfolder'} eq 'out') { $senderinfo = $inmes_txt{'324'}; }
			elsif ($INFO{'viewfolder'} ne 'in') { $senderinfo = qq~$inmes_txt{'318'} / $inmes_txt{'324'}~; }
			$callerid = 3;
			$boxtxt = $inmes_txt{'storage'};
			$movebutton  = qq~<input type="submit" name="imaction" value="$inmes_imtxt{'store'}" class="button" />$otherStoreSelect $inmes_txt{'storeor'}~;
			$IM_box = $inmes_txt{'storage'};
			if ($INFO{'viewfolder'} eq 'in' || $INFO{'viewfolder'} eq 'out') { $IM_box .= qq~ &rsaquo; $im_folders_txt{"$INFO{'viewfolder'}"}~; }
			elsif ($INFO{'viewfolder'}) { $IM_box .= qq~ &rsaquo; $INFO{'viewfolder'}~; }
			$PMfileToOpen = 'imstore';
		}
		## sending a message / previewing
		elsif ($action eq 'imsend' || ($action eq 'imsend2' && $FORM{'previewim'})) {
			$IM_box = $inmes_txt{'148'};
			if ($INFO{'forward'} == 1) { $IM_box = $inmes_txt{'forward'}; }
			if ($INFO{'reply'}) { $IM_box = $inmes_txt{'replymess'}; }
			&IMPost;
			&buildIMsend;
			&doshowims;
		}
		## posting the message or draft
		elsif ($action eq 'imsend2' || $FORM{'draft'}) {
			$IM_box = $inmes_txt{'148'};
			if($INFO{'forward'} == 1) { $IM_box = $inmes_txt{'forward'}; }
			if($INFO{'reply'}) { $IM_box = $inmes_txt{'replymess'}; }
			&IMsendMessage;
		}
		elsif ($action eq 'imshow' && $INFO{'caller'} == 5) {
			$mctitle = $inmes_txt{'broadcast'};
			$status = $inmes_imtxt{'status'};
			$senderinfo = $inmes_txt{'318'};
			$callerid = 5;
			$boxtxt = $inmes_txt{'316'};
			$movebutton = qq~<input type="submit" name="imaction" value="$inmes_imtxt{'store'}" class="button" />$otherStoreSelect $inmes_txt{'storeor'}~;
			$IM_box = $inmes_txt{'broadcast'};
			$PMfileToOpen = 'msg';
		}
	}
	## viewing front page
	elsif ($view eq "mycenter") {
		$mctitle = "$inmes_txt{'mycenter'}";
	}
	## viewing my profile
	elsif ($view eq "profile") {
		$mctitle = "$mc_menus{'profile'}";
	}
	## viewing my recent posts
	elsif ($view eq 'recentposts') {
		$mctitle = "$inmes_txt{'viewrecentposts'} $inmes_txt{'viewrecentposts2'}";
	}

	## draw the container
	&drawPMbox($PMfileToOpen);
	&LoadIMs;

	# navigation link
	$yynavigation = qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $mctitle~;

	## set template up
	$mycenter_template =~ s/({|<)yabb mcviewmenu(}|>)/$MCViewMenu/g;
	$mycenter_template =~ s/({|<)yabb mcmenu(}|>)/$yymcmenu/g;
	$mycenter_template =~ s/({|<)yabb mcpmmenu(}|>)/$MCPmMenu/g;
	$mycenter_template =~ s/({|<)yabb mcprofmenu(}|>)/$MCProfMenu/g;
	$mycenter_template =~ s/({|<)yabb mcpostsmenu(}|>)/$MCPostsMenu/g;
	$mycenter_template =~ s/({|<)yabb mcglobformstart(}|>)/$MCGlobalFormStart/g;
	$mycenter_template =~ s/({|<)yabb mcglobformend(}|>)/ ($MCGlobalFormStart ? "<\/form>" : "") /e;
	$mycenter_template =~ s/({|<)yabb mcextrasmilies(}|>)/$MCExtraSmilies/g;
	$mycenter_template =~ s/({|<)yabb mccontent(}|>)/$MCContent/g;
	$mycenter_template =~ s/({|<)yabb mctitle(}|>)/$mctitle/g;
	$mycenter_template =~ s/({|<)yabb selecthtml(}|>)/$selecthtml/g;
	$mycenter_template =~ s/({|<)yabb forumjump(}|>)//g;

	## end new style box
	$yymain .= $mycenter_template;
	if (%usernames_life_quote) { # for display names in Quotes in LivePreview
		$yymain .= qq~
<script language="JavaScript" type="text/javascript">
<!-- //
	~ . join(';', map { qq~LivePrevDisplayNames['$_'] = "$usernames_life_quote{$_}"~ } keys %usernames_life_quote) . qq~;
// -->
</script>\n\n~;
	}
	&template;
}

sub AddFolder {
	if ($iamguest) { &fatal_error("im_members_only"); }
	my $storefolders = ${$username}{'PMfolders'};
	my @currStoreFolders = split(/\|/, ${$username}{'PMfolders'});
	my $newStoreFolders = "in|out";

	my $newFolderName = $FORM{'newfolder'};
	chomp $newFolderName;

	my $x = 0;
	nxtfdr: foreach my $currStoreFolder (@currStoreFolders) {
		if ($FORM{'newfolder'}) {
			if ($newFolderName =~ /[^0-9A-Za-z \-_]/) { &fatal_error('invalid_character', $inmes_txt{'foldererror'}); }
			if ($FORM{'newfolder'} eq $currStoreFolder) { &fatal_error('im_folder_exists'); }
		} elsif ($FORM{'delfolders'}) {
			if ($currStoreFolder ne 'in' && $currStoreFolder ne 'out' && $FORM{"delfolder$x"} ne 'del') {
				$newStoreFolders .= qq~|$currStoreFolder~;
			}
		}
		$x++;
	}
	if ($FORM{'newfolder'}) { ${$username}{'PMfolders'} = qq~$storefolders|$FORM{'newfolder'}~; }
	elsif ($FORM{'delfolders'}) { ${$username}{'PMfolders'} = $newStoreFolders; }
	&buildIMS($username, 'update');
	$yySetLocation = qq~$scripturl?action=mycenter~;
	&redirectexit;
}

##  call an unopened message back
sub CallBack {
	if ($iamguest) { &fatal_error("im_members_only"); }

	my $receiver = $INFO{'receiver'}; # set variables from GET - localised

	if ($receiver && $receiver !~ /,/) {
		my $receiver = &decloak($receiver);
		if (&CallBackRec($receiver,$INFO{'rid'},1)) { &fatal_error("im_deleted"); }
		&updateIMS($receiver,$INFO{'rid'},'callback');
	} elsif ($receiver) {
		my $rec;
		foreach $rec (split(/,/, $receiver)) {
			$rec = &decloak($rec);
			if (&CallBackRec($rec,$INFO{'rid'},0)) { &fatal_error("im_deleted_multi"); }
		}
		foreach $rec (split(/,/, $receiver)) {
			$rec = &decloak($rec);
			&CallBackRec($rec,$INFO{'rid'},1);
			&updateIMS($rec,$INFO{'rid'},'callback');
		}
	}

	&updateMessageFlag($username, $INFO{'rid'}, 'outbox', '', 'c');

	$yySetLocation = qq~$scripturl?action=imoutbox~;
	&redirectexit;
}

sub CallBackRec {
	my ($receiver,$rid,$do_it) = @_;

	if (!&checkfor_DBorFILE("$memberdir/$receiver.vars")) {
		return 0 ;
	} else {
		${$uid.$receiver}{'mysql'} = 1 if $use_MySQL;
	}

	my ($nodel,$rmessageid,$fromuser,$flags,@rmsg);
	## run through and drop the message line
	foreach (($do_it ? &read_DBorFILE(0,CALLBACK,$memberdir,$receiver,'msg') : &read_DBorFILE(0,'',$memberdir,$receiver,'msg'))) {
		($rmessageid,$fromuser, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, $flags, undef) = split(/\|/, $_, 14);
		if (!$do_it) {
			if ($rmessageid == $rid && $fromuser eq $username) {
				if ($flags !~ /u/i) { $nodel = 1; }
				last;
			}
		} else {
			if ($rmessageid != $rid || $fromuser ne $username) { push(@rmsg, $_); }
			elsif ($flags !~ /u/i) { push(@rmsg, $_); $nodel = 1;}
		}
	}
	&write_DBorFILE(${$uid.$receiver}{'mysql'},CALLBACK,$memberdir,$receiver,'msg',@rmsg) if $do_it;
	$nodel;
}

sub checkIMS { # lookup value in pm file
	my $user = $_[0];
	my $id = $_[1];
	my $checkfor = $_[2];

	## has the message been opened by the receiver? 1 = yes 0 = no
	if ($checkfor eq 'messageopened') {
		my $messageFoundFlag = &checkMessageFlag($user, $id, 'msg', 'u');
		if ($messageFoundFlag == 1) { return 0; }
		else {$messageFoundFlag = &checkMessageFlag($user, $id, 'imstore', 'u'); }
		if ($messageFoundFlag == 1) { return 0; }
		else { return 1; }

	## has the message been replied to? 1 = yes 0 = no
	} elsif ($checkfor eq 'messagereplied') {
		## check in msg and imstore
		my $messageFoundFlag = &checkMessageFlag($user, $id, 'msg', 'r');
		if ($messageFoundFlag == 1) { return 1; }
		else {$messageFoundFlag = &checkMessageFlag($user, $id, 'imstore', 'r'); }
		if ($messageFoundFlag == 1) { return 1; }
		else { return 0; }
	}
}

sub checkMessageFlag { # look for $user.$pmFile, find $id message and check for $messageFlag
	my ($user, $id, $pmFile, $messageFlag) = @_;
	my $messageFoundFlag = 0;
	if (%{'MF' . $user . $pmFile}) {
		if (exists ${'MF' . $user . $pmFile}{$id} && ${'MF' . $user . $pmFile}{$id} =~ /$messageFlag/i) { $messageFoundFlag = 1; }
	} elsif (&checkfor_DBorFILE("$memberdir/$user.$pmFile")) {
		my @userMessages = &read_DBorFILE(0,'',$memberdir,$user,$pmFile);
		my ($uMessageId,$uMessageFlags);
		foreach (@userMessages) {
			($uMessageId, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, $uMessageFlags, undef) = split(/\|/, $_,  14);
			${'MF' . $user . $pmFile}{$uMessageId} = $uMessageFlags;
			if ($uMessageId == $id && $uMessageFlags =~ /$messageFlag/i) { $messageFoundFlag = 1; }
		}
	}
	$messageFoundFlag;
}

sub updateMessageFlag { # look for $user.$pmFile, find $id message and check for $messageFlag. change to $newMessageFlag
	my ($user, $id, $pmFile, $messageFlag, $newMessageFlag) = @_;
	my $messageFoundFlag = 0;
	if ((!exists ${'MF' . $user . $pmFile}{$id} || ($messageFlag ne '' && ${'MF' . $user . $pmFile}{$id} =~ /$messageFlag/) || ($messageFlag eq '' && !${'MF' . $user . $pmFile}{$id} =~ /$newMessageFlag/)) && &checkfor_DBorFILE("$memberdir/$user.$pmFile")) {
		my @userFile;
		foreach my $userMessage (&read_DBorFILE(0,USERFILE,$memberdir,$user,$pmFile)) {
			my ($uMessageId, $uFrom, $uToUser, $uTocc, $uTobcc, $uSubject, $uDate, $uMessage, $uPid, $uReply , $uip, $uStatus, $uMessageFlags, $uStorefolder, $uAttach) = split(/\|/, $userMessage);
			if ($uMessageId == $id) {
				$uMessageFlags =~ s/$newMessageFlag//gi if $newMessageFlag ne '';
				if ($uMessageFlags =~ s/$messageFlag/$newMessageFlag/i) {
					$messageFoundFlag = 1;
				} else {
					$uMessageFlags .= $newMessageFlag;
				}
				$userMessage = "$uMessageId|$uFrom|$uToUser|$uTocc|$uTobcc|$uSubject|$uDate|$uMessage|$uPid|$uReply|$uip|$uStatus|$uMessageFlags|$uStorefolder|$uAttach";
			}
			${'MF' . $user . $pmFile}{$uMessageId} = $uMessageFlags;
			push(@userFile, $userMessage);
		}
		&write_DBorFILE(${$uid.$user}{'mysql'},USERFILE,$memberdir,$user,$pmFile,@userFile);
	}
	$messageFoundFlag;
}

sub updateIMS { # update .ims file for user: &updateIMS(<user>,<PM msgid>,[target/action])
	my ($user,$id,$target) = @_;

	# load the user who is processed here, if not allready loaded
	&buildIMS($user, 'load') unless exists ${$user}{'PMmnum'};

	# new msg received - add to the inbox lists and increment the counts
	if ($target eq 'messagein') {
		# read the lines into temp variables
		${$user}{'PMmnum'}++;
		${$user}{'PMimnewcount'}++;

	# message sent - add to the outbox list and increment count
	} elsif ($target eq 'messageout') {
		${$user}{'PMmoutnum'}++;

	# reading msg in inbox - newcount -1, remove from unread list
	} elsif ($target eq 'inread') {
		if (&updateMessageFlag($user, $id, 'msg', 'u', '')) { ${$user}{'PMimnewcount'}--; }
		else { return; }

	# callback message - take off imnewcount, mnum
	} elsif ($target eq 'callback') {
		${$user}{'PMmnum'}--;
		${$user}{'PMimnewcount'}--;

	# draft added
	} elsif ($target eq 'draftadd') {
		${$user}{'PMdraftnum'}++;

	# draft send
	} elsif ($target eq 'draftsend') {
		${$user}{'PMdraftnum'}--;
	}

	&buildIMS($user, 'update'); # rebuild the .ims file it with the new values
}

# delete|move IMs
sub Del_Some_IM {
	&LoadLanguage('InstantMessage');
	if ($iamguest) { &fatal_error('im_members_only'); }

	my @fileToOpen = ($username,"msg");
	if ($INFO{'caller'} == 2)    { $fileToOpen[1] = "outbox"; }
	elsif ($INFO{'caller'} == 3) { $fileToOpen[1] = "imstore"; }
	elsif ($INFO{'caller'} == 4) { $fileToOpen[1] = "imdraft"; }
	elsif ($INFO{'caller'} == 5) { @fileToOpen = ("broadcast","messages"); }

	my @messages = &read_DBorFILE(0,USRFILE,$memberdir,@fileToOpen);

	# deleting
	my @left_messages;
	if ($FORM{'imaction'} eq $inmes_txt{'remove'} || $INFO{'action'} eq $inmes_txt{'remove'} || $INFO{'deleteid'}) {
		my %CountStore;
		if ($INFO{'caller'} == 2)    { ${$username}{'PMmoutnum'} = 0; }
		elsif ($INFO{'caller'} == 4) { ${$username}{'PMdraftnum'} = 0; }
		elsif ($INFO{'caller'} != 3 && $INFO{'caller'} != 5) { ${$username}{'PMmnum'} = 0; ${$username}{'PMimnewcount'} = 0; }

		if ($INFO{'deleteid'}) { $FORM{"message" . $INFO{'deleteid'}} = 1; } # singel delete

		foreach (@messages) {
			my @m = split(/\|/, $_);
			if (!exists $FORM{"message" . $m[0]}) {
				push(@left_messages, $_);

				if ($INFO{'caller'} == 2)    { ${$username}{'PMmoutnum'}++; }
				elsif ($INFO{'caller'} == 3) { $CountStore{$m[13]}++; }
				elsif ($INFO{'caller'} == 4) { ${$username}{'PMdraftnum'}++; }
				elsif ($INFO{'caller'} != 5) { ${$username}{'PMmnum'}++; ${$username}{'PMimnewcount'}++ if $m[12] =~ /u/; }
			} else {
				if ($INFO{'caller'} == 3) {
					$INFO{'viewfolder'} = $m[13];
				} elsif ($INFO{'caller'} == 5) {
					${$username}{'PMbcRead'} =~ s/$m[0]\b//g unless ${$username}{'PMbcRead'} =~ s/\b$m[0]$//;
				}
			}
		}
		&write_DBorFILE(${$uid.$fileToOpen[0]}{'mysql'},USRFILE,$memberdir,@fileToOpen,@left_messages);
		if ($INFO{'caller'} == 3) {
			${$username}{'PMfoldersCount'} = '';
			${$username}{'PMstorenum'} = 0;
			foreach (split(/\|/, ${$username}{'PMfolders'})) {
				$CountStore{$_} ||= 0;
				${$username}{'PMfoldersCount'} .= ${$username}{'PMfoldersCount'} eq '' ? $CountStore{$_} : "|$CountStore{$_}";
				${$username}{'PMstorenum'} += $CountStore{$_};
			}
		}
		&buildIMS($username, 'update');

	#  moving messages
	} elsif ($FORM{'imaction'} eq $inmes_imtxt{'store'} || $INFO{'imaction'} eq $inmes_imtxt{'store'}) {
		my (@newmessages,%CountStore,$imstorefolder);
		if ($FORM{'tostorefolder'}) { $imstorefolder = $FORM{'tostorefolder'}; }
		elsif ($INFO{'caller'} == 1) { $imstorefolder = 'in'; }
		else { $imstorefolder = 'out'; }

		foreach (@messages) {
			if (!$FORM{"message" . (split(/\|/, $_, 2))[0]}) {
				if ($INFO{'caller'} != 3) {
					push(@left_messages, $_);
				} else {
					my @m = split(/\|/, $_);
					push(@newmessages, [@m]);
					$CountStore{$m[13]}++;
				}
			} else {
				my @m = split(/\|/, $_);
				$m[13] = $imstorefolder;
				push(@newmessages, [@m]);
				$CountStore{$imstorefolder}++;
				if ($INFO{'caller'} != 3) {
					${$username}{'PMstorenum'}++;
					if ($INFO{'caller'} == 1) { ${$username}{'PMmnum'}--; }
					elsif ($INFO{'caller'} == 2) { ${$username}{'PMmoutnum'}--; }
					${$username}{'PMimnewcount'}-- if $m[12] =~ /u/;
				}
			}
		}
		&write_DBorFILE(${$uid.$fileToOpen[0]}{'mysql'},USRFILE,$memberdir,@fileToOpen,@left_messages);

		if (@newmessages) {
			if ($INFO{'caller'} != 3) {
				foreach (&read_DBorFILE(0,'',$memberdir,$username,'imstore')) {
					my @m = split(/\|/, $_);
					push(@newmessages, [@m]);
					$CountStore{$m[13]}++;
				}
			}
			&write_DBorFILE(${$uid.$username}{'mysql'},'',$memberdir,$username,'imstore',map { join('|', @$_) } sort { $$b[6] <=> $$a[6] } @newmessages);

			${$username}{'PMfoldersCount'} = '';
			foreach (split(/\|/, ${$username}{'PMfolders'})) {
				$CountStore{$_} ||= 0;
				${$username}{'PMfoldersCount'} .= ${$username}{'PMfoldersCount'} eq '' ? $CountStore{$_} : "|$CountStore{$_}";
			}
			&buildIMS($username, 'update');
		}
	}

	my $redirect = 'im';
	if ($INFO{'caller'} == 2)    { $redirect = 'imoutbox'; }
	elsif ($INFO{'caller'} == 3) { $redirect = "imstorage;viewfolder=$INFO{'viewfolder'}"; }
	elsif ($INFO{'caller'} == 4) { $redirect = 'imdraft'; }
	elsif ($INFO{'caller'} == 5) { $redirectview = ';focus=bmess'; }

	$yySetLocation = qq~$scripturl?action=$redirect~;
	&redirectexit;
}

# if the user is valid...
sub LoadValidUserDisplay {
	my $muser = $_[0];
	if (!$yyUDLoaded{$muser} && &checkfor_DBorFILE("$memberdir/$muser.vars")) { $sm = 1; &LoadUserDisplay($muser); }
}

# create either a full link or just a name for the IM display
sub CreateUserDisplayLine {
	$usrname = $_[0];
	my $usernamelink;

	$sendPM = '';
	$sendEmail = '';
	$membAdInfo = '';

	if ($yyUDLoaded{$usrname}) {
		unless ($INFO{'caller'} == 2 && ($mstatus =~ /b/ || $mtousers =~ /,/ || $mccusers || $mbccusers)) {
			$signature = ${$uid.$usrname}{'signature'};
			if ($INFO{'caller'} == 2 || $INFO{'caller'} == 3) { $signature = ''; }
			unless($INFO{'caller'} == 5 && $mstatus eq 'g') { &userOnLineStatus($usrname); }

			if (!$iamguest) {
				# Allow instant message sending if current user is a member.
				$sendPM = qq~$menusep<a href="$scripturl?action=imsend;to=$useraccount{$usrname}">$img{'message_sm'}</a>~;
			}
			if (!${$uid.$usrname}{'hidemail'} || $iamadmin || $iamgmod || $allow_hide_email != 1) {
				$sendEmail = qq~$menusep<a href="mailto:${$uid.$usrname}{'email'}">$img{'email_sm'}</a>~;
			}

			$membAdInfo .= ${$uid.$usrname}{'weburl'}   ? $menusep.${$uid.$usrname}{'weburl'} : '';
			$membAdInfo .= ${$uid.$usrname}{'msn'}      ? $menusep.${$uid.$usrname}{'msn'} : '';
			$membAdInfo .= ${$uid.$usrname}{'gtalk'}    ? $menusep.${$uid.$usrname}{'gtalk'} : '';
			$membAdInfo .= ${$uid.$usrname}{'skype'}    ? $menusep.${$uid.$usrname}{'skype'} : '';
			$membAdInfo .= ${$uid.$usrname}{'myspace'}  ? $menusep.${$uid.$usrname}{'myspace'} : '';
			$membAdInfo .= ${$uid.$usrname}{'facebook'} ? $menusep.${$uid.$usrname}{'facebook'} : '';
			$membAdInfo .= ${$uid.$usrname}{'icq'}      ? $menusep.${$uid.$usrname}{'icq'} : '';
			$membAdInfo .= ${$uid.$usrname}{'yim'}      ? $menusep.${$uid.$usrname}{'yim'} : '';
			$membAdInfo .= ${$uid.$usrname}{'aim'}      ? $menusep.${$uid.$usrname}{'aim'} : '';
		}
		$usernamelink = $link{$usrname};
		if ($musername eq $username) {
			$imOpened = &checkIMS($usrname, $messageid, 'messageopened');
			&LoadUser($usrname);
			if (!$imOpened && (${$uid.$usrname}{'notify_me'} < 2 || $enable_notifications < 2)) { $usernamelink .= qq~ <span class="small">(<a href="$scripturl?action=imcb;rid=$messageid;receiver=$useraccount{$usrname}" onclick="return confirm('$inmes_imtxt{'73'}')">$inmes_imtxt{'83'}</a>)</span>~; }
		}
	} else {
		$usernamelink = qq~<b>$usrname</b>~;
	}
	$usernamelink;
}

#  posting the IM
sub IMPost {
	if (($INFO{'bmess'} || $FORM{'isBMess'}) eq 'yes') { $sendBMess = 1; }
	##  if user isn't a FA/gmod and has a postcount below the threshold
	if (!$staff && ${$uid.$username}{'postcount'} < $numposts) {
		&fatal_error('im_low_postcount');
	}
	##  guests not allowed
	if ($iamguest) { &fatal_error('im_members_only'); }
	my ($mdate, $mip, $mmessage);
	##  if the IM has a number assigned already, open the right IM file
	if ($INFO{'id'} ne '' && !$replyguest) {
		if ($INFO{'caller'} < 5) { &updateIMS($username, $INFO{'id'}, 'inread'); }

		my @pmFileType = ($username,"msg");
		if ($INFO{'caller'} == 2)    { $pmFileType[1] = "outbox"; }
		elsif ($INFO{'caller'} == 3) { $pmFileType[1] = "imstore"; }
		elsif ($INFO{'caller'} == 4) { $pmFileType[1] = "imdraft"; }
		elsif ($INFO{'caller'} == 5) { @pmFileType = ("broadcast","messages"); }

		@messages = &read_DBorFILE(0,'',$memberdir,@pmFileType);

		## split content of IM file up
		foreach my $checkTheMessage (@messages) {
			($qmessageid, $mfrom, $mto, $mtocc, $mtobcc, $msubject, $mdate, $message, $mparid, $mreplyno, $mip, $mstatus, $mflags, $mstore, $mattach) = split(/\|/, $checkTheMessage);
			if ($qmessageid == $INFO{'id'}) { last; }
		}
		## remove 're:' from subject (why?)
		$msubject =~ s/Re: //g;
		## if replying/quoting, up the reply# by 1
		if ($INFO{'quote'} || $INFO{'reply'}) { $mreplyno++; $INFO{'status'} = $mstatus; }
		##  if quote
		if ($INFO{'reply'}) { $message = ''; }
		if ($INFO{'quote'}) {
			# swap out brs and spaces
			$message =~ s~<br.*?>~\n~gi;
			$message =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/ig;
			if (!$nestedquotes) {
				$message =~ s~\n{0,1}\[quote([^\]]*)\](.*?)\[/quote([^\]]*)\]\n{0,1}~\n~isg;
			}
			if ($mfrom ne "" && $do_scramble_id) { $cloakedAuthor = &cloak($mfrom); }
			else { $cloakedAuthor = $mfrom; }

			# next 2 lines for display names in Quotes in LivePreview
			&LoadUser($mfrom);
			$usernames_life_quote{$cloakedAuthor} = ${$uid.$mfrom}{'realname'};

			$quotestart = int($quotemsg / $maxmessagedisplay) * $maxmessagedisplay;
			if ($INFO{'forward'} || $INFO{'quote'}) {
				$message    = qq~[quote author=$cloakedAuthor link=impost date=$mdate\]$message\[/quote\]\n~;
			}
			if ($message =~ /\#nosmileys/isg) { $message =~ s/\#nosmileys//isg; $nscheck = "checked"; }
		}
		if ($INFO{'reply'} || $INFO{'forward'} || $INFO{'quote'}) { $msubject = "Re: $msubject"; }
	} elsif ($replyguest) {
		## split content of IM file up
		foreach my $checkTheMessage (&read_DBorFILE(0,'',$memberdir,'broadcast','messages')){
			($qmessageid, $mfrom, $mto, $mtocc, $mtobcc, $msubject, $mdate, $message, $mparid, $mreplyno, $mip, $mstatus, $mflags, $mstore, $mattach) = split(/\|/, $checkTheMessage);
			if ($qmessageid == $INFO{'id'}) { last; }
		}
		($guestName, $guestEmail) = split(/\ /, $mfrom);
		$guestName =~ s/%20/ /g;
		$message =~ s~<br.*?>~\n~gi;
		$message =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/ig;
		$message =~ s~\[b\](.*?)\[/b\]~*$1*~isg;
		$message =~ s~\[i\](.*?)\[/i\]~/$1/~isg;
		$message =~ s~\[u\](.*?)\[/u\]~_$1_~isg;
		$message =~ s~\[.*?\]~~g;
		my $sendtouser = ${$uid.$username}{'realname'};
		my $mdate = &timeformat($mdate, 1);
		require "$sourcedir/Mailer.pl";
		&LoadLanguage('Email');
		#sender email date subject message
		$message = &template_email($replyguestmail, {'sender' => $guestName, 'email' => $guestEmail, 'sendto' => $sendtouser, 'date' => $mdate, 'subject' => $msubject, 'message' => $message});
		$msubject = qq~Re: $msubject~;
	}

	&FromHTML($message) if $INFO{'forward'} || $INFO{'quote'};
	&FromHTML($msubject);

	$submittxt = $inmes_txt{'sendmess'};
	if ($INFO{'forward'} == 1) { $submittxt = $inmes_txt{'forward'}; }
	$destination = 'imsend2';
	$waction = 'imsend';
	$is_preview = 0;
	$post = 'imsend';
	$previewtxt = $inmes_txt{'507'};
	$preview = 'previewim';
	$icon = 'xx';
	$draft = 'draft';
	$mctitle = $inmes_txt{'sendmess'};
	if ($sendBMess) { $mctitle = $inmes_txt{'sendbroadmess'}; }
}

sub MarkAll {
	if ($iamguest) { &fatal_error('im_members_only'); }

	my @messages;
	foreach (&read_DBorFILE(0,MARKALL,$memberdir,$username,'msg')) {
		my ($imessageid, $imusername, $imusernameto, $imusernametocc, $imusernametobcc, $imsub, $imdate, $mmessage, $imessagepid, $imreply, $mip, $imstatus, $imflags, $imstore, $imattach) = split(/\|/, $_);
		if ($imflags =~ s/u//i) {
			push(@messages, "$imessageid|$imusername|$imusernameto|$imusernametocc|$imusernametobcc|$imsub|$imdate|$mmessage|$imessagepid|$imreply|$mip|$imstatus|$imflags|$imstore|$imattach");
		} else { push(@messages, $_); }
	}
	&write_DBorFILE(${$uid.$username}{'mysql'},MARKALL,$memberdir,$username,'msg',@messages);

	${$username}{'PMimnewcount'} = 0;
	&buildIMS($username, 'update');

	if ($INFO{'oldmarkread'}) {
		$yySetLocation = qq~$scripturl?action=im~;
		&redirectexit;
	}
	$elenable = 0;
	die ""; # This is here only to avoid server error log entries!
}

# change type of page index for PM
sub PmPageindex {
	my ($msindx, $trindx, $mbindx, undef) = split(/\|/, ${$uid.$username}{'pageindex'});
	if ($INFO{'action'} eq 'pmpagedrop') { ${$uid.$username}{'pageindex'} = qq~$msindx|$trindx|$mbindx|1~; }
	if ($INFO{'action'} eq 'pmpagetext') { ${$uid.$username}{'pageindex'} = qq~$msindx|$trindx|$mbindx|0~; }
	&UserAccount($username, 'update');
	if ($INFO{'pmaction'} =~ /\//) {
		my ($act, $val) = split(/\//, $INFO{'pmaction'});
		$INFO{'pmaction'} = $act . ';start=' . $val;
	}
	if ($INFO{'focus'} eq 'bmess') { $bmesslink = qq~;focus=bmess~;}
	$yySetLocation = qq~$scripturl?action=$INFO{'pmaction'}$bmesslink;start=$INFO{'start'}~ . ($INFO{'viewfolder'} ? ";viewfolder=$INFO{'viewfolder'}" : "");
	&redirectexit;
}

# draw the whole block , with the menu, and the various PM views.
sub drawPMbox {
	&LoadLanguage('InstantMessage');
	&LoadLanguage('Profile');
	$PMfileToOpen = $_[0];
	@dimmessages;
	@bmessages;
	if (($PMfileToOpen || $INFO{'focus'}) && $view eq 'pm' && ($PM_level  == 1 || ($PM_level  == 2 && $staff) || ($PM_level  == 3 && ($iamadmin || $iamgmod)))) {
		if (!$INFO{'focus'}) {
			if ($callerid < 5) {
				@dimmessages = &read_DBorFILE(1,'',$memberdir,$username,$PMfileToOpen);
				my ($mID,$mFlag);
				foreach (reverse(@dimmessages)) {
					($mID, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, $mFlag, undef) = split(/\|/, $_, 14);
					${$username . $PMfileToOpen}{$mID} = $mFlag;
					if ($INFO{'id'} == -1 && $mFlag eq 'u') {
						$INFO{'id'} = $mID;
					}
				}
			} else {
				@bmessages = &read_DBorFILE(1,'',$memberdir,'broadcast','messages');
			}
		} elsif ($INFO{'focus'} eq 'bmess' && $PMenableBm_level > 0) {
			@bmessages = &read_DBorFILE(1,'',$memberdir,'broadcast','messages');
		}
		$stkmess = 0;
		if (@bmessages > 0) {
			my ($mfrom, $mto, $messStatus);
			foreach my $checkbcm (@bmessages) {
				(undef, $mfrom, $mto, undef, undef, undef, undef, undef, undef, undef, undef, $messStatus, undef) = split (/\|/, $checkbcm);
				if ($mfrom eq $username || &BroadMessageView($mto)) {
					if ($INFO{'sort'} ne 'gpdate' && ($messStatus =~ /g/ || $messStatus =~ /a/)) {
						push (@stkbmessages, $checkbcm);
						$stkmess++;
					} else {
						push (@tmpbmessages, $checkbcm);
					}
				}
			}
			undef @bmessages;
		}
		@stkbmessages = sort {$b <=> $a} @stkbmessages;
		@tmpbmessages = sort {$b <=> $a} @tmpbmessages;
		push (@dimmessages, @stkbmessages);
		push (@dimmessages, @tmpbmessages);
		undef @stkbmessages;
		undef @tmpbmessages;
	}

	$yyjavascript .= qq~
		function changeBox(cbox) {
			box = eval(cbox);
			box.checked = !box.checked;
		}
	~;


	##  new style box ####
	## start with forum > my messages > inbox
	$yymain .= qq~
<script language="JavaScript1.2" src="$yyhtml_root/ajax.js" type="text/javascript"></script>
<script language="JavaScript1.2" type="text/javascript">
<!--
var postas = '$post';
function checkForm(theForm) {
	if (navigator.appName == "Microsoft Internet Explorer" && document.getElementById('iecopy').checked == true) { theForm.message.createTextRange().execCommand("Copy"); }
	if (theForm.subject.value == "") { alert("$post_txt{'77'}"); theForm.subject.focus(); return false }
	~ . ($iamguest && $post ne "imsend" ? qq~if (theForm.name.value == "" || theForm.name.value == "_" || theForm.name.value == " ") { alert("$post_txt{'75'}"); theForm.name.focus(); return false }
	if (theForm.name.value.length > 25)  { alert("$post_txt{'568'}"); theForm.name.focus(); return false }
	if (theForm.email.value == "") { alert("$post_txt{'76'}"); theForm.email.focus(); return false }
	if (! checkMailaddr(theForm.email.value)) { alert("$post_txt{'500'}"); theForm.email.focus(); return false }
~ : qq~if (postas == "imsend") { if (theForm.toshow.value == "") { alert("$post_txt{'752'}"); theForm.toshow.focus(); return false } }~) . qq~
	if (theForm.message.value == "") { alert("$post_txt{'78'}"); theForm.message.focus(); return false }
	return true
}
function NewWindow(mypage, myname, w, h, scroll) {
	var new_win;
	new_win = window.open (mypage, myname, 'status=yes,height='+h+',width='+w+',top=100,left=100,scrollbars=yes');
	new_win.window.focus();
}

// copy user
function copyUser (oElement) {
	var indexToCopyId = oElement.options.selectedIndex;
	var indexToCopy = oElement.options[indexToCopyId];
	var username = indexToCopy.text;
	var userid = indexToCopy.value;
	insert_user ('toshow',username,userid);
}

// insert user name to list
function insert_user (oElement,username,userid) {
	var exists = false;
	var oDoc = window.document;
	var oList = oDoc.getElementById('toshow').options;
	for (var i = 0; i < oList.length; i++) {
		if (oList[i].text == username) {
			exists = true;
			alert("$usersel_txt{'memfound'}");
		}
	}
	if (!exists) {
		if (oList.length == 1 && oList[0].value == '0' ) {
			oList[0].value = userid;
			oList[0].text = username;
		} else {
			var newOption = oDoc.createElement("option");
			oDoc.getElementById(oElement).appendChild(newOption);
			newOption.text = username;
			newOption.value = userid;
		}
	}
}
//-->
</script>
	~;

	if ($action =~ /^im/ && (!@dimmessages && $INFO{'focus'} ne 'bmess') && ($PM_level == 1 || ($PM_level == 2 && $staff) || ($PM_level == 3 && ($iamadmin || $iamgmod)))) {
		if (!@dimmessages) {
			if    ($action eq 'im')        { &delete_DBorFILE("$memberdir/$username.msg"); }
			elsif ($action eq 'imoutbox')  { &delete_DBorFILE("$memberdir/$username.outbox"); }
			elsif ($action eq 'imstorage') { &delete_DBorFILE("$memberdir/$username.imstore"); }
			elsif ($action eq 'imdraft')   { &delete_DBorFILE("$memberdir/$username.imdraft"); }
		}
	}

	&LoadCensorList;

	# Fix moderator showing in info
	$sender = 'im';
	$acount = 0;
	## set browser title
	$yytitle = $mycenter_txt{'welcometxt'};

	## start new container - left side is menu, right side is content
	my ($display_prof, $display_posts, $display_pm, $tabPMHighlighted, $tabProfHighlighted, $tabNotifyHighlighted);

	if ($mycenter_template =~ /({|<)yabb mcmenu(}|>)/g) {
		&mcMenu;
		$newtemplate = 1;
	}

	if ($view eq 'profile' || ($view eq 'mycenter' && ($PM_level == 0 || ($PM_level == 2 && !$staff) || ($PM_level == 3 && !$iamadmin && !$iamgmod)))) {
		$display_prof = 'inline';
		$tabProfHighlighted = 'windowbg2';
	} else {
		$display_prof = 'none';
		$tabProfHighlighted = 'windowbg';
	}

	if ($view eq 'notify' || $view eq 'favorites' || $view eq 'recentposts') {
		$display_posts = 'inline';
		$tabNotifyHighlighted = 'windowbg2';
	} else {
		$display_posts = 'none';
		$tabNotifyHighlighted = 'windowbg';
	}

	if ($view eq 'pm' || ($view eq 'mycenter' && ($PM_level == 1 || ($PM_level == 2 && $staff) || ($PM_level == 3 && ($iamadmin || $iamgmod))))) {
		$display_pm = 'inline';

		$tabPMHighlighted = 'windowbg2';
	} else {
		$display_pm = 'none';
		$tabPMHighlighted = 'windowbg';
	}

	my $tabWidth = '33%';
	if ($PM_level == 0 || ($PM_level == 2 && !$staff) || ($PM_level == 3 && !$iamadmin && !$iamgmod)) { $tabWidth = '50%'; }
	$MCViewMenu = '';
	$MCPmMenu = '';
	$MCProfMenu = '';
	$MCPostsMenu = '';
	$MCExtraSmilies = '';
	$MCContent = '';

	if ($newtemplate) {
		$MCViewMenu .= qq~
		<script language="JavaScript1.2" type="text/javascript">
		<!--
		function changeToTab(tab) {~;
		if ($PM_level == 1 || ($PM_level == 2 && $staff) || ($PM_level == 3 && ($iamadmin || $iamgmod))) {
			$MCViewMenu .= qq~
			document.getElementById('cont_pm').style.display = 'none';
			document.getElementById('menu_pm').className = '';~;
		}
		$MCViewMenu .= qq~
			document.getElementById('cont_prof').style.display = 'none';
			document.getElementById('menu_prof').className = '';
			document.getElementById('cont_posts').style.display = 'none';
			document.getElementById('menu_posts').className = '';
			document.getElementById('cont_' + tab).style.display = 'inline';
			document.getElementById('menu_' + tab).className = 'selected';
		}
		//-->
		</script>~;
	} else {
		$MCViewMenu .= qq~
		<script language="JavaScript1.2" type="text/javascript">
		<!--
		function changeToTab(tab) {~;
		if ($PM_level == 1 || ($PM_level == 2 && $staff) || ($PM_level == 3 && ($iamadmin || $iamgmod))) {
			$MCViewMenu .= qq~
			document.getElementById('cont_pm').style.display = 'none';
			document.getElementById('menu_pm').className = 'windowbg';~;
		}
		$MCViewMenu .= qq~
			document.getElementById('cont_prof').style.display = 'none';
			document.getElementById('menu_prof').className = 'windowbg';
			document.getElementById('cont_posts').style.display = 'none';
			document.getElementById('menu_posts').className = 'windowbg';
			document.getElementById('cont_' + tab).style.display = 'inline';
			document.getElementById('menu_' + tab).className = 'windowbg2';
		}
		//-->
		</script>\n~;
		$MCViewMenu .= qq~
		<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" >
		<tr>~;
		if ($PM_level == 0 || ($PM_level == 2 && !$staff) || ($PM_level == 3 && !$iamadmin && !$iamgmod)) {
			$display_prof = 'inline';
			$tabProfHighlighted = 'windowbg2';
		}
		if ($PM_level == 1 || ($PM_level == 2 && $staff) || ($PM_level == 3 && ($iamadmin || $iamgmod))   ) {
			$MCViewMenu .= qq~
			<td width="$tabWidth" style="padding:4px" align="center" valign="middle" class="$tabPMHighlighted" id="menu_pm"><a href="javascript:void(0);" onclick="changeToTab('pm'); return false;">$mc_menus{'messages'}</a></td>~;
		}
		$MCViewMenu .= qq~
			<td width="$tabWidth" style="padding:4px" align="center" valign="middle" class="$tabProfHighlighted" id="menu_prof"><a href="javascript:void(0);" onclick="changeToTab('prof'); return false;">$mc_menus{'profile'}</a></td>
			<td width="$tabWidth" style="padding:4px" align="center" valign="middle" class="$tabNotifyHighlighted" id="menu_posts"><a href="javascript:void(0);" onclick="changeToTab('posts'); return false;">$mc_menus{'posts'}</a></td>
		</tr>
		</table>\n~;
	}

## start Profile div
	$MCProfMenu = qq~
	<div id="cont_prof" style="display: $display_prof">
	<table id="prof"  width="100%" align="center" class="windowbg2" cellpadding="4">
		<tr>
			<td style="text-align: left;">~;

	## links for profile pages. SID is now cloaked and controls whether or not
	## the action goes to authenticate or straight to the page.
	## The trick is to use $page to pass the intended page through and switch over on
	## positive id.
	if ($page && $page ne $action)  { $action = $page; }
	my $profileLink;
	my $sid = $INFO{'sid'};
	my $thisLink = '';
	my $sidLink = '';
	if (!$sid) {$sid = $FORM{'sid'}; }
	if ($sid) { $sidLink = ";sid=$sid"; }

	if (!$sid) { $profileLink = 'action=profileCheck;page='; }
	else {$profileLink = 'action=';}
	$thisLink = 'action=myviewprofile;username=' . $useraccount{$username};
	$MCProfMenu .= qq~
	<span class="nav"><b><a href="$scripturl?$thisLink">$inmes_txt{'viewprofile'}</a></b></span><br /><br />~;

	$thisLink = $profileLink . 'myprofile;username=' . $useraccount{$username} . $sidLink;
	$MCProfMenu .= qq~
	<span class="nav"><b><a href="$scripturl?$thisLink">$profile_txt{'79'}</a></b></span><br />~;

	$thisLink = $profileLink . 'myprofileContacts;username=' . $useraccount{$username} . $sidLink;
	$MCProfMenu .= qq~
	<span class="nav"><b><a href="$scripturl?$thisLink">$profile_txt{'819'}</a></b></span><br />~;

	$thisLink = $profileLink . 'myprofileOptions;username=' . $useraccount{$username} . $sidLink;
	$MCProfMenu .= qq~
	<span class="nav"><b><a href="$scripturl?$thisLink">$profile_txt{'818'}</a></b></span><br />~;

	if ($buddyListEnabled) {
		$thisLink = $profileLink . 'myprofileBuddy;username=' . $useraccount{$username} . $sidLink;
		$MCProfMenu .= qq~
		<span class="nav"><b><a href="$scripturl?$thisLink">$profile_buddy_list{'buddylist'}</a></b></span><br />~;
	}

	if ($PM_level == 1 || ($PM_level == 2 && $staff) || ($PM_level == 3 && ($iamadmin || $iamgmod))) {
		$thisLink = $profileLink . 'myprofileIM;username=' . $useraccount{$username} . $sidLink;
		$MCProfMenu .= qq~
		<span class="nav"><b><a href="$scripturl?$thisLink">$inmes_txt{'765'}</a></b></span>
		<br />
		~;
	}

	if ($iamadmin || ($iamgmod && $allow_gmod_profile && $gmod_access2{'profileAdmin'} eq 'on')) {
		$thisLink = $profileLink . 'myprofileAdmin;username=' . $useraccount{$username} . $sidLink;
		$MCProfMenu .= qq~
			<span class="nav"><b><a href="$scripturl?$thisLink">$profile_txt{'820'}</a></b></span>
			<br />
		~;
	}

	$MCProfMenu .= qq~
		</td></tr>
	</table>
	</div>
	~;
## end Profile div

## start Posts div
	$MCPostsMenu = qq~
	<div id="cont_posts" style="display: $display_posts">
	<table id="posts" width="100%" align="center" class="windowbg2" cellpadding="4">
		<tr><td class="windowbg2">
			<span class="nav"><b><a href="$scripturl?action=shownotify">$inmes_txt{'viewnotify'}</a></b></span><br />
			<span class="nav"><b><a href="$scripturl?action=favorites">$inmes_txt{'viewfavs'}</a></b></span><br />
	~;
	if (${$uid.$username}{'postcount'} > 0 && $maxrecentdisplay > 0) {
		$MCPostsMenu .= qq~
		<br /><br />
		<form action="$scripturl?action=myusersrecentposts;username=$useraccount{$username}" method="post" style="display: inline;">
		<span class="small">$inmes_txt{'viewrecentposts'} <select name="viewscount" size="1">~;

		my ($x,$y) = (int($maxrecentdisplay/5),0);
		if ($x) {
			for (my $i = 1; $i <= 5; $i++) {
				$y = $i * $x;
				$MCPostsMenu .= qq~
			<option value="$y">$y</option>~;
			}
		}
		$MCPostsMenu .= qq~
		<option value="$maxrecentdisplay">$maxrecentdisplay</option>~ if $maxrecentdisplay > $y;

		$MCPostsMenu .= qq~
		</select> $inmes_txt{'viewrecentposts2'}
		<input type="submit" value="$inmes_txt{'goviewrecent'}" class="button" /></span>
		</form>
	~;
	}
	$MCPostsMenu .= qq~
		</td></tr>
	</table>
	</div>
	~;
## end Posts div

	if (!$replyguest) {
		if ($view eq 'pm' && $action ne 'imsend' && $action ne 'imsend2') {
			my $imstoreFolder;
			if ($action eq 'imstorage') { $imstoreFolder = ";viewfolder=$INFO{'viewfolder'}"; }
			$MCGlobalFormStart .= qq~
			<form action="$scripturl?action=deletemultimessages;caller=$callerid$imstoreFolder" method="post" name="searchform" enctype="application/x-www-form-urlencoded">
			~;

		} elsif ($view eq 'pm') {
			$MCGlobalFormStart .= qq~<form action="$scripturl?action=$destination" method="post" name="postmodify" id="postmodify" enctype="application/x-www-form-urlencoded" onsubmit="~;
			if (!${$uid.$toshow}{'realname'}) { $MCGlobalFormStart .= qq~selectNames(); ~; }
			$MCGlobalFormStart .= qq~if(!checkForm(this)) { return false; } else { return submitproc(); }">~;

			## add smilies box
			## smilies
			$MCPmMenu .= qq~
		<script language="JavaScript1.2" src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
		<script language="JavaScript1.2" type="text/javascript">
		<!--~;

			if ($smiliestyle == 1) { $smiliewinlink = qq~$scripturl?action=smilieput~; }
			else { $smiliewinlink = qq~$scripturl?action=smilieindex~; }
			
			$MCPmMenu .= qq~
		function smiliewin() {
			window.open("$smiliewinlink", 'list', 'width=$winwidth, height=$winheight, scrollbars=yes');
		}
		//-->
		</script>\n~;

			if ($showadded == 2 || $showsmdir == 2) {
				$MCExtraSmilies .= qq~
				<br />
				<script language="JavaScript1.2" type="text/javascript">
				<!--
				function Smiliextra() {
					AddTxt=smiliecode[document.getElementById('smiliextra_list').value];
					AddText(AddTxt);
				}
				~;
				$smilieslist = '';
				$smilie_url_array = '';
				$smilie_code_array = '';
				$i = 0;
				if ($showadded == 2) {
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
				if ($showsmdir == 2) {
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

				$MCExtraSmilies .= qq~
				smilieurl = new Array($smilie_url_array);
				smiliecode = new Array($smilie_code_array);
				document.write('<table class="bordercolor" height="90" width="120" border="0" cellpadding="2" cellspacing="1" align="center"><tr>');
				document.write('<td height="15" align="center" valign="middle" class="titlebg"><span class="small"><b>$post_smiltxt{'1'}</b></span></td>');
				document.write('</tr><tr>');
				document.write('<td height="20" align="center" valign="top" class="windowbg2"><select name="smiliextra_list" id="smiliextra_list" onchange="document.images.smiliextra_image.src=smilieurl[document.getElementById(\\'smiliextra_list\\').value]" style="width:114px; font-size:7pt;">');
				$smilieslist
				document.write('</select></td>');
				document.write('</tr><tr>');
				document.write('<td height="70" align="center" valign="middle" class="windowbg2"><img name="smiliextra_image" src="'+smilieurl[0]+'" alt="" border="0" onclick="javascript: Smiliextra();" style="cursor: pointer;"></td>');
				document.write('</tr><tr>');
				document.write('<td height="15" align="center" valign="middle" class="windowbg2"><span class="small"><a href="javascript: smiliewin();">$post_smiltxt{'17'}</a></span></td>');
				document.write('</tr></table>');
				document.images.smiliextra_image.src = smilieurl[document.getElementById('smiliextra_list').value];
				//-->
				</script>
				<br />
				~;
			}
		}

	} else {
		$MCGlobalFormStart .= qq~<form action="$scripturl?action=$destination" method="post" name="postmodify" id="postmodify" enctype="application/x-www-form-urlencoded">~;
	}

	###################################################
	########  right side container starts here
	###################################################
	if ($view eq 'mycenter') {
		&LoadUserDisplay($username);

		my $onOffStatus = ${$uid.$username}{'offlinestatus'} eq "away" ? $mycenter_txt{'onoffstatusaway'} : $mycenter_txt{'onoffstatuson'};

		my $stealthstatus = '';
		if (($iamadmin || $iamgmod) && $enable_MCstatusStealth) {
			$stealthstatus = $mycenter_txt{'stealth_off'};
			if (${$uid.$username}{'stealth'}) { $stealthstatus = $mycenter_txt{'stealth_on'}; }
			$stealthstatus = qq~		<tr>
					<td class="windowbg2">$mycenter_txt{'stealth'}</td>
					<td class="windowbg2">'$stealthstatus'</td>
				</tr>~;
		}

		my $memberinfo = "$memberinfo{$username}$addmembergroup{$username}";
		my $userOnline = &userOnLineStatus($username) . "<br />";
		my $template_postinfo = qq~$mycenter_txt{'posts'}: ~ . &NumberFormat(${$uid.$username}{'postcount'}) . qq~<br />~;
		my $userlocation;
		if (${$uid.$username}{'location'}) {
			$userlocation = ${$uid.$username}{'location'} . "<br />";
		}

		$mctitle = $mycenter_txt{'welcometxt'};
		#################################
		$myprofileblock =~ s/({|<)yabb userlink(}|>)/$link{$username}/g;
		$myprofileblock =~ s/({|<)yabb memberinfo(}|>)/$memberinfo/g;
		$myprofileblock =~ s/({|<)yabb stars(}|>)/$memberstar{$username}/g;
		$myprofileblock =~ s/({|<)yabb useronline(}|>)/$userOnline/g;
		$myprofileblock =~ s/({|<)yabb userpic(}|>)/${$uid.$username}{'userpic'}/g;
		$myprofileblock =~ s/({|<)yabb usertext(}|>)/${$uid.$username}{'usertext'}/g;
		$myprofileblock =~ s/({|<)yabb postinfo(}|>)/$template_postinfo/g;
		$myprofileblock =~ s/({|<)yabb location(}|>)/$userlocation/g;
		$myprofileblock =~ s/({|<)yabb gender(}|>)/${$uid.$username}{'gender'}/g;
		################################
		$myprofileblock =~ s/({|<)yabb .+?(}|>)//g;

		if ($buddyListEnabled) {
			$buddiesCurrentStatus;
			if (${$uid.$username}{'buddylist'}) {
				&LoadBuddyList;
				$buddiesCurrentStatus = qq~$mycenter_txt{'buddylisttitle'}:<br />$buddiesCurrentStatus~;
			} else { 
				$buddiesCurrentStatus = $mycenter_txt{'buddylistnone'};
			}
		} else {
			$buddiesCurrentStatus = qq~&nbsp;~;
		}

		$MCContent .= qq~
		<table width="100%" border="0" cellspacing="1" cellpadding="5" align="right" class="bordercolor">
				<tr>
					<td width="33%" class="windowbg2" valign="top">
						$myprofileblock
					</td>
					<td width="67%" class="windowbg2" valign="top">
						$buddiesCurrentStatus
					</td>
				</tr>
				<tr>
					<td colspan="2" class="windowbg">
						$mycenter_txt{'currentsettings'}
					</td>
				</tr>
				<tr>
					<td class="windowbg2">
						$mycenter_txt{'onoffstatus'}<br />
					</td>
					<td class="windowbg2">

		'$onOffStatus'</td>
				</tr>
		$stealthstatus
		</table>
		~;

	############### sending pm #######################
	} elsif ($view eq 'pm' && ($action eq 'imsend' || $action eq 'imsend2')) {
		my $sendTitle = $inmes_txt{'sendmess'};
		if ($sendBMess) { $sendTitle = $inmes_txt{'sendbroadmess'}; }
		$MCContent .= qq~
		$MCGlobalFormStart
		<div class="bordercolor" style="padding:1px">
		<table width="100%" border="0" cellspacing="0" cellpadding="5">
			$imsend
		</table>
		</div>
		</form>~;
		$MCGlobalFormStart = '';
		
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
			parent.IFrameShrink();
			var height = document.body.scrollHeight;
			parent.ResizeIFrame(height);
		}
		
		function postQuery() { 
			var theForm = document.forms.postmodify; 
			var postText = ""; 
			var amp = ""; 
			for(i = 0; i < theForm.elements.length; i++){ 
				var elem = theForm.elements[i];
				if(elem.type == "text" || elem.type == "textarea" || elem.type == "hidden"){ 
					postText += amp + elem.name + "=" + encodeURIComponent(elem.value); 
				} else if (elem.type == "checkbox") {
					if (elem.checked) {
						postText += amp + elem.name + "=checked";
					}
				} else if (elem.type == "select-multiple") { 
					for (var j = 0; j < elem.options.length; j++) {
						postText += amp + elem.name + "=" + elem.options[j].value;
					}
				} else if (elem.type == "select-one") {
					postText += amp + elem.name + "=" + elem.options[elem.selectedIndex].value; 
				}
				amp = "&";
			}
			parent.sendIM(document.forms.postmodify.action, postText);
		}
		</script>
		$yyinlinestyle
		</head>
		<body onload="ResizeIFrame()" style="background-color:#2f7dce; height: 100%; width: 100%; min-width:650px">
		$MCContent
		</body>
		</html>~;
		
		$output =~ s~</form>~<input type="hidden" name="formsession" value="$formsession" /></form>~g;

		&print_HTML_output_and_finish;
		}
		
		

	# inbox/outbox/ storage/draft  viewing
	} elsif ($view eq 'pm' && ($action eq 'im' || $action eq 'imoutbox' || $action eq 'imstorage' || $action eq 'imdraft')) {
		&drawPMView;

	} elsif ($view eq 'pm' && $action eq 'imshow') {
		$showIM = '';
		if ($INFO{'id'} eq 'all') {
			my $BC;
			foreach (@dimmessages) {
				$showmessid = (split /\|/, $_)[0];
				$showIM .= &DoShowIM($showmessid);
				if ($INFO{'caller'} == 5 && !${$username}{'PMbcRead' . $showmessid}) {
					${$username}{'PMbcRead'} .= ${$username}{'PMbcRead'} ? ",$showmessid" : $showmessid;
					$BCnewMessage--; $BC = 1;
				}
			}
			if ($BC) { &buildIMS($username, 'update'); }
		} else { 
			$showIM = &DoShowIM($INFO{'id'});
			if ($INFO{'caller'} == 5 && !${$username}{'PMbcRead' . $INFO{'id'}}) {
				${$username}{'PMbcRead'} .= ${$username}{'PMbcRead'} ? ",$INFO{'id'}" : $INFO{'id'};
				&buildIMS($username, 'update');
				$BCnewMessage--;
			}
		}

		$MCContent .= $showIM;

	} elsif ($view eq 'pm' && $action eq 'pmsearch') {
		&spam_protection;
		$yysearchmain = '';
		require "$sourcedir/Search.pl";
		&pmsearch;
		$MCContent .= $yysearchmain;
		$mctitle = "$pm_search{'desc'}";

	} elsif ($view eq 'profile') {
		## if user has had to go via id check, this restores their intended page
		$page = $INFO{'page'};
		if($page && $action ne $page) { $action = $page; }
		require "$sourcedir/Profile.pl";
		if ($action eq 'myprofileIM') { &ModifyProfileIM; }
		elsif ($action eq 'myprofileIM2') { &ModifyProfileIM2; }
		elsif ($action eq 'myprofile') { &ModifyProfile; }
		elsif ($action eq 'myprofile2') { &ModifyProfile2; }
		elsif ($action eq 'myprofileContacts') { &ModifyProfileContacts; }
		elsif ($action eq 'myprofileContacts2') { &ModifyProfileContacts2; }
		elsif ($action eq 'myprofileOptions') { &ModifyProfileOptions; }
		elsif ($action eq 'myprofileOptions2') { &ModifyProfileOptions2; }
		elsif ($action eq 'myprofileBuddy') { &ModifyProfileBuddy; }
		elsif ($action eq 'myprofileBuddy2') { &ModifyProfileBuddy2; }
		elsif ($action eq 'myviewprofile') { &ViewProfile; }
		elsif ($action eq 'myprofileAdmin') { &ModifyProfileAdmin; }
		elsif ($action eq 'myprofileAdmin2') { &ModifyProfileAdmin2; }
		$MCContent .= $showProfile;

	} elsif ($view eq 'notify') {
		require "$sourcedir/Notify.pl";
		if ($action eq 'shownotify') { &ShowNotifications; }
		elsif ($action eq 'boardnotify2') { &BoardNotify2; &ShowNotifications; }
		elsif ($action eq 'notify4') { &Notify4; }
		$MCContent .= $showNotifications;

	} elsif ($view eq 'recentposts') {
		require "$sourcedir/Profile.pl";
		&usersrecentposts;
		$MCContent .= $showProfile;

	} elsif ($view eq 'favorites'){
		require "$sourcedir/Favorites.pl";
		&Favorites;
		$MCContent .= $showFavorites;
	}

	## start PM div
	if ($PM_level == 1 || ($PM_level == 2 && $staff) || ($PM_level == 3 && ($iamadmin || $iamgmod))) {
		$MCPmMenu .= qq~
	<div id="cont_pm" style="display: $display_pm">
		<table id="pms" width="100%" align="center" class="windowbg2" cellpadding="1">
		~;

		if (($PMenableBm_level == 1 && $staff) || ($PMenableBm_level == 2 && ($iamadmin || $iamgmod)) || ($PMenableBm_level == 3 && $iamadmin)) {
			$MCPmMenu .= qq~
			<tr>
				<td style="text-align: left;" colspan="3">
					<span class="nav"><b><a href="$scripturl?action=imsend;bmess=yes">$img{'sendbmess'}</a></b></span>
				</td>
			</tr>~;
		}

		my $inboxNewCount = qq~<span class="NewLinks">, <a href="$scripturl?action=imshow;caller=1;id=-1">${$username}{'PMimnewcount'} $inmes_txt{'new'}</a></span>~;
		if (${$username}{'PMimnewcount'} == 0) { $inboxNewCount = ''; }

		$MCPmMenu .= qq~
		 	<tr>
		 		<td style="text-align: left;" colspan="3"><span class="nav"><b><a href="$scripturl?action=imsend">$img{'im_send'}</a></b></span></td>
			</tr>
			<tr>
				<td width="15%" class="windowbg2"><img src="$imagesdir/im_inbox.gif" alt="$inmes_txt{'inbox'}" title="$inmes_txt{'inbox'}" border="0" /></td>
				<td width="60%" class="windowbg2"><span class="nav"><b><a href="$scripturl?action=im">$inmes_txt{'inbox'}</a></b></span></td>
				<td width="25%" class="windowbg2"><span class="nav">${$username}{'PMmnum'}$inboxNewCount</span></td>
			</tr>~;

		if ($PMenableBm_level > 0 || ($PMenableGuestButton == 1 && ($iamadmin || $iamgmod))) {
			$inboxNewCount = $BCnewMessage ? " <span class='NewLinks'>($inmes_txt{'new'})</span>" : "";
			$MCPmMenu .= qq~
			<tr>
				<td width="15%" class="windowbg2"><img src="$imagesdir/im_inbox.gif" alt="$inmes_txt{'broadcast'}" title="$inmes_txt{'broadcast'}" border="0" /></td>
				<td width="60%" class="windowbg2"><span class="nav"><b><a href="$scripturl?action=im;focus=bmess">$inmes_txt{'broadcast'}</a></b></span></td>
				<td width="25%" class="windowbg2"><span class="nav">$BCCount$inboxNewCount</span></td>
			</tr>~;
		}

		my @folderCount = split(/\|/, ${$username}{'PMfoldersCount'});
		$MCPmMenu .= qq~
			<tr>
				<td width="15%" class="windowbg2"><img src="$imagesdir/im_outbox.gif" alt="$inmes_txt{'draft'}" title="$inmes_txt{'draft'}" border="0" /></td>
				<td width="60%" class="windowbg2"><span class="nav"><b><a href="$scripturl?action=imdraft">$inmes_txt{'draft'}</a></b></span>	</td>
				<td width="25%" class="windowbg2"><span class="nav">${$username}{'PMdraftnum'}</span></td>
			</tr>
			<tr>
				<td width="15%" class="windowbg2"><img src="$imagesdir/im_outbox.gif" alt="$inmes_txt{'outbox'}" title="$inmes_txt{'outbox'}" border="0" /></td>
				<td width="60%" class="windowbg2"><span class="nav"><b><a href="$scripturl?action=imoutbox">$inmes_txt{'outbox'}</a></b></span>	</td>
				<td width="25%" class="windowbg2"><span class="nav">${$username}{'PMmoutnum'}</span></td>
			</tr>
			<tr>
				<td colspan="3"><hr width="100%" class="hr" /></td>
			</tr>
			<tr>
				<td width="15%" class="windowbg2"><img src="$imagesdir/imstore.gif" alt="$inmes_txt{'storage'}" title="$inmes_txt{'storage'}" border="0" /></td>
				<td width="60%" class="windowbg2"><span class="small">$inmes_txt{'storage'}</span></td>
				<td width="25%" class="windowbg2"><span class="nav">${$username}{'PMstorenum'}</span></td>
			</tr>
			<tr>
				<td width="15%" class="windowbg2">&nbsp;</td>
				<td width="60%" class="windowbg2"><span class="nav">&nbsp; &nbsp;<b><a href="$scripturl?action=imstorage;viewfolder=in">$im_folders_txt{'in'}</a></b></span></td>
				<td width="25%" class="windowbg2"><span class="nav">~; $MCPmMenu .= $folderCount[0] || 0; $MCPmMenu .= qq~</span></td>
			</tr>
			<tr>
				<td width="15%" class="windowbg2">&nbsp;</td>
				<td width="60%" class="windowbg2"><span class="nav">&nbsp; &nbsp;<b><a href="$scripturl?action=imstorage;viewfolder=out">$im_folders_txt{'out'}</a></b> </span></td>
				<td width="25%" class="windowbg2"><span class="nav">~; $MCPmMenu .= $folderCount[1] || 0; $MCPmMenu .= qq~</span></td>
			</tr>
		~;

		## if there are some folders to show under storage
		## split the list down and show it with link to each folder
		if ($enable_storefolders > 0) {
			my $storeFoldersTotal = 0;
			my $DelAdFolder = 0;
			if (${$username}{'PMfolders'}) {
				my $x = 2;
				foreach my $storefolder (split(/\|/, ${$username}{'PMfolders'})) {
					if ($storefolder ne 'in' && $storefolder ne 'out') {
						$storeFoldersTotal++;
						$MCPmMenuTemp .= qq~
						<tr>
							<td width="15%" class="windowbg2">~;
						if ($storeFoldersTotal > 0 && $folderCount[$x] == 0) {
							$DelAdFolder = 1;
							$MCPmMenuTemp .= qq~
								<input type="checkbox" name="delfolder$x" id="delfolder$x" value="del" />~;
						} else {
							$MCPmMenuTemp .= qq~&nbsp;~;
						}

						$MCPmMenuTemp .= qq~
							</td>
							<td width="60%" class="windowbg2"><span class="nav">&nbsp; &nbsp;<b><a href="$scripturl?action=imstorage;viewfolder=$storefolder">$storefolder</a></b></span></td>
							<td width="25%" class="windowbg2"><span class="nav">~;
						$MCPmMenuTemp .= $folderCount[$x] || 0;
						$MCPmMenuTemp .= qq~</span></td>
						</tr>~;
					$x++;
					}
				}

				if ($DelAdFolder) {
					$MCPmMenuTemp .= qq~
						<tr>
							<td class="windowbg2" colspan="3">
							<input type="submit" name="deladdfolder" id="deladdfolder" value="$inmes_txt{'delete'}" class="button" />
							<input type="hidden" name="delfolders" id="delfolders" value="yes" />
							</td>
						</tr>
					~;
				}
			}

			if ($storeFoldersTotal) {
				$MCPmMenu .= qq~
					<tr>
						<td class="windowbg2" colspan="3">
						<form action="$scripturl?action=delpmfolder" method="post" name="delpmfolder" id="delpmfolder" enctype="application/x-www-form-urlencoded" style="display:inline;"  onsubmit="return submitproc()">
						<table width="100%" border="0" cellspacing="0" cellpadding="2">
						$MCPmMenuTemp
						</table>
						</form>
						</td>
					</tr>
				~;
			}

			$MCPmMenu .= qq~
			<tr>
				<td colspan="3"><hr width="100%" class="hr" /></td>
			</tr>
			<tr>
				<td colspan="3"><span class="nav"><b><a href="javascript:MarkAllAsRead('$scripturl?action=markims','$imagesdir')">$inmes_txt{'764'}</a></b></span></td>
			</tr>~;
			$yyjavascript .= qq~\nvar markallreadlang = '$inmes_txt{'500'}';\nvar markfinishedlang = '$inmes_txt{'500a'}';~;

			## this allows user to add a new folder on the fly
			if ($storeFoldersTotal < $enable_storefolders ) {
				$MCPmMenu .= qq~
			<tr>
				<td colspan="3">
				<hr width="100%" class="hr" />
					<form action="$scripturl?action=newpmfolder" method="post" name="newpmfolder" id="newpmfolder" enctype="application/x-www-form-urlencoded" style="display:inline;"  onsubmit="return submitproc()">
					<label for="newfolder">$inmes_imtxt{'newstorefolder'}</label><br />
					<input type="text" name="newfolder" id="newfolder" size="15" value="$mc_folders{'foldername'}" onfocus="txtInFields(this, '$mc_folders{'foldername'}');" onblur="txtInFields(this, '$mc_folders{'foldername'}')" />
					<input type="submit" name="addimfolder" id="addimfolder" value="$inmes_txt{'addfolder'}" class="button" /> 
					</form>
				</td>
			</tr>~;
			}
		}

		unless ($enable_PMsearch == 0) {
			$MCPmMenu .= qq~
			<tr>
				<td colspan="3">
				<hr width="100%" class="hr" />
				<script language="JavaScript1.2" src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
				<label for="search">$pm_search{'desc'}</label><br />
				<form action="$scripturl?action=pmsearch" method="post" onsubmit="return submitproc()" style="display: inline">~;

			if ($view eq 'pm' && $action ne 'pmsearch') {
				$MCPmMenu .= qq~
				- <input type="radio" name="pmbox" id="pmboxall" value="" checked="checked" /> <label for="pmboxall">$pm_search{'all'}</label>
				<input type="radio" name="pmbox" id="pmboxthis" value="$callerid" /> <label for="pmboxthis">$pm_search{'justthis'}</label><br />~;
			}

			$MCPmMenu .= qq~
				- <input type="checkbox" name="searchtype" id="searchtype" value="user" /> <label for="searchtype">$pm_search{'byuser'}</label><br />
				<input type="text" name="search" id="search" size="16" style="font-size: 11px; vertical-align: middle;" />

				<input type="image" src="$imagesdir/search.png" style="border: 0; background-color: transparent; margin-right: 5px; vertical-align: middle;" />
				</form>
				</td>
			</tr>
			~;
		}

		$MCPmMenu .= qq~
		</table>
	</div>
		~;

	}
	## end PM div
}

sub drawPMView {
	## column headers
	## note - if broadcast messages not enabled but guest pm is, admin/gmod still
	##  see the broadcast split
	if (($enable_PMcontrols && ${$uid.$username}{'pmviewMess'}) || (!$enable_PMcontrols && !$enable_PMviewMess) ) {
		if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
	}
	if ($INFO{'sort'} ne 'gpdate' && $INFO{'sort'} ne 'thread') { &pageLinksList; }
	my $dateColhead = "$inmes_txt{'317'}";
	if ($action eq 'imdraft') { $dateColhead = $inmes_txt{'datesave'}; }

	$mctitle = $IM_box;
	$MCContent .= qq~
	<table border="0" width="100%" cellspacing="1" cellpadding="3" class="bordercolor">
	~;

	if (($#dimmessages >= $maxmessagedisplay || $INFO{'start'} =~ /all/) && $action ne 'imstorage') {
		$MCContent .= qq~
		<tr><td colspan="3" class="titlebg">$pageindex1$pageindexjs</td></tr>
		~;
	}

	if ($INFO{'viewfolder'} ne '') { $vfolder = qq~;viewfolder=$INFO{'viewfolder'}~; }
	if ($INFO{'focus'} eq 'bmess') { $vbmess = qq~;focus=bmess~; }
	if ($INFO{'sort'} ne 'gpdate') { $sbgpdate = qq~;sort=gpdate~; }

	unless ($action eq 'imstorage' && $INFO{'viewfolder'} eq '') {
		$MCContent .= qq~
	  <tr>
	    <td class="titlebg"  width="65%"><b>$inmes_txt{'70'}</b></td>
	    <td class="titlebg"  width="15%"><b>$senderinfo</b></td>
	    <td class="titlebg"  width="20%"><b><a href="$scripturl?action=$action$sbgpdate$vfolder$vbmess">$dateColhead</a></b></td>
	  </tr>
		~;
	}

	## if no messages found in file, say so
	my $storeContentFound = 0;
	if ($INFO{'viewfolder'} && @dimmessages) {
		foreach my $checkPost (@dimmessages) {
			my $thisStorefolder= (split /\|/, $checkPost)[13];
			if ($thisStorefolder eq $INFO{'viewfolder'}) { $storeContentFound = 1; last; }
		}
	}

	if (!@dimmessages || ($storeContentFound == 0 && $INFO{'viewfolder'})) {
		## drop in the 'no messages' text
		$MCContent .= qq~
	  <tr>
	    <td class="windowbg" colspan="3" height="21">$inmes_txt{'151'}</td>
	  </tr>
	</table>
	<br clear="all" /><br />
	~;
	} else {
		## set colours for display
		$acount++;
		my $sortBy = $INFO{'sort'};
		my $maxcounter;
		$start = $start || 0;
		## if on last page, adjust the maxcounter down
		if ((($#dimmessages + 1) - $start) < $maxmessagedisplay || $sortBy eq 'gpdate' || $action eq 'imstorage') {
		    $maxcounter = @dimmessages;
		} else {
		    $maxcounter = ($start + $maxmessagedisplay);
		}
		my $viewBMess;
		my $groupByDate = 0;
		my $dateSpan = 0;
		my $latestPM = 0;
		if ($INFO{'focus'} eq 'bmess') { $viewBMess = 1; }
		if ($sortBy eq 'gpdate') {
			my $topMDate = (split /\|/, $dimmessages[0])[6];
			my $oldestDate = (split /\|/, $dimmessages[$#dimmessages])[6];
			$groupByDate = 1;
			## work out the span of days - today less oldest message, in days
			$dateSpan = int(($date - $oldestDate) / 86400); # in days
			$latestPM = (($date - $topMDate) / 3600); # in hours
		}
		## if sort is grouped, extra block is added per group
		## pull date of newest pm

		my $latestDateSet = 0;
		my $lastWeekSet = 0;
		my $twoWeeksSet = 0;
		my $threeWeeksSet = 0;
		my $monthSet = 0;
		my $gtMonthSet = 0;
		my $uselegend = "";

		# work out the newest pm date soa s to put the right first block in
		if ($dateSpan > 31) { $gtMonthSet = 1; $uselegend = 'older'; }
		if ($dateSpan > 21 && ($latestPM / 24) < 32 ) { $monthSet = 1; $uselegend = 'fourweeks';}
		if ($dateSpan > 14 && ($latestPM / 24) < 22 ) { $threeWeeksSet = 1; $uselegend = 'threeweeks';}
		if ($dateSpan > 7  && ($latestPM / 24) < 15 ) { $twoWeeksSet = 1; $uselegend = 'twoweeks';}
		if ($dateSpan > 1 && ($latestPM / 24) < 8 ) { $lastWeekSet = 1; $uselegend = 'oneweek';}
		if ($latestPM < 24) { $latestDateSet = 1; $uselegend = 'latest'; }

		if ($sortBy eq 'gpdate') {
			$MCContent .= qq~
	  <tr>
	    <td class="titlebg"  width="100%" colspan="3"><span class="imgtitlebg">$im_sorted{$uselegend}</span></td>
	  </tr>
			~;

			$counterCheck = $start; 
		}
		if ($viewBMess) { $stkDateSet = 1; }

		for ($counter = $start; $counter < $maxcounter; $counter++) {
##########  top of messages list ##########
# $messageid, $musername, $musernameto, $musernamecc, $musernamebcc
			$class_PM_list = $class_PM_list eq 'windowbg2' ? 'windowbg' : 'windowbg2';
			chomp $dimmessages[$counter];
			my ($messageid, $musername, $musernameto, $musernamecc, $musernamebcc, $msub, $mdate, $immessage, $mpmessageid, $mreplyno, $mips, $messageStatus, $messageFlags, $storeFolder, $messageAttachment) = split(/\|/, $dimmessages[$counter]);
			## if we are viewing  one of the storage folders, filter out the
			##  PMs that don't match
			if ($action eq 'imstorage' && $INFO{'viewfolder'} ne $storeFolder) {
				$class_PM_list = $class_PM_list eq 'windowbg2' ? 'windowbg' : 'windowbg2';
				next;
			}
			## set the status icon
			my $messIconName = 'standard';
			if ($messageStatus =~ /c/) { $messIconName = 'confidential'; }
			elsif ($messageStatus =~ /u/) { $messIconName = 'urgent'; }
			elsif ($messageStatus =~ /a/) { $messIconName = 'alertmod'; }
			elsif ($messageStatus =~ /gr/) { $messIconName = 'guestpmreply'; }
			elsif ($messageStatus =~ /g/) { $messIconName = 'guestpm'; }
			my $messIcon = qq~<img src="$imagesdir/$messIconName.gif" name="icons" border="0" hspace="15" alt="$im_message_status{$messIconName}" title="$im_message_status{$messIconName}" style="vertical-align: middle;" />~;

			my ($hasMultiRecs,$multiRecs);
			if ($musernameto =~ /,/ || $musernamecc || $musernamebcc ) { $hasMultiRecs = 1; }

			## if store, set the from/to

			# check for multiple recs (outbox/store/draft only)
			## and build the to/rec string for individual callback
			my %usersRec;

			my $usernameto = '';
			if ($action eq 'imoutbox' || $action eq 'imstorage' || $action eq 'imdraft') {
				if ($hasMultiRecs) {
					my $switchComma = 0;
					$usernameto = '';
					if ($messageStatus !~ /b/) {
						## check each to see if they read the message
						foreach my $muser (split(/\,/, $musernameto)) {
							$userToMessRead = &checkIMS($muser, $messageid, 'messageopened');
							%usersRec = {%usersRec , $muser => $userToMessRead};
							if (!$yyUDLoaded{$muser}) { &LoadUser($muser); }
							if ($usernameto && $switchComma == 0) { $usernameto .= qq~ ...~; $switchComma = 1; }
							elsif (!$usernameto) {
								$usernameto = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$muser}" rel="nofollow">${$uid.$muser}{'realname'}</a>~;
							}
						}
						if ($musernamecc) {
						## check each to see if they read the message
							foreach my $muser (split(/\,/, $musernamecc)) {
								$userToMessRead = &checkIMS($muser, $messageid, 'messageopened');
								%usersRec = {%usersRec , $muser => $userToMessRead};
								if (!$yyUDLoaded{$muser}) { &LoadUser($muser); }
								if ($usernameto && $switchComma == 0) { $usernameto .= qq~ ...~; $switchComma = 1; }
							}
						}
						if ($musernamebcc) {
							## check each to see if they read the message
							foreach my $muser (split(/\,/, $musernamebcc)) {
								$userToMessRead = &checkIMS($muser, $messageid, 'messageopened');
								%usersRec = {%usersRec , $muser => $userToMessRead};
								if (!$yyUDLoaded{$muser}) { &LoadUser($muser); }
								if($usernameto && $switchComma == 0) {$usernameto .= qq~ ...~; $switchComma = 1; }
							}
						}
					} else {
						foreach my $muser (split(/\,/, $musernameto)) {
							if ($muser eq 'all') { $usernameto = $inmes_txt{'bmallmembers'}; }
							elsif ($muser eq 'mods') { $usernameto = $inmes_txt{'bmmods'}; }
							elsif ($muser eq 'gmods') { $usernameto = $inmes_txt{'bmgmods'}; }
							elsif ($muser eq 'admins') { $usernameto = $inmes_txt{'bmadmins'}; }
							else {
								my $title = (split /\|/, $NoPost{$muser})[0];
								$usernameto = $title;
							}
							if ($usernameto && $switchComma == 0) { $usernameto .= qq~ ...~; $switchComma = 1; last; }
						}
					}
				} else {
					if ($messageStatus !~ /b/) {
						$userToMessRead = &checkIMS($musernameto, $messageid, 'messageopened');
						if (!$yyUDLoaded{$musernameto}) { &LoadUser($musernameto); }
						$usernameto = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musernameto}" rel="nofollow">${$uid.$musernameto}{'realname'}</a>~;
					} else {
						if ($musernameto eq 'all') { $usernameto = $inmes_txt{'bmallmembers'}; }
						elsif ($musernameto eq 'mods') { $usernameto = $inmes_txt{'bmmods'}; }
						elsif ($musernameto eq 'gmods') { $usernameto = $inmes_txt{'bmgmods'}; }
						elsif ($musernameto eq 'admins') { $usernameto = $inmes_txt{'bmadmins'}; }
						else {
							my $title = (split /\|/, $NoPost{$musernameto})[0];
							$usernameto = $title;
						}
					}
				}
			}
			## done multi
			## kill if not needed
			if (!$hasMultiRecs) { undef %usersRec; }

			## time to output name
			# for multi recs, have to split it down and test per user
			## happens for any message sent with cc or bcc
			my $checkz = 0;
			my $allChecked = 0;

			$msub = &Censor($msub);
			&ToChars($msub);

			$mydate = &timeformat($mdate);
			## start of message row 1
			## for inbox or store, check from
			my ($fromToName, $messageIcon, $callBack, $messageAction);
			if ($action ne 'imstorage' && $action ne 'imdraft' && !$viewBMess) {
				## detect multi-rec
				my ($imnew, $imRepliedTo, $imOpened);
				## outbox - has the recp opened the message? (allow for multi)
				if ($action eq 'imoutbox' && !$hasMultiRecs ) {
					$imOpened = &checkIMS($musernameto, $messageid, 'messageopened');
				} elsif ($action eq 'im') { ## inbox - has user opened ?
					$imOpened = &checkIMS($username, $messageid, 'messageopened');
				}
				if ($action eq 'im') { $imRepliedTo = &checkIMS($username, $messageid, 'messagereplied'); }

				## viewing inbox
				if ($action eq 'im') {
					## not opened
					if (!$imOpened && !$hasMultiRecs) {
						$messageIcon = qq~<img src="$imagesdir/imclose.gif" border="0" alt="$inmes_imtxt{'innotread'}" title="$inmes_imtxt{'innotread'}" style="vertical-align: middle;" />~;
					}
					## replied to
					elsif ($imRepliedTo && !$hasMultiRecs) {
						$messageIcon = qq~<img src="$imagesdir/answered.gif" border="0" alt="$inmes_imtxt{'08'}" title="$inmes_imtxt{'08'}" style="vertical-align: middle;" />~;
					}
					## opened
					elsif ($imOpened && !$hasMultiRecs) {
						$messageIcon = qq~<img src="$imagesdir/imopen.gif" border="0" alt="$inmes_imtxt{'inread'}" title="$inmes_imtxt{'inread'}" style="vertical-align: middle;" />~;
					}
					## not opened multi
					elsif (!$imOpened && $hasMultiRecs) {
						$messageIcon = qq~<img src="$imagesdir/imclose2.gif" border="0" alt="$inmes_imtxt{'inread'}" title="$inmes_imtxt{'inread'}" style="vertical-align: middle;" />~;
					}
					## opened multi
					elsif ($imOpened && $hasMultiRecs) {
						$messageIcon = qq~<img src="$imagesdir/imopen2.gif" border="0" alt="$inmes_imtxt{'inread'}" title="$inmes_imtxt{'inread'}" style="vertical-align: middle;" />~;
					}
				}

				##  outbox
				elsif ($action eq 'imoutbox') {
					## not opened
					if (!$imOpened && !$hasMultiRecs) {
						&LoadUser($musernameto);
						if (${$uid.$musernameto}{'notify_me'} < 2 || $enable_notifications < 2) {
							$messageIcon = qq~<img src="$imagesdir/imclose.gif" border="0" alt="$inmes_imtxt{'outnotread'}" title="$inmes_imtxt{'outnotread'}" style="vertical-align: middle;" />~;
							$callBack = qq~<span class="small"><a href="$scripturl?action=imcb;rid=$messageid;receiver=$useraccount{$musernameto}" onclick="return confirm('$inmes_imtxt{'73'}')">$inmes_imtxt{'83'}</a> | </span>~;
						} else {
							$messageIcon = qq~<img src="$imagesdir/imclose.gif" border="0" alt="$inmes_imtxt{'outnotread'}" title="$inmes_imtxt{'outnotread'}" style="vertical-align: middle;" />~;
						}
					}
					## opened
					elsif ($imOpened && !$hasMultiRecs) {
						$messageIcon = $messageFlags =~ /c/i ? qq~<img src="$imagesdir/imcallback.gif" border="0" alt="$inmes_imtxt{'callback'}" title="$inmes_imtxt{'callback'}" style="vertical-align: middle;" />~ : qq~<img src="$imagesdir/imopen.gif" border="0" alt="$inmes_imtxt{'outread'}" title="$inmes_imtxt{'outread'}" style="vertical-align: middle;" />~;
					}

					## for multi rec, and none opened
					if ($hasMultiRecs) {
						my ($countrecepients,$countread,@receivers);
						my $tousers = $musernameto;
						$tousers .= ",$musernamecc" if $musernamecc;
						$tousers .= ",$musernamebcc" if $musernamebcc;
						foreach my $recname (split(/,/, $tousers)) {
							$countrecepients++;
							&LoadUser($recname);
							if (&checkIMS($recname, $messageid, 'messageopened') || (${$uid.$recname}{'notify_me'} > 1 && $enable_notifications > 1)) { $countread++; } else { push(@receivers, $useraccount{$recname}); }
						}
						if (!$countread) {
							$messageIcon = qq~<img src="$imagesdir/imclose2.gif" border="0" alt="$inmes_imtxt{'outmultinotread'}" title="$inmes_imtxt{'outmultinotread'}" style="vertical-align: middle;" />~;
							$callBack = qq~<span class="small"><a href="$scripturl?action=imcb;rid=$messageid;receiver=~ . join(',', @receivers) . qq~" onclick="return confirm('$inmes_imtxt{'73'}')">$inmes_imtxt{'83'}</a> | </span>~;
						} elsif ($countrecepients == $countread) {
							$messageIcon = $messageFlags =~ /c/i ? qq~<img src="$imagesdir/imcallback2.gif" border="0" alt="$inmes_imtxt{'outmulticallback'}" title="$inmes_imtxt{'outmulticallback'}" style="vertical-align: middle;" />~ : qq~<img src="$imagesdir/imopen2.gif" border="0" alt="$inmes_imtxt{'outmultiread'}" title="$inmes_imtxt{'outmultiread'}" style="vertical-align: middle;" />~;
						} else {
							$messageIcon = $messageFlags =~ /c/i ? qq~<img src="$imagesdir/imcallback3.gif" border="0" alt="$inmes_imtxt{'outsomemulticallback'}" title="$inmes_imtxt{'outsomemulticallback'}" style="vertical-align: middle;" />~ : qq~<img src="$imagesdir/imopen3.gif" border="0" alt="$inmes_imtxt{'outmultisomeread'}" title="$inmes_imtxt{'outmultisomeread'}" style="vertical-align: middle;" />~;
							$callBack = qq~<span class="small"><a href="$scripturl?action=imshow;id=$messageid;caller=2">$inmes_imtxt{'multicallback'}</a> | </span>~;
						}
					}
				}
			}

			## switch action if opening a draft - want this sending to the 'send' screen
			my $actString = 'imshow';
			if ($action eq 'imdraft') { $actString = 'imsend'; }

			## if grouping, check bar here
			if ($stkmess && $sortBy ne 'gpdate' && $normDateSet && $viewBMess) {
				## sticky messages
				$normDateSet = 0;
				$MCContent .= qq~
	  <tr>
	    <td class="titlebg"  width="100%" colspan="3"><span class="imgtitlebg">$im_sorted{'standart'}</span></td>
	  </tr>
				~;
			}

			if ($stkmess && $sortBy ne 'gpdate' && $stkDateSet && $viewBMess && ($messageStatus =~ /g/ || $messageStatus =~ /a/)) {
				## sticky messages
				$stkDateSet = 0;
				$MCContent .= qq~
	  <tr>
	    <td class="titlebg"  width="100%" colspan="3"><span class="imgtitlebg">$im_sorted{'important'}</span></td>
	  </tr>
				~;
			}

			if ($sortBy eq 'gpdate') {
				$uselegend = '';
				if ($latestDateSet && ($date - $mdate)/86400 > 1 && $counter > $counterCheck) {
						$latestDateSet = 0;
						if ($lastWeekSet) {
							$counterCheck = $counter if ($date - $mdate)/86400 <= 7;
							$uselegend = 'oneweek';
						}
				}

				if ($lastWeekSet && ($date - $mdate)/86400 > 7 && $counter > $counterCheck) {
						$lastWeekSet = 0;
						if ($twoWeeksSet) {
							$counterCheck = $counter if ($date - $mdate)/86400 <= 14;
							$uselegend = 'twoweeks';
						}
				}

				if ($twoWeeksSet && ($date - $mdate)/86400 > 14 && $counter > $counterCheck) {
						$twoWeeksSet = 0;
						if ($threeWeeksSet) {
							$counterCheck = $counter if ($date - $mdate)/86400 <= 21;
							$uselegend = 'threeweeks';
						}
				}

				if ($threeWeeksSet && ($date - $mdate)/86400 > 21 && $counter > $counterCheck) {
						$threeWeeksSet = 0;
						if ($monthSet) {
							$counterCheck = $counter if ($date - $mdate)/86400 <= 31;
							$uselegend = 'fourweeks';
						}
				}

				if ($monthSet && ($date - $mdate)/86400 > 31 && $counter > $counterCheck) {
						$monthSet = 0;
						if ($gtMonthSet) { $uselegend = 'older'; }
				}
				$MCContent .= qq~
	  <tr>
	    <td class="titlebg"  width="100%" colspan="3"><span class="imgtitlebg">$im_sorted{$uselegend}</span></td>
	  </tr>
				~ if $uselegend;
			}

			my $BCnew;
			if ($action eq 'im' && $viewBMess && !${$username}{'PMbcRead' . $messageid}) {
				$BCnew = qq~&nbsp;<img src="$imagesdir/new.gif" alt="" border="0" style="vertical-align: middle;" />~;
			}

			$MCContent .= qq~
	  <tr>
	    <td class="$class_PM_list" align="left">$BCnew$messageIcon$messIcon<a href="$scripturl?action=$actString;caller=$callerid;id=$messageid">$msub</a></td>
	    <td class="$class_PM_list">~;

			if ($action eq 'im' || ($action eq 'imstorage' && $INFO{'viewfolder'} eq 'in')) {
				if ($messageStatus eq 'g') {
					my ($guestName, $guestEmail) = split(/ /, $musername);
					$guestName =~ s/%20/ /g;
					$usernamefrom = qq~$guestName<br />(<a href="mailto:$guestEmail">$guestEmail</a>)~;
				} else {
					&LoadUser($musername); # is from user
					$usernamefrom = ${$uid.$musername}{'realname'} ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}" rel="nofollow">${$uid.$musername}{'realname'}</a>~ : ($musername ? qq~$musername ($maintxt{'470a'})~ : $maintxt{'470a'}); # 470a == Ex-Member
				}
				$MCContent .= $usernamefrom; # [inbox / broadcast / storage in]

			} elsif ($action eq 'imoutbox' || ($action eq 'imstorage' && $INFO{'viewfolder'} eq 'out')) {
				my @usernameto;
				if ($messageStatus eq 'gr') {
					my ($guestName, $guestEmail) = split(/ /, $musernameto);
					$guestName =~ s/%20/ /g;
					$usernameto[0] = qq~$guestName<br />(<a href="mailto:$guestEmail">$guestEmail</a>)~;
				} elsif ($messageStatus =~ /b/) {
					foreach my $uname (split(/,/, $musernameto)) {
						if ($uname eq 'all') { push(@usernameto, $inmes_txt{'bmallmembers'});
						} elsif ($uname eq 'mods') { push(@usernameto, $inmes_txt{'bmmods'});
						} elsif ($uname eq 'gmods') { push(@usernameto, $inmes_txt{'bmgmods'});
						} elsif ($uname eq 'admins') { push(@usernameto, $inmes_txt{'bmadmins'});
						} else {
							my ($title, undef) = split(/\|/, $NoPost{$uname}, 2);
							push(@usernameto, $title);
						}
					}
				} else {
					my $uname = $musernameto; # is to user
					$uname .= ",$musernamecc" if $musernamecc; 
					if ($musernamebcc) {
						if ($musername eq $username) {
							$uname .= ",$musernamebcc";
						} else {
							foreach (split(/,/, $musernamebcc)) {
								if ($_ eq $username) { $uname .= ",$username"; last; }
							}
						}
					}
					foreach $uname (split(/,/, $uname)) {
						&LoadUser($uname);
						push(@usernameto, (${$uid.$uname}{'realname'} ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$uname}" rel="nofollow">${$uid.$uname}{'realname'}</a>~ : ($uname ? qq~$uname ($maintxt{'470a'})~ : $maintxt{'470a'}))); # 470a == Ex-Member
					}
				}
				$MCContent .= join(', ', @usernameto); # [outbox / storage out]

			} elsif ($action eq 'imdraft') {
				my @usernameto;
				if ($messageStatus =~ /b/) {
					foreach my $uname (split(/,/, $musernameto)) {
						if ($uname eq 'all') { push(@usernameto, $inmes_txt{'bmallmembers'});
						} elsif ($uname eq 'mods') { push(@usernameto, $inmes_txt{'bmmods'});
						} elsif ($uname eq 'gmods') { push(@usernameto, $inmes_txt{'bmgmods'});
						} elsif ($uname eq 'admins') { push(@usernameto, $inmes_txt{'bmadmins'});
						} else {
							my ($title, undef) = split(/\|/, $NoPost{$uname}, 2);
							push(@usernameto, $title);
						}
					}
				} else {
					my $uname = $musernameto; # is to user
					$uname .= ",$musernamecc" if $musernamecc; 
					if ($musernamebcc) {
						if ($musername eq $username) {
							$uname .= ",$musernamebcc";
						} else {
							foreach (split(/,/, $musernamebcc)) {
								if ($_ eq $username) { $uname .= ",$username"; last; }
							}
						}
					}
					foreach $uname (split(/,/, $uname)) {
						&LoadUser($uname);
						push(@usernameto, (${$uid.$uname}{'realname'} ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$uname}" rel="nofollow">${$uid.$uname}{'realname'}</a>~ : ($uname ? qq~$uname ($maintxt{'470a'})~ : $maintxt{'470a'}))); # 470a == Ex-Member
					}
				}
				$MCContent .= join(', ', @usernameto); # [draft]

			} else {
				my @usernameto;
				if ($messageStatus eq 'g') {
					my ($guestName, $guestEmail) = split(/ /, $musername);
					$guestName =~ s/%20/ /g;
					$usernamefrom = qq~$guestName<br />(<a href="mailto:$guestEmail">$guestEmail</a>)~;

					my $uname = $musernameto; # is to user
					$uname .= ",$musernamecc" if $musernamecc; 
					if ($musernamebcc) {
						if ($musername eq $username) {
							$uname .= ",$musernamebcc";
						} else {
							foreach (split(/,/, $musernamebcc)) {
								if ($_ eq $username) { $uname .= ",$username"; last; }
							}
						}
					}
					foreach $uname (split(/,/, $uname)) {
						&LoadUser($uname);
						push(@usernameto, (${$uid.$uname}{'realname'} ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$uname}" rel="nofollow">${$uid.$uname}{'realname'}</a>~ : ($uname ? qq~$uname ($maintxt{'470a'})~ : $maintxt{'470a'}))); # 470a == Ex-Member
					} 
					$usernameto = join(', ', @usernameto);

				} elsif ($messageStatus eq 'gr') {
					my ($guestName, $guestEmail) = split(/ /, $musernameto);
					$guestName =~ s/%20/ /g;
					$usernameto = qq~$guestName<br />(<a href="mailto:$guestEmail">$guestEmail</a>)~;

					&LoadUser($musername); # is from user
					$usernamefrom = ${$uid.$musername}{'realname'} ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}" rel="nofollow">${$uid.$musername}{'realname'}</a>~ : ($musername ? qq~$musername ($maintxt{'470a'})~ : $maintxt{'470a'}); # 470a == Ex-Member

				} elsif ($messageStatus =~ /b/) {
					foreach my $uname (split(/,/, $musernameto)) {
						if ($uname eq 'all') { push(@usernameto, $inmes_txt{'bmallmembers'});
						} elsif ($uname eq 'mods') { push(@usernameto, $inmes_txt{'bmmods'});
						} elsif ($uname eq 'gmods') { push(@usernameto, $inmes_txt{'bmgmods'});
						} elsif ($uname eq 'admins') { push(@usernameto, $inmes_txt{'bmadmins'});
						} else {
							my ($title, undef) = split(/\|/, $NoPost{$uname}, 2);
							push(@usernameto, $title);
						}
					}
					$usernameto = join(', ', @usernameto); 

					&LoadUser($musername); # is from user
					$usernamefrom = ${$uid.$musername}{'realname'} ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}" rel="nofollow">${$uid.$musername}{'realname'}</a>~ : ($musername ? qq~$musername ($maintxt{'470a'})~ : $maintxt{'470a'}); # 470a == Ex-Member

				} else {
					my $uname = $musernameto; # is to user
					$uname .= ",$musernamecc" if $musernamecc;
					if ($musernamebcc) {
						if ($musername eq $username) {
							$uname .= ",$musernamebcc";
						} else {
							foreach (split(/,/, $musernamebcc)) {
								if ($_ eq $username) { $uname .= ",$username"; last; }
							}
						}
					}
					foreach $uname (split(/,/, $uname)) {
						&LoadUser($uname);
						push(@usernameto, (${$uid.$uname}{'realname'} ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$uname}" rel="nofollow">${$uid.$uname}{'realname'}</a>~ : ($uname ? qq~$uname ($maintxt{'470a'})~ : $maintxt{'470a'}))); # 470a == Ex-Member
					} 
					$usernameto = join(', ', @usernameto);

					&LoadUser($musername); # is from user
					$usernamefrom = ${$uid.$musername}{'realname'} ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}" rel="nofollow">${$uid.$musername}{'realname'}</a>~ : ($musername ? qq~$musername ($maintxt{'470a'})~ : $maintxt{'470a'}); # 470a == Ex-Member 
				}
				$MCContent .= qq~$usernamefrom / $usernameto~; #[store other]
			}
			$MCContent .= qq~</td>
	    <td class="$class_PM_list">$mydate</td>
			~;

			undef $quotecount;
			undef $codecount;
			$quoteimg = '';
			$codeimg = '';

			if ($UseMenuType != 1) { $sepa = '&nbsp;|&nbsp;'; }
			else { $sepa = $menusep; }
			## inline list for msg
			my ($actionsMenu, $actionsMenuselect, $storefolderView);
			$mreplyno++;
			## build actionsMenu for output
			if ($action eq 'im' && !$viewBMess) { 
				$actionsMenu = qq~<a href="$scripturl?action=imsend;caller=$callerid;quote=$mreplyno;to=$useraccount{$musername};id=$messageid">$inmes_txt{'145'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;reply=$mreplyno;to=$useraccount{$musername};id=$messageid">$inmes_txt{'146'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;forward=1;quote=$mreplyno;id=$messageid">$inmes_txt{'147'}</a>$sepa<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messageid" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~; 

			## broadcast messages can only be quoted on!
			} elsif ($action eq 'im' && $viewBMess) {
				if ($messageStatus eq 'g') {
					$actionsMenu = qq~<a href="$scripturl?action=imsend;caller=$callerid;quote=$mreplyno;replyguest=1;id=$messageid">$inmes_txt{'146'}</a>~;
				} else {

					$actionsMenu = qq~<a href="$scripturl?action=imsend;caller=$callerid;quote=$mreplyno;id=$messageid">$inmes_txt{'145'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;reply=$mreplyno;to=$useraccount{$musername};id=$messageid">$inmes_txt{'146'}</a>~;
				}
				if ($iamadmin || $username eq $musername) { 
					$actionsMenu .= qq~$sepa<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messageid" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~; $deleteButton = 1;
				}

			## for others
			} elsif ($action eq 'imdraft') { 
				$actionsMenu = qq~<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messageid" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
			} elsif ($action eq 'imoutbox') { 
				$actionsMenu = qq~$callBack<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messageid" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
			} else {
				if ($action eq 'imstorage') { $storefolderView = ";viewfolder=$INFO{'viewfolder'}"; }
				if ($messageStatus =~ /gr/) {
					$actionsMenu = qq~<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messageid$storefolderView" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
				} else {
					$actionsMenu = qq~$callBack<a href="$scripturl?action=imsend;caller=$callerid;quote=$mreplyno;to=$useraccount{$musername};id=$messageid">$inmes_txt{'145'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;reply=$mreplyno;to=$useraccount{$musername};id=$messageid">$inmes_txt{'146'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;forward=1;id=$messageid">$inmes_txt{'147'}</a>$sepa<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messageid$storefolderView" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
				}
			}
			if (!$viewBMess || ($viewBMess && ($iamadmin || $username eq $musername))) {
				$actionsMenuselect = qq~<input type="checkbox" name="message$messageid" id="message$messageid" class="$class_PM_list" value="1" style="cursor: hand;" /> <label for="message$messageid">$inmes_txt{'delete'}</label>~;
				if ($action ne 'imdraft' && !$viewBMess) { $actionsMenuselect .= qq~/<label for="message$messageid">$inmes_imtxt{'store'}</label>~; }
			}
			$MCContent .= qq~
	  </tr>

	  <tr>
	    <td colspan="3" height="21" class="$class_PM_list">
			~;

			if (($enable_PMcontrols && ${$uid.$username}{'pmviewMess'}) || (!$enable_PMcontrols && $enable_PMviewMess && ${$uid.$username}{'pmviewMess'})) {
				if ($immessage =~ /\[quote(.*?)\]/isg) {
					$quoteimg = qq~<img src="$imagesdir\/quote.gif" alt="$inmes_imtxt{'69'}" title="$inmes_imtxt{'69'}" \/>&nbsp;~;
					$immessage =~ s/\[quote(.*?)\](.+?)\[\/quote\]//ig;
				}
				if ($immessage =~ /\[code\s*(.*?)\]/isg) {
					$codeimg = qq~<img src="$imagesdir\/code1.gif" alt="$inmes_imtxt{'84'}" title="$inmes_imtxt{'84'}" \/>&nbsp;~;
					$immessage =~ s/\[code\s*(.*?)\](.+?)\[\/code\]//ig;
				}
				$immessage =~ s~<br.*?>~&nbsp;~gi;
				$immessage =~ s~&nbsp;&nbsp;~ ~g;
				&ToChars($immessage);
				$immessage =~ s~\[.*?\]~~g;
				&FromChars($immessage);
				$convertstr = $immessage;
				$convertcut = 100;
				&CountChars;
				my $immessage = $convertstr;
				&ToChars($immessage);
				if ($cliped) { $immessage .= "..."; }
				$immessage = qq~$quoteimg$codeimg $immessage~;
				$immessage = &Censor($immessage);
				unless ($immessage =~ s/#nosmileys//isg) {
					$message = $immessage;
					if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
					&MakeSmileys;
					$immessage = $message;
				}
				$MCContent .= qq~
		$immessage<br /><br />
		<hr width="100%" class="hr" />
				~;
			}
			$MCContent .= qq~
		<div style="float: left; text-align: left; width: 65%;"><span class="small">$actionsMenu</span></div>
		<div style="float: right; text-align: right; width: 35%;"><span class="small">$actionsMenuselect</span></div>
	    </td>
	  </tr>~;
			$acount++;
			if ($acount == $stkmess +1) { $normDateSet = 1; }
		}
################ end of message loop ###################

		## limiter bar
		if ($enable_imlimit == 1 && !$viewBMess) {
			my $impercent = 0;
			my $imbar = 0;
			my $imrest = 0;
			my $messageCounter = @dimmessages;
			if ($action eq 'im' && !$viewBMess) {
				if ($messageCounter != 0 && $numibox != 0) {
					$impercent = int(100 / $numibox * $messageCounter);
					$imbar = int(200 / $numibox * $messageCounter);
				}

				$intext = qq~($inmes_imtxt{'13'} $messageCounter $inmes_imtxt{'01'} $numibox $inmes_imtxt{'19'} $inmes_txt{'inbox'} $inmes_txt{'folder'})~;
			}

			elsif ($action eq 'imoutbox') {
				if ($messageCounter != 0 && $numobox != 0) {
					$impercent = int(100 / $numobox * $messageCounter);
					$imbar = int(200 / $numobox * $messageCounter);
				}
				$intext = qq~($inmes_imtxt{'13'} $messageCounter $inmes_imtxt{'01'} $numobox $inmes_imtxt{'19'} $inmes_txt{'outbox'} $inmes_txt{'folder'})~;
			}

			elsif ($action eq 'imdraft') {
				if ($messageCounter != 0 && $numdraft != 0) {
					$impercent = int(100 / $numdraft * $messageCounter);
					$imbar = int(200 / $numdraft * $messageCounter);
				}
				$intext = qq~($inmes_imtxt{'13'} $messageCounter $inmes_imtxt{'01'} $numdraft $inmes_imtxt{'19'} $inmes_txt{'draft'} $inmes_txt{'folder'})~;
			}
			elsif ($action eq 'imstorage') {
				if ($messageCounter != 0 && $numstore != 0) {
					$impercent = int(100 / $numstore * $messageCounter);
					$imbar = int(200 / $numstore * $messageCounter);
				}
				$intext = qq~($inmes_imtxt{'13'} $messageCounter $inmes_imtxt{'01'} $numstore $inmes_imtxt{'19'} $inmes_txt{'storage'} $inmes_txt{'folder'})~;
			}
			$imrest = 200 - $imbar;
			if ($imbar > 200) { $imbar  = 200; }
			if ($imrest <= 0) { $dorest = ''; }
			else { $dorest = qq~<img src="$imagesdir/usageempty.gif" height="8" width="$imrest" align="middle" alt="" />~; }
			$imbargfx = qq~$inmes_imtxt{'67'}:&nbsp;<img src="$imagesdir/usage.gif" align="middle" alt="" /><img src="$imagesdir/usagebar.gif" height="8" width="$imbar" align="middle" alt="" />$dorest<img src="$imagesdir/usage.gif" align="middle" alt="" />&nbsp;$impercent&nbsp;%&nbsp;<br />~;
		} else {
			$intext = '';
			$imbargfx = '';
		}
		unless ($action eq 'imstorage' && $INFO{'viewfolder'} eq '') { 
			$removeButton = qq~<input type="submit" name="imaction" value="$inmes_txt{'remove'}" class="button" onclick="return confirm('$inmes_txt{'delmultipms'}');" />~;
			$inmes_txt{'777'} =~ s/REMOVE/$removeButton/;
			$removeButton = $inmes_txt{'777'};
		}
		if (@dimmessages) {
			$MCContent .= qq~
	  <tr>
	    <td class="titlebg" colspan="3" align="right" height="21" >
			<br />~;
			if (!$viewBMess) {
				$MCContent .= qq~
		<span  class="small"><b>$imbargfx&nbsp;$intext</b><br /><br /></span>~ if $imbargfx || $intext;
				unless ($action eq 'imstorage' && $INFO{'viewfolder'} eq '') { $MCContent .= $movebutton; }
			}
			if (!$viewBMess || ($viewBMess && ($iamadmin|| $deleteButton))) {
				$MCContent .= qq~ $removeButton<br /><br />~;
			}
			$MCContent .= qq~
	    </td>
	  </tr>
			~;

			if ((!$viewBMess || ($viewBMess && ($iamadmin || $deleteButton))) && !($action eq 'imstorage' && $INFO{'viewfolder'} eq '')) {
				$MCContent .= qq~
	  <tr>
	    <td class="windowbg" colspan="3" align="right">
		<div style="float: right;">
		  <label for="delete_store"><i>$inmes_txt{'737'}</i></label>&nbsp;<input type="checkbox" id="delete_store" name="delete_store" onclick="if (this.checked) checkAll(); else uncheckAll();" />
		</div>
		<br />
		<script language="JavaScript1.2" type="text/javascript">
			<!--
			function checkAll() {
				for (var i = 0; i < document.searchform.elements.length; i++) {
					document.searchform.elements[i].checked = true;
				}
			}
			function uncheckAll() {

				for (var i = 0; i < document.searchform.elements.length; i++) {
				document.searchform.elements[i].checked = false;
				}
			}
			// -->
		</script>
	    </td>
	  </tr>~;
			}
		}
		$MCContent .= qq~
		</table>
		~;
	}
}

# load user's buddylist and show status of said members
sub LoadBuddyList {
	# Load background color list
	my @cssvalues = ('windowbg2', 'windowbg');
	my $cssnum = @cssvalues;
	my $counter = 0;

	my @buddies = split('\|',${$uid.$username}{'buddylist'});
	chomp @buddies;
	$buddiesCurrentStatus = qq~
		<table cellspacing="1" cellpadding="1" width="100%" align="center" border="0">
		<tr class="catbg"><td align="center">$profile_txt{'68a'}</td><td align="center">$profile_txt{'68b'}</td><td align="center"><img src="$imagesdir/imclose.gif" border="0" alt="$profile_txt{'69a'}" title="$profile_txt{'69a'}" /></td><td align="center"><img src="$imagesdir/email.gif" border="0" alt="$profile_txt{'69'}" title="$profile_txt{'69'}" /></td><td align="center"><img src="$imagesdir/www.gif" border="0" alt="$profile_txt{'96'}" title="$profile_txt{'96'}" /></td></tr>
	~;
	foreach my $buddyname (@buddies) {
		$css = $cssvalues[($counter % $cssnum)];
		my ($buddyrealname);
		my ($online, $buddyemail, $buddypm, $buddywww) = '&nbsp;';
		if (&checkfor_DBorFILE("$memberdir/$buddyname.vars")) {
			&LoadUser($buddyname);
			$online = &userOnLineStatus($buddyname);
			$buddyrealname = ${$uid.$buddyname}{'realname'};
			$usernamelink = $link{$buddyname};

			if (${$uid.$buddyname}{'hidemail'} && !$iamadmin && $allow_hide_email == 1) {
				$buddyemail = qq~<img src="$imagesdir/lockmail.gif" alt="$mycenter_txt{'hiddenemail'}" title="$mycenter_txt{'hiddenemail'}" />~;
			} else {
				$buddyemail = qq~<a href="mailto:${$uid.$buddyname}{'email'}"><img src="$imagesdir/email.gif" border="0" alt="$profile_txt{'889'} ${$uid.$buddyname}{'email'}" title="$profile_txt{'889'} ${$uid.$buddyname}{'email'}" /></a>~;
			}

			&CheckUserPM_Level($buddyname);
			if ($PM_level == 1 || ($PM_level == 2 && $UserPM_Level{$buddyname} > 1 && $staff) || ($PM_level == 3 && $UserPM_Level{$buddyname} == 3 && ($iamadmin || $iamgmod))) {
				$buddypm = qq~<a href="$scripturl?action=imsend;to=$useraccount{$buddyname}"><img src="$imagesdir/imclose.gif" border="0" alt="$profile_txt{'688'} $buddyrealname" title="$profile_txt{'688'} $buddyrealname" /></a>~;
			}

			if (${$uid.$buddyname}{'weburl'}) {
				$buddywww = qq~<a href="${$uid.$buddyname}{'weburl'}" target="_blank"><img src="$imagesdir/www.gif" border="0" alt="${$uid.$buddyname}{'webtitle'}" title="${$uid.$buddyname}{'webtitle'}" /></a>~;
			}

		} else {
			$usernamelink = $mycenter_txt{'buddydeleted'}; # Ex-Member 
		}
		$buddiesCurrentStatus .= qq~<tr class="$css"><td align="left">$usernamelink</td><td align="center">$online</td><td align="center">$buddypm</td><td align="center">$buddyemail</td><td align="center">$buddywww</td></tr>~;
		$counter++;
	}
	undef %UserPM_Level;
	$buddiesCurrentStatus .= "</table>";
	return $buddiesCurrentStatus;
}

sub mcMenu {
	my ($pmclass, $profclass, $postclass);
	if ($action eq "mycenter" || $action eq "im" || $action eq "imdraft" || $action eq "imoutbox" || $action eq "imstorage" || $action eq "imsend" || $action eq "imsend2" || $action eq "imshow") {
		$pmclass = qq~ class="selected"~;
		if ($PM_level == 0 || ($PM_level == 2 && !$staff) || ($PM_level == 3 && !$iamadmin && !$iamgmod)) {
			$profclass = qq~ class="selected"~;
		}
	}

	if ($action eq "profileCheck" || $action eq "myviewprofile" || $action eq "myprofile" || $action eq "myprofileContacts" || $action eq "myprofileOptions" || $action eq "myprofileBuddy" || $action eq "myprofileIM" || $action eq "myprofileAdmin") {
		$profclass = qq~ class="selected"~;
	}

	if ($action eq "favorites" || $action eq "shownotify" || $action eq "myusersrecentposts") {
		$postclass = qq~ class="selected"~;
	}

	my $tabsep = qq~<img src="$imagesdir/tabsep211.png" border="0" alt="" style="float: left; vertical-align: middle;" />~;
	my $tabfill = qq~<img src="$imagesdir/tabfill.gif" border="0" alt="" style="vertical-align: middle;" />~;

	# pm link
	if ($PM_level == 1 || ($PM_level == 2 && $staff) || ($PM_level == 3 && ($iamadmin || $iamgmod))) {
		$yymcmenu .= qq~<span onclick="changeToTab('pm'); return false;"$pmclass id="menu_pm"><a href="$scripturl?action=mycenter" onclick="changeToTab('pm'); return false;" style="padding: 3px 0 4px 0; ">$tabfill$mc_menus{'messages'}$tabfill</a></span>$tabsep
		~;
	}
	# profile link
	$yymcmenu .= qq~<span onclick="changeToTab('prof'); return false;"$profclass id="menu_prof"><a href="$scripturl?action=myviewprofile;username=$useraccount{$username}" onclick="changeToTab('prof'); return false;" style="padding: 3px 0 4px 0; ">$tabfill$mc_menus{'profile'}$tabfill</a></span>
	~;

	# posts link
	$yymcmenu .= qq~$tabsep<span onclick="changeToTab('posts'); return false;"$postclass  id="menu_posts"><a href="$scripturl?action=favorites" onclick="changeToTab('posts'); return false;" style="padding: 3px 0 4px 0; ">$tabfill$mc_menus{'posts'}$tabfill</a></span>
	~;

	$yymcmenu .= qq~$tabsep~;
}

1;