<cfcomponent>

<!--- constructor --->
<cffunction name="init" access="public" output="false" returntype="any" hint="Constructor for this cfc">
	<!--- take form input as arguments --->
	<cfargument name="author" type="string" required="true">
	<cfargument name="table" type="string" required="true">
	<cfargument name="dsn" type="string" required="true">
	<cfargument name="linkType" type="string" required="true">
	<cfargument name="useRTE" type="boolean" required="true">
	<cfargument name="section" type="string" require="true">
	
	<!--- set arguments into the variables scope so they can be used throughout the cfc --->
	<cfset variables.author = arguments.author />
	<cfset variables.table = arguments.table/>
	<cfset variables.dsn = arguments.dsn />
	<cfset variables.linkType = arguments.linkType />
	<cfset variables.useRTE = arguments.useRTE />
	<cfset variables.section = arguments.section />
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
	</cfquery>
    <cfreturn retVar>
</cffunction>

<!--- Get Table Info --->     
<cffunction name="getColumns" displayname="Get Columns" hint="Return column data from specified table" access="public" output="false" returntype="query">
    <cfdbinfo datasource=#variables.dsn#
      name="retVar"
      type="columns"
      table="#variables.table#">
      
    <cfreturn retVar>
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

<!--- Controller Generator --->
<cffunction name="generateController" access="public" returntype="string" hint="Generates code for the controller script">

	<cfscript>
		var apos = "'";
		var retVar = '
<cfcomponent>

	<!---********** #section#.cfc Controller **********--->
	<cffunction name="init" access="public" returntype="Any">
		<cfargument name="fw" type="Any" required="true">
		<cfset variables.fw = arguments.fw>
		
		<cfreturn this>
	</cffunction>
	
	<!---********** Get/Set Services **********--->
	<!---// 
			The getters and setters are implicitly created. These getters and setters
			refer to service object that is created off the generic _baseService class
			(cfc) located in the services folder.
	//--->
	
						
	<!---***** Get/Set: Insertion Point for Generator - DO NOT REMOVE *****--->
	
	
	

	<!---********** Action Services **********--->			
	
	<!---***** Action Services: Insertion Point for Generator - DO NOT REMOVE *****--->
	
</cfcomponent>';
			
		return retVar;
	</cfscript>
</cffunction>

<!--- Service Get/Set Functions --->
<cffunction name="generateServiceGetSet" access="public" returntype="string" hint="Generates Get/Set functions for the Service">
<cfscript>
	var itemLower= lcase(table);
	var item1Upper = ucase(left(table, 1)) & right(table, len(table)-1);
	
	var retVal = '	
	<cffunction name="set#item1Upper#Service" access="public" output="false" returntype="void">
		<cfargument name="#itemLower#Service" type="any" required="true" />
		<cfset variables.#itemLower#Service = arguments.#itemLower#Service />
	</cffunction>
	<cffunction name="get#item1Upper#Service" access="public" output="false" returntype="any">
		<cfreturn variables.#itemLower#Service />
	</cffunction>	
	';
	
	return retVal;
</cfscript>
</cffunction>

<!--- Service Action Functions --->
<cffunction name="generateServiceAction" access="public" returntype="string" hint="Generates Action functions for the Service">
<cfscript>
	var itemLower= lcase(table);
	var item1Upper = ucase(left(table, 1)) & right(table, len(table)-1);
	var apos = "'";
	
	var retVal = '
	<cffunction name="start#item1Upper#" access="public" output="false" returntype="void">
		<cfargument name="rc" type="struct" required="true">
		<cfif  isDefined(^arguments.rc.crudAction^) AND arguments.rc.crudAction EQ "delete">
			<cfset var bean = get#item1Upper#Service().getIBOByAttribute(argumentCollection=arguments.rc)> 
			<cfset get#item1Upper#Service().delete(bean)>
		</cfif>
	</cffunction>
	
	<cffunction name="#itemLower#" access="public" output="false" returntype="void">
		<cfargument name="rc" type="struct" required="true">
		<cfset var bean = get#item1Upper#Service().create()> 
		<cfset bean.loadStruct(arguments.rc)>
		<cfset arguments.rc.q = get#item1Upper#Service().getQueryByAttribute(bean)>	
	</cffunction>
	
	<cffunction name="#itemLower#Form" access="public" output="false" returntype="void"> 
		<cfargument name="rc" type="struct" required="true">
		<cfif isDefined(^arguments.rc.btnSubmit^)>
			<cfset var bean = get#item1Upper#Service().create()> 
			<cfset bean.loadStruct(arguments.rc)> 
			<cfset get#item1Upper#Service().save(bean)> 
			<cfset arguments.rc.msg = "#item1Upper# Item has been processed." />
		<cfelseif isDefined(^arguments.rc.crudAction^) AND arguments.rc.crudAction EQ "update">			
			<cfset arguments.rc.r = get#item1Upper#Service().getIBOByAttribute(argumentCollection=arguments.rc)>
		</cfif>
	</cffunction>
	
	';
	
	return retVal;
</cfscript>
</cffunction>

<!--- Bean.xml DAO Functions --->
<cffunction name="generateBeanXmlDAO" access="public" returntype="string" hint="Generates Get/Set functions for the Service">
<cfscript>
	var retVal = '	
	<bean id="#table#DAO" class="daos._baseDAO" singleton="true">
		<argument name="datasource" value="#dsn#" />
		<argument name="entity" value="#table#" />
	</bean>
	
	';
	
	return retVal;
</cfscript>
</cffunction>

<!--- Bean.xml Service Functions --->
<cffunction name="generateBeanXmlService" access="public" returntype="string" hint="Generates Action functions for the Service">
<cfscript>
	var itemLower= lcase(table);
	var item1Upper = ucase(left(table, 1)) & right(table, len(table)-1);
	var apos = "'";
	
	var retVal = '	
	<bean id="#table#Service" class="services._baseService" singleton="true">
		<argument name="argDAO">
			<ref bean="#table#DAO" />
		</argument>
		<argument name="argBean_path" value="models._baseIBO" />
	</bean>
	
	';
	
	return retVal;
</cfscript>
</cffunction>

<!--- Form Generator --->
<cffunction name="generateForm" access="public" returntype="string" hint="Generates code for the form script">
<cfscript>var retVar = '';</cfscript>

<cfloop query="tableColumns">
	<cfscript>retVar = retVar & '<cfparam name="rc.r.#variables.tableColumns.column_name#" default="" />
';</cfscript>
</cfloop>

<cfscript>retVar = retVar & '
<h1>#variables.table# Form</h1>

<cfif IsDefined("rc.msg")>
	<div style="color:red; font-weight:bold;">
		<p><cfoutput>%rc.msg%</cfoutput></p>
	</div>
</cfif>
<cfoutput>
<p><a href="%buildURL(^#variables.section#.#variables.table#^)%">&lt;&lt; Back to #ucase(variables.table)# in #ucase(variables.section)#</a></p>
<p>

<cfform action="%buildURL(^#variables.section#.#variables.table#Form^)%" method="post">
	<fieldset id="generalcontent">
		<legend>Add New #variables.table#</legend>';
</cfscript>
	
<!--- looping over fields in database to create form fields --->
	<cfloop query="tableColumns">
		<cfif is_PrimaryKey EQ "yes">
			
			<cfscript>
				retVar = retVar & '
					<div class="field">
						<label style="color:gray">#variables.tableColumns.column_name#</label>
						<cfinput name="#variables.tableColumns.column_name#" type="text" value="%rc.r.get(^#variables.tableColumns.column_name#^)%" readonly="true" />
					</div>

					<br class="clearFloat">
					';
			</cfscript>		
		<cfelse>
		<cfscript>
				retVar = retVar & '
				<div class="field">
					<label>#variables.tableColumns.column_name#</label>
					';
		</cfscript>
		<!--- Loop through columns and create form fields based off column type --->
		<!--- BIT and BOOLEAN datatypes --->
		<cfif #variables.tableColumns.type_name# EQ "bit" OR #variables.tableColumns.type_name# EQ "boolean" >
			<cfscript>
			retVar = retVar & '
				<input name="#variables.tableColumns.column_name#" type="checkbox" value="1" <cfif %rc.r.get(^#variables.tableColumns.column_name#^)% EQ 1>checked="checked"</cfif> />
				';
			</cfscript>
		
		<!--- TEXT datatype --->
		<cfelseif #variables.tableColumns.type_name# EQ "varchar" AND #variables.tableColumns.column_size# GT 255 OR #variables.tableColumns.type_name# EQ "text">
			<cfscript>
			retVar = retVar & '
				<cftextarea name="#variables.tableColumns.column_name#" height="300" width="600" rows="15" cols="75">%rc.r.get(^#variables.tableColumns.column_name#^)%</cftextarea>
				';
			</cfscript>
		
		<!--- DATE datatype --->
		<cfelseif #variables.tableColumns.type_name# EQ "date">
			<cfscript>
			retVar = retVar & '
				<cfinput name="#variables.tableColumns.column_name#" type="datefield" validate="date" size="30" maxlength="50" value="%rc.r.get(^#variables.tableColumns.column_name#^)%" />
				';
			</cfscript>
		
		<!--- DATETIME, SMALLDATETIME and TIMESTAMP datatypes --->
		<cfelseif #variables.tableColumns.type_name# EQ "datetime" OR #variables.tableColumns.type_name# EQ "timestamp" OR #variables.tableColumns.type_name# EQ "smalldatetime">
			<cfscript>
			retVar = retVar & '
				<cfinput name="#variables.tableColumns.column_name#" type="text" validate="date" size="30" maxlength="50" value="%rc.r.get(^#variables.tableColumns.column_name#^)%">
				';
			</cfscript>
		
		<!--- TIME datatype --->
		<cfelseif #variables.tableColumns.type_name# EQ "time" >
			<cfscript>
			retVar = retVar & '
				<cfinput name="#variables.tableColumns.column_name#" type="text" validate="time" size="30" maxlength="50" value="%rc.r.get(^#variables.tableColumns.column_name#^)%">
				';
			</cfscript>
		
		<!--- BIGINT, INT, SMALLINT datatype --->
		<cfelseif #variables.tableColumns.type_name# EQ "bigint" OR  #variables.tableColumns.type_name# EQ "int" OR #variables.tableColumns.type_name# EQ "smallint" >
			<cfscript>
			retVar = retVar & '
				<cfinput name="#variables.tableColumns.column_name#" type="text" validate="integer" size="30" maxlength="50" value="%rc.r.get(^#variables.tableColumns.column_name#^)%">
				';
			</cfscript>

		<!--- TINYINT datatype --->
		<cfelseif #variables.tableColumns.type_name# EQ "tinyint" >
			<cfscript>
			retVar = retVar & '
				<cfinput name="#variables.tableColumns.column_name#" type="text" validate="integer" size="30" maxlength="50" value="%rc.r.get(^#variables.tableColumns.column_name#^)%">
				';
			</cfscript>
		
		<!--- DECIMAL, FLOAT, MONEY, SMALLMONEY datatype --->
		<cfelseif #variables.tableColumns.type_name# EQ "decimal" OR  #variables.tableColumns.type_name# EQ "float" OR #variables.tableColumns.type_name# EQ "money" OR #variables.tableColumns.type_name# EQ "smallmoney" >
			<cfscript>
			retVar = retVar & '
				<cfinput name="#variables.tableColumns.column_name#" type="text" validate="decimal" size="30" maxlength="50" value="%rc.r.get(^#variables.tableColumns.column_name#^)%">
				';
			</cfscript>
										
		<!--- Column Name is PASSWORD --->
		<cfelseif #variables.tableColumns.column_name# EQ "password" >
			<cfscript>
			retVar = retVar & '
				<cfinput name="#variables.tableColumns.column_name#" type="password" size="50" maxlength="50" value="%rc.r.get(^#variables.tableColumns.column_name#^)%" />
		</td>
	</tr>
	<tr>
		<td valign="top" style="font-weight:bold; color:red;"</cfif>>
			Confirm Password
		</td>
		<td>
			<cfinput name="confirm#variables.tableColumns.column_name#" type="password" required="true" message="#variables.tableColumns.column_name# is required" size="50" maxlength="50" />	
				';
			</cfscript>
							
		<!--- Any other datatypes --->
		<cfelse>
			<cfscript>
			retVar = retVar & '
				<cfinput name="#variables.tableColumns.column_name#" type="text" size="50" maxlength="50" value="%rc.r.get(^#variables.tableColumns.column_name#^)%" />
				';
			</cfscript>
		</cfif>
		<cfscript>
			retVar = retVar & '
		</div>
		<br class="clearFloat">
		
	';
	</cfscript>
	</cfif>
	</cfloop>
	<cfscript>
			retVar = retVar & '
		<div class="field">
			<cfinput name="btnSubmit" type="submit" value="Submit" SubmitOnce="true" />
		</div>
</cfform>
</cfoutput>
</p>';	

return retVar;

</cfscript>

</cffunction>

<!--- Data Table Generator --->
<cffunction name="generateDataTable" access="public" returntype="string" hint="Generates code for the html data table">
<cfscript>var retVar = '
	<cfsavecontent variable="local.js">
		<style type="text/css" media="screen">
			@import "assets/css/demo_table_jui.css";	
			@import "assets/css/sunny.css";
		</style>
		
		<script language="JavaScript" type="text/javascript">
			$(document).ready(function() {
				$(^%#variables.table#^).dataTable({
					"bJQueryUI": true,
					"sPaginationType": "full_numbers"							
				});
			});
		</script>
	</cfsavecontent>
	
	<cfhtmlhead text="%local.js%">

	<br>
	<a href="<cfoutput>%buildURL(^#variables.section#.#variables.table#Form^)%</cfoutput>"><img src="assets/images/icons/add.png" border="0" style="vertical-align:middle;"> Add #variables.table#</a>
	<br><br>
	<table id="#variables.table#" class="display">
	<thead>
	<tr align="left">
	';</cfscript>
	<cfloop query="variables.tableColumns">
		<cfset counter = 1>
		<cfif counter LTE 5>
			<cfif NOT IS_PRIMARYKEY EQ "YES" AND  (#variables.tableColumns.type_name# EQ "varchar" AND #variables.tableColumns.column_size# GT 100) OR #variables.tableColumns.type_name# EQ "text" OR #variables.tableColumns.type_name# EQ "ntext" OR #variables.tableColumns.type_name# EQ "varchar">
				<cfscript>
					retVar = retVar & '<th>#variables.tableColumns.column_name#</th>
					';
				</cfscript>
				<cfset counter = counter + 1>
			</cfif>
		</cfif>
	</cfloop>
		<cfscript>
		retVar = retVar & '
		<th align="center">Edit</th>
		<th align="center">Delete</th>
	</tr>
	</thead>
	<tbody>
<cfoutput query="rc.q">
	<tr>';</cfscript>
<cfloop query="variables.tableColumns">
	<cfset counter = 1>
	<cfif counter LTE 5>
		<cfif NOT IS_PRIMARYKEY EQ "YES" AND  (#variables.tableColumns.type_name# EQ "varchar" AND #variables.tableColumns.column_size# GT 100) OR #variables.tableColumns.type_name# EQ "text" OR #variables.tableColumns.type_name# EQ "ntext" OR #variables.tableColumns.type_name# EQ "varchar">
			<cfif #variables.tableColumns.type_name# EQ "date" OR #variables.tableColumns.type_name# EQ "datetime" OR #variables.tableColumns.type_name# EQ "timestamp" OR #variables.tableColumns.type_name# EQ "smalldatetime" OR #variables.tableColumns.type_name# EQ "smalldate" >
				<cfscript>
			retVar = retVar & '<td valign="top">%dateformat(#variables.tableColumns.column_name#, ^m/d/yy^)%</td>';</cfscript>
				
			<cfelseif #variables.tableColumns.type_name# EQ "time">
				<cfscript>
			retVar = retVar & '<td valign="top">%timeformat(#variables.tableColumns.column_name#, ^h:mm tt^)%</td>';</cfscript>
				
			<cfelse>
				<cfscript>
			retVar = retVar & '<td valign="top">%#variables.tableColumns.column_name#%</td>';</cfscript>
				
			</cfif>
		</cfif>	
		<counter = counter + 1>
	</cfif>
</cfloop>
<cfscript>
		retVar = retVar & '<td align="center">
			<a href="%buildURL(^#variables.section#.#variables.table#Form?crudAction=update&#variables.pkField#=%#variables.pkField#%^)%" style="text-decoration: none;">';</cfscript>
			<cfif variables.linkType EQ 'useGraphicLinks'>
			<cfscript>
				retVar = retVar & '<img src="assets/images/icons/pencil.png" border="0" align="absmiddle">
				';</cfscript>
			<cfelse>
			<cfscript>
			retVar = retVar & 'Edit
			';</cfscript>
			</cfif>
			<cfscript>
			retVar = retVar & '</a>
		</td>
		<td align="center">
			<a href="%buildURL(^#variables.section#.#variables.table#?crudAction=delete&#variables.pkField#=%#variables.pkField#%^)%" onclick="javascript:return confirm(^Are you sure you want to delete this record?^)" style="text-decoration: none;">
			';</cfscript>
				<cfif variables.linkType EQ 'useGraphicLinks'>
				<cfscript>
					retVar = retVar & '<img src="assets/images/icons/delete.png" border="0" align="absmiddle">
					';</cfscript>
				<cfelse>
				<cfscript>
				retVar = retVar & 'Delete
				';</cfscript>
				</cfif>
			<cfscript>
			retVar = retVar & '</a>
		</td>
	</tr>
</cfoutput>
</tbody>
</table>		

';

return retVar;

</cfscript>
</cffunction>

<!--- Application CFC Generator --->
<cffunction name="generateApplicationCFC" access="public" returntype="string" hint="Generates code for Application CFC">
<cfset apos = "'"/>
<cfscript>
		var retVar = '<cfcomponent extends="framework">
	<cfscript>
		this.name = "CF/1 Application Generator";
		this.datasource = "#variables.dsn#";
		this.sessionmanagement = true;		
	
		/* framework defaults (as struct literal):*/
		variables.framework = {
			// the name of the URL variable:
			action = ^action^,
			// default section name:
			defaultSection = ^main^,
			// default item name:
			defaultItem = ^home^,
			// the default when no action is specified:
			home = ^main.home^,
			// the default error action when an exception is thrown:
			error = ^main.error^,
			// the URL variable to reload the controller/service cache:
			reload = ^reload^,
			// the value of the reload variable that authorizes the reload:
			password = ^true^,
			// debugging flag to force reload of cache on each request:
			reloadApplicationOnEveryRequest = false	
		};
		
		//** Function that called by the framework.cfc and run during the onApplicationStart() event **//
		function setupApplication() {
			//** Creates an instance of the ObjectFactory in the models folder using the beans.xml file from the _config directory **//
			setBeanFactory(createObject("component", "models.ObjectFactory").init(expandPath("./_config/beans.xml.cfm")));	
			
			Application.Datasource = this.datasource;
			Application.Name = this.name;
		}
	</cfscript>
</cfcomponent>';
		
		return retVar;
	</cfscript>
</cffunction>

</cfcomponent>