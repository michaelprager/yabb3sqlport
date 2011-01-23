###############################################################################
# Backup.pl                                                                   #
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

# Many thanks to AK108 (http://fkp.jkcsi.com/) for his contibution to the YaBB community

$backupplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

# Add in support for Archive::Tar in the Modules directory and binaries in different places
@ENVpaths = split(/\:/, $ENV{'PATH'});

&LoadLanguage('Backup');
$yytitle = $backup_txt{1};
$action_area = 'backupsettings';

my $curtime = CORE::time; # None of that Time::HiRes stuff

my %dirs = (
	    'src' => "Admin/ $backup_txt{'and'} Sources/",
	    'bo' => "Boards/",
	    'lan' => "Languages/ $backup_txt{'and'} Help/",
	    'mem' => "Members/",
	    'mes' => "Messages/",
	    'temp' => "Templates/ $backup_txt{10}",
	    'var' => "Variables/",
	    'html' => "yabbfiles",
	    'upld' => "yabbfiles/Attachments $backup_txt{'and'} yabbfiles/avatars/UserAvatars",
	    );

&is_admin_or_gmod;

sub backupsettings {
	my ($module, $command, $tarcompress1, $tarcompress2, $allchecked, $item, %pathchecklist, %methodchecklist, $presetjavascriptcode, $file, @backups, $newcommand, $style, $disabledtext, $input);

	$yymain .= qq~<b>$backup_txt{33} $INFO{'backupspendtime'} $backup_txt{34}</b><br /><br />~ if $INFO{'backupspendtime'};
	$yymain .= qq~<font color="green"><b>$backup_txt{'mailsuccess'}</b></font><br /><br />~ if $INFO{'mailinfo'} == 1;
	$yymain .= qq~<font color="red"><b>$backup_txt{'mailfail'}</b></font><br /><br />~ if $INFO{'mailinfo'} == -1;

	if (@backup_paths == 8) { $allchecked = 'checked="checked" '; }

	# Yes, my checklists are really hashes. Oh well.
	foreach $item (@backup_paths) { $pathchecklist{$item} = 'checked="checked" '; }
	$methodchecklist{$backupmethod} = 'checked="checked" ';
	$methodchecklist{$compressmethod} = 'checked="checked" ';

	# domodulecheck if we have a checked value
	$presetjavascriptcode = qq~	domodulecheck("$backupmethod", 'init');~;

	# Javascript to make the behavior of the form buttons work better
	$yymain .= qq~
 <script type="text/javascript">
 <!--
	function checkYaBB () {
		// See if the check all box should be checked or unchecked.
		// It should be checked only if all the other boxes are checked.
		if (document.backupsettings.YaBB_bo.checked && document.backupsettings.YaBB_mes.checked && document.backupsettings.YaBB_mem.checked && document.backupsettings.YaBB_temp.checked && document.backupsettings.YaBB_lan.checked && document.backupsettings.YaBB_var.checked && document.backupsettings.YaBB_src.checked && document.backupsettings.YaBB_html.checked && document.backupsettings.YaBB_upld.checked) {
			document.backupsettings.YaBB_ALL.checked = 1;
		} else {
			document.backupsettings.YaBB_ALL.checked = 0;
		}
	}

	function masscheckYaBB (toggleboxstate) {
		if(!toggleboxstate) { // Uncheck all
			checkstate = 0;
		} else if(toggleboxstate) { // Check all
			checkstate = 1;
		}
		document.backupsettings.YaBB_bo.checked = checkstate;
		document.backupsettings.YaBB_mes.checked = checkstate;
		document.backupsettings.YaBB_mem.checked = checkstate;
		document.backupsettings.YaBB_temp.checked = checkstate;
		document.backupsettings.YaBB_lan.checked = checkstate;
		document.backupsettings.YaBB_var.checked = checkstate;
		document.backupsettings.YaBB_src.checked = checkstate;
		document.backupsettings.YaBB_html.checked = checkstate;
		document.backupsettings.YaBB_upld.checked = checkstate;
	}

	function domodulecheck (module, initstate) {
		if(module == "Archive::Tar") {
			for(i = 0; document.getElementsByName("tarmodulecompress")[i]; i++) {
				document.getElementsByName("tarmodulecompress")[i].disabled = false;
			}
			if(!initstate) {
				document.getElementsByName("tarmodulecompress")[0].checked = true;
			}
		} else {
			for(i = 0; document.getElementsByName("tarmodulecompress")[i]; i++) {
				document.getElementsByName("tarmodulecompress")[i].disabled = true;
			}
		}

		if(module == "/usr/bin/tar") {
			for(i = 0; document.getElementsByName("bintarcompress")[i]; i++) {
				document.getElementsByName("bintarcompress")[i].disabled = false;
			}
			if(!initstate) {
				document.getElementsByName("bintarcompress")[0].checked = true;
			}
		} else {
			for(i = 0; document.getElementsByName("bintarcompress")[i]; i++) {
				document.getElementsByName("bintarcompress")[i].disabled = true;
			}
		}
	}
 -->
 </script>
 <form action="$adminurl?action=backupsettings2" method="post" name="backupsettings">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg">
         <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$backup_txt{1}</b>
       </td>
     </tr>~;

	if(!$backupsettingsloaded) {
		$yymain .= qq~
     <tr valign="middle">
       <td align="left" class="catbg">
         <b>$backup_txt{2}</b>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left">
         <!-- Empty td for a spacer -->
       </td>
     </tr>~;
	}

	$yymain .= qq~
     <tr valign="middle">
       <td align="left" class="windowbg">
         $backup_txt{3}
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg">
         <b>$backup_txt{4}</b>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg">
         <input type="checkbox" name="YaBB_ALL" id="YaBB_ALL" value="1" onclick="masscheckYaBB(this.checked)" $allchecked/> <label for="YaBB_ALL">$backup_txt{5}<br />
         $backup_txt{6}</label>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
         <input type="checkbox" onclick="checkYaBB()" name="YaBB_src" id="YaBB_src" value="1" $pathchecklist{'src'}/> <label for="YaBB_src">Admin/ $backup_txt{'and'} Sources/ $backup_txt{13}</label>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
         <input type="checkbox" onclick="checkYaBB()" name="YaBB_bo" id="YaBB_bo" value="1" $pathchecklist{'bo'}/> <label for="YaBB_bo">Boards/ $backup_txt{7}</label>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
         <input type="checkbox" onclick="checkYaBB()" name="YaBB_lan" id="YaBB_lan" value="1" $pathchecklist{'lan'}/> <label for="YaBB_lan">Languages/ $backup_txt{'and'} Help/ $backup_txt{11}</label>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
         <input type="checkbox" onclick="checkYaBB()" name="YaBB_mem" id="YaBB_mem" value="1" $pathchecklist{'mem'}/> <label for="YaBB_mem">Members/ $backup_txt{9}</label>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
         <input type="checkbox" onclick="checkYaBB()" name="YaBB_mes" id="YaBB_mes" value="1" $pathchecklist{'mes'}/> <label for="YaBB_mes">Messages/ $backup_txt{8}</label>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
         <input type="checkbox" onclick="checkYaBB()" name="YaBB_temp" id="YaBB_temp" value="1" $pathchecklist{'temp'}/> <label for="YaBB_temp">Templates/ $backup_txt{10} $backup_txt{'10a'}</label>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
         <input type="checkbox" onclick="checkYaBB()" name="YaBB_var" id="YaBB_var" value="1" $pathchecklist{'var'}/> <label for="YaBB_var">Variables/ $backup_txt{12}</label>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
         <input type="checkbox" onclick="checkYaBB()" name="YaBB_html" id="YaBB_html" value="1" $pathchecklist{'html'}/> <label for="YaBB_html">yabbfiles $backup_txt{14}</label>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
         <input type="checkbox" onclick="checkYaBB()" name="YaBB_upld" id="YaBB_upld" value="1" $pathchecklist{'upld'}/> <label for="YaBB_upld">yabbfiles/Attachments $backup_txt{'and'} yabbfiles/avatars/UserAvatars $backup_txt{'14a'}</label>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg">
         <b>$backup_txt{15}</b>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg">
         $backup_txt{16}
       </td>
     </tr>~;

	# Make a list of modules that we can use with Tar::Archive
	$tarcompress1 = qq~
     <tr valign="middle">
       <td align="left" class="windowbg">
         <input type="radio" name="tarmodulecompress" id="tarmodulecompress" value="none" $methodchecklist{'none'}/> <label for="tarmodulecompress">$backup_txt{17}</label>
       </td>
     </tr>~;

	my $label_id;
	foreach $module qw(Compress::Zlib Compress::Bzip2) {
		$label_id++;
		$input = qq~name="tarmodulecompress" id="label_$label_id" value="$module" $methodchecklist{$module}~;
		eval "use $module();";
		if ($@) {
			$input = qq~disabled="disabled"~;
			$style = qq~style="font-style:italic; color:grey"~;
			$disabledtext = $backup_txt{41};
		} else {
			($style,$disabledtext) = ('','');
		}
		$tarcompress1 .= qq~
     <tr valign="middle">
       <td align="left" class="windowbg" $style>
         <input type="radio" $input/> <label for="label_$label_id">$module $backup_txt{18} $disabledtext</label>
       </td>
     </tr>~;
	}

	$tarcompress1 .= qq~
     <tr valign="middle">
       <td align="left" class="windowbg">
         &nbsp;
       </td>
     </tr>~;

	# Make a list of compression commands we can use with /usr/bin/tar
	$tarcompress2 = qq~
     <tr valign="middle">
       <td align="left" class="windowbg">
         <input type="radio" name="bintarcompress" id="bintarcompress" value="none" $methodchecklist{'none'}/> <label for="bintarcompress">$backup_txt{17}</label>
       </td>
     </tr>~;

	foreach $command qw(/bin/gzip /bin/bzip2) {
		$label_id++;
		$input = qq~name="bintarcompress" id="label_$label_id" value="$command" $methodchecklist{$command}~;
		$newcommand = &CheckPath($command);
		if (!$newcommand) {
			$input = qq~disabled="disabled"~;
			$style = qq~style="font-style:italic; color:grey"~;
			$disabledtext = $backup_txt{41};
			$newcommand = $command;
		} else {
			($style,$disabledtext) = ('','');
		}
		$tarcompress2 .= qq~
     <tr valign="middle">
       <td align="left" class="windowbg" $style>
         <input type="radio" $input/> <label for="label_$label_id">$newcommand $backup_txt{18} $disabledtext</label>
       </td>
     </tr>~;
	}

	$tarcompress2 .= qq~
     <tr valign="middle">
       <td align="left" class="windowbg">
         &nbsp;
       </td>
     </tr>~;

	# Display the commands we can use for compression
	# Non-translated here, as I doubt there are words to describe "tar" in another language
	$input = qq~name="backupmethod" id="backupmethod1" value="/usr/bin/tar" onclick="domodulecheck('/usr/bin/tar')" $methodchecklist{'/usr/bin/tar'}~;
	$newcommand = &CheckPath('/usr/bin/tar');
	if ($newcommand) {
		if (&ak_system("tar -cf $vardir/backuptest.$curtime.tar ./$yyexec.$yyext")) {
			($style,$disabledtext) = ('','');
			&delete_DBorFILE("$vardir/backuptest.$curtime.tar");
		} else {
			$input = qq~disabled="disabled"~;
			$style = qq~style="font-style:italic; color:grey"~;
			$disabledtext = ": Tar $backup_txt{31}: $!. $backup_txt{32} " . ($? >> 8);
		}
	} else {
		$input = qq~disabled="disabled"~;
		$style = qq~style="font-style:italic; color:grey"~;
		$disabledtext = $backup_txt{41};
	}
	$yymain .= qq~
     <tr valign="middle">
       <td align="left" class="windowbg2" $style>
         <input type="radio" $input/> <label for="backupmethod1">Tar ($newcommand) $disabledtext</label>
       </td>
     </tr>$tarcompress2~;

	$input = qq~name="backupmethod" id="backupmethod2" value="/usr/bin/zip" onclick="domodulecheck('/usr/bin/zip')" $methodchecklist{'/usr/bin/zip'}~;
	$newcommand = &CheckPath('/usr/bin/zip');
	if ($newcommand) {
		if (&ak_system("zip -gq $vardir/backuptest.$curtime.zip ./$yyexec.$yyext")) {
			($style,$disabledtext) = ('','');
			&delete_DBorFILE("$vardir/backuptest.$curtime.zip");
		} else {
			$input = qq~disabled="disabled"~;
			$style = qq~style="font-style:italic; color:grey"~;
			$disabledtext = ": Zip $backup_txt{31}: $!. $backup_txt{32} " . ($? >> 8);
		}
	} else {
		$input = qq~disabled="disabled"~;
		$style = qq~style="font-style:italic; color:grey"~;
		$disabledtext = $backup_txt{41};
	}
	$yymain .= qq~
     <tr valign="middle">
       <td align="left" class="windowbg2" $style>
         <input type="radio" $input/> <label for="backupmethod2">Zip ($newcommand) $disabledtext</label>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg">
         &nbsp;
       </td>
     </tr>~;

	# Display the modules that we can use
	foreach $module qw(Archive::Tar Archive::Zip) {
		$i++;
		$input = qq~name="backupmethod" id="backupmethod3_$i" value="$module" onclick="domodulecheck('$module')" $methodchecklist{$module}~;
		eval "use $module();";
		if ($@) {
			$input = qq~disabled="disabled"~;
			$style = qq~style="font-style:italic; color:grey"~;
			$disabledtext = $backup_txt{41};
		} else {
			($style,$disabledtext) = ('','');
		}
		$yymain .= qq~
     <tr valign="middle">
       <td align="left" class="windowbg2" $style>
         <input type="radio" $input/> <label for="backupmethod3_$i">$module $disabledtext</label>
       </td>
     </tr>~;
		if ($module eq 'Archive::Tar') { $yymain .= $tarcompress1; }
	}

	# Last but not least, the submit button and the $backupdir path.
	$backupdir ||= "$boarddir/Backups";
	if ($backupdir =~ s|^\./||) {
		$ENV{'SCRIPT_FILENAME'} =~ /(.*\/)/;
		$backupdir = "$1$backupdir";
	}
	$yymain .= qq~
     <tr valign="middle">
       <td align="left" class="catbg">
         <b>$backup_txt{19}</b>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
         <label for="backupdir">$backup_txt{'19a'}</label>: <input type="text" name="backupdir" id="backupdir" value="$backupdir" size="80"/>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="catbg">
         <b>$backup_txt{'19b'}</b>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">
         <label for="rememberbackup">$backup_txt{'19c'}</label> <input type="text" name="rememberbackup" id="rememberbackup" value="~ . ($rememberbackup / 86400) . qq~" size="3"/> <label for="rememberbackup">$backup_txt{'19d'}</label>
       </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg">
         <input type="submit" name="submit" value="$backup_txt{20}" class="button" />
       </td>
     </tr>
   </table>
 </div>
 </form>
 <script type="text/javascript">
 <!--
$presetjavascriptcode

	function BackupNewest(lastbackup) {
		document.getElementsByName("backupnewest")[0].value = lastbackup;
		if (!window.submitted) {
			window.submitted = true;
			document.runbackup.submit();
		}
	}
 //-->
 </script>~;

	# Here we go again with another table. Here's the backup button area
	if ($backupsettingsloaded) {
		# Look for the files.
		opendir(BACKUPDIR, $backupdir);
		@backups = readdir(BACKUPDIR);
		closedir(BACKUPDIR);
		#@backup_paths = qw(Admin_Sources Boards Languages Members Messages Templates Variables yabbfiles);

		my ($lastbackupfiletime,$filename);
		foreach $file (map { $_->[0] } sort { $b->[1] <=> $a->[1] } map { [$_, /(\d+)/, $_] } @backups) {
			if ($file !~ /\A(backup)(n?)\.(\d+)\.([^\.]+)\.(.+)/) { next; }
			$lastbackupfiletime = $3 if !$lastbackupfiletime;
			my $filesize = -s "$backupdir/$file";
			$filesize = int($filesize / 1024); # Measure it in kilobytes
			if ($filesize > 1024 * 4) { $filesize = int($filesize / 1024) . ' MB'; } # Measure it in megabytes
			else { $filesize .= ' KB'; } # Label it
			my @dirs;
			foreach (split(/_/, $4)) {
				push(@dirs, $dirs{$_});
			}

			$filename = "$1$2.$3.$4.$5";
			$filelist .= qq~          <tr><td align="left">~ . &timeformat($3) . qq~</td><td align="right">$filesize</td><td align="left">- ~ . join('<br />- ', @dirs) . qq~</td><td align="left">~ . ($2 ? "<acronym title='$backup_txt{62}'>$backup_txt{'62a'}</acronym><br />" : '') . qq~$5</td><td><a href="$adminurl?action=downloadbackup;backupid=$file">$backup_txt{60}</a></td><td><a href="$adminurl?action=emailbackup;backupid=$file">$backup_txt{52}</a></td><td><a href="$adminurl?action=runbackup;runbackup_again=$1$2.0.$4.$5">$backup_txt{61}</a><br /><a href="$adminurl?action=runbackup;runbackup_again=$filename">$backup_txt{62}</a></td><td align="center">~ . (($5 =~ /^a\.tar/|| $5 !~ /tar/) ? '-' : qq~<a href="$adminurl?action=recoverbackup1;recoverfile=$filename">$backup_txt{63}</a>~) . qq~</td><td><a href="$adminurl?action=deletebackup;backupid=$file">$backup_txt{53}</a></td></tr>\n~;
		}

		$filelist ||= qq~          <tr><td align="left" colspan="9"><i>$backup_txt{38}</i></td></tr>\n~;

		$yymain .= qq~
 <br />
 <form action="$adminurl?action=runbackup" method="post" name="runbackup">
 <input type="hidden" name="backupnewest" value="0" />
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="2">
         <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$backup_txt{21}</b>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2" colspan="2">
         $backup_txt{22} <tt>$backupdir</tt> $backup_txt{23}<br />
         <br />
         $backup_txt{24}
       </td>
     </tr>
     <tr valign="middle">
       <td align="center" class="catbg" colspan="2">
         <table width="100%"><tr><td align="center">
         <input type="button" name="submit1" value="$backup_txt{25}" onclick="BackupNewest(0);" class="button" />~;

		if ($lastbackupfiletime && $lastbackup == $lastbackupfiletime) {
			$lastbackupfiletime = &timeformat($lastbackup,1);
			$lastbackupfiletime =~ s/<.*?>//g;
			$lastbackupfiletime =~ s/ .+// if $backupmethod eq '/usr/bin/zip';
			$yymain .= qq~</td></tr><tr><td align="center">
         <input type="button" name="submit2" value="$backup_txt{'25a'} $lastbackupfiletime" onclick="BackupNewest($lastbackup);" class="button" />~;
		}

	 $yymain .= qq~
         </td></tr></table>
       </td>
     </tr>
   </table>
 </div>
 </form>

 <br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="2">
         <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$backup_txt{35}</b>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2" colspan="2">
         $backup_txt{37} <i>${$uid.$username}{'email'}</i> $backup_txt{'37a'}<br />
         $backup_txt{36} <tt>$backupdir</tt>
         <table border="1" cellspacing="1" cellpadding="4">
          <tr><td align="center">$backup_txt{70}</td><td align="center">$backup_txt{71}</td><td align="center">$backup_txt{72}</td><td align="center">$backup_txt{73}</td><td align="center" colspan="5">$backup_txt{74}</td></tr>
          $filelist
         </table>
       </td>
     </tr>
   </table>
 </div>~;
	}

	&AdminTemplate;
}

sub backupsettings2 {
	$backupmethod = $FORM{'backupmethod'};
	$compressmethod = $FORM{'bintarcompress'} || $FORM{'tarmodulecompress'} || 'none';

	# Handle the paths.
	@backup_paths = ();
	if ($FORM{'YaBB_ALL'}) { # handle the magic select all checkbox so Javascript can be disabled and it still work
		@backup_paths = qw(src bo lan mem mes temp var html upld);
	} else {
		foreach (qw(src bo lan mem mes temp var html upld)) {
			if ($FORM{'YaBB_'.$_}) { push(@backup_paths, $_); }
		}
	}

	&check_backup_settings;

	# Set $backupdir
	if (!-w $FORM{'backupdir'}) { &fatal_error("","$backup_txt{42} '$FORM{'backupdir'}'. $backup_txt{43}"); }

	$backupdir = $FORM{'backupdir'};
	$lastbackup = 0; # reset when saving settings new
	&print_BackupSettings;

	# Set $rememberbackup for alert into Settings.pl
	if ($rememberbackup != $FORM{'rememberbackup'}) {
		$rememberbackup = $FORM{'rememberbackup'};
		my @settings = &read_DBorFILE(0,'',$vardir,'Settings','pl');
		for ($i = 0; $i < @settings; $i++) {
			if ($settings[$i] =~ /\$rememberbackup = \d+;/) {
				$rememberbackup = 0 if !$rememberbackup;
				$rememberbackup *= 86400; # days in seconds
				$settings[$i] =~ s/\$rememberbackup = \d+;/\$rememberbackup = $rememberbackup;/;
			}
		}
		# if \$rememberbackup = is not allready in Settings.pl
		if ($rememberbackup && $rememberbackup == $FORM{'rememberbackup'}) {
			$rememberbackup *= 86400; # days in seconds
			unshift(@settings, "\$rememberbackup = $rememberbackup;\n");
		}
		&write_DBorFILE(0,'',$vardir,'Settings','pl',@settings);
	}

	$yySetLocation = qq~$adminurl?action=backupsettings~;
	&redirectexit;
}

sub check_backup_settings {
	if (!@backup_paths) { &fatal_error("","$backup_txt{3}"); }

	if (!$backupmethod) { &fatal_error("","$backup_txt{29} ''"); }

	if ($backupmethod =~ /::/) { # It's a module, test-require it
		eval "use $backupmethod();";
		if ($@) { &fatal_error("","$backup_txt{39} $backupmethod $backup_txt{41}"); }
	} else {
		my $newcommand = &CheckPath($backupmethod);
		if (!$newcommand) { &fatal_error("","$backup_txt{40} $backupmethod $backup_txt{41}"); }
	}

	# If we're using /usr/bin/tar, check for the compression method.
	if ($backupmethod eq '/usr/bin/tar' && $compressmethod ne 'none') {
		my $newcommand = &CheckPath($compressmethod);
		if (!$newcommand) { &fatal_error("","$backup_txt{40} $compressmethod $backup_txt{41}"); }
	}
	# If we're using Archive::Tar, check for the compression method.
	elsif ($backupmethod eq 'Archive::Tar' && $compressmethod ne 'none') {
		eval "use $compressmethod();";
		if ($@) { &fatal_error("","$backup_txt{39} $compressmethod $backup_txt{41}"); }
	} else {
		$compressmethod = 'none';
	}
}

sub print_BackupSettings {
	my @newpaths;
	foreach my $path qw(src bo lan mem mes temp var html upld) {
		foreach (@backup_paths) {
			if ($_ eq $path) { push(@newpaths, $path); last; }
		}
	}
	@backup_paths = @newpaths;
	$backupsettingsloaded = 1;

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');
}

# This routine actually does the backup.
sub runbackup {
	my($prevmainsetting, $prevmaintext, $newmaintext, %pathconvert);

	if ($INFO{'runbackup_again'}) {
		&fatal_error("","$backup_txt{32} \$INFO{'runbackup_again'}=$INFO{'runbackup_again'}") if $INFO{'runbackup_again'} !~ /^backup/;

		my @again = split(/\./, $INFO{'runbackup_again'});
		$FORM{'backupnewest'} = $again[1];
		@backup_paths = split(/_/, $again[2]);
		if ($again[3] eq 'a') {
			$backupmethod = $again[4] eq 'tar' ? 'Archive::Tar' : 'Archive::Zip';
			$compressmethod = $again[5] ? ($again[5] eq 'gz' ? 'Compress::Zlib' : 'Compress::Bzip2') : 'none';
		} else {
			$backupmethod = $again[3] eq 'tar' ? '/usr/bin/tar' : '/usr/bin/zip';
			$compressmethod = $again[4] ? ($again[4] eq 'gz' ? '/bin/gzip' : '/bin/bzip2') : 'none';
		}
		&check_backup_settings;
	}

	my $backuptime = $INFO{'backuptime'} || time();

	my $time_to_jump = time() + $max_process_time;

	$curtime = $INFO{'curtime'} || $curtime;
	$FORM{'backupnewest'} ||= $INFO{'backupnewest'};
	$backuptype = 'n' if $FORM{'backupnewest'};
	if ($FORM{'backupnewest'} && $backupmethod eq '/usr/bin/zip') {
		my ($day, $mon, $year);
		(undef, undef, undef, $day, $mon, $year, undef, undef, undef) = gmtime($FORM{'backupnewest'});
		$FORM{'backupnewest'} = sprintf("%02d", ($mon+1)) . sprintf("%02d", $day) . (1900 + $year);

	} elsif ($FORM{'backupnewest'} && $backupmethod =~ /::/) {
		$FORM{'backupnewest'} = ($curtime - $FORM{'backupnewest'}) / 86400;
	}
	my $filedirs = join('_', @backup_paths);

	# Verify that our method is possible, and load it if it's a module
	&BackupMethodInit($filedirs);

	# Handle the conversion of the informal backup_paths stored in the settings file to the real ones
	# I'll build a hash to quickly match them.
	# A pipe separates them in the case of needing multiple real paths to handle one informal path
	%pathconvert = (
		'src', "$admindir|$sourcedir|$boarddir/Modules|!$boarddir",
		'bo', $boardsdir,
		'lan', "$langdir|$helpfile",
		'mem', $memberdir,
		'mes', $datadir,
		'temp', "$templatesdir|$forumstylesdir|$adminstylesdir",
		'var', $vardir,
		'html', "!$htmldir|!$htmldir/avatars|$htmldir/Buttons|$htmldir/googiespell|$htmldir/greybox|$htmldir/ModImages|$htmldir/Smilies|$htmldir/Templates",
		'upld', "$htmldir/Attachments|$htmldir/avatars/UserAvatars",
	);

	# Set the forum to maintenance mode.
	&automaintenance('on');

	# Looping to prevent runt into browser/server timeout
	my ($i,$j,$key,$path);
	foreach $key (@backup_paths) {
		$i++;
		if ($i >= $INFO{'loop1'}) {
			$j = 0;
			foreach $path (split(/\|/, $pathconvert{$key})) {
				$j++;
				if ($j > $INFO{'loop2'}) {
					$INFO{'loop2'} = 0;

					# To keep this simple, I'll just point to a generic subroutine that takes care of
					# handling the differences in backup methods.
					if ($path =~ s|^\./||) {
						$ENV{'SCRIPT_FILENAME'} =~ /(.*\/)/;
						$path = "$1$path";
					}
					&BackupDirectory($path,$filedirs);

					if (time() > $time_to_jump) {
						&BackupMethodFinalize($filedirs,1);
						&runbackup_loop($i,$j,$curtime,$FORM{'backupnewest'},$backuptime);
					}
				}
			}
			$INFO{'loop2'} = 0;
		}
	}

	# Last, we'll finalize the archive. If it's a tar, we compress them,
	# if requested. This can NOT be done with the forum out of maintenance mode
	# due to the maintenance.lock file that is removed with &automaintenance('off')
	&BackupMethodFinalize($filedirs,0);

	# Undo maintenance mode.
	&automaintenance('off');

	$lastbackup = $curtime; # save the last backup time with the actual settings
	&print_BackupSettings;

	# Display the amount of time it took to be nice ;)
	$yySetLocation = qq~$adminurl?action=backupsettings;backupspendtime=~ . sprintf("%.4f", (time() - $backuptime));
	&redirectexit;
}

# Checks once more that we can use the command or module given. If we can, we load module(s) here.
sub BackupMethodInit {
	my $filedirs = shift;

	# Check module types and load them at runtime (not compilation)
	if($backupmethod eq 'Archive::Tar') {
		eval 'use Archive::Tar;'; # Everything is exported at once
		if ($@) { &fatal_error("","$backup_txt{28} Archive::Tar: $@"); }
		if ($compressmethod eq 'Compress::Zlib') { # Also using Zlib
			eval 'use Compress::Zlib;'; # Zlib exports everything at once
			if ($@) { &fatal_error("","$backup_txt{28} Compres::Zlib: $@"); }

		} elsif ($compressmethod eq 'Compress::Bzip2') {
			eval 'use Compress::Bzip2 qw(:utilities);'; # Finally, something I can export just some code with
			if ($@) { &fatal_error("","$backup_txt{28} Compress::Bzip2: $@"); }

		} else { $compressmethod = 'none'; }

		$tarball = Archive::Tar->new;

		# We need this for the loops, when preventing to run into browser/server timeout.
		if (-e "$backupdir/backup$backuptype.$curtime.$filedirs.a.tar") {
			$tarball->read("$backupdir/backup$backuptype.$curtime.$filedirs.a.tar", 0);
			&delete_DBorFILE("$backupdir/backup$backuptype.$curtime.$filedirs.a.tar");
		}

	} elsif ($backupmethod eq 'Archive::Zip') {
		eval 'use Archive::Zip;'; # Everything's exported by default here too
		if ($@) { &fatal_error("","$backup_txt{28} Archive::Zip: $@"); }
		$zipfile = Archive::Zip->new;

		# We need this for the loops, when preventing to run into browser/server timeout.
		if (-e "$backupdir/backup$backuptype.$curtime.$filedirs.a.zip") {
			$zipfile->read("$backupdir/backup$backuptype.$curtime.$filedirs.a.zip");
		}

	} else {
		unless (&CheckPath($backupmethod)) { &fatal_error("","$backup_txt{29} $backupmethod."); }
		if ($compressmethod ne 'none' && !&CheckPath($compressmethod)) {
			&fatal_error("","$backup_txt{30} $compressmethod.");
		}
	}
}

sub BackupDirectory {
	# Handles all the fun of directly archiving a directory.
	my ($dir,$filedirs) = @_;
	my ($recursemode, $cr, $Nt);
	$recursemode = 1;
	if ($dir =~ s/^!//) { $recursemode = 0; }

	if ($backupmethod eq '/usr/bin/tar') {
		$cr = ($tarcreated || $INFO{'curtime'}) ? '-r' : '-c';
		$tarcreated = 1;
		if (!$recursemode) { $dir .= '/*.*'; }
		if ($FORM{'backupnewest'}) { $Nt = "-N \@$FORM{'backupnewest'}"; }
		$dir =~ s|^/||; # needet not to get server log messages like "Removing leading `/' from ..."
		&ak_system("tar $cr -C / -f $backupdir/backup$backuptype.$curtime.$filedirs.tar $Nt $dir") || &fatal_error("","'tar $cr -C / -f $backupdir/backup$backuptype.$curtime.$filedirs.tar $Nt $dir' $backup_txt{31}: $!. $backup_txt{32} " . ($? >> 8));

	} elsif ($backupmethod eq '/usr/bin/zip') {
		my $recurseoption;
		if (!$recursemode) { $dir .= '/*.*'; }
		else { $recurseoption = 'r'; }
		if ($FORM{'backupnewest'}) { $Nt = "-t $FORM{'backupnewest'}"; }
		&ak_system("zip -gq$recurseoption $Nt $backupdir/backup$backuptype.$curtime.$filedirs.zip $dir") || &fatal_error("","'zip -gq$recurseoption $Nt $backupdir/backup$backuptype.$curtime.$filedirs.zip $dir' $backup_txt{31}: $!. $backup_txt{32} " . ($? >> 8));

	} elsif ($backupmethod eq 'Archive::Tar') {
		$tarball->add_files(&RecurseDirectory($dir, $recursemode));

	} elsif ($backupmethod eq 'Archive::Zip') {
		map { $zipfile->addFile($_) } &RecurseDirectory($dir, $recursemode);
	}
}

sub RecurseDirectory {
	# Simple subroutine to run through every entry in a directory and return a giant list of the files/subdirs.
	my ($dir,$recursemode) = @_;
	my ($item, @dirlist, @newcontents);

	opendir(RECURSEDIR, $dir);
	@dirlist = readdir(RECURSEDIR);
	closedir(RECURSEDIR);

	foreach $item (@dirlist) {
		if ($recursemode && $item ne '.' && $item ne '..' && -d "$dir/$item") { push(@newcontents, &RecurseDirectory("$dir/$item", $recursemode)); }
		elsif (-f "$dir/$item" && (!$FORM{'backupnewest'} || $FORM{'backupnewest'} > -M "$dir/$item")) {
			push(@newcontents, "$dir/$item");
		}
	}
	@newcontents;
}

# Compresses the tar
sub BackupMethodFinalize {
	my ($filedirs,$loop) = @_;
	if (!$loop && $backupmethod eq '/usr/bin/tar') {
		if ($compressmethod eq '/bin/bzip2') {
			&ak_system("bzip2 -z $backupdir/backup$backuptype.$curtime.$filedirs.tar") || &fatal_error("","'bzip2 -z $backupdir/backup$backuptype.$curtime.$filedirs.tar.bz2' $backup_txt{31}: $!. $backup_txt{32} " . ($? >> 8));

		} elsif ($compressmethod eq '/bin/gzip') {
			&ak_system("gzip $backupdir/backup$backuptype.$curtime.$filedirs.tar") || &fatal_error("","'gzip $backupdir/backup$backuptype.$curtime.$filedirs.tar.gz' $backup_txt{31}: $!. $backup_txt{32} " . ($? >> 8));
		}

	} elsif ($backupmethod eq 'Archive::Tar') {
		if ($loop || $compressmethod eq 'none') {
			$tarball->write("$backupdir/backup$backuptype.$curtime.$filedirs.a.tar", 0);

		} elsif ($compressmethod eq 'Compress::Zlib') { # Gzip as a module
			my ($gzip) = gzopen("$backupdir/backup$backuptype.$curtime.$filedirs.a.tar.gz", 'wb');
			$gzip->gzwrite($tarball->write);
			$gzip->gzclose();
			&delete_DBorFILE("$backupdir/backup$backuptype.$curtime.$filedirs.tar");

		} elsif ($compressmethod eq 'Compress::Bzip2') { # Bzip2 as a module
			my ($bzip2) = bzopen("$backupdir/backup$backuptype.$curtime.$filedirs.a.tar.bz2", 'wb');
			$bzip2->bzwrite($tarball->write);
			$bzip2->bzclose();
			&delete_DBorFILE("$backupdir/backup$backuptype.$curtime.$filedirs.tar");
		}

	} elsif ($backupmethod eq 'Archive::Zip') {
		$zipfile->overwriteAs("$backupdir/backup$backuptype.$curtime.$filedirs.a.zip");
	}
}

sub ak_system { # Returns a success code. The system's code returned is $? >> 8
	CORE::system(@_);
	if ($? == -1) { return ''; } # Failed to execute; return a null string.
	elsif ($? & 127) { return 0; } # Died, return 0.
	1; # Success; return 1.
}

sub runbackup_loop {
	my ($i,$j,$curtime,$backupnewest,$backuptime) = @_;

	$yymain .= qq~</b>
	<p id="memcontinued">
		$admin_txt{'542'} <a href="$adminurl?action=runbackup;loop1=$i;loop2=$j;curtime=$curtime;backupnewest=$backupnewest;backuptime=$backuptime;runbackup_again=$INFO{'runbackup_again'}" onclick="PleaseWait();">$admin_txt{'543'}</a>.<br />
		$backup_txt{'90'}
	</p>

	<script type="text/javascript">
	 <!--
		function PleaseWait() {
			document.getElementById("memcontinued").innerHTML = '<font color="red"><b>$backup_txt{'91'}</b></font><br />&nbsp;<br />&nbsp;';
		}

		function stoptick() { stop = 1; }

		stop = 0;
		function membtick() {
			if (stop != 1) {
				PleaseWait();
				location.href="$adminurl?action=runbackup;loop1=$i;loop2=$j;curtime=$curtime;backupnewest=$backupnewest;backuptime=$backuptime;runbackup_again=$INFO{'runbackup_again'}";
			}
		}

		setTimeout("membtick()",2000);
	 // -->
	</script>~;

	&AdminTemplate;
}

sub CheckPath {
	my ($path, $file);
	$file = $_[0];

	if (-e $file) { return $file; }

	$file =~ s~\A.*\/~~;

	foreach $path (@ENVpaths) {
		$path =~ s~\/\Z~~;
		if (-e "$path/$file") { return "$path/$file"; }
	}
}

# Thanks to BBQ at PerlMonks for the basis of this routine: http://www.perlmonks.org/?node_id=9277
sub downloadbackup {
	chdir($backupdir) || &fatal_error("","$backup_txt{44} $backupdir",1);
	my $filename = $INFO{'backupid'};
	if ($filename !~ /\Abackup/ || $filename !~ /\d{9,10}/) { &fatal_error("",$backup_txt{'45'}); }
	my $filesize = -s $filename;

	# print full header
	print "Content-disposition: inline; filename=$filename\n";
	print "Content-Length: $filesize\n";
	print "Content-Type: application/octet-stream\n\n";

	# open in binmode
	fopen(READ, $filename) || &fatal_error("","$backup_txt{46} $filename",1);
	binmode READ;

	# stream it out
	binmode STDOUT;
	while (<READ>) {print;}
	fclose(READ);
}

sub deletebackup {
	my $filename = $INFO{'backupid'};
	if ($filename !~ /\Abackup/ || $filename !~ /\d{9,10}/) { &fatal_error("",$backup_txt{'45'}); }

	$yymain = qq~
$backup_txt{47} $filename $backup_txt{48}
<br />
<br /><a href="$adminurl?action=deletebackup2;backupid=$filename">$backup_txt{49}</a> | <a href="$adminurl?action=backupsettings">$backup_txt{50}</a>
~;

	&AdminTemplate;
}

sub deletebackup2 {
	my $filename = $INFO{'backupid'};
	if ($filename !~ /\Abackup/ || $filename !~ /\d{9,10}/) { &fatal_error("",$backup_txt{'45'}); }

	# Just remove it!
	&delete_DBorFILE("$backupdir/$filename") || &fatal_error("","$backup_txt{51} $backupdir/$filename",1);

	$yySetLocation = "$adminurl?action=backupsettings";
	&redirectexit();
}

sub emailbackup {
	# Unfourtantly, we can't use &sendmail() for this.
	# So, we'll load MIME::Lite and try that, as it should work.
	# If not, we'll email out a download link.
	my ($mainmessage, $filename);

	$filename = $INFO{'backupid'};
	if ($filename !~ /\Abackup/ || $filename !~ /\d{9,10}/) { &fatal_error("",$backup_txt{'45'}); }

	# Try to safely load MIME::Lite
	eval 'use MIME::Lite;';
	if (!$@ && !$INFO{'linkmail'}) { # We can use MIME::Lite.
		my $filesize = -s "$backupdir/$filename";
		$filesize = int($filesize / 1024); # Measure it in kilobytes
		if (!$INFO{'passwarning'} && $filesize > 1024 * 4) { # Warn if the file-size is to big for email (> 4 MB)
			if ($filesize > 1024 * 4) { $filesize = int($filesize / 1024) . ' MB'; } # Measure it in megabytes
			else { $filesize .= ' KB'; } # Label it

			$yymain = qq~
$backup_txt{54}?<br />
$backup_txt{55} <b>$filesize</b>!<br />
<br />
<a href="$adminurl?action=emailbackup;backupid=$INFO{'backupid'};passwarning=1">$backup_txt{56} <i>${$uid.$username}{'email'}</i></a><br />
<a href="$adminurl?action=emailbackup;backupid=$INFO{'backupid'};linkmail=1">$backup_txt{57}</a><br />
<a href="$adminurl?action=downloadbackup;backupid=$INFO{'backupid'}">$backup_txt{58}</a><br />
<a href="$adminurl?action=backupsettings">$backup_txt{59}</a>
~;
			&AdminTemplate;
		}

		$mainmessage = $backup_txt{'mailmessage1'};
		$mainmessage =~ s~USERNAME~${$uid.$username}{'realname'}~g;
		$mainmessage =~ s~LINK~$adminurl?action=downloadbackup;backupid=$filename~g;
		$mainmessage =~ s~FILENAME~$filename~g;

		eval q^
			my $msg = MIME::Lite->new(
				To      => ${$uid.$username}{'email'},
				From    => $backup_txt{'mailfrom'},
				Subject => $backup_txt{'mailsubject'},
				Type    => 'multipart/mixed'
				);
			$msg->attach(
				Type => 'TEXT',
				Data => $mainmessage
			);
			$msg->attach(
				Type     => 'AUTO', # Let it be auto-detected.
				Filename => $filename,
				Path     => "$backupdir/$filename",
			);
			if (!$mailtype) {
				$msg->send();
			} else {
				my @arg = ("$smtp_server", Hello => "$smtp_server", Timeout => 30);
				push(@arg, AuthUser => "$authuser") if $authuser;
				push(@arg, AuthPass => "$authpass") if $authpass;
				$msg->send('smtp', @arg);
			}
		^;
	}

	if ($@ || $INFO{'linkmail'}) {
		$mainmessage = ($INFO{'linkmail'} && !$@) ? $backup_txt{'mailmessage2'} : $backup_txt{'mailmessage3'};
		$mainmessage =~ s~USERNAME~${$uid.$username}{'realname'}~;
		$mainmessage =~ s~LINK~$adminurl?action=downloadbackup;backupid=$filename~;
		$mainmessage =~ s~FILENAME~$filename~;
		$mainmessage =~ s~SYSTEMINFO~$@~;

		require "$sourcedir/Mailer.pl";
		&sendmail(${$uid.$username}{'email'}, $backup_txt{'mailsubject'}, $mainmessage, $backup_txt{'mailfrom'});

		$yySetLocation = "$adminurl?action=backupsettings&mailinfo=-1";
	} else {
		$yySetLocation = "$adminurl?action=backupsettings&mailinfo=1";
	}

	&redirectexit();
}

sub recoverbackup1 {
	$INFO{'recoverfile'} =~ /\A(backup)(n?)\.(\d+)\.([^\.]+)\.(.+)/;

	my @dirs;
	foreach (split(/_/, $4)) {
		push(@dirs, $dirs{$_});
	}

	$yymain .= qq~
 <script type="text/javascript">
 <!--
	function CheckCHMOD (v,min,t) {
		if (v == '') {
			return;
		} else if (/\\D/.test(v)) {
			alert('$backup_txt{112}');
			t.value = '';
		} else if (v < min) {
			alert('$backup_txt{110} ' + min);
			t.value = min;
		} else if (v > 7) {
			alert('$backup_txt{111}');
			t.value = 7;
		}
	}
 -->
 </script>
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <form action="$adminurl?action=recoverbackup2" method="post" name="recover">
   <table width="100%" cellspacing="1" cellpadding="10">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="2">
         <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$backup_txt{100}</b>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2" colspan="2">
         $backup_txt{101}<br />
         <br />
         - ~ . join('<br />- ', @dirs) . qq~<br />
         <br />
         $backup_txt{102}<br />
         <br />
         <i>$INFO{'recoverfile'}</i>~ . ($2 ? " (<b>$backup_txt{62}</b>)" : '') . qq~ $backup_txt{103} ~ . &timeformat($3) . qq~<br />
         <br />
         <input type="button" onclick="window.location.href='$adminurl?action=backupsettings'" value="$backup_txt{125}" /><br />
         <br />
         $backup_txt{104},<br />
         <br />
         <input type="checkbox" name="originalrestore" value="1" /> $backup_txt{105}<br />
         <br />
         $backup_txt{106}<br />
         <table cellpadding="3">
           <tr><td align="center" valign="middle"><b>$backup_txt{107}</b></td><td align="center" valign="middle"><b>$backup_txt{108}</b></td></tr>\n~;

	$INFO{'recoverfile'} =~ /\.tar(.*)$/;
	my $recovertype = $1 eq '.gz' ? "tar -tzf $backupdir/$INFO{'recoverfile'} -C $backupdir/" : "tar -tf $backupdir/$INFO{'recoverfile'} -C $backupdir/";

	my %checkdir;
	foreach (split(/\n/, qx($recovertype))) {
		next if -d "/$_/";
		$_ =~ /(.*\/)(.*)/;
		if (!$checkdir{$1} && $2) {
			$checkdir{$1} = 1;
			$yymain .= qq~           <tr><td align="left">/$1 *$backup_txt{114}</td><td align="center"><input type="text" name="u-$1" value="6" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,6,this);" /> <input type="text" name="g-$1" value="6" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,6,this);" /> <input type="text" name="a-$1" value="" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,0,this);" /></td></tr>\n~;
		}
	}

	$yymain .= qq~
           <tr>
             <td align="left" colspan="2">&nbsp;</td>
           </tr>
           <tr>
             <td align="left">$backup_txt{115} index.html $backup_txt{116}</td><td align="center"><input type="text" name="u-index" value="6" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,6,this);" /> <input type="text" name="g-index" value="6" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,6,this);" /> <input type="text" name="a-index" value="4" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,0,this);" /></td>
           </tr>
           <tr>
             <td align="left">$backup_txt{115} .htaccess $backup_txt{116}</td><td align="center"><input type="text" name="u-htaccess" value="6" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,6,this);" /> <input type="text" name="g-htaccess" value="6" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,6,this);" /> <input type="text" name="a-htaccess" value="4" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,0,this);" /></td>
           </tr>
           <tr>
             <td align="left" colspan="2">&nbsp;</td>
           </tr>
           <tr>
             <td align="left">$backup_txt{120}</td><td align="center"><input type="text" name="u-newdir" value="7" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,6,this);" /> <input type="text" name="g-newdir" value="5" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,5,this);" /> <input type="text" name="a-newdir" value="5" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,0,this);" /></td>
           </tr>
         </table>
         <br />
         <input type="hidden" name="recoverfile" value="$INFO{'recoverfile'}" />
         <input type="submit" value="$backup_txt{126}" />
       </td>
     </tr>
   </table>
   </form>
 </div>~;

	&AdminTemplate;
}

sub recoverbackup2 {
	my ($output,$o,$CHMOD,%checkdirexists,%checkdir,$path);

	my $restore_root;
	if ($FORM{'originalrestore'}) {
		$restore_root = "/";
	} else {
		$restore_root = "$backupdir/recovered_$date/";
		mkdir($restore_root,oct("0$FORM{'u-newdir'}$FORM{'g-newdir'}$FORM{'a-newdir'}"));
		chmod(oct("0$FORM{'u-newdir'}$FORM{'g-newdir'}$FORM{'a-newdir'}"), $restore_root); # mkdir somtimes does not set the CHMOD as expected
	}

	$FORM{'recoverfile'} =~ /\.tar(.*)$/;
	my $recovertype = $1 eq '.gz' ? "tar -tzf $backupdir/$FORM{'recoverfile'} -C $restore_root" : "tar -tf $backupdir/$FORM{'recoverfile'} -C $restore_root";
	$output = qx($recovertype);
	$recovertype = $1 eq '.gz' ? "tar -xzf $backupdir/$FORM{'recoverfile'} -C $restore_root" : "tar -xf $backupdir/$FORM{'recoverfile'} -C $restore_root";

	# Check what directories do/do not exist
	foreach $o (split(/\n/, $output)) {
		next if -d "/$o/";
		$o =~ /(.*\/)(.*)/;
		$path = "";
		foreach (split(/\//, $1)) {
			$path .= "$_/";
			if (!$checkdirexists{$path}) { $checkdirexists{$path} = -d "$restore_root/$path" ? 1 : -1; }
		}
	}

	qx($recovertype); # must be done AFTER directory check!

	$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="10">
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="2">
         <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$backup_txt{100}</b>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2" colspan="2">
         $backup_txt{130}<br />
         <br />
         <pre>\n~;

	foreach $o (split(/\n/, $output)) {
		next if -d "/$o/";
		$CHMOD = "";
		$o =~ /(.*\/)(.*)/;
		if ($2 eq "index.html") {
			$CHMOD .= $FORM{'u-index'} < 6 ? 6 : $FORM{'u-index'};
			$CHMOD .= $FORM{'g-index'} < 6 ? 6 : $FORM{'g-index'};
			$CHMOD .= $FORM{'a-index'} < 1 ? 0 : $FORM{'a-index'};

		} elsif ($2 eq ".htaccess") {
			$CHMOD .= $FORM{'u-htaccess'} < 6 ? 6 : $FORM{'u-htaccess'};
			$CHMOD .= $FORM{'g-htaccess'} < 6 ? 6 : $FORM{'g-htaccess'};
			$CHMOD .= $FORM{'a-htaccess'} < 1 ? 0 : $FORM{'a-htaccess'};

		} elsif ($2) {
			$CHMOD .= $FORM{'u-' . $1} < 6 ? 6 : $FORM{'u-' . $1};
			$CHMOD .= $FORM{'g-' . $1} < 6 ? 6 : $FORM{'g-' . $1};
			$CHMOD .= $FORM{'a-' . $1} < 1 ? 0 : $FORM{'a-' . $1};
		}

		$path = "";
		foreach (split(/\//, $1)) {
			$path .= "$_/";
			if (!$checkdir{$path}) {
				$checkdir{$path} = 1;
				if ($checkdirexists{$path} == -1) { # set directories CHMOD
					my $od = "$restore_root/$path";
					$yymain .= chmod(oct("0$FORM{'u-newdir'}$FORM{'g-newdir'}$FORM{'a-newdir'}"), $od) . " - CHMOD 0$FORM{'u-newdir'}$FORM{'g-newdir'}$FORM{'a-newdir'} - $od\n";
				}
			}
		}

		if ($CHMOD) {
			$o = "$restore_root/$o";
			$yymain .= chmod(oct("0$CHMOD"), $o) . " - CHMOD 0$CHMOD - $o\n";
		}
	}

	$yymain .= qq~         </pre>
         $backup_txt{131}<br />
         <br />
         <input type="button" onclick="window.location.href='$adminurl?action=backupsettings'" value="$backup_txt{132}" />
       </td>
     </tr>
   </table>
 </div>~;

	&AdminTemplate;
}

1;