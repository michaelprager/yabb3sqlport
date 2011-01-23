###############################################################################
# EventCalSet.pl                                                              #
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

$eventcalsetplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('EventCal');

eval { require "$vardir/eventcalset.txt"; };
if ($Show_EventCal eq '') { &EventCalSet2; }

## Calendar Setting ##

sub EventCalSet {
	&is_admin_or_gmod;
	my ($caleventprivatechecked);

	# figure out what to print
	my $status_calendar = "red1.gif";
	my $status_bdlist = "red1.gif";

	if    (!$Scroll_Events)           { $aevt1  = ' selected="selected"'; }
	elsif ($Scroll_Events == 1)       { $aevt2  = ' selected="selected"'; }
	elsif ($Scroll_Events == 2)       { $aevt3  = ' selected="selected"'; }
	elsif ($Scroll_Events == 3)       { $aevt4  = ' selected="selected"'; }

	if    (!$Show_EventCal)           { $bevt1  = ' selected="selected"'; }
	elsif ($Show_EventCal == 1)       { $bevt2  = ' selected="selected"'; $status_calendar = "green1.gif"; }
	elsif ($Show_EventCal == 2)       { $bevt3  = ' selected="selected"'; $status_calendar = "green1.gif"; }

	if    (!$Show_EventButton)        { $cevt1  = ' selected="selected"'; }
	elsif ($Show_EventButton == 1)    { $cevt2  = ' selected="selected"'; }
	elsif ($Show_EventButton == 2)    { $cevt3  = ' selected="selected"'; }

	if    (!$Show_BirthdaysList)      { $devt1  = ' selected="selected"'; }
	elsif ($Show_BirthdaysList == 1)  { $devt2  = ' selected="selected"'; $status_bdlist = "green1.gif"; }
	elsif ($Show_BirthdaysList == 2)  { $devt3  = ' selected="selected"'; $status_bdlist = "green1.gif"; }

	if    (!$Show_BirthdayButton)     { $eevt1  = ' selected="selected"'; }
	elsif ($Show_BirthdayButton == 1) { $eevt2  = ' selected="selected"'; }
	elsif ($Show_BirthdayButton == 2) { $eevt3  = ' selected="selected"'; }

	if    (!$Show_BirthdayDate)       { $fevt1  = ' selected="selected"'; }
	elsif ($Show_BirthdayDate == 1)   { $fevt2  = ' selected="selected"'; }
	elsif ($Show_BirthdayDate == 2)   { $fevt3  = ' selected="selected"'; }

	if    (!$Show_EventBirthdays)     { $gevt1  = ' selected="selected"'; }
	elsif ($Show_EventBirthdays == 1) { $gevt2  = ' selected="selected"'; }
	elsif ($Show_EventBirthdays == 2) { $gevt3  = ' selected="selected"'; }

	if    ($Show_BirthdaysList)       { $onbirthlistchecked = "checked='checked'" }
	if    ($Show_MiniCalIcons)        { $onminiiconchecked = "checked='checked'" }
	if    ($ShowSunday)               { $onsundaychecked = "checked='checked'" }
	if    ($CalEventPrivate)          { $caleventprivatechecked = "checked='checked'" }
	if    ($DisplayCalEvents)         { $dcaleventschecked = "checked='checked'" }
	if    ($Show_ColorLinks)          { $oncolorlinkschecked = "checked='checked'" }
	if    ($No_ShortUbbc)             { $onnosubbcchecked = "checked='checked'" }
	if    ($Show_BdColorLinks)        { $onbdcolorlinkschecked = "checked='checked'" }
	if    (!$Event_TodayColor)        { $Event_TodayColor = "#ff0000"; }
	else                              { $Event_TodayColor = lc($Event_TodayColor); }
	if    (!$Delete_EventsUntil)      { $Delete_EventsUntil = "0"; }

	if    (!$CalEventNoName)          { $noname1 = ' selected="selected"'; }
	elsif ($CalEventNoName == 1)      { $noname2 = ' selected="selected"'; }
	elsif ($CalEventNoName == 2)      { $noname3 = ' selected="selected"'; }

	require "$admindir/ManageBoards.pl";
	$CalEventPerms =~ s/,/, /g;
	$CalEventPerms = &DrawPerms($CalEventPerms);

	$yymain .= qq~
<form action="$adminurl?action=eventcal_set2" method="post">
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <colgroup>
       <col width="50%" />
       <col width="50%" />
     </colgroup>
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="2">
         <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$event_cal{'1'}</b>
       </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg" colspan="2"><span class="small">$event_cal{'21'}</span></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><img src="$defaultimagesdir/$status_calendar" alt="" /> <label for="Show_EventCal">$event_cal{'3'}</label></td>
       <td align="left" class="windowbg2">
		<select name="Show_EventCal" id="Show_EventCal" size="1">
		<option value="0"$bevt1>$event_cal{'11'}</option>
		<option value="1"$bevt2>$event_cal{'46'}</option>
		<option value="2"$bevt3>$event_cal{'47'}</option>
		</select>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="Show_EventButton">$event_cal{'4'}</label></td>
       <td align="left" class="windowbg2">
		<select name="Show_EventButton" id="Show_EventButton" size="1">
		<option value="0"$cevt1>$event_cal{'11'}</option>
		<option value="1"$cevt2>$event_cal{'46'}</option>
		<option value="2"$cevt3>$event_cal{'47'}</option>
		</select>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="Show_EventBirthdays">$event_cal{'5'}</label></td>
       <td align="left" class="windowbg2">
		<select name="Show_EventBirthdays" id="Show_EventBirthdays" size="1">
		<option value="0"$gevt1>$event_cal{'11'}</option>
		<option value="1"$gevt2>$event_cal{'46'}</option>
		<option value="2"$gevt3>$event_cal{'47'}</option>
		</select>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="ShowSunday">$event_cal{'36'}<br /><span class="small">$event_cal{'37'}</span></label></td>
       <td align="left" class="windowbg2"><input type="checkbox" name="ShowSunday" id="ShowSunday" $onsundaychecked /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="Event_TodayColor">$event_cal{'8'}</label></td>
       <td align="left" class="windowbg2">
		<input type="text" size="7" maxlength="7" name="Event_TodayColor" id="Event_TodayColor" value="$Event_TodayColor" onkeyup="previewColor(this.value);" /> <span id="Event_TodayColor2" style="background-color:$Event_TodayColor">&nbsp; &nbsp; &nbsp;</span> <img align="top" src="$defaultimagesdir/palette1.gif" style="cursor: pointer" onclick="window.open('$scripturl?action=palette;task=templ', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" alt="" border="0" />
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			function previewColor(color) {
				document.getElementById('Event_TodayColor2').style.background = color;
				document.getElementsByName("Event_TodayColor")[0].value = color;
			}
		//-->
		</script>
       </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg" colspan="2"><span class="small">$event_cal{'22'}</span></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="Show_MiniCalIcons">$event_cal{'43'}</label></td>
       <td align="left" class="windowbg2"><input type="checkbox" name="Show_MiniCalIcons" id="Show_MiniCalIcons" $onminiiconchecked /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="Show_ColorLinks">$event_cal{'44'}<br /><span class="small">$event_cal{'45'}</span></label></td>
       <td align="left" class="windowbg2"><input type="checkbox" name="Show_ColorLinks" id="Show_ColorLinks" $oncolorlinkschecked /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="Scroll_Events">$event_cal{'9'}<br /><span class="small">$event_cal{'10'}</span></label></td>
       <td align="left" class="windowbg2">
		<select name="Scroll_Events" id="Scroll_Events" size="1">
		<option value="0"$aevt1>$event_cal{'11'}</option>
		<option value="1"$aevt2>$event_cal{'12'} ($event_cal{'56'})</option>
		<option value="3"$aevt4>$event_cal{'12'} ($event_cal{'57'})</option>
		<option value="2"$aevt3>$event_cal{'13'}</option>
		</select>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="DisplayCalEvents">$event_cal{'20'}</label></td>
       <td align="left" class="windowbg2"><input type="checkbox" name="DisplayCalEvents" id="DisplayCalEvents" $dcaleventschecked /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="DisplayEvents">$event_cal{'34'}<br /><span class="small">$event_cal{'35'}</span></label></td>
       <td align="left" class="windowbg2"><input type="text" name="DisplayEvents" id="DisplayEvents" size="5" value="$DisplayEvents" /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="CalShortEvent">$event_cal{'6'}<br /><span class="small">$event_cal{'7'}</span></label></td>
       <td align="left" class="windowbg2">
		<input type="text" name="CalShortEvent" id="CalShortEvent" size="5" value="$CalShortEvent" /><br />
		<input type="checkbox" name="No_ShortUbbc" id="No_ShortUbbc" $onnosubbcchecked /> <span class="small"><label for="No_ShortUbbc">$event_cal{'58'}</label></span>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="Delete_EventsUntil">$event_cal{'52'}<br /><span class="small">$event_cal{'53'}</span></label></td>
       <td align="left" class="windowbg2"><input type="text" name="Delete_EventsUntil" id="Delete_EventsUntil" size="10" value="$Delete_EventsUntil" /></td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg" colspan="2"><span class="small">$event_cal{'23'}</span></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="CalEventPerms">$event_cal{'14'}<br /><span class="small">$event_cal{'15'}</span></label></td>
       <td align="left" class="windowbg2"><select multiple="multiple" name="CalEventPerms" id="CalEventPerms" size="5">$CalEventPerms</select></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="CalEventMods">$event_cal{'16'}<br /><span class="small">$event_cal{'17'}</span></label></td>
       <td align="left" class="windowbg2"><input type="text" name="CalEventMods" id="CalEventMods" size="35" value="$CalEventMods" /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="CalEventPrivate">$event_cal{'18'}<br /><span class="small">$event_cal{'19'}</span></label></td>
       <td align="left" class="windowbg2"><input type="checkbox" name="CalEventPrivate" id="CalEventPrivate" $caleventprivatechecked /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="CalEventNoName">$event_cal{'24'}</label></td>
       <td align="left" class="windowbg2">
		<select name="CalEventNoName" id="CalEventNoName" size="1">
		<option value="0"$noname1>$event_cal{'39'}</option>
		<option value="1"$noname2>$event_cal{'40'}</option>
		<option value="2"$noname3>$event_cal{'41'}</option>
		</select>
       </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg" colspan="2"><span class="small">$event_cal{'49'}</span></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><img src="$defaultimagesdir/$status_bdlist" alt="" /> <label for="Show_BirthdaysList">$event_cal{'42'}</label></td>
       <td align="left" class="windowbg2">
		<select name="Show_BirthdaysList" id="Show_BirthdaysList" size="1">
		<option value="0"$devt1>$event_cal{'11'}</option>
		<option value="1"$devt2>$event_cal{'46'}</option>
		<option value="2"$devt3>$event_cal{'47'}</option>
		</select>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="Show_BirthdayButton">$event_cal{'48'}</label></td>
       <td align="left" class="windowbg2">
		<select name="Show_BirthdayButton" id="Show_BirthdayButton" size="1">
		<option value="0"$eevt1>$event_cal{'11'}</option>
		<option value="1"$eevt2>$event_cal{'46'}</option>
		<option value="2"$eevt3>$event_cal{'47'}</option>
		</select>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="Show_BirthdayDate">$event_cal{'50'}</label></td>
       <td align="left" class="windowbg2">
		<select name="Show_BirthdayDate" id="Show_BirthdayDate" size="1">
		<option value="0"$fevt1>$event_cal{'11'}</option>
		<option value="1"$fevt2>$event_cal{'46'}</option>
		<option value="2"$fevt3>$event_cal{'47'}</option>
		</select>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><label for="Show_BdColorLinks">$event_cal{'44'}<br /><span class="small">$event_cal{'45'}</span></label></td>
       <td align="left" class="windowbg2"><input type="checkbox" name="Show_BdColorLinks" id="Show_BdColorLinks" $onbdcolorlinkschecked /></td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="center" class="catbg">
		 <input type="submit" name="savesetting" value="$event_cal{'31'}" /> <input type="submit" name="rebuiltbd" value="$event_cal{'54'}" />
	   </td>
     </tr>
   </table>
 </div>
</form>

<br /><br />
~;

	## Calendar Event-Icon Setting ##

	eval{ require "$vardir/eventcalIcon.txt"; };

	$yymain .= qq~
<form action="$adminurl?action=eventcal_set3" method="post">
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td  colspan="4" align="left" class="titlebg"><img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$event_cal{'26'}</b></td>
     </tr>
     <tr valign="middle">
       <td  colspan="4" align="left" class="windowbg2"><br />$event_cal{'33'}<br /><br /></td>
     </tr>
     <tr align="center" valign="middle">
       <td class="catbg" width="24%" align="center"><b>$event_cal{'27'}</b></td>
       <td class="catbg" width="24%" align="center"><b>$event_cal{'28'}</b></td>
       <td class="catbg" width="10%" align="center"><b>$event_cal{'29'}</b></td>
       <td class="catbg" width="6%" align="center"><b>$var_cal{'caldel'}</b></td>
     </tr>~;


	$i=0;
	while($CalIconURL[$i]) {
		$yymain .= qq~
     <tr>
       <td class="windowbg" width="24%" align="center"><input type="text" name="caliimg[$i]" value="$CalIconURL[$i]" /></td>
       <td class="windowbg" width="24%" align="center"><input type="text" name="calidescr[$i]" value="$CalIDescription[$i]" /></td>
       <td class="windowbg" width="10%" align='center'><img src="$yyhtml_root/EventIcons/$CalIconURL[$i].gif" alt="" /></td>
       <td class="windowbg" width="6%" align="center"><input type="checkbox" name="calidelbox[$i]" value="1" /></td>
     </tr>~;
		$i++
	}

	$yymain .= qq~
     <tr valign="middle">
       <td  colspan="4" align="left" class="titlebg"><img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$event_cal{'30'}</b></td>
     </tr>~;

	$inew = 0;
	while ($inew <= "3") {
		$yymain .= qq~
     <tr>
       <td class="windowbg" width="24%" align="center"><input type="text" name="caliimg[$i]" /></td>
       <td class="windowbg" width="24%" align="center"><input type="text" name="calidescr[$i]" /></td>
       <td class="windowbg" width="10%" align="center" colspan="2">&nbsp;</td>
     </tr>~;
		$i++;
		$inew++;
	}

	$yymain .= qq~
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="center" class="catbg"><input type="submit" value="$event_cal{'32'}" /></td>
     </tr>
   </table>
 </div>
</form>
~;

	$yytitle     = $event_cal{'1'};
	$action_area = "eventcal_set";
	&AdminTemplate;
	exit;
}

## Save Calendar Setting ##

sub EventCalSet2 {
	&is_admin_or_gmod;
die("SQLPORT: this still needs to be tested");#SQLPORT: TODO
	if ($FORM{'rebuiltbd'} eq "$event_cal{'54'}") {
		unlink("$vardir/eventcalbday.db");

			my @birthmembers = &read_DBorFILE(0,'',$memberdir,'memberinfo','txt');
			fopen(FILE,">$vardir/eventcalbday.db");
			foreach $user_name (@birthmembers) {
			($user_xy, $dummy) = split(/	/, $user_name);
				chomp $user_xy;
				&LoadUser($user_xy);
				$user_xy_bd = ${$uid.$user_xy}{'bday'};
				if ($user_xy_bd) {
					($user_month, $user_day, $user_year) = split(/\//, $user_xy_bd);
					if ($user_month < 10 && length($user_month) == 1) { $user_month = "0$user_month"; }
					if ($user_day < 10 && length($user_day) == 1) { $user_day = "0$user_day"; }
					print FILE qq~$user_year|$user_month|$user_day|$user_xy\n~;
					push(@eventcalbday, qq~$user_year|$user_month|$user_day|$user_xy\n~);

				}
			}
			fclose(FILE);

		$yySetLocation = qq~$adminurl?action=eventcal_set;rebok=1~;
		&redirectexit;

	} else {
		# Set 1 or 0 if box was checked or not
		map { ${$_} = $FORM{$_} ? 1 : 0; } qw/Show_MiniCalIcons CalEventPrivate DisplayCalEvents ShowSunday Show_ColorLinks No_ShortUbbc Show_BdColorLinks/;

		# If empty fields are submitted, set them to default-values to save yabb from crashing
		$DisplayEvents       = $FORM{'DisplayEvents'};
		$DisplayEvents       =~ s~[^\d]~~g;
		$DisplayEvents       = $DisplayEvents || 0;
		$Scroll_Events       = $FORM{'Scroll_Events'} || 0;
		$Show_EventCal       = $FORM{'Show_EventCal'} || 0;
		$Show_EventButton    = $FORM{'Show_EventButton'} || 0;
		$Show_EventButton    = $Show_EventCal if $Show_EventButton > $Show_EventCal;
		$Show_EventBirthdays = $FORM{'Show_EventBirthdays'} || 0;
		$Show_EventBirthdays = $Show_EventCal if $Show_EventBirthdays > $Show_EventCal;
		$Show_BirthdaysList  = $FORM{'Show_BirthdaysList'} || 0;
		$Show_BirthdayButton = $FORM{'Show_BirthdayButton'} || 0;
		$Show_BirthdayButton = $Show_BirthdaysList if $Show_BirthdayButton > $Show_BirthdaysList;
		$Show_BirthdayDate   = $FORM{'Show_BirthdayDate'} || 0;
		$CalEventNoName      = $FORM{'CalEventNoName'} || 0;
		$Event_TodayColor    = uc($FORM{'Event_TodayColor'} || "#FF0000") . '000000';
		$Event_TodayColor    =~ s/[^a-fA-F0-9#]//g;
		$Event_TodayColor    = substr($Event_TodayColor,0,7);
		$Delete_EventsUntil  = $FORM{'Delete_EventsUntil'} || 0;
		$CalShortEvent       = $FORM{'CalShortEvent'};
		$CalShortEvent       =~ s~[^\d]~~g;
		$CalShortEvent       = $CalShortEvent || 0;
		$CalEventPerms       = $FORM{'CalEventPerms'} || "";
		$CalEventPerms       =~ s~^\s*,\s*|\s*,\s*$~~g;
		$CalEventPerms       =~ s~\s*,\s*~,~g;
		$CalEventMods        = $FORM{'CalEventMods'} || "";
		$CalEventMods        =~ s~^\s*,\s*|\s*,\s*$~~g;
		$CalEventMods        =~ s~\s*,\s*~,~g;

		require "$admindir/NewSettings.pl";
		&SaveSettingsTo('Settings.pl');

		$yySetLocation = qq~$adminurl?action=eventcal_set~;
		&redirectexit;
	}
}

## Save Calendar Event-Icon Setting ##

sub EventCalSet3 {
	&is_admin_or_gmod;

	my $count = 0;
	my $tempA = 0;
	my @eventcalIcon;
	while ($FORM{"caliimg[$tempA]"}) {
		if ($FORM{"calidelbox[$tempA]"} != 1) {
			push(@eventcalIcon, qq~\$CalIconURL[$count] = "$FORM{"caliimg[$tempA]"}";\n\$CalIDescription[$count] = "$FORM{"calidescr[$tempA]"}";\n\n~);
			$count++;
		}
		$tempA++;
	}
	push(@eventcalIcon, "1;");
	&write_DBorFILE(0,'',$vardir,'eventcalIcon','txt',@eventcalIcon);

	$yySetLocation = qq~$adminurl?action=eventcal_set~;
	&redirectexit;
}

1;