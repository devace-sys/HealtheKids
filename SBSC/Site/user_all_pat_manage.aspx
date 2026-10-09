<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_pat_manage.aspx.cs" Inherits="Spedmon.userAllPatManage" %>

<div class="container-fluid">
  
  <div class="row">
    <div class="col-12">

      <%//-----------------------------------------------------------------------------%>
      <%// Select Client %>
      <%//-----------------------------------------------------------------------------%>
    
      <Spedmon:DataEntryRowSelectClient
            ID                   = "selectClient" 
            entityControlID      = "clientid"                
            rowLabel             = "Client"
            onSpedmonInputData   = "resetPatSelectionAndFireChangeEvent();"
            dataEntryRowRenderAs = "FIELD"
            selectTitle          = "Enter Name"
            runat                = "server">
      </Spedmon:DataEntryRowSelectClient>
  
      <%//-----------------------------------------------------------------------------%>
      <%// Select Patient %>
      <%//-----------------------------------------------------------------------------%>
     
      <Spedmon:DataEntryRowSelectPatient
            ID                   = "selectPatient" 
            entityControlID      = "patid"  
            rowLabel             = "Patient (Last,First)"
            dataEntryRowRenderAs = "FIELD"
            selectTitle          = "Enter Last, First"
            onSpedmonInputData   = "triggerChangeEventForPat();"
            runat                = "server">
      </Spedmon:DataEntryRowSelectPatient>
   
      <%//-----------------------------------------------------------------------------%>
      <%// CYBHI Program Export Options (if user is allowed to see them)               %>
      <%//-----------------------------------------------------------------------------%>

      <%if (showCybhiOptions == true) { %>          
        <Spedmon:DataEntryButton ID="doDownloadCybhiPatsTPAExport" faIcon="fa fa-file-excel" style="PRIMARY" size="SMALL" cssClass="mr-1" fireSpedmonInput="false" label="CYBHI TPA Patients Export" title="Click to download.  Please note that the export will only include patients that have ALL required fields for the TPA export." onclick="downloadCybhiPatsExport(e)" runat="server"/>
        <Spedmon:DataEntryButton ID="doDownloadCybhiPatsTPAExportFixed" faIcon="fa fa-file" style="PRIMARY" size="SMALL" cssClass="mr-1" fireSpedmonInput="false" label="CYBHI TPA Patients Direct Export" title="Click to download.  Please note that the export will only include patients that have ALL required fields for the TPA export." onclick="downloadCybhiPatsExportFixed(e)" runat="server"/>
        <Spedmon:DataEntryButton ID="doDownloadCybhiPatsAudit" faIcon="fa fa-file-excel" style="SECONDARY" size="SMALL" cssClass="mr-1" fireSpedmonInput="false"  label="CYBHI Patients Audit" title="Click to download." onclick="downloadCybhiPatsAuditRpt(e)" runat="server"/> 
        <Spedmon:DataEntryButton ID="doProcessTpaReturnFile" faIcon="fa fa-upload" style="INFO" size="SMALL" fireSpedmonInput="false"  label="CYBHI Process Return File" title="Click to process return file." onclick="doOpenProcessCybhiPatsReturnFile(e)" runat="server"/> 
     <%}%>
    </div> <!-- col -->
  </div> <!-- row -->

      
  <%//-----------------------------------------------------------------------------%>
  <%// Add/Edit/View                                                               %>
  <%//-----------------------------------------------------------------------------%>
  
  <Spedmon:DataEntryRowIframeContentEntitySaveOrView
        ID                    ="patIframeContent"
        addNewReqFieldIDs     ="clientid"
        addNewReqParamNames   ="clientid"
        editReqFieldIDs       ="patid"
        editReqParamNames     ="recid"
        viewReqFieldIDs       ="clientid"
        viewReqParamNames     ="clientid"
        iFrameResetFieldNames ="clientid"
        editFieldID           ="patid"
        fnCustomAddNew        ="function(){ return checkForClientID(); }"
        fnCustomView          ="function(){ return checkForClientID(); }"
        hasAddNew             ="true"
        hasEdit               ="true"
        hasView               ="true"
        runat                 ="server">

    </Spedmon:DataEntryRowIframeContentEntitySaveOrView>
</div>
<script type="text/javascript" charset="utf-8">

    // makes sure client id is selected when trying to add new record or view

    function checkForClientID() {
        // retrieve and validate client selection
        let clientID = $('#clientid').val();
        if (!clientID || clientID == 0 || clientID == '0') {
            $('#clientid_all_cont').effect("shake", { distance: 7, times: 4 }, 50);
            return false;
        }

        return true;
    }
    
    // trigger a change event when patient is selected so the iFrame component catches it and launches edit
    function triggerChangeEventForPat() {
        $('#patid').trigger('change');
    }
        
    // reset patient selection display
    function resetPatSelectionAndFireChangeEvent() {
        $('#patid_selection').val('');
        $('#clientid').trigger('change');
    }

    function doOpenProcessCybhiPatsReturnFile(e) {
        checkForClientID();
        let _clientid = $('#clientid').val();
        let urlBase = '<%=Spedmon.Patients.URL_CYBHI_PROCESS_FILE_BASE()%>'
        let parms = [];
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject('clientid', _clientid));
        let reqUrl = MBA.ComponentCommon.fnBuildUrl(urlBase, true, parms);
        return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
    };

    function downloadCYBHIExport(e, rptNum, rptFmt) {
        if (!checkForClientID()) return;
        let elem = e.target;
        let reqUrl = '<%=Spedmon.Patients.URL_WEB_REPORT_BASE()%>';
        let reqData = [
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_CLIENT_ID%>", $("#<%=Constants.PARM_CLIENT_ID%>").val())
        ];
        MBA.ComponentCommon.fnElemDoRequestDownloadWebReportDocument(elem, reqUrl, rptFmt, rptNum, 'Cybhi_Rpt_' + rptNum + '_' + rptFmt, reqData
            , function () { return; }
            , function () { return; });
    };

    function downloadCybhiPatsExport(e) {
        let rptNum = <%=Spedmon.PatientsRpt.RPT_CYBHI_PATS_EXPORT%>;
        let rptFmt = 9; /* CSV instead of Pipe delimited(10) */
        downloadCYBHIExport(e, rptNum, rptFmt);
    };

    function downloadCybhiPatsExportFixed(e) {
        let rptNum = <%=Spedmon.PatientsRpt.RPT_CYBHI_PATS_EXPORT_FIXED%>;
        let rptFmt = 11; /* Fixed width */
        downloadCYBHIExport(e, rptNum, rptFmt);
    };

    function downloadCybhiPatsAuditRpt(e) {
        let rptNum = <%=Spedmon.PatientsRpt.RPT_CYBHI_PATS_AUDIT%>;
        let rptFmt = 3; /* Excel */
        downloadCYBHIExport(e, rptNum, rptFmt);
    };

</script>