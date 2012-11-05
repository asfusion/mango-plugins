<cfoutput>

<form method="post" action="#cgi.script_name#">

	<p>
		<label for="apiKey">Your Akismet API Key:</label>
		<span class="hint">You must get this key from Akismet</span>
		<span class="field"><input type="text" id="apiKey" name="apiKey" value="#getSetting('apiKey')#" size="20" class="required" /></span>
	</p>
	
	<p>
		<label>Mode:</label>
		<span class="hint">How you want to handle possible spam comments</span>
		<span class="field">
			<input type="radio" name="mode" id="mode_moderate" value="moderate" <cfif getSetting('mode') EQ "moderate">checked="checked"</cfif>> <label for="mode_moderate">Moderation</label>: if comment is marked as spam, author will receive an email but comment will not be posted until author approval.<br />
			<input type="radio" name="mode" id="mode_reject" value="reject" <cfif getSetting('mode') EQ "reject">checked="checked"</cfif>> <label for="mode_reject">Reject</label>: if comment is marked as spam, it will simply be rejected.
		</span>
	</p>
	
	<div class="actions">
		<input type="submit" class="primaryAction" value="Submit"/>
		<input type="hidden" value="showAkismetSettings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="askimet" name="selected" />
	</div>
</form>
</cfoutput>