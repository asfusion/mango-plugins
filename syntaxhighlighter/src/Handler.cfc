<!---
LICENSE INFORMATION:

Copyright 2009, Tony Garcia
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not 
use this file except in compliance with the License. 

You may obtain a copy of the License at 

	http://www.apache.org/licenses/LICENSE-2.0 
	
Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
CONDITIONS OF ANY KIND, either express or implied. See the License for the 
specific language governing permissions and limitations under the License.

VERSION INFORMATION:

This file is part of SyntaxHighlighter Mango Blog Plugin (2.0).
--->
<cfcomponent displayname="Handler" extends="BasePlugin">
	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
			
		<cfset setManager(arguments.mainManager) />
		<cfset setPreferencesManager(arguments.preferences) />
		<cfset setPackage("com/objectivebias/mango/plugins/syntaxhighlighter") />
		<cfset initSettings() />
		<cfset variables.assetPath = getAssetPath() />
		<cfset variables.break = chr(13) & chr(10) />
		
		<cfreturn this/>
	</cffunction>

	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<!--- initialize settings  --->
		<cfset setSettings(
						   shLanguages="coldfusion,as3,css,jscript,sql,xml",
						   shTheme = "Default",
						   shLegacyMode="false"
						   ) />
		<cfset persistSettings() />
		<cfreturn "SyntaxHighlighter plugin activated. Would you like to <a href='generic_settings.cfm?event=showSHSettings&amp;owner=SyntaxHighlighter&amp;selected=showSHSettings'>configure it now</a>?" />
	</cffunction>
	
	<cffunction name="upgrade" hint="This is run when a plugin is upgraded" access="public" output="false" returntype="any">
		<cfargument name="fromVersion" type="string" />
		<cfset var local = structNew() />
		
		<!--- if upgrading from version 1, remove the syntaxhl tinyMCE plugin stuff, as that is no longer a dependency --->
		<cfif listFirst(arguments.fromVersion,".") eq 1>
			<cftry>
				<cfset local.TMCEpluginDir = expandpath(getManager().getBlog().getBasePath() & "admin/assets/editors/tinymce_3/jscripts/tiny_mce/plugins/syntaxhl") />
				<cfset local.layoutCFM = expandPath(getManager().getBlog().getBasePath() & "admin/editorSettings.cfm") />
				<!--- delete TinyMCE plugin --->
				<cfdirectory action="delete" directory="#local.TMCEpluginDir#" recurse="yes"/>
				<!--- reverse changes to TinyMCE config for syntaxhl plugin --->
				<cffile action="read" file="#local.layoutCFM#" variable="local.content" />
				<cfset local.content = ReplaceNoCase(local.content, "plugins : ""table,syntaxhl,", "plugins : ""table,", "one") />
				<cfset local.content = ReplaceNoCase(local.content, ",code,syntaxhl,help", ",code,help", "one") />
				<cffile action="write" file="#local.layoutCFM#" output="#local.content#" />
				<cfcatch>
					<cfreturn "SyntaxHightlighter Plugin has been upgraded from version 1, but was unable to remove TinyMCE config. See instructions for manual removal."/>
				</cfcatch>
			</cftry>	
		</cfif>
		<cfreturn "SyntaxHightlighter Plugin has been upgraded." />
	</cffunction>

	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		<cfreturn />
	</cffunction>

	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		<cfset var eventName = arguments.event.name />
		<cfset var eventData = arguments.event.data />
		<cfset var message = arguments.event.message />
		<cfset var local = structNew() />
		<cfset var js = ""/>
		<cfset var data = ""/>
		

		<!--- process page and post content events --->			
		<cfif eventName is "postGetExcerpt" or eventName is "pageGetExcerpt">
			<cfset data = arguments.event.accessObject />
			<cfset data.excerpt = highlightCode(data.excerpt) />
			
		<cfelseif eventName is "pageGetContent" or eventName is "postGetContent">
			<cfset data = arguments.event.accessObject />
			<cfset data.content = highlightCode(data.content) />
			
		<!--- include script and css calls in the head --->
		<cfelseif eventName is "beforeHtmlHeadEnd">
			<cfset data =  arguments.event.outputData />
			<cfset data = data & '#variables.break#<link rel="stylesheet" href="#variables.assetPath#styles/shCore.css" type="text/css" media="screen" />'/>
			<cfset data = data & '#variables.break#<link rel="stylesheet" href="#variables.assetPath#styles/shTheme#getSetting("shTheme")#.css" type="text/css" media="screen" />'/>
			<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shCore.js" type="text/javascript"></script>'/>
			<cfif getSetting("shLegacyMode") is "true">
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shLegacy.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"as3")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushAS3.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"bash")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushBash.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"coldfusion")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushColdFusion.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"cpp")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushCpp.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"cSharp")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushCSharp.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"css")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushCss.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"delphi")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushDelphi.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"diff")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushDiff.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"erlang")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushErlang.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"groovy")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushGroovy.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"java")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushJava.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"javafx")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushJavaFX.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"jscript")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushJScript.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"perl")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushPerl.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"php")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushPhp.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"plain")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushPlain.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"powershell")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushPowerShell.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"python")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushPython.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"ruby")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushRuby.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"scala")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushScala.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"sql")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushSql.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"vb")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushVb.js" type="text/javascript"></script>'/>
			</cfif>
			<cfif listFindNoCase(getSetting("shLanguages"),"xml")>
				<cfset data = data & '#variables.break#<script src="#variables.assetPath#scripts/shBrushXml.js" type="text/javascript"></script>'/>
			</cfif>
			<cfset data = data & '#variables.break#<script type="text/javascript">'/>
			<cfset data = data & "#variables.break#SyntaxHighlighter.config.clipboardSwf =  '#variables.assetPath#scripts/clipboard.swf';"/>
			<cfset data = data & "#variables.break#SyntaxHighlighter.all();"/>
			<cfif getSetting("shLegacyMode") is "true">
				<cfset data = data & "#variables.break#window.onload = function () {dp.SyntaxHighlighter.HighlightAll('code');}"/>
			</cfif>
			<cfset data = data & '#variables.break#</script>'/>
			<cfset arguments.event.outputData = data />
		
		<!--- admin nav event --->
		<cfelseif eventName is "settingsNav">
			<cfset local.link = structnew() />
			<cfset local.link.owner = "syntaxHighlighter">
			<cfset local.link.page = "settings" />
			<cfset local.link.title = "SyntaxHighlighter" />
			<cfset local.link.eventName = "showSHSettings" />
			<cfset arguments.event.addLink(local.link)>

		<!--- admin event --->
		<cfelseif eventName is "showSHSettings" and getManager().isCurrentUserLoggedIn()>		
			<cfif structkeyexists(eventData.externaldata,"apply")>
			<cfparam name="eventData.externalData.shLegacyMode" default="false" />
			
				<!--- save plugin settings --->
				<cfset setSettings(
									shLanguages = eventData.externaldata.shLanguages,
									shTheme = eventData.externaldata.shTheme,
									shLegacyMode = eventData.externaldata.shLegacyMode
									) />
				<cfset persistSettings() />
				
				<!--- this is a hack, just try to get the currently authenticated user --->
				<cftry>
					<cfif structkeyexists(session,"author")>
						<cfset getManager().getAdministrator().pluginUpdated(
								"SyntaxHighlighter", variables.id, session.author) />
					</cfif>
					<cfcatch type="any"></cfcatch>
				</cftry>
				<cfset eventData.message.setstatus("success") />
				<cfset eventData.message.setType("settings") />
				<cfset eventData.message.settext("Settings updated")/>
			</cfif>
				
			<cfsavecontent variable="local.page">
				<cfinclude template="admin/settingsForm.cfm">
			</cfsavecontent>
				
			<!--- change message --->
			<cfset eventData.message.setTitle("SyntaxHighlighter Plugin settings") />
			<cfset eventData.message.setData(local.page) />
		
		</cfif>
	
		<cfreturn arguments.event />
	</cffunction>
	
	<cffunction name="highlightCode" access="public" returntype="any" output="false">
		<cfargument name="contentBody" required="true" />
		<cfset var retStr = arguments.contentBody />
		<cfset var codeBody = "" />
		<cfset var highlightedCode = "" />
		<cfset var noMoreMatches = false />
		<cfset var startPosition = 1 />
		<cfset var language = "" />
		<cfset var startMatch = "" />
		<cfset var endMatch = "" />
		
		<cfloop condition="noMoreMatches is false">
			<cfset startMatch = reFindNoCase("\[code:([-_[:alnum:]]+)\]", arguments.contentBody, startPosition, true) />
			<cfif startMatch.len[1] eq 0>
				<cfset noMoreMatches = true />
			<cfelse>
				<!--- get the end [/code] tag position --->
				<cfset endMatch = findNoCase("[/code]",arguments.contentBody,startMatch.pos[1] + startMatch.len[1]) />
				<!--- get code body between (and including) [code/] tags --->
				<cfset codeBody = mid(arguments.contentBody,startMatch.pos[1],(endMatch - startMatch.pos[1]) + 7) />
				<!--- get the syntax language specified --->
				<cfset language = mid(arguments.contentBody, startMatch.pos[2], startMatch.len[2]) />
				<!--- replace <br /> and <p> tags with line breaks in the code block --->
				<cfset highlightedCode = replaceNoCase(codeBody,"<br />",variables.break,"all") />
				<cfset highlightedCode = replaceList(highlightedCode,"<p>,</p>,<p></p>,<p> </p>","#variables.break##variables.break#") />
				<!--- replace [code] tags with <pre> tags --->
				<cfset highlightedCode = rereplaceNoCase(highlightedCode,"\[code:([-_[:alnum:]]+)\]",'<pre class="brush: #language#">',"one") />
				<cfset highlightedCode = replaceNoCase(highlightedCode,"[/code]","</pre>","one") />
				<!--- put the processed code block back into the content body --->
				<cfset retStr = replaceNoCase(retStr,codeBody,highlightedCode,"all") />
				<cfset startPosition = startMatch.pos[1] + len(codeBody) />
			</cfif>
		</cfloop>
		<cfreturn retStr />
	</cffunction>

</cfcomponent>