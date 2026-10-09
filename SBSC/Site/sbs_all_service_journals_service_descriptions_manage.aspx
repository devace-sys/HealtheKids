<%@ Page Language="C#" CodeBehind="sbs_all_service_journals_service_descriptions_manage.aspx.cs" Inherits="Spedmon.SBSAllServiceJournalsServiceDescriptionsManage" %>

 <Spedmon:Steps 
   ID         = "editdelete" 
   autoHeight = "false" 
   autoScroll = "true" 
   dataURL    = "servicejournalsservicedescriptions.ashx"
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

  
  <%/************************************* [ Step 3 ] ************************************/%>
  
  <Spedmon:StepRecordsAddNewEditDeleteView     
    ID                          = "step3" 
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
  var patid  = $('#patid').val();  
  if (cltid) prmsOut = prmsOut + '&patclientid='       + cltid;   
  if (patid) prmsOut = prmsOut + '&patpatientid='      + patid;               
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
