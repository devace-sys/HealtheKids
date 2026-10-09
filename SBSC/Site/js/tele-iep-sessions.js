;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.TeleIEPSessionsCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.TeleIEPSessionsCommon = (function ($)
{

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _THIS_NAME           = 'TeleIEPSessions Common Methods';
const _THIS_NS             = 'mba-tele-iep-sessions'
const _JQ_DATA_NAME        = 'jq-'   + _THIS_NS;
const _DATA_ATTR_BASE      = 'data-' + _THIS_NS;  

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS  = {
    PARM_NAME_CLIENT_ID   : 'clientid'
  , PARM_NAME_PATIENT_ID  : 'patid'
  , PARM_NAME_ACTIVE      : 'active'
  , containerCtrlID       : ''
  , sessionTimeOutUrl     : ''
  , baseUrlView           : ''
  , defaultPageRowOrder   : ''
  , baseUrlAddNew         : ''
  , baseUrlEdit           : ''
  , baseUrlDelete         : ''
  , reportBaseUrl         : ''
  , activeFlag            : '1'
  , baseUrlJoinSession    : ''
  , enableRowControls     : true
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
    opts.enableRowControls          = optsIn.enableRowControls;
    opts.enableRowControlRecAddNew  = true;
    opts.enableRowControlRecEdit    = true;
    opts.enableRowControlRecDelete  = true;
    opts.positionUserDefinedControlsInBodyExisting = 2; /* After built in */
    
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

    opts.enableReports    = false;
    opts.enableReportHtml = false;
    opts.enableReportXls  = false;
    opts.enableReportPdf  = false;

    opts.fieldDefinitions = [];
    
    opts.fieldDefinitions.push({
        name: 'id'
        , isRecID: true
        , saveable: true
        , saveUsing: 'recid'
    });

    opts.fieldDefinitions.push({
        name: 'meetingDateStr'
        , label: 'Meeting Date'
        , toolTip: 'Date of IEP Meeting'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'date'
        , saveUsing: ''
        , sortUsing: 'meetingDate'
    });

    opts.fieldDefinitions.push({
        name: 'meetingTimeStr'
        , label: 'Meeting Time'
        , toolTip: 'Time of Meeting'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'time'
        , saveUsing: ''
        , sortUsing: 'meetingTime'
    });

    opts.fieldDefinitions.push({
        name: 'patName'
        , label: 'Patient<br>Last, First'
        , toolTip: 'Patient Last, First Name'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'lastfirst'
        , sortUsing: 'patName'
        , saveUsing: ''
        , showMore: false
    });

    opts.additionalControlDefinitionsForBodyRows = new Map();

    /* Join Session  */

    opts.additionalControlDefinitionsForBodyRows.set('joinSession', {
        defType: 'userprovided'
        , name: 'joinSession'
        , toolTip: 'Join Meeting'
        , cssClass: 'mba-rest-view fa fa-video'
        , handlerFn: function (uiActionObj) {
            let opURL = optsIn.baseUrlJoinSession
            $.spedmonWebUI.recOpJoinTeleCommMeetingUsingUserID(uiActionObj.recordID, opURL, null);
            return uiActionObj;
        }
        , initiallyHidden: false
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
    let VALUE_PAT_ID = $('#' + dataObj.opts.PARM_NAME_PATIENT_ID).val();
    let VALUE_ACTIVE = dataObj.opts.activeFlag;

    if (!VALUE_CLIENT_ID) return;

    let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
    let NV_PAT_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PATIENT_ID, VALUE_PAT_ID);
    let NV_ACTIVE = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE, VALUE_ACTIVE);

    /* Note: Don't use a loop here, keep it unrolled for performance reasons */

    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

    /* We need these for the add new */

    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
    $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PAT_ID);

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