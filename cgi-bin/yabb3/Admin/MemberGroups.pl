###############################################################################
# MemberGroups.pl                                                             #
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

$membergroupsplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub EditMemberGroups {
	&is_admin_or_gmod;
	my ($MemStatAdmin, $MemStarNumAdmin, $MemStarPicAdmin, $MemTypeColAdmin, $noshowAdmin, $viewpermsAdmin, $topicpermsAdmin, $replypermsAdmin, $pollpermsAdmin, $attachpermsAdmin, undef) = split(/\|/, $Group{'Administrator'});
	my ($MemStatGMod, $MemStarNumGMod, $MemStarPicGMod, $MemTypeColGMod, $noshowGMod, $viewpermsGMod, $topicpermsGMod, $replypermsGMod, $pollpermsGMod, $attachpermsGMod, undef) = split(/\|/, $Group{'Global Moderator'});
	my ($MemStatMod, $MemStarNumMod, $MemStarPicMod, $MemTypeColMod, $noshowMod, $viewpermsMod, $topicpermsMod, $replypermsMod, $pollpermsMod, $attachpermsMod, undef) = split(/\|/, $Group{'Moderator'});
	my $noshowAdmin = ($noshowAdmin == 1) ? "$admin_txt{'164'}" : "$admin_txt{'163'}";
	my $noshowGMod = ($noshowGMod == 1) ? "$admin_txt{'164'}" : "$admin_txt{'163'}";
	my $noshowMod = ($noshowMod == 1) ? "$admin_txt{'164'}" : "$admin_txt{'163'}";
	my $adminpi = &permImage($viewpermsAdmin, $topicpermsAdmin, $replypermsAdmin, $pollpermsAdmin, $attachpermsAdmin);
	my $gmodpi = &permImage($viewpermsGMod,  $topicpermsGMod, $replypermsGMod, $pollpermsGMod, $attachpermsGMod);
	my $modpi = &permImage($viewpermsMod, $topicpermsMod, $replypermsMod, $pollpermsMod, $attachpermsMod);

	$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/guest.gif" alt="" border="0" />&nbsp;<b>$admin_txt{'8'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		$admin_txt{'11'}<br /><br />
	   </td>
     </tr>
   </table>
 </div>

<br />

<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td align="left" class="titlebg" colspan="6">
		<img src="$imagesdir/guest.gif" alt="" border="0" />&nbsp;<b>$admin_txt{'12'}</b>
		</td>
	</tr>
	<tr valign="middle">
		<td align="center" class="catbg" width="25%"><b>$amgtxt{'03'}</b></td>
		<td align="center" class="catbg" width="15%"><b>$amgtxt{'19'}</b></td>
		<td align="center" class="catbg" width="10%"><b>$amgtxt{'08'}</b></td>
		<td align="center" class="catbg" width="25%"><b>$amgtxt{'01'}</b></td>
		<td align="center" class="catbg" width="10%"><b>$admin_txt{'53'}</b></td>
		<td align="center" class="catbg" width="15%"><b>&nbsp;</b></td>
	</tr>
	<tr valign="middle">
		<td align="center" class="windowbg2">$MemStatAdmin</td>
		<td align="center" class="windowbg2"><img src="$imagesdir/$MemStarPicAdmin" /> x $MemStarNumAdmin</td>~;

	if ($MemTypeColAdmin) {
		$thecolname = &hextoname($MemTypeColAdmin);
		$yymain .= qq~
		<td align="center" class="windowbg2"><span style="color:$MemTypeColAdmin">$thecolname</span></td>~;
	} else {
		$yymain .= qq~
		<td align="center" class="windowbg2" width="10%">&nbsp;</td>~;
	}
	$yymain .= qq~
		<td align="center" class="windowbg2">$noshowAdmin</td>
		<td align="center" class="windowbg2"><a href="$adminurl?action=editgroup;group=Administrator">$admin_txt{'53'}</a></td>
		<td align="center" class="windowbg2">&nbsp;</td>
	</tr>
	<tr valign="middle">
		<td align="center" class="windowbg2">$MemStatGMod</td>
		<td align="center" class="windowbg2"><img src="$imagesdir/$MemStarPicGMod" /> x $MemStarNumGMod</td>~;
	if ($MemTypeColGMod) {
		$thecolname = &hextoname($MemTypeColGMod);
		$yymain .= qq~
		<td align="center" class="windowbg2"><span style="color:$MemTypeColGMod">$thecolname</span></td>~;
	} else {
		$yymain .= qq~
		<td align="center" class="windowbg2" width="10%">&nbsp;</td>~;
	}
	$yymain .= qq~
		<td align="center" class="windowbg2">$noshowGMod</td>
		<td align="center" class="windowbg2"><a href="$adminurl?action=editgroup;group=Global Moderator">$admin_txt{'53'}</a></td>
		<td align="center" class="windowbg2">&nbsp;</td>
	</tr>
	<tr valign="middle">
		<td align="center" class="windowbg2">$MemStatMod</td>
		<td align="center" class="windowbg2"><img src="$imagesdir/$MemStarPicMod" /> x $MemStarNumMod</td>~;

	if ($MemTypeColMod) {
		$thecolname = &hextoname($MemTypeColMod);
		$yymain .= qq~
		<td align="center" class="windowbg2"><span style="color:$MemTypeColMod">$thecolname</span></td>~;
	} else {
		$yymain .= qq~
		<td align="center" class="windowbg2" width="10%">&nbsp;</td>~;
	}
	$yymain .= qq~
		<td align="center" class="windowbg2">$noshowMod</td>
		<td align="center" class="windowbg2"><a href="$adminurl?action=editgroup;group=Moderator">$admin_txt{'53'}</a></td>
		<td align="center" class="windowbg2">&nbsp;</td>
	</tr>
</table>
</div>

<br />
~;

	my $colspan = 6; 
	my $width1 = '25%';
	my $width2 = '10%';
	my $width3 = '15%';
	if ($addmemgroup_enabled > 0) {
		$additional_tablehead = qq~<td align="center" class="catbg" width="15%"><b>$amgtxt{'83'}</b></td>~;
		$colspan = 7;
		$width1 = '20%';
		$width2 = '5%';
		$width3 = '10%';
	}
	my $reorderlink = "";
	if ($#nopostorder) {
		$reorderlink = qq~ | <a href="$adminurl?action=reordergroup">$admintxt{'reordergroups'}</a>~;
	}

	$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td align="left" class="titlebg" colspan="$colspan">
		<img src="$imagesdir/guest.gif" alt="" border="0" />&nbsp;<b>$amgtxt{'37'} (<a href="$adminurl?action=editgroup">$admintxt{'18c'}</a>$reorderlink)</b>
		</td>
	</tr>
	<tr valign="middle">
		<td align="center" class="catbg" width="25%"><b>$amgtxt{'03'}</b></td>
		<td align="center" class="catbg" width="15%"><b>$amgtxt{'19'}</b></td>
		<td align="center" class="catbg" width="10%"><b>$amgtxt{'08'}</b></td>
		<td align="center" class="catbg" width="$width1"><b>$amgtxt{'01'}</b></td>
		$additional_tablehead
		<td align="center" class="catbg" width="$width2"><b>$admin_txt{'53'}</b></td>
		<td align="center" class="catbg" width="$width3"><b>$admin_txt{'54'}</b></td>
	</tr>~;

	$count = 0;
	foreach (@nopostorder) {
		($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms, $additional) = split(/\|/, $NoPost{$_});
		$permimage = "";
		$permimage = &permImage($viewperms, $topicperms, $replyperms, $pollperms, $attachperms);
		$noshow = ($noshow == 1) ? "$admin_txt{'164'}" : "$admin_txt{'163'}";
		$additional = ($additional == 0) ? "$admin_txt{'164'}" : "$admin_txt{'163'}";
		if (!$stars) { $stars = "0"; }
		$yymain .= qq~
	<tr>
		<td align="center" class="windowbg2">$title</td>
		<td align="center" class="windowbg2"><img src="$imagesdir/$starpic" /> x $stars</td>~;

		if ($color) {
			$thecolname = &hextoname($color);
			$yymain .= qq~
		<td align="center" class="windowbg2"><span style="color:$color">$thecolname</span></td>~;
		} else {
			$yymain .= qq~
		<td align="center" class="windowbg2">&nbsp;</td>~;
		}

		$yymain .= qq~
		<td align="center" class="windowbg2">$noshow</td>~;

		if ($addmemgroup_enabled > 0) {
			$yymain .= qq~
		<td align="center" class="windowbg2">$additional</td>~;
		}

		$yymain .= qq~
		<td align="center" class="windowbg2"><a href="$adminurl?action=editgroup;group=NP|$_">$admin_txt{'53'}</a></td>
		<td align="center" class="windowbg2"><a href="$adminurl?action=delgroup;group=NP|$_">$admin_txt{'54'}</a></td>
	</tr>~;
		$count++;
	}

	if ($count == 0) {
		$yymain .= qq~
	<tr>
		<td align="center" class="windowbg2" colspan="6">$amgtxt{'35'}</td>
	</tr>~;
	}

	$yymain .= qq~
</table>
</div>

<br />

<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td align="left" class="titlebg" colspan="6">
		<img src="$imagesdir/guest.gif" alt="" border="0" />&nbsp;<b>$amgtxt{'40'}&nbsp;(<a href="$adminurl?action=editgroup1">$admintxt{'18c'}</a>)</b>
		</td>
	</tr>
	<tr valign="middle">
		<td align="center" class="catbg" width="25%"><b>$amgtxt{'03'}</b></td>
		<td align="center" class="catbg" width="15%"><b>$amgtxt{'19'}</b></td>
		<td align="center" class="catbg" width="10%"><b>$amgtxt{'08'}</b></td>
		<td align="center" class="catbg" width="25%"><b>$admin_txt{'21'}</b></td>
		<td align="center" class="catbg" width="10%"><b>$admin_txt{'53'}</b></td>
		<td align="center" class="catbg" width="15%"><b>$admin_txt{'54'}</b></td>
	</tr>~;

	my $count = 0;
	foreach (sort { $b <=> $a } keys %Post) {
		my ($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms, undef) = split(/\|/, $Post{$_});

		$permimage = "";
		$permimage = &permImage($viewperms, $topicperms, $replyperms, $pollperms, $attachperms);
		$noshow    = ($noshow == 1) ? "$admin_txt{'164'}" : "$admin_txt{'163'}";
		if (!$stars) { $stars = "0"; }
		if ($starpic !~ /\//) { $starpic = "$imagesdir/$starpic"; }
		$yymain .= qq~
	<tr>
		<td align="center" class="windowbg2" width="25%">$title</td>
		<td align="center" class="windowbg2" width="15%"><img src="$starpic" /> x $stars</td>~;

		if ($color) {
			$thecolname = &hextoname($color);
			$yymain .= qq~
		<td align="center" class="windowbg2" width="10%"><span style="color: $color;">$thecolname</span></td>~;
		} else {
			$yymain .= qq~
		<td align="center" class="windowbg2" width="10%">&nbsp;</td>~;
		}

		$yymain .= qq~
		<td align="center" class="windowbg2" width="25%">$_</td>
		<td align="center" class="windowbg2" width="10%"><a href="$adminurl?action=editgroup;group=P|$_">$admin_txt{'53'}</a></td>
		<td align="center" class="windowbg2" width="15%"><a href="$adminurl?action=delgroup;group=P|$_">$admin_txt{'54'}</a></td>
	</tr>~;
		$count++;
	}

	if ($count == 0) {
		$yymain .= qq~
	<tr>
		<td class="windowbg2" colspan="6">$amgtxt{'36'}</td>
	</tr>~;
	}
	$yymain .= qq~
</table>
</div>
~;

	$yytitle = $admin_txt{'8'};
	$action_area = 'modmemgr';

	&AdminTemplate;
}

sub hextoname {
	$colorname = $_[0];
	$colorname =~ s~aqua|#00FFFF~$amgtxt{'56'}~i;
	$colorname =~ s~black|#000000~$amgtxt{'57'}~i;
	$colorname =~ s~blue|#0000FF~$amgtxt{'58'}~i;
	$colorname =~ s~fuchsia|#FF00FF~$amgtxt{'59'}~i;
	$colorname =~ s~gray|#808080~$amgtxt{'60'}~i;
	$colorname =~ s~green|#008000~$amgtxt{'61'}~i;
	$colorname =~ s~lime|#00FF00~$amgtxt{'62'}~i;
	$colorname =~ s~maroon|#800000~$amgtxt{'63'}~i;
	$colorname =~ s~navy|#000080~$amgtxt{'64'}~i;
	$colorname =~ s~olive|#808000~$amgtxt{'65'}~i;
	$colorname =~ s~purple|#800080~$amgtxt{'66'}~i;
	$colorname =~ s~red|#FF0000~$amgtxt{'67'}~i;
	$colorname =~ s~silver|#C0C0C0~$amgtxt{'68'}~i;
	$colorname =~ s~teal|#008080~$amgtxt{'69'}~i;
	$colorname =~ s~white|#FFFFFF~$amgtxt{'70'}~i;
	$colorname =~ s~yellow|#FFFF00~$amgtxt{'71'}~i;
	$colorname =~ s~#DEB887~$amgtxt{'75'}~i;
	$colorname =~ s~#FFD700~$amgtxt{'76'}~i;
	$colorname =~ s~#FFA500~$amgtxt{'77'}~i;
 	$colorname =~ s~#A0522D~$amgtxt{'78'}~i;
	$colorname =~ s~#87CEEB~$amgtxt{'79'}~i;
	$colorname =~ s~#6A5ACD~$amgtxt{'80'}~i;
	$colorname =~ s~#4682B4~$amgtxt{'81'}~i;
	$colorname =~ s~#9ACD32~$amgtxt{'82'}~i;
	return $colorname;
}

sub editAddGroup {
	&is_admin_or_gmod;
	if ($INFO{'group'}) {
		$viewtitle = $admintxt{'18a'};
		($type, $element) = split(/\|/, $INFO{'group'});
		if ($element ne '') {
			if ($type eq 'P') {
				$posts = $element;
				($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms, $additional) = split(/\|/, $Post{$element});
			} else {
				$noposts = $element;
				$choosable = 1;
				($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms, $additional) = split(/\|/, $NoPost{$element});
			}
		} else {
			($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms, $additional) = split(/\|/, $Group{$INFO{'group'}});
		}
	} else {
		$viewtitle = $admintxt{'18b'};
		$title = '';
		$stars = '';
		$starpic = '';
		$color = '';
		$posts = '';
		$noposts = 1;
		foreach (sort { $a <=> $b } keys %NoPost) {
			$noposts = $_ + 1;
		}
	}
	
	if ($stars !~ /\A[0-9]+\Z/) { $stars = 0; }

	$otherdisable = qq~ disabled="disabled"~;

	# Get star selected if needed.
	if    ($starpic eq "staradmin.gif")  { $stars1 = "selected=\"selected\"" }
	elsif ($starpic eq "stargmod.gif")   { $stars2 = "selected=\"selected\"" }
	elsif ($starpic eq "starmod.gif")    { $stars3 = "selected=\"selected\"" }
	elsif ($starpic eq "starblue.gif")   { $stars4 = "selected=\"selected\"" }
	elsif ($starpic eq "starsilver.gif") { $stars5 = "selected=\"selected\"" }
	elsif ($starpic eq "stargold.gif")   { $stars6 = "selected=\"selected\"" }
	elsif ($starpic eq "")               { $stars1 = "selected=\"selected\"" }
	else { $stars7 = "selected=\"selected\""; $pick = $starpic; $otherdisable = ""; }
	my $starurl = ($starpic !~ m~http://~ ? "$imagesdir/" : "") . ($starpic ? $starpic : "blank.gif");

	$color =~ s/\#//g;

	$pc = qq~ checked="checked"~;
	$pd = "";
	$pt = "";

	if ($noshow) { $pc = ''; }
	if ($additional) { $admg = qq~ checked="checked"~; }

	if ($posts eq "" && $action ne "editgroup1") { $post2 = qq~ checked="checked"~; $pt = qq~ disabled="disabled"~; }
	else { $post1 = qq~ checked="checked"~; $pd = qq~ disabled="disabled"~; }

	if ($viewperms == 1) { $vc  = qq~ checked="checked"~; }
	if ($topicperms == 1) { $tc  = qq~ checked="checked"~; }
	if ($replyperms == 1) { $rc  = qq~ checked="checked"~; }
	if ($pollperms == 1) { $poc = qq~ checked="checked"~; }
	if ($attachperms == 1) { $ac  = qq~ checked="checked"~; }

	$yymain .= qq~

<form name="groups" action="$adminurl?action=editAddGroup2" method="post">
<input type="hidden" name="original" value="$INFO{'group'}" />
<input type="hidden" name="origin" value="$action" />

<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td align="left" class="titlebg" colspan="2">
		<img src="$imagesdir/preferences.gif" alt="" border="0" /> <b>$viewtitle</b>
		</td>
	</tr>
	<tr valign="middle">
		<td class="windowbg" width="40%"><label for="title">$amgtxt{'51'}:</label></td>
		<td class="windowbg2" width="60%"><input type="text" name="title" id="title" value="$title" /></td>
	</tr><tr>
		<td class="windowbg"><label for="numstars">$amgtxt{'05'}</label></td>
		<td class="windowbg2"><input type="text" name="numstars" id="numstars" size="2" value="$stars" /></td>
	</tr><tr>
		<td class="windowbg"><label for="starsadmin">$amgtxt{'38'}:</label></td>
		<td class="windowbg2">
			<select name="starsadmin" id="starsadmin" onchange="stars(this.value); showimage();">
			<option value="staradmin.gif" $stars1>$amgtxt{'20'}</option>
			<option value="stargmod.gif" $stars2>$amgtxt{'21'}</option>
			<option value="starmod.gif" $stars3>$amgtxt{'22'}</option>
			<option value="starblue.gif" $stars4>$amgtxt{'23'}</option>
			<option value="starsilver.gif" $stars5>$amgtxt{'24'}</option>
			<option value="stargold.gif" $stars6>$amgtxt{'25'}</option>
			<option value="other" $stars7>$amgtxt{'26'}</option>
			</select>
			&nbsp;
			<label for="otherstar"><b>$amgtxt{'26'}</b></label> <input type="text" name="otherstar" id="otherstar" onchange="showimage();" value="$pick"$otherdisable />
			&nbsp;
			<img src="$starurl" name="starpic" border="0" alt="" />
		</td>
	</tr><tr>
		<td class="windowbg"><label for="color">$amgtxt{'08'}:</label></td>
		<td class="windowbg2" >
			<select name="color" id="color" onchange="viscolor(this.options[this.selectedIndex].value);">
			<option value=""></option>
			<option value="00FFFF">$amgtxt{'56'}</option>
			<option value="000000">$amgtxt{'57'}</option>
			<option value="0000FF">$amgtxt{'58'}</option>
			<option value="FF00FF">$amgtxt{'59'}</option>
			<option value="808080">$amgtxt{'60'}</option>
			<option value="008000">$amgtxt{'61'}</option>
			<option value="00FF00">$amgtxt{'62'}</option>
			<option value="800000">$amgtxt{'63'}</option>
			<option value="000080">$amgtxt{'64'}</option>
			<option value="808000">$amgtxt{'65'}</option>
			<option value="800080">$amgtxt{'66'}</option>
			<option value="FF0000">$amgtxt{'67'}</option>
			<option value="C0C0C0">$amgtxt{'68'}</option>
			<option value="008080">$amgtxt{'69'}</option>
			<option value="FFFFFF">$amgtxt{'70'}</option>
			<option value="FFFF00">$amgtxt{'71'}</option>
			<option value="DEB887">$amgtxt{'75'}</option>
			<option value="FFD700">$amgtxt{'76'}</option>
			<option value="FFA500">$amgtxt{'77'}</option>
			<option value="A0522D">$amgtxt{'78'}</option>
			<option value="87CEEB">$amgtxt{'79'}</option>
			<option value="6A5ACD">$amgtxt{'80'}</option>
			<option value="4682B4">$amgtxt{'81'}</option>
			<option value="9ACD32">$amgtxt{'82'}</option>
			</select> &nbsp;
			<span id="grpcolor"~ . ($color ne '' ? qq* style="color: #$color;"* : '') . qq~><label for="color2"><b>$amgtxt{'08'}</b></label></span>
			#<input type="text" name="color2" id="color2" size="6" value="$color" maxlength="6" onkeyup="viscolor(this.value);" /> &nbsp;
			<img src="$imagesdir/palette1.gif" style="cursor: pointer" onclick="window.open('$scripturl?action=palette;task=templ', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" align="top" alt="" border="0" /> 
		</td>
	</tr>~;

	# Get color selected
	$yymain =~ s/(<option value="$color")/$1 selected="selected"/;

	unless (exists $Group{$INFO{'group'}}) {
		$yymain .= qq~
	<tr>
		<td class="windowbg"><label for="postindepend">$amgtxt{'39a'}</label></td>
		<td class="windowbg2">
			<input type="radio" name="postdepend" id="postindepend" value="No" $post2 class="windowbg2" style="border: 0px; vertical-align: middle;" onclick="depend(this.value)" /><br />
			<label for="viewpublic"><b>$amgtxt{'42'}?</b>
			<input type="checkbox" name="viewpublic" id="viewpublic" value="1"$pc$pd style="vertical-align: middle;" /> <br />$amgtxt{'43'}</label>
			<input type="hidden" name="noposts" id="noposts" value="$noposts" />
		</td>
	</tr><tr>
		<td class="windowbg"><label for="postdepend">$amgtxt{'39'}</label></td>
		<td class="windowbg2">
			<input type="radio" name="postdepend" id="postdepend" value="Yes" $post1 class="windowbg2" style="border: 0px; vertical-align: middle;" onclick="depend(this.value)" /><br />
			<label for="posts"><b>$amgtxt{'04'}</b></label> <input type="text" name="posts" id="posts" size="5" value="$posts"$pt style="vertical-align: middle;" />
		</td>
	</tr>~;

	} else {
		$yymain .= qq~
	<tr>
		<td class="windowbg"><label for="viewpublic"><b>$amgtxt{'42'}</b> <br /><b>$amgtxt{'43'}</b></label></td>
		<td class="windowbg2">
			<input type="checkbox" name="viewpublic" id="viewpublic" value="1"$pc$pd style="vertical-align: middle;" />
		</td>
	</tr>~;
	}

	if ($addmemgroup_enabled > 0) {
		if ($choosable || (!$choosable && $action ne 'editgroup1' && !$INFO{'group'})) {
			$yymain .= qq~
	<tr>
		<td class="windowbg"><label for="additional">$amgtxt{'83'}</label></td>
		<td class="windowbg2">
			<input type="checkbox" name="additional" id="additional" value="1"$admg style="vertical-align: middle;" /> <br /><label for="additional">$amgtxt{'84'}</label>
		</td>
	</tr>~;
		}
	}
	unless ($INFO{'group'} eq "Administrator") {
		$yymain .= qq~
</table>
</div>

<br />

<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td align="left" class="titlebg" colspan="5">
			<img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$amgtxt{'44'}</b>
		</td>
	</tr>
	<tr valign="middle">
		<td align="center" class="catbg" width="20%"><label for="view"><span class="small">$amgtxt{'45'} $amgtxt{'46'}</span></label></td>
		<td align="center" class="catbg" width="20%"><label for="topics"><span class="small">$amgtxt{'45'} $amgtxt{'47'}</span></label></td>
		<td align="center" class="catbg" width="21%"><label for="reply"><span class="small">$amgtxt{'45'} $amgtxt{'48'}</span></label></td>
		<td align="center" class="catbg" width="19%"><label for="polls"><span class="small">$amgtxt{'45'} $amgtxt{'49'}</span></label></td>
		<td align="center" class="catbg" width="20%"><label for="attach"><span class="small">$amgtxt{'45'} $amgtxt{'50'}</span></label></td>
	</tr>
	<tr valign="middle">
		<td align="center" class="windowbg2" width="20%"><span class="small"><input type="checkbox" name="view" id="view" value="1"$vc /></span></td>
		<td align="center" class="windowbg2" width="20%"><span class="small"><input type="checkbox" name="topics" id="topics" value="1"$tc /></span></td>
		<td align="center" class="windowbg2" width="21%"><span class="small"><input type="checkbox" name="reply" id="reply" value="1"$rc /></span></td>
		<td align="center" class="windowbg2" width="19%"><span class="small"><input type="checkbox" name="polls" id="polls" value="1"$poc /></span></td>
		<td align="center" class="windowbg2" width="20%"><span class="small"><input type="checkbox" name="attach" id="attach" value="1"$ac /></span></td>
	</tr>~;
	}

	$yymain .= qq~
	<tr valign="middle">
		<td align="center" class="catbg" colspan="5">
			<input type="submit" value="$admin_txt{'10'}" class="button" />
		</td>
	</tr>
</table>
</div>
</form>

<script type="text/javascript">
<!--
function viscolor(v) {
	v = v.toUpperCase();
	v = v.replace(/[^A-F0-9]/g, '');
	if (v) document.getElementById('grpcolor').style.color = '#' + v;
	else   document.getElementById('grpcolor').style.color = '#000000';
	document.getElementById('color2').value = v;
	j = 0;
	for (i = 0; i < document.getElementById('color').length; i++) {
	    if (document.getElementById('color').options[i].value == v) {
			    document.getElementById('color').options[i].selected = true;
			    j = 1; break;
			}
	}
	if (j == 0) document.getElementById('color').options[0].selected = true;
}

function previewColor(color) {                                        
	color = color.replace(/#/, '');                              
	document.getElementById('color2').value = color;             
	viscolor(color);
}

function stars(value) {
	if (value == "other") document.getElementById('otherstar').disabled = false;
	else document.getElementById('otherstar').disabled = true;
}

function showimage() {
	selected = document.groups.starsadmin.options[document.groups.starsadmin.selectedIndex].value;
	otherurl = document.groups.otherstar.value;
	useimg = (selected != "other") ? "$imagesdir/"+selected : ((otherurl != "") ? otherurl : "$imagesdir/blank.gif");
	document.images.starpic.src=useimg;
	if (document.images.starpic.complete == false) {
		useimg = (selected != "other") ? "$defaultimagesdir/"+selected : ((otherurl != "") ? otherurl : "$defaultimagesdir/blank.gif");
		document.images.starpic.src=useimg;
	}
}

function depend(value) {
	if (value == "Yes") {
		document.getElementById('posts').disabled = false;
		if (document.getElementById('posts').value == '') document.getElementById('posts').value = 0;
		document.getElementById('viewpublic').checked = true;
		document.getElementById('viewpublic').disabled = true;
	} else{
		document.getElementById('posts').disabled = true;
		document.getElementById('viewpublic').disabled = false;
	}
}
//-->
</script>

~;
	$yytitle     = $admin_txt{'8'};
	$action_area = "modmemgr";

	&AdminTemplate;
}

sub editAddGroup2 {
	&is_admin_or_gmod;

	# Additional checks are:
	# If post independent -> post dependent, then need to kill off post independent
	# If post dependent -> post independent, then need to kill off post dependent.
	# If post dependent -> NEW post dependent, then need to kill off OLD post dependent.
	$newpostdep = 0;

	if (!$FORM{'title'}) { &fatal_error("no_group_name"); }
	$name = $FORM{'title'};

	$name =~ s~&amp;~&~g;
	$name =~ s~'~&#39;~g;
	$name =~ s~,~&#44;~g;
	$name =~ s~\|~&#124;~g;
	$lcname = lc($name);

	$star       = ($FORM{'starsadmin'} eq "other") ? $FORM{'otherstar'} : $FORM{'starsadmin'};
	$color      = $FORM{'color2'} ne '' ? "#$FORM{'color2'}" : '';
	$postdepend = $FORM{'postdepend'};
	if ($FORM{'posts'} !~ /\d+/ && $postdepend eq "Yes") { &fatal_error("no_post_number"); }
	else { $posts = $FORM{'posts'} }
	if ($postdepend eq "No") { $noposts = $FORM{'noposts'}; }

	if ($FORM{'viewpublic'}) { $viewpublic = 0 }
	else { $viewpublic = 1 }
	$view   = $FORM{'view'}   || 0;
	$topics = $FORM{'topics'} || 0;
	$reply  = $FORM{'reply'}  || 0;
	$polls  = $FORM{'polls'}  || 0;
	$attach = $FORM{'attach'} || 0;
	$additional = $FORM{'additional'} || 0;
	$original = $FORM{'original'};

	# all the checks.
	if ($original ne '') {
		($type, $element) = split(/\|/, $original);

		# Ignoring Administrative groups.
		if ($element ne "") {
			if ($type eq "P") {
				if ($element != $posts || $postdepend eq "No") {
					if ($iamgmod) { &fatal_error("newpostdep_gmod"); }

					delete $Post{$element};
					$newpostdep = 1;
					$noposts    = 1;
					foreach (sort { $a <=> $b } keys %NoPost) {
						$noposts = $_ + 1;
					}
				}
			} elsif ($type eq "NP") {
				if ($element != $noposts || $postdepend eq "Yes") {
					delete $NoPost{$element};
					for ($i = 0; $i < @nopostorder; $i++) {
						if ($nopostorder[$i] == $element) {
							splice(@nopostorder,$i,1);
							last;
						}
					}
				}
			}
		}
	}

	if ((split(/\|/, $Group{$original}, 2))[0] ne $name) {
		if ($lcname eq lc((split(/\|/, $Group{'Administrator'}, 2))[0])) { &fatal_error("double_group", $lcname); }
		if ($lcname eq lc((split(/\|/, $Group{'Global Moderator'}, 2))[0])) { &fatal_error("double_group", $lcname); }
		if ($lcname eq lc((split(/\|/, $Group{'Moderator'}, 2))[0])) { &fatal_error("double_group", $lcname); }
	}

	# Check Post Independent
	foreach my $key (keys %NoPost) {
		if ($type eq "NP" && $key eq $element) { next; }
		($value, undef) = split(/\|/, $NoPost{$key}, 2);
		$lcvalue = lc($value);
		if ($lcname eq $lcvalue) { &fatal_error("double_group", $lcname); }
	}

	# Check Post Dependent
	foreach my $key (keys %Post) {
		if ($type eq "P" && $key eq $element) { next; }
		($value, undef) = split(/\|/, $Post{$key}, 2);
		$lcvalue = lc($value);
		if ($lcname eq $lcvalue) { &fatal_error("double_group", $lcname); }
	}

	if ($FORM{'numstars'} !~ /\A[0-9]+\Z/) { $FORM{'numstars'} = 0; }
	# Now, we must deliberate on what type of thing this group is, and add/readd(when editing) it.
	# First, using original variable, we check to see it's not a perma-group.
	($type, $element) = split(/\|/, $original);
	if ($element eq "" && $original ne "") {
		# We have a perma-group! $type is now equal to the perma group or key for the hash.
		# add in code to actually set the line.
		$Group{"$type"} = "$name|$FORM{'numstars'}|$star|$color|$viewpublic|$view|$topics|$reply|$polls|$attach|$additional";
	} else {
		# post dependent group.
		if ($postdepend eq "Yes") {
			foreach my $key (keys %Post) {
				if ($posts == $key && ($FORM{'origin'} eq "editgroup1" || $original ne "P|$posts")) {
					&fatal_error("double_count","($posts)");
				}
			}

			if ($iamgmod) { &fatal_error("newpostdep_gmod"); }

			$Post{$posts} = "$name|$FORM{'numstars'}|$star|$color|0|$view|$topics|$reply|$polls|$attach|$additional";
			$newpostdep = 1;

		# no post group
		} else {
			$NoPost{$noposts} = "$name|$FORM{'numstars'}|$star|$color|$viewpublic|$view|$topics|$reply|$polls|$attach|$additional";
			my $isinorder;
			for ($i = 0; $i < @nopostorder; $i++) {
				if ($NoPost{$nopostorder[$i]} && $nopostorder[$i] == $noposts) {
					$isinorder = 1; last;
				}
			}
			if (!$isinorder) { push(@nopostorder, $noposts); }
		}
	}

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl'); # save @nopostorder, %Group, %NoPost and %Post

	if ($newpostdep) { 
		$yySetLocation = qq~$adminurl?action=rebuildmemlist;actiononfinish=modmemgr~;
	} else {
		$yySetLocation = qq~$adminurl?action=modmemgr~;
	}
	&redirectexit;
}

sub permImage {
	my $viewperms, $topicperms, $replyperms, $pollperms, $attachperms;

	$viewperms   = ($_[0] != 1) ? "<img src=\"$imagesdir/open.gif\" />"        : "";
	$topicperms  = ($_[1] != 1) ? "<img src=\"$imagesdir/new_thread.gif\" />"  : "";
	$replyperms  = ($_[2] != 1) ? "<img src=\"$imagesdir/reply.gif\" />"       : "";
	$pollperms   = ($_[3] != 1) ? "<img src=\"$imagesdir/poll_create.gif\" />" : "";
	$attachperms = ($_[4] != 1) ? "<img src=\"$imagesdir/paperclip.gif\" />"   : "";

	return "$viewperms $topicperms $replyperms $pollperms $attachperms";
}

sub deleteGroup {
	if ($INFO{'group'}) {
		($type, $element) = split(/\|/, $INFO{'group'});
		if ($element ne "") {
			if ($type eq "P") {
				delete $Post{$element};
			} elsif ($type eq "NP") {
				delete $NoPost{$element};
				&KillModeratorGroup($element);
			}
		}
	} else {
		&fatal_error("no_info");
	}

	my @new_nopostorder;
	foreach (@nopostorder) {
		if ($NoPost{$_}) { push(@new_nopostorder, $_); }
	}
	@nopostorder = @new_nopostorder;

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl'); # save @nopostorder, %Group, %NoPost and %Post

	$yySetLocation = qq~$adminurl?action=rebuildmemlist;actiononfinish=modmemgr~;
	&redirectexit;
}

sub reorderGroups {
	$selsize = 0;
	foreach (@nopostorder) {
		if ($NoPost{$_}) {
			($title, undef) = split(/\|/, $NoPost{$_}, 2);
			if ($_ eq $INFO{"thegroup"}) {
				$orderopt .= qq~<option value="$_" selected="selected">$title</option>~;
			} else {
				$orderopt .= qq~<option value="$_">$title</option>~;
			}
			$selsize++;
		}
	}

	$rowspan = $#nopostorder + 2;
	$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 75%; margin-left: auto; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td align="left" class="titlebg" colspan="3">
			<img src="$imagesdir/guest.gif" alt="" border="0" />&nbsp;<b>$admintxt{'reordergroups2'}</b>
		</td>
	</tr>
	<tr valign="middle">
		<td align="center" class="catbg" width="33%"><b>$amgtxt{'03'}</b></td>
		<td align="center" class="catbg" width="33%"><b>$amgtxt{'19'}</b></td>
		<td align="center" class="windowbg" width="34%" rowspan="$rowspan">
			<form action="$adminurl?action=reordergroup2" method="post" name="groupsorder" style="display: inline; white-space: nowrap;">
			<select name="ordergroups" class="small" size="$selsize" style="width: 130px;">
				$orderopt
			</select><br />
			<input type="submit" value="$admin_txt{'739a'}" name="moveup" style="font-size: 11px; width: 65px;" class="button" /><input type="submit" value="$admin_txt{'739b'}" name="movedown" style="font-size: 11px; width: 65px;" class="button" />
			</form>
		</td>
	</tr>~;

	foreach (@nopostorder) {
		($title, $stars, $starpic, $color, undef) = split(/\|/, $NoPost{$_}, 5);
		if (!$stars) { $stars = "0"; }
		$yymain .= qq~
	<tr>
		<td align="left" class="windowbg2">~;

		if ($color) { $yymain .= qq~<span style="color:$color"><b>$title</b></span>~; }
		else { $yymain .= qq~<b>$title</b>~; }
		$yymain .= qq~
		</td>
		<td align="center" class="windowbg2">~;

		for (1..$stars) { $yymain .= qq~<img src="$imagesdir/$starpic" />~; }

		$yymain .= qq~
		</td>
	</tr>~;
	}

	$yymain .= qq~

</table>
</div>~;

	$yytitle = $admintxt{'reordergroups'};
	$action_area = 'modmemgr';

	&AdminTemplate;
}

sub reorderGroups2 {
	my $moveitem = $FORM{'ordergroups'};

	if ($moveitem) {
		for ($i = 0; $i < @nopostorder; $i++) {
			if ($nopostorder[$i] == $moveitem &&
			    (($FORM{'moveup'}   && $i > 0             && $i <= $#nopostorder) ||
			     ($FORM{'movedown'} && $i < $#nopostorder && $i >= 0))) {
				my $j = $FORM{'moveup'} ? $i - 1 : $i + 1;
				$nopostorder[$i] = $nopostorder[$j];
				$nopostorder[$j] = $moveitem;
				last;
			}
		}
	}

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl'); # save @nopostorder

	$yySetLocation = qq~$adminurl?action=reordergroup;thegroup=$moveitem~;
	&redirectexit;
}

1;