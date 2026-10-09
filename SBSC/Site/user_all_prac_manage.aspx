<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_prac_manage.aspx.cs" Inherits="Spedmon.userAllPracManage" %>
 
<div class="container-fluid"> 
  <div class="row">
    <div class="col-12">

      <%//-----------------------------------------------------------------------------%>
      <%// Select Client %>
      <%//-----------------------------------------------------------------------------%>

       <Spedmon:DataEntryRowSelectClient
            ID                   = "selectClient" 
            entityControlID      = "clientid"                
            rowLabel             = "Client?" 
            onSpedmonInputData   = "resetPracSelectionAndFireChangeEvent();"
            dataEntryRowRenderAs = "FIELD"
            selectTitle          = "Enter Name"
            showClearSelection   = "true"
            runat                = "server">
       </Spedmon:DataEntryRowSelectClient>
    
       <%//-----------------------------------------------------------------------------%>
       <%// Select Practitioner %>
       <%//-----------------------------------------------------------------------------%>

        <Spedmon:DataEntryRowSelectPractitioner
            ID                                 = "selectPractitioner" 
            entityControlID                    = "pracid"                
            rowLabel                           = "Practitioner (Last,First)?" 
            selectTitle                        = "Enter Last, First"
            preSelectedDataSource              = "ALL_PRACTITIONERS"
            showDataSourceSelection            = "true"
            onSpedmonInputData                 = "triggerChangeEventForPrac();"
            dataEntryRowRenderAs               = "FIELD"            
            runat                              = "server">
          </Spedmon:DataEntryRowSelectPractitioner>

        
         <%//-----------------------------------------------------------------------------%>
         <%// Missing or Expired Quals Report (if user is allowed to see them)            %>
         <%//-----------------------------------------------------------------------------%>

          <%if (showDownloadMissingOrExpiredQualsRpt == true) {%>
            <Spedmon:DataEntryButton ID="doDownloadExpiredOrMissingQuals" faIcon="fa fa-file-excel" style="WARNING" size="SMALL" cssClass="ml-1" fireSpedmonInput="false"  label="Expired or Missing Qualifications" title="Click to download.  You can run this for a selected client or all active clients." onclick="downloadExpiredOrMissingQualsReport(e)" runat="server"/>
          <%}%>

         <%//-----------------------------------------------------------------------------%>
         <%// CYBHI Program Export Options (if user is allowed to see them)               %>
         <%//-----------------------------------------------------------------------------%>

          <%if (showCybhiOptions == true) { %>   
            <span class="ml-1 mr-1">CYBHI</span>
            <Spedmon:DataEntryButton ID="doDownloadCybhiPracsTPAExport" faIcon="fa fa-file" style="PRIMARY" size="SMALL" cssClass="mr-1" fireSpedmonInput="false" label="TPA Export" title="Click to download.  Please note that the export will only include practitioners that have ALL required fields for the TPA export" onclick="downloadCybhiPracsTPAExport(e)" runat="server"/>
            <Spedmon:DataEntryButton ID="doDownloadCybhiPracsAudit" faIcon="fa fa-file-excel" style="SECONDARY" size="SMALL" cssClass="mr-1" fireSpedmonInput="false"  label="Audit" title="Click to download." onclick="downloadCybhiPracsAuditRpt(e)" runat="server"/>
            <Spedmon:DataEntryButton ID="doProcessTpaReturnFile" faIcon="fa fa-upload" style="INFO" size="SMALL" fireSpedmonInput="false"  label="Process TPA Return File" title="Click to process return file." onclick="doOpenProcessCybhiPracReturnFile(e)" runat="server"/> 
          <%}%>
        
       </div> <!-- col -->
  </div> <!-- row -->
    
  <%//-----------------------------------------------------------------------------%>
  <%// Add/Edit/View                                                               %>
  <%//-----------------------------------------------------------------------------%>

  <Spedmon:DataEntryRowIframeContentEntitySaveOrView
        ID                    ="pracIframeContent"
        addNewReqFieldIDs     ="clientid"
        addNewReqParamNames   ="clientid"
        editReqFieldIDs       ="pracid"
        editReqParamNames     ="recid"
        viewReqFieldIDs       ="clientid"
        viewReqParamNames     ="clientid"
        iFrameResetFieldNames ="clientid"
        editFieldID           ="pracid"
        fnCustomAddNew        ="function(){ return checkForClientID(); }"
        fnCustomView          ="function(){ return checkForClientID(); }"
        hasAddNew             ="true"
        hasEdit               ="true"
        hasView               ="true"
        runat                 ="server">

    </Spedmon:DataEntryRowIframeContentEntitySaveOrView>
</div> <!-- container -->

<script type="text/javascript" charset="utf-8">


    $(
      function() {
        $('iframe.mba-data-entry-row-iframe-content').attr(
          'src',
          '<%= iframePrefill %>'
        );
      }
    );

    // makes sure client id is selected when trying to add new record or view
    function checkForClientID() {
        // retrieve and validate client selection
        let clientID = $('#clientid').val();
        if (!clientID || clientID == 0 || clientID == '0') {
            $('#clientid_all_cont').effect("shake", { distance: 7, times: 4 }, 50).mbaHighlight({ color: '#fcf75e', duration: 500 });
            return false;
        }

        return true;
    }

    // trigger a change event when prac is selected so the iFrame component catches it and launches edit
    function triggerChangeEventForPrac() {
        $('#pracid').trigger('change');
    }

    // reset prac selection display
    function resetPracSelectionAndFireChangeEvent() {
        $('#pracid_selection').val('');
        $('#clientid').trigger('change');
    }

    <%if (showDownloadMissingOrExpiredQualsRpt == true) {%>

    function downloadExpiredOrMissingQualsReport(e) {
        
        let elem   = e.target;
        let rptNum = <%=Spedmon.PractitionersRpt.RPT_QUALS_MISSING_OR_EXPIRED%>;
        let rptFmt = 3; /* Excel */

        let reqUrl = '<%=Spedmon.Practitioners.URL_WEB_REPORT_BASE()%>';

        let reqData = [
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_CLIENT_ID%>", $("#<%=Constants.PARM_CLIENT_ID%>").val())
        ];

        MBA.ComponentCommon.fnElemDoRequestDownloadWebReportDocument(elem, reqUrl, rptFmt, rptNum, 'Missing_Or_Expired_Prac_Quals_Rpt_' + rptNum + '_' + rptFmt, reqData
            , function () { return; }
            , function () { return; });
    };
    <%}%>

    <%if (showCybhiOptions == true) { %>

    function downloadCYBHIExport(e, rptNum, rptFmt) {
        if (!checkForClientID()) return;
        let elem = e.target;
        let reqUrl = '<%=Spedmon.Practitioners.URL_WEB_REPORT_BASE()%>';
        let reqData = [
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_CLIENT_ID%>", $("#<%=Constants.PARM_CLIENT_ID%>").val())
        ];
        MBA.ComponentCommon.fnElemDoRequestDownloadWebReportDocument(elem, reqUrl, rptFmt, rptNum, 'Cybhi_Rpt_' + rptNum + '_' + rptFmt, reqData
            , function () { return; }
            , function () { return; });
    };

    function doOpenProcessCybhiPracReturnFile(e) {
        checkForClientID();
        let _clientid = $('#clientid').val();
        let urlBase = '<%=Spedmon.Practitioners.URL_CYBHI_PROCESS_FILE_BASE()%>'
        let parms = [];
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject('clientid', _clientid));
        let reqUrl = MBA.ComponentCommon.fnBuildUrl(urlBase, true, parms);
        return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
    };

    function downloadCybhiPracsTPAExport(e) {
        let rptNum = <%=Spedmon.PractitionersRpt.RPT_CYBHI_PRACS_TPA_EXPORT%>;
        let rptFmt = 10; /* Pipe delimited */
        downloadCYBHIExport(e, rptNum, rptFmt);
    };

    function downloadCybhiPracsAuditRpt(e) {
        let rptNum = <%=Spedmon.PractitionersRpt.RPT_CYBHI_PRACS_AUDIT%>;
        let rptFmt = 3; /* Excel */
        downloadCYBHIExport(e, rptNum, rptFmt);
    };
    <%}%>

</script>