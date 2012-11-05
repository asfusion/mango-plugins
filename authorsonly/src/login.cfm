<cfoutput>
<cfif len(errormsg)>
	<p class="error">#errormsg#</p>
</cfif>
<form action="#address#" method="post" id="login_form">
	<label for="username">Username:</label>
	<p>
	<input name="username" id="username" value="" size="22" type="text" class="text_input">
	</p>
	<p>
	<label for="password">Password:</label><br />
	<input name="password" id="password" value="" size="22" type="password" class="text_input">
	</p>
	<input name="login" class="form_submit" type="submit" id="submit" />
</form>
</cfoutput>