<cfoutput>
   <cfform id="appSettings" name="appSettings" method="post" action="step2.cfm">
		<fieldset>
			<legend>Application Settings</legend>
              <ol>
				<li><cftooltip hideDelay="250" tooltip="Enter the ColdFusion datasource for this applications database"><img src="images/help.png"></cftooltip>Datasource Name 
					<cfinput type="text" name="dsn" id="dsn" required="true" message="Datasource is required" />
				<li>
				<li class="btn"><input type="submit" name="button" id="button" value="Next >>" /></li>
			  </ol>
		</fieldset>
	</cfform>
</cfoutput>
