###############################################################################
# NewSettings.pl                                                              #
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

$newsettingsplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

# Figure out what tabset to use, depending on the page= parameter.
my %settings_dispatch = (
	news => "$admindir/Settings_News.pl",
	main => "$admindir/Settings_Main.pl",
	advanced => "$admindir/Settings_Advanced.pl",
	security => "$admindir/Settings_Security.pl",
	antispam => "$admindir/Settings_Antispam.pl",
	maintenance => "$admindir/Settings_Maintenance.pl",

	### BOARDMOD SETTINGS ANCHOR ###
	### ADD BEFORE THESE LINES   ###
);

my $page = $INFO{'page'};
# 'eval' because NewSettings.pl can be called by Sources/TabMenu.pl
eval{ require $settings_dispatch{$page}; };

sub settings {
	&is_admin_or_gmod;

	$yytitle = $page eq 'main' ? $admin_txt{'222'} : ($page eq 'advanced' ? $admin_txt{'223'} : ($page eq 'security' ? $admintxt{'a3_title'} : ($page eq 'antispam' ? $admintxt{'a3_sub4'} : ($page eq 'maintenance' ? $admintxt{'a7_title'} : $admintxt{'a2_sub1'}))));

	my @requireorder; # an array for the correct order of the requirements
	my %requirements; # an hash that says "Y is required by X"

	$yymain .= qq~
   <a name="top"></a>
   <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
         <b>$yytitle</b>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><br />
        $admin_txt{'347'}
       </td>
     </tr>
  </table>
  </div>
  <br />
  <form action="$adminurl?action=newsettings2;page=$page" onsubmit="undisableAll(this);" method="post">
  <ul id="navlist">
~;
	my $i = 0;
	foreach my $tab (@settings) {
		$tab->{'name'} =~ s/ /&nbsp;/g;
		# The &nbsp;'s are for Konqueror, and also to add a little more padding.
		$yymain .= qq~    <li id="button_$tab->{'id'}" onclick="changeToTab('$tab->{'id'}'); return false;">&nbsp;<a href="#tab_$tab->{'id'}">$tab->{'name'}</a>&nbsp;</li>
~;
	}
	$yymain .= q~  </ul>~;

	foreach my $tab (@settings) {
		$yymain .= qq~
  <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
    <table width="100%" cellspacing="1" cellpadding="4" class="section" id="tab_$tab->{'id'}">
     <tr>
       <td style="text-align: left;" class="titlebg" colspan="2">
         <a name="tab_$tab->{'id'}"></a><img src="$imagesdir/preferences.gif" alt="" border="0" /> <b>$tab->{'name'}</b>
         <span style="float: right;" class="js_remove_me"><a href="#top"><b>$settings_txt{'top'}</b></a></span>
       </td>
     </tr>~;

		foreach my $item (@{$tab->{'items'}}) {
			if($item->{'header'}) {
				$yymain .= qq~
     <tr>
       <td style="text-align: left;" class="catbg" colspan="2">
         <span class="small">$item->{'header'}</span>
       </td>
     </tr>~;
			}
			elsif($item->{'two_rows'} && $item->{'input_html'}) {
				$yymain .= qq~
     <tr style="text-align: left;">
       <td style="width: 50%;" class="windowbg2" colspan="2">
         $item->{'description'}
       </td>
     </tr>
     <tr style="text-align: left;">
       <td style="width: 50%;" class="windowbg2" colspan="2">
         $item->{'input_html'}
       </td>
     </tr>~;
			}
			elsif($item->{'input_html'}) {
				$yymain .= qq~
     <tr style="text-align: left;">
       <td style="width: 50%;" class="windowbg2" valign="top">
         $item->{'description'}
       </td>
       <td style="width: 50%;" class="windowbg2" valign="top">
         $item->{'input_html'}
       </td>
     </tr>~;
			}

			# Handle settings that require other settings
			if ($item->{'depends_on'} && $item->{'name'}) {
				foreach my $require (@{$item->{'depends_on'}}) {
					# This is somewhat messy, but it works well.
					# We strip off the possible options: inverse, equal, and not equal
					# Then we attach those to this current option in the detailed string for requirements
					# While this data does not really belong with the value, it transfers nicely.
					# We then remove it and reuse it later.
					my($inverse, $realname, $remainder) = $require =~ m/(\(?\!?)(\w+)(.*)/;
					push(@requireorder, $realname) unless $requirements{$realname};
					push(@{$requirements{$realname}}, $inverse . $item->{'name'} . $remainder);
				}
			}
		}

		$yymain .= qq~
   </table>
  </div>~;
	}

	# The old method isn't quite good enough.
	# So we build a hash with the Javascript logic needed to determine if this item should be enabled.
	# When in doubt, generate some code :)
	my %requirejs;

	my $dependicies = '';
	my $onloadevents;
	foreach my $ritem (@requireorder) {
		$dependicies .= qq~
	function handleDependent_$ritem() {
		var isChecked = document.getElementsByName("$ritem")[0].checked;
		var itemValue = document.getElementsByName("$ritem")[0].value;\n~;

		foreach my $require (@{$requirements{$ritem}}) {
			# && or ||, ( and )
			my $AndOr = $require =~ s/\)// ? ')' : '';
			$AndOr   .= $require =~ s/\|\|// ? ' ||' : ' &&';
			my $C     = $require =~ s/\(// ? '(' : '';
			# Is false
			if ($require =~ s/^\!//) {
				$requirejs{$require} .= qq~$C\!document.getElementsByName("$ritem")[0].checked$AndOr ~;
			}
			# Is equal to
			elsif ($require =~ s/\=\=(.*)$//) {
				$requirejs{$require} .= qq~$C\document.getElementsByName("$ritem")[0].value == '$1'$AndOr ~;
			}
			# Is not equal to
			elsif ($require =~ s/\!\=(.*)$//) {
				$requirejs{$require} .= qq~$C\document.getElementsByName("$ritem")[0].value != '$1'$AndOr ~;
			}
			# Is true
			else {
				$requirejs{$require} .= qq~$C\document.getElementsByName("$ritem")[0].checked$AndOr ~;
			}
			$dependicies .= qq~		checkDependent("$require");\n~;
		}
		$dependicies .= qq~	};
	document.getElementsByName("$ritem")[0].onclick = handleDependent_$ritem;
	document.getElementsByName("$ritem")[0].onkeyup = handleDependent_$ritem;
~;
		$onloadevents .= qq~handleDependent_$ritem(); ~;
	}

	# Hidden "feature": jump directly to a tab by default via the URL bar.
	$INFO{'tab'} =~ s/\W//g;
	$default_tab = $INFO{'tab'} || $settings[0]->{'id'};
	$yymain .= qq~
  <div class="bordercolor" style="padding: 0px; width: 99%; margin-top: 1em; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="2">
         <img src="$imagesdir/preferences.gif" alt="" border="0" /> <b>$admin_txt{'10'}</b>
       </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="center" class="catbg" colspan="2">
         <input class="button" type="submit" value="$admin_txt{'10'}" />
       </td>
     </tr>
   </table>
  </div>
  </form>
  <script type="text/javascript">
  <!--
	function getElementsByClass(searchClass,node,tag) {
		var classElements = new Array();
		if ( node == null )
			node = document;
		if ( tag == null )
			tag = '*';
		var els = node.getElementsByTagName(tag);
		var elsLen = els.length;
		var pattern = new RegExp('(^|\\s)'+searchClass+'(\\s|\$)');
		for (i = 0, j = 0; i < elsLen; i++) {
			if ( pattern.test(els[i].className) ) {
				classElements[j] = els[i];
				j++;
			}
		}
		return classElements;
	}
	function changeToTab(tab) {
		var elements = getElementsByClass('section');
		var i;
		for(i = 0; i < elements.length; i++) {
			if(elements[i].id == 'tab_' + tab) {
				elements[i].style.display = '';
			}
			else {
				elements[i].style.display = 'none';
			}
		}
		var elm = getElementsByClass('curtab')[0];
		if(elm) {
			elm.className = '';
		}
		document.getElementById('button_' + tab).className = 'curtab';
	}
	var removables = getElementsByClass('js_remove_me');
	var i;
	for(i = 0; i < removables.length; i++) {
		removables[i].innerHTML = '';
	}
	changeToTab('$default_tab'); // Focus default tab
	function checkDependent(eid) {
		var elm = document.getElementsByName(eid)[0];\n~;

		# Loop through each item that depends on something else
		foreach my $name (keys(%requirejs)) {
			my $logic = $requirejs{$name};
			$logic    =~ s/ (&&|\|\|) $//;
			$yymain .= qq~
		if (eid == "$name" && ($logic)) {
			elm.disabled = false;
		} else if (eid == "$name") {
			elm.disabled = true;
		}\n~;
		}

	$yymain.= qq~
	}
$dependicies
	window.onload = function(){ $onloadevents};
	function undisableAll(node) {
		var elements = document.getElementsByTagName("input");
		for(var i = 0; i < elements.length; i++) {
			elements[i].disabled = false;
		}
		var elements = document.getElementsByTagName("textarea");
		for(var i = 0; i < elements.length; i++) {
			elements[i].disabled = false;
		}
		var elements = document.getElementsByTagName("select");
		for(var i = 0; i < elements.length; i++) {
			elements[i].disabled = false;
		}
	}
  // -->
  </script>~;

	$action_area = "newsettings;page=$page";
	&AdminTemplate;
}

sub ischecked {
	# Return a ref so we can be used like ${ischecked($var)} inside a string
	return \' checked="checked"' if $_[0];
	return \'';
}

sub isselected {
	# Return a ref so we can be used like ${isselected($var)} inside a string
	return \' selected="selected"' if $_[0];
	return \'';
}

# Regexes. Will be used like this: $var =~ /^(?:$regexes{'a'}|$regexes{'b'}|$regexes{'c'})$/ || die;
my %regexes = (
boolean     => '.*', # anything. True is not 0 and defined, false is 0/undefined
number      => '\d+', # just numbers
fullnumber  => '(?:\+|\-|)[\d\.]+', # optional sign, plus numbers and decimal
hexadecimal => '#?[0-9a-fA-F]+', # optional "#" (for hex color codes), plus hex characters
alpha       => '[a-zA-Z]+', # Letters
text        => '[^\n\r]+', # Anything but newlines
fulltext    => '(?s).+', # Anything, including newlines
null        => '', # Use this if something can be false, in addition to the normal valid characters (not needed for boolean)
);

# Preserve the traditional "2" name as well as the nicer SaveSettings.
sub settings2 {
	&is_admin_or_gmod;

	# Load/Verify the settings
	foreach my $tab (@settings) {
		foreach my $item (@{$tab->{'items'}}) {
			# Get the value
			my $name = $item->{'name'} || next; # Skip non-items
			$settings{$name} = $FORM{$name};
			$settings{$name} = '' unless defined $settings{$name};

			$settings{$name} =~ s/^\s+//;
			$settings{$name} =~ s/\s+$//;

			# Validate it
			if ($item->{'validate'}) {
				# Handle numbers/nulls better (empty string is 0)
				if ($item->{'validate'} =~ /null/ && $item->{'validate'} =~ /number/) {
					$settings{$name} ||= 0;
				}

				# Handle text/nulls better (empty string is empty string :)
				if ($item->{'validate'} =~ /null/ && $item->{'validate'} =~ /text/) {
					$settings{$name} ||= '';
				}

				# Piece together the patterns. It only needs to validate 1 pattern, but the pattern must be the whole string.
				my $pattern = '^(?:' . join('|', @regexes{split(/,/, $item->{'validate'})}) . ')$';
				&fatal_error('invalid_value', qq~$name ($item->{'description'})~) unless $settings{$name} =~ /$pattern/;

				# Set numeric options to 0 if they are null
				if ($item->{'validate'} eq 'boolean') {
					$settings{$name} = $settings{$name} ? 1 : 0;
				}
			}
		}
	}

	# Save them, as according to this type of settings
	# This subroutine resides in the file that is loaded in the hash at the top of the file.
	&SaveSettings(%settings);

	# Redirect.
	$yySetLocation = "$adminurl?action=newsettings;page=$page";
	&redirectexit;
}

# Subroutine for saving to Settings.pl
sub SaveSettingsTo {
	my $file     = shift;
	my %settings = @_;

	# This is why we should use hashes for options to begin with.
	foreach my $key (keys(%settings)) {
		$$key = delete($settings{$key});
		# Sanitize the input using \Q...\E later.
	}

	if ($codemaxchars > 15) { $codemaxchars = 15; }

	my $setfile;
	if ($file eq 'Settings.pl') {
		if ($settings_file_version ne $YaBBversion) { # START upgrade codes
			# The following is for upgrades from YaBB versions < 2.3 START
			if ($enable_notifications eq '') { $enable_notifications = $enable_notification ? 3 : 0; }
			$fix_avatar_img_size ||= 0;
			$fix_post_img_size ||= 0;
			$fix_signat_img_size ||= 0;
			$fix_attach_img_size ||= 0;
			# The following is for upgrades from YaBB versions < 2.3 END

			# The following is for upgrades from YaBB versions < 2.4 START
			if (-e "$vardir/membergroups.txt") { require "$vardir/membergroups.txt"; }
			if (!@nopostorder && -e "$vardir/nopostorder.txt") {
				@nopostorder = &read_DBorFILE(0,'',$vardir,'nopostorder','txt');
				chomp(@nopostorder);
			}

			if (-e "$vardir/advsettings.txt") { require "$vardir/advsettings.txt"; }
			if (-e "$vardir/secsettings.txt") { require "$vardir/secsettings.txt"; }

			if (-e "$vardir/Smilies.txt") {
				require "$vardir/Smilies.txt";
				$popback =~ s/[^a-f0-9]//ig;
				$poptext =~ s/[^a-f0-9]//ig;
			}

			if (-e "$vardir/template.cfg") { require "$vardir/template.cfg"; }
			elsif (!%templateset) { # only for upgrade from very old versions
				opendir(TMPLDIR, "$templatesdir"); my @configs = readdir(TMPLDIR); closedir(TMPLDIR);
				foreach (@configs) { if (-e "$templatesdir/$_/$_.cfg") { require "$admindir/ManageTemplates.pl"; &UpdateTemplates($_, "new"); } }
			}

			if (-e "$vardir/Guardian.banned") { require "$vardir/Guardian.banned"; }
			if (-e "$vardir/Guardian.settings") { require "$vardir/Guardian.settings"; }

			if (-e "$vardir/ban.txt") {
				foreach (&read_DBorFILE(0,'',$vardir,'ban','txt')) {
					my ($type, $bannedlist) = split(/\|/, $_, 2);
					chomp($bannedlist);
					$ip_banlist = $bannedlist if $type =~ /I/i;
					$email_banlist = $bannedlist if $type =~ /E/i;
					$user_banlist = $bannedlist if $type =~ /U/i;
				}
			}

			if (-e "$vardir/HelpSettings.txt") { require "$vardir/HelpSettings.txt"; }
			if (-e "$vardir/BackupSettings.cgi") { require "$vardir/BackupSettings.cgi"; @backup_paths = @paths; }

			if (-e "$vardir/extended_profiles_order.txt") {
				@ext_prof_order = &read_DBorFILE(0,'',$vardir,'extended_profiles_order','txt');
				chomp(@ext_prof_order);
			}
			if (-e "$vardir/extended_profiles_fields.txt") {
				@ext_prof_fields = &read_DBorFILE(0,'',$vardir,'extended_profiles_fields','txt');
				chomp(@ext_prof_fields);
			}

			if (-e "$vardir/palette.def") {
				@pallist = &read_DBorFILE(0,'',$vardir,'palette','def'); chomp(@pallist);
			}

			if (!@AdvancedTabs) {
				if (-e "$vardir/taborder.txt") {
					@AdvancedTabs = &read_DBorFILE(0,'',$vardir,'taborder','txt');
					chomp(@AdvancedTabs);
				} else { @AdvancedTabs = qw (home help search ml eventcal birthdaylist admin revalidatesession login register guestpm mycenter logout); }

				my @temp = &read_DBorFILE(1,'',$vardir,'tabs_ext','def');
				if (@temp) {
					my %exttabs = map /(.*)\t(.*)/, @temp;
					for (my $i = 0; $i < @AdvancedTabs; $i++) {
						if ($exttabs{$AdvancedTabs[$i]}) {
							$exttabs{$AdvancedTabs[$i]} =~ s/"//g;
							$AdvancedTabs[$i] .= "|$exttabs{$AdvancedTabs[$i]}";
						}
					}
					chomp(@AdvancedTabs);
				}
			}
			# The following is for upgrades from YaBB versions < 2.4 END

			# The following is for upgrades from YaBB versions < 2.5 START
			# Add event calendar to Tabs
			my %testTabs;
			map { $testTabs{$_} = 1 } @AdvancedTabs;
			push(@AdvancedTabs, 'eventcal') if !$testTabs{'eventcal'};
			push(@AdvancedTabs, 'birthdaylist') if !$testTabs{'birthdaylist'};

			
			# The following is for upgrades from YaBB versions < 2.5 END

			# The following is for upgrades from YaBB versions < 2.3 START
			if (-e "$vardir/upgrade_secsettings.txt") { require "$vardir/upgrade_secsettings.txt"; }
			if (-e "$vardir/upgrade_advsettings.txt") { require "$vardir/upgrade_advsettings.txt"; }
			if (-e "$vardir/upgrade_Settings.pl") { require "$vardir/upgrade_Settings.pl"; }
			# The following is for upgrades from YaBB versions < 2.3 END
		} # END upgrade codes

		my $templateset = join('', map { qq~'$_' => "$templateset{$_}",\n~; } keys(%templateset));

		my $ext_prof_order = '"' . join('","', @ext_prof_order) . '"' if @ext_prof_order;
		my $ext_prof_fields = '"' . join(qq~",\n"~, @ext_prof_fields) . '"' if @ext_prof_fields;

		my $member_groups = "# Static Member Groups\n";
		foreach (keys %Group)  { $member_groups .= qq~\$Group{'$_'} = '$Group{$_}';\n~; }
		$member_groups .= "\n# Post independent Member Groups\n";
		foreach (keys %NoPost) { $member_groups .= qq~\$NoPost{'$_'} = '$NoPost{$_}';\n~; }
		$member_groups .= "\n# Post dependent Member Groups\n";
		foreach (keys %Post)   { $member_groups .= qq~\$Post{'$_'} = '$Post{$_}';\n~; }

		my $pallist = '"' . join('","', @pallist) . '"' if @pallist;

		if ($INFO{'page'} eq 'main') {
			if (!$enable_notifications_N && !$enable_notifications_PM) {
				$enable_notifications = 0;
			} elsif ($enable_notifications_N && !$enable_notifications_PM) {
				$enable_notifications = 1;
			} elsif (!$enable_notifications_N && $enable_notifications_PM) {
				$enable_notifications = 2;
			} elsif ($enable_notifications_N && $enable_notifications_PM) {
				$enable_notifications = 3;
			}
		}

		my $AdvancedTabs = '"' . join('","', @AdvancedTabs) . '"';

		my $SmilieURL = '"' . join('","', @SmilieURL) . '"' if @SmilieURL;
		my $SmilieCode = '"' . join('","', @SmilieCode) . '"' if @SmilieCode;
		my $SmilieDescription = '"' . join('","', @SmilieDescription) . '"' if @SmilieDescription;
		my $SmilieLinebreak = '"' . join('","', @SmilieLinebreak) . '"' if @SmilieLinebreak;

		my $backup_paths = join(' ', @backup_paths);

		my $use_MySQL_comment = '#' if !$use_MySQL;
		my $db_user_vars_col = join("", map { qq~'$_' => '$db_user_vars_col{$_}',~; } keys %db_user_vars_col) if %db_user_vars_col;
		my $db_vars_col = join("", map { qq~'$_' => 1,~; } keys %db_vars_col) if %db_vars_col;
		my $db_vars_tabs_order = "'" . join("','", @db_vars_tabs_order) . "'" if @db_vars_tabs_order;

		$smtp_server =~ s/^\s+|\s+$//g;

		$setfile = << "EOF";
###############################################################################
# Settings.pl                                                                 #
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

########## Board Info ##########
# Note: these settings must be properly changed for YaBB to work

\$settings_file_version = "$YaBBversion";		# If not equal actual YaBBversion then the updating process is run through

\%templateset = (
$templateset);						# Forum templates settings

\$members_total = $members_total;			# Total number of Members
\$last_member = "\Q$last_member\E";			# Name of the last Member

\$maintenance = $maintenance;				# Set to 1 to enable Maintenance mode
\$rememberbackup = $rememberbackup;			# seconds past since last backup until alert is displayed
\$maintenancetext = "\Q$maintenancetext\E";		# Admin-defined text for Maintenance mode

\$guestaccess = $guestaccess;				# Set to 0 to disallow guests from doing anything but login or register

\$mbname = "\Q$mbname\E";				# The name of your YaBB forum
\$forumstart = "\Q$forumstart\E";			# The start date of your YaBB Forum
\$Cookie_Length = $Cookie_Length;			# Default minutes to set login cookies to stay for
\$cookieusername = "\Q$cookieusername\E";		# Name of the username cookie
\$cookiepassword = "\Q$cookiepassword\E";		# Name of the password cookie
\$cookiesession_name = "\Q$cookiesession_name\E";	# Name of the Session cookie

\$regtype = $regtype;					# 0 = registration closed (only admin can register), 1 = pre registration with admin approval, 
							# 2 = pre registration and email activation, 3 = open registration
\$RegAgree = $RegAgree;					# Set to 1 to display the registration agreement when registering
\$allow_self_del = $allow_self_del;				# Set to 1 to allow users to delete their Profile.
\$RegReasonSymbols = $RegReasonSymbols;			# Maximum allowed symbols in User reason(s) for registering
\$preregspan = $preregspan;				# Time span in hours for users to account activation before cleanup
\$pwstrengthmeter_scores = "\Q$pwstrengthmeter_scores\E";	# Password-Strength-Meter Scores
\$pwstrengthmeter_common = "\Q$pwstrengthmeter_common\E";	# Password-Strength-Meter common words
\$pwstrengthmeter_minchar = $pwstrengthmeter_minchar;	# Password-Strength-Meter minimum characters
\$emailpassword = $emailpassword;			# 0 - instant registration. 1 - password emailed to new members
\$emailnewpass = $emailnewpass;				# Set to 1 to email a new password to members if they change their email address
\$emailwelcome = $emailwelcome;				# Set to 1 to email a welcome message to users even when you have mail password turned off
\$name_cannot_be_userid = $name_cannot_be_userid;	# Set to 1 to require users to have different usernames and display names
\$cannot_change_displayname = $cannot_change_displayname;	# Set to 1 for users can not change their displayname
\$birthday_on_reg = $birthday_on_reg;			# Set to 0: don't ask for birthday on registration
							# 1: ask for the birthday, no input required
							# 2: ask for the birthday, input required

\$gender_on_reg = $gender_on_reg;			# 0: don't ask for gender on registration
							# 1: ask for gender, no input required
							# 2: ask for gender, input required
\$lang = "\Q$lang\E";					# Default Forum Language
\$default_template = "\Q$default_template\E";		# Default Forum Template

\$mailprog = "\Q$mailprog\E";				# Location of your sendmail program
\$smtp_server = "\Q$smtp_server\E";			# Address of your SMTP-Server (for Net::SMTP::TLS, specify the port number with a ":<portnumber>" at the end)
\$smtp_auth_required = $smtp_auth_required;		# Set to 1 if the SMTP server requires Authorisation
\$authuser = "\Q$authuser\E";				# Username for SMTP authorisation
\$authpass = "\Q$authpass\E";				# Password for SMTP authorisation
\$webmaster_email = "\Q$webmaster_email\E";		# Your email address. (eg: \$webmaster_email = q^admin\@host.com^;)
\$mailtype = $mailtype;					# Mail program to use: 0 = sendmail, 1 = SMTP, 2 = Net::SMTP, 3 = Net::SMTP::TLS

\$UseHelp_Perms = $UseHelp_Perms;			# Help Center: 1 == use permissions, 0 == don't use permissions

########## MemberGroups ##########

$member_groups
\@nopostorder = qw(@nopostorder);			# Order how "Post independent Member Groups" are displayed

########## Database ###########

\$use_MySQL = $use_MySQL;				# Set to 1 if you are on MySQL-DB, set to 0 if you are on the default file-DB structure
$use_MySQL_comment use DBI;				# Add DBI only if needed, comment out otherwise!

\$db_server = "$db_server";				# Name of the SQL-server
\$db_port = "$db_port";					# Port of the SQL-server
\$db_socket = "$db_socket";				# Socket of the SQL-server
\$db = "$db";						# Name of the database
\$db_username = "$db_username";				# Unsername of the database
\$db_password = "$db_password";				# Password of the user of the database
\$db_prefix = "$db_prefix";				# Prefix for YaBB tables inside the database

\$db_user_vars_table = "$db_user_vars_table";		# Name of the table with user 'vars' informations
\%db_user_vars_col = ($db_user_vars_col);		# Name (key) of the colums in the above table with user 'vars' (value) informations
\$db_user_vars_key = "$db_user_vars_key";		# DB-Key of the table with user 'vars' informations
\%db_vars_col = ($db_vars_col);				# Name (key) of the rest 'vars' colums in the YaBB table
\$db_vars_order = "$db_vars_order";			# Right order of the colums for a fetch of all 'vars'
\@db_vars_tabs_order = ($db_vars_tabs_order);		# variables tabs order coreponding to $db_vars_order
\$db_vars_laston_table = "$db_vars_laston_table";	# 'lastonline' table
\$db_vars_laston = "$db_vars_laston";			# 'lastonline' colum namen

\$db_user_log_table = "$db_user_log_table";		# Name of the table with user 'log' informations
\$db_user_log_col = "$db_user_log_col";			# Name of the colums in the above table with user 'log' informations
\$db_user_log_key = "$db_user_log_key";			# DB-Key of the table with user 'log' informations
\@db_user_log_array_order = qw(@db_user_log_array_order);	# number of the variable in the @log_array for the user_log
\$db_log_col = "$db_log_col";				# Name of the colums in the 'log' table with user 'log' informations
\$db_log_order = "$db_log_order";			# Right order of the colums for a fetch of all 'log'
\$db_log_date = "$db_log_date";				# `date` colum of the 'log' table
\@db_log_array_order = qw(@db_log_array_order);		# number of the variable in the @log_array in the 'log'

########## Layout ##########

\$MenuType = $MenuType;					# 1 for text menu or anything else for images menu
\$profilebutton = $profilebutton;			# 1 to show view profile button under post, or 0 for blank
\$threadtools = $threadtools;				# Enable dropdown for post actions
\$posttools = $posttools;				# Enable dropdown for post actions
\$userinfostyle = $userinfostyle;				# 1 for old user info on left, 0 for new user info above posts
\$usertools = $usertools;				# Allow admin to hide the list of tools that show when clicking a userlink
\$allow_hide_email = $allow_hide_email;			# Allow users to hide their email from public. Set 0 to disable
\$user_hide_avatars = $user_hide_avatars;		# Allow users to hide Avatars in threads. Set 0 to disable
\$user_hide_user_text = $user_hide_user_text;		# Allow users to hide User Text in threads. Set 0 to disable
\$user_hide_attach_img = $user_hide_attach_img;		# Allow users to hide Attached Images in threads. Set 0 to disable
\$user_hide_signat = $user_hide_signat;			# Allow users to hide User Signatures in threads. Set 0 to disable
\$user_hide_smilies_row = $user_hide_smilies_row;	# Allow users to hide Smilies row below the Post Message-inputarea. Set 0 to disable
\$buddyListEnabled = $buddyListEnabled;			# Enable Buddy List
\$addmemgroup_enabled = $addmemgroup_enabled;		# Enable Users choose additional MemberGroups
\$showlatestmember = $showlatestmember;			# Set to 1 to display "Welcome Newest Member" on the Board Index
\$shownewsfader = $shownewsfader;			# 1 to allow or 0 to disallow NewsFader javascript
\$Show_RecentBar = $Show_RecentBar;			# Set to 1 to display the Recent Post on Board Index
\$showmodify = $showmodify;				# Set to 1 to display "Last modified: Realname - Date" under each message
\$ShowBDescrip = $ShowBDescrip;				# Set to 1 to display board descriptions on the topic (message) index for each board
\$showuserpic = $showuserpic;				# Set to 1 to display each member's picture in the message view (by the ICQ.. etc.)
\$showusertext = $showusertext;				# Set to 1 to display each member's personal text in the message view (by the ICQ.. etc.)
\$showtopicviewers = $showtopicviewers;			# Set to 1 to display members viewing/replying a topic for staff
							# Set to 2 for all members; 3 for all; 0 for none
\$showgenderimage = $showgenderimage;			# Set to 1 to display each member's gender in the message view (by the ICQ.. etc.)
\$hide_signat_for_guests = $hide_signat_for_guests;	# Set to 1 to hide all signatures for Guests (only Members can see them).
\$showyabbcbutt = $showyabbcbutt;			# Set to 1 to display the yabbc buttons on Posting and IM Send Pages
\$nestedquotes = $nestedquotes;				# Set to 1 to allow quotes within quotes (0 will filter out quotes within a quoted message)
\$parseflash = $parseflash;				# Set to 1 to parse the flash tag
\$enableclicklog = $enableclicklog;			# Set to 1 to track stats in Clicklog (this may slow your board down)
\$showimageinquote = $showimageinquote;			# Set to 1 to shows images in quotes, 0 displays a link to the image

\@pallist = ($pallist);					# color settings of the palette

########## Feature Settings ##########

\$enable_spell_check = $enable_spell_check;		# Set to 1 if you want to enable SpellChecker. By doing this you agree to the terms of license under that googiespell runs. See: http://orangoo.com/labs/GoogieSpell/License/ and /yabbfiles/googiespell/GPL.txt
\$enable_ubbc = $enable_ubbc;				# Set to 1 if you want to enable UBBC (Uniform Bulletin Board Code)
\$enable_news = $enable_news;				# Set to 1 to turn news on, or 0 to set news off
\$allowpics = $allowpics;				# set to 1 to allow members to choose avatars in their profile
\$upload_useravatar = $upload_useravatar;		# set to 1 to allow members to upload avatars for their profile
\$upload_avatargroup = "\Q$upload_avatargroup\E";	# membergroups allowed to upload avatars for their profile, '' == all members
\$avatar_limit = $avatar_limit;				# set to the maximum size of the uploaded avatar, 0 == no limit
\$avatar_dirlimit = $avatar_dirlimit;			# set to the maximum size of the upload avatar directory, 0 == no limit

\$enable_guestposting = $enable_guestposting;		# Set to 0 if do not allow 1 is allow.
\$guest_media_disallowed = $guest_media_disallowed;	# disallow browsing guests to see media files or have clickable auto linked urls in messages.
\$enable_guestlanguage = $enable_guestlanguage;		# allow browsing guests to select their language - requires more than one language pack! - Set to 0 if do not allow 1 is allow.

\$enable_notifications = $enable_notifications;		# - Allow e-mail notification for boards/threads listed in "My Notifications" => value == 1
							# - Allow e-mail notification when new PM comes in => value == 2
							# - value == 0 => both disabled | value == 3 => both enabled

\$NewNotificationAlert = $NewNotificationAlert;		# enable notification alerts (popup) for new notifications
\$autolinkurls = $autolinkurls;				# Set to 1 to turn URLs into links, or 0 for no auto-linking.

\$forumnumberformat = $forumnumberformat;		# Select your preferred output Format for Numbers
\$timeselected = $timeselected;				# Select your preferred output Format of Time and Date
\$timecorrection = $timecorrection;			# Set time correction for server time in seconds
\$timeoffset = "\Q$timeoffset\E";				# Time Offset to GMT/UTC (0 for GMT/UTC)
\$dstoffset = $dstoffset;				# Time Offset (for daylight savings time, 0 to disable DST)
\$dynamic_clock = $dynamic_clock;			# Set to a value enables the dynamic clock at the top of the page
\$TopAmmount = $TopAmmount;				# No. of top posters to display on the top members list
\$maxdisplay = $maxdisplay;				# Maximum of topics to display
\$maxfavs = $maxfavs;					# Maximum of favorite topics to save in a profile
\$maxrecentdisplay = $maxrecentdisplay;			# Maximum of topics to display on recent posts by a user (-1 to disable)
\$maxsearchdisplay = $maxsearchdisplay;			# Maximum of messages to display in a search query (-1 to disable search)
\$maxmessagedisplay = $maxmessagedisplay;		# Maximum of messages to display
\$showpageall = $showpageall;				# Disable or Enable show All on page selectors
\$checkallcaps = $checkallcaps;				# Set to 0 to allow ALL CAPS in posts (subject and message) or set to a value > 0 to open a JS-alert if more characters in ALL CAPS were there.
\$set_subjectMaxLength = $set_subjectMaxLength;		# Maximum Allowed Characters in a Posts Subject
\$MaxMessLen = $MaxMessLen;				# Maximum Allowed Characters in a Posts
\$speedpostdetection = $speedpostdetection;		# Set to 1 to detect speedposters and delay their spam actions
\$spd_detention_time = $spd_detention_time;		# Time in seconds before a speedposting ban is lifted again
\$min_post_speed = $min_post_speed;			# Minimum time in seconds between entering a post form and submitting a post
\$minlinkpost = $minlinkpost;				# Minimum amount of posts a member needs to post links and images
\$minlinksig = $minlinksig;				# Minimum amount of posts a member needs to create links and images in signature
\$post_speed_count = $post_speed_count;			# Maximum amount of abuses befor a user gets banned
\$fontsizemin = $fontsizemin;				# Minimum Allowed Font height in pixels
\$fontsizemax = $fontsizemax;				# Maximum Allowed Font height in pixels
\$MaxSigLen = $MaxSigLen;				# Maximum Allowed Characters in Signatures
\$ClickLogTime = $ClickLogTime;				# Time in minutes to log every click to your forum (longer time means larger log file size)
\$max_log_days_old = $max_log_days_old;			# If an entry in the user's log is older than ... days remove it

\$maxsteps = $maxsteps;					# Number of steps to take to change from start color to endcolor
\$stepdelay = $stepdelay;				# Time in miliseconds of a single step
\$fadelinks = $fadelinks;				# Fade links as well as text?

\$defaultusertxt = "\Q$defaultusertxt\E";		# The dafault usertext visible in users posts
\$timeout = $timeout;					# Minimum time between 2 postings from the same IP
\$HotTopic = $HotTopic;					# Number of posts needed in a topic for it to be classed as "Hot"
\$VeryHotTopic = $VeryHotTopic;				# Number of posts needed in a topic for it to be classed as "Very Hot"

\$barmaxdepend = $barmaxdepend;				# Set to 1 to let bar-max-length depend on top poster or 0 to depend on a number of your choise
\$barmaxnumb = $barmaxnumb;				# Select number of post for max. bar-length in memberlist
\$defaultml = "\Q$defaultml\E";

\$ML_Allowed = $ML_Allowed;				# allow browse MemberList

########## Quick Reply configuration ##########

\$enable_quickpost = $enable_quickpost;			# Set to 1 if you want to enable the quick post box
\$enable_quickreply = $enable_quickreply;		# Set to 1 if you want to enable the quick reply box
\$enable_quickjump = $enable_quickjump;			# Set to 1 if you want to enable the jump to quick reply box
\$enable_markquote = $enable_markquote;			# Set to 1 if you want to enable the mark&quote feature
\$quick_quotelength = $quick_quotelength;		# Set the max length for Quick Quotes
\$enable_quoteuser = $enable_quoteuser;			# Set to 1 if you want to enable userquote
\$quoteuser_color = "\Q$quoteuser_color\E";		# Set the default color of @ in userquote

########## Post Popup configuration ##########

\$display_postpopup = $display_postpopup;		# Set to 1 if you want to enable the post popup on the display page
\$mindex_postpopup = $mindex_postpopup;			# Set to 1 if you want to enable the post popup on the message index page
\$mdrop_postpopup = $mdrop_postpopup;			# Set to 1 if you want to enable the post popup on the message drop downs

########## MemberPic Settings ##########

\$max_avatar_width = $max_avatar_width;			# Set maximum pixel width to which the selfselected userpics are resized, 0 disables this limit
\$max_avatar_height = $max_avatar_height;		# Set maximum pixel height to which the selfselected userpics are resized, 0 disables this limit
\$fix_avatar_img_size = $fix_avatar_img_size;		# Set to 1 disable the image resize feature and sets the image size to the max_... values. If one of the max_... values is 0 the image is shown in his proportions to the other value. If both are 0 the image is shown at his original size.
\$max_post_img_width = $max_post_img_width;		# Set maximum pixel width for images, 0 disables this limit
\$max_post_img_height = $max_post_img_height;		# Set maximum pixel height for images, 0 disables this limit
\$fix_post_img_size = $fix_post_img_size;		# Set to 1 disable the image resize feature and sets the image size to the max_... values. If one of the max_... values is 0 the image is shown in his proportions to the other value. If both are 0 the image is shown at his original size.
\$max_signat_img_width = $max_signat_img_width;		# Set maximum pixel width for images in the signature, 0 disables this limit
\$max_signat_img_height = $max_signat_img_height;	# Set maximum pixel height for images in the signature, 0 disables this limit
\$fix_signat_img_size = $fix_signat_img_size;		# Set to 1 disable the image resize feature and sets the image size to the max_... values. If one of the max_... values is 0 the image is shown in his proportions to the other value. If both are 0 the image is shown at his original size.
\$max_attach_img_width = $max_attach_img_width;		# Set maximum pixel width for attached images, 0 disables this limit
\$max_attach_img_height = $max_attach_img_height;	# Set maximum pixel height for attached images, 0 disables this limit
\$fix_attach_img_size = $fix_attach_img_size;		# Set to 1 disable the image resize feature and sets the image size to the max_... values. If one of the max_... values is 0 the image is shown in his proportions to the other value. If both are 0 the image is shown at his original size.
\$img_greybox = $img_greybox;				# Set to 0 to disable "greybox" (each image is shown in a new window)
							# Set to 1 to enable the attachment and post image "greybox" (one image/page)
							# Set to 2 to enable the attachment and post image "greybox" => attachmet images: (all images/page), post images: (one image/page)

########## Extended Profiles ##########

\$extendedprofiles = $extendedprofiles;			# Set to 1 to enabled 'Extended Profiles'. Turn it off (0) to save server load.
\@ext_prof_order = ($ext_prof_order);			# Order of the extended profile fields.
\@ext_prof_fields = (
$ext_prof_fields
);							# Settings of the extendes profiles fields.

########## File Settings ##########

\$enable_quota = $enable_quota;				# Set to 1 to enable free HOST size check with command 'quota' on every pageview
\$hostusername = "\Q$hostusername\E";			# Username on the above host HDD
\$findfile_time = $findfile_time;			# Used HOST size check with 'find' every ... minutes
\$findfile_root = "\Q$findfile_root\E";			# Used HOST size check with 'find' in this folder -r
\$findfile_maxsize = $findfile_maxsize;			# Maximum size in KB the above folder is allowed to store
\$findfile_space = "\Q$findfile_space\E";		# dynamically inserted available space on the user account and timestamp of the last check
\$enable_freespace_check = $enable_freespace_check;	# Set to 1 to enable the free DISK space check on every pageview

\$gzcomp = $gzcomp;					# GZip compression: 0 = No Compression, 1 = External gzip, 2 = Zlib::Compress
\$gzforce = $gzforce;					# Don't try to check whether browser supports GZip
\$cachebehaviour = $cachebehaviour;			# Browser Cache Control: 0 = No Cache must revalidate, 1 = Allow Caching
\$use_flock = $use_flock;				# Set to 0 if your server doesn't support file locking, 1 for Unix/Linux and WinNT, 2 for Windows 95/98/ME and 3 for NFSLock (Unix based only)

\$faketruncation = $faketruncation;			# Enable this option only if YaBB fails with the error:
							# "truncate() function not supported on this platform."
							# 0 to disable, 1 to enable.

\$debug = $debug;					# If set to 1 debug info is added to the template. Tag in template is {yabb debug}



###############################################################################
# Advanced Settings (old AdvSettings.txt)                                     #
###############################################################################

########## RSS Settings ##########

\$rss_disabled = $rss_disabled;				# Set to 1 to disable the RSS feed
\$rss_limit = $rss_limit;				# Maximum number of topics in the feed
\$rss_message = $rss_message;				# Message to display in the feed
							# 0: None
							# 1: Latest Post
							# 2: Original Post in the topic
\$showauthor = $showauthor;				# Show author name
\$showdate = $showdate;					# Show post date

########## New Member Notification Settings ##########

\$new_member_notification = $new_member_notification;			# Set to 1 to enable the new member notification
\$new_member_notification_mail = "\Q$new_member_notification_mail\E";	# Your "New Member Notification"-email address.

\$sendtopicmail = $sendtopicmail;			# Set to 0 for send NO topic email to friend
							# Set to 1 to send topic email to friend via YaBB
							# Set to 2 to send topic email to friend via user program
							# Set to 3 to let user decide between 1 and 2

########## In-Thread Multi Delete ##########

\$mdadmin = $mdadmin;
\$mdglobal = $mdglobal;
\$mdmod = $mdmod;
\$adminbin = $adminbin;					# Skip recycle bin step for admins and delete directly

########## Moderation Update ##########

\$adminview = $adminview;				# Multi-admin settings for Administrators: 0=none, 1=icons 2=single checkbox 3=multiple checkboxes
\$gmodview = $gmodview;					# Multi-admin settings for Global Moderators: 0=none, 1=icons 2=single checkbox 3=multiple checkboxes
\$modview = $modview;					# Multi-admin settings for Moderators: 0=none, 1=icons 2=single checkbox 3=multiple checkboxes

########## Advanced Memberview Plus ##########

\$showallgroups = $showallgroups;
\$OnlineLogTime = $OnlineLogTime;			# Time in minutes before Users are removed from the Online Log
\$lastonlineinlink = $lastonlineinlink;			# Show "Last online X days and XX:XX:XX hours ago." to all members == 1

########## Polls ##########

\$numpolloptions = $numpolloptions;			# Number of poll options
\$maxpq = $maxpq;					# Maximum Allowed Characters in a Poll Qestion?
\$maxpo = $maxpo;					# Maximum Allowed Characters in a Poll Option?
\$maxpc = $maxpc;					# Maximum Allowed Characters in a Poll Comment?
\$useraddpoll = $useraddpoll;				# Allow users to add polls to existing threads? (1 = yes)
\$ubbcpolls = $ubbcpolls;				# Allow UBBC tags and smilies in polls? (1 = yes)

########## My Center and Private Messaging Features ##########

\$PM_level = $PM_level;					# minimum user level for private messaging: 0 = off, 1 = members, 2 = mods, 3 = gmod
\$PMenableGuestButton = $PMenableGuestButton;		# enable 'pm to admin' for guests? 1=yes, 0=no. Appears on the general menu instead of 'my center'
\$PMenableAlertButton = $PMenableAlertButton;		# enable 'alert moderator' button on thread view? 1=yes 0=no. Acts as a broadcast message to mods etc.
\$PMAlertButtonGuests = $PMAlertButtonGuests;		# enable 'alert moderator' button for Guests
\$enable_PMsearch = $enable_PMsearch;			#enable/max returns for PM search - 0 = off / 10 - 50 range for results

\$send_welcomeim = $send_welcomeim;			# enable auto-welcome message from forum to new member. 1=yes, 0=no
\$sendname = "\Q$sendname\E";				# username 'from' for welcome message. Defaults to fa.
\$imsubject = "\Q$imsubject\E";				# title of welcome message.
\$imtext = "\Q$imtext\E";				# message sent to new member

\$numposts = $numposts;					# Number of posts required to send Instant Messages
\$imspam = $imspam;					# Percent of Users a user is a allowed to send a message at once

\$enable_imlimit = $enable_imlimit;			# Set to 1 to enable limitation of incoming and outgoing im messages
\$numibox = $numibox;					# Number of maximum Messages in the IM-Inbox
\$numobox = $numobox;					# Number of maximum Messages in the IM-Outbox
\$numstore = $numstore;					# Number of maximum Messages in the Storage box
\$numdraft = $numdraft;					# Number of maximum Messages in the draft box

\$PMenable_cc = $PMenable_cc;				# enable cc for PM posting 1 yes, 0 no
\$PMenable_bcc = $PMenable_bcc;				# enable bcc for PM posting 1 yes, 0 no
\$PMenableBm_level = $PMenableBm_level;			# minimum level to send? 0 = off, 1 = mods, 2 = gmod, 3 = admin

\$enable_storefolders = $enable_storefolders;		# enable additonal store folders - in/out are default for all
							# 0=no > 1 = number, max 25

\$enable_YaBBBut = $enable_YaBBBut;			# enable YABBC Buttons on post page? 1=yes, 0=no
\$enable_PMcontrols = $enable_PMcontrols;		# enable extended controls for members? 1=yes, 0=no. If off, use the following instead
\$enable_PMprev = $enable_PMprev;			# enable preview button
\$enable_PMActprev = $enable_PMActprev;			# enable active preview
\$enable_PMviewMess = $enable_PMviewMess;		# enable message body suppress in list view

\$enable_PMautoAway = $enable_PMautoAway;		# enable PM 'away' auto reply for inbox.
\$enable_MCaway = $enable_MCaway;			# enable 'away' indicator 0=Off 1=Staff to Staff 2=Staff to all 3=Members
\$MaxAwayLen = $MaxAwayLen; 				# maximum allowed characters in Away message
\$enable_MCstatusStealth = $enable_MCstatusStealth;	# enable 'stealth' mode for fa/gmods. Allows status label to stay at offline/away for all members viewing.

########## Topic Summary Cutter ##########

\$cutamount = $cutamount;				# Number of posts to list in topic summary
\$tsreverse = $tsreverse;				# Reverse Topic Summaries in Topic Reply (most recent becomes first)
\$ttsreverse = $ttsreverse;				# Reverse Topic Summaries in Topic (most recent becomes first)
\$ttsureverse = $ttsureverse;				# Reverse Topic Summaries in Topic (most recent becomes first) allowed as user wishes? Yes == 1

########## Time Lock ##########

\$tlnomodflag = $tlnomodflag;				# Set to 1 limit time users may modify posts
\$tlnomodtime = $tlnomodtime;				# Time limit on modifying posts (days)
\$tlnodelflag = $tlnodelflag;				# Set to 1 limit time users may delete posts
\$tlnodeltime = $tlnodeltime;				# Time limit on deleting posts (days)
\$tllastmodflag = $tllastmodflag;			# Set to 1 allow users to modify posts up to the specified time limit w/o showing "last Edit" message
\$tllastmodtime = $tllastmodtime;			# Time limit to modify posts w/o triggering "last Edit" message (in minutes)

########## Permalinks ##########

\$accept_permalink = $accept_permalink;			# Set to 1 to have the board accept permalink alike environment strings
\$symlink = "\Q$symlink\E";				# The part defined in .htaccess redirection rules that is between domainname and permalink
\$perm_spacer = "\Q$perm_spacer\E";			# The character used in the permalink output file that replaces the space.
\$perm_domain = "\Q$perm_domain\E";			# The full domainname (no http://) where the .haccess redirect is set on.

########## bypass post for locked thread ##########

\$bypass_lock_perm = "\Q$bypass_lock_perm\E";		# set level of permission - fa / fa+gmod / fa+gmod+mod; '' if disabled

########## File Attachment Settings ##########

\$limit = $limit;					# Set to the maximum number of kilobytes an attachment can be. Set to 0 to disable the file size check.
\$dirlimit = $dirlimit;					# Set to the maximum number of kilobytes the attachment directory can hold. Set to 0 to disable the directory size check.
\$overwrite = $overwrite;				# Set to 0 to auto rename attachments if they exist, 1 to overwrite them or 2 to generate an error if the file exists already.
\@ext = qw(@ext);					# The allowed file extensions for file attachements. Variable should be set in the form of "jpg bmp gif" and so on.
\$checkext = $checkext;					# Set to 1 to enable file extension checking, set to 0 to allow all file types to be uploaded
\$amdisplaypics = $amdisplaypics;			# Set to 1 to display attached pictures in posts, set to 0 to only show a link to them.
\$allowattach = $allowattach;				# Set to the number of maximum files attaching a post, set to 0 to disable file attaching.
\$allowguestattach = $allowguestattach;			# Set to 1 to allow guests to upload attachments, 0 to disable guest attachment uploading.

########## Error Logger ##########

\$elmax = $elmax;					# Max number of log entries before rotation
\$elenable = $elenable;					# allow for error logging
\$elrotate = $elrotate;					# Allow for log rotation

########## Advanced Tabs ##########

\@AdvancedTabs = ($AdvancedTabs);			# Advanced Tabs order and infos

########## Smilies ##########

\@SmilieURL = ($SmilieURL);				# Additional Smilies URL
\@SmilieCode = ($SmilieCode);				# Additional Smilies Code
\@SmilieDescription = ($SmilieDescription);		# Additional Smilies Description
\@SmilieLinebreak = ($SmilieLinebreak);			# Additional Smilies Linebreak

\$smiliestyle = "$smiliestyle";				# smiliestyle
\$showadded = "$showadded";				# showadded
\$showsmdir = "$showsmdir";				# showsmdir
\$detachblock = "$detachblock";				# detachblock
\$winwidth = "$winwidth";				# winwidth
\$winheight = "$winheight";				# winheight
\$popback = "$popback";					# popback
\$poptext = "$poptext";					# poptext
\$showinbox = "$showinbox";				# showinbox
\$removenormalsmilies = "$removenormalsmilies";		# removenormalsmilies



###############################################################################
# Security Settings (old SecSettings.txt)                                     #
###############################################################################

\$regcheck = $regcheck;					# Set to 1 if you want to enable automatic flood protection enabled
\$gpvalid_en = $gpvalid_en;				# Set to 1 if you want to enable validation code on guest posting
\$codemaxchars = $codemaxchars;				# Set max length of validation code (15 is max)
\$captchastyle = "\Q$captchastyle\E";			# Set L = lowercase only, U = uppercase only, A = both upper and lowercase letters
\$rgb_foreground = "\Q$rgb_foreground\E";		# Set hex RGB value for validation image foreground color
\$rgb_shade = "\Q$rgb_shade\E";				# Set hex RGB value for validation image shade color
\$rgb_background = "\Q$rgb_background\E";		# Set hex RGB value for validation image background color
\$translayer = $translayer;				# Set to 1 background for validation image should be transparent
\$randomizer = $randomizer;				# Set 0 to 3 to create background random noise based on foreground or shade color or both
\$distortion = $distortion;				# Set 1 to distort the captcha image even more
\$stealthurl = $stealthurl;				# Set to 1 to mask referer url to hosts if a hyperlink is clicked.
\$do_scramble_id = $do_scramble_id;			# Set to 1 scambles all visible links containing user ID's
\$referersecurity = $referersecurity;			# Set to 1 to activate referer security checking.
\$sessions = $sessions;					# Set to 1 to activate session id protection.
\$show_online_ip_admin = $show_online_ip_admin;		# Set to 1 to show online IP's to admins.
\$show_online_ip_gmod = $show_online_ip_gmod;		# Set to 1 to show online IP's to global moderators.
\$masterkey = "\Q$masterkey\E";				# Seed for encryption of captcha's



###############################################################################
# Guardian Settings (old Guardian.banned and Guardian.settings)               #
###############################################################################

\$banned_harvesters = qq~$banned_harvesters~;
\$banned_referers = qq~$banned_referers~;
\$banned_requests = qq~$banned_requests~;
\$banned_strings = qq~$banned_strings~;
\$whitelist = qq~$whitelist~;

\$use_guardian = $use_guardian;
\$use_htaccess = $use_htaccess;

\$disallow_proxy_on = $disallow_proxy_on;
\$referer_on = $referer_on;
\$harvester_on = $harvester_on;
\$request_on = $request_on;
\$string_on = $string_on;
\$union_on = $union_on;
\$clike_on = $clike_on;
\$script_on = $script_on;

\$disallow_proxy_htaccess = $disallow_proxy_htaccess;
\$referer_htaccess = $referer_htaccess;
\$harvester_htaccess = $harvester_htaccess;
\$request_htaccess = $request_htaccess;
\$string_htaccess = $string_htaccess;
\$union_htaccess = $union_htaccess;
\$clike_htaccess = $clike_htaccess;
\$script_htaccess = $script_htaccess;

\$disallow_proxy_notify = $disallow_proxy_notify;
\$referer_notify = $referer_notify;
\$harvester_notify = $harvester_notify;
\$request_notify = $request_notify; 
\$string_notify = $string_notify;
\$union_notify = $union_notify;
\$clike_notify = $clike_notify;
\$script_notify = $script_notify;



###############################################################################
# Banning Settings (old ban.txt)                                              #
###############################################################################

\$ip_banlist = "\Q$ip_banlist\E";			# IP banlist
\$email_banlist = "\Q$email_banlist\E";			# EMAIL banlist
\$user_banlist = "\Q$user_banlist\E";			# USER banlist



###############################################################################
# Backup Settings (old BackupSettings.cgi)                                    #
###############################################################################

\@backup_paths = qw($backup_paths);
\$backupmethod = '$backupmethod';
\$compressmethod = '$compressmethod';
\$backupdir = '$backupdir';
\$lastbackup = $lastbackup;
\$backupsettingsloaded = $backupsettingsloaded;



###############################################################################
# CalEventSet.txt                                                             #
###############################################################################

# Standard Calendar Setting
\$Show_EventCal = $Show_EventCal;
\$Show_EventButton = $Show_EventButton;
\$Show_EventBirthdays = $Show_EventBirthdays;
\$Show_MiniCalIcons = $Show_MiniCalIcons;
\$ShowSunday = $ShowSunday;
\$Show_ColorLinks = $Show_ColorLinks;
\$No_ShortUbbc = $No_ShortUbbc;
\$Event_TodayColor = "$Event_TodayColor";
\$Delete_EventsUntil = $Delete_EventsUntil;
\$CalShortEvent = $CalShortEvent;
\$CalEventPerms = qq~$CalEventPerms~;
\$CalEventMods = qq~$CalEventMods~;
\$CalEventPrivate = $CalEventPrivate;
\$CalEventNoName = $CalEventNoName;
\$Scroll_Events = $Scroll_Events;
\$DisplayCalEvents = $DisplayCalEvents;
\$DisplayEvents = $DisplayEvents;

# Birthdaylist Setting
\$Show_BirthdaysList = $Show_BirthdaysList;
\$Show_BirthdayButton = $Show_BirthdayButton;
\$Show_BirthdayDate = $Show_BirthdayDate;
\$Show_BdColorLinks = $Show_BdColorLinks;

1;
EOF

	} else {
		# This should only be seen by developers.
		# If you get this, then you've typoed $file
		# or tried to write to one that isn't implemented here.
		die "I don't know how to write to this file.";
	}

	WriteSettingsTo("$vardir/$file", $setfile);

	if ($settings_file_version ne $YaBBversion) { # START upgrade codes
		# The following is for upgrades from YaBB versions < 2.5 START
		&delete_DBorFILE("$memberdir/members.ttl") if -e "$memberdir/members.ttl";
		&delete_DBorFILE("$memberdir/memberlist.txt") if -e "$memberdir/memberlist.txt";
		rename("$datadir/showcase.poll","$datadir/poll.showcase");
		&delete_DBorFILE("$vardir/CalEventSet.txt") if -e "$vardir/CalEventSet.txt";
		# The following is for upgrades from YaBB versions < 2.5 END

		# The following is for upgrades from YaBB versions < 2.4 START
		&delete_DBorFILE("$vardir/nopostorder.txt") if -e "$vardir/nopostorder.txt";
		&delete_DBorFILE("$vardir/advsettings.txt") if -e "$vardir/advsettings.txt";
		&delete_DBorFILE("$vardir/secsettings.txt") if -e "$vardir/secsettings.txt";
		&delete_DBorFILE("$vardir/membergroups.txt") if -e "$vardir/membergroups.txt";
		&delete_DBorFILE("$vardir/Smilies.txt") if -e "$vardir/Smilies.txt";
		&delete_DBorFILE("$vardir/template.cfg") if -e "$vardir/template.cfg";
		&delete_DBorFILE("$vardir/Guardian.banned") if -e "$vardir/Guardian.banned";
		&delete_DBorFILE("$vardir/Guardian.settings") if -e "$vardir/Guardian.settings";
		&delete_DBorFILE("$vardir/ban.txt") if -e "$vardir/ban.txt";
		&delete_DBorFILE("$vardir/ban_email.txt") if -e "$vardir/ban_email.txt";
		&delete_DBorFILE("$vardir/ban_memname.txt") if -e "$vardir/ban_memname.txt";
		&delete_DBorFILE("$vardir/HelpSettings.txt") if -e "$vardir/HelpSettings.txt";
		&delete_DBorFILE("$vardir/BackupSettings.cgi") if -e "$vardir/BackupSettings.cgi";
		&delete_DBorFILE("$vardir/extended_profiles_order.txt") if -e "$vardir/extended_profiles_order.txt";
		&delete_DBorFILE("$vardir/extended_profiles_fields.txt") if -e "$vardir/extended_profiles_fields.txt";
		&delete_DBorFILE("$vardir/palette.def") if -e "$vardir/palette.def";
		&delete_DBorFILE("$vardir/taborder.txt") if -e "$vardir/taborder.txt";
		&delete_DBorFILE("$vardir/tabs_ext.def") if -e "$vardir/tabs_ext.def";
		# The following is for upgrades from YaBB versions < 2.4 END

		# The following is for upgrades from YaBB versions < 2.3 START
		&delete_DBorFILE("$vardir/upgrade_secsettings.txt") if -e "$vardir/upgrade_secsettings.txt";
		&delete_DBorFILE("$vardir/upgrade_advsettings.txt") if -e "$vardir/upgrade_advsettings.txt";
		&delete_DBorFILE("$vardir/upgrade_Settings.pl") if -e "$vardir/upgrade_Settings.pl";
		# The following is for upgrades from YaBB versions < 2.3 END
	} # END upgrade codes
}

# Subroutine for writing the common format of settings file
sub WriteSettingsTo {
	my ($file, $setfile) = @_;

	# Fix a certain type of syntax error
	$setfile =~ s~=\s+;~= 0;~g;

	# Make it look nicely aligned. The comment starts after 50 Col
	my $filler = ' ' x 50;
	$setfile =~ s~(.+;)[ \t]+(#.+$)~ $1 . substr($filler,(length $1 < 50 ? length $1 : 49)) . $2 ~gem;
	$setfile =~ s~\t+(#.+$)~$filler$1~gm;
	$setfile =~ s~(.+)(#.+$)~ $1 . &cut_comment($1,$2) ~gem;

	sub cut_comment { # line brake of too long comments
		my ($comment,$length) = ('',120); # 120 Col is the max width of page
		my $var_length = length($_[0]);
		while ($length < $var_length) { $length += 120; }
		foreach (split(/ +/, $_[1])) {
			if (($var_length + length($comment) + length($_)) > $length) {
				$comment =~ s/ $//;
				$comment .= "\n$filler#  $_ ";
				$length += 120;
			} else { $comment .= "$_ "; }
		}
		$comment =~ s/ $//;
		$comment; 
	}

	# Write it out
	if ($file =~ /^(.+)\/(.+?)\.(.+?)$/) {
		# extract path, filename and extension
		&write_DBorFILE(0,'',$1,$2,$3,($setfile));
	} else {
		# fallback in case of malformed destination filename
		fopen(SETTINGS, ">$file") || &fatal_error('cannot_open', $file, 1);
		print SETTINGS $setfile;
		fclose(SETTINGS);
	}
}

1;