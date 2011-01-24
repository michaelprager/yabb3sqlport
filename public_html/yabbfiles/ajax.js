//##############################################################################
//# ajax.js                                                                    #
//##############################################################################
//# YaBB: Yet another Bulletin Board                                           #
//# Open-Source Community Software for Webmasters                              #
//# Version:        YaBB 3.0 Beta                                              #
//# Packaged:       October 05, 2010                                           #
//# Distributed by: http://www.yabbforum.com                                   #
//# ===========================================================================#
//# Copyright (c) 2000-2010 YaBB (www.yabbforum.com) - All Rights Reserved.    #
//# Software by:  The YaBB Development Team                                    #
//#               with assistance from the YaBB community.                     #
//##############################################################################

//YaBB 3.0 Beta $Revision: 100 $

var xmlHttp = null;
var browser = '';
var cachedPostPage;
var cachedIMPage;
var iframeloaded = 0;

if (navigator.appName == "Microsoft Internet Explorer") {
	browser = "block"; 
} else {
	browser = "table"; 
}

function Collapse_All (url,action,imgdir,lng) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url + ";oldcollapse=1";
		return;
	}

	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);

	var i = 0;
	var noboards = "";
	var boards = "";
	var imgsrc = "";
	if (action == 1) { 
		boards = browser;
		noboards = "none";
		imgsrc = "/cat_collapse.gif";
		document.getElementById("expandall").style.display = "none";
		document.getElementById("collapseall").style.display = "";
	} else {
		noboards = "";
		boards = "none";
		imgsrc = "/cat_expand.gif";
		document.getElementById("expandall").style.display = "";
		document.getElementById("collapseall").style.display = "none";
	}
	for (i = 0 ; i < catNames.length; i++) {
		document.getElementById(catNames[i]).style.display = boards;
		document.getElementById("col"+catNames[i]).style.display = noboards;
		document.getElementById("img"+catNames[i]).src = imgdir + imgsrc;
		document.getElementById("img"+catNames[i]).title = lng;
		document.getElementById("img"+catNames[i]).alt = lng;
	}
}

function SendRequest (url,cat,imgdir,lng_collapse,lng_expand) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url + ";oldcollapse=1";
		return;
	}

	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);

	var open = 0;
	var closed = 0;
	var board = '';
	if (document.getElementById(cat).style.display == "none") {
		document.getElementById(cat).style.display = browser;
		document.getElementById("col"+cat).style.display = "none";
		document.getElementById("img"+cat).src = imgdir+"/cat_collapse.gif";
		document.getElementById("img"+cat).title = lng_collapse;
		document.getElementById("img"+cat).alt = lng_collapse;
		document.getElementById("collapseall").style.display = "";
	} else {
		document.getElementById(cat).style.display = "none";
		document.getElementById("col"+cat).style.display = "";
		document.getElementById("img"+cat).src = imgdir+"/cat_expand.gif";
		document.getElementById("img"+cat).title = lng_expand;
		document.getElementById("img"+cat).alt = lng_expand;
		document.getElementById("expandall").style.display = "";
	}
	for (i = 0; i < catNames.length; i++) {
		if (document.getElementById(catNames[i]).style.display == "none") { closed++; }
		else { open++; }
	}
	if (closed == catNames.length) {
		document.getElementById("collapseall").style.display = "none";
		document.getElementById("expandall").style.display = "";
	}
	if (open == catNames.length) {
		document.getElementById("collapseall").style.display = "";
		document.getElementById("expandall").style.display = "none";
	}
}

function MarkAllAsRead(url,imgdir) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url + ";oldmarkread=1";
		return;
	}
	imagedir = imgdir;
	var imagealert = document.getElementById("ImageAlert");
	var imagebody = document.getElementById("ImageAlertBody");
	document.getElementById("ImageAlertIFrame").style.display = "none";
	imagebody.style.display = "block";
	
	var insert = '<div class="tabtitle" style="width: 100%; height: 30%; text-align: center">'+markallreadlang+'</div><div class="windowbg2" style="width: 100%; height: 70%; text-align: center"><img style="margin:4px" src="' + imagedir + '/Rotate.gif">';
	imagebody.innerHTML = insert;
	imagebody.style.width = "200px";
	imagebody.style.height = "60px";
	imagealert.style.display = "block";
	imagealert.style.visibility = "visible";
	imagealert.style.marginLeft = "-60px";
	imagealert.style.marginTop = "-60px";
	xmlHttp.onreadystatechange=MarkFinished;
	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);
}

function MarkFinished() {
	if (xmlHttp.readyState==4 || xmlHttp.readyState=="complete") { 
		var insert = '<div class="tabtitle" style="width: 100%; height: 30%; text-align: center">'+markfinishedlang+'</div><div class="windowbg2" style="width: 100%; height: 70%; text-align: center"><img style="margin: 4px;" src="' + imagedir + '/Rotate.gif">';
		document.getElementById("ImageAlertBody").innerHTML = insert;
		setTimeout("HideAlert()",1500);
		var images = document.getElementsByTagName("img");
		for (var i=0; i<images.length; i++) {
			var src = images[i].getAttribute("src");
			if (src.match("/on.gif") && !images[i].id.match("no_edit")) {
				images[i].setAttribute("src",src.replace("/on.gif","/off.gif"));
			}
			else if (src.match("/sub_on.png")) {
				images[i].setAttribute("src",src.replace("/sub_on.png","/sub_off.png"));
			}
			else if (src.match("imclose.gif")) {
				images[i].setAttribute("src",src.replace("imclose.gif","imopen.gif"));
			}
			else if (src.match("imclose2.gif")) {
				images[i].setAttribute("src",src.replace("imclose2.gif","imopen2.gif"));
			}
			else if (src.match("new.gif")) {
				images[i].style.display = "none";
			}
		}
		var newlinks = document.getElementsByTagName("span");
		for (var e=0; e<newlinks.length; e++) {
			if (newlinks[e].className == "NewLinks") {
				newlinks[e].style.display = "none";
			}
		}
 	} 
}

function AddRemFav(url,imgdir) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url + ";oldaddfav=1";
		return;
	}
	imagedir = imgdir;

	var imagealert = document.getElementById("ImageAlert");
	var imagebody = document.getElementById("ImageAlertBody");
	document.getElementById("ImageAlertIFrame").style.display = "none";
	imagebody.style.display = "block";

	var text;
	if (url.match("addfav")) {
		text = addfavlang;
		if(document.postmodify != null) { document.postmodify.favorite.checked = 'checked'; }
	} else {
		text = remfavlang;
		if(document.postmodify != null) { document.postmodify.favorite.checked = ''; }
	}
	
	var insert = '<div class="tabtitle" style="width: 100%; height: 30%; text-align: center">'+text+'</div><div class="windowbg2" style="width: 100%; height: 70%; text-align: center"><img style="margin:4px" src="' + imagedir + '/Rotate.gif"></div>';
	imagebody.innerHTML = insert;
	imagebody.style.width = "200px";
	imagebody.style.height = "60px";
	imagealert.style.display = "block";
	imagealert.style.visibility = "visible";
	imagealert.style.marginLeft = "-60px";
	imagealert.style.marginTop = "-60px";
	
	xmlHttp.onreadystatechange=AddRemFavFinished;
	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);
}


function AddRemFavFinished() {
	if (xmlHttp.readyState == 4 || xmlHttp.readyState == "complete") {
		document.getElementById("ImageAlertBody").innerHTML = '<div class="tabtitle" style="width: 100%; height: 30%; text-align: center">'+markfinishedlang+'</div><div class="windowbg2" style="width: 100%; height: 70%; text-align: center">&nbsp;</div>';
		setTimeout("HideAlert()",1500);
		var links = document.getElementsByName("favlink");
		for (var i = 0; i < links.length; i++) {
			var href = links[i].href;
			if (href.match("addfav")) {
				links[i].setAttribute("href",href.replace("addfav","remfav"));
				links[i].innerHTML = remlink;
			}
			if (href.match("remfav")) {
				links[i].setAttribute("href",href.replace("remfav","addfav"));
				links[i].innerHTML = addlink;
			}
		}
 	}
}

function Notify(url,imgdir) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url + ";oldnotify=1";
		return;
	}
	imagedir = imgdir;

	var imagealert = document.getElementById("ImageAlert");
	var imagebody = document.getElementById("ImageAlertBody");
	document.getElementById("ImageAlertIFrame").style.display = "none";
	imagebody.style.display = "block";

	var text;
	if (url.match("notify2")) {
		text = addnotelang;
		if(document.postmodify != null) { document.postmodify.notify.checked = 'checked'; }
	} else {
		text = remnotelang;
		if(document.postmodify != null) { document.postmodify.notify.checked = ''; }
	}
	
	var insert = '<div class="tabtitle" style="width: 100%; height: 30%; text-align: center">'+text+'</div><div class="windowbg2" style="width: 100%; height: 70%; text-align: center"><img style="margin:4px" src="' + imagedir + '/Rotate.gif"></div>';
	imagebody.innerHTML = insert;
	imagebody.style.width = "200px";
	imagebody.style.height = "60px";
	imagealert.style.display = "block";
	imagealert.style.visibility = "visible";
	imagealert.style.marginLeft = "-60px";
	imagealert.style.marginTop = "-60px";

	xmlHttp.onreadystatechange=NotifyFinished;
	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);
}

function NotifyFinished() {
	if (xmlHttp.readyState == 4 || xmlHttp.readyState == "complete") {
		document.getElementById("ImageAlertBody").innerHTML = '<div class="tabtitle" style="width: 100%; height: 30%; text-align: center">'+markfinishedlang+'</div><div class="windowbg2" style="width: 100%; height: 70%; text-align: center">&nbsp;</div>';
		setTimeout("HideAlert()",1500);
		var links = document.getElementsByName("notifylink");
		for (var i = 0; i < links.length; i++) {
			var href = links[i].href;
			if (href.match("notify2")) {
				links[i].setAttribute("href",href.replace("notify2","notify3"));
				links[i].innerHTML = remnotlink;
			}
			if (href.match("notify3")) {
				links[i].setAttribute("href",href.replace("notify3","notify2"));
				links[i].innerHTML = addnotlink;
			}
		}
 	} 
}

// Load a pop up post page

function PostPage(url, postboard) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url;
		return;
	}
	var imagealert = document.getElementById("ImageAlert");
	var imageframe = document.getElementById("ImageAlertIFrame");
	var imagebody = document.getElementById("ImageAlertBody");
	imagebody.style.display = "none";
	imagealert.style.display = "block";
	imagealert.style.visibility = "visible";
	imageframe.style.width = "800px";
	
	if (!cachedPostPage) {
		if (cachedIMPage) { ResizeIFrame(50); }
		document.getElementById("ImageAlertLoad").style.display = "block";
		imageframe.height = 0;
		imageframe.src = url + ";popup=1";
		curboard = postboard;
		cachedPostPage = 1;		
	} else {
		if (postboard != curboard) {
			var act = imageframe.contentDocument.forms.postmodify.action;
			act = act.replace("board="+curboard,"board="+postboard);
			imageframe.contentDocument.forms.postmodify.action = act;
			curboard = postboard;
		}
		imageframe.contentWindow.ResizeIFrame();
	}
	cachedIMPage = 0;
	imagealert.style.marginLeft = "-410px";
	imageframe.style.display = "block";
}

function IMPage(url,name,id) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url;
		return;
	}
	var imagealert = document.getElementById("ImageAlert");
	var imageframe = document.getElementById("ImageAlertIFrame");
	var imagebody = document.getElementById("ImageAlertBody");
	imagebody.style.display = "none";
	imagealert.style.display = "block";
	imagealert.style.visibility = "visible";
	imageframe.style.width = "650px";
	
	if (!cachedIMPage) {
		if (cachedPostPage) { ResizeIFrame(50); }
		document.getElementById("ImageAlertLoad").style.display = "block";
		imageframe.height = 0;
		imageframe.src = url + ";popup=1";
		cachedIMPage = 1;		
	} else {
		imageframe.contentWindow.ResizeIFrame();
		var toshow = imageframe.contentDocument.getElementById("toshow");
		for (var i = 0; i < toshow.options.length; i++) {
			toshow.remove(i);
		}
		
		var tmp_option = imageframe.contentDocument.createElement("option");
		tmp_option.value = id;
		tmp_option.text = name;
		toshow.appendChild(tmp_option);
	}
	cachedPostPage = 0;
	imagealert.style.marginLeft = "-335px";
	imageframe.style.display = "block";
}

function sendIM(url,params) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		document.getElementById("ImageAlertIFrame").contentDocument.forms.postmodify.submit();
		return;
	}
	var imagealert = document.getElementById("ImageAlert");
	var imagebody = document.getElementById("ImageAlertBody");
	document.getElementById("ImageAlertIFrame").style.display = "none";
	imagebody.style.display = "block";
	
	var insert = '<div class="tabtitle" style="width: 100%; height: 30%; text-align: center">Sending PM</div><div class="windowbg2" style="width: 100%; height: 70%; text-align: center"><img style="margin:4px" src="' + imagedir + '/Rotate.gif">';
	imagebody.innerHTML = insert;
	imagebody.style.width = "200px";
	imagebody.style.height = "60px";
	imagealert.style.display = "block";
	imagealert.style.visibility = "visible";
	imagealert.style.marginLeft = "-60px";
	imagealert.style.marginTop = "-60px";
	
	xmlHttp.onreadystatechange=IMComplete;
	xmlHttp.open("POST",url + "&popup=1",true);
	xmlHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	xmlHttp.setRequestHeader("Content-length", params.length);
	xmlHttp.setRequestHeader("Connection", "close");
	xmlHttp.send(params);
}

function IMComplete() {
	if (xmlHttp.readyState == 4 || xmlHttp.readyState == "complete") {
		var insert = '<div class="tabtitle" style="width: 100%; height: 30%; text-align: center">Complete</div><div class="windowbg2" style="width: 100%; height: 70%; text-align: center"><img style="margin: 4px;" src="' + imagedir + '/Rotate.gif">';
		document.getElementById("ImageAlertBody").innerHTML = insert;
		setTimeout("HideAlert()",1500);
 	}
}

// Drop down message index for board index

function MessageList(url,board,loadnew) {
	// close previously opened board
	if(boardOpen != "" && !loadnew) {
		document.getElementById("droprow_"+boardOpen).style.display = "none";
		document.getElementById("dropbutton_"+boardOpen).src = openbutton;
		cachedBoards[boardOpen] = document.getElementById("drop_"+boardOpen).innerHTML;
		if (boardOpen == board) {
			boardOpen = "";
			return;
		}
	}
	
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url.substring(0,url.length - 14);
		return;
	}
	
	boardOpen = board;
	
	MessageListInsert('<img src="'+loadimg+'" border="0" />');
	document.getElementById("dropbutton_"+board).src = closebutton;
	
	if (cachedBoards[board] == null || loadnew) {	
		xmlHttp.onreadystatechange=MessageListFinished;
		xmlHttp.open("GET",url,true);
		xmlHttp.send(null);
	} else {
		MessageListInsert(cachedBoards[board]);
	}
}

function MessageListFinished() {
	if (xmlHttp.readyState == 4 || xmlHttp.readyState == "complete") {
		var r = xmlHttp.responseText;
		cachedBoards[boardOpen] = r;
		MessageListInsert(r);
		if (document.getElementById("RunSelDec")) {
			eval(document.getElementById("RunSelDec").innerHTML);
		}
 	} 
}

function MessageListInsert(code) {
	document.getElementById("drop_"+boardOpen).innerHTML = code;
	document.getElementById("droprow_"+boardOpen).style.display = "table-row";	
}

// drop down sub board display

function SubBoardList(url,board,cat,subcount,index) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url;
		return;
	}

	// close any opened MessageList
	if (boardOpen != "") {
		MessageList("",boardOpen,0);
	}

	// close previously opened board
	if(subboardOpen != "") {
		var del = document.getElementById(insertcat).rows;
		var len = del.length;
		for (var i = 0; i < len; i++) {
			if (del.item(i).className == "subboards_of_" + subboardOpen) {
				document.getElementById(insertcat).deleteRow(i);
				len--;
				i--;
			}
		}
		document.getElementById("subdropbutton_"+subboardOpen).src = openbutton;
		if (subboardOpen == board) {
			subboardOpen = "";
			return;
		}
	}
	
	subboardOpen = board;
	insertindex = index;
	insertcat = cat;
	prev_subcount = subcount;
	
	document.getElementById("subdropbutton_"+board).src = closebutton;
	
	if (cachedSubBoards[board] == null) {
		document.getElementById("dropsub_" + subboardOpen).innerHTML = '<img src="'+loadimg+'" border="0" />';
		document.getElementById("dropsubrow_" + subboardOpen).style.display = "table-row";
		
		xmlHttp.onreadystatechange=SubBoardListFinished;
		xmlHttp.open("GET",url + ";a=1",true);
		xmlHttp.send(null);
	} else {
		document.getElementById("dropsub_" + subboardOpen).innerHTML = cachedSubBoards[board];
		InsertSubBoards(index, cat);
	}
}

function SubBoardListFinished() {
	if (xmlHttp.readyState == 4 || xmlHttp.readyState == "complete") {
		var r = xmlHttp.responseText;
		cachedSubBoards[subboardOpen] = r;
		document.getElementById("dropsubrow_" + subboardOpen).style.display = "none";
		document.getElementById("dropsub_" + subboardOpen).innerHTML = r;
		InsertSubBoards(insertindex, insertcat);
 	} 
}

function InsertSubBoards(index, cat) {
	var table = document.getElementById("subloaded_"+subboardOpen);
	
	var cattable = document.getElementById(cat);
	
	var i;
	for (i = table.rows.length - 1; i >= 0 ; i--) {
		var row = cattable.insertRow((index+1) * 3);
		row.className = "subboards_of_" + subboardOpen;
		row.id = table.rows.item(i).id;
		row.style.cssText = table.rows.item(i).style.cssText;
		
		var cells = table.rows.item(i).cells;
		
		for (var j = cells.length - 1; j >= 0; j--) {
			var cell = row.insertCell(0);
			cell.className = cells.item(j).className;
			cell.style.cssText = cells.item(j).style.cssText;
			cell.align = cells.item(j).align;
			cell.width = cells.item(j).width;
			cell.colSpan = cells.item(j).colSpan;
			cell.innerHTML = cells.item(j).innerHTML;
		}
	}
	MakeCollapseBars(cattable, (index+1) * 3);
	MakeCollapseBars(cattable, (index+1) * 3 + table.rows.length + 1);
	
	document.getElementById("dropsub_" + subboardOpen).innerHTML = "";
}

function MakeCollapseBars(table, index) {
	var row = table.insertRow(index);
	row.className = "subboards_of_" + subboardOpen;
	var cell = row.insertCell(0);
	cell.colSpan = "5";
	cell.align = "center";
	cell.className = "tabtitle";
	cell.innerHTML = arrowup;
	cell.style.cursor = "pointer";
	cell.onclick = function () {
		var elem = document.getElementById("subdropbutton_"+subboardOpen);
		if (typeof elem.onclick == "function") {
   			elem.onclick.apply(elem);
		}
	};
}

// Quick switcher for message index page listing

function SwitchPageList(oldurl, sendurl, closelist, openlist) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		window.location = url;
		return;
	}
	
	document.getElementById(closelist).style.display = "none";
	document.getElementById(closelist + '2').style.display = "none";
	document.getElementById(openlist).style.display = "inline-block";
	document.getElementById(openlist + '2').style.display = "inline-block";
	
	xmlHttp.open("GET",sendurl,true);
	xmlHttp.send(null);
}

function AlertResults()
{
	if (xmlHttp.readyState == 4 || xmlHttp.readyState == "complete") {
		alert(xmlHttp.responseText);
	} 
}

// Login check credentials

function CheckCredentials(url) {
	GetXmlHttpObject();
	if (xmlHttp == null) {
		document.loginform.action = url.substring(0,url.length - 15);
		document.loginform.onsubmit = null;
		document.loginform.submit();
		return;
	}
	var params = "username=" + document.getElementById("username").value + "&passwrd=" + document.getElementById("passwrd").value + "&cookielength=" + document.getElementById("cookielength").value + "&formsession=" + document.forms[0].formsession.value;
	
	xmlHttp.onreadystatechange=CredentialResults;
	xmlHttp.open("POST",url,true);
	xmlHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	xmlHttp.setRequestHeader("Content-length", params.length);
	xmlHttp.setRequestHeader("Connection", "close");
	xmlHttp.send(params);
}

function CredentialResults() {
	if (xmlHttp.readyState == 4 || xmlHttp.readyState == "complete") {
		var r = xmlHttp.responseText;
		if(r.substring(0,5) == "error") {
			document.getElementById("credresults").innerHTML = r.substring(5);
		} else {
			document.getElementById("credresults").style.display = "none";
			document.getElementById("credresults").innerHTML = r;
			window.location = r.substring(r.indexOf("confirmed") + 9);
		}
	} 
}

function enterKey(e) {
	var e = window.event || e;
	if(e.keyCode == 13){
		document.loginform.submitlogin.click();
	}
}

//---------------
// Member Search
//---------------
var list = new Array();
var list2 = new Array();
var first = "";

function LetterChange(text) {
	text = text.toLowerCase()
	if (text.length == 1) {
		if (list[text] == null) {
			first = text;
			SendLetter(text);
		} else {
			first = text;
			ListNames(list[text],list2[text]);
		}
	} else if (text.length > 1) {
		var temp = new Array();
		var temp2 = new Array();
		for(var i = 0; i < list[first].length; i++) {
			text = text.toLowerCase();
			var regex = new RegExp("^" + text);
			if(list[first][i].toLowerCase().match(regex)) {
				temp[temp.length] = list[first][i];
				temp2[temp2.length] = list2[first][i];
			}
		}
		ListNames(temp,temp2);
	}
}

function SendLetter(letter) {
	GetXmlHttpObject();
	if (xmlHttp == null) { alert("AJAX not supported."); return; }
	document.getElementById("load").src = imageurl + "/mozilla_blu.gif";
	xmlHttp.onreadystatechange=Response;
	xmlHttp.open("GET", scripturl + "?action=qsearch2;letter=" + letter, true);
	xmlHttp.send(null);
}

function Response() {
	if (xmlHttp.readyState==4 || xmlHttp.readyState=="complete") { 
		document.getElementById("load").src = imageurl + "/mozilla_gray.gif";
		var results = new Array();
		document.getElementById("response").innerHTML = xmlHttp.responseText;
		list[first] = new Array();
		list2[first] = new Array();
		var temp = new Array();
		temp = document.getElementById("response").innerHTML.split(",");
		for (var i = 0; i < temp.length; i++) {
			if ((i % 2) == 0) { list[first][list[first].length] = temp[i]; }
			else { list2[first][list2[first].length] = temp[i]; }
		}
		if (list[first] == "") { list[first] = new Array(); }
		ListNames(list[first],list2[first]);
	}
}

function ListNames(names,ids) {
		var select = document.getElementById("rec_list");
		select.options.length = 0;
		for (var i = 0; i < names.length; i++) {
			browserAdd(names[i],ids[i]);
		}
		if (select.options.length == 0) { browserAdd(noresults,""); }
}

function browserAdd(name,value) {
	var select = document.getElementById("rec_list");
	if (navigator.appName == "Microsoft Internet Explorer") {
		select.add(new Option(name,value));
	} else {
		select.add(new Option(name,value),null);
	}
}
// End Member Search

// Check username availability
function checkAvail(scripturl,val,type,namenotid) {

	document.getElementById(type + "availability").innerHTML = '';
	if (val == '') return;

	var tmptype = type;
	if (namenotid == 1) {
		if (type == 'user')    { if (val == document.getElementById('regrealname').value) tmptype = 'nouserid'; }
		if (type == 'display') { if (val == document.getElementById('regusername').value) tmptype = 'nodisplay'; }
	}
	var valstr = '';
	for (i = 0; i < val.length; i++) {
		if (val.charCodeAt(i) > 127) valstr += '[ch' + val.charCodeAt(i) + ']';
		else valstr += val.charAt(i);
	}
	var urivalstr = encodeURIComponent(valstr);
	GetXmlHttpObject();
	if (xmlHttp == null) { alert("AJAX not supported."); return; }
	xmlHttp.onreadystatechange=returnAvail;
	xmlHttp.open("GET", scripturl + "?action=checkavail;type=" + tmptype + ";" + type + "=" + urivalstr, true);
	xmlHttp.send(null);
}

function returnAvail() {
	if (xmlHttp.readyState==4 || xmlHttp.readyState=="complete") {
		var avail = xmlHttp.responseText;
		var type = avail.split("|");
		document.getElementById(type[0] + "availability").innerHTML = type[1];
	}
}

function HideAlert() {
	document.getElementById("ImageAlert").style.display = "none";
	document.getElementById("ImageAlert").style.visibility = "hidden";
}

function GetXmlHttpObject() {
	try { // test if ajax is supported
		if (typeof( new XMLHttpRequest() ) == 'object') {
			xmlHttp = new XMLHttpRequest();
		} else if (typeof( new ActiveXObject("Msxml2.XMLHTTP") ) == 'object') {
			xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
		} else if (typeof( new ActiveXObject("Microsoft.XMLHTTP") ) == 'object') {
			xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
		}
	} catch (e) { }
}