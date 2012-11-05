<!--- 
=============================================================
	Utility:	ColdFusion ColoredCode v3.2
	Author:		Dain Anderson
	Email:		webmaster@cfcomet.com
	Revised:	June 7, 2001
	Download:	http://www.cfcomet.com/cfcomet/utilities/
	
	Modified by Laura Arguello to make it XHTML valid
	
============================================================= 
--->

<!--- Initialize attribute values --->
<CFPARAM NAME="Attributes.Data" DEFAULT="">

<!--- mod by ray --->
<cfparam name="attributes.r_result" default="result">

<CFSET Data = Attributes.Data>

<!--- Abort if no data was sent ---> 
<CFIF NOT LEN(DATA)>
			 <cfset caller[attributes.r_result] = data>
</CFIF>

<CFSCRIPT>
	/* Pointer to Attributes.Data */
	this = Data;

	/* Convert special characters so they do not get interpreted literally; italicize and boldface */
	this = REReplaceNoCase(this, "&([[:alpha:]]{2,});", "«span class='cc_specialchar'»&amp;\1;«/span»", "ALL");

	/* Convert many standalone (not within quotes) numbers to blue, ie. myValue = 0 */
	this = REReplaceNoCase(this, "(gt|lt|eq|is|,|\(|\))([[:space:]]?[0-9]{1,})", "\1«span class='cc_numeric'»\2«/span»", "ALL");

	/* Convert normal tags to navy blue */
	this = REReplaceNoCase(this, "<(/?)((!d|b|c(e|i|od|om)|d|e|f(r|o)|h|i|k|l|m|n|o|p|q|r|s|t(e|i|t)|u|v|w|x)[^>]*)>", "«span class='cc_normaltag'»<\1\2>«/span»", "ALL");

	/* Convert all table-related tags to teal */
	this = REReplaceNoCase(this, "<(/?)(t(a|r|d|b|f|h)([^>]*)|c(ap|ol)([^>]*))>", "«span class='cc_tabletag'»<\1\2>«/span»", "ALL");

	/* Convert all form-related tags to orange */
	this = REReplaceNoCase(this, "<(/?)((bu|f(i|or)|i(n|s)|l(a|e)|se|op|te)([^>]*))>", "«span class='cc_formtag'»<\1\2>«/span»", "ALL");

	/* Convert all tags starting with 'a' to green, since the others aren't used much and we get a speed gain */
	this = REReplaceNoCase(this, "<(/?)(a[^>]*)>", "«span class='cc_anchor'»<\1\2>«/span»", "ALL");

	/* Convert all image and style tags to purple */
	this = REReplaceNoCase(this, "<(/?)((im[^>]*)|(sty[^>]*))>", "«span class='cc_image'»<\1\2>«/span»", "ALL");

	/* Convert all ColdFusion, SCRIPT and WDDX tags to maroon */
	this = REReplaceNoCase(this, "<(/?)((cf[^>]*)|(sc[^>]*)|(wddx[^>]*))>", "«span class='cc_cftag'»<\1\2>«/span»", "ALL");

	/* Convert all inline "//" comments to gray (revised) */
	this = REReplaceNoCase(this, "([^:/]\/{2,2})([^[:cntrl:]]+)($|[[:cntrl:]])", "«span class='cc_comment'»\1\2«/span»", "ALL");

	/* Convert all multi-line script comments to gray */
	this = REReplaceNoCase(this, "(\/\*[^\*]*\*\/)", "«span class='cc_comment'»\1«/span»", "ALL");

	/* Convert all HTML and ColdFusion comments to gray */	
	/* The next 10 lines of code can be replaced with the commented-out line following them, if you do care whether HTML and CFML 
	   comments contain colored markup. */
	EOF = 0; BOF = 1;
	while(NOT EOF) {
		Match = REFindNoCase("<!---?([^-]*)-?-->", this, BOF, True);
		if (Match.pos[1]) {
			Orig = Mid(this, Match.pos[1], Match.len[1]);
			Chunk = REReplaceNoCase(Orig, "«(/?[^»]*)»", "", "ALL");
			BOF = ((Match.pos[1] + Len(Chunk)) + 31); // 31 is the length of the FONT tags in the next line
			this = Replace(this, Orig, "«span class='comment'»#Chunk#«/span»");
		} else EOF = 1;
	}
	
	

	/* Convert all quoted values to blue */
	this = REReplaceNoCase(this, """([^""]*)""", "«span class='cc_value'»""\1""«/span»", "ALL");

</CFSCRIPT>

<cfset caller[attributes.r_result] = this>


