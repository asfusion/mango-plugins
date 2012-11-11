<cfoutput>
<form method="post" action="#cgi.script_name#">
	<p>
		<label for="podTitle">Search engine unique ID:</label>
		<span class="field"><input type="text" id="engineId" name="engineId" value="#getSetting('engineId')#" size="45"/></span>
	</p>
	
	<div class="actions">
		<input type="submit" class="primaryAction" value="Submit"/>
		<input type="hidden" value="event" name="action" />
		<input type="hidden" value="googlesearch-showSettings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="googlesearch" name="selected" />
	</div>

</form>
</cfoutput>