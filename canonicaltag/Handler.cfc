component extends="org.mangoblog.plugins.BasePlugin" {

	variables.package = "plugin/asfusion/canonicaltag";

	this.events = [ { 'name' = 'beforeHtmlHeadEnd', 'type' = 'sync', 'priority' = '5' }];

	// --------------------------------------------------
	public function init( mainManager, preferences ){
		super.init( arguments.mainManager, arguments.preferences );
		variables.blog = arguments.mainManager.getBlog();
		variables.blogUrl = variables.blog.getUrl();
		return this;
	}

	// --------------------------------------------------
	public function processEvent( required event ){
		if ( arguments.event.name EQ "beforeHtmlHeadEnd" ) {
			var context = arguments.event.getContextData();
			var newUrl = '';

			//check if it is an entry event.getContextData().currentEntry
			if ( structKeyExists( context, 'currentEntry' )){
				//page or post
				newUrl = variables.blogUrl & context.currentEntry.getUrl();
			}
			else if ( structKeyExists( context, 'currentArchive' )){
				//archives
				newUrl = variables.blogUrl & context.currentArchive.getUrl();
			}
			else if ( cgi.script_name EQ "/index.cfm" ) {
				newUrl = variables.blogUrl;
			}
			if ( len( newUrl )){
				arguments.event.setOutputData('<link rel="canonical" href="#newUrl#" />');
			}
		}
		return arguments.event;
	}
}