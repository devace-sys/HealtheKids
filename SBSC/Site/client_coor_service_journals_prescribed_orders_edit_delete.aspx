<%@ Page Language="C#" CodeBehind="client_coor_service_journals_prescribed_orders_edit_delete.aspx.cs" Inherits="Spedmon.ClientCoorServiceJournalsPrescribedOrdersEditDelete" %>

 <Spedmon:Steps 
   ID="editdelete" 
   autoHeight="false" 
   autoScroll="true" 
   dataURL="servicejournalsprescribedorders.ashx"
   runat="server">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:StepSelectPatient 
    ID               = "step1" 
    showaddpatient   = "false" 
    showpatientnotes = "false"
    showdatasource   = "false"   
    selecttype       = "SEARCH_BOX" 
    selectall        = "true" 
    selectdelay      = "0" 
    selectid         = "patid"  
    runat            = "server">
  </Spedmon:StepSelectPatient>    

  <%/*************************************[ Step 2 ]************************************/%>
     
  <Spedmon:Step 
    ID           = "step2" 
	title        = "What Dates?"
    instructions = "Click to select an effective date range or type in a date or date range"
    runat        = "server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" value="" title="Click to select a date range" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:StepRecordsEditDelete 
    ID                = "step3" 
    editURL           = "user_all_order_prescription_save.aspx" 
    deleteURL         = "servicejournalsprescribedorders.asmx/delete"
    title             = "Select Order to Edit or Delete"
    instructions      = "Select the order you wish to edit or remove from list"
    recIDPos          = "2" 
    runat             = "server">
    
   <Spedmon:HiddenInput ID="clientid"  name="clientid"  title="Client id"           runat="server"/>
   <Spedmon:HiddenInput ID="pracid"    name="pracid"    title="Prac id"             runat="server"/>   
   <Spedmon:HiddenInput id="active"    name="active"    title="active"   value="1"  runat="server"/>
        
  </Spedmon:StepRecordsEditDelete>
    
</Spedmon:Steps>

