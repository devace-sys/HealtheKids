<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="rpt_claims_transmission_summary.aspx.cs" Inherits="Spedmon.rpt_claims_transmission_summary" %>

    <%/****************************
  * Report Claims  View
  ****************************/%>

 <Spedmon:Steps ID="claimsrpt" runat="server" autoHeight="false" dataURL="claims.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list"
   optional="false"
   runat="server">
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel"  runat="server" /> 
  </Spedmon:Step>
      

  
  <%/*************************************[ Step 2 ]************************************/%>
 
     
    <Spedmon:Step
  
      ID           = "step2" 
  	  title        = "Who is the Rep?"
      instructions = "Start typing the name of the district rep, or click on the down arrow for a list"
      optional     = "true"
      runat        = "server">
  
      <Spedmon:ComboBox 
        ID          = "clrepidLEA" 
	    name        = "clrepidLEA"	
	    title       = "Select Rep" 
	    dataPrivate = "true" 
	    dataURL     = "clientReps.asmx/viewSel" 
	    runat       = "server" /> 

  </Spedmon:Step>

  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step ID="step3" title="What Dates?"
    instructions="Click to select a date range or type in a date or date range"
    optional="false"
    runat="server">
    
    <Spedmon:DateBoxRange ID="daterange" name="daterange" title="Click to select a date range or type one" runat="server" />
  
  </Spedmon:Step>
  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepView ID="step4" reportNumber="21" runat="server"/>

 </Spedmon:Steps>
