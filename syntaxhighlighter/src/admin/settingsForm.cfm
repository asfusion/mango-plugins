<cfoutput>
<form method="post" action="#cgi.script_name#">
  <span class="oneField">
    <span class="preField">Select Languages for which to include syntax brushes:</span><br />
	<input type="checkbox" name="shLanguages" value="as3" id="as3" <cfif listFind(getSetting("shLanguages"),"as3")> checked</cfif>> <label for="as3">ActionScript 3</label><br />
	<input type="checkbox" name="shLanguages" value="bash" id="bash" <cfif listFind(getSetting("shLanguages"),"bash")> checked</cfif>> <label for="as3">Bash</label><br />
	<input type="checkbox" name="shLanguages" value="coldfusion" id="coldFusion" <cfif listFind(getSetting("shLanguages"),"coldfusion")> checked</cfif>> <label for="coldFusion">ColdFusion</label><br />
	<input type="checkbox" name="shLanguages" value="cpp" id="cpp" <cfif listFind(getSetting("shLanguages"),"cpp")> checked</cfif>> <label for="cpp">C++</label><br />
	<input type="checkbox" name="shLanguages" value="cSharp" id="cSharp" <cfif listFind(getSetting("shLanguages"),"cSharp")> checked</cfif>> <label for="cSharp">C##</label><br />
	<input type="checkbox" name="shLanguages" value="css" id="css" <cfif listFind(getSetting("shLanguages"),"css")> checked</cfif>> <label for="css">CSS</label><br />
	<input type="checkbox" name="shLanguages" value="delphi" id="delphi" <cfif listFind(getSetting("shLanguages"),"delphi")> checked</cfif>> <label for="delphi">Delphi</label><br />
	<input type="checkbox" name="shLanguages" value="diff" id="diff" <cfif listFind(getSetting("shLanguages"),"diff")> checked</cfif>> <label for="diff">Diff</label><br />
	<input type="checkbox" name="shLanguages" value="erlang" id="erlang" <cfif listFind(getSetting("shLanguages"),"erlang")> checked</cfif>> <label for="erlang">Erlang</label><br />
	<input type="checkbox" name="shLanguages" value="groovy" id="groovy" <cfif listFind(getSetting("shLanguages"),"groovy")> checked</cfif>> <label for="groovy">Groovy</label><br />
	<input type="checkbox" name="shLanguages" value="java" id="java" <cfif listFind(getSetting("shLanguages"),"java")> checked</cfif>> <label for="java">Java</label><br />
	<input type="checkbox" name="shLanguages" value="javafx" id="javafx" <cfif listFind(getSetting("shLanguages"),"javafx")> checked</cfif>> <label for="javafx">JavaFX</label><br />
	<input type="checkbox" name="shLanguages" value="jscript" id="jscript" <cfif listFind(getSetting("shLanguages"),"jscript")> checked</cfif>> <label for="jscript">JavaScript/JScript</label><br />
	<input type="checkbox" name="shLanguages" value="perl" id="perl" <cfif listFind(getSetting("shLanguages"),"perl")> checked</cfif>> <label for="perl">Perl</label><br />
	<input type="checkbox" name="shLanguages" value="php" id="php" <cfif listFind(getSetting("shLanguages"),"php")> checked</cfif>> <label for="php">PHP</label><br />
	<input type="checkbox" name="shLanguages" value="plain" id="plain" <cfif listFind(getSetting("shLanguages"),"plain")> checked</cfif>> <label for="plain">Plain</label><br />
	<input type="checkbox" name="shLanguages" value="powershell" id="powershell" <cfif listFind(getSetting("shLanguages"),"powershell")> checked</cfif>> <label for="powershell">PowerShell</label><br />
	<input type="checkbox" name="shLanguages" value="python" id="python" <cfif listFind(getSetting("shLanguages"),"python")> checked</cfif>> <label for="python">Python</label><br />
	<input type="checkbox" name="shLanguages" value="ruby" id="ruby" <cfif listFind(getSetting("shLanguages"),"ruby")> checked</cfif>> <label for="ruby">Ruby</label><br />
	<input type="checkbox" name="shLanguages" value="scala" id="scala" <cfif listFind(getSetting("shLanguages"),"scala")> checked</cfif>> <label for="scala">Scala</label><br />
	<input type="checkbox" name="shLanguages" value="sql" id="sql" <cfif listFind(getSetting("shLanguages"),"sql")> checked</cfif>> <label for="sql">SQL</label><br />
	<input type="checkbox" name="shLanguages" value="vb" id="vb" <cfif listFind(getSetting("shLanguages"),"vb")> checked</cfif>> <label for="vb">VBScript</label><br />
	<input type="checkbox" name="shLanguages" value="xml" id="xml" <cfif listFind(getSetting("shLanguages"),"xml")> checked</cfif>> <label for="xml">XML/XHTML</label>
  </span><br /><br />
  
  <span class="oneField">
    <span class="preField">Choose SyntaxHighligher Theme:</span><br />
	<input type="radio" name="shTheme" value="Default" id="default" <cfif getSetting("shTheme") is "Default"> checked</cfif>> <label for="default">Default</label><br />
	<input type="radio" name="shTheme" value="Django" id="django" <cfif getSetting("shTheme") is "Django"> checked</cfif>> <label for="django">Django</label><br />
	<input type="radio" name="shTheme" value="Eclipse" id="eclipse" <cfif getSetting("shTheme") is "Eclipse"> checked</cfif>> <label for="eclipse">Eclipse</label><br />
	<input type="radio" name="shTheme" value="Emacs" id="emacs" <cfif getSetting("shTheme") is "Emacs"> checked</cfif>> <label for="emacs">Emacs</label><br />
	<input type="radio" name="shTheme" value="FadeToGrey" id="fadetogrey" <cfif getSetting("shTheme") is "FadeToGrey"> checked</cfif>> <label for="fadetogrey">Fade To Grey</label><br />
	<input type="radio" name="shTheme" value="Midnight" id="midnight" <cfif getSetting("shTheme") is "Midnight"> checked</cfif>> <label for="midnight">Midnight</label><br />
	<input type="radio" name="shTheme" value="RDark" id="rdark" <cfif getSetting("shTheme") is "RDark"> checked</cfif>> <label for="rdark">R Dark</label><br />
  </span><br /><br />
  <span class="preField">Compatibility Mode for SyntaxHighlighter 1.5</span><br />
  	<input type="checkbox" name="shLegacyMode" value="true" id="legacyMode" <cfif getSetting("shLegacyMode") is "true"> checked</cfif>> <label for="legacyMode">Enabled</label>
 
  <div class="actions">
    <input type="submit" class="primaryAction" value="Submit"/>
	<input type="hidden" value="event" name="action" />
	<input type="hidden" value="showSHSettings" name="event" />
	<input type="hidden" value="true" name="apply" />
	<input type="hidden" value="SyntaxHighlighter" name="selected" />
  </div>

</form>
</cfoutput>