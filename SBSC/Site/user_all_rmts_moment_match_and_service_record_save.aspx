<%@ Page Language="C#" CodeBehind="user_all_rmts_moment_match_and_service_record_save.aspx.cs" Inherits="Spedmon.UserAllRMTSMomentMatchAndServiceRecordSave" %>
 
<%//##################################################################################################################%>
<%//#                                   RMTS Moment Information Rows   %>
<%//##################################################################################################################%>

<%if(showRMTSMomentInfo == true) {%>

<div class="container-fluid rmts-moment-info-container">

<div class="row">
  <div class="col-12">
    <h5 class="rmts-moment-info-title">RMTS moment</h5>
  </div>
</div> <!-- row -->

<div class="row">
    <div class="col">
        <h6 class="rmts-moment-info-question">What Were You Doing?</h6>
    </div> <!-- col -->
    <div class="col">
        <h6 class="rmts-moment-info-question">Who Were You With?</h6>
    </div> <!-- col -->
    <div class="col">
        <h6 class="rmts-moment-info-question">Why Were Your Performing This Activity</h6>
    </div> <!-- col -->
</div> <!-- row -->

<div class="row">
    <div class="col">
        <p class="rmts-moment-info-answer"><%=rmtsMoment.WhatWereYouDoing%></p>
    </div> <!-- col -->
    <div class="col">
        <p class="rmts-moment-info-answer"><%=rmtsMoment.WhoWereYouWith%></p>
    </div> <!-- col-->
    <div class="col">
        <p class="rmts-moment-info-answer"><%=rmtsMoment.WhyWereYouPerformingThisActivity%></p>
    </div> <!-- col -->
</div> <!-- row -->
<div class="row">
    <div class="col-12">
     <div class="rmts-moment-match-status <%=rmtsMomentMatchStatusState%>">
        <%=rmtsMomentMatchStatusText%>
      </div>
    </div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->
<%} /* RMTS moment info*/%>

<%//##################################################################################################################%>
<%//#                                        Service Journal Options   %>
<%//##################################################################################################################%>

<%if(showSvcJournalOptions == true) {%>

<div class="container-fluid rmts-moment-service-journal-container">
<div class="row">
<div class="col-12">
  <h5 class="rmts-moment-info-title">Please record a service journal entry that covers the activity documented in the RMTS moment</h5>
</div> <!-- col -->
</div> <!-- row -->
<div class="row">
<div class="col-12">
<Spedmon:ButtonMenuItemLink ID="gotoJournal" title="Open Service Journal" menuitemid="svcjournalrecordproclink" menuitemlinktype="URL_GOTO_AMD_SUB" runat="server">
Click Here to Record in Service Journal
</Spedmon:ButtonMenuItemLink>
</div> <!-- col -->
</div> <!-- row-->
</div> <!-- container -->
<%} /* Service journal */%>
 

<%//##################################################################################################################%>
<%//#                                        Service Record Data Entry   %>
<%//##################################################################################################################%>

<%if(showSvcRecDataEntry == true) {%>

<Spedmon:DataEntryRows purpose="SAVE" useBootstrapFluid="true" dataURL="servicerecords.asmx/saveandrmtsmomentmatch" runat="server">
  
 <%//-----------------------------------------------------------------------------%>
 <%// Instructions  %>
 <%//-----------------------------------------------------------------------------%>
 
  <div class="row">
    <div class="col-12">
      <h5 class="rmts-moment-action-title">Please enter a service record that covers the activity documented in the RMTS moment</h5>
     </div> <!-- col -->
   </div> <!-- row -->  

 <%//-----------------------------------------------------------------------------%>
 <%// Patient  %>
 <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryRowSelectPatient
     ID                                 = "selectPatient" 
     rowLabel                           = "Patient Name" 
     preSelectedDataSource              = "ALL_PATIENTS"
     showDataSourceSelection            = "false"    
     saveDataSourceSelectedAsPreference = "false"
     runat                              = "server">
  </Spedmon:DataEntryRowSelectPatient>
  
  <%//-----------------------------------------------------------------------------%>
  <%// Date of Service, Start Time, and Num of Minutes %>
  <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryRow ID="selDosTimeMin" rowLabel="Date, Time & Minutes" runat="server">
  
    <Spedmon:DataEntryBoxDate   ID="dos" name="dos" label="Date of Service" runat="server" />
    <Spedmon:DataEntryBoxTime   ID="starttime" name="starttime" label="Start Time" runat="server" />  
    <Spedmon:DataEntryBoxNumber ID="nummin" name="nummin" label="Session Minutes" runat="server" />

  </Spedmon:DataEntryRow>
  
  <%//-----------------------------------------------------------------------------%>
  <%// Telehealth %>
  <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryRow ID="selTelehealth" rowLabel="Via Telehealth?" runat="server">

    <Spedmon:SelectYesOrNo 
        ID           = "viatelehealth" 
        name         = "viatelehealth" 
        renderLabel  = "false" 
        title        = "Via Telehealth?"        
        runat        = "server"/>
    
  </Spedmon:DataEntryRow>

  <%//-----------------------------------------------------------------------------%>
  <%// Plan Type %>
  <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryRow ID="selPlanType" rowLabel="Plan Type" runat="server">

    <Spedmon:DataEntryBoxSelect ID="svcnameslistdatasourceid" name="svcnameslistdatasourceid" label="Plan Type" title="Select what type of plan this service is part of" fireSpedmonInput="true" runat="server" />
    <Spedmon:HiddenInput        ID ="altmodalitynameid"       name ="altmodalitynameid" title="altmodalitynameid" runat ="server" />
  
  </Spedmon:DataEntryRow>

  <%//-----------------------------------------------------------------------------%>
  <%// Service Selection  %>
  <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryRowSelectService 
      ID                 = "selServiceRow" 
      rowLabel           = "Service?"        
      onSpedmonInputData = "fnGetSvcNameFormData();"
      runat              = "server">  
  </Spedmon:DataEntryRowSelectService>

  <%//-----------------------------------------------------------------------------%>
  <%// Attendance Status %>
  <%//-----------------------------------------------------------------------------%>
 
  <Spedmon:DataEntryRow ID="selAttendanceStatus" rowLabel="Attendance" runat="server">
       
      <Spedmon:ComboBox 
         ID          = "attendancestatus" 
         name        = "attendancestatus" 
         title       = "Select Attendance Status" 
         dataPrivate = "true" 
         dataURL     = "servicerecordattendanceselections.asmx/viewSel" 
         dataParms   = "[{}]" 
         runat       = "server" />
  
  </Spedmon:DataEntryRow>
    
  <%//-----------------------------------------------------------------------------%>
  <%// Notes %>
  <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryRow ID="rowNotes" rowLabel="Notes?" runat="server">
    
    <Spedmon:NoteAreaBox ID="notes" name="notes" title="Notes" autoSize="true" showOKButton="false" runat="server" /> 
     
    <Spedmon:HiddenInput    ID="hasPatientGoalTrackingData"       name="hasPatientGoalTrackingData"       title = "hasPatientGoalTrackingData"       runat ="server"/>
    <Spedmon:HiddenTextArea ID="svcNotesFormBuilderQuestionsJSON" name="svcNotesFormBuilderQuestionsJSON" title = "svcNotesFormBuilderQuestionsJSON" runat ="server"/>
    <Spedmon:HiddenTextArea ID="svcNotesFormBuilderAnswersJSON"   name="svcNotesFormBuilderAnswersJSON"   title = "svcNotesFormBuilderAnswersJSON"   runat ="server"/>
    <Spedmon:HiddenTextArea ID="patientGoalProgressJSON"          name="patientGoalProgressJSON"          title = "patientGoalProgressJSON"          runat ="server"/>
    <Spedmon:HiddenInput    ID="hasSessionRatingTracking"         name="hasSessionRatingTracking"         title = "hasSessionRatingTracking"         runat ="server"/>
    <Spedmon:HiddenInput    ID="hasFillablePdfSelections"         name="hasFillablePdfSelections"         title = "hasFillablePdfSelections"         runat="server" />
    <Spedmon:HiddenTextArea ID="fillablePdfSelectionsJSON"        name="fillablePdfSelectionsJSON"        title = "fillablePdfSelectionsJSON"        runat="server" />
    <Spedmon:HiddenTextArea ID="fillablePdfAnswersJSON"           name="fillablePdfAnswersJSON"           title = "fillablePdfAnswersJSON"           runat="server" />
    
  </Spedmon:DataEntryRow>

  <%//-----------------------------------------------------------------------------%>
  <%// Save %>
  <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryRowSaveOrEdit 
    ID                               = "saveOrEdit"     
    runat                            = "server">
  
    <Spedmon:HiddenInput ID="clientid"      name="clientid"     title="clientid"     runat="server" />
    <Spedmon:HiddenInput ID="pracid"        name="pracid"       title="pracid"       runat="server" />
    <Spedmon:HiddenInput ID="groupid"       name="groupid"      title="groupid"      runat="server" />
    <Spedmon:HiddenInput ID="rmtsmomentid"  name="rmtsmomentid" title="rmtsmomentid" runat="server" />

   <Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server" />

  </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>

<script type="text/javascript">

let clientIdRef                      = null;
let pracIdRef                        = null;
let patIdRef                         = null;
let dosRef                           = null;
let grpIdRef                         = null;
let isIepRef                         = null;
let nameIdRef                        = null;
let hasPatGoalDataRef                = null;
let formBuilderQuestionsTaRef        = null;
let formBuilderAnswersTaRef          = null;
let patientGoalProgressTaRef         = null;
let hasSessionRatingTrackingCellRef  = null;
let hasFillablePdfSelectionsCellRef  = null;
let fillablePdfSelectionsJSONCellRef = null;
let fillablePdfAnswersJSONCellRef    = null;

/* Create callback function for note library additional content div */

let fnRenderNoteLibAddContent = function ($div) {
        $($div).html('');

        renderFormInDiv($div
            , '' + $(formBuilderQuestionsTaRef).val()
            , '' + $(formBuilderAnswersTaRef).val()
            , '' + $(clientIdRef).val()
            , '' + $(patIdRef).val()
            , '' + $(grpIdRef).val()
            , function (fbNoteAnswersJSON) { $(formBuilderAnswersTaRef).val(fbNoteAnswersJSON); });
};

let fnGetSvcNameFormData = function () {

    let planTypeSelVal = $('#svcnameslistdatasourceid').val();
    let planTypeID = '100';
    if      (planTypeSelVal == '100') { planTypeID = '2'; }
    else if (planTypeSelVal == '200') { planTypeID = '3'; }
    else if (planTypeSelVal == '300') { planTypeID = '4'; }
    else if (planTypeSelVal == '400') { planTypeID = '5'; }
    else { planTypeSelVal = '100'; }

        let svcNameFormDataRequestObj        = {};
        svcNameFormDataRequestObj.clientid   = $(clientIdRef).val();
        svcNameFormDataRequestObj.groupid    = $(grpIdRef).val();
        svcNameFormDataRequestObj.plantypeid = planTypeID;
        svcNameFormDataRequestObj.nameid     = $(nameIdRef).val();
    
        let svcNameFormDataRequestJSON = JSON.stringify(svcNameFormDataRequestObj);
        let svcNameFormDataRequestUrl = '<%=serviceNameFormDataRequestUrl%>';

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(svcNameFormDataRequestUrl, svcNameFormDataRequestJSON, null)
        .then(responseData => {

            $(formBuilderQuestionsTaRef).val('{}');
            $(formBuilderAnswersTaRef).val('{}');
            $(patientGoalProgressTaRef).val('[]');
            $(hasPatGoalDataRef).val('false');
            $(hasSessionRatingTrackingCellRef).val('false');

            if (responseData.rawData.entity.hasFormData) {
                $(formBuilderQuestionsTaRef).val(responseData.rawData.entity.formDataJson);
            }

            $(hasPatGoalDataRef).val(responseData.rawData.entity.hasPatientGoalTracking);
            $(hasSessionRatingTrackingCellRef).val(responseData.rawData.entity.hasPatientGoalTracking);

            $(hasFillablePdfSelectionsCellRef).val(responseData.rawData.entity.hasFillablePdfSelections);
            $(fillablePdfSelectionsJSONCellRef).val(responseData.rawData.entity.fillablePdfSelectionsJSON);
            $(fillablePdfAnswersJSONCellRef).val('[]');


            /* Create notes library instance */

            $('#notes').notelibrary({
                displayMode: ''
                , sel_tmp_enabled: true
                , useMenu: true
                , showPreview: true
                , notefornamespacefn: function () { return 'service_records'; }
                , noteforsourcefn: function () { return 'add_new_and_match_rmtsmoment'; }
                , noteforclientidfn: function () { return '' + $(clientIdRef).val(); }
                , noteforpracidfn: function () { return '' + $(pracIdRef).val(); }
                , noteforpatidfn: function () { return '' + $(patIdRef).val(); }
                , noteforrefdatefn: function () { return '' + $(dosRef).val(); }
                , noteforgroupidfn: function () { return '' + $(grpIdRef).val(); }
                , tkn: '<%=this.rd.wu.usr.token%>'
                , additionalcontentfn: (fnRenderNoteLibAddContent)
                , noteforhaspatientgoaltrackingfn: function () {
                    return MBA.ComponentCommon.fnFlagValueToTrueFalse($(hasPatGoalDataRef).val());
                }
                , noteforsetpatientgoaltrackingjsonfn: function () {
                    let goalsJSONVal = JSON.parse($(patientGoalProgressTaRef).val());
                    return (goalsJSONVal) ? $(patientGoalProgressTaRef).val() : null;
                }
                , noteforhassessionratingtrackingfn: function () {
                    return MBA.ComponentCommon.fnFlagValueToTrueFalse($(hasSessionRatingTrackingCellRef).val());
                }
                , noteforgetpatientgoaltrackingjsonfn: function (goalTrackingJSON) {
                    $(patientGoalProgressTaRef).val(goalTrackingJSON);
                    return;
                }
                , noteforsvcnamefn: function () {
                    return '' + $('#nameid_selection').val();
                }
                , noteforgrpsvcclassnameidfn: function () {
                    return '' + $('#groupserviceclassnameid').val();
                }


                , url_view_all_patient_goals_progress: '<%=Spedmon.PatientGoalsProgressIndividualGoals.URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_BASE()%>'
             });

        });
};

$(document).ready(function () {

  /* Get various references */

  clientIdRef = $('#<%=Spedmon.Constants.PARM_CLIENT_ID%>');
  pracIdRef   = $('#<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>');
  patIdRef    = $('#<%=Spedmon.Constants.PARM_PATIENT_ID%>');
  dosRef      = $('#<%=Spedmon.Constants.PARM_DOS%>');
  grpIdRef    = $('#<%=Spedmon.Constants.PARM_GROUP_ID%>');
  isIepRef    = $('#<%=Spedmon.Constants.PARM_IS_IEP%>');
  nameIdRef   = $('#<%=Spedmon.Constants.PARM_NAME_ID%>');

  hasPatGoalDataRef                = $('#hasPatientGoalTrackingData');
  formBuilderQuestionsTaRef        = $('#svcNotesFormBuilderQuestionsJSON');
  formBuilderAnswersTaRef          = $('#svcNotesFormBuilderAnswersJSON');
  patientGoalProgressTaRef         = $('#patientGoalProgressJSON');
  hasSessionRatingTrackingCellRef  = $('#hasSessionRatingTracking');
  hasFillablePdfSelectionsCellRef  = $('#hasFillablePdfSelections');
  fillablePdfSelectionsJSONCellRef = $('#fillablePdfSelectionsJSON');
  fillablePdfAnswersJSONCellRef    = $('#fillablePdfAnswersJSON');

  /* Init */

  $(formBuilderQuestionsTaRef).val('{}');
  $(formBuilderAnswersTaRef).val('{}');
  $(hasPatGoalDataRef).val('false');
  $(patientGoalProgressTaRef).val('{}');
  $(hasSessionRatingTrackingCellRef).val('false');


  /* Listen for service record changes so we can get form data for service selected */

});
  
</script>

<%} /* Service record */%>

