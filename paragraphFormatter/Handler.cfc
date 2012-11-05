<cfcomponent extends="BasePlugin">

	<cfset variables.name 		= "Paragraph Formatter">
	<cfset variables.id 		= "com.asfusion.mango.plugins.paragraphFormatter">
	<cfset variables.package 	= "com/asfusion/mango/plugins/paragraphFormatter"/>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		
			<cfset setManager(arguments.mainManager) />
			<cfset setPreferencesManager(arguments.preferences) />
			
			<cfset initSettings(paragraphComments=true, paragraphPosts=false, paragraphPages=false,
								htmlFormatComments=true, htmlFormatPosts=false, htmlFormatPages=false) />
			
		<cfreturn this/>
		
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
				
		<cfreturn />
		
	</cffunction>
	
	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<!--- TODO: Implement Method --->
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />	
		
		<cfreturn />

	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var eventName 	= arguments.event.getName() />
		<cfset var link 		= "" />
		<cfset var page 		= "" />
		<cfset var data 		= ""/>
		
		<cfif eventName EQ "commentGetContent">
			<cfset data = arguments.event.accessObject />
			<cfif variables.settings.htmlFormatComments>
				<cfset data.content = htmleditformat(data.content) />
			</cfif>
			<cfif variables.settings.paragraphComments>
				<cfset data.content = ParagraphFormat2(data.content) />
			</cfif>
		<cfelseif eventName EQ "postGetContent" OR eventName EQ "postGetExcerpt">
			<cfset data = arguments.event.accessObject />
			<cfif variables.settings.htmlFormatPosts>
				<cfset data.content = htmleditformat(data.content) />
			</cfif>
			<cfif variables.settings.paragraphPosts>
				<cfset data.content = ParagraphFormat2(data.content) />
			</cfif>
		<cfelseif eventName EQ "pageGetContent" OR eventName EQ "pageGetExcerpt">
			<cfset data = arguments.event.accessObject />
			<cfif variables.settings.htmlFormatPages>
				<cfset data.content = htmleditformat(data.content) />
			</cfif>
			<cfif variables.settings.paragraphPages>
				<cfset data.content = ParagraphFormat2(data.content) />
			</cfif>
		<cfelseif eventName EQ "settingsNav">

				<cfset link 			= structnew() />
				<cfset link.owner 		= "paragraphFormatter">
				<cfset link.page 		= "settings" />
				<cfset link.title 		= "Paragraph Format" />
				<cfset link.eventName 	= "paragraphFormatter-showSettings" />
				
				<cfset arguments.event.addLink(link)>
			
			
		<cfelseif eventName EQ "paragraphFormatter-showSettings">
			
				<cfset data = arguments.event.getData() />				
				
				<cfif structkeyexists(data.externaldata,"apply")>
					
					<cfset data.message.setstatus("success") />
					<cfset data.message.setType("settings") />
					<cfset data.message.settext("Account details updated")/>

				</cfif>
			
				<cfsavecontent variable="page">
					<cfinclude template="admin/settingsForm.cfm">
				</cfsavecontent>

				<!--- change message --->
				<cfset data.message.setTitle("Paragraph Formatter Settings") />
				<cfset data.message.setData(page) />
		</cfif>
		<cfreturn arguments.event />
		
	</cffunction>
	
<cfscript>
/**
 * An &quot;enhanced&quot; version of ParagraphFormat.
 * Added replacement of tab with nonbreaking space char, idea by Mark R Andrachek.
 * Rewrite and multiOS support by Nathan Dintenfas.
 * 
 * @param string 	 The string to format. (Required)
 * @return Returns a string. 
 * @author Ben Forta (ben@forta.com) 
 * @version 3, June 26, 2002 
 */
function ParagraphFormat2(str) {
	//first make Windows style into Unix style
	str = replace(str,chr(13)&chr(10),chr(10),"ALL");
	//now make Macintosh style into Unix style
	str = replace(str,chr(13),chr(10),"ALL");
	//now fix tabs
	str = replace(str,chr(9),"&nbsp;&nbsp;&nbsp;","ALL");
	//now return the text formatted in HTML
	return replace(str,chr(10),"<br />","ALL");
}

</cfscript>

</cfcomponent>