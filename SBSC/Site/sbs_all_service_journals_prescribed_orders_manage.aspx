<%@ Page Language="C#" CodeBehind="sbs_all_service_journals_prescribed_orders_manage.aspx.cs" Inherits="Spedmon.SBSAllServiceJournalsPrescribedOrdersManage" %>

 <Spedmon:Steps 
   ID         = "editdelete" 
   autoHeight = "false" 
   autoScroll = "true" 
   dataURL    = "orp_documents.ashx"
   runat      = "server">
   
   <%/*************************************[ Step 1 ]************************************/%>
  
   <Spedmon:Step 
     ID             = "step1"
	   title          = "Who is the Client?"
     instructions   = "Start typing the client name or click on the down arrow for a list" 
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
  
   <%/************************************* [ Step 2 ] ************************************/%>

   <Spedmon:Step 
     ID            = "step2" 
     title         = "What practitioner groups will be rendering the ordered service?"
     instructions  = "Select the practitioner groups that this order applies to"
     runat         = "server">

     <Spedmon:ComboBox ID="groupServiceClassNameID" name="groupServiceClassNameID" title="Select Discipline Family" dataPrivate="true" dataURL ="groups_service_classes.asmx/viewSelForOrpDocs" dataParms="[{}]" runat="server" />
 
   </Spedmon:Step>

   <%/*************************************[ Step 3 ]************************************/%>
  
   <Spedmon:StepSelectPatient 
     ID               = "step3" 
     showaddpatient   = "false" 
     showpatientnotes = "false"
     showdatasource   = "false"   
     selecttype       = "SEARCH_BOX" 
     selectall        = "true" 
     selectdelay      = "0" 
     selectid         = "patid"  
     runat            = "server">
   </Spedmon:StepSelectPatient>    

  <%/************************************* [ Step 4 ] ************************************/%>
  
  <Spedmon:StepRecordsAddNewEditDeleteView     
    ID                          = "step4" 
    addNewIsSubPage             = "true"
    editIsSubPage               = "true"    
    addNewUrl                   = "user_all_order_prescription_save.aspx"
    editURL                     = "user_all_order_prescription_save.aspx" 
    deleteURL                   = "orp_documents.asmx/deleteOrderOrProfile"
    addParmsToActionURLFnAddNew = "addParmsToAddNew"
    addParmsToActionURLFnEdit   = "addParmsToAddNew"
    reportNumber                = "2"
    title                       = "Select Order to Edit or Delete"
    instructions                = "Select the order you wish to edit or remove from list"
    recIDPos                    = "2" 
    runat                       = "server">
      
      <Spedmon:HiddenInput ID="daterange" name="daterange" title="daterange" value="" runat="server"/> 
      
      <Spedmon:RecordOpButton 
           ID        = "requestAuthorizationBut"
           cssClass  = "eauthorize-request-authorization"
           saveType  = "EDIT" 
           text      = "Request Authorization"
           icon      = "ui-icon-mail-closed"
           opIsMulti = "false"
           opUrl     = "user_all_service_authorization_request_save.aspx"
           opFn      = "requestServiceAuthorization (opURL, $recs, rowIdx)"
           runat     = "server"/> 

  </Spedmon:StepRecordsAddNewEditDeleteView>
</Spedmon:Steps>


<Spedmon:Script ID="preOptions" runat="server">


function addParmsToAddNew() { 
  var prmsOut = ''; 
  
  var cltid  = $('#clientid').val();  
  var patid  = $('#patid').val();
  var grpid  = $('#groupServiceClassNameID').val();
  
  if (cltid) prmsOut = prmsOut + '&patclientid='       + cltid;   
  if (patid) prmsOut = prmsOut + '&patpatientid='      + patid;           
  if (grpid) prmsOut = prmsOut + '&patgrpsvcclsnmeid=' + grpid;
    
  return prmsOut;
}

function requestServiceAuthorization (opURL, $recs, rowIdx) {

    /* Note: Column indexes are different that all other roles since an active column is shown */

    let aSelRowData = $recs.dataTable().fnGetData(rowIdx);

    var reqSvcAuthUrl = opURL 
                      + '&amd=uidbssub'
                      + '&referencedEntityID=' + aSelRowData[21]
                      + '&svcAuthorizationRequestTypeID=' + ((aSelRowData[22] == '3') ? 2 : 1)
    
    $.spedmonWebUI.openURL(reqSvcAuthUrl, 2);
   
};

</Spedmon:Script>
