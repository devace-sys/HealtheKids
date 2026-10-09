var SpEdCare = (SpEdCare || {});

SpEdCare.recPatService = (function ($) {

'use strict';

/*#################################################################################################
  #
  #                                  Global Data Structures
  #
  #################################################################################################*/

var _opts = {};
var _Recs  = new Map();
var _initMode         = true;

const _viewDetsButClass = 'viewDetsBut';
const _serviceTabID = 'tab-services';
const _dialogDivIDPostfix = "FormBuilderRenderModalCont";
const _formQuestionsJSONPostfix = "FormBuilderQuestionsJSON";
var _salt = 0;

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
  $(_opts.RecsServiceTextAreaSelector).val(RecsJSON);
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

    return '<td><div ' + _opts.RecsTableColCtrlDataAttr   + '=' + _opts.RecsTableColCtrlDataAttrValServiceName           + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValServiceName]        + '</div></td>'
        + '<td><button ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValServiceDescriptionBut + ' class="' + _viewDetsButClass + ' ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" type="button" title="View Details" role="button" aria-disabled="false"><span class="ui-button-text">View Details</span></button></td>'
         + '<td><div ' + _opts.RecsTableColCtrlDataAttr   + '=' + _opts.RecsTableColCtrlDataAttrValORPProfessional       + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValORPProfessional]    + '</div></td>'
         + '<td><div ' + _opts.RecsTableColCtrlDataAttr   + '=' + _opts.RecsTableColCtrlDataAttrValEffectiveDate         + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValEffectiveDate]      + '</div></td>'
         + '<td><div ' + _opts.RecsTableColCtrlDataAttr   + '=' + _opts.RecsTableColCtrlDataAttrValStatus                + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValStatus]             + '</div></td>';
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
 * _renderSvcDescriptionDialog */
/**
 * 
 ***************************************************************************/

function _renderSvcDescriptionDialog(RecObj) {
    var $divSvcDescription = '';

    if (RecObj[_opts.RecsTableColCtrlDataAttrValFormBuilderQuestions]) {
        var formBuilderName = 'svcDescription' + _salt++;
        var formBuilderQuestionsID = formBuilderName + _formQuestionsJSONPostfix;
        var formBuilderModalContID = formBuilderName + _dialogDivIDPostfix;

        $divSvcDescription = $('<div id="' + formBuilderModalContID + '" style="display:none;"></div>');

        // set up hidden textareas for formBuilder questions/answers
        var $hiddenFormQuestionsJSON = $('<textarea id="' + formBuilderQuestionsID + '" name="' + formBuilderQuestionsID + '" title="' + formBuilderQuestionsID + '" style="display: none;">' + RecObj[_opts.RecsTableColCtrlDataAttrValFormBuilderQuestions] + '</textarea>');
        var $hiddenFormAnswersJSON = $('<textarea id="' + formBuilderName + '" name="' + formBuilderName + '" title="' + formBuilderName   + '" style="display: none;">' + RecObj[_opts.RecsTableColCtrlDataAttrValFormBuilderAnswers]   + '</textarea>');
        
        $($divSvcDescription).append($hiddenFormQuestionsJSON);
        $($divSvcDescription).append($hiddenFormAnswersJSON);
        
        $divSvcDescription.dialog(
            {
                width: 1200
                , height: $(window).height()
                , title: "Service Description"
                , show: {
                    effect: 'slide',
                    complete: function () {
                        spedmonRenderFormBuilderFromJSON(formBuilderName, false, false);
                    }
                }
                , close: function () {
                    $('#' + formBuilderModalContID).remove();
                }
                , hide: {
                    effect: 'slide'
                    , direction: 'left'
                }
            }

        );
    }
    else {
        $divSvcDescription = $('<textarea readonly class="w-100" style="margin-bottom: 4em; background-color: #9dc8cc30;"></textarea>');
        var svcDescription = (RecObj[_opts.RecsTableColCtrlDataAttrValServiceDescription]) ?
            RecObj[_opts.RecsTableColCtrlDataAttrValServiceDescription] :
            "No description for the selected service...";

        $($divSvcDescription).append(svcDescription);

        $divSvcDescription.dialog(
            {
                width: 1200
                , height: $(window).height()
                , title: "Service Description"
                , show: {
                    effect: 'slide',
                    complete: function () { }
                }
                , hide: {
                    effect: 'slide'
                    , direction: 'left'
                }
            }

        );
    }
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

    let $_tdAuth = $('<td></td>');
    let $_butAuth = $('<i ' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValAuthorize + '" class="fa fa-user-md" title="Request Authorization"></i>');
    $($_tdAuth).append($_butAuth);
    $($_row).append($_tdAuth);

    let $_tdEdit = $('<td></td>');
    let $_butEdit = $('<i ' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValEdit + '" class="fa fa-pencil-alt" title="Edit Record"></i>');
    $($_tdEdit).append($_butEdit);
    $($_row).append($_tdEdit);
    
    $($_row).append(_createRecTableColsCommonMkup (RecObj));

    if (_initMode) {
        // if called in init, we want to preload in the correct order so we use append()
        $(_opts.RecsServiceTableBodySelector).append($_row);
    }
    else {
        // otherwise, we use prepend to generate a row on the top of the other records
        $(_opts.RecsServiceTableBodySelector).prepend($_row);
    }

    // set up callback functions
    let $svcDescriptionBut = $_row.find('[' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValServiceDescriptionBut + '"]').parent();
    $svcDescriptionBut.on("click", function () { _renderSvcDescriptionDialog(RecObj); });
}

/***************************************************************************
 * _drawRecsTableBodyRows */
/**
 * 
 ***************************************************************************/

function _drawRecsTableBodyRows() {
  _currentRecsToTA();

  $(_opts.RecsServiceTableBodySelector).children().remove();

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

    var reqUrl = "orp_documents.asmx/deleteOrderOrProfile?tkn=" + tkn;
    var reqData = "{'editDelReason':'" + '' + "','recid':'" + recid + "'}";

    // success callback for ajax
    var fnProcRespSuccess = function (rd) {};

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
 * _requestServiceAuthorization */
/**
 *
 ***************************************************************************/

function _requestServiceAuthorization (RecObj) {
    var tkn = _opts.tkn;
    var url = 'user_all_service_authorization_request_save.aspx';
    var refID = RecObj[_opts.RecsTableColCtrlDataAttrValReferenceID];
    var reqType = (RecObj[_opts.RecsTableColCtrlDataAttrValORPDocType] == '3') ? 2 : 1;

    var reqSvcAuthUrl = $.spedmonWebUI.createPrivateURL(tkn, url) 
                      + '&amd=uidbssub'
                      + '&referencedEntityID=' + refID
                      + '&svcAuthorizationRequestTypeID=' + reqType
    
    $.spedmonWebUI.openURL(reqSvcAuthUrl, 2);
   
};

/***************************************************************************
 * _openOrdersOrProfilesEditScreen */
/**
 *
 ***************************************************************************/

function _openOrdersOrProfilesEditScreen(RecObj) {
    var tkn = _opts.tkn;
    var url = 'user_all_order_prescription_save.aspx';
    var recID = RecObj[_opts.RecsTableColCtrlDataAttrValID];
    var cid = _opts.clientID;
    var pid = _opts.patID;
    var pracid = _opts.pracID;
    
    var reqUrl = $.spedmonWebUI.createPrivateURL(tkn, url)
        + '&recid=' + recID
        + '&savetype=2'
        + '&patclientid=' + cid
        + '&patpatientid=' + pid
        + '&patpracid=' + pracid
        + '&amd=uidbssub';
    
    var fnEntryTest = function () { return true; };
    var fnExitTest = function () { return true; };
    var fnResume = function () {
        refreshAndGoToTab(_serviceTabID);
        return true;
    };
    
    $.spedmonWebUI.popupThenResume(fnEntryTest
        , fnExitTest
        , fnResume
        , reqUrl
        , 'Popups Not Supported'
        , 'Please allow popups for SpEdCare'
        , 'Waiting'
        , 'Waiting for you  to finish with patient places');
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
        var onYes = function () {
            // delete record from the table
            _removeRecFromTable(_rowAction);

            // delete record from the database
            _removeRecFromDatabase(RecObj);
        };

        $.spedmonWebUI.dialogConfirm("Please Confirm", "Are you sure you want to remove this record? Once this record is deleted it cannot be undeleted!", onYes, function () { });
    }

    // send for authorization if needed
    else if (_rowAction.doWhat == _opts.RecsTableColCtrlDataAttrValAuthorize) {
        _requestServiceAuthorization(RecObj);
    }

    // go to order/profile edit screen if needed
    else if (_rowAction.doWhat == _opts.RecsTableColCtrlDataAttrValEdit) {
        _openOrdersOrProfilesEditScreen(RecObj);
    }
}

/*#################################################################################################
  #
  #                                  Public Methods
  #
  #################################################################################################*/

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
   _opts.RecsTableColCtrlDataAttrValAuthorize     = 'requestAuthorization';
   _opts.RecsTableColCtrlDataAttrValEdit          = 'edit';

   _opts.RecsTableColCtrlDataAttrValServiceName           = 'orpDocStdName';  
   _opts.RecsTableColCtrlDataAttrValServiceDescription    = 'svcDesc';  
   _opts.RecsTableColCtrlDataAttrValServiceDescriptionBut = 'svcDescBut';  
   _opts.RecsTableColCtrlDataAttrValORPProfessional       = 'orpPracName';  
   _opts.RecsTableColCtrlDataAttrValEffectiveDate         = 'lastApprovalEffectiveDateStr';  
   _opts.RecsTableColCtrlDataAttrValStatus                = 'lastApprovalExpirationMessage';  
   _opts.RecsTableColCtrlDataAttrValReferenceID           = 'refID';  
   _opts.RecsTableColCtrlDataAttrValORPDocType            = 'orpDocType';  
   _opts.RecsTableColCtrlDataAttrValFormBuilderAnswers    = 'formBuilderAnswersJSON';  
   _opts.RecsTableColCtrlDataAttrValFormBuilderQuestions  = 'formBuilderQuestionsJSON';  
   
   _opts.RecsTableColButsSubSelector = 'tr td i';

   //callback for buttons only
   $(_opts.RecsServiceTableBodySelector).on( 'click'
                                       , _opts.RecsTableColButsSubSelector
	                                   , function(e){ _handleRecsTableBodyRowActionForButton(e); });   

   // clear the table (for the case where the user clicks the back button to go to this screen)
   $(_opts.RecsServiceTableBodySelector).children().remove();

   _Recs  = new Map();

   let _RecsJSON = $(_opts.RecsServiceTextAreaSelector).val();

    if (_RecsJSON && _RecsJSON != '[]') {
        let _RecObjs = JSON.parse(_RecsJSON);

        $.each(_RecObjs, function (_idx, _RecObj) {

            // set defaults if inputs not filled

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValServiceName])
                _RecObj[_opts.RecsTableColCtrlDataAttrValServiceName] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValServiceDescription])
                _RecObj[_opts.RecsTableColCtrlDataAttrValServiceDescription] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValORPProfessional])
                _RecObj[_opts.RecsTableColCtrlDataAttrValORPProfessional] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValEffectiveDate])
                _RecObj[_opts.RecsTableColCtrlDataAttrValEffectiveDate] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValStatus])
                _RecObj[_opts.RecsTableColCtrlDataAttrValStatus] = '';

            _addRecToRecs(_RecObj);
        });
    }

    _drawRecsTableBodyRows();

    _initMode = false;
 };

/****************************************************************************/

return {
    init: _init
};

})(jQuery);
