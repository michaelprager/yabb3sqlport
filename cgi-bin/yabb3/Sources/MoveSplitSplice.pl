###############################################################################
# MoveSplitSplice.pl                                                          #
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

$movesplitspliceplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('MoveSplitSplice');

sub Split_Splice {
	if (!$staff) { &fatal_error("split_splice_not_allowed"); }
	&Split_Splice_2 if $FORM{'ss_submit'} || $INFO{'ss_submit'};

	$output = qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$sstxt{'1'}</title>
<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />
<link rel="stylesheet" href="$forumstylesurl/$usestyle.css" type="text/css" />

</head>
<body>
<a name="pagetop">&nbsp;</a><br />
<div id="maincontainer">
<div id="container">
<br />
<br />~;

	my $curboard  = $INFO{'board'};
	my $curthread = $INFO{'thread'};
	unless (exists $FORM{'oldposts'}) { $FORM{'oldposts'} = $INFO{'oldposts'}; }
	unless (exists $FORM{'leave'})    { $FORM{'leave'} = $INFO{'leave'}; }
	if     (exists $INFO{'newinfo'})  { $FORM{'newinfo'} = $INFO{'newinfo'}; }
	my $newcat    = $FORM{'newcat'} || $INFO{'newcat'};
	my $newboard  = $FORM{'newboard'} || $INFO{'newboard'};
	unless (exists $FORM{'newthread'}) { $FORM{'newthread'} = $INFO{'newthread'}; }
	my $newthread = $FORM{'newthread'} || "new";
	unless (exists $FORM{'newthread_subject'}) { $FORM{'newthread_subject'} = $INFO{'newthread_subject'}; }
	unless (exists $FORM{'position'})          { $FORM{'position'} = $INFO{'position'}; }

	require "$sourcedir/YaBBC.pl";
	&LoadCensorList;

	# Get posts of current thread
	unless (ref($thread_arrayref{$curthread})) {
		@{$thread_arrayref{$curthread}} = &read_DBorFILE(1,'',$datadir,$curthread,'txt');
	}
	my @messages = @{$thread_arrayref{$curthread}};

	my ($counter,$size1);
	for ($counter = 0; $counter < @messages; $counter++) {
		$message = (split(/\|/, $messages[$counter], 10))[8];
		($message, undef) = &Split_Splice_Move($message,1);
		&DoUBBC;

		$convertstr = $message;
		$convertcut = 50;
		&CountChars;
		$message = $convertstr;
		$message .= " ..." if $cliped;

		&ToChars($message);
		$message =~ s/<(p|br|div).*?>/ /g;
		$message =~ s/<.*?>//g; # remove HTML-tags
		$message = &Censor($message);

		$messages[$counter] = qq~<option value="$counter" ~ . ($FORM{'oldposts'} =~ /\b$counter\b/ ? q~selected="selected"~ : '') . qq~>~ . ($counter ? "$sstxt{'40'} $counter" : $sstxt{'41'}) . qq~: $message</option>\n~;
	}
	@messages = reverse(@messages) if ($ttsureverse && ${$uid.$username}{'reversetopic'}) || $ttsreverse;
	my $postlist = ($FORM{'oldposts'} eq "all" ? qq~<option value="all" selected="selected">$sstxt{'26'}</option>\n~ : qq~<option value="all">$sstxt{'26'}</option>\n~) . join('', @messages);
	$size1 = @messages + 1;
	$size1 = $size1 > 10 ? 10 : $size1; # maximum size of multiselect field

	# List of options of what, if anything, to leave in place of the posts moved
	my @leaveopts = ($sstxt{'11'}, $sstxt{'12'}, $sstxt{'13'});
	for ($counter = 0; $counter < @leaveopts; $counter++) {
		$leavelist .= qq~<option value="$counter" ~ . ($FORM{'leave'} == $counter ? q~selected="selected"~ : '') . qq~>$leaveopts[$counter]</option>\n~;
	}

	# Get categories and make the current one the default selection
	my $catlist = qq~<option value="cats" >$sstxt{'28'}</option>\n~;
	foreach (@categoryorder) {
		my ($catname, $catperms) = split(/\|/, $catinfo{$_}, 3);
		next if !&CatAccess($catperms);
		$catlist .= qq~<option value="$_" ~ . ($newcat eq $_ ? q~selected="selected"~ : '') . qq~>$catname</option>\n~;
	}

	# Get boards and make the current one the default selection
	$boardlist = qq~<option value="boards" >$sstxt{'29'}</option>\n~;
	
	my $indent = -2;

	&get_subboards(split (/,/, $cat{$newcat}));
	sub get_subboards {
		$indent += 2;
		foreach $childbd (@_) {
			my $dash;
			if($indent > 0) { $dash = "-"; }
			my ($boardname, $boardperms) = split(/\|/, $board{$childbd}, 3);
			my $access = &AccessCheck($_, '', $boardperms);
			next if !$iamadmin && $access ne "granted" && $boardview != 1;
			
			$boardlist .= qq~<option value="$childbd" ~ . ($newboard eq $childbd ? q~selected="selected"~ : '') . qq~>~ . ("&nbsp;" x $indent) . ($dash x ($indent / 2)) . qq~&nbsp;$boardname</option>\n~;
			if($subboard{$childbd}) {
				&get_subboards(split(/\|/,$subboard{$childbd}));
			}
		}
		$indent -= 2;
	}

	# Get threads and make the current one the default selection
	my ($threadlist,$threadids,$positionlist);
	#if ($cat{$newcat} =~ /\b$newboard\b/) {
		my @threads = &read_DBorFILE(1,'',$boardsdir,$newboard,'txt');

		$threadlist = qq~<option value="new">$sstxt{'30'}</option>\n~;
		my $threadid;
		foreach (@threads) {
			($threadid, $message, undef) = split(/\|/, $_, 3);
			next if $curthread eq $threadid;
			$threadids .= "$threadid,";

			($message, undef) = &Split_Splice_Move($message,$threadid);
			&DoUBBC;

			$convertstr = $message;
			$convertcut = 50;
			&CountChars;
			$message = $convertstr;
			$message .= " ..." if $cliped;

			&ToChars($message);
			$message =~ s/<(p|br|div).*?>/ /g;
			$message =~ s/<.*?>//g; # remove HTML-tags
			$message = &Censor($message);

			$threadlist .= qq~<option value="$threadid" ~ . ($newthread eq $threadid ? q~selected="selected"~ : '') . qq~>$message</option>\n~;
		}

		# Get new thread posts to select splice site
		if ($FORM{'newthread'} ne "new") {
			unless (ref($thread_arrayref{$newthread})) {
				@{$thread_arrayref{$newthread}} = &read_DBorFILE(1,'',$datadir,$newthread,'txt');
			}
			@messages = @{$thread_arrayref{$newthread}};

			for ($counter = 0; $counter < @messages; $counter++) {
				$message = (split(/[\|]/, $messages[$counter], 10))[8];
				($message, undef) = &Split_Splice_Move($message,1);
				&DoUBBC;

				$convertstr = $message;
				$convertcut = 50;
				&CountChars;
				$message = $convertstr;
				$message .= " ..." if $cliped;

				&ToChars($message);
				$message =~ s/<(p|br|div).*?>/ /g;
				$message =~ s/<.*?>//g; # remove HTML-tags
				$message = &Censor($message);

				$messages[$counter] = qq~<option value="$counter">~ . ($counter ? "$sstxt{'40'} $counter" : $sstxt{'41'}) . qq~: $message</option>\n~;
			}
			@messages = reverse(@messages) if ($ttsureverse && ${$uid.$username}{'reversetopic'}) || $ttsreverse;
			$positionlist = qq~<option value="end">$sstxt{'31'}</option>\n~;
			$positionlist .= qq~<option value="begin">$sstxt{'32'}</option>\n~ . join('', @messages);
			if ($FORM{'position'} && $newthread == $FORM{'old_position_thread'}) {
				$positionlist =~ s/(value="$FORM{'position'}")/$1 selected="selected"/;
			}
		}
	#}

	$output .= qq~
<script language="JavaScript1.2" src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
<form action="$scripturl?action=split_splice;board=$currentboard;thread=$INFO{'thread'}" method="post" name="split_splice" onsubmit="return submitproc()">
<input type="hidden" name="formsession" value="$formsession" />
<table border="0" cellspacing="0" cellpadding="0" class="tabtitle" align="center" width="90%" height="30">
	<tr>
		<td class="round_top_left" width="1%">&nbsp;</td>
		<td align="left" valign="middle"><img src="$defaultimagesdir/admin_move_split_splice.gif" alt="$sstxt{'1'}" /> <b>$sstxt{'1'}</b></td>
		<td class="round_top_right" width="1%">&nbsp;</td>
	</tr>
</table>
<table border="0" cellspacing="1" cellpadding="8" class="bordercolor" align="center" width="90%">
	<tr>
		<td class="catbg"><b>$sstxt{'2'}:</b></td>
	</tr><tr>
		<td class="windowbg"><b>$sstxt{'3'}</b></td>
	</tr><tr>
		<td class="windowbg2">
			<label for="oldposts">$sstxt{'14'}<br />
			<select name="oldposts" id="oldposts" size="$size1" multiple="multiple">$postlist</select><br />
			<span class="small">$sstxt{'14a'}</span></label>
		</td>
	</tr><tr>
		<td class="windowbg"><b>$sstxt{'4'}</b></td>
	</tr><tr>
		<td class="windowbg2">
			<label for="leave">$sstxt{'15'}</label><br />
			<select name="leave" id="leave">$leavelist</select>
		</td>
	</tr><tr>
		<td class="catbg"><b>$sstxt{'5'}:</b></td>
	</tr><tr>
		<td class="windowbg"><b>$sstxt{'6'}</b></td>
	</tr><tr>
		<td class="windowbg2">
			<label for="newcat">$sstxt{'16'}</label><br />
			<select name="newcat" id="newcat" onchange="document.split_splice.submit();">$catlist</select>
		</td>
	</tr><tr>
		<td class="windowbg"><b>$sstxt{'7'}</b></td>
	</tr><tr>
		<td class="windowbg2">
			<label for="newboard">$sstxt{'17'}</label><br />
			<select name="newboard" id="newboard" onchange="document.split_splice.submit();">$boardlist</select>
		</td>
	</tr><tr>
		<td class="windowbg"><b>$sstxt{'8'}</b></td>
	</tr><tr>
		<td class="windowbg2">
			<label for="newthread">$sstxt{'18'}</label><br />
			<select name="newthread" id="newthread" onchange="document.split_splice.submit();">$threadlist</select>
		</td>
	</tr>~;

	if ($newthread eq "new" || !$threadlist || $threadids !~ /\b$newthread\b/){
		$output .= qq~<tr>
		<td class="windowbg"><b>$sstxt{'9'}</b></td>
	</tr><tr>
		<td class="windowbg2">
			<label for="newthread_subject">$sstxt{'20'}</label><br />
			<input type="text" name="newthread_subject" id="newthread_subject" size="50" value="$FORM{'newthread_subject'}" />
			<input type="hidden" name="position" value="$FORM{'position'}" />
			<input type="hidden" name="old_position_thread" value="$FORM{'old_position_thread'}" />
		</td>
	</tr>~;

	} else {
		$output .= qq~<tr>
		<td class="windowbg"><b>$sstxt{'10'}</b></td>
	</tr><tr>
		<td class="windowbg2">
			<label for="position">$sstxt{'19'}</label><br />
			<select name="position" id="position">$positionlist</select>
			<input type="hidden" name="newthread_subject" value="$FORM{'newthread_subject'}" />
			<input type="hidden" name="old_position_thread" value="$newthread" />
		</td>
	</tr>~;
	}

	$output .= qq~<tr>
		<td class="windowbg"><b>$sstxt{'4'}</b></td>
	</tr><tr>
		<td class="windowbg2">
			<input type="checkbox" name="newinfo" id="newinfo" value="1"~ . ($FORM{'newinfo'} ? ' checked="checked"' : '') . qq~ /> <label for="newinfo">$sstxt{'15a'}</label>
		</td>
	</tr><tr>
		<td class="catbg" align="center"><input type="submit" name="ss_submit" value="$sstxt{'24'}" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="reset" value="$sstxt{'25'}" /></td>
	</tr>
</table>
</form>
<br />
<br />
</div>
</div>
</body>
</html>~;

	&print_output_header;
	&print_HTML_output_and_finish;
}

sub Split_Splice_2 {
	if (!$staff && $INFO{'newboard'} ne $binboard) { &fatal_error("split_splice_not_allowed"); }

	my $curboard       = $INFO{'board'};
	my $curthreadid    = $INFO{'thread'};
	my $movingposts    = exists $INFO{'oldposts'} ? $INFO{'oldposts'} : $FORM{'oldposts'};
	$FORM{'oldposts'}  = $movingposts;
	my $leavemess      = exists $INFO{'leave'} ? $INFO{'leave'} : $FORM{'leave'};
	my $forcenewinfo   = exists $INFO{'newinfo'} ? $INFO{'newinfo'} : $FORM{'newinfo'};
	my $newcat         = exists $INFO{'newcat'} ? $INFO{'newcat'} : $FORM{'newcat'};
	my $newboard       = exists $INFO{'newboard'} ? $INFO{'newboard'} : $FORM{'newboard'};
	my $newthreadid    = exists $INFO{'newthread'} ? $INFO{'newthread'} : $FORM{'newthread'};
	$FORM{'newthread'} = $newthreadid;
	my $newthreadsub   = exists $INFO{'newthread_subject'} ? $INFO{'newthread_subject'} : $FORM{'newthread_subject'};
	my $newposition    = exists $INFO{'position'} ? $INFO{'position'} : $FORM{'position'};
	$FORM{'position'}  = $newposition;

	# Error messages if something is not filled out right
	&fatal_error('',"$sstxt{'22b'} $sstxt{'23'} $sstxt{'50'}") if $movingposts eq '';
	&fatal_error('',"$sstxt{'22'}") if $newcat eq 'cats';
	&fatal_error('',"$sstxt{'22a'}") if $newboard eq 'boards';
	&fatal_error('',"$sstxt{'51'} $sstxt{'50'}") if &checkfor_DBorFILE("$datadir/$curthreadid.poll") && &checkfor_DBorFILE("$datadir/$newthreadid.poll");

	my (@postnum,@utdcurthread,@utdnewthread,$i);
	my $linkcount = 0;

	# Get current thread posts
	unless (ref($thread_arrayref{$curthreadid})) {
		@{$thread_arrayref{$curthreadid}} = &read_DBorFILE(1,'',$datadir,$curthreadid,'txt');
	}
	my @curthread = @{$thread_arrayref{$curthreadid}};
	&MessageTotals("load", $curthreadid);

	# Store post numbers to be moved in array
	if ((split(/\, /, $movingposts, 2))[0] eq "all") { @postnum = (0 .. $#curthread); }
	else { @postnum = sort {$a <=> $b} split(/\, /, $movingposts); } # sort numerically ascending because may be reversed!

	# Check to see if current thread was the latest post for the board and if the last post was selected to change
	&BoardTotals("load", $curboard);
	if(${$curthreadid}{'lastpostdate'} == ${$uid.$curboard}{'lastposttime'} && $leavemess == 2 && $postnum[$#postnum] == $#curthread) {
		$newest_post = 1;
	}

	# Move selected posts to a brand new thread
	if ($newthreadid eq "new") {
		# Find a valid random ID for new thread.
		$newthreadid = (split(/\|/, $curthread[$postnum[0]], 5))[3] + 1;
		eval { require "$datadir/movedthreads.cgi" };
		while (exists $moved_file{$newthreadid} || &checkfor_DBorFILE("$datadir/$newthreadid.txt")) { $newthreadid++; }

		foreach (@postnum) {
			if ($newthreadsub || $leavemess == 1) { # insert new subject name || add 'no_postcount' into copies
				my @x = split(/\|/, $curthread[$_]);
				if ($newthreadsub) { $x[0] = $_ == $postnum[0] ? $newthreadsub : qq~$sstxt{'21'} $newthreadsub~; }
				if ($leavemess == 1) { $x[5] = 'no_postcount'; }
				push(@utdnewthread, join('|', @x));
			} else {
				push(@utdnewthread, $curthread[$_]);
			}
		}

	# Place selected posts in existing thread at selected position
	} else {
		# Get existing thread posts
		unless (ref($thread_arrayref{$newthreadid})) {
			@{$thread_arrayref{$newthreadid}} = &read_DBorFILE(1,'',$datadir,$newthreadid,'txt');
		}
		my @newthread = @{$thread_arrayref{$newthreadid}};
		&MessageTotals("load", $newthreadid);

		if    ($newposition eq "end")   { $newposition = $#newthread; }
		elsif ($newposition eq "begin") {
			foreach (@postnum) {
				if ($leavemess == 1) { # add 'no_postcount' into copies
					my @x = split(/\|/, $curthread[$_]);
					$x[5] = 'no_postcount';
					push(@utdnewthread, join('|', @x));
				} else {
					push(@utdnewthread, $curthread[$_]);
				}
			}
			$newposition = -1;
		}
		for ($i = 0; $i < @newthread; $i++){
			push (@utdnewthread, $newthread[$i]);
			if ($newposition == $i) {
				foreach (@postnum) {
					if ($leavemess == 1) { # add 'no_postcount' into copies
						my @x = split(/\|/, $curthread[$_]);
						$x[5] = 'no_postcount';
						push(@utdnewthread, join('|', @x));
					} else {
						push(@utdnewthread, $curthread[$_]);
					}
				}
				$linkcount = $i + 1;
			}
		}
	}

	# Remove or copy selected posts from current thread
	if ($#postnum == $#curthread && $leavemess != 1){
		if ($newboard ne $binboard) {
			my ($tmpsub,$tmpmessage);
			my $hidename = &cloak($username);
			($tmpsub, undef) = split(/\|/, $curthread[0], 2);
			if ($curboard eq $newboard) {
				$tmpmessage = qq~[m by=$hidename dest=$newthreadid/$linkcount#$linkcount]~;
				$tmpsub = qq~[m by=$hidename dest=$newthreadid]: '$tmpsub'~;
			} else {
				$tmpmessage = qq~[m by=$hidename destboard=$newboard dest=$newthreadid/$linkcount#$linkcount]~;
				$tmpsub = qq~[m by=$hidename destboard=$newboard dest=$newthreadid]: '$tmpsub'~;
			}
			&FromChars($tmpmessage);
			$utdcurthread[0] = qq~$tmpsub|${$uid.$username}{'realname'}|${$uid.$username}{'email'}|$date|$username|no_postcount||$user_ip|$tmpmessage||||\n~;

			eval { require "$datadir/movedthreads.cgi" };
			$moved_file{$curthreadid} = $newthreadid;
			delete $moved_file{$newthreadid};
			&save_moved_file;
			$leavemess = 0;
		} else {
			$leavemess = 2;
			$forcenewinfo = 1;
		}

	} elsif ($leavemess != 1) {
		$leavemess = 2 if $newboard eq $binboard;
		for ($i = 0; $i < @curthread; $i++){
			if ($movingposts =~ /\b$i\b/){
				if ($leavemess == 0 && $i == $postnum[$#postnum]){
					my $tmpsub;
					($tmpsub, undef) = split(/\|/, $curthread[$i], 2);
					push (@utdcurthread, qq~$tmpsub|${$uid.$username}{'realname'}|${$uid.$username}{'email'}|$date|$username|no_postcount||$user_ip|[split] [link=$scripturl?num=$newthreadid/$linkcount#$linkcount][splithere][/link][splithere_end]||||\n~);
				}
			} else {
				push (@utdcurthread, $curthread[$i]);
			}
		}

	} else { @utdcurthread = @curthread; }

	if ($forcenewinfo) {
		my ($boardtitle,$tmpsub,$tmpmessage);
		($boardtitle, undef) = split(/\|/, $board{$curboard}, 2);
		$tmpmessage = ($#postnum == $#utdnewthread ? "[b][movedhere]" : "[b][postsmovedhere1] " . @postnum . " [postsmovedhere2]") . " [i]$boardtitle\[/i] [move by] [i]${$uid.$username}{'realname'}\[/i].[/b]";
		&FromChars($tmpmessage);
		($tmpsub, undef, undef, undef, undef, undef, undef) = split(/\|/, $utdnewthread[0], 7);
		splice(@utdnewthread, ($linkcount + @postnum), 0,qq~$sstxt{'21'} $tmpsub|${$uid.$username}{'realname'}|${$uid.$username}{'email'}|$date|$username|no_postcount||$user_ip|$tmpmessage||||\n~);
	}

	# get mail, poll and polled data before eventually deleting the thread
	my (@curthread_mail,@curthread_poll,@curthread_polled);
	if ($use_MySQL && $#postnum == $#curthread) {
		@curthread_mail = &read_DBorFILE(0,'',$datadir,$curthreadid,'mail');
		@curthread_poll = &read_DBorFILE(0,'',$datadir,$curthreadid,'poll');
		@curthread_polled = &read_DBorFILE(0,'',$datadir,$curthreadid,'polled');
	}

	if (@utdcurthread) {
		for ($i = 0; $i < @utdcurthread; $i++) { # sort post numbers
			my @x = split(/\|/, $utdcurthread[$i]);
			$x[6] = $i;
			$utdcurthread[$i] = join('|', @x);
		}
		# Update current thread
		&write_DBorFILE(0,'',$datadir,$curthreadid,'txt',@utdcurthread);
	} else {
		require "$sourcedir/RemoveTopic.pl";
		my $moveit = $INFO{'moveit'};
		$INFO{'moveit'} = 1;
		&RemoveThread;
		$INFO{'moveit'} = $moveit;
	}

	for ($i = 0; $i < @utdnewthread; $i++) { # sort post numbers
		my @x = split(/\|/, $utdnewthread[$i]);
		$x[6] = $i;
		$utdnewthread[$i] = join('|', @x);
	}
	# Update new thread
	&write_DBorFILE(0,'',$datadir,$newthreadid,'txt',@utdnewthread);

	# Update the .rlog files of the users
	my ($reply,$ms,$mn,$md,$mu,$mnp,$mi,%mu,%curthreadusersdate,%curthreaduserscount,%newthreadusersdate,%newthreaduserscount,%BoardTotals);
	$reply = 0;
	foreach (@utdcurthread) { # $subject|$name|$email|$date|$username|$icon|0|$user_ip|$message|$ns|||$fixfile
		($ms, $mn, undef, $md, $mu, $mnp, undef, $mi, undef) = split(/\|/, $_, 9);
		$BoardTotals{$curthreadid} = [$md,$mu,$reply,$ms,$mn,$mi] if ${$BoardTotals{$curthreadid}}[0] <= $md;
		$reply++;
		next if $mnp eq 'no_postcount';
		$curthreadusersdate{$mu} = $md if $curthreadusersdate{$mu} < $md;
		$curthreaduserscount{$mu}++;
		$mu{$mu} = 1;
	}
	$reply = 0;
	foreach (@utdnewthread) {
		($ms, $mn, undef, $md, $mu, $mnp, undef, $mi, undef) = split(/\|/, $_, 9);
		$BoardTotals{$newthreadid} = [$md,$mu,$reply,$ms,$mn,$mi] if ${$BoardTotals{$newthreadid}}[0] <= $md;
		$reply++;
		next if $mnp eq 'no_postcount';
		$newthreadusersdate{$mu} = $md if $newthreadusersdate{$mu} < $md;
		$newthreaduserscount{$mu}++;
		$mu{$mu} = 1;
	}
	foreach $mu (keys %mu) {
		&Recent_Load($mu);
		delete $recent{$curthreadid};
		delete $recent{$newthreadid};
		if ($curthreaduserscount{$mu}) {
			${$recent{$curthreadid}}[0] = $curthreaduserscount{$mu};
			${$recent{$curthreadid}}[1] = $curthreadusersdate{$mu};
		}
		if ($newthreaduserscount{$mu}) {
			${$recent{$newthreadid}}[0] = $newthreaduserscount{$mu};
			${$recent{$newthreadid}}[1] = $newthreadusersdate{$mu};
		}
		&Recent_Save($mu);
	}

	# For: Mark threads/boards as read
	&getlog;
	my $boardlog = 1;
	# Mark new thread as read because you will be directed there at the end
	delete $yyuserlog{"$newthreadid--unread"};
	$yyuserlog{$newthreadid} = $date;

	# Update .ctb, tags=>(board replies views lastposter lastpostdate threadstatus repliers)
	# curthread
	${$curthreadid}{'replies'} = $#utdcurthread;
	${$curthreadid}{'lastpostdate'} = ${$BoardTotals{$curthreadid}}[0];
	${$curthreadid}{'lastposter'}   = ${$BoardTotals{$curthreadid}}[1] eq 'Guest' ? "Guest-${$BoardTotals{$curthreadid}}[4]" : ${$BoardTotals{$curthreadid}}[1];
	# newthread
	${$newthreadid}{'replies'} = $#utdnewthread;
	${$newthreadid}{'lastpostdate'} = ${$BoardTotals{$newthreadid}}[0];
	${$newthreadid}{'lastposter'}   = ${$BoardTotals{$newthreadid}}[1] eq 'Guest' ? "Guest-${$BoardTotals{$newthreadid}}[4]" : ${$BoardTotals{$newthreadid}}[1];
	if ($FORM{'newthread'} eq 'new') {
		${$newthreadid}{'board'} = $newboard;
		${$newthreadid}{'views'} = $#postnum == $#curthread ? ${$curthreadid}{'views'} : ($INFO{'ss_submit'} ? 1 : 0);
		${$newthreadid}{'threadstatus'} = ${$curthreadid}{'threadstatus'};
		${$curthreadid}{'views'} = $#postnum == $#curthread && $leavemess != 1 ? 0 : ${$curthreadid}{'views'};
	} else {
		${$newthreadid}{'views'} += int(${$curthreadid}{'views'} / @curthread * @postnum);
	}

	# Update current message index
	my @curmessindex = &read_DBorFILE(0,BOARD,$boardsdir,$curboard,'txt');

	my $old_mstate;
	for ($i = 0; $i < @curmessindex; $i++) {
		my ($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $curmessindex[$i]);
		$boardlog = 0 if $mdate > $yyuserlog{$curboard}; # For: Mark boards as read
		if ($mnum == $curthreadid) {
			chomp $mstate;
			if ($#postnum == $#curthread && $leavemess != 1) { # thread was moved
				my $hidename = &cloak($username);
				if ($curboard eq $newboard) {
					$msub = qq~[m by=$hidename dest=$newthreadid]: '$msub'~;
				} else {
					$msub = qq~[m by=$hidename destboard=$newboard dest=$newthreadid]: '$msub'~;
				}
				$mname = ${$uid.$username}{'realname'};
				$memail = ${$uid.$username}{'email'};
				$mreplies = 0;
				$musername = $username;
				# alter message icon to 'exclamation' to match status 'lm'
				$micon = 'exclamation' if $micon ne 'no_postcount';
				# thread status - (a)nnoumcement, (h)idden, (l)ocked, (m)oved and (s)ticky
				$old_mstate = $mstate;
				if ($curboard eq $annboard && $mstate !~ /a/i) { $mstate .= "a"; }
				if ($mstate !~ /l/i) { $mstate .= "l"; }
				if ($mstate !~ /m/i) { $mstate .= "m"; }
				${$curthreadid}{'threadstatus'} = $mstate;
			} else {
				($msub, $mname, $memail, undef, $musername, $micon, undef) = split(/\|/, $utdcurthread[0], 7);
				$mreplies = ${$curthreadid}{'replies'};
			}
			$curmessindex[$i] = qq~$mnum|$msub|$mname|$memail|${$curthreadid}{'lastpostdate'}|$mreplies|$musername|$micon|$mstate\n~;
			${$BoardTotals{$mnum}}[6] = $mstate;

		} elsif ($mnum == $newthreadid) {
			chomp $mstate;
			if ($FORM{'position'} eq 'begin') {
				($msub, $mname, $memail, undef, $musername, $micon, undef) = split(/\|/, $utdnewthread[0], 7);
			}
			$yyThreadLine = $curmessindex[$i] = qq~$mnum|$msub|$mname|$memail|${$newthreadid}{'lastpostdate'}|${$newthreadid}{'replies'}|$musername|$micon|$mstate\n~;
			${$BoardTotals{$mnum}}[6] = $mstate;
			if (($enable_notifications == 1 || $enable_notifications == 3) && (&checkfor_DBorFILE("$boardsdir/$curboard.mail") || &checkfor_DBorFILE("$datadir/$newthreadid.mail"))) {
				require "$sourcedir/Post.pl";
				$currentboard = $curboard;
				$msub = &Censor($msub);
				&ReplyNotify($newthreadid, $msub, ${$newthreadid}{'replies'});
			}
		}
	}
	if ($curboard eq $newboard && $FORM{'newthread'} eq 'new') {
		my ($msub,$mname,$memail,$musername,$micon);
		($msub, $mname, $memail, undef, $musername, $micon, undef) = split(/\|/, $utdnewthread[0], 7);
		if ($old_mstate !~ /0/i) { $old_mstate .= "0"; }
		$yyThreadLine = qq~$newthreadid|$msub|$mname|$memail|${$newthreadid}{'lastpostdate'}|${$newthreadid}{'replies'}|$musername|$micon|$old_mstate\n~;
		unshift (@curmessindex, $yyThreadLine);
		${$BoardTotals{$newthreadid}}[6] = $old_mstate;
		if (($enable_notifications == 1 || $enable_notifications == 3) && &checkfor_DBorFILE("$boardsdir/$newboard.mail")) {
			require "$sourcedir/Post.pl";
			$currentboard = $curboard;
			$msub = &Censor($msub);
			&NewNotify($newthreadid, $msub);
		}
	}
	&write_DBorFILE(0,BOARD,$boardsdir,$curboard,'txt',sort( { (split(/\|/,$b,6))[4] <=> (split(/\|/,$a,6))[4] } @curmessindex ));

	$yyuserlog{$curboard} = $date if $boardlog; # For: Mark boards as read

	# Update new message index if needed
	if ($curboard ne $newboard) {
		$boardlog = 1; # For: Mark boards as read

		my @newmessindex = &read_DBorFILE(0,BOARD,$boardsdir,$newboard,'txt');

		if ($FORM{'newthread'} eq 'new') {
			# For: Mark boards as read
			foreach (@newmessindex) {
				$boardlog = 0 if (split(/\|/, $_, 6))[4] > $yyuserlog{$newboard};
				last if !$boardlog;
			}

			my ($msub,$mname,$memail,$musername,$micon);
			($msub, $mname, $memail, undef, $musername, $micon, undef) = split(/\|/, $utdnewthread[0], 7);
			if ($old_mstate =~ /a/i) { 
				if ($newboard ne $annboard) { $old_mstate =~ s/a//gi; }
			} elsif ($newboard eq $annboard) {
				$old_mstate .= "a";
			}
			if ($old_mstate !~ /0/i) { $old_mstate .= "0"; }
			$yyThreadLine = qq~$newthreadid|$msub|$mname|$memail|${$newthreadid}{'lastpostdate'}|${$newthreadid}{'replies'}|$musername|$micon|$old_mstate\n~;
			unshift (@newmessindex, $yyThreadLine);
			${$BoardTotals{$newthreadid}}[6] = $old_mstate;
			if (($enable_notifications == 1 || $enable_notifications == 3) && &checkfor_DBorFILE("$boardsdir/$newboard.mail")) {
				require "$sourcedir/Post.pl";
				$currentboard = $newboard;
				$msub = &Censor($msub);
				&NewNotify($newthreadid, $msub);
			}

		} else {
			for ($i = 0; $i < @newmessindex; $i++) {
				my ($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $newmessindex[$i]);
				$boardlog = 0 if $mdate > $yyuserlog{$newboard}; # For: Mark boards as read
				if ($mnum == $newthreadid) {
					chomp $mstate;
					if ($FORM{'position'} eq 'begin') {
						($msub, $mname, $memail, undef, $musername, $micon, undef) = split(/\|/, $utdnewthread[0], 7);
					}
					$yyThreadLine = $newmessindex[$i] = qq~$mnum|$msub|$mname|$memail|${$newthreadid}{'lastpostdate'}|${$newthreadid}{'replies'}|$musername|$micon|$mstate\n~;
					${$BoardTotals{$mnum}}[6] = $mstate;
				}
			}
			if (($enable_notifications == 1 || $enable_notifications == 3) && (&checkfor_DBorFILE("$boardsdir/$newboard.mail") || &checkfor_DBorFILE("$datadir/$newthreadid.mail"))) {
				require "$sourcedir/Post.pl";
				$currentboard = $newboard;
				$msub = &Censor($msub);
				&ReplyNotify($newthreadid, $msub, ${$newthreadid}{'replies'});
			}
		}
		&write_DBorFILE(0,BOARD,$boardsdir,$newboard,'txt',sort( { (split /\|/,$b,6)[4] <=> (split /\|/,$a,6)[4] } @newmessindex ));

		$yyuserlog{$newboard} = $date if $boardlog; # For: Mark boards as read
	}

	&MessageTotals("update", $curthreadid) if @utdcurthread;
	&MessageTotals("update", $newthreadid);

	# update current board totals
	# BoardTotals- tags => (board threadcount messagecount lastposttime lastposter lastpostid lastreply lastsubject lasticon lasttopicstate)
	#&BoardTotals("load", $curboard); - Load this at top now to detect if newest board post is being moved - Unilat
	if (${$BoardTotals{$curthreadid}}[6] =~ /m/) { # Moved-Info thread
		if ($curboard ne $newboard) {
			${$uid.$curboard}{'threadcount'}--;
			${$uid.$curboard}{'messagecount'} -= @postnum;
		}
		&BoardSetLastInfo($curboard,\@curmessindex);
	} else {
		if ($FORM{'newthread'} eq 'new' && $curboard eq $newboard) { ${$uid.$curboard}{'threadcount'}++; }
		if ($leavemess == 0) {
			if ($curboard ne $newboard) { ${$uid.$curboard}{'messagecount'} -= $#postnum; }
			else { ${$uid.$curboard}{'messagecount'} += ($forcenewinfo ? 2 : 1); }
		} elsif ($leavemess == 1 && $curboard eq $newboard) {
			${$uid.$curboard}{'messagecount'} += $#postnum + ($forcenewinfo ? 1 : 0);
		} elsif ($leavemess == 2 && $curboard ne $newboard && @utdcurthread) {
			${$uid.$curboard}{'messagecount'} -= @postnum;
		}
		if ($newest_post || (((${$uid.$curboard}{'threadcount'} == 1 && @utdcurthread) || ${$BoardTotals{$curthreadid}}[0] >= ${$uid.$curboard}{'lastposttime'}) && ($curboard ne $newboard || ${$BoardTotals{$curthreadid}}[0] >= ${$BoardTotals{$newthreadid}}[0]))) {
			${$uid.$curboard}{'lastposttime'}   = ${$BoardTotals{$curthreadid}}[0];
			${$uid.$curboard}{'lastposter'}     = ${$BoardTotals{$curthreadid}}[1] eq 'Guest' ? "Guest-${$BoardTotals{$curthreadid}}[4]" : ${$BoardTotals{$curthreadid}}[1];
			${$uid.$curboard}{'lastpostid'}     = $curthreadid;
			${$uid.$curboard}{'lastreply'}      = ${$BoardTotals{$curthreadid}}[2]--;
			${$uid.$curboard}{'lastsubject'}    = ${$BoardTotals{$curthreadid}}[3];
			${$uid.$curboard}{'lasticon'}       = ${$BoardTotals{$curthreadid}}[5];
			${$uid.$curboard}{'lasttopicstate'} = ${$BoardTotals{$curthreadid}}[6];
		} elsif (${$BoardTotals{$newthreadid}}[0] >= ${$uid.$curboard}{'lastposttime'} && $curboard eq $newboard) {
			${$uid.$curboard}{'lastposttime'}   = ${$BoardTotals{$newthreadid}}[0];
			${$uid.$curboard}{'lastposter'}     = ${$BoardTotals{$newthreadid}}[1] eq 'Guest' ? "Guest-${$BoardTotals{$newthreadid}}[4]" : ${$BoardTotals{$newthreadid}}[1];
			${$uid.$curboard}{'lastpostid'}     = $newthreadid;
			${$uid.$curboard}{'lastreply'}      = ${$BoardTotals{$newthreadid}}[2]--;
			${$uid.$curboard}{'lastsubject'}    = ${$BoardTotals{$newthreadid}}[3];
			${$uid.$curboard}{'lasticon'}       = ${$BoardTotals{$newthreadid}}[5];
			${$uid.$curboard}{'lasttopicstate'} = ${$BoardTotals{$newthreadid}}[6];
		}
		&BoardTotals("update", $curboard);
	}

	# update new board totals if needed
	if ($curboard ne $newboard) {
		&BoardTotals("load", $newboard);
		if ($FORM{'newthread'} eq 'new') { ${$uid.$newboard}{'threadcount'}++; }
		${$uid.$newboard}{'messagecount'} += @postnum + ($forcenewinfo ? 1 : 0);
		if (${$uid.$newboard}{'threadcount'} == 1 || ${$BoardTotals{$newthreadid}}[0] >= ${$uid.$newboard}{'lastposttime'}) {
			${$uid.$newboard}{'lastposttime'}   = ${$BoardTotals{$newthreadid}}[0];
			${$uid.$newboard}{'lastposter'}     = ${$BoardTotals{$newthreadid}}[1] eq 'Guest' ? "Guest-${$BoardTotals{$newthreadid}}[4]" : ${$BoardTotals{$newthreadid}}[1];
			${$uid.$newboard}{'lastpostid'}     = $newthreadid;
			${$uid.$newboard}{'lastreply'}      = ${$BoardTotals{$newthreadid}}[2]--;
			${$uid.$newboard}{'lastsubject'}    = ${$BoardTotals{$newthreadid}}[3];
			${$uid.$newboard}{'lasticon'}       = ${$BoardTotals{$newthreadid}}[5];
			${$uid.$newboard}{'lasttopicstate'} = ${$BoardTotals{$newthreadid}}[6];
		}
		&BoardTotals("update", $newboard);
	}

	# now fix all attachments.txt info
	my $attachments;
	for ($i = $postnum[0]; $i < @curthread; $i++){ # see if old thread had attachments
		$attachments = (split(/\|/, $curthread[$i]))[12];
		chomp $attachments;
		if ($attachments) {
			$attachments = 1;
			last;
		}
	}
	if (!$attachments) { # see if new thread has attachments
		for ($i = $linkcount; $i < @utdnewthread; $i++){
			$attachments = (split(/\|/, $utdnewthread[$i]))[12];
			chomp $attachments;
			if ($attachments) {
				$attachments = 2;
				last;
			}
		}
	}
	if ($attachments) {
		my ($attid,$attachmentname,$downloadscount,@newattachments,%attachments,$mreplies,$msub,$mname,$mdate,$mfn);
		while (&read_DBorFILE(0,ATM,$vardir,'attachments','txt')) {
			($attid, undef, undef, undef, undef, undef, undef, $attachmentname, $downloadscount) = split(/\|/, $_);
			push(@newattachments, $_) if ($attid != $curthreadid && $attid != $newthreadid) || ($attid == $curthreadid && $attachments != 1);
			chomp $downloadscount;
			$attachments{$attachmentname} = $downloadscount;
		}

		$mreplies = 0;
		if ($attachments == 1) {
			foreach (@utdcurthread) { # fix new old thread attachments
				($msub, $mname, undef, $mdate, undef, undef, undef, undef, undef, undef, undef, undef, $mfn) = split(/\|/, $_);
				chomp $mfn;
				foreach (split(/,/, $mfn)) {
					if (&checkfor_DBorFILE("$uploaddir/$_")) {
						my $asize = int((-s "$uploaddir/$_") / 1024) || 1;
						push (@newattachments, qq~$curthreadid|$mreplies|$msub|$mname|$curboard|$asize|$mdate|$_|~ . ($attachments{$_} || 0) . qq~\n~);
					}
				}
				$mreplies++;
			}
		}

		$mreplies = 0;
		foreach (@utdnewthread) { # fix new thread attachments
			($msub, $mname, undef, $mdate, undef, undef, undef, undef, undef, undef, undef, undef, $mfn) = split(/\|/, $_);
			chomp $mfn;
			foreach (split(/,/, $mfn)) {
				if (&checkfor_DBorFILE("$uploaddir/$_")) {
					my $asize = int((-s "$uploaddir/$_") / 1024) || 1;
					push (@newattachments, qq~$newthreadid|$mreplies|$msub|$mname|$newboard|$asize|$mdate|$_|~ . ($attachments{$_} || 0) . qq~\n~);
				}
			}
			$mreplies++;
		}

		&write_DBorFILE(0,ATM,$vardir,'attachments','txt',sort( { (split(/\|/,$a,8))[6] <=> (split(/\|/,$b,8))[6] } @newattachments ));
	}

	if ($#postnum == $#curthread) {
		if (&checkfor_DBorFILE("$datadir/$curthreadid.poll")) {
			if ($use_MySQL) {
				&write_DBorFILE(1,'',$datadir,$newthreadid,'poll',@curthread_poll);
				&delete_DBorFILE("$datadir/$curthreadid.poll");
			} else {
				rename("$datadir/$curthreadid.poll", "$datadir/$newthreadid.poll");
			}
		}
		if (&checkfor_DBorFILE("$datadir/$curthreadid.polled")) {
			if ($use_MySQL) {
				&write_DBorFILE(1,'',$datadir,$newthreadid,'polled',@curthread_polled);
				&delete_DBorFILE("$datadir/$curthreadid.polled");
			} else {
				rename("$datadir/$curthreadid.polled", "$datadir/$newthreadid.polled");
			}
		}
		if (&checkfor_DBorFILE("$datadir/$curthreadid.mail")) {
			if ($use_MySQL) {
				&write_DBorFILE(1,'',$datadir,$newthreadid,'mail',@curthread_mail);
				&delete_DBorFILE("$datadir/$curthreadid.mail");
			} else {
				rename("$datadir/$curthreadid.mail", "$datadir/$newthreadid.mail");
			}
			require "$sourcedir/Notify.pl";
			&ManageThreadNotify("load", $newthreadid);
			my ($u,%t);
			foreach $u (keys %thethread) {
				&LoadUser($u);
				foreach (split(/,/, ${$uid.$u}{'thread_notifications'})) {
					$t{$_} = 1;
				}
				delete $t{$curthreadid};
				$t{$newthreadid} = 1;
				${$uid.$u}{'thread_notifications'} = join(',', keys %t);
				&UserAccount($u);
				undef %t;
			}
		}
	}

	# Mark current thread as read
	delete $yyuserlog{"$curthreadid--unread"};
	&dumplog($curthreadid); # Save threads/boards as read

	chomp $yyThreadLine;

	if ($INFO{'moveit'} == 1) {
		$currentboard = $curboard;
		return;
	}
	if ($INFO{'ss_submit'}) {
		$currentboard = $newboard;
		$INFO{'num'} = $INFO{'thread'} = $FORM{'threadid'} = $curnum = $newthreadid;
		&redirectinternal;
	}
	if ($debug == 1 or ($debug == 2 && $iamadmin)) {
		require "$sourcedir/Debug.pl";
		&Debug;
		$yydebug = qq~\n- $#utdnewthread<br />\n- @utdnewthread<br />\n- ${$newthreadid}{'lastpostdate'}<br />\n- ${$newthreadid}{'lastposter'}<br />\n- \$enable_notifications == $enable_notifications<br />\n- \$attachments = $attachments<br />\n<a href="javascript:load_thread($newthreadid,$linkcount);">continue</a>\n$yydebug~;
	}

	&print_output_header;

	$output = qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$sstxt{'1'}</title>
<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />
<script language="JavaScript1.2" type="text/javascript">
<!--
	function load_thread(threadid,replies) {
		try{
			if (typeof(opener.document) == 'object') throw '1';
			else throw '0';
		} catch (e) {
			if (replies > 0 || ~ . ((($ttsureverse && ${$uid.$username}{'reversetopic'}) || $ttsreverse) ? 1 : 0) . qq~ == 1) replies = '/' + replies + '#' + replies;
			else replies = '';
			if (e == 1) {
				opener.focus();
				opener.location.href='$scripturl?num=' + threadid + replies;
				self.close();
			} else {
				location.href='$scripturl?num=' + threadid + replies;
			}
		}
	}
// -->
</script>
</head>
<body onload="load_thread($newthreadid,$linkcount);">
&nbsp;$yydebug
</body>
</html>~;

	&print_HTML_output_and_finish;
}

1;