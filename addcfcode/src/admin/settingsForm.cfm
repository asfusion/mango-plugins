<cfoutput>
<form method="post" action="#cgi.script_name#">
	<fieldset>
		<legend><input type="checkbox" name="useRam" value="1" <cfif getSetting("useRam") EQ 1>checked="true"</cfif>/>
		Use the Virtual File System to execute the code (Recommended for ColdFusion 9 or higher)</legend>
		<p>Virtual File System Mapping : 
			<input type="text" name="ramMapping" value="#getSetting("ramMapping")#" /><br/>
			(You need to setup the corresponding mapping to the virtual file system (ram://))
		</p>
	</fieldset>
	
	<div>
			<label for="shortCode">Shortcode to use:</label>
			<input type="text" name="shortCode" value="#getSetting('shortCode')#" class="required" />
	</div>
	<p class="actions">
	<input type="submit" class="primaryAction" value="Submit"/>
	<input type="hidden" value="event" name="action" />
	<input type="hidden" value="showAddCFCodeSettings" name="event" />
	<input type="hidden" value="true" name="apply" />
	<input type="hidden" value="showAddCFCodeSettings" name="selected" />
	</p>
</form>
</cfoutput>
