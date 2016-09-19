<script type="text/javascript">

	var <portlet:namespace/>LBL_YOU = '<liferay-ui:message key="de.iisys.shindigmsg.you" />';
	var <portlet:namespace/><portlet:namespace/>USER_DUMMY_PIC_URL = '/image/user_female_portrait';

	//control (GET):
	function <portlet:namespace/>getHashtagMessages(userId) {
		if(<portlet:namespace/>hashtag != "") {
			<portlet:namespace/>showHashtagDetails("hashtags");
			
			var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>MESSAGES_FRAG + userId + "/@outbox" +
				"?startIndex="+<portlet:namespace/>curHashtags+
				"&count="+<portlet:namespace/>MESSAGES_PER_PAGE +
				"&sortBy=timeSent&sortOrder=descending"+
				"&filterBy=urls&filterOp=contains&filterValue="+<portlet:namespace/>hashtag;
				if(<portlet:namespace/>SHINDIG_TOKEN != null) url += "&st="+<portlet:namespace/>SHINDIG_TOKEN;
				
			<portlet:namespace/>sendAsyncRequest('GET', url, <portlet:namespace/>showHashtagMessages);
		}
	}
	
	function <portlet:namespace/>getMultipleUserDetails(userIds, targetBox) {
		if(userIds.length > 0) {
			var users = "";
			for(var i=0; i<userIds.length; i++) {
				if(i>0) users += ",";
				users += userIds[i];
			}
			var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG + users + '?count='+userIds.length;
			switch(targetBox) {
				case "inbox":
					<portlet:namespace/>sendAsyncRequest('GET', url, <portlet:namespace/>showInboxUserDetails); break;
				case "@outbox":
					<portlet:namespace/>sendAsyncRequest('GET', url, <portlet:namespace/>showOutboxUserDetails); break;
				case "@wall":
					<portlet:namespace/>sendAsyncRequest('GET', url, <portlet:namespace/>showWallUserDetails); break;
				case "hashtags":
					<portlet:namespace/>sendAsyncRequest('GET', url, <portlet:namespace/>showHashtagUserDetails); break;
			}	
		}
	}
	
	
	// view(callback):
	function <portlet:namespace/>showHashtagMessages(data) {
		<portlet:namespace/>updatePaginationView('hashtags',data.totalResults,<portlet:namespace/>curHashtags);
		<portlet:namespace/>showMessages(data, 'hashtags');
	}
	
	function <portlet:namespace/>showMessages(data, targetDiv) {
		if(!data.error) {
			var userIds = [];
			var html = "";
			
			if(data.totalResults===0) {
				html += '<em><liferay-ui:message key="de.iisys.shindigmsg.noMsgToDisplay" /></em>';
			} else {
				var showMaxTemp = <portlet:namespace/>MESSAGES_PER_PAGE;
				var temp = "";
				html += '<table class="table table-bordered table-hover table-striped">'+
					'<tbody class="table-data">';
				
				for(var i=0; (i<showMaxTemp && i<data.list.length); i++) {
					var msg = data.list[i];
					
					var type = "";
					if(msg.type) type = msg.type;
					
					if(targetDiv==="inbox" && msg.type && msg.type==="publicMessage") {
						showMaxTemp++;
						continue;
					}
					if(targetDiv==="@wall")
						var collectionId = "inbox";
					else
						var collectionId = targetDiv;
					
					if(<portlet:namespace/>highlightedMsg && <portlet:namespace/>highlightedMsg===msg.id)
						var highlighted = true;
					else
						var highlighted = false;
					
					temp = <portlet:namespace/>createTableRow(msg.id, msg.senderId, msg.title, msg.body, msg.timeSent, msg.recipients, collectionId, type, highlighted);
					html += temp;
	
					
					if(msg.senderId != <portlet:namespace/>USER_ID)
						userIds.push(msg.senderId);
					for(var j=0; j<msg.recipients.length; j++) {
						// every userId is added once:
						if( msg.recipients[j] != <portlet:namespace/>USER_ID && userIds.indexOf(msg.recipients[j])===-1 ) {
							userIds.push(msg.recipients[j]);
						}
					}
					
					
					var mentions = <portlet:namespace/>findMentions(msg.body);
					for(var j=0; j<mentions.length; j++) {	
						var mention = mentions[j].substring(1,mentions[j].length-1);
						if( mention != <portlet:namespace/>USER_ID && userIds.indexOf(mention)===-1 ) {
							userIds.push(mention);
						}
					}
					
				}	  
				html += '</tbody></table>';
			}
			
			document.getElementById('<portlet:namespace/>'+targetDiv).innerHTML = html;
			
			if(data.totalResults!==0) { // add user names:
				<portlet:namespace/>getMultipleUserDetails(userIds, targetDiv);
			}
		} else { // if(data.error)
			if(data.error.value) {
				alert(data.error.value);
		    } else if(data.error.message) {
				alert(data.error.message);
		    } else {
				alert(data.error);
		    }
		}
	}
		
	function <portlet:namespace/>showInboxUserDetails(data) {
		<portlet:namespace/>showAllUserDetails(data, "inbox");
	}
	function <portlet:namespace/>showOutboxUserDetails(data) {
		<portlet:namespace/>showAllUserDetails(data, "@outbox");
	}
	function <portlet:namespace/>showWallUserDetails(data) {
		<portlet:namespace/>showAllUserDetails(data, "@wall");
	}
	function <portlet:namespace/>showHashtagUserDetails(data) {
		<portlet:namespace/>showAllUserDetails(data, "hashtags");
	}
	function <portlet:namespace/>showAllUserDetails(data, targetBox) {
		var box = document.getElementById('<portlet:namespace/>'+targetBox);
		
		if(data.list) {
			for(var i=0; i<data.list.length; i++) {
				var spans = box.getElementsByClassName("user-"+data.list[i].id);
				for(var j=0; j<spans.length; j++) {
					spans[j].innerHTML = data.list[i].displayName;
				}
				if(data.list[i].thumbnailUrl) {
				var imgs = box.getElementsByClassName("user-img-"+data.list[i].id);
					for(var k=0; k<imgs.length; k++) {
						imgs[k].src = data.list[i].thumbnailUrl;
						imgs[k].alt = data.list[i].displayName;
					}
				}
			}
		} else {
			var spans = box.getElementsByClassName("user-"+data.entry.id);
			for(var j=0; j<spans.length; j++) {
				spans[j].innerHTML = data.entry.displayName;
			}
			if(data.thumbnailUrl) {
			var imgs = box.getElementsByClassName("user-img-"+data.entry.id);
				for(var k=0; k<imgs.length; k++) {
					imgs[k].src = data.entry.thumbnailUrl;
					imgs[k].alt = data.entry.displayName;
				}
			}
		}
	}
	
	// view:
		
	function <portlet:namespace/>createTableRow(msgId,sender,title,msg,date,recipients,collectionId,type, highlighted) {
		var typeIcon;
		var reci = "";
		
		msg = <portlet:namespace/>addHashtagsToHtml(msg);
		msg = <portlet:namespace/>addMentionsToHtml(msg);
		
		if(type=='publicMessage')
			typeIcon = 'icon-globe';
		else
			typeIcon = 'icon-lock';
		
		// if group-message or outbox-message, then recipients are added to view:
		if(recipients.length > 1 || sender === <portlet:namespace/>USER_ID) {
			reci = '<span style="color:#999">';
			for(var i=0; i<recipients.length; i++) {
				if(recipients[i] != <portlet:namespace/>USER_ID) {
					if(i===0 || (i===1 && recipients[0] === <portlet:namespace/>USER_ID) )
						reci += ' <i class="icon-long-arrow-right"></i> ';
					else
						reci += ', ';
					reci += '<a href="'+<portlet:namespace/>LIFERAY_PROFILE_URL+recipients[i]+'" style="color:#999">'
						+ '<span class="user-'+recipients[i]+'">'+recipients[i]+'</span>'
						+ '</a>';
				}
			}
			if(sender != <portlet:namespace/>USER_ID)
				reci+=', '+<portlet:namespace/>LBL_YOU;
			else
				sender = <portlet:namespace/>LBL_YOU;	
			reci += '</span>';
		}
		
		var html = '<tr id="<%= renderResponse.getNamespace()%>message-'+msgId+'">';
		html += '<td class="table-cell first last';
		if(highlighted===true) html += ' highlighted';
		html += '">';
			
		html += '<div class="taglib-user-display display-style-2"> <a href=""> '+
			'<span class="user-profile-image"> '+
				'<img alt="" class="avatar user-img-';
					if(sender === <portlet:namespace/>LBL_YOU) html += recipients[0];
					else html += sender;
		html +=	'" src="'+<portlet:namespace/><portlet:namespace/>USER_DUMMY_PIC_URL+'">'+
			' </span> '+
			'<span class="user-name user-'+sender+'"> '+sender+
			' </span> </a> <div class="user-details"> </div> </div>';
			
		html += '<div class="last-thread"> <div class="message-link"> '+
				'<span class="author-sender">';
		if(sender != <portlet:namespace/>LBL_YOU) html += '<a href="'+<portlet:namespace/>LIFERAY_PROFILE_URL+sender+'">';
		html += 	'<span class="user-'+sender+'">'+sender+'</span>';
		if(sender != <portlet:namespace/>LBL_YOU) html += '</a>';
		html += reci+' </span>'+
				'<span class="date"> '+<portlet:namespace/>displayTime(date)+
					' <a href="" onclick="<portlet:namespace/>deleteMessage(\''+<portlet:namespace/>USER_ID+'\', \''+collectionId+'\', \''+msgId+'\');return false;" style="color:#666;"><i class="icon-remove"></i></a></span> '+
				'<div class="subject"> '+title+'</div> '+
				'<div class="body">'+
	//				'<a href="" onclick="<portlet:namespace/>showCommentBox(this);return false;" style="color:#666;"><i class="icon-reply"></i></a> '+
					'<i class="'+typeIcon+'" style="color:#999;"></i> ' + msg +
				' </div>'+
			'</div></div>';	
				
		html += '</td></tr>';
		
		return html;
	}
	
	function <portlet:namespace/>addHashtagsToHtml(htmlIn) {
		var url = <portlet:namespace/>LIFERAY_URL + <portlet:namespace/>LIFERAY_HASHTAGWIKI;
		if(url.indexOf("/", this.length-1)== -1) url += "/";
		
		var tags = <portlet:namespace/>findHashtags(htmlIn);
		for(var i=0; i<tags.length; i++) {
			var showTag = tags[i].substring(1).toLowerCase();
			// gimmick:
			switch(showTag) {
			case "android": showTag = '<i class="icon-android"></i>'+showTag; break;
			case "apple": showTag = '<i class="icon-apple"></i>'+showTag; break;
			case "bitbucket": showTag = '<i class="icon-bitbucket"></i>'+showTag; break;
			case "bitcoin": showTag = '<i class="icon-bitcoin"></i>'+showTag; break;
			case "buggy":
			case "bug": showTag = '<i class="icon-bitcoin"></i>'+showTag; break;
			case "dropbox": showTag = '<i class="icon-dropbox"></i>'+showTag; break;
			case "euro": showTag = '<i class="icon-euro"></i>'+showTag; break;
			case "instagram": showTag = '<i class="icon-instagram"></i>'+showTag; break;
			case "linux": showTag = '<i class="icon-linux"></i>'+showTag; break;
			case "skype": showTag = '<i class="icon-skype"></i>'+showTag; break;
			case "stackexchange":
			case "stackoverflow": showTag = '<i class="icon-stackexchange"></i>'+showTag; break;
			case "windows": showTag = '<i class="icon-windows"></i>'+showTag; break;
			case "xing": showTag = '<i class="icon-xing"></i>'+showTag; break;
			case "youtube": showTag = '<i class="icon-youtube"></i>'+showTag; break;
			default: showTag = '#'+showTag;
			}	
		
			htmlIn = htmlIn.replace(tags[i], '<a href="'+url+tags[i].substring(1).toLowerCase()+'">'+showTag+'</a>');
		}
		return htmlIn;
	}
	
	function <portlet:namespace/>addMentionsToHtml(htmlIn) {
		var url = <portlet:namespace/>LIFERAY_URL + <portlet:namespace/>LIFERAY_PROFILE_URL;
		
		var mentions = <portlet:namespace/>findMentions(htmlIn);
		for(var i=0; i<mentions.length; i++) {
			var mention = mentions[i].substring(1,mentions[i].length-1);
			htmlIn = htmlIn.replace(mentions[i], '<a href="'+url+mention+'" class="user-'+mention+'">'+mention+'</a>');
		}
		return htmlIn;
	}
	
	function <portlet:namespace/>showCommentBox(element) {
		var messageLink = element.parentNode.parentNode;
		
		messageLink.innerHTML += '<form onsubmit="console.log(\'Hallo\');" class="comment-form"><input type="text" name="" placeholder="'+'<liferay-ui:message key="de.iisys.shindigmsg.leaveComment" />'+'" /></form>';
	}
	
	// helper:
		
	function <portlet:namespace/>getUserPicSrc(userId) {
		var url = <portlet:namespace/>SHINDIG_URL + "/pictures/"+userId+".png";
		return url;
	}

	function <portlet:namespace/>displayTime(time) {
	    var date = new Date(time);
	  	
	    // year:
	    var display = date.getFullYear() + '/';
	    // month:
	    var month = date.getMonth() + 1;
	    if(month < 10)
	    {
	      month = '0' + month;
	    }
	    display += month + '/';
	    
	    
	    var days = date.getDate();
	    if(days < 10)
	    {
	    	days = '0' + days;
	    }    
	    display += days + ' ';
	    
	    var hours = date.getHours();
	    if(hours < 10)
	    {
	      display += '0';
	    }
	    display += hours + ':';
	    
	    var minutes = date.getMinutes();
	    if(minutes < 10)
	    {
	      display += '0';
	    }
	    display += minutes;
	    
	    return display;
	}
	
	// pagination:
		
	function <portlet:namespace/>updatePaginationView(targetBox,totalMessages,curMsgStart) {
		var totalPages = Math.ceil( totalMessages / <portlet:namespace/>MESSAGES_PER_PAGE );
		var curPage = Math.ceil( (curMsgStart+1) / <portlet:namespace/>MESSAGES_PER_PAGE );
		
		var THREE_DOTS = '<li class="disabled"><a href="#" onclick="return false;">...</a></li>';

		
		// page "prev":
		var temp = '<li'; 
		if(curPage===1) temp += ' class="disabled"';
		temp += '><a href="#" onclick="';
		if(curPage > 1) temp += "<portlet:namespace/>prevPage('" + targetBox + "'); ";
		temp+= 'return false;" class="icon-chevron-left"></a></li>';
		// page 1:
		temp += '<li';
		if(curPage===1) temp += ' class="active"';
		temp += '><a href="#" onclick="';
		if(curPage!=1) temp += '<portlet:namespace/>changePage(\''+targetBox+'\',1); ';
		temp += 'return false;">1</a></li>';
		// three dots:
		if(curPage > 2) temp += THREE_DOTS;
		// current page:
		if(curPage > 1  &&  curPage < totalPages)
			temp += '<li class="active"><a href="#" onclick="return false;">'+curPage+'</a></li>';
		// three dots:
		if(curPage < (totalPages-1)) temp += THREE_DOTS;
		// last page:
		if(totalPages > 1) {
			temp += '<li';
			if(curPage===totalPages) temp += ' class="active"';
			temp += '><a href="#" onclick="';
			if(curPage!=totalPages) temp += '<portlet:namespace/>changePage(\''+targetBox+'\','+totalPages+'); ';
			temp += 'return false;">'+totalPages+'</a></li>';
		}
		// page "next":
		temp += '<li';
		if(totalPages<=curPage) temp += ' class="disabled"';
		temp += '><a href="#" onclick="';
		if(curPage < totalPages) temp += '<portlet:namespace/>nextPage(\''+targetBox+'\'); ';
		temp += 'return false;" class="icon-chevron-right"></a></li>';
		
		document.getElementById('<portlet:namespace/>'+targetBox+'-pages').innerHTML = temp;
	}
	
	function <portlet:namespace/>nextPage(targetBox) {
		<portlet:namespace/>changePage(targetBox,"+1");
	}
	function <portlet:namespace/>prevPage(targetBox) {
		<portlet:namespace/>changePage(targetBox,"-1");
	}
	function <portlet:namespace/>changePage(targetBox,pageNr) {
		var tempCur;
		
		switch(targetBox) {
			case "inbox":
				tempCur = <portlet:namespace/>curInbox; break;
			case "@outbox":
				tempCur = <portlet:namespace/>curOutbox; break;
			case "@wall":
				tempCur = <portlet:namespace/>curWall; break;
			case "hashtags":
				tempCur = <portlet:namespace/>curHashtags; break;
		}
		
		switch(pageNr) {
			case "+1":
				tempCur += <portlet:namespace/>MESSAGES_PER_PAGE;
				break;
			case "-1":
				tempCur -= <portlet:namespace/>MESSAGES_PER_PAGE;
				if(tempCur < 0) tempCur = 0;
				break;
			default:
				tempCur = (pageNr-1) * <portlet:namespace/>MESSAGES_PER_PAGE;
		}
		
		switch(targetBox) {
			case "inbox":
				<portlet:namespace/>curInbox = tempCur;
				<portlet:namespace/>getInboxMessages(<portlet:namespace/>USER_ID);
				break;
			case "@outbox":
				<portlet:namespace/>curOutbox = tempCur;
				<portlet:namespace/>getOutboxMessages(<portlet:namespace/>USER_ID);
				break;
			case "@wall":
				<portlet:namespace/>curWall = tempCur;
				<portlet:namespace/>getWallMessages(<portlet:namespace/>USER_ID);
				break;
			case "hashtags":
				<portlet:namespace/>curHashtags = tempCur;
				<portlet:namespace/>getHashtagMessages(<portlet:namespace/>USER_ID);
		}
	}
	
</script>