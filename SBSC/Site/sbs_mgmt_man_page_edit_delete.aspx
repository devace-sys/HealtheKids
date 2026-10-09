<%@ Page Language="C#" CodeBehind="sbs_mgmt_man_page_edit_delete.aspx.cs" Inherits="Spedmon.SBSMgmtManPageEditDelete" %>


 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="man_pages.ashx">
   
  <%/*************************************[ Step 1 ]************************************/%>

   <Spedmon:StepRecordsAddNewEditDeleteView     
    ID                          = "step1" 
    addNewIsSubPage             = "false"
    editIsSubPage               = "false"    
    addNewUrl                   = "sbs_mgmt_man_page_save.aspx"
    editURL                     = "sbs_mgmt_man_page_save.aspx" 
    deleteURL                   = "man_pages.asmx/delete"
    title                       = "Select announcement to Edit, Republish, or Delete"
    instructions                = "Select the announcement you wish to edit, resend, or delete from the list below"
    recIDPos                    = "2" 
    activeFlag                  = "true"
    runat                       = "server">     


     <Spedmon:RecordOpButton 
       ID        = "resendNotif"   
       saveType  = "EDIT" 
       text      = "Republish and Reset"
       icon      = "ui-icon-mail-closed"
       opUrl     = "man_pages.asmx/resetandrepublish"
       opIsMulti = "false"
       opFn      = "doResetAndRepublishManPage(opURL, recID, $st)"
       runat     = "server"/>  
  
  </Spedmon:StepRecordsAddNewEditDeleteView>
    
</Spedmon:Steps>


<Spedmon:Script runat="server">                  

 function doResetAndRepublishManPage (opURL, recID, $st)
 {
    var fnDoYes = function () {      
      $.spedmonWebUI.ajax(null,opURL,'{recid: ' + recID + '}',null,null,null,null,$st,1,function(){
        $($st).spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,'Notifications will be sent to all recipients for this announcement',0);
      }); 
    };

    $.spedmonWebUI.dialogConfirm( 'Republish and Reset Announcement?'
                                 ,'Are you sure you want to republish this announcement?  All user read statistics for this announcement will be cleared and all intended recipients will receive a new email notification and will have to reacknowledge that they have read the announcement.  This operation cannot be undone!  Click on Yes if you are absolutely sure you want to do this.'
                                 , fnDoYes
                                 , null);
 }
  
</Spedmon:Script>