<cfoutput>
<form method="post" action="#cgi.script_name#">
	<p>
		<label for="podTitle">Pod Title</label>
		<span class="field"><input type="text" id="podTitle" name="podTitle" value="#getSetting('podTitle')#" size="20"/></span>
	</p>
	
	<p>
		<label for="searchBoxCode">Search Box Code</label>
		<span class="field"><textarea rows="10" cols="60" id="searchBoxCode" name="searchBoxCode">#getSetting("searchBoxCode")#</textarea></span>
	</p>
	
	<p>
		<label for="searchResultsCode">Search Results Code</label>
		<span class="field"><textarea rows="10" cols="60" id="searchResultsCode" name="searchResultsCode">#getSetting("searchResultsCode")#</textarea></span>
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