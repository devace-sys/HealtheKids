<%@ Page Language="C#" CodeBehind="user_all_practice_office_patient_visit_manage.aspx.cs" Inherits="Spedmon.UserAllPracticeOfficePatientVisitManage"%>

<%if (this.pageInitOK == true) { %>

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                           Hidden Fields                                                         %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server"/>
<Spedmon:HiddenInput ID="clientid" name="clientid" title="clientid" runat="server" />
<Spedmon:HiddenInput ID="patid"    name="patid"    title="patid"    runat="server" />
<Spedmon:HiddenInput ID="pracid"   name="pracid"   title="pracid"   runat="server" />
<Spedmon:HiddenInput ID="groupid"  name="groupid"  title="groupid"  runat="server" />
<Spedmon:HiddenInput ID="siteid"   name="siteid"   title="siteid"   runat="server" />
<Spedmon:HiddenInput ID="dos"      name="dos"      title="dos"      runat="server" />
<Spedmon:HiddenInput ID="recid"    name="recid"    title="recid"    runat="server" />
<Spedmon:HiddenInput ID="active"   name="active"   title="active"   value="1" runat="server" />
<Spedmon:HiddenInput ID="practitionerpatientcaseloadexpectedserviceid" name="practitionerpatientcaseloadexpectedserviceid"  title="Select Plan from IEP" runat="server" />


<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                           Data Entry                                                            %>
<%//#                                                                                                                 %>
<%//# Note: The following is a bootstrap grid with nested bootstrap grids for each tab                                %>
<%//##################################################################################################################%>
  
<div id="visitcontentcontainer" class="container-fluid">

<div class="row">
<div class="col-12">
<div class="d-flex justify-content-end">
  <Spedmon:DataEntryButton ID="butpracticeofficevisitclose" label="Close" faIcon="fa fa-door-open fa-2x" iconOnly="true" assignBsCssClasses="false" onclick="exitVisit()" runat="server" />
</div> <!-- control container -->
</div> <!-- col -->
</div> <!-- row -->  

<div class="row">
<div id="r1-cl" class="col-3">

<%//#############################################################################%>
<%//                             Profile                                         %>
<%//#############################################################################%>

<section id="profile"></section> <!-- profile -->

</div> <!-- col -->

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                              Tabbed Content                                                     %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<div id="r1-cr" class="col-9">

<div id="tabs">

<%//##################################################################################################################%>
<%//#                                             Tabs Anchors                                                        %>
<%//##################################################################################################################%>

<ul>
  <li><a href = "#tab-medical-history">Medical History</a></li>
  <li><a href = "#tab-contacts">Contacts</a></li>
  <li><a href = "#tab-orders-and-prescriptions">Orders & Prescriptions</a></li>
  <li><a href = "#tab-care-plans">Care Plans</a></li>
  <li><a href = "#tab-iep-related-services">IEP Related Services</a></li>
  <li><a href = "#tab-goals">Goals</a></li>
  <li><a href = "#tab-insurance">Insurance</a></li>
  <li><a href = "#tab-services-and-documentation">Services & Documentation</a></li>
  <li><a href = "#tab-files">Files</a></li>
</ul> <!-- tabs -->

<%//##################################################################################################################%>
<%//#                                             Tabs Content                                                        %>
<%//##################################################################################################################%>
  
<%//-----------------------------------------------------------------------------%>
<%// Medical History  %>
<%//-----------------------------------------------------------------------------%>

<div id="tab-medical-history">      
<div class="container-fluid">

<div class="row">

<%//---------------------------------%>
<%// Med Hist Icon                   %>
<%//---------------------------------%>

<div class="col-1">
  <i class="fas fa-notes-medical fa-4x med-history visit-section-icon"></i>
</div>

<%//---------------------------------%>
<%// Known Health Problems           %>
<%//---------------------------------%>

<div id="datamanagerowsrestviewpatientknownhealthproblems" class="col-3">
<div id="restviewpatientknownhealthproblems" class="rest-view-display-minimal"></div> <!-- rest view -->
</div> <!-- col -->

<%//---------------------------------%>
<%// Allergies                       %>
<%//---------------------------------%>

<div id="datamanagerowsrestviewpatientallergies" class="col-3">
<div id="restviewpatientallergies" class="rest-view-display-minimal"></div> <!-- rest view -->
</div> <!-- col -->

<%//---------------------------------%>
<%// Diagnoses                       %>
<%//---------------------------------%>

<div id="datamanagerowsrestviewpatientdiagnoses" class="col-5">
<div id="restviewpatientdiagnoses" class="rest-view-display-minimal"></div> <!-- rest view -->
</div> <!-- col -->

</div> <!-- row -->


<%//---------------------------------%>
<%// Patient Care Notes              %>
<%//---------------------------------%>

<div class="row tab-subsection-divider">

<%//---------------------------------%>
<%// Care Notes Icon                 %>
<%//---------------------------------%>

<div class="col-1">
  <i class="fas fa-comment-dots fa-4x notes"></i>
</div> <!-- col -->

<%//---------------------------------%>
<%// Care Notes Component            %>
<%//---------------------------------%>

<div id="datamanagerowsrestviewpatientcarenotes" class="col-11">
    <div id="patientcarenotescomponentvisits"></div>
</div> <!-- col -->
</div> <!-- row -->

<%//---------------------------------%>
<%// Practice Office Visits          %>
<%//---------------------------------%>

<div id="practiceofficevisitsection" class="row tab-subsection-divider" style="display:none">

<%//---------------------------------%>
<%// Visits Icon                     %>
<%//---------------------------------%>

<div class="col-1">

<i class="fas fa-user-md fa-4x visits visit-section-icon"></i>

</div> <!-- col -->

<%//---------------------------------%>
<%// Visits Rest View                %>
<%//---------------------------------%>

<div class="col-11">

<div id="datamanagerowsrestviewpracticeofficevisits" class="container-fluid">

<div id="thisvisitdetails" class="row">

<div class="col-1">
  <Spedmon:DataEntryButton ID="butcompletepracticeofficevisit" iconOnly="true" title="Click here to save" faIcon="fa fa-save fa-2x mba-rest-view-animation-heartbeat-infinite" assignBsCssClasses="false" onclick="doCompletePracticeOfficeVisit(false)" runat="server" />
</div> <!-- col-->

<div class="col-11 d-flex ">
<div class="visit-detail">
<div class="visit-detail-label">Check In Date and Time</div>
<div class="visit-detail-content">
<input type="text" class="input-date" id="checkindate" name="checkindate" value="<%=pov.visitStartDateStr%>" />
<span class="edit-label">Edit</span>
<br />
<input type="time" class="input-time" id="checkintime" name="checkintime" value="<%=pov.checkInTimeHHMMStr%>" />
<span class="edit-label2">Edit</span>
<br />
</div>
</div>

<div class="visit-detail">
<div class="visit-detail-label">Visit Start Date and Time</div>
<div class="visit-detail-content">
<input type="text" class="input-date" id="visitstartdate" name="visitstartate"  value="<%=pov.visitStartDateStr%>" />
<span class="edit-label">Edit</span>
<br />
<input type="time" id="visitstarttime" class="input-time" name="visitstarttime" value="<%=pov.visitStartTimeHHMMStr%>" />
<span class="edit-label2">Edit</span>
</div>
</div>

<div class="visit-detail">
<div class="visit-detail-label">Visit End Date and Time</div>
<div class="visit-detail-content">
<input type="text" class="input-date" id="visitenddate" name="visitenddate" placeholder="mm/dd/yyyy" value="<%=pov.visitEndDateStr%>" />
<span class="edit-label">Edit</span>
<br />
<input type="time" id="visitendtime" class="input-time" name="visitendtime"  value="<%=pov.visitEndTimeHHMMStr%>" />
<span class="edit-label2">Edit</span>
<br />
</div>
</div>
<div class="visit-detail">
<div class="visit-detail-label">Reason For Visit</div>
<div class="visit-detail-content">
<span title="<%=pov.practiceOfficeVisitReasonNotes%>"><%=pov.practiceOfficeVisitReasonName%></span>
<br />
<%if (pov.hasVisitReasonNotes == true){%>
<sup>Hover to see additional notes</sup>
<%} else {%>
<br />
<%}%>
</div>
</div>

<div class="visit-detail">
<div class="visit-detail-label">Practitioner Assigned</div>
<div class="visit-detail-content">
<span><%=pov.pracName%></span>
<br />
<sup><%=pov.pracTitle%></sup>
</div>
</div>

<div class="visit-detail">
<div class="visit-detail-label"></div>
<div class="visit-detail-content">
<Spedmon:DataEntryBoxSelect ID="practiceofficevisitresolutionid" label="Resolution" required="true" runat="server"/>
</div>
</div>

</div> <!-- col -->
<div class="col-6">
    <p class="p-2"><em style="font-size:.75em;font-weight:bold;"><%=MBA.Messages.ATTEST_STATEMENT%></em></p>
</div>
<div class="col-6">
<%/* Note: resolutionnotes is enhanced into dataentry box on load since we have to attach the note library*/%>
<textarea ID="practiceofficevisitresolutionnotes" title="Visit notes" placeholder="Enter notes" style="width:20em;">
    <%=pov.practiceOfficeVisitResolutionNotes%>
</textarea>
<textarea id="practiceofficevisitresolutionfbquestionsjson" style="display:none;">
    <%=povr.formDataJSON%>
</textarea>
<textarea id="practiceofficevisitresolutionfbanswersjson" style="display:none;">
    <%=pov.practiceOfficeVisitResolutionFBAnswersJSON%>
</textarea>
</div>

</div> <!-- row -->

<div class="row">
<div class="col-12">
<details id="practiceofficevisitshistorydetails">
<summary id="practiceofficevisitshistorysummary"><i class="fas fa-history fa-lg mr-1"></i>Previous Visits</summary>
<div id="restviewpracticeofficevisits"></div> <!-- practice office visits -->
</details>
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->
</div> <!-- col -->
</div> <!-- row -->

<%//---------------------------------%>
<%// Medication Adminstration        %>
<%//---------------------------------%>

<div class="row tab-subsection-divider">

<%//---------------------------------%>
<%// Med Admin Icon                  %>
<%//---------------------------------%>

<div class="col-1">
<i class="fas fa-prescription fa-4x orpdocs visit-section-icon"></i>
</div> <!-- col -->

<%//---------------------------------%>
<%// Med Admin Forms                 %>
<%//---------------------------------%>

<div id="ordersorprescriptionshsprovidedfordoscontainer" class="col-11">
    <div id="ordersorprescriptionshsprovidedfordos"></div>
</div> <!-- col -->   
</div> <!-- row -->

<%//---------------------------------%>
<%// Vital Signs                     %>
<%//---------------------------------%>

<div class="row tab-subsection-divider">

<%//---------------------------------%>
<%// Vitals Icon                     %>
<%//---------------------------------%>

<div class="col-1">
<i class="fas fa-heartbeat fa-4x vitals visit-section-icon"></i>
</div> <!-- col -->

<%//---------------------------------%>
<%// Vitals Component                %>
<%//---------------------------------%>

<div id="vitalsmeasurementsfordoscontainer" class="col-11">
    
<div id="vitalsmeasurementsfordos"></div>

</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->
</div> <!-- medical history tab -->
  
<%//-----------------------------------------------------------------------------%>
<%// Contacts  %>
<%//-----------------------------------------------------------------------------%>

<div id="tab-contacts">      
<div class="container-fluid">
<div id="datamanagerowsrestviewpatientpersons" class="row">
<div class="col-12">
<div id="restviewpatientpersons"></div>
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->
</div> <!-- contacts -->

<%//=============================================================================%>
<%//                      Orders and Prescriptions %>
<%//=============================================================================%>

<div id="tab-orders-and-prescriptions">
<div class="container-fluid">
<div id="datamanagerowsrestviewordersorprescriptions" class="row">
<div class="col-12">
<div id="restviewordersorprescriptions"></div> <!-- restview -->
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->
</div> <!-- orders and prescriptions -->

<%//-----------------------------------------------------------------------------%>
<%// Care Plans  %>
<%//-----------------------------------------------------------------------------%>

<div id="tab-care-plans">
<div id="datamanagerowsrestviewcareplans" class="container-fluid">
<div class="row">

<%//---------------------------------%>
<%// Filters for Care Plans          %>
<%//---------------------------------%>

<div class="col-12">
  <input type="hidden" id="fiscalyearid" name="fiscalyearid" title="fiscalyearid" value="" />
            
  <div class="ml-1" style="display:inline-block">

    <span class="mr-2" style="font-weight:bold;">Show Plans That : </span>                
                
    <div class="form-check form-check-inline mr-4">
      <input class="form-check-input" type="checkbox" id="iscreatedbycaller" onchange="fireSpedmonInputDataEvent();">
      <label class="form-check-label" for="iscreatedbycaller">I Created</label>
    </div>

    <div class="form-check form-check-inline mr-4">
      <input class="form-check-input" type="checkbox" id="isexpiring" onchange="fireSpedmonInputDataEvent();">
      <label class="form-check-label" for="isexpiring">Are Expiring Soon</label>
    </div>

    <div class="form-check form-check-inline">
      <input class="form-check-input" type="checkbox" id="isexpired" onchange="fireSpedmonInputDataEvent();">
      <label class="form-check-label" for="isexpired">Have Expired</label>
     </div>

  </div> <!-- filters -->
</div> <!-- col -->
</div> <!-- row -->

<%//---------------------------------%>
<%// Rest View for Care Plans        %>
<%//---------------------------------%>

<div class="row mt-2">
<div class="col-12">
<div id="restviewcareplans" class="mba-care-plan" ></div> <!-- rest view -->
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->    
</div> <!-- care plans -->

<%//-----------------------------------------------------------------------------%>
<%// IEP Related Services  %>
<%//-----------------------------------------------------------------------------%>

<div id="tab-iep-related-services">      
<div class="container-fluid">
<div class="row">
<div class="col-12">
<table class="table table-sm">
<thead>           
<tr>
  <th>Case Manager</th>
  <th>Disability 1</th>
  <th>Disability 2</th>
  <th>Last Eval Date</th>
  <th>Last IEP Date</th>
  <th>Next IEP Date</th>
  <th>Exited SpEd Date</th>
</tr>
</thead>
<tbody>
<tr>
  <td><%=pat.spEdCaseManagerName%></td>
  <td><%=pat.spEdDisability1CodeAndName%></td>
  <td><%=pat.spEdDisability2CodeAndName%></td>
  <td><%=pat.spEdLastEvalDateYMD%></td>
  <td><%=pat.spEdLastAnnualIEPDateYMD%></td>
  <td><%=pat.spEdNextAnnualIEPDateYMD%></td>
  <td><%=pat.spEdExitedSpEdDateYMD%></td>
</tr>
</tbody>
</table>
</div> <!-- col-->  
</div> <!-- row -->
<div id="datamanagerowsrestviewpatientpromisedservices" class="row mt-2">
<div class="col-12">
<div id="restviewpatientpromisedservices"></div><!-- rest view -->
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->
</div> <!-- iep related services -->

<%//-----------------------------------------------------------------------------%>
<%// Goals  %>
<%//-----------------------------------------------------------------------------%>

<div id="tab-goals">     
<div class="container-fluid">
<div id="datamanagerowsrestviewpatientgoals" class="row">
<div class="col-12">
<div id="restviewpatientgoals"></div><!-- rest view here -->
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->   
</div> <!-- goals -->

<%//-----------------------------------------------------------------------------%>
<%// Insurance  %>
<%//-----------------------------------------------------------------------------%>

<div id="tab-insurance">
<div class="container-fluid">
<div id="datamanagerowsrestviewpatientinsurance" class="row">
<div class="col-12">
<div id="restviewpatientinsurance"></div> <!-- rest view -->
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->
</div> <!-- insurance -->

<%//-----------------------------------------------------------------------------%>
<%// Services and Documentation %>
<%//-----------------------------------------------------------------------------%>

<div id ="tab-services-and-documentation">
<div id="datamanagerowsrestviewservicerecords" class="container-fluid">
<div class="row">
<div class="col-12">
<div id="restviewservicerecords"></div> <!-- rest view -->
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->
</div> <!-- services and documentation -->

<%//=============================================================================%>
<%//                                    Files %>
<%//=============================================================================%>

<div id ="tab-files">
<div id="datamanagerowsrestviewstoredfiles" class="container-fluid">
<div class="row">
<div class="col-12">
<div id="restviewstoredfiles"></div><!-- rest view -->
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->
</div> <!-- files -->

<%//---------------------------- Tabs Content - End -------------------------------------- %>

</div> <!-- tabs -->
</div> <!-- col -->
</div> <!-- row -->  
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">

let $r1_cl = null;
let $r1_cr = null;

let practiceOfficeVisitComplete = false;
let hideVisitSection            = false;
let $ctrlPovResolutionID;
let $ctrlPovResolutionNotes;
let $ctrlPovResolutionFBQ;
let $ctrlPovResolutionFBA;
let $restViewStoredFiles = null;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function onBeforeUnloadHandler(event) {
  if (hideVisitSection == true) {
    doCompletePracticeOfficeVisit(false);
    return;
  }
  doPracticeOfficeSaveInProgress();
  return;
};

<%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

function initProfile() {

  let opts = {};

  opts.PARM_NAME_CLIENT_ID       = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
  opts.PARM_NAME_REC_ID          = '<%=Spedmon.Constants.PARM_REC_ID%>';
  opts.PARM_NAME_SAVE_TYPE       = '<%=Spedmon.Constants.PARM_SAVE_TYPE%>';
  opts.PARM_NAME_VALIDATE_REC    = '<%=Spedmon.Constants.PARM_VALIDATE_REC%>';
  opts.PARM_NAME_EDIT_DEL_REASON = '<%=Spedmon.Constants.PARM_EDIT_DEL_REASON%>';
  opts.PARM_NAME_SEARCH_TERM     = '<%=Spedmon.Constants.PARM_SEARCH_TERM%>';
  opts.sessionTimeOutUrl         = '<%=MBA.Credential.generateSessionExpiredLink()%>';
  opts.baseUrlSaveProfile        = '<%=Spedmon.Patients.URL_SVC_SAVE_PROFILE_BASE()%>';
  opts.baseUrlGetProfile         = '<%=Spedmon.Patients.URL_SVC_GET_BASE()%>';
  opts.baseUrlSiteIDSel = '<%=Spedmon.Sites.URL_SVC_VIEW_SEL()%>';
  opts.baseUrlPreferredContactMethodIDSel = '<%= Spedmon.ContactMethods.URL_VIEW_SEL_BASE()%>';
  opts.isPcalStaff               = <%=isPcalStaffJSBoolStr%>;
  opts.VALUE_SAVE_TYPE           = '2';
  opts.VALUE_PAT_ID              = '<%=pat.id.ToString()%>';
  opts.baseUrlSaveProfilePicture = '<%=Spedmon.PatientProfilePictures.URL_SVC_SAVE_OR_REPLACE_BASE()%>';
  opts.baseUrlGetProfilePicture  = '<%=Spedmon.PatientProfilePictures.URL_SVC_GET_BASE()%>';
  opts.baseUrlDeleteProfilePicture = '';
  opts.enableProfilePictureUpload  = true;
  
  opts.baseUrlFindStudentsWithSSID = '<%=Spedmon.CrossClientPatients.URL_VIEW_SEL_FOR_NEW_RECS_BASE()%>';
  opts.fnAfterSaveEdit = function (patID) {
  /* TODO: Uncomment line below for developing */
  /* MBA.StudentStatusBarCommon.fnGetMissingInfoAndUpdateStatusStates('patientTopBannerContainer');*/
  };

  opts.fnBeforeShrink = function () {
    $($r1_cl).removeClass('col-3');
    $($r1_cr).removeClass('col-9');
  };

  opts.fnAfterShrink = function () {
    $($r1_cl).addClass('col-3');
    $($r1_cr).addClass('col-12');
  };

  opts.fnBeforeRestore = function () {
    $($r1_cl).removeClass('col-3');
    $($r1_cr).removeClass('col-12');
  };

  opts.fnAfterRestore = function () {
    $($r1_cl).addClass('col-3');
    $($r1_cr).addClass('col-9');
  };

    opts.relatedRestViewStoredFilesRef  = $restViewStoredFiles;
    opts.baseUrlInvitePatientPortal     = '<%=Spedmon.Patients.URL_INVITE_PATIENT_TO_PORTAL_BASE()%>';
    opts.baseUrlSaveMessage             = '<%=urlUserMessagesSave%>';
    opts.baseUrlurlRecipientSrc         = '<%=urlRecipientSrc%>';

  MBA.PatientProfileCommon.fnSetup('profile', opts);
};

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initKnownHealthProblemsRestView() {

      let optsObj = {
         PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
       , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
       , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
       , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
       , containerCtrlID: 'datamanagerowsrestviewpatientknownhealthproblems'
       , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
       , baseUrlView:'<%=Spedmon.PatientKnownHealthProblems.URL_REST_VIEW_BASE()%>'
       , defaultPageRowOrder:'<%=Spedmon.PatientKnownHealthProblem.DEFAULT_PAGING_ORDER%>'
       , baseUrlAddNew:'<%=Spedmon.PatientKnownHealthProblems.URL_SAVE_NEW_BASE()%>'
       , baseUrlEdit:'<%=Spedmon.PatientKnownHealthProblems.URL_EDIT_BASE()%>'
       , baseUrlDelete:'<%=Spedmon.PatientKnownHealthProblems.URL_DELETE_INLINE_BASE()%>'
       , baseUrlKnownHealthProblemIDSel: '<%=Spedmon.KnownHealthProblems.URL_VIEW_SEL_BASE()%>'
       , showAddNew: true
       , showEdit: true
       , showDelete: true
       , enableScrollView: true
       , scrollViewUseCustomHeight: true
       , scrollViewCustomHeight: '10em'
       , autoHidePageControls: true

       };

    MBA.PatientKnownHealthProblemsCommon.fnSetup('restviewpatientknownhealthproblems', optsObj);
    return;
};

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initAllergiesRestView() {

        let optsObj = {
              PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , containerCtrlID: 'datamanagerowsrestviewpatientallergies'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView:'<%=Spedmon.PatientAllergies.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder:'<%=Spedmon.PatientAllergy.DEFAULT_PAGING_ORDER%>'
            , baseUrlAddNew:'<%=Spedmon.PatientAllergies.URL_SAVE_NEW_BASE()%>'
            , baseUrlEdit:'<%=Spedmon.PatientAllergies.URL_EDIT_BASE()%>'
            , baseUrlDelete:'<%=Spedmon.PatientAllergies.URL_DELETE_INLINE_BASE()%>'
            , baseUrlAllergyIDSel: '<%=Spedmon.Allergies.URL_VIEW_SEL_BASE()%>'            
            , showAddNew: true
            , showEdit: true
            , showDelete: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '10em'
            , autoHidePageControls: true

        };

    MBA.PatientAllergiesCommon.fnSetup('restviewpatientallergies', optsObj);
    return;
    };

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initDiagnosesRestView() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
          , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
          , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
          , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
          , containerCtrlID: 'datamanagerowsrestviewpatientdiagnoses'
          , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
          , baseUrlView:'<%=Spedmon.PatientDiagnoses.URL_REST_VIEW_BASE()%>'
          , defaultPageRowOrder:'<%=Spedmon.PatientDiagnosis.DEFAULT_PAGING_ORDER%>'
          , baseUrlAddNew:'<%=Spedmon.PatientDiagnoses.URL_SAVE_INLINE_BASE()%>'
          , baseUrlEdit:'<%=Spedmon.PatientDiagnoses.URL_SAVE_INLINE_BASE()%>'
          , baseUrlDelete:'<%=Spedmon.PatientDiagnoses.URL_DELETE_INLINE_BASE()%>'
          , baseUrlDiagnosisIDSel:'<%=Spedmon.ICD10CMCodes.URL_VIEW_SEL_BASE()%>' 
          , showAddNew: true
          , showEdit: false
          , showDelete: true
          , enableScrollView: true
          , scrollViewUseCustomHeight: true
          , scrollViewCustomHeight: '10em'
          , autoHidePageControls: true

        };

    MBA.PatientDiagnosesCommon.fnSetup('restviewpatientdiagnoses', optsObj);
    return;
    };

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initPatientCareNotes() {

    let optsForPatientCareNotes = {};

    optsForPatientCareNotes.PARM_NAME_CLIENT_ID                 = $('#<%=Spedmon.Constants.PARM_CLIENT_ID%>').val();
    optsForPatientCareNotes.PARM_NAME_GROUP_SVC_CLASS_NAME_ID   = $('#<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>').val();
    optsForPatientCareNotes.PARM_NAME_PAT_ID                    = $('#<%=Spedmon.Constants.PARM_PATIENT_ID%>').val();
    optsForPatientCareNotes.containerCtrlID                     = 'datamanagerowsrestviewpatientcarenotes';
    optsForPatientCareNotes.sessionTimeOutUrl                   = '<%=MBA.Credential.generateSessionExpiredLink()%>';
    optsForPatientCareNotes.baseUrlView                         = '<%=Spedmon.PatientCareNotes.URL_REST_VIEW_BASE()%>';
    optsForPatientCareNotes.defaultPageRowOrder                 = '<%=Spedmon.PatientCareNote.DEFAULT_PAGING_ORDER%>';
    optsForPatientCareNotes.baseUrlSave                         = '<%=Spedmon.PatientCareNotes.URL_SAVE_NOTE_BASE()%>';
    optsForPatientCareNotes.baseUrlLoad                         = '<%=Spedmon.PatientCareNotes.URL_LOAD_NOTE_BASE()%>';

    MBA.PatientCareNotesCommon.fnSetup('patientcarenotescomponentvisits', optsForPatientCareNotes);

    };

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function doCompletePracticeOfficeVisit(closeWindow) {

    let valueClientID          = $('#<%=Spedmon.Constants.PARM_CLIENT_ID%>').val();
    let valuePracID            = $('#<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>').val();
    let valueResolutionID      = $($ctrlPovResolutionID).MBA_DataEntryBox('getValue');
    let valueResolutionNotes   = $($ctrlPovResolutionNotes).MBA_DataEntryBox('getValue');
    let valueResolutionFBQJ    = $($ctrlPovResolutionFBQ).val();
    let valueResolutionFBAJ    = $($ctrlPovResolutionFBA).val();
    let valueRecID             = $('#<%=Spedmon.Constants.PARM_REC_ID%>').val();
    let checkInDate            = $('#<%=Spedmon.Constants.PARM_CHECK_IN_DATE%>').val();
    let checkInTime            = $('#<%=Spedmon.Constants.PARM_CHECK_IN_TIME%>').val();
    let visitStartDate         = $('#<%=Spedmon.Constants.PARM_VISIT_START_DATE%>').val();
    let visitStartTime         = $('#<%=Spedmon.Constants.PARM_VISIT_START_TIME%>').val();
    let visitEndDate           = $('#<%=Spedmon.Constants.PARM_VISIT_END_DATE%>').val();
    let visitEndTime           = $('#<%=Spedmon.Constants.PARM_VISIT_END_TIME%>').val();

    if (!valueResolutionID) {
        MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Please Complete The Form', 'Please select a resolution', {});
        return;
    }

    let requestObj = {};

    requestObj['<%=Spedmon.Constants.PARM_CLIENT_ID%>']                              = valueClientID;
    requestObj['<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>']                        = valuePracID;
    requestObj['<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_ID%>']    = valueResolutionID;
    requestObj['<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_NOTES%>'] = valueResolutionNotes;
    requestObj['<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_FBQJ%>']  = valueResolutionFBQJ;
    requestObj['<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_FBAJ%>']  = valueResolutionFBAJ;
    requestObj['<%=Spedmon.Constants.PARM_REC_ID%>']                                 = valueRecID;
    requestObj['<%=Spedmon.Constants.PARM_CHECK_IN_DATE%>']                          = checkInDate;
    requestObj['<%=Spedmon.Constants.PARM_CHECK_IN_TIME%>']                          = checkInTime;
    requestObj['<%=Spedmon.Constants.PARM_VISIT_START_DATE%>']                       = visitStartDate;
    requestObj['<%=Spedmon.Constants.PARM_VISIT_START_TIME%>']                       = visitStartTime;
    requestObj['<%=Spedmon.Constants.PARM_VISIT_END_DATE%>']                         = visitEndDate;
    requestObj['<%=Spedmon.Constants.PARM_VISIT_END_TIME%>']                         = visitEndTime;

    let requestJSON = JSON.stringify(requestObj);
    
    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.PracticeOfficeVisits.URL_SVC_END_VISIT_BASE()%>', requestJSON, null)
        .then(responseData => {
          $('#thisvisitdetails').children().remove();
          $('#thisvisitdetails').append('<div class="alert alert-success">Visit resolution, notes, and end date/time have been saved.  See previous visits below for details.</div>');
          MBA.PracticeOfficeVisitsCommon.fnRefreshView('restviewpracticeofficevisits');
          practiceOfficeVisitComplete = true;            
          window.removeEventListener('beforeunload', onBeforeUnloadHandler);
            if (closeWindow == true) {
                if (<%=Util.netBoolToJSBool(visitScreenIsWindow)%> == true) {
                    window.close();
                } else {
                    $.spedmonWebUI.gotoURL('<%=goBackURL%>');
                }
            }
      })
       .catch(err => {
           MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
       });

    return;
};

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function doPracticeOfficeSaveInProgress() {

    if (hideVisitSection            == true) return;  /* Prevent save if visit data cannot be entered */
    if (practiceOfficeVisitComplete == true) return;  /* Prevent save if visit is complete */

    let valueClientID        = $('#<%=Spedmon.Constants.PARM_CLIENT_ID%>').val();
    let valuePracID          = $('#<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>').val();
    let valueResolutionID    = $($ctrlPovResolutionID).MBA_DataEntryBox('getValue');
    let valueResolutionNotes = $($ctrlPovResolutionNotes).MBA_DataEntryBox('getValue');
    let valueResolutionFBQJ  = $($ctrlPovResolutionFBQ).val();
    let valueResolutionFBAJ  = $($ctrlPovResolutionFBA).val();
    let valueRecID           = $('#<%=Spedmon.Constants.PARM_REC_ID%>').val();
    let checkInDate          = $('#<%=Spedmon.Constants.PARM_CHECK_IN_DATE%>').val();
    let checkInTime          = $('#<%=Spedmon.Constants.PARM_CHECK_IN_TIME%>').val();
    let visitStartDate       = $('#<%=Spedmon.Constants.PARM_VISIT_START_DATE%>').val();
    let visitStartTime       = $('#<%=Spedmon.Constants.PARM_VISIT_START_TIME%>').val();
    let visitEndDate         = $('#<%=Spedmon.Constants.PARM_VISIT_END_DATE%>').val();
    let visitEndTime          = $('#<%=Spedmon.Constants.PARM_VISIT_END_TIME%>').val();
    
    let requestObj = {};

    requestObj['<%=Spedmon.Constants.PARM_CLIENT_ID%>']                              = valueClientID;
    requestObj['<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>']                        = valuePracID;
    requestObj['<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_ID%>']    = valueResolutionID;
    requestObj['<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_NOTES%>'] = valueResolutionNotes;
    requestObj['<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_FBQJ%>']  = valueResolutionFBQJ;
    requestObj['<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_FBAJ%>']  = valueResolutionFBAJ;
    requestObj['<%=Spedmon.Constants.PARM_REC_ID%>']                                 = valueRecID;
    requestObj['<%=Spedmon.Constants.PARM_CHECK_IN_DATE%>']                          = checkInDate;
    requestObj['<%=Spedmon.Constants.PARM_CHECK_IN_TIME%>']                          = checkInTime;
    requestObj['<%=Spedmon.Constants.PARM_VISIT_START_DATE%>']                       = visitStartDate;
    requestObj['<%=Spedmon.Constants.PARM_VISIT_START_TIME%>']                       = visitStartTime;
    requestObj['<%=Spedmon.Constants.PARM_VISIT_END_DATE%>']                         = visitEndDate;
    requestObj['<%=Spedmon.Constants.PARM_VISIT_END_TIME%>']                         = visitEndTime;

    let requestJSON = JSON.stringify(requestObj);
    
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.PracticeOfficeVisits.URL_SVC_VISIT_IN_PROGRESS_SAVE_BASE()%>', requestJSON, null)
            .then(responseData => {                                
            })
            .catch(err => {                
            });
        return;
    };

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initPracticeOfficeRestView() {

        
        let $currentRecCtrlEditStart = null;
        
        let optsObj = {
              PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_GROUP_SVC_CLASS_NAME_ID: '<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>'
            , PARM_NAME_SITE_ID: '<%=Spedmon.Constants.PARM_SITE_ID%>'
            , PARM_NAME_PRAC_ID: '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_COMPLETED: '<%=Spedmon.Constants.PARM_COMPLETED%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , PARM_DATA_SOURCE: '<%=Spedmon.Constants.PARM_DATA_SOURCE%>'
            , dataSourceValueForVisits: '1' /* Default all.  1= all , 2 = waiting room only */
            , PAT_DATA_SOURCE_VALUE_ALL_PATIENTS: '<%=PAT_DATA_SOURCE_VALUE_ALL_PATIENTS%>'
            , PRAC_DATA_SOURCE_VALUE_WITHIN_PRACTICE_FAMILY_ONLY: '<%=PRAC_DATA_SOURCE_VALUE_WITHIN_PRACTICE_FAMILY_ONLY%>'
            , containerCtrlID: 'datamanagerowsrestviewpracticeofficevisits'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.PracticeOfficeVisits.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder: '<%=Spedmon.PracticeOfficeVisit.DEFAULT_PAGING_ORDER%>'
            , whatPage: 3
            , baseUrlAddNew: ''
            , baseUrlEdit: '<%=Spedmon.PracticeOfficeVisits.URL_SVC_END_VISIT_BASE()%>'
            , baseUrlDelete: ''
            , baseUrlPatIDSel: '<%=Spedmon.Patients.URL_SVC_VIEW_SEL_BASE()%>'
            , baseUrlPracticeOfficeVisitReasonIDSel: '<%=Spedmon.PracticeOfficeVisitReasons.URL_VIEW_SEL_BASE()%>'
            , baseUrlPracIDSel: '<%=Spedmon.Practitioners.URL_VIEW_SEL2_BASE()%>'
            , baseUrlPatientVisitManage: '<%=Spedmon.PracticeOfficeCommon.URL_PATIENT_VISIT_MANAGE()%>'
            , baseUrlPracticeOfficeVisitResolutionIDSel:'<%=Spedmon.PracticeOfficeVisitResolutions.URL_VIEW_SEL_BASE()%>'
            , baseUrlReport:'<%=Spedmon.PracticeOfficeVisits.URL_WEB_REPORT_BASE()%>'
            , defaultReportNumber: '<%=Spedmon.PracticeOfficeVisitsView.REPT_NUM_VIEW%>'
            , showAddNew: false
            , showStartVisit: false
            , showEdit: true
            , completedValue: 'Y'
            , showCaption: false
            , caption: 'Visits'
            , enableScrollView:true
            , scrollViewUseCustomHeight:true
            , scrollViewCustomHeight:'15em'
            , autoHidePageControls: true
            , enableSortControls: false
            , showPatientRelatedColumns: false
            , showWaitingRelatedFields:false
            , showVisitRelatedFields: true
            , canEditPat: false
            , canEditPrac: false
            , canEditVisitReason: false
            , canEditVisitResolution: true            
        };


    MBA.PracticeOfficeVisitsCommon.fnSetup('restviewpracticeofficevisits', optsObj);
    return;
};

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initOrderOrPrescriptionForHSDelivery() {

    let optsObj = {
        PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
        , PARM_NAME_PRAC_ID: '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'
        , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
        , PARM_NAME_DOS: '<%=Spedmon.Constants.PARM_DOS%>'
        , PARM_NAME_GROUP_ID: '<%=Spedmon.Constants.PARM_GROUP_ID%>'
        , PARM_NAME_TERM: '<%=Spedmon.Constants.PARM_SEARCH_TERM%>'
        , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
        , containerCtrlID: 'ordersorprescriptionshsprovidedfordoscontainer'
        , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
        , baseUrlView: '<%=Spedmon.ServiceJournalRecentProcedureEntries.URL_REST_VIEW_OPEN_BASE()%>'
        , defaultPageRowOrder: '<%=Spedmon.ServiceJournalRecentProcedureEntry.DEFAULT_PAGING_ORDER%>'
        , baseUrlViewSelPatOrdersForDOS: '<%=Spedmon.ServiceJournalsJournalEventSelections.URL_VIEW_SEL_JOURNAL_PAT_ORDERS_ONLY_BASE()%>'
        , baseUrlSaveJournalJournal: '<%=Spedmon.ServiceJournalsJournals.URL_SVC_SAVE_INLINE_BASE()%>'
        , baseUrlSaveJournalEntry: '<%=Spedmon.ServiceJournalsJournalEntries.URL_SVC_SAVE_INLINE_BASE()%>'
        , tkn: '<%=this.rd.wu.usr.token%>'
    };
    MBA.OrdersOrPrescriptionsProvideHSForPatOnDOSCommon.fnSetup('ordersorprescriptionshsprovidedfordos', optsObj);
    return;
};

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initVitalsMeasurementsForPatOnDOS() {
        
    let optsForPatientVitalSigns = {};

    optsForPatientVitalSigns.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
    optsForPatientVitalSigns.PARM_NAME_PAT_ID    = '<%=Spedmon.Constants.PARM_PATIENT_ID%>';
    optsForPatientVitalSigns.PARM_NAME_ACTIVE    = '<%=Spedmon.Constants.PARM_ACTIVE%>';
    optsForPatientVitalSigns.containerCtrlID     = 'vitalsmeasurementsfordoscontainer';
    optsForPatientVitalSigns.sessionTimeOutUrl   = '<%=MBA.Credential.generateSessionExpiredLink()%>';
    optsForPatientVitalSigns.baseUrlView         = '<%=Spedmon.PatientVitalsMeasurements.URL_REST_VIEW_BASE()%>';
    optsForPatientVitalSigns.defaultPageRowOrder = '<%=Spedmon.PatientVitalsMeasurement.DEFAULT_PAGING_ORDER%>';
    optsForPatientVitalSigns.baseUrlAddNew       = '<%=Spedmon.PatientVitalsMeasurements.URL_REST_SAVE_INLINE_BASE()%>';
    optsForPatientVitalSigns.baseUrlEdit         = '<%=Spedmon.PatientVitalsMeasurements.URL_REST_SAVE_INLINE_BASE()%>';
    optsForPatientVitalSigns.baseUrlDelete       = '<%=Spedmon.PatientVitalsMeasurements.URL_REST_DELETE_INLINE_BASE()%>';
    optsForPatientVitalSigns.baseUrlReport       = '<%=Spedmon.PatientVitalsMeasurements.URL_WEB_REPORT_BASE()%>';
    optsForPatientVitalSigns.defaultReportNumber = '<%=Spedmon.PatientVitalsMeasurementView.REPT_NUM_VIEW%>';

    MBA.PatientVitalSignsMeasurementCommon.fnSetup('vitalsmeasurementsfordos', optsForPatientVitalSigns);

    };

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initOrdersOrPrescriptionsRestView() {
    let optsObj = {
          PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
        , PARM_NAME_GROUP_SVC_CLASS_NAME_ID: '<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>'
        , PARM_NAME_SITE_ID: '<%=Spedmon.Constants.PARM_SITE_ID%>'
        , PARM_NAME_PRAC_ID: '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'
        , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
        , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
        , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
        , PARM_NAME_ORP_APR_STATE:'<%=Spedmon.Constants.PARM_ORP_APPROVAL_STATE%>'
        , containerCtrlID: 'datamanagerowsrestviewordersorprescriptions'
        , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
        , baseUrlView: '<%=Spedmon.ORPDocuments.URL_REST_VIEW_ORP_DOCS_ORDERS_AND_PROFILES()%>'
        , defaultPageRowOrder:'id desc'
        , baseUrlAddNew: '<%=Spedmon.ORPDocuments.URL_ADD_NEW_ORDER_PRESCRIPTION()%>'
        , baseUrlEdit: '<%=Spedmon.ORPDocuments.URL_EDIT_ORDER_PRESCRIPTION_BASE()%>'
        , baseUrlDelete: '<%=Spedmon.ORPDocuments.URL_DELETE_ORDER_PRESCRIPTION_BASE()%>'
        , baseUrlReport: '<%=Spedmon.ORPDocuments.URL_WEB_REPORT_ORP_DOCS_ORDERS_AND_PROFILES()%>'
        , defaultReportNumber: '<%=Spedmon.ORPDocumentsViw.REPT_NUM_VIEW_ORDERS_AND_PROFILES%>'
        , autoHidePageControls: true
        , enableScrollView: true
        , scrollViewUseCustomHeight: true
        , scrollViewCustomHeight: '20em'
        , showActive: false
        , showPatientName: false
        , showPracticeName: false
        , showSiteName:false
        , hasCarePlanAccess: true
        , editCarePlanUrl: '<%=Spedmon.PlanWriterPlans.GEN_URL_ASPX_SAVE()%>'
        , svcAuthReqOrderOrPrescriptionUrl: '<%=Spedmon.ORPDocuments.URL_REQUEST_SVC_AUTH_ORDER_PRESCRIPTION_BASE()%>'
        , svcAuthReqPatProfileUrl: '<%=Spedmon.ORPDocuments.URL_REQUEST_SVC_AUTH_PATIENT_PROFILE_BASE()%>'
        , autoHidePageControls: true
        , fnGetActiveValue: function (dataObj) { return '1'; }
        , fnGetOrpApprovalStateValue: function (dataObj) { return ''; }
    };

    MBA.OrdersOrPrescriptionsCommon.fnSetup('restviewordersorprescriptions', optsObj);
    return;
};

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function fireSpedmonInputDataEvent() {
        $('#restviewcareplans').trigger('spedmoninputdata');
}

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initCarePlansView() {
    let optsForCarePlans = {};

    optsForCarePlans.CONST_ATTR_CLIENT_ID = 'clientID';
    optsForCarePlans.PARM_NAME_PLAN_TYPE  = 'plantypeid';
    optsForCarePlans.PARM_NAME_CLIENT_ID  = '<%=Constants.PARM_CLIENT_ID%>';
    optsForCarePlans.PARM_NAME_PAT_ID     = '<%=Constants.PARM_PATIENT_ID%>';
    optsForCarePlans.PARM_NAME_REC_ID     = '<%=Constants.PARM_REC_ID%>';
    optsForCarePlans.PARM_NAME_TERM       = '<%=Constants.PARM_SEARCH_TERM%>';
    optsForCarePlans.PARM_NAME_PRAC_ID    = '<%=Constants.PARM_PRACTITIONER_ID%>';
    optsForCarePlans.PARM_NAME_GROUP_SVC_CLASS_NAME_ID = '<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    optsForCarePlans.PARM_NAME_SITE_ID                 = '<%=Constants.PARM_SITE_ID%>';
    optsForCarePlans.PARM_NAME_FISCAL_YEAR_ID          = '<%=Constants.PARM_FISCAL_YEAR_ID%>';
    optsForCarePlans.PARM_NAME_IS_CREATED_BY_CALLER    = '<%=Constants.PARM_IS_CREATED_BY_CALLER%>';
    optsForCarePlans.PARM_NAME_IS_EXPIRING             = '<%=Constants.PARM_IS_EXPIRING%>';
    optsForCarePlans.PARM_NAME_IS_EXPIRED              = '<%=Constants.PARM_IS_EXPIRED%>';
    optsForCarePlans.PARM_NAME_ACTIVE                  = '<%=Constants.PARM_ACTIVE%>';
    optsForCarePlans.ROLE_LEA_PROVIDER_ID              = '<%=Constants.ROLE_LEA_PROVIDER_ID%>';
    optsForCarePlans.sessionTimeOutUrl                 = '<%=MBA.Credential.generateSessionExpiredLink()%>';
    optsForCarePlans.baseUrlClone                      = '<%=Spedmon.PlanWriterPlans.URL_ASMX_SAVE_NO_JSON_BASE()%>';
    optsForCarePlans.baseUrlAddNew                     = '<%=Spedmon.PlanWriterPlans.URL_ASMX_SAVE_NO_JSON_BASE()%>';
    optsForCarePlans.containerCtrlID                   = 'datamanagerowsrestviewcareplans';
    optsForCarePlans.baseUrlEdit                       = '<%=Spedmon.PlanWriterPlans.URL_ASMX_SAVE_NO_JSON_BASE()%>';
    optsForCarePlans.baseUrlDelete                     = '<%=Spedmon.PlanWriterPlans.URL_ASMX_DELETE_BASE()%>';
    optsForCarePlans.baseUrlView                       = '<%=Spedmon.PlanWriterPlans.URL_REST_VIEW_BASE()%>';
    optsForCarePlans.defaultPageRowOrder               = '<%=Spedmon.PlanWriterPlanJSON.DEFAULT_PAGING_ORDER%>';
    optsForCarePlans.baseUrlPDF                        = '<%=Spedmon.PlanWriterPlans.URL_PDF_PREVIEW_BASE()%>';
    optsForCarePlans.baseUrlPatID                      = '<%=Spedmon.Patients.URL_SVC_VIEW_SEL_BASE()%>';
    optsForCarePlans.baseUrlASMXReqAuth                = '<%=Spedmon.PlanWriterPlans.URL_ASMX_REQ_AUTH_BASE()%>';
    optsForCarePlans.baseUrlChangePlanAuthor           = '<%=Spedmon.PlanWriterPlans.GEN_URL_ASPX_CHANGE_PLAN_AUTHOR()%>';
    optsForCarePlans.baseUrlSelectUser                 = '<%=Spedmon.Users.URL_ASMX_VIEW_SEL_BASE()%>';
    optsForCarePlans.baseURLSaveDiagnoses              = '<%=Spedmon.PlanWriterDiagnoses.URL_SAVE_BASE()%>';
    optsForCarePlans.baseURLDeleteDiagnoses            = '<%=Spedmon.PlanWriterDiagnoses.URL_DELETE_BASE()%>';
    optsForCarePlans.baseURLViewDiagnoses              = '<%=Spedmon.PlanWriterDiagnoses.URL_VIEW_SEL_BASE()%>';
    optsForCarePlans.baseURLCoorManage                 = '<%=Spedmon.ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_NEW_BASE()%>';
    optsForCarePlans.baseURLDeleteOrder                = '<%=Spedmon.ORPDocuments.URL_DELETE_ORDER_PRESCRIPTION_BASE()%>';
    optsForCarePlans.baseUrlSelOrpDocs                 = '<%=Spedmon.PlanWriterPlans.URL_ASMX_VIEW_SEL_ORP_DOCS_BASE()%>';
    optsForCarePlans.baseUrlSavePatPerson              = '<%=Spedmon.PatientPersons.URL_SAVE_BASE()%>';
    optsForCarePlans.baseUrlViewSelPatPerson           = '<%=Spedmon.PatientPersons.URL_VIEW_SEL_BASE()%>';    
    optsForCarePlans.userPrevSignature                 = '<%=userPrevSignature%>';
    optsForCarePlans.userId                            = '<%=uInfo.useridStr%>';
    optsForCarePlans.lastName                          = '<%=rd.wu.usr.lastName%>';
    optsForCarePlans.firstName                         = '<%=rd.wu.usr.firstName%>';
    optsForCarePlans.email                             = '<%=rd.wu.usr.email%>';
    optsForCarePlans.phone                             = '<%=rd.wu.usr.phone%>';
    optsForCarePlans.roleID                            = '<%=rd.wu.usr.roleID%>';

    MBA.CarePlansCommon.fnSetup('restviewcareplans', optsForCarePlans);
    return;
};

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initPatientPersonsView() {
    
    let optsObj = {
        PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
        , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
        , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
        , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
        , PARM_PERSON_ROLE_ID: '<%=Spedmon.Constants.PARM_PERSON_ROLE_ID%>'
        , containerCtrlID: 'datamanagerowsrestviewpatientpersons'
        , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
        , baseUrlView: '<%=Spedmon.PatientPersons.URL_REST_VIEW_BASE()%>'
        , defaultPageRowOrder: '<%=Spedmon.PatientPerson.DEFAULT_PAGING_ORDER%>'
        , baseUrlAddNew: '<%=Spedmon.PatientPersons.URL_SAVE_INLINE_BASE()%>'
        , baseUrlEdit: '<%=Spedmon.PatientPersons.URL_SAVE_INLINE_BASE()%>'
        , baseUrlDelete: '<%=Spedmon.PatientPersons.URL_DELETE_INLINE_BASE()%>'
        , baseUrlReport: ''
        , defaultReportNumber: '1'
        , autoHidePageControls: true
        , enableScrollView: true
        , scrollViewUseCustomHeight: true
        , scrollViewCustomHeight: '20em'
        , isPcalStaff:<%=isPcalStaffJSBoolStr%>
        , currentPage: 1
    };

    MBA.PatientPersonsCommon.fnSetup('restviewpatientpersons', optsObj);
        return;
};

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initPromisedServicesView() {

    let optsObj = {
          PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
        , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
        , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
        , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'

        , containerCtrlID: 'datamanagerowsrestviewpatientpromisedservices'
        , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
        , baseUrlView: '<%=Spedmon.PatientPromisedServices.URL_REST_VIEW()%>'
        , defaultPageRowOrder: '<%=Spedmon.PatientPromisedService.DEFAULT_PAGING_ORDER%>'
        , baseUrlAddNew: '<%=Spedmon.PatientPromisedServices.URL_ADD_NEW_PATIENT_PROMISED_SERVICE()%>'
        , baseUrlEdit: '<%=Spedmon.PatientPromisedServices.URL_EDIT_PATIENT_PROMISED_SERVICE()%>'
        , baseUrlDelete: '<%=Spedmon.PatientPromisedServices.URL_REST_DELETE_INLINE()%>'
        , baseUrlReport: ''
        , defaultReportNumber: '1'
        , autoHidePageControls: true
        , enableScrollView: true
        , scrollViewUseCustomHeight: true
        , scrollViewCustomHeight: '20em'
    };

    MBA.PatientPromisedServicesCommon.fnSetup('restviewpatientpromisedservices', optsObj);
    return;
    };

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initPatientGoalsView() {

    let optsObj = {};

    optsObj.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
    optsObj.PARM_NAME_PAT_ID = '<%=Spedmon.Constants.PARM_PATIENT_ID%>';
    optsObj.PARM_NAME_PAT_GOAL_ID = '<%=Spedmon.Constants.PARM_PATIENT_GOAL_ID%>';
    optsObj.PARM_NAME_ACTIVE = '<%=Spedmon.Constants.PARM_ACTIVE%>';
    optsObj.PARM_NAME_GROUP_SVC_CLASS_NAME_ID = '<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    optsObj.PARAM_ROLE_LEA_PROVIDER_ID = '<%=Spedmon.Constants.ROLE_LEA_PROVIDER_ID%>';
    optsObj.containerCtrlID = 'datamanagerowsrestviewpatientgoals';
    optsObj.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
    optsObj.baseUrlView = '<%=Spedmon.PatientGoals.URL_REST_VIEW_BASE()%>';
    optsObj.defaultPageRowOrder = '<%=Spedmon.PatientGoal.DEFAULT_PAGING_ORDER%>';
    optsObj.baseUrlAddNew = '<%=Spedmon.PatientGoals.URL_REST_SAVE_INLINE_BASE()%>';
    optsObj.baseUrlEdit = '<%=Spedmon.PatientGoals.URL_REST_SAVE_INLINE_BASE()%>';
    optsObj.baseUrlDelete = '<%=Spedmon.PatientGoals.URL_REST_DELETE_INLINE_BASE()%>'
    optsObj.groupSvcClassNameIDOpts = '<%=Spedmon.GroupsServiceClasses.URL_REST_VIEWSEL_FOR_ORP_DOCS_BASE()%>';
    optsObj.patientGoalsDefaultDates = '<%=Spedmon.PatientGoalsDefaultDates.URL_SVC_VIEW_DEFAULT_DATES_BASE()%>';
    optsObj.baseUrlIndividualGoal = '<%=Spedmon.PatientGoalsProgressIndividualGoals.URL_SVC_VIEW_PROGRESS_INDIVIDUAL_GOALS_BASE()%>';
    optsObj.roleID = '<%=rd.wu.usr.roleID%>';
    optsObj.baseUrlViewProgress = '<%=urlViewAllPatientGoalsProgress%>';
    optsObj.pracGrpSvcClassNameID = '<%=visitGrpSvcClassNameID%>';
    optsObj.autoHidePageControls = true;
    optsObj.enableScrollView = true;
    optsObj.scrollViewUseCustomHeight = true;
    optsObj.scrollViewCustomHeight = '20em';

    MBA.PatientGoalsCommon.fnSetup('restviewpatientgoals', optsObj);

    return;
}

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initInsuranceCoverageView() {

    let optsObj = {};

    optsObj.PARM_NAME_CLIENT_ID   = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
    optsObj.PARM_NAME_PAT_ID      = '<%=Spedmon.Constants.PARM_PATIENT_ID%>';
    optsObj.PARM_NAME_ACTIVE      = '<%=Spedmon.Constants.PARM_ACTIVE%>';
    optsObj.containerCtrlID       = 'datamanagerowsrestviewpatientinsurance';
    optsObj.sessionTimeOutUrl     = '<%=MBA.Credential.generateSessionExpiredLink()%>';
    optsObj.baseUrlView           = '<%=Spedmon.PatientInsuranceCarriers.URL_PATIENT_CARRIERS_REST_VIEW_BASE()%>';
    optsObj.defaultPageRowOrder   = '<%=Spedmon.PatientInsuranceCarrier.DEFAULT_PAGING_ORDER%>';
    optsObj.baseUrlAddNew         = '<%=Spedmon.PatientInsuranceCarriers.URL_REST_PATCARRIER_SAVE_INLINE_BASE()%>';
    optsObj.baseUrlEdit           = '<%=Spedmon.PatientInsuranceCarriers.URL_REST_PATCARRIER_SAVE_INLINE_BASE()%>';
    optsObj.baseUrlInsuranceCarrierIDSel = '<%=Spedmon.InsuranceCarriers.URL_VIEW_SEL_BASE()%>';    
    optsObj.autoHidePageControls      = true;
    optsObj.enableScrollView          = true;
    optsObj.scrollViewUseCustomHeight = true;
    optsObj.scrollViewCustomHeight    = '20em';
    optsObj.fnGetPatientLastName = function (dataObj) {
        let lname = '<%=pat.name%>'.split(',');
        return lname[0];
    }
    optsObj.fnGetPatientFirstName= function (dataObj) {
        let fname = '<%=pat.name%>'.split(',');
        return fname[1];
    }
    MBA.PatientInsuranceCommon.fnSetup('restviewpatientinsurance', optsObj);

  return;
}

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initServiceRecordsView() {

    let optsObj = {
        PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
      , PARM_NAME_PATIENT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
      , containerCtrlID: 'datamanagerowsrestviewservicerecords'
      , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
      , baseUrlView: '<%=Spedmon.ServiceRecords.URL_REST_VIEW_BASE()%>'
      , defaultPageRowOrder: 'dos desc'
      , baseUrlReport: ''
      , defaultReportNumber: '1'
      , autoHidePageControls: true
      , enableScrollView: true
      , scrollViewUseCustomHeight: true
      , scrollViewCustomHeight: '20em'          
    };

    MBA.PatientServiceRecordsCommon.fnSetup('restviewservicerecords', optsObj);
   
    return;
};

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initStoredFilesView() {

  let optsObj = {
      PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
    , PARM_NAME_DATE_RANGE: '<%=Constants.PARM_DATE_RANGE%>'
    , PARM_NAME_FILE_CLASS: '<%=Constants.PARM_FILE_CLASS%>'
    , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
    , PARM_NAME_FILE_ID: '<%=Spedmon.StoredFiles.PARAM_FILE_ID%>'
    , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
    , containerCtrlID: 'datamanagerowsrestviewstoredfiles'
    , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
    , baseUrlView: '<%=Spedmon.StoredFiles.URL_REST_VIEW_BASE()%>'
    , defaultPageRowOrder: '<%=Spedmon.StoredFile.DEFAULT_PAGING_ORDER%>'
    , baseUrlDelete: '<%=Spedmon.StoredFiles.URL_WEB_SVC_DELETE()%>'
    , baseUrlReport: '<%=Spedmon.StoredFiles.URL_WEB_REPORT_BASE()%>'
    , defaultReportNumber: '<%=Spedmon.StoredFilesRpt.REPT_NUM_VIEW%>'
    , autoHidePageControls: true
    , enableScrollView: true
    , scrollViewUseCustomHeight: true
    , scrollViewCustomHeight: '20em'    
    , isPcalStaff:<%=isPcalStaffJSBoolStr%>
    , showPatientName: false
    , webSvcFlagAsNonConfidentialUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_FLAG_AS_NON_CONFIDENTIAL()%>'
    , webSvcFlagAsConfidentialUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_FLAG_AS_CONFIDENTIAL()%>'
    , webSvcEnableSharingWithPatientUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_ENABLE_SHARING_WITH_PATIENT()%>'
    , webSvcDisableSharingWithPatientUrl: '<%=Spedmon.StoredFiles.URL_WEB_SVC_DISABLE_SHARING_WITH_PATIENT()%>'
    , webSvcEnableSharingWithParentUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_ENABLE_SHARING_WITH_PARENT()%>'
    , webSvcDisableSharingWithParentUrl: '<%=Spedmon.StoredFiles.URL_WEB_SVC_DISABLE_SHARING_WITH_PARENT()%>'
    , currUserID: <%=rd.wu.usr.id%>
    , downloadHandlerPrivateBaseUrl: '<%=Spedmon.StoredFiles.URL_DOWNLOAD_HANDLER_PRIVATE_BASE()%>'
    , fnGetFileClassValue: function (dataObj) { return '';}
    , fnGetDateRangeValue: function (dataObj) { return ''; }
    , showOKToShareWithPatient: false
    , showOKToShareWithParentGuardian: false
  };

  $restViewStoredFiles = MBA.StoredFilesCommon.fnSetup('restviewstoredfiles', optsObj);
  return;
};

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  function exitVisit() {        
    if ( hideVisitSection == true ) {
        doCompletePracticeOfficeVisit(true);  /* Slightly more reliable */
        return;
    } else {
        if (<%=Util.netBoolToJSBool(visitScreenIsWindow)%> == true) {
            window.close();
        } else {
            $.spedmonWebUI.gotoURL('<%=goBackURL%>');
       }
    }
    return;
  }

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    
$(window).on('load', function () {

  $r1_cl = $('#r1-cl');
  $r1_cr = $('#r1-cr');

  /* Get control references for resolution data */

  $ctrlPovResolutionID    = $('#<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_ID%>');
  $ctrlPovResolutionNotes = $('#<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_NOTES%>');
  $ctrlPovResolutionFBQ   = $('#<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_FBQJ%>');
  $ctrlPovResolutionFBA   = $('#<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_RESOLUTION_FBAJ%>');

  /* Determine if we hide (and autosave) the visit resolution data */

  hideVisitSection = <%=Util.netBoolToJSBool(povr.hideVisitSection)%>;

  practiceOfficeVisitComplete = false;

  /* Setup tabs */

  /*$("#tabs").tabs();
  $('#tabs').addClass('data-entry-row-tabs');*/
  $("#tabs").MBA_Tabs({});

  initStoredFilesView(); /* Has to be before profile init because of stored files ref depend*/
  initProfile();

    /* Setup entry forms */

  initPatientCareNotes();
  initOrderOrPrescriptionForHSDelivery();
  initVitalsMeasurementsForPatOnDOS();


  /* Setup rest views */

  initKnownHealthProblemsRestView();
  initAllergiesRestView();
  initDiagnosesRestView();
  
  initPracticeOfficeRestView();
  initOrdersOrPrescriptionsRestView();
  initCarePlansView();
  initPatientPersonsView();
  initPromisedServicesView();
  initPatientGoalsView();
  initInsuranceCoverageView();
  initServiceRecordsView();
  
  /* Setup our close window guard */

  window.addEventListener('beforeunload', onBeforeUnloadHandler);

  /* Setup note lib for visit notes */

  let _fnNoteLibFormBuilder = function ($div) {
    $($div).html('');

    renderFormInDiv (  $div
                     , '' + $($ctrlPovResolutionFBQ).val()
                     , '' + $($ctrlPovResolutionFBA).val()
                     , '<%=prac.clientID.ToString()%>'
                     , '<%=pat.id.ToString()%>'
                     , '<%=prac.groupID.ToString()%>'
                     , function (fbNoteAnswersJSON) { $($ctrlPovResolutionFBA).val(fbNoteAnswersJSON); });
    
  };

  let _fnNoteLibGetPatID = function () {
    return '<%=pat.id.ToString()%>';
  };

  $($ctrlPovResolutionNotes).notelibrary({
          displayMode: ""
        , useMenu: true
        , useLabelInOpenButton: false
        , sel_tmp_enabled: false
        , tkn: '<%=rd.wu.usr.token%>'
        , noteforpatidfn: (_fnNoteLibGetPatID)
        , additionalcontentfn: (_fnNoteLibFormBuilder)
  });

  $($ctrlPovResolutionNotes).siblings('button.mba-notelibrary').children('i.mba-notelibrary').addClass('fa-2x');
  $($ctrlPovResolutionNotes).MBA_DataEntryBox({});
  
  if (hideVisitSection == false) {
    $('#practiceofficevisitsection').show();
  }    

  $($ctrlPovResolutionNotes).MBA_DataEntryBox('evaluateCurrentEntry', 'input'); /* Makes sure any preloaded value is visible */

});

</script>

<%} else {%>
<div class="container-fluid">
<div class="row">
<div class="col-11">
<div class="alert alert-info">
    <%=errorMessage%>
</div> <!-- alert -->
</div> <!-- col -->
<div class="col-1">
    <Spedmon:DataEntryButton ID="butErrorMessageClose" label="Close" title="Click here to close this window" onclick="window.close()" runat="server" />
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->
<%}%>