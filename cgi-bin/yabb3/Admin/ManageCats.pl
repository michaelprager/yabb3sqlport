###############################################################################
# ManageCats.pl                                                               #
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

$managecatsplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub DoCats {
	&is_admin_or_gmod;
	my $i = 0;
	while ($_ = each(%FORM)) {
		if($FORM{$_} && /^yitem_(.+)$/) {
			$editcats[$i] = $1;
			$i++;
		}
	}

	if    ($FORM{'baction'} eq "edit")  { &AddCats(@editcats); }
	elsif ($FORM{'baction'} eq "delme") {
		&get_forum_master;
		foreach $catid (@editcats) {
			##Check if category has any boards, and if it does remove them.
			if ($cat{$catid} ne "") { require "$admindir/ManageBoards.pl"; &DeleteBoards(split(/,/, $cat{$catid})); }

			delete $cat{"$catid"};
			delete $catinfo{"$catid"};

			my $x = 0;
			foreach $categoryid (@categoryorder) {
				if ($catid eq $categoryid) { splice(@categoryorder, $x, 1); last; }
				$x++;
			}

			$yymain .= qq~$admin_txt{'830'} <i>$catid</i> $admin_txt{'831'}<br />~;
		}
		&Write_ForumMaster;
	}
	$yytitle     = "$admin_txt{'3'}";
	$action_area = "managecats";
	&AdminTemplate;
}

sub AddCats {
	&is_admin_or_gmod;

	my @editcats = @_;
	if ($INFO{"action"} eq "catscreen") { $FORM{"amount"} = @editcats; }

	&get_forum_master;

	$yymain .= qq~
<form action="$adminurl?action=addcat2" method="post">
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table border="0" align="center" cellspacing="1" cellpadding="4" width="100%">
  <tr>
    <td class="titlebg" colspan="5" align="left">
      <img src="$imagesdir/cat.gif" alt="" border="0" />
      <b>$admin_txt{'3'}</b>
    </td>
  </tr><tr>
    <td class="windowbg2" colspan="5" align="left"><br />$admin_txt{'43'}<br /><br /></td>
  </tr>
</table>
</div>
<br />
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table border="0" align="center" cellspacing="1" cellpadding="4" width="100%">~;

	require "$admindir/ManageBoards.pl";
	# Start Looping through and repeating the board adding wherever needed
	for ($i = 0; $i < $FORM{'amount'}; $i++) {
		if ((!$editcats[$i] && $INFO{"action"} eq "catscreen") || ($editcats[$i] eq "" && $INFO{"action"} eq "catscreen")) { next; }
		if ($INFO{"action"} eq "catscreen") {
			$id = $editcats[$i];
			foreach $catid (@categoryorder) {
				unless ($id eq $catid) { next; }
				@bdlist = split(/,/, $cat{$catid});
				($curcatname, $catperms, $catallowcol, $catimage) = split(/\|/, $catinfo{"$catid"});
				&ToChars($curcatname);
				$cattext = $curcatname;
				if ($catallowcol eq '' || $catallowcol eq '1') { $allowChecked = 'checked="checked"'; }
				else { $allowChecked = ''; }
			}
		} else {
			$cattext = "$admin_txt{'44'} $i:";
		}
		$catperms = &DrawPerms($catperms, 0);
		$yymain .= qq~
  <tr>
    <td class="catbg" colspan="4" align="left"> <b>$cattext</b></td>
  </tr><tr>
    <td class="windowbg" colspan="2">&nbsp;</td>
    <td class="windowbg" align="center"><label for="catperms$i"><b>$admin_txt{'45'}</b></label></td>
    <td class="windowbg" align="center"><label for="allowcol$i"><b>$exptxt{'6'}</b></label></td>
  </tr><tr>~;
		if ($INFO{"action"} eq 'catscreen') {
			$yymain .= qq~			
			<td class="windowbg" align="left" valign="middle"><label for="theid$i"><b>$admin_txt{'61a'}</b></label></td>
			<td class="windowbg2" valign="middle"><br /><input type="hidden" name="theid$i" id="theid$i" value="$id" />$id<br /><br />~;
		} else {
			$yymain .= qq~
			<td class="windowbg" align="left" valign="middle"><label for="theid$i"><b>$admin_txt{'61a'}</b><br />$admin_txt{'61b'}</label></td>
			<td class="windowbg2" valign="middle"><br /><input type="text" name="theid$i" id="theid$i" value="$id" /><br /><br />~;
		}
		$yymain .= qq~
    </td>
    <td class="windowbg2" align="center" rowspan="3"><select multiple="multiple" name="catperms$i" id="catperms$i" size="5">$catperms</select><br /><label for="catperms$i"><span class="small">$admin_txt{'14'}</span></label></td>
    <td class="windowbg2" align="center" rowspan="3"><input type="checkbox" $allowChecked name="allowcol$i" id="allowcol$i" /></td>
  </tr><tr>
    <td class="windowbg" align="left" valign="middle"><label for="name$i"><b>$admin_txt{'68'}:</b></label></td>
    <td class="windowbg2"><br /><input type="text" name="name$i" id="name$i" value="$curcatname" size="40" /><br /><br /></td>
  </tr><tr>
    <td class="windowbg" align="left" valign="middle"><label for="catimage$i"><b>$admin_txt{'64b2'}:</b></label></td>
    <td class="windowbg2"><br /><input type="text" name="catimage$i" id="catimage$i" value="$catimage" size="40" />~ . ($catimage ? qq~<br /><br  /><img src="$catimage" alt="" border="0" />~ : '') . qq~<br /><br /></td>
  </tr>~;
	}
	$yymain .= qq~<tr>
      <td class="catbg" colspan="4" align="center">
      <input type="hidden" name="amount" value="$FORM{"amount"}" />
      <input type="hidden" name="screenornot" value="$INFO{'action'}" />
      <input type="submit" value="$admin_txt{'10'}" class="button" /></td>
  </tr>
</table>
</div>
</form>~;

	$yytitle     = "$admin_txt{'3'}";
	$action_area = "managecats";
	&AdminTemplate;
}

sub AddCats2 {
	&is_admin_or_gmod;
	&get_forum_master;

	for ($i = 0; $i < $FORM{'amount'}; $i++) {
		if ($FORM{"catimage$i"} ne "") {
			&fatal_error("invalid_character",$FORM{"catimage$i"}) if $FORM{"catimage$i"} =~ /[^0-9a-zA-Z_\.#\%\-:\+\?\$&~,\@\/]/;
			&fatal_error("",$admintxt{'44'}) if $FORM{"catimage$i"} !~ /\.(gif|png|jpe?g)$/;
		}
		if ($FORM{"theid$i"} eq "") { next; }
		$id = $FORM{"theid$i"};
		&fatal_error("invalid_character","$admin_txt{'44'} $admin_txt{'241'}") if ($id !~ /^[0-9A-Za-z#%+-\.@^_]+$/);
		if ($FORM{'screenornot'} ne "catscreen") {
			if ($catinfo{"$id"}) { &fatal_error("cat_defined"); }
			else { $cat{"$id"} = ""; }
			push(@categoryorder, $id);
		}
		if (!$FORM{"name$i"}) { $FORM{"name$i"} = $id; }

		$cname = $FORM{"name$i"};
		&FromChars($cname);
		&ToHTML($cname);

		if ($FORM{"allowcol$i"} eq 'on') { $FORM{"allowcol$i"} = 1; }
		else { $FORM{"allowcol$i"} = 0; }
		$catinfo{"$id"} = qq~$cname|$FORM{"catperms$i"}|$FORM{"allowcol$i"}|$FORM{"catimage$i"}~;

		$yymain .= qq~$admin_txt{'830'} <i>$id</i> $admin_txt{'48'}<br />~;
	}
	&Write_ForumMaster;

	$action_area = "managecats";
	&AdminTemplate;
}

sub ReorderCats {
	&is_admin_or_gmod;
	&get_forum_master;
	if (@categoryorder > 1) {
		$catcnt = @categoryorder;
		$catnum = $catcnt;
		if ($catcnt < 4) { $catcnt = 4; }
		$categorylist = qq~<select name="selectcats" id="selectcats" size="$catcnt" style="width: 190px;">~;
		foreach $category (@categoryorder) {
			chomp $category;
			($categoryname, undef) = split(/\|/, $catinfo{$category}, 2);
			&ToChars($categoryname);
			if ($category eq $INFO{"thecat"}) {
				$categorylist .= qq~<option value="$category" selected="selected">$categoryname</option>~;
			} else {
				$categorylist .= qq~<option value="$category">$categoryname</option>~;
			}
		}
		$categorylist .= qq~</select>~;
	}
	$yymain .= qq~
<br /><br />
<form action="$adminurl?action=reordercats2" method="post">
<table border="0" width="525" cellspacing="1" cellpadding="4" class="bordercolor" align="center">
  <tr>
    <td class="titlebg"><img src="$imagesdir/board.gif" style="vertical-align: middle;" /> <b>$admin_txt{'829'}</b></td>
  </tr>
  <tr>
    <td class="windowbg" valign="middle" align="left">~;

	if ($catnum > 1) {
		$yymain .= qq~
      <div style="float: left; width: 280px; text-align: left; margin-bottom: 4px;" class="small"><label for="selectcats">$admin_txt{'738'}</label></div>
      <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">$categorylist</div>
      <div style="float: left; width: 280px; text-align: left; margin-bottom: 4px;" class="small">$admin_txt{'738a'}</div>
      <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">
        <input type="submit" value="$admin_txt{'739a'}" name="moveup" style="font-size: 11px; width: 95px;" class="button" />
        <input type="submit" value="$admin_txt{'739b'}" name="movedown" style="font-size: 11px; width: 95px;" class="button" />
      </div>~;
	} else {
		$yymain .= qq~
      <div class="small" style="text-align: center; margin-bottom: 4px;">$admin_txt{'738b'}</div>~;
	}
	$yymain .= qq~
    </td>
  </tr>
</table>
</form>
~;
	$yytitle     = "$admin_txt{'829'}";
	$action_area = "managecats";
	&AdminTemplate;
}

sub ReorderCats2 {
	&is_admin_or_gmod;
	my $moveitem = $FORM{'selectcats'};
	&get_forum_master;
	if ($moveitem) {
		if ($FORM{'moveup'}) {
			for ($i = 0; $i < @categoryorder; $i++) {
				if ($categoryorder[$i] eq $moveitem && $i > 0) {
					$j                 = $i - 1;
					$categoryorder[$i] = $categoryorder[$j];
					$categoryorder[$j] = $moveitem;
					last;
				}
			}
		} elsif ($FORM{'movedown'}) {
			for ($i = 0; $i < @categoryorder; $i++) {
				if ($categoryorder[$i] eq $moveitem && $i < $#categoryorder) {
					$j                 = $i + 1;
					$categoryorder[$i] = $categoryorder[$j];
					$categoryorder[$j] = $moveitem;
					last;
				}
			}
		}
		&Write_ForumMaster;
	}
	$yySetLocation = qq~$adminurl?action=reordercats;thecat=$moveitem~;
	&redirectexit;
}

1;