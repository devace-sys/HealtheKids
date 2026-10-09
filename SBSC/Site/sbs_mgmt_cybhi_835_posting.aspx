<%@ Page Language="C#" CodeBehind="sbs_mgmt_cybhi_835_posting.aspx.cs" Inherits="Spedmon.SbsMgmtCybhi835Posting"%>

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
 
  <div class="col-4">          
      <button id="btnpost" type="button" class="btn btn-primary">Post</button>      
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
let fileName              = null;
let fileContent           = null;
let x12DataObj            = null;
let reportsObj            = null;
let postingObjs           = null;
let $btnPost              = null;

<%/**************************************************************************************************************************/%>

function clearContent() {
   $processingMessages.html('');
   $fileReport.html('');
   fileName     = null;
   fileContent  = null;
   postingObjs  = null;
   x12DataObj   = null;
   reportsObj   = null;
   return;
};

<%/**************************************************************************************************************************/%>

function requestPosting() {
    let reqUrl = '';
    let reqObj = {};
    reqObj.filename    = fileName;
    //reqObj.filecontent = fileContent;
    reqObj.postings    = postingObjs;
    reqObj.validate    = '';
    let reqJSON = JSON.stringify(reqObj);
    console.log(reqJSON);
    return;

    //$butSaveSpinner = MBA.ComponentCommon.fnElemDisableAndAddSpinner($butSave);

    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, null)
        .then(responseData => {
            //parseReturnJSON(responseData.rawData.jsonData);
            //MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butSave, $butSaveSpinner);
        })
        .catch(err => {
            //MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butSave, $butSaveSpinner);
            //MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Process', err.message, {});
        });
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
    htmlStr = MBA.X12Common.fnParseX125010835TxSetReportsObjIntoHTMLTableStr(reportsObj);
    $fileReport.html(htmlStr);
    return;
};

<%/**************************************************************************************************************************/%>

function processFile () {
   x12DataObj = MBA.X12Common.fnParseX125010FileContentIntoX125010DataObj(fileName, fileContent);
   generateProcessingMessages();
   if (x12DataObj.success === false) return;
   reportsObj = MBA.X12Common.fnParseX125010835DataObjIntoTxSetReportsObj(x12DataObj);   
   generateReport();
   postingObjs = MBA.X12Common.fnParseX125010835TxSetReportsObjIntoPostingObjs(reportsObj);
};

<%/**************************************************************************************************************************/%>

function loadSelectedFile(e) {
  const file = e.target.files[0];
  if (file) {        
    clearContent();
    const reader = new FileReader();
    reader.addEventListener("load", function (f) {
        fileName    = file.name;
        fileContent = reader.result;
        processFile();
    });    
    reader.readAsText(file);
  };
};

<%/**************************************************************************************************************************/%>

$(document).ready(function () {
  $fileSelect = $('#fileselect');
  $fileReport = $('#filereport');
  $btnPost = $('#btnpost');
  $processingMessages = $('#processingmessages');
  $($fileSelect).val('');
  clearContent();
  $($fileSelect).on('change', function (e) { loadSelectedFile(e); });
  $($btnPost).on('click', function () { requestPosting(); });
});
</script>