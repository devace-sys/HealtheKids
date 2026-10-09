;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ClientGroupServiceClassNameSpecificPracticeRuleSetsCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common 
 */

MBA.ClientGroupServiceClassNameSpecificPracticeRuleSetsCommon = (function ($)
{

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _THIS_NAME           = 'Client Group Service Class Name Specific Rule Sets Common Methods';
const _THIS_NS             = 'mba-client_group_service_class_name_specific_practice_rule_sets'
const _JQ_DATA_NAME        = 'jq-'   + _THIS_NS;
const _DATA_ATTR_BASE      = 'data-' + _THIS_NS;  

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS  = {
    PARM_NAME_CLIENT_ID : ''
  , containerCtrlID     : ''
  , sessionTimeOutUrl   : ''
  , baseUrlView         : ''
  , defaultPageRowOrder : ''
  , baseUrlAddNew       : ''
  , baseUrlEdit         : ''
  , baseUrlDelete       : ''
  , defaultReportNumber:'1'
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
   opts.enableRowNumbers           = true; /* Turn on row numbers */
   opts.enableRowControls          = true;
   opts.enableReports              = false;
   opts.enableRowControlRecAddNew  = false;
   opts.enableRowControlRecEdit    = true;
   opts.enableRowControlRecDelete  = false;

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

   opts.loadModeReport             = 'mbawebreport';
   opts.baseUrlReport              = optsIn.baseUrlReport
   opts.baseUrlReportHasParameters = true;
   opts.defaultReportNumber        = optsIn.defaultReportNumber

   opts.fieldDefinitions = [];
   opts.additionalControlDefinitionsForBodyRows = new Map();

   opts.fieldDefinitions.push({
        name: 'id'
      , isRecID: true
      , saveable: true
      , saveUsing: 'recid'
   });
       
  opts.fieldDefinitions.push({
      name: 'groupSvcClassName'
    , label: 'Practice Family'
    , toolTip:'Practice Family'
    , visible: true
    , sortable: true
    , saveable: false
    , editable: false
    , isRecID: false
    , dataType: 'text'
    , sortUsing: 'groupSvcClassName'
    , saveUsing: ''
    , showMore: false
   });
	 
   opts.fieldDefinitions.push({
          name: 'departmentHeadsCanViewSupervisedPracsPrivateNotes'
        , label: 'Department Heads<br>Can View<br>Supervised Practitioners<br>Private Notes'
        , toolTip:'Toggle between yes and no'
        , visible: true
        , sortable: true
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'checkbox'
        , sortUsing: 'departmentHeadsCanViewSupervisedPracsPrivateNotes'
        , saveUsing: 'departmentheadscanviewsupervisedpracsprivatenotes'
        , showMore: false
        , handlerFn: function (uiActionObj) {            
           return uiActionObj;
        }
   });
	
    opts.fieldDefinitions.push({
          name: 'departmentHeadsCanViewSupervisedPracsStoredFiles'
        , label: 'Department Heads<br>Can View<br>Supervised Practitioners<br>Stored Files'
        , toolTip:'Toggle between yes and no'
        , visible: true
        , sortable: true
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'checkbox'
        , sortUsing: 'departmentHeadsCanViewSupervisedPracsStoredFiles'
        , saveUsing: 'departmentheadscanviewsupervisedpracsstoredfiles'
        , showMore: false
        , handlerFn: function (uiActionObj) {            
           return uiActionObj;
        }
   });

    opts.fieldDefinitions.push({
          name: 'departmentHeadsCanViewSupervisedPracsSvcRecs'
        , label: 'Department Heads<br>Can View<br>Supervised Practitioners<br>Service Records'
        , toolTip:'Toggle between yes and no'
        , visible: true
        , sortable: true
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'checkbox'
        , sortUsing: 'departmentHeadsCanViewSupervisedPracsSvcRecs'
        , saveUsing: 'departmentheadscanviewsupervisedpracssvcrecs'
        , showMore: false
        , handlerFn: function (uiActionObj) {            
           return uiActionObj;
        }
   });
   
    opts.fieldDefinitions.push({
          name: 'onlyDepartmentHeadsCanManageDirectSupervisionAssignments'
        , label: 'Only Department Heads<br>Can Manage<br>Direct Supervision<br>Assignments'
        , toolTip:'Toggle between yes and no'
        , visible: true
        , sortable: true
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'checkbox'
        , sortUsing: 'onlyDepartmentHeadsCanManageDirectSupervisionAssignments'
        , saveUsing: 'onlydepartmentheadscanmanagedirectsupervisionassignments'
        , showMore: false
        , handlerFn: function (uiActionObj) {            
           return uiActionObj;
        }
    });

    opts.fieldDefinitions.push({
        name: 'departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup'
        , label: 'Department Heads<br>Can Only View<br>Supervised Practitioner Data<br>For Practitioners<br>In Their Reporting Group'
        , toolTip: 'Toggle between yes and no'
        , visible: true
        , sortable: true
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'checkbox'
        , sortUsing: 'departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup'
        , saveUsing: 'departmentheadscanonlyviewsupervisedpracsdataintheirreportinggroup'
        , showMore: false
        , handlerFn: function (uiActionObj) {
            return uiActionObj;
        }
    });

    opts.fieldDefinitions.push({
        name: 'departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup'
        , label: 'Department Heads<br>Can Only Manage<br>Supervision Assignments<br>For Practitioners<br>In Their Reporting Group'
        , toolTip: 'Toggle between yes and no'
        , visible: true
        , sortable: true
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'checkbox'
        , sortUsing: 'departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup'
        , saveUsing: 'departmentheadscanonlymanagedirectsupervisionassignmentsintheirreportinggroup'
        , showMore: false
        , handlerFn: function (uiActionObj) {
            return uiActionObj;
        }
    });


    opts.fieldDefinitions.push({
        name: 'departmentHeadsCanViewAllPracDataInTheirReportingGroup'
        , label: 'Department Heads<br>Can View All<br>Practitioners Data<br>(Supervised or Not)<br>For Practitioners<br>In Their Reporting Group'
        , toolTip: 'Toggle between yes and no.  Use this instead of the Supervised Practitioner options if you need to give this practice families department heads access to all.'
        , visible: true
        , sortable: true
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'checkbox'
        , sortUsing: 'departmentHeadsCanViewAllPracDataInTheirReportingGroup'
        , saveUsing: 'departmentheadscanviewallpracdataintheirreportinggroup'
        , showMore: false
        , handlerFn: function (uiActionObj) {
            return uiActionObj;
        }
    });

    opts.fieldDefinitions.push({
        name: 'supervisingAndSupervisedPracsMustBeInSameReportingGroup'
        , label: 'Supervising And Supervised<br>Practitioners Must Be In<br>The Same Reporting Group'
        , toolTip: 'Toggle between yes and no'
        , visible: true
        , sortable: true
        , editable: true
        , saveable: true
        , isRecID: false
        , dataType: 'checkbox'
        , sortUsing: 'supervisingAndSupervisedPracsMustBeInSameReportingGroup'
        , saveUsing: 'supervisingandsupervisedpracsmustbeinsamereportinggroup'
        , showMore: false
        , handlerFn: function (uiActionObj) {
            return uiActionObj;
        }
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
    let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
    
    /* Note: Don't use a loop here, keep it unrolled for performance reasons */

    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);

    /* We need these for the various rec ops */

    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet',   NV_CLIENT_ID);

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
    , fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer: _updateAdditionalViewParameterValuesAndRequestViewFromServer
};

})(jQuery);