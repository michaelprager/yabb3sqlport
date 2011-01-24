###############################################################################
# Settings_News.pl                                                            #
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

$settings_newsplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

# Load the news from news.txt
my $yabbnews = join('', &read_DBorFILE(0,'',$vardir,'news','txt'));
# ToHTML, in case they have some crazy HTML in it like </textarea>
&ToHTML($yabbnews);
&ToChars($yabbnews);

# List of settings
@settings = (
# Begin tab
{
	name  => $settings_txt{'news'}, # Tab name
	id    => 'settings', # Javascript ID
	items => [
		{
			header => $settings_txt{'news'}, # Section header
		},
		{
			description => qq~<label for="enable_news">$admin_txt{'379'}</label>~, # Description of item (displayed on left)
			input_html => qq~<input type="checkbox" name="enable_news" id="enable_news" value="1" ${ischecked($enable_news)}/>~, # HTML for item
			name => 'enable_news', # Variable/FORM name
			validate => 'boolean', # Regex(es) to validate against
		},
		{
			header => $settings_txt{'newsfader'},
		},
		{
			description => qq~<label for="shownewsfader">$admin_txt{'387'}</label>~,
			input_html => qq~<input type="checkbox" name="shownewsfader" id="shownewsfader" value="1" ${ischecked($shownewsfader)}/>~,
			name => 'shownewsfader',
			validate => 'boolean',
			depends_on => ['enable_news'],
		},
		{
			description => qq~<label for="maxsteps">$admintxt{'41'}</label>~,
			input_html => qq~<input type="text" name="maxsteps" id="maxsteps" size="3" value="$maxsteps" />~,
			name => 'maxsteps',
			validate => 'number',
			depends_on => ['enable_news', 'shownewsfader'],
		},
		{
			description => qq~<label for="stepdelay">$admintxt{'42'}</label>~,
			input_html => qq~<input type="text" name="stepdelay" id="stepdelay" size="3" value="$stepdelay" /> $admintxt{'ms'}~,
			name => 'stepdelay',
			validate => 'number',
			depends_on => ['enable_news', 'shownewsfader'],
		},
		{
			description => qq~<label for="fadelinks">$admintxt{'40'}</label>~,
			input_html => qq~<input type="checkbox" name="fadelinks" id="fadelinks" value="1" ${ischecked($fadelinks)}/>~,
			name => 'fadelinks',
			validate => 'boolean',
			depends_on => ['enable_news', 'shownewsfader'],
		},
	],
},
{
	name  => $admin_txt{'7'},
	id    => 'editnews',
	items => [
		{
			header => $admin_txt{'7'},
		},
		{
			two_rows => 1, # Use to rows to display this item
			description => qq~<label for="news">$admin_txt{'670'}</label>~,
			input_html => qq~<textarea cols="80" rows="35" name="news" id="news" style="width: 99%">$yabbnews</textarea>~,
			name => 'news',
			validate => 'null,fulltext',
			depends_on => ['enable_news'],
		},
	],
});

# Routine to save them
sub SaveSettings {
	my %settings = @_;

	$settings{'news'} =~ tr/\r//d;
	chomp $settings{'news'};
	&FromChars($settings{'news'});
	# news.txt stuff
	&write_DBorFILE(0,'',$vardir,'news','txt',($settings{'news'}));
	delete $settings{'news'}; # Remove it from the hash

	# Settings.pl stuff
	&SaveSettingsTo('Settings.pl', %settings);
}

1;