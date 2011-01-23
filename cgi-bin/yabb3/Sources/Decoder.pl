###############################################################################
# Decoder.pl                                                                  #
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

$decoderplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub scramble {
	my ($input, $user) = @_;
	if ($user eq "") { return; }
	# creating a codekey based on userid
	my $carrier = "";
	for (my $n = 0; $n < length $user; $n++) {
		my $ascii = substr($user, $n, 1);
		$ascii = ord($ascii);
		$carrier .= $ascii;
	}
	while (length($carrier) < length($input)) { $carrier .= $carrier; }
	$carrier = substr($carrier, 0, length($input));
	my $scramble = &encode_password(rand(100));
	for ($n = 0; $n < 10; $n++) {
		$scramble .= &encode_password($scramble);
	}
	$scramble =~ s/\//y/g;
	$scramble =~ s/\+/x/g;
	$scramble =~ s/\-/Z/g;
	$scramble =~ s/\:/Q/g;

	# making a mess of the input
	my $lastvalue = 3;
	for (my $n = 0; $n < length $input; $n++) {
		$value = (substr($carrier, $n, 1)) + $lastvalue + 1;
		$lastvalue = $value;
		substr($scramble, $value, 1) = substr($input, $n, 1); # does this make sense??? (deti)
	}

	# adding code length to code
	my $len = length($input) + 65;
	$scramble .= chr($len);
	return $scramble;
}

sub descramble {
	my ($input, $user) = @_;
	if ($user eq ""){ return; }
	# creating a codekey based on userid
	my $carrier = "";
	for (my $n = 0; $n < length($user); $n++) {
		my $ascii = substr($user, $n, 1);
		$ascii = ord($ascii);
		$carrier .= $ascii;
	}
	my $orgcode   = substr($input, length($input) - 1, 1);
	my $orglength = ord($orgcode);

	while (length($carrier) < $orglength - 65) { $carrier .= $carrier; }
	$carrier = substr($carrier, 0, length($input));

	my $lastvalue  = 3;
	my $descramble = "";

	# getting code length from encrypted input
	for (my $n = 0; $n < $orglength - 65; $n++) {
		my $value = (substr($carrier, $n, 1)) + $lastvalue + 1;
		$lastvalue = $value;
		$descramble .= substr($input, $value, 1);
	}
	$descramble;
}

sub validation_check {
	my $checkcode = $_[0];
	&fatal_error("no_verification_code") if $checkcode eq '';
	&fatal_error("invalid_verification_code") if $checkcode !~ /\A[0-9A-Za-z]+\Z/;
	&fatal_error("wrong_verification_code") if &testcaptcha($FORM{"sessionid"}) ne $checkcode;
}

sub validation_code {
	# set the max length of the shown verification code
	if (!$codemaxchars || $codemaxchars < 3) { $codemaxchars = 3; }
	$codemaxchars2 = $codemaxchars + int(rand(2));
	## Generate a random string
	$captcha = &keygen($codemaxchars2,$captchastyle);
	## now we are going to spice the captcha with the formsession
	$sessionid = &scramble ($captcha,$masterkey);
	chomp $sessionid;

	$showcheck .= qq~<img src="$scripturl?action=$randaction;$randaction=$sessionid" border="0" alt="" /><input type="hidden" name="sessionid" value="$sessionid" />~;
	return $sessionid;
}

sub testcaptcha {
	my $testcode = $_[0];
	chomp $testcode;
	## now it is time to decode the session and see if we have a valid code ##
	my $out = &descramble($testcode,$masterkey);
	chomp $out;
	return $out;
}

sub convert {
	require "$sourcedir/Captcha.pl";
	$captcha = &testcaptcha($INFO{$randaction});
	&captcha($captcha);
}

1;