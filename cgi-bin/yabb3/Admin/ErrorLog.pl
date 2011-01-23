###############################################################################
# ErrorLog.pl                                                                 #
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

$errorlogplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub ErrorLog {
	&is_admin_or_gmod;
	$yytitle    = "$errorlog{'1'}";
	$errorcount = 0;
	my @errors = &read_DBorFILE(0,'',$vardir,'errorlog','txt');
	$errorcount = @errors;
	$date2      = $date;
	for ($i = 0; $i < $errorcount; $i++) {
		my @tmpArray = split(/\|/, $errors[$i]);
		$date1 = $tmpArray[1];
		&calcdifference;
		$date_ref = $result;
		$tmplist[$i] = qq~$date_ref\|$errors[$i]~;
	}
	$sortmode  = $INFO{'sort'};
	$sortorder = $INFO{'order'};
	if ($sortmode eq "") {
		$sortmode = "time";
	}
	if ($sortorder eq "") {
		$sortorder = "reverse";
	}
	my @sortlist = ();
	my $field    = '0';    # 0-based field defaults to the datecmp value
	my $type     = '0';    # 0=numeric; 1=text
	my $case     = '1';    # 0=case sensitive; 1=ignore case
	my $dir      = '0';    # 0=increasing; 1=decreasing

	if ($sortmode eq "time") {
		$field = '1';
		$type  = '0';
		$case  = '1';
		$dir   = '0';
	} elsif ($sortmode eq "users") {
		$field = '8';
		$type  = '1';
		$case  = '1';
		$dir   = '0';
	} elsif ($sortmode eq "ip") {
		$field = '3';
		$type  = '0';
		$case  = '0';
		$dir   = '0';
	}
	@sortlist = map { $_->[0] } sort { YaBBsort($field, $type, $case, $dir) } map { [$_, split /\|/] } @tmplist;

	if ($INFO{'order'} eq "reverse") {
		@sortlist = reverse @sortlist;
	} else {
		if ($sortmode eq "time") {
			$order_time = ";order=reverse";
		} elsif ($sortmode eq "users") {
			$order_users = ";order=reverse";
		} elsif ($sortmode eq "ip") {
			$order_ip = ";order=reverse";
		}
	}

	if ($sortmode ne "") {
		$sortmode = ";sort=" . $INFO{'sort'};
	}
	if ($sortorder ne "") {
		$sortorder = ";order=" . $INFO{'order'};
	}
	$yymain .= qq~\
<script language="JavaScript1.2" src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
<script language="JavaScript1.2" type="text/javascript">
<!-- Begin
function changeBox(cbox) {
  box = eval(cbox);
  box.checked = !box.checked;
}
function checkAll() {
  for (var i = 0; i < document.errorlog_form.elements.length; i++) {
  	if(document.errorlog_form.elements[i].name != "subfield" && document.errorlog_form.elements[i].name != "msgfield") {
    		document.errorlog_form.elements[i].checked = true;
    	}
  }
}
function uncheckAll() {
  for (var i = 0; i < document.errorlog_form.elements.length; i++) {
  	if(document.errorlog_form.elements[i].name != "subfield" && document.errorlog_form.elements[i].name != "msgfield") {
    		document.errorlog_form.elements[i].checked = false;
    	}
  }
}
//-->
</script>
<form name="errorlog_form" action="$adminurl?action=deleteerror;$sortmode$sortorder" method="post" onsubmit="return submitproc()">
<input type="hidden" name="button" value="4" />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="5">
<img src="$imagesdir/xx.gif" alt="" border="0" /><b>$yytitle</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2" colspan="5"><br />
		 $errorlog{'18'}<br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" valign="middle" class="catbg">
		 <b>$errorlog{'21'}</b>
	   </td>
       <td align="center" valign="middle" class="catbg">
		 <a href="$adminurl?action=errorlog$startmode;sort=time$order_time"><b>$errorlog{'5'}</b></a>
	   </td>
       <td align="center" valign="middle" class="catbg">
		 <a href="$adminurl?action=errorlog$startmode;sort=users$order_users"><b>$errorlog{'11'}</b></a> ( <a href="$adminurl?action=errorlog$startmode;sort=ip$order_ip"><b>$errorlog{'6'}</b></a> )
	   </td>
       <td align="center" valign="middle" class="catbg">
		 <b>$errorlog{'7'} / $errorlog{'8'}</b>
	   </td>
       <td align="center" valign="middle" class="catbg">
		 <b>$errorlog{'13'}</b>
	   </td>
     </tr>
~;
	$numshown  = 0;
	$actualnum = 0;
	while ($numshown <= $errorcount) {
		my ($tmp_user, $username, $numb, $ids, $all) = '';
		$numshown++;
		my ($tmp_datecmp, $tmp_id, $tmp_date, $tmp_userip, $tmp_error, $tmp_action, $tmp_topic_number, $tmp_board, $tmp_username, $tmp_password) = split(/\|/, $sortlist[$b]);
		if (!$tmp_id) { next; }
		&FormatUserName($tmp_username);
		if (!$tmp_username) {
			$tmp_user = "Guest";
		} else {
			$tmp_user = $tmp_username;
		}
		$userlist{$tmp_user} = $userlist{$tmp_user} + 1;
		$tmp_date = &timeformat($tmp_date);
		&LoadUser($tmp_user);
		if ($tmp_user eq "$useraccount{$tmp_user}") {
			if ($userprofile{$tmp_user}->[1]) {
				$username = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$tmp_user}" target ="_blank">$userprofile{$tmp_user}->[1]</a>~;
			} else {
				$username .= qq~$useraccount{$tmp_user}~;
			}
			$username .= qq~<br />($tmp_userip)~;
		} else {
			$username = qq~$tmp_user<br />($tmp_userip)~;
		}
		if ($tmp_topic_number eq '') {
			$numb = "&action=$tmp_action";
		} else {
			$numb = "&action=$tmp_action&num=$tmp_topic_number";
		}
		if ($tmp_board eq '') {
			$ids = "?board=";
		} else {
			$ids = "?board=$tmp_board";
		}
		if ($tmp_action eq '' && $tmp_board eq '') {
			$all = "$boardurl/$yyexec.$yyext";
		} else {
			$all = "$boardurl/$yyexec.$yyext$ids$numb";
		}
		if ($tmp_error eq $admin_txt{'39'} || $tmp_error eq $admin_txt{'40'}) {
			$tmp_error = $tmp_error . " - (<span style=\"color: #FF0000;\">$tmp_password</span>)";
		}

		$b++;
		$addel = qq~<td class="windowbg" align="center"><input type="checkbox" name="error$tmp_id" value="$tmp_id" class="windowbg" style="border: 0px;" /></td>~;
		$actualnum++;
		$print_errorlog .= qq~
	<tr>
		<td class="windowbg" align="center">$actualnum</td>
	        <td class="windowbg">$tmp_date</td>
          	<td class="windowbg2" align="center">$username</td>
          	<td class="windowbg" align="center">
              <span class="small">$tmp_error<br /><br /><a href="$all">$all</a></span>
            </td>
          	$addel
        </tr>~;
	}
	if (!($actualnum)) {
		$print_errorlog = qq~
	<tr>
		<td class="windowbg2" align="center" colspan="5">
			$errorlog{'19'}
		</td>
	</tr>~;
	}
	$yymain .= qq~
$print_errorlog
	~;

	@userlist = sort { $userlist{$b} <=> $userlist{$a} } keys %userlist;
	foreach $member (@userlist) {
		$errmember .= qq~$member ($userlist{$member}), ~;
	}
	$errmember =~ s/, \Z//;

	$yymain .= qq~
     <tr valign="middle">
       <td align="left" class="windowbg2" colspan="5"><br />
       <strong>$errorlog{'26'}</strong> $errmember<br /><br />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="right" class="windowbg" colspan="4">&nbsp;~;
	if ($errorcount > 0) { $yymain .= qq~<label for="checkall"><b>$admin_txt{'737'}</label>&nbsp;</b>~; }
	$yymain .= qq~
	   </td>
	   <td class="windowbg" align="center">&nbsp;~;
	if ($errorcount > 0) { $yymain .= qq~<input type="checkbox" name="checkall" id="checkall" class="windowbg" style="border: 0px;" onclick="if (this.checked) checkAll(); else uncheckAll();" />~; }
	$yymain .= qq~
	   </td>
     </tr>
   </table>
 </div>

<br />
	~;

if ($errorcount > 0) {
	$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="center" class="catbg">
		 <input type="submit" value="$errorlog{'14'}" onclick="return confirm('$errorlog{'15'}')" class="button" />
	   </td>
     </tr>
   </table>
 </div>
	~;
}

	$yymain .= qq~
</form>
~;
	$action_area = "errorlog";
	&AdminTemplate;
}

sub CleanErrorLog {
	&is_admin_or_gmod;
	if (&checkfor_DBorFILE("$vardir/errorlog.txt")) { &delete_DBorFILE("$vardir/errorlog.txt") || die "$!" }
	$yySetLocation = qq~$adminurl?action=errorlog~;
	&redirectexit;
}

sub DeleteError {
	&is_admin_or_gmod;
	my ($count, $currentmem, @deademails, $start, $sortmode, $sortorder);
	chomp $FORM{"button"};
	if ($FORM{"button"} ne "4") { &fatal_error("no_access"); }
	my @errors = &read_DBorFILE(0,'',$vardir,'errorlog','txt');

	&delete_DBorFILE("$vardir/errorlog.txt");

	&read_DBorFILE(0,FILE,$vardir,'errorlog','txt');
	foreach my $line (@errors) {
		chomp $line;
		my ($tmp_id, $tmp_date, $tmp_username, $tmp_error, $tmp_board, $tmp_action) = split(/\|/, $line);
		unless (exists $FORM{"error$tmp_id"}) {
			print FILE $line . "\n";
		}
	}
	&write_DBorFILE(0,FILE,$vardir,'errorlog','txt',(''));

	$yySetLocation = qq~$adminurl?action=errorlog~;
	&redirectexit;
}

# Moved here from Subs.pl since it was only used here
sub YaBBsort {
	my $field = (shift || 0) + 1;    # 0-based field
	my $type = shift || 0;           # 0=numeric; 1=text
	my $case = shift || 0;           # 0=case sensitive; 1=ignore case
	my $dir  = shift || 0;           # 0=increasing; 1=decreasing

	if ($type == 0) {
		if ($dir == 0) {
			$a->[$field] <=> $b->[$field];
		} else {
			$b->[$field] <=> $a->[$field];
		}
	} else {
		if ($case == 0) {
			if ($dir == 0) {
				$a->[$field] cmp $b->[$field];
			} else {
				$b->[$field] cmp $a->[$field];
			}
		} else {
			if ($dir == 0) {
				uc $a->[$field] cmp uc $b->[$field];
			} else {
				uc $b->[$field] cmp uc $a->[$field];
			}
		}
	}
}

1;
