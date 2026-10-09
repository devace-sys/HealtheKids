<%@ Page Language="C#" CodeBehind="client_coor_rpt_combined_1on1_by_pmt_date.aspx.cs" Inherits="Spedmon.client_coor_rpt_combined_1on1_by_pmt_date" %>

<%/**********************************
  * Report Combined1on1ByPaymentDate
  ***********************************/%>
  
 <Spedmon:Steps ID="servicerecordsrpt" runat="server" autoHeight="false" dataURL="servicerecords.ashx">


  
   <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:StepSelectPractitioner 
    ID                    = "step1" 
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
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="What Dates?"
    instructions="Enter a date or date range.  Click to select a date range or date.<br/>Selecting or entering any date within a month or a range of months gives you the data for the full month(s).<br/>For example 9/15/2010 will give you all of September 2010.<br/>Also 9/25/2010 - 11/3/2010 will give you all of September 2010 through all of November 2010."
    optional="false"
    runat="server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" value="" title="Click to select a date range or type one" runat="server" />

  </Spedmon:Step>
  
   <%/*************************************[ Step 3 ]************************************/%>
   
      <Spedmon:StepReport ID="step3" reportNumber="2" runat="server">
  <input id="clientid" name="clientid" value="" type="hidden"/>  
 </Spedmon:StepReport>
    
</Spedmon:Steps>