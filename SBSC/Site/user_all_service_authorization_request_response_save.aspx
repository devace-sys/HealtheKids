<%@ Page Language="C#" CodeBehind="user_all_service_authorization_request_response_save.aspx.cs" Inherits="Spedmon.UserAllServiceAuthorizationRequestResponseSave" %>

<main> <%/* Note: This is loaded into an iframe*/%>

<%//##################################################################################################################%>
<%//#                                         Request Operations   %>
<%//##################################################################################################################%>

<div class="service-request-operations">

<%//-----------------------------------------------------------------------------%>
<%// Can Delete and Save New (Used for Pending)  %>
<%//-----------------------------------------------------------------------------%>

<%if (sar.viewingUserCanCurrentlyDeleteAndSaveNew == true) {%>
<script type="text/javascript" charset="utf-8">
function doDeleteAndSaveNew() {
  var fnRefreshRequestListAfterDeleteAndSaveNew = function () {
    var pw = window.parent; pw.refreshAll(); return true;
  }
  var wdsn = $.spedmonWebUI.openURL('<%=urlDeleteAndSaveNewRequest%>', 1);
  wdsn.addEventListener("beforeunload", function (e) {
    fnRefreshRequestListAfterDeleteAndSaveNew();
  });
};

function doDeleteRequest() {
  // function to refresh the shown records on delete
  var fnRefreshRequestListAfterDelete = function () {
      var pw = window.parent; pw.refreshAll(); return true;
  }

  // callback or when delete ajax request is successful
  var fnOnAjaxSuccess = function() {
      //build data object for post request
<%--      var deleteAjaxData = {
                          "<%=appModeVarName%>"       : "<%=appModeVal%>",    
                          "<%=saveTypeVarName%>"      : <%=saveTypeVal%>,    
                          "<%=recIDVarName%>"         : <%=recIDVal%>,    
                          "<%=editDelReasonVarName%>" : "<%=editDelReasonVal%>",    
                          "<%=validateRecVarName%>"   : <%=validateRecVal%> }; --%>

      $.spedmonWebUI.ajax(null, "<%=urlDeleteRequest%>", "<%=deleteAjaxDataObj%>", 'json', null, null, null, null, 0, fnRefreshRequestListAfterDelete, null, null);
  }

  // callback or when delete ajax request is unsuccessful
  var fnOnAjaxSuccess = function() {
      $.spedmonWebUI.ajax(null, "<%=urlDeleteRequest%>", "<%=deleteAjaxDataObj%>", 'json', null, null, null, null, 0, fnRefreshRequestListAfterDelete, null, null);
  }

  $.spedmonWebUI.dialogConfirm("Please Confirm", "Are you sure you want to cancel this request?", fnOnAjaxSuccess, function () { })

};
    
</script>
<span class="service-request-operation">
<Spedmon:Button ID="butdeleteandsavenew" icon="ui-icon-transfer-e-w" onclick="doDeleteAndSaveNew()" runat="server">Edit and Resubmit this Request</Spedmon:Button>
<Spedmon:Button ID="butdelete" icon="ui-icon-cancel" onclick="doDeleteRequest()" runat="server">Cancel this Request</Spedmon:Button>
</span>
<%}%>

<%//-----------------------------------------------------------------------------%>
<%// Can Close and Save New (Used for Declined)  %>
<%//-----------------------------------------------------------------------------%>

<%if (sar.viewingUserCanCurrentlyCloseAndSaveNew == true) {%>
<script type="text/javascript" charset="utf-8">
  function doCloseAndSaveNew() {

    var fnRefreshRequestListAfterCloseAndSaveNew = function () {
       var pw = window.parent; pw.refreshAll(); return true;
    }

    var wdsn = $.spedmonWebUI.openURL('<%=urlCloseAndSaveNewRequest%>', 1);

    wdsn.addEventListener("beforeunload", function (e) {
      fnRefreshRequestListAfterCloseAndSaveNew();
    });
  };
</script>

<span class="service-request-operation">
<Spedmon:Button ID="butcloseandsavenew" icon="ui-icon-transfer-e-w" onclick="doCloseAndSaveNew()" runat="server">Edit and Resubmit This Request</Spedmon:Button>
</span>
<%}%>

<%//-----------------------------------------------------------------------------%>
<%// Download Returned Form  %>
<%//-----------------------------------------------------------------------------%>

<%if (showDownloadReturnedForm == true) {%>
<script type="text/javascript" charset="utf-8">
function doDownloadReturnedForm() {
$.spedmonWebUI.downloadDynamicURL('<%=urlPaperFormDownload%>');
return;
};
</script>
<span class="service-request-operation">
<Spedmon:Button ID="butdownloadreturnedform" icon="ui-icon-arrowthickstop-1-s" onclick="doDownloadReturnedForm()" runat="server">Download Returned Form</Spedmon:Button>
</span>
<%}%>

<%//-----------------------------------------------------------------------------%>
<%// Request ID  %>
<%//-----------------------------------------------------------------------------%>

<span class="service-request-id">
<span class="service-request-id-label">Request ID</span>
<span class="service-request-id-number"><%=sar.id%></span>
</span>

</div>

<%//##################################################################################################################%>
<%//#                                         Request Details   %>
<%//##################################################################################################################%>

<%//-----------------------------------------------------------------------------%>
<%// Request Date and Service Name   %>
<%//-----------------------------------------------------------------------------%>

<div class="svc-auth-request-view-section">
<h3>Authorization Requested On <%=sar.requestDateStr%> For :</h3>
<p>
<%=sar.name%>
</p>
</div>

<%//-----------------------------------------------------------------------------%>
<%// Service Description  %>
<%//-----------------------------------------------------------------------------%>

<div class="svc-auth-request-view-section">
<h3>Description of Request :</h3>
 <%if (!String.IsNullOrEmpty(sar.formBuilderQuestionsJSON)) { %>
    <Spedmon:DataEntryRowFormBuilderRenderBox ID="formBuilderAnswersJSONForOrder" name="formBuilderAnswersJSONForOrder" showFormBuilderBtnText="View Form Answers" formEditable="false" renderInDialog="false" runat="server"></Spedmon:DataEntryRowFormBuilderRenderBox>
<%} else { %>
    <pre><%=sar.svcDescription%></pre>
<%}%>
</div>

<%//-----------------------------------------------------------------------------%>
<%// Included Files  %>
<%//-----------------------------------------------------------------------------%>

<%if (sar.hasFileIncludes == true) {%>
<div class="svc-auth-request-view-section">
<h3>Attachments :</h3>
<%=includedFiles%>
</div>
<%}%>

<%//-----------------------------------------------------------------------------%>
<%// District Contact  %>
<%//-----------------------------------------------------------------------------%>

<div class="svc-auth-request-view-section">
<h3>Requested By :</h3>
<address class="contact contact-container">
<div class="contact contact-line">
<span class="contact contact-name"><%=sar.districtContactName%></span>
</div>
<div class="contact contact-line">
<span class="contact contact-title"><%= !(Util.IsNullOrEmpty(sar.pracTitle)) ? (sar.pracTitle + " - " ) : "" %><%=sar.clientName%></span>
</div>
<div class="contact contact-line">
<span class="contact contact-email"><Spedmon:EmailLink ID="pracemail" runat="server"/></span>
<span class="contact contact-phone"><Spedmon:PhoneLink ID="pracphone" runat="server"/></span>
</div>
</address>
</div>

<%//-----------------------------------------------------------------------------%>
<%// Requesting Authorization From - Previous Request  %>
<%//-----------------------------------------------------------------------------%>

<%if (sar.showPrevResponseInChain) {%>
<div class="svc-auth-request-view-section">
<address class="contact contact-container">
<div class="contact contact-line">
<span class="contact contact-name"><%=sar.prevChainRespondantName%></span>
<span class="contact contact-title"><%=sar.prevChainRespondantTitle%></span>
</div>
<div class="contact contact-line">
<span class="contact contact-email"><Spedmon:EmailLink ID="prevRespondantEmail" runat="server"/></span>
<span class="contact contact-phone"><Spedmon:PhoneLink ID="prevRespondantPhone" runat="server"/></span>
</div>
</address>
</div>
<%}%>

<%//-----------------------------------------------------------------------------%>
<%// Requesting Authorization From - Current  %>
<%//-----------------------------------------------------------------------------%>

<div class="svc-auth-request-view-section">
<h3>Request Sent To <%=sar.reqSvcAuthFromSelectionName%> :</h3>
<address class="contact contact-container">
<div class="contact contact-line">
<span class="contact contact-name"><%=sar.currChainRespondantName%></span>
<span class="contact contact-title"><%=sar.currChainRespondantTitle%></span>
</div>
<div class="contact contact-line">
<span class="contact contact-email"><Spedmon:EmailLink ID="currRespondantEmail" runat="server"/></span>
<span class="contact contact-phone"><Spedmon:PhoneLink ID="currRespondantPhone" runat="server"/></span>
</div>
</address>
</div>

<%//-----------------------------------------------------------------------------%>
<%// Supporting Files (Additional Documentation) %>
<%//-----------------------------------------------------------------------------%>

<%if (showSupportingFilesSection == true) {%>
<div class="svc-auth-request-view-section">
<h3>Additional Documentation :</h3>
<p><%=supportingFiles%></p>
</div>
<%}%>

<%//##################################################################################################################%>
<%//#                                         Response Details   %>
<%//##################################################################################################################%>

<div class="svc-auth-request-view-section svc-auth-request-view-section-response">

<ul class="svc-auth-responses">
<%if (sar.showPrevResponseInChain) {%>
<li class="svc-auth-response">
<%=sar.prevChainResponseSummary%>
<%if(sar.prevChainShowResponseNotes){%>
 Notes:<%=sar.prevChainResponseNotes%>
<%}%>
</li>

<%}%>
<li class="svc-auth-response">
<%=sar.currChainResponseSummary%>
<%if(sar.currChainShowResponseNotes){%>
 Notes: <%=sar.currChainResponseNotes%>
<%}%>
</li>
</ul>
<%
if (sar.viewingUserCanCurrentlyAccessResponseForm == true) 
{
%>
<hr />
<%if (sar.reqSvcAuthMethodSelectionID == (long) RequestServiceAuthorizationMethod.ELECTRONIC){%>

<form id="frmsvcauthrequestresponse" method="post" action="<%=urlSvcSave%>"  class="svc-auth-request-view-section svc-auth-request-view-section-response">


  <Spedmon:HiddenInput ID="savetype" name="savetype" title="savetype" value="1" runat="server"/>
  <Spedmon:HiddenInput ID="recid" name="recid" title="recid" value="" runat="server"/>
  <Spedmon:HiddenInput ID="validaterec" name="validaterec" title="validaterec" value="1" runat="server"/>
  <Spedmon:HiddenInput ID="requestid" name="requestid" title="requestid" runat="server"/>
    
  <h3><%=Spedmon.ServiceAuthorizationCommon.LABEL_I_HAVE_REVIEWED_RESPONSE%></h3>
  
  <p>
  <span class="center-field">

  <Spedmon:SelectRequestServiceAuthorizationResponse 
    id                    = "responsecode" 
    name                  = "responsecode" 
    title                 = "Select One"
    selectionTextApproved = "Approve This Request"
    selectionTextDeclined = "Decline This Request"
    showPendingOption     = "false"
    onSelectValue         = "function(oldval,newval){reqSvcIs (oldval,newval); return true;}" 
    value                 = "APPROVED"
    runat                 = "server"/>
   </span>
  </p>

  <p id="effectivedaterow">
    <span class="center-field">
      <label for="effectivedate">Authorization Effective As Of : </label>
      <Spedmon:DateBox ID="effectivedate" name="effectivedate" title="Authorization Effective As Of" showOK="false" cssInline="width:10em;" runat="server" />
    </span>
  </p>
  
  <p>
    <span class="center-field">
    <Spedmon:NoteAreaBox ID="editDelReason" name="editDelReason" cssInline="width:100%;height:4em;" maxlen="5000"  title="Notes" showOKButton="false" runat="server" />
    </span>
  </p>
  
  <p>    
    <span class="center-field">I herby attest by submitting my response that :</span>
  </p>

  <div class="response-attest-statement"><%=sar.currChainResponseAttestStatement%></div>

   <p>
     <span class="center-field">
       <Spedmon:Button ID="butSaveResp" onclick="saveResponse();" runat="server">Submit My Response</Spedmon:Button>      
     </span>
   </p>  
  
   <p>
    <Spedmon:DetailList ID="validatelist" runat="server"></Spedmon:DetailList>
   </p>
      
</form>

<script type="text/javascript" charset="utf-8">

    var $frm;
    var $st;
    var $vld;
    
    $(window).on('load', function () {
       $frm = $('#frmsvcauthrequestresponse');
       $st  = $('#validatelist');
       $vld = $('#validaterec');
       return;
    });

    var fnHideFormThenRefreshParent = function (respData) {
        $($frm).hide();
        var parentWindow = window.parent; 
        parentWindow.refreshAll();
        parentWindow.processResponseScreenFormResponseData(respData);
    };
    
    function callSaveMethod (validate, fnSuccess) {
      $($vld).val(validate);     
      $.spedmonWebUI.ajaxFrm($frm, null, 'json_synch', null, $st, fnSuccess);
    };
    
    function validateResponse() {
      callSaveMethod (1, null);
    };

    function saveResponse() {
        //procRespSuccess($resp.data);
        callSaveMethod(0, fnHideFormThenRefreshParent);      
    };

 function reqSvcIs(oldval, newval) {
  if (newval == 3000)
    $('#effectivedaterow').show();
  else if (newval == 4000)
    $('#effectivedaterow').hide();
  else
    $('#effectivedaterow').show();
  };
</script>

<%} else {%>
<p>
Please click <a id="downloadorppaperauthform" href="#">here</a> to download a copy of this form to have completed by the <%=sar.reqSvcAuthFromSelectionName%>.
</p>
<p>
Please click <a href="<%=urlPaperFormUpload%>" target="_blank">here</a> to upload the completed form.
</p>

<script>
    /* Setup download link for orp doc for parents*/
    $(window).on('load', function () {
        $('#downloadorppaperauthform').on('click', function (e) {
          let frmUrl = '<%=urlPaperFormDownload%>';
          $.spedmonWebUI.downloadDynamicURL(frmUrl);        
          return false;
    });
});
</script>
<%}%>
<%}%>
</div>

</main>

