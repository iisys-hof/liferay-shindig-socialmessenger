package de.iisys.liferay.portlet.shindigMessaging.messenger;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;
import java.util.List;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import com.liferay.portal.kernel.dao.orm.Criterion;
import com.liferay.portal.kernel.dao.orm.DynamicQuery;
import com.liferay.portal.kernel.dao.orm.DynamicQueryFactoryUtil;
import com.liferay.portal.kernel.dao.orm.PropertyFactoryUtil;
import com.liferay.portal.kernel.dao.orm.RestrictionsFactoryUtil;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.servlet.SessionMessages;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.PortalClassLoaderUtil;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.model.ClassName;
import com.liferay.portal.model.User;
import com.liferay.portal.service.ClassNameLocalServiceUtil;
import com.liferay.portal.service.ServiceContext;
import com.liferay.portal.service.ServiceContextFactory;
import com.liferay.portal.service.UserLocalServiceUtil;
import com.liferay.portal.service.UserNotificationDeliveryLocalServiceUtil;
import com.liferay.portal.service.UserNotificationEventLocalServiceUtil;
import com.liferay.portal.theme.ThemeDisplay;
import com.liferay.util.bridges.mvc.MVCPortlet;

import de.iisys.liferay.portlet.shindigMessaging.activity.SocialActivityContainer;

public class ShindigMsgActions extends MVCPortlet {
	
	private ThemeDisplay themeDisplay;
	
	public void render(RenderRequest request, RenderResponse response)
			throws PortletException, IOException {
		themeDisplay = (ThemeDisplay)request.getAttribute(WebKeys.THEME_DISPLAY);
		/*
		System.out.println("PortletDisplay, Id: "+themeDisplay.getPortletDisplay().getId());
		System.out.println("Plid: "+themeDisplay.getPlid());
		System.out.println("PortletName: "+themeDisplay.getPortletDisplay().getPortletName());
		System.out.println("InstanceId:" +themeDisplay.getPortletDisplay().getInstanceId()); */
		
		super.render(request, response);
	}
	
	public void processAction(ActionRequest actionRequest, ActionResponse actionResponse) 
			throws IOException, PortletException {
//		String firstRecipient = ParamUtil.getString(actionRequest, "firstRecipient", "");
		
		super.processAction(actionRequest, actionResponse);
	}
	
	public void addMessage(ActionRequest actionRequest, ActionResponse response) throws PortalException, SystemException, IOException {
		SessionMessages.add(actionRequest, "message_sent");
		sendRedirect(actionRequest, response);
	}
	
	public void showSingleMessage(ActionRequest actionRequest, ActionResponse actionResponse) 
			throws IOException, PortletException {
		System.out.println("Nüxxx");
	}
	
	
	private String getUserNameById(String userScreenName) {
		User user;
		try {
			user = UserLocalServiceUtil.getUserByScreenName(themeDisplay.getCompanyId(), userScreenName);
		} catch (PortalException | SystemException e) {
			e.printStackTrace();
			return userScreenName;
		}
		System.out.println(user.getFullName());
		return user.getFullName();
	}
	
	
	/* AJAX Calls: */
	
	@Override
	public void serveResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
			throws IOException, PortletException {
		String resourceID = resourceRequest.getResourceID();
		if(resourceID.equals("autocomplete")) {
			getUsersForAutocomplete(resourceRequest, resourceResponse);
		} else if(resourceID.equals("sendMessage")) {
			try {
				sendUserNotification(resourceRequest, resourceResponse);
			} catch (PortalException | SystemException e) {
				e.printStackTrace();
			}
			boolean isPublic = ParamUtil.getBoolean(resourceRequest, "type");
			if(isPublic) createActivityForShindig(resourceRequest, resourceResponse);
		} else {
			super.serveResource(resourceRequest, resourceResponse);
		}
	}
	
	private void createActivityForShindig(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
			throws IOException,	PortletException {
		String recipient = ParamUtil.getString(resourceRequest, "recipient");
		String senderId = ParamUtil.getString(resourceRequest, "senderId");
		String msgText = ParamUtil.getString(resourceRequest, "msgText");
		String msgId = ParamUtil.getString(resourceRequest, "msgId");
		
		
	}
	
	private void sendUserNotification(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
			throws IOException,	PortletException, PortalException, SystemException {
		String recipient = ParamUtil.getString(resourceRequest, "recipient");
		String senderId = ParamUtil.getString(resourceRequest, "senderId");
		String msgText = ParamUtil.getString(resourceRequest, "msgText");
		String msgId = ParamUtil.getString(resourceRequest, "msgId");
		
		long recipientId = UserLocalServiceUtil.getUserIdByScreenName(themeDisplay.getCompanyId(), recipient);
		User sender = UserLocalServiceUtil.getUserByScreenName(themeDisplay.getCompanyId(), senderId);
		
		ServiceContext sc = ServiceContextFactory.getInstance(resourceRequest);
		
//		System.out.println("Name: "+senderName+", Text:"+msgText);
		
		JSONObject payloadJSON = JSONFactoryUtil.createJSONObject();
		payloadJSON.put("msgId", msgId);
		payloadJSON.put("userId", sender.getUserId());
		payloadJSON.put("senderName", sender.getFullName());
		payloadJSON.put("msgText", msgText);
		payloadJSON.put("msgPlid", sc.getPlid());
		

		UserNotificationEventLocalServiceUtil.addUserNotificationEvent(recipientId,
				ShindigMsgNotificationHandler.PORTLET_ID, (new Date()).getTime(), themeDisplay.getUserId(), 
				payloadJSON.toString(), false, sc);

	}
	
	private void getUsersForAutocomplete(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
			throws IOException,	PortletException {
		String keywords = ParamUtil.getString(resourceRequest, "keywords");
		 
		JSONObject json = JSONFactoryUtil.createJSONObject();
		JSONArray results = JSONFactoryUtil.createJSONArray();
		json.put("response", results);
 
		try {
			DynamicQuery query = DynamicQueryFactoryUtil
					.forClass(User.class);
//			query.add(PropertyFactoryUtil.forName("firstName").like(
//					StringPool.PERCENT + keywords + StringPool.PERCENT));
			Criterion criterion = RestrictionsFactoryUtil.ilike("firstName",
					StringPool.PERCENT + keywords + StringPool.PERCENT);
			Criterion criterion2 = RestrictionsFactoryUtil.ilike("lastName",
					StringPool.PERCENT + keywords + StringPool.PERCENT);
			
			query.add(RestrictionsFactoryUtil.or(criterion, criterion2));
			
			List<User> userNames = UserLocalServiceUtil.dynamicQuery(query);
 
			for (User user : userNames) {
				JSONObject object = JSONFactoryUtil.createJSONObject();
				object.put("userId", user.getScreenName());
				object.put("fullName", user.getFullName());
				results.put(object);
			}
		} catch (SystemException e) {
			e.printStackTrace();
		}
 
		writeJSON(resourceRequest, resourceResponse, json);
	}
}
