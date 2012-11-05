<cfoutput>

<form method="post" action="#cgi.script_name#">
	<p>
		<label for="podTitle">Pod Title</label>
   		<span class="field"><input type="text" id="podTitle" name="podTitle" value="#variables.title#" size="20"/></span>
	</p>
	
	<p>
		<label for="tags">Tags</label>
		<span class="hint">Photos matching these tags (separated by commas). Either tags or username is required</span>
		<span class="field"><input type="text" id="tags" name="tags" value="#variables.tags#" size="20" class="{required:'##username:blank',messages:{required:'Either this field or <strong>username</strong> is required'}}"/></span>
	</p>
	
	<p>
   		<label for="username">Username</label>
		<span class="hint">Photos belonging to this username. Either tags or username is required</span>
		<span class="field"><input type="text" id="username" name="username" value="#variables.username#" size="20" class="{required:'##tags:blank',messages:{required:'Either this field or <strong>tags</strong> is required'}}"/></span>
	</p>
	
	<div class="actions">
		<input type="submit" class="primaryAction" value="Submit"/>
		<input type="hidden" value="event" name="action" />
		<input type="hidden" value="showFlickrWidgetSettings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="flickrWidget" name="selected" />
	</div>

</form>



</cfoutput>