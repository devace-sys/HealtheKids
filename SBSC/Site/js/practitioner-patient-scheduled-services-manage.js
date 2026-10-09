;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PractitionerPatientScheduledServicesManageCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common 
 */

MBA.PractitionerPatientScheduledServicesManageCommon = (function ($)
{

'use strict';


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _THIS_NAME           = 'Practitioner Patient Scheduled Services Manage Common Methods';
const _THIS_NS             = 'mba-practitioner-patient-scheduled-services-manage'
const _JQ_DATA_NAME        = 'jq-'   + _THIS_NS;
const _DATA_ATTR_BASE      = 'data-' + _THIS_NS;  

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS  = {
    PARM_NAME_CLIENT_ID : ''
  , PARM_NAME_PRACTITIONER_ID:''
  , PARM_NAME_PATIENT_ID:''
  , PARM_NAME_ACTIVE:''
  , PARM_NAME_REC_ID:''
  , PARM_NAME_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID:''
  , containerCtrlID     : ''
  , sessionTimeOutUrl   : ''
  , baseUrlView         : ''
  , defaultPageRowOrder : ''
  , baseUrlAddNew       : ''
  , baseUrlEdit         : ''
  , baseUrlDelete       : ''
  , defaultReportNumber :'1'
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetMe
 * @private
 * @summary      Gets reference to original elemementid
 * @description  Gets reference to original elemementid
 * @param  {Object}  elem  Element reference
 */

let _fnGetMe = function (elementid) { 
  return $('#' + elementid); 
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetDataObj
 * @private
 * @summary      Gets reference to data object
 * @description  Gets reference to the jQuery data object associated with this element
 * @param  {Object}  $me  Element reference
 */
 
let _fnGetDataObj = function ($me)  { 
  let dataObj = $($me).data(_JQ_DATA_NAME);
  if (!dataObj) throw new Error('An instance of ' + _THIS_NAME +' is required');
  return dataObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSetDataObj
 * @private
 * @summary      Sets value of data object
 * @description  Sets value of data object
 * @param  {Object}  $me      Element reference
 * @param  {Object}  dataObj  Data obj for this lib
 */

let _fnSetDataObj = function ($me, dataObj) {
  $($me).data(_JQ_DATA_NAME, dataObj);
  return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _createRestView = function ($me, optsIn) 
{
   
  let opts = {};

  opts.sessionTimeOutUrl         = optsIn.sessionTimeOutUrl;
  opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */
  opts.enableSortControls        = true;
  opts.enableRowNumbers          = true; /* Turn on row numbers */
  opts.enableRowControls         = true;
  opts.enableRowControlRecAddNew = true;
  opts.enableRowControlRecEdit   = true;
  opts.enableRowControlRecDelete = true;

  opts.loadModeView               = 'rest';
  opts.baseUrlView                = optsIn.baseUrlView;
  opts.baseUrlViewHasParameters   = true;
  opts.defaultPageRowOrder        = optsIn.defaultPageRowOrder;

  opts.saveModeAddNew             = 'inwindow';
  opts.baseUrlAddNew              = optsIn.baseUrlAddNew;
  opts.baseUrlAddNewHasParameters = true;

  opts.saveModeEdit               = 'inwindow';
  opts.baseUrlEdit                = optsIn.baseUrlEdit;
  opts.baseUrlEditHasParameters   = true;

  opts.saveModeDelete             = 'inline';
  opts.baseUrlDelete              = optsIn.baseUrlDelete;
  opts.baseUrlDeleteHasParameters = true;

  opts.enableReports              = true;
  opts.enableReportHtml           = true;
  opts.enableReportXls            = true;
  opts.enableReportPdf            = false;
  opts.loadModeReport             = 'mbawebreport';
  opts.baseUrlReport              = optsIn.baseUrlReport;
  opts.defaultReportNumber        = optsIn.defaultReportNumber;
  opts.baseUrlReportHasParameters = true;  

  opts.fieldDefinitions = [];
  
  opts.additionalControlDefinitionsForBodyRows = new Map();


  opts.fieldDefinitions.push({
      name: 'id'
    , isRecID: true
    , editable: false
    , saveable: true
    , saveUsing:'recid'
  });


  opts.fieldDefinitions.push({
       name: 'practitionerPatientCaseloadExpectedServiceID'
      , visible: false
      , sortable: false
      , saveable: true
      , editable: false
      , isRecID: false
      , dataType: 'hidden'
      , sortUsing: ''
      , saveUsing: 'practitionerpatientcaseloadexpectedserviceid'
      , showMore: false  });


  opts.fieldDefinitions.push({
      name: 'clientID'
    , visible: false
    , sortable: false
    , saveable: true
    , editable: false
    , isRecID: false
    , dataType: 'hidden'
    , sortUsing: ''
    , saveUsing:'clientid'
    , showMore: false
  });


  opts.fieldDefinitions.push({
        name: 'pracID'
        , visible: false
        , sortable: false
        , saveable: true
        , editable: false
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'pracid'
        , showMore: false
    });
    

    opts.fieldDefinitions.push({
          name: 'patID'
        , visible: false
        , sortable: false
        , saveable:true
        , editable: false
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'patid'
        , showMore: false
    }); 
        

    opts.fieldDefinitions.push({
        name: 'patName'
        , label: 'Student<br>Last, First'
        , toolTip:'Patient who receives the service'
        , visible: true
        , sortable: true
        , saveable: false
        , editable: false
        , isRecID: false
        , dataType: 'lastfirst'
        , sortUsing: 'patName'        
        , showMore: false
    });


    opts.fieldDefinitions.push({
        name: 'startDateStr'
        , label: 'Start<br>Date'
        , toolTip: 'What date does this service start?'
        , visible: true
        , sortable: true
        , editable: false
        , saveable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'startDate'
        , showMore: false
    });


    opts.fieldDefinitions.push({
        name: 'endDateStr'
        , label: 'End<br>Date'
        , toolTip: 'What date does this service end?'
        , visible: true
        , sortable: true
        , editable: false
        , saveable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'endDate'
        , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'dateRangeBeforeInOrAfterRefDateName'
        , label: 'Dates Are'
        , toolTip: 'Are the dates in the past, present, or future'
        , visible: true
        , sortable: true
        , editable: false
        , saveable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'dateRangeBeforeInOrAfterRefDateName'
        , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'scheduleHasExpiredStr'
        , label: 'Schedule<br>Expired?'
        , toolTip: 'Has the schedule expired?'
        , visible: true
        , sortable: true
        , editable: false
        , saveable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'scheduleHasExpired'
        , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'svcNamesListDataSourceName'
        , label: 'Plan<br>Type'
        , toolTip: 'The type of plan'
        , visible: true
        , sortable: true
        , editable: false
        , saveable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'svcNamesListDataSourceName'
        , showMore: false
    });


    opts.fieldDefinitions.push({
          name: 'svcName'
        , label: 'Service'
        , toolTip: 'The service that will be provided'
        , visible: true
        , sortable: true
        , editable: false
        , saveable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'svcName'
        , showMore: false
    });
      

    opts.fieldDefinitions.push({
        name: 'numMins'
        , label: 'Num<br>of<br>Mins'
        , toolTip: 'Number of minutes'
        , visible: true
        , sortable: true
        , editable: false
        , saveable: false
        , isRecID: false
        , dataType: 'number'
        , sortUsing: 'numMins'
        , showMore: false
    });


    opts.fieldDefinitions.push({
        name: 'recurringYN'
        , label: 'Recurring?'
        , toolTip: 'Is this service a regular/recurring service?'
        , visible: true
        , sortable: true
        , editable: false
        , saveable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'recurring'
        , showMore: false
    });
    

    opts.fieldDefinitions.push({
        name: 'viaTeleHealthYN'
        , label: 'Via<br>Tele<br>Health?'
        , toolTip: 'Is service delivered via telehealth'
        , visible: true
        , sortable: true
        , editable: false
        , saveable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'viaTeleHealth'
        , showMore: false
    });

    opts.fieldDefinitions.push({
          name: 'whenSummary'
        , label: 'Service Is<br>Provided On'
        , toolTip: 'When will the service be provided'
        , visible: true
        , sortable: false
        , editable: false
        , saveable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'whenSummary'
        , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'notes'
        , label: 'Notes'
        , toolTip: 'Notes'
        , visible: true
        , sortable: false
        , editable: false
        , saveable: false
        , isRecID: false
        , dataType: 'pre'
        , sortUsing: 'notes'
        , showMore: false
    });


    /* Create the rest view */

    $($me).MBA_RestView(opts);
	return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me) 
{
    let dataObj = _fnGetDataObj($me);
		
	
	let VALUE_CLIENT_ID  = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
    let VALUE_PRAC_ID    = $('#' + dataObj.opts.PARM_NAME_PRACTITIONER_ID).val();
    let VALUE_PATIENT_ID = $('#' + dataObj.opts.PARM_NAME_PATIENT_ID).val();
    let VALUE_ACTIVE     = $('#' + dataObj.opts.PARM_NAME_ACTIVE).val();
    let VALUE_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID = $('#' + dataObj.opts.PARM_NAME_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID).val();
    
    let NV_CLIENT_ID     = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID,       VALUE_CLIENT_ID);
    let NV_PRAC_ID       = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PRACTITIONER_ID, VALUE_PRAC_ID);
    let NV_PATIENT_ID    = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PATIENT_ID,      VALUE_PATIENT_ID);
    let NV_ACTIVE        = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE,          VALUE_ACTIVE);
    let NV_REC_ID_EMPTY  = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_REC_ID, "");

    let NV_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID, VALUE_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID);

    /* Note: Don't use a loop here, keep it unrolled for performance reasons */

    /* View */

    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PATIENT_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

    /* Add new (inwindow) */

    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PRAC_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PATIENT_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID);

    /* Edit (inwindow) */
    
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_CLIENT_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_PRAC_ID);    
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_REC_ID_EMPTY);

    /* Delete */

    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_CLIENT_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_PRAC_ID);

    /* Request view */
	
    $(dataObj.restViewCtrl).MBA_RestView('requestViewFromServer', 1);

};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnRefreshView = function (elementid) {
    let $me = _fnGetMe(elementid);
    _updateAdditionalViewParameterValuesAndRequestViewFromServer($me);
    return;
};


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
  
let _fnSetup = function (elementid, optsIn)
{
  
  let $me = _fnGetMe(elementid);	  
  	    
  /* See if we have created an instance of this plugin already for this element.  If so get out. */
 
  let dataObj = $($me).data(_JQ_DATA_NAME);
  if (dataObj) return; 

  /* Define the data object we will save later */
	  
  dataObj = {}; 
	  
  /* Store reference to elem */
	  
  dataObj.me = $me;

  /* Merge default options and options passed in. */
	  
  let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);
  
  dataObj.opts = opts;
  
  /* Create rest view */
  
  let $restViewCtrl  = $me;
  dataObj.restViewCtrl  = $restViewCtrl;
  _createRestView ($restViewCtrl, opts);

  /* Get reference to container control to listen for events on */
  
  let $containerCtrl = $('#' + opts.containerCtrlID);
  dataObj.containerCtrl = $containerCtrl;
  
  /* Save our data object.  This will be used for option calls */

  $($me).data(_JQ_DATA_NAME, dataObj);
  
  /* Wire up events */
  
  $($containerCtrl).on('spedmoninputdata', function(e) {
    _updateAdditionalViewParameterValuesAndRequestViewFromServer ($me);
  });

  _updateAdditionalViewParameterValuesAndRequestViewFromServer($me);

  return opts;
}; /*_fnSetup */

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

return {
      fnSetup: _fnSetup
    , fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer: _updateAdditionalViewParameterValuesAndRequestViewFromServer
    , fnRefreshView: _fnRefreshView
};

})(jQuery);