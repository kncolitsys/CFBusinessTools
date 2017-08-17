<cfcomponent displayname="Base Service">

	<cfproperty name="variables.dao" type="any">
	<cfproperty name="variables.bean_path" type="string">

	<cffunction name="init" access="public" output="false" returntype="Any">
		<cfargument name="argDao" type="any" required="true">
		<cfargument name="argBean_path" type="string" required="false" default="">
		
		<cfset variables.dao=arguments.argDao>
		<cfset variables.bean_path=arguments.argBean_path>
		
		<cfreturn this>
	</cffunction>

	<cffunction name="create" access="public" output="false" returntype="any">
		<cfset var obj = createObject("component","#variables.bean_path#").init()>
		<cfreturn obj>
	</cffunction>

	<cffunction name="getIBOByAttribute" access="public" output="false" returntype="any">
		<cfset var obj = create()>
		<cfset obj.loadQuery(variables.dao.read(argumentCollection=arguments))>
		<cfreturn obj>
	</cffunction>

	<cffunction name="getQueryByAttribute" access="public" output="false" returntype="any">
		<cfreturn variables.dao.read(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="save" access="public" output="false" returntype="any">
		<cfargument name="bean" type="Any" required="true">
		<cfargument name="overwritePK" type="boolean" required="false" default="false">
		<cfreturn variables.dao.save(argumentCollection=arguments)>
	</cffunction>
	
	<cffunction name="delete" access="public" output="false" returntype="any">
		<cfargument name="bean" type="Any" required="true">
		<cfreturn variables.dao.delete(argumentCollection=arguments)>
	</cffunction>
</cfcomponent>