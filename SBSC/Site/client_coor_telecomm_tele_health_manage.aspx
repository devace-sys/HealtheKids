<%@ Page Language="C#" CodeBehind="client_coor_telecomm_tele_health_manage.aspx.cs" Inherits="Spedmon.ClientCoorTeleCommTeleHealthManage" %>

 <Spedmon:Steps 
   ID         = "editdelete" 
   autoHeight = "false" 
   autoScroll = "true" 
   dataURL    = "telecomm_sessions_tele_health.ashx"
   runat      = "server">
         
  <%/************************************* [ Step 1 ] ************************************/%>
  
  <Spedmon:StepSelectPractitioner 
     ID                    = "step1" 
     showaddpractitioner   = "false"
     showdatasource        = "false"
     savedatasource        = "false"       
     showpractionernotes   = "false" 
     selecttype            = "COMBO_BOX" 
     selectall             = "true" 
     selectdelay           = "0" 
     selectid              = "pracid"
     runat                 = "server">
  </Spedmon:StepSelectPractitioner> 

  <%/************************************* [ Step 2 ] ************************************/%>
  
  <Spedmon:StepRecordsAddNewEditDeleteView     
    ID                          = "step2" 
    addNewIsSubPage             = "true"
    editIsSubPage               = "true"    
    addNewUrl                   = "user_all_telecomm_tele_health_save.aspx"
    editURL                     = "user_all_telecomm_tele_health_save.aspx" 
    deleteURL                   = "telecomm_sessions_tele_health.asmx/delete"
    addParmsToActionURLFnAddNew = "addParmsToAddNew"
    title                       = "Select Upcoming Session to Edit or Delete"
    instructions                = "Select the upcoming session you wish to edit or delete from the list below"
    recIDPos                    = "2" 
    runat                       = "server">         
 

    <Spedmon:RecordOpButton 
       ID       = "joinSession"   
       text     = "Join Meeting"
       saveType = "EDIT" 
       icon     = "ui-icon-arrowthick-1-s"
       opUrl    = "telecomm_sessions_tele_health.asmx/gettelecommsessionparticipantforuserid"
       opFn     = "$.spedmonWebUI.recOpJoinTeleCommMeetingUsingUserID(recID,opURL,$st)" 
       runat    = "server"/>
   
  </Spedmon:StepRecordsAddNewEditDeleteView>
</Spedmon:Steps>

<Spedmon:Script ID="preOptions" runat="server">

function addParmsToAddNew() { 
  var prmsOut = ''; 
  var cltid  = '<%=uInfo.userClientIDStr%>';  
  var pracid = $('#pracid').val();
  if (cltid) prmsOut  = prmsOut + '&clientid=' + cltid;   
  if (pracid) prmsOut = prmsOut + '&pracid=' + pracid;           
  return prmsOut;
}

</Spedmon:Script>
