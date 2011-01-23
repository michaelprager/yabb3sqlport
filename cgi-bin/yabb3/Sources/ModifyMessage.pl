###############################################################################
# ModifyMessage.pl                                                            #
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

$modifymessageplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

if (!$post_txt_loaded) {
	&LoadLanguage('Post');
	$post_txt_loaded = 1;
}
&LoadLanguage('FA');
require "$sourcedir/SpamCheck.pl";

sub ModifyMessage {
	if ($iamguest) { &fatal_error("members_only"); }
	if ($currentboard eq '') { &fatal_error("no_access"); }

	my ($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate, $msubject, $mreplyno, $mip, $mmessage, $mns, $mlm, $mlmb);
	$threadid = $INFO{'thread'};
	$postid   = $INFO{'message'};

	my ($filetype_info, $filesize_info, $extensions);
	$extensions = join(" ", @ext);
	$filetype_info = $checkext == 1 ? qq~$fatxt{'2'} $extensions~ : qq~$fatxt{'2'} $fatxt{'4'}~;
	$filesize_info = $limit != 0    ? qq~$fatxt{'3'} $limit KB~   : qq~$fatxt{'3'} $fatxt{'5'}~;

	($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $yyThreadLine);

	$postthread = 2;

	if ($mstate =~ /l/i) {
		my $icanbypass = &checkUserLockBypass if $bypass_lock_perm;
		if (!$icanbypass) { &fatal_error("topic_locked"); }
	} elsif (!$staff && $tlnomodflag && $date > $mdate + ($tlnomodtime * 3600 * 24)) {
		&fatal_error("time_locked","$tlnomodtime$timelocktxt{'02'}");
	}
	if ($postid eq "Poll") {
		unless (&checkfor_DBorFILE("$datadir/$threadid.poll")) { &fatal_error("not_allowed"); }

		my @poll_data = &read_DBorFILE(0,'',$datadir,$threadid,'poll');
		chomp(@poll_data);
		($poll_question, $poll_locked, $poll_uname, $poll_name, $poll_email, $poll_date, $guest_vote, $hide_results, $multi_choice, $poll_mod, $poll_modname, $poll_comment, $vote_limit, $pie_radius, $pie_legends, $poll_end) = split(/\|/, $poll_data[0]);
		&ToChars($poll_question);
		&ToChars($poll_comment);

		for (my $i = 1; $i < @poll_data; $i++) {
			($votes[$i], $options[$i], $slicecolor[$i], $split[$i]) = split(/\|/, $poll_data[$i]);
			&ToChars($options[$i]);
		}

		unless ($poll_uname eq $username || $staff) { &fatal_error("not_allowed"); }

		$poll_comment =~ s~<br \/>~\n~g;
		$poll_comment =~ s~<br>~\n~g;
		$pollthread = 2;
		$settofield = "question";
		$icon = 'poll_mod';

	} else {
		unless (ref($thread_arrayref{$threadid})) {
			@{$thread_arrayref{$threadid}} = &read_DBorFILE(0,'',$datadir,$threadid,'txt');
		}
		($sub, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $message, $mns, $mlm, $mlmb, $mfn) = split(/\|/, ${$thread_arrayref{$threadid}}[$postid]);
		chomp $mfn;

		if ((${$uid.$username}{'regtime'} > $mdate || $musername ne $username) && !$staff) {
			&fatal_error("change_not_allowed");
		}

		$lastmod = $mlm ? &timeformat($mlm) : '-';
		$nscheck = $mns ? ' checked'        : '';

		$lastmod = qq~
<tr>
	<td valign="top" width="23%"><span class="text1"><b>$post_txt{'211'}:</b></span></td>
	<td><span class="text1">$lastmod</span></td>
</tr>
~;
		$icon = $micon;
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
		$message =~ s~<br \/>~\n~ig;
		$message =~ s~<br>~\n~ig;
		$message =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/ig;
		$settofield = "message";
	}
	if ($ENV{'HTTP_USER_AGENT'} =~ /(MSIE) (\d)/) {
		if($2 >= 7.0) { $iecopycheck = ""; } else { $iecopycheck = qq~checked="checked"~; }
	}
	$submittxt = $post_txt{'10'};
	$destination = 'modify2';
	$is_preview  = 0;
	$post = 'postmodify';
	$preview = 'previewmodify';
	require "$sourcedir/Post.pl";
	$yytitle = $post_txt{'66'};
	$mename = $mname;
	&Postpage;
	&template;
}

sub ModifyMessage2 {
	if ($iamguest) { &fatal_error("members_only"); }

	if ($FORM{'previewmodify'}) {
		$mename = qq~$FORM{'mename'}~;
		require "$sourcedir/Post.pl";
		&Preview;
	}

	# the post is to be deleted...
	if ($INFO{'d'} == 1) {
		$threadid = $FORM{'thread'};
		$postid   = $FORM{'id'};

		if ($postid eq "Poll") {
			&fatal_error("not_allowed") unless $staff;

			# First look for a poll.showcase file to delete
			if ($threadid == (&read_DBorFILE(1,'',$datadir,'poll','showcase'))[0]) {
				&delete_DBorFILE("$datadir/poll.showcase");
			}
			# showcase poll end
			&delete_DBorFILE("$datadir/$threadid.poll");
			&delete_DBorFILE("$datadir/$threadid.polled");
			$yySetLocation = qq~$scripturl?num=$threadid~;
			&redirectexit;

		} else {
			unless (ref($thread_arrayref{$threadid})) {
				@{$thread_arrayref{$threadid}} = &read_DBorFILE(0,'',$datadir,$threadid,'txt');
			}
			$msgcnt = @{$thread_arrayref{$threadid}};

			# Make sure the user is allowed to edit this post.
			if ($postid >= 0 && $postid < $msgcnt) {
				($msub, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $mmessage, $mns, $mlm, $mlmb, $mfn) = split(/\|/, ${$thread_arrayref{$threadid}}[$postid]);
				chomp $mfn;
				if (${$uid.$username}{'regdate'} > $mdate || (!$staff && $musername ne $username)) { &fatal_error("delete_not_allowed"); }
				if (!$staff && $tlnodelflag && $date > $mdate + ($tlnodeltime * 3600 * 24)) { &fatal_error("time_locked","$tlnodeltime$timelocktxt{'02a'}"); }
			} else {
				&fatal_error("bad_postnumber",$postid);
			}
			$iamposter = ($musername eq $username && $msgcnt == 1) ? 1 : 0;
			$FORM{"del$postid"} = 1;
			&MultiDel;
		}
	}

	my ($threadid, $postid, $msub, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $mmessage, $mns, $mlm, $mlmb, $tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate, @threads, $tmpa, $tmpb, $newlastposttime, $newlastposter, $lastpostid, $views, $name, $email, $subject, $message, $ns,);

	$threadid   = $FORM{'threadid'};
	$postid     = $FORM{'postid'};
	$pollthread = $FORM{'pollthread'};

	if ($pollthread) {
		$maxpq          ||= 60;
		$maxpo          ||= 50;
		$maxpc          ||= 0;
		$numpolloptions ||= 8;
		$vote_limit     ||= 0;

		unless (&checkfor_DBorFILE("$datadir/$threadid.poll")) { &fatal_error("not_allowed"); }

		my @poll_data = &read_DBorFILE(0,'',$datadir,$threadid,'poll');
		chomp($poll_data);
		($poll_question, $poll_locked, $poll_uname, $poll_name, $poll_email, $poll_date, $guest_vote, $hide_results, $multi_choice, $poll_mod, $poll_modname, $poll_comment, $vote_limit, $pie_radius, $pie_legends, $poll_end) = split(/\|/, $poll_data[0]);

		unless ($poll_uname eq $username || $staff) { &fatal_error("not_allowed"); }

		my $numcount = 0;
		unless ($FORM{"question"}) { &fatal_error("no_question"); }
		$FORM{"question"} =~ s/\&nbsp;/ /g;
		my $testspaces = $FORM{"question"};
		$testspaces =~ s/[\r\n\ ]//g;
		$testspaces =~ s/\&nbsp;//g;
		$testspaces =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
		$testspaces =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;
		$testspaces =~ s/\[.*?\]//g;
		if (length($testspaces) == 0 && length($FORM{"question"}) > 0) { fatal_error("useless_post","$testspaces"); }

		$poll_question = $FORM{"question"};
		&FromChars($poll_question);
		$convertstr = $poll_question;
		$convertcut = $maxpq;
		&CountChars;
		$poll_question = $convertstr;
		if ($cliped) { &fatal_error("error_occurred","$post_polltxt{'40'} $post_polltxt{'34a'} $maxpq $post_polltxt{'34b'} $post_polltxt{'36'}"); }
		&ToHTML($poll_question);

		$guest_vote   = $FORM{'guest_vote'}   || 0;
		$hide_results = $FORM{'hide_results'} || 0;
		$multi_choice = $FORM{'multi_choice'} || 0;
		$poll_comment = $FORM{'poll_comment'} || "";
		$vote_limit   = $FORM{'vote_limit'}   || 0;
		$pie_legends  = $FORM{'pie_legends'}  || 0;
		$pie_radius   = $FORM{'pie_radius'}   || 100;
		$poll_end_days = $FORM{'poll_end_days'};
		$poll_end_min  = $FORM{'poll_end_min'};

		if ($pie_radius =~ /\D/) { $pie_radius = 100; }
		if ($pie_radius < 100)   { $pie_radius = 100; }
		if ($pie_radius > 200)   { $pie_radius = 200; }

		if ($vote_limit =~ /\D/) { $vote_limit = 0; &fatal_error("only_numbers_allowed","$post_polltxt{'62'}"); }

		&FromChars($poll_comment);
		$convertstr = $poll_comment;
		$convertcut = $maxpc;
		&CountChars;
		$poll_comment = $convertstr;
		if ($cliped) { &fatal_error("error_occurred","$post_polltxt{'57'} $post_polltxt{'34a'} $maxpc $post_polltxt{'34b'} $post_polltxt{'36'}"); }
		&ToHTML($poll_comment);
		$poll_comment =~ s~\n~<br />~g;
		$poll_comment =~ s~\r~~g;

		$poll_end_days = '' if !$poll_end_days || $poll_end_days =~ /\D/;
		$poll_end_min  = '' if !$poll_end_min  || $poll_end_min =~ /\D/;
		my $poll_end = $poll_end_days * 86400 if $poll_end_days;
		$poll_end += $poll_end_min * 60 if $poll_end_min;
		$poll_end += $date if $poll_end;

		my @new_poll_data;
		push @new_poll_data, qq~$poll_question|$poll_locked|$poll_uname|$poll_name|$poll_email|$poll_date|$guest_vote|$hide_results|$multi_choice|$date|$username|$poll_comment|$vote_limit|$pie_radius|$pie_legends|$poll_end\n~;

		for ($i = 1; $i <= $numpolloptions; $i++) {
			($votes, undef) = split(/\|/, $poll_data[$i], 2);
			if (!$votes) { $votes = "0"; }
			if ($FORM{"option$i"}) {
				$FORM{"option$i"} =~ s/\&nbsp;/ /g;
				my $testspaces = $FORM{"option$i"};
				$testspaces =~ s/[\r\n\ ]//g;
				$testspaces =~ s/\&nbsp;//g;
				$testspaces =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
				$testspaces =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;
				$testspaces =~ s/\[.*?\]//g;
				if (!length($testspaces)) { fatal_error("useless_post","$testspaces"); }

				&FromChars($FORM{"option$i"});
				$convertstr = $FORM{"option$i"};
				$convertcut = $maxpo;
				&CountChars;
				$FORM{"option$i"} = $convertstr;
				if ($cliped) { &fatal_error("error_occurred","$post_polltxt{'7'} $i $post_polltxt{'34a'} $maxpo $post_polltxt{'34b'} $post_polltxt{'36'}"); }

				&ToHTML($FORM{"option$i"});
				$numcount++;
				push @new_poll_data, qq~$votes|$FORM{"option$i"}|$FORM{"slicecol$i"}|$FORM{"split$i"}\n~;
			}
		}
		if ($numcount < 2) { &fatal_error("no_options"); }

		# showcase poll start
		if ($iamadmin || $iamgmod) {
			if ($threadid == (&read_DBorFILE(1,'',$datadir,'poll','showcase'))[0] && !$FORM{'scpoll'}) {
				&delete_DBorFILE("$datadir/poll.showcase");
			} elsif ($FORM{'scpoll'}) {
				&write_DBorFILE(1,'',$datadir,'poll','showcase',($threadid));
			}
		}
		# showcase poll end

		&write_DBorFILE(1,'',$datadir,$threadid,'poll',@new_poll_data);

		$yySetLocation = qq~$scripturl?num=$threadid~;

		&redirectexit;
	}

	unless (ref($thread_arrayref{$threadid})) {
		@{$thread_arrayref{$threadid}} = &read_DBorFILE(0,'',$datadir,$threadid,'txt');
	}

	# Make sure the user is allowed to edit this post.
	if ($postid >= 0 && $postid < @{$thread_arrayref{$threadid}}) {
		($msub, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $mmessage, $mns, $mlm, $mlmb, $mfn) = split(/\|/, ${$thread_arrayref{$threadid}}[$postid]);
		chomp $mfn;
		unless ((${$uid.$username}{'regdate'} < $mdate && $musername eq $username) || $staff) {
			&fatal_error("change_not_allowed");
		}
	} else {
		&fatal_error("bad_postnumber","$postid");
	}

	($tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate) = split(/\|/, $yyThreadLine);

	$postthread = 2 if $postid;

	# the post is to be modified...
	$name    = $FORM{'name'};
	$email   = $FORM{'email'};
	$subject = $FORM{'subject'};
	$message = $FORM{'message'};
	$icon    = $FORM{'icon'};
	$ns      = $FORM{'ns'};
	$notify  = $FORM{'notify'};
	$thestatus = $FORM{'topicstatus'};
	$thestatus =~ s/\, //g;
	&CheckIcon;

	&fatal_error("no_message") unless ($message);

	$spamdetected = &spamcheck("$subject $message");
	if (!${$uid.$FORM{$username}}{'spamcount'}) { ${$uid.$FORM{$username}}{'spamcount'} = 0; }
	$postspeed = $date - $posttime;
	if (!$staff){
		if (($speedpostdetection && $postspeed < $min_post_speed) || $spamdetected == 1) {
			${$uid.$username}{'spamcount'}++;
			${$uid.$username}{'spamtime'} = $date;
			&UserAccount($username,"update");
			$spam_hits_left_count = $post_speed_count - ${$uid.$username}{'spamcount'};
			if ($spamdetected == 1){ &fatal_error("tsc_alert"); } else { &fatal_error("speed_alert"); }
		}
	}

	my $mess_len = $message;
	$mess_len =~ s/[\r\n ]//ig;
	$mess_len =~ s/&#\d{3,}?\;/X/ig;
	if (length($mess_len) > $MaxMessLen) {
		require "$sourcedir/Post.pl";
		&Preview($post_txt{'536'} . " " . (length($mess_len) - $MaxMessLen) . " " . $post_txt{'537'});
	}
	undef $mess_len;

	&FromChars($subject);
	$convertstr = $subject;
	$convertcut = $set_subjectMaxLength + ($subject =~ /^Re: / ? 4 : 0);
 	&CountChars;
	$subject = $convertstr;
	&ToHTML($subject);

	&ToHTML($name);
	$email =~ s/\|//g;
	&ToHTML($email);
	&fatal_error("no_subject") unless ($subject && $subject !~ m~\A[\s_.,]+\Z~);
	my $testmessage = $message;
	&ToChars($testmessage);
	$testmessage =~ s/[\r\n\ ]//g;
	$testmessage =~ s/\&nbsp;//g;
	$testmessage =~ s~\[table\].*?\[tr\].*?\[td\]~~g;
	$testmessage =~ s~\[/td\].*?\[/tr\].*?\[/table\]~~g;
	$testmessage =~ s/\[.*?\]//g;
	if ($testmessage eq "" && $message ne "" && $pollthread != 2) { fatal_error("useless_post","$testmessage"); }

	if (!$minlinkpost){ $minlinkpost = 0 ;}
	if (${$uid.$username}{'postcount'} < $minlinkpost && !$staff && !$iamguest) { 
		if ($message =~ m~http:\/\/~ || $message =~ m~https:\/\/~ || $message =~ m~ftp:\/\/~ || $message =~ m~www.~ || $message =~ m~ftp.~ =~ m~\[url~ || $message=~ m~\[link~ || $message=~ m~\[img~ || $message=~ m~\[ftp~) {
			&fatal_error("no_links_allowed");
		}
	}

	&FromChars($message);
	$message =~ s/\cM//g;
	$message =~ s~\[([^\]]{0,30})\n([^\]]{0,30})\]~\[$1$2\]~g;
	$message =~ s~\[/([^\]]{0,30})\n([^\]]{0,30})\]~\[/$1$2\]~g;
	$message =~ s~(\w+://[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)~$1\n$2~g;
	&ToHTML($message);
	$message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/g;
	$message =~ s~\n~<br />~g;
	if ($postid == 0) {
		$tsub  = $subject;
		$ticon = $icon;
	}

	if ($tstate =~ /l/i) {
		my $icanbypass = &checkUserLockBypass if $bypass_lock_perm;
		if (!$icanbypass) { &fatal_error('topic_locked');}
	}
	if ($iammod || $iamgmod || $iamadmin) {
		$thestatus =~ s/0//g;
		$tstate = $tstate =~ /a/i ? "0a$thestatus" : "0$thestatus";
		&MessageTotals("load", $tnum);
		${$tnum}{'threadstatus'} = $tstate;
		&MessageTotals("update", $tnum);
	}

	$yyThreadLine = qq~$tnum|$tsub|$tname|$temail|$tdate|$treplies|$tusername|$ticon|$tstate~;

	if ($mip =~ /$user_ip/) { $useredit_ip = $mip; }
	else { $useredit_ip = "$mip $user_ip"; }

	my (@attachments,%post_attach,%del_filename);
	foreach (&read_DBorFILE(0,ATM,$vardir,'attachments','txt')) {
		$_ =~ /^(\d+)\|(\d+)\|.+\|(.+)\|\d+\s+/;
		$del_filename{$3}++;
		if ($threadid == $1 && $postid == $2) {
			$post_attach{$3} = $_;
		} else {
			push(@attachments, $_);
		}
	}

	my ($file,$fixfile,@filelist,@newfilelist,@attachmentsfile);
	for (my $y = 1; $y <= $allowattach; ++$y) {
		$file = $CGI_query->upload("file$y") if $CGI_query;
		if ($file && ($FORM{"w_file$y"} eq "attachnew" || !exists $FORM{"w_file$y"})) {
			$fixfile = $file;
			$fixfile =~ s/.+\\([^\\]+)$|.+\/([^\/]+)$/$1/;
			$fixfile =~ s/[^0-9A-Za-z\+\-\.:_]/_/g; # replace all inappropriate with the "_" character.

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
					foreach (@newfilelist) { &delete_DBorFILE("$uploaddir/$_"); }
					&fatal_error("tsc_alert");
				}
			}

			$fixext  =~ s/\.(pl|pm|cgi|php)/._$1/i;
			$fixname =~ s/\./_/g;
			$fixfile = qq~$fixname$fixext~;

			&delete_DBorFILE(qq~$uploaddir/$FORM{"w_filename$y"}~) if $FORM{"w_filename$y"};
			if (!$overwrite) { $fixfile = &check_existence($uploaddir, $fixfile); }
			elsif ($overwrite == 2 && &checkfor_DBorFILE("$uploaddir/$fixfile")) {
				foreach (@newfilelist) { &delete_DBorFILE("$uploaddir/$_"); }
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
				unless ($allowattach && (($allowguestattach == 0 && $username ne 'Guest') || $allowguestattach == 1)) {
					foreach (@newfilelist) { &delete_DBorFILE("$uploaddir/$_"); }
					&fatal_error("no_perm_att");
				}
			} else {
				foreach (@newfilelist) { &delete_DBorFILE("$uploaddir/$_"); }
				require "$sourcedir/Post.pl";
				&Preview("$fixfile $fatxt{'20'} @ext");
			}

			my ($size,$buffer,$filesize,$file_buffer);
			while ($size = read($file, $buffer, 512)) { $filesize += $size; $file_buffer .= $buffer; }
			if ($limit && $filesize > (1024 * $limit)) {
				foreach (@newfilelist) { &delete_DBorFILE("$uploaddir/$_"); }
				require "$sourcedir/Post.pl";
				&Preview("$fatxt{'21'} $fixfile (" . int($filesize / 1024) . " KB) $fatxt{'21b'} " . $limit);
			}
			if ($dirlimit) {
				my $dirsize = &dirsize($uploaddir);
				if ($filesize > ((1024 * $dirlimit) - $dirsize)) {
					foreach (@newfilelist) { &delete_DBorFILE("$uploaddir/$_"); }
					require "$sourcedir/Post.pl";
					&Preview("$fatxt{'22'} $fixfile (" . (int($filesize / 1024) - $dirlimit + int($dirsize / 1024)) . " KB) $fatxt{'22b'}");
				}
			}

			# create a new file on the server using the formatted ( new instance ) filename
			if (fopen(NEWFILE, ">$uploaddir/$fixfile")) {
				binmode NEWFILE; # needed for operating systems (OS) Windows, ignored by Linux
				print NEWFILE $file_buffer; # write new file on HD
				fclose(NEWFILE);

			} else { # return the server's error message if the new file could not be created
				foreach (@newfilelist) { &delete_DBorFILE("$uploaddir/$_"); }
				&fatal_error("file_not_open","$uploaddir");
			}

			# check if file has actually been uploaded, by checking the file has a size
			my $filesizekb = -s "$uploaddir/$fixfile";
			unless ($filesizekb) {
				foreach (qw("@newfilelist" $fixfile)) { &delete_DBorFILE("$uploaddir/$_"); }
				&fatal_error("file_not_uploaded",$fixfile);
			}
			$filesizekb = int($filesizekb / 1024);

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
					foreach (qw("@newfilelist" $fixfile)) { &delete_DBorFILE("$uploaddir/$_"); }
					&fatal_error("file_not_uploaded","$fixfile <= illegal code inside image file!");
				}
			}

			push(@newfilelist, $fixfile);
			push(@filelist, $fixfile);
			push(@attachments, qq~$threadid|$postid|$subject|$mname|$currentboard|$filesizekb|$date|$fixfile|0\n~);

		} elsif ($FORM{"w_filename$y"}) {
			if ($FORM{"w_file$y"} eq "attachdel") {
				&delete_DBorFILE(qq~$uploaddir/$FORM{"w_filename$y"}~) if $del_filename{$FORM{"w_filename$y"}} == 1;
				$del_filename{$FORM{"w_filename$y"}}--;
			} elsif ($FORM{"w_file$y"} eq "attachold") {
				push(@filelist, $FORM{"w_filename$y"});
				push(@attachments, $post_attach{$FORM{"w_filename$y"}});
			}
		}
	}
	# Print attachments.txt
	&write_DBorFILE(0,ATM,$vardir,'attachments','txt',sort( { (split /\|/,$a)[6] <=> (split /\|/,$b)[6] } @attachments ));

	# Create the list of files
	$fixfile = join(",", @filelist);

	${$thread_arrayref{$threadid}}[$postid] = qq~$subject|$mname|$memail|$mdate|$musername|$icon|$mreplyno|$useredit_ip|$message|$ns|$date|$username|$fixfile\n~;
	&write_DBorFILE(0,'',$datadir,$threadid,'txt',@{$thread_arrayref{$threadid}});

	if ($postid == 0 || $iammod || $iamgmod || $iamadmin) {
		# Save the current board. icon, status or subject may have changed -> update board info
		my @board = &read_DBorFILE(0,FILE,$boardsdir,$currentboard,'txt');
		for (my $a = 0; $a < @board; $a++) {
			if ($board[$a] =~ m~\A$threadid\|~o) { $board[$a] = "$yyThreadLine\n"; last; }
		}
		&write_DBorFILE(0,FILE,$boardsdir,$currentboard,'txt',@board);

		&BoardSetLastInfo($currentboard,\@board);

	} elsif ($postid == $#{$thread_arrayref{$threadid}}) {
		# maybe last message changed subject and/or icon -> update board info
		my @board = &read_DBorFILE(0,'',$boardsdir,$currentboard,'txt');
		&BoardSetLastInfo($currentboard,\@board);
	}

	require "$sourcedir/Notify.pl";
	if ($notify) {
		&ManageThreadNotify("add", $threadid, $username, ${$uid.$username}{'language'}, 1, 1);
	} else {
		&ManageThreadNotify("delete", $threadid, $username);
	}

	if (${$uid.$username}{'postlayout'} ne "$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}") {
		${$uid.$username}{'postlayout'} = "$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}";
		&UserAccount($username, "update");
	}

	my $start = !$ttsreverse ? (int($postid / $maxmessagedisplay) * $maxmessagedisplay) : $treplies - (int(($treplies - $postid) / $maxmessagedisplay) * $maxmessagedisplay);
	$yySetLocation = qq~$scripturl?num=$threadid/$start#$postid~;
	&redirectexit;
}

sub MultiDel { # deletes singel- or multi-Posts
	$thread = $INFO{'thread'};

	unless (ref($thread_arrayref{$thread})) {
		@{$thread_arrayref{$thread}} = &read_DBorFILE(0,'',$datadir,$thread,'txt');
	}
	my @messages = @{$thread_arrayref{$thread}};

	# check all checkboxes, delete posts if checkbox is ticked
	my $kill = 0;
	my $postid;
	for ($count = $#messages; $count >= 0; $count--) {
		if ($FORM{"del$count"} ne '' || $INFO{"del$count"} ne '') {
			chomp $messages[$count];
			@message = split(/\|/, $messages[$count]);
			$musername = $message[4];

			# Checks that the user is actually allowed to access multidel
			if (${$uid.$username}{'regdate'} > $message[3] || (!$staff && $musername ne $username)) { &fatal_error("delete_not_allowed"); }
			if (!$staff && $tlnodelflag && $date > $message[3] + ($tlnodeltime * 3600 * 24)) { &fatal_error("time_locked","$tlnodeltime$timelocktxt{'02a'}"); }

			if ($message[12]) { # delete post attachments
				require "$admindir/Attachments.pl";
				my %remattach;
				$message[12] =~ s/,/|/g;
				$remattach{$thread} = $message[12];
				&RemoveAttachments(\%remattach);
			}

			splice(@messages, $count, 1);
			$kill++;
			$postid = $count if $kill == 1;

			# decrease members post count if not in a zero post count board
			unless (${$uid.$currentboard}{'zero'} || $musername eq 'Guest' || $message[5] eq 'no_postcount' || $message[6] eq 'no_postcount') {
				if (!${$uid.$musername}{'password'}) {
					&LoadUser($musername);
				}
				if (${$uid.$musername}{'postcount'} > 0) {
					${$uid.$musername}{'postcount'}--;
					&UserAccount($musername, "update");
				}
				if (${$uid.$musername}{'position'}) {
					$grp_after = qq~${$uid.$musername}{'position'}~;
				} else {
					foreach $postamount (sort { $b <=> $a } keys %Post) {
						if (${$uid.$musername}{'postcount'} > $postamount) {
							($grp_after, undef) = split(/\|/, $Post{$postamount}, 2);
							last;
						}
					}
				}
				&ManageMemberinfo("update", $musername, '', '', '', $grp_after, ${$uid.$musername}{'postcount'});

				my ($md,$mu,$mdmu);
				foreach (reverse @messages) {
					(undef, undef, undef, $md, $mu, undef) = split(/\|/, $_, 6);
					if ($mu eq $musername) { $mdmu = $md; last; }
				}
				&Recent_Write("decr", $thread, $musername, $mdmu);
			}
		}
	}

	if (!@messages) {
		# all post was deleted, call removethread
		require "$sourcedir/Favorites.pl";
		$INFO{'ref'} = "delete";
		&RemFav($thread);

		require "$sourcedir/RemoveTopic.pl";
		$iamposter = ($message[4] eq $username) ? 1 : 0;
		&DeleteThread($thread);
	}
	for ($count = 0; $count < @messages; $count++) {
		@message = split(/\|/, $messages[$count]);
		$message[6] = $count;
		$messages[$count] = join('|', @message);
	}
	@{$thread_arrayref{$thread}} = @messages;

	# if thread has not been deleted: update thread, update message index details ...
	&write_DBorFILE(0,'',$datadir,$thread,'txt',@{$thread_arrayref{$thread}});

	my @firstmessage = split(/\|/, ${$thread_arrayref{$thread}}[0]);
	my @lastmessage  = split(/\|/, ${$thread_arrayref{$thread}}[$#{$thread_arrayref{$thread}}]);

	# update the current thread
	&MessageTotals("load", $thread);
	${$thread}{'replies'} = $#{$thread_arrayref{$thread}};
	${$thread}{'lastposter'} = $lastmessage[4] eq "Guest" ? qq~Guest-$lastmessage[1]~ : $lastmessage[4];
	&MessageTotals("update", $thread);

	# update the current board.
	&BoardTotals("load", $currentboard);
	${$uid.$currentboard}{'messagecount'} -= $kill;
	# &BoardTotals("update", ...) is done later in &BoardSetLastInfo

	my @buffer = &read_DBorFILE(0,BOARDFILE,$boardsdir,$currentboard,'txt');

	my ($a,$threadline);
	for ($a = 0; $a < @buffer; $a++) {
		if ($buffer[$a] =~ /^$thread\|/) {
			$threadline = $buffer[$a];
			splice(@buffer, $a, 1);
			last;
		}
	}

	chomp $threadline;
	my @newthreadline = split(/\|/, $threadline);
	$newthreadline[1] = $firstmessage[0];         # subject of first message
	$newthreadline[7] = $firstmessage[5];         # icon of first message
	$newthreadline[4] = $lastmessage[3];          # date of last message
	$newthreadline[5] = ${$thread}{'replies'};    # replay number

	my $inserted = 0;
	for ($a = 0; $a < @buffer; $a++) {
		if ((split(/\|/, $buffer[$a], 6))[4] < $newthreadline[4]) {
			splice(@buffer,$a,0,join("|", @newthreadline) . "\n");
			$inserted = 1;
			last;
		}
	}
	if (!$inserted) { push(@buffer, join("|", @newthreadline) . "\n"); }
	&write_DBorFILE(0,BOARDFILE,$boardsdir,$currentboard,'txt',@buffer);

	&BoardSetLastInfo($currentboard,\@buffer);

	if ($INFO{'recent'}) {
		$yySetLocation = qq~$scripturl?action=recent~;
	} else {
		$postid = $postid > ${$thread}{'replies'} ? ${$thread}{'replies'} : ($postid - 1);
		my $start = !$ttsreverse ? (int($postid / $maxmessagedisplay) * $maxmessagedisplay) : ${$thread}{'replies'} - (int((${$thread}{'replies'} - $postid) / $maxmessagedisplay) * $maxmessagedisplay);
		$yySetLocation = qq~$scripturl?num=$thread/$start#$postid~;
	}

	&redirectexit;
}

1;