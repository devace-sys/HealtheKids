;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ClientSchoolSessionAcademicYearsCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.ClientSchoolSessionAcademicYearsCommon = (function ($)
{

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _THIS_NAME           = 'School Session Academic Years Common Methods';
const _THIS_NS             = 'mba-client-school-session-academic-years'
const _JQ_DATA_NAME        = 'jq-'   + _THIS_NS;
const _DATA_ATTR_BASE      = 'data-' + _THIS_NS;  

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS  = {
    PARM_NAME_CLIENT_ID : 'clientid'
  , PARM_NAME_ACTIVE    : 'active'
  , containerCtrlID     : ''
  , sessionTimeOutUrl   : ''
  , baseUrlView         : ''
  , defaultPageRowOrder : ''
  , baseUrlAddNew       : ''
  , baseUrlEdit         : ''
  , baseUrlDelete: ''
  , baseURLCompanyFiscalYearsViewSel:''
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

   opts.sessionTimeOutUrl          = optsIn.sessionTimeOutUrl;
   opts.requestViewOnLoad          = false; /*This is so we can set the initial filters */
   opts.enableSortControls         = true;
   opts.enableRowNumbers           = false; /* Turn off row numbers */
   opts.enableRowControls          = true;
   opts.enableReports              = false;
   opts.enableRowControlRecAddNew  = true;
   opts.enableRowControlRecEdit    = true;
   opts.enableRowControlRecDelete  = true;

   opts.loadModeView               = 'rest';
   opts.baseUrlView                = optsIn.baseUrlView;
   opts.baseUrlViewHasParameters   = true;
   opts.defaultPageRowOrder        = optsIn.defaultPageRowOrder;

   opts.saveModeAddNew             = 'inline';
   opts.baseUrlAddNew              = optsIn.baseUrlAddNew;
   opts.baseUrlAddNewHasParameters = true;

   opts.saveModeEdit               = 'inline';
   opts.baseUrlEdit                = optsIn.baseUrlEdit;
   opts.baseUrlEditHasParameters   = true;

   opts.saveModeDelete             = 'inline';
   opts.baseUrlDelete              = optsIn.baseUrlDelete;
   opts.baseUrlDeleteHasParameters = true;
        		
   opts.fieldDefinitions = [];
   opts.additionalControlDefinitionsForBodyRows = new Map();

   opts.fieldDefinitions.push({
        name: 'id'
      , isRecID: true
      , saveable: true
      , saveUsing: 'recid'
   });
    
   let companyFiscalYearAutoCompleteOptions = {};

   companyFiscalYearAutoCompleteOptions.baseUrl                    = optsIn.baseURLCompanyFiscalYearsViewSel;
   companyFiscalYearAutoCompleteOptions.loadMode                   = 'mbaviewsel';
   companyFiscalYearAutoCompleteOptions.getInitialSelectedNameFrom = 'companyFiscalYearName';
   companyFiscalYearAutoCompleteOptions.fnOnSelect                 = function (event, ui) { };        
   companyFiscalYearAutoCompleteOptions.fnModifyRequestNvps        = function (nvpsIn) { return nvpsIn; };
   companyFiscalYearAutoCompleteOptions.fnModifyResponseSelRecs    = function (requestNvps, SelRecs) { return SelRecs; };
   companyFiscalYearAutoCompleteOptions.fnModifyRenderItem         = function ($ul, item, $li) { return $li; };
   companyFiscalYearAutoCompleteOptions.fnHandleCellValueAction    = function (uiActionObj) { return uiActionObj; };

   opts.fieldDefinitions.push({
       name: 'companyFiscalYearID'
        , label: 'Academic Year'
        , toolTip: 'What academic year should this school year be associated with?'
        , visible: true
        , sortable: true
        , saveable: true
        , editable: true
        , isRecID: false
        , dataType: 'autocomplete'
        , dataTypeOptions: companyFiscalYearAutoCompleteOptions
        , sortUsing: 'companyFiscalYearName'
        , saveUsing: 'companyfiscalyearid'
        , showMore: false
   });

   opts.fieldDefinitions.push({
        name: 'name'
      , label: 'Name of School Year or Track'
      , toolTip: 'Your organizations name for the school year or track'
      , visible: true
      , sortable: true
      , saveable: true
      , editable: true
      , isRecID: false
      , dataType: 'text'
      , sortUsing: 'name'
      , saveUsing: 'name'
      , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'startDateStrYMD'
      , label: 'Start Date'
      , toolTip: 'The date that the school year starts'
      , visible: true
      , sortable: true
      , saveable: true
      , editable: true
      , isRecID: false
      , dataType: 'date'
      , sortUsing: 'startDate'
      , saveUsing: 'startdate'
      , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'endDateStrYMD'
      , label: 'End Date'
      , toolTip: 'The date that the school year ends'
      , visible: true
      , sortable: true
      , saveable: true
      , editable: true
      , isRecID: false
      , dataType: 'date'
      , sortUsing: 'endDate'
      , saveUsing: 'enddate'
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
	
	let VALUE_CLIENT_ID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
    let VALUE_ACTIVE    = '1';

    let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
    let NV_ACTIVE    = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE,    VALUE_ACTIVE);
    
    /* Note: Don't use a loop here, keep it unrolled for performance reasons */

    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

    /* We need these for the various rec ops */

    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet',   NV_CLIENT_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_CLIENT_ID);


    $(dataObj.restViewCtrl).MBA_RestView('requestViewFromServer', 1);
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
  
}; /*_fnSetup */

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

return {
      fnSetup: _fnSetup
    , fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer : _updateAdditionalViewParameterValuesAndRequestViewFromServer
};

})(jQuery);