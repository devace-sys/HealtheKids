<%@ Page Language="C#" CodeBehind="user_all_aries_api_student_lookup.aspx.cs" Inherits="Spedmon.UserAllAriesApiStudentLookup"%>
<div class="container-fluid">

<div class="row">

<%/*#################################################
    # Request Form
    #################################################*/%>

<div class="col-12">
<form class="form-inline" method="post" action="user_all_aries_api_student_lookup.aspx">

<label for="<%=PARM_NAME_SERVER%>">Server</label>
<input class="form-control ml-2" id="<%=PARM_NAME_SERVER%>" name="<%=PARM_NAME_SERVER%>" type="url" value="<%=server%>"/>

<label class="ml-2" for="<%=PARM_NAME_API_TOKEN%>">API Token</label>
<input class="form-control ml-2" id="<%=PARM_NAME_API_TOKEN%>" name="<%=PARM_NAME_API_TOKEN%>" type="text" value="<%=apiToken%>" />

<label class="ml-2" for="<%=PARM_NAME_ASCDE%>">ARIES School Code</label>
<input class="form-control ml-2" id="<%=PARM_NAME_ASCDE%>" name="<%=PARM_NAME_ASCDE%>" type="text" value="<%=ascde%>"/>

<input type="hidden" name="<%=Spedmon.Constants.PARM_TOKEN%>" value="<%=tkn%>" />
<input type="hidden" name="<%=Spedmon.Constants.PARM_APP_MODE%>" value="<%=amd%>" />

<button class="btn btn-primary ml-2" type="submit">Submit</button>
</form>
</div> <!-- col -->
</div> <!-- row -->

<%/*#################################################
    # Export File (Preview)
    #################################################*/%>

<div class="row mt-2">
<div class="col-12">
<details>
<summary>Export File Contents</summary>
<table id="tbl-exportfilecontents" class="table table-sm mt-2">
</table>
</details>
</div> <!-- col -->
</div> <!-- row -->

<%/*#################################################
    # Result Set
    #################################################*/%>

<div class="row mt-2">
<div class="col-12">
<table class="table table-sm mt-2">
<thead class="thead-light">
<tr>
<th>School Name</th>
<th>School Code</th>
<th>First</th>
<th>Last</th>
<th>DOB</th>
<th>Student ID</th>
<th>SSID</th>
<th>Inactive</th>
<th>Is SpEd?</th>
<th>Primary Contact</th>
<th>Programs</th>
<th>Contacts</th>
</tr>
</thead>
<tbody>
<%foreach (var schoolAndStudents in schoolsAndStudents){%>
<%foreach (var studentProfile in schoolAndStudents.studentProfiles) {%>
<tr>
<td><%=schoolAndStudents.school.Name%></td>
<td><%=schoolAndStudents.school.SchoolCode%></td>

<td><%=studentProfile.student.FirstName%></td>
<td><%=studentProfile.student.LastName%></td>
<td><%=studentProfile.student.Birthdate.ToString()%></td>
<td><%=studentProfile.student.StudentID%></td>
<td><%=studentProfile.student.StateStudentID%></td>
<td><%=studentProfile.student.InactiveStatusCode%></td>
<td><%=studentProfile.studentIsSpEd%></td>
<td>
First: <%=studentProfile.primaryContactFirstName%><br>
Last: <%=studentProfile.primaryContactLastName%><br>
Email: <%=studentProfile.primaryContactEmail%><br>
Phone: <%=studentProfile.primaryContactPhone%><br>
</td>
<td>
<%if(schoolAndStudents.requestSuccessfulSpEdPrograms == false){%>
  <span class="badge badge-pill badge-danger">No Access</span>
<%}%>
<ul>
<%foreach (var studentProgram in studentProfile.studentSpEdPrograms) {%>
<li><%=studentProgram.ProgramCode%> - <%=studentProgram.ProgramDescription%></li>
<%}%>
</ul>
</td>
<td>
<%if(schoolAndStudents.requestSuccessfulContacts == false){%>
  <span class="badge badge-pill badge-danger">No Access</span>
<%}%>
<table>
<thead>
<tr>
    <td></td>
    <td>Contact<br>Order</td>
    <td>Primary<br>Flag</td>
    <td>First Name</td>
    <td>Last Name</td> 
    <td>Email</td>
    <td>Home</td>
    <td>Cell</td>
    <td>Relationship<br>To Student<br>Code</td>
    <td>Notification<br>Preference<br>Code</td>
    <td>Record Type</td>
</tr>
</thead>
<tbody>
<%foreach(var studentContact in studentProfile.studentContacts) {%>
<tr>           
    <td><%if (studentContact.identifiedAsPrimaryContact == true){%>SpEdCare Primary<%}%></td>
    <td><%=studentContact.ContactOrder%></td>
    <td><%=studentContact.PrimaryContact%></td>
    <td><%=studentContact.FirstName%></td>
    <td><%=studentContact.LastName%></td>
    <td><%=studentContact.EmailAddress%></td>
    <td><%=studentContact.HomePhone%></td>
    <td><%=studentContact.CellPhone%></td>
    <td><%=studentContact.RelationshipToStudentCode%></td>
    <td><%=studentContact.NotificationPreferenceCode%></td>
    <td><%=studentContact.MiscCode%></td>
 </tr>        
<%}%>
</tbody>
</table>
</td>
</tr>
<%}%>
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
            
    function parseExportFileContents() {
        let $tblExportFileContents = $('#tbl-exportfilecontents');
        $($tblExportFileContents).html('');
        <%if (exportFileGenerated){%>        
        let strExportFileContents = '<%=exportFileContents%>';
        let exportFileContentLines = strExportFileContents.split(/\n/);
        exportFileContentLines.forEach(exportFileContentLine => {
            let exportFileContentLineCells = exportFileContentLine.split(',');
            let $tr = $('<tr></tr>');
            exportFileContentLineCells.forEach(exportFileContentLineCell => {
                let $td = $('<td>' + exportFileContentLineCell + '</td>');
                $($tr).append($td);                
            });
            $($tblExportFileContents).append($tr);
        });
        <%}%>
    };

    $(document).ready(function () {        
        parseExportFileContents();        
    });

</script>
