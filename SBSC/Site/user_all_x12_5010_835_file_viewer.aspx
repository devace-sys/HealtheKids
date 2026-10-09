<%@ Page Language="C#" CodeBehind="user_all_x12_5010_835_file_viewer.aspx.cs" Inherits="Spedmon.UserAllX125010835FileViewer"%>

<div class="container-fluid">

<div class="row">
  
  <div class="col-4">    
   <div class="input-group">
     <div class="input-group-prepend">
       <span class="input-group-text">Select 835 File</span>
     </div>
     <input id="fileselect" class="form-control" type="file"/>
   </div>   
 </div> <!-- col -->
 
  <div class="col-4 report-controls">          
      <button id="btnshowjustdeniedrows" type="button" class="btn btn-primary">Show Just Denied</button>
      <button id="btnshowallrows" type="button" class="btn btn-primary">Show All</button> 
  </div> <!-- col -->
  
</div> <!-- row -->

<div class="row">
<div class="col-12">
<div id="processingmessages">
</div> 
</div> <!-- col -->
</div> <!-- row -->

<div class="row mt-3">
<div class="col-12">
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
let $fileStats            = null;
let $processingMessages   = null;
let x12DataObj            = null;

let $btnFindDetailRowsBySpedcareClaimRef = null;
let $btnShowJustDenialRows               = null;
let $btnShowAllRows                      = null;

<%/**************************************************************************************************************************/%>

function findAcceptedClaimLevelDetailRows() {
  return $($fileReport).find('tr.accepted');
};

<%/**************************************************************************************************************************/%>

function findRejectedClaimLevelDetailRows() {
    return $($fileReport).find('tr.rejected');
};

<%/**************************************************************************************************************************/%>

function showAllClaimLevelDetailRows() {
    findAcceptedClaimLevelDetailRows().removeClass('d-none')
    findRejectedClaimLevelDetailRows().removeClass('d-none');
    $($btnShowJustDenialRows).show();
    $($btnShowAllRows).hide();
};

<%/**************************************************************************************************************************/%>

function showJustDeniedClaimLevelDetailRows() {
    findAcceptedClaimLevelDetailRows().addClass('d-none')
    findRejectedClaimLevelDetailRows().removeClass('d-none');
    $($btnShowJustDenialRows).hide();
    $($btnShowAllRows).show();
};

<%/**************************************************************************************************************************/%>

function clearContent() {
   $processingMessages.html('');
   $fileReport.html('');
   $fileStats.html('');
   showAllClaimLevelDetailRows();
   $('div.report-controls').addClass('d-none');
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
    
    let htmlStr = '';

    if (x12DataObj.success === false) return;

    let reportsObj = MBA.X12Common.fnParseX125010835DataObjIntoTxSetReportsObj(x12DataObj);
    htmlStr = MBA.X12Common.fnParseX125010835TxSetReportsObjIntoHTMLTableStr(reportsObj);
    $fileReport.html(htmlStr);
    $('div.report-controls').removeClass('d-none');
    return;
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
        $fileSelect = $('#fileselect');
        $fileReport = $('#filereport');
        $fileStats = $('#filestats');

        $processingMessages = $('#processingmessages');
        $btnShowJustDenialRows = $('#btnshowjustdeniedrows');
        $btnShowAllRows = $('#btnshowallrows');

        $($fileSelect).val('');
        clearContent();
        $($fileSelect).on('change', function (e) { loadSelectedFile(e); });
        $($btnShowJustDenialRows).on('click', function (e) { showJustDeniedClaimLevelDetailRows(); });
        $($btnShowAllRows).on('click', function (e) { showAllClaimLevelDetailRows(); });

    });
</script>