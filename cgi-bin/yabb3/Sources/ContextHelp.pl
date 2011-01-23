###############################################################################
# ContextHelp.pl						                                      #
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

# Many thanks to Carsten Dalgaard (http://www.carsten-dalgaard.dk/) for his contibution to the YaBB community

$contexthelpplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }


sub ContextScript {
&LoadLanguage('ContextHelp');

my $contextmain;
if($_[0] eq "post") { $contextmain = $contextpost; }

undef %contextxt;

$ctmain .= qq~
	<script language="JavaScript1.2" type="text/javascript">
	<!--
	function Hash()	{
		this.length = 0;
		this.items = new Array();
		for (var i = 0; i < arguments.length; i += 2) {
			if (typeof(arguments[i + 1]) != 'undefined') {
				this.items[arguments[i]] = arguments[i + 1];
				this.length++;
			}
		}

		this.getItem = function(in_key) {
			return this.items[in_key];
		}
	}

	$contextmain
	document.write('<div id="contexthlp" class="windowbg" style="position: absolute; top: 20px; left: 20px; width: 400px; filter: alpha(opacity=95); opacity: 0.95; border: 1px solid black; z-index: 10000; display: none;">');
	document.write('<div id="contexttitle" class="titlebg" style="filter: alpha(opacity=100); opacity: 1.0; padding: 6px;">context_title</div>');
	document.write('<div id="contexttext" class="windowbg" style="filter: alpha(opacity=100); opacity: 1.0; padding: 8px;">context_text</div>');
	document.write('</div>');
	document.write('<div id="ctxtip" style="position: absolute; top: 20px; left: 90px; font: 11px Helvetica, sans-serif; color: #000; background-color: #ffffdd; border: 1px solid black; padding: 1px 4px; z-index: 10000; display: none;"></div>');
	DocClick.push("hidecontexthelp()");

	function sizecontexthelp() {
		if (!document.all) {
			var wtop = window.pageYOffset;
			var wleft = window.pageXOffset;
			var wsize = parseInt(window.innerWidth / 2);
		}
		else {
			var wtop = document.documentElement.scrollTop;
			var wleft = document.documentElement.scrollLeft;
			var wsize = parseInt(document.documentElement.clientWidth / 2);
		}
		document.getElementById("contexthlp").style.width = wsize + 'px';
		document.getElementById("contexthlp").style.left = wleft + (wsize / 2) + 'px';
		document.getElementById("contexthlp").style.top = wtop + 50 + 'px';
		document.getElementById("contexthlp").style.display = 'inline';
	}

	function showcontexthelp(conimage, contitle) {
		var conkey, contextimage, contexthelp = '';
		conkey = conimage.replace(/(.*)\\/(.*?)\\.(gif|png)/, "\$2");
		if(conkey) contextimage = '<img src=' + conimage + ' alt=" ' + contitle + ' " style="vertical-align: middle" \/>';
		else conkey = conimage;
		contexthelp = contexthash.getItem(conkey);
		if(contexthelp == '') return true;
		sizecontexthelp();
		contexthelp = contexthelp.replace(/\\[TITLE\\]/g, contitle);
		contexthelp = contexthelp.replace(/\\[BUTTON\\]/g, contextimage);
		contexthelp = contexthelp.replace(/\\[SELECT\\](.*?)\\[\\/SELECT\\]/g, '<span style=\"color: white\; background-color: darkblue\">\$1</span>');
		contexthelp = contexthelp.replace(/\\[CODE\\](.*?)\\[\\/CODE\\]/g, '<pre class=\"code\" style=\"margin: 0px\; width: 90%\; overflow: scroll\;\">\$1</pre>');
		contexthelp = contexthelp.replace(/\\[QUOTE\\](.*?)\\[\\/QUOTE\\]/g, '<div class=\"quote\" style=\"width: 90%\">\$1</div>');
		contexthelp = contexthelp.replace(/\\[EDIT\\](.*?)\\[\\/EDIT\\]/g, '<div class=\"editbg\" style=\"overflow: auto\">\$1</div>');
		contexthelp = contexthelp.replace(/\\[ME\\]\\s(.*)/g, '<span style=\"color: #FF0000\"><i>\\* $displayname \$1</i></span>');
		contexthelp = contexthelp.replace(/\\[MOVE\\](.*?)\\[\\/MOVE\\]/g, '<marquee>\$1</marquee>');
		contexthelp = contexthelp.replace(/\\[HIGHLIGHT\\](.*?)\\[\\/HIGHLIGHT\\]/g, '<span class=\"highlight\">\$1</span>');
		contexthelp = contexthelp.replace(/\\[PRE\\](.*?)\\[\\/PRE\\]/g, '<pre>\$1</pre>');
		contexthelp = contexthelp.replace(/\\[LEFT\\](.*?)\\[\\/LEFT\\]/g, '<div style=\"text-align: left\">\$1</div>');
		contexthelp = contexthelp.replace(/\\[CENTER\\](.*?)\\[\\/CENTER\\]/g, '<center>\$1</center>');
		contexthelp = contexthelp.replace(/\\[RIGHT\\](.*?)\\[\\/RIGHT\\]/g, '<div style=\"text-align: right\">\$1</div>');
		contexthelp = contexthelp.replace(/\\[RED\\](.*?)\\[\\/RED\\]/g, '<span style=\"color: #FF0000\">\$1</span>');
		document.getElementById("contexttitle").innerHTML = contextimage + ' ' + contitle;
		document.getElementById("contexttext").innerHTML = contexthelp;
		return false;
	}

	function hidecontexthelp() {
		document.getElementById("contexthlp").style.display = 'none';
	}

	var images = document.getElementsByTagName('img');
	var thetitle, tmpi;

	function tmpTitle(txtitle) {
		for(var i=0; i<images.length;i++) {
			thetitle = txtitle;
			var titlevalue = images[i].alt;
			if(titlevalue == txtitle) {
				images[i].title = '';
				tmpi = i;
			}
		}
	}

	function orgTitle() {
		images[tmpi].title = thetitle;
	}

	function contextTip(e, ctxtitle) {
		if (/Opera[\\/\\s](\\d+\\.\\d+)/.test(navigator.userAgent)) {
			var oprversion=new Number(RegExp.\$1);
			if (oprversion < 9.8) return;
		}

		var dsize = document.getElementById('ctxtip').offsetWidth;
		if (!document.all) {
			var wsize = window.innerWidth;
			var wleft = e.pageX - parseInt(dsize/4);
			var wtop = e.pageY + 20;
		}
		else {
			var wsize = document.documentElement.clientWidth;
			var wleft = (e.clientX + document.documentElement.scrollLeft) - parseInt(dsize/4);
			var wtop = e.clientY + document.documentElement.scrollTop + 20;
		}
		if (document.getElementById('ctxtip').style.display == 'inline') {
			orgTitle();
			document.getElementById('ctxtip').style.display = 'none';
		}
		else {
			if (wleft < 2) wleft = 2;
			else if (wleft + dsize > wsize) wleft -= dsize/2;
			document.getElementById('ctxtip').style.left = wleft + 'px';
			document.getElementById('ctxtip').style.top = wtop + 'px';
			document.getElementById('ctxtip').style.display = 'inline';
			document.getElementById('ctxtip').innerHTML = ctxtitle + ' | ' + contexthash.getItem('contexttip');
			tmpTitle(ctxtitle);
		}
	}

	-->
	</script>
~;
}

1;