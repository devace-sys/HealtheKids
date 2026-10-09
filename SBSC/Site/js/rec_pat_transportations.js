var SpEdCare = (SpEdCare || {});

SpEdCare.recPatTransportation = (function ($) {

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

const _amPmPrefix = 'amPmID-';
const _srcPrefix  = 'orig-';
const _destPrefix = 'dest-';
const _routePrefix = 'routeID-';
const _daysColClass = 'transportDaysColumn'; // used to increase the width of the column
const _selectBoxColClass = 'transportSelectBoxColumn'; // used to increase the width of the column
const _tdAmPmClass = 'transportAmPmColumn'; // used for the AM/PM input
const _amPmColClass = 'ui-spedmon-box-radio-am-pm-container'; // used for the AM/PM input
const _distanceColClass = 'distanceColumn';
var _salt         = 1; // used for table record id's

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

function _createRecObj () {
    var RecObj = {};
    
    // set default values
    RecObj[_opts.RecsTableColCtrlDataAttrValID] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValDuppedRecKey] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValAmPm] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValAmPmInputID] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationID] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationIDInput] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationName] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationNameInput] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationAddress] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationID] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationIDInput] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationName] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationNameInput] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationAddress] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValRouteID] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValRouteIDInput] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValRouteName] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValRouteNameInput] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValDistance] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValDaysJSON] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValDaysMon] = true;
    RecObj[_opts.RecsTableColCtrlDataAttrValDaysTue] = true;
    RecObj[_opts.RecsTableColCtrlDataAttrValDaysWed] = true;
    RecObj[_opts.RecsTableColCtrlDataAttrValDaysThur] = true;
    RecObj[_opts.RecsTableColCtrlDataAttrValDaysFri] = true;
    RecObj[_opts.RecsTableColCtrlDataAttrValSaveType] = $.spedmonWebUI.RECORD_SAVE_TYPE_NEW;
  
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
  $(_opts.RecsTransportationTextAreaSelector).val(RecsJSON);
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
 * _genAmPmRadioBoxID */
/**
 *
 ***************************************************************************/

function _genAmPmRadioBoxID() {
    
    return _amPmPrefix + _salt;
}

/***************************************************************************
 * _genLocationSelBoxID */
/**
 *
 ***************************************************************************/

function _genLocationSelBoxID(isSrcLocation) {
    
    return (isSrcLocation) ? _srcPrefix + _salt : _destPrefix + _salt;
}

/***************************************************************************
 * _genRouteSelBoxID */
/**
 *
 ***************************************************************************/

function _genRouteSelBoxID() {
    
    return _routePrefix + _salt;
}

/***************************************************************************
 * _genDaysCheckboxes */
/**
 *
 ***************************************************************************/

function _genDaysCheckboxes() {
    
    var $daysCont = $('<div></div>');

    var $dayslbls     = $('<div class="d-flex justify-content-around"></div>');
    var $dayslblItems = $('<p class="m-0">Mon</p><p class="m-0">Tue</p><p class="m-0">Wed</p><p class="m-0">Thur</p><p class="m-0">Fri</p>');

    var $daysInp   = $('<div class="d-flex justify-content-around"></div>');
    var $monday    = $('<input type="checkbox" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValDaysMon + '>');
    var $tuesday   = $('<input type="checkbox" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValDaysTue + '>');
    var $wednesday = $('<input type="checkbox" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValDaysWed + '>');
    var $thursday  = $('<input type="checkbox" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValDaysThur + '>');
    var $friday    = $('<input type="checkbox" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValDaysFri + '>');

    // append the items

    $($dayslbls).append($dayslblItems);

    $($daysInp).append($monday);
    $($daysInp).append($tuesday);
    $($daysInp).append($wednesday);
    $($daysInp).append($thursday);
    $($daysInp).append($friday);

    $($daysCont).append($dayslbls);
    $($daysCont).append($daysInp);

    return $($daysCont).html();
}

/***************************************************************************
 * _createRecTableColsCommonMkup */
/**
 *
 ***************************************************************************/

function _createRecTableColsCommonMkup(RecObj) {

    // set AM/PM properties
    RecObj[_opts.RecsTableColCtrlDataAttrValAmPmInputID] = _genAmPmRadioBoxID();

    // set source location properties
    RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationIDInput] = _genLocationSelBoxID(true);
    RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationNameInput] = RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationIDInput] + '_selection';

    // set destination location properties
    RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationIDInput] = _genLocationSelBoxID(false);
    RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationNameInput] = RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationIDInput] + '_selection';

    // set route selection properties
    RecObj[_opts.RecsTableColCtrlDataAttrValRouteIDInput] = _genRouteSelBoxID();
    RecObj[_opts.RecsTableColCtrlDataAttrValRouteNameInput] = RecObj[_opts.RecsTableColCtrlDataAttrValRouteIDInput] + '_selection';

    _salt++;

    return '<td class="' + _tdAmPmClass + '"><input class="' + _amPmColClass + '" name="' + RecObj[_opts.RecsTableColCtrlDataAttrValAmPmInputID] + '" id="' + RecObj[_opts.RecsTableColCtrlDataAttrValAmPmInputID] + '" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValAmPm + '></td>'
        + '<td class="' + _selectBoxColClass + '"><input name="' + RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationIDInput] + '" id="' + RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationIDInput] + '" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValSrcLocationID + ' title="Select Pickup Place">'
            + '<div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValSrcLocationAddress + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationAddress] + '</div></td>'
        + '<td class="' + _selectBoxColClass + '"><input name="' + RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationIDInput] + '" id="' + RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationIDInput] + '" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValDestLocationID + ' title="Select Drop Off Place">'
            + '<div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValDestLocationAddress + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationAddress] + '</div></td>'
        + '<td class="' + _selectBoxColClass + '"><input name="' + RecObj[_opts.RecsTableColCtrlDataAttrValRouteIDInput] + '" id="' + RecObj[_opts.RecsTableColCtrlDataAttrValRouteIDInput] + '" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValRouteID + ' title="Select a Route"></td>'
        + '<td class="' + _distanceColClass + '"><div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValDistance + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValDistance] + '">' + RecObj[_opts.RecsTableColCtrlDataAttrValDistance] + '</div></td>'
        + '<td class="' + _daysColClass + '">' + _genDaysCheckboxes() + '</td>';
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
    
    let $_tdSave = $('<td></td>');  
    let $_butSave = $('<i ' + _opts.RecsTableColCtrlDataAttr + '="' +_opts.RecsTableColCtrlDataAttrValSave + '" class="fa fa-save" title="Save Record"></i>');
    $($_tdSave).append($_butSave);
    $($_row).append($_tdSave);

    let $_tdDup = $('<td></td>');
    let $_butDup = $('<i ' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValDup + '" class="fa fa-copy" title="Duplicate Record"></i>');
    $($_tdDup).append($_butDup);
    $($_row).append($_tdDup);
    
    $($_row).append(_createRecTableColsCommonMkup(RecObj));

    if (_initMode) {
        // if called in init, we want to preload in the correct order so we use append()
        // NOTE: in this table specifically, we use prepend() to avoid AM/PM bugs
        $(_opts.RecsTransportationTableBodySelector).prepend($_row);
    }
    else if (RecObj[_opts.RecsTableColCtrlDataAttrValDuppedRecKey]) {
        // if duplicate, we insert it after the record being duplicated
        $_row.insertAfter($('tbody tr[' + _opts.RecsTableRowDataAttr + '='
            + RecObj[_opts.RecsTableColCtrlDataAttrValDuppedRecKey] + ']'));
    }
    else {
        // otherwise, we use prepend to generate a row on the top of the other records
        $(_opts.RecsTransportationTableBodySelector).prepend($_row);
    }

    // pre-select checkbox values

    $($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValDaysMon + '"]').prop('checked', RecObj[_opts.RecsTableColCtrlDataAttrValDaysMon]);
    $($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValDaysTue + '"]').prop('checked', RecObj[_opts.RecsTableColCtrlDataAttrValDaysTue]);
    $($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValDaysWed + '"]').prop('checked', RecObj[_opts.RecsTableColCtrlDataAttrValDaysWed]);
    $($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValDaysThur + '"]').prop('checked', RecObj[_opts.RecsTableColCtrlDataAttrValDaysThur]);
    $($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValDaysFri + '"]').prop('checked', RecObj[_opts.RecsTableColCtrlDataAttrValDaysFri]);

    // create AM/PM control
    _genAmPmControl($($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValAmPm + '"]'), RecObj);
    $($_row).find('.' + _tdAmPmClass + ' .ui-corner-left').attr('title', 'Route: Home to School');
    $($_row).find('.' + _tdAmPmClass + ' .ui-corner-right').attr('title', 'Route: School to Home');
    
    // create Location SelectBox
    _getLocations($($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValSrcLocationID + '"]')
                , RecObj
                , _opts.RecsTableColCtrlDataAttrValSrcLocationID
                , _opts.RecsTableColCtrlDataAttrValSrcLocationName
                , _opts.RecsTableColCtrlDataAttrValSrcLocationAddress
                , $($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValSrcLocationAddress + '"]')
                , $($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValDistance + '"]'));

    _getLocations($($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValDestLocationID + '"]')
                , RecObj
                , _opts.RecsTableColCtrlDataAttrValDestLocationID
                , _opts.RecsTableColCtrlDataAttrValDestLocationName
                , _opts.RecsTableColCtrlDataAttrValDestLocationAddress
                , $($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValDestLocationAddress + '"]')
                , $($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValDistance + '"]'));

    // create Routes SelectBox
    _getRoutesNotAssigned($($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValRouteID + '"]'), RecObj);
}

/***************************************************************************
 * _drawRecsTableBodyRows */
/**
 * 
 ***************************************************************************/

function _drawRecsTableBodyRows() {
  _currentRecsToTA();

  $(_opts.RecsTransportationTableBodySelector).children().remove();

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

  // special cases for spedmonRadioBoxes
  if (_rowAction.whatInp.val() == 'AM' || _rowAction.whatInp.val() == 'PM') {
    _rowAction.doWhat = _opts.RecsTableColCtrlDataAttrValAmPm;
  }

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
 * _removeRecFromDatabase */
/**
 * sends ajax request to delete a record from the database
 ***************************************************************************/

function _removeRecFromDatabase (RecObj) {
    var tkn = _opts.tkn;
    var cltid = _opts.clientID;
    var patid = _opts.patID;
    
    /****** set up ajax url ***********/
    
    var reqUrl = "transport_mgmt_auth_route_members.asmx/delete?tkn=" + tkn;
    var reqData = "{'organizationID':'" + cltid + "','ownerID':'" + cltid + "','groupID':'" + RecObj[_opts.RecsTableColCtrlDataAttrValRouteID] + "','entityID':'" + patid + "'}";
    
    // success callback for ajax
    var fnProcRespSuccess = function (rd) {
    
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
 * _saveRecToDatabase */
/**
 * sends ajax request to delete a record from the database
 ***************************************************************************/

function _saveRecToDatabase (RecObj, saveType) {
    // if patient is not currently authorzed for routes, they should be added to the list
    if (!_opts.isAuthorizedPatient) {
        _addRecToAuthorizedPatients();
    }
    
    var tkn   = _opts.tkn;
    var cltid = _opts.clientID;
    var patid = _opts.patID;

    // recid is routeID for existing records and "" for new records
    var recid = (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) ? "" : RecObj[_opts.RecsTableColCtrlDataAttrValRouteID];

    // create the weekDaysJSON
    var weekDaysJSON = JSON.stringify({
        "mon": RecObj[_opts.RecsTableColCtrlDataAttrValDaysMon]
        , "tue": RecObj[_opts.RecsTableColCtrlDataAttrValDaysTue]
        , "wed": RecObj[_opts.RecsTableColCtrlDataAttrValDaysWed]
        , "thur": RecObj[_opts.RecsTableColCtrlDataAttrValDaysThur]
        , "fri": RecObj[_opts.RecsTableColCtrlDataAttrValDaysFri]
    });
    
    /****** set up ajax url ***********/
    
    var reqUrl = "transport_mgmt_auth_route_members.asmx/save?tkn=" + tkn;
    var reqData = "{'organizationID':'" + cltid + "','ownerID':'" + cltid + "','groupID':'" + RecObj[_opts.RecsTableColCtrlDataAttrValRouteID] + "','entityID':'" + patid + "','origPlaceID':'" + RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationID] + "','destPlaceID':'" + RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationID] + "','weekDaysJSON':'" + weekDaysJSON + "','selectAmPm':'" + RecObj[_opts.RecsTableColCtrlDataAttrValAmPm] + "','savetype':'" + saveType + "','recid':'" + recid + "'}";
    
    // success callback for ajax
    var fnProcRespSuccess = function (rd) {
        if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {
            RecObj[_opts.RecsTableColCtrlDataAttrValID] = rd.recordID;
        }

        // this record now becomes an EXISTING record (if not already an existing one)
        RecObj[_opts.RecsTableColCtrlDataAttrValSaveType] = $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT;
        
        $.spedmonWebUI.dialogMessage('DONE', "Your record was successfully saved.", null, 400, 200, null, null, null);
    };

    // error callback for ajax
    var fnProcRespError = function () {
        $.spedmonWebUI.dialogMessage('ERROR', "Something went wrong when saving record!", null, 400, 200, null, null, null);
        return;
    };
    
    $.spedmonWebUI.ajax(null
        , reqUrl
        , reqData
        , 'json'
        , null
        , null
        , fnProcRespError
        , null
        , 0
        , fnProcRespSuccess
        , null
        , null);
}

/***************************************************************************
 * _setLocationBasedOnAmPm */
/**
 *
 ***************************************************************************/

function _setLocationBasedOnAmPm(RecKey, inputVal) {
    var RecObj = _Recs.get(RecKey);

    if (inputVal == "AM") {
        RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationID] = _opts.RecsTableColCtrlDataAttrValHomeLocationID;
        RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationName] = _opts.RecsTableColCtrlDataAttrValHomeLocationName;
        RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationAddress] = _opts.RecsTableColCtrlDataAttrValHomeLocationAddress;

        RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationID] = _opts.RecsTableColCtrlDataAttrValSiteLocationID;
        RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationName] = _opts.RecsTableColCtrlDataAttrValSiteLocationName;
        RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationAddress] = _opts.RecsTableColCtrlDataAttrValSiteLocationAddress;
    }
    else if (inputVal == "PM") {
        RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationID] = _opts.RecsTableColCtrlDataAttrValSiteLocationID;
        RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationName] = _opts.RecsTableColCtrlDataAttrValSiteLocationName;
        RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationAddress] = _opts.RecsTableColCtrlDataAttrValSiteLocationAddress;

        RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationID] = _opts.RecsTableColCtrlDataAttrValHomeLocationID;
        RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationName] = _opts.RecsTableColCtrlDataAttrValHomeLocationName;
        RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationAddress] = _opts.RecsTableColCtrlDataAttrValHomeLocationAddress;
    }
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
        if (RecObj[_opts.RecsTableColCtrlDataAttrValSaveType] == $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT) {
            // if this is an existing record, there should be a confirmation
            var onYes = function () {
                // delete record from the table
                _removeRecFromTable(_rowAction);

                // delete record from the database
                _removeRecFromDatabase(RecObj);
            };

            $.spedmonWebUI.dialogConfirm("Please Confirm", "Are you sure you want to remove this record? Once this record is deleted it cannot be undeleted!", onYes, function () { })
        }
        else {
            // if this is a new record, there is no need for confirmation and removing database records
            _removeRecFromTable(_rowAction);
        }
    }

    // save record if needed
    else if (_rowAction.doWhat == _opts.RecsTableColCtrlDataAttrValSave) {

        // save/edit record in the database
        _saveRecToDatabase(RecObj, RecObj[_opts.RecsTableColCtrlDataAttrValSaveType]);
    }

    // duplicate record if needed
    else if (_rowAction.doWhat == _opts.RecsTableColCtrlDataAttrValDup) {
        _dupRecRow(_rowAction.RecKey, _rowAction.whatRow);
    }
}

/***************************************************************************
 * _handleRecsTableBodyRowActionForInput */
/**
 * 
 ***************************************************************************/

function _handleRecsTableBodyRowActionForInput (e) {
    let _rowAction = _identifyRecsTableBodyRowAction(e, e.currentTarget.localName);
    var RecObj = _Recs.get(_rowAction.RecKey);

    // decide what value we want to set for this field
    let inputVal = _rowAction.whatInp.val();
    if (_rowAction.whatInp.attr('type') == 'checkbox') inputVal = _rowAction.whatInp.prop('checked');
    
    // enter input change into the hidden textarea json
    _updateCurrentRecsForSpecificField(_rowAction.RecKey, inputVal, _rowAction.doWhat);
    
    // if AM/PM is clicked, change location inputs
    if (_rowAction.doWhat == _opts.RecsTableColCtrlDataAttrValAmPm) {
        _setLocationBasedOnAmPm(_rowAction.RecKey, inputVal);
       
        _computeDistance(RecObj, $(_rowAction.whatRow).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValDistance + '"]'), _drawRecsTableBodyRows);
    }
}

/***************************************************************************
 * _dupRecRow */
/**
 * duplicates a _Recs object 
 ***************************************************************************/

var _dupRecRow  = function (RecKey) {
  let _newRecObj = JSON.parse(JSON.stringify(_Recs.get(RecKey))); //https://www.samanthaming.com/tidbits/70-3-ways-to-clone-objects/
  // set append type
  _newRecObj[_opts.RecsTableColCtrlDataAttrValDuppedRecKey] = RecKey;

  // empty the Route Name selection
  _newRecObj[_opts.RecsTableColCtrlDataAttrValRouteID] = null;
  _newRecObj[_opts.RecsTableColCtrlDataAttrValRouteName] = '';

  _newRecObj[_opts.RecsTableColCtrlDataAttrValSaveType] = $.spedmonWebUI.RECORD_SAVE_TYPE_NEW;

  let _newRecKey = _addRecToRecs(_newRecObj);

  if (!_newRecKey) return;
  _drawRecsTableBodyRows();
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

var _addRec  = function () {
  let _RecObj = _createRecObj ();
  let _RecKey = _addRecToRecs (_RecObj);
  if (!_RecKey) return;
    _drawRecsTableBodyRows();
}

/***************************************************************************
 * _genAmPmControl */
/**
 * Creates the AM/PM control
 ***************************************************************************/

function _genAmPmControl($obj, RecObj) {

    $($obj).spedmonRadioBox({
        valueSelections: [
            {
                label: 'AM', value: 'AM'
            }, {
                label: 'PM', value: 'PM'
            }]
        , renderLabel: false
    });
    
    // set pre-chosen values if they exist
    if (RecObj[_opts.RecsTableColCtrlDataAttrValAmPm]) {
        var optNum = (RecObj[_opts.RecsTableColCtrlDataAttrValAmPm] == 'AM') ? 0 : 1;
        var amPmLabelID = RecObj[_opts.RecsTableColCtrlDataAttrValAmPmInputID] + '_radiobox_opt_' + optNum;

        $('label[for="' + amPmLabelID + '"]').addClass('ui-state-active');
    }
}

/***************************************************************************
 * _tripCalcLoadRefreshOrNew */
/**
 *
 ***************************************************************************/

function _tripCalcLoadRefreshOrNew(tkn, cid, pid, opid, dpid, fnReturnData) {
  if (!opid) return;
  if (!dpid) return;
  
  var reqUrl     = $.spedmonWebUI.createPrivateURL(tkn,"transport_mgmt_trip_calculations.asmx/loadRefreshOrNew");
  
  var reqData = '{'
              + ' "organizationid":"'  + cid  + '"'
              + ',"entityid":"'        + pid  + '"'
              + ',"origplaceid":"'     + opid + '"'
              + ',"destplaceid":"'     + dpid + '"'
              + '}';  

      
  var fnProcRespSuccess = function (rd) {
    fnReturnData(rd);	
  };
 
  var fnComplete = function() {};
   
  $.spedmonWebUI.ajax(null, reqUrl, reqData, 'json_synch', null, null, null, null, 0, fnProcRespSuccess, fnComplete, null);
    
  return;
  
}

/***************************************************************************
 * _computeDistance */
/**
 *
 ***************************************************************************/

function _computeDistance(RecObj, $distanceDiv, fnCallBack) {
    $($distanceDiv).html('');

    var fnReturnData = function (returnData) {
        var distanceVal = (returnData.distanceInMiles) ? returnData.distanceInMiles : '';

        $($distanceDiv).html(distanceVal);
        RecObj[_opts.RecsTableColCtrlDataAttrValDistance] = distanceVal;

        if (fnCallBack) fnCallBack();
    };


    var cid = _opts.clientID
    var pid = _opts.patID
    var opid = RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationID];
    var dpid = RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationID];

    _tripCalcLoadRefreshOrNew(_opts.tkn, cid, pid, opid, dpid, fnReturnData);
}

/***************************************************************************
 * _getLocations */
/**
 * Send ajax request to get the Locations
 ***************************************************************************/

function _getLocations($obj, RecObj, locationID, locationName, locationAddress, $addressDiv, $distanceDiv) {
    var tkn   = _opts.tkn;
    
    /****** set up ajax url ***********/

    var reqUrl = "transport_mgmt_places.asmx/viewSel?tkn=" + tkn;
    var reqData = [{ name: "clientid", value: _opts.clientID }
                , { name: "patid", value: _opts.patID }
                , { name: "placeid", value: "" }
    ];

    // update the orpPracID and orpPracName fields in our JSON
    function updateLocationDataInRecs(event, ui) {
        var recKey = $(event.target).parents('tr').attr(_opts.RecsTableRowDataAttr);
        
        _updateCurrentRecsForSpecificField(recKey, ui.item.recData2, locationID);
        _updateCurrentRecsForSpecificField(recKey, ui.item.label, locationName);
        _updateCurrentRecsForSpecificField(recKey, ui.item.recData1, locationAddress);

        // update the address display
        $($addressDiv).html(ui.item.recData1);

        // calculate the distance
        _computeDistance(RecObj, $distanceDiv, null);
    }

    $($obj).spedmonSelectBox({dataParmType:'DOM',selectAll:true,delay:600,showSelectControlLabel:false,selectControlLabel:'Select : ',selectType:1,displayInline:false,singleSelectName:'',singleSelectValue:'',singleSelectClearAfterSelection:false,multiSelect:false,multiSelectShowOK:true,multiSelectListTitle:'Selected Locations',multiSelectNames:'',multiSelectValues:'',multiSelectLoad:false,multiSelectContextLabels:'null',multiSelectDisplayContextLabels:false,multiSelectOnAdd:function(selObj){},multiSelectOnRemove:function(selObj){},onSelect:updateLocationDataInRecs,ajaxopts:{url:reqUrl,data:'', namevalues:reqData}});
    
    // set pre-chosen values if they exist
    if (RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationID] && RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationName]) {
        $('#' + RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationIDInput]).val(RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationID]);
        $('#' + RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationNameInput]).val(RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationName]);
    }

    if (RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationID] && RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationName]) {
        $('#' + RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationIDInput]).val(RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationID]);
        $('#' + RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationNameInput]).val(RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationName]);
    }
}

/***************************************************************************
 * _getRoutesNotAssigned */
/**
 * Creates the Routes control
 ***************************************************************************/

function _getRoutesNotAssigned($obj, RecObj) {

    var tkn   = _opts.tkn;
    
    /****** set up ajax url ***********/

    var reqUrl = "transport_mgmt_auth_routes.asmx/viewSelPatNotAssigned?tkn=" + tkn;
    var reqData = [{ name: "organizationID", value: _opts.clientID }
                , { name: "ownerID", value: _opts.clientID }
                , { name: "patID", value: _opts.patID }
    ];

    // update the orpPracID and orpPracName fields in our JSON
    function updateRouteDataInRecs(event, ui) {
        var recKey = $(event.target).parents('tr').attr(_opts.RecsTableRowDataAttr);
        
        _updateCurrentRecsForSpecificField(recKey, ui.item.id, _opts.RecsTableColCtrlDataAttrValRouteID);
        _updateCurrentRecsForSpecificField(recKey, ui.item.label, _opts.RecsTableColCtrlDataAttrValRouteName);
    }

    $($obj).spedmonSelectBox({dataParmType:'DOM',selectAll:true,delay:600,showSelectControlLabel:false,selectControlLabel:'Select : ',selectType:1,displayInline:false,singleSelectName:'',singleSelectValue:'',singleSelectClearAfterSelection:false,multiSelect:false,multiSelectShowOK:true,multiSelectListTitle:'Selected Locations',multiSelectNames:'',multiSelectValues:'',multiSelectLoad:false,multiSelectContextLabels:'null',multiSelectDisplayContextLabels:false,multiSelectOnAdd:function(selObj){},multiSelectOnRemove:function(selObj){},onSelect:updateRouteDataInRecs,ajaxopts:{url:reqUrl,data:'', namevalues:reqData}});
    
    // set pre-chosen values if they exist
    if (RecObj[_opts.RecsTableColCtrlDataAttrValRouteID] && RecObj[_opts.RecsTableColCtrlDataAttrValRouteName]) {
        $('#' + RecObj[_opts.RecsTableColCtrlDataAttrValRouteIDInput]).val(RecObj[_opts.RecsTableColCtrlDataAttrValRouteID]);
        $('#' + RecObj[_opts.RecsTableColCtrlDataAttrValRouteNameInput]).val(RecObj[_opts.RecsTableColCtrlDataAttrValRouteName]);
    }
}

/***************************************************************************
 * _addRecToAuthorizedPatients */
/**
 *
 ***************************************************************************/

function _addRecToAuthorizedPatients() {
    var tkn = _opts.tkn;
    var cltid = _opts.clientID;
    var patid = _opts.patID;
    var saveType = $.spedmonWebUI.RECORD_SAVE_TYPE_NEW;

    /****** set up ajax url ***********/

    var reqUrl = "transport_mgmt_auth_patients.asmx/save?tkn=" + tkn;
    var reqData = "{'organizationID':'" + cltid + "','ownerID':'" + cltid + "','groupID':'" + cltid + "','entityID':'" + patid + "','sitePlaceID':'" + '' + "','homePlaceID':'" + '' + "','saveType':'" + saveType + "','recID':'" + '' + "'}";

    // success callback for ajax
    var fnProcRespSuccess = function (rd) {
        // now that the patient is in the list, we can proceed
        _getHomeAndSiteLocationInfo();
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
 * _getHomeAndSiteLocationInfo */
/**
 *
 ***************************************************************************/

function _getHomeAndSiteLocationInfo() {

    var tkn = _opts.tkn;
    var cltid = _opts.clientID;
    var patid = _opts.patID;


    /****** set up ajax url ***********/
 
    var reqUrl = "transport_mgmt_auth_patients.asmx/viewSel?tkn=" + tkn;
    var reqData = JSON.stringify({
        "organizationID": cltid
        , "ownerID": cltid
        , "groupid": cltid
        , "term": ""
    });


    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
        .then(responseData => {


            // find patient from array of returned patients (using patid)

            let authPats = responseData.rawData.SelRecs;
            let patInfo  = (authPats) ? authPats.find(patient => patient.id == patid) : '';

            if (patInfo) {
                _opts.isAuthorizedPatient = true;
                _opts.RecsTableColCtrlDataAttrValHomeLocationID = (patInfo.recData6) ? patInfo.recData6 : '';
                _opts.RecsTableColCtrlDataAttrValHomeLocationName = (patInfo.recData4) ? patInfo.recData4 : '';
                _opts.RecsTableColCtrlDataAttrValHomeLocationAddress = (patInfo.recData5) ? patInfo.recData5 : '';
                _opts.RecsTableColCtrlDataAttrValSiteLocationID = (patInfo.recData3) ? patInfo.recData3 : '';
                _opts.RecsTableColCtrlDataAttrValSiteLocationName = (patInfo.recData1) ? patInfo.recData1 : '';
                _opts.RecsTableColCtrlDataAttrValSiteLocationAddress = (patInfo.recData2) ? patInfo.recData2 : '';
            }
        })
        .catch(responseData => {


        });

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
   _opts.RecsTableRowDataAttr                     = 'data-Rec-id';
   _opts.RecsTableColCtrlDataAttr                 = 'data-Rec-ctrl';
   _opts.RecsTableColCtrlDataAttrValID            = 'id';
   _opts.RecsTableColCtrlDataAttrValRemove        = 'remove';
   _opts.RecsTableColCtrlDataAttrValSave          = 'save';
   _opts.RecsTableColCtrlDataAttrValDup           = 'duplicate';
   _opts.RecsTableColCtrlDataAttrValDuppedRecKey  = 'duppedRecKey';
   _opts.RecsTableColCtrlDataAttrValSaveType      = 'saveType';

   _opts.RecsTableColCtrlDataAttrValAmPm                  = 'selectAmPm';  
   _opts.RecsTableColCtrlDataAttrValAmPmInputID           = 'selectAmPmInputID';  
   _opts.RecsTableColCtrlDataAttrValSrcLocationID         = 'origPlaceID';
   _opts.RecsTableColCtrlDataAttrValSrcLocationIDInput    = 'pickUpLocationIDInput'; 
   _opts.RecsTableColCtrlDataAttrValSrcLocationName       = 'origName'; 
   _opts.RecsTableColCtrlDataAttrValSrcLocationNameInput  = 'pickUpLocationNameInput';
   _opts.RecsTableColCtrlDataAttrValSrcLocationAddress    = 'origAddress';
   _opts.RecsTableColCtrlDataAttrValDestLocationID        = 'destPlaceID';
   _opts.RecsTableColCtrlDataAttrValDestLocationIDInput   = 'dropOffLocationIDInput'; 
   _opts.RecsTableColCtrlDataAttrValDestLocationName      = 'destName'; 
   _opts.RecsTableColCtrlDataAttrValDestLocationNameInput = 'dropOffLocationNameInput';
   _opts.RecsTableColCtrlDataAttrValDestLocationAddress   = 'destAddress';
   _opts.RecsTableColCtrlDataAttrValRouteID               = 'routeID';  
   _opts.RecsTableColCtrlDataAttrValRouteIDInput          = 'routeIDInput';  
   _opts.RecsTableColCtrlDataAttrValRouteName             = 'routeName';  
   _opts.RecsTableColCtrlDataAttrValRouteNameInput        = 'routeNameInput';  
   _opts.RecsTableColCtrlDataAttrValDistance              = 'distanceMilesStr';  
   _opts.RecsTableColCtrlDataAttrValDaysJSON              = 'weekDaysJSON';  
   _opts.RecsTableColCtrlDataAttrValDaysMon               = 'scheduledForMon';  
   _opts.RecsTableColCtrlDataAttrValDaysTue               = 'scheduledForTue';  
   _opts.RecsTableColCtrlDataAttrValDaysWed               = 'scheduledForWed';  
   _opts.RecsTableColCtrlDataAttrValDaysThur              = 'scheduledForThur';  
   _opts.RecsTableColCtrlDataAttrValDaysFri               = 'scheduledForFri';
   _opts.isAuthorizedPatient                              = false;
   
   _opts.RecsTableColButsSubSelector = 'tr td i';
   _opts.RecsTableColInputsSubSelector = 'tr td input, tr td select, tr td textarea';

   // callback for inputs only
   $(_opts.RecsTransportationTableBodySelector).on( 'change'
                                       , _opts.RecsTableColInputsSubSelector
	                                   , function(e){ _handleRecsTableBodyRowActionForInput(e); });
   //callback for buttons only
   $(_opts.RecsTransportationTableBodySelector).on( 'click'
                                       , _opts.RecsTableColButsSubSelector
	                                   , function(e){ _handleRecsTableBodyRowActionForButton(e); });   

   // clear the table (for the case where the user clicks the back button to go to this screen)
   $(_opts.RecsTransportationTableBodySelector).children().remove();

   _Recs  = new Map();

   let _RecsJSON = $(_opts.RecsTransportationTextAreaSelector).val();

    if (_RecsJSON && _RecsJSON != '[]') {
        let _RecObjs = JSON.parse(_RecsJSON);
        
        $.each(_RecObjs, function (_idx, _RecObj) {
        
            // set defaults if inputs not filled
            _RecObj[_opts.RecsTableColCtrlDataAttrValSaveType] = $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValAmPm])
                _RecObj[_opts.RecsTableColCtrlDataAttrValAmPm] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationID]) {
                _RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationID] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationName] = '';
                _RecObj[_opts.RecsTableColCtrlDataAttrValSrcLocationAddress] = '';
            }

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationID]) {
                _RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationID] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationName] = '';
                _RecObj[_opts.RecsTableColCtrlDataAttrValDestLocationAddress] = '';
            }

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValRouteID]) {
                _RecObj[_opts.RecsTableColCtrlDataAttrValRouteID] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValRouteName] = '';
            }

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValDistance])
                _RecObj[_opts.RecsTableColCtrlDataAttrValDistance] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValDaysJSON]) {
                _RecObj[_opts.RecsTableColCtrlDataAttrValDaysJSON] = '';
            }
            else {
                var weekDaysObj = JSON.parse(_RecObj[_opts.RecsTableColCtrlDataAttrValDaysJSON]);
                _RecObj[_opts.RecsTableColCtrlDataAttrValDaysMon] = weekDaysObj.mon;
                _RecObj[_opts.RecsTableColCtrlDataAttrValDaysTue] = weekDaysObj.tue;
                _RecObj[_opts.RecsTableColCtrlDataAttrValDaysWed] = weekDaysObj.wed;
                _RecObj[_opts.RecsTableColCtrlDataAttrValDaysThur] = weekDaysObj.thur;
                _RecObj[_opts.RecsTableColCtrlDataAttrValDaysFri] = weekDaysObj.fri;
            }
        
            _addRecToRecs(_RecObj);
        });
    }
    else {
        // generate an empty row
        _addRec();
    }

    _drawRecsTableBodyRows();

    // get the patient's home and site addresses
    _getHomeAndSiteLocationInfo();

    _initMode = false;
 };

/****************************************************************************/

return {
    init: _init
  , addRec : _addRec
};

})(jQuery);
