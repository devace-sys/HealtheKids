/* Requires jquery */

var MBA = (MBA || {});

MBA.util = (function ($) {

'use strict';

const statePattern = /^\[\d{1,}\]/i;
const codePattern  = /\d{1,}/;

const BS_CSS_BG_PRIMARY   = 'bg-primary';
const BS_CSS_BG_SECONDARY = 'bg-secondary';
const BS_CSS_BG_SUCCESS   = 'bg-success';
const BS_CSS_BG_DANGER    = 'bg-danger';
const BS_CSS_BG_WARNING   = 'bg-warning';
const BS_CSS_BG_INFO      = 'bg-info';
const BS_CSS_BG_LIGHT     = 'bg-light';
const BS_CSS_BG_DARK      = 'bg-dark';

const BS_CSS_ALERT_PRIMARY   = 'alert alert-primary';
const BS_CSS_ALERT_SECONDARY = 'alert alert-secondary';
const BS_CSS_ALERT_SUCCESS   = 'alert alert-success';
const BS_CSS_ALERT_DANGER    = 'alert alert-danger';
const BS_CSS_ALERT_WARNING   = 'alert alert-warning';
const BS_CSS_ALERT_INFO      = 'alert alert-info';
const BS_CSS_ALERT_LIGHT     = 'alert alert-light';
const BS_CSS_ALERT_DARK      = 'alert alert-dark';

const FA_CSS_CHECK_CIRCLE       = 'fas fa-check-circle';
const FA_CSS_INFO_CIRCLE        = 'fas fa-info-circle';
const FA_CSS_EXCLAMATION_CIRCLE = 'fas fa-exclamation-circle';
const FA_CSS_TIMES_CIRCLE       = 'fas fa-times-circle';

var _RETURN_CODE = {};

/***************************************************************************
 * initReturnCodes */
/**
 * Sets up a pseudo enum
 ***************************************************************************/

function _initReturnCodes() {
   _RETURN_CODE = {}
   _RETURN_CODE.SUCCESS = 0;
   _RETURN_CODE.INFO = 1;
   _RETURN_CODE.WARNING = 2;
   _RETURN_CODE.CRITICAL = 3;
   _RETURN_CODE.ERROR = 4;
   _RETURN_CODE.ABORT_OR_CANCEL = 5;
   _RETURN_CODE.SESSION_EXPIRE = 12;  // Keep in synch with database exception #
   _RETURN_CODE.PASSWORD_LOCK = 14;
   _RETURN_CODE.DUP_RECORD = 20;
   _RETURN_CODE.REDIRECT = 50;
   _RETURN_CODE.FATAL = 99;
   Object.freeze(_RETURN_CODE);
}


var _returnCodeToElementClasses = function (returnCode) {
    var elementClasses = {};
    elementClasses.bsAlert = '';
    elementClasses.faIcon = '';

    if (returnCode == _RETURN_CODE.SUCCESS) {
        elementClasses.bsAlert = BS_CSS_ALERT_SUCCESS;
        elementClasses.faIcon  = FA_CSS_CHECK_CIRCLE;
    }
    else if (returnCode == _RETURN_CODE.INFO) {
        elementClasses.bsAlert = BS_CSS_ALERT_INFO;
        elementClasses.faIcon  = FA_CSS_INFO_CIRCLE;
    }
    else if (returnCode == _RETURN_CODE.WARNING) {
        elementClasses.bsAlert = BS_CSS_ALERT_WARNING;
        elementClasses.faIcon  = FA_CSS_EXCLAMATION_CIRCLE;
    }
    else if (returnCode == _RETURN_CODE.DUP_RECORD) {
        elementClasses.bsAlert = BS_CSS_ALERT_WARNING;
        elementClasses.faIcon = FA_CSS_EXCLAMATION_CIRCLE;
    }
    else if (returnCode == _RETURN_CODE.CRITICAL) {
        elementClasses.bsAlert = BS_CSS_ALERT_DANGER;
        elementClasses.faIcon  = FA_CSS_TIMES_CIRCLE;
    }
    else if (returnCode == _RETURN_CODE.ERROR) {
        elementClasses.bsAlert = BS_CSS_ALERT_DANGER;
        elementClasses.faIcon = FA_CSS_TIMES_CIRCLE;
    }
    else if (returnCode == _RETURN_CODE.SESSION_EXPIRE) {
        elementClasses.bsAlert = BS_CSS_ALERT_DANGER;
        elementClasses.faIcon = FA_CSS_TIMES_CIRCLE;
    }   
    else if (returnCode == _RETURN_CODE.FATAL) {
        elementClasses.bsAlert = BS_CSS_ALERT_DANGER;
        elementClasses.faIcon  = FA_CSS_TIMES_CIRCLE;
    }
    else {
        elementClasses.bsAlert = '';
        elementClasses.faIcon  = '';
    }
    return elementClasses;
}


/***************************************************************************
 * createNewUUID */
/**
 * Creates UUID
 * https://www.w3resource.com/javascript-exercises/javascript-math-exercise-23.php
 ***************************************************************************/

var _createNewUUID = function() {
  var dt = new Date().getTime();
  var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      var r = (dt + Math.random() * 16) % 16 | 0;
      dt = Math.floor(dt / 16);
      return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
  });
  return uuid;
}

/***************************************************************************
 * factorToPercent
/**
 * Takes a number between 1 to 100 and converts it to a fractional value.
 * 
 ***************************************************************************/

var _factorToPercent = function (factor)  {
    const FACTOR_ERROR_MSG = 'Factor must be an integer value between 0 and 100';
    if (!Number.isInteger(factor)) { throw FACTOR_ERROR_MSG; return null; }
    if (factor < 1) { throw FACTOR_ERROR_MSG; return null; }
    if (factor > 100) { throw FACTOR_ERROR_MSG; return null; }
    let pct = (factor * .01);
    return pct;
}

/***************************************************************************
 * getCurrentViewportWidthInPx
/**
 * Courtesey of ryanve https://stackoverflow.com/a/8876069
 ***************************************************************************/

var _getCurrentViewportWidthInPx = function () {
  return Math.max(document.documentElement.clientWidth || 0, window.innerWidth || 0);
}

/***************************************************************************
 * getCurrentViewportHeightInPx
/**
 * Courtesey of ryanve https://stackoverflow.com/a/8876069 
 ***************************************************************************/

var _getCurrentViewportHeightInPx = function () {  
  return Math.max(document.documentElement.clientHeight || 0, window.innerHeight || 0);
}

/***************************************************************************
 * computePercentageOfViewportWidthInPx
/**
 * Computes a percentage (0-100) of current width in px 
 * This is functionally equivalent to CSS vw
 ***************************************************************************/

var _computePercentOfViewportWidthInPx = function (factor) {
  let cvw = _getCurrentViewportWidthInPx();
  let pct = _factorToPercent(factor);
  let pvw = Math.round((cvw * pct));
  return pvw;
}

/***************************************************************************
 * computePercentageOfViewportHeightInPx
/**
 * Computes a percentage (0-100) of current height in px 
 * This is functionally equivalent to CSS vh
 ***************************************************************************/

var _computePercentOfViewportHeightInPx = function (factor) {
    let cvh = _getCurrentViewportHeightInPx();
    let pct = _factorToPercent(factor);
    let pvh = Math.round((cvh * pct));
    return pvh;
}

/***************************************************************************
 * tableBodyToJsonListBase */
/**
 * Base function for generating a JSON list of form field data from HTML
 * form fields inside an HTML table body.
 ***************************************************************************/

  var _tableBodyToJsonListBase = function (tblBodyID, listName, fnPopulateListEntryObj) {
  return new Promise((resolve, reject) => {

    if (!tblBodyID) reject(new Error("Table body id was not provided"));
    if (!listName)  reject(new Error("List name not provided"));
    if (!fnPopulateListEntryObj) reject(new Error("Create list entry object function not provided"));

    let retObj = {};
    let fldObjs = [];
    let tblBodyRows = '#' + tblBodyID + ' tr';

    $(tblBodyRows).each(function (rowIdx) {
        let tblBodyRow = $(this);
        var listEntryObj = {}

        $(tblBodyRow).children().each(function (colIdx) {
            let tblBodyCol = $(this);
            $(tblBodyCol).children(':input').each(function (fldIdx) {
                var fld = $(this);
                listEntryObj = fnPopulateListEntryObj (listEntryObj, rowIdx, colIdx, fldIdx, fld);                        
            }); /* Form fields */                             
        }); /* Cols */
        fldObjs.push(listEntryObj);
      }); /* Rows*/
    retObj[listName] = fldObjs;
    resolve(JSON.stringify(retObj));
   });
 }
 

/***************************************************************************
 * tableBodyToJsonNameValueList */
/**
 * Generates a JSON list of form field name,value pair data from HTML form
 * fields inside an HTML table body.
 ***************************************************************************/

var _tableBodyToJsonNameValueList = function (tblBodyID, listName) {
    return new Promise((resolve, reject) => {
        
        var fnPopulateListEntryObj = function (listEntryObj, rowIdx, colIdx, fldIdx, fld) {
          listEntryObj[fld.attr('name')] = fld.val();
          return listEntryObj;
        }
        _tableBodyToJsonListBase(tblBodyID, listName, fnPopulateListEntryObj).then((jsonData) => {
            resolve(jsonData);
        }).catch(convError => {
            reject(convError);
        });
    });   
}

/***************************************************************************
 * jsonNameValueListToTableBody */
/**
 * 
 * 
 ***************************************************************************/

var _jsonNameValueListToTableBody = function (jsonData, listName, tblBodyID) {  
  let dataObj = JSON.parse(jsonData);
  let fldObjs = dataObj[listName];
  let tblBodyRows = '#' + tblBodyID + ' tr';
  $(tblBodyRows).each(function (rowIdx) {
    let tblBodyRow = $(this);
    let rowObj = fldObjs[rowIdx];
    $(tblBodyRow).children().each(function (colIdx) {
        let tblBodyCol = $(this);
        $(tblBodyCol).children(':input').each(function (fldIdx) {            
            var fld = $(this);                        
            let fldName = $(fld).attr('name');
            let fldVal = rowObj[fldName];            
            $(fld).val(fldVal);
          }); /* Form fields */
      }); /* Cols */
  }); /* Rows*/
}; 

/***************************************************************************
 * getFormAction */
/**
 * 
 * 
 ***************************************************************************/

function getFormAction(formID) {
   return  $('#' + formID).attr('action');
}

/***************************************************************************
 * _convertFromOneToManyKeyValuesToOneToOne */
/**
 * Converts from one to many key (key: value1, key: value2) to one to array
 * (key: [value1, value2])
 * 
 ***************************************************************************/
function _convertFromOneToManyKeyValuesToOneToArray(frmNameValues, name) {
    let valArr = []; // value to be returned

    // iterate through the keys and add values
    frmNameValues.forEach(function (value) {
        if (value.name == name) {
            valArr.push(value.value);
        }
    });

    // if single value, no need for array
    if (valArr.length == 1) valArr = valArr[0];

    // if no value, set back to original
    else if (valArr.length < 1) valArr = frmNameValues[name];

    // if multi value, return stringified array
    else valArr = JSON.stringify(valArr);

    return valArr;
}

/***************************************************************************
 * formToObj */
/**
 * Generates an object containing form name and value pairs
 * 
 ***************************************************************************/

var _formToObj = function (formID) {
    return new Promise((resolve, reject) => {
      if (!formID) reject(new Error('Form id must be provided'));
      var frmObj = {};
      let frmSelector   = '#' + formID;
      let frmNameValues = $(frmSelector).serializeArray();
      $.each(frmNameValues, function (idx, frmNameValue) {
          frmObj[frmNameValue.name] = _convertFromOneToManyKeyValuesToOneToArray(frmNameValues, frmNameValue.name);
      });
      resolve(frmObj);
    });
}

/***************************************************************************
 * formToJSON */
/**
 * Generates a JSON list of form field name,value pair data from HTML form
 * 
 ***************************************************************************/

var _formToJSON = function (formID) {   
    return new Promise((resolve, reject) => {    
        _formToObj(formID).then(frmObj => {let json = JSON.stringify(frmObj); resolve(json);})
                         .catch(convErr => { reject(new Error(convErr)) });
    });
}

/***************************************************************************
 * _objToForm */
/**
 * formObj needs to be the same object that _formToOb returns
 ***************************************************************************/

var _objToForm = function (formID, formObj, bsFormFields) {  
 
  if (!formID) return;
  if (!formObj) return;
  let formSel = '#' + formID;
  $(formSel).trigger('reset');     /* Reset back to defaults.  This takes care of checkboxes*/
  $(formSel).deserialize(formObj); /* Replace old values with new values */
  
  /* Boot strap specific */
  
  if (bsFormFields === true)
  {
    /* Takes care of updating btn-groups */
  
    $(formSel + ' .btn-group input').each(function (i) {
      if ($(this).is(':checked')) {
        $(this).closest('label').addClass('active');
      }
      else {
        $(this).closest('label').removeClass('active');
      }
    });
  }
}

/***************************************************************************
 * detailStrToDetailObj */
/**
 * Converts [code] msg to object containing code and msg
 * 
 ***************************************************************************/

var _detailStrToDetailObj = function (detailStr, defaultCode) {
  var detailObj = { code: (defaultCode), msg: (detailStr) };
  if (statePattern.test(detailStr) == true) {
      let stateCodeContainer = statePattern.exec(detailStr); // Extract code container [x]
      detailObj.code = codePattern.exec(stateCodeContainer); // Extract code itself x
      detailObj.msg = detailStr.replace(statePattern, "");   // Remove code container from detail leaving just detail text
  }
  return detailObj;
}

/***************************************************************************
 * _detailObjToListItemElement */
/**
 * 
 * li.mba-detail
 * i.mba-detail-icon
 * span.mba-detail-msg
 ***************************************************************************/

var _detailObjToListItemElement = function (detailObj) {
    let elementClasses = _returnCodeToElementClasses(detailObj.code);
    var $li = $('<li class="mba-detail"></li>');
    var $fa = $('<i class="mba-detail-icon"></i>');
    var $msg = $('<span class="mba-detail-msg">' + detailObj.msg + '</span>');
    $li.addClass(elementClasses.bsAlert);
    $fa.addClass(elementClasses.faIcon);
    $li.append($fa, $msg);
    return $li;
}

/***************************************************************************
 * _detailObjsToUnorderedListElement */
/**
 * 
 * ul.mba.details
 ***************************************************************************/

var _detailObjsToUnorderedListElement = function (detailObjs) {
  var $ul = $('<ul class="mba-details"></ul>');
  $.each(detailObjs, function (i, detailObj) {
        var $li = _detailObjToListItemElement(detailObj);
        $ul.append($li);
  });
  return $ul;
}

/****************************************************************************/

_initReturnCodes();

return {
    RETURN_CODE: _RETURN_CODE
  , returnCodeToElementClasses: _returnCodeToElementClasses
  , createNewUUID: _createNewUUID
  , factorToPercent : _factorToPercent
  , getCurrentViewportWidthInPx : _getCurrentViewportWidthInPx
  , getCurrentViewportHeightInPx : _getCurrentViewportHeightInPx
  , computePercentOfViewportWidthInPx: _computePercentOfViewportWidthInPx
  , computePercentOfViewportHeightInPx: _computePercentOfViewportHeightInPx
  , tableBodyToJsonNameValueList: _tableBodyToJsonNameValueList
  , jsonNameValueListToTableBody: _jsonNameValueListToTableBody
  , formToObj : _formToObj
  , formToJSON: _formToJSON
  , objToForm: _objToForm
  , detailStrToDetailObj: _detailStrToDetailObj
  , detailObjToListItemElement: _detailObjToListItemElement
  , detailObjsToUnorderedListElement: _detailObjsToUnorderedListElement
};

})(jQuery);
