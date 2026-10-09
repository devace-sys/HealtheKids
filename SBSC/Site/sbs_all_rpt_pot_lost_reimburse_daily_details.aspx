<%@ Page Language="C#" CodeBehind="sbs_all_rpt_pot_lost_reimburse_daily_details.aspx.cs" Inherits="Spedmon.sbs_all_rpt_pot_lost_reimburse_daily_details"%>

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
    
  <Spedmon:StepViewNoPreview ID="step2" reportNumber="50" runat="server"/>
      
</Spedmon:Steps>