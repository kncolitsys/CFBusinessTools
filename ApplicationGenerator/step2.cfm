<cfparam name="author" type="string" default="">
<cfparam name="dsn" type="string" default="">
<cfparam name="linkType" type="string" default="useTextLinks">
<cfparam name="useRTE" type="boolean" default="false">
<cfparam name="section" type="string" default="">

<cfoutput>
   <cfform id="appSettings" name="appSettings" method="post" action="step3.cfm">
   	   <fieldset>
			<legend>Table</legend>
              <ol>
				<cfdbinfo datasource="#dsn#" name="raw" type="tables" />
				<cfquery dbtype="query" name="filtered" >
					select *
					from raw
					where table_type like 'TABLE'
				</cfquery>
				<li><cftooltip autoDismissDelay="0" tooltip="Select the table for which you want to create CRUD code"><img src="images/help.png"></cftooltip>Table Name&nbsp;
					<cfselect name="table" query="filtered" value="TABLE_NAME">
						<option value="all">All Tables</option>
					</cfselect>
				</li>
				<input type="hidden" name="author" value="#author#">
				<input type="hidden" name="dsn" value="#dsn#">
				<input type="hidden" name="linkType" value="#linkType#">
				<input type="hidden" name="useRTE" value="#useRTE#">
				<input type="hidden" name="section" value="#section#">
				<li class="btn"><input type="submit" name="button" id="button" value="Next >>" /></li>
			  </ol>
		</fieldset>
	</cfform>
</cfoutput>