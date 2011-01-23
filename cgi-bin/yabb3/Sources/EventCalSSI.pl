###############################################################################
# EventCalSSI.pl                                                              #
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

$eventcalssiplver = 'YaBB 3.0 Beta $Revision: 100 $';

&LoadLanguage('EventCal');

sub get_cal_ssi {
	$calssimode = $INFO{'calssimode'};
	$calssidays = $INFO{'calssidays'};

	## EventCal SSI Check START ##
	my $curcaldisplay;
	if ($Show_EventCal) {
		if (!$iamguest || $Show_EventCal == 2) {
			require "$sourcedir/EventCal.pl";
			$curcaldisplay = &get_cal($calssimode,$calssidays);
		}
	}
	## EventCal SSI Check END ##

	## PRINT SSI EventCal ##

	print qq~Content-type: text/html\n\n~;
	if ($curcaldisplay) {
		print $curcaldisplay;
	} else {
		print $ml_txt{'223'};
	}
	exit;
}

1;