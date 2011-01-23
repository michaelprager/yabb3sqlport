###############################################################################
# AdminEdit.pl                                                                #
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

$admineditplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('Register');

sub GmodSettings {
	&is_admin;

	&LoadLanguage('GModPrivileges');

	if (!-e ("$vardir/gmodsettings.txt")) { &GmodSettings2; }

	require "$vardir/gmodsettings.txt";

	if ($gmod_newfile eq '') { &GmodSettings2; }

	@scriptlines = &read_DBorFILE(0,'',$vardir,'gmodsettings','txt');

	$startread = 0;
	$counter   = 0;
	foreach $scriptline (@scriptlines) {
		chomp $scriptline;
		if (substr($scriptline, 0, 1) eq "'") {
			$scriptline =~ s/newsettings\;page\=//;
			$scriptline =~ /\"(.*?)\"/;
			$allow = $1;
			$scriptline =~ /\'(.*?)\'/;
			$actionfound = $1;
			push(@actfound, $actionfound);
			push(@allowed,  $allow);
			$counter++;
		}
	}
	$column  = int($counter / 2);
	$counter = 0;
	$a       = 0;
	foreach $actfound (@actfound) {
		$checked = '';
		if ($allowed[$a] eq 'on') { $checked = ' checked="checked"'; }
		$dismenu .= qq~\n<input type="checkbox" name="$actfound" id="$actfound"$checked />&nbsp;<label for="$actfound"><img src="$imagesdir/question.gif" align="middle" alt="$reftxt{'1a'} $gmodprivexpl_txt{$actfound}" title="$reftxt{'1a'} $gmodprivexpl_txt{$actfound}" border="0" /> $actfound</label><br />~;
		$counter++;
		$a++;
		if ($counter > $column + 1) {
			$dismenu .= qq~</td><td align="left" class="windowbg2" valign="top" width="50%">~;
			$counter = 0;
		}
	}

	if ($allow_gmod_admin) { $gmod_selected_a = ' checked="checked"'; }
	if ($allow_gmod_profile) { 
		$gmod_selected_p = ' checked="checked"';
		if ($allow_gmod_aprofile) { $gmod_selected_ap = ' checked="checked"'; }
	} else {
		$gmod_selected_ap = ' disabled="disabled"';
	}

	$yymain .= qq~
<form action="$adminurl?action=gmodsettings2" method="post" enctype="application/x-www-form-urlencoded">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="2"><img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$gmod_settings{'1'}</b></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2" colspan="2"><br />
<input type="checkbox" id="allow_gmod_admin" name="allow_gmod_admin"$gmod_selected_a /> <label for="allow_gmod_admin">$gmod_settings{'2'}</label><br />
<input type="checkbox" id="allow_gmod_profile" name="allow_gmod_profile"$gmod_selected_p onclick="depend(this.checked);" /> <label for="allow_gmod_profile">$gmod_settings{'3'}</label><br />
<input type="checkbox" id="allow_gmod_aprofile" name="allow_gmod_aprofile"$gmod_selected_ap /> <label for="allow_gmod_aprofile">$gmod_settings{'3a'}</label><br />
<br />
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg" colspan="2"><span class="small">$gmod_settings{'4'}</span></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2" valign="top" width="50%">$dismenu</td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg" colspan="2"><input type="submit" value="$reftxt{'4'}" class="button" /></td>
     </tr>
   </table>
 </div>
</form>

<script type="text/javascript">
<!--
function depend(value) {
      if (value) {
		document.getElementById('allow_gmod_aprofile').disabled = false;
      } else {
      	document.getElementById('allow_gmod_aprofile').checked = false;
		document.getElementById('allow_gmod_aprofile').disabled = true;
      }
}
//-->
</script>

~;
	$yytitle     = "$gmod_settings{'1'}";
	$action_area = "gmodaccess";
	&AdminTemplate;
}

sub EditBots {
	&is_admin_or_gmod;
	my ($line);
	$yymain .= qq~
<form action="$adminurl?action=editbots2" method="post" enctype="application/x-www-form-urlencoded">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg"><img src="$imagesdir/xx.gif" alt="" border="0" /><b>$admin_txt{'18'}</b></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
	<span class="small">
	$admin_txt{'19'}
	</span><br /><br />
       </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="windowbg2"><br />
	<textarea cols="70" rows="35" name="bots" style="width:98%">~;
	foreach (&read_DBorFILE(0,'',$vardir,'bots','hosts')) { $yymain .= $_; }
	$yymain .= qq~</textarea>
	<br /><br />
       </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg"><input type="submit" value="$admin_txt{'10'}" class="button" /></td>
     </tr>
   </table>
 </div>
</form>
~;
	$yytitle     = "$admin_txt{'18'}";
	$action_area = "editbots";
	&AdminTemplate;
}

sub EditBots2 {
	&is_admin_or_gmod;

	&write_DBorFILE(0,'',$vardir,'bots','hosts',(map { "$_\n"; } sort { (split(/\|/, $a))[1] cmp (split(/\|/, $b))[1] } split(/[\n\r]+/, $FORM{'bots'})));

	$yySetLocation = qq~$adminurl?action=editbots~;
	&redirectexit;
}

sub SetCensor {
	&is_admin_or_gmod;
	my ($censorlanguage, $line);
	if ($FORM{'censorlanguage'}) { $censorlanguage = $FORM{'censorlanguage'} }
	else { $censorlanguage = $lang; }
	opendir(LNGDIR, $langdir);
	my @lfilesanddirs = readdir(LNGDIR);
	close(LNGDIR);

	foreach my $fld (sort {lc($a) cmp lc($b)} @lfilesanddirs) {
		if (-d "$langdir/$fld" && $fld =~ m^\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@/]+\Z^ && -e "$langdir/$fld/Main.lng") {
			my $displang = $fld;
			$displang =~ s~(.+?)\_(.+?)$~$1 ($2)~gi;
			if ($censorlanguage eq $fld) { $drawnldirs .= qq~<option value="$fld" selected="selected">$displang</option>~; }
			else { $drawnldirs .= qq~<option value="$fld">$displang</option>~; }
		}
	}

	my $dispcenlang = $censorlanguage;
	$dispcenlang =~ s~(.+?)\_(.+?)$~$1 ($2)~gi;
	$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		 <img src="$imagesdir/ban.gif" alt="" border="0" /><span class="legend"><b>$admin_txt{'135'}</b></span>
       </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="windowbg2">
	<form action="$adminurl?action=setcensor" method="post" enctype="application/x-www-form-urlencoded">
	$templs{'7'}
	<select name="censorlanguage" id="censorlanguage" size="1">
		$drawnldirs
	</select>
	<input type="submit" value="$admin_txt{'462'}" class="button" />
	</form>
       </td>
     </tr>
   </table>
 </div>
 <br />
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <!-- Split for XHTML Validation purposes -->
   <form action="$adminurl?action=setcensor2" method="post" enctype="application/x-www-form-urlencoded">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
         <label for="censored">$admin_txt{'136'}</label><br /><br />
       </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="windowbg2"><br />
	<input type="hidden" name="censorlanguage" value="$censorlanguage" />
	<textarea rows="35" cols="15" name="censored" id="censored" style="width:90%">~;
	foreach (&read_DBorFILE(0,'',"$langdir/$censorlanguage",'censor','txt')) {
		$yymain .= $_;
	}
	$yymain .= qq~</textarea>
        <br /><br />
      </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg">
<input type="submit" value="$admin_txt{'10'} $dispcenlang" class="button" />
       </td>
     </tr>
   </table>
   </form>
 </div>
~;
	$yytitle     = "$admin_txt{'135'}";
	$action_area = "setcensor";
	&AdminTemplate;
}

sub SetCensor2 { # don't use &FromChars() here!!!
	&is_admin_or_gmod;
	$FORM{'censored'} =~ tr/\r//d;
	$FORM{'censored'} =~ s~\A[\s\n]+~~;
	$FORM{'censored'} =~ s~[\s\n]+\Z~~;
	$FORM{'censored'} =~ s~\n\s*\n~\n~g;
	if ($FORM{'censorlanguage'}) { $censorlanguage = $FORM{'censorlanguage'}; }
	else { $censorlanguage = $lang; }
	my @lines = split(/\n+/, $FORM{'censored'});

	&write_DBorFILE(0,'',"$langdir/$censorlanguage",'censor','txt',(map { "$_\n" } grep { /.+[=~].+/ } @lines));

	$yySetLocation = qq~$adminurl?action=setcensor~;
	$action_area = "setcensor";
	&redirectexit;
}

sub SetReserve {
	my (@reserved, @reservecfg, $i);
	&is_admin_or_gmod;
	@reserved = &read_DBorFILE(0,'',$vardir,'reserve','txt');
	@reservecfg = &read_DBorFILE(0,'',$vardir,'reservecfg','txt');
	for (my $i = 0; $i < @reservecfg; $i++) {
		chomp $reservecfg[$i];
		if($reservecfg[$i]) { $reservecheck[$i] = qq~ checked="checked"~; }
	}
	$yymain .= qq~
<form action="$adminurl?action=setreserve2" method="post" enctype="application/x-www-form-urlencoded">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg"><img src="$imagesdir/profile.gif" alt="" border="0" /><b>$admin_txt{'341'}</b></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		 $admin_txt{'699'}<br /><br />
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		$admin_txt{'342'}<br /><br />
			<center><textarea cols="40" rows="35" name="reserved" style="width:95%">~;
	foreach $i (@reserved) {
		chomp $i;
		$i =~ s~\t~~g;
		if ($i !~ m~\A[\S|\s]*[\n\r]*\Z~) { next; }
		$yymain .= "$i\n";
	}
	$yymain .= qq~</textarea>
	</center>
<br /><br />
	<input type="checkbox" name="matchword" id="matchword" value="checked"$reservecheck[0] />
	<label for="matchword">$admin_txt{'726'}</label><br />
	<input type="checkbox" name="matchcase" id="matchcase" value="checked"$reservecheck[1] />
	<label for="matchcase">$admin_txt{'727'}</label><br />
	<input type="checkbox" name="matchuser" id="matchuser" value="checked"$reservecheck[2] />
	<label for="matchuser">$admin_txt{'728'}</label><br />
	<input type="checkbox" name="matchname" id="matchname" value="checked"$reservecheck[3] />
	<label for="matchname">$admin_txt{'729'}</label><br />
       </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg"><input type="submit" value="$admin_txt{'10'}" class="button" /></td>
     </tr>
   </table>
 </div>
</form>
~;
	$yytitle     = "$admin_txt{'341'}";
	$action_area = "setreserve";
	&AdminTemplate;
}

sub SetReserve2 {
	&is_admin_or_gmod;
	$FORM{'reserved'} =~ tr/\r//d;
	$FORM{'reserved'} =~ s~\A[\s\n]+~~;
	$FORM{'reserved'} =~ s~[\s\n]+\Z~~;
	$FORM{'reserved'} =~ s~\n\s*\n~\n~g;
	&write_DBorFILE(0,'',$vardir,'reserve','txt',($FORM{'reserved'}));
	my $matchword = $FORM{'matchword'} eq 'checked' ? 'checked' : '';
	my $matchcase = $FORM{'matchcase'} eq 'checked' ? 'checked' : '';
	my $matchuser = $FORM{'matchuser'} eq 'checked' ? 'checked' : '';
	my $matchname = $FORM{'matchname'} eq 'checked' ? 'checked' : '';
	&write_DBorFILE(0,'',$vardir,'reservecfg','txt',("$matchword\n","$matchcase\n","$matchuser\n","$matchname\n"));
	$yySetLocation = qq~$adminurl~;
	&redirectexit;
}

sub ModifyAgreement {
	&is_admin_or_gmod;

	opendir(LNGDIR, $langdir);
	my @lfilesanddirs = readdir(LNGDIR);
	close(LNGDIR);

	my $agreementlanguage = $FORM{'agreementlanguage'} || $INFO{'agreementlanguage'} || $lang;
	foreach my $fld (sort {lc($a) cmp lc($b)} @lfilesanddirs) {
		if (-d "$langdir/$fld" && $fld =~ m^\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@/]+\Z^ && -e "$langdir/$fld/Main.lng") {
			my $displang = $fld;
			$displang =~ s~(.+?)\_(.+?)$~$1 ($2)~gi;
			if ($agreementlanguage eq $fld) { $drawnldirs .= qq~<option value="$fld" selected="selected">$displang</option>~; }
			else { $drawnldirs .= qq~<option value="$fld">$displang</option>~; }
		}
	}

	my ($line,$fullagreement);
	foreach $line (&read_DBorFILE(0,'',"$langdir/$agreementlanguage",'agreement','txt')) {
		$line =~ tr/[\r\n]//d;
		&FromHTML($line);
		$fullagreement .= qq~$line\n~;
	}
	my $dispagrlang = $agreementlanguage;
	$dispagrlang =~ s~(.+?)\_(.+?)$~$1 ($2)~gi;
	$yymain .= qq~

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg"><img src="$imagesdir/xx.gif" alt="" border="0" /><b>$admin_txt{'764'}</b></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
		<label for="agreement">$admin_txt{'765'}</label><br /><br />
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
	<form action="$adminurl?action=modagreement" method="post" enctype="application/x-www-form-urlencoded">
	$templs{'8'}
	<select name="agreementlanguage" id="agreementlanguage" size="1">
		$drawnldirs
	</select>
	<input type="submit" value="$admin_txt{'462'}" class="button" />
	</form>
       </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="windowbg2"><br />
	<form action="$adminurl?action=modagreement2" method="post" enctype="application/x-www-form-urlencoded">
	<input type="hidden" name="destination" value="$INFO{'destination'}" />
	<input type="hidden" name="agreementlanguage" value="$agreementlanguage" />
	<textarea rows="35" cols="95" name="agreement" id="agreement" style="width:95%">$fullagreement</textarea><br /><br />
       </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg"><input type="submit" value="$admin_txt{'10'} $dispagrlang" class="button" /></td>
     </tr>
	</form>
   </table>
 </div>
~;
	$yytitle     = "$admin_txt{'764'}";
	$action_area = "modagreement";
	&AdminTemplate;
}

sub ModifyAgreement2 {
	&is_admin_or_gmod;

	if ($FORM{'agreementlanguage'}) { $agreementlanguage = $FORM{'agreementlanguage'}; }
	else { $agreementlanguage = $lang; }
	$FORM{'agreement'} =~ tr/\r//d;
	$FORM{'agreement'} =~ s~\A\n+~~;
	$FORM{'agreement'} =~ s~\n+\Z~~;
	&write_DBorFILE(0,'',"$langdir/$agreementlanguage",'agreement','txt',($FORM{'agreement'}));

	$FORM{'agreement'} =~ s/\n/<br \/>\n/g;
	&write_DBorFILE(0,'',"$helpfile/$agreementlanguage/User/",'user00_agreement','help',(qq^\$SectionName = "$register_txt{'764a'}";

### Section 1
#############################################
\$SectionSub1 = "$register_txt{'764a'}";
\$SectionBody1 = qq~<p>$FORM{'agreement'}</p>~;
#############################################


1;^));

	$yySetLocation = $FORM{'destination'} ? qq~$adminurl?action=$FORM{'destination'}~ : qq~$adminurl?action=modagreement;agreementlanguage=$FORM{'agreementlanguage'}~;
	&redirectexit;
}

sub GmodSettings2 {
	&is_admin;

	# modstyle is set the same as modcss as modcss is useless without it.
	$mynewsettings = $FORM{'main'} || $FORM{'advanced'} || $FORM{'news'} || $FORM{'security'}|| $FORM{'antispam'};

	$FORM{'viewmembers'} = "on" if $FORM{'deletemultimembers'} eq 'on' || $FORM{'addmember'} eq 'on';

	my $filler  = q~                                                                               ~;
	my $setfile = << "EOF";
### Gmod Related Setttings ###

\$allow_gmod_admin = "$FORM{'allow_gmod_admin'}"; #
\$allow_gmod_profile = "$FORM{'allow_gmod_profile'}"; #
\$allow_gmod_aprofile = "$FORM{'allow_gmod_aprofile'}"; #
\$gmod_newfile = "on"; #

### Areas Gmods can Access ### 

%gmod_access = (
'ext_admin',"$FORM{'ext_admin'}",

'newsettings;page=main',"$FORM{'main'}",
'newsettings;page=advanced', "$FORM{'advanced'}",
'editbots',"$FORM{'editbots'}",

'newsettings;page=news',"$FORM{'news'}",
'smilies',"$FORM{'smilies'}",
'setcensor',"$FORM{'setcensor'}",
'modagreement',"$FORM{'modagreement'}",

'referer_control',"$FORM{'referer_control'}",
'newsettings;page=security',"$FORM{'security'}",
'setup_guardian',"$FORM{'setup_guardian'}",
'newsettings;page=antispam',"$FORM{'antispam'}",

'managecats',"$FORM{'managecats'}",
'manageboards',"$FORM{'manageboards'}",
'helpadmin',"$FORM{'helpadmin'}",
'editemailtemplates',"$FORM{'editemailtemplates'}",

'addmember',"$FORM{'addmember'}",
'viewmembers',"$FORM{'viewmembers'}",
'deletemultimembers',"$FORM{'deletemultimembers'}",
'modmemgr',"$FORM{'modmemgr'}",
'mailing',"$FORM{'mailing'}",
'ipban',"$FORM{'ipban'}",
'setreserve',"$FORM{'setreserve'}",

'modskin',"$FORM{'modskin'}",
'modcss',"$FORM{'modcss'}",
'modtemp',"$FORM{'modtemp'}",

'clean_log',"$FORM{'clean_log'}",
'boardrecount',"$FORM{'boardrecount'}",
'rebuildmesindex',"$FORM{'rebuildmesindex'}",
'rebuildmemlist',"$FORM{'rebuildmemlist'}",
'rebuildmemhist',"$FORM{'rebuildmemhist'}",
'rebuildnotifications',"$FORM{'rebuildnotifications'}",
'deleteoldthreads',"$FORM{'deleteoldthreads'}",
'manageattachments',"$FORM{'manageattachments'}",

'detailedversion',"$FORM{'detailedversion'}",
'stats',"$FORM{'stats'}",
'showclicks',"$FORM{'showclicks'}",
'errorlog',"$FORM{'errorlog'}",

'view_reglog',"$FORM{'view_reglog'}",

'modlist',"$FORM{'modlist'}",
);

%gmod_access2 = (
admin => "$FORM{'allow_gmod_admin'}",

newsettings => "$mynewsettings",
newsettings2 => "$mynewsettings",

eventcal_set => "$FORM{'eventcal_set'}",
eventcal_set2 => "$FORM{'eventcal_set'}",
eventcal_set3 => "$FORM{'eventcal_set'}",

deleteattachment => "$FORM{'manageattachments'}",
manageattachments2 => "$FORM{'manageattachments'}",
removeoldattachments => "$FORM{'manageattachments'}",
removebigattachments => "$FORM{'manageattachments'}",
rebuildattach => "$FORM{'manageattachments'}",
remghostattach => "$FORM{'manageattachments'}",

profile => "$FORM{'allow_gmod_profile'}",
profile2 => "$FORM{'allow_gmod_profile'}",
profileAdmin => "$FORM{'allow_gmod_aprofile'}",
profileAdmin2 => "$FORM{'allow_gmod_aprofile'}",
profileContacts => "$FORM{'allow_gmod_profile'}",
profileContacts2 => "$FORM{'allow_gmod_profile'}",
profileIM => "$FORM{'allow_gmod_profile'}",
profileIM2 => "$FORM{'allow_gmod_profile'}",
profileOptions => "$FORM{'allow_gmod_profile'}",
profileOptions2 => "$FORM{'allow_gmod_profile'}",

ext_edit => "$FORM{'ext_admin'}",
ext_edit2 => "$FORM{'ext_admin'}",
ext_create => "$FORM{'ext_admin'}",
ext_reorder => "$FORM{'ext_admin'}",
ext_convert => "$FORM{'ext_admin'}",

myprofileAdmin => "$FORM{'allow_gmod_aprofile'}",
myprofileAdmin2 => "$FORM{'allow_gmod_aprofile'}",

delgroup => "$FORM{'modmemgr'}",
editgroup => "$FORM{'modmemgr'}",
editAddGroup2 => "$FORM{'modmemgr'}",
modmemgr2 => "$FORM{'modmemgr'}",
assigned => "$FORM{'modmemgr'}",
assigned2 => "$FORM{'modmemgr'}",

reordercats => "$FORM{'managecats'}",
reordercats2 => "$FORM{'managecats'}",
modifycatorder => "$FORM{'managecats'}",
modifycat => "$FORM{'managecats'}",
createcat => "$FORM{'managecats'}",
catscreen => "$FORM{'managecats'}",
addcat => "$FORM{'managecats'}",
addcat2 => "$FORM{'managecats'}",

modskin => "$FORM{'modskin'}",
modskin2 => "$FORM{'modskin'}",
modcss => "$FORM{'modcss'}",
modcss2 => "$FORM{'modcss'}",
modstyle => "$FORM{'modcss'}",
modstyle2 => "$FORM{'modcss'}",
modtemplate2 => "$FORM{'modtemp'}",
modtemp2 => "$FORM{'modtemp'}",

modifyboard => "$FORM{'manageboards'}",
addboard => "$FORM{'manageboards'}",
addboard2 => "$FORM{'manageboards'}",
reorderboards => "$FORM{'manageboards'}",
reorderboards2 => "$FORM{'manageboards'}",
boardscreen => "$FORM{'manageboards'}",

smilieput => "$FORM{'smilies'}",
smilieindex => "$FORM{'smilies'}",
smiliemove => "$FORM{'smilies'}",
addsmilies => "$FORM{'smilies'}",

addmember => "$FORM{'addmember'}",
addmember2 => "$FORM{'addmember'}",
ml => "$FORM{'viewmembers'}",
deletemultimembers => "$FORM{'deletemultimembers'}",

mailmultimembers => "$FORM{'mailing'}",
mailing2 => "$FORM{'mailing'}",

activate => "$FORM{'view_reglog'}",
admin_descision => "$FORM{'view_reglog'}",
apr_regentry => "$FORM{'view_reglog'}",
del_regentry => "$FORM{'view_reglog'}",
rej_regentry => "$FORM{'view_reglog'}",
view_regentry => "$FORM{'view_reglog'}",
clean_reglog => "$FORM{'view_reglog'}",

cleanerrorlog => "$FORM{'errorlog'}",
deleteerror => "$FORM{'errorlog'}",

modagreement2 => "$FORM{'modagreement'}",
advsettings2 => "$FORM{'advsettings'}",
referer_control2 => "$FORM{'referer_control'}",
removeoldthreads => "$FORM{'deleteoldthreads'}",
ipban2 => "$FORM{'ipban'}",
ipban3 => "$FORM{'ipban'}",
setcensor2 => "$FORM{'setcensor'}",
setreserve2 => "$FORM{'setreserve'}",

editbots2 => "$FORM{'editbots'}",
);

1;
EOF

	$setfile =~ s~(.+\;)\s+(\#.+$)~$1 . substr( $filler, 0, (70-(length $1)) ) . $2 ~gem;
	$setfile =~ s~(.{64,}\;)\s+(\#.+$)~$1 . "\n   " . $2~gem;
	$setfile =~ s~^\s\s\s+(\#.+$)~substr( $filler, 0, 70 ) . $1~gem;

	&write_DBorFILE(0,'',$vardir,'gmodsettings','txt',($setfile));

	$yySetLocation = qq~$adminurl~;
	&redirectexit;
}

sub EditPaths {
	# Simple output of env variables, for troubleshooting
	if ($ENV{'SCRIPT_FILENAME'} ne "") {
		$support_env_path = $ENV{'SCRIPT_FILENAME'};

		# replace \'s with /'s for Windows Servers
		$support_env_path =~ s~\\~/~g;

		# Remove Setupl.pl and cgi - and also nph- for buggy IIS.
		$support_env_path =~ s~(nph-)?AdminIndex.(pl|cgi)~~ig;
	} elsif ($ENV{'PATH_TRANSLATED'} ne "") {
		$support_env_path = $ENV{'PATH_TRANSLATED'};

		# replace \'s with /'s for Windows Servers
		$support_env_path =~ s~\\~/~g;

		# Remove Setupl.pl and cgi - and also nph- for buggy IIS.
		$support_env_path =~ s~(nph-)?AdminIndex.(pl|cgi)~~ig;
	}

	$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg"><b>$edit_paths_txt{'33'}</b></td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$edit_paths_txt{'34'}</span></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
			<br />
			$support_env_path
			<br />
			<br />
       </td>
     </tr>
   </table>
 </div>

<br />
<br />

<form action="$adminurl?action=editpaths2" method="post" enctype="application/x-www-form-urlencoded">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
		<img src="$imagesdir/preferences.gif" alt="" border="0" />
&nbsp;<b>$edit_paths_txt{'1'}</b>
       </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$edit_paths_txt{'2'}</span></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
		<div class="setting_cell">
			<label for="boarddir">$edit_paths_txt{'4'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="boarddir" id="boarddir" size="50" value="$boarddir" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="admindir">$edit_paths_txt{'9'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="admindir" id="admindir" size="50" value="$admindir" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="boardsdir">$edit_paths_txt{'5'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="boardsdir" id="boardsdir" size="50" value="$boardsdir" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="helpfile">$edit_paths_txt{'12'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="helpfile" id="helpfile" size="50" value="$helpfile" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="langdir">$edit_paths_txt{'11'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="langdir" id="langdir" size="50" value="$langdir" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="memberdir">$edit_paths_txt{'7'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="memberdir" id="memberdir" size="50" value="$memberdir" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="datadir">$edit_paths_txt{'6'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="datadir" id="datadir" size="50" value="$datadir" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="sourcedir">$edit_paths_txt{'8'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="sourcedir" id="sourcedir" size="50" value="$sourcedir" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="templatesdir">$edit_paths_txt{'13'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="templatesdir" id="templatesdir" size="50" value="$templatesdir" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="vardir">$edit_paths_txt{'10'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="vardir" id="vardir" size="50" value="$vardir" />
		</div>
		<br />
	<!--	<div class="setting_cell">
			<label for="forumstylesdir">$edit_paths_txt{'14'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="forumstylesdir" id="forumstylesdir" size="50" value="$forumstylesdir" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="adminstylesdir">$edit_paths_txt{'15'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="adminstylesdir" id="adminstylesdir" size="50" value="$adminstylesdir" />
		</div>
		<br />
	-->	<div>&nbsp;</div>
		<div class="setting_cell">
			<label for="htmldir">$edit_paths_txt{'16'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="htmldir" id="htmldir" size="50" value="$htmldir" />
		</div>
		<br />
	<!--	<div class="setting_cell">
			<label for="smiliesdir">$edit_paths_txt{'18'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="smiliesdir" id="smiliesdir" size="50" value="$smiliesdir" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="modimgdir">$edit_paths_txt{'19'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="modimgdir" id="modimgdir" size="50" value="$modimgdir" />
		</div>
		<br />
	-->	<div class="setting_cell">
			<label for="uploaddir">$edit_paths_txt{'20'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="uploaddir" id="uploaddir" size="50" value="$uploaddir" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="facesdir">$edit_paths_txt{'17'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="facesdir" id="facesdir" size="50" value="$facesdir" />
		</div>
       </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg"><span class="small">$edit_paths_txt{'21'}</span></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
		<div class="setting_cell">
			<label for="boardurl">$edit_paths_txt{'3'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="boardurl" id="boardurl" size="50" value="$boardurl" />
		</div>
		<div>&nbsp;</div>
	<!--	<div class="setting_cell">
			<label for="forumstylesurl">$edit_paths_txt{'22'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="forumstylesurl" id="forumstylesurl" size="50" value="$forumstylesurl" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="adminstylesurl">$edit_paths_txt{'23'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="adminstylesurl" id="adminstylesurl" size="50" value="$adminstylesurl" />
		</div>
		<br />
	-->	<div class="setting_cell">
			<label for="yyhtml_root">$edit_paths_txt{'28'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="yyhtml_root" id="yyhtml_root" size="50" value="$yyhtml_root" />
		</div>
		<br />
	<!--	<div class="setting_cell">
			<label for="smiliesurl">$edit_paths_txt{'30'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="smiliesurl" id="smiliesurl" size="50" value="$smiliesurl" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="modimgurl">$edit_paths_txt{'31'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="modimgurl" id="modimgurl" size="50" value="$modimgurl" />
		</div>
		<br />
	-->	<div class="setting_cell">
			<label for="uploadurl">$edit_paths_txt{'32'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="uploadurl" id="uploadurl" size="50" value="$uploadurl" />
		</div>
		<br />
		<div class="setting_cell">
			<label for="facesurl">$edit_paths_txt{'29'}</label>
		</div>
		<div class="setting_cell2">
			<input type="text" name="facesurl" id="facesurl" size="50" value="$facesurl" />
		</div>
       </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg">
		 <input type="hidden" name="lastsaved" value="${$uid.$username}{'realname'}" />
		 <input type="hidden" name="lastdate" value="$date" />
		 <input type="submit" value="$admin_txt{'10'}" class="button" />
       </td>
     </tr>
   </table>
 </div>
</form>
~;
	$yytitle     = "$edit_paths_txt{'1'}";
	$action_area = "editpaths";
	&AdminTemplate;
}

sub EditPaths2 {
	&LoadCookie;          # Load the user's cookie (or set to guest)
	&LoadUserSettings;
	if (!$iamadmin) { &fatal_error("no_access"); }

	$lastsaved      = $FORM{'lastsaved'};
	$lastdate       = $FORM{'lastdate'};
	$boardurl       = $FORM{'boardurl'};
	$boarddir       = $FORM{'boarddir'};
	$htmldir        = $FORM{'htmldir'};
	$uploaddir      = $FORM{'uploaddir'};
	$uploadurl      = $FORM{'uploadurl'};
	$yyhtml_root    = $FORM{'yyhtml_root'};
	$datadir        = $FORM{'datadir'};
	$boardsdir      = $FORM{'boardsdir'};
	$memberdir      = $FORM{'memberdir'};
	$sourcedir      = $FORM{'sourcedir'};
	$admindir       = $FORM{'admindir'};
	$vardir         = $FORM{'vardir'};
	$langdir        = $FORM{'langdir'};
	$helpfile       = $FORM{'helpfile'};
	$templatesdir   = $FORM{'templatesdir'};
	#$forumstylesdir = $FORM{'forumstylesdir'};
	#$forumstylesurl = $FORM{'forumstylesurl'};
	#$adminstylesdir = $FORM{'adminstylesdir'};
	#$adminstylesurl = $FORM{'adminstylesurl'};
	$facesdir       = $FORM{'facesdir'};
	$facesurl       = $FORM{'facesurl'};
	#$smiliesdir     = $FORM{'smiliesdir'};
	#$smiliesurl     = $FORM{'smiliesurl'};
	#$modimgdir      = $FORM{'modimgdir'};
	#$modimgurl      = $FORM{'modimgurl'};

	my $filler  = q~                                                                               ~;
	my $setfile = << "EOF";
###############################################################################
# Paths.pl                                                                    #
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
# Sponsored by: Xnull Internet Media, Inc. - http://www.ximinc.com            #
#               Your source for web hosting, web design, and domains.         #
###############################################################################

\$lastsaved = "$lastsaved";
\$lastdate = "$lastdate";

########## Directories ##########

\$boardurl = "$boardurl";				# URL of your board's folder (without trailing '/')
\$boarddir = "$boarddir";				# The server path to the board's folder (usually can be left as '.')
\$boardsdir = "$boardsdir";				# Directory with board data files
\$datadir = "$datadir";					# Directory with messages
\$memberdir = "$memberdir";				# Directory with member files
\$sourcedir = "$sourcedir";				# Directory with YaBB source files
\$admindir = "$admindir";				# Directory with YaBB admin source files
\$vardir = "$vardir";					# Directory with variable files
\$langdir = "$langdir";					# Directory with Language files and folders
\$helpfile = "$helpfile";				# Directory with Help files and folders
\$templatesdir = "$templatesdir";			# Directory with template files and folders
\$htmldir = "$htmldir";					# Base Path for all public-html files and folders
\$facesdir = "$facesdir";				# Base Path for all avatar files
\$uploaddir = "$uploaddir";				# Base Path for all attachment files

########## URL's ##########

\$yyhtml_root = "$yyhtml_root";				# Base URL for all html/css files and folders
\$facesurl = "$facesurl";				# Base URL for all avatar files
\$uploadurl = "$uploadurl";				# Base URL for all attachment files

########## Old Path Settings ##########
########## The following variables are deprecated! ##########
########## Don't use them for new code! ##########

\$forumstylesdir = \$htmldir . "/Templates/Forum";	# Directory with forum style files and folders
\$adminstylesdir = \$htmldir . "/Templates/Admin";	# Directory with admin style files and folders
\$smiliesdir = \$htmldir . "/Smilies";			# Base Path for all smilie files
\$modimgdir = \$htmldir . "/ModImages";			# Base Path for all mod images

\$forumstylesurl = \$yyhtml_root . "/Templates/Forum";	# Default Forum Style Directory
\$adminstylesurl = \$yyhtml_root . "/Templates/Admin";	# Default Admin Style Directory
\$smiliesurl = \$yyhtml_root . "/Smilies";		# Base URL for all smilie files
\$modimgurl = \$yyhtml_root . "/ModImages";		# Base URL for all mod images

1;
EOF

	$setfile =~ s~(.+\;)\s+(\#.+$)~$1 . substr( $filler, 0, (70-(length $1)) ) . $2 ~gem;
	$setfile =~ s~(.{64,}\;)\s+(\#.+$)~$1 . "\n   " . $2~gem;
	$setfile =~ s~^\s\s\s+(\#.+$)~substr( $filler, 0, 70 ) . $1~gem;

	&write_DBorFILE(0,'','./','Paths','pl',($setfile));

	$yySetLocation = qq~$adminurl~;
	&redirectexit;
}

1;