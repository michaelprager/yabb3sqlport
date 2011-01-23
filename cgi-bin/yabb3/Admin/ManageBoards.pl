###############################################################################
# ManageBoards.pl                                                             #
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

$manageboardsplver = 'YaBB 3.0 Beta $Revision: 100 $';
if ($action eq 'detailedversion') { return 1; }

sub ManageBoards {
	&is_admin_or_gmod;
	&LoadBoardControl;
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	if ($INFO{'action'} eq 'managecats') {
		$colspan = qq~colspan="2"~;
		$add = $admin_txt{'47'};
		$act = 'catscreen';
		$manage = qq~<a href="$adminurl?action=reordercats"><img src="$imagesdir/reorder.gif" alt="$admin_txt{'829'}" title="$admin_txt{'829'}" border="0" style="vertical-align: middle;" /></a> &nbsp;<b>$admin_txt{'49'}</b>~;
		$managedescr = $admin_txt{'678'};
		$act2 = 'addcat';
		$action_area = 'managecats';
	} else {
		$colspan = qq~colspan="4"~;
		$add = $admin_txt{'50'};
		$act = 'boardscreen';
		$manage = qq~<img src="$imagesdir/cat.gif" alt="" border="0" style="vertical-align: middle;" /> &nbsp;<b>$admin_txt{'51'}</b>~;
		$managedescr = $admin_txt{'677'};
		$act2 = 'addboard';
		$action_area = 'manageboards';
	}
	$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript">
	<!--
		function checkSubmit(where){ 
			var something_checked = false;
			for (i=0; i<where.elements.length; i++){
				if(where.elements[i].type == "checkbox"){
					if(where.elements[i].checked == true){
						something_checked = true;
					}
				}
			}
			if(something_checked == true){
				if (where.baction[1].checked == false){
					return true;
				}
				if (confirm("$admin_txt{'617'}")) {
					return true;
				} else {
					return false; 
				}
			} else {
				alert("$admin_txt{'5'}");
				return false;
			}
		}
		
		function editSingle(board) {
			var where = document.getElementById("whattodo");
			for (i=0; i<where.elements.length; i++){
				if(where.elements[i].type == "checkbox"){
					if(where.elements[i].getAttribute("name") == board){
						where.elements[i].checked = true;
					} else {
						where.elements[i].checked = false;
					}
				}
			}
			document.getElementById("baction").checked = true;
			where.submit();
		}
		
		function delSingle(board) {
			var where = document.getElementById("whattodo");
			for (i=0; i<where.elements.length; i++){
				if(where.elements[i].type == "checkbox"){
					if(where.elements[i].getAttribute("name") == board){
						where.elements[i].checked = true;
					} else {
						where.elements[i].checked = false;
					}
				}
			}
			document.getElementById("delme").checked = true;
			if (confirm("$admin_txt{'617'}")) {
				where.submit();
			}
		}
	//-->
</script>
<form name="whattodo" id="whattodo" action="$adminurl?action=$act" onSubmit="return checkSubmit(this);" method="post">
 <div style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4" class="bordercolor">
     <tr valign="middle">
       <td align="left" class="titlebg" $colspan>
		 $manage
	   </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="windowbg2" $colspan><br />
		  $managedescr<br /><br />
	   </td>
     </tr>
   </table>
~;
	foreach $catid (@categoryorder) {
		@bdlist = split(/,/, $cat{$catid});
		($curcatname, $catperms) = split(/\|/, $catinfo{"$catid"});
		&ToChars($curcatname);

		if ($INFO{"action"} eq "managecats") {
			$tempcolspan = "";
			$tempclass   = "windowbg2";
			$temphrefclass = "";
		} else {
			$tempcolspan = qq~colspan="4"~;
			$tempclass   = "catbg";
			$temphrefclass = qq~class="catbg a"~;
		}

		$yymain .= qq~
   <table width="100%" cellspacing="1" cellpadding="4" class="bordercolor" style="margin-top: 5px;">
     <tr valign="middle">
       <td align="left" height="25" class="$tempclass" valign="middle" $tempcolspan>
		<a href="$adminurl?action=reorderboards;item=$catid" $temphrefclass><img src="$imagesdir/reorder.gif" alt="$admin_txt{'832'}" title="$admin_txt{'832'}" border="0" style="vertical-align: middle;" /></a> &nbsp;<b>$curcatname</b>
	   </td>
~;
		if ($INFO{"action"} eq "managecats") {
			$yymain .= qq~
    	<td class="windowbg" height="25" width="10%" align="center"><input type="checkbox" name="yitem_$catid" value="1" /></td>~;
		}

		$yymain .= qq~
     </tr>
   </table>~;
		unless ($INFO{"action"} eq "managecats") {
			# recursive loop to display all sub boards
			
			my $indent = -3;
			&show_boards(@bdlist);

			sub show_boards {
				my @brdlist = @_;
				$indent += 3;
				foreach $curboard (@brdlist) {
					($boardname, $boardperms, $boardview) = split(/\|/, $board{$curboard});
					$boardname =~ s/\&quot\;/&#34;/g;
					&ToChars($boardname);
					$descr = ${$uid.$curboard}{'description'};
					$descr =~ s~\<br />~\n~g;
					my $bicon = "";
					if(${$uid.$curboard}{'pic'}) { $bicon = ${$uid.$curboard}{'pic'}; }
					if ($bicon =~ /\//i) { $bicon = qq~ <img src="$bicon" alt="" border="0" /> ~; }
					elsif ($bicon) { $bicon = qq~ <img src="$imagesdir/$bicon" alt="" border="0" /> ~; }
					if (${$uid.$curboard}{'ann'} == 1)  { $bicon = qq~ <img src="$imagesdir/ann.gif" alt="$admin_txt{'64g'}" title="$admin_txt{'64g'}" border="0" />~; }
					if (${$uid.$curboard}{'rbin'} == 1) { $bicon = qq~ <img src="$imagesdir/recycle.gif" alt="$admin_txt{'64i'}" title="$admin_txt{'64i'}" border="0" />~; }
					$convertstr = $descr;
					unless($convertstr =~ /<.+?>/) { # Don't cut it if there's HTML in it.
						$convertcut = 60;
						&CountChars;
					}
					my $descr = $convertstr;
					&ToChars($descr);
					if ($cliped) { $descr .= "..."; }
					
					my $tmpwidth = 100 - $indent;
					my $tmpwidth2 = 90 - $indent;
					
					my @children = split(/\|/, $subboard{$curboard});
					
					$reorder_subs = @children > 0 ? qq~<a href="$adminurl?action=reorderboards;item=$curboard;subboards=1"><img src="$imagesdir/reorder_sub.gif" alt="$admin_txt{'252'}" title="$admin_txt{'252'}" border="0" /></a>~ : "";
					
					my $del_txt = $admin_txt{'251'};
					my $edit_txt = $admin_txt{'253'};
					if(${$uid.$curboard}{'parent'}) {
						$del_txt =~ s/{(.*?)}/$admin_txt{'254'}$1/g;
						$edit_txt =~ s/{(.*?)}/$admin_txt{'254'}$1/g;
					} else {
						$del_txt =~ s/{(.*?)}/$1/g;
						$edit_txt =~ s/{(.*?)}/$1/g;
					}
					
					$yymain .= qq~
<table width="~ . $tmpwidth . qq~%" cellspacing="1" cellpadding="4" style="margin: 1px; margin-left:~ . $indent . qq~%" class="bordercolor">
  <tr>
    <td class="windowbg2" width="~ . $tmpwidth2 . qq~%" align="left">
    	$boardname
    	<div style="position:relative; display:inline; float:right;">
    	<a href="$adminurl?action=addboard;parent=$curboard;category=$catid"><img src="$imagesdir/add_sub.gif" alt="$admin_txt{'250'}" title="$admin_txt{'250'}" border="0" /></a>
    	<a href="javascript:editSingle('yitem_$curboard')"><img src="$imagesdir/edit_sub.gif" alt="$edit_txt" title="$edit_txt" border="0" /></a>
    	<a href="javascript:delSingle('yitem_$curboard')"><img src="$imagesdir/delete_sub.gif" alt="$del_txt" title="$del_txt" border="0" /></a>
    	~ . $reorder_subs . qq~
    	</div>
    </td>
    <td class="windowbg2" width="5%" align="center">$bicon</td>
    <td class="titlebg" width="5%" align="center"><input type="checkbox" name="yitem_$curboard" value="1" /></td>
  </tr>
  <tr>
    <td class="windowbg" colspan="3" width="100%" align="left">$descr</td>
  </tr>
</table>
~;
					if($subboard{$curboard}) { &show_boards(@children); }
				}
				$indent -= 3;
			}
		}
	}

	$yymain .= qq~
<table width="100%" cellspacing="1" cellpadding="4" class="bordercolor" style="margin-top: 3px">
  <tr>
      <td class="catbg" width="100%" align="center" valign="middle" $colspan> <label for="baction">$admin_txt{'52'}</label>
    	<input type="radio" name="baction" id="baction" value="edit" checked="checked" /> $admin_txt{'53'} 
    	<input type="radio" name="baction" id="delme" value="delme" /> $admin_txt{'54'} 
    	<input type="submit" value="$admin_txt{'32'}" class="button" /></td>
  </tr>
</table>
</div>
</form>
<br />
<form name="diff" id="diff" action="$adminurl?action=$act2" method="post">

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
  <tr>
    <td class="catbg" align="center" valign="middle"><label for="amount"><b>$add: </b></label>
	<input type="text" name="amount" id="amount" value="3" size="2" maxlength="2" /> 
	<input type="submit" value="$admintxt{'45'}" class="button" />
	</td>
  </tr>
   </table>
 </div>
</form>
~;
	$yytitle = "$admintxt{'a4_title'}";
	&AdminTemplate;
}

sub BoardScreen {
	&is_admin_or_gmod;
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	$i = 0;
	while ($_ = each(%FORM)) {
		if ($FORM{$_} && $_ =~ /^yitem_(.+)$/) {
			$editboards[$i] = $1;
			$i++;
		}
	}
	$i = 1;
	foreach $thiscat (@categoryorder) {
		my @catboards = split(/,/, $cat{$thiscat});
		
		# make an array of all sub boards recursively
		&recursive_boards(@catboards);
		sub recursive_boards {
			push(@theboards, @_);
			foreach $childbd (@_) {
				if($subboard{$childbd}) { &recursive_boards(split(/\|/,$subboard{$childbd})); }
			}
		}
		
		for (my $z = 0; $z < @theboards; $z++) {
			my $found = 0;
			for (my $j = 0; $j < @editboards; $j++) {
				if ($editboards[$j] eq $theboards[$z]) {
					$editbrd[$i] = $theboards[$z];
					$found = 1;
					$i++;
					splice(@editboards,$j,1);
					last;
				}
			}
		}
	}
	if    ($FORM{'baction'} eq "edit")  { &AddBoards(@editbrd); }
	elsif ($FORM{'baction'} eq "delme") {
		shift(@editbrd);
		if (!$mloaded) { require "$boardsdir/forum.master"; }
		foreach my $bd (@editbrd) {
			# Remove Board form category it belongs to unless it's a sub board, then it's not in the cat list
			if(!${$uid.$bd}{'parent'}) {
				$category = ${$uid.$bd}{'cat'};
				@bdlist = split(/,/, $cat{$category});
				my $c = 0;
				foreach (@bdlist) {
					if ($_ eq $bd) { splice(@bdlist, $c, 1); last; }
					$c++;
				}
				$cat{$category} = join(',', &undupe(@bdlist));
			} else { # if it has a parent, remove it from it's parent's child board list
				my @bdlist = split(/\|/, $subboard{${$uid.$bd}{'parent'}});

				# Remove Board from old parent board
				my $k = 0;
				foreach (@bdlist) {
					if ($bd eq $_) { splice(@bdlist, $k, 1); }
					$k++;
				}
				$subboard{${$uid.$bd}{'parent'}} = join('|', @bdlist);
			}
			
			# remove the $subboard{} hash that contains children list, since it's a parent board and move children up
			if($subboard{$bd}) {
				foreach $childbd (split(/\|/,$subboard{$bd})) {
					# if this one has a parent board, move it's children up to that, otherwise to category.
					if(${$uid.$bd}{'parent'}) {
						if($subboard{${$uid.$bd}{'parent'}}) {
							$subboard{${$uid.$bd}{'parent'}} .= qq~|$childbd~;
						} else {
							$subboard{${$uid.$bd}{'parent'}} = $childbd;
						}
						${$uid.$childbd}{'parent'} = ${$uid.$bd}{'parent'};
					} else {
						$cat{${$uid.$bd}{'cat'}} .= ",$childbd";
						${$uid.$childbd}{'parent'} = "";
					}
					push(@del_updateparent, $childbd);
				}
				delete $subboard{$bd};
			}
			delete $board{$bd};
			$yymain .= qq~$admin_txt{'55'}$bd <br />~;
		}


		# Actual deleting
		&DeleteBoards(@editbrd);
		&Write_ForumMaster;

	} else {
		&fatal_error("no_action","$FORM{'baction'}");
	}

	$action_area = "manageboards";
	&AdminTemplate;
}

sub DeleteBoards {
	&is_admin_or_gmod;

	my @oldcontrols = &read_DBorFILE(0,FORUMCONTROL,$boardsdir,'forum','control');
	foreach $board (@_) {
		@messages = &read_DBorFILE(0,'',$boardsdir,$board,'txt');
		foreach $curmessage (@messages) {
			my ($id, undef) = split(/\|/, $curmessage, 2);
			&delete_DBorFILE("$datadir/$id.txt");
			&delete_DBorFILE("$datadir/$id.mail");
			&delete_DBorFILE("$datadir/$id.ctb");
			&delete_DBorFILE("$datadir/$id.data");
			&delete_DBorFILE("$datadir/$id.poll");
			&delete_DBorFILE("$datadir/$id.polled");
		}
		for (my $cnt = 0; $cnt < @oldcontrols; $cnt++) {
			my $oldboard;
			(undef, $oldboard, undef) = split(/\|/, $oldcontrols[$cnt], 3);
			$yydebug .= "$cnt   $oldboard \n";
			if ($oldboard eq $board) {
				$oldcontrols[$cnt] = "";
				$yydebug .= "\$board{\"$oldboard\"}";
				delete $board{"$board"};
				last;
			}
		}
		&delete_DBorFILE("$boardsdir/$board.txt");
		&delete_DBorFILE("$boardsdir/$board.ttl");
		&delete_DBorFILE("$boardsdir/$board.poster");
		&delete_DBorFILE("$boardsdir/$board.mail");

		my @buffer = &read_DBorFILE(0,ATM,$vardir,'attachments','txt');
		my ($amcurrentboard,$amfn);
		for (my $a = 0; $a < @buffer; $a++) {
			(undef, undef, undef, undef, $amcurrentboard, undef, undef, $amfn, undef) = split(/\|/, $buffer[$a]);
			if ($amcurrentboard eq $board) {
				$buffer[$a] = '';
				&delete_DBorFILE("$upload_dir/$amfn");
			}
		}
		&write_DBorFILE(0,ATM,$vardir,'attachments','txt',@buffer);

		&BoardTotals("delete", $board);
	}

	# Update parents for subboards that had a parent deleted.
	if(@del_updateparent) {
		for (my $cnt = 0; $cnt < @oldcontrols; $cnt++) {
			my ($oldcat,$oldboard,$pic,$bdescription,$moderators,$moderatorgroups,$topicperms,$replyperms,$pollperms,$zero,$membergroups,$ann,$rbin,$att,$minage,$maxage,$gender,$canpost,$parent) = split(/\|/, $oldcontrols[$cnt]);

			foreach my $changedboard (@del_updateparent) {
				if ($changedboard eq $oldboard) {
					$oldcontrols[$cnt] = qq~$oldcat|$oldboard|$pic|$bdescription|$moderators|$moderatorgroups|$topicperms|$replyperms|$pollperms|$zero|$membergroups|$ann|$rbin|$att|$minage|$maxage|$gender|$canpost|${$uid.$changedboard}{'parent'}\n~;
					last;
				}
			}
		}
	}
	
	&write_DBorFILE(0,FORUMCONTROL,$boardsdir,'forum','control',sort(grep { $_; } @oldcontrols));

	@forum_control = &read_DBorFILE(0,'',$boardsdir,'forum','control');
}

sub AddBoards {
	my @editboards = @_;
	&is_admin_or_gmod;
	$addtext = $admin_txt{'50'};
	if ($INFO{'action'} eq 'boardscreen') { $FORM{'amount'} = $#editboards; $addtext = $admin_txt{'50a'}; }
	if ($INFO{'parent'}) {
		$FORM{'amount'} = 1;
	}
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	&LoadBoardControl;
	
	# build recursive drop down of boards in each category for selecting parent board
	foreach $thiscat (@categoryorder) {
		my @catboards = split(/\,/, $cat{$thiscat});
		my $indent = -2;
		$catboardlist{$thiscat} = qq~||~;

		&get_subboards(@catboards);
		
		$catboardlist_js .= qq~
			catboardlist['$thiscat'] = "$catboardlist{$thiscat}";
		~;
	}
	
	sub get_subboards {
		$indent += 2;
		foreach $childbd (@_) {
			my $dash;
			if($indent > 0) { $dash = "-"; }
			($chldboardname, undef, undef) = split(/\|/, $board{"$childbd"});
			$catboardlist{$thiscat} .= qq~$childbd|~ . (" " x $indent) . ($dash x ($indent / 2)) . qq~ $chldboardname|~;
			if($subboard{$childbd}) {
				&get_subboards(split(/\|/,$subboard{$childbd}));
			}
		}
		$indent -= 2;
	}
	
	$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript">
<!--
var copyValues = new Array();
var copyList = new Array();

var catboardlist = new Array();
$catboardlist_js

// this function removes an entry from the IM multi-list
function removeUser(oElement) {
	var oList = oElement.options;
	var noneSelected = 1;

	for (var i = 0; i < oList.length; i++) {
		if(oList[i].selected) noneSelected = 0;
	}
	if(noneSelected) return false;

	var indexToRemove = oList.selectedIndex;
	if (confirm("$selector_txt{'remove'}"))
		{oElement.remove(indexToRemove);}
}
// this function forces all users listed in moderators to be selected for processing
function selectNames(total) {
	for(var x = 1; x <= total; x++) {
	var oList = document.getElementById('moderators'+x)
	for (var i = 0; i < oList.options.length; i++)
		{oList.options[i].selected = true;}
	}
}
// allows copying one or multiple items from moderators list
function copyNames(num) {
	copyList = new Array();
	copyValues = new Array();
	var oList = document.getElementById('moderators'+num).options;
	for (var i = 0; i < oList.length; i++) {
		if(oList[i].selected == true) {
			copyList[copyList.length] = oList[i].text;
			copyValues[copyValues.length] = oList[i].value;
		}
	}
}
// allows pasting from previously copied moderator list items
function pasteNames(num,total) {
	var found = false;
	var oList = null;
	var which = 0;
	if(copyList.length != 0) {
		for(var x = 0; x < total; x++) {
			which = num + x;
			oList = document.getElementById('moderators'+which).options;
			for (var e = 0; e < copyList.length; e++) {
				found = false;
				for (var i = 0; i < oList.length; i++) {
					if(oList[i].value == copyValues[e] || oList[i].text == copyList[e]) {
						found = true;
						break;
					}
				}
				if(found == false) {
					if(navigator.appName=="Microsoft Internet Explorer") {
						document.getElementById('moderators'+which).add(new Option(copyList[e],copyValues[e]));
					} else {
						document.getElementById('moderators'+which).add(new Option(copyList[e],copyValues[e]),null);
					}
				}
			}
		}
	}
}
// updates parent drop down list when new category is selected
function updateParent(cat, board, id) {
	var parentsel = document.getElementById("parent" + id);
	var insertbds = catboardlist[cat].split("|");
	
	clearSelect(parentsel);
	for (var j = 1; j < insertbds.length; j += 2) {
		var op;
		if(navigator.appName=="Microsoft Internet Explorer") {
			op = new Option(insertbds[j],insertbds[j-1]);
		} else {
			op = new Option(insertbds[j],insertbds[j-1],null);
		}
		if(insertbds[j-1] == board) {
			op.style.backgroundColor = "#ffbbbb";
		}
		op.value = insertbds[j-1];
		parentsel.add(op);
	}
}
// changes the parent board dropdown to whatever it should be, otherwise default is the first category's set of boards
function selectParentBoard() {
	for (var i = 1; i <= editbrds.length - 1; i++) {
		var parentsel = document.getElementById("parent" + i);
		
		var bdinfo = editbrds[i].split("|");
		var insertbds;
		
		if(bdinfo[0]) {
			insertbds = catboardlist[bdinfo[0]].split("|");
		} else {
			insertbds = catboardlist[document.getElementById("cat" + i).value].split("|");
		}

		clearSelect(parentsel);
		for (var j = 1; j < insertbds.length; j += 2) {
			var op = new Option(insertbds[j],insertbds[j-1]);
			if(insertbds[j-1] == bdinfo[1]) {
				op.style.backgroundColor = "#ffbbbb";
			}
			if(insertbds[j-1] == bdinfo[2]) {
				op.selected = true;
			}
			op.value = insertbds[j-1];
			if(navigator.appName=="Microsoft Internet Explorer") {
				parentsel.add(op);
			} else {
				parentsel.add(op,null);
			}
		}
	}
}
// clear a select box
function clearSelect(sel) {
	for (var i = sel.options.length - 1; i >= 0 ; i--) {
		sel.options[i] = null;
	}
}
// make sure we don't select a board and decide to move it to itself....
function checkParent(id, board) {
	var parent = document.getElementById("parent" + id).value;
	if(parent == board) {
		alert("$admin_txt{'735'}");
	}
}
//-->
</script>
<form name="boardsadd" id="boardsadd" action="$adminurl?action=addboard2" method="post" onsubmit="selectNames($FORM{'amount'});">
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table border="0" align="center" cellspacing="1" cellpadding="4" width="100%">
  <tr>
    <td class="titlebg" colspan="5" align="left">
    <img src="$imagesdir/cat.gif" alt="" border="0" />
    <b>$addtext</b></td>
  </tr><tr>
      <td class="windowbg2" colspan="5" align="left"><br />$admin_txt{'57'}<br /><br /></td>
  </tr>
</table>
</div>
<br />
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table border="0" align="center" cellspacing="1" cellpadding="4" width="100%">
~;

	# Check if and which board are set for announcements or recycle bin
	# Start Looping through and repeating the board adding wherever needed
	$istart    = 0;
	$annexist  = "";
	$rbinexist = "";

	for ($i = 1; $i != $FORM{'amount'} + 1; $i++) {
		# differentiate between edit or add boards
		if ($editboards[$i] eq "" && $INFO{"action"} eq "boardscreen") { next; }
		if ($INFO{"action"} eq "boardscreen") {
			$id = $editboards[$i];
		} else {
			$boardtext = "$admin_txt{'58'} $i:";
		}
		
		# print javascript hash of board names and their equivalent category
		if(!$INFO{'parent'}) {
			$brd_javascript .= qq~editbrds[$i] = "${$uid.$editboards[$i]}{'cat'}|$editboards[$i]|${$uid.$editboards[$i]}{'parent'}";\n~;
		} else {
			$brd_javascript .= qq~editbrds[$i] = "$INFO{'category'}||$INFO{'parent'}";\n~;
		}
		
		my $boardcat = ${$uid.$editboards[$i]}{'cat'};
		foreach $catid (@categoryorder) {
			@bdlist = split(/,/, $cat{$catid});
			($curcatname, $catperms) = split(/\|/, $catinfo{"$catid"});
			if ($INFO{"action"} eq "boardscreen" || $INFO{'parent'}) {
				if ($catid eq $boardcat || $catid eq $INFO{'category'}) { $selected = qq~selected="selected" ~; }
				else { $selected = ""; }
			}
			&ToChars($curcatname);
			$catsel{$i} .= qq~<option value="$catid"$selected>$curcatname</option>~;
		}
		$catsel .= qq~</select>~;
		if ($istart == 0) { $istart = $i; }

		($boardname, $boardperms, $boardview) = split(/\|/, $board{"$id"});
		&ToChars($boardname);
		if ($INFO{"action"} eq "boardscreen") { $boardtext = $boardname; }
		$boardpic    = ${$uid.$editboards[$i]}{'pic'};
		$description = ${$uid.$editboards[$i]}{'description'};
		$description =~ s~<br />~\n~g;
		&ToChars($description);
		$moderators      = ${$uid.$editboards[$i]}{'mods'};
		$moderatorgroups = ${$uid.$editboards[$i]}{'modgroups'};
		$boardminage     = ${$uid.$editboards[$i]}{'minageperms'};
		$boardmaxage     = ${$uid.$editboards[$i]}{'maxageperms'};
		$boardgender     = ${$uid.$editboards[$i]}{'genderperms'};
		$genselect       = qq~<select name="gender$i" id="gender$i">~;
		$gentag[0]       = "";
		$gentag[1]       = "M";
		$gentag[2]       = "F";
		$gentag[3]       = "B";
		foreach $genlabel (@gentag) {
			$gentext = "99";
			$gentext .= $genlabel;
			if ($genlabel eq $boardgender) {
				$genselect .= qq~<option value="$genlabel" selected="selected">$admin_txt{$gentext}</option>~;
			} else {
				$genselect .= qq~<option value="$genlabel">$admin_txt{$gentext}</option>~;
			}
		}
		$genselect .= qq~</select>~;
		if (${$uid.$id}{'canpost'} == 1 || $INFO{'action'} ne 'boardscreen') { $canpostch    = qq~ checked="checked"~; }
		
		# Make children list if it contains sub boards
		my $childrenlist;
		if($subboard{$id}) {
			foreach $childbd (split(/\|/, $subboard{$id})) {
				my ($chldboardname, undef, undef) = split(/\|/, $board{"$childbd"});
				$childrenlist .= qq~$chldboardname, ~;
			}
			$childrenlist =~ s/, $//g;
		}
		
		if($childrenlist eq "") { $childrenlist = $admin_txt{'246'}; }

		# Retrieve Optional Details
		$ann      = "";
		$rbin     = "";
		$zeroch   = "";
		$attch    = "";
		$showpriv = "";
		$brdpic   = "";
		if ($boardview == 1)              { $showpriv = qq~ checked="checked"~; }
		if (${$uid.$id}{'zero'} == 1)     { $zeroch   = qq~ checked="checked"~; }
		if (${$uid.$id}{'attperms'} == 1) { $attch    = qq~ checked="checked"~; }

		if (${$uid.$id}{'ann'} == 1) {
			$annch = qq~ checked="checked"~;
			$brdpic   = qq~ disabled="disabled"~;
		} elsif ($annboard ne "") {
			$annch    = qq~ disabled="disabled"~;
			$annexist = 1;
		}
		if (${$uid.$id}{'rbin'} == 1) {
			$rbinch = qq~ checked="checked"~;
			$brdpic   = qq~ disabled="disabled"~;
		} elsif ($binboard ne "") {
			$rbinch    = qq~ disabled="disabled"~;
			$rbinexist = 1;
		}

		#Get Board permissions here
		my $startperms = &DrawPerms(${$uid.$id}{'topicperms'}, 0);
		my $replyperms = &DrawPerms(${$uid.$id}{'replyperms'}, 1);
		my $viewperms  = &DrawPerms($boardperms, 0);
		my $pollperms  = &DrawPerms(${$uid.$id}{'pollperms'}, 0);

		$yymain .= qq~
  <tr>
	<td class="titlebg" width="100%" colspan="5" align="left"> <b>$boardtext</b></td>
  </tr><tr>
	<td class="catbg"  colspan="4"><b>$admin_txt{'59'}:</b> $admin_txt{'60'}</td>
  </tr><tr>~;
		if ($id ne '') {
			$yymain .= qq~
	<td class="windowbg" width="25%" align="left"><label for="id$i"><b>$admin_txt{'61'}</b></label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="hidden" name="id$i" id="id$i" value="$id" />$id</td>~;
		} else {
			$yymain .= qq~
	<td class="windowbg" width="25%" align="left"><label for="id$i"><b>$admin_txt{'61'}</b><br />$admin_txt{'61b'}</label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="text" name="id$i" id="id$i" /></td>~;
		}
		$yymain .= qq~
  </tr><tr>
    <td class="windowbg"  width="25%" align="left"><label for="name$i"><b>$admin_txt{'68'}:</b></label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="text" name="name$i" id="name$i" value="$boardname" size="50" maxlength="100" /></td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><label for="description$i"><b>$admin_txt{'62'}:</b></label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><textarea name="description$i" id="description$i" rows="5" cols="30" style="width:98%; height:60px">$description</textarea></td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left">
	<b>$admin_txt{'63'}:</b><br /><span class="small">
	<!-- <a href="javascript:void(0);" onclick="window.open('$scripturl?action=imlist;sort=username;toid=moderators$i','','status=no,height=345,width=464,menubar=no,toolbar=no,top=50,left=50,scrollbars=no')">$selector_txt{linklabel}</a><br/> -->
	<a href="javascript:void(0);" onclick="window.open('$scripturl?action=qsearch;toid=moderators$i','','status=no,height=325px,width=300,menubar=no,toolbar=no,top=50,left=50,scrollbars=no')">$selector_txt{linklabel}</a><br />
	<a href="javascript:copyNames($i)">$admin_txt{'63a'}</a><br/>
	<a href="javascript:pasteNames($i,1)">$admin_txt{'63b'}</a><br/>
	<a href="javascript:pasteNames(1,$FORM{'amount'})">$admin_txt{'63c'}</a></span>
    </td>
    <td class="windowbg2" width="75%" colspan="3" align="left">
    	<select name="moderators$i" id="moderators$i" multiple="multiple" size="3" style="width: 320px;" ondblclick="removeUser(this);">~;

		my @thisBoardModerators = split(/, ?/, $moderators);
		foreach my $thisMod (@thisBoardModerators ) {
			&LoadUser($thisMod);
			my $thisModname = ${$uid.$thisMod}{'realname'};
			if (!$thisModname) { $thisModname = $thisMod; }
			if ($do_scramble_id) { $thisMod = &cloak($thisMod); }
			$yymain .= qq~
			<option value="$thisMod">$thisModname</option>~;
		}

		$yymain .= qq~
		</select>
	        <br /><span class="small">$selector_txt{instructions}</span>
    <!--<input type="text" name="moderators$i" value="$moderators" size="50" maxlength="100" />-->
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><label for="moderatorgroups$i"><b>$admin_txt{'13'}:</b></label></td>
	<td class="windowbg2"  width="75%" colspan="3">
~;

		# Allows admin to select entire membergroups to be a board moderator
		$k = 0;
		my $box = "";
		foreach (@nopostorder) {
			@groupinfo = split(/\|/, $NoPost{$_});
			$box .= qq~<option value="$_"~;
			foreach (split(/, /, $moderatorgroups)) {
				($lineinfo, undef) = split(/\|/, $NoPost{$_}, 2);
				if ($lineinfo eq $groupinfo[0]) {
					$box .= qq~ selected="selected" ~;
				}
			}
			$box .= qq~>$groupinfo[0]</option>~;
			$k++;
		}
		if ($k > 5) { $k = 5; }
		if ($k > 0) {
			$yymain .= qq~<select multiple="multiple" name="moderatorgroups$i" id="moderatorgroups$i" size="$k">$box</select> <label for="moderatorgroups$i"><span class="small">$admin_txt{'14'}</span></label>~;
		} else {
			$yymain .= qq~$admin_txt{'15'}~;
		}

		$yymain .= qq~
	</td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><label for="cat$i"><b>$admin_txt{'44'}:</b></label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><select name="cat$i" id="cat$i" onchange="updateParent(this.value, '$editboards[$i]', $i)">$catsel{$i}</select></td>
  </tr><tr>
      <td class="windowbg" width="25%" align="left"><label for="parent$i"><b>$admin_txt{'249'}:</b></label></td>
      <td class="windowbg2" width="75%" colspan="3" align="left"><select onchange="checkParent($i, '$editboards[$i]')" name="parent$i" id="parent$i">$catboardlist{${$uid.$editboards[$i]}{'cat'}}</select></td>
  </tr><tr>
      <td class="windowbg" width="25%" align="left"><label for="children$i"><b>$admin_txt{'248'}:</b></label></td>
      <td class="windowbg2" width="75%" colspan="3" align="left">$childrenlist</td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><label for="canpost$i"><b>$admin_txt{'247'}</b></label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="checkbox" name="canpost$i" id="canpost$i" value="1"$canpostch /> <label for="canpost$i">$admin_txt{'247a'}</label></td>
  </tr><tr>
    <td class="catbg"  colspan="4"><b>$admin_txt{'64'}</b> $admin_txt{'64a'} </td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><label for="pic$i"><b>$admin_txt{'64b'}:</b></label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="text" name="pic$i" id="pic$i" value="$boardpic" size="50" maxlength="255"$brdpic /></td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><label for="zero$i"><b>$admin_txt{'64c'}</b></label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="checkbox" name="zero$i" id="zero$i" value="1"$zeroch /> <label for="zero$i">$admin_txt{'64d'}</label></td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><label for="show$i"><b>$admin_txt{'64e'}</b></label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="checkbox" name="show$i" id="show$i" value="1"$showpriv /> <label for="show$i">$admin_txt{'64f'}</label></td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><label for="att$i"><b>$admin_txt{'64k'}</b></label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="checkbox" name="att$i" id="att$i" value="1"$attch /> <label for="att$i">$admin_txt{'64l'}</label></td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><label for="ann$i"><b>$admin_txt{'64g'}</b></label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="checkbox" id="ann$i" name="ann$i" value="1" $annch onclick="javascript: if (this.checked) checkann(true, '$i'); else checkann(false, '$i');" /> <label for="ann$i">$admin_txt{'64h'}</label></td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><label for="rbin$i"><b>$admin_txt{'64i'}</b></label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="checkbox" id="rbin$i" name="rbin$i" value="1" $rbinch onclick="javascript: if (this.checked) checkbin(true, '$i'); else checkbin(false, '$i');" /> <label for="rbin$i">$admin_txt{'64j'}</label></td>
  </tr><tr>
    <td class="catbg"  colspan="4"><b>$admin_txt{'100'}:</b> $admin_txt{'100a'}</td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><label for="minage$i"><b>$admin_txt{'95'}:</b></label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="text" size="3" name="minage$i" id="minage$i" value="$boardminage" /> <label for="minage$i">$admin_txt{'96'}</label></td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><label for="maxage$i"><b>$admin_txt{'95a'}:</b></label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left"><input type="text" size="3" name="maxage$i" id="maxage$i" value="$boardmaxage" /> <label for="maxage$i">$admin_txt{'96a'}</label></td>
  </tr><tr>
    <td class="windowbg" width="25%" align="left"><label for="gender$i"><b>$admin_txt{'97'}:</b></label></td>
    <td class="windowbg2" width="75%" colspan="3" align="left">$genselect <label for="gender$i">$admin_txt{'98'}</label></td>
  </tr><tr>
    <td class="catbg"  colspan="4"><b>$admin_txt{'65'}:</b> $admin_txt{'65a'} <span class="small">$admin_txt{'14'}</span></td>
  </tr><tr>
    <td class="titlebg" width="25%" align="center"><label for="topicperms$i"><b>$admin_txt{'65b'}:</b></label></td>
    <td class="titlebg" width="25%" align="center"><label for="replyperms$i"><b>$admin_txt{'65c'}:</b></label></td>
    <td class="titlebg" width="25%" align="center"><label for="viewperms$i"><b>$admin_txt{'65d'}:</b></label></td>
    <td class="titlebg" width="25%" align="center"><label for="pollperms$i"><b>$admin_txt{'65e'}:</b></label></td>
  </tr><tr>
    <td class="windowbg2" width="25%" align="center"><select multiple="multiple" name="topicperms$i" id="topicperms$i" size="8">$startperms</select></td>
    <td class="windowbg2" width="25%" align="center"><select multiple="multiple" name="replyperms$i" id="replyperms$i" size="8">$replyperms</select></td>
    <td class="windowbg2" width="25%" align="center"><select multiple="multiple" name="viewperms$i" id="viewperms$i" size="8">$viewperms</select></td>
    <td class="windowbg2" width="25%" align="center"><select multiple="multiple" name="pollperms$i" id="pollperms$i" size="8">$pollperms</select></td>
  </tr>
</table>
</div>
<br /><br />
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table border="0" align="center" cellspacing="1" cellpadding="4" width="100%">
~;
	}
	$yymain .= qq~
  <tr>
      <td class="catbg" width="100%" colspan="5" align="center"> <input type="hidden" name="amount" value=\"$FORM{"amount"}\" />
      <input type="hidden" name="screenornot" value="$INFO{'action'}" />
      <input type="submit" value="$admin_txt{'10'}" class="button" /></td>
  </tr>
</table>
</div>
</form>

<script language="JavaScript1.2" type="text/javascript">
<!--
var numboards = "$FORM{'amount'}";
var annexist = "$annexist";
var rbinexist = "$rbinexist";
var istart = "$istart";
var editbrds = new Array();
$brd_javascript

function checkann(acheck, awho) {
	var adischeck = acheck;
	var adisuncheck = acheck;
	for (var i = istart; i <= numboards; i++) {
		if(i != awho) {
			if(document.getElementById('rbin'+i).checked == true) {
				adischeck = true;
				document.getElementById('ann'+i).disabled = true;
			}
			else {
				document.getElementById('ann'+i).disabled = acheck;
			}
		}
	}
	if(document.getElementById('ann'+awho).checked == true) {
		adischeck = true;
		document.forms["boardsadd"].elements['topicperms'+awho].selectedIndex = -1;
		document.forms["boardsadd"].elements['topicperms'+awho].options[0].selected = true;
		document.forms["boardsadd"].elements['replyperms'+awho].selectedIndex = -1;
		document.forms["boardsadd"].elements['replyperms'+awho].options[0].selected = true;
		document.forms["boardsadd"].elements['pollperms'+awho].selectedIndex = -1;
		document.forms["boardsadd"].elements['pollperms'+awho].options[0].selected = true;
	}
	document.getElementById('rbin'+awho).disabled = adischeck;
	document.getElementById('pic'+awho).disabled = adisuncheck;
	if(rbinexist == '1') document.getElementById('rbin'+awho).disabled = true;
}

function checkbin(bcheck, bwho) {
	var bdischeck = bcheck;
	var bdisuncheck = bcheck;
	for (var i = istart; i <= numboards; i++) {
		if(i != bwho) {
			if(document.getElementById('ann'+i).checked == true) {
				bdischeck = true;
				document.getElementById('rbin'+i).disabled = true;
			}
			else document.getElementById('rbin'+i).disabled = bcheck;
		}
	}
	if(document.getElementById('rbin'+bwho).checked == true) bdischeck = true;
	document.getElementById('ann'+bwho).disabled = bdischeck;
	document.getElementById('pic'+bwho).disabled = bdisuncheck;
	if(annexist == '1') document.getElementById('ann'+bwho).disabled = true;
}


selectParentBoard();


//-->
</script>

	~;
	$yytitle     = "$admin_txt{'50'}";
	$action_area = "manageboards";
	&AdminTemplate;
}

sub DrawPerms {
	my ($permissions,$permstype) = @_;
	my ($foundit, %found, $groupsel, $groupsel2, $name);
	my $count = 0;
	if ($permissions eq "") { $permissions = "xk8yj56ndkal"; }
	my @perms = split(/, /, $permissions);
	foreach $perm (@perms) {
		$foundit = 0;
		if ($permstype == 1) {
			$name = $admin_txt{'65f'};
			if ($perm eq "Topic Starter") {
				$foundit = 1;
				$found{$name} = 1;
				$groupsel .= qq~<option value="Topic Starter" selected="selected">$name</option>\n~;
			}
			if ($count == $#perms && $found{$name} != 1) { $groupsel2 .= qq~<option value="Topic Starter">$name</option>\n~; }
		}

		($name, undef) = split(/\|/, $Group{"Administrator"}, 2);
		if ($perm eq "Administrator") {
			$foundit = 1;
			$found{$name} = 1;
			$groupsel .= qq~<option value="Administrator" selected="selected">$name</option>\n~;
		}
		if ($count == $#perms && $found{$name} != 1) { $groupsel2 .= qq~<option value="Administrator">$name</option>\n~; }

		($name, undef) = split(/\|/, $Group{"Global Moderator"}, 2);
		if ($perm eq "Global Moderator") {
			$foundit = 1;
			$found{$name} = 1;
			$groupsel .= qq~<option value="Global Moderator" selected="selected">$name</option>\n~;
		}
		if ($count == $#perms && $found{$name} != 1) { $groupsel2 .= qq~<option value="Global Moderator">$name</option>\n~; }

		if ($foundit != 1 || $count == $#perms) {
			foreach (@nopostorder) {
				($name, undef) = split(/\|/, $NoPost{$_}, 2);
				if ($perm eq $_) {
					$foundit = 1;
					$found{$_} = 1;
					$groupsel .= qq~<option value="$_" selected="selected">$name</option>\n~;
				}
				if ($found{$_} != 1 && $count == $#perms) { $groupsel2 .= qq~<option value="$_">$name</option>\n~; }
			}
			if ($foundit != 1 || $count == $#perms) {
				foreach (sort { $b <=> $a } keys %Post) {
					($name, undef) = split(/\|/, $Post{$_}, 2);
					if ($perm eq $name) {
						$foundit = 1;
						$found{$name} = 1;
						$groupsel .= qq~<option value="$name" selected="selected">$name</option>\n~;
					}
					if ($count == $#perms && ($found{$name} != 1 || $found{$name} eq "")) { $groupsel2 .= qq~<option value="$name">$name</option>\n~; }
				}
			}
		}
		$count++;
	}
	$groupsel . $groupsel2;
}

sub AddBoards2 {
	&is_admin_or_gmod;
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	$anncount  = 0;
	$rbincount = 0;
	my (@boardcontrol,@changes,@updatecats);
	&LoadBoardControl;
	
	for (my $i = 1; $i != $FORM{'amount'} + 1; $i++) {
		if ($FORM{"pic$i"} ne '' && $FORM{"pic$i"} !~ m~^[0-9a-zA-Z_\.\#\%\-\:\+\?\$\&\~\.\,\@/]+\.(gif|png|bmp|jpg)$~) { &fatal_error("invalid_picture"); }
		##### Dealing with Required Info here #####
		if ($FORM{"id$i"} eq '') { next; }
		$id = $FORM{"id$i"};
		if ($FORM{"ann$i"})  { $anncount++; }
		if ($FORM{"rbin$i"}) { $rbincount++; }
		&fatal_error('announcement_defined') if ($anncount > 1);
		&fatal_error('recycle_bin_defined') if ($rbincount > 1);
		&fatal_error('invalid_character',"$admin_txt{'61'} $admin_txt{'241'}") if ($id !~ /\A[0-9A-Za-z#%+-\.@^_]+\Z/);

		if ($FORM{'screenornot'} ne "boardscreen") {
			# adding a board
			# make sure no board already exists with that id
			&fatal_error("board_defined","$id") if (exists $board{"$id"});

			# add to category if it's not a sub board, otherwise add it to subboard list for its parent
			if(!$FORM{"parent$i"}) {
				my @bdlist = split(/\,/, $cat{$FORM{"cat$i"}});
				push(@bdlist, "$id");
				$cat{$FORM{"cat$i"}} = join(',', @bdlist);
			} else {
				if($subboard{$FORM{"parent$i"}} ne "") {
					$subboard{$FORM{"parent$i"}} .= qq~|$id~;
				} else {
					$subboard{$FORM{"parent$i"}} = $id;
				}
			}
			&write_DBorFILE(0,'',$boardsdir,$id,'txt',(''));
		}
		if ($FORM{'screenornot'} eq "boardscreen") {
			# editing a board
			my $category = ${$uid.$id}{'cat'};

			# move category of board
			if ($category ne $FORM{"cat$i"}) {
				${$uid.$id}{'cat'} = qq~$FORM{"cat$i"}~;
				
				# recursively change the category of child boards.
				if($subboard{$id}) {
					&cat_change(split(/\|/, $subboard{$id}));
					sub cat_change {
						foreach $childbd (@_) {
							${$uid.$childbd}{'cat'} = qq~$FORM{"cat$i"}~;
							push(@updatecats, $childbd);
							if($subboard{$childbd}) { &cat_change(split(/\|/, $subboard{$childbd})); }
						}
					}
				}
				
				# if it's not a sub board, remove from the old category
				if(!${$uid.$id}{'parent'}) {
					my @bdlist = split(/,/, $cat{$category});

					# Remove Board from old Category
					my $k = 0;
					foreach $bd (@bdlist) {
						if ($id eq $bd) { splice(@bdlist, $k, 1); }
						$k++;
					}
					$cat{"$category"} = join(',', @bdlist);
				}
				# Add Category to new Category, but only if it isn't a sub board
				if(!$FORM{"parent$i"}) {
					my $ncat   = $FORM{"cat$i"};
					if ($cat{$ncat} ne "") { $cat{$ncat} .= ",$id"; }
					else { $cat{$ncat} = $id; }
				}
			}
			
			# move parent board of board
			if(${$uid.$id}{'parent'} ne $FORM{"parent$i"}) {
				# if it had a parent, remove it from that list, otherwise it didnt have a parent so remove it from cat list
				if(${$uid.$id}{'parent'}) {
					my @bdlist = split(/\|/, $subboard{${$uid.$id}{'parent'}});

					# Remove Board from old parent board
					my $k = 0;
					foreach $bd (@bdlist) {
						if ($id eq $bd) { splice(@bdlist, $k, 1); }
						$k++;
					}
					$subboard{${$uid.$id}{'parent'}} = join('|', @bdlist);
				}
				# only remove from old category if it now has a parent and its in the same cat as before, otherwise
				# cat had to have been changed to get a parent in a different cat, and the cat change takes care of
				# removing it from the previous category
				elsif ($category eq $FORM{"cat$i"}) {
					my @bdlist = split(/,/, $cat{$category});

					# Remove Board from old Category
					my $k = 0;
					foreach $bd (@bdlist) {
						if ($id eq $bd) { splice(@bdlist, $k, 1); }
						$k++;
					}
					$cat{$category} = join(',', @bdlist);
				}
				
				# if we're removing the parent board, move it back up to it's category, otherwise add to new parent board
				if($FORM{"parent$i"} eq "") {
					# only move up to cat if cat is the same as previously
					if ($category eq $FORM{"cat$i"}) {
						my @bdlist = split(/\,/, $cat{$FORM{"cat$i"}});
						push(@bdlist, "$id");
						$cat{$FORM{"cat$i"}} = join(',', @bdlist);
					}
				} else {
					# Add to new parent board
					if($subboard{$FORM{"parent$i"}}) {
						$subboard{$FORM{"parent$i"}} .= qq~|$id~;
					} else {
						$subboard{$FORM{"parent$i"}} = $id;
					}
				}
			}

			if (&checkfor_DBorFILE("$boardsdir/$id.txt")) { # fix a(nnboard) in the boardid.txt
				my @boardtomodify = &read_DBorFILE(0,'',$boardsdir,$id,'txt');
				my $x;
				if ($FORM{"ann$i"} && (split /\|/, $boardtomodify[0])[8] !~ /a/i) {
					for ($x = 0; $x < @boardtomodify; $x++) {
						$boardtomodify[$x] =~ s/(.*\|)(0?)(.*)/ $1 . ($2 eq '0' ? "0a$3" : "a$3") /e;
					}
				} elsif (!$FORM{"ann$i"} && (split /\|/, $boardtomodify[0])[8] =~ /a/i) {
					for ($x = 0; $x < @boardtomodify; $x++) {
						$boardtomodify[$x] =~ s/(.*\|)(.*)/ $1 . &take_a_off($2) /e;
					}
					sub take_a_off { my $y = shift; $y =~ s/a//g; $y; }
				}
				if ($x) {
					&write_DBorFILE(0,'',$boardsdir,$id,'txt',@boardtomodify);
				}
			}
		}

		$bname = $FORM{"name$i"};
		&FromChars($bname);
		&ToHTML($bname);

		# If someone has the bright idea of starting a membergroup with a $
		# We need to escape it for them, to prevent us interpreting it as a var...
		$FORM{"viewperms$i"} =~ s~\$~\\\$~g;

		$board{"$id"} = "$bname|$FORM{\"viewperms$i\"}|$FORM{\"show$i\"}";
		$bdescription = $FORM{"description$i"};
		&FromChars($bdescription);
		$bdescription =~ s/\r//g;
		$bdescription =~ s~\n~<br \/>~g;
		if ($do_scramble_id) {
			my @mods;
			foreach (split(', ', $FORM{"moderators$i"})) {
				push(@mods, &decloak($_));
			}
			$FORM{"moderators$i"} = join(', ', @mods);
		}
		if ($FORM{"zero$i"} eq '') { $FORM{"zero$i"} = 0; }
		$FORM{"minage$i"} =~ tr/[0-9]//cd;    ## remove non numbers
		$FORM{"maxage$i"} =~ tr/[0-9]//cd;    ## remove non numbers
		if ($FORM{"minage$i"} < 0)   { $FORM{"minage$i"} = ""; }
		if ($FORM{"maxage$i"} < 0)   { $FORM{"maxage$i"} = ""; }
		if ($FORM{"minage$i"} > 180) { $FORM{"minage$i"} = ""; }
		if ($FORM{"maxage$i"} > 180) { $FORM{"maxage$i"} = ""; }
		if ($FORM{"maxage$i"} && $FORM{"maxage$i"} < $FORM{"minage$i"}) { $FORM{"maxage$i"} = $FORM{"minage$i"}; }

		push(@boardcontrol, "$FORM{\"cat$i\"}|$id|$FORM{\"pic$i\"}|$bdescription|$FORM{\"moderators$i\"}|$FORM{\"moderatorgroups$i\"}|$FORM{\"topicperms$i\"}|$FORM{\"replyperms$i\"}|$FORM{\"pollperms$i\"}|$FORM{\"zero$i\"}|$FORM{\"membergroups$i\"}|$FORM{\"ann$i\"}|$FORM{\"rbin$i\"}|$FORM{\"att$i\"}|$FORM{\"minage$i\"}|$FORM{\"maxage$i\"}|$FORM{\"gender$i\"}|$FORM{\"canpost$i\"}|$FORM{\"parent$i\"}\n");
		push(@changes, $id);
		$yymain .= qq~<i>'$FORM{"name$i"}'</i> $admin_txt{'48'} <br />~;
	}

	# do the saving here, after all new boards passed the tests (fatal_error)
	if ($FORM{'screenornot'} ne "boardscreen") { &BoardTotals("add", @changes); }

	&Write_ForumMaster;
	my @oldcontrols = &read_DBorFILE(0,FORUMCONTROL,$boardsdir,'forum','control');
	my $oldboard;
	
	# Update categories for subboards that got changed.
	for (my $cnt = 0; $cnt < @oldcontrols; $cnt++) {
		(undef, $oldboard, undef) = split(/\|/, $oldcontrols[$cnt], 3);
		foreach my $changedboard (@updatecats) {
			if ($changedboard eq $oldboard) {
				my ($oldcat, $therest) =  split(/\|/, $oldcontrols[$cnt], 2);
				$oldcontrols[$cnt] = qq~${$uid.$changedboard}{'cat'}|$therest~;
				last;
			}
		}
	}
	
	for (my $cnt = 0; $cnt < @oldcontrols; $cnt++) {
		(undef, $oldboard, undef) = split(/\|/, $oldcontrols[$cnt], 3);
		foreach my $changedboard (@changes) {
			if ($changedboard eq $oldboard) { $oldcontrols[$cnt] = ""; last;}
		}
	}
	push(@oldcontrols, @boardcontrol);
	&write_DBorFILE(0,FORUMCONTROL,$boardsdir,'forum','control',sort(grep { $_; } @oldcontrols));

	$action_area = "manageboards";
	&AdminTemplate;
}

sub ReorderBoards {
	&is_admin_or_gmod;
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	if($INFO{'subboards'}) { &LoadBoardControl; }
	if ($#categoryorder > 0) {
		foreach $category (@categoryorder) {
			chomp $category;
			($categoryname, undef) = split(/\|/, $catinfo{$category});
			&ToChars($categoryname);
			if (($category eq $INFO{"item"} && !$INFO{'subboards'}) || ($category eq ${$uid.$INFO{"item"}}{'cat'} && $INFO{'subboards'})) {
				$categorylistsel = qq~<option value="$category" selected="selected">$categoryname</option>~;
			} else {
				$categorylist .= qq~<option value="$category">$categoryname</option>~;
			}
			
			# build option lists for parent boards
			my @catboards = split(/,/, $cat{$category});
			my $indent = -2;
			$catboardlist{$category} = qq~<option value=''>&nbsp;<\\/option>~;

			&get_subboards2(@catboards);
			sub get_subboards2 {
				$indent += 2;
				foreach $childbd (@_) {
					my $dash;
					if($indent > 0) { $dash = "-"; }
					($chldboardname, undef, undef) = split(/\|/, $board{"$childbd"});
					$catboardlist{$category} .= qq~<option value='$childbd'>~ . ("&nbsp;" x $indent) . ($dash x ($indent / 2)) . qq~ $chldboardname<\\/option>~;
					if($subboard{$childbd}) {
						&get_subboards2(split(/\|/,$subboard{$childbd}));
					}
				}
				$indent -= 2;
			}

			$catboardlist_js .= qq~
				catboardlist['$category'] = "$catboardlist{$category}";
			~;
		}
	}
	
	# get list of subboards if that's what we're reordering otherwise boards in the selected category
	if($INFO{'subboards'}) {
		@bdlist = split(/\|/, $subboard{ $INFO{"item"} });
		$INFO{'subboards'} = ";subboards=1";
		($curname, $boardperms, $boardview) = split(/\|/, $board{$INFO{"item"}});
		&ToChars($curname);
		$cur_txt = $admin_txt{'832a'};
		
	} else {
		@bdlist = split(/,/, $cat{ $INFO{"item"} });
		($curname, $catperms) = split(/\|/, $catinfo{ $INFO{"item"} });
		&ToChars($curname);
		$cur_txt = $admin_txt{'832'};
	}
	$bdcnt = @bdlist;
	$bdnum = $bdcnt;
	if ($bdcnt < 4) { $bdcnt = 4; }

	# Prepare the list of current boards to be put in the select box
	$boardslist = qq~<select name="selectboards" id="selectboards" size="$bdcnt" style="width: 190px;">~;
	foreach $board (@bdlist) {
		chomp $board;
		($boardname, undef) = split(/\|/, $board{$board}, 2);
		&ToChars($boardname);
		if ($board eq $INFO{'theboard'}) {
			$boardslist .= qq~<option value="$board" selected="selected">$boardname</option>~;
		} else {
			$boardslist .= qq~<option value="$board">$boardname</option>~;
		}
	}
	$boardslist .= qq~</select>~;

	
	if($INFO{'subboards'}) {
		$cat_or_bd_txt = $admin_txt{'739h'};
		$admin_txt{'739c'} =~ s/{(.*?)}/$admin_txt{'739j'}$1/g;
		$admin_txt{'739d'} =~ s/{(.*?)}/$admin_txt{'739j'}$1/g;
		$admin_txt{'739f'} =~ s/{(.*?)}/$admin_txt{'739j'}$1/g;
	} else {
		$cat_or_bd_txt = $admin_txt{'739'};
		$admin_txt{'739c'} =~ s/{(.*?)}/$1/g;
		$admin_txt{'739d'} =~ s/{(.*?)}/$1/g;
		$admin_txt{'739f'} =~ s/{(.*?)}/$1/g;
	}

	$yymain .= qq~
<br /><br />
<form action="$adminurl?action=reorderboards2;item=$INFO{'item'}$INFO{'subboards'}" method="post" id="bdform">
<table border="0" width="525" cellspacing="1" cellpadding="4" class="bordercolor" align="center">
  <tr>
    <td class="titlebg"><img src="$imagesdir/board.gif" alt="" style="vertical-align: middle;" /> <b>$cur_txt ($curname)</b></td>
  </tr>
  <tr>
    <td class="windowbg" valign="middle" align="left">
~;
	if ($bdnum) {
		$yymain .= qq~
    <div style="float: left; width: 280px; text-align: left; margin-bottom: 4px;" class="small"><label for="selectboards">$cat_or_bd_txt</label></div>
    <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">$boardslist</div>
    <div style="float: left; width: 280px; text-align: left; margin-bottom: 4px;" class="small">$admin_txt{'739d'}</div>
    <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">
	<input type="submit" value="$admin_txt{'739a'}" name="moveup" style="font-size: 11px; width: 95px;" class="button" />
	<input type="submit" value="$admin_txt{'739b'}" name="movedown" style="font-size: 11px; width: 95px;" class="button" />
    </div>
~;
		if ($#categoryorder > 0) {
			$yymain .= qq~
    <div class="small" style="float: left; width: 280px; text-align: left; margin-bottom: 4px;"><label for="selectcategory">$admin_txt{'739c'}</label></div>
    <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">
	<select name="selectcategory" id="selectcategory" style="width: 190px;" onchange = "updateParent(this.value, '~ . ($INFO{'subboards'} ? $INFO{'item'} : "") . qq~')">
	$categorylistsel
	$categorylist
	</select>
    </div><br />
~;
		}
		$yymain .= qq~
    <div class="small" style="float: left; width: 280px; text-align: left; margin-bottom: 4px;"><label for="selectboard">$admin_txt{'739f'}</label></div>
    <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">
	<select name="selectboard" id="selectboard" style="width: 190px;"><option>&nbsp;</option></select>
    </div>
    <br />
    <div style="float: left; width: 280px; text-align: left;">&nbsp;</div>
    <div style="float: left; width: 230px; text-align: center;">
        <input type="button" onclick="checkParent()" value="$admin_txt{'739g'}" name="update" style="font-size: 11px; width: 190px;" class="button" />
    </div>
~;
	} else {
		$yymain .= qq~
    <div class="small" style="text-align: center; margin-bottom: 4px;">$admin_txt{'739e'}</div>
~;
	}
	$yymain .= qq~
    </td>
  </tr>
</table>
</form>
~;
	$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript">
var catboardlist = new Array();
$catboardlist_js

// updates parent drop down list when new category is selected
function updateParent(cat, board) {
	var parentsel = document.getElementById("selectboard");
	parentsel.innerHTML = catboardlist[cat];
	
	for (var i = 0; i < parentsel.options.length; i++) {
		if(parentsel.options[i].value == board) {
			parentsel.options[i].style.backgroundColor = "#ffbbbb";
		}
	}
}

// make sure we don't select a board and decide to move it to itself....
function checkParent() {
	var parent = document.getElementById("selectboard").value;
	var board = document.getElementById("selectboards").value;
	if(parent == board) {
		alert("$admin_txt{'733'}");
	}
	else if (!board) {
		alert("$admin_txt{'734'}");
	} else {
		document.getElementById("bdform").submit();
	}
}

updateParent('~ . ($INFO{'subboards'} ? ${$uid.$INFO{'item'}}{'cat'} : $INFO{'item'}) . qq~','$INFO{'item'}');
var parentsel = document.getElementById("selectboard");
~;

	if($INFO{'subboards'}) {
	$yymain .= qq~
for (var i = 0; i < parentsel.options.length; i++) {
		if(parentsel.options[i].value == '$INFO{'item'}') {
			parentsel.options[i].selected = true;
		}
}
~;
	}
	
	$yymain .= qq~
</script>
~;
	
	$yytitle     = "$admin_txt{'832'}";
	$action_area = "manageboards";
	&AdminTemplate;
}

sub ReorderBoards2 {
	&is_admin_or_gmod;
	unless ($mloaded == 1) { require "$boardsdir/forum.master"; }
	
	if($INFO{'subboards'}) {
		@itemorder = split(/\|/, $subboard{ $INFO{"item"} });
	} else {
		@itemorder = split(/,/, $cat{ $INFO{"item"} });
	}
	
	&LoadBoardControl;
	
	my $moveitem = $FORM{'selectboards'};
	my $catorbd = $INFO{"item"};
	my @updatecats;
	if ($moveitem) {
		if ($FORM{'moveup'} || $FORM{'movedown'}) {
			if ($FORM{'moveup'}) {
				for ($i = 0; $i < @itemorder; $i++) {
					if ($itemorder[$i] eq $moveitem && $i > 0) {
						$j             = $i - 1;
						$itemorder[$i] = $itemorder[$j];
						$itemorder[$j] = $moveitem;
						last;
					}
				}
			} elsif ($FORM{'movedown'}) {
				for ($i = 0; $i < @itemorder; $i++) {
					if ($itemorder[$i] eq $moveitem && $i < $#itemorder) {
						$j             = $i + 1;
						$itemorder[$i] = $itemorder[$j];
						$itemorder[$j] = $moveitem;
						last;
					}
				}
			}
			if($INFO{'subboards'}) {
				$subboard{$catorbd} = join('|', grep { $_; } @itemorder);
			} else {
				$cat{$catorbd} = join(',', grep { $_; } @itemorder);
			}
		} else {
			my $category = ${$uid.$moveitem}{'cat'};
			if (${$uid.$moveitem}{'cat'} ne $FORM{"selectcategory"}) {
				${$uid.$moveitem}{'cat'} = qq~$FORM{'selectcategory'}~;
				my @bdlist = split(/,/, $cat{$category});
				
				# recursively change the category of child boards.
				if ($subboard{$moveitem}) {
					&cat_change2(split(/\|/, $subboard{$moveitem}));
					sub cat_change2 {
						foreach $childbd (@_) {
							${$uid.$childbd}{'cat'} = qq~$FORM{"selectcategory"}~;
							push(@updatecats, $childbd);
							if ($subboard{$childbd}) { &cat_change2(split(/\|/, $subboard{$childbd})); }
						}
					}
				}
				
				# remove from the category list only if it was not a subboard
				if (!${$uid.$moveitem}{'parent'}) {
					my $k = 0;
					foreach $bd (@bdlist) {
						if ($moveitem eq $bd) { splice(@bdlist, $k, 1); }
						$k++;
					}
					$cat{$category} = join(',', @bdlist);
				}
				
				# add to new category if there's no parent selected
				if (!$FORM{'selectboard'}) {
					# add to new cat list
					my $ncat   = $FORM{"selectcategory"};
					if ($cat{$ncat} ne "") { $cat{$ncat} .= ",$moveitem"; }
					else { $cat{$ncat} = $moveitem; }
				}
			}
			
			# if parent has changed
			if (${$uid.$moveitem}{'parent'} ne $FORM{'selectboard'}) {
				# if it had a parent, remove it from that list, otherwise it didnt have a parent so remove it from cat list
				if (${$uid.$moveitem}{'parent'}) {
					my @bdlist = split(/\|/, $subboard{${$uid.$moveitem}{'parent'}});

					# Remove Board from old parent board
					my $k = 0;
					foreach $bd (@bdlist) {
						if ($moveitem eq $bd) { splice(@bdlist, $k, 1); }
						$k++;
					}
					$subboard{${$uid.$moveitem}{'parent'}} = join('|', @bdlist);
				}
				# only remove from old category if it now has a parent and its in the same cat as before, otherwise
				# cat had to have been changed to get a parent in a different cat, and the cat change takes care of
				# removing it from the previous category
				elsif ($category eq $FORM{"selectcategory"}) {
					my @bdlist = split(/,/, $cat{$category});

					# Remove Board from old Category
					my $k = 0;
					foreach $bd (@bdlist) {
						if ($moveitem eq $bd) { splice(@bdlist, $k, 1); }
						$k++;
					}
					$cat{$category} = join(',', @bdlist);
				}

				# if we're removing the parent board, move it back up to it's category, otherwise add to new parent board
				if ($FORM{'selectboard'} eq "") {
					# only move up to cat if cat is the same as previously
					if ($category eq $FORM{"selectcategory"}) {
						my @bdlist = split(/\,/, $cat{$FORM{"selectcategory"}});
						push(@bdlist, "$moveitem");
						$cat{$FORM{"selectcategory"}} = join(',', @bdlist);
					}
				} else {
					# Add to new parent board
					if($subboard{$FORM{'selectboard'}}) {
						$subboard{$FORM{'selectboard'}} .= qq~|$moveitem~;
					} else {
						$subboard{$FORM{'selectboard'}} = $moveitem;
					}
				}
				${$uid.$moveitem}{'parent'} = $FORM{'selectboard'};
			}
		}
		&Write_ForumMaster;


		my @oldcontrols = &read_DBorFILE(0,FORUMCONTROL,$boardsdir,'forum','control');
		my $oldboard;
		for (my $cnt = 0; $cnt < @oldcontrols; $cnt++) {
			my (undef, $oldboard,$pic,$bdescription,$moderators,$moderatorgroups,$topicperms,$replyperms,$pollperms,$zero,$membergroups,$ann,$rbin,$att,$minage,$maxage,$gender,$canpost,$parent) = split(/\|/, $oldcontrols[$cnt]);
			if ($moveitem eq $oldboard) {
				$oldcontrols[$cnt] = qq~${$uid.$moveitem}{'cat'}|$moveitem|$pic|$bdescription|$moderators|$moderatorgroups|$topicperms|$replyperms|$pollperms|$zero|$membergroups|$ann|$rbin|$att|$minage|$maxage|$gender|$canpost|${$uid.$moveitem}{'parent'}\n~;
			}
			foreach my $changedboard (@updatecats) {
				if ($changedboard eq $oldboard) {
					$oldcontrols[$cnt] = qq~${$uid.$changedboard}{'cat'}|$changedboard|$pic|$bdescription|$moderators|$moderatorgroups|$topicperms|$replyperms|$pollperms|$zero|$membergroups|$ann|$rbin|$att|$minage|$maxage|$gender|$canpost|${$uid.$changedboard}{'parent'}\n~;
				}
			}
		}
		&write_DBorFILE(0,FORUMCONTROL,$boardsdir,'forum','control',sort(grep { $_; } @oldcontrols));

	}
	if(!$INFO{'subboards'}) {
		$yySetLocation = qq~$adminurl?action=reorderboards;item=$catorbd;theboard=$moveitem~;
	} else {
		$yySetLocation = qq~$adminurl?action=reorderboards;item=$catorbd;theboard=$moveitem;subboards=1~;
	}
	&redirectexit;
}

sub ConfRemBoard {
	$yymain .= qq~
<table border="0" width="100%" cellspacing="1" class="bordercolor">
<tr>
	<td class="titlebg"><b>$admin_txt{'31'} - '$FORM{'boardname'}'?</b></td>
</tr>
<tr>
	<td class="windowbg" >
$admin_txt{'617'}<br />
<b><a href="$adminurl?action=modifyboard;cat=$FORM{'cat'};id=$FORM{'id'};moda=$admin_txt{'31'}2">$admin_txt{'163'}</a> - <a href="$adminurl?action=manageboards">$admin_txt{'164'}</a></b>
</td>
</tr>
</table>
~;
	$yytitle     = "$admin_txt{'31'} - '$FORM{'boardname'}'?";
	$action_area = "manageboards";
	&AdminTemplate;
}
1;