<cfparam name="dsn" type="string" default="">

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
						<option value="All">All Tables</option>
					</cfselect>
				</li>
				<input type="hidden" name="dsn" value="#dsn#">
				<li class="btn"><input type="submit" name="button" id="button" value="Next >>" /></li>
			  </ol>
		</fieldset>
	</cfform>
</cfoutput>