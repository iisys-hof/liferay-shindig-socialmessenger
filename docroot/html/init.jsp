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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ taglib uri="http://alloy.liferay.com/tld/aui" prefix="aui" %>
<%@ taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet" %>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui"%>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme"%>

<%@ page import="javax.portlet.PortletPreferences" %>
<%@ page import="javax.portlet.PortletURL" %>
<%@ page import="com.liferay.util.portlet.PortletProps" %>
<%@ page import="com.liferay.portal.util.PortalUtil" %>
<%@ page import="com.liferay.portal.kernel.util.ParamUtil" %>
<%@ page import="com.liferay.portal.kernel.util.GetterUtil" %>
<%@ page import="com.liferay.portal.kernel.util.Constants"%>
<%@ page import="com.liferay.portal.kernel.util.StringPool" %>

<%@ page import="java.util.Map,java.util.HashMap,org.apache.shindig.common.crypto.BasicBlobCrypter,java.io.File" %>

<portlet:defineObjects />
<liferay-theme:defineObjects />

<%
	String userName = user.getScreenName();
	String userFullName = user.getFullName();
	
	//see AbstractSecurityToken for keys
	Map<String, String> token = new HashMap<String, String>();
	//application
	token.put("i", "ShindigMessaging-portlet");
	//viewer
	token.put("v", userName);
	
	String shindigToken = "default:" + new BasicBlobCrypter(new File(PortletProps.get("token_secret"))).wrap(token);
%>


<script type="text/javascript">
	
	var <portlet:namespace/>SHINDIG_TOKEN = '<%= shindigToken %>';
	
	var <portlet:namespace/>USER_ID = '<%= userName %>';
	var <portlet:namespace/>USER_NAME = '<%= userFullName %>';
	
	var <portlet:namespace/>LIFERAY_URL = '<%= PortletProps.get("liferay_url") %>'; 
	var <portlet:namespace/>LIFERAY_PROFILE_URL = '<%= PortletProps.get("liferay_profile_url") %>';
		
	var <portlet:namespace/>SHINDIG_URL = '<%= PortletProps.get("shindig_url") %>';
	var <portlet:namespace/>MESSAGES_FRAG = "/social/rest/messages/";
	var <portlet:namespace/>PEOPLE_FRAG = "/social/rest/people/";

	//request methods:
	
	function <portlet:namespace/>sendAsyncRequest(method, url, callback, payload, callbackValue) {
		
		AUI().use('aui-io-request', function(A)
		{
			<portlet:namespace/>animationOnOff(true, A);
			
			if(payload && payload!=="") {
			  A.io.request(url, {
				  dataType: 'json',
				  method : method,
				  headers: {
					  'Content-Type': 'application/json; charset=utf-8'
				  },
				  data : JSON.stringify(payload),
				  on: {
					success: function() {
						<portlet:namespace/>animationOnOff(false, A);
						if(callbackValue)
							callback(this.get('responseData'),callbackValue);
						else
					  		callback(this.get('responseData'));
					},
					failure: function() {
						<portlet:namespace/>showError(this.get('responseData'));
						<portlet:namespace/>animationOnOff(false, A);
					}
				  }
			  });
			} else {
				A.io.request(url, {
				  dataType: 'json',
				  method : method,
				  on: {
					success: function() {
						<portlet:namespace/>animationOnOff(false, A);
						if(callbackValue)
							callback(this.get('responseData'),callbackValue);
						else
					  		callback(this.get('responseData'));
					},
					failure: function() {
						<portlet:namespace/>showError(this.get('responseData'));
						<portlet:namespace/>animationOnOff(false, A);
					}
				  }
				});
			}
		});
	}
	
	
	
	// helper:
		
	function <portlet:namespace/>animationOnOff(on, A) {
		if(on)
			A.one('#<portlet:namespace/>loader').setHTML(A.Node.create('<div class="loading-animation" />'));
		else
			A.one('#<portlet:namespace/>loader').setHTML(A.Node.create('<div />'));
	}
	
	function <portlet:namespace/>showError(data) {
		console.log("Request-Error!");
		var successElement = document.getElementById('<portlet:namespace/>'+'successMsg');
		successElement.className = 'portlet-msg-error';
		successElement.innerHTML = 'Request-Error';
		if(data && data.type)
			successElement.innerHTML += ' ('+data.type+')';
		if(data && data.message)
			successElement.innerHTML += ': '+data.message;
		
		successElement.style.display = "block";
	}

	function <portlet:namespace/>findHashtags(searchText) {
	    var regexp = /\B\#\w\w+\b/g
	    result = searchText.match(regexp);
	    if (result) {
	        return result;
	    } else {
	        return false;
	    }
	}
	
	function <portlet:namespace/>findMentions(searchText) {
		var regexp = /\[[^\]]+\]/g;
	    var result = searchText.match(regexp);
	    
	    if (result) {
	        return result;
	    } else {
	        return [];
	    }
	}

</script>