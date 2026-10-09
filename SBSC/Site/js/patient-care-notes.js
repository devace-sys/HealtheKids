; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PatientCareNotesCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.PatientCareNotesCommon = (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME = 'Patient Care Notes Common Methods';
    const _THIS_NS = 'mba-patient-care-notes'
    const _JQ_DATA_NAME = 'jq-' + _THIS_NS;
    const _DATA_ATTR_BASE = 'data-' + _THIS_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
          PARM_CLIENT_ID: 'clientid'
        , PARM_GRP_SVC_CLS_NME_ID: 'groupserviceclassnameid'
        , PARM_PATIENT_ID: 'patid'
        , containerCtrlID: ''
        , sessionTimeOutUrl: ''
        , baseUrlView: ''
        , defaultPageRowOrder: ''
        , baseUrlSave: ''
        , baseUrlLoad: ''
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

    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnLoadNotes = function ($me) {

        let dataObj = _fnGetDataObj($me);

        let requestObj = {};

        requestObj[dataObj.opts.PARM_CLIENT_ID]          = $('#' + dataObj.opts.PARM_CLIENT_ID).val();
        requestObj[dataObj.opts.PARM_GRP_SVC_CLS_NME_ID] = $('#' + dataObj.opts.PARM_GRP_SVC_CLS_NME_ID).val();
        requestObj[dataObj.opts.PARM_PATIENT_ID]         = $('#' + dataObj.opts.PARM_PATIENT_ID).val();

        let requestJSON = JSON.stringify(requestObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlLoad, requestJSON, dataObj.opts.sessionTimeOutUrl)
            .then(responseData => {
                let objPCN = responseData.rawData.entity;
                $(dataObj.opts.ctrlNote).val((objPCN == null) ? '' : objPCN.note);
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
            });

        return;
    }

    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSaveOrUpdateNotesData = function ($me) {

        let dataObj = _fnGetDataObj($me);        

        let requestObj = {};

        requestObj[dataObj.opts.PARM_CLIENT_ID]          = $('#' + dataObj.opts.PARM_CLIENT_ID).val();
        requestObj[dataObj.opts.PARM_GRP_SVC_CLS_NME_ID] = $('#' + dataObj.opts.PARM_GRP_SVC_CLS_NME_ID).val();
        requestObj[dataObj.opts.PARM_PATIENT_ID]         = $('#' + dataObj.opts.PARM_PATIENT_ID).val();
        requestObj["note"]                               = $(dataObj.opts.ctrlNote).val();
        requestObj["savetype"]                           = "";

        let requestJSON = JSON.stringify(requestObj);
        
        let $waitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner(dataObj.opts.ctrlButSaveNotes);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlSave, requestJSON, dataObj.opts.sessionTimeOutUrl)
            .then(responseData => {
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner(dataObj.opts.ctrlButSaveNotes, $waitingIcon);                               
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});                
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner(dataObj.opts.ctrlButSaveNotes, $waitingIcon);
            });

        return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnmanageHasDataOnInput = function ($me) {

        let dataObj = _fnGetDataObj($me);

        $(dataObj.opts.ctrlNote).on('input', function () {
            if ($(this).val().trim() !== '') {
                $(dataObj.opts.ctrlButSaveNotes).addClass('hasdata');
            } else {
                $(dataObj.opts.ctrlButSaveNotes).removeClass('hasdata');
            }
        });
    }

    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnclearHasDataOnFocusOut = function ($me) {

        let dataObj = _fnGetDataObj($me);

        $(dataObj.opts.ctrlNote).on('blur', function () {

            $(dataObj.opts.ctrlButSaveNotes).removeClass('hasdata');

        });
    }
    /*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnclearHasDataOnClick = function ($me) {

        let dataObj = _fnGetDataObj($me);

        $(dataObj.opts.ctrlButSaveNotes).click(function () {
            $(dataObj.opts.ctrlButSaveNotes).removeClass('hasdata');
        });
    }
    
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

        /* Title */
        let $divLabel = $('<div class="visit-notes-label">Pre-Care Notes</div>');

        $($me).append($divLabel);
        
        let $divRow = $('<div class="row"></div>');
        let $divSaveButtom = $('<div class="col-1"></div>');
        let $divTextarea = $('<div class="col-11"></div>');

        /* Save button */

        let $ctrlButSaveNotes = $('<button class="but-pat-visit-pre-care-savenotes" type="button" title="Click here to save the note"><i class="fa fa-save fa-2x"/></button>');
        $($ctrlButSaveNotes).attr("id", butSaveID);
        $($divSaveButtom).append($ctrlButSaveNotes);
        opts.ctrlButSaveNotes = $ctrlButSaveNotes;

        /* Notes Textare*/
        let $ctrlNote = $('<textarea title="Patient Care Notes" class="txtarea-pat-visit-pre-care-note" placeholder="Enter notes"></textarea>');
        $($ctrlNote).attr("id", txtNotesID);
        $($divTextarea).append($ctrlNote);
        opts.ctrlNote = $ctrlNote;
        
        $($divRow).append($divSaveButtom);
        $($divRow).append($divTextarea);

        $($me).append($divRow);        
        
        /* Wire up save */

        $($ctrlButSaveNotes).on('click', function (e) {
            _fnSaveOrUpdateNotesData($me);
        });        
        
        /* Save opts */

        dataObj.opts = opts;
        
        /* Save our data object.  This will be used for option calls */

        $($me).data(_JQ_DATA_NAME, dataObj);

        /*Loading existing notes if any*/
        _fnLoadNotes($me);
        
        /*Adding some effects*/
        _fnmanageHasDataOnInput($me);
        _fnclearHasDataOnFocusOut($me);
        _fnclearHasDataOnClick($me);
    }; /*_fnSetup */

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
          fnSetup: _fnSetup
    };

})(jQuery);