<cfcomponent extends="org.mangoblog.plugins.BasePlugin">
	<cfset variables.package = "com/asfusion/mango/plugins/authorsonly"/>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		
			<cfset setManager(arguments.mainManager) />
			<cfset setPreferencesManager(arguments.preferences) />
			
		<cfreturn this/>
	</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var data = arguments.event.data />
			<cfset var eventName = arguments.event.name />
			<cfset var manager = getManager() />
			<cfset var templates = "" />
			<cfset var template = "" />
			<cfset var loginContent = "" />
			<cfset var address = "" />
			<cfset var errormsg = "" />
			
			<cfif NOT manager.isCurrentUserLoggedIn()>
				<cfset template = "generic.cfm" />
				
				<!--- first check if this page has been defined in the current skin --->
				<cfset templates = manager.getAdministrator().getAdminPageTemplates()>
				<cfif structkeyexists(templates,"login")>
					<cfset template = templates['login'].file />
				<cfelse>
					<cfset address = cgi.script_name />
					<cfif len(cgi.path_info) AND cgi.path_info NEQ cgi.script_name>
						<cfset address = address & cgi.path_info />
					</cfif>
					<cfif len(cgi.query_string)>
						<cfset address = address & "?" & cgi.query_string />
					</cfif>
					<cfif structkeyexists(request, "errormsg")>
						<cfset errormsg = request.errormsg />
					</cfif>
					<cfsavecontent variable="loginContent">
						<cfinclude template="login.cfm">
					</cfsavecontent>
					<cfset data.message.setTitle("Login") />
					<cfset data.message.setText(loginContent) />
				</cfif>
				
				<cfif eventName EQ "beforeIndexTemplate">
					<cfset data.indexTemplate = template />
				<cfelseif eventName EQ "beforePageTemplate">
					<cfset data.pageTemplate = template />
				<cfelseif eventName EQ "beforePostTemplate">
					<cfset data.postTemplate = template />
				<cfelseif eventName EQ "beforeArchivesTemplate">
					<cfset data.archivesTemplate = template />
				<cfelseif eventName EQ "beforeAuthorTemplate">
					<cfset data.authorTemplate = template />
				</cfif>
			
			</cfif>
			
		
		<cfreturn arguments.event />
	</cffunction>
	
</cfcomponent>