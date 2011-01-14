###############################################################################
# Search.pl                                                                   #
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

$searchplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('Search');

if($FORM{'searchboards'} =~ /\A\!/) {
	my $checklist = '';
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	foreach my $catid (@categoryorder) {
		(@bdlist) = split(/\,/,$cat{$catid});
		my ($catname, $catperms, $catallowcol) = split(/\|/, $catinfo{$catid});
		my $access = &CatAccess($catperms);
		if (!$access) { next; }
		
		recursive_search(@bdlist);
	}
	sub recursive_search {
		foreach my $curboard (@_) {
			chomp $curboard;
			# don't add to count if it's a sub board
			if(!${$uid.$curboard}{'parent'}) { $cat_boardcnt{$catid}++; }
			my ($boardname, $boardperms, $boardview) = split(/\|/, $board{$curboard});
			my $access = &AccessCheck($curboard, '', $boardperms);
			if (!$iamadmin && $access ne 'granted') { next; }
			$checklist .= qq~$curboard, ~;

			if($subboard{$curboard}) {
				&recursive_search(split(/\|/,$subboard{$curboard}));
			}
		}
	}
	$checklist =~ s/, \Z//;
	$FORM{'searchboards'} = $checklist;
}

sub plushSearch1 {
	# generate error if admin has disabled search options
	if ($maxsearchdisplay < 0) { &fatal_error("search_disabled"); }
	my (@categories, $curcat, %catname, %cataccess, %catboards, $openmemgr, @membergroups, $tmpa, %openmemgr, $curboard, @threads, @boardinfo, $counter);

	&LoadCensorList;
	if (!$iamguest) {
		&Collapse_Load;
	}
	$yymain .= qq~
<script language="JavaScript1.2" src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
<script language="JavaScript1.2" type="text/javascript">
<!--
function removeUser() {
	if (document.getElementById('userspec').value && confirm("$searchselector_txt{'removeconfirm'}")) {
		document.getElementById('userspec').value = "";
		document.getElementById('userspectext').value = "";
		if(document.getElementById('searchme').checked) {
			document.getElementById('searchme').checked = false;
			document.getElementById('userkind').disabled=false;
			document.getElementById('noguests').selected=true;
		}
		document.getElementById('usrsel').style.display = 'inline';
		document.getElementById('usrrem').style.display = 'none';
		document.getElementById('searchme').disabled = false;
	}
}

function addUser() {
	window.open('$scripturl?action=imlist;sort=username;toid=userspec','','status=no,height=360,width=464,menubar=no,toolbar=no,top=50,left=50,scrollbars=no');
}

function searchMe(chelem) {
	if(chelem.checked) {
		document.getElementById('userspectext').value='${$uid.$username}{'realname'}';
		document.getElementById('userspec').value='$username';
		document.getElementById('userkind').value='poster';
		document.getElementById('poster').selected=true;
		document.getElementById('userkind').disabled=true;
	} else {
		document.getElementById('userspectext').value='';
		document.getElementById('userspec').value='';
		document.getElementById('userkind').value='noguests';
		document.getElementById('noguests').selected=true;
		document.getElementById('userkind').disabled=false;
	}
}
//-->
</script>

<form action="$scripturl?action=search2" method="post" name="searchform" onsubmit="return CheckSearchFields();">
<table border="0" width="700" cellpadding="4" cellspacing="0" align="center" class="tabtitle">
	<tr>
		<td align="left" class="round_top_left" width="99%">
			<img src="$imagesdir/search.gif" alt="" /> <span class="text1"><b>$search_txt{'183'}</b></span>
		</td>
		<td class="round_top_right" width="1%">&nbsp;</td>
	</tr>
</table>
<table width="700" align="center" border="0" cellpadding="4" cellspacing="1" class="bordercolor" >
	<colgroup>
		<col width="45%" />
		<col width="55%" />
	</colgroup>
	<tr>
		<td class="windowbg" valign="top"><label for="search"><b>$search_txt{'582'}:</b></label></td>
		<td class="windowbg2">
			<div style="padding: 2px;">
			<input type="text" size="30" name="search" id="search" />
			<br /><br />
			<label for="searchtype">$search_txt{'582'}</label>
			<select name="searchtype" id="searchtype">
			<option value="allwords" selected="selected">$search_txt{'343'}</option>
			<option value="anywords">$search_txt{'344'}</option>
			<option value="asphrase">$search_txt{'345'}</option>
			<option value="aspartial">$search_txt{'345a'}</option>
			</select><br />
			<input type="checkbox" name="casesensitiv" id="casesensitiv" value="1" /><label for="casesensitiv">$search_txt{'casesensitiv'}</label>~ . ($enable_ubbc ? qq~<br />
			<input type="checkbox" name="searchyabbtags" id="searchyabbtags" value="1" /><label for="searchyabbtags">$search_txt{'searchyabbtags'}<br />$search_txt{'yabbtagswarn'}</label>~ : '') . qq~
			</div>~;

	if (!$ML_Allowed || ($ML_Allowed == 1 && !$iamguest) || ($ML_Allowed == 2 && $staff) || ($ML_Allowed == 3 && ($iamadmin || $iamgmod))) {
		$yymain .= qq~
		</td>
	</tr>
	<tr>
		<td class="windowbg" valign="top">
			<b>$search_txt{'583'}:</b>
		</td>
		<td class="windowbg2">
			<div style="padding: 4px 0px 4px 0px;">
			<input type="text" size="30" style="width: 220px; padding-left: 3px;" name="userspectext" id="userspectext" value="" readonly="readonly" /><input type="button" class="button" id="usrsel" style="border-left: 0px; display: inline;" value="$searchselector_txt{'select'}" onclick="javascript:addUser();" /><input type="button" class="button" id="usrrem" style="border-left: 0px; display: none;" value="$searchselector_txt{'remove'}" onclick="javascript:removeUser();" />
			~;

			$yymain .= qq~
			<input type="hidden" size="30" name="userspec" id="userspec" value="" />
			</div>
			<div style="padding: 4px 0px 4px 0px;">
			<select name="userkind" id="userkind">
				<option value="any">$search_txt{'577'}</option>
				<option value="starter">$search_txt{'186'}</option>
				<option id="poster" value="poster">$search_txt{'187'}</option>
				<option id="noguests" value="noguests" selected="selected">$search_txt{'346'}</option>
				<option value="onlyguests">$search_txt{'572'}</option>
			</select><br />~;

			if(!$iamguest) {
				$yymain .= qq~<input type="checkbox" name="searchme" id="searchme" style="margin: 0px; border: 0px; padding: 0px; vertical-align: middle;" onclick="searchMe(this);" /> <label for="searchme" class="lille">$search_txt{'searchme'}</label><br />~;
			} else {
				$yymain .= qq~<input type="checkbox" name="searchme" id="searchme" style="visibility: hidden;" /><br />~;
			}
			
			$yymain .= qq~</div> ~;

	} else {
		$yymain .= qq~<input type="hidden" name="userkind" value="any" />~;
	}

	$yymain .= qq~
		</td>
	</tr>
	<tr>
		<td class="windowbg" valign="top"><b>$search_txt{'189'}:</b><br /><span class="small">$search_txt{'190'}</span></td>
		<td class="windowbg2" >~;
	$allselected = 0;
	$isselected  = 0;
	$boardscheck = "";
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }

	foreach $catid (@categoryorder) {
		$boardlist = $cat{$catid};
		(@bdlist) = split(/\,/, $boardlist);
		($catname, $catperms) = split(/\|/, $catinfo{"$catid"});
		$cataccess = &CatAccess($catperms);
		if (!$cataccess) { next; }

		foreach $curboard (@bdlist) {
			($boardname, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});
			&ToChars($boardname);
			my $access = &AccessCheck($curboard, '', $boardperms);
			if (!$iamadmin && $access ne "granted") { next; }

			# Checks to see if category is expanded or collapsed
			if ($username ne "Guest") {
				if ($catcol{$catid}) {
					$selected = qq~selected="selected"~;
					$isselected++;
				} else {
					$selected = "";
				}
			} else {
				$selected = qq~selected="selected"~;
				$isselected++;
			}
			$allselected++;
			$checklist .= qq~<option value="$curboard" $selected>$boardname</option>\n          ~;
			if(!$subboard{$curboard}) { next; }
			my $indent;

			&get_subboards(split(/\|/,$subboard{$curboard}));
			sub get_subboards {
				$indent += 2;
				foreach $childbd (@_) {
					my $dash;
					if($indent > 0) { $dash = "-"; }
					($chldboardname, undef, undef) = split(/\|/, $board{"$childbd"});
					$checklist .= qq~<option value="$childbd" $selected>~ . ("&nbsp;" x $indent) . ($dash x ($indent / 2)) . qq~ $chldboardname</option>\n          ~;
					if($subboard{$childbd}) {
						&get_subboards(split(/\|/,$subboard{$childbd}));
					}
				}
				$indent -= 2;
			}
		}
	}
	if ($isselected == $allselected) { $boardscheck = qq~ checked="checked"~; }
	$yymain .= qq~
			<select multiple="multiple" name="searchboards" size="5" onchange="selectnum();">
			$checklist
			</select>
			<input type="checkbox" name="srchAll" id="srchAll"$boardscheck onclick="if (this.checked) searchAll(true); else searchAll(false);" /> <label for="srchAll">$search_txt{'737'}</label>
			<script language="JavaScript1.2" type="text/javascript">
			<!-- //
			function searchAll(_v) {
				for(var i=0;i<document.searchform.searchboards.length;i++)
				document.searchform.searchboards[i].selected=_v;
			}

			function selectnum() {
				document.searchform.srchAll.checked = true;
				for(var i=0;i<document.searchform.searchboards.length;i++) {
					if (! document.searchform.searchboards[i].selected) { document.searchform.srchAll.checked = false; }
				}
			}
			// -->
			</script>
		</td>
	</tr>
	<tr>
		<td class="windowbg"><b>$search_txt{'573'}:</b></td>
		<td class="windowbg2">
			<input type="checkbox" name="subfield" id="subfield" value="on" checked="checked" /><label for="subfield"> $search_txt{'70'}</label> &nbsp;
			<input type="checkbox" name="msgfield" id="msgfield" value="on" checked="checked" /><label for="msgfield"> $search_txt{'72'}</label>
		</td>
	</tr>
	<tr>
		<td class="windowbg"><label for="age"><b>$search_txt{'1'}</b></label></td>
		<td class="windowbg2">
			<select name="age" id="age">
				<option value="7" selected="selected">$search_txt{'2'}</option>
				<option value="31">$search_txt{'3'}</option>
				<option value="92">$search_txt{'4'}</option>
				<option value="365">$search_txt{'5'}</option>
				<option value="0">$search_txt{'6'}</option>
			</select>
		</td>
	</tr>
	<tr>
		<td class="windowbg"><label for="numberreturned"><b>$search_txt{'191'}</b><br /><span class="small">$search_txt{'191b'}</span></label></td>
		<td class="windowbg2"><input type="text" size="5" name="numberreturned" id="numberreturned" maxlength="5" value="$maxsearchdisplay" /></td>
	</tr>
	<tr>
		<td class="windowbg"><label for="oneperthread"><b>$search_txt{'191a'}</b></label></td>
		<td class="windowbg2"><input type="checkbox" name="oneperthread" id="oneperthread" value="1"/></td>
	</tr>
</table>
<table width="700" align="center" border="0" cellpadding="4" cellspacing="0" class="catbg" >
	<tr>
		<td class="round_bottom_left" width="1%">&nbsp;</td>
		<td width="98%" height="50" valign="middle" align="center">
			<input type="submit" name="submit" value="$search_txt{'182'}" class="button" />
		</td>
		<td class="round_bottom_right" width="1%">&nbsp;</td>
	</tr>
</table>
</form>
<script type="text/javascript" language="JavaScript">
<!--
	document.searchform.search.focus();

	function CheckSearchFields() {
		if (document.searchform.numberreturned.value > $maxsearchdisplay) {
			alert("$search_txt{'191x'}");
			document.searchform.numberreturned.focus();
			return false;
		}
		return true;
	}
//-->
</script>
~;

	$yytitle = $search_txt{'183'};
	$yynavigation = qq~&rsaquo; $search_txt{'182'}~;
	&template;
}

#searchtype=allwords&userkind=any&subfield=on&msgfield=on&age=31&numberreturned=25&oneperthread=1&searchboards=%21all&search=test&x=0&y=0&formsession=3A02212143200B021743020D0743301613130C111743200C0E0E160D0A171A2416061017630
#searchtype=allwords&userkind=any&subfield=on&msgfield=on&age=31&numberreturned=15&oneperthread=1&searchboards=%21all&search=test&x=0&y=0&formsession=774F6C6C0E6A4B584B42415E434B405A0E68415C5B434941414A434F401F16182E0
#search=test&searchtype=allwords&userspectext=&userspec=&userkind=noguests&searchboards=bugs&searchboards=opensub&searchboards=fixed&searchboards=request&searchboards=general&searchboards=cc&searchboards=test&searchboards=subtest&searchboards=test1&searchboards=test3&searchboards=test4&searchboards=test2&searchboards=stz2&searchboards=subtest2&searchboards=announcements&searchboards=recycle&srchAll=on&subfield=on&msgfield=on&age=31&numberreturned=15&oneperthread=1&submit=Search&formsession=566E4D4D2F4B6A796A63607F626A617B2F49607D7A626860606B626E613E37390F0

sub plushSearch2 {
	# generate error if admin has disabled search options
	if ($maxsearchdisplay < 0) { &fatal_error("search_disabled"); }
	&spam_protection;

	my $maxage = $FORM{'age'} || (int(($date - &stringtotime($forumstart)) / 86400) + 1);

	my $display = $FORM{'numberreturned'} || $maxsearchdisplay;
	if ($maxage  =~ /\D/) { &fatal_error("only_numbers_allowed"); }
	if ($display =~ /\D/) { &fatal_error("only_numbers_allowed"); }

	# restrict flooding using form abuse
	if ($display > $maxsearchdisplay) { &fatal_error("result_too_high"); }

	my $userkind = $FORM{'userkind'};
	my $userspec = $FORM{'userspec'};

	if ($userkind eq 'starter') { $userkind = 1; }
	elsif ($userkind eq 'poster') { $userkind = 2; }
	elsif ($userkind eq 'noguests') { $userkind = 3; }
	elsif ($userkind eq 'onlyguests') { $userkind = 4; }
	else { $userkind = 0; $userspec = ''; }
	if ($userspec =~ m~/~)  { &fatal_error("no_user_slash"); }
	if ($userspec =~ m~\\~) { &fatal_error("no_user_backslash"); }
	$userspec =~ s/\A\s+//;
	$userspec =~ s/\s+\Z//;
	$userspec =~ s/[^0-9A-Za-z#%+,-\.@^_]//g;
	if ($do_scramble_id) {
		$userspec =~ s/ //g;
		$userspec = &decloak($userspec);
	}
	if ($FORM{'searchme'} eq 'on' && !$iamguest) {
		$userkind = 2;
		$userspec = $username;
	}
	$searchtype = $FORM{'searchtype'};
	my $search  = $FORM{'search'};
	&FromChars($search);
	my $one_per_thread = $FORM{'oneperthread'} || 0;
	if ($searchtype eq 'anywords') { $searchtype = 2; }
	elsif ($searchtype eq 'asphrase') { $searchtype = 3; }
	elsif ($searchtype eq 'aspartial') { $searchtype = 4; }
	else { $searchtype = 1; }
	$search =~ s/\A\s+//;
	$search =~ s/\s+\Z//;
	$search =~ s/\s+/ /g if $searchtype != 3;
	if ($search eq "" || $search eq " ") { &fatal_error("no_search"); }
	if ($search =~ m~/~)  { &fatal_error("no_search_slashes"); }
	if ($search =~ m~\\~) { &fatal_error("no_search_slashes"); }
	my $searchsubject = $FORM{'subfield'} eq 'on';
	my $searchmessage = $FORM{'msgfield'} eq 'on';
	&ToHTML($search);
	$search =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/g;
	$search =~ s/\cM//g;
	$search =~ s/\n/<br \/>/g;
	if ($searchtype != 3) { @search = split(/\s+/, $search); }
	else { @search = ($search); }
	my $case = $FORM{'casesensitiv'};

	my ($curboard, @threads, $curthread, $tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate, @messages, $curpost, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $ns, $subfound, $msgfound, $numfound, %data, $i, $board, $curcat, @categories, %catid, %catname, %cataccess, %openmemgr, @membergroups, %cats, @boardinfo, %boardinfo, @boards, $counter, $msgnum);
	my $maxtime = $date + (3600 * ${$uid.$username}{'timeoffset'}) - ($maxage * 86400);
	my $oldestfound = 99999999999;

	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	foreach $catid (@categoryorder) {
		$boardlist = $cat{$catid};
		(@bdlist) = split(/\,/, $boardlist);
		($catname, $catperms) = split(/\|/, $catinfo{$catid});
		$cataccess = &CatAccess($catperms);
		if (!$cataccess) { next; }

		foreach $cboard (@bdlist) {
			($bname, $bperms, $bview) = split(/\|/, $board{$cboard});
			$catid{$cboard} = $catid;
			$catname{$cboard} = $catname;
		}
	}

	foreach $cbdlist (keys %subboard) {
		foreach $cboard (split(/\|/, $subboard{$cbdlist})) {
			my $catid = ${$uid.$cboard}{'cat'};
			($catname, $catperms) = split(/\|/, $catinfo{$catid});
			$cataccess = &CatAccess($catperms);
			if (!$cataccess) { next; }
			$catid{$cboard} = $catid;
			$catname{$cboard} = $catname;
		}
	}

	if ($enable_ubbc) { require "$sourcedir/YaBBC.pl"; }

	@boards = split(/\,\ /, $FORM{'searchboards'});
	boardcheck: foreach $curboard (@boards) {
		($boardname{$curboard}, $boardperms, $boardview) = split(/\|/, $board{$curboard});

		my $access = &AccessCheck($curboard, '', $boardperms);
		if (!$iamadmin && $access ne "granted") { next; }

		next if !(@threads = &read_DBorFILE(0,'',$boardsdir,$curboard,'txt'));

		threadcheck: foreach $curthread (@threads) {
			chomp $curthread;

			($tnum, $tsub, $tname, $temail, $tdate, $treplies, $tusername, $ticon, $tstate) = split(/\|/, $curthread);

			if ($tdate < $maxtime || $tstate =~ /m/i || (!$iamadmin && !$iamgmod && $tstate =~ /h/i)) { next threadcheck; }
			if ($userkind == 1) {
				if ($tusername eq 'Guest') {
					if ($tname !~ m~\A\Q$userspec\E\Z~i) { next threadcheck; }
				} else {
					if ($tusername !~ m~\A\Q$userspec\E\Z~i) { next threadcheck; }
				}
			}

			next if !(@messages = &read_DBorFILE(0,'',$datadir,$tnum,'txt'));

			postcheck: for ($msgnum = @messages; $msgnum >= 0; $msgnum--) {
				$curpost = $messages[$msgnum];
				chomp $curpost;

				my ($msub, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $savedmessage, $ns) = split(/\|/, $curpost);

				## if either max to display or outside of filter, next
				if ($mdate < $maxtime || ($numfound >= $display && $mdate <= $oldestfound)) { next postcheck; }

				&ToChars($msub);
				($msub, undef) = &Split_Splice_Move($msub,0);

				&ToChars($savedmessage);
				$message = $savedmessage;
				if ($FORM{'searchyabbtags'} && $message =~ /\[\w[^\[]*?\]/) {
					&wrap;
					($message, undef) = &Split_Splice_Move($message,$tnum);
					if ($enable_ubbc) { &DoUBBC; }
					&wrap2;
					$savedmessage = $message;
					$message =~ s/<.+?>//g;
				} elsif (!$FORM{'searchyabbtags'}) {
					$message =~ s/\[\w[^\[]*?\]//g;
				}

				if ($musername eq 'Guest') {
					if ($userkind == 3 || ($userkind == 2 && $mname !~ m~\A\Q$userspec\E\Z~i) ) { next postcheck; }
				} else {
					if ($userkind == 4 || ($userkind == 2 && $musername !~ m~\A\Q$userspec\E\Z~i) ) { next postcheck; }
				}

				if ($case) {
					if ($searchsubject) {
						if ($searchtype == 2 || $searchtype == 4) {
							$subfound = 0;
							foreach (@search) {
								if ($searchtype == 4 && $msub =~ m~\Q$_\E~) { $subfound = 1; last; }
								elsif ($msub =~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~) { $subfound = 1; last; }
							}
						} else {
							$subfound = 1;
							foreach (@search) {
								if ($msub !~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~) { $subfound = 0; last; }
							}
						}
					}
					if ($searchmessage && !$subfound) {
						if ($searchtype == 2 || $searchtype == 4) {
							$msgfound = 0;
							foreach (@search) {
								if ($searchtype == 4 && $message =~ m~\Q$_\E~) { $msgfound = 1; last; }
								elsif ($message =~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~) { $msgfound = 1; last; }
							}
						} else {
							$msgfound = 1;
							foreach (@search) {
								if ($message !~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~) { $msgfound = 0; last; }
							}
						}
					}
				} else {
					if ($searchsubject) {
						if ($searchtype == 2 || $searchtype == 4) {
							$subfound = 0;
							foreach (@search) {
								if ($searchtype == 4 && $msub =~ m~\Q$_\E~i) { $subfound = 1; last; }
								elsif ($msub =~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~i) { $subfound = 1; last; }
							}
						} else {
							$subfound = 1;
							foreach (@search) {
								if ($msub !~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~i) { $subfound = 0; last; }
							}
						}
					}
					if ($searchmessage && !$subfound) {
						if ($searchtype == 2 || $searchtype == 4) {
							$msgfound = 0;
							foreach (@search) {
								if ($searchtype == 4 && $message =~ m~\Q$_\E~i) { $msgfound = 1; last; }
								elsif ($message =~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~i) { $msgfound = 1; last; }
							}
						} else {
							$msgfound = 1;
							foreach (@search) {
								if ($message !~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~i) { $msgfound = 0; last; }
							}
						}
					}
				}

				## blank? try next = else => build list from found mess/sub
				unless ($msgfound || $subfound) { next postcheck; }

				$data{$mdate} = [$curboard, $tnum, $msgnum, $tusername, $tname, $msub, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $savedmessage, $ns, $tstate];
				if ($mdate < $oldestfound) { $oldestfound = $mdate; }
				$numfound++;
				if ($one_per_thread) { last postcheck; }
			}
		}
	}

	@messages = sort { $b <=> $a } keys %data;
	if (@messages) {
		if (@messages > $display) { $#messages = $display - 1; }
		&LoadCensorList;
	} else {
		$yymain .= qq~<hr class="hr" /><b>$search_txt{'170'}<br /><a href="javascript:history.go(-1)">$search_txt{'171'}</a></b><hr class="hr" />~;
	}
	$search = &Censor($search);

	# Search for censored or uncencored search string and remove duplicate words
	my @tmpsearch;
	if ($searchtype == 3) { @tmpsearch = ($search); }
	else { @tmpsearch = split(/\s+/, $search); }
	push @tmpsearch, @search;
	undef %found;
	@search = grep(!$found{$_}++, @tmpsearch);

	my $icanbypass = &checkUserLockBypass;

	for ($i = 0; $i < @messages; $i++) {
		($board, $tnum, $msgnum, $tusername, $tname, $msub, $mname, $memail, $mdate, $musername, $micon, $mreplyno, $mip, $message, $ns, $tstate) = @{ $data{ $messages[$i] } };

		$tname = &addMemberLink($tusername,$tname,$tnum);
		$mname = &addMemberLink($musername,$mname,$mdate);

		$mdate = &timeformat($mdate);

		if (!$FORM{'searchyabbtags'}) {
			&wrap;
			($message, undef) = &Split_Splice_Move($message,$tnum);
			if ($enable_ubbc) { &DoUBBC; }
			&wrap2;
		}

		$message = &Censor($message);
		$msub    = &Censor($msub);

		&Highlight(\$msub,\$message,\@search,$case);

		&ToChars($catname{$board});
		&ToChars($boardname{$board});
		
		# generate a sub board tree
		my $boardtree = '';
		my $parentboard = $board;
		while($parentboard) {
			my ($pboardname, undef, undef) = split(/\|/, $board{"$parentboard"});
			if(${$uid.$parentboard}{'canpost'}) {
				$pboardname = qq~<a href="$scripturl?board=$parentboard"><u>$pboardname</u></a>~;
			} else {
				$pboardname = qq~<a href="$scripturl?boardselect=$parentboard&subboards=1"><u>$pboardname</u></a>~;
			}
			$boardtree = qq~ / $pboardname$boardtree~;
			$parentboard = ${$uid.$parentboard}{'parent'};
		}

		++$counter;

		$yymain .= qq~
<table border="0" width="100%" cellspacing="0" class="tabtitle">
	<tr>
		<td align="center" width="5%" class="round_top_left">$counter</td>
		<td align="left" width="95%" class="round_top_right">&nbsp;<a href="$scripturl?catselect=$catid{$board}"><u>$catname{$board}</u></a> / <a href="$scripturl?board=$board"><u>$boardname{$board}</u></a> / <a href="$scripturl?num=$tnum/$msgnum#$msgnum"><u>$msub</u></a><br />
		&nbsp;<span class="small">$search_txt{'30'}: $mdate</span>&nbsp;</td>
	</tr>
</table>
<table border="0" width="100%" cellspacing="1" cellpadding="0" class="bordercolor" style="table-layout: fixed;">
	<tr>
		<td>
			<table border="0" width="100%" class="titlebg">
				<tr>
					<td align="left">$search_txt{'109'} $tname | $search_txt{'105'} $search_txt{'525'} $mname</td>
					<td align="right">&nbsp;~;

		if ($tstate != 1 && (!$iamguest || ($iamguest && $enable_guestposting))) {
			my $notify = '';
			if (!$iamguest) {
				if (${$uid.$username}{'thread_notifications'} =~ /\b$tnum\b/) {
					$notify = qq~$menusep<a href="$scripturl?action=notify3;oldnotify=1;num=$tnum/$msgnum#$msgnum">$img{'del_notify'}</a>~;
				} else {
					$notify = qq~$menusep<a href="$scripturl?action=notify2;oldnotify=1;num=$tnum/$msgnum#$msgnum">$img{'add_notify'}</a>~;
				}
			}
			$yymain .= qq~<a href="$scripturl?board=$board;action=post;num=$tnum/$msgnum#$msgnum;title=PostReply">$img{'reply'}</a>$menusep<a href="$scripturl?board=$board;action=post;num=$tnum;quote=$msgnum;title=PostReply">$img{'recentquote'}</a>$notify~;
		}

		if ($staff && ($icanbypass || $tstate !~ /l/i) && (!$iammod || &is_moderator($username,$board))) {
				&LoadLanguage('Display');
				$yymain .= qq~$menusep<a href="$scripturl?action=multidel;recent=1;thread=$tnum;del$c=$c" onclick="return confirm('~ . (($icanbypass && $tstate =~ /l/i) ? qq~$display_txt{'modifyinlocked'}\\n\\n~ : '') . qq~$display_txt{'rempost'}')">$img{'delete'}</a>~;
		}

		$yymain .= qq~ &nbsp;
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="left" height="80" class="windowbg2" valign="top" style="padding:5px"><div class="message" style="float: left; width: 99%; overflow: auto;">$message</div></td>
	</tr>
</table><br />~;
	}

	$yymain .= qq~
$search_txt{'167'}<hr class="hr" />
<span class="small"><a href="$scripturl">$search_txt{'236'}</a> $search_txt{'237'}<br /></span>~ if @messages;

	$yynavigation = qq~&rsaquo; $search_txt{'166'}~;
	$yytitle = $search_txt{'166'};
	&template;
}

## does a search of all member's pm files

sub pmsearch {
	# generate error if admin has disabled search options
	if ($enable_PMsearch < 0) { &fatal_error("search_disabled"); }

	my $display = $FORM{'numberreturned'} || $enable_PMsearch;
	if ($display =~ /\D/) { &fatal_error("only_numbers_allowed"); }
	if ($display > $enable_PMsearch) { &fatal_error("result_too_high"); }

	$searchtype = $FORM{'searchtype'} || $INFO{'searchtype'};
	my $search  = $FORM{'search'} || $INFO{'search'};
	my $pmbox = $FORM{'pmbox'} || '!all';

	&FromChars($search);
	if    ($searchtype eq 'anywords')  { $searchtype = 2; }
	elsif ($searchtype eq 'asphrase')  { $searchtype = 3; }
	elsif ($searchtype eq 'aspartial') { $searchtype = 4; }
	elsif ($searchtype eq 'user') {
		$searchtype = 5;
		&ManageMemberinfo("load");
		my $username;
		foreach (keys %memberinf) {
			(undef, $memrealname, undef) = split(/\|/, $memberinf{$_}, 3);
			if ($memrealname eq $search) { $username = $_; last; }
		}
		undef %memberinf;
		$search = $username;
	} else { $searchtype = 1; }

	if ($searchtype != 5) {
		$search =~ s/\A\s+//;
		$search =~ s/\s+\Z//;
		$search =~ s/\s+/ /g if $searchtype != 3;
		if ($search eq "" || $search eq " ") { &fatal_error("no_search"); }
		if ($search =~ m~/~)  { &fatal_error("no_search_slashes"); }
		if ($search =~ m~\\~) { &fatal_error("no_search_slashes"); }
		&ToHTML($search);
		$search =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/g;
		$search =~ s/\cM//g;
		$search =~ s/\n/<br \/>/g;
	}

	my $pmboxesCount = 1;
	if ($pmbox eq "!all") { $pmboxesCount = 3; }
	if ($searchtype == 5) { @search = ($search); }
	elsif ($searchtype != 3) { @search = split(/\s+/, lc $search); }
	else { @search = (lc $search); }

	my ($curboard, @threads, $curthread, $tnum, $tsub, $tname, $temail, $treplies, $tusername, $ticon, $tstate, @messages, $mname, $memail, $mdate, $mattachment, $mip, $userfound, $subfound, $msgfound, $numfound, %data, $i, $board, $curcat, @categories, %catname, %cataccess, %openmemgr, @membergroups, %cats, @boardinfo, %boardinfo, @boards, $counter, $msgnum, @scanthreads);
	my $oldestfound = 9999999999;

	if (($pmbox eq "!all" || $pmbox == 1) && &checkfor_DBorFILE("$memberdir/$username.msg")) {
		@msgthreads = &read_DBorFILE(0,'',$memberdir,$username,'msg');
	}

	if (($pmbox eq "!all" || $pmbox == 2) && &checkfor_DBorFILE("$memberdir/$username.outbox")) {
		@outthreads = &read_DBorFILE(0,'',$memberdir,$username,'outbox');
	}

	if (($pmbox eq "!all" || $pmbox == 3) && &checkfor_DBorFILE("$memberdir/$username.imstore")) {
		@storethreads = &read_DBorFILE(0,'',$memberdir,$username,'imstore');
	}

	if ($enable_ubbc) { require "$sourcedir/YaBBC.pl"; }

	for (my $boxCount = 1; $boxCount <= $pmboxesCount; $boxCount++) {

		if ($boxCount == 1 || $pmbox == 1) {
			@scanthreads = @msgthreads;
			$pmboxName = 1;
		}
		if ($boxCount == 2 || $pmbox == 2) {
			@scanthreads = @outthreads;
			$pmboxName = 2;
		}
		if ($boxCount == 3 || $pmbox == 3) {
			@scanthreads = @storethreads;
			$pmboxName = 3;
		}
		chomp(@scanthreads);

		## reverse through messages
		postcheck: for ($msgnum = $#scanthreads; $msgnum >= 0; $msgnum--) {
			my ($messageid, $mfromuser, $mtouser, $mccuser, $mbccuser, $msub, $mdate, $savedmessage, $mparentmid, $mreply, $mip, $mmessagestatus, $mflags, $mstorefolder, $mattachment)  = split(/\|/, $scanthreads[$msgnum]);

			## if either max to display or outside of filter, next
			if ($numfound >= $display && $mdate <= $oldestfound) { next postcheck; }

			&ToChars($msub);

			&ToChars($savedmessage);
			$message = $savedmessage;
			if ($message =~ /\[\w[^\[]*?\]/) {
				&wrap;
				if ($enable_ubbc) { &DoUBBC; }
				&wrap2;
				$savedmessage = $message;
				$message =~ s/<.+?>//g;
			}

			if ($searchtype == 5) {
				$userfound = 0;
				foreach (@search) {
					if ($mfromuser eq $_ || $mtouser eq $_) { $userfound = 1; }
				}

			} else {
				if ($searchtype == 2 || $searchtype == 4) {
					$subfound = 0;
					foreach (@search) {
						if ($searchtype == 4 && $msub =~ m~\Q$_\E~i) { $subfound = 1; last; }
						elsif ($msub =~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~i) { $subfound = 1; last; }
					}
				} else {
					$subfound = 1;
					foreach (@search) {
						if ($msub !~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~i) { $subfound = 0; last; }
					}
				}
				## nothing found? message
				if (!$subfound) {
					if ($searchtype == 2 || $searchtype == 4) {
						$msgfound = 0;
						foreach (@search) {
							if ($searchtype == 4 && $message =~ m~\Q$_\E~i) { $msgfound = 1; last; }
							elsif ($message =~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~i) { $msgfound = 1; last; }
						}
					} else {
						$msgfound = 1;
						foreach (@search) {
							if ($message !~ m~(^|\W|_)\Q$_\E(?=$|\W|_)~i) { $msgfound = 0; last; }
						}
					}
				}
			}
			## blank? try next = else => build list from found mess/sub
			unless ($msgfound || $subfound || $userfound) { next postcheck; }

			$data{$mdate} = [$pmboxName, $msgnum, $msub, $mname, $memail, $mdate, $mfromuser, $mtouser, $mccuser, $mbccuser, $mattachment, $mip, $savedmessage, $messageid, $mstorefolder];
			if ($mdate < $oldestfound) { $oldestfound = $mdate; }
			$numfound++;
		}
	}

	## sort result
	my @messages = sort { $b <=> $a } keys %data;
	if (@messages) {
		if (@messages > $display) { $#messages = $display - 1; }
		&LoadCensorList;
	} else {
		$yysearchmain .= qq~<hr class="hr" />&nbsp; <b>$search_txt{'170'}</b><hr />~;
	}
	if ($searchtype == 5) { $search = $FORM{'search'} || $INFO{'search'}; @search = ($search); } # not to display username
	$search = &Censor($search);

	# Search for censored or uncencored search string and remove duplicate words
	my @tmpsearch;
	if ($searchtype != 5) {
		if ($searchtype == 3) { @tmpsearch = (lc $search); }
		else { @tmpsearch = split(/\s+/, lc $search); }
	}
	push @tmpsearch, @search;
	undef %found;
	@search = grep(!$found{$_}++, @tmpsearch);

	## output results
	for ($i = 0; $i < @messages; $i++) {
		my ($thispmbox, $msgnum, $msub, $mname, $memail, $mdate, $mfromuser, $mtouser, $mccuser, $mbccuser, $mattachment, $mip, $message, $messageid, $mstorefolder) = @{ $data{ $messages[$i] } };
		my ($MemberFromLink, $MemberToLink, $MemberCCLink, $MemberBCCLink);
		my ($fromTitle, $toTitle, $toTitleCC, $toTitleBCC, $FolderName);

		if ($mfromuser) {
			foreach my $uname (split(/\,/, $mfromuser)) {
				$MemberFromLink .= &addMemberLink($uname,$uname,$mdate) . ', ';
			}
			$MemberFromLink =~ s/, \Z//;
			$fromTitle = qq~$search_txt{'pmfrom'}: $MemberFromLink<br />~;
		}

		if ($mtouser) {
			foreach my $uname (split(/\,/, $mtouser)) {
				$MemberToLink .= &addMemberLink($uname,$uname,$mdate) . ', ';
			}
			$MemberToLink =~ s/, \Z//;
			$toTitle = qq~$search_txt{'pmto'}: $MemberToLink<br />~;
		}

		if ($mccuser && $mfromuser eq $username) {
			foreach my $uname (split(/\,/, $mccuser)) {
				$MemberCCLink .= &addMemberLink($uname,$uname,$mdate) . ', ';
			}
			$MemberCCLink =~ s/, \Z//;
			$toTitleCC = qq~$search_txt{'pmcc'}: $MemberCCLink<br />~;
		}

		if ($mbccuser && $mfromuser eq $username) {
			foreach my $uname (split(/\,/, $mbccuser)) {
				$MemberBCCLink .= &addMemberLink($uname,$uname,$mdate) . ', ';
			}
			$MemberBCCLink =~ s/, \Z//;
			$toTitleBCC = qq~$search_txt{'pmbcc'}: $MemberBCCLink<br />~;
		}

		if ($thispmbox == 1) {
			$FolderName = $pmboxes_txt{'inbox'};
		} elsif ($thispmbox == 2) {
			$FolderName = $pmboxes_txt{'outbox'};
		} elsif ($thispmbox == 3) {
			if ($mstorefolder eq 'in') { $FolderName = $pmboxes_txt{'in'}; }
			elsif ($mstorefolder eq 'out') { $FolderName = $pmboxes_txt{'out'}; }
			else { $FolderName = $mstorefolder; }
			$FolderName = qq~$pmboxes_txt{'store'} &raquo; $FolderName~;
		}

		$mdate = &timeformat($mdate);

		&Highlight(\$msub,\$message,\@search,0);
		&MakeSmileys if $enable_ubbc && $message !~ /#nosmileys/isg;

		$message = &Censor($message);
		$msub = &Censor($msub);

		++$counter;

		$yysearchmain .= qq~
<table border="0" width="100%" cellspacing="1" class="bordercolor" style="table-layout: fixed;">
	<tr>
		<td align="center" width="5%" class="titlebg">&nbsp;$counter&nbsp;</td>
		<td align="left" width="95%" class="titlebg">&nbsp;$FolderName &raquo; <a href="$scripturl?action=imshow;caller=$thispmbox;id=$messageid"><u>$msub</u></a><br />
		&nbsp;<span class="small">$search_txt{'30'}: $mdate</span>&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2">
			<table border="0" width="100%" class="catbg">
				<tr>
					<td align="left">
						$fromTitle
						$toTitle
						$toTitleCC
						$toTitleBCC
					</td>
					<td align="right">&nbsp;<a href="$scripturl?action=imsend;caller=$thispmbox;reply=1;to=;id=$messageid">$img{'reply'}</a>$menusep<a href="$scripturl?action=imsend;caller=$thispmbox;num=;quote=1;to=;id=$messageid">$img{'recentquote'}</a>&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="left" height="80" colspan="2" class="windowbg2" valign="top"><div class="message" style="float: left; width: 99%; overflow: auto;">$message</div></td>
	</tr>
</table><br />
~;
	}

	$yysearchmain .= qq~
		&nbsp;&nbsp;$search_txt{'167'}
		<hr class="hr" />
	~ if @messages;

	$yynavigation = qq~&rsaquo; $search_txt{'166'}~;
	$yytitle = $search_txt{'166'};
}

sub addMemberLink {
	my ($user,$displayname,$mdate) = @_;
	if (&checkfor_DBorFILE("$memberdir/$user.vars")) { &LoadUser($user); }
	if (${$uid.$user}{'regdate'} && $mdate >= (${$uid.$user}{'regtime'} || $date)) {
		$mname = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$user}" rel="nofollow">${$uid.$user}{'realname'}</a>~;
	} elsif ($user !~ m~Guest~ && $mdate < (${$uid.$user}{'regtime'} || $date)) {
		$mname = qq~$displayname - $maintxt{'470a'}~;
	} else {
		$mname = $user . " ($maintxt{'28'})";
	}
	$mname;
}

sub Highlight {
	my ($msub,$message,$search,$case) = @_;
	my $i = 0;
	my @HTMLtags;
	my $HTMLtag = 'HTML';
	while ($$message =~ /\[$HTMLtag\d+\]/) { $HTMLtag .= '1'; }
	while ($$message =~ s/(<.+?>)/[$HTMLtag$i]/s) { push(@HTMLtags, $1); $i++; }

	foreach my $tmp (@$search) {
		if ($case) {
			if ($searchtype == 4) {
				$$msub =~ s~(\Q$tmp\E)~<span class="highlight">$1</span>~g;
				$$message =~ s~(\Q$tmp\E)~<span class="highlight">$1</span>~g;
			} else {
				$$msub =~ s~(^|\W|_)(\Q$tmp\E)(?=$|\W|_)~$1<span class="highlight">$2</span>$3~g;
				$$message =~ s~(^|\W|_)(\Q$tmp\E)(?=$|\W|_)~$1<span class="highlight">$2</span>$3~g;
			}
		} else {
			if ($searchtype == 4) {
				$$msub =~ s~(\Q$tmp\E)~<span class="highlight">$1</span>~ig;
				$$message =~ s~(\Q$tmp\E)~<span class="highlight">$1</span>~ig;
			} else {
				$$msub =~ s~(^|\W|_)(\Q$tmp\E)(?=$|\W|_)~$1<span class="highlight">$2</span>$3~ig;
				$$message =~ s~(^|\W|_)(\Q$tmp\E)(?=$|\W|_)~$1<span class="highlight">$2</span>$3~ig;
			}
		}
	}

	$i = 0;
	while ($$message =~ s/\[$HTMLtag$i\]/$HTMLtags[$i]/s) { $i++; }
}

1;