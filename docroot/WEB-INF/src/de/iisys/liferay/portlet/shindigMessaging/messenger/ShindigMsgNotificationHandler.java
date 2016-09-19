package de.iisys.liferay.portlet.shindigMessaging.messenger;

import java.util.ResourceBundle;

import javax.portlet.PortletConfig;
import javax.portlet.WindowState;

import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;

import com.liferay.portal.kernel.notifications.BaseUserNotificationHandler;
import com.liferay.portal.kernel.portlet.LiferayPortletResponse;
import com.liferay.portal.kernel.portlet.LiferayPortletURL;
import com.liferay.portal.kernel.util.JavaConstants;
import com.liferay.portal.kernel.util.StringBundler;
import com.liferay.portal.kernel.util.StringUtil;
import com.liferay.portal.model.UserNotificationEvent;
import com.liferay.portal.service.ServiceContext;

public class ShindigMsgNotificationHandler extends BaseUserNotificationHandler {
	public static final String PORTLET_ID = "ShindigMessaging_WAR_ShindigMessagingportlet";
	
	public ShindigMsgNotificationHandler() {
		 
		setPortletId(ShindigMsgNotificationHandler.PORTLET_ID);
	}
 
	@Override
	protected String getBody(UserNotificationEvent userNotificationEvent,
			ServiceContext serviceContext) throws Exception {
 
		JSONObject jsonObject = JSONFactoryUtil
				.createJSONObject(userNotificationEvent.getPayload());
 
		String senderName = jsonObject.getString("senderName");
		String msgText = jsonObject.getString("msgText");
 
//		ResourceBundle rb = ResourceBundle.getBundle("content.Language", serviceContext.getLocale());
//		System.out.println("serviceContext: "+serviceContext.getLocale().toLanguageTag());
//		System.out.println("ResourceBundle: "+rb.getLocale());
		
		String titleText = "";
		switch(serviceContext.getLocale().toLanguageTag()) {
		case("de-DE"):
		case("de"): titleText = "Nachricht von"; break;
		default: titleText = "Message from";
		}
		
		String title = "<strong>" + titleText + " " + senderName + "</strong>:";
 
		String bodyText = msgText;
		if(msgText.length()>40)
			bodyText = msgText.substring(0,40)+"...";

 
		String body = StringUtil.replace(getBodyTemplate(), new String[] {
				"[$TITLE$]", "[$BODY_TEXT$]" }, new String[] {
				title, bodyText });
		
		return body;
	}
	

	@Override
	protected String getLink(UserNotificationEvent userNotificationEvent,
			ServiceContext serviceContext) throws Exception {
 
		JSONObject jsonObject = JSONFactoryUtil.createJSONObject(userNotificationEvent.getPayload());
		String msgId = jsonObject.getString("msgId");
		long msgPlid = jsonObject.getLong("msgPlid");
		
		LiferayPortletResponse liferayPortletResponse = serviceContext
				.getLiferayPortletResponse();
		
 
//		PortletURL viewURL = liferayPortletResponse.createActionURL(PORTLET_ID);
		LiferayPortletURL viewURL = liferayPortletResponse.createRenderURL(PORTLET_ID);
		viewURL.setPortletId(PORTLET_ID);
		viewURL.setPlid(msgPlid);
		
//		viewURL.setParameter(ActionRequest.ACTION_NAME, "showSingleMessage");
		viewURL.setParameter("redirect", serviceContext.getLayoutFullURL());
		viewURL.setParameter("highlightedMsg", String.valueOf(msgId));
		viewURL.setParameter("userNotificationEventId", String.valueOf(userNotificationEvent.getUserNotificationEventId()));
		viewURL.setWindowState(WindowState.NORMAL);

		
		return viewURL.toString();
	}


 
	protected String getBodyTemplate() throws Exception {
		StringBundler sb = new StringBundler(5);
		sb.append("<div class=\"title\">[$TITLE$]</div><div ");
		sb.append("class=\"body\">[$BODY_TEXT$]</div>");
		return sb.toString();
	}
}
