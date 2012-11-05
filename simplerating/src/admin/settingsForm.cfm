<cfoutput>
<form method="post" action="#cgi.script_name#">
	<p>
		<label for="showInPostFooter">
		<input type="checkbox" id="showInPostFooter" name="showInPostFooter" value="1" size="20" <cfif getSetting('showInPostFooter')>checked='checked'</cfif> />
		Add rating to posts
		</label>
	</p>
	<p>
		<label for="showInPageFooter"><input type="checkbox" id="showInPageFooter" name="showInPageFooter" value="1" size="20" <cfif getSetting('showInPageFooter')>checked='checked'</cfif> />
Add rating to pages
		</label>
	</p>
	<p>
		<label for="showInExcerpt">
		<input type="checkbox" id="showInExcerpt" name="showInExcerpt" value="0" size="20" <cfif NOT getSetting('showInExcerpt')>checked='checked'</cfif> />
Add rating only to full posts or pages
		</label>
		<span class="hint">This usually excludes rating from home page and archives</span>
	</p>
	<p>
		<label for="includePrototype">
		<input type="checkbox" id="includePrototype" name="includePrototype" value="1" size="20" <cfif getSetting('includePrototype')>checked='checked'</cfif> />
Include Prototype library</label>
<span class="hint">This plugin needs the Prototype JavaScript library. If you are including it in your theme or with another plugin, disable this setting</span>
	</p>
	<div class="actions">
		<input type="submit" class="primaryAction" value="Submit"/>
		<input type="hidden" value="simplerating-settings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="simplerating" name="selected" />
	</div>
</form>
</cfoutput>