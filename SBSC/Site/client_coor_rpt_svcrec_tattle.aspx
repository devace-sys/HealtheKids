<%@ Page Language="C#" CodeBehind="client_coor_rpt_svcrec_tattle.aspx.cs" Inherits="Spedmon.ClientCoorRptTattleTale" %>

<%/****************************
  * Report TattleTale
  ****************************/%>

 <Spedmon:Steps ID="servicerecordsrpt" runat="server" autoHeight="false" dataURL="servicerecords.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="What Dates?"
    instructions="Enter a date or date range.  Click to select a date range or date.<br/>Selecting or entering any date within a month or a range of months gives you the data for the full month(s).<br/>For example 9/15/2010 will give you all of September 2010.<br/>Also 9/25/2010 - 11/3/2010 will give you all of September 2010 through all of November 2010."
    optional="false"
    runat="server">
    
    <%/****************************
       * Client ID is required but
       * hidden and not settable
       ****************************/%>
    <Spedmon:HiddenInput ID="clientid" name="clientid" title="ClientID" value="" runat="server" />
    
    <Spedmon:DateBoxRange ID="daterange" name="daterange" value="" title="Click to select a date range or type one" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 2 ]************************************/%>
    
    <Spedmon:StepView ID="step2" reportNumber="2" runat="server"/>
    
</Spedmon:Steps>

