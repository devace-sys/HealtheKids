<%@ Page Language="C#" CodeBehind="client_coor_svcrec_view.aspx.cs" Inherits="Spedmon.ClientCoorServiceRecordsView" %>

<%/****************************
  * View Service Record
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" dataURL="servicerecords.ashx">
  
  <%/*************************************[ Step 1 ]************************************/%>
    
 <Spedmon:StepSelectPractitioner 
    ID                    = "step1" 
    optional              = "false" 
    showaddpractitioner   = "false"
    showdatasource        = "false"
    savedatasource        = "false"       
    showpractionernotes   = "false"
    showpractionerqforms  = "false"
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
    selectall        = "true" 
    selectdelay      = "1000" 
    selectid         = "patid"  
    runat            = "server">
  </Spedmon:StepSelectPatient> 
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step ID="step3" title="What Dates?"
    instructions="Click to select a date range or type in a date or date range"
    optional="true"
    runat="server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" title="Click to select a date range" useDefaultValue="true" defaultType="RANGE_CONSTANT" defaultValue="3" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepView ID="step4" runat="server">
    
    <Spedmon:HiddenInput ID="clientid"      name="clientid"      title="client id" runat="server"/> 
  
  </Spedmon:StepView>

</Spedmon:Steps>   
