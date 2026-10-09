var SpEdCare = (SpEdCare || {});

SpEdCare.recPatContact = (function ($) {

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

const _viewDetsButClass = 'viewDetsBut';
const _addressColClass  = 'contactAddressCol';

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
    RecObj[_opts.RecsTableColCtrlDataAttrValLastName] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValFirstName] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValPersonRoleID] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] = null;
    RecObj[_opts.RecsTableColCtrlDataAttrValEmail] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValPhone] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValAddress1] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValAddress2] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValCity] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValState] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValZip5] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValZip4] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValSaveType] = $.spedmonWebUI.RECORD_SAVE_TYPE_NEW;

    RecObj[_opts.RecsTableColCtrlDataAttrValHasRoleDetBut] = false;
    RecObj[_opts.RecsTableColCtrlDataAttrValFax] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValNPI] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValMediCalID] = '';
  
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

    return '<td><input type="text" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValLastName + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValLastName] + '" ></td>'
        + '<td><input type="text" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValFirstName + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValFirstName] + '" ></td>'
        + '<td><select ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValRoleID + ' >'
            + '<option disabled value' + ((RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] == null) ? ' selected' : '') + ' > -- select an option --</option>'
            + '<option value="1000"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] == 1000) ? ' selected' : '') + ' >Mother</option>'
            + '<option value="1001"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] == 1001) ? ' selected' : '') + ' >Father</option>'
            + '<option value="1002"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] == 1002) ? ' selected' : '') + ' >Guardian / Surrogate</option>'
            + '<option value="5000"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] == 5000) ? ' selected' : '') + ' >School Nurse</option>'
            + '<option value="5001"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] == 5001) ? ' selected' : '') + ' >Mental Health Provider</option>'
            + '<option value="5002"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] == 5002) ? ' selected' : '') + ' >Teacher</option>'
            + '<option value="2000"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] == 2000) ? ' selected' : '') + ' >Physician</option>'
            + '<option value="3003"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] == 3003) ? ' selected' : '') + ' >Other School Staff</option>'
        + '</select></td>'
        + '<td><input type="text" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValEmail + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValEmail] + '" ></td>'
        + '<td><input type="text" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValPhone + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValPhone] + '" ></td>'
        + '<td><button ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValAddress + ' class="' + _viewDetsButClass + ' ' + _addressColClass + ' ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" type="button" title="Edit Details" role="button" aria-disabled="false"><span class="ui-button-text">Edit Details</span></button></td>';
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
 * _doAcceptAdditionalPhysicianFields */
/**
 * save answers for physician
 ***************************************************************************/
function _doAcceptAdditionalPhysicianFields(RecObj) {

    // save the answers in RecObj
    RecObj[_opts.RecsTableColCtrlDataAttrValFax]       = _opts.$fax.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValNPI]       = _opts.$additionaldata1.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValMediCalID] = _opts.$additionaldata2.val();
 
    _opts.$physicianFieldsCont.dialog("close");
    _currentRecsToTA();
}

/***************************************************************************
 * _doAcceptContactAddress */
/**
 * save answers for contact address
 ***************************************************************************/

function _doAcceptContactAddress(RecObj) {

    // save the answers in RecObj
    RecObj[_opts.RecsTableColCtrlDataAttrValAddress1] = _opts.$addressStreet1.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValAddress2] = _opts.$addressStreet2.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValCity]     = _opts.$addressCity.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValState]    = _opts.$addressState.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValZip5]     = _opts.$addressZip5.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValZip4]     = _opts.$addressZip4.val();
 
    _opts.$patAddressCont.dialog("close");
    _currentRecsToTA();
}

/***************************************************************************
 * _renderPatAddressDialog */
/**
 * 
 ***************************************************************************/

function _renderPatAddressDialog (RecObj) {
    _opts.$patAddressCont.show().dialog(
        {
            width: $(window).width()
            , height: $(window).height()
            , title: "Contact Address"
            , show: {
                effect: 'slide',
                // attach callback to "ok" button to save entered service details answers
                complete: function () {
                    // preload data
                    _opts.$addressStreet1.val(RecObj[_opts.RecsTableColCtrlDataAttrValAddress1]);
                    _opts.$addressStreet2.val(RecObj[_opts.RecsTableColCtrlDataAttrValAddress2]);
                    _opts.$addressCity.val(RecObj[_opts.RecsTableColCtrlDataAttrValCity]);
                    _opts.$addressState.val(RecObj[_opts.RecsTableColCtrlDataAttrValState]);
                    _opts.$addressZip5.val(RecObj[_opts.RecsTableColCtrlDataAttrValZip5]);
                    _opts.$addressZip4.val(RecObj[_opts.RecsTableColCtrlDataAttrValZip4]);
                    
                    _opts.$addressDetsOK.off().bind('click', function (e) {
                        _doAcceptContactAddress(RecObj);
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

    // set up callback functions
    let $addressBut = $_row.find('[' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValAddress + '"]').parent();
    $addressBut.on("click", function () { _renderPatAddressDialog(RecObj); });

    // include the View Details button if the row has one
    if (RecObj[_opts.RecsTableColCtrlDataAttrValHasRoleDetBut] == true) {
        let $physicianCell = $_row.find('select[' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValRoleID + '"]').parent();

        $physicianCell.append(generatePhysicianDetsButtonElem(function () { _showPhysicianDetailCont(RecObj); }));
    } 

}

/***************************************************************************
 * _drawRecsTableBodyRows */
/**
 * 
 ***************************************************************************/

function _drawRecsTableBodyRows() {
  _currentRecsToTA();

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

    var reqUrl = "patient_persons.asmx/delete?tkn=" + tkn;
    var reqData = '{'
                + '"clientid":"'       + _opts.clientID + '"'
                + ',"patientid":"'      + _opts.patID    + '"'
				+ ',"editDelReason":"' + ''             + '"'
				+ ',"validaterec":"'   + 1              + '"'
				+ ',"recid":"'         + recid          + '"}';

    // success callback for ajax
    var fnProcRespSuccess = function (rd) {
        // send another ajax request with the validaterec field now set to 0
        var reqData2 = '{'
                + '"clientid":"'       + _opts.clientID + '"'
                + ',"patientid":"'      + _opts.patID    + '"'
				+ ',"editDelReason":"' + ''             + '"'
				+ ',"validaterec":"'   + 0              + '"'
				+ ',"recid":"'         + recid          + '"}';

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
    
    var tkn = _opts.tkn;
    var recid = RecObj[_opts.RecsTableColCtrlDataAttrValID];
    
    /****** set up ajax url ***********/

    var reqUrl = "patient_persons.asmx/saveContact?tkn=" + tkn;
    var reqData = '{'
                + '"clientid":"'               + _opts.clientID                                     + '"'
				+ ',"patientid":"'             + _opts.patID                                        + '"'
				+ ',"personroleid":"'          + 1                                                  + '"'
				+ ',"personrelationshipid":"'  + RecObj[_opts.RecsTableColCtrlDataAttrValRoleID]    + '"'
				+ ',"lastname":"'              + RecObj[_opts.RecsTableColCtrlDataAttrValLastName]  + '"'
				+ ',"firstname":"'             + RecObj[_opts.RecsTableColCtrlDataAttrValFirstName] + '"'
				+ ',"middlename":"'            + ''                                                 + '"'
				+ ',"phone":"'                 + RecObj[_opts.RecsTableColCtrlDataAttrValPhone]     + '"'
				+ ',"fax":"'                   + RecObj[_opts.RecsTableColCtrlDataAttrValFax]       + '"'
				+ ',"email":"'                 + RecObj[_opts.RecsTableColCtrlDataAttrValEmail]     + '"'
				+ ',"street1":"'               + RecObj[_opts.RecsTableColCtrlDataAttrValAddress1]  + '"'
				+ ',"street2":"'               + RecObj[_opts.RecsTableColCtrlDataAttrValAddress2]  + '"'
				+ ',"city":"'                  + RecObj[_opts.RecsTableColCtrlDataAttrValCity]      + '"'
				+ ',"state":"'                 + RecObj[_opts.RecsTableColCtrlDataAttrValState]     + '"'
				+ ',"zip5":"'                  + RecObj[_opts.RecsTableColCtrlDataAttrValZip5]      + '"'
				+ ',"zip4":"'                  + RecObj[_opts.RecsTableColCtrlDataAttrValZip4]      + '"'
				+ ',"additionaldata1":"'       + RecObj[_opts.RecsTableColCtrlDataAttrValNPI]       + '"'
				+ ',"additionaldata2":"'       + RecObj[_opts.RecsTableColCtrlDataAttrValMediCalID] + '"'
				+ ',"editDelReason":"'         + ''                                                 + '"'
				+ ',"validaterec":"'           + 1                                                  + '"'
				+ ',"savetype":"'              + saveType                                           + '"'
				+ ',"recid":"'                 + recid                                              + '"}';

    // success callback for ajax
    var fnProcRespSuccess = function (rd) {
        // send another ajax request with the validaterec field now set to 0
        var reqData2 = '{'
                      +'"clientid":"'               + _opts.clientID                                     + '"'
					  +',"patientid":"'             + _opts.patID                                        + '"'
					  +',"personroleid":"'          + 1                                                  + '"'
					  +',"personrelationshipid":"'  + RecObj[_opts.RecsTableColCtrlDataAttrValRoleID]    + '"'
					  +',"lastname":"'              + RecObj[_opts.RecsTableColCtrlDataAttrValLastName]  + '"'
					  +',"firstname":"'             + RecObj[_opts.RecsTableColCtrlDataAttrValFirstName] + '"'
					  +',"middlename":"'            + ''                                                 + '"'
					  +',"phone":"'                 + RecObj[_opts.RecsTableColCtrlDataAttrValPhone]     + '"'
					  +',"fax":"'                   + RecObj[_opts.RecsTableColCtrlDataAttrValFax]       + '"'
					  +',"email":"'                 + RecObj[_opts.RecsTableColCtrlDataAttrValEmail]     + '"'
					  +',"street1":"'               + RecObj[_opts.RecsTableColCtrlDataAttrValAddress1]  + '"'
					  +',"street2":"'               + RecObj[_opts.RecsTableColCtrlDataAttrValAddress2]  + '"'
					  +',"city":"'                  + RecObj[_opts.RecsTableColCtrlDataAttrValCity]      + '"'
					  +',"state":"'                 + RecObj[_opts.RecsTableColCtrlDataAttrValState]     + '"'
					  +',"zip5":"'                  + RecObj[_opts.RecsTableColCtrlDataAttrValZip5]      + '"'
					  +',"zip4":"'                  + RecObj[_opts.RecsTableColCtrlDataAttrValZip4]      + '"'
					  +',"additionaldata1":"'       + RecObj[_opts.RecsTableColCtrlDataAttrValNPI]       + '"'
					  +',"additionaldata2":"'       + RecObj[_opts.RecsTableColCtrlDataAttrValMediCalID] + '"'
					  +',"editDelReason":"'         + ''                                                 + '"'
					  +',"validaterec":"'           + 0                                                  + '"'
					  +',"savetype":"'              + saveType                                           + '"'
					  +',"recid":"'                 + recid                                              + '"}';

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
 * _showPhysicianDetailCont */
/**
 * show physician details container
 ***************************************************************************/
function _showPhysicianDetailCont(RecObj) {

    _opts.$physicianFieldsCont.show().dialog(
        {
              width: $(window).width()
            , height: $(window).height()
            , title: "Additional Physician Questions"
            , show: {
                effect: 'slide',
                // attach callback to "ok" button to save entered service details answers
                complete: function () {

                    // prelaod data
                    _opts.$fax.val(RecObj[_opts.RecsTableColCtrlDataAttrValFax]);
                    _opts.$additionaldata1.val(RecObj[_opts.RecsTableColCtrlDataAttrValNPI]);
                    _opts.$additionaldata2.val(RecObj[_opts.RecsTableColCtrlDataAttrValMediCalID]);
                    
                    _opts.$physicianDetsOK.off().bind('click', function(e) {
                        _doAcceptAdditionalPhysicianFields(RecObj);
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
 * generatePhysicianDetsButtonElem */
/**
 * generates button for service details questions to pop up
 ***************************************************************************/
function generatePhysicianDetsButtonElem(callbackFunc) {
    let $physDetBut = $('<button class="' + _viewDetsButClass + '" type="button" title="View Details">&nbsp;</button>');
    $physDetBut.button({ label: 'View Details' });
    $physDetBut.on("click", callbackFunc);

    return $physDetBut;
}

/***************************************************************************
 * _showAdditionalPhysicianQuestions */
/**
 * when a physician is selected, load details
 ***************************************************************************/
function _showAdditionalPhysicianQuestions(RecKey, inputVal, whatCol) {
    // get selected object
    let RecObj = _Recs.get(RecKey);

    // every time we choose another contact role, the old data should be cleared out
    RecObj[_opts.RecsTableColCtrlDataAttrValFax]       = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValNPI]       = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValMediCalID] = '';

    // remove the button if it exists
    whatCol.find('.' + _viewDetsButClass).remove();

    // attach the button if physician is selected
    if (inputVal == 2000) {
        let $physDetBut = generatePhysicianDetsButtonElem(function () { _showPhysicianDetailCont(RecObj); });
        RecObj[_opts.RecsTableColCtrlDataAttrValHasRoleDetBut] = true;
        whatCol.append($physDetBut);

        _showPhysicianDetailCont(RecObj);
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
        // make sure all the fields are filled before proceeding
        if (!RecObj[_opts.RecsTableColCtrlDataAttrValLastName]
            || !RecObj[_opts.RecsTableColCtrlDataAttrValFirstName]
        ) {
            $.spedmonWebUI.dialogMessage('WARNING', "Please make sure the contact name is filled out.", null, 400, 200, null, null, null);
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

  // if physician is selected, load additional questions
  if (_rowAction.doWhat == _opts.RecsTableColCtrlDataAttrValRoleID) {
          _showAdditionalPhysicianQuestions(_rowAction.RecKey, inputVal, _rowAction.whatCol);
  }

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
   _opts.RecsTableColCtrlDataAttrValSaveType      = 'saveType';

   _opts.RecsTableColCtrlDataAttrValLastName      = 'lastName';
   _opts.RecsTableColCtrlDataAttrValFirstName     = 'firstName';
   _opts.RecsTableColCtrlDataAttrValPersonRoleID  = 'personroleid'; 
   _opts.RecsTableColCtrlDataAttrValRoleID        = 'classID2'; 
   _opts.RecsTableColCtrlDataAttrValEmail         = 'email'; 
   _opts.RecsTableColCtrlDataAttrValPhone         = 'phone'; 
   _opts.RecsTableColCtrlDataAttrValAddress       = 'address';  
   _opts.RecsTableColCtrlDataAttrValAddress1      = 'address1';  
   _opts.RecsTableColCtrlDataAttrValAddress2      = 'address2';  
   _opts.RecsTableColCtrlDataAttrValCity          = 'city';  
   _opts.RecsTableColCtrlDataAttrValState         = 'state';  
   _opts.RecsTableColCtrlDataAttrValZip5          = 'zip5';  
   _opts.RecsTableColCtrlDataAttrValZip4          = 'zip4';

   _opts.RecsTableColCtrlDataAttrValHasRoleDetBut = 'hasRoleDetBut';
   _opts.RecsTableColCtrlDataAttrValFax           = 'fax';
   _opts.RecsTableColCtrlDataAttrValNPI           = 'additionalData1';
   _opts.RecsTableColCtrlDataAttrValMediCalID     = 'additionalData2';
   
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

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValLastName])
                _RecObj[_opts.RecsTableColCtrlDataAttrValLastName] = null;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValFirstName])
                _RecObj[_opts.RecsTableColCtrlDataAttrValFirstName] = null;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValRoleID])
                _RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] = null;
            else if (_RecObj[_opts.RecsTableColCtrlDataAttrValRoleID] == 2000)
                _RecObj[_opts.RecsTableColCtrlDataAttrValHasRoleDetBut] = true;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValEmail])
                _RecObj[opts.RecsTableColCtrlDataAttrValEmail] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValPhone])
                _RecObj[_opts.RecsTableColCtrlDataAttrValPhone] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValAddress1])
                _RecObj[_opts.RecsTableColCtrlDataAttrValAddress1] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValAddress2])
                _RecObj[_opts.RecsTableColCtrlDataAttrValAddress2] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValCity])
                _RecObj[_opts.RecsTableColCtrlDataAttrValCity] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValState])
                _RecObj[_opts.RecsTableColCtrlDataAttrValState] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValZip5])
                _RecObj[_opts.RecsTableColCtrlDataAttrValZip5] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValZip4])
                _RecObj[_opts.RecsTableColCtrlDataAttrValZip4] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValFax])
                _RecObj[_opts.RecsTableColCtrlDataAttrValFax] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValNPI])
                _RecObj[_opts.RecsTableColCtrlDataAttrValNPI] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValMediCalID])
                _RecObj[_opts.RecsTableColCtrlDataAttrValMediCalID] = '';

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
