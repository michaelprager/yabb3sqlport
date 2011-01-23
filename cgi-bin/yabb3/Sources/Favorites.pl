###############################################################################
# Favorites.pl                                                                #
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

$favoritesplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub Favorites {
	&LoadLanguage('MessageIndex');
	require "$templatesdir/$usemessage/MessageIndex.template";
	my $start = int($INFO{'start'}) || 0;
	my (@threads, $counter, $pages, $mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate, $dlp);
	my $treplies = 0;

	# grab all relevant info on the favorite thread for this user and check access to them
	if (!$maxfavs) { $maxfavs = 10; }
	my @favboards;
	eval { require "$datadir/movedthreads.cgi" };
	foreach my $myfav (split(/,/, ${$uid.$username}{'favorites'})) {
		# see if thread exists and search for it if moved
		if (exists $moved_file{$myfav}) {
			my @moved = ($myfav);
			while (exists $moved_file{$myfav}) {
				$myfav = $moved_file{$myfav};
				unshift(@moved, $myfav);
			}
			foreach (@moved) {
				$myfav = $_;
				if ($myfav ne $moved[$#moved]) {
					if (&checkfor_DBorFILE("$datadir/$myfav.ctb")) {
						&RemFav($moved[$#moved], "nonexist");
						&AddFav($myfav,0,1);
						last;
					}
				} elsif (!&checkfor_DBorFILE("$datadir/$myfav.ctb")) {
					&RemFav($myfav, "nonexist");
					$myfav = 0;
				}
			}
			next if !$myfav;
		} elsif (!&checkfor_DBorFILE("$datadir/$myfav.ctb")) {
			&RemFav($myfav, "nonexist");
			next;
		}
		&MessageTotals("load", $myfav);
		$favoboard = ${$myfav}{'board'};
		push(@favboards, "$favoboard|$myfav");
	}

	foreach (sort(@favboards)) {
		($loadboard, $loadfav) = split(/\|/, $_);
		&BoardTotals("load", $loadboard) if !${$uid.$loadboard}{'board'};

		next if !$iamadmin && &AccessCheck($loadboard, '', (split(/\|/, $board{$loadboard}))[1]) ne "granted";

		next if !$iamadmin && !&CatAccess((split(/\|/, $catinfo{"${$uid.$loadboard}{'cat'}"}))[1]);

		foreach (&read_DBorFILE(0,'',$boardsdir,$loadboard,'txt')) {
			if ((split(/\|/, $_, 2))[0] eq $loadfav) { push(@threads, $_); }
		}
	}

	my $curfav =  &NumberFormat(scalar @threads);

	&LoadCensorList;

	my %attachments;
	if (-s "$vardir/attachments.txt" > 5) {
		foreach (&read_DBorFILE(0,'',$vardir,'attachments','txt')) {
			$attachments{(split(/\|/, $_, 2))[0]}++;
		}
	}

	# Print the header and board info.
	my $colspan = 7;

	# Begin printing the message index for current board.
	$counter = $start;
	&getlog;
	my $dmax = $date - ($max_log_days_old * 86400);
	foreach (@threads) {
		($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $_);

		# Set thread class depending on locked status and number of replies.
		if ($mnum == '') { next; }
		#if ($mstate =~ /h/i && !$staff) { next; }

		&MessageTotals('load', $mnum);

		$permlinkboard = ${$mnum}{'board'} eq $annboard ? $annboard : $currentboard;
		my $permdate = &permtimer($_);
		my $message_permalink = qq~<a href="http://$perm_domain/$symlink$permdate/$permlinkboard/$mnum">$messageindex_txt{'10'}</a>~;

		$threadclass = 'thread';
		if ($mstate =~ /h/i) { $threadclass = 'hide'; }
		elsif ($mstate =~ /l/i) { $threadclass = 'locked'; }
		elsif ($mreplies >= $VeryHotTopic) { $threadclass = 'veryhotthread'; }
		elsif ($mreplies >= $HotTopic) { $threadclass = 'hotthread'; }
		elsif ($mstate == '') { $threadclass = 'thread'; }
		if ($threadclass eq 'hide' && $mstate =~ /s/i && $mstate !~ /l/i) { $threadclass = 'hidesticky'; }
		elsif ($threadclass eq 'hide' && $mstate =~ /l/i && $mstate !~ /s/i) { $threadclass = 'hidelock'; }
		elsif ($threadclass eq 'hide' && $mstate =~ /s/i && $mstate =~ /l/i) { $threadclass = 'hidestickylock'; }
		elsif ($threadclass eq 'locked' && $mstate =~ /s/i && $mstate !~ /h/i) { $threadclass = 'stickylock'; }
		elsif ($mstate =~ /s/i && $mstate !~ /h/i) { $threadclass = 'sticky'; }
		elsif (${$mnum}{'board'} eq $annboard && $mstate !~ /h/i) { $threadclass = $threadclass eq 'locked' ? 'announcementlock' : 'announcement'; }

		my $movedFlag;
		(undef, $movedFlag) = &Split_Splice_Move($msub,$mnum);

		if (!$iamguest && $max_log_days_old) {
			# Decide if thread should have the "NEW" indicator next to it.
			# Do this by reading the user's log for last read time on thread,
			# and compare to the last post time on the thread.
			$dlp = int($yyuserlog{$mnum}) > int($yyuserlog{"$currentboard--mark"}) ? int($yyuserlog{$mnum}) : int($yyuserlog{"$currentboard--mark"});
			if ($yyuserlog{"$mnum--unread"} || (!$dlp && $mdate > $dmax) || ($dlp > $dmax && $dlp < $mdate)) {
				if (${$mnum}{'board'} eq $annboard) {
					$new = qq~<a href="$scripturl?virboard=$currentboard;num=$mnum/new"><img src="$imagesdir/new.gif" alt="$messageindex_txt{'302'}" title="$messageindex_txt{'302'}" border="0"/></a>~;
				} else {
					$new = qq~<a href="$scripturl?num=$mnum/new"><img src="$imagesdir/new.gif" alt="$messageindex_txt{'302'}" title="$messageindex_txt{'302'}" border="0"/></a>~;
				}

			} else {
				$new = '';
			}
		}
		$new = '' if $movedFlag;

		$micon = qq~<img src="$imagesdir/$micon.gif" alt="" border="0" align="middle" />~;
		$mpoll = "";
		if (&checkfor_DBorFILE("$datadir/$mnum.poll")) {
			$mpoll = qq~<b>$messageindex_txt{'15'}: </b>~;
			my @poll = &read_DBorFILE(0,'',$datadir,$mnum,'poll');
			my ($poll_question, $poll_locked, $poll_uname, $poll_name, $poll_email, $poll_date, $guest_vote, $hide_results, $multi_vote, $poll_mod, $poll_modname, $poll_comment, $vote_limit, $pie_radius, $pie_legends, $poll_end) = split(/\|/, $poll[0]);
			chomp $poll_end;
			if ($poll_end && !$poll_locked && $poll_end < $date) {
				$poll_locked = 1;
				$poll_end = '';
				$poll[0] = "$poll_question|$poll_locked|$poll_uname|$poll_name|$poll_email|$poll_date|$guest_vote|$hide_results|$multi_vote|$poll_mod|$poll_modname|$poll_comment|$vote_limit|$pie_radius|$pie_legends|$poll_end\n";
				&write_DBorFILE(1,'',$datadir,$mnum,'poll',@poll);
			}
			$micon = qq~$img{'pollicon'}~;
			if ($poll_locked) { $micon = $img{'polliconclosed'}; }
			elsif ($max_log_days_old && $mdate > $dmax) {
				if ($dlp < $createpoll_date) {
					$micon = qq~$img{'polliconnew'}~;
				} else {
					my $polled = &read_DBorFILE(0,'',$datadir,$mnum,'polled');
					if ($dlp < (split(/\|/, $polled))[3]) { $micon = qq~$img{'polliconnew'}~; }
				}
			}
		}

		# Load the current nickname of the account name of the thread starter.
		if ($musername ne 'Guest') {
			&LoadUser($musername);
			if (${$uid.$musername}{'realname'}) {
				$mname = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}" rel="nofollow">$ {$uid.$musername}{'realname'}</a>~;
			} else {
				$mname .= qq~ ($messageindex_txt{'470a'})~;
			}
		}

		($msub, undef) = &Split_Splice_Move($msub,0);
		# Censor the subject of the thread.
		$msub = &Censor($msub);
		&ToChars($msub);

		# Build the page links list.
		$pages = '';
		$pagesall;
		if ($showpageall) { $pagesall = qq~<a href="$scripturl?num=$mnum/all-0">$pidtxt{'01'}</a>~; }
		if (int(($mreplies + 1) / $maxmessagedisplay) > 6) {
			$pages = qq~ <a href="$scripturl?num=$mnum/~ . (!$ttsreverse ? "0#0" : "$mreplies#$mreplies") . qq~">1</a>~;
			$pages .= qq~ <a href="$scripturl?num=$mnum/~ . (!$ttsreverse ? "$maxmessagedisplay#$maxmessagedisplay" : ($mreplies - $maxmessagedisplay) . '#' . ($mreplies - $maxmessagedisplay)) . qq~">2</a>~;
			$endpage = int($mreplies / $maxmessagedisplay) + 1;
			$i = ($endpage - 1) * $maxmessagedisplay;
			$j = $i - $maxmessagedisplay;
			$k = $endpage - 1;
			$tmpa = $endpage - 2;
			$tmpb = $j - $maxmessagedisplay;
			$pages .= qq~ <a href="javascript:void(0);" onclick="ListPages($mnum);">...</a>~;
			$pages .= qq~ <a href="$scripturl?num=$mnum/~ . (!$ttsreverse ? "$tmpb#$tmpb" : ($mreplies - $tmpb) . '#' . ($mreplies - $tmpb)) . qq~">$tmpa</a>~;
			$pages .= qq~ <a href="$scripturl?num=$mnum/~ . (!$ttsreverse ? "$j#$j" : ($mreplies - $j) . '#' . ($mreplies - $j)) . qq~">$k</a>~;
			$pages .= qq~ <a href="$scripturl?num=$mnum/~ . (!$ttsreverse ? "$i#$i" : ($mreplies - $i) . '#' . ($mreplies - $i)) . qq~">$endpage</a>~;
			$pages = qq~<br /><span class="small">&#171; $messageindex_txt{'139'} $pages $pagesall &#187;</span>~;

		} elsif ($mreplies + 1 > $maxmessagedisplay) {
			$tmpa = 1;
			for ($tmpb = 0; $tmpb < $mreplies + 1; $tmpb += $maxmessagedisplay) {
				$pages .= qq~<a href="$scripturl?num=$mnum/~ . (!$ttsreverse ? "$tmpb#$tmpb" : ($mreplies - $tmpb)) . qq~">$tmpa</a>\n~;
				++$tmpa;
			}
			$pages =~ s/\n\Z//;
			$pages = qq~<br /><span class="small">&#171; $messageindex_txt{'139'} $pages &#187;</span>~;
		}

		$views = ${$mnum}{'views'};
		$lastposter = ${$mnum}{'lastposter'};
		if ($lastposter =~ m~\AGuest-(.*)~) {
			$lastposter = $1;
		} elsif ($lastposter !~ m~Guest~ && !&checkfor_DBorFILE("$memberdir/$lastposter.vars")) {
			$lastposter = $messageindex_txt{'470a'};
		} else {
			unless (($lastposter eq $messageindex_txt{'470'} || $lastposter eq $messageindex_txt{'470a'}) && &checkfor_DBorFILE("$memberdir/$lastposter.vars")) {
				&LoadUser($lastposter);
				if (${$uid.$lastposter}{'realname'}) { $lastposter = qq~<a href="$scripturl?action=viewprofile;username=$lastposter" rel="nofollow">${$uid.$lastposter}{'realname'}</a>~; }
			}
		}
		$lastpostername = $lastposter || $messageindex_txt{'470'};
		$views = $views ? $views - 1 : 0;

		# Check if the thread contains attachments and create a paper-clip icon if it does
		$temp_attachment = $attachments{$mnum} ? qq~<a href="javascript:void(window.open('$scripturl?action=viewdownloads;thread=$mnum','_blank','width=800,height=650,scrollbars=yes'))"><img src="$imagesdir/paperclip.gif" alt="$messageindex_txt{'3'} $attachments{$mnum} ~ . ($attachments{$mnum} == 1 ? $messageindex_txt{'5'} : $messageindex_txt{'4'}) . qq~" title="$messageindex_txt{'3'} $attachments{$mnum} ~ . ($attachments{$mnum} == 1 ? $messageindex_txt{'5'} : $messageindex_txt{'4'}) . qq~" style="border-style:none;" /></a>~ : "";

		$mydate = &timeformat($mdate);

		my $threadpic    = qq~<img src="$imagesdir/$threadclass.gif" alt=""/>~;
		my $msublink = qq~<a href="$scripturl?num=$mnum">$msub</a>~;
		if (!$movedFlag && ${$mnum}{'board'} eq $annboard) {
			$msublink = qq~<a href="$scripturl?virboard=$currentboard;num=$mnum">$msub</a>~;
		}
		my $lastpostlink = qq~<a href="$scripturl?num=$mnum/$mreplies#$mreplies">$img{'lastpost'}$mydate</a>~;
		my $fmreplies = &NumberFormat($mreplies);
		$views = &NumberFormat($views);
		my $tempbar = $threadbar;
		if ($movedFlag) { $tempbar = $threadbarMoved; }

		$adminbar = qq~<input type="checkbox" name="admin$mcount" class="windowbg" style="border: 0px;" value="$mnum" />~;
		$admincol = $admincolumn;
		$admincol =~ s/({|<)yabb admin(}|>)/$adminbar/g;

		$tempbar =~ s/({|<)yabb admin column(}|>)/$admincol/g;
		$tempbar =~ s/({|<)yabb threadpic(}|>)/$threadpic/g;
		$tempbar =~ s/({|<)yabb icon(}|>)/$micon/g;
		$tempbar =~ s/({|<)yabb new(}|>)/$new/g;
		$tempbar =~ s/({|<)yabb poll(}|>)/$mpoll/g;
		$tempbar =~ s/({|<)yabb favorite(}|>)/$favicon{$mnum}/g;
		$tempbar =~ s/({|<)yabb subjectlink(}|>)/$msublink/g;
		$tempbar =~ s/({|<)yabb attachmenticon(}|>)/$temp_attachment/g;
		$tempbar =~ s/({|<)yabb pages(}|>)/$pages/g;
		$tempbar =~ s/({|<)yabb starter(}|>)/$mname/g;
		$tempbar =~ s/({|<)yabb replies(}|>)/$fmreplies/g;
		$tempbar =~ s/({|<)yabb views(}|>)/$views/g;
		$tempbar =~ s/({|<)yabb lastpostlink(}|>)/$lastpostlink/g;
		$tempbar =~ s/({|<)yabb lastposter(}|>)/$lastpostername/g;
		if ($accept_permalink == 1) {
			$tempbar =~ s/({|<)yabb permalink(}|>)/$message_permalink/g;
		} else {
			$tempbar =~ s/({|<)yabb permalink(}|>)//g;
		}
		$tmptempbar .= $tempbar;
		$counter++;
		$mcount++;
		$treplies += $mreplies + 1;
	}

	# Put a "no messages" message if no threads exisit:
	if (!$tmptempbar) {
		$tmptempbar = qq~
		<tr>
			<td class="windowbg2" valign="middle" align="center" colspan="8"><br />$messageindex_txt{'840'}<br /><br /></td>
		</tr>
		~;
	}

	$yabbicons = qq~
		<img src="$imagesdir/thread.gif" alt="$messageindex_txt{'457'}" title="$messageindex_txt{'457'}" /> $messageindex_txt{'457'}<br />
		<img src="$imagesdir/sticky.gif" alt="$messageindex_txt{'779'}" title="$messageindex_txt{'779'}" /> $messageindex_txt{'779'}<br />
		<img src="$imagesdir/locked.gif" alt="$messageindex_txt{'456'}" title="$messageindex_txt{'456'}" /> $messageindex_txt{'456'}<br />
		<img src="$imagesdir/stickylock.gif" alt="$messageindex_txt{'780'}" title="$messageindex_txt{'780'}" /> $messageindex_txt{'780'}<br />
	~;

	if ($staff) {
		$yabbadminicons = qq~<img src="$imagesdir/hide.gif" alt="$messageindex_txt{'458'}" title="$messageindex_txt{'458'}" /> $messageindex_txt{'458'}<br />~;
		$yabbadminicons .= qq~<img src="$imagesdir/hidesticky.gif" alt="$messageindex_txt{'459'}" title="$messageindex_txt{'459'}" /> $messageindex_txt{'459'}<br />~;
		$yabbadminicons .= qq~<img src="$imagesdir/hidelock.gif" alt="$messageindex_txt{'460'}" title="$messageindex_txt{'460'}" /> $messageindex_txt{'460'}<br />~;
		$yabbadminicons .= qq~<img src="$imagesdir/hidestickylock.gif" alt="$messageindex_txt{'461'}" title="$messageindex_txt{'461'}" /> $messageindex_txt{'461'}<br />~;
	}

	$yabbadminicons .= qq~
		<img src="$imagesdir/announcement.gif" alt="$messageindex_txt{'779a'}" title="$messageindex_txt{'779a'}" /> $messageindex_txt{'779a'}<br />
	<img src="$imagesdir/announcementlock.gif" alt="$messageindex_txt{'779b'}" title="$messageindex_txt{'779b'}" /> $messageindex_txt{'779b'}<br />
		<img src="$imagesdir/hotthread.gif" alt="$messageindex_txt{'454'} $HotTopic $messageindex_txt{'454a'}" title="$messageindex_txt{'454'} $HotTopic $messageindex_txt{'454a'}" /> $messageindex_txt{'454'} $HotTopic $messageindex_txt{'454a'}<br />
		<img src="$imagesdir/veryhotthread.gif" alt="$messageindex_txt{'455'} $VeryHotTopic $messageindex_txt{'454a'}" title="$messageindex_txt{'455'} $VeryHotTopic $messageindex_txt{'454a'}" /> $messageindex_txt{'455'} $VeryHotTopic $messageindex_txt{'454a'}<br />
	~;

	$formstart = qq~<form name="multiremfav" action="$scripturl?board=$currentboard;action=multiremfav" method="post" style="display: inline">~;
	$formend   = qq~<input type="hidden" name="allpost" value="$INFO{'start'}" /></form>~;

	&LoadAccess;

	$adminselector = qq~
	<input type="submit" value="$messageindex_txt{'842'}" class="button" />
	~;

	$admincheckboxes = qq~
	<input type="checkbox" name="checkall" id="checkall" value="" class="titlebg" style="border: 0px;" onclick="if (this.checked) checkAll(0); else uncheckAll(0);" />
	~;
	$subfooterbar =~ s/({|<)yabb admin selector(}|>)/$adminselector/g;
	$subfooterbar =~ s/({|<)yabb admin checkboxes(}|>)/$admincheckboxes/g;

	# Template it
	$adminheader =~ s/({|<)yabb admin(}|>)/$messageindex_txt{'2'}/g;

	$messageindex_template =~ s/({|<)yabb home(}|>)//g;
	$messageindex_template =~ s/({|<)yabb category(}|>)//g;

	$yynavigation = qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $img_txt{'70'}~;

	$favboard = qq~<span class="nav">$img_txt{'70'}</span>~;
	$messageindex_template =~ s/({|<)yabb board(}|>)/$favboard/g;
	$messageindex_template =~ s/({|<)yabb moderators(}|>)//g;
	$bdescrip = qq~$messageindex_txt{'75'}<br />$messageindex_txt{'76'} $curfav $messageindex_txt{'77'} $maxfavs $messageindex_txt{'78'}~;
	$treplies = &NumberFormat($treplies);

	&ToChars($bdescrip);
	$boarddescription      =~ s/({|<)yabb boarddescription(}|>)/$bdescrip/g;
	$messageindex_template =~ s/({|<)yabb description(}|>)/$boarddescription/g;
	$bdpic = qq~ <img src="$imagesdir/favboards.gif" alt="$img_txt{'70'}" title="$img_txt{'70'}" border="0" align="middle" /> ~;
	$messageindex_template =~ s/({|<)yabb bdpicture(}|>)/$bdpic/g;
	$messageindex_template =~ s/({|<)yabb threadcount(}|>)/$curfav/g;
	$messageindex_template =~ s/({|<)yabb messagecount(}|>)/$treplies/g;

	$messageindex_template =~ s/({|<)yabb colspan(}|>)/$colspan/g;
	$messageindex_template =~ s/({|<)yabb notify button(}|>)//g;
	$messageindex_template =~ s/({|<)yabb markall button(}|>)//g;
	$messageindex_template =~ s/({|<)yabb new post button(}|>)//g;
	$messageindex_template =~ s/({|<)yabb new poll button(}|>)//g;
	$messageindex_template =~ s/({|<)yabb pageindex top(}|>)//g;
	$messageindex_template =~ s/({|<)yabb pageindex bottom(}|>)//g;
	$messageindex_template =~ s/({|<)yabb topichandellist(}|>)//g;
	$messageindex_template =~ s/({|<)yabb pageindex toggle(}|>)//g;

	$messageindex_template =~ s/({|<)yabb admin column(}|>)/$adminheader/g;
	$messageindex_template =~ s/({|<)yabb modupdate(}|>)/$formstart/g;
	$messageindex_template =~ s/({|<)yabb modupdateend(}|>)/$formend/g;

	$messageindex_template =~ s/({|<)yabb stickyblock(}|>)//g;
	$messageindex_template =~ s/({|<)yabb threadblock(}|>)/$tmptempbar/g;
	$messageindex_template =~ s/({|<)yabb adminfooter(}|>)/$subfooterbar/g;
	$messageindex_template =~ s/({|<)yabb icons(}|>)/$yabbicons/g;
	$messageindex_template =~ s/({|<)yabb admin icons(}|>)/$yabbadminicons/g;
	$messageindex_template =~ s/({|<)yabb rss(}|>)//g;
	$messageindex_template =~ s/({|<)yabb rssfeed(}|>)//g;
	$showFavorites .= qq~$messageindex_template~;

	$showFavorites .= qq~
<script language="JavaScript1.2" type="text/javascript">
	<!--
		function checkAll(j) {
			for (var i = 0; i < document.multiremfav.elements.length; i++) {
				if (j == 0 ) {document.multiremfav.elements[i].checked = true;}
			}
		}
		function uncheckAll(j) {
			for (var i = 0; i < document.multiremfav.elements.length; i++) {
				if (j == 0 ) {document.multiremfav.elements[i].checked = false;}
			}
		}
		function ListPages(tid) { window.open('$scripturl?action=pages;num='+tid, '', 'menubar=no,toolbar=no,top=50,left=50,scrollbars=yes,resizable=no,width=400,height=300'); }
	//-->
</script>
	~;

	$yytitle = $img_txt{'70'};
}

sub AddFav {
	my $favo = $INFO{'fav'} || $_[0];
	my $goto = $INFO{'start'} || $_[1] || 0;
	my $return = $_[2];

	&fatal_error("error_occurred",'',1) if $favo =~ /\D/;

	my @oldfav = split(/,/, ${$uid.$username}{'favorites'});
	if (@oldfav < ($maxfavs || 10)) {
		push(@oldfav, $favo);
		${$uid.$username}{'favorites'} = join(",", &undupe(@oldfav));
		&UserAccount($username, "update");
	}
	if (!$return) {
		if ($INFO{'oldaddfav'}) {
			$yySetLocation = qq~$scripturl?num=$favo/$goto~;
			&redirectexit;
		}
		$elenable = 0;
		die ""; # This is here only to avoid server error log entries!
	}
}

sub MultiRemFav {
	while ($maxfavs >= $count) {
		&RemFav($FORM{"admin$count"});
		$count++;
	}
	$yySetLocation = qq~$scripturl?action=favorites~;
	&redirectexit;
}

sub RemFav {
	my $favo = $INFO{'fav'}   || $_[0];
	my $goto = $INFO{'start'} || $_[1];
	if (!$goto) { $goto = 0; }

	my @newfav;
	foreach (split(/,/, ${$uid.$username}{'favorites'})) {
		push(@newfav, $_) if $favo ne $_;
	}

	${$uid.$username}{'favorites'} = join(",", &undupe(@newfav));
	&UserAccount($username, "update");

	return if $_[1] eq "nonexist";
	if ($INFO{'ref'} ne "delete" && $action ne "multiremfav" && $INFO{'oldaddfav'}) {
		$yySetLocation = qq~$scripturl?num=$favo/$goto~;
		&redirectexit;
	}
	if ($action eq 'remfav') {
		$elenable = 0;
		die ""; # This is here only to avoid server error log entries!
	}
}

sub IsFav {
	my $favo = $_[0];
	my $goto = $_[1] || 0;
	my $postcheck = $_[2];

	$addrem_fav .= qq~\n
		var addlink = '$img{'addfav'}';
		var remlink = '$img{'remfav'}';\n~ if !$postcheck;

	my @oldfav = split(/,/, ${$uid.$username}{'favorites'});
	my ($button,$nofav);
	if (@oldfav < ($maxfavs || 10)) {
		$button = qq~$menusep<a href="javascript:AddRemFav('$scripturl?action=addfav;fav=$favo;start=$goto','$imagesdir')" name="favlink">$img{'addfav'}</a>~;
		$nofav = 1;
	} else { $nofav = 2; }

	foreach (@oldfav) {
		if ($favo eq $_) {
			$button = qq~$menusep<a href="javascript:AddRemFav('$scripturl?action=remfav;fav=$favo;start=$goto','$imagesdir')" name="favlink">$img{'remfav'}</a>~;
			$nofav = 0;
		}
	}
	(!$postcheck ? $button : $nofav);
} 

1;