<!--- 
Project:     CFFormProtect plugin for Mango Blog <http://mangoblog.org>Author:      Seb Duggan <seb@sebduggan.com>Version:     1.0Build date:  2009-04-14 15:55:57Check for updated versions at <http://code.google.com/p/mangoplugins/>


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
	
	
<p><a href="http://cfformprotect.riaforge.org/" target="_blank">CFFormProtect</a> is a fully accessible, invisible-to-users form protection system to stop spam bots - and even human spammers.</p>

<p>You can customise how it works below: simply pick and choose which tests you'd like to enforce, specify how many "spam points" a failure in that test will add, and decide how many total points will deny the form submission.</p>

<form method="post" action="#cgi.script_name#">
	<!--- Akismet --->
	<fieldset>
		<legend>
			<label>
				<input type="checkbox" id="akismet" name="akismet" value="1"<cfif getSetting("akismet") eq 1> checked="checked"</cfif>/>
				Akismet spam detection
			</label>
		</legend>

		<p>
			Use the <a href="http://akismet.com" target="_blank">Akismet</a> spam detection service. You will need to sign up for a <a href="http://akismet.com/personal/" target="_blank">free API key</a> to use this.
		</p>
		
		<p>
			<label for="akismetPoints">Failure points</label>
			<span class="hint">How many points to award if this test fails</span>
			<span class="field"><input type="text" id="akismetPoints" name="akismetPoints" value="#getSetting("akismetPoints")#" size="2" class="{required:'##akismet:checked'} digits"/></span>
		</p>
		
		<p>
			<label for="akismetAPIKey">Akismet API key</label>
			<span class="hint">Enter your Akismet API key here</span>
			<span class="field"><input type="text" id="akismetAPIKey" name="akismetAPIKey" value="#HTMLEditFormat(getSetting("akismetAPIKey"))#" size="15" class="{required:'##akismet:checked'}"/></span>
		</p>
			
	</fieldset>
	
	
	<!--- Mouse Movement --->
	<fieldset>
		<legend>
			<label>
				<input type="checkbox" id="mouseMovement" name="mouseMovement" value="1"<cfif getSetting("mouseMovement") eq 1> checked="checked"</cfif>/>
				Check for mouse movement
			</label>
		</legend>

		<p>
			Uses JavaScript to detect whether the user moved the mouse while viewing the page.
		</p>
		
		<p>
			<label for="mouseMovementPoints">Failure points</label>
			<span class="hint">How many points to award if this test fails</span>
			<span class="field"><input type="text" id="mouseMovementPoints" name="mouseMovementPoints" value="#getSetting("mouseMovementPoints")#" size="2" class="{required:'##mouseMovement:checked'} digits"/></span>
		</p>
			
	</fieldset>
	
	
	<!--- Used Keyboard --->
	<fieldset>
		<legend>
			<label>
				<input type="checkbox" id="usedKeyboard" name="usedKeyboard" value="1"<cfif getSetting("usedKeyboard") eq 1> checked="checked"</cfif>/>
				Check for use of keyboard
			</label>
		</legend>

		<p>
			Uses JavaScript to detect whether the user used the keyboard while filling in the form.
		</p>
		
		<p>
			<label for="usedKeyboardPoints">Failure points</label>
			<span class="hint">How many points to award if this test fails</span>
			<span class="field"><input type="text" id="usedKeyboardPoints" name="usedKeyboardPoints" value="#getSetting("usedKeyboardPoints")#" size="2" class="{required:'##usedKeyboard:checked'} digits"/></span>
		</p>
			
	</fieldset>
	
	
	<!--- Timed Form Submission --->
	<fieldset>
		<legend>
			<label>
				<input type="checkbox" id="timedFormSubmission" name="timedFormSubmission" value="1"<cfif getSetting("timedFormSubmission") eq 1> checked="checked"</cfif>/>
				Timed form submission
			</label>
		</legend>

		<p>
			Determines how long it took to fill out the form.
		</p>
		
		<p>
			<label for="timedFormPoints">Failure points</label>
			<span class="hint">How many points to award if this test fails</span>
			<span class="field"><input type="text" id="timedFormPoints" name="timedFormPoints" value="#getSetting("timedFormPoints")#" size="2" class="{required:'##timedFormSubmission:checked'} digits"/></span>
		</p>
		
		<p>
			<label for="timedFormMinSeconds">Minimum time</label>
			<span class="hint">What is the minimum time to indicate a valid submission?</span>
			<span class="field"><input type="text" id="timedFormMinSeconds" name="timedFormMinSeconds" value="#getSetting("timedFormMinSeconds")#" size="5" class="{required:'##timedFormSubmission:checked'} digits"/> seconds</span>
		</p>
		
		<p>
			<label for="timedFormMaxSeconds">Maximum time</label>
			<span class="hint">What is the maximum time to indicate a valid submission?</span>
			<span class="field"><input type="text" id="timedFormMaxSeconds" name="timedFormMaxSeconds" value="#getSetting("timedFormMaxSeconds")#" size="5" class="{required:'##timedFormSubmission:checked'} digits"/> seconds</span>
		</p>
			
	</fieldset>
	
	
	<!--- Hidden Form Field --->
	<fieldset>
		<legend>
			<label>
				<input type="checkbox" id="hiddenFormField" name="hiddenFormField" value="1"<cfif getSetting("hiddenFormField") eq 1> checked="checked"</cfif>/>
				Hidden form field
			</label>
		</legend>

		<p>
			Adds a hidden form field to the form. A real user shouldn't fill this in!
		</p>
		
		<p>
			<label for="hiddenFieldPoints">Failure points</label>
			<span class="hint">How many points to award if this test fails</span>
			<span class="field"><input type="text" id="hiddenFieldPoints" name="hiddenFieldPoints" value="#getSetting("hiddenFieldPoints")#" size="2" class="{required:'##hiddenFormField:checked'} digits"/></span>
		</p>
			
	</fieldset>
	
	
	<!--- Too Many URLs --->
	<fieldset>
		<legend>
			<label>
				<input type="checkbox" id="tooManyUrls" name="tooManyUrls" value="1"<cfif getSetting("tooManyUrls") eq 1> checked="checked"</cfif>/>
				Too many URLs
			</label>
		</legend>

		<p>
			Checks if the user has entered multiple URLs in the submission.
		</p>
		
		<p>
			<label for="tooManyUrlsPoints">Failure points</label>
			<span class="hint">How many points to award if this test fails</span>
			<span class="field"><input type="text" id="tooManyUrlsPoints" name="tooManyUrlsPoints" value="#getSetting("tooManyUrlsPoints")#" size="2" class="{required:'##tooManyUrls:checked'} digits"/></span>
		</p>
		
		<p>
			<label for="tooManyUrlsMaxUrls">Maximum URLs</label>
			<span class="hint">How many URLs is too many?</span>
			<span class="field"><input type="text" id="tooManyUrlsMaxUrls" name="tooManyUrlsMaxUrls" value="#getSetting("tooManyUrlsMaxUrls")#" size="2" class="{required:'##tooManyUrls:checked'} digits"/></span>
		</p>
			
	</fieldset>
	
	
	<!--- Spam Strings --->
	<fieldset>
		<legend>
			<label>
				<input type="checkbox" id="teststrings" name="teststrings" value="1"<cfif getSetting("teststrings") eq 1> checked="checked"</cfif>/>
				Check against spam strings
			</label>
		</legend>

		<p>
			Checks the submission against a user-defined list of words which indicate a likelihood of spam.
		</p>
		
		<p>
			<label for="spamStringPoints">Failure points</label>
			<span class="hint">How many points to award if this test fails</span>
			<span class="field"><input type="text" id="spamStringPoints" name="spamStringPoints" value="#getSetting("spamStringPoints")#" size="2" class="{required:'##teststrings:checked'} digits"/></span>
		</p>
		
		<p>
			<label for="spamstrings">Spam strings</label>
			<span class="hint">Comma separated list of strings that would indicate likely spam</span>
			<span class="field"><textarea id="spamstrings" name="spamstrings" rows="7" cols="70">#HTMLEditFormat(getSetting("spamstrings"))#</textarea></span>
		</p>
			
	</fieldset>
	
	
	<!--- Project HoneyPot --->
	<fieldset>
		<legend>
			<label>
				<input type="checkbox" id="projectHoneyPot" name="projectHoneyPot" value="1"<cfif getSetting("projectHoneyPot") eq 1> checked="checked"</cfif>/>
				Project HoneyPot
			</label>
		</legend>

		<p>
			Sends the user's IP address to the <a href="http://www.projecthoneypot.org" target="_blank">Project HoneyPot</a> service to check if it's from a known spammer. You'll need to sign up to get an API key.
		</p>
		
		<p>
			<label for="projectHoneyPotPoints">Failure points</label>
			<span class="hint">How many points to award if this test fails</span>
			<span class="field"><input type="text" id="projectHoneyPotPoints" name="projectHoneyPotPoints" value="#getSetting("projectHoneyPotPoints")#" size="2" class="{required:'##projectHoneyPot:checked'} digits"/></span>
		</p>
		
		<p>
			<label for="projectHoneyPotAPIKey">Project HoneyPot API key</label>
			<span class="hint">Enter your Project HoneyPot API key here</span>
			<span class="field"><input type="text" id="projectHoneyPotAPIKey" name="projectHoneyPotAPIKey" value="#HTMLEditFormat(getSetting("projectHoneyPotAPIKey"))#" size="15" class="{required:'##projectHoneyPot:checked'}"/></span>
		</p>
			
	</fieldset>
	
	
	<!--- General settings --->
	<fieldset>
		<legend>General settings</legend>
		
		<!--- Failure Limit --->
		<p>
			<label for="failureLimit">Failure points limit</label>
			<span class="hint">How many total points will cause the submission to be flagged as spam?</span>
			<span class="field"><input type="text" id="failureLimit" name="failureLimit" value="#getSetting("failureLimit")#" size="2" class="required digits"/></span>
		</p>
		
		<!--- User confirmation --->
		<p>
			<label>User confirmation</label>
			<span class="hint">How should the user be notified when a post is flagged as spam? (Post is discarded whichever option you choose.)</span>
			<span class="field">
				<!--- <input type="radio" name="confirmationMethod" id="confirmationMethod_0" value="0" class="required"<cfif getSetting("confirmationMethod") eq 0> checked="checked"</cfif>/> <label for="confirmationMethod_0">Silent:</label> post will be discarded with no on-screen message<br />
				 ---><input type="radio" name="confirmationMethod" id="confirmationMethod_1" value="1"<cfif getSetting("confirmationMethod") eq 1> checked="checked"</cfif>/> <label for="confirmationMethod_1">Moderation:</label> user will be told post has been accepted but needs to be moderated<br />
				<input type="radio" name="confirmationMethod" id="confirmationMethod_2" value="2"<cfif getSetting("confirmationMethod") eq 2> checked="checked"</cfif>/> <label for="confirmationMethod_2">Error:</label> user will be informed that the message has been classed as spam
			</span>
		</p>
			
	</fieldset>
	
	
	<!--- Logging --->
	<fieldset>
		<legend>Logging &amp; notification</legend>

		<!--- Log Failed Tests --->
		<p>
			<input type="checkbox" id="logFailedTests" name="logFailedTests" value="1"<cfif getSetting("logFailedTests") eq 1> checked="checked"</cfif>/>
			<label for="logFailedTests">Log failed tests</label>
			<span class="hint">Record to ColdFusion log file <strong>#variables.logfile#</strong> when a submission fails the tests</span>
		</p>

		<!--- Email Failed Tests --->
		<p>
			<input type="checkbox" id="emailFailedTests" name="emailFailedTests" value="1"<cfif getSetting("emailFailedTests") eq 1> checked="checked"</cfif>/>
			<label for="emailFailedTests">Email failed tests</label>
			<span class="hint">Send an email when a submission fails the tests</span>
		</p>
		
		<div style="margin-left:4em;">
			<p>
				<label for="emailFromAddress">"From" address</label>
				<span class="hint">What address shoudl failure notifications be sent from?</span>
				<span class="field"><input type="text" id="emailFromAddress" name="emailFromAddress" value="#getSetting("emailFromAddress")#" size="40" class="{required:'##emailFailedTests:checked'} email"/></span>
			</p>
			<p>
				<label for="emailToAddress">"To" address</label>
				<span class="hint">Where do you want failure notifications sent to?</span>
				<span class="field"><input type="text" id="emailToAddress" name="emailToAddress" value="#getSetting("emailToAddress")#" size="40" class="{required:'##emailFailedTests:checked'} email"/></span>
			</p>
			<p>
				<label for="emailSubject">Email subject</label>
				<span class="hint">The subject line of any failure notification email</span>
				<span class="field"><input type="text" id="emailSubject" name="emailSubject" value="#getSetting("emailSubject")#" size="40" class="{required:'##emailFailedTests:checked'}"/></span>
			</p>
		</div>
	</fieldset>
	
	
	

	<div class="actions">
		<input type="submit" class="primaryAction" value="Submit"/>
		<input type="hidden" value="event" name="action" />
		<input type="hidden" value="CFFormProtect-settings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="cfformprotect" name="selected" />
	</div>

</form>


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