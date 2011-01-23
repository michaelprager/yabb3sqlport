#!/usr/bin/perl --
# Change the shebang only if you plan to use RSS in a program of your own.
###############################################################################
# RSS.pl                                                                      #
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

$rssplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

# Change the error routine for here.
$SIG{__WARN__} = sub { &RSS_error(@_) };

# Allow us to be called by a system()-like call
# This lets us send data to any language that supports capturing STDOUT.
# Usage is detailed in POD at the bottom.
if (scalar @ARGV) {&shellaccess();}

# Is RSS disabled?
&RSS_error('not_allowed') if $rss_disabled;

&LoadCensorList;

# Load YaBBC if it is enabled
require "$sourcedir/YaBBC.pl" if $enable_ubbc;

# Read from a single board
sub RSS_board {
	### Arguments:
	# board: the board to load from. Defaults to all boards.
	# showauthor: show the author or not? Defaults to false.
	# topics: Number of topics to show. Defaults to 5.
	###

	# Local variables
	my ($board, $topics); # Variables for settings

	# Settings
	$board = $INFO{'board'};
	$topics = $INFO{'topics'} || $rss_limit || 10;
	if ($rss_limit && $topics > $rss_limit) { $topics = $rss_limit; }

	### Security check ###
	if (&AccessCheck($currentboard, '', $boardperms) ne 'granted') { &RSS_error('no_access'); }
	if ($annboard eq $board && !$iamadmin && !$iamgmod) { &RSS_error('no_access'); }

	# Now, go into the board and look for the last X topics
	my @threadlist = &read_DBorFILE(0,'',$boardsdir,$board,'txt');
	my $threadcount = @threadlist;
	if ($threadcount < $topics) { $topics = $threadcount; }

	@threadlist = splice(@threadlist, 0, $topics);
	# Sorting mode
	if ($rss_message == 2) {
		# Sort by original post
		@threadlist = sort @threadlist;
	}
	# Otherwise, it's good enough as-is
	chomp @threadlist;

	my $i = 0;
	foreach (@threadlist) {
		($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate, $ns) = split(/\|/, $_);
		$curnum = $mnum;
		# See if this is a topic that we don't want displayed.
		if ($mstate =~ /h/ && !$iamadmin && !$iamgmod) { next; }

		# Does it need to be returned as a 304?
		if ($i == 0) { # Do this for the first request only
			$cachedate = &RFC822Date($mdate);
			if ($ENV{'HTTP_IF_NONE_MATCH'} eq qq~"$cachedate"~ || $ENV{'HTTP_IF_MODIFIED_SINCE'} eq $cachedate) {
				&Send304NotModified(); # Comment this out to test with caching disabled
			}
		}

		($msub, undef) = &Split_Splice_Move($msub,0);
		&FromHTML($msub);
		&ToChars($msub);
		# Censor the subject of the thread.
		$msub = &Censor($msub);

		my $postid = "$mreplies#$mreplies";
		$postid = '0#0' if $rss_message == 2;

		my $category = "$mbname/$boardname";
		&FromHTML($category);
		# Show the minimum stuff (topic title, link to it)
		if ($accept_permalink){
			$permdate = &permtimer($curnum);
			$yymain .= qq~		<item>
				<title>~ . &RSSDescriptionTrim($msub) . qq~</title>
				<link>~ . &RSSDescriptionTrim("http://$perm_domain/$symlink$permdate/$currentboard/$curnum") . qq~</link>
				<category>~ . &RSSDescriptionTrim($category) . qq~</category>
				<guid isPermaLink="true">~ . &RSSDescriptionTrim("http://$perm_domain/$symlink$permdate/$currentboard/$curnum") . qq~</guid>
~;
		} else {
			$yymain .= qq~		<item>
				<title>~ . &RSSDescriptionTrim($msub) . qq~</title>
				<link>~ . &RSSDescriptionTrim("$scripturl?num=$curnum") . qq~</link>
				<category>~ . &RSSDescriptionTrim($category) . qq~</category>
				<guid>~ . &RSSDescriptionTrim("$scripturl?num=$curnum") . qq~</guid>
~;
		}

		my $post;
		if ($rss_message == 1) {
			# Open up the thread and read the last post.
			foreach (&read_DBorFILE(0,'',$datadir,$curnum,'txt')) {
				chomp $_;
				$post = $_ if $_;
			}
		} elsif ($rss_message == 2) {
			# Open up the thread and read the first post.
			$post = (&read_DBorFILE(0,'',$datadir,$curnum,'txt'))[0];
		}
		if ($post ne '') {
			(undef, undef, undef, undef, $musername, undef, undef, undef, $message, $ns) = split(/\|/, $post);
		}
		if ($showauthor) {
			# The spec really wants us to include their email.
			# That's not adviseable for us (spambots anyone?). So we skip author if the email hidden flag is on for that user.
			if (&checkfor_DBorFILE("$memberdir/$musername.vars")) {
				&LoadUser($musername); 
				if (!${$uid.$musername}{'hidemail'}){
					$yymain .= qq~<author>~ . &RSSDescriptionTrim("${$uid.$musername}{'email'} (${$uid.$musername}{'realname'})") . qq~</author>~;
				}
			}
		}
		if ($showdate) {
				$mdate = $curnum if $rss_message == 2; # Sort by topic creation if requested.
				# Get the date how the user wants it.
				my $realdate = &RFC822Date($mdate);
				$yymain .= qq~		<pubDate>$realdate</pubDate>
~;
		}
		if ($message ne '') {
			($message, undef) = &Split_Splice_Move($message,$curnum);
			if ($enable_ubbc) {
					&LoadUser($musername);
					$displayname = ${$uid.$musername}{'realname'};
					&DoUBBC;
			}
			&FromHTML($message);
			&ToChars($message);
			$message = &Censor($message);
			$yymain .= qq~		<description>~ . &RSSDescriptionTrim($message) . qq~</description>
~;
		}
		# Finish up the item
		$yymain .= qq~		</item>
~;
		$i++; # Increment
	}

	&ToChars($boardname);
	$yytitle = $boardname;
	$yydesc = ${$uid.$curboard}{'description'};

	&RSS_template();
}

# Similar to Recent.pl&RecentList but uses original code
# RSS feed from multiple boards (a category or the whole forum)
sub RSS_recent {
	### Arguments:
	# catselect: use a specific category instead of the whole forum (optional)
	# topics: Number of topics to show. Defaults to 5.
	###


	# Local variables
	my ($topics); # Variables for settings
	my (@threadlist, $i, $cutofftime); # Variables for the messages

	# Settings
	$topics = $INFO{'topics'} || $rss_limit;
	if ($rss_limit && $topics > $rss_limit) { $topics = $rss_limit; }

	# If this is just a single category, handle it.
	if ($catinfo{$INFO{'catselect'}}) { @categoryorder = ($INFO{'catselect'}); }

	# Find the latest $topics post times in all boards that we have access to
	# and add them to a giant array
	foreach $catid (@categoryorder) {
		my $boardlist = $cat{$catid};

		my @bdlist = split(/\,/, $boardlist);
		my ($catname, $catperms) = split(/\|/, $catinfo{$catid});
		my $cataccess = &CatAccess($catperms);
		if (!$cataccess) { next; }

		foreach $curboard (@bdlist) {
			($boardname{$curboard}, $boardperms, $boardview) = split(/\|/, $board{$curboard});

			my $access = &AccessCheck($curboard, '', $boardperms);
			if (!$iamadmin && $access ne 'granted') { next; }

			my @temp = &read_DBorFILE(0,'',$boardsdir,$curboard,'txt');
			for (my $i = 0; $i < $topics; $i++) {
				my ($buffer, $mnum, $mdate, $mstate);

				$buffer = $temp[$i];
				last unless $buffer;
				chomp $buffer;

				($mnum, undef, undef, undef, $mdate, undef, undef, undef, $mstate) = split(/\|/, $buffer);
				$mdate = sprintf("%010d", $mdate);
				$mdate = $mnum if $rss_message == 2; # Sort by topic creation if requested.

				# Check if it's hidden. If so, don't show it
				if ($mstate =~ /h/ && !$iamadmin && !$iamgmod) { next; }

				# Add it to an array, using $mdate as the first value so we can easily sort
				push(@threadlist, "$mdate|$curboard|$buffer");
			}

			# Clean out the extra entries in the threadlist
			@threadlist = reverse sort @threadlist;
			@threadlist = @threadlist[0 .. $topics - 1];
		}
	}

	for($i = 0; $threadlist[$i]; $i++) {
		# Opening item stuff
		($mdate, $board, $mnum, $msub, $mname, $memail, $modate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $threadlist[$i]);
		$curnum = $mnum;

		($msub, undef) = &Split_Splice_Move($msub,0);
		&FromHTML($msub);
		&ToChars($msub);
		# Censor the subject of the thread.
		$msub = &Censor($msub);

		# Does it need to be returned as a 304?
		if($i == 0) { # Do this for the first request only
			$cachedate = &RFC822Date($mdate); 
			if($ENV{'HTTP_IF_NONE_MATCH'} eq qq~"$cachedate"~ || $ENV{'HTTP_IF_MODIFIED_SINCE'} eq $cachedate) {
				&Send304NotModified(); # Comment this out to test with caching disabled
			}
		}

		my $postid = "$mreplies#$mreplies";
		$postid = '0#0' if $rss_message == 2;

		my $category = "$mbname/$boardname{$board}";
		&FromHTML($category);
		my $bn = $boardname{$board};
		&FromHTML($bn);
		if ($accept_permalink){
			my $permsub = $msub;
			$permdate = &permtimer($curnum);
			$permsub =~ s~ ~$perm_spacer~g;
			$yymain .= qq~			<item>
			<title>~ . &RSSDescriptionTrim("$bn - $msub") . qq~</title>
			<link>~ . &RSSDescriptionTrim("http://$perm_domain/$symlink$permdate/$board/$curnum") . qq~</link>
			<category>~ . &RSSDescriptionTrim($category) . qq~</category>
			<guid isPermaLink="true">~ . &RSSDescriptionTrim("http://$perm_domain/$symlink$permdate/$board/$curnum") . qq~</guid>\n~;
		} else {
			$yymain .= qq~		<item>
			<title>~ . &RSSDescriptionTrim("$bn - $msub") . qq~</title>
			<link>~ . &RSSDescriptionTrim("$scripturl?num=$curnum/$postid") . qq~</link>
			<category>~ . &RSSDescriptionTrim($category) . qq~</category>
			<guid>~ . &RSSDescriptionTrim("$scripturl?num=$curnum/$postid") . qq~</guid>\n~;
		}

		my $post;
		if ($rss_message == 1) {
			# Open up the thread and read the last post.
			foreach (&read_DBorFILE(0,'',$datadir,$curnum,'txt')) {
				chomp $_;
				$post = $_ if $_;
			}
		} elsif ($rss_message == 2) {
			# Open up the thread and read the first post.
			$post = (&read_DBorFILE(0,'',$datadir,$curnum,'txt'))[0];
		}

		if ($post ne ''){
			(undef, undef, undef, undef, $musername, undef, undef, undef, $message, $ns) = split(/\|/, $post);
		}

		if ($showauthor) {
			# The spec really wants us to include their email.
			# That's not adviseable for us (spambots anyone?). So we skip author if the email hidden flag is on for that user.
			if (&checkfor_DBorFILE("$memberdir/$musername.vars")) {
				&LoadUser($musername); 
				if (!${$uid.$musername}{'hidemail'}){
					$yymain .= qq~			<author>~ . &RSSDescriptionTrim("${$uid.$musername}{'email'} (${$uid.$musername}{'realname'})") . qq~</author>\n~;
				}
			}
		}

		if ($showdate) {
			$mdate = $curnum if $rss_message == 2; # Sort by topic creation if requested.
			# Get the date how the user wants it.
			my $realdate = &RFC822Date($mdate);
			$yymain .= qq~			<pubDate>$realdate</pubDate>\n~;
		}

		if ($message ne '') {
			($message, undef) = &Split_Splice_Move($message,$curnum);
			if ($enable_ubbc) {
					&LoadUser($musername);
					$displayname = ${$uid.$musername}{'realname'};
					&DoUBBC;
			}
			&FromHTML($message);
			&ToChars($message);
			$message = &Censor($message);
			$yymain .= qq~			<description>~ . &RSSDescriptionTrim($message) . qq~</description>\n~;
		}

		$yymain .= qq~		</item>\n~;
	}

	&ToChars($boardname);
	$yytitle = "$topics $maintxt{'214b'}";
	$yydesc = ${$uid.$curboard}{'description'};

	&RSS_template();
}

sub RSS_template { # print RSS output
	# Generate the lastBuildDate
	my $rssdate = &RFC822Date($date);

	# Send out the "Last-Modified" and "ETag" headers so nice readers will ask before downloading.
	$LastModified = $ETag = $cachedate || $rssdate;
	$contenttype = 'text/xml';
	&print_output_header;

	# Make the generator look better
	my $RSSplver = $rssplver;
	$RSSplver =~ s/\$//g;

	# Removed per Corey's suggestion: http://www.yabbforum.com/community/YaBB.pl?num=1142571424/20#20
	#my $docs = "		<docs>http://$perm_domain</docs>\n" if $perm_domain;

	my $mainlink = $scripturl;
	$mainlink .= "?board=$INFO{'board'}" if $INFO{'board'};
	$mainlink .= "?catselect=$INFO{'catselect'}" if $INFO{'catselect'};

	my $tit = "$yytitle - $mbname";
	&FromHTML($tit);
	my $descr = ($boardname ? "$boardname - " : "") . $mbname;
	&FromHTML($descr);
	my $mn = $mbname;
	&FromHTML($mn);
	$output = qq~<?xml version="1.0" encoding="$yycharset" ?>
<!-- Generated by YaBB on $rssdate -->
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
	<channel>
		<atom:link href="$scripturl?action=$INFO{'action'}~ . ($INFO{'board'} ? ";board=$INFO{'board'}" : "") . qq~" rel="self" type="application/rss+xml" />
		<title>~ . &RSSDescriptionTrim($tit) . qq~</title>
		<link>~ . &RSSDescriptionTrim($mainlink) . qq~</link>
		<description>~ . &RSSDescriptionTrim($descr) . qq~</description>
		<language>~ . &RSSDescriptionTrim("$maintxt{'w3c_lngcode'}") . qq~</language>

		<copyright>~ . &RSSDescriptionTrim($mn) . qq~</copyright>
		<lastBuildDate>$rssdate</lastBuildDate>
		<docs>http://blogs.law.harvard.edu/tech/rss</docs>
		<generator>$RSSplver</generator>
		<ttl>30</ttl>
$yymain
	</channel>
</rss>~;

	&print_HTML_output_and_finish;
}

sub RSS_error {
	# This routine is mostly a copy of fatal_error except it uses RSS templating
	&LoadLanguage('Error');
	my($e_filename, $e_line, $e_subroutine, $l, $ot);
	# Gets filename and line where fatal_error was called.
	# Need to go further back to get correct subroutine name,
	# otherwise will print fatal_error as current subroutine!
	(undef, $e_filename, $e_line) = caller(0);
	(undef, undef, undef, $e_subroutine) = caller(1);
	(undef, $e_subroutine) = split(/::/, $e_subroutine);
	my($e,$t,$v) = @_;
	if ($t || $e) { $ot = "<b>$maintxt{'error_description'}</b>: $error_txt{$e} $t"; }
	if (($debug == 1 or ($debug == 2 && $iamadmin)) && ($e_filename || $e_line || $e_subroutine)) { $l = "<br />$maintxt{'error_location'}: $e_filename<br />$maintxt{'error_line'}: $e_line<br />$maintxt{'error_subroutine'}: $e_subroutine"; }
	if ($v) { $v = "<br />$maintxt{'error_verbose'}: $!"; }

	if ($elenable) {
		&fatal_error_logging("$ot$l$v");
	}

	my $tit = $error_txt{'error_occurred'};
	&FromHTML($tit);
	my $ed = "$ot$l$v";
	&FromHTML($ed);
	my $mn = $mbname;
	&FromHTML($mn);
	$yymain = qq~
	<item>
		<title>~ . &RSSDescriptionTrim($tit) . qq~</title>
		<description>~ . &RSSDescriptionTrim($ed) . qq~</description>
		<category>~ . &RSSDescriptionTrim($mn) . qq~</category>
	</item>~;

	&RSS_template();
}

sub Send304NotModified {
	print "Status: 304 Not Modified\n\n";
	exit;
}

sub RFC822Date {
	# Takes a Unix timestamp and returns the RFC-822 date format
	# of it: Sat, 07 Sep 2002 9:42:31 GMT
	my @GMTime = split(/ +/, gmtime(shift));
	"$GMTime[0], $GMTime[2] $GMTime[1] $GMTime[4] $GMTime[3] GMT";
}

sub RSSDescriptionTrim { # This formats the RSS
	my $x = $_[0];

	$x =~ s/ (class|style)\s*=\s*["'].+?['"]//g;

	$x =~ s/&/&#38;/g;
	$x =~ s/"/&#34;/g;
	$x =~ s~'~&#39;~g;
	$x =~ s/  / &#160;/g;
	$x =~ s/</&#60;/g;
	$x =~ s/>/&#62;/g;
	$x =~ s/\|/&#124;/g;
	$x =~ s/\{/&#123;/g;
	$x =~ s/\}/&#125;/g;

	$x;
}

sub shellaccess {
	# Parse the arguments
	my($data, $i, %arguments);

	for($i = 0; $i < @ARGV; $i++) {
		if($ARGV[$i] =~ /\A\-/) {
			my($option, $value);
			$option = $ARGV[$i];
			$option =~ s/\A\-\-?//;
			($option, $value) = split(/\=/, $option);
			$arguments{$option} = $value || '';
			unless(defined $arguments{$option}) {$arguments{$option} = 1;}
		}
	}

	### Requirements and Errors ###
	$script_root = $arguments{'script-root'};

	if (-e "Paths.pl") { require "Paths.pl"; }
	elsif (-e "$script_root/Paths.pl") { require "$script_root/Paths.pl"; }

	require "$vardir/Settings.pl";
	require "$sourcedir/Subs.pl";
	require "$sourcedir/DateTime.pl";
	require "$sourcedir/Load.pl";

	&LoadCookie;          # Load the user's cookie (or set to guest)
	&LoadUserSettings;    # Load user settings
	&WhatLanguage;        # Figure out which language file we should be using! :D

	require "$boardsdir/forum.master";
	require "$sourcedir/Security.pl";

	# Is RSS disabled?
	&RSS_error('rss_disabled') if $rss_disabled;

	$gzcomp = 0; # Disable gzip so we can talk clearly

	# Map %arguments to %INFO
	foreach my $var (qw(action board catselect topics)) {
		$INFO{$var} = $arguments{$var};
	}

	# Run the subroutine
	require "$sourcedir/SubList.pl";
	my $action = $INFO{'action'};
	my ($file,$sub) = split(/&/, $director{$action});
	if ($file eq 'RSS.pl') { &{$sub}(); }
	exit;
}

1;

__END__

# Sample subroutine to show how to use URL encoding
# If $_[1] is true, it fully encodes the text. If not, it just encodes non-word characters (\W).
sub urlencode {
	my($text, $mode) = ($_[0], $_[1]);
	#$text =~ s/(\W)/sprintf("%%%lx", ord($1));/eg; # Not good enough; doesn't make it 2 digits all the time

	### "Real Perl Hackers Use 'pack'" (tm) - jbert on Perlmonks
	if(!$mode) {$text =~ s/(\W)/'%' . unpack("H*", pack("C", ord($1)))/eg;}
	elsif($mode) {$text =~ s/(.)/'%' . unpack("H*", pack("C", ord($1)))/eg;}
	return $text;
}

=pod

=head1 Command line usage

To make it possible for most programming languages to easily get output from this script, we have a command line mode.
To do this, simply run "$sourcedir/RSS.pl (ARGUMENTS)". The RSS feed will be sent to STDOUT.

=head1 Command line arguments

You must give at least one argument so we know we're running as a commandline script.

All options are given delimited by equal signs, for instance:

Sources/RSS.pl --action=RSS_board

If you need to insert a character with a special meaning such as a space, equals sign, or percent sign: use the URL encoding format. The subroutine &urlencode found in this file should show how to encode properly.

For true/false values, 0 is false and anything else is true (even without an option).

=head2 Required argument

=over 12

=item C<--action>

Action to run. This is the exact same as the actions found in SubList.pl that belong to this file.

=back

=head3 Optional argument

=over 12

=item C<--script-root>

Changes the script root used to load Paths.pl from.

=back

=head2 Optional arguments for action=RSSrecent

=over 12

=item C<--catselect>

Category to use for recent posts.

=item C<--showauthor>

Show the author's email address and name? Defaults to false. Working only if allowed by forum Admin

=item C<--topics>

Number of topics to show. Can be anywhere from 1 to 10, and it defaults to 5.

=back

=head2 Required arguments for action=RSSboard

=over 12

=item C<--board>

Board ID to use.

=back

=head3 Optional arguments for action=RSSboard

=over 12

=item C<--showauthor>

Show the author's name? Defaults to false.

=item C<--topics>

Number of topics to show. Can be anywhere from 1 to 10, and it defaults to 5.

=back

=cut