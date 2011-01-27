###############################################################################
# RemoveOldTopics.pl                                                          #
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

$removeoldtopicsplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub RemoveOldThreads {
	&is_admin_or_gmod;
	my $maxdays = $FORM{'maxdays'} || $INFO{'maxdays'};
	if ($maxdays !~ /\A[0-9]+\Z/) { &fatal_error("only_numbers_allowed"); }

	&automaintenance('on');

	# Set up the multi-step action
	$time_to_jump = time() + $max_process_time;

	my (@threads,$num,$status,$keep_sticky,%attachfile);
	$date1;
	$date2 = $date;

	$yytitle = "$removemess_txt{'120'} $maxdays";
	$action_area = "deleteoldthreads";
	$yymain .= qq~<br /><b>$removemess_txt{'1'} $maxdays $removemess_txt{'2'}</b><br />~;

	&write_DBorFILE(0,'',$vardir,'oldestmes','txt',($maxdays));

	&get_forum_master;
	require "$admindir/Attachments.pl";

	my @boards = sort( keys %board );
	for (my $j = ($INFO{'nextboard'} || 0); $j < @boards; $j++) {
		my $checkboard = $FORM{ $boards[$j] . 'check' } || $INFO{ $boards[$j] . 'check' };
		if ($checkboard == 1) {
			$keep_sticky = ($FORM{'keep_them'} || $INFO{'keep_them'}) ? 1 : 0;

			@threads = &read_DBorFILE(0,'',$boardsdir,$boards[$j],'txt');

			my $totalthreads = @threads;
			my ($boardname) = split(/\|/, $board{$boards[$j]}, 2);
			$yymain .= qq~<br />$removemess_txt{'3'} <b>$boardname</b> ($totalthreads $removemess_txt{'6'})<br />~;

			next if !$totalthreads;

			my @temparray_1 = ();
			my $tempcount = 0;
			for (my $i = 0; $i < $totalthreads; $i++) {
				($num, undef, undef, undef, $date1, undef, undef, undef, $status) = split(/\|/, $threads[$i]);
				$date1 = sprintf("%010d", $date1);

				if ($i < $INFO{'nextthread'}) {
					push(@temparray_1, "$date1|$threads[$i]");
					next;
				}

				# Check if original thread was sticky
				if ($keep_sticky && $status =~ /s/i) {
					push(@temparray_1, "$date1|$threads[$i]");
					$yymain .= "$num : $removemess_txt{'4'} <br />";
				} else {
					&calcdifference();
					if ($result <= $maxdays) { # If the message is not too old
						push(@temparray_1, "$date1|$threads[$i]");
						$yymain .= "$num = $result $removemess_txt{'122'}<br />";

					} else {
						# remove thread files
						&delete_DBorFILE("$datadir/$num.txt");
						&delete_DBorFILE("$datadir/$num.ctb");
						&delete_DBorFILE("$datadir/$num.mail");
						&delete_DBorFILE("$datadir/$num.poll");
						&delete_DBorFILE("$datadir/$num.polled");

						# delete all attachments of removed topic later
						$attachfile{$num} = undef;

						$tempcount++;

						$yymain .= "$num = $result $removemess_txt{'122'} ($removemess_txt{'123'})<br />&nbsp; &nbsp; &nbsp;$num : $removemess_txt{'7'}<br />";
					}
				}

				if (time() > $time_to_jump && ($i + 1) < $totalthreads) {
					$i++;
					for (my $x = $i; $x < $totalthreads; $x++) {
						(undef, undef, undef, undef, $date1, undef) = split(/\|/, $threads[$x], 6);
						$date1 = sprintf("%010d", $date1);
						push(@temparray_1, "$date1|$threads[$x]");
					}
					&write_DBorFILE(0,'',$boardsdir,$boards[$j],'txt',(map { s/^.*?\|//; $_; } sort { lc($b) cmp lc($a) } @temparray_1));

					# remove attachments of removed topics
					&RemoveAttachments(\%attachfile);

					$i -= $tempcount;
					$INFO{'total_rem_count'} += $tempcount;
					&RemoveOldThreadsText($j,$i,$INFO{'total_rem_count'});
				}
			}

			&write_DBorFILE(0,'',$boardsdir,$boards[$j],'txt',(map({ s/^.*?\|//; $_; } sort({ lc($b) cmp lc($a) } @temparray_1) )));

			&BoardCountTotals($boards[$j]);
			$INFO{'total_rem_count'} += $tempcount;
			$INFO{'nextthread'} = 0;
		}
	}

	# remove attachments of removed topics
	&RemoveAttachments(\%attachfile);

	&automaintenance('off');

	$yymain .= qq~<br /><b>$removemess_txt{'5'} $INFO{'total_rem_count'} $removemess_txt{'6'}.</b>~;
	&AdminTemplate;
}

sub RemoveOldThreadsText {
			my ($j,$i,$total) = @_;

			$INFO{'st'} = int($INFO{'st'} + time() - $time_to_jump + $max_process_time);

			my $query;
			foreach (keys %FORM) {
				$query .= qq~;$_=$FORM{$_}~ if $_ =~ /check$/;
			}
			foreach (keys %INFO) {
				$query .= qq~;$_=$INFO{$_}~ if $_ =~ /check$/;
			}

			$yymain = qq~<b>$removemess_txt{'200'} <i>$max_process_time $admin_txt{'533'}</i>.<br />
			$removemess_txt{'201'} <i>~ . (time() - $time_to_jump + $max_process_time) . qq~ $admin_txt{'533'}</i>.<br />
			$removemess_txt{'202'} <i>~ . int(($INFO{'st'} + 60)/60) . qq~ $admin_txt{'537'}</i>.<br />
			<br />$total $removemess_txt{'203'}.</b><br />
			<p id="memcontinued">$removemess_txt{'210'} <a href="$adminurl?action=removeoldthreads;maxdays=$FORM{'maxdays'}$INFO{'maxdays'};keep_them=$FORM{'keep_them'}$INFO{'keep_them'};nextboard=$j;st=$INFO{'st'};nextthread=$i;total_rem_count=$total$query" onclick="PleaseWait();">$removemess_txt{'211'}</a>...<br />$removemess_txt{'212'}
			</p>
			$yymain

			<script type="text/javascript">
			<!--
				function PleaseWait() {
					document.getElementById("memcontinued").innerHTML = '<font color="red"><b>$removemess_txt{'213'}</b></font>';
				}

				function stoptick() { stop = 1; }

				stop = 0;
				function membtick() {
					if (stop != 1) {
						PleaseWait();
						location.href="$adminurl?action=removeoldthreads;maxdays=$FORM{'maxdays'}$INFO{'maxdays'};keep_them=$FORM{'keep_them'}$INFO{'keep_them'};nextboard=$j;st=$INFO{'st'};nextthread=$i;total_rem_count=$total$query";
					}
				}

				setTimeout("membtick()",2000);
			// -->
			</script>

			~;

			&AdminTemplate;
}

1;