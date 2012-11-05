<!--- !Component: twitterCom --->
<!--- 
License: Free to use
copyright 2009 Quinn Michaels; All Rights Reserved

please feel free to use this component and the associated
function to interact with the Twitter API.  Please leave in this block
and send me a message if you like using the script.

if you have any question you can find me on twitter @quinnmichaels
also you can email me any questions quinn@thequinnshow.com

Quinn Michaels
http://www.thequinnshow.com
 --->

<cfcomponent>
	<cfinclude template="twitterFUNC.cfm">

<!--- ! function: veirfy(tu,tp) --->
<!--- 
verify credentials 
tu = twitter uname
tp = twitter password
returns userdata with the stat variable either set to true or false
--->
	<cffunction name="verify">
		<cfargument name="tu" type="string" required="yes" />
		<cfargument name="tp" type="string" required="yes" />

    	<cfhttp url="http://twitter.com/account/verify_credentials.json" method="get" username="#arguments.tu#" password="#arguments.tp#" />

		<cfset validate.stat = false>
		<cfset validate.statuscode = cfhttp.statuscode>
		
		<cfif cfhttp.StatusCode EQ "200 ok">
	    	<cfset validate = deserializejson(cfhttp.filecontent)>
			<cfset validate.stat = true>
		</cfif>
		
		<cfreturn validate>				
	</cffunction>
	
    
<!--- !function: extinfo(tu,tp,user/id) --->
<!--- 
get extended info for a user 
tu = twitter username
tp = twitter password
user = screen_name or id to return values for
values are returned as a structure
--->
	<cffunction name="extInfo">
		<cfargument name="tu" type="string" required="yes">
        <cfargument name="tp" type="string" required="yes">
		<cfargument name="user" required="no" type="string">

        <cfset gourl = "http://twitter.com/users/show.json?">
        <cfif isnumeric("arguments.user")>
        	<cfset gourl = gourl& "user_id=#arguments.user#">
		<cfelse>
        	<cfset gourl = gourl & "screen_name=#arguments.user#">
		</cfif>
		
        <cfhttp url="#gourl#" method="get" username="#arguments.tu#" password="#arguments.tp#" result="info" />

		<cfset config.stat = false>
        <cfset config.statuscode = info.statuscode>

        <cfif info.statuscode eq "200 ok">
			<cfset config = deserializejson(info.filecontent)>
			<cfset config.stat = true>
        </cfif>
		<cfreturn config>
    </cffunction>

<!--- ! function: messages(tu,tp,page,folder) --->
<!--- 
return direct messages for user 
tu = twitter username
tp = twitter password
page = page number to return
folder = inbox or sent
--->
	<cffunction name="messages">
		<cfargument name="tu" type="string" required="yes">
        <cfargument name="tp" type="string" required="yes">
    	<cfargument name="page" default="1" type="numeric">
        <cfargument name="folder" default="inbox">

        <cfparam name="msgURL" default="http://twitter.com/direct_messages.json?page=#arguments.page#">
        <cfif arguments.folder eq "sent">
			<cfset msgURL = "http://twitter.com/direct_messages/sent.json?page=#arguments.page#">
		</cfif>

		<cfset returnArr = arraynew(1)>

        <cfhttp url="#msgurl#" method="get" username="#arguments.tu#" password="#arguments.tp#" result="msgs" />

        <cfif msgs.statuscode eq "200 ok">
			<cfset returnArr = deserializejson(msgs.filecontent)>
		<cfelse>
			<cfset returnArr[1] = "fail">
			<cfset returnArr[2] = msgs.statuscode>
        </cfif>
		<cfreturn returnArr>
    </cffunction>

<!--- ! function newmessage(tup,tp,user,msg) --->
<!--- 
send direct message for user 
tu = twitter username
tp = twitter password
user = user to send message to
msg = message being sent
--->
	<cffunction name="newmessage">
    	<cfargument name="tu" required="yes" type="string">
        <cfargument name="tp" required="yes" type="string">
        <cfargument name="user" required="yes" type="numeric">
        <cfargument name="msg" required="yes" type="string">
        <cfhttp url="http://twitter.com/direct_messages/new.xml" username="#arguments.tu#" password="#arguments.tp#" result="msg" method="post">
            <cfhttpparam type="formfield" name="user" value="#arguments.user#">
            <cfhttpparam type="formfield" name="text" value="#arguments.msg#">
        </cfhttp>
        <cfreturn msg.statuscode>
    </cffunction>



<!--- ! function: relations(tu,tp,func,user/id,page) --->
<!--- 
return friends/followers 
tu = twitter username
tp = twitter password
func = friends/followers list to return
user/id = screen_name or id of relations to return
page = page number to return by default it returns all relationships
--->
	<cffunction name="relations">
		<cfargument name="tu" type="string" required="yes">
        <cfargument name="tp" type="string" required="yes">
        <cfargument name="func" type="string" required="yes">
        <cfargument name="user" type="string" required="yes">
        <cfargument name="page" type="numeric" required="no">
        
        <cfset defurl = "http://twitter.com/#arguments.func#/ids.json">

        <cfif isnumeric("arguments.user")>
			<cfset defurl = "#defurl#?user_id=#arguments.id#">
		<cfelse>
			<cfset defurl = "#defurl#?screen_name=#arguments.user#">
		</cfif>
        
        <cfif isdefined("arguments.page")>
			<cfset defurl = "#defurl#&page=#arguments.page#">
		</cfif>

        <cfset returnArr = arraynew(1)>
        <cfhttp url="#defurl#" username="#arguments.tu#" password="#arguments.tp#" method="get" result="output" />
        <cfif output.statuscode eq "200 ok">
        	<cfset returnArr = deserializejson(output.filecontent)>
        <cfelse>
        	<cfset returnArr[1] = "fail">
            <cfset returnArr[2] = output.statuscode>
        </cfif>
        <cfreturn returnArr>
    </cffunction>


<!--- ! function: friendship(tu,tp,friend) --->    
<!--- 
create friendship 
tu = twitter username
tp = twitter password
friend = id/screen_name to make friends with
--->
	<cffunction name="friendship">
    	<cfargument name="tu" type="string" required="yes">
        <cfargument name="tp" type="string" required="yes">
        <cfargument name="user" type="string" required="yes">
        <cfargument name="func" type="string" required="yes" />
        
        <cfswitch expression="#arguments.func#">
        	<cfcase value="create">
        		<cfset defUrl = "http://twitter.com/friendships/create/#arguments.user#.json?follow=true">
        	</cfcase>
        	<cfcase value="destroy">
        		<cfset defUrl = "http://twitter.com/friendships/destroy/#arguments.user#.json">
        	</cfcase>
        	<cfcase value="block">
        		<cfset defUrl = "http://twitter.com/blocks/create/#arguments.user#.json">
        	</cfcase>
        </cfswitch>
        <cfhttp url="#defurl#" username="#arguments.tu#" password="#arguments.tp#" method="post">
            <cfhttpparam name="follow" type="formfield" value="true">
        </cfhttp>
        <cfreturn cfhttp.statuscode>
    </cffunction>


<!--- ! function: getstatus(tu,tp,user/id,section,page,since,limit) --->
<!--- 
get status 
tu = twitter username
tp = twitter password
user = screen_name to return status for
id = userid to return status for
section = status/timeline/mentions
page = page number to return
since = results since this id
limit = limit return results
--->    
	<cffunction name="getstatus">
        <cfargument name="tu" type="string" required="yes">
        <cfargument name="tp" type="string" required="yes">
    	<cfargument name="user" type="string" required="yes">
    	<cfargument name="section" type="string" required="yes">
        <cfargument name="page" type="numeric" required="no">
        <cfargument name="since" type="numeric" required="no" />
        <cfargument name="limit" required="no" type="numeric">

		<cfparam name="usertype" default="screen_name">
		<cfset baseURL = "http://twitter.com/statuses/">

        <cfswitch expression="#arguments.section#">
        	<cfcase value="status">
				<cfif isnumeric("arguments.user")>
	            	<cfset geturl = "user_timeline.json?user_id=#arguments.id#">
				<cfelse>                
	            	<cfset geturl = "user_timeline.json?screen_name=#arguments.user#">
                </cfif>
            </cfcase>
        	<cfcase value="timeline">
            	<cfset geturl = "friends_timeline.json?temp=0">
            </cfcase>
            <cfcase value="mentions">
            	<cfset geturl = "mentions.json?temp=0">
            </cfcase>
		</cfswitch>
    	<cfif isdefined("arguments.limit")>
			<cfset geturl = geturl & "&count=#arguments.limit#">
		</cfif>

		<cfif isdefined("arguments.page")>
			<cfset geturl = geturl & "&page=#arguments.page#">
		</cfif>

    	<cfif isdefined("arguments.since")>
			<cfset geturl = geturl & "&since=#arguments.since#">
		</cfif>
	
		<cfset geturl = baseurl & geturl>
        <cfhttp url="#geturl#" method="get" username="#arguments.tu#" password="#arguments.tp#" result="statusmsg" />

        <cfif statusmsg.statuscode eq "200 ok">
			<cfset statusout = deserializejson(statusmsg.filecontent)>
		<cfelse>
			<cfset statusout = arraynew(1)>
			<cfset statusout[1] = "fail">
			<cfset statusout[2] = statusmsg.statuscode>
		</cfif>
    	<cfreturn statusout>
    </cffunction>

<!--- ! function: poststatus(tu,tp,message,replyid) --->
<!--- 
post status 
tu = twitter username
tp = twitter password
message = message to post
replyid = include if replying to a message
--->
	<cffunction name="postStatus" access="public" output="false" returntype="Any">
        <cfargument name="tu" type="string" required="yes">
        <cfargument name="tp" type="string" required="yes">
		<cfargument name="message" required="true" />
        <cfargument name="replyid" default="">
        
        <cfset message = CharsetEncode(CharsetDecode(arguments.message, "utf-8"), "utf-8")>
        
		<cfhttp url="http://twitter.com/statuses/update.xml" method="post" username="#arguments.tu#" password="#arguments.tp#">
			<cfhttpparam name="status" value="#arguments.message#" type="formfield" />
			<cfhttpparam name="in_reply_to_status_id" type="formfield" value="#arguments.replyid#" />
            <cfhttpparam name="source" type="formfield" value="A Better World Project" />
		</cfhttp>
		<cfreturn cfhttp.statuscode />
	</cffunction>

<!--- ! function: singlestatus(tu,tp,id) --->
<!--- 
return single status message by id 
tu = twitter username
tp = twitter password
id = statusid to return
--->
	<cffunction name="singlestatus">
		<cfargument name="tu" type="string" required="yes" />
		<cfargument name="tp" type="string" required="yes" />
		<cfargument name="id" type="string" required="yes" />
		<cfset defurl = "http://twitter.com/statuses/show/#arguments.id#.json">
        <cfhttp url="#defurl#" method="get" username="#arguments.tu#" password="#arguments.tp#" result="statusmsg" />

        <cfif statusmsg.statuscode eq "200 ok">
			<cfset statusout = deserializejson(statusmsg.filecontent)>
			<cfset statusout.stat = true>
		<cfelse>
			<cfset statusout.stat = false>
			<cfset statusout.statuscode = statusmsg.statuscode>
		</cfif>

		<cfreturn statusout>
	</cffunction>

<!--- ! function: search(ownerid, search, rpp) --->
<!--- 
search 
tu = twitter username
tp = twitter password
search = string to search for
ppm = number of results per page
--->
	<cffunction name="search">
    	<cfargument name="tu" type="string" required="yes">
        <cfargument name="tp" type="string" required="yes">
    	<cfargument name="search" type="string">
        <cfargument name="rpp" type="numeric" default="18">
        <cfset search = urlencodedformat(CharsetEncode(CharsetDecode(arguments.search, "utf-8"), "utf-8"))>
        <cfset rpp = arguments.rpp>
        <cfset returnArr = arraynew(1)>

        <cfhttp method="get" url="http://search.twitter.com/search.json?lang=en&q=#search#&rpp=#rpp#" result="result" username="#arguments.tu#" password="#arguments.tp#" />
		<cfset searchStruct = deserializejson(result.filecontent)>
		<cfset resultArr = searchStruct.results>
		<cfreturn resultArr>        
    </cffunction>

<!--- ! saved searches --->
	<cffunction name="savedsearch">
		<cfargument name="tu" type="string" required="yes" />
		<cfargument name="tp" type="string" required="yes" />
		<cfargument name="func" type="string" required="yes" />
		<cfargument name="search" type="string" required="yes" />

		<cfswitch expression="#arguments.func#">
			<cfcase value="list">
				<cfhttp method="GET" url="http://twitter.com/saved_searches.json" username="#arguments.tu#" password="#arguments.tp#" result="srch" />
			</cfcase>

			<cfcase value="show">
				<cfhttp method="GET" url="http://twitter.com/saved_searches/show/#arguments.search#.json" username="#arguments.tu#" password="#arguments.tp#" result="srch" />
			</cfcase>

			<cfcase value="create">
				<cfhttp method="POST" url="http://twitter.com/saved_searches/create.json" username="#arguments.tu#" password="#arguments.tp#" result="srch">
					<cfhttpparam type="formField" name="query" value="#arguments.search#" />
				</cfhttp>
			</cfcase>

			<cfcase value="destroy">
				<cfhttp method="POST" url="http://twitter.com/saved_searches/destroy/#arguments.search#.json" username="#arguments.tu#" password="#arguments.tp#" result="srch">
					<cfhttpparam type="formField" name="id" value="#arguments.search#" />
				</cfhttp>
			</cfcase>
		</cfswitch>
		
		<cfset config = arraynew(1)>
		<cfset config[1] = false>
		<cfset config[2] = srch.statuscode>

		<cfif srch.statuscode eq "200 ok">
			<cfset config = deserializejson(srch.filecontent)>
		</cfif>
		<cfreturn config>
	</cffunction>




</cfcomponent>

