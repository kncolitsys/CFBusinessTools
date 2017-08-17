<cfparam name="author" type="string" default="">
<cfparam name="dsn" type="string" default="">
<cfparam name="linkType" type="string" default="useTextLinks">
<cfparam name="useRTE" type="boolean" default="false">
<cfparam name="table" type="string" default="">
<cfparam name="section" type="string" default="">

<cfset rootPath = #expandpath("../../.")#>

<cfif find(rootPath, "/") GT 0>
	<cfset slash = "/">
<cfelse>
	<cfset slash = "\">
</cfif>

<cfinclude template="udf/directoryCopy.cfm">

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>CF/1 Application Generator </title>
        <link href="style.css" rel="stylesheet" type="text/css" />
</head>
    <body>
		<div id="container">
			<div id="cfWindowHeader">
				<div id="cfWindowLogo">&nbsp;</div>
			</div>
			<div id="cfWindowContent">
				<h2>Copying Directory Structure</h2>

				<cfif NOT DirectoryExists( ExpandPath( "..#slash#..#slash#_config" ) )
					  AND NOT DirectoryExists( ExpandPath( "..#slash#..#slash#controllers" ) )
					  AND NOT DirectoryExists( ExpandPath( "..#slash#..#slash#daos" ) )
					  AND NOT DirectoryExists( ExpandPath( "..#slash#..#slash#layouts" ) )
					  AND NOT DirectoryExists( ExpandPath( "..#slash#..#slash#services" ) )
					  AND NOT DirectoryExists( ExpandPath( "..#slash#..#slash#models" ) )
					  AND NOT DirectoryExists( ExpandPath( "..#slash#..#slash#views" ) )
					  >
					<cfset directoryCopy(ExpandPath( "frameworkfiles" ), ExpandPath( "..#slash#..#slash#" )) />
					Base directory structure and files were copied to the root folder.<br />
				<cfelse>
					Base directory structure seem to exists.  Directory copy aborted.
				</cfif>
				
				<cfif NOT DirectoryExists( ExpandPath( "..#slash#..#slash#views#slash##section#" ) )>
					<cfdirectory action="create" directory="#rootPath##slash#views#slash##section#">
					<cfoutput>#section#</cfoutput> directory was created under views.<br />
				<cfelse>
					<cfoutput>#section#</cfoutput> directory already existed under views.<br />
				</cfif>
				<br/><br/>
				<h2>Writing Files to the System</h2>
					
				<cfif #table# EQ "all">
					<cfdbinfo datasource="#dsn#" name="raw" type="tables" />
					<cfquery dbtype="query" name="filtered" >
						select *
						from raw
						where table_type like 'TABLE'
					</cfquery>
					<cfloop query="filtered">
					<cfset table = #table_name#>
					<cfset generator = CreateObject("component", "generator").init(#author#,#table#,#dsn#,#linkType#,#useRTE#,#section#) />
					<cfset generateController = generator.generateController() />
					<cfset generateForm = generator.generateForm() />
					<cfset generateDataTable = generator.generateDataTable() />
					<cfset generateApplicationCFC = generator.generateApplicationCFC() />
					<cfset generateTableConfig = generator.generateTableConfig() />
					<cfset generateServiceGetSet = generator.generateServiceGetSet() />
					<cfset generateServiceAction = generator.generateServiceAction() />
					<cfset generateBeanXmlDAO = generator.generateBeanXmlDAO() />
					<cfset generateBeanXmlService = generator.generateBeanXmlService() />
	                
	                <!--- Base Section.CFC in Controllers Folder --->    
					<cfif FileExists( ExpandPath( "..#slash#..#slash#controllers#slash##section#.cfc" ) )>
	                    <cfoutput>#section#.cfc in the controllers folder already existed so the base template was not created.<br /></cfoutput>
	                <cfelse>
	                    <cfoutput>#section#.cfc in the controllers folder has been created.<br /></cfoutput>
	                    <cffile action="write" file="#rootPath##slash#controllers#slash##section#.cfc" output="#generateController#" nameconflict="skip">
	                </cfif>
	                
	                <!--- Form in Views Folder --->    
					<cfif FileExists( ExpandPath( "..#slash#..#slash#views#slash##section##slash##table#Form.cfm" ) )>
	                    <cfoutput>#table#Form.cfm already existed in the views/#section# folder.  Please manually remove this file if you want it replaced.<br /></cfoutput>
	                <cfelse>
	                    <cfoutput>#table#Form.cfm has been created in the views/#section# folder.<br /></cfoutput>
						<cfset generateForm =  replaceList(generateForm,"%,^","##,'") />
	                    <cffile action="write" file="#rootPath##slash#views#slash##section##slash##table#Form.cfm" output="#generateForm#" nameconflict="skip">
	                </cfif>
	                
	                <!--- Data Table in Views Folder --->                            
	                <cfif FileExists( ExpandPath( "..#slash#..#slash#views#slash##section##slash##table#.cfm" ) )>
	                    <cfoutput>#table#.cfm already existed in the views/#section# folder.  Please manually remove this file if you want it replaced.<br /></cfoutput>
	                <cfelse>
	                    <cfoutput>#table#.cfm has been created in the views/#section# folder.<br /></cfoutput>
						<cfset generateDataTable =  replaceList(generateDataTable,"%,^","##,'") />
	                    <cffile action="write" file="#rootPath##slash#views#slash##section##slash##table#.cfm" output="#generateDataTable#" nameconflict="skip">
	                </cfif>
	                
	                <!--- Application.cfc --->    
	                <cfif FileExists( ExpandPath( "..#slash#..#slash#Application.cfc" ) )>
	                    <cfoutput>Application.cfc already existed.  Please manually remove this file if you want it replaced.<br /></cfoutput>
	                <cfelse>
	                    <cfif NOT FileExists( ExpandPath( "..#slash#..#slash#Application.cfc" ) )>
	                        <cfoutput>Application.cfc has been created.<br /></cfoutput>
	                        <cfset generateApplicationCFC =  replaceList(generateApplicationCFC,"%,^","##,'") />
	                        <cffile action="write" file="#rootPath##slash#Application.cfc" output="#generateApplicationCFC#" nameconflict="skip">
	                    </cfif>
	                </cfif>
	                
	                <!--- Insert DB Table in the _config/Tables Folder --->
	                <cfif FileExists( ExpandPath( "..#slash#..#slash#_config#slash#tables#slash##table#.cfm" ) )>
	                    <cfoutput>#table#.cfm located in the _config/tables folder already existed.  Please manually remove this file if you want it replaced.<br /></cfoutput>
	                <cfelse>
	                    <cfif NOT FileExists( ExpandPath( "..#slash#..#slash#_config#slash#tables#slash##table#.cfm" ) )>
	                        <cfoutput>#table#.cfm located in the _config/tables has been created.<br /></cfoutput>
	                        <cffile action="write" file="#rootPath##slash#_config#slash#tables#slash##table#.cfm" output="#generateTableConfig#" nameconflict="skip">
	                    </cfif>
	                </cfif>            
	                
	                <!--- Insert Getter/Setter into Controller Section.cfc --->
	                <cfset filePath = expandPath( "..#slash#..#slash#controllers#slash##section#.cfc" ) />
	                <cffile action="read" file="#filePath#" variable="datafile">
					<cfset setVar = 'set' & #table# & 'Service'/>
					
					<cfif find(setVar, datafile)>
						<cfoutput>Getter/Setter for #table# exists in the #section#.cfc controller.  Write operation for Getter/Setter was skipped.<br /></cfoutput>
					<cfelse>
						<cfset insPos = find('Get/Set: Insertion Point', dataFile) - 12>
						<cfset insText = insert(generateServiceGetSet, dataFile, insPos)>
						<cffile action="write" file="#rootPath##slash#controllers#slash##section#.cfc" output="#insText#" nameconflict="overwrite">
						<cfoutput>Getter/Setter for #table# has been added to the #section#.cfc controller.<br /></cfoutput>
	                </cfif>
	                
	                <!--- Insert Create Action into Controller Section.cfc --->
	                <cfset filePath = expandPath( "..#slash#..#slash#controllers#slash##section#.cfc" ) />
	                <cffile action="read" file="#filePath#" variable="datafile">
					<cfset setVar = 'name="#table#"'/>
					
					<cfif find(setVar, datafile)>
						<cfoutput>Action for #table# exists in the #section#.cfc controller.  Write operation for Action was skipped.<br /></cfoutput>
					<cfelse>
						<cfset insPos = find('Action Services: Insertion Point', dataFile) - 12>
						<cfset generateServiceAction =  replaceList(generateServiceAction,"%,^","##,'") />
						<cfset insText = insert(generateServiceAction, dataFile, insPos)>
						<cffile action="write" file="#rootPath##slash#controllers#slash##section#.cfc" output="#insText#" nameconflict="overwrite">
						<cfoutput>Action for #table# has been added to the #section#.cfc controller.<br /></cfoutput>
	                </cfif> 
	                
	                <!--- Insert DAO commands into Bean.xml.cfm --->
	                <cfset filePath = expandPath( "..#slash#..#slash#_config#slash#beans.xml.cfm" ) />
	                <cffile action="read" file="#filePath#" variable="datafile">
					<cfset setVar = '#table#DAO'/>
					
					<cfif find(setVar, datafile)>
						<cfoutput>DAO action for #table# exists in the beans.xml.cfm file.  Write operation for DAO action was skipped.<br /></cfoutput>
					<cfelse>
						<cfset insPos = find('DAO: Insertion Point', dataFile) - 12>
						<cfset insText = insert(generateBeanXmlDAO, dataFile, insPos)>
						<cffile action="write" file="#rootPath##slash#_config#slash#beans.xml.cfm" output="#insText#" nameconflict="overwrite">
						<cfoutput>DAO action for #table# has been added to the beans.xml.cfm file.<br /></cfoutput>
	                </cfif> 
	                       
	                <!--- Insert Service commands into Bean.xml.cfm --->
	                <cfset filePath = expandPath( "..#slash#..#slash#_config#slash#beans.xml.cfm" ) />
	                <cffile action="read" file="#filePath#" variable="datafile">
					<cfset setVar = '#table#Service'/>
					
					<cfif find(setVar, datafile)>
						<cfoutput>Services action for #table# exists in the beans.xml.cfm file.  Write operation for Service action was skipped.<br /></cfoutput>
					<cfelse>
						<cfset insPos = find('Services: Insertion Point', dataFile) - 12>
						<cfset insText = insert(generateBeanXmlService, dataFile, insPos)>
						<cffile action="write" file="#rootPath##slash#_config#slash#beans.xml.cfm" output="#insText#" nameconflict="overwrite">
						<cfoutput>Services action for #table# has been added to the beans.xml.cfm file.<br /></cfoutput>
	                </cfif>			
				</cfloop>
				
				<cfelse>
	                               
					<cfset generator = CreateObject("component", "generator").init(#author#,#table#,#dsn#,#linkType#,#useRTE#,#section#) />
					<cfset generateController = generator.generateController() />
					<cfset generateForm = generator.generateForm() />
					<cfset generateDataTable = generator.generateDataTable() />
					<cfset generateApplicationCFC = generator.generateApplicationCFC() />
					<cfset generateTableConfig = generator.generateTableConfig() />
					<cfset generateServiceGetSet = generator.generateServiceGetSet() />
					<cfset generateServiceAction = generator.generateServiceAction() />
					<cfset generateBeanXmlDAO = generator.generateBeanXmlDAO() />
					<cfset generateBeanXmlService = generator.generateBeanXmlService() />
	                
	                <!--- Base Section.CFC in Controllers Folder --->    
					<cfif FileExists( ExpandPath( "..#slash#..#slash#controllers#slash##section#.cfc" ) )>
	                    <cfoutput>#section#.cfc in the controllers folder already existed so the base template was not created.<br /></cfoutput>
	                <cfelse>
	                    <cfoutput>#section#.cfc in the controllers folder has been created.<br /></cfoutput>
	                    <cffile action="write" file="#rootPath##slash#controllers#slash##section#.cfc" output="#generateController#" nameconflict="skip">
	                </cfif>
	                
	                <!--- Form in Views Folder --->    
					<cfif FileExists( ExpandPath( "..#slash#..#slash#views#slash##section##slash##table#Form.cfm" ) )>
	                    <cfoutput>#table#Form.cfm already existed in the views/#section# folder.  Please manually remove this file if you want it replaced.<br /></cfoutput>
	                <cfelse>
	                    <cfoutput>#table#Form.cfm has been created in the views/#section# folder.<br /></cfoutput>
						<cfset generateForm =  replaceList(generateForm,"%,^","##,'") />
	                    <cffile action="write" file="#rootPath##slash#views#slash##section##slash##table#Form.cfm" output="#generateForm#" nameconflict="skip">
	                </cfif>
	                
	                <!--- Data Table in Views Folder --->                            
	                <cfif FileExists( ExpandPath( "..#slash#..#slash#views#slash##section##slash##table#.cfm" ) )>
	                    <cfoutput>#table#.cfm already existed in the views/#section# folder.  Please manually remove this file if you want it replaced.<br /></cfoutput>
	                <cfelse>
	                    <cfoutput>#table#.cfm has been created in the views/#section# folder.<br /></cfoutput>
						<cfset generateDataTable =  replaceList(generateDataTable,"%,^","##,'") />
	                    <cffile action="write" file="#rootPath##slash#views#slash##section##slash##table#.cfm" output="#generateDataTable#" nameconflict="skip">
	                </cfif>
	                
	                <!--- Application.cfc --->    
	                <cfif FileExists( ExpandPath( "..#slash#..#slash#Application.cfc" ) )>
	                    <cfoutput>Application.cfc already existed.  Please manually remove this file if you want it replaced.<br /></cfoutput>
	                <cfelse>
	                    <cfif NOT FileExists( ExpandPath( "..#slash#..#slash#Application.cfc" ) )>
	                        <cfoutput>Application.cfc has been created.<br /></cfoutput>
	                        <cfset generateApplicationCFC =  replaceList(generateApplicationCFC,"%,^","##,'") />
	                        <cffile action="write" file="#rootPath##slash#Application.cfc" output="#generateApplicationCFC#" nameconflict="skip">
	                    </cfif>
	                </cfif>
	                
	                <!--- Insert DB Table in the _config/Tables Folder --->
	                <cfif FileExists( ExpandPath( "..#slash#..#slash#_config#slash#tables#slash##table#.cfm" ) )>
	                    <cfoutput>#table#.cfm located in the _config/tables folder already existed.  Please manually remove this file if you want it replaced.<br /></cfoutput>
	                <cfelse>
	                    <cfif NOT FileExists( ExpandPath( "..#slash#..#slash#_config#slash#tables#slash##table#.cfm" ) )>
	                        <cfoutput>#table#.cfm located in the _config/tables has been created.<br /></cfoutput>
	                        <cffile action="write" file="#rootPath##slash#_config#slash#tables#slash##table#.cfm" output="#generateTableConfig#" nameconflict="skip">
	                    </cfif>
	                </cfif>            
	                
	                <!--- Insert Getter/Setter into Controller Section.cfc --->
	                <cfset filePath = expandPath( "..#slash#..#slash#controllers#slash##section#.cfc" ) />
	                <cffile action="read" file="#filePath#" variable="datafile">
					<cfset setVar = 'set' & #table# & 'Service'/>
					
					<cfif find(setVar, datafile)>
						<cfoutput>Getter/Setter for #table# exists in the #section#.cfc controller.  Write operation for Getter/Setter was skipped.<br /></cfoutput>
					<cfelse>
						<cfset insPos = find('Get/Set: Insertion Point', dataFile) - 12>
						<cfset insText = insert(generateServiceGetSet, dataFile, insPos)>
						<cffile action="write" file="#rootPath##slash#controllers#slash##section#.cfc" output="#insText#" nameconflict="overwrite">
						<cfoutput>Getter/Setter for #table# has been added to the #section#.cfc controller.<br /></cfoutput>
	                </cfif>
	                
	                <!--- Insert Create Action into Controller Section.cfc --->
	                <cfset filePath = expandPath( "..#slash#..#slash#controllers#slash##section#.cfc" ) />
	                <cffile action="read" file="#filePath#" variable="datafile">
					<cfset setVar = 'name="#table#"'/>
					
					<cfif find(setVar, datafile)>
						<cfoutput>Action for #table# exists in the #section#.cfc controller.  Write operation for Action was skipped.<br /></cfoutput>
					<cfelse>
						<cfset insPos = find('Action Services: Insertion Point', dataFile) - 12>
						<cfset generateServiceAction =  replaceList(generateServiceAction,"%,^","##,'") />
						<cfset insText = insert(generateServiceAction, dataFile, insPos)>
						<cffile action="write" file="#rootPath##slash#controllers#slash##section#.cfc" output="#insText#" nameconflict="overwrite">
						<cfoutput>Action for #table# has been added to the #section#.cfc controller.<br /></cfoutput>
	                </cfif> 
	                
	                <!--- Insert DAO commands into Bean.xml.cfm --->
	                <cfset filePath = expandPath( "..#slash#..#slash#_config#slash#beans.xml.cfm" ) />
	                <cffile action="read" file="#filePath#" variable="datafile">
					<cfset setVar = '#table#DAO'/>
					
					<cfif find(setVar, datafile)>
						<cfoutput>DAO action for #table# exists in the beans.xml.cfm file.  Write operation for DAO action was skipped.<br /></cfoutput>
					<cfelse>
						<cfset insPos = find('DAO: Insertion Point', dataFile) - 12>
						<cfset insText = insert(generateBeanXmlDAO, dataFile, insPos)>
						<cffile action="write" file="#rootPath##slash#_config#slash#beans.xml.cfm" output="#insText#" nameconflict="overwrite">
						<cfoutput>DAO action for #table# has been added to the beans.xml.cfm file.<br /></cfoutput>
	                </cfif> 
	                       
	                <!--- Insert Service commands into Bean.xml.cfm --->
	                <cfset filePath = expandPath( "..#slash#..#slash#_config#slash#beans.xml.cfm" ) />
	                <cffile action="read" file="#filePath#" variable="datafile">
					<cfset setVar = '#table#Service'/>
					
					<cfif find(setVar, datafile)>
						<cfoutput>Services action for #table# exists in the beans.xml.cfm file.  Write operation for Service action was skipped.<br /></cfoutput>
					<cfelse>
						<cfset insPos = find('Services: Insertion Point', dataFile) - 12>
						<cfset insText = insert(generateBeanXmlService, dataFile, insPos)>
						<cffile action="write" file="#rootPath##slash#_config#slash#beans.xml.cfm" output="#insText#" nameconflict="overwrite">
						<cfoutput>Services action for #table# has been added to the beans.xml.cfm file.<br /></cfoutput>
	                </cfif>
				</cfif>
			</div>
			<div id="footer"&nbsp;</div>
		</div>
    </body>
</html>