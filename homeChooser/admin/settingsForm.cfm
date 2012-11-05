<cfoutput>
<form method="post" action="#cgi.script_name#">
	<p>
		<label for="homePage">Page to show as home</label>
		<span class="field"><select name="homePage" id="homePage">
			<option value="">-- Default --</option>
			<cfloop from="1" to="#arraylen(pages)#" index="i">
			<option value="#pages[i].getName()#" <cfif variables.indexPage EQ pages[i].getName()>selected="selected"</cfif>>#pages[i].getTitle()#</option>
			</cfloop>
		</select></span>
	</p>
	
	<p>
		<input type="checkbox" value="1" id="removeFromMenu" name="removeFromMenu" <cfif variables.removeFromMenu>checked="checked"</cfif>>
		<label for="removeFromMenu">Remove this page from menu</label>
		<span class="hint">If checked, this page will not be listed in the top-level menu.</span>
	</p>
	
	<p>
		<label for="blogPage">Page to show as blog</label>
		<span class="field"><select name="blogPage" id="blogPage">
			<option value="">-- Default --</option>
			<cfloop from="1" to="#arraylen(pages)#" index="i">
			<option value="#pages[i].getName()#" <cfif variables.blogPage EQ pages[i].getName()>selected="selected"</cfif>>#pages[i].getTitle()#</option>
			</cfloop>
		</select></span>
	</p>

	<div class="actions">
		<input type="submit" class="primaryAction" value="Submit"/>
		<input type="hidden" value="event" name="action" />
		<input type="hidden" value="homeChooser-showSettings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="homeChooser" name="selected" />
	</div>

</form>



</cfoutput>