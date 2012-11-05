<cfscript>
/*
	Strip HTML from a string
	example: #stripHTML(variable)#
*/
function stripHTML(htmltxt) {
	return REReplaceNoCase(htmltxt,"<[^>]*>","","ALL");
}

/*
	return a string cut at a charater length
	examp: #strLen(30, variable)#
	this will return the variable cut
	off to a length of 30 characters
*/
function strLen(sLen,sVal) {
	sVal = stripHTML(sVal);
	if (len(sLen) gt sVal) {
		rtn = "#left(sLen, sVal)#...";
	} else {
		rtn = sVal;
	}
	return rtn;
}

/*
	activates urls in a message
	example: #activateURL(variable)#
	where variable contains a valid
	url or mailto address.
*/
function activateURL(sActive) {
    var nextMatch = 1;
    var objMatch = "";
    var outstring = "";
    var thisURL = "";
    var thisLink = "";
    
    do {
        objMatch = REFindNoCase("(((https?:|ftp:|gopher:)\/\/)|(www\.|ftp\.))[-[:alnum:]\?%,\.\/&##!;@:=\+~_]+[A-Za-z0-9\/]", sActive, nextMatch, true);
        if (objMatch.pos[1] GT nextMatch OR objMatch.pos[1] EQ nextMatch) {
            outString = outString & Mid(String, nextMatch, objMatch.pos[1] - nextMatch);
        } else {
            outString = outString & Mid(String, nextMatch, Len(sActive));
        }
        nextMatch = objMatch.pos[1] + objMatch.len[1];
        if (ArrayLen(objMatch.pos) GT 1) {
            // If the preceding character is an @, assume this is an e-mail address
            // (for addresses like admin@ftp.cdrom.com)
            if (Compare(Mid(String, Max(objMatch.pos[1] , 1), 1), "@") NEQ 0) {
                thisURL = Mid(String, objMatch.pos[1], objMatch.len[1]);
                thisLink = "<A target=twitter HREF=""";
                switch (LCase(Mid(String, objMatch.pos[2], objMatch.len[2]))) {
                    case "www.": {
                        thisLink = thisLink & "http://";
                        break;
                    }
                    case "ftp.": {
                        thisLink = thisLink & "ftp://";
                        break;
                    }
                }
                thisLink = thisLink & thisURL & """";
                thisLink = thisLink & ">" & thisURL & "</A>";
                outString = outString & thisLink;
                // String = Replace(String, thisURL, thisLink);
                // nextMatch = nextMatch + Len(thisURL);
            } else {
                outString = outString & Mid(String, objMatch.pos[1], objMatch.len[1]);
            }
        }
    } while (nextMatch GT 0);
        
    // Now turn e-mail addresses into mailto: links.
    outString = REReplace(outString, "([[:alnum:]_\.\-]+@([[:alnum:]_\.\-]+\.)+[[:alpha:]]{2,4})", "<A HREF=""mailto:\1"">\1</A>", "ALL");
        
    return outString;
}


/*
	parse returned twitter dates for input into database
	example: #twitterDate(dateVariable, offsetVariable)#
	
	date: the date returned from twitter to parse
	offset: the number of seconds to offset for display.
*/
function twitterDate(date,offset) {
	var retDate = listtoarray(date, " ");
	var thisDay = retDate[1];
	var thisMonth = retDate[2];
	var thisDate = retDate[3];
	var thisTime = timeformat(retDate[4], "h:mm tt");
	var thisYear = retDate[6];
	var thisReturn = "";
	var thisFormat = "#thisMonth#, #thisDate# #thisYear#";
	
	thisFormat = dateformat(thisFormat, "m/d/yy") & " " & thisTime;
	thisFormat = dateadd("s", offset, thisFormat);
	thisFormat = dateadd("h", 1, thisFormat);

	longFormat = dateformat(thisFormat, "yyyy-mm-dd") & " " & timeformat(thisFormat, "HH:mm:ss");

	thisReturn = longFormat;
	return thisReturn;
}


/*
	parse twitter status for display
	example: #twitterMsg(statusmsg)#
	replaces @username with a url to profile
	replace #string with link to search
*/
function twitterMsg(msg) {
	var retMsg = activateURL(msg);
	retMsg = REReplace(retMsg, "@([[:alpha:][:digit:]_\-]+)", "<a target=""twitter"" href=""http://twitter.com/\1"">@\1</a> ", "ALL");
	retMsg = REReplace(retMsg, "\##([[:alpha:][:digit:]_\-]+)", "<a target='twitter' href='http://search.twitter.com/\'>##\1</a> ", "ALL");
	return retMsg;
}

</cfscript>

<!---
check to see if relationship exists
example: #checkFriend(user_a, user_b)
tu = twitter username
tp = twitter password
function checks if User A is friends with User B
--->
<cffunction name="checkFriend">
	<cfargument name="tu" type="string" required="yes" />
	<cfargument name="tp" type="string" required="yes" />
    <cfargument name="userA" type="string" required="yes">
    <cfargument name="userB" type="string" required="yes">
        <cfhttp url="http://twitter.com/friendships/exists.xml?user_a=#arguments.userA#&user_b=#arguments.userB#" result="friends" username="#arguments.tp#" password="#arguments.tu#" />
		<cfset ret = 0>
        <cfif find("true", friends.filecontent)>
			<cfset ret = 1>
		</cfif>
        <cfreturn ret>      
</cffunction>

<!--- 
tinyURL
pass a long url and a tiny url will be returned
theurl = the url to shorten	
--->
<cffunction name="tinyURL">
	<cfargument name="theurl" type="string" required="yes">
	<cfset var apiURL = "http://tinyurl.com/api-create.php?url=" & URLEncodedFormat(arguments.theurl) />
    <cfhttp url="#apiURL#" />
    <cfreturn cfhttp.FileContent />
</cffunction>


<!--- 
return rate limits 
checks the rate limit status of the verifying user
--->
<cffunction name="rateLimits">
    <cfargument name="tu" type="string" required="yes">
    <cfargument name="tp" type="string" required="yes">
	
    <cfparam name="thisrate.inlimit" default="false">
    <cfparam name="thisrate.remaining" default="0">
	
    <cfhttp url="http://twitter.com/account/rate_limit_status.xml" username="#arguments.tu#" password="#arguments.tp#" result="limits" />
	<cfif limits.statuscode eq "200 ok">
		<cfset rates = xmlparse(limits.filecontent)>
        <cfloop array="#rates.hash.XmlChildren#" index="x">
            <cfset "rate.#left(x.XmlName, 5)#" = x.XmlText>
        </cfloop>
        <cfset thisrate.remaining = rate.remai>
		<cfif rate.remai gt 0>
			<cfset thisrate.inlimit = true>
		</cfif>
	</cfif>
	<cfreturn thisrate>
</cffunction>

