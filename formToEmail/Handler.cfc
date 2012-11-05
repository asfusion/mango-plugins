<cfcomponent>
		
<!--- Some regex code based on Canvas wiki by Raymond Camden --->		
		
	<cfset variables.id = "com.asfusion.mango.plugins.formToEmail">
	<cfset variables.package = "com/asfusion/mango/plugins/formToEmail"/>
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />	
		
		<cfset variables.manager = arguments.mainManager />
		<cfset variables.preferences = arguments.preferences />
		<cfset variables.encryptionKey = GenerateSecretKey("BLOWFISH") />
		<cfreturn this/>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getId" access="public" output="false" returntype="any">
		<cfreturn variables.id />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="any" required="true" />
		<cfset variables.id = arguments.id />
		<cfset variables.package = replace(variables.id,".","/","all") />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="boolean">
		<cfset var mailTo = variables.preferences.get(variables.manager.getBlog().getId() & "/" & variables.package,"mailTo","") />
		<cfif NOT len(mailto)>
			<cfset variables.preferences.put(variables.manager.getBlog().getId() & "/" & variables.package,"mailTo","") />
		</cfif>	
		<cfreturn true />
	</cffunction>

	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">

		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
		<cfset var eventName = arguments.event.getName() />
		<cfset var mailer =  ""/>
		<cfset var mailTo =  ""/>
		<cfset var label = "" />
		<cfset var inpuType = "" />
		<cfset var formData = "">
		<cfset var formMatch = "">
		<cfset var match = "">
		<cfset var matches = "">
		<cfset var newString = "">
		<cfset var required = "">
		<cfset var tempData = "">
		<cfset var field = "">
		<cfset var mail = structnew()/>
		<cfset var validates = true />
		<cfset var data = ""/>
		<cfset var fields = "">
		<cfset var message = "">
		<cfset var thankYouMessage = "Thank you for your message">
		<cfset var pluginQueue = "" />
		<cfset var tempEvent = "" />
		<cfset var inputType = ""/>
		<cfset var x = 0 />
		
		<cfif eventName EQ "pageGetContent">
			<cfset data = arguments.event.accessObject />
			<cfset formMatch = refindnocase("\[formToEmail\](.*?)\[/formToEmail\]", data.content, 1,true)>
			
			<cfif formMatch.len[1] GT 0 AND arraylen(formMatch.len) GT 1>
				<cfset formData = mid(data.content, formMatch.pos[2],formMatch.len[2]) />
				
				<cfset matches = reFindAll("\[(.*?)\]", formData)>

				<cfif matches.pos[1] gt 0>
				<cfloop index="x" to="1" from="#arrayLen(matches.pos)#" step="-1">
					<cfset match = mid(formData, matches.pos[x], matches.len[x])>
					<cfset required = false>
					<cfset tempData = "">
					<cfset newString = "">
				
					<!--- remove [ ] --->
					<cfset match = mid(match, 2, len(match)-2)>
	
					<cfif listLen(match, "|") gte 2>
						<cfset label = listFirst(match, "|")>
						<cfset inputType = listGetat(match, 2, "|")>
						<cfif listlen(match, "|") GTE 3>
							<!--- required? --->
							<cfif listgetat(match, 3, "|") EQ "required">
								<cfset required = true>
							</cfif>
						</cfif>
						<cfif structkeyexists(request.externalData,"formToEmail_#x#")>
							<cfset tempData = request.externalData["formToEmail_#x#"]>
						</cfif>
						<cfsavecontent variable="newString"><cfoutput><label for="formToEmail_#x#">#label#</label>
							<cfif inputType EQ "text">
							<input type="text" name="formToEmail_#x#" id="formToEmail_#x#" class="formToEmail_text <cfif required>required</cfif>" size="50" value="#tempData#" />
							<cfelseif inputType EQ "textarea">
							<textarea name="formToEmail_#x#" id="formToEmail_#x#" class="formToEmail_textarea <cfif required>required</cfif>" rows="15" cols="50">#tempData#</textarea>
							</cfif>
							<input type="hidden" name="formToEmail_#x#_label" value="#ReReplaceNoCase(label, '<[^>]*>', '', 'ALL')#" />
							<cfif required><input type="hidden" name="formToEmail_#x#_isrequired" value="1" /></cfif>
						</cfoutput>
						</cfsavecontent>
					
					<cfelseif findnocase('subject=',match) AND listlen(match,"=") GT 1>
						<cfset newString = '<input type="hidden" name="formToEmail_subject" value="#trim(encrypt(listgetat(match,2,'='),variables.encryptionKey,"BLOWFISH","Hex"))#" />' />
					<cfelseif findnocase('from=',match) AND listlen(match,"=") GT 1>
						<cfset newString = '<input type="hidden" name="formToEmail_sender" value="#trim(encrypt(listgetat(match,2,'='),variables.encryptionKey,"BLOWFISH","Hex"))#" />' />
					<cfelseif findnocase('to=',match) AND listlen(match,"=") GT 1>
						<cfset newString = '<input type="hidden" name="formToEmail_recipient" value="#trim(encrypt(listgetat(match,2,'='),variables.encryptionKey,"BLOWFISH","Hex"))#" />' />
					<cfelseif findnocase('thankYouMessage=',match) AND listlen(match,"=") GT 1>
						<cfset newString = '<input type="hidden" name="formToEmail_thankYouMessage" value="#trim(encrypt(listgetat(match,2,'='),variables.encryptionKey,"BLOWFISH","Hex"))#" />' />
					</cfif>
					
					<cfif matches.pos[x] gt 1>
						<cfset formData = left(formData, matches.pos[x]-1) & newString & 
							mid(formData, matches.pos[x]+matches.len[x], len(formData))>
					<cfelse>
						<cfset formData = newString & 
							mid(formData, matches.pos[x]+matches.len[x], len(formData))>
					</cfif>
				</cfloop>
				
				</cfif>
				
				<!--- this is a bit of a hack :( --->
				<cfif structkeyexists(request,"message")>
					<cfif request.message.type EQ "formToEmail">
						<cfif request.message.status EQ "success">
							<cfset message = '<p class="message">#request.message.text#</p>'/>
						<cfelseif request.message.status EQ "error">
							<cfset message = '<p class="error">#request.message.text#</p>'/>
						</cfif>
					</cfif>
				</cfif>
				
				<cfset formData = '<a name="formToEmail"></a>#message#<form action="##formToEmail" method="post">#formData#<input type="hidden" value="event" name="action" />' />
				
				<!--- broadcast form end event --->
				<cfset pluginQueue = variables.manager.getPluginQueue() />
				<cfset tempEvent = pluginQueue.createEvent("beforeFormToEmailEnd",arguments.event.data,"Template") />
				<cfset tempEvent = pluginQueue.broadcastEvent(tempEvent) />
				
				<cfset formData = formData & '#tostring(tempEvent.getOutputData())#
						<input type="hidden" value="sendFormToEmail" name="event" />
						<input type="submit" name="send" id="formToEmailSubmitButton" value="Send" />
						</form>'>
				<cfset data.content = rereplaceNoCase(data.content,"\[formToEmail\](.*?)\[/formToEmail\]", formData)>
			</cfif>
	
		
		<!--- :::::::::::::::::::::::::::::::::::::::::::::::: --->
		<cfelseif eventName EQ "sendFormToEmail">
			<!--- get request data --->
			<cfset data = arguments.event.getData() />
			<cfset mail.body = "">	
			<cfset data.externalData.fieldnames = listsort(data.externalData.fieldnames,"text") />
			<cfset fields = arraynew(1) />
			
			<cfloop list="#data.externalData.fieldnames#" index="field">
				<cfif findnocase("formToEmail_",field) AND validates>
					<cfif field EQ "formToEmail_subject">
						<cfset mail.subject = decrypt(data.externalData[field],variables.encryptionKey,"BLOWFISH","Hex") />
					<cfelseif field EQ "formToEmail_sender">
						<cfset mail.from = decrypt(data.externalData[field],variables.encryptionKey,"BLOWFISH","Hex") />
					<cfelseif field EQ "formToEmail_recipient">
						<cfset mail.to = decrypt(data.externalData[field],variables.encryptionKey,"BLOWFISH","Hex") />
					<cfelseif field EQ "formToEmail_thankYouMessage">
						<cfset thankYouMessage = decrypt(data.externalData[field],variables.encryptionKey,"BLOWFISH","Hex") />
					<cfelseif listlen(field,"_") EQ 2 AND isnumeric(listgetAt(field,2,"_"))>
						<!--- check for required --->
						<cfif structkeyexists(data.externalData,"#field#_isrequired") AND 
								data.externalData['#field#_isrequired'] EQ 1 AND not len(trim(data.externalData[field]))>
							<cfset validates = false>
						<cfelse>
							<cfset arrayappend(fields,data.externalData[field]) />
							<cfset mail.body = mail.body & data.externalData['#field#_label'] & " #trim(data.externalData[field])##chr(13)##chr(10)#"/>
						</cfif>
					</cfif>
				</cfif>
			</cfloop>
			
			<cfif validates>
				<cfif NOT structkeyExists(mail,"subject")>
					<cfset mail.subject = "Message sent from your blog" />
				</cfif>
				<cfif NOT structkeyExists(mail,"to")>
					<cfset mail.from = variables.preferences.get(variables.manager.getBlog().getId() & "/" & variables.package,"mailTo","") />
				</cfif>
				
				<!--- replace all {} --->
				<cfloop from="1" to="#arraylen(fields)#" index="field">
					<cfset mail.body = replacenocase(mail.body,"{#field#}",fields[field]) />
					<cfset mail.subject = replacenocase(mail.subject,"{#field#}",fields[field]) />
					<cfset mail.from = replacenocase(mail.from,"{#field#}",fields[field]) />
					<cfset mail.to = replacenocase(mail.to,"{#field#}",fields[field]) />
				</cfloop>
				
				
				<!--- broadcast form submit event --->
				<cfset tempData = structnew() />
				<cfset tempData.originalEventData = arguments.event.data />
				<cfset tempData.mail = mail />
				<cfset pluginQueue = variables.manager.getPluginQueue() />
				<cfset tempEvent = pluginQueue.createEvent("beforeFormToEmailSend", tempData) />
				<cfset tempEvent = pluginQueue.broadcastEvent(tempEvent) />
				
				<cfif tempEvent.getContinueProcess()>
				
					<cfset mailer = variables.manager.getMailer()/>
					<cfset mailer.sendEmail(argumentCollection=mail) />
						
					<!--- change message --->
					<cfset data.message.setText(thankYouMessage) />
					<cfset data.message.setType("formToEmail") />
					<cfset data.message.setStatus("success") />
					
					<!--- remove fields --->
					<cfloop list="#data.externalData.fieldnames#" index="field">
						<cfif findnocase("formToEmail_",field)>
							<cfset data.externalData[field] = ''/>
						</cfif>
					</cfloop>
				<cfelse>
					<cfset data.message.setText(tempEvent.message.text) />
					<cfset data.message.setType("formToEmail") />
					<cfset data.message.setStatus(tempEvent.message.status) />
				</cfif>
			<cfelse><!--- does not validate --->
				<cfset data.message.setText("Please enter all required fields") />
				<cfset data.message.setType("formToEmail") />
				<cfset data.message.setStatus("error") />
			</cfif>
					
		</cfif>	
		
		<cfreturn arguments.event />
	</cffunction>


<!---
 Returns all the matches of a regular expression within a string.
 @param regex 	 Regular expression. (Required)
 @param text 	 String to search. (Required)
 @return Returns a structure. 
 @author Ben Forta (ben@forta.com) 
 @version 1, July 15, 2005 
--->
<cffunction name="reFindAll" output="false" returnType="struct" access="private">
   <cfargument name="regex" type="string" required="true">
   <cfargument name="text" type="string" required="true">


   <!--- Define local variables --->	
   <cfset var results=structNew()>
   <cfset var pos=1>
   <cfset var subex="">
   <cfset var done=false>

   <!--- Initialize results structure --->
   <cfset results.len=arraynew(1)>
   <cfset results.pos=arraynew(1)>

   <!--- Loop through text --->
   <cfloop condition="not done">
      <!--- Perform search --->
      <cfset subex=reFind(arguments.regex, arguments.text, pos, true)>
      <!--- Anything matched? --->
      <cfif subex.len[1] is 0>
         <!--- Nothing found, outta here --->
         <cfset done=true>
      <cfelse>
         <!--- Got one, add to arrays --->
         <cfset arrayappend(results.len, subex.len[1])>
         <cfset arrayappend(results.pos, subex.pos[1])>
         <!--- Reposition start point --->
         <cfset pos=subex.pos[1]+subex.len[1]>
      </cfif>
   </cfloop>

   <!--- If no matches, add 0 to both arrays --->
   <cfif arraylen(results.len) is 0>
      <cfset arrayappend(results.len, 0)>
      <cfset arrayappend(results.pos, 0)>
   </cfif>

   <!--- and return results --->
   <cfreturn results>
</cffunction>



</cfcomponent>