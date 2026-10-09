; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.WorkInProgressSavePoints 
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     WorkInProgressSavePointsCommon (this is rendered dynamically server side), jQuery, jQueryUI, common, SessionHelper
 */
 
MBA.WorkInProgressSavePoints = (function ($) {

    'use strict';

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    const DATA_ATTR_READY_FOR_USE         = 'mba-wip-sp-ready-for-use';
    const DATA_ATTR_PREVIOUS_FORM_DATA    = 'mba-wip-sp-previous-form-data';
    const DATA_ATTR_OPTIONS               = 'mba-wip-sp-options';
    const REJECT_REASON_NOT_READY_FOR_USE = 'mba-wip-form-not-ready';
    const REJECT_REASON_NO_DATA_CHANGE    = 'mba-wip-form-data-no-change';

    const DEFAULT_OPTIONS_OBJ = {
          fnIsFormEmpty : function (formDataObj) { return false; }
        , autoSave: true
        , fieldNamesToIgnore:[]
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetOptionsObj = function (formRef) {
        let optsObj = $(formRef).data(DATA_ATTR_OPTIONS);
        return optsObj;
    }

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetOptionsObj = function (formRef, optsObjIn) {        
       let optsObj = $.extend({}, DEFAULT_OPTIONS_OBJ, optsObjIn);
        $(formRef).data(DATA_ATTR_OPTIONS, optsObj);
        return optsObj;
    }

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetReadyForUseFlag = function (formRef) {
      let readyForUse = $(formRef).data(DATA_ATTR_READY_FOR_USE);
      if (!MBA.ComponentCommon.fnHasValue(readyForUse)) return false;
      return readyForUse;
    }

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetReadyForUseFlag = function (formRef, readyForUse) {
        $(formRef).data(DATA_ATTR_READY_FOR_USE, readyForUse);        
        return readyForUse;
    }

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetPreviousFormDataJSON = function (formRef) {
        let formDataJSON =  $(formRef).data(DATA_ATTR_PREVIOUS_FORM_DATA);
        return formDataJSON;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetPreviousFormDataJSON = function (formRef, formDataJSON) {
       $(formRef).data(DATA_ATTR_PREVIOUS_FORM_DATA, formDataJSON);
       return formDataJSON;        
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetCurrentFormDataJSON = function (formRef) {
        let opts = _fnGetOptionsObj(formRef);        
        let frmObj = MBA.ComponentCommon.fnFormToObjExceptForFieldNames(formRef, opts.fieldNamesToIgnore);        
        var json = JSON.stringify(frmObj);
        return json;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnArePreviousCurrentFormDataJSONTheSame = function (prevFormDataJSON, currFormDataJSON) {        
      let retValue = false;
      let prevFormDataHasValue = MBA.ComponentCommon.fnHasValue(prevFormDataJSON);
      let currFormDataHasValue = MBA.ComponentCommon.fnHasValue(currFormDataJSON);
      if      ((prevFormDataHasValue == false) && (currFormDataHasValue == false)) retValue = true;
      else if ((prevFormDataHasValue == true)  && (currFormDataHasValue == false)) retValue = false;
      else if ((prevFormDataHasValue == false) && (currFormDataHasValue == true))  retValue = false;
      else if ((prevFormDataHasValue == true)  && (currFormDataHasValue == true))  retValue = (prevFormDataJSON === currFormDataJSON);
      else retValue = false;      
      return retValue;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnPrepareBaseReqObj = function (formID) {
        let reqObj = {};
        reqObj[MBA.WorkInProgressSavePointsCommon.parmNameRequestResource] = MBA.WorkInProgressSavePointsCommon.requestResource;
        reqObj[MBA.WorkInProgressSavePointsCommon.parmNameSavePointName]   = formID;
        return reqObj;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnCreateFormRefObj = function (formID) {
        return new Promise((resolve, reject) => {
            if (!formID) reject(new Error('Form ID required'));
            let formRefObj = {};
            formRefObj.formID = formID;
            formRefObj.formRef = $('#' + formID);
            resolve(formRefObj);
        });
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnCheckIfFormDataHasChanged = function (formRef) {        
      let retObj = {};
      retObj.prevFormJSON = _fnGetPreviousFormDataJSON(formRef);
      retObj.currFormJSON = _fnGetCurrentFormDataJSON(formRef);
      retObj.isDataTheSame = _fnArePreviousCurrentFormDataJSONTheSame(retObj.prevFormJSON, retObj.currFormJSON);
      return retObj;         
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnPrepareSaveReqDataJSON = function (formRefObj) {
        return new Promise((resolve, reject) => {
            let readyForUse = _fnGetReadyForUseFlag(formRefObj.formRef);
            if (!readyForUse) reject(REJECT_REASON_NOT_READY_FOR_USE);
            let retObj = _fnCheckIfFormDataHasChanged(formRefObj.formRef);
            if (retObj.isDataTheSame === true) reject(REJECT_REASON_NO_DATA_CHANGE);
            _fnSetPreviousFormDataJSON(formRefObj.formRef, retObj.currFormJSON);
            let reqObj = _fnPrepareBaseReqObj(formRefObj.formID);
            reqObj[MBA.WorkInProgressSavePointsCommon.parmNameSavedDataJSON] = retObj.currFormJSON;
            let reqJSON = JSON.stringify(reqObj);
            resolve(reqJSON);                
        });
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnPrepareDeleteReqDataJSON = function (formRefObj) {
        return new Promise((resolve, reject) => {
            let readyForUse = _fnGetReadyForUseFlag(formRefObj.formRef);
            if (!readyForUse) reject(REJECT_REASON_NOT_READY_FOR_USE);
            let retObj = _fnCheckIfFormDataHasChanged(formRefObj.formRef);            
            _fnSetPreviousFormDataJSON(formRefObj.formRef, retObj.currFormJSON);
            let reqObj = _fnPrepareBaseReqObj(formRefObj.formID);
            let reqJSON = JSON.stringify(reqObj);
            resolve(reqJSON);
        });
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSaveFromForm = function (formID) {

        if (MBA.WorkInProgressSavePointsCommon.saveEnabled === false) {
            return new Promise((resolve, reject) => {
                resolve({});
            });
        };

        return new Promise((resolve, reject) => {
            _fnCreateFormRefObj(formID)                
                .then(formRefObj => _fnPrepareSaveReqDataJSON(formRefObj))
                .then(reqJSON => MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(MBA.WorkInProgressSavePointsCommon.webSvcSaveOrReplaceUrl, reqJSON, MBA.WorkInProgressSavePointsCommon.sessionExpiredUrl))
                .then(responseData => resolve(responseData))
                .catch(reason => {
                    if      (reason == REJECT_REASON_NOT_READY_FOR_USE) {}
                    else if (reason == REJECT_REASON_NO_DATA_CHANGE)    {}
                    else {throw new Error(reason);}
                });
        });
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnDeleteFromForm = function (formID) {

        if (MBA.WorkInProgressSavePointsCommon.deleteEnabled === false) {
            return new Promise((resolve, reject) => {
                resolve({});
            });
        };
        
        MBA.WorkInProgressSavePointsCommon.saveEnabled = false;

        return new Promise((resolve, reject) => {
            _fnCreateFormRefObj(formID)
                .then(formRefObj => _fnPrepareDeleteReqDataJSON(formRefObj))
                .then(reqJSON => MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(MBA.WorkInProgressSavePointsCommon.webSvcDeleteUrl, reqJSON, MBA.WorkInProgressSavePointsCommon.sessionExpiredUrl))
                .then(responseData => {
                    MBA.WorkInProgressSavePointsCommon.saveEnabled = true;
                    resolve(responseData);
                })
                .catch(reason => {
                    MBA.WorkInProgressSavePointsCommon.saveEnabled = true;
                    if (reason == REJECT_REASON_NOT_READY_FOR_USE) { }
                    else {throw new Error(reason);}
                });
        });
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnDetermineWhatAutoUpdateAction = function (formID) {
        return new Promise((resolve, reject) => {
            _fnCreateFormRefObj(formID)
                .then(formRefObj => {
                    let retObj = _fnCheckIfFormDataHasChanged(formRefObj.formRef);
                    if (retObj.isDataTheSame === true) reject(REJECT_REASON_NO_DATA_CHANGE);
                    let opts = _fnGetOptionsObj(formRefObj.formRef);
                    let formDataObj = MBA.ComponentCommon.fnFormToObj(formRefObj.formRef);
                    let isFormEmpty = opts.fnIsFormEmpty(formDataObj);
                    let fnAutoUpdateAction = _fnSaveFromForm;
                    if (isFormEmpty === true) {
                        fnAutoUpdateAction = _fnDeleteFromForm;
                    }
                    resolve(fnAutoUpdateAction);
                });
                
        });
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnAutoSave = function (formID) {
        return new Promise((resolve, reject) => {
            _fnDetermineWhatAutoUpdateAction(formID).then(fnAutoUpdateAction => {
                fnAutoUpdateAction(formID);
            }).then(responseData => {
                resolve(responseData);
            }).catch(reason => {
                if   (reason == REJECT_REASON_NO_DATA_CHANGE) { }
                else { throw new Error(reason); }
            });
        });
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetSaveEnabledFlag = function (value) { MBA.WorkInProgressSavePointsCommon.saveEnabled = value; }

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetDeleteEnabledFlag = function (value) { MBA.WorkInProgressSavePointsCommon.deleteEnabled = value; }

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnEnableSave = function () { _fnSetSaveEnabledFlag(true);}

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnDisableSave = function () { _fnSetSaveEnabledFlag(false); }

    /*------------------------------------------------------------------------------------------------------------------------------------------*/
    
    let _fnEnableDelete = function () { _fnSetDeleteEnabledFlag(true); }

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnDisableDelete = function () { _fnSetDeleteEnabledFlag(false); }

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnInit = function (formID, optsObj) {
        return new Promise((resolve, reject) => {
            _fnCreateFormRefObj(formID).then(formRefObj => {
                let opts = _fnSetOptionsObj(formRefObj.formRef, optsObj);
                let currFormJSON = _fnGetCurrentFormDataJSON(formRefObj.formRef);
                _fnSetPreviousFormDataJSON(formRefObj.formRef, currFormJSON);
                _fnSetReadyForUseFlag(formRefObj.formRef, true);
                if (opts.autoSave === true) {
                    MBA.SessionHelperCommon.fnExecuteCustomTasks = function () {
                        _fnAutoSave (formID);
                    };
                };
                resolve(currFormJSON);
            });
        });
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
          fnInit           : _fnInit
        , fnSaveFromForm   : _fnSaveFromForm
        , fnDeleteFromForm : _fnDeleteFromForm
        , fnEnableSave     : _fnEnableSave
        , fnDisableSave    : _fnDisableSave
        , fnEnableDelete   : _fnEnableDelete
        , fnDisableDelete  : _fnDisableDelete

    };
        
})(jQuery);