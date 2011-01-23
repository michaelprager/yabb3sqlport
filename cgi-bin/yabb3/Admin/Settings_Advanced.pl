###############################################################################
# Settings_Advanced.pl                                                        #
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

$settings_advancedplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

my $uploaddiriscorrect = qq~<span style="color: red;">$admin_txt{'164'}</span>~;
if(-w $uploaddir && -d $uploaddir) {$uploaddiriscorrect = qq~<span style="color: green;">$admin_txt{'163'}</span>~;}

# Setting for gzip, if it's available
my $compressgzip = (-e "/bin/gzip" && open(GZIP, "| gzip -f")) ? qq~\n  <option value="1" ${isselected($gzcomp == 1)}>$gztxt{'4'}</option>~ : '';

# Setting for Compress::Zlib, if it's available
my $compresszlib;
eval { require Compress::Zlib; Compress::Zlib::memGzip("test"); };
$compresszlib = qq~\n  <option value="2" ${isselected($gzcomp == 2)}>$gztxt{'5'}</option>~ unless $@;

# RSS Defaults 
if ($rss_disabled eq '') { $rss_disabled = 0; }
if ($rss_limit eq '') { $rss_limit = 10; }
if ($rss_message eq '') { $rss_message = 1; }

# Free Disk Space Checking
my @disk_space = qx{df -k .};
map { $_ =~ s/ +/  /g } @disk_space;

my @find = qx(find . -noleaf -type f -printf "%s-");

$hostusername = $hostusername || (split(/ +/, qx{ls -l YaBB.$yyext}))[2];
my @quota = qx{quota -u $hostusername -v};
$quota[0] =~ s/^ +//;
$quota[0] =~ s/ /&nbsp;/g;
$quota[1] =~ s/^ +//;
$quota[1] =~ s/ /&nbsp;/g;
my $quota_select = qq~$quota[0]<br />$quota[1]~;
if ($quota[2]) {
	my $ds = (split(/ +/, $disk_space[1], 2))[0] if !$enable_quota;
	$quota_select .= qq~<br /><select name="enable_quota_value">~;
	for (my $i = 2; $i < @quota; $i++) {
		$quota[$i] =~ s/^ +//;
		$quota[$i] =~ s/ +/&nbsp;&nbsp;/g;
		$quota_select .= qq~<option value="$i" ~ . ${isselected($i == $enable_quota || ($ds && $quota[$i] =~ /^$ds/))} . qq~>$quota[$i]</option>~;
	}
	$quota_select .= '</select>';
}

# List of settings
@settings = (
{
	name  => $settings_txt{'permarss'},
	id    => 'permarss',
	items => [
		# Permalinks
		{
			header => $admin_txt{'24'},
		},
		{
			description => qq~<label for="accept_permalink">$admin_txt{'22'}</label>~,
			input_html => qq~<input type="checkbox" name="accept_permalink" id="accept_permalink" value="1" ${ischecked($accept_permalink)}/>~,
			name => 'accept_permalink',
			validate => 'boolean',
		},
		{
			description => qq~<label for="symlink">$admin_txt{'25'}<br /><span class="small">$admin_txt{'26'}</span></label>~,
			input_html => qq~<input type="text" size="30" name="symlink" id="symlink" value="$symlink" />~,
			name => 'symlink',
			validate => 'text,null',
			depends_on => ['accept_permalink'],
		},
		{
			description => qq~<label for="perm_domain">$admin_txt{'23'}</label>~,
			input_html => qq~<input type="text" size="30" name="perm_domain" id="perm_domain" value="$perm_domain" />~,
			name => 'perm_domain',
			validate => 'text,null',
			depends_on => ['accept_permalink'],
		},
		# RSS
		{
			header => $settings_txt{'rss'},
		},
		{
			description => qq~<label for="rss_disabled">$rss_txt{'1'}</label>~,
			input_html => qq~<input type="checkbox" name="rss_disabled" id="rss_disabled" value="1"${ischecked($rss_disabled)} />~,
			name => 'rss_disabled',
			validate => 'boolean',
		},
		{
			description => qq~<label for="rss_limit">$rss_txt{'2'}</label>~,
			input_html => qq~<input type="text" name="rss_limit" id="rss_limit" size="5" value="$rss_limit" />~,
			name => 'rss_limit',
			validate => 'number',
			depends_on => ['!rss_disabled'],
		},

		{
			description => qq~<label for="showauthor">$rss_txt{'7'}</label>~,
			input_html => qq~<input type="checkbox" name="showauthor" id="showauthor" size="5"${ischecked($showauthor)} />~,
			name => 'showauthor',
			validate => 'boolean',
			depends_on => ['!rss_disabled'],
		},
		{
			description => qq~<label for="showdate">$rss_txt{'8'}</label>~,
			input_html => qq~<input type="checkbox" name="showdate" id="showdate" size="5"${ischecked($showdate)} />~,
			name => 'showdate',
			validate => 'boolean',
			depends_on => ['!rss_disabled'],
		},
		{
			description => qq~<label for="rss_message">$rss_txt{'3'}</label>~,
			input_html => qq~
<select name="rss_message" id="rss_message" size="1">
  <option value="0" ${isselected($rss_message == 0)}>$rss_txt{'4'}</option>
  <option value="1" ${isselected($rss_message == 1)}>$rss_txt{'5'}</option>
  <option value="2" ${isselected($rss_message == 2)}>$rss_txt{'6'}</option>
</select>~,
			name => 'rss_message',
			validate => 'number',
			depends_on => ['!rss_disabled'],
		},
		
	],
},
{
	name  => $settings_txt{'email'},
	id    => 'email',
	items => [
		# Email
		{
			header => $settings_txt{'email'},
		},
		{
			description => qq~<label for="mailtype">$admin_txt{'404'}</label>~,
			input_html => qq~
<select name="mailtype" id="mailtype" size="1">
  <option value="0" ${isselected($mailtype == 0)}>$smtp_txt{'sendmail'}</option>
  <option value="1" ${isselected($mailtype == 1)}>$smtp_txt{'smtp'}</option>
  <option value="2" ${isselected($mailtype == 2)}>$smtp_txt{'net'}</option>
  <option value="3" ${isselected($mailtype == 3)}>$smtp_txt{'tslnet'}</option>
</select>~,
			name => 'mailtype',
			validate => 'number',
		},
		{
			description => qq~<label for="mailprog">$admin_txt{'354'}</label>~,
			input_html => qq~<input type="text" name="mailprog" id="mailprog" size="20" value="$mailprog" />~,
			name => 'mailprog',
			validate => 'text,null',
		},
		{
			description => qq~<label for="smtp_server">$admin_txt{'407'}</label>~,
			input_html => qq~<input type="text" name="smtp_server" id="smtp_server" size="20" value="$smtp_server" />~,
			name => 'smtp_server',
			validate => 'text,null',
		},
		{
			description => qq~<label for="smtp_auth_required">$smtp_txt{'1'}</label>~,
			input_html => qq~
<select name="smtp_auth_required" id="smtp_auth_required" size="1">
  <option value="4" ${isselected($smtp_auth_required == 4)}>$smtp_txt{'auto'}</option>
  <option value="3" ${isselected($smtp_auth_required == 3)}>$smtp_txt{'cram'}</option>
  <option value="2" ${isselected($smtp_auth_required == 2)}>$smtp_txt{'login'}</option>
  <option value="1" ${isselected($smtp_auth_required == 1)}>$smtp_txt{'plain'}</option>
  <option value="0" ${isselected($smtp_auth_required == 0)}>$smtp_txt{'off'}</option>
</select>~,
			name => 'smtp_auth_required',
			validate => 'number',
		},
		{
			description => qq~<label for="authuser">$smtp_txt{'3'}</label>~,
			input_html => qq~<input type="text" name="authuser" id="authuser" size="20" value="$authuser" />~,
			name => 'authuser',
			validate => 'text,null',
		},
		{
			description => qq~<label for="authpass">$smtp_txt{'4'}</label>~,
			input_html => qq~<input type="password" name="authpass" id="authpass" size="20" value="$authpass" />~,
			name => 'authpass',
			validate => 'text,null',
		},
		{
			description => qq~<label for="webmaster_email">$admin_txt{'355'}</label>~,
			input_html => qq~<input type="text" name="webmaster_email" id="webmaster_email" size="35" value="$webmaster_email" />~,
			name => 'webmaster_email',
			validate => 'text',
		},
		# New Member Notification
		{
			header => $admin_txt{'366'},
		},
		{
			description => qq~<label for="new_member_notification">$admin_txt{'367'}</label>~,
			input_html => qq~<input type="checkbox" name="new_member_notification" id="new_member_notification" value="1"${ischecked($new_member_notification)} />~,
			name => 'new_member_notification',
			validate => 'boolean',
		},
		{
			description => qq~<label for="new_member_notification_mail">$admin_txt{'368'}</label>~,
			input_html => qq~<input type="text" name="new_member_notification_mail" id="new_member_notification_mail" size="35" value="$new_member_notification_mail" />~,
			name => 'new_member_notification_mail',
			validate => 'text,null',
			depends_on => ['new_member_notification']
		},
		# New Member Notification
		{
			header => $admin_txt{'600'},
		},
		{
			description => qq~<label for="sendtopicmail">$admin_txt{'601'}</label>~,
			input_html => qq~<select name="sendtopicmail" id="sendtopicmail">
				<option value="0"${isselected($sendtopicmail == 0)}>$admin_txt{'602'}</option>
				<option value="1"${isselected($sendtopicmail == 1)}>$admin_txt{'603'}</option>
				<option value="2"${isselected($sendtopicmail == 2)}>$admin_txt{'604'}</option>
				<option value="3"${isselected($sendtopicmail == 3)}>$admin_txt{'605'}</option>
			</select>~,
			name => 'sendtopicmail',
			validate => 'number',
		},
	],
},
{
	name => $settings_txt{'attachments'},
	id => 'attachments',
	items => [
		{
			header => $settings_txt{'attachments'},
		},
		{
			description => qq~$edit_paths_txt{'20'}<br />$settings_txt{'changeinpaths'}~,
			input_html => $uploaddir, # Non-changable setting
		},
		{
			description => $settings_txt{'uploaddircorrect'},
			input_html => $uploaddiriscorrect, # This is tested to see if it's valid at the top of the file.
		},
		{
			description => $fatxt{'17'},
			input_html => qq~<input type="text" name="allowattach" id="allowattach" size="5" value="$allowattach" /> ~,
			name => 'allowattach',
			validate => 'number',
		},
		{
			description => qq~<label for="allowguestattach">$fatxt{'18'}</label>~,
			input_html => qq~<input type="checkbox" name="allowguestattach" id="allowguestattach" value="1" ${ischecked($allowguestattach)}/>~,
			name => 'allowguestattach',
			validate => 'boolean',
			depends_on => ['allowattach!=0'],
		},
		{
			description => qq~<label for="amdisplaypics">$fatxt{'16'}</label>~,
			input_html => qq~<input type="checkbox" name="amdisplaypics" id="amdisplaypics" value="1" ${ischecked($amdisplaypics)}/>~,
			name => 'amdisplaypics',
			validate => 'boolean',
			depends_on => ['allowattach!=0'],
		},
		{
			description => qq~<label for="checkext">$fatxt{'15'}</label>~,
			input_html => qq~<input type="checkbox" name="checkext" id="checkext" value="1" ${ischecked($checkext)}/>~,
			name => 'checkext',
			validate => 'boolean',
			depends_on => ['allowattach!=0'],
		},
		{
			description => qq~<label for="extensions">$fatxt{'14'}</label>~,
			input_html => qq~<input type="text" name="extensions" id="extensions" size="35" value="~ . join(' ', @ext) . qq~" />~,
			name => 'extensions',
			validate => 'text',
			depends_on => ['allowattach!=0', 'checkext'],
		},
		{
			description => qq~<label for="limit">$fatxt{'12'}</label>~,
			input_html => qq~<input type="text" name="limit" id="limit" size="5" value="$limit" /> KB~,
			name => 'limit',
			validate => 'number',
			depends_on => ['allowattach!=0'],
		},
		{
			description => qq~<label for="dirlimit">$fatxt{'13'}</label>~,
			input_html => qq~<input type="text" name="dirlimit" id="dirlimit" size="5" value="$dirlimit" /> KB~,
			name => 'dirlimit',
			validate => 'number',
			depends_on => ['allowattach!=0'],
		},
		{
			description => qq~<label for="overwrite">$fatxt{'53'}</label>~,
			input_html => qq~
			<select name="overwrite" id="overwrite" size="1">
			<option value="0"${isselected($overwrite == 0)}>$fatxt{'54r'}</option>
			<option value="1"${isselected($overwrite == 1)}>$fatxt{'54o'}</option>
			<option value="2"${isselected($overwrite == 2)}>$fatxt{'54n'}</option>
			</select>~,
			name => 'overwrite',
			validate => 'number',
			depends_on => ['allowattach!=0'],
		},
	],
},
{
	name  => $settings_txt{'images'},
	id    => 'images',
	items => [
		{
			header => $admin_txt{'471'},
		},
		{
			description => qq~<label for="max_avatar_width">$admin_txt{'472'}</label>~,
			input_html => qq~<input type="text" name="max_avatar_width" id="max_avatar_width" size="5" value="$max_avatar_width" /> pixel~,
			name => 'max_avatar_width',
			validate => 'number',
		},
		{
			description => qq~<label for="max_avatar_height">$admin_txt{'473'}</label>~,
			input_html => qq~<input type="text" name="max_avatar_height" id="max_avatar_height" size="5" value="$max_avatar_height" /> pixel~,
			name => 'max_avatar_height',
			validate => 'number',
		},
		{
			description => qq~<label for="fix_avatar_img_size">$admin_txt{'473x'}</label>~,
			input_html => qq~<input type="checkbox" name="fix_avatar_img_size" id="fix_avatar_img_size" value="1"${ischecked($fix_avatar_img_size)} />~,
			name => 'fix_avatar_img_size',
			validate => 'boolean',
		},
		{
			description => qq~<label for="max_post_img_width">$admin_txt{'474'}</label>~,
			input_html => qq~<input type="text" name="max_post_img_width" id="max_post_img_width" size="5" value="$max_post_img_width" /> pixel~,
			name => 'max_post_img_width',
			validate => 'number',
		},
		{
			description => qq~<label for="max_post_img_height">$admin_txt{'475'}</label>~,
			input_html => qq~<input type="text" name="max_post_img_height" id="max_post_img_height" size="5" value="$max_post_img_height" /> pixel~,
			name => 'max_post_img_height',
			validate => 'number',
		},
		{
			description => qq~<label for="fix_post_img_size">$admin_txt{'475x'}</label>~,
			input_html => qq~<input type="checkbox" name="fix_post_img_size" id="fix_post_img_size" value="1"${ischecked($fix_post_img_size)} />~,
			name => 'fix_post_img_size',
			validate => 'boolean',
		},
		{
			description => qq~<label for="max_signat_img_width">$admin_txt{'476'}</label>~,
			input_html => qq~<input type="text" name="max_signat_img_width" id="max_signat_img_width" size="5" value="$max_signat_img_width" /> pixel~,
			name => 'max_signat_img_width',
			validate => 'number',
		},
		{
			description => qq~<label for="max_signat_img_height">$admin_txt{'477'}</label>~,
			input_html => qq~<input type="text" name="max_signat_img_height" id="max_signat_img_height" size="5" value="$max_signat_img_height" /> pixel~,
			name => 'max_signat_img_height',
			validate => 'number',
		},
		{
			description => qq~<label for="fix_signat_img_size">$admin_txt{'477x'}</label>~,
			input_html => qq~<input type="checkbox" name="fix_signat_img_size" id="fix_signat_img_size" value="1"${ischecked($fix_signat_img_size)} />~,
			name => 'fix_signat_img_size',
			validate => 'boolean',
		},
		{
			description => qq~<label for="max_attach_img_width">$admin_txt{'478'}</label>~,
			input_html => qq~<input type="text" name="max_attach_img_width" id="max_attach_img_width" size="5" value="$max_attach_img_width" /> pixel~,
			name => 'max_attach_img_width',
			validate => 'number',
		},
		{
			description => qq~<label for="max_attach_img_height">$admin_txt{'479'}</label>~,
			input_html => qq~<input type="text" name="max_attach_img_height" id="max_attach_img_height" size="5" value="$max_attach_img_height" /> pixel~,
			name => 'max_attach_img_height',
			validate => 'number',
		},
		{
			description => qq~<label for="fix_attach_img_size">$admin_txt{'479x'}</label>~,
			input_html => qq~<input type="checkbox" name="fix_attach_img_size" id="fix_attach_img_size" value="1"${ischecked($fix_attach_img_size)} />~,
			name => 'fix_attach_img_size',
			validate => 'boolean',
		},
		{
			description => qq~<label for="img_greybox">$admin_txt{'479a'}</label>~,
			input_html => qq~
				<select name="img_greybox" id="img_greybox">
					<option value="0"${isselected(!$img_greybox)}>$admin_txt{'479b'}</option>
					<option value="1"${isselected($img_greybox == 1)}>$admin_txt{'479c'}</option>
					<option value="2"${isselected($img_greybox == 2)}>$admin_txt{'479d'}</option>
				</select>~,
			name => 'img_greybox',
			validate => 'number',
		},
	]
},
{
	name  => $settings_txt{'advanced'},
	id    => 'advanced',
	items => [
		{
			header => $settop_txt{'5'},
		},
		{
			description => qq~<label for="gzcomp">$gztxt{'1'}</label>~,
			input_html => qq~
<select name="gzcomp" id="gzcomp" size="1">
  <option value="0" ${isselected($gzcomp == 0)}>$gztxt{'3'}</option>$compressgzip$compresszlib
</select>~,
			name => 'gzcomp',
			validate => 'number',
		},
		{
			description => qq~<label for="gzforce">$gztxt{'2'}</label>~,
			input_html => qq~<input type="checkbox" name="gzforce" id="gzforce" value="1" ${ischecked($gzforce)}/>~,
			name => 'gzforce',
			validate => 'boolean',
			depends_on => ['gzcomp!=0'],
		},
		{
			description => qq~<label for="cachebehaviour">$admin_txt{'802'}</label>~,
			input_html => qq~<input type="checkbox" name="cachebehaviour" id="cachebehaviour" value="1" ${ischecked($cachebehaviour)}/>~,
			name => 'cachebehaviour',
			validate => 'boolean',
		},
		{
			description => qq~<label for="enableclicklog">$admin_txt{'803'}</label>~,
			input_html => qq~<input type="checkbox" name="enableclicklog" id="enableclicklog" value="1" ${ischecked($enableclicklog)}/>~,
			name => 'enableclicklog',
			validate => 'boolean',
		},
		{
			description => qq~<label for="ClickLogTime">$admin_txt{'690'}</label>~,
			input_html => qq~<input type="text" name="ClickLogTime" id="ClickLogTime" size="5" value="$ClickLogTime" />~,
			name => 'ClickLogTime',
			validate => 'number',
			depends_on => ['enableclicklog'],
		},
		{
			description => qq~<label for="max_log_days_old">$admin_txt{'376'}</label>~,
			input_html => qq~<input type="text" name="max_log_days_old" id="max_log_days_old" size="5" value="$max_log_days_old" />~,
			name => 'max_log_days_old',
			validate => 'number',
		},
		{
			description => qq~<label for="maxrecentdisplay">$floodtxt{'5'}</label>~,
			input_html => qq~<input type="text" name="maxrecentdisplay" id="maxrecentdisplay" size="5" value="$maxrecentdisplay" />~,
			name => 'maxrecentdisplay',
			validate => 'fullnumber',
		},
		{
			description => qq~<label for="maxsearchdisplay">$floodtxt{'6'}</label>~,
			input_html => qq~<input type="text" name="maxsearchdisplay" id="maxsearchdisplay" size="5" value="$maxsearchdisplay" />~,
			name => 'maxsearchdisplay',
			validate => 'fullnumber',
		},
		{
			description => qq~<label for="OnlineLogTime">$amv_txt{'13'}</label>~,
			input_html => qq~<input type="text" name="OnlineLogTime" id="OnlineLogTime" size="5" value="$OnlineLogTime" />~,
			name => 'OnlineLogTime',
			validate => 'number',
		},
		{
			description => qq~<label for="lastonlineinlink">$amv_txt{'25'}</label>~,
			input_html => qq~<input type="checkbox" name="lastonlineinlink" id="lastonlineinlink" size="5" value="1" ${ischecked($lastonlineinlink)}/>~,
			name => 'lastonlineinlink',
			validate => 'boolean',
		},
		{
			header => $errorlog{'25'},
		},
		{
			description => qq~<label for="elenable">$errorlog{'22'}</label>~,
			input_html => qq~<input type="checkbox" name="elenable" id="elenable" value="1" ${ischecked($elenable)}/>~,
			name => 'elenable',
			validate => 'boolean',
		},
		{
			description => qq~<label for="elrotate">$errorlog{'23'}</label>~,
			input_html => qq~<input type="checkbox" name="elrotate" id="elrotate" value="1" ${ischecked($elrotate)}/>~,
			name => 'elrotate',
			validate => 'boolean',
			depends_on => ['elenable'],
		},
		{
			description => qq~<label for="elmax">$errorlog{'24'}</label>~,
			input_html => qq~<input type="text" name="elmax" id="elmax" size="5" value="$elmax" />~,
			name => 'elmax',
			validate => 'number',
			depends_on => ['elenable', 'elrotate'],
		},
		{
			header => $settings_txt{'debug'},
		},
		{
			description => qq~<label for="debug">$admin_txt{'999'}<br /><span class="small">$admin_txt{'999a'}</span></label>~,
			input_html => qq~
<select name="debug" id="debug" size="1">
  <option value="0" ${isselected($debug == 0)}>$admin_txt{'nodebug'}</option>
  <option value="1" ${isselected($debug == 1)}>$admin_txt{'alldebug'}</option>
  <option value="2" ${isselected($debug == 2)}>$admin_txt{'admindebug'}</option>
</select>~,
			name => 'debug',
			validate => 'number',
		},
		{
			header => $settings_txt{'files'},
		},
		{
			description => qq~<label for="use_flock">$admin_txt{'391'}</label>~,
			input_html => qq~
<select name="use_flock" id="use_flock" size="1">
  <option value="0" ${isselected($use_flock == 0)}>$admin_txt{'401'}</option>
  <option value="1" ${isselected($use_flock == 1)}>$admin_txt{'402'}</option>
  <option value="2" ${isselected($use_flock == 2)}>$admin_txt{'403'}</option>
  <option value="3" ${isselected($use_flock == 3)}>$admin_txt{'410'}</option>
</select>~,
			name => 'use_flock',
			validate => 'number',
		},
		{
			description => qq~<label for="faketruncation">$admin_txt{'630'}</label>~,
			input_html => qq~<input type="checkbox" name="faketruncation" id="faketruncation" value="1" ${ischecked($faketruncation)}/>~,
			name => 'faketruncation',
			validate => 'boolean',
		},
		{
			header => $settings_txt{'freedisk'},
		},
		{
			description => qq~<label for="enable_quota">$admin_txt{'quota'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_quota" id="enable_quota" value="1" ~ . (!$quota[2] ? 'disabled="disabled" ' : ${ischecked($enable_quota)}) . qq~/>~,
			name => 'enable_quota',
			validate => 'boolean',
			depends_on => (!$quota[2] ? [] : ['!enable_freespace_check','(findfile_time==0||','findfile_time==||','findfile_maxsize==0||','findfile_maxsize==)']),
		},
		{
			description => qq~<label for="enable_quota_value">$admin_txt{'quota_value'}</label>~,
			input_html => ($quota[2] ? $quota_select : qq~<input type="hidden" name="enable_quota_value" id="enable_quota_value" value="0" />~),
			name => 'enable_quota_value',
			validate => 'number,null',
			depends_on => ['enable_quota'],
		},
		{
			description => qq~<label for="hostusername">$admin_txt{'quotahostuser'}</label>~,
			input_html => qq~<input type="text" name="hostusername" id="hostusername" size="20" value="$hostusername" />~,
			name => 'hostusername',
			validate => 'text,null',
			depends_on => ['enable_quota'],
		},
		{
			description => qq~<label for="findfile_time">$admin_txt{'findtime'}</label>~,
			input_html => qq~<input type="text" name="findfile_time" id="findfile_time" size="4" value="~ . (@find ? qq~$findfile_time"~ : '0" disabled="disabled"') . qq~ /> $admin_txt{'537'}~,
			name => 'findfile_time',
			validate => 'number,null',
			depends_on => (@find ? ['!enable_quota','!enable_freespace_check'] : []),
		},
		{
			description => qq~<label for="findfile_root">$admin_txt{'findroot'}</label>~,
			input_html => qq~<input type="text" name="findfile_root" id="findfile_root" size="40" value="$findfile_root" ~ . (@find ? '' : 'disabled="disabled" ') . qq~/>~,
			name => 'findfile_root',
			validate => 'text,null',
			depends_on => (@find ? ['!enable_quota','!enable_freespace_check'] : []),
		},
		{
			description => qq~<label for="findfile_maxsize">$admin_txt{'findmax'}</label>~,
			input_html => qq~<input type="text" name="findfile_maxsize" id="findfile_maxsize" size="10" value="$findfile_maxsize" ~ . (@find ? '' : 'disabled="disabled" ') . qq~/> MB~,
			name => 'findfile_maxsize',
			validate => 'number,null',
			depends_on => (@find ? ['!enable_quota','!enable_freespace_check'] : []),
		},
		{
			description => qq~<label for="enable_freespace_check">$admin_txt{'diskspacecheck'}</label>~,
			input_html => qq~<input type="checkbox" name="enable_freespace_check" id="enable_freespace_check" value="1" ${ischecked($enable_freespace_check)}/><pre>@disk_space</pre>~,
			name => 'enable_freespace_check',
			validate => 'boolean',
			depends_on => ['!enable_quota','(findfile_time==0||','findfile_time==||','findfile_maxsize==0||','findfile_maxsize==)'],
		},
	],
},
);

# Routine to save them
sub SaveSettings {
	my %settings = @_;
	$settings{'extensions'} =~ s~[^\ A-Za-z0-9_]~~g;
	@ext = split(/\s+/, $settings{'extensions'});

	if ($settings{'enable_quota'} && $settings{'enable_quota_value'} > 1 && $settings{'hostusername'}) {
		$settings{'enable_quota'} = $settings{'enable_quota_value'};
		$settings{'findfile_maxsize'} = 0;
		$settings{'enable_freespace_check'} = 0;
	} elsif (-d "$settings{'findfile_root'}" && $settings{'findfile_maxsize'} > 0 && !$settings{'enable_freespace_check'}) {
		$findfile_space = '1<>0';
		$settings{'enable_quota'} = 0;
	} elsif ($settings{'enable_freespace_check'}) {
		$settings{'findfile_maxsize'} = 0;
		$settings{'enable_quota'} = 0;
	} elsif (!-d "$settings{'findfile_root'}" || !$settings{'findfile_maxsize'}) {
		$settings{'findfile_time'} = 0;
		$settings{'findfile_maxsize'} = 0;
	}

	# Settings.pl stuff
	&SaveSettingsTo('Settings.pl', %settings);
}

1;