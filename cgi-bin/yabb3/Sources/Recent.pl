###############################################################################
# Recent.pl                                                                   #
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

$recentplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

# Sub Recent_Topics_Posts shows
# - all the most recently posted topics (recenttopics)
# - OR the X last POSTS (recent)
# Meaning each thread will show up ONCE in the list (recenttopics)
# OR all new post will be shown even if from the same thread (recent)

sub Recent_Topics_Posts {
	&spam_protection;

	my ($recent_topics, $display, @data, $numfound, %catid, %catname, $curboard, $boardperms, $i, $c, @mess, @messages, $tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $mns, $mtime, $board, $notify, $registrationdate, $icanbypass, @bdlist);

	$recent_topics = $action eq 'recenttopics' ? 1 : 0;

	$display = $FORM{'display'} || $INFO{'display'} || 10;
	if ($display < 0) { $display = 5; }
	elsif ($display > $maxrecentdisplay) { $display = $maxrecentdisplay; }

	$numfound = 0;
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	foreach my $catid (@categoryorder) {
		my ($catname, $catperms) = split(/\|/, $catinfo{$catid});
		unless (&CatAccess($catperms)) { next; }
		(@bdlist) = split(/\,/, $cat{$catid});
		&recursive_check(@bdlist)
	}

	sub recursive_check {
		foreach $curboard (@_) {
			($boardname{$curboard}, $boardperms, undef) = split(/\|/, $board{$curboard});

			if (!$iamadmin && &AccessCheck($curboard, '', $boardperms) ne "granted") { next; }

			$catid{$curboard} = $catid;
			$catname{$curboard} = $catname;

			my @buffer = &read_DBorFILE(0,'',$boardsdir,$curboard,'txt');
			for ($i = 0; ($i < $display && $buffer[$i]); $i++) {
				($tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate) = split(/\|/, $buffer[$i]);
				chomp $tstate;
				if ($tstate !~ /h/ || $iamadmin || $iamgmod) {
					$data[$numfound] = "$tdate|$curboard|$tnum|$treplies|$tusername|$tname|$tstate";
					$numfound++;
				}
			}
			if($subboard{$curboard}) { &recursive_check(split(/\|/,$subboard{$curboard})); }
		}
	}

	@data = sort {$b <=> $a} @data;

	$numfound = 0;
	$notify = $recent_topics ? scalar @data : (@data > $display ? $display : scalar @data);
	for ($i = 0; $i < $notify; $i++) {
		($mtime, $curboard, $tnum, $treplies, $tusername, $tname, $tstate) = split(/\|/, $data[$i]);

		next if !(@mess = &read_DBorFILE(0,'',$datadir,$tnum,'txt'));

		for ($c = ($recent_topics ? $#mess : (@mess > $display ? @mess - $display : 0)); $c < @mess; $c++) {
			chomp($mess[$c]);
			if ($mess[$c]) {
				($msub, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $message, $mns) = split(/\|/, $mess[$c]);
				$messages[$numfound] = "$mdate|$curboard|$tnum|$c|$tusername|$tname|$msub|$mname|$memail|$mdate|$musername|$micon|$mreplyno|$mip|$message|$mns|$tstate|$mtime";
				$numfound++;
			}
		}
		if ($recent_topics && $numfound == $display) { last; }
	}

	@messages  = sort {$b <=> $a} @messages;

	if ($numfound > 0) {
		if ($numfound > $display) { $numfound = $display; }
		&LoadCensorList;
		$icanbypass = &checkUserLockBypass;
	} else {
		$yymain .= qq~<hr class="hr" /><b>$maintxt{'170'}</b><hr />~;
	}

	for ($i = 0; $i < $numfound; $i++) {
		(undef, $board, $tnum, $c, $tusername, $tname, $msub, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $message, $mns, $tstate, $trstart) = split(/\|/, $messages[$i]);

		if ($tusername ne 'Guest') { &LoadUser($tusername); }
		if (${$uid.$tusername}{'regtime'}) {
			$registrationdate = ${$uid.$tusername}{'regtime'};
		} else {
			$registrationdate = $date;
		}

		if (${$uid.$tusername}{'regdate'} && $trstart > $registrationdate) {
			$tname = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$tusername}" rel="nofollow">${$uid.$tusername}{'realname'}</a>~;
		} elsif ($tusername !~ m~Guest~ && $trstart < $registrationdate) {
			$tname = qq~$tname - $maintxt{'470a'}~;
		} else {
			$tname = "$tname ($maintxt{'28'})";
		}

		if ($musername ne 'Guest') { &LoadUser($musername); }
		if (${$uid.$musername}{'regtime'}) {
			$registrationdate = ${$uid.$musername}{'regtime'};
		} else {
			$registrationdate = $date;
		}

		if (${$uid.$musername}{'regdate'} && $mdate > $registrationdate) {
			$mname = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}" rel="nofollow">${$uid.$musername}{'realname'}</a>~;
		} elsif ($musername !~ m~Guest~ && $mdate < $registrationdate) {
			$mname = qq~$mname - $maintxt{'470a'}~;
		} else {
			$mname = "$mname ($maintxt{'28'})";
		}

		&wrap;
		($message, undef) = &Split_Splice_Move($message,$tnum);
		if ($enable_ubbc) {
			$ns = $mns;
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC;
		}
		&wrap2;
		&ToChars($message);
		$message = &Censor($message);

		($msub, undef) = &Split_Splice_Move($msub,0);
		&ToChars($msub);
		$msub = &Censor($msub);

		if ($iamguest) {
			$notify = '';
		} else {
			if (${$uid.$username}{'thread_notifications'} =~ /\b$tnum\b/) {
				$notify = qq~$menusep<a href="$scripturl?action=notify3;num=$tnum/$c;oldnotify=1">$img{'del_notify'}</a>~;
			} else {
				$notify = qq~$menusep<a href="$scripturl?action=notify2;num=$tnum/$c;oldnotify=1">$img{'add_notify'}</a>~;
			}
		}
		$mdate = &timeformat($mdate);

		# generate a sub board tree
		my $boardtree = '';
		my $parentboard = $board;
		while($parentboard) {
			my ($pboardname, undef, undef) = split(/\|/, $board{"$parentboard"});
			&ToChars($pboardname);
			if(${$uid.$parentboard}{'canpost'}) {
				$pboardname = qq~<a href="$scripturl?board=$parentboard"><u>$pboardname</u></a>~;
			} else {
				$pboardname = qq~<a href="$scripturl?boardselect=$parentboard&subboards=1"><u>$pboardname</u></a>~;
			}
			$boardtree = qq~ / $pboardname$boardtree~;
			$parentboard = ${$uid.$parentboard}{'parent'};
		}

		$yymain .= qq~
<table border="0" width="100%" cellspacing="0" class="tabtitle">
	<tr>
		<td align="center" width="5%" class="round_top_left">~ . ($i + 1) . qq~</td>
		<td align="left" width="95%" class="round_top_right">&nbsp;<a href="$scripturl?catselect=$catid{$board}"><u>$catname{$board}</u></a>$boardtree / <a href="$scripturl?num=$tnum/$c#$c"><u>$msub</u></a><br />
		&nbsp;<span class="small">$maintxt{'30'}: $mdate</span>&nbsp;</td>
	</tr>
</table>
<table border="0" width="100%" cellspacing="1" cellpadding="0" class="bordercolor" style="table-layout: fixed;">
	<tr>
		<td>
			<table border="0" cellspacing="0" width="100%" class="titlebg">
				<tr>
					<td align="left" style="padding-left:5px">$maintxt{'109'} $tname | $maintxt{'197'} $mname</td>
					<td align="right">&nbsp;~;

		if ($tstate != 1 && (!$iamguest || $enable_guestposting)) {
			$yymain .= qq~<a href="$scripturl?board=$board;action=post;num=$tnum/$c#$c;title=PostReply">$img{'reply'}</a>$menusep<a href="$scripturl?board=$board;action=post;num=$tnum;quote=$c;title=PostReply">$img{'recentquote'}</a>$notify~;
		}

		if ($staff && ($icanbypass || $tstate !~ /l/i) && (!$iammod || &is_moderator($username,$board))) {
				&LoadLanguage('Display');
				$yymain .= $recent_topics ? qq~$menusep<a href="$scripturl?action=removethread;recent=1;thread=$tnum" onclick="return confirm('~ . (($icanbypass && $tstate =~ /l/i) ? qq~$display_txt{'modifyinlocked'}\\n\\n~ : '') . qq~$display_txt{'162'}')">$img{'delete'}</a>~ :
				                            qq~$menusep<a href="$scripturl?action=multidel;recent=1;thread=$tnum;del$c=$c" onclick="return confirm('~ . (($icanbypass && $tstate =~ /l/i) ? qq~$display_txt{'modifyinlocked'}\\n\\n~ : '') . qq~$display_txt{'rempost'}')">$img{'delete'}</a>~;
		}

		$yymain .= qq~ &nbsp;
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="left" style="padding:5px" height="80" class="windowbg2" valign="top"><div class="message" style="float: left; width: 99%; overflow: auto;">$message</div></td>
	</tr>
</table><br />
~;
	}

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

	if ($recent_topics) {
		$yynavigation = qq~&rsaquo; $maintxt{'214b'}~;
		$yytitle = $maintxt{'214b'};
	} else {
		$yynavigation = qq~&rsaquo; $maintxt{'214'}~;
		$yytitle = $maintxt{'214'};
	}
	&template;
}

1;