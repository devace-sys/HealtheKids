<%@ Page Language="C#" CodeBehind="sbs_all_oneononeaideassignments_view.aspx.cs" Inherits="Spedmon.SBSAllOneOnOneAideAssignmentsView" %>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="oneononeaideassignments.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list."
   runat="server">
               
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
  
  </Spedmon:Step>
  
<%/*************************************[ Step 2 ]************************************/%>

<Spedmon:StepSelectPatient 
    ID               = "step2" 
    optional         = "false"
    showaddpatient   = "false" 
    showpatientnotes = "true" 
    showdatasource   = "false"   
    selecttype       = "SEARCH_BOX" 
    selectall        = "true" 
    selectdelay      = "0" 
    selectid         = "patid"  
    runat            = "server">
  </Spedmon:StepSelectPatient>    
  
  <%/*************************************[ Step 3 ]************************************/%>
  
   <Spedmon:StepSelectPractitioner 
    ID                    = "step3" 
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

  
<%/*************************************[ Step 4 ]************************************/%>
  
<Spedmon:StepView ID="step4" runat="server">
  
  <Spedmon:HiddenInput id="active" name="active" value="1" title="active" runat="server"></Spedmon:HiddenInput>

  </Spedmon:StepView>
    
</Spedmon:Steps>