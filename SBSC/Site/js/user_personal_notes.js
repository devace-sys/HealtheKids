; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.UserPersonalNotesCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.UserPersonalNotesCommon = (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME = 'User Personal Notes Common Methods';
    const _THIS_NS = 'mba-patient-care-notes'
    const _JQ_DATA_NAME = 'jq-' + _THIS_NS;
    const _DATA_ATTR_BASE = 'data-' + _THIS_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
        PARM_NAME_CLIENT_ID: ''
        , PARM_NAME_PAT_ID: ''
        , PARM_NAME_PRAC_ID: ''
        , PARM_NAME_NOTENAMESPACE: ''
        , PARM_NAME_NOTESOURCE: ''
        , PARM_NAME_ACTIVE: ''
        , containerCtrlID: ''
        , sessionTimeOutUrl: ''
        , baseUrlView: ''
        , defaultPageRowOrder: ''
        , baseUrlSave: ''
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

        opts.enableScrollView = optsIn.enableScrollView;
        opts.scrollViewUseCustomHeight = optsIn.scrollViewUseCustomHeight;
        opts.scrollViewCustomHeight = optsIn.scrollViewCustomHeight;
        opts.enableRowNumbers = false; /* Turn off row numbers */
        opts.sessionTimeOutUrl = optsIn.sessionTimeOutUrl;
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.autoHidePageControls = optsIn.autoHidePageControls;

        opts.loadModeView = 'rest';
        opts.baseUrlView = optsIn.baseUrlView
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = optsIn.defaultPageRowOrder;

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
            name: 'dateStr'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });

        opts.fieldDefinitions.push({
            name: 'noteText'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });

        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) {
            /* Table body, new records */
            if ((subsection === 103) && (rowtype === 4)) {
                /* Field def after end date */
                if (fieldDefinition.name === 'dateStr') {
                    newCellValueElem.css('font-weight', 'bold');
                }

                if (fieldDefinition.name === 'noteText') {
                    newCellValueElem.css('font-style', 'italic');
                }
            }

            return newCell;
        }
        /* Create the rest view */

        $($me).MBA_RestView(opts);

        return;
    };

    function _fnSaveOrUpdateNotesData($me) {
        let dataObj = _fnGetDataObj($me);

        let requestObj = {};

        requestObj[dataObj.opts.PARM_NAME_CLIENT_ID] = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        requestObj[dataObj.opts.PARM_NAME_PAT_ID] = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
        requestObj[dataObj.opts.PARM_NAME_PRAC_ID] = $('#' + dataObj.opts.PARM_NAME_PRAC_ID).val();
        requestObj[dataObj.opts.PARM_NAME_NOTENAMESPACE] = $('#' + dataObj.opts.PARM_NAME_NOTENAMESPACE).val();
        requestObj[dataObj.opts.PARM_NAME_NOTESOURCE] = $('#' + dataObj.opts.PARM_NAME_NOTESOURCE).val();
        requestObj["editDelReason"] = "";
        requestObj["validaterec"] = "0";
        requestObj["notetext"] = $(dataObj.opts.ctrlNote).val();
        requestObj["savetype"] = "1";
        requestObj["recid"] = "";

        let requestJSON = JSON.stringify(requestObj);

        let $waitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner(dataObj.opts.ctrlButSaveNotes);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlSave, requestJSON, dataObj.opts.sessionTimeOutUrl)
            .then(responseData => {
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner(dataObj.opts.ctrlButSaveNotes, $waitingIcon);
                _updateAdditionalViewParameterValuesAndRequestViewFromServer($me);
                $(dataObj.opts.ctrlNote).val('');
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner(dataObj.opts.ctrlButSaveNotes, $waitingIcon);
            });

        return;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me) {

        let dataObj = _fnGetDataObj($me);

        let VALUE_CLIENT_ID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let VALUE_PAT_ID = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
        let VALUE_PRAC_ID = $('#' + dataObj.opts.PARM_NAME_PRAC_ID).val();
        let VALUE_NOTE_NAMESPACE = $('#' + dataObj.opts.PARM_NAME_NOTENAMESPACE).val();
        let VALUE_NOTE_SOURCE = $('#' + dataObj.opts.PARM_NAME_NOTESOURCE).val();
        let VALUE_ACTIVE = '1';

        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_PAT_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PAT_ID, VALUE_PAT_ID);
        let NV_PRAC_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PRAC_ID, VALUE_PRAC_ID);
        let NV_NOTENAMESPACE = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_NOTENAMESPACE, VALUE_NOTE_NAMESPACE);
        let NV_NOTESOURCE = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_NOTESOURCE, VALUE_NOTE_SOURCE);
        let NV_ACTIVE = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE, VALUE_ACTIVE);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_NOTENAMESPACE);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_NOTESOURCE);
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

        /*Creating uniques IDs for Save Buttom and textarea*/
        let butSaveID = elementid + '-butsavenotes';
        let txtNotesID = elementid + '-txtprecarenotes';

        /* Create content */
        $($me).addClass('container-fluid');
        
        let $divRow = $('<div class="row mb-5"></div>');
        let $divSaveButtom = $('<div class="col-1"></div>');
        let $divTextarea = $('<div class="col-11"></div>');

        /* Save button */
        let $ctrlButSaveNotes = $('<button class="btn mt-3" type="button" title="Click here to save the note"><i class="fa fa-save fa-2x"/></button>');
        $($ctrlButSaveNotes).attr("id", butSaveID);
        $($divSaveButtom).append($ctrlButSaveNotes);
        opts.ctrlButSaveNotes = $ctrlButSaveNotes;

        /* Notes Textarea*/
        let $ctrlNote = $('<textarea title="User Personal Notes" class="form-control w-100" placeholder="Enter notes"></textarea>');
        $($ctrlNote).attr("id", txtNotesID);
        $($divTextarea).append($ctrlNote);
        opts.ctrlNote = $ctrlNote;
        
        $($divRow).append($divTextarea, $divSaveButtom);
        //$($divRow).append($divTextarea);

        $($me).append($divRow);        
        
        /* Wire up save */

        $($ctrlButSaveNotes).on('click', function (e) {
            _fnSaveOrUpdateNotesData($me);
        });

        /* Save opts */

        dataObj.opts = opts;

        /* Create rest view */

        let $restViewCtrl = $me;
        dataObj.restViewCtrl = $restViewCtrl;
        _createRestView($restViewCtrl, opts);

        /* Get reference to container control to listen for events on */

        let $containerCtrl = $('#' + opts.containerCtrlID);
        dataObj.containerCtrl = $containerCtrl;

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