<%@ Page Language="C#" CodeBehind="client_coor_svcrec_edit_delete.aspx.cs" Inherits="Spedmon.ClientCoorServiceRecordsEditDelete" %>

<%/****************************
  * Select Service Record
  * for client for edit/delete
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" dataURL="servicerecords.ashx">
    
 
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
  
  <Spedmon:Step 
  
    ID           = "step3" 
    title        = "What Entry Dates?"
    instructions = "Click to select a date range or type in a date or date range"
    optional     = "false"
    runat        = "server">

    <Spedmon:DateBoxRange ID="entrydaterange" name="entrydaterange" title="Click to select a date range" useDefaultValue="true" defaultType="RANGE_CONSTANT" defaultValue="8" runat="server" />

  </Spedmon:Step>
 
 <%/*************************************[ Step 4 ]************************************/%>
 
 <Spedmon:StepRecordsEditDelete
  
   ID        = "step4" 
   editURL   = "client_coor_svcrec_save.aspx" 
   deleteURL = "servicerecords.asmx/delete"
   recIDPos  = "2"
   runat     = "server">
   
   <input id="reference" name="reference" value="" style="display:none"/>  
  
  </Spedmon:StepRecordsEditDelete>
    
</Spedmon:Steps>