<cfoutput>
<form method="post" action="#cgi.script_name#">
	<div class="card card-body">
		<label for="googleAnalyticsCode" class="form-label">Your Google Analytics Account</label>
		<input type="text" class="form-control" id="googleAnalyticsCode" name="googleAnalyticsCode" value="#variables.googleCode#" size="20" class="required"/>
		<div class="form-text ">You must get this number from Google Analytics</div>
</div>
	<div class="actions">
		<input type="submit" class="btn btn-primary my-4" value="Submit"/>
		<input type="hidden" value="event" name="action" />
		<input type="hidden" value="showGoogleAnalyticsSettings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="googleAnalytics" name="selected" />
	</div>

</form>
</cfoutput>