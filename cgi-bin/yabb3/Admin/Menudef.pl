###############################################################################
# Menudef.pl                                                                  #
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

# Many thanks to Carsten for his original contribution!!!
#-------------------------------------------------------------------#
# Menu.pl							    #
#-------------------------------------------------------------------#
# CSS Buttons 4 YaBB 2.4					    #
# Version 0.1.3							    #
# by Carsten Dalgaard						    #
#-------------------------------------------------------------------#
# Copyright: 2009 'Carsten Dalgaard' - All Rights Reserved	    #
# Released: May 1, 2009						    #
# e-mail: carsten.dalgaard@gmail.com				    #
#-------------------------------------------------------------------#
# Any redistribution of this script without the expressed written   #
# consent of 'Carsten Dalgaard' is strictly prohibited. Copying     #
# any	of the code contained within this script and claiming it as #
# your own is also prohibited.					    #
#-------------------------------------------------------------------#
# By using this script you agree to indemnify 'Carsten Dalgaard'    #
# from any liability that might arise from its use.		    #
#-------------------------------------------------------------------#
# You may not remove any of these header notices.		    #
#-------------------------------------------------------------------#

$menuplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

$imgext = "gif";

sub SetMenu {
	%img = map /(.*),(.*)\n/, &read_DBorFILE(0,'',$vardir,'Menu','def');

	my (%def0,%def1,%def2,%def3);

	foreach (keys %img) {
		my ($button_icon, $button_text, $text_num, $alt_text, $alt_num, $span_class, $mod_or_not) = split(/\|/, $img{$_});

		if (!$alt_text) {
			$alt_text = $button_text;
			$alt_num = $text_num;
		}

		if ($mod_or_not eq 'mod') {
			$button_imgurl = $modimgurl;
		} else {
			$button_imgurl = qq~\$yyhtml_root/\$templatesdir/Forum/\$usestyle~;
		}

		$helpstyle = $_ eq 'help' ? " cursor: help;" : " cursor: pointer;";

		if ($_ !~/^(lastpost|poll(icon|iconnew|iconclosed))$/) {
			$def0{$_} = qq~<span style="white-space: nowrap;" class="$span_class"><img src="$button_imgurl/$button_icon.$imgext" border="0" alt="\$$alt_text\{'$alt_num'}" /> \$$button_text\{'$text_num'}</span>~;

			$def1{$_} = qq~<span style="white-space: nowrap;" class="$span_class">\$$button_text\{'$text_num'}</span>~;

			$def2{$_} = qq~<span class="buttonleft" title="\$$alt_text\{'$alt_num'}" style="height: 20px; border: 0px; margin: 1px 1px; background-position: top left; background-repeat: no-repeat; text-decoration: none; font-size: 18px; vertical-align: top; display: inline-block;$helpstyle">~;
			$def2{$_} .= qq~<span class="buttonright" style="height: 20px; border: 0px; margin: 0px; background-position: top right; background-repeat: no-repeat; text-decoration: none; font-size: 18px; vertical-align: top; display: inline-block;">~;
			$def2{$_} .= qq~<span class="buttonimage" style="height: 20px; border: 0px; margin: 0px; background-image: url( $button_imgurl/$button_icon.$imgext ); background-repeat: no-repeat; vertical-align: top; text-decoration: none; font-size: 18px; display: inline-block;">~;
			$def2{$_} .= qq~<span class="buttontext" style="height: 20px; border: 0px; margin: 0px; padding: 0px; text-align: left; text-decoration: none; vertical-align: top; white-space: nowrap; display: inline-block;">\$$button_text\{'$text_num'}</span></span></span></span>~;
			
			$def3{$_} = qq~\$imagesdir/$button_icon.$imgext|\$$button_text\{'$text_num'}~;
		} else {
			$def0{$_} = $def1{$_} = $def2{$_} = qq~<img src="$button_imgurl/$button_icon.$imgext" alt="\$$button_text\{'$text_num'}" border="0" />~;
		}
		$def3{$_} = qq~\$imagesdir/$button_icon.$imgext|\$$button_text\{'$text_num'}~;
	}

	foreach my $deffile (0,1,2,3) {
		my @file = (
"###############################################################################
# Menu$deffile.def (Image text/images definitions)                                   #
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

");

		if ($deffile == 0) {
			push(@file, "\$menusep = ' &nbsp; ';\n\n\%img = (\n");
			foreach (sort(keys %def0)) {
				push(@file, qq*'$_' => qq~$def0{$_}~,\n*);
			}
		} elsif ($deffile == 1) {
			push(@file, "\$menusep = ' | ';\n\n\%img = (\n");
			foreach (sort(keys %def1)) {
				push(@file, qq*'$_' => qq~$def1{$_}~,\n*);
			}
		} elsif ($deffile == 2) {
			push(@file, qq*\$menusep = qq~<img src="\$yyhtml_root/\$templatesdir/Forum/\$usestyle/buttonsep.png" style="height: 20px; width: 1px; margin: 0px; padding: 0px; vertical-align: top; display: inline-block;" alt="" title="" border="0" />~;\n\n\%img = (\n*);
			foreach (sort(keys %def2)) {
				push(@file, qq*'$_' => qq~$def2{$_}~,\n*);
			}
		} else {
			push(@file, "\$menusep = ' ';\n\n\%def_img = (\n");
			foreach (sort(keys %def2)) {
				push(@file, qq*'$_' => qq~$def3{$_}~,\n*);
			}
		}
		push(@file, ");\n\n1;");
		&write_DBorFILE(0,'',$vardir,"Menu$deffile",'def',@file);
	}
}

1;