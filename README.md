# liferay-shindig-socialmessenger
Liferay portlet: Social Shindig-Messenger with #Hashtag and @Mentioning features

*Requires the Shindig server's secret token.*

**Portlets included**

* Social Messenger
* Social Messenger (Hashtag View)

**Installation**

Configuration: /src/main/resources/portlet.properties

Build .war:

1. (optional) Import in Liferay 7 IDE
2. Edit configuration file.
3. Build using Maven with package goal

Deploy:

4. Put generated war in Liferay's "deploy" folder
5. Restart Liferay

**Documentation**

Social Messenger:
* When put on foreign profile, it only shows the Public Wall. Otherwise it is a full messenger (with inbox, outbox, public wall).
* Can send public and private messages.
* Supports hashtags and mentioning.