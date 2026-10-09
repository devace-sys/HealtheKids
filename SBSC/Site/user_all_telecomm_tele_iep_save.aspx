<%@ Page Language="C#" CodeBehind="user_all_telecomm_tele_iep_save.aspx.cs" Inherits="Spedmon.UserAllTeleCommTeleIEPSave" %>
 
<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>

<Spedmon:DataEntryRows purpose="SAVE" dataURL="telecomm_sessions_tele_iep.asmx/save" runat="server">

<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectClient
    ID              = "selectClient" 
    entityControlID = "clientid"                
    rowLabel        = "Client" 
    runat           = "server">
</Spedmon:DataEntryRowSelectClient>


<%//-----------------------------------------------------------------------------%>
<%// Select a Patient %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPatient
    ID                      = "selectPatient" 
    rowLabel                = "Select a Patient" 
    entityControlID         = "patid"  
    preSelectedDataSource   = "ALL_PATIENTS"
    showDataSourceSelection = "false"
    showAddNew              = "false" 
    showEditSelected        = "false"
    runat                 = "server">
</Spedmon:DataEntryRowSelectPatient>

<%//-----------------------------------------------------------------------------%>
<%// Type of IEP %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="selectIEPFormType" rowLabel="Select IEP Format" runat="server">

   <Spedmon:ComboBox 
     ID            = "iepformtype" 
     name          = "iepformtype" 
     title         = "Select IEP Format"
     displayInline = "true"
     dataPrivate   = "true" 
     dataURL       = "telecomm_iep_types.asmx/viewSel" 
     dataParms     = "[]" 
     runat         = "server" />  
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Select a Facilitator %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectUser 
    ID              = "selectFacilitator" 
    entityControlID = "facilitatoruserid"                
    rowLabel        = "Select an IEP Meeting Contact" 
    runat           = "server">
</Spedmon:DataEntryRowSelectUser>

<%//-----------------------------------------------------------------------------%>
<%// Participants %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterParticipantDetails" rowLabel="IEP Participants" runat="server">
          
  <Spedmon:DataGrid 
     ID             = "participantdetails" 
     name           = "participantdetails"
     title          = "Enter Participant Details"
     classAssembly  = "AppFramework"
     className      = "MBA.TeleCommParticipant"  
     sortRowsByKey  = "true" 
     showControls   = "false"
     runat          = "server"/>
 
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Title %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterMeetingTitle" rowLabel="IEP Meeting Title" runat="server">

  <Spedmon:TextBox ID="title" name="title" maxlen="512" showOK="false" title="Enter a short title that uniquely identifies this IEP meeting" runat="server" />

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Meeting Date %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="selectOrEnterMeetingDate" rowLabel="IEP Meeting Date" runat="server">
  
  <Spedmon:DateBox 
    ID              = "meetingdate" 
    name            = "meetingdate" 
    title           = "mm/dd/yyyy"     
    numMonths       = "1"
    maxDate         = ""
    showOK          = "false"    
    runat           = "server" />

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Meeting Time %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="selectOrEnterMeetingTime" rowLabel="IEP Meeting Time" runat="server">

  <Spedmon:TimeBox 
    ID              = "meetingtime" 
    name            = "meetingtime" 
    title           = "hh:mm:ss"
    showOK          = "false"
    runat           = "server" />

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Meeting Duration %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="selectOrEnterMeetingDuration" rowLabel="IEP Meeting Duration (in minutes)" runat="server">

  <Spedmon:NumberBox 
    ID      = "meetingdurationinmins" 
    name    = "meetingdurationinmins" 
    title   = "Enter number of minutes"
    showOK  = "false"
    runat   = "server" />

</Spedmon:DataEntryRow>


<%//-----------------------------------------------------------------------------%>
<%// Files to Share During Meeting %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectStoredFile
   ID                              = "selectFiles"  
   rowLabel                        = "Files to Share During Meeting (Note: ONLY PDF files are supported at this time)"
   entityControlID                 = "filestoshareuploadids"
   multiSelect                     = "true"
   multiSelectListTitle            = "Files to Share During Meeting (PDF files only please)"
   runat                           = "server">

  <Spedmon:Button ID="butmanagefiles" title="Click here To Add New Files" onclick="manageTeleIEPFileLibrary()" runat="server">Manage Library</Spedmon:Button>

</Spedmon:DataEntryRowSelectStoredFile>

<%//-----------------------------------------------------------------------------%>
<%// Save or Edit %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSaveOrEdit 
    ID                               = "saveOrEdit" 
    editDelManageLink                = "telecommtelehealthmanagelink"
    runat                            = "server">

  <Spedmon:HiddenInput ID="fileclass"      name="fileclass"      title="fileclass"     noClear="true" runat="server" />
  <Spedmon:HiddenInput ID="filenamespace"  name="filenamespace"  title="filenamespace" noClear="true" runat="server" />
  <Spedmon:HiddenInput ID="filesource"     name="filesource"     title="filesource"    noClear="true" runat="server" />

</Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>


<%//##################################################################################################################%>
<%//#                                         Data Entry Scripts  %>
<%//##################################################################################################################%>

<script type="text/javascript">

 var participantRoleOther   = '88';
 var participantRolePatient = '99';

 var clsHideUntilNeeded = 'ui-spedmon-data-entry-row-input-hide-until-needed';
 var sessionTitleSelector                 = '#title';
 var enterParticipantDetailsSelector      = '#enterParticipantDetails';
 var enterMeetingTitleSelector            = '#enterMeetingTitle';
 var selectOrEnterMeetingDateSelector     = '#selectOrEnterMeetingDate';
 var selectOrEnterMeetingTimeSelector     = '#selectOrEnterMeetingTime';
 var selectOrEnterMeetingDurationSelector = '#selectOrEnterMeetingDuration';
 var enterMeetingContentSelector          = '#enterMeetingContent';
 
  /**************************************************************************
   * lockRequiredParticipantTitles() */
  /**
   * 
   *
   **************************************************************************/

  function lockRequiredParticipantTitles() {    
     var dgObj = $('#participantdetails').data('spedmondatagrid');     
      let titleCells = dgObj.getCol(4);
      $(titleCells).each(function (idx, titleCell) {         
          let inpTitle = $(titleCell).find('input').first();
          $(inpTitle).attr('readonly', 'readonly');         
          if (idx >= 5) return false;
      });
  }

  /**************************************************************************
   * manageTeleIEPFileLibrary() */
  /**
   * 
   *
   **************************************************************************/


function manageTeleIEPFileLibrary () {

  let cid = $('#clientid').val();
  let pid = $('#patid').val();      
  if ((cid != '') && (pid != '')) {
      var fileAdditionalDataJSONStr = '{clientid:' + cid + ', patid:' + pid + '}';
      $.spedmonWebUI.fileList(  '<%=Spedmon.TeleIEPSessions.SEL_LABEL%>'
                              , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>'
                              , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
                              , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
                              , 3 /* Record id position */
                              , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
                              , '<%=Spedmon.TeleIEPSessions.VAL_FILE_CLASS%>'
                              , '' /* File subclass */
                              , '<%=Spedmon.TeleIEPSessions.VAL_FILE_NAMESPACE%>'
                              , '<%=Spedmon.TeleIEPSessions.VAL_FILE_SOURCE%>'
                              , fileAdditionalDataJSONStr
                              , true
                              , true);
  }
}

$( document ).ready(function() {
    lockRequiredParticipantTitles();
});
</script>
