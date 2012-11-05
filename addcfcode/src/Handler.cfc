<cfcomponent extends="org.mangoblog.plugins.BasePlugin">

	<cfset variables.package = "com/thecfguy/mango/plugins/addcfcode"/>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
						
			<cfset super.init(arguments.mainManager, arguments.preferences) />
			<cfset initSettings(useRam=0,ramMapping='/ram',shortCode='addcfcode') />
			
		<cfreturn this/>
		
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<cfset super.setup() />
		<cfreturn "addcfcode plugin activated. <br />Wrap your coldfusion code with [#getSetting('shortCode')#][/#getSetting('shortCode')#] to execute it." />
	</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var local = structnew() />

		<cfif arguments.event.name EQ "postGetContent" OR arguments.event.name EQ "pageGetContent">
			<cfset local.shortCode = getSetting('shortCode') />
			<cfset local.data = arguments.event.accessObject />
			
			<cfset local.matcharr = rematch("\[#local.shortCode#\][\s\S]*?\[\/#local.shortCode#\]",local.data.content) />
			
			<cfloop array="#local.matcharr#" index="local.matchcontent">
				<cfset local.matchcontent = replacenocase(local.matchcontent,"[#local.shortCode#]","") />
				<cfset local.matchcontent = replacenocase(local.matchcontent,"[/#local.shortCode#]","") />
				<cfset local.matchcontent = reReplaceNoCase(local.matchcontent,"<(.|\n|\r|/)*?>","","all")>
				<cfset local.matchcontent = replacenocase(local.matchcontent,"&lt;","<","All") />
				<cfset local.matchcontent = replacenocase(local.matchcontent,"&gt;",">","All") />
				<cfset local.matchcontent = ReReplaceNoCase(local.matchcontent,"[\x00\x01\x02\x03\x04\x05\x06\x07\x08\x0B\x0C\x0E\x0F\x10\x11\x12\x13\x14\x15\x1A\x1B\x1C\x1D\x1E\x1F\x16\x17\x18\x19\x7F\xA0]"," ","ALL")>
				<cfset local.filename = "#createuuid()#.cfm" />
				<cfif NOT getSetting("useRam")>
					<cfset local.path = GetDirectoryFromPath(GetCurrentTemplatePath()) />
					<cfset local.map = "" />
				<cfelse>
					<cfset local.path = "ram://" />
					<cfset local.map = getSetting('ramMapping') & "/" />
				</cfif>
				
				<cfsavecontent variable="local.executedcontent">
					<cftry>
						<cffile action="write" file="#local.path##local.filename#" output="#local.matchcontent#">
						<cfinclude template="#local.map##local.filename#">
						<cffile action="delete" file="#local.path##local.filename#">
						<cfcatch>
							<cfoutput>
								<span style="color:red;font-weight:bold">[addcfcode:error] Error occured while executing your code.</span>
							</cfoutput>
						</cfcatch>
					</cftry>
				</cfsavecontent>

				<cfset local.data.content = rereplacenocase(local.data.content,"\[#local.shortCode#\][\s\S]*?\[\/#local.shortCode#\]", local.executedcontent) />
			</cfloop>
		
		<cfelseif  arguments.event.name is "settingsNav">
			<cfset local.link = structnew() />
			<cfset local.link.owner = "thecfguy">
			<cfset local.link.page = "settings" />
			<cfset local.link.title = "AddCFCode" />
			<cfset local.link.eventName = "showAddCFCodeSettings" />
			<cfset arguments.event.addLink(local.link)>
			
		<cfelseif  arguments.event.name EQ "showAddCFCodeSettings">

			<cfset local.data = arguments.event.getData() />
			<cfif structkeyexists(local.data.externaldata,"apply")>

				<cfif structkeyexists(local.data.externalData,"useRam")>
					<cfset setSettings(	useRam = local.data.externaldata.useRam,ramMapping =local.data.externaldata.ramMapping, shortCode =  local.data.externaldata.shortCode) />
				<cfelse>
					<cfset setSettings(	useRam = 0,ramMapping =local.data.externaldata.ramMapping, shortCode =  local.data.externaldata.shortCode ) />
				</cfif>
				
				<cfset persistSettings() />
				<cfset local.data.message.setstatus("success") />
				<cfset local.data.message.setType("settings") />
				<cfset local.data.message.settext("settings updated successfully") />
			</cfif>
			<cfsavecontent variable="local.page">
				<cfinclude template="admin/settingsForm.cfm">
			</cfsavecontent>

			<!--- change message --->
			<cfset local.data.message.setTitle("AddCFCode Settings") />
			<cfset local.data.message.setData(local.page) />
		</cfif>
		
		<cfreturn arguments.event />
		
	</cffunction>

</cfcomponent>