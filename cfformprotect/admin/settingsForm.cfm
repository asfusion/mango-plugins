<!--- 
Project:     CFFormProtect plugin for Mango Blog <http://mangoblog.org>
Author:      Seb Duggan <seb@sebduggan.com>
Version:     1.0
Build date:  2009-04-14 15:55:57

Check for updated versions at <http://code.google.com/p/mangoplugins/>



Copyright 2009 Seb Duggan

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->

<cfoutput>
<div  class="alert alert-info">
<p><a href="http://cfformprotect.riaforge.org/" target="_blank">CFFormProtect</a> is a fully accessible, invisible-to-users form protection system to stop spam bots - and even human spammers.</p>

<p>You can customise how it works below: simply pick and choose which tests you'd like to enforce, specify how many "spam points" a failure in that test will add, and decide how many total points will deny the form submission.</p>
</div>
	<div class="card card-body">
<form method="post" action="#cgi.script_name#">
	<!--- Akismet --->
	<fieldset class="mb-4">
		<legend>
			<label>
			<div class="form-check form-switch">
			<input class="form-check-input checkbox" type="checkbox" id="akismet" name="akismet" value="1"<cfif getSetting("akismet") eq 1> checked="checked"</cfif>/>
				Akismet spam detection
			</div>
			</label>
		</legend>
		<p>
			Use the <a href="http://akismet.com" target="_blank">Akismet</a> spam detection service. You will need to sign up for a <a href="http://akismet.com/personal/" target="_blank">free API key</a> to use this.
		</p>
		
		<div class="row mb-3">
			<label for="akismetPoints" class="col-sm-2 col-form-label">Failure points</label>
			<div class="col-sm-1">
				<input class="form-control" type="number" id="akismetPoints" name="akismetPoints" value="#getSetting("akismetPoints")#" size="2"  class="{required:'##akismet:checked'} digits"/>
			</div>
			<small class="form-text text-muted col">How many points to award if this test fails</small>
		</div>

		<div class="row">
			<label for="akismetAPIKey" class="col-sm-2 col-form-label">Akismet API key</label>
			<div class="col-sm-5">
			<input type="text" id="akismetAPIKey"  class="form-control"  name="akismetAPIKey" value="#HTMLEditFormat(getSetting("akismetAPIKey"))#" size="15" class="{required:'##akismet:checked'}"/>
			</div>
		</div>
	</fieldset>
	
	<!--- Mouse Movement --->
	<fieldset class="mb-4">
		<legend>
			<label>
			<div class="form-check form-switch">
				<input type="checkbox" class="form-check-input checkbox" id="mouseMovement" name="mouseMovement" value="1"<cfif getSetting("mouseMovement") eq 1> checked="checked"</cfif>/>
				Check for mouse movement
			</div>
			</label>
		</legend>
		<p>Uses JavaScript to detect whether the user moved the mouse while viewing the page.</p>

		<div class="row mb-3">
			<label for="mouseMovementPoints" class="col-sm-2 col-form-label">Failure points</label>
			<div class="col-sm-1">
				<input class="form-control" type="number" id="mouseMovementPoints" name="mouseMovementPoints" value="#getSetting("mouseMovementPoints")#" size="2" class="{required:'##mouseMovement:checked'} digits"/>
			</div>
			<small class="form-text text-muted col">How many points to award if this test fails</small>
		</div>
	</fieldset>
	
	
	<!--- Used Keyboard --->
	<fieldset class="mb-4">
		<legend>
			<label>
				<div class="form-check form-switch">
				<input type="checkbox" class="form-check-input checkbox" id="usedKeyboard" name="usedKeyboard" value="1"<cfif getSetting("usedKeyboard") eq 1> checked="checked"</cfif>/>
				Check for use of keyboard
			</div>
			</label>
		</legend>
		<p>Uses JavaScript to detect whether the user used the keyboard while filling in the form.</p>

		<div class="row mb-3">
			<label for="usedKeyboardPoints" class="col-sm-2 col-form-label">Failure points</label>
			<div class="col-sm-1">
				<input class="form-control" type="number" id="usedKeyboardPoints" name="usedKeyboardPoints" value="#getSetting("usedKeyboardPoints")#" size="2" class="{required:'##usedKeyboard:checked'} digits"/>
			</div>
			<small class="form-text text-muted col">How many points to award if this test fails</small>
		</div>
			
	</fieldset>
	
	
	<!--- Timed Form Submission --->
	<fieldset class="mb-4">
		<legend>
			<label>
			<div class="form-check form-switch">
				<input type="checkbox" class="form-check-input checkbox" id="timedFormSubmission" name="timedFormSubmission" value="1"<cfif getSetting("timedFormSubmission") eq 1> checked="checked"</cfif>/>
				Timed form submission
			</div>
			</label>
		</legend>
		<p>Determines how long it took to fill out the form</p>

	<div class="row mb-3">
			<label for="timedFormPoints" class="col-sm-2 col-form-label">Failure points</label>
			<div class="col-sm-1">
			<input class="form-control" type="number" id="timedFormPoints" name="timedFormPoints" value="#getSetting("timedFormPoints")#" size="2" class="{required:'##timedFormSubmission:checked'} digits"/>
			</div>
		<small class="form-text text-muted col">How many points to award if this test fails</small>
	</div>
	<div class="row mb-3">
			<label for="timedFormMinSeconds" class="col-sm-2 col-form-label">Minimum time</label>
		<div class="col-sm-1">
			<input class="form-control" type="number" id="timedFormMinSeconds" name="timedFormMinSeconds" value="#getSetting("timedFormMinSeconds")#" size="5" class="{required:'##timedFormSubmission:checked'} digits"/> seconds
		</div>
		<small class="form-text text-muted col">What is the minimum time to indicate a valid submission?</small>
	</div>

	<div class="row mb-3">
			<label for="timedFormMaxSeconds" class="col-sm-2 col-form-label">Maximum time</label>
			<div class="col-sm-1"><input class="form-control" type="number" id="timedFormMaxSeconds" name="timedFormMaxSeconds" value="#getSetting("timedFormMaxSeconds")#" size="5" class="{required:'##timedFormSubmission:checked'} digits"/> seconds</div>
		<small class="form-text text-muted col">What is the maximum time to indicate a valid submission?</small>
	</div>
			
	</fieldset>
	
	
	<!--- Hidden Form Field --->
	<fieldset class="mb-4">
		<legend>
			<label>
			<div class="form-check form-switch">
				<input type="checkbox" class="form-check-input checkbox" id="hiddenFormField" name="hiddenFormField" value="1"<cfif getSetting("hiddenFormField") eq 1> checked="checked"</cfif>/>
				Hidden form field
			</div>
			</label>
		</legend>

		<p>Adds a hidden form field to the form. A real user shouldn't fill this in!</p>

	<div class="row mb-3">
			<label for="hiddenFieldPoints" class="col-sm-2 col-form-label">Failure points</label>
	<div class="col-sm-1"><input class="form-control" type="number" id="hiddenFieldPoints" name="hiddenFieldPoints" value="#getSetting("hiddenFieldPoints")#" size="2" class="{required:'##hiddenFormField:checked'} digits"/></div>
		<small class="form-text text-muted col">How many points to award if this test fails</small>
	</div>
			
	</fieldset>
	
	
	<!--- Too Many URLs --->
	<fieldset class="mb-4">
		<legend>
			<label>
	<div class="form-check form-switch">
				<input type="checkbox" class="form-check-input checkbox"  id="tooManyUrls" name="tooManyUrls" value="1"<cfif getSetting("tooManyUrls") eq 1> checked="checked"</cfif>/>
				Too many URLs
	</div>	</label>
		</legend>

		<p>Checks if the user has entered multiple URLs in the submission</p>

	<div class="row mb-3">
			<label for="tooManyUrlsPoints" class="col-sm-2 col-form-label">Failure points</label>
	<div class="col-sm-1"><input class="form-control" type="number" id="tooManyUrlsPoints" name="tooManyUrlsPoints" value="#getSetting("tooManyUrlsPoints")#" size="2" class="{required:'##tooManyUrls:checked'} digits"/></div>
		<small class="form-text text-muted col">How many points to award if this test fails</small>
	</div>

	<div class="row mb-3">
			<label for="tooManyUrlsMaxUrls" class="col-sm-2 col-form-label">Maximum URLs</label>
	<div class="col-sm-1"><input class="form-control" type="number" id="tooManyUrlsMaxUrls" name="tooManyUrlsMaxUrls" value="#getSetting("tooManyUrlsMaxUrls")#" size="2" class="{required:'##tooManyUrls:checked'} digits"/></div>
		<small class="form-text text-muted col">How many URLs is too many?</small>
	</div>
			
	</fieldset>
	
	
	<!--- Spam Strings --->
	<fieldset class="mb-4">
		<legend>
			<label>
	<div class="form-check form-switch">
				<input type="checkbox"  class="form-check-input checkbox"  id="teststrings" name="teststrings" value="1"<cfif getSetting("teststrings") eq 1> checked="checked"</cfif>/>
				Check against spam strings
</div>
			</label>
		</legend>
		<p>Checks the submission against a user-defined list of words which indicate a likelihood of spam.</p>

<div class="row mb-3">
	<label for="spamStringPoints" class="col-sm-2 col-form-label">Failure points</label>
<div class="col-sm-1"><input class="form-control" type="number" id="spamStringPoints" name="spamStringPoints" value="#getSetting("spamStringPoints")#" size="2" class="{required:'##teststrings:checked'} digits"/></div>
	<small class="form-text text-muted col">How many points to award if this test fails</small>
</div>
		
	<div>
			<label for="spamstrings"  class="form-label">Spam words</label>
<textarea id="spamstrings" name="spamstrings" rows="3" class="form-control" >#HTMLEditFormat(getSetting("spamstrings"))#</textarea>
	<small class="form-text text-muted col">Comma separated list of strings that would indicate likely spam</small>
</div>
			
	</fieldset>
	
<fieldset class="mb-4">
		<legend>
			<label>
<div class="form-check form-switch">
				<input type="checkbox" id="linkSleeve" class="form-check-input checkbox"  name="linkSleeve" value="1"<cfif getSetting("linkSleeve") eq 1> checked="checked"</cfif>/>
				LinkSleeve
</div>
			</label>
		</legend>

		<p>Uses the <a href="http://www.linksleeve.org/" target="_blank">LinkSleeve service</a> to check for spam.</p>

<div class="row mb-3">
			<label for="tooManyUrlsPoints" class="col-sm-2 col-form-label">Failure points</label>
<div class="col-sm-1"><input class="form-control" type="number" id="linkSleevePoints" name="linkSleevePoints" value="#getSetting("linkSleevePoints")#" size="2" class="{required:'##linkSleeve:checked'} digits"/></div>
	<small class="form-text text-muted col">How many points to award if this test fails</small>
</div>
	</fieldset>

	<!--- Project HoneyPot --->
	<fieldset class="mb-4">
		<legend>
			<label>
			<div class="form-check form-switch">
				<input type="checkbox" class="form-check-input checkbox" id="projectHoneyPot" name="projectHoneyPot" value="1"<cfif getSetting("projectHoneyPot") eq 1> checked="checked"</cfif>/>
				Project HoneyPot
</div>
			</label>
		</legend>

		<p>Sends the user's IP address to the <a href="http://www.projecthoneypot.org" target="_blank">Project HoneyPot</a> service to check if it's from a known spammer. You'll need to sign up to get an API key.</p>

	<div class="row mb-3">
			<label for="projectHoneyPotPoints" class="col-sm-2 col-form-label">Failure points</label>
	<div class="col-sm-1"><input class="form-control" type="number" id="projectHoneyPotPoints" name="projectHoneyPotPoints" value="#getSetting("projectHoneyPotPoints")#" size="2" class="{required:'##projectHoneyPot:checked'} digits"/></div>
		<small class="form-text text-muted col">How many points to award if this test fails</small>
	</div>

	<div class="row mb-3">
			<label for="projectHoneyPotAPIKey" class="col-sm-2 col-form-label">Project HoneyPot API key</label>
	<div class="col-sm-3"><input class="form-control" type="text" id="projectHoneyPotAPIKey" name="projectHoneyPotAPIKey" value="#HTMLEditFormat(getSetting("projectHoneyPotAPIKey"))#" size="15" class="{required:'##projectHoneyPot:checked'}"/></div>
	</div>
			
	</fieldset>
	
	
	<!--- General settings --->
	<fieldset class="mb-4">
		<legend>General settings</legend>
		
		<!--- Failure Limit --->
		<div class="row mb-3">
			<label for="failureLimit" class="col-sm-2 col-form-label">Failure points limit</label>
			<div class="col-sm-1"><input class="form-control" type="number" id="failureLimit" name="failureLimit" value="#getSetting("failureLimit")#" size="2" class="required digits"/></div>
			<small class="form-text text-muted col">How many total points will cause the submission to be flagged as spam?</small>
		</div>
		
		<!--- User confirmation --->
		<div class="mb-3">
			<label>User confirmation</label>

		<div class="form-check">
			<input type="radio" class="form-check-input" name="confirmationMethod" id="confirmationMethod_1" value="1"<cfif getSetting("confirmationMethod") eq 1> checked="checked"</cfif>/>
			<label for="confirmationMethod_1" class="form-check-label">Moderation:</label> user will be told post has been accepted but needs to be moderated<br />
			<input type="radio" name="confirmationMethod" class="form-check-input" id="confirmationMethod_2" value="2"<cfif getSetting("confirmationMethod") eq 2> checked="checked"</cfif>/> <label for="confirmationMethod_2" class="form-check-label">Error:</label> user will be informed that the message has been classed as spam
		</div>

		<small class="form-text text-muted col">How should the user be notified when a post is flagged as spam? (Post is discarded whichever option you choose.)</small>
		</div>
			
	</fieldset>
	
	
	<!--- Logging --->
	<fieldset class="mb-4">
		<legend>Logging &amp; notification</legend>

		<!--- Log Failed Tests --->
		<div class="form-check">
			<input type="checkbox" class="form-check-input" id="logFailedTests" name="logFailedTests" value="1"<cfif getSetting("logFailedTests") eq 1> checked="checked"</cfif>/>
			<label for="logFailedTests">Log failed tests</label>
			<small class="form-text text-muted col">Record to ColdFusion log file <strong>#variables.logfile#</strong> when a submission fails the tests</small>
		</div>

		<!--- Email Failed Tests --->
	<div class="form-check">
			<input type="checkbox" class="form-check-input" id="emailFailedTests" name="emailFailedTests" value="1"<cfif getSetting("emailFailedTests") eq 1> checked="checked"</cfif>/>
			<label for="emailFailedTests">Email failed tests</label>
	<small class="form-text text-muted col">Send an email when a submission fails the tests</small>
		</div>
		
		<div class="ms-3">
			<div class="row mb-3">
				<label for="emailFromAddress" class="col-sm-2 col-form-label">"From" address</label>
<div class="col-sm-4"><input type="text" id="emailFromAddress" class="form-control" name="emailFromAddress" value="#getSetting("emailFromAddress")#" size="40" class="{required:'##emailFailedTests:checked'} email"/></div>
	<small class="form-text text-muted col">What address shoudl failure notifications be sent from?</small>
</div>
<div class="row mb-3">
				<label for="emailToAddress" class="col-sm-2 col-form-label">"To" address</label>
				<div class="col-sm-4"><input type="text" class="form-control"  id="emailToAddress" name="emailToAddress" value="#getSetting("emailToAddress")#" size="40" class="{required:'##emailFailedTests:checked'} email"/></div>
	<small class="form-text text-muted col">Where do you want failure notifications sent to?</small>
</div>
<div class="row mb-3">
				<label for="emailSubject" class="col-sm-2 col-form-label">Email subject</label>
				<div class="col-sm-4"><input type="text" class="form-control"  id="emailSubject" name="emailSubject" value="#getSetting("emailSubject")#" size="40" class="{required:'##emailFailedTests:checked'}"/></div>
	<small class="form-text text-muted col">The subject line of any failure notification email</small>
</div>
		</div>
	</fieldset>

	<div class="actions">
		<input type="submit" class="btn btn-primary" value="Submit"/>
		<input type="hidden" value="event" name="action" />
		<input type="hidden" value="CFFormProtect-settings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="cfformprotect" name="selected" />
	</div>

</form>
</div>

<script type="text/javascript">

$('legend label input').each(function(){
	var $chk = $(this);
	var $opts = $chk.parents('legend').siblings().not(':first');
	
	if (! $chk.is(':checked')) $opts.hide();
	
	$chk.change(function(){
		if ($chk.is(':checked')) {
			$opts.show();
		} else {
			$opts.hide();
		}
	});
});

</script>

</cfoutput>