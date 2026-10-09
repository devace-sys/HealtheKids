; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.StoredFilesCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.StoredFilesCommon = (function ($) {

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _THIS_NAME      = 'Stored Files Common';
const _THIS_NS        = 'mba-stored-files'
const _JQ_DATA_NAME   = 'jq-' + _THIS_NS;
const _DATA_ATTR_BASE = 'data-' + _THIS_NS;

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS = {
    PARM_NAME_CLIENT_ID: ''
  , PARM_NAME_DATE_RANGE:''
  , PARM_NAME_FILE_CLASS:''
  , PARM_NAME_PAT_ID: ''  
  , PARM_NAME_FILE_ID: ''
  , PARM_NAME_REC_ID: ''
  , containerCtrlID: ''
  , sessionTimeOutUrl: ''
  , baseUrlView: ''
  , defaultPageRowOrder: ''
  , baseUrlDelete: ''
  , baseUrlReport:''
  , defaultReportNumber: ''
  , enableRowNumbers: true
  , autoHidePageControls: false
  , enableScrollView: false
  , scrollViewUseCustomHeight: true
  , scrollViewCustomHeight: '15em'
  , isPcalStaff: true
  , showPatientName: true
  , webSvcFlagAsNonConfidentialUrl:'' 
  , webSvcFlagAsConfidentialUrl: ''
  , webSvcEnableSharingWithPatientUrl: ''
  , webSvcDisableSharingWithPatientUrl: ''
  , webSvcEnableSharingWithParentUrl: ''
  , webSvcDisableSharingWithParentUrl: ''
  , showOKToShareWithPatient: false
  , showOKToShareWithParentGuardian: false
  , currUserID: -1 
  , downloadHandlerPrivateBaseUrl: ''
  , urlFilesUpload: ''				  
  , fnGetFileClassValue: function (dataObj) {
    return $('#' + dataObj.opts.PARM_NAME_FILE_CLASS).val();
  }
  , fnGetDateRangeValue: function (dataObj) {
    return $('#' + dataObj.opts.PARM_NAME_DATE_RANGE).val();
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

  opts.sessionTimeOutUrl            = optsIn.sessionTimeOutUrl; 
  opts.requestViewOnLoad            = false; /*This is so we can set the initial filters */  
  opts.enableSortControls           = true;
  opts.enableRowNumbers             = optsIn.enableRowNumbers;
  opts.enableRowControls            = true;
  opts.enableRowControlRecAddNew    = false;
  opts.enableRowControlRecEdit      = false;
  opts.enableRowControlRecDelete    = true;

  opts.enableRowControlShowAdditionalInfo        = true;
  opts.positionUserDefinedControlsInBodyExisting = 2; /* After built in*/

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
        , saveUsing: 'recid'
  });

  opts.fieldDefinitions.push({
        name: 'label'
        , label: 'File Name and Description'
        , toolTip: 'File Name and Description'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'label'
        , additionalCssClassesForCol: 'text-left'
        , additionalCssClassesForColTop: 'text-left'
        , additionalCssClassesForColLabel: 'text-left'
        , additionalCssClassesForCell: 'text-left'
        , additionalCssClassesForCellValue: 'text-left'
  });

  opts.fieldDefinitions.push({
        name: 'fileUploadOnStr'
        , label: 'Uploaded On'
        , toolTip: 'File Uploaded On'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'date'
        , sortUsing: 'fileUploadOn'
      , additionalCssClassesForCol: 'text-left'
      , additionalCssClassesForColTop: 'text-left'
      , additionalCssClassesForColLabel: 'text-left'
      , additionalCssClassesForCell: 'text-left'
      , additionalCssClassesForCellValue: 'text-left'
  });

  opts.fieldDefinitions.push({
        name: 'fileClassName'
        , label: 'Information In File'
        , toolTip: 'What is in the file'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'fileClassName'
      , additionalCssClassesForCol: 'text-left'
      , additionalCssClassesForColTop: 'text-left'
      , additionalCssClassesForColLabel: 'text-left'
      , additionalCssClassesForCell: 'text-left'
      , additionalCssClassesForCellValue: 'text-left'
  });

    opts.fieldDefinitions.push({
        name: 'patID'
        , visible: false
        , sortable: false
        , saveable: true
        , editable: false
        , isRecID: false
        , dataType: 'hidden'
        , sortUsing: ''
        , saveUsing: 'patID'
        , showMore: false
    });

    if (optsIn.showPatientName == true) {

      opts.fieldDefinitions.push({
          name: 'patName'
        , label: 'Associated Patient'
        , toolTip: 'Who is the patient that is associated with this file'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'patName'
          , additionalCssClassesForCol: 'text-left'
          , additionalCssClassesForColTop: 'text-left'
          , additionalCssClassesForColLabel: 'text-left'
          , additionalCssClassesForCell: 'text-left'
          , additionalCssClassesForCellValue: 'text-left'

      });
    };

    opts.additionalInfoFieldDefinitions = [];

    opts.additionalInfoFieldDefinitions.push({
          name: 'fileUploadByEmail'
        , label: 'Uploaded By'
        , toolTip: 'Who Uploaded This File'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'fileUploadByEmail'
    });

    opts.additionalInfoFieldDefinitions.push({
        name: 'fileSizeHuman'
        , label: 'Size'
        , toolTip: 'Size of File'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'fileSizeHuman'
    });

    if (optsIn.isPcalStaff == true) {

        opts.additionalInfoFieldDefinitions.push({
            name: 'ourFileName'
            , label: 'SpEdCare File Name'
            , toolTip: 'Our Internal File Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'ourFileName'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'fileSubClass'
            , label: 'Type of Information'
            , toolTip: 'Our internal file sub class'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'fileSubClass'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'clientName'
            , label: 'Associated Client'
            , toolTip: 'Who is the client that is associated with this file'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'clientName'
        });
    }

    opts.additionalInfoFieldDefinitions.push({
            name: 'pracName'
            , label: 'Associated Practitioner'
            , toolTip: 'Who is the practitioner that is associated with this file'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'pracName'
    });

    opts.additionalInfoFieldDefinitions.push({
        name: 'isConfidentialPracticeFileStr'
        , label: 'Confidential'
        , toolTip: 'Confidential'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'isConfidentialPracticeFile'
    });

    opts.additionalInfoFieldDefinitions.push({
        name: 'okToShareFileWithPatientStr'
        , label: 'File Shared With Patient'
        , toolTip: 'File Shared With Patient'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'okToShareFileWithPatient'
    });

    opts.additionalInfoFieldDefinitions.push({
        name: 'okToShareFileWithParentGuardianStr'
        , label: 'File Shared With Parent/Guardian'
        , toolTip: 'File Shared With Parent/Guardian'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'okToShareFileWithParentGuardian'
    });

    opts.additionalInfoFieldDefinitions.push({
        name: 'fileMimeType'
        , label: 'File MIME Type'
        , toolTip: 'What type of file is this'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'fileMimeType'
    });

    opts.additionalInfoFieldDefinitions.push({
        name: 'id'
        , label: 'SpEdCare File ID'
        , toolTip: 'Our internal id for this file'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'text'
        , sortUsing: 'id'
    });

	opts.additionalControlDefinitionsForHeadRows = new Map();
    opts.positionUserDefinedControlsInHead = MBA.RestViewCommon.CONST_POSITION_USER_DEFINED_CONTROLS.AFTER_BUILT_IN;

    opts.additionalControlDefinitionsForHeadRows.set('filesupload', {
        defType: 'userprovided'
        , name: 'filesupload'
        , toolTip: 'Updaload files'
        , cssClass: 'fas fa-paperclip'
        , handlerFn: function (uiActionObj) {
            let url = optsIn.urlFilesUpload;
            MBA.ComponentCommon.fnOpenWindow(url, null);
            return uiActionObj;
        }
        , initiallyHidden: false
    });																												
    /* Setup additional row controls */

    opts.additionalControlDefinitionsForBodyRows = new Map();

    
    /* Flag as confidential */

    opts.additionalControlDefinitionsForBodyRows.set('flagAsConfidential', {
          defType: 'userprovided'
        , name: 'flagAsConfidential'
        , toolTip: 'Click here to flag this file as CONFIDENTIAL.  This file is currently flagged as NON confidential and is visible to all appropriate and authorized users.  If you click here you will restrict access to this file to just yourself and (if applicable) your direct supervisor.'
        , cssClass: 'fas fa-key text-warning'
        , handlerFn: function (uiActionObj) {

            let reqUrl = optsIn.webSvcFlagAsConfidentialUrl;
            let reqDataObj = {};
            reqDataObj[optsIn.PARM_NAME_REC_ID] = uiActionObj.recordID;
            let reqDataJSON = JSON.stringify(reqDataObj);

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqDataJSON, null)
                .then(responseData => {                    
                    $(uiActionObj.me).MBA_RestView('refreshCurrentViewFromServer');
                })
                .catch(responseData => {
                });

            return uiActionObj;            
        }
        , initiallyHidden: false
    });

    /* Flag as non confidential */

    opts.additionalControlDefinitionsForBodyRows.set('flagAsNonConfidential', {
        defType: 'userprovided'
        , name: 'flagAsNonConfidential'
        , toolTip: 'Click here to flag this file as NON confidential. This file is currently flagged as confidential and is only visible to yourself and (if applicable) your direct supervisior.  If you click here you will remove this protection.'
        , cssClass: 'fas fa-lock-open text-danger'
        , handlerFn: function (uiActionObj) {
            let reqUrl = optsIn.webSvcFlagAsNonConfidentialUrl;
            let reqDataObj = {};
            reqDataObj[optsIn.PARM_NAME_REC_ID] = uiActionObj.recordID;
            let reqDataJSON = JSON.stringify(reqDataObj);

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqDataJSON, null)
                .then(responseData => {
                    $(uiActionObj.me).MBA_RestView('refreshCurrentViewFromServer');
                })
                .catch(responseData => {
                });
            return uiActionObj;
        }
        , initiallyHidden: false
    });

    /* Enable sharing with Patient */

    opts.additionalControlDefinitionsForBodyRows.set('enableSharingWithPatient', {
        defType: 'userprovided'
        , name: 'enableSharingWithPatient'
        , toolTip: 'Click here to share this file with the patient.'
        , cssClass: 'fas fa-user-times text-danger'
        , handlerFn: function (uiActionObj) {

            let reqUrl = optsIn.webSvcEnableSharingWithPatientUrl;
            let reqDataObj = {};
            reqDataObj[optsIn.PARM_NAME_REC_ID] = uiActionObj.recordID;
            let reqDataJSON = JSON.stringify(reqDataObj);

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqDataJSON, null)
                .then(responseData => {
                    $(uiActionObj.me).MBA_RestView('refreshCurrentViewFromServer');
                })
                .catch(responseData => {
                });

            return uiActionObj;
        }
        , initiallyHidden: false
    });


    /* Disable sharing with Patient */

    opts.additionalControlDefinitionsForBodyRows.set('disableSharingWithPatient', {
        defType: 'userprovided'
        , name: 'disableSharingWithPatient'
        , toolTip: 'Click here to stop sharing this file with the patient.'
        , cssClass: 'fas fa-user-check text-success'
        , handlerFn: function (uiActionObj) {

            let reqUrl = optsIn.webSvcDisableSharingWithPatientUrl;
            let reqDataObj = {};
            reqDataObj[optsIn.PARM_NAME_REC_ID] = uiActionObj.recordID;
            let reqDataJSON = JSON.stringify(reqDataObj);

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqDataJSON, null)
                .then(responseData => {
                    $(uiActionObj.me).MBA_RestView('refreshCurrentViewFromServer');
                })
                .catch(responseData => {
                });

            return uiActionObj;
        }
        , initiallyHidden: false
    });


    /* Enable sharing with Parent/Guardian */

    opts.additionalControlDefinitionsForBodyRows.set('enableSharingWithParentGuardian', {
        defType: 'userprovided'
        , name: 'enableSharingWithParentGuardian'
        , toolTip: 'Click here to share this file with the parent/guardian.'
        , cssClass: 'fas fa-people-arrows text-danger'
        , handlerFn: function (uiActionObj) {

            let reqUrl = optsIn.webSvcEnableSharingWithParentUrl;
            let reqDataObj = {};
            reqDataObj[optsIn.PARM_NAME_REC_ID] = uiActionObj.recordID;
            let reqDataJSON = JSON.stringify(reqDataObj);

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqDataJSON, null)
                .then(responseData => {
                    $(uiActionObj.me).MBA_RestView('refreshCurrentViewFromServer');
                })
                .catch(responseData => {
                });

            return uiActionObj;
        }
        , initiallyHidden: false
    });


    /* Disable sharing with Parent/Guardian */

    opts.additionalControlDefinitionsForBodyRows.set('disableSharingWithParentGuardian', {
        defType: 'userprovided'
        , name: 'disableSharingWithParentGuardian'
        , toolTip: 'Click here to stop sharing this file with the parent/guardian.'
        , cssClass: 'fas fa-people-arrows text-success'
        , handlerFn: function (uiActionObj) {

            let reqUrl = optsIn.webSvcDisableSharingWithParentUrl;
            let reqDataObj = {};
            reqDataObj[optsIn.PARM_NAME_REC_ID] = uiActionObj.recordID;
            let reqDataJSON = JSON.stringify(reqDataObj);

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqDataJSON, null)
                .then(responseData => {
                    $(uiActionObj.me).MBA_RestView('refreshCurrentViewFromServer');
                })
                .catch(responseData => {
                });

            return uiActionObj;
        }
        , initiallyHidden: false
    });

    /* Cell creation hook */

    opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
        if ((subsection === 103) && (rowtype === 4)) {

               if (optsIn.isPcalStaff == true) {
                  if (fieldDefinition.name === 'fileClassName') {
                      $($newCellValue).append('<br><sub>' + rowData.fileSubClass + '</sub>');
                  }
               }

               if (fieldDefinition.name === 'label') {
                let faFileIcon = MBA.ComponentCommon.fnMimeTypeToFaIconClassName(rowData.fileMimeType);

                $($newCellValue).attr('title', 'Click here to download this file.');
                $($newCellValue).wrap('<a href="#" class="mba-file-download"></a>');
                $($newCellValue).prepend($('<i class="fa ' + faFileIcon + ' mr-1"></i>'));
                if (rowData.isConfidentialPracticeFile == true) {
                    $($newCellValue).append('<span class="badge badge-warning ml-1" title="Only you or (if applicable) your supervisior can see this row and download this file.">Confidential</span>');
                }
                $($newCellValue).append('<br>');
                $($newCellValue).append('<sub>' + rowData.description + '</sub>');

                $($newCellValue).closest('a').on('click', function () {
                  MBA.ComponentCommon.fnFileDownload(optsIn.downloadHandlerPrivateBaseUrl, true, optsIn.PARM_NAME_FILE_ID, rowData.fileId);
                  return false;
                });                   
            }            
        }

        /* Return cell new as required */
        return newCell;
    };

    /* Row creation hook */
    
    opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

        if (!rowData) return $newRow;  /* Quick way to skip header rows */

        let currUserID = optsIn.currUserID;
        let fileUserID = rowData.userID;

        let hasPatID = false;

        if (rowData.patID !== '' && parseInt(rowData.patID, 10) > 0) {
            hasPatID = true;
        }

        let isAuthor = currUserID == fileUserID;

        let canShowPatientSharing =
            optsIn.showOKToShareWithPatient == true &&
            isAuthor &&
            hasPatID;

        let canShowParentGuardianSharing =
            optsIn.showOKToShareWithParentGuardian == true &&
            isAuthor &&
            hasPatID;

        let ctrlRefDelete                = MBA.RestViewCommon.fnFindRowControl($newRow, 'recdeleteinlinestart');
        let ctrlRefFlagAsConfidential    = MBA.RestViewCommon.fnFindRowControl($newRow, 'flagAsConfidential');
        let ctrlRefFlagAsNonConfidential = MBA.RestViewCommon.fnFindRowControl($newRow, 'flagAsNonConfidential');

        let ctrlRefEnableSharingWithPatient = MBA.RestViewCommon.fnFindRowControl($newRow, 'enableSharingWithPatient');
        let ctrlRefDisableSharingWithPatient = MBA.RestViewCommon.fnFindRowControl($newRow, 'disableSharingWithPatient');
        let ctrlRefEnableSharingWithParentGuardian = MBA.RestViewCommon.fnFindRowControl($newRow, 'enableSharingWithParentGuardian');
        let ctrlRefDisableSharingWithParentGuardian = MBA.RestViewCommon.fnFindRowControl($newRow, 'disableSharingWithParentGuardian');
                  
        /* If this is not the user who created the file, remove controls they cannot use */
        if (!isAuthor) {
            $(ctrlRefDelete).remove();
            $(ctrlRefFlagAsConfidential).remove();
            $(ctrlRefFlagAsNonConfidential).remove();
        }

        /* Toggle visibility of flag as confidential controls */
        if (rowData.isConfidentialPracticeFile == true) {
            $(ctrlRefFlagAsConfidential).remove();
        }
        else {
            $(ctrlRefFlagAsNonConfidential).remove();
        }

        /* Patient sharing controls */
        if (!canShowPatientSharing) {
            $(ctrlRefEnableSharingWithPatient).remove();
            $(ctrlRefDisableSharingWithPatient).remove();
        }
        else {
            if (rowData.okToShareFileWithPatient == true) {
                $(ctrlRefEnableSharingWithPatient).remove();
            }
            else {
                $(ctrlRefDisableSharingWithPatient).remove();
            }
        }

        /* Parent/Guardian sharing controls */
        if (!canShowParentGuardianSharing) {
            $(ctrlRefEnableSharingWithParentGuardian).remove();
            $(ctrlRefDisableSharingWithParentGuardian).remove();
        }
        else {
            if (rowData.okToShareFileWithParentGuardian == true) {
                $(ctrlRefEnableSharingWithParentGuardian).remove();
            }
            else {
                $(ctrlRefDisableSharingWithParentGuardian).remove();
            }
        }

        return $newRow;
    };

    /* Create the rest view */

    $($me).MBA_RestView(opts);

    return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me) {

  let dataObj = _fnGetDataObj($me);

  let VALUE_CLIENT_ID    = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
  let VALUE_PAT_ID       = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
  let VALUE_FILE_CLASS   = dataObj.opts.fnGetFileClassValue(dataObj);
  let VALUE_DATE_RANGE   = dataObj.opts.fnGetDateRangeValue(dataObj);
  
  let NV_CLIENT_ID  = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID,  VALUE_CLIENT_ID);
  let NV_DATE_RANGE = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_DATE_RANGE, VALUE_DATE_RANGE);
  let NV_FILE_CLASS = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_FILE_CLASS, VALUE_FILE_CLASS);
  let NV_PAT_ID     = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PAT_ID,     VALUE_PAT_ID);

  /* Note: Don't use a loop here, keep it unrolled for performance reasons */

  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);      
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FILE_CLASS);    
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DATE_RANGE);
  $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);

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