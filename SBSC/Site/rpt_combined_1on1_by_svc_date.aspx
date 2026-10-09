<%@ Page Language="C#" CodeBehind="rpt_combined_1on1_by_svc_date.aspx.cs" Inherits="Spedmon.RptCombined1on1BySvcDate" %>

<%/**********************************
  * Report Combined1on1ByPaymentDate
  ***********************************/%>
  
 <Spedmon:Steps ID="servicerecordsrpt" runat="server" autoHeight="false" dataURL="servicerecords.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list.<br/>To select all clients leave this blank."
   optional="false"
   runat="server">
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
  
  <Spedmon:Step ID="step3" title="What Dates?"
    instructions="Enter a date or date range.  Click to select a date range or date.<br/>Selecting or entering any date within a month or a range of months gives you the data for the full month(s).<br/>For example 9/15/2010 will give you all of September 2010.<br/>Also 9/25/2010 - 11/3/2010 will give you all of September 2010 through all of November 2010."
    optional="false"
    runat="server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" value="" title="Click to select a date range or type one" runat="server" />

  </Spedmon:Step>
  
   <%/*************************************[ Step 4 ]************************************/%>
   
     <Spedmon:StepView ID="step4" reportNumber="5" runat="server"/>
    
</Spedmon:Steps>