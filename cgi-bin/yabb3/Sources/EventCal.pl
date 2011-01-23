###############################################################################
# EventCal.pl                                                                 #
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

$eventcalplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('EventCal');

use Time::Local 'timelocal';

sub get_cal {
	my ($i,$eventfound);
	## SSI Variables ##
	my $ssicalmode = $_[0];
	my $ssicaldisplay = $_[1];

	# select class depending on template style
	my ($seperator,$title_class) = ('','tabtitle');
	if ($usehead =~ /21$/) {
		$seperator   = 'seperator';
		$title_class = 'catbg';
	}

	#<--------------------------------------------->#
	# Access check to add events begin
	#<--------------------------------------------->#

	if (!$Show_EventCal || ($iamguest && $Show_EventCal != 2)) { &fatal_error('not_allowed'); }

	my $Allow_Event_Imput = 0;
	if    ($iamadmin)                   { $Allow_Event_Imput = 1; }
	elsif ($CalEventPerms eq "")        { $Allow_Event_Imput = 1; }
	elsif ($iamguest && $CalEventPerms) { $Allow_Event_Imput = 0; }
	else {
		toploop : foreach my $element (split(/,/, $CalEventPerms)) {
			if ($element eq ${$uid.$username}{'position'}) { $Allow_Event_Imput = 1; last; }
			foreach (split(/,/, $memberaddgroup{$username})) {
				if ($element eq $_) { $Allow_Event_Imput = 1; last toploop; }
			}
		}
		if (!$Allow_Event_Imput && $CalEventMods) {
			foreach (split(/,/, $CalEventMods)) {
				if ($_ eq $username) { $Allow_Event_Imput = 1; last; }
			}
		}
	}

	#<--------------------------------------------->#
	# Access check to add events end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# GoTo Box begin
	#<--------------------------------------------->#

	if ($INFO{'calgotobox'} == 1) {
		$goyear = $FORM{'selyear'};
		$gomon = $FORM{'selmon'};
		$goday = $FORM{'selday'};

		if ($goday) {
			$yySetLocation = qq~$scripturl?action=get_cal;calshow=1;eventdate=$goyear$gomon$goday;showmini=1~;
			&redirectexit;
		} else {
			$yySetLocation = qq~$scripturl?action=get_cal;calshow=1;calmon=$gomon;calyear=$goyear~;
			&redirectexit;
		}
	}

	#<--------------------------------------------->#
	# GoTo Box end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Time/Days begin
	#<--------------------------------------------->#

	my ($sel_year,$sel_mon,$sel_day);
	my $event_date = $INFO{'eventdate'};
	if ($event_date) {
		$event_date =~ /(\d{4})(\d{2})(\d{2})/;
		($sel_year,$sel_mon,$sel_day) = ($1,$2,$3);
	}

	my ($newisdst, $toffs, $newdate);
	$newdate = $date;

	if ($INFO{'calyear'}) { 
		$ausgabe1 = qq~$INFO{'calmon'}/01/$INFO{'calyear'} am 00:00:00~;
		$heute = &stringtotime($ausgabe1);
		$daterechnug = $heute;
	} else {
		$heute = $date;
		$daterechnug = $date;
	}

	(undef, undef, undef, undef, undef, undef, undef, undef, $newisdst) = localtime($heute);
	if ($newisdst > 0 && $dstoffset) {
		if ($iamguest) { if ($dstoffset) { $heute += 3600; $newdate += 3600; } }
		else { if (${$uid.$username}{'dsttimeoffset'} != 0) { $heute += 3600; $newdate += 3600; } }
	}

	if ($iamguest) { $toffs = $timeoffset; }
	else { $toffs = ${$uid.$username}{'timeoffset'}; }

	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $dst) = gmtime($heute + (3600 * $toffs));
	$year += 1900;

	my (undef, undef, undef, $callnewday, $callnewmonth, $callnewyear, undef) = gmtime($newdate + (3600 * $toffs));
	$callnewyear += 1900;
	$callnewmonth++;

	if ($INFO{'calyear'}) { 
		$year = $INFO{'calyear'};
		$mon = $INFO{'calmon'}-1;
	}

	&timeformat(); # get only correct $mytimeselected

	#<--------------------------------------------->#
	# Time/Days end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Get Navi begin
	#<--------------------------------------------->#

	if (!$INFO{'calmon'}) { $INFO{'calmon'} = $mon + 1; }
	if (!$INFO{'calmon'} > 12) { $INFO{'calmon'} = 12; }

	$next_mon = $INFO{'calmon'} + 1;
	$next_year = $year;
	$st_mon = $next_mon;
	if ($st_mon < 10) { $st_mon = "0$st_mon"; }
	$stnext = "calmon_" . $st_mon;
	$stnextname = $var_cal{$stnext};   
	$last_mon = $INFO{'calmon'} - 1;
	$st_mon = "$last_mon";
	if ($st_mon < 10) { $st_mon = "0$st_mon"; }
	$stlast = "calmon_" . $st_mon;
	$stlastname = $var_cal{$stlast};   
	$last_year = $year;
	if ($INFO{'calmon'} == 12) { $next_mon =1; $next_year = $year + 1; }
	if ($INFO{'calmon'} == 1)  { $last_mon =12; $last_year = $year - 1; }
	if ($next_mon < 10) { $next_mon = "0$next_mon"; }
	if ($last_mon < 10) { $last_mon = "0$last_mon"; }
	$next_link = qq~<a href="$scripturl?action=get_cal;calshow=1;calmon=$next_mon;calyear=$next_year;" title="$stnextname $next_year"> -&raquo;</a>~;
	$last_link = qq~<a href="$scripturl?action=get_cal;calshow=1;calmon=$last_mon;calyear=$last_year" title="$stlastname $last_year">&laquo;- </a>~;

	#<--------------------------------------------->#
	# Get Navi end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# EventCal System begin
	#<--------------------------------------------->#

	$viewyear = $year;
	$viewyear = substr($viewyear, 2,4);
	my @mon_days = (31,28,31,30,31,30,31,31,30,31,30,31);
	$days = @mon_days[$mon];
	$wday1 = (localtime(timelocal(0, 0, 0, 1, $mon, $year)))[6];
	if ($ShowSunday) { $wday1++; }
	if ($wday1 == 0) { $wday1 = 7; }
	$mon++;
	$caltoday = "$year".sprintf("%02d",$mon).sprintf("%02d",$mday);
	$st_mon = "$mon";
	if ($st_mon < 10) { $st_mon = "0$st_mon"; }
	$st = "calmon_".$st_mon;
	$view_mon = $mon;
	if ($view_mon < 10) { $view_mon = "0$view_mon"; }

	if (!$Show_ColorLinks) {
		&ManageMemberinfo("load");
	}

	#<--------------------------------------------->#
	# EventCal System end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Add Events and GoTo begin
	#<--------------------------------------------->#

	my $sdays   = qq~ <label for="calday">$var_cal{'calday'}</label>
	<select class="input" name="selday" id="calday">\n~;
	my $boxdays = qq~ <label for="selday"><span class="small">$var_cal{'calday'}</span></label>
	<select class="input" name="selday" id="selday">
	<option value="0">---</option>\n~;
	for ($i = 1; $i < 32; $i++) {
		my $sel = "";
		if ($mday == $i && !$sel_day) {
			$sel = ' selected="selected"';
		} elsif ($sel_day == $i) {
			$sel = ' selected="selected"';
		}
		$sdays   .= "		<option value=\"" . sprintf("%02d",$i) . "\"$sel>$i</option>\n";
		$boxdays .= "		<option value=\"" . sprintf("%02d",$i) . "\"$sel>$i</option>\n";
	}
	$sdays   .= "	</select>";
	$boxdays .= "	</select>";

	my $smonths   = qq~ <label for="calmon">$var_cal{'calmonth'}</label>
	<select class="input" name="selmon" id="calmon">\n~;
	my $boxmonths = qq~ <label for="selmon"><span class="small">$var_cal{'calmonth'}</span></label>
	<select class="input" name="selmon" id="selmon">\n~;
	for ($i = 1; $i < 13; $i++) {
		my $sel = "";
		if ($mon == $i && !$sel_mon) {
			$sel = ' selected="selected"';
		} elsif ($sel_mon == $i) {
			$sel = ' selected="selected"';
		}
		$smonths   .= "		<option value=\"" . sprintf("%02d",$i) . "\"$sel>$i</option>\n";
		$boxmonths .= "		<option value=\"" . sprintf("%02d",$i) . "\"$sel>$i</option>\n";
	}
	$smonths   .= "	</select>";
	$boxmonths .= "	</select>";

	my $syears = qq~ <label for="calyear">$var_cal{'calyear'}</label>
	<select class="input" name="selyear" id="calyear">\n~;
	my $gyears3 = $year - 3;
	my $gyears2 = $year - 2;
	my $gyears1 = $year - 1;
	my $boxyears .= qq~ <label for="selyear"><span class="small">&nbsp;$var_cal{'calyear'}</span></label>
	<select class="input" name="selyear" id="selyear">
		<option value="$gyears3">$gyears3</option>
		<option value="$gyears2">$gyears2</option>
		<option value="$gyears1">$gyears1</option>\n~;
	for ($i = $year; $i < $year + 4; $i++) {
		my $sel = "";
		if ($year == $i && !$sel_year) {
			$sel = ' selected="selected"';
		} elsif ($sel_year == $i) {
			$sel = ' selected="selected"';
		}
		$syears   .= qq~		<option value="$i"$sel>$i</option>\n~;
		$boxyears .= qq~		<option value="$i"$sel>$i</option>\n~;
	}
	$syears   .= "	</select>";
	$boxyears .= "	</select>";

	my $addevdate;
	my $calgotobox = qq~
	<form action="$scripturl?action=get_cal;calshow=1;calgotobox=1" method="post">
	<span class="small"><b>$var_cal{'calsubmit'}</b></span>~;

	if ($mytimeselected == 8 || $mytimeselected == 6 || $mytimeselected == 3 || $mytimeselected == 2) {
		$addevdate .= $sdays . $smonths;
		$calgotobox .= $boxdays . $boxmonths;
	} else {
		$addevdate .= $smonths . $sdays;
		$calgotobox .= $boxmonths . $boxdays;
	}
	$addevdate  .= $syears;
	$calgotobox .= qq~$boxyears
	&nbsp; <input type="submit" name="Go" value="$var_cal{'calgo'}" />
	</form>\n~;

	#<--------------------------------------------->#
	# Add Events and GoTo end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# YaBBC Section begin
	#<--------------------------------------------->#

	my $YaBBC_calout;
	if ($INFO{'addnew'} == 1) {
		if ($INFO{'edit_cal_even'}) { $var_cal{'calevent'} = "$var_cal{'caledit'}:"; }

		$calicon = "eventinfo";

		## Edit Infos Begin ##
		if ($INFO{'edit_typ'} == 0)    { $aevt1 = ' selected="selected"'; }
		elsif ($INFO{'edit_typ'} == 1) { $aevt2 = ' selected="selected"'; }
		elsif ($INFO{'edit_typ'} == 2) { $aevt3 = ' selected="selected"'; }
		else { $aevt2 = ' selected="selected"'; }

		if ($INFO{'edit_typ1'} == 0)    { $a1evt1 = ' selected="selected"'; }
		elsif ($INFO{'edit_typ1'} == 2) { $a1evt2 = ' selected="selected"'; }
		elsif ($INFO{'edit_typ1'} == 3) { $a1evt3 = ' selected="selected"'; }
		else { $a1evt1 = ' selected="selected"'; }

		if ($INFO{'edit_icon'}) {
			$class = "calicon_$INFO{'edit_icon'}";
			$$class = ' selected="selected"';
			$calicon = "$INFO{'edit_icon'}";
		}

		if ($INFO{'edit_nonam'} == 1) { $cecknonam = "checked='checked'" }
		## Edit Infos End ##

		$YaBBC_calout = qq~
<script language="JavaScript1.2" src="$yyhtml_root/yabbc.js" type="text/javascript"></script>

<form action="$scripturl?action=add_cal" name="postmodify" method="post">
<table width="100%" style="margin: 3px" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="100%" class="windowbg2">
			<b>$var_cal{'calevent'}</b><br />

<table cellspacing="0" cellpadding="0" border="0">
	<tr> 
		<td width="160" height="23">
			<label for="calday"><span class="small"><b>$var_cal{'date'}:</b></span></label>
		</td>
		<td>
			<span class="small">$addevdate</span>
		</td>
	</tr>~;

		my ($option_noname,$option_private);
		if (($CalEventNoName == 0 && ($iamadmin || $iamgmod)) || ($CalEventNoName == 1 && !$iamguest)) { 
			$option_noname = qq~
	<tr> 
		<td width="160" height="23">
			<span class="small"><label for="calnoname"><b>$var_cal{'calnoname'}:</b></label></span>
		</td>
		<td>
			<input type="checkbox" value="1" name="calnoname" id="calnoname" $cecknonam/>
		</td>
	</tr>~;
		}

		if ($iamadmin || $iamgmod || ($CalEventPrivate == 1 && !$iamguest)) {
			$option_private = qq~<option value="2"$aevt3>$var_cal{'calprivate'}</option>~;
		}

		$YaBBC_calout .= qq~$option_noname
	<tr> 
		<td width="160" height="23">
			<span class="small"><label for="caltype"><b>$var_cal{'calview'}:</b></label></span>
		</td>
		<td> 
			<select name="caltype" id="caltype" size="1">
			<option value="0"$aevt1>$var_cal{'calpublic'}</option>
			<option value="1"$aevt2>$var_cal{'calmembers'}</option>
			$option_private
			</select> / 
			<select name="caltype2" size="1">
			<option value="0"$a1evt1>$var_cal{'onlyone'}</option>
			<option value="2"$a1evt2>$var_cal{'eventinfo'} ($var_cal{'monthly'})</option>
			<option value="3"$a1evt3>$var_cal{'eventinfo'} ($var_cal{'yearly'})</option>
			</select>
		</td>
	</tr>
	<tr> 
		<td  align="left" width="160" height="26">
			<span class="small"><label for="calicon"><b>$var_cal{'event_icon'}:</b></label></span>
		</td>
		<td>
			<table cellspacing="0" cellpadding="0" border="0">
			<tr>
				<td>
					<select name="calicon" id="calicon" onchange="calshowimage();">
					<option value="eventinfo"$calicon_eventinfo>$var_cal{'eventinfo'}</option>
					<option value="eventholiday"$calicon_eventholiday>$var_cal{'eventholiday'}</option>
					<option value="eventannounce"$calicon_eventannounce>$var_cal{'eventannounce'}</option>
					<option value="eventnote"$calicon_eventnote>$var_cal{'eventnote'}</option>
					<option value="eventparty"$calicon_eventparty>$var_cal{'eventparty'}</option>
					<option value="eventcelebration"$calicon_eventcelebration>$var_cal{'eventcelebration'}</option>
					<option value="eventsport"$calicon_eventsport>$var_cal{'eventsport'}</option>
					<option value="eventmedia"$calicon_eventmedia>$var_cal{'eventmedia'}</option>
					<option value="eventmeeting"$calicon_eventmeeting>$var_cal{'eventmeeting'}</option>~;

		eval{ require "$vardir/eventcalIcon.txt"; };
		my $i=0;
		while ($CalIconURL[$i]) {
			if ($INFO{'edit_icon'} eq $CalIconURL[$i]) { $eveic[$i] = " selected"; }
			$YaBBC_calout .= qq~
					<option value="$CalIconURL[$i]"$eveic[$i]>$CalIDescription[$i]</option>~;
			$i++;
		}

		$YaBBC_calout .= qq~
					</select>
				</td><td>
						<img src="$yyhtml_root/EventIcons/$calicon.gif" name="calicons" border="0" hspace="26" alt="" />
				</td>
			</tr>
			</table>
		</td>
	</tr>
</table>

		</td>
	</tr><tr>
		<td width="100%" class="windowbg2">
			<br />~;
      
		if ($enable_ubbc && $showyabbcbutt) {
			$YaBBC_calout .= qq~
			<div style="float: left; width: 440px;">
			<script language="JavaScript1.2" type="text/javascript">
			<!--
			HAND = "style='cursor: pointer;'";
			HAND += " onmouseover='contextTip(event, this.alt)' onmouseout='contextTip(event, this.alt)' oncontextmenu='if(!showcontexthelp(this.src, this.alt)) return false;'";
			document.write('<div style="width: 437px; float: left;">');
			document.write("<img src='$imagesdir/url.gif' onclick='hyperlink();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'url'}' title='$var_calpost{'url'}' border='0' />");
			document.write("<img src='$imagesdir/ftp.gif' onclick='ftp();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'ftp'}' title='$var_calpost{'ftp'}' border='0' />");
			document.write("<img src='$imagesdir/img.gif' onclick='image();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'img'}' title='$var_calpost{'img'}' border='0' />");
			document.write("<img src='$imagesdir/email2.gif' onclick='emai1();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'email'}' title='$var_calpost{'email'}' border='0' />");
			document.write("<img src='$imagesdir/media.gif' onclick='flash();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'media'}' title='$var_calpost{'media'}' border='0' />");
			document.write("<img src='$imagesdir/table.gif' onclick='table();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'table'}' title='$var_calpost{'table'}' border='0' />");
			document.write("<img src='$imagesdir/tr.gif' onclick='trow();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'tr'}' title='$var_calpost{'tr'}' border='0' />");
			document.write("<img src='$imagesdir/td.gif' onclick='tcol();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'td'}' title='$var_calpost{'td'}' border='0' />");
			document.write("<img src='$imagesdir/hr.gif' onclick='hr();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'hr'}' title='$var_calpost{'hr'}' border='0' />");
			document.write("<img src='$imagesdir/tele.gif' onclick='teletype();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'tt'}' title='$var_calpost{'tt'}' border='0' />");
			document.write("<img src='$imagesdir/code.gif' onclick='showcode();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'code'}' title='$var_calpost{'code'}' border='0' />");
			document.write("<img src='$imagesdir/quote2.gif' onclick='quote();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'quote'}' title='$var_calpost{'quote'}' border='0' />");
			document.write("<img src='$imagesdir/edit.gif' onclick='edit();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'edit'}' title='$var_calpost{'edit'}' border='0' />");
			document.write("<img src='$imagesdir/sup.gif' onclick='superscript();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'sup'}' title='$var_calpost{'sup'}' border='0' />");
			document.write("<img src='$imagesdir/sub.gif' onclick='subscript();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'sub'}' title='$var_calpost{'sub'}' border='0' />");
			document.write("<img src='$imagesdir/list.gif' onclick='list();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'list'}' title='$var_calpost{'list'}' border='0' />");
			document.write("<img src='$imagesdir/me.gif' onclick='me();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'me'}' title='$var_calpost{'me'}' border='0' />");
			document.write("<img src='$imagesdir/move.gif' onclick='move();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'move'}' title='$var_calpost{'move'}' border='0' />");
			document.write("<img src='$imagesdir/timestamp.gif' onclick='timestamp($date);' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'timestamp'}' title='$var_calpost{'timestamp'}' border='0' /><br />");
			document.write('</div>');
			document.write('<div style="width: 115px; float: left;">');
			document.write("<img src='$imagesdir/bold.gif' onclick='bold();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'bold'}' title='$var_calpost{'bold'}' border='0' />");
			document.write("<img src='$imagesdir/italicize.gif' onclick='italicize();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'italicize'}' title='$var_calpost{'italicize'}' border='0' />");
			document.write("<img src='$imagesdir/underline.gif' onclick='underline();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'underline'}' title='$var_calpost{'underline'}' border='0' />");
			document.write("<img src='$imagesdir/strike.gif' onclick='strike();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'strike'}' title='$var_calpost{'strike'}' border='0' />");
			document.write("<img src='$imagesdir/highlight.gif' onclick='highlight();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'highlight'}' title='$var_calpost{'highlight'}' border='0' />");
			document.write('</div>');
			document.write('<div style="width: 139px; float: left; text-align: center;">');
			document.write('<select name="fontface" id="fontface" onchange="if(this.options[this.selectedIndex].value) fontfce(this.options[this.selectedIndex].value);" style="width: 90px; margin-top: 2px; margin-left: 2px; margin-right: 1px; font-size: 9px;">');
			document.write('<option value="">Verdana</option>');
			document.write('<option value="">-\\-\\-\\-\\-\\-\\-\\-\\-</option>');
			document.write('<option value="Arial" style="font-family: Arial">Arial</option>');
			document.write('<option value="Bitstream Vera Sans Mono" style="font-family: Bitstream Vera Sans Mono">Bitstream</option>');
			document.write('<option value="Bradley Hand ITC" style="font-family: Bradley Hand ITC">Bradley Hand ITC</option>');
			document.write('<option value="Comic Sans MS" style="font-family: Comic Sans MS">Comic Sans MS</option>');
			document.write('<option value="Courier" style="font-family: Courier">Courier</option>');
			document.write('<option value="Courier New" style="font-family: Courier New">Courier New</option>');
			document.write('<option value="Georgia" style="font-family: Georgia">Georgia</option>');
			document.write('<option value="Impact" style="font-family: Impact">Impact</option>');
			document.write('<option value="Lucida Sans" style="font-family: Lucida Sans">Lucida Sans</option>');
			document.write('<option value="Microsoft Sans Serif" style="font-family: Microsoft Sans Serif">MS Sans Serif</option>');
			document.write('<option value="Papyrus" style="font-family: Papyrus">Papyrus</option>');
			document.write('<option value="Tahoma" style="font-family: Tahoma">Tahoma</option>');
			document.write('<option value="Tempus Sans ITC" style="font-family: Tempus Sans ITC">Tempus Sans ITC</option>');
			document.write('<option value="Times New Roman" style="font-family: Times New Roman">Times New Roman</option>');
			document.write('<option value="Verdana" style="font-family: Verdana">Verdana</option>');
			document.write('</select>');
			var fntoptions = ["6", "7", "8", "9", "10", "11", "12", "14", "16", "18", "20", "22", "24", "36", "48", "56", "72"]
			document.write('<select name="fontsize" id="fontsize" onchange="if(this.options[this.selectedIndex].value) fntsize(this.options[this.selectedIndex].value);" style="width: 39px; margin-top: 2px; margin-left: 1px; margin-right: 2px; font-size: 9px;">');
			document.write('<option value="">11</option>');
			document.write('<option value="">-\\-</option>');
			for(var i = 0; i < fntoptions.length; i++) {
				if(fntoptions[i] >= $fontsizemin && fntoptions[i] <= $fontsizemax) {
					if(fntoptions[i] == 11) document.write('<option value="11" selected="selected">11</option>');
					else document.write('<option value=' + fntoptions[i] + '>' + fntoptions[i] + '</option>');
				}
			}
			document.write('</select>');
			document.write('</div>');


			// Palette
			var thistask = 'post';
			function tohex(i) {
				a2 = ''
				ihex = hexQuot(i);
				idiff = eval(i + '-(' + ihex + '*16)')
				a2 = itohex(idiff) + a2;
				while( ihex >= 16) {
					itmp = hexQuot(ihex);
					idiff = eval(ihex + '-(' + itmp + '*16)');
					a2 = itohex(idiff) + a2;
					ihex = itmp;
				} 
				a1 = itohex(ihex);
				return a1 + a2 ;
			}

			function hexQuot(i) {
				return Math.floor(eval(i +'/16'));
			}

			function itohex(i) {
				if( i == 0) { aa = '0' }
				else { if( i == 1 ) { aa = '1' }
				else { if( i == 2 ) { aa = '2' }
				else { if( i == 3 ) { aa = '3' }
				else { if( i == 4 ) { aa = '4' }
				else { if( i == 5 ) { aa = '5' }
				else { if( i == 6 ) { aa = '6' }
				else { if( i == 7 ) { aa = '7' }
				else { if( i == 8 ) { aa = '8' }
				else { if( i == 9 ) { aa = '9' }
				else { if( i == 10) { aa = 'a' }
				else { if( i == 11) { aa = 'b' }
				else { if( i == 12) { aa = 'c' }
				else { if( i == 13) { aa = 'd' }
				else { if( i == 14) { aa = 'e' }
				else { if( i == 15) { aa = 'f' }
				}}}}}}}}}}}}}}}
				return aa;
			}

			function ConvShowcolor(color) {
				if ( c=color.match(/rgb\\((\\d+?)\\, (\\d+?)\\, (\\d+?)\\)/i) ) {
					var rhex = tohex(c[1]);
					var ghex = tohex(c[2]);
					var bhex = tohex(c[3]);
					var newcolor = '#'+rhex+ghex+bhex;
				}
				else {
					var newcolor = color;
				}
				if(thistask == "post") showcolor(newcolor);
				if(thistask == "templ") previewColor(newcolor);
			}
			//-->
			</script>
			<div style="float: left; height: 22px; width: 91px;">
			<div style="height: 20px; width: 66px; padding-left: 1px; padding-top: 1px; margin-top: 1px; float: left;">
				<span style="float: left; background-color: #000000; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor('#000000')">&nbsp;</span>
				<span style="float: left; background-color: #333333; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor('#333333')">&nbsp;</span>
				<span style="float: left; background-color: #666666; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor('#666666')">&nbsp;</span>
				<span style="float: left; background-color: #999999; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor('#999999')">&nbsp;</span>
				<span style="float: left; background-color: #cccccc; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor('#cccccc')">&nbsp;</span>
				<span style="float: left; background-color: #ffffff; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor('#ffffff')">&nbsp;</span>
				<span id="defaultpal1" style="float: left; background-color: $pallist[0]; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
				<span id="defaultpal2" style="float: left; background-color: $pallist[1]; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
				<span id="defaultpal3" style="float: left; background-color: $pallist[2]; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
				<span id="defaultpal4" style="float: left; background-color: $pallist[3]; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
				<span id="defaultpal5" style="float: left; background-color: $pallist[4]; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
				<span id="defaultpal6" style="float: left; background-color: $pallist[5]; width: 10px; height: 9px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
			</div>
			<div style="height: 22px; width: 23px; padding-left: 1px; float: right;">
				<img src="$imagesdir/palette1.gif" style="cursor: pointer" onclick="window.open('$scripturl?action=palette;task=post', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" alt="$var_calpost{'color'}" title="$var_calpost{'color'}" border="0" />
			</div>
			</div>
			<script language="JavaScript1.2" type="text/javascript">
			<!--
			HAND = "style='cursor: pointer; cursor: hand;'";
			document.write('<div style="width: 92px; float: left;">');
			document.write("<img src='$imagesdir/pre.gif' onclick='pre();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'pre'}' title='$var_calpost{'pre'}' border='0' />");
			document.write("<img src='$imagesdir/left.gif' onclick='left();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'left'}' title='$var_calpost{'left'}' border='0' />");
			document.write("<img src='$imagesdir/center.gif' onclick='center();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'center'}' title='$var_calpost{'center'}' border='0' />");
			document.write("<img src='$imagesdir/right.gif' onclick='right();' "+HAND+" align='top' width='23' height='22' alt='$var_calpost{'right'}' title='$var_calpost{'right'}' border='0' />");
			document.write('</div>');
			//-->
			</script>
			<noscript>
			<span class="small">$maintxt{'noscript'}</span>
			</noscript>
			</div>~;
		}

		if (!${$uid.$username}{'postlayout'}) {
			$pheight = 130; $pwidth = 425; $textsize = 10;
		} else {
			($pheight, $pwidth, $textsize, $col_row) = split(/\|/, ${$uid.$username}{'postlayout'});
		}
		$col_row ||= 0;
		if(!$textsize || $textsize < 6) { $textsize = 6; }
		if($textsize > 16) { $textsize = 16; }
		if($pheight > 400) { $pheight = 400; }
		if($pheight < 130) { $pheight = 130; }
		if($pwidth > 855) { $pwidth = 855; }
		if($pwidth < 425) { $pwidth = 425; }
		$mtextsize = $textsize . "pt";
		$mheight = $pheight . "px";
		$mwidth = $pwidth . "px";
		$dheight = ($pheight + 12) . "px";
		$dwidth = ($pwidth + 12) . "px";
		$jsdragwpos = $pwidth - 425;
		$dragwpos = ($pwidth - 425) . "px";
		$jsdraghpos = $pheight - 130;
		$draghpos = ($pheight - 130) . "px";

		$YaBBC_calout .= qq~
			<div id="spell_container"></div>
			<div style="float: left; width: 99%;">
			<input type="hidden" name="col_row" id="col_row" value="$col_row" />
			<input type="hidden" name="messagewidth" id="messagewidth" value="$pwidth" />
			<input type="hidden" name="messageheight" id="messageheight" value="$pheight" />
			<div id="dragcanvas" style="position: relative; top: 0px; left: 0px; height: $dheight; width: $dwidth; border: 0; z-index: 1;">
			<textarea name="message" id="message" rows="8" cols="68" style="position: absolute; top: 0px; left: 0px; z-index: 2; height: $mheight; width: $mwidth; font-size: $mtextsize; padding: 5px; margin: 0px; visibility: visible;" onclick="storeCaret(this);" onkeyup="storeCaret(this);" onchange="storeCaret(this);" tabindex="4">{yabb calevent}</textarea>
			<div id="dragbgw" style="position: absolute; top: 0px; left: 437px; width: 3px; height: $dheight; border: 0; z-index: 3;">
			<img id="dragImg1" src="$imagesdir/resize_wb.gif" class="drag" style="position: absolute; top: 0px; left: $dragwpos; z-index: 4; width: 3px; height: $dheight; cursor: e-resize;" alt= "" />
			</div>
			<div id="dragbgh" style="position: absolute; top: 142px; left: 0px; width: $dwidth; height: 3px; border: 0; z-index: 3;">
			<img id="dragImg2" src="$imagesdir/resize_hb.gif" class="drag" style="position: absolute; top: $draghpos; left: 0px; z-index: 4; width: $dwidth; height: 3px; cursor: n-resize;" alt= "" />
			</div>
			</div>
			<div style="float: left; width: 315px; text-align: left;"> 
			<img src="$imagesdir/green1.gif" name="chrwarn" height="8" width="8" border="0" vspace="0" hspace="0" alt="" align="middle" />
			<span class="small">$var_calpost{'eventmaxlength'} <input value="$MaxMessLen" size="3" name="msgCL" class="windowbg2" style="border: 0px; font-size: 11px; width: 40px; padding: 1px" readonly="readonly" /></span>
			</div>
			<div style="float: left; width: 127px; text-align: right;">
				<span class="small">$var_calpost{'textsize'} <input value="$textsize" size="2" name="txtsize" id="txtsize" class="windowbg2" style="border: 0px; font-size: 11px; width: 15px; padding: 1px" readonly="readonly" />pt <img src="$imagesdir/smaller.gif" height="11" width="11" border="0" alt="" align="middle" onclick="sizetext(-1);" /><img src="$imagesdir/larger.gif" height="11" width="11" border="0" alt="" align="middle" onclick="sizetext(1);" /></span>
			</div>
			</div>
		</td>
	</tr>
	<tr>
		<td width="100%" class="windowbg2">
		~;

		# SpellChecker start
		if ($enable_spell_check) {
			$yyinlinestyle .= qq~<link href="$yyhtml_root/googiespell/googiespell.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="$yyhtml_root/AJS.js"></script>
<script type="text/javascript" src="$yyhtml_root/googiespell/googiespell.js"></script>
<script type="text/javascript" src="$yyhtml_root/googiespell/cookiesupport.js"></script>~;
			my $userdefaultlang = (split(/-/, $abbr_lang))[0];
			$userdefaultlang ||= 'en';
			$YaBBC_calout .= qq~
			<script type="text/javascript">
			<!--
			GOOGIE_DEFAULT_LANG = '$userdefaultlang';
			var googie1 = new GoogieSpell("$yyhtml_root/googiespell/", "$boardurl/Sources/SpellChecker.pl?lang=");
			googie1.lang_chck_spell = '$var_calspell{'chck_spell'}';
			googie1.lang_revert = '$var_calspell{'revert'}';
			googie1.lang_close = '$var_calspell{'close'}';
			googie1.lang_rsm_edt = '$var_calspell{'rsm_edt'}';
			googie1.lang_no_error_found = '$var_calspell{'no_error_found'}';
			googie1.lang_no_suggestions = '$var_calspell{'no_suggestions'}';
			googie1.setSpellContainer("spell_container");
			googie1.decorateTextarea("message");
			//-->
			</script>~;
		}
		# SpellChecker end

		$YaBBC_calout .= qq~
			<script language="JavaScript1.2" type="text/javascript">
			<!--
			HAND = "style='cursor: pointer; cursor: hand;'";
			document.write("<img src='$imagesdir/smiley.gif' onclick='smiley();' "+HAND+" align='bottom' alt='$var_calsmiley{'smiley'}' title='$var_calsmiley{'smiley'}' border='0'> ");
			document.write("<img src='$imagesdir/wink.gif' onclick='wink();' "+HAND+" align='bottom' alt='$var_calsmiley{'wink'}' title='$var_calsmiley{'wink'}' border='0'> ");
			document.write("<img src='$imagesdir/cheesy.gif' onclick='cheesy();' "+HAND+" align='bottom' alt='$var_calsmiley{'cheesy'}' title='$var_calsmiley{'cheesy'}' border='0'> ");
			document.write("<img src='$imagesdir/grin.gif' onclick='grin();' "+HAND+" align='bottom' alt='$var_calsmiley{'grin'}' title='$var_calsmiley{'grin'}' border='0'> ");
			document.write("<img src='$imagesdir/angry.gif' onclick='angry();' "+HAND+" align='bottom' alt='$var_calsmiley{'angry'}' title='$var_calsmiley{'angry'}' border='0'> ");
			document.write("<img src='$imagesdir/sad.gif' onclick='sad();' "+HAND+" align='bottom' alt='$var_calsmiley{'sad'}' title='$var_calsmiley{'sad'}' border='0'> ");
			document.write("<img src='$imagesdir/shocked.gif' onclick='shocked();' "+HAND+" align='bottom' alt='$var_calsmiley{'shocked'}' title='$var_calsmiley{'shocked'}' border='0'> ");
			document.write("<img src='$imagesdir/cool.gif' onclick='cool();' "+HAND+" align='bottom' alt='$var_calsmiley{'cool'}' title='$var_calsmiley{'cool'}' border='0'> ");
			document.write("<img src='$imagesdir/huh.gif' onclick='huh();' "+HAND+" align='bottom' alt='$var_calsmiley{'huh'}' title='$var_calsmiley{'huh'}' border='0'> ");
			document.write("<img src='$imagesdir/rolleyes.gif' onclick='rolleyes();' "+HAND+" align='bottom' alt='$var_calsmiley{'rolleyes'}' title='$var_calsmiley{'rolleyes'}' border='0'> ");
			document.write("<img src='$imagesdir/tongue.gif' onclick='tongue();' "+HAND+" align='bottom' alt='$var_calsmiley{'tongue'}' title='$var_calsmiley{'tongue'}' border='0'> ");
			document.write("<img src='$imagesdir/embarassed.gif' onclick='embarassed();' "+HAND+" align='bottom' alt='$var_calsmiley{'embarrassed'}' title='$var_calsmiley{'embarrassed'}' border='0'> ");
			document.write("<img src='$imagesdir/lipsrsealed.gif' onclick='lipsrsealed();' "+HAND+" align='bottom' alt='$var_calsmiley{'lipssealed'}' title='$var_calsmiley{'lipssealed'}' border='0'> ");
			document.write("<img src='$imagesdir/undecided.gif' onclick='undecided();' "+HAND+" align='bottom' alt='$var_calsmiley{'undecided'}' title='$var_calsmiley{'undecided'}' border='0'> ");
			document.write("<img src='$imagesdir/kiss.gif' onclick='kiss();' "+HAND+" align='bottom' alt='$var_calsmiley{'kiss'}' title='$var_calsmiley{'kiss'}' border='0'> ");
			document.write("<img src='$imagesdir/cry.gif' onclick='cry();' "+HAND+" align='bottom' alt='$var_calsmiley{'cry'}' title='$var_calsmiley{'cry'}' border='0'> ");$moresmilieslist
			//-->
			</script>~ if !$removenormalsmilies && (!${$uid.$username}{'hide_smilies_row'} || !$user_hide_smilies_row);

		$YaBBC_calout .= qq~
			<noscript>
			<span class="small">$maintxt{'noscript'}</span>
			</noscript>
			<script language="JavaScript1.2" type="text/javascript">
			<!--
				// Size of messagebox and text START
				var oldwidth = parseInt(document.getElementById('message').style.width) - $jsdragwpos;
				var olddragwidth = parseInt(document.getElementById('dragbgh').style.width) - $jsdragwpos;
				var oldheight = parseInt(document.getElementById('message').style.height) - $jsdraghpos;
				var olddragheight = parseInt(document.getElementById('dragbgw').style.height) - $jsdraghpos;
				var orgsize = $textsize;
				skydobject.initialize();
				// Size of message box, characters in message box END

				function calshowimage() {
					document.images.calicons.src = "$yyhtml_root/EventIcons/" + document.postmodify.calicon.options[document.postmodify.calicon.selectedIndex].value + ".gif";
				}

				// count left characters START
				var noalert = true, gralert = false, rdalert = false, clalert = false;
				var cntsec = 0

				function tick() {
					cntsec++;
					calcCharLeft();
					var timerID = setTimeout("tick()",1000);
				}

				function calcCharLeft() {
					var clipped = false;
					var maxLength = $MaxMessLen;
					if (document.postmodify.message.value.length > maxLength) {
						document.postmodify.message.value = document.postmodify.message.value.substring(0,maxLength);
						var charleft = 0;
						clipped = true;
					} else {
						charleft = maxLength - document.postmodify.message.value.length;
					}
					document.postmodify.msgCL.value = charleft;
					if (charleft >= 100 && noalert) { noalert = false; gralert = true; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/green1.gif"; }
					if (charleft < 100 && charleft >= 50 && gralert) { noalert = true; gralert = false; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/green0.gif"; }
					if (charleft < 50 && charleft > 0 && rdalert) { noalert = true; gralert = true; rdalert = false; clalert = true; document.images.chrwarn.src="$defaultimagesdir/red0.gif"; }
					if (charleft == 0 && clalert) { noalert = true; gralert = true; rdalert = true; clalert = false; document.images.chrwarn.src="$defaultimagesdir/red1.gif"; }
					return clipped;
				}

				tick();
				// count left characters END
			//-->
			</script>~;

		if ($iamguest && $gpvalid_en) {
			require "$sourcedir/Decoder.pl";
			&validation_code;
			$YaBBC_calout .= qq~
			<br /><br /><br />
			<table>
			<tr>
				<td class="windowbg2" width="160" valign="middle"><span class="small"><label for="verification"><b>$var_calflood{'1'}:</b></label></span></td>
				<td class="windowbg2">$showcheck<br /><label for="verification"><span class="small">$var_calflood{'casewarning'}</span></label></td>
			</tr>
			<tr>
				<td class="windowbg2" width="160" valign="middle"><span class="small"><label for="verification"><b>$var_calflood{'2'}:</b></label></span></td>
				<td class="windowbg2">
				<input type="text" maxlength="30" name="verification" id="verification" size="30" />
				</td>
			</tr>
			</table>\n~;
		}

		if (!$INFO{'edit_cal_even'}) {
			$YaBBC_calout .= qq~
			<br /><br />
			<input class="button" type="submit" name="calsubmit" value="$var_calpost{'event_send'}" accesskey="s" />
			<br />
		</td>
	</tr>
</table>
</form>~;
		}
	}

	#<--------------------------------------------->#
	# YaBBC Section end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Event data begin
	#<--------------------------------------------->#

	if ($INFO{'eventdate'}) { $bd_year= substr($INFO{'eventdate'},0,4); } else { $bd_year= $year; }

	my @caldata;
	## Get Birthdays ##
	if (($Show_EventBirthdays == 1 && !$iamguest) || $Show_EventBirthdays == 2) {
		my @birthmembers = &read_DBorFILE(1,'',$vardir,'eventcalbday','db');

		foreach $user_bdname (@birthmembers) {
			chomp $user_bdname;
			($user_bdyear, $user_bdmon, $user_bdday, $user_bdname) = split(/\|/,$user_bdname);

	 		if ((($user_bdmon < $view_mon) || ($user_bdmon == $view_mon) && ($user_bdday < $mday)) && (!$INFO{'showmini'}) && (!$INFO{'showthisdate'})) {
				$bd_y = $year;
				$bday_date ="$bd_y$user_bdmon$user_bdday";
				$age = $bd_y-$user_bdyear;
			} else { 
				$bd_y = $bd_year;
				$bday_date ="$bd_y$user_bdmon$user_bdday";
				$age = $bd_y-$user_bdyear;
			}

			%{bday.$bd_year.$user_bdmon.$user_bdday}=(
				'caleventdate' => "$bd_year$user_bdmon$user_bdday",
				'calyear' => "$bd_year",
				'calmon' => "$user_bdmon",
				'calday' => "$user_bdday",
				'caltype' => "0",
				'calname' => "$user_bdname",
				'caltime' => "$user_bdname",
				'calicon' => "birthday",
				'calevent' => "$string",
				'calnoname' => "0",
			);

			push(@caldata, qq~$bday_date|0|$user_bdname|$user_bdname|<span class="small">$age</span>|birthday|0~);
		}
	}

	## Get Events ##
	foreach my $eventline (sort &read_DBorFILE(1,'',$vardir,'eventcal','db')) {
		chomp $eventline;
		my ($cal_date,$cal_type,$cal_name,$cal_time,$cal_event,$cal_icon,$cal_noname,$cal_type2) = split(/\|/,$eventline);
		$cal_date =~ /(\d{4})(\d{2})(\d{2})/;
		my ($c_year,$c_mon,$c_day) = ($1,$2,$3);

		if ($cal_type == 2) {
			next if $cal_name ne $username;
			%{private.$c_year.$c_mon.$c_day.$username.2} = ('private' => 2,);
		} elsif ($cal_type == 1 && $iamguest) { next;}

		if ($cal_icon eq "") { $cal_icon = "eventinfo"; }

		if ($cal_type2 == 2) { 
			$c_mon = $st_mon;
			$c_year = $bd_year;
			if (($c_mon < $view_mon) || ($c_mon == $view_mon) && ($c_day < $mday) && (!$INFO{'calmon'})) {
				$cd_year = $bd_year + 1;
			} else {
				$cd_year = $bd_year;
			}
			$cal_date = "$cd_year$st_mon$c_day";

		} elsif ($cal_type2 == 3) {
			$c_year = $bd_year;
			if (($c_mon < $view_mon) || ($c_mon == $view_mon) && ($c_day < $mday) && (!$INFO{'calmon'})) {
				$cd_year = $bd_year + 1;
			} else {
				$cd_year = $bd_year;
			}
			$cal_date = "$cd_year$c_mon$c_day";
		}

		if ($CalEventNoName == 2) { $cal_noname = 1; } 
		else { $cal_noname = $cal_noname; }

		%{event.$c_year.$c_mon.$c_day}=(
			'caleventdate' => $cal_date,
			'calyear' => $c_year,
			'calmon' => $c_mon,
			'calday' => $c_day,
			'caltype' => $cal_type,
			'calname' => $cal_name,
			'caltime' => $cal_time,
			'calicon' => $cal_icon,
			'calevent' => $cal_event,
			'calnoname' => $cal_noname,
			'caltype2' => $cal_type2,
		);

		push(@caldata, qq~$cal_date|$cal_type|$cal_name|$cal_time|$cal_event|$cal_icon|$cal_noname|$cal_type2~);
	}

	#<--------------------------------------------->#
	# Event data end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Show/Edit Events begin
	#<--------------------------------------------->#

	if ($INFO{'showthisdate'} || $INFO{'showmini'} || $INFO{'edit_cal_even'}) {
		$event_id = ($INFO{'showthisdate'} == 2 && $do_scramble_id) ? &decloak($INFO{'calid'}) : $INFO{'calid'};
		$event_date = $INFO{'eventdate'};
		$d_year = substr($event_date,0,4);
		$d_mon = substr($event_date,4,2);
		$d_day = substr($event_date,6,2);

		if ($mytimeselected == 1 || $mytimeselected == 5) {
			$cdate = "$d_mon/$d_day/$d_year";
		} elsif ($mytimeselected == 2 || $mytimeselected == 3) {
			$cdate = "$d_day.$d_mon.$d_year";
		} elsif ($mytimeselected == 4 || $mytimeselected == 8) {
			my $sup;
			if ($d_day > 10 && $d_day < 20) {
				$sup = "<sup>$timetxt{'4'}</sup>";
			} elsif ($d_day % 10 == 1) {
				$sup = "<sup>$timetxt{'1'}</sup>";
			} elsif ($d_day % 10 == 2) {
				$sup = "<sup>$timetxt{'2'}</sup>";
			} elsif ($d_day % 10 == 3) {
				$sup = "<sup>$timetxt{'3'}</sup>";
			} else {
				$sup = "<sup>$timetxt{'4'}</sup>";
			}
			$cdate = $mytimeselected == 4 ? qq~$var_cal{"calmon_$d_mon"} $d_day$sup, $d_year~ : qq~$d_day$sup $var_cal{"calmon_$d_mon"}, $d_year~;
		} elsif ($mytimeselected == 6) {
			$cdate = qq~$d_day. $var_cal{"calmon_$d_mon"} $d_year~;
		} else {
			$cdate = "$d_day-$d_mon-$d_year";
		}

		if ($INFO{'showmini'}) {
			if ($seperator) {
				$yymain .= qq~
		<div class="$seperator">
		<table cellpadding="4" cellspacing="1" border="0" width="100%">
		<tr>
			<td align="left" class="$title_class" colspan="2">
				<div style="float: left; width: 30%; padding-top: 1px; padding-bottom: 1px; text-align: left;"><img src="$imagesdir/eventcal.gif" border="0" alt="" /> $var_cal{'caltitle'}</div>
				<div style="float: left; width: 70%; padding-top: 1px; padding-bottom: 1px; text-align: right;">$calgotobox</div>
			</td>
		</tr>
		</table>
		</div>
		~;
			} else {
				$yymain .= qq~
		<table class="tabtitle" cellpadding="0" cellspacing="0" border="0" width="100%" height="38">
		<tr>
			<td class="round_top_left" width="1%" height="25" valign="middle">
				&nbsp;
			</td>
			<td width="1%" valign="middle" align="left">
				<img src="$imagesdir/eventcal.gif" border="0" alt="" />
			</td>
			<td width="28%" valign="middle">$var_cal{'caltitle'}</td>
			<td width="69%" valign="middle" align="right">
				$calgotobox
			</td>
			<td class="round_top_right" width="1%" height="25" valign="middle">
				&nbsp;
			</td>
		</tr>
		</table>~;
			}
			$yymain .= qq~
<table border="0" width="100%" cellspacing="0" cellpadding="0" class="bordercolor">
  <tr>
    <td>
<table cellpadding="4" cellspacing="1" border="0" width="100%">~;

			foreach $cal_events (sort @caldata) {
				my ($cdat,$ctyp,$cnam,$ctim,$ceve,$cico,$cnonam,$ctyp2) = split(/\|/, $cal_events);
				if (!$Show_ColorLinks) {
					$memrealname = (split(/\|/, $memberinf{$cnam}, 3))[1];
				}
				$cdat =~ /(\d{4})(\d{2})(\d{2})/;
				my ($dd_year,$dd_mon,$dd_day) = ($1,$2,$3);
				if ($ctyp2 == 2) { $cdat = "$bd_year$d_mon$dd_day"; } else { $cdat = "$cdat"; }
				if ($ctyp2 == 3) { $cdat = "$bd_year$dd_mon$dd_day"; } else { $cdat = "$cdat"; }
				$delete_event = "";
				$edit_event = "";
				$icon_text = $var_cal{$cico};
				if (!$var_cal{$cico}) { $icon_text = &calicontext($cico); }
				$message = $ceve;
				if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; } &DoUBBC;
				$event_message = $message;

				if ($event_date == $cdat && !$INFO{'edit_cal_even'}) {
					$eventfound = 1;
					if ($cnam eq "Guest") {
						$eventuserlink = $maintxt{'28'};
					} elsif ($Show_ColorLinks) {
						&LoadUser($cnam);
						$eventuserlink = $link{$cnam};
					} else {
						$eventuserlink = qq~<a href="$scripturl?action=viewprofile;username=~ . ($do_scramble_id ? &cloak($cnam) : $cnam) . qq~">$memrealname</a>~;
					}
					$eventbduserlink = $eventuserlink;
					if ($CalEventNoName == 1 && $cnonam == 1 && ($iamadmin || $iamgmod)) { $cnonam = 0; } else { $cnonam = $cnonam; }
					if ($cnonam == 1) { $eventuserlink = ""; } else { $eventuserlink = "($eventuserlink)";}

					if ($cico eq "birthday") {
						$yymain .= qq~
	<tr>
		<td align="left" colspan="2" class="windowbg2">
			<img src="$defaultimagesdir/eventbd.gif" border="0" alt="$var_cal{'calbirthday'}" /> $cdate <b>$var_cal{'calbirthday'}</b>
		</td>
	</tr>
	<tr>
		<td align="left" colspan="2" class="windowbg">
			<b>$var_cal{'calsubtitle'}:</b><br /> <br />
			$eventbduserlink $var_cal{'calis'} $ceve $var_cal{'calold'}<br/><br/>
		</td>
	</tr>~;

					} else {
						$yymain .= qq~
	<tr>
		<td align="left" colspan="2" class="windowbg2">~;

						if ($ctyp == 2) {
							$yymain .= qq~
			<img src="$imagesdir/eventprivate.gif" border="0" alt="Event" /> <img src="$yyhtml_root/EventIcons/$cico.gif" border="0" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink~;
						} else {
							$yymain .= qq~
			<img src="$yyhtml_root/EventIcons/$cico.gif" border="0" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink~;
						}

						$yymain .= qq~
		</td>
	</tr>
	<tr>
		<td align="left" colspan="2" class="windowbg">
			<b>$var_cal{'calsubtitle'}:</b><br /> <br />
			$event_message<br/><br/>
		</td>
	</tr>~;

						if (!$iamguest && ($username eq $cnam || $iamadmin || $iamgmod)) {
							$yymain .= qq~
	<tr>
		<td align="left" colspan="2" class="windowbg">
			<a href="$scripturl?action=get_cal;calshow=1;eventdate=$cdat;calid=$ctim;edit_cal_even=1;addnew=1;edit_typ=$ctyp;edit_icon=$cico;edit_nonam=$cnonam;edit_typ1=$ctyp2" title='$var_cal{'caledit'}'><img src="$imagesdir/modify.gif" alt="$var_cal{'caledit'}" title="$var_cal{'caledit'}" border="0" /> $var_cal{'caledit'}</a>&nbsp;&nbsp;&nbsp;<a href="javascript:if(confirm('$var_cal{'caldelalert'}')){ location.href='$scripturl?action=del_cal;caldel=1;calid=$ctim'; }" title='$var_cal{'caldel'}'><img src="$imagesdir/delete.gif" alt="$var_cal{'caldel'}" title="$var_cal{'caldel'}" border="0" /> $var_cal{'caldel'}</a>
		</td>
	</tr>~;
						}
					}
				}
			}

			if (!exists(${event.$d_year.$d_mon.$d_day}{'calday'}) && !$eventfound && !exists(${bday.$d_year.$d_mon.$d_day}{'calday'})) {
				$yymain .= qq~
	<tr>
		<td align="left" colspan="2" class="windowbg">
			<table>
				<tr>
					<td width=100% valign=top>
						<hr class="hr" />
						<img src="$yyhtml_root/EventIcons/eventinfo.gif" border="0" alt="Event" /> $var_cal{'calnoevent'}
						<hr class="hr" />
					</td>
				</tr>
			</table>
		</td>
	</tr>~;
			}

			$yymain .= qq~
</table>
</td>
</tr>
</table>~;

			$yytitle = $var_cal{'yytitle'};
			&template;
			exit;
		}

		## Show Edit Events ##

		if ($INFO{'edit_cal_even'} || $INFO{'showthisdate'}) {
			if ($seperator) {
				$yymain = qq~
		<div class="$seperator">
		<table cellpadding="4" cellspacing="1" border="0" width="100%">
		<tr>
			<td align="left" class="$title_class" colspan="2">
				<div style="float: left; width: 30%; padding-top: 1px; padding-bottom: 1px; text-align: left;"><img src="$imagesdir/eventcal.gif" border="0" alt="" /> $var_cal{'caltitle'}</div>
				<div style="float: left; width: 70%; padding-top: 1px; padding-bottom: 1px; text-align: right;">$calgotobox</div>
			</td>
		</tr>
		</table>
		</div>
		~;
			} else {
				$yymain = qq~
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td class="tabtitle" width="1%" height="25" valign="middle">
				&nbsp;
			</td>
			<td class="tabtitle" width="29%" height="25" valign="middle" align="left">
				<img src="$imagesdir/eventcal.gif" border="0" alt="" /> $var_cal{'caltitle'}
			</td>
			<td class="tabtitle" width="69%" height="25" valign="middle" align="right">
				$calgotobox
			</td>
			<td class="tabtitle" width="1%" height="25" valign="middle">
				&nbsp;
			</td>
		</tr>
		</table>~;
			}

			$yymain .= qq~
<br />
<div class="$seperator">
<table class="bordercolor" cellpadding="3" cellspacing="1" border="0" width="100%">~;

			foreach $cal_events (sort @caldata) {
				my ($cdat,$ctyp,$cnam,$ctim,$ceve,$cico,$cnonam,$ctyp2) = split(/\|/, $cal_events);
				if (!$Show_ColorLinks) {
					$memrealname = (split(/\|/, $memberinf{$cnam}, 3))[1];
				}
				if ($cico eq "") { $cico = "eventinfo"; }
				$cdat =~ /(\d{4})(\d{2})(\d{2})/;
				my ($dd_year,$dd_mon,$dd_day) = ($1,$2,$3);
				if ($ctyp2 == 2) { $cdat = "$d_year$d_mon$dd_day"; } else { $cdat = "$cdat"; }
				if ($ctyp2 == 3) { $cdat = "$d_year$dd_mon$dd_day"; } else { $cdat = "$cdat"; }
				$delete_event = "";
				$edit_event = "";
				$icon_text = $var_cal{$cico};
				if (!$var_cal{$cico}) { $icon_text = &calicontext($cico); }
				$message = $ceve;
				if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; } &DoUBBC;
				$event_message = $message;

				if ($event_id eq $ctim && $cdat == $event_date) {
					$eventfound = 1;
					if ($cnam eq "Guest") {
						$eventuserlink = $maintxt{'28'};
					} elsif ($Show_ColorLinks) {
						&LoadUser($cnam);
						$eventuserlink = $link{$cnam};
					} else {
						$eventuserlink = qq~<a href="$scripturl?action=viewprofile;username=~ . ($do_scramble_id ? &cloak($cnam) : $cnam) . qq~">$memrealname</a>~;
					}
					$eventbduserlink = $eventuserlink;
					if ($CalEventNoName == 1 && $cnonam == 1 && ($iamadmin || $iamgmod)) { $cnonam = 0; } else { $cnonam = $cnonam; }
					if ($cnonam == 1) { $eventuserlink = ""; } else { $eventuserlink = "($eventuserlink)"; }

					if ($cico eq "birthday" && $cdat == $event_date) {
						$yymain .= qq~
	<tr>
		<td align="left" colspan="2" class="windowbg2">
			<img src="$defaultimagesdir/eventbd.gif" border="0" alt="$var_cal{'calbirthday'}" /> $cdate <b>$var_cal{'calbirthday'}</b>
		</td>
	</tr>
	<tr>
		<td align="left" colspan="2" class="windowbg">
			<b>$var_cal{'calsubtitle'}:</b><br /> <br />
			$eventbduserlink $var_cal{'calis'} $ceve $var_cal{'calold'}<br/><br/>
		</td>
	</tr>~;

					} else {
						$yymain .= qq~
	<tr>
		<td align="left" colspan="2" class="windowbg2">~;
						if ($ctyp == 2) {
							$yymain .= qq~
			<img src="$imagesdir/eventprivate.gif" border="0" alt="Event" /> <img src="$yyhtml_root/EventIcons/$cico.gif" border="0" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink~;
						} else {
							$yymain .= qq~
			<img src="$yyhtml_root/EventIcons/$cico.gif" border="0" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink~;
						}
						$yymain .= qq~
		</td>
	</tr>
	<tr>
		<td align="left" colspan="2" class="windowbg">
			<b>$var_cal{'calsubtitle'}:</b><br /> <br />
			$event_message<br/><br/>
		</td>
	</tr>~;

						if (!$iamguest && ($username eq $cnam || $iamadmin || $iamgmod) && !$INFO{'edit_cal_even'}) {
							$yymain .= qq~
	<tr>
		<td align="left" colspan="2" class="windowbg">
			<a href="$scripturl?action=get_cal;calshow=1;eventdate=$cdat;calid=$ctim;edit_cal_even=1;addnew=1;edit_typ=$ctyp;edit_icon=$cico;edit_nonam=$cnonam;edit_typ1=$ctyp2" title='$var_cal{'caledit'}'><img src="$imagesdir/modify.gif" alt="$var_cal{'caledit'}" title="$var_cal{'caledit'}" border="0" /> $var_cal{'caledit'}</a>&nbsp;&nbsp;&nbsp;<a href="javascript:if(confirm('$var_cal{'caldelalert'}')){ location.href='$scripturl?action=del_cal;caldel=1;calid=$ctim'; }" title="$var_cal{'caldel'}"><img src="$imagesdir/delete.gif" alt="$var_cal{'caldel'}" title="$var_cal{'caldel'}" border="0" /> $var_cal{'caldel'}</a>
		</td>
	</tr>~;
						}
					}

					$yymain .= qq~
</table>
</div>~;

					if ($INFO{'edit_cal_even'} && ($username eq $cnam || $iamadmin || $iamgmod)) {
						$editmessage = $ceve;
						$editmessage =~ s~<\/~\&lt\;/~isg;
						$editmessage =~ s~<br />~\n~g;
						$editmessage =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/ig;
						&ToChars($editmessage);

						$yymain .= qq~
<div class="$seperator">
<table cellpadding="4" cellspacing="1" border="0" width="100%">
	<tr>
		<td align="left" class="catbg">
			<img src="$imagesdir/modify.gif" alt="$var_cal{'caledit'}" title="$var_cal{'caledit'}" border="0" /> $var_cal{'caledit'}
		</td>
	</tr>
	<tr>
		<td class="windowbg2">

$YaBBC_calout

			<br /><br />
			<input type="hidden" name="editid" value="$event_id" />
			<input class="button" type="submit" name="calsubmit" value="$var_cal{'calsave'}" accesskey="s" />
			<br />
		</td>
	</tr>
</table>
</form>
		</td>
	</tr>
</table>
</div>~;

						$yymain =~ s/\{yabb calevent\}/$editmessage/;

					}
				}
			}

			$yytitle = $var_cal{'yytitle'};
			&template;
			exit;
		}
	}

	#<--------------------------------------------->#
	# Show/Edit Events end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Print Events begin
	#<--------------------------------------------->#

	$countdownload = $CD_onoff || 0; # Fix for Countdown Mod by XTC

	$outstring  = qq~ ~;
	if      ($Scroll_Events == 1) {
		$outstring .= "<a name=\"scroller\"></a><marquee behavior='scroll' direction='up' height='130' scrollamount='1' scrolldelay='1' onmouseover='this.stop()' onmouseout='this.start()'>";
	} elsif ($Scroll_Events == 2) {
		$outstring .= "<div style='overflow:auto;height:150px;'>";
	} elsif ($Scroll_Events == 3) {
		$yyinlinestyle .= qq~\n<link rel="stylesheet" href="$forumstylesurl/$usestyle.css" type="text/css" />~;
		$outstring  .= qq~
<script language="JavaScript1.2" type="text/javascript">
<!--
	// initial position
	var countdownmod=$countdownload; 

	window.onload = function() {
		initDOMnews();
		if(countdownmod==1) countdown();
	}

	// initial position
	var startpos=120;
	// end position
	var endpos=-130;
	// scrolling speed
	var speed=10;
	// pause before scrolling again
	var pause=2000;
	// scroller box id
	var newsID='eventcaldata';
	// class to add when js is available
	var classAdd='hasJS';
	var counter=0;
	var total=1;

	var scrollpos=startpos;
	// Initialize scroller
	function initDOMnews() {
		var n=document.getElementById(newsID);
		if(!n){return;}
		n.className=classAdd;
		interval=setInterval('scrollDOMnews()',speed);
	}

	function scrollDOMnews() {
		var n=document.getElementById(newsID).getElementsByTagName('div');

		n[counter].style.top=scrollpos+'px';
		// stop scrolling when it reaches the top
		if (scrollpos==0) {
			clearInterval(interval);
			setTimeout("interval=setInterval('scrollDOMnews()',speed);", pause)
		}
		if (scrollpos==endpos) {
			counter++;
			if (!n[counter]) {
				counter=0;
			}
			(n[counter]) ? counter : counter=0;
			scrollpos=startpos;
		}
		scrollpos = scrollpos - 1;
	}
// -->
</script>
	<div id="eventcaldata">~;
	}
	if ($Scroll_Events != 3) {
		$outstring .= qq~<table width="90%" border="0">~;
	}

	my ($caleventbegin,$caleventend);
	if ($ssicaldisplay) { $DisplayEvents = $ssicaldisplay; }
	if (!$DisplayEvents) {
		$DisplayEvents = 0;
	} else {
		my ($d_cal,$m_cal,$y_cal);
		(undef,undef,undef,$d_cal,$m_cal,$y_cal,undef,undef,undef) = gmtime($daterechnug + (86400 * $DisplayEvents));
		$m_cal++;
		$y_cal += 1900;
		$caleventbegin = "$year"  . sprintf("%02d",$mon)   . sprintf("%02d",$mday);
		$caleventend   = "$y_cal" . sprintf("%02d",$m_cal) . sprintf("%02d",$d_cal);
	}
	foreach $cal_events (sort @caldata) {
		my ($cdate,$ctype,$cname,$ctime,$cevent,$cicon,$cnoname,$ctype2) = split(/\|/, $cal_events);
		if (!$Show_ColorLinks) {
			$memrealname = (split(/\|/, $memberinf{$cname}, 3))[1];
		}
		$cdate =~ /(\d{4})(\d{2})(\d{2})/;
		my ($cyear,$cmon,$cday) = ($1,$2,$3);
		if ($DisplayEvents > 0 && !$INFO{'calyear'}) {
			if ($cdate >= $caleventbegin && $cdate <= $caleventend) { $event_found = 1; } else { $event_found = 0; }
			if ($DisplayEvents == 1) { $event_index = qq~$var_cal{'caltoday'} $var_cal{'calsubtitle'}:~; } else { $event_index = qq~$var_cal{'calcoming'} $var_cal{'calsubtitle'} ($DisplayEvents $var_cal{'caldays'}):~; }
		} else {
			if ($view_mon == $cmon && $year == $cyear) { $event_found = 1; } else { $event_found = 0;}
			if ($INFO{'calyear'} || $DisplayEvents == 0) { $event_index = qq~$var_cal{$st} $year - $var_cal{'calsubtitle'}:~; }
		}

		if ($cicon eq "") { $cico = "eventinfo"; }
		if ($CalShortEvent && length($cevent) > $CalShortEvent) {
			unless ($ctime eq "birthday") {
				if ($enable_ubbc && $No_ShortUbbc == 1) {
					$cevent =~ s~\[url(.*?)\](.*?)\[\/url\]~$2~isg;
					$cevent =~ s~\[ftp(.*?)\](.*?)\[\/ftp\]~$2~isg;
					$cevent =~ s~\[email(.*?)\](.*?)\[\/email\]~$2~isg;
					$cevent =~ s~\[link(.*?)\](.*?)\[\/link\]~$2~isg;
					$cevent =~ s~\[img\](.*?)\[\/img\]~~ig;
					$cevent =~ s~\[media\](.*?)\[\/media\]~~ig;
					$cevent =~ s~\[b\](.*?)\[/b\]~*$1*~isg;
					$cevent =~ s~\[i\](.*?)\[/i\]~/$1/~isg;
					$cevent =~ s~\[u\](.*?)\[/u\]~_$1_~isg;
					$cevent =~ s~\[.*?\]~~g;
					$cevent =~ s~https?://~~ig;
				}
				$convertstr = $cevent;
				$convertcut = $CalShortEvent;
				&CountChars;
				$cevent = $convertstr;
				$cevent .= " ..." if $cliped;
				$cevent .= qq~<br /><br /><a  href="$scripturl?action=get_cal;calshow=1;eventdate=$cyear$cmon$cday;calid=$ctime;showthisdate=1" title="$var_cal{'calshowevent'}"><font color="#FF6600">$var_cal{'calmore'}</font> <img  src="$defaultimagesdir/eventmore.gif" border="0" alt="$var_cal{'calshowevent'}" /></a>~; # There MUST be two spaces after "<a" and "<img" here or you will get this message here after going through &DoUBBC: "Multimedia File Viewing and Clickable Links are available for Registered Members only!! You need to Login or Register"
			}
		}
		if ($enable_ubbc) {
			$message = $cevent;
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC;
			$cevent = $message;
		}

		if ($event_found == 1) {
			if ($mytimeselected == 1 || $mytimeselected == 5) {
				$cdate = "$cmon/$cday/$cyear";
			} elsif ($mytimeselected == 2 || $mytimeselected == 3) {
				$cdate = "$cday.$cmon.$cyear";
			} elsif ($mytimeselected == 4 || $mytimeselected == 8) {
				my $sup;
				if ($cday > 10 && $cday < 20) {
					$sup = "<sup>$timetxt{'4'}</sup>";
				} elsif ($cday % 10 == 1) {
					$sup = "<sup>$timetxt{'1'}</sup>";
				} elsif ($cday % 10 == 2) {
					$sup = "<sup>$timetxt{'2'}</sup>";
				} elsif ($cday % 10 == 3) {
					$sup = "<sup>$timetxt{'3'}</sup>";
				} else {
					$sup = "<sup>$timetxt{'4'}</sup>";
				}
				$cdate = $mytimeselected == 4 ? qq~$var_cal{"calmon_$cmon"} $cday$sup, $cyear~ : qq~$cday$sup $var_cal{"calmon_$cmon"}, $cyear~;
			} elsif ($mytimeselected == 6) {
				$cdate = qq~$cday. $var_cal{"calmon_$cmon"} $cyear~;
			} else {
				$cdate = "$cday-$cmon-$cyear";
			}
			$cdate = "<a href=\"$scripturl?action=get_cal;calshow=1;eventdate=$cyear$cmon$cday;calid=" . ($do_scramble_id ? &cloak($ctime) : $ctime) . ";showthisdate=2\" title=\"$var_cal{'calshowevent'}\">$cdate</a>";
			$cal_time = &stringtotime( $ctime );
			$icon_text = "$var_cal{$cicon}";
			if (!$var_cal{$cicon}) { $icon_text = &calicontext($cicon); }
			if ($cname eq "Guest") {
				$eventuserlink = $maintxt{'28'};
			} elsif ($Show_ColorLinks) {
				&LoadUser($cname);
				$eventuserlink = $link{$cname};
			} else {
				$eventuserlink = qq~<a href="$scripturl?action=viewprofile;username=~ . ($do_scramble_id ? &cloak($cname) : $cname) . qq~">$memrealname</a>~;
			}
			$eventbduserlink = $eventuserlink;
			if ($CalEventNoName == 1 && $cnoname == 1 && ($iamadmin || $iamgmod)) { $cnoname = 0; } else { $cnoname = $cnoname; }
			if ($cnoname == 1) { $eventuserlink = ""; } else { $eventuserlink = "($eventuserlink)"; }
			if ($Scroll_Events == 3) {
				if ($cicon eq "birthday") {
					$outstring .="<div><span class=\"small\"><img src=\"$defaultimagesdir/eventbd.gif\" border=\"0\" alt=\"$var_cal{'calbirthday'}\" /> $cdate <b>$var_cal{'calbirthday'}</b><br /> $eventbduserlink $var_cal{'calis'} $cevent $var_cal{'calold'}</span><hr class=\"hr\" size=\"1\" /></div>";
				} elsif ($ctype == 2) {
					$outstring .="<div><span class=\"small\"><img src=\"$defaultimagesdir/eventprivate.gif\" border=\"0\" alt=\"$var_cal{'calprivate'} Event\" /> <img src=\"$yyhtml_root/EventIcons/$cicon.gif\" border=\"0\" alt=\"$icon_text\" /> $cdate <b>$icon_text</b> $eventuserlink<br />$cevent</span><hr class=\"hr\" size=\"1\" /></div>";
				} else {
					$outstring .="<div><span class=\"small\"><img src=\"$yyhtml_root/EventIcons/$cicon.gif\" border=\"0\" alt=\"$icon_text\" /> $cdate <b>$icon_text</b> $eventuserlink<br />$cevent</span><hr class=\"hr\" size=\"1\" /></div>";
				}
			} else {
				if ($cicon eq "birthday") {
					$outstring .="<tr><td width=\"100%\" valign=\"top\"><span class=\"small\"><img src=\"$defaultimagesdir/eventbd.gif\" border=\"0\" alt=\"$var_cal{'calbirthday'}\" /> $cdate <b>$var_cal{'calbirthday'}</b><br /> $eventbduserlink $var_cal{'calis'} $cevent $var_cal{'calold'}</span><hr class=\"hr\" size=\"1\" /></td></tr>";
				} elsif ($ctype == 2) {
					$outstring .="<tr><td width=\"100%\" valign=\"top\"><span class=\"small\"><img src=\"$defaultimagesdir/eventprivate.gif\" border=\"0\" alt=\"$var_cal{'calprivate'} Event\" /> <img src=\"$yyhtml_root/EventIcons/$cicon.gif\" border=\"0\" alt=\"$icon_text\" /> $cdate <b>$icon_text</b> $eventuserlink<br />$cevent</span><hr class=\"hr\" size=\"1\" /></td></tr>";
				} else {
					$outstring .="<tr><td width=\"100%\" valign=\"top\"><span class=\"small\"><img src=\"$yyhtml_root/EventIcons/$cicon.gif\" border=\"0\" alt=\"$icon_text\" /> $cdate <b>$icon_text</b> $eventuserlink<br />$cevent</span><hr class=\"hr\" size=\"1\" /></td></tr>";
				}
			}
		}
	}
	if ($Scroll_Events != 3) { $outstring .= "</table>"; }
	if ($Scroll_Events == 1) { $outstring .= "</marquee>"; }
	if ($Scroll_Events == 2 || $Scroll_Events == 3) { $outstring .= "</div><br />"; }

	#<--------------------------------------------->#
	# Print Events end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Print Mini EventCal begin
	#<--------------------------------------------->#

	if ($Show_BirthdaysList) {
		unless ($iamguest && ($Show_BirthdaysList == 1)) {
			$ShowBirthdaysLink = qq~<span class="small"> <img src="$defaultimagesdir/eventmore.gif" border="0" alt="$var_calpost{'var_cal'}" /> <a href="$scripturl?action=cal_birthdaylist">$var_cal{'calbdaylist'}</a></span>~;
		}
	}
	if ($Allow_Event_Imput && !$INFO{'addnew'} == 1) {
		$ShowEventAddLink = qq~<br /><span class="small"> <img src="$defaultimagesdir/eventmore.gif" border="0" alt="$var_calpost{'getaddevent'}" /> <a href="$scripturl?action=get_cal;calshow=1;addnew=1">$var_calpost{'getaddevent'}</a></span>~;
	}

	$mon_name=$var_cal{$st};

	if ($mon == 2) {
		if ($year%4 == 0) { $days=29; }
	}
	for ($i=1;$i<8;$i++) {
		$st = "calday_$i";
		$dstr[$i-1] = qq~<td width="14%" class="titlebg" align="center"><span class="small"><b>$var_cal{$st}</b></span></td>~;
	}
	$dcnt = 0;
	$e_day = $wday1;
	if ($wday1 > 1) {
		$cal_out = "<tr>";
		for ($i = 1; $i < $wday1; $i++) {
			$cal_out .= qq~<td width="14%" class="windowbg">&nbsp;</td>~;
		}
	}
	if (!$Event_TodayColor) { $Event_TodayColor = "#FF0000"; }

	for ($i = 1; $i <= $days; $i++) {
		$dddd = $i;
		if ($dddd < 10) { $dddd = "0$dddd"; }

		$sel = "<span class=\"small\">$i</span>";
		if ($i == $callnewday && $mon == $callnewmonth && $year == $callnewyear) {
			$sel = "<span class=\"small\"><font color=\"$Event_TodayColor\"><b>$i</b></font></span>";
		}

		$cal_pic = '';
		if (!exists(${event.$year.$view_mon.$dddd}{'calday'}) && exists(${bday.$year.$view_mon.$dddd}{'calday'})) {
			$cal_pic = "$defaultimagesdir/eventbd.gif";
		}
		if (exists(${event.$year.$view_mon.$dddd}{'calday'}) && !exists(${bday.$year.$view_mon.$dddd}{'calday'})) {
			$cal_pic = "$yyhtml_root/EventIcons/eventinfo.gif";
		}
		if (exists(${event.$year.$view_mon.$dddd}{'calday'}) && exists(${bday.$year.$view_mon.$dddd}{'calday'})) {
			$cal_pic = "$defaultimagesdir/eventinfobd.gif";
		}
		if (exists(${private.$year.$view_mon.$dddd.$username.2}{'private'})) {
			$cal_pic = "$defaultimagesdir/eventprivate.gif";
		}
		if ($Show_MiniCalIcons) { $cal_pic = ''; }

		$cal_out = "<tr>" if !$cal_out;
		if (exists(${bday.$year.$view_mon.$dddd}{'calday'}) || exists(${event.$year.$view_mon.$dddd}{'calday'})) {
			$cal_out .= qq~	<td width="14%" class="windowbg2" style="background-image:URL('$cal_pic'); background-repeat:no-repeat;" align="center"><a href="$scripturl?action=get_cal;calshow=1;eventdate=$year$view_mon$dddd;showmini=1" title='$var_cal{'calshowmini'}'><u>$sel</u></a></td>\n~;
		} else {
			$cal_out .= qq~	<td width="14%" class="windowbg2" align="center">$sel</td>\n~;
		}

		$e_day++;
		$wday1++;
		if ($wday1 > 7 && $i != $days) {
			$wday1 = 1;
			$cal_out .= "</tr><tr>\n";
		}
	}
	$endrow = 42;
	if ($e_day < 36) { $endrow = 35; }
	$endday = $endrow-$e_day+2;
	if ($endday < 8) {
		$cal_out = "<tr>\n" if !$cal_out && $endday > 1;
		for ($i = 1; $i < $endday; $i++) {
			$cal_out .= qq~	<td width="14%" class="windowbg">&nbsp;</td>\n~;
		}
	}
	$cal_out .= "</tr>\n" if $cal_out;

	if ($ShowSunday) {
		$weekdays = qq~$dstr[6]$dstr[0]$dstr[1]$dstr[2]$dstr[3]$dstr[4]$dstr[5]~;
	} else {
		$weekdays = qq~$dstr[0]$dstr[1]$dstr[2]$dstr[3]$dstr[4]$dstr[5]$dstr[6]~;
	}

	#<--------------------------------------------->#
	# Print Mini EventCal end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# EventCal Output begin
	#<--------------------------------------------->#

	if ($outstring !~ /$yyhtml_root\//) {
		$outstring = "<table><tr><td width=\"100%\" valign=\"top\"><span class=\"small\"><img src=\"$yyhtml_root/EventIcons/eventinfo.gif\" border=\"0\" alt=\"Event\" /> $var_cal{'calnoevent'}</span><hr class=\"hr\" size=\"1\" /></td></tr></table>";
	}

	my $cal_display;
	if ($seperator) {
		$cal_display = qq~
<tr>
	<td align="left" class="$title_class" colspan="2">
		<div style="float: left; width: 30%; padding-top: 1px; padding-bottom: 1px; text-align: left;"><img src="$imagesdir/eventcal.gif" border="0" alt="" /> $var_cal{'caltitle'}</div>
		<div style="float: left; width: 70%; padding-top: 1px; padding-bottom: 1px; text-align: right;">$calgotobox</div>
	</td>
</tr>
~;
	} else {
		$cal_display = qq~
<tr>
	<td class="round_top_left" width="1%" height="25" valign="middle">
		&nbsp;
	</td>
	<td width="29%" height="25" valign="middle" align="left">
		$var_cal{'caltitle'}
	</td>
	<td height="25" valign="middle" align="right">
		$calgotobox
	</td>
	<td class="round_top_right" width="1%" height="25" valign="middle">
		&nbsp;
	</td>
</tr>
</table>
<table class="bordercolor" cellpadding="3" cellspacing="1" border="0" width="100%">~;
	}

	$cal_display .= qq~
<tr>
	<td class="windowbg" width="5%" valign="middle" align="center">
		<img src="$imagesdir/eventcal.gif" border="0" alt="" />
	</td>

	<td class="windowbg2">
		<table width="100%">
		<tr>
			<td width="30%">
				<table width="100%" cellpadding="0" cellspacing="1">
				<tr>
					<td class="windowbg">~;

	$cal_displayssi = qq~<table width="100%" border="0" cellpadding="3" cellspacing="1">
						<tr>
							<td align="center" class="$title_class"><span class="small">$last_link</span></td>
							<td colspan="5" align="center" class="$title_class"><span class="small"><b>$mon_name $year</b></span></td>
							<td align="center" class="$title_class"><span class="small">$next_link</span></td>
						</tr>
						<tr>
							$weekdays
						</tr>
						$cal_out
					</table>~;

	$cal_display .= qq~
					$cal_displayssi
					</td>
				</tr>
				</table>
				$ShowBirthdaysLink
				$ShowEventAddLink
			</td>
			<td class="windowbg2" width="70%" align="left" valign="top">~;

	if ($DisplayCalEvents || $INFO{'calshow'}) {
		$cal_display .= qq~
				<b>$event_index</b><br />
				$outstring~;
	}

	$cal_display .= qq~
			&nbsp;</td>
		</tr>
		</table>~;

	if ($Allow_Event_Imput) {
		$cal_display .= qq~
	</td>
</tr>~;

		if ($INFO{'addnew'} == 1) {
			$cal_display .= qq~
<tr>
	<td class="windowbg" width="5%" valign="middle" align="center">
		<img src="$imagesdir/modify.gif" border="0" alt="" />
	</td>
	<td class="windowbg2">$YaBBC_calout</td>
</tr>~;
		}

	}

	## Print EventCal SSI ##
	if ($ssicalmode == 1) { return $cal_display; exit; }
	elsif ($ssicalmode == 2) { return $cal_displayssi; exit; } 
	elsif ($ssicalmode == 3) { return $outstring; exit; }

####################################################################################################################

	## Print EventCal in new window ##
	if ($INFO{'calshow'} == 1) {
		$yymain .= $seperator ? qq~
		<div class="$seperator">
		<table cellpadding="4" cellspacing="1" border="0" width="100%">
			$cal_display
		</table>
		</div>
		~ : qq~
		<table class="tabtitle" cellpadding="0" cellspacing="0" border="0" width="100%">
			$cal_display
		</table>
		~;

		$yytitle = $var_cal{'yytitle'};
		&template;
	}

	if ($seperator) {
		$cal_display;
	} else {
		qq~
<table class="tabtitle" cellpadding="0" cellspacing="0" border="0" width="100%">
		$cal_display
</table>~;
	}
}

#<--------------------------------------------->#
# EventCal Output end
#<--------------------------------------------->#

#<--------------------------------------------->#
# EventCal Subs begin
#<--------------------------------------------->#

## Delete Events ##

sub del_cal {
	if ($iamguest) { &fatal_error('not_allowed'); }
	if ($INFO{'caldel'} == 1) {
		if (&checkfor_DBorFILE("$vardir/eventcal.db")) {
			&write_DBorFILE(0,'',$vardir,'eventcal','db',grep(!/$INFO{'calid'}/, &read_DBorFILE(1,'',$vardir,'eventcal','db')));
		}
	}

	&del_old_events;
	$yySetLocation = qq~$scripturl?action=get_cal;calshow=1~;
	&redirectexit;
}

## Add Events ##

sub add_cal {
	if (!$Show_EventCal || ($iamguest && $Show_EventCal != 2)) { &fatal_error('not_allowed'); }
	if ($iamguest && $gpvalid_en) {
		require "$sourcedir/Decoder.pl";
		&validation_check($FORM{'verification'});
	}
	if (length($FORM{'message'}) > 0) {
		$calmessage = $FORM{'message'};
		$calmessage =~ s/\|//g;
		$calmessage =~ s/\cM//g;
		$calmessage =~ s~\:\`\(~\:\'\(~g;
		$calmessage =~ s~\[([^\]]{0,30})\n([^\]]{0,30})\]~\[$1$2\]~g;
		$calmessage =~ s~\[/([^\]]{0,30})\n([^\]]{0,30})\]~\[/$1$2\]~g;
		$calmessage =~ s~(\w+://[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)~$1\n$2~g;
		&FromChars($calmessage);
		&ToHTML($calmessage);
		$calmessage =~ s~\t~ \&nbsp; \&nbsp; \&nbsp;~g;
		$calmessage =~ s~\n~<br />~g;
		$calmessage =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/g;

		my @calinput = &read_DBorFILE(1,'',$vardir,'eventcal','db');
		if ($FORM{'editid'}) {
			for (my $i = 0; $i < @calinput; $i++) {
				($c_date,$c_type,$c_name,$c_time,$c_event,$c_icon,$c_noname,$c_type2) = split(/\|/, $calinput[$i]);
				if($c_time == $FORM{'editid'}){
					$calinput[$i] = "$FORM{'selyear'}$FORM{'selmon'}$FORM{'selday'}|$FORM{'caltype'}|$c_name|$c_time|$calmessage|$FORM{'calicon'}|$FORM{'calnoname'}|$FORM{'caltype2'}\n";
				} else {
					$calinput[$i] = "$c_date|$c_type|$c_name|$c_time|$c_event|$c_icon|$c_noname|$c_type2";
				}
			}

		} else {
			push(@calinput, "$FORM{'selyear'}$FORM{'selmon'}$FORM{'selday'}|$FORM{'caltype'}|$username|$date|$calmessage|$FORM{'calicon'}|$FORM{'calnoname'}|$FORM{'caltype2'}\n");
		}
		&write_DBorFILE(0,'',$vardir,'eventcal','db',@calinput);

		if (!$iamguest && ${$uid.$username}{'postlayout'} ne qq~$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}~) {
			${$uid.$username}{'postlayout'} = qq~$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}~;
			&UserAccount($username, "update");
		}
	}

	&del_old_events;
	$yySetLocation = qq~$scripturl?action=get_cal;calshow=1;calmon=$FORM{'selmon'};calyear=$FORM{'selyear'}~;
	&redirectexit;
}

## Delete old events ##

sub del_old_events {
	return if $Delete_EventsUntil < 1;

	my $caltoday = $Delete_EventsUntil;
	if ($caltoday == 1) {
		my $toffs = $timeoffset;
		$toffs += (localtime($date + (3600 * $toffs)))[8] ? $dstoffset : 0;

		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$dst) = gmtime($date + (3600 * $toffs));
		$year += 1900;
		$mon++;
		$caltoday = $year . sprintf("%02d", $mon) . sprintf("%02d", $mday);
	}

	my @calinput = &read_DBorFILE(1,'',$vardir,'eventcal','db');
	for (my $i = 0; $i < @calinput; $i++) {
		($c_date,undef,undef,undef,undef,undef,undef,$c_type2) = split(/\|/, $calinput[$i]);
		chop $c_type2;
		if ($c_date < $caltoday && $c_type2 < 2) { $calinput[$i] = ''; }
	}
	&write_DBorFILE(0,'',$vardir,'eventcal','db',@calinput);
}

## Event Icon ##

sub calicontext {
	my $currenticon = $_[0];

	eval{ require "$vardir/eventcalIcon.txt"; };
	my $i = 0;
	while ($CalIconURL[$i]) {
		if ($CalIconURL[$i] eq "$currenticon") { $icon_out = "$CalIDescription[$i]"; }
		$i++;
	}

	$icon_out;
}

#<--------------------------------------------->#
# EventCal Subs end ----> !!! Finish EventCal !!!
#<--------------------------------------------->#

1;
