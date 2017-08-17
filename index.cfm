<cfif isDefined('url.loginError')>
	<p style="font-weight:bold; color:red;">There was an error with your login.  Please try again.</p>
<cfelseif isDefined('url.mustLogin')>
	<p style="font-weight:bold; color:red;">You must login before using the Application Generator</p>					
</cfif>
<form name="ApplicationGeneratorLogin" action="home.cfm" method="post">
	<fieldset>
		<legend>Login</legend>
		<table>
			<tr>
				<td>Username:</td>
				<td><input name="username" type="text" /></td>
			</tr>
			<tr>
				<td>Password:</td>
				<td><input name="password" type="password" /></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td><input name="login" type="submit" value="Login"/></td>
			</tr>
		</table>
	</fieldset>
</form>