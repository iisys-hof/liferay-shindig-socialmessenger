<%
/**
 * Copyright (c) 2015-present. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * Created for: Social Collaboration Hub (www.sc-hub.de)
 * Created at: Institute for Information Systems (www.iisys.de/en)
 * @author: Christian Ochsenkühn
 */
%>

<%@include file="/html/init.jsp" %>

<%@ page import="com.liferay.portal.model.User"%>
<%@ page import="com.liferay.portal.service.UserLocalServiceUtil"%>


<%
	User receiver = null;
	long msgId = ParamUtil.getLong(request, "msgId");
	
	String redirect = ParamUtil.getString(request, "redirect");
	String firstRecipient = ParamUtil.getString(request, "firstRecipient", "");
	String firstRecipientName = "";
	if(!firstRecipient.isEmpty()) {
		firstRecipientName = UserLocalServiceUtil.getUserByScreenName(themeDisplay.getCompanyId(), firstRecipient).getFullName();
	}
%>

<liferay-portlet:resourceURL id="sendMessage" var="startNotificationURL" />	



<portlet:resourceURL var="getUsers">
       <portlet:param name="<%=Constants.CMD%>" value="get_users" />
</portlet:resourceURL>


<portlet:renderURL var="viewMessageURL" />
<portlet:actionURL name="addMessage" var="addMessageURL" windowState="normal" />

<liferay-ui:header backURL="<%= viewMessageURL %>" title="de.iisys.shindigmsg.newMessage" />

<div class="new-social-message">

	<div class="portlet-msg-success" style="display:none;" id="<portlet:namespace/>successMsg"></div>

	<liferay-portlet:resourceURL id="autocomplete" var="autocompleteURL" />
	<aui:button-row>
		<label><liferay-ui:message key="de.iisys.shindigmsg.addRecipients" /></label>
		<aui:button onClick='<%= renderResponse.getNamespace() + "addRecipientByInput();"%>' value="add"  cssClass="pull-left" />
        <aui:input id="userName" name="userName" type="text" cssClass="pull-left" label="" value="<%= firstRecipientName %>" />
        <aui:input name="userIdToBeSaved" type="hidden" value="<%= firstRecipient %>" />
    </aui:button-row>


	<aui:form action="<%= addMessageURL %>" method="POST" name="fm" label="de.iisys.shindigmsg.newMessage">
		<aui:fieldset>
			<aui:input name="redirect" type="hidden" value="<%= redirect %>" />
			
			<label><liferay-ui:message key="de.iisys.shindigmsg.recipients" /></label>
			<div id="<portlet:namespace/>recipients">
				<p class="dummy"> - </p>
				<!--
				<p class="highlighted">Bärbel Bitte <i class="icon-remove" style="color:#bf1616; cursor:pointer;" onclick="" title="<liferay-ui:message key='de.iisys.shindigmsg.remove' />"></i></p>
				<aui:input name="recipient1" class="TESTrecipient" type="hidden" value="5473" />
				 -->
			</div>
			
			<aui:input id="toUserId" name="toUserId" type="hidden" value="" />
			<aui:input id="firstName" name="firstName" type="hidden" value="" />
			<aui:input id="lastName" name="lastName" type="hidden" value="" />
			<aui:input id="userMail" name="userMail" type="hidden" value="" />
	
			<aui:input id="title" name="title" type="text" label="de.iisys.shindigmsg.title" cssClass="input-long" />
	        <aui:input id="msgContent" name="msgContent" type="textarea" label="de.iisys.shindigmsg.message" value="" cssClass="input-long" helpMessage="de.iisys.shindigmsg.useHashtags" />
			
			<div id="<portlet:namespace/>user-mentions"></div>
			
			<%--  <aui:select id="isPublic" name="isPublic" label="de.iisys.shindigmsg.privacy">
				<aui:option value="false"> <liferay-ui:message key="de.iisys.shindigmsg.private" /> </aui:option>
				<aui:option value="true"> <liferay-ui:message key="de.iisys.shindigmsg.public" /> </aui:option>
			</aui:select> --%>
		</aui:fieldset>
		
		<div id="<portlet:namespace/>loader"></div>
		
		<aui:button-row>
	        <aui:button onClick='<%= renderResponse.getNamespace() + "startNewMessage(\'false\');"%>' name="sendButton" value="de.iisys.shindigmsg.sendPrivate" disabled="<%= false %>" primary="<%= true %>" icon="icon-lock" />
			<aui:button onClick='<%= renderResponse.getNamespace() + "startNewMessage(\'true\');"%>' name="sendPublicButton" value="de.iisys.shindigmsg.sendPublic" disabled="<%= false %>" primary="<%= true %>" icon="icon-globe" />
	        <aui:button onClick="<%= viewMessageURL %>"  type="cancel" />
	    </aui:button-row>
	</aui:form>
</div>


<aui:script>
		
	// vars:
		
	var <portlet:namespace/>ACTIVITY_FRAG = "/social/rest/activitystreams/";
	var <portlet:namespace/>CREATE_ACTIVITY = '<%= GetterUtil.getString( portletPreferences.getValue("createActivity", StringPool.TRUE) ) %>';
	
	var <portlet:namespace/>firstRecipient = '<%= firstRecipient %>';
	
	var <portlet:namespace/>REGEX_USER_NAME = /@(.*[^\s]+)$/;
	var <portlet:namespace/>MAP_MENTIONS = {};
	
	// temp vars:
	var <portlet:namespace/>tempReceiverFullname;
	
	
	
	// control:
		
	function <portlet:namespace/>init() {
		<portlet:namespace/>addRecipientByInput();
		
		// test:
		var recipients =  ["anna"];
		<portlet:namespace/>tempReceiverFullname = "Anna Alster";
		var message = <portlet:namespace/>createMessageJSON(recipients,
				"Wichtige Besprechung",
				"Hi Anna, bitte denk an unser Meeting! Nicht, dass du wieder nicht das bist...",
				"publicMessage",false,false);
//		<portlet:namespace/>sendActivity(message, "messages:0");
	}

	
	function <portlet:namespace/>sendMessage(recipients,title,message,isPublic) {	
		var userId = <portlet:namespace/>USER_ID;
		
		if(isPublic=="true")
			var type = "publicMessage";
		else
			var type = "privateMessage";
		
		var hashtags = <portlet:namespace/>findHashtags(message);
		var mentions = <portlet:namespace/>findMentions(message);
		
		var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>MESSAGES_FRAG +userId+"/@outbox";
		if(<portlet:namespace/>SHINDIG_TOKEN != null) url += "?st="+<portlet:namespace/>SHINDIG_TOKEN;
		
		var payload = <portlet:namespace/>createMessageJSON(recipients,title,message,type,hashtags,mentions);
		
		<portlet:namespace/>sendAsyncRequest('POST', url, <portlet:namespace/>showMessageState, payload, payload);
	}
	
	function <portlet:namespace/>sendActivity(message, msgId) {			
		var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>ACTIVITY_FRAG +message.senderId+"/@self";
		if(<portlet:namespace/>SHINDIG_TOKEN != null) url += "?st="+<portlet:namespace/>SHINDIG_TOKEN;
		
		var payload = <portlet:namespace/>createMessageActivity(message, msgId);
		
		<portlet:namespace/>sendAsyncRequest('POST', url, <portlet:namespace/>showActivityState, payload);
	}
	
	function <portlet:namespace/>createMessageJSON(recipients,title,message,type,hashtags,mentions) {
		var recipientsString = '[';
		for(var i=0; i<recipients.length; i++) {
			if(i>0)
				recipientsString += ', ';
			recipientsString += '"'+recipients[i]+'"';
		}
		recipientsString += "]";
		var recipientsObj = JSON.parse(recipientsString);
		
		var urlsString = "[";
		for(var i=0; i<hashtags.length; i++) {
			if(i>0)
				urlsString += ', ';
			urlsString += '{"type" : "hashtag", "value" : "/hashtag/-/wiki/Main/'+hashtags[i].substring(1).toLowerCase()+'"}';
		}
		for(var j=0; j<mentions.length; j++) {
			if(j>0 || i>0)
				urlsString += ', ';
			urlsString += '{"type" : "mentioned", "value" : "'+<portlet:namespace/>LIFERAY_PROFILE_URL+mentions[j].substring(1,mentions[j].length-1).toLowerCase()+'"}';
		}
		urlsString += "]";
		var urls = JSON.parse(urlsString);
		
		var jsonMsg = {
			"recipients" : recipientsObj,
			"title" : title,
			"body" : message,
			"senderId" : <portlet:namespace/>USER_ID,
			"type" : type,
			"urls" : urls
			};
		console.log("Created JSON: \n"+JSON.stringify(jsonMsg));
		return jsonMsg;
	}
	
	function <portlet:namespace/>createMessageActivity(message, msgId) {
		var shortMsg = message.body;
		if(shortMsg.length>25)
			shortMsg = shortMsg.substring(0,24)+'...';
		
		if(!msgId || msgId==null)
			msgId = "";
		
		var msgUrl = <portlet:namespace/>LIFERAY_PROFILE_URL + message.recipients[0] + '&<portlet:namespace/>highlightedMsg='+msgId;
		
		var msgDisplayName = '<liferay-ui:message key="de.iisys.shindigmsg.aMessage" />';
		
		var json = {
				"actor" : {
					"id" : <portlet:namespace/>USER_ID,
					"displayName" : <portlet:namespace/>USER_NAME,
					"objectType" : "person"
				},
				"generator" : {
					"id" : "shindig-socialmessaging",
					"displayName" : "Social Messenger",
					"objectType" : "application",
				},
				"object" : {
					"id" : msgId,
					"displayName" : msgDisplayName,
					"objectType" : "message",
					"url" : msgUrl
				},
				"target" : {
					"id" : message.recipients[0],
					"displayName" : <portlet:namespace/>tempReceiverFullname,
					"objectType" : "person"
				},
				"verb" : "send",
				"title" : message.title+": "+shortMsg,
				"provider" : {
					"id" : "liferay",
					"objectType" : "application",
					"displayName" : "Liferay",
					"url" : <portlet:namespace/>LIFERAY_URL
				}
			};
		
		return json;
	}
	
	// AJAX server calls:
	
	
	function <portlet:namespace/>startNotificationOnServer(msgId, recipientId, senderId, msgText, type) {
		
		AUI().use('aui-io-request', function(A){
	        A.io.request('<%=startNotificationURL.toString()%>', {
	               method: 'post',
	               data: {
	            	   <portlet:namespace />msgId: msgId,
	            	   <portlet:namespace />recipient: recipientId,
	            	   <portlet:namespace />senderId: senderId,
	            	   <portlet:namespace />msgText: msgText,
	            	   <portlet:namespace />type: type
	            	   
	               },
	               on: {
	                    success: function() {
//	                     	<portlet:namespace />showFullNameInHtml(screenName, this.get('responseData'));
	               		}
	               }
	            });
	    });
		
	}
	
	
	// view (callback):

	function <portlet:namespace/>startNewMessage(isPublic) {
		var recipients =  [];
		var inputs = document.getElementById('<portlet:namespace/>'+'recipients').getElementsByClassName("recipient");	
		for(var i=0; i<inputs.length; i++) {
			console.log(inputs[i].value);
			recipients.push(inputs[i].value);
		}
		
		if(recipients.length > 0) {
			var message = document.getElementById('<portlet:namespace/>'+'msgContent').value;
			var title = document.getElementById('<portlet:namespace/>'+'title').value;
//			var isPublic = document.getElementById('<portlet:namespace/>'+'isPublic').value;
			
			<portlet:namespace/>sendMessage(recipients,title,message,isPublic);
		} else {
			var jsonError = {
				"error" : '<liferay-ui:message key="de.iisys.shindigmsg.noRecipient" />'
				};
			<portlet:namespace/>showMessageState(jsonError);
		}
		
		if(recipients.length === 1) {
			var inp = document.getElementById('<portlet:namespace/>'+'recipients').getElementsByClassName("recipientName");
			if(inp[0])
				<portlet:namespace/>tempReceiverFullname = inp[0].value;
		}
	}
	
	function <portlet:namespace/>addRecipientByInput() {
		var rec = document.getElementById('<portlet:namespace/>'+'userName').value;
		var recId = document.getElementById('<portlet:namespace/>'+'userIdToBeSaved').value;
		
		// debug:
		if(recId=="") recId = rec;
		
		<portlet:namespace/>addRecipient(rec, recId);
	}
	function <portlet:namespace/>addRecipient(recipient, recipientId) {
		if(recipientId!="") {
			document.getElementById('<portlet:namespace/>'+'userName').value = "";
			
			var html = '<p class="highlighted">'+recipient+
				' <a href="#" onclick="<portlet:namespace/>removeRecipient(this.parentNode); return false;">'+
				'<i class="icon-remove" style="color:#bf1616; cursor:pointer;" onclick="" title=""></i></a>'+
				'<input class="recipient" type="hidden" value="'+recipientId+'" />'+
				'<input class="recipientName" type="hidden" value="'+recipient+'" />'+
				'</p>';
			
			var recipientsEl = document.getElementById('<portlet:namespace/>'+'recipients');
			if(recipientsEl.getElementsByClassName("dummy").length>0)
				recipientsEl.innerHTML = "";
			
			document.getElementById('<portlet:namespace/>'+'recipients').innerHTML += html;
		}
	}
	
	function <portlet:namespace/>removeRecipient(element) {
		element.parentNode.removeChild(element);
	}
	
	
	// view (callback):
		
	function <portlet:namespace/>showMessageState(data, callbackJSON) {
		var successElement = document.getElementById('<portlet:namespace/>'+'successMsg');
		
		if(data!= null && !data.error) {
			console.log("Success. Message-Id: "+JSON.stringify(data));
			
			successElement.className = 'portlet-msg-success';
			successElement.innerHTML = '<liferay-ui:message key="de.iisys.shindigmsg.success" />';
			
			var newMsgId = "";
			if(data && data.entry & data.entry.id)
				newMsgId = data.entry.id;
			
			for(var i=0; i<callbackJSON.recipients.length; i++) {
				<portlet:namespace/>startNotificationOnServer(newMsgId, callbackJSON.recipients[i], callbackJSON.senderId, callbackJSON.body, callbackJSON.type);
			}
			
			// create activity:
			if(<portlet:namespace/>CREATE_ACTIVITY===true && callbackJSON.type==="publicMessage")
				<portlet:namespace/>createMessageActivity(callbackJSON, newMsgId);
			
			document.getElementById('<portlet:namespace/>'+'recipients').innerHTML = '<p class="dummy"> - </p>';
			document.getElementById('<portlet:namespace/>'+'msgContent').value = "";
			document.getElementById('<portlet:namespace/>'+'title').value = "";
		} else {
			var errormsg = "";
			if(data.error.value) {
				errormsg = data.error.value;
		    } else if(data.error.message) {
		    	errormsg = data.error.message;
		    } else {
		    	errormsg = data.error;
		    }
			successElement.className = 'portlet-msg-error';
			successElement.innerHTML = '<liferay-ui:message key="de.iisys.shindigmsg.failed" />';
			if(errormsg != "") successElement.innerHTML += ' ('+errormsg+')';
		}
		successElement.style.display = "block";
	}
	
	function <portlet:namespace/>showActivityState(data) {
		console.log(JSON.stringify(data));
	}
		

	// Recipients - user autocomplete:
	AUI().use('autocomplete-list','datasource-io',function(A) {
		var datasource = new A.DataSource.IO({
			source: '<%=autocompleteURL%>'
		});	
		
		var autoComplete = new A.AutoCompleteList({
			allowBrowserAutocomplete: false,
			activateFirstItem: true,
			inputNode: '#<portlet:namespace />userName',
			maxResults: 10,
			on: {
				select: function(event) {
					var result = event.result.raw;
					A.one('#<portlet:namespace/>userIdToBeSaved').val(result.userId);
					<portlet:namespace/>addRecipient(result.fullName,result.userId);
				}
			},
			render: true,
			source: datasource,
			requestTemplate: '&<portlet:namespace />keywords={query}',
			resultListLocator: function (response) {
				var responseData = A.JSON.parse(response[0].responseText);
				return responseData.response;
			},
			resultTextLocator: function (result) {
				return result.fullName;
			},
			resultHighlighter: 'phraseMatch'
		});
	});
	
	// @Mentions - user autocomplete:
	AUI().use('autocomplete-list','datasource-io',function(A) {
		var <portlet:namespace />datasource = new A.DataSource.IO({
			source: '<%=autocompleteURL%>'
		});	
		
		var <portlet:namespace />autoComplete = new A.AutoCompleteList({
//			queryDelimiter: '@',
//			allowTrailingDelimiter: true,
			allowBrowserAutocomplete: false,
			activateFirstItem: true,
			inputNode: '#<portlet:namespace />msgContent',
			maxResults: 5,
			on: {
				select: function(event) {
					var result = event.result.raw;
//					document.getElementById('<portlet:namespace/>'+'user-mentions').innerHTML += '<input class="mention-'+result.userId+'" type="hidden" value="'+result.userId+'" />';
				
					event.preventDefault();
					var fullName = result.fullName;
					var inputNode = event.currentTarget._inputNode;
					var inputNodeValue = inputNode.val();
					var inputValueUpdated = inputNodeValue.replace(<portlet:namespace/>REGEX_USER_NAME, '['+result.userId+']');
					inputNode.val(inputValueUpdated);
					inputNode.focus();
					
					<portlet:namespace/>MAP_MENTIONS[fullName] = result.userId;
				},
				query: function(event) {
					var inputValue = event.inputValue;
					var query = inputValue.match(<portlet:namespace/>REGEX_USER_NAME);
					
					if(query)
						event.query = query[0].substr(1);
					else
						event.preventDefault();
					
				},
				clear: function() {
//					document.getElementById('<portlet:namespace/>'+'user-mentions').innerHTML = "";
				}
			},
			render: true,
			source: <portlet:namespace />datasource,
			requestTemplate: '&<portlet:namespace />keywords={query}',
			resultListLocator: function (response) {
				var responseData = A.JSON.parse(response[0].responseText);
				return responseData.response;
			},
			resultTextLocator: function (result) {
				return result.fullName;
			},
			resultHighlighter: 'phraseMatch'
		});
	});
	
	// start:
	<portlet:namespace/>init();
</aui:script>