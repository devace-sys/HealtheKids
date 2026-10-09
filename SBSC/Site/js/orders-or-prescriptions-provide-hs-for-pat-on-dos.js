; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.OrdersOrPrescriptionsProvideHSForPatOnDOSCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common, ServiceJournalRecentProcedureEntriesCommon
 */

MBA.OrdersOrPrescriptionsProvideHSForPatOnDOSCommon = (function ($)
{

    'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _THIS_NAME                                      = 'Orders Or Prescriptions Provide HS For Pat On DOS Common';
const _THIS_NS                                        = 'mba-orders-or-prescriptions-provide-hs-for-pat-on-dos'
const _JQ_DATA_NAME                                   = 'jq-'   + _THIS_NS;
const _DATA_ATTR_BASE                                 = 'data-' + _THIS_NS;
const _DATA_SVC_JOURNAL_EVENT_OR_ORDER_SELECTION_DATA = 'data-svc-journal-event-or-order-selection-data';
const _DATA_SVC_JOURNAL_ENTRY_NOTES_FB_ANSWERS_JSON   = 'data-svc-journal-entry-notes-fb-answers-json';

const _DATA_SVC_JOURNAL_ENTRY_NOTES_FB_ANSWERS_FOR_STD_ORP_DOC_SVC_NAME_JSON = 'data-svc-journal-entry-notes-fb-answers-for-std-orp-doc-svc-name-json'

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS = {
    PARM_NAME_CLIENT_ID:'clientid'
  , PARM_NAME_PRAC_ID:'pracid'
  , PARM_NAME_GROUP_ID:'groupid'
  , PARM_NAME_PAT_ID: 'patid'
  , PARM_NAME_DOS: 'dos'
  , PARM_NAME_PAT_ABSENT:'patabsent'
  , PARM_NAME_TERM:'term'
  , PARM_NAME_SAVE_TYPE:'savetype'
  , PARM_NAME_REC_ID: 'recid'
  , baseUrlView: ''
  , sessionTimeOutUrl: ''
  , baseUrlViewSelPatOrdersForDOS: ''
  , baseUrlSaveJournalJournal:''
  , baseUrlSaveJournalEntry: ''
  , tkn:''
};
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetMe
 * @private
 * @summary      Gets reference to original elemementid
 * @description  Gets reference to original elemementid
 * @param  {Object}  elem  Element reference
 */

let _fnGetMe = function (elementid) {
  return $('#' + elementid);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetDataObj
 * @private
 * @summary      Gets reference to data object
 * @description  Gets reference to the jQuery data object associated with this element
 * @param  {Object}  $me  Element reference
 */

let _fnGetDataObj = function ($me) {
  let dataObj = $($me).data(_JQ_DATA_NAME);
  if (!dataObj) throw new Error('An instance of ' + _THIS_NAME + ' is required');
  return dataObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSetDataObj
 * @private
 * @summary      Sets value of data object
 * @description  Sets value of data object
 * @param  {Object}  $me      Element reference
 * @param  {Object}  dataObj  Data obj for this lib
 */

let _fnSetDataObj = function ($me, dataObj) {
  $($me).data(_JQ_DATA_NAME, dataObj);
  return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSaveJournalJournal
 * @private
 * @summary      Saves new or returns recordID of existing (open) journal
 * @description  Saves new or returns recordID of existing (open) journal
 * @param  {Object}  $me        Element reference
 * @param  {String}  patAbsent  Valid flag value indicating if patient is absent
 * @param  {String}  saveType   Valid value for save type 
 * @returns Promise
 */

let _fnSaveJournalJournal = function ($me, patAbsent, saveType) {
    let dataObj    = _fnGetDataObj($me);
    let requestObj = {};
    requestObj[dataObj.opts.PARM_NAME_CLIENT_ID]  = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
    requestObj[dataObj.opts.PARM_NAME_PRAC_ID]    = $('#' + dataObj.opts.PARM_NAME_PRAC_ID).val();
    requestObj[dataObj.opts.PARM_NAME_PAT_ID]     = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
    requestObj[dataObj.opts.PARM_NAME_DOS]        = $('#' + dataObj.opts.PARM_NAME_DOS).val();
    requestObj[dataObj.opts.PARM_NAME_PAT_ABSENT] = patAbsent;
    requestObj[dataObj.opts.PARM_NAME_SAVE_TYPE]  = saveType;
    requestObj[dataObj.opts.PARM_NAME_REC_ID]     = '';
    var requestJSON = JSON.stringify(requestObj);
    return MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlSaveJournalJournal, requestJSON, dataObj.opts.sessionTimeOutUrl);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSaveJournalEntry
 * @private
 * @summary      Saves journal entry
 * @description  Saves journal entry
 * @param  {Object}  $me        Element reference
 * @param  {Object}  $row       Reference to data entry row
 * @returns Promise
 */

let _fnSaveJournalEntry = function ($me, $row, $inpStartTime, $inpEndTime, $taNotes, journalID, journalEntryID, saveType) {
    
  let dataObj = _fnGetDataObj($me);
  let selRec  = $($row).data(_DATA_SVC_JOURNAL_EVENT_OR_ORDER_SELECTION_DATA);

  let fbNoteAnswersForStdOrpDocSvcName = $($row).data(_DATA_SVC_JOURNAL_ENTRY_NOTES_FB_ANSWERS_FOR_STD_ORP_DOC_SVC_NAME_JSON);
  let fbNoteAnswersJSON                = $($row).data(_DATA_SVC_JOURNAL_ENTRY_NOTES_FB_ANSWERS_JSON);
  
  let entryStartTime    = $($inpStartTime).MBA_DataEntryBox('getValue');
  let entryEndTime      = $($inpEndTime).MBA_DataEntryBox('getValue');
  let entryNotes        = $($taNotes).MBA_DataEntryBox('getValue');

  let requestObj = {};

  requestObj[dataObj.opts.PARM_NAME_CLIENT_ID]   = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
  requestObj[dataObj.opts.PARM_NAME_PRAC_ID]     = $('#' + dataObj.opts.PARM_NAME_PRAC_ID).val();
  requestObj[dataObj.opts.PARM_NAME_GROUP_ID]    = $('#' + dataObj.opts.PARM_NAME_GROUP_ID).val();
  requestObj[dataObj.opts.PARM_NAME_PAT_ID]      = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
  requestObj['journalid']                        = journalID;
  requestObj['iep']                              = selRec.recData10;
  requestObj['eventid']                          = selRec.id;
  requestObj['starttime']                        = entryStartTime;
  requestObj['endtime']                          = entryEndTime;
  requestObj['orpDocID']                         = selRec.recData4;
  requestObj['notes']                            = entryNotes;
  requestObj['svcNotesFormBuilderQuestionsJSON'] = selRec.recData12;
  requestObj['svcNotesFormBuilderAnswersJSON']   = fbNoteAnswersForStdOrpDocSvcName;
  requestObj['noteCriteriaQuestionsJSON']        = selRec.recData9;
  requestObj['noteCriteriaAnswersJSON']          = fbNoteAnswersJSON; 
  requestObj['editDelReason']                    = '';
  requestObj['validaterec']                      = 'N';
  requestObj['savetype']                         = saveType;
  requestObj['recid']                            = journalEntryID;

  var requestJSON = JSON.stringify(requestObj);
  return MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlSaveJournalEntry, requestJSON, dataObj.opts.sessionTimeOutUrl)

};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnDoSaveNewJournalAndJournalEntryID
 * @private
 * @summary      Opens journal if neccessary and saves new journal entry
 * @description  Opens journal if neccessary and saves new journal entry
 * @param  {Object}  $me        Element reference
 * @param  {Object}  $row       Reference to data entry row
 * @returns Promise
 */

    let _fnDoSaveNewJournalAndJournalEntry = function ($me, $row, $butSave, $inpStartTime, $inpEndTime, $taNotes) {       
        let dataObj = _fnGetDataObj($me);
    _fnSaveJournalJournal($me, 'N', '1')
        .then(responseDataJournalSave => {            
            let journalID = responseDataJournalSave.rawData.recordID;
            _fnSaveJournalEntry($me, $row, $inpStartTime, $inpEndTime, $taNotes, journalID, '', '1')
                .then(responseDataJournalEntrySave => {
                    MBA.RestViewCommon.fnRefreshCurrentViewFromServer(dataObj.restViewCtrl);
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Journal Entry Saved', 'This procedure has been recorded in the daily service journal.', {});
                    $($butSave).hide(); /* TODO: Temporary.  Replace with disabling */
                })
                .catch(err => {                    
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Please check your entry', err.message, {});
                });
        })
        .catch(err => {
        });        
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateOrderRows
 * @private
 * @summary      Generates journal entry placeholder rows for all orders (orpDoc type 2).
 * @description  Generates journal entry placeholder rows for all orders (orpDoc type 2).
 * @param  {Object}  $me          Element reference
 * @param  {Object}  $selRecords  Output of viewSel call
 */

let _fnCreateOrderRows = function ($me, requestObj, selRecs) {

    if (!selRecs) {
        let $row     = $('<div class="row mt-1"></div>');
        let $col     = $('<div class="col-12"></div>');
        let $msg     = $('<p class="alert alert-info text-center">No orders or prescriptions to administer.</p>');

        $($col).append($msg);
        $($row).append($col);
        $($me).children().remove();
        $($me).append($row);
        return;
    }

    let dataObj = _fnGetDataObj($me);

    let clientID = requestObj[dataObj.opts.PARM_NAME_CLIENT_ID];
    let pracID   = requestObj[dataObj.opts.PARM_NAME_PRAC_ID];
    let groupID  = requestObj[dataObj.opts.PARM_NAME_GROUP_ID];
    let patID    = requestObj[dataObj.opts.PARM_NAME_PAT_ID];

    $.each(selRecs, function (idx, selRec) {
       
        let $row = $('<div class="row"></div>');
        $($row).data(_DATA_SVC_JOURNAL_EVENT_OR_ORDER_SELECTION_DATA, selRec);

        let $colStart  = $('<div class="col-1"></col>')
        let $colMid   = $('<div class="col-2"></col>')
        let $colEnd = $('<div class="col-9"></div>');
        
        let $butSave = $('<button style="display:inline-block;border:none;background:none" type="button"><i class="fa fa-save fa-2x"/></button>')
        $($colStart).append($butSave);


        let $label = $('<div class="text-left">' + selRec.label + '</div>');
        $($colMid).append($label);        

        let $inpStartTime = $('<input type="time" placeholder="Start Time" size="10"/>');
        $($colEnd).append($inpStartTime);

        let $inpEndTime = $('<input type="time" placeholder="End Time" size="10"/>');
        $($colEnd).append($inpEndTime);

        let $taNotes = $('<textarea placeholder="Notes"></textarea>');
        $($taNotes).attr('id', MBA.ComponentCommon.fnCreateNewUUID());

        $($colEnd).append($taNotes);


        let $butAuthStatus = $('<button style="display:inline-block;border:none;background:none;" type="button"/>');
        $($butAuthStatus).attr('title', selRec.context1);
        let $iconAuthStatus = $('<i class="fas fa-file-prescription fa-2x"></i>');

        if (selRec.recData11 == '0') $($iconAuthStatus).addClass('text-info');
        else if (selRec.recData11 == '1') $($iconAuthStatus).addClass('text-success');
        else if (selRec.recData11 == '2') $($iconAuthStatus).addClass('text-warning');
        else if (selRec.recData11 == '3') $($iconAuthStatus).addClass('text-danger');
        else addClass('text-danger');

        $($butAuthStatus).append($iconAuthStatus);
        $($colEnd).append($butAuthStatus);

        $($row).append($colStart);
        $($row).append($colMid);
        $($row).append($colEnd);
        $($me).prepend($row);

        $($inpStartTime).MBA_DataEntryBox({});
        $($inpEndTime).MBA_DataEntryBox({});

        $($row).data(_DATA_SVC_JOURNAL_ENTRY_NOTES_FB_ANSWERS_FOR_STD_ORP_DOC_SVC_NAME_JSON, '{}');
        $($row).data(_DATA_SVC_JOURNAL_ENTRY_NOTES_FB_ANSWERS_JSON,                          '{}');

        let _fnNoteLibGetPatID = function () { return patID; };

        let _fnNoteLibFormBuilder = function ($div) {

            $($div).html('');
            
            renderFormInDiv($div
                , selRec.recData12
                , ($($row).data(_DATA_SVC_JOURNAL_ENTRY_NOTES_FB_ANSWERS_FOR_STD_ORP_DOC_SVC_NAME_JSON))
                , clientID
                , patID
                , groupID
                , function (fbNoteAnswersJSON) {
                    $($row).data(_DATA_SVC_JOURNAL_ENTRY_NOTES_FB_ANSWERS_FOR_STD_ORP_DOC_SVC_NAME_JSON, fbNoteAnswersJSON);
                });

            renderFormInDiv($div
                , selRec.recData9
                , ($($row).data(_DATA_SVC_JOURNAL_ENTRY_NOTES_FB_ANSWERS_JSON))
                , clientID
                , patID
                , groupID
                , function (fbNoteAnswersJSON) {
                    $($row).data(_DATA_SVC_JOURNAL_ENTRY_NOTES_FB_ANSWERS_JSON, fbNoteAnswersJSON);                    
                });

            let $additionalNotesLbl = $('<p class="m-0">Additional Notes</p>');
            $($div).append($additionalNotesLbl);

        };

        $($taNotes).notelibrary({
              displayMode: ""
            , useMenu: true
            , useLabelInOpenButton: false
            , sel_tmp_enabled: false
            , tkn: dataObj.opts.tkn
            , noteforpatidfn: (_fnNoteLibGetPatID)
            , additionalcontentfn: (_fnNoteLibFormBuilder)
        });

        $($taNotes).siblings('button.mba-notelibrary').children('i.mba-notelibrary').addClass('fa-2x');

        $($taNotes).MBA_DataEntryBox({});

        $($butSave).on('click', function () {
            _fnDoSaveNewJournalAndJournalEntry($me, $row, $butSave, $inpStartTime, $inpEndTime, $taNotes);
        });


    });
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetOrdersAndCreateOrderRows
 * @private
 * @summary      Calls save viewSel routine that the journal uses for events but only returns orders
 * @description  Calls save viewSel routine that the journal uses for events but only returns orders
 * @param  {Object}  $me          Element reference
 
 */

let _fnGetOrdersAndCreateOrderRows = function ($me) {

    let dataObj = _fnGetDataObj($me);

    let requestObj = {};
    requestObj[dataObj.opts.PARM_NAME_CLIENT_ID] = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
    requestObj[dataObj.opts.PARM_NAME_PRAC_ID]   = $('#' + dataObj.opts.PARM_NAME_PRAC_ID).val();
    requestObj[dataObj.opts.PARM_NAME_GROUP_ID]  = $('#' + dataObj.opts.PARM_NAME_GROUP_ID).val();
    requestObj[dataObj.opts.PARM_NAME_PAT_ID]    = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
    requestObj[dataObj.opts.PARM_NAME_DOS]       = $('#' + dataObj.opts.PARM_NAME_DOS).val();
    requestObj[dataObj.opts.PARM_NAME_TERM]      = '';
    requestObj[dataObj.opts.PARM_NAME_REC_ID]    = '';
    
    let requestJSON = JSON.stringify(requestObj);
    
    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlViewSelPatOrdersForDOS, requestJSON, dataObj.opts.sessionTimeOutUrl)
        .then(responseData => {
            let selRecs = responseData.rawData.SelRecs;
            _fnCreateOrderRows($me, requestObj, selRecs);
        })
        .catch(err => {
        });
    };


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetup = function (elementid, optsIn) {

        let $me = _fnGetMe(elementid);

        /* See if we have created an instance of this plugin already for this element.  If so get out. */

        let dataObj = $($me).data(_JQ_DATA_NAME);
        if (dataObj) return;

        /* Define the data object we will save later */

        dataObj = {};

        /* Store reference to elem */

        dataObj.me = $me;

        /* Merge default options and options passed in. */

        let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);

        dataObj.opts = opts;

        /* Save our data object.  This will be used for option calls */

        $($me).data(_JQ_DATA_NAME, dataObj);

        $($me).addClass('container-fluid');

        _fnGetOrdersAndCreateOrderRows($me);        


        /* Create some instance specific ids based on elementid */
        let restViewContainerID = elementid + '-restview-container';
        let restViewID = elementid + '-restview';

        let $row = $('<div class="row mt-2"></div>');
        let $rowCol1 = $('<div class="col-12"></div>');

        let $restViewCtrlContainer = $('<details class="orders-or-prescriptions-provide-hs-for-pat-on-dos-prev-entries mt-1"></details>');
        $($restViewCtrlContainer).attr('id', restViewContainerID);

        let $historyToggle = $('<summary class="orders-or-prescriptions-provide-hs-for-pat-on-dos-prev-entries"><i class="fas fa-history fa-lg"></i> Recent Entries</summary>');
        let historyToggleID = elementid + '-summary';
        $($historyToggle).attr('id', historyToggleID);

        let $restViewCtrl = $('<div></div>');
        $($restViewCtrl).attr('id', restViewID);

        $($restViewCtrlContainer).append($historyToggle);
        $($restViewCtrlContainer).append($restViewCtrl);

        $($rowCol1).append($restViewCtrlContainer);
        $($row).append($rowCol1);

        $($me).append($row);

        /* Create rest view */

        opts.containerCtrlID = restViewContainerID;
        opts.enableRowControlRecAddNew = false;
        opts.enableScrollView = true;
        opts.scrollViewUseCustomHeight = true;
        opts.scrollViewCustomHeight = '15em';
        opts.autoHidePageControls = true;

        dataObj.restViewOpts = MBA.ServiceJournalRecentProcedureEntriesCommon.fnSetup(restViewID, opts);


        /* Save reference */

        dataObj.restViewCtrl = $restViewCtrl;
        
        /* Save opts */

        dataObj.opts = opts;

        /* Save our data object.  This will be used for option calls */

        $($me).data(_JQ_DATA_NAME, dataObj);

    }; /*_fnSetup */

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

return {
    fnSetup: _fnSetup
};

})(jQuery);