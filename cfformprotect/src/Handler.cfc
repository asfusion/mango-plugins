<!--- 
Project:     CFFormProtect plugin for Mango Blog <http://mangoblog.org>Author:      Seb Duggan <seb@sebduggan.com>Version:     1.1Build date:  2009-04-14 15:55:57Check for updated versions at <http://code.google.com/p/mangoplugins/>


Copyright 2009 Seb Duggan

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
		
		<cfset setManager(arguments.mainManager) />
		<cfset setPreferencesManager(arguments.preferences) />
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
				variables.defaults.akismet = 0;
				variables.defaults.projectHoneyPot = 0;
				// the points each test costs for failure
				variables.defaults.mouseMovementPoints = 1;
				variables.defaults.usedKeyboardPoints = 1;
				variables.defaults.timedFormPoints = 2;
				variables.defaults.hiddenFieldPoints = 3;
				variables.defaults.tooManyUrlsPoints = 3;
				variables.defaults.spamStringPoints = 2;
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
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var data = arguments.event.getData() />
			<cfset var message = arguments.event.getMessage() />
			<cfset var akismetData = StructNew() />
			<cfset var LOCAL = StructNew() />
			<cfset var eventName = arguments.event.getName() />
			
			<cfif eventName EQ "beforeCommentAdd">
				
					<!--- Put comment fields into standard format for Akismet --->
					<cfset akismetData.comment_author = data.rawdata.comment_name />
					<cfset akismetData.comment_author_email = data.rawdata.comment_email />
					<cfset akismetData.comment_author_url = data.rawdata.comment_website />
					<cfset akismetData.comment_content = data.rawdata.comment_content />
					
					<cfset LOCAL.valid = testSubmission(data.rawdata, akismetData) />
					
					<cfif data.newItem.getAuthorId() NEQ "">
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
					
					<!--- Put form fields into standard format for Akismet --->
					<cfset akismetData.comment_author = "" />
					<cfset akismetData.comment_author_email = data.mail.from />
					<cfset akismetData.comment_author_url = "" />
					<cfset akismetData.comment_content = data.mail.body />
					
					<cfset LOCAL.valid = testSubmission(data.originaleventdata.externaldata, akismetData) />
					
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
							<input type="hidden" name="formfield1234567891" id="formfield1234567891<cfif eventName is "beforeFormToEmailEnd">_a</cfif>" value="" />
							<cfhtmlhead text="<script type=""text/javascript"" src=""#getAssetPath()#mouseMovement.js""></script>" />
						</cfif>
						
						<cfif getSetting("usedKeyboard")>
							<input type="hidden" name="formfield1234567892" id="formfield1234567892<cfif eventName is "beforeFormToEmailEnd">_a</cfif>" value="" />
							<cfhtmlhead text="<script type=""text/javascript"" src=""#getAssetPath()#usedKeyboard.js""></script>" />
						</cfif>
						
						<cfif getSetting("timedFormSubmission")>
							<!--- get the current time, obfuscate it and load it to this hidden field --->
							<cfset LOCAL.currentDate = dateFormat(now(),'yyyymmdd') />
							<cfset LOCAL.currentTime = timeFormat(now(),'HHmmss') />
							<!--- Add an arbitrary number to the date/time values to mask them from prying eyes --->
							<cfset LOCAL.blurredDate = LOCAL.currentDate + 19740206 />
							<cfset LOCAL.blurredTime = LOCAL.currentTime + 19740206 />
							<input type="hidden" name="formfield1234567893" value="#LOCAL.blurredDate#,#LOCAL.blurredTime#" />
						</cfif>
						
						<cfif getSetting("hiddenFormField")>
							<span style="display:none">Leave this field empty: <input type="text" name="formfield1234567894" value="" /></span>
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
		<cfargument name="akismetData" required="true" type="struct" />
		<cfscript>
		var Pass = true;
		// each time a test fails, totalPoints is incremented by the user specified amount
		var TotalPoints = 0;
		// setup a variable to store a list of tests that failed, for informational purposes
		var TestResults = StructNew();
		var local = structnew();

		local.FormStruct = Duplicate(arguments.FormStruct);
		for (local.field in local.FormStruct) {
			if ( not isSimpleValue( local.FormStruct[local.field] ) ) {
				structDelete(local.FormStruct, local.field);
			}
		}
				
		// Begin tests		
		// Test for mouse movement
		try	{
			if (getSetting("mouseMovement"))	{
				TestResults.MouseMovement = testMouseMovement(local.FormStruct);
				if (NOT TestResults.MouseMovement.Pass)	{
					// The mouse did not move
					TotalPoints = TotalPoints + getSetting("mouseMovementPoints");
				}
			}
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	

		
		// Test for used keyboard
		try	{
			if (getSetting("usedKeyboard"))	{
				TestResults.usedKeyboard = testUsedKeyboard(local.FormStruct);
				if (NOT TestResults.usedKeyboard.Pass)	{
					// No keyboard activity was detected
					TotalPoints = TotalPoints + getSetting("usedKeyboardPoints");			
				}
			}					
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	

		
		// Test for time taken on the form
		try	{
			if (getSetting("timedFormSubmission"))	{
				TestResults.timedFormSubmission = testTimedFormSubmission(local.FormStruct);
				if (NOT TestResults.timedFormSubmission.Pass)	{
					// Time was either too short, too long, or the form field was altered
					TotalPoints = TotalPoints + getSetting("timedFormPoints");			
				}
			}						
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	


		// Test for empty hidden form field
		try	{
			if (getSetting("hiddenFormField"))	{
				TestResults.hiddenFormField = testHiddenFormField(local.FormStruct);
				if (NOT TestResults.hiddenFormField.Pass)	{
					// The submitter filled in a form field hidden via CSS
					TotalPoints = TotalPoints + getSetting("hiddenFieldPoints");			
				}
			}			
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	

		
		// Test Akismet
		try	{
			if (getSetting("akismet"))	{
				TestResults.akismet = testAkismet(local.FormStruct, arguments.akismetData);
				if (NOT TestResults.akismet.Pass)	{
					// Akismet says this form submission is spam
					TotalPoints = TotalPoints + getSetting("akismetPoints");
				}
			}
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	

		
		// Test tooManyUrls
		try	{
			if (getSetting("tooManyUrls"))	{
				TestResults.tooManyUrls = TestTooManyUrls(local.FormStruct);
				if (NOT TestResults.tooManyUrls.Pass)	{
					// Submitter has included too many urls in at least one form field
					TotalPoints = TotalPoints + getSetting("tooManyUrlsPoints");
				}
			}			
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	

		// Test spamStrings
		try	{
			if (getSetting("teststrings"))	{
				TestResults.SpamStrings = testSpamStrings(local.FormStruct);
				if (NOT TestResults.SpamStrings.Pass)	{
					// Submitter has included a spam string in at least one form field
					TotalPoints = TotalPoints + getSetting("spamStringPoints");
				}
			}			
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	
		
		// Test Project Honey Pot
		try	{
			if (getSetting("projectHoneyPot"))	{
				TestResults.ProjHoneyPot = testProjHoneyPot(local.FormStruct);
				if (NOT TestResults.ProjHoneyPot.Pass)	{
					// Submitter has included a spam string in at least one form field
					TotalPoints = TotalPoints + getSetting("projectHoneyPotPoints");
				}
			}			
		}
		catch(any excpt)	{ /* an error occurred on this test, but we will move one */ }	

		// Compare the total points from the spam tests to the user specified failure limit
		if (TotalPoints GTE getSetting("failureLimit"))	{
			Pass = false;	
			try	{
				if (getSetting("emailFailedTests"))	{
					emailReport(TestResults=TestResults,FormStruct=local.FormStruct,TotalPoints=TotalPoints,akismetData=arguments.akismetData);	
				}				
			}
			catch(any excpt)	{ /* an error has occurred emailing the report, but we will move on */ }
			try	{
				if (getSetting("logFailedTests"))	{
					logFailure(TestResults=TestResults,FormStruct=local.FormStruct,TotalPoints=TotalPoints,akismetData=arguments.akismetData);	
				}				
			}
			catch(any excpt)	{ /* an error has occurred logging the spam, but we will move on */ }
		}
		return pass;
		</cfscript>
	</cffunction>
	
	<cffunction name="testMouseMovement" access="private" output="false" returntype="struct"
				hint="I make sure this form field exists, and it has a numeric value in it (the distance the mouse traveled)">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfscript>
		var Result = StructNew();
		Result.Pass = false;
		if (StructKeyExists(arguments.FormStruct,"formfield1234567891") AND IsNumeric(arguments.FormStruct.formfield1234567891))	{
			Result.Pass = true;
		}	
		return Result;
		</cfscript>
	</cffunction>	
	
	<cffunction name="testUsedKeyboard" access="private" output="false" returntype="struct"
				hint="I make sure this form field exists, and it has a numeric value in it (the amount of keys pressed by the user)">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfscript>
		var Result = StructNew();
		Result.Pass = false;
		if (StructKeyExists(arguments.FormStruct,"formfield1234567892") AND IsNumeric(arguments.FormStruct.formfield1234567892))	{
			Result.Pass = true;
		}	
		return Result;
		</cfscript>		
	</cffunction>
	
	<cffunction name="testTimedFormSubmission" access="private" output="false" returntype="struct" 
					hint="I check the time elapsed from the begining of the form load to the form submission">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfscript>
		var Result = StructNew();
		var FormDate = "";
		var FormTime = "";
		var FormDateTime = "";
		//var FormTimeElapsed = "";
		
		Result.Pass = true;
								
		// Decrypt the initial form load time
		if (StructKeyExists(arguments.FormStruct,"formfield1234567893") AND ListLen(form.formfield1234567893) eq 2)	{
			FormDate = ListFirst(form.formfield1234567893)-19740206;
			if (Len(FormDate) EQ 7) {
				FormDate = "0" & FormDate;	
			}
			FormTime = ListLast(form.formfield1234567893)-19740206;
			if (Len(FormTime))	{
				// in original form, FormTime was always padded with a "0" below.  In my testing, this caused the timed test to fail
				// consistantly after 9:59am due to the fact it was shifting the time digits one place to the right with 2 digit hours.  
				// To make this work I added NumberFormat()
				FormTime = NumberFormat(FormTime,000000);
			}
			
			FormDateTime = CreateDateTime(Left(FormDate,4),Mid(FormDate,5,2),Right(FormDate,2),Left(FormTime,2),Mid(FormTime,3,2),Right(FormTime,2));
			// Calculate how many seconds elapsed
			Result.FormTimeElapsed = DateDiff("s",FormDateTime,Now());
			if (Result.FormTimeElapsed LT getSetting("timedFormMinSeconds") OR Result.FormTimeElapsed GT getSetting("timedFormMaxSeconds"))	{
				Result.Pass = false;
			}
		}	
		else	{
			Result.Pass = false;
		}
		return Result;
		</cfscript>
	</cffunction>
	
	<cffunction name="testHiddenFormField" access="private" output="false" returntype="struct"
				hint="I make sure the CSS hidden form field doesn't have a value">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfscript>
		var Result = StructNew();
		Result.Pass = false;
		if (StructKeyExists(arguments.FormStruct,"formfield1234567894") AND NOT Len(arguments.FormStruct.formfield1234567894))	{
			Result.Pass = true;
		}	
		return Result;		
		</cfscript>
	</cffunction>

	<cffunction name="testAkismet" access="private" output="false" returntype="struct"
				hint="I send form contents to the public Akismet service to validate that it's not 'spammy'">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfargument name="akismetData" required="true" type="struct" />
		<cfscript>
		var Result = StructNew();
		var AkismetKeyIsValid = false;
		var AkismetHTTPRequest = true;
		Result.Pass = true;
		Result.ValidKey = false;
		</cfscript>
		
		<cftry>
			<!--- validate the Akismet API key --->
			<cfhttp url="http://rest.akismet.com/1.1/verify-key" timeout="10" method="post" throwonerror="true">
				<cfhttpparam name="key" type="formfield" value="#getSetting("akismetAPIKey")#" />
				<cfhttpparam name="blog" type="formfield" value="#getManager().getBlog().getUrl()#" />
			</cfhttp>
 			<cfcatch type="any">
				<cfset AkismetHTTPRequest = false />
				<cflog file="#variables.logfile#" text="Unable to validate Akismet API key" />
			</cfcatch>
		</cftry>
		<cfif AkismetHTTPRequest AND Trim(cfhttp.FileContent) EQ "valid">
			<cfset AkismetKeyIsValid = true />
			<cfset Result.ValidKey = true />
		</cfif>
		<cfif AkismetKeyIsValid>
		
			<cftry>
				<!--- send form contents to Akismet API --->
				<cfhttp url="http://#getSetting("akismetAPIKey")#.rest.akismet.com/1.1/comment-check" timeout="10" method="post" throwonerror="true">
					<cfhttpparam name="key" type="formfield" value="#getSetting("akismetAPIKey")#" />
					<cfhttpparam name="blog" type="formfield" value="#getManager().getBlog().getUrl()#" />
					<cfhttpparam name="user_ip" type="formfield" value="#cgi.remote_addr#" />
					<cfhttpparam name="user_agent" type="formfield" value="CFFormProtect for Mango Blog/1.0 | Akismet/1.11" />
					<cfhttpparam name="referrer" type="formfield" value="#cgi.http_referer#" />
					<cfhttpparam name="comment_author" type="formfield" value="#arguments.akismetData.comment_author#" />
					<cfhttpparam name="comment_author_email" type="formfield" value="#arguments.akismetData.comment_author_email#" />
					<cfhttpparam name="comment_author_url" type="formfield" value="#arguments.akismetData.comment_author_url#" />
					<cfhttpparam name="comment_content" type="formfield" value="#arguments.akismetData.comment_content#" />
				</cfhttp>
				
				<cfcatch type="any">
					<cfset AkismetHTTPRequest = false />
					<cflog file="#variables.logfile#" text="Akismet error: #cfcatch.message#" />
				</cfcatch>
			</cftry>
				<!--- check Akismet results --->
				<cfif AkismetHTTPRequest AND Trim(cfhttp.FileContent)>
					<!--- Akismet says this form submission is spam --->
					<cfset Result.Pass = false />
				</cfif>
		</cfif>
		<cfreturn Result />
	</cffunction>
	
	<cffunction name="testTooManyUrls" access="private" output="false" returntype="struct"
				hint="I test whether too many URLs have been submitted in fields">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfscript>
		var Result = StructNew();
		var i = "";
		// Make a duplicate since this is passed by reference and we don't want to modify the original data
		var FormStructCopy = Duplicate(arguments.FormStruct);
		var UrlCount = "";
		
		Result.Pass = true;
		for (i=1;i LTE ListLen(arguments.FormStruct.FieldNames);i=i+1)	{
			UrlCount = -1;
			while (FindNoCase("http://",FormStructCopy[ListGetAt(arguments.FormStruct.FieldNames,i)]))	{
				FormStructCopy[ListGetAt(arguments.FormStruct.FieldNames,i)] = ReplaceNoCase(FormStructCopy[ListGetAt(arguments.FormStruct.FieldNames,i)],"http://","","one");
				UrlCount = UrlCount + 1;
			}	
			if (UrlCount GTE getSetting("tooManyUrlsMaxUrls"))	{
				Result.Pass = false;
				break;	
			}
		}
		return Result;
		</cfscript>
	</cffunction>
	
	<cffunction name="listFindOneOf" output="false" returntype="boolean">
		<cfargument name="texttosearch" type="string" required="yes"/>
		<cfargument name="values" type="string" required="yes"/>
		<cfargument name="delimiters" type="string" required="no" default=","/>
		<cfset var value = 0/>
		<cfloop list="#arguments.values#" index="value" delimiters="#arguments.delimiters#">
			<cfif FindNoCase(value, arguments.texttosearch)>
				<cfreturn false />
			</cfif>
		</cfloop>
		<cfreturn true />
	</cffunction>

	<cffunction name="testSpamStrings" access="private" output="false" returntype="struct"
				hint="I test whether any of the configured spam strings are found in the form submission">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfscript>
		var Result = StructNew();
		var value = 0;
		var teststrings = getSetting("spamstrings");
		var checkfield = '';
		Result.Pass = true;
		
		// Loop through the list of spam strings to see if they are found in the form submission		
		for (checkfield in arguments.FormStruct)	{
			if (Result.Pass IS true)	{
				Result.Pass = listFindOneOf(arguments.FormStruct[checkfield],teststrings);
			}
		}
		return Result;
		</cfscript>
	</cffunction>

	<cffunction name="testProjHoneyPot" access="private" output="false" returntype="struct"
				hint="I send the user's IP address to the Project Honey Pot service to check if it's from a known spammer.">
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfset var Result = StructNew()>
		<cfset var apiKey = getSetting("projectHoneyPotAPIKey")>
		<cfset var visitorIP = cgi.remote_addr> <!--- 93.174.93.221 is known to be bad --->
		<cfset var reversedIP = "">
		<cfset var addressFound = 1>
		<cfset var isSpammer = 0>
		<cfset var inetObj = "">
		<cfset var hostNameObj = "">
		<cfset var projHoneypotResult = "">
		<cfset var resultArray = "">
		<cfset var threatScore = "">
		<cfset var classification = "">
		<cfset Result.Pass = true>
		
		<!--- Setup the DNS query string --->
		<cfset reversedIP = listToArray(visitorIP,".")>
		<cfset reversedIP = reversedIP[4]&"."&reversedIP[3]&"."&reversedIP[2]&"."&reversedIP[1]>

		<cftry>
			<!--- Query Project Honeypot for this address --->
			<cfset inetObj = createObject("java", "java.net.InetAddress")>
			<cfset hostNameObj = inetObj.getByName("#apiKey#.#reversedIP#.dnsbl.httpbl.org")>
			<cfset projHoneypotResult = hostNameObj.getHostAddress()>
			<cfcatch type="java.net.UnknownHostException">
				<!--- The above Java code throws an exception when the address is not
							found in the Project Honey Pot database. --->
				<cfset addressFound = 0>
			</cfcatch>
		</cftry>
		
		<cfif addressFound>
			<cfset resultArray = listToArray(projHoneypotResult,".")>
			<!--- resultArray[3] is the threat score for the address, rated from 0 to 255.
						resultArray[4] is the classification for the address, anything higher than
						1 is either a harvester or comment spammer --->
			<cfset threatScore = resultArray[3]>
			<cfset classification = resultArray[4]>
			<cfif (threatScore gt 10) and (classification gt 1)>
				<cfset isSpammer = isSpammer+1>
			</cfif>
		</cfif>
		
		<cfif isSpammer>
			<cfset Result.Pass = false>
		</cfif>
		
		<cfreturn Result>
	</cffunction>

	<cffunction name="emailReport" access="private" output="false" returntype="void">
		<cfargument name="TestResults" required="true" type="struct" />
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfargument name="TotalPoints" required="true" type="numeric" />
		<cfargument name="akismetData" required="true" type="struct" />
		<cfscript>
		var akismetURL = "";
		var mailBody = "";
		var mail = StructNew();
		</cfscript>
		<!--- Here is where you might want to make some changes, to customize what happens
				if a spam message is found.  depending on your system, you can either just use
				my code here, or email yourself the failed test, or plug into your system
				in the best way for your needs --->
					
	 	<cfsavecontent variable="mailBody">
		 	<cfoutput>
			<p>This message was marked as spam because:</p>
			<ol>
				<cfif StructKeyExists(arguments.TestResults,"mouseMovement") AND NOT arguments.TestResults.mouseMovement.Pass>
					<li>No mouse movement was detected [#getSetting("mouseMovementPoints")#]</li>
				</cfif>
				
				<cfif StructKeyExists(arguments.TestResults,"usedKeyboard") AND NOT arguments.TestResults.usedKeyboard.Pass>
					<li>No keyboard activity was detected [#getSetting("usedKeyboardPoints")#]</li>
				</cfif>
				
				<cfif StructKeyExists(arguments.TestResults,"timedFormSubmission") AND NOT arguments.TestResults.timedFormSubmission.Pass>
					<cfif StructKeyExists(arguments.FormStruct,"formfield1234567893")>
						<li>
							The time it took to fill out the form was 
							<cfif arguments.FormStruct.formfield1234567893 lt getSetting("timedFormMinSeconds")>
								too short.
							<cfelseif arguments.FormStruct.formfield1234567893 gt getSetting("timedFormMaxSeconds")>
								too long.
							</cfif>
							It took them #arguments.TestResults.FormTimeElapsed# seconds to submit the form, and your allowed
							threshold is #getSetting("timedFormMinSeconds")#-#getSetting("timedFormMaxSeconds")# seconds [#getSetting("timedFormPoints")#]
						</li>
					<cfelse>
						<li>
							The time it took to fill out the form did not fall within your configured threshold
							of #getSetting("timedFormMinSeconds")#-#getSetting("timedFormMaxSeconds")# seconds.
							Also, I think the form data for this field was tampered with by the spammer [#getSetting("timedFormPoints")#]
						</li>
					</cfif>
				</cfif>
				
				<cfif StructKeyExists(arguments.TestResults,"hiddenFormField") AND NOT arguments.TestResults.hiddenFormField.Pass>
					<li>The hidden form field that is supposed to be blank contained data [#getSetting("hiddenFieldPoints")#]</li>
				</cfif>
				
				<cfif StructKeyExists(arguments.TestResults,"SpamStrings") AND NOT arguments.TestResults.SpamStrings.Pass>
					<li>One of the configured spam strings was found in the form submission [#getSetting("spamStringPoints")#]</li>
				</cfif>
				
				<cfif StructKeyExists(arguments.TestResults,"akismet")>
					<cfset akismetURL = "#getManager().getBlog().getUrl()#admin/generic.cfm?event=CFFormProtect-akismet&owner=cfformprotect&selected=CFFormProtect-settings" />
					<cfset akismetURL = akismetURL & "&user_ip=#urlEncodedFormat(cgi.remote_addr,'utf-8')#" />
					<cfset akismetURL = akismetURL & "&referrer=#urlEncodedFormat(cgi.http_referer,'utf-8')#" />
					<cfset akismetURL = akismetURL & "&comment_author=#urlEncodedFormat(arguments.akismetData.comment_author,'utf-8')#" />
					<cfset akismetURL = akismetURL & "&comment_author_email=#urlEncodedFormat(arguments.akismetData.comment_author_email,'utf-8')#" />
					<cfset akismetURL = akismetURL & "&comment_author_url=#urlEncodedFormat(arguments.akismetData.comment_author_url,'utf-8')#" />
					<cfset akismetURL = akismetURL & "&comment_content=#urlEncodedFormat(arguments.akismetData.comment_content,'utf-8')#" />
					
					<cfif NOT arguments.TestResults.akismet.Pass>
						<!--- The next few lines build the URL to submit a false positive notification to Akismet if this is not spam --->					
						<li>
							Akismet thinks this is spam.
							If it's not, please mark this as a false positive by <a href="#akismetURL#&type=ham">clicking here</a> [#getSetting("akismetPoints")#]
						</li>
					<cfelseif arguments.TestResults.akismet.ValidKey AND arguments.TestResults.akismet.Pass>
						<!--- The next few lines build the URL to submit a missed spam notification to Akismet --->
						<li>
							Akismet did not think this message was spam.
							If it was, please <a href="#akismetURL#&type=spam">notify Akismet</a> that it missed one.
						</li>
					</cfif>
				</cfif>
				
				<cfif StructKeyExists(arguments.TestResults,"TooManyUrls") AND NOT arguments.TestResults.tooManyUrls.Pass>
				       <li>There were too many URLs in the form contents [#getSetting("tooManyUrlsPoints")#]</li>
				</cfif>
				
				<cfif StructKeyExists(arguments.TestResults,"ProjHoneyPot") AND NOT arguments.TestResults.ProjHoneyPot.Pass>
					<li>The user's IP address has been flagged by Project Honey Pot [#getSetting("projectHoneyPotPoints")#]</li>
				</cfif>
				
			</ol>
			
			<p>
				Failure score: #totalPoints#<br />
				Your failure threshold: #getSetting("failureLimit")#
			</p>

			<p>
				IP address: #cgi.remote_addr#<br />
				User agent: #cgi.http_user_agent#<br />
				Previous page: #cgi.http_referer#
			</p>

			<p>
				Form variables:
			</p>
			<cfdump var="#form#">
			</cfoutput>
		</cfsavecontent>
		
		<cfif len(getSetting("emailFromAddress")) and len(getSetting("emailToAddress")) and len(getSetting("emailSubject"))>
			<!--- build email --->
			<cfset mail.from = getSetting("emailFromAddress") />
			<cfset mail.to = getSetting("emailToAddress") />
			<cfset mail.subject = getSetting("emailSubject") />
			<cfset mail.body = mailBody />
			<cfset mail.type = "HTML" />
	
			<!--- send email --->
			<cfset getManager().getMailer().sendEmail(argumentCollection=mail) />
		</cfif>
		
	</cffunction>

	<cffunction name="logFailure" acces="private" output="false" returntype="void">
		<cfargument name="TestResults" required="true" type="struct" />
		<cfargument name="FormStruct" required="true" type="struct" />
		<cfargument name="TotalPoints" required="true" type="numeric" />
		<cfargument name="akismetData" required="true" type="struct" />
		<cfscript>
		var akismetURL = "";
		var LogText = "Message marked as spam!   ";
		</cfscript>
	
		<cfif StructKeyExists(arguments.TestResults,"mouseMovement") AND NOT arguments.TestResults.mouseMovement.Pass>
			<cfset LogText = LogText & "--- No mouse movement was detected." />
		</cfif>
					
		<cfif StructKeyExists(arguments.TestResults,"usedKeyboard") AND NOT arguments.TestResults.usedKeyboard.Pass>
			<cfset LogText = LogText & "--- No keyboard activity was detected." />
		</cfif>
					
		<cfif StructKeyExists(arguments.TestResults,"timedFormSubmission") AND NOT arguments.TestResults.timedFormSubmission.Pass>
			<cfif StructKeyExists(arguments.FormStruct,("formfield1234567893"))>
				<cfset LogText = LogText & "--- The time it took to fill out the form did not fall within your configured threshold of #getSetting("timedFormMinSeconds")#-#getSetting("timedFormMaxSeconds")# seconds." />
				
			<cfelse>
				<cfset LogText = LogText & "The time it took to fill out the form did not fall within your configured threshold of #getSetting("timedFormMinSeconds")#-#getSetting("timedFormMaxSeconds")# seconds.  Also, I think the form data for this field was tampered with by the spammer." />
			</cfif>
		</cfif>
					
		<cfif StructKeyExists(arguments.TestResults,"hiddenFormField") AND NOT arguments.TestResults.hiddenFormField.Pass>
			<cfset LogText = LogText & "--- The hidden form field that is supposed to be blank contained data." />
		</cfif>
		
		<cfif StructKeyExists(arguments.TestResults,"SpamStrings") AND NOT arguments.TestResults.SpamStrings.Pass>
			<cfset LogText = LogText & "--- One of the configured spam strings was found in the form submission." />
		</cfif>

		<cfif StructKeyExists(arguments.TestResults,"akismet")>
			<cfset akismetURL = "#getManager().getBlog().getUrl()#admin/generic.cfm?event=CFFormProtect-akismet&owner=cfformprotect&selected=CFFormProtect-settings" />
			<cfset akismetURL = akismetURL & "&user_ip=#urlEncodedFormat(cgi.remote_addr,'utf-8')#" />
			<cfset akismetURL = akismetURL & "&referrer=#urlEncodedFormat(cgi.http_referer,'utf-8')#" />
			<cfset akismetURL = akismetURL & "&comment_author=#urlEncodedFormat(arguments.akismetData.comment_author_url,'utf-8')#" />
			<cfset akismetURL = akismetURL & "&comment_author_email=#urlEncodedFormat(arguments.akismetData.comment_author_email,'utf-8')#" />
			<cfset akismetURL = akismetURL & "&comment_author_url=#urlEncodedFormat(arguments.akismetData.comment_author_url,'utf-8')#" />
			<cfset akismetURL = akismetURL & "&comment_content=#urlEncodedFormat(arguments.akismetData.comment_content,'utf-8')#" />
			
			<cfif NOT arguments.TestResults.akismet.Pass>
				<!--- The next few lines build the URL to submit a false positive notification to Akismet if this is not spam --->					
				<cfset LogText = LogText & "--- Akismet thinks this is spam. If it's not, please mark this as a false positive by visiting: #akismetURL#&type=ham" />
			<cfelseif arguments.TestResults.akismet.ValidKey AND arguments.TestResults.akismet.Pass>
				<!--- The next few lines build the URL to submit a missed spam notification to Akismet --->
				<cfset LogText = LogText & "--- Akismet did not think this message was spam.  If it was, please visit: #akismetURL#&type=spam" />
			</cfif>
		</cfif>

					
		<cfif StructKeyExists(TestResults,"TooManyUrls") AND NOT arguments.TestResults.tooManyUrls.Pass>
		      <cfset LogText = LogText & "--- There were too many URLs in the form contents." />
		</cfif>
					
		<cfif StructKeyExists(TestResults,"ProjHoneyPot") AND NOT arguments.TestResults.ProjHoneyPot.Pass>
		      <cfset LogText = LogText & "--- The user's IP address has been flagged by Project Honey Pot." />
		</cfif>
					
		<cfset LogText = LogText & "--- Failure score: #totalPoints#.  Your failure threshold: #getSetting("failureLimit")#.  IP address: #cgi.remote_addr#. 	User agent: #cgi.http_user_agent#. 	Previous page: #cgi.http_referer#" />
	
		<cflog file="#variables.logfile#" text="#LogText#" />
	</cffunction>


</cfcomponent>