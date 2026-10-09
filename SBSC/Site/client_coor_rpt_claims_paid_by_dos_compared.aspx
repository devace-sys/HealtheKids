<%@ Page Language="C#" CodeBehind="client_coor_rpt_claims_paid_by_dos_compared.aspx.cs" Inherits="Spedmon.ClientCoorRptClaimsPaidByDosCompared" %>

<%/****************************
  * Report Claims Paid 
  * by Check Date 
  ****************************/%>

 <Spedmon:Steps ID="claimsrpt" runat="server" autoHeight="false" dataURL="reports_fin.ashx">


  
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="What Is the Date Range for Period 1 (P1)?"
    instructions="Click to select a date range or type in a date or date range"
    optional="false"
    runat="server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" useDefaultValue="true" defaultType="RANGE_CONSTANT" defaultValue="4" runat="server" />
  
  </Spedmon:Step>
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="What Is the Date Range for Period 2 (P2)?"
    instructions="Click to select a date range or type in a date or date range"
    optional="false"
    runat="server">

    <Spedmon:DateBoxRange ID="daterange2" name="daterange2" useDefaultValue="true" defaultType="RANGE_CONSTANT" defaultValue="3" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step ID="step3" title="Display Practitioners With Zeros?"
    instructions="Do you want to display practitioners with totals equal to zero in this report?"
    optional="false"
    runat="server">
   
    <Spedmon:YesNo ID="includezeros" name="includezeros" title="Display Zeros?" useDefaultValue="true" defaultValue="Yes" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 4 ]************************************/%>
    
<Spedmon:StepReport ID="step4" reportNumber="4" runat="server">
  <input id="clientid" name="clientid" value="" type="hidden"/>  
 </Spedmon:StepReport>
    
</Spedmon:Steps>