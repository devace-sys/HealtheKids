var SpEdCare = (SpEdCare || {});

SpEdCare.recPracQualification = (function ($) {

'use strict';

/*#################################################################################################
  #
  #                                  Global Data Structures
  #
  #################################################################################################*/

var _opts = {};
var _Recs  = new Map();
var _initMode         = true;

/*#################################################################################################
  #
  #                                  Global Variables
  #
  #################################################################################################*/

/*#################################################################################################
  #
  #                                  Private Methods
  #
  #################################################################################################*/

/***************************************************************************
 * _createRecKey  */
/**
 * https://www.w3resource.com/javascript-exercises/javascript-math-exercise-23.php
 ***************************************************************************/

function _createRecKey () {
  var dt = new Date().getTime();
  var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      var r = (dt + Math.random() * 16) % 16 | 0;
      dt = Math.floor(dt / 16);
      return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
  });
  return uuid;
}

/***************************************************************************
 * _createRecObj */
/**
 * 
 ***************************************************************************/

function _createRecObj (pracTypeID, pracTypeName, isLifetime) {
    var RecObj = {};
    
    // set default values
    RecObj.pracTypeID   = pracTypeID;
    RecObj.pracTypeName = pracTypeName;

    RecObj[_opts.RecsTableColCtrlDataAttrValLicenseNum] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValStartDate] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValEndDate] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValFullName] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValIsLifetime] = isLifetime;
  
    return RecObj;
}

/***************************************************************************
 * _currentRecsToArray */
/**
 * 
 ***************************************************************************/

function _currentRecsToArray () {
   let RecObjs = [];

    _Recs.forEach(function (RecObj, _idx) {
       RecObjs.push(JSON.parse(JSON.stringify(RecObj)));
   });
   return RecObjs;
}

/***************************************************************************
 * _currentRecsToJSON */
/**
 * 
 ***************************************************************************/

function _currentRecsToJSON () {
  let RecObjs = _currentRecsToArray();
  return JSON.stringify(RecObjs);
}

/***************************************************************************
 * _currentRecsToTA */
/**
 * 
 ***************************************************************************/

function _currentRecsToTA () {
  let RecsJSON = _currentRecsToJSON();
  $(_opts.RecsQualificationTextAreaSelector).val(RecsJSON);
}

/***************************************************************************
 * _createRecsTableRowCommonMkup */
/**
 * 
 ***************************************************************************/

function _createRecsTableRowCommonMkup (RecObj,RecKey) {
  return '<tr ' + _opts.RecsTableRowDataAttr  + '="' + RecKey + '"></tr>';
}

/***************************************************************************
 * _createRecTableColsCommonMkup */
/**
 *
 ***************************************************************************/

function _createRecTableColsCommonMkup(RecObj) {
    let checkedString = (RecObj[_opts.RecsTableColCtrlDataAttrValIsLifetime]) ? 'checked' : ''; // for isLifetime checkbox

    return '<td>' + RecObj.pracTypeName + '</td>'
        + '<td><input type="text" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValLicenseNum + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValLicenseNum] + '"></td>'
        + '<td><input type="date" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValStartDate + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValStartDate] + '"></td>'
        + '<td><input type="date" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValEndDate + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValEndDate] + '"></td>'
        + '<td><input type="text" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValFullName + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValFullName] + '"></td>'
        + '<td><input type="checkbox" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValIsLifetime + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValIsLifetime] + '" ' + checkedString + ' /></td>';
}

/***************************************************************************
 * _updateCurrentRecsForSpecificField */
/**
 * updates current
 ***************************************************************************/

function _updateCurrentRecsForSpecificField(key, val, whatField) {
    var RecObj = _Recs.get(key);

    RecObj[whatField] = val;
    _Recs.set(key, RecObj);
    _currentRecsToTA();
}

/***************************************************************************
 * _addRecToRecs */
/**
 * 
 ***************************************************************************/

function _addRecToRecs (_RecObj) {
 
  let _RecKey = _createRecKey(_RecObj);

  if (_initMode === false) { 
    if (_Recs.has(_RecKey)) return null;
  }
  
  _Recs.set(_RecKey, _RecObj); 

  _currentRecsToTA();

  return _RecKey;
}

/***************************************************************************
 * _removeRecFromRecs */
/**
 * 
 ***************************************************************************/

function _removeRecFromRecs (RecKey) {
  if (_Recs.has(RecKey) === false) return;
  _Recs.delete(RecKey);  
  _currentRecsToTA();
}

/***************************************************************************
 * _drawRecsTableBodyRow */
/**
 * 
 ***************************************************************************/

function _drawRecsTableBodyRow (RecObj, RecKey) {	
    let $_row = $(_createRecsTableRowCommonMkup(RecObj,RecKey));
      
    let $_tdRemove = $('<td></td>');  
    let $_butRem = $('<i ' + _opts.RecsTableColCtrlDataAttr + '="' +_opts.RecsTableColCtrlDataAttrValRemove + '" class="fa fa-trash-alt" title="Remove Record"></i>');
    $($_tdRemove).append($_butRem);
    $($_row).append($_tdRemove);
    
    $($_row).append(_createRecTableColsCommonMkup (RecObj));
    $(_opts.RecsQualificationTableBodySelector).append($_row);
}

/***************************************************************************
 * _drawRecsTableBodyRows */
/**
 * 
 ***************************************************************************/

function _drawRecsTableBodyRows() {
  _currentRecsToTA();

  $(_opts.RecsQualificationTableBodySelector).children().remove();

  _Recs.forEach(function(_RecObj, _RecKey) {
      _drawRecsTableBodyRow(_RecObj, _RecKey);
  })
}

/***************************************************************************
 * _identifyRecsTableBodyRowAction */
/**
 * 
 ***************************************************************************/

function _identifyRecsTableBodyRowAction(e, whatElement) {
  let _rowAction = {};
  _rowAction.whatInp = $(e.target).closest(whatElement);
  _rowAction.whatCol = $(_rowAction.whatInp).closest('td');
  _rowAction.whatRow = $(_rowAction.whatCol).closest('tr');
  _rowAction.doWhat  = $(_rowAction.whatInp).attr(_opts.RecsTableColCtrlDataAttr);
  _rowAction.RecKey = $(_rowAction.whatRow).attr(_opts.RecsTableRowDataAttr);
  return _rowAction;
}

/***************************************************************************
 * _removeRecFromTable */
/**
 * 
 ***************************************************************************/

function _removeRecFromTable (rowAction) {
    _removeRecFromRecs(rowAction.RecKey);
    $(rowAction.whatRow).remove();
}

/***************************************************************************
 * _handleRecsTableBodyRowActionForButton */
/**
 * 
 ***************************************************************************/

function _handleRecsTableBodyRowActionForButton (e) {
    let _rowAction = _identifyRecsTableBodyRowAction(e, 'i');
    var RecObj = _Recs.get(_rowAction.RecKey);

    // remove record if needed
    if (_rowAction.doWhat == _opts.RecsTableColCtrlDataAttrValRemove) {
        _removeRecFromTable(_rowAction);
    }
}

/***************************************************************************
 * _handleRecsTableBodyRowActionForInput */
/**
 * 
 ***************************************************************************/

function _handleRecsTableBodyRowActionForInput (e) {
  let _rowAction = _identifyRecsTableBodyRowAction(e, e.currentTarget.localName);
  
  // decide what value we want to set for this field
  let inputVal = _rowAction.whatInp.val();
  if (_rowAction.whatInp.attr('type') == 'checkbox') inputVal = _rowAction.whatInp.prop('checked');

  // enter input change into the hidden textarea json
  _updateCurrentRecsForSpecificField(_rowAction.RecKey, inputVal, _rowAction.doWhat);
}

/*#################################################################################################
  #
  #                                  Public Methods
  #
  #################################################################################################*/

/***************************************************************************
 * _addRec */
/**
 * 
 ***************************************************************************/

var _addRec  = function (pracTypeID, pracTypeName, isLifetime) {
  let _RecObj = _createRecObj (pracTypeID, pracTypeName, isLifetime);
  let _RecKey = _addRecToRecs (_RecObj);
  if (!_RecKey) return;
    _drawRecsTableBodyRows();
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
   _opts.RecsTableRowDataAttr                  = 'data-Rec-id';
   _opts.RecsTableColCtrlDataAttr              = 'data-Rec-ctrl';
   _opts.RecsTableColCtrlDataAttrValID         = 'id';
   _opts.RecsTableColCtrlDataAttrValRemove     = 'remove';

   _opts.RecsTableColCtrlDataAttrValLicenseNum = 'licenseNum'; 
   _opts.RecsTableColCtrlDataAttrValStartDate  = 'startDate'; 
   _opts.RecsTableColCtrlDataAttrValEndDate    = 'endDate'; 
   _opts.RecsTableColCtrlDataAttrValFullName   = 'fullName'; 
   _opts.RecsTableColCtrlDataAttrValIsLifetime = 'isLifetime'; 
   
   _opts.RecsTableColButsSubSelector = 'tr td i';
   _opts.RecsTableColInputsSubSelector = 'tr td input, tr td select, tr td textarea';

   // callback for inputs only
   $(_opts.RecsQualificationTableBodySelector).on( 'change'
                                       , _opts.RecsTableColInputsSubSelector
	                                   , function(e){ _handleRecsTableBodyRowActionForInput(e); });
   //callback for buttons only
   $(_opts.RecsQualificationTableBodySelector).on( 'click'
                                       , _opts.RecsTableColButsSubSelector
	                                   , function(e){ _handleRecsTableBodyRowActionForButton(e); });   

   // clear the table (for the case where the user clicks the back button to go to this screen)
   $(_opts.RecsQualificationTableBodySelector).children().remove();

   _Recs  = new Map();

   let _RecsJSON = $(_opts.RecsQualificationTextAreaSelector).val();

    if (_RecsJSON && _RecsJSON != '[]') {
        let _RecObjs = JSON.parse(_RecsJSON);

        $.each(_RecObjs, function (_idx, _RecObj) {

            // set defaults if inputs not filled
            _RecObj[_opts.RecsTableColCtrlDataAttrValSaveType] = $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValName])
                _RecObj[_opts.RecsTableColCtrlDataAttrValName] = null;

            _addRecToRecs(_RecObj);
        });
    }

    _drawRecsTableBodyRows();

    _initMode = false;
 };

/****************************************************************************/

return {
    init: _init
  , addRec : _addRec
};

})(jQuery);
