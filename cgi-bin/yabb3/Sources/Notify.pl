###############################################################################
# Notify.pl                                                                   #
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

$notifyplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('Notify');

sub ManageBoardNotify {
	my $todo     = $_[0];
	my $theboard = $_[1];
	my $user     = $_[2];
	my $userlang = $_[3];
	my $notetype = $_[4];
	my $noteview = $_[5];
	if ($todo eq "load" || $todo eq "update" || $todo eq "delete" || $todo eq "add") {
		undef %theboard;
		## open board mail file and build hash name / detail
		%theboard = map /(.*)\t(.*)/, &read_DBorFILE(1,'',$boardsdir,$theboard,'mail');
	}
	if ($todo eq "add") {
		$theboard{$user} = "$userlang|$notetype|$noteview";
		&LoadUser($user);
		my %b;
		foreach (split(/,/, ${$uid.$user}{'board_notifications'})) {
			$b{$_} = 1;
		}
		$b{$theboard} = 1;
		${$uid.$user}{'board_notifications'} = join(',', keys %b);
		&UserAccount($user);
	} elsif ($todo eq "update") {
		if (exists $theboard{$user}) {
			my ($memlang, $memtype, $memview) = split(/\|/, $theboard{$user});
			if ($userlang) { $memlang = $userlang; }
			if ($notetype) { $memtype = $notetype; }
			if ($noteview) { $memview = $noteview; }
			$theboard{$user} = "$memlang|$memtype|$memview";
		}
	} elsif ($todo eq "delete") {
		my %b;
		foreach my $u (split(',', $user)) {
			delete $theboard{$u};
			&LoadUser($u);
			foreach (split(/,/, ${$uid.$u}{'board_notifications'})) { $b{$_} = 1; }
			if (delete $b{$theboard}) {
				${$uid.$u}{'board_notifications'} = join(',', keys %b);
				&UserAccount($u);
			}
			undef %b;
		}
	}
	if ($todo eq "save" || $todo eq "update" || $todo eq "delete" || $todo eq "add") {
		if (%theboard) {
			&write_DBorFILE(1,'',$boardsdir,$theboard,'mail',(map "$_\t$theboard{$_}\n", sort { $theboard{$a} cmp $theboard{$b} } keys %theboard));
			undef %theboard;
		} else {
			&delete_DBorFILE("$boardsdir/$theboard.mail");
		}
	}
}

sub BoardNotify {
	if (!$currentboard) { &fatal_error("no_access"); }
	if ($iamguest)      { &fatal_error("members_only"); }
	my ($curuser, $curlang, $notifytype);
	$selected1 = "";
	$selected2 = "";
	$deloption = "";
	my ($boardname, undef) = split(/\|/, $board{$currentboard}, 2);
	&ToChars($boardname);
	&ManageBoardNotify("load", $currentboard);
	$yymain .= qq~
	<form action="$scripturl?action=boardnotify3;board=$currentboard" method="post">
	<table border="0" width="600" cellspacing="1" cellpadding="4" align="center" class="bordercolor">
		<tr>
		<td colspan="2" align="left" class="titlebg">
		<img src="$imagesdir/notify.gif" alt="$notify_txt{'136'} - $boardname" title="$notify_txt{'136'} - $boardname" /> <span class="text1"><b>$notify_txt{'136'} - $boardname</b></span>
		</td>
		</tr><tr>
		<td class="windowbg" width="70%" align="left" valign="middle"><br />
	~;

	if (exists $theboard{$username}) {
		($memlang, $memtype, $memview) = split(/\|/, $theboard{$username});
		${ selected . $memtype } = qq~ selected="selected"~;
		$deloption = qq~<option value="3">$notify_txt{'134'}</option>~;
		$yymain .= qq~$notify_txt{'137'} &nbsp;~;
	} else {
		$yymain .= qq~$notify_txt{'126'} &nbsp;~;
	}
	$yymain .= qq~
		<br /><br />
		</td><td class="windowbg" width="30%" align="center" valign="middle">
		<select name="$currentboard">
		<option value="1"$selected1>$notify_txt{'132'}</option>
		<option value="2"$selected2>$notify_txt{'133'}</option>
		$deloption
		</select>
		</td></tr>
		<tr>
		<td colspan="2" class="catbg" align="center">
		<input type="submit" value="$notify_txt{'124'}" class="button" />
		</td>
		</tr>
	</table>
	</form>
	~;
	undef %theboard;
	$yytitle = "$notify_txt{'125'}";
	&template;
}

sub BoardNotify2 {
	if ($iamguest) { &fatal_error("members_only"); }
	foreach $variable (keys %FORM) {
		if ($variable eq 'formsession') { next; }
		$notify_type = $FORM{$variable};
		if ($notify_type == 1 || $notify_type == 2) {
			&ManageBoardNotify("add", $variable, $username, ${$uid.$username}{'language'}, $notify_type, "1");
		} elsif ($notify_type == 3) {
			&ManageBoardNotify("delete", $variable, $username);
		}
	}
	if ($action eq "boardnotify3") {
		$yySetLocation = qq~$scripturl?board=$INFO{'board'}~;
	} else {
		$yySetLocation = qq~$scripturl?action=shownotify~;
	}
	&redirectexit;
}

sub ManageThreadNotify {
	my $todo      = $_[0];
	my $thethread = $_[1];
	my $user      = $_[2];
	my $userlang  = $_[3];
	my $notetype  = $_[4];
	my $noteview  = $_[5];

	if ($todo eq "load" || $todo eq "update" || $todo eq "delete" || $todo eq "add") {
		undef %thethread;
		##  open mail file and build hash 
		%thethread = map /(.*)\t(.*)/, &read_DBorFILE(1,'',$datadir,$thethread,'mail');
	}
	if ($todo eq "add") {
		$thethread{$user} = "$userlang|$notetype|$noteview";
		&LoadUser($user);
		my %t;
		foreach (split(/,/, ${$uid.$user}{'thread_notifications'})) {
			$t{$_} = 1;
		}
		$t{$thethread} = 1;
		${$uid.$user}{'thread_notifications'} = join(',', keys %t);
		&UserAccount($user);
	} elsif ($todo eq "update") {
		if (exists $thethread{$user}) {
			($memlang, $memtype, $memview) = split(/\|/, $thethread{$user});
			if ($userlang) { $memlang = $userlang; }
			if ($notetype) { $memtype = $notetype; }
			if ($noteview) { $memview = $noteview; }
			$thethread{$user} = "$memlang|$memtype|$memview";
		}
	} elsif ($todo eq "delete") {
		my %t;
		foreach my $u (split(',', $user)) {
			delete $thethread{$u};
			&LoadUser($u);
			foreach (split(/,/, ${$uid.$u}{'thread_notifications'})) { $t{$_} = 1; }
			if (delete $t{$thethread}) {
				${$uid.$u}{'thread_notifications'} = join(',', keys %t);
				&UserAccount($u);
			}
			undef %t;
		}
	}
	if ($todo eq "save" || $todo eq "update" || $todo eq "delete" || $todo eq "add") {
		if (%thethread) {
			&write_DBorFILE(1,'',$datadir,$thethread,'mail',(map "$_\t$thethread{$_}\n", sort { $thethread{$a} cmp $thethread{$b} } keys %thethread));
			undef %thethread;
		} else {
			&delete_DBorFILE("$datadir/$thethread.mail");
		}
	}
}

# sub Notify { delted because not needed any more since YaBB 2.3 (deti)

sub Notify2 {
	if ($iamguest) { &fatal_error("members_only"); }

	&ManageThreadNotify("add", $INFO{'num'}, $username, ${$uid.$username}{'language'}, 1, 1);

	if ($INFO{'oldnotify'}) {
		&redirectinternal;
	}
	$elenable = 0;
	die ""; # This is here only to avoid server error log entries!
}

sub Notify3 {
	if ($iamguest) { &fatal_error("members_only"); }

	&ManageThreadNotify("delete", $INFO{'num'}, $username);

	if ($INFO{'oldnotify'}) {
		&redirectinternal;
	}
	$elenable = 0;
	die ""; # This is here only to avoid server error log entries!
}

sub Notify4 {
	if ($iamguest) { &fatal_error("members_only"); }
	my ($variable, $notype, $threadno);
	foreach $variable (keys %FORM) {
		($notype, $threadno) = split(/-/, $variable);
		if ($notype eq "thread") {
			&ManageThreadNotify("delete", $threadno, $username);
		}
	}
	$action = 'shownotify';
	&ShowNotifications;
}

sub updateLanguage {
	my ($user,$newlang) = @_;
	&getMailFiles;
	foreach (@bmaildir) {
		&ManageBoardNotify("update", $_, $user, $newlang, "", "");
	}
	foreach (@tmaildir) {
		&ManageThreadNotify("update", $_, $user, $newlang, "", "");
	}
}

sub removeNotifications {
	my $user_s = shift;
	&getMailFiles;
	foreach (@bmaildir) {
		&ManageBoardNotify("delete", $_, $user_s);
	}
	foreach (@tmaildir) {
		&ManageThreadNotify("delete", $_, $user_s);
	}
}

sub getMailFiles {
	opendir(BOARDNOT, "$boardsdir");
	@bmaildir = map { (split(/\./, $_))[0] } grep { /\.mail$/ } readdir(BOARDNOT);
	closedir(BOARDNOT);
	if ($use_MySQL) {
		@tmaildir = &get_mail_array();
	} else {
		opendir(THREADNOT, "$datadir");
		@tmaildir = map { (split(/\./, $_))[0] } grep { /\.mail$/ } readdir(THREADNOT);
		closedir(THREADNOT);
	}
}

sub ShowNotifications {
	## bye bye guest....
	if ($iamguest) { &fatal_error("members_only"); }

	$yynavigation = qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $img_txt{'418'}~;

	# Show Javascript for 'check all' notifications
	$showNotifications .= qq~
<script language="Javascript1.2" type="text/javascript">
	<!--
		function checkAll(j) {
				for (var i = 0; i < document.threadnotify.elements.length; i++) {
					if (j == 0 ) {document.threadnotify.elements[i].checked = true;}
				}
		}
		function uncheckAll(j) {
				for (var i = 0; i < document.threadnotify.elements.length; i++) {
					if (j == 0 ) {document.threadnotify.elements[i].checked = false;}
				}
		}
	//-->
</script>

	<form action="$scripturl?action=boardnotify2" method="post" name="boardnotify">
	<table border="0" width="100%" align="center" cellspacing="1" cellpadding="4" class="bordercolor">
		<tr><td colspan="2" align="left" class="titlebg">
			<img src="$imagesdir/notify.gif" alt="$notify_txt{'136'}" title="$notify_txt{'136'}" /> <span class="text1"><b>$notify_txt{'136'}</b></span>
		</td></tr>
	~;

	($board_notify,$thread_notify) = &NotificationAlert;
	my ($num,$new);
	# Board notifications sorted lexically and case-insensitively
	foreach (sort {lc(${$$board_notify{$a}}[0]) cmp lc(${$$board_notify{$b}}[0])} keys %$board_notify) { # boardname, boardnotifytype , new
		$num++;

		my ($selected1, $selected2);
		if (${$$board_notify{$_}}[1] == 1) { # new topics
				$selected1 = qq~ selected="selected"~;
		} else { # all new posts
				$selected2 = qq~ selected="selected"~;
		}

		if (${$$board_notify{$_}}[2]) {
			$new = qq~<img src="$imagesdir/on.gif" alt="$notify_txt{'333'}" title="$notify_txt{'333'}" border="0" style="vertical-align: middle;" />~;
		} else {
			$new = qq~<img src="$imagesdir/off.gif" alt="$notify_txt{'334'}" title="$notify_txt{'334'}" border="0" style="vertical-align: middle;" />~;
		}

		## output notify detail - option 3 = remove notify
		$boardblock .= qq~
		<tr><td align="left" width="65%" class="windowbg">
			$new <a href="$scripturl?board=$_">${$$board_notify{$_}}[0]</a>
		</td><td align="center" width="35%" class="windowbg">
		<select name="$_">
				<option value="1"$selected1>$notify_txt{'132'}</option>
				<option value="2"$selected2>$notify_txt{'133'}</option>
				<option value="3">$notify_txt{'134'}</option>
		</select>
		</td></tr>
		~;
	}

	if (!$num) { # no board notifies up
		$showNotifications .= qq~
		<tr><td colspan="2" align="left" class="windowbg2">
		<br />
		$notify_txt{'139'}<br /><br />
		</td></tr>
		~;
	} else { # list boards
		$showNotifications .= qq~
		<tr><td align="left" class="catbg">
		<b>$notify_txt{'135'}</b>
		</td><td align="center" class="catbg">
		<b>$notify_txt{'138'}</b>
		</td></tr>
		$boardblock
		<tr><td colspan="2" align="center" class="windowbg">
		<input type="submit" value="$notify_txt{'124'}" class="button" />&nbsp; <input type="reset" value="$notify_txt{'121'}" class="button" />
		</td></tr>
		~;
	}

	$showNotifications .= qq~
	</table>
	</form>
	<br /><br />

	<form action="$scripturl?action=notify4" method="post" name="threadnotify">
	<table border="0" width="100%" align="center" cellspacing="1" cellpadding="4" class="bordercolor">
	<tr><td align="left" colspan="2" class="titlebg">
		<img src="$imagesdir/notify.gif" alt="$notify_txt{'118'}" title="$notify_txt{'118'}" /> <span class="text1"><b>$notify_txt{'118'}</b></span>
	</td></tr>
	~;

	$num = 0;
	# sort numerically descending
	# mythread, msub, new, username_link, catname_link, boardname_link, lastpostdate
	foreach (sort { ${$$thread_notify{$b}}[6] <=> ${$$thread_notify{$a}}[6] } keys %$thread_notify) {
		$num++;

		## format last post date for output
		my $lastpostdate = &timeformat(${$$thread_notify{$_}}[6]);

		## build block for display
		$threadblock .= qq~
		<tr><td align="left" width="85%" class="windowbg2">
				<b><a href="$scripturl?num=${$$thread_notify{$_}}[0]/new#new">${$$thread_notify{$_}}[2] ${$$thread_notify{$_}}[1]</a></b> $notify_txt{'120'} ${$$thread_notify{$_}}[3]
				<br /><span class="small">${$$thread_notify{$_}}[4] &raquo; ${$$thread_notify{$_}}[5] - $notify_txt{'lastpost'} $lastpostdate</span>
		</td><td align="center" width="15%" class="windowbg2">
				<input type="checkbox" name="thread-${$$thread_notify{$_}}[0]" value="1" />
		</td></tr>
		~;
	}

	if (!$num) { ## no threads listed
		$showNotifications .= qq~
		<tr><td colspan="2" align="left" class="windowbg2">
		<br />
		$notify_txt{'119'}<br /><br />
		</td></tr>
		~;
	} else { ## output details
		$showNotifications .= qq~
		<tr><td align="left" class="catbg">
		<b>$notify_txt{'140'}</b>
		</td><td align="center" class="catbg">
		<b>$notify_txt{'134'}</b>
		</td></tr>
		$threadblock
		<tr><td align="right" width="85%" class="catbg"><span class="small"><label for="checkall">$notify_txt{'144'}</label></span></td>
		<td align="center" width="15%" class="catbg"><input type="checkbox" name="checkall" id="checkall" value="" onclick="if (this.checked) checkAll(0); else uncheckAll(0);" /></td></tr>
		<tr><td colspan="2" align="center" class="windowbg">
		<input type="submit" value="$notify_txt{'124'}" class="button" />&nbsp; <input type="reset" value="$notify_txt{'121'}" class="button" />
		</td></tr>
		~;
	}
	$showNotifications .= qq~
	</table>
	</form>
	~;

	$yytitle = "$notify_txt{'124'}";

	## and finally, add jump menu for a route back.
	if (!$view) {
		&jumpto;
		$yymain .= qq~$showNotifications$selecthtml~;
		&template;
	}
}

sub NotificationAlert {
	my ($myboard, %board_notify, $mythread, %thread_notify);

	@bmaildir = split(/,/, ${$uid.$username}{'board_notifications'});
	@tmaildir = split(/,/, ${$uid.$username}{'thread_notifications'});

	# needed for $new - icon (on/off/new.gif)
	my @noloadboard = grep(!exists ${$uid.$_}{'lastposttime'}, @allboards);
	&BoardTotals("load",@noloadboard) if @noloadboard; # to get ${$uid.$myboard}{'lastposttime'}
	&getlog; # sub in Subs.pl, for $yyuserlog{$myboard}
	my $dmax = $date - ($max_log_days_old * 86400);

	## run through boards list
	foreach $myboard (@bmaildir) { # board name from file name
		if (!&checkfor_DBorFILE("$boardsdir/$myboard.txt")) { # remove from user board_notifications
			&ManageBoardNotify("delete", $myboard, $username);
			next;
		}

		## load in hash of name / detail for board
		&ManageBoardNotify("load", $myboard);

		if (exists $theboard{$username}) {
			## grab board name
			my $boardname = (split(/\|/, $board{$myboard}))[0];

			$board_notify{$myboard} = [ $boardname,
			                            (split(/\|/, $theboard{$username}))[1], # boardnotifytype
			                            (($max_log_days_old && int(${$uid.$myboard}{'lastposttime'}) && ((!$yyuserlog{$myboard} && ${$uid.$myboard}{'lastposttime'} > $dmax) || ($yyuserlog{$myboard} > $dmax && $yyuserlog{$myboard} < ${$uid.$myboard}{'lastposttime'}))) ? 1 : 0), # new == 1
			                           ];

			undef %theboard;
		}
	}

	&LoadCensorList if $action eq 'shownotify';

	## load board names
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; } # for $board{...}

	foreach $mythread (@tmaildir) { # number of next thread
		# see if thread exists and search for it if moved
		if (!&checkfor_DBorFILE("$datadir/$mythread.txt")) {
			&ManageThreadNotify("delete", $mythread, $username);
			eval { require "$datadir/movedthreads.cgi" };
			next if !exists $moved_file{$mythread} || !$moved_file{$mythread};
			my $newthread;
			while (exists $moved_file{$mythread}) {
				$mythread = $moved_file{$mythread};
				$newthread = $mythread if !exists $moved_file{$mythread} && &checkfor_DBorFILE("$datadir/$mythread.txt");
			}
			next if !$newthread;
			&ManageThreadNotify("add", $newthread, $username, ${$uid.$username}{'language'}, 1, 1);
		}

		## load threads hash
		&ManageThreadNotify("load", $mythread);

		if (exists $thethread{$username}) {
			## load ctb file for board data
			&MessageTotals ("load", $mythread);

			## pull out board and last post
			my $boardid = ${$mythread}{'board'};
			my ($msub,$mname,$musername,$new,$username_link,$catname_link,$boardname_link);
			if ($action eq 'shownotify') {
				unless (${${'notify'.$boardid.$mythread}}[0]) {
					my ($messageid,$messagesubject);
					foreach (&read_DBorFILE(0,'',$boardsdir,$boardid,'txt')) {
						($messageid, $messagesubject, $mname, undef, undef, undef, $musername, undef) = split(/\|/, $_, 8);
						${'notify'.$boardid.$messageid} = [$messagesubject,$mname,$musername];
					}
				}
				$msub = ${${'notify'.$boardid.$mythread}}[0];
				$mname = ${${'notify'.$boardid.$mythread}}[1];
				$musername = ${${'notify'.$boardid.$mythread}}[2];

				&ToChars($msub);
				($msub, undef) = &Split_Splice_Move($msub,0);
				$msub = &Censor($msub);  # censor subject text !

				## run through the categories until we hit the match for category name
				my ($catname,$thiscatid,$catid);
				my $boardname = (split(/\|/, $board{$boardid}))[0]; # grab boardname from list
				checkboardname: foreach $catid (@categoryorder) {
								 foreach (split(/\,/, $cat{$catid})) {
									## find the match, grab data and jump out
									if ($_ eq $boardid) {
										$catname = (split(/\|/, $catinfo{$catid}))[0];
										$thiscatid = $catid;
										last checkboardname;
									}
								 }
				}
				$catname_link = qq~<a href="$scripturl?catselect=$thiscatid">$catname</a>~;
				$boardname_link = qq~<a href="$scripturl?board=$boardid">$boardname</a>~;

				## build view profile link, if real name exists
				&LoadUser($musername); # load poster
				if (${$uid.$musername}{'realname'}) {
					$username_link = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}" rel="nofollow">${$uid.$musername}{'realname'}</a>~;
				} elsif ($mname) {
					$username_link = $mname;
				} else {
					$username_link = $musername;
				}
			}

			if ($max_log_days_old) {
				# Decide if thread should have the "NEW" indicator next to it.
				# Do this by reading the user's log for last read time on thread,
				# and compare to the last post time on the thread.
				my $dlp  = int($yyuserlog{$mythread});
				my $dlpb = int($yyuserlog{"$boardid--mark"});
				$dlp     = $dlp > $dlpb ? $dlp : $dlpb;
				if ($yyuserlog{"$mythread--unread"} || (!$dlp && ${$mythread}{'lastpostdate'} > $dmax) || ($dlp > $dmax && $dlp < ${$mythread}{'lastpostdate'})) {
					$new = qq~<img src="$imagesdir/new.gif" alt="$notify_txt{'335'}" title="$notify_txt{'335'}" border="0"/>~;
				}
			}

			$thread_notify{$mythread} = [$mythread, $msub, $new, $username_link, $catname_link, $boardname_link, ${$mythread}{'lastpostdate'}];
		}
	}

	(\%board_notify,\%thread_notify);
}

1;