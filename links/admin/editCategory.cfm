<cfoutput><form method="post" action="#cgi.script_name#">

<div class="row">
<div class="col-12 ">
<div class="card card-body border-0 shadow mb-4">
<div class="mb-3">
<div>
	<label for="title">Title</label>
		<input class="form-control" input type="text" id="name" name="name" value="#category.getName()#" size="30" class="required"/>
</div>
</div>

<div class="mb-3">
	<label for="description">Description</label>
<textarea class="form-control"  id="description" name="description">#category.getDescription()#</textarea></textarea>

	<div class="form-text hint">What this category is about. Whether or not this is shown in the blog depends on the skin used</div>
</div>

	<div class="mt-3">
		<input type="submit" class="btn btn-gray-800 mt-2 animate-up-2" value="Save"/>
	</div>

</div>
</div>
</div>
	<input type="hidden" value="links-editLinkCategorySettings" name="event" />
	<input type="hidden" value="true" name="apply" />
	<input type="hidden" value="Links" name="owner" />
	<input type="hidden" value="links-editLinkCategorySettings" name="selected" />
	<cfif len(category.getId())><input type="hidden" value="#category.getId()#" name="categoryid" /></cfif>
	</form></cfoutput>