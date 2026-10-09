; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PatientServiceRecordsCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.PatientServiceRecordsCommon = (function ($) {

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _THIS_NAME      = 'Patient Service Records Common';
const _THIS_NS        = 'mba-patient-service-records-common'
const _JQ_DATA_NAME   = 'jq-' + _THIS_NS;
const _DATA_ATTR_BASE = 'data-' + _THIS_NS;

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS = {
    PARM_NAME_CLIENT_ID: ''
  , PARM_NAME_PATIENT_ID: ''
  , PARM_NAME_ACTIVE: ''
  , containerCtrlID: ''
  , sessionTimeOutUrl: ''
  , baseUrlView: ''
  , defaultPageRowOrder: ''
  , baseUrlAddNew: ''
  , baseUrlEdit: ''
  , baseUrlDelete: ''
  , baseUrlReport:''
  , defaultReportNumber: ''
  , enableRowNumbers: true
  , autoHidePageControls: false
  , enableScrollView: false
  , scrollViewUseCustomHeight: true
  , scrollViewCustomHeight: '15em'  
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

let _fnGetDataObj = function ($me) {
  let dataObj = $($me).data(_JQ_DATA_NAME);
  if (!dataObj) throw new Error('An instance of ' + _THIS_NAME + ' is required');
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

let _createRestView = function ($me, optsIn) {

  let opts = {};

  opts.autoHidePageControls      = optsIn.autoHidePageControls;
  opts.enableScrollView          = optsIn.enableScrollView;
  opts.scrollViewUseCustomHeight = optsIn.scrollViewUseCustomHeight;
  opts.scrollViewCustomHeight    = optsIn.scrollViewCustomHeight;

  opts.sessionTimeOutUrl         = optsIn.sessionTimeOutUrl;
 
  opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */
  
  opts.enableSortControls        = true;
  opts.enableRowNumbers          = optsIn.enableRowNumbers;
  opts.enableRowControls         = false;
  
  opts.loadModeView               = 'rest';
  opts.baseUrlView                = optsIn.baseUrlView;
  opts.baseUrlViewHasParameters   = true;
  opts.defaultPageRowOrder        = optsIn.defaultPageRowOrder;

  opts.enableReports    = false;
  opts.enableReportHtml = true;
  opts.enableReportXls  = true;
  opts.enableReportPdf  = false;

  opts.loadModeReport             = 'mbawebreport';
  opts.baseUrlReport              = optsIn.baseUrlReport; 
  opts.baseUrlReportHasParameters = true;
  opts.defaultReportNumber        = optsIn.defaultReportNumber 
  
  opts.fieldDefinitions = [];
  opts.fieldDefinitions = [];
  opts.fieldDefinitions.push({ name: 'id', isRecID: true });
  opts.fieldDefinitions.push({ name: 'dosStr', label: 'Date', visible: true, sortable: true, isRecID: false, dataType: 'date', sortUsing: 'dos' });
  opts.fieldDefinitions.push({ name: 'startTimeStr', label: 'Start<br>Time', visible: true, sortable: false, isRecID: false, dataType: 'time', sortUsing: 'startTimeVal', showMore: false });
  opts.fieldDefinitions.push({ name: 'endTimeStr', label: 'End<br>Time', visible: true, sortable: false, isRecID: false, dataType: 'time', sortUsing: 'endTimeVal', showMore: false });
  opts.fieldDefinitions.push({ name: 'svcName', label: 'Service Provided', visible: true, sortable: true, isRecID: false, dataType: 'string', sortUsing: 'svcName', showMore: false });
  opts.fieldDefinitions.push({ name: 'pracName', label: 'Provided By<br>Last, First', visible: true, sortable: true, isRecID: false, dataType: 'lastfirst', sortUsing: 'pracName', showMore: false });
  opts.fieldDefinitions.push({ name: 'numMins_tripsMiles', label: 'Minutes or<br>Trips/Miles', visible: true, sortable: true, isRecID: false, dataType: 'ratio', sortUsing: 'numMins', showMore: false });
  opts.fieldDefinitions.push({ name: 'isIFSPorIEPStr', label: 'Part<br>Of<br>IEP', visible: true, sortable: true, sortUsing: 'isIFSPorIEP', isRecID: false, dataType: 'yesno', showMore: false });
  opts.fieldDefinitions.push({ name: 'attendanceStatusSelectionName', label: 'Attendance<br>Status', visible: true, sortable: true, sortUsing: 'attendanceStatusSelectionName', isRecID: false, dataType: 'string', showMore: false });
  
  /* Create the rest view */

  $($me).MBA_RestView(opts);

  return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me) {

  let dataObj = _fnGetDataObj($me);

  let VALUE_CLIENT_ID               = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
  let VALUE_PAT_ID                  = $('#' + dataObj.opts.PARM_NAME_PATIENT_ID).val();
  let VALUE_ACTIVE                  = '1';
        
  let NV_CLIENT_ID               = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
  let NV_PAT_ID                  = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PATIENT_ID, VALUE_PAT_ID);
  let NV_ACTIVE                  = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE, VALUE_ACTIVE);


  /* Note: Don't use a loop here, keep it unrolled for performance reasons */

  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);      
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

  $(dataObj.restViewCtrl).MBA_RestView('requestViewFromServer', 1);
};
    
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnSetup = function (elementid, optsIn) {

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

  let $restViewCtrl      = $me;
  dataObj.restViewCtrl   = $restViewCtrl;
  _createRestView($restViewCtrl, opts);

  /* Get reference to container control to listen for events on */

  let $containerCtrl    = $('#' + opts.containerCtrlID);
  dataObj.containerCtrl = $containerCtrl;

  /* Save our data object.  This will be used for option calls */

  $($me).data(_JQ_DATA_NAME, dataObj);

  /* Wire up events */

  $($containerCtrl).on('spedmoninputdata', function (e) {
    _updateAdditionalViewParameterValuesAndRequestViewFromServer($me);
  });

  _updateAdditionalViewParameterValuesAndRequestViewFromServer($me);

}; /*_fnSetup */

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

return {
    fnSetup: _fnSetup
  , fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer: _updateAdditionalViewParameterValuesAndRequestViewFromServer
};

})(jQuery);