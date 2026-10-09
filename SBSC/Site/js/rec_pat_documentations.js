var SpEdCare = (SpEdCare || {});

SpEdCare.recPatDocumentation = (function ($) {

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
  $(_opts.RecsDocumentationTextAreaSelector).val(RecsJSON);
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

    return '<td><div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValDateOfService + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValDateOfService] + '</div></td>'
         + '<td><div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValServiceName + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValServiceName] + '</div></td>'
         + '<td><div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValORPDocName + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValORPDocName] + '</div></td>'
         + '<td><div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValPracName + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValPracName] + '</div></td>'
         + '<td><div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValStartTime + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValStartTime] + '</div></td>'
         + '<td><div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValSessionMinutes + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValSessionMinutes] + '</div></td>'
         + '<td><div ' + _opts.RecsTableColCtrlDataAttr + '=' + _opts.RecsTableColCtrlDataAttrValMiles + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValMiles] + '</div></td>'
         + '<td><div ' + _opts.RecsTableColCtrlDataAttrValNote + '=' + _opts.RecsTableColCtrlDataAttrValStatus + '>' + RecObj[_opts.RecsTableColCtrlDataAttrValNote] + '</div></td>';
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
    
    $($_row).append(_createRecTableColsCommonMkup (RecObj));

    if (_initMode) {
        // if called in init, we want to preload in the correct order so we use append()
        $(_opts.RecsDocumentationTableBodySelector).append($_row);
    }
    else {
        // otherwise, we use prepend to generate a row on the top of the other records
        $(_opts.RecsDocumentationTableBodySelector).prepend($_row);
    }

}

/***************************************************************************
 * _drawRecsTableBodyRows */
/**
 * 
 ***************************************************************************/

function _drawRecsTableBodyRows() {
  _currentRecsToTA();

  $(_opts.RecsDocumentationTableBodySelector).children().remove();

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
    //var tkn = _opts.tkn;
    //var recid = RecObj[_opts.RecsTableColCtrlDataAttrValID];
    //
    ///****** set up ajax url ***********/
    //
    //var reqUrl = "orp_documents.asmx/deleteOrderOrProfile?tkn=" + tkn;
    //var reqData = "{'editDelReason':'" + '' + "','recid':'" + recid + "'}";
    //
    //// success callback for ajax
    //var fnProcRespSuccess = function (rd) {};
    //
    //$.spedmonWebUI.ajax(null
    //    , reqUrl
    //    , reqData
    //    , 'json'
    //    , null
    //    , null
    //    , null
    //    , null
    //    , 0
    //    , fnProcRespSuccess
    //    , null
    //    , null);
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
    _opts.RecsTableRowDataAttr = 'data-Rec-id';
    _opts.RecsTableColCtrlDataAttr = 'data-Rec-ctrl';
    _opts.RecsTableColCtrlDataAttrValID = 'id';
    _opts.RecsTableColCtrlDataAttrValRemove = 'remove';
    _opts.RecsTableColCtrlDataAttrValEdit = 'edit';
    _opts.requestedmethod = 'view';
    _opts.pageOrder = 'dosStrYMD+desc';
    _opts.pagenumber = '1';

    _opts.RecsTableColCtrlDataAttrValDateOfService = 'dosStr';
    _opts.RecsTableColCtrlDataAttrValServiceName = 'svcName';
    _opts.RecsTableColCtrlDataAttrValORPDocName = 'orpDocLabel';
    _opts.RecsTableColCtrlDataAttrValPracName = 'pracName';
    _opts.RecsTableColCtrlDataAttrValStartTime = 'startTimeStr';
    _opts.RecsTableColCtrlDataAttrValSessionMinutes = 'numMins';
    _opts.RecsTableColCtrlDataAttrValMiles = 'tripsMiles';
    _opts.RecsTableColCtrlDataAttrValNote = 'notes';

    // clear the table (for the case where the user clicks the back button to go to this screen)
    $(_opts.RecsDocumentationTableBodySelector).children().remove();

    _Recs = new Map();

    // ajax call to get the svcRecs

    var url = _opts.svcRecsAPICallURL
        + '&clientid=' + _opts.clientID
        + '&patid=' + _opts.patID
        + '&requestedmethod=' + _opts.requestedmethod
        + '&pageOrder=' + _opts.pageOrder
        + '&pagenumber=' + _opts.pagenumber;

    $.ajax({
        url: url, success: function (result) {
            var data = result.data;

            if (data) {
                $.each(data, function (_idx, _RecObj) {

                    // set defaults if inputs not filled

                    if (!_RecObj[_opts.RecsTableColCtrlDataAttrValDateOfService])
                        _RecObj[_opts.RecsTableColCtrlDataAttrValDateOfService] = '';

                    if (!_RecObj[_opts.RecsTableColCtrlDataAttrValServiceName])
                        _RecObj[_opts.RecsTableColCtrlDataAttrValServiceName] = '';

                    if (!_RecObj[_opts.RecsTableColCtrlDataAttrValORPDocName])
                        _RecObj[_opts.RecsTableColCtrlDataAttrValORPDocName] = '';

                    if (!_RecObj[_opts.RecsTableColCtrlDataAttrValPracName])
                        _RecObj[_opts.RecsTableColCtrlDataAttrValPracName] = '';

                    if (!_RecObj[_opts.RecsTableColCtrlDataAttrValStartTime])
                        _RecObj[_opts.RecsTableColCtrlDataAttrValStartTime] = '';

                    if (!_RecObj[_opts.RecsTableColCtrlDataAttrValSessionMinutes])
                        _RecObj[_opts.RecsTableColCtrlDataAttrValSessionMinutes] = '';

                    if (!_RecObj[_opts.RecsTableColCtrlDataAttrValMiles])
                        _RecObj[_opts.RecsTableColCtrlDataAttrValMiles] = '';

                    if (!_RecObj[_opts.RecsTableColCtrlDataAttrValNote])
                        _RecObj[_opts.RecsTableColCtrlDataAttrValNote] = '';

                    _addRecToRecs(_RecObj);
                });

                _drawRecsTableBodyRows();

                // dataTables plugin
                $(_opts.RecsDocumentationTableSelector).dataTable({
                    "pagingType": "simple_numbers"
                    , "lengthChange": false
                    , "searching": false
                    , "pageLength": 15
                    , "ordering": false
                });

                _initMode = false;
            }
        }
    });

 };

/****************************************************************************/

return {
    init: _init
};

})(jQuery);
