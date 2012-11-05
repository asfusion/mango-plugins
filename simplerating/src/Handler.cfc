<cfcomponent extends="org.mangoblog.plugins.BasePlugin">

	<cfset variables.package = "com/asfusion/mango/simplerating"/>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
						
			<cfset super.init(arguments.mainManager, arguments.preferences) />
			<cfset initSettings(showInPostFooter=1, showInExcerpt=0, showInPageFooter=1, includePrototype=1) />
		<cfreturn this/>
		
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
		<cfset var eventName = arguments.event.name />
		<cfset var local = structnew() />
		
		<cfset local.logger = getManager().getLogger() />
		
		<cfif eventName EQ "simplerating-saverating">
			<cfset local.logger.logMessage("debug","Handling simplerating-saverating",'plugin','Simple Rating') />
			
			<!--- make sure the type of event is simple so that we don't accept url requests --->
			<cfif arguments.event.type EQ "Event">
				<cfset saveRating(arguments.event.data.entry_id, arguments.event.data.rating, arguments.event.data.votes, arguments.event.data.type) />
				<cfset local.logger.logMessage("debug","New rating #arguments.event.data.rating# saved for entry: #arguments.event.data.entry_id#",'plugin','Simple Rating') />
			</cfif>
		</cfif>
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
		<cfset var eventName = arguments.event.name />
		<cfset var local = structnew() />
		<cfset var data = arguments.event.data />

		<!--- _____________________________________________ --->
		<cfif eventName EQ "beforeHtmlHeadEnd">
			<cfset local.path = getAssetPath() />
			<cfif getSetting('includePrototype')>
				<cfset arguments.event.outputData = arguments.event.outputData &  
								'<script type="text/javascript" src="#local.path#scripts/prototype.js"></script>' />
			
			</cfif>
			<cfset arguments.event.outputData = arguments.event.outputData &  
							'<script type="text/javascript" src="#local.path#scripts/stars.js"></script>
							<link rel="stylesheet" type="text/css" href="#local.path#styles/stars.css" />' />
		
		<!--- _____________________________________________ --->
		<cfelseif eventName EQ "beforePostContentEnd" AND getSetting('showInPostFooter')>
			<cfset arguments.event.outputData = arguments.event.outputData & showInFooter(arguments.event, 'post') />
		
		<!--- _____________________________________________ --->
		<cfelseif eventName EQ "beforePageContentEnd" AND getSetting('showInPageFooter')>
			<cfset arguments.event.outputData = arguments.event.outputData & showInFooter(arguments.event, 'page') />
		
		<!--- _____________________________________________ --->
		<cfelseif eventName EQ "simplerating-rate">
			<cfset local.cookieRatings = '' />
			<cfset data.newRating = data.rating />
			<cfset local.applyRating = false />
			
			<cfif structkeyexists(cookie,"rated_entries")>
				<cfset local.cookieRatings = cookie.rated_entries />
			</cfif>
			<cfif NOT listfindnocase(local.cookieRatings, data.entry_id)>
				<cfset local.applyRating = true />
				<cfcookie name="rated_entries" value="#listappend(local.cookieRatings, data.entry_id)#" expires="30">
			</cfif>
			
			<cfset data.newRating = rate(data.entry_id, data.rating, data.type, local.applyRating) />
			<cfset arguments.event.message.data = data.newRating />
		
		<!--- _____________________________________________ --->
		<cfelseif eventName EQ "simplerating-gettop">
			<cfset arguments.event.message.data = getTopPost(arguments.event.data.total, arguments.event.type) />
		
		<!--- _____________________________________________ --->
		<!--- admin nav event --->
		<cfelseif eventName EQ "settingsNav" AND getManager().isCurrentUserLoggedIn()>
			<cfset local.link = structnew() />
			<cfset local.link.owner = "simplerating">
			<cfset local.link.page = "settings" />
			<cfset local.link.title = "Rating" />
			<cfset local.link.eventName = "simplerating-settings" />
				
			<cfset arguments.event.addLink(local.link)>
		
		<!--- _____________________________________________ --->
		<cfelseif eventName EQ "simplerating-settings" AND getManager().isCurrentUserLoggedIn()>
			
			<cfif structkeyexists(data,"apply")>
				
				<cfif NOT structkeyexists(data,'showInPostFooter')>
					<cfset data.showInPostFooter = 0 />
				</cfif>
				<cfif NOT structkeyexists(data,'showInExcerpt')>
					<cfset data.showInExcerpt = 1 />
				</cfif>
				<cfif NOT structkeyexists(data,'showInPageFooter')>
					<cfset data.showInPageFooter = 0 />
				</cfif>
				<cfif NOT structkeyexists(data,'includePrototype')>
					<cfset data.includePrototype = 0 />
				</cfif>
				<cfset setSettings(showInPostFooter=data.showInPostFooter, showInExcerpt=data.showInExcerpt, 
									showInPageFooter=data.showInPageFooter, includePrototype=data.includePrototype)>
				<cfset persistSettings() />
				
				<cfset arguments.event.message.setstatus("success") />
				<cfset arguments.event.message.setType("settings") />
				<cfset arguments.event.message.settext("Settings updated")/>
			</cfif>
				
			<cfsavecontent variable="local.page">
				<cfinclude template="admin/settingsForm.cfm">
			</cfsavecontent>
					
				<!--- change message --->
				<cfset arguments.event.message.setTitle("Simple Rating settings") />
				<cfset arguments.event.message.setData(local.page) />
		
		<!--- _____________________________________________ --->	
		<cfelseif eventName EQ "beforeAdminPostFormDisplay" AND getManager().isCurrentUserLoggedIn()>
			<!--- remove rating form form --->
			<cfset local.panelField = structnew() />
			<cfset local.panelField["id"] = "rating" />
			<cfset local.panelField["inputType"] = "hidden">
			<cfset local.panelField["name"] = "Rating">
			<cfset arrayappend(arguments.event.data.request.panelData.customFields, local.panelField)>
			
			<cfset local.panelField = structnew() />
			<cfset local.panelField["id"] = "rating_votes" />
			<cfset local.panelField["inputType"] = "hidden">
			<cfset local.panelField["name"] = "Rating total votes">
			<cfset arrayappend(arguments.event.data.request.panelData.customFields, local.panelField) />
		
		<!--- _____________________________________________ --->	
		<!--- admin dashboard event --->
		<cfelseif eventName EQ "dashboardPod" AND getManager().isCurrentUserLoggedIn()>	
			<cfset showAdminPod(arguments.event) />
		<cfelseif eventName EQ "simplerating-adminreport" AND getManager().isCurrentUserLoggedIn()>	
			<cfset showAdminReport(arguments.event) />
		</cfif>
		
		<cfreturn arguments.event />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="rate" access="private" output="false">
		<cfargument name="id" type="string" required="true" />
		<cfargument name="rating" type="string" required="true" />
		<cfargument name="type" type="string" required="true" />
		<cfargument name="applyRating" type="boolean" required="false" default="true" />
		
		<cfset var local = structnew() />
		<cfset local.currentRating = 0 />
		<cfset local.currentRatingVotes = 0 />
		<cfset local.newRating = 0 />
		
		<cftry>
			<cfif arguments.type EQ "post">
				<cfset local.post = getManager().getPostsManager().getPostById(arguments.id) />
			<cfelse>
				<cfset local.post = getManager().getPagesManager().getPageById(arguments.id) />
			</cfif>
			<cfif local.post.customFieldExists('rating')>
				<cfset local.currentRating = local.post.getCustomField('rating').value />
			</cfif>
			<cfif local.post.customFieldExists('rating_votes')>
				<cfset local.currentRatingVotes = local.post.getCustomField('rating_votes').value />
			</cfif>
			
			<cfset local.newVotes = local.currentRatingVotes + 1 />
			<cfset local.newRating = decimalformat(((local.currentRating * local.currentRatingVotes) + arguments.rating) / local.newVotes) />
				
			<cfif arguments.applyRating>
				<cfset local.saveEventData = structnew() />
				<cfset local.saveEventData.votes = local.newVotes />
				<cfset local.saveEventData.rating = local.newRating />
				<cfset local.saveEventData.entry_id = arguments.id />
				<cfset local.saveEventData.type = arguments.type />
				<cfset local.pluginQueue = getManager().getPluginQueue() />
				<cfset local.pluginQueue.broadcastEvent(local.pluginQueue.createEvent("simplerating-saverating", local.saveEventData)) />
			</cfif>
			<cfcatch type="any">
				<cfset getManager().getLogger().logMessage("warning","There has been an error while attempting to rate: #cfcatch.Message#",'plugin','Simple Rating') />
			</cfcatch>
		</cftry>
		
		<cfreturn local.newRating />
		
	</cffunction>
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="saveRating" access="private" output="false">
		<cfargument name="id" type="string" required="true" />
		<cfargument name="rating" type="string" required="true" />
		<cfargument name="votes" type="string" required="true" />
		<cfargument name="type" type="string" required="true" />
		
		<cfset var local = structnew() />
		
		<cfset local.admin = getManager().getAdministrator() />
		<cfset local.customField = structnew() />
		<cfset local.customField.key = "rating" />
		<cfset local.customField.name = "Rating" />
		<cfset local.customField.value = arguments.rating  />
		
		<cfset local.customField2 = structnew() />
		<cfset local.customField2.key = "rating_votes" />
		<cfset local.customField2.name = "Rating total votes" />
		<cfset local.customField2.value = arguments.votes  />
		
		<cfif arguments.type EQ "post">
			<cfset local.admin.setPostCustomField(arguments.id, local.customField) />
			<cfset local.admin.setPostCustomField(arguments.id, local.customField2) />
		<cfelse>
			<cfset local.admin.setPageCustomField(arguments.id, local.customField) />
			<cfset local.admin.setPageCustomField(arguments.id, local.customField2) />
		</cfif>
	</cffunction>
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getTopPost" output="false" access="private" returntype="array">
		<cfargument name="count" type="numeric" default="10">
		<cfargument name="eventType" type="string" default="Event">
		
		<cfreturn getManager().getPostsManager().getPostsByCustomField('rating','',1,arguments.count,false, arguments.eventType NEQ "RemoteEvent",'CUSTOMFIELD-DESC') />

	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="showAdminPod" output="false" access="private" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
		<cfset var local = structnew() />
		<cfset local.top10 = getTopPost(10) />
		
		<cfsavecontent variable="local.pod">
			<cfoutput><ul>
				<cfloop from="1" to="#arraylen(local.top10)#" index="local.i">
					<li><a href="#local.top10[local.i].getPermalink()#" target="_blank">#local.top10[local.i].getTitle()#</a> #local.top10[local.i].getCustomField('rating').value#/5 (#local.top10[local.i].getCustomField('rating_votes').value# votes)</li>
				</cfloop></ul>
				<p><a href="generic.cfm?event=simplerating-adminreport&amp;owner=simplerating&amp;selected=simplerating">View top 100</a></p>
			</cfoutput>
		</cfsavecontent>			
					
		<cfset local.data = structnew() />
		<cfset local.data.title = "Top Rated Posts" />
		<cfset local.data.content = local.pod />
		<cfset arguments.event.addPod(local.data)>

	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="showAdminReport" output="false" access="private" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
		<cfset var local = structnew() />
		<cfset local.top10 = getTopPost(100) />
		
		<cfsavecontent variable="local.page"><table cellspacing="0">
			<tr><th>Title</th><th>Rating</th><th>Votes</th></tr>
			<cfoutput><ul>
				<cfloop from="1" to="#arraylen(local.top10)#" index="local.i">
					<tr><td><a href="#local.top10[local.i].getPermalink()#" target="_blank">#local.top10[local.i].getTitle()#</a></td>
					<td>#local.top10[local.i].getCustomField('rating').value#</td><td>#local.top10[local.i].getCustomField('rating_votes').value#</td></tr>
				</cfloop></ul>
			</cfoutput></table>
		</cfsavecontent>
		
		<cfset arguments.event.message.setTitle("Top 100 Posts") />
		<cfset arguments.event.message.setData(local.page) />

	</cffunction>
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="showInFooter" output="false" access="private" returntype="string">
		<cfargument name="event" type="any" required="true" />
		<cfargument name="type" type="string" required="true" />
		
		<cfset var local = structnew() />
		
		<cfset local.output = '' />
		<cfset local.add = true />
		
		<cfif structkeyexists(arguments.event.data, "attributes") AND 
			structkeyexists(arguments.event.data.attributes, "mode") AND 
			arguments.event.data.attributes.mode EQ "excerpt" AND NOT getSetting('showInExcerpt')>
				
				<!--- not ok to add in footer --->
				<cfset local.add = false />
		</cfif>
		
		<cfif local.add>
		
			<cfset local.basePath = getManager().getBlog().getBasePath() />
			<cfif arguments.type EQ "post">
				<cfset local.item = arguments.event.contextData.currentPost />
			<cfelseif arguments.type EQ "page">
				<cfset local.item = arguments.event.contextData.currentPage />
			</cfif>
			
			<cfset local.postId = local.item.getId() />
			<cfset local.currentRating = 0 />
			<cfset local.tempId = listlast(local.postId,"-") />
			<cfset local.cookieRatings = '' />
			<cfset local.locked = '' />
			
			<cfif local.item.customFieldExists('rating')>
				<cfset local.currentRating = local.item.getCustomField('rating').value />
			</cfif>
			
			<cfif isDefined("cookie.rated_entries")>
				<cfset local.cookieRatings = cookie.rated_entries />
			</cfif>
			
			<cfif listfindnocase(local.cookieRatings, local.postId)>
				<cfset local.locked = ",locked: true" />
			</cfif>
			
			<cfset local.output = '<div class="simplerating rating"><span class="value-title" title="#local.currentRating#" /> 
	<script type="text/javascript">
	  function ajaxRating#local.tempId#(newRating)
	  {
	  	s#local.tempId#.locked = true;
	  }
	  var s#local.tempId# = new Stars({
	    maxRating: 5,
	    actionURL: ''#local.basePath#output.cfm?event=simplerating-rate&entry_id=#local.postId#&type=#arguments.type#&rating='',
	    callback: ajaxRating#local.tempId#,
	    imagePath: ''#getAssetPath()#styles/'',
	    value: #local.currentRating#
	    #local.locked#
	  });
	</script></div>' />
	
	</cfif>
	
	<cfreturn local.output />

	</cffunction>

</cfcomponent>