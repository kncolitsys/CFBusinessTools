<cfcomponent output="false">

	<cfset variables.datasource = "">	<!--- Datasource name --->
	<cfset variables.entity = "">		<!--- DB table name --->
	<cfset variables.properties = {}>	<!--- Struct to hold column info --->
	<cfset variables.defaultSort = "">	<!--- Default column list to sort by --->
	<cfset variables.joinTables = {}>	<!--- Struct of tables that we can join with --->
	<cfset variables.pkColumn = "">		<!--- Primary key column --->

	<cffunction name="init" output="false" access="public" returntype="any">
		<cfargument name="datasource" type="String" required="true">
		<cfargument name="entity" type="String" required="true">
		
		<cfset variables.datasource = arguments.datasource>
		<cfset variables.entity = arguments.entity>
		
		<!--- Load variables.properties --->
		<cfset loadEntityFile(variables.entity & ".cfm")>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="read" output="false" access="public" returntype="query">
		<!--- Arguments
			[Struct:[p1,p2...pn]],	= Properties to filter on.
			[Struct:[r1,r2...rn]],	= Struct of relationship & any properties to filter on.
			[String:orderBy],		= Comma-delimited columns to order the query by.
		--->
		<cfset var qRead = "">
		<cfset var item = "">
		<cfset var isJoin = false>
		<cfset var myJoin = "">
		<cfset var joinList = structKeyList(variables.joinTables)>
		<cfset var table = "">
		<cfset var relations = structNew()>
		<cfset var relation = "">
		
		<cfloop collection="#arguments#" item="item">
			<cfif isStruct(arguments[item]) AND structKeyExists(variables.joinTables, item)>
				<cfset relations[item] = duplicate(arguments[item])>
				<cfset structdelete(arguments, item)>
			</cfif>
		</cfloop>
				
		<cfquery name="qRead" datasource="#variables.datasource#">
			SELECT 
				#addTableAlias(structKeyList(variables.properties))#
				<cfloop collection="#relations#" item="relation">
					,#addTableAlias(structKeyList(variables.joinTables[relation].properties), relation)#
				</cfloop>
			FROM
				[#variables.entity#]
				<cfloop collection="#relations#" item="relation">
					<cfset myJoin = variables.joinTables[relation]>
					<cfif listFind("1:1,m:1,1:m", myJoin.relationship)>
						#myJoin.joinType# JOIN [#myJoin.table#] as [#relation#] ON
							[#relation#].[#myJoin.pk#] = [#variables.entity#].[#myJoin.fk#]
					<cfelseif myJoin.relationship EQ "m:m">
						#myJoin.joinType# JOIN [#myJoin.linkTable#] as [#relation#_#myJoin.linkTable#] ON
							[#relation#_#myJoin.linkTable#].[#myJoin.linkpk#] = [#variables.entity#].[#myJoin.fk#]
						#myJoin.joinType# JOIN [#myJoin.table#] as [#relation#] ON
							[#relation#].[#myJoin.pk#] = [#relation#_#myJoin.linkTable#].[#myJoin.linkfk#]
					</cfif>
				</cfloop>
			<cfif len(structkeylist(arguments))>
				WHERE 1=1
				<cfloop collection="#arguments#" item="item">
					<cfif listFind("orderBy", item)>
						<cfcontinue>
					<cfelseif NOT isStruct(arguments[item]) AND structKeyExists(variables.properties, item)>
						AND [#variables.entity#].[#item#] = <cfqueryparam cfsqltype="#getSQLType(item)#" value="#arguments[item]#">
					<cfelseif structKeyExists(relations, item)>
						<cfloop collection="#arguments[item]#" item="property">
							<cfset myJoin = variables.joinTables[item]>
							<cfif arguments[item][property] IS NOT "*NULL">
								AND [#item#].[#property#] = <cfqueryparam cfsqltype="#ranslateSQLType(myJoin.properties[property].type)#" value="#arguments[item][property]#">
							<cfelse>
								AND [#item#].[#property#] IS NULL
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
				
				<cfif structKeyExists(arguments, "orderBy") AND len(trim(arguments.orderBy))>
					ORDER BY 
						<cfloop list="#arguments.orderBy#" index="property">
							<cfif structKeyExists(variables.properties, property)>
								#addTableAlias(arguments.orderBy)#
							<cfelse>
								<cfloop collection="#relations#" item="relation">
									#variables.joinTables[relation]#.#property#
								</cfloop>
							</cfif>
						</cfloop>
				<cfelseif variables.defaultSort IS NOT "">
					ORDER BY #addTableAlias(variables.defaultSort)#
				</cfif>
			</cfif>
		</cfquery>
		
		<cfreturn qRead>
	</cffunction>

	<cffunction name="save" output="false" access="public" returntype="Any">
		<cfargument name="bean" type="Any" required="true">
		<cfargument name="overwritePK" type="boolean" required="false" default="false">
		
		<cfif bean.get(variables.pkColumn) EQ "" OR arguments.overwritePK>
			<cfreturn create(argumentCollection=arguments)>
		<cfelse>
			<cfreturn update(arguments.bean)>
		</cfif>
	</cffunction>

	<cffunction name="create" output="false" access="private" returntype="any">
		<cfargument name="bean" type="Any" required="true">
		<cfargument name="overwritePK" type="boolean" required="false" default="false">
		<cfset var insResult = "">
		<cfset var colList = "">
		<cfset var item = "">
		<cfset var tmp = "">
		<cfloop collection="#variables.properties#" item="item">
			<cfif structKeyExists(variables.properties, item) AND (arguments.overwritePK OR NOT variables.properties[item].pk)>
				<cfset colList = listAppend(colList, item)>
			</cfif>
		</cfloop>
		
		<cfquery datasource="#variables.datasource#" result="insResult">
			INSERT INTO [#variables.entity#]
			(#colList#)
			VALUES
			(
			<cfloop list="#colList#" index="item">
				<cfif structKeyExists(variables.properties, item) AND (arguments.overwritePK OR NOT variables.properties[item].pk)>
					<cfif arguments.bean.get(item) IS "" AND variables.properties[item].allowNull>
						<cfqueryparam cfsqltype="#getSQLType(item)#" value="" null="true">
					<cfelse>
						<cfqueryparam cfsqltype="#getSQLType(item)#" value="#arguments.bean.get(item)#">
					</cfif><cfset tmp &= "#item# (#getSQLType(item)#): #arguments.bean.get(item)# <br>">
					<cfif NOT listLast(colList) IS item>,</cfif>
				</cfif>
			</cfloop>
			)
		</cfquery>
		
		<cfif structKeyExists(insResult, "IDENTITYCOL")>
			<cfset arguments.bean.set(variables.pkColumn, insResult.IDENTITYCOL)>
		</cfif>
		
		<cfreturn arguments.bean>
	</cffunction>

	<cffunction name="update" output="false" access="private" returntype="any">
		<cfargument name="bean" type="Any" required="true">
		<cfset var fieldsToUpdate = "">
		<cfset var primaryKeys = {}>
		<cfset var item = "">
		
		<cfloop collection="#variables.properties#" item="item">
			<cfif structKeyExists(variables.properties, item) AND variables.properties[item].pk>
				<cfset primaryKeys[item] = arguments.bean.get(item)>
			<cfelseif structKeyExists(variables.properties, item)>
				<cfset fieldsToUpdate = listAppend(fieldsToUpdate, item)>
			</cfif>
		</cfloop>
		
		<cfquery datasource="#variables.datasource#" result="insResult">
			UPDATE [#variables.entity#]
			SET
				<cfloop list="#fieldsToUpdate#" index="item">
					[#item#] = 
					<cfif arguments.bean.get(item) IS "" AND variables.properties[item].allowNull>
						<cfqueryparam cfsqltype="#getSQLType(item)#" value="" null="true">
					<cfelse>
						<cfqueryparam cfsqltype="#getSQLType(item)#" value="#arguments.bean.get(item)#">
					</cfif>
					<cfif NOT item IS listLast(fieldsToUpdate)>,</cfif>
				</cfloop>
			WHERE 1=1
			<cfloop collection="#primaryKeys#" item="item">
				AND [#item#] = <cfqueryparam cfsqltype="#getSQLType(item)#" value="#arguments.bean.get(item)#">
			</cfloop>
		</cfquery>
		
		<cfreturn arguments.bean>
	</cffunction>
	
	<cffunction name="delete" output="false" access="public" returntype="any">
		<cfargument name="bean" type="Any" required="true">
		<cfset var primaryKeys = {}>
		<cfset var item = "">
		
		<cfloop collection="#variables.properties#" item="item">
			<cfif structKeyExists(variables.properties, item) AND variables.properties[item].pk>
				<cfset primaryKeys[item] = arguments.bean.get(item)>
			</cfif>
		</cfloop>
		
		<cfquery datasource="#variables.datasource#" result="delResult">
			DELETE FROM [#variables.entity#]
			WHERE 1=1
			<cfloop collection="#primaryKeys#" item="item">
				AND [#item#] = <cfqueryparam cfsqltype="#getSQLType(item)#" value="#arguments.bean.get(item)#">
			</cfloop>
		</cfquery>
		
		<cfreturn arguments.bean>
	</cffunction>
	
	<cffunction name="translateSQLType" output="false" access="private" returntype="String">
		<cfargument name="type" type="String" required="true">
		<cfset var result = "">
		
		<cfswitch expression="#arguments.type#">
			<cfcase value="int"><cfset result = "cf_sql_integer"></cfcase>
			<cfcase value="decimal"><cfset result = "cf_sql_decimal"></cfcase>
			<cfcase value="float"><cfset result = "cf_sql_float"></cfcase>
			<cfcase value="money"><cfset result = "cf_sql_money"></cfcase>
			<cfcase value="uniqueidentifier"><cfset result = "cf_sql_idstamp"></cfcase>
			<cfdefaultcase><cfset result = "cf_sql_varchar"></cfdefaultcase>
		</cfswitch>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="getSQLType" output="false" access="private" returntype="String">
		<cfargument name="item" type="String" required="true">
		
		<cfreturn translateSQLType(variables.properties[arguments.item].type)>
	</cffunction> 
	
	<cffunction name="addTableAlias" output="false" access="private" returntype="String">
		<cfargument name="columnList" type="String" required="true">
		<cfargument name="alias" type="String" required="false" default="#variables.entity#">
		<cfset var i = 0>
		<cfset var item = "">
		<cfset var property = "">
		<cfset var direction = "">
		<cfset var col = "">
		<cfset var newList = "">
		
		<cfloop from="1" to="#listLen(arguments.columnList)#" index="i">
			<cfset item = listGetAt(arguments.columnList, i)>
			<cfset property = listGetAt(item, 1, " ")>
			<cfset direction = "">
			
			<cfif listLen(item, " ") EQ 2>
				<cfset direction = listGetAt(item, 2, " ")>
			</cfif>
			
			<cfset col = "[" & arguments.alias & "]" & ".[" & property & "] " & direction>
			
			<cfif arguments.alias IS NOT variables.entity AND variables.joinTables[arguments.alias].propertyPrefix IS NOT "">
				<cfset col &= " as [" & variables.joinTables[arguments.alias].propertyPrefix>
				<cfif structKeyExists(variables.joinTables[arguments.alias].properties[property], "alias")>
					<cfset col &= variables.joinTables[arguments.alias].properties[property].alias & "]">
				<cfelse>
					<cfset col &= property & "]">
				</cfif>
			<cfelseif structKeyExists(variables.properties, property) AND structKeyExists(variables.properties[property], "alias")>
				<cfset col &=  " as [" & variables.properties[property].alias & "]">
			</cfif>
			
			<cfset newList = listAppend(newList, col)>
		</cfloop>
		
		<cfreturn newList>
	</cffunction>

	<cffunction name="addProperty" output="false" access="private" returntype="void">
		<cfargument name="property" type="String" required="true">
		<cfargument name="type" type="String" required="true">
		<cfargument name="size" type="Numeric" required="false" default="0">
		<cfargument name="allowNull" type="Boolean" required="false" default="true">
		<cfargument name="alias" type="String" required="false" default="">
		<cfargument name="pk" type="Boolean" required="false" default="false">
		<cfargument name="defaultSort" type="String" required="false" default="">
		
		<cfscript>
			var prop = {
				type=arguments.type,
				allowNull=arguments.allowNull,
				pk=arguments.pk
			};
			
			if(arguments.size GT 0)
				prop.size = arguments.size;
			if(len(arguments.alias))
				prop.alias = arguments.alias;
			if(arguments.pk)
				variables.pkColumn = arguments.property;
			if(len(arguments.defaultSort))
				variables.defaultSort = listappend(variables.defaultSort, arguments.property);
			
			if(structKeyExists(variables, "_addingJoinTable"))
				variables.joinTables[variables._addingJoinTable].properties[arguments.property] = prop;
			else
				variables.properties[arguments.property] = prop;
		</cfscript>
	</cffunction>
	
	<cffunction name="addRelation" output="false" access="private" returntype="void">
		<cfargument name="table" type="String" required="true">
		<cfargument name="relationship" type="String" required="true">
		<cfargument name="pk" type="String" required="true">
		<cfargument name="fk" type="String" required="true">
		<cfargument name="joinType" type="String" required="false" default="INNER">
		<cfargument name="propertyPrefix" type="String" required="false" default="">
		<cfargument name="name" type="String" required="false" default="#arguments.table#">
		<cfargument name="lazy" type="String" required="false" default="false">
		<cfargument name="linkTable" type="String" required="false" default="">
		<cfargument name="linkPk" type="String" required="false" default="">
		<cfargument name="linkFk" type="String" required="false" default="">
		
		<cfscript>
			// If we're already adding a relation, ignore this call
			if(structKeyExists(variables, "_addingJoinTable"))
				return;
			
			variables.joinTables[arguments.name] = {
				table=arguments.table,
				relationship=lcase(arguments.relationship),
				pk=arguments.pk,
				fk=arguments.fk,
				propertyPrefix=arguments.propertyPrefix,
				joinType=arguments.joinType,
				lazy=arguments.lazy,
				linkTable = arguments.linkTable,
				linkPk = arguments.linkPk,
				linkFk = arguments.linkFk
			};
			
			//Pull in columns from the joined table
			variables._addingJoinTable = arguments.name;
			loadEntityFile(arguments.table & ".cfm");
			structDelete(variables, "_addingJoinTable");
		</cfscript>
		
		
	</cffunction>
	
	<cffunction name="loadEntityFile" output="false" access="private" returntype="void">
		<cfargument name="file" type="String" required="true">
		
		<cfif fileexists(expandPath("_config/tables/#arguments.file#"))>
			<cfinclude template="../_config/tables/#arguments.file#">
		</cfif>
	</cffunction>
</cfcomponent>