<cfcomponent extends="BasePlugin">

	<cfset variables.name 		= "BlogCFC Redirecter">
	<cfset variables.id 		= "com.asfusion.mango.plugins.blogcfcRedirecter">
	<cfset variables.package 	= "com/asfusion/mango/plugins/blogcfcRedirecter"/>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
						
			<cfset setManager(arguments.mainManager) />
			<cfset setPreferencesManager(arguments.preferences) />
			
		<cfreturn this/>
		
	</cffunction>
	

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
		<cfreturn />

	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var data = arguments.event.data />
		<cfset var eventName = arguments.event.name />
		<cfset var local = structnew() />
		
		
		<cfif eventName EQ "beforeIndexTemplate">
			<cfset local.isPost = false />
			<!--- check for 4 raw parameters --->
			<cfif arraylen(data.externaldata.raw) GTE 4>
					<cfset local.postsManager = getManager().getPostsManager() />
					
					<cftry>
					<!--- take the last argument, which is the alias, and use it. --->
					<cfset local.post = local.postsManager.getPostByName(data.externaldata.raw[4]) />
					<cfset local.isPost = true />

					<cfcatch type="PostNotFound">
						<!--- try to find by custom field, which is more expensive --->
						<cfset local.posts = local.postsManager.getPostsByCustomField('blogcfc_alias',data.externaldata.raw[4]) />
						<cfif arraylen(local.posts)>
							<cfset local.post = local.posts[1] />
							<cfset local.isPost = true />
						</cfif>
					</cfcatch>
					</cftry>
					
					<cfif local.isPost>
						<cfset data.indexTemplate = "post.cfm" />
						<cfset data.externalData.postName = local.post.getName() />
					</cfif>
			
			<cfelseif structkeyexists(data.externaldata,"entry")>
					<cfset local.postsManager = getManager().getPostsManager() />
					
					<!--- maybe this is of the type ?mode=entry&entry=B40D10B3-3048-80A9-EFF1C7D1A99EBC27 
					this we can only do if they have used the new import wizard --->
					<cfset local.posts = local.postsManager.getPostsByCustomField('blogcfc_id',data.externaldata.entry) />
					
					<cfif arraylen(local.posts)>
						<cfset local.post = local.posts[1] />
						<cfset local.isPost = true />
					</cfif>
				
				<cfif local.isPost>
					<cfset data.indexTemplate = "post.cfm" />
					<cfset data.externalData.postName = local.post.getName() />
				</cfif>
				
			<!--- check for 1 raw parameters (category) --->
			<cfelseif arraylen(data.externaldata.raw) GTE 1>
				<cfset local.data = structnew() />
				<cfset local.data.name = data.externaldata.raw[1] />
				<!--- this is kind of a hack, I don't like to refer to request --->
				<cfset request.archive = getManager().getArchivesManager().getArchive("category",local.data)>
				<cfset data.indexTemplate = "archives.cfm" />
			</cfif>
			
		<cfelseif eventName EQ "beforeAdminPostFormDisplay" OR eventName EQ "beforeAdminPageFormDisplay">
			<cfif arguments.event.data.item.customFieldExists("blogcfc_id")>
				<cfset local.hiddenIds = structnew() />
				<cfset local.hiddenIds["id"] = "blogcfc_id" />
				<cfset local.hiddenIds["name"] = "BlogCFC Entry ID"/>
				<cfset local.hiddenIds["inputType"] = "hidden">
				<cfset local.hiddenIds["value"] = ""/>
				<cfset arrayappend(arguments.event.data.request.panelData.customFields,local.hiddenIds) />
			</cfif>
			
			<cfif arguments.event.data.item.customFieldExists("blogcfc_alias")>
				<cfset local.hiddenIds = structnew() />
				<cfset local.hiddenIds["id"] = "blogcfc_alias" />
				<cfset local.hiddenIds["name"] = "BlogCFC Alias"/>
				<cfset local.hiddenIds["inputType"] = "hidden">
				<cfset local.hiddenIds["value"] = ""/>
				<cfset arrayappend(arguments.event.data.request.panelData.customFields,local.hiddenIds) />
			</cfif>
		</cfif>
		
		<cfreturn arguments.event />
		
	</cffunction>


</cfcomponent>