var SpEdCare = (SpEdCare || {});

SpEdCare.svcrecOnDos = (function ($) {

'use strict';

/*#################################################################################################
  #
  #                                  Global Data Structures
  #
  #################################################################################################*/

var _opts = {};
var _SvcRecs  = new Map();
var _initMode         = true;

/*#################################################################################################
  #
  #                                  Global Variables
  #
  #################################################################################################*/

// used for dertermining the notesID of each row for the notes textarea
const _notesIDPrefix               = 'notes-for-';
var   _salt                        = 1; // used for table record id's
const _inactiveInputCSSClass       = 'inactive-input';
const _svcDetsButClass             = 'svcDetsBut'; // view details button for selected service
const _orpDocID                    = 'orpDocID'; // id of the orp id input field
const _orpDocNameID                = 'orpDocID_selection'; // id of the orp name input field
const _svcrecIsRmtsMomentClass     = 'svcrec-is-rmts-moment'; // class which indicates a svcrec has been selected to be RMTS moment
const _notificationBellClass       = 'svcrec-notification-bell'; // notification bell class
const _notificationBellActiveClass = 'svcrec-notification-bell-active'; // class which indicates the notification bell is one and the user needs to read the notifications
const _checkboxInputClass          = 'form-checkbox-input'; // class for checkboxes
const _formBuilderFormID           = 'spedmon-form-builder-questions-answers-form';
const _formBuilderClientID         = 'spedmon-form-builder-patient-goals-client-id';
const _formBuilderPatID            = 'spedmon-form-builder-patient-goals-pat-id';
const _formBuilderGroupID          = 'spedmon-form-builder-patient-goals-group-id';

// notification types
const _notificationTypeOrderExpiration = 1;
const _notificationMsgOrderExpiration = "<i class=\"fas fa-caret-right mr-1\"></i>The current order for this date of service is either expired, expiring in the next 30 days, or pending authorization.  Please update this order with a new authorization date (when available) or request new authorization.";

const _notificationTypeNoOrdersForDos = 2;
const _notificationMsgNoOrdersForDos  = "<i class=\"fas fa-caret-right mr-1\"></i>No order for this date of service is currently in SpEdCare. Please add an order in the Manage Orders & Prescriptions screen.";

/*#################################################################################################
  #
  #                                  Private Methods
  #
  #################################################################################################*/

/***************************************************************************
 * _createSvcRecKey  */
/**
 * https://www.w3resource.com/javascript-exercises/javascript-math-exercise-23.php
 ***************************************************************************/

function _createSvcRecKey () {
  var dt = new Date().getTime();
  var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      var r = (dt + Math.random() * 16) % 16 | 0;
      dt = Math.floor(dt / 16);
      return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
  });
  return uuid;
}

/***************************************************************************
 * _createNotesID  */
/**
 *
 ****************************************************************************/

function _createNotesID (patID) {
 
    return _notesIDPrefix + patID + '-' + _salt++;
}

/***************************************************************************
 * _mergeDefaultsWithSvcRecObj */
/**
 * creates a service records object where default values are merged with the
 * passed in object to create a merged service record object
 * 
 * returns service record object
 ***************************************************************************/
function _mergeDefaultsWithSvcRecObj (_SvcRecObj) {
    let retObj = {}; // object to be returned

    // if fields exist in passed in object, then set retObj value to those, otherwise set to default values
    retObj[_opts.SvcRecsTableColCtrlDataAttrValPatID]       = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatID]) ?
                                                               _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatID]  : null;
    
    retObj[_opts.SvcRecsTableColCtrlDataAttrValPatientName] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatientName]) ?
                                                               _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatientName]  : null;
        
    retObj[_opts.SvcRecsTableColCtrlDataAttrValStartTime]   = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValStartTime]) ?
                                                               _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValStartTime]  : '';

    retObj[_opts.SvcRecsTableColCtrlDataAttrValPlanType]    = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPlanType]) ?
                                                               _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPlanType]  : null;
                                                            
    retObj[_opts.SvcRecsTableColCtrlDataAttrValNumMins]     = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValNumMins]) ?
                                                               _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValNumMins]  : null;
                                                            
    retObj[_opts.SvcRecsTableColCtrlDataAttrValNotes]       = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValNotes]) ?
                                                               _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValNotes]  : null;
                                                                
    retObj[_opts.SvcRecsTableColCtrlDataAttrValDuppedRecKey] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValDuppedRecKey]) ?
                                                                _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValDuppedRecKey]  : null;

    retObj[_opts.SvcRecsTableColCtrlDataAttrValSessionDeliveryStatus] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValSessionDeliveryStatus]) ?
                                                                         _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValSessionDeliveryStatus] : 0;

    retObj[_opts.SvcRecsTableColCtrlDataAttrValDateOfService] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValDateOfService]) ?
                                                                 _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValDateOfService] : _opts.dos;

    // set append type for the table
    retObj[_opts.SvcRecsTableColCtrlDataAttrValAppendType] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValAppendType]) ?
                                                              _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValAppendType]  : 'prepend';

    // set service default classes
    retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses] = [];


    // select default service selection data
    retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass]) ?
                                                                _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass]  : null;


    // handle service type and sub type
    if (!_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass]) {
        retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassTypeID] = null;
    }
    else if (!_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassTypeID]) {
        // possible alternative name for service type
        if (_SvcRecObj.svcTypeID) {
            retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassTypeID] = _SvcRecObj.svcTypeID;
        }
        else
            retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassTypeID] = null;
    } else
        retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassTypeID] = _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassTypeID];

    if (!_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass]) {
        retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassSubTypeID] = null;
    }
    else if (!_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassSubTypeID]) {
        // possible alternative name for service sub type
        if (_SvcRecObj.svcSubTypeID) {
            retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassSubTypeID] = _SvcRecObj.svcSubTypeID;
        }
        else
            retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassSubTypeID] = null;
    } else
        retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassSubTypeID] = _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassSubTypeID];

    // select default svcDetFlags       
    retObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetFlags] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetFlags]) ?
                                                                  _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetFlags]  : false;

    retObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag1] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetFlags]) ?
                                                               _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag1]     : null;

    retObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag2] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetFlags]) ?
                                                               _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag2]     : null;

    retObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag3] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetFlags]) ?
                                                               _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag3]     : null;

    retObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag4] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetFlags]) ?
                                                               _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag4]     : null;

    retObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocIDRequired] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocIDRequired]) ?
                                                                    _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocIDRequired]  : null;

    // set details button
    if (retObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetFlags] || retObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocIDRequired])
        retObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetBut] = true;
    else
        retObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetBut] = false;

    if (!_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocID]) {
        retObj[_opts.SvcRecsTableColCtrlDataAttrValHasOrpDocID] = false;
        retObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocID]    = null;
        retObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocName]  = null;
    }
    else {
        retObj[_opts.SvcRecsTableColCtrlDataAttrValHasOrpDocID] = true;
        retObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocID]    = _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocID];
        retObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocName]  = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocID]) ? 
                                                                   _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocID]  : null;
    }

    retObj[_opts.SvcRecsTableColCtrlDataAttrValNotifications] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValNotifications]) ?
                                                                 _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValNotifications]  : false;
    
    // RMTS moment
    retObj[_opts.SvcRecsTableColCtrlDataAttrValRMTSMoment] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValRMTSMoment]) ?
                                                              _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValRMTSMoment] : false;

    retObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocIDAutoSelected] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocIDAutoSelected]) ?
                                                                        _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocIDAutoSelected] : false;

    retObj[_opts.SvcRecsTableColCtrlDataAttrValFormQuestionsJSON] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValFormQuestionsJSON]) ?
                                                                     _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValFormQuestionsJSON] : '{}';

    retObj[_opts.SvcRecsTableColCtrlDataAttrValFormAnswersJSON] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValFormAnswersJSON]) ?
                                                                   _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValFormAnswersJSON] : '{}';

    retObj[_opts.SvcRecsTableColCtrlDataAttrValViaTeleHealth] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValViaTeleHealth]) ?
                                                                 _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValViaTeleHealth] : null;

    retObj[_opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalTracking] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalTracking]) ?
                                                                     _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalTracking] : false;

    retObj[_opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalProgressJSON] = (_SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalProgressJSON]) ?
                                                                     _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalProgressJSON] : null;

    return retObj;
}

/***************************************************************************
 * _createSvcRecObjPromise */
/**
 *
 ***************************************************************************/

function _createSvcRecObjPromise (_SvcRecObj) {
    return new Promise((resolve, reject) => {
        let tkn    = _opts.tkn;
        let cltid  = $('#clientid').val();
        let prcid  = $('#pracid').val();
        let patid  = _SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatID];
        let grpid  = $(_opts.pracGroupID).val();
        let dos    = _opts.dos;
        let retObj = _mergeDefaultsWithSvcRecObj(_SvcRecObj); // merge defaults with passed in patameters

        // this variable if an ajax counter. The ajax functions will use this variable to decide whether or not to resolve the promise 
        // based on whether other ajax requests have completed or not
        let numAjaxReqsProcessed = 0;
        let numAjaxReqsGoal = 0;

        // *************************** set goal number of ajax calls ************************************
        
        // if plan type is passed, we have to get services dropdown entries
        if (retObj[_opts.SvcRecsTableColCtrlDataAttrValPlanType])
            numAjaxReqsGoal++;
        
        // if session type is passed, we have to get form data
        if (retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass]) numAjaxReqsGoal++;

        // if no need to make ajax calls to get service data, resolve promise
        if (numAjaxReqsGoal == 0) {
            resolve(retObj);
            return;
        }

        // if plan type is selected, get services dropdown options with ajax
        if (retObj[_opts.SvcRecsTableColCtrlDataAttrValPlanType]) {

            // decide isIEP based on inputVal, which is what option they selected for plan type
            var isIEP = false;
            switch (Number(retObj[_opts.SvcRecsTableColCtrlDataAttrValPlanType])) {
                case 1:
                    isIEP = true;
                    break;
                default:
                    break; // shouldn't get here
            }

            let reqUrlSessionTypes = "services.asmx/viewSel?tkn=" + tkn;
            let reqDataSessionTypes = "{'clientid':'" + cltid + "','pracid':'" + prcid + "','dos':'" + dos + "','patid':'" + patid + "','isiep':'" + isIEP + "','term':'" + '' + "'}";

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrlSessionTypes, reqDataSessionTypes, null)
                .then(responseData => {
                    // get the returned services
                    let services = responseData.rawData.SelRecs;
                    
                    if (services) {
                        $.each(services, function (idx, serviceObj) {
                            if (retObj[_opts.SvcRecsTableColCtrlDataAttrValViaTeleHealth]) {
                                if (serviceObj.recData4.includes("TELEHEALTH")) {
                                    serviceObj.label = serviceObj.label.replace("(via TeleHealth)", "").replace("(via Telehealth)", "");

                                    // add to service types array
                                    retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses]
                                        .push(serviceObj/*{ "id": serviceObj.id, "label": serviceObj.label }*/);
                                }
                            }
                            else {
                                if (serviceObj.recData4.includes("IN_PERSON")) {
                                    serviceObj.label = serviceObj.label.replace("(In Person)", "");

                                    // add to service types array
                                    retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses]
                                        .push(serviceObj/*{ "id": serviceObj.id, "label": serviceObj.label }*/);
                                }
                            }

                        });
                    }

                    numAjaxReqsProcessed++; // indicate that an ajax function has successfully been processed
                    
                    if (numAjaxReqsProcessed == numAjaxReqsGoal) resolve(retObj); // if we hit our ajax goal, resolve the promise
                })
                .catch(responsedata => {
                    reject(responsedata.message);
                });
        }
        
        // if service type is selected, get form data
        if (retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass]) {
            // send ajax to get form data
            var iep = (retObj[_opts.SvcRecsTableColCtrlDataAttrValPlanType] == 1) ? "2" : "3";

            var reqUrlServiceForm = "claim_service_name_xref_and_form_data_records.asmx/loadN?tkn=" + tkn;
            var reqDataServiceForm = JSON.stringify({
                "clientid": cltid
                , "plantypeid": iep
                , "groupid": grpid
                , "nameid": retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass]
            });

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrlServiceForm, reqDataServiceForm, null)
                .then(responseData => {

                    if (responseData.rawData.entity.hasFormData) {
                        // update formQuestionsJSON for the record
                        retObj[_opts.SvcRecsTableColCtrlDataAttrValFormQuestionsJSON] = responseData.rawData.entity.formDataJson;
                    }

                    retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassTypeID] = responseData.rawData.entity.svcTypeId;
                    retObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassSubTypeID] = responseData.rawData.entity.svcSubType1Id;
                    retObj[_opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalTracking] = responseData.rawData.entity.hasPatientGoalTracking;

                    numAjaxReqsProcessed++; // indicate that an ajax function has successfully been processed

                    if (numAjaxReqsProcessed == numAjaxReqsGoal) resolve(retObj); // if we hit our ajax goal, resolve the promise
                })
                .catch(responsedata => {
                    reject(responsedata.message);
                });
        }
    });
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _currentSvcRecsToArray () {
   let SvcRecObjs = [];
   let tempSvcClasses;
   let tempSvcClassTypeID;
   let tempSvcClassSubTypeID;
   let tempAppendType;
   let tempHasSvcDetBut;
   let tempPatientName;
   let tempOrpDocName;
   let tmpNotifications;

   _SvcRecs.forEach(function(SvcRecObj, _idx) {
      // exclude fields we don't want to send to the database
      tempSvcClasses = SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses];
      delete SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses];

      tempSvcClassTypeID = SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassTypeID];
      delete SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassTypeID];

      tempSvcClassSubTypeID = SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassSubTypeID];
      delete SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassSubTypeID];

      tempAppendType = SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValAppendType];
      delete SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValAppendType];

      tempHasSvcDetBut = SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetBut];
      delete SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetBut];

      tempPatientName = SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatientName];
      delete SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatientName];

      tempOrpDocName = SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocName];
      delete SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocName];
       
      tmpNotifications = SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValNotifications];
      delete SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValNotifications];

      SvcRecObjs.push(JSON.parse(JSON.stringify(SvcRecObj)));  

      // add back excluded fields
      SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses]         = tempSvcClasses;
      SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassTypeID]     = tempSvcClassTypeID;
      SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassSubTypeID]  = tempSvcClassSubTypeID;
      SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValAppendType]             = tempAppendType;
      SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetBut]           = tempHasSvcDetBut;
      SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatientName]            = tempPatientName;
      SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocName]             = tempOrpDocName;
      SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValNotifications]          = tmpNotifications;

   });
   return SvcRecObjs;
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _currentSvcRecsToJSON () {
  let SvcRecObjs = _currentSvcRecsToArray();
  return JSON.stringify(SvcRecObjs);
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _currentSvcRecsToTA () {
  let SvcRecsJSON = _currentSvcRecsToJSON();
  $(_opts.SvcRecsTextAreaSelector).val(SvcRecsJSON);
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _SvcRecsDataToTA () {
    _currentSvcRecsToTA();
};

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _createSvcRecsTableRowCommonMkup (SvcRecObj,SvcRecKey) {
  return '<tr ' + _opts.SvcRecsTableRowDataAttr  + '="' + SvcRecKey + '"></tr>';
}

/***************************************************************************
 * _createSvcClassesMkup */
/**
 * generates markup for services class options dropdown
 ***************************************************************************/
function _createSvcClassesMkup(SvcrecObj) {
    let svcTypeOptions = '<option disabled value' + ((SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass] == null) ? ' selected' : '') + ' > -- select an option -- </option>';

    $.each(SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses], function (idx, svcTypeObj) {
        svcTypeOptions += 
            (
                '<option value="' + svcTypeObj.id + '" '
                + ((SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass] == svcTypeObj.id)
                ? ' selected' : '') + ' >' + svcTypeObj.label + '</option >'
            );
    });

    return svcTypeOptions;
}

/***************************************************************************
 * _createSvcrecTableColsCommonMkup */
/**
 *
 ***************************************************************************/
function _createSvcrecTableColsCommonMkup(SvcrecObj, notesID) {

    // set up session type class if not a duplicate so that session type will be disabled initially
    let sessionTypeClass = (!SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValPlanType]) ? ' class="inactive-input" ' : '';

    // define dos
    let thisDos = SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValDateOfService];
    thisDos = thisDos.replace(/(\d\d)\/(\d\d)\/(\d{4})/, "$3-$1-$2");

    return '<td><div ' + _opts.SvcRecsTableColCtrlDataAttr + '=' + _opts.SvcRecsTableColCtrlDataAttrValPatientName + ' value="' + SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValPatientName] + '" />' + SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValPatientName] + '</td>'
        + '<td><input ' + _opts.SvcRecsTableColCtrlDataAttr + '=' + _opts.SvcRecsTableColCtrlDataAttrValDateOfService + ' value="' + thisDos + '" type="date"/></td>'
        + '<td><input ' + _opts.SvcRecsTableColCtrlDataAttr + '=' + _opts.SvcRecsTableColCtrlDataAttrValViaTeleHealth + ' type="checkbox" class="' + _checkboxInputClass + '" ' + ((SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValViaTeleHealth]) ? 'checked' : '') + '/></td>'
        + '<td><select ' + _opts.SvcRecsTableColCtrlDataAttr + '=' + _opts.SvcRecsTableColCtrlDataAttrValPlanType + ' >'
            + '<option disabled value' + ((SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValPlanType] == null) ? ' selected' : '') + ' > -- select an option --</option>'
            + '<option value="1"' + ((SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValPlanType] == 1) ? ' selected' : '') + ' >IEP / IFSP</option>'
            + '<option value="2"' + ((SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValPlanType] == 2) ? ' selected' : '') + ' >Other (IHP, 504, Counseling, etc.)</option>'
        + '</select></td>'
        + '<td><select ' + sessionTypeClass + _opts.SvcRecsTableColCtrlDataAttr + '=' + _opts.SvcRecsTableColCtrlDataAttrValServiceClass + ' value="' + SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass] + '" >'
            + _createSvcClassesMkup(SvcrecObj) + '</select ></td >'
        + '<td><input ' + _opts.SvcRecsTableColCtrlDataAttr + '=' + _opts.SvcRecsTableColCtrlDataAttrValStartTime + ' value="' + SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValStartTime] + '" type="time"/></td>'
        + '<td><input ' + _opts.SvcRecsTableColCtrlDataAttr + '=' + _opts.SvcRecsTableColCtrlDataAttrValNumMins + ' value="' + SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValNumMins] + '" type="number" style="width: 5em;" min="0" /></td>'
        + '<td><select ' + _opts.SvcRecsTableColCtrlDataAttr + '=' + _opts.SvcRecsTableColCtrlDataAttrValSessionDeliveryStatus + ' value="' + '' + '" >'
            + '<option value="0"' + ((SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValSessionDeliveryStatus] == 0) ? ' selected' : '') + ' >Regular Session</option >'
            + '<option value="1"' + ((SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValSessionDeliveryStatus] == 1) ? ' selected' : '') + ' >Student Absent</option>'
            + '<option value="2"' + ((SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValSessionDeliveryStatus] == 2) ? ' selected' : '') + ' >Practitioner Absent</option>'
            + '<option value="4"' + ((SvcrecObj[_opts.SvcRecsTableColCtrlDataAttrValSessionDeliveryStatus] == 4) ? ' selected' : '') + ' >Make-up Session</option></select ></td >'
        + '<td><textarea id="' + notesID + '" ' + _opts.SvcRecsTableColCtrlDataAttr + '=' + _opts.SvcRecsTableColCtrlDataAttrValNotes + ' value="' + SvcrecObj.notes + '" >' + ((SvcrecObj.notes) ? SvcrecObj.notes : '') + '</textarea></td>';
}

/***************************************************************************
 * updateCurrentSvcRecsForStartEndDates */
/**
 * updates current supervising pracs when a start or end date is entered
 ***************************************************************************/

function _updateCurrentSvcRecsForSpecificField(key, val, whatField) {
    var SvcRecObj = _SvcRecs.get(key);

    // if we are trying to change service type, make sure the chosen service is valid for this row
    if (whatField == _opts.SvcRecsTableColCtrlDataAttrValServiceClass &&
        (!SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses] || !(SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses].find(o => o.id == val))))
        return;
    
    // if we are trying to change notes, make sure to update the associated textarea value
    if (whatField == _opts.SvcRecsTableColCtrlDataAttrValNotes)
        $('tr[' + _opts.SvcRecsTableRowDataAttr + '="' + key + '"]').find('*[' + _opts.SvcRecsTableColCtrlDataAttr + '="' + _opts.SvcRecsTableColCtrlDataAttrValNotes + '"]').val(val);
    
    SvcRecObj[whatField] = val;
    _SvcRecs.set(key, SvcRecObj);
    _SvcRecsDataToTA();
}

/***************************************************************************
 * _sortCurrentRosterByName */
/**
 * 
 ***************************************************************************/

function _sortCurrentSvcRecsByName () {
  
  let _arr = _currentSvcRecsToArray();
  let _sortedMap = new Map();
  
  _arr.sort(function(a, b) {
     
	if (a.name < b.name) { return -1; }
    if (a.name > b.name) { return 1; }
    return 0;
  });
  
   $.each( _arr, function( _idx, _pObj ) {
     let _pk = _createSvcRecKey (_pObj);
	 _sortedMap.set(_pk,_pObj);
   });
   _SvcRecs = new Map(_sortedMap);
}


/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _addRecToSvcRecs (_SvcRecObj) {
 
  let _SvcRecKey = _createSvcRecKey(_SvcRecObj);

  if (_initMode === false) { 
    if (_SvcRecs.has(_SvcRecKey)) return null;
  }
  
  _SvcRecs.set(_SvcRecKey, _SvcRecObj); 

  _SvcRecsDataToTA();

  return _SvcRecKey;
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _removeRecFromSvcRecs (SvcRecKey) {
  if (_SvcRecs.has(SvcRecKey) === false) return;
  _SvcRecs.delete(SvcRecKey);  
  _SvcRecsDataToTA();
}

/***************************************************************************
 * generateSvcDetsButtonElem */
/**
 * generates button for service details questions to pop up
 ***************************************************************************/
function generateSvcDetsButtonElem(callbackFunc) {
    let $svcDetBut = $('<button class="' + _svcDetsButClass + '" type="button" title="View Details">&nbsp;</button>');
    $svcDetBut.button({ label: 'View Details' });
    $svcDetBut.on("click", callbackFunc);

    return $svcDetBut;
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _drawSvcRecsTableBodyRow (SvcRecObj, SvcRecKey) {	
  let recObj = _SvcRecs.get(SvcRecKey);
  let notesID = _createNotesID(SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatID]);
  let $_row = $(_createSvcRecsTableRowCommonMkup(SvcRecObj,SvcRecKey));  
  let $_tdRemove = $('<td></td>');  
  let $_butRem = $('<i ' + _opts.SvcRecsTableColCtrlDataAttr + '="' +_opts.SvcRecsTableColCtrlDataAttrValRemove + '" class="fa fa-trash-alt" title="Remove Record"></i>');
  $($_tdRemove).append($_butRem);
  $($_row).append($_tdRemove);

  let $_tdDup = $('<td></td>');  
  let $_butDup = $('<i ' + _opts.SvcRecsTableColCtrlDataAttr + '="' +_opts.SvcRecsTableColCtrlDataAttrValDup + '" class="fa fa-copy" title="Duplicate Record"></i>');
  $($_tdDup).append($_butDup);

  $($_row).append($_tdDup);

  let $_tdRMTSMoment = $('<td></td>');  
    let $_butRMTSMoment = $('<i ' + _opts.SvcRecsTableColCtrlDataAttr + '="' + _opts.SvcRecsTableColCtrlDataAttrValRMTSMoment + '" class="far fa-clock'
        + ((SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValRMTSMoment]) ? ' svcrec-is-rmts-moment' : '' )
        +  '" title="Mark as RMTS moment"></i>');
  $($_tdRMTSMoment).append($_butRMTSMoment);
  
  $($_row).append($_tdRMTSMoment);
    
  let $_tdNotificationBell = $('<td></td>');  
  let $_butNotificationBell = $('<i ' + _opts.SvcRecsTableColCtrlDataAttr + '="' + _opts.SvcRecsTableColCtrlDataAttrValNotifications + '" class="fas fa-bell ' + _notificationBellClass
      + ((SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValNotifications] && SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValNotifications].length > 0) ? ' ' + _notificationBellActiveClass : '')
      + '" title="Notifications"></i>');
  $_butNotificationBell.on("click", function () {
      $.spedmonWebUI.dialogMessage('Alert', SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValNotifications].map(o => o.message).join('<br/><br/>'), null, 400, 400, null, null, null);
  });

  $($_tdNotificationBell).append($_butNotificationBell);
  
  $($_row).append($_tdNotificationBell);

  $($_row).append(_createSvcrecTableColsCommonMkup (SvcRecObj, notesID));

  // append by appendType
  if (SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValAppendType] == 'prepend') $(_opts.SvcRecsTableBodySelector).prepend($_row);
  
  // if this is the duplicate of a row, insert it directly after its original row
  else if (SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValAppendType] == 'insertafter') {
    $_row.insertAfter($('tbody tr[' + _opts.SvcRecsTableRowDataAttr + '='
        + SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValDuppedRecKey] + ']'));
  }

  else $(_opts.SvcRecsTableBodySelector).append($_row);

  // link notes
  var tkn = _opts.tkn;
  var noteFld = $('#' + notesID);
  var patID = SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatID];  // Get patient id value
  var groupID = $(_opts.pracGroupID).val();                          // Get group id value
    
  var patIDFn = function () { return patID; };              // Setup function to return patient id value
  var groupIDFn = function () { return groupID; };          // Setup function to return group id value

  var hasPatientGoalTrackingFn = function () {
      // flag to determine if we need patient goal tracking
      return MBA.ComponentCommon.fnFlagValueToTrueFalse(SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalTracking]);
  };
  var setPatientGoalTrackingJSONFn = function () {
      // JSON value preloaded to hidden textarea (used for generating previously saved goal tracking)
      return SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalProgressJSON];
  };
  var getPatientGoalTrackingJSONFn = function (goalTrackingJSON) {
      // grab goal tracking hidden texarea value (JSON)
      _updateCurrentSvcRecsForSpecificField(SvcRecKey, goalTrackingJSON, _opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalProgressJSON);
  };

  var formBuilderFn = function ($div) {

    $($div).html('');

      renderFormInDiv($div
          , SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValFormQuestionsJSON]
          , SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValFormAnswersJSON]
          , $('#clientid').val()
          , SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatID]
          , groupID
          , function (fbNoteAnswersJSON) { _updateCurrentSvcRecsForSpecificField(SvcRecKey, fbNoteAnswersJSON, _opts.SvcRecsTableColCtrlDataAttrValFormAnswersJSON); });

  };

  $.when(
        noteFld.notelibrary({ displayMode: ""
            , useMenu: true
            , useLabelInOpenButton: false
            , sel_tmp_enabled: false
            , tkn: tkn
            , noteforpatidfn: (patIDFn)
            , noteforgroupidfn: (groupIDFn) 
            , additionalcontentfn: (formBuilderFn)
            , noteforhaspatientgoaltrackingfn: (hasPatientGoalTrackingFn)
            , noteforsetpatientgoaltrackingjsonfn: (setPatientGoalTrackingJSONFn)
            , noteforgetpatientgoaltrackingjsonfn: (getPatientGoalTrackingJSONFn)
            , url_view_all_patient_goals_progress: _opts.urlViewAllPatientGoalsProgress
        })
  ).then(
      noteFld.val(SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValNotes])
  );

  // append svcDetails button if this row has one
  if (SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetBut]) {
    let $svcTypeCell = $_row.find('select[' + _opts.SvcRecsTableColCtrlDataAttr + '="' + _opts.SvcRecsTableColCtrlDataAttrValServiceClass + '"]').parent();

    if (SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetFlags]) {
        $svcTypeCell.append(generateSvcDetsButtonElem(function () { showSvcDetailCont(SvcRecObj); }));
    }
    else if (SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocIDRequired]) {
        $svcTypeCell.append(generateSvcDetsButtonElem(function () { showOrpSelCont(SvcRecKey); }));
    }      
  }

  // set up notifications
  if (recObj[_opts.SvcRecsTableColCtrlDataAttrValNotifications] && recObj[_opts.SvcRecsTableColCtrlDataAttrValNotifications].length > 0) {
      _setNotificationToolTip($_butNotificationBell, recObj[_opts.SvcRecsTableColCtrlDataAttrValNotifications].map(o => o.message).join('<br />'));
}

}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _drawSvcRecsTableBodyRows() {
  _SvcRecsDataToTA();

  $(_opts.SvcRecsTableBodySelector).children().remove();

  _SvcRecs.forEach(function(_SvcrecObj, _SvcrecKey) {
      _drawSvcRecsTableBodyRow(_SvcrecObj, _SvcrecKey);
  });
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _identifySvcRecsTableBodyRowAction(e, whatElement) {

  let _rowAction = {};
  _rowAction.whatInp = $(e.target).closest(whatElement);
  _rowAction.whatCol = $(_rowAction.whatInp).closest('td');
  _rowAction.whatRow = $(_rowAction.whatCol).closest('tr');
  _rowAction.doWhat  = $(_rowAction.whatInp).attr(_opts.SvcRecsTableColCtrlDataAttr);
  _rowAction.SvcRecKey = $(_rowAction.whatRow).attr(_opts.SvcRecsTableRowDataAttr);
  return _rowAction;
}
    
/***************************************************************************
 * getDefaultServiceObjs */
/**
 * return array of default service types for service class dropwdown
 ***************************************************************************/
function setDefaultServiceType(svcRecObj, whatRow) {
    // remove svcDetails button if it exists
    if (whatRow) whatRow.find("." + _svcDetsButClass).remove();
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetBut] = false;

    // set defaults
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass]              = null;
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetFlags]            = false;
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag1]               = null;
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag2]               = null;
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag3]               = null;
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag4]               = null;
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocIDRequired]          = false;
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocID]                  = null;
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocName]                = null;
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassTypeID]        = null;
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassSubTypeID]     = null;

}

/***************************************************************************
 * loadSessionTypes */
/**
 * sends ajax request to get available service classes when plan type is selected
 ***************************************************************************/
function loadSessionTypes(svcRecKey, inputVal, whatRow, $sessionTypeDropdown) {
    var tkn = _opts.tkn;
    var cltid = $('#clientid').val();
    var prcid = $('#pracid').val();
    var svcRecObj = _SvcRecs.get(svcRecKey);
    var patid = svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatID];
    var dos = whatRow.find('input[' + _opts.SvcRecsTableColCtrlDataAttr + '="' + _opts.SvcRecsTableColCtrlDataAttrValDateOfService + '"]').val();

    // if no plan type, exit
    if (!inputVal) {
        return;
    }

    // remove all notifications as no order has been selected yet
    _removeNotification(svcRecKey, _notificationTypeOrderExpiration);
    _removeNotification(svcRecKey, _notificationTypeNoOrdersForDos);


    // set service type defaults
    setDefaultServiceType(svcRecObj, whatRow);

    // set up an array of id, label for our returned services for this row
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses] = [];

    // decide isIEP based on inputVal, which is what option they selected for plan type
    var isIEP = false;
    switch (Number(inputVal)) {
        case 1:
            isIEP = true;
            break;
        default:
            break; // shouldn't get here
    }

    /****** set up ajax url ***********/

    var reqUrl = "services.asmx/viewSel?tkn=" + tkn;
    var reqData = "{'clientid':'" + cltid + "','pracid':'" + prcid + "','dos':'" + dos + "','patid':'" + patid + "','isiep':'" + isIEP + "','term':'" + '' + "'}";

    // objects to be returned from ajax
    var services = null;

    // success callback for ajax
    var fnProcRespSuccess = function (rd) {
        if ($sessionTypeDropdown) {
            // remove all options from the service type dropdown
            $sessionTypeDropdown.children('option').remove();

            // append default unselected value
            $sessionTypeDropdown.append(
                '<option disabled value' + ((svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass] == null) ? ' selected' : '')
                + ' > -- select an option -- </option>'
            );
        }

        // get the returned services
        services = rd.SelRecs;

        // add patient rows
        if (services) {
            $.each(services, function (idx, serviceObj) {
                if (svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValViaTeleHealth]) {
                    if (serviceObj.recData4.includes("TELEHEALTH")) {
                        serviceObj.label = serviceObj.label.replace("(via TeleHealth)", "").replace("(via Telehealth)", "");

                        // add to service types array
                        svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses]
                            .push(serviceObj/*{ "id": serviceObj.id, "label": serviceObj.label }*/);

                        if ($sessionTypeDropdown) {
                            $sessionTypeDropdown.append(
                                '<option value="' + serviceObj.id + '">' + serviceObj.label + '</option>'
                            );
                        }
                    }
                }
                else {
                    if (serviceObj.recData4.includes("IN_PERSON")) {
                        serviceObj.label = serviceObj.label.replace("(In Person)", "");
                        
                        // add to service types array
                        svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses]
                            .push(serviceObj/*{ "id": serviceObj.id, "label": serviceObj.label }*/);

                        if ($sessionTypeDropdown) {
                            $sessionTypeDropdown.append(
                                '<option value="' + serviceObj.id + '">' + serviceObj.label + '</option>'
                            );
                        }
                    }
                }

            });
        }

        // make sessionType interactable
        if ($sessionTypeDropdown) $sessionTypeDropdown.removeClass(_inactiveInputCSSClass);

        _SvcRecsDataToTA();
    };

    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
        .then(responseData => {
            fnProcRespSuccess(responseData.rawData);
        })
        .catch(responseData => {

        });
}

/***************************************************************************
 * loadSessionTypesForCopy */
/**
 * sends ajax request to get available service classes when plan type is selected
 ***************************************************************************/
function loadSessionTypesForCopy(inputVal) {
    var $sessionTypeDropdown = $('#' + _opts.servicesToCopy);
    var tkn = _opts.tkn;
    var cltid = $('#clientid').val();
    var prcid = $('#pracid').val();
    var dos = _opts.dos;

    // decide isIEP based on inputVal, which is what option they selected for plan type
    var isIEP = false;
    switch (Number(inputVal)) {
        case 1:
            isIEP = true;
            break;
        default:
            break; // shouldn't get here
    }

    /****** set up ajax url ***********/

    var reqUrl = "services.asmx/viewSelTmtTcmTrans?tkn=" + tkn;
    var reqData = "{'clientid':'" + cltid + "','pracid':'" + prcid + "','dos':'" + dos + "','isiep':'" + isIEP + "','term':'" + '' + "'}";

    // objects to be returned from ajax
    var services = null;

    // success callback for ajax
    var fnProcRespSuccess = function (rd) {
        var isViaTeleHealth = $('#' + _opts.telehealthFlagToCopy).prop("checked");

        // remove all options from the service type dropdown
        $sessionTypeDropdown.children('option').remove();

        // append default unselected value
        $sessionTypeDropdown.append(
            '<option disabled value selected > -- select an option -- </option>'
        );

        // get the returned services
        services = rd.SelRecs;

        // add patient rows
        if (services) {
            $.each(services, function (idx, serviceObj) {
                if (isViaTeleHealth) {
                    if (serviceObj.recData5.includes("TELEHEALTH")) {
                        serviceObj.label = serviceObj.label.replace("(via TeleHealth)", "").replace("(via Telehealth)", "");

                        $sessionTypeDropdown.append(
                            '<option value="' + serviceObj.recData4 + '">' + serviceObj.label + '</option>'
                        );
                    }
                }
                else {
                    if (serviceObj.recData5.includes("IN_PERSON")) {
                        serviceObj.label = serviceObj.label.replace("(In Person)", "");

                        $sessionTypeDropdown.append(
                            '<option value="' + serviceObj.recData4 + '">' + serviceObj.label + '</option>'
                        );
                    }
                }
            });
        }

        // make sessionType interactable
        if ($sessionTypeDropdown) $sessionTypeDropdown.removeClass(_inactiveInputCSSClass);
    };

    $.spedmonWebUI.ajax(null
        , reqUrl
        , reqData
        , 'json'
        , null
        , null
        , null
        , null
        , 0
        , fnProcRespSuccess
        , null
        , null);

}

/***************************************************************************
 * doAcceptSvcDetFlags */
/**
 * save answers for svcDetails
 ***************************************************************************/
function doAcceptSvcDetFlags(svcRecObj) {
    let svcDetFlag1 = $('input[name="' + _opts.svcDetFlag1 + '"]:checked').val();
    let svcDetFlag2 = $('input[name="' + _opts.svcDetFlag2 + '"]:checked').val();
    let svcDetFlag3 = $('input[name="' + _opts.svcDetFlag3 + '"]:checked').val();
    let svcDetFlag4 = $('input[name="' + _opts.svcDetFlag4 + '"]:checked').val();

    // validate the flags
    if (!svcDetFlag1 || !svcDetFlag2 || !svcDetFlag3 || !svcDetFlag4) {
        $.spedmonWebUI.dialogMessage('Warning', "Please answer every question", null, 400, 200, null, null, null);
        return;
    }

    // save the answers as true or false in svcRecObj
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag1] = (svcDetFlag1 == 'true');
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag2] = (svcDetFlag2 == 'true');
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag3] = (svcDetFlag3 == 'true');
    svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag4] = (svcDetFlag4 == 'true');
 
    _opts.$svcDetailsCont.dialog("close");
    _currentSvcRecsToTA();
}

/***************************************************************************
 * doAcceptSvcDetFlags */
/**
 * save answers for svcDetails
 ***************************************************************************/

function doAcceptOrpDoc(svcRecObj) {
    let orpDocVal     = $('#' + _orpDocID).val();
    let orpDocNameVal = $('#' + _orpDocNameID).val();

    // save the answer
    if (orpDocVal) {
        svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasOrpDocID]  = true;
        svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocID]     = orpDocVal;
        svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocName]   = orpDocNameVal;
    }
    

    _opts.$orpDocumentsCont.dialog("close");
    _currentSvcRecsToTA();
}

/***************************************************************************
 * boolToYesNo */
/**
 * Convert bool value to 'Yes" or 'No'
 ***************************************************************************/

function boolToYesNo(boolVal) {
    switch (boolVal) {
        case true:
            return "Yes";
        case false:
            return "No";
        default:
            return "";
    } 
}

/***************************************************************************
 * showSvcDetailCont */
/**
 * show service details container
 ***************************************************************************/
function showSvcDetailCont(svcRecObj) {

    _opts.$svcDetailsCont.show().dialog(
        {
              width: $(window).width()  / 1.5
            , height: $(window).height()
            , title: "Service Details Questions"
            , show: {
                effect: 'slide',
                // attach callback to "ok" button to save entered service details answers
                complete: function () {
                    // clear the fields first
                    $('input[name="' + _opts.svcDetFlag1 + '"]').attr('checked', false);
                    $('input[name="' + _opts.svcDetFlag2 + '"]').attr('checked', false);
                    $('input[name="' + _opts.svcDetFlag3 + '"]').attr('checked', false);
                    $('input[name="' + _opts.svcDetFlag4 + '"]').attr('checked', false);

                    // preload data
                    $('input[name="' + _opts.svcDetFlag1 + '"]' + '[value="' + svcRecObj.svcDetFlag1 + '"]').attr('checked', true);
                    $('input[name="' + _opts.svcDetFlag2 + '"]' + '[value="' + svcRecObj.svcDetFlag2 + '"]').attr('checked', true);
                    $('input[name="' + _opts.svcDetFlag3 + '"]' + '[value="' + svcRecObj.svcDetFlag3 + '"]').attr('checked', true);
                    $('input[name="' + _opts.svcDetFlag4 + '"]' + '[value="' + svcRecObj.svcDetFlag4 + '"]').attr('checked', true);

                    _opts.$svcDetFlagsOK.off().bind('click', function(e) {
                        doAcceptSvcDetFlags(svcRecObj);
                    });
                }
              }
            , hide: {
                  effect: 'slide'
                , direction: 'left'
              }
        }

    );
}

/***************************************************************************
 * showOrpSel */
/**
 * show the orp selection
 ***************************************************************************/

function showOrpSelCont(svcRecKey) {
    var svcRecObj = _SvcRecs.get(svcRecKey);

    // remove previous entry
    $('#' + _orpDocID).parent().remove();

    _opts.$orpDocumentsCont.show().dialog(
    {
          width: $(window).width()  / 1.5
        , height: $(window).height()
        , title: "This service requires an Order ORP to be selected"
        , show: {
            effect: 'slide',
            // attach callback to "ok" button to save entered service details answers
            complete: function () {

                // append the input field
                $('<input name="' + _orpDocID + '" value="" title="Select Order or Prescription" autocomplete="off" class="mba-web-ui-field-simple mba-web-ui-field-ctrl-type-select-box" id="' + _orpDocID + '" style="display: none;">').insertAfter(_opts.$orpInputFieldPlaceHolder);
                
                $('#' + _orpDocID).spedmonSelectBox({
                    dataParmType: 'DOM',
                    selectAll: true,
                    delay: 600,
                    showSelectControlLabel: false,
                    selectControlLabel: 'Select : ',
                    selectType: 1,
                    displayInline: true,
                    singleSelectName: '',
                    singleSelectValue: '',
                    singleSelectClearAfterSelection: false,
                    multiSelect: false,
                    multiSelectShowOK: true,
                    multiSelectListTitle: 'Selected records',
                    multiSelectNames: '',
                    multiSelectValues: '',
                    multiSelectLoad: false,
                    multiSelectContextLabels: 'null',
                    multiSelectDisplayContextLabels: false,
                    multiSelectOnAdd: function (selObj) { },
                    multiSelectOnRemove: function (selObj) { },
                    onSelect: function (event, ui) {
                        _checkPatOrdersForExpiration(svcRecKey, ui.item.recData4);
                    },
                    ajaxopts: {
                        url: "orp_documents.asmx/viewSel?tkn=" + _opts.tkn,
                        data: "",
                        namevalues:
                            [{
                                name: 'clientid', value: $('#clientid').val()
                            }, {                         
                                name: 'pracid', value: $('#pracid').val()
                            }, {
                                name: 'patid', value: svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatID]
                            }]
                        
                    }
                });

                // set up add new order callback
                $(_opts.addNewOrderButSel).off().click(function () {
                    $.spedmonWebUI.openAddNewServiceJournalsPrescribedOrderForm(null, null, null, svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatID], null, null);
                });

                _opts.$orpDocsOK.off().bind('click', function (e) {
                    doAcceptOrpDoc(svcRecObj);
                });

                // set pre-chosen values if they exist
                if (svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocID] && svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocName]) {
                    $('#' + _orpDocID).val(svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocID]);  
                    $('#' + _orpDocNameID).val(svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocName]);               
                }
            }
        }
        , hide: {
            effect: 'slide'
            , direction: 'left'
        }
        , close: function () {
            // check dos and service selection combination
            _checkPatOrdersForDos(svcRecKey);
        }
    });
}

/***************************************************************************
 * _setNotificationToolTip */
/**
 * set tipso for bell notifictaions
 ***************************************************************************/
function _setNotificationToolTip($bell, content) {

    $bell.tipso('destroy').tipso({
        speed: 400
        , background: '#ffc57d'
        , titleBackground: '#333333'
        , color: 'black'
        , titleColor: '#ffffff'
        , titleContent: ''
        , showArrow: true
        , position: 'top-right'
        , width: 300
        , maxWidth: ''
        , delay: 200
        , hideDelay: 0
        , animationIn: ''
        , animationOut: ''
        , offsetX: 0
        , offsetY: 0
        , tooltipHover: true
        , content: content
        , ajaxContentUrl: null
        , contentElementId: null
        , useTitle: false
        , templateEngineFunc: null
        , onBeforeShow: null
        , onShow: null
        , onHide: null
    });
}
    
/***************************************************************************
 * _addNotification */
/**
 * Turn on the notification bell
 ***************************************************************************/
function _addNotification(RecKey, message, type) {
    let RecObj = _SvcRecs.get(RecKey);

    // if no service type, remove notification for service type
    if (!RecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocID]) {
        _removeNotification(RecKey, _notificationTypeOrderExpiration);
    }

    let $bell = $('tr[' + _opts.SvcRecsTableRowDataAttr + '="' + RecKey + '"]').find('.' + _notificationBellClass);

    if (!$bell.hasClass(_notificationBellActiveClass)) {
        $bell.addClass(_notificationBellActiveClass);
    }

    // create notification object
    let notificationObj = {
          "type": type
        , "message": message
    }

    // update notifications in object
    let notifications = RecObj[_opts.SvcRecsTableColCtrlDataAttrValNotifications] || [];
    notifications.push(notificationObj);
    _updateCurrentSvcRecsForSpecificField(RecKey, notifications, _opts.SvcRecsTableColCtrlDataAttrValNotifications);

    _setNotificationToolTip($bell, notifications.map(o => o.message).join('<br />'));
}
    
/***************************************************************************
 * _addNotification */
/**
 * Turn on the notification bell
 ***************************************************************************/
function _removeNotification(RecKey, type) {
    let RecObj = _SvcRecs.get(RecKey);

    let $bell = $('tr[' + _opts.SvcRecsTableRowDataAttr + '="' + RecKey + '"]').find('.' + _notificationBellClass);

    // update notifications in object
    let notifications = RecObj[_opts.SvcRecsTableColCtrlDataAttrValNotifications] || [];
    notifications = notifications.filter(item => item.type != type);
    _updateCurrentSvcRecsForSpecificField(RecKey, notifications, _opts.SvcRecsTableColCtrlDataAttrValNotifications);

    _setNotificationToolTip($bell, notifications.map(o => o.message).join('<br/><br/>'));

    // deactivate bell if no more notifications
    if (!notifications || notifications.length < 1) {
        $bell.removeClass(_notificationBellActiveClass);
    }
}

/***************************************************************************
 * _checkPatOrdersForExpiration */
/**
 * when a service is selected check patients orders and
 * notify user if order is expiring or expired
 ***************************************************************************/
function _checkPatOrdersForExpiration(SvcRecKey, expirationState) {        
    _removeNotification(SvcRecKey, _notificationTypeOrderExpiration);
    _removeNotification(SvcRecKey, _notificationTypeNoOrdersForDos);
    
    if (expirationState == 2 || expirationState == 3 || expirationState == 0) {
        _addNotification(SvcRecKey, _notificationMsgOrderExpiration, _notificationTypeOrderExpiration);
    }
}

/***************************************************************************
 * _checkPatOrdersForDos */
/**
 * check if patient has orders that cover a selected date
 ***************************************************************************/
function _checkPatOrdersForDos(SvcRecKey) {   
    var RecObj = _SvcRecs.get(SvcRecKey);
    var dos = RecObj[_opts.SvcRecsTableColCtrlDataAttrValDateOfService];    
    var tkn = _opts.tkn;
    var cltid = $('#clientid').val();
    var patid = RecObj[_opts.SvcRecsTableColCtrlDataAttrValPatID];
    var pracid = $('#pracid').val();

    // remove any old notifications
    _removeNotification(SvcRecKey, _notificationTypeNoOrdersForDos);

    // exit early if no need to check
    if ($('#svcetrmde').val() == 3 || !dos) {
        return;
    }

    /****** set up ajax url ***********/

    var reqUrl = "orp_documents.asmx/viewSelPatOrdersForDos?tkn=" + tkn;
    var reqData = JSON.stringify(
                  {
                    'clientid': cltid 
                  , 'pracid'  : pracid 
                  , 'patid'   : patid 
                  , 'dos'     : dos
                  , 'recid'   : null
                  });

    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData,null)
        .then(responseData => {
            if (!responseData.rawData.SelRecs) {
                // remove any old notifications
                _removeNotification(SvcRecKey, _notificationTypeNoOrdersForDos);
                _removeNotification(SvcRecKey, _notificationTypeOrderExpiration);

                _addNotification(SvcRecKey, _notificationMsgNoOrdersForDos, _notificationTypeNoOrdersForDos);
            } else {
                // check for expiration if order is auto selected. Otherwise it gets checked when user chooses an order
                if (RecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocIDAutoSelected]) {
                $.each(responseData.rawData.SelRecs, function (_idx, _elem) {
                    _checkPatOrdersForExpiration(SvcRecKey, _elem.recData4);
                });
            }
            }
        })
        .catch(responseData => {

        });
}

/***************************************************************************
 * _getFormData */
/**
 *
 ***************************************************************************/

function _getFormData(SvcRecKey, inputVal) {

    _updateCurrentSvcRecsForSpecificField(SvcRecKey, '{}', _opts.SvcRecsTableColCtrlDataAttrValFormQuestionsJSON);
    _updateCurrentSvcRecsForSpecificField(SvcRecKey, '{}', _opts.SvcRecsTableColCtrlDataAttrValFormAnswersJSON);
    _updateCurrentSvcRecsForSpecificField(SvcRecKey, false, _opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalTracking);

    let svcRecObj = _SvcRecs.get(SvcRecKey);

    /****** set up ajax url ***********/

    var tkn = _opts.tkn;
    var iep = (svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPlanType] == 1) ? "2" : "3";

    var reqUrl = "claim_service_name_xref_and_form_data_records.asmx/loadN?tkn=" + tkn;
    var reqData = JSON.stringify({
        "clientid": $('#clientid').val()
        , "plantypeid": iep
        , "groupid": $(_opts.pracGroupID).val()
        , "nameid": inputVal
    });
        
    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
        .then(responseData => {
            if (responseData.rawData.entity.hasFormData) {
                // update formQuestionsJSON for the record
                _updateCurrentSvcRecsForSpecificField(SvcRecKey, responseData.rawData.entity.formDataJson , _opts.SvcRecsTableColCtrlDataAttrValFormQuestionsJSON);
            }
            
            _updateCurrentSvcRecsForSpecificField(SvcRecKey, responseData.rawData.entity.svcTypeId, _opts.SvcRecsTableColCtrlDataAttrValServiceClassTypeID);
            _updateCurrentSvcRecsForSpecificField(SvcRecKey, responseData.rawData.entity.svcSubType1Id, _opts.SvcRecsTableColCtrlDataAttrValServiceClassSubTypeID);
            _updateCurrentSvcRecsForSpecificField(SvcRecKey, responseData.rawData.entity.hasPatientGoalTracking, _opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalTracking);
        })
        .catch(responseData => {

        });
}

/***************************************************************************
 * showSvcDetailCont */
/**
 * when a service type is selected load details if needed
 ***************************************************************************/
function loadServiceDetails(SvcRecKey, inputVal, whatRow, whatCol, renderDetailsForm) {
    // get selected service type's data
    let svcRecObj = _SvcRecs.get(SvcRecKey);
    let svcTypeObj = svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses].filter(obj => {
        return obj.id == inputVal;
    });

    // get formData (if any)
    _getFormData(SvcRecKey, inputVal);

    // set defaults
    setDefaultServiceType(svcRecObj, whatRow);

    if (svcTypeObj[0]["showOptions2"] == 'SHOW_SPEECH_ASSESS_OPTIONS') {
        svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetFlags] = true;

        // attach service details button to this row so they can always go to the questions
        let $svcDetBut = generateSvcDetsButtonElem(function () { showSvcDetailCont(svcRecObj); });
        svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetBut] = true;

        // remove existing details button (if any)
        if (whatRow) whatRow.find("." + _svcDetsButClass).remove();

        whatCol.append($svcDetBut);

        if (renderDetailsForm) showSvcDetailCont(svcRecObj);
    }

    else if (svcTypeObj[0]["showOptions2"] == 'SHOW_TREATMENT_ORP_DOC_SELECTION' && svcTypeObj[0]["recData3"] == 0) {
        svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocIDRequired] = true;
        
        // attach service details button to this row so they can always go to the questions
        let $svcDetBut = generateSvcDetsButtonElem(function () { showOrpSelCont(SvcRecKey); });
        svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasSvcDetBut] = true;

        // remove existing details button (if any)
        if (whatRow) whatRow.find("." + _svcDetsButClass).remove();

        whatCol.append($svcDetBut);

        if (renderDetailsForm) showOrpSelCont(SvcRecKey);
    }

    // check dos and service selection combination
    _removeNotification(SvcRecKey, _notificationTypeOrderExpiration);
    _removeNotification(SvcRecKey, _notificationTypeNoOrdersForDos);

    // check the case where order is auto selected
    if (svcTypeObj[0].flag1 == 2) {
        if (!svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValOrpDocIDRequired]) {
            _updateCurrentSvcRecsForSpecificField(SvcRecKey, true, _opts.SvcRecsTableColCtrlDataAttrValOrpDocIDAutoSelected);
        }
        _checkPatOrdersForDos(SvcRecKey);
    } else {
        _updateCurrentSvcRecsForSpecificField(SvcRecKey, false, _opts.SvcRecsTableColCtrlDataAttrValOrpDocIDAutoSelected);

    }
}
/***************************************************************************
 * _handleSvcRecsTableBodyRowActionForButton */
/**
 * 
 ***************************************************************************/

function _handleSvcRecsTableBodyRowActionForButton (e) {
  let _rowAction = _identifySvcRecsTableBodyRowAction(e, 'i');

  // remove record if needed
  if (_rowAction.doWhat == _opts.SvcRecsTableColCtrlDataAttrValRemove) {
	_removeRecFromSvcRecs(_rowAction.SvcRecKey);
	$(_rowAction.whatRow).remove();
  }

  // duplicate record if needed
  else if (_rowAction.doWhat == _opts.SvcRecsTableColCtrlDataAttrValDup) {
    _dupSvcRecRow(_rowAction.SvcRecKey, _rowAction.whatRow);
  }

  // duplicate record if needed
  else if (_rowAction.doWhat == _opts.SvcRecsTableColCtrlDataAttrValRMTSMoment) {
      _rowAction.whatInp.toggleClass(_svcrecIsRmtsMomentClass);
      _updateCurrentSvcRecsForSpecificField(_rowAction.SvcRecKey, _rowAction.whatInp.hasClass(_svcrecIsRmtsMomentClass), _rowAction.doWhat);
  }

}

/***************************************************************************
 * _handleSvcRecsTableBodyRowActionForInput */
/**
 * 
 ***************************************************************************/

function _handleSvcRecsTableBodyRowActionForInput (e) {
  let _rowAction = _identifySvcRecsTableBodyRowAction(e, e.currentTarget.localName);

  // decide what value we want to set for this field
  let inputVal = _rowAction.whatInp.val();
  if (_rowAction.whatInp.attr('type') == 'checkbox') inputVal = _rowAction.whatInp.prop('checked');

  // if plan type selected, make service class dropdown interactable and get its data via AJAX
  if (_rowAction.doWhat == _opts.SvcRecsTableColCtrlDataAttrValPlanType) {
      // get the plan type selection dropdown for this row so we can update its options
      var $sessionTypeDropdown = _rowAction.whatCol.next('td')
          .children('select[' + _opts.SvcRecsTableColCtrlDataAttr + '=' + _opts.SvcRecsTableColCtrlDataAttrValServiceClass + ']');
      loadSessionTypes(_rowAction.SvcRecKey, inputVal, _rowAction.whatRow, $sessionTypeDropdown);
  }

  // if service type selected, show details if necessary
  if (_rowAction.doWhat == _opts.SvcRecsTableColCtrlDataAttrValServiceClass) {
      // get the plan type selection dropdown for this row so we can update its options
      loadServiceDetails(_rowAction.SvcRecKey, inputVal, _rowAction.whatRow, _rowAction.whatCol, true);
  }

  // if TeleHealth flag changes, update the services dropdown
  if (_rowAction.doWhat == _opts.SvcRecsTableColCtrlDataAttrValViaTeleHealth) {

      // proceed only if plan type is already selected
      var planType = _SvcRecs.get(_rowAction.SvcRecKey)[_opts.SvcRecsTableColCtrlDataAttrValPlanType];

      if (planType) {
          // get the plan type selection dropdown for this row so we can update its options
          var $sessionTypeDropdown = _rowAction.whatRow
              .find('select[' + _opts.SvcRecsTableColCtrlDataAttr + '=' + _opts.SvcRecsTableColCtrlDataAttrValServiceClass + ']');
          loadSessionTypes(_rowAction.SvcRecKey, planType, _rowAction.whatRow, $sessionTypeDropdown);
      }
  }

  // enter input change into the hidden textarea json
  _updateCurrentSvcRecsForSpecificField(_rowAction.SvcRecKey, inputVal, _rowAction.doWhat);

  // if dos, check patient's orders to see if any orders exist
  if (_rowAction.doWhat == _opts.SvcRecsTableColCtrlDataAttrValDateOfService) {
      // if order selected, check date
      if (   _SvcRecs.get(_rowAction.SvcRecKey)[_opts.SvcRecsTableColCtrlDataAttrValOrpDocIDAutoSelected] == true
          || _SvcRecs.get(_rowAction.SvcRecKey)[_opts.SvcRecsTableColCtrlDataAttrValOrpDocIDRequired]) {
          _checkPatOrdersForDos(_rowAction.SvcRecKey);
      }
  }
}


/***************************************************************************
 * _dupSvcRecRow */
/**
 * duplicates a _SvcRecs object 
 ***************************************************************************/

var _dupSvcRecRow  = function (svcRecKey) {
  let _newSvcRecObj = JSON.parse(JSON.stringify(_SvcRecs.get(svcRecKey))); //https://www.samanthaming.com/tidbits/70-3-ways-to-clone-objects/
  // set append type
  _newSvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValAppendType]   = 'insertafter';
  _newSvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValDuppedRecKey] = svcRecKey;

  let _newSvcRecKey = _addRecToSvcRecs(_newSvcRecObj);

  if (!_newSvcRecKey) return;
  _drawSvcRecsTableBodyRows();
}


/*#################################################################################################
  #
  #                                  Public Methods
  #
  #################################################################################################*/

/***************************************************************************
 * _addSvcRec */
/**
 * 
 ***************************************************************************/

var _addSvcRec  = function (patObj) {
   
  _createSvcRecObjPromise (patObj)
      .then(function (svcRecObj) 
      {
  
          let _SvcRecKey = _addRecToSvcRecs(svcRecObj);
          if (!_SvcRecKey) return;
  
          _drawSvcRecsTableBodyRows();
  
      }).catch(function(err) {
          return;
      });
  
}
    
/***************************************************************************
 * _addMultipleRecs */
/**
 * add multiple patients and redraw the table only once
 ***************************************************************************/

var _addMultipleRecs  = function (patients) {
    let promises = [];

    // add patients to _SvcRecs
    $.each(patients, function (_idx, _patObj) {

        promises.push(
            _createSvcRecObjPromise(_patObj)
                .catch(function (err) {
                    return;
                })
        );
    });

    // when all promises resolved, add to the map and draw table
    Promise.all(promises).then(function (svcRecObjs) {
        $.each(svcRecObjs, function (_index, _svcRecObj) {
            _svcRecObj[_opts.SvcRecsTableColCtrlDataAttrValAppendType] = 'append';
            let _SvcRecKey = _addRecToSvcRecs(_svcRecObj);
            if (!_SvcRecKey) return;
        });

        _drawSvcRecsTableBodyRows();
    });
}

/***************************************************************************
 * _clearScvRecs */
/**
 * removes all records
 ***************************************************************************/

var _clearScvRecs  = function (skipDialog) {
    // confirm with user that they actually want to delete all records
    var onYes = function() {
        // clear _SvcRecs
        _SvcRecs.clear();

        _drawSvcRecsTableBodyRows();
    };

    if (skipDialog) {
        onYes();
        return;
    }

    $.spedmonWebUI.dialogConfirm("Please Confirm", "Are you sure you want to remove all records?", onYes, function () { });
}
       
/***************************************************************************
 * _saveLiveSessionData */
/**
 * Purpose: save callback for live session plug-in call
 * Details: Save patient notes data from live session return map
 ***************************************************************************/

var _saveLiveSessionData = function (patNotesMap) {
    if (!patNotesMap) return;

    // save notes and form data for each patient
    // the key will match the key in _SvcRecs
    patNotesMap.forEach(function (value, key) {
        _updateCurrentSvcRecsForSpecificField(key, value.notes, _opts.SvcRecsTableColCtrlDataAttrValNotes);
        _updateCurrentSvcRecsForSpecificField(key, value.formBuilderAnswersJSON, _opts.SvcRecsTableColCtrlDataAttrValFormAnswersJSON);
        _updateCurrentSvcRecsForSpecificField(key, value.patientGoalProgressJSON, _opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalProgressJSON);
    });
}
/***************************************************************************
 * _beginLiveGroupSession */
/**
 * Purpose: Begins live session with selected patients in the table
 * Details: Create a div and call the live session plug-in on it inside a
 * dialog
 ***************************************************************************/

var _beginLiveGroupSession  = function () {
    // set our check parameters
    const THERAPY_SVC_TYPE_ID   = 2;
    const GROUP_SVC_SUB_TYPE_ID = 2001;

    // create dialog div for the live session to render inside 
    let $liveSession = $('<div></div>');

    // build array of patients objects according to live notes plug in that are selected for group therapy
    let grpTherapyPatObjsArr = [];

    _SvcRecs.forEach(function (SvcRecObj, _idx) {
        try {
            // include group therapies
            if (SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassTypeID] == THERAPY_SVC_TYPE_ID &&
                SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClassSubTypeID] == GROUP_SVC_SUB_TYPE_ID &&
                SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass] &&
                SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClass] != 0
            ) {
                grpTherapyPatObjsArr.push({
                      'patID'                             : SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPatID]
                    , 'associationKey'                    : _idx
                    , 'notes'                             : SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValNotes]
                    , 'formBuilderQuestionsJSON'          : SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValFormQuestionsJSON]
                    , 'formBuilderAnswersJSON'            : SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValFormAnswersJSON]
                    , 'hasPatientGoalTracking'            : SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalTracking]
                    , 'patientGoalProgressJSON'           : SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalProgressJSON]
                    , 'groupID'                           : $(_opts.pracGroupID).val()
                    , 'urlViewAllPatientGoalsProgress'    : _opts.urlViewAllPatientGoalsProgress
                });
            }
        } catch (error) {
            console.error(error);
        }
    });

    // if no patients selected for group therapy, notify user
    if (grpTherapyPatObjsArr.length < 1) {
        $.spedmonWebUI.dialogMessage('Error', "No group therapy service selected for any person", null, 400, 200, null, null, null);
        return;
    }

    $liveSession.dialog(
        {
              width: $(window).width() / 1.5
            , height: $(window).height()
            , title: '<strong>Live Session</strong>'
            , modal: true
            , show: {
                  effect: 'slide'
                , direction: 'left'

                // When dialog renders, call the live session plug-in to render live session
                , complete: function () {

                    // remove close dialog button
                    $liveSession.parent().find('.ui-dialog-titlebar-close').hide();

                    // render live session
                    $liveSession.liveSessionNotes({
                          patObjsArr     : grpTherapyPatObjsArr
                        , patLoadURL     : 'patients.asmx/viewEntity?tkn=' + $.spedmonWebUI.token
                        , patLoadData    : { 'clientid': $('#clientid').val() }
                        , fnSaveCallback : function (patNotesMap) {
                            _saveLiveSessionData(patNotesMap);
                            $liveSession.dialog('close');
                        }
                        , tkn            : $.spedmonWebUI.token
                    });
                }
            }
            , hide: {
                effect: 'slide'
                , direction: 'left'
            }
            , close: function (event, ui) { $liveSession.remove(); }
        });

}

    
/***************************************************************************
 * _copyValForAllRows */
/**
 * copies the nearest input's value to all rows
 ***************************************************************************/

var _copyValForAllRows  = function ($elemSelector) {
    // get nearest input's value
    const inputTypes = 'input, textarea, select';
    var $th = $elemSelector.parents('th');
    var $rowIndex = $th.index() + 1;
    var $prevRow = $elemSelector.parents('tr').prev();
    var $inputHeader = $prevRow.find('th:nth-child(' + $rowIndex + ')');
    var $inputElem = $inputHeader.find(inputTypes);
    var isCheckbox = ($inputElem.attr('type') == 'checkbox') ? true : false;
    var inputVal = (isCheckbox) ? $inputElem.prop('checked') : $inputElem.val();

    // if the input element is 'Date of Service', then update DOS
    if ($inputElem.attr('id') == _opts.dateToCopy) {
        _opts.dos = inputVal;
        $('#dos').val(inputVal);
    }
    // if the input element is 'Plan Type', then update the services dropdown
    else if ($inputElem.attr('id') == _opts.planToCopy) {
        loadSessionTypesForCopy(inputVal);
    }
    // if the input element is 'Via TeleHealth', then update the services dropdown
    else if ($inputElem.attr('id') == _opts.telehealthFlagToCopy) {
        var planTypeCopy = $('#' + _opts.planToCopy).val();
        
        if (planTypeCopy) {
            loadSessionTypesForCopy(planTypeCopy);
        }
    }

    // get the attribute name, which represents the field name for this cell
    var $td = $th.parents('table').find('td:nth-child(' + $rowIndex + ')');
    var attributeName = $td.children().attr(_opts.SvcRecsTableColCtrlDataAttr);

    // loop through the records and find the values
    $td.each(function (idx, $thisTd) {
        // get key of this row
        let $tr = $(this).parent('tr');
        let key = $tr.attr(_opts.SvcRecsTableRowDataAttr);
        let SvcRecObj = _SvcRecs.get(key);

        // if we are trying to change service type, make sure the chosen service is valid for this row
        if (attributeName == _opts.SvcRecsTableColCtrlDataAttrValServiceClass &&
            (!SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses] ||
             !(SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValServiceClasses].find(o => o.id == inputVal)))
        )
            return;

        // load "View Details" button if necessary
        if (attributeName == _opts.SvcRecsTableColCtrlDataAttrValServiceClass) {
            loadServiceDetails(key, inputVal, $tr, $($thisTd), false);
        }

        // copy the value to our object in _SvcRecs
        _updateCurrentSvcRecsForSpecificField(key, inputVal, attributeName);

        // instead of redrawing the whole table, just change all the fields that need to be changed
        (isCheckbox) ? $($thisTd).children(inputTypes).prop('checked', inputVal)
        : $($thisTd).children(inputTypes).val(inputVal);

        // if type is plan type, load available services
        if (attributeName == _opts.SvcRecsTableColCtrlDataAttrValPlanType && inputVal) {
            let $sessionTypeDropdown = $($thisTd).next('td')
                .children('select[' + _opts.SvcRecsTableColCtrlDataAttr + '=' + _opts.SvcRecsTableColCtrlDataAttrValServiceClass + ']');

            loadSessionTypes(key, inputVal, $tr, $sessionTypeDropdown);
        }

        // if the "via Telehealth" checkbox changes, reset the service selection
        if (attributeName == _opts.SvcRecsTableColCtrlDataAttrValViaTeleHealth) {
            var planType = SvcRecObj[_opts.SvcRecsTableColCtrlDataAttrValPlanType];
            var $sessionTypeDropdown = $tr.find('select[' + _opts.SvcRecsTableColCtrlDataAttr + '=' + _opts.SvcRecsTableColCtrlDataAttrValServiceClass + ']');
            loadSessionTypes(key, planType, $tr, $sessionTypeDropdown);
        }

    });

    // clear out original input when done
    if (!$elemSelector.hasClass("noReset")) {
        (isCheckbox) ? $inputElem.prop('checked', false) : $inputElem.val('');
    }

    // if the input element is 'Date of Service', then update DOS
    if ($inputElem.attr('id') == _opts.dateToCopy) {
        _drawSvcRecsTableBodyRows();
    }
}

/***************************************************************************
 * _init */
/**
 * Call once
 * 
 ***************************************************************************/

var _init = function (opts) {

   _initMode = true;
   _opts = opts;  
   _opts.SvcRecsTableRowDataAttr                                  = 'data-SvcRec-id';
   _opts.SvcRecsTableColCtrlDataAttr                              = 'data-SvcRec-ctrl';
   _opts.SvcRecsTableColCtrlDataAttrValRemove                     = 'remove';
   _opts.SvcRecsTableColCtrlDataAttrValDup                        = 'duplicate';
   _opts.SvcRecsTableColCtrlDataAttrValRMTSMoment                 = 'RMTSMoment';
   _opts.SvcRecsTableColCtrlDataAttrValPatientName                = 'patName';
   _opts.SvcRecsTableColCtrlDataAttrValPatID                      = 'patID';
   _opts.SvcRecsTableColCtrlDataAttrValDateOfService              = 'dosStr';
   _opts.SvcRecsTableColCtrlDataAttrValViaTeleHealth              = 'viaTeleHealth';
   _opts.SvcRecsTableColCtrlDataAttrValServiceClass               = 'serviceNameID';
   _opts.SvcRecsTableColCtrlDataAttrValServiceClassTypeID         = 'svcTypeId';
   _opts.SvcRecsTableColCtrlDataAttrValServiceClassSubTypeID      = 'svcSubType1Id';
   _opts.SvcRecsTableColCtrlDataAttrValServiceClasses             = 'serviceSelectionsJSON';
   _opts.SvcRecsTableColCtrlDataAttrValPlanType                   = 'planTypeSelectionID';
   _opts.SvcRecsTableColCtrlDataAttrValStartTime                  = 'startTime';
   _opts.SvcRecsTableColCtrlDataAttrValNumMins                    = 'numMins';
   _opts.SvcRecsTableColCtrlDataAttrValSessionDeliveryStatus      = 'sessionDeliveryStatus';
   _opts.SvcRecsTableColCtrlDataAttrValNotes                      = 'notes';
   _opts.SvcRecsTableColCtrlDataAttrValAppendType                 = 'appendType';
   _opts.SvcRecsTableColCtrlDataAttrValDuppedRecKey               = 'duppedRecKey';
   _opts.SvcRecsTableColCtrlDataAttrValHasSvcDetFlags             = 'hasSvcDetFlags';
   _opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag1                = 'svcDetFlag1';
   _opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag2                = 'svcDetFlag2';
   _opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag3                = 'svcDetFlag3';
   _opts.SvcRecsTableColCtrlDataAttrValSvcDetFlag4                = 'svcDetFlag4';
   _opts.SvcRecsTableColCtrlDataAttrValHasSvcDetBut               = 'hasSvcDetBut'; // has button for svDetails questions
   _opts.SvcRecsTableColCtrlDataAttrValOrpDocIDAutoSelected       = 'orpDocSelectionAuto';
   _opts.SvcRecsTableColCtrlDataAttrValOrpDocIDRequired           = 'orpDocSelectionRequired';
   _opts.SvcRecsTableColCtrlDataAttrValHasOrpDocID                = 'hasOrpDocumentID';
   _opts.SvcRecsTableColCtrlDataAttrValOrpDocID                   = 'orpDocumentID';
   _opts.SvcRecsTableColCtrlDataAttrValOrpDocName                 = 'orpDocumentName';
   _opts.SvcRecsTableColCtrlDataAttrValNotifications              = 'notifications';
   _opts.SvcRecsTableColCtrlDataAttrValFormQuestionsJSON          = 'svcNotesFormBuilderQuestionsJSON';
   _opts.SvcRecsTableColCtrlDataAttrValFormAnswersJSON            = 'svcNotesFormBuilderAnswersJSON';
   _opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalTracking     = 'hasPatientGoalTracking';
   _opts.SvcRecsTableColCtrlDataAttrValHasPatientGoalProgressJSON = 'patientGoalProgressJSON';
   
   _opts.SvcRecsTableColButsSubSelector = 'tr td i';
   _opts.SvcRecsTableColInputsSubSelector = 'tr td input, tr td select, tr td textarea';

  // probably a bad way to do this, but here we move the table to its own line
  $(_opts.SvcRecsTableSelector).parent().css({"display": "contents", "padding-left": "15px"});

   // callback for inputs only
   $(_opts.SvcRecsTableBodySelector).on( 'change'
                                       , _opts.SvcRecsTableColInputsSubSelector
	                                   , function(e){ _handleSvcRecsTableBodyRowActionForInput(e); });
   //callback for buttons only
   $(_opts.SvcRecsTableBodySelector).on( 'click'
                                       , _opts.SvcRecsTableColButsSubSelector
	                                   , function(e){ _handleSvcRecsTableBodyRowActionForButton(e); });   

   // clear the table (for the case where the user clicks the back button to go to this screen)
   $(_opts.SvcRecsTableBodySelector).children().remove();

   _SvcRecs  = new Map();

   let _SvcRecsJSON = $(_opts.SvcRecsTextAreaSelector).val();

   if (_SvcRecsJSON && _SvcRecsJSON != '[]') {

        let _SvcrecObjs = JSON.parse(_SvcRecsJSON);

        let promises = [];

         $.each(_SvcrecObjs, function (_idx, _SvcrecObj) {
             promises.push(
                 _createSvcRecObjPromise(_SvcrecObj)
                     .catch(function (err) {
                         return;
                     })
             );
        });

         // when all promises resolved, add to the map and draw table
         Promise.all(promises).then(function (svcRecObjs) {
             $.each(svcRecObjs, function (_index, _svcRecObj) {
                 _addRecToSvcRecs(_svcRecObj);
             });

            _drawSvcRecsTableBodyRows();
        });
   }
   else {
       // draw empty table
       _drawSvcRecsTableBodyRows();
   }

    _initMode = false;
 };

/****************************************************************************/

return {
    init                  : _init
  , addSvcRec             : _addSvcRec
  , addMultipleRecs       : _addMultipleRecs 
  , clearScvRecs          : _clearScvRecs
  , beginLiveGroupSession : _beginLiveGroupSession
  , copyValForAllRows     : _copyValForAllRows
};

})(jQuery);
