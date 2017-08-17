<cfcomponent>

<!--- constructor --->
<cffunction name="init" access="public" output="false" returntype="any" hint="Constructor for this cfc">
	<!--- take form input as arguments --->
	<cfargument name="author" type="string" required="true">
	<cfargument name="gitlog" type="string" required="true">
	
	<!--- set arguments into the variables scope so they can be used throughout the cfc --->
	<cfset variables.author = arguments.author/>
	<cfset variables.gitlog = arguments.gitlog />

	<!--- return this cfc --->
	<cfreturn this/>
</cffunction>

<!--- Get Author Records --->
<cffunction name="getAuthorRecords" displayname="Get Author Records" hint="Return query of authors commit information" output="false" returntype="query">
	<cfset columnNames = "author,date,time,message">
	<cfset var gitQuery = QueryNew(columnNames)>
	<cfset messageRecord = "">
	<cfset authorRecord = false>
	<cfset authorNameContinue=false>
	<cfset dateTimeContinue = false>
	
	<cfloop index="line" list="#variables.gitlog#" delimiters="#chr(10)##chr(13)#">
		<cfif find("Author", line) NEQ 0>
			<cfset authorFirst = mid(line, 9, len(rtrim(line)))>
			<cfif find(' ', authorFirst) EQ 0>
				<cfset authorNameContinue=true>
			<cfelse>
				<cfset authorName = authorFirst>
				<cfif authorName EQ #variables.author#>
					<cfset authorRecord = true>
					<cfset authorNameContinue=false>
				</cfif>
			</cfif>
		<cfelseif #authorNameContinue# EQ true >
			<cfset authorName = authorFirst & " " & ltrim(rtrim(line))>
			<cfif authorName EQ #variables.author#>
				<cfset authorRecord = true>
				<cfset authorNameContinue=false>
			</cfif>
		<cfelseif authorRecord EQ true AND find("Date", line) NEQ 0>
			<cfset dateRecord = mid(line, 7, len(rtrim(line)))>
			<cfset dateTimeContinue = true>
		<cfelseif authorRecord EQ true AND dateTimeContinue EQ true>
			<cfset timeRecord = ltrim(rtrim(line))>
			<cfset dateTimeContinue = false>
		<cfelseif authorRecord EQ true AND find("Message", line) NEQ 0>
			<cfset messageContinue = true>
		<cfelseif authorRecord EQ true and find("Signed-off-by", line) NEQ 0>
			<cfset QueryAddRow(gitQuery)>
			<cfset QuerySetCell(gitQuery, "author", authorName)>
			<cfset QuerySetCell(gitQuery, "date", dateRecord)>
			<cfset QuerySetCell(gitQuery, "time", timeRecord)>
			<cfset QuerySetCell(gitQuery, "message", messageRecord)>
			<cfset messageContinue = false>
			<cfset authorRecord = false>
			<cfset messageRecord = "">
		<cfelseif authorRecord EQ true AND messageContinue EQ true>
			<cfset messageRecord = messageRecord & " " & ltrim(rtrim(line))>
		</cfif>	
	</cfloop>
	
	<cfreturn gitQuery/>
</cffunction>

<cffunction name="getRecords" returntype="query">
	<cfset columnNames = "line">
	<cfset var query = QueryNew(columnNames)>
	
	<cfloop index="line" list="#variables.gitlog#" delimiters="#chr(10)##chr(13)#">
		
		<cfset QueryAddRow(query)>
		<cfset QuerySetCell(query, "line", line)>
			
	</cfloop>
	<cfreturn query/>
</cffunction>


</cfcomponent>