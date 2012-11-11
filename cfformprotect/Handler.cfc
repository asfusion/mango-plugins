<!--- 
Project:     CFFormProtect plugin for Mango Blog <http://mangoblog.org>Author:      Seb Duggan <seb@sebduggan.com>Version:     1.1Copyright 2009 Seb Duggan

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

######
This file includes code and modification of code from CFFormProtect
by Jake Munson:
http://cfformprotect.riaforge.org/

The original CFFormProtect code is covered by the Mozilla Public License:
http://www.mozilla.org/MPL/
######
--->

<cfcomponent output="false" extends="BasePlugin">

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		
		<cfset super.init(argumentCollection=arguments) />
		<cfset setPackage("com/sebduggan/mango/plugins/cfformprotect") />
		
		<cfset variables.logfile = "CFFormProtect_" & getManager().getBlog().getId() />
		
		<cfscript>
			variables.defaults = structnew();
				// which tests to run
				variables.defaults.mouseMovement = 1;
				variables.defaults.usedKeyboard = 1;
				variables.defaults.timedFormSubmission = 1;
				variables.defaults.hiddenFormField = 1;
				variables.defaults.tooManyUrls = 1;
				variables.defaults.teststrings = 1;
				variables.defaults.linkSleeve = 1;
				variables.defaults.akismet = 0;
				variables.defaults.projectHoneyPot = 0;
				// the points each test costs for failure
				variables.defaults.mouseMovementPoints = 1;
				variables.defaults.usedKeyboardPoints = 1;
				variables.defaults.timedFormPoints = 2;
				variables.defaults.hiddenFieldPoints = 3;
				variables.defaults.tooManyUrlsPoints = 3;
				variables.defaults.spamStringPoints = 2;
				variables.defaults.linkSleevePoints = 3;
				variables.defaults.akismetPoints = 3;
				variables.defaults.projectHoneyPotPoints = 3;
				// settings for individual tests
				variables.defaults.timedFormMinSeconds = 5;
				variables.defaults.timedFormMaxSeconds = 3600;
				variables.defaults.tooManyUrlsMaxUrls = 6;
				variables.defaults.spamstrings = "free music,download music,music downloads,viagra,phentermine,viagra,tramadol,ultram,prescription soma,cheap soma,cialis,levitra,weight loss,buy cheap";
				variables.defaults.akismetAPIKey = "";
				variables.defaults.projectHoneyPotAPIKey = "";
				// how many points will flag the form submission as spam
				variables.defaults.failureLimit = 3;
				variables.defaults.confirmationMethod = 2;
				// email settings
				variables.defaults.emailFailedTests = 0;
				variables.defaults.emailFromAddress = "";
				variables.defaults.emailToAddress = "";
				variables.defaults.emailSubject = "Mango Blog form submission blocked by CFFormProtect";
				// logging
				variables.defaults.logFailedTests = 0;
		</cfscript>
		
		<cfset initSettings(argumentCollection = variables.defaults) />
				
		<cfreturn this/>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<cfreturn "CFFormProtect plugin activated. Would you like to <a href=""generic.cfm?event=CFFormProtect-settings&owner=cfformprotect&selected=CFFormProtect-settings"">configure it now</a>?" />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="upgrade" hint="This is run when a plugin is upgraded" access="public" output="false" returntype="any">
		<cfargument name="fromVersion" type="string" />
		
		<cfset var local = structnew() />
		<cfset var blogid = getManager().getBlog().getId() />
		<cfset var path = blogid & "/" & variables.package />
		
		<cfif arguments.fromVersion EQ "1.0">
			<!--- transfer preferences and move from files to the preferences database --->
			<cfset local.title = variables.preferencesManager.get(path,"podTitle","Search") />
			<cfset local.settingsFile = variables.preferencesManager.get(path,"settingsFile","") />
			
			<cfscript>
				local.defaults = structnew();
				// which tests to run
				local.defaults.mouseMovement = variables.preferencesManager.get(path,"mouseMovement","1");
				local.defaults.usedKeyboard = variables.preferencesManager.get(path,"usedKeyboard","1");
				local.defaults.timedFormSubmission = variables.preferencesManager.get(path,"timedFormSubmission","1");
				local.defaults.hiddenFormField = variables.preferencesManager.get(path,"hiddenFormField","1");
				local.defaults.tooManyUrls = variables.preferencesManager.get(path,"tooManyUrls","1");
				local.defaults.teststrings = variables.preferencesManager.get(path,"teststrings","1");
				local.defaults.akismet = variables.preferencesManager.get(path,"akismet","0");
				local.defaults.projectHoneyPot = variables.preferencesManager.get(path,"projectHoneyPot","0");
				// the points each test costs for failure
				local.defaults.mouseMovementPoints = variables.preferencesManager.get(path,"mouseMovementPoints","1");
				local.defaults.usedKeyboardPoints = variables.preferencesManager.get(path,"usedKeyboardPoints","1");
				local.defaults.timedFormPoints = variables.preferencesManager.get(path,"timedFormPoints","2");
				local.defaults.hiddenFieldPoints = variables.preferencesManager.get(path,"hiddenFieldPoints","3");
				local.defaults.tooManyUrlsPoints = variables.preferencesManager.get(path,"tooManyUrlsPoints","3");
				local.defaults.spamStringPoints = variables.preferencesManager.get(path,"spamStringPoints","2");
				local.defaults.akismetPoints = variables.preferencesManager.get(path,"akismetPoints","3");
				local.defaults.projectHoneyPotPoints = variables.preferencesManager.get(path,"projectHoneyPotPoints","3");
				// settings for individual tests
				local.defaults.timedFormMinSeconds = variables.preferencesManager.get(path,"timedFormMinSeconds","5");
				local.defaults.timedFormMaxSeconds = variables.preferencesManager.get(path,"timedFormMaxSeconds","3600");
				local.defaults.tooManyUrlsMaxUrls = variables.preferencesManager.get(path,"tooManyUrlsMaxUrls","6");
				local.defaults.spamstrings = variables.preferencesManager.get(path,"spamstrings",
					"free music,download music,music downloads,viagra,phentermine,viagra,tramadol,ultram,prescription soma,cheap soma,cialis,levitra,weight loss,buy cheap");
				local.defaults.akismetAPIKey = variables.preferencesManager.get(path,"akismetAPIKey","");
				local.defaults.projectHoneyPotAPIKey = variables.preferencesManager.get(path,"projectHoneyPotAPIKey","");
				// how many points will flag the form submission as spam
				local.defaults.failureLimit = variables.preferencesManager.get(path,"failureLimit","3");
				local.defaults.confirmationMethod = variables.preferencesManager.get(path,"confirmationMethod","2");
				// email settings
				local.defaults.emailFailedTests = variables.preferencesManager.get(path,"emailFailedTests","0");
				local.defaults.emailFromAddress = variables.preferencesManager.get(path,"emailFromAddress","");
				local.defaults.emailToAddress = variables.preferencesManager.get(path,"emailToAddress","");
				local.defaults.emailSubject = variables.preferencesManager.get(path,"emailSubject","Mango Blog form submission blocked by CFFormProtect");
				// logging
				local.defaults.logFailedTests = variables.preferencesManager.get(path,"logFailedTests","0");
			</cfscript>
			<cfset setSettings(argumentCollection = local.defaults) />
			<cfset persistSettings() />
			<cfset initSettings(argumentCollection = local.defaults) />
		</cfif>

		<cfreturn "Google Search upgraded" />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var data = arguments.event.getData() />
			<cfset var message = arguments.event.getMessage() />
			<cfset var akismetData = StructNew() />
			<cfset var LOCAL = StructNew() />
			<cfset var eventName = arguments.event.getName() />
			
			<cfif eventName EQ "beforeHtmlHeadEnd">
				<cfset outData = arguments.event.outputData />
				<cfset outData = outData & '<script type="text/javascript" src="#getAssetPath()#cffp.js"></script>' />
				<cfset arguments.event.outputData = outData />
			
			<cfelseif eventName EQ "beforeCommentAdd">
				
					<!--- Put comment fields into standard format for Akismet --->
					<cfset local.additionalConfig = structnew() />
					<cfset local.additionalConfig.akismetFormNameField = 'comment_name' />
					<cfset local.additionalConfig.akismetFormEmailField = 'comment_email' />
					<cfset local.additionalConfig.akismetFormURLField = 'comment_website' />
					<cfset local.additionalConfig.akismetFormBodyField = 'comment_content' />
					
					<cfset LOCAL.valid = testSubmission(data.rawdata, local.additionalConfig) />
					
					<cfif getManager().isCurrentUserLoggedIn()>
						<!--- maybe this is an author adding a comment from the admin --->
						<cfset LOCAL.valid = true />
					</cfif>
					
					<cfif NOT LOCAL.valid>
						<cfset arguments.event.setContinueProcess(false) />

						<cfswitch expression="#getSetting('confirmationMethod')#">
							
							<cfcase value="1">
								<cfset message.setText("Your comment will be moderated for possible spam.") />
								<cfset message.setStatus("success") />
							</cfcase>
							
							<cfcase value="2">
								<cfset message.setText("Sorry, but your comment appears to be spam and could not be submitted.") />
								<cfset message.setStatus("error") />
							</cfcase>
							
						</cfswitch>
					</cfif>
				
			<cfelseif eventName EQ "beforeFormToEmailSend">
				<!--- inject known fields for Akismet --->
				<cfset local.formFields = duplicate( data.originaleventdata.externaldata )/>
				<cfset local.formFields.comment_content = data.mail.body />
				<cfset local.additionalConfig = structnew() />
				<cfset local.additionalConfig.akismetFormNameField = '' />
				<cfset local.additionalConfig.akismetFormEmailField = '' />
				<cfset local.additionalConfig.akismetFormURLField = '' />
				<cfset local.additionalConfig.akismetFormBodyField = 'comment_content' />
					
				<cfset LOCAL.valid = testSubmission( local.formFields, local.additionalConfig) />
					
				<cfif NOT LOCAL.valid>
						<cfset arguments.event.setContinueProcess(false) />
						
						<cfswitch expression="#getSetting("confirmationMethod")#">
							
							<cfcase value="1">
								<cfset arguments.event.message.text = "Your comment will be moderated for possible spam." />
								<cfset arguments.event.message.status = "success" />
							</cfcase>
							
							<cfcase value="2">
								<cfset arguments.event.message.text = "Sorry, but your comment appears to be spam and could not be submitted." />
								<cfset arguments.event.message.status = "error" />
							</cfcase>
							
						</cfswitch>
					</cfif>
					
				
				<cfelseif eventName EQ "beforeCommentFormEnd" OR eventName EQ "beforeFormToEmailEnd">
					<cfset LOCAL.outputData = arguments.event.getOutputData() />
					
					<cfsavecontent variable="LOCAL.formInputs">
						<cfoutput>
						<cfif getSetting("mouseMovement")>
							<input id="fp<cfoutput>#createuuid()#</cfoutput>" type="hidden" name="formfield1234567891" class="cffp_mm" value="" />
						</cfif>
						
						<cfif getSetting("usedKeyboard")>
							<input id="fp<cfoutput>#createuuid()#</cfoutput>" type="hidden" name="formfield1234567892" class="cffp_kp" value="" />
						</cfif>
						
						<cfif getSetting("timedFormSubmission")>
							<cfset local.currentDate = dateFormat(now(),'yyyymmdd')>
							<cfset local.currentTime = timeFormat(now(),'HHmmss')>
							<!--- Add an arbitrary number to the date/time values to mask them from prying eyes --->
							<cfset local.blurredDate = local.currentDate+19740206>
							<cfset local.blurredTime = local.currentTime+19740206>
							<input id="fp<cfoutput>#createuuid()#</cfoutput>" type="hidden" name="formfield1234567893" value="<cfoutput>#local.blurredDate#,#local.blurredTime#</cfoutput>" />
						</cfif>
						
						<cfif getSetting("hiddenFormField")>
							<span style="display:none">Leave this field empty <input id="fp<cfoutput>#createuuid()#</cfoutput>" type="text" name="formfield1234567894" value="" /></span>
						</cfif>
						</cfoutput>
					</cfsavecontent>
					
					<cfset arguments.event.setOutputData(LOCAL.outputData & LOCAL.formInputs) />

				
				<!--- admin event --->
				<cfelseif eventName EQ "settingsNav">
					<cfset LOCAL.link = structnew() />
					<cfset LOCAL.link.owner = "cfformprotect">
					<cfset LOCAL.link.page = "settings" />
					<cfset LOCAL.link.title = "CFFormProtect" />
					<cfset LOCAL.link.eventName = "CFFormProtect-settings" />
					
					<cfset arguments.event.addLink(LOCAL.link)>

			
				<cfelseif eventName EQ "CFFormProtect-settings" AND getManager().isCurrentUserLoggedIn()>		
					<cfif structkeyexists(data.externaldata,"apply")>
						
						<cfparam name="data.externaldata.logFailedTests" default="0" />
						<cfparam name="data.externaldata.emailFailedTests" default="0" />
						<cfparam name="data.externaldata.mouseMovement" default="0" />
						<cfparam name="data.externaldata.usedKeyboard" default="0" />
						<cfparam name="data.externaldata.timedFormSubmission" default="0" />
						<cfparam name="data.externaldata.hiddenFormField" default="0" />
						<cfparam name="data.externaldata.tooManyUrls" default="0" />
						<cfparam name="data.externaldata.teststrings" default="0" />
						<cfparam name="data.externaldata.akismet" default="0" />
						<cfparam name="data.externaldata.linkSleeve" default="0" />
						<cfparam name="data.externaldata.projectHoneyPot" default="0" />
						
						<cfset LOCAL.newSettings = StructNew() />
						<cfloop collection="#variables.defaults#" item="LOCAL.key">
							<cfset LOCAL.newSettings[LOCAL.key] = data.externaldata[LOCAL.key] />
						</cfloop>
						
						<cfset setSettings(argumentCollection = LOCAL.newSettings) />
						<cfset persistSettings() />
						
						<cfset data.message.setstatus("success") />
						<cfset data.message.setType("settings") />
						<cfset data.message.settext("Settings updated")/>
					</cfif>
					
					<cfsavecontent variable="LOCAL.page">
						<cfinclude template="admin/settingsForm.cfm">
					</cfsavecontent>
						
					<!--- change message --->
					<cfset data.message.setTitle("CFFormProtect settings") />
					<cfset data.message.setData(LOCAL.page) />

			
				<cfelseif eventName EQ "CFFormProtect-akismet">		
					
					<cfsavecontent variable="LOCAL.page">
						<cfinclude template="admin/akismetSubmit.cfm">
					</cfsavecontent>
					
					<!--- change message --->
					<cfset data.message.setTitle("CFFormProtect: Submit to Akismet") />
					<cfset data.message.setData(LOCAL.page) />
				
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="testSubmission" access="public" output="false" returntype="any">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfargument name="additionalConfig" required="false" type="struct" default="#structnew()#" />
		<cfscript>
		var local = structnew();
		var cffp = createObject( 'component', 'cffpVerify' );
		
		local.config = duplicate( variables.settings );
		local.config.akismetBlogURL = "#getManager().getBlog().getUrl()#admin/generic.cfm?event=CFFormProtect-akismet&owner=cfformprotect&selected=CFFormProtect-settings";
		local.config.logFile = variables.logfile;
		structappend( local.config, arguments.additionalConfig );
		
		cffp.setConfig( local.config );

		local.FormStruct = Duplicate(arguments.FormStruct);
		for (local.field in local.FormStruct) {
			if ( not isSimpleValue( local.FormStruct[local.field] ) ) {
				structDelete(local.FormStruct, local.field);
			}
		}
				
		// Begin tests
		local.results = cffp.testSubmission( local.formStruct );
		if ( NOT local.results.pass AND getSetting('emailFailedTests'))	{
			emailReport(TestResults=local.results.TestResults,FormStruct=local.FormStruct,TotalPoints=local.results.TotalPoints, additionalConfig = arguments.additionalConfig);
		}
		
		return local.results.pass;
		</cfscript>
	</cffunction>
	
	<cffunction name="emailReport" access="private" output="false" returntype="void">
		<cfargument name="TestResults" required="true" type="struct" />
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfargument name="TotalPoints" required="true" type="numeric" />
		<cfargument name="additionalConfig" required="false" type="struct" default="#structnew()#" />
		
		<cfscript>
		var local = structnew();
		var cffp = createObject( 'component', 'cffpVerify' );
		var mail =structnew();
		
		local.config = duplicate( variables.settings );
		local.config.akismetBlogURL = "#getManager().getBlog().getUrl()#admin/generic.cfm?event=CFFormProtect-akismet&owner=cfformprotect&selected=CFFormProtect-settings";
		local.config.logFile = variables.logfile;
		structappend( local.config, arguments.additionalConfig );
		
		cffp.setConfig( local.config );
		</cfscript>
		<cfif len(getSetting("emailFromAddress")) and len(getSetting("emailToAddress")) and len(getSetting("emailSubject"))>
			<!--- build email --->
			<cfset mail.from = getSetting("emailFromAddress") />
			<cfset mail.to = getSetting("emailToAddress") />
			<cfset mail.subject = getSetting("emailSubject") />
			<cfset mail.body = cffp.emailReport( TestResults=TestResults,FormStruct=FormStruct,TotalPoints=TotalPoints)  />
			<cfset mail.type = "HTML" />
	
			<!--- send email --->
			<cfset getManager().getMailer().sendEmail(argumentCollection=mail) />
		</cfif>
		
	</cffunction>

</cfcomponent>