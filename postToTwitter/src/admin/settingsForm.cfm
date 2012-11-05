<cfoutput>
	<form method="post" action="#cgi.script_name#">
		<p>
			<label for="username">Your Twitter username:</label>
			<span class="field"><input type="text" id="twitter_username" name="twitter_username" value="#getSetting('username')#"
					 size="" class="required"/></span>
		</p>
		<p>
			<label for="password">Your Twitter password:</label>
			<span class="field"><input type="password" id="twitter_password" name="twitter_password" value="#getSetting('password')#" size="" class="required"/></span>
		</p>
		 
		<div class="actions">
			<input type="submit" class="primaryAction" value="Submit"/>
			<input type="hidden" value="postToTwitter-settings" name="event" />
			<input type="hidden" value="true" name="apply" />
			<input type="hidden" value="postToTwitter" name="selected" />
		</div> 
	
	</form>

</cfoutput>