###############################################################################
# Database.pl                                                                 #
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

$databaseplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('Database');

$yytitle = $db_txt{'title'};
$action_area = 'database';

sub SelectDatabase {
	$yymain .= qq~
<form action="$adminurl?action=database2" method="post">
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr>
		<td align="left" colspan="3" class="titlebg">
		<img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$db_txt{'title'}</b>
		</td>
	</tr>~;

	$yymain .= $use_MySQL ? qq~
	<tr>
		<td align="left" colspan="3" class="windowbg">
			$db_txt{'2'}
			<div style="width: 100%; text-align: center;"><br />
			<input type="button" value="$db_txt{'3'}" class="button" onclick="window.location.href='$adminurl?action=database4'" />
			</div>
			<br />
			$db_txt{'5'}
			<div style="width: 100%; text-align: center;"><br />
			<input type="button" value="$db_txt{'6'}" class="button" onclick="window.location.href='$adminurl?action=database5'" />
			</div>
			<br />
			$db_txt{'4'}
		</td>
	</tr>~
	: qq~
	<tr>
		<td align="left" colspan="3" class="windowbg">
			$db_txt{'1'}<br />
			<br />
			$db_txt{'9'}
		</td>
	</tr>~;

	$yymain .= qq~
	<tr>
		<td align="right" valign="top" colspan="2" class="windowbg2">
			$db_txt{'20'}:
		</td>
		<td align="left" class="windowbg2">
			<input type="text" name="db_server" value="~ . ($db_server || 'localhost') . qq~" />
		</td>
	</tr>
	<tr>
		<td align="right" valign="top" colspan="2" class="windowbg2">
			$db_txt{'21'}:
		</td>
		<td align="left" class="windowbg2">
			<input type="text" name="db_port" value="~ . ($db_port || '3306') . qq~" /><br />
			$db_txt{'21a'}: 3306
		</td>
	</tr>
	<tr>
		<td align="right" valign="top" colspan="2" class="windowbg2">
			$db_txt{'22'}:
		</td>
		<td align="left" class="windowbg2">
			<input type="text" name="db_socket" value="$db_socket" /><br />
			$db_txt{'22a'}.
		</td>
	</tr>
	<tr>
		<td align="right" valign="top" colspan="2" class="windowbg2">
			$db_txt{'23'}:
		</td>
		<td align="left" class="windowbg2">
			<input type="text" name="db" value="$db" />
		</td>
	</tr>
	<tr>
		<td align="right" valign="top" colspan="2" class="windowbg2">
			$db_txt{'24'}:
		</td>
		<td align="left" class="windowbg2">
			<input type="text" name="db_username" value="$db_username" />
		</td>
	</tr>
	<tr>
		<td align="right" valign="top" colspan="2" class="windowbg2">
			$db_txt{'25'}:
		</td>
		<td align="left" class="windowbg2">
			<input type="password" name="db_password" value="" /><br />
			$db_txt{'25a'}.
		</td>
	</tr>~;

	if (!$use_MySQL) {
		$yymain .= qq~
	<tr>
		<td align="right" valign="top" colspan="2" class="windowbg2">
			$db_txt{'26'}:
		</td>
		<td align="left" class="windowbg2">
			<input type="text" name="db_prefix" value="~ .($db_prefix || 'YaBB2') . qq~" /><br />
			$db_txt{'26a'}.
		</td>
	</tr>
	<tr>
		<td align="left" colspan="3" class="windowbg">
			<input type="checkbox" name="own_tables" value="1" onclick="HideOrNot()" /> $db_txt{'10'}
		</td>
	</tr>
	<tr id="hide_or_not1" style="display:none">
		<td align="left" colspan="3" class="windowbg2">
			<br />
			$db_txt{'11'}<br />
			<br />
		</td>
	</tr>
	<tr id="hide_or_not2" style="display:none">
		<td align="center" valign="middle" class="windowbg2">$db_txt{'40'}</td>
		<td align="center" valign="middle" class="windowbg2">$db_txt{'41'}:<br /><input type="text" name="vars_tablename" value="" /><br /><br />$db_txt{'42'}:</td>
		<td align="center" valign="middle" class="windowbg2">$db_txt{'43'}</td>
	</tr>
	<tr id="hide_or_not3" style="display:none">
		<td align="center" class="windowbg2">yabbusername</td>
		<td align="center" class="windowbg2"><input type="text" name="col_yabbusername" value="" /></td>
		<td align="left" class="windowbg2">$db_txt{'yabbusername'}</td>
	</tr>~;


		# This array must be exactly the same as the @db_vars_tabs_order array
		# further down, the @tags in Sources/System.pl!!!
		my @tags = qw(realname password position addgroups email hidemail regdate regtime regreason location bday gender userpic usertext signature template language stealth webtitle weburl icq aim yim skype myspace facebook msn gtalk timeselect timeformat timeoffset dsttimeoffset dynamic_clock postcount lastonline lastpost lastim im_ignorelist im_popup im_imspop pmmessprev pmviewMess pmactprev notify_me board_notifications thread_notifications favorites buddylist cathide pageindex reversetopic postlayout sesquest sesanswer session lastips onlinealert offlinestatus awaysubj awayreply awayreplysent spamcount spamtime hide_avatars hide_user_text hide_attach_img hide_signat hide_smilies_row numberformat);
		push(@tags, 'additional_variables');

		my $x = 3;
		foreach my $t (@tags) {
			$x++;
			$yymain .= qq~
	<tr id="hide_or_not$x" style="display:none">
		<td align="center" class="windowbg2">$t</td>
		<td align="center" class="windowbg2"><input type="text" name="col_$t" value="~ . (grep { $db_user_vars_col{$_} eq $t; } keys %db_user_vars_col) . qq~" /></td>
		<td align="left" class="windowbg2">~ . ($db_txt{$t} || "&nbsp;") . qq~</td>
	</tr>~;
		}

		$x++;
		$yymain .= qq~
	<tr id="hide_or_not$x" style="display:none">
		<td align="center" class="windowbg2" colspan="3"><br /><br /><br /></td>
	</tr>~;
		$x++;
		$yymain .= qq~
	<tr id="hide_or_not$x" style="display:none">
		<td align="center" class="windowbg2">$db_txt{'40a'}</td>
		<td align="center" class="windowbg2">$db_txt{'41'}:<br /><input type="text" name="log_tablename" value="" /><br /><br />$db_txt{'42'}:</td>
		<td align="center" class="windowbg2">$db_txt{'43'}</td>
	</tr>~;
		$x++;
		$yymain .= qq~
	<tr id="hide_or_not$x" style="display:none">
		<td align="center" class="windowbg2">username</td>
		<td align="center" class="windowbg2"><input type="text" name="col_username" value="" /></td>
		<td align="left" class="windowbg2">$db_txt{'username'}</td>
	</tr>~;


		foreach my $log (qw(date ip user_host)) {
			$x++;
			my ($z) = grep { /`$log`/ } split(/,/, $db_user_log_col);
			$z =~ s/`//g;
			$yymain .= qq~
	<tr id="hide_or_not$x" style="display:none">
		<td align="center" class="windowbg2">$log</td>
		<td align="center" class="windowbg2"><input type="text" name="col_$log" value="$z" /></td>
		<td align="left" class="windowbg2">~ . ($db_txt{$log} || "&nbsp;") . qq~</td>
	</tr>~;
		}

		$yymain .= qq~
	<tr>
		<td align="center" colspan="3" class="windowbg">
			$db_txt{30}<br />~;

	} else {
		$yymain .= qq~
	<tr>
		<td align="center" colspan="3" class="windowbg">
			<input type="hidden" name="save_settings" value="$db_prefix" />
			$db_txt{29}<br />~;
	}

	$yymain .= qq~
			<br />
			<input type="submit" name="submit" value="$db_txt{31}" class="button" />
		</td>
	</tr>
</table>
</div>
</form>

<script language="JavaScript1.2" type="text/javascript">
<!--
	function HideOrNot() {
		for (var i = 1; 100 > i; i++) {
			try {
				if (typeof(document.getElementById('hide_or_not' + i).style.display)) throw '1';
			} catch (e) {
				if (e == '1') {
					if (document.getElementById('hide_or_not' + i).style.display == 'none') document.getElementById('hide_or_not' + i).style.display = '';
					else document.getElementById('hide_or_not' + i).style.display = 'none';
				}
			}
		}
	}
//-->
</script>
~;

	&AdminTemplate;
}

sub SaveDatabase {
	&is_admin();



	#############
	&fatal_error('', "Adding data to own tables is not working at the moment.") if $FORM{'own_tables'};
	#############



	&fatal_error('', $db_txt{'missingDBdata'}) if !$FORM{'db_server'} || !$FORM{'db_port'} || !$FORM{'db'} || !$FORM{'db_username'} || (!$FORM{'db_prefix'} && !$FORM{'save_settings'});

	my $own_vars_table = 1 if $FORM{'own_tables'} && $FORM{'vars_tablename'} && $FORM{'col_yabbusername'};
	my $own_log_table  = 1 if $FORM{'own_tables'} && $FORM{'log_tablename'}  && $FORM{'col_username'};

	&fatal_error('', $db_txt{'missingvarsdata'}) if $FORM{'own_tables'} && !$own_vars_table && ($FORM{'vars_tablename'}  || $FORM{'col_yabbusername'});
	&fatal_error('', $db_txt{'missinglogdata'}) if $FORM{'own_tables'} && !$own_log_table && ($FORM{'log_tablename'}  || $FORM{'col_username'});


	# general
	$db_server = $FORM{'db_server'};			# Name of the SQL-server
	$db_port = $FORM{'db_port'};				# Port of the SQL-server
	$db_socket = $FORM{'db_socket'};			# Socket of the SQL-server
	$db = $FORM{'db'};					# Name of the database
	$db_username = $FORM{'db_username'};			# Unsername of the database
	$db_password = $FORM{'db_password'} || $db_password;	# Password of the user of the database
	$db_prefix = $FORM{'db_prefix'};			# Prefix for YaBB tables inside the database


	if ($FORM{'save_settings'}) {
		$db_prefix = $FORM{'save_settings'};

		require "$admindir/NewSettings.pl";
		&SaveSettingsTo('Settings.pl');

		&SelectDatabase; # don't come back here; exit there
	}

	&fatal_error('', $db_txt{'already_in_MySQL'}) if $use_MySQL == 1;
	$use_MySQL = 0;						# Set to 1 if you are on MySQL-DB, set to 0 if you are on the default file-DB structure

	# vars
	my (@ex_colums,@var_colums,@order);
	# This array must be exactly the same as @tags from above, in Sources/System.pl!!!
	@db_vars_tabs_order = qw(realname password position addgroups email hidemail regdate regtime regreason location bday gender userpic usertext signature template language stealth webtitle weburl icq aim yim skype myspace facebook msn gtalk timeselect timeformat timeoffset dsttimeoffset dynamic_clock postcount lastonline lastpost lastim im_ignorelist im_popup im_imspop pmmessprev pmviewMess pmactprev notify_me board_notifications thread_notifications favorites buddylist cathide pageindex reversetopic postlayout sesquest sesanswer session lastips onlinealert offlinestatus awaysubj awayreply awayreplysent spamcount spamtime hide_avatars hide_user_text hide_attach_img hide_signat hide_smilies_row numberformat);
	push(@db_vars_tabs_order, 'additional_variables');
	%db_user_vars_col = ();
	%db_vars_col = ();

	my $buildnew_vars = qq~CREATE TABLE `$FORM{'db_prefix'}_vars` (\n`yabbusername` char(20) default NULL,\n~;
	foreach (@db_vars_tabs_order) {
		&fatal_error('', $db_txt{'wrongchar'} . "'$_': $1") if $own_vars_table && $FORM{"col_$_"} =~ /(\W)/;

		if ($own_vars_table && $FORM{"col_$_"}) {
			push(@order, $FORM{"col_$_"});
			$db_user_vars_col{$FORM{"col_$_"}} = $_;
			if ($_ eq 'lastonline') {
				$db_vars_laston_table = $FORM{'vars_tablename'};
				$db_vars_laston = $FORM{"col_$_"};
			}
		} else {
			push(@order, $_);
			$db_vars_col{$_} = 1;

			if      ($_ eq 'realname') {
				$buildnew_vars .= qq~`$_` char(30) default NULL,\n~;
			} elsif ($_ eq 'password') {
				$buildnew_vars .= qq~`$_` char(22) binary default NULL,\n~;
			} elsif ($_ eq 'position') {
				$buildnew_vars .= qq~`$_` varchar(300) default NULL,\n~;
			} elsif ($_ eq 'addgroups') {
				$buildnew_vars .= qq~`$_` varchar(300) default NULL,\n~;
			} elsif ($_ eq 'email') {
				$buildnew_vars .= qq~`$_` varchar(100) default NULL,\n~;
			} elsif ($_ eq 'hidemail') {
				$buildnew_vars .= qq~`$_` tinyint(1) NOT NULL default '1',\n~;
			} elsif ($_ eq 'regdate') {
				$buildnew_vars .= qq~`$_` char(25) default NULL,\n~;
			} elsif ($_ eq 'regtime') {
				$buildnew_vars .= qq~`$_` bigint(11) default NULL,\n~;
			} elsif ($_ eq 'regreason') {
				$buildnew_vars .= qq~`$_` varchar(500) default NULL,\n~;
			} elsif ($_ eq 'location') {
				$buildnew_vars .= qq~`$_` varchar(50) default NULL,\n~;
			} elsif ($_ eq 'bday') {
				$buildnew_vars .= qq~`$_` char(10) default NULL,\n~;
			} elsif ($_ eq 'gender') {
				$buildnew_vars .= qq~`$_` char(6) default NULL,\n~;
			} elsif ($_ eq 'userpic') {
				$buildnew_vars .= qq~`$_` varchar(100) default NULL,\n~;
			} elsif ($_ eq 'usertext') {
				$buildnew_vars .= qq~`$_` varchar(255) default NULL,\n~;
			} elsif ($_ eq 'signature') {
				$buildnew_vars .= qq~`$_` varchar(2000) default NULL,\n~;
			} elsif ($_ eq 'template') {
				$buildnew_vars .= qq~`$_` varchar(20) default NULL,\n~;
			} elsif ($_ eq 'language') {
				$buildnew_vars .= qq~`$_` varchar(20) default NULL,\n~;
			} elsif ($_ eq 'stealth') {
				$buildnew_vars .= qq~`$_` tinyint(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'webtitle') {
				$buildnew_vars .= qq~`$_` varchar(50) default NULL,\n~;
			} elsif ($_ eq 'weburl') {
				$buildnew_vars .= qq~`$_` varchar(50) default NULL,\n~;
			} elsif ($_ eq 'icq') {
				$buildnew_vars .= qq~`$_` varchar(50) default NULL,\n~;
			} elsif ($_ eq 'aim') {
				$buildnew_vars .= qq~`$_` varchar(50) default NULL,\n~;
			} elsif ($_ eq 'yim') {
				$buildnew_vars .= qq~`$_` varchar(50) default NULL,\n~;
			} elsif ($_ eq 'skype') {
				$buildnew_vars .= qq~`$_` varchar(50) default NULL,\n~;
			} elsif ($_ eq 'myspace') {
				$buildnew_vars .= qq~`$_` varchar(50) default NULL,\n~;
			} elsif ($_ eq 'facebook') {
				$buildnew_vars .= qq~`$_` varchar(50) default NULL,\n~;
			} elsif ($_ eq 'msn') {
				$buildnew_vars .= qq~`$_` varchar(50) default NULL,\n~;
			} elsif ($_ eq 'gtalk') {
				$buildnew_vars .= qq~`$_` varchar(50) default NULL,\n~;
			} elsif ($_ eq 'timeselect') {
				$buildnew_vars .= qq~`$_` tinyint(1) NOT NULL default '1',\n~;
			} elsif ($_ eq 'timeformat') {
				$buildnew_vars .= qq~`$_` varchar(50) default NULL,\n~;
			} elsif ($_ eq 'timeoffset') {
				$buildnew_vars .= qq~`$_` decimal(6,4) default '0.0000',\n~;
			} elsif ($_ eq 'dsttimeoffset') {
				$buildnew_vars .= qq~`$_` tinyint(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'dynamic_clock') {
				$buildnew_vars .= qq~`$_` tinyint(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'postcount') {
				$buildnew_vars .= qq~`$_` int(6) NOT NULL default '0',\n~;
			} elsif ($_ eq 'lastonline') {
				$buildnew_vars .= qq~`$_` bigint(11) default NULL,\n~;
			} elsif ($_ eq 'lastpost') {
				$buildnew_vars .= qq~`$_` bigint(11) default NULL,\n~;
			} elsif ($_ eq 'lastim') {
				$buildnew_vars .= qq~`$_` bigint(11) default NULL,\n~;
			} elsif ($_ eq 'im_ignorelist') {
				$buildnew_vars .= qq~`$_` varchar(500) default NULL,\n~;
			} elsif ($_ eq 'im_popup') {
				$buildnew_vars .= qq~`$_` tinyint(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'im_imspop') {
				$buildnew_vars .= qq~`$_` tinyint(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'pmmessprev') {
				$buildnew_vars .= qq~`$_` tinyint(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'pmviewMess') {
				$buildnew_vars .= qq~`$_` tinyint(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'pmactprev') {
				$buildnew_vars .= qq~`$_` tinyint(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'notify_me') {
				$buildnew_vars .= qq~`$_` tinyint(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'board_notifications') {
				$buildnew_vars .= qq~`$_` varchar(1000) default NULL,\n~;
			} elsif ($_ eq 'thread_notifications') {
				$buildnew_vars .= qq~`$_` varchar(1000) default NULL,\n~;
			} elsif ($_ eq 'favorites') {
				$buildnew_vars .= qq~`$_` varchar(1000) default NULL,\n~;
			} elsif ($_ eq 'buddylist') {
				$buildnew_vars .= qq~`$_` varchar(500) default NULL,\n~;
			} elsif ($_ eq 'cathide') {
				$buildnew_vars .= qq~`$_` varchar(300) default NULL,\n~;
			} elsif ($_ eq 'pageindex') {
				$buildnew_vars .= qq~`$_` char(10) default NULL,\n~;
			} elsif ($_ eq 'reversetopic') {
				$buildnew_vars .= qq~`$_` tinyint(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'postlayout') {
				$buildnew_vars .= qq~`$_` char(12) default NULL,\n~;
			} elsif ($_ eq 'sesquest') {
				$buildnew_vars .= qq~`$_` varchar(200) default NULL,\n~;
			} elsif ($_ eq 'sesanswer') {
				$buildnew_vars .= qq~`$_` varchar(200) default NULL,\n~;
			} elsif ($_ eq 'session') {
				$buildnew_vars .= qq~`$_` char(22) binary default NULL,\n~;
			} elsif ($_ eq 'lastips') {
				$buildnew_vars .= qq~`$_` char(50) default NULL,\n~;
			} elsif ($_ eq 'onlinealert') {
				$buildnew_vars .= qq~`$_` tinyint(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'offlinestatus') {
				$buildnew_vars .= qq~`$_` char(7) default NULL,\n~;
			} elsif ($_ eq 'awaysubj') {
				$buildnew_vars .= qq~`$_` varchar(50) default NULL,\n~;
			} elsif ($_ eq 'awayreply') {
				$buildnew_vars .= qq~`$_` varchar(1000) default NULL,\n~;
			} elsif ($_ eq 'awayreplysent') {
				$buildnew_vars .= qq~`$_` varchar(500) default NULL,\n~;
			} elsif ($_ eq 'spamcount') {
				$buildnew_vars .= qq~`$_` int(6) NOT NULL default '0',\n~;
			} elsif ($_ eq 'spamtime') {
				$buildnew_vars .= qq~`$_` bigint(11) default NULL,\n~;
			} elsif ($_ eq 'hide_avatars') {
				$buildnew_vars .= qq~`$_` int(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'hide_user_text') {
				$buildnew_vars .= qq~`$_` int(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'hide_attach_img') {
				$buildnew_vars .= qq~`$_` int(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'hide_signat') {
				$buildnew_vars .= qq~`$_` int(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'hide_smilies_row') {
				$buildnew_vars .= qq~`$_` int(1) NOT NULL default '0',\n~;
			} elsif ($_ eq 'numberformat') {
				$buildnew_vars .= qq~`$_` int(1) NOT NULL default '0',\n~;

			# add new variables here before
			} elsif ($_ eq 'additional_variables') {
				$buildnew_vars .= qq~`$_` varchar(1500) default NULL,\n~;
			}
		}
	}
	$buildnew_vars .= qq~`msg` text,\n~;
	$buildnew_vars .= qq~`ims` text,\n~;
	$buildnew_vars .= qq~`outbox` text,\n~;
	$buildnew_vars .= qq~`imstore` text,\n~;
	$buildnew_vars .= qq~`imdraft` text,\n~;
	$buildnew_vars .= qq~`log` text,\n~;
	$buildnew_vars .= qq~`rlog` text,\n~;
	$buildnew_vars .= qq~PRIMARY KEY (`yabbusername`)) TYPE=MyISAM~;
	$buildnew_vars = '' if !%db_vars_col;

	if (%db_user_vars_col) { # must be more then only 'yabbusername'
		$db_user_vars_table = $FORM{'vars_tablename'};
		$db_user_vars_key = $FORM{'col_yabbusername'};
	} else { $db_user_vars_table = ''; $db_user_vars_key = ''; }
	@db_vars_tabs_order = @order;
	$db_vars_order = join(',', @order);


	# online
	@order = ();
	@ex_colums = ();
	@db_user_log_array_order = ();
	@var_colums = ();
	@db_log_array_order = ();
	push(@order, 'yabbuserlogname');
	push(@var_colums, 'yabbuserlogname');
	push(@db_log_array_order, 0);

	my $buildnew_online = qq~CREATE TABLE `$FORM{'db_prefix'}_log` (\n`yabbuserlogname` varchar(20) binary default NULL,\n~;
	my $i = 0;
	foreach (qw(date ip user_host)) {
		&fatal_error('', $db_txt{'wrongchar'} . "'$_': $1", 1) if $own_log_table && $FORM{"col_$_"} =~ /(\W)/;

		if ($own_log_table && $FORM{"col_$_"}) {
			push(@order, $FORM{"col_$_"});
			push(@ex_colums, $FORM{"col_$_"});
			push(@db_user_log_array_order, $i);
			$i++;
		} else {
			$i++;
			push(@order, $_);
			push(@var_colums, $_);
			push(@db_log_array_order, $i);
			$buildnew_online .= qq~`date` bigint(11) default NULL,\n~ if $_ eq 'date';
			$buildnew_online .= qq~`ip` char(15) default NULL,\n~ if $_ eq 'ip';
			$buildnew_online .= qq~`user_host` char(100) default NULL,\n~ if $_ eq 'user_host';
		}
	}
	push(@db_log_array_order, ($i + 1));
	push(@order, 'additional_data');
	push(@var_colums, 'additional_data');

	if (@ex_colums) {
		$db_user_log_table = $FORM{'log_tablename'};
		$db_user_log_col = join('`,`', @ex_colums);
		$db_user_log_key = $FORM{'col_username'};
		splice(@order,0,1,$FORM{'col_username'});
	} else { $db_user_log_table = ''; $db_user_log_col = ''; $db_user_log_key = ''; }
	$db_log_col = join('`,`', @var_colums);
	$db_log_order = '`' . join('`,`', @order) . '`';
	$db_log_date = (split(/,/, $db_log_order, 3))[1];

	$buildnew_online .= qq~`additional_data` varchar(300) default NULL~;
	$buildnew_online .= qq~,\nKEY `date` (`date`)~ if grep { "`$_`" eq $db_log_date } @var_colums;
	$buildnew_online .= qq~) TYPE=MyISAM~;


	# ctb
	my $buildnew_ctb;
	$buildnew_ctb = qq~CREATE TABLE `$FORM{'db_prefix'}_ctb` (\n`threadnum` bigint(11) NOT NULL,\n~;
	$buildnew_ctb .= qq~`board` char(20) default NULL,\n~;
	$buildnew_ctb .= qq~`replies` int(5) default NULL,\n~;
	$buildnew_ctb .= qq~`views` int(5) default NULL,\n~;
	$buildnew_ctb .= qq~`lastposter` char(20) default NULL,\n~;
	$buildnew_ctb .= qq~`lastpostdate` bigint(11) default NULL,\n~;
	$buildnew_ctb .= qq~`threadstatus` char(5) default NULL,\n~;
	$buildnew_ctb .= qq~`repliers` varchar(1000) default NULL,\n~;
	$buildnew_ctb .= qq~`mail` text,\n~;
	$buildnew_ctb .= qq~`poll` text,\n~;
	$buildnew_ctb .= qq~`polled` text,\n~;
	$buildnew_ctb .= qq~PRIMARY KEY (`threadnum`)) TYPE=MyISAM~;


	# messages.txt
	my $buildnew_message_txt;
	$buildnew_message_txt = qq~CREATE TABLE `$FORM{'db_prefix'}_messages` (\n`mess_threadnum` bigint(11) NOT NULL,\n~;
	$buildnew_message_txt .= qq~`subject` varchar(100) default NULL,\n~;
	$buildnew_message_txt .= qq~`displayname` char(30) default NULL,\n~;
	$buildnew_message_txt .= qq~`email` varchar(100) default NULL,\n~;
	$buildnew_message_txt .= qq~`date` bigint(11) default NULL,\n~;
	$buildnew_message_txt .= qq~`username` char(20) default NULL,\n~;
	$buildnew_message_txt .= qq~`icon` char(15) default NULL,\n~;
	$buildnew_message_txt .= qq~`post_number` int(5) NOT NULL default '0',\n~;
	$buildnew_message_txt .= qq~`user_ip` char(15) default NULL,\n~;
	$buildnew_message_txt .= qq~`message` text,\n~;
	$buildnew_message_txt .= qq~`no_smilies` char(2) default NULL,\n~;
	$buildnew_message_txt .= qq~`modified_date` bigint(11) default NULL,\n~;
	$buildnew_message_txt .= qq~`modified_by` char(20) default NULL,\n~;
	$buildnew_message_txt .= qq~`attachments` varchar(500) default NULL,\n~;
	$buildnew_message_txt .= qq~PRIMARY KEY (`mess_threadnum`,`post_number`)) TYPE=MyISAM~;


	# do the work now
	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');

	require DBI;
	# remove old tables
	&mysql_process(0,'do',"DROP TABLE IF EXISTS `$FORM{'db_prefix'}_vars`, `$FORM{'db_prefix'}_log`, `$FORM{'db_prefix'}_ctb`, `$FORM{'db_prefix'}_messages`");

	# build new tables
	&mysql_process(0,'do',$buildnew_vars);
	&mysql_process(0,'do',$buildnew_online);
	&mysql_process(0,'do',$buildnew_ctb);
	&mysql_process(0,'do',$buildnew_message_txt);

	# remove old conversion files if exist
	&delete_DBorFILE("$memberdir/memberrest.dbconvert");
	&delete_DBorFILE("$memberdir/membercalc.dbconvert");
	&delete_DBorFILE("$datadir/messrest.dbconvert");
	&delete_DBorFILE("$datadir/messcalc.dbconvert");

	my $db_user_vars_col = join("", map { qq~'$_' => '$db_user_vars_col{$_}',~; } keys %db_user_vars_col) if %db_user_vars_col;
	my $db_vars_col = join("", map { qq~'$_' => 1,~; } keys %db_vars_col) if %db_vars_col;

	$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<form action="$adminurl?action=database3" method="post">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr>
		<td align="left" class="titlebg">
		<img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$db_txt{'title'}</b>
		</td>
	</tr>~;

	$yymain .= qq~
	<tr>
		<td align="left" class="windowbg2">
			$db_txt{''}
			<pre style="overflow:scroll;">
# Set to 1 to use MySQL-DB, 0 to use the default file-DB
\$use_MySQL = $use_MySQL;

# Name of the SQL-server
\$db_server = "$db_server";
# Port of the SQL-server
\$db_port = "$db_port";
# Socket of the SQL-server
\$db_socket = "$db_socket";
# Name of the database
\$db = "$db";
# Unsername of the database
\$db_username = "$db_username";
# Password of the user of the database
\$db_password = "$db_password";
# Prefix for YaBB tables inside the database
\$db_prefix = "$db_prefix";

# Name of the table with user 'vars' informations
\$db_user_vars_table = "$db_user_vars_table";
# Name (key) of the colums in the above table with user 'vars' (value) informations
\%db_user_vars_col = ($db_user_vars_col);
# DB-Key of the table with user 'vars' informations
\$db_user_vars_key = "$db_user_vars_key";
# Name (key) of the rest 'vars' colums in the YaBB table
\%db_vars_col = ($db_vars_col);
# Right order of the colums for a fetch of all 'vars'
\$db_vars_order = "$db_vars_order";
# variables tabs order coreponding to $db_vars_order
\@db_vars_tabs_order = (@db_vars_tabs_order);
# 'lastonline' table
\$db_vars_laston_table = "$db_vars_laston_table";
# 'lastonline' colum namen
\$db_vars_laston = "$db_vars_laston";


# Name of the table with user 'log' informations
\$db_user_log_table = "$db_user_log_table";
# Name of the colums in the above table with user 'log' informations
\$db_user_log_col = "$db_user_log_col";
# DB-Key of the table with user 'log' informations
\$db_user_log_key = "$db_user_log_key";
# number of the variable in the @log_array for the user_log
\@db_user_log_array_order = qw(@db_user_log_array_order);
# Name of the colums in the 'log' table with user 'log' informations
\$db_log_col = "$db_log_col";
# Right order of the colums for a fetch of all 'log'
\$db_log_order = "$db_log_order";
# date colum of the 'log' table
\$db_log_date = "$db_log_date";
# number of the variable in the @log_array in the 'log'
\@db_log_array_order = qw(@db_log_array_order);
			</pre><br /><br />
			<pre>$buildnew_vars</pre><br /><br />
			<pre>$buildnew_online</pre><br /><br />
			<pre>$buildnew_ctb</pre><br /><br />
			<pre>$buildnew_message_txt</pre>
		</td>
	</tr>~ if $debug;

	$yymain .= qq~
	<tr>
		<td align="center" class="windowbg">
			$db_txt{33}<br /><br />
			<input type="submit" name="submit" value="$db_txt{31}" class="button" />
		</td>
	</tr>
</table>
</form>
</div>~;

	&AdminTemplate;
}

sub ConvertDatabase {
	require DBI;

	my (@contents, $begin_time, $start_time, $sumuser);

	# Security
	&is_admin;
	&automaintenance("on");

	# Set up the multi-step action
	$begin_time = time();

	# convert .vars
	unless (-e "$datadir/messrest.dbconvert" && -e "$datadir/messrest.dbconvert") {
		if (-e "$memberdir/memberrest.dbconvert" && -M "$memberdir/memberrest.dbconvert" < 1) {
			@contents = &read_DBorFILE(0,'',$memberdir,'memberrest','dbconvert');

			($start_time,$sumuser) = &read_DBorFILE(0,'',$memberdir,'membercalc','dbconvert');
			chomp ($start_time, $sumuser);
		}

		if (!@contents) {
			# Get the list
			opendir(MEMBERS, $memberdir) || die "$txt{'230'} ($memberdir) :: $!";
			@contents = map { $_ =~ s/\.vars$//; "$_\n"; } grep { /.\.vars$/ } readdir(MEMBERS);
			closedir(MEMBERS);

			$start_time = $begin_time;
			$sumuser = @contents;
			&write_DBorFILE(0,'',$memberdir,'membercalc','dbconvert',("$start_time\n$sumuser\n"));
		}

		# Loop through each -rest- member
		my $member;
		my @notnull_default0 = (qw/hidemail stealth dsttimeoffset dynamic_clock postcount im_popup im_imspop pmmessprev pmviewMess pmactprev notify_me reversetopic onlinealert spamcount hide_avatars hide_user_text hide_attach_img hide_signat hide_smilies_row numberformat/);
		my @notnull_default1 = (qw/timeselect/);
		while (@contents) {
			$member = pop @contents;
			chomp $member;

			# Load the users info from file
			$use_MySQL = 0;
			&LoadUser($member);
			
			# make sure that NOT NULL values actually have a value before submitting them to the database
			foreach my $tag (@notnull_default0) {
				if (${$uid.$member}{$tag} eq "") {
					${$uid.$member}{$tag} = 0;
				}
			}
			foreach my $tag (@notnull_default1) {
				if (${$uid.$member}{$tag} eq "") {
					${$uid.$member}{$tag} = 1;
				}
			}

			# save the users info to MySQL
			$use_MySQL = 1;
			&UserAccount($member);

			foreach (qw(msg ims outbox imstore imdraft log rlog)) {
				$use_MySQL = 0;
				my @temp = &read_DBorFILE(1,'',$memberdir,$member,$_);
				$use_MySQL = 1;
				&write_DBorFILE(1,'',$memberdir,$member,$_,@temp) if @temp;
			}

			undef %{$uid.$member} if $member ne $username;
			last if time() > ($begin_time + $max_process_time);
		}
		$use_MySQL = 0;

		# If it isn't completely done ...
		if (@contents) {
			&write_DBorFILE(0,'',$memberdir,'memberrest','dbconvert',@contents);

			&do_info(scalar(@contents),$start_time,$sumuser,'database3','varstodb');

			&AdminTemplate();
		}
	}

	# onlinelog will be build new, don't need conversion

	# convert Messages/....[txt|ctb|mail|poll|polled]
	#unless (-e "$.../...rest.dbconvert" && -e "$.../...calc.dbconvert") {
		if (-e "$datadir/messrest.dbconvert" && -M "$datadir/messrest.dbconvert" < 1) {
			@contents = &read_DBorFILE(0,'',$datadir,'messrest','dbconvert');

			($start_time,$sumuser) = &read_DBorFILE(0,'',$datadir,'messcalc','dbconvert');
			chomp ($start_time, $sumuser);
		}

		if (!@contents) {
			# Get the list
			opendir(TXT, $datadir) || die "$txt{'230'} ($datadir) :: $!";
			@contents = map { $_ =~ s/\.txt$//; "$_\n"; } grep { /\d+\.txt$/ } readdir(TXT);
			closedir(TXT);

			$sumuser = @contents;
			&write_DBorFILE(0,'',$datadir,'messcalc','dbconvert',("$start_time\n$sumuser\n"));
		}

		# Loop through each -rest- thread
		my $thread;
		while (@contents) {
			$thread = pop @contents;
			chomp $thread;

			$use_MySQL = 0;
			# Load thread-file
			my @temp = &read_DBorFILE(0,'',$datadir,$thread,'txt');
			for (my $i = 0; $i < @temp; $i++) {
				my @x = split(/\|/, $temp[$i]);
				$x[5] = 'no_postcount' if $x[6] eq 'no_postcount';
				$x[6] = $i;
				$x[12] = $x[12] || "\n"; # fix of mistake in old moved infos
				splice(@x,13); # make sure we don't have too much entrys
				$temp[$i] = join('|', @x);
			}

			# Load ctb-file
			&MessageTotals("load",$thread);

			$use_MySQL = 1;
			# Save thread to MySQL
			&write_DBorFILE(0,'',$datadir,$thread,'txt',@temp);

			# Save ctb to MySQL
			&MessageTotals("update",$thread);
			undef %{$thread};

			foreach (qw(mail poll polled)) {
				next if !-e "$datadir/$thread.$_";
				$use_MySQL = 0;
				@temp = &read_DBorFILE(0,'',$datadir,$thread,$_);
				$use_MySQL = 1;
				&write_DBorFILE(1,'',$datadir,$thread,$_,@temp) if @temp;
			}

			last if time() > ($begin_time + $max_process_time);
		}
		$use_MySQL = 0;

		# If it isn't completely done ...
		if (@contents) {
			&write_DBorFILE(0,'',$datadir,'messrest','dbconvert',@contents);

			&do_info(scalar(@contents),$start_time,$sumuser,'database3','threadtodb');

			&AdminTemplate;
		}
	#}


	&delete_DBorFILE("$memberdir/memberrest.dbconvert");
	&delete_DBorFILE("$memberdir/membercalc.dbconvert");
	&delete_DBorFILE("$datadir/messrest.dbconvert");
	&delete_DBorFILE("$datadir/messcalc.dbconvert");

	&automaintenance("off"); # Must be set to off before &SaveSettingsTo(... !

	$use_MySQL = 1;
	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');

	$yymain .= qq~<font color="red"><b>$db_txt{'100'}</b></font><br />\n~;

	$debug = 0; # because output can be huge!!!
	&SelectDatabase;
}

sub ReturnFileDB {
	my (@contents, $begin_time, $start_time, $sumuser);

	# Security
	&is_admin;
	&automaintenance("on");

	# Set up the multi-step action
	$begin_time = time();

	# convert .vars
	unless (-e "$datadir/ctbrest.dbconvert" && -e "$datadir/ctbcalc.dbconvert") {
		if (-e "$memberdir/memberrest.dbconvert" && -M "$memberdir/memberrest.dbconvert" < 1) {
			@contents = &read_DBorFILE(0,'',$memberdir,'memberrest','dbconvert');

			($start_time,$sumuser) = &read_DBorFILE(0,'',$memberdir,'membercalc','dbconvert');
			chomp ($start_time, $sumuser);
		}

		if (!@contents) {
			# Get the list
			@contents = map { "$$_[0]\n"; } @{&mysql_process(0,'selectall_arrayref',"SELECT `" . ($db_user_vars_table ? $db_user_vars_key : "yabbusername") . "` FROM `" . ($db_user_vars_table ? $db_user_vars_table : "$db_prefix\_vars") . "`")};

			$start_time = $begin_time;
			$sumuser = @contents;
			&write_DBorFILE(0,'',$memberdir,'membercalc','dbconvert',("$start_time\n$sumuser\n"));
		}

		# Loop through each -rest- member
		while (@contents) {
			$member = pop @contents;
			chomp $member;

			# Load the users info from MySQL
			$use_MySQL = 1;
			&LoadUser($member);

			# save the users info to file
			$use_MySQL = 0;
			&UserAccount($member);
			undef %{$uid.$member} if $member ne $username;

			foreach (qw(msg ims outbox imstore imdraft log rlog)) {
				$use_MySQL = 1;
				my @temp = &read_DBorFILE(0,'',$memberdir,$member,$_);
				$use_MySQL = 0;
				&write_DBorFILE(0,'',$memberdir,$member,$_,@temp);
			}

			last if time() > ($begin_time + $max_process_time);
		}
		$use_MySQL = 1;

		# If it isn't completely done ...
		if (@contents) {
			&write_DBorFILE(0,'',$memberdir,'memberrest','dbconvert',@contents);

			&do_info(scalar(@contents),$start_time,$sumuser,'database4','dbtovars');

			&AdminTemplate();
		}
	}

	# onlinelog will be build new, don't need conversion

	# convert Messages/....[txt|ctb|mail|poll|polled]
	if (-e "$datadir/ctbrest.dbconvert" && -M "$datadir/ctbrest.dbconvert" < 1) {
		@contents = &read_DBorFILE(0,'',$datadir,'ctbrest','dbconvert');

		($start_time,$sumuser) = &read_DBorFILE(0,'',$datadir,'ctbcalc','dbconvert');
		chomp ($start_time, $sumuser);
	}

	if (!@contents) {
		# Get the list
		@contents = map { "$$_[0]\n"; } @{&mysql_process(0,'selectall_arrayref',"SELECT `threadnum` FROM `$db_prefix\_ctb`")};

		$sumuser = @contents;
		&write_DBorFILE(0,'',$datadir,'ctbcalc','dbconvert',("$start_time\n$sumuser\n"));
	}

	# Loop through each -rest- member
	while (@contents) {
		$thread = pop @contents;
		chomp $thread;

		my @temp;
		foreach (qw(txt mail poll polled)) {
			$use_MySQL = 1;
			@temp = &read_DBorFILE(0,'',$datadir,$thread,$_);
			next if !@temp;
			$use_MySQL = 0;
			&write_DBorFILE(0,'',$datadir,$thread,$_,@temp);
		}

		$use_MySQL = 1;
		# Load ctb MySQL
		&MessageTotals("load",$thread);


		$use_MySQL = 0;
		# Save ctb to file
		&MessageTotals("update",$thread);
		undef %{$thread};

		last if time() > ($begin_time + $max_process_time);
	}
	$use_MySQL = 1;

	# If it isn't completely done ...
	if (@contents) {
		&write_DBorFILE(0,'',$datadir,'ctbrest','dbconvert',@contents);

		&do_info(scalar(@contents),$start_time,$sumuser,'database4','dbtotxt');

		&AdminTemplate;
	}

	&delete_DBorFILE("$memberdir/memberrest.dbconvert");
	&delete_DBorFILE("$memberdir/membercalc.dbconvert");
	&delete_DBorFILE("$datadir/ctbrest.dbconvert");
	&delete_DBorFILE("$datadir/ctbcalc.dbconvert");

	&automaintenance("off"); # Must be set to off before &SaveSettingsTo(... !

	$use_MySQL = 0;
	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');

	$yymain .= qq~<font color="red"><b>$db_txt{'101'}</b></font><br />\n~;

	$debug = 0; # because output can be huge!!!
	&SelectDatabase;
}

sub Delete_files {
	my (@contents, $begin_time, $start_time, $sumuser, $member, $txt);

	# Security
	&is_admin;
	&automaintenance("on");

	# Set up the multi-step action
	$begin_time = time();

	# delete Members/....[vars|msg|ims|outbox|imstore|imdraft|log|rlog]
	unless (-e "$datadir/txtdel.dbconvert" && -e "$datadir/txtdelcalc.dbconvert") {
		if (-e "$memberdir/memberdel.dbconvert" && -M "$memberdir/memberdel.dbconvert" < 1) {
			@contents = &read_DBorFILE(0,'',$memberdir,'memberdel','dbconvert');

			($start_time,$sumuser) = &read_DBorFILE(0,'',$memberdir,'memberdelcalc','dbconvert');
			chomp ($start_time, $sumuser);
		}

		if (!@contents) {
			# Get the list
			opendir(MEMBERS, $memberdir) || die "$txt{'230'} ($memberdir) :: $!";
			@contents = map { $_ =~ s/\.vars$//; "$_\n"; } grep { /.\.vars$/ } readdir(MEMBERS);
			closedir(MEMBERS);

			$start_time = $begin_time;
			$sumuser = @contents;
			&write_DBorFILE(0,'',$memberdir,'memberdelcalc','dbconvert',("$start_time\n$sumuser\n"));
		}

		# Loop through each -rest- member
		$use_MySQL = 0;
		while (@contents) {
			$member = pop @contents;
			chomp $member;

			if ($member ne 'admin') {
				foreach (qw(vars msg ims outbox imstore imdraft log rlog)) {
					&delete_DBorFILE("$memberdir/$member.$_");
				}
			}

			last if time() > ($begin_time + $max_process_time);
		}
		$use_MySQL = 1;

		# If it isn't completely done ...
		if (@contents) {
			&write_DBorFILE(0,'',$memberdir,'memberdel','dbconvert',@contents);

			&do_info(scalar(@contents),$start_time,$sumuser,'database5','varsdel');

			&AdminTemplate();
		}
	}


	# empty onlinelog
	&write_DBorFILE(0,'',$vardir,'log','txt',(''));


	# delete Messages/....[vars|ctb|mail|poll|polled]
	if (-e "$datadir/txtdel.dbconvert" && -M "$datadir/txtdel.dbconvert" < 1) {
		@contents = &read_DBorFILE(0,'',$datadir,'txtdel','dbconvert');

		($start_time,$sumuser) = &read_DBorFILE(0,'',$datadir,'txtdelcalc','dbconvert');
		chomp ($start_time, $sumuser);
	}

	if (!@contents) {
		# Get the list
		opendir(TXT, $datadir) || die "$txt{'230'} ($datadir) :: $!";
		@contents = map { $_ =~ s/\.txt$//; "$_\n"; } grep { /\d+\.txt$/ } readdir(TXT);
		closedir(TXT);

		$sumuser = @contents;
		&write_DBorFILE(0,'',$datadir,'txtdelcalc','dbconvert',("$start_time\n$sumuser\n"));
	}

	# Loop through each -rest- thread
	$use_MySQL = 0;
	while (@contents) {
		$txt = pop @contents;
		chomp $txt;

		foreach (qw(txt ctb mail poll polled)) {
			&delete_DBorFILE("$datadir/$txt.$_");
		}

		last if time() > ($begin_time + $max_process_time);
	}
	$use_MySQL = 1;

	# If it isn't completely done ...
	if (@contents) {
		&write_DBorFILE(0,'',$datadir,'txtdel','dbconvert',@contents);

		&do_info(scalar(@contents),$start_time,$sumuser,'database5','txtdel');

		&AdminTemplate;
	}

	&delete_DBorFILE("$memberdir/memberdel.dbconvert");
	&delete_DBorFILE("$memberdir/memberdelcalc.dbconvert");
	&delete_DBorFILE("$datadir/txtdel.dbconvert");
	&delete_DBorFILE("$datadir/txtdelcalc.dbconvert");

	&automaintenance("off");

	$yymain .= qq~<font color="red"><b>$db_txt{'105'}</b></font><br />\n~;

	$debug = 0; # because output can be huge!!!
	&SelectDatabase;
}

sub do_info {
	my ($restuser,$start_time,$sumuser,$action,$text) = @_;

	my $run_time = int(time() - $start_time) || 1;
	my $time_left = int($restuser / (($sumuser - $restuser + 1) / $run_time));
	my $hour= int($run_time/3600);
	my $min = int(($run_time-$hour*3600)/60);
	my $sec = $run_time - $hour*3600 - $min*60;
	$hour = "0$hour" if $hour<10; $min = "0$min" if $min<10; $sec = "0$sec" if $sec<10;
	$run_time = "$hour:$min:$sec";

	$hour= int($time_left/3600);
	$min = int(($time_left-$hour*3600)/60);
	$sec = $time_left - $hour*3600 - $min*60;
	$hour = "0$hour" if $hour<10; $min = "0$min" if $min<10; $sec = "0$sec" if $sec<10;
	$time_left = "$hour:$min:$sec";

	$debug = 0; # because output can be huge!!!

	$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr>
		<td align="left" class="titlebg">
		<img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$rebuild_txt{'title'}</b>
		</td>
	</tr>
	<tr>
		<td align="left" class="windowbg">
			$rebuild_txt{'1'}<br />
			$rebuild_txt{'5'} = $max_process_time $rebuild_txt{'6'}<br />
			<br />
			$rebuild_txt{$text} $sumuser<br />
			$rebuild_txt{$text.'a'} $restuser<br />
			<br />
			$rebuild_txt{'7'} $run_time<br />
			$rebuild_txt{'8'} $time_left<br />
			<br />
			<div id="memcontinued">
			$rebuild_txt{'2'} <a href="$adminurl?action=$action" onclick="clearMeminfo();">$rebuild_txt{'3'}</a>
			</div>
			<script type="text/javascript" language="JavaScript">
			 <!--
				function clearMeminfo() {
					document.getElementById("memcontinued").innerHTML = '$rebuild_txt{'4'}';
				}

				function membtick() {
					clearMeminfo();
					location.href = "$adminurl?action=$action";
				}

				setTimeout("membtick()", 5000);
			 // -->
			</script>
		</td>
	</tr>
</table>
</div>~;
}

1;
