<%@ Page Language="C#" CodeBehind="client_prov_rpt_svc_rec_review_for_direct_sup.aspx.cs" Inherits="Spedmon.ClientProvRptSvcRecReviewForDirectSup" %>

<%/****************************
  * View Service Records
  ****************************/%>

<Spedmon:Steps 
  ID         = "viewexisting"
  autoHeight = "false" 
  dataURL    = "servicerecordsapproval.ashx"
  runat      = "server" >
 
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:StepSelectPractitioner   
    ID                    = "step1" 
    optional              = "true" 
    showaddpractitioner   = "false"
    showdatasource        = "false"
    savedatasource        = "false"
    showpractionerqforms  = "false"       
    showpractionernotes   = "false" 
    selecttype            = "COMBO_BOX" 
    selectall             = "true" 
    selectdelay           = "0" 
    selectid              = "pracid"
    runat                 = "server" />  
  

  <%/*************************************[ Step 2 ]************************************/%>
    
  <Spedmon:StepSelectPatient   
    ID               = "step2" 
    optional         = "true"
    showaddpatient   = "false" 
    showpatientnotes = "false"
    showdatasource   = "false"
    savedatasource   = "false"          
    selecttype       = "COMBO_BOX" 
    selectall        = "false" 
    selectdelay      = "1000" 
    selectid         = "patid"
    runat            = "server" />    
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step3" 
    title        = "What Dates?"
    instructions = "Click to select a date range or type in a date or date range"
    optional     = "true"
    runat        = "server">

    <Spedmon:DateBoxRange     
      ID              = "daterange" 
      name            = "daterange" 
      title           = "Click to select a date range" 
      useDefaultValue = "true" 
      defaultType     = "RANGE_CONSTANT" 
      defaultValue    = "3" 
      runat           = "server" />

  </Spedmon:Step>

 <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepView   
    ID           = "step4" 
    reportNumber = "5" 
    runat        = "server" >
    
    <Spedmon:HiddenInput id="clientid"         name="clientid"         title="clientid" />
    <Spedmon:HiddenInput id="approvingpracid"  name="approvingpracid"  title="approvingpracid" />
    
  </Spedmon:StepView>
 
</Spedmon:Steps>