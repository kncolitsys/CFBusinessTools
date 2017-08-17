<cfcomponent name="BaseIBO" hint="I am the base business object (IBO) class." output="no">

<cffunction name="init" output="false" returntype="any">
	<cfargument name="GettableProperties" type="string" required="false" default="*" hint="A comma delimited list of instance properties that should be gettable. Defaults to * for all.">
	<cfargument name="SettableProperties" type="string" required="false" default="*" hint="A comma delimited list of instance properties that should be settable. Defaults to * for all.">
	<cfargument name="GettableClassProperties" type="string" required="false" default="*" hint="A comma delimited list of class properties that should be gettable. Defaults to * for all.">
	<cfargument name="SettableClassProperties" type="string" required="false" default="*" hint="A comma delimited list of class properties that should be settable. Defaults to '' for none.">
	<cfscript>
		variables.GettableProperties = arguments.GettableProperties;
		variables.SettableProperties = arguments.SettableProperties;
		variables.GettableClassProperties = arguments.GettableClassProperties;
		variables.SettableClassProperties = arguments.SettableClassProperties;
		variables.IteratorRecord = 0;
		variables.NumberofRecords = 0;
		// Create a structure for storing data values within the object
		variables.Data = StructNew();
		variables.Data.Instance = StructNew();
		variables.Data.Class = StructNew();
		variables.Data.Instance[0] = StructNew();
		//Super.Init(argumentsCollection=Arguments);
		variables.FailQuietlyonGet = true;
	</cfscript>
	<cfreturn THIS>
</cffunction>

<cffunction name="add" returntype="void" hint="I add a new record to an IBO ready to be loaded." output="false">
	<cfscript>
		IteratorRecord = NumberofRecords + 1;
		NumberofRecords = NumberofRecords + 1;
		variables.Data.Instance[IteratorRecord] = StructNew();
	</cfscript>
</cffunction>

<cffunction name="asStruct" returntype="struct" access="public" output="false" hint="I return the object as a struct.">
	<cfreturn variables.Data.Instance[IteratorRecord]>
</cffunction>

<cffunction name="classGet" returntype="any" output="false" hint="If the property name is not in the GettableClassProperties list, and the list isn't set to '*' for all, it calls invalidAccess() and (if that doesn't throw or dump) returns an empty string to the caller. If the property name is gettable, if there is a custom getter, it calls it. If not it returns the value directly from Data.Class[PropertyName] if it exists (if it doesn't exist, it also calls invalidAccess()).">
	<cfargument name="PropertyName" type="string" required="true" hint="The name of the property to retrieve.">
	<cfscript>
		var ReturnValue = "";
		If (ListFindNoCase(GettableClassProperties, PropertyName) OR GettableClassProperties EQ "*")
		{
			If (StructKeyExists(variables, "classget#PropertyName#"))
			{
				// Custom getter exists - run it
				ReturnValue = evaluate("variables.classget#PropertyName#()");
			}
			Else
			{
				If (StructKeyExists(variables.Data.Class, PropertyName))
				{
					// Value exists, return it
					ReturnValue = variables.Data.Class[PropertyName];
				}
				Else
				{invalidAccess("classget", PropertyName, "It doesn't exist");};
			};
		}
		Else
		{invalidAccess("classget", PropertyName, "It isn't gettable (not included in GettableClassProperties - #GettableClassProperties#)).");};
	</cfscript>
	<cfreturn ReturnValue>
</cffunction>

<cffunction name="classSet" returntype="boolean" output="false" hint="If the property name is not in the SettableClassProperties list, and the list isn't set to '*' for all, it calls invalidAccess() and (if that doesn't throw or dump) returns an 'false' boolean to the caller. If the property name is settable, if there is a custom setter, it calls it. If not it sets the value directly at Data.Class[PropertyName].">
	<cfargument name="PropertyName" type="string" required="true" hint="The name of the property to retrieve.">
	<cfargument name="PropertyValue" type="any" required="true" hint="The value of the property to retrieve.">
	<cfscript>
		var ReturnValue = false;
		If (ListFindNoCase(SettableClassProperties, PropertyName) OR SettableClassProperties EQ "*")
		{
			If (StructKeyExists(variables, "classset#PropertyName#"))
			{
				// Custom setter exists - run it
				ReturnValue = evaluate("variables.classset#PropertyName#(PropertyValue)");
			}
			Else
			{
				variables.Data.Class[PropertyName] = PropertyValue;
				ReturnValue = true;
			};
		}
		Else
		{
			invalidAccess("classset", PropertyName, "It isn't settable (not included in SettableClassProperties - #SettableClassProperties#))).");
		};
	</cfscript>
	<cfreturn ReturnValue>
</cffunction>

<cffunction name="dump" returntype="void" hint="I provide cfdump/cfabort functionality within cfscript blocks." output="false">
	<cfargument name="VariabletoDump" required="true" type="any" hint="The variable to dump to the screen.">
	<cfdump var="#VariabletoDump#">
	<cfabort>
</cffunction>

<cffunction name="first" returntype="void" access="public" output="false" hint="I set the iterator to point to the first record so it is ready to access with the first record.">
	<cfset variables.IteratorRecord = 1>
</cffunction>

<cffunction name="get" returntype="any" output="false" hint="If the property name is not in the GettableProperties list, and the list isn't set to '*' for all, it calls invalidAccess() and (if that doesn't throw or dump) returns an empty string to the caller. If the property name is gettable, if there is a custom getter, it calls it. If not it returns the value directly from Data.Instance[IteratorRecord][PropertyName] if it exists (if it doesn't exist, it also calls invalidAccess()).">
	<cfargument name="PropertyName" type="string" required="true" hint="The name of the property to retrieve.">
	<cfscript>
		var ReturnValue = "";
		If (ListFindNoCase(GettableProperties, PropertyName) OR GettableProperties EQ "*")
		{
			If (StructKeyExists(variables, "get#PropertyName#"))
			{
				// Custom getter exists - run it
				ReturnValue = evaluate("variables.get#PropertyName#()");
			}
			Else
			{
				If (StructKeyExists(variables.Data.Instance[IteratorRecord], PropertyName))
				{
					// Value exists, return it
					ReturnValue = variables.Data.Instance[IteratorRecord][PropertyName];
				}
				Else
				{
					If(NOT FailQuietlyonGet)
					{invalidAccess("get", PropertyName, "It doesn't exist in instance #IteratorRecord#.");};
				};
			};
		}
		Else
		{invalidAccess("get", PropertyName, "It isn't gettable (not included in GettableProperties - #GettableProperties#).");};
	</cfscript>
	<cfreturn ReturnValue>
</cffunction>

<cffunction name="invalidAccess" returntype="void" output="false" hint="This method is called if you try to get or set an instance or class property that is not gettable/settable or doesn't exist. By default it throws an error.">
	<cfargument name="MethodName" required="true" type="string" hint="The name of the method having problem with access - get(), set(), classGet() or classSet().">
	<cfargument name="PropertyName" required="true" type="string" hint="The name of the property the method was unable to access.">
	<cfargument name="Problem" required="true" type="string" hint="The problem that the method had accessing the property.">
	<cfset throw("Getter/setter Error occurred trying to #MethodName# the #PropertyName# property. #Problem#")>
</cffunction>

<cffunction name="loadQuery" returntype="void" access="public" output="false" hint="I load a query into the IBO and then resets the iterator counter to 1.">
	<cfargument name="Recordset" type="query" required="yes" displayname="Recordset" hint="I am the query that needs to be loaded.">
	<cfscript>
	 	var theQuery = arguments.Recordset;
		var theStructure = StructNew();
		var cols = ListToArray(theQuery.columnlist);
		var row = 1;
		var thisRow = "";
		var col = 1;
		If (theQuery.recordcount LT 1)
		{	
			theStructure[row] = StructNew();
			THIS.Recordset = theStructure[row];
		}
		Else
		{
			for(row = 1; row LTE theQuery.recordcount; row = row + 1)
			{
				thisRow = StructNew();
				for(col = 1; col LTE arraylen(cols); col = col + 1)
				{
					thisRow[cols[col]] = theQuery[cols[col]][row];
				} 
				theStructure[row] = Duplicate(thisRow);
			}
			 
			THIS.Recordset = arguments.Recordset;
		};
		variables.Data.Instance = theStructure;
		variables.NumberofRecords = theQuery.recordcount;
		variables.IteratorRecord = 1;
		variables.ImportedPropertyNameList = theQuery.columnlist;
	</cfscript>
</cffunction>

<cffunction name="loadStruct" returntype="void" access="public" output="false" hint="I load a structure into the current instance being pointed to..">
	<cfargument name="Structure" type="struct" required="true" hint="I am the structure that needs to be loaded.">
	<cfargument name="Prefix" type="string" required="false" default="" hint="Optional prefix on all fields being passed in - if this is passed, ONLY set properties with this prefix.">
	<cfargument name="Override" type="boolean" required="false" default="true" hint="Whether to overload values if they already exist.">
	<cfscript>
		var KeyWithoutPrefix = "";
		var PrefixLength = Len(Prefix);
		For (key in arguments.Structure)
		{
			If (Len(Prefix) GT 0)
			{
			If (Left(Key, PrefixLength) EQ Prefix) 
			KeyWithoutPrefix = Right(Key, (Len(Key) - PrefixLength));
			If (Override OR NOT StructKeyExists(variables.Data.Instance[IteratorRecord], KeyWithoutPrefix))
			{variables.Data.Instance[IteratorRecord][KeyWithoutPrefix] = arguments.Structure[key];};
			}
			Else
			{
				If (Override OR NOT StructKeyExists(variables.Data.Instance[IteratorRecord], key))
				{variables.Data.Instance[IteratorRecord][key] = arguments.Structure[key];};
			};
		};
	</cfscript>
</cffunction>

<cffunction name="metaGet" output="false" returntype="string" hint="I get properties from the Metadata bean.">
	<cfargument name="PropertyName" type="string" required="true" hint="The name of the property to retrieve.">
	<cfreturn Metadata.get(PropertyName)>
</cffunction>

<cffunction name="next" returntype="boolean" access="public" output="false" hint="I increment the count of the iterator, returning success or failure as a boolean. If failure (already on final record), I leave the count the same.">
	<cfscript>
		var ReturnValue = "true";
		If (IteratorRecord GTE NumberofRecords)
		{	
			ReturnValue = False;
			IteratorRecord = NumberofRecords;
		}
		Else
		{IteratorRecord = IteratorRecord + 1;};
	</cfscript>
	<cfreturn ReturnValue>
</cffunction>

<cffunction name="recordCount" output="false" returntype="numeric" hint="I return the number of records currently loaded in the IBO.">
	<cfreturn NumberofRecords>
</cffunction>

<cffunction name="reset" returntype="void" access="public" output="false" hint="I set theiterator to point to before the first record so it is ready for a next() method to call the first record as part of the iterator functionality.">
	<cfset variables.IteratorRecord = 0>
</cffunction>

<cffunction name="set" returntype="boolean" output="false" hint="If the property name is not in the SettableProperties list, and the list isn't set to '*' for all, it calls invalidAccess() and (if that doesn't throw or dump) returns an 'false' boolean to the caller. If the property name is settable, if there is a custom setter, it calls it. If not it sets the value directly at Data.Instance[IteratorRecord][PropertyName].">
	<cfargument name="PropertyName" type="string" required="true" hint="The name of the property to retrieve.">
	<cfargument name="PropertyValue" type="any" required="true" hint="The value of the property to retrieve.">
	<cfscript>
		var ReturnValue = false;
		If (ListFindNoCase(SettableProperties, PropertyName) OR SettableProperties EQ "*")
		{
			If (StructKeyExists(variables, "set#PropertyName#"))
			{
				// Custom setter exists - run it
				ReturnValue = evaluate("variables.set#PropertyName#(PropertyValue)");
			}
			Else
			{
				variables.Data.Instance[IteratorRecord][PropertyName] = PropertyValue;
				ReturnValue = true;
			};
		}
		Else
		{
			invalidAccess("set", PropertyName, "It isn't settable (not included in SettableProperties - #SettableProperties#))");
		};
	</cfscript>
	<cfreturn ReturnValue>
</cffunction>

<cffunction name="throw" returntype="void" hint="I throw an error." output="false">
	<cfargument name="ErrorMessage" required="true" type="any" hint="The error to throw.">
	<cfthrow message="LIGHTBASE ERROR: #ErrorMessage#">
</cffunction>

<cffunction name="search" returntype="boolean" hint="I search the resultset and set the iterator to the found record and return true/false" output="false">
	<cfargument name="property" type="String" required="true">
	<cfargument name="value" type="String" required="true">
	<cfset var myList = arrayToList(THIS.Recordset[arguments.property])>
	<cfset var pos = listFind(myList, arguments.value)>
	
	<cfif pos GT 0>
		<cfset variables.iterator = pos>
		<cfreturn true>
	</cfif>
	
	<cfreturn false>
</cffunction>

<cffunction name="isEvenRecord" returntype="boolean" hint="I look at the iterator to see if it is an even number and return true/false" output="false">
	<cfreturn NOT bitAnd(variables.IteratorRecord, 1)>
</cffunction>

<cffunction name="currentRecord" returntype="boolean" hint="I return the iterator" output="false">
	<cfreturn variables.IteratorRecord>
</cffunction>

<cffunction name="isLast" returntype="boolean" hint="I look at the iterator to see if it at the end and return true/false" output="false">
	<cfreturn (variables.IteratorRecord EQ variables.NumberofRecords)>
</cffunction>

<cffunction name="getPropertyList" returntype="String" output="false">
	<cfreturn structKeyList(variables.Data.Instance[IteratorRecord])>
</cffunction>

</cfcomponent>