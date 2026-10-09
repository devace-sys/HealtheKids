var SpEdCare = (SpEdCare || {});

SpEdCare.recContract = (function ($) {

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

const _feeDetsButClass = 'feeDetsBut';

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
    RecObj[_opts.RecsTableColCtrlDataAttrValContractNumber] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValStartDate] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValEndDate] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValTypeOfAgreement] = null;
    RecObj[_opts.RecsTableColCtrlDataAttrValFeeStructure] = null;
    RecObj[_opts.RecsTableColCtrlDataAttrValSaveType] = $.spedmonWebUI.RECORD_SAVE_TYPE_NEW;

    RecObj[_opts.RecsTableColCtrlDataAttrValHasFeeDetBut] = false;
    RecObj[_opts.RecsTableColCtrlDataAttrValAdditionalFeeAnswersJSON] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValContractTerms] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValEvergreen] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValTerminationDays] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeFull] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeFull] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeLicense] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValManagerHourlyRate] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValOnsiteRate] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValAdminRate] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValNumHours] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValHoursPer] = null;
    RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeLicense] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValPercentageRate] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeePercentage] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValUnitRate] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeTransmission] = '';
  
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
  $(_opts.RecsContractTextAreaSelector).val(RecsJSON);
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
    
    return '<td><input type="text" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValContractNumber + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValContractNumber] + '" ></td>'
        + '<td><input type="date" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValStartDate + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValStartDate] + '" ></td>'
        + '<td><input type="date" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValEndDate + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValEndDate] + '" ></td>'
        + '<td><select ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValTypeOfAgreement + ' >'
            + '<option disabled value' + ((RecObj[_opts.RecsTableColCtrlDataAttrValTypeOfAgreement] == null) ? ' selected' : '') + ' > -- select an option --</option>'
            + '<option value="1"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValTypeOfAgreement] == 1) ? ' selected' : '') + ' >Full Service</option>'
            + '<option value="2"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValTypeOfAgreement] == 2) ? ' selected' : '') + ' >Software</option>'
        + '</select></td>'
        + '<td><select ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValFeeStructure + ' >'
            + '<option disabled value' + ((RecObj[_opts.RecsTableColCtrlDataAttrValFeeStructure] == null) ? ' selected' : '') + ' > -- select an option --</option>'
            + '<option value="1"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValFeeStructure] == 1) ? ' selected' : '') + ' >Flat Fee</option>'
            + '<option value="2"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValFeeStructure] == 2) ? ' selected' : '') + ' >Percentage</option>'
        + '</select></td>';
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

    let $_tdContractFiles = $('<td></td>');
    if (RecObj[_opts.RecsTableColCtrlDataAttrValSaveType] == $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT) {
        // we only want this feature for existing records
        let $_butContractFiles = $('<i ' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValManageContractFiles + '" class="fa fa-paperclip" title="Manage Contract Files"></i>');
        $($_tdContractFiles).append($_butContractFiles);
    }
    $($_row).append($_tdContractFiles);
    
    $($_row).append(_createRecTableColsCommonMkup (RecObj));

    if (_initMode) {
        // if called in init, we want to preload in the correct order so we use append()
        $(_opts.RecsContractTableBodySelector).append($_row);
    }
    else {
        // otherwise, we use prepend to generate a row on the top of the other records
        $(_opts.RecsContractTableBodySelector).prepend($_row);
    }

    // include the View Details button if the row has one
    if (RecObj[_opts.RecsTableColCtrlDataAttrValHasFeeDetBut] == true) {
        let $feeStructureCell = $_row.find('select[' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValFeeStructure + '"]').parent();

        $feeStructureCell.append(generateFeeDetsButtonElem(function () { _showFeeDetailCont(RecObj); }));
    } 
}

/***************************************************************************
 * _drawRecsTableBodyRows */
/**
 * 
 ***************************************************************************/

function _drawRecsTableBodyRows() {
  _currentRecsToTA();

  $(_opts.RecsContractTableBodySelector).children().remove();

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
    var tkn   = _opts.tkn;
    var recid = RecObj[_opts.RecsTableColCtrlDataAttrValID];

    /****** set up ajax url ***********/

    var reqUrl  = "client_contracts.asmx/delete?tkn=" + tkn;
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
 * _createAdditionalFeeAnswersJSON */
/**
 * 
 ***************************************************************************/

function _createAdditionalFeeAnswersJSON (RecObj) {
    return '{'
        + '"contractTerms":'            + ((RecObj[_opts.RecsTableColCtrlDataAttrValContractTerms]) ?
                                               RecObj[_opts.RecsTableColCtrlDataAttrValContractTerms] : '""')
        + ',"evergreen":'               + ((RecObj[_opts.RecsTableColCtrlDataAttrValEvergreen]) ?
                                               RecObj[_opts.RecsTableColCtrlDataAttrValEvergreen] : '""')
        + ',"terminationDays":'         + ((RecObj[_opts.RecsTableColCtrlDataAttrValTerminationDays]) ?
                                               RecObj[_opts.RecsTableColCtrlDataAttrValTerminationDays] : '""')
        + ',"annualFeeFull":'           + ((RecObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeFull]) ?
                                               '"' + RecObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeFull] + '"' : '""')
        + ',"miscFlatFeeFull":'         + ((RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeFull]) ?
                                               '"' + RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeFull] + '"' : '""')
        + ',"annualFeeLicense":'        + ((RecObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeLicense]) ?
                                               '"' + RecObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeLicense] + '"' : '""')
        + ',"managerHourlyRate":'       + ((RecObj[_opts.RecsTableColCtrlDataAttrValManagerHourlyRate]) ?
                                               '"' + RecObj[_opts.RecsTableColCtrlDataAttrValManagerHourlyRate] + '"' : '""')
        + ',"onsiteRate":'              + ((RecObj[_opts.RecsTableColCtrlDataAttrValOnsiteRate]) ?
                                               '"' + RecObj[_opts.RecsTableColCtrlDataAttrValOnsiteRate] + '"' : '""')
        + ',"adminRate":'               + ((RecObj[_opts.RecsTableColCtrlDataAttrValAdminRate]) ?
                                               '"' + RecObj[_opts.RecsTableColCtrlDataAttrValAdminRate] + '"' : '""')
        + ',"numHours":'                + ((RecObj[_opts.RecsTableColCtrlDataAttrValNumHours]) ?
                                               RecObj[_opts.RecsTableColCtrlDataAttrValNumHours] : '""')
        + ',"hoursPer":'                + ((RecObj[_opts.RecsTableColCtrlDataAttrValHoursPer]) ?
                                               RecObj[_opts.RecsTableColCtrlDataAttrValHoursPer] : '""')
        + ',"miscFlatFeeLicense":'      + ((RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeLicense]) ?
                                               '"' + RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeLicense] + '"' : '""')
        + ',"percentageRate":'          + ((RecObj[_opts.RecsTableColCtrlDataAttrValPercentageRate]) ?
                                               '"' + RecObj[_opts.RecsTableColCtrlDataAttrValPercentageRate] + '"' : '""')
        + ',"miscFlatFeePercentage":'   + ((RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeePercentage]) ?
                                               '"' + RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeePercentage] + '"' : '""')
        + ',"unitRate":'                + ((RecObj[_opts.RecsTableColCtrlDataAttrValUnitRate]) ?
                                               '"' + RecObj[_opts.RecsTableColCtrlDataAttrValUnitRate] + '"' : '""')
        + ',"miscFlatFeeTransmission":' + ((RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeTransmission]) ?
                                               '"' + RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeTransmission] + '"' : '""')
        + '}';
}

/***************************************************************************
 * _parseAdditionalFeeAnswersJSON */
/**
 * 
 ***************************************************************************/

function _parseAdditionalFeeAnswersJSON (RecObj) {

    let additionalFeeAnswersObj = JSON.parse(RecObj[_opts.RecsTableColCtrlDataAttrValAdditionalFeeAnswersJSON]);

    // load the answers into the slide-in fields
    RecObj[_opts.RecsTableColCtrlDataAttrValContractTerms]           = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValContractTerms];        
    RecObj[_opts.RecsTableColCtrlDataAttrValEvergreen]               = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValEvergreen];             
    RecObj[_opts.RecsTableColCtrlDataAttrValTerminationDays]         = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValTerminationDays];        
    RecObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeFull]           = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeFull];          
    RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeFull]         = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeFull];        
    RecObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeLicense]        = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeLicense];       
    RecObj[_opts.RecsTableColCtrlDataAttrValManagerHourlyRate]       = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValManagerHourlyRate];       
    RecObj[_opts.RecsTableColCtrlDataAttrValOnsiteRate]              = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValOnsiteRate];           
    RecObj[_opts.RecsTableColCtrlDataAttrValAdminRate]               = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValAdminRate];              
    RecObj[_opts.RecsTableColCtrlDataAttrValNumHours]                = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValNumHours];               
    RecObj[_opts.RecsTableColCtrlDataAttrValHoursPer]                = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValHoursPer];               
    RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeLicense]      = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeLicense];     
    RecObj[_opts.RecsTableColCtrlDataAttrValPercentageRate]          = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValPercentageRate];        
    RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeePercentage]   = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeePercentage];  
    RecObj[_opts.RecsTableColCtrlDataAttrValUnitRate]                = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValUnitRate];               
    RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeTransmission] = additionalFeeAnswersObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeTransmission];
}

/***************************************************************************
 * _saveRecToDatabase */
/**
 * sends ajax request to delete a record from the database
 ***************************************************************************/

function _saveRecToDatabase (RecObj, saveType) {
    
    var tkn            = _opts.tkn;
    var cltid          = _opts.clientID;
    var contractNumber = RecObj[_opts.RecsTableColCtrlDataAttrValContractNumber];
    var startDate      = RecObj[_opts.RecsTableColCtrlDataAttrValStartDate];
    var endDate        = RecObj[_opts.RecsTableColCtrlDataAttrValEndDate];
    var contractTypeID = RecObj[_opts.RecsTableColCtrlDataAttrValTypeOfAgreement];
    var feeStructureID = RecObj[_opts.RecsTableColCtrlDataAttrValFeeStructure];
    var recid          = RecObj[_opts.RecsTableColCtrlDataAttrValID];

    // create JSON string from the fee structure slide-in
    var additionalFeeAnswersJSON = _createAdditionalFeeAnswersJSON(RecObj);
    
    /****** set up ajax url ***********/

    var reqUrl = "client_contracts.asmx/save?tkn=" + tkn;
    var reqData = JSON.stringify({
        "clientid": cltid
        , "contractNumber": contractNumber
        , "startDate": startDate
        , "endDate": endDate
        , "contractTypeID": contractTypeID
        , "feeStructureID": feeStructureID
        , "additionalFeeAnswersJSON": additionalFeeAnswersJSON
        , "editDelReason": ""
        , "validaterec": "0"
        , "savetype": saveType
        , "recid": recid
    });

    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
        .then(responseData => {
            if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {
                RecObj[_opts.RecsTableColCtrlDataAttrValID] = responseData.rawData.recordID;
            }

            // this record now becomes an EXISTING record (if not already an existing one)
            RecObj[_opts.RecsTableColCtrlDataAttrValSaveType] = $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT;

            // redraw the table to add the paperclip icons
            _drawRecsTableBodyRows();

            $.spedmonWebUI.dialogMessage('DONE', "Your record was successfully saved.", null, 400, 200, null, null, null);
        })
        .catch(responseData => {
            $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
        });
}

/***************************************************************************
 * _doAcceptAdditionalFeeFields */
/**
 * save answers for fee structure
 ***************************************************************************/
function _doAcceptAdditionalFeeFields(RecObj) {

    // save the answers in RecObj
    RecObj[_opts.RecsTableColCtrlDataAttrValContractTerms]           = _opts.$contractTerms.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValEvergreen]               = _opts.$evergreen.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValTerminationDays]         = _opts.$terminationDays.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeFull]           = _opts.$annualFeeFull.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeFull]         = _opts.$miscFlatFeeFull.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeLicense]        = _opts.$annualFeeLicense.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValManagerHourlyRate]       = _opts.$managerHourlyRate.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValOnsiteRate]              = _opts.$onsiteRate.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValAdminRate]               = _opts.$adminRate.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValNumHours]                = _opts.$numHours.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValHoursPer]                = _opts.$hoursPer.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeLicense]      = _opts.$miscFlatFeeLicense.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValPercentageRate]          = _opts.$percentageRate.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeePercentage]   = _opts.$miscFlatFeePercentage.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValUnitRate]                = _opts.$unitRate.val();
    RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeTransmission] = _opts.$miscFlatFeeTransmission.val();
 
    _opts.$feeStructureCont.dialog("close");
    _currentRecsToTA();
}


/***************************************************************************
 * _showFeeDetailCont */
/**
 * show fee details container
 ***************************************************************************/
function _showFeeDetailCont(RecObj) {

    _opts.$feeStructureCont.show().dialog(
        {
              width: $(window).width()
            , height: $(window).height()
            , title: "Additional Fee Questions"
            , show: {
                effect: 'slide',
                // attach callback to "ok" button to save entered service details answers
                complete: function () {
                    // prelaod data
                    _opts.$contractTerms.val(RecObj[_opts.RecsTableColCtrlDataAttrValContractTerms]);
                    _opts.$evergreen.val(RecObj[_opts.RecsTableColCtrlDataAttrValEvergreen]);
                    _opts.$terminationDays.val(RecObj[_opts.RecsTableColCtrlDataAttrValTerminationDays]);
                    _opts.$annualFeeFull.val(RecObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeFull]);
                    _opts.$miscFlatFeeFull.val(RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeFull]);
                    _opts.$annualFeeLicense.val(RecObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeLicense]);
                    _opts.$managerHourlyRate.val(RecObj[_opts.RecsTableColCtrlDataAttrValManagerHourlyRate]);
                    _opts.$onsiteRate.val(RecObj[_opts.RecsTableColCtrlDataAttrValOnsiteRate]);
                    _opts.$adminRate.val(RecObj[_opts.RecsTableColCtrlDataAttrValAdminRate]);
                    _opts.$numHours.val(RecObj[_opts.RecsTableColCtrlDataAttrValNumHours]);
                    _opts.$hoursPer.val(RecObj[_opts.RecsTableColCtrlDataAttrValHoursPer]);
                    _opts.$miscFlatFeeLicense.val(RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeLicense]);
                    _opts.$percentageRate.val(RecObj[_opts.RecsTableColCtrlDataAttrValPercentageRate]);
                    _opts.$miscFlatFeePercentage.val(RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeePercentage]);
                    _opts.$unitRate.val(RecObj[_opts.RecsTableColCtrlDataAttrValUnitRate]);
                    _opts.$miscFlatFeeTransmission.val(RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeTransmission]);

                    _opts.$feeDetsOK.off().bind('click', function(e) {
                        _doAcceptAdditionalFeeFields(RecObj);
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
 * generateFeeDetsButtonElem */
/**
 * generates button for service details questions to pop up
 ***************************************************************************/
function generateFeeDetsButtonElem(callbackFunc) {
    let $feeDetBut = $('<button class="' + _feeDetsButClass + '" type="button" title="View Details">&nbsp;</button>');
    $feeDetBut.button({ label: 'View Details' });
    $feeDetBut.on("click", callbackFunc);

    return $feeDetBut;
}

/***************************************************************************
 * _showAdditionalFeeQuestions */
/**
 * when a fee structure is selected load details if needed
 ***************************************************************************/
function _showAdditionalFeeQuestions(RecKey, whatRow, whatCol) {
    // get selected object
    let RecObj = _Recs.get(RecKey);

    // attach fee details button to this row so they can always go to the questions
    if (RecObj[_opts.RecsTableColCtrlDataAttrValHasFeeDetBut] == false) {
        let $feeDetBut = generateFeeDetsButtonElem(function () { _showFeeDetailCont(RecObj); });
        RecObj[_opts.RecsTableColCtrlDataAttrValHasFeeDetBut] = true;
        whatCol.append($feeDetBut);
    }

    _showFeeDetailCont(RecObj);
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

    // Manage PBS documents
    else if (_rowAction.doWhat == _opts.RecsTableColCtrlDataAttrValManageContractFiles) {
        manageContractFiles();
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

  // if fee structure selected, show details if necessary
  if (_rowAction.doWhat == _opts.RecsTableColCtrlDataAttrValFeeStructure) {
      _showAdditionalFeeQuestions(_rowAction.RecKey, _rowAction.whatRow, _rowAction.whatCol);
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
   _opts.RecsTableRowDataAttr                                = 'data-Rec-id';
   _opts.RecsTableColCtrlDataAttr                            = 'data-Rec-ctrl';
   _opts.RecsTableColCtrlDataAttrValID                       = 'id';
   _opts.RecsTableColCtrlDataAttrValRemove                   = 'remove';
   _opts.RecsTableColCtrlDataAttrValSave                     = 'save';
   _opts.RecsTableColCtrlDataAttrValManageContractFiles      = 'manageContractFiles';
   _opts.RecsTableColCtrlDataAttrValContractNumber           = 'contractNumber'; 
   _opts.RecsTableColCtrlDataAttrValStartDate                = 'startDateStr'; 
   _opts.RecsTableColCtrlDataAttrValEndDate                  = 'endDateStr';
   _opts.RecsTableColCtrlDataAttrValTypeOfAgreement          = 'contractTypeID'; 
   _opts.RecsTableColCtrlDataAttrValFeeStructure             = 'feeStructureID';
   _opts.RecsTableColCtrlDataAttrValHasFeeDetBut             = 'hasFeeDetBut';
   _opts.RecsTableColCtrlDataAttrValSaveType                 = 'saveType'; 

   _opts.RecsTableColCtrlDataAttrValAdditionalFeeAnswersJSON = 'additionalFeeAnswersJSON';
   _opts.RecsTableColCtrlDataAttrValContractTerms            = 'contractTerms';
   _opts.RecsTableColCtrlDataAttrValEvergreen                = 'evergreen';
   _opts.RecsTableColCtrlDataAttrValTerminationDays          = 'terminationDays';
   _opts.RecsTableColCtrlDataAttrValAnnualFeeFull            = 'annualFeeFull';
   _opts.RecsTableColCtrlDataAttrValMiscFlatFeeFull          = 'miscFlatFeeFull';
   _opts.RecsTableColCtrlDataAttrValAnnualFeeLicense         = 'annualFeeLicense';
   _opts.RecsTableColCtrlDataAttrValManagerHourlyRate        = 'managerHourlyRate';
   _opts.RecsTableColCtrlDataAttrValOnsiteRate               = 'onsiteRate';
   _opts.RecsTableColCtrlDataAttrValAdminRate                = 'adminRate';
   _opts.RecsTableColCtrlDataAttrValNumHours                 = 'numHours';
   _opts.RecsTableColCtrlDataAttrValHoursPer                 = 'hoursPer';
   _opts.RecsTableColCtrlDataAttrValMiscFlatFeeLicense       = 'miscFlatFeeLicense';
   _opts.RecsTableColCtrlDataAttrValPercentageRate           = 'percentageRate';
   _opts.RecsTableColCtrlDataAttrValMiscFlatFeePercentage    = 'miscFlatFeePercentage';
   _opts.RecsTableColCtrlDataAttrValUnitRate                 = 'unitRate';
   _opts.RecsTableColCtrlDataAttrValMiscFlatFeeTransmission  = 'miscFlatFeeTransmission';
   
   _opts.RecsTableColButsSubSelector = 'tr td i';
   _opts.RecsTableColInputsSubSelector = 'tr td input, tr td select, tr td textarea';

   // callback for inputs only
   $(_opts.RecsContractTableBodySelector).on( 'change'
                                       , _opts.RecsTableColInputsSubSelector
	                                   , function(e){ _handleRecsTableBodyRowActionForInput(e); });
   //callback for buttons only
   $(_opts.RecsContractTableBodySelector).on( 'click'
                                       , _opts.RecsTableColButsSubSelector
	                                   , function(e){ _handleRecsTableBodyRowActionForButton(e); });   

   // clear the table (for the case where the user clicks the back button to go to this screen)
   $(_opts.RecsContractTableBodySelector).children().remove();

   _Recs  = new Map();

   let _RecsJSON = $(_opts.RecsContractTextAreaSelector).val();
    
    if (_RecsJSON && _RecsJSON != '[]') {
        let _RecObjs = JSON.parse(_RecsJSON);

        $.each(_RecObjs, function (_idx, _RecObj) {
            
            // set defaults if inputs not filled
            _RecObj[_opts.RecsTableColCtrlDataAttrValSaveType]     = $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT;
            _RecObj[_opts.RecsTableColCtrlDataAttrValHasFeeDetBut] = true;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValContractNumber])
                _RecObj[_opts.RecsTableColCtrlDataAttrValContractNumber] = null;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValStartDate])
                _RecObj[_opts.RecsTableColCtrlDataAttrValStartDate] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValEndDate])
                _RecObj[_opts.RecsTableColCtrlDataAttrValEndDate] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValTypeOfAgreement])
                _RecObj[_opts.RecsTableColCtrlDataAttrValTypeOfAgreement] = null;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValFeeStructure])
                _RecObj[_opts.RecsTableColCtrlDataAttrValFeeStructure] = null;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValAdditionalFeeAnswersJSON]) {
                _RecObj[_opts.RecsTableColCtrlDataAttrValContractTerms] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValEvergreen] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValTerminationDays] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeFull] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeFull] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValAnnualFeeLicense] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValManagerHourlyRate] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValOnsiteRate] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValAdminRate] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValNumHours] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValHoursPer] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeLicense] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValPercentageRate] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeePercentage] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValUnitRate] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValMiscFlatFeeTransmission] = null;
            }
            else {
                // if answers are loaded, parse the JSON into the individual fields
                _parseAdditionalFeeAnswersJSON(_RecObj);
            }
            
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
