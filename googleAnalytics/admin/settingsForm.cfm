<cfoutput>

<form method="post" action="#cgi.script_name#">

	<p>
		<label for="googleAnalyticsCode">Your Google Analytics Account</label>
		<span class="hint">You must get this number from Google Analytics</span>
		<span class="field"><input type="text" id="googleAnalyticsCode" name="googleAnalyticsCode" value="#variables.googleCode#" size="20" class="required"/></span>
	</p>
	
	<div class="actions">
		<input type="submit" class="primaryAction" value="Submit"/>
		<input type="hidden" value="event" name="action" />
		<input type="hidden" value="showGoogleAnalyticsSettings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="googleAnalytics" name="selected" />
	</div>

</form>



</cfoutput>