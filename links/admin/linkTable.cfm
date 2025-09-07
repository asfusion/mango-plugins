<cfoutput>
	<h5>Category: #category.getName()#
	<a href="#cgi.script_name#?event=links-editLinkCategorySettings&amp;owner=Links&categoryid=#category.getId()#&selected=Links"><button class="btn btn-outline-tertiary btn-sm" type="button">Edit</button></a> <a href="#cgi.script_name#?event=links-deleteLinkCategory&amp;owner=Links&categoryid=#category.getId()#&amp;selected=Links" class="deleteButton">
	<button class="btn btn-outline-danger btn-sm" type="button">Delete</button></a></h5>

<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center py-4">
<div class="card card-body border-0 shadow table-wrapper table-responsive">
<table class="table table-hover">
	<thead>
	<tr>
		<th class="border-gray-200">Title</th>
		<th class="border-gray-200">Address</th>
		<th class="border-gray-200">Actions</th>
	</tr>
	</thead>
<tbody>
	<cfloop from="1" to="#arraylen(links)#" index="i">
		<tr>
			<td >#links[i].getTitle()#</td>
			<td ><a href="#links[i].getAddress()#">#links[i].getAddress()#</a></td>
			<td ><a href="#cgi.script_name#?action=event&amp;event=links-editLinkSettings&amp;owner=Links&linkid=#links[i].getId()#&amp;selected=Links" class="editButton"><button class="btn btn-outline-tertiary btn-sm" type="button">Edit</button></a>
			<a href="#cgi.script_name#?event=links-deleteLink&amp;owner=Links&linkid=#links[i].getId()#&amp;selected=Links" class="deleteButton"><button class="btn btn-outline-danger btn-sm" type="button">Delete</button></a></td>
	</tr>
	</cfloop>

	</tbody>
	</table>

	</div>
	</div>
</cfoutput>