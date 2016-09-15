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
<%@include file="/html/shared.jsp" %>


<%
	String redirect = PortalUtil.getCurrentURL(renderRequest);
	
	HttpServletRequest httpRequest = PortalUtil.getOriginalServletRequest(
			PortalUtil.getHttpServletRequest(renderRequest)); 
	String userProfile = httpRequest.getParameter("userId");
	String highlightedMsg = httpRequest.getParameter(renderResponse.getNamespace()+"highlightedMsg");
	
	String hashtag = ParamUtil.getString(request, "hashtag", "").toLowerCase();
	if(hashtag.startsWith("#"))
		hashtag = hashtag.substring(1);
	
	String tabNames = "Inbox, Public Wall, Outbox";
	String tabsValues = "inbox,wall,outbox"; // currently not used
	if(!hashtag.equals("")) {
		tabNames += ", #"+hashtag;
		tabsValues += ",hashtag";
	}
	if(userProfile==null)
		userProfile = "";
	else
		tabNames = "Public Wall";
	
	if(highlightedMsg==null) highlightedMsg = "";
	
	
	PortletURL portletURL = renderResponse.createRenderURL();
	portletURL.setParameter("mvcPath", "/html/messenger/view.jsp");
%>


<liferay-ui:success key="message_sent" message="de.iisys.shindigmsg.success" />

<aui:button-row cssClass="controls">
	<portlet:renderURL var="newMessageURL">
		<portlet:param name="mvcPath" value="/html/messenger/new_message.jsp" />
		<portlet:param name="redirect" value="<%= redirect %>"/>
		<c:if test="<%= !userProfile.isEmpty() %>">
			<portlet:param name="firstRecipient" value="<%= userProfile %>"/>
		</c:if>
	</portlet:renderURL>
	
	<form class="form shindigmsg-entry-form" method="post" action="<%= portletURL.toString() %>">
		<div class="form-group">
			<div class="input-group">
				<span class="input-group-btn">
					<aui:button type="submit" value="de.iisys.shindigmsg.search" class="btn btn-default" primary="<%= false %>" icon="icon-search" />
				</span>
				<input name="<portlet:namespace/>hashtag" class="field autocomplete form-control" type="text" label="" placeholder="#hashtag" style="margin-left:0;" />
			</div>
		</div>
	</form>
	
	<% String newMessageUrlString = "location.href='" + newMessageURL.toString() + "'"; %>
	<aui:button onClick="<%= newMessageUrlString.toString() %>" value="de.iisys.shindigmsg.newMessage" cssClass="pull-right" primary="<%= true %>" icon="icon-comment" />
</aui:button-row>

<div class="portlet-msg-success" style="display:none;" id="<portlet:namespace/>successMsg"></div>
<div id="<portlet:namespace/>loader"></div>


<liferay-ui:tabs names="<%= tabNames %>" refresh="false">

<div id="<portlet:namespace/>message_boxes">

<c:if test="<%= userProfile.isEmpty() %>">
	<liferay-ui:section>
		<div class="messages">
			<div id="<portlet:namespace/>inbox">
				<em><liferay-ui:message key="de.iisys.shindigmsg.noMsgToDisplay" />.</em>
			</div>
		</div>
		<div class="pagination pagination-mini pull-right">
			<ul id="<portlet:namespace/>inbox-pages" class="pagination"></ul>
		</div>
		<div style="clear:both;"></div>
	</liferay-ui:section>
</c:if>
	
	<liferay-ui:section>
		<div class="messages">
			<div id="<portlet:namespace/>@wall">
				<em><liferay-ui:message key="de.iisys.shindigmsg.noMsgToDisplay" />.</em>
			</div>
		</div>
		<div class="pagination pagination-mini pull-right">
			<ul id="<portlet:namespace/>@wall-pages" class="pagination"></ul>
		</div>
		<div style="clear:both;"></div>
	</liferay-ui:section>

<c:if test="<%= userProfile.isEmpty() %>">
	<liferay-ui:section>
		<div class="messages">
			<div id="<portlet:namespace/>@outbox">
				<em><liferay-ui:message key="de.iisys.shindigmsg.noMsgToDisplay" />.</em>
			</div>
		</div>
		<div class="pagination pagination-mini pull-right">
			<ul id="<portlet:namespace/>@outbox-pages" class="pagination"></ul>
		</div>
		<div style="clear:both;"></div>
	</liferay-ui:section>
</c:if>
	
	<liferay-ui:section>
		<div class="messages">
			<div id="<portlet:namespace/>hashtags">
				<em><liferay-ui:message key="de.iisys.shindigmsg.noMsgToDisplay" />.</em>
			</div>
		</div>
		<div class="pagination pagination-mini pull-right">
			<ul id="<portlet:namespace/>hashtags-pages" class="pagination-content"></ul>
		</div>
		<div style="clear:both;"></div>
	</liferay-ui:section>

</div><!-- message_boxes END -->
</liferay-ui:tabs>


<script type="text/javascript">
		
	// vars:
	
	var <portlet:namespace/>USER_PROFILE_ID = '<%= userProfile %>';
	var <portlet:namespace/>LIFERAY_HASHTAGWIKI = '<%= GetterUtil.getString( portletPreferences.getValue("wikiURL", PortletProps.get("liferay_hashtag-wiki")) ) %>';
	
	var <portlet:namespace/>MESSAGES_PER_PAGE = 5;
	
	
	var <portlet:namespace/>hashtag = '<%= hashtag %>';
	var <portlet:namespace/>highlightedMsg = '<%= highlightedMsg %>';
	
	// temp vars:
//	var <portlet:namespace/>totalInbox = 0;
	var <portlet:namespace/>curInbox = 0;
	
//	var <portlet:namespace/>totalOutbox = 0;
	var <portlet:namespace/>curOutbox = 0;
	
//	var <portlet:namespace/>totalWall = 0;
	var <portlet:namespace/>curWall = 0;
	
//	var <portlet:namespace/>totalHashtags = 0;
	var <portlet:namespace/>curHashtags = 0;
	
	var <portlet:namespace/>tempLastDeleted;
	
	 
	  
	// control:
		
	function <portlet:namespace/>init() {
		if(<portlet:namespace/>USER_PROFILE_ID == '' || <portlet:namespace/>USER_PROFILE_ID == null) {
			<portlet:namespace/>getInboxMessages(<portlet:namespace/>USER_ID);
			<portlet:namespace/>getOutboxMessages(<portlet:namespace/>USER_ID);
			<portlet:namespace/>getPublicMessages(<portlet:namespace/>USER_ID);
		} else {
			<portlet:namespace/>getPublicMessages(<portlet:namespace/>USER_PROFILE_ID);
		}
		<portlet:namespace/>getHashtagMessages(<portlet:namespace/>USER_ID);
	}
	
	// control GET:

	function <portlet:namespace/>getInboxMessages(userId) {
//		var userId = '@self';
		var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>MESSAGES_FRAG + userId + "/inbox" +
			"?startIndex="+<portlet:namespace/>curInbox +
			"&count="+<portlet:namespace/>MESSAGES_PER_PAGE +
			"&sortBy=timeSent&sortOrder=descending"+
			"&filterBy=type&filterOp=contains&filterValue=private";
			if(<portlet:namespace/>SHINDIG_TOKEN != null) url += "&st="+<portlet:namespace/>SHINDIG_TOKEN;
		<portlet:namespace/>sendAsyncRequest('GET', url, <portlet:namespace/>showInboxMessages);
	}
	
	function <portlet:namespace/>getOutboxMessages(userId) {
//		var userId = '@me';
		var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>MESSAGES_FRAG + userId + "/@outbox" +
			"?startIndex="+<portlet:namespace/>curOutbox +
			"&count="+<portlet:namespace/>MESSAGES_PER_PAGE +
			"&sortBy=timeSent&sortOrder=descending";
			if(<portlet:namespace/>SHINDIG_TOKEN != null) url += "&st="+<portlet:namespace/>SHINDIG_TOKEN;
		<portlet:namespace/>sendAsyncRequest('GET', url, <portlet:namespace/>showOutboxMessages);
	}
	
	function <portlet:namespace/>getPublicMessages(userId) {
		var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>MESSAGES_FRAG + userId + "/inbox" +
			"?startIndex="+<portlet:namespace/>curWall+
			"&count="+<portlet:namespace/>MESSAGES_PER_PAGE +
			"&sortBy=timeSent&sortOrder=descending"+
			"&filterBy=type&filterOp=contains&filterValue=public";
			if(<portlet:namespace/>SHINDIG_TOKEN != null) url += "&st="+<portlet:namespace/>SHINDIG_TOKEN;
		<portlet:namespace/>sendAsyncRequest('GET', url, <portlet:namespace/>showWallMessages);
	}
	
	// control SET:
	
	function <portlet:namespace/>deleteMessage(userId, collectionId, messageId) {
		<portlet:namespace/>tempLastDeleted = messageId;
		var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>MESSAGES_FRAG +userId+"/"+collectionId+"/"+messageId.replace(":", "%3A"); 
		<portlet:namespace/>sendAsyncRequest('DELETE', url, <portlet:namespace/>showDeletedMessageState);
	}
	
	function <portlet:namespace/>createPublicPost() {
		
	}
	  
	  
	// view (callback):
	  
	function <portlet:namespace/>showInboxMessages(data) {
		<portlet:namespace/>updatePaginationView('inbox',data.totalResults,<portlet:namespace/>curInbox);
		<portlet:namespace/>showMessages(data, 'inbox');
	}
	function <portlet:namespace/>showOutboxMessages(data) {
		<portlet:namespace/>updatePaginationView('@outbox',data.totalResults,<portlet:namespace/>curOutbox);
		<portlet:namespace/>showMessages(data, '@outbox');
	}
	function <portlet:namespace/>showWallMessages(data) {
		<portlet:namespace/>updatePaginationView('@wall',data.totalResults,<portlet:namespace/>curWall);
		<portlet:namespace/>showMessages(data, '@wall');
	}
	
	
	
	
	function <portlet:namespace/>showDeletedMessageState(data) {
		if(!data.error) {
			console.log("Message succesfully deleted.");
			var el = document.getElementById('<portlet:namespace/>'+'message-'+<portlet:namespace/>tempLastDeleted);
			el.parentNode.removeChild(el);
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
	
	// view:
	
	function <portlet:namespace/>showHashtagDetails(targetBox) {
		var url = <portlet:namespace/>LIFERAY_URL + <portlet:namespace/>LIFERAY_HASHTAGWIKI;
		if(url.indexOf("/", this.length-1)== -1) url += "/";
		
		var tabBox = document.getElementById('<portlet:namespace/>'+targetBox).parentNode.parentNode;
		tabBox.innerHTML = '<p>'+'<liferay-ui:message key="de.iisys.shindigmsg.moreInformationHashtagWiki" />'+': <a href="'+url+<portlet:namespace/>hashtag+'">#'+<portlet:namespace/>hashtag+'</a>.</p>'
			+ tabBox.innerHTML;
	}

	  
	// start:
	<portlet:namespace/>init();
	  
</script>
