<cfcomponent output="false">
	
	<cfset this.name = "" />
	<cfset this.version = "" />
	<cfset this.sessionmanagement = true />
	<cfset this.username = "admin" />
	<cfset this.password = "password" />

	<cffunction name="onApplicationStart">
	    <cfset APPLICATION.name = "Database Schema Generator">
	    <cfset APPLICATION.version = "1.0">
	</cffunction>
	
	<cffunction name="onRequestStart" returntype="void">		
		<cfif structKeyExists(url,'reload')>
  			<cfset OnApplicationStart() />
		</cfif>
		
		<cfif isDefined('Form.Username') AND isDefined('Form.Password')>
			<cfif #Form.Username# EQ #this.username# AND #Form.Password# EQ #this.password#>
				<cfset Session.Authenticated = true />
			<cfelse>
				<cflocation url="index.cfm?loginError=true" addtoken="false" />
			</cfif>
		<cfelseif NOT #listLast(cgi.script_name, "/")# EQ "index.cfm" AND NOT IsDefined('Session.Authenticated')>
			<cflocation url="index.cfm?mustLogin=true" addtoken="false" />
		</cfif>
		
		<cfif NOT #listLast(cgi.script_name, "/")# EQ "printschema.cfm">
			<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			<html xmlns="http://www.w3.org/1999/xhtml">
			    <head>
			        <title>Schema Generator </title>
			        <link href="style.css" rel="stylesheet" type="text/css" />
				</head>
			    <body>
					<div id="container">
						<div id="header">
							<div id="logo">&nbsp;</div>
						</div>
						<div id="subheading">
							Schema Settings
						</div>
				            
							<div id="content">
		</cfif>
	</cffunction>
	
	<cffunction name="onRequestEnd" returntype="void">
		<cfif NOT #listLast(cgi.script_name, "/")# EQ "step4write.cfm">
								</div>
						<div id="footer">&nbsp;</div>
					</div>
			    </body>
			</html>
		</cfif>
	</cffunction>
	
</cfcomponent>


