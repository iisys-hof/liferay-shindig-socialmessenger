# liferay-shindig-socialmessenger
Liferay portlet: Social Shindig-Messenger with #Hashtag and @Mentioning features

*Requires the Shindig server's secret token.*

**Portlets included**

* Social Messenger
* Social Messenger (Hashtag View)

**Installation**

Configuration:
/docroot/WEB-INF/src/portlet.properties

Build .war:
1. Project has to be placed in a folder called "ShindigMessaging-portlet" in the *portlets* folder of a Liferay Plugins SDK.
2. Import in Liferay IDE using "Liferay project from existing source"
3. Edit configuration file.
4. Right click on project and execute Liferay - SDK - war

Deploy:
4. Put generated war in Liferay's "deploy" folder
5. Restart Liferay

**Documentation**

Social Messenger:
* When put on foreign profile, it only shows the Public Wall. Otherwise it is a full messenger (with inbox, outbox, public wall).
* Can send public and private messages.
* Supports hashtags and mentioning.