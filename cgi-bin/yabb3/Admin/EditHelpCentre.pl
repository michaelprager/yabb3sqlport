###############################################################################
# EditHelpCentre.pl                                                           #
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

$edithelpcentreplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('HelpCentre');

$yytitle = $helptxt{'1'};

sub HelpEdit {
	$page      = $FORM{'page'};
	$help_area = $INFO{'area'};

	if ($page eq "user00_agreement") {
		$yySetLocation = qq~$adminurl?action=modagreement;agreementlanguage=$language;destination=helpadmin~;
		&redirectexit;
	}

	require "$helpfile/$language/$help_area/$page.help";

	$SectionName =~ s/_/ /g;
	$admin_list = qq~
     <tr>
       <td align="left" class="titlebg" valign="middle" width="100%">
		<input type="text" maxlength="50" width="50" value="$SectionName" name="SectionName" />
	   </td>
     </tr>
~;

	$a = 1;
	while (${ SectionSub . $a }) {
		${ SectionSub . $a } =~ s/_/ /g;
		my $hmessage;
		$hmessage = ${ SectionBody . $a };

		$admin_list .= qq~
     <tr>
       <td align="left" class="catbg" valign="middle" width="100%">
		<input type="text" maxlength="50" width="50" value="${SectionSub.$a}" name="SectionSub$a" />
	   </td>
     </tr>
     <tr>
       <td align="left" class="windowbg2" valign="middle" width="100%">
		<textarea rows="10" name="SectionBody$a" style="width: 100%">$hmessage</textarea><br /><br />
	   </td>
     </tr>
~;
		$a++;
	}

	$yymain .= qq~
<form name="help_update" action="$adminurl?action=helpediting2" method="post">
<input type="hidden" name="area" value="$help_area" />
<input type="hidden" name="page" value="$page" />
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-bottom: 10px; margin-left: auto; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr>
       <td align="left" valign="middle" class="titlebg">
<img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$helptxt{'7'}</b>
	   </td>
     </tr>
    </table>
 </div>
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: auto; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
$admin_list
     <tr>
       <td align="center" valign="middle" class="catbg">
    	<input type="submit" value="$admin_txt{'10'}" class="button" /></td>
	 </td>
     </tr>
   </table>
 </div>
</form>
~;

	$yytitle     = "$helptxt{'7'}";
	$action_area = "helpadmin";
	&AdminTemplate;
}

sub HelpEdit2 {
	$Area = $FORM{'area'};
	$Page = $FORM{'page'};

	$FORM{"SectionName"} =~ s/ /_/g;
	$a = 1;

	&read_DBorFILE(0,HELPORDER,"$helpfile/$language/$Area",$Page,'help');
	print HELPORDER qq~\$SectionName = "$FORM{"SectionName"}";\n\n~;
	while ($FORM{"SectionBody$a"}) {

		$FORM{"SectionBody$a"} =~ tr/\r//d;
		$FORM{"SectionBody$a"} =~ s/\cM//g;
		$FORM{"SectionBody$a"} =~ s~\[([^\]]{0,30})\n([^\]]{0,30})\]~\[$1$2\]~g;
		$FORM{"SectionBody$a"} =~ s~\[/([^\]]{0,30})\n([^\]]{0,30})\]~\[/$1$2\]~g;
		$FORM{"SectionBody$a"} =~ s~(\w+://[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)~$1\n$2~g;
		$FORM{"SectionBody$a"} =~ s~\t~ \&nbsp; \&nbsp; \&nbsp;~g;
		$FORM{"SectionBody$a"} =~ s~@~\\@~g;

		$FORM{"SectionSub$a"} =~ s/ /_/g;

		print HELPORDER qq~### Section $a\n~;
		print HELPORDER qq~#############################################\n~;
		print HELPORDER qq~\$SectionSub$a = "$FORM{"SectionSub$a"}";\n~;
		print HELPORDER qq~\$SectionBody$a = qq\~$FORM{"SectionBody$a"}\~;\n~;
		print HELPORDER qq~#############################################\n\n\n~;

		$a++;
	}
	&write_DBorFILE(0,HELPORDER,"$helpfile/$language/$Area",$Page,'help',('1;'));

	$yymain .= "$helptxt{'8'}";
	$yytitle       = "$helptxt{'7'}";
	$yySetLocation = qq~$adminurl?action=helpadmin~;
	&redirectexit;
}

sub HelpSet2 {
	$UseHelp_Perms = $FORM{"UseHelp_Perms"} ? 1 : 0;

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');

	$yymain .= "$helptxt{'8'}";
	$yytitle = "$helptxt{'7'}";
	$yySetLocation = qq~$adminurl?action=helpadmin~;
	&redirectexit;

}

sub MainAdmin {
	my ($admin_list, $adminlist, $gmod_list, $gmodlist, $moderator_list, $moderatorlist, $user_list, $userlist);

	$admincount = 0;
	opendir(HELPDIR, "$helpfile/$language/Admin");
	@contents = readdir(HELPDIR);
	closedir(HELPDIR);
	foreach $line (sort { uc($a) cmp uc($b) } @contents) {
		($name, $extension) = split(/\./, $line);
		if ($extension !~ /help/i) { next; }
		$select = "";
		if ($admincount == 0) { $select = qq~ selected="selected"~; }
		$admin_list .= qq~<option value="$name"$select>$name</option>~;
		$admin_lst  .= qq~$name\n~;
		$admincount++;
	}
	if (!-e ("$vardir/Admin.helporder")) {
		&write_DBorFILE(0,'',$vardir,'Admin','helporder',($admin_lst));
	}
	@adminorderlist = &read_DBorFILE(0,'',$vardir,'Admin','helporder');
	foreach $line (@adminorderlist) {
		chomp $line;
		$adminlist .= "$line\n";
	}

	$gmodcount = 0;
	opendir(HELPDIR, "$helpfile/$language/Gmod");
	@contents = readdir(HELPDIR);
	closedir(HELPDIR);
	foreach $line (sort { uc($a) cmp uc($b) } @contents) {
		($name, $extension) = split(/\./, $line);
		if ($extension !~ /help/i) { next; }
		$select = "";
		if ($gmodcount == 0) { $select = qq~ selected="selected"~; }
		$gmod_list .= qq~<option value="$name"$select>$name</option>~;
		$gmod_lst  .= qq~$name\n~;
		$gmodcount++;
	}
	if (!-e ("$vardir/Gmod.helporder")) {
		&write_DBorFILE(0,'',$vardir,'Gmod','helporder',($gmod_lst));
	}
	@gmodorderlist = &read_DBorFILE(0,'',$vardir,'Gmod','helporder');
	foreach $line (@gmodorderlist) {
		chomp $line;
		$gmodlist .= "$line\n";
	}

	$modcount = 0;
	opendir(HELPDIR, "$helpfile/$language/Moderator");
	@contents = readdir(HELPDIR);
	closedir(HELPDIR);
	foreach $line (sort { uc($a) cmp uc($b) } @contents) {
		($name, $extension) = split(/\./, $line);
		if ($extension !~ /help/i) { next; }
		$select = "";
		if ($modcount == 0) { $select = qq~ selected="selected"~; }
		$moderator_list .= qq~<option value="$name"$select>$name</option>~;
		$moderator_lst  .= qq~$name\n~;
		$modcount++;
	}
	if (!-e ("$vardir/Moderator.helporder")) {
		&write_DBorFILE(0,'',$vardir,'Moderator','helporder',($moderator_lst));
	}
	@modorderlist = &read_DBorFILE(0,'',$vardir,'Moderator','helporder');
	foreach $line (@modorderlist) {
		chomp $line;
		$moderatorlist .= "$line\n";
	}

	$usercount = 0;
	opendir(HELPDIR, "$helpfile/$language/User");
	@contents = readdir(HELPDIR);
	closedir(HELPDIR);
	foreach $line (sort { uc($a) cmp uc($b) } @contents) {
		($name, $extension) = split(/\./, $line);
		if ($extension !~ /help/i) { next; }
		$select = "";
		if ($usercount == 0) { $select = qq~ selected="selected"~; }
		$user_list .= qq~<option value="$name"$select>$name</option>~;
		$user_lst  .= qq~$name\n~;
		$usercount++;
	}
	if (!-e ("$vardir/User.helporder")) {
		&write_DBorFILE(0,'',$vardir,'User','helporder',($user_lst));
	}
	@userorderlist = &read_DBorFILE(0,'',$vardir,'User','helporder');
	foreach $line (@userorderlist) {
		chomp $line;
		$userlist .= qq~$line\n~;
	}

	if ($admincount < 4) { $admincount = 4; }
	if ($gmodcount < 4)  { $gmodcount  = 4; }
	if ($modcount < 4)   { $modcount   = 4; }
	if ($usercount < 4)  { $usercount  = 4; }

	my $perms_check = '';
	if ($UseHelp_Perms == 1) {
		$perms_check = qq~ checked='checked'~;
	}
	$yymain .= qq~
<form action="$adminurl?action=helpsettings2" method="post" style="display: inline">
   <table class="bordercolor" align="center" width="440" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$helptxt{'7'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
		<label for="UseHelp_Perms">$helptxt{'9'}</label> <input type="checkbox" name="UseHelp_Perms" id="UseHelp_Perms" value="1"$perms_check />
	   </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg">
    	<input type="submit" value="$admin_txt{'10'}" class="button" />
	   </td>
     </tr>
   </table>
</form>
<br /><br />

<script language="JavaScript1.2" type="text/javascript">
<!--
var nline = '\\n';
myRe=/\\n\$/;
myRg=/\\n\\s*?\\n/;
function addadminhelp() {
	thisstr = document.adminorder.order.value;
	if( ! myRe.test(thisstr) && document.adminorder.order.value != '' ) document.adminorder.order.value = document.adminorder.order.value + nline;
	if( myRg.test(thisstr) ) document.adminorder.order.value = document.adminorder.order.value.replace(/\\n\\s*?\\n/, "\\n" + document.adminhelp.page.options[document.adminhelp.page.selectedIndex].value + "\\n");
	else document.adminorder.order.value += document.adminhelp.page.options[document.adminhelp.page.selectedIndex].value + nline;
}
function addgmodhelp() {
	thisstr = document.gmodorder.order.value;
	if( ! myRe.test(thisstr) && document.gmodorder.order.value != '' ) document.gmodorder.order.value = document.gmodorder.order.value + nline;
	if( myRg.test(thisstr) ) document.gmodorder.order.value = document.gmodorder.order.value.replace(/\\n\\s*?\\n/, "\\n" + document.gmodhelp.page.options[document.gmodhelp.page.selectedIndex].value + "\\n");
	else document.gmodorder.order.value += document.gmodhelp.page.options[document.gmodhelp.page.selectedIndex].value + nline;
}
function addmodhelp() {
	thisstr = document.modorder.order.value;
	if( ! myRe.test(thisstr) && document.modorder.order.value != '' ) document.modorder.order.value = document.modorder.order.value + nline;
	if( myRg.test(thisstr) ) document.modorder.order.value = document.modorder.order.value.replace(/\\n\\s*?\\n/, "\\n" + document.modhelp.page.options[document.modhelp.page.selectedIndex].value + "\\n");
	else document.modorder.order.value += document.modhelp.page.options[document.modhelp.page.selectedIndex].value + nline;
}
function adduserhelp() {
	thisstr = document.userorder.order.value;
	if( ! myRe.test(thisstr) && document.userorder.order.value != '' ) document.userorder.order.value = document.userorder.order.value + nline;
	if( myRg.test(thisstr) ) document.userorder.order.value = document.userorder.order.value.replace(/\\n\\s*?\\n/, "\\n" + document.userhelp.page.options[document.userhelp.page.selectedIndex].value + "\\n");
	else document.userorder.order.value += document.userhelp.page.options[document.userhelp.page.selectedIndex].value + nline;
}
//-->
</script>

   <table class="bordercolor" align="center" width="440" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
<img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$helptxt{'7'}</b>
	   </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		<span class="small">$helptxt{'10'}</span><br /><br />
       </td>
     </tr>
     <tr>
       <td align="left" class="catbg">
		<i>$helptxt{'6'}</i>
	   </td>
     </tr>
	<tr>
		<td width="100%" align="center" class="windowbg2" valign="middle">
		<span style="float: left; text-align: center; width: 200px;">
		<form name="adminhelp" action="$adminurl?action=helpediting;area=Admin" method="post" style="display: inline">
		<select name="page" size="$admincount" style="width: 180px; font-size: 10px; margin: 2px;">
		$admin_list
		</select>
		<br />
	    	<input type="submit" value="$admin_txt{'53'}" class="button" />
		</form>
		</span>
		<span style="float: left; text-align: center; vertical-align: middle; width: 30px;">
		<br /><br />
		<input type="button" value="\-\>" onclick="addadminhelp()" />
		</span>
		<span style="float: right; text-align: center; width: 200px;">
		<form name="adminorder" action="$adminurl?action=helporder;area=Admin" method="post" style="display: inline">
		<textarea name="order" cols="29" rows="$admincount" style="width: 180px; font-size: 10px; margin: 2px">$adminlist</textarea>
		<input type="hidden" value="$admin_lst" name="testlst" />
		<br />
	    	<input type="submit" value="$admin_txt{'10'}" class="button" />
		</form>
		</span>
		</td>
	</tr>
     <tr>
       <td align="left" class="catbg">
		<i>$helptxt{'5'}</i>
	   </td>
     </tr>
	<tr>
		<td width="100%" align="center" class="windowbg2" valign="middle">
		<span style="float: left; text-align: center; width: 200px;">
		<form name="gmodhelp" action="$adminurl?action=helpediting;area=Gmod" method="post" style="display: inline">
		<select name="page" size="$gmodcount" style="width: 180px; font-size: 10px; margin: 2px;">
		$gmod_list
		</select>
		<br />
	    	<input type="submit" value="$admin_txt{'53'}" class="button" />
		</form>
		</span>
		<span style="float: left; text-align: center; vertical-align: middle; width: 30px;">
		<br /><br />
		<input type="button" value="\-\>" onclick="addgmodhelp()" />
		</span>
		<span style="float: right; text-align: center; width: 200px;">
		<form name="gmodorder" action="$adminurl?action=helporder;area=Gmod" method="post" style="display: inline">
		<textarea name="order" cols="29" rows="$gmodcount" style="width: 180px; font-size: 10px; margin: 2px">$gmodlist</textarea>
		<input type="hidden" value="$gmod_lst" name="testlst" />
		<br />
	    	<input type="submit" value="$admin_txt{'10'}" class="button" />
		</form>
		</span>
		</td>
	</tr>
     <tr>
       <td align="left" class="catbg">
		<i>$helptxt{'4'}</i>
	   </td>
     </tr>
	<tr>
		<td width="100%" align="center" class="windowbg2" valign="middle">
		<span style="float: left; text-align: center; width: 200px;">
		<form name="modhelp" action="$adminurl?action=helpediting;area=Moderator" method="post" style="display: inline">
		<select name="page" size="$modcount" style="width: 180px; font-size: 10px; margin: 2px;">
		$moderator_list
		</select>
		<br />
	    	<input type="submit" value="$admin_txt{'53'}" class="button" />
		</form>
		</span>
		<span style="float: left; text-align: center; vertical-align: middle; width: 30px;">
		<br /><br />
		<input type="button" value="\-\>" onclick="addmodhelp()" />
		</span>
		<span style="float: right; text-align: center; width: 200px;">
		<form name="modorder" action="$adminurl?action=helporder;area=Moderator" method="post" style="display: inline">
		<textarea name="order" cols="29" rows="$modcount" style="width: 180px; font-size: 10px; margin: 2px">$moderatorlist</textarea>
		<input type="hidden" value="$moderator_lst" name="testlst" />
		<br />
	    	<input type="submit" value="$admin_txt{'10'}" class="button" />
		</form>
		</span>
		</td>
	</tr>

     <tr>
       <td align="left" class="catbg">
		<i>$helptxt{'3'}</i>
	   </td>
     </tr>
	<tr>
		<td width="100%" align="center" class="windowbg2" valign="middle">
		<span style="float: left; text-align: center; width: 200px;">
		<form name="userhelp" action="$adminurl?action=helpediting;area=User" method="post" style="display: inline">
		<select name="page" size="$usercount" style="width: 180px; font-size: 10px; margin: 2px;">
		$user_list
		</select>
		<br />
	    	<input type="submit" value="$admin_txt{'53'}" class="button" />
		</form>
		</span>
		<span style="float: left; text-align: center; vertical-align: middle; width: 30px;">
		<br /><br />
		<input type="button" value="\-\>" onclick="adduserhelp()" />
		</span>
		<span style="float: right; text-align: center; width: 200px;">
		<form name="userorder" action="$adminurl?action=helporder;area=User" method="post" style="display: inline">
		<textarea name="order" cols="29" rows="$usercount" style="width: 180px; font-size: 10px; margin: 2px">$userlist</textarea>
		<input type="hidden" value="$user_lst" name="testlst" />
		<br />
	    	<input type="submit" value="$admin_txt{'10'}" class="button" />
		</form>
		</span>
		</td>
	</tr>

   </table>
~;

	$yytitle     = "$helptxt{'7'}";
	$action_area = "helpadmin";
	&AdminTemplate;
}

sub SetOrderFile {
	my $help_area   = $INFO{'area'};
	my %verify_hash = ();
	$FORM{'order'}   =~ s/\r//g;
	$FORM{'testlst'} =~ s/\r//g;
	$oldorder = $FORM{'testlst'};
	$neworder = $FORM{'order'};
	@oldorder = split(/\n/, $oldorder);
	@neworder = split(/\n/, $neworder);
	foreach (@oldorder) {
		$_ =~ s/[\n\r]//g;
		$verify_hash{"$_"}++;
	}
	$theorder = "";
	foreach $order (@neworder) {
		$order =~ s/[\n\r]//g;
		if ($order eq "") { next; }
		if (!(exists($verify_hash{$order}))) { next; }
		$theorder .= "$order\n";
	}
	&write_DBorFILE(0,'',$vardir,$help_area,'helporder',($theorder));
	$yytitle       = "$helptxt{'7'}";
	$yySetLocation = qq~$adminurl?action=helpadmin~;
	&redirectexit;
}

1;
