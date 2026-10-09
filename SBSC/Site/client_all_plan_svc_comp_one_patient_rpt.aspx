<%@ Page Language="C#" CodeBehind="client_all_plan_svc_comp_one_patient_rpt.aspx.cs" Inherits="Spedmon.client_all_plan_svc_comp_one_patient_rpt" %>

<%/****************************
   * View stats on services 
   * rendered for one patient 
   * for compliance purposes
   ****************************/%>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" dataURL="servicerecords.ashx">
  
  <%/*************************************[ Step 1 ]************************************/%>
    
  <Spedmon:StepSelectPatient 
    ID               = "step1" 
    optional         = "false"
    showaddpatient   = "false" 
    showpatientnotes = "false"
    showdatasource   = "true"   
    selecttype       = "COMBO_BOX" 
    selectall        = "false" 
    selectdelay      = "1000" 
    selectid         = "patid"
    title            = "Please select the patient that you would like to verify service compliance for"
    runat            = "server">
    
  </Spedmon:StepSelectPatient>
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID                = "step2" 
	  title             = "Select the date range for the patient you are verifying service compliance"
    instructionFormat = "UL_LIST"
    instructions      = "<li>To verify based on a service authorization date, select All Dates After and select date</li><li>To verify based on a specific date range, select Date Range and select the start and end date</li>"
    optional          = "false"
    runat             = "server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" title="Click to select a date range" useDefaultValue="true" defaultType="RANGE_CONSTANT" defaultValue="3" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:StepView
    ID            = "step3" 
    reportNumber  = "7" 
    displayGenPDF = "false"
    runat         = "server">
        
  </Spedmon:StepView>

</Spedmon:Steps>   
