<%@ Page Language="C#" CodeBehind="user_all_aries_api_code_set_lookup.aspx.cs" Inherits="Spedmon.UserAllAriesApiCodeSetLookup"%>
<div class="container-fluid">

<div class="row">

<%/*#################################################
    # Request Form
    #################################################*/%>
    
<div class="col-10">
<form class="form-inline" method="post" action="user_all_aries_api_code_set_lookup.aspx">
<label for="<%=PARM_NAME_SERVER%>">Server</label>
<input class="form-control ml-2" id="<%=PARM_NAME_SERVER%>" name="<%=PARM_NAME_SERVER%>" type="url" value="<%=server%>"/>
<label class="ml-2" for="<%=PARM_NAME_API_TOKEN%>">API Token</label>
<input class="form-control ml-2" id="<%=PARM_NAME_API_TOKEN%>" name="<%=PARM_NAME_API_TOKEN%>" type="text" value="<%=apiToken%>" />
<label class="ml-2" for="<%=PARM_NAME_TABLE_NAME%>">Table Name</label>
<input class="form-control ml-2" id="<%=PARM_NAME_TABLE_NAME%>" name="<%=PARM_NAME_TABLE_NAME%>" type="text" value="<%=tableName%>"/>
<label class="ml-2" for="<%=PARM_NAME_FIELD_NAME%>">Field Name</label>
<input class="form-control ml-2" id="<%=PARM_NAME_FIELD_NAME%>" name="<%=PARM_NAME_FIELD_NAME%>" type="text" value="<%=fieldName%>"/>
<input type="hidden" name="<%=Spedmon.Constants.PARM_TOKEN%>" value="<%=tkn%>" />
<input type="hidden" name="<%=Spedmon.Constants.PARM_APP_MODE%>" value="<%=amd%>" />
<button class="btn btn-primary ml-2" type="submit">Submit</button>
</form>
</div> <!-- col -->

<%/*#################################################
    # Aries Documentation Links
    #################################################*/%>

<div class="col-2">
<details>
<summary>Aries Documentation</summary>
<div class="list-group mt-2">
  <a class="list-group-item" target="_blank" href="https://support.aeries.com/support/solutions/articles/14000068197-api-security">API Administrator Guide</a>
  <a class="list-group-item" target="_blank" href="https://support.aeries.com/support/solutions/articles/14000077926-aeries-api-full-documentation">API Full Documentation</a>
  <a class="list-group-item" target="_blank" href="https://support.aeries.com/support/solutions/articles/14000070569-api-quick-reference-guide">API Quick Reference Guide</a>
</div>
</details>
</div> <!-- col -->

</div> <!-- row -->

<%/*#################################################
    # Code Set
    #################################################*/%>

<div class="row mt-2">
<div class="col-12">
<table class="table table-sm">
<thead class="thead-light">
<tr>
<th>Code</th>
<th>Description</th>
<th>Status</th>
</tr>
</thead>
<tbody>
<%foreach (var ac in ariesCodes){%>
<tr>
<td><%=ac.Code%></td>
<td><%=ac.Description%></td>
<td><%=ac.Status%></td>
</tr>
<%}%>
</tbody>
</table>
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container-->
