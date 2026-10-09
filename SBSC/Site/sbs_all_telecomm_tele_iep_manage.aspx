<%@ Page Language="C#" CodeBehind="sbs_all_telecomm_tele_iep_manage.aspx.cs" Inherits="Spedmon.SBSAllTeleCommTeleIEPManage" %>

 <Spedmon:Steps 
   ID         = "editdelete" 
   autoHeight = "false" 
   autoScroll = "true" 
   dataURL    = "telecomm_sessions_tele_iep.ashx"
   runat      = "server">
   
   <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
      ID             = "step1" 
      title          = "Who is the Client?"
      instructions   = "Start typing the client name or click on the down arrow for a list"
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
  
 
  <%/*************************************[ Step 2 ]************************************/%>
    
 <Spedmon:StepSelectPatient 
    ID               = "step2" 
    optional         = "false"
    showaddpatient   = "false" 
    showpatientnotes = "false" 
    showdatasource   = "false"   
    selecttype       = "COMBO_BOX" 
    selectall        = "true" 
    selectdelay      = "1000" 
    selectid         = "patid"  
    runat            = "server">
  </Spedmon:StepSelectPatient>
     
  <%/************************************* [ Step 3 ] ************************************/%>
  
  <Spedmon:StepRecordsAddNewEditDeleteView     
    ID                          = "step3" 
    addNewIsSubPage             = "true"
    editIsSubPage               = "true"    
    addNewUrl                   = "user_all_telecomm_tele_iep_save.aspx"
    editURL                     = "user_all_telecomm_tele_iep_save.aspx" 
    deleteURL                   = "telecomm_sessions_tele_iep.asmx/delete"
    addParmsToActionURLFnAddNew = "addParmsToAddNew"
    title                       = "Select Upcoming Meeting to Edit or Delete"
    instructions                = "Select the upcoming meeting you wish to edit or delete from the list below"
    recIDPos                    = "2" 
    runat                       = "server"> 
      
    <Spedmon:RecordOpButton 
       ID       = "joinSession"   
       text     = "Join Meeting"
       saveType = "EDIT" 
       icon     = "ui-icon-arrowthick-1-s"
       opUrl    = "telecomm_sessions_tele_iep.asmx/gettelecommsessionparticipantforuserid"
       opFn     = "$.spedmonWebUI.recOpJoinTeleCommMeetingUsingUserID(recID,opURL,$st)" 
       runat    = "server"/>

  </Spedmon:StepRecordsAddNewEditDeleteView>

</Spedmon:Steps>

<Spedmon:Script ID="preOptions" runat="server">

function addParmsToAddNew() { 
  var prmsOut = ''; 
  
  var cltid  = $('#clientid').val();  
  var patid  = $('#patid').val();

  if (cltid) prmsOut = prmsOut + '&clientid=' + cltid;   
  if (patid) prmsOut = prmsOut + '&patid=' + patid;  
  return prmsOut;
}
   
</Spedmon:Script>
