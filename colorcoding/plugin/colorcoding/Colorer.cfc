<cfcomponent name="Colorer">

	<cfset variables.name = "Color Coding">
	<cfset variables.id = "com.blueinstant.colorcode">
	<cfset variables.package = "com/blueinstant/plugins/colorcode"/>
	<cfset variables.preferences = structnew() />
	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
			
			<cfset var pref = "" />
			<cfset var blogid = arguments.mainManager.getBlog().getId() />
			<cfset var path = blogid & "/" & variables.package />
			<cfset variables.preferencesManager = arguments.preferences />
			<cfset variables.manager = arguments.mainManager />
			
			<cfset variables.preferences["comment"] = structnew() />
			<cfset variables.preferences["entry"] = structnew() />
			<cfset variables.preferences["excerpt"] = structnew() />
			
			<cfset variables.preferences["comment"]["addParagraphFormat"] = 
					variables.preferencesManager.get(path & "/comment","addParagraphFormat",1) />

			<cfset variables.preferences["entry"]["addParagraphFormat"] = 
									variables.preferencesManager.get(path & "/entry","addParagraphFormat", 1) />
			
			<cfset variables.preferences["excerpt"]["addParagraphFormat"] = 
					variables.preferencesManager.get(path & "/excerpt","addParagraphFormat", 1) /> />
			
			<cfset variables.preferences["comment"]["addHtmlFormat"] = 
					variables.preferencesManager.get(path & "/comment","addHtmlFormat",1) />
					
			<cfset variables.preferences["entry"]["addHtmlFormat"] = 
					variables.preferencesManager.get(path & "/entry","addHtmlFormat", 1) />
			
			<cfset variables.preferences["excerpt"]["addHtmlFormat"] = 
					variables.preferencesManager.get(path & "/excerpt","addHtmlFormat", 1) />
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
		<cfset variables.package = replace(variables.id,".","/","all") />
	</cffunction>

	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<!--- TODO: Implement Method --->
		<cfreturn />
	</cffunction>

	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<cfset variables.preferencesManager.removeNode(variables.manager.getblog().getId() & "/com/blueinstant/plugins/colorcode") />
		<cfreturn />
	</cffunction>

	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		<!--- TODO: Implement Method --->
		<cfreturn />
	</cffunction>

	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
			<cfset var data =  "" />
			<cfset var eventName = arguments.event.name />
			<!--- use if instead of switch for performance --->
			
			<cfif eventName EQ "commentGetContent">
					<cfset data = arguments.event.accessObject />
					<cfset data.content = colorCode(data.content,"comment") />
					
			<cfelseif eventName EQ "postGetContent" OR eventName EQ "pageGetContent">
					<cfset data = arguments.event.accessObject />
					<cfset data.content = colorCode(data.content,"entry") />
					
			<cfelseif eventName EQ "postGetExcerpt" OR eventName EQ "pageGetExcerpt">
					<cfset data = arguments.event.accessObject />
					<cfset data.content = colorCode(data.content,"excerpt") />
					
			<cfelseif eventName EQ "beforeHtmlHeadEnd">
					<cfset data = arguments.event.outputData />
					<cfset data = data &  '<link rel="stylesheet" href="' & variables.manager.getBlog().getBasePath() 
							& 'assets/plugins/colorcoding/style.css" type="text/css" />' />
					<cfset arguments.event.outputData = data />
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>
	
	<!--- original code by Raymond Camden --->
	<cffunction name="colorCode" output="false" returntype="string">
	<cfargument name="bodyArg" required="true" type="string">
	<cfargument name="type" required="true" type="string">
	
	<cfset var counter = 0 />
	<cfset var codeblock = "" />
	<cfset var codeportion = "" />
	<cfset var result = "" />
	<cfset var newbody = "" />
	<cfset var body = arguments.bodyArg />
	
		<!--- find <code class="coldfusion"> tags --->
		<cfif findNoCase('<code class="coldfusion">',body) and findNoCase("</code>",body)>
			<cfset counter = findNoCase('<code class="coldfusion">',body)>
			<cfloop condition="counter gte 1">
				<cfset codeblock = reFindNoCase('(.*)(<code class="coldfusion">)(.*)(</code>)(.*)',body,1,1)>
				<cfif arrayLen(codeblock.len) is 6>
					<cfset codeportion = mid(body, codeblock.pos[4], codeblock.len[4])>
					<cfmodule template="coloredcode.cfm" data="#trim(codeportion)#" result="result">
					<cfset result = "«code»" & result &  "«/code»">
					
					<cfif variables.preferences[arguments.type]["addHtmlFormat"]>
						<cfset result = htmleditformat(result) />
					</cfif>
					
					<cfif variables.preferences[arguments.type]["addParagraphFormat"]>
						<cfset result = ParagraphFormat2(result) />
					</cfif>
										
					<cfset newbody = mid(body, 1, codeblock.len[2]) & result & mid(body,codeblock.pos[6],codeblock.len[6])>
					<cfset body = newbody>
					<cfset counter = findNoCase('<code class="coldfusion">',body,counter)>
				<cfelse>
					<!--- bad crap, maybe <code> and no ender, or maybe </code><code> --->
					<cfset counter = 0>
				</cfif>
			</cfloop>
		</cfif>
		
		<!--- find default <code> tags --->
		<cfif findNoCase('<code>',body) and findNoCase("</code>",body)>
			<cfset counter = findNoCase('<code>',body)>
			<cfloop condition="counter gte 1">
				<cfset codeblock = reFindNoCase('(.*)(<code>)(.*)(</code>)(.*)',body,1,1)>
				<cfif arrayLen(codeblock.len) is 6>
					<cfset codeportion = mid(body, codeblock.pos[4], codeblock.len[4])>
					<cfmodule template="coloredcode.cfm" data="#trim(codeportion)#" result="result">
					<cfset result = "«code»" & result &  "«/code»">
					
					<cfif variables.preferences[arguments.type]["addHtmlFormat"]>
						<cfset result = htmleditformat(result) />
					</cfif>
					
					<cfif variables.preferences[arguments.type]["addParagraphFormat"]>
						<cfset result =  ParagraphFormat2(result) />
					</cfif>					
					
					<cfset newbody = mid(body, 1, codeblock.len[2]) & result & mid(body,codeblock.pos[6],codeblock.len[6])>
					<cfset body = newbody>
					<cfset counter = findNoCase('<code>',body,counter)>
				<cfelse>
					<!--- bad crap, maybe <code> and no ender, or maybe </code><code> --->
					<cfset counter = 0>
				</cfif>
			</cfloop>
		</cfif>

		<cfset body = REReplaceNoCase(body, "«([^»]*)»", "<\1>", "ALL")/>

		<cfreturn body>
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