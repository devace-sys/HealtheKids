var SpEdCare = (SpEdCare || {});

SpEdCare.recSpecAuth = (function ($) {

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

const _orpPrefix = 'orpPracID-';
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
  RecObj[_opts.RecsTableColCtrlDataAttrValGroups] = null;
  RecObj[_opts.RecsTableColCtrlDataAttrValEffectiveDate] = '';
  RecObj[_opts.RecsTableColCtrlDataAttrValExpirationDate] = '';
  RecObj[_opts.RecsTableColCtrlDataAttrValORPPracID] = '';
  RecObj[_opts.RecsTableColCtrlDataAttrValORPPracIDInput] = '';
  RecObj[_opts.RecsTableColCtrlDataAttrValORPPracName] = '';
  RecObj[_opts.RecsTableColCtrlDataAttrValORPPracNameInput] = '';
  RecObj[_opts.RecsTableColCtrlDataAttrValORPSelection] = [];
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
   let tempID;
   let tempORPSelection;
   let tempSaveType;

   _Recs.forEach(function(RecObj, _idx) {
       // exclude fields we don't want to send to the database
       tempID = RecObj[_opts.RecsTableColCtrlDataAttrValID];
       delete RecObj[_opts.RecsTableColCtrlDataAttrValID];

       tempORPSelection = RecObj[_opts.RecsTableColCtrlDataAttrValORPSelection];
       delete RecObj[_opts.RecsTableColCtrlDataAttrValORPSelection];

       tempSaveType = RecObj[_opts.RecsTableColCtrlDataAttrValSaveType];
       delete RecObj[_opts.RecsTableColCtrlDataAttrValSaveType];
      
       RecObjs.push(JSON.parse(JSON.stringify(RecObj)));

       // add back excluded fields
       RecObj[_opts.RecsTableColCtrlDataAttrValORPSelection] = tempORPSelection;
       RecObj[_opts.RecsTableColCtrlDataAttrValID]           = tempID;
       RecObj[_opts.RecsTableColCtrlDataAttrValSaveType]    = tempSaveType;

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
  $(_opts.RecsSpecAuthTextAreaSelector).val(RecsJSON);
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
    
    return _orpPrefix + _salt++;
}

/***************************************************************************
 * _createRecTableColsCommonMkup */
/**
 *
 ***************************************************************************/

function _createRecTableColsCommonMkup(RecObj) {

    // set prac selection properties
    RecObj[_opts.RecsTableColCtrlDataAttrValORPPracIDInput] = _genSelBoxID();
    RecObj[_opts.RecsTableColCtrlDataAttrValORPPracNameInput] = RecObj[_opts.RecsTableColCtrlDataAttrValORPPracIDInput] + '_selection';
    
    return '<td><select ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValGroups + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValGroups] + '" >'
            + '<option disabled value' + ((RecObj[_opts.RecsTableColCtrlDataAttrValGroups] == null) ? ' selected' : '') + ' > -- select an option --</option>'
            + '<option value="9"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValGroups] == 9) ? ' selected' : '') + ' >Speech Services</option>'
            + '<option value="4"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValGroups] == 4) ? ' selected' : '') + ' >Occupational Therapy Services</option>'
            + '<option value="6"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValGroups] == 6) ? ' selected' : '') + ' >Physical Therapy Services</option>'
        + '</select></td>'
        + '<td class="pracSelectionCol"><input name="' + RecObj[_opts.RecsTableColCtrlDataAttrValORPPracIDInput] + '" id="' + RecObj[_opts.RecsTableColCtrlDataAttrValORPPracIDInput] + '" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValORPPracID + ' title="Select A Practitioner"></td>'
        + '<td><input type="date" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValEffectiveDate + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValEffectiveDate] + '" ></td>'
        + '<td><input type="date" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValExpirationDate + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValExpirationDate] + '" ></td>';
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

    let $_tdPBS = $('<td></td>');
    let $_butPBS = $('<i ' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValManagePBS + '" class="fa fa-paperclip" title="Manage Special Authorization Document Files"></i>');
    $($_tdPBS).append($_butPBS);
    $($_row).append($_tdPBS);
    
    $($_row).append(_createRecTableColsCommonMkup (RecObj));

    if (_initMode) {
        // if called in init, we want to preload in the correct order so we use append()
        $(_opts.RecsSpecAuthTableBodySelector).append($_row);
    }
    else {
        // otherwise, we use prepend to generate a row on the top of the other records
        $(_opts.RecsSpecAuthTableBodySelector).prepend($_row);
    }
    
    // create ORP SelectBox
    _getPractitioners($($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValORPPracID + '"]'), RecObj);
  
}

/***************************************************************************
 * _drawRecsTableBodyRows */
/**
 * 
 ***************************************************************************/

function _drawRecsTableBodyRows() {
  _RecsDataToTA();

  $(_opts.RecsSpecAuthTableBodySelector).children().remove();

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

    var reqUrl = "client_pbs_documentation.asmx/delete?tkn=" + tkn;
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
    var grpid = RecObj[_opts.RecsTableColCtrlDataAttrValGroups];
    var pracid = RecObj[_opts.RecsTableColCtrlDataAttrValORPPracID];
    var startdate = RecObj[_opts.RecsTableColCtrlDataAttrValEffectiveDate];
    var enddate = RecObj[_opts.RecsTableColCtrlDataAttrValExpirationDate];
    var recid = RecObj[_opts.RecsTableColCtrlDataAttrValID];

    /****** set up ajax url ***********/

    var reqUrl = "client_pbs_documentation.asmx/save?tkn=" + tkn;
    var reqData = "{'clientid':'" + cltid + "','groupServiceClassNameID':'" + grpid + "','orpPracID':'" + pracid + "','startDate':'" + startdate + "','endDate':'" + enddate + "','notes':'" + '' + "','editDelReason':'" + '' + "','validaterec':'" + 1 + "','savetype':'" + saveType + "','recid':'" + recid + "'}";

    // success callback for ajax
    var fnProcRespSuccess = function (rd) {
        // send another ajax request with the validaterec field now set to 0
        var reqData2 = "{'clientid':'" + cltid + "','groupServiceClassNameID':'" + grpid + "','orpPracID':'" + pracid + "','startDate':'" + startdate + "','endDate':'" + enddate + "','notes':'" + '' + "','editDelReason':'" + '' + "','validaterec':'" + 0 + "','savetype':'" + saveType + "','recid':'" + recid + "'}";

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
        if (!RecObj[_opts.RecsTableColCtrlDataAttrValGroups]
            || !RecObj[_opts.RecsTableColCtrlDataAttrValEffectiveDate]
            || !RecObj[_opts.RecsTableColCtrlDataAttrValExpirationDate]
            || !RecObj[_opts.RecsTableColCtrlDataAttrValORPPracID]
        ) {
            $.spedmonWebUI.dialogMessage('WARNING', "Please make sure all the fields are filled out.", null, 400, 200, null, null, null);
            return;
        }

        // save/edit record in the database
        _saveRecToDatabase(RecObj, RecObj[_opts.RecsTableColCtrlDataAttrValSaveType]);

        // this record now becomes an EXISTING record (if not already an existing one)
        RecObj[_opts.RecsTableColCtrlDataAttrValSaveType] = $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT;
    }

    // Manage PBS documents
    else if (_rowAction.doWhat == _opts.RecsTableColCtrlDataAttrValManagePBS) {
        managePBSFiles();
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
 * _getPractitioners */
/**
 * Send ajax request to get the ORP's for this client
 ***************************************************************************/

function _getPractitioners($obj, RecObj) {
    var tkn   = _opts.tkn;
    var cltid = _opts.clientID;
    
    /****** set up ajax url ***********/

    var reqUrl = "practitioners.asmx/viewSel2?tkn=" + tkn;
    var reqData = [{
                       name: 'pracdatasource', value: ''
                   }, {
                       name: 'clientid', value: cltid
                   }, {
                       name: 'patid', value: ''
                   }, {
                       name: 'dos', value: ''                  
                   }, {
                       name: 'groupserviceclassnameid', value: ''
                   }];

    // update the orpPracID and orpPracName fields in our JSON
    function updatePracDataInRecs(event, ui) {
        var recKey = $(event.target).parents('tr').attr(_opts.RecsTableRowDataAttr);

        _updateCurrentRecsForSpecificField(recKey, ui.item.id, _opts.RecsTableColCtrlDataAttrValORPPracID);
        _updateCurrentRecsForSpecificField(recKey, ui.item.label, _opts.RecsTableColCtrlDataAttrValORPPracName);
    }

    $($obj).spedmonSelectBox({dataParmType:'DOM',selectAll:true,delay:600,showSelectControlLabel:false,selectControlLabel:'Select : ',selectType:1,displayInline:false,singleSelectName:'',singleSelectValue:'',singleSelectClearAfterSelection:false,multiSelect:false,multiSelectShowOK:true,multiSelectListTitle:'Selected Practioners',multiSelectNames:'',multiSelectValues:'',multiSelectLoad:false,multiSelectContextLabels:'null',multiSelectDisplayContextLabels:false,multiSelectOnAdd:function(selObj){},multiSelectOnRemove:function(selObj){},onSelect:updatePracDataInRecs,ajaxopts:{url:reqUrl,data:'', namevalues:reqData}});
    
    // set pre-chosen values if they exist
    if (RecObj[_opts.RecsTableColCtrlDataAttrValORPPracID] && RecObj[_opts.RecsTableColCtrlDataAttrValORPPracName]) {
        $('#' + RecObj[_opts.RecsTableColCtrlDataAttrValORPPracIDInput]).val(RecObj[_opts.RecsTableColCtrlDataAttrValORPPracID]);
        $('#' + RecObj[_opts.RecsTableColCtrlDataAttrValORPPracNameInput]).val(RecObj[_opts.RecsTableColCtrlDataAttrValORPPracName]);
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
   _opts.RecsTableRowDataAttr                        = 'data-Rec-id';
   _opts.RecsTableColCtrlDataAttr                    = 'data-Rec-ctrl';
   _opts.RecsTableColCtrlDataAttrValID               = 'id';
   _opts.RecsTableColCtrlDataAttrValRemove           = 'remove';
   _opts.RecsTableColCtrlDataAttrValSave             = 'save';
   _opts.RecsTableColCtrlDataAttrValManagePBS        = 'managePBSFiles'; 
   _opts.RecsTableColCtrlDataAttrValGroups           = 'groupServiceClassNameID'; 
   _opts.RecsTableColCtrlDataAttrValEffectiveDate    = 'startDateStr'; 
   _opts.RecsTableColCtrlDataAttrValExpirationDate   = 'endDateStr'; 
   _opts.RecsTableColCtrlDataAttrValORPPracID        = 'orpPracID'; 
   _opts.RecsTableColCtrlDataAttrValORPPracIDInput   = 'orpPracIDInput'; 
   _opts.RecsTableColCtrlDataAttrValORPPracName      = 'orpPracName'; 
   _opts.RecsTableColCtrlDataAttrValORPPracNameInput = 'orpPracNameInput'; 
   _opts.RecsTableColCtrlDataAttrValORPSelection     = 'orpPracSelection'; 
   _opts.RecsTableColCtrlDataAttrValSaveType         = 'saveType'; 
   
   _opts.RecsTableColButsSubSelector = 'tr td i';
   _opts.RecsTableColInputsSubSelector = 'tr td input, tr td select, tr td textarea';

   // callback for inputs only
   $(_opts.RecsSpecAuthTableBodySelector).on( 'change'
                                       , _opts.RecsTableColInputsSubSelector
	                                   , function(e){ _handleRecsTableBodyRowActionForInput(e); });
   //callback for buttons only
   $(_opts.RecsSpecAuthTableBodySelector).on( 'click'
                                       , _opts.RecsTableColButsSubSelector
	                                   , function(e){ _handleRecsTableBodyRowActionForButton(e); });   

   // clear the table (for the case where the user clicks the back button to go to this screen)
   $(_opts.RecsSpecAuthTableBodySelector).children().remove();

   _Recs  = new Map();

   let _RecsJSON = $(_opts.RecsSpecAuthTextAreaSelector).val();

    if (_RecsJSON && _RecsJSON != '[]') {
        let _RecObjs = JSON.parse(_RecsJSON);

        $.each(_RecObjs, function (_idx, _RecObj) {

            // set defaults if inputs not filled
            _RecObj[_opts.RecsTableColCtrlDataAttrValSaveType] = $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValGroups])
                _RecObj[_opts.RecsTableColCtrlDataAttrValGroups] = null;

            // dates loaded from the database should be in the yyyy-MM-dd format instead of MM/dd/yyyy
            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValEffectiveDate])
                _RecObj[_opts.RecsTableColCtrlDataAttrValEffectiveDate] = null;
            else
                _RecObj[_opts.RecsTableColCtrlDataAttrValEffectiveDate] = _dateFormatter(_RecObj[_opts.RecsTableColCtrlDataAttrValEffectiveDate]);

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValExpirationDate])
                _RecObj[opts.RecsTableColCtrlDataAttrValExpirationDate] = null;
            else
                _RecObj[_opts.RecsTableColCtrlDataAttrValExpirationDate] = _dateFormatter(_RecObj[_opts.RecsTableColCtrlDataAttrValExpirationDate]);


            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValORPPracID])
                _RecObj[_opts.RecsTableColCtrlDataAttrValORPPracID] = null;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValORPPracIDInput])
                _RecObj[_opts.RecsTableColCtrlDataAttrValORPPracIDInput] = null;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValORPPracName])
                _RecObj[_opts.RecsTableColCtrlDataAttrValORPPracName] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValORPPracNameInput])
                _RecObj[_opts.RecsTableColCtrlDataAttrValORPPracNameInput] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValORPSelection])
                _RecObj[_opts.RecsTableColCtrlDataAttrValORPSelection] = [];
            else
                _RecObj[_opts.RecsTableColCtrlDataAttrValORPSelection] =
                    JSON.parse(_RecObj["" + _opts.RecsTableColCtrlDataAttrValORPSelection]);

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
