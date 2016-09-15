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

<%@ include file="/html/init.jsp" %>

<liferay-portlet:actionURL portletConfiguration="true" var="configurationURL" />

<%
	boolean createActivity_cfg = GetterUtil.getBoolean(portletPreferences.getValue("createActivity", StringPool.TRUE));
	String wikiURL_cfg = GetterUtil.getString(portletPreferences.getValue("wikiURL", "/web/guest/hashtag/-/wiki/Main/"));
%>

<aui:form action="<%= configurationURL %>" method="post" name="fm">
    <aui:input name="<%= Constants.CMD %>" type="hidden" value="<%= Constants.UPDATE %>" />

	<p><strong><liferay-ui:message key="de.iisys.shindigmsg.general" />:</strong></p>
	<aui:input name="preferences--createActivity" type="checkbox" value="<%= createActivity_cfg %>" label="de.iisys.shindigmsg.lblCreateActivity" />

	<aui:spacer />
	<p><strong>Liferay URLs:</strong></p>
	<aui:input name="preferences--wikiURL--" type="text" value="<%= wikiURL_cfg %>" label="de.iisys.shindigmsg.lblWikiURL" />


    <aui:button-row>
       <aui:button type="submit" />
    </aui:button-row>
</aui:form>