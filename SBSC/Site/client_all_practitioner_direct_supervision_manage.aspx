<%@ Page Language="C#" CodeBehind="client_all_practitioner_direct_supervision_manage.aspx.cs" Inherits="Spedmon.ClientAllPractitionerDirectSupervisionManage" %>

 <Spedmon:Steps 
   ID         = "editdelete" 
   autoHeight = "false" 
   autoScroll = "true" 
   dataURL    = "practitioner_direct_supervisors.ashx"
   runat      = "server">

     
  <%/************************************* [ Step 1 ] ************************************/%>
  
  <Spedmon:StepRecordsAddNewEditDeleteView     
    ID                          = "step1"
    addNewButtonLabel           = "Create New Supervision Tracking Records"
    editButtonLabel             = "Edit Existing Supervision Tracking Records"
    addNewIsSubPage             = "true"
    editIsSubPage               = "true"    
    addNewUrl                   = "user_all_practitioner_direct_supervisor_save.aspx"
    editURL                     = "user_all_practitioner_direct_supervisor_save.aspx" 
    hasEdit                     = "true"
    hasDelete                   = "false"
    title                       = "Select Supervision Tracking Record to Edit"
    instructions                = "Select the record you wish to edit from the list below"
    recIDPos                    = "2" 
    runat                       = "server">   
      

  </Spedmon:StepRecordsAddNewEditDeleteView>

</Spedmon:Steps>


