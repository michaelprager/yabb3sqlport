###############################################################################
# SpamCheck.pl                                                                #
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

$spamcheckplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub spamcheck {
	my ($rawcontent) = $_[0];
	$rawcontent =~ s/[\r\n\t]/ /g;				#convert cr/lf/tab to space
	$rawcontent =~ s/\[(.*?){1,2}\]//g;			# rip out all make up yabb tags if it is a non yabbc message which can be uses to break and obscure words
	$rawcontent =~ s/\<(.*?){1,2}\>//g;			# rip out all make up html tags if it is a html message which can be uses to break and obscure words
	my $testcontent = lc(" $rawcontent");			#add a leading space to trace start of the very first word and make it lowercase
	my ($spamline,$spamcnt,$searchtype);
	if (&checkfor_DBorFILE("$vardir/spamrules.txt")) {
		foreach my $buffer (&read_DBorFILE(0,'',$vardir,'spamrules','txt')) {
			chomp $buffer;
			$spamline = "";
			if ($buffer =~ m/\~\;/) {
				($spamcnt,$spamline) = split(/\~\;/, $buffer);
				$searchtype = "S";
			} elsif ($buffer =~ m/\=\;/) {
				($spamcnt,$spamline) = split(/\=\;/, $buffer);
				$searchtype = "E";
			} else {
				if ($buffer ne ""){ 
					$spamline = $buffer;
					$spamcnt = 0;
					$searchtype = "S";
				}
			}
			if(!$spamcnt){ $spamcnt = 0;}
			if($spamline ne ""){ push(@spamlines, [$spamline, $spamcnt, $searchtype]); }
		}
	}

	for $spamrule (@spamlines) {
		chomp $spamrule;
		$is_spam = 0;
		($spamword,$spamlimit,$spamtype) = @{$spamrule};
		if ($spamtype eq "S" ) {
			@spamcount = $testcontent =~ /$spamword/gsi;
		} elsif ($spamtype eq "E" ) {
			@spamcount = $testcontent =~ /\b$spamword\b/gsi;
		}
		$spamcounter = $#spamcount + 1;
		if ($spamcounter > $spamlimit){ 
			$is_spam = 1;
			last;
		}
	}
#	&fatal_error("error_occurred","$testcontent|$is_spam|$spamword|$spamcount|$spamtype");
	return $is_spam;
	return $spamword;
}

1;