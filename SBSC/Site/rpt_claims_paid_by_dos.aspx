<%@ Page Language="C#" CodeBehind="rpt_claims_paid_by_dos.aspx.cs" Inherits="Spedmon.RptClaimsPaidByDos" %>

<%/****************************
  * Report Claims Paid 
  * by Check Date 
  ****************************/%>

 <Spedmon:Steps ID="claimsrpt" runat="server" autoHeight="false" dataURL="reports_fin.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list"
   optional="false"
   runat="server">
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
  </Spedmon:Step>    
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="What Date Range?"
    instructions="Click to select a date range or type in a date or date range"
    optional="false"
    runat="server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" useDefaultValue="true" defaultType="RANGE_CONSTANT" defaultValue="3" runat="server" />

  </Spedmon:Step>

  <%/*************************************[ Step 3 ]************************************/%>

  <Spedmon:Step ID="step3" title="Display Practitioners With Zeros?"
    instructions="Do you want to display practitioners with totals equal to zero in this report?"
    optional="false"
    runat="server">
   
    <Spedmon:YesNo ID="includezeros" name="includezeros" title="Display Zeros?" useDefaultValue="true" defaultValue="Yes" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 4 ]************************************/%>
    
  <Spedmon:StepReport ID="step4" reportNumber="3" runat="server"/>
    
</Spedmon:Steps>
