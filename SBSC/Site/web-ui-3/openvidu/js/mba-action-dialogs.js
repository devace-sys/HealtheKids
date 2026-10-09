/* Requires  */

var MBA = (MBA || {});

MBA.actionDialogs = (function ($) {

    'use strict';

    /***************************************************************************
     * _openAlertDialog*/
    /**
     * 
     * 
     ***************************************************************************/

    var _openAlertDialog = function (title, message) {
	   
	   var _diaID           = MBA.util.createNewUUID();
       var _diaButtonsClose = [ { text: 'Close', click: function () { MBA.responsizeDialog.close(_diaID);}}];	
	   var _diaButtons      = {};
	   
	   /*============================================================
        * Open dialog
        *============================================================*/
       
       MBA.responsizeDialog.createNew(
            _diaID
          , title
          , message
          , 50
          , 50
          , 1
          , 0
          , 1
          , null
          , null
          , null
          , _diaButtonsClose);
    };

    /***************************************************************************
     * _openConfirmDialog */
    /**
     * 
     * 
     ***************************************************************************/

    var _openConfirmDialog = function (title, message, noBtnText, yesBtnText, fnOnNo, fnOnYes) {

        var _diaID = MBA.util.createNewUUID();
        var _diaButtons = [
              { text: noBtnText    , click: function () { MBA.responsizeDialog.close(_diaID); fnOnNo();     } }
            , { text: yesBtnText   , click: function () { MBA.responsizeDialog.close(_diaID); fnOnYes();    } }
        ];

        /*============================================================
         * Open dialog
         *============================================================*/

        MBA.responsizeDialog.createNew(
            _diaID
            , title
            , message
            , 50
            , 50
            , 1
            , 0
            , 1
            , null
            , null
            , null
            , _diaButtons);
    };
  
    /***************************************************************************
     * _openViewHtmlContent */
    /**
     * 
     * 
     ***************************************************************************/

    var _openViewHtmlContent = function (title, content) {
	   
	   var _diaID           = MBA.util.createNewUUID();
       var _diaButtonsClose = [ { text: 'Close', click: function () { MBA.responsizeDialog.close(_diaID);}}];	
	   var _diaButtons      = {};
	   
	   /*============================================================
        * Open dialog
        *============================================================*/
       
       MBA.responsizeDialog.createNew(
            _diaID
          , title
          , content
          , 95
          , 85
          , 0
          , 0
          , 1
          , null
          , null
          , null
          , _diaButtonsClose);
	};
 
    /***************************************************************************
     * openSaveFormDialog */
    /**
     * 
     * 
     ***************************************************************************/

    var _openSaveFormDataDialog = function (formID, submitButtonID, diaTitle, saveType, fnCallSaveMethod, fnStart, fnOnGoBack, fnOnProceedWithSave, fnOnGoBackAndFix) {

        /*============================================================
         * If any of the callbacks are not defined replace them with
         * empty calls
         *============================================================*/

        if (!fnStart) fnStart = function () { };
        if (!fnOnGoBack) fnOnGoBack = function () { };
        if (!fnOnProceedWithSave) fnOnProceedWithSave = function () { };
        if (!fnOnGoBackAndFix) fnOnGoBackAndFix = function () { };

        /*============================================================
         * Create selectors for parameters passed in
         *============================================================*/

        var submitButtonSel = '#' + submitButtonID;
        var formSel = '#' + formID;

        /*============================================================
         * Create unique ids and selectors
         *============================================================*/

        let diaID = MBA.util.createNewUUID();
        let diaSel = '#' + diaID;
        let instructionsContID = MBA.util.createNewUUID();
        let instructionsContSel = '#' + instructionsContID;
        let statusListContID = MBA.util.createNewUUID();
        let statusListContSel = '#' + statusListContID;

        /*============================================================
         * Define dialog event handlers  
         *============================================================*/

        var _fnBeforeDiaOpen = function () { };
        var _fnBeforeDiaClose = function () { };

        /*============================================================
         * Define dialog click button handlers
         *============================================================*/

        var _fnGoBack = function () { };
        var _fnProceed = function () { };

        /*============================================================
         * Define other handlers
         *============================================================*/

        var _fnCallSaveMethodThenUpdateOrCloseDialog = function (formID, saveType, validateRec) { };
        var _fnServerSaysOkToProceed = function (formID, saveType, validateRec, responseData, instructions) { };
        var _fnServerSaysGoBackAndFix = function (formID, saveType, validateRec, responseData, instructions) { };
        var _fnUpdateOrCloseDialog = function (formID, saveType, validateRec, responseData) { };

        /*============================================================
         * Define dialog buttons and assign handlers
         *============================================================*/

        let _diaButtonsGoBack = [
            { text: 'Go Back', click: function () { _fnGoBack(); } }
        ];

        let _diaButtonsGoBackProceed = [
            { text: 'Go Back', click: function () { _fnGoBack(); } }
            , { text: 'Proceed', click: function () { _fnProceed(); } }
        ];

        /*============================================================
         * Define initial code for handlers
         *============================================================*/

        _fnServerSaysOkToProceed = function (formID, saveType, validateRec, responseData, instructions) {
            /* Validating record */
            if (validateRec === true) {
                /* Replace dialog instructions */
                $(instructionsContSel).text(instructions);
                /* Redefine handler for proceed button */
                _fnProceed = function () { _fnCallSaveMethodThenUpdateOrCloseDialog(formID, saveType, false); };
                /* Replace dialog buttons*/
                MBA.responsizeDialog.replaceButtons(diaID, _diaButtonsGoBackProceed);
            }
            /* Saving record */
            else {
                MBA.responsizeDialog.close(diaID);
            }
        };

        _fnServerSaysGoBackAndFix = function (formID, saveType, validateRec, responseData, instructions) {
            /* Replace instructions */
            $(instructionsContSel).text(instructions);
            /* Replace dialog buttons */
            MBA.responsizeDialog.replaceButtons(diaID, _diaButtonsGoBack);
        };

        _fnUpdateOrCloseDialog = function (formID, saveType, validateRec, responseData) {

            $(statusListContSel).html('');
            let $ul = MBA.util.detailObjsToUnorderedListElement(responseData.details);
            $(statusListContSel).append($ul);
            $(instructionsContSel).text('');

            if (responseData.status === MBA.util.RETURN_CODE.SUCCESS) {
                _fnServerSaysOkToProceed(formID, saveType, validateRec, responseData, 'Validation completed.  Please select "Proceed" to continue.');
            }
            else if (responseData.status === MBA.util.RETURN_CODE.INFO) {
                _fnServerSaysOkToProceed(formID, saveType, validateRec, responseData, 'Validation completed.  Please select "Proceed" to continue.');
            }
            else if (responseData.status === MBA.util.RETURN_CODE.WARNING) {
                _fnServerSaysOkToProceed(formID, saveType, validateRec, responseData, 'Validation completed.  Please review the warnings listed below and if you do not have any concerns then select "Proceed" to continue.');
            }
            else {
                _fnServerSaysGoBackAndFix(formID, saveType, validateRec, responseData, 'Validation completed.  Please review the problems listed below, correct them if possible, and then retry.');
            }
        };

        _fnCallSaveMethodThenUpdateOrCloseDialog = function (formID, saveType, validateRec) {
            if (validateRec === false) {
                /* Final save -- Get rid of buttons */
                MBA.responsizeDialog.replaceButtons(diaID, {});
            }
            /* Validate and final save calls */
            fnCallSaveMethod(formID, saveType, validateRec).then(responseData => {
                _fnUpdateOrCloseDialog(formID, saveType, validateRec, responseData);
            });
        };

        _fnBeforeDiaOpen = function () {
            fnStart();
            $(submitButtonSel).hide();
            _fnCallSaveMethodThenUpdateOrCloseDialog(formID, saveType, true);
        };

        _fnBeforeDiaClose = function () {
            $(submitButtonSel).show();
        };

        _fnGoBack = function ()  { MBA.responsizeDialog.close(diaID); };
        _fnProceed = function () { MBA.responsizeDialog.close(diaID); };

        /*============================================================
         * Define dialog content
         *============================================================*/

        let diaContent = '<div class="mba-dialog-save-form-section mba-dialog-save-form-section-instructions" id="' + instructionsContID + '"></div><div class="mba-dialog-save-form-section mba-dialog-save-form-section-details" id="' + statusListContID + '"></div>';

        /*============================================================
         * Open dialog
         *============================================================*/

        MBA.responsizeDialog.createNew(
            diaID
            , diaTitle
            , diaContent
            , 80
            , 80
            , 1
            , 0
            , 1
            , null
            , _fnBeforeDiaOpen
            , _fnBeforeDiaClose
            , _diaButtonsGoBack);
    }

    return {
        alert: _openAlertDialog
      , confirm: _openConfirmDialog
	  , openViewHtmlContent: _openViewHtmlContent
	  , openSaveFormDataDialog: _openSaveFormDataDialog
    };

})(jQuery);
