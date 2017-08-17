<cfcomponent output="false">
	
	<cfset this.name = "" />
	<cfset this.version = "" />
	<cfset this.sessionmanagement = true />
	<cfset this.username = "admin" />
	<cfset this.password = "password" />

	<cffunction name="onApplicationStart">
	    <cfset APPLICATION.name = "Business Tools">
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
		
		<cfif #listfind("step4write.cfm, printschema.cfm", listLast(cgi.script_name, "/"))# EQ 0>
			<cfoutput>
				<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
				<html xmlns="http://www.w3.org/1999/xhtml">
				    <head>
				        <title>#APPLICATION.name#</title>
						<link rel="shortcut icon" href="assets/images/favicon.ico">
				        <link href="assets/css/style.css" rel="stylesheet" type="text/css" />
						<script language="JavaScript" type="text/javascript" src="assets/js/jquery-1.5.2.min.js"></script>
					</head>
				    <body>
						<div id="container">
							<div id="header">
								<div id="logo">&nbsp;</div>
							</div>
							<div id="subheading">
								#APPLICATION.name#
							</div>
									            
							<div id="content">
			</cfoutput>
		</cfif>
	</cffunction>
	
	<cffunction name="onRequestEnd" returntype="void">
		<cfif #listfind("step4write.cfm, printschema.cfm", listLast(cgi.script_name, "/"))# EQ 0>
						</div>
						<div id="footer">&nbsp;</div>
					</div>
			    </body>
			</html>
		</cfif>
	</cffunction>
	
</cfcomponent>


