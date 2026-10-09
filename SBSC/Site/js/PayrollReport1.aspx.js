

  //$('.toggle-expand').click(
      var clickToggleExpand = function( tt ){
        //var varthis_jq = $(this);
        var varthis_jq = $( tt );

        $( '.notes-val-td', varthis_jq.parent().parent() ).toggleClass('expanded');
        $( '.task-namestr-td', varthis_jq.parent().parent() ).toggleClass('expanded');

        varthis_jq.toggleClass('ui-spedmon-rotate-180deg-animation');
        //$('.ui-mba-content-selection-content-list.d-none').toggleClass('d-none').toggleClass('d-lg-block').slideDown(600); //do it later

      }
  //)

function PrintPage() {
            var printContent = document.getElementById
            ('PanelReport');
            var printWindow = window.open("All Records", 
                "Print Panel", 'left=50000,top=50000,width=0,height=0');
            printWindow.document.write(
'<html lang="en"><head id="pagehead">' +
'<meta http-equiv="Content-Type" content="text/html; charset=utf-8">' +
'<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"><meta http-equiv="X-UA-Compatible" content="IE=edge">' + 
'<link rel="stylesheet" type="text/css" media="all" href="css/PayrollReport1.aspx.css"/></head><body>' + 
              printContent.innerHTML +
'</body></html>'
            );
            //printWindow.document.close();
            //debugger;
            printWindow.focus();
            setTimeout(function() {
                //printWindow.document.close();
                //printWindow.focus();
                printWindow.print();
            }, 100);
}
function SelectEmployee(id) {
    $('#DropDownListEmployees').val(id);
    __doPostBack('ByDateTab', ''); //$('#ByDateTab').click(); // TODO; i don't like calling click() on DOM selections;
                                            // ideally the click handler would exist somewhere as a named function
                                            // and I could call it directly

}
function SelectDaterange(val) {
    $('#tbStartDate').val(val); $('#tbEndDate').val(val);
    __doPostBack('ByTaskTab', '');// $('#ButtonUpdateDateRange').click(); // TODO; i don't like calling click() on DOM selections;
                                            // ideally the click handler would exist somewhere as a named function
                                            // and I could call it directly

}
function requiresSave(rowid) {
    //debugger;
    $("#orange-dollarval-" + rowid).addClass('requiresSave').parent().addClass('alert-warning text-dark');
    $("#orange-text-" + rowid).addClass('requiresSave').parent().addClass('alert-warning text-dark');
    //$("#bg-btn-rowsave-" + rowid).addClass('alert-warning text-dark');
    $("#btn-rowsave-" + rowid).addClass('requiresSave').parent().addClass('alert-warning text-dark');
}

function adjustmentSave(rowid) {
    //var fnComplete = function () { alert('complete'); };
    //var fnProcRespSuccess = function () { alert('success'); };

    if (! ($("#orange-dollarval-" + rowid).hasClass('requiresSave') )) {
      alert('You have not entered any changes to save.');
      return;
    }

    $.spedmonWebUI.dialogConfirmReason('Are you sure?',
        'Are you sure?',
        function () {
            //var res = $('#dialogConfirmReasonText').val();
            //$('#editDelReason').val(res);
            //var reqData = '{' + 'recids:' + '"' + recIDsStr + '"' + ",editDelReason:" + '"' + res + '"}';
            $.spedmonWebUI.ajax(null,
                'payroll.asmx/saveAdjWReason?tkn='+ $.spedmonWebUI.token,
                JSON.stringify(
                {
                    e_id: rowid,
                    startdate: ($('#tbStartDate').val()),
                    d_amount: ($('#orange-dollarval-' + rowid).val().replace(/,/g, '')),
                    adj_reason: ($('#orange-text-' + rowid).val()),
                }),
                'json_synch', null, null, null, /* $st */ null, 1, null, null, /* fnProcRespSuccess, fnComplete, */ null).always(

                function always(jxhr, str_status) {
                  debugger;
                  console.log(jxhr);
                  if (str_status != "success")
                    alert(str_status);
                  else
                    alert(jxhr.d.message);
                }
            ); 
        },
        function () { });

};