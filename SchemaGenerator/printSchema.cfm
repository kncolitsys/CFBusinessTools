<cfparam name="dsn" type="string" default="">
<cfparam name="table" type="string" default="">

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
		<cfif #table# EQ "all">
			<cfdbinfo datasource="#dsn#" name="raw" type="tables" />
			<cfquery dbtype="query" name="filtered" >
				select *
				from raw
				where table_type like 'TABLE'
			</cfquery>
			<cfloop query="filtered">
				<cfset generator = CreateObject("component", "generator").init(#table_name#,#dsn#) />
				<cfset tableColumns = generator.getColumns() />
				<div class="page">
					<table border="0" width="800" cellpadding="5" cellspacing="0">
						<tr>
							<td colspan="7" align="center">
								<h2><cfoutput>#ucase(table_name)# Schema</cfoutput></h2>
							</td>	
						</tr>
						<tr><td colspan="7">&nbsp;</td></tr>
						<tr>
							<th>Keys</th>
							<th>Position</th>
							<th>Column Name</th>
							<th>Data Type</th>
							<th>Column Size</th>
							<th>Default Value</th>
							<th>Nullable</th>
						</tr>
					   	<cfoutput query="tableColumns">
						   	<cfif currentrow MOD 2 EQ 0><cfset bg="##ddd"><cfelse><cfset bg="##fff"></cfif>
							<tr style="background:#bg#">
								<td>
									<cfif #is_primaryKey# EQ "yes">
										<img src="images/primaryKey.png">
									<cfelseif #is_Foreignkey# EQ "yes">
										<img src="images/foreignKey.png">
									</cfif>
								</td>
								<td>#ordinal_position#</td>
								<td>#column_name#</td>
								<td>#type_name#</td>
								<td>#column_size#</td>
								<td>#column_default_value#</td>
								<td>#is_nullable#</td>
							</tr>
					   </cfoutput>
					</table>	
				</div>		
			</cfloop>
		<cfelse>
			<cfset generator = CreateObject("component", "generator").init(#table#,#dsn#) />
			<cfset tableColumns = generator.getColumns() />		
			<table border="0" width="800" cellpadding="5" cellspacing="0">
				<tr>
					<td colspan="7" align="center">
						<h2><cfoutput>#ucase(table)# Schema</cfoutput></h2>
					</td>	
				</tr>
				<tr><td colspan="7">&nbsp;</td></tr>
				<tr>
					<th>Keys</th>
					<th>Position</th>
					<th>Column Name</th>
					<th>Data Type</th>
					<th>Column Size</th>
					<th>Default Value</th>
					<th>Nullable</th>
				</tr>
			   	<cfoutput query="tableColumns">
				   	<cfif currentrow MOD 2 EQ 0><cfset bg="##ddd"><cfelse><cfset bg="##fff"></cfif>
					<tr style="background:#bg#">
						<td>
							<cfif #is_primaryKey# EQ "yes">
								<img src="images/primaryKey.png">
							<cfelseif #is_Foreignkey# EQ "yes">
								<img src="images/foreignKey.png">
							</cfif>
						</td>
						<td>#ordinal_position#</td>
						<td>#column_name#</td>
						<td>#type_name#</td>
						<td>#column_size#</td>
						<td>#column_default_value#</td>
						<td>#is_nullable#</td>
					</tr>
			   </cfoutput>
			</table>
		</cfif>
	</body>
</table>