<cfcomponent extends="org.mangoblog.plugins.BasePlugin">

	<cfset variables.name = "Google Analytics">
	<cfset variables.id = "com.asfusion.mango.plugins.googleanalytics">
	<cfset variables.package = "com/asfusion/mango/plugins/googleanalytics"/>

	<cfset this.events = [
		{ 'name' = 'beforeHtmlBodyEnd', 'type' = 'sync', 'priority' = 5 },
		{ 'name' = 'settingsNav', 'type' = 'sync', 'priority' = 5 },
  		{ 'name' = 'showGoogleAnalyticsSettings', 'type' ='sync', 'priority' = 5 },
		{ 'name' = 'dashboardPod', 'type' = 'sync', 'priority' = 5 }
		] />

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		
			<cfset var blogid = arguments.mainManager.getBlog().getId() />
			<cfset var path = blogid & "/" & variables.package />
			<cfset variables.preferencesManager = arguments.preferences />
			<cfset variables.manager = arguments.mainManager />
			<cfset variables.googleCode = variables.preferencesManager.get(path,"accountNumber","YOUR_ACCOUNT_NUMBER") />
			
		<cfreturn this/>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<cfreturn "Google Analytics activated. <br />You can now <a href='generic_settings.cfm?event=showGoogleAnalyticsSettings&amp;owner=googleAnalytics&amp;selected=showGoogleAnalyticsSettings'>Configure it</a>" />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var js = "" />
			<cfset var outputData = "" />
			<cfset var link = "" />
			<cfset var page = "" />
			<cfset var data = ""/>
			<cfset var path = "" />
			<cfset var admin = "" />
			<cfset var eventName = arguments.event.name />
			
			<cfif eventName EQ "beforeHtmlBodyEnd">
				<cfset outputData =  arguments.event.getOutputData() />
					
				<cfsavecontent variable="js"><cfoutput>
				<!-- Google tag (gtag.js) -->
				<script async src="https://www.googletagmanager.com/gtag/js?id=#variables.googleCode#"></script>
				<script>
					window.dataLayer = window.dataLayer || [];
					function gtag(){dataLayer.push(arguments);}
					gtag('js', new Date());

					gtag('config', '#variables.googleCode#');
				</script>
				</cfoutput></cfsavecontent>
				<cfset arguments.event.setOutputData(outputData & js) />
			
			<!--- admin dashboard event --->
			<cfelseif eventName EQ "dashboardPod" AND variables.manager.isCurrentUserLoggedIn()>		
				<cfif variables.googleCode EQ "YOUR_ACCOUNT_NUMBER">
					<!--- add a pod warning about missin account number --->
				
					<cfsavecontent variable="outputData">
					<cfoutput><p class="error">You have not entered your Google Analytics account number yet</p>
							<p><a href="generic_settings.cfm?event=showGoogleAnalyticsSettings&amp;owner=googleAnalytics&amp;selected=showGoogleAnalyticsSettings">Enter account number</a></p>
					</cfoutput>
					</cfsavecontent>			
					
					<cfset data = structnew() />
					<cfset data.title = "Google Analytics" />
					<cfset data.content = outputData />
					<cfset arguments.event.addPod(data)>
				</cfif>
				
			<!--- admin nav event --->
			<cfelseif eventName EQ "settingsNav">
				<cfset link = structnew() />
				<cfset link.owner = "googleAnalytics">
				<cfset link.page = "settings" />
				<cfset link.title = "Google Analytics" />
				<cfset link.eventName = "showGoogleAnalyticsSettings" />
				
				<cfset arguments.event.addLink(link)>
			
			<!--- admin event --->
			<cfelseif eventName EQ "showGoogleAnalyticsSettings" AND variables.manager.isCurrentUserLoggedIn()>
				<cfset data = arguments.event.getData() />				
				<cfif structkeyexists(data.externaldata,"apply")>
					<cfset variables.googleCode = data.externaldata.googleAnalyticsCode />
					<cfset path = variables.manager.getBlog().getId() & "/" & variables.package />
					<cfset variables.preferencesManager.put(path,"accountNumber",variables.googleCode) />
					
					<cfset data.message.setstatus("success") />
					<cfset data.message.setType("settings") />
					<cfset data.message.settext("Account number updated")/>
				</cfif>
				
				<cfsavecontent variable="page">
					<cfinclude template="admin/settingsForm.cfm">
				</cfsavecontent>
					
					<!--- change message --->
					<cfset data.message.setTitle("Google Analytics settings") />
					<cfset data.message.setData(page) />
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>

</cfcomponent>