<%@ Page Language="C#" CodeBehind="sbs_all_service_journals_prescribed_orders_edit_delete.aspx.cs" Inherits="Spedmon.SBSAllServiceJournalsPrescribedOrdersEditDelete" %>

 <Spedmon:Steps 
   ID         = "editdelete" 
   autoHeight = "false" 
   autoScroll = "true" 
   dataURL    = "servicejournalsprescribedorders.ashx"
   runat      = "server">
   
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID             = "step1"
	  title          = "Who is the Client?"
    instructions   = "Start typing the client name or click on the down arrow for a list" 
    ondataselected = "" 
    runat          = "server">
    
    <Spedmon:StepSelectionOptions ID="step1options" runat="server">
      <Spedmon:Button ID="dspNotesClient" icon="ui-icon-note" onclick="doShowNotesClient()" runat="Server">Notes</Spedmon:Button>
    </Spedmon:StepSelectionOptions>
    
    <Spedmon:ComboBox ID="clientid" name="clientid" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 


   <script type="text/javascript">
     function doShowNotesClient ()
     {
       var $stp  = $('#step1');
       var tkn   = $.spedmonWebUI.token;
       var cltid = $('#clientid').val();
       var url   = "clients.asmx/viewEntity?tkn=" + tkn;
       var $data = "{'clientid':" + cltid + "}";
       var notes = "";
       var name = "";
       $.spedmonWebUI.ajax($stp, url, $data, null, null, function(rd) { name = 'Client notes for ' + rd.data.entity.name; notes = rd.data.entity.notes; }, null, null, 0, function() {$.spedmonWebUI.dialogMessage(name, $.spedmonWebUI.formattedTextToHTML(notes, 'ui-spedmon-dialog-mono-txt'), true, 800, 400) });       
       return;
     }

   </script>
  </Spedmon:Step>
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:StepSelectPatient 
    ID               = "step2" 
    showaddpatient   = "false" 
    showpatientnotes = "false"
    showdatasource   = "false"   
    selecttype       = "SEARCH_BOX" 
    selectall        = "true" 
    selectdelay      = "0" 
    selectid         = "patid"  
    runat            = "server">
  </Spedmon:StepSelectPatient>    

  <%/*************************************[ Step 3 ]************************************/%>
     
  <Spedmon:Step 
    ID           = "step3" 
	  title        = "What Dates?"
    instructions = "Click to select an effective date range or type in a date or date range"
    runat        = "server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" value="" title="Click to select a date range" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepRecordsEditDelete 
    ID                = "step4" 
    editURL           = "user_all_order_prescription_save.aspx" 
    deleteURL         = "servicejournalsprescribedorders.asmx/delete"
    title             = "Select Order to Edit or Delete"
    instructions      = "Select the order you wish to edit or remove from list"
    recIDPos          = "2" 
    runat             = "server">
    
   <Spedmon:HiddenInput id="active"    name="active"    title="active"   value="1"  runat="server"/>
        
  </Spedmon:StepRecordsEditDelete>    

</Spedmon:Steps>
