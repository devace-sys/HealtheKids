var SpEdCare = (SpEdCare || {});

SpEdCare.recContact = (function ($) {

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

const _rolePrefix = 'contactRoleID-';
var _salt        = 1; // used for table record id's

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
    RecObj[_opts.RecsTableColCtrlDataAttrValName] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValRoleIDInput] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValRoleName] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValRoleIDInput] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValRoleSelection] = [];
    RecObj[_opts.RecsTableColCtrlDataAttrValEmail] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValPhone] = '';
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
  $(_opts.RecsContactTextAreaSelector).val(RecsJSON);
}

/***************************************************************************
 * _RecsDataToTA */
/**
 * 
 ***************************************************************************/

function _RecsDataToTA () {
  _currentRecsToTA();
};

/***************************************************************************
 * _createRecsTableRowCommonMkup */
/**
 * 
 ***************************************************************************/

function _createRecsTableRowCommonMkup (RecObj,RecKey) {
  return '<tr ' + _opts.RecsTableRowDataAttr  + '="' + RecKey + '"></tr>';
}

/***************************************************************************
 * _genSelBoxID */
/**
 *
 ***************************************************************************/

function _genSelBoxID() {
    
    return _rolePrefix + _salt++;
}

/***************************************************************************
 * _createRecTableColsCommonMkup */
/**
 *
 ***************************************************************************/

function _createRecTableColsCommonMkup(RecObj) {

    // set role selection properties
    RecObj[_opts.RecsTableColCtrlDataAttrValRoleIDInput] = _genSelBoxID();
    RecObj[_opts.RecsTableColCtrlDataAttrValRoleNameInput] = RecObj[_opts.RecsTableColCtrlDataAttrValRoleIDInput] + '_selection';

    return '<td><input type="text" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValName + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValName] + '" ></td>'
        + '<td class="roleSelectionCol"><input name="' + RecObj[_opts.RecsTableColCtrlDataAttrValRoleIDInput] + '" id="' + RecObj[_opts.RecsTableColCtrlDataAttrValRoleIDInput] + '" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValRoleID + ' title="Select A Role"></td>'
        + '<td><input type="text" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValEmail + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValEmail] + '" class="largerInputContact" ></td>'
        + '<td><input type="text" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValPhone + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValPhone] + '" ></td>';
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
    _RecsDataToTA();
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

  _RecsDataToTA();

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
  _RecsDataToTA();
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
    
    $($_row).append(_createRecTableColsCommonMkup (RecObj));

    if (_initMode) {
        // if called in init, we want to preload in the correct order so we use append()
        $(_opts.RecsContactTableBodySelector).append($_row);
    }
    else {
        // otherwise, we use prepend to generate a row on the top of the other records
        $(_opts.RecsContactTableBodySelector).prepend($_row);
    }

    // create ORP SelectBox
    _getContactRoles($($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValRoleID + '"]'), RecObj);
  
}

/***************************************************************************
 * _drawRecsTableBodyRows */
/**
 * 
 ***************************************************************************/

function _drawRecsTableBodyRows() {
  _RecsDataToTA();

  $(_opts.RecsContactTableBodySelector).children().remove();

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
 * _removeRecFromDatabase */
/**
 * sends ajax request to delete a record from the database
 ***************************************************************************/

function _removeRecFromDatabase (RecObj) {
    var tkn = _opts.tkn;
    var recid = RecObj[_opts.RecsTableColCtrlDataAttrValID];

    /****** set up ajax url ***********/

    var reqUrl = "client_contacts.asmx/delete?tkn=" + tkn;
    var reqData = "{'editDelReason':'" + '' + "','validaterec':'" + 1 + "','recid':'" + recid + "'}";

    // success callback for ajax
    var fnProcRespSuccess = function (rd) {
        // send another ajax request with the validaterec field now set to 0
        var reqData2 = "{'editDelReason':'" + '' + "','validaterec':'" + 0 + "','recid':'" + recid + "'}";

        var fnProcRespSuccess2 = function (rd) {};

        $.spedmonWebUI.ajax(null
            , reqUrl
            , reqData2
            , 'json'
            , null
            , null
            , null
            , null
            , 0
            , fnProcRespSuccess2
            , null
            , null);
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
    
    var tkn   = _opts.tkn;
    var cltid = _opts.clientID;
    var name = RecObj[_opts.RecsTableColCtrlDataAttrValName];
    var roleid = RecObj[_opts.RecsTableColCtrlDataAttrValRoleID];
    var email = RecObj[_opts.RecsTableColCtrlDataAttrValEmail];
    var phone = RecObj[_opts.RecsTableColCtrlDataAttrValPhone];
    var recid = RecObj[_opts.RecsTableColCtrlDataAttrValID];

    /****** set up ajax url ***********/

    var reqUrl = "client_contacts.asmx/save?tkn=" + tkn;
    var reqData = "{'clientid':'" + cltid + "','name':'" + name + "','roleid':'" + roleid + "','email':'" + email + "','phone':'" + phone + "','editDelReason':'" + '' + "','validaterec':'" + 1 + "','savetype':'" + saveType + "','recid':'" + recid + "'}";

    // success callback for ajax
    var fnProcRespSuccess = function (rd) {
        // send another ajax request with the validaterec field now set to 0
        var reqData2 = "{'clientid':'" + cltid + "','name':'" + name + "','roleid':'" + roleid + "','email':'" + email + "','phone':'" + phone + "','editDelReason':'" + '' + "','validaterec':'" + 0 + "','savetype':'" + saveType + "','recid':'" + recid + "'}";

        var fnProcRespSuccess2 = function (rd) {
            if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {
                RecObj[_opts.RecsTableColCtrlDataAttrValID] = rd.recordID;
            }

            $.spedmonWebUI.dialogMessage('DONE', "Your record was successfully saved.", null, 400, 200, null, null, null);
        };

        $.spedmonWebUI.ajax(null
            , reqUrl
            , reqData2
            , 'json'
            , null
            , null
            , null
            , null
            , 0
            , fnProcRespSuccess2
            , null
            , null);
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
        // make sure all the fields are filled before proceeding
        if (!RecObj[_opts.RecsTableColCtrlDataAttrValName]
            || !RecObj[_opts.RecsTableColCtrlDataAttrValRoleID]
            || !RecObj[_opts.RecsTableColCtrlDataAttrValEmail]
        ) {
            $.spedmonWebUI.dialogMessage('WARNING', "Please make sure the required fields are filled out.", null, 400, 200, null, null, null);
            return;
        }

        // save/edit record in the database
        _saveRecToDatabase(RecObj, RecObj[_opts.RecsTableColCtrlDataAttrValSaveType]);

        // this record now becomes an EXISTING record (if not already an existing one)
        RecObj[_opts.RecsTableColCtrlDataAttrValSaveType] = $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT;
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

var _addRec  = function () {
  let _RecObj = _createRecObj ();
  let _RecKey = _addRecToRecs (_RecObj);
  if (!_RecKey) return;
    _drawRecsTableBodyRows();
}

/***************************************************************************
 * _getContactRoles */
/**
 * Send ajax request to get the ORP's for this client
 ***************************************************************************/

function _getContactRoles($obj, RecObj) {
    var tkn   = _opts.tkn;
    
    /****** set up ajax url ***********/

    var reqUrl = "client_contact_roles.asmx/viewSel?tkn=" + tkn;
    var reqData = [];

    // update the orpPracID and orpPracName fields in our JSON
    function updateRoleDataInRecs(event, ui) {
        var recKey = $(event.target).parents('tr').attr(_opts.RecsTableRowDataAttr);
        
        _updateCurrentRecsForSpecificField(recKey, ui.item.id, _opts.RecsTableColCtrlDataAttrValRoleID);
        _updateCurrentRecsForSpecificField(recKey, ui.item.label, _opts.RecsTableColCtrlDataAttrValRoleName);
    }

    $($obj).spedmonSelectBox({dataParmType:'DOM',selectAll:true,delay:600,showSelectControlLabel:false,selectControlLabel:'Select : ',selectType:1,displayInline:false,singleSelectName:'',singleSelectValue:'',singleSelectClearAfterSelection:false,multiSelect:false,multiSelectShowOK:true,multiSelectListTitle:'Selected Roles',multiSelectNames:'',multiSelectValues:'',multiSelectLoad:false,multiSelectContextLabels:'null',multiSelectDisplayContextLabels:false,multiSelectOnAdd:function(selObj){},multiSelectOnRemove:function(selObj){},onSelect:updateRoleDataInRecs,ajaxopts:{url:reqUrl,data:'', namevalues:reqData}});
    
    // set pre-chosen values if they exist
    if (RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] && RecObj[_opts.RecsTableColCtrlDataAttrValRoleName]) {
        $('#' + RecObj[_opts.RecsTableColCtrlDataAttrValRoleIDInput]).val(RecObj[_opts.RecsTableColCtrlDataAttrValRoleID]);
        $('#' + RecObj[_opts.RecsTableColCtrlDataAttrValRoleNameInput]).val(RecObj[_opts.RecsTableColCtrlDataAttrValRoleName]);
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
   _opts.RecsTableRowDataAttr                     = 'data-Rec-id';
   _opts.RecsTableColCtrlDataAttr                 = 'data-Rec-ctrl';
   _opts.RecsTableColCtrlDataAttrValID            = 'id';
   _opts.RecsTableColCtrlDataAttrValRemove        = 'remove';
   _opts.RecsTableColCtrlDataAttrValSave          = 'save';
   _opts.RecsTableColCtrlDataAttrValName          = 'contactName'; 
   _opts.RecsTableColCtrlDataAttrValRoleID        = 'contactRoleID'; 
   _opts.RecsTableColCtrlDataAttrValRoleIDInput   = 'contactRoleIDInput'; 
   _opts.RecsTableColCtrlDataAttrValRoleName      = 'contactRoleName'; 
   _opts.RecsTableColCtrlDataAttrValRoleNameInput = 'contactRoleNameInput'; 
   _opts.RecsTableColCtrlDataAttrValRoleSelection = 'contactRoleSelection'; 
   _opts.RecsTableColCtrlDataAttrValEmail         = 'email'; 
   _opts.RecsTableColCtrlDataAttrValPhone         = 'phone'; 
   _opts.RecsTableColCtrlDataAttrValSaveType      = 'saveType'; 
   
   _opts.RecsTableColButsSubSelector = 'tr td i';
   _opts.RecsTableColInputsSubSelector = 'tr td input, tr td select, tr td textarea';

   // callback for inputs only
   $(_opts.RecsContactTableBodySelector).on( 'change'
                                       , _opts.RecsTableColInputsSubSelector
	                                   , function(e){ _handleRecsTableBodyRowActionForInput(e); });
   //callback for buttons only
   $(_opts.RecsContactTableBodySelector).on( 'click'
                                       , _opts.RecsTableColButsSubSelector
	                                   , function(e){ _handleRecsTableBodyRowActionForButton(e); });   

   // clear the table (for the case where the user clicks the back button to go to this screen)
   $(_opts.RecsContactTableBodySelector).children().remove();

   _Recs  = new Map();

   let _RecsJSON = $(_opts.RecsContactTextAreaSelector).val();

    if (_RecsJSON && _RecsJSON != '[]') {
        let _RecObjs = JSON.parse(_RecsJSON);

        $.each(_RecObjs, function (_idx, _RecObj) {

            // set defaults if inputs not filled
            _RecObj[_opts.RecsTableColCtrlDataAttrValSaveType] = $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValName])
                _RecObj[_opts.RecsTableColCtrlDataAttrValName] = null;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValRoleID])
                _RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] = null;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValRoleIDInput])
                _RecObj[_opts.RecsTableColCtrlDataAttrValRoleIDInput] = null;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValRoleName])
                _RecObj[_opts.RecsTableColCtrlDataAttrValRoleName] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValRoleNameInput])
                _RecObj[_opts.RecsTableColCtrlDataAttrValRoleNameInput] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValRoleSelection])
                _RecObj[_opts.RecsTableColCtrlDataAttrValRoleSelection] = [];
            else
                _RecObj[_opts.RecsTableColCtrlDataAttrValRoleSelection] =
                    JSON.parse(_RecObj["" + _opts.RecsTableColCtrlDataAttrValRoleSelection]);

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValEmail])
                _RecObj[opts.RecsTableColCtrlDataAttrValEmail] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValPhone])
                _RecObj[_opts.RecsTableColCtrlDataAttrValPhone] = '';

            _addRecToRecs(_RecObj);
        });
    }
    else {
        // generate an empty row
        _addRec();
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
