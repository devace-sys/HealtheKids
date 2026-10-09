<%@Page
Language="C#"
AutoEventWireup="true"
CodeBehind="ani_all_pat_edit_delete.aspx.cs"
Inherits="Spedmon.ani_all_pat_edit_delete " 
%>

<%/*********************************************************************************/%>
<%/* Patient Data Update or Correction Request
<%/*********************************************************************************/%>

<Spedmon:Instructions ID="patdatarequest" instructionWidth="70%" title="To Update or Correct Patient Data Please Contact SBSC" runat="server">

<p>If a Patient record needs to be edited, please send an e-mail to IT@practi-cal.com 
with the information needed to EDIT along with the CURRENT information in SpEdCare about the patient:
</p>
<br />
<br />
<ul class="ui-instruction-list">
<li class="ui-instruction-list">Patient Name</li>
<li class="ui-instruction-list">Date of Birth</li>
<li class="ui-instruction-list">Client Name</li>
<li class="ui-instruction-list">School Site</li>
<li class="ui-instruction-list">SpEdCare Patient ID # (if possible) - The Patient ID # is the last column on the Patients – View report</li>
</ul>

</Spedmon:Instructions>
