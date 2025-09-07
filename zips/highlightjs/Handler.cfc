component extends="org.mangoblog.plugins.BasePlugin" {

	variables.package = "plugin/asfusion/highlightjs";

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
			var script = '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/styles/default.min.css"><script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/highlight.min.js"></script><script>hljs.highlightAll();</script>';
				arguments.event.setOutputData(script);
		}
		return arguments.event;
	}
}