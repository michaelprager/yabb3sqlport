###############################################################################
# Mailer.pl                                                                   #
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

$mailerplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub sendmail {
	my ($to, $subject, $message, $from, $mailcharset) = @_;

	# Do a FromHTML here for $to, and for $mbname
	# Just in case has special chars like & in addresses
	&FromHTML($to);
	&FromHTML($mbname);

	# Change commas to HTML entity - ToHTML doesn't catch this
	# It's only a problem when sending emails, so no change to ToHTML.
	$mbname =~ s/,/&#44;/ig;

	$charsetheader = $mailcharset ? $mailcharset : $yycharset;

	if (!$from) {
		$from = $webmaster_email;
		$fromheader = "$mbname <$from>";
	} else {
		$fromheader = $from;
	}

	if (!$to) {
		$to = $webmaster_email;
		$toheader = "$mbname $smtp_txt{'555'} <$to>";
	} else {
		$to =~ s/[ \t]+/, /g;
		$toheader = $to;
	}

	$message =~ s/^\./../m;
	$message =~ s/[\r\n]/\n/g;

	if ($mailtype == 0) {
		open(MAIL, "|$mailprog -t");
		print MAIL "To: $toheader\n";
		print MAIL "From: $fromheader\n";
		print MAIL "X-Mailer: YaBB Sendmail\n";
		print MAIL "Subject: $subject\n";
		print MAIL "Content-Type: text/plain\; charset=$charsetheader\n\n";
		$message =~ s/\r\n/\n/g;
		print MAIL "$message\n";
		close(MAIL);
		return 1;

	} elsif ($mailtype == 1) {
		$smtp_to = $to;
		$smtp_from = $from;
		$smtp_message = $message;
		$smtp_subject = $subject;
		$smtp_charset = $charsetheader;
		require "$sourcedir/Smtp.pl";
		&use_smtp;

	} elsif ($mailtype == 2 || $mailtype == 3) {
		my $smtp;
		my @arg = ("$smtp_server", Hello => "$smtp_server", Timeout => 30);
		if ($mailtype == 2) {
			eval q^
				eval 'use Net::SMTP;';
				push(@arg, Debug => 0);
				$smtp = Net::SMTP->new(@arg) || die "Unable to create Net::SMTP object. Server: '$smtp_server'\n\n" . $!;
			^;
		} else {
			eval q^
				use Net::SMTP::TLS;';
				my $port = 25;
				if ($smtp_server =~ s/:(\d+)$//) { $port = $1; }
				push(@arg, Port => $port);
				push(@arg, User => "$authuser") if $authuser;
				push(@arg, Password => "$authpass") if $authpass;
				$smtp = Net::SMTP::TLS->new(@arg) || die "Unable to create Net::SMTP::TLS object. Server: '$smtp_server', port '$port'\n\n" . $!;
			^;
		}
		if ($@) { &fatal_error("net_fatal","$error_txt{'error_verbose'}: $@"); }

		eval q^
			$smtp->mail($from); 
			foreach (split(/, /, $to)) { $smtp->to($_); }
			$smtp->data(); 
			$smtp->datasend("To: $toheader\r\n"); 
			$smtp->datasend("From: $fromheader\r\n"); 
			$smtp->datasend("X-Mailer: YaBB Net::SMTP\r\n"); 
			$smtp->datasend("Subject: $subject\r\n");
			$smtp->datasend("Content-Type: text/plain\; charset=$charsetheader\r\n");
			$smtp->datasend("\r\n");
			$smtp->datasend($message);
			$smtp->dataend();
			$smtp->quit();
		^;
		if ($@) { &fatal_error("net_fatal","$error_txt{'error_verbose'}: $@"); }
		return 1;

	} elsif ($mailtype == 4) {
		# Dummy mail engine
		$message =~ s/\r\n/\n/g;
		&write_DBorFILE(1,MAIL,$vardir,'mail','log',(
			&read_DBorFILE(0,MAIL,$vardir,'mail','log'),
			"Mail sent at " . scalar localtime() . "\n",
			"To: $toheader\n",
			"From: $fromheader\n",
			"X-Mailer: YaBB Sendmail\n",
			"Subject: $subject\n\n",
			"$message\n",
			"End of Message\n\n")
		);
		return 1;
	}
}

# Before &sendmail is called, the message MUST be run through here.
# First argument is the message
# Second argument is a hashref to the replacements
# Example:
#  $message = qq~Hello, {yabb username}! The answer is {yabb answer}!~;
#  $message = &template_email($message, {username => $username, answer => 42});
# Result (with $username being the actual username):
#  Hello, $username! The answer is 42!
sub template_email {
	my ($message, $info) = @_;
	foreach my $key (keys(%$info)) { $message =~ s/(<|{)yabb $key(}|>)/$info->{$key}/g; }
	$message =~ s/(<|{)yabb scripturl(}|>)/$scripturl/g;
	$message =~ s/(<|{)yabb adminurl(}|>)/$adminurl/g;
	$message =~ s/(<|{)yabb mbname(}|>)/$mbname/g;
	$message;
}

1;