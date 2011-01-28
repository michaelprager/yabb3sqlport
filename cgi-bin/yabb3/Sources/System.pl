###############################################################################
# System.pl                                                                   #
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

$systemplver = 'YaBB 3.0 Beta $Revision: 100 $';

sub BoardTotals {
	my ($testboard, $line, @lines, $updateboard, @boardvars, $tag, $cnt);
	my ($job, @updateboards) = @_;
	if (!@updateboards) { @updateboards = @allboards; }
	chomp(@updateboards);
	if (@updateboards) {
		my @tags = qw(board threadcount messagecount lastposttime lastposter lastpostid lastreply lastsubject lasticon lasttopicstate);
		if ($job eq "load") {
			@lines = &read_DBorFILE(0,'',$boardsdir,'forum','totals');
			chomp(@lines);
			foreach $updateboard (@updateboards) {
				foreach $line (@lines) {
					@boardvars = split(/\|/, $line);
					if ($boardvars[0] eq $updateboard && exists($board{ $boardvars[0] })) {
						for ($cnt = 1; $cnt < @tags; $cnt++) {
							${$uid.$updateboard}{ $tags[$cnt] } = $boardvars[$cnt];
						}
						last;
					}
				}
			}

		} elsif ($job eq "update") {
			@lines = &read_DBorFILE(0,FORUMTOTALS,$boardsdir,'forum','totals');
			for ($line = 0; $line < @lines; $line++) {
				@boardvars = split(/\|/, $lines[$line]);
				if (exists $board{$boardvars[0]}) {
					next if $boardvars[0] ne $updateboards[0];
					$lines[$line] = "$updateboards[0]|";
					chomp $boardvars[9];
					for ($cnt = 1; $cnt < @tags; $cnt++) {
						if (exists(${$uid.$boardvars[0]}{ $tags[$cnt] })) {
							$lines[$line] .= ${$uid.$boardvars[0]}{ $tags[$cnt] };
						} else {
							$lines[$line] .= $boardvars[$cnt];
						}
						$lines[$line] .= $cnt < $#tags ? "|" : "\n";
					}
				} else {
					$lines[$line] = '';
				}
			}
			&write_DBorFILE(0,FORUMTOTALS,$boardsdir,'forum','totals',@lines);

		} elsif ($job eq "delete") {
			@lines = &read_DBorFILE(0,FORUMTOTALS,$boardsdir,'forum','totals');
			for ($line = 0; $line < @lines; $line++) {
				@boardvars = split(/\|/, $lines[$line], 2);
				if ($boardvars[0] eq $updateboards[0] || !exists $board{$boardvars[0]}) {
					$lines[$line] = '';
				}
			}
			&write_DBorFILE(0,FORUMTOTALS,$boardsdir,'forum','totals',@lines);

		} elsif ($job eq "add") {
			@lines = &read_DBorFILE(0,FORUMTOTALS,$boardsdir,'forum','totals');
			foreach (@updateboards) { push(@lines, "$_|0|0|N/A|N/A||||\n"); }
			&write_DBorFILE(0,FORUMTOTALS,$boardsdir,'forum','totals',@lines);
		}
	}
}

sub BoardCountTotals {
	my $cntboard = $_[0];
	unless ($cntboard) { return undef; }
	my (@threads, $threadcount, $messagecount, $i, $threadline);

	@threads = &read_DBorFILE(0,'',$boardsdir,$cntboard,'txt');
	$threadcount  = @threads;
	$messagecount = $threadcount;
	for ($i = 0; $i < @threads; $i++) {
		@threadline = split(/\|/, $threads[$i]);
		if ($threadline[8] =~ /m/) {
			$threadcount--;
			$messagecount--;
			next;
		}
		$messagecount += $threadline[5];
	}
	${$uid.$cntboard}{'threadcount'}  = $threadcount;
	${$uid.$cntboard}{'messagecount'} = $messagecount;
	&BoardSetLastInfo($cntboard,\@threads);
}

sub BoardSetLastInfo {
	my ($setboard,$board_ref) = @_;
	my ($lastthread, $lastthreadid, $lastthreadstate, @lastthreadmessages, @lastmessage);

	foreach $lastthread (@$board_ref) {
		if ($lastthread) {
			($lastthreadid, undef, undef, undef, undef, undef, undef, undef, $lastthreadstate) = split(/\|/, $lastthread);
			if ($lastthreadstate !~ /m/) {
				chomp $lastthreadstate;
				@lastthreadmessages = &read_DBorFILE(0,'',$datadir,$lastthreadid,'txt');
				@lastmessage = split(/\|/, $lastthreadmessages[$#lastthreadmessages], 7);
				last;
			}
			$lastthreadid = '';
		}
	}
	${$uid.$setboard}{'lastposttime'}   = $lastthreadid ? $lastmessage[3]      : 'N/A';
	${$uid.$setboard}{'lastposter'}     = $lastthreadid ? ($lastmessage[4] eq "Guest" ? "Guest-$lastmessage[1]" : $lastmessage[4]) : 'N/A';
	${$uid.$setboard}{'lastpostid'}     = $lastthreadid ? $lastthreadid        : '';
	${$uid.$setboard}{'lastreply'}      = $lastthreadid ? $#lastthreadmessages : '';
	${$uid.$setboard}{'lastsubject'}    = $lastthreadid ? $lastmessage[0]      : '';
	${$uid.$setboard}{'lasticon'}       = $lastthreadid ? $lastmessage[5]      : '';
	${$uid.$setboard}{'lasttopicstate'} = ($lastthreadid && $lastthreadstate) ? $lastthreadstate : "0";
	&BoardTotals("update", $setboard);
}

#### THREAD MANAGEMENT ####

sub MessageTotals {
	# usage: &MessageTotals("task",<threadid>)
	# tasks: update, load, incview, incpost, decpost, recover
	my ($job,$updatethread) = @_;
	chomp $updatethread;
	return if !$updatethread;

	# Changes here on @tag must also be done in Post.pl -> sub Post2 -> my @tag = ...
	# and in Subs.pl in the SQL/File management block: my %db_table = (...
	my @tag = qw(board replies views lastposter lastpostdate threadstatus repliers);

	if ($job eq "update") {
		if (${$updatethread}{'board'} eq "") { # load if the variable is not already filled
			&MessageTotals("load",$updatethread);
		}

	} elsif ($job eq "load") {
		return if ${$updatethread}{'board'} ne ""; # skip load if the variable is already filled

		my $i = 0;
		foreach (&read_DBorFILE(0,'',$datadir,$updatethread,'ctb')) {
			if ($use_MySQL) { ${$updatethread}{$tag[$i]} = $_; $i++; }
			else { if ($_ =~ /^'(.*?)',"(.*?)"/) { ${$updatethread}{$1} = $2; } }
		}

		${$updatethread}{'mysql'} = ($use_MySQL && ${$updatethread}{'lastpostdate'}) ? 1 : 0;
		@repliers = split(",", ${$updatethread}{'repliers'});

		return;

	} elsif ($job eq "incview") {
		${$updatethread}{'views'}++;

	} elsif ($job eq "incpost") {
		${$updatethread}{'replies'}++;

	} elsif ($job eq "decpost") {
		${$updatethread}{'replies'}--;

	} elsif ($job eq 'recover') {
		# storing thread status
		my $threadstatus;
		my $openboard = ${$updatethread}{'board'};
		foreach (&read_DBorFILE(0,'',$boardsdir,$openboard,'txt')) {
			if ($updatethread == (split /\|/, $_, 2)[0]) {
				$threadstatus = (split /\|/, $_)[8];
				chomp $threadstatus;
				last;
			}
		}
		# storing thread other info
		my @threaddata = &read_DBorFILE(0,'',$datadir,$updatethread,'txt');
		my @lastinfo = split(/\|/, $threaddata[$#threaddata]);
		my $lastpostdate = sprintf("%010d", $lastinfo[3]);
		my $lastposter = $lastinfo[4] eq 'Guest' ? qq~Guest-$lastinfo[1]~ : $lastinfo[4];
		# rewrite/create a correct thread.ctb
		${$updatethread}{'replies'} = $#threaddata;
		${$updatethread}{'views'} = ${$updatethread}{'views'} || 0;
		${$updatethread}{'lastposter'} = $lastposter;
		${$updatethread}{'lastpostdate'} = $lastpostdate;
		${$updatethread}{'threadstatus'} = $threadstatus;
		@repliers = ();

	} else {
		return;
	}

	if (&checkfor_DBorFILE("$datadir/$updatethread.txt")) { # trap writing false ctb files on forged num= actions
		${$updatethread}{'repliers'} = join(",", @repliers);

		if ($use_MySQL) {
			@tag = map { ${$updatethread}{$_} } @tag;
		} else {
			@tag = map { qq~'$_',"${$updatethread}{$_}"\n~ } @tag;
			unshift(@tag, "### ThreadID: $updatethread ###\n\n");
		}

		&write_DBorFILE(${$updatethread}{'mysql'},'',$datadir,$updatethread,'ctb',@tag);
	}
}

# NOBODY expects the Spanish Inquisition!
# - Monty Python

#### USER AND MEMBERSHIP MANAGEMENT ####

sub UserAccount {
	my ($user, $action, $pars) = @_;
	return if !${$uid.$user}{'password'};

	if ($action eq "update") {
		if ($pars) {
			foreach (split(/\+/, $pars)) { ${$uid.$user}{$_} = $date; }
		} elsif ($username eq $user) {
			${$uid.$user}{'lastonline'} = $date;
		}
		$userext = "vars";
		${$uid.$user}{'reversetopic'} = $ttsreverse unless exists(${$uid.$user}{'reversetopic'});
	} elsif ($action eq "preregister") {
		$userext = "pre";
	} elsif ($action eq "register") {
		$userext = "vars";
	} elsif ($action eq "delete") {
		&delete_DBorFILE("$memberdir/$user.vars");
		return;
	} else { $userext = "vars"; }

	# using sequential tag writing as hashes do not sort the way we like them to
	# This array must be exactly the same as in Admin/Database.pl!!!
	# If you want to add Mods, don't add your variables here. See 7 lines below.
	my @tags = qw(realname password position addgroups email hidemail regdate regtime regreason location bday gender userpic usertext signature template language stealth webtitle weburl icq aim yim skype myspace facebook msn gtalk timeselect timeformat timeoffset dsttimeoffset dynamic_clock postcount lastonline lastpost lastim im_ignorelist im_popup im_imspop pmmessprev pmviewMess pmactprev notify_me board_notifications thread_notifications favorites buddylist cathide pageindex reversetopic postlayout sesquest sesanswer session lastips onlinealert offlinestatus awaysubj awayreply awayreplysent spamcount spamtime hide_avatars hide_user_text hide_attach_img hide_signat hide_smilies_row numberformat);
	my @additional_tags;
	if ($extendedprofiles) {
		require "$sourcedir/ExtendedProfiles.pl";
		push(@additional_tags, &ext_get_fields_array());
	}
	# Add here something like this for Mods:
	# push(@additional_tags, 'name_of_mod_variable_1' [, 'name_of_mod_variable_2' , 'name_of_mod_variable_3' , ... ]);
	# Dont't use the variable name 'additional_variables' or one
	# of the names from @tags above, nor one beginning with 'ext_'!

	if ($use_MySQL && $userext eq 'vars') {
		${$uid.$user}{'additional_variables'} = join('', map { qq~'$_',"${$uid.$user}{$_}"\n~ } @additional_tags);
	} else {
		@tags = map { qq~'$_',"${$uid.$user}{$_}"\n~ } (@tags,@additional_tags);
		unshift(@tags, "### User variables for ID: $user ###\n\n");
	}
	&write_DBorFILE(${$uid.$user}{'mysql'},'',$memberdir,$user,$userext,@tags);
}

sub MemberIndex {
	my ($memaction, $user, $actual_username) = @_;
	return if $user eq '';
	if ($memaction eq "add" && &LoadUser($user)) {
		if (!${$uid.$user}{'postcount'}) { ${$uid.$user}{'postcount'} = 0; }
		if (!${$uid.$user}{'position'})  { ${$uid.$user}{'position'}  = &MemberPostGroup(${$uid.$user}{'postcount'}); }
		&ManageMemberinfo("add", $user, sprintf("%010d", &stringtotime(${$uid.$user}{'regdate'})), ${$uid.$user}{'realname'}, ${$uid.$user}{'email'}, ${$uid.$user}{'position'}, ${$uid.$user}{'postcount'},${$uid.$user}{'bday'});

		$members_total++;
		$last_member = $user;

		require "$admindir/NewSettings.pl";
		&SaveSettingsTo('Settings.pl');

		return 0;

	} elsif ($memaction eq "remove") {
		&ManageMemberinfo("delete", $user);

		require "$sourcedir/Notify.pl";
		&removeNotifications($user);

		my @memberlt = &read_DBorFILE(0,'',$memberdir,'memberinfo','txt');

		$members_total = @memberlt;
		($last_member, undef) = split(/\t/, $memberlt[$#memberlt]);

		require "$admindir/NewSettings.pl";
		&SaveSettingsTo('Settings.pl');

		return 0;

	} elsif ($memaction eq "check_exist") {
		&ManageMemberinfo("load");
		my ($curname, $curmail);
		foreach (keys %memberinf) {
			(undef, $curname, $curmail, undef) = split(/\|/, $memberinf{$_}, 4);
			if (($name_cannot_be_userid || $actual_username eq '' || (!$name_cannot_be_userid && lc $actual_username ne lc $user)) && lc $user eq lc $_) { 
				undef %memberinf; return $_;
			} elsif (lc $user eq lc $curmail) {
				undef %memberinf; return $curmail;
			} elsif (lc $user eq lc $curname) {
				undef %memberinf; return $curname;
			}
		}
		undef %memberinf;

	} elsif ($memaction eq "who_is") {
		&ManageMemberinfo("load");
		my ($curname, $curmail);
		foreach (keys %memberinf) {
			(undef, $curname, $curmail, undef) = split(/\|/, $memberinf{$_}, 4);
			if (lc $user eq lc $curmail || lc $user eq lc $curname) { undef %memberinf; return $_; }
		}
	}
	# if ($memaction eq "rebuild") { ... Deleted! Don't rebuild
	# member list here, or you run into browser/server timeout
	# with xx-large forums!!! Use Admin.pl -> sub RebuildMemList instead!
}

sub MemberPostGroup {
	$userpostcnt = $_[0];
	$grtitle     = "";
	foreach $postamount (sort { $b <=> $a } keys %Post) {
		if ($userpostcnt >= $postamount) {
			($grtitle, undef) = split(/\|/, $Post{$postamount}, 2);
			last;
		}
	}
	return $grtitle;
}

sub RegApprovalCheck {
	## alert admins and gmods of waiting users for approval
	if ($regtype == 1 && ($iamadmin || ($iamgmod && $allow_gmod_admin eq "on" && $gmod_access{'view_reglog'} eq "on"))) {
		opendir(MEM,"$memberdir"); 
		my @approval = (grep /.wait$/i, readdir(MEM));
		closedir(MEM);
		my $app_waiting = $#approval+1;
		if ($app_waiting == 1) {
			$yyadmin_alert .= qq~<div class="editbg">$reg_txt{'admin_alert_start_one'} $app_waiting $reg_txt{'admin_alert_one'} <a href="$boardurl/AdminIndex.$yyaext?action=view_reglog">$reg_txt{'admin_alert_end'}</a></div>~;
		} elsif ($app_waiting > 1) {
			$yyadmin_alert .= qq~<div class="editbg">$reg_txt{'admin_alert_start_more'} $app_waiting $reg_txt{'admin_alert_more'} <a href="$boardurl/AdminIndex.$yyaext?action=view_reglog">$reg_txt{'admin_alert_end_more'}</a></div>~;
		}
	}
	## alert admins and gmods of waiting users for validations
	if (($regtype == 1 || $regtype == 2) && ($iamadmin || ($iamgmod && $allow_gmod_admin eq "on" && $gmod_access{'view_reglog'} eq "on"))) {
		opendir(MEM,"$memberdir"); 
		my @preregged = (grep /.pre$/i, readdir(MEM));
		closedir(MEM);
		my $preregged_waiting = $#preregged+1;
		if ($preregged_waiting == 1) {
			$yyadmin_alert .= qq~<div class="editbg">$reg_txt{'admin_alert_start_one'} $preregged_waiting $reg_txt{'admin_alert_act_one'} <a href="$boardurl/AdminIndex.$yyaext?action=view_reglog">$reg_txt{'admin_alert_act_end'}</a></div>~;
		} elsif ($preregged_waiting > 1) {
			$yyadmin_alert .= qq~<div class="editbg">$reg_txt{'admin_alert_start_more'} $preregged_waiting $reg_txt{'admin_alert_act_more'} <a href="$boardurl/AdminIndex.$yyaext?action=view_reglog">$reg_txt{'admin_alert_act_end_more'}</a></div>~;
		}
	}
}

sub activation_check {
	my ($regtime,$regmember,@outlist);
	my $timespan = $preregspan * 3600;

	# check if user is in pre-registration and check activation key
	foreach (&read_DBorFILE(0,INACT,$memberdir,'memberlist','inactive')) {
		($regtime, undef, $regmember, undef) = split(/\|/, $_, 4);
		if ($date - $regtime > $timespan) {
			&delete_DBorFILE("$memberdir/$regmember.pre");

			# add entry to registration log
			&write_DBorFILE(0,REGLOG,$vardir,'registration','log',(&read_DBorFILE(0,REGLOG,$vardir,'registration','log'),"$date|T|$regmember||$user_ip\n"));
		} else {
			# update non activate user list
			# write valid registration to the list again
			push(@outlist, $_);
		}
	}
	&write_DBorFILE(0,INACT,$memberdir,'memberlist','inactive',@outlist);
}

sub MakeStealthURL {
	# Usage is simple - just call MakeStealthURL with any url, and it will stealthify it.
	# if stealth urls are turned off, it just gives you the same value back
	my $theurl = $_[0];
	if ($stealthurl) {
		$theurl =~ s~([^\w\"\=\[\]]|[\n\b]|\A)\\*(\w+://[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+\.[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%]+[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%])~$boardurl/$yyexec.$yyext?action=dereferer;url=$2~isg;
		$theurl =~ s~([^\"\=\[\]/\:\.(\://\w+)]|[\n\b]|\A)\\*(www\.[^\.][\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+\.[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%]+[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%])~$boardurl/$yyexec.$yyext?action=dereferer;url=http://$2~isg;
	}
	$theurl;
}

sub arraysort {
	# usage: &arraysort(1,"|","R",@array_to_sort);

	my ($sortfield, $delimiter, $reverse, @in) = @_;
	my (@sk, @out, @sortkey, %newline, $oldline, $n);
	foreach $oldline (@in) {
		@sk = split(/$delimiter/, $oldline);
		$sk[$sortfield] = "$sk[$sortfield]-$n";    ## make sure that identical keys are avoided ##
		$n++;
		$newline{ $sk[$sortfield] } = $oldline;
	}
	@sortkey = sort keys %newline;
	if ($reverse) {
		@sortkey = reverse @sortkey;
	}
	foreach (@sortkey) {
		push(@out, $newline{$_});
	}
	return @out;
}

sub keygen {
	## length = output length, type = A (All), U (Uppercase), L (lowercase) ##
	my ($length, $type) = @_;
	if ($length <= 0 || $length > 10000 || !$length) { return; }
	$type = uc($type);
	if ($type ne "A" && $type ne "U" && $type ne "L") { $type = "A"; }

	# generate random ID for password reset or other purposes.
	@chararray = qw(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z);
	my $randid;
	for (my $i; $i < $length; $i++) {
		$randid .= $chararray[int(rand(61))];
	}
	if ($type eq "U") { return uc $randid; } 
	elsif ($type eq "L") { return lc $randid; }
	else { return $randid; }
}

1;