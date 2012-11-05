<cfcomponent extends="org.mangoblog.plugins.BasePlugin">

	<cfset variables.package 	= "com/asfusion/mango/postToTwitter"/>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
						
			<cfset super.init(arguments.mainManager, arguments.preferences) />
			<cfset initSettings(username="YOUT_TWITTER_USERNAME", password="YOUR_TWITTER_PASSWORD", schedulePassword='') />
		<cfreturn this/>
		
	</cffunction>
	

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		
		<!--- create a random password to ensure that twitter posts are not repeateadly posted by anyone --->
		<cfset initSettings(schedulePassword='') />
		<cfif NOT len(getSetting('schedulePassword'))>
			<cfset setSettings(schedulePassword=rand()) />
			<cfset persistSettings() />
		</cfif>
		
		<cfset super.setup() />
		<cfreturn "Post to Twitter is activated.<br/>Would you like to <a href='generic_settings.cfm?event=postToTwitter-settings&amp;owner=postToTwitter&amp;selected=postToTwitter-settings'>set it up</a>?" />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
		<cfset var local = structnew() />
		<cfset var eventName = arguments.event.getName() />
		<cfset local.logger = getManager().getLogger() />
		
		<!--- __________________________________ --->
		<cfif eventName eq "afterPostAdd" or eventName eq "afterPostUpdate">
		
			<cfset local.logger.logMessage("debug","Handling afterPostAdd or afterPostUpdate",'plugin','PostToTwitter') />
			
			<!--- logic borrowed from scribe plugin, thanks Adam :) --->
			<cfscript>
				//default to false, do nothing
				local.published = false;
	 
				//if newItem.status = draft, status should not be published
				if (event.data.newItem.getStatus() EQ "published"){
	
					local.published = true;
		 
					//if oldItem.status = published, then this was just a correction, do not published
					//if date has not changed
					if (structKeyExists(event, "oldItem") and not isSimpleValue(event.oldItem) 
						and event.oldItem.getStatus() eq "published" AND 
						event.newItem.getPostedOn() EQ event.oldItem.getPostedOn()){
							local.published = false;
					}
				}
	 
				//get post info
				if (local.published){
					local.publishDate = event.data.newItem.getPostedOn();
					local.postId = event.data.newItem.getId();
				}
			</cfscript>
			
			<cfif local.published>
				<!---
				scheduling a one-run job in the past causes it to be run immediately, so we don't
				need to worry about the publish date/time, just use it!
				--->
				<cfschedule
					task="PostToTwitter_#local.postId#"
					url="#getManager().getBlog().getUrl()#generic.cfm?event=postToTwitter-publish&postId=#local.postId#&schedulePassword=#getSetting('schedulePassword')#"
					action="update"
					operation="HTTPRequest"
					interval="once"
					startDate="#dateFormat(local.publishDate,'yyyy-mm-dd')#"
					startTime="#timeFormat(local.publishDate, 'HH:MM:SS')#"
					/>
			</cfif>
		
		<!--- __________________________________ --->
		<cfelseif eventName EQ "afterPostDelete">
			
			<cfset deleteSchedule(arguments.event.oldItem.getId()) />
			
		<!--- __________________________________ --->
		<cfelseif eventName EQ "postToTwitter-publish">
			
			<cfset local.logger.logMessage("debug","Publishing post started",'plugin','PostToTwitter') />
			
			<!--- check the password --->
			<cfif (structkeyexists(arguments.event.data.externalData, "schedulePassword")
					AND arguments.event.data.externalData.schedulePassword EQ getSetting('schedulePassword'))
				AND structkeyexists(arguments.event.data.externalData, "postId")>
				
				<!--- try to get the post, if it was deleted or not yet published, this will give an error --->
				<cftry>
					<cfset local.post = getManager().getPostsManager().getPostById(arguments.event.data.externalData.postId) />
					<cfset postToTwitter(local.post.getTitle(), local.post.getPermalink()) />
					<cfset local.logger.logMessage("info",
							"Twitter status published",'plugin','PostToTwitter') />
							
					<cfcatch type="PostNotFound">
						<cfset local.logger.logMessage("info",
							"Post was not found, maybe it hasn't been published yet",'plugin','PostToTwitter') />
					</cfcatch>
				</cftry>
				<!--- cleanup: delete the scheduled job --->
				<cfset deleteSchedule(arguments.event.data.externalData.postId) />
				
			<cfelse>
				<cfset local.logger.logMessage("info",
							"Wrong password or required information was not supplied in event",'plugin','PostToTwitter') />
			</cfif>

			
		</cfif>
		
		<cfreturn />

	</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		
		<cfargument name="event" type="any" required="true" />

		<cfset var local = structnew() />
		<cfset var eventName = arguments.event.getName() />

		<cfif eventName EQ "settingsNav">

				<cfset local.link 			= structnew() />
				<cfset local.link.owner 	= "postToTwitter">
				<cfset local.link.page 		= "settings" />
				<cfset local.link.title 	= "Post to Twitter" />
				<cfset local.link.eventName = "postToTwitter-settings" />
				
				<cfset arguments.event.addLink(local.link)>
			
		<cfelseif eventName EQ "postToTwitter-settings">
			
				<cfset local.data = arguments.event.getData() />				
				
				<cfif structkeyexists(local.data.externaldata,"apply")>
					
					<cfset setSettings(username=local.data.externaldata.twitter_username,
										password=local.data.externaldata.twitter_password) />
					<cfset persistSettings() />
					<cfset local.data.message.setstatus("success") />
					<cfset local.data.message.setType("settings") />
					<cfset local.data.message.settext("Account details updated")/>

				</cfif>
			
				<cfsavecontent variable="local.page">
					<cfinclude template="admin/settingsForm.cfm">
				</cfsavecontent>

				<!--- change message --->
				<cfset local.data.message.setTitle("Post to Twitter") />
				<cfset local.data.message.setData(local.page) />
			
		</cfif>
		
		<cfreturn arguments.event />
		
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="postToTwitter" access="private">
		<cfargument name="title" type="string">
		<cfargument name="postUrl" type="string">
		
		<cfset var status = arguments.title  & " " & arguments.postUrl />
		<cfset var twitterLib = createObject("component", "libs.twitterCOM") />
		
		<!--- if everything fits the 140 chars, then send the url as is --->
		<cfif len(status) GT 140>
			<!--- reduce the url --->
			<cfset arguments.postUrl = twitterLib.tinyURL(arguments.postUrl) />
			<cfset status = arguments.title  & " " & arguments.postUrl />
			
			<!--- still too big? --->
			<cfif len(status) GT 140>
				<cfset arguments.title = left(arguments.title, 136 - len(arguments.postUrl)) & "..." />
				<cfset status = arguments.title  & " " & arguments.postUrl />
			</cfif>
		</cfif>
		
		<cfset twitterLib.postStatus(getSetting('username'), getSetting('password'), status) />
		
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="deleteSchedule" access="private">
		<cfargument name="postId" type="string">
		
		<cfschedule
					action="delete"
					task="PostToTwitter_#arguments.postId#" />
	</cffunction>

</cfcomponent>