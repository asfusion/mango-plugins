<cfcomponent>

	<cfset variables.name = "Flickr Widget" />
	<cfset variables.id = "com.asfusion.mango.plugins.flickrWidget" />
	<cfset variables.package = "com/asfusion/mango/plugins/flickrWidget"/>
	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
			
			<cfset var blogid = arguments.mainManager.getBlog().getId() />
			<cfset var path = blogid & "/" & variables.package />
			<cfset variables.manager = arguments.mainManager />
			<cfset variables.preferencesManager = arguments.preferences />
			<cfset variables.title = variables.preferencesManager.get(path,"podTitle","Photos") />
			<cfset variables.tags = variables.preferencesManager.get(path,"tags","") />
			<cfset variables.username = variables.preferencesManager.get(path,"username","") />
		<cfreturn this/>
	</cffunction>

	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<cfreturn "Flickr Widget activated. <br />
		You can now <a href='generic_settings.cfm?event=showFlickrWidgetSettings&amp;owner=flickrWidget&amp;selected=showFlickrWidgetSettings'>Configure it</a>		
		" />
	</cffunction>

	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<!--- TODO: Implement Method --->
		<cfreturn />
	</cffunction>
	
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>

	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
		<cfreturn />
	</cffunction>

	<cffunction name="getId" access="public" output="false" returntype="any">
		<cfreturn variables.id />
	</cffunction>

	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="any" required="true" />
		<cfset variables.id = arguments.id />
		<cfreturn />
	</cffunction>

	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
		<cfreturn />
	</cffunction>

	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var data = arguments.event.data />
			<cfset var eventName = arguments.event.name />
			<cfset var pod = "" />
			<cfset var basePath = variables.manager.getBlog().basePath />	
			<cfset var content = "" />
			<cfset var outputData = "" />
			<cfset var link = "" />
			<cfset var page = "" />
			<cfset var path = "" />
			
			<cfif eventName EQ "getPods">
				
				<!--- make sure we can add this to the pods list --->
				<cfif event.allowedPodIds EQ "*" OR listfindnocase(event.allowedPodIds, "flickrWidget")>
					<cfsavecontent variable="content">
					<cfoutput><object id="flickrWidget" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="200" height="210">
					<param name="movie" value="#basePath#assets/plugins/flickrWidget/FlickrWidget.swf" />
					<param name="flashvars" value="tags=#variables.tags#&amp;user=#variables.username#" />
					<param name="wmode" value="transparent" />
	        		<!--[if !IE]>-->
					<object type="application/x-shockwave-flash" data="#basePath#assets/plugins/flickrWidget/FlickrWidget.swf" width="200" height="210">
						<param name="flashvars" value="tags=#variables.tags#&amp;user=#variables.username#" />
						<param name="wmode" value="transparent" />
					<!--<![endif]-->
					<div>
						<p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" /></a></p>
					</div>
					<!--[if !IE]>-->
					</object>
					<!--<![endif]-->
				</object></cfoutput>
					</cfsavecontent>
					
					<cfset pod = structnew() />
					<cfset pod.title = variables.title />
					<cfset pod.content = content />
					<cfset pod.id = "flickrWidget" />
					<cfset arguments.event.addPod(pod)>
				</cfif>
				
			<cfelseif eventName EQ "beforeHtmlHeadEnd">
				<cfsavecontent variable="content"><cfoutput>
					<script type="text/javascript" src="#basePath#assets/plugins/flickrWidget/swfobject.js"></script>
					 <script type="text/javascript">
    swfobject.registerObject("flickrWidget", "9.0.28", "#basePath#assets/plugins/flickrWidget/expressInstall.swf");
    </script>
				</cfoutput>
				</cfsavecontent>
					<cfset data = arguments.event.outputData />
					<cfset data = data & content />
					<cfset arguments.event.outputData = data />
			
			<!--- admin nav event --->
			<cfelseif arguments.event.getName() EQ "settingsNav">
				<cfset link = structnew() />
				<cfset link.owner = "flickrWidget">
				<cfset link.page = "settings" />
				<cfset link.title = "Flickr Widget" />
				<cfset link.eventName = "showFlickrWidgetSettings" />
				
				<cfset arguments.event.addLink(link)>
			
			<!--- admin event --->
			<cfelseif arguments.event.getName() EQ "showFlickrWidgetSettings">
				<cfset data = arguments.event.getData() />				
				<cfif structkeyexists(data.externaldata,"apply")>
					<cfset path = variables.manager.getBlog().getId() & "/" & variables.package />
					<cfset variables.tags = data.externaldata.tags />
					<cfset variables.preferencesManager.put(path,"tags",variables.tags) />
					<cfset variables.username = data.externaldata.username />
					<cfset variables.preferencesManager.put(path,"username",variables.username) />
					<cfset variables.title = data.externaldata.podTitle />
					<cfset variables.preferencesManager.put(path,"podTitle",variables.title) />
					
					<cfset data.message.setstatus("success") />
					<cfset data.message.setType("settings") />
					<cfset data.message.settext("Settings updated")/>
				</cfif>
				
				<cfsavecontent variable="page">
					<cfinclude template="admin/settingsForm.cfm">
				</cfsavecontent>
					
					<!--- change message --->
					<cfset data.message.setTitle("Flickr Widget settings") />
					<cfset data.message.setData(page) />
					
			<cfelseif eventName EQ "getPodsList"><!--- no content, just title and id --->
				<cfset pod = structnew() />
				<cfset pod.title = "Flickr Photos Widget" />
				<cfset pod.id = "flickrWidget" />
				<cfset arguments.event.addPod(pod)>
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>
	


</cfcomponent>