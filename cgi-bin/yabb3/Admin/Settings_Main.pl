###############################################################################
# Settings_Main.pl                                                            #
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

$settings_mainplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

# Language requirements
&LoadLanguage('Register');

# Date/Time selector
my ($forumstart_month, $forumstart_day, $forumstart_year, $forumstart_hour, $forumstart_minute, $forumstart_secund) = $forumstart =~ m~(\d{2})\/(\d{2})\/(\d{2,4}).*?(\d{2})\:(\d{2})\:(\d{2})~s;

if ($forumstart_month > 12) { $forumstart_month = 12; }
if ($forumstart_month < 1) { $forumstart_month = 1; }
if ($forumstart_day > 31) { $forumstart_day = 31; }
if ($forumstart_day < 1) { $forumstart_day = 1; }
if (length($forumstart_year) > 2) { $forumstart_year = substr($forumstart_year , length($forumstart_year) - 2, 2); }
if ($forumstart_year < 90 && $forumstart_year > 20) { $forumstart_year = 90; }
if ($forumstart_year > 20 && $forumstart_year < 90) { $forumstart_year = 20; }
if ($forumstart_hour > 23) { $forumstart_hour = 23; }
if ($forumstart_minute > 59) { $forumstart_minute = 59; }
if ($forumstart_secund > 59) { $forumstart_secund = 59; }

my $sel_day = qq~
<select name="forumstart_day"~ . (($timeselected == 1 || $timeselected == 4 || $timeselected == 5) ? '' : ' id="fd_fm"') . qq~>\n~;
for ($i = 1; $i <= 31; $i++) {
	$day_val = sprintf("%02d", $i);
	$sel_day .= qq~<option value="$day_val" ${isselected($forumstart_day == $i)}>$i</option>\n~;
}
$sel_day .= qq~</select>\n~;

my $sel_month = qq~
<select name="forumstart_month"~ . (($timeselected == 1 || $timeselected == 4 || $timeselected == 5) ? ' id="fd_fm"' : '') . qq~>\n~;
for ($i = 0; $i < 12; $i++) {
	$z = $i+1;
	$month_val = sprintf("%02d", $z);
	$sel_month .= qq~<option value="$month_val" ${isselected($forumstart_month == $z)}>$months[$i]</option>\n~;
}
$sel_month .= qq~</select>\n~;

my $sel_year = qq~
<select name="forumstart_year">\n~;
for ($i = 90; $i <= 120; $i++) {
	if($i < 100) { $z = $i; $year_pre = qq~19~; } else { $z = $i-100; $year_pre = qq~20~; }
	$year_val = sprintf("%02d", $z);
	$sel_year .= qq~<option value="$year_val" ${isselected($forumstart_year == $z)}>$year_pre$year_val</option>\n~;
}
$sel_year .= qq~</select>\n~;

if ($timeselected == 1 || $timeselected == 4 || $timeselected == 5) { $all_date = qq~$sel_month $sel_day $sel_year~; }
else { $all_date = qq~$sel_day $sel_month $sel_year~; }

my $sel_hour = qq~
<select name="forumstart_hour">\n~;
for($i = 0; $i <= 23; $i++) {
	$hour_val = sprintf("%02d", $i);
	$sel_hour .= qq~<option value="$hour_val" ${isselected($forumstart_hour == $i)}>$hour_val</option>\n~;
}
$sel_hour .= qq~</select>\n~;

my $sel_minute = qq~
<select name="forumstart_minute">\n~;
for($i = 0; $i <= 59; $i++) {
	$minute_val = sprintf("%02d", $i);
	$sel_minute .= qq~<option value="$minute_val" ${isselected($forumstart_minute == $i)}>$minute_val</option>\n~;
}
$sel_minute .= qq~</select>\n~;

my $sel_secund = qq~<input type="hidden" value="$forumstart_secund" name="forumstart_secund" />~;
my $all_time = qq~$sel_hour $sel_minute $sel_secund~;
# End time

# Timezone selector
my @usertimeoffset = split(/\./, $timeoffset);
my $timeoffsetselect = qq~<span class="small"><br /><br /></span><select name="usertimesign" id="usertimesign"><option value="">+</option><option value="-"~ . ($usertimeoffset[0] < 0 ? ' selected="selected"' : '') . qq~>-</option></select> <select name="usertimehour">~;
	for (my $i = 0; 15 > $i; $i++) {
		$i = sprintf("%02d", $i);
		$timeoffsetselect .= qq~<option value="$i"~ . (($usertimeoffset[0] == $i || $usertimeoffset[0] == -$i) ? ' selected="selected"' : '') . qq~>$i</option>~;
	}
	$timeoffsetselect .= qq~</select> : <select name="usertimemin">~;
	for (my $i = 0; 60 > $i; $i++) {
		my $j = $i / 60;
		$j = (split(/\./, $j))[1] || 0;
		$timeoffsetselect .= qq~<option value="$j"~ . ($usertimeoffset[1] eq $j ? ' selected="selected"' : '') . qq~>~ . sprintf("%02d", $i) . qq~</option>~;
	}
	$timeoffsetselect .= qq~</select>~;

# Language selector
opendir(LNGDIR, $langdir);
my @lfilesanddirs = readdir(LNGDIR);
close(LNGDIR);
foreach my $fld (sort {lc($a) cmp lc($b)} @lfilesanddirs) {
	if (-e "$langdir/$fld/Main.lng") {
		my $displang = $fld;
		$displang =~ s~(.+?)\_(.+?)$~$1 ($2)~gi;
		$drawnldirs .= qq~<option value="$fld" ${isselected($fld eq $lang)}>$displang</option>~;
	}
}

# Template selector
foreach my $curtemplate (sort{ $templateset{$a} cmp $templateset{$b} } keys %templateset) {
	$drawndirs .= qq~<option value="$curtemplate" ${isselected($curtemplate eq $default_template)}>$curtemplate</option>\n~;
}

# imspam conversion
$imspam = 0 if $imspam eq 'off';

$imtext =~ s~<br />~\n~g;

# max / min for PM search
$enable_PMsearch =~ s/\D//ig;
$enable_PMsearch = 0 if !$enable_PMsearch;
$enable_PMsearch = 50 if $enable_PMsearch > 50;
$enable_PMsearch = 5 if $enable_PMsearch < 5;
$set_subjectMaxLength = 50 if $set_subjectMaxLength eq '';
$RegReasonSymbols = 200 if $RegReasonSymbols eq '';
$ML_Allowed = 1 if $ML_Allowed eq '';

# This is only for update, when comming from YaBB lower or equal version 2.2.3
# I think it can be deleted around version 2.4.0 without causing mayor issues (deti).
if ($enable_notifications eq '') { $enable_notifications = $enable_notification ? 3 : 0; }
# End update workaround

require "$admindir/ManageBoards.pl"; # needed for avatar upload settings

# Insert default if forum is beeing upgraded to YaBB 2.4
if (!$pwstrengthmeter_scores && !$pwstrengthmeter_common && !$pwstrengthmeter_minchar) {
	$FORM{'pwstrengthmeter_scores'} = "10,15,30,40";
	$FORM{'pwstrengthmeter_common'} = qq~"123456","abcdef","password"~;
	$FORM{'pwstrengthmeter_minchar'} = 3;
}

# googiespell start
eval { require LWP::UserAgent };
my $modulLWP = $@;
eval { require HTTP::Request::Common };
my $modulHTTP = $@;
eval { require Crypt::SSLeay };
my $modulCrypt = $@;

my $googiehtml = qq~<input type="checkbox" name="enable_spell_check" id="enable_spell_check" value="1"${ischecked($enable_spell_check)} />~;
 if ($modulLWP || $modulHTTP || $modulCrypt) {
	$googiehtml = qq~<input type="hidden" name="enable_spell_check" value="0" />~ .
	$admin_txt{'377a'} .
	"- LWP::UserAgent &lt;- <b>" . ($modulLWP ? $modulLWP : $admin_txt{'377b'}) . "</b><br />" .
	"- HTTP::Request::Common &lt;- <b>" . ($modulHTTP ? $modulHTTP : $admin_txt{'377b'}) . "</b><br />" .
	"- Crypt::SSLeay &lt;- <b>" . ($modulCrypt ? $modulCrypt : $admin_txt{'377b'}) . "</b><br />" .
	$admin_txt{'377c'};
}
# googiespell end 

# List of settings
@settings = (
{
	name  => $settings_txt{'generalforum'},
	id    => 'general',
	items => [
		{
			header => $settings_txt{'generalforum'},
		},
		{
			description => qq~<label for="mbname">$admin_txt{'350'}</label>~,
			input_html => qq~<input type="text" size="40" name="mbname" id="mbname" value="$mbname" />~,
			name => 'mbname',
			validate => 'text',
		},
		{
			description => qq~<label for="fd_fm">$admin_txt{'350a'}</label>~,
			input_html => qq~$all_date $maintxt{'107'} $all_time~,
			### Custom validated.
		},
		{
			description => qq~<label for="MenuType">$admin_txt{'521'}</label>~,
			input_html => qq~
<select name="MenuType" id="MenuType" size="1">
  <option value="0" ${isselected($MenuType == 0)}>$admin_txt{'521a'}</option>
  <option value="1" ${isselected($MenuType == 1)}>$admin_txt{'521b'}</option>
  <option value="2" ${isselected($MenuType == 2)}>$admin_txt{'521c'}</option>
</select>~,
			name => 'MenuType',
			validate => 'number',
		},
		{
			description => qq~<label for="default_template">$admin_txt{'813'}</label>~,
			input_html => qq~<select name="default_template" id="default_template">$drawndirs</select>~,
			name => 'default_template',
			validate => 'text',
		},
		{
			description => qq~<label for="lang">$admin_txt{'816'}</label>~,
			input_html => qq~<select name="lang" id="lang">$drawnldirs</select>~,
			name => 'lang',
			validate => 'text',
		},
		{
			description => qq~<label for="forumnumberformat">$admin_txt{'forumnumbformat'}</label>~,
			input_html => qq~
<select name="forumnumberformat" id="forumnumberformat" size="1">
  <option value="1" ${isselected($forumnumberformat == 1)}>10987.65</option>
  <option value="2" ${isselected($forumnumberformat == 2)}>10987,65</option>
  <option value="3" ${isselected($forumnumberformat == 3)}>10,987.65</option>
  <option value="4" ${isselected($forumnumberformat == 4)}>10.987,65</option>
  <option value="5" ${isselected($forumnumberformat == 5)}>10 987,65</option>
</select>~,
			name => 'forumnumberformat',
			validate => 'number',
		},
		{
			description => qq~<label for="timeselected">$admin_txt{'587'}</label>~,
			input_html => qq~
<select name="timeselected" id="timeselected" size="1">
  <option value="1" ${isselected($timeselected == 1)}>$admin_txt{'480'}</option>
  <option value="5" ${isselected($timeselected == 5)}>$admin_txt{'484'}</option>
  <option value="4" ${isselected($timeselected == 4)}>$admin_txt{'483'}</option>
  <option value="8" ${isselected($timeselected == 8)}>$admin_txt{'483a'}</option>
  <option value="2" ${isselected($timeselected == 2)}>$admin_txt{'481'}</option>
  <option value="3" ${isselected($timeselected == 3)}>$admin_txt{'482'}</option>
  <option value="6" ${isselected($timeselected == 6)}>$admin_txt{'485'}</option>
</select>~,
			name => 'timeselected',
			validate => 'number',
		},
		{
			description => qq~<label for="usertimesign">$admin_txt{'371'}</label>~,
			input_html => &timeformat($date,1,0,1) . $timeoffsetselect,
			### Custom validated.
		},
		{
			description => qq~<label for="dstoffset">$admin_txt{'371a'}</label>~,
			input_html => qq~<input type="checkbox" name="dstoffset" id="dstoffset" value="1"${ischecked($dstoffset)}/>~,
			name => 'dstoffset',
			validate => 'boolean',
		},
		{
			description => qq~<label for="dynamic_clock">$admin_txt{'371b'}</label>~,
			input_html => qq~<input type="checkbox" name="dynamic_clock" id="dynamic_clock" value="1"${ischecked($dynamic_clock)}/>~,
			name => 'dynamic_clock',
			validate => 'boolean',
		},
		{
			description => qq~<label for="timecorrection">$admin_txt{'371c'}</label>~,
			input_html => qq~<input type="text" size="4" name="timecorrection" id="timecorrection" value="$timecorrection" />~,
			name => 'timecorrection',
			validate => 'fullnumber',
		},
		{
			header => $settings_txt{'showhide'},
		},
		{
			description => qq~<label for="profilebutton">$admin_txt{'523'}</label>~,
			input_html => qq~<input type="checkbox" name="profilebutton" id="profilebutton" value="1"${ischecked($profilebutton)} />~,
			name => 'profilebutton',
			validate => 'boolean',
		},
		{
			description => qq~<label for="usertools">$admin_txt{'526'}</label>~,
			input_html => qq~<input type="checkbox" name="usertools" id="usertools" value="1"${ischecked($usertools)} />~,
			name => 'usertools',
			validate => 'boolean',
		},
		{
			description => qq~<label for="posttools">$admin_txt{'527'}</label>~,
			input_html => qq~<input type="checkbox" name="posttools" id="posttools" value="1"${ischecked($posttools)} />~,
			name => 'posttools',
			validate => 'boolean',
		},
		{
			description => qq~<label for="threadtools">$admin_txt{'528'}</label>~,
			input_html => qq~<input type="checkbox" name="threadtools" id="threadtools" value="1"${ischecked($threadtools)} />~,
			name => 'threadtools',
			validate => 'boolean',
		},
		{
			description => qq~<label for="userinfostyle">$admin_txt{'529'}</label>~,
			input_html => qq~<input type="checkbox" name="userinfostyle" id="userinfostyle" value="1"${ischecked($userinfostyle)} />~,
			name => 'userinfostyle',
			validate => 'boolean',
		},
		{
			description => qq~<label for="showlatestmember">$admin_txt{'382'}</label>~,
			input_html => qq~<input type="checkbox" name="showlatestmember" id="showlatestmember" value="1"${ischecked($showlatestmember)} />~,
			name => 'showlatestmember',
			validate => 'boolean',
		},
		{
			description => qq~<label for="Show_RecentBar">$admin_txt{'509'}</label>~,
			input_html => qq~<input type="checkbox" name="Show_RecentBar" id="Show_RecentBar" value="1"${ischecked($Show_RecentBar)} />~,
			name => 'Show_RecentBar',
			validate => 'boolean',
		},
		{
			description => qq~<label for="showpageall">$admin_txt{'showall'}</label>~,
			input_html => qq~<input type="checkbox" name="showpageall" id="showpageall" value="1"${ischecked($showpageall)} />~,
			name => 'showpageall',
			validate => 'boolean',
		},
		{
			description => qq~<label for="ShowBDescrip">$admin_txt{'732'}</label>~,
			input_html => qq~<input type="checkbox" name="ShowBDescrip" id="ShowBDescrip" value="1"${ischecked($ShowBDescrip)} />~,
			name => 'ShowBDescrip',
			validate => 'boolean',
		},
		{
			description => qq~<label for="showmodify">$admin_txt{'383'}</label>~,
			input_html => qq~<input type="checkbox" name="showmodify" id="showmodify" value="1"${ischecked($showmodify)} />~,
			name => 'showmodify',
			validate => 'boolean',
		},
		{
			description => qq~<label for="showuserpic">$admin_txt{'384'}</label>~,
			input_html => qq~<input type="checkbox" name="showuserpic" id="showuserpic" value="1"${ischecked($showuserpic)} />~,
			name => 'showuserpic',
			validate => 'boolean',
		},
		{
			description => qq~<label for="showusertext">$admin_txt{'385'}</label>~,
			input_html => qq~<input type="checkbox" name="showusertext" id="showusertext" value="1"${ischecked($showusertext)} />~,
			name => 'showusertext',
			validate => 'boolean',
		},
		{
			description => qq~<label for="showgenderimage">$admin_txt{'386'}</label>~,
			input_html => qq~<input type="checkbox" name="showgenderimage" id="showgenderimage" value="1"${ischecked($showgenderimage)} />~,
			name => 'showgenderimage',
			validate => 'boolean',
		},
		{
			description => qq~<label for="hide_signat_for_guests">$admin_txt{'409'}</label>~,
			input_html => qq~<input type="checkbox" name="hide_signat_for_guests" id="hide_signat_for_guests" value="1"${ischecked($hide_signat_for_guests)} />~,
			name => 'hide_signat_for_guests',
			validate => 'boolean',
		},
		{
			description => qq~<label for="showallgroups">$amv_txt{'12'}</label>~,
			input_html => qq~<input type="checkbox" name="showallgroups" id="showallgroups" value="1"${ischecked($showallgroups)} />~,
			name => 'showallgroups',
			validate => 'boolean',
		},
		{
			description => qq~<label for="showtopicviewers">$admin_txt{'394'}</label>~,
			input_html => qq~
				<select name="showtopicviewers" id="showtopicviewers" size="1">
				  <option value="0"${isselected($showtopicviewers == 0)}>$userlevel_txt{'none'}</option>
				  <option value="1"${isselected($showtopicviewers == 1)}>$userlevel_txt{'modgmodadmin'}</option>
				  <option value="2"${isselected($showtopicviewers == 2)}>$userlevel_txt{'members'}</option>
				  <option value="3"${isselected($showtopicviewers == 3)}>$userlevel_txt{'all'}</option>
				</select>~,
			name => 'showtopicviewers',
			validate => 'number',
		},
		{
			description => qq~<label for="showimageinquote">$admin_txt{'imageinquote'}</label>~,
			input_html => qq~<input type="checkbox" name="showimageinquote" id="showimageinquote" value="1"${ischecked($showimageinquote)} />~,
			name => 'showimageinquote',
			validate => 'boolean',
		},
	],
},
{
	name  => $settings_txt{'posting'},
	id    => 'posting',
	items => [
		{
			header => $settings_txt{'posting'},
		},
		{
			description => qq~<label for="enable_spell_check">$admin_txt{'377'}</label>~,
			input_html => $googiehtml,
			name => 'enable_spell_check',
			validate => 'boolean',
		},
		{
			description => qq~<label for="enable_ubbc">$admin_txt{'378'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_ubbc" id="enable_ubbc" value="1"${ischecked($enable_ubbc)} />~,
			name => 'enable_ubbc',
			validate => 'boolean',
		},
		{
			description => qq~<label for="showyabbcbutt">$admin_txt{'740'}</label>~,
			input_html => qq~<input type="checkbox" name="showyabbcbutt" id="showyabbcbutt" value="1"${ischecked($showyabbcbutt)} />~,
			name => 'showyabbcbutt',
			validate => 'boolean',
		},
		{
			description => qq~<label for="parseflash">$admin_txt{'804'}</label>~,
			input_html => qq~<input type="checkbox" name="parseflash" id="parseflash" value="1"${ischecked($parseflash)} />~,
			name => 'parseflash',
			validate => 'boolean',
		},
		{
			description => qq~<label for="nestedquotes">$admin_txt{'378a'}</label>~,
			input_html => qq~<input type="checkbox" name="nestedquotes" id="nestedquotes" value="1"${ischecked($nestedquotes)} />~,
			name => 'nestedquotes',
			validate => 'boolean',
		},
		{
			description => qq~<label for="autolinkurls">$admin_txt{'524'}</label>~,
			input_html => qq~<input type="checkbox" name="autolinkurls" id="autolinkurls" value="1"${ischecked($autolinkurls)} />~,
			name => 'autolinkurls',
			validate => 'boolean',
		},
		{
			description => qq~<label for="checkallcaps">$admin_txt{'525'}</label>~,
			input_html => qq~<input type="text" size="2" name="checkallcaps" id="checkallcaps" value="$checkallcaps" />~,
			name => 'checkallcaps',
			validate => 'number,null',
		},
		{
			description => qq~<label for="set_subjectMaxLength">$admin_txt{'498a'}</label>~,
			input_html => qq~<input type="text" size="5" name="set_subjectMaxLength" id="set_subjectMaxLength" value="$set_subjectMaxLength" />~,
			name => 'set_subjectMaxLength',
			validate => 'number',
		},
		{
			description => qq~<label for="MaxMessLen">$admin_txt{'498'}</label>~,
			input_html => qq~<input type="text" size="5" name="MaxMessLen" id="MaxMessLen" value="$MaxMessLen" />~,
			name => 'MaxMessLen',
			validate => 'number',
		},
		{
			description => qq~<label for="fontsizemin">$admin_txt{'499'}</label>~,
			input_html => qq~<input type="text" size="5" name="fontsizemin" id="fontsizemin" value="$fontsizemin" />~,
			name => 'fontsizemin',
			validate => 'number',
		},
		{
			description => qq~<label for="fontsizemax">$admin_txt{'500'}</label>~,
			input_html => qq~<input type="text" size="5" name="fontsizemax" id="fontsizemax" value="$fontsizemax" />~,
			name => 'fontsizemax',
			validate => 'number',
		},
		{
			description => qq~<label for="HotTopic">$admin_txt{'842'}</label>~,
			input_html => qq~<input type="text" size="5" name="HotTopic" id="HotTopic" value="$HotTopic" />~,
			name => 'HotTopic',
			validate => 'number',
		},
		{
			description => qq~<label for="VeryHotTopic">$admin_txt{'843'}</label>~,
			input_html => qq~<input type="text" size="5" name="VeryHotTopic" id="VeryHotTopic" value="$VeryHotTopic" />~,
			name => 'VeryHotTopic',
			validate => 'number',
		},
		{
			description => qq~<label for="maxdisplay">$admin_txt{'374'}</label>~,
			input_html => qq~<input type="text" name="maxdisplay" id="maxdisplay" size="5" value="$maxdisplay" />~,
			name => 'maxdisplay',
			validate => 'number',
		},
		{
			description => qq~<label for="maxmessagedisplay">$admin_txt{'375'}</label>~,
			input_html => qq~<input type="text" name="maxmessagedisplay" id="maxmessagedisplay" size="5" value="$maxmessagedisplay" />~,
			name => 'maxmessagedisplay',
			validate => 'number',
		},
		{
			description => qq~<label for="mindex_postpopup">$admin_txt{'1000'}</label>~,
			input_html => qq~<input type="checkbox" name="mindex_postpopup" id="mindex_postpopup" value="1"${ischecked($mindex_postpopup)} />~,
			name => 'mindex_postpopup',
			validate => 'boolean',
		},
		{
			description => qq~<label for="display_postpopup">$admin_txt{'1001'}</label>~,
			input_html => qq~<input type="checkbox" name="display_postpopup" id="display_postpopup" value="1"${ischecked($display_postpopup)} />~,
			name => 'display_postpopup',
			validate => 'boolean',
		},
		{
			description => qq~<label for="mdrop_postpopup">$admin_txt{'1002'}</label>~,
			input_html => qq~<input type="checkbox" name="mdrop_postpopup" id="mdrop_postpopup" value="1"${ischecked($mdrop_postpopup)} />~,
			name => 'mdrop_postpopup',
			validate => 'boolean',
		},
		{
			header => $timelocktxt{'01'},
		},
		{
			description => qq~<label for="tlnomodflag">$timelocktxt{'03'}</label>~,
			input_html => qq~<input type="checkbox" name="tlnomodflag" id="tlnomodflag" value="1"${ischecked($tlnomodflag)} />~,
			name => 'tlnomodflag',
			validate => 'boolean',
		},
		{
			description => qq~<label for="tlnomodtime">$timelocktxt{'04'}</label>~,
			input_html => qq~<input type="text" size="5" name="tlnomodtime" id="tlnomodtime" value="$tlnomodtime" />~,
			name => 'tlnomodtime',
			validate => 'number',
			depends_on => ['tlnomodflag'],
		},
		{
			description => qq~<label for="tlnodelflag">$timelocktxt{'07'}</label>~,
			input_html => qq~<input type="checkbox" name="tlnodelflag" id="tlnodelflag" value="1"${ischecked($tlnodelflag)} />~,
			name => 'tlnodelflag',
			validate => 'boolean',
		},
		{
			description => qq~<label for="tlnodeltime">$timelocktxt{'08'}</label>~,
			input_html => qq~<input type="text" size="5" name="tlnodeltime" id="tlnodeltime" value="$tlnodeltime" />~,
			name => 'tlnodeltime',
			validate => 'number',
			depends_on => ['tlnodelflag'],
		},
		{
			description => qq~<label for="tllastmodflag">$timelocktxt{'05'}</label>~,
			input_html => qq~<input type="checkbox" name="tllastmodflag" id="tllastmodflag" value="1"${ischecked($tllastmodflag)} />~,
			name => 'tllastmodflag',
			validate => 'boolean',
		},
		{
			description => qq~<label for="tllastmodtime">$timelocktxt{'06'}</label>~,
			input_html => qq~<input type="text" size="5" name="tllastmodtime" id="tllastmodtime" value="$tllastmodtime" />~,
			name => 'tllastmodtime',
			validate => 'number',
		},
		{
			header => $cutts{'8'},
		},
		{
			description => qq~<label for="ttsreverse">$cutts{'9'}</label>~,
			input_html => qq~<input type="checkbox" name="ttsreverse" id="ttsreverse" value="1"${ischecked($ttsreverse)} />~,
			name => 'ttsreverse',
			validate => 'boolean',
		},
		{
			description => qq~<label for="ttsureverse">$cutts{'9a'}</label>~,
			input_html => qq~<input type="checkbox" name="ttsureverse" id="ttsureverse" value="1"${ischecked($ttsureverse)} />~,
			name => 'ttsureverse',
			validate => 'boolean',
		},
		{
			description => qq~<label for="tsreverse">$cutts{'7'}</label>~,
			input_html => qq~<input type="checkbox" name="tsreverse" id="tsreverse" value="1"${ischecked($tsreverse)} />~,
			name => 'tsreverse',
			validate => 'boolean',
		},
		{
			description => qq~<label for="cutamount">$cutts{'1'}</label>~,
			input_html => qq~<input type="text" size="5" name="cutamount" id="cutamount" value="$cutamount" />~,
			name => 'cutamount',
			validate => 'number',
		},
		{
			header => $settings_txt{'poll'},
		},
		{
			description => qq~<label for="numpolloptions">$polltxt{'28'}</label>~,
			input_html => qq~<input type="text" size="5" name="numpolloptions" id="numpolloptions" value="$numpolloptions" />~,
			name => 'numpolloptions',
			validate => 'number',
		},
		{
			description => qq~<label for="maxpq">$polltxt{'61'}</label>~,
			input_html => qq~<input type="text" size="5" name="maxpq" id="maxpq" value="$maxpq" />~,
			name => 'maxpq',
			validate => 'number',
		},
		{
			description => qq~<label for="maxpo">$polltxt{'62'}</label>~,
			input_html => qq~<input type="text" size="5" name="maxpo" id="maxpo" value="$maxpo" />~,
			name => 'maxpo',
			validate => 'number',
		},
		{
			description => qq~<label for="maxpc">$polltxt{'63'}</label>~,
			input_html => qq~<input type="text" size="5" name="maxpc" id="maxpc" value="$maxpc" />~,
			name => 'maxpc',
			validate => 'number',
		},
		{
			description => qq~<label for="useraddpoll">$polltxt{'29'}</label>~,
			input_html => qq~<input type="checkbox" name="useraddpoll" id="useraddpoll" value="1"${ischecked($useraddpoll)} />~,
			name => 'useraddpoll',
			validate => 'boolean',
		},
		{
			description => qq~<label for="ubbcpolls">$polltxt{'60'}</label>~,
			input_html => qq~<input type="checkbox" name="ubbcpolls" id="ubbcpolls" value="1"${ischecked($ubbcpolls)} />~,
			name => 'ubbcpolls',
			validate => 'boolean',
		},
		{
			header => $qrb_txt{'1'},
		},
		{
			description => qq~<label for="enable_quickpost">$qrb_txt{'2'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_quickpost" id="enable_quickpost" value="1"${ischecked($enable_quickpost)} />~,
			name => 'enable_quickpost',
			validate => 'boolean',
		},
		{
			description => qq~<label for="enable_quickreply">$qrb_txt{'3'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_quickreply" id="enable_quickreply" value="1"${ischecked($enable_quickreply)} />~,
			name => 'enable_quickreply',
			validate => 'boolean',
		},
		{
			description => qq~<label for="enable_markquote">$qrb_txt{'4'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_markquote" id="enable_markquote" value="1"${ischecked($enable_markquote)} />~,
			name => 'enable_markquote',
			validate => 'boolean',
			depends_on => ['enable_quickreply'],
		},
		{
			description => qq~<label for="enable_quoteuser">$qrb_txt{'5'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_quoteuser" id="enable_quoteuser" value="1"${ischecked($enable_quoteuser)} />~,
			name => 'enable_quoteuser',
			validate => 'boolean',
			depends_on => ['enable_quickreply'],
		},
		{
			description => qq~<label for="quoteuser_color">$qrb_txt{'6'}</label>~,
			input_html => qq~<input type="text" size="7" maxlength="7" name="quoteuser_color" id="quoteuser_color" value="$quoteuser_color" onkeyup="previewColor(this.value);" /> <span id="quoteuser_color2" style="background-color:$quoteuser_color">&nbsp; &nbsp; &nbsp;</span> <img src="$defaultimagesdir/palette1.gif" align="top" style="cursor: pointer" onclick="window.open('$scripturl?action=palette;task=templ', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" alt="" border="0" />
			<script language="JavaScript1.2" type="text/javascript">
			<!--
			function previewColor(color) {
				document.getElementById('quoteuser_color2').style.background = color;
				document.getElementsByName("quoteuser_color")[0].value = color;
			}
			//-->
			</script>~,
			name => 'quoteuser_color',
			validate => 'text',
			depends_on => ['enable_quoteuser', 'enable_quickreply'],
		},
		{
			description => qq~<label for="enable_quickjump">$qrb_txt{'7'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_quickjump" id="enable_quickjump" value="1"${ischecked($enable_quickjump)} />~,
			name => 'enable_quickjump',
			validate => 'boolean',
			depends_on => ['enable_quickpost||', 'enable_quickreply||'],
		},
		{
			description => qq~<label for="quick_quotelength">$qrb_txt{'8'}</label>~,
			input_html => qq~<input type="text" size="5" name="quick_quotelength" id="quick_quotelength" value="$quick_quotelength" />~,
			name => 'quick_quotelength',
			validate => 'number',
			depends_on => ['enable_quickjump', 'enable_quickreply'],
		},
	],
},
{
	name  => $settings_txt{'user'},
	id    => 'user',
	items => [
		{
			header => $settings_txt{'guest'},
		},
		{
			description => qq~<label for="guestaccess">$admin_txt{'632'}</label>~,
			input_html => qq~<input type="checkbox" name="guestaccess" id="guestaccess" value="1"${ischecked(!$guestaccess)} />~,
			name => 'guestaccess',
			validate => 'boolean',
		},
		{
			description => qq~<label for="enable_guestposting">$admin_txt{'380'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_guestposting" id="enable_guestposting" value="1"${ischecked($enable_guestposting)} />~,
			name => 'enable_guestposting',
			validate => 'boolean',
		},
		{
			description => qq~<label for="enable_guestlanguage">$admin_txt{'guestlang'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_guestlanguage" id="enable_guestlanguage" value="1"${ischecked($enable_guestlanguage)} />~,
			name => 'enable_guestlanguage',
			validate => 'boolean',
		},
		{
			description => qq~<label for="guest_media_disallowed">$admin_txt{'guestmedia'}</label>~,
			input_html => qq~<input type="checkbox" name="guest_media_disallowed" id="guest_media_disallowed" value="1"${ischecked($guest_media_disallowed)} />~,
			name => 'guest_media_disallowed',
			validate => 'boolean',
		},
		{
			header => $settings_txt{'profile'},
		},
		{
			description => qq~<label for="allowpics">$admin_txt{'746'}</label>~,
			input_html => qq~<input type="checkbox" name="allowpics" id="allowpics" value="1"${ischecked($allowpics)} />~,
			name => 'allowpics',
			validate => 'boolean',
		},
		{
			description => qq~<label for="upload_useravatar">$admin_txt{'747'}</label>~,
			input_html => qq~<input type="checkbox" name="upload_useravatar" id="upload_useravatar" value="1"${ischecked($upload_useravatar)} />~,
			name => 'upload_useravatar',
			validate => 'boolean',
			depends_on => ['allowpics'],
		},
		{
			description => $admin_txt{'747a'},
			input_html => qq~$facesdir/UserAvatars<br />~ . ((-w "$facesdir/UserAvatars" && -d "$facesdir/UserAvatars") ? qq~<span style="color: green;">$admin_txt{'163'}</span>~ : qq~<span style="color: red;">$admin_txt{'164'}</span>~), # Non-changable setting
		},
		{
			description => qq~<label for="upload_avatargroup">$admin_txt{'748'}</label>~,
			input_html => qq~<select multiple="multiple" name="upload_avatargroup" id="upload_avatargroup" size="8">~ . &DrawPerms($upload_avatargroup, 0) . qq~</select>~,
			name => 'upload_avatargroup',
			validate => 'text,null',
			depends_on => ['allowpics','upload_useravatar'],
		},
		{
			description => qq~<label for="avatar_limit">$admin_txt{'749'}</label>~,
			input_html => qq~<input type="text" name="avatar_limit" id="avatar_limit" size="5" value="$avatar_limit" /> KB~,
			name => 'avatar_limit',
			validate => 'number',
			depends_on => ['allowpics','upload_useravatar'],
		},
		{
			description => qq~<label for="avatar_dirlimit">$admin_txt{'750'}</label>~,
			input_html => qq~<input type="text" name="avatar_dirlimit" id="avatar_dirlimit" size="5" value="$avatar_dirlimit" /> KB~,
			name => 'avatar_dirlimit',
			validate => 'number',
			depends_on => ['allowpics','upload_useravatar'],
		},
		{
			description => qq~<label for="enable_notifications_N">$admin_txt{'381'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_notifications_N" id="enable_notifications_N" value="1"${ischecked((($enable_notifications == 1 || $enable_notifications == 3) ? 1 : 0))} />~,
			name => 'enable_notifications_N',
			validate => 'boolean',
		},
		{
			description => qq~<label for="NewNotificationAlert">$imtxt{'NewNotificationAlert'}</label>~,
			input_html => qq~<input type="checkbox" name="NewNotificationAlert" id="NewNotificationAlert" value="1"${ischecked($NewNotificationAlert)} />~,
			name => 'NewNotificationAlert',
			validate => 'boolean',
		},
		{
			description => qq~<label for="allow_hide_email">$admin_txt{'723'}</label>~,
			input_html => qq~<input type="checkbox" name="allow_hide_email" id="allow_hide_email" value="1"${ischecked($allow_hide_email)} />~,
			name => 'allow_hide_email',
			validate => 'boolean',
		},
		{
			description => qq~<label for="user_hide_avatars">$admin_txt{'751'}</label>~,
			input_html => qq~<input type="checkbox" name="user_hide_avatars" id="user_hide_avatars" value="1"${ischecked((($user_hide_avatars && $showuserpic && $allowpics) ? 1 : 0))} />~,
			name => 'user_hide_avatars',
			validate => 'boolean',
			depends_on => ['showuserpic','allowpics'],
		},
		{
			description => qq~<label for="user_hide_user_text">$admin_txt{'752'}</label>~,
			input_html => qq~<input type="checkbox" name="user_hide_user_text" id="user_hide_user_text" value="1"${ischecked((($user_hide_user_text && $showusertext) ? 1 : 0))} />~,
			name => 'user_hide_user_text',
			validate => 'boolean',
			depends_on => ['showusertext'],
		},
		{
			description => qq~<label for="user_hide_attach_img">$admin_txt{'753'}</label>~,
			input_html => qq~<input type="checkbox" name="user_hide_attach_img" id="user_hide_attach_img" value="1"${ischecked($user_hide_attach_img)}~ . ($allowattach ? '' : ' disabled="disabled"') . qq~ />~,
			name => 'user_hide_attach_img',
			validate => 'boolean',
		},
		{
			description => qq~<label for="user_hide_signat">$admin_txt{'754'}</label>~,
			input_html => qq~<input type="checkbox" name="user_hide_signat" id="user_hide_signat" value="1"${ischecked($user_hide_signat)} />~,
			name => 'user_hide_signat',
			validate => 'boolean',
		},
		{
			description => qq~<label for="user_hide_smilies_row">$admin_txt{'755'}</label>~,
			input_html => qq~<input type="checkbox" name="user_hide_smilies_row" id="user_hide_smilies_row" value="1"${ischecked((($user_hide_smilies_row && !$removenormalsmilies) ? 1 : 0))}~ . ($removenormalsmilies ? ' disabled="disabled"' : '') . qq~ />~,
			name => 'user_hide_smilies_row',
			validate => 'boolean',
		},
		{
			description => qq~<label for="buddyListEnabled">$admin_txt{'buddylist'}</label>~,
			input_html => qq~<input type="checkbox" name="buddyListEnabled" id="buddyListEnabled" value="1"${ischecked($buddyListEnabled)} />~,
			name => 'buddyListEnabled',
			validate => 'boolean',
		},
		{
			description => qq~<label for="defaultusertxt">$admin_txt{'385a'}</label>~,
			input_html => qq~<input type="text" name="defaultusertxt" id="defaultusertxt" value="$defaultusertxt" />~,
			name => 'defaultusertxt',
			validate => 'text,null',
		},
		{
			description => qq~<label for="MaxSigLen">$admin_txt{'689'}</label>~,
			input_html => qq~<input type="text" name="MaxSigLen" id="MaxSigLen" size="5" value="$MaxSigLen" />~,
			name => 'MaxSigLen',
			validate => 'number,null',
		},
		{
			description => qq~<label for="maxfavs">$admin_txt{'101'}</label>~,
			input_html => qq~<input type="text" name="maxfavs" id="maxfavs" size="5" value="$maxfavs" />~,
			name => 'maxfavs',
			validate => 'number',
		},
		{
			description => qq~<label for="emailnewpass">$admin_txt{'639'}</label>~,
			input_html => qq~<input type="checkbox" name="emailnewpass" id="emailnewpass" value="1"${ischecked($emailnewpass)} />~,
			name => 'emailnewpass',
			validate => 'boolean',
		},
		{
			description => qq~<label for="addmemgroup_enabled">$amgtxt{'84'}</label>~,
			input_html => qq~
				<select name="addmemgroup_enabled" id="addmemgroup_enabled">
				  <option value="0"${isselected($addmemgroup_enabled == 0)}>$amgtxt{'85'}</option>
				  <option value="1"${isselected($addmemgroup_enabled == 1)}>$amgtxt{'86'}</option>
				  <option value="2"${isselected($addmemgroup_enabled == 2)}>$amgtxt{'87'}</option>
				  <option value="3"${isselected($addmemgroup_enabled == 3)}>$amgtxt{'88'}</option>
				</select>~,
			name => 'addmemgroup_enabled',
			validate => 'number',
		},
		{
			description => qq~<label for="extendedprofiles">$admin_txt{'extendedprofiles'}</label>~,
			input_html => qq~<input type="checkbox" name="extendedprofiles" id="extendedprofiles" value="1" ${ischecked($extendedprofiles)}/>~,
			name => 'extendedprofiles',
			validate => 'boolean',
		},
		{
			header => $settings_txt{'login'},
		},
		{
			description => qq~<label for="Cookie_Length">$admin_txt{'432'}</label>~,
			input_html => qq~
<select name="Cookie_Length" id="Cookie_Length">
  <option value="2" ${isselected($Cookie_Length == 2)}>$admin_txt{'497d'}</option>
  <option value="1" ${isselected($Cookie_Length == 1)}>$admin_txt{'497c'}</option>
  <option value="60" ${isselected($Cookie_Length == 60)}>1 $admin_txt{'497a'}</option>
  <option value="180" ${isselected($Cookie_Length == 180)}>3 $admin_txt{'497b'}</option>
  <option value="360" ${isselected($Cookie_Length == 360)}>6 $admin_txt{'497b'}</option>
  <option value="480" ${isselected($Cookie_Length == 480)}>8 $admin_txt{'497b'}</option>
  <option value="600" ${isselected($Cookie_Length == 600)}>10 $admin_txt{'497b'}</option>
  <option value="720" ${isselected($Cookie_Length == 720)}>12 $admin_txt{'497b'}</option>
  <option value="1440" ${isselected($Cookie_Length == 1440)}>24 $admin_txt{'497b'}</option>
</select>~,
			name => 'Cookie_Length',
			validate => 'number',
		},
		{
			description => qq~<label for="cookieusername">$admin_txt{'352'}</label>~,
			input_html => qq~<input type="text" name="cookieusername" id="cookieusername" size="20" value="$cookieusername" />~,
			name => 'cookieusername',
			validate => 'text',
		},
		{
			description => qq~<label for="cookiepassword">$admin_txt{'353'}</label>~,
			input_html => qq~<input type="text" name="cookiepassword" id="cookiepassword" size="20" value="$cookiepassword" />~,
			name => 'cookiepassword',
			validate => 'text',
		},
		{
			description => qq~<label for="cookiesession_name">$admin_txt{'353a'}</label>~,
			input_html => qq~<input type="text" name="cookiesession_name" id="cookiesession_name" size="20" value="$cookiesession_name" />~,
			name => 'cookiesession_name',
			validate => 'text',
		},
		{
			header => $settings_txt{'registration'},
		},
		{
			description => qq~<label for="regtype">$rtype_text{'4'}</label>~,
			input_html => qq~
			<select name="regtype" id="regtype" size="1">
			  <option value="0" ${isselected($regtype == 0)}>$rtype_text{'0'}</option>
			  <option value="1" ${isselected($regtype == 1)}>$rtype_text{'1'}</option>
			  <option value="2" ${isselected($regtype == 2)}>$rtype_text{'2'}</option>
			  <option value="3" ${isselected($regtype == 3)}>$rtype_text{'3'}</option>
			</select>~,
			name => 'regtype',
			validate => 'number',
		},
		{
			description => qq~<label for="preregspan">$prereg_txt{'11'}</label>~,
			input_html => qq~<input type="text" name="preregspan" id="preregspan" size="5" value="$preregspan" />~,
			name => 'preregspan',
			validate => 'number',
			depends_on => ['regtype!=0', 'regtype!=3'],
		},
		{
			description => qq~<label for="emailpassword">$admin_txt{'702'}</label>~,
			input_html => qq~<input type="checkbox" name="emailpassword" id="emailpassword" value="1"${ischecked($emailpassword)} />~,
			name => 'emailpassword',
			validate => 'boolean',
		},
		{
			description => qq~<label for="emailwelcome">$admin_txt{'619'}</label>~,
			input_html => qq~<input type="checkbox" name="emailwelcome" id="emailwelcome" value="1"${ischecked($emailwelcome)} />~,
			name => 'emailwelcome',
			validate => 'boolean',
			depends_on => ['!emailpassword'],
		},
		{
			description => qq~<label for="name_cannot_be_userid">$register_txt{'768'}</label>~,
			input_html => qq~<input type="checkbox" name="name_cannot_be_userid" id="name_cannot_be_userid" value="1"${ischecked($name_cannot_be_userid)} />~,
			name => 'name_cannot_be_userid',
			validate => 'boolean',
		},
		{
			description => qq~<label for="cannot_change_displayname">$register_txt{'769'}</label>~,
			input_html => qq~<input type="checkbox" name="cannot_change_displayname" id="cannot_change_displayname" value="1"${ischecked($cannot_change_displayname)} />~,
			name => 'cannot_change_displayname',
			validate => 'boolean',
		},
		{
			description => qq~<label for="birthday_on_reg">$register_txt{'770'}</label>~,
			input_html => qq~
			<select name="birthday_on_reg" id="birthday_on_reg" size="1">
			  <option value="0">$register_txt{'771'}</option>
			  <option value="1"${isselected($birthday_on_reg == 1)}>$register_txt{'772'}</option>
			  <option value="2"${isselected($birthday_on_reg == 2)}>$register_txt{'773'}</option>
			</select>~,
			name => 'birthday_on_reg',
			validate => 'number,null',
		},
		{
			description => qq~<label for="gender_on_reg">$register_txt{'gender_reg'}</label>~,
			input_html => qq~
			<select name="gender_on_reg" id="gender_on_reg" size="1">
			  <option value="0">$register_txt{'771'}</option>
			  <option value="1"${isselected($gender_on_reg == 1)}>$register_txt{'gender_reg_opt'}</option>
			  <option value="2"${isselected($gender_on_reg == 2)}>$register_txt{'gender_reg_req'}</option>
			</select>~,
			name => 'gender_on_reg',
			validate => 'number,null',
		},
		{
			description => qq~<label for="pwstrengthmeter_scores">$admin_txt{'710'}</label>~,
			input_html => qq~<input type="text" name="pwstrengthmeter_scores" id="pwstrengthmeter_scores" size="20" value="$pwstrengthmeter_scores" />~,
			name => 'pwstrengthmeter_scores',
			validate => 'text',
		},
		{
			description => qq~<label for="pwstrengthmeter_common">$admin_txt{'711'}</label>~,
			input_html => qq~<input type="text" name="pwstrengthmeter_common" id="pwstrengthmeter_common" size="20" value='$pwstrengthmeter_common' />~,
			name => 'pwstrengthmeter_common',
			validate => 'text',
		},
		{
			description => qq~<label for="pwstrengthmeter_minchar">$admin_txt{'712'}</label>~,
			input_html => qq~<input type="text" name="pwstrengthmeter_minchar" id="pwstrengthmeter_minchar" size="5" value="$pwstrengthmeter_minchar" />~,
			name => 'pwstrengthmeter_minchar',
			validate => 'number',
		},
		{
			description => qq~<label for="RegReasonSymbols">$admin_txt{'regreason'}</label>~,
			input_html => qq~<input type="text" name="RegReasonSymbols" id="RegReasonSymbols" size="5" value="$RegReasonSymbols" />~,
			name => 'RegReasonSymbols',
			validate => 'number',
			depends_on => ['regtype==1'],
		},
		{
			description => qq~<label for="RegAgree">$admin_txt{'584'}</label>~,
			input_html => qq~<input type="checkbox" name="RegAgree" id="RegAgree" value="1"${ischecked($RegAgree)} />~,
			name => 'RegAgree',
			validate => 'boolean',
			depends_on => ['regtype!=0'],
		},
		{
			description => qq~<label for="allow_self_del">$admin_txt{'586'}</label>~,
			input_html => qq~<input type="checkbox" name="allow_self_del" id="allow_self_del" value="1"${ischecked($allow_self_del)} />~,
			name => 'allow_self_del',
			validate => 'boolean',
		},
		{
			header => $settings_txt{'memberlist'},
		},
		{
			description => qq~<label for="ML_Allowed">$admin_txt{'mlview'}</label>~,
			input_html => qq~
<select name="ML_Allowed" id="ML_Allowed">
  <option value="0" ${isselected($ML_Allowed == 0)}>$userlevel_txt{'all'}</option>
  <option value="1" ${isselected($ML_Allowed == 1)}>$userlevel_txt{'members'}</option>
  <option value="2" ${isselected($ML_Allowed == 2)}>$userlevel_txt{'modgmodadmin'}</option>
  <option value="3" ${isselected($ML_Allowed == 3)}>$userlevel_txt{'gmodadmin'}</option>
</select>~,
			name => 'ML_Allowed',
			validate => 'number',
		},
		{
			description => qq~<label for="defaultml">$admin_txt{'912'}</label>~,
			input_html => qq~
<select name="defaultml" id="defaultml">
  <option value="username" ${isselected($defaultml eq 'username')}>$admin_txt{'914'}</option>
  <option value="position" ${isselected($defaultml eq 'position')}>$admin_txt{'911'}</option>
  <option value="posts"    ${isselected($defaultml eq 'posts')   }>$admin_txt{'910'}</option>
  <option value="regdate"  ${isselected($defaultml eq 'regdate') }>$admin_txt{'909'}</option>
</select>~,
			name => 'defaultml',
			validate => 'text',
		},
		{
			description => qq~<label for="TopAmmount">$admin_txt{'373'}</label>~,
			input_html => qq~<input type="text" size="5" name="TopAmmount" id="TopAmmount" value="$TopAmmount" />~,
			name => 'TopAmmount',
			validate => 'number',
		},
		{
			description => qq~<label for="barmaxnumb">$admin_txt{'902'} $admin_txt{'107'}</label>~,
			input_html => qq~<input type="text" name="barmaxnumb" id="barmaxnumb" size="5" value="$barmaxnumb" /> $admin_txt{'904'} <input type="radio" name="barmaxdepend" value="0"${ischecked(!$barmaxdepend)}/> $admin_txt{'905'} <input type="radio" name="barmaxdepend" value="1"${ischecked($barmaxdepend)}/> $admin_txt{'903'}~,
			name => 'barmaxdepend',
			validate => 'boolean',
		},
	]
},
{
	name  => $settings_txt{'staff'},
	id    => 'staff',
	items => [
		{
			header => $settings_txt{'staff'},
		},
		# Multi-delete/multi-admin
		{
			description => qq~<label for="mdadmin">$mdintxt{'1'} $admin_txt{'684'}?</label>~,
			input_html => qq~<input type="checkbox" name="mdadmin" id="mdadmin" value="1"${ischecked($mdadmin)} />~,
			name => 'mdadmin',
			validate => 'boolean',
		},
		{
			description => qq~<label for="mdglobal">$mdintxt{'1'} $admin_txt{'684a'}?</label>~,
			input_html => qq~<input type="checkbox" name="mdglobal" id="mdglobal" value="1"${ischecked($mdglobal)} />~,
			name => 'mdglobal',
			validate => 'boolean',
		},
		{
			description => qq~<label for="mdmod">$mdintxt{'1'} $admin_txt{'63'}?</label>~,
			input_html => qq~<input type="checkbox" name="mdmod" id="mdmod" value="1"${ischecked($mdmod)} />~,
			name => 'mdmod',
			validate => 'boolean',
		},
		{
			description => qq~<label for="adminbin">$mdintxt{'4'}</label>~,
			input_html => qq~<input type="checkbox" name="adminbin" id="adminbin" value="1"${ischecked($adminbin)} />~,
			name => 'adminbin',
			validate => 'boolean',
		},
		{
			description => qq~<label for="adminview">$matxt{'5'}</label>~,
			input_html => qq~
<select name="adminview" id="adminview" size="1">
  <option value="0" ${isselected($adminview == 0)}>$matxt{'1'}</option>
  <option value="1" ${isselected($adminview == 1)}>$matxt{'2'}</option>
  <option value="2" ${isselected($adminview == 2)}>$matxt{'3'}</option>
  <option value="3" ${isselected($adminview == 3)}>$matxt{'4'}</option>
</select>~,
			name => 'adminview',
			validate => 'number',
		},
		{
			description => qq~<label for="gmodview">$matxt{'6'}</label>~,
			input_html => qq~
<select name="gmodview" id="gmodview" size="1">
  <option value="0" ${isselected($gmodview == 0)}>$matxt{'1'}</option>
  <option value="1" ${isselected($gmodview == 1)}>$matxt{'2'}</option>
  <option value="2" ${isselected($gmodview == 2)}>$matxt{'3'}</option>
  <option value="3" ${isselected($gmodview == 3)}>$matxt{'4'}</option>
</select>~,
			name => 'gmodview',
			validate => 'number',
		},
		{
			description => qq~<label for="modview">$matxt{'7'}</label>~,
			input_html => qq~
<select name="modview" id="modview" size="1">
  <option value="0" ${isselected($modview == 0)}>$matxt{'1'}</option>
  <option value="1" ${isselected($modview == 1)}>$matxt{'2'}</option>
  <option value="2" ${isselected($modview == 2)}>$matxt{'3'}</option>
  <option value="3" ${isselected($modview == 3)}>$matxt{'4'}</option>
</select>~,
			name => 'modview',
			validate => 'number',
		},
		{
			description => qq~<label for="enable_MCstatusStealth">$admin_txt{'stealth'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_MCstatusStealth" id="enable_MCstatusStealth" value="1"${ischecked($enable_MCstatusStealth)}/>~,
			name => 'enable_MCstatusStealth',
			validate => 'boolean',
		},
		{
			description => qq~<label for="bypass_lock_perm">$bypassLock_txt{'allow'}</label>~,
			input_html => qq~
<select name="bypass_lock_perm" id="bypass_lock_perm" size="1">
  <option value="0" ${isselected($bypass_lock_perm eq '0')}>$userlevel_txt{'none'}</option>
  <option value="mod" ${isselected($bypass_lock_perm eq 'mod')}>$userlevel_txt{'modgmodadmin'}</option>
  <option value="gmod" ${isselected($bypass_lock_perm eq 'gmod')}>$userlevel_txt{'gmodadmin'}</option>
  <option value="fa" ${isselected($bypass_lock_perm eq 'fa')}>$userlevel_txt{'admin'}</option>
</select>~,
			name => 'bypass_lock_perm',
			validate => 'text',
		},
	],
},
{
	name  => $settings_txt{'privatemessage'},
	id    => 'privatemessage',
	items => [
		{
			header => $settings_txt{'pmgeneral'},
		},
		{
			description => qq~<label for="PM_level">$imtxt{'enablePM'}</label>~,
			input_html => qq~
<select name="PM_level" id="PM_level">
  <option value="0" ${isselected($PM_level == 0)}>$userlevel_txt{'none'}</option>
  <option value="1" ${isselected($PM_level == 1)}>$userlevel_txt{'members'}</option>
  <option value="2" ${isselected($PM_level == 2)}>$userlevel_txt{'modgmodadmin'}</option>
  <option value="3" ${isselected($PM_level == 3)}>$userlevel_txt{'gmodadmin'}</option>
</select>~,
			name => 'PM_level',
			validate => 'number',
		},
		{
			description => qq~<label for="numposts">$imtxt{'75'}</label>~,
			input_html => qq~<input type="text" name="numposts" id="numposts" size="5" value="$numposts" />~,
			name => 'numposts',
			validate => 'number',
			depends_on => ['PM_level!=0'],
		},
		{
			description => qq~<label for="imspam">$imtxt{'52'}</label>~,
			input_html => qq~<input type="text" name="imspam" id="imspam" size="5" value="$imspam" />~,
			name => 'imspam',
			validate => 'number,null',
			depends_on => ['PM_level!=0'],
		},
		{
			description => qq~<label for="enable_PMsearch">$imtxt{'enable_PMsearch'}</label>~,
			input_html => qq~<input type="text" name="enable_PMsearch" id="enable_PMsearch" size="5" value="$enable_PMsearch" />~,
			name => 'enable_PMsearch',
			validate => 'number,null',
			depends_on => ['PM_level!=0'],
		},
		{
			description => qq~<label for="send_welcomeim">$imtxt{'33'}</label>~,
			input_html => qq~<input type="checkbox" name="send_welcomeim" id="send_welcomeim" value="1"${ischecked($send_welcomeim)} />~,
			name => 'send_welcomeim',
			validate => 'boolean',
			depends_on => ['PM_level!=0'],
		},
		{
			description => qq~<label for="sendname">$imtxt{'34'}</label>~,
			input_html => qq~<input type="text" name="sendname" id="sendname" size="35" value="$sendname" />~,
			name => 'sendname',
			validate => 'text,null',
			depends_on => ['PM_level!=0', 'send_welcomeim'],
		},
		{
			description => qq~<label for="imsubject">$imtxt{'36'}</label>~,
			input_html => qq~<input type="text" name="imsubject" id="imsubject" size="35" value="$imsubject" />~,
			name => 'imsubject',
			validate => 'text,null',
			depends_on => ['PM_level!=0', 'send_welcomeim'],
		},
		{
			description => qq~<label for="imtext">$imtxt{'35'}</label>~,
			input_html => qq~<textarea name="imtext" id="imtext" cols="35" rows="5">$imtext</textarea>~,
			name => 'imtext',
			validate => 'fulltext,null',
			depends_on => ['PM_level!=0', 'send_welcomeim'],
		},
		{
			header => $settings_txt{'bmessages'},
		},
		{
			description => qq~<label for="PMenableBm_level">$imtxt{'87'}</label>~,
			input_html => qq~
<select name="PMenableBm_level" id="PMenableBm_level">
  <option value="0" ${isselected($PMenableBm_level == 0)}>$userlevel_txt{'none'}</option>
  <option value="1" ${isselected($PMenableBm_level == 1)}>$userlevel_txt{'modgmodadmin'}</option>
  <option value="2" ${isselected($PMenableBm_level == 2)}>$userlevel_txt{'gmodadmin'}</option>
  <option value="3" ${isselected($PMenableBm_level == 3)}>$userlevel_txt{'admin'}</option>
</select>~,
			name => 'PMenableBm_level',
			validate => 'number',
			depends_on => ['PM_level!=0'],
		},
		{
			description => qq~<label for="PMenableGuestButton">$imtxt{'88'}</label>~,
			input_html => qq~<input type="checkbox" name="PMenableGuestButton" id="PMenableGuestButton" value="1"${ischecked($PMenableGuestButton)} />~,
			name => 'PMenableGuestButton',
			validate => 'boolean',
			depends_on => ['PMenableBm_level!=0', 'PM_level!=0'],
		},
		{
			description => qq~<label for="PMenableAlertButton">$imtxt{'89'}</label>~,
			input_html => qq~<input type="checkbox" name="PMenableAlertButton" id="PMenableAlertButton" value="1"${ischecked($PMenableAlertButton)} />~,
			name => 'PMenableAlertButton',
			validate => 'boolean',
			depends_on => ['PMenableBm_level!=0', 'PM_level!=0'],
		},
		{
			description => qq~<label for="PMAlertButtonGuests">$imtxt{'90'}</label>~,
			input_html => qq~<input type="checkbox" name="PMAlertButtonGuests" id="PMAlertButtonGuests" value="1"${ischecked($PMAlertButtonGuests)} />~,
			name => 'PMAlertButtonGuests',
			validate => 'boolean',
			depends_on => ['PMenableBm_level!=0', 'PMenableAlertButton', 'PM_level!=0'],
		},


		{
			header => $settings_txt{'members'},
		},
		{
			description => qq~<label for="enable_imlimit">$imtxt{'06'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_imlimit" id="enable_imlimit" value="1"${ischecked($enable_imlimit)} />~,
			name => 'enable_imlimit',
			validate => 'boolean',
			depends_on => ['PM_level!=0'],
		},
		{
			description => qq~<label for="numobox">$imtxt{'03'} $imtxt{'85'}</label>~,
			input_html => qq~<input type="text" name="numobox" id="numobox" size="5" value="$numobox" />~,
			name => 'numobox',
			validate => 'number,null',
			depends_on => ['enable_imlimit', 'PM_level!=0'],
		},
		{
			description => qq~<label for="numibox">$imtxt{'03'} $imtxt{'84'}</label>~,
			input_html => qq~<input type="text" name="numibox" id="numibox" size="5" value="$numibox" />~,
			name => 'numibox',
			validate => 'number,null',
			depends_on => ['enable_imlimit', 'PM_level!=0'],
			 
		},
		{
			description => qq~<label for="numstore">$imtxt{'03'} $imtxt{'46'}</label>~,
			input_html => qq~<input type="text" name="numstore" id="numstore" size="5" value="$numstore" />~,
			name => 'numstore',
			validate => 'number,null',
			depends_on => ['enable_imlimit', 'PM_level!=0'],
		},
		{
			description => qq~<label for="numdraft">$imtxt{'03'} $imtxt{'draft'}</label>~,
			input_html => qq~<input type="text" name="numdraft" id="numdraft" size="5" value="$numdraft" />~,
			name => 'numdraft',
			validate => 'number,null',
			depends_on => ['enable_imlimit', 'PM_level!=0'],
		},
		{
			description => qq~<label for="PMenable_cc">$imtxt{'allowcc'}</label>~,
			input_html => qq~<input type="checkbox" name="PMenable_cc" id="PMenable_cc" value="1"${ischecked($PMenable_cc)} />~,
			name => 'PMenable_cc',
			validate => 'boolean',
			depends_on => ['PM_level!=0'],
		 
		},
		{
			description => qq~<label for="PMenable_bcc">$imtxt{'allowbcc'}</label>~,
			input_html => qq~<input type="checkbox" name="PMenable_bcc" id="PMenable_bcc" value="1"${ischecked($PMenable_bcc)} />~,
			name => 'PMenable_bcc',
			validate => 'boolean',
			depends_on => ['PM_level!=0'],
		},
		{
			description => qq~<label for="enable_notifications_PM">$imtxt{'381'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_notifications_PM" id="enable_notifications_PM" value="1"${ischecked((($enable_notifications == 2 || $enable_notifications == 3) ? 1 : 0))} />~,
			name => 'enable_notifications_PM',
			validate => 'boolean',
			depends_on => ['PM_level!=0'],
		},
		{
			description => qq~<label for="enable_storefolders">$imtxt{'extrastore'}</label>~,
			input_html => qq~<input type="text" name="enable_storefolders" id="enable_storefolders" size="5" value="$enable_storefolders" />~,
			name => 'enable_storefolders',
			validate => 'number,null',
			depends_on => ['PM_level!=0'],
		},
		{
			description => qq~<label for="enable_PMcontrols">$imtxt{'enablecontrols'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_PMcontrols" id="enable_PMcontrols" value="1"${ischecked($enable_PMcontrols)} />~,
			name => 'enable_PMcontrols',
			validate => 'boolean',
			depends_on => ['PM_level!=0'],
		},
		{
			description => qq~<label for="enable_PMprev">$imtxt{'enable_PMprev'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_PMprev" id="enable_PMprev" value="1"${ischecked($enable_PMprev)} />~,
			name => 'enable_PMprev',
			validate => 'boolean',
			depends_on => ['!enable_PMcontrols', 'PM_level!=0'],
		},
		{
			description => qq~<label for="enable_PMActprev">$imtxt{'enable_PMActprev'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_PMActprev" id="enable_PMActprev" value="1"${ischecked($enable_PMActprev)} />~,
			name => 'enable_PMActprev',
			validate => 'boolean',
			depends_on => ['!enable_PMcontrols', 'PM_level!=0'],
		},
		{
			description => qq~<label for="enable_PMviewMess">$imtxt{'enable_PMviewMess'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_PMviewMess" id="enable_PMviewMess" value="1"${ischecked($enable_PMviewMess)} />~,
			name => 'enable_PMviewMess',
			validate => 'boolean',
			depends_on => ['!enable_PMcontrols', 'PM_level!=0'],
		},


		{
			header => $settings_txt{'mycenter'},
		},
		{
			description => qq~<label for="enable_MCaway">$imtxt{'away'}</label>~,
			input_html => qq~
<select name="enable_MCaway" id="enable_MCaway">
  <option value="0" ${isselected($enable_MCaway == 0)}>$userlevel_txt{'none'}</option>
  <option value="1" ${isselected($enable_MCaway == 1)}>$userlevel_txt{'staff'}</option>
  <option value="2" ${isselected($enable_MCaway == 2)}>$userlevel_txt{'staffall'}</option>
  <option value="3" ${isselected($enable_MCaway == 3)}>$userlevel_txt{'members'}</option>
</select><br />~,
			name => 'enable_MCaway',
			validate => 'number',
			depends_on => ['PM_level!=0'],
		},
		{
			description => qq~<label for="MaxAwayLen">$admin_txt{'689a'}</label>~,
			input_html => qq~<input type="text" name="MaxAwayLen" id="MaxAwayLen" size="5" value="$MaxAwayLen" />~,
			name => 'MaxAwayLen',
			validate => 'number,null',
			depends_on => ['enable_MCaway!=0', 'PM_level!=0'],
		},
	],
},
);

# Routine to save them
sub SaveSettings {
	my %settings = @_;

	# Validate forum_start stuff
	foreach (qw(forumstart_month forumstart_day forumstart_year forumstart_hour forumstart_minute forumstart_secund)) {
		$FORM{$_} =~ s/\D//g;
	}
	my $forumstart_month  = $FORM{'forumstart_month'};
	my $forumstart_day    = $FORM{'forumstart_day'};
	my $forumstart_year   = $FORM{'forumstart_year'};
	my $forumstart_hour   = $FORM{'forumstart_hour'};
	my $forumstart_minute = $FORM{'forumstart_minute'};
	my $forumstart_secund = $FORM{'forumstart_secund'};
	my $max_days = 31;
	if($forumstart_month == 4 || $forumstart_month == 6 || $forumstart_month == 9 || $forumstart_month == 11) {
		$max_days = 30;
	} elsif($forumstart_month == 2 && $forumstart_year % 4 == 0 && $forumstart_year != 0) {
		$max_days = 29;
	} elsif($forumstart_month == 2 && ($forumstart_year % 4 != 0 || $forumstart_year == 0)) {
		$max_days = 28;
	}
	$forumstart_day = $max_days if $forumstart_day > $max_days;
	$forumstart = qq~$forumstart_month/$forumstart_day/$forumstart_year $maintxt{'107'} $forumstart_hour:$forumstart_minute:$forumstart_secund~;

	# Validate Timezone
	$timeoffset  = $FORM{'usertimesign'} =~ /^-$/ ? '-' : '';
	$timeoffset .= $FORM{'usertimehour'} =~ /^\d+$/ ? $FORM{'usertimehour'} : '0';
	$timeoffset .= '.';
	$timeoffset .= $FORM{'usertimemin'}  =~ /^\d+$/ ? $FORM{'usertimemin'} : '0';

	# Get barmaxnumb
	$settings{'barmaxnumb'} = $FORM{'barmaxnumb'};
	$settings{'barmaxnumb'} =~ s/\D//g;

	# Fix guestaccess
	$settings{'guestaccess'} = !$settings{'guestaccess'} || 0;
	$settings{'imtext'} =~ s/\r(?=\n*)//g;
	$settings{'imtext'} =~ s~\n~<br />~g;

	# Fix $pwstrengthmeter_common
	$settings{'pwstrengthmeter_common'} =~ s/'//g;

	# Convert unwanted tags in Board Name
	&ToHTML($settings{'mbname'});

	# Settings.pl stuff
	&SaveSettingsTo('Settings.pl', %settings);
}

1;