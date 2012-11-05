This Mango plugin makes use of:

SyntaxHighlighter 2.1 code syntax highlighting script by Alex Gorbatchev
(http://alexgorbatchev.com/wiki/SyntaxHighlighter)

::::::::::::::::::::::INSTALLATION::::::::::::::::::::::::::::::::::::::::::::::::::::::

There are 2 ways install SyntaxHighlighter plugin for Mango:

1) The recommended way is to use Mango's auto-install feature. At the top of the "Plugins"
page in the admin, paste this URL where it says "URL of Plugin to Download":

  http://mangoblog-extensions.googlecode.com/files/syntaxhighlighter_plugin.zip
  
 Then click on "Download Plugin"

2) Or download the zip file from the URL, extract it, and upload the enlclosed SyntaxHighlighter 
folder (the one containing the "admin" and "assets" directories) into this directory in your
Mango installation:

[MangoBlog root]/components/plugins/user/


Then go to the Plugins admin page and click on "Activate" next to the plugin's name.

**************IMPORTANT NOTE FOR THOSE UPGRADING FROM VERSION 1 OF THE PLUGIN:*******************

It is highly recommended that you use method (1) above to upgrade your plugin. Unlike version 1, this
version does not use the TinyMCE SyntaxHighlighter plugin (syntaxhl) for Syntaxhighlighter integration.
So using this upgrade path will clean out the syntaxhl files and configuration. If, after upgrading the plugin,
you see this message:

"SyntaxHightlighter Plugin has been upgraded from version 1, but was unable to remove TinyMCE config. 
See instructions for manual removal."

1) Remove this directory:

[MangoBlog root]/admin/assets/editors/tinymce_3/jscripts/tiny_mce/plugins/syntaxhl
	

2) Edit this file: admin/editorSettings.cfm

Edit line 18

Change:
	plugins : "table,syntaxhl,save,...

To:
	plugins : "table,save,...
	
Edit line 23

Change:
	theme_advanced_buttons1 : "...,code,syntaxhl,help",
	
To:
	theme_advanced_buttons1 : "...,code,help",
	

ALSO, if upgrading from version 1, please see the note below about the "Legacy Mode" configuration setting.

::::::::::::::::::::::CONFIGURATION::::::::::::::::::::::::::::::::::::::::::::::::::::::

Once activated, there are several configuration options which are accessed by clicking on the "SyntaxHighlighter"
link at the top of the "Settings" page in the admin.

 * Select Languages for which to include syntax brushes
   Here, you select which languages you'd like to have highlighting for. It is recommended that you only
   select the languages that you are likely to highlight, as there will be an additional js file loaded for each
   language.
   
 * Choose a SyntaxHighlighter Theme
   Select one of 7 themes to change the look of your syntax highlighting
   
 * Compatibility Mode for Prior Version
   If you are upgrading from version 1 of the Mango Plugin (which uses SyntaxHighlighter version 1.5) and have a lot
   of prior posts using that version, enable this setting for backwards compatibility.

::::::::::::::::::::::USAGE:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

To use the plugin, simply paste your code into the WYSIWIG editor in between a pair of [code][/code] tags.

**************************** IMPORTANT ****************************

This plugin was made to work in WYSIWYG mode. You should see a the rich text editor toolbar at the top of the content editor. If you 
don't please enable WYSIWYG mode by clicking on the little pencil-and-paper icon at the top of the content (or excerpt) field, OR ELSE
THE PLUGIN WILL NOT WORK PROPERLY. This plugin was built so that authors wouldn't have to worry about switching back and forth between
WYSIWYG mode and HTML mode. Also, don't enter code blocks by clicking on the "HTML" button in the rich text editor toolbar. Enter them
directly into the content and/or excerpt fields. 

You designate which language to highlight by using an alias for the language in the opening code tag after a colon. For example, 
the alias for ColdFusion code highlighting is "cf":

[code:cf]
<cfset message = "This plugin is really cool!!!" />
<cfoutput>#message#</cfoutput>
[/code]

Here is a list of aliases for all code brushes included in the plugin (also, make sure the brushes you want to use are 
selected in the plugin configuration --see above):

as3  (ActionScript3)
bash (Bash)
cf   (ColdFusion)
cpp  (C++)
csharp   (C#)
css  (CSS)
delph  (Delphi)
diff  (Diff, Pascal)
erlang (Erlang)
groovy (Groovy)
java  (Java)
javafx  (JavaFX)
js   (JavaScript, JScript)
perl  (Perl)
php  (PHP)
ps  (PowerShell)
python (Python)
ruby  (Ruby)
scala  (Scala)
sql   (SQL)
text  (Text)
vb  (VB, VB.NET)
xml (XML, XHTML, HTML)




::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Version info:

1.0 (05August2009) Initial release
1.0.1 (06 August2009 )plugin now configures itself with a base list of syntax brushes on setup
1.0.2 (10 August2009) added ActionScript 3 brush
1.0.3 (7 October 2009) fixed a file path bug

2.0 (1 November 2009) Complete refactoring of plugin:
	* used updated plugin architecture introduced in Mango version 1.3
	* removed dependency on syntaxhl TinyMCE plugin for SyntaxHighlighter, code is now simply surrounded by [code][/code] tags in the editor
	* plugin now uses updated SyntaxHighlighter version 2.1
	* plugin is now configurable to use additional syntax brushes and code view themes included in SyntaxHighligher version 2.1
	* "legacy mode" for backwards compatibility with version 1 plugin, which used SyntaxHighlighter 1.5.1

2.0.1 (2 January 2010) plugin now highlights code in post excerpts (bug fix)