<cfoutput>
   <cfform id="appSettings" name="appSettings" method="post" action="step2.cfm">
		<fieldset>
			<legend>Application Settings</legend>
              <ol>
				<li><cftooltip hideDelay="250" tooltip="Enter the ColdFusion datasource for this applications database"><img src="images/help.png"></cftooltip>Datasource Name 
					<cfinput type="text" name="dsn" id="dsn" required="true" message="Datasource is required" />
				<li>
			    <li><cftooltip hideDelay="250" tooltip="Do you want to use text or graphic links (images for the graphics can be downloaded from a later screen)"><img src="images/help.png"></cftooltip>Which types of links would you like to use?
					<li class="sub"><input name="linkType" type="radio" id="useGraphicLinks" value="useGraphicLinks"  checked="checked" /> Use Graphic Links</li>
					<li class="sub"><input name="linkType" type="radio" id="useTextLinks" value="useTextLinks" /> Use Text Links</li>

				</li>
				<li><cftooltip hideDelay="250" tooltip="You can use the richtext feature of the textarea fields"><img src="images/help.png"></cftooltip>Do you want to use rich text areas for longer input fields or a plain text area?
					<li class="sub"><input type="radio" name="useRTE" id="useRTE" value="false" checked="checked" /> No, use a plan textarea field</li>
					<li class="sub"><input type="radio" name="useRTE" id="useRTE" value="true"  /> Yes, use RTE on textarea fields</li>
				</li>
				<li><cftooltip hideDelay="250" tooltip="Enter name of section for FW/1 structure"><img src="images/help.png"></cftooltip>Section Name 
					<cfinput type="text" name="section" id="section" required="true" message="Section Name is required" />
				<li>
				<li class="btn"><input type="submit" name="button" id="button" value="Next >>" /></li>
			  </ol>
		</fieldset>
	</cfform>
</cfoutput>
