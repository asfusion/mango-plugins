<cfcomponent extends="BasePlugin">

	<cfset variables.package = "com/asfusion/mango/plugins/googlesearch"/>

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
			
			<cfset setManager(arguments.mainManager) />
			<cfset setPreferencesManager(arguments.preferences) />
						
			<cfset initSettings(podTitle="Search", searchBoxCode='', searchResultsCode='') />
		<cfreturn this />
	</cffunction>

	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<cfreturn "Google Search activated. <br />You can now <a href='generic_settings.cfm?event=googlesearch-showSettings&amp;owner=googlesearch&amp;selected=googlesearch'>Configure it</a>" />
	</cffunction>

	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="upgrade" hint="This is run when a plugin is upgraded" access="public" output="false" returntype="any">
		<cfargument name="fromVersion" type="string" />
		
		<cfset var local = structnew() />
		<cfset var blogid = getManager().getBlog().getId() />
		<cfset var path = blogid & "/" & variables.package />
		<cfset var content = "" />
		<cfset var separatorPosition = 0 />
		<cfset var formClosePosition = 0 />
		
		<cfif arguments.fromVersion EQ "1.1">
			<!--- transfer preferences and move from files to the preferences database --->
			<cfset local.title = variables.preferencesManager.get(path,"podTitle","Search") />
			<cfset local.settingsFile = variables.preferencesManager.get(path,"settingsFile","") />
			
			<cfif len(local.settingsFile) AND 
				fileexists(GetDirectoryFromPath(GetCurrentTemplatePath()) & "code/" & local.settingsFile)>
				<cfsavecontent variable="content"><cfinclude template="code/#local.settingsFile#">
				</cfsavecontent>
				
				<cfset separatorPosition = findnocase("------",content) />
				<cfif separatorPosition GT 0>
					<cfset local.searchBoxCode = left(content, separatorPosition - 1) />
					<!--- add a hidden input, if needed --->
					<cfif NOT findnocase('<input type="hidden" name="event" value="googlesearch-search" />',local.searchBoxCode)>
						<cfset formClosePosition = findnocase("</form>", local.searchBoxCode) />
						<cfset local.searchBoxCode = insert('<input type="hidden" name="event" value="googlesearch-search" />
						<input type="hidden" name="action" value="event" />',
							local.searchBoxCode, formClosePosition - 1) />
					</cfif>
					
					<cfset local.searchResultsCode = right(content, len(content) - 5 - separatorPosition)>
				</cfif>
			
				<cfset setSettings(podTitle=local.title, 
						searchBoxCode=local.searchBoxCode, 
						searchResultsCode=local.searchResultsCode) />
				<cfset persistSettings() />
				<cfset initSettings(podTitle="Search", searchBoxCode='', searchResultsCode='') />
				<cfdirectory action="delete" recurse="true" directory="#GetDirectoryFromPath(GetCurrentTemplatePath())#code/">
		
			</cfif>
		</cfif>

		<cfreturn "Google Search upgraded" />
	</cffunction>

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
			<cfset var data =  "" />
			<cfset var eventName = arguments.event.name />
			
		<cfreturn />
	</cffunction>

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
		<cfset var data = arguments.event.data />
		<cfset var eventName = arguments.event.name />
		<cfset var content = "" />
		<cfset var outData = "" />
		<cfset var blogid = "" />
		<cfset var path = "" />
		<cfset var pod = "" />
		<cfset var link = "" />
		<cfset var page = "" />
		
		<cfif eventName EQ "getPods">
				
				<!--- make sure we can add this to the pods list --->
				<cfif event.allowedPodIds EQ "*" OR listfindnocase(event.allowedPodIds, "googlesearch")>
					
					<cfset pod = structnew() />
					<cfset pod.title = getSetting("podTitle") />
					<cfset pod.content = getSetting("searchBoxCode") />
					<cfset pod.id = "googlesearch" />
					<cfset arguments.event.addPod(pod)>
				</cfif>
			
			<cfelseif eventName EQ "googlesearch-search">
				<cfset data.message.setData(getSetting("searchResultsCode")) />
				<cfset data.message.setTitle("Search Results for #htmleditformat(data.externaldata.q)#")/>
			
			<cfelseif eventName EQ "googlesearch-showform">
				<cfset outData = arguments.event.outputData />
				<cfset outData = outData & getSetting("searchBoxCode") />
				<cfset arguments.event.outputData = outData />
			
			<!--- admin nav event --->
			<cfelseif eventName EQ "settingsNav">
				<cfset link = structnew() />
				<cfset link.owner = "googlesearch">
				<cfset link.page = "settings" />
				<cfset link.title = "Google Search" />
				<cfset link.eventName = "googlesearch-showSettings" />
				
				<cfset arguments.event.addLink(link)>
			
			<!--- admin event --->
			<cfelseif eventName EQ "googlesearch-showSettings" AND getManager().isCurrentUserLoggedIn()>			
				<cfif structkeyexists(data.externaldata,"apply")>
					
					<cfset setSettings(podTitle=data.externaldata.podTitle, 
						searchBoxCode=data.externaldata.searchBoxCode, 
						searchResultsCode=data.externaldata.searchResultsCode) />
					<cfset persistSettings() />
					
					<cfset data.message.setstatus("success") />
					<cfset data.message.setType("settings") />
					<cfset data.message.settext("Settings updated")/>
				</cfif>
				
				<cfsavecontent variable="page">
					<cfinclude template="admin/settingsForm.cfm">
				</cfsavecontent>
					
					<!--- change message --->
					<cfset data.message.setTitle("Google Search settings") />
					<cfset data.message.setData(page) />
					
			<cfelseif eventName EQ "getPodsList"><!--- no content, just title and id --->
				<cfset pod = structnew() />
				<cfset pod.title = "Google Custom Search" />
				<cfset pod.id = "googlesearch" />
				<cfset arguments.event.addPod(pod)>
			</cfif>
		<cfreturn arguments.event />
	</cffunction>
	
	
</cfcomponent>