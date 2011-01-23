###############################################################################
# EventCalBirthdays.pl                                                        #
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

$eventcalbirthdaysplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('EventCal');

sub cal_birthdaylist {
	if (!$Show_BirthdaysList || ($iamguest && $Show_BirthdaysList != 2)) { &fatal_error('not_allowed'); }

	(undef, undef, undef, undef, undef, undef, undef, undef, $newisdst) = localtime($heute);
	if ($newisdst > 0) { $userdst = ${$uid.$username}{'dsttimeoffset'} || $dstoffset; $dst = 1; }
	$heute = $date;

	if ($iamguest) {
		$toffs   = $timeoffset;
		$dstoffs = $dstoffset;
	} else {
		$toffs   = ${$uid.$username}{'timeoffset'};
		$dstoffs = $userdst;
	}
	($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $dst) = gmtime($heute + (3600 * ($toffs + $dstoffs)));
	$year += 1900;
	$mon = $mon+1;
	$actualmon = $mon;
	$actualday = $mday;
	if ($actualmon < 10) { $actualmon = "0$actualmon"; }
	if ($actualday < 10) { $actualday = "0$actualday"; }

	&timeformat(); # get only correct $mytimeselected


	#<--------------------------------------------->#
	# GoTo begin
	#<--------------------------------------------->#

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
		$boxdays .= "		<option value=\"" . sprintf("%02d",$i) . "\"$sel>$i</option>\n";
	}
	$boxdays .= "	</select>";

	my $boxmonths = qq~ <label for="selmon"><span class="small">$var_cal{'calmonth'}</span></label>
	<select class="input" name="selmon" id="selmon">\n~;
	for ($i = 1; $i < 13; $i++) {
		my $sel = "";
		if ($mon == $i && !$sel_mon) {
			$sel = ' selected="selected"';
		} elsif ($sel_mon == $i) {
			$sel = ' selected="selected"';
		}
		$boxmonths .= "		<option value=\"" . sprintf("%02d",$i) . "\"$sel>$i</option>\n";
	}
	$boxmonths .= "	</select>";

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
		$boxyears .= qq~		<option value="$i"$sel>$i</option>\n~;
	}
	$boxyears .= "	</select>";

	my $calgotobox = qq~
	<form action="$scripturl?action=get_cal;calshow=1;calgotobox=1" method="post">
	<span class="small"><b>$var_cal{'calsubmit'}</b></span>~;

	if ($mytimeselected == 6 || $mytimeselected == 3 || $mytimeselected == 2) {
		$calgotobox .= $boxdays . $boxmonths;
	} else {
		$calgotobox .= $boxmonths . $boxdays;
	}
	$calgotobox .= qq~$boxyears
	&nbsp; <input type="submit" name="Go" value="$var_cal{'calgo'}" />
	</form>\n~;

	#<--------------------------------------------->#
	# GoTo end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Begin Birthdaylist
	#<--------------------------------------------->#

	my $sortiert = $INFO{'sort'};
	my $letter   = lc($INFO{'letter'});

	#<--------------------------------------------->#
	# Add Star sign and age begin
	#<--------------------------------------------->#

	&ManageMemberinfo("load");

	my @birthmembers = &read_DBorFILE(1,'',$vardir,'eventcalbday','db');

	my @birthmembers1 = ();
	foreach $user_name (@birthmembers) {
		chomp $user_name;
		($user_bdyear, $user_bdmon, $user_bdday, $user_bdname) = split(/\|/,$user_name);

		$memrealname = (split(/\|/, $memberinf{$user_bdname}, 3))[1];

 		if (($user_bdmon < $actualmon) || (($user_bdmon == $actualmon) && ($user_bdday <= $actualday))) {
			$age = $year-$user_bdyear;
		} else { $age = $year-$user_bdyear; $age-- }

		if ($user_bdday >= 1 && $user_bdday <= 20 && $user_bdmon == 1) {
			$sternzeichen = "$var_cal{'Capricorn'}"; }
		elsif ($user_bdday >= 21 && $user_bdday <= 31 && $user_bdmon == 1) {
			$sternzeichen = "$var_cal{'Aquarius'}"; } 
		elsif ($user_bdday >= 1 && $user_bdday <= 19 && $user_bdmon == 2) {
			$sternzeichen = "$var_cal{'Aquarius'}"; } 
		elsif ($user_bdday >= '20' && $user_bdday <= 29 && $user_bdmon == 2) {
			$sternzeichen = "$var_cal{'Pisces'}"; } 
		elsif ($user_bdday >= 1 && $user_bdday <= 20 && $user_bdmon == 3) {
			$sternzeichen = "$var_cal{'Pisces'}"; } 
		elsif ($user_bdday >= 21 && $user_bdday <= 31 && $user_bdmon == 3) {
			$sternzeichen = "$var_cal{'Aries'}"; } 
		elsif ($user_bdday >= 1 && $user_bdday <= 20 && $user_bdmon == 4) {
			$sternzeichen = "$var_cal{'Aries'}"; } 
		elsif ($user_bdday >= 21 && $user_bdday <= 30 && $user_bdmon == 4) {
			$sternzeichen = "$var_cal{'Taurus'}"; } 
		elsif ($user_bdday >= 1 && $user_bdday <= 20 && $user_bdmon == 5) {
			$sternzeichen = "$var_cal{'Taurus'}"; } 
		elsif ($user_bdday >= 21 && $user_bdday <= 31 && $user_bdmon == 5) {
			$sternzeichen = "$var_cal{'Gemini'}"; } 
		elsif ($user_bdday >= 1 && $user_bdday <= 21 && $user_bdmon == 6) {
			$sternzeichen = "$var_cal{'Gemini'}"; } 
		elsif ($user_bdday >= 22 && $user_bdday <= 30 && $user_bdmon == 6) {
			$sternzeichen = "$var_cal{'Cancerian'}"; } 
		elsif ($user_bdday >= 1 && $user_bdday <= 22 && $user_bdmon == 7) {
			$sternzeichen = "$var_cal{'Cancerian'}"; } 
		elsif ($user_bdday >= 23 && $user_bdday <= 31 && $user_bdmon == 7) {
			$sternzeichen = "$var_cal{'Leo'}"; } 
		elsif ($user_bdday >= 1 && $user_bdday <= 23 && $user_bdmon == 8) {
			$sternzeichen = "$var_cal{'Leo'}"; } 
		elsif ($user_bdday >= 24 && $user_bdday <= 31 && $user_bdmon == 8) {
			$sternzeichen = "$var_cal{'Virgo'}"; } 
		elsif ($user_bdday >= 1 && $user_bdday <= 23 && $user_bdmon == 9) {
			$sternzeichen = "$var_cal{'Virgo'}"; } 
		elsif ($user_bdday >= 24 && $user_bdday <= 30 && $user_bdmon == 9) {
			$sternzeichen = "$var_cal{'Libra'}"; } 
		elsif ($user_bdday >= 1 && $user_bdday <= 23 && $user_bdmon == 10) {
			$sternzeichen = "$var_cal{'Libra'}"; } 
		elsif ($user_bdday >= 24 && $user_bdday <= 31 && $user_bdmon == 10) {
			$sternzeichen = "$var_cal{'Scorpio'}"; } 
		elsif ($user_bdday >= 1 && $user_bdday <= 22 && $user_bdmon == 11) {
			$sternzeichen = "$var_cal{'Scorpio'}"; } 
		elsif ($user_bdday >= 23 && $user_bdday <= 30 && $user_bdmon == 11) {
			$sternzeichen = "$var_cal{'Sagittarius'}"; } 
		elsif ($user_bdday >= 1 && $user_bdday <= 21 && $user_bdmon == 12) {
			$sternzeichen = "$var_cal{'Sagittarius'}"; } 
		elsif ($user_bdday >= 22 && $user_bdday <= 31 && $user_bdmon == 12) {
			$sternzeichen = "$var_cal{'Capricorn'}";
		}

		$string = "$user_bdyear|$user_bdmon|$user_bdday|$user_bdname|$age|$sternzeichen|$memrealname\n";
		push (@birthmembers1, $string);
	}
	undef %memberinf;

	#<--------------------------------------------->#
	# Add Star sign and age end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# What sort we use?
	#<--------------------------------------------->#

	if (!$sortiert) { $sortiert = 'sortdate';}

	#<--------------------------------------------->#
	# What sort we use end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# sorting <dt> style begin
	#<--------------------------------------------->#

	${"class_$sortiert"} = ' class="windowbg"';
	${"styleletter_$letter"} = ' class="catbg"';

	if (!$class_sortuser) { $class_sortuser = ' class="catbg"'; }
	if (!$class_sortage) { $class_sortage = ' class="catbg"'; }
	if (!$class_sortstarsign) { $class_sortstarsign = ' class="catbg"'; }
	if (!$class_sortdate) { $class_sortdate = ' class="catbg"'; }

	#<--------------------------------------------->#
	# sorting <dt> style end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# view birthdays begin
	#<--------------------------------------------->#

	if (!@birthmembers1) {
		$viewbirthdays .= qq~<tr><td class="windowbg2" colspan="4"><center><b><i>$var_cal{'calbirthday1'}</i></b></center></td></tr>~;
	} else {
		foreach $user_name (sort { &$sortiert($a,$b); } @birthmembers1) {
			chomp $user_name;
			($user_bdyear, $user_bdmon, $user_bdday, $user_bdname, $age, $sternzeichen, $user_bdrealname) = split(/\|/,$user_name);

			#<--------------------------------------------->#
			# what birthday should we show begin
			#<--------------------------------------------->#

			if ($user_bdmon == $actualmon && $user_bdday == $actualday) {
				if ($Show_BdColorLinks) {
					&LoadUser($user_bdname);
					$user_linkprofile = $link{$user_bdname};
				} else {
					$user_linkname = $user_bdrealname;
					$user_linkprofile = qq~<a href="$scripturl?action=viewprofile;username=~ . ($do_scramble_id ? &cloak($user_bdname) : $user_bdname) . qq~">$user_linkname</a>~;
				}
				$bd_today .=qq~$user_linkprofile <span class="small">($age)</span>, ~;
			}

			$showviewbd = 0;
			if ($letter) {
				$searchbdname = $user_bdrealname;
				$searchbdname ||= $user_bdname;
				if ($letter ne "other") {
					$showviewbd = 1 if $searchbdname =~ /^$letter/i;
				} elsif ($searchbdname !~ /^[a-z]/i) { $showviewbd = 1; }
			} else {
				$showviewbd = 1;
			}

			#<--------------------------------------------->#
			# what birthday should we show end
			#<--------------------------------------------->#

			if ($showviewbd) {
				my $cdate = $var_cal{'hidden'};
				if ($Show_BirthdayDate == 2 || ($Show_BirthdayDate == 1 && !$iamguest)) {
					## User date display begin ##
					if ($mytimeselected == 1 || $mytimeselected == 5) {
						$cdate = "$user_bdmon/$user_bdday/$user_bdyear";
					} elsif ($mytimeselected == 2 || $mytimeselected == 3) {
						$cdate = "$user_bdday.$user_bdmon.$user_bdyear";
					} elsif ($mytimeselected == 4) {
						my $sup;
						if ($user_bdday > 10 && $user_bdday < 20) {
							$sup = "<sup>$timetxt{'4'}</sup>";
						} elsif ($user_bdday % 10 == 1) {
							$sup = "<sup>$timetxt{'1'}</sup>";
						} elsif ($user_bdday % 10 == 2) {
							$sup = "<sup>$timetxt{'2'}</sup>";
						} elsif ($user_bdday % 10 == 3) {
							$sup = "<sup>$timetxt{'3'}</sup>";
						} else {
							$sup = "<sup>$timetxt{'4'}</sup>";
						}
						$cdate = qq~$var_cal{"calmon_$user_bdmon"} $user_bdday$sup, $user_bdyear~;
					} elsif ($mytimeselected == 6) {
						$cdate = qq~$user_bdday. $var_cal{"calmon_$user_bdmon"} $user_bdyear~;
					} else {
						$cdate = "$user_bdday-$user_bdmon-$user_bdyear";
					}
					## User date display end ##
				}

				if ($Show_BdColorLinks) {
					&LoadUser($user_bdname);
					$user_linkprofile = $link{$user_bdname};
				} else {
					$user_linkname = $user_bdrealname;
					$user_linkprofile = qq~<a href="$scripturl?action=viewprofile;username=~ . ($do_scramble_id ? &cloak($user_bdname) : $user_bdname) . qq~">$user_linkname</a>~;
				}

				#<--------------------------------------------->#
				# handle with the months begin
				#<--------------------------------------------->#

				if ($user_bdmon == 1 || $user_bdmon == '1') {
					$view_January .= qq~	<tr><td class="windowbg2" align="center" valign="middle" width="30%">$user_linkprofile</td><td class="windowbg2" align="center" valign="middle" width="20%">$age</td><td class="windowbg2" align="center" valign="middle" width="30%">$sternzeichen</td><td class="windowbg2" align="center" valign="middle" width="20%">$cdate</td></tr>\n~;
					$countJanuary++;
				}
				if ($user_bdmon == 2 || $user_bdmon == 2) {
					$view_February .= qq~	<tr><td class="windowbg2" align="center" valign="middle" width="30%">$user_linkprofile</td><td class="windowbg2" align="center" valign="middle" width="20%">$age</td><td class="windowbg2" align="center" valign="middle" width="30%">$sternzeichen</td><td class="windowbg2" align="center" valign="middle" width="20%">$cdate</td></tr>\n~;
					$countFebruary++;
				}
				if ($user_bdmon == 3 || $user_bdmon == 3) {
					$view_March .= qq~	<tr><td class="windowbg2" align="center" valign="middle" width="30%">$user_linkprofile</td><td class="windowbg2" align="center" valign="middle" width="20%">$age</td><td class="windowbg2" align="center" valign="middle" width="30%">$sternzeichen</td><td class="windowbg2" align="center" valign="middle" width="20%">$cdate</td></tr>\n~;
					$countMarch++;
				}
				if ($user_bdmon == 4 || $user_bdmon == 4) {
					$view_April .= qq~	<tr><td class="windowbg2" align="center" valign="middle" width="30%">$user_linkprofile</td><td class="windowbg2" align="center" valign="middle" width="20%">$age</td><td class="windowbg2" align="center" valign="middle" width="30%">$sternzeichen</td><td class="windowbg2" align="center" valign="middle" width="20%">$cdate</td></tr>\n~;
					$countApril++;
				}
				if ($user_bdmon == 5 || $user_bdmon == 5) {
					$view_May .= qq~	<tr><td class="windowbg2" align="center" valign="middle" width="30%">$user_linkprofile</td><td class="windowbg2" align="center" valign="middle" width="20%">$age</td><td class="windowbg2" align="center" valign="middle" width="30%">$sternzeichen</td><td class="windowbg2" align="center" valign="middle" width="20%">$cdate</td></tr>\n~;
					$countMay++;
				}
				if ($user_bdmon == 6 || $user_bdmon == 6) {
					$view_June .= qq~	<tr><td class="windowbg2" align="center" valign="middle" width="30%">$user_linkprofile</td><td class="windowbg2" align="center" valign="middle" width="20%">$age</td><td class="windowbg2" align="center" valign="middle" width="30%">$sternzeichen</td><td class="windowbg2" align="center" valign="middle" width="20%">$cdate</td></tr>\n~;
					$countJune++;
				}
				if ($user_bdmon == 7 || $user_bdmon == 7) {
					$view_July .= qq~	<tr><td class="windowbg2" align="center" valign="middle" width="30%">$user_linkprofile</td><td class="windowbg2" align="center" valign="middle" width="20%">$age</td><td class="windowbg2" align="center" valign="middle" width="30%">$sternzeichen</td><td class="windowbg2" align="center" valign="middle" width="20%">$cdate</td></tr>\n~;
					$countJuly++;
				}
				if ($user_bdmon == 8 || $user_bdmon == 8) {
					$view_August .= qq~	<tr><td class="windowbg2" align="center" valign="middle" width="30%">$user_linkprofile</td><td class="windowbg2" align="center" valign="middle" width="20%">$age</td><td class="windowbg2" align="center" valign="middle" width="30%">$sternzeichen</td><td class="windowbg2" align="center" valign="middle" width="20%">$cdate</td></tr>\n~;
					$countAugust++;
				}
				if ($user_bdmon == 9 || $user_bdmon == 9) {
					$view_September .= qq~	<tr><td class="windowbg2" align="center" valign="middle" width="30%">$user_linkprofile</td><td class="windowbg2" align="center" valign="middle" width="20%">$age</td><td class="windowbg2" align="center" valign="middle" width="30%">$sternzeichen</td><td class="windowbg2" align="center" valign="middle" width="20%">$cdate</td></tr>\n~;
					$countSeptember++;
				}
				if ($user_bdmon == 10) {
					$view_October .= qq~	<tr><td class="windowbg2" align="center" valign="middle" width="30%">$user_linkprofile</td><td class="windowbg2" align="center" valign="middle" width="20%">$age</td><td class="windowbg2" align="center" valign="middle" width="30%">$sternzeichen</td><td class="windowbg2" align="center" valign="middle" width="20%">$cdate</td></tr>\n~;
					$countOctober++;
				}
				if ($user_bdmon == 11) {
					$view_November .= qq~	<tr><td class="windowbg2" align="center" valign="middle" width="30%">$user_linkprofile</td><td class="windowbg2" align="center" valign="middle" width="20%">$age</td><td class="windowbg2" align="center" valign="middle" width="30%">$sternzeichen</td><td class="windowbg2" align="center" valign="middle" width="20%">$cdate</td></tr>\n~;
					$countNovember++;
				}
				if ($user_bdmon == 12) {
					$view_December .= qq~	<tr><td class="windowbg2" align="center" valign="middle" width="30%">$user_linkprofile</td><td class="windowbg2" align="center" valign="middle" width="20%">$age</td><td class="windowbg2" align="center" valign="middle" width="30%">$sternzeichen</td><td class="windowbg2" align="center" valign="middle" width="20%">$cdate</td></tr>\n~;
					$countDecember++;
				}
			}
		}
	}

	if (!$view_January)   { $no_birthday_found .= qq~&bull; $var_cal{'calmon_01'} ~;  $no_bd_found = 1;}
	if (!$view_February)  { $no_birthday_found .= qq~&bull; $var_cal{'calmon_02'} ~;  $no_bd_found = 1;}
	if (!$view_March)     { $no_birthday_found .= qq~&bull; $var_cal{'calmon_03'} ~;  $no_bd_found = 1;}
	if (!$view_April)     { $no_birthday_found .= qq~&bull; $var_cal{'calmon_04'} ~;  $no_bd_found = 1;}
	if (!$view_May)       { $no_birthday_found .= qq~&bull; $var_cal{'calmon_05'} ~;  $no_bd_found = 1;}
	if (!$view_June)      { $no_birthday_found .= qq~&bull; $var_cal{'calmon_06'} ~;  $no_bd_found = 1;}
	if (!$view_July)      { $no_birthday_found .= qq~&bull; $var_cal{'calmon_07'} ~;  $no_bd_found = 1;}
	if (!$view_August)    { $no_birthday_found .= qq~&bull; $var_cal{'calmon_08'} ~;  $no_bd_found = 1;}
	if (!$view_September) { $no_birthday_found .= qq~&bull; $var_cal{'calmon_09'} ~;  $no_bd_found = 1;}
	if (!$view_October)   { $no_birthday_found .= qq~&bull; $var_cal{'calmon_10'} ~;  $no_bd_found = 1;}
	if (!$view_November)  { $no_birthday_found .= qq~&bull; $var_cal{'calmon_11'} ~;  $no_bd_found = 1;}
	if (!$view_December)  { $no_birthday_found .= qq~&bull; $var_cal{'calmon_12'} ~;  $no_bd_found = 1;}

	#<--------------------------------------------->#
	# handle with the months end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Birthdaylist output begin
	#<--------------------------------------------->#

	$cal_info_header = qq~
	<tr>
		<td$class_sortuser align="center" width="30%"><a href="$scripturl?action=cal_birthdaylist;sort=sortuser;letter=$letter" style="text-decoration:none;"><b>$var_cal{'calname'}</b></a></td>
		<td$class_sortage align="center" width="20%"><a href="$scripturl?action=cal_birthdaylist;sort=sortage;letter=$letter" style="text-decoration:none;"><b>$var_cal{'calage'}</b></a></td>
		<td$class_sortstarsign align="center" width="30%"><a href="$scripturl?action=cal_birthdaylist;sort=sortstarsign;letter=$letter" style="text-decoration:none;"><b>$var_cal{'calstarsign'}</b></a></td>
		<td$class_sortdate align="center" width="20%"><a href="$scripturl?action=cal_birthdaylist;sort=sortdate;letter=$letter" style="text-decoration:none;"><b>$var_cal{'calbddate'}</b></a></td>
	</tr>
~;

	$yymain .= qq~
<table border="0" cellspacing="0" cellpadding="3" class="tabtitle" align="center" width="100%">
<tr>
<td class="round_top_left" width="1%">&nbsp;</td>
<td valign="middle">$var_cal{'caltitle'}</td>
<td class="round_top_right" align="right">$calgotobox</td>
</td>
</tr>
</table>
<table border="0" cellspacing="1" cellpadding="3" class="bordercolor" align="center" width="100%">
<tr>
<td class="windowbg" colspan="4">
<div style="float:left"><img align="bottom" src="$imagesdir/eventcal.gif" border="0" alt="" /></div>
<div style="float:left">
<br />
<span class="small">$var_cal{'calbirthdayinfo'}<br /><br />
~;

	if ($bd_today) {
		$yymain .= qq~
<u>$var_cal{calbirthdaytoday}:</u><br /><br />
$bd_today
<br /><br />
~;
	}

	$yymain .= qq~
</span>
</div>
</td>
</tr><tr>
<td class="titlebg" colspan="4" align="center" width="100%">
<b>$var_cal{'calbirthdays'}</b>
</td>
</tr>
<tr>
<td$class_sortuser align="center" width="30%"><a href="$scripturl?action=cal_birthdaylist;sort=sortuser" style="text-decoration:none;"><b>$var_cal{'calname'}</b></a></td>
<td$class_sortage align="center" width="20%"><a href="$scripturl?action=cal_birthdaylist;sort=sortage" style="text-decoration:none;"><b>$var_cal{'calage'}</b></a></td>
<td$class_sortstarsign align="center" width="30%"><a href="$scripturl?action=cal_birthdaylist;sort=sortstarsign" style="text-decoration:none;"><b>$var_cal{'calstarsign'}</b></a></td>
<td$class_sortdate align="center" width="20%"><a href="$scripturl?action=cal_birthdaylist;sort=sortdate" style="text-decoration:none;"><b>$var_cal{'calbddate'}</b></a></td>
</tr>
<tr>
<td class="windowbg" colspan="4" align="center" width="100%">
<table border="0" cellpadding="4" cellspacing="1" width="100%">
	<tr align="center">
		<td$styleletter_other><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=other" style="text-decoration:none;">123</a></font></td>
		<td$styleletter_a><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=a" style="text-decoration:none;">A</a></font></td>
		<td$styleletter_b><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=b" style="text-decoration:none;">B</a></font></td>
		<td$styleletter_c><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=c" style="text-decoration:none;">C</a></font></td>
		<td$styleletter_d><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=d" style="text-decoration:none;">D</a></font></td>
		<td$styleletter_e><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=e" style="text-decoration:none;">E</a></font></td>
		<td$styleletter_f><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=f" style="text-decoration:none;">F</a></font></td>
		<td$styleletter_g><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=g" style="text-decoration:none;">G</a></font></td>
		<td$styleletter_h><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=h" style="text-decoration:none;">H</a></font></td>
		<td$styleletter_i><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=i" style="text-decoration:none;">I</a></font></td>
		<td$styleletter_j><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=j" style="text-decoration:none;">J</a></font></td>
		<td$styleletter_k><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=k" style="text-decoration:none;">K</a></font></td>
		<td$styleletter_l><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=l" style="text-decoration:none;">L</a></font></td>
		<td$styleletter_m><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=m" style="text-decoration:none;">M</a></font></td>
		<td$styleletter_n><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=n" style="text-decoration:none;">N</a></font></td>
		<td$styleletter_o><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=o" style="text-decoration:none;">O</a></font></td>
		<td$styleletter_p><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=p" style="text-decoration:none;">P</a></font></td>
		<td$styleletter_q><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=q" style="text-decoration:none;">Q</a></font></td>
		<td$styleletter_r><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=r" style="text-decoration:none;">R</a></font></td>
		<td$styleletter_s><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=s" style="text-decoration:none;">S</a></font></td>
		<td$styleletter_t><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=t" style="text-decoration:none;">T</a></font></td>
		<td$styleletter_u><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=u" style="text-decoration:none;">U</a></font></td>
		<td$styleletter_v><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=v" style="text-decoration:none;">V</a></font></td>
		<td$styleletter_w><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=w" style="text-decoration:none;">W</a></font></td>
		<td$styleletter_x><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=x" style="text-decoration:none;">X</a></font></td>
		<td$styleletter_y><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=y" style="text-decoration:none;">Y</a></font></td>
		<td$styleletter_z><font class="text"><a href="$scripturl?action=cal_birthdaylist;sort=$sortiert;letter=z" style="text-decoration:none;">Z</a></font></td>
	</tr>
</table>
</td>
</tr>
$viewbirthdays
</table>
<br /><br />
~;

	if ($view_January) {
		$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td colspan="4" align="left" class="titlebg">
			<img align="bottom" src="$defaultimagesdir/eventbd.gif" border="0" alt="$var_cal{calbirthday}" /> <b>$var_cal{'calmon_01'}</b> ($countJanuary)
		</td>
	</tr>
$cal_info_header
$view_January
</table>
</div>
<br /><br />
~;
	}

	if ($view_February) {
		$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td  colspan="4" align="left" class="titlebg">
			<img align="bottom" src="$defaultimagesdir/eventbd.gif" border="0" alt="$var_cal{calbirthday}" /> <b>$var_cal{'calmon_02'}</b> ($countFebruary)
		</td>
	</tr>
$cal_info_header
$view_February
</table>
</div>
<br /><br />
~;
	}

	if ($view_March) {
		$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td  colspan="4" align="left" class="titlebg">
			<img align="bottom" src="$defaultimagesdir/eventbd.gif" border="0" alt="$var_cal{calbirthday}" /> <b>$var_cal{'calmon_03'}</b> ($countMarch)
		</td>
	</tr>
$cal_info_header
$view_March
</table>
</div>
<br /><br />
~;
	}

	if ($view_April) {
		$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td  colspan="4" align="left" class="titlebg">
			<img align="bottom" src="$defaultimagesdir/eventbd.gif" border="0" alt="$var_cal{calbirthday}" /> <b>$var_cal{'calmon_04'}</b> ($countApril)
		</td>
	</tr>
$cal_info_header
$view_April
</table>
</div>
<br /><br />
~;
	}

	if ($view_May) {
		$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td  colspan="4" align="left" class="titlebg">
			<img align="bottom" src="$defaultimagesdir/eventbd.gif" border="0" alt="$var_cal{calbirthday}" /> <b>$var_cal{'calmon_05'}</b> ($countMay)
		</td>
	</tr>
$cal_info_header
$view_May
</table>
</div>
<br /><br />
~;
	}

	if ($view_June) {
		$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td  colspan="4" align="left" class="titlebg">
			<img align="bottom" src="$defaultimagesdir/eventbd.gif" border="0" alt="$var_cal{calbirthday}" /> <b>$var_cal{'calmon_06'}</b> ($countJune)
		</td>
	</tr>
$cal_info_header
$view_June
</table>
</div>
<br /><br />
~;
	}

	if ($view_July) {
		$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td  colspan="4" align="left" class="titlebg">
			<img align="bottom" src="$defaultimagesdir/eventbd.gif" border="0" alt="$var_cal{calbirthday}" /> <b>$var_cal{'calmon_07'}</b> ($countJuly)
		</td>
	</tr>
$cal_info_header
$view_July
</table>
</div>
<br /><br />
~;
	}

	if ($view_August) {
		$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td  colspan="4" align="left" class="titlebg">
			<img align="bottom" src="$defaultimagesdir/eventbd.gif" border="0" alt="$var_cal{calbirthday}" /> <b>$var_cal{'calmon_08'}</b> ($countAugust)
		</td>
	</tr>
$cal_info_header
$view_August
</table>
</div>
<br /><br />
~;
	}

	if ($view_September) {
		$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td  colspan="4" align="left" class="titlebg">
			<img align="bottom" src="$defaultimagesdir/eventbd.gif" border="0" alt="$var_cal{calbirthday}" /> <b>$var_cal{'calmon_09'}</b> ($countSeptember)
		</td>
	</tr>
$cal_info_header
$view_September
</table>
</div>
<br /><br />
~;
	}

	if ($view_October) {
		$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td  colspan="4" align="left" class="titlebg">
			<img align="bottom" src="$defaultimagesdir/eventbd.gif" border="0" alt="$var_cal{calbirthday}" /> <b>$var_cal{'calmon_10'}</b> ($countOctober)
		</td>
	</tr>
$cal_info_header
$view_October
</table>
</div>
<br /><br />
~;
	}

	if ($view_November) {
		$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td  colspan="4" align="left" class="titlebg">
			<img align="bottom" src="$defaultimagesdir/eventbd.gif" border="0" alt="$var_cal{calbirthday}" /> <b>$var_cal{'calmon_11'}</b> ($countNovember)
		</td>
	</tr>
$cal_info_header
$view_November
</table>
</div>
<br /><br />
~;
	}

	if ($view_December) {
		$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td  colspan="4" align="left" class="titlebg">
			<img align="bottom" src="$defaultimagesdir/eventbd.gif" border="0" alt="$var_cal{calbirthday}" /> <b>$var_cal{'calmon_12'}</b> ($countDecember)
		</td>
	</tr>
$cal_info_header
$view_December
</table>
</div>
<br /><br />
~;
	}

	if ($no_bd_found == 1) {
		$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td  colspan="4" align="left" class="titlebg">
			<img src="$defaultimagesdir/info2.gif" border="0" alt="$var_cal{calbirthday}" /> <b>$var_cal{'calbirthday1'}</b>
		</td>
	</tr>
	<tr>
		<td class="windowbg2" align="left" valign="middle" colspan="4">
			$no_birthday_found
		</td>
	</tr>
</table>
</div>
~;
	}

	#<--------------------------------------------->#
	# Birthdaylist output end
	#<--------------------------------------------->#

	$yytitle = "$var_cal{yytitle} $var_cal{'calbirthdays'}";
	&template;
	exit;
}

#<--------------------------------------------->#
# view birthdays end
#<--------------------------------------------->#

#<--------------------------------------------->#
# sort area begin
#<--------------------------------------------->#

sub sortdate {
	my @zahl1 = split(/\|/,$a);
	my @zahl2 = split(/\|/,$b);
	$zahl1[2].$zahl1[0] <=> $zahl2[2].$zahl2[0];
}

sub sortage {
	my @zahl1 = split(/\|/,$a);
	my @zahl2 = split(/\|/,$b);
	$zahl1[4].$zahl1[2].$zahl1[0] <=> $zahl2[4].$zahl2[2].$zahl2[0];
}

sub sortstarsign {
	my @name1 = split(/\|/,$a);
	my @name2 = split(/\|/,$b);
	$name1[5] cmp $name2[5];
}

sub sortuser {
	my @name1 = split(/\|/,$a);
	my @name2 = split(/\|/,$b);
	lc $name1[6] cmp lc $name2[6];
}

#<--------------------------------------------->#
# sort area end - Event Birthday List >> Finish
#<--------------------------------------------->#

1;
