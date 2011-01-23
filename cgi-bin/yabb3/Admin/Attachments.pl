###############################################################################
# Attachments.pl                                                              #
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

$attachmentsplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub Attachments {
	&is_admin_or_gmod;

	my @attachments = &read_DBorFILE(1,'',$vardir,'attachments','txt');

	my $attachment_space = 0;
	foreach (@attachments) {
		$attachment_space += (split /\|/, $_, 7)[5];
	}

	my $remaining_space;
	if (!$dirlimit) {
		$remaining_space = "$fatxt{'23'}";
	} else {
		$remaining_space = ($dirlimit - $attachment_space) . " KB";
	}

	$maxdaysattach = &read_DBorFILE(1,'',$vardir,'oldestattach','txt');

	$maxsizeattach = &read_DBorFILE(1,'',$vardir,'maxattachsize','txt');

	my $totalattachnum = @attachments;
	$yymain .= qq~
<table border="0" width="70%" cellspacing="1" cellpadding="3" class="bordercolor" align="center">
<tr>
<td class="titlebg">
<img src="$imagesdir/xx.gif" alt="" />
<b>$fatxt{'24'}</b></td>
</tr><tr>
<td class="windowbg"><br /><span class="small">$fatxt{'25'}</span><br /><br /></td>
</tr><tr>
<td width="460" class="catbg"><b>$fatxt{'26'}</b></td>
</tr><tr>
<td class="windowbg" height="21">
<b>$fatxt{'27'}</b><br /></td>
</tr><tr>
<td class="windowbg2">
<table border="0" cellpadding="3" cellspacing="0"><tr>
<td><span class="small"><b>$fatxt{'28'}</b></span></td>
<td><span class="small">$totalattachnum</span></td>
</tr><tr>
<td><span class="small"><b>$fatxt{'29'}</b></span></td>
<td><span class="small">$attachment_space KB</span><br /></td>
</tr><tr>
<td><span class="small"><b>$fatxt{'30'}</b></span></td>
<td><span class="small">$remaining_space</span></td>
</tr>
</table><br />
</td>
</tr><tr>
<td class="windowbg" height="21">
<b>$fatxt{'31'}</b><br /></td>
</tr><tr>
<td class="windowbg2">
<table border="0" cellpadding="3" cellspacing="0">
<tr>
<form action="$adminurl?action=removeoldattachments" method="post">
<td><span class="small">$fatxt{'32'}</span></td>
<td><span class="small"><input type="text" name="maxdaysattach" size="2" value="$maxdaysattach" /> $fatxt{'58'}&nbsp;</span></td>
<td><input type="submit" value="$admin_txt{'32'}" class="button" /></td>
</form>
</tr><tr>
<form action="$adminurl?action=removebigattachments" method="post">
<td><span class="small">$fatxt{'33'}</span></td>
<td><span class="small"><input type="text" name="maxsizeattach" size="2" value="$maxsizeattach" /> KB&nbsp;</span></td>
<td><input type="submit" value="$admin_txt{'32'}" class="button" /></td>
</form>
</tr><tr>
<td colspan="3"><span class="small" style="font-weight: bold;"><a href="$adminurl?action=manageattachments2">$fatxt{'31a'}</a></span> | <span class="small" style="font-weight: bold;"><a href="$adminurl?action=rebuildattach">$fatxt{'63'}</a></span></td>
</tr>
</table>
</td>
</tr>
</table>~;

	$yytitle = "$fatxt{'36'}";
	$action_area = "manageattachments";
	&AdminTemplate;
}

sub RemoveOldAttachments {
	&is_admin_or_gmod;

	my $maxdaysattach = $FORM{'maxdaysattach'} || $INFO{'maxdaysattach'};
	if ($maxdaysattach !~ /^[0-9]+$/) { &fatal_error("only_numbers_allowed"); }

	# Set up the multi-step action
	$time_to_jump = time() + $max_process_time;

	&automaintenance('on');

	opendir(ATT, $uploaddir) || &fatal_error('cannot_open', "$uploaddir", 1);
	my @attachments = sort( grep(/\w+$/, readdir(ATT)) );
	closedir(ATT);

	my @attachmentstxt = &read_DBorFILE(1,'',$vardir,'attachments','txt');

	my (%att,@line);
	foreach (@attachmentstxt) {
		@line = split(/\|/, $_);
		$att{$line[7]} = $line[0];
	}

	my $info;
	if (!@attachments) {
		&write_DBorFILE(0,'',$vardir,'attachments','txt',(''));

		$info = qq~<br /><i>$fatxt{'48'}.</i>~;

	} else {
		&delete_DBorFILE("$vardir/rem_old_attach.tmp") unless exists $INFO{'next'};

		my %rem_attachments;
		for (my $a = ($INFO{'next'} || 0); $a < @attachments; $a++) {
			# -M => Script start time minus file modification time, in days.
			my $age = sprintf("%.2f", -M "$uploaddir/$attachments[$a]");
			if ($age <= $maxdaysattach) {
				# If the attachment is not too old
				$info .= qq~<br />$attachments[$a] = $age $admin_txt{'122'}.~;

			} elsif (exists $att{$attachments[$a]}) {
				$rem_attachments{$att{$attachments[$a]}} .= $rem_attachments{$att{$attachments[$a]}} ? "|$attachments[$a]" : $attachments[$a];
				$info .= qq~<br /><i>$attachments[$a]</i> $fatxt{'1'} = $age $admin_txt{'122'}.~;
			}

			if ($time_to_jump < time() && ($a + 1) < @attachments) { 
				# save the $info of this run until the end of 'RemoveOldAttachments'
				&write_DBorFILE(0,FILE,$vardir,'rem_old_attach','tmp',(&read_DBorFILE(1,FILE,$vardir,'rem_old_attach','tmp'),$info));

				$yySetLocation = qq~$adminurl?action=removeoldattachments;maxdaysattach=$maxdaysattach;next=~ . ($a + 1 - &RemoveAttachments(\%rem_attachments));
				&redirectexit;
			}
		}

		&RemoveAttachments(\%rem_attachments);
	}

	&automaintenance('off');

	$yymain .= qq~<b>$fatxt{'32'} $maxdaysattach $fatxt{'58'}.</b><br />~;

	$yymain .= join('', &read_DBorFILE(1,'',$vardir,'rem_old_attach','tmp')) . $info;
	&delete_DBorFILE("$vardir/rem_old_attach.tmp");

	&write_DBorFILE(0,'',$vardir,'oldestattach','txt',($maxdaysattach));

	$yytitle     = "$fatxt{'34'} $maxdaysattach";
	$action_area = "removeoldattachments";
	&AdminTemplate;
}

sub RemoveBigAttachments {
	&is_admin_or_gmod;

	my $maxsizeattach = $FORM{'maxsizeattach'} || $INFO{'maxsizeattach'};
	if ($maxsizeattach !~ /^[0-9]+$/) { &fatal_error("only_numbers_allowed"); }

	# Set up the multi-step action
	$time_to_jump = time() + $max_process_time;

	&automaintenance('on');

	opendir(ATT, $uploaddir) || &fatal_error('cannot_open', "$uploaddir", 1);
	my @attachments = sort( grep(/\w+$/, readdir(ATT)) );
	closedir(ATT);

	@attachmentstxt = &read_DBorFILE(1,'',$vardir,'attachments','txt');

	my (%att,@line);
	foreach (@attachmentstxt) {
		@line = split(/\|/, $_);
		$att{$line[7]} = $line[0];
	}

	my $info;
	if (!@attachments) {
		&write_DBorFILE(0,'',$vardir,'attachments','txt',(''));

		$info = qq~<br /><i>$fatxt{'48'}.</i>~;

	} else {
		&delete_DBorFILE("$vardir/rem_big_attach.tmp") unless exists $INFO{'next'};

		my (%rem_attachments,@line);
		for ($a = ($INFO{'next'} || 0); $a < @attachments; $a++) {
			my $size = sprintf("%.2f", ((-s "$uploaddir/$attachments[$a]") / 1024));
			if ($size <= $maxsizeattach) {
				# If the attachment is not too big
				$info .= qq~<br />$attachments[$a] = $size KB~;

			} elsif (exists $att{$attachments[$a]}) {
				$rem_attachments{$att{$attachments[$a]}} .= $rem_attachments{$att{$attachments[$a]}} ? "|$attachments[$a]" : $attachments[$a];
				$info .= qq~<br /><i>$attachments[$a]</i> $fatxt{'1'} = $size KB~;
			}

			if ($time_to_jump < time() && ($a + 1) < @attachments) { 
				# save the $info of this run until the end of 'RemoveBigAttachments'
				&write_DBorFILE(0,FILE,$vardir,'rem_big_attach','tmp',(&read_DBorFILE(1,FILE,$vardir,'rem_big_attach','tmp'),$info));

				$yySetLocation = qq~$adminurl?action=removebigattachments;maxsizeattach=$maxsizeattach;next=~ . ($a + 1 - &RemoveAttachments(\%rem_attachments));
				&redirectexit;
			}
		}

		&RemoveAttachments(\%rem_attachments);
	}

	$yymain .= qq~<b>$fatxt{'33'} $maxsizeattach KB.</b><br />~;

	$yymain .= join('', &read_DBorFILE(1,'',$vardir,'rem_big_attach','tmp')) . $info;
	&delete_DBorFILE("$vardir/rem_big_attach.tmp");

	&write_DBorFILE(0,'',$vardir,'maxattachsize','txt',($maxsizeattach));

	&automaintenance('off');

	$yytitle = "$fatxt{'35'} $maxsizeattach KB";
	$action_area = "removebigattachments";
	&AdminTemplate;
}

sub Attachments2 {
	&is_admin_or_gmod;

	my @attachinput = &read_DBorFILE(1,'',$vardir,'attachments','txt');
	my $max = @attachinput;

	my $action = $INFO{'action'};
	my $sort = $INFO{'sort'} || 6;
	my $newstart = $INFO{'newstart'} || 0;

	if (!$max) {
		$viewattachments .= qq~<tr><td class="windowbg2" colspan="8"><center><b><i>$fatxt{'48'}</i></b></center></td></tr>~;

	} else {
		$yymain .= qq~
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			function checkAll() {
  				for (var i = 0; i < document.del_attachments.elements.length; i++) {
					document.del_attachments.elements[i].checked = true;
	  			}
			}
			function uncheckAll() {
  				for (var i = 0; i < document.del_attachments.elements.length; i++) {
					document.del_attachments.elements[i].checked = false;
	  			}
			}
		//-->
		</script>

		<form name="del_attachments" action="$adminurl?action=deleteattachment" method="post" style="display: inline;">~;

		my @attachments;
		if ($sort > 0) { # sort ascending
			if ($sort == 5 || $sort == 6 || $sort == 8) {
				@attachments = sort { (split(/\|/, $a))[$sort] <=> (split(/\|/, $b))[$sort]; } @attachinput; # sort size, date, count numerically
			} elsif ($sort == 100) {
				@attachments = sort { lc((split(/\./, (split(/\|/, $a))[7]))[1]) cmp lc((split(/\./, (split(/\|/, $b))[7]))[1]); } @attachinput; # sort extension lexically
			} else {
				@attachments = sort { lc((split(/\|/, $a))[$sort]) cmp lc((split(/\|/, $b))[$sort]); } @attachinput; # sort lexically
			}
		} else { # sort descending
			if ($sort == -5 || $sort == -6 || $sort == -8) {
				@attachments = sort { (split(/\|/, $b))[-$sort] <=> (split(/\|/, $a))[-$sort]; } @attachinput; # sort size, date, count numerically
			} elsif ($sort == -100) {
				@attachments = sort { lc((split(/\./, (split(/\|/, $b))[7]))[1]) cmp lc((split(/\./, (split(/\|/, $a))[7]))[1]); } @attachinput; # sort extension lexically
			} else {
				@attachments = sort { lc((split(/\|/, $b))[-$sort]) cmp lc((split(/\|/, $a))[-$sort]); } @attachinput; # sort lexically
			}
		}

		$postdisplaynum = 8;
		$newstart = (int($newstart / 25)) * 25;
		$tmpa = 1;
		if ($newstart >= (($postdisplaynum - 1) * 25)) { $startpage = $newstart - (($postdisplaynum - 1) * 25); $tmpa = int( $startpage / 25 ) + 1; }
		if ($max >= $newstart + ($postdisplaynum * 25)) { $endpage = $newstart + ($postdisplaynum * 25); } else { $endpage = $max; }
		if ($startpage > 0) { $pageindex = qq~<a href="$adminurl?action=$action;newstart=0;sort=$sort" style="font-weight: normal;">1</a>&nbsp;...&nbsp;~; }
		if ($startpage == 25) { $pageindex = qq~<a href="$adminurl?action=$action;newstart=0;sort=$sort" style="font-weight: normal;">1</a>&nbsp;~;}
		for ($counter = $startpage; $counter < $endpage; $counter += 25) {
			$pageindex .= $newstart == $counter ? qq~<b>$tmpa</b>&nbsp;~ : qq~<a href="$adminurl?action=$action;newstart=$counter;sort=$sort" style="font-weight: normal;">$tmpa</a>&nbsp;~;
			$tmpa++;
		}
		$lastpn = int($max / 25) + 1;
		$lastptn = ($lastpn - 1) * 25;
		if ($endpage < $max - (25) ) { $pageindexadd = qq~...&nbsp;~; }
		if ($endpage != $max) { $pageindexadd .= qq~<a href="$adminurl?action=$action;newstart=$lastptn;sort=$sort">$lastpn</a>~; }
		$pageindex .= $pageindexadd;

		$pageindex = qq~<div class="small" style="text-align: right; vertical-align: middle;">$fatxt{'64'}: $pageindex</div>~;

		$numbegin = ($newstart + 1);
		$numend = ($newstart + 25);
		if ($numend > $max) { $numend  = $max; }
		if ($max == 0) { $numshow = ''; }
		else { $numshow = qq~($numbegin - $numend)~; }

		my (%attach_gif,$ext);
		foreach $row (splice(@attachments, $newstart, 25)) {
			my ($amthreadid, $amreplies, $amthreadsub, $amposter, $amcurrentboard, $amkb, $amdate, $amfn, $amcount) = split(/\|/, $row);

			$amfn =~ /\.(.+?)$/;
			$ext = $1;
			unless (exists $attach_gif{$ext}) {
				$attach_gif{$ext} = ($ext && -e "$forumstylesdir/$useimages/$ext.gif") ? "$ext.gif" : "paperclip.gif";
			}

			$amdate = &timeformat($amdate);
			if (length($amthreadsub) > 20) { $amthreadsub = substr($amthreadsub, 0, 20) . "..."; }

			$viewattachments .= qq~
		<tr>
		<td class="windowbg2" align="center" valign="middle"><input type="checkbox" name="del_$amthreadid" value="$amfn" /></td>
		<td class="windowbg2" align="left" valign="middle"><a href="$uploadurl/$amfn" target="_blank"> $amfn</a></td>
		<td class="windowbg2" align="center" valign="middle"><img src="$imagesdir/$attach_gif{$ext}" border="0" align="bottom" alt="" /></td>
		<td class="windowbg2" align="right" valign="middle">$amkb KB</td>
		<td class="windowbg2" align="center" valign="middle">$amdate</td>
		<td class="windowbg2" align="right" valign="middle">$amcount</td>
		<td class="windowbg2" align="left" valign="middle"><a href="$scripturl?num=$amthreadid/$amreplies#$amreplies" target="blank">$amthreadsub</a></td>
		<td class="windowbg2" align="center" valign="middle">$amposter</td>
		</tr>\n~;
		}

		$viewattachments .= qq~
		<tr>
		<td class="catbg" align="center">
		<input type="checkbox" name="checkall" id="checkall" value="" onclick="if(this.checked){checkAll();}else{uncheckAll();}" />
		</td>
		<td class="catbg" colspan="7">
		<div class="small" style="float: left; text-align: left;">
		&lt;= <label for="checkall">$amv_txt{'38'}</label> &nbsp; <input type="submit" value="$admin_txt{'32'}" class="button" />
		</div>
		$pageindex
		</td>
		</tr>
		~;

		$yymain .= qq~
		<input type="hidden" name="newstart" value="$newstart" />~;
	}

	my $class_sortattach = $sort =~ /7/   ? 'catbg' : 'windowbg';
	my $class_sorttype   = $sort =~ /100/ ? 'catbg' : 'windowbg';
	my $class_sortsize   = $sort =~ /5/   ? 'catbg' : 'windowbg';
	my $class_sortdate   = $sort =~ /6/   ? 'catbg' : 'windowbg';
	my $class_sorcount   = $sort =~ /8/   ? 'catbg' : 'windowbg';
	my $class_sortsubj   = $sort =~ /2/   ? 'catbg' : 'windowbg';
	my $class_sortuser   = $sort =~ /3/   ? 'catbg' : 'windowbg';

	$yymain .= qq~
<table border="0" cellspacing="1" cellpadding="8" class="bordercolor" align="center" width="90%">
	<tr>
		<td class="titlebg" colspan="8">
		<img src="$imagesdir/xx.gif" alt="" border="0" />&nbsp;<b>$fatxt{'39'}</b>
		</td>
	</tr><tr>
		<td class="windowbg" colspan="8">
		<br />
		<span class="small">$fatxt{'38'}</span>
		<br /><br />
		</td>
	</tr><tr>
		<td class="titlebg" colspan="8" align="center" width="100%"><b>$fatxt{'55'}</b></td>
	</tr><tr>
		<td class="titlebg" colspan="8" width="100%">
		<div class="small" style="float: left; text-align: left;">$fatxt{'28'} $max $numshow</div>
		$pageindex
		</td>
	</tr>
	<tr>
		<td align="center" class="windowbg"><b>$fatxt{'45'}</b></td>
		<td onclick="location.href='$adminurl?action=manageattachments2;sort=~ . ($sort == 7 ? -7 : 7) . qq~';" align="center" class="$class_sortattach" style="border: 0px; border-style: outset; cursor: pointer;"><a href="$adminurl?action=manageattachments2;sort=~ . ($sort == 7 ? -7 : 7) . qq~"><b>$fatxt{'40'}</b></a></td>
		<td onclick="location.href='$adminurl?action=manageattachments2;sort=~ . ($sort == 100 ? -100 : 100) . qq~';" align="center" class="$class_sorttype" style="border: 0px; border-style: outset; cursor: pointer;"><a href="$adminurl?action=manageattachments2;sort=~ . ($sort == 100 ? -100 : 100) . qq~"><b>$fatxt{'40a'}</b></a></td>
		<td onclick="location.href='$adminurl?action=manageattachments2;sort=~ . ($sort == 5 ? -5 : 5) . qq~';" align="center" class="$class_sortsize" style="border: 0px; border-style: outset; cursor: pointer;"><a href="$adminurl?action=manageattachments2;sort=~ . ($sort == -5 ? 5 : -5) . qq~"><b>$fatxt{'41'}</b></a></td>
		<td onclick="location.href='$adminurl?action=manageattachments2;sort=~ . ($sort == 6 ? -6 : 6) . qq~';" align="center" class="$class_sortdate" style="border: 0px; border-style: outset; cursor: pointer;"><a href="$adminurl?action=manageattachments2;sort=~ . ($sort == -6 ? 6 : -6) . qq~"><b>$fatxt{'43'}</b></a></td>
		<td onclick="location.href='$adminurl?action=manageattachments2;sort=~ . ($sort == 8 ? -8 : 8) . qq~';" align="center" class="$class_sorcount" style="border: 0px; border-style: outset; cursor: pointer;"><a href="$adminurl?action=manageattachments2;sort=~ . ($sort == -8 ? 8 : -8) . qq~"><b>$fatxt{'41a'}</b></a></td>
		<td onclick="location.href='$adminurl?action=manageattachments2;sort=~ . ($sort == 2 ? -2 : 2) . qq~';" align="center" class="$class_sortsubj" style="border: 0px; border-style: outset; cursor: pointer;"><a href="$adminurl?action=manageattachments2;sort=~ . ($sort == 2 ? -2 : 2) . qq~"><b>$fatxt{'44'}</b></a></td>
		<td onclick="location.href='$adminurl?action=manageattachments2;sort=~ . ($sort == 3 ? -3 : 3) . qq~';" align="center" class="$class_sortuser" style="border: 0px; border-style: outset; cursor: pointer;"><a href="$adminurl?action=manageattachments2;sort=~ . ($sort == 3 ? -3 : 3) . qq~"><b>$fatxt{'42'}</b></a></td>
	</tr>
	$viewattachments
</table>~;

	$yymain .= '</form>' if $max;

	$yytitle = "$fatxt{'37'}";
	$action_area = "manageattachments";
	&AdminTemplate;
}

sub DeleteAttachments {
	&is_admin_or_gmod;

	&automaintenance('on') if !$FORM{'formsession'};

	my %rem_att;
	foreach (keys(%FORM)) {
		next unless $_ =~ /^del_(\d+)$/;
		my $thread = $1;
		$rem_att{$thread} = $FORM{$_};
		$rem_att{$thread} =~ s/, /|/g;
	}

	&RemoveAttachments(\%rem_att);

	&automaintenance('off') if !$FORM{'formsession'};

	$yySetLocation = $FORM{'formsession'} ? qq~$scripturl?action=viewdownloads;thread=~ . (keys(%rem_att))[0] . qq~;newstart=$FORM{'newstart'}~ : qq~$adminurl?action=manageattachments2;newstart=$FORM{'newstart'}~;
	&redirectexit;
}

sub FullRebuildAttachents {
	&is_admin_or_gmod();

	unless (defined $INFO{'boardnum'}) {
		&automaintenance('on');

		&delete_DBorFILE("$vardir/newattachments.tmp");
		$yySetLocation = qq~$adminurl?action=rebuildattach;topicnum=0;boardnum=0~;
		&redirectexit();
	}

	# Set up the multi-step action
	$time_to_jump = time() + $max_process_time;

	# Get the board list from the forum.master file
	require "$boardsdir/forum.master";
	@boardlist = sort( keys(%board) );

	# Find the current board:
	my $curboard = $boardlist[$INFO{'boardnum'}];

	# store all downloadcounts in variable
	my %attachments;
	if (-s "$vardir/attachments.txt" > 5) {
		my ($atfile,$atcount);
		foreach (&read_DBorFILE(0,'',$vardir,'attachments','txt')) {
			(undef, undef, undef, undef, undef, undef, undef, $atfile, $atcount) =split(/\|/, $_);
			chomp $atcount;
			$attachments{$atfile} = $atcount;
		}
	}

	# Get the topic list.
	my @topiclist = &read_DBorFILE(0,'',$boardsdir,$curboard,"txt");

	my ($topicnum,@newattachments,$mreplies,$msub, $mname, $mdate, $mfn, $nexttopic);
	for (my $i = $INFO{'topicnum'}; $i < @topiclist; $i++) {
		($topicnum, undef) = split(/\|/, $topiclist[$i], 2);
		my @topic = &read_DBorFILE(0,'',$datadir,$topicnum,'txt');
		chomp(@topic);

		$mreplies = 0;
		foreach (@topic) {
			($msub, $mname, undef, $mdate, undef, undef, undef, undef, undef, undef, undef, undef, $mfn) = split(/\|/, $_);
			foreach (split(/,/, $mfn)) {
				if (-e "$uploaddir/$_") {
					my $asize = int((-s "$uploaddir/$_") / 1024) || 1;
					push (@newattachments, qq~$topicnum|$mreplies|$msub|$mname|$curboard|$asize|$mdate|$_|~ . ($attachments{$_} || 0) . qq~\n~);
				}
			}
			$mreplies++;
		}

		if (time() > $time_to_jump && ($i + 1) < @topiclist) {
			$nexttopic = $i + 1;
			last;
		}
	}

	if (@newattachments) {
		&write_DBorFILE(0,NEWATM,$vardir,'newattachments','tmp',(&read_DBorFILE(1,NEWATM,$vardir,'newattachments','tmp'),@newattachments));
	}

	# Prepare to continue...
	if ($nexttopic) { $INFO{'topicnum'} = $nexttopic; }
	else { $INFO{'boardnum'}++; $INFO{'topicnum'} = 0; }

	my $numleft = @boardlist - $INFO{'boardnum'};
	if ($numleft == 0) {
		my @newattachments = &read_DBorFILE(1,'',$vardir,'newattachments','tmp');

		&write_DBorFILE(0,'',$vardir,"attachments","txt",sort( { (split /\|/,$a)[6] <=> (split /\|/,$b)[6] } @newattachments));
		&delete_DBorFILE("$vardir/newattachments.tmp");

		&automaintenance("off");
		$yySetLocation = qq~$adminurl?action=remghostattach~;
		&redirectexit;
	}

	# Continue
	$action_area = 'manageattachments';
	$yytitle = "$fatxt{'37'}";

	$yymain .= qq~
		<br />
		$rebuild_txt{'1'}<br />
		$rebuild_txt{'5'} $max_process_time $rebuild_txt{'6'}<br />
		$rebuild_txt{'9'} ~ . (@boardlist - $INFO{'boardnum'}) . "/" . @boardlist . qq~<br />
		<br />
		<div id="attachcontinued">
		$rebuild_txt{'2'} <a href="$adminurl?action=rebuildattach;topicnum=$INFO{'topicnum'};boardnum=$INFO{'boardnum'}" onclick="rebAttach();">$rebuild_txt{'3'}</a>
		</div>
	<script type="text/javascript" language="JavaScript">
	<!--
		function rebAttach() {
			document.getElementById("attachcontinued").innerHTML = '$rebuild_txt{'4'}';
		}

		function attachtick() {
			rebAttach();
			location.href="$adminurl?action=rebuildattach;topicnum=$INFO{'topicnum'};boardnum=$INFO{'boardnum'}";
		}

		setTimeout("attachtick()",3000)
	// -->
	</script>~;

	&AdminTemplate();
}

sub RemoveGhostAttach {
	&is_admin_or_gmod;

	$yymain .= qq~<b>$fatxt{'62'}</b><br /><br />~;

	my @attachmentstxt = &read_DBorFILE(0,'',$vardir,'attachments','txt');

	my %att;
	foreach (@attachmentstxt) {
		$att{(split(/\|/, $_))[7]} = 1;
	}

	opendir(DIR, $uploaddir);
	my @filesDIR = grep(/\w+$/, readdir(DIR));
	close(DIR);

	$yymain .= qq~$fatxt{'61'}:<br />~;

	foreach my $fileinDIR (@filesDIR) {
		if (!$att{$fileinDIR}) {
			&delete_DBorFILE("$uploaddir/$fileinDIR");
			$yymain .= qq~<br />$fatxt{'61b'}: $fileinDIR~;
		}
	}

	$yymain .= qq~<br /><br /><b>$fatxt{'61a'}</b>~;
	$yytitle = $fatxt{'61'};
	$action_area = 'manageattachments';
	&AdminTemplate;
}

sub RemoveAttachments { # remove single or multiple attachments stored in a hash-reference
	my $count = 0;
	my $ThreadHashref = shift; # usage: ${$ThreadHashref}{'threadnum'} = 'filename1|filename2|...'
	                           # all attachments of thread are included if filname is undefined (undef)

	return $count if !%$ThreadHashref;

	my @attachments = &read_DBorFILE(0,ATM,$vardir,'attachments','txt');
	my ($athreadnum, $afilename, %del_filename, @new_attach);
	foreach (@attachments) {
		(undef, undef, undef, undef, undef, undef, undef, $afilename, undef) = split(/\|/, $_);
		$del_filename{$afilename}++;
	}
	for ($i = 0; $i < @attachments; $i++) {
		($athreadnum, undef, undef, undef, undef, undef, undef, $afilename, undef) = split(/\|/, $attachments[$i]);
		my $del = 0;
		if (exists ${$ThreadHashref}{$athreadnum}) {
			if (defined ${$ThreadHashref}{$athreadnum}) {
				foreach (split(/\|/, ${$ThreadHashref}{$athreadnum})) {
					if ($_ eq $afilename) { $del = 1; last; }
				}
			} else {
				$del = 1;
			}
		}
		if ($del) {
			# deletes the file only if NO other entry for the same filename is in the attachments.txt
			&delete_DBorFILE("$uploaddir/$afilename") if $del_filename{$afilename} == 1;
			$del_filename{$afilename}--;
			$count++;
		} else {
			push(@new_attach, $attachments[$i]);
		}
	}
	&write_DBorFILE(0,ATM,$vardir,'attachments','txt',@new_attach);

	$count;
}

1;