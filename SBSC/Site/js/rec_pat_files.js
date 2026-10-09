var SpEdCare = (SpEdCare || {});

SpEdCare.recPatFile = (function ($) {

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
  $(_opts.RecsFileTextAreaSelector).val(RecsJSON);
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

    return '<td><div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValUploadDate + '>'  + new Date(RecObj[_opts.RecsTableColCtrlDataAttrValUploadDate].match(/\d+/)[0] * 1).toLocaleDateString('en-US')  + '</div></td>'
         + '<td><div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValTypeOfFile  + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValTypeOfFile]  + '</div></td>'
         + '<td><div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValFileName    + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValFileName]    + '</div></td>'
         + '<td><div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValUploadedBy  + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValUploadedBy]  + '</div></td>'
         + '<td><div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValDescription + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValDescription] + '</div></td>';
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
 * _drawRecsTableBodyRow */
/**
 * 
 ***************************************************************************/

function _drawRecsTableBodyRow (RecObj, RecKey) {	
    let $_row = $(_createRecsTableRowCommonMkup(RecObj,RecKey));
      
    let $_tdPrint = $('<td></td>');  
    let $_butPrint = $('<i ' + _opts.RecsTableColCtrlDataAttr + '="' + _opts.RecsTableColCtrlDataAttrValPrint + '" class="fa fa-download" title="Download File"></i>');
    $($_tdPrint).append($_butPrint);
    $($_row).append($_tdPrint);
    
    $($_row).append(_createRecTableColsCommonMkup (RecObj));

    if (_initMode) {
        // if called in init, we want to preload in the correct order so we use append()
        $(_opts.RecsFileTableBodySelector).append($_row);
    }
    else {
        // otherwise, we use prepend to generate a row on the top of the other records
        $(_opts.RecsFileTableBodySelector).prepend($_row);
    }

}

/***************************************************************************
 * _drawRecsTableBodyRows */
/**
 * 
 ***************************************************************************/

function _drawRecsTableBodyRows() {
  _currentRecsToTA();

  $(_opts.RecsFileTableBodySelector).children().remove();

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
 * _handleRecsTableBodyRowActionForButton */
/**
 * 
 ***************************************************************************/

function _handleRecsTableBodyRowActionForButton (e) {
    let _rowAction = _identifyRecsTableBodyRowAction(e, 'i');
    var RecObj = _Recs.get(_rowAction.RecKey);

    // print file if needed
    if (_rowAction.doWhat == _opts.RecsTableColCtrlDataAttrValPrint) {
        var recID = RecObj[_opts.RecsTableColCtrlDataAttrValID];
        var url = "storedfiledownload.ashx";

        $.spedmonWebUI.fileDownload(url, 'sf-fid', recID)
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
   _opts.RecsTableRowDataAttr                   = 'data-Rec-id';
   _opts.RecsTableColCtrlDataAttr               = 'data-Rec-ctrl';
   _opts.RecsTableColCtrlDataAttrValID          = 'id';
   _opts.RecsTableColCtrlDataAttrValPrint       = 'print';

   _opts.RecsTableColCtrlDataAttrValUploadDate  = 'fileUploadOn';
   _opts.RecsTableColCtrlDataAttrValTypeOfFile  = 'fileClassName';
   _opts.RecsTableColCtrlDataAttrValFileName    = 'label';
   _opts.RecsTableColCtrlDataAttrValUploadedBy  = 'fileUploadByEmail';
   _opts.RecsTableColCtrlDataAttrValDescription = 'description';
   
   _opts.RecsTableColButsSubSelector = 'tr td i';

   //callback for buttons only
   $(_opts.RecsFileTableBodySelector).on( 'click'
                                       , _opts.RecsTableColButsSubSelector
	                                   , function(e){ _handleRecsTableBodyRowActionForButton(e); });   

   // clear the table (for the case where the user clicks the back button to go to this screen)
   $(_opts.RecsFileTableBodySelector).children().remove();

   _Recs  = new Map();

   let _RecsJSON = $(_opts.RecsFileTextAreaSelector).val();
    
    if (_RecsJSON && _RecsJSON != '[]') {
        let _RecObjs = JSON.parse(_RecsJSON);
        
        $.each(_RecObjs, function (_idx, _RecObj) {

            // set defaults if inputs not filled

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValUploadDate])
                _RecObj[_opts.RecsTableColCtrlDataAttrValUploadDate] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValTypeOfFile])
                _RecObj[_opts.RecsTableColCtrlDataAttrValTypeOfFile] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValFileName])
                _RecObj[_opts.RecsTableColCtrlDataAttrValFileName] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValUploadedBy])
                _RecObj[_opts.RecsTableColCtrlDataAttrValUploadedBy] = '';

            if (!_RecObj[_opts.RecsTableColCtrlDataAttrValDescription])
                _RecObj[_opts.RecsTableColCtrlDataAttrValDescription] = '';

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
