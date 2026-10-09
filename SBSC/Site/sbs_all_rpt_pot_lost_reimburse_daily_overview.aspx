<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="sbs_all_rpt_pot_lost_reimburse_daily_overview.aspx.cs" Inherits="Spedmon.sbs_all_rpt_pot_lost_reimburse_daily_overview" %>

 <Spedmon:Steps ID="claimsrpt" autoHeight="false" autoScroll="true" dataURL="claims.ashx" runat="server">
    
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step1" 
  	title        = "Who is the Client?"
    instructions = "Start typing the client name or click on the down arrow for a list"
    optional     = "false"
    runat        = "server">
  
    <Spedmon:ComboBox 
      ID          = "clientid" 
	    name        = "clientid" 	
	    title       = "Select Client" 
	    dataPrivate = "true" 
	    dataURL     = "clients.asmx/viewSel" 
	    runat       = "server" /> 
  
  </Spedmon:Step>    
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID            = "step2" 
	  title         = "Who is the Client Consultant?"
    instructions  = "Start typing the consultant name or click on the down arrow for a list"
    optional      = "true"
    runat         = "server">

     <Spedmon:ComboBox 
       ID          = "clrepidLEA" 
	     name        = "clrepidLEA"	
	     title       = "Select Client Consultant" 
	     dataPrivate = "true" 
	     dataURL     = "clientReps.asmx/viewSel" 
	     runat       = "server" /> 

  </Spedmon:Step>

  <%/*************************************[ Step 3 ]************************************/%>
    
  <Spedmon:StepView ID="step3" reportNumber="51" runat="server"/>
      
</Spedmon:Steps>