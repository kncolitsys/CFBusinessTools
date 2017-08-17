<cfset reader = CreateObject("component", "reader").init(#form.author#,#form.gitlog#) />
<cfset authorRecords = reader.getAuthorRecords() />

<cfif isDefined('btnPrint')>
	<html>
		<head>
			<style type="text/css">
				* {
					padding: 0em;
					margin: 0em;
				}
				
				table {
					font-family: Arial, sans-serif;
					font-size:10pt;
					margin: 10px 0 0 10px;
					border: double 1px black;
				}
				
				th {
					font-weight:bold;
					border-bottom:double 1px black;
					text-align:left;
				}
				
				td {
					padding:2px 0 2px 0;
				}
	
				.page{page-break-after:always;}
			
			</style>
		</head>
		<body>
			<table border="0" width="800" cellpadding="5" cellspacing="0">
				<tr>
					<td colspan="7" align="center">
						<h2><cfoutput>Git Log Records for #form.author#</cfoutput></h2>
					</td>	
				</tr>
				<tr><td colspan="7">&nbsp;</td></tr>
				<tr>
					<th width="120">Author</th>
					<th width="80">Date</th>
					<th width="100">Time</th>
					<th>Action</th>
				</tr>
			   	<cfoutput query="authorRecords">
				   	<cfif ListFind(printRecord, currentrow) NEQ 0>
						<tr>
							<td valign="top">#author#</td>
							<td valign="top">#date#</td>
							<td valign="top">#time#</td>
							<td>#message#</td>
						</tr>
					</cfif>
			    </cfoutput>
			</table>
		</body>
	</html>
<cfelse>	
	<!--- create new query replacing the value of bookimmediately from 1/0 to X or empty string --->
	<cfset excelData = queryNew("author, date, time, action",
								"VarChar, Date, Time, VarChar")>
	
	<cfloop query="authorRecords">
		<cfif ListFind(printRecord, currentrow) NEQ 0>
			<cfset queryAddRow(excelData)>
			<cfset querySetCell(excelData, "author", "#author#")>
			<cfset querySetCell(excelData, "date", "#dateformat(date, 'mm/dd/yy')#")>
			<cfset querySetCell(excelData, "time", "#timeformat(time, 'HH:mm')#")>
			<cfset querySetCell(excelData, "action", "#message#")>
		</cfif>
	</cfloop>
	
	<!--- Create excel spreadsheet and push the file to the user --->
	<cfheader name="Content-Disposition" value="inline; filename=GitLog-#author#.xls">
	<cfset theSheet = SpreadsheetNew("GitLog")>
	<cfset SpreadsheetAddRow(theSheet, "AUTHOR,DATE,TIME,ACTION")>
	<cfset SpreadsheetAddRows(theSheet,excelData)> 
	<cfset bin = spreadsheetReadBinary(theSheet)> 
	<cfcontent type="application/vnd-ms.excel" variable="#bin#" reset="true">
</cfif>