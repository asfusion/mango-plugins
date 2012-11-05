<cfcomponent name="cocomment">


	<cfset variables.name = "CoComment">
	<cfset variables.id = "com.asfusion.mango.plugins.cocomment">

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
			<cfset variables.manager = arguments.mainManager />
		<cfreturn this/>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getId" access="public" output="false" returntype="any">
		<cfreturn variables.id />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="any" required="true" />
		<cfset variables.id = arguments.id />
		<cfreturn />
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

			<cfset var data = arguments.event.getData() />
			<cfset var blog = variables.manager.getBlog() />
			<cfset var js = "" />
			<cfset var outputData = "" />
			<cfset var context =  "" />
			<cfset var postUrl = "" />
			<cfset var postTitle = "" />
			<cfset var blogurl = "" />
			<cfswitch expression="#arguments.event.getName()#">
				<cfcase value="beforeCommentFormEnd"><!--- this is a template event, there should be a context and a request --->
					<cfset outputData = arguments.event.getOutputData() />
					<cfset context = arguments.event.getContextData() />
					<cfif structkeyexists(context,"currentPost")>
						<cfset postTitle = context.currentPost.getTitle() />
						<cfset postUrl = context.currentPost.getUrl() />
					</cfif>
					<cfset blogurl = blog.getUrl() />
					<cfsavecontent variable="js"><cfoutput>
					<script type="text/javascript">
						var blogTool = "Mango";
						var blogURL = "#blogurl#";
						var blogTitle = "#blog.getTitle()#";
						var postURL = "#blogurl##postUrl#";
						var postTitle  = "#replace(postTitle,'"',"'","all")#";
						var commentTextFieldName  = "comment_content";
						var commentButtonName = "submit_comment";
						var commentAuthorLoggedIn = false;
						var commentAuthorFieldName = "comment_name";
						var commentFormName = "comments_form";
						</script>
					<script id="cocomment-fetchlet" src="http://www.cocomment.com/js/enabler.js"></script></cfoutput>
					</cfsavecontent>
					<cfset arguments.event.setOutputData(outputData & js) />
				</cfcase>
			</cfswitch>
		
		<cfreturn arguments.event />
	</cffunction>


</cfcomponent>