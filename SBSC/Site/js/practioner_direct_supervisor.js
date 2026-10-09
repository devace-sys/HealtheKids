var SpEdCare = (SpEdCare || {});

SpEdCare.directSupervisonSave = (function ($) {

'use strict';

/*#################################################################################################
  #
  #                                  Global Data Structures
  #
  #################################################################################################*/

var _opts = {};
var _currentSupervisors = new Map();
var _initMode      = true;

/*#################################################################################################
  #
  #                                  Private Methods
  #
  #################################################################################################*/

/***************************************************************************
 * _createsupervisingPracKey  */
/**
 * https://www.w3resource.com/javascript-exercises/javascript-math-exercise-23.php
 ***************************************************************************/

function _createsupervisingPracKey () {
  var dt = new Date().getTime();
  var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      var r = (dt + Math.random() * 16) % 16 | 0;
      dt = Math.floor(dt / 16);
      return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
  });
  return uuid;
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _createSupervisorObj (supervisingPracID, supervisingPracName, startDate, endDate, shareNotes) {
  var supervisorObj = {};
  supervisorObj.supervisingPracID    = '' + supervisingPracID;
  supervisorObj.supervisingPracName  = supervisingPracName;
  supervisorObj.startDate = startDate;
  supervisorObj.endDate = endDate;
  supervisorObj.shareNotes = shareNotes;

  return supervisorObj;
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _currentSupervisingPracsToArray () {
   let supervisorObjs = [];
   _currentSupervisors.forEach(function(supervisorObj, _idx) {
      supervisorObjs.push(supervisorObj);  
   });
   return supervisorObjs;
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _currentSupervisingPracsToJSON () {
  let supervisorObjs = _currentSupervisingPracsToArray();
  return JSON.stringify(supervisorObjs);
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _currentSupervisingPracsToTA () {
  let supervisorsJSON = _currentSupervisingPracsToJSON();
  $(_opts.supervisingPracsTextAreaSelector).val(supervisorsJSON);
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _supervisingPracsDataToTA () {
  _currentSupervisingPracsToTA();
};

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _createSupervisingPracsTableRowCommonMkup (participantObj, supervisingPracKey) {
  return '<tr ' + _opts.supervisingPracsTableRowDataAttr  + '="' + supervisingPracKey + '"></tr>';
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _createSupervisingPracsTableColsCommonMkup(supervisingPracObj) {
    let checkedString = (supervisingPracObj.shareNotes) ? 'checked' : ''; // for shareNotes checkbox

    return '<td>' + supervisingPracObj.supervisingPracName + '</td>'
         + '<td><input type="date" '     + _opts.supervisingPracsTableColCtrlDataAttr + '=' + _opts.supervisingPracsTableColCtrlDataAttrValStartDate  + ' value="' + supervisingPracObj.startDate  + '" /></td>'
         + '<td><input type="date" '     + _opts.supervisingPracsTableColCtrlDataAttr + '=' + _opts.supervisingPracsTableColCtrlDataAttrValEndDate    + ' value="' + supervisingPracObj.endDate    + '" /></td>'
         + '<td><input type="checkbox" ' + _opts.supervisingPracsTableColCtrlDataAttr + '=' + _opts.supervisingPracsTableColCtrlDataAttrValShareNotes + ' value="' + supervisingPracObj.shareNotes + '" ' + checkedString + ' /></td>';
}

/***************************************************************************
 * updateCurrentSupervisingPracs */
/**
 * updates current supervising pracs when a value is entered
 ***************************************************************************/

function _updateCurrentsupervisingPracs(key, val, field) {
   var supervisorObj = _currentSupervisors.get(key);
   supervisorObj[field] = val;
   _currentSupervisors.set(key, supervisorObj);
   _supervisingPracsDataToTA();
}

/***************************************************************************
 * _sortCurrentRosterByName */
/**
 * 
 ***************************************************************************/

function _sortCurrentSupervisingPracsByName () {
  
  let _arr = _currentSupervisingPracsToArray();
  let _sortedMap = new Map();
  
  _arr.sort(function(a, b) {
     
	if (a.name < b.name) { return -1; }
    if (a.name > b.name) { return 1; }
    return 0;
  });
  
   $.each( _arr, function( _idx, _pObj ) {
     let _pk = _createsupervisingPracKey (_pObj);
	 _sortedMap.set(_pk,_pObj);
   });
   _currentSupervisors = new Map(_sortedMap);
}


/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _addPracToSupervisingPracs (supervisingPracObj) {
 
  let _supervisingPracKey = _createsupervisingPracKey(supervisingPracObj);
  supervisingPracObj.supervisingPracName = supervisingPracObj.supervisingPracName.toUpperCase();
  if (_initMode === false) { 
    if (_currentSupervisors.has(_supervisingPracKey)) return null;
  }
  
  _currentSupervisors.set(_supervisingPracKey, supervisingPracObj); 
  
  if (_initMode == false)
  {                   
    _supervisingPracsDataToTA();
  }
  return _supervisingPracKey;
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _removePracFromSupervisingPracs (supervisingPracKey) {
  if (_currentSupervisors.has(supervisingPracKey) === false) return;
  _currentSupervisors.delete(supervisingPracKey);  
  _supervisingPracsDataToTA();
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _drawSupervisingPracsTableBodyRow (participantObj, supervisingPracKey) {	 

  let $_row = $(_createSupervisingPracsTableRowCommonMkup(participantObj,supervisingPracKey));  
  let $_tdCtrls = $('<td></td>');  
  let $_butRem = $('<button ' + _opts.supervisingPracsTableColCtrlDataAttr + '="' +_opts.supervisingPracsTableColCtrlDataAttrValRemove + '" type="button" title="Remove from Roster">&nbsp;</button>');
  $($_butRem).button({text:false,icons:{primary:'ui-icon-minusthick'}});
  $($_tdCtrls).append($_butRem);
  $($_row).append($_tdCtrls);
  $($_row).append(_createSupervisingPracsTableColsCommonMkup (participantObj));
  $(_opts.supervisingPracsTableBodySelector).append($_row);

}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _drawSupervisingPracsTableBodyRows() {
  _sortCurrentSupervisingPracsByName();
  $(_opts.supervisingPracsTableBodySelector).children().remove();

  _currentSupervisors.forEach(function(_supervisingPracObj, _supervisingPracKey) {
    _drawSupervisingPracsTableBodyRow(_supervisingPracObj, _supervisingPracKey);
  })
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _identifySupervisingPracsTableBodyRowAction(e, whatElement) {

  let _rowAction = {};
  _rowAction.whatInp = $(e.target).closest(whatElement);
  _rowAction.whatCol = $(_rowAction.whatInp).closest('td');
  _rowAction.whatRow = $(_rowAction.whatCol).closest('tr');
  _rowAction.doWhat  = $(_rowAction.whatInp).attr(_opts.supervisingPracsTableColCtrlDataAttr);
  _rowAction.supervisingPracKey = $(_rowAction.whatRow).attr(_opts.supervisingPracsTableRowDataAttr);
  return _rowAction;
}

/***************************************************************************
 * _handleSupervisingPracsTableBodyRowActionForButton */
/**
 * 
 ***************************************************************************/

function _handleSupervisingPracsTableBodyRowActionForButton (e) {
  let _rowAction = _identifySupervisingPracsTableBodyRowAction(e, 'button');

  // remove record if needed
  if (_rowAction.doWhat == _opts.supervisingPracsTableColCtrlDataAttrValRemove) {
	_removePracFromSupervisingPracs(_rowAction.supervisingPracKey);
	$(_rowAction.whatRow).remove(_rowAction.doWhat == _opts.supervisingPracsTableColCtrlDataAttrValStartDate);
  }

}

/***************************************************************************
 * _handleSupervisingPracsTableBodyRowActionForInput */
/**
 * 
 ***************************************************************************/

function _handleSupervisingPracsTableBodyRowActionForInput (e) {
  let _rowAction = _identifySupervisingPracsTableBodyRowAction(e, 'input');

  // if start or end date was entered, store to roster
    if (_rowAction.doWhat == _opts.supervisingPracsTableColCtrlDataAttrValStartDate || _rowAction.doWhat == _opts.supervisingPracsTableColCtrlDataAttrValEndDate) {
      _updateCurrentsupervisingPracs(_rowAction.supervisingPracKey, _rowAction.whatInp.val(), _rowAction.doWhat);
  } 

  // if checkbox was checked, store to roster
  else if (_rowAction.doWhat == _opts.supervisingPracsTableColCtrlDataAttrValShareNotes) {
      _updateCurrentsupervisingPracs(_rowAction.supervisingPracKey, _rowAction.whatInp.prop("checked"), _rowAction.doWhat);
  }

}

/*#################################################################################################
  #
  #                                  Public Methods
  #
  #################################################################################################*/

/***************************************************************************
 * _addParticipant */
/**
 * 
 ***************************************************************************/

var _addParticipant  = function (supervisingPracID, supervisingPracName, startDate, endDate, shareNotes) {
  let _participantObj = _createSupervisorObj (supervisingPracID, supervisingPracName, startDate, endDate, shareNotes);
  let _supervisingPracKey = _addPracToSupervisingPracs (_participantObj);
  if (!_supervisingPracKey) return;
  _drawSupervisingPracsTableBodyRows();
}

/***************************************************************************
 * _init */
/**
 * Call once
 * 
 ***************************************************************************/

var _init = function (opts) {

   if (_initMode === false) return;
   _initMode = true;
   _opts = opts;  
   _opts.supervisingPracsTableRowDataAttr                  = 'data-supervisor-id';
   _opts.supervisingPracsTableColCtrlDataAttr              = 'data-supervisor-ctrl';
   _opts.supervisingPracsTableColCtrlDataAttrValRemove     = 'remove';
   _opts.supervisingPracsTableColCtrlDataAttrValStartDate  = 'startDate';
   _opts.supervisingPracsTableColCtrlDataAttrValEndDate    = 'endDate';
   _opts.supervisingPracsTableColCtrlDataAttrValShareNotes = 'shareNotes';
   
   _opts.participantTableColButsSubSelector = 'tr td button';
   _opts.participantTableColInputsSubSelector = 'tr td input';

   // callback for inputs only
   $(_opts.supervisingPracsTableBodySelector).on( 'change'
                                       , _opts.participantTableColInputsSubSelector
	                                   , function(e){ _handleSupervisingPracsTableBodyRowActionForInput(e); });
   // callback for buttons only
   $(_opts.supervisingPracsTableBodySelector).on( 'click'
                                       , _opts.participantTableColButsSubSelector
	                                   , function(e){ _handleSupervisingPracsTableBodyRowActionForButton(e); });   

   
   //$(_opts.rosterChangesTableBodySelector).on( 'change'
   //                                         , _opts.participantTableColInputsSubSelector
	  //                                      , function(e){_handleRosterChangesTableBodyRowAction(e);});   

   //_initialRoster  = new Map();
   _currentSupervisors  = new Map();
   //_rosterChanges = new Map();

   let _participantsJSON = $(_opts.supervisingPracsTextAreaSelector).val();
   let _participantObjs = JSON.parse(_participantsJSON);


   $.each( _participantObjs, function( _idx, _participantObj ) {
     _addPracToSupervisingPracs (_participantObj);
   });
   //_initialRoster = new Map(_currentRoster);
   _drawSupervisingPracsTableBodyRows();
    
   _initMode = false;
 };

/****************************************************************************/

return {
    init: _init
  , addParticipant : _addParticipant

};

})(jQuery);
