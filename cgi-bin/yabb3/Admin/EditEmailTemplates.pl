###############################################################################
# EditEmailTemplates.pl                                                       #
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

$editemailtemplatesplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub editemailtemplates {
	&is_admin_or_gmod();
	my($editlang, $string);

	$editlang = $INFO{'lang'} || '';
	$string = $INFO{'string'} || '';

	if(!$editlang) {
		# Select language
		$yymain .= qq~
<form action="$adminurl?action=editemailtemplates" method="get" style="display: inline">
<input type="hidden" name="action" value="editemailtemplates" />
  <table class="bordercolor" align="center" width="440" cellspacing="1" cellpadding="4">
    <tr valign="middle">
      <td align="left" class="titlebg">
        <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$emaileditor{'1'}</b>
      </td>
    </tr>
    <tr valign="middle">
      <td align="center" class="windowbg2">
        <select name="lang">~;

		# Find all the languages
		opendir(LNGDIR, $langdir);
		my @langitems = readdir(LNGDIR);
		close(LNGDIR);
		foreach my $item (sort {lc($a) cmp lc($b)} @langitems) {
			if (-d "$langdir/$item" && $item =~ m~\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@/]+\Z~ && -e "$langdir/$item/Email.lng") {
				my $displang = $item;
				$displang =~ s~(.+?)\_(.+?)$~$1 ($2)~gi;
				$yymain .= qq~
          <option value="$item">$displang</option>~;
			}
		}

		$yymain .= qq~
        </select>
      </td>
    </tr>
    <tr valign="middle">
      <td align="center" class="catbg">
   	<input type="submit" value="$emaileditor{'2'}" class="button" />
      </td>
    </tr>
  </table>
</form>~;
	}
	elsif(!$string) {
		# Select string

		$yymain .= qq~
<form action="$adminurl?action=editemailtemplates" method="get" style="display: inline">
<input type="hidden" name="action" value="editemailtemplates" />
<input type="hidden" name="lang" value="$editlang" />
  <table class="bordercolor" align="center" width="440" cellspacing="1" cellpadding="4">
    <tr valign="middle">
      <td align="left" class="titlebg">
        <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$emaileditor{'3'}</b>
      </td>
    </tr>
    <tr valign="middle">
      <td align="center" class="windowbg2">
        <select name="string">~;

		# Find all the strings
		&LoadLanguage('Email');
		my @emaildescset = sort{ $emaildesc{$a} cmp $emaildesc{$b} } keys %emaildesc;
		foreach my $varname (@emaildescset) {
			$yymain .= qq~
          <option value="$varname">$emaildesc{$varname}</option>~;
		}

		$yymain .= qq~
        </select>
      </td>
    </tr>
    <tr valign="middle">
      <td align="center" class="catbg">
   	<input type="submit" value="$emaileditor{'2'}" class="button" />
      </td>
    </tr>
  </table>
</form>~;
	}
	else {
		# Show editor
		my $reallang = $language;
		$language = $editlang;
		&LoadLanguage('Email');
		$language = $reallang;

		my $message = ${$string};
		&ToHTML($message);
		my $comment = $emaildesc{$string};

		$yymain .= qq~
<form action="$adminurl?action=editemailtemplates2;lang=$editlang;string=$string" method="post" style="display: inline">
  <table class="bordercolor" align="center" cellspacing="1" cellpadding="4">
    <tr valign="middle">
      <td align="left" class="titlebg">
        <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$emaileditor{'4'}</b>
      </td>
    </tr>
    <tr valign="middle">
      <td align="left" class="windowbg2">
        $emaileditor{'5'} $comment<br /><br />
        $emaileditor{'6'}<br />
        <textarea name="message" rows="20" cols="80">$message</textarea>
      </td>
    </tr>
    <tr valign="middle">
      <td align="left" class="windowbg2">
        $emaileditor{'7'}
        <ul>
          <li>{yabb scripturl} $yabbtagdesc{'scripturl'}</li>
          <li>{yabb adminurl} $yabbtagdesc{'adminurl'}</li>
          <li>{yabb mbname} $yabbtagdesc{'mbname'}</li>~;

	# Find the list of usable YaBB tags
	foreach my $yabbtag (split(/\s+/, $yabbtags{$string})) {
		next unless $yabbtag =~ /\w/;
		$yymain .= qq~
          <li>{yabb $yabbtag} $yabbtagdesc{$yabbtag}</li>~;
	}	

	$yymain .= qq~
        </ul>
      </td>
    </tr>
    <tr valign="middle">
      <td align="left" class="catbg">
   	$emaileditor{'8'}
        <br />$emaileditor{'9'} <tt>Languages/$editlang/Email.lng</tt> $emaileditor{'10'}
      </td>
    </tr>
    <tr valign="middle">
      <td align="center" class="catbg">
   	<input type="submit" value="$emaileditor{'11'}" class="button" />
      </td>
    </tr>
  </table>
</form>~;
	}

	$yytitle = $admintxt{'a4_label4'};
	$action_area = 'editemailtemplates';
	&AdminTemplate();
}

sub editemailtemplates2 {
	&is_admin_or_gmod();
	my($editlang, $string, $message);

	$editlang = $INFO{'lang'};
	$string = $INFO{'string'};
	$message = $FORM{'message'};

	$message =~ s~(\~|\\)~\\$1~g;
	$message =~ s/\r(?=\n*)//g;

	&fatal_error('no_info') unless $message && $string;

	# Read the current file
	my $langfile = join('', &read_DBorFILE(0,'',"$langdir/$editlang",'Email','lng'));

	# Vague hardcoded error since it was tampered with
	&fatal_error('error_occurred', 'Language Error') unless $string =~ /\Q$string\E/;

	# Make the change
	$langfile =~ s!\$\Q$string\E = qq~.+?~;!\$$string = qq~$message~;!s;

	# Write it out
	&write_DBorFILE(0,'',"$langdir/$editlang",'Email','lng',($langfile));

	$yySetLocation = qq~$adminurl~;
	&redirectexit();
}

1;
