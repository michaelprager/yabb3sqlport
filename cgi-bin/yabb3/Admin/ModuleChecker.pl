#!/usr/bin/perl --

###############################################################################
# ModuleChecker.pl                                                            #
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

$modulecheckerplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

if ($ENV{'SCRIPT_FILENAME'} =~ /ModuleChecker\.\w+$/) {
	# This part is only needed if you call ModuleChecker.pl directly
	# as stand allone script (only the language "English" is supported).

	# Make sure the ./Modules path is present
	push(@INC, "./Modules");

	%modulecheck = (
	'1' => 'Module Check',
	'2' => 'Checks if all modules used by YaBB are installed.',
	'3' => 'Name of the Module',
	'4' => 'Info',
	'5' => 'Information provided by the system:',
	'6' => 'Installed',
	'7' => 'Some modules are not installed on you server.',
	'8' => '<b>If you really need them (read the Info), your first choice should be to ask your server host to install the needed modules for you!<br /><br />If you are the host of your own server, or if your host does not install the module for you, see <a href="http://codex.yabbforum.com/YaBB.pl?num=..../0#0" target="_blank"><b>this post in the <i>YaBB Codex</i> for help</b></a>.</b>',
	'Digest::MD5' => 'Used for the password encryption.<br />This module is essential! Without it YaBB will not work!',
	'Time::HiRes' => 'Used for the benchmarking time if debug is enabled.<br />If this module in not installed the benchmarking time will be displayed in full seconds and not in high resolution seconds. Otherwise you do not need this module.',
	'Time::Local' => 'Used to convert time strings into timestamps.<br />This module is essential! Without it YaBB will not always work!',
	'File::Find' => 'Used for avatar and attachment upload.<br />If this module is not installed and these features are enabled you will get an error messages when you try to upload. Otherwise you do not need this module.',
	'CGI' => 'Used for avatar and attachment upload.<br />If this module is not installed and these features are enabled you will get an error messages when you try to upload. Otherwise you do not need this module.',
	'DBI' => 'Used if you want to use MySQL for saving your data.<br />If this module is not installed you can\'t use the MySQL database you will have to use the flat file database, what is not bad too!!! Especially for not too big forums I (deti) recommend to use the flat file database. If you do not want to use MySQL, you do not need this module.',
	'Net::SMTP' => 'Used to send emails via SMTP.<br />This module is only needed if you want to send your emails via Net::SMTP. Otherwise you do not need this module.',
	'Net::SMTP::TLS' => 'Used to send emails via SMTP::TLS.<br />This module is only needed if you want to send your emails via Net::SMTP::TLS. Otherwise you do not need this module.',
	'Compress::Zlib' => 'Used for the Backup feature and to compress the size of the HTML-Code sent from YaBB to the browser.<br />This module is only needed if you do not have other Backup methods available (see the page of the Backup feature for details) and/or if you want to enable "Use GZip-Compression?". Otherwise you do not need this module.',
	'Compress::Bzip2' => 'Used for the Backup feature.<br />This module is only needed if you do not have other Backup methods available (see the page of the Backup feature for details). Otherwise you do not need this module.',
	'Archive::Tar' => 'Used for the Backup feature.<br />This module is only needed if you do not have other Backup methods available (see the page of the Backup feature for details). Otherwise you do not need this module.',
	'Archive::Zip' => 'Used for the Backup feature.<br />This module is only needed if you do not have other Backup methods available (see the page of the Backup feature for details). Otherwise you do not need this module.',
	'MIME::Lite' => 'Used to send Backups attached on an email.<br />This module is only needed if you want to get the Backup by email and not by direct download from the AdminCenter.',
	'LWP::UserAgent' => 'Used by "GoogieSpell", our Spell Checker.<br />If this module is not installed you can not enable the Spell Checker. Otherwise you do not need this module.',
	'HTTP::Request::Common' => 'Used by "GoogieSpell", our Spell Checker.<br />If this module is not installed you can not enable the Spell Checker. Otherwise you do not need this module.',
	'Crypt::SSLeay' => 'Used by "GoogieSpell", our Spell Checker.<br />If this module is not installed you can not enable the Spell Checker. Otherwise you do not need this module.',
	'IO::Socket::INET' => 'Used to send emails via "YaBB SMTP Engine".<br />This module is only needed if you want to send your emails via the "YaBB SMTP Engine". Otherwise you do not need this module.',
	'Digest::HMAC_MD5' => 'Used to send emails via "YaBB SMTP Engine".<br />This module is only needed if you want to send your emails via the "YaBB SMTP Engine". Otherwise you do not need this module.',
	'Carp' => 'Used to send emails via "YaBB SMTP Engine".<br />This module is only needed if you want to send your emails via the "YaBB SMTP Engine". Otherwise you do not need this module.',
	'bytes' => 'Used to send emails via "YaBB SMTP Engine".<br />This module is only needed if you want to send your emails via the "YaBB SMTP Engine". Otherwise you do not need this module.',
	'integer' => 'Used to send emails via "YaBB SMTP Engine".<br />This module is only needed if you want to send your emails via the "YaBB SMTP Engine". Otherwise you do not need this module.',
	);
}

my ($checker_output,$module,$i);

foreach $module qw(Digest::MD5 Time::HiRes Time::Local File::Find CGI DBI Net::SMTP Net::SMTP::TLS Compress::Zlib Compress::Bzip2 Archive::Tar Archive::Zip MIME::Lite LWP::UserAgent HTTP::Request::Common Crypt::SSLeay IO::Socket::INET Digest::HMAC_MD5 Carp bytes integer) {
	eval "require $module";

	if ($@) {
		$dont_continue_setup = 1 if "$module" eq "Digest::MD5";
		$i = $modulecheck{'8'};
		my $e = $@;
		# IE does display the @INC path it in one line  :-(
		# If you use IE and don't like what you see, remove the
		# comment (#) in next line.
		# $e =~ s/\//\\/g;
		$checker_output .= qq~
	<tr valign="middle">
		<td align="left" class="windowbg2">
			<font color="red">$module</font>
		</td>
		<td align="left" class="windowbg2">
			$modulecheck{'5'}<br />
			<br />
			$e
		</td>
		<td align="left" class="windowbg2">
			$modulecheck{"$module"}
		</td>
	</tr>~;
	} else {
		$checker_output .= qq~
	<tr valign="middle">
		<td align="left" class="windowbg2">
			<font color="green">$module</font>
		</td>
		<td align="left" class="windowbg2" colspan="2">
			$modulecheck{'6'}
		</td>
	</tr>~;
	}
}

if ($ENV{'SCRIPT_FILENAME'} !~ /ModuleChecker\.\w+$/) {
	$yymain .= qq~
<div style="float: left; padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">&nbsp;</div>
<div class="bordercolor" style="float: left; padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td align="left" class="titlebg" colspan="3">
			<b>$modulecheck{'1'}</b>
		</td>
	</tr>
	<tr valign="middle">
		<td align="left" class="catbg" colspan="3">
			<span class="small">$modulecheck{'2'}</span>
		</td>
	</tr>~ . ($i ? qq~
	<tr valign="middle">
		<td align="left" class="windowbg2">
			<font color="red"><b>$modulecheck{'7'}</b></font>
		</td>
		<td align="left" class="windowbg2" colspan="2">
			$i
		</td>
	</tr>~ : '') . qq~
	<tr valign="middle">
		<td align="center" class="catbg">
			<b>$modulecheck{'3'}</b>
		</td>
		<td align="center" class="catbg" colspan="2">
			<b>$modulecheck{'4'}</b>
		</td>
	</tr>
	$checker_output
</table>
</div>~;

} else {
	print qq~Content-Type: text/html$params{'-charset'}\r\n
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>YaBB 2 Module Checker</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
</head>
<body>
<div style="height: 40px;">&nbsp;</div>
<table align="center" width="80%" border="1" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td align="left" class="titlebg" colspan="3">
			<b>$modulecheck{'1'}</b><br />
			$modulecheck{'2'}
		</td>
	</tr>~ . ($i ? qq~
	<tr valign="middle">
		<td align="left" class="windowbg2">
			<font color="red"><b>$modulecheck{'7'}</b></font>
		</td>
		<td align="left" class="windowbg2" colspan="2">
			$i
		</td>
	</tr>~ : '') . qq~
	<tr valign="middle">
		<td align="center" class="catbg">
			<b>$modulecheck{'3'}</b>
		</td>
		<td align="center" class="catbg" colspan="2">
			<b>$modulecheck{'4'}</b>
		</td>
	</tr>
	$checker_output
</table>
<div style="height: 40px;">&nbsp;</div>
</body>
</html>~;
}

1;