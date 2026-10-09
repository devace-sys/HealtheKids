<%@ Page Language="C#" CodeBehind="client_prov_service_journals_service_descriptions_manage.aspx.cs" Inherits="Spedmon.ClientProvServiceJournalsServiceDescriptionsManage" %>

 <Spedmon:Steps 
   ID         = "editdelete" 
   autoHeight = "false" 
   autoScroll = "true" 
   dataURL    = "servicejournalsservicedescriptions.ashx"
   runat      = "server">
     
   <%/*************************************[ Step 1 ]************************************/%>
  
   <Spedmon:StepSelectPatient 
     ID               = "step1" 
     showaddpatient   = "false" 
     showpatientnotes = "false"
     showdatasource   = "false"   
     selecttype       = "COMBO_BOX" 
     selectall        = "true" 
     selectdelay      = "0" 
     selectid         = "patid"  
     runat            = "server">
   </Spedmon:StepSelectPatient>    
  
  <%/************************************* [ Step 2] ************************************/%>
  
  <Spedmon:StepRecordsAddNewEditDeleteView     
    ID                          = "step2" 
    addNewIsSubPage             = "true"
    editIsSubPage               = "true"        
    addNewUrl                   = "user_all_patient_profile_save.aspx"
    editURL                     = "user_all_patient_profile_save.aspx" 
    deleteURL                   = "servicejournalsservicedescriptions.asmx/delete"
    addParmsToActionURLFnAddNew = "addParmsToAddNew"
    title                       = "Patient Profiles"
    instructions                = "Add a new profile, select a profile from the list to edit or delete, or select a reporting option."
    recIDPos                    = "2" 
    runat                       = "server">     

   <Spedmon:HiddenInput ID="clientid" name="clientid"  title="clientid" noClear="true" runat="server"/>
   <Spedmon:HiddenInput ID="pracid" name="pracid"  title="pracid" noClear="true" runat="server"/>
   
    <Spedmon:RecordOpButton 
       ID        = "requestAuthorizationBut"
       cssClass  = "eauthorize-request-authorization"
       saveType  = "EDIT" 
       text      = "Request Authorization"
       icon      = "ui-icon-mail-closed"
       opIsMulti = "false"
       opUrl     = "user_all_service_authorization_request_save.aspx"
       opFn      = "requestServiceAuthorization (recID, 2, opURL)"
       runat     = "server"/> 
  
  </Spedmon:StepRecordsAddNewEditDeleteView>
    
</Spedmon:Steps>


<Spedmon:Script ID="preOptions" runat="server">

function addParmsToAddNew()
{ 
  var prmsOut = '';   
  var cltid  = $('#clientid').val();  
  var prcid  = $('#pracid').val();
  var patid  = $('#patid').val();  
  if (cltid) prmsOut = prmsOut + '&patclientid='  + cltid;
  if (patid) prmsOut = prmsOut + '&patpatientid=' + patid;
  if (prcid) prmsOut = prmsOut + '&patpracid='    + prcid;
  return prmsOut;
}

function requestServiceAuthorization (referencedEntityID, svcAuthorizationRequestTypeID, opURL) {
    var reqSvcAuthUrl = opURL 
                      + '&amd=uidbssub'
                      + '&referencedEntityID=' + referencedEntityID
                      + '&svcAuthorizationRequestTypeID=' + svcAuthorizationRequestTypeID
    
    $.spedmonWebUI.openURL(reqSvcAuthUrl, 2);
   
};
</Spedmon:Script>
