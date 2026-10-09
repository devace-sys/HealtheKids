var SpEdCare = (SpEdCare || {});

SpEdCare.rmtsParticipantRosterSave = (function ($) {

'use strict';

/*#################################################################################################
  #
  #                                  Global Data Structures
  #
  #################################################################################################*/

var _opts = {};

var _initialRoster = new Map();
var _currentRoster = new Map();
var _rosterChanges = new Map();
var _initMode      = true;
var _sortCurrentRosterTableByWhatCol = 1;

/*#################################################################################################
  #
  #                                  Private Methods
  #
  #################################################################################################*/

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _createParticipantKey (participantObj) {
  return '' + participantObj.id;
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _createParticipantObj (id, name, title, submitClaimsStr) {
  var _participantObj = {};
  _participantObj.id    = id;
  _participantObj.name  = name;
  _participantObj.title = title;
  _participantObj.submitClaimsStr = submitClaimsStr;
  return _participantObj;
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _createParticipantChangeObj (participantObj, action, effectiveDate) {
  var _participantChangeObj = {};

  _participantChangeObj.action              = action;
  _participantChangeObj.effectiveDate       = effectiveDate;
  _participantChangeObj.participationStatus = '';
  _participantChangeObj.participating       = '';
  _participantChangeObj.participantObj      = participantObj;
   
  if (action === _opts.participantRosterActionAdded) {
    _participantChangeObj.participationStatus = 'Participating';
    _participantChangeObj.participating = '1';
  }
  else if (action === _opts.participantRosterActionRemoved) {
    _participantChangeObj.participationStatus = 'Not Participating';
	_participantChangeObj.participating = '0';
  }
  else { 
    _participantChangeObj.participationStatus = '';
    _participantChangeObj.participating = '';
  }
  return _participantChangeObj;
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _currentRosterToArray () {
   let _participantObjs = [];
   _currentRoster.forEach(function(_participantObj, _idx) {
      _participantObjs.push(_participantObj);  
   });
   return _participantObjs;
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _currentRosterToJSON () {
  let _participantObjs = _currentRosterToArray();
  return JSON.stringify(_participantObjs);
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _currentRosterToTA () {
  let _participantsJSON = _currentRosterToJSON();
  $(_opts.rosterTextAreaSelector).val(_participantsJSON);
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _rosterChangesToArray () {
   let _participantObjs = [];
   _rosterChanges.forEach(function(_participantChangeObj, _idx) {
     _participantObjs.push(_participantChangeObj);  
   });
   return _participantObjs;
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _rosterChangesToJSON () {
  let _participantObjs = _rosterChangesToArray();
  return JSON.stringify(_participantObjs);
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _rosterChangesToTA () {
  let _participantsJSON = _rosterChangesToJSON();
  $(_opts.rosterChangesTextAreaSelector).val(_participantsJSON);
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _rosterDataToTA () {
  _currentRosterToTA();
  _rosterChangesToTA();
};

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _createParticipantTableRowCommonMkup (participantObj,participantKey) {
  return '<tr ' + _opts.participantTableRowDataAttr  + '="' + participantKey + '"></tr>';
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _createParticipantTableColsCommonMkup (participantObj) {
  return '<td>' + participantObj.name + '</td>' + '<td>' + participantObj.title + '</td>'; 	
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _drawParticipantsRosterChangesTableBodyRow (participantChangeObj, participantKey) {	   		 

  let $_row = $(_createParticipantTableRowCommonMkup(participantChangeObj.participantObj,participantKey));  
 
  $($_row).append('<td>' + participantChangeObj.participationStatus + '</td>');
  let _mkupEffDate = '<td><input ' 
                   + _opts.participantTableColCtrlDataAttr 
				   + '="' + _opts.participantTableColCtrlDataAttrValEffDate + '"'
				   + ' type="date"'
				   + ' min="' + _opts.effectiveDateMin +'"'
				   + ' max="' + _opts.effectiveDateMax +'"'
				   + ' value="' + participantChangeObj.effectiveDate 				 
				   + '"/></td>';
				   
  $($_row).append(_mkupEffDate);
  $($_row).append(_createParticipantTableColsCommonMkup (participantChangeObj.participantObj));
  $(_opts.rosterChangesTableBodySelector).append($_row);
}

/***************************************************************************
 * _sortCurrentRosterByName */
/**
 * 
 ***************************************************************************/

function _sortCurrentRosterByName () {
  
  let _arr = _currentRosterToArray();
  let _sortedMap = new Map();
  
  _arr.sort(function(a, b) {
     
	if (a.name < b.name) { return -1; }
    if (a.name > b.name) { return 1; }
    return 0;
  });
  
   $.each( _arr, function( _idx, _pObj ) {
     let _pk = _createParticipantKey (_pObj);
	 _sortedMap.set(_pk,_pObj);
   });
   _currentRoster = new Map(_sortedMap);
}

/***************************************************************************
 * _sortCurrentRosterByTitle */
/**
 * 
 ***************************************************************************/

function _sortCurrentRosterByTitle () {
  
  let _arr = _currentRosterToArray();
  let _sortedMap = new Map();
  
  _arr.sort(function(a, b) {
	let cmpA = a.title.toLowerCase();
	let cmpB = b.title.toLowerCase();
	if (cmpA < cmpB) { return -1; }
    if (cmpA > cmpB) { return 1; }
    return 0;
  });
  
   $.each( _arr, function( _idx, _pObj ) {
     let _pk = _createParticipantKey (_pObj);
	 _sortedMap.set(_pk,_pObj);
   });
   _currentRoster = new Map(_sortedMap);
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

var _drawParticipantsRosterChangesTableBodyRows = function () {
  $(_opts.rosterChangesTableBodySelector).children().remove();
  _rosterChanges.forEach(function(_participantChangeObj, _participantKey) {
    _drawParticipantsRosterChangesTableBodyRow(_participantChangeObj, _participantKey);
  })
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _updateParticipantRosterChanges (participantObj, participantKey) {
    
  if (_rosterChanges.has(participantKey)) _rosterChanges.delete(participantKey);  
  
  /* Initially did not have record and currently dont have record so no change */
  
  if ((_initialRoster.has(participantKey) === false) && (_currentRoster.has(participantKey) === false)) {
  }
  
  /* Initially did not have but now have */
  
  else if ((_initialRoster.has(participantKey) === false) && (_currentRoster.has(participantKey) === true)) {
	 let _participantChangeObj = _createParticipantChangeObj(participantObj, _opts.participantRosterActionAdded, _opts.effectiveDateDefault);
    _rosterChanges.set(participantKey, _participantChangeObj);
  }
  
  /* Initially had but not do not have */
  
  else if ((_initialRoster.has(participantKey) === true) && (_currentRoster.has(participantKey) === false)) {
	let _participantChangeObj = _createParticipantChangeObj(participantObj, _opts.participantRosterActionRemoved, _opts.effectiveDateDefault);
    _rosterChanges.set(participantKey, _participantChangeObj);  
  }
  
  /* Initially had and currently have so no change */
  
  else if ((_initialRoster.has(participantKey) === true) && (_currentRoster.has(participantKey) === true)){
  }
  /* Technically not possible but here for completion purposes */
  
  else {
  }  
  
  _drawParticipantsRosterChangesTableBodyRows();
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _addParticipantToRoster (participantObj) {
 
  let _participantKey = _createParticipantKey(participantObj);
  participantObj.name = participantObj.name.toUpperCase();
  
  if (_initMode === false) { 
    if (_currentRoster.has(_participantKey)) return null;
  }
  
  _currentRoster.set(_participantKey, participantObj); 
  
  if (_initMode == false)
  {                   
	if (_opts.trackChanges === true) {
	  _updateParticipantRosterChanges (participantObj, _participantKey);
    }
    _rosterDataToTA();
  }
  return _participantKey;
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _removeParticipantFromRoster (participantKey) {
  if (_currentRoster.has(participantKey) === false) return;
  let _participantObj = _currentRoster.get(participantKey);
  _currentRoster.delete(participantKey);  
  if (_opts.trackChanges === true) {
    _updateParticipantRosterChanges (_participantObj, participantKey);
  }
  _rosterDataToTA();
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _drawParticipantsRosterTableBodyRow (participantObj, participantKey) {	   		
  let $_row = $(_createParticipantTableRowCommonMkup(participantObj,participantKey));  
  let $_tdCtrls = $('<td></td>');  
  let $_butRem = $('<button ' + _opts.participantTableColCtrlDataAttr + '="' +_opts.participantTableColCtrlDataAttrValRemove + '" type="button" title="Remove from Roster">&nbsp;</button>');
  $($_butRem).button({text:false,icons:{primary:'ui-icon-minusthick'}});
  $($_tdCtrls).append($_butRem);
  $($_row).append($_tdCtrls);
  $($_row).append(_createParticipantTableColsCommonMkup (participantObj));
  $(_opts.rosterTableBodySelector).append($_row);
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _drawParticipantsRosterTableBodyRows() {
  
  if      (_sortCurrentRosterTableByWhatCol === 1)     _sortCurrentRosterByName();
  else if (_sortCurrentRosterTableByWhatCol === 2)     _sortCurrentRosterByTitle();
  else                                                 _sortCurrentRosterByName();
  
  $(_opts.rosterTableBodySelector).children().remove();
  _currentRoster.forEach(function(_participantObj, _participantKey) {
    _drawParticipantsRosterTableBodyRow(_participantObj, _participantKey);
  })
}

/***************************************************************************
 *  */
/**
 * 
 ***************************************************************************/

function _identifyParticipantTableBodyRowAction (e) {
  let _rowAction = {};
  _rowAction.whatBut = $(e.target).closest('button');
  _rowAction.whatCol = $(_rowAction.whatBut).closest('td');
  _rowAction.whatRow = $(_rowAction.whatCol).closest('tr');
  _rowAction.doWhat  = $(_rowAction.whatBut).attr(_opts.participantTableColCtrlDataAttr);
  _rowAction.participantKey = $(_rowAction.whatRow).attr(_opts.participantTableRowDataAttr);
  return _rowAction;
}

/***************************************************************************
 * _identifyParticipantTableBodyCellDataChangeAction */
/**
 * 
 ***************************************************************************/

function _identifyParticipantTableBodyCellDataChangeAction (e) {
  let _dataChangeAction = {};
  _dataChangeAction.whatInp   = $(e.target).closest('input');
  _dataChangeAction.whatCol   = $(_dataChangeAction.whatInp).closest('td');
  _dataChangeAction.whatRow   = $(_dataChangeAction.whatCol).closest('tr');
  _dataChangeAction.whatData  = $(_dataChangeAction.whatInp).attr(_opts.participantTableColCtrlDataAttr);
  _dataChangeAction.participantKey = $(_dataChangeAction.whatRow).attr(_opts.participantTableRowDataAttr);
  return _dataChangeAction;
}

/***************************************************************************
 * _handleRosterTableBodyRowAction */
/**
 * 
 ***************************************************************************/

function _handleRosterTableBodyRowAction (e) {
  let _rowAction = _identifyParticipantTableBodyRowAction(e);
 
  if (_rowAction.doWhat == _opts.participantTableColCtrlDataAttrValRemove) {
	_removeParticipantFromRoster(_rowAction.participantKey);
	$(_rowAction.whatRow).remove();
  }
}

/***************************************************************************
 * _handleRosterChangesTableBodyRowAction */
/**
 * 
 ***************************************************************************/

function _handleRosterChangesTableBodyRowAction (e) {
  let _dataChangeAction = _identifyParticipantTableBodyCellDataChangeAction(e);
  let _participantChangeObj = _rosterChanges.get(_dataChangeAction.participantKey);
  if (_dataChangeAction.whatData === _opts.participantTableColCtrlDataAttrValEffDate) {
    _participantChangeObj.effectiveDate = $(_dataChangeAction.whatInp).val();
  }
  _rosterChanges.set(_dataChangeAction.participantKey, _participantChangeObj);
  _rosterChangesToTA();
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

var _addParticipant  = function (id, name, title, submitClaimsStr) {
  let _participantObj = _createParticipantObj (id, name, title, submitClaimsStr);
  let _participantKey = _addParticipantToRoster (_participantObj);
  if (!_participantKey) return 
  _drawParticipantsRosterTableBodyRows();
  //_drawParticipantsRosterTableBodyRow(_participantObj, _participantKey);
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
   _opts.participantTableRowDataAttr                = 'data-participant-id';
   _opts.participantTableColCtrlsDataAttr           = 'data-participant-ctrls';
   _opts.participantTableColCtrlDataAttr            = 'data-participant-ctrl';
   _opts.participantTableColCtrlDataAttrValRemove   = 'remove';
   _opts.participantTableColCtrlDataAttrValEffDate  = 'effectivedate';
   _opts.participantRosterActionAdded               = 'added';
   _opts.participantRosterActionRemoved             = 'removed';
   
   _opts.participantTableColButsSubSelector   = 'tr td button[' + _opts.participantTableColCtrlDataAttr + ']';
   _opts.participantTableColInputsSubSelector = 'tr td input[' + _opts.participantTableColCtrlDataAttr + ']';

   
   $(_opts.rosterTableBodySelector).on( 'click'
                                       , _opts.participantTableColButsSubSelector
	                                   , function(e){ _handleRosterTableBodyRowAction(e);});   

   
   $(_opts.rosterChangesTableBodySelector).on( 'change'
                                            , _opts.participantTableColInputsSubSelector
	                                        , function(e){_handleRosterChangesTableBodyRowAction(e);});   


    $(_opts.rosterTableHeadColSelectorName).on("click", function () {
        _sortCurrentRosterTableByWhatCol = 1;
        _drawParticipantsRosterTableBodyRows();
    });
	
    $(_opts.rosterTableHeadColSelectorTitle).on("click", function () {
		_sortCurrentRosterTableByWhatCol = 2;
		_drawParticipantsRosterTableBodyRows();
    });

   _initialRoster  = new Map();
   _currentRoster  = new Map();
   _rosterChanges  = new Map();
   
   let _participantsJSON = $(_opts.rosterTextAreaSelector).val();
   let _participantObjs = JSON.parse(_participantsJSON);
   $.each( _participantObjs, function( _idx, _participantObj ) {    
    _addParticipantToRoster (_participantObj);
   });
   _initialRoster = new Map(_currentRoster);
   _sortCurrentRosterTableByWhatCol = 1;
   _drawParticipantsRosterTableBodyRows();
    
   _initMode = false;
 };

/****************************************************************************/

return {
    init: _init
  , addParticipant : _addParticipant

};

})(jQuery);