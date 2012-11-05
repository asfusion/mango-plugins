<cfoutput>
<cfif arraylen(local.comments)>
	<form action="#cgi.script_name#" method="post">
	<cfloop from="1" to="#arraylen(local.comments)#" index="i">
		<div<cfif NOT local.comments[i].getApproved() AND local.comments[i].getRating() EQ -1> class="spam"<cfelseif NOT i mod 2> class="alternate"</cfif>><a name="#local.comments[i].getId()#"></a>
			<p>
				<strong>Name:</strong> #local.comments[i].getCreatorName()# |
				<strong>E-mail:</strong> <a href='#local.comments[i].getCreatorEmail()#'>#local.comments[i].getCreatorEmail()#</a> |
				<strong>Website:</strong> <a href="#local.comments[i].getCreatorUrl()#">#local.comments[i].getCreatorUrl()#</a>
			</p>
	
			#XHTMLParagraphFormat(htmleditformat(local.comments[i].getContent()))#

	        <p>
				<label><input type="radio" name="approve_#i#" value="approve"> Approve</label>
				<label><input type="radio" name="approve_#i#" value="delete"> Delete</label> |
				Posted #dateformat(local.comments[i].getCreatedOn(),"medium")# #timeformat(local.comments[i].getCreatedOn(),"short")# |
				<a href="comment_edit.cfm?id=#local.comments[i].getId()#">Edit</a>
				<input type="hidden" name="comment_id_#i#" value="#local.comments[i].getId()#" />
			</p>
		</div>
	</cfloop>
	
	<div class="actions">
		<input type="submit" class="primaryAction" value="Submit"/>
		<input type="hidden" value="event" name="action" />
		<input type="hidden" value="commentModeration-moderate" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="commentModeration" name="selected" />
		<input type="hidden" value="#arraylen(local.comments)#" name="total" />
	</div>
</form>
<cfelse>
	<p class="message">No comments to moderate</p>
</cfif></cfoutput>