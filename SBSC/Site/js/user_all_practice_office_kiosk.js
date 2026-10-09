; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PracticeOfficeKioskCommon 
 * @memberof     MBA
 * @summary      Static methods used on a screen
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.PracticeOfficeKioskCommon = (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME    = 'Practice Office Kiosk Common Methods';
    const _THIS_NS      = 'mba-practice-office-kiosk'
    const _JQ_DATA_NAME = 'jq-' + _THIS_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
          PARM_NAME_CLIENT_ID: ''
        , PARM_NAME_GROUP_SVC_CLASS_NAME_ID:''
        , PARM_NAME_SITE_ID:''
        , PARM_NAME_STUDENT_ID:''
        , PARM_NAME_PRACTICE_OFFICE_VISIT_REASON_ID:''
        , PARM_NAME_PRACTICE_OFFICE_VISIT_REASON_NOTES:''
        , CTRL_ID_BUT_PRACTICE_OFFICE_CHECK_IN_SUBMIT: ''
        , CTRL_ID_BUT_PRACTICE_OFFICE_CHECK_IN_CLEAR: ''
        , checkInFromKioskUrl:''
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

    let _fnLockCheckInForm = function (elementid) {
        let $me     = _fnGetMe(elementid);
        let dataObj = $($me).data(_JQ_DATA_NAME);
        if (!dataObj) return;
        $(dataObj.ctrlInpStudentID).MBA_DataEntryBox('lock');
        $(dataObj.ctrlInpReasonForVisitID).MBA_DataEntryBox('lock');
        $(dataObj.ctrlTAReasonForVisitNotes).MBA_DataEntryBox('lock');
        MBA.ComponentCommon.fnDisableElement(dataObj.ctrlButCheckInClear);
        let waitingIconRef = MBA.ComponentCommon.fnElemDisableAndAddSpinner(dataObj.ctrlButCheckInSubmit);
        return waitingIconRef;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnUnLockCheckInForm = function (elementid, waitingIconRef) {
        let $me = _fnGetMe(elementid);
        let dataObj = $($me).data(_JQ_DATA_NAME);
        if (!dataObj) return;
        $(dataObj.ctrlInpStudentID).MBA_DataEntryBox('unlock');
        $(dataObj.ctrlInpReasonForVisitID).MBA_DataEntryBox('unlock');
        $(dataObj.ctrlTAReasonForVisitNotes).MBA_DataEntryBox('unlock');
        MBA.ComponentCommon.fnEnableElement(dataObj.ctrlButCheckInClear);
        MBA.ComponentCommon.fnElemEnableAndRemoveSpinner(dataObj.ctrlButCheckInSubmit, waitingIconRef);
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    
    let _fnClearCheckInForm = function (elementid) {
        let $me     = _fnGetMe(elementid);
        let dataObj = $($me).data(_JQ_DATA_NAME);
        if (!dataObj) return;
	    $(dataObj.ctrlInpStudentID).MBA_DataEntryBox('clearValue');
        $(dataObj.ctrlInpReasonForVisitID).MBA_DataEntryBox('clearValue');
        $(dataObj.ctrlTAReasonForVisitNotes).MBA_DataEntryBox('clearValue');
	}

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnCreateRequestObjForCheckIn = function (dataObj) {

        let requestObj = {};

        requestObj[dataObj.opts.PARM_NAME_CLIENT_ID]                          = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        requestObj[dataObj.opts.PARM_NAME_GROUP_SVC_CLASS_NAME_ID]            = $('#' + dataObj.opts.PARM_NAME_GROUP_SVC_CLASS_NAME_ID).val();
        requestObj[dataObj.opts.PARM_NAME_SITE_ID]                            = $('#' + dataObj.opts.PARM_NAME_SITE_ID).val();

        requestObj[dataObj.opts.PARM_NAME_STUDENT_ID]                         = $(dataObj.ctrlInpStudentID).MBA_DataEntryBox('getValue');
        requestObj[dataObj.opts.PARM_NAME_PRACTICE_OFFICE_VISIT_REASON_ID]    = $(dataObj.ctrlInpReasonForVisitID).MBA_DataEntryBox('getValue');
        requestObj[dataObj.opts.PARM_NAME_PRACTICE_OFFICE_VISIT_REASON_NOTES] = $(dataObj.ctrlTAReasonForVisitNotes).MBA_DataEntryBox('getValue');

        /*
        requestObj[dataObj.opts.PARM_NAME_STUDENT_ID] = $('#' + dataObj.opts.PARM_NAME_STUDENT_ID).val();
        requestObj[dataObj.opts.PARM_NAME_PRACTICE_OFFICE_VISIT_REASON_ID]    = $('#' + dataObj.opts.PARM_NAME_PRACTICE_OFFICE_VISIT_REASON_ID).val();
        requestObj[dataObj.opts.PARM_NAME_PRACTICE_OFFICE_VISIT_REASON_NOTES] = $('#' + dataObj.opts.PARM_NAME_PRACTICE_OFFICE_VISIT_REASON_NOTES).val();
        */

        return requestObj;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnVerifyCheckInValues = function (dataObj, requestObj) {
        if (!MBA.ComponentCommon.fnHasValue(requestObj[dataObj.opts.PARM_NAME_STUDENT_ID])) return false;
        if (!MBA.ComponentCommon.fnHasValue(requestObj[dataObj.opts.PARM_NAME_PRACTICE_OFFICE_VISIT_REASON_ID])) return false;
        if (requestObj[dataObj.opts.PARM_NAME_STUDENT_ID] == '') return false;
        if (requestObj[dataObj.opts.PARM_NAME_PRACTICE_OFFICE_VISIT_REASON_ID] == '') return false;        
        return true;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    	
    let _fnCheckIn = function (elementid) {
        
        let $me = _fnGetMe(elementid);        
        let dataObj = $($me).data(_JQ_DATA_NAME);
        if (!dataObj) return;
        let requestObj = _fnCreateRequestObjForCheckIn(dataObj);
        if (!_fnVerifyCheckInValues(dataObj, requestObj)) {
            MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Please Complete The Form', 'Please enter a student id and select a reason.', {});
            return;
        }

        let requestJSON = JSON.stringify(requestObj);
        let waitingIconRef = _fnLockCheckInForm(elementid);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.checkInFromKioskUrl, requestJSON, null)
            .then(responseData => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('All Set!', 'You have been checked in.', {});
                _fnUnLockCheckInForm(elementid, waitingIconRef);
                _fnClearCheckInForm(elementid);
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', 'There was a problem checking you in.  Please ask the school staff for assistance.', {});
                _fnUnLockCheckInForm(elementid, waitingIconRef);
                _fnClearCheckInForm(elementid);
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

		/* Get references */
		
        dataObj.ctrlInpStudentID          = $('#' + opts.PARM_NAME_STUDENT_ID);
        dataObj.ctrlInpReasonForVisitID   = $('#' + opts.PARM_NAME_PRACTICE_OFFICE_VISIT_REASON_ID);
        dataObj.ctrlTAReasonForVisitNotes = $('#' + opts.PARM_NAME_PRACTICE_OFFICE_VISIT_REASON_NOTES);
        dataObj.ctrlButCheckInClear       = $('#' + opts.CTRL_ID_BUT_PRACTICE_OFFICE_CHECK_IN_CLEAR);
        dataObj.ctrlButCheckInSubmit      = $('#' + opts.CTRL_ID_BUT_PRACTICE_OFFICE_CHECK_IN_SUBMIT);

        /* Save our data object.  This will be used for option calls */

        $($me).data(_JQ_DATA_NAME, dataObj);
    
    }; /*_fnSetup */

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
          fnSetup: _fnSetup
		, fnClearCheckInForm : _fnClearCheckInForm
		, fnCheckIn : _fnCheckIn        
    };

})(jQuery);