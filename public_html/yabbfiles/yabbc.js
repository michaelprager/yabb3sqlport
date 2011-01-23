//##############################################################################
//# yabbc.js                                                                   #
//##############################################################################
//# YaBB: Yet another Bulletin Board                                           #
//# Open-Source Community Software for Webmasters                              #
//# Version:        YaBB 3.0 Beta                                              #
//# Packaged:       October 05, 2010                                           #
//# Distributed by: http://www.yabbforum.com                                   #
//# ===========================================================================#
//# Copyright (c) 2000-2010 YaBB (www.yabbforum.com) - All Rights Reserved.    #
//# Software by:  The YaBB Development Team                                    #
//#               with assistance from the YaBB community.                     #
//##############################################################################


//YaBB 3.0 Beta $Revision: 100 $

var LivePrevDisplayNames = new Object();

function jsDoTohtml(tohtmlstr) {
	tohtmlstr=tohtmlstr.replace(/\&/g, "&amp;");
	tohtmlstr=tohtmlstr.replace(/\"/g, "&quot;");
	tohtmlstr=tohtmlstr.replace(/  /g, " &nbsp;");
	tohtmlstr=tohtmlstr.replace(/\|/g, "&#124;");
	tohtmlstr=tohtmlstr.replace(/\</g, "&lt;");
	tohtmlstr=tohtmlstr.replace(/\>/g, "&gt;");
	return tohtmlstr;
}

function jsDoUbbc(ubbcstr,codestrg,quotstrg,squotstrg,editxt,dspname,scriptul,imagesdir,smilieurl,parsflash,fontmax,fontmin,autolinkurls,month,timeselect,splittxt,dontusetoday,todaytext,yesterdaytext,timetxt1,timetxt2,timetxt3,timetxt4,jssmilieurl,jssmiliecode,showimagequote) {

	ubbcstr=ubbcstr.replace(/\r/g, "");
	ubbcstr=ubbcstr.replace(/\cM/g, "");
	ubbcstr=ubbcstr.replace(/\[([^\]]{0,30})\n([^\]]{0,30})\]/g, '[$1$2]');
	ubbcstr=ubbcstr.replace(/\[\/([^\]]{0,30})\n([^\]]{0,30})\]/g, '[/$1$2]');
	ubbcstr=ubbcstr.replace(/(\w+:\/\/[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)/g, '$1$2');

	ubbcstr=ubbcstr.replace(/\&/g, "&amp;");
	ubbcstr=ubbcstr.replace(/\"/g, "&quot;");
	ubbcstr=ubbcstr.replace(/  /g, " &nbsp;");
	ubbcstr=ubbcstr.replace(/\|/g, "&#124;");
	ubbcstr=ubbcstr.replace(/\$/g, "&#36;");
	ubbcstr=ubbcstr.replace(/\</g, "&lt;");
	ubbcstr=ubbcstr.replace(/\>/g, "&gt;");

	ubbcstr=ubbcstr.replace(/\n/g, "<br />");

	if (document.postmodify.ns.checked) {
		return ubbcstr;
	}


	ubbcstr=ubbcstr.replace(/\[ch(\d{3,}?)\]/ig, "&#$1;");
	
	while( a=ubbcstr.match(/\[noparse\]\n*(.*?)\n*\[\/noparse\]/i) ) {
		var npmessage=a[1];
		npmessage=npmessage.replace(/\./g, "&#46;");
		npmessage=npmessage.replace(/\//g, "&#47;");
		npmessage=npmessage.replace(/\[/g, "&#91;");
		npmessage=npmessage.replace(/\]/g, "&#93;");
		ubbcstr=ubbcstr.replace(/\[noparse\]\n*(.*?)\n*\[\/noparse\]/i, npmessage);
	}

	ubbcstr=ubbcstr.replace(/\[code(.*?)\]/ig, " [code$1]");
	ubbcstr=ubbcstr.replace(/\[\/code\]/ig, " [/code]");
	ubbcstr=ubbcstr.replace(/\[quote\]/ig, " [quote]");
	ubbcstr=ubbcstr.replace(/\[\/quote\]/ig, " [/quote]");
	ubbcstr=ubbcstr.replace(/\[img\]/ig, " [img]");
	ubbcstr=ubbcstr.replace(/\[\/img\]/ig, " [/img]");

	function codeConvStr() {
		comessage='$1';
		codestrg=codestrg.replace(/CODE/g, comessage);
		return codestrg;
	}

	ubbcstr=ubbcstr.replace(/(\[code\s*([a-z|\+]{0,})\]\n*(.+?)\n*\[\/code\])/ig, codeConvStr());

	while( a=ubbcstr.match(/\[code\s*([a-z|\+]{0,})\]\n*(.+?)\n*\[\/code\]/i) ) {
		var clang=a[1];
		var clanguage = '';
		var cclass = 'code';

		if(clang.match(/c\+\+/i)) { clanguage = " (C++)"; cclass = "sh_cpp"; }
		else if(clang.match(/css/i)) { clanguage = " (CSS)"; cclass = "sh_css"; }
		else if(clang.match(/html/i)) { clanguage = " (HTML)"; cclass = "sh_html"; }
		else if(clang.match(/javascript/i)) { clanguage = " (Javascript)"; cclass = "sh_javascript"; }
		else if(clang.match(/java/i)) { clanguage = " (Java)"; cclass = "sh_java"; }
		else if(clang.match(/pascal/i)) { clanguage = " (Pascal)"; cclass = "sh_pascal"; }
		else if(clang.match(/perl/i)) { clanguage = " (Perl)"; cclass = "sh_perl"; }
		else if(clang.match(/php/i)) { clanguage = " (php)"; cclass = "sh_php"; }
		else if(clang.match(/sql/i)) { clanguage = " (SQL)"; cclass = "sh_sql"; }

		ubbcstr=ubbcstr.replace(/XLANGX/, clanguage);

		var cmessage=a[2];
		cmessage=cmessage.replace(/\[code\s*([a-z|\+]{0,})\]/g, "[code]");
		linepatt = /\<br \/\>/;
		linecount = cmessage.split(linepatt);
		if (linecount.length > 20) {
			theight = " height: 300px; ";
		} else {
			theight = " ";
		}
		if (! cmessage.match(/\&\S*\;/g)) {
			cmessage=cmessage.replace(/\;/g, "&#059;");
		}
		cmessage=cmessage.replace(/\!/g, "&#33;");
		cmessage=cmessage.replace(/\(/g, "&#40;");
		cmessage=cmessage.replace(/\)/g, "&#41;");
		cmessage=cmessage.replace(/\-/g, "&#45;");
		cmessage=cmessage.replace(/\./g, "&#46;");
		cmessage=cmessage.replace(/\//g, "&#47;");
		cmessage=cmessage.replace(/\:/g, "&#58;");
		cmessage=cmessage.replace(/\?/g, "&#63;");
		cmessage=cmessage.replace(/\[/g, "&#91;");
		cmessage=cmessage.replace(/\/\//g, "&#92;");
		cmessage=cmessage.replace(/\]/g, "&#93;");
		cmessage=cmessage.replace(/\^/g, "&#94;");
		cmessage=cmessage.replace(/\&\#91\;highlight\&\#93\;(.*?)\&\#91\;\&\#47\;highlight\&\#93\;/ig, "<span class='highlight'>$1</span>");
		cmessage=cmessage.replace(/\&nbsp; \&nbsp; \&nbsp;/ig, "\t");
		cmessage=cmessage.replace(/\&nbsp;/ig, " ");
		cmessage=cmessage.replace(/\n/g, "[code_br]");
		cmessage = "<pre class='" + cclass + "' style='margin: 0px; width: 90%;"+theight+"overflow: auto;'>"+cmessage+"[code_br][code_br]</pre>";

		ubbcstr=ubbcstr.replace(/\[code\s*([a-z|\+]{0,})\]\n*(.+?)\n*\[\/code\]/i, cmessage);
	}

	ubbcstr=ubbcstr.replace(/\[smilie=(\S+\.)(gif|jpg|png|bmp)\]/g, "<img src='"+smilieurl+"/$1$2' border='0' alt='$1' />");
	ubbcstr=ubbcstr.replace(/\[smiley=(\S+\.)(gif|jpg|png|bmp)\]/g, "<img src='"+smilieurl+"/$1$2' border='0' alt='$1' />");
	ubbcstr=ubbcstr.replace(/(\W|^)\;\)/g, "$1<img border='0' src='"+imagesdir+"/wink.gif' alt='Wink' />");
	ubbcstr=ubbcstr.replace(/(\W|^)\;\-\)/g, "$1<img border='0' src='"+imagesdir+"/wink.gif' alt='Wink' />");
	ubbcstr=ubbcstr.replace(/(\W|^)\;D/g, "$1<img border='0' src='"+imagesdir+"/grin.gif' alt='Grin' />");
	ubbcstr=ubbcstr.replace(/\:\'\(/g, "<img border='0' src='"+imagesdir+"/cry.gif' alt='Cry' />");
	ubbcstr=ubbcstr.replace(/\:\-\//g, "<img border='0' src='"+imagesdir+"/undecided.gif' alt='Undecided' />");
	ubbcstr=ubbcstr.replace(/\:\-X/g, "<img border='0' src='"+imagesdir+"/lipsrsealed.gif' alt='Lips Sealed' />");
	ubbcstr=ubbcstr.replace(/\:\-\[/g, "<img border='0' src='"+imagesdir+"/embarassed.gif' alt='Embarassed' />");
	ubbcstr=ubbcstr.replace(/\:\-\*/g, "<img border='0' src='"+imagesdir+"/kiss.gif' alt='Kiss' />");
	ubbcstr=ubbcstr.replace(/\&gt\;\:\(/g, "<img border='0' src='"+imagesdir+"/angry.gif' alt='Angry' />");
	ubbcstr=ubbcstr.replace(/\:\:\)/g, "<img border='0' src='"+imagesdir+"/rolleyes.gif' alt='Roll Eyes' />");
	ubbcstr=ubbcstr.replace(/\:P/g, "<img border='0' src='"+imagesdir+"/tongue.gif' alt='Tongue' />");
	ubbcstr=ubbcstr.replace(/\:\)/g, "<img border='0' src='"+imagesdir+"/smiley.gif' alt='Smiley' />");
	ubbcstr=ubbcstr.replace(/\:\-\)/g, "<img border='0' src='"+imagesdir+"/smiley.gif' alt='Smiley' />");
	ubbcstr=ubbcstr.replace(/\:D/g, "<img border='0' src='"+imagesdir+"/cheesy.gif' alt='Cheesy' />");
	ubbcstr=ubbcstr.replace(/\:\-\(/g, "<img border='0' src='"+imagesdir+"/sad.gif' alt='Sad' />");
	ubbcstr=ubbcstr.replace(/\:\(/g, "<img border='0' src='"+imagesdir+"/sad.gif' alt='Sad' />");
	ubbcstr=ubbcstr.replace(/\:o/g, "<img border='0' src='"+imagesdir+"/shocked.gif' alt='Shocked' />");
	ubbcstr=ubbcstr.replace(/8\-\)/g, "<img border='0' src='"+imagesdir+"/cool.gif' alt='Cool' />");
	ubbcstr=ubbcstr.replace(/\:\-\?/g, "<img border='0' src='"+imagesdir+"/huh.gif' alt='Huh' />");
	ubbcstr=ubbcstr.replace(/\^_\^/g, "<img border='0' src='"+imagesdir+"/happy.gif' alt='Happy' />");
	ubbcstr=ubbcstr.replace(/\:thumb\:/g, "<img border='0' src='"+imagesdir+"/thumbsup.gif' alt='Thumbsup' />");
	ubbcstr=ubbcstr.replace(/\&gt\;\:\-D/g, "<img border='0' src='"+imagesdir+"/evil.gif' alt='Evil' />");

	for(var i=0; i<jssmiliecode.length-1; i++) {
		if (jssmilieurl[i].match(/\//)) tmpurl = jssmilieurl[i];
		else tmpurl = imagesdir+'/'+jssmilieurl[i];
		var tmpcode = jssmiliecode[i];
		tmpcode=tmpcode.replace(/\&#36\;/g, "$");
		tmpcode=tmpcode.replace(/\&#64\;/g, "@");
		tmpcode=tmpcode.replace(/ /g, "");
		tmpcode=tmpcode.replace(/([\\\^\$\@*+[\]?{}.=!:(|)])/g,"\\$1");
		retmpcode = new RegExp(tmpcode, 'g');
		ubbcstr=ubbcstr.replace(retmpcode, "<img border='0' src='"+tmpurl+"' alt='' />");
	}

	ubbcstr=ubbcstr.replace(/\[([^\]]{0,30})\n([^\]]{0,30})\]/g, '[$1$2]');
	ubbcstr=ubbcstr.replace(/\[\/([^\]]{0,30})\n([^\]]{0,30})\]/g, '[/$1$2]');
	ubbcstr=ubbcstr.replace(/(\w+:\/\/[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)/g, '$1\n$2');

	ubbcstr=ubbcstr.replace(/\[b\](.+?)\[\/b\]/ig, "<b>$1</b>");
	ubbcstr=ubbcstr.replace(/\[i\](.+?)\[\/i\]/ig, "<i>$1</i>");
	ubbcstr=ubbcstr.replace(/\[u\](.+?)\[\/u\]/ig, "<u>$1</u>");
	ubbcstr=ubbcstr.replace(/\[s\](.+?)\[\/s\]/ig, "<s>$1</s>");
	ubbcstr=ubbcstr.replace(/\[move\](.+?)\[\/move\]/ig, "<marquee>$1</marquee>");

	ubbcstr=ubbcstr.replace(/\[color=(.+?)\](.+?)\[\/color\]/ig, "<div style='display:inline; color:$1'>$2</div>");
	ubbcstr=ubbcstr.replace(/\[black\](.*?)\[\/black\]/ig, "<div style='display:inline; color:#000000'>$1</div>");
	ubbcstr=ubbcstr.replace(/\[white\](.*?)\[\/white\]/ig, "<div style='display:inline; color:#FFFFFF'>$1</div>");
	ubbcstr=ubbcstr.replace(/\[red\](.*?)\[\/red\]/ig, "<div style='display:inline; color:#FF0000'>$1</div>");
	ubbcstr=ubbcstr.replace(/\[green\](.*?)\[\/green\]/ig, "<div style='display:inline; color:#00FF00'>$1</div>");
	ubbcstr=ubbcstr.replace(/\[blue\](.*?)\[\/blue\]/ig, "<div style='display:inline; color:#0000FF'>$1</div>");


	function ltTen(number)
	{
		if (number < 10) number = '0' + number;
		return number;
	}


	while ( c=ubbcstr.match(/\[timestamp=([\d]{9,10})\]/i) ) {
		var tsdate=c[1];
		tsdate=tsdate * 1000;
		var tdate = new Date(tsdate);

		var tyear = tdate.getYear();
		var tsmonth = tdate.getMonth();
		var tsday = tdate.getDate();

		var daytxt = '';

		if (!dontusetoday) {
			var today = new Date();

			var ytday = today.getTime();
			ytday -= 86400000;
			var yyday = new Date(ytday);

			var ayear = today.getYear();
			var amonth = today.getMonth();
			var aday = today.getDate();

			var yyear = yyday.getYear();
			var ymonth = yyday.getMonth();
			var yday = yyday.getDate();

			if (tsday == aday && tsmonth == amonth && tyear == ayear) {
				daytxt = "\<b\>" + todaytext + "\<\/b\> " + splittxt + ' ';
			}
			else if(tsday == yday && tsmonth == ymonth && tyear == yyear) {
				daytxt = "\<b\>" + yesterdaytext + "\<\/b\> " + splittxt + ' ';
			}
		}

		var tday = ltTen(tdate.getDate());
		var tmonth = ltTen(tdate.getMonth()+1);
		var tlmonth = month[tdate.getMonth()];
		var tyear = tyear % 100;
		var tlyear = tyear;
		tyear = ltTen(tyear);
		tlyear += (tlyear < 38) ? 2000 : 1900;
		var thours = ltTen(tdate.getHours());
		var tshours = tdate.getHours();
		var ampm = 'am';

		if (tshours > 11) ampm = 'pm';
		if (tshours == 0) tshours = 12;
		if (tshours > 12) tshours -= 12;
		var tminutes = ltTen(tdate.getMinutes());
		var tseconds = ltTen(tdate.getSeconds());
		var tstr;


		if (!daytxt) {
			if(timeselect == 1) { daytxt = tmonth + '/' + tday + '/' + tyear + ' ' + splittxt + ' '; }
			else if(timeselect == 2) { daytxt = tday + '.' + tmonth + '.' + tyear + ' ' + splittxt + ' '; }
			else if(timeselect == 3) { daytxt = tday + '.' + tmonth + '.' + tlyear + ' ' + splittxt + ' '; }
			else if(timeselect == 4) {

				tsday += "\<sup\>" + timetxt4 + "\<\/sup\>";
				if (tsday > 10 && tsday < 20) {
					tsday += "\<sup\>" + timetxt4 + "\<\/sup\>";
				}
				else if (tsday % 10 == 1) {
					tsday += "\<sup\>" + timetxt1 + "\<\/sup\>";
				}
				else if (tsday % 10 == 2) {
					tsday += "\<sup\>" + timetxt2 + "\<\/sup\>";
				}
				else if (tsday % 10 == 3) {
					tsday += "\<sup\>" + timetxt3 + "\<\/sup\>";
				}

				daytxt = tlmonth + ' ' + tsday + ', ' + tlyear + ', ';
			}
			else if(timeselect == 5) { daytxt = tmonth + '/' + tday + '/' + tyear + ' ' + splittxt + ' '; }
			else if(timeselect == 6) { daytxt = tday + '. ' + tlmonth + ' ' + tlyear + ' ' + splittxt + ' '; }
			else if(timeselect == 7) { daytxt = tmonth + '/' + tday + '/' + tyear + ' ' + splittxt + ' '; }
		}

		if(timeselect == 1) { tstr = daytxt + thours + ':' + tminutes + ':' + tseconds; }
		else if(timeselect == 2) { tstr = daytxt + thours + ':' + tminutes + ':' + tseconds; }
		else if(timeselect == 3) { tstr = daytxt + thours + ':' + tminutes + ':' + tseconds; }
		else if(timeselect == 4) { tstr = daytxt + tshours + ':' + tminutes + ampm; }
		else if(timeselect == 5) { tstr = daytxt + tshours + ':' + tminutes + ampm; }
		else if(timeselect == 6) { tstr = daytxt + thours + ':' + tminutes; }
		else if(timeselect == 7) { tstr = daytxt + thours + ':' + tminutes + ':' + tseconds; }

		ubbcstr=ubbcstr.replace(/\[timestamp=[\d]{9,10}\]/i, tstr);
	}

	ubbcstr=ubbcstr.replace(/\[highlight\](.*?)\[\/highlight\]/ig, "<span class='highlight'>$1</span>");

	ubbcstr=ubbcstr.replace(/\[font=(.+?)\](.+?)\[\/font\]/ig, "<div style='display:inline; font-family:$1'>$2</div>");

	function fontConvSize(tsize, ttext) {
		var csize = parseInt(tsize);
		if(csize < fontmin) csize = fontmin;
		else if(csize > fontmax) csize = fontmax;
		var resized = '<div style="display:inline; font-size: ' + csize + 'pt;">' + ttext + '</div>';
		ubbcstr=ubbcstr.replace(/\[size=(\d+)\](.+?)\[\/size\]/i, resized);
	}

	while(fontsize=ubbcstr.match(/\[size=(\d+)\](.+?)\[\/size\]/i)) { fontConvSize(fontsize[1], fontsize[2]); }

	var ycssvalue = 'quote2';
	function squoteConv(nosqmessage, sqauthor, sqlink, sqdate, sqmessage) {
		if ( !sqauthor || !sqlink || !sqdate ) stquotstrg = squotstrg;
		else stquotstrg = quotstrg;
		if ( sqauthor ) {
			sqmessage=sqmessage.replace(/\/me /ig, "<i>" + sqauthor + "</i> ");
		} else {
			sqmessage=sqmessage.replace(/\/me /ig, "<i>" + dspname + "</i> ");
		}
		if (LivePrevDisplayNames[sqauthor]) sqauthor = LivePrevDisplayNames[sqauthor];
		else sqauthor = post_txt_807;
		if(!showimagequote) {
			sqmessage=sqmessage.replace(/\[img (.+?)\]/g, "[img]");
			sqmessage=sqmessage.replace(/\[img\][\s*\t*\n*(\&nbsp\;)*(\&#160\;)*]*(https\:\/\/)(.+?)[\s*\t*\n*(\&nbsp\;)*(\&#160\;)*]*\[\/img\]/ig, "[url]https://$2[/url]");
			sqmessage=sqmessage.replace(/\[img\][\s*\t*\n*(\&nbsp\;)*(\&#160\;)*]*(http\:\/\/)*(.+?)[\s*\t*\n*(\&nbsp\;)*(\&#160\;)*]*\[\/img\]/ig, "[url]http://$2[/url]");
		}
		stquotstrg=stquotstrg.replace(/AUTHOR/g, sqauthor);
		stquotstrg=stquotstrg.replace(/QUOTELINK/g, scriptul+'?num='+sqlink+'" target="_blank');
		stquotstrg=stquotstrg.replace(/DATE/g, sqdate);
		if(ycssvalue == 'quote') ycssvalue = 'quote2';
		else ycssvalue = 'quote';
		stquotstrg=stquotstrg.replace(/QUOTECSS/g, ycssvalue);
		stquotstrg=stquotstrg.replace(/QUOTE/g, sqmessage);
		ubbcstr=ubbcstr.replace(/\[quote(\s+author=(.*?)\s+link=(.*?)\s+date=(.*?)\s*)?\]\n*(.+?)\n*\[\/quote\]/i, nosqmessage + stquotstrg);
	}

	function nstsquoteConv(nsqmessage) {
		c=nsqmessage.match(/(.*)\[quote(\s+author=(.*?)\s+link=(.*?)\s+date=(.*?)\s*)?\]\n*(.+?)\n*\[\/quote\]/i);
		squoteConv(c[1], c[3], c[4], c[5], c[6]);
	}

	while ( d=ubbcstr.match(/(\[quote(\s+author=(.*?)\s+link=(.*?)\s+date=(.*?)\s*)?\]\n*(.+?)\n*\[\/quote\])/i) ) {
		nstsquoteConv(d[1]);
	}

	ubbcstr=ubbcstr.replace(/\[yabbimg\](.+?)\[\/yabbimg\]/ig, '<img src="'+imagesdir+'/$1" alt="" border="0">');
	ubbcstr=ubbcstr.replace(/\[img\][\s*\t*\n*(\&nbsp\;)*(\&#160\;)*]*(https\:\/\/)(.+?)[\s*\t*\n*(\&nbsp\;)*(\&#160\;)*]*\[\/img\]/ig, '<img src="https://$2" alt="" border="0">');
	ubbcstr=ubbcstr.replace(/\[img\][\s*\t*\n*(\&nbsp\;)*(\&#160\;)*]*(http\:\/\/)*(.+?)[\s*\t*\n*(\&nbsp\;)*(\&#160\;)*]*\[\/img\]/ig, '<img src="http://$2" alt="" border="0">');

	function restrictimage(p,s) {
		w = '';
		h = '';
		a = '';
		c=p.split(/ /);
		for(i = 0; i < c.length; i++) {
			params = c[i].split(/=/);
			if(params[0] == 'width') w = "width='" + new Number(params[1]) + "' ";
			if(params[0] == 'height') h = "height='" + new Number(params[1]) + "' ";
			if(params[0] == 'align') a = "align='" + params[1] + "' ";
		}
		var imgrest = "<img src='http://" + s + "' " + w + h + a + "alt='' border='0' />";
		ubbcstr=ubbcstr.replace(/\[img (.+?)\][\s*\t*\n*(\&nbsp\;)*(\&#160\;)*]*(http\:\/\/)*(.+?)[\s*\t*\n*(\&nbsp\;)*(\&#160\;)*]*\[\/img\]/i, imgrest);
	}

	while(picr=ubbcstr.match(/\[img (.+?)\][\s*\t*\n*(\&nbsp\;)*(\&#160\;)*]*(http\:\/\/)*(.+?)[\s*\t*\n*(\&nbsp\;)*(\&#160\;)*]*\[\/img\]/i)) { restrictimage(picr[1],'$3') }

	ubbcstr=ubbcstr.replace(/\[tt\](.*?)\[\/tt\]/ig, "<tt>$1</tt>");
	ubbcstr=ubbcstr.replace(/\[left\](.+?)\[\/left\]/ig, "<p align=left>$1</p>");
	ubbcstr=ubbcstr.replace(/\[center\](.+?)\[\/center\]/ig, "<center>$1</center>");
	ubbcstr=ubbcstr.replace(/\[right\](.+?)\[\/right\]/ig, "<p align=right>$1</p>");
	ubbcstr=ubbcstr.replace(/\[sub\](.+?)\[\/sub\]/ig, "<sub>$1</sub>");
	ubbcstr=ubbcstr.replace(/\[sup\](.+?)\[\/sup\]/ig, "<sup>$1</sup>");
	ubbcstr=ubbcstr.replace(/\[fixed\](.+?)\[\/fixed\]/ig, "<div style='display:inline; font-family:Courier New'>$1</div>");

	ubbcstr=ubbcstr.replace(/\[hr\]\n/ig, "<hr width=40% align=left size=1 class='hr'>");
	ubbcstr=ubbcstr.replace(/\[hr\]/ig, "<hr width=40% align=left size=1 class='hr'>");
	ubbcstr=ubbcstr.replace(/\[br\]/ig, "\n");

	if(autolinkurls != 0) ubbcstr=ubbcstr.replace(/([^\w(?:\'|\")\=\[\]\/]|[\n\b]|\&quot\;|\]|^)((http\:\/\/|www\.){1,}\S+?\.(\w|\.|\/)+)/ig, "$1[url]$2[/url]");
	ubbcstr=ubbcstr.replace(/\[url\]\s*www\.(\S+?)\s*\[\/url\]/ig, "<a href='http://www.$1' target='_blank'>www.$1</a>");
	ubbcstr=ubbcstr.replace(/\[url=\s*(\S\w+\:\/\/\S+?)\s*\](.+?)\[\/url\]/ig, "<a href='$1' target='_blank'>$2</a>");
	ubbcstr=ubbcstr.replace(/\[url=\s*(\S+?)\](.+?)\s*\[\/url\]/ig, "<a href='http://$1' target='_blank'>$2</a>");
	ubbcstr=ubbcstr.replace(/\[url\]\s*(\S+?)\s*\[\/url\]/ig, "<a href='$1' target='_blank'>$1</a>");
	ubbcstr=ubbcstr.replace(/\[url\]|\[\/url\]/ig, ""); 

	ubbcstr=ubbcstr.replace(/\[link\]\s*www\.(\S+?)\s*\[\/link\]/ig, "<a href='http://www.$1'>www.$1</a>");
	ubbcstr=ubbcstr.replace(/\[link=\s*(\S\w+\:\/\/\S+?)\s*\](.+?)\[\/link\]/ig, "<a href='$1'>$2</a>");
	ubbcstr=ubbcstr.replace(/\[link=\s*(\S+?)\](.+?)\s*\[\/link\]/ig, "<a href='http://$1'>$2</a>");
	ubbcstr=ubbcstr.replace(/\[link\]\s*(\S+?)\s*\[\/link\]/ig, "<a href='$1'>$1</a>");

	ubbcstr=ubbcstr.replace(/\[email\]\s*(\S+?\@\S+?)\s*\[\/email\]/ig, "<a href='mailto:$1'>$1</a>");
	ubbcstr=ubbcstr.replace(/\[email=\s*(\S+?\@\S+?)\](.*?)\[\/email\]/ig, "<a href='mailto:$1'>$2</a>");

	ubbcstr=ubbcstr.replace(/\[news\](\S+?)\[\/news\]/ig, '<a href="$1">$1</a>');
	ubbcstr=ubbcstr.replace(/\[gopher\](\S+?)\[\/gopher\]/ig, '<a href="$1">$1</a>');
	ubbcstr=ubbcstr.replace(/\[ftp\](\S+?)\[\/ftp\]/ig, '<a href="$1">$1</a>');

	ubbcstr=ubbcstr.replace(/\/me /ig, "<i>" + dspname + "</i> ");

	function wrapstr(wraptext) {
		wraptext=wraptext.replace(/([\S]{80})/g, "$1\n");
		ubbcstr=ubbcstr.replace(/\[edit\]\n*(.+?)\n*\[\/edit\]/i, "<b>" + editxt + ": </b><br /><div class='editbg'>" + wraptext + "</div>");
	}

	while(longstrg=ubbcstr.match(/\[edit\](.+?)\[\/edit\]/i)) { wrapstr(longstrg[1]); }

	ubbcstr=ubbcstr.replace(/\[\*\]/ig, "</li><li>");
	ubbcstr=ubbcstr.replace(/\[olist\]/ig, "<ol>");
	ubbcstr=ubbcstr.replace(/\[\/olist\]/ig, "</li></ol>");
	ubbcstr=ubbcstr.replace(/\<\/li\>\<ol\>/ig, "<ol>");
	ubbcstr=ubbcstr.replace(/\<ol\>\<\/li\>/ig, "<ol>");
	ubbcstr=ubbcstr.replace(/\[\*\]/ig, "</li><li>");
	ubbcstr=ubbcstr.replace(/\[list\]/ig, "<ul>");
	ubbcstr=ubbcstr.replace(/\[\/list\]/ig, "</li></ul>");
	ubbcstr=ubbcstr.replace(/\<\/li\>\<ul\>/ig, "<ul>");
	ubbcstr=ubbcstr.replace(/\<ul\>\<\/li\>/ig, "<ul>");


	ubbcstr=ubbcstr.replace(/\[list\]/ig, "<ul>");
	ubbcstr=ubbcstr.replace(/\[list (.+?)\]/ig, "<ul style='list-style-image: url("+imagesdir+"/$1.gif)'>");
	ubbcstr=ubbcstr.replace(/\[\*\]/ig, "<li>");
	ubbcstr=ubbcstr.replace(/\[\/list\]/ig, "</ul>");
	ubbcstr=ubbcstr.replace(/\<\/li\>\<ul (.+?)\>/ig, "<ul $1>");
	ubbcstr=ubbcstr.replace(/\<ul (.+?)\>\<\/li\>/ig, "<ul $1>");

	function jsdopre(prestrg) {
		prestrg=prestrg.replace(/\<br \/\>/g, "\n");
		ubbcstr=ubbcstr.replace(/\[pre\](.+?)\[\/pre\]/i, "<pre>"+prestrg+"</pre>");
	}

	while ( prestr=ubbcstr.match(/\[pre\](.+?)\[\/pre\]/i) ) { jsdopre(prestr[1]) }


	while(fw=ubbcstr.match(/\[flash\=(\S+?),(\S+?)](\S+?)\[\/flash\]/)) {
		if(parsflash == 1) {
			var fwidth = fw[1];
			var fheight = fw[2];
			if (fwidth > 500) { fwidth = 500; }
			if (fheight > 500) { fheight = 500; }
			ubbcstr=ubbcstr.replace(/\[flash\=(\S+?),(\S+?)\](\S+?)\[\/flash\]/, '<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" width='+fwidth+' height='+fheight+'><param name=movie value=$3><param name=play value=true><param name=loop value=true><param name=quality value=high><embed src=$3 width='+fwidth+' height='+fheight+' play=true loop=true quality=high></embed></object>');
		}
		else {
			ubbcstr=ubbcstr.replace(/\[flash\=(\S+?),(\S+?)\](\S+?)\[\/flash\]/, "<b>Flash location ($1 x $2):</b> <a href=\"$3\" target=\"_blank\" onClick=\"window.open('$3', 'flash', 'resizable,width=$1,height=$2'); return false;\">$3</a>");
		}
	}

	if( ubbcstr.match(/\[table\](?:.*?)\[\/table\]/i) ) {
		while( ubbcstr.match(/\<marquee\>(.*?)\[table\](.*?)\[\/table\](.*?)\<\/marquee\>/g) ) {ubbcstr=ubbcstr.replace(/\<marquee\>(.*?)\[table\](.*?)\[\/table\](.*?)\<\/marquee\>/, "<marquee>$1<table>$2<\/table>$3<\/marquee>")}
		while( ubbcstr.match(/\<marquee\>(.*?)\[table\](.*?)\<\/marquee\>(.*?)\[\/table\]/g) ) {ubbcstr=ubbcstr.replace(/\<marquee\>(.*?)\[table\](.*?)\<\/marquee\>(.*?)\[\/table\]/, "<marquee>$1\[//table\]$2</marquee>$3\[//table\]")}
		while( ubbcstr.match(/\[table\](.*?)\<marquee\>(.*?)\[\/table\](.*?)\<\/marquee\>/g) ) {ubbcstr=ubbcstr.replace(/\[table\](.*?)\<marquee\>(.*?)\[\/table\](.*?)\<\/marquee\>/, "[//table\]$1<marquee>$2[//table\]$3</marquee>")}
		ubbcstr=ubbcstr.replace(/\n{0,1}\[table\]\n*(.+?)\n*\[\/table\]\n{0,1}/ig, "<table>$1</table>");
		while( ubbcstr.match(/\<table\>(.*?)\n*\[tr\]\n*(.*?)\n*\[\/tr\]\n*(.*?)\<\/table\>/ig) ) {ubbcstr=ubbcstr.replace(/\<table\>(.*?)\n*\[tr\]\n*(.*?)\n*\[\/tr\]\n*(.*?)\<\/table\>/i, "<table>$1<tr>$2</tr>$3</table>")}
		while( ubbcstr.match(/\<tr\>(.*?)\n*\[td\]\n{0,1}(.*?)\n{0,1}\[\/td\]\n*(.*?)\<\/tr\>/ig) ) {ubbcstr=ubbcstr.replace(/\<tr\>(.*?)\n*\[td\]\n{0,1}(.*?)\n{0,1}\[\/td\]\n*(.*?)\<\/tr\>/i, "<tr>$1<td>$2</td>$3</tr>")}
                ubbcstr=ubbcstr.replace(/\<table\>((?:(?!\<tr\>|\<\/tr\>|\<td\>|\<\/td\>|\<table\>|\<\/table\>).)*)\<tr\>/ig, "<table><tr>");
		ubbcstr=ubbcstr.replace(/\<tr\>((?:(?!\<tr\>|\<\/tr\>|\<td\>|\<\/td\>|\<table\>|\<\/table\>).)*)\<td\>/ig, "<tr><td>");
		ubbcstr=ubbcstr.replace(/\<\/td\>((?:(?!\<tr\>|\<\/tr\>|\<td\>|\<\/td\>|\<table\>|\<\/table\>).)*)\<td\>/ig, "</td><td>");
		ubbcstr=ubbcstr.replace(/\<\/td\>((?:(?!\<tr\>|\<\/tr\>|\<td\>|\<\/td\>|\<table\>|\<\/table\>).)*)\<\/tr\>/ig, "</td></tr>");
		ubbcstr=ubbcstr.replace(/\<\/tr\>((?:(?!\<tr\>|\<\/tr\>|\<td\>|\<\/td\>|\<table\>|\<\/table\>).)*)\<tr\>/ig, "</tr><tr>");
		ubbcstr=ubbcstr.replace(/\<\/tr\>((?:(?!\<tr\>|\<\/tr\>|\<td\>|\<\/td\>|\<table\>|\<\/table\>).)*)\<\/table\>/ig, "</tr></table>");
	}

	while( ubbcstr.match(/\<a([^>]*?)\n([^>]*)>/g) ) {ubbcstr=ubbcstr.replace(/\<a([^>]*?)\n([^>]*)>/, "<a$1$2>")}
	while( ubbcstr.match(/\<a([^>]*)>([^<]*?)\n([^<]*)<\/a>/g) ) {ubbcstr=ubbcstr.replace(/\<a([^>]*)>([^<]*?)\n([^<]*)<\/a>/, "<a$1>$2$3</a>")}
	while( ubbcstr.match(/\<a([^>]*?)\&amp\;([^>]*)>/g) ) {ubbcstr=ubbcstr.replace(/\<a([^>]*?)\&amp\;([^>]*)>/, "<a$1&$2>")}
	while( ubbcstr.match(/\<img([^>]*?)\n([^>]*)>/g) ) {ubbcstr=ubbcstr.replace(/\<img([^>]*?)\n([^>]*)>/, "<img$1$2>")}
	while( ubbcstr.match(/\<img([^>]*?)\&amp\;([^>]*)>/g) ) {ubbcstr=ubbcstr.replace(/\<img([^>]*?)\&amp\;([^>]*)>/, "<img$1&$2>")}

	ubbcstr=ubbcstr.replace(/\[\&table(.*?)\]/g, "<table$1>");
	ubbcstr=ubbcstr.replace(/\[\/\&table\]/g, "</table>");


	ubbcstr=ubbcstr.replace(/\<a (.+?)\>([\S]{80}?)(\S+?)\<\/a\>/g, "<a $1>$2...</a>");


	ubbcstr=ubbcstr.replace(/\n/ig, "<br />");
	ubbcstr=ubbcstr.replace(/\[code_br\]/ig, "\n");

	return ubbcstr;
}
