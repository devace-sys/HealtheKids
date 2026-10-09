<%@ Page Language="C#" CodeBehind="user_all_telecomm_tele_health_save.aspx.cs" Inherits="Spedmon.UserAllTeleCommTeleHealthSave" %>
 
<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>

<Spedmon:DataEntryRows purpose="SAVE" dataURL="telecomm_sessions_tele_health.asmx/save" runat="server">

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
<%// Select Practitioner %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPractitioner 
   ID                              = "selectPractitioner"  
   rowLabel                        = "Practitioner"
   entityControlID                 = "pracid"    
   preSelectedDataSource           = "ALL_PRACTITIONERS"            
   runat                           = "server">
</Spedmon:DataEntryRowSelectPractitioner>

<%//-----------------------------------------------------------------------------%>
<%// Sub Type of Service %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="selectServiceSubType" rowLabel="Individual or Group Service" runat="server">

  <Spedmon:SelectServiceSubTypeIndividualOrGroup 
    ID            = "servicesubtype"
    name          = "servicesubtype"
    title         = "Select One"
    renderLabel   = "false"
    onSelectValue = "function(oldval,newval){onServiceSubTypeSelected (oldval,newval); return true;}" 
    runat         = "server">
  </Spedmon:SelectServiceSubTypeIndividualOrGroup>
  
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Select a Patient %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPatient
    ID                      = "selectIndividualPatient" 
    rowLabel                = "Select a Patient" 
    entityControlID         = "patid"  
    preSelectedDataSource   = "ALL_PATIENTS"
    showDataSourceSelection = "false"
    showAddNew              = "false" 
    showEditSelected        = "false"
    onSpedmonInputData      = "addIndividualPatient(e);"
    runat                 = "server">
</Spedmon:DataEntryRowSelectPatient>

<%//-----------------------------------------------------------------------------%>
<%// Select Patient Group %>
<%//-----------------------------------------------------------------------------%>
    
<Spedmon:DataEntryRow ID="selectGroupOfPatients" rowLabel="Select A Patient Group" runat="server">

  <Spedmon:ComboBox 
    ID            = "patgroupid" 
    name          = "patgroupid" 
    title         = "Select Group" 
    dataPrivate   = "true" 
    dataParms     = "[{id:'clientid'},{id:'pracid'}]" 
    dataURL       = "practitioner_patient_groups.asmx/viewSelByClientPrac"  
    onSelect      = "addGroupOfPatients(event, ui);"
    runat         = "server" />

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Participants %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterParticipantDetails" rowLabel="Patients and Additional Participants" runat="server">
    
  <Spedmon:Button ID="butAddNewRow" title="Add" onclick="addParticipant();" runat="server">Add Non Patient Participant</Spedmon:Button>
      
  <Spedmon:DataGrid 
     ID             = "participantdetails" 
     name           = "participantdetails"
     title          = "Enter Participant Details"
     classAssembly  = "AppFramework"
     className      = "MBA.TeleCommParticipant"  
     sortRowsByKey  = "false" 
     showControls   = "false"
     addRemoveButtonForEachBodyRow = "true"
     runat          = "server"/>
 
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Title %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterMeetingTitle" rowLabel="Session Title" runat="server">

  <Spedmon:TextBox ID="title" name="title" maxlen="512" showOK="false" title="Enter a short title that uniquely identifies this session" runat="server" />

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Meeting Date %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="selectOrEnterMeetingDate" rowLabel="Date of Service" runat="server">
  
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

<Spedmon:DataEntryRow ID="selectOrEnterMeetingTime" rowLabel="Time of Service" runat="server">

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

<Spedmon:DataEntryRow ID="selectOrEnterMeetingDuration" rowLabel="Number of Expected Minutes" runat="server">

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

   <Spedmon:Button ID="butmanagefiles" title="Click here To Add New Files" onclick="manageTelehealthFileLibrary()" runat="server">Manage Library</Spedmon:Button>

</Spedmon:DataEntryRowSelectStoredFile>

<%//-----------------------------------------------------------------------------%>
<%// Content %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterMeetingContent" rowLabel="Session Content" runat="server">

 <Spedmon:RichTextAreaBox 
    id           = "content" 
    name         = "content" 
    title        = "Session Content"
    showControls = "false"
    runat        = "server">
  </Spedmon:RichTextAreaBox> 

</Spedmon:DataEntryRow>

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
 var selectIndividualPatientSelector      = '#selectIndividualPatient';
 var selectPatientGroupSelector           = '#selectGroupOfPatients';
 var enterParticipantDetailsSelector      = '#enterParticipantDetails';
 var enterMeetingTitleSelector            = '#enterMeetingTitle';
 var selectOrEnterMeetingDateSelector     = '#selectOrEnterMeetingDate';
 var selectOrEnterMeetingTimeSelector     = '#selectOrEnterMeetingTime';
 var selectOrEnterMeetingDurationSelector = '#selectOrEnterMeetingDuration';
 var enterMeetingContentSelector          = '#enterMeetingContent';
 
 var keyCounter = 1;
     
 /***************************************************************************
  * onServiceSubTypeSelected */
 /**
  * 
  ***************************************************************************/

 function onServiceSubTypeSelected(oldval, newval)
 {
     $(enterParticipantDetailsSelector).removeClass(clsHideUntilNeeded);

     if (newval == <%=MBA.ServiceSubTypeIndividualOrGroup.INDIVIDUAL.GetValueAsString()%>) {
         $(selectIndividualPatientSelector).removeClass(clsHideUntilNeeded);
         $(selectPatientGroupSelector).addClass(clsHideUntilNeeded);
     }
     else if ((newval == <%=MBA.ServiceSubTypeIndividualOrGroup.GROUP.GetValueAsString()%>)){
       $(selectIndividualPatientSelector).addClass(clsHideUntilNeeded);
       $(selectPatientGroupSelector).removeClass(clsHideUntilNeeded);
     }
 }

 /***************************************************************************
  * getDgRef */
 /**
  * Gets ref to practitioner details datagrid
  ***************************************************************************/

  function getDgRef()
  {
    var dgObj = $('#participantdetails').data('spedmondatagrid');
    return dgObj;
  }

 /**************************************************************************
   * generateNewKey() */
  /**
   * 
   *
   **************************************************************************/
 
  function generateNewKey()
  {
     var newKey = keyCounter;
     keyCounter = keyCounter + 1;
     return '' + newKey;
  }

  /**************************************************************************
   * addParticipant() */
  /**
   * 
   *
   **************************************************************************/
 
  function addParticipant(name,title,email,phone,roleid,entityid)
  {  
    var dgParticipants = getDgRef();

    var newArgs = [];
    var newKey = generateNewKey();

    if (!name) name     = '';
    if (!title) title   = '';
    if (!email) email   = '';
    if (!phone) phone   = '';
    if (!roleid) roleid = participantRoleOther; /* Other */
    if (!entityid) entityid = '';

    newArgs.push(name);
    newArgs.push(title);
    newArgs.push(email);
    newArgs.push(phone);
    newArgs.push(''); /* pin (empty)*/
    newArgs.push('');  /*userID*/
    newArgs.push(roleid); 
    newArgs.push(entityid); 
    
    dgParticipants.addRowByKeyWithValues(newKey, newArgs);    
    return;
  }
  
  
  /**************************************************************************
   * removeParticipant() */
  /**
   * 
   *
   **************************************************************************/

  function removeParticipant (existingKey)
  {
    if (existingKey)
    {
      var dgParticipants = getDgRef(); 
      dgParticipants.removeRowByKey(existingKey);    
    }
    return;
  }

  /***************************************************************************
   * addIndivdualPatient */
  /**
   * 
   ***************************************************************************/

  function addIndividualPatient(e)
  {      

    addParticipant(e.dataitem.label, 'Patient', e.dataitem.recData11, e.dataitem.recData12, participantRolePatient, e.dataitem.id);
    // add code to clear selection
  }


  /***************************************************************************
   * addGroupOfPatients */
  /**
   * 
   ***************************************************************************/

  function addGroupOfPatients(event, ui)
  {
      if (!ui.item) return;
      
      let reqURL = '<%=URL_PATIENT_GROUP_MEMBERS_VIEW_SEL%>';
      let cltid     =  $('#clientid').val();
      let prcid     =  $('#pracid').val();
      let patgrpid  = ui.item.id;

      if (!cltid)    return;
      if (!prcid)    return;
      if (!patgrpid) return;

      $('#title').val(ui.item.label);

      var reqData = "{"
                  + "'clientid':"   + "'" + cltid     + "',"
                  + "'pracid':"     + "'" + prcid     + "',"
                  + "'patgroupid':" + "'" + patgrpid  + "',"
                  + "'term':"       + "'" + ""        + "'"
                  + "}";

      let fnGetGroupMembersSuccess = function (rd) {
        var dtg = getDgRef();
        dtg.clear();
        var groupMembers = rd.SelRecs;
          
        if (groupMembers) {
            $.each(groupMembers, function (idx, groupMember) {                
                addParticipant(groupMember.label,'Patient',groupMember.recData11,groupMember.recData12,participantRolePatient,groupMember.id)
            });
          }
          // Add code to use group name as title
         // Add code to clear selection
      };

      $.spedmonWebUI.ajax(null
                          , reqURL
                          , reqData
                          , 'json'
                          , null
                          , null
                          , null
                          , null
                          , 0
                          , fnGetGroupMembersSuccess
                          , null
                          , null);

  }


function manageTelehealthFileLibrary () {

  let cid = $('#clientid').val();
  let pid = $('#pracid').val();      
  if ((cid != '') && (pid != '')) {
      var fileAdditionalDataJSONStr = '{clientid:' + cid + ', pracid:' + pid + '}';
      $.spedmonWebUI.fileList(  '<%=Spedmon.TeleHealthSessions.SEL_LABEL%>'
                              , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>'
                              , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
                              , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
                              , 3 /* Record id position */
                              , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
                              , '<%=Spedmon.TeleHealthSessions.VAL_FILE_CLASS%>'
                              , '' /* File subclass */
                              , '<%=Spedmon.TeleHealthSessions.VAL_FILE_NAMESPACE%>'
                              , '<%=Spedmon.TeleHealthSessions.VAL_FILE_SOURCE%>'
                              , fileAdditionalDataJSONStr
                              , true
                              , true);
  }
}


</script>
