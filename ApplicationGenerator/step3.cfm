<cfparam name="author" type="string" default="">
<cfparam name="dsn" type="string" default="">
<cfparam name="linkType" type="string" default="useTextLinks">
<cfparam name="useRTE" type="boolean" default="false">
<cfparam name="section" type="string" default="">
<cfparam name="table" type="string" default="">

<cfif #table# EQ "all">
	<cfdbinfo datasource="#dsn#" name="raw" type="tables" />
	<cfquery dbtype="query" name="filtered" >
		select *
		from raw
		where table_type like 'TABLE'
	</cfquery>
	<cflayout type="accordion" name="generatedCode"style="background-color:##FFF;">
	    <cflayoutarea name="home" title="Home">
			<cfoutput>
				<ol>
					<li><img src="images/pencil.png" border="0"/> <a href="##" onclick="javascript:ColdFusion.Window.show('writeAllFiles')">Write ALL Files to Outer Folder</a></li>
				</ol>
			</cfoutput>
		</cflayoutarea>
		<cfloop query="filtered" >
			<cfset generator = CreateObject("component", "generator").init(#author#,#table_name#,#dsn#,#linkType#,#useRTE#,#section#) />
			<cfset tableColumns = generator.getColumns() />
			<cflayoutarea name="#table_name#" title="#table_name#">
				<br>
				<table border="0" width="600" cellpadding="5" cellspacing="0">
				   	<tr>
						<td colspan="5" align="center">
							<h2><cfoutput>#ucase(table_name)# Table Structure</cfoutput></h2>
						</td>	
					</tr>
					<tr>
						<th style="width:20px;"></th>
						<th>Column Name</td>
						<th>Data Type</td>
						<th>Column Size</td>
						<th>Is Nullable</td>
					</tr>
			       	<cfoutput query="tableColumns">
						<tr>
							<td></td>
							<td>#column_name#</td>
							<td>#type_name#</td>
							<td>#column_size#</td>
							<td>#is_nullable#</td>
						</tr>
		           </cfoutput>
		       </table>	
			   <br>
		    </cflayoutarea>
		</cfloop>
	</cflayout>
<cfelse>
	<cfset generator = CreateObject("component", "generator").init(#author#,#table#,#dsn#,#linkType#,#useRTE#,#section#) />
	<cfset tableColumns = generator.getColumns() />
	<cflayout type="tab" name="generatedCode" tabheight="500" style="background-color:##FFF;">
	    <cflayoutarea name="home" title="Home">
			<cfoutput>
				<ol>
					<li><img src="images/pencil.png" border="0"/> <a href="##" onclick="javascript:ColdFusion.Window.show('writeFiles')">Write Files to Outer Folder</a></li>
				</ol>
			</cfoutput>
			<br/>
	   	<table border="0" width="600" cellpadding="5" cellspacing="0">
		   	<tr>
				<td colspan="4" align="center">
					<h2><cfoutput>#ucase(table)# Table Structure</cfoutput></h2>
				</td>	
				</tr>
					<tr>
						<th>Column Name</td>
						<th>Data Type</td>
						<th>Column Size</td>
						<th>Is Nullable</td>
					</tr>
			       	<cfoutput query="tableColumns">
						<tr>
							<td>#column_name#</td>
							<td>#type_name#</td>
							<td>#column_size#</td>
							<td>#is_nullable#</td>
						</tr>
		           </cfoutput>
		       </table>
	    </cflayoutarea>
	    <cflayoutarea name="applicationcfc" title="ApplicationCFC" style="background-color:##FFF;">
	        <cfset getApplicationCFC = generator.generateApplicationCFC()>
			<cfset getApplicationCFC =  replaceList(getApplicationCFC,"%,^","##,'") />
			<cfoutput>
				<span style="color:##000099; font-weight:bold;">Click inside code box to select all</span>
				<textarea onclick="this.focus();this.select()" 
					style="font-size: 8pt; width: 100%;"
					wrap="hard" rows="33" name="linkNode">
						#getApplicationCFC#
					</textarea>
			</cfoutput>
	    </cflayoutarea>				    
	    <cflayoutarea name="controller" title="Controller" style="background-color:##FFF;">
	        <cfset getController = generator.generateController()>
			<cfset getController =  replaceList(getController,"<%,%,/@","&lt;,##,%") />
			<cfoutput>
				<span style="color:##000099; font-weight:bold;">Click inside code box to select all</span>
				<textarea onclick="this.focus();this.select()" 
					style="font-size: 8pt; width: 100%;"
					wrap="hard" rows="33" name="linkNode">
						#getController#
					</textarea>
			</cfoutput>
	    </cflayoutarea>
	    <cflayoutarea name="serviceGetSet" title="Service Get/Set" style="background-color:##FFF;">
	        <cfset getService = generator.generateServiceGetSet()>
			<cfoutput>
				<span style="color:##000099; font-weight:bold;">Click inside code box to select all</span>
				<textarea onclick="this.focus();this.select()" 
					style="font-size: 8pt; width: 100%;"
					wrap="hard" rows="33" name="linkNode">#getService#</textarea>
			</cfoutput>
	    </cflayoutarea>			
	    <cflayoutarea name="serviceAction" title="Service Action" style="background-color:##FFF;">
	        <cfset getAction = generator.generateServiceAction()>
			<cfset getAction =  replaceList(getAction,"%,^","##,'") />
			<cfoutput>
				<span style="color:##000099; font-weight:bold;">Click inside code box to select all</span>
				<textarea onclick="this.focus();this.select()" 
					style="font-size: 8pt; width: 100%;"
					wrap="hard" rows="33" name="linkNode">#getAction#</textarea>
			</cfoutput>
	    </cflayoutarea>	
	    <cflayoutarea name="tableConfig" title="Table Config" style="background-color:##FFF;">
	        <cfset getConfig = generator.generateTableConfig()>
			<cfoutput>
				<span style="color:##000099; font-weight:bold;">Click inside code box to select all</span>
				<textarea onclick="this.focus();this.select()" 
					style="font-size: 8pt; width: 100%;"
					wrap="hard" rows="33" name="linkNode">#getConfig#</textarea>
			</cfoutput>
	    </cflayoutarea>
	    <cflayoutarea name="beanDAO" title="Bean.xml DAO" style="background-color:##FFF;">
	        <cfset getBeanDAO = generator.generateBeanXmlDAO()>
			<cfoutput>
				<span style="color:##000099; font-weight:bold;">Click inside code box to select all</span>
				<textarea onclick="this.focus();this.select()" 
					style="font-size: 8pt; width: 100%;"
					wrap="hard" rows="33" name="linkNode">#getBeanDAO#</textarea>
			</cfoutput>
	    </cflayoutarea>	
	    <cflayoutarea name="BeanService" title="Bean.xml Service" style="background-color:##FFF;">
	        <cfset getBeanService = generator.generateBeanXmlService()>
			<cfoutput>
				<span style="color:##000099; font-weight:bold;">Click inside code box to select all</span>
				<textarea onclick="this.focus();this.select()" 
					style="font-size: 8pt; width: 100%;"
					wrap="hard" rows="33" name="linkNode">#getBeanService#</textarea>
			</cfoutput>
	    </cflayoutarea>				    			    				    	    
	    <cflayoutarea name="dataTable" title="Data Table" style="background-color:##FFF;">
	        <cfset getDataTable = generator.generateDataTable()>
			<cfset getDataTable =  replaceList(getDataTable,"%,^","##,'") />
			<cfoutput>
				<span style="color:##000099; font-weight:bold;">Click inside code box to select all</span>
				<textarea onclick="this.focus();this.select()" 
					style="font-size: 8pt; width: 100%;"
					wrap="hard" rows="33" name="linkNode">
						#getDataTable#
					</textarea>
			</cfoutput>
	    </cflayoutarea>
	    <cflayoutarea name="form" title="Form" style="background-color:##FFF;">
	        <cfset getForm = generator.generateForm()>
			<cfset getForm =  replaceList(getForm,"%,^","##,'") />
			<cfoutput>
				<span style="color:##000099; font-weight:bold;">Click inside code box to select all</span>
				<textarea onclick="this.focus();this.select()" 
					style="font-size: 8pt; width: 100%;"
					wrap="hard" rows="33" name="linkNode">
						#getForm#
					</textarea>
			</cfoutput>
	    </cflayoutarea>
	</cflayout>
</cfif>

<cfwindow width="500" height="465" name="writeFiles" x="20" y="20" center="true" draggable="true" modal="true" resizable="false" initshow="false" 
title="Writing Files to System" source="step4write.cfm?author=#author#&dsn=#dsn#&table=#table#&linkType=#linkType#&useRTE=#useRTE#&section=#section#" />

<cfwindow width="500" height="465" name="writeAllFiles" x="20" y="20" center="true" draggable="true" modal="true" resizable="false" initshow="false" 
title="Writing Files to System" source="step4write.cfm?author=#author#&dsn=#dsn#&table=all&linkType=#linkType#&useRTE=#useRTE#&section=#section#" />