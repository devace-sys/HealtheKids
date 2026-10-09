<%@ Page Language="C#" CodeBehind="client_coor_svcrec_svcnote_view.aspx.cs" Inherits="Spedmon.ClientCoorServiceRecordsSvcNotesView" %>

<%/****************************
  * View Service Record and
  * Service Notes
  ****************************/%>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" dataURL="servicerecords.ashx">
  
  <Spedmon:StepSelectPractitioner 
    ID                    = "step1" 
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
  
  <%/*************************************[ Step 2 ]************************************/%>
    
  <Spedmon:StepSelectPatient 
    ID               = "step2" 
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
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step3" 
	  title        = "What Dates?"
    instructions = "Click to select a date range or type in a date or date range"
    optional     = "false"
    runat        ="server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" title="Click to select a date range" useDefaultValue="true" defaultType="RANGE_CONSTANT" defaultValue="3" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepView
    ID           ="step4" 
    reportNumber ="6" 
    runat        ="server">
    
    <input id="clientid" name="clientid" value="" type="hidden"/>  
    
  </Spedmon:StepView>

</Spedmon:Steps>   
