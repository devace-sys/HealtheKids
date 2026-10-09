<%@ Page Language="C#" CodeBehind="client_prov_svcrec_svcnote_view.aspx.cs" Inherits="Spedmon.ClientProvServiceRecordsSvcNotesView" %>

<%/****************************
  * View Service Record and
  * Service Notes
  ****************************/%>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" dataURL="servicerecords.ashx">
  
  <%/*************************************[ Step 1 ]************************************/%>
    
  <Spedmon:StepSelectPatient 
    ID               = "step1" 
    optional         = "true"
    showaddpatient   = "false" 
    showpatientnotes = "false"
    showdatasource   = "true"   
    selecttype       = "COMBO_BOX" 
    selectall        = "false" 
    selectdelay      = "1000" 
    selectid         = "patid"
    runat            = "server">
    
  </Spedmon:StepSelectPatient>
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step2" 
	  title        = "What Dates?"
    instructions = "Click to select a date range or type in a date or date range"
    optional     = "false"
    runat        ="server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" title="Click to select a date range" useDefaultValue="true" defaultType="RANGE_CONSTANT" defaultValue="3" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:StepView
    ID            = "step3" 
    reportNumber  = "6" 
    displayGenPDF = "false"
    runat         = "server">
        
  </Spedmon:StepView>

</Spedmon:Steps>   
