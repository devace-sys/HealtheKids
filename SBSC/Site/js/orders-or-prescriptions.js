; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.OrdersOrPrescriptionsCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.OrdersOrPrescriptionsCommon = (function ($) {

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _THIS_NAME      = 'Orders Or Prescriptions Common';
const _THIS_NS        = 'mba-orders-or-prescriptions'
const _JQ_DATA_NAME   = 'jq-' + _THIS_NS;
const _DATA_ATTR_BASE = 'data-' + _THIS_NS;

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS = {
    PARM_NAME_CLIENT_ID: ''
  , PARM_NAME_PAT_ID: ''
  , PARM_NAME_GROUP_SVC_CLASS_NAME_ID:''
  , PARM_NAME_ACTIVE: ''
  , PARM_NAME_ORP_APR_STATE:''
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
  , showActive: false
  , showPatientName: true
  , showPracticeName: true
  , showSiteName: true
  , hasCarePlanAccess:true
  , editCarePlanUrl:''
  , svcAuthReqOrderOrPrescriptionUrl:''
  , svcAuthReqPatProfileUrl: ''
  , fnGetOrpApprovalStateValue: function (dataObj) {
      return $('#' + dataObj.opts.PARM_NAME_ORP_APR_STATE).val();
  }
  , fnGetActiveValue: function (dataObj) {
      return $('#' + dataObj.opts.PARM_NAME_ACTIVE).val();
  }
  
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

  opts.saveModeEdit               = 'inwindow';
  opts.baseUrlEdit                =  optsIn.baseUrlEdit; 
  opts.baseUrlEditHasParameters   = true;

  opts.saveModeDelete             = 'inline';
  opts.baseUrlDelete              = optsIn.baseUrlDelete; 
  opts.baseUrlDeleteHasParameters = true;

  opts.loadModeView               = 'rest';
  opts.baseUrlView                =  optsIn.baseUrlView 
  opts.baseUrlViewHasParameters   = true;
  opts.defaultPageRowOrder        = optsIn.defaultPageRowOrder;

  opts.enableReports    = true;
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
      , saveUsing:'recid'
  });

  if (optsIn.showActive == true) {
  
    opts.fieldDefinitions.push({
          name: 'activeStr'
        , label: 'Active'
        , toolTip: 'Active'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'yesno'
        , saveUsing: ''
        , sortUsing: 'active'
        , additionalCssClassesForCol: 'text-left'
        , additionalCssClassesForColTop: 'text-left'
        , additionalCssClassesForColLabel: 'text-left'
        , additionalCssClassesForCell: 'text-left'
        , additionalCssClassesForCellValue: 'text-left'

    });
  
  };

  if (optsIn.showPatientName == true) {
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
        , additionalCssClassesForCol: 'text-left'
        , additionalCssClassesForColTop: 'text-left'
        , additionalCssClassesForColLabel: 'text-left'
        , additionalCssClassesForCell: 'text-left'
        , additionalCssClassesForCellValue: 'text-left'

    });
  };
  
  opts.fieldDefinitions.push({
      name: 'patID'
      , label: 'Patient ID'
      , toolTip: 'Patient ID'
      , visible: false
      , editable: false
      , saveable: false
      , sortable: false
      , isRecID: false
      , dataType: 'hidden'
      , sortUsing: 'patID'
      , saveUsing: ''
      , showMore: false
  });
  
if (optsIn.showPracticeName == true) {
        opts.fieldDefinitions.push({
            name: 'groupServiceClassNameName'
            , label: 'Practice'
            , toolTip: 'Rendering Practitioners Practice Family'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'groupServiceClassNameName'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });
};
opts.fieldDefinitions.push({
            name: 'orpDocStdName'
            , label: 'Service'
            , toolTip: 'Service that has been ordered or prescribed'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'orpDocStdName'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });

  opts.fieldDefinitions.push({
        name: 'lastApprovalEffectiveDateStr'
        , label: 'ORP<br>Approval<br>Date'
        , toolTip: 'Service Last Authorized By ORP On'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'date'
        , saveUsing: ''
      , sortUsing: 'lastApprovalEffectiveDate'
      , additionalCssClassesForCol: 'text-left'
      , additionalCssClassesForColTop: 'text-left'
      , additionalCssClassesForColLabel: 'text-left'
      , additionalCssClassesForCell: 'text-left'
      , additionalCssClassesForCellValue: 'text-left'

  });

  opts.fieldDefinitions.push({
        name: 'lastApprovalExpirationMessage'
        , label: 'ORP<br>Approval<br>Status'
        , toolTip: 'Current status of authorization'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , saveUsing: ''
      , sortUsing: 'lastApprovalExpirationMessage'
      , additionalCssClassesForCol: 'text-left'
      , additionalCssClassesForColTop: 'text-left'
      , additionalCssClassesForColLabel: 'text-left'
      , additionalCssClassesForCell: 'text-left'
      , additionalCssClassesForCellValue: 'text-left'

  });

   
  opts.fieldDefinitions.push({
        name: 'lastApprovalOrpName'
        , label: 'ORP<br>Professional'
        , toolTip: 'Service is authorized by this ORP'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'lastfirst'
        , saveUsing: ''
        , sortUsing: 'lastApprovalOrpName'
      , additionalCssClassesForCol: 'text-left'
      , additionalCssClassesForColTop: 'text-left'
      , additionalCssClassesForColLabel: 'text-left'
      , additionalCssClassesForCell: 'text-left'
      , additionalCssClassesForCellValue: 'text-left'

  });

  opts.fieldDefinitions.push({
          name: 'lastApprovalOrpIsValidMcalOrpStr'
        , label: 'ORP<br>Valid'
        , toolTip: 'ORP is recognized by DHCS as a valid ORP'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'yesnounknown'
        , saveUsing: ''
      , sortUsing: 'lastApprovalOrpIsValidMcalOrp'
      , additionalCssClassesForCol: 'text-left'
      , additionalCssClassesForColTop: 'text-left'
      , additionalCssClassesForColLabel: 'text-left'
      , additionalCssClassesForCell: 'text-left'
      , additionalCssClassesForCellValue: 'text-left'

  });

  opts.fieldDefinitions.push({
        name: 'orpDocType'
      , label: ''
      , toolTip: ''
      , visible: false
      , editable: false
      , saveable: false
      , sortable: true
      , isRecID: false
      , dataType: 'hidden'
      , saveUsing: ''
      , sortUsing: 'active'
  });

  opts.fieldDefinitions.push({
        name: 'refID'
      , label: ''
      , toolTip: ''
      , visible: false
      , editable: false
      , saveable: false
      , sortable: true
      , isRecID: false
      , dataType: 'hidden'
      , saveUsing: ''
      , sortUsing: 'refID'
  });

  opts.fieldDefinitions.push({
          name: 'id'
        , label: 'ORP<br>Doc<br>ID'
        , toolTip: 'Unique ID for this order or prescription'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'number'
        , saveUsing:''
      , sortUsing: 'id'
      , additionalCssClassesForCol: 'text-left'
      , additionalCssClassesForColTop: 'text-left'
      , additionalCssClassesForColLabel: 'text-left'
      , additionalCssClassesForCell: 'text-left'
      , additionalCssClassesForCellValue: 'text-left'

  });

if (optsIn.showSiteName == true) {
    opts.fieldDefinitions.push({
        name: 'siteName'
      , label: 'Site'
      , toolTip: 'Site Name'
      , visible: true
      , editable: false
      , saveable: false
      , sortable: true
      , isRecID: false
      , dataType: 'text'
      , saveUsing: ''
        , sortUsing: 'siteName'
        , additionalCssClassesForCol: 'text-left'
        , additionalCssClassesForColTop: 'text-left'
        , additionalCssClassesForColLabel: 'text-left'
        , additionalCssClassesForCell: 'text-left'
        , additionalCssClassesForCellValue: 'text-left'

    });
}
  /* Setup additional row controls */

  opts.additionalControlDefinitionsForBodyRows = new Map();

  /* Go to care plan screen for patient */

  if (optsIn.hasCarePlanAccess == true)
  {
  
      opts.additionalControlDefinitionsForBodyRows.set('editcareplans', {
                defType: 'userprovided'
                , name: 'editcareplans'
                , toolTip: 'Click Here to Edit Care Plans'
                , cssClass: 'fas fa-notes-medical'
                , handlerFn: function (uiActionObj) {

                    let patID = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="patID"]').val();
                
                    let editCarePlanUrl = optsIn.editCarePlanUrl + '&' + optsIn.PARM_NAME_PAT_ID + '=' + patID;

                    var win = window.open(editCarePlanUrl, '_blank');
                    if (win) {
                        
                        win.focus();
                    } else {
                        
                        alert('Please allow popups for this website');
                    }
                    return uiActionObj;
                }
                , initiallyHidden: false
            });

  };
  
  /* Request authorization for service */

  opts.additionalControlDefinitionsForBodyRows.set('requestsvcauth', {
            defType: 'userprovided'
            , name: 'requestsvcauth'
            , toolTip: 'Click Here to Request Service Authorization'
            , cssClass: 'fa fa-user-md'
            , handlerFn: function (uiActionObj) {
                let orpDocType        = uiActionObj.whatFieldCellsInputValues.get('orpDocType');
                let refEntID          = uiActionObj.whatFieldCellsInputValues.get('refID');

                let svcAuthReqUrlBase = '';

                if (orpDocType === '2') {
                  svcAuthReqUrlBase =  optsIn.svcAuthReqOrderOrPrescriptionUrl; 
                }

                else if (orpDocType === '3') {
                  svcAuthReqUrlBase = optsIn.svcAuthReqPatProfileUrl; 
                }
                let svcAuthReqUrl = svcAuthReqUrlBase + refEntID;

                uiActionObj.orpDocType    = orpDocType;
                uiActionObj.refEntID      = refEntID;
                uiActionObj.svcReqAuthUrl = svcAuthReqUrl;

                let newWindowName     = 'reqauth-' + uiActionObj.recordID;             
                let newWindow         = MBA.RestViewCommon.fnOpenWindow(uiActionObj.elem, svcAuthReqUrl, newWindowName, false);
                uiActionObj.newWindow = newWindow;
                return uiActionObj;
            }
            , initiallyHidden: false
    });

    /* Create the rest view */

    $($me).MBA_RestView(opts);

    return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me) {

  let dataObj = _fnGetDataObj($me);

  let VALUE_CLIENT_ID               = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
  let VALUE_GROUP_SVC_CLASS_NAME_ID = $('#' + dataObj.opts.PARM_NAME_GROUP_SVC_CLASS_NAME_ID).val();
  let VALUE_PAT_ID                  = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
  let VALUE_ORP_APR_STATE           = dataObj.opts.fnGetOrpApprovalStateValue(dataObj);     
  let VALUE_ACTIVE                  = dataObj.opts.fnGetActiveValue(dataObj);
        
  let NV_CLIENT_ID               = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
  let NV_GROUP_SVC_CLASS_NAME_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_GROUP_SVC_CLASS_NAME_ID, VALUE_GROUP_SVC_CLASS_NAME_ID);
  let NV_PAT_ID                  = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PAT_ID, VALUE_PAT_ID);
  let NV_ORP_APR_STATE           = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ORP_APR_STATE, VALUE_ORP_APR_STATE);
  let NV_ACTIVE                  = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE, VALUE_ACTIVE);

  /* Note: Don't use a loop here, keep it unrolled for performance reasons */

  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);      
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GROUP_SVC_CLASS_NAME_ID);    
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ORP_APR_STATE);
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_GROUP_SVC_CLASS_NAME_ID);
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PAT_ID);

  $(dataObj.restViewCtrl).MBA_RestView('requestViewFromServer', 1);
};
    
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnSetup = function (elementid, optsIn) {

  let $me = _fnGetMe(elementid);

  /* See if we have created an instance of this plugin already for this element.  If so get out. */

  let dataObj = $($me).data(_JQ_DATA_NAME);
  if (dataObj) return $me;

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

  return $me;

}; /*_fnSetup */

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

return {
    fnSetup: _fnSetup
  , fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer: _updateAdditionalViewParameterValuesAndRequestViewFromServer
};

})(jQuery);