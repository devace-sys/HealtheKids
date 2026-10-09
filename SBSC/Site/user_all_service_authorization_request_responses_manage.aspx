<%@ Page Language="C#" CodeBehind="user_all_service_authorization_request_responses_manage.aspx.cs" Inherits="Spedmon.UserAllServiceAuthorizationRequestResponsesManage" %>

<div class="container-fluid">

<Spedmon:DataViewRequestForm
    id                        = "dvauthreqreqfrm"
    dataViewRecordsViewCtrlID = "dvauthreqrecview"
    dataURL                   = "service_authorization_requests.ashx"
    onSpedmonInputData        = "unloadRequest()"
    cssClass                  = "row"
    runat                     = "server">

  <div class="col-4">

  <div id="filteroptions" class="request-form-options">
    
   <script type="text/javascript" charset="utf-8">

       function onSelectResponseValue (oldval, newval) {
           $('#closed').val('0');
           if      (newval == 4000) { /* Declined */ $('#closed').val('0'); }
           else if (newval == 3000) { /* Approved */ $('#closed').val('1'); }
           else if (newval == 2000) { /* Pending */  $('#closed').val('0'); }
           else                     { $('#closed').val('0'); }
           return true;
       };
   </script>

   <Spedmon:HiddenInput ID="closed" name="closed" title="closed" value="0" runat="server"/>

   <Spedmon:SelectRequestServiceAuthorizationResponse 
    id                    = "responsecode" 
    name                  = "responsecode" 
    title                 = "Show"
    showPendingOption     = "true"
    selectionTextApproved = "Approved"
    selectionTextDeclined = "Declined"
    onSelectValue         = "function(oldval,newval) { onSelectResponseValue(oldval, newval); return true;}"
    value                 = "PENDING"
    runat                 = "server"/>
  


  </div>
  </div>
  <div class="col-8">
  <div class="request-form-options">
    <label class="mba-web-ui mba-web-ui-inline">Or: </label>
    <Spedmon:NumberBox ID="requestid" name="requestid" title="Enter Request ID" showOK="false" showControls="false"  runat="server" />
    <Spedmon:Button ID="butfindrequestbyid" onclick="doFindRequestByID()" runat="server">Find Service Authorization Request By ID</Spedmon:Button>
    <Spedmon:Button ID="butclearfind" onclick="doClearFind()" runat="server">Resume Using Filter</Spedmon:Button>  
  </div>
  </div>
</Spedmon:DataViewRequestForm>


<div class="row">

<div class="col-4">


<Spedmon:DataViewRecordsView
    id                        = "dvauthreqrecview" 
    dataViewRequestFormCtrlID = "dvauthreqreqfrm"
    recIDPos                  = "2"
    onSelect                  = "loadRequest(oSelRowData)"
    cssClass                  = "section-content"    
    runat                     = "server">
</Spedmon:DataViewRecordsView>


</div> <!-- col -->

<div class="col-8">

<div class="frame-wrapper">
<iframe 
    id="<%=Spedmon.ServiceAuthorizationRequestResponses.IFRAME_RESPONSE_SAVE_ID%>" 
    name="<%=Spedmon.ServiceAuthorizationRequestResponses.IFRAME_RESPONSE_SAVE_ID%>" 
    class="frame-content"
    src="about:blank">
</iframe>
</div>
</div> <!- col -->

</div> <!- row -->
</div>

<script type="text/javascript" charset="utf-8">

    function setRequestSrc(reqUrl) {
        $('#<%=Spedmon.ServiceAuthorizationRequestResponses.IFRAME_RESPONSE_SAVE_ID%>').attr('src', reqUrl);
    };

    function unloadRequest () {        
        setRequestSrc('about:blank');
    }

    function loadRequest(oSelRowData) { 
        var reqUrl = '<%= requestResponseBaseUrl%>' + oSelRowData.recID;
        setRequestSrc(reqUrl);
    }

    function refreshRecordList() {
       var $dataViewRecordsViewCtrlData = $('#dvauthreqrecview').data('spedmonDataViewRecordsView');
       $dataViewRecordsViewCtrlData.fnRefresh();
    }

    function refreshAll() {
        unloadRequest();
        refreshRecordList();
    }

    function processResponseScreenFormResponseData(respData) {
        var r1 = JSON.parse(respData.jsonData);
        if (r1.userNeedsToDownloadRequest == true)
        {                    
          
          var downloadFormMessage = '<div class="download-request-form-dialog-content">'
                                   + '<a href="' + r1.userNeedsToDownloadRequestURL + '" target="_blank" download>Click Here To Download Form</a>'
                                   + r1.userNeedsToDownloadRequestDialogContent
                                   + '</div>'
          var fnOpen = function () { };
          $.spedmonWebUI.dialogMessage(r1.userNeedsToDownloadRequestDialogTitle, downloadFormMessage, true, 400, 400, null,fnOpen);
        }        
    }

    function doFindRequestByID() {
        var reqid = $('#requestid').val();
        if (reqid) {
            $('#filteroptions').hide();
            $('#butclearfind').show();
        }
        else {
            $('#filteroptions').show();
            $('#butclearfind').hide();
        }
        refreshAll();
    }

    function doClearFind() {
        $('#requestid').val(null);
        doFindRequestByID();
    }


$('#butclearfind').hide();
</script>
