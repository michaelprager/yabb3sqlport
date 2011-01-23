###############################################################################
# Settings_Maintenance.pl                                                     #
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

$settings_maintenanceplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

# List of settings
@settings = (
# Begin tab
{
	name  => $admin_txt{'67'}, # Tab name
	id    => 'settings', # Javascript ID
	items => [
		{
			description => qq~<label for="maintenance">$admin_txt{'348'}</label>~,
			input_html => qq~<input type="checkbox" name="maintenance" id="maintenance" value="1" ${ischecked($maintenance)}/>~,
			name => 'maintenance',
			validate => 'boolean',
		},
		{
			description => qq~<label for="maintenancetext">$admin_txt{'348Text'}</label>~,
			input_html => qq~<textarea cols="30" rows="5" name="maintenancetext" id="maintenancetext" style="width: 98%">$maintenancetext</textarea>~,
			name => 'maintenancetext',
			validate => 'fulltext,null',
		},
	],
});

# Routine to save them
sub SaveSettings {
	my %settings = @_;

	&delete_DBorFILE("$vardir/maintenance.lock") if $settings{'maintenance'} != 1;

	SaveSettingsTo('Settings.pl', %settings);
}

1;