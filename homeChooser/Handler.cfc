<cfcomponent>
	<cfset variables.package = "com/asfusion/mango/plugins/homePageChooser"/>
	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
			
			<cfset var blogid = arguments.mainManager.getBlog().getId() />
			<cfset var path = blogid & "/" & variables.package />
			<cfset variables.manager = arguments.mainManager />
			<cfset variables.preferencesManager = arguments.preferences />
			<cfset variables.indexPage = variables.preferencesManager.get(path,"indexPage","") />
			<cfset variables.blogPage = variables.preferencesManager.get(path,"blogPage","") />
			<cfset variables.indexPageTemplate = "" />
			<cfset variables.removeFromMenu = variables.preferencesManager.get(path,"removeFromMenu", 0) />
		<cfreturn this/>
	</cffunction>

	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		
		<cfreturn "Home Chooser activated. <br />You can now <a href='generic_settings.cfm?event=homeChooser-showSettings&amp;owner=homeChooser&amp;selected=homeChooser-showSettings'>Configure it</a>		
		" />
		
		<cfreturn />
	</cffunction>

	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<!--- TODO: Implement Method --->
		<cfreturn />
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

	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
		<cfreturn />
	</cffunction>

	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var data = arguments.event.data />
			<cfset var eventName = arguments.event.name />
			<cfset var template = "" />
			<cfset var page = "" />
			<cfset var link = "" />
			<cfset var pages = "" />
			<cfset var i = 0 />			
			<cfset var path = "" />
			
			<cfif eventName EQ "beforeIndexTemplate">
				
				<!--- check whether there is an index chosen --->
				<cfif len(variables.indexPage)>
					<!--- change the template --->
					<cfif NOT len(variables.indexPageTemplate)>
						<!--- get it once --->
						<cftry>
							<cfset page = variables.manager.getPagesManager().getPageByName(variables.indexPage) />
							<cfset variables.indexPageTemplate = page.getTemplate() />
							<cfif NOT len(variables.indexPageTemplate)>
								<cfset variables.indexPageTemplate = "page.cfm" />
							</cfif>
						<cfcatch type="PageNotFound">
							<cfset variables.indexPageTemplate = "index.cfm" />
						</cfcatch>
						</cftry>
					</cfif>
					
					<cfset data.indexTemplate = variables.indexPageTemplate />
					<cfset data.externalData.pageName = variables.indexPage />
										
				</cfif>
			
			<cfelseif eventName EQ "beforePageTemplate">
				
				<!--- check whether there is an index chosen and it matches this page --->
				<cfif len(variables.blogPage) AND data.externalData.pageName EQ variables.blogPage>
					<!--- change the template --->
					
					<cfset data.pageTemplate =  "index.cfm" />
											
				</cfif>
			
			<!--- removing index from menu --->
			<cfelseif eventName EQ "getPagesByParent">
				<cfif variables.removeFromMenu AND len(variables.indexPage)>
					<!--- remove it, only if it is a top page --->
					<cfif event.arguments.parent_page_id EQ "">
						<cfloop from="1" to="#arraylen(arguments.event.collection)#" index="i">					
							<cfif arguments.event.collection[i].getName() EQ variables.indexPage>
								<cfset arraydeleteat(arguments.event.collection, i) />
								<cfbreak />
							</cfif>
						</cfloop>
					</cfif>
				</cfif> 
			
			<!--- admin nav event --->
			<cfelseif arguments.event.getName() EQ "settingsNav">
				<cfset link = structnew() />
				<cfset link.owner = "homeChooser">
				<cfset link.page = "settings" />
				<cfset link.title = "Home Page Chooser" />
				<cfset link.eventName = "homeChooser-showSettings" />
				
				<cfset arguments.event.addLink(link)>
			
			<!--- admin event --->
			<cfelseif arguments.event.getName() EQ "homeChooser-showSettings" AND variables.manager.isCurrentUserLoggedIn()>
				<cfset data = arguments.event.getData() />
				<!--- get the list of pages to show as options --->
				<cfset pages = variables.manager.getPagesManager().getPages() />
				
				<cfif structkeyexists(data.externaldata,"apply")>
					<cfset path = variables.manager.getBlog().getId() & "/" & variables.package />
					<cfset variables.indexPage = data.externaldata.homePage />
					<cfset variables.preferencesManager.put(path,"indexPage",variables.indexPage) />
					<cfset variables.blogPage = data.externaldata.blogPage />
					<cfset variables.preferencesManager.put(path,"blogPage",variables.blogPage) />
					<cfif structkeyexists(data.externaldata, "removeFromMenu")>
						<cfset variables.removeFromMenu = data.externaldata.removeFromMenu />
					<cfelse>
						<cfset variables.removeFromMenu = 0 />
					</cfif>
					<cfset variables.preferencesManager.put(path,"removeFromMenu", variables.removeFromMenu) />
					
					<cfset variables.indexPageTemplate = "" />
					
					<cfset data.message.setstatus("success") />
					<cfset data.message.setType("settings") />
					<cfset data.message.settext("Settings updated")/>
				</cfif>
				
				<cfsavecontent variable="page">
					<cfinclude template="admin/settingsForm.cfm">
				</cfsavecontent>
					
					<!--- change message --->
					<cfset data.message.setTitle("Home Page Chooser settings") />
					<cfset data.message.setData(page) />
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>
	


</cfcomponent>