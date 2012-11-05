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

######
This file includes code and modification of code from CFFormProtect
by Jake Munson:
http://cfformprotect.riaforge.org/

The original CFFormProtect code is covered by the Mozilla Public License:
http://www.mozilla.org/MPL/
######
--->

<cfif StructKeyExists(URL,"type")
	and ListFind("ham,spam", URL.type)
	and StructKeyExists(URL,"user_ip")
	and StructKeyExists(URL,"referrer")
	and StructKeyExists(URL,"comment_author")
	and StructKeyExists(URL,"comment_author_email")
	and StructKeyExists(URL,"comment_author_url")
	and StructKeyExists(URL,"comment_content")>
		
	<cftry>
		<!--- send form contents to Akismet API --->
		<cfhttp url="http://#getSetting("akismetAPIKey")#.rest.akismet.com/1.1/cdcdsubmit-#URL.type#" timeout="10" method="post" throwonerror="true">
			<cfhttpparam name="key" type="formfield" value="#getSetting("akismetAPIKey")#">
			<cfhttpparam name="blog" type="formfield" value="#getManager().getBlog().getUrl()#">
			<cfhttpparam name="user_ip" type="formfield" value="#urlDecode(URL.user_ip,'utf-8')#">
			<cfhttpparam name="user_agent" type="formfield" value="CFFormProtect for Mango Blog/1.0 | Akismet/1.11">
			<cfhttpparam name="referrer" type="formfield" value="#urlDecode(URL.referrer,'utf-8')#">
			<cfhttpparam name="comment_author" type="formfield" value="#urlDecode(URL.comment_author,'utf-8')#">
			<cfhttpparam name="comment_author_email" type="formfield" value="#urlDecode(URL.comment_author_email,'utf-8')#">
			<cfhttpparam name="comment_author_url" type="formfield" value="#urlDecode(URL.comment_author_url,'utf-8')#">
			<cfhttpparam name="comment_content" type="formfield" value="#urlDecode(URL.comment_content,'utf-8')#">
		</cfhttp>

		<p>Thank you for submitting this data to Akismet.</p>
		
		<cfdump var="#cfhttp#"/>
		
		<cfcatch type="any">
			<p>Unable to contact Akismet server.</p>
		</cfcatch>
	</cftry>
	
<cfelse>

	<p>Invalid URL.</p>
	
</cfif>