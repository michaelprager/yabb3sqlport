###############################################################################
# AdvancedTabs.pl                                                             #
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

$advancedtabsplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub AddNewTab {
	&GetTexttab;

	$edittabs = qq~<option value="thefront">$tabmenu_txt{'tabfront'}</option>~;
	foreach (@AdvancedTabs) {
		$_ =~ /^([^\|]+)/;
		if ($texttab{$1}) { $edittabs .= qq~<option value="$1">$texttab{$1}</option>~; }
	}

	$yyaddtab = qq~
	<br />

	<script language="JavaScript1.2" type="text/javascript">
	<!--
	function submittab() {
		if (window.submitted) return false;
		window.submitted = true;
		return true;
	}

	function checkTab(theForm) {
		var isError = 0;
		var tabError = "$tabmenu_txt{'taberr'}\\n";

		if (theForm.tabtext.value == "") { tabError += "\\n- $tabmenu_txt{'texterr'}"; if(isError == 0) isError = 1; }
		if (theForm.taburl.value == "") { tabError += "\\n- $tabmenu_txt{'urlerr'}"; if(isError == 0) isError = 2; }
		if(isError >= 1) {
			alert(tabError);
			if(isError == 1) theForm.tabtext.focus();
			else if(isError == 2) theForm.taburl.focus();
			else if(isError == 3) theForm.tabtext.focus();
			return false;
		}
		return true
	}
	//-->
	</script>

	<form action="$scripturl?action=addtab2" method="post" name="addtabtext" style="font-size: 11px; display: inline;" onsubmit="if(!checkTab(this)) {return false} else {return submittab()}">
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td class="tabmenuleft" width="40">&nbsp;</td>
		<td class="tabmenu" align="right" valign="middle" style="text-align: left; vertical-align: middle;">
			<span class="selected" style="cursor: auto; vertical-align: middle; padding-top: 1px; white-space: nowrap;"><label for="tabtext">$tabfill$tabmenu_txt{'tabtext'}</label> <input type="text" name="tabtext" id="tabtext" value="" size="10" class="small" style="vertical-align: middle;" /></span>
			<span class="selected" style="cursor: auto; vertical-align: middle; padding-top: 1px; white-space: nowrap;"><label for="taburl">$tabfill$tabmenu_txt{'taburl'}</label> <input type="text" name="taburl" id="taburl" value="" size="25" class="small" style="vertical-align: middle;" /></span>

			<span class="selected" style="cursor: auto; vertical-align: middle; padding-top: 1px; white-space: nowrap;"><label for="tabwin">$tabfill$tabmenu_txt{'tabwin'}</label> <input type="checkbox" name="tabwin" id="tabwin" style="border: 0; padding: 0; margin: 0; background-color: transparent; vertical-align: middle;" /></span>

			<span class="selected" style="cursor: auto; vertical-align: middle; padding-top: 1px; white-space: nowrap;"><label for="showto">$tabfill$tabmenu_txt{'tabview'}</label>
				<select name="showto" id="showto" class="small" style="vertical-align: middle;">
					<option value="0" selected="selected">$tabmenu_txt{'viewall'}</option>
					<option value="1">$tabmenu_txt{'viewmem'}</option>
					<option value="2">$tabmenu_txt{'viewgm'}</option>
					<option value="3">$tabmenu_txt{'viewadm'}</option>
				</select>
			</span>
			<span class="selected" style="cursor: auto; vertical-align: middle; padding-top: 1px; white-space: nowrap;"><label for="addafter">$tabfill$tabmenu_txt{'tabinsert'}</label>
				<select name="addafter" id="addafter" class="small" style="vertical-align: middle;">
					$edittabs
				</select>
			</span>
			<span class="selected" style="cursor: auto; vertical-align: middle; padding-top: 1px; white-space: nowrap;">$tabfill<input type="submit" value="$tabmenu_txt{'addtab'}" class="small" style="vertical-align: middle;" />$tabfill</span>$tabsep
		</td>
	</tr>
	</table>
	</form>
~;
}

sub AddNewTab2 {
	if ($iamadmin) {
		my $tabtext = $FORM{'tabtext'};
		my $taburl = $FORM{'taburl'};
		$taburl =~ s/"/\%22/g;
		my $tabwin = $FORM{'tabwin'} ? 1 : 0;
		my $tabview = $FORM{'showto'};
		my $tabafter = $FORM{'addafter'};
		my $tmpusernamereq = 0;

		if ($taburl !~ /^\http:\/\//) { $taburl = qq~http://$taburl~; }

		if($taburl =~ /$boardurl\/$yyexec\.$yyaext/i && $taburl =~ /action\=(.*?)(\;|\Z)/i) {
			$taburl = 1;
			$tabaction = $1;
			$tmpisaction = 1;
		} elsif($taburl =~ /$boardurl\/AdminIndex\.$yyaext/i && $taburl =~ /action\=(.*?)(\;|\Z)/i) {
			$taburl = 2;
			$tabaction = $1;
			$tmpisaction = 1;
		} else {
			$tabaction = lc $tabtext;
			$tabaction =~ s/ /\_/g;
			$tmpisaction = 0;
		}
		$tabaction =~ s/\W/_/g;
		map { &fatal_error('tabext',$tabaction) if $_ =~ /^$tabaction\|?/; } @AdvancedTabs;

		if ($taburl == 1 || $taburl == 2) {
			if ($FORM{'taburl'} =~ m/username\=/i) { $tmpusernamereq = 1; }
			$exttaburl = $FORM{'taburl'};
			$exttaburl =~ s/(.*?)\?(.*?)/$2/g;
			$exttaburl =~ s/action\=(.*?)(\;|\Z)//i;
			$exttaburl =~ s/username\=(.*?)(\;|\Z)//i;
		} else {
			$exttaburl = "";
		}

		&ToHTML($tabtext);

		opendir(DIR, $langdir);
		my @languages = readdir(DIR);
		closedir(DIR);
		foreach $lngdir (@languages) {
			next if $lngdir eq "." || $lngdir eq ".." || !-d "$langdir/$lngdir";
			undef %tabtxt;
			%tabtxt = map /(.*)\t(.*)/, &read_DBorFILE(1,'',"$langdir/$lngdir",'tabtext','txt');
			$tabtxt{$tabaction} = $tabtext;
			&write_DBorFILE(0,'',"$langdir/$lngdir",'tabtext','txt',(map "$_\t$tabtxt{$_}\n", keys %tabtxt));
		}

		my @new_tabs_order;
		if($tabafter eq "thefront") {
			push(@new_tabs_order, qq~$tabaction|$taburl|$tmpisaction|$tmpusernamereq|$tabview|$tabwin|$exttaburl~);
		}
		foreach (@AdvancedTabs) {
			push(@new_tabs_order, $_);
			if (/^$tabafter\|?/) {
				push(@new_tabs_order, qq~$tabaction|$taburl|$tmpisaction|$tmpusernamereq|$tabview|$tabwin|$exttaburl~);
			}
		}
		@AdvancedTabs = @new_tabs_order;

		require "$admindir/NewSettings.pl";
		&SaveSettingsTo('Settings.pl');
	}

	$yySetLocation = $scripturl;
	&redirectexit;
}

sub EditTab {
	$tabsave = qq~<img src="$imagesdir/tabsave.gif" border="0" alt="$tabmenu_txt{'savetab'}" title="$tabmenu_txt{'savetab'}" style="vertical-align: middle;" />~;
	$tabdel = qq~<img src="$imagesdir/tabdelete.gif" border="0" alt="$tabmenu_txt{'tabdel'}" title="$tabmenu_txt{'tabdel'}" style="vertical-align: middle;" />~;
	$tabstyle = qq~style="font-size: 11px; white-space: nowrap; cursor: auto;"~;

	$edittab{'home'} = qq~<span $tabstyle>$tabfill$img_txt{'103'}$tabfill</span>~;
	$edittab{'help'} = qq~<span $tabstyle>$tabfill$img_txt{'119'}$tabfill</span>~;
	$edittab{'search'} = qq~<span $tabstyle>$tabfill$img_txt{'182'}$tabfill</span>~;
	$edittab{'ml'} = qq~<span $tabstyle>$tabfill$img_txt{'331'}$tabfill</span>~;
	$edittab{'eventcal'} = qq~<span $tabstyle>$tabfill$img_txt{'eventcal'}$tabfill</span>~;
	$edittab{'birthdaylist'} = qq~<span $tabstyle>$tabfill$img_txt{'birthdaylist'}$tabfill</span>~;
	$edittab{'admin'} = qq~<span $tabstyle>$tabfill$img_txt{'2'}$tabfill</span>~;
	$edittab{'revalidatesession'} = qq~<span $tabstyle>$tabfill$img_txt{'34a'}$tabfill</span>~;
	$edittab{'login'} = qq~<span $tabstyle>$tabfill$img_txt{'34'}$tabfill</span>~;
	$edittab{'register'} = qq~<span $tabstyle>$tabfill$img_txt{'97'}$tabfill</span>~;
	$edittab{'guestpm'} = qq~<span $tabstyle>$tabfill$img_txt{'pmadmin'}$tabfill</span>~;
	$edittab{'mycenter'} = qq~<span $tabstyle>$tabfill$img_txt{'mycenter'}$tabfill</span>~;
	$edittab{'logout'} = qq~<span $tabstyle>$tabfill$img_txt{'108'}$tabfill</span>~;

	&GetTexttab;

	my $selsize = 0;
	my $isexttabs = 0;
	for (my $i = 0; $i < @AdvancedTabs; $i++) {
		if ($AdvancedTabs[$i] =~ /\|/) {
			my ($tab_key, $tmptab_url, $isaction, $username_req, $tab_access, $dummy) = split(/\|/, $AdvancedTabs[$i], 6);
			my $enc_key = $tab_key;
			$enc_key =~ s~\&~%26~g;
			$isexttabs++;
			if (!$tab_access || ($tab_access < 2 && !$iamguest) || ($tab_access < 3 && $iamgmod) || $iamadmin) {
				if ($tmptab_url == 1) { $tab_url = qq~$scripturl~; }
				elsif ($tmptab_url == 2) { $tab_url = qq~$boardurl/AdminIndex.$yyaext~; }
				else { $tab_url = qq~$tmptab_url~; }
				if ($isaction) { $tab_url .= qq~?action=$tab_key~; }
				if ($username_req) { $tab_url .= qq~;username=$useraccount{$username}~; }
				$inputlength = length($tabtxt{$tab_key});
				$edittab{$tab_key} = qq~<form action="$scripturl?action=edittab2;savetab=$enc_key" method="post" name="$tab_key$isexttabs" style="display: inline; white-space: nowrap;">~;
				$edittab{$tab_key} .= qq~<span $tabstyle>$tabfill~;
				$edittab{$tab_key} .= qq~<input type="text" name="$tab_key" id="$tab_key" value="$tabtxt{$tab_key}" size="$inputlength" class="small" style="font-size: 11px; border: 0; margin: 0; padding: 0; background-color: transparent; vertical-align: middle;" />$tabfill~;
				$edittab{$tab_key} .= qq~<input type="image" src="$imagesdir/tabsave.gif" alt="$tabmenu_txt{'savetab'}" title="$tabmenu_txt{'savetab'}" style="background-color: transparent; border:0; vertical-align: middle;" />~;
				$edittab{$tab_key} .= qq~ <a href="$scripturl?action=deletetab;deltab=$enc_key">$tabdel</a>~;
				$edittab{$tab_key} .= qq~$tabfill</span>~;
				$edittab{$tab_key} .= qq~</form>~;
				$edittabs .= qq~<option value="$tab_key"~ . ($tab_key eq $INFO{"thetab"} ? ' selected="selected"' : '') . qq~>$texttab{$tab_key}</option>~;
				$edittabmenu .= $edittab{$tab_key} . $tabsep;
				$selsize++;
			}
		} elsif ($edittab{$AdvancedTabs[$i]}) {
			$edittabs .= qq~<option value="$AdvancedTabs[$i]"~ . ($AdvancedTabs[$i] eq $INFO{"thetab"} ? ' selected="selected"' : '') . qq~>$texttab{$AdvancedTabs[$i]}</option>~;
			$edittabmenu .= $edittab{$AdvancedTabs[$i]} . $tabsep;
			$selsize++;
		}
	}
	if ($selsize > 11) { $selsize = 11; }

	$yyaddtab = qq~
	<br />
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td class="tabmenuleft" width="40" style="text-align: left; vertical-align: top;">&nbsp;</td>
		<td class="tabmenu" style="text-align: left; vertical-align: top;">
			$edittabmenu
		</td>
		<td class="tabmenuright" width="45" style="text-align: left; vertical-align: top;">&nbsp;</td>
		<td class="rightbox" width="160" align="center" valign="middle">
			<b>$tabmenu_txt{'reordertab'}</b>
		</td>

	</tr>
	<tr>
		<td colspan="3">&nbsp;</td>
		<td width="160" align="center" valign="top" rowspan="3">
			<form action="$scripturl?action=reordertab" method="post" name="tabsorder" style="display: inline; white-space: nowrap;">
			<select name="ordertabs" class="small" size="$selsize" style="width: 130px;">
				$edittabs
			</select><br />
			<input type="submit" value="$tabmenu_txt{'tableft'}" name="moveleft" style="font-size: 11px; width: 65px;" /><input type="submit" value="$tabmenu_txt{'tabright'}" name="moveright" style="font-size: 11px; width: 65px;" />
			</form>
		</td>
	</tr>
	<tr>
		<td width="40">&nbsp;</td>
		<td class="windowbg" style="text-align: left;">
			<div class="small" style="float: left; width: 98%; padding: 4px;">
				$tabmenu_txt{'edittext1'} $tabsave$tabmenu_txt{'edittext2'}$tabdel$tabmenu_txt{'edittext3'}<br />
				$tabmenu_txt{'reordertext'}
			</div>

		</td>
		<td width="45">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="3" style="font-size: 50px; text-align: left; vertical-align: top;">&nbsp;</td>
	</tr>
	</table>
~;
	undef %edittab;
}

sub EditTab2 {
	if($iamadmin) {
		$tosave = $INFO{'savetab'};
		$tosave =~ s~%26~&~g;
		$tosavetxt = $FORM{$tosave};
		&ToHTML($tosavetxt);
		$tab_lang = $language ? $language : $lang;
		%tabtxt = map /(.*)\t(.*)/, &read_DBorFILE(0,'',"$langdir/$tab_lang",'tabtext','txt');
		$tabtxt{$tosave} = $tosavetxt;
		&write_DBorFILE(0,'',"$langdir/$tab_lang",'tabtext','txt',(map "$_\t$tabtxt{$_}\n", keys %tabtxt));
	}

	$yySetLocation = $scripturl;
	&redirectexit;
}

sub ReorderTab {
	my $moveitem = $FORM{'ordertabs'};
	if ($iamadmin) {
		if ($moveitem) {
			if ($FORM{'moveleft'}) {
				for ($i = 0; $i < @AdvancedTabs; $i++) {
					if ($AdvancedTabs[$i] =~ /^$moveitem\|?/ && $i > 0) {
						my $j = $i - 1;
						my $x = $AdvancedTabs[$i];
						$AdvancedTabs[$i] = $AdvancedTabs[$j];
						$AdvancedTabs[$j] = $x;
						last;
					}
				}
			} elsif ($FORM{'moveright'}) {
				for ($i = 0; $i < @AdvancedTabs; $i++) {
					if ($AdvancedTabs[$i] =~ /^$moveitem\|?/ && $i < $#AdvancedTabs) {
						my $j = $i + 1;
						my $x = $AdvancedTabs[$i];
						$AdvancedTabs[$i] = $AdvancedTabs[$j];
						$AdvancedTabs[$j] = $x;
						last;
					}
				}
			}
		}

		require "$admindir/NewSettings.pl";
		&SaveSettingsTo('Settings.pl');
	}

	$yySetLocation = qq~$scripturl?action=edittab;thetab=$moveitem~;
	&redirectexit;
}

sub DeleteTab {
	if ($iamadmin) {
		my $todelete = $INFO{'deltab'};
		$todelete =~ s~%26~&~g;

		opendir(DIR, $langdir);
		@languages = readdir(DIR);
		closedir(DIR);
		foreach $lngdir (@languages) {
			if ($lngdir eq "." || $lngdir eq ".." || !-d "$langdir/$lngdir" || !-e "$langdir/$lngdir/tabtext.txt") { next; }
			%tabtxt = map /(.*)\t(.*)/, &read_DBorFILE(0,'',"$langdir/$lngdir",'tabtext','txt');
			delete $tabtxt{$todelete};
			if (!%tabtxt) {
				&delete_DBorFILE("$langdir/$lngdir/tabtext.txt");
			} else {
				&write_DBorFILE(0,'',"$langdir/$lngdir",'tabtext','txt',(map "$_\t$tabtxt{$_}\n", keys %tabtxt));
			}
		}

		my @new_tabs_order;
		foreach (@AdvancedTabs) {
			if ($_ !~ /^$todelete\|?/) { push(@new_tabs_order, $_); }
		}
		@AdvancedTabs = @new_tabs_order;
		require "$admindir/NewSettings.pl";
		&SaveSettingsTo('Settings.pl');
	}

	$yySetLocation = $scripturl;
	&redirectexit;
}

sub GetTexttab {
	$texttab{'home'} = $img_txt{'103'};
	$texttab{'help'} = $img_txt{'119'};
	$texttab{'search'} = $img_txt{'182'};
	$texttab{'ml'} = $img_txt{'331'};
	$texttab{'eventcal'} = $img_txt{'eventcal'};
	$texttab{'birthdaylist'} = $img_txt{'birthdaylist'};
	$texttab{'admin'} = $img_txt{'2'};
	$texttab{'revalidatesession'} = $img_txt{'34a'};
	$texttab{'login'} = $img_txt{'34'};
	$texttab{'register'} = $img_txt{'97'};
	$texttab{'guestpm'} = $img_txt{'pmadmin'};
	$texttab{'mycenter'} = $img_txt{'mycenter'};
	$texttab{'logout'} = $img_txt{'108'};

	&GetTabtxt unless $tab_lang;
	foreach (keys %tabtxt) { $texttab{$_} = $tabtxt{$_}; }
}

1;