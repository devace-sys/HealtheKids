<%@ Page Language="C#" CodeBehind="user_all_aries_api_test.aspx.cs" Inherits="Spedmon.UserAllAriesApiTest"%>
<div class="container-fluid">

<div class="row">

<%/*#################################################
    # Request Form
    #################################################*/%>

<div class="col-11">
<form class="form-inline" method="post" action="user_all_aries_api_test.aspx">

<label for="<%=PARM_NAME_SERVER%>">Server</label>
<input class="form-control ml-2" id="<%=PARM_NAME_SERVER%>" name="<%=PARM_NAME_SERVER%>" type="url" value="<%=server%>"/>

<label class="ml-2" for="<%=PARM_NAME_API_TOKEN%>">API Token</label>
<input class="form-control ml-2" id="<%=PARM_NAME_API_TOKEN%>" name="<%=PARM_NAME_API_TOKEN%>" type="text" value="<%=apiToken%>" />

<input type="hidden" name="<%=Spedmon.Constants.PARM_TOKEN%>" value="<%=tkn%>" />
<input type="hidden" name="<%=Spedmon.Constants.PARM_APP_MODE%>" value="<%=amd%>" />

<button class="btn btn-primary ml-2" type="submit">Submit</button>

</form>
</div> <!-- col -->

<%/*#################################################
    # Status
    #################################################*/%>

<div class="col-1">
  <%if (requestSuccesful){%><div class="alert alert-success">Request Successful</div><%}%>
</div> <!-- col -->
</div> <!-- row -->

<div class="row mt-2">

<%/*#################################################
    # Aries Server Info
    #################################################*/%>

<div class="col-4">
<h4>Server Info</h4>
<%if (systemInfo.hasData){%>
<ul class="list-group mt-2">
<li class="list-group-item"><span class="text-muted">Aries Version</span> <%=systemInfo.AeriesVersion%></li>
<li class="list-group-item"><span class="text-muted">Database Year</span> <%=systemInfo.DatabaseYear%></li>
<li class="list-group-item"><span class="text-muted">Local Time Zone Name</span> <%=systemInfo.LocalTimeZoneName%></li>
</ul>
<%} else {%>
  <%=systemInfo.AeriesVersion%>
<%}%>
</div> <!-- col -->

<%/*#################################################
    # Tools
    #################################################*/%>

<div class="col-4">
<h4>Tools</h4>
<div class="list-group mt-2">
    <a class="list-group-item" href="<%=siteLookupUrl%>">Sites List (Start Here)</a>
    <a class="list-group-item" href="<%=studentLookupUrl%>">Student Lookup</a>
    <a class="list-group-item" href="<%=codeSetLookupUrl%>">Code Set Lookup</a>
</div> 
</div> <!-- col -->

<%/*#################################################
    # Aries Documentation Links
    #################################################*/%>

<div class="col-4">
<h4>Aries Documentation</h4>
<div class="list-group mt-2">
  <a class="list-group-item" target="_blank" href="https://support.aeries.com/support/solutions/articles/14000068197-api-security">API Administrator Guide</a>
  <a class="list-group-item" target="_blank" href="https://support.aeries.com/support/solutions/articles/14000077926-aeries-api-full-documentation">API Full Documentation</a>
  <a class="list-group-item" target="_blank" href="https://support.aeries.com/support/solutions/articles/14000070569-api-quick-reference-guide">API Quick Reference Guide</a>
</div>
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container-->

