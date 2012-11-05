<cfcomponent>


	<cfset variables.name = "Comment Moderation">
	<cfset variables.id = "com.asfusion.mango.plugins.commentModeration">
	<cfset variables.package = "com/asfusion/mango/plugins/commentModeration"/>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		
			<cfset var blogid = arguments.mainManager.getBlog().getId() />
			<cfset var path = blogid & "/" & variables.package />
			<cfset variables.preferencesManager = arguments.preferences />
			<cfset variables.manager = arguments.mainManager />
			<cfset variables.moderate = variables.preferencesManager.get(path,"enabled","0") />
			
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
		<cfreturn "Comment moderation plugin activated. <br />
		You can now <a href='generic_settings.cfm?event=commentModeration-showSettings&amp;owner=commentModeration&amp;selected=commentModeration-showSettings'>Configure it</a>" />
	</cffunction>
	
	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<cfset var blogid = variables.manager.getBlog().getId() />
		
		<cfset variables.preferencesManager.removeNode(blogid & "/" & variables.package) />
		<cfreturn "Plugin de-activated" />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="remove" hint="This is run when a plugin is removed" access="public" output="false" returntype="any">
		<cfset var blogid = variables.manager.getBlog().getId() />
		
		<cfset variables.preferencesManager.removeNode(blogid & "/" & variables.package) />
		
		<cfreturn "Removed Plugin" />
	</cffunction>	

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />		
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var local = structnew() />
			<cfset var eventName = arguments.event.name />
			<cfset var outputData = "" />
			<cfset var page = "" />
			<cfset var comment = "" />
			
			<cfif eventName EQ "beforeCommentAdd">
				<cfset comment = arguments.event.getNewItem() />
				<cfif NOT len(comment.getAuthorId()) AND variables.moderate>
					<cfset comment.setApproved(false) />
				</cfif>
			
			<!--- admin nav event --->
			<cfelseif eventName EQ "settingsNav">
				<cfset local.link = structnew() />
				<cfset local.link.owner = "commentModeration">
				<cfset local.link.page = "settings" />
				<cfset local.link.title = "Comment Moderation" />
				<cfset local.link.eventName = "commentModeration-showSettings" />
				
				<cfset arguments.event.addLink(local.link)>
			
			<!--- admin dashboard event --->
			<cfelseif eventName EQ "dashboardPod" AND variables.manager.isCurrentUserLoggedIn()>		
				<!--- add a pod with comments to moderate --->
				<cfset local.commentManager = variables.manager.getCommentsManager() />
				<cfset local.comments = local.commentManager.search(approved=false,adminMode=true) />
				
				<cfsavecontent variable="outputData">
				<cfoutput>
					<p>#arraylen(local.comments)# comment(s) to moderate</p>
					<cfif arraylen(local.comments)>
					<p><a href="generic.cfm?event=commentModeration-moderate&amp;owner=commentModeration&amp;selected=commentModeration-moderate">Manage comments</p>
					</cfif>
				</cfoutput>
				</cfsavecontent>			
				
				<cfset local.data = structnew() />
				<cfset local.data.title = "New comments" />
				<cfset local.data.content = outputData />
				<cfset arguments.event.addPod(local.data)>

			
			<!--- ----------------------------------- --->
			<!--- admin event --->
			<cfelseif eventName EQ "commentModeration-moderate" AND variables.manager.isCurrentUserLoggedIn()>
				<!--- this is for the admin to be able to moderate comments --->
				<cfset local.commentManager = variables.manager.getCommentsManager() />
				<cfset local.adminUtil = variables.manager.getAdministrator() />
				<cfset local.data = arguments.event.getData() />
				
				<!--- user is submitting changes --->
				<cfif structkeyexists(local.data.externaldata,"apply")>
					<cfloop from="1" to="#local.data.externaldata.total#" index="local.i">
						<cfif structkeyexists(local.data.externaldata,"approve_" & local.i)>
							<cfif local.data.externaldata["approve_" & local.i] EQ "approve">
								<!--- update comment --->
								<cfset local.thisComment = 
										local.commentManager.getCommentById(local.data.externaldata["comment_id_" & local.i], true) />								

								<cfset local.adminUtil.editComment(local.thisComment.id,
											local.thisComment.content,
											local.thisComment.creatorName,
											local.thisComment.creatorEmail,
											local.thisComment.creatorUrl,
											true, structnew())>
							<cfelse>
								<!--- delete the comment --->
								<cfset local.adminUtil.deleteComment(local.data.externaldata["comment_id_" & local.i], structnew())>
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
			
				
				<cfset local.comments = local.commentManager.search(approved=false,adminMode=true) />
				
				
				<cfsavecontent variable="page">
					<cfinclude template="admin/moderateComments.cfm">
				</cfsavecontent>
					
				<!--- change message --->
				<cfset local.data.message.setTitle("Comments to moderate") />
				<cfset local.data.message.setData(page) />
			
			<!--- admin event, make sure user is logged in --->
			<cfelseif eventName EQ "commentModeration-showSettings" AND variables.manager.isCurrentUserLoggedIn()>
				<cfset local.data = arguments.event.getData() />				
				<cfif structkeyexists(local.data.externaldata,"apply")>
					<cfif structkeyexists(local.data.externaldata,"moderate")>
						<cfset variables.moderate = 1 />
					<cfelse>
						<cfset variables.moderate = 0 />
					</cfif>
					
					<cfset local.path = variables.manager.getBlog().getId() & "/" & variables.package />
					<cfset variables.preferencesManager.put(local.path,"enabled",variables.moderate) />
					
					<cfset local.data.message.setstatus("success") />
					<cfset local.data.message.setType("settings") />
					<cfset local.data.message.settext("Settings updated")/>
				</cfif>
				
				<cfsavecontent variable="page">
					<cfinclude template="admin/settingsForm.cfm">
				</cfsavecontent>
					
				<!--- change message --->
				<cfset local.data.message.setTitle("Comment Moderation settings") />
				<cfset local.data.message.setData(page) />
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>

<cfscript>
/**
 * Returns a XHTML compliant string wrapped with properly formatted paragraph tags.
 * 
 * @param string 	 String you want XHTML formatted. 
 * @param attributeString 	 Optional attributes to assign to all opening paragraph tags (i.e. style=""font-family: tahoma""). 
 * @return Returns a string. 
 * @author Jeff Howden (&#106;&#101;&#102;&#102;&#64;&#109;&#101;&#109;&#98;&#101;&#114;&#115;&#46;&#101;&#118;&#111;&#108;&#116;&#46;&#111;&#114;&#103;) 
 * @version 1.1, January 10, 2002 
 */
function XHTMLParagraphFormat(string)
{
  var attributeString = '';
  var returnValue = '';
  if(ArrayLen(arguments) GTE 2) attributeString = ' ' & arguments[2];
  if(Len(Trim(string)))
    returnValue = '<p' & attributeString & '>' & Replace(string, Chr(13) & Chr(10), '</p>' & Chr(13) & Chr(10) & '<p' & attributeString & '>', 'ALL') & '</p>';
  return returnValue;
}
</cfscript>

</cfcomponent>