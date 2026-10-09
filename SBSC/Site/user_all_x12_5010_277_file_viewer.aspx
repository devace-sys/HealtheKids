<%@ Page Language="C#" CodeBehind="user_all_x12_5010_277_file_viewer.aspx.cs" Inherits="Spedmon.UserAllX125010277FileViewer"%>

<div class="container-fluid">

<div class="row">
  
  <div class="col-4">    
   <div class="input-group">
     <div class="input-group-prepend">
       <span class="input-group-text">Select 277 File</span>
     </div>
     <input id="fileselect" class="form-control" type="file"/>
   </div>   
 </div> <!-- col -->
  
  <div class="col-4 report-controls">          
      <button id="btnshowaccepteddetailrows" type="button" class="btn btn-primary">Show Accepted Detail Rows</button>
      <button id="btnhideaccepteddetailrows" type="button" class="btn btn-primary">Hide Accepted Detail Rows</button> 
  </div> <!-- col -->

  <div class="col-4 report-controls">      
   <div class="input-group">
     <input id="inpspedcareclaimref" type="text" class="form-control" placeholder="Enter SpEdCare Claim Reference" />
     <div class="input-group-append">
       <button id="btnfinddetailrowbyspedcareclaimref" type="button" class="btn btn-primary ml-2">Find</button>
     </div>
   </div>
   
  </div> <!-- col -->

</div> <!-- row -->

<div class="row mt-3">
<div class="col-12">

<div id="processingmessages">
</div> 

<div id="filereport">
</div> 

</div> <!-- col -->
</div> <!-- row -->


<div class="row">
<div class="col-12">
<div id="filestats">
</div>
</div> <!-- col -->
</div> <!-- row -->

</div> <!-- container -->


<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">

let $fileSelect           = null;
let $fileReport           = null;
let $processingMessages   = null;
let $fileStats            = null;
let $inpSpedcareClaimRef  = null;
let $btnFindDetailRowsBySpedcareClaimRef = null;
let $btnGrpShowHideAcceptedDetailRows = null;
let $btnShowAcceptedDetailRows        = null;
let $btnHideAcceptedDetailRows        = null;
let x12DataObj                        = null;

<%/**************************************************************************************************************************/%>

function closeAllDetailsElements() {
   const allDetailsElements = document.querySelectorAll('details');
   allDetailsElements.forEach(detail => {
     detail.open = false;
   });
};

<%/**************************************************************************************************************************/%>

function clearDetailRowsFound() {
  closeAllDetailsElements();
  $($fileReport).find('table.file-report-details tbody tr').removeClass('table-info');
};

<%/**************************************************************************************************************************/%>

function findAndShowDetailRowBySpEdCareClaimRefID() {
    clearDetailRowsFound();
    let claimrefid = $($inpSpedcareClaimRef).val();
    if (claimrefid) {
        claimrefid = claimrefid.trim();
        let elemRef = document.getElementById(claimrefid);        
        if (elemRef) {
            let elemDetailsPar = elemRef.closest('details');
            if (elemDetailsPar) {
                elemDetailsPar.open = true;
            }
            elemRef.scrollIntoView();            
            elemRef.classList.add('table-info');
        }
    }
};

<%/**************************************************************************************************************************/%>

function findAcceptedDetailRows() {
  return $($fileReport).find('table.file-report-details tbody tr.accepted');
};

<%/**************************************************************************************************************************/%>

function findRejectedDetailRows() {
  return $($fileReport).find('table.file-report-details tbody tr.rejected');
};

<%/**************************************************************************************************************************/%>

function showAcceptedDetailRows() {
    let $detailRows = findAcceptedDetailRows();
    $($detailRows).removeClass('d-none');
    $($btnShowAcceptedDetailRows).hide();
    $($btnHideAcceptedDetailRows).show();
};

<%/**************************************************************************************************************************/%>

function hideAcceptedDetailRows() {
    let $detailRows = findAcceptedDetailRows();
    $($detailRows).addClass('d-none');
    $($btnShowAcceptedDetailRows).show();
    $($btnHideAcceptedDetailRows).hide();
};

<%/**************************************************************************************************************************/%>

function clearContent() {
   $processingMessages.html('');
   $fileReport.html('');
   $fileStats.html('');
   showAcceptedDetailRows();
   $($inpSpedcareClaimRef).val('');
   clearDetailRowsFound();
   $('div.report-controls').addClass('d-none');
   return;
};

<%/**************************************************************************************************************************/%>

function generateProcessingMessages() {    
    let htmlStr = '';
    if (x12DataObj.success === false) {
        htmlStr += '<div>';
        htmlStr += x12DataObj.message;
        htmlStr += '</div>';
        $processingMessages.html(htmlStr);
        return;
    }
    if (x12DataObj.errorsCtr > 0) {
        htmlStr += '<div>';
        x12DataObj.errors.forEach((error) => {
            htmlStr += '<span class="badge badge-danger mr-1">';
            htmlStr += error;
            htmlStr += '</span>';
        });
        htmlStr += '</div>';
    }
    if (x12DataObj.warningsCtr > 0) {
        htmlStr += '<div>';
        x12DataObj.warnings.forEach((warning) => {
            htmlStr += '<span class="badge badge-warning mr-1">';
            htmlStr += warning;
            htmlStr += '</span>';
        });
        htmlStr += '</div>';
    }
    $processingMessages.html(htmlStr);
    return;
};

<%/**************************************************************************************************************************/%>

function generateReport() {

    if (x12DataObj.success === false) return;

    let htmlStr = '';

    let reportsObj = MBA.X12Common.fnParseX125010277DataObjIntoTxSetReportsObj(x12DataObj);

    if (reportsObj.success === false) {
        htmlStr = '<div class="alert alert-warning">';
        htmlStr += reportsObj.message;
        htmlStr += '</div>';
        $fileReport.html(htmlStr);
        return;
    }

    htmlStr += '<table class="table table-sm file-report">';

    htmlStr += '<thead>';

    htmlStr += '<tr>';    
    htmlStr += '<th class="font-weight-bold" scope="col">Transaction</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Response From &<br>Transmission Receipt ID</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Client Name &<br>SpEdCare Transmission Reference</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Received On<br>Processed On</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Accepted<br>Count &<br>Amount</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Rejected<br>Count &<br>Amount</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Status</th>';

    htmlStr += '</tr>';
    htmlStr += '</thead>';
    htmlStr += '<tbody>';

    const numRpts = reportsObj.txSetReports.length;
    let rptCtr = 1;

    reportsObj.txSetReports.forEach((reportObj) => {
        
        htmlStr += '<tr class="file-report-summary">';

        htmlStr += '<td rowspan="2">';
        htmlStr += rptCtr;
        htmlStr += ' of ';
        htmlStr += numRpts;
        htmlStr += '</td>';

        htmlStr += '<td>'
        htmlStr += reportObj.summaryObj.sourceName;
        htmlStr += '<br>';
        htmlStr += reportObj.summaryObj.senderTransactionID;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += reportObj.summaryObj.receiverName;
        htmlStr += '<br>';
        htmlStr += reportObj.summaryObj.transmissionID;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += reportObj.summaryObj.dateReceived.toDateString();
        htmlStr += '<br>';
        htmlStr += reportObj.summaryObj.dateProcessed.toDateString();
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += reportObj.summaryObj.qtyClaimsAccepted;
        htmlStr += '<br>';
        htmlStr += reportObj.summaryObj.amtClaimsAccepted;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += reportObj.summaryObj.qtyClaimsRejected;
        htmlStr += '<br>';
        htmlStr += reportObj.summaryObj.amtClaimsRejected;
        htmlStr += '</td>';

        let styleDetails    = false;
        let statusCellClass = "";

        if (reportObj.summaryObj.batchStatusState === 1) {
            styleDetails = false;
            statusCellClass = "table-success";
        }
        else if (reportObj.summaryObj.batchStatusState === 2) {
            styleDetails    = true;
            statusCellClass = "table-warning";
        }
        else if (reportObj.summaryObj.batchStatusState === 3) {
            styleDetails    = false;
            statusCellClass = "table-danger";
        }
        /* Future */

        else {

        }

        htmlStr += '<td ';
        htmlStr += 'class="';
        htmlStr += statusCellClass;
        htmlStr += '">';
        htmlStr += reportObj.summaryObj.batchStatusMessage;
        htmlStr += '</td>';        
        htmlStr += '</tr>';

        htmlStr += '<tr>';
        htmlStr += '<td colspan="6">';
        htmlStr += '<details>';
        htmlStr += '<summary>';
        htmlStr += 'Details (';
        htmlStr += reportObj.detailObjs.length;
        htmlStr += ')';
        htmlStr += '</summary>';
        
        htmlStr += '<table class="file-report-details mt-2">';
        htmlStr += '<thead">';
        htmlStr += '<tr>';
        htmlStr += '<th class="font-weight-bold" scope="col">Patient &<br>Insurance ID</th>';
        htmlStr += '<th class="font-weight-bold" scope="col">SpEdCare<br>Claim Reference</th>';
        htmlStr += '<th class="font-weight-bold" scope="col">Claim<br>Accepted</th>'
        htmlStr += '<th class="font-weight-bold" scope="col">Claim<br>Status</th>';
        htmlStr += '</tr>';
        htmlStr += '</thead>';
        htmlStr += '<tbody>';
        reportObj.detailObjs.forEach((detailObj) => {
            for (const [key, value] of detailObj.claims) {

                htmlStr += '<tr id = "' + key + '" class =';

                let acceptedYN = 'No';

                if (value.accepted === true) {
                    acceptedYN = 'Yes';
                    htmlStr += '"accepted"';
                }
                else {
                    if (styleDetails === true) {
                        htmlStr += '"rejected table-warning"';
                    }
                    else {
                        htmlStr += '"rejected"';
                    }
                }
                htmlStr += '>';
                htmlStr += '<td>' + detailObj.patientLastName + ',' + detailObj.patientFirstName;
                htmlStr += '<br>' + detailObj.patientBeneficiaryID + '</td>';
                htmlStr += '<td>' + key + '</span></td>';
                htmlStr += '<td>' + acceptedYN + '</td>';
                htmlStr += '<td>';

                /* Start of claim status */

                htmlStr += '<table>';
                htmlStr += '<thead>';
                htmlStr += '<tr>';
                htmlStr += '<th class="font-weight-bold" scope="col">Action<br>Code</th>';
                htmlStr += '<th class="font-weight-bold" scope="col">Effective<br>Date</th>';
                htmlStr += '<th class="font-weight-bold" scope="col">Amount</th>';
                htmlStr += '<th class="font-weight-bold" scope="col">Additional<br>Message</th>';
                htmlStr += '<th class="font-weight-bold" scope="col">Status<br>Codes</th>';
                htmlStr += '</tr>';
                htmlStr += '</thead>';
                htmlStr += '<tbody>';
                value.patientLevelStcObjs.forEach((stcObj) => {
                    htmlStr += '<tr>';
                    htmlStr += '<td>';
                    htmlStr += stcObj.actionCode;
                    htmlStr += '</td>';
                    htmlStr += '<td>';
                    htmlStr += stcObj.effectiveDate.toDateString();
                    htmlStr += '</td>';
                    htmlStr += '<td>';
                    htmlStr += stcObj.amount;
                    htmlStr += '</td>';
                    htmlStr += '<td>';
                    htmlStr += stcObj.messageText;
                    htmlStr += '</td>';
                    htmlStr += '<td>';

                    /* Start of status codes */

                    htmlStr += '<table>';
                    htmlStr += '<thead>';
                    htmlStr += '<th class="font-weight-bold" scope="col" colspan="2">Category</th>'
                    htmlStr += '<th class="font-weight-bold" scope="col" colspan="2">Status</th>'
                    htmlStr += '<th class="font-weight-bold" scope="col" colspan="2">Entity</th>'
                    htmlStr += '</thead>';
                    htmlStr += '<tbody>';
                    stcObj.statusCodeObjs.forEach((statusCodeObj) => {
                        htmlStr += '<tr>';

                        htmlStr += '<td>';
                        htmlStr += statusCodeObj.claimStatusCategoryCodeValue;
                        htmlStr += '</td>';

                        htmlStr += '<td>';
                        htmlStr += statusCodeObj.claimStatusCategoryCodeName;
                        htmlStr += '</td>';

                        htmlStr += '<td>';
                        htmlStr += statusCodeObj.claimStatusCodeValue;
                        htmlStr += '</td>';

                        htmlStr += '<td>';
                        htmlStr += statusCodeObj.claimStatusCodeName
                        htmlStr += '</td>';

                        htmlStr += '<td>';
                        htmlStr += statusCodeObj.entityIdentifierCodeValue;
                        htmlStr += '</td>';

                        htmlStr += '<td>';
                        htmlStr += statusCodeObj.entityIdentifierCodeName;
                        htmlStr += '</td>';

                        htmlStr += '</tr>';
                    });                    
                    htmlStr += '</tbody></table>';
                    /* End of status codes */

                    htmlStr += '</td>';
                    htmlStr += '</tr>';
                });
                htmlStr += '</tbody>';
                htmlStr += '</table>';
                /* End of claim status */

                htmlStr += '</td>';
                
                htmlStr += '</tr>';
            };
            
        });

        htmlStr += '</tbody>';
        htmlStr += '</table>';
        htmlStr += '</details>';
        htmlStr += '</td>';
        htmlStr += '</tr>';
        rptCtr++;
    });
    
    htmlStr += '</tbody>';
    htmlStr += '</table>';
    $fileReport.html(htmlStr);
    showAcceptedDetailRows();
    $('div.report-controls').removeClass('d-none');
    return;
};

<%/**************************************************************************************************************************/%>

function generateFileStats() {
        let htmlStr = '';
        if (x12DataObj.success === true) {
            htmlStr += '<details>';
            htmlStr += '<summary>Segment Stats</summary>';

            htmlStr += '<ul class="list-group">';
            for (const [segmentKey, segmentCount] of x12DataObj.segmentCounts) {
                htmlStr += '<li class="list-group-item d-flex justify-content-between align-items-center">';
                htmlStr += segmentKey;
                htmlStr += '<span class="badge badge-primary badge-pill">' + segmentCount + '</span>';
                htmlStr += '</li>';
            };
            htmlStr += '</ul>';
            htmlStr += '</details>';
        }
        $fileStats.html(htmlStr);
 };

<%/**************************************************************************************************************************/%>

function generateContent () {
    clearContent();
    generateProcessingMessages();
    generateReport();
    generateFileStats();
};

<%/**************************************************************************************************************************/%>

function processFile(fileName, fileContent) {
   clearContent();
   x12DataObj = MBA.X12Common.fnParseX125010FileContentIntoX125010DataObj(fileName, fileContent);
   generateContent();
};

<%/**************************************************************************************************************************/%>

function loadSelectedFile(e) {  
  const file = e.target.files[0];
  if (file) {        
    const reader = new FileReader();
    reader.addEventListener("load", function (f) {        
        processFile(file.name, reader.result);
    });    
    reader.readAsText(file);
  };
};

<%/**************************************************************************************************************************/%>

$(document).ready(function () {
  $fileSelect            = $('#fileselect');
  $fileReport            = $('#filereport');
  $processingMessages    = $('#processingmessages');
  $fileStats             = $('#filestats');
  $btnShowAcceptedDetailRows           = $('#btnshowaccepteddetailrows');
  $btnHideAcceptedDetailRows           = $('#btnhideaccepteddetailrows');
  $btnFindDetailRowsBySpedcareClaimRef = $('#btnfinddetailrowbyspedcareclaimref');    
  $inpSpedcareClaimRef                 = $('#inpspedcareclaimref');  
  
  $($fileSelect).val('');
  clearContent();
  $($btnShowAcceptedDetailRows).on('click', function (e) { showAcceptedDetailRows();});
  $($btnHideAcceptedDetailRows).on('click', function (e) { hideAcceptedDetailRows(); });
  $($btnFindDetailRowsBySpedcareClaimRef).on('click', function (e) { findAndShowDetailRowBySpEdCareClaimRefID();})
  $($fileSelect).on('change', function (e) { loadSelectedFile(e); });
});

</script>