<%@ Page Language="C#" CodeBehind="sbs_all_service_journals_view.aspx.cs" Inherits="Spedmon.SBSAllServiceJournalsView" %>

<%/****************************
  * View Service Record and
  * Service Notes
  ****************************/%>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" dataURL="servicejournals.ashx">
  
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID="step1" 
	title="Who is the Client?"
    instructions="Start typing the client name or click on the down arrow for a list."
    optional="false"
    runat="server">
         
    <Spedmon:ComboBox 
	  ID="clientid" 
	  name="clientid" 
	  value="" 
	  title="Select Client" 
	  dataPrivate="true" 
	  dataURL="clients.asmx/viewSel" 
	  runat="server" /> 
	
  </Spedmon:Step>
  
  <%/*************************************[ Step 2 ]************************************/%>

  <Spedmon:StepSelectPractitioner 
    ID                    = "step2" 
    optional              = "true" 
    showaddpractitioner   = "false"
    showdatasource        = "false"
    savedatasource        = "false"       
    showpractionernotes   = "false" 
    selecttype            = "COMBO_BOX" 
    selectall             = "true" 
    selectdelay           = "0" 
    selectid              = "pracid"
    runat                 = "server">
  </Spedmon:StepSelectPractitioner> 
  
  <%/*************************************[ Step 3 ]************************************/%>
    
  <Spedmon:StepSelectPatient 
    ID               = "step3" 
    optional         = "true"
    showaddpatient   = "false" 
    showpatientnotes = "false"
    showdatasource   = "false"   
    selecttype       = "COMBO_BOX" 
    selectall        = "true" 
    selectdelay      = "1000" 
    selectid         = "patid"
    runat            = "server">
    
  </Spedmon:StepSelectPatient>
  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step4" 
	title        = "What Dates?"
    instructions = "Click to select a date range or type in a date or date range"
    optional     = "false"
    runat        ="server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" value="" title="Click to select a date range" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:StepView
    ID           ="step5" 
    reportNumber ="1" 
    runat        ="server">
        
  </Spedmon:StepView>

</Spedmon:Steps>   