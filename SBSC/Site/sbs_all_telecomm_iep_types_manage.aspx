<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="sbs_all_telecomm_iep_types_manage.aspx.cs" Inherits="Spedmon.TelecommIEPTypesManage" %>

<Spedmon:Steps 
   ID         = "editdelete" 
   autoHeight = "false" 
   autoScroll = "true" 
   dataURL    = "telecomm_iep_types.ashx"
   runat      = "server">


  <%/************************************* [ Step 1 ] ************************************/%>
  
  <Spedmon:StepRecordsAddNewEditDeleteView     
    ID                          = "step1" 
    addNewIsSubPage             = "true"
    editIsSubPage               = "true"    
    addNewUrl                   = "sbs_all_telecomm_iep_types_save.aspx"
    editURL                     = "sbs_all_telecomm_iep_types_save.aspx" 
    deleteURL                   = "telecomm_iep_types.asmx/delete"
    title                       = "Select a row to edit or delete"
    instructions                = "Select the telecomm IEP type you wish to edit or delete from the list below"
    recIDPos                    = "2"
    runat                       = "server">         
  
  </Spedmon:StepRecordsAddNewEditDeleteView>

</Spedmon:Steps>
