###############################################################################
# ModList.pl                                                                  #
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

$modlistplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub ListMods {
	my @installed_mods = ();

	# You need to list your mod in this file for full compliance.
	# Add it in the following way:
	# 	$my_mod = "Name of Mod|Author|Description|Version|Date Released";
	#	push (@installed_mods, "$my_mod");
	# It is reccomended that you do a "add before" on the end boardmod tag
	# This preserves the installation order.

	# Also note, you should pick a unique name instead of "$my_mod".
	# If you mod is called "SuperMod For Doing Cool Things"
	# You could use "$SuperMod_CoolThings"

### BOARDMOD ANCHOR ###

### END BOARDMOD ANCHOR ###

	if (!@installed_mods) {

		$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="3">
		 <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$mod_list{'5'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
		  <br />
		    $mod_list{'8'} <a href="http://www.boardmod.org">$mod_list{'9'}</a>
		  <br /><br />
	   </td>
     </tr>
   </table>
 </div>
~;

		$yytitle     = $mod_list{'6'};
		$action_area = "modlist";

		&AdminTemplate;
	}

	foreach $modification (@installed_mods) {
		chomp($modification);
		($mod_anchor, $mod_author, $mod_desc, $mod_version, $mod_date) = split(/\|/, $modification);

		$mod_displayname = $mod_anchor;
		$mod_displayname =~ s/\_/ /g;
		$mod_anchor      =~ s/ /\_/g;
		$mod_anchor      =~ s/[^\w]//g;

		$mod_text_list .= qq~

     <tr valign="middle">
       <td align="left" class="windowbg2">
		  <a href="#$mod_anchor">$mod_displayname</a>
	   </td>
       <td align="left" class="windowbg2">
		  $mod_author
	   </td>
       <td align="left" class="windowbg2">
		  $mod_version
	   </td>
     </tr>

		~;

		$full_description .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		 <a name="$mod_anchor"><img src="$imagesdir/preferences.gif" alt="" border="0" /></a><b>$mod_displayname</b> &nbsp; <span class="small">$mod_list{'4'}: $mod_version</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg">
		 <span class="small">$mod_list{'2'}: $mod_author</span>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		  $mod_desc<br /><br />
	   </td>
     </tr>
       <td align="right" class="catbg">
		 <span class="small">$mod_list{'3'}: $mod_date</span>
	   </td>
     </tr>

   </table>
 </div>
<br />
		~;

	}

	$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="3">
		 <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$mod_list{'5'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg">
		 <span class="small">$mod_list{'1'}</span>
	   </td>
       <td align="left" class="catbg">
		 <span class="small">$mod_list{'2'}</span>
	   </td>
       <td align="left" class="catbg">
		 <span class="small">$mod_list{'4'}</span>
	   </td>
     </tr>

$mod_text_list 
     </tr>

   </table>
 </div>

<br /><br /><br />

$full_description

~;

	$yytitle     = $mod_list{'6'};
	$action_area = "modlist";

	&AdminTemplate;
}

1;
