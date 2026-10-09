<%@ Page Language="C#" CodeBehind="rpt_plan_svc_comp_one_patient.aspx.cs" Inherits="Spedmon.rpt_plan_svc_comp_one_patient" %>

<%/****************************
   * View stats on services 
   * rendered for one patient 
   * for compliance purposes
   ****************************/%>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" dataURL="servicerecords.ashx">
  
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list"
   optional="false"
   runat="server">
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
  </Spedmon:Step>    
  
  <%/*************************************[ Step 2 ]************************************/%>
    
  <Spedmon:StepSelectPatient 
    ID               = "step2" 
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
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step 
    ID                = "step3" 
	  title             = "Select the date range for the patient you are verifying service compliance"
    instructionFormat = "UL_LIST"
    instructions      = "<li>To verify based on a service authorization date, select All Dates After and select date</li><li>To verify based on a specific date range, select Date Range and select the start and end date</li>"
    optional          = "false"
    runat             = "server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" title="Click to select a date range" useDefaultValue="true" defaultType="RANGE_CONSTANT" defaultValue="3" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepView
    ID            = "step4" 
    reportNumber  = "7" 
    displayGenPDF = "false"
    runat         = "server">
        
  </Spedmon:StepView>

</Spedmon:Steps>   
