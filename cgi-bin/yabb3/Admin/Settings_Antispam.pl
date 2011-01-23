###############################################################################
# Settings_Antispam.pl                                                        #
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

$settings_antispamplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

# TSC
$spamlist = join('', &read_DBorFILE(1,'',$vardir,'spamrules','txt'));

# Email Domain Filter
if (-e "$vardir/email_domain_filter.txt") {
	require "$vardir/email_domain_filter.txt";
}
$adomains =~ s~,~\n~g;
$bdomains =~ s~,~\n~g;

# List of settings
@settings = (
{
	name  => $settings_txt{'generalspam'},
	id    => 'spam',
	items => [
		{
			description => qq~<label for="post_speed_count">$admin_txt{'91'}<br /><span class="small">$admin_txt{'91a'}</span></label>~,
			input_html => qq~<input type="text" name="post_speed_count" id="post_speed_count" size="5" value="$post_speed_count" />~,
			name => 'post_speed_count',
			validate => 'number',
		},
		{
			description => qq~<label for="minlinkpost">$admin_txt{'minlinkpost'}<br /><span class="small">$admin_txt{'minlinkpost_exp'}</span></label>~,
			input_html => qq~<input type="text" name="minlinkpost" id="minlinkpost" size="5" value="$minlinkpost" />~,
			name => 'minlinkpost',
			validate => 'number',
		},
		{
			description => qq~<label for="minlinksig">$admin_txt{'minlinksig'}<br /><span class="small">$admin_txt{'minlinksig_exp'}</span></label>~,
			input_html => qq~<input type="text" name="minlinksig" id="minlinksig" size="5" value="$minlinksig" />~,
			name => 'minlinksig',
			validate => 'number',
		},
		{
			description => qq~<label for="spd_detention_time">$admin_txt{'92'}<br /><span class="small">$admin_txt{'93'}</span></label>~,
			input_html => qq~<input type="text" name="spd_detention_time" id="spd_detention_time" size="5" value="$spd_detention_time" />~,
			name => 'spd_detention_time',
			validate => 'number',
		},
		{
			description => qq~<label for="timeout">$admin_txt{'408'}</label>~,
			input_html => qq~<input type="text" name="timeout" id="timeout" size="4" value="$timeout" />~,
			name => 'timeout',
			validate => 'number',
		},
		{
			header => $settings_txt{'speedban'},
		},
		{
			description => qq~<label for="speedpostdetection">$admin_txt{'89'}</label>~,
			input_html => qq~<input type="checkbox" name="speedpostdetection" id="speedpostdetection" value="1" ${ischecked($speedpostdetection)}/>~,
			name => 'speedpostdetection',
			validate => 'boolean',
		},
		{
			description => qq~<label for="min_post_speed">$admin_txt{'90'}</label>~,
			input_html => qq~<input type="text" name="min_post_speed" id="min_post_speed" size="5" value="$min_post_speed" />~,
			name => 'min_post_speed',
			validate => 'number',
			depends_on => ['speedpostdetection'],
		},
	],
},
{
	name  => $tsc_txt{'2'},
	id    => 'tsc',
	items => [
		{
			description => qq~<label for="spamrules"><b>$tsc_txt{'4'}</b><br /><span class="small">$tsc_txt{'3'}</span></label>~,
			input_html => qq~<textarea cols="60" rows="35" name="spamrules" id="spamrules" style="width: 95%">$spamlist</textarea>~,
			two_rows => 1,
			name => 'spamrules',
			validate => 'fulltext,null',
		},
	],
},
{
	name  => $domain_filter_txt{'2'},
	id    => 'emailfilter',
	items => [
		{
			description => qq~<label for="adomains"><b>$domain_filter_txt{'4'}</b><br /><span class="small">$domain_filter_txt{'3'}</span></label>~,
			input_html => qq~<textarea cols="60" rows="35" name="adomains" id="adomains" style="width: 95%">$adomains</textarea>~,
			two_rows => 1,
			name => 'adomains',
			validate => 'fulltext,null',
		},
		{
			description => qq~<label for="bdomains"><b>$domain_filter_txt{'6'}</b><br /><span class="small">$domain_filter_txt{'7'}</span></label>~,
			input_html => qq~<textarea cols="60" rows="35" name="bdomains" id="bdomains" style="width: 95%">$bdomains</textarea>~,
			two_rows => 1,
			name => 'bdomains',
			validate => 'fulltext,null',
		},
	],
},
);

# Routine to save them
sub SaveSettings {
	my %settings = @_;

	# TSC
	$settings{'spamrules'} =~ s/\r(?=\n*)//g;
	&write_DBorFILE(0,'',$vardir,'spamrules','txt',(delete($settings{'spamrules'})));

	# email domain filter
	my @domains = (delete $settings{'adomains'}, delete $settings{'bdomains'});
	foreach (@domains){
		s~\n~,~g;
		s~\s+~~g;
		s~(^,+|,+$)~~g;
		s~,+~,~g;
		s~\@~\\@~g;
	}
	&write_DBorFILE(0,'',$vardir,'email_domain_filter','txt',(qq~\$adomains = "$domains[0]";\n~,qq~\$bdomains = "$domains[1]";\n~,qq~1;~));

	# Settings.pl
	&SaveSettingsTo('Settings.pl', %settings);
}

1;