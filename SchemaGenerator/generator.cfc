<cfcomponent>

<!--- constructor --->
<cffunction name="init" access="public" output="false" returntype="any" hint="Constructor for this cfc">
	<!--- take form input as arguments --->
	<cfargument name="table" type="string" required="true">
	<cfargument name="dsn" type="string" required="true">
	
	<!--- set arguments into the variables scope so they can be used throughout the cfc --->
	<cfset variables.table = arguments.table/>
	<cfset variables.dsn = arguments.dsn />
  	<cfset variables.tableColumns = getColumns(variables.dsn, variables.table)/>
	  
	<cfloop query="variables.tableColumns">
		<cfif Is_PrimaryKey EQ true>
			<cfset variables.pkField = "#variables.tableColumns.column_name#" />
		</cfif>
	</cfloop>

	<!--- return this cfc --->
	<cfreturn this/>
</cffunction>

<!--- Get Database Info --->
<cffunction name="getTables" displayname="Get Tables" hint="Return table data from specified datasource" access="remote" output="false" returntype="query">
	<cfargument name="dsn" type="string" required="false"/>
	<cfdbinfo datasource="#arguments.dsn#" name="raw" type="tables" />
	<cfquery dbtype="query" name="retVar" >
		select *
		from raw
		where table_type like 'TABLE'
		Order By table_name
	</cfquery>
    <cfreturn retVar>
</cffunction>

<!--- Get Table Info --->     
<cffunction name="getColumns" displayname="Get Columns" hint="Return column data from specified table" access="public" output="false" returntype="query">
    <cfdbinfo datasource=#variables.dsn#
      name="retVar"
      type="columns"
      table="#variables.table#">
	<cfquery dbtype="query" name="sorted" >
		select *
		from retVar
		Order By column_name
	</cfquery>
    <cfreturn sorted>
</cffunction>

<!--- Table Config Generator --->
<cffunction name="generateTableConfig" displayname="Table Configuration" access="public" output="false" returntype="String" >
	<cfset qColumns = getColumns()>

	<cfset config = "<cfscript>">
		
	<cfloop query="qColumns">
		<cfset line = "#chr(9)#addProperty(property=""#column_name#""">
		<cfif type_name IS "char">
			<cfset line &= ", type=""varchar""">
		<cfelse>
			<cfset line &= ", type=""#listGetAt(type_name, 1, ' ')#""">
		</cfif>
		<cfif listFind("varchar,char", type_name)>
			<cfset line &= ", size=#column_size#">
		</cfif>
		<cfif NOT trim(is_nullable)>
			<cfset line &= ", allowNull=false">
		</cfif>
		<cfif is_primaryKey>
			<cfset line &= ", pk=true">
		</cfif>
		<cfset line &= ");">
		<cfset config = listappend(config, line, "#chr(10)#")>
	</cfloop>
		
	<cfset config &= "#chr(10)#</cfscript>">
	<cfset config = ltrim(config)>
	<cfreturn config />
</cffunction>

</cfcomponent>