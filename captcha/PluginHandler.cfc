<cfcomponent name="PluginHandler">


	<cfset variables.name = "Captcha Manager">
	<cfset variables.id = "com.blueinstant.captcha">
	<cfset variables.service =  ""/>

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
			
			<cfset variables.service = CreateObject("component", "captchaService").init(configFile="#GetDirectoryFromPath(GetCurrentTemplatePath())#captcha.xml") />
			<cfset variables.service.setup() />
			<cfset variables.manager = arguments.mainManager />
		<cfreturn this/>
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
			<cfset var formInputs = "" />
			<cfset var hashString = "" />
			<cfset var outputData = "" />
			<cfset var valid = false />
			<cfset var userInput = "" />
			<cfset var message = arguments.event.getMessage() />
			
			<cfswitch expression="#arguments.event.getName()#">
				<cfcase value="beforeCommentAdd">
					<!--- check for valid captcha, otherwise, reject --->
					<cfif structkeyexists(data.rawdata,"hashReference") AND structkeyexists(data.rawdata,"captchaText")>
						<cfset hashString = data.rawdata.hashReference />
						<cfset userInput = data.rawdata.captchaText />
						<cfset valid = variables.service.validateCaptcha(hashString,userInput) />
					<cfelseif data.newItem.getAuthorId() NEQ "">
						<!--- maybe this is an author adding a comment from the admin --->
						<cfset valid = true />
					</cfif>
					
					<cfset arguments.event.setContinueProcess(valid) />
					<cfif NOT valid>
						<cfset message.setText("Invalid picture text. Please try again") />
						<cfset message.setStatus("error") />
					</cfif>
					
				</cfcase>
				<cfcase value="beforeFormToEmailSend">
					<!--- check for valid captcha, otherwise, reject --->
					<cfif structkeyexists(data.originalEventData.externalData,"hashReference") AND 
							structkeyexists(data.originalEventData.externalData,"captchaText")>
						<cfset hashString = data.originalEventData.externalData.hashReference />
						<cfset userInput = data.originalEventData.externalData.captchaText />
						<cfset valid = variables.service.validateCaptcha(hashString,userInput) />
					</cfif>
					
					<cfset arguments.event.setContinueProcess(valid) />
					<cfif NOT valid>
						<cfset message.text = "Invalid picture text. Please try again" />
						<cfset message.status = "error" />
					</cfif>
				</cfcase>
				<cfcase value="beforeCommentFormEnd,beforeFormToEmailEnd">
					<cfset hashString = variables.service.createHashReference() />
					<cfset outputData = arguments.event.getOutputData() />
					<cfsavecontent variable="formInputs"><cfoutput>
					<img src="#variables.manager.getBlog().getBasePath()#output.cfm?action=event&amp;event=displayLylaCaptcha&amp;hashReference=#hashString.hash#" /><br />
					<label>Text you see in the picture: <br /><input name="captchaText" type="text" value="" /></label>
					<input name="HashReference" type="hidden" value="#hashString.hash#" /><br /></cfoutput>
					</cfsavecontent>
					<cfset arguments.event.setOutputData(outputData & formInputs) />
				</cfcase>
				<cfcase value="displayLylaCaptcha">
					<cfset hashString = data.externaldata.hashReference />
					<cfcontent type="image/jpg" reset="false" />
					<cfset data.message.setData(variables.service.createCaptchaFromHashReference("stream",hashString).stream) />
					
				</cfcase>
			</cfswitch>
		
		<cfreturn arguments.event />
	</cffunction>


</cfcomponent>