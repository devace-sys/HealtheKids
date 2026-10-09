<%@ Page Language="C#" CodeBehind="sbs_all_manage_service_name_form_data_fillable_pdf_files.aspx.cs" Inherits="Spedmon.SBSAllManageServiceNameFormDataFillablePdfFiles"%>
<%if(pageParmsOK == true){%>
<input type="hidden" id="daterange" name="daterange" />
<input type="hidden" id="fileclass" name="fileclass" value="<%=MBA.StoredFiles.FILE_CLASS_FILLABLE_PDF_FOR_SERVICE_REC_BLANK%>"/>
<input type="hidden" id="patid"     name="patid"/>

<div class="alert alert-warning text-center">
Do not delete files that have been assigned to service names.
</div>

<div id="dataManagementRows" class="container-fluid">
  
<div class="row">

<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%//-----------------------------------------------------------------------------%>

<div class="col-10">

<Spedmon:DataEntryRowSelectClient
        ID                   = "selectClient" 
        entityControlID      = "clientid"                
        rowLabel             = "Client"
        dataEntryRowRenderAs = "FIELD"
        showClearSelection   = "true"
        runat                = "server">
</Spedmon:DataEntryRowSelectClient>

</div> <!-- col -->               

<%//-----------------------------------------------------------------------------%>
<%// Upload %>
<%//-----------------------------------------------------------------------------%>

<div class="col-2"> 
  <div class="d-flex justify-content-end">
    <Spedmon:DataEntryButton ID="butSendMiscFile" style="INFO" fireSpedmonInput="false" faIcon="fas fa-upload" label="Add A New File" title="Add A New File" onclick="doSendNewFillablePDFFile()"  runat="server"/>
  </div>      
</div> <!-- col -->
</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Rest View  %>
<%//-----------------------------------------------------------------------------%>
  
<div id="restViewRow" class="row mt-3">
  <div class="col-12">
    <div id="restView">
    </div>
  </div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    let $me = null;

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function initStoredFilesView() {

      let optsObj = {
        PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
      , PARM_NAME_DATE_RANGE: '<%=Constants.PARM_DATE_RANGE%>'
      , PARM_NAME_FILE_CLASS: '<%=Constants.PARM_FILE_CLASS%>'
      , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
      , PARM_NAME_FILE_ID: '<%=Spedmon.StoredFiles.PARAM_FILE_ID%>'
      , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
      , containerCtrlID: 'dataManagementRows'
      , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
      , baseUrlView: '<%=Spedmon.StoredFiles.URL_REST_VIEW_BASE()%>'
      , defaultPageRowOrder: '<%=Spedmon.StoredFile.DEFAULT_PAGING_ORDER%>'
      , baseUrlDelete: '<%=Spedmon.StoredFiles.URL_WEB_SVC_DELETE()%>'
      , baseUrlReport: '<%=Spedmon.StoredFiles.URL_WEB_REPORT_BASE()%>'
      , defaultReportNumber: '<%=Spedmon.StoredFilesRpt.REPT_NUM_VIEW%>'
      , autoHidePageControls: false
      , enableScrollView: false
      , scrollViewUseCustomHeight: true
      , scrollViewCustomHeight: '20em'    
      , isPcalStaff:<%=isPcalStaffJSBoolStr%>
      , showPatientName: false
      , webSvcFlagAsNonConfidentialUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_FLAG_AS_NON_CONFIDENTIAL()%>'
      , webSvcFlagAsConfidentialUrl: '<%=Spedmon.StoredFiles.URL_WEB_SVC_FLAG_AS_CONFIDENTIAL()%>'
      , webSvcEnableSharingWithPatientUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_ENABLE_SHARING_WITH_PATIENT()%>'
      , webSvcDisableSharingWithPatientUrl: '<%=Spedmon.StoredFiles.URL_WEB_SVC_DISABLE_SHARING_WITH_PATIENT()%>'
      , webSvcEnableSharingWithParentUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_ENABLE_SHARING_WITH_PARENT()%>'
      , webSvcDisableSharingWithParentUrl: '<%=Spedmon.StoredFiles.URL_WEB_SVC_DISABLE_SHARING_WITH_PARENT()%>'
      , currUserID: <%=rd.wu.usr.id%>
      , downloadHandlerPrivateBaseUrl: '<%=Spedmon.StoredFiles.URL_DOWNLOAD_HANDLER_PRIVATE_BASE()%>'
      , showOKToShareWithPatient: false
      , showOKToShareWithParentGuardian: false
    };

    $me = MBA.StoredFilesCommon.fnSetup('restView', optsObj);
    return;
  };

  /*---------------------------------------------------------------------------------------------------------------------------------*/

    $(document).ready(function () {
        initStoredFilesView();      
    });

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function doSendNewFillablePDFFile() {

        let cid = $('#<%=Constants.PARM_CLIENT_ID%>').val();
        if (!cid) {
            MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Client Selection Required', 'Please select a client', {});
            return;
        }
        let fileAdditionalDataObj = {};
        fileAdditionalDataObj['<%=Constants.PARM_CLIENT_ID%>'] = cid;
        let fileAdditionalDataJSONStr = JSON.stringify(fileAdditionalDataObj);

        let fnCloseSuccess = function () {
            MBA.StoredFilesCommon.fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer($me);
        };

        $.spedmonWebUI.fileUpload('Upload New Fillable PDF'
            , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
            , '<%=MBA.StoredFiles.FILE_CLASS_FILLABLE_PDF_FOR_SERVICE_REC_BLANK%>'
            , ''
            , ''
            , ''
            , fileAdditionalDataJSONStr
            , true
            , fnCloseSuccess
            , false /* Confidential */
        );
    };
</script>
<%} else {%>
<div class="alert alert-danger text-center">
Please select a client then try again
</div>
<%}%>