<%@Page Language="C#" AutoEventWireup="true" CodeBehind="practice_office_public_check_in.aspx.cs" Inherits="Spedmon.PracticeOfficePublicCheckIn" subTitle="Check In"%>
<%if (this.pageInitIsOK == true) { %>

<form id="check-in-form">

<%/****************************************************************************/%>
<%/* Public Token (Note: Do NOT MOVE INSIDE CONTAINER) */%>
<%/****************************************************************************/%>

<input id="<%=Spedmon.Constants.PARM_PUBLIC_TOKEN%>" name="<%=Spedmon.Constants.PARM_PUBLIC_TOKEN%>" type="hidden" value="<%=ptkn%>"/>

<div class="container-fluid">

<%/****************************************************************************/%>
<%/* Title and Site Name */%>
<%/****************************************************************************/%>

<div class="row" style="border-bottom:1px solid #000">
<div class="col-2">
<img src="<%=rec.clientLogoFileBase64%>" style="width:80%;height:80%;object-fit:contain;display:block;"/>
</div> <!-- col-->
<div class="col-10">
<h1><%=rec.practiceName%> Office</h1>
<h2><%=rec.siteName%></h2>
<h3><%=rec.clientName%></h3>
</div> <!-- col -->
</div> <!-- row -->

<%/****************************************************************************/%>
<%/* Instructions/Status */%>
<%/****************************************************************************/%>

<div class="row mt-2 mb-2">
<div id="status-container" class="col-12"></div> <!-- col-->
</div> <!-- row -->

<%/****************************************************************************/%>
<%/* Student ID */%>
<%/****************************************************************************/%>

<div class="row">
<div class="col-6">
<h4><label for="<%=Spedmon.Constants.PARM_STUDENT_ID%>">Your Student ID Or Name<span class="ml-2 badge badge-danger">Required</span></label></h4>
</div> <!-- col -->
<div class="col-6">
<input id="<%=Spedmon.Constants.PARM_STUDENT_ID%>" name="<%=Spedmon.Constants.PARM_STUDENT_ID%>" type="text" required="required" placeholder="Enter A Student ID Or Name" class="form-control form-control-lg" maxlength="50"/>
</div> <!-- col -->
</div> <!-- row -->

<%/****************************************************************************/%>
<%/* Visit Reason */%>
<%/****************************************************************************/%>

<div class="row mt-2">
<div class="col-6">
<h4><label for="<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_REASON_ID%>">Reason For Your Visit <span class="ml-2 badge badge-danger">Required</span></label></h4>
</div> <!-- col -->
<div class="col-6">
<select id="<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_REASON_ID%>" name="<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_REASON_ID%>" required="required" class="form-control form-control-lg">
<%=visitReasonsOptionsHTML%>
</select>
</div> <!-- col -->
</div> <!-- row -->

<%/****************************************************************************/%>
<%/* Visit Reason Notes */%>
<%/****************************************************************************/%>

<div class="row mt-2">
<div class="col-6">
<h4><label for="<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_REASON_NOTES%>">Additional Information</label></h4>
</div> <!-- col -->
<div class="col-6">
<textarea id="<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_REASON_NOTES%>" name="<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_REASON_NOTES%>" placeholder="Enter any additional information about your visit that you believe we need to know." class="form-control form-control-lg" maxlength="2000">
</textarea>
</div> <!-- col -->
</div> <!-- row -->

<%/****************************************************************************/%>
<%/* Clear Button and Check In Button */%>
<%/****************************************************************************/%>

<div class="row mt-2">
<div class="col-6">
<button id="clear-check-in" type="button" class="btn btn-danger btn-lg btn-block">Clear</button>
</div> <!-- col -->
<div class="col-6">
<button id="request-check-in" type="button" class="btn btn-success btn-lg btn-block">Check In</button>
</div> <!-- col -->    
</div> <!-- row -->

</div> <!-- container -->
</form>

<%/****************************************************************************/%>
<%/* Scripting */%>
<%/****************************************************************************/%>

<script>

<%/*-----------------------------------------------------------------------------------*/%>

const DEFAULT_STATUS_MESSAGE_TEXT  = "Please complete the following form";
const DEFAULT_STATUS_MESSAGE_CLASS = "alert-light";

<%/*-----------------------------------------------------------------------------------*/%>

let $formCheckIn = null;
let $butCheckIn         = null;
let $butClear           = null;
let $divStatusContainer = null;

<%/*-----------------------------------------------------------------------------------*/%>

function disableOrEnableCheckInForm(what) {$("input, select, textarea, button", $formCheckIn).prop('disabled', what);};

<%/*-----------------------------------------------------------------------------------*/%>

function clearStatusMessage() { $($divStatusContainer).children().remove();};

<%/*-----------------------------------------------------------------------------------*/%>

function updateStatusMessage(message, messageClass, showMessageThenResetToDefault) {
    clearStatusMessage();
    let $statusMsg = $('<p class="text-center alert"></p>');
    $($statusMsg).addClass(messageClass);
    $($statusMsg).text(message);
    $($divStatusContainer).append($statusMsg);    
    if (showMessageThenResetToDefault == true) {
        $($statusMsg).fadeOut(5000, function () {
          updateStatusMessage(DEFAULT_STATUS_MESSAGE_TEXT, DEFAULT_STATUS_MESSAGE_CLASS, false);
        });
    }
};

<%/*-----------------------------------------------------------------------------------*/%>

function doClearForm() {
    $($formCheckIn)[0].reset();    
};

<%/*-----------------------------------------------------------------------------------*/%>

function requestCheckIn() {

  if ($($formCheckIn)[0].reportValidity() == false) {
        updateStatusMessage('Please complete all required fields', 'alert-warning', false);
        return;
  }

  updateStatusMessage('Please Wait', 'alert-info', false);
  
  let formFields = $($formCheckIn).serializeArray();
  let reqObj = {};
  formFields.forEach(function (field) {reqObj[field.name] = field.value;})
  let reqJSON = JSON.stringify(reqObj);
  let requestURL = '<%=checkInSvcURL%>';
  let reqOpts = {};
  reqOpts.method = 'POST';
  reqOpts.type   = 'POST';
  reqOpts.data   = reqJSON;
  reqOpts.processData = false;
  reqOpts.contentType = 'application/json; charset=UTF-8';
  disableOrEnableCheckInForm(true);
  $.ajax(requestURL, reqOpts)
   .done(function (data, textStatus, jqXHR) {
     if (data.hasOwnProperty('d')) {
       let dataInD = data.d;
       data = dataInD;
     }            
     disableOrEnableCheckInForm(false);
     if (data.status == 0) {  
         doClearForm();
         updateStatusMessage('You are checked in', 'alert-success', true);
     }
     else {
         updateStatusMessage(data.message, 'alert-warning', false);
     }
   })
  .fail(function (jqXHR, textStatus, errorThrown) {
     disableOrEnableCheckInForm(false);
     updateStatusMessage('Unexpected issue please try again', 'alert-danger', false);
   });
};

<%/*-----------------------------------------------------------------------------------*/%>

$(window).on('load', function () {
    $formCheckIn        = $('#check-in-form');
    $butCheckIn         = $('#request-check-in');
    $butClear           = $('#clear-check-in');
    $divStatusContainer = $('#status-container');
    doClearForm();
    updateStatusMessage(DEFAULT_STATUS_MESSAGE_TEXT, DEFAULT_STATUS_MESSAGE_CLASS, false);
    $($butCheckIn).on('click', function () { requestCheckIn(); });
    $($butClear).on('click', function () { doClearForm(); updateStatusMessage('Form Cleared', 'alert-info', true);});
});

<%/*-----------------------------------------------------------------------------------*/%>

</script>

<%} else {%>

<%}%>