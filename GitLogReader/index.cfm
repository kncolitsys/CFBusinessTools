<cfoutput>
   <cfform id="appSettings" name="appSettings" method="post" action="step2.cfm">
		<fieldset>
			<legend>Git Log Information</legend>
              <ol>
				<li><cftooltip hideDelay="250" tooltip="Enter the Authors Name as it appears in the Git Logs"><img src="images/help.png"></cftooltip>Authors Name 
					<cfinput type="text" name="author" id="author" required="true" message="Authors name is required" />
				<li>
				<li><cftooltip hideDelay="250" tooltip="Copy and paste the Git log file here"><img src="images/help.png"></cftooltip>Git Log File <br>
					<cftextarea wrap="hard" name="gitLog" id="gitlog" style="width:750px; height:400px;" required="true" message="Git Log is required"></cftextarea>
				<li>
				<li class="btn"><input type="submit" name="button" id="button" value="Next >>" /></li>
			  </ol>
		</fieldset>
	</cfform>
</cfoutput>
