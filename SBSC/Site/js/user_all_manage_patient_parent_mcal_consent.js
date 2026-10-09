/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const FILTER_VALUE_ALL              = '1';
const FILTER_VALUE_HELD_CLAIMS      = '2';
const FILTER_VALUE_NO_CONSENT       = '3';
const FILTER_VALUE_UNKNOWN_CONSENT  = '4';
const PARM_NAME_CLIENT_ID           = 'clientid';
const PARM_NAME_PAT_ID              = 'patid';
const PARM_NAME_PARENT_CONSENT      = 'parentconsent';
const PARM_NAME_HAS_UNKNOWN_CONSENT = 'hasunknownconsent';
const PARM_NAME_HAS_HELD_CLAIMS     = 'hasheldclaims';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let $dataManagementRows;                   
let $restViewPatientParentMcalConsentsCtrl;

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let clientConsentTextGetBaseUrl;
let clientConsentTextSetBaseUrl;
let viewConsentBaseUrl;   
let updateConsentBaseUrl; 
let requestAuthBaseUrl;
let reportBaseUrl;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let getClientIDRef      = function () { return $('#clientid'); }
let getClientIDVal      = function () { return $(getClientIDRef()).val(); }
let getPatIDRef         = function () { return $('#patid'); }
let getPatIDVal         = function () { return $(getPatIDRef()).val(); }
let getFilterOptionsRef = function () { return $('#filterOptions');}
let getFilterOptionsVal = function () { return $(getFilterOptionsRef()).val(); }
let setFilterOptionsVal = function (value) { return $(getFilterOptionsRef).val(value); }
let getMsgTextRef       = function () { return $('#msgtext'); }
let getMsgTextVal       = function () { return $(getMsgTextRef()).val();}
let setMsgTextVal       = function (value) { $(getMsgTextRef()).val(value); }

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let previousClientID  = ''
let previousPatientID = '';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function getClientParentConsentMcalText(fnReturn) {

    var $data = '{"' + PARM_NAME_CLIENT_ID + '":' + getClientIDVal() + '}';

    var returnData = null;

    var fnProcResp = function (rd) {
        returnData = rd.data;
    };

    var fnProcComplete = function () {
        if (returnData) {
          setMsgTextVal(returnData.value);
          fnReturn(returnData);
        }
    };

    $.spedmonWebUI.ajax(null, clientConsentTextGetBaseUrl, $data, null, null, fnProcResp, null, null, 0, null, fnProcComplete, null);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function setClientParentConsentMcalText(fnReturn) {

    var $data = '{'
        + '"' + PARM_NAME_CLIENT_ID + '":' + getClientIDVal()
        + ',"msgtext":"' + getMsgTextVal() + '"'
        + '}';

    var returnData = null;
    var fnProcResp = function (rd) { returnData = rd.data; };
    var fnProcComplete = function () {
      if (returnData) {
          fnReturn(returnData);
      }
    };

    $.spedmonWebUI.ajax(null, clientConsentTextSetBaseUrl, $data, null, null, fnProcResp, null, null, 0, null, fnProcComplete, null);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function doManageConsentText() {
  let cid = getClientIDVal();
  if (!cid) return;
  let fnReturn = function (returnData) {
    $('#diaManageClientConsentText').dialog('open');
  }
  getClientParentConsentMcalText(fnReturn);
  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

  let VALUE_CLIENT_ID           = getClientIDVal();
  let VALUE_PATIENT_ID          = getPatIDVal();
  let VALUE_FILTER_OPTION       = getFilterOptionsVal();

  let VALUE_PARENT_CONSENT      = '';
  let VALUE_HAS_UNKNOWN_CONSENT = '1';
  let VALUE_HAS_HELD_CLAIMS     = ''; 

  if      (VALUE_FILTER_OPTION === FILTER_VALUE_ALL )            { VALUE_PARENT_CONSENT = '';  VALUE_HAS_UNKNOWN_CONSENT = '';  VALUE_HAS_HELD_CLAIMS = '';}
  else if (VALUE_FILTER_OPTION === FILTER_VALUE_HELD_CLAIMS)     { VALUE_PARENT_CONSENT = '';  VALUE_HAS_UNKNOWN_CONSENT = '';  VALUE_HAS_HELD_CLAIMS = '1'; } 
  else if (VALUE_FILTER_OPTION === FILTER_VALUE_NO_CONSENT)      { VALUE_PARENT_CONSENT = '0'; VALUE_HAS_UNKNOWN_CONSENT = '';  VALUE_HAS_HELD_CLAIMS = ''; }
  else if (VALUE_FILTER_OPTION === FILTER_VALUE_UNKNOWN_CONSENT) { VALUE_PARENT_CONSENT = '';  VALUE_HAS_UNKNOWN_CONSENT = '1'; VALUE_HAS_HELD_CLAIMS = ''; } 
  else    {}

  let NV_CLIENT_ID           = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID,           VALUE_CLIENT_ID);
  let NV_PATIENT_ID          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID,              VALUE_PATIENT_ID);
  let NV_PARENT_CONSENT      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PARENT_CONSENT,      VALUE_PARENT_CONSENT);
  let NV_HAS_UNKNOWN_CONSENT = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_HAS_UNKNOWN_CONSENT, VALUE_HAS_UNKNOWN_CONSENT);
  let NV_HAS_HELD_CLAIMS     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_HAS_HELD_CLAIMS,     VALUE_HAS_HELD_CLAIMS);

  /* Note: Don't use a loop here, keep it unrolled for performance reasons */

  $($restViewPatientParentMcalConsentsCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
  $($restViewPatientParentMcalConsentsCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PATIENT_ID);
  $($restViewPatientParentMcalConsentsCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PARENT_CONSENT);
  $($restViewPatientParentMcalConsentsCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_HAS_UNKNOWN_CONSENT);
  $($restViewPatientParentMcalConsentsCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_HAS_HELD_CLAIMS);

  $($restViewPatientParentMcalConsentsCtrl).MBA_RestView('requestViewFromServer', 1);

};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initView(includeMessaing, userClientID, sendMessageAjaxURL, recipientSrcURL) {

    let opts = {};
    opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */
    opts.enableSortControls        = true;
    opts.enableRowNumbers          = true;
    opts.enableRowControls         = true;
    opts.enableRowControlRecAddNew = false;
    opts.enableRowControlRecEdit   = true;
    opts.enableRowControlRecDelete = false;

    opts.baseUrlView              = viewConsentBaseUrl;
    opts.baseUrlViewHasParameters = true;
    opts.defaultPageRowOrder      = 'PATIENT_NAME asc';

    opts.saveModeEdit             = 'inline';
    opts.baseUrlEdit              = updateConsentBaseUrl;
    opts.enableReports = true;

    opts.enableReportHtml = true;
    opts.enableReportXls = true;
    opts.enableReportPdf = false;
    opts.loadModeReport = 'mbawebreport';
    opts.baseUrlReport = reportBaseUrl;
    opts.baseUrlReportHasParameters = true;
    opts.defaultReportNumber = '1';

    opts.fieldDefinitions = [];

    opts.fieldDefinitions.push({
          name: 'ID'
        , isRecID: true
    });

    opts.fieldDefinitions.push({
          name: 'CLIENT_ID'
        , label: 'Client ID'
        , toolTip:''
        , visible: false
        , editable: false
        , saveable: true
        , sortable: false
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'clientid'
        , showMore: false
    });

    opts.fieldDefinitions.push({
          name: 'PATIENT_ID'
        , label: 'Patient ID'
        , toolTip: ''
        , visible: false
        , editable: false
        , saveable: true
        , sortable: false
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'patid'
        , showMore: false
    });

    opts.fieldDefinitions.push({
          name: 'PATIENT_NAME'
        , label: 'Patient<br>Last, First'
        , toolTip: 'Last, First Name'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'lastfirst'
        , sortUsing: 'PATIENT_NAME'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
          name: 'DATE_OF_BIRTH_STR'
        , label: 'Date<br>of Birth'
        , toolTip: 'Date of Birth'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'date'
        , saveUsing: ''
        , sortUsing: 'DATE_OF_BIRTH_VAL'
    });

    opts.fieldDefinitions.push({
        name: 'PATIENT_STUDENT_ID'
        , label: 'Student ID'
        , toolTip: 'Patients current student id according to our records'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'PATIENT_STUDENT_ID'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'PATIENT_CSIS'
        , label: 'CSIS'
        , toolTip: 'Patients current California School Information Services ID according to our records'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'PATIENT_CSIS'
        , saveUsing: ''
        , showMore: false
    });
    opts.fieldDefinitions.push({
        name: 'PATIENT_SITE_NAME'
        , label: 'School<br>Site'
        , toolTip: 'Patients current school site according to our records'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'PATIENT_SITE_NAME'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
          name: 'CURRENT_CONSENT_STATUS_STR'
        , label: 'Parental<br>Consent'
        , toolTip: 'Current Parental Consent for Medi-Cal Billing'
        , visible: true
        , editable: true
        , saveable: true
        , sortable: true
        , isRecID: false
        , dataType: 'yesnounknown'
        , sortUsing: 'CURRENT_CONSENT_STATUS_VAL'
        , saveUsing: 'consentbool'
        , showMore: false
    });

    opts.fieldDefinitions.push({
          name: 'CURRENT_CONSENT_STATUS_EFF_DATE_STR_YYYY_MM_DD'
        , label: 'Effective<br>Date'
        , toolTip: 'Effective Date For Parental Consent'
        , visible: true
        , editable: true
        , saveable: true
        , sortable: false
        , isRecID: false
        , dataType: 'date'
        , saveUsing: 'effdate'
        , sortUsing: 'CURRENT_CONSENT_STATUS_EFF_DATE_VAL'
    });

    opts.fieldDefinitions.push({
        name: 'CURRENT_CONSENT_STATUS_NOTES'
        , label: 'Notes'
        , toolTip: 'Please enter any notes related to parent consent for this patient'
        , visible: true
        , editable: true
        , saveable: true
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , saveUsing: 'notes'
        , sortUsing: 'CURRENT_CONSENT_STATUS_NOTES'
    });

    opts.fieldDefinitions.push({
        name: 'CASE_MANAGER'
        , label: 'Case Manager'
        , toolTip: 'Name of the case manager'
        , visible: true
        , editable: true
        , saveable: true
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'CASE_MANAGER'
        , saveUsing: 'casemanager'
        , showMore: false
    });



    opts.fieldDefinitions.push({
          name: 'HELD_CLAIMS_TOTAL_EST_REIMBURSE_AMOUNT_STR'
        , label: 'Potential Lost<br>Reimbursement'
        , toolTip: 'Potential Lost Reimbursement Amount in USD'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'usd'
        , saveUsing: ''
        , sortUsing: 'HELD_CLAIMS_TOTAL_EST_REIMBURSE_AMOUNT_VAL'
    });

    /* Setup addtional parameters for view */

    opts.additionalParameterDefinitionsForView = new Map();
    opts.additionalParameterDefinitionsForView.set(PARM_NAME_CLIENT_ID,           '');
    opts.additionalParameterDefinitionsForView.set(PARM_NAME_PAT_ID,              '');
    opts.additionalParameterDefinitionsForView.set(PARM_NAME_PARENT_CONSENT,      '');
    opts.additionalParameterDefinitionsForView.set(PARM_NAME_HAS_UNKNOWN_CONSENT, '');
    opts.additionalParameterDefinitionsForView.set(PARM_NAME_HAS_HELD_CLAIMS,     '1');

    /* Setup additional row controls */

    opts.additionalControlDefinitionsForBodyRows = new Map();

    /* Request authorization for MCAL billing */

    opts.additionalControlDefinitionsForBodyRows.set('requestparentauth', {
          defType: 'userprovided'
        , name: 'requestparentauth'
        , toolTip: 'Click Here to Request Parental Consent for Medi-Cal Billing'
        , cssClass: 'fa fa-user-md'
        , handlerFn: function (uiActionObj) {
            let pid = uiActionObj.recordID;
            let reqSvcAuthUrl = requestAuthBaseUrl + pid;
            let newWindowName = 'req-consent-' + pid;
            let newWindow = MBA.RestViewCommon.fnOpenWindow(uiActionObj.elem, reqSvcAuthUrl, newWindowName, false);
            uiActionObj.newWindow = newWindow;
            return uiActionObj;
        }
        , initiallyHidden: false
    });

    if (includeMessaing) {
        /* Messaging */
        opts.additionalControlDefinitionsForBodyRows.set('messaging', {
            defType: 'userprovided'
            , name: 'messaging'
            , toolTip: 'Send a Message'
            , cssClass: 'fas fa-comment mba-messages-widget-class'
            , handlerFn: function (uiActionObj) {
                // no need to do anything here as the messaging constructor will take care of messages
                return uiActionObj;
            }
            , initiallyHidden: false
        });
    }

    /*###############################################################################################
      #
      #                                  Row hooks
      #
      ################################################################################################*/
 
    
    if (includeMessaing) {
        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            /* Call the messaging js constructor on the messaging icon to add messaging functionality */
            let _messageIcon = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="messaging"] > i.fa-comment')[0];
            if (_messageIcon) {            
                let _msgOpts = {
                      'clientID'            : userClientID
                    , 'sendMessageAjaxURL'  : sendMessageAjaxURL
                    , 'recipientSrcURL'     : recipientSrcURL
                    , 'replyModeOn'         : false
                    , 'allowDelete'         : false
                    , 'viewModeSubject'     : 'Parent Consent Needed For ' 
                                              + ((rowData.PATIENT_NAME)      ? rowData.PATIENT_NAME      + ' ' : '')
                                              + ((rowData.DATE_OF_BIRTH_STR) ? rowData.DATE_OF_BIRTH_STR       : '')
                };

                $(_messageIcon).messagesWidget(_msgOpts);
            }
            return $newRow;
        };
    }

    /* Create the rest view */

    $($restViewPatientParentMcalConsentsCtrl).MBA_RestView(opts);
    
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initDialogs() {  

    $('#diaManageClientConsentText').dialog({
        resizable: true
        , width: 400
        , height: 400
        , modal: true
        , autoOpen: false
        , buttons: {
            'Cancel': function () {
                $(this).dialog('close');
            }
            , 'Save & Proceed': function () {
                let dr = $(this); /* Reference to this dialog */
                setClientParentConsentMcalText(function (rd) { $(dr).dialog('close'); });
            }

        }
    });
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function init(clientID, sendMessageAjaxURL, recipientSrcURL) {
  let previousClientID  = getClientIDVal();
  let previousPatientID = getPatIDVal();

  initDialogs();
  initView(true, clientID, sendMessageAjaxURL, recipientSrcURL);
  $($dataManagementRows).on('spedmoninputdata', function (e) {
    updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
  });
  updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

}