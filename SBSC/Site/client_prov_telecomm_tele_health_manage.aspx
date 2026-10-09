<%@ Page Language="C#" CodeBehind="client_prov_telecomm_tele_health_manage.aspx.cs" Inherits="Spedmon.ClientProvTeleCommTeleHealthManage" %>

 <Spedmon:Steps 
   ID         = "editdelete" 
   autoHeight = "false" 
   autoScroll = "true" 
   dataURL    = "telecomm_sessions_tele_health.ashx"
   runat      = "server">
         
  <%/************************************* [ Step 1 ] ************************************/%>
  
  <Spedmon:StepRecordsAddNewEditDeleteView     
    ID                          = "step1" 
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
  var pracid = '<%=uInfo.userPracIDStr%>';
  if (cltid) prmsOut  = prmsOut + '&clientid=' + cltid;   
  if (pracid) prmsOut = prmsOut + '&pracid=' + pracid;           
  return prmsOut;
}

</Spedmon:Script>