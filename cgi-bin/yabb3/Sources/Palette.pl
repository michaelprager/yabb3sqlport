###############################################################################
# Palette.pl                                                                  #
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

$paletteplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub ColorPicker {
	my $picktask = $INFO{'task'};

	if ($INFO{'palnr'} && $iamadmin) {
		my @new_pal;
		for (my $i = 0; $i < @pallist; $i++) {
			if ($i == ($INFO{'palnr'} - 1) && $INFO{'palcolor'}) { push(@new_pal, "#$INFO{'palcolor'}"); }
			else { push(@new_pal, "$pallist[$i]"); }
		}
		@pallist = @new_pal;

		require "$admindir/NewSettings.pl";
		&SaveSettingsTo('Settings.pl');
	}

	$gzcomp = 0;
	&print_output_header;

	print qq~
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>Palette</title>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<link rel="stylesheet" href="$forumstylesurl/$usestyle.css" type="text/css" />

<script language="JavaScript1.2" type="text/javascript">
<!--
var picktask = '$picktask';

function Pickshowcolor(color) {
	if ( c=color.match(/rgb\\((\\d+?)\\, (\\d+?)\\, (\\d+?)\\)/i) ) {
		var rhex = tohex(c[1]);
		var ghex = tohex(c[2]);
		var bhex = tohex(c[3]);
		var newcolor = '#'+rhex+ghex+bhex;
	}
	else {
		var newcolor = color;
	}
	if(picktask == "post") {
		passcolor=newcolor.replace(/#/, "");
		if(document.getElementById("defpal1").checked) {
			opener.document.getElementById("defaultpal1").style.backgroundColor=newcolor;
			location.href='$scripturl?action=palette;palnr=1;palcolor=' + passcolor + ';task=$picktask';
		}
		else if(document.getElementById("defpal2").checked) {
			opener.document.getElementById("defaultpal2").style.backgroundColor=newcolor;
			location.href='$scripturl?action=palette;palnr=2;palcolor=' + passcolor + ';task=$picktask';
		}
		else if(document.getElementById("defpal3").checked) {
			opener.document.getElementById("defaultpal3").style.backgroundColor=newcolor;
			location.href='$scripturl?action=palette;palnr=3;palcolor=' + passcolor + ';task=$picktask';
		}
		else if(document.getElementById("defpal4").checked) {
			opener.document.getElementById("defaultpal4").style.backgroundColor=newcolor;
			location.href='$scripturl?action=palette;palnr=4;palcolor=' + passcolor + ';task=$picktask';
		}
		else if(document.getElementById("defpal5").checked) {
			opener.document.getElementById("defaultpal5").style.backgroundColor=newcolor;
			location.href="$scripturl?action=palette;palnr=5;palcolor=" + passcolor + ';task=$picktask';
		}
		else if(document.getElementById("defpal6").checked) {
			opener.document.getElementById("defaultpal6").style.backgroundColor=newcolor;
			location.href='$scripturl?action=palette;palnr=6;palcolor=' + passcolor + ';task=$picktask';
		}
		else {
			window.close();
			opener.AddSelText("[color="+newcolor+"]","[/color]");
		}
	}
	else {
		if(picktask == "templ") opener.previewColor(newcolor);
		if(picktask == "templ_0") opener.previewColor_0(newcolor);
		if(picktask == "templ_1") opener.previewColor_1(newcolor);
	}
//	window.close();
}

//-->
</script>
</head>

<body>
<div class="windowbg" style="position: absolute; top: 0px; left: 0px; width: 302px; height: 308px; border: 1px black outset;">
<div style="position: relative; top: 4px; left: 5px; width: 289px; height: 209px; padding-left: 1px; padding-top: 1px; border: 0px; background-color: black;">~;

	for (my $z = 0; $z < 256; $z += 51) {
		my $c1 = sprintf("%02x", $z);
		for (my $y = 0; $y < 256; $y += 51) {
			my $c2 = sprintf("%02x", $y);
			for (my $x = 0; $x < 256; $x += 51) {
				my $c3 = sprintf("%02x", $x);
				print qq~\n	<span title="#$c3$c2$c1" style="float: left; background-color: #$c3$c2$c1; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="Pickshowcolor('#$c3$c2$c1')">&nbsp;</span>~;
			}
		}
	}

	print qq~
	<span style="float: left; background-color: #222222; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="Pickshowcolor('#222222')">&nbsp;</span>
	<span style="float: left; background-color: #333333; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="Pickshowcolor('#333333')">&nbsp;</span>
	<span style="float: left; background-color: #444444; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="Pickshowcolor('#444444')">&nbsp;</span>
	<span style="float: left; background-color: #555555; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="Pickshowcolor('#555555')">&nbsp;</span>
	<span style="float: left; background-color: #666666; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="Pickshowcolor('#666666')">&nbsp;</span>
	<span style="float: left; background-color: #777777; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="Pickshowcolor('#777777')">&nbsp;</span>
	<span style="float: left; background-color: #888888; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="Pickshowcolor('#888888')">&nbsp;</span>
	<span style="float: left; background-color: #aaaaaa; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="Pickshowcolor('#aaaaaa')">&nbsp;</span>
	<span style="float: left; background-color: #bbbbbb; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="Pickshowcolor('#bbbbbb')">&nbsp;</span>
	<span style="float: left; background-color: #cccccc; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="Pickshowcolor('#cccccc')">&nbsp;</span>
	<span style="float: left; background-color: #dddddd; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="Pickshowcolor('#dddddd')">&nbsp;</span>
	<span style="float: left; background-color: #eeeeee; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px; cursor: pointer; cursor: hand;" onclick="Pickshowcolor('#eeeeee')">&nbsp;</span>
	<form name="dodefpal" id="dodefpal" action="">~;

	if ($iamadmin && $picktask eq "post") {
		print qq~
	<span id="defpal_1" style="float: left; text-align: center; background-color: $pallist[0]; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px;"><input type="radio" name="defpal" id="defpal1" value="defcolor1" style="width: 13px; height: 13px; vertical-align: middle; font-size: 5px; padding: 0px; margin: 0px; border: 0px; background-color: $pallist[0];" title="Default palette" /></span>
	<span id="defpal_2" style="float: left; text-align: center; background-color: $pallist[1]; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px;"><input type="radio" name="defpal" id="defpal2" value="defcolor2" style="width: 13px; height: 13px; vertical-align: middle; font-size: 5px; padding: 0px; margin: 0px; border: 0px; background-color: $pallist[1];" title="Default palette" /></span>
	<span id="defpal_3" style="float: left; text-align: center; background-color: $pallist[2]; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px;"><input type="radio" name="defpal" id="defpal3" value="defcolor3" style="width: 13px; height: 13px; vertical-align: middle; font-size: 5px; padding: 0px; margin: 0px; border: 0px; background-color: $pallist[2];" title="Default palette" /></span>
	<span id="defpal_4" style="float: left; text-align: center; background-color: $pallist[3]; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px;"><input type="radio" name="defpal" id="defpal4" value="defcolor4" style="width: 13px; height: 13px; vertical-align: middle; font-size: 5px; padding: 0px; margin: 0px; border: 0px; background-color: $pallist[3];" title="Default palette" /></span>
	<span id="defpal_5" style="float: left; text-align: center; background-color: $pallist[4]; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px;"><input type="radio" name="defpal" id="defpal5" value="defcolor5" style="width: 13px; height: 13px; vertical-align: middle; font-size: 5px; padding: 0px; margin: 0px; border: 0px; background-color: $pallist[4];" title="Default palette" /></span>
	<span id="defpal_6" style="float: left; text-align: center; background-color: $pallist[5]; width: 15px; height: 15px; margin-right: 1px; margin-bottom: 1px; border: 0px; font-size: 5px;"><input type="radio" name="defpal" id="defpal6" value="defcolor6" style="width: 13px; height: 13px; vertical-align: middle; font-size: 5px; padding: 0px; margin: 0px; border: 0px; background-color: $pallist[5];" title="Default palette" /></span>~;

	} else {
		print qq~
	<input type="hidden" id="defpal1" value="" />
	<input type="hidden" id="defpal2" value="" />
	<input type="hidden" id="defpal3" value="" />
	<input type="hidden" id="defpal4" value="" />
	<input type="hidden" id="defpal5" value="" />
	<input type="hidden" id="defpal6" value="" />
	~;
	}

	print qq~
	</form>
</div>
<div style="position: relative; top: 9px; left: 5px; width: 289px; height: 17px; border: 1px black solid;">
	<span id="viewcolor" style="float: left; width: 192px; height: 17px; border-right: 1px black solid; font-size: 5px; cursor: pointer; cursor: hand;" onclick="Pickshowcolor(this.style.backgroundColor)">&nbsp;</span>
	<span style="float: right; width: 72px; height: 15px;">
	<input class="windowbg" name="viewcode" id="viewcode" type="text" style="width: 70px; font-size: 11px; border: 0px; display: inline;" readonly="readonly" />
	</span>
</div>
<div class="catbg" style="position: relative; top: 15px; left: 10px; width: 277px; height: 56px; border-width: 1px; border-style: outset;">
	<img src="$defaultimagesdir/knapbagrms01.gif" alt="" style="position: absolute; top: 0px; left: 0px; z-index: 1; width: 275px; height: 16px;" />
	<img id="knapImg1" src="$defaultimagesdir/knapred.gif" alt="" class="skyd" style="position: absolute; left: 4px; top: 2px; cursor: pointer; cursor: hand; z-index: 2; width: 13px; height: 15px;" />
	<img src="$defaultimagesdir/knapbagrms01.gif" alt="" style="position: absolute; top: 16px; left: 0px; z-index: 1; width: 275px; height: 16px;" />
	<img id="knapImg2" src="$defaultimagesdir/knapgreen.gif" alt="" class="skyd" style="position: absolute; left: 4px; top: 18px; cursor: pointer; cursor: hand; z-index: 2; width: 13px; height: 15px;" />
	<img src="$defaultimagesdir/knapbagrms01.gif" alt="" style="position: absolute; top: 32px; left: 0px; z-index: 1; width: 275px; height: 16px;" />
	<img id="knapImg3" src="$defaultimagesdir/knapblue.gif" alt="" class="skyd" style="position: absolute; left: 4px; top: 34px; cursor: pointer; cursor: hand; z-index: 2; width: 13px; height: 15px;" />
</div>
</div>

<script language="JavaScript1.2" src="$yyhtml_root/palette.js" type="text/javascript"></script>

</body>
</html>~;
}

1;