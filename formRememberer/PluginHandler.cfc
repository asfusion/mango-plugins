<cfcomponent name="PluginHandler">


	<cfset variables.name = "Form Rememberer">
	<cfset variables.id = "com.asfusion.mango.plugins.formRememberer">

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />

			<cfset variables.manager = arguments.mainManager />
		<cfreturn this/>
	</cffunction>

	
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>

	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
	</cffunction>

	<cffunction name="getId" access="public" output="false" returntype="any">
		<cfreturn variables.id />
	</cffunction>

	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="any" required="true" />
		<cfset variables.id = arguments.id />
	</cffunction>

	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<!--- TODO: Implement Method --->
		<cfreturn />
	</cffunction>

	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<!--- TODO: Implement Method --->
		<cfreturn />
	</cffunction>

	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		<!--- TODO: Implement Method --->
		<cfreturn />
	</cffunction>

	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var data = arguments.event.getData() />
			<cfset var comment = "" />
			<cfset var outputData = "" />
			<cfset var formInputs = "" />
			
			<cfswitch expression="#arguments.event.getName()#">
				<cfcase value="beforeCommentAdd">
					<cfset comment = data.comment />
					
					<!--- check for checkbox value, if exists --->
					<cfif structkeyexists(data.rawdata,"comment_rememberme")>					
						<cfcookie expires="never" name="comment_email" value="#comment.getCreatorEmail()#">
						<cfcookie expires="never" name="comment_name" value="#comment.getCreatorName()#">
						<cfcookie expires="never" name="comment_website" value="#comment.getCreatorUrl()#">
					</cfif>
				
				</cfcase>
				<cfcase value="beforeIndexTemplate,beforeArchivesTemplate,beforeOuputTemplate,beforePageTemplate,beforePostTemplate">
										
					<!--- put cookie values in the request if they don't exist' --->
					<cfif isdefined("cookie")>
						<cfif structKeyExists(data, "externaldata") and NOT structkeyexists(data.externaldata,"comment_email") AND structkeyexists(cookie,"comment_email")>
							<cfset data.externaldata.comment_email = cookie.comment_email />
						</cfif>
						<cfif structKeyExists(data, "externaldata") and NOT structkeyexists(data.externaldata,"comment_name") AND structkeyexists(cookie,"comment_name")>
							<cfset data.externaldata.comment_name = cookie.comment_name />
						</cfif>
						<cfif structKeyExists(data, "externaldata") and NOT structkeyexists(data.externaldata,"comment_website") AND structkeyexists(cookie,"comment_website")>
							<cfset data.externaldata.comment_website = cookie.comment_website />
						</cfif>
					</cfif>
				
				</cfcase>
				<cfcase value="beforeCommentFormEnd">
					<cfset outputData = arguments.event.getOutputData() />
					<cfsavecontent variable="formInputs">
					<cfoutput><br /><label><input name="comment_rememberme" type="checkbox" value="1" /> Remember my information</label><br /></cfoutput>
					</cfsavecontent>
					<cfset arguments.event.setOutputData(outputData & formInputs) />
				</cfcase>
			</cfswitch>
		
		<cfreturn arguments.event />
	</cffunction>


</cfcomponent>