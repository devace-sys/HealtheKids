<%@ Page Language="C#" CodeBehind="user_all_aries_api_student_students_lookup.aspx.cs" Inherits="Spedmon.UserAllAriesApiStudentStudentsLookup"%>
<div class="container-fluid">

<div class="row">

<%/*#################################################
    # Request Form
    #################################################*/%>

<div class="col-11">
<form class="form-inline" method="post" action="user_all_aries_api_student_students_lookup.aspx">

<label for="<%=PARM_NAME_SERVER%>">Server</label>
<input class="form-control ml-2" id="<%=PARM_NAME_SERVER%>" name="<%=PARM_NAME_SERVER%>" type="url" value="<%=server%>"/>

<label class="ml-2" for="<%=PARM_NAME_API_TOKEN%>">API Token</label>
<input class="form-control ml-2" id="<%=PARM_NAME_API_TOKEN%>" name="<%=PARM_NAME_API_TOKEN%>" type="text" value="<%=apiToken%>" />

<label class="ml-2" for="<%=PARM_NAME_ASCDE%>">School Code</label>
<input class="form-control ml-2" id="<%=PARM_NAME_ASCDE%>" name="<%=PARM_NAME_ASCDE%>" type="number" size="5" value="<%=ascde%>"/>

<label class="ml-2" for="<%=PARM_NAME_REC_NUM_START%>">Starting Rec</label>
<input class="form-control ml-2" id="<%=PARM_NAME_REC_NUM_START%>" name="<%=PARM_NAME_REC_NUM_START%>" type="number" size="5" value="<%=arnsrt%>"/>

<label class="ml-2" for="<%=PARM_NAME_REC_NUM_END%>">Ending Rec</label>
<input class="form-control ml-2" id="<%=PARM_NAME_REC_NUM_END%>" name="<%=PARM_NAME_REC_NUM_END%>" type="number" size="5" value="<%=arnend%>"/>

<label class="ml-2" for="<%=PARM_NAME_ASID%>">Student ID</label>
<input class="form-control ml-2" id="<%=PARM_NAME_ASID%>" name="<%=PARM_NAME_ASID%>" type="text" size="6" value="<%=asid%>"/>

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
    <th>Student ID</th>
    <th>First Name</th>
    <th>Last Name</th>
    <th>DOB</th>
    <th>Gender</th>
    <th>SSID</th>
    <th>Inactive<br>Status<br>Code</th>
    <th colspan="2">View For This Student</th>
</tr>
</thead>
<tbody>
<%foreach (var student in students) {%>
<tr> 
<td><%=student.SchoolCode%></td>
<td><%=student.StudentID%></td>
<td><%=student.FirstName%></td>
<td><%=student.LastName%></td>
<td><%if(student.Birthdate.HasValue){%><%=student.Birthdate.Value.ToShortDateString()%><%}%></td>
<td><%=student.Gender%></td>
<td><%=student.StateStudentID%></td>
<td><%=student.InactiveStatusCode%></td>
<td><a title="Click to see student contacts" href="<%=URL_STUDENT_CONTACTS_FOR_STUDENT_BASE%><%=student.StudentID%>">Contacts</a></td>
<td><a title="Click to see student programs" href="<%=URL_STUDENT_PROGRAMS_FOR_STUDENT_BASE%><%=student.StudentID%>">Programs</a></td>
</tr>
<%}%>
</tbody>
</table>
</div> <!-- col -->
</div> <!-- row -->

</div> <!-- container-->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">
            
   
    $(document).ready(function () {        
   
    });

</script>
