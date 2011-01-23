###############################################################################
# Smilies.pl                                                                  #
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

$smiliesplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub SmiliePanel {
	&is_admin_or_gmod;
	if    ($smiliestyle eq 1) { $ss1    = " selected='selected'"; }
	elsif ($smiliestyle eq 2) { $ss2    = " selected='selected'"; }
	if    ($showadded   eq 1) { $sa1    = " selected='selected'"; }
	elsif ($showadded   eq 2) { $sa2    = " selected='selected'"; }
	elsif ($showadded   eq 3) { $sa3    = " selected='selected'"; }
	elsif ($showadded   eq 4) { $sa4    = " selected='selected'"; }
	if    ($showsmdir   eq 1) { $ssm1   = " selected='selected'"; }
	elsif ($showsmdir   eq 2) { $ssm2   = " selected='selected'"; }
	elsif ($showsmdir   eq 3) { $ssm3   = " selected='selected'"; }
	elsif ($showsmdir   eq 4) { $ssm4   = " selected='selected'"; }
	if    ($detachblock eq 1) { $dblock = " checked='checked'"; }
	if    ($removenormalsmilies) { $remnosmi = " checked='checked'"; }
	opendir(DIR, "$smiliesdir");
	@contents = readdir(DIR);
	closedir(DIR);
	$smilieslist = "";

	foreach $line (sort { uc($a) cmp uc($b) } @contents) {
		($name, $extension) = split(/\./, $line);
		if ($extension =~ /gif/i || $extension =~ /jpg/i || $extension =~ /jpeg/i || $extension =~ /png/i) {
			if ($line !~ /banner/i) {
				$smilieslist .= qq~<tr>
    <td class="windowbg2" width="5%" align="center"><input type="radio" name="showinbox" value="$name"~ . ($showinbox eq $name ? ' checked="checked"' : '') . qq~ /></td>
    <td class="windowbg2" width="21%" align="center">[smiley=$line]</td>
    <td class="windowbg2" width="21%" align="center">$line</td>
    <td class="windowbg2" width="21%" align="center">$name</td>
    <td class="windowbg2" colspan="4" width="32%" align="center"><img src="$smiliesurl/$line" alt="$name" title="$name" /></td>
  </tr>~;
			}
		}
	}
	$yymain .= qq~
<form action="$adminurl?action=addsmilies" method="post">
<table border="0" width="98%" cellspacing="1" cellpadding="4" class="bordercolor" align="center">
  <tr>
    <td class="titlebg" colspan="8"><b>&nbsp;<img src="$imagesdir/grin.gif" alt="" />&nbsp;$asmtxt{'11'}</b></td>
  </tr><tr>
    <td class="catbg" width="5%" align="center"><b>$smiltxt{'22'}</b></td>
    <td class="catbg" width="20%" align="center"><b>$asmtxt{'02'}</b></td>
    <td class="catbg" width="20%" align="center"><b>$asmtxt{'03'}</b></td>
    <td class="catbg" width="20%" align="center"><b>$asmtxt{'04'}</b></td>
    <td class="catbg" width="15%" align="center"><b>$asmtxt{'05'}</b></td>
    <td class="catbg" width="10%" align="center"><b>$asmtxt{'06'}</b></td>
    <td class="catbg" width="5%" align="center"><b>$asmtxt{'07'}</b></td>
    <td class="catbg" width="5%" align="center"><b>$asmtxt{'12'}</b></td>
  </tr>~;

	$i = 0;
	foreach (@SmilieURL) {
		if ($i != 0) {
			$up = qq~<a href="$adminurl?action=smiliemove;index=$i;moveup=1"><img src="$imagesdir/smiley_up.gif" border="0" alt="$asmtxt{'13'}" title="$asmtxt{'13'}" /></a>~;
		} else {
			$up = qq~<img src="$imagesdir/smiley_up.gif" border="0" alt="" />~;
		}
		if ($SmilieURL[$i + 1]) {
			$down = qq~<a href="$adminurl?action=smiliemove;index=$i;movedown=1"><img src="$imagesdir/smiley_down.gif" border="0" alt="$asmtxt{'14'}" title="$asmtxt{'14'}" /></a>~;
		} else {
			$down = qq~<img src="$imagesdir/smiley_down.gif" border="0" alt="" />~;
		}
		$yymain .= qq~<tr>
    <td class="windowbg2" width="5%" align="center"><input type="radio" name="showinbox" value="$SmilieDescription[$i]"~ . ($showinbox eq $SmilieDescription[$i] ? ' checked="checked"' : '') . qq~ /></td>
    <td class="windowbg2" width="20%" align="center"><input type="text" name="scd[$i]" value="$SmilieCode[$i]" /></td>
    <td class="windowbg2" width="20%" align="center"><input type="text" name="smimg[$i]" value="$SmilieURL[$i]" /></td>
    <td class="windowbg2" width="20%" align="center"><input type="text" name="sdescr[$i]" value="$SmilieDescription[$i]" /></td>
    <td class="windowbg2" width="15%" align="center"><input type="checkbox" name="smbox[$i]" value="1"~ . ($SmilieLinebreak[$i] eq "<br />" ? " checked='checked'" : "") . qq~ /></td>
    <td class="windowbg2" width="10%" align="center"><img src="~ . ($SmilieURL[$i] =~ /\//i ? $SmilieURL[$i] : qq~$imagesdir/$SmilieURL[$i]~) . qq~" alt="" /></td>
    <td class="windowbg2" width="5%" align="center"><input type="checkbox" name="delbox[$i]" value="1" /></td>
    <td class="windowbg2" width="5%" align="center">$up $down</td>
  </tr>~;
		$i++;
	}
	$yymain .= qq~<tr>
    <td class="titlebg" colspan="8"><b>&nbsp;<img src="$imagesdir/grin.gif" alt="" />&nbsp;$asmtxt{'08'}</b></td>
  </tr>~;
	$inew = 0;
	while ($inew <= "5") {
		$yymain .= qq~<tr>
    <td class="windowbg2" width="5%" align="center">&nbsp;</td>
    <td class="windowbg2" width="20%" align="center"><input type="text" name="scd[$i]" /></td>
    <td class="windowbg2" width="20%" align="center"><input type="text" name="smimg[$i]" /></td>
    <td class="windowbg2" width="20%" align="center"><input type="text" name="sdescr[$i]" /></td>
    <td class="windowbg2" width="15%" align="center"><input type="checkbox" name="smbox[$i]" value="1" /></td>
    <td class="windowbg2" width="20%" align="center" colspan="3"></td>
  </tr>~;
		$i++;
		$inew++;
		if ($inew == 5) {
			$yymain .= qq~<tr>
    <td colspan="8" class="titlebg"><b>&nbsp;<img src="$imagesdir/grin.gif" alt="" />&nbsp;$smiltxt{'2'}</b></td>
  </tr><tr>
    <td class="catbg" width="5%" align="center"><b>$smiltxt{'22'}</b></td>
    <td class="catbg" width="21%" align="center"><b>$asmtxt{'02'}</b></td>
    <td class="catbg" width="21%" align="center"><b>$asmtxt{'03'}</b></td>
    <td class="catbg" width="21%" align="center"><b>$asmtxt{'04'}</b></td>
    <td class="catbg" colspan="4" width="32%" align="center"><b>$asmtxt{'06'}</b></td>
  </tr>$smilieslist<tr>
    <td class="titlebg" colspan="8" height="22"><b>&nbsp;<img src="$imagesdir/grin.gif" alt="" />&nbsp;$smiltxt{'3'}</b><br /></td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="removenormalsmilies"><b>$smiltxt{'24'}</b></label></td>
    <td class="windowbg2" colspan="4" align="right"><input type="checkbox" name="removenormalsmilies" id="removenormalsmilies" value="1"$remnosmi /></td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="smiliestyle"><b>$smiltxt{'4'}</b></label></td>
    <td class="windowbg2" colspan="4" align="right">
      <select name="smiliestyle" id="smiliestyle">
        <option value="1"$ss1>$smiltxt{'5'}</option>
        <option value="2"$ss2>$smiltxt{'6'}</option>
      </select>
    </td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="showadded"><b>$smiltxt{'7'}</b></label></td>
    <td class="windowbg2" colspan="4" align="right">
      <select name="showadded" id="showadded">
        <option value="1"$sa1>$smiltxt{'8'}</option>
        <option value="2"$sa2>$smiltxt{'9'}</option>
        <option value="3"$sa3>$smiltxt{'10'}</option>
        <option value="4"$sa4>$smiltxt{'11'}</option>
      </select>
    </td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="showsmdir"><b>$smiltxt{'2'}</b></label></td>
    <td class="windowbg2" colspan="4" align="right">
      <select name="showsmdir" id="showsmdir">
        <option value="1"$ssm1>$smiltxt{'8'}</option>
        <option value="2"$ssm2>$smiltxt{'9'}</option>
        <option value="3"$ssm3>$smiltxt{'10'}</option>
        <option value="4"$ssm4>$smiltxt{'11'}</option>
      </select>
    </td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="detachblock"><b>$smiltxt{'12'}</b><br /> $smiltxt{'13'}</label></td>
    <td class="windowbg2" colspan="4" align="right"><input type="checkbox" name="detachblock" id="detachblock" value="1"$dblock /></td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="winwidth"><b>$smiltxt{'14'}</b></label></td>
    <td class="windowbg2" colspan="4" align="right"><input type="text" size="10" name="winwidth" id="winwidth" value="$winwidth" /></td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="winheight"><b>$smiltxt{'15'}</b></label></td>
    <td class="windowbg2" colspan="4" align="right"><input type="text" size="10" name="winheight" id="winheight" value='$winheight' /></td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="showinbox"><b>$smiltxt{'23'}</b></label></td>
    <td class="windowbg2" colspan="4" align="right"><input type="radio" name="showinbox" id="showinbox" value=""~ . (!$showinbox ? ' checked="checked"' : '') . qq~ /></td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><b>$smiltxt{'18'}</b></td>
    <td class="windowbg2" colspan="4" align="left">$smiliesurl</td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="popback"><b>$smiltxt{'20'}</b></label></td>
    <td class="windowbg2" colspan="4" align="right">#<input type="text" size="10" name="popback" id="popback" value="$popback" /></td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="poptext"><b>$smiltxt{'19'}</b></label></td>
    <td class="windowbg2" colspan="4" align="right">#<input type="text" size="10" name="poptext" id="poptext" value="$poptext" /></td>
  </tr><tr>
    <td class="catbg" align="center" colspan="8">
    <input type="submit" value="$asmtxt{'09'}" class="button" />&nbsp;<input type="reset" value="$asmtxt{'10'}" class="button" /></td>
  </tr>
</table>
</form>
~;

			$yytitle     = "$asmtxt{'01'}";
			$action_area = "smilies";
			&AdminTemplate;
		}
	}

}

sub AddSmilies {
	&is_admin_or_gmod;

	$smiliestyle = $FORM{'smiliestyle'};
	$showadded = $FORM{'showadded'};
	$showsmdir = $FORM{'showsmdir'};
	$detachblock = $FORM{'detachblock'};
	$winwidth = $FORM{'winwidth'};
	$winheight = $FORM{'winheight'};
	$popback = $FORM{'popback'};
	$popback =~ s/[^a-f0-9]//ig;
	$poptext = $FORM{'poptext'};
	$poptext =~ s/[^a-f0-9]//ig;
	$showinbox = $FORM{'showinbox'};
	$removenormalsmilies = $FORM{'removenormalsmilies'};

	@SmilieURL = ();
	@SmilieCode = ();
	@SmilieDescription = ();
	@SmilieLinebreak = ();
	my $tempA = 0;
	while (exists $FORM{"scd[$tempA]"}) {
		unless ($FORM{"delbox[$tempA]"} || !$FORM{"smimg[$tempA]"}) {
			push(@SmilieURL, $FORM{"smimg[$tempA]"});

			&ToHTML($FORM{"scd[$tempA]"});
			$FORM{"scd[$tempA]"} =~ s/\$/&#36;/g;
			$FORM{"scd[$tempA]"} =~ s/\@/&#64;/g;
			push(@SmilieCode, $FORM{"scd[$tempA]"});

			&ToHTML($FORM{"sdescr[$tempA]"});
			$FORM{"sdescr[$tempA]"} =~ s/\$/&#36;/g;
			$FORM{"sdescr[$tempA]"} =~ s/\@/&#64;/g;
			push(@SmilieDescription, $FORM{"sdescr[$tempA]"});

			push(@SmilieLinebreak, ($FORM{"smbox[$tempA]"} ? "<br />" : ""));
		}
		++$tempA;
	}

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');

	$yySetLocation = qq~$adminurl?action=smilies~;
	&redirectexit;
}

sub SmilieMove {
	&is_admin_or_gmod;

	if (exists $INFO{'index'}) {
		for (my $i = 0; $i < @SmilieURL; $i++) {
			if ($i == $INFO{'index'} &&
			    (($INFO{'movedown'} && $i >= 0           && $i < $#SmilieURL) ||
			     ($INFO{'moveup'}   && $i <= $#SmilieURL && $i > 0))) {
				my $j = $INFO{'moveup'} ? $i - 1 : $i + 1;

				my $moveit = $SmilieURL[$i];
				$SmilieURL[$i] = $SmilieURL[$j];
				$SmilieURL[$j] = $moveit;

				$moveit = $SmilieCode[$i];
				$SmilieCode[$i] = $SmilieCode[$j];
				$SmilieCode[$j] = $moveit;

				$moveit = $SmilieDescription[$i];
				$SmilieDescription[$i] = $SmilieDescription[$j];
				$SmilieDescription[$j] = $moveit;

				$moveit = $SmilieLinebreak[$i];
				$SmilieLinebreak[$i] = $SmilieLinebreak[$j];
				$SmilieLinebreak[$j] = $moveit;
				last;
			}
		}
	}

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');

	$yySetLocation = qq~$adminurl?action=smilies~;
	&redirectexit;
}

1;