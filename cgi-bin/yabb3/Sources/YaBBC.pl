###############################################################################
# YaBBC.pl                                                                    #
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

$yabbcplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('Post');

$yyYaBBCloaded = 1;

sub MakeSmileys {
	my $message = join "", @_;
	my $i = 0;
	my @HTMLtags;
	while ($message =~ s/(<.+?>)/[HTML$i]/s) { push(@HTMLtags, $1); $i++; }

	$message =~ s/(\W|^)\[smil(ie|ey)=(\S+?\.(gif|jpg|png|bmp))\]/$1<img src="$smiliesurl\/$3" border="0" alt="$post_txt{'287'}" title="$post_txt{'287'}" \/>/ig;
	$message =~ s/(\W|^);-?\)/$1<img src="$imagesdir\/wink.gif" border="0" alt="$post_txt{'292'}" title="$post_txt{'292'}" \/>/g;
	$message =~ s/(\W|^);D/$1<img src="$imagesdir\/grin.gif" border="0" alt="$post_txt{'293'}" title="$post_txt{'293'}" \/>/g;
	$message =~ s/(\W|^):'\(/$1<img src="$imagesdir\/cry.gif" border="0" alt="$post_txt{'530'}" title="$post_txt{'530'}" \/>/g;
	$message =~ s/(\W|^):-\//$1<img src="$imagesdir\/undecided.gif" border="0" alt="$post_txt{'528'}" title="$post_txt{'528'}" \/>/g;
	$message =~ s/(\W|^):-X/$1<img src="$imagesdir\/lipsrsealed.gif" border="0" alt="$post_txt{'527'}" title="$post_txt{'527'}" \/>/g;
	$message =~ s/(\W|^):-\[/$1<img src="$imagesdir\/embarassed.gif" border="0" alt="$post_txt{'526'}" title="$post_txt{'526'}" \/>/g;
	$message =~ s/(\W|^):-\*/$1<img src="$imagesdir\/kiss.gif" border="0" alt="$post_txt{'529'}" title="$post_txt{'529'}" \/>/g;
	$message =~ s/(\W|^)&gt;:\(/$1<img src="$imagesdir\/angry.gif" border="0" alt="$post_txt{'288'}" title="$post_txt{'288'}" \/>/g;
	$message =~ s/(\W|^)::\)/$1<img src="$imagesdir\/rolleyes\.gif" border="0" alt="$post_txt{'450'}" title="$post_txt{'450'}" \/>/g;
	$message =~ s/(\W|^):P/$1<img src="$imagesdir\/tongue\.gif" border="0" alt="$post_txt{'451'}" title="$post_txt{'451'}" \/>/g;
	$message =~ s/(\W|^):-?\)/$1<img src="$imagesdir\/smiley\.gif" border="0" alt="$post_txt{'287'}" title="$post_txt{'287'}" \/>/g;
	$message =~ s/(\W|^):D/$1<img src="$imagesdir\/cheesy.gif" border="0" alt="$post_txt{'289'}" title="$post_txt{'289'}" \/>/g;
	$message =~ s/(\W|^):-?\(/$1<img src="$imagesdir\/sad.gif" border="0" alt="$post_txt{'291'}" title="$post_txt{'291'}" \/>/g;
	$message =~ s/(\W|^):o/$1<img src="$imagesdir\/shocked.gif" border="0" alt="$post_txt{'294'}" title="$post_txt{'294'}" \/>/gi;
	$message =~ s/(\W|^)8-\)/$1<img src="$imagesdir\/cool.gif" border="0" alt="$post_txt{'295'}" title="$post_txt{'295'}" \/>/g;
	$message =~ s/(\W|^):-\?/$1<img src="$imagesdir\/huh.gif" border="0" alt="$post_txt{'296'}" title="$post_txt{'296'}" \/>/g;
	$message =~ s/(\W|^)\^_\^/$1<img src="$imagesdir\/happy.gif" border="0" alt="$post_txt{'801'}" title="$post_txt{'801'}" \/>/g;
	$message =~ s/(\W|^):thumb:/$1<img src="$imagesdir\/thumbsup.gif" border="0" alt="$post_txt{'282'}" title="$post_txt{'282'}" \/>/g;
	$message =~ s/(\W|^)&gt;:-D/$1<img src="$imagesdir\/evil.gif" border="0" alt="$post_txt{'802'}" title="$post_txt{'802'}" \/>/g;

	my $count = 0;
	while ($SmilieURL[$count]) {
		if ($SmilieURL[$count] =~ /\//i) { $tmpurl = $SmilieURL[$count]; }
		else { $tmpurl = qq~$imagesdir/$SmilieURL[$count]~; }
		$tmpcode = $SmilieCode[$count];
		$tmpcode =~ s/&#36;/\$/g;
		$tmpcode =~ s/&#64;/\@/g;
		$message =~ s~\Q$tmpcode\E~<img src="$tmpurl" border="0" alt="$SmilieDescription[$count]" title="$SmilieDescription[$count]" />~g;
		$count++;
	}

	$i = 0;
	while ($message =~ s/\[HTML$i\]/$HTMLtags[$i]/s) { $i++; }
	
	return $message;
}

@ycssvalues = ('quote', 'quote2');
$ycssnum = 2;
$ycsscounter = 2;
sub quotemsg {
	my ($qauthor, $qlink, $qdate, $qmessage) = @_;
	my ($testauthor,$fqauthor);
	if ($qauthor) {
		$usernames_life_quote{'temp_quote_autor'} = $qauthor; # for display names in Quotes in LivePreview
		&ToChars($qauthor);
		if (!&checkfor_DBorFILE("$memberdir/$qauthor.vars")) { # if the file is there it is an unencrypted user ID
			$qauthor = &decloak($qauthor); # if not, decrypt it and see if it is a regged user
			if (!&checkfor_DBorFILE("$memberdir/$qauthor.vars")) { # if still not found probably the author is a screen name
				$testauthor = &MemberIndex("who_is", "$qauthor"); # check if this name exists in the memberlist
				if ($testauthor ne ""){ # if it is, load the user id returned
					$qauthor = $testauthor;
					&LoadUser($qauthor);
					$fqauthor = ${$uid.$qauthor}{'realname'}; # set final author var to the current users screen name
				} else {
					$fqauthor = &decloak($qauthor); # if all fails it is a non existing real name so decode and asign as screenname
				}
			} else {
				&LoadUser($qauthor); # after encoding the user ID was found and loaded, setting the current real name
				$fqauthor = ${$uid.$qauthor}{'realname'};
			}
		} else {
			&LoadUser($qauthor); # it was an old style user id which could be loaded and screen name set to final author
			$fqauthor = ${$uid.$qauthor}{'realname'};
		}
		$qmessage =~ s~\/me\s+(.*?)(\n|\Z)(.*?)~<span style="color: #FF0000;">* $fqauthor $1</span>$2$3~ig;
	}
	# next 2 lines: for display names in Quotes in LivePreview
	$usernames_life_quote{$usernames_life_quote{'temp_quote_autor'}} = $fqauthor;
	delete $usernames_life_quote{'temp_quote_autor'};

	$qmessage = &parseimgflash($qmessage);
	$qdate    = &timeformat($qdate); # generates also the global variable $daytxt
	$cssbg = $ycssvalues[($ycsscounter % $ycssnum)];
	$ycsscounter++;
	if ($fqauthor eq '' || $qlink eq '' || $qdate eq '') { $_ = $post_txt{'601'}; }
	elsif ($qlink eq 'impost') {
		$_ = $daytxt ? $post_txt{'600a_d'} : $post_txt{'600a'};
		$_ =~ s~AUTHOR2~$scripturl?action=viewprofile;username=$useraccount{$qauthor}~g; }
	elsif ($action ne 'imshow' && $action ne 'imsend' && $action ne 'imsend2') { $_ = $daytxt ? $post_txt{'600_d'} : $post_txt{'600'}; }
	else  { $_ = $daytxt ? $post_txt{'599_d'} : $post_txt{'599'}; }
	$_ =~ s~AUTHOR~$fqauthor~g;
	$_ =~ s~QUOTELINK~$scripturl?num=$qlink~g;
	$_ =~ s~DATE~$qdate~g;
	$_ =~ s~QUOTECSS~$cssbg~g;
	$_ =~ s~QUOTE~$qmessage~g;
	$_;
}

sub parseimgflash {
	my $tmp_message = $_[0];
	$tmp_message =~ s~\[flash\=(\S+?),(\S+?)](\S+?)\[\/flash\]~<b>$display_txt{'769'} ($1 x $2):</b> <a href="$3" target="_blank" onclick="window.open('$3', 'flash', 'resizable,width=$1,height=$2'); return false;">>$3</a>~g;
	my $char_160  = chr(160);
	my $hardspace = qq~&nbsp;~;
	if (!$showimageinquote) {
		$tmp_message =~ s~\[img (.+?)\]~[img\]~isg;
		$tmp_message =~ s~\[img\](?:\s|\t|\n|$hardspace|$char_160)*(http\:\/\/)*(.+?)(?:\s|\t|\n|$hardspace|$char_160)*\[/img\]~\[url\]$1$2\[\/url\]~isg;
	}
	$tmp_message;
}

sub sizefont {
	## limit minimum and maximum font pitch as CSS does not restrict it at all. ##
	my ($tsize, $ttext) = @_;
	if    (!$fontsizemax)         { $fontsizemax = 72; }
	if    (!$fontsizemin)         { $fontsizemin = 6; }
	if    ($tsize < $fontsizemin) { $tsize       = $fontsizemin; }
	elsif ($tsize > $fontsizemax) { $tsize       = $fontsizemax; }
	return qq~<div style="display:inline; font-size:$tsize\pt;">$ttext</div>~;
}

{
	my %killhash = (
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
		'^'  => '&#94;',
		'D'  => '&#068;'
		);

	$codecnt = 0;
	sub codemsg {
		my $code = $_[0];
		my $class = $_[1];
		my $prclass = "";
		if(lc $class eq "c++") { $insclass = "sh_cpp"; $prclass = " (C++)"; }
		elsif(lc $class eq "css") { $insclass = "sh_css"; $prclass = " (CSS)"; }
		elsif(lc $class eq "html") { $insclass = "sh_html"; $prclass = " (HTML)"; }
		elsif(lc $class eq "java") { $insclass = "sh_java"; $prclass = " (Java)"; }
		elsif(lc $class eq "javascript") { $insclass = "sh_javascript"; $prclass = " (Javascript)"; }
		elsif(lc $class eq "pascal") { $insclass = "sh_pascal"; $prclass = " (Pascal)"; }
		elsif(lc $class eq "perl") { $insclass = "sh_perl"; $prclass = " (Perl)"; }
		elsif(lc $class eq "php") { $insclass = "sh_php"; $prclass = " (PHP)"; }
		elsif(lc $class eq "sql") { $insclass = "sh_sql"; $prclass = " (SQL)"; }
		else { $insclass = "code"; }
		&ToChars($code);
		if ($code !~ /&\S*;/) { $code =~ s/;/&#059;/g; }
		$code =~ s~([\(\)\-\:\\\/\?\!\]\[\.\^\.D])~$killhash{$1}~g;
		$code =~ s~\&\#91\;highlight\&\#93\;(.*?)\&\#91\;\&\#47\;highlight\&\#93\;~<span class="highlight">$1</span>~isg;
		$_ = $post_txt{'602'};

		# Thx. to Michael Prager for the improved Code boxes
		# count lines in code
		$linecount = () = $code =~ /\n/g;

		# if more that 20 lines then limit code box height
		if ($linecount > 20) {
			$height = "height: 300px;";
		} else {
			$height = "";
		}

		# try to display text as it was originally intended
		$code =~ s~ \&nbsp; \&nbsp; \&nbsp;~\t~ig;
		$code =~ s~\&nbsp;~ ~ig;
		$code =~ s~\s*?\n\s*?~\[code_br\]~ig; # we need to keep normal linebreaks inside <pre> tag
		$codecnt++;
		$prselect = qq~<a href="javascript:selectAllCode($codecnt)"><img src="$imagesdir/codeselect.png" border="0" alt="$post_txt{'selectall'}" title="$post_txt{'selectall'}" /></a>~;
		$code = qq~<pre class="$insclass" id="code$codecnt" style="margin: 0px; width: 90%; $height overflow: scroll;">$code\[code_br][code_br]</pre>~;
		$_ =~ s~XSELECTX~$prselect~g;
		$_ =~ s~XLANGX~$prclass~g;
		$_ =~ s~CODE~$code~g;
		$_;
	}

	sub noparse {
		my $noubbc = $_[0];
		$noubbc =~ s~([;!\(\)\-\.\/:\?\[\\\]\^D])~$killhash{$1}~g;
		$noubbc;
	}
}

sub imagemsg {
	my ($rest,$attribut,$url,$type) = @_;
	# use or kill urls
	$url =~ s~\[url\](.*?)\[/url\]~$1~ig;
	$url =~ s~\[link\](.*?)\[/link\]~$1~ig;
	$url =~ s~\[url\s*=\s*(.*?)\s*.*?\].*?\[/url\]~$1~ig;
	$url =~ s~\[link\s*=\s*(.*?)\s*.*?\].*?\[/link\]~$1~ig;
	$url =~ s~\[url.*?/url\]~~ig;
	$url =~ s~\[link.*?/link\]~~ig;

	my $char_160 = chr(160);
	$url =~ s/\s|\?|&nbsp;|$char_160//g;

	if ($url !~ /^http.+\.(gif|jpg|jpeg|png|bmp)$/i) {return $rest . $url;}

	my %parameter;
	&FromHTML($attribut);
	$attribut =~ s/(\s|$char_160)+/ /g;
	foreach (split(/ +/, $attribut)) {
		my ($key, $value) = split(/=/, $_);
		$value =~ s/["']//g;
		$parameter{$key} = $value;
	}

	$parameter{'name'} = $type ? 'signat_img_resize' : 'post_img_resize';
	$parameter{'alt'} =~ s/[<>"]/*/g;
	$parameter{'alt'} ||= "...";
	$parameter{'align'}  =~ s~[^a-z]~~ig;
	$parameter{'width'}  =~ s~\D~~g;
	$parameter{'height'} =~ s~\D~~g;
	if ($parameter{'align'})  { $parameter{'align'}  = qq~ align="$parameter{'align'}"~; }
	if ($parameter{'width'})  { $parameter{'width'}  = qq~ width="$parameter{'width'}"~; }
	if ($parameter{'height'}) { $parameter{'height'} = qq~ height="$parameter{'height'}"~; }

	my $linkedimg = $rest =~ /\[url[^\[]*\]\s*$/i ? 1 : 0;
	$rest . ((!$linkedimg && $img_greybox) ? qq~<a href="$url" rel="gb_image[nice_pics]" title="$parameter{'alt'}">~ : '') . qq~<img src="$url" name="$parameter{'name'}" alt="$parameter{'alt'}" title="$parameter{'alt'}"$parameter{'align'}$parameter{'width'}$parameter{'height'} border="0" style="display:none" />~ . ((!$linkedimg && $img_greybox) ? '</a>' : '');
}

sub DoUBBC {
	return $message if $ns eq "NS" || $message =~ s/#nosmileys//isg;

	my $image_type = $_[0];
	$ycsscounter = 2;

	$message =~ s~\[noparse\](.*?)(\[/noparse\]|$)~noparse($1)~eisg;

	$message =~ s~\[code\]~ \[code\]~ig;
	$message =~ s~\[/code\]~ \[/code\]~ig;

	$message =~ s~\[quote\]~ \[quote\]~ig;
	$message =~ s~\[/quote\]~ \[/quote\]~ig;
	$message =~ s~\[glow\]~ \[glow\]~ig;
	$message =~ s~\[/glow\]~ \[/glow\]~ig;
	$message =~ s~<br>|<br />~\n~ig;
	$message =~ s~\[code\s*(.*?)\]\n*(.+?)\n*\[/code\]~&codemsg($2,$1)~eisg; # [code] must come at first! At least before image transformation!

	$message =~ s~\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[$1$2\]~g;
	$message =~ s~\[/([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[/$1$2\]~g;
	#$message =~ s~(\w+://[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)~$1\n$2~g;
	$message =~ s~\[b\](.*?)\[/b\]~<b>$1</b>~isg;
	$message =~ s~\[i\](.*?)\[/i\]~<i>$1</i>~isg;
	$message =~ s~\[u\](.*?)\[/u\]~<u>$1</u>~isg;
	$message =~ s~\[s\](.*?)\[/s\]~<s>$1</s>~isg;
	$message =~ s~\[glb\](.*?)\[/glb\]~<div style="display:inline; font-weight: bold;">$1</div>~isg;
	$message =~ s~( |&nbsp;)*\[move\](.*?)\[/move\]~<marquee>$2</marquee>~isg;

	# Quote message
	while ($message =~ s~\[quote(\s+author=(.*?)\s+link=(.*?)\s+date=(.*?)\s*)?\]\n*(.*?)\n*\[/quote\]~ &quotemsg($2,$3,$4,$5) ~eisg) { }

	# Images in message. Must come behind "Quote message" due to $showimageinquote in &quotemsg -> &parseimgflash
	while ($message =~ s~(\[url[^\[]*\]\s*)?\[img(.*?)\](.*?)\[/img\]~ &imagemsg($1,$2,$3,$image_type) ~eisg) { }

	$message =~ s~\[color=([A-Za-z0-9# ]+)\](.+?)\[/color\]~<div style="display:inline; color: $1;">$2</div>~isg;
	$message =~ s~\[black\](.*?)\[/black\]~<div style="display:inline; color:#000000;">$1</div>~isg;
	$message =~ s~\[white\](.*?)\[/white\]~<div style="display:inline; color:#FFFFFF;">$1</div>~isg;
	$message =~ s~\[red\](.*?)\[/red\]~<div style="display:inline; color:#FF0000;">$1</div>~isg;
	$message =~ s~\[green\](.*?)\[/green\]~<div style="display:inline; color:#00FF00;">$1</div>~isg;
	$message =~ s~\[blue\](.*?)\[/blue\]~<div style="display:inline; color:#0000FF;">$1</div>~isg;
	$message =~ s~\[timestamp\=([\d]{9,10})\]~&timeformat($1)~eisg;
	$message =~ s~\[font=([A-Za-z0-9# -]+)\](.+?)\[/font\]~<div style="display:inline; font-family: $1;">$2</div>~isg;
	while ($message =~ s~\[size=([A-Za-z0-9# ]+)\](.+?)\[/size\]~&sizefont($1,$2)~eisg) { }

	$message =~ s~\[tt\](.*?)\[/tt\]~<tt>$1</tt>~isg;
	$message =~ s~\[left\](.*?)\[/left\]~<div style="text-align: left;">$1</div>~isg;
	$message =~ s~\[center\](.*?)\[/center\]~<center>$1</center>~isg;
	$message =~ s~\[right\](.*?)\[/right\]~<div style="text-align: right;">$1</div>~isg;
	$message =~ s~\[justify\](.*?)\[/justify\]~<div style="text-align: justify">$1</div>~isg;
	$message =~ s~\[sub\](.*?)\[/sub\]~<sub>$1</sub>~isg;
	$message =~ s~\[sup\](.*?)\[/sup\]~<sup>$1</sup>~isg;
	$message =~ s~\[fixed\](.*?)\[/fixed\]~<div style="display:inline; font-family: Courier New;">$1</div>~isg;

	$message =~ s~\[hr\]\n~<hr width="40%" align="left" size="1" class="hr" />~g;
	$message =~ s~\[hr\]~<hr width="40%" align="left" size="1" class="hr" />~g;
	$message =~ s~\[br\]~\n~ig;
	$message =~ s~\s$YaBBversion\s~ \<a style\=\"font-weight: bold;\" href\=\"http\:\/\/www\.yabbforum\.com\/downloads\.php\"\>$YaBBversion Forum Software\<\/a\> ~g;

	$message =~ s~\[highlight\](.*?)\[/highlight\]~<span class="highlight">$1</span>~isg;

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
		qq~$txtfirst\[url\=$txturl\]$realurl\[\/url\]$lasttxt~;
	}
	sub format_url2 {
		my ($txturl, $txtlink) = @_;
		$txturl =~ s~(\[highlight\]|\[\/highlight\]|\[edit\]|\[\/edit\])~~ig;
		$txturl =~ s~\<.+?\>~~ig;
		qq~[url=$txturl]$txtlink\[/url]~;
	}
	sub format_url3 {
		my $txturl = $_[0];
		my $txtlink = $txturl;
		$txturl =~ s~(\[highlight\]|\[\/highlight\]|\[edit\]|\[\/edit\])~~ig;
		$txturl =~ s~\[~&#91;~g;
		$txturl =~ s~\]~&#93;~g;
		$txturl =~ s~\<.+?\>~~ig;
		qq~[url=$txturl]$txtlink\[/url]~;
	}

	$message =~ s~\[url=\s*(.+?)\s*\]\s*(.+?)\s*\[/url\]~&format_url2($1, $2)~eisg;
	$message =~ s~\[url\]\s*(\S+?)\s*\[/url\]~&format_url3($1)~eisg;

	if ($autolinkurls) {
		$message =~ s~\[url\]\s*([^\[]+)\s*\[/url\]~[url]$1\[/url]~g;
		$message =~ s~\[link\]\s*([^\[]+)\s*\[/link\]~[link]$1\[/link]~g;
		$message =~ s~\[news\](\S+?)\[/news\]~<a href="$1">$1</a>~isg;
		$message =~ s~\[gopher\](\S+?)\[/gopher\]~<a href="$1">$1</a>~isg;
		$message =~ s~&quot;&gt;~">~g; #"
		$message =~ s~(\[\*\])~ $1~g;
		$message =~ s~(\[\/list\])~ $1~g;
		$message =~ s~(\[\/td\])~ $1~g;
		$message =~ s~(\[\/td\])~ $1~g;
		$message =~ s~\<span style\=~\<span_style\=~g;
		$message =~ s~\<div style\=~\<div_style\=~g;
		$message =~ s~([^\w\"\=\[\]]|[\n\b]|\&quot\;|\[quote.*?\]|\[edit\]|\[highlight\]|\[\*\]|\[td\]|\A)\\*(\w+?\:\/\/(?:[\w\~\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\[\](?:\<\S+?\>\S+?\<\/\S+?\>)]+?)\.(?:[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\[\]\x80-\xFF]{1,})+?)~&format_url($1,$2)~eisg;
		$message =~ s~([^\"\=\[\]/\:\.\-(\://\w+)]|[\n\b]|\&quot\;|\[quote.*?\]|\[edit\]|\[highlight\]|\[\*\]|\[td\]|\A|\()\\*(www\.[^\.](?:[\w\~\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\[\](?:\<\S+?\>\S+?\<\/\S+?\>)]+?)\.(?:[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%\(\)\[\]\x80-\xFF]{1,})+?)~&format_url($1,$2)~eisg;
		$message =~ s~\<span_style\=~\<span style\=~g;
		$message =~ s~\<div_style\=~\<div style\=~g;
	}

	if ($stealthurl) {
		#$message =~ s~\[url\]\s*www\.\s*(.+?)\s*\[/url\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=http://www.$1" target="_blank">www.$1</a>~isg;
		$message =~ s~\[url=\s*(\w+\://.+?)\](.+?)\s*\[/url\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=$1" target="_blank">$2</a>~isg;
		$message =~ s~\[url=\s*(.+?)\]\s*(.+?)\s*\[/url\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=http://$1" target="_blank">$2</a>~isg;
		#$message =~ s~\[url\]\s*(.+?)\s*\[/url\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=$1" target="_blank">$1</a>~isg;

		$message =~ s~\[link\]\s*www\.\s*(.+?)\s*\[/link\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=http://www.$1">www.$1</a>~isg;
		$message =~ s~\[link=\s*(\w+\://.+?)\](.+?)\s*\[/link\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=$1">$2</a>~isg;
		$message =~ s~\[link=\s*(.+?)\]\s*(.+?)\s*\[/link\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=http://$1">$2</a>~isg;
		$message =~ s~\[link\]\s*(.+?)\s*\[/link\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=$1">$1</a>~isg;

		$message =~ s~\[ftp\]\s*(.+?)\s*\[/ftp\]~<a href="$boardurl/$yyexec.$yyext?action=dereferer;url=$1" target="_blank">$1</a>~isg;
	} else {
		#$message =~ s~\[url\]\s*www\.(\S+?)\s*\[/url\]~<a href="http://www.$1" target="_blank">www.$1</a>~isg;
		$message =~ s~\[url=\s*(\S\w+\://\S+?)\s*\](.+?)\[/url\]~<a href="$1" target="_blank">$2</a>~isg;
		$message =~ s~\[url=\s*(\S+?)\](.+?)\s*\[/url\]~<a href="http://$1" target="_blank">$2</a>~isg;
		#$message =~ s~\[url\]\s*(http://)?(\S+?)\s*\[/url\]~<a href="http://$2" target="_blank">$1$2</a>~isg;

		$message =~ s~\[link\]\s*www\.(\S+?)\s*\[/link\]~<a href="http://www.$1">www.$1</a>~isg;
		$message =~ s~\[link=\s*(\S\w+\://\S+?)\s*\](.+?)\[/link\]~<a href="$1">$2</a>~isg;
		$message =~ s~\[link=\s*(\S+?)\](.+?)\s*\[/link\]~<a href="http://$1">$2</a>~isg;
		$message =~ s~\[link\]\s*(\S+?)\s*\[/link\]~<a href="$1">$1</a>~isg;

		$message =~ s~\[ftp\]\s*(ftp://)?(.+?)\s*\[/ftp\]~<a href="ftp://$2">$1$2</a>~isg;
	}

	$message =~ s~(dereferer\;url\=http\:\/\/.*?)#(\S+?\")~$1;anch=$2~isg;
	$message =~ s~\[email\]\s*(\S+?\@\S+?)\s*\[/email\]~<a href="mailto:$1">$1</a>~isg;
	$message =~ s~\[email=\s*(\S+?\@\S+?)\](.*?)\[/email\]~<a href="mailto:$1">$2</a>~isg;

	$message =~ s~\[edit\](.*?)\[/edit\]~<b>$post_txt{'603'}: </b><br /><div class="editbg" style="overflow: auto;">$1</div>~isg;

	$message =~ s~/me ~<i>$displayname</i> ~ig;

	if($message =~ /\[media/ || $message =~ /\[flash/) {
		require "$sourcedir/MediaCenter.pl";
		$message =~ s~\[flash\](.*?)\[/flash\]~\[media\]$1\[/media\]~isg; # convert old flash tags to media tags
		while ($message =~ s~\[flash\s*(.*?)\]\n*(.*?)\n*\[/flash\]~&flashconvert($2,$1)~eisg){ } # convert old flash tags to media tags
		while ($message =~ s~\[media\]\n*(.*?)\n*\[/media\]~&embed($1)~eisg){ }
		while ($message =~ s~\[media\s*(.*?)\]\n*(.*?)\n*\[/media\]~&embed($2,$1)~eisg){ }
		$message =~ s~media:~http:~ig;
	}

	if ($guest_media_disallowed && $iamguest) {
		my $oops = qq~$maintxt{'40'}&nbsp;&nbsp;$maintxt{'41'} <a href="$scripturl?action=login;sesredir=num\~$curnum">$img{'login'}</a>~;
		if ($regtype) { $oops .= qq~ $maintxt{'42'} <a href="$scripturl?action=register">$img{'register'}</a>~; }

		$showattach = '';
		$showattachhr = '';
		$attachment =~ s~<a href=".+?</a>~[oops]~g;
		$attachment =~ s~<img src=".+?>~[oops]~g;
		$attachment =~ s~\[oops\]~$oops~g;
		$message =~ s~<a href=".+?</a>~[oops]~g;
		$message =~ s~<img src=".+?>~[oops]~g;
		$message =~ s~\[oops\]~$oops~g;
	}

	$message = MakeSmileys($message);

	$message =~ s~\s*\[\*\]~</li><li>~isg;
	$message =~ s~\[olist\]~<ol>~isg;
	$message =~ s~\s*\[/olist\]~</li></ol>~isg;
	$message =~ s~</li><ol>~<ol>~isg;
	$message =~ s~<ol></li>~<ol>~isg;
	$message =~ s~\[list\]~<ul>~isg;
	$message =~ s~\[list (.+?)\]~<ul style="list-style-image\: url($defaultimagesdir\/$1\.gif)">~isg;
	$message =~ s~\s*\[/list\]~</li></ul>~isg;
	$message =~ s~</li><ul>~<ul>~isg;
	$message =~ s~<ul></li>~<ul>~isg;
	$message =~ s~</li><ul (.+?)>~<ul $1>~isg;
	$message =~ s~<ul (.+?)></li>~<ul $1>~isg;

	$message =~ s~\[pre\](.+?)\[/pre\]~'<pre>' . dopre($1) . '</pre>'~iseg;

	if ($message =~ m~\[table\](?:.*?)\[/table\]~is) {
		while ($message =~ s~<marquee>(.*?)\[table\](.*?)\[/table\](.*?)</marquee>~<marquee>$1<table>$2</table>$3</marquee>~s)        { }
		while ($message =~ s~<marquee>(.*?)\[table\](.*?)</marquee>(.*?)\[/table\]~<marquee>$1\[//table\]$2</marquee>$3\[//table\]~s) { }
		while ($message =~ s~\[table\](.*?)<marquee>(.*?)\[/table\](.*?)</marquee>~\[//table\]$1<marquee>$2\[//table\]$3</marquee>~s) { }
		$message =~ s~\n{0,1}\[table\]\n*(.+?)\n*\[/table\]\n{0,1}~<table>$1</table>~isg;
		while ($message =~ s~\<table\>(.*?)\n*\[tr\]\n*(.*?)\n*\[/tr\]\n*(.*?)\</table\>~<table>$1<tr>$2</tr>$3</table>~is) { }
		while ($message =~ s~\<tr\>(.*?)\n*\[td\]\n{0,1}(.*?)\n{0,1}\[/td\]\n*(.*?)\</tr\>~<tr>$1<td>$2</td>$3</tr>~is) { }
		$message =~ s~<table>((?:(?!<tr>|</tr>|<td>|</td>|<table>|</table>).)*)<tr>~<table><tr>~isg;
		$message =~ s~<tr>((?:(?!<tr>|</tr>|<td>|</td>|<table>|</table>).)*)<td>~<tr><td>~isg;
		$message =~ s~</td>((?:(?!<tr>|</tr>|<td>|</td>|<table>|</table>).)*)<td>~</td><td>~isg;
		$message =~ s~</td>((?:(?!<tr>|</tr>|<td>|</td>|<table>|</table>).)*)</tr>~</td></tr>~isg;
		$message =~ s~</td>((?!<tr>|</tr>|<td>|</td>|<table>|</table>).*?)<td>~</td><td>~isg;
		$message =~ s~</td>((?!<tr>|</tr>|<td>|</td>|<table>|</table>).*?)</tr>~</td></tr>~isg;
		$message =~ s~</tr>((?:(?!<tr>|</tr>|<td>|</td>|<table>|</table>).)*)<tr>~</tr><tr>~isg;
		$message =~ s~</tr>((?:(?!<tr>|</tr>|<td>|</td>|<table>|</table>).)*)</table>~</tr></table>~isg;
	}

	while ($message =~ s~<a([^>]*?)\n([^>]*)>~<a$1$2>~)                  { }
	while ($message =~ s~<a([^>]*)>([^<]*?)\n([^<]*)</a>~<a$1>$2$3</a>~) { }
	while ($message =~ s~<a([^>]*?)&amp;([^>]*)>~<a$1&$2>~)              { }

	$message =~ s~\[\&table(.*?)\]~<table$1>~g;
	$message =~ s~\[/\&table\]~</table>~g;
	$message =~ s~\n~<br />~ig;
	$message =~ s~\[code_br\]~\n~ig;

	return $message;
}

sub DoUBBCTo {
	# Does UBBC to $_[0] using &DoUBBC and keeps $message the same
	my($messagecopy, $returnthis);
	$messagecopy = $message;
	$message = $_[0];
	&DoUBBC;
	$returnthis = $message;
	$message = $messagecopy;
	$returnthis;
}

1;