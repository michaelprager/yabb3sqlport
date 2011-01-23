###############################################################################
# ExtendedProfiles.pl                                                         #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Version:        YaBB 3.0 Beta                                               #
# Packaged:       October 05, 2010                                            #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2010 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################

$extendedprofilesplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

###############################################################################
# This file was part of the Extended Profiles Mod which has been created by   #
# Michael Prager. Last modification by him: 15.11.07                          #
# Added to the YaBB default code on 07. September 2008                        #
###############################################################################
# file formats used by this code:
#
#  username.vars - contains the additional user profile information. Number is field-id
#  -------------
#  ...
#  'ext_0',"value"
#  'ext_1',"value"
#  'ext_2',"value"
#  ...
#
#  @ext_prof_order - contains the order in which the fields will be displayed
#  ---------------------------
#  ("name","name","name",....)
#
#  extended_profiles_fields.txt - defines the new profile fields. Uses line number as field-id
#  ----------------------------
#  ("name|type|options|active|comment|required_on_reg|visible_in_viewprofile|v_users|v_groups|visible_in_posts|p_users|p_groups|p_displayfieldname|visible_in_memberlist|m_users|m_groups|editable_by_user|visible_in_posts_popup|pp_users|pp_groups|pp_displayfieldname","name|type|options|active|comment|required_on_reg|visible_in_viewprofile|v_users|v_groups|visible_in_posts|p_users|p_groups|p_displayfieldname|visible_in_memberlist|m_users|m_groups|editable_by_user|visible_in_posts_popup|pp_users|pp_groups|pp_displayfieldname","name|type|options|active|comment|required_on_reg|visible_in_viewprofile|v_users|v_groups|visible_in_posts|p_users|p_groups|p_displayfieldname|visible_in_memberlist|m_users|m_groups|editable_by_user|visible_in_posts_popup|pp_users|pp_groups|pp_displayfieldname|radiounselect",....)
#
#  Here are all types with their possible type-specific options. If options contain multiple entries, seperated by ^
#  - text		limit_len^width^is_numberic^default_value^allow_ubbc
#  - text_multi		limit_len^rows^cols^allow_ubbc
#  - select		option1^option2^option3... (first option is default)
#  - radiobuttons	option1^option2^option3... (first option is default)
#  - spacer		br_or_hr^visible_in_editprofile
#  - checkbox		-
#  - date		-
#  - emial		-
#  - url		-
#  - image		width^height^allowed_extensions
#
#  required_on_reg can have value 0 (disabled), 1 (required on registration) and 2 (not req. but display on reg. page anyway)
#  editable_by_user can have value 0 (will only show on the "admin edits" page), 1 ("edit profile" page), 2 ("contact information" page), 3 ("Options" page) and 4 ("PM Preferences" page)
#  allowed_extensions is a space-seperated list of file extensions, example: "jpg jpeg gif bmp png"
#  v_groups, p_groups, m_groups, pp_groups format: "Administrator" or "Moderator" or "Global Moderator" or NoPost{...} or Post{...}
#
# NOTE: use prefix "ext_" in sub-, variable- and formnames to prevent conflicts with other mods
#
# easy mod integration: use &ext_get($username,"fieldname") go get user's field value
#
###############################################################################

&LoadLanguage("ExtendedProfiles");

$ext_spacer_hr = qq~<hr size="1" width="100%" class="hr" />~;
$ext_spacer_br = qq~<br />~;
$ext_max_email_length = 60;
$ext_max_url_length = 100;
$ext_max_image_length = 100;

my %field;

# outputs the value of a user's extended profile field
## USAGE: $value = ext_get("admin","my_custom_fieldname");
##  or    $value_raw = ext_get("admin","my_custom_fieldname",1);
## pass the third argument if you want to get the raw content e.g. an unformated date
sub ext_get {
	my ($pusername, $fieldname, $no_parse, @ext_profile, @options, $id, $value, $width, $height, @allowed_extensions, $extension, $match) = (shift, shift, shift);
	&ext_get_profile($pusername);
	$id = &ext_get_field_id($fieldname);
	$value = ${$uid.$pusername}{'ext_'.$id};
	if ($no_parse eq "" || $no_parse == 0) {
		&ext_get_field($id);
		if ($field{'type'} eq "text") {
			@options = split(/\^/,$field{'options'});
			if ($options[3] ne "" && $value eq "") { $value = $options[3]; }
			if ($options[4] == 1) { $value = &ext_parse_ubbc($value, $pusername); }

		} elsif ($field{'type'} eq "text_multi" && $value ne "") {
			@options = split(/\^/,$field{'options'});
			if ($options[3] == 1) { $value = &ext_parse_ubbc($value, $pusername); }

		} elsif ($field{'type'} eq "select") {
			@options = split(/\^/,$field{'options'});
			if ($value > $#options || $value eq "") { $value = 0; }
			$value = $options[$value];

		} elsif ($field{'type'} eq "radiobuttons") {
			@options = split(/\^/,$field{'options'});
			if ($value > $#options) { $value = 0; }
			if(!$field{'radiounselect'} && $value eq "") { $value = 0; }
			if($value ne "") { $value = $options[$value]; }

		} elsif ($field{'type'} eq "date" && $value ne "") {
			$value = &ext_timeformat($value);

		} elsif ($field{'type'} eq "checkbox") {
			if ($value == 1) { $value = $lang_ext{'true'} }
			else { $value = $lang_ext{'false'} }

		} elsif ($field{'type'} eq "spacer") {
			@options = split(/\^/,$field{'options'});
			if ($options[0] == 1) { $value = qq~$ext_spacer_br~; }
			else { $value = qq~$ext_spacer_hr~; }

		} elsif ($field{'type'} eq "url" && $value ne "") {
			if ($value !~ m~\Ahttp://~) { $value = "http://$value"; }

		} elsif ($field{'type'} eq "image" && $value ne "") {
			@options = split(/\^/,$field{'options'});
			if ($options[2] ne "") {
				@allowed_extensions = split(/ /,$options[2]);
				$match = 0;
				foreach $extension (@allowed_extensions){
					if (grep /$extension$/i,$value) { $match = 1; last; }
				}
				if ($match == 0) { return ""; }
			}
			if ($options[0] ne "" && $options[0] != 0) { $width = " width=\"".($options[0]+0)."\""; } else { $width = ""; }
			if ($options[1] ne "" && $options[1] != 0) { $height = " height=\"".($options[1]+0)."\""; } else { $height = ""; }
			if ($value !~ m~\Ahttp://~) { $value = "http://$value"; }
			$value = qq~<img src="$value" align="top"$width$height alt="" />~;
		}
	}

	$value;
}

# loads the (extended) profile of a user
sub ext_get_profile {
	&LoadUser(shift);
}

# returns an array of the form qw(ext_0 ext_1 ext_2 ...)
sub ext_get_fields_array {
	my ($count, @result) = (0);
	foreach (@ext_prof_fields) {
		push(@result, "ext_$count");
		$count++;
	}
	@result;
}

# returns the id of a field through the fieldname
sub ext_get_field_id {
	my ($fieldname, $count, $id, $current, $currentname, $dummy) = (shift, 0);
	foreach $current (@ext_prof_fields) {
		($currentname, $dummy) = split(/\|/, $current);
		if ($currentname eq $fieldname) { $id = $count; last; }
		$count++;
	}
	$id;
}

# returns all settings of a specifig field
sub ext_get_field {
	$field{'id'} = shift;

	($field{'name'},
	 $field{'type'},
	 $field{'options'},
	 $field{'active'},
	 $field{'comment'},
	 $field{'required_on_reg'},
	 $field{'visible_in_viewprofile'},
	 $field{'v_users'},
	 $field{'v_groups'},
	 $field{'visible_in_posts'},
	 $field{'p_users'},
	 $field{'p_groups'},
	 $field{'p_displayfieldname'},
	 $field{'visible_in_memberlist'},
	 $field{'m_users'},
	 $field{'m_groups'},
	 $field{'editable_by_user'},
	 $field{'visible_in_posts_popup'},
	 $field{'pp_users'},
	 $field{'pp_groups'},
	 $field{'pp_displayfieldname'},
	 $field{'radiounselect'},
	 undef) = split(/\|/, $ext_prof_fields[$field{'id'}]);
}

# formats a MM/DD/YYYY string to the user's prefered format, ignores time completely!
sub ext_timeformat {
	my ($mytimeselected,$oldformat,$newformat,$mytimeformat,$newday,$newday2,$newmonth,$newmonth2,$newyear,$newshortyear,$oldmonth,$oldday,$oldyear,$newweekday,$newyearday,$newweek,$dummy,$usefullmonth);

	if (${$uid.$username}{'timeselect'} > 0) { $mytimeselected = ${$uid.$username}{'timeselect'}; } else { $mytimeselected = $timeselected; }

	$oldformat = shift;
	if ($oldformat eq '' || $oldformat eq "\n") { return $oldformat; }

	$oldmonth = substr($oldformat,0,2);
	$oldday = substr($oldformat,3,2);
	$oldyear = substr($oldformat,6,4);

	if ($oldformat ne '') {
		$newday = $oldday+0;
		$newmonth = $oldmonth+0;
		$newyear = $oldyear+0;
		$newshortyear = substr($newyear,2,2);
		if ($newmonth < 10) { $newmonth = "0$newmonth"; }
		if ($newday < 10 && $mytimeselected != 4) { $newday = "0$newday"; }

		if ($mytimeselected == 1) {
			qq~$newmonth/$newday/$newshortyear~;

		} elsif ($mytimeselected == 2) {
			qq~$newday.$newmonth.$newshortyear~;

		} elsif ($mytimeselected == 3) {
			qq~$newday.$newmonth.$newyear~;

		} elsif ($mytimeselected == 4) {
			$newmonth2 = $months[$newmonth - 1];
			if( $newday > 10 && $newday < 20 ) { $newday2 = "<sup>$timetxt{'4'}</sup>"; }
			elsif( $newday % 10 == 1 ) { $newday2 = "<sup>$timetxt{'1'}</sup>"; }
			elsif( $newday % 10 == 2 ) { $newday2 = "<sup>$timetxt{'2'}</sup>"; }
			elsif( $newday % 10 == 3 ) { $newday2 = "<sup>$timetxt{'3'}</sup>"; }
			else{ $newday2 = "<sup>$timetxt{'4'}</sup>"; }
			qq~$newmonth2 $newday$newday2, $newyear~;

		} elsif ($mytimeselected == 5) {
			qq~$newmonth/$newday/$newshortyear~;

		} elsif ($mytimeselected == 6) {
			$newmonth2 = $months[$newmonth - 1];
			qq~$newday. $newmonth2 $newyear~;

		} elsif ($mytimeselected == 7) {
			($dummy,$dummy,$dummy,$dummy,$dummy,$dummy,$newweekday,$newyearday,$dummy) = gmtime($oldformat);
			$newweek = int(( $newyearday + 1 - $newweekday ) / 7 )+1;

			$mytimeformat = ${$uid.$username}{'timeformat'};
			if ($mytimeformat =~ m/MM/) {$usefullmonth = 1;}
			$mytimeformat =~ s/(?:\s)*\@(?:\s)*//g;
			$mytimeformat =~ s/HH(?:\s)?//g;
			$mytimeformat =~ s/mm(?:\s)?//g;
			$mytimeformat =~ s/ss(?:\s)?//g;
			$mytimeformat =~ s/://g;
			$mytimeformat =~ s/ww(?:\s)?//g;
			$mytimeformat =~ s/(.*?)(?:\s)*$/$1/g;

			if ($mytimeformat =~ m/\+/) {
				if( $newday > 10 && $newday < 20 ) { $dayext = "<sup>$timetxt{'4'}</sup>"; } 
				elsif( $newday % 10 == 1 ) { $dayext = "<sup>$timetxt{'1'}</sup>"; }
				elsif( $newday % 10 == 2 ) { $dayext = "<sup>$timetxt{'2'}</sup>"; }
				elsif( $newday % 10 == 3 ) { $dayext = "<sup>$timetxt{'3'}</sup>"; }
				else { $dayext = "<sup>$timetxt{'4'}</sup>"; }
			}
			$mytimeformat =~ s/YYYY/$newyear/g;
			$mytimeformat =~ s/YY/$newshortyear/g;
			$mytimeformat =~ s/DD/$newday/g;
			$mytimeformat =~ s/D/$newday/g;
			$mytimeformat =~ s/\+/$dayext/g;
			if ($usefullmonth == 1){
				$mytimeformat =~ s/MM/$months[$newmonth - 1]/g;
			} else {
				$mytimeformat =~ s/M/$newmonth/g;
			}

			$mytimeformat =~ s/\*//g;
			$mytimeformat;
		}
	} else { ''; }
}

# returns whenever the current user is allowed to view a field or not
sub ext_has_access {
	my ($allowed_users, $allowed_groups, $usergroup, $useraddgroup, $postcount, $groupid) = (shift, shift, 0, ${$uid.$username}{'position'}, ${$uid.$username}{'addgroups'}, ${$uid.$username}{'postcount'}, undef);

	if ($allowed_users ne "" || $allowed_groups ne "") {
		foreach (split(/,/, $allowed_users)) { return 1 if $_ eq $username; }

		# example list of allowed groups:
		# ('Administrator', 'Moderator', 'Global Moderator', 'Post{-1}', 'NoPost{1}')
		foreach my $group (split(/\s*,\s*/, $allowed_groups)) {
			# check if user is in one of these groups
			if ($group eq "Administrator" || $group eq "Moderator" || $group eq "Global Moderator") {
				if ($usergroup eq $group) { return 1; }

			# check if user is on a post-independend group
			} elsif ($group =~ m~^NoPost{(\d+)}$~) {
				$groupid = $1;
				# check if group exists at all
				if ($groupid ne "" && exists $NoPost{$groupid}) {
					# check if group id is in user position or addgroup field
					if ($usergroup eq $groupid) { return 1; }
					foreach (split(/,/,$useraddgroup)) {
						if ($_ eq $groupid) { return 1; }
					}
				}

			# check if user is in one of the post-depending groups...
			} elsif ($group =~ m~^Post{(\d+)}$~) {
				$groupid = $1;
				foreach (sort { $b <=> $a } keys %Post) {
					if ($postcount > $_) {
						# found the group the user is in
						if ($_ eq $groupid) { return 1; }
					}
				}
			}
		}
		return 0;
	}
	return 1;
}

# applies UBBC code to a string
sub ext_parse_ubbc {
	my ($source, $temp);
	($source, $displayname, $temp) = ($_[0], $_[1], $message);
	$message = $source;
	require "$sourcedir/YaBBC.pl";
	&DoUBBC;
	&ToChars($message);
	$source = $message;
	$message = $temp;
	$source;
}

# returns the output for the viewprofile page
sub ext_viewprofile {
	my ($pusername, @ext_profile, $id, $output, $fieldname, @options, $value, $previous, $count, $last_field_id, $pre_output) = (shift);

	if ($#ext_prof_order > 0) { $last_field_id = &ext_get_field_id($ext_prof_order[$#ext_prof_order]); }

	foreach $fieldname (@ext_prof_order) {
		$id = &ext_get_field_id($fieldname);
		&ext_get_field($id);
		$value = &ext_get($pusername,$fieldname);

		# make sure the field is visible and the user allowed to view the current field
		if ($field{'visible_in_viewprofile'} == 1 && $field{'active'} == 1 && &ext_has_access($field{'v_users'},$field{'v_groups'})) {
			if ($output eq "" && $previous ne 1) {
				$pre_output = qq~
	<tr>
		<td class="windowbg2" align="left" valign="top">~;
				$previous = 1;
			}
			# format the output dependend of the field type
			if (($field{'type'} eq "text" && $value ne "") ||
			    ($field{'type'} eq "text_multi" && $value ne "") ||
			    ($field{'type'} eq "select" && $value ne " ") ||
			    ($field{'type'} eq "radiobuttons" && $value ne "") ||
			    ($field{'type'} eq "date" && $value ne "") ||
			    $field{'type'} eq "checkbox") {
				$output .= qq~
			<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
			<b>$field{'name'}:</b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
			$value&nbsp;
			</div>~;
				$previous = 0;

			} elsif ($field{'type'} eq "spacer") {
				# only print spacer if the previous entry was no spacer of the same type and if this is not the last entry
				if (($previous eq 0 || $field{'comment'} ne "") && $id ne $last_field_id) {
					if ($value eq $ext_spacer_br) {
						$output .= qq~
			<div style="float: left; width: 100%; padding-top: 5px;  padding-bottom: 5px;">
			$ext_spacer_br
			</div>~;
						$previous = 0;
					} else {
						$output .= qq~
		</td>
	</tr>
	<tr>~;
						if ($field{'comment'} ne "") {
							$output .= qq~
		<td class="catbg" align="left">
			<img src="$imagesdir/profile.gif" alt="" border="0" style="vertical-align: middle;" />&nbsp; 
			<span class="text1"><b>$field{'comment'}</b></span>
		</td>
	</tr>
	<tr>
		<td class="windowbg2" align="left" valign="top">~;
						} else {
							$output .= qq~
		<td class="windowbg2" align="left" valign="top">~;
						}
						$previous = 1;
					}
				}

			} elsif ($field{'type'} eq "email" && $value ne "") {
				$output .= qq~
			<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
			<b>$field{'name'}:</b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
			~ . &enc_eMail($img_txt{'69'},$value,'','') . qq~
			</div>~;
				$previous = 0;

			} elsif ($field{'type'} eq "url" && $value ne "") {
				$output .= qq~
			<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
			<b>$field{'name'}:</b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
			<a href="$value" target="_blank">$value</a>
			</div>~;
				$previous = 0;

			} elsif ($field{'type'} eq "image" && $value ne "") {
				$output .= qq~
			<div style="float: left; width: 30%; padding-top: 5px;  padding-bottom: 5px;">
			<b>$field{'name'}:</b>
			</div>
			<div style="float: left; width: 70%; padding-top: 5px;  padding-bottom: 5px;">
			$value
			</div>~;
				$previous = 0;
			}
		}
	}
	# only add spacer if there there is at least one field displayed
	if ($output ne "") {
		$output = $pre_output . $output . qq~
		</td>
	</tr>~;
	}
	$output;
}

# returns the output for the post page
sub ext_viewinposts {
	my ($pusername, $popup, @ext_profile, $id, $output, $fieldname, @options, $value, $previous, $pre_output, $visible, $users, $groups, $displayfieldname) = (shift, shift);

	if ($pusername ne 'Guest') {
		foreach $fieldname (@ext_prof_order) {
			$id = &ext_get_field_id($fieldname);
			&ext_get_field($id);
			$value = &ext_get($pusername,$fieldname);

			if ($popup ne "") {
				$visible = $field{'visible_in_posts_popup'};
				$users = $field{'pp_users'};
				$groups = $field{'pp_groups'};
				$displayfieldname = $field{'pp_displayfieldname'};
			} else {
				$visible = $field{'visible_in_posts'};
				$users = $field{'p_users'};
				$groups = $field{'p_groups'};
				$displayfieldname = $field{'p_displayfieldname'};
			}

			# make sure the field is visible and the user allowed to view the current field
			if ($visible == 1 && $field{'active'} == 1 && &ext_has_access($users,$groups)) {
				if ($displayfieldname == 1) { $displayedfieldname = "$field{'name'}: "; } else { $displayedfieldname = ""; }
				if ($output eq "") { $output = qq~$ext_spacer_br\n~; }
				# format the output dependend of the field type
				if (($field{'type'} eq "text" && $value ne "") ||
				    ($field{'type'} eq "text_multi" && $value ne "") ||
				    ($field{'type'} eq "select" && $value ne " ") ||
				    ($field{'type'} eq "radiobuttons" && $value ne "") ||
				    ($field{'type'} eq "date" && $value ne "") ||
				    $field{'type'} eq "checkbox") {
					$output .= qq~$displayedfieldname$value<br />\n~;
					$previous = "";
				} elsif ($field{'type'} eq "spacer") {
					# those tags are required to keep the doc XHTML 1.0 valid
					if ($previous ne "</small>$value<small>") {
						$previous = qq~</small>$value<small>~;
						$output .= $previous;
					}
				} elsif ($field{'type'} eq "email" && $value ne "") {
					$output .= $displayedfieldname . &enc_eMail($img_txt{'69'},$value,'','') . qq~<br />\n~;
					$previous = "";
				} elsif ($field{'type'} eq "url" && $value ne "") {
					$output .= qq~$displayedfieldname<a href="$value" target="_blank">$value</a><br />\n~;
					$previous = "";
				} elsif ($field{'type'} eq "image" && $value ne "") {
					$output .= qq~$displayedfieldname$value<br />\n~;
					$previous = "";
				}
			}
		}
	}
	# check if there we have any output (except spacers) at all. If so, return empty output
	$pre_output = $output;
	$pre_output =~ s~(?:\</small>(?:(?:$ext_spacer_hr)|(?:$ext_spacer_br))<small>)|\n|(?:\<br(?: /)?>)~~ig;
	if ($pre_output eq "") { $output = ""; }

	$output;
}

{
	# we need a "static" variable to produce unique element ids
	my $ext_usercount = 0;
	# returns the output for the post page (popup box)
	sub ext_viewinposts_popup {
		my ($pusername,$link,$output) = (shift,shift);
		$output = &ext_viewinposts($pusername, "popup");
		$output =~ s~^$ext_spacer_br\n~~ig;
		if ($output ne "") {
			$link =~ s~<a ~<a onmouseover="document.getElementById('ext_$ext_usercount').style.visibility = 'visible'" onmouseout="document.getElementById('ext_$ext_usercount').style.visibility = 'hidden'" ~ig;
			$output = qq~$link<div id="ext_$ext_usercount" class="code" style="visibility:hidden; position:absolute; z-index:1; width:auto;">$output</div>~;
			$ext_usercount++;
		} else {
			$output = $link;
		}

		$output;
	}
}

# returns the output for the table header in memberlist
sub ext_memberlist_tableheader {
	my ($output, $fieldname);

	foreach $fieldname (@ext_prof_order) {
		&ext_get_field(&ext_get_field_id($fieldname));

		# make sure the field is visible and the user allowed to view the current field
		if ($field{'visible_in_memberlist'} == 1 && $field{'active'} == 1 && &ext_has_access($field{'m_users'},$field{'m_groups'})) {
			$output .= qq~<td class="catbg" align="center">$field{'name'}</td>\n~;
		}
	}

	$output;
}

# returns the number of additional fields showed in memberlist
sub ext_memberlist_get_headercount { # count the linebreaks to get the number of additional <td>s for the memberlist table
	my ($headers,$headercount) = (shift, 0);
	$headers =~ s~(\n)~ $headercount++ ~eg;
	$headercount;
}

# returns the output for the table tds in memberlist
sub ext_memberlist_tds {
	my ($pusername, $usergroup, @ext_profile, $id, $output, $access, @users, $user, @groups, $group, $fieldname, @options, $count, $color, $value) = (shift, ${$uid.$username}{'position'});

	$count = 0;
	foreach $fieldname (@ext_prof_order) {
		$id = &ext_get_field_id($fieldname);
		&ext_get_field($id);
		$value = &ext_get($pusername,$fieldname);

		# make sure the field is visible and the user allowed to view the current field
		if ($field{'visible_in_memberlist'} == 1 && $field{'active'} == 1 && &ext_has_access($field{'m_users'},$field{'m_groups'})) {
			$color = $count % 2 == 1 ? "windowbg" : "windowbg2";
			#if ($using_yams5 eq "1") {
			#	$td_attributs = qq~class="windowbg2" style="border-top: #6394BD 1px solid; border-right: #6394BD 1px solid; padding: 2px" bgcolor="#F8F8F8" align="center" valign="middle"~;
			#} else {
				$td_attributs = qq~class="$color"~;
			#}
			if ($field{'type'} eq "email") {
				if ($value ne "") { $value = &enc_eMail($img_txt{'69'},$value,'',''); }
			} elsif ($field{'type'} eq "url") {
				if ($value ne "") { $value = qq~<a href="$value" target="_blank">$value</a>~; }
			}
			if ($value eq "") { $value .= "&nbsp;"; }
			$output .= qq~<td $td_attributs>$value</td>\n~;
			$count++;
		}
	}

	$output;
}

# returns the edit mask of a field (used on registration and edit profile page)
sub ext_gen_editfield {
	my ($id, $pusername, @ext_profile, $output, @options, $selected, $count, $required_prefix, $dayormonth, $dayormonthd, $dayormonthm, $value, $template1, $template2) = (shift, shift);

	&LoadLanguage("Profile");

	&ext_get_field($id);

	# if username is obmitted, we'll generate the code for the registration page
	if ($pusername ne "") { $value = &ext_get($pusername,$field{'name'},1); }

	&FromHTML($field{'comment'});

	$template1 = qq~<tr class="windowbg"><td align="left" valign="top"><label for=""><b>$field{'name'}: </b><br /><span class="small">$field{'comment'}</span></label></td><td align="left">~;
	if ($field{'required_on_reg'} == 1) { $template2 = " *"; }
	$template2 .= qq~</td></tr>\n~;

	# format the output dependend on field type
	my $name_id = "ext_$id";
	if ($field{'type'} eq "text") {
		@options = split(/\^/,$field{'options'});
		if ($options[0] ne "") { $options[0] = qq~ maxlength="$options[0]"~; }
		if ($options[1] ne "") { $options[1] = qq~ size="$options[1]"~; }
		if ($options[3] ne "" && $value eq "") { $options[3] = qq~ value="$options[3]"~; } else { $options[3] = qq~ value="$value"~; }
		$output .= $template1 . qq~<input type="text"$options[0] name="ext_$id" id="ext_$id"$options[1] $options[3] />~ . $template2;

	} elsif ($field{'type'} eq "text_multi") {
		@options = split(/\^/,$field{'options'});
		if ($options[0]) {
			$field{'options'} = qq~
	<br /><span class="small">$lang_ext{'max_chars1'}$options[0]$lang_ext{'max_chars2'} <input value="$options[0]" size="~ . length($options[0]) . qq~" name="ext_$id\_msgCL" id="ext_$id\_msgCL" class="windowbg" style="border: 0px; padding: 1px; font-size: 11px;" readonly="readonly" /></span>
	<script language="JavaScript" type="text/javascript">
	<!--
	var ext_$id\_supportsKeys = false;
	function ext_$id\_tick() {
		ext_$id\_calcCharLeft(document.forms[0]);
		if (!ext_$id\_supportsKeys) timerID = setTimeout("ext_$id\_tick()",$options[0]);
	}

	function ext_$id\_calcCharLeft(sig) {
		clipped = false;
		maxLength = $options[0];
		if (document.creator.ext_$id.value.length > maxLength) {
			document.creator.ext_$id.value = document.creator.ext_$id.value.substring(0,maxLength);
			charleft = 0;
			clipped = true;
		} else {
			charleft = maxLength - document.creator.ext_$id.value.length;
		}
		document.creator.ext_$id\_msgCL.value = charleft;
		return clipped;
	}

	ext_$id\_tick();
	//-->
	</script>~;
		} else { $field{'options'} = ""; }
		if ($options[1] ne "") { $options[1] = qq~ rows="$options[1]"~; } else { $options[1] = qq~ rows="4"~; }
		if ($options[2] ne "") { $options[2] = qq~ cols="$options[2]"~; } else { $options[2] = qq~ cols="50"~; }
		$value =~ s/<br(?: ?\/)?>/\n/g;
		$output .= $template1 . qq~<textarea name="ext_$id" id="ext_$id"$options[1]$options[2]>$value</textarea>$field{'options'}~ . $template2;

	} elsif ($field{'type'} eq "select") {
		$output .= $template1 . qq~<select name="ext_$id" id="ext_$id" size="1">\n~;
		@options = split(/\^/,$field{'options'});
		if ($value > $#options || $value eq "") { $ext_profile[$id] = 0; }
		$count = 0;
		foreach (@options) {
			if ($count == $value) { $selected = " selected=\"selected\""; } else { $selected = ""; }
			$output .= qq~<option value="$count"$selected>$_</option>\n~;
			$count++;
		}
		$output .= qq~</select>~ . $template2;

	} elsif ($field{'type'} eq "radiobuttons") {
		$output .= $template1;
		@options = split(/\^/,$field{'options'});
		if ($value > $#options) { $value = 0; }
		if(!$field{'radiounselect'} && $value eq "") { $value = 0; }
		$count = 0;
		foreach (@options) {
			if ($value ne "" && $count == $value) { $selected = qq~ id="ext_$id" checked="checked"~; } else { $selected = ""; }
			$output .= qq~<input type="radio" name="ext_$id" value="$count"$selected />$_\n~;
			$count++;
		}
		$output .= $template2;

	} elsif ($field{'type'} eq "date") {
		if ($value !~ /[0-9\/]/) { $value = ""; }
		@options = split(/\//,$value);
		$dayormonthm = qq~ $profile_txt{'564'} <input type="text" name="ext_$id\_month" id="ext_$id\_month" size="2" maxlength="2" value="$options[0]" />~;
		$dayormonthd = qq~ $profile_txt{'565'} <input type="text" name="ext_$id\_day" id="ext_$id\_day" size="2" maxlength="2" value="$options[1]" />~;
		if ((${$uid.$pusername}{'timeselect'} == 2 || ${$uid.$pusername}{'timeselect'} == 3 || ${$uid.$pusername}{'timeselect'} == 6) || ($timeselected == 2 || $timeselected == 3 || $timeselected == 6)) {
			$dayormonth=$dayormonthd.$dayormonthm;
			$name_id = "ext_$id\_day";
		} else {
			$dayormonth=$dayormonthm.$dayormonthd;
			$name_id = "ext_$id\_month";
		}
		$output .= $template1 . qq~<span class="small">$dayormonth $profile_txt{'566'} <input type="text" name="ext_$id\_year" size="4" maxlength="4" value="$options[2]" /></span>~ . $template2;

	} elsif ($field{'type'} eq "checkbox") {
		if ($value == 1) { $value = " checked=\"checked\""; } else { $value = ""; }
		# we have to use a little trick here to get a value from a checkbox if it has been unchecked by adding a hidden <input value=""> before it
		$output .= $template1 . qq~<input type="hidden" name="ext_$id" value="" /><input type="checkbox" name="ext_$id" id="ext_$id"$value />~ . $template2;

	} elsif ($field{'type'} eq "spacer") {
		@options = split(/\^/,$field{'options'});
		if ($options[1] == 1) {
			#if ($options[0] == 1) { $output .= qq~<tr class="catbg"><td colspan=2><br /></td></tr>\n~; }
			#else { $output .= qq~<tr class="catbg"><td colspan=2><hr width="100%" size="1" class="hr"></td></tr>\n~; }
			$output .= qq~<tr><td class="catbg" colspan="2">$field{'comment'}&nbsp;</td></tr>\n~;
		}

	} elsif ($field{'type'} eq "email") {
		$output .= $template1 . qq~<input type="text" name="ext_$id" id="ext_$id" maxlength="$ext_max_email_length" size="30" value="$value" />~ . $template2;

	} elsif ($field{'type'} eq "url") {
		$output .= $template1 . qq~<input type="text" name="ext_$id" id="ext_$id" maxlength="$ext_max_url_length" size="50" value="$value" />~ . $template2;

	} elsif ($field{'type'} eq "image") {
		if ($value eq "") { $value = "http://"; }
		$output .= $template1 . qq~<input type="text" name="ext_$id" id="ext_$id" maxlength="$ext_max_image_length" size="50" value="$value" />~ . $template2;
	}
	$output =~ s/<label for="">/<label for="$name_id">/g;

	$output;
}

# returns the output for the edit profile page
## USAGE: $value = ext_editprofile("admin","required");
sub ext_editprofile {
	my ($pusername, $part, $usergroup, $id, $output, $fieldname, @options, $selected, $count) = (shift, shift, ${$uid.$username}{'position'});

	if (-e ("$vardir/gmodsettings.txt")) { require "$vardir/gmodsettings.txt"; }

	foreach $fieldname (@ext_prof_order) {
		$id = &ext_get_field_id($fieldname);
		&ext_get_field($id);

		# make sure the field is visible, the user allowed to edit the current field and only the requested fields are returned
		if ($field{'active'} == 1 &&
		    ($field{'editable_by_user'} != 0 || $iamadmin || $iamgmod && $allow_gmod_profile) &&
		    (($part eq "required"   && $field{'required_on_reg'}  == 1) ||  # show all required fields
		     ($part eq "additional" && $field{'required_on_reg'}  != 1) ||  # show all additional fields
		     ($part eq "admin"      && $field{'editable_by_user'} == 0) ||  # all fields for "admin edits" page
		     ($part eq "edit"       && $field{'editable_by_user'} == 1) ||  # all fields for "edit profile" page
		     ($part eq "contact"    && $field{'editable_by_user'} == 2) ||  # contact information page
		     ($part eq "options"    && $field{'editable_by_user'} == 3) ||  # options page
		     ($part eq "im"         && $field{'editable_by_user'} == 4))) { # im prefs page
			$output .= &ext_gen_editfield($id, $pusername);
		}
	}

	$output;
}

# returns the output for the registration page
sub ext_register {
	my ($id, $output, $fieldname, @options, @selected);

	foreach $fieldname (@ext_prof_order) {
		$id = &ext_get_field_id($fieldname);
		&ext_get_field($id);
		if ($field{'active'} == 1 && $field{'required_on_reg'} != 0) {
			$output .= &ext_gen_editfield($id);
		}
	}

	$output;
}

# returns if the submitted profile is valid, if not, return error messages
sub ext_validate_submition {
	my ($username, $pusername, $usergroup, %newprofile, @oldprofile, $output, $key, $value, $id, @options) = (shift, shift, ${$uid.$username}{'position'}, %FORM);

	if (-e "$vardir/gmodsettings.txt") { require "$vardir/gmodsettings.txt"; }

	while (($key,$value) = each(%newprofile)) {
		# only validate fields with prefix "ext_"
		if ($key =~ /^ext_(\d+)$/) {
			$id = $1;
			&ext_get_field($id);

			if (!$field{'name'}) { $output .= $lang_ext{'field_not_existing1'}.$id.$lang_ext{'field_not_existing2'}."<br />\n"; }

			# check if user is allowed to modify this setting
			if ($action eq "register2") {
				# if we're on registration page, igonre the 'editable_by_user' setting in case that 'required_on_reg' is set
				if ($field{'editable_by_user'} == 0 && $field{'required_on_reg'} == 0) {
					$output .= $field{'name'}.": ".$lang_ext{'not_allowed_to_modify'}."<br />\n";
				}
			} elsif (($field{'editable_by_user'} == 0 || $username ne $pusername) && !$iamadmin && (!$iamgmod || !$allow_gmod_profile)) {
					$output .= $field{'name'}.": ".$lang_ext{'not_allowed_to_modify'}."<br />\n";
			}

			# check if setting is valid
			if ($field{'type'} ne "text_multi" && $value =~ /[\n\r]/) { $output .= $field{'name'}.": ".$lang_ext{'invalid_char'}."<br />\n"; }

			if ($field{'type'} eq "text") {
				@options = split(/\^/,$field{'options'});
				# don't fill it with default value yet, it might be required on registration
				# if ($options[3] ne "" && $value eq "") { $value = $options[3]; $newprofile{'ext_'.$id} = $value; }
				if ($options[0]+0 > 0 && length($value) > $options[0]) { $output .= $field{'name'}.": ".$lang_ext{'too_long'}."<br />\n"; }
				if ($options[2] == 1 && $value !~ /[0-9\.,]+/ && $value ne "") { $output .= $field{'name'}.": ".$lang_ext{'not_numeric'}."<br />\n"; }
				&FromChars($value);
				&ToHTML($value);
				&ToChars($value);

			} elsif ($field{'type'} eq "text_multi") {
				@options = split(/\^/,$field{'options'});
				if ($options[0]+0 > 0 && length($value) > $options[0]) { $output .= $field{'name'}.": ".$lang_ext{'too_long'}."<br />\n"; }
				&FromChars($value);
				&ToHTML($value);
				&ToChars($value);
				$value =~ s/\n/<br \/>/g;
				$value =~ s/\r//g;

			} elsif ($field{'type'} eq "select" || $field{'type'} eq "radiobuttons") {
				@options = split(/\^/,$field{'options'});
				if ($value !~ /[0-9]/) { $output .= $field{'name'}.": ".$lang_ext{'not_numeric'}."<br />\n"; }
				if ($value < 0) { $output .= $field{'name'}.": ".$lang_ext{'too_small'}."<br />\n"; }
				if ($value > $#options) { $output .= $field{'name'}.": ".$lang_ext{'option_does_not_exist'}."<br />\n"; }
				next;

			} elsif ($field{'type'} eq "date" && $value ne "") {
				if ($value !~ /[0-9]/) { $output .= $field{'name'}.": ".$lang_ext{'not_numeric'}."<br />\n"; }
				if ($key eq "ext_".$id."_day") {
					if ($value < 1) { $output .= $field{'name'}.": ".$lang_ext{'too_small'}."<br />\n"; }
					if ($value > 31) { $output .= $field{'name'}.": ".$lang_ext{'too_big'}."<br />\n"; }
					if (length($value) == 1) { $newprofile{'ext_'.$id.'_day'} = "0".$value; }
				}
				elsif ($key eq "ext_".$id."_month") {
					if ($value < 1) { $output .= $field{'name'}.": ".$lang_ext{'too_small'}."<br />\n"; }
					if ($value > 12) { $output .= $field{'name'}.": ".$lang_ext{'too_big'}."<br />\n"; }
					if (length($value) == 1) { $newprofile{'ext_'.$id.'_month'} = "0".$value; }
				}
				elsif ($key eq "ext_".$id."_year") {
					if (length($value) != 4) { $output .= $field{'name'}.": ".$lang_ext{'invalid_year'}."<br />\n"; }
				}
				$newprofile{'ext_'.$id} = $newprofile{'ext_'.$id.'_month'} ."\/". $newprofile{'ext_'.$id.'_day'} ."\/". $newprofile{'ext_'.$id.'_year'};
				if ($newprofile{'ext_'.$id} !~ /^\d\d\/\d\d\/\d\d\d\d$/) { $newprofile{'ext_'.$id} = ""; }
				next;

			} elsif ($field{'type'} eq "checkbox") {
				if ($value ne "") { $newprofile{'ext_'.$id} = 1; } else { $newprofile{'ext_'.$id} = 0; }
				next;

			} elsif ($field{'type'} eq "email" && $value ne "") {
				$value = substr($value,0,$ext_max_email_length);
				# uses the code from Profile.pl without further checking...
				if ($value !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/) { $output .= $field{'name'}.": ".$lang_ext{'invalid_char'}."<br />\n"; }
				if (($value =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($value !~ /^.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?$/)) { $output .= $field{'name'}.": ".$lang_ext{'invalid_char'}."<br />\n"; }

			} elsif ($field{'type'} eq "url" && $value ne "") {
				$value = substr($value,0,$ext_max_url_length);

			} elsif ($field{'type'} eq "image" && $value ne "" && $value ne "http://") {
				$value = substr($value,0,$ext_max_image_length);
				@options = split(/\^/,$field{'options'});
				if ($options[2] ne "") {
					@allowed_extensions = split(/ /,$options[2]);
					$match = 0;
					foreach $extension (@allowed_extensions){
						if (grep /$extension$/i,$value) { $match = 1; last; }
					}
					if ($match == 0) { $output .= $field{'name'}.": ".$lang_ext{'invalid_extension'}."<br />\n"; }
				}
				# filename check from profile.pl:
				if ($value !~ m^\A[0-9a-zA-Z_\.\#\%\-\:\+\?\$\&\~\.\,\@/]+\Z^) { $output .= $field{'name'}.": ".$lang_ext{'invalid_char'}."<br />\n"; }
			}
			$newprofile{'ext_'.$id} = $value;
		}
	}

	# check if required fields are filled and add missing fields to $newprofile, just to be on the saver side
	$id = 0;
	foreach (@ext_prof_fields) {
		&ext_get_field($id);
		$value = &ext_get($pusername, $field{'name'}, 1);
		if (defined $newprofile{'ext_'.$id} && ($field{'type'} eq "checkbox" || $field{'type'} eq "radiobuttons")) {
			if ($newprofile{'ext_'.$id} eq "") { $newprofile{'ext_'.$id} = 0; }
		}
		if (defined $newprofile{'ext_'.$id} && $field{'type'} eq "select") {
			if ($newprofile{'ext_'.$id} eq "") { $newprofile{'ext_'.$id} = 0; }
			@options = split(/\^/,$field{'options'});
			if($options[$newprofile{'ext_'.$id}] eq " ") { $newprofile{'ext_'.$id} = ""; }
		}
		if (defined $newprofile{'ext_'.$id} && $field{'type'} eq "image") {
			if ($newprofile{'ext_'.$id} eq "http://") { $newprofile{'ext_'.$id} = ""; }
		}
		# load old settings which where invisible/restricted
		if ($action eq "register2") {
			if ($field{'editable_by_user'} == 0 && $field{'required_on_reg'} == 0) {
				$newprofile{'ext_'.$id} = $value;
			}
		} else {
			if ($field{'editable_by_user'} == 0 && !$iamadmin && (!$iamgmod || !$allow_gmod_profile)) {
				$newprofile{'ext_'.$id} = $value;
			}
		}
		# if setting didn't get submitted or field is disabled, load old value
		if (!defined $newprofile{'ext_'.$id} || $field{'active'} == 0) { $newprofile{'ext_'.$id} = $value; }
		if ($field{'required_on_reg'} == 1 && $newprofile{'ext_'.$id} eq "") { $output .= $field{'name'}.": ".$lang_ext{'required'}."<br />\n"; }
		# only fill with default value AFTER check of requirement
		if ($field{'type'} eq "text" && $newprofile{'ext_'.$id} eq "") {
			@options = split(/\^/,$field{'options'});
			if ($options[3] ne "") { $newprofile{'ext_'.$id} = $options[3] }
		} elsif ($field{'type'} eq "spacer") {
			$newprofile{'ext_'.$id} = "";
		}
		elsif ($field{'type'} eq "select" && $newprofile{'ext_'.$id} eq "") {
			$newprofile{'ext_'.$id} = 0;
		}
		$id++;
	}

	# write our now validated profile information back into the usually used variable
	%FORM = %newprofile;

	$output;
}

# stores the submitted profile on disk
sub ext_saveprofile {
	my ($pusername, $id, %newprofile, @fields) = (shift, 0, %FORM);

	# note: we expect the new profile to be complete and validated already

	foreach (@ext_prof_fields) {
		${$uid.$pusername}{'ext_'.$id} = $newprofile{"ext_".$id};
		$id++;
	}
}

# here we define us some ready-to-use html samples to design the input forms for the admin area
# this makes it easier to modify the html code afterwards
sub ext_admin_htmlreq {
	$ext_template_blockstart = qq~
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
  <table cellpadding="4" cellspacing="1" width="100%">
    <tbody>
~;
	$ext_template_headerstart = qq~
    <tr valign="middle"><td class="titlebg" align="left">
      <img src="$imagesdir/profile.gif" alt="" border="0" /><b>~;
	$ext_template_headerstop = qq~
      </b>
    </td></tr>~;
	$ext_template_commentstart = qq~
    <tr align="center" valign="middle"><td class="catbg" align="left">
      <span class="small">~;
	$ext_template_commentstop = qq~
      </span></td>
    </tr>~;
	$ext_template_contentstart = qq~
    <tr valign="middle"><td class="windowbg2" align="left">~;
	$ext_template_contentstop = qq~
    </td></tr>~;
	$ext_template_blockstop = qq~
  </tbody></table>
</div>
~;
	$ext_template_option_part1 = qq~
      <tr>
        <td align="left" valign="top"><b>~;
	$ext_template_option_part2 = qq~: </b><br /><span class="small">~;
	$ext_template_option_part3 = qq~</span></td>
        <td align="left" valign="top">~;
	$ext_template_option_part4 = qq~</td>
      </tr>~;
}

# returns the output for the Extended Profile Controls in admin center
sub ext_admin {
	my ($id, $output, $fieldname, @options, $active, @selected, @contents);

	&is_admin_or_gmod;
	&ext_admin_htmlreq;

	$yymain .= qq~
$ext_template_blockstart
$ext_template_headerstart
$lang_ext{'Profiles_Controls'}
$ext_template_headerstop
$ext_template_contentstart
$lang_ext{'admin_description'}
$ext_template_contentstop
$ext_template_blockstop

<br />

$ext_template_blockstart
$ext_template_headerstart
$lang_ext{'edit_title'}
$ext_template_headerstop
$ext_template_contentstart
$lang_ext{'edit_description'}
$ext_template_contentstop
$ext_template_contentstart
    <table class="windowbg2" border="0" cellspacing="0" cellpadding="3" width="100%">
      <tr>
        <td align="center">$lang_ext{'active'}</td>
        <td align="center">$lang_ext{'field_name'}</td>
        <td align="center">$lang_ext{'field_type'}</td>
        <td align="center">$lang_ext{'actions'}</td>
      </tr>
~;
	if (!@ext_prof_order) {
		$yymain .= qq~<td class="windowbg2" colspan="4" align="center"><br /><i>$lang_ext{'no_additional_fields_set'}</i><br /><br /></td>~;
	} else {
		foreach $fieldname (@ext_prof_order) {
			$id = &ext_get_field_id($fieldname);
			&ext_get_field($id);
			if ($field{'type'} eq "text") { $selected[0] = " selected=\"selected\""; } else { $selected[0] = ""; }
			if ($field{'type'} eq "text_multi") { $selected[1] = " selected=\"selected\""; } else { $selected[1] = ""; }
			if ($field{'type'} eq "select") { $selected[2] = " selected=\"selected\""; } else { $selected[2] = ""; }
			if ($field{'type'} eq "radiobuttons") { $selected[3] = " selected=\"selected\""; } else { $selected[3] = ""; }
			if ($field{'type'} eq "checkbox") { $selected[4] = " selected=\"selected\""; } else { $selected[4] = ""; }
			if ($field{'type'} eq "date") { $selected[5] = " selected=\"selected\""; } else { $selected[5] = ""; }
			if ($field{'type'} eq "email") { $selected[6] = " selected=\"selected\""; } else { $selected[6] = ""; }
			if ($field{'type'} eq "url") { $selected[7] = " selected=\"selected\""; } else { $selected[7] = ""; }
			if ($field{'type'} eq "spacer") { $selected[8] = " selected=\"selected\""; } else { $selected[8] = ""; }
			if ($field{'type'} eq "image") { $selected[9] = " selected=\"selected\""; } else { $selected[9] = ""; }
			if ($field{'active'} == 1) { $active = " checked=\"checked\""; } else { $active = ""; }
			$yymain .= qq~
      <tr>
        <form action="$adminurl?action=ext_edit" method="post">
        <td class="windowbg2" align="center">
          <input name="id" type="hidden" value="$id" />
          <input type="checkbox" name="active" value="1"$active />
        </td>
        <td class="windowbg2" align="center">
          <input name="name" value="$field{'name'}" size="20" />
        </td>
        <td class="windowbg2" align="center">
          <select name="type" size="1">
            <option value="text"$selected[0]>$lang_ext{'text'}</option>
            <option value="text_multi"$selected[1]>$lang_ext{'text_multi'}</option>
            <option value="select"$selected[2]>$lang_ext{'select'}</option>
            <option value="radiobuttons"$selected[3]>$lang_ext{'radiobuttons'}</option>
            <option value="checkbox"$selected[4]>$lang_ext{'checkbox'}</option>
            <option value="date"$selected[5]>$lang_ext{'date'}</option>
            <option value="email"$selected[6]>$lang_ext{'email'}</option>
            <option value="url"$selected[7]>$lang_ext{'url'}</option>
            <option value="spacer"$selected[8]>$lang_ext{'spacer'}</option>
            <option value="image"$selected[9]>$lang_ext{'image'}</option>
          </select>
        </td>
        <td class="windowbg2" align="center">
          <input type="submit" name="apply" value="$lang_ext{'apply'}" />
          <input type="submit" name="options" value="$lang_ext{'options'}" />
          <input type="submit" name="delete" value="$lang_ext{'delete'}" />
        </td>
        </form>
      </tr>
~;
		}
	}

	$yymain .= qq~
    </table>
$ext_template_contentstop
$ext_template_blockstop

<br />

$ext_template_blockstart
$ext_template_headerstart
$lang_ext{'create_new_title'}
$ext_template_headerstop
$ext_template_contentstart
$lang_ext{'create_new_description'}
$ext_template_contentstop
$ext_template_contentstart
    <table border="0" cellspacing="0" cellpadding="3" width="100%">
      <tr>
        <td class="windowbg2" align="center"><label for="name">$lang_ext{'field_name'}</label></td>
        <td class="windowbg2" align="center"><label for="type">$lang_ext{'field_type'}</label></td>
        <td class="windowbg2" align="center">$lang_ext{'actions'}</td>
      </tr>
      <tr>
        <form action="$adminurl?action=ext_create" method="post">
        <td class="windowbg2" align="center">
          <input name="name" id="name" size="30" />
        </td>
        <td class="windowbg2" align="center">
          <select name="type" id="type" size="1">
            <option value="text" selected="selected">$lang_ext{'text'}</option>
            <option value="text_multi">$lang_ext{'text_multi'}</option>
            <option value="select">$lang_ext{'select'}</option>
            <option value="radiobuttons">$lang_ext{'radiobuttons'}</option>
            <option value="checkbox">$lang_ext{'checkbox'}</option>
            <option value="date">$lang_ext{'date'}</option>
            <option value="email">$lang_ext{'email'}</option>
            <option value="url">$lang_ext{'url'}</option>
            <option value="spacer">$lang_ext{'spacer'}</option>
            <option value="image">$lang_ext{'image'}</option>
          </select>
        </td>
        <td class="windowbg2" align="center">
          <input type="submit" name="create" value="$lang_ext{'create_field'}" />
        </td>
        </form>
      </tr>
    </table>
$ext_template_contentstop
$ext_template_blockstop

<br />

$ext_template_blockstart
$ext_template_headerstart
$lang_ext{'reorder_title'}
$ext_template_headerstop
$ext_template_contentstart
      <table border="0" cellspacing="0" cellpadding="6" width="100%">
      <tr>
        <form action="$adminurl?action=ext_reorder" method="post">
        <td class="windowbg2" valign="top">
          <textarea name="reorder" cols="30" rows="6">~;

	foreach $fieldname (@ext_prof_order) { $yymain .= $fieldname."\n"; }

          $yymain .= qq~</textarea>
        </td>
        <td class="windowbg2" width="100%" valign="top" align="left">
          $lang_ext{'reorder_description'}<br /><br />
          <input type="submit" name="reorder_submit" value="$lang_ext{'reorder'}" />
        </td>
        </form>
      </tr>
      </table>
$ext_template_contentstop
$ext_template_blockstop

<br />
~;

	if (-e "$vardir/ConvSettings.txt") {
		require "$vardir/ConvSettings.txt";
	} else {
		$convmemberdir = "./Convert/Members";
		$convvardir = "./Convert/Variables";
	}

	$yymain .= qq~
$ext_template_blockstart
$ext_template_headerstart
$lang_ext{'converter_title'}
$ext_template_headerstop
$ext_template_contentstart
$lang_ext{'converter_description'}
    <form action="$adminurl?action=ext_convert" method="post">
    <p align="center"><br />
      <label for="members">$lang_ext{'path_old_members_folder'}:</label>  <input name="members" id="members" value="$convmemberdir" /><br />
      <label for="vars">$lang_ext{'path_old_variables_folder'}:</label>  <input name="vars" id="vars" value="$convvardir" /><br /><br />
      <input type="submit" name="convert" value="$lang_ext{'converter_button'}" /><br /><br /></p>
    </form>
$ext_template_contentstop
$ext_template_blockstop
~;

	$yytitle = $lang_ext{'Profiles_Controls'};
	$action_area = "ext_admin";
	&AdminTemplate;
}

# reorders the fields as submitted
sub ext_admin_reorder {
	&is_admin_or_gmod;

	$FORM{'reorder'} =~ tr/\r//d;
	$FORM{'reorder'} =~ s~\A[\s\n]+~~;
	$FORM{'reorder'} =~ s~[\s\n]+\Z~~;
	$FORM{'reorder'} =~ s~\n\s*\n~\n~g;
	&ToHTML($FORM{'reorder'});

	@ext_prof_order = split(/\n/, $FORM{'reorder'});

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');

	$yySetLocation = qq~$adminurl?action=ext_admin~;
	&redirectexit;
}

# creates a new field as submitted
sub ext_admin_create {
	&is_admin_or_gmod;

	&ToHTML($FORM{'name'});

	push(@ext_prof_order, $FORM{'name'});
	push(@ext_prof_fields, "$FORM{'name'}|$FORM{'type'}||1||0|1|||0|||0|0|||1|0|||0|0");

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');

	$yySetLocation = qq~$adminurl?action=ext_admin~;
	&redirectexit;
}

# will generate us a nicely formated table row for the input form
sub ext_admin_gen_inputfield {
	my ($var1,$var2,$var3,$output) = (shift, shift, shift);

	# &ext_admin_htmlreq; has to be called before using this subroutine

	$output = qq~$ext_template_option_part1$var1~;
	$output .= qq~$ext_template_option_part2$var2~;
	$output .= qq~$ext_template_option_part3$var3~;
	$output .= qq~$ext_template_option_part4~;

	$output;
}

# generate html form option list depending on the passed groups string
sub ext_admin_gen_groupslist {
	my ($groups, $output, $groupid, @groups, %groupcheck) = (shift,"");

	@groups = split(/\s*\,\s*/,$groups);
	foreach (@groups) {
		$groupcheck{$_} = " selected=\"selected\"";
	}

	$output = qq~<option value="Administrator"$groupcheck{'Administrator'}>~.(split(/\|/, $Group{"Administrator"}))[0].qq~</option>\n~.
		  qq~<option value="Global Moderator"$groupcheck{'Global Moderator'}>~.(split(/\|/, $Group{"Global Moderator"}))[0].qq~</option>\n~.
		  qq~<option value="Moderator"$groupcheck{Moderator}>~.(split(/\|/, $Group{"Moderator"}))[0].qq~</option>\n~;

	foreach (sort { $a <=> $b } keys %NoPost) {
		$groupid = $_;
		$output .= qq~<option value="NoPost{$groupid}"$groupcheck{'NoPost{'.$groupid.'}'}>~.(split(/\|/, (split(/\|/, $NoPost{$groupid}))[0]))[0].qq~</option>\n~;
	}
	foreach (sort { $b <=> $a } keys %Post) {
		$groupid = $_;
		$output .= qq~<option value="Post{$groupid}"$groupcheck{'Post{'.$groupid.'}'}>~.(split(/\|/, (split(/\|/, $Post{$groupid}))[0]))[0].qq~</option>\n~;
	}

	$output;
}

# performs all actions done in the edit profile field panel
sub ext_admin_edit {
	my (@fields, @order, $type, $active, $id, $name, $oldname, $req1, $req2, $req3, $v_check, $p_check, $p_d_check, $m_check, @editable_check, $is_numeric, $ubbc, @options, $check1, $check2, @contents, @old_content, $new_content, $output);
	&is_admin_or_gmod;

	if ($FORM{'apply'} ne "") {
		&ToHTML($FORM{'name'});
		$name = $FORM{'name'};
		$id = $FORM{'id'};
		$type = $FORM{'type'};
		$active = $FORM{'active'} ne "" ? 1 : 0;

		@fields = @ext_prof_fields;
		@_ = split(/\|/,$fields[$FORM{'id'}]);
		$oldname = $_[0];
		$fields[$FORM{'id'}] = "$name|$type|$_[2]|$active|$_[4]|$_[5]|$_[6]|$_[7]|$_[8]|$_[9]|$_[10]|$_[11]|$_[12]|$_[13]|$_[14]|$_[15]|$_[16]|$_[17]|$_[18]|$_[19]|$_[20]|$_[21]";
		@ext_prof_fields = @fields;

		@order = @ext_prof_order;
		$id = 0;
		foreach (@order) {
			if ($oldname eq $_) { $order[$id] = $name; last; }
			$id++;
		}
		@ext_prof_order = @order;

		require "$admindir/NewSettings.pl";
		&SaveSettingsTo('Settings.pl');

		$yySetLocation = qq~$adminurl?action=ext_admin~;
		&redirectexit;

	} elsif ($FORM{'options'} ne "") {
		&ext_admin_htmlreq;
		&ext_get_field($FORM{'id'});
		if ($field{'active'} == 1) { $active = $lang_ext{'true'}; } else { $active = $lang_ext{'false'}; }
		if ($field{'required_on_reg'} == 1) { $req1 = ""; $req2 = " checked=\"checked\""; $req3 = ""; }
		elsif ($field{'required_on_reg'} == 2) { $req1 = ""; $req2 = ""; $req3 = " checked=\"checked\""; }
		else { $req1 = " checked=\"checked\""; $req2 = ""; $req3 = ""; }
		if ($field{'visible_in_viewprofile'} == 1) { $v_check = " checked=\"checked\""; } else { $v_check = ""; }
		if ($field{'visible_in_posts'} == 1) { $p_check = " checked=\"checked\""; } else { $p_check = ""; }
		if ($field{'visible_in_posts_popup'} == 1) { $pp_check = " checked=\"checked\""; } else { $pp_check = ""; }
		if ($field{'p_displayfieldname'} == 1) { $p_d_check = " checked=\"checked\""; } else { $p_d_check = ""; }
		if ($field{'pp_displayfieldname'} == 1) { $pp_d_check = " checked=\"checked\""; } else { $pp_d_check = ""; }
		if ($field{'visible_in_memberlist'} == 1) { $m_check = " checked=\"checked\""; } else { $m_check = ""; }
		if ($field{'radiounselect'} == 1) { $radiounselect = " checked=\"checked\""; } else { $radiounselect = ""; }
		$editable_check[$field{'editable_by_user'}] = " selected=\"selected\"";
		$yymain .= qq~
<form action="$adminurl?action=ext_edit2" method="post">
$ext_template_blockstart
$ext_template_headerstart
$lang_ext{'options_title'}
$ext_template_headerstop
$ext_template_commentstart
$lang_ext{'options_description'}
$ext_template_commentstop
$ext_template_contentstart
<table class="windowbg2" border="0" cellspacing="0" cellpadding="6" width="100%">
	<tr>
		<td><b>$lang_ext{'active'}:</b> $active</td>
		<td align="center"><b>$lang_ext{'field_name'}:</b> $field{'name'}</td>
		<td align="center"><b>$lang_ext{'field_type'}:</b> $lang_ext{$field{'type'}}</td>
		<td align="right"><a href="$adminurl?action=ext_admin">&lt;-- $lang_ext{'change_these_settings'}</a></td>
	</tr>
</table>
$ext_template_contentstop
$ext_template_contentstart
<table class="windowbg2" border="0" cellspacing="0" cellpadding="6" width="100%">
~;
		if ($field{'type'} eq "text") {
			@options = split(/\^/,$field{'options'});
			if ($options[2] == 1) { $is_numeric = " checked=\"checked\"" } else { $is_numeric = "" }
			if ($options[4] == 1) { $ubbc = " checked=\"checked\"" } else { $ubbc = "" }
			$yymain .=
				&ext_admin_gen_inputfield(qq~<label for="limit_len">$lang_ext{'limit_len'}</label>~,qq~<label for="limit_len">$lang_ext{'limit_len_description'}</label>~,
					qq~<input name="limit_len" id="limit_len" size="5" value='$options[0]' />~).
				&ext_admin_gen_inputfield(qq~<label for="width">$lang_ext{'width'}</label>~,qq~<label for="width">$lang_ext{'width_description'}</label>~,
					qq~<input name="width" id="width" size="5" value='$options[1]' />~).
				&ext_admin_gen_inputfield(qq~<label for="is_numeric">$lang_ext{'is_numeric'}</label>~,qq~<label for="is_numeric">$lang_ext{'is_numeric_description'}</label>~,
					qq~<input name="is_numeric" id="is_numeric" type="checkbox" value="1"$is_numeric />~).
				&ext_admin_gen_inputfield(qq~<label for="default">$lang_ext{'default'}</label>~,qq~<label for="default">$lang_ext{'default_description'}</label>~,
					qq~<input name="default" id="default" size="50" value='$options[3]' />~).
				&ext_admin_gen_inputfield(qq~<label for="ubbc">$lang_ext{'ubbc'}</label>~,qq~<label for="ubbc">$lang_ext{'ubbc_description'}</label>~,
					qq~<input name="ubbc" id="ubbc" type="checkbox" value="1"$ubbc />~);

		} elsif ($field{'type'} eq "text_multi") {
			@options = split(/\^/,$field{'options'});
			if ($options[3] == 1) { $ubbc = " checked=\"checked\"" } else { $ubbc = "" }
			$yymain .= 
				&ext_admin_gen_inputfield(qq~<label for="limit_len">$lang_ext{'limit_len'}</label>~,qq~<label for="limit_len">$lang_ext{'limit_len_description'}</label>~,
					qq~<input name="limit_len" id="limit_len" size="5" value='$options[0]' />~).
				&ext_admin_gen_inputfield(qq~<label for="rows">$lang_ext{'rows'}</label>~,qq~<label for="rows">$lang_ext{'rows_description'}</label>~,
					qq~<input name="rows" id="rows" size="5" value='$options[1]' />~).
				&ext_admin_gen_inputfield(qq~<label for="cols">$lang_ext{'cols'}</label>~,qq~<label for="cols">$lang_ext{'cols_description'}</label>~,
					qq~<input name="cols" id="cols" size="5" value='$options[2]' />~).
				&ext_admin_gen_inputfield(qq~<label for="ubbc">$lang_ext{'ubbc'}</label>~,qq~<label for="ubbc">$lang_ext{'ubbc_description'}</label>~,
					qq~<input name="ubbc" id="ubbc" type="checkbox" value="1"$ubbc />~);

		} elsif ($field{'type'} eq "select") {
			@options = split(/\^/,$field{'options'});
			$output = "";
			foreach (@options) { $output .= qq~$_\n~; }
			$yymain .= 
				&ext_admin_gen_inputfield(qq~<label for="options">$lang_ext{'s_options'}</label>~,qq~<label for="options">$lang_ext{'s_options_description'}</label>~,
					qq~<textarea name="options" id="options" cols="30" rows="3">$output</textarea>~);

		} elsif ($field{'type'} eq "radiobuttons") {
			@options = split(/\^/,$field{'options'});
			$output = "";
			foreach (@options) { $output .= qq~$_\n~; }
			$yymain .= 
				&ext_admin_gen_inputfield(qq~<label for="options">$lang_ext{'s_options'}</label>~,qq~<label for="options">$lang_ext{'s_options_description'}</label>~,
					qq~<textarea name="options" id="options" cols="30" rows="3">$output</textarea>~).
				&ext_admin_gen_inputfield(qq~<label for="radiounselect">$lang_ext{'radiounselect'}</label>~,qq~<label for="radiounselect">$lang_ext{'radiounselect_description'}</label>~,
					qq~<input name="radiounselect" id="radiounselect" type="checkbox" value="1"$radiounselect />~);

		} elsif ($field{'type'} eq "spacer") {
			@options = split(/\^/,$field{'options'});
			if ($options[0] == 1) { $check2 = " checked=\"checked\""; $check1 = ""; } else {  $check2 = ""; $check1 = " checked=\"checked\""; }
			if ($options[1] == 1) { $options[1] = " checked=\"checked\""; } else { $options[1] = ""; }
			$yymain .= 
				&ext_admin_gen_inputfield(qq~<label for="hr_or_br">$lang_ext{'hr_or_br'}</label>~,qq~<label for="hr_or_br">$lang_ext{'hr_or_br_description'}</label>~,
					qq~<input name="hr_or_br" id="hr_or_br" type="radio" value="0"$check1 />$lang_ext{'hr'}\n~.
					qq~<input name="hr_or_br" type="radio" value="1"$check2 />$lang_ext{'br'}~).
				&ext_admin_gen_inputfield(qq~<label for="visible_in_editprofile">$lang_ext{'visible_in_editprofile'}</label>~,qq~<label for="visible_in_editprofile">$lang_ext{'visible_in_editprofile_description'}</label>~,
					qq~<input name="visible_in_editprofile" id="visible_in_editprofile" type="checkbox" value="1"$options[1] />~);

		} elsif ($field{'type'} eq "image") {
			@options = split(/\^/,$field{'options'});
			#if ($options[3] == 1) { $ubbc = " checked=\"checked\"" } else { $ubbc = "" }
			$yymain .= 
				&ext_admin_gen_inputfield(qq~<label for="image_width">$lang_ext{'image_width'}</label>~,qq~<label for="image_width">$lang_ext{'image_width_description'}</label>~,
					qq~<input name="image_width" id="image_width" size="5" value='$options[0]' />~).
				&ext_admin_gen_inputfield(qq~<label for="image_height">$lang_ext{'image_height'}</label>~,qq~<label for="image_height">$lang_ext{'image_height_description'}</label>~,
					qq~<input name="image_height" id="image_height" size="5" value='$options[1]' />~).
				&ext_admin_gen_inputfield(qq~<label for="allowed_extensions">$lang_ext{'allowed_extensions'}</label>~,qq~<label for="allowed_extensions">$lang_ext{'allowed_extensions_description'}</label>~,
					qq~<input name="allowed_extensions" id="allowed_extensions" size="30" value='$options[2]' />~);
		}

		$yymain .= 
			&ext_admin_gen_inputfield(qq~<label for="comment">$lang_ext{'comment'}</label>~,qq~<label for="comment">$lang_ext{'comment_description'}</label>~,
				qq~<input name="comment" id="comment" size="50" value='$field{'comment'}' />~).
			&ext_admin_gen_inputfield(qq~<label for="required_on_reg">$lang_ext{'required_on_reg'}</label>~,qq~<label for="required_on_reg">$lang_ext{'required_on_reg_description'}</label>~,
				qq~<input name="required_on_reg" type="radio" value="1"$req2 /> $lang_ext{'req1'}<br />\n~.
				qq~<input name="required_on_reg" id="required_on_reg" type="radio" value="0"$req1 /> $lang_ext{'req0'}<br />\n~.
				qq~<input name="required_on_reg" type="radio" value="2"$req3 /> $lang_ext{'req2'}\n~).
			&ext_admin_gen_inputfield(qq~<label for="visible_in_viewprofile">$lang_ext{'visible_in_viewprofile'}</label>~,qq~<label for="visible_in_viewprofile">$lang_ext{'visible_in_viewprofile_description'}</label>~,
				qq~<input name="visible_in_viewprofile" id="visible_in_viewprofile" type="checkbox" value="1"$v_check /><br />\n~.
				qq~<table class="windowbg2" border="0" cellspacing="4" cellpadding="0">\n~.
				qq~  <tr><td><label for="v_users">$lang_ext{'v_users'}:</label> </td><td><input name="v_users" id="v_users" value="$field{'v_users'}" /></td></tr>\n~.
				qq~  <tr><td valign="top"><label for="v_groups">$lang_ext{'v_groups'}:</label> </td><td>\n~.
				qq~    <select multiple="multiple" name="v_groups" id="v_groups" size="4">\n~.
			&ext_admin_gen_groupslist($field{'v_groups'}).
				qq~    </select>\n~.
				qq~  </td></tr>\n~.
				qq~</table>\n~).
			&ext_admin_gen_inputfield(qq~<label for="visible_in_posts">$lang_ext{'visible_in_posts'}</label>~,qq~<label for="visible_in_posts">$lang_ext{'visible_in_posts_description'}</label>~,
				qq~<input name="visible_in_posts" id="visible_in_posts" type="checkbox" value="1"$p_check /><br />\n~.
				qq~<table class="windowbg2" border="0" cellspacing="4" cellpadding="0">\n~.
				qq~  <tr><td><label for="p_displayfieldname">$lang_ext{'display_fieldname'}:</label> </td><td><input name="p_displayfieldname" id="p_displayfieldname" type="checkbox" value="1"$p_d_check /></td></tr>\n~.
				qq~  <tr><td><label for="p_users">$lang_ext{'p_users'}:</label> </td><td><input name="p_users" id="p_users" value="$field{'p_users'}" /></td></tr>\n~.
				qq~  <tr><td valign="top"><label for="p_groups">$lang_ext{'p_groups'}:</label> </td><td>\n~.
				qq~    <select multiple="multiple" name="p_groups" id="p_groups" size="4">\n~.
			&ext_admin_gen_groupslist($field{'p_groups'}).
				qq~    </select>\n~.
				qq~  </td></tr>\n~.
				qq~</table>\n~).
			&ext_admin_gen_inputfield(qq~<label for="visible_in_posts_popup">$lang_ext{'visible_in_posts_popup'}</label>~,qq~<label for="visible_in_posts_popup">$lang_ext{'visible_in_posts_popup_description'}</label>~,
				qq~<input name="visible_in_posts_popup" id="visible_in_posts_popup" type="checkbox" value="1"$pp_check /><br />\n~.
				qq~<table class="windowbg2" border="0" cellspacing="4" cellpadding="0">\n~.
				qq~  <tr><td><label for="pp_displayfieldname">$lang_ext{'display_fieldname'}:</label> </td><td><input name="pp_displayfieldname" id="pp_displayfieldname" type="checkbox" value="1"$pp_d_check /></td></tr>\n~.
				qq~  <tr><td><label for="pp_users">$lang_ext{'p_users'}:</label> </td><td><input name="pp_users" id="pp_users" value="$field{'pp_users'}" /></td></tr>\n~.
				qq~  <tr><td valign="top"><label for="pp_groups">$lang_ext{'p_groups'}:</label> </td><td>\n~.
				qq~    <select multiple="multiple" name="pp_groups" id="pp_groups" size="4">\n~.
			&ext_admin_gen_groupslist($field{'pp_groups'}).
				qq~    </select>\n~.
				qq~  </td></tr>\n~.
				qq~</table>\n~).
			&ext_admin_gen_inputfield(qq~<label for="visible_in_memberlist">$lang_ext{'visible_in_memberlist'}</label>~,qq~<label for="visible_in_memberlist">$lang_ext{'visible_in_memberlist_description'}</label>~,
				qq~<input name="visible_in_memberlist" id="visible_in_memberlist" type="checkbox" value="1"$m_check /><br />\n~.
				qq~<table class="windowbg2" border="0" cellspacing="4" cellpadding="0">\n~.
				qq~  <tr><td><label for="m_users">$lang_ext{'m_users'}:</label> </td><td><input name="m_users" id="m_users" value="$field{'m_users'}" /></td></tr>\n~.
				qq~  <tr><td valign="top"><label for="m_groups">$lang_ext{'m_groups'}:</label> </td><td>\n~.
				qq~    <select multiple="multiple" name="m_groups" id="m_groups" size="4">\n~.
			&ext_admin_gen_groupslist($field{'m_groups'}).
				qq~    </select>\n~.
				qq~  </td></tr>\n~.
				qq~</table>\n~);

		if ($field{'type'} ne "spacer") {
			$yymain .= 
				&ext_admin_gen_inputfield(qq~<label for="editable_by_user">$lang_ext{'editable_by_user'}</label>~,qq~<label for="editable_by_user">$lang_ext{'editable_by_user_description'}</label>~,
					qq~<select name="editable_by_user" id="editable_by_user" size="1">\n~.
					qq~  <option value="0"$editable_check[0]>$lang_ext{'page_admin'}</option>\n~.
					qq~  <option value="1"$editable_check[1]>$lang_ext{'page_edit'}</option>\n~.
					qq~  <option value="2"$editable_check[2]>$lang_ext{'page_contact'}</option>\n~.
					qq~  <option value="3"$editable_check[3]>$lang_ext{'page_options'}</option>\n~.
					qq~  <option value="4"$editable_check[4]>$lang_ext{'page_im'}</option>\n~.
					qq~</select>\n~);
		}
		$yymain .= qq~
	<tr>
		<td colspan="2" align="center">
			<input name="id" type="hidden" value="$FORM{'id'}" />
			<input name="name" type="hidden" value="$FORM{'name'}" />
			<input name="type" type="hidden" value="$FORM{'type'}" />
			<input name="active" type="hidden" value="$FORM{'active'}" />
			~;
		if ($field{'type'} eq "spacer") { $yymain .= qq~<input name="editable_by_user" type="hidden" value="1" />
			~; }
		$yymain .= qq~<input type="submit" name="save" value="$lang_ext{'Save'}" />
		</td>
	</tr>
</table>
$ext_template_contentstop
$ext_template_blockstop
</form>
~;
		$yytitle = "$lang_ext{'Profiles_Controls'} - $lang_ext{'options_title'}";
		$action_area = "ext_admin";
		&AdminTemplate;

	} elsif ($FORM{'delete'} ne "") {
		$id = 0;
		&ext_get_field($FORM{'id'});
		@fields = @ext_prof_fields;
		@ext_prof_fields = ();
		foreach (@fields) {
			if ($FORM{'id'} != $id) { push(@ext_prof_fields, $_); }
			$id++;
		}

		@order = @ext_prof_order;
		@ext_prof_order = ();
		foreach (@order) {
			if ($_ ne $field{'name'}) { push(@ext_prof_order, $_); }
		}

		require "$admindir/NewSettings.pl";
		&SaveSettingsTo('Settings.pl');

		if ($use_MySQL) {
			@contents = &get_members_array();
		} else {
			opendir(EXT_DIR, "$memberdir");
			@contents = map { s/\.vars$//; $_; } grep { /\.vars$/ } readdir(EXT_DIR);
			closedir(EXT_DIR);
		}

		foreach (@contents) {
			&write_DBorFILE(0,EXT_FILE,$memberdir,$_,'vars',(map { $_ =~ s~'ext_$FORM{'id'}',"(?:.*?)"\n+~~ig; $_; } &read_DBorFILE(0,EXT_FILE,$memberdir,$_,'vars')));
		}

		$yySetLocation = qq~$adminurl?action=ext_admin~;
		&redirectexit;

	} else {
		$yySetLocation = qq~$adminurl?action=ext_admin~;
		&redirectexit;
	}
}

# modifies a field as submitted
sub ext_admin_edit2 {
	my (@fields, @options);
	&is_admin_or_gmod;

	&ToHTML($FORM{'name'});
	&ToHTML($FORM{'comment'});
	if ($FORM{'active'} eq "") { $FORM{'active'} = 0; }
	if ($FORM{'required_on_reg'} eq "") { $FORM{'required_on_reg'} = 0; }
	if ($FORM{'visible_in_viewprofile'} eq "") { $FORM{'visible_in_viewprofile'} = 0; }
	if ($FORM{'visible_in_posts'} eq "") { $FORM{'visible_in_posts'} = 0; }
	if ($FORM{'visible_in_posts_popup'} eq "") { $FORM{'visible_in_posts_popup'} = 0; }
	if ($FORM{'p_displayfieldname'} eq "") { $FORM{'p_displayfieldname'} = 0; }
	if ($FORM{'pp_displayfieldname'} eq "") { $FORM{'pp_displayfieldname'} = 0; }
	if ($FORM{'visible_in_memberlist'} eq "") { $FORM{'visible_in_memberlist'} = 0; }
	if ($FORM{'editable_by_user'} eq "") { $FORM{'editable_by_user'} = 0; }
	$FORM{'v_users'} =~ s/^(\s)*(.+?)(\s)*$/$2/;
	$FORM{'v_groups'} =~ s/^(\s)*(.+?)(\s)*$/$2/;
	$FORM{'p_users'} =~ s/^(\s)*(.+?)(\s)*$/$2/;
	$FORM{'p_groups'} =~ s/^(\s)*(.+?)(\s)*$/$2/;
	$FORM{'pp_users'} =~ s/^(\s)*(.+?)(\s)*$/$2/;
	$FORM{'pp_groups'} =~ s/^(\s)*(.+?)(\s)*$/$2/;
	$FORM{'m_users'} =~ s/^(\s)*(.+?)(\s)*$/$2/;
	$FORM{'m_groups'} =~ s/^(\s)*(.+?)(\s)*$/$2/;
	$FORM{'v_groups'} = join(',',split(/\s*\,\s*/,$FORM{'v_groups'}));
	$FORM{'p_groups'} = join(',',split(/\s*\,\s*/,$FORM{'p_groups'}));
	$FORM{'pp_groups'} = join(',',split(/\s*\,\s*/,$FORM{'pp_groups'}));
	$FORM{'m_groups'} = join(',',split(/\s*\,\s*/,$FORM{'m_groups'}));
	if ($FORM{'type'} eq "text") {
		if ($FORM{'width'} == 0) { $FORM{'width'} = ""; }
		if ($FORM{'is_numeric'} eq "") { $FORM{'is_numeric'} = 0; }
		if ($FORM{'ubbc'} eq "") { $FORM{'ubbc'} = 0; }
		$FORM{'options'} = "$FORM{'limit_len'}^$FORM{'width'}^$FORM{'is_numeric'}^$FORM{'default'}^$FORM{'ubbc'}";

	} elsif ($FORM{'type'} eq "text_multi") {
		if ($FORM{'rows'} == 0) { $FORM{'rows'} = ""; }
		if ($FORM{'cols'} == 0) { $FORM{'cols'} = ""; }
		if ($FORM{'ubbc'} eq "") { $FORM{'ubbc'} = 0; }
		$FORM{'options'} = "$FORM{'limit_len'}^$FORM{'rows'}^$FORM{'cols'}^$FORM{'ubbc'}";

	} elsif ($FORM{'type'} eq "select") {
		$FORM{'options'} =~ tr/\r//d;
		$FORM{'options'} =~ s~\A[\s\n]+~ \n~;
		$FORM{'options'} =~ s~[\s\n]+\Z~~;
		$FORM{'options'} =~ s~\n\s*\n~\n~g;
		@options = split(/\n/,$FORM{'options'});
		$FORM{'options'} = "";
		foreach (@options) { $FORM{'options'} .= "\^".$_; }
		$FORM{'options'} =~ s/^\^//;

	} elsif ($FORM{'type'} eq "radiobuttons") {
		$FORM{'options'} =~ tr/\r//d;
		$FORM{'options'} =~ s~\A[\s\n]+~~;
		$FORM{'options'} =~ s~[\s\n]+\Z~~;
		$FORM{'options'} =~ s~\n\s*\n~\n~g;
		@options = split(/\n/,$FORM{'options'});
		$FORM{'options'} = "";
		foreach (@options) { $FORM{'options'} .= "\^".$_; }
		$FORM{'options'} =~ s/^\^//;
		if ($FORM{'radiounselect'} eq "") { $FORM{'radiounselect'} = 0; }

	} elsif ($FORM{'type'} eq "spacer") {
		if ($FORM{'visible_in_editprofile'} eq "") { $FORM{'visible_in_editprofile'} = 0; }
		$FORM{'options'} = "$FORM{'hr_or_br'}^$FORM{'visible_in_editprofile'}";

	} elsif ($FORM{'type'} eq "image") {
		if ($FORM{'image_width'} == 0) { $FORM{'image_width'} = ""; }
		if ($FORM{'image_height'} == 0) { $FORM{'image_height'} = ""; }
		$FORM{'options'} = "$FORM{'image_width'}^$FORM{'image_height'}^$FORM{'allowed_extensions'}";
	}

	@fields = @ext_prof_fields;
	$fields[$FORM{'id'}] = "$FORM{'name'}|$FORM{'type'}|$FORM{'options'}|$FORM{'active'}|$FORM{'comment'}|$FORM{'required_on_reg'}|$FORM{'visible_in_viewprofile'}|$FORM{'v_users'}|$FORM{'v_groups'}|$FORM{'visible_in_posts'}|$FORM{'p_users'}|$FORM{'p_groups'}|$FORM{'p_displayfieldname'}|$FORM{'visible_in_memberlist'}|$FORM{'m_users'}|$FORM{'m_groups'}|$FORM{'editable_by_user'}|$FORM{'visible_in_posts_popup'}|$FORM{'pp_users'}|$FORM{'pp_groups'}|$FORM{'pp_displayfieldname'}|$FORM{'radiounselect'}";

	@ext_prof_fields = @fields;

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');

	$yySetLocation = qq~$adminurl?action=ext_admin~;
	&redirectexit;
}

# converts a user's .ext file to Y2 format
sub ext_user_convert {
	my ($pusername, $old_membersdir, @ext_profile, $id) = (shift, shift);
	&is_admin_or_gmod;

	if (-e "$old_membersdir/$pusername.ext") {
		if (&checkfor_DBorFILE("$memberdir/$pusername.vars")) {
			&ext_get_profile($pusername);

			fopen(EXT_FILE, "$old_membersdir/$pusername.ext") || &fatal_error('cannot_open', "$old_membersdir/$pusername.ext");
			@ext_profile = <EXT_FILE>;
			fclose(EXT_FILE);
			chomp @ext_profile;

			$id = 0;
			foreach (@ext_prof_fields) {
				${$uid.$pusername}{'ext_'.$id} = $ext_profile[$id];
				$id++;
			}
			&UserAccount($pusername,"update");
			# don't delete old .ext files anymore, user can do that himself now.
			#&delete_DBorFILE("$old_membersdir/$pusername.ext");
		}
	}
}

# convert a string of usergroup names from the old YaBB format into Y2's new format
sub ext_admin_convert_fixgroupnames {
	my ($input, $done, $j, @groups, $group, $groupid, %checkdoubles) = (shift, 0);

	@groups = split(/\s*\,\s*/,$input);
	for ($j = 0; $j < @groups; $j++) {
		# if groupname is in old format
		if ($groups[$j] ne "Administrator" && $groups[$j] ne "Global Moderator" && $groups[$j] ne "Moderator" && $groups[$j] !~ m/^(?:No)?Post{\d+}$/) {
			# find best matching usergroup
			foreach $groupid (sort { $a <=> $b } keys %NoPost) {
				if ($groups[$j] eq (split(/\|/, (split(/\|/, $NoPost{$groupid}))[0]))[0]) {
					$groups[$j] = "NoPost{$groupid}";
					# check for doubles
					if ($checkdoubles{$groups[$j]} == 1) {
						splice(@groups,$j,1);
						$j--;
						$done = 1;
						last;
					} else {
						$checkdoubles{$groups[$j]} = 1;
					}
				}
			}
			if ($done == 1) { $done = 0; next; }
			foreach $groupid (sort { $b <=> $a } keys %Post) {
				if ($groups[$j] eq (split(/\|/, (split(/\|/, $Post{$groupid}))[0]))[0]) {
					$groups[$j] = "Post{$groupid}";
					# check for doubles
					if ($checkdoubles{$groups[$j]} == 1) {
						splice(@groups,$j,1);
						$done = 1;
						$j--;
						last;
					} else {
						$checkdoubles{$groups[$j]} = 1;
					}
				}
			}
			if ($done == 1) { $done = 0; next; }
		} else {
			$checkdoubles{$groups[$j]} = 1;
		}
		# if still not matching, get rid of it!
		if ($groups[$j] ne "Administrator" && $groups[$j] ne "Global Moderator" && $groups[$j] ne "Moderator" && $groups[$j] !~ m/^(?:No)?Post{\d+}$/) {
			#delete $groups[$j];
			splice(@groups,$j,1);
			$j--;
		}
	}
	join(',', @groups);
}

# converts ALL old .ext files into the the YaBB 2 file format
sub ext_admin_convert {
	my (@contents, $filename, $old_membersdir, $old_vardir, $i);
	&is_admin_or_gmod;

	&fatal_error("", $lang_ext{'converter_no_sql'}) if $use_MySQL;

	$old_membersdir = $FORM{'members'};
	$old_vardir = $FORM{'vars'};

	if (!-e $old_vardir) {
		&fatal_error("", $lang_ext{'converter_missing_vars'});
	}
	if (!-e "$old_vardir/extended_profiles_order.txt") {
		&fatal_error("", $lang_ext{'converter_missing_order'});
	}
	if (!-e "$old_vardir/extended_profiles_fields.txt") {
		&fatal_error("", $lang_ext{'converter_missing_fields'});
	}

	fopen(CONVERTER,"$old_vardir/extended_profiles_order.txt") || &fatal_error('cannot_open', "$old_vardir/extended_profiles_order.txt");
	@ext_prof_order = <CONVERTER>;
	fclose(CONVERTER);
	chomp(@ext_prof_order);

	# copy old extended_profiles_fields and extended_profiles_order files
	fopen(CONVERTER,"$old_vardir/extended_profiles_fields.txt") || &fatal_error('cannot_open', "$old_vardir/extended_profiles_fields.txt");
	@ext_prof_fields = <CONVERTER>;
	fclose(CONVERTER);
	chomp(@ext_prof_fields);

	#check if used membergroups still exist + convert to YaBB's new format
	for ($i = 0; $i < @ext_prof_fields; $i++) {
		my @field = split(/\|/, $ext_prof_fields[$i]);
		$field[8]  = &ext_admin_convert_fixgroupnames($field[8]);
		$field[11] = &ext_admin_convert_fixgroupnames($field[11]);
		$field[15] = &ext_admin_convert_fixgroupnames($field[15]);
		$field[19] = &ext_admin_convert_fixgroupnames($field[19]);
		$ext_prof_fields[$i] = join('|', @field);
	}

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');

	opendir(EXT_DIR, "$old_membersdir");
	@contents = grep {/\.ext$/} readdir(EXT_DIR);
	closedir(EXT_DIR);

	foreach $filename (@contents) {
		$filename =~ s~.ext$~~;
		&ext_user_convert($filename,$old_membersdir);
	}

	$yymain .= $lang_ext{'converter_succeeded'};
	$yytitle = "$lang_ext{'Profiles_Controls'} - $lang_ext{'options_title'}";
	$action_area = "ext_admin";
	&AdminTemplate;
}

1;