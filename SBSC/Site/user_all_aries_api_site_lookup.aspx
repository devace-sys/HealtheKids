<%@ Page Language="C#" CodeBehind="user_all_aries_api_site_lookup.aspx.cs" Inherits="Spedmon.UserAllAriesApiSiteLookup"%>
<div class="container-fluid">

<div class="row">

<%/*#################################################
    # Request Form
    #################################################*/%>
    
<div class="col-11">
<form class="form-inline" method="post" action="user_all_aries_api_site_lookup.aspx">

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

<%/*#################################################
    # Result Set
    #################################################*/%>

<div class="row mt-2">
<div class="col-12">
<table class="table table-sm table-hover">
<thead class="thead-light">
<tr>
<th>School Code</th>
<th>Name</th>
<th>CDS Code</th>
<th>Address</th>
<th colspan="4">View For This School</th>
</tr>
</thead>
<tbody>
<%foreach (var school in schools){%>
<tr>
<td><%=school.SchoolCode%></td>
<td><%=school.Name%></td>
<td><%=school.StateCountyID%><%=school.StateDistrictID%><%=school.StateSchoolID%></td>
<td><%=school.Address%> <%=school.AddressCity%> <%=school.AddressState%> <%=school.AddressZipCode%><%=school.AddressZipExt%></td>
<td><a title="Click to see students at this school" href="<%=URL_STUDENT_STUDENTS_AT_SCHOOL%><%=school.SchoolCode%>">Students</a></td>
<td><a title="Click to see student contacts at this school" href="<%=URL_STUDENT_CONTACTS_AT_SCHOOL_BASE%><%=school.SchoolCode%>">Student Contacts</a></td>
<td><a title="Click to see student programs at this school" href="<%=URL_STUDENT_PROGRAMS_AT_SCHOOL_BASE%><%=school.SchoolCode%>">Student Programs</a></td>        
<td><a title="Click to see extract data from this school." href="<%=URL_STUDENT_PROFILES_AT_SCHOOL_PREVIEW_BASE%><%=school.SchoolCode%>">Test Extract</a></td>
</tr>
<%}%>
</tbody>
</table>
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container-->
