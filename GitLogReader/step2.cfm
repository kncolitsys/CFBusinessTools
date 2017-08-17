<cfparam name="author" type="string" default="">
<cfparam name="gitlog" type="string" default="">

<cfsavecontent variable="local.js">
	<script language="JavaScript" type="text/javascript">
		$(document).ready(function() {
			$('#gitlog').dataTable({
				"bJQueryUI": true,
				"sPaginationType": "full_numbers"							
			});
		});
	</script>
</cfsavecontent>

<cfhtmlhead text="#local.js#">
				
<cfset reader = CreateObject("component", "reader").init(#author#,#gitlog#) />
<cfset authorRecords = reader.getAuthorRecords() />

<form action="exportRecords.cfm" method="post">
	<table id="gitlog" border="0" width="100%" cellpadding="5" cellspacing="0">
		<thead>
			<tr>
				<th width="50">Row</th>
				<th width="120">Author</th>
				<th width="80">Date</th>
				<th width="100">Time</th>
				<th>Action</th>
				<th width="50">Print</th>
			</tr>
		</thead>
		<tbody>
		   	<cfoutput query="authorRecords">
				<tr>
					<td valign="top" align="center">#currentrow#</td>
					<td valign="top">#author#</td>
					<td valign="top">#date#</td>
					<td valign="top">#time#</td>
					<td>#message#</td>
					<td valign="top" align="center"><input type="checkbox" name="printRecord" value="#currentrow#" checked="true"></td>
				</tr>
		    </cfoutput>
		</tbody>
	</table>
	<br/>
	<cfoutput>
		<input type="hidden" name="author" value="#author#">
		<div style="display:none;">
			<textarea name="gitlog">#gitlog#</textarea>
		</div>
		<input type="submit" name="btnPrint" value="Print marked records">
		<input type="submit" name="btnExcel" value="Output marked records to Excel">
	</cfoutput>
</form>