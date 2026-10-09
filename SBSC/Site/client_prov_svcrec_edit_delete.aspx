<%@ Page Language="C#" CodeBehind="client_prov_svcrec_edit_delete.aspx.cs" Inherits="Spedmon.ClientProvServiceRecordsEditDelete" %>

<%/****************************
  * Select Service Record
  * for client for edit/delete
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" dataURL="servicerecords.ashx">
    
  <%/*************************************[ Step 1 ]************************************/%>
    
  <Spedmon:StepSelectPatient ID="step1" 
    optional="true"
    showaddpatient="false" 
    showpatientnotes="false"
    showdatasource="true"   
    selecttype="COMBO_BOX" 
    selectall="false" 
    selectdelay="1000" 
    selectid="patid"
    runat="server">
    
  </Spedmon:StepSelectPatient>
 
    
    <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step2" 
    title        = "What Entry Dates?"
    instructions = "Click to select a date range or type in a date or date range"
    optional     = "false"
    runat        = "server">

    <Spedmon:DateBoxRange ID="entrydaterange" name="entrydaterange" title="Click to select a date range" useDefaultValue="true" defaultType="RANGE_CONSTANT" defaultValue="8" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 3 ]************************************/%>
  
    <Spedmon:StepRecordsEditDelete ID="step3" 
                               editURL   = "client_prov_svcrec_save.aspx" 
                               deleteURL = "servicerecords.asmx/delete"
                               recIDPos  = "2"
                               runat="server">
    
      <input id="reference" name="reference" value="" style="display:none"/>  
    </Spedmon:StepRecordsEditDelete>
    
</Spedmon:Steps>