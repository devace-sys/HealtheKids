<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_manage_patients_with_missing_info.aspx.cs" Inherits="Spedmon.UserAllManagePatientsWithMissingInfo" %>

<%/*###############################################################################################
    #
    #                           Bulk Cancel Information Request Dialog
    #
    ###############################################################################################*/%>

<div id="diaContentBulkCancelRequestInfoForPats" title="<%=LABEL_BULK_INFO_REQUEST_CANCEL%>">
  <p><span>Cancel all pending (requests with no replies) older than </span>
  <Spedmon:DataEntryBoxNumber ID="ageindays" fireSpedmonInput="false" label="Number of Days" value="7" required="true" size="10" runat="server"/>
  </p>
  <p>Select or enter a value of 0 if you wish to cancel everything.</p>
  <p>Click proceed if you wish to continue.  This action cannot be undone.</p>
</div> <!-- dialog -->

<%/*###############################################################################################
    #
    #                           Bulk Request Information Dialog
    #
    ###############################################################################################*/%>

<div id="diaContentBulkRequestInfoForPats" title="<%=LABEL_BULK_INFO_REQUEST_SEND%>">
    <div class="container-fluid">    
        <div class="row">
        <div class="col-12">
        <p>
        For each student that :
        <br>
        1. Does NOT CURRENTLY have a pending private information request.<br>
        2. Has parent/guardian records in SpEdCare WITH VALID EMAIL ADDRESSES.<br>
        <br />
        A new information request will be created and emailed to their parent or guardian(s).
        </p>

        <p>
        It may take some time to process all of the students in a request.  
        You will receive a message in SpEdCare (and an email notification sent to your email on record in SpEdCare)
        when a batch request has been completed.  Until that time no new requests will 
        be allowed and cancelling requests will also not be allowed.
        </p>

        <p>
        Please fill out the following information and click the Proceed button if you wish to continue.
        </p>

        </div> <!-- col -->
    </div> <!-- row -->

    <div class="row">
    <div class="col-12">
    <Spedmon:DataEntryBoxText ID="requestername" fireSpedmonInput="false" label="District Contact Name" required="true" size="30" maxLen="500" runat="server"/>
    </div> <!-- col -->
    </div> <!-- row -->
    
    <div class="row">
    <div class="col-6">
    <Spedmon:DataEntryBoxEmail ID="requesteremail" fireSpedmonInput="false" label="District Contact Email Address" required="true" size="20" maxLen ="255" runat="server"/>
    </div> <!-- col -->

    <div class="col-6">
    <Spedmon:DataEntryBoxPhone ID="requesterphone" fireSpedmonInput="false" label="District Contact Phone Number" required="false" size="15" maxLen = "255" runat="server"/>
    </div> <!-- col -->
    </div> <!-- row -->
    
    </div> <!-- container -->
</div> <!-- dialog -->

<%/*###############################################################################################
    #
    #                       Single Fix Problems / Request Information Dialog
    #
    ###############################################################################################*/%>

<div id="diaRequestInfoForPat" title="Fix Problems">
<div class="container-fluid">

<Spedmon:HiddenInput ID="patid" name="patid" title="patid" runat="server"/>

<div id="dia-fix-problems-row-missing-insurance-info" title="Fix Problems" class="row mt-3">
<div class="col-12">
<h5><i class="fas fa-exclamation-triangle mr-1"></i>Missing Insurance Information and/or Missing FERPA Consent</h5>
<p>Please select one or more parent/guardians from the list below to send an insurance information and FERPA consent request to and then click Send Request.</p>
<div id="datamanagerowsrestviewpatientpersons">
<div id="restviewpatientpersons"></div>
</div> <!-- restview cont -->
</div> <!-- col -->
</div> <!-- row -->

<div id="dia-fix-problems-row-missing-home-address" class="row mt-3">
<div class="col-12">
<h5><i class="fas fa-exclamation-triangle mr-1"></i>Missing Home Address Information</h5>
<p>Please find the students home address in your student information system and then add the addresss to their SpEdCare profile.</p>
</div> <!-- col -->
</div> <!-- row -->

<div class="row mt-3">
<div class="col-12">
<div class="d-flex flex-row justify-content-end">
<button id="dia-fix-problems-btn-do-cancel" type="button" class="btn btn-secondary"><i class="fa fa-times-circle mr-1"></i>Cancel</button>
<button id="dia-btn-do-send-info-request" type="button" class="btn btn-primary ml-2"><i class="fa fa-envelope mr-1"></i>Send Request</button>
</div>
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->
</div> <!-- dialog --> 

<%/*###############################################################################################
    #
    #                                         Main UI
    #
    ###############################################################################################*/%>

<div id="dataManagementRows" class="container-fluid">

<div class="row">

<%/*###############################################
    # Select Client (PCAL Staff Only)
    ###############################################*/%>

<div class="col-xl-4 col-lg-12 col-md-12 col-sm-12 col-12">
  <div class="d-flex justify-content-center mt-1">
  <Spedmon:DataEntryRowSelectClient ID="selectClient" entityControlID="clientid" rowLabel="Client" dataEntryRowRenderAs="FIELD" showClearSelection="true" runat="server"> </Spedmon:DataEntryRowSelectClient>
  <Spedmon:HiddenInput ID="active"               name="active"               title="active"               runat="server"/>
  <Spedmon:HiddenInput ID="datasource"           name="datasource"           title="datasource"           runat="server"/>
  </div>
</div> <!-- col -->

<%/*###############################################
    # Parent/Guardian Search (PCAL Staff Only)
    ###############################################*/%>

<div class="col-xl-4 col-lg-6 col-md-12 col-sm-12 col-12">
<div class="d-flex justify-content-center mt-1">
    <%if(isPCalStaff == true){%>
    <Spedmon:DataEntryBoxSearch
                ID                 = "term"
                name               = "term"
                label              = "Search For Parent/Guardians By Email or Name"
                fireSpedmonInput   = "false"
                title              = "Enter search term then click search icon.  Opens a new window."
                size               = "20"
                runat              = "server" />

    <Spedmon:DataEntryButton
                ID                 = "butdosearch"
                title              = "Click here to search (Opens a New Window)"
                iconOnly           = "true"
                faIcon             = "fa fa-search text-success"
                assignBsCssClasses = "false"
                size               = "LARGE"
                onclick            = "openPatientPersonResults()"
                runat              = "server"   />
    <%}%>
</div> <!-- flex -->
</div> <!-- col -->

<div class="col-xl-4 col-lg-6 col-md-12 col-sm-12 col-12">

<div class="d-flex justify-content-center mt-1">

<%/*###############################################
    # Bulk Options
    ###############################################*/%>

<%if (canAccessPatientInfoRequestResponseSystem) {%>
  
  <Spedmon:DataEntryButton 
          ID            ="butDoBulkRequest"
          runat         ="server"
          style         ="PRIMARY"
          size          ="SMALL"        
          cssClass      ="mr-2"
          onclick       ="doOpenDiaBulkRequestPatientInfo()"
          label         ="Send Requests"
          title         ="Click here to send a private student info request to all related parent guardians with valid email addresses"
          faIcon        ="fas fa-envelope" />
      
  <Spedmon:DataEntryButton
          ID            ="butDoCancelAllInfoRequests"
          runat         ="server"
          style         ="DANGER"
          size          ="SMALL"        
          cssClass      ="mr-2"
          onclick       ="doOpenDiaBulkCancelPatientInfoRequest()"
          label         ="Cancel Pending Requests"
          title         ="Click here to cancel all pending (requests that have not received a response) private student info requests"
          faIcon        ="fas fa-trash" />

<%}%>

<%/*###############################################
    # Request Options
    ###############################################*/%>

<%if (canAccessCombinedOptionsManageScreen){%>

<Spedmon:DataEntryButton 
      ID                 = "openRequestFormOptions" 
      title              = "Open Request Form Options" 
      label              = "Request Form Options"
      fireSpedmonInput   = "false" 
      assignBsCssClasses = "true" 
      size               = "SMALL"
      faIcon             = "fas fa-cog"
      style              = "SUCCESS"
      
      onclick            = "openRequestFormOptions()"
      runat              = "server" />    
<%}%>

</div> <!-- flex-->

</div> <!-- col -->
</div> <!-- row -->

<div class="row mt-2">
<div class="col-12">

<%/*###############################################
    # Tabs
    ###############################################*/%>

<div id="tabs">
<ul>
  <li><a href="#tab-missing-info-pats">Students with Missing Information</a></li> 
  <li><a href="#tab-missing-info-pats-require-followup">Responses for Potential Followup</a></li>
</ul>

<%/*###############################################
    # Tab - Missing Info Patients
    ###############################################*/%>

<div id="tab-missing-info-pats">
<div class="container-fluid">

<%/*######################
    # Filters
    ######################*/%>

<div class="row">

<div class="col-2">
  <Spedmon:SelectYesOrNoOrAny ID="missingpgemails" anyLabel="Either" title="Missing<br>Parent/Guardian Info or Emails?" runat="server"/>
</div> <!-- col -->

<div class="col-2">
  <Spedmon:SelectYesOrNoOrAny ID="missinginsuranceinfo" title="Missing<br>Insurance Info?" anyLabel="Either" runat="server"/>
</div> <!-- col -->

<div class="col-2">
  <Spedmon:SelectYesOrNoOrAny ID="missingaddressinfo" title="Missing<br>Address Info?" anyLabel="Either"  runat="server"/>
</div> <!-- col -->

<div class="col-2">
  <Spedmon:SelectYesOrNoOrAny ID="missingferpaconsent" title="Missing<br>FERPA Consent?" anyLabel="Either" runat="server"/>
</div> <!-- col -->

<div class="col-2">
  <Spedmon:SelectYesIsTrueNoIsBlank ID="hascurrinforqst" title="Show Only<br>Pending Requests?"  runat="server"/>
</div> <!-- col -->

<div class="col-2">
  <Spedmon:SelectYesIsTrueNoIsBlank ID="hascurrinforqstreqrvw" title="Show Only<br>Responses Requiring Review?" runat="server"/>
</div> <!-- col -->

</div> <!-- row -->

<%/*######################
    # Rest View
    ######################*/%>

<div class="row mt-3">
<div class="col-12">
  <div id="restview-missing-info-pats"></div> 
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->
</div> <!-- tab -->


<%/*###############################################
    # Tab - Missing Info Patients Responses 
    # that Require Followup
    ###############################################*/%>

<div id="tab-missing-info-pats-require-followup">
<div class="container-fluid">
<div class="row">
<div class="col-12">
<div id="restview-missing-info-pats-responses-requiring-followup"></div>
</div> <!-- col-->
</div> <!-- row-->
</div> <!-- container -->
</div> <!-- tab -->


</div> <!-- tabs -->
</div> <!-- col-->
</div> <!-- row -->
</div> <!-- container -->

<%/*###############################################################################################
    #
    #                                   Inline Scripts
    #
    ###############################################################################################*/%>
   
<script type="text/javascript">

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

const PARM_NAME_DATA_SOURCE            = '<%=Constants.PARM_DATA_SOURCE%>';
const PARM_NAME_ACTIVE                 = '<%=Constants.PARM_ACTIVE%>';
const PARM_NAME_CLIENT_ID              = '<%=Constants.PARM_CLIENT_ID%>';
const PARM_NAME_PAT_ID                 = '<%=Constants.PARM_PATIENT_ID%>';
const PARM_NAME_MISSING_INSURANCE_INFO = '<%=Constants.PARM_MISSING_INSURANCE_INFO%>';
const PARM_NAME_MISSING_ADDRESS_INFO   = '<%=Constants.PARM_MISSING_ADDRESS_INFO%>';
const PARM_NAME_MISSING_FERPA_CONSENT  = '<%=Constants.PARM_MISSING_FERPA_CONSENT%>';
const PARM_NAME_MISSING_PG_EMAILS      = '<%=Constants.PARM_MISSING_PG_EMAILS%>'

const PARM_NAME_HAS_CURR_INFO_REQUEST         = '<%=Constants.PARM_HAS_CURR_INFO_REQUEST%>';
const PARM_NAME_HAS_CURR_INFO_REQUEST_REQ_RVW = '<%=Constants.PARM_HAS_CURR_INFO_REQUEST_THAT_REQUIRES_REVIEW%>';
const PARM_NAME_HAS_PREV_INFO_REQUEST         = '<%=Constants.PARM_HAS_PREV_INFO_REQUEST_THAT_REQUIRED_REVIEW%>'

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

let $dataManagementRows                               = null;
let $restViewMissingInfoPats                          = null;    
let $restViewPatPersons                               = null;
let $patid                                            = null;
let $diaRequestInfoForPat                             = null;
let $diaFixProblemsRowMissingHomeAddress              = null;
let $diaFixProblemsRowMissingInsuranceInfo            = null;
let $diaBtnFixProblemsBtnDoCancel                     = null;
let $diaBtnDoSendInfoRequest                          = null;
let $diaContentBulkRequestInfoForPats                 = null;
let $diaContentBulkCancelRequestInfoForPats           = null;
let $diaBulkRequestInfoForPats                        = null;
let $diaBulkCancelRequestInfoForPats                  = null;
let $restViewMissingInfoPatResponsesRequiringFollowup = null;
    

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

<%/***************************************************************************
   * openPatientPersonResults
   ** 
   **************************************************************************/%>

function openPatientPersonResults() {
    let _term = $('#term').val();
    let reqUrl = '<%=Spedmon.PatientPersons.URL_USER_ALL_VIEW_BASE("")%>' + _term;
    return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
};

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

<%/***************************************************************************
   * doSendBulkInfoRequest
   ** 
   **************************************************************************/%>

function doSendBulkInfoRequest () {
       
  let reqURL = '<%=Spedmon.PatientInfoRequestsResponses.URL_SVC_SAVE_NEW_MASS_REQUEST_INLINE_BASE()%>';

  let reqDataObj = {};

  reqDataObj.clientid       = $('#' + PARM_NAME_CLIENT_ID).val();
  reqDataObj.datasource     = $('#' + PARM_NAME_DATA_SOURCE).val();
  reqDataObj.requestername  = $('#requestername').val();;
  reqDataObj.requesteremail = $('#requesteremail').val();
  reqDataObj.requesterphone = $('#requesterphone').val();

  let reqDataJSON = JSON.stringify(reqDataObj);

  MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqDataJSON, null)
  .then(responseData => {
    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('<%=LABEL_BULK_INFO_REQUEST_SEND%>', 'The bulk send request has been received and is currently being processed.  It may take some time for the request to be completed.  You will receive a SpEdCare message (and email) once the request is completed.', {});
  })
  .catch(responseData => {
    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('<%=LABEL_BULK_INFO_REQUEST_SEND%>', responseData.message, {});
  });
};

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

<%/***************************************************************************
   * doOpenDiaBulkRequestPatientInfo
   ** 
   **************************************************************************/%>

function doOpenDiaBulkRequestPatientInfo() {

  let _fnOnProceed = function () { doSendBulkInfoRequest();};

  $diaBulkRequestInfoForPats = MBA.ComponentCommon.fnCreateDialogFromElemWithProceedAndCancelButtons(
        $diaContentBulkRequestInfoForPats
        , null
        , 95
        , {}
        , _fnOnProceed
        , null
        , true
        , true
   );
};

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

<%/***************************************************************************
   * doCancelAllInfoRequests
   ** 
   **************************************************************************/%>

function doCancelAllInfoRequests () {     

  let reqURL = '<%=Spedmon.PatientInfoRequestsResponses.URL_SVC_CANCEL_ALL_REQUESTS_INLINE_BASE()%>';
  
  let reqDataObj = {};

  reqDataObj.clientid  = $('#' + PARM_NAME_CLIENT_ID).val();
  reqDataObj.ageindays = $('#ageindays').val();

  let reqDataJSON      = JSON.stringify(reqDataObj);

  MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqDataJSON, null)
  .then(responseData => {                
      MBA.ComponentCommon.fnCreateOneTimeAlertDialog('<%=LABEL_BULK_INFO_REQUEST_CANCEL%>', 'All pending requests that are older than ' + reqDataObj.ageindays + ' days have been cancelled.', {});
    $($restViewMissingInfoPats).MBA_RestView('refreshCurrentViewFromServer');
  })
  .catch(responseData => {
    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('<%=LABEL_BULK_INFO_REQUEST_CANCEL%>', responseData.message, {});
   });
 };

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

<%/***************************************************************************
   * doOpenDiaBulkCancelPatientInfoRequest
   ** 
   **************************************************************************/%>

function doOpenDiaBulkCancelPatientInfoRequest() {
   
  let _fnOnProceed = function () { doCancelAllInfoRequests();};

  $diaBulkCancelRequestInfoForPats = MBA.ComponentCommon.fnCreateDialogFromElemWithProceedAndCancelButtons(
        $diaContentBulkCancelRequestInfoForPats
      , null
      , null
      , {}
      , _fnOnProceed
      , null
      , true
      , true
    );
};

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

<%/***************************************************************************
   * initPatientPersonsView
   ** 
   **************************************************************************/%>

function initPatientPersonsView (containerCtrlID, ctrlID) {

    let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
          , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
          , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
          , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
          , PARM_PERSON_ROLE_ID: '<%=Spedmon.Constants.PARM_PERSON_ROLE_ID%>'
          , PARM_PERSON_CLASS_ID_1: '<%=Spedmon.Constants.PARM_PERSON_CLASS_ID_1%>'
          , PARM_PERSON_CLASS_ID_2: '<%=Spedmon.Constants.PARM_PERSON_CLASS_ID_2%>'
          , containerCtrlID: containerCtrlID
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
          , scrollViewCustomHeight: '15em'
          , showOnlyParentGuardian: true
          , isPcalStaff:<%=isPcalStaffJSBoolStr%>
          , enableRowNumbers:false
          , enableRowControlMarkRow: true
          , currentPage: 1
      };

      return MBA.PatientPersonsCommon.fnSetup(ctrlID, optsObj);
};
       
<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

<%/***************************************************************************
   * updateAdditionalViewParameterValuesAndRequestViewFromServer
   ** 
   **************************************************************************/%>

function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

  let VALUE_DATA_SOURCE           = $('#' + PARM_NAME_DATA_SOURCE).val();
  let VALUE_CLIENT_ID             = $('#' + PARM_NAME_CLIENT_ID).val();
  let VALUE_ACTIVE                = $('#' + PARM_NAME_ACTIVE).val();
  let VALUE_MISSING_INSURANCE     = $('#' + PARM_NAME_MISSING_INSURANCE_INFO).val();
  let VALUE_MISSING_ADDRESS       = $('#' + PARM_NAME_MISSING_ADDRESS_INFO).val();
  let VALUE_MISSING_FERPA_CONSENT = $('#' + PARM_NAME_MISSING_FERPA_CONSENT).val();
  let VALUE_MISSING_PG_EMAILS     = $('#' + PARM_NAME_MISSING_PG_EMAILS).val();
  let VALUE_HAS_CURR_INFO_RQST    = $('#' + PARM_NAME_HAS_CURR_INFO_REQUEST).val();
  let VALUE_HAS_CURR_INFO_RQST_RR = $('#' + PARM_NAME_HAS_CURR_INFO_REQUEST_REQ_RVW).val();

  let NV_DATA_SOURCE           = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_DATA_SOURCE, VALUE_DATA_SOURCE);
  let NV_CLIENT_ID             = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
  let NV_ACTIVE                = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);
  let NV_MISSING_INSURANCE     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_MISSING_INSURANCE_INFO, VALUE_MISSING_INSURANCE);
  let NV_MISSING_ADDRESS       = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_MISSING_ADDRESS_INFO, VALUE_MISSING_ADDRESS);
  let NV_MISSING_FERPA_CONSENT = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_MISSING_FERPA_CONSENT, VALUE_MISSING_FERPA_CONSENT);
  let NV_MISSING_PG_EMAILS     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_MISSING_PG_EMAILS, VALUE_MISSING_PG_EMAILS);
  let NV_HAS_CURR_INFO_RQST    = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_HAS_CURR_INFO_REQUEST, VALUE_HAS_CURR_INFO_RQST);
  let NV_HAS_CURR_INFO_RQST_RR = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_HAS_CURR_INFO_REQUEST_REQ_RVW, VALUE_HAS_CURR_INFO_RQST_RR);
  
  let NV_HAS_PREV_INFO_REQ_NO  = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_HAS_PREV_INFO_REQUEST, '0');
  let NV_HAS_PREV_INFO_REQ_YES = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_HAS_PREV_INFO_REQUEST, '1');

  /* Note: Don't use a loop here, keep it unrolled for performance reasons */

  /* Refresh the “Missing Info” rest view */

  $($restViewMissingInfoPats).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
  $($restViewMissingInfoPats).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);
  $($restViewMissingInfoPats).MBA_RestView('additionalParameterDefinitionForViewSet', NV_MISSING_INSURANCE);
  $($restViewMissingInfoPats).MBA_RestView('additionalParameterDefinitionForViewSet', NV_MISSING_ADDRESS);
  $($restViewMissingInfoPats).MBA_RestView('additionalParameterDefinitionForViewSet', NV_MISSING_FERPA_CONSENT);
  $($restViewMissingInfoPats).MBA_RestView('additionalParameterDefinitionForViewSet', NV_MISSING_PG_EMAILS);
  $($restViewMissingInfoPats).MBA_RestView('additionalParameterDefinitionForViewSet', NV_HAS_PREV_INFO_REQ_NO);
  $($restViewMissingInfoPats).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DATA_SOURCE);
  $($restViewMissingInfoPats).MBA_RestView('additionalParameterDefinitionForViewSet', NV_HAS_CURR_INFO_RQST);
  $($restViewMissingInfoPats).MBA_RestView('additionalParameterDefinitionForViewSet', NV_HAS_CURR_INFO_RQST_RR);
    
  $($restViewMissingInfoPats).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
  $($restViewMissingInfoPats).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_ACTIVE);

  $($restViewMissingInfoPats).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_CLIENT_ID);
  $($restViewMissingInfoPats).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_ACTIVE);

  $($restViewMissingInfoPats).MBA_RestView('requestViewFromServer', 1);

 
  /* Refresh the pats prev responses missing info requires review */

  $($restViewMissingInfoPatResponsesRequiringFollowup).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
  $($restViewMissingInfoPatResponsesRequiringFollowup).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);        
  $($restViewMissingInfoPatResponsesRequiringFollowup).MBA_RestView('additionalParameterDefinitionForViewSet', NV_HAS_PREV_INFO_REQ_YES);
  $($restViewMissingInfoPatResponsesRequiringFollowup).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DATA_SOURCE);

  $($restViewMissingInfoPatResponsesRequiringFollowup).MBA_RestView('requestViewFromServer', 1);

};

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

<%/***************************************************************************
   * createInfoRequest
   ** 
   **************************************************************************/%>

 function createInfoRequest (uiActionObj) {

        let _recIDsArr = $($restViewPatPersons).MBA_RestView('getMarkedRowsRecordIDs');

        if (_recIDsArr.length == 0) {
            return uiActionObj;
        };

        let _recIDsStr = _recIDsArr.join();

        let reqUrl = '<%=Spedmon.PatientInfoRequestsResponses.URL_SVC_SAVE_NEW_REQUEST_INLINE_BASE()%>';

        let reqData = {};

        reqData.clientid       = uiActionObj.whatFieldNameValues['clientID'];
        reqData.patid          = uiActionObj.whatFieldNameValues['patID'];
        reqData.msgtxt         = '';
        reqData.patperids      = _recIDsStr;
        reqData.sendemail      = 'Y';
        reqData.sendtext       = 'N';

        reqData = JSON.stringify(reqData);

        let $waitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner($diaBtnDoSendInfoRequest);
        MBA.ComponentCommon.fnDisableElement($diaBtnFixProblemsBtnDoCancel);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                MBA.ComponentCommon.fnEnableElement($diaBtnFixProblemsBtnDoCancel);
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($diaBtnDoSendInfoRequest, $waitingIcon);
                $($diaRequestInfoForPat).dialog("close");
                $($restViewMissingInfoPats).MBA_RestView('refreshCurrentViewFromServer');
            })
            .catch(responseData => {
                MBA.ComponentCommon.fnEnableElement($diaBtnFixProblemsBtnDoCancel);
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($diaBtnDoSendInfoRequest, $waitingIcon);
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Request Information', responseData.message, {});
            });
    };

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

<%/***************************************************************************
   * openDiaRequestInfoForPat
   ** 
   **************************************************************************/%>

function openDiaRequestInfoForPat (uiActionObj) {

  <%/* Get flags from row that indicate what is missing and convert to bool */%>

  let missingPGInfo        = MBA.ComponentCommon.fnFlagValueToTrueFalse(uiActionObj.whatFieldNameValues['missingPGEmails']);
  let missingAddressInfo   = MBA.ComponentCommon.fnFlagValueToTrueFalse(uiActionObj.whatFieldNameValues['missingAddressInfo']);
  let missingInsuranceInfo = MBA.ComponentCommon.fnFlagValueToTrueFalse(uiActionObj.whatFieldNameValues['missingInsuranceInfo']);
  let missingFerpaConsent  = MBA.ComponentCommon.fnFlagValueToTrueFalse(uiActionObj.whatFieldNameValues['missingFerpaConsent']);

  <%/* Get patient id from row */%>

  let patID = uiActionObj.whatFieldNameValues['patID'];

  <%/* Set patient id hidden input (note: we need this hidden input for the patient persons rest view to work */%>

  $($patid).val(patID);

  let diaOpts = {};

  diaOpts.resizable = false;

  diaOpts.close = function (event, ui) {
    $($diaRequestInfoForPat).hide();
    $(this).dialog('destroy');
  };

  MBA.PatientPersonsCommon.fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer($restViewPatPersons);

  MBA.ComponentCommon.fnCreateDialogFromElem($diaRequestInfoForPat, 90,90, diaOpts);
  MBA.ComponentCommon.fnEnableElement($diaBtnFixProblemsBtnDoCancel);

  $($diaFixProblemsRowMissingHomeAddress).hide();
  $($diaFixProblemsRowMissingInsuranceInfo).hide();
  $($diaBtnDoSendInfoRequest).hide();

  $($diaBtnDoSendInfoRequest).off('click');
  $($diaBtnFixProblemsBtnDoCancel).off('click');

  $($diaBtnFixProblemsBtnDoCancel).on('click', function (e) {
    $($diaRequestInfoForPat).dialog('close');
  });
     
  if ((missingInsuranceInfo === true) || (missingFerpaConsent === true)) {
    $($diaFixProblemsRowMissingInsuranceInfo).show();
    $($diaBtnDoSendInfoRequest).show();
    $($diaBtnDoSendInfoRequest).on('click', function (e) {
      createInfoRequest(uiActionObj);
    });
  }

  if (missingAddressInfo === true) $($diaFixProblemsRowMissingHomeAddress).show();

};

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

<%/***************************************************************************
   * completeReviewResponse
   ** 
   **************************************************************************/%>

function completeReviewResponse (uiActionObj) {

  let reqURL = '<%=Spedmon.PatientInfoRequestsResponses.URL_SVC_COMPLETE_REVIEW_RESPONSE_INLINE_BASE()%>';
  let reqData = {};

  reqData.clientid = uiActionObj.whatFieldNameValues['clientID'];
  reqData.recid    = uiActionObj.whatFieldNameValues['currentInfoRequestID'];       
  reqData = JSON.stringify(reqData);

  MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqData, null)
  .then(responseData => {
    $($restViewMissingInfoPats).MBA_RestView('refreshCurrentViewFromServer');
    $($restViewMissingInfoPatResponsesRequiringFollowup).MBA_RestView('refreshCurrentViewFromServer');
  })
  .catch(responseData => {
    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Complete Review', responseData.message, {});                
  });
  return uiActionObj;
}

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>    

<%/***************************************************************************
   * createPatientCellContent
   ** 
   **************************************************************************/%>

function createPatentCellContent (patID, patName, dob, studentID, grade, ssid) {

  let $cellContent = $('<div class="container-fluid"></div>');
  let $cellRow1 = $('<div class="row"></div>');

  let $cellRow2 = $('<div class="row m-0 p-0">'
                + '<div class="col-4 m-0 p-0"><small><u>DOB</u></small></div>'
                + '<div class="col-3 m-0 p-0"><small><u>Student ID</u></small></div>'
                + '<div class="col-2 m-0 p-0"><small><u>Grade</u></small></div>'
                + '<div class="col-3 m-0 p-0"><small><u>SSID</u></small></div>'
                + '</div>');

   let $cellRow3 = $('<div class="row m-0 p-0"></div>');

   let $editPatProf = $('<a href="#" class="mba-rest-view-drill-down" title="Click here to edit patient profile"><strong>' + patName + '</strong><i class="fa fa-pencil-alt fa-sm ml-1"></i></a>');

   $($editPatProf).on('click', function () {
       let reqUrl = '<%=urlEditPatient%>' + patID;
       return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
   });

   let $patName = $('<div class="col-12"></div>');
   $($patName).append($editPatProf);

   let $dob       = $('<div class="col-4 mt-0 p-0"><small>' + dob       + '</small></div>');
   let $studentID = $('<div class="col-3 mt-0 p-0"><small>' + studentID + '</small></div>');
   let $grade     = $('<div class="col-2 mt-0 p-0"><small>' + grade     + '</small></div>');
   let $ssid      = $('<div class="col-3 mt-0 p-0"><small>' + ssid      + '</small></div>');

   $($cellRow1).append($patName);
   $($cellRow3).append($dob);
   $($cellRow3).append($studentID);
   $($cellRow3).append($grade);
   $($cellRow3).append($ssid);

   $($cellContent).append($cellRow1);
   $($cellContent).append($cellRow2);
   $($cellContent).append($cellRow3);
   return $cellContent
};

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

 <%/***************************************************************************
    * createCurrRequestOrResponseStatusCellContent
    ** 
    **************************************************************************/%>

  function createCurrRequestOrResponseStatusCellContent (rowData) {

        let $cellContent = $('<div class="container-fluid"></div>');

        if (rowData.hasCurrentInfoRequest === false) {
            let $noRequestRow = $('<div class="row"><div class="col-12">No Requests</div></div>');
            $($cellContent).append($noRequestRow);            
            return $cellContent;
        }

        let $requestIDRow = $('<div class="row mb-2"><div class="col-12"><div class="d-flex justify-content-center"><small class="text-muted">Request ID : ' + rowData.currentInfoRequestID + '</small></div></div></div>');

        if ((rowData.currentInfoRequestRequestSent === true) && (rowData.currentInfoRequestResponseReceived === false)) {
            $($cellContent).append($requestIDRow);
            let $requestSentOnRow = $('<div class="row mb-2"><div class="col-12">Request Forms Sent On ' + rowData.currentInfoRequestSentOnStr + ' To </div></div>');
            $($cellContent).append($requestSentOnRow);
            let persons = JSON.parse(rowData.currentInfoRequestSentToJSON);
            persons.forEach((person) => {
                <%/* The following 2 lines are purely to guard against loading production pages in dev and test environments.*/%>
                let _requestURLObj = URL.parse(person.requestURL);
                let _requestURL = '<%=infoRequestFormBaseURL%>' + _requestURLObj.search;
                let $personRow = $('<div class="row"><div class="col-12"><a title="Open Request Form" target="_blank" href="' + _requestURL + '"><i class="fas fa-external-link-alt"></i><span class="mr-1">' + person.name + '</span></a></div></div>');
               $($cellContent).append($personRow);
            });
            return $cellContent;
        }

        if ((rowData.currentInfoRequestRequestSent === true) && (rowData.currentInfoRequestResponseReceived === true)) {

            let $responseReceivedOnRow = $('<div class="row mb-1"></div>');
            let $responseReceivedOnCol = $('<div class="col-8">Response Received On ' + rowData.currentInfoRequestResponseReceivedOnStr + '</div>');
            let $responseReviewClassCol = $('<div class="col-4"></div>');

            if (rowData.currentInfoRequestResponseNoInsuranceOptionSelected === true) {
                $($responseReviewClassCol).append($('<span class="badge badge-warning">No Insurance</span>'));
            }

            if (rowData.currentInfoRequestResponseOtherInsuranceOptionSelected === true) {
                $($responseReviewClassCol).append($('<span class="badge badge-info">Other Insurance</span>'));
            }

            if (rowData.currentInfoRequestResponseResponderConsent === false) {
                $($responseReviewClassCol).append($('<span class="badge badge-danger">No FERPA Consent</span>'));
            }

            $($responseReceivedOnRow).append($responseReceivedOnCol);
            $($responseReceivedOnRow).append($responseReviewClassCol);
                        
            let $responderRow    = $('<div class="row mb-1"><div class="col-4"><small>Response From</small></div><div class="col-4">' + rowData.currentInfoRequestResponseResponderName + '</div><div class="col-4"><img style="width:50px;height:50px;" src="' + rowData.currentInfoRequestResponseResponderSignatureImgData + '"></img></div></div>');
            let $consentRow      = $('<div class="row mb-1"><div class="col-8"><small>Consent To Use Insurance Info</small></div><div class="col-4">' + rowData.currentInfoRequestResponseResponderConsentStr + '</div></div></div>');
            let $policyHolderRow = $('<div class="row mb-1"><div class="col-4"><small>Policy Holder Name</small></div><div class="col-4">' + rowData.currentInfoRequestResponsePolicyHolderFirstName + '</div><div class="col-4">' + rowData.currentInfoRequestResponsePolicyHolderLastName +'</div></div>');
            let $policyNumberRow = $('<div class="row"><div class="col-4"><small>Policy & Group #</small></div><div class="col-4" title="Policy Number">' + rowData.currentInfoRequestResponsePolicyNumber + '</div><div class="col-4" title="Group Number">' + rowData.currentInfoRequestResponseGroupNumber + '</div></div>');
            let $carrierRow      = $('<div class="row"><div class="col-4"><small>Carrier Name</small></div><div class="col-8">' + rowData.currentInfoRequestResponseInsuranceCarrierName + rowData.currentInfoRequestResponseInsuranceCarrierOtherName + '</div></div>');

            $($cellContent).append($requestIDRow);
            $($cellContent).append($responseReceivedOnRow);
            $($cellContent).append($responderRow);
            $($cellContent).append($consentRow);
            $($cellContent).append($policyHolderRow);
            $($cellContent).append($policyNumberRow);
            $($cellContent).append($carrierRow);

            return $cellContent;
        }
        $cellContent = $('<div></div>');
        return $cellContent;
    };

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

<%/***************************************************************************
   * createPrevResponseStatusCellContent
   **
   **************************************************************************/%>

 function createPrevResponseStatusCellContent(rowData) {

        let $cellContent = $('<div class="container-fluid"></div>');

        let $responseReceivedOnRow = $('<div class="row mb-1"></div>');
        let $responseReceivedOnCol = $('<div class="col-8">Response Received On ' + rowData.prevInfoRequestResponseReceivedOnStr + '</div>');
        let $responseReviewClassCol = $('<div class="col-4"></div>');

        if (rowData.prevInfoRequestResponseNoInsuranceOptionSelected === true) {
          $($responseReviewClassCol).append($('<span class="badge badge-warning">No Insurance</span>'));
        }

        if (rowData.prevInfoRequestResponseOtherInsuranceOptionSelected === true) {
          $($responseReviewClassCol).append($('<span class="badge badge-info">Other Insurance</span>'));
        }

        if (rowData.prevInfoRequestResponseResponderConsent === false) {
          $($responseReviewClassCol).append($('<span class="badge badge-danger">No FERPA Consent</span>'));
        }

        $($responseReceivedOnRow).append($responseReceivedOnCol);
        $($responseReceivedOnRow).append($responseReviewClassCol);

        let $responderRow    = $('<div class="row"><div class="col-4"><small>Response From</small></div><div class="col-4">' + rowData.prevInfoRequestResponseResponderName + '</div><div class="col-4"><img style="width:50px;height:50px;" src="' + rowData.prevInfoRequestResponseResponderSignatureImgData + '"></img></div></div>');
        let $consentRow      = $('<div class="row"><div class="col-4"><small>Consent To Use Insurance Info</small></div><div class="col-8">' + rowData.prevInfoRequestResponseResponderConsentStr + '</div></div></div>');        
        let $policyHolderRow = $('<div class="row"><div class="col-4"><small>Policy Holder Name</small></div><div class="col-8">' + rowData.prevInfoRequestResponsePolicyHolderFirstName + ' ' + rowData.prevInfoRequestResponsePolicyHolderLastName + '</div></div>');
        let $policyNumberRow = $('<div class="row"><div class="col-4"><small>Policy & Group #</small></div><div class="col-4" title="Policy Number">' + rowData.prevInfoRequestResponsePolicyNumber + '</div><div class="col-4" title="Group Number">' + rowData.prevInfoRequestResponseGroupNumber + '</div></div>');
        let $carrierRow      = $('<div class="row"><div class="col-4"><small>Carrier Name</small></div><div class="col-8">' + rowData.prevInfoRequestResponseInsuranceCarrierName + rowData.prevInfoRequestResponseInsuranceCarrierOtherName +'</div></div>');

        $($cellContent).append($responseReceivedOnRow);
        $($cellContent).append($responderRow);
        $($cellContent).append($consentRow);
        $($cellContent).append($policyHolderRow);
        $($cellContent).append($policyNumberRow);
        $($cellContent).append($carrierRow);

        return $cellContent;
        
    };

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

<%/***************************************************************************
   * initCommonRestViewFieldDefOpts
   **
   **************************************************************************/%>

function initCommonRestViewFieldDefOpts(opts, includeCurrentInfoRequestResponseStatusDetails) {

  opts.sessionTimeOutUrl  = '<%=MBA.Credential.generateSessionExpiredLink()%>';
  opts.requestViewOnLoad  = false;
  opts.enableSortControls = true;
  opts.enableRowNumbers   = false;
  opts.enableRowControls  = true;      
  opts.enableRowControlRecAddNew = false;
  opts.enableRowControlRecEdit   = false;
  opts.enableRowControlRecDelete = false;

  opts.loadModeView              = 'rest';
  opts.baseUrlView               = '<%=Spedmon.PatientsWithMissingInfo.URL_REST_VIEW_BASE()%>';
  opts.baseUrlViewHasParameters  = true;
  opts.defaultPageRowOrder       = '<%=Spedmon.PatientWithMissingInfo.DEFAULT_PAGING_ORDER%>';

  opts.enableReports    = true;
  opts.enableReportHtml = true;
  opts.enableReportXls  = true;
  opts.enableReportPdf  = false;

  opts.loadModeReport             = 'mbawebreport';
  opts.baseUrlReport              = '<%=Spedmon.PatientsWithMissingInfo.URL_WEB_REPORT_BASE()%>';
  opts.baseUrlReportHasParameters = true;
  opts.fieldDefinitions           = [];

     opts.fieldDefinitions.push({
            name: 'clientID'
          , label: 'clientID'
          , toolTip: ''
          , visible: false
          , editable: false
          , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'clientid'
        });

        opts.fieldDefinitions.push({
            name: 'patID'
            , label: 'Patient ID'
            , toolTip: ''
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , dataType: 'hidden'
            , saveUsing: 'patid'
        });

        opts.fieldDefinitions.push({
            name: 'missingPGEmails'
            , label: ''
            , toolTip: ''
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , dataType: 'hidden'
            , saveUsing: 'missingPGEmails'
        });

        opts.fieldDefinitions.push({
            name: 'missingAddressInfo'
            , label: ''
            , toolTip: ''
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , dataType: 'hidden'
            , saveUsing: 'missingAddressInfo'
        });

        opts.fieldDefinitions.push({
            name: 'missingInsuranceInfo'
            , label: ''
            , toolTip: ''
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , dataType: 'hidden'
            , saveUsing: 'missingInsuranceInfo'
        });

        opts.fieldDefinitions.push({
            name: 'missingFerpaConsent'
            , label: ''
            , toolTip: ''
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , dataType: 'hidden'
            , saveUsing: 'missingFerpaConsent'
        });

        opts.fieldDefinitions.push({
            name: 'currentInfoRequestID'
            , label: 'Current Info Request ID'
            , toolTip: 'Current Info Request ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , dataType: 'hidden'
            , saveUsing: 'currentinforequestid'
        });

        opts.fieldDefinitions.push({
            name: 'patSummary'
            , label: 'Student'
            , toolTip: 'Student name, date of birth, student id, grade'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , dataType: 'emptydiv'
            , sortUsing: 'patName'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'siteName'
            , label: 'Site'
            , toolTip: 'School Site'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , dataType: 'text'
            , sortUsing: 'siteName'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'numSvcRecs'
            , label: 'Number of<br>Services'
            , toolTip: 'Number of services documented in SpEdCare'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , dataType: 'text'
            , sortUsing: 'numSvcRecs'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'missingPGEmailsStr'
            , label: 'Missing<br>Parent/Guardian<br>Info or Emails?'
            , toolTip: 'Missing or incomplete (missing emails) parent/guardian records for this student'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , dataType: 'text'
            , sortUsing: 'missingPGEmails'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'missingAddressInfoStr'
            , label: 'Missing<br>Address<br>Info?'
            , toolTip: 'Missing or incomplete home address records for this student in SpEdCare'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , dataType: 'text'
            , sortUsing: 'missingAddressInfo'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'missingInsuranceInfoStr'
            , label: 'Missing<br>Insurance<br>Info?'
            , toolTip: 'Missing or incomplete insurance records for this student in SpEdCare'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , dataType: 'text'
            , sortUsing: 'missingInsuranceInfo'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'missingFerpaConsentStr'
            , label: 'Missing<br>FERPA<br>Consent?'
            , toolTip: 'There is no FERPA consent for this student in SpEdCare'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , dataType: 'text'
            , sortUsing: 'missingFerpaConsent'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });
        
        <%if (canAccessPatientInfoRequestResponseSystem) {%>
        if (includeCurrentInfoRequestResponseStatusDetails == true) {
             opts.fieldDefinitions.push({
                name: 'currentInfoRequestResponseStatusDetails'
              , label: 'Request or Response Status'
              , toolTip: 'Current status of the request or response'
              , visible: true
              , editable: false
              , saveable: false
              , sortable: false
              , dataType: 'emptydiv'
              , additionalCssClassesForCol: 'text-left'
              , additionalCssClassesForColTop: 'text-center'
              , additionalCssClassesForColLabel: 'text-center'
              , additionalCssClassesForCell: 'text-left'
              , additionalCssClassesForCellValue: 'text-left'
          });
        }
        <%}%>

      return opts;
  };

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

  <%/***************************************************************************
     * initMissingInfoPatsRestView
     **
     ***************************************************************************/%>

  function initMissingInfoPatsRestView() {

        let opts = {};             
        opts = initCommonRestViewFieldDefOpts(opts,true);
        opts.defaultReportNumber = '<%=Spedmon.PatientsWithMissingInfoViw.REPT_NUM_VIEW_DEFAULT%>';

     <%/*###############################################################################################
         #
         #                             Additional Body Row Controls
         #
         ###############################################################################################*/%>

      <%if (canAccessPatientInfoRequestResponseSystem) {%>

      opts.additionalControlDefinitionsForBodyRows = new Map();

      opts.additionalControlDefinitionsForBodyRows.set('createPatInfoRequest', {
          defType: 'userprovided',
          name: 'createPatInfoRequest',
          toolTip: 'Fix Problems',
          cssClass: 'fas fa-wrench',
          handlerFn: function (uiActionObj) {
              openDiaRequestInfoForPat(uiActionObj);
              return uiActionObj;
          },
          initiallyHidden: false
      });

      opts.additionalControlDefinitionsForBodyRows.set('cancelPatInfoRequest', {
            defType: 'userprovided',
            name: 'cancelPatInfoRequest',
            toolTip: 'Cancel Request',
            cssClass: 'fas fa-trash-alt',
            handlerFn: function (uiActionObj) {
                let reqURL = '<%=Spedmon.PatientInfoRequestsResponses.URL_SVC_CANCEL_REQUEST_INLINE_BASE()%>';
                let reqData = {};

                reqData.clientid = uiActionObj.whatFieldNameValues['clientID'];
                reqData.recid = uiActionObj.whatFieldNameValues['currentInfoRequestID'];
                reqData = JSON.stringify(reqData);

                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqData, null)
                    .then(responseData => {
                        $($restViewMissingInfoPats).MBA_RestView('refreshCurrentViewFromServer');
                    })
                    .catch(responseData => {
                        MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Cancel Request', responseData.message, {});                        
                    });
                return uiActionObj;
            },
            initiallyHidden: false
        });

        opts.additionalControlDefinitionsForBodyRows.set('responseReviewed', {
            defType: 'userprovided',
            name: 'responseReviewed',
            toolTip: 'Mark As Reviewed',
            cssClass: 'fas fa-thumbs-up',
            handlerFn: function (uiActionObj) {
                return completeReviewResponse(uiActionObj);
            },
            initiallyHidden: false
        });
        <%}%>

     <%/*###############################################################################################
         #
         #                             Create New Cell After Hook
         #
         ###############################################################################################*/%>

        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) {
            if (fieldDefinition.name === 'patSummary') {                                               
                $(newCellValueElem).append(createPatentCellContent(rowData.patID,rowData.patName, rowData.dobStr, rowData.studentID, rowData.grade, rowData.ssid));
            }
            <%if (canAccessPatientInfoRequestResponseSystem) {%>
            else if (fieldDefinition.name === 'currentInfoRequestResponseStatusDetails')
            {
                $(newCellValueElem).append(createCurrRequestOrResponseStatusCellContent(rowData));
            }
            <%}%>
            /* Return cell new as required */

            return newCell;
        };

     <%/*###############################################################################################
         #
         #                             Create New Row After Hook
         #
         ###############################################################################################*/%>

        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            <%if (canAccessPatientInfoRequestResponseSystem) {%>
            if ((subsection === 103) && (rowtype === 4)) {

                let $butCreateRequest        = MBA.RestViewCommon.fnFindRowControl($newRow, 'createPatInfoRequest');
                let $butOpenRequestForm      = MBA.RestViewCommon.fnFindRowControl($newRow, 'openPatInfoRequestForm');
                let $butCancelRequest        = MBA.RestViewCommon.fnFindRowControl($newRow, 'cancelPatInfoRequest');                                
                let $butMarkResponseReviewed = MBA.RestViewCommon.fnFindRowControl($newRow, 'responseReviewed');

                if (rowData.hasCurrentInfoRequest === false) {
                    /* Just show create request */
                    $($butOpenRequestForm).remove();
                    $($butCancelRequest).remove();
                    $($butMarkResponseReviewed).remove();
                }
                else {
                    /* Remove create request */
                    $($butCreateRequest).remove();

                    /* Show only appprove or decline*/

                    if (rowData.currentInfoRequestResponseReceived === true) {
                        $($butOpenRequestForm).remove();
                        $($butCancelRequest).remove();
                    }

                    /* Show only open request or cancel request */

                    else {
                        $($butMarkResponseReviewed).remove();                        
                    }
                }

            };
            <%}%>
            return $newRow;
        };

        $($restViewMissingInfoPats).MBA_RestView(opts);

      
    };

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

<%/***************************************************************************
   * initMissingInfoPatResponsesRequiringFollowupRestView
   **
   ***************************************************************************/%>

  function initMissingInfoPatResponsesRequiringFollowupRestView() {

        let opts = {};

        opts = initCommonRestViewFieldDefOpts(opts, false);

        opts.defaultReportNumber        = '<%=Spedmon.PatientsWithMissingInfoViw.REPT_NUM_VIEW_PATS_NEEDING_POSSIBLE_FOLLOWUP%>';

      
        opts.fieldDefinitions.push({
            name: 'prevInfoRequestResponseStatusDetails'
            , label: 'Request or Response Status'
            , toolTip: 'Response data'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , dataType: 'emptydiv'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

     <%/*###############################################################################################
         #
         #                             Create New Cell After Hook
         #
         ###############################################################################################*/%>

        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) {
            if (fieldDefinition.name === 'patSummary') {                                               
                $(newCellValueElem).append(createPatentCellContent(rowData.patID,rowData.patName, rowData.dobStr, rowData.studentID, rowData.grade, rowData.ssid));
            }

            else if (fieldDefinition.name === 'prevInfoRequestResponseStatusDetails') {
                $(newCellValueElem).append(createPrevResponseStatusCellContent(rowData));
            }

            /* Return cell new as required */

            return newCell;
        };

        $($restViewMissingInfoPatResponsesRequiringFollowup).MBA_RestView(opts);
        
    };

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function openRequestFormOptions() {
        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        const manageOptionsUrlBase = '<%=Spedmon.PatientInfoRequestOptionsCommon.URL_REQUEST_FORM_OPTIONS_MANAGE("") %>';
        MBA.ComponentCommon.fnOpenWindow(
            manageOptionsUrlBase + encodeURIComponent(VALUE_CLIENT_ID),
            'managestudentinforequestoption'
        );
    };

<%/*-----------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    $(window).on('load', function () {

        $dataManagementRows                               = $('#dataManagementRows');
        $restViewMissingInfoPats                          = $('#restview-missing-info-pats');
        $restViewMissingInfoPatResponsesRequiringFollowup = $('#restview-missing-info-pats-responses-requiring-followup');

        $diaRequestInfoForPat                   = $('#diaRequestInfoForPat')
        $diaContentBulkRequestInfoForPats       = $('#diaContentBulkRequestInfoForPats')
        $diaContentBulkCancelRequestInfoForPats = $('#diaContentBulkCancelRequestInfoForPats');

        $patid = $('#patid');

        $diaFixProblemsRowMissingHomeAddress   = $('#dia-fix-problems-row-missing-home-address');
        $diaFixProblemsRowMissingInsuranceInfo = $('#dia-fix-problems-row-missing-insurance-info')
        $diaBtnDoSendInfoRequest               = $('#dia-btn-do-send-info-request');
        $diaBtnFixProblemsBtnDoCancel          = $('#dia-fix-problems-btn-do-cancel');

        //$("#tabs").tabs().addClass('data-entry-row-tabs');
        $("#tabs").MBA_Tabs({});

        $($diaRequestInfoForPat).hide();
        $($diaContentBulkRequestInfoForPats).hide();
        $($diaContentBulkCancelRequestInfoForPats).hide();

        $($patid).val('');

        $restViewPatPersons = initPatientPersonsView('datamanagerowsrestviewpatientpersons', 'restviewpatientpersons');

        initMissingInfoPatsRestView();
        initMissingInfoPatResponsesRequiringFollowupRestView();

        $dataManagementRows.on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        <%/* Goto a specific tab specified by query string parameter if needed */
        if (!String.IsNullOrWhiteSpace(tabToOpen)) {%>
        $('a[href="#<%=tabToOpen%>"]').click();
        <%}%>

        /* Do one initial refresh on page load if the client id is available . */

        let _cid = $('#' + PARM_NAME_CLIENT_ID).val();
        if (!_cid) return;
        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

    });
</script>