<cfoutput>

<form method="post" action="#cgi.script_name#">
	<p>
		<label><input type="checkbox" name="moderate" value="1" <cfif variables.moderate>checked="checked"</cfif>> Comment moderation enabled
	</p>
	
	<div class="actions">
		<input type="submit" class="primaryAction" value="Submit"/>
		<input type="hidden" value="event" name="action" />
		<input type="hidden" value="commentModeration-showSettings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="commentModeration" name="selected" />
	</div>
</form>
</cfoutput>