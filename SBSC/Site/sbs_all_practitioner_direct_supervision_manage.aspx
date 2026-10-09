<%@ Page Language="C#" CodeBehind="sbs_all_practitioner_direct_supervision_manage.aspx.cs" Inherits="Spedmon.SBSAllPractitionerDirectSupervisionManage" %>

 <Spedmon:Steps 
   ID         = "editdelete" 
   autoHeight = "false" 
   autoScroll = "true" 
   dataURL    = "practitioner_direct_supervisors.ashx"
   runat      = "server">
   
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
      ID             = "step1" 
      title          = "Who is the Client? (Note: You MUST select a client)"
      instructions   = "Start typing the client name or click on the down arrow for a list"
      optional       = "false"
      runat          = "server">
              
    <Spedmon:ComboBox 
      ID          = "clientid" 
      name        = "clientid" 
      value       = "" 
      title       = "Select Client" 
      dataPrivate = "true" 
      dataURL     = "clients.asmx/viewSel" 
      runat       = "server" /> 

  </Spedmon:Step>
      
  <%/************************************* [ Step 2 ] ************************************/%>
  
  <Spedmon:StepRecordsAddNewEditDeleteView     
    ID                          = "step2"
    addNewButtonLabel           = "Create New Supervision Tracking Records"
    editButtonLabel             = "Edit Existing Supervision Tracking Records"
    addNewIsSubPage             = "true"
    editIsSubPage               = "true"    
    addNewUrl                   = "user_all_practitioner_direct_supervisor_save.aspx"
    editURL                     = "user_all_practitioner_direct_supervisor_save.aspx" 
    hasEdit                     = "true"
    hasDelete                   = "false"
    addParmsToActionURLFnAddNew = "addParms"    
    addParmsToActionURLFnEdit   = "addParms"
    title                       = "Select Supervision Tracking Record to Edit"
    instructions                = "Select the record you wish to edit from the list below"
    recIDPos                    = "2" 
    runat                       = "server">         
  </Spedmon:StepRecordsAddNewEditDeleteView>

</Spedmon:Steps>

<Spedmon:Script ID="preOptions" runat="server">

function addParms() { 
  var prmsOut = ''; 
  
  var cltid  = $('#clientid').val();  
  
  if (cltid) prmsOut = prmsOut + '&clientid=' + cltid;   
    
  return prmsOut;
}

</Spedmon:Script>
