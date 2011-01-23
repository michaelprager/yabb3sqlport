###############################################################################
# HelpCentre.pl                                                               #
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

$helpcentreplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('HelpCentre');

$yytitle = $helptxt{'1'};
undef $guest_media_disallowed;

sub SectionDecide {
	# This bit decides what section we are in and sets the background accordingly
	# Also sets the variables are used to open up the correct Help Directory
	$moderator_class  = "catbg";
	$admin_class      = "catbg";
	$global_mod_class = "catbg";
	$UserClass        = "catbg";

	if ($UseHelp_Perms) {
		$ismod = 0;
		unless (exists $memberinfo{$username}) { &LoadUser($username); }
		foreach $catid (@categoryorder) {
			if ($ismod) { last; }
			$boardlist = $cat{$catid};
			(@bdlist) = split(/\,/, $boardlist);
			foreach $curboard (@bdlist) {
				if ($ismod) { last; }
				foreach $curuser (split(/, ?/, ${$uid.$curboard}{'mods'})) {
					if ($curuser eq $username) { $ismod = 1; last; }
				}
				foreach (split(/, /, ${$uid.$curboard}{'modgroups'})) {
					if ($_ eq ${$uid.$username}{'position'}) { $ismod = 1; last; }
				}
			}
		}
	}

	if ($INFO{'section'} eq "admin") {
		if ($UseHelp_Perms && !$iamadmin) { &fatal_error("no_access","HelpCentre->SectionDecide"); }
		${ $INFO{'section'} . _class } = "titlebg";
		$help_area = "Admin";
	} elsif ($INFO{'section'} eq "moderator") {
		if ($UseHelp_Perms && !$ismod && !$iamgmod && !$iamadmin) { &fatal_error("no_access","HelpCentre->SectionDecide"); }
		${ $INFO{'section'} . _class } = "titlebg";
		$help_area = "Moderator";
	} elsif ($INFO{'section'} eq "global_mod") {
		if ($UseHelp_Perms && !$iamgmod && !$iamadmin) { &fatal_error("no_access","HelpCentre->SectionDecide"); }
		${ $INFO{'section'} . _class } = "titlebg";
		$help_area = "Gmod";
	} else {
		$UserClass = "titlebg";
		$help_area = "User";
	}

}

sub SectionPrint {
	# Prints the navigation bar for the help section
	$userhlp = qq~<a href="$scripturl?action=help">$helptxt{'3'}</a>~;
	if ($UseHelp_Perms) {
		if (!$ismod && !$iamgmod && !$iamadmin) { return }
		if ($ismod || $iamgmod || $iamadmin) {
			$modhlp = qq~<a href="$scripturl?action=help;section=moderator">$helptxt{'4'}</a>~;
		} else {
			$modhlp = "&nbsp;";
		}
		if ($iamgmod || $iamadmin) {
			$gmodhlp = qq~<a href="$scripturl?action=help;section=global_mod">$helptxt{'5'}</a>~;
		} else {
			$gmodhlp = "&nbsp;";
		}
		if ($iamadmin) {
			$adminhlp = qq~<a href="$scripturl?action=help;section=admin">$helptxt{'6'}</a>~;
		} else {
			$adminhlp = "&nbsp;";
		}
	} else {
		$modhlp   = qq~<a href="$scripturl?action=help;section=moderator">$helptxt{'4'}</a>~;
		$gmodhlp  = qq~<a href="$scripturl?action=help;section=global_mod">$helptxt{'5'}</a>~;
		$adminhlp = qq~<a href="$scripturl?action=help;section=admin">$helptxt{'6'}</a>~;
	}

	$HelpNavBar =~ s/<user menu>/$userhlp/g;
	$HelpNavBar =~ s/<moderator menu>/$modhlp/g;
	$HelpNavBar =~ s/<global mod menu>/$gmodhlp/g;
	$HelpNavBar =~ s/<admin menu>/$adminhlp/g;
	$HelpNavBar =~ s/<user class>/$UserClass/g;
	$HelpNavBar =~ s/<moderator class>/$moderator_class/g;
	$HelpNavBar =~ s/<global mod class>/$global_mod_class/g;
	$HelpNavBar =~ s/<admin class>/$admin_class/g;
	$yymain .= $HelpNavBar;

}

sub GetHelpFiles {
	unless ($HelpTemplateLoaded) {
		if (-e ("$templatesdir/$usestyle/HelpCentre.template")) {
			require "$templatesdir/$usestyle/HelpCentre.template";
		} else {
			require "$templatesdir/default/HelpCentre.template";
		}
	}

	&SectionDecide;

	# This determines if the order file is present and if it isn't
	# It creates a new one, in default alphabetical order
	&CreateOrderFile if (!&checkfor_DBorFILE("$vardir/$help_area.helporder"));

	my @helporderlist = &read_DBorFILE(0,'',$vardir,$help_area,'helporder');
	chomp(@helporderlist);

	foreach (@helporderlist) {
		if (-e "$helpfile/$language/$help_area/$_.help") {
			require "$helpfile/$language/$help_area/$_.help";
		} elsif (-e "$helpfile/English/$help_area/$_.help") {
			require "$helpfile/English/$help_area/$_.help";
		} else {
			next;
		}

		&MainHelp;
		&DoContents;
	}

	&SectionPrint;
	&ContentContainer;

	$yynavigation = qq~&rsaquo; $yytitle~;
	&template;
}

sub MainHelp {

	$TempParse = $BodyHeader;
	$TempParse =~ s/<yabb section_anchor>/$SectionName/g;
	$SectionNam = $SectionName;
	$SectionNam =~ s/_/ /g;
	$TempParse  =~ s/<yabb section_name>/$SectionNam/g;
	$Body .= qq~$TempParse~;

	$i = 1;
	while (${ SectionSub . $i }) {

		if (${ SectionExcl . $i } eq "yabbc" && (!$enable_ubbc || !$showyabbcbutt)) { $i++; next; }

		$TempParse     = $BodySubHeader;
		$SectionAnchor = ${ SectionSub . $i };
		$SectionSub    = ${ SectionSub . $i };
		$SectionSub =~ s/_/ /g;
		$TempParse  =~ s/<yabb section_anchor>/$SectionAnchor/g;
		$TempParse  =~ s/<yabb section_sub>/$SectionSub/g;
		$Body .= qq~$TempParse~;

		$message = ${ SectionBody . $i };
		$displayname = ${$uid.$username}{'realname'};
		if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
		$message =~ s~\[yabbc\](.*?)\[/yabbc\]~my($text) = $1; &ToHTML($text); &DoUBBCTo($text);~sge;
		&wrap2;

		if($SectionAnchor eq 'YaBBC_Reference') {
			$yyinlinestyle .= qq~<style type="text/css">
.yabbc td {width: 75%; text-align: left;}
.yabbc td:first-child {width: 25%; vertical-align: top;}
.yabbc th {width: 100%;}
.yabbc th img {float: left;}
.yabbc table {width: 75%;}
</style>\n~;
		}

		$TempParse = $BodyItem;
		$TempParse =~ s/<yabb item>/$message/g;
		$Body .= qq~$TempParse~;
		$i++;
	}
	$Body .= qq~$BodyFooter~;
}

{
	my %hpkillhash = (
		';'  => '&#059;',
		'!'  => '&#33;',
		'('  => '&#40;',
		')'  => '&#41;',
		'-'  => '&#45;',
		'.'  => '&#46;',
		'/'  => '&#47;',
		':'  => '&#58;',
		'?'  => '&#63;',
		'['  => '&#91;',
		'\\' => '&#92;',
		']'  => '&#93;',
		'^'  => '&#94;');

	sub codehlp {
		my $hcode = $_[0];
		if ($hcode !~ /&\S*;/) { $hcode =~ s/;/&#059;/g; }
		$hcode =~ s~([\(\)\-\:\\\/\?\!\]\[\.\^])~$hpkillhash{$1}~g;
		$hcode =~ s~(&#91\;.+?&#93\;)~<span style="color: #ff0000;">$1</span>~isg;
		$hcode =~ s~(&#91\;&#47\;.+?&#93\;)~<span style="color: #ff0000;">$1</span>~isg;
		return $hcode;
	}
}

sub ContentContainer {
	$MainLayout =~ s/<yabb contents>/$Contents/g;
	$MainLayout =~ s/<yabb body>/$Body/g;

	$yymain .= qq~$MainLayout~;
}

sub DoContents {
	$TempParse = $ContentHeader;

	$TempParse =~ s/<yabb section_anchor>/$SectionName/g;
	$SectionNam = $SectionName;
	$SectionNam =~ s/_/ /g;
	$TempParse  =~ s/<yabb section_name>/$SectionNam/g;
	$Contents .= qq~$TempParse~;

	$Contents .= qq~<ul style="list-style: none; margin: 0; padding: 2px; border: none;">~;
	$i = 1;
	while (${ SectionSub . $i }) {

		if (${ SectionExcl . $i } eq "yabbc" && (!$enable_ubbc || !$showyabbcbutt)) { $i++; next; }

		$SectionAnchor = ${ SectionSub . $i };
		${ SectionSub . $i } =~ s/_/ /g;

		$TempParse = $ContentItem;
		$TempParse =~ s/<yabb anchor>/$SectionAnchor/g;
		$TempParse =~ s/<yabb content>/${SectionSub.$i}/g;

		$Contents .= qq~$TempParse~;
		${ SectionSub . $i } = "";
		$i++;
	}
	$Contents .= qq~</ul>~;
}

sub CreateOrderFile {
	opendir(HELPDIR, "$helpfile/$language/$help_area");
	@contents = readdir(HELPDIR);
	closedir(HELPDIR);

	foreach (sort { uc($a) cmp uc($b) } @contents) {
		($name, $extension) = split(/\./, $_);
		next if $extension !~ /help/i;
		$order_list .= "$name\n";
	}

	&write_DBorFILE(0,'',$vardir,$help_area,'helporder',($order_list));
}

1;