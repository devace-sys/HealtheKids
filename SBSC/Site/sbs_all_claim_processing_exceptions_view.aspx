<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="sbs_all_claim_processing_exceptions_view.aspx.cs" Inherits="Spedmon.SBSAllClaimProcessingExceptionView" %>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="claimexceptions.ashx">


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
 
  <Spedmon:Step ID="step3" title="Start Date"
   instructions="Select or enter the start date of Exception" 
   ondataselected="" 
   runat="server">
   <Spedmon:DateBox ID="startDate" name="startDate" title="Start Date of Exception" numMonths="1" runat="server" />
  </Spedmon:Step>
 
  <%/*************************************[ Step 4 ]************************************/%>
 
  <Spedmon:Step ID="step4" title="End Date"
   instructions="Select or enter the end date of exception" 
   ondataselected="" 
   runat="server">
   <Spedmon:DateBox ID="endDate" name="endDate" title="End Date of Exception" numMonths="1" runat="server" />
  </Spedmon:Step>
   
  <%/*************************************[ Step 5 ]************************************/%>
  
   <Spedmon:StepView ID="step5" runat="server"/>
    
</Spedmon:Steps>

