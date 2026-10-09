; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PatientPromisedServicesCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.PatientPromisedServicesCommon = (function ($) {

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _THIS_NAME      = 'Patient Promised Services Common';
const _THIS_NS        = 'mba-patient-promised-services-common'
const _JQ_DATA_NAME   = 'jq-' + _THIS_NS;
const _DATA_ATTR_BASE = 'data-' + _THIS_NS;

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS = {
    PARM_NAME_CLIENT_ID: ''
  , PARM_NAME_PAT_ID: ''
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
  , fnOnResponseViewFromServer: function (elem, responseData, $me, dataObj) { return; }
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
  opts.enableRowControls         = true;
  opts.enableRowControlRecAddNew = true;
  opts.enableRowControlRecEdit   = true;
  opts.enableRowControlRecDelete = true;

  opts.saveModeAddNew             = 'inwindow';
  opts.baseUrlAddNew              = optsIn.baseUrlAddNew; 
  opts.baseUrlAddNewHasParameters = true;

  opts.saveModeDelete             = 'inline';
  opts.baseUrlDelete              = optsIn.baseUrlDelete; 
  opts.baseUrlDeleteHasParameters = true;

  opts.saveModeEdit = 'custom';
  opts.baseUrlEdit                =  optsIn.baseUrlEdit; 
  opts.baseUrlEditHasParameters   = true;
  
  opts.handlerFnEditCustom = function (uiActionObj) {
    let nvpObjs = [];

    uiActionObj.dataObj.opts.additionalParameterDefinitionsForEdit.forEach(function (value, key) {
      nvpObjs.push(MBA.RestViewCommon.fnCreateNameValueObject(key, value));
    });

    let rid = uiActionObj.recordID;
    let baseUrl = uiActionObj.dataObj.opts.baseUrlEdit + rid; // add recid to parameters

    let url = MBA.RestViewCommon.fnBuildUrl( baseUrl
                                           , uiActionObj.dataObj.opts.baseUrlEditHasParameters
                                           , nvpObjs);

    let newWindowName = 'edit-' + rid;
    let newWindow = MBA.RestViewCommon.fnOpenWindow(uiActionObj.elem, url, newWindowName, true);
    uiActionObj.newWindow = newWindow;
    return uiActionObj;
  
  };
   
  opts.loadModeView               = 'rest';
  opts.baseUrlView                =  optsIn.baseUrlView 
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

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
            name: 'spEdServiceCodeAndName'
            , label: 'Service'
            , toolTip: 'The service to be provided'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdServiceCodeAndName'
            , saveUsing: 'spEdServiceCodeAndName'
            , showMore: false
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:20em'
        });

        opts.fieldDefinitions.push({
            name: 'spEdProviderCodeAndName'
            , label: 'Provider'
            , toolTip: 'Who is the service provider'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdProviderCodeAndName'
            , saveUsing: 'spEdProviderCodeAndName'
            , showMore: false
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'            
        });

        opts.fieldDefinitions.push({
            name: 'spEdFreqCodeAndName'
            , label: 'Frequency'
            , toolTip: 'Service frequency'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdFreqCodeAndName'
            , saveUsing: 'spEdFreqCodeAndName'
            , showMore: false
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'spEdLocationCodeAndName'
            , label: 'Location'
            , toolTip: 'Service location'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdLocationCodeAndName'
            , saveUsing: 'spEdLocationCodeAndName'
            , showMore: false
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'startDateStr'
            , label: 'Start<br>Date'
            , toolTip: 'Start Date'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'startDate'
            , saveUsing: 'startDate'
            , showMore: false
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });

        opts.fieldDefinitions.push({
            name: 'endDateStr'
            , label: 'End<br>Date'
            , toolTip: 'End Date'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'endDate'
            , saveUsing: 'endDate'
            , showMore: false
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });


        opts.fieldDefinitions.push({
            name: 'minsPerFreq'
            , label: 'Total Minutes<br/>(Recurring)'
            , toolTip: 'Minutes per frequency interval'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'minsPerFreq'
            , saveUsing: 'minsPerFreq'
            , showMore: false
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });

    opts.fnOnResponseViewFromServer = function (elem, responseData, $me, dataObj) {
        return optsIn.fnOnResponseViewFromServer(elem, responseData, $me, dataObj);
    }

    /* Create the rest view */

    $($me).MBA_RestView(opts);

    return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me) {

  let dataObj = _fnGetDataObj($me);

  let VALUE_CLIENT_ID               = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
  let VALUE_PAT_ID                  = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
  let VALUE_ACTIVE                  = '1';
        
  let NV_CLIENT_ID               = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
  let NV_PAT_ID                  = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PAT_ID, VALUE_PAT_ID);
  let NV_ACTIVE                  = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE, VALUE_ACTIVE);


  /* Note: Don't use a loop here, keep it unrolled for performance reasons */

  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);      
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PAT_ID);

  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_CLIENT_ID);
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_PAT_ID);

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