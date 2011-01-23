###############################################################################
# DoSmilies.pl                                                                #
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

$dosmiliesplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('Main');

sub SmiliePut {
	&print_output_header;

	$moresmilieslist   = "";
	$evenmoresmilies   = "";
	$more_smilie_array = "";
	$i = 0;
	while ($SmilieURL[$i]) {
		if ($SmilieURL[$i] =~ /\//i) { $tmpurl = $SmilieURL[$i]; }
		else { $tmpurl = qq~$defaultimagesdir/$SmilieURL[$i]~; }
		$moresmilieslist .= qq~<br />~ if $i && ($i / 10) == int($i / 10);
		$moresmilieslist .= qq~<img src="$tmpurl" align="bottom" alt="$SmilieDescription[$i]" border="0" onclick="javascript:MoreSmilies($i)" style="cursor:hand" />$SmilieLinebreak[$i]\n~;
		$smilie_url_array .= qq~"$tmpurl", ~;
		$tmpcode = $SmilieCode[$i];
		$tmpcode =~ s/\&quot;/"+'"'+"/g;
		&FromHTML($tmpcode);
		$tmpcode =~ s/&#36;/\$/g;
		$tmpcode =~ s/&#64;/\@/g;
		$more_smilie_array .= qq~" $tmpcode", ~;
		$i++;
	}
	if ($showsmdir eq 3 || ($showsmdir eq 2 && $detachblock eq 1)) {
		opendir(DIR, "$smiliesdir");
		@contents = readdir(DIR);
		closedir(DIR);
		$smilieslist = "";
		foreach $line (sort { uc($a) cmp uc($b) } @contents) {
			($name, $extension) = split(/\./, $line);
			if ($extension =~ /gif/i || $extension =~ /jpg/i || $extension =~ /jpeg/i || $extension =~ /png/i) {
				if ($line !~ /banner/i) {
					$evenmoresmilies .= qq~<br />~ if $i && ($i / 10) == int($i / 10);
					$evenmoresmilies .= qq~<img src='$smiliesurl/$line' align="bottom" alt='$name' border='0' onclick='javascript:MoreSmilies($i)' style='cursor:hand' />\n~;
					$more_smilie_array .= qq~" [smiley=$line]", ~;
					$i++;
				}
			}
		}
	}
	$more_smilie_array .= qq~""~;

	$output = qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$smiltxt{'1'}</title>
<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />
<link rel="stylesheet" href="$forumstylesurl/$usestyle.css" type="text/css" />
<script language="JavaScript1.2" type="text/javascript">
<!--
function AddText(text) {
	if (window.opener && !window.opener.closed) {
		if (opener.document.postmodify.message.createTextRange && opener.document.postmodify.message.caretPos) {      
			var caretPos = opener.document.postmodify.message.caretPos;
			caretPos.text = caretPos.text.charAt(caretPos.text.length - 1) == ' ' ?
			text + ' ' : text;
		} else if (opener.document.postmodify.message.setSelectionRange) {
			var selectionStart = opener.document.postmodify.message.selectionStart;
			var selectionEnd = opener.document.postmodify.message.selectionEnd;
			var replaceString = text + opener.document.postmodify.message.value.substring(selectionStart, selectionEnd);
			opener.document.postmodify.message.value = opener.document.postmodify.message.value.substring(0, selectionStart) + replaceString + opener.document.postmodify.message.value.substring(selectionEnd);
			opener.document.postmodify.message.setSelectionRange(selectionStart + text.length, selectionEnd + text.length);
		} else {
			opener.document.postmodify.message.value += text;
		}
	}
}

moresmiliecode = new Array($more_smilie_array)

function MoreSmilies(i) {
	AddTxt=moresmiliecode[i];
	AddText(AddTxt);
}
// -->
</script>
</head>
<body style="background: #$popback; min-width:400px;">
<span style="color: #$poptext;">$smiltxt{'21'}</span><br /><br />~;

	if ($showadded eq 3 || ($showadded eq 2 && $detachblock eq 1)) {
		$output .= qq~ $moresmilieslist ~;
	}

	$output .= qq~
	$evenmoresmilies
</body>
</html>~;

	&print_HTML_output_and_finish;
}

sub SmilieIndex {
	&print_output_header;

	$i = 0;
	$offset = 0;
	$smilieslist = "";
	$smilie_code_array = "";
	if ($showadded eq 3 || ($showadded eq 2 && $detachblock eq 1)) {
		while ($SmilieURL[$i]) {
			if ($i % 4 == 0 && $i != 0) {
				$smilieslist .= qq~      </tr>\n      <tr>\n~;
				$offset++;
			}
			if (($i + $offset) % 2 == 0) { $smiliescolor = qq~class="windowbg2"~; }
			else { $smiliescolor = qq~class="windowbg"~; }
			if ($SmilieURL[$i] =~ /\//i) { $tmpurl = $SmilieURL[$i]; }
			else { $tmpurl = qq~$defaultimagesdir/$SmilieURL[$i]~; }
			$smilieslist .= qq~          <td align="center" valign="middle" height="60" $smiliescolor><img src="$tmpurl" border="0" alt="" onclick='javascript:MoreSmilies($i)' style='cursor:hand' /><br /><font size="1" color="#$poptext">$SmilieDescription[$i]</font></td>\n~;
			$smilie_url_array .= qq~"$tmpurl", ~;
			$tmpcode = $SmilieCode[$i];
			$tmpcode =~ s/\&quot;/"+'"'+"/g;
			&FromHTML($tmpcode);
			$tmpcode =~ s/&#36;/\$/g;
			$tmpcode =~ s/&#64;/\@/g;
			$more_smilie_array .= qq~" $tmpcode", ~;
			$i++;
		}
	}
	if ($showsmdir eq 3 || ($showsmdir eq 2 && $detachblock eq 1)) {
		opendir(DIR, "$smiliesdir");
		@contents = readdir(DIR);
		closedir(DIR);
		foreach $line (sort { uc($a) cmp uc($b) } @contents) {
			($name, $extension) = split(/\./, $line);
			if ($extension =~ /gif/i || $extension =~ /jpg/i || $extension =~ /jpeg/i || $extension =~ /png/i) {
				if ($line !~ /banner/i) {
					if ($i % 4 == 0 && $i != 0) {
						$smilieslist .= qq~      </tr>\n      <tr>\n~;
						$offset++;
					}
					if (($i + $offset) % 2 == 0) { $smiliescolor = qq~class="windowbg2"~; }
					else { $smiliescolor = qq~class="windowbg"~; }
					$smilieslist .= qq~          <td align="center" valign="middle" height="60" $smiliescolor><img src="$smiliesurl/$line" border="0" alt="" onclick="javascript:MoreSmilies($i)" style="cursor:hand" /><br /><font size="1" color="#$poptext">$line</font></td>\n~;
					$more_smilie_array .= qq~" [smiley=$line]", ~;
					$i++;
				}
			}
		}
	}
	while ($i % 4 != 0) {
		if (($i + $offset) % 2 == 0) { $smiliescolor = qq~class="windowbg2"~; }
		else { $smiliescolor = qq~class="windowbg"~; }
		$smilieslist .= qq~          <td align="center" valign="middle" height="60" $smiliescolor>&nbsp;</td>\n~;
		$i++;
	}
	$smilie_code_array .= qq~""~;
	$more_smilie_array .= qq~""~;
	if (-e "$smiliesdir/banner.gif") { $smiliesheader = qq~<tr><td colspan="4" bgcolor="#$popback" align="center"><img src="$smiliesurl/banner.gif" alt="" /></td></tr>~; }
	else { $smiliesheader = qq~<tr><td colspan="4" align="center"><b><font size="2">$smiltxt{'21'}</font></b></td></tr>~; }

	$output = qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$smiltxt{'1'}</title>
<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />
<link rel="stylesheet" href="$forumstylesurl/$usestyle.css" type="text/css" />
<script language="JavaScript1.2" type="text/javascript">
<!--
function AddText(text) {
	if (window.opener && !window.opener.closed) {
		if (opener.document.postmodify.message.createTextRange && opener.document.postmodify.message.caretPos) {
			var caretPos = opener.document.postmodify.message.caretPos;
			caretPos.text = caretPos.text.charAt(caretPos.text.length - 1) == ' ' ?
			text + ' ' : text;
		} else if (opener.document.postmodify.message.setSelectionRange) {
			var selectionStart = opener.document.postmodify.message.selectionStart;
			var selectionEnd = opener.document.postmodify.message.selectionEnd;
			var replaceString = text + opener.document.postmodify.message.value.substring(selectionStart, selectionEnd);
			opener.document.postmodify.message.value = opener.document.postmodify.message.value.substring(0, selectionStart) + replaceString + opener.document.postmodify.message.value.substring(selectionEnd);
			opener.document.postmodify.message.setSelectionRange(selectionStart + text.length, selectionEnd + text.length);
		} else {
			opener.document.postmodify.message.value += text;
		}
	}
}

moresmiliecode = new Array($more_smilie_array)
function MoreSmilies(i) {
	AddTxt=moresmiliecode[i];
	AddText(AddTxt);
}
//-->
</script>
</head>
<body style="background: #$popback; min-width:400px;">
    <table border="0" cellpadding="4" cellspacing="1" class="bordercolor">
$smiliesheader
      <tr>
$smilieslist
      </tr>
    </table>
</body>
</html>~;

	&print_HTML_output_and_finish;
}

1;