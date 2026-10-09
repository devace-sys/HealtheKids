  <%@ Page Language="C#" CodeBehind="rpt_batches_about_to_ageout.aspx.cs" Inherits="Spedmon.RptBatchesAboutToAgeOut"%>
  
    <Spedmon:Steps ID="claimsrpt" autoHeight="false" autoScroll="true" dataURL="servicerecords.ashx" runat="server">
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
 
      ID           = "step2" 
  	  title        = "Who is the Consultant?"
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
  
   <Spedmon:StepView
    ID            = "step5" 
    reportNumber  = "8"   
    runat         = "server"/>
  
    </Spedmon:Steps>