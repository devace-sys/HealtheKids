<%@ Page Language="C#" CodeBehind="rpt_services_pending_prac_approval_or_held.aspx.cs" Inherits="Spedmon.RptSvcsPendingPracApprovalOrHeld" %>

<%/****************************
  * Services Held for Approval
  ****************************/%>

 <Spedmon:Steps ID="svcrecsheldrpt" runat="server" autoHeight="false" dataURL="servicerecordsapproval.ashx">   
  
   <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list"
   optional="false"
   runat="server">
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel"  runat="server" /> 
  </Spedmon:Step>


  <%/*************************************[ Step 2]************************************/%>
    
  <Spedmon:StepView ID="step2" reportNumber="4" runat="server"/>
    
</Spedmon:Steps>

