<%@ Page Language="C#" CodeBehind="user_all_aries_api_student_programs_lookup.aspx.cs" Inherits="Spedmon.UserAllAriesApiStudentProgramsLookup"%>
<div class="container-fluid">

<div class="row">

<%/*#################################################
    # Request Form
    #################################################*/%>

<div class="col-11">

<form class="form-inline" method="post" action="user_all_aries_api_student_programs_lookup.aspx">

<label for="<%=PARM_NAME_SERVER%>">Server</label>
<input class="form-control ml-2" id="<%=PARM_NAME_SERVER%>" name="<%=PARM_NAME_SERVER%>" type="url" value="<%=server%>"/>

<label class="ml-2" for="<%=PARM_NAME_API_TOKEN%>">API Token</label>
<input class="form-control ml-2" id="<%=PARM_NAME_API_TOKEN%>" name="<%=PARM_NAME_API_TOKEN%>" type="text" value="<%=apiToken%>" />

<label class="ml-2" for="<%=PARM_NAME_ASCDE%>">School Code</label>
<input class="form-control ml-2" id="<%=PARM_NAME_ASCDE%>" name="<%=PARM_NAME_ASCDE%>" type="number" size="5" value="<%=ascde%>"/>

<label class="ml-2" for="<%=PARM_NAME_ASID%>">Student ID <span class="text-muted ml-1">(0 = all)</span></label>
<input class="form-control ml-2" id="<%=PARM_NAME_ASID%>" name="<%=PARM_NAME_ASID%>" type="text" size="6" value="<%=asid%>"/>

<label class="ml-2" for="<%=PARM_NAME_APCDE%>">Program Code <span class="text-muted ml-1">(144 = SpEd)</span></label>
<input class="form-control ml-2" id="<%=PARM_NAME_APCDE%>" name="<%=PARM_NAME_APCDE%>" type="text" size="4" value="<%=apcde%>"/>

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
<table class="table table-sm">
<thead class="thead-light">
<tr>
    <th>Student ID</th>
    <th>Program Code</th>
    <th>Program Description</th>
</tr>
</thead>
<tbody>
<%foreach (var studentProgram in studentPrograms) {%>
<tr> 
<td><%=studentProgram.StudentID%></td>
<td><%=studentProgram.ProgramCode%></td>
<td><%=studentProgram.ProgramDescription%></td>
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
