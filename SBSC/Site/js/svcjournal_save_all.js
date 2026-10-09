var SpEdCare = (SpEdCare || {});

SpEdCare.svcjournalOnDos = (function ($) {

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

const _servicePrefix               = 'eventID-';
const _notesIDPrefix               = 'notes-for-';
var   _salt                        = 1; // used for table record id's
var   _saltForNotes                = 1;
const _selectBoxColClass           = 'selBoxCol';
const _startTimeColClass           = 'startTimeCol';
const _endTimeColClass             = 'endTimeCol';
const _selectBoxColShowDetBtnClass = 'selBoxColShowDetBtn';
const _noteLibraryClass            = 'noteLibraryCol';
const _orpDocID                    = 'orpDocID';
const _orpDocNameID                = 'orpDocID_selection';
const _pulsateAnimationClass       = 'spedmon-animation-pulsate'; // used for pulsating effect
const _formBuilderFormID           = 'spedmon-form-builder-questions-answers-form';
const _formBuilderClientID         = 'spedmon-form-builder-patient-goals-client-id';
const _formBuilderPatID            = 'spedmon-form-builder-patient-goals-pat-id';
const _formBuilderGroupID          = 'spedmon-form-builder-patient-goals-group-id';

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
 * _createNotesID  */
/**
 *
 ****************************************************************************/

function _createNotesID (patID) {
 
    return _notesIDPrefix + patID + '-' + _salt;
}

/***************************************************************************
 * _createRecObj */
/**
 * 
 ***************************************************************************/

function _createRecObj () {
    var RecObj = {};
    
    // set default values
    RecObj[_opts.RecsTableColCtrlDataAttrValID]                    = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValDuppedRecKey]          = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValServiceClass]          = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassInput]     = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassName]      = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassNameInput] = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValPlanType]              = 1;
    RecObj[_opts.RecsTableColCtrlDataAttrValStartTime]             = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValEndTime]               = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValNotes]                 = '';
    RecObj[_opts.RecsTableColCtrlDataAttrValCanEdit]               = true;
    RecObj[_opts.RecsTableColCtrlDataAttrValReqORPDoc]             = null;
    RecObj[_opts.RecsTableColCtrlDataAttrValReqStartTime]          = null;
    RecObj[_opts.RecsTableColCtrlDataAttrValReqEndTime]            = null;
    RecObj[_opts.RecsTableColCtrlDataAttrValOrderID]               = null;
    RecObj[_opts.RecsTableColCtrlDataAttrValOrderName]             = null;
    RecObj[_opts.RecsTableColCtrlDataAttrValSaveType]              = $.spedmonWebUI.RECORD_SAVE_TYPE_NEW;
    RecObj[_opts.RecsTableColCtrlDataAttrValHasUnsavedChanges]     = true;
    RecObj[_opts.RecsTableColCtrlDataAttrValFormQuestionsJSONForOrder] = '{}';
    RecObj[_opts.RecsTableColCtrlDataAttrValFormAnswersJSONForOrder] = '{}';
    RecObj[_opts.RecsTableColCtrlDataAttrValFormQuestionsJSON] = '{}';
    RecObj[_opts.RecsTableColCtrlDataAttrValFormAnswersJSON] = '{}';
  
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
  $(_opts.SvcRecsTextAreaSelector).val(RecsJSON);
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
 * _genServiceSelBoxID */
/**
 *
 ***************************************************************************/

function _genServiceSelBoxID() {
    
    return _servicePrefix + _salt;
}

/***************************************************************************
 * _createRecTableColsCommonMkup */
/**
 *
 ***************************************************************************/

function _createRecTableColsCommonMkup(RecObj, notesID) {
    // handle service selection logic only if record is editable
    if (RecObj[_opts.RecsTableColCtrlDataAttrValCanEdit]) {
        // set selection properties
        RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassInput] = _genServiceSelBoxID();
        RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassNameInput] = RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassInput] + '_selection';

        _salt++;
    }

    return ((RecObj[_opts.RecsTableColCtrlDataAttrValCanEdit]) ?
            '<td><select ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValPlanType + ' >'
                + '<option disabled value' + ((RecObj[_opts.RecsTableColCtrlDataAttrValPlanType] == null) ? ' selected' : '') + ' > -- select an option --</option>'
                + '<option value="1"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValPlanType] == 1) ? ' selected' : '') + ' >IEP / IFSP</option>'
                + '<option value="0"' + ((RecObj[_opts.RecsTableColCtrlDataAttrValPlanType] == 0) ? ' selected' : '') + ' >Other (IHP, 504, Counseling, etc.)</option>'
            + '</select></td>'
            + '<td class="' + _selectBoxColClass + '"><input name="' + RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassInput] + '" id="' + RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassInput] + '" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValServiceClass + ' title="Select a Service Activity"></td>'
            + '<td class="' + _startTimeColClass + '">'
                + ((RecObj[_opts.RecsTableColCtrlDataAttrValReqStartTime] == true) ?
                    '<input ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValStartTime + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValStartTime] + '" type="time" />'
                    :
                    ''
                )
            + '</td>'
            + '<td class="' + _endTimeColClass + '">'
                + ((RecObj[_opts.RecsTableColCtrlDataAttrValReqEndTime] == true) ?
                    '<input ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValEndTime + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValEndTime] + '" type="time" />'
                    :
                    ''
                )
            + '</td>'
            + '<td class="' + _noteLibraryClass + '"><textarea id="' + notesID + '" ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValNotes + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValNotes] + '" >' + ((RecObj[_opts.RecsTableColCtrlDataAttrValNotes]) ? RecObj[_opts.RecsTableColCtrlDataAttrValNotes] : '') + '</textarea></td>'
        :
            '<td><input value="' + ((RecObj[_opts.RecsTableColCtrlDataAttrValPlanType] == 1) ? 'IEP / IFSP' : 'Other (IHP, 504, Counseling, etc.)') 
                + '" title="' + ((RecObj[_opts.RecsTableColCtrlDataAttrValPlanType] == 1) ? 'IEP / IFSP' : 'Other (IHP, 504, Counseling, etc.)') + '" readonly /></td>'
            + '<td><textarea title="' + RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassName] + '" readonly>' + RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassName] + '</textarea></td>'
            + '<td><input  value="' + RecObj[_opts.RecsTableColCtrlDataAttrValStartTime] + '" type="time" readonly /></td>'
            + '<td><input  value="' + RecObj[_opts.RecsTableColCtrlDataAttrValEndTime]   + '" type="time" readonly /></td>'
            + '<td><textarea  readonly>' + RecObj[_opts.RecsTableColCtrlDataAttrValNotes] + '</textarea></td>'
        );
        
}

/***************************************************************************
 * _updateCurrentRecsForSpecificField */
/**
 * updates current
 ***************************************************************************/

function _updateCurrentRecsForSpecificField(key, val, whatField) {
    var RecObj = _Recs.get(key);

    RecObj[whatField] = val;

    // logic to pulsate save icon if the value being set is not savetype (which means record needs to be saved)
    if (whatField != _opts.RecsTableColCtrlDataAttrValHasUnsavedChanges) {
        RecObj[_opts.RecsTableColCtrlDataAttrValHasUnsavedChanges] = true;
    }

    _checkForUnsavedChanges(key);

    _Recs.set(key, RecObj);
    _currentRecsToTA();
}

/***************************************************************************
 * _sortCurrentRecsByStartTime */
/**
 * 
 ***************************************************************************/

function _sortCurrentRecsByStartTime () {
  
  let _arr = _currentRecsToArray();
  let _sortedMap = new Map();
  
  _arr.sort(function(a, b) {
      
    let cmpA = a[_opts.RecsTableColCtrlDataAttrValStartTime];
    let cmpB = b[_opts.RecsTableColCtrlDataAttrValStartTime];
    
    // If no start date, record goes to the bottom
    if (!cmpA) return 1
    if (!cmpB) return -1

	if (cmpA < cmpB) { return -1; }
    if (cmpA > cmpB) { return 1; }
    return 0;
  });
  
   $.each( _arr, function( _idx, _pObj ) {
     let _pk = _createRecKey (_pObj);
	 _sortedMap.set(_pk,_pObj);
   });
   _Recs = new Map(_sortedMap);
}


/***************************************************************************
 * _checkForUnsavedChanges */
/**
 * checks an object for unsaved changes and pulsates save icon if any exist
 ***************************************************************************/

function _checkForUnsavedChanges(RecKey) {
    var RecObj = _Recs.get(RecKey);

    let hasUnsavedChanges = RecObj[_opts.RecsTableColCtrlDataAttrValHasUnsavedChanges];
    let $saveIcon = $('tr[' + _opts.RecsTableRowDataAttr + '="' + RecKey + '"]').find('i[' + _opts.RecsTableColCtrlDataAttr + ' = "' + _opts.RecsTableColCtrlDataAttrValSave + '"]');

    if (hasUnsavedChanges) {
        $saveIcon.addClass(_pulsateAnimationClass);
    } else {
        $saveIcon.removeClass(_pulsateAnimationClass);
    }
}

/***************************************************************************
 * doAcceptOrpDoc */
/**
 * save user's orp doc selection
 ***************************************************************************/

function _doAcceptOrpDoc(RecKey) {
    let orpDocVal     = $('#' + _orpDocID).val();
    let orpDocNameVal = $('#' + _orpDocNameID).val();

    // save the answer
    if (orpDocVal) {
        _updateCurrentRecsForSpecificField(RecKey, orpDocVal    , _opts.RecsTableColCtrlDataAttrValOrderID   );
        _updateCurrentRecsForSpecificField(RecKey, orpDocNameVal, _opts.RecsTableColCtrlDataAttrValOrderName );
    }    

    $(_opts.orpDocContSel).dialog("close");
    _currentRecsToArray();
    _drawRecsTableBodyRows();
}

/***************************************************************************
 * _createSvcJournalTblRowAttrSelector */
/**
 * 
 ***************************************************************************/
function _createSvcJournalTblRowAttrSelector(attr) {
    if (!attr) return '';

    return _opts.SvcRecsTableBodySelector + ' tr[' + _opts.RecsTableRowDataAttr + '="' + attr + '"]';
}

/***************************************************************************
 * _createSvcJournalTblColAttrSelector */
/**
 * this function returns a general [attr="value"] selector
 ***************************************************************************/
function _createSvcJournalTblColAttrSelector(attr) {
    if (!attr) return '';

    return '[' + _opts.RecsTableColCtrlDataAttr + '="' + attr + '"]';
}

/***************************************************************************
 * _createSvcJournalTblColAttrSelectorIncludingTbl */
/**
 * returns a full selector that starts from the table and goes to individual input
 ***************************************************************************/
function _createSvcJournalTblColAttrSelectorIncludeTbl(RecKey, attr) {
    if (!attr || !RecKey) return '';

    return _createSvcJournalTblRowAttrSelector(RecKey) + ' ' + _createSvcJournalTblColAttrSelector(attr);
}

/***************************************************************************
 * _setSvcJournalColSelectValueAndUpdateUI */
/**
 * sets a specific select value in the global object and updates UI
 ***************************************************************************/

function _setSvcJournalColSelectValueAndUpdateUI(RecKey, whatField, value) {
    _updateCurrentRecsForSpecificField(RecKey, value, whatField);

    // update the dropdown
    let $selectElem = $(_createSvcJournalTblColAttrSelectorIncludeTbl(RecKey, whatField));
    $selectElem.val(value);
    let $selectOptions = $selectElem.find('option');
    $selectOptions.removeAttr('selected');
    $selectOptions.filter('[value="' + value + '"]').prop("selected", true);
}
    
/***************************************************************************
 * showOrpSel */
/**
 * show the orp selection
 ***************************************************************************/

function _showOrpSelCont(RecKey) {

    var RecObj = _Recs.get(RecKey);

    // remove previous entry
    $('#' + _orpDocID).parent().remove();

    $(_opts.orpDocContSel).show().dialog(
    {
          width: $(window).width()
        , height: $(window).height()
        , title: "This service requires an Order ORP to be selected"
        , show: {
            effect: 'slide',
            // attach callback to "ok" button to save entered service details answers
            complete: function () {
                // append the input field
                $('<input name="' + _orpDocID + '" value="" title="Select Order or Prescription" autocomplete="off" class="mba-web-ui-field-simple mba-web-ui-field-ctrl-type-select-box" id="'
                    + _orpDocID + '" style="display: none;">').insertAfter($(_opts.orpInputFieldPlaceHolderSel));

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
                        // update the notes
                        //RecObj[_opts.RecsTableColCtrlDataAttrValNotes] = ui.item.recData2;
                        var formQuestionsJSON = (!ui.item.recData5) ? '{}' : ui.item.recData5;
                        _updateCurrentRecsForSpecificField(RecKey, formQuestionsJSON, _opts.RecsTableColCtrlDataAttrValFormQuestionsJSONForOrder);
                        _updateCurrentRecsForSpecificField(RecKey, '{}', _opts.RecsTableColCtrlDataAttrValFormAnswersJSONForOrder);

                        // check plan type
                        // note: recData6 as of 3/17/2022 is "iep" flag
                        if (ui.item.recData6) { _setSvcJournalColSelectValueAndUpdateUI(RecKey, _opts.RecsTableColCtrlDataAttrValPlanType, ui.item.recData6); }
                    },
                    ajaxopts: {
                        url: "orp_documents.asmx/viewSel?tkn=" + _opts.tkn,
                        data: "",
                        namevalues:
                            [{
                                name: 'clientid', value: $(_opts.clientIDSel).val()
                            }, {                         
                                name: 'pracid', value: $(_opts.pracIDSel).val()
                            }, {
                                name: 'patid', value: $(_opts.patIDSel).val()
                            }]
                        
                    }
                });

                $(_opts.orpDocsOKSel).off().bind('click', function (e) {
                    _doAcceptOrpDoc(RecKey);
                });

                // set pre-chosen values if they exist
                if (RecObj[_opts.RecsTableColCtrlDataAttrValOrderID] && RecObj[_opts.RecsTableColCtrlDataAttrValOrderID] != "0" && RecObj[_opts.RecsTableColCtrlDataAttrValOrderName]) {
                    $('#' + _orpDocID).val(RecObj[_opts.RecsTableColCtrlDataAttrValOrderID]);  
                    $('#' + _orpDocNameID).val(RecObj[_opts.RecsTableColCtrlDataAttrValOrderName]);               
                }
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
 * _getFormData */
/**
 *
 ***************************************************************************/

function _getFormData(RecKey, nameID, formDataFromStandardSelectionNameForSvcJournalJSON ) {

    _updateCurrentRecsForSpecificField(RecKey, '{}', _opts.RecsTableColCtrlDataAttrValFormQuestionsJSON);
    _updateCurrentRecsForSpecificField(RecKey, '{}', _opts.RecsTableColCtrlDataAttrValFormAnswersJSON);

    let RecObj = _Recs.get(RecKey);

    /* If there is a orp standard service selection name form for this selection 
     * use it and return.*/

    if (formDataFromStandardSelectionNameForSvcJournalJSON) {
        _updateCurrentRecsForSpecificField(RecKey, formDataFromStandardSelectionNameForSvcJournalJSON, _opts.RecsTableColCtrlDataAttrValFormQuestionsJSON);
        return;
    }

    /* Otherwise see if there is an associated service name selection that has
     * form data we can use */

    /****** set up ajax url ***********/

    var tkn = _opts.tkn;
    var iep = (RecObj[_opts.RecsTableColCtrlDataAttrValPlanType] == 1) ? "2" : "3";

    var reqUrl = "claim_service_name_xref_and_form_data_records.asmx/loadN?tkn=" + tkn;

    var reqData = JSON.stringify({
        "clientid": $(_opts.clientIDSel).val()
        , "plantypeid": iep
        , "groupid": $(_opts.pracGroupID).val()
        , "nameid": nameID
    });
        
    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
        .then(responseData => {

            /* If there is a service name form for this selection use it*/

            if (responseData.rawData.entity.hasFormData) {
                // update formQuestionsJSON for the record
                _updateCurrentRecsForSpecificField(RecKey, responseData.rawData.entity.formDataJson, _opts.RecsTableColCtrlDataAttrValFormQuestionsJSON);
            }

            /* Otherwise assume no form data */

            else {
           
               _updateCurrentRecsForSpecificField(RecKey, '{}', _opts.RecsTableColCtrlDataAttrValFormQuestionsJSON);
            }
        })
        .catch(responseData => {

        });
}

/***************************************************************************
 * _getServiceSelection */
/**
 * Creates the Service selection control
 ***************************************************************************/

function _getServiceSelection($obj, RecKey) {

    var RecObj = _Recs.get(RecKey);

    var tkn       = _opts.tkn;
    var journalid = $(_opts.journalIDSel).val();
    var pracid    = $(_opts.pracIDSel).val();
    var patid     = $(_opts.patIDSel).val();
    var clientid  = $(_opts.clientIDSel).val();
    var groupid   = $(_opts.pracGroupID).val();

    
    /****** set up ajax url ***********/

    var reqUrl = "servicejournalseventselections.asmx/viewSelJournalEventsAndPatOrders?tkn=" + tkn;
    var reqData = [{ name: "journalid",   value: journalid }
                , { name: "pracid",       value: pracid }
                , { name: "patid",        value: patid }
                , { name: "orpdoctypeid", value: "2" }
                , { name: "clientid",     value: clientid }
                , { name: "groupid",     value: groupid }
    ];

    // update the orpPracID and orpPracName fields in our JSON

    function updateServiceDataInRecs(event, ui) {

        var recKey = $(event.target).parents('tr').attr(_opts.RecsTableRowDataAttr);

        // get form data 
        
        _getFormData(recKey, ui.item.recData8, ui.item.recData12);

        // remove show details button if exists

        $(event.target).parents('tr').find('.' + _selectBoxColShowDetBtnClass).remove();

        _updateCurrentRecsForSpecificField(recKey, ui.item.id,    _opts.RecsTableColCtrlDataAttrValServiceClass);
        _updateCurrentRecsForSpecificField(recKey, ui.item.label, _opts.RecsTableColCtrlDataAttrValServiceClassName);
       // _updateCurrentRecsForSpecificField(recKey, ui.item.recData2, _opts.RecsTableColCtrlDataAttrValNotes);
        _updateCurrentRecsForSpecificField(recKey, ui.item.recData3, _opts.RecsTableColCtrlDataAttrValReqORPDoc);
        _updateCurrentRecsForSpecificField(recKey, ui.item.recData4, _opts.RecsTableColCtrlDataAttrValOrderID);
        _updateCurrentRecsForSpecificField(recKey, ui.item.recData5, _opts.RecsTableColCtrlDataAttrValOrderName);
        _updateCurrentRecsForSpecificField(recKey, ui.item.recData6, _opts.RecsTableColCtrlDataAttrValReqStartTime);
        _updateCurrentRecsForSpecificField(recKey, ui.item.recData7, _opts.RecsTableColCtrlDataAttrValReqEndTime);
        _updateCurrentRecsForSpecificField(recKey, ui.item.recData8, _opts.RecsTableColCtrlDataAttrValSvcNameID);

        _updateCurrentRecsForSpecificField(recKey, ui.item.recData9, _opts.RecsTableColCtrlDataAttrValFormQuestionsJSONForOrder);
        _updateCurrentRecsForSpecificField(recKey, '{}', _opts.RecsTableColCtrlDataAttrValFormAnswersJSONForOrder);
        
        if (ui.item.recData10) {
            _setSvcJournalColSelectValueAndUpdateUI(recKey, _opts.RecsTableColCtrlDataAttrValPlanType, ui.item.recData10);
        }

        
        // update the notes
        //$(event.target).parents('tr').find('[' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValNotes + '"]').val(ui.item.recData2);

        // if ORP document required

        if (RecObj[_opts.RecsTableColCtrlDataAttrValReqORPDoc] == true) {
            // attach service details button to this row so they can always go to the questions
            let $svcDetBut = _generateButtonElem("Show Details", _selectBoxColShowDetBtnClass, function () { _showOrpSelCont(recKey); });
            $(event.target).parents('tr').find('[' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValServiceClass + '"]').parent().append($svcDetBut);

            // show dialog if required
            if (!(RecObj[_opts.RecsTableColCtrlDataAttrValOrderID] && RecObj[_opts.RecsTableColCtrlDataAttrValOrderID] != "0") && !RecObj[_opts.RecsTableColCtrlDataAttrValOrderName]) {
                _showOrpSelCont(recKey);
            }

        }

        // remove start time (it will be appended later if needed)

        var tdRow = $(event.target).parents('tr');
        var tdStartTime = tdRow.find('.' + _startTimeColClass);
        var tdEndTime   = tdRow.find('.' + _endTimeColClass);

        // reset start and end time

        tdStartTime.empty();
        tdEndTime.empty();
        _updateCurrentRecsForSpecificField(recKey, '', _opts.RecsTableColCtrlDataAttrValStartTime);
        _updateCurrentRecsForSpecificField(recKey, '', _opts.RecsTableColCtrlDataAttrValEndTime);

        // if start time required

        if (RecObj[_opts.RecsTableColCtrlDataAttrValReqStartTime] == true) {
            tdStartTime.append('<input ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValStartTime + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValStartTime] + '" type="time" />');
        }

        // if end time required

        if (RecObj[_opts.RecsTableColCtrlDataAttrValReqEndTime] == true) {
            tdEndTime.append('<input ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValEndTime + ' value="' + RecObj[_opts.RecsTableColCtrlDataAttrValEndTime] + '" type="time" />');
        }
    }

    $($obj).spedmonSelectBox({
          dataParmType: 'DOM'
        , selectAll: true
        , delay: 600
        , showSelectControlLabel: false
        , selectControlLabel: 'Select : '
        , selectType: 1
        , displayInline: false
        , singleSelectName: ''
        , singleSelectValue: ''
        , singleSelectClearAfterSelection: false
        , multiSelect: false
        , multiSelectShowOK: true
        , multiSelectListTitle: 'Selected Journal Events'
        , multiSelectNames: ''
        , multiSelectValues: ''
        , multiSelectLoad: false
        , multiSelectContextLabels: 'null'
        , multiSelectDisplayContextLabels: false
        , multiSelectOnAdd: function (selObj) { }
        , multiSelectOnRemove: function (selObj) { }
        , onSelect: updateServiceDataInRecs
        , ajaxopts: { url: reqUrl, data: '', namevalues: reqData }
    });
    
    // set pre-chosen values if they exist
    if (RecObj[_opts.RecsTableColCtrlDataAttrValServiceClass] && RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassName]) {
        $('#' + RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassInput]).val(RecObj[_opts.RecsTableColCtrlDataAttrValServiceClass]);
        $('#' + RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassNameInput]).val(RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassName]);
    }
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
    let notesID = _createNotesID($(_opts.patIDSel).val());
    let $_row = $(_createRecsTableRowCommonMkup(RecObj,RecKey));

    // append save and delete icon only if record is editable
    if (RecObj[_opts.RecsTableColCtrlDataAttrValCanEdit] == true) {
        let $_tdRemove = $('<td></td>');
        let $_butRem = $('<i ' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValRemove + '" class="fa fa-trash-alt" title="Remove Record"></i>');
        $($_tdRemove).append($_butRem);
        $($_row).append($_tdRemove);

        let $_tdSave = $('<td></td>');
        let $_butSave = $('<i ' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValSave + '" class="fa fa-save'
            + ((RecObj[_opts.RecsTableColCtrlDataAttrValHasUnsavedChanges]) ? ' ' + _pulsateAnimationClass : '')
            + '" title="Save Record"></i>');
        $($_tdSave).append($_butSave);
        $($_row).append($_tdSave);

        let $_tdDup = $('<td></td>');
        let $_butDup = $('<i ' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValDup + '" class="fa fa-copy" title="Duplicate Record"></i>');
        $($_tdDup).append($_butDup);
        $($_row).append($_tdDup);
    }
    else {
        $($_row).append($('<td colspan="3" class="font-weight-bold">' + RecObj[_opts.RecsTableColCtrlDataAttrValPracName] + '</td>'));
    }
    
    $($_row).append(_createRecTableColsCommonMkup (RecObj, notesID));

    if (RecObj[_opts.RecsTableColCtrlDataAttrValDuppedRecKey]) {
        // if duplicate, we insert it after the record being duplicated
        $_row.insertAfter($('tbody tr[' + _opts.RecsTableRowDataAttr + '='
            + RecObj[_opts.RecsTableColCtrlDataAttrValDuppedRecKey] + ']'));

        // we only want to insertAfter once, so we reset the duppedKey
        RecObj[_opts.RecsTableColCtrlDataAttrValDuppedRecKey] = '';
    }
    else {
        $(_opts.SvcRecsTableBodySelector).append($_row);
    }

    // link notes
    var tkn = _opts.tkn;
    var noteFld = $('#' + notesID);
    var patID   = $(_opts.patIDSel).val();  // Get patient id value
    var patIDFn = function () { return patID; };              // Setup function to return patient id value

    var formBuilderFn = function ($div) {
        $($div).html('');
        
        // custom form builder questions from standard orp doc name or service name

        renderFormInDiv($div
            , RecObj[_opts.RecsTableColCtrlDataAttrValFormQuestionsJSON]
            , RecObj[_opts.RecsTableColCtrlDataAttrValFormAnswersJSON]
            , $(_opts.clientIDSel).val()
            , $(_opts.patIDSel).val()
            , $(_opts.pracGroupID).val()
            , function (fbNoteAnswersJSON) { _updateCurrentRecsForSpecificField(RecKey, fbNoteAnswersJSON, _opts.RecsTableColCtrlDataAttrValFormAnswersJSON); });
        
        // custom questions from order 

        renderFormInDiv($div
            , RecObj[_opts.RecsTableColCtrlDataAttrValFormQuestionsJSONForOrder]
            , RecObj[_opts.RecsTableColCtrlDataAttrValFormAnswersJSONForOrder]
            , $(_opts.clientIDSel).val()
            , $(_opts.patIDSel).val()
            , $(_opts.pracGroupID).val()
            , function (fbNoteAnswersJSON) { _updateCurrentRecsForSpecificField(RecKey, fbNoteAnswersJSON, _opts.RecsTableColCtrlDataAttrValFormAnswersJSONForOrder); });

        var $additionalNotesLbl = $('<p class="m-0">Additional Notes</p>');
        $($div).append($additionalNotesLbl);
    };

    $.when(
        noteFld.notelibrary({
            displayMode: ""
            , useMenu: true
            , useLabelInOpenButton: false
            , sel_tmp_enabled: false
            , tkn: tkn
            , noteforpatidfn: (patIDFn)
            , additionalcontentfn: (formBuilderFn)
        })
    ).then(
        noteFld.val(RecObj[_opts.RecsTableColCtrlDataAttrValNotes])
    );

    // create services SelectBox
    _getServiceSelection($($_row).find('[' + _opts.RecsTableColCtrlDataAttr + '= "' + _opts.RecsTableColCtrlDataAttrValServiceClass + '"]'), RecKey);

    // include the View Details button if the row has one
    if (RecObj[_opts.RecsTableColCtrlDataAttrValReqORPDoc] == true) {
        let $servicesSelCell = $_row.find('[' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValServiceClass + '"]').parent();

        $servicesSelCell.append(_generateButtonElem("Show Details", _selectBoxColShowDetBtnClass, function () { _showOrpSelCont(RecKey); }));
    } 

}

/***************************************************************************
 * _generateButtonElem */
/**
* generates button for dialog
***************************************************************************/
function _generateButtonElem(label, classes, callbackFunc) {
    let $butElem = $('<i class="' + classes + ' fas fa-edit" title="' + label + '"></i>');
    $butElem.on("click", callbackFunc);

    return $butElem;
}

/***************************************************************************
 * _drawRecsTableBodyRows */
/**
 * 
 ***************************************************************************/

function _drawRecsTableBodyRows() {
  _currentRecsToTA();
    
  $(_opts.SvcRecsTableBodySelector).children().remove();

  _Recs.forEach(function(_RecObj, _RecKey) {
      _drawRecsTableBodyRow(_RecObj, _RecKey);
  });
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
 * _saveRecToDatabase */
/**
 * sends ajax request to save a record to the database
 ***************************************************************************/

function _saveRecToDatabase (RecKey) {
    var RecObj = _Recs.get(RecKey);
    var saveType = RecObj[_opts.RecsTableColCtrlDataAttrValSaveType];
    var tkn = _opts.tkn;
    var cltid = $(_opts.clientIDSel).val();
    var patid = $(_opts.patIDSel).val();
    var pracid = $(_opts.pracIDSel).val();
    var journalid = $(_opts.journalIDSel).val();
    var recid = RecObj[_opts.RecsTableColCtrlDataAttrValID];

    /****** set up ajax url ***********/

    var reqUrl = "servicejournalsjournalentries.asmx/save?tkn=" + tkn;
    var reqData = JSON.stringify({
                      "clientid":                         cltid                                                
                    , "pracid":                           pracid                                               
                    , "patid":                            patid                                                
                    , "iep":                              RecObj[_opts.RecsTableColCtrlDataAttrValPlanType]    
                    , "journalid":                        journalid                                            
                    , "eventid":                          RecObj[_opts.RecsTableColCtrlDataAttrValServiceClass]
                    , "starttime":                        RecObj[_opts.RecsTableColCtrlDataAttrValStartTime]   
                    , "endtime":                          RecObj[_opts.RecsTableColCtrlDataAttrValEndTime]     
                    , "orpDocID":                         RecObj[_opts.RecsTableColCtrlDataAttrValOrderID]     
                    , "notes":                            RecObj[_opts.RecsTableColCtrlDataAttrValNotes]       
                    , "svcNotesFormBuilderQuestionsJSON": RecObj[_opts.RecsTableColCtrlDataAttrValFormQuestionsJSON]       
                    , "svcNotesFormBuilderAnswersJSON":   RecObj[_opts.RecsTableColCtrlDataAttrValFormAnswersJSON]       
                    , "noteCriteriaQuestionsJSON":        RecObj[_opts.RecsTableColCtrlDataAttrValFormQuestionsJSONForOrder]       
                    , "noteCriteriaAnswersJSON":          RecObj[_opts.RecsTableColCtrlDataAttrValFormAnswersJSONForOrder]       
                    , "editDelReason":                    ''                                                    
                    , "validaterec":                      0                                                   
                    , "savetype":                         saveType                                             
                    , "recid":                            recid                                                
                  });

    // success callback for ajax
    var fnProcRespSuccess = function (rd) {
        if (rd.status == 0) {
            if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {
                RecObj[_opts.RecsTableColCtrlDataAttrValID] = rd.recordID;
            }

            // indicate success
            $('body').mbaHighlight({ color: "#bdffc7", duration: 500 });

            // this record now becomes an EXISTING record (if not already an existing one)
            _updateCurrentRecsForSpecificField(RecKey, $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT, _opts.RecsTableColCtrlDataAttrValSaveType);
            _updateCurrentRecsForSpecificField(RecKey, false, _opts.RecsTableColCtrlDataAttrValHasUnsavedChanges);

            _sortCurrentRecsByStartTime();
            _drawRecsTableBodyRows();
        }
    };

    // error callback for ajax
    var fnProcRespError = function () {
        $.spedmonWebUI.dialogMessage('ERROR', "Something went wrong when saving record!", null, 400, 200, null, null, null);
        return;
    }; 
    
    // response callback for ajax
    var fnProcResp = function (rd) {
        if (rd.status != 0) $.spedmonWebUI.dialogMessage('Status', rd.message, null, 400, 200, null, null, null);
    };

    $.spedmonWebUI.ajax(null
        , reqUrl
        , reqData
        , 'json'
        , null
        , fnProcResp
        , fnProcRespError
        , null
        , 0
        , fnProcRespSuccess
        , null
        , null);
}

/***************************************************************************
 * _removeRecFromDatabase */
/**
 * sends ajax request to delete a record from the database
 ***************************************************************************/

function _removeRecFromDatabase (RecObj) {
    var tkn = _opts.tkn;
    var pracid = $(_opts.pracIDSel).val();
    var journalid = $(_opts.journalIDSel).val();
    var recid = RecObj[_opts.RecsTableColCtrlDataAttrValID];

    /****** set up ajax url ***********/

    var reqUrl = "servicejournalsjournalentries.asmx/delete?tkn=" + tkn;
    var reqData = '{'
                + '"journalid":"'      + journalid + '"'
                + ',"pracid":"'        + pracid    + '"'
				+ ',"recid":"'         + recid     + '"}';

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
        // if ending accompany and monitoring, display the attest statements
        if (RecObj[_opts.RecsTableColCtrlDataAttrValServiceClass] == 3) {
            $.spedmonWebUI.dialogProceedOrGoBack(
                "Verify Expected Outcomes"
                , '<p>I have documented all services and events, and certify that all expected outcomes were met for remaining units of time.</p><br/><p>By clicking <strong>Proceed</strong>, SpEdCare will populate the remaining units of service, not covered by documented events with the message <strong>"All defined and expected outcomes were met"</strong>.</p><br/><p>By clicking <strong>Go Back</strong>, you will be returned to the procedure log, where you can add further services and events. When you are finished, you will need to restart the Ended Accompanying and Monitoring process.</p>'
                , 400
                , 400
                , function () { _saveRecToDatabase(_rowAction.RecKey); }
                , function () { /*doNewEntry();*/ }
            );
        }
        else {
            _saveRecToDatabase(_rowAction.RecKey);
        }
    }

    // duplicate record if needed
    else if (_rowAction.doWhat == _opts.RecsTableColCtrlDataAttrValDup) {
        if (RecObj[_opts.RecsTableColCtrlDataAttrValServiceClass] != 2
                && RecObj[_opts.RecsTableColCtrlDataAttrValServiceClass] != 3)
        {
            _dupRecRow(_rowAction.RecKey, _rowAction.whatRow);
        }
        else {
            // user should not be able to duplicate Accompany & Monitoring
            $.spedmonWebUI.dialogMessage('WARNING', "Record cannot be duplicated for the selected service.", null, 400, 200, null, null, null);
        }
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

/***************************************************************************
 * _dupRecRow */
/**
 * duplicates a _Recs object 
 ***************************************************************************/

var _dupRecRow  = function (RecKey) {
  let _newRecObj = JSON.parse(JSON.stringify(_Recs.get(RecKey))); //https://www.samanthaming.com/tidbits/70-3-ways-to-clone-objects/
  // set append type
  _newRecObj[_opts.RecsTableColCtrlDataAttrValDuppedRecKey] = RecKey;

  // empty the start and end times
  _newRecObj[_opts.RecsTableColCtrlDataAttrValStartTime] = '';
  _newRecObj[_opts.RecsTableColCtrlDataAttrValEndTime] = '';
  _newRecObj[_opts.RecsTableColCtrlDataAttrValHasUnsavedChanges] = true;

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

var _addRec  = function (dos) {
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
   _opts.RecsTableRowDataAttr                                 = 'data-Rec-id';
   _opts.RecsTableColCtrlDataAttr                             = 'data-Rec-ctrl';
   _opts.RecsTableColCtrlDataAttrValID                        = 'id';
   _opts.RecsTableColCtrlDataAttrValRemove                    = 'remove';
   _opts.RecsTableColCtrlDataAttrValSave                      = 'save';
   _opts.RecsTableColCtrlDataAttrValSaveType                  = 'saveType';
   _opts.RecsTableColCtrlDataAttrValDup                       = 'duplicate';
   _opts.RecsTableColCtrlDataAttrValDuppedRecKey              = 'duppedRecKey';
                                                              
   _opts.RecsTableColCtrlDataAttrValServiceClass              = 'eventID';
   _opts.RecsTableColCtrlDataAttrValServiceClassInput         = 'eventIDInput';
   _opts.RecsTableColCtrlDataAttrValServiceClassName          = 'eventLabel';
   _opts.RecsTableColCtrlDataAttrValServiceClassNameInput     = 'eventLabelInput';
   _opts.RecsTableColCtrlDataAttrValPlanType                  = 'iep';
   _opts.RecsTableColCtrlDataAttrValStartTime                 = 'startTime';
   _opts.RecsTableColCtrlDataAttrValEndTime                   = 'endTime';
   _opts.RecsTableColCtrlDataAttrValNotes                     = 'notes';
   _opts.RecsTableColCtrlDataAttrValPracID                    = 'pracID';
   _opts.RecsTableColCtrlDataAttrValPracName                  = 'pracName';
   _opts.RecsTableColCtrlDataAttrValCanEdit                   = 'canEdit';
   _opts.RecsTableColCtrlDataAttrValReqORPDoc                 = 'reqORPDoc';
   _opts.RecsTableColCtrlDataAttrValOrderID                   = 'orpDocID';	
   _opts.RecsTableColCtrlDataAttrValOrderName                 = 'orpDocName';
   _opts.RecsTableColCtrlDataAttrValReqStartTime              = 'reqStartTime';
   _opts.RecsTableColCtrlDataAttrValReqEndTime                = 'reqEndTime';
   _opts.RecsTableColCtrlDataAttrValHasUnsavedChanges         = 'hasUnsavedChanges';
   _opts.RecsTableColCtrlDataAttrValSvcNameID                 = 'svcNameID';
   _opts.RecsTableColCtrlDataAttrValFormQuestionsJSON         = 'entryNotesFormBuilderQuestionsJSON';
   _opts.RecsTableColCtrlDataAttrValFormAnswersJSON           = 'entryNotesFormBuilderAnswersJSON';
   _opts.RecsTableColCtrlDataAttrValFormQuestionsJSONForOrder = 'noteCriteriaQuestionsJSON';
   _opts.RecsTableColCtrlDataAttrValFormAnswersJSONForOrder   = 'noteCriteriaAnswersJSON';
   
   _opts.RecsTableColButsSubSelector = 'tr td i';
   _opts.RecsTableColInputsSubSelector = 'tr td input, tr td select, tr td textarea';

   // callback for inputs only
   $(_opts.SvcRecsTableBodySelector).on( 'change'
                                       , _opts.RecsTableColInputsSubSelector
	                                   , function(e){ _handleRecsTableBodyRowActionForInput(e); });
   //callback for buttons only
   $(_opts.SvcRecsTableBodySelector).on( 'click'
                                       , _opts.RecsTableColButsSubSelector
	                                   , function(e){ _handleRecsTableBodyRowActionForButton(e); });   

   // clear the table (for the case where the user clicks the back button to go to this screen)
   $(_opts.SvcRecsTableBodySelector).children().remove();

  // hide ORP container
  $(_opts.orpDocContSel).hide();

   _Recs  = new Map();

   let _RecsJSON = $(_opts.SvcRecsTextAreaSelector).val();
   
    if (_RecsJSON && _RecsJSON != '[]') {
        let _RecObjs = JSON.parse(_RecsJSON);

        $.each(_RecObjs, function (_idx, _RecObj) {

            // set defaults if inputs not filled
            _RecObj[_opts.RecsTableColCtrlDataAttrValSaveType] = $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT;

            if (_RecObj[_opts.RecsTableColCtrlDataAttrValPracID] != $(_opts.pracIDSel).val())
                _RecObj[_opts.RecsTableColCtrlDataAttrValCanEdit] = false;
            else
                _RecObj[_opts.RecsTableColCtrlDataAttrValCanEdit] = true;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValServiceClass]) {
                _RecObj[_opts.RecsTableColCtrlDataAttrValServiceClass] = null;
                _RecObj[_opts.RecsTableColCtrlDataAttrValServiceClassName] = null;
            }

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValPlanType])
                _RecObj[_opts.RecsTableColCtrlDataAttrValEmail] = null;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValStartTime])
                _RecObj[_opts.RecsTableColCtrlDataAttrValStartTime] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValEndTime])
                _RecObj[_opts.RecsTableColCtrlDataAttrValEndTime] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValNotes])
                _RecObj[_opts.RecsTableColCtrlDataAttrValNotes] = '';
            
            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValReqORPDoc])
                _RecObj[_opts.RecsTableColCtrlDataAttrValReqORPDoc] = null;    
            
            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValReqStartTime])
                _RecObj[_opts.RecsTableColCtrlDataAttrValReqStartTime] = null;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValReqEndTime])
                _RecObj[_opts.RecsTableColCtrlDataAttrValReqEndTime] = null;

            _RecObj[_opts.RecsTableColCtrlDataAttrValHasUnsavedChanges] = false;

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValFormQuestionsJSONForOrder])
                _RecObj[_opts.RecsTableColCtrlDataAttrValFormQuestionsJSONForOrder] = '{}';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValFormAnswersJSONForOrder])
                _RecObj[_opts.RecsTableColCtrlDataAttrValFormAnswersJSONForOrder] = '{}';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValFormQuestionsJSON])
                _RecObj[_opts.RecsTableColCtrlDataAttrValFormQuestionsJSON] = '{}';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValFormAnswersJSON])
                _RecObj[_opts.RecsTableColCtrlDataAttrValFormAnswersJSON] = '{}';

            _addRecToRecs(_RecObj);
        });
    }

    _sortCurrentRecsByStartTime();
    _drawRecsTableBodyRows();

    _initMode = false;
 };

/****************************************************************************/

return {
    init: _init
  , addRec : _addRec
};

})(jQuery);
