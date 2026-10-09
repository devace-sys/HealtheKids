<%@ Page Language="C#" CodeBehind="user_all_patient_known_health_problem_save.aspx.cs" Inherits="Spedmon.UserAllPatientKnownHealthProblemSave" %>

<%if (clientAndPatAreOK == true){%>

<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>

<Spedmon:DataEntryRows ID="save" purpose="SAVE" dataURL="patient_knownhealthproblems.asmx/save" useBootstrapFluid="true" runat="server">
 
<%//-----------------------------------------------------------------------------%>
<%// Select Known Health Problem %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow rowLabel="Select Known Health Problem" runat="server">

  <Spedmon:ComboBox ID="knownhealthproblemid" name="knownhealthproblemid" title="Select Known Health Problem" dataPrivate="true" dataURL="KnownHealthProblems.asmx/viewSel" runat="server" /> 

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Select Priority %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow rowLabel='Flag this health problem as critical?<br> Critical health problems are shown at the top of the list and are denoted with a <i class="fas fa-exclamation-triangle text-danger"></i>' runat="server">
  
    <Spedmon:SelectYesOrNo 
            id            = "ispriority" 
            name          = "ispriority" 
            title         = "ispriority"
            renderLabel   = "false" 
            onSelectValue = "function(oldval,newval){ return true; }"
            runat         = "server" />

</Spedmon:DataEntryRow>
 
<%//-----------------------------------------------------------------------------%>
<%// Notes %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow rowLabel="Enter any notes.<br>You can view these notes by hovering over the health problem name in the list of health problems." runat="server">
  
  <Spedmon:DataEntryBoxTextArea ID="notes" name="notes" title="Notes" size="25" runat="server" />

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Save or Edit %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSaveOrEdit 
    ID                               = "saveOrEdit"     
    runat                            = "server"> 
  
  <Spedmon:HiddenInput ID="clientid" name ="clientid" title="clientid" runat="server" />
  <Spedmon:HiddenInput ID="patid"    name ="patid"    title="patid"   runat="server" />
  
</Spedmon:DataEntryRowSaveOrEdit> <!-- row -->

</Spedmon:DataEntryRows> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Entry Scripts  %>
<%//##################################################################################################################%>

<script type="text/javascript">


<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

$(window).on('load', function () {

});

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    

</script>

<%} /* client and pat are ok */ else {%>
<div class="alert alert-danger text-center">Please select a patient</div>
<%}%>


