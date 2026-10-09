<%@ Page Language="C#" CodeBehind="client_coor_service_journals_prescribed_orders_manage.aspx.cs" Inherits="Spedmon.ClientCoorServiceJournalsPrescribedOrdersManage" %>

 <Spedmon:Steps 
   ID         = "editdelete" 
   autoHeight = "false" 
   autoScroll = "true" 
   dataURL    = "orp_documents.ashx"
   runat      = "server">
   
  
   <%/************************************* [ Step 1 ] ************************************/%>

   <Spedmon:Step 
     ID            = "step1" 
     title         = "What practitioner groups will be rendering the ordered service?"
     instructions  = "Select the practitioner groups that this order applies to"
     runat         = "server">

     <Spedmon:ComboBox ID="groupServiceClassNameID" name="groupServiceClassNameID" title="Select Discipline Family" dataPrivate="true" dataURL ="groups_service_classes.asmx/viewSelForOrpDocs" dataParms="[{}]" runat="server" />
 
   </Spedmon:Step>

   <%/*************************************[ Step 2 ]************************************/%>
  
   <Spedmon:StepSelectPatient 
     ID               = "step2" 
     showaddpatient   = "false" 
     showpatientnotes = "false"
     showdatasource   = "false"   
     selecttype       = "COMBO_BOX" 
     selectall        = "true" 
     selectdelay      = "0" 
     selectid         = "patid"  
     runat            = "server">
   </Spedmon:StepSelectPatient>    
  
  <%/************************************* [ Step 3 ] ************************************/%>
  
  <Spedmon:StepRecordsAddNewEditDeleteView     
    ID                          = "step3" 
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
  
  
   <Spedmon:HiddenInput ID="clientid" name="clientid"  title="clientid" noClear="true" runat="server"/>
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

function addParmsToAddNew()
{ 
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
    let aSelRowData = $recs.dataTable().fnGetData(rowIdx);

    var reqSvcAuthUrl = opURL 
                      + '&amd=uidbssub'
                      + '&referencedEntityID=' + aSelRowData[18]
                      + '&svcAuthorizationRequestTypeID=' + ((aSelRowData[19] == '3') ? 2 : 1)
    
    $.spedmonWebUI.openURL(reqSvcAuthUrl, 2);
   
};

</Spedmon:Script>
