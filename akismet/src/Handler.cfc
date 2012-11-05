<cfcomponent extends="org.mangoblog.plugins.BasePlugin">

	<cfset variables.package = "com/asfusion/mango/plugins/akismet"/>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
			
			<cfset super.init(argumentCollection=arguments) />
			<cfset initSettings(apiKey='YOUR_AKISMET_API_KEY', mode='moderate') />
			
		<cfreturn this/>
	</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<cfreturn "Akismet plugin activated. <br />You can now <a href='generic_settings.cfm?event=showAkismetSettings&amp;owner=askimet&amp;selected=showAkismetSettings'>Configure it</a>" />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="upgrade" hint="This is run when a plugin is upgraded" access="public" output="false" returntype="any">
		<cfargument name="fromVersion" type="string" />
		
		<cfset var blogid = getManager().getBlog().getId() />
		<cfset var path = blogid & "/" & variables.package />
		
		<cfif arguments.fromVersion EQ "1.1">
			<cfset setSettings(apiKey=getPreferencesManager().get(path,"apiKey","YOUR_AKISMET_API_KEY"),
								mode=getPreferencesManager().get(path,"mode","moderate")) />
			<cfset persistSettings() />
			<cfset getPreferencesManager().removeNode(path) />
			<cfset initSettings(apiKey='YOUR_AKISMET_API_KEY', mode='moderate') />
		</cfif>

		<cfreturn "Akismet upgraded" />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var outputData = "" />
			<cfset var link = "" />
			<cfset var page = "" />
			<cfset var data = ""/>
			<cfset var verificationArgs = structnew() />
			<cfset var eventName = arguments.event.name />
			<cfset var comment = "" />
			<cfset var isSpam = false>
			<cfset var entry = "">
			<cfset var manager = getManager() />
			
			<cfif eventName EQ "beforeCommentAdd">
				<cfset comment = arguments.event.getNewItem() />
				<cfif NOT len(comment.getAuthorId())>
					<!--- check for spam only if non-author --->
					<!--- test for spam --->
					<cfif NOT structkeyexists(variables, 'cfakismet')>
						<cfset initAskimet() />
					</cfif>
					
					<cfif variables.cfakismet.verifyKey()>				
						
						<cftry>
							<cftry>
							<cfset entry = manager.getPostsmanager().getPostById(comment.getEntryId())>
							<cfcatch type="any">
								<cfset entry = manager.getPagesManager().getPageById(comment.getEntryId()) />
							</cfcatch>
							</cftry>
							<cfset verificationArgs.CommentAuthor = comment.getCreatorName() />
							<cfset verificationArgs.CommentAuthorEmail = comment.getCreatorEmail() />
							<cfset verificationArgs.CommentAuthorURL = comment.getCreatorUrl() />
							<cfset verificationArgs.CommentContent = comment.getContent() />
							<cfset verificationArgs.Permalink  = manager.getBlog().getUrl() & entry.getUrl() />
							
							<cfset isSpam = variables.cfakismet.isCommentSpam(argumentCollection= verificationArgs) />					
							
							<cfcatch type="any"></cfcatch>
						</cftry>
						
						<cfif isSpam and getSetting('mode') EQ "moderate">
							<cfset comment.setApproved(0) />
							<cfset comment.setRating(-1) />
						<cfelseif isSpam and getSetting('mode') EQ "reject">
							<cfset arguments.event.message.status = "error" />
							<cfset arguments.event.message.text = "Comment was marked as spam and could not be submitted" />
							<cfset arguments.event.continueProcess = false />
						</cfif>
					</cfif>
				</cfif>
			<!--- admin nav event --->
			<cfelseif eventName EQ "settingsNav" AND manager.isCurrentUserLoggedIn()>
				<cfset link = structnew() />
				<cfset link.owner = "askimet">
				<cfset link.page = "settings" />
				<cfset link.title = "Akismet" />
				<cfset link.eventName = "showAkismetSettings" />
				
				<cfset arguments.event.addLink(link)>
			
			<!--- admin event, make sure user is logged in --->
			<cfelseif eventName EQ "showAkismetSettings" AND manager.isCurrentUserLoggedIn()>
				<cfset data = arguments.event.getData() />
				<cfif structkeyexists(data.externaldata,"apply")>
					
					<cfset setSettings(apiKey=data.externaldata.apiKey, mode=data.externaldata.mode)>
					<cfset persistSettings() />
					
					<cfset data.message.setstatus("success") />
					<cfset data.message.setType("settings") />
					<cfset data.message.settext("Settings updated")/>
				</cfif>
				
				<cfsavecontent variable="page">
					<cfinclude template="admin/settingsForm.cfm">
				</cfsavecontent>
					
					<!--- change message --->
					<cfset data.message.setTitle("Akismet settings") />
					<cfset data.message.setData(page) />
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="initAskimet" access="private">
		
		<cfset var manager = getManager() />
		<cfset variables.cfakismet = createObject("component","CFAkismet").init() />
		<cfset variables.cfakismet.setBlogURL(manager.getBlog().getUrl()) />
		<cfset variables.cfakismet.setKey(getSetting('apiKey')) />
		<cfset variables.cfakismet.setApplicationName("Mango " & manager.getVersion()) />
		
	</cffunction>

</cfcomponent>