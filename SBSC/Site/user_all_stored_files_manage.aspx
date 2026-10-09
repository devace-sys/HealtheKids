<%@ Page Language="C#" CodeBehind="user_all_stored_files_manage.aspx.cs" Inherits="Spedmon.UserAllStoredFilesManage"%>


<div id="dataManagementRows" class="container-fluid">    
  

<div class="row">

<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%// (Practi-Cal staff only) %>
<%//-----------------------------------------------------------------------------%>

<div class="col-auto">

<Spedmon:DataEntryRowSelectClient
        ID                   = "selectClient" 
        entityControlID      = "clientid"                
        rowLabel             = "Client"
        dataEntryRowRenderAs = "FIELD"
        runat                = "server">
</Spedmon:DataEntryRowSelectClient>

</div> <!-- col -->               

</div>

<div class="row">
        
<%//-----------------------------------------------------------------------------%>
<%// Upload Date Range %>
<%//-----------------------------------------------------------------------------%>

<div class="col">
  <div class="d-flex justify-content-start">
    <Spedmon:DateBoxRange ID="daterange" name="daterange" value="" title="Upload Dates" showOK="false" runat="server" />
  </div>
</div>

<%//-----------------------------------------------------------------------------%>
<%// File Class %>
<%//-----------------------------------------------------------------------------%>

<div class="col">
  <div class="d-flex justify-content-center">
    <Spedmon:ComboBox ID="fileclass" name="fileclass" value="" title="Select Information In File" dataPrivate="true" dataURL="fileclasses.asmx/viewSel" runat="server" /> 
  </div>
</div> <!-- col -->    

<%//-----------------------------------------------------------------------------%>
<%// Select Patient %>
<%//-----------------------------------------------------------------------------%>

<div class="col">
<div class="d-flex justify-content-center">
<Spedmon:DataEntryRowSelectPatient
    ID                                 = "selectPatient" 
    rowLabel                           = "Associated Patient?" 
    dataEntryRowRenderAs               = "FIELD"
    preSelectedDataSource              = "ALL_PATIENTS"
    showDataSourceSelection            = "false"    
    saveDataSourceSelectedAsPreference = "false"
    runat                              = "server">
</Spedmon:DataEntryRowSelectPatient>
</div>
</div> <!--col -->

<%//-----------------------------------------------------------------------------%>
<%// Send Us A File (Misc) %>
<%// Client Use Only %>
<%//-----------------------------------------------------------------------------%>

<%if (isPCalStaff == false) {%>
<div class="col"> 
<div class="d-flex justify-content-end">
    <Spedmon:DataEntryButton ID="butSendMiscFile" style="INFO" fireSpedmonInput="false" faIcon="fas fa-upload" label="Send Us A File (Misc)" title="Send us a misc file" onclick="doSendMiscFile()"  runat="server"/>  
</div>      
</div> <!-- col -->
<%}%>

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
      , showPatientName: true
      , webSvcFlagAsNonConfidentialUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_FLAG_AS_NON_CONFIDENTIAL()%>'
      , webSvcFlagAsConfidentialUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_FLAG_AS_CONFIDENTIAL()%>'
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

    function doSendMiscFile() {

        let fileAdditionalDataJSONStr = '{}';
        let fnCloseSuccess = function () {
            MBA.StoredFilesCommon.fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer($me);
        };

        $.spedmonWebUI.fileUploadMultiple('Send Us A File (Misc)'
            , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
            , '<%=MBA.StoredFiles.FILE_CLASS_MISC%>'
            , ''
            , 'misc'
            , ''
            , fileAdditionalDataJSONStr
            , true
            , fnCloseSuccess
            , false /* Confidential */
        );
    };
</script>