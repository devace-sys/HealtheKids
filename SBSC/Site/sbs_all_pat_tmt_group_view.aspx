<%@ Page Language="C#" CodeBehind="sbs_all_pat_tmt_group_view.aspx.cs" Inherits="Spedmon.SBSAllPatientGroupsView" %>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="patientgroups.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list.<br/>To select all clients leave this blank."
   runat="server">
          
  <%/****************************
    * Do not remove the following
    * inputs.  Their values will
    * be automatically replaced
    * on the server side.
    ****************************/%>
     
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
  </Spedmon:Step>
  
  <%/*************************************[ Step 2 ]************************************/%>
  
 <Spedmon:StepSelectPractitioner 
    ID                    = "step2" 
    optional              = "false" 
    showaddpractitioner   = "false"
    showdatasource        = "false"
    savedatasource        = "false"       
    showpractionernotes   = "true" 
    selecttype            = "COMBO_BOX" 
    selectall             = "true" 
    selectdelay           = "0" 
    selectid              = "pracid"
    runat                 = "server">
  </Spedmon:StepSelectPractitioner>

<%/*************************************[ Step 3 ]************************************/%>
  
<Spedmon:StepView ID="step3" runat="server">
  <Spedmon:HiddenInput id="active" name="active" value="1" title="active" runat="server"></Spedmon:HiddenInput>
</Spedmon:StepView>
    
</Spedmon:Steps>