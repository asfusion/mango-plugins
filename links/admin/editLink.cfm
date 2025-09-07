<cfoutput><form method="post" action="#cgi.script_name#">

<div class="row">
<div class="col-12 ">
<div class="card card-body border-0 shadow mb-4">
<div class="mb-3">
<div>
	<label for="title">Title</label>
		<input class="form-control" input type="text" id="title" name="title" value="#link.getTitle()#" size="30" class="required" required/>
</div>
</div>

<div class="mb-3">
	<label for="address">Address</label>
		<input class="form-control" input type="text" id="address" name="address" value="#link.getAddress()#" size="30" class="required" required/>
</div>
<div class="mb-3">
	<label for="description">Description</label>
<textarea class="form-control"  id="description" name="description">#link.getDescription()#</textarea>
</div>
<div class="mb-3">
	<label for="category">Category</label>
<select id="category" name="category" class="required form-select mb-0" required>
	<cfloop from="1" to="#arraylen(categories)#" index="i">
	<option value="#categories[i].getId()#" <cfif categories[i].getId() EQ link.getCategoryId()>selected="selected"</cfif>>#categories[i].getName()#</option>
	</cfloop>
	</select>
</div>
	<div class="mb-3">
		<label for="order">Order</label>
			<input class="form-control" type="text" id="order" name="order" value="#link.getShowOrder()#" size="3"/>
	</div>
	<div class="mt-3">
		<input type="submit" class="btn btn-gray-800 mt-2 animate-up-2" value="Save"/>
	</div>
</div>
</div>
</div>
	<input type="hidden" name="selected" value="links-editLinkSettings" />
	<input type="hidden" name="event" value="links-editLinkSettings" />
	<input type="hidden" name="apply" value="true"  />
	<input type="hidden" name="owner" value="Links" />
		<input type="hidden" name="selected" value="Links" />
	<cfif len(link.getId())><input type="hidden" value="#link.getId()#" name="linkid" /></cfif>
	</form>
</cfoutput>