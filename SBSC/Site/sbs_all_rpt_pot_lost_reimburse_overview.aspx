<%@ Page Language="C#" CodeBehind="sbs_all_rpt_pot_lost_reimburse_overview.aspx.cs" Inherits="Spedmon.SBSAllRptPotLostReimburseOverview"%>

  <Spedmon:Steps ID="claimsrpt" autoHeight="false" autoScroll="true" dataURL="claims.ashx" runat="server">
    
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step1" 
  	title        = "Who is the Client?"
    instructions = "Start typing the client name or click on the down arrow for a list"
    optional     = "true"
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
    
  <Spedmon:StepView ID="step3" reportNumber="20" runat="server"/>
      
</Spedmon:Steps>