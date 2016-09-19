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


<%@ page import="com.liferay.portal.theme.ThemeDisplay" %>


<%
//	String shindigToken = null;

	String NO_HASHTAG = "111nohashtag!";
	
	String hashtag2 = ParamUtil.getString(request, "hashtag", "");
	if(hashtag2.startsWith("#"))
		hashtag2 = hashtag2.substring(1);

	String curURL = themeDisplay.getURLCurrent();
	String hashtag = "";
	String tabNames;
	if(curURL.indexOf("_title=") != -1) {
		hashtag = curURL.substring( curURL.indexOf("_title")+7 ).toLowerCase();
	} else if(curURL.toLowerCase().indexOf("_title%3d") != -1) {
		hashtag = curURL.substring( curURL.toLowerCase().indexOf("_title")+9 ).toLowerCase();
	}
	
	if(hashtag.equals("")) {
		hashtag = curURL.substring( curURL.lastIndexOf("/")+1 ).toLowerCase();		
	}
	
	if(hashtag.indexOf("?") != -1)
		hashtag = hashtag.substring(0, hashtag.indexOf("?"));
	else if(hashtag.indexOf("&") != -1)
		hashtag = hashtag.substring(0, hashtag.indexOf("&"));
	else if(hashtag.toLowerCase().indexOf("%2f") != -1)
		hashtag = hashtag.substring(0, hashtag.toLowerCase().indexOf("%2f"));

	String redirect = PortalUtil.getCurrentURL(renderRequest);
	
//	String hashtag = ParamUtil.getString(request, "hashtag", "");
	if(hashtag.startsWith("#"))
		hashtag = hashtag.substring(1);
	if(hashtag.endsWith("/"))
		hashtag = hashtag.substring(0, -1);
	
	if(hashtag.indexOf("&")!=-1 || hashtag.indexOf("?")!=-1 || hashtag.equals("")) {
		hashtag = NO_HASHTAG;
		tabNames = "No #hashtag chosen";
	} else {
		tabNames = "#"+hashtag;
	}
	
	if(!hashtag2.isEmpty()) {
		tabNames += ", #"+hashtag2;
	}
	
	
	PortletURL portletURL = renderResponse.createRenderURL();
	portletURL.setParameter("mvcPath", "/view.jsp");
//	portletURL.setParameter("hashtag", "test");
%>

<div class="portlet-msg-success" style="display:none;" id="<portlet:namespace/>successMsg"></div>
<div id="<portlet:namespace/>loader"></div>


<liferay-ui:tabs names="<%= tabNames %>" refresh="false">
	
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
	
	<liferay-ui:section>
		<div class="messages">
			<div id="<portlet:namespace/>hashtags2">
				<em><liferay-ui:message key="de.iisys.shindigmsg.noMsgToDisplay" />.</em>
			</div>
		</div>
		<div class="pagination pagination-mini pull-right">
			<ul id="<portlet:namespace/>hashtags2-pages" class="pagination-content"></ul>
		</div>
		<div style="clear:both;"></div>
	</liferay-ui:section>
	
</liferay-ui:tabs>


<script type="text/javascript">
		
	// vars:
	var <portlet:namespace/>LIFERAY_HASHTAGWIKI = '<%= PortletProps.get("liferay_hashtag-wiki") %>';

	var <portlet:namespace/>MESSAGES_PER_PAGE = 10;
	
	var <portlet:namespace/>hashtag = '<%= hashtag %>';
	var <portlet:namespace/>highlightedMsg = false;
	
	// temp vars:
	var <portlet:namespace/>curHashtags = 0;
	var <portlet:namespace/>tempCrawledUsers = [];

	  
	   
	// control:
	function <portlet:namespace/>init() {
		<portlet:namespace/>getHashtagMessages(<portlet:namespace/>USER_ID);
	}
	
	// control (GET):  
	function <portlet:namespace/>getUserDetails(userId, box) {
		var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG + userId;

		if(box==="hashtags")
			<portlet:namespace/>sendAsyncRequest('GET', url, <portlet:namespace/>showHashtagUserDetails);
	}
	
	
	// view:
	
	function <portlet:namespace/>showHashtagDetails(targetBox) {
		/*
		var tabBox = document.getElementById('<portlet:namespace/>'+targetBox).parentNode.parentNode;
		tabBox.innerHTML = '<p>'+'<liferay-ui:message key="de.iisys.shindigmsg.moreInformationHashtagWiki" />'+': <a href="">#'+<portlet:namespace/>hashtag+'</a>.</p>'
			+ tabBox.innerHTML;
		*/
	}
	
	  
	// start:
	<portlet:namespace/>init();
	  
</script>

