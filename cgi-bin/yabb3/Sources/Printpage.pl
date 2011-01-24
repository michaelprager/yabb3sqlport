###############################################################################
# Printpage.pl                                                                #
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

$printpageplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub Print_IM {
	my (@threads,$boxtitle,$type);
	if ($INFO{'caller'} == 1) {
		@threads = &read_DBorFILE(0,'',$memberdir,$username,'msg');
		$boxtitle = $maintxt{'316'};
		$type = $maintxt{'318'};
	} elsif ($INFO{'caller'} == 2) {
		@threads = &read_DBorFILE(0,'',$memberdir,$username,'outbox');
		$boxtitle = $maintxt{'320'};
		$type = $maintxt{'324'};
	} else {
		@threads = &read_DBorFILE(0,'',$memberdir,$username,'imstore');
		$boxtitle = $load_imtxt{'46'};
		$type = "$maintxt{'318'}/$maintxt{'324'}";
	}

	### Lets output all that info. ###
	$output = qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$mbname - $maintxt{'668'}</title>
<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />

<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/YaBB.js"></script>
<script language="JavaScript" type="text/javascript">
<!--
function printPage() {
	if (window.print) {
		agree = confirm('$maintxt{773}');
		if (agree) window.print(); 
	}
}

var imgdisplay = 'none';
function do_images() {
	for (var i = 0; i < document.images.length; i++) {
		document.images[i].style.display = imgdisplay;
	}
	if (imgdisplay == 'none') {
		imgdisplay = 'inline';
		document.getElementById("Hide_Image").value = "$maintxt{'669b'}";
	} else {
		imgdisplay = 'none';
		document.getElementById("Hide_Image").value = "$maintxt{'669a'}";
	}
}
// -->
</script>
</head>

<body onload="printPage()">

<table width="96%" align="center">
	<tr>
		<td align="left" valign="top">
			<span style="font-family: arial, sans-serif; font-size: 18px; font-weight: bold;">$mbname</span>
		</td>
		<td align="right" valign="top">
			<input type="button" id="Hide_Image" value="$maintxt{'669a'}" onclick="do_images();" />
		</td>
	</tr>
	<tr>
		<td align="left" valign="top" colspan="2">
			<span style="font-family: arial, sans-serif; font-size: 10px;">$scripturl</span>
			<br />
			<span style="font-family: arial, sans-serif; font-size: 14px; font-weight: bold;">$load_imtxt{'71'} $boxtitle $maintxt{'30'} $date</span>
		</td>
	</tr>
</table>

<br />
~;

	# Split the threads up so we can print them.
	foreach $thread (@threads) {
		($threadposter, $threadtitle, $threaddate, $threadpost, undef) = split(/\|/, $thread);

		&do_print;
		$output .= qq~
<table width="96%" align="center" cellpadding="10" style="border: 1px solid #000000;">
	<tr>
		<td style="font-family: arial, sans-serif; font-size: 12px;">
			$maintxt{'70'}: <b>$threadtitle</b><br />
			$type <b>$threadposter</b> $maintxt{'30'} <b>$threaddate</b>
			<hr width="100%" size="1" />
			<span style="font-family: arial, sans-serif; font-size: 12px;">
			$threadpost
			</span>
		</td>
	</tr>
</table>

<br />
~;
	}

	$output .= qq~
<table width="96%" align="center">
	<tr>
		<td align="center">
			<span style="font-family: arial, sans-serif; font-size: 10px;">
			$yycopyright
			</span>
		</td>
	</tr>
</table>

</body>
</html>~;

	&image_resize;

	&print_output_header;
	&print_HTML_output_and_finish;
}

sub Print {
	$num = $INFO{'num'};

	# Determine category
	$curcat = ${$uid.$currentboard}{'cat'};
	&MessageTotals("load", $num);

	my $ishidden;
	if (${$num}{'threadstatus'} =~ /h/i) {
		$ishidden = 1;
	}

	if ($ishidden && !$staff) { &fatal_error("no_access"); }

	# Figure out the name of the category
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	($cat, $catperms) = split(/\|/, $catinfo{"$curcat"});

	($boardname, $boardperms, $boardview) = split(/\|/, $board{"$currentboard"});
	&ToChars($boardname);

	&LoadCensorList;

	# Lets open up the thread file itself
	unless (ref($thread_arrayref{$num})) {
		&donoopen if !(@{$thread_arrayref{$num}} = &read_DBorFILE(1,'',$datadir,$num,'txt'));
	}
	&ToChars($cat);
	$cat =~ s/\n//g;

	($messagetitle, $poster_realname, undef, $date, $poster_username) = split(/\|/, ${$thread_arrayref{$num}}[0]);
	if (&checkfor_DBorFILE("$memberdir/$poster_username.vars")) {
		&LoadUser($poster_username);
		$poster_realname = ${$uid.$poster_username}{'realname'};
	}
	$startedby = $poster_realname;
	$startedon = timeformat($date, 1);
	&ToChars($messagetitle);
	($messagetitle, undef) = &Split_Splice_Move($messagetitle,0);

	### Lets output all that info. ###
	$output = qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$mbname - $maintxt{'668'}</title>
<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />

<script language="JavaScript1.2" type="text/javascript" src="$yyhtml_root/YaBB.js"></script>
<script language="JavaScript" type="text/javascript">
<!--
function printPage() {
	if (window.print) {
		agree = confirm('$maintxt{773}');
		if (agree) window.print(); 
	}
}

var imgdisplay = 'none';
var urldisplay = 'inline';
function do_images() {
	for (var i = 0; i < document.images.length; i++) {
		if (document.images[i].align != 'bottom') {
			document.images[i].style.display = imgdisplay;
			imageid = document.images[i].id;
			if (imageid) document.getElementById('url' + imageid).style.display = urldisplay;
		}
	}
	if (imgdisplay == 'none') {
		imgdisplay = 'inline';
		urldisplay = 'none';
		document.getElementById("Hide_Image").value = "$maintxt{'669b'}";
	} else {
		imgdisplay = 'none';
		urldisplay = 'inline';
		document.getElementById("Hide_Image").value = "$maintxt{'669a'}";
	}
}
// -->
</script>
</head>

<body onload="printPage()">

<table width="96%" align="center">
	<tr>
		<td align="left" valign="top">
			<span style="font-family: arial, sans-serif; font-size: 18px; font-weight: bold;">$mbname</span>
		</td>
		<td align="right" valign="top">
			<input type="button" id="Hide_Image" value="$maintxt{'669a'}" onclick="do_images();" />
		</td>
	</tr>
	<tr>
		<td align="left" valign="top" colspan="2">
			<span style="font-family: arial, sans-serif; font-size: 10px;">$scripturl</span>
			<br />
			<span style="font-family: arial, sans-serif; font-size: 16px; font-weight: bold;">$cat &gt;&gt; $boardname &gt;&gt; $messagetitle</span>
			<br />
			<span style="font-family: arial, sans-serif; font-size: 10px;">$scripturl?num=$num</span>
			<br />
			<hr size="1" width="100%" />
			<span style="font-family: arial, sans-serif; font-size: 14px; font-weight: bold;">$maintxt{'195'} $startedby $maintxt{'30'} $startedon</span>
		</td>
	</tr>
</table>

<br />~;

	&LoadLanguage('FA');
	# Split the threads up so we can print them.
	foreach $thread (@{$thread_arrayref{$num}}) {
		($threadtitle, $threadposter_realname, undef, $threaddate, $threadposter_username, undef, undef, undef, $threadpost, undef, undef, undef, $attachments) = split(/\|/, $thread);
		if (&checkfor_DBorFILE("$memberdir/$threadposter_username.vars")) {
			&LoadUser($threadposter_username);
			$threadposter_realname = ${$uid.$threadposter_username}{'realname'};
		}

		($threadtitle, undef) = &Split_Splice_Move($threadtitle,0);
		($threadpost, undef) = &Split_Splice_Move($threadpost,$num);
		&do_print;

		$output .= qq~
<table width="96%" align="center" cellpadding="10" style="border: 1px solid #000000;">
	<tr>
		<td style="font-family: arial, sans-serif; font-size: 12px;">
			$maintxt{'196'}: <b>$threadtitle</b><br />
			$maintxt{'197'} <b>$threadposter_realname</b> $maintxt{'30'} <b>$threaddate</b>
			<hr width="100%" size="1" />
			<div style="font-family: arial, sans-serif; font-size: 12px;">
			$threadpost~;

		chomp $attachments;
		if ($attachments) {
			# store all downloadcounts in variable
			if (!%attach_count) {
				my ($atfile,$atcount);
				foreach (&read_DBorFILE(1,'',$vardir,'attachments','txt')) {
					(undef, undef, undef, undef, undef, undef, undef, $atfile, $atcount) =split(/\|/, $_);
					$attach_count{$atfile} = $atcount;
				}
				$attach_count{'no_attachments'} = 1 if !%attach_count;
			}

			my $attachment = '';
			my $showattach = '';

			foreach (split(/,/, $attachments)) {
				$_ =~ /\.(.+?)$/;
				my $ext = lc($1);
				unless (exists $attach_gif{$ext}) {
					$attach_gif{$ext} = ($ext && -e "$forumstylesdir/$useimages/$ext.gif") ? "$ext.gif" : "paperclip.gif";
				}
				my $filesize = -s "$uploaddir/$_";
				if ($filesize) {
					if ($_ =~ /\.(bmp|jpe|jpg|jpeg|gif|png)$/i && $amdisplaypics == 1) {
						$imagecount++;
						$showattach .= qq~<div class="small" style="float:left; margin:8px;"><img src="$imagesdir/$attach_gif{$ext}" border="0" align="bottom" alt="" /> <span id="urlimagecount$imagecount" style="display:none">$scripturl?action=downloadfile;file=</span>$_ (~ . int($filesize / 1024) . qq~ KB | <acronym title='$attach_count{$_} $fatxt{'41a'}' class="small">$attach_count{$_}</acronym> )<br /><img src="$uploadurl/$_" name="attach_img_resize" alt="$_" id="imagecount$imagecount" title="$_" border="0" style="display:none" /></div>\n~;
					} else {
						$attachment .= qq~<div class="small"><img src="$imagesdir/$attach_gif{$ext}" border="0" align="bottom" alt="" /> $scripturl?action=downloadfile;file=$_ (~ . int($filesize / 1024) . qq~ KB | <acronym title='$attach_count{$_} $fatxt{'41a'}' class="small">$attach_count{$_}</acronym> )</div>~;
					}
				} else {
					$attachment .= qq~<div class="small"><img src="$imagesdir/$attach_gif{$ext}" border="0" align="bottom" alt="" />  $_ ($fatxt{'1'}~ . (exists $attach_count{$_} ? qq~ | <acronym title='$attach_count{$_} $fatxt{'41a'}' class="small">$attach_count{$_}</acronym> ~ : '') . qq~)</div>~;
				}
			}
			if ($showattach && $attachment) {
				$attachment =~ s/<div class="small">/<div class="small" style="margin:8px;">/g;
			}
			$output .= qq~
			<hr width="100%" size="1" />
			$attachment
			$showattach~;
		}

		$output .= qq~
			</div>
		</td>
	</tr>
</table>

<br />~;
	}

	$output .= qq~
<table width="96%" align="center">
	<tr>
		<td align="center" style="font-family: arial, sans-serif; font-size: 10px;">
			$yycopyright
		</td>
	</tr>
</table>

</body>
</html>~;

	&image_resize;

	&print_output_header;
	&print_HTML_output_and_finish;
}

sub sizefont {
	# limit minimum and maximum font pitch as CSS does not restrict it at all.
	my ($tsize, $ttext) = @_;
	if    (!$fontsizemax)         { $fontsizemax = 72; }
	if    (!$fontsizemin)         { $fontsizemin = 6; }
	if    ($tsize < $fontsizemin) { $tsize       = $fontsizemin; }
	elsif ($tsize > $fontsizemax) { $tsize       = $fontsizemax; }
	my $resized = qq~<span style="font-size:$tsize\px;">$ttext</span>~;
	return $resized;
}

{
	my %killhash = (
		';' => '&#059;',
		'!' => '&#33;',
		'(' => '&#40;',
		')' => '&#41;',
		'-' => '&#45;',
		'.' => '&#46;',
		'/' => '&#47;',
		':' => '&#58;',
		'?' => '&#63;',
		'[' => '&#91;',
		'\\' => '&#92;',
		']' => '&#93;',
		'^' => '&#94;');

	sub codemsg {
		my $code = $_[0];
		if ($code !~ /&\S*;/) { $code =~ s/;/&#059;/g; }
		$code =~ s~([\(\)\-\:\\\/\?\!\]\[\.\^])~$killhash{$1}~g;
		$_ = qq~<br /><b>Code:</b><br /><table cellspacing="1" width="90%"><tr><td width="100%"><table width="100%" cellpadding="2" cellspacing="0"><tr><td><font face="courier" size="1">CODE</font></td></tr></table></td></tr></table>~;
		$_ =~ s~CODE~$code~g;
		return $_;
	}
}

sub donoopen {
	print qq~Content-Type: text/html\r\n\r\n
<html>
<head>
<title>$maintxt{'199'}</title>
</head>
<body>
<font size="2" face="Arial,Helvetica"><center>$maintxt{'199'}</center></font>
</body>
</html>~;
	exit;
}

sub do_print {
	$threadpost =~ s~<br />~\n~ig;
	$threadpost =~ s~\[highlight(.*?)\](.*?)\[/highlight\]~$2~isg;
	$threadpost =~ s~\[code\]\n*(.+?)\n*\[/code\]~<br /><b>Code:</b><br /><table cellspacing="1"><tr><td><table cellpadding="2" cellspacing="0"><tr><td><font face="Courier" size="1">$1</font></td></tr></table></td></tr></table>~isg;
	$threadpost =~ s~\[code\s*(.+?)\]\n*(.+?)\n*\[/code\]~<br /><b>Code ($1):</b><br /><table cellspacing="1"><tr><td><table cellpadding="2" cellspacing="0"><tr><td><font face="Courier" size="1">$2</font></td></tr></table></td></tr></table>~isg;

	$threadpost =~ s~\[([^\]]{0,30})\n([^\]]{0,30})\]~\[$1$2\]~g;
	$threadpost =~ s~\[/([^\]]{0,30})\n([^\]]{0,30})\]~\[/$1$2\]~g;
	$threadpost =~ s~(\w+://[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)~$1\n$2~g;

	$threadpost =~ s~\[b\](.*?)\[/b\]~<b>$1</b>~isg;
	$threadpost =~ s~\[i\](.*?)\[/i\]~<i>$1</i>~isg;
	$threadpost =~ s~\[u\](.*?)\[/u\]~<u>$1</u>~isg;
	$threadpost =~ s~\[s\](.*?)\[/s\]~<s>$1</s>~isg;
	$threadpost =~ s~\[move\](.*?)\[/move\]~$1~isg;

	$threadpost =~ s~\[glow(.*?)\](.*?)\[/glow\]~&elimnests($2)~eisg;
	$threadpost =~ s~\[shadow(.*?)\](.*?)\[/shadow\]~&elimnests($2)~eisg;

	$threadpost =~ s~\[shadow=(\S+?),(.+?),(.+?)\](.+?)\[/shadow\]~$4~eisg;
	$threadpost =~ s~\[glow=(\S+?),(.+?),(.+?)\](.+?)\[/glow\]~$4~eisg;

	$threadpost =~ s~\[color=([\w#]+)\](.*?)\[/color\]~$2~isg;
	$threadpost =~ s~\[black\](.*?)\[/black\]~$1~isg;
	$threadpost =~ s~\[white\](.*?)\[/white\]~$1~isg;
	$threadpost =~ s~\[red\](.*?)\[/red\]~$1~isg;
	$threadpost =~ s~\[green\](.*?)\[/green\]~$1~isg;
	$threadpost =~ s~\[blue\](.*?)\[/blue\]~$1~isg;
	$threadpost =~ s~\[font=(.+?)\](.+?)\[/font\]~<span style="font-family:$1;">$2</span>~isg;
	while ($threadpost =~ s~\[size=(.+?)\](.+?)\[/size\]~&sizefont($1,$2)~eisg) { }

	$threadpost =~ s~\[quote\s+author=(.*?)\s+link=(.*?)\].*\/me\s+(.*?)\[\/quote\]~\[quote author=$1 link=$2\]<i>* $1 $3</i>\[/quote\]~isg;
	$threadpost =~ s~\[quote(.*?)\].*\/me\s+(.*?)\[\/quote\]~\[quote$1\]<i>* Me $2</i>\[/quote\]~isg;
	$threadpost =~ s~\/me\s+(.*)~* $displayname $1~ig;

	# Images in message
	$threadpost =~ s~\[img(.*?)\](.*?)\[/img\]~ &imagemsg($1,$2) ~eisg;
	sub imagemsg { # out of YaBBC.pl -> sub imagemsg {
		my($attribut,$url) = @_;
		# use or kill urls
		$url =~ s~\[url\](.*?)\[/url\]~$1~ig;
		$url =~ s~\[link\](.*?)\[/link\]~$1~ig;
		$url =~ s~\[url\s*=\s*(.*?)\s*.*?\].*?\[/url\]~$1~ig;
		$url =~ s~\[link\s*=\s*(.*?)\s*.*?\].*?\[/link\]~$1~ig;
		$url =~ s~\[url.*?/url\]~~ig;
		$url =~ s~\[link.*?/link\]~~ig;

		my $char_160 = chr(160);
		$url =~ s/(\s|&nbsp;|$char_160)+//g;

		if ($url !~ /^http.+?\.(gif|jpg|jpeg|png|bmp)$/i) {return ' ' . $url;}

		my %parameter;
		&FromHTML($attribut);
		$attribut =~ s/(\s|$char_160)+/ /g;
		foreach (split(/ +/, $attribut)) {
			my ($key, $value) = split(/=/, $_);
			$value =~ s/["']//g;
			$parameter{$key} = $value;
		}

		$parameter{'name'} = 'post_img_resize' if $parameter{'name'} ne 'signat_img_resize';
		&ToHTML($parameter{'alt'});
		$parameter{'align'}  =~ s~[^a-z]~~ig;
		$parameter{'width'}  =~ s~\D~~g;
		$parameter{'height'} =~ s~\D~~g;
		if ($parameter{'align'})  { $parameter{'align'}  = qq~ align="$parameter{'align'}"~; }
		if ($parameter{'width'})  { $parameter{'width'}  = qq~ width="$parameter{'width'}"~; }
		if ($parameter{'height'}) { $parameter{'height'} = qq~ height="$parameter{'height'}"~; }

		$imagecount++;
		qq~ <img src="$url" name="$parameter{'name'}" alt="$parameter{'alt'}"$parameter{'align'}$parameter{'width'}$parameter{'height'} border="0" id="imagecount$imagecount" style="display:none" /><span id="urlimagecount$imagecount" style="display:none">$url</span>~;
	}

	$threadpost =~ s~\[tt\](.*?)\[/tt\]~<tt>$1</tt>~isg;
	$threadpost =~ s~\[left\](.*?)\[/left\]~<div style="text-align: left;">$1</div>~isg;
	$threadpost =~ s~\[center\](.*?)\[/center\]~<center>$1</center>~isg;
	$threadpost =~ s~\[right\](.*?)\[/right\]~<div style="text-align: right;">$1</div>~isg;
	$threadpost =~ s~\[justify\](.*?)\[/justify\]~<div style="text-align: justify">$1</div>~isg;
	$threadpost =~ s~\[sub\](.*?)\[/sub\]~<sub>$1</sub>~isg;
	$threadpost =~ s~\[sup\](.*?)\[/sup\]~<sup>$1</sup>~isg;
	$threadpost =~ s~\[fixed\](.*?)\[/fixed\]~<span style="font-family: Courier New;">$1</span>~isg;

	$threadpost =~ s~\[\[~\{\{~g;
	$threadpost =~ s~\]\]~\}\}~g;
	$threadpost =~ s~\|~\&#124;~g;
	$threadpost =~ s~\[hr\]\n~<hr width="40%" align="left" size="1" class="hr" />~g;
	$threadpost =~ s~\[hr\]~<hr width="40%" align="left" size="1" class="hr" />~g;
	$threadpost =~ s~\[br\]~\n~ig;

	$threadpost =~ s~\[flash\](.*?)\[/flash\]~\[media\]$1\[/media\]~isg;

	sub format_url {
		my ($txtfirst, $txturl) = @_;
		my $lasttxt = "";
		if ($txturl =~ m~(.*?)(\.|\.\)|\)\.|\!|\!\)|\)\!|\,|\)\,|\)|\;|\&quot\;|\&quot\;\.|\.\&quot\;|\&quot\;\,|\,\&quot\;|\&quot\;\;|\<\/)\Z~) {
			$txturl = $1;
			$lasttxt = $2;
		}
		my $realurl = $txturl;
		$txturl =~ s~(\[highlight\]|\[\/highlight\]|\[edit\]|\[\/edit\])~~ig;
		$txturl =~ s~\[~&#91;~g;
		$txturl =~ s~\]~&#93;~g;
		$txturl =~ s~\<.+?\>~~ig;
		my $formaturl = qq~$txtfirst\[url\=$txturl\]$realurl\[\/url\]$lasttxt~;
		return $formaturl;
	}
	sub format_url2 {
		my ($txturl, $txtlink) = @_;
		$txturl =~ s~(\[highlight\]|\[\/highlight\]|\[edit\]|\[\/edit\])~~ig;
		$txturl =~ s~\<.+?\>~~ig;
		my $formaturl = qq~\[url\=$txturl\]$txtlink\[\/url\]~;
		return $formaturl;
	}
	sub format_url3 {
		my $txturl = $_[0];
		my $txtlink = $txturl;
		$txturl =~ s~(\[highlight\]|\[\/highlight\]|\[edit\]|\[\/edit\])~~ig;
		$txturl =~ s~\[~&#91;~g;
		$txturl =~ s~\]~&#93;~g;
		$txturl =~ s~\<.+?\>~~ig;
		my $formaturl = qq~\[url\=$txturl\]$txtlink\[\/url\]~;
		return $formaturl;
	}

	$threadpost =~ s~\[url=\s*(.+?)\s*\]\s*(.+?)\s*\[/url\]~&format_url2($1, $2)~eisg;
	$threadpost =~ s~\[url\]\s*(\S+?)\s*\[/url\]~&format_url3($1)~eisg;

	if ($autolinkurls) {
		$threadpost =~ s~\[url\]\s*([^\[]+)\s*\[/url\]~[url]$1\[/url]~g;
		$threadpost =~ s~\[link\]\s*([^\[]+)\s*\[/link\]~[link]$1\[/link]~g;
		$threadpost =~ s~\[news\](\S+?)\[/news\]~<a href="$1">$1</a>~isg;
		$threadpost =~ s~\[gopher\](\S+?)\[/gopher\]~<a href="$1">$1</a>~isg;
		$threadpost =~ s~&quot;&gt;~">~g; #"
		$threadpost =~ s~(\[\*\])~ $1~g;
		$threadpost =~ s~(\[\/list\])~ $1~g;
		$threadpost =~ s~(\[\/td\])~ $1~g;
		$threadpost =~ s~(\[\/td\])~ $1~g;
		$threadpost =~ s~\<span style\=~\<span_style\=~g;
		$threadpost =~ s~\<div style\=~\<div_style\=~g;
		$threadpost =~ s~([^\w\"\=\[\]]|[\n\b]|\&quot\;|\[quote.*?\]|\[edit\]|\[highlight\]|\[\*\]|\[td\]|\A)\\*(\w+?\:\/\/(?:[\w\~\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\[\](?:\<\S+?\>\S+?\<\/\S+?\>)]+?)\.(?:[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\[\]\x80-\xFF]{1,})+?)~&format_url($1,$2)~eisg;
		$threadpost =~ s~([^\"\=\[\]/\:\.(\://\w+)]|[\n\b]|\&quot\;|\[quote.*?\]|\[edit\]|\[highlight\]|\[\*\]|\[td\]|\A|\()\\*(www\.[^\.](?:[\w\~\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\[\](?:\<\S+?\>\S+?\<\/\S+?\>)]+?)\.(?:[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\[\]\x80-\xFF]{1,})+?)~&format_url($1,$2)~eisg;
		$threadpost =~ s~\<span_style\=~\<span style\=~g;
		$threadpost =~ s~\<div_style\=~\<div style\=~g;
	}

	if ($stealthurl) {
		$threadpost =~ s~\[url=\s*(\w+\://.+?)\](.+?)\s*\[/url\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=$1" target="_blank">$2</a>~isg;
		$threadpost =~ s~\[url=\s*(.+?)\]\s*(.+?)\s*\[/url\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=http://$1" target="_blank">$2</a>~isg;
		$threadpost =~ s~\[link\]\s*www\.\s*(.+?)\s*\[/link\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=http://www.$1">www.$1</a>~isg;
		$threadpost =~ s~\[link=\s*(\w+\://.+?)\](.+?)\s*\[/link\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=$1">$2</a>~isg;
		$threadpost =~ s~\[link=\s*(.+?)\]\s*(.+?)\s*\[/link\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=http://$1">$2</a>~isg;
		$threadpost =~ s~\[link\]\s*(.+?)\s*\[/link\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=$1">$1</a>~isg;
		$threadpost =~ s~\[ftp\]\s*(.+?)\s*\[/ftp\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=$1" target="_blank">$1</a>~isg;
	} else {
		$threadpost =~ s~\[url=\s*(\S\w+\://\S+?)\s*\](.+?)\[/url\]~<a href="$1" target="_blank">$2</a>~isg;
		$threadpost =~ s~\[url=\s*(\S+?)\](.+?)\s*\[/url\]~<a href="http://$1" target="_blank">$2</a>~isg;
		$threadpost =~ s~\[link\]\s*www\.(\S+?)\s*\[/link\]~<a href="http://www.$1">www.$1</a>~isg;
		$threadpost =~ s~\[link=\s*(\S\w+\://\S+?)\s*\](.+?)\[/link\]~<a href="$1">$2</a>~isg;
		$threadpost =~ s~\[link=\s*(\S+?)\](.+?)\s*\[/link\]~<a href="http://$1">$2</a>~isg;
		$threadpost =~ s~\[link\]\s*(\S+?)\s*\[/link\]~<a href="$1">$1</a>~isg;
		$threadpost =~ s~\[ftp\]\s*(ftp://)?(.+?)\s*\[/ftp\]~<a href="ftp://$2">$1$2</a>~isg;
	}

	$threadpost =~ s~(dereferer\;url\=http\:\/\/.*?)#(\S+?\")~$1;anch=$2~isg;

 	if ($guest_media_disallowed && $iamguest) {
		my $oops = qq~$maintxt{'40'}&nbsp;&nbsp;$maintxt{'41'} <a href="$scripturl?action=login">$img{'login'}</a>~;
		if ($regtype) { $oops .= qq~ $maintxt{'42'} <a href="$scripturl?action=register">$img{'register'}</a>~; }

		$threadpost =~ s~<a href=".+?</a>~[oops]~g;
		$threadpost =~ s~<img src=".+?>~[oops]~g;
		$threadpost =~ s~\[media\].*?\[/media\]~[oops]~isg;
		$threadpost =~ s~\[oops\]~$oops~g;
	}

	$threadpost =~ s~\[media\](.*?)\[/media\]~$1~isg;

	$threadpost =~ s~\[email\]\s*(\S+?\@\S+?)\s*\[/email\]~$1~isg;
	$threadpost =~ s~\[email=\s*(\S+?\@\S+?)\]\s*(.*?)\s*\[/email\]~$2 ($1)~isg;

	$threadpost =~ s~\[news\](.+?)\[/news\]~$1~isg;
	$threadpost =~ s~\[gopher\](.+?)\[/gopher\]~$1~isg;
	$threadpost =~ s~\[ftp\](.+?)\[/ftp\]~$1~isg;

	while ($threadpost =~ /\[quote\s+author=(.*?)\slink=.*?\s+date=(.*?)\s*\]\n*.*?\n*\[\/quote\]/is) {
		my $author = $1;
		my $date   = &timeformat($2, 1);

		if ($author) { # out of YaBBC.pl -> sub quotemsg {
			&ToChars($author);
			if (!&checkfor_DBorFILE("$memberdir/$author.vars")) { # if the file is there it is an unencrypted user ID
				$author = &decloak($author); # if not, decrypt it and see if it is a regged user
				if (!&checkfor_DBorFILE("$memberdir/$author.vars")) { # if still not found probably the author is a screen name
					$testauthor = &MemberIndex("who_is", "$author"); # check if this name exists in the memberlist
					if ($testauthor ne ""){ # if it is, load the user id returned
						$author = $testauthor;
						&LoadUser($author);
						$author = ${$uid.$author}{'realname'}; # set final author var to the current users screen name
					} else {
						$author = &decloak($author); # if all fails it is a non existing real name so decode and asign as screenname
					}
				} else {
					&LoadUser($author); # after encoding the user ID was found and loaded, setting the current real name
					$author = ${$uid.$author}{'realname'};
				}
			} else {
				&LoadUser($author); # it was an old style user id which could be loaded and screen name set to final author
				$author = ${$uid.$author}{'realname'};
			}
		}

		$threadpost =~ s~\[quote\s+author=.*?link=.*?\s+date=.*?\s*\]\n*(.*?)\n*\[/quote\]~<br /><i>$author $maintxt{'30a'} $date</a>:</i><table cellspacing="1" width="90%"><tr><td width="100%"><table cellpadding="2" cellspacing="0" width="100%"><tr><td width="100%"><font size="1">$1</font></td></tr></table></td></tr></table>~is;
	}
	$threadpost =~ s~\[quote\]\n*(.+?)\n*\[/quote\]~<br /><i>$maintxt{'31'}:</i><table cellspacing="1" width="90%"><tr><td width="100%"><table cellpadding="2" cellspacing="0" width="100%"><tr><td width="100%"><font face="Arial,Helvetica" size="1">$1</font></td></tr></table></td></tr></table>~isg;

	$threadpost =~ s~\[list\]~<ul>~isg;
	$threadpost =~ s~\[\*\]~<li>~isg;
	$threadpost =~ s~\[/list\]~</ul>~isg;

	$threadpost =~ s~\[pre\](.+?)\[/pre\]~'<pre>' . dopre($1) . '</pre>'~iseg;

	$threadpost =~ s~\[flash=(\S+?),(\S+?)\](\S+?)\[/flash\]~$3~isg;

	$threadpost =~ s~\{\{~\[~g;
	$threadpost =~ s~\}\}~\]~g;

	if ($threadpost =~ m~\[table\]~i) {
		$threadpost =~ s~\n{0,1}\[table\]\n*(.+?)\n*\[/table\]\n{0,1}~<table>$1</table>~isg;
		while ($threadpost =~ s~\<table\>(.*?)\n*\[tr\]\n*(.*?)\n*\[/tr\]\n*(.*?)\</table\>~<table>$1<tr>$2</tr>$3</table>~is) { }
		while ($threadpost =~ s~\<tr\>(.*?)\n*\[td\]\n{0,1}(.*?)\n{0,1}\[/td\]\n*(.*?)\</tr\>~<tr>$1<td>$2</td>$3</tr>~is)     { }
	}

	$threadpost =~ s~\[\&table(.*?)\]~<table$1>~g;
	$threadpost =~ s~\[/\&table\]~</table>~g;
	$threadpost =~ s~\n~<br />~ig;

	### Censor it ###
	$threadtitle = &Censor($threadtitle);
	$threadpost  = &Censor($threadpost);

	&ToChars($threadtitle);
	&ToChars($threadpost);

	$threaddate = timeformat($threaddate, 1);
}

1;