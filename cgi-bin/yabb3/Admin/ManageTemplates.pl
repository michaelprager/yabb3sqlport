###############################################################################
# ManageTemplates.pl                                                          #
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

$managetemplatesplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('Templates');

sub ModifyTemplate {
	&is_admin_or_gmod;
	my ($fulltemplate, $line);
	if    ($FORM{'templatefile'}) { $templatefile = $FORM{'templatefile'} }
	elsif ($INFO{'templatefile'}) { $templatefile = $INFO{'templatefile'} }
	else { $templatefile = "default/default.html"; }
	opendir(TMPLDIR, $templatesdir);
	@temptemplates = readdir(TMPLDIR);
	closedir(TMPLDIR);
	$templs = "";

	foreach $file (@temptemplates) {
		if (-e "$templatesdir/$file/$file.html") {
			push(@templates, $file);
		} else {
			next;
		}
	}

	foreach $name (sort @templates) {
		$selected = "";

		if (-e "$templatesdir/$name/$name.html") {
			$cmp_templatefile = "$name/$name.html";
			if ($cmp_templatefile eq $templatefile) { $selected = qq~ selected="selected"~; }
			$templs .= qq~<option value="$cmp_templatefile"$selected>$cmp_templatefile</option>\n~;
			$selected = "";
		} elsif (-e "$templatesdir/$name/$name.htm") {
			$cmp_templatefile = "$name/$name.htm";
			if ($cmp_templatefile eq $templatefile) { $selected = qq~ selected="selected"~; }
			$templs .= qq~<option value="$cmp_templatefile"$selected>$cmp_templatefile</option>\n~;
			$selected = "";
		}

		$cmp_boardfile   = "$name/BoardIndex.template";
		$cmp_messagefile = "$name/MessageIndex.template";
		$cmp_displayfile = "$name/Display.template";
		$cmp_helpfile    = "$name/HelpCentre.template";
		$cmp_mycenterfile = "$name/MyCenter.template";

		if (-e "$templatesdir/$name/BoardIndex.template") {
			$ext = "BoardIndex";
			if ($cmp_boardfile eq $templatefile) { $selected = qq~ selected="selected"~; }
			$templs .= qq~<option value="$name/$ext.template"$selected>$name/$ext</option>\n~;
			$selected = "";
		}
		if (-e "$templatesdir/$name/MessageIndex.template") {
			$ext = "MessageIndex";
			if ($cmp_messagefile eq $templatefile) { $selected = qq~ selected="selected"~; }
			$templs .= qq~<option value="$name/$ext.template"$selected>$name/$ext</option>\n~;
			$selected = "";
		}
		if (-e "$templatesdir/$name/Display.template") {
			$ext = "Display";
			if ($cmp_displayfile eq $templatefile) { $selected = qq~ selected="selected"~; }
			$templs .= qq~<option value="$name/$ext.template"$selected>$name/$ext</option>\n~;
			$selected = "";
		}
		if (-e "$templatesdir/$name/HelpCentre.template") {
			$ext = "HelpCentre";
			if ($cmp_helpfile eq $templatefile) { $selected = qq~ selected="selected"~; }
			$templs .= qq~<option value="$name/$ext.template"$selected>$name/$ext</option>\n~;
			$selected = "";
		}
		if (-e "$templatesdir/$name/MyCenter.template") {
			$ext = "MyCenter";
			if ($cmp_mycenterfile eq $templatefile) { $selected = qq~ selected="selected"~; }
			$templs .= qq~<option value="$name/$ext.template"$selected>$name/$ext</option>\n~;
			$selected = "";
		}
	}

	fopen(TMPL, "$templatesdir/$templatefile");
	while ($line = <TMPL>) {
		$line =~ s~[\r\n]~~g;
		$line =~ s~&nbsp;~&#38;nbsp;~g;
		$line =~ s~&amp;~&#38;amp;~g;
		&FromHTML($line);
		$fulltemplate .= qq~$line\n~;
	}
	fclose(TMPL);

	$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4" style="table-layout: fixed;">
	<tr valign="middle">
		<td align="left" class="titlebg">
		<img src="$imagesdir/xx.gif" alt="" border="0" /><b> $templ_txt{'52'}</b> - $templatefile
		</td>
	</tr>
	<tr valign="middle">
		<td align="center" class="windowbg2">
		<form action="$adminurl?action=modtemp2" method="post" style="display: inline;">
		<textarea rows="20" cols="95" name="template" style="width:99%; height: 350px;">$fulltemplate</textarea>
		<input type="hidden" name="filename" value="$templatefile" />
		</td>
	</tr>
	<tr valign="middle">
		<td align="center" class="catbg">
		<input type="submit" value="$admin_txt{'10'} $templatefile" class="button" />
		</form>
		</td>
	</tr>
	<tr valign="middle">
		<td align="left" class="windowbg2">
		<div style="float: left; width: 30%; padding: 3px;"><label for="templatefile"><b>$templ_txt{'10'}</b></label></div>
		<div style="float: left; width: 69%;">
		<form action="$adminurl?action=modtemp" method="post" style="display: inline;">
		<select name="templatefile" id="templatefile" size="1" onchange="submit()">
		$templs
		</select>
		<noscript><input type="submit" value="$admin_txt{'32'}" class="button" /></noscript>
		</form>
		</div>
		</td>
	</tr>
   </table>
 </div>
~;
	$yytitle     = "$admin_txt{'216'}";
	$action_area = "modtemp";
	&AdminTemplate;
}

sub ModifyTemplate2 {
	&is_admin_or_gmod;
	$FORM{'template'} =~ tr/\r//d;
	$FORM{'template'} =~ s~\A\n~~;
	$FORM{'template'} =~ s~\n\Z~~;
	if ($FORM{'filename'}) { $templatefile = $FORM{'filename'}; }
	else { $templatefile = "default.html"; }
	fopen(TMPL, ">$templatesdir/$templatefile");

	print TMPL "$FORM{'template'}\n";
	fclose(TMPL);
	$yySetLocation = qq~$adminurl?action=modtemp;templatefile=$templatefile~;
	&redirectexit;
}

sub ModifyStyle {
	&is_admin_or_gmod;
	my ($fullcss, $line, $csstype);
	$admincs = 0;
	if ($FORM{'cssfile'}) { $cssfile = $FORM{'cssfile'}; $csstype = qq~$forumstylesdir/$cssfile~; }
	elsif ($FORM{'admcssfile'}) { $cssfile = $FORM{'admcssfile'}; $csstype = qq~$adminstylesdir/$cssfile~; $admincs = 1; }
	else { $cssfile = "default.css"; $csstype = qq~$forumstylesdir/$cssfile~; }
	opendir(TMPLDIR, "$forumstylesdir");
	@styles = readdir(TMPLDIR);
	closedir(TMPLDIR);
	$forumcss = "";
	$forumcss = qq~<option value=""></option>\n~;

	foreach $file (sort @styles) {
		($name, $ext) = split(/\./, $file);
		$selected = "";
		if ($ext eq 'css') {
			if ($file eq $cssfile && !$admincs) { $selected = qq~ selected="selected"~; }
			$forumcss .= qq~<option value="$file"$selected>$name</option>\n~;
		}
	}

	opendir(TMPLDIR, "$adminstylesdir");
	@astyles = readdir(TMPLDIR);
	closedir(TMPLDIR);
	$admincss = "";
	$admincss = qq~<option value=""></option>\n~;
	foreach $file (sort @astyles) {
		($name, $ext) = split(/\./, $file);
		$selected = "";
		if ($ext eq 'css') {
			if ($file eq $cssfile && $admincs) { $selected = qq~ selected="selected"~; }
			$admincss .= qq~<option value="$file"$selected>$name</option>\n~;
		}
	}

	fopen(CSS, "$csstype") or &admin_fatal_error("cannot_open","$csstype");
	while ($line = <CSS>) {
		$line =~ s~[\r\n]~~g;
		$line =~ s~&nbsp;~&#38;nbsp;~g;
		$line =~ s~&amp;~&#38;amp;~g;
		&FromHTML($line);
		$fullcss .= qq~$line\n~;
	}
	fclose(CSS);

	$yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
	<form action="$adminurl?action=modcss;cssfile=$cssfile" name="modcss" method="post" style="display: inline;">
	<tr>
		<td align="left" valign="middle" class="titlebg">
		<img src="$imagesdir/xx.gif" alt="" border="0" /><b> $templ_txt{'51'}</b> - $cssfile &nbsp;
		<input type="submit" name="wysiwyg" id="wysiwyg" value="wysiwyg" class="button" />
		<input type="button" name="source" id="source" value=" source " disabled="disabled" />
		</td>
	</tr>
	</form>
	<form action="$adminurl?action=modstyle2" method="post">
	<tr valign="middle">
		<td align="center" class="windowbg2">
		<input type="hidden" name="filename" value="$cssfile" />
		<input type="hidden" name="type" value="$admincs" />
		<textarea rows="20" cols="95" name="css" style="width: 99%; height: 350px;">$fullcss</textarea>
		</td>
	</tr>
	<tr valign="middle">
		<td align="center" class="catbg">
		<input type="submit" value="$admin_txt{'10'} $cssfile" class="button" />
		</td>
	</tr>
	</form>
	<tr>
		<td align="left" class="windowbg2">
		<div style="float: left; width: 30%; padding: 3px;"><b>$templ_txt{'1'}</b></div>
		<div style="float: left; width: 69%;">
		<form action="$adminurl?action=modstyle" name="selcss" method="post" style="display: inline;">
		<div class="small" style="float: left; width: 25%;"><label for="cssfile">$templ_txt{'forum'}:</label><br />
		  <select name="cssfile" id="cssfile" size="1" style="width: 90%;" onchange="if(this.options[this.selectedIndex].value) { document.aselcss.admcssfile.selectedIndex = '0'; submit(); }">
			$forumcss
		  </select><br />
		<noscript><input type="submit" value="$admin_txt{'32'}" style="width: 90%;" class="button" /></noscript>
		</div>
		</form>
		<form action="$adminurl?action=modstyle" name="aselcss" method="post" style="display: inline;">
		<div class="small" style="float: left; width: 25%;"><label for="admcssfile">$templ_txt{'admincenter'}:</label><br />
		  <select name="admcssfile" id="admcssfile" size="1" style="width: 90%;" onchange="if(this.options[this.selectedIndex].value) { document.selcss.cssfile.selectedIndex = '0'; submit(); }">
			$admincss
		  </select><br />
		<noscript><input type="submit" value="$admin_txt{'32'}" style="width: 90%;" class="button" /></noscript>
		</div>
		</form>
		</div>
		</td>
	</tr>
   </table>
 </div>
~;
	$yytitle = $templ_txt{'1'};
	$action_area = "modcss";
	&AdminTemplate;
}

sub ModifyStyle2 {
	&is_admin_or_gmod;
	$FORM{'css'} =~ tr/\r//d;
	$FORM{'css'} =~ s~\A\n~~;
	$FORM{'css'} =~ s~\n\Z~~;

	if ($FORM{'filename'}) { $cssfile = $FORM{'filename'}; }
	else { $cssfile = "default.css"; }
	if ($FORM{'type'}) {
		fopen(CSS, ">$adminstylesdir/$cssfile") || &admin_fatal_error("cannot_open","$adminstylesdir/$cssfile", 1);
	} else {
		fopen(CSS, ">$forumstylesdir/$cssfile") || &admin_fatal_error("cannot_open","$forumstylesdir/$cssfile", 1);
	}
	print CSS "$FORM{'css'}\n";
	fclose(CSS);
	$yySetLocation = qq~$adminurl?action=modcss;cssfile=$cssfile~;
	&redirectexit;
}

sub ModifyCSS {
	&is_admin_or_gmod;

	if ($INFO{'templateset'}) { $thistemplate = $INFO{'templateset'}; }
	else { $thistemplate = "$template"; }

	while (($curtemplate, $value) = each(%templateset)) {
		if ($curtemplate eq $thistemplate) { $akttemplate = $curtemplate; }
	}

	($aktstyle, $aktimages, $akthead, $aktboard, $aktmessage, $aktdisplay) = split(/\|/, $templateset{"$akttemplate"});

	my ($fullcss, $line);
	if ($INFO{'cssfile'}) { $cssfile = $INFO{'cssfile'}; }
	else { $cssfile = "$aktstyle.css"; }

	$tempimages = qq~$forumstylesurl/$aktimages~;
	my $istabbed = 0;

	$stylestr = "";

	opendir(TMPLDIR, "$forumstylesdir");
	@styles = readdir(TMPLDIR);
	closedir(TMPLDIR);
	$forumcss = "";
	$imgdirs  = "";
	foreach $file (sort @styles) {
		($name, $ext) = split(/\./, $file);
		$selected = "";
		if ($ext eq 'css') {
			if ($file eq $cssfile) { $selected = qq~ selected="selected"~; $viewcss = $name; }
			$forumcss .= qq~<option value="$file"$selected>$name</option>\n~;
		}
	}

	fopen(CSS, "$forumstylesdir/$cssfile") or &admin_fatal_error("cannot_open","$forumstylesdir/$cssfile");
	@thecss = <CSS>;
	fclose(CSS);
	foreach $style_sgl (@thecss) {
		$style_sgl =~ s/[\n\r]//g;
		$style_sgl =~ s/\A\s*//;
		$style_sgl =~ s/\s*\Z//;
		$style_sgl =~ s/\t//g;
		$style_sgl =~ s/\.\/default/$forumstylesurl\/default/g;
		$style_sgl =~ s/\.\/$viewcss/$forumstylesurl\/$viewcss/g;
		$stylestr .= qq~$style_sgl ~;
	}
	$stylestr =~ s/\s{2,}/ /g;
	my ($selstyl, $selhidden, $postsstyle, $seperatorstyle, $bodycontainerstyle, $bodystyle, $containerstyle, $titlestyle, $titlestyle_a, $categorystyle, $categorystyle_a, $window1style, $window2style, $inputstyle, $textareastyle, $selectstyle, $quotestyle, $codestyle, $editbgstyle, $highlightstyle,$gen_fontsize);

	$gen_fontsize = qq~<select name="cssfntsize" id="cssfntsize" style="vertical-align: middle;" onchange="previewFont()">~;
	for ($i = 7; $i < 21; $i++) {
		$gen_fontsize .= qq~<option value="$i">$i</option>~;
	}
	$gen_fontsize .= qq~</select>~;
	$gen_fontface = qq~<select name="cssfntface" id="cssfntface" style="vertical-align: middle;" onchange="previewFontface()">
		<option value="verdana">Verdana</option>
		<option value="helvetica">Helvetica</option>
		<option value="arial">Arial</option>
		<option value="courier">Courier</option>
		<option value="courier new">Courier New</option>
	</select>~;
	$gen_borderweigth = qq~<select name="borderweigth" id="borderweigth" style="vertical-align: middle;" onchange="previewBorder()">~;
	for ($i = 0; $i < 6; $i++) {
		$gen_borderweigth .= qq~<option value="$i">$i</option>~;
	}
	$gen_borderweigth .= qq~</select>~;
	$gen_borderstyle = qq~<select name="borderstyle" id="borderstyle" style="vertical-align: middle;" onchange="previewBorder()">
		<option value="solid">$templ_txt{'43'}</option>
		<option value="dashed">$templ_txt{'44'}</option>
		<option value="dotted">$templ_txt{'45'}</option>
		<option value="double">$templ_txt{'46'}</option>
		<option value="groove">$templ_txt{'47'}</option>
		<option value="ridge">$templ_txt{'48'}</option>
		<option value="inset">$templ_txt{'49'}</option>
		<option value="outset">$templ_txt{'50'}</option>
	</select>~;

	if ($stylestr =~ /body/) {
		$bodystyle = $stylestr;
		$bodystyle =~ s/.*?(body\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$bodystyle' selected="selected">$templ_txt{'25'}</option>\n~;
	}
	if ($stylestr =~ /\#container/) {
		$containerstyle = $stylestr;
		$containerstyle =~ s/.*?(\#container\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$containerstyle'>$templ_txt{'26'}</option>\n~;
	}
	if ($stylestr =~ /\.tabmenu/) {
		$istabbed = 1;
	}
	if ($stylestr =~ /\.tabtitle/ && $istabbed) {
		$tabtitlestyle = $stylestr;
		$tabtitlestyle =~ s/.*?(\.tabtitle\s*?\{.+?\}).*/$1/ig;
		$tabtitlestyle = $tabtitlestyle;
		$selstyl .= qq~<option value='$tabtitlestyle'>$templ_txt{'tabtitle'}</option>\n~;
		if ($stylestr =~ /\.tabtitle a/) {
			$tabtitlestyle_a = $stylestr;
			$tabtitlestyle_a =~ s/.*?(\.tabtitle a\s*?\{.+?\}).*/$1/ig;
			$selstyl .= qq~<option value='$tabtitlestyle_a'>$templ_txt{'tabtitlea'}</option>\n~;
		}
	}
	if ($stylestr =~ /\.seperator/) {
		$seperatorstyle = $stylestr;
		$seperatorstyle =~ s/.*?(\.seperator\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$seperatorstyle'>$templ_txt{'27'}</option>\n~;
	}
	if ($stylestr =~ /\.bordercolor/) {
		$bordercolorstyle = $stylestr;
		$bordercolorstyle =~ s/.*?(\.bordercolor\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$bordercolorstyle'>$templ_txt{'28'}</option>\n~;
	}
	if ($stylestr =~ /\.hr/) {
		$hrstyle = $stylestr;
		$hrstyle =~ s/.*?(\.hr\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$hrstyle'>$templ_txt{'29'}</option>\n~;
	}
	if ($stylestr =~ /\.titlebg/) {
		$titlestyle = $stylestr;
		$titlestyle =~ s/.*?(\.titlebg\s*?\{.+?\}).*/$1/ig;
		$titlestyle = $titlestyle;
		$selstyl .= qq~<option value='$titlestyle'>$templ_txt{'30'}</option>\n~;
		if ($stylestr =~ /\.titlebg a/) {
			$titlestyle_a = $stylestr;
			$titlestyle_a =~ s/.*?(\.titlebg a\s*?\{.+?\}).*/$1/ig;
			$selstyl .= qq~<option value='$titlestyle_a'>$templ_txt{'30a'}</option>\n~;
		}
	}
	if ($stylestr =~ /\.catbg/) {
		$categorystyle = $stylestr;
		$categorystyle =~ s/.*?(\.catbg\s*?\{.+?\}).*/$1/ig;
		$categorystyle = $categorystyle;
		$selstyl .= qq~<option value='$categorystyle'>$templ_txt{'31'}</option>\n~;
		if ($stylestr =~ /\.catbg a/) {
			$categorystyle_a = $stylestr;
			$categorystyle_a =~ s/.*?(\.catbg a\s*?\{.+?\}).*/$1/ig;
			$selstyl .= qq~<option value='$categorystyle_a'>$templ_txt{'31a'}</option>\n~;
		}
	}
	if ($stylestr =~ /\.windowbg/) {
		$window1style = $stylestr;
		$window1style =~ s/.*?(\.windowbg\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$window1style'>$templ_txt{'32'}</option>\n~;
	}
	if ($stylestr =~ /\.windowbg2/) {
		$window2style = $stylestr;
		$window2style =~ s/.*?(\.windowbg2\s*?\{.+?\}).*/$1/ig;
		$windowcol2 = $window2style;
		$windowcol2 =~ s/.*?(\#[a-f0-9]{3,6}).*/$1/i;
		$selstyl .= qq~<option value='$window2style'>$templ_txt{'33'}</option>\n~;
	}
	if ($stylestr =~ /\.message/) {
		$postsstyle = $stylestr;
		$postsstyle =~ s/.*?(\.message\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$postsstyle'>$templ_txt{'65'}</option>\n~;

		if ($stylestr =~ /\.message a/) {
			$postsstyle_a = $stylestr;
			$postsstyle_a =~ s/.*?(\.message a\s*?\{.+?\}).*/$1/ig;
			$selstyl .= qq~<option value='$postsstyle_a'>$templ_txt{'66'}</option>\n~;
		}
	}
	if ($stylestr =~ /input/) {
		$inputstyle = $stylestr;
		$inputstyle =~ s/.*?(input\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$inputstyle'>$templ_txt{'34a'}</option>\n~;
	}
	if ($stylestr =~ /button/) {
		$buttonstyle = $stylestr;
		$buttonstyle =~ s/.*?(button\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$buttonstyle'>$templ_txt{'34b'}</option>\n~;
	}
	if ($stylestr =~ /textarea/) {
		$textareastyle = $stylestr;
		$textareastyle =~ s/.*?(textarea\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$textareastyle'>$templ_txt{'35'}</option>\n~;
	}
	if ($stylestr =~ /select/) {
		$selectstyle = $stylestr;
		$selectstyle =~ s/.*?(select\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$selectstyle'>$templ_txt{'36'}</option>\n~;
	}
	if ($stylestr =~ /.quote/) {
		$quotestyle = $stylestr;
		$quotestyle =~ s/.*?(\.quote\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$quotestyle'>$templ_txt{'37'}</option>\n~;
		$message = qq~\[quote\]$templ_txt{'53'}\[/quote\]~;
		if ($enable_ubbc) {
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC;
		}
		$aquote = $message;
	}
	if ($stylestr =~ /.code/) {
		$codestyle = $stylestr;
		$codestyle =~ s/.*?(\.code\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$codestyle'>$templ_txt{'38'}</option>\n~;
		$message = qq~\[code\]$templ_txt{'54'}\[/code\]~;
		if ($enable_ubbc) {
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC;
		}
		$acode = $message;
	}
	if ($stylestr =~ /.editbg/) {
		$editbgstyle = $stylestr;
		$editbgstyle =~ s/.*?(\.editbg\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$editbgstyle'>$templ_txt{'24'}</option>\n~;
		$message = qq~\[edit\]$templ_txt{'55'}\[/edit\]~;
		if ($enable_ubbc) {
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC;
		}
		$aedit = $message;
	}
	if ($stylestr =~ /.highlight/) {
		$highlightstyle = $stylestr;
		$highlightstyle =~ s/.*?(\.highlight\s*?\{.+?\}).*/$1/ig;
		$selstyl .= qq~<option value='$highlightstyle'>$templ_txt{'39'}</option>\n~;
		$message = qq~\[highlight\]$templ_txt{'56'}\[/highlight\]~;
		if ($enable_ubbc) {
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
			&DoUBBC;
		}
		$ahighlight = $message;
	}
	if ($stylestr =~ /\.bodycontainer/) {
		$bodycontainerstyle = 1;
	}

	$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr>
		<td align="left" valign="middle" class="titlebg">
		<form action="$adminurl?action=modstyle" name="modstyles" id="modstyles" method="post">
		<img src="$imagesdir/xx.gif" alt="" border="0" style="vertical-align: middle;" /> <b>$templ_txt{'51'}</b> - $viewcss &nbsp;
		<input type="hidden" name="cssfile" value="$cssfile" />
		<input type="button" name="wysiwyg" id="wysiwyg" value="wysiwyg" disabled="disabled" />
		<input type="submit" name="source" id="source" value=" source " class="button" />
		</form>
		</td>
	</tr>
</table>
<form action="$adminurl?action=modcss2" name="allstyles" id="allstyles" method="post">
<table width="100%" cellspacing="1" cellpadding="0">
	<tr>
		<td class="windowbg2" align="center" valign="middle">
		<iframe id="StyleManager" name="StyleManager" width="100%" height="350" marginwidth="0" marginheight="0" frameborder="0" scrolling="yes" style="border-top: 1px inset; border-bottom: 1px inset; visibility: visible; display: inline"></iframe>
		</td>
	</tr>
</table>
<table width="100%" cellspacing="1" cellpadding="4">
	<tr>
		<td align="left" class="windowbg2">
		<div style="float: left; width: 30%; padding: 3px;"><label for="cssfile"><b>$templ_txt{'1'}</b></label></div>
		<div style="float: left; width: 69%;">
				<input type="hidden" name="button" value="0" />
				<select name="cssfile" id="cssfile" size="1" onchange="document.allstyles.button.value = '1'; submit();">
				$forumcss
				</select>
				<input type="button" value="$templ_txt{'14'}" onclick="document.allstyles.button.value = '3'; if (confirm('$templ_txt{'15'} $cssfile?')) submit();" />
		</div>
		</td>
	</tr>
	<tr>
		<td align="left" class="windowbg2">
		<div style="float: left; width: 30%; padding: 3px;">
			<label for="csselement"><b>$templ_txt{'18'}</b><br /><span class="small">$templ_txt{'19'}<br /><br /></span></label>
		</div>
		<div style="float: left; width: 69%;">
		<div style="float: left; text-align: center; margin-left: 0px; margin-right: 6px; vertical-align: middle;">
				<select name="csselement" id="csselement" size="5" onchange="setElement()">
				$selstyl
				</select>
		</div>
		<div style="float: left;">
			<div class="small" style="float: left; vertical-align: middle;">
				<span style="width: 70px;">
				<input type="radio" name="selopt" id="selopt1" value="color" class="windowbg2" style="border: 0px; vertical-align: middle;" onclick="manSelect();" /> <label for="selopt1"><span class="small" style="vertical-align: middle;"><b>$templ_txt{'22'}</b></span></label>
				</span>
				<span>
				<input type="text" size="9" name="textcol" id="textcol" value="$textcol" class="windowbg2" style="font-size: 10px; border: 1px #eef7ff solid; vertical-align: middle;" onchange="previewColor(this.value)" />
				$gen_fontface $gen_fontsize
				<img src="$imagesdir/cssbold.gif" border="0" alt="bold" name="cssbold" id="cssbold" style="border: 2px #eeeeee outset; vertical-align: middle;" onclick="previewFontweight()" />
				<img src="$imagesdir/cssitalic.gif" border="0" alt="italic" name="cssitalic" id="cssitalic" style="border: 2px #eeeeee outset; vertical-align: middle;" onclick="previewFontstyle()" />
				</span><br />
				<span style="width: 70px;">
				<input type="radio" name="selopt" id="selopt2" value="background-color" class="windowbg2" style="border: 0px; vertical-align: middle;" onclick="manSelect();" /> <label for="selopt2"><span class="small" style="vertical-align: middle;"><b>$templ_txt{'21'}</b></span></label>
				</span>
				<span>
				<input type="text" size="9" name="backcol" id="backcol" value="$backcol" class="windowbg2" style="font-size: 10px; border: 1px #eef7ff solid; vertical-align: middle;" onchange="previewColor(this.value)" />
				</span><br />
				<span style="width: 70px;">
				<input type="radio" name="selopt" id="selopt3" value="border" class="windowbg2" style="border: 0px; vertical-align: middle;" onclick="manSelect();" /> <label for="selopt3"><span class="small" style="vertical-align: middle;"><b>$templ_txt{'23'}</b></span></label>
				</span>
				<span>
				<input type="text" size="9" name="bordcol" id="bordcol" value="$bordcol" class="windowbg2" style="font-size: 10px; border: 1px #eef7ff solid; vertical-align: middle;" onchange="previewBorder()" />
				$gen_borderstyle $gen_borderweigth
				</span><br />
			</div>
			<div style="float: left; height: 68px; width: 92px; overflow: auto; border: 0px; margin-left: 8px;">
				<div style="float: left; height: 22px; width: 91px;">
					<div class="bordercolor" style="height: 20px; width: 66px; padding-left: 1px; padding-top: 1px; margin-top: 1px; float: left;">
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
						<img src="$imagesdir/palette1.gif" style="cursor: pointer" onclick="window.open('$scripturl?action=palette;task=templ', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" alt="" border="0" />
					</div>
				</div>
			</div>
		</div>
		</div>
		</td>
	</tr>
	~;

	$viewstylestart = qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>Test Styles</title>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
~;
	$viewstyle = qq~
<body>
<div id="maincontainer">
~;
	if ($containerstyle) {
		$viewstyle .= qq~
<div id="container">
~;
	}
	if ($istabbed) {
		$tabsep = qq~<img src="$imagesdir/tabsep211.png" border="0" alt="" style="float: left; vertical-align: middle;" />~;
		$tabfill = qq~<img src="$imagesdir/tabfill.gif" border="0" alt="" style="vertical-align: middle;" />~;
		$tabtime = &timeformat($date, 1);

		$viewstyle .= qq~
<table width="100%" cellpadding="0" cellspacing="0" border="0" class="menutop">
	<tr>
		<td class="small" align="left" valign="middle" width="2%" height="23">&nbsp;</td>
		<td class="small" align="left" valign="middle" width="98%" height="23">$tabtime</td>
	</tr>
</table>
<table class="windowbg2" width="100%" cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td align="left" valign="top" width="100%" height="30">&nbsp;</td>
	</tr>
</table>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td class="menutop" height="22" align="left">&nbsp;</td>
	</tr>
</table>
<table width="100%" cellpadding="0" cellspacing="0" border="0">

<tr>
	<td id="tabmnleft" class="tabmenuleft" width="40">&nbsp;</td>
	<td id="tabmn" class="tabmenu">
	<span class="selected"><a href="javascript:;">$tabfill$img_txt{'103'}$tabfill</a></span>
	$tabsep<span style="cursor:help;"><a href="javascript:;" style="cursor:help;">$tabfill$img_txt{'119'}$tabfill</a></span>
	$tabsep<span><a href="javascript:;">$tabfill$img_txt{'182'}$tabfill</a></span>
	$tabsep<span><a href="javascript:;">$tabfill$img_txt{'331'}$tabfill</a></span>
	$tabsep<span><a href="javascript:;">$tabfill$img_txt{'mycenter'}$tabfill</a></span>
	$tabsep<span><a href="javascript:;">$tabfill$img_txt{'108'}$tabfill</a></span>
	$tabsep
	</td>
	<td id="tabmnrss" class="tabmenu" width="40" valign="top"></td>
	<td id="tabmnright" class="tabmenuright" width="45">&nbsp;	</td>
	<td id="tabmnbox" class="rightbox" width="160" valign="top">
		<div style="float: left; width: 160px; height: 21px; text-align: center; padding-top: 3px; display: inline;">
		<input type="text" name="search" size="16" style="font-size: 11px; vertical-align: middle;" />
		<img src="$imagesdir/search.gif" style="border: 0; background-color: transparent; margin-right: 5px; vertical-align: middle;" />
		</div>
	</td>
</tr>
<tr>
	<td colspan="5"><br />&nbsp;</td>
</tr>
</table>
~;
	}
	if ($containerstyle) {
		$viewstyle .= qq~
  $templ_txt{'64'}
<br /><br />
~;
	}
	if ($bodycontainerstyle) {
		$viewstyle .= qq~<div class="bodycontainer">~;
	}
	if ($seperatorstyle) {
		$viewstyle .= qq~<div class="seperator">~;
	}
	if ($istabbed) {
		$viewstyle .= qq~
<table cellpadding="0" cellspacing="0" border="0" width="100%" class="bordercolor">
<tr>
	<td class="tabtitle" width="1%" height="25" align="left" valign="middle">
		&nbsp;
	</td>
	<td class="tabtitle" width="49%" height="25" align="left" valign="middle">
		$templ_txt{'tabtitle'}
	</td>
	<td class="tabtitle" width="50%" height="25" align="left" valign="middle">
		<a href="javascript:;">$templ_txt{'tabtitlea'}</a>
	</td>
</tr>
</table>
<br />
~;
	}
	$viewstyle .= qq~
<table class="bordercolor" cellpadding="4" cellspacing="1" border="0" width="100%">
<tr>
<td id="title" class="titlebg" width="50%" align="left" valign="middle">
$templ_txt{'30'}
</td>
<td id="titlea" class="titlebg" width="50%" align="left" valign="middle">
<a href="javascript:;">$templ_txt{'30a'}</a>
</td>
</tr>
</table>
~;
	if ($seperatorstyle) {
		$viewstyle .= qq~</div>~;
	}
	$viewstyle .= qq~
<br />
~;
	if ($seperatorstyle) {
		$viewstyle .= qq~<div class="seperator">~;
	}
	$viewstyle .= qq~
<table class="bordercolor" cellpadding="4" cellspacing="1" border="0" width="100%">
<tr>
<td id="category" class="catbg" width="50%" align="left" valign="middle">
$templ_txt{'31'}
</td>
<td id="categorya" class="catbg" width="50%" align="left" valign="middle">
<a href="javascript:;">$templ_txt{'31a'}</a>
</td>
</tr>
</table>

<table class="bordercolor" cellpadding="4" cellspacing="1" border="0" width="100%">
<tr>
<td id="window1" class="windowbg" align="left" valign="top">
$templ_txt{'32'}
</td>
<td id="window2" class="windowbg2" align="left" valign="top">
$templ_txt{'33'}<br />
<hr class="hr">
<div id="messages" class="message">$templ_txt{'65'}</div>
<div id="messagesa" class="message"><a href="javascript:;">$templ_txt{'66'}</a><br /><br /></div>
<textarea rows="4" cols="19">$templ_txt{'35'}</textarea><br />
<input type="text" size="19" value="$templ_txt{'34a'}" />&nbsp;
<select value="test">
<option>$templ_txt{'36'} $templ_txt{'61'}</option>
<option>$templ_txt{'36'} 2</option>
</select>&nbsp;
<input type="button" value="$templ_txt{'34b'}" class="button" />
</td>
</tr>
<tr>
<td id="window1" class="windowbg" align="left" valign="top">
&nbsp;
</td>
<td id="window2" class="windowbg2" align="left" valign="top">
$aquote
$acode
$aedit<br />
$ahighlight
</td>
</tr>
</table>
~;
	if ($seperatorstyle) {
		$viewstyle .= qq~</div>~;
	}
	if ($bodycontainerstyle) {
		$viewstyle .= qq~</div>~;
	}
	if($istabbed) {
$viewstyle .= qq~
		<br />
		<div class="mainbottom">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td class="nav" height="22" width="100%" align="left">&nbsp;</td>
			</tr>
		</table>
		</div>
~;
	}
	if ($containerstyle) {
		$viewstyle .= qq~</div>~;
	}
	$viewstyle .= qq~
<br /><br />
</div>
</body>
</html>~;

	$viewstylestart =~ s~[\n\r]~~g;
	&ToHTML($viewstylestart);
	$stylestr =~ s~[\n\r]~~g;
	&ToHTML($stylestr);
	$viewstyle =~ s~[\n\r]~~g;
	&ToHTML($viewstyle);

	$yymain .= qq~
	<tr valign="middle">
		<td align="left" class="windowbg2">
		<input type="hidden" name="stylestart" value="$viewstylestart" />
		<input type="hidden" name="stylelink" value="$stylestr" />
		<input type="hidden" name="stylebody" value="$viewstyle" />
		<div style="float: left; width: 30%; padding: 3px;"><label for="savecssas"><b>$templ_txt{'12'}</b></label></div>
		<div style="float: left; width: 69%;">
			<input type="text" name="savecssas" id="savecssas" value="~ . (split(/\./, $cssfile))[0] . qq~" size="30" maxlength="30" />
			<input type="submit" value="$templ_txt{'13'}" onclick="document.allstyles.button.value = '2';" class="button" />
		</div>
		</td>
	</tr>
</table>
</form>
</div>

<script type="text/javascript" language="JavaScript">
<!--
var cssbold;
var cssitalic;
var stylesurl = '$forumstylesurl';

function initStyles() {
	var thestylestart = document.allstyles.stylestart.value;
	var thestyles = document.allstyles.stylelink.value;
	var thestylebody = document.allstyles.stylebody.value;
	var thestyle = thestylestart + '\\<style type="text/css"\\>\\<\\!\\-\\-' + thestyles + '\\-\\-\\>\\<\\/style\\>' + thestylebody;
	thestyle=thestyle.replace(/\\&quot\\;/g, '"');
	thestyle=thestyle.replace(/\\&nbsp\\;/g, " ");
	thestyle=thestyle.replace(/\\&\\#124\\;/g, "|");
	thestyle=thestyle.replace(/\\&lt\\;/g, "<");
	thestyle=thestyle.replace(/\\&gt\\;/g, ">");
	thestyle=thestyle.replace(/\\&amp\\;/g, "&");
	thestyle=thestyle.replace(/(url\\(\\")(.*?\\/.*?\\"\\))/gi, "\$1" + stylesurl + "\/\$2");
	StyleManager.document.open("text/html");
	StyleManager.document.write(thestyle);
	StyleManager.document.close();
}

function updateStyles() {
	var currentTop = document.getElementById('StyleManager').contentWindow.document.documentElement.scrollTop;
	initStyles();
	document.getElementById('StyleManager').contentWindow.document.documentElement.scrollTop = currentTop;
}

function previewColor(thecolor) {
	thenewstyle = document.allstyles.stylelink.value;
	cssoption = document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value;
	var cssfont = document.allstyles.selopt1;
	var cssback = document.allstyles.selopt2;
	var cssborder = document.allstyles.selopt3;
	if(cssfont.checked) {
		newcssoption=cssoption.replace(/( color\\s*?\\:).+?(\\;)/i, "\$1 " + thecolor + "\$2");
		document.allstyles.textcol.value = thecolor;
		if(cssoption.match(/\\#container\\s*?\\{/)) {
			thenewstyle=thenewstyle.replace(/(\\.tabmenu span a\\s*?\\{.*?color\\s*?\\:).+?(\\;)/ig, "\$1 " + thecolor + "\$2");
		}
	}
	if(cssback.checked) {
		newcssoption=cssoption.replace(/(background-color\\s*?\\:).+?(\\;)/i, "\$1 " + thecolor + "\$2");
		document.allstyles.backcol.value = thecolor;
		if(cssoption.match(/\\#container\\s*?\\{/)) {
			thenewstyle=thenewstyle.replace(/(\\.tabmenu.*?\\{.*?background-color\\s*?\\:).+?(\\;)/ig, "\$1 " + thecolor + "\$2");
			thenewstyle=thenewstyle.replace(/(\\.menutop.*?\\{.*?background-color\\s*?\\:).+?(\\;)/ig, "\$1 " + thecolor + "\$2");
			thenewstyle=thenewstyle.replace(/(\\.mainbottom.*?\\{.*?background-color\\s*?\\:).+?(\\;)/ig, "\$1 " + thecolor + "\$2");
			thenewstyle=thenewstyle.replace(/(\\.rightbox.*?\\{.*?background-color\\s*?\\:).+?(\\;)/ig, "\$1 " + thecolor + "\$2");
		}
	}
	if(cssborder.checked) {
		tempnewcolor=cssoption;

		if(tempnewcolor.match(/border\\s*?\\:/)) {
			bordercol=tempnewcolor.replace(/.*?border\\s*?\\:(.+?)\\;.*/, "\$1");
			if(bordercol.match(/\\#[0-9a-f]{3,6}/i)) {
				tempnewcolor=tempnewcolor.replace(/(border\\s*?\\:.*?)\\#[0-9a-f]{3,6}(.*?\\;)/i, "\$1 " + thecolor + "\$2");
				viewnewcolor=tempnewcolor.replace(/.*?border\\s*?\\:(.*?)\\;.*/i, "\$1");
			}
		}
		if(tempnewcolor.match(/border\\-top\\s*?\\:/)) {
			bordertopcol=tempnewcolor.replace(/.*?border\\-top\\s*?\\:(.+?)\\;.*/, "\$1");
			if(bordertopcol.match(/\\#[0-9a-f]{3,6}/i)) {
				tempnewcolor=tempnewcolor.replace(/(border\\-top\\s*?\\:.*?)\\#[0-9a-f]{3,6}(.*?\\;)/i, "\$1 " + thecolor + "\$2");
				viewnewcolor=tempnewcolor.replace(/.*?border\\-top\\s*?\\:(.*?)\\;.*/i, "\$1");
			}
		}
		if(tempnewcolor.match(/border\\-bottom\\s*?\\:/)) {
			borderbottomcol=tempnewcolor.replace(/.*?border\\-bottom\\s*?\\:(.+?)\\;.*/, "\$1");
			if(borderbottomcol.match(/\\#[0-9a-f]{3,6}/i)) {
				tempnewcolor=tempnewcolor.replace(/(border\\-bottom\\s*?\\:.*?)\\#[0-9a-f]{3,6}(.*?\\;)/i, "\$1 " + thecolor + "\$2");
				viewnewcolor=tempnewcolor.replace(/.*?border\\-bottom\\s*?\\:(.*?)\\;.*/i, "\$1");
			}
		}
		if(tempnewcolor.match(/border\\-left\\s*?\\:/)) {
			borderleftcol=tempnewcolor.replace(/.*?border\\-left\\s*?\\:(.+?)\\;.*/, "\$1");
			if(borderleftcol.match(/\\#[0-9a-f]{3,6}/i)) {
				tempnewcolor=tempnewcolor.replace(/(border\\-left\\s*?\\:.*?)\\#[0-9a-f]{3,6}(.*?\\;)/i, "\$1 " + thecolor + "\$2");
				viewnewcolor=tempnewcolor.replace(/.*?border\\-left\\s*?\\:(.*?)\\;.*/i, "\$1");
			}
		}
		if(tempnewcolor.match(/border\\-right\\s*?\\:/)) {
			borderrightcol=tempnewcolor.replace(/.*?border\\-right\\s*?\\:(.+?)\\;.*/, "\$1");
			if(borderrightcol.match(/\\#[0-9a-f]{3,6}/i)) {
				tempnewcolor=tempnewcolor.replace(/(border\\-right\\s*?\\:.*?)\\#[0-9a-f]{3,6}(.*?\\;)/i, "\$1 " + thecolor + "\$2");
				viewnewcolor=tempnewcolor.replace(/.*?border\\-right\\s*?\\:(.*?)\\;.*/i, "\$1");
			}
		}
		newcssoption=tempnewcolor;
		nocolor=viewnewcolor.replace(/(.*?)\\#[0-9a-f]{3,6}(.*)/i, "\$1\$2");
		theborderstyle=viewnewcolor.replace(/(.*?)(solid|dashed|dotted|double|groove|ridge|inset|outset)(.*)/i, "\$2");
		thebordersize=nocolor.replace(/.*?([\\d]{1,2}).*/i, "\$1");
		document.allstyles.bordcol.value = thecolor;
	}
	document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value = newcssoption;
	re=cssoption.replace(/(.*)/, "\$1");
	thenewstyle=thenewstyle.replace(re, newcssoption);
	document.allstyles.stylelink.value = thenewstyle;
	updateStyles();
}

function previewBorder() {
	thenewstyle = document.allstyles.stylelink.value;
	cssoption = document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value;
	var cssborder = document.allstyles.selopt3;
	var thebweigth = document.allstyles.borderweigth.value;
	var thebcolor = document.allstyles.bordcol.value;
	var thebstyle = document.allstyles.borderstyle.value;
	var thecolor = thebweigth + 'px ' + thebcolor + ' ' + thebstyle;
	if(cssborder.checked) {
		tempnewcolor=cssoption;
		if(tempnewcolor.match(/border\\s*?\\:/)) {
			bordercol=tempnewcolor.replace(/.*?border\\s*?\\:(.+?)\\;.*/, "\$1");
			if(bordercol.match(/\\#[0-9a-f]{3,6}/i)) {
				tempnewcolor=tempnewcolor.replace(/(border\\s*?\\:).*?\\#[0-9a-f]{3,6}.*?(\\;)/i, "\$1 " + thecolor + "\$2");
				viewnewcolor=tempnewcolor.replace(/.*?border\\s*?\\:(.*?)\\;.*/i, "\$1");
			}
		}
		if(tempnewcolor.match(/border\\-top\\s*?\\:/)) {
			bordertopcol=tempnewcolor.replace(/.*?border\\-top\\s*?\\:(.+?)\\;.*/, "\$1");
			if(bordertopcol.match(/\\#[0-9a-f]{3,6}/i)) {
				tempnewcolor=tempnewcolor.replace(/(border\\-top\\s*?\\:).*?\\#[0-9a-f]{3,6}.*?(\\;)/i, "\$1 " + thecolor + "\$2");
				viewnewcolor=tempnewcolor.replace(/.*?border\\-top\\s*?\\:(.*?)\\;.*/i, "\$1");
			}
		}
		if(tempnewcolor.match(/border\\-bottom\\s*?\\:/)) {
			borderbottomcol=tempnewcolor.replace(/.*?border\\-bottom\\s*?\\:(.+?)\\;.*/, "\$1");
			if(borderbottomcol.match(/\\#[0-9a-f]{3,6}/i)) {
				tempnewcolor=tempnewcolor.replace(/(border\\-bottom\\s*?\\:).*?\\#[0-9a-f]{3,6}.*?(\\;)/i, "\$1 " + thecolor + "\$2");
				viewnewcolor=tempnewcolor.replace(/.*?border\\-bottom\\s*?\\:(.*?)\\;.*/i, "\$1");
			}
		}
		if(tempnewcolor.match(/border\\-left\\s*?\\:/)) {
			borderleftcol=tempnewcolor.replace(/.*?border\\-left\\s*?\\:(.+?)\\;.*/, "\$1");
			if(borderleftcol.match(/\\#[0-9a-f]{3,6}/i)) {
				tempnewcolor=tempnewcolor.replace(/(border\\-left\\s*?\\:).*?\\#[0-9a-f]{3,6}.*?(\\;)/i, "\$1 " + thecolor + "\$2");
				viewnewcolor=tempnewcolor.replace(/.*?border\\-left\\s*?\\:(.*?)\\;.*/i, "\$1");
			}
		}
		if(tempnewcolor.match(/border\\-right\\s*?\\:/)) {
			borderrightcol=tempnewcolor.replace(/.*?border\\-right\\s*?\\:(.+?)\\;.*/, "\$1");
			if(borderrightcol.match(/\\#[0-9a-f]{3,6}/i)) {
				tempnewcolor=tempnewcolor.replace(/(border\\-right\\s*?\\:).*?\\#[0-9a-f]{3,6}.*?(\\;)/i, "\$1 " + thecolor + "\$2");
				viewnewcolor=tempnewcolor.replace(/.*?border\\-right\\s*?\\:(.*?)\\;.*/i, "\$1");
			}
		}
		newcssoption=tempnewcolor;

		nocolor=viewnewcolor.replace(/(.*?)\\#[0-9a-f]{3,6}(.*)/i, "\$1\$2");
		theborderstyle=viewnewcolor.replace(/(.*?)(solid|dashed|dotted|double|groove|ridge|inset|outset)(.*)/i, "\$2");
		thebordersize=nocolor.replace(/.*?([\\d]{1,2}).*/i, "\$1");
		document.allstyles.bordcol.value = thebcolor;
	}
	document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value = newcssoption;
	re=cssoption.replace(/(.*)/, "\$1");
	thenewstyle=thenewstyle.replace(re, newcssoption);
	document.allstyles.stylelink.value = thenewstyle;
	updateStyles();
}

function previewFont() {
	thesize = document.allstyles.cssfntsize.options[document.allstyles.cssfntsize.selectedIndex].value;
	thenewstyle = document.allstyles.stylelink.value;
	cssoption = document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value;
	newcssoption=cssoption.replace(/(font\\-size\\s*?\\:\\s*?)[\\d]{1,2}(\\w+?\;)/i, "\$1" + thesize + "\$2");
	document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value = newcssoption;
	re=cssoption.replace(/(.*)/, "\$1");
	thenewstyle=thenewstyle.replace(re, newcssoption);
	document.allstyles.stylelink.value = thenewstyle;
	updateStyles();
}

function previewFontface() {
	theface = document.allstyles.cssfntface.options[document.allstyles.cssfntface.selectedIndex].value;
	thenewstyle = document.allstyles.stylelink.value;
	cssoption = document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value;
	thetmpfontface=cssoption.replace(/.*?font\\-family\\s*?\\:\\s*?([\\D]+?)\\;.*?\\}/i, "\$1");
	thearrfontface=thetmpfontface.split(",");
	optnumb=thearrfontface.length;
	newfontarr = theface;
	for(i = 0; i < optnumb; i++) {
		thefontface = thearrfontface[i].toLowerCase();
		thefontface=thefontface.replace(/^\\s/g, "");
		thefontface=thefontface.replace(/\\s\$/g, "");
		if(thefontface != theface) newfontarr += ', ' + thefontface;
	}
	newcssoption=cssoption.replace(/(font\\-family\\s*?\\:).*?(\;)/i, "\$1 " + newfontarr + "\$2");
	document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value = newcssoption;
	re=cssoption.replace(/(.*)/, "\$1");
	thenewstyle=thenewstyle.replace(re, newcssoption);
	document.allstyles.stylelink.value = thenewstyle;
	updateStyles();
}

function previewFontweight() {
	if(cssbold == false) return;
	thenewstyle = document.allstyles.stylelink.value;
	cssoption = document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value;
	thetmpfontweight=cssoption.replace(/.*?font\\-weight\\s*?\\:\\s*?([\\D]+?)\\;.*/i, "\$1");
	thetmpfontweight=thetmpfontweight.replace(/\\s/g, "");
	if(thetmpfontweight == 'normal') {
		thefontweight = 'bold';
		document.getElementById('cssbold').style.borderStyle = 'inset';
	}
	else {
		thefontweight = 'normal';
		document.getElementById('cssbold').style.borderStyle = 'outset';
	}
	newcssoption=cssoption.replace(/(font\\-weight\\s*?\\:).*?(\;)/ig, "\$1 " + thefontweight + "\$2");
	document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value = newcssoption;
	re=cssoption.replace(/(.*)/, "\$1");
	thenewstyle=thenewstyle.replace(re, newcssoption);
	document.allstyles.stylelink.value = thenewstyle;
	updateStyles();
}

function previewFontstyle() {
	if(cssitalic == false) return;
	thenewstyle = document.allstyles.stylelink.value;
	cssoption = document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value;
	thetmpfontstyle=cssoption.replace(/.*?font\\-style\\s*?\\:\\s*?([\\D]+?)\\;.*/i, "\$1");
	thetmpfontstyle=thetmpfontstyle.replace(/\\s/g, "");
	if(thetmpfontstyle == 'normal') {
		thefontstyle = 'italic';
		document.getElementById('cssitalic').style.borderStyle = 'inset';
	}
	else {
		thefontstyle = 'normal';
		document.getElementById('cssitalic').style.borderStyle = 'outset';
	}
	newcssoption=cssoption.replace(/(font\\-style\\s*?\\:).*?(\;)/ig, "\$1 " + thefontstyle + "\$2");
	document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value = newcssoption;
	re=cssoption.replace(/(.*)/, "\$1");
	thenewstyle=thenewstyle.replace(re, newcssoption);
	document.allstyles.stylelink.value = thenewstyle;
	updateStyles();
}

function manSelect() {
	var cssfont = document.allstyles.selopt1;
	var cssback = document.allstyles.selopt2;
	var cssborder = document.allstyles.selopt3;
	document.allstyles.textcol.disabled = true;
	document.allstyles.backcol.disabled = true;
	document.allstyles.bordcol.disabled = true;
	document.allstyles.borderweigth.disabled = true;
	document.allstyles.borderstyle.disabled = true;
	if(cssfont.checked == true) {
		document.allstyles.textcol.disabled = false;
	}
	if(cssback.checked == true) {
		document.allstyles.backcol.disabled = false;
	}
	if(cssborder.checked == true) {
		document.allstyles.bordcol.disabled = false;
		document.allstyles.borderweigth.disabled = false;
		document.allstyles.borderstyle.disabled = false;
	}
}

function setElement() {
	cssbold = false;
	cssitalic = false;

	tempcssoption = document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value;
	tmpcssoption = tempcssoption.split("{");

	document.modstyles.wysiwyg.disabled = true;

	document.allstyles.cssfntsize.disabled = true;
	document.allstyles.cssfntface.disabled = true;
	document.getElementById('cssbold').style.backgroundColor = '#cccccc';
	document.getElementById('cssbold').style.borderStyle = 'outset';
	document.getElementById('cssitalic').style.backgroundColor = '#cccccc';
	document.getElementById('cssitalic').style.borderStyle = 'outset';

	var cssfont = document.allstyles.selopt1;
	var cssback = document.allstyles.selopt2;
	var cssborder = document.allstyles.selopt3;
	cssfont.checked = false;
	cssback.checked = false;
	cssborder.checked = false;
	cssfont.disabled = true;
	cssback.disabled = true;
	cssborder.disabled = true;

	if(tmpcssoption[1].match(/font\-size/g)) {
		cssfont.disabled = false;
		document.allstyles.cssfntsize.disabled = false;
		thefontsize=tmpcssoption[1].replace(/.*?font\\-size\\s*?\\:\\s*?([\\d]{1,2})\\w+?\\;.*/, "\$1");
		if(!thefontsize) thesel=0;
		else thesel=thefontsize-7;
		document.allstyles.cssfntsize.value = document.allstyles.cssfntsize.options[thesel].value;
	}
	if(tmpcssoption[1].match(/font\-family/g)) {
		cssfont.disabled = false;
		document.allstyles.cssfntface.disabled = false;
		optnumb=document.allstyles.cssfntface.options.length;
		thetmpfontface=tmpcssoption[1].replace(/.*?font\\-family\\s*?\\:\\s*?([\\D]+?)\\;.*/i, "\$1");
		thearrfontface=thetmpfontface.split(",", 1);
		thefontface = thearrfontface[0].toLowerCase();
		thefontface=thefontface.replace(/^\\s/g, "");
		thefontface=thefontface.replace(/\\s\$/g, "");
		for(i = 0; i < optnumb; i++) {
			selfontface = document.allstyles.cssfntface.options[i].value;
			if(selfontface == thefontface) document.allstyles.cssfntface.value = selfontface;
		}
	}

	if(tmpcssoption[1].match(/font\-weight/g)) {
		cssbold = true;
		document.getElementById('cssbold').style.backgroundColor = '#ffffff';
		thetmpfontweight=tmpcssoption[1].replace(/.*?font\\-weight\\s*?\\:\\s*?([\\D]+?)\\;.*/i, "\$1");
		if(thetmpfontweight.match(/bold/)) document.getElementById('cssbold').style.borderStyle = 'inset';
	}

	if(tmpcssoption[1].match(/font\-style/g)) {
		cssitalic = true;
		document.getElementById('cssitalic').style.backgroundColor = '#ffffff';
		thetmpfontstyle=tmpcssoption[1].replace(/.*?font\\-style\\s*?\\:\\s*?([\\D]+?)\\;.*/i, "\$1");
		if(thetmpfontstyle.match(/italic/)) document.getElementById('cssitalic').style.borderStyle = 'inset';
	}

	if(tmpcssoption[1].match(/background\-color/g)) {
		cssback.disabled = false;
		thebackcolor=tmpcssoption[1].replace(/(.*?)background\\-color\\s*?\\:(.+?)\\;(.*)/i, "\$2");
		thebackcolor=thebackcolor.replace(/\\s/g, "");
		document.allstyles.backcol.value = thebackcolor;
	}
	else {
		document.allstyles.backcol.value = '';
	}
	if(tmpcssoption[1].match(/ color/g)) {
		cssfont.disabled = false;
		thefontcolor=tmpcssoption[1].replace(/(.*?) color\\s*?\\:(.+?)\\;(.*)/i, "\$2");
		thefontcolor=thefontcolor.replace(/\\s/g, "");
		document.allstyles.textcol.value = thefontcolor;
	}
	else {
		document.allstyles.textcol.value = '';
	}

	if(tmpcssoption[1].match(/border/)) {
		cssborder.disabled = false;
		document.allstyles.borderweigth.disabled = false;
		document.allstyles.borderstyle.disabled = false;
	}
	else {
		document.allstyles.borderweigth.disabled = true;
		document.allstyles.borderstyle.disabled = true;
	}
	viewnewcolor = '';

	if(tmpcssoption[1].match(/border\\s*?\\:/)) {
		bordercol=tmpcssoption[1].replace(/.*?border\\s*?\\:(.+?)\\;.*/, "\$1");
		if(bordercol.match(/\\#[0-9a-f]{3,6}/i)) {
			viewnewcolor=bordercol;
		}
	}
	if(tmpcssoption[1].match(/border\\-top\\s*?\\:/)) {
		bordertopcol=tmpcssoption[1].replace(/.*?border\\-top\\s*?\\:(.+?)\\;.*/, "\$1");
		if(bordertopcol.match(/\\#[0-9a-f]{3,6}/i)) {
			viewnewcolor=bordertopcol;
		}
	}
	if(tmpcssoption[1].match(/border\\-bottom\\s*?\\:/)) {
		borderbottomcol=tmpcssoption[1].replace(/.*?border\\-bottom\\s*?\\:(.+?)\\;.*/, "\$1");
		if(borderbottomcol.match(/\\#[0-9a-f]{3,6}/i)) {
			viewnewcolor=borderbottomcol;
		}
	}
	if(tmpcssoption[1].match(/border\\-left\\s*?\\:/)) {
		borderleftcol=tmpcssoption[1].replace(/.*?border\\-left\\s*?\\:(.+?)\\;.*/, "\$1");
		if(borderleftcol.match(/\\#[0-9a-f]{3,6}/i)) {
			viewnewcolor=borderleftcol;
		}
	}
	if(tmpcssoption[1].match(/border\\-right\\s*?\\:/)) {
		borderrightcol=tmpcssoption[1].replace(/.*?border\\-right\\s*?\\:(.+?)\\;.*/, "\$1");
		if(borderrightcol.match(/\\#[0-9a-f]{3,6}/i)) {
			viewnewcolor=borderrightcol;
		}
	}
	thebordercolor=viewnewcolor.replace(/.*?(\\#[0-9a-f]{3,6}).*/i, "\$1");
	nocolor=viewnewcolor.replace(/(.*?)(\\#[0-9a-f]{3,6})(.*)/i, "\$1\$3");
	optnumb=document.allstyles.borderstyle.options.length;
	theborderstyle=viewnewcolor.replace(/.*?(solid|dashed|dotted|double|groove|ridge|inset|outset).*/i, "\$1");
	theborderstyle = theborderstyle.toLowerCase();
	theborderstyle=theborderstyle.replace(/^\\s/g, "");
	theborderstyle=theborderstyle.replace(/\\s\$/g, "");
	for(i = 0; i < optnumb; i++) {
		selborderstyle = document.allstyles.borderstyle.options[i].value;
		if(selborderstyle == theborderstyle) document.allstyles.borderstyle.value = selborderstyle;
	}

	thebordersize=nocolor.replace(/.*?([\\d]{1,2}).*/i, "\$1");
	if(!thebordersize) thebordersize=0;
	document.allstyles.bordcol.value = thebordercolor;
	document.allstyles.borderweigth.value = document.allstyles.borderweigth.options[thebordersize].value;

	if (cssfont.disabled == false) {
		cssfont.checked = true;
	}
	else if (cssback.disabled == false) {
		cssback.checked = true;
	}
	else if (cssborder.disabled == false) {
		cssborder.checked = true;
	}
	manSelect();
}

initStyles();
setElement();

// Palette
var thistask = 'templ';
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
	~;
	$yytitle = $templ_txt{'1'};
	$action_area = "modcss";
	&AdminTemplate;
}

sub ModifyCSS2 {
	&is_admin_or_gmod;
	if ($FORM{'button'} == 1) {
		$yySetLocation = qq~$adminurl?action=modcss;cssfile=$FORM{'cssfile'}~;
		&redirectexit;

	} elsif ($FORM{'button'} == 2) {
		$style_name = $FORM{'savecssas'};
		if ($style_name eq "default") { &admin_fatal_error("no_delete_default"); }
		if ($style_name !~ m^\A[0-9a-zA-Z_\.\#\%\-\:\+\?\$\&\~\.\,\@/]+\Z^ || $style_name eq "") { &admin_fatal_error("invalid_template"); }
		$style_cnt = $FORM{'stylelink'};
		&FromHTML($style_cnt);
		$style_cnt =~ s~(\*\/)~$1\n\n~g;
		$style_cnt =~ s~(\/\*)~\n$1~g;
		$style_cnt =~ s~(\{)~$1\n~g;
		$style_cnt =~ s~(\})~$1\n~g;
		$style_cnt =~ s~(\;)~$1\n~g;
		@style_arr = split(/\n/, $style_cnt);

		fopen(TMPCSS, ">$forumstylesdir/$style_name.css") || &admin_fatal_error("cannot_open","$forumstylesdir/$style_name.css", 1);
		foreach $style_sgl (@style_arr) {
			$style_sgl =~ s~\A\s+?~~g;
			if($style_sgl =~ m~\;+\Z~) { $style_sgl = qq~\t$style_sgl~; }
			$style_sgl =~ s/$forumstylesurl/\./g;
			print TMPCSS "$style_sgl\n";
		}
		fclose(TMPCSS);

		$yySetLocation = qq~$adminurl?action=modcss;cssfile=$style_name.css~;
		&redirectexit;

	} elsif ($FORM{'button'} == 3) {
		$style_name = $FORM{'cssfile'};
		if ($style_name eq "default.css") { &admin_fatal_error("no_delete_default"); }
		unlink "$forumstylesdir/$style_name";
		$yySetLocation = qq~$adminurl?action=modcss;cssfile=default.css~;
		&redirectexit;
	}
}

sub ModifySkin {
	&is_admin_or_gmod;

	if ($INFO{'templateset'}) { $thistemplate = $INFO{'templateset'}; }
	else { $thistemplate = "$template"; }

	foreach my $curtemplate (sort{ $templateset{$a} cmp $templateset{$b} } keys %templateset) {
		$selected = "";
		if ($curtemplate eq $thistemplate) { $selected = qq~ selected="selected"~; $akttemplate = $curtemplate; }
		$templatesel .= qq~<option value="$curtemplate"$selected>$curtemplate</option>\n~;
	}

	($aktstyle, $aktimages, $akthead, $aktboard, $aktmessage, $aktdisplay, $aktmycenter, $aktmenutype) = split(/\|/, $templateset{$akttemplate});
	$thisimagesdir = "$forumstylesurl/$aktimages";

	my ($fullcss, $line);
	if ($INFO{'cssfile'}) { $cssfile = $INFO{'cssfile'}; }
	else { $cssfile = "$aktstyle.css"; }
	if ($INFO{'imgfolder'}) { $imgfolder = $INFO{'imgfolder'}; }
	else { $imgfolder = "$aktimages"; }
	if ($INFO{'headfile'}) { $headfile = $INFO{'headfile'}; }
	else { $headfile = "$akthead.html"; }
	if ($INFO{'boardfile'}) { $boardfile = $INFO{'boardfile'}; }
	else { $boardfile = "$aktboard/BoardIndex.template"; }
	if ($INFO{'messagefile'}) { $messagefile = $INFO{'messagefile'}; }
	else { $messagefile = "$aktmessage/MessageIndex.template"; }
	if ($INFO{'displayfile'}) { $displayfile = $INFO{'displayfile'}; }
	else { $displayfile = "$aktdisplay/Display.template"; }

	if ($INFO{'mycenterfile'}) { $mycenterfile = $INFO{'mycenterfile'}; }
	else { $mycenterfile = "$aktmycenter/MyCenter.template"; }

	if ($INFO{'menutype'} ne '') { $UseMenuType = $INFO{'menutype'}; }
	else {
		$UseMenuType = $MenuType;
		if ($aktmenutype ne '') { $UseMenuType = $aktmenutype; }
	}

	if ($INFO{'selsection'}) { $selectedsection = $INFO{'selsection'}; }
	else { $selectedsection = "vboard"; }
	my ($boardsel, $messagesel, $displaysel);
	if    ($selectedsection eq "vboard")   { $boardsel   = qq~ checked="checked"~; }
	elsif ($selectedsection eq "vmessage") { $messagesel = qq~ checked="checked"~; }
	elsif ($selectedsection eq "vdisplay") { $displaysel = qq~ checked="checked"~; }
	else  { $mycentersel = qq~ checked="checked"~; }

	opendir(TMPLDIR, "$forumstylesdir");
	@styles = readdir(TMPLDIR);
	closedir(TMPLDIR);
	$forumcss = "";
	$imgdirs  = "";
	foreach $file (sort @styles) {
		($name, $ext) = split(/\./, $file);
		$selected = "";
		if ($ext eq 'css') {
			if ($file eq $cssfile) { $selected = qq~ selected="selected"~; $viewcss = $name; }
			$forumcss .= qq~<option value="$file"$selected>$name</option>\n~;
		}
		if (-d "$forumstylesdir/$file" && $file =~ m^\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@/]+\Z^) {
			if ($imgfolder eq $file) { $imgdirs .= qq~<option value="$file" selected="selected">$file</option>~; $viewimg = $file; }
			else { $imgdirs .= qq~<option value="$file">$file</option>~; }
		}
	}

	fopen(CSS, "$forumstylesdir/$cssfile") or &admin_fatal_error("cannot_open","$forumstylesdir/$cssfile");
	while ($line = <CSS>) {
		$line =~ s~[\r\n]~~g;
		&FromHTML($line);
		$fullcss .= qq~$line\n~;
	}
	fclose(CSS);

	opendir(TMPLDIR, "$templatesdir");
	@temptemplates = readdir(TMPLDIR);
	closedir(TMPLDIR);

	foreach $tmpfile (@temptemplates) {
		if (-d "$templatesdir/$tmpfile") {
			push(@templates, $tmpfile);
		} else {
			next;
		}
	}

	if ($UseMenuType == 0) { $menutype0 = ' selected="selected" ';  }
	elsif ($UseMenuType == 1) { $menutype1 = ' selected="selected" '; }
	elsif ($UseMenuType == 2) { $menutype2 = ' selected="selected" '; }
	require "$vardir/Menu$UseMenuType.def";

	$boardtemplates   = "";
	$messagetemplates = "";
	$displaytemplates = "";
	$headtemplates    = "";

	foreach $name (sort @templates) {
		opendir(TMPLSDIR, "$templatesdir/$name");
		@templatefiles = readdir(TMPLSDIR);
		closedir(TMPLSDIR);

		foreach $file (@templatefiles) {
			if ($file eq "index.html") { next; }
			$thefile = qq~$name/$file~;
			($section, $ext) = split(/\./, $file);
			$hselected = "";
			if ($ext eq 'html') {
				if ($file eq $headfile) { $hselected = qq~ selected="selected"~; $viewhead = $name; }
				$headtemplates .= qq~<option value="$file"$hselected>$name</option>\n~;
			}
			$bselected = "";
			$mselected = "";
			$dselected = "";
			$myselected = "";
			if ($section eq 'BoardIndex') {
				if ($thefile eq $boardfile) { $bselected = qq~ selected="selected"~; $viewboard = $name; }
				$boardtemplates .= qq~<option value="$thefile"$bselected>$name</option>\n~;
			} elsif ($section eq 'MessageIndex') {
				if ($thefile eq $messagefile) { $mselected = qq~ selected="selected"~; $viewmessage = $name; }
				$messagetemplates .= qq~<option value="$thefile"$mselected>$name</option>\n~;
			} elsif ($section eq 'Display') {
				if ($thefile eq $displayfile) { $dselected = qq~ selected="selected"~; $viewdisplay = $name; }
				$displaytemplates .= qq~<option value="$thefile"$dselected>$name</option>\n~;
			} elsif ($section eq 'MyCenter') {
				if ($thefile eq $mycenterfile) { $myselected = qq~ selected="selected"~; $viewmycenter = $name; }
				$mycentertemplates .= qq~<option value="$thefile"$myselected>$name</option>\n~;
			}
		}
	}

	fopen(TMPL, "$templatesdir/$viewhead/$viewhead.html");
	while ($line = <TMPL>) {
		$line =~ s~[\r\n]~~g;
		$fulltemplate .= qq~$line\n~;
	}
	fclose(TMPL);

	$tabsep = qq~<img src="$imagesdir/tabsep211.png" border="0" alt="" style="float: left; vertical-align: middle;" />~;
	$tabfill = qq~<img src="$imagesdir/tabfill.gif" border="0" alt="" style="vertical-align: middle;" />~;

	$tempforumurl  = $mbname;
	$temptitle     = qq~Template Config~;
	$tempnewstitle = qq~<b>$templ_txt{'68'}:</b> ~;
	$tempnews      = qq~$templ_txt{'84'}~;
	$tempstyles    = qq~<link rel="stylesheet" href="$forumstylesurl/$viewcss.css" type="text/css" />~;
	$tempimages    = qq~$forumstylesurl/$viewimg~;
	$tempimagesdir = qq~$forumstylesdir/$viewimg~;
	$tempmenu = qq~<span title="$img_txt{'103'}" class="selected">$tabfill$img_txt{'103'}$tabfill</span>~;
	$tempmenu .= qq~$tabsep<span title="$img_txt{'119'}" style="cursor:help;">$tabfill$img_txt{'119'}$tabfill</span>~;
	$tempmenu .= qq~$tabsep<span title="$img_txt{'331'}">$tabfill$img_txt{'331'}$tabfill</span>~;
	$tempmenu .= qq~$tabsep<span title="$img_txt{'mycenter'}">$tabfill$img_txt{'mycenter'}$tabfill</span>~;
	$tempmenu .= qq~$tabsep<span title="$img_txt{'108'}">$tabfill$img_txt{'108'}$tabfill</span>$tabsep~;
	$tempmenu =~ s~img src\=\"$imagesdir\/(.+?)\"~&TmpImgLoc($1, $tempimages, $tempimagesdir)~eisg;
	$temp21menu = qq~$img{'home'}$menusep$img{'help'}$menusep$img{'search'}$menusep$img{'memberlist'}$menusep$img{'profile'}$menusep$img{'notification'}$menusep$img{'logout'}~;
	$temp21menu =~ s~img src\=\"$imagesdir\/(.+?)\"~&TmpImgLoc($1, $tempimages, $tempimagesdir)~eisg;
	$rssbutton = qq~<img src="$imagesdir/rss.png" border="0" alt="" style="vertical-align: middle;" />~;
	$tempuname = qq~$templ_txt{'69'} ${$uid.$username}{'realname'}, ~;
	$tempuim   = qq~$templ_txt{'70'} <a name="ims">0 $templ_txt{'71'}</a>.~;
	$temptime  = &timeformat($date, 1);
	my $tempsearchbox = qq~<input type="text" name="search" size="16" style="font-size: 11px; vertical-align: middle;" />~;
	$tempsearchbox .= qq~<img src="$imagesdir/search.gif" alt="" style="border: 0; background-color: transparent; margin-right: 5px; vertical-align: middle;" />~;

	$templatejump = 1;
	$tempforumjump = &jumpto;

	$fulltemplate =~ s/({|<)yabb charset(}|>)/$yycharset/g;
	$fulltemplate =~ s/({|<)yabb title(}|>)/$temptitle/g;
	$fulltemplate =~ s/({|<)yabb style(}|>)/$tempstyles/g;
	$fulltemplate =~ s/({|<)yabb images(}|>)/$tempimages/g;
	$fulltemplate =~ s/({|<)yabb uname(}|>)/$tempuname/g;
	$fulltemplate =~ s/({|<)yabb boardlink(}|>)/$tempforumurl/g;
	$fulltemplate =~ s/({|<)yabb navigation(}|>)//g;
	$fulltemplate =~ s/({|<)yabb searchbox(}|>)/$tempsearchbox/g;
	$fulltemplate =~ s/({|<)yabb im(}|>)/$tempuim/g;
	$fulltemplate =~ s/({|<)yabb time(}|>)/$temptime/g;
	$fulltemplate =~ s/({|<)yabb langChooser(}|>)//g;
	$fulltemplate =~ s/({|<)yabb menu(}|>)/$temp21menu/g;
	$fulltemplate =~ s/({|<)yabb tabmenu(}|>)/$tempmenu/g;
	$fulltemplate =~ s/({|<)yabb rss(}|>)/$rssbutton/g;
	$fulltemplate =~ s/({|<)yabb news(}|>)/$tempnews/g;
	$fulltemplate =~ s/({|<)yabb newstitle(}|>)/$tempnewstitle/g;
	$fulltemplate =~ s/({|<)yabb copyright(}|>)//g;
	$fulltemplate =~ s/({|<)yabb debug(}|>)//g;
	$fulltemplate =~ s/({|<)yabb forumjump(}|>)/$tempforumjump/g;
	$fulltemplate =~ s/({|<)yabb freespace(}|>)//g;
	$fulltemplate =~ s/({|<)yabb navback(}|>)//g;
	$fulltemplate =~ s/({|<)yabb admin_alert(}|>)//g;
	$fulltemplate =~ s/({|<)yabb tabadd(}|>)//g;
	$fulltemplate =~ s/({|<)yabb addtab(}|>)//g;

	if ($selectedsection eq "vboard") {
		$boardtempl = &BoardTempl($viewboard, $tempimages, $tempimagesdir);
		$fulltemplate =~ s/({|<)yabb main(}|>)/$boardtempl/g;
	} elsif ($selectedsection eq "vmessage") {
		$messagetempl = &MessageTempl($viewmessage, $tempimages, $tempimagesdir);
		$fulltemplate =~ s/({|<)yabb main(}|>)/$messagetempl/g;
	} elsif ($selectedsection eq "vdisplay") {
		$displaytempl = &DisplayTempl($viewdisplay, $tempimages, $tempimagesdir);
		$fulltemplate =~ s/({|<)yabb main(}|>)/$displaytempl/g;
	} elsif ($selectedsection eq "vmycenter") {
		$mycentertempl = &MyCenterTempl($viewmycenter, $tempimages, $tempimagesdir);
		$fulltemplate =~ s/({|<)yabb main(}|>)/$mycentertempl/g;
	}
	$fulltemplate =~ s~img src\=\"$tempimages\/(.+?)\"~&TmpImgLoc($1, $tempimages, $tempimagesdir)~eisg;
	$fulltemplate =~ s/<a href="http:\/\/validator.w3.org\/check\/referer">.+?<\/a>//g;
	$fulltemplate =~ s/<a href="http:\/\/jigsaw.w3.org\/css\-validator\/validator\?uri\=<yabb url>">.+?<\/a>//g;
	$fulltemplate =~ s~[\n\r]~~g;
	&ToHTML($fulltemplate);

	$yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr>
		<td align="left" valign="middle" class="titlebg">
		<img src="$imagesdir/xx.gif" alt="" border="0" style="vertical-align: middle;" /><b> $templ_txt{'6'}</b>
		</td>
	</tr>
</table>
<table width="100%" cellspacing="1" cellpadding="0">
	<tr>
		<td width="100%" align="center" valign="middle" class="windowbg2">
			<iframe id="TempManager" name="TempManager" width="100%" height="350" marginwidth="0" marginheight="0" frameborder="0" scrolling="yes" style="border-top: 1px inset; border-bottom: 1px inset; visibility: visible; display: inline"></iframe>
		</td>
	</tr>
</table>
<form action="$adminurl?action=modskin2" name="selskin" method="post" style="display: inline;">
<table width="100%" cellspacing="1" cellpadding="4">
	<tr valign="middle">
		<td align="left" class="windowbg2">
		<div style="float: left; width: 30%; padding: 3px;"><label for="templateset"><b>$templ_txt{'10'}</b></label></div>
		
		<div style="float: left; width: 69%;">
			<input type="hidden" name="button" value="0" />
			<select name="templateset" id="templateset" size="1" onchange="submit();">
			$templatesel
			</select>
~;
	unless ($akttemplate eq "Forum default") {
		$yymain .= qq~			<input type="submit" value="$templ_txt{'14'}" onclick="document.selskin.button.value = '3'; return confirm('$templ_txt{'15'} $thistemplate?')" class="button" />~;
	}
	$yymain .= qq~
		</div>
		</td>
	</tr>
	<tr>
		<td align="left" class="windowbg2">
		<div style="float: left; width: 30%; padding: 3px;">
			<b>$templ_txt{'11'}</b><br /><span class="small">$templ_txt{'7'}</span>
		</div>
		<div style="float: left; width: 69%;">
			<div style="float: left; width: 32%; text-align: left;">
				<label for="menutype"><span class="small">$admin_txt{'521'}</span></label><br />
				<select name="menutype" id="menutype" size="1" style="width: 90%;">
					<option value="0"$menutype0>$admin_txt{'521a'}</option>
					<option value="1"$menutype1>$admin_txt{'521b'}</option>
					<option value="2"$menutype2>$admin_txt{'521c'}</option>
				</select>
			</div>
			<br /><br /><br />
			<div style="float: left; width: 32%; text-align: left;">
				<label for="cssfile"><span class="small">$templ_txt{'1'}</span></label><br />
				<select name="cssfile" id="cssfile" size="1" style="width: 90%;">
				$forumcss
				</select>
			</div>
			<div style="float: left; width: 32%; text-align: left;">
				<label for="imgfolder"><span class="small">$templ_txt{'8'}</span></label><br />
				<select name="imgfolder" id="imgfolder" size="1" style="width: 90%;">
				$imgdirs
				</select>
			</div>
			<div style="float: left; width: 32%; text-align: left;">
				<label for="headfile"><span class="small">$templ_txt{'2'}</span></label><br />
				<select name="headfile" id="headfile" size="1" style="width: 90%;">
				$headtemplates
				</select>
			</div>
			<div style="float: left; width: 32%; text-align: left;">
				<input type="radio" name="selsection" id="bradio" value="vboard" class="windowbg2" style="border: 0px; vertical-align: middle;"$boardsel /><label for="bradio" class="small">$templ_txt{'3'}</label><br />
				<select name="boardfile" id="boardfile" size="1" style="width: 90%;">
				$boardtemplates
				</select>
			</div>
			<div style="float: left; width: 32%; text-align: left;">
				<input type="radio" name="selsection" id="mradio" value="vmessage" class="windowbg2" style="border: 0px; vertical-align: middle;"$messagesel /><label for="mradio" class="small">$templ_txt{'4'}</label><br />
				<select name="messagefile" id="messagefile" size="1" style="width: 90%;">
				$messagetemplates
				</select>
			</div>
			<div style="float: left; width: 32%; text-align: left;">
				<input type="radio" name="selsection" id="dradio" value="vdisplay" class="windowbg2" style="border: 0px; vertical-align: middle;"$displaysel /><label for="dradio" class="small">$templ_txt{'5'}</label><br />
				<select name="displayfile" id="displayfile" size="1" style="width: 90%;">
				$displaytemplates
				</select>
			</div>
			<div style="float: left; width: 32%; text-align: left;">
				<input type="radio" name="selsection" id="myradio" value="vmycenter" class="windowbg2" style="border: 0px; vertical-align: middle;"$mycentersel /><label for="myradio" class="small">$templ_txt{'67'}</label><br />
				<select name="mycenterfile" id="mycenterfile" size="1" style="width: 90%;">
				$mycentertemplates
				</select>
			</div>
		</div>
		</td>
	</tr>
	<tr valign="middle">
		<td align="left" class="windowbg2">
		<div style="float: left; width: 30%; padding: 3px;"><label for="saveas"><b>$templ_txt{'12'}</b></label></div>
		<div style="float: left; width: 69%;">
			<input type="hidden" name="tempname" value="$fulltemplate" />
			<input type="text" name="saveas" id="saveas" value="$thistemplate" size="30" maxlength="50" />
			<input type="submit" value="$templ_txt{'13'}" onclick="document.selskin.button.value = '2';" class="button" />
			<input type="submit" value="$templ_txt{'9'}" onclick="document.selskin.button.value = '1';" class="button" />
		</div>
		</td>
	</tr>
</table>
</form>
</div>

<script type="text/javascript" language="JavaScript">
<!--
function updateTemplate() {
	var thetemplate = document.selskin.tempname.value;
	thetemplate=thetemplate.replace(/\\&amp\\;/g, "&");
	thetemplate=thetemplate.replace(/\\&quot\\;/g, '"');
	thetemplate=thetemplate.replace(/\\&nbsp\\;/g, " ");
	thetemplate=thetemplate.replace(/\\&\\#124\\;/g, "|");
	thetemplate=thetemplate.replace(/\\&lt\\;/g, "<");
	thetemplate=thetemplate.replace(/\\&gt\\;/g, ">");
	TempManager.document.open("text/html");
	TempManager.document.write(thetemplate);
	TempManager.document.close();
}
document.onload = updateTemplate();
//-->
</script>
~;
	$yytitle = $templ_txt{'6'};
	$action_area = "modskin";
	&AdminTemplate;
}

sub ModifySkin2 {
	&is_admin_or_gmod;
	$formattemp = $FORM{'templateset'};
	&formatTempname;
	if ($FORM{'button'} == 1) {
		$yySetLocation = qq~$adminurl?action=modskin;templateset=$formattemp;cssfile=$FORM{'cssfile'};imgfolder=$FORM{'imgfolder'};headfile=$FORM{'headfile'};boardfile=$FORM{'boardfile'};messagefile=$FORM{'messagefile'};displayfile=$FORM{'displayfile'};mycenterfile=$FORM{'mycenterfile'};menutype=$FORM{'menutype'};selsection=$FORM{'selsection'}~;

	} elsif ($FORM{'button'} == 2) {
		$template_name = $FORM{'saveas'};
		if ($template_name eq "default") { &admin_fatal_error("no_delete_default"); }
		if ($template_name !~ m^\A[0-9a-zA-Z_\ \.\#\%\-\:\+\?\$\&\~\.\,\@/]+\Z^ || $template_name eq "") { &admin_fatal_error("invalid_template"); }
		($template_css, undef, undef) = split(/\./, $FORM{'cssfile'});
		$template_images = $FORM{'imgfolder'};
		($template_head, undef) = split(/\./, $FORM{'headfile'});
		($template_board, undef) = split(/\//, $FORM{'boardfile'});
		($template_message, undef) = split(/\//, $FORM{'messagefile'});
		($template_display, undef) = split(/\//, $FORM{'displayfile'});
		($template_mycenter, undef) = split(/\//, $FORM{'mycenterfile'});
		($template_menutype, undef) = split(/\//, $FORM{'menutype'});
		$formattemp = $FORM{'saveas'};
		&formatTempname;
		&UpdateTemplates($template_name, "save");
		$yySetLocation = qq~$adminurl?action=modskin;templateset=$formattemp;cssfile=$FORM{'cssfile'};imgfolder=$FORM{'imgfolder'};headfile=$FORM{'headfile'};boardfile=$FORM{'boardfile'};messagefile=$FORM{'messagefile'};displayfile=$FORM{'displayfile'};mycenterfile=$FORM{'mycenterfile'};menutype=$FORM{'menutype'};selsection=$FORM{'selsection'}~;

	} elsif ($FORM{'button'} == 3) {
		$template_name = $FORM{'templateset'};
		if ($template_name eq "default")       { &admin_fatal_error("no_delete_default"); }
		if ($template_name eq "Forum default") { &admin_fatal_error("no_delete_default"); }
		&UpdateTemplates($template_name, "delete");
		$yySetLocation = qq~$adminurl?action=modskin~;
	} else {
		$yySetLocation = qq~$adminurl?action=modskin;templateset=$formattemp~;
	}
	&redirectexit;
}

sub formatTempname {
	$formattemp =~ s~\%~%25~g;
	$formattemp =~ s~\#~%23~g;
	$formattemp =~ s~\+~%2B~g;
	$formattemp =~ s~\,~%2C~g;
	$formattemp =~ s~\-~%2D~g;
	$formattemp =~ s~\.~%2E~g;
	$formattemp =~ s~\@~%40~g;
	$formattemp =~ s~\^~%5E~g;
}

sub TmpImgLoc {
	if (!-e "$_[2]/$_[0]") { $thisimgloc = qq~img src="$forumstylesurl/default/$_[0]"~; }
	else { $thisimgloc = qq~img src="$_[1]/$_[0]"~; }
	$thisimgloc;
}

sub BoardTempl {
	&LoadLanguage('BoardIndex');
	my $tmpimagesdir = $imagesdir;
	$imagesdir = qq~$_[1]~;
	require "$templatesdir/$_[0]/BoardIndex.template";

	if (-e ("$vardir/mostlog.txt")) {
		fopen(MOSTUSERS, "$vardir/mostlog.txt");
		@mostentries = <MOSTUSERS>;
		fclose(MOSTUSERS);
		($mostmemb,  $datememb) = split(/\|/, $mostentries[0]);
		($mostguest, $dateguest) = split(/\|/, $mostentries[1]);
		($mostusers, $dateusers) = split(/\|/, $mostentries[2]);
		($mostbots, $datebots) = split(/\|/, $mostentries[3]);
		chomp($datememb, $dateguest, $dateusers, $datebots);
		$themostmembdate = &timeformat($datememb);
		$themostguestdate = &timeformat($dateguest);
		$themostuserdate = &timeformat($dateusers);
		$themostbotsdate = &timeformat($datebots);
		$themostuser = $mostusers;
		$themostmemb = $mostmemb;
		$themostguest = $mostguest;
		$themostbots = $mostbots;
	} else {
		$themostmembdate  = &timeformat($date);
		$themostguestdate = &timeformat($date);
		$themostuserdate  = &timeformat($date);
		$themostbotsdate = &timeformat($date);
		$themostuser = 23;
		$themostmemb = 12;
		$themostguest = 19;
		$themostbots = 4;
	}

	$grpcolors = "";
	($title, undef, undef, $color, $noshow) = split(/\|/, $Group{'Administrator'}, 5);
	my $admcolor = qq~$color~;
	if ($color && $noshow != 1) { $grpcolors .= qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~; }
	($title, undef, undef, $color, $noshow) = split(/\|/, $Group{'Global Moderator'}, 5);
	if ($color && $noshow != 1) { $grpcolors .= qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~; }
	foreach $nopostamount (sort { $a <=> $b } keys %NoPost) {
		($title, undef, undef, $color, $noshow) = split(/\|/, $NoPost{$nopostamount}, 5);
		if ($color && $noshow != 1) { $grpcolors .= qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~; }
	}
	foreach $postamount (sort { $b <=> $a } keys %Post) {
		($title, undef, undef, $color, $noshow) = split(/\|/, $Post{$postamount}, 5);
		if ($color && $noshow != 1) { $grpcolors .= qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~; }
	}

	my $latestmemberlink = qq~$boardindex_txt{'201'} <a href="javascript:;"><b>${$uid.$username}{'realname'}</b></a>.<br />~;
	my $tempims = qq~$boardindex_txt{'795'} <a href="javascript:;"><b>2</b></a> $boardindex_txt{'796'} $boardindex_imtxt{'24'} <a href="javascript:;"><b>2</b></a> $boardindex_imtxt{'26'}.~;
	my $tempforumurl = $mbname;
	my $tempnew = qq~<img src="$imagesdir/off.gif" alt="" border="0" />~;
	my $tempcurboard = $templ_txt{'77'};
	my $tempcurboardurl = qq~javascript:;~;
	my $tempboardanchor = $templ_txt{'78'};
	my $tempbddescr = $templ_txt{'79'};
	my $tempshowmods = qq~$boardindex_txt{'63'}: $templ_txt{'74'}<br />$boardindex_txt{'63a'}: $templ_txt{'74a'}~;
	my $templastposttme  = &timeformat($date);
	my $templastpostlink = qq~<a href="javascript:;">$img{'lastpost'}</a> $templastposttme~;
	my $templastposter = qq~<a href="javascript:;">${$uid.$username}{'realname'}</a>~;
	my $tmplasttopiclink = qq~<a href="javascript:;">$templ_txt{'80'}</a>~;
	$tempcatlink = qq~<img src="$_[1]/cat_collapse.gif" alt="" border="0" /> <a href="javascript:;">$templ_txt{'81'}</a>~;
	my $templatecat = $catheader;
	$templatecat =~ s/({|<)yabb catlink(}|>)/$tempcatlink/g;
	my $tmptemplateblock = $templatecat;
	my $templastpostdate = &timeformat($date);
	$templastpostdate = qq~($templastpostdate).<br />~;
	my $temprecentposts = qq~$boardindex_txt{'791'} <select style="font-size: 7pt;"><option>&nbsp;</option><option>5</option></select> $boardindex_txt{'792'} $boardindex_txt{'793'}~;
	my $tempguestson    = qq~<span class="small">$boardindex_txt{'141'}: <b>2</b></span>~;
	my $tempbotson = qq~<span class="small">$boardindex_txt{'143'}: <b>3</b></span>~;
	my $tempbotlist = qq~<span class="small">Googlebot (1), MSN Search (2)</span>~;
	my $tempuserson = qq~<span class="small">$boardindex_txt{'142'}: <b>1</b></span>~;
	my $tempusers = qq~<span class="small" style="color: $admcolor;"><b>${$uid.$username}{'realname'}</b></span><br />~;
	my $tempmembercount = qq~<b>2</b>~;
	my $tempboardpic = qq~ <img src="$imagesdir/boards.gif" alt="$tempcurboard" border="0" />~;

	for ($i = 1; $i < 3; $i++) {
		my $templateblock = $boardblock;
		$templateblock =~ s/({|<)yabb new(}|>)/$tempnew/g;
		$templateblock =~ s/({|<)yabb boardanchor(}|>)/$tempboardanchor/g;
		$templateblock =~ s/({|<)yabb boardurl(}|>)/$tempcurboardurl/g;
		$templateblock =~ s/({|<)yabb boardpic(}|>)/$tempboardpic/g;
		$templateblock =~ s/({|<)yabb boardname(}|>)/$tempcurboard $i/g;
		$templateblock =~ s/({|<)yabb boarddesc(}|>)/$tempbddescr/g;
		$templateblock =~ s/({|<)yabb moderators(}|>)/$tempshowmods/g;
		$templateblock =~ s/({|<)yabb threadcount(}|>)/$i/g;
		$templateblock =~ s/({|<)yabb messagecount(}|>)/$i/g;
		$templateblock =~ s/({|<)yabb lastpostlink(}|>)/$templastpostlink/g;
		$templateblock =~ s/({|<)yabb lastposter(}|>)/$templastposter/g;
		$templateblock =~ s/({|<)yabb lasttopiclink(}|>)/$tmplasttopiclink/g;
		$tmptemplateblock .= $templateblock;
	}
	$tmptemplateblock .= $catfooter;
	$boardindex_template =~ s/({|<)yabb pollshowcase(}|>)//;
	$boardindex_template =~ s/({|<)yabb catsblock(}|>)/$tmptemplateblock/g;

	$collapselink = qq~$menusep$img{'collapse'}~;
	$expandlink   = qq~$menusep$img{'expand'}~;
	$markalllink  = qq~$menusep$img{'markallread'}~;

	my $templasttopiclink = qq~$boardindex_txt{'236'} <a href="javascript:;"><b>$templ_txt{'80'}</b></a>~;

	$boardhandellist     =~ s/({|<)yabb collapse(}|>)/$collapselink/g;
	$boardhandellist     =~ s/({|<)yabb expand(}|>)//g;
	$boardhandellist     =~ s/({|<)yabb markallread(}|>)/$markalllink/g;
	$boardhandellist     =~ s/\Q$menusep//i;
	$boardindex_template =~ s/({|<)yabb boardhandellist(}|>)/$boardhandellist/g;
	$boardindex_template =~ s/({|<)yabb catimage(}|>)//g;
	$boardindex_template =~ s~img src\=\"$tmpimagesdir\/(.+?)\"~&TmpImgLoc($1, $_[1], $_[2])~eisg;

	$boardindex_template =~ s/({|<)yabb newmsg start(}|>)//g;
	$boardindex_template =~ s/({|<)yabb newmsg icon(}|>)//g;
	$boardindex_template =~ s/({|<)yabb newmsg(}|>)//g;
	$boardindex_template =~ s/({|<)yabb newmsg end(}|>)//g;

	$boardindex_template =~ s/({|<)yabb totaltopics(}|>)/3/g;
	$boardindex_template =~ s/({|<)yabb totalmessages(}|>)/3/g;
	$boardindex_template =~ s/({|<)yabb lastpostlink(}|>)/$templasttopiclink/g;
	$boardindex_template =~ s/({|<)yabb lastpostdate(}|>)/$templastpostdate/g;
	$boardindex_template =~ s/({|<)yabb recentposts(}|>)/$temprecentposts/g;

	$boardindex_template =~ s/({|<)yabb mostusers(}|>)/$themostuser/g;
	$boardindex_template =~ s/({|<)yabb mostmembers(}|>)/$themostmemb/g;
	$boardindex_template =~ s/({|<)yabb mostguests(}|>)/$themostguest/g;
	$boardindex_template =~ s/({|<)yabb mostbots(}|>)/$themostbots/g;
	$boardindex_template =~ s/({|<)yabb mostusersdate(}|>)/$themostuserdate/g;
	$boardindex_template =~ s/({|<)yabb mostmembersdate(}|>)/$themostmembdate/g;
	$boardindex_template =~ s/({|<)yabb mostguestsdate(}|>)/$themostguestdate/g;
	$boardindex_template =~ s/({|<)yabb mostbotsdate(}|>)/$themostbotsdate/g;
	$boardindex_template =~ s/({|<)yabb groupcolors(}|>)/$grpcolors/g;

	$boardindex_template =~ s/({|<)yabb membercount(}|>)/$tempmembercount/g;
	$boardindex_template =~ s/({|<)yabb latestmember(}|>)/$latestmemberlink/g;
	$boardindex_template =~ s/({|<)yabb ims(}|>)/$tempims/g;
	$boardindex_template =~ s/({|<)yabb users(}|>)/$tempuserson/g;
	$boardindex_template =~ s/({|<)yabb onlineusers(}|>)/$tempusers/g;
	$boardindex_template =~ s/({|<)yabb guests(}|>)/$tempguestson/g;
	$boardindex_template =~ s/({|<)yabb onlineguests(}|>)//g;
	$boardindex_template =~ s/({|<)yabb bots(}|>)/$tempbotson/g;
	$boardindex_template =~ s/({|<)yabb onlinebots(}|>)/$tempbotlist/g;
	$boardindex_template =~ s/({|<)yabb caldisplay(}|>)/$cal_display/g;
	$boardindex_template =~ s/({|<)yabb sharedlogin(}|>)//g;
	$boardindex_template =~ s/({|<)yabb selecthtml(}|>)//g;
	$boardindex_template =~ s~img src\=\"$_[1]\/(.+?)\"~&TmpImgLoc($1, $_[1], $_[2])~eisg;
	$imagesdir = $tmpimagesdir;
	$boardindex_template;
}

sub MessageTempl {
	&LoadLanguage('MessageIndex');
	my $tmpimagesdir = $imagesdir;
	$imagesdir = "$_[1]";
	require "$templatesdir/$_[0]/MessageIndex.template";
	my $tempcatnm = $templ_txt{'72'};
	my $tempboardnm = $templ_txt{'73'};
	my $tempmodslink = qq~($messageindex_txt{'298'}: $templ_txt{'74'} - $messageindex_txt{'298a'}: $templ_txt{'74a'})~;
	my $tempbdescrip = $templ_txt{'79'};
	my $temppageindextgl = qq~<img src="$_[1]/xx.gif" style="vertical-align: middle;" alt="" border="0" />~;
	my $temppageindex = qq~<span class="small" style="vertical-align: middle;"> <b>$messageindex_txt{'139'}:</b> 1</span>~;
	my $tempthreadpic = qq~<img src="$_[1]/thread.gif" style="vertical-align: middle;" alt="" border="0" />~;
	my $tempmicon = qq~<img src="$_[1]/xx.gif" style="vertical-align: middle;" alt="" border="0" />~;
	my $tempnew = qq~<img src="$_[1]/new.gif" style="vertical-align: middle;" alt="" border="0" />~;
	my $tempmsublink = $templ_txt{'83'};
	my $tempmname = ${$uid.$username}{'realname'};
	my $templastpostlink = qq~<img src="$_[1]/lastpost.gif" style="vertical-align: middle;" alt="" border="0" /> $templ_txt{'82'}~;
	my $templastposter = $tempmname;
	my $tempyabbicons = qq~
	<img src="$_[1]/thread.gif" alt="" /> $messageindex_txt{'457'}<br />
	<img src="$_[1]/hotthread.gif" alt="" /> $messageindex_txt{'454'} x $messageindex_txt{'454a'}<br />
	<img src="$_[1]/veryhotthread.gif" alt="" /> $messageindex_txt{'455'} x $messageindex_txt{'454a'}<br />
	<img src="$_[1]/locked.gif" alt="" /> $messageindex_txt{'456'}<br />
	<img src="$_[1]/locked_moved.gif" alt="" /> $messageindex_txt{'845'}
	~;
	my $tempyabbadminicons .= qq~
	<img src="$_[1]/hide.gif" alt="" /> $messageindex_txt{'458'}<br />
	<img src="$_[1]/hidesticky.gif" alt="" /> $messageindex_txt{'459'}<br />
	<img src="$_[1]/hidelock.gif" alt="" /> $messageindex_txt{'460'}<br />
	<img src="$_[1]/hidestickylock.gif" alt="" /> $messageindex_txt{'461'}<br />
	<img src="$_[1]/announcement.gif" alt="" /> $messageindex_txt{'779a'}<br />
	<img src="$_[1]/announcementlock.gif" alt="" /> $messageindex_txt{'779b'}<br />
	<img src="$_[1]/sticky.gif" alt="" /> $messageindex_txt{'779'}<br />
	<img src="$_[1]/stickylock.gif" alt="" /> $messageindex_txt{'780'}
	~;

	$notify_board = qq~$menusep$img{'notify'}~;
	$markalllink = qq~$menusep$img{'markboardread'}~;
	$postlink = qq~$menusep$img{'newthread'}~;
	$polllink = qq~$menusep$img{'createpoll'}~;

	$bdpic = qq~ <img src="$_[1]/boards.gif" alt="$templ_txt{'72'}" border="0" align="middle" /> ~;
	$message_permalink = $messageindex_txt{'10'};
	$temp_attachment = qq~<img src="$_[1]/paperclip.gif" alt="$messageindex_txt{'5'}" />~;
	
	$messageindex_template =~ s/({|<)yabb home(}|>)/$mbname/g;
	$messageindex_template =~ s/({|<)yabb category(}|>)/$tempcatnm/g;
	$messageindex_template =~ s/({|<)yabb board(}|>)/$tempboardnm/g;
	$messageindex_template =~ s/({|<)yabb moderators(}|>)/$tempmodslink/g;
	$messageindex_template =~ s/({|<)yabb sortsubject(}|>)/$sort_subject/g;
	$messageindex_template =~ s/({|<)yabb sortstarter(}|>)/$sort_starter/g;
	$messageindex_template =~ s/({|<)yabb sortanswer(}|>)/$sort_answer/g;
	$messageindex_template =~ s/({|<)yabb sortlastpostim(}|>)/$sort_lastpostim/g;
	$messageindex_template =~ s/({|<)yabb bdpicture(}|>)/$bdpic/g;
	$messageindex_template =~ s/({|<)yabb threadcount(}|>)/1/g;
	$messageindex_template =~ s/({|<)yabb messagecount(}|>)/2/g;
	$boarddescription =~ s/({|<)yabb boarddescription(}|>)/$tempbdescrip/g;
	$messageindex_template =~ s/({|<)yabb description(}|>)/$boarddescription/g;
	$messageindex_template =~ s/({|<)yabb colspan(}|>)/7/g;

	$messageindex_template =~ s/({|<)yabb pageindex top(}|>)/$temppageindex1/g;
	$messageindex_template =~ s/({|<)yabb pageindex bottom(}|>)/$temppageindex1/g;
	$topichandellist =~ s/({|<)yabb notify button(}|>)/$notify_board/g;
	$topichandellist =~ s/({|<)yabb markall button(}|>)/$markalllink/g;
	$topichandellist =~ s/({|<)yabb new post button(}|>)/$postlink/g;
	$topichandellist =~ s/({|<)yabb new poll button(}|>)/$polllink/g;
	$topichandellist =~ s/\Q$menusep//i;
	$messageindex_template =~ s/({|<)yabb topichandellist(}|>)/$topichandellist/g;

	$messageindex_template =~ s/({|<)yabb pageindex(}|>)/$temppageindex/g;
	$messageindex_template =~ s/({|<)yabb pageindex toggle(}|>)/$temppageindextgl/g;
	$messageindex_template =~ s/({|<)yabb admin column(}|>)//g;

	my $tempbar = $threadbar;
	$tempbar =~ s/({|<)yabb admin column(}|>)//g;
	$tempbar =~ s/({|<)yabb threadpic(}|>)/$tempthreadpic/g;
	$tempbar =~ s/({|<)yabb icon(}|>)/$tempmicon/g;
	$tempbar =~ s/({|<)yabb new(}|>)/$tempnew/g;
	$tempbar =~ s/({|<)yabb poll(}|>)//g;
	$tempbar =~ s/({|<)yabb favorite(}|>)//g;
	$tempbar =~ s/({|<)yabb subjectlink(}|>)/$tempmsublink/g;
	$tempbar =~ s/({|<)yabb pages(}|>)//g;
	$tempbar =~ s/({|<)yabb attachmenticon(}|>)/$temp_attachment/g;
	$tempbar =~ s/({|<)yabb starter(}|>)/$tempmname/g;
	$tempbar =~ s/({|<)yabb replies(}|>)/2/g;
	$tempbar =~ s/({|<)yabb views(}|>)/12/g;
	$tempbar =~ s/({|<)yabb lastpostlink(}|>)/$templastpostlink/g;
	$tempbar =~ s/({|<)yabb lastposter(}|>)/$templastposter/g;

	if ($accept_permalink == 1) {
		$tempbar =~ s/({|<)yabb permalink(}|>)/$message_permalink/g;
	} else {
		$tempbar =~ s/({|<)yabb permalink(}|>)//g;
	}

	$tmptempbar .= $tempbar;

	$messageindex_template =~ s/({|<)yabb threadblock(}|>)/$tmptempbar/g;
	$messageindex_template =~ s/({|<)yabb modupdate(}|>)//g;
	$messageindex_template =~ s/({|<)yabb modupdateend(}|>)//g;
	$messageindex_template =~ s/({|<)yabb stickyblock(}|>)//g;
	$messageindex_template =~ s/({|<)yabb adminfooter(}|>)//g;
	$messageindex_template =~ s/({|<)yabb icons(}|>)/$tempyabbicons/g;
	$messageindex_template =~ s/({|<)yabb admin icons(}|>)/$tempyabbadminicons/g;
	$messageindex_template =~ s/({|<)yabb access(}|>)//g;
	$messageindex_template =~ s~img src\=\"$tmpimagesdir\/(.+?)\"~&TmpImgLoc($1, $_[1], $_[2])~eisg;
	$messageindex_template =~ s~img src\=\"$_[1]\/(.+?)\"~&TmpImgLoc($1, $_[1], $_[2])~eisg;
	$imagesdir = $tmpimagesdir;
	$messageindex_template;
}

sub DisplayTempl {
	&LoadLanguage('Display');
	my $tmpimagesdir = $imagesdir;
	$imagesdir = $_[1];
	require "$templatesdir/$_[0]/Display.template";
	($title, $stars, $starpic, $color, $noshow, $viewperms, $topicperms, $replyperms, $pollperms, $attachperms) = split(/\|/, $Group{"Administrator"});
	if ($UseMenuType == 0) {
		$yimimg = qq~$menusep<img src="$_[1]/yim.gif" alt="" border="0" />~;
		$aimimg = qq~$menusep<img src="$_[1]/aim.gif" alt="" border="0" />~;
		$msnimg = qq~$menusep<img src="$_[1]/msn.gif" alt="" border="0" />~;
	} elsif ($UseMenuType == 1) {
		$yimimg = qq~$menusep<span class="imgwindowbg">YIM</span>~;
		$aimimg = qq~$menusep<span class="imgwindowbg">AIM</span>~;
		$msnimg = qq~$menusep<span class="imgwindowbg">MSN</span>~;
	} else {
		$yimimg = qq~$menusep<img src="$yyhtml_root/Buttons/$language/yim.png" alt="" border="0" />~;
		$aimimg = qq~$menusep<img src="$yyhtml_root/Buttons/$language/aim.png" alt="" border="0" />~;
		$msnimg = qq~$menusep<img src="$yyhtml_root/Buttons/$language/msn.png" alt="" border="0" />~;
	}
	my $template_home = qq~<span class="nav">$mbname</span>~;
	my $tempcatnm = $templ_txt{'72'};
	my $tempboardnm = $templ_txt{'73'};
	my $tempmodslink = qq~($display_txt{'298'}: $templ_txt{'74'} - $display_txt{'298a'}: $templ_txt{'74a'})~;
	my $template_prev = $display_txt{'768'};
	my $template_next = $display_txt{'767'};
	my $temppageindextgl = qq~<img src="$_[1]/xx.gif" style="vertical-align: middle;" alt="" border="0" />~;
	my $temppageindex1 = qq~<span class="small" style="vertical-align: middle;"> <b>$display_txt{'139'}:</b> 1</span>~;
	my $replybutton = qq~$menusep$img{'reply'}~;
	my $pollbutton = qq~$menusep$img{'addpoll'}~;
	my $notify = qq~$menusep$img{'notify'}~;
	my $template_sendtopic = qq~$menusep$img{'sendtopic'}~;
	my $template_print = qq~$menusep$img{'print'}~;
	my $template_threadimage = qq~<img src="$_[1]/thread.gif" align="middle" alt="" />~;
	my $threadurl = $templ_txt{'75'};
	my $template_alertmod = qq~$menusep$img{'alertmod'}~;
	my $template_quote = qq~$menusep$img{'quote'}~;
	my $template_modify = qq~$menusep$img{'modify'}~;
	my $template_split = qq~$menusep$img{'admin_split'}~;
	my $template_delete = qq~$menusep$img{'delete'}~;
	my $memberinfo = qq~<span class="small"><b>$title</b></span>~;
	my $usernamelink = qq~<span style="color: $color;"><b>${$uid.$username}{'realname'}</b></span><br />~;

	for (1 .. 5) {
		$star .= qq(<img src="$_[1]/$starpic" border="0" alt="*" />);
	}
	my $msub = $templ_txt{'76'};
	my $msgimg = qq~<img src="$_[1]/xx.gif" align="middle" alt="" />~;
	my $messdate = &timeformat($date);
	my $template_postinfo = qq~$display_txt{'21'}: ${$uid.$username}{'postcount'}<br />~;
	my $template_usertext = qq~${$uid.$username}{'usertext'}<br />~;
	my $avatar = qq~<img src="$facesurl/elmerfudd.gif" name="avatar" alt="" border="0" align="middle" style="max-width: $userpic_width\px\; max-height: $userpic_height\px" />~;
	my $message = qq~$templ_txt{'65'}<br /><a href="javascript:;">$templ_txt{'66'}</a>~;
	my $template_email = qq~$menusep$img{'email_sm'}~;
	my $template_pm = qq~$menusep$img{'message_sm'}~;
	my $ipimg = qq~<img src="$imagesdir/ip.gif" alt="" border="0" align="middle" />~;
	my $template_remove = qq~$menusep$img{'admin_rem'}~;
	my $template_splice = qq~$menusep$img{'admin_move_split_splice'}~;
	my $template_lock = qq~$menusep$img{'admin_lock'}~;
	my $template_hide = qq~$menusep$img{'hide'}~;
	my $template_sticky = qq~$menusep$img{'admin_sticky'}~;

	$online = qq~<span class="useronline">$maintxt{'60'}</span>~;

	for ($i = 0; $i < 2; $i++) {
		my $outblock = $messageblock;
		my $posthandelblock = $posthandellist;
		my $contactblock = $contactlist;

		if ($i == 0) {
			$css = qq~windowbg~;
			$counterwords = "";
		} else {
			$css = qq~windowbg2~;
			$counterwords = "$display_txt{'146'} #$i";
		}

		$posthandelblock =~ s/({|<)yabb modalert(}|>)/$template_alertmod/g;
		$posthandelblock =~ s/({|<)yabb quote(}|>)/$template_quote/g;
		$posthandelblock =~ s/({|<)yabb modify(}|>)/$template_modify/g;
		$posthandelblock =~ s/({|<)yabb split(}|>)/$template_split/g;
		$posthandelblock =~ s/({|<)yabb delete(}|>)/$template_delete/g;
		$posthandelblock =~ s/({|<)yabb admin(}|>)/$template_admin/g;
		$posthandelblock =~ s/\Q$menusep//i;

		$contactblock =~ s/({|<)yabb email(}|>)/$template_email/g;
		$contactblock =~ s/({|<)yabb profile(}|>)//g;
		$contactblock =~ s/({|<)yabb pm(}|>)/$template_pm/g;
		$contactblock =~ s/({|<)yabb www(}|>)//g;
		$contactblock =~ s/({|<)yabb aim(}|>)/$aimimg/g;
		$contactblock =~ s/({|<)yabb yim(}|>)/$yimimg/g;
		$contactblock =~ s/({|<)yabb icq(}|>)//g;
		$contactblock =~ s/({|<)yabb msn(}|>)/$msnimg/g;
		$contactblock =~ s/({|<)yabb gtalk(}|>)//g;
		$contactblock =~ s/({|<)yabb skype(}|>)//g;
		$contactblock =~ s/({|<)yabb myspace(}|>)/$myspacead/g;
		$contactblock =~ s/({|<)yabb facebook(}|>)/$facebookad/g;
		$contactblock =~ s/({|<)yabb addbuddy(}|>)//g;
		$contactblock =~ s/\Q$menusep//i;

		$outblock =~ s/({|<)yabb images(}|>)/$tmpimagesdir/g;
		$outblock =~ s/({|<)yabb messageoptions(}|>)//g;
		$outblock =~ s/({|<)yabb memberinfo(}|>)/$memberinfo/g;
		$outblock =~ s/({|<)yabb userlink(}|>)/$usernamelink/g;
		$outblock =~ s/({|<)yabb stars(}|>)/$star/g;
		$outblock =~ s/({|<)yabb subject(}|>)/$msub/g;
		$outblock =~ s/({|<)yabb msgimg(}|>)/$msgimg/g;
		$outblock =~ s/({|<)yabb msgdate(}|>)/$messdate/g;
		$outblock =~ s/({|<)yabb replycount(}|>)/$counterwords/g;
		$outblock =~ s/({|<)yabb count(}|>)//g;
		$outblock =~ s/({|<)yabb att(}|>)//g;
		$outblock =~ s/({|<)yabb css(}|>)/$css/g;
		$outblock =~ s/({|<)yabb gender(}|>)//g;
		$outblock =~ s/({|<)yabb ext_prof(}|>)/$template_ext_prof/g;
		$outblock =~ s/({|<)yabb location(}|>)//g;
		$outblock =~ s/({|<)yabb isbuddy(}|>)//g;
		$outblock =~ s/({|<)yabb useronline(}|>)/$online/g;
		$outblock =~ s/({|<)yabb postinfo(}|>)/$template_postinfo/g;
		$outblock =~ s/({|<)yabb usertext(}|>)/$template_usertext/g;
		$outblock =~ s/({|<)yabb userpic(}|>)/$avatar/g;
		$outblock =~ s/({|<)yabb message(}|>)/$message/g;
		$outblock =~ s/({|<)yabb showatt(}|>)//g;
		$outblock =~ s/({|<)yabb showatthr(}|>)//g;
		$outblock =~ s/({|<)yabb modified(}|>)//g;
		$outblock =~ s/({|<)yabb signature(}|>)//g;
		$outblock =~ s/({|<)yabb signaturehr(}|>)//g;
		$outblock =~ s/({|<)yabb ipimg(}|>)/$ipimg/g;
		$outblock =~ s/({|<)yabb ip(}|>)//g;
		$outblock =~ s/({|<)yabb permalink(}|>)//g;
		$outblock =~ s/({|<)yabb posthandellist(}|>)/$posthandelblock/g;
		$outblock =~ s/({|<)yabb contactlist(}|>)/$contactblock/g;
		$tempoutblock .= $outblock;
	}

	$threadhandellist =~ s/({|<)yabb reply(}|>)/$replybutton/g;
	$threadhandellist =~ s/({|<)yabb poll(}|>)/$template_poll/g;
	$threadhandellist =~ s/({|<)yabb notify(}|>)/$template_notify/g;
	$threadhandellist =~ s/({|<)yabb favorite(}|>)/$template_favorite/g;
	$threadhandellist =~ s/({|<)yabb sendtopic(}|>)/$template_sendtopic/g;
	$threadhandellist =~ s/({|<)yabb print(}|>)/$template_print/g;
	$threadhandellist =~ s/({|<)yabb markunread(}|>)//g;
	$threadhandellist =~ s/\Q$menusep//i;

	$adminhandellist =~ s/({|<)yabb remove(}|>)/$template_remove/g;
	$adminhandellist =~ s/({|<)yabb splice(}|>)/$template_splice/g;
	$adminhandellist =~ s/({|<)yabb lock(}|>)/$template_lock/g;
	$adminhandellist =~ s/({|<)yabb hide(}|>)/$template_hide/g;
	$adminhandellist =~ s/({|<)yabb sticky(}|>)/$template_sticky/g;
	$adminhandellist =~ s/({|<)yabb multidelete(}|>)/$template_multidelete/g;
	$adminhandellist =~ s/\Q$menusep//i;

	$display_template =~ s/({|<)yabb pollmain(}|>)//g;
	$display_template =~ s/({|<)yabb topicviewers(}|>)//g;

	$display_template =~ s/({|<)yabb home(}|>)/$template_home/g;
	$display_template =~ s/({|<)yabb category(}|>)/$tempcatnm/g;
	$display_template =~ s/({|<)yabb board(}|>)/$tempboardnm/g;
	$display_template =~ s/({|<)yabb moderators(}|>)/$tempmodslink/g;
	$display_template =~ s/({|<)yabb prev(}|>)/$template_prev/g;
	$display_template =~ s/({|<)yabb next(}|>)/$template_next/g;
	$display_template =~ s/({|<)yabb pageindex toggle(}|>)/$temppageindextgl/g;
	$display_template =~ s/({|<)yabb pageindex top(}|>)/$temppageindex1/g;
	$display_template =~ s/({|<)yabb pageindex bottom(}|>)/$temppageindex1/g;
	$display_template =~ s/({|<)yabb threadhandellist(}|>)/$threadhandellist/g;
	$display_template =~ s/({|<)yabb threadimage(}|>)/$template_threadimage/g;
	$display_template =~ s/({|<)yabb threadurl(}|>)/$threadurl/g;
	$display_template =~ s/({|<)yabb views(}|>)/12/g;
	$display_template =~ s/({|<)yabb multistart(}|>)//g;
	$display_template =~ s/({|<)yabb multiend(}|>)//g;
	$display_template =~ s/({|<)yabb postsblock(}|>)/$tempoutblock/g;
	$display_template =~ s/({|<)yabb adminhandellist(}|>)/$adminhandellist/g;
	$display_template =~ s/({|<)yabb forumselect(}|>)//g;
	$display_template =~ s~img src\=\"$tmpimagesdir\/(.+?)\"~&TmpImgLoc($1, $_[1], $_[2])~eisg;
	$display_template =~ s~img src\=\"$_[1]\/(.+?)\"~&TmpImgLoc($1, $_[1], $_[2])~eisg;
	$imagesdir = $tmpimagesdir;
	$display_template;
}

sub MyCenterTempl {
	&LoadLanguage('InstantMessage');
	&LoadLanguage('MyCenter');
	my $tmpimagesdir = $imagesdir;
	$imagesdir = $_[1];
	require "$templatesdir/$_[0]/MyCenter.template";
	
	$tabsep = qq~<img src="$imagesdir/tabsep211.png" border="0" alt="" style="float: left; vertical-align: middle;" />~;
	$tabfill = qq~<img src="$imagesdir/tabfill.gif" border="0" alt="" style="vertical-align: middle;" />~;

	if ($PM_level == 1 || ($PM_level == 2 && ($iamadmin || $iamgmod || $iammod)) || ($PM_level == 3 && ($iamadmin || $iamgmod))   )	{
		$yymcmenu .= qq~<span title="$mc_menus{'messages'}" class="selected">$tabsep$tabfill$mc_menus{'messages'}$tabfill</span>
		~;
	}

	$yymcmenu .= qq~$tabsep<span title="$mc_menus{'profile'}">$tabfill$mc_menus{'profile'}$tabfill</span>~;
	$yymcmenu .= qq~$tabsep<span title="$mc_menus{'posts'}">$tabfill$mc_menus{'posts'}$tabfill</span>~;
	$yymcmenu .= qq~$tabsep~;

	$mycenter_template =~ s/{yabb mcviewmenu}/$MCViewMenu/g;
	$mycenter_template =~ s/{yabb mcmenu}/$yymcmenu/g;
	$mycenter_template =~ s/{yabb mcpmmenu}/$MCPmMenu/g;
	$mycenter_template =~ s/{yabb mcprofmenu}/$MCProfMenu/g;
	$mycenter_template =~ s/{yabb mcpostsmenu}/$MCPostsMenu/g;
	$mycenter_template =~ s/{yabb mcglobformstart}/$MCGlobalFormStart/g;
	$mycenter_template =~ s/{yabb mcglobformend}/ ($MCGlobalFormStart ? "<\/form>" : "") /e;
	$mycenter_template =~ s/{yabb mcextrasmilies}/$MCExtraSmilies/g;
	$mycenter_template =~ s/{yabb mccontent}/$MCContent/g;
	$mycenter_template =~ s/{yabb mctitle}/$mctitle/g;
	$mycenter_template =~ s/{yabb selecthtml}/$selecthtml/g;
	
	$mycenter_template =~ s~img src\=\"$tmpimagesdir\/(.+?)\"~&TmpImgLoc($1, $_[1], $_[2])~eisg;
	$mycenter_template =~ s~img src\=\"$_[1]\/(.+?)\"~&TmpImgLoc($1, $_[1], $_[2])~eisg;
	$imagesdir = $tmpimagesdir;
	$mycenter_template;
}

sub UpdateTemplates {
	my ($tempelement, $tempjob) = @_;
	if ($tempjob eq "new") { # update to new style from very old versions
		require "$templatesdir/$tempelement/$tempelement.cfg";
		if ($template_name !~ m^\A[0-9a-zA-Z_\´\ \.\#\%\-\:\+\?\$\&\~\.\,\@/]+\Z^ || $template_name eq "") {
			$template_name = "Invalid template_name in $tempelement.cfg";
		}
		my $testname = $template_name;
		my $i        = 1;
		while (my ($curtemplate, $value) = each(%templateset)) {
			if (lc $curtemplate eq lc $testname) {
				$testname = qq~$template_name ($i)~;
				$i++;
			}
		}
		if ($template_css) { $templateset{"$testname"} = "$tempelement"; }
		else { $templateset{"$testname"} = "default"; }
		if ($template_images) { $templateset{"$testname"} .= "|$tempelement"; }
		else { $templateset{"$testname"} .= "|default"; }
		if ($template_head) { $templateset{"$testname"} .= "|$tempelement"; }
		else { $templateset{"$testname"} .= "|default"; }
		if ($template_board) { $templateset{"$testname"} .= "|$tempelement"; }
		else { $templateset{"$testname"} .= "|default"; }
		if ($template_message) { $templateset{"$testname"} .= "|$tempelement"; }
		else { $templateset{"$testname"} .= "|default"; }
		if ($template_display) { $templateset{"$testname"} .= "|$tempelement"; }
		else { $templateset{"$testname"} .= "|default"; }
		if ($template_mycenter) { $templateset{"$testname"} .= "|$tempelement"; }
		else { $templateset{"$testname"} .= "|default"; }
		if ($template_menutype) { $templateset{"$testname"} .= "|$tempelement"; }
		else { $templateset{"$testname"} .= "|"; }

		unlink "$templatesdir/$tempelement/$tempelement.cfg";
		return;

	} elsif ($tempjob eq "save") {
		$templateset{"$tempelement"} = "$template_css";
		$templateset{"$tempelement"} .= "|$template_images";
		$templateset{"$tempelement"} .= "|$template_head";
		$templateset{"$tempelement"} .= "|$template_board";
		$templateset{"$tempelement"} .= "|$template_message";
		$templateset{"$tempelement"} .= "|$template_display";
		$templateset{"$tempelement"} .= "|$template_mycenter";
		$templateset{"$tempelement"} .= "|$template_menutype";

	} elsif ($tempjob eq "delete") {
		delete $templateset{$tempelement};
	}

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');
}

1;