<%@ Page Language="C#" CodeBehind="user_all_plan_writer_diagnoses_manage.aspx.cs" Inherits="Spedmon.UserAllPlanWriterDiagnosesManage" %>

 <Spedmon:Steps 
   ID         = "editdelete" 
   autoHeight = "false" 
   autoScroll = "true" 
   dataURL    = "plan_writer_diagnoses.ashx"
   runat      = "server">
   
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
      ID             = "step1" 
      title          = "Who is the Client?"
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
    addNewButtonLabel           = "Create New Diagnosis"
    editButtonLabel             = "Edit Existing Diagnosis"
    addNewIsSubPage             = "true"
    editIsSubPage               = "true"    
    addNewUrl                   = "user_all_plan_writer_diagnosis_save.aspx"
    editURL                     = "user_all_plan_writer_diagnosis_save.aspx" 
    hasEdit                     = "true"
    hasDelete                   = "true"
    deleteURL                   = "plan_writer_diagnoses.asmx/delete"
    displayGenHTM               = "false"
    displayGenXLS               = "false"
    addParmsToActionURLFnAddNew = "addParms"    
    addParmsToActionURLFnEdit   = "addParms"
    title                       = "Select Diagnosis to Edit"
    instructions                = "Select the diagnosis you wish to edit from the list below"
    recIDPos                    = "2" 
    runat                       = "server">         
  </Spedmon:StepRecordsAddNewEditDeleteView>

</Spedmon:Steps>

<Spedmon:Script ID="preOptions" runat="server">

function addParms() { 
  var prmsOut = ''; 
  
  var cltid  = $('#clientid').val();

  var templatetype = 1;
  if (cltid) {
    templatetype = 2;
    }
  
  prmsOut = prmsOut + ((cltid) ? '&clientid=' + cltid : '') + '&templatetype=' + templatetype;   
    
  return prmsOut;
}

</Spedmon:Script>
