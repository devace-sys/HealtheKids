var latestServiceRecordDataRecorded = '{}';

function saveServiceRecords() {

    var fnStart = function () { };
    var fnOnGoBack = function () { };
    var fnOnProceedWithSave = function () { };
    var fnOnGoBackAndFix = function () { };

    MBA.util.tableBodyToJsonNameValueList('tblSvcRecordsBody', 'svcDetails')
      .then(jsonData => {
          $('#details').val(jsonData);        
          return MBA.telecomm.doSubmitFinalForm('frmSvcRecords', 'butSubSvcRecords', 'Save Service Records', fnStart, fnOnGoBack, fnOnProceedWithSave, fnOnGoBackAndFix);
      })
      .catch(saveErr => {
          
      });
}

function restoreServiceRecordFormData () {  
  let _latestRoomFormDataRecordedObj = JSON.parse(latestServiceRecordDataRecorded);
  if (_latestRoomFormDataRecordedObj.forms) {
    $.each(_latestRoomFormDataRecordedObj.forms, function (_formIdx, _formObj) {
        let _formID      = _formObj.formID
        let _formDataObj = JSON.parse(_formObj.formDataJSON);
        MBA.util.objToForm(_formID, _formDataObj, true);
	});      
    let jsonData = $('#details').val();
	MBA.util.jsonNameValueListToTableBody (jsonData, 'svcDetails', 'tblSvcRecordsBody');
  }
}

$(document).ready(function () {

    restoreServiceRecordFormData();
	
	autosize($('textarea.form-control'));

    /* Setup table header copy down buttons */

    $('#tblSvcRecordsHead > tr > th > button[data-copy-down]').on('click', function (butCopyClickEvent) {
        let butClicked      = butCopyClickEvent.target;
        let fldName = $(butClicked).attr('data-copy-down');
        let inpSelHead = 'input[data-copy-down="' + fldName + '"]';
        let inputToCopyDown = $(butClicked).siblings(inpSelHead).first();
        let fldValue = $(inputToCopyDown).val();
        let inpSelBody = 'input[name="' + fldName + '"]';
        $('#tblSvcRecordsBody > tr > td ' + inpSelBody).val(fldValue);
        
    });

    /* Track changes for saving WIP */

    $('#tblSvcRecords :input').on('click change select focusout', function (dataChangedEvent) {
        MBA.util.tableBodyToJsonNameValueList('tblSvcRecordsBody', 'svcDetails').then(jsonData => {
            $('#details').val(jsonData).trigger('change');            
        });
    });
   
    /* Save service records button */

    $('#frmSvcRecords').on('submit', function (e) { e.preventDefault(); });
  
    $('#butSubSvcRecords').click(function (e) {
      e.preventDefault();    
      saveServiceRecords();	
    });
    
});

