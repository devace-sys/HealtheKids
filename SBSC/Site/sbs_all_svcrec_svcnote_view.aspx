<%@ Page Language="C#" CodeBehind="sbs_all_svcrec_svcnote_view.aspx.cs" Inherits="Spedmon.SBSAllServiceRecordsSvcNotesView" %>

<%/****************************
  * View Service Record and
  * Service Notes
  ****************************/%>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" dataURL="servicerecords.ashx">
  
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
    showdatasource        = "true"
    savedatasource        = "false"       
    showpractionernotes   = "true" 
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
      showdatasource   = "true"
      savedatasource   = "false"       
      showpatientnotes = "true" 
      selecttype       = "SEARCH_BOX" 
      selectall        = "false" 
      selectdelay      = "0" 
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

    <Spedmon:DateBoxRange ID="daterange" name="daterange" title="Click to select a date range"  useDefaultValue="true" defaultType="RANGE_CONSTANT" defaultValue="3" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:StepView
    ID           ="step5" 
    reportNumber ="6" 
    runat        ="server">
        
  </Spedmon:StepView>

</Spedmon:Steps>   