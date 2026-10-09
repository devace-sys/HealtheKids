<%@ Page Language="C#" CodeBehind="user_all_cde_compliance_manage_for_selpa.aspx.cs" Inherits="Spedmon.UserAllCdeComplianceManageForSelpa"%>

<%//##################################################################################################################%>
<%//# Instructions Content  %>
<%//##################################################################################################################%>

<!-- CDE Compliance Buckets Summary -->

<div id="cdecompliancebucketssummaryinstructions" class="mba-action-item-common-instructions-definition">
<p>This is a metric that the <a href="https://www.cde.ca.gov/" target="_blank" style="color:#000;">California Department of Education (CDE)</a> is proposing to use to determine a districts compliance with delivering ALL services that are promised to patients within a given period.</p>
<p>The period currently used for this chart is from <%=currentWindowStartDateStr%> to <%=currentWindowEndDateStr%>.</p>
<ul>    
<li>Hovering over each section will display the number of students included in the percentage calculation.</li>
<li>Clicking the legend labels will toggle the sections of the pie chart on and off.</li>
</ul>
</div>

<!-- CDE Compliance Buckets Summary By Svc -->

<div id="cdecompliancebucketssummarybysvcinstructions" class="mba-action-item-common-instructions-definition">
<p>This shows the percentage of completion for each service that your district has promised to provide patients within a given period.</p>
<p>The period currently used for this chart is <%=currentWindowStartDateStr%> to <%=currentWindowEndDateStr%>.</p>
<ul>
<li>Hovering over a service title will display the number of students this service has been promised.</li>
<li>Hovering over the percentage amount will display the number of minutes promised and the number of minutes satisfied.</li>
<li>Clicking on a service title will open a new window that displays a detail report.</li>
</ul>
</div>

<%//##################################################################################################################%>
<%//# Select Selpa & Export Options  %>
<%//##################################################################################################################%>

<div id="selpasummaryrows" class="container-fluid">

<div class="row">
    
    <%//-----------------------------------------------------------------------------%>
    <%// Select SELPA  %>
    <%// (Practi-Cal staff only) %>
    <%//-----------------------------------------------------------------------------%>
    
     <div class="col-auto">

      <Spedmon:DataEntryRowSelectSELPA
          ID                    = "selectSelpa" 
          rowLabel              = "SELPA"
          dataEntryRowRenderAs  = "FIELD"
          runat                 = "server">
      </Spedmon:DataEntryRowSelectSELPA>


    </div> <!-- col -->
    
   </div> <!-- row -->
 
   <div class="row">
         
      <%//-----------------------------------------------------------------------------%>
      <%// Summary Chart  %>
      <%//-----------------------------------------------------------------------------%>
  
      <div class="col-7">
        <section id="cdecompliancebucketssummary"></section>
      </div> <!-- col -->  
  
      <%//-----------------------------------------------------------------------------%>
      <%// Sections TOC   %>
      <%//-----------------------------------------------------------------------------%>
  
      <div class="col-5">
        
        <div class="mba-action-items-container p-2">
        <h3 class="mba-action-item-common mba-action-item-common-label">Click on a district to scroll to details</h3>
        <ul id="clientdetailstoc"></ul>
        </div> <!-- action item -->
        
        <br>

        <div class="mba-action-items-container p-2">
        <h3 class="mba-action-item-common mba-action-item-common-label">Export Data for SELPA</h3>
          
          <div class="alert alert-info mr-1">Please note that this date range is only used for the download options and the CSV download is the recommended option for data exports.</div>
          
          <span style="display:inline-block;">
          <Spedmon:DateBoxRange ID="daterange" name="daterange" title="Export Data for Dates of Service" showOK="false" runat="server" />          
          </span>

          <button type="button" id="butDoExportXLS" class="btn btn-info mr-1">
          <span id="lblDoExportXLS">Download Excel </span>
          <i id="iconDoExportXLS" class="fa fa-file-excel"></i>
          </button>
          
          <button type="button" id="butDoExportCSV" class="btn btn-info ml-1">
            <span id="lblDoExportCSV">Download CSV </span>
            <i id="iconDoExportCSV" class="fa fa-file-csv"></i>
          </button>
         </div> <!-- action item -->

      </div> <!-- col -->  
  

  </div> <!-- row -->

</div> <!-- container -->

<%//##################################################################################################################%>
<%//# Detail Rows  %>
<%//##################################################################################################################%>

<div id="clientdetailsrows" class="container-fluid">    
  
</div> <!-- container -->


<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    const PARM_NAME_SELPA_CODE                         = '<%=Constants.PARM_SELPA_CODE%>';
    const PARM_NAME_CLIENT_ID                          = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_PAT_ABSENT_MINS_ARE_SATISFIED_MINS = '<%=Constants.PARM_PAT_ABSENT_MINS_ARE_SATISFIED_MINS%>';

    const URL_SESSION_EXPIRED_LINK  = '<%=MBA.Credential.generateSessionExpiredLink()%>';

    let $dashboardItemCdeComplianceBucketsSummaryInstructions      = null;
    let $dashboardItemCdeComplianceBucketsSummaryBySvcInstructions = null;
    let $selpaSummaryRows  = null;
    let $butDoExportCSV    = null;
    let $iconDoExportCSV   = null;
    let $dashboardRows     = null;
    
    let $dashboardItemCdeComplianceBucketsSummary = null;
    let $clientDetailsToc                         = null;
    let $clientDetailsRows                        = null;

<%//##################################################################################################################%>

    function doExport($butDoExport, $iconDoExport, rptFmt, rptCookieName) {

        $($butDoExport).prop('disabled', true);

        let $waitingIcon = $('<i class="fa fa-spinner fa-pulse fa-fw m-auto"></i>');
        $waitingIcon.insertAfter($iconDoExport);

        let reqUrl = '<%=Spedmon.ServiceRecords.URL_WEB_REPORT_BASE()%>';

        let reqData = [
          MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_SELPA_CODE%>", $("#<%=Constants.PARM_SELPA_CODE%>").val()),
          MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_DATE_RANGE%>" , $("#<%=Constants.PARM_DATE_RANGE%>").val()),
        ];
            
        MBA.ComponentCommon.fnRequestDownloadWebReportDocument (
                  reqUrl
                , rptFmt
              , <%=Spedmon.ServiceRecordsRpt.REPT_SELPA_EXPORT_FOR_SELPA%>
                , rptCookieName
              , reqData
              , function () {
                  $($butDoExport).prop('disabled', false); $waitingIcon.remove();
              }
              , function () {
                  $($butDoExport).prop('disabled', false); $waitingIcon.remove();
              }
          );
    }

<%//##################################################################################################################%>

    function doExportCSV() {        
        doExport($butDoExportCSV, $iconDoExportCSV, <%=Constants.REPT_FORMAT_CSV%>, 'Rpt_Selpa_Export_For_Selpa_CSV');
    }

<%//##################################################################################################################%>

    function doExportXLS() {
        doExport($butDoExportXLS, $iconDoExportXLS, <%=Constants.REPT_FORMAT_XLS%>, 'Rpt_Selpa_Export_For_Selpa_XLS');
    }

<%//##################################################################################################################%>

    function getNameValuePatAbsentMinsAreSatisfiedMins() {
        let VALUE_PAT_ABSENT_MINS_ARE_SATISFIED_MINS = $('#' + PARM_NAME_PAT_ABSENT_MINS_ARE_SATISFIED_MINS).val();
        return MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PAT_ABSENT_MINS_ARE_SATISFIED_MINS, VALUE_PAT_ABSENT_MINS_ARE_SATISFIED_MINS);
    }

<%//##################################################################################################################%>

    function generateDashBoardItemCdeComplianceBucketsSummaryForClient (bucketSummaryChart, relatedClient) {
        let opts = {};
        opts.label = '<%=Spedmon.CdeComplianceCommon.LABEL_SUCCESS_BUCKETS%>' + ' - ' + relatedClient.clientName;
        opts.showCurrYear = true;
        opts.showCurrAudit = true;
        
        opts.requestDataUrlCurrYearBase = '<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_YEAR_GET()%>';
        opts.requestDataUrlCurrAuditBase = '<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_GET()%>';

        opts.rowLabelCurrAudit    = '<%=Spedmon.CdeComplianceCommon.SEL_LABEL_CURRENT_AUDIT%><br>For CDE Audit Period ';
        opts.rowLabelCurrYear     = '<%=Spedmon.CdeComplianceCommon.SEL_LABEL_ANNUAL%><br>For All Plans Active Between ';
        opts.colLabelBucketLabelA = '<%=Spedmon.CdeComplianceCommon.LABEL_BUCKET_A_LINES(@"<br>")%>';
        opts.colLabelBucketLabelB = '<%=Spedmon.CdeComplianceCommon.LABEL_BUCKET_B_LINES(@"<br>")%>';
        opts.colLabelBucketLabelC = '<%=Spedmon.CdeComplianceCommon.LABEL_BUCKET_C_LINES(@"<br>")%>';
        opts.colLabelTotPatsLabel = '<%=Spedmon.CdeComplianceCommon.LABEL_BUCKET_TOTAL_STUDENTS_LINES(@"<br>")%>';
        
        let _nvpClientIDObj = MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID,relatedClient.clientID);
        let NV_PAT_ABSENT_MINS_ARE_SATISFIED_MINS = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PAT_ABSENT_MINS_ARE_SATISFIED_MINS, '0'); /* TODO: Hardcoded for now to NOT count absent as satisfied.  Change to ctrl refefence if needed later. */

        $(bucketSummaryChart).MBA_ActionItemCdeComplianceBuckets(opts);
        $(bucketSummaryChart).MBA_ActionItemCdeComplianceBuckets('requestDataParameterSetOrUpdate', _nvpClientIDObj);
        $(bucketSummaryChart).MBA_ActionItemCdeComplianceBuckets('requestDataParameterSetOrUpdate', NV_PAT_ABSENT_MINS_ARE_SATISFIED_MINS);
        $(bucketSummaryChart).MBA_ActionItemCdeComplianceBuckets('getData');

    }

<%//##################################################################################################################%>

    function generateDashBoardItemCdeComplianceBucketsSummaryBySvcForClient(bucketSummaryBySvcChart, relatedClient) {
        let opts = {};
        opts.label = 'CDE Implementation By CALPADS Service - ' + relatedClient.clientName;
        opts.urlSessionExpiredLink = URL_SESSION_EXPIRED_LINK;
        opts.requestDataUrlBase = '<%=Spedmon.CdeComplianceCommon.WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_BY_SVC()%>';
        opts.autoSetUpdateRequestDataParametersFromRequestDataFieldNames = false;
        opts.instructionsEnabled = true;
        opts.instructionsPosition = 'bottom-left';
        opts.instructionsContent = $($dashboardItemCdeComplianceBucketsSummaryBySvcInstructions).html();
        opts.title = 'CALPADS Services';
        opts.subTitleProgressLabel = 'CALPADS Service'
        opts.subTitleProgressBar = 'Percentage';
        opts.progressDataHasActionURL = true;

        opts.fnGenerateProgressLabelTitleAttributeText = function (progressDataObj) {
            return 'Number of patients who have this service in their special education plan : '
                + progressDataObj.additionalData1 + '.'
                + '<br>Click for more details.';
        };

        opts.fnGenerateProgressBarTitleAttributeText = function (progressDataObj) {
            return progressDataObj.value + '% of expected minutes to date have been provided.';
        };

        opts.fnGenerateProgressPercentTitleAttributeText = function (progressDataObj) {
            return 'Total number of minutes satisfied to date / expected to date : '
                + progressDataObj.additionalData3
                + ' / '
                + progressDataObj.additionalData2;
        };

        $(bucketSummaryBySvcChart).MBA_ActionItemProgressBarChart(opts);
        let _nvpClientIDObj = MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, relatedClient.clientID);
        $(bucketSummaryBySvcChart).MBA_ActionItemProgressBarChart('requestDataParameterSetOrUpdate', _nvpClientIDObj);
        $(bucketSummaryBySvcChart).MBA_ActionItemProgressBarChart('getData');        
    }

<%//##################################################################################################################%>


    function generateRelatedClientTocEntry (relatedClientSectionID, relatedClient) {
      var $relatedClientTocEntry = $('<li><a href="#' + relatedClientSectionID + '"><h4>' + relatedClient.clientName + '</h4></a></li>');
      return $relatedClientTocEntry;
    }

<%//##################################################################################################################%>

    function generateRelatedClientSectionRow (relatedClientSectionID, relatedClient) {

        let relatedClientBucketSummaryChartID          = 'cdecompliancebucketssummary-'      + relatedClient.clientID;
        let relatedClientBucketSummaryByServiceChartID = 'cdecompliancebucketssummarybysvc-' + relatedClient.clientID;

        let $relatedClientSectionColHeader = $('<div class="col-4 p-2"></div>');
        let $relatedClientSectionHeader = $('<h2 class="text-center">' + relatedClient.clientName + '</h4>');
        $($relatedClientSectionHeader).attr('id', relatedClientSectionID);

        $($relatedClientSectionColHeader).append($relatedClientSectionHeader);

        let $relatedClientSectionCol1 = $('<div class="col-8 p-2"></div>');

        let $relatedClientBucketSummaryChart = $('<section></section>');
        $($relatedClientBucketSummaryChart).attr('id',relatedClientBucketSummaryChartID);

        $($relatedClientSectionCol1).append($relatedClientBucketSummaryChart);

        let $relatedClientSectionCol2 = $('<div class="col-12 p-2"></div>');
        let $relatedClientBucketSummaryByServiceChart = $('<div></div>');
        $($relatedClientBucketSummaryByServiceChart).attr('id', relatedClientBucketSummaryByServiceChartID);
        $($relatedClientSectionCol2).append($relatedClientBucketSummaryByServiceChart);
        let $relatedClientSectionRow = $('<div class="row mt-4"></div>');
        $($relatedClientSectionRow).append($relatedClientSectionColHeader);
        $($relatedClientSectionRow).append($relatedClientSectionCol1);
        $($relatedClientSectionRow).append($relatedClientSectionCol2);

        var sectionRowRefsObj = {};
        sectionRowRefsObj.sectionRow                     = $relatedClientSectionRow;
        sectionRowRefsObj.bucketSummaryChart             = $relatedClientBucketSummaryChart;
        sectionRowRefsObj.bucketSummaryByServiceChart    = $relatedClientBucketSummaryByServiceChart;

        return sectionRowRefsObj;
 
    }

<%//##################################################################################################################%>

    function updateClientDetails(responseData) {
        $($clientDetailsToc).html('');
        $($clientDetailsRows).html('');
        $.each(responseData.rawData.data, function (idx, relatedClient) {
            let relatedClientSectionID = 'scid-' + relatedClient.clientID;
            $($clientDetailsToc).append(generateRelatedClientTocEntry(relatedClientSectionID, relatedClient));
            let sectionRowRefsObj = generateRelatedClientSectionRow(relatedClientSectionID, relatedClient);            
            $($clientDetailsRows).append(sectionRowRefsObj.sectionRow);

            generateDashBoardItemCdeComplianceBucketsSummaryForClient(sectionRowRefsObj.bucketSummaryChart, relatedClient);
            generateDashBoardItemCdeComplianceBucketsSummaryBySvcForClient(sectionRowRefsObj.bucketSummaryByServiceChart, relatedClient)
        });
    }

<%//##################################################################################################################%>

    function initDashBoardItemCdeComplianceBucketsSummary() {
       
        let opts = {};

        opts.label         = '<%=Spedmon.CdeComplianceCommon.LABEL_SUCCESS_BUCKETS%>';
        opts.showCurrYear  = true;
        opts.showCurrAudit = true;

        opts.requestDataUrlCurrYearBase  = '<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_YEAR_FOR_SELPA_GET()%>';
        opts.requestDataUrlCurrAuditBase = '<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_GET_FOR_SELPA()%>';
        opts.rowLabelCurrAudit           = '<%=Spedmon.CdeComplianceCommon.SEL_LABEL_CURRENT_AUDIT%><br>For CDE Audit Period ';
        opts.rowLabelCurrYear            = '<%=Spedmon.CdeComplianceCommon.SEL_LABEL_ANNUAL%><br>For All Plans Active Between ';
        opts.colLabelBucketLabelA        = '<%=Spedmon.CdeComplianceCommon.LABEL_BUCKET_A_LINES(@"<br>")%>';
        opts.colLabelBucketLabelB        = '<%=Spedmon.CdeComplianceCommon.LABEL_BUCKET_B_LINES(@"<br>")%>';
        opts.colLabelBucketLabelC        = '<%=Spedmon.CdeComplianceCommon.LABEL_BUCKET_C_LINES(@"<br>")%>';
        opts.colLabelTotPatsLabel        = '<%=Spedmon.CdeComplianceCommon.LABEL_BUCKET_TOTAL_STUDENTS_LINES(@"<br>")%>';

        $($dashboardItemCdeComplianceBucketsSummary).MBA_ActionItemCdeComplianceBuckets(opts);
        
    };
<%//##################################################################################################################%>

    function getSelpaClientDetails() {
        let reqUrl = '<%=Spedmon.SELPAS.WEB_SVC_VIEW_RELATED_CLIENTS_BASE()%>';
        let reqDataObj = {};
        reqDataObj[PARM_NAME_SELPA_CODE] = $('#' + PARM_NAME_SELPA_CODE).val();
        let reqDataJSON = JSON.stringify(reqDataObj);
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqDataJSON, null)
            .then(responseData => {
                updateClientDetails(responseData);
            })
            .catch(responseData => {

            });
    }

<%//##################################################################################################################%>

    function updateDashBoard(e) {
        let _selpacode = $('#' + PARM_NAME_SELPA_CODE).val();
        let _nvpSelpaIDObj = MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_SELPA_CODE, _selpacode);
        $($dashboardItemCdeComplianceBucketsSummary).MBA_ActionItemCdeComplianceBuckets('requestDataParameterSetOrUpdate', _nvpSelpaIDObj);
        $($dashboardItemCdeComplianceBucketsSummary).MBA_ActionItemCdeComplianceBuckets('getData');
        getSelpaClientDetails();
    }

<%//##################################################################################################################%>

    $(document).ready(function () {

        $dashboardItemCdeComplianceBucketsSummaryInstructions      = $('#cdecompliancebucketssummaryinstructions');
        $dashboardItemCdeComplianceBucketsSummaryBySvcInstructions = $('#cdecompliancebucketssummarybysvcinstructions')

        $butDoExportCSV  = $('#butDoExportCSV');
        $iconDoExportCSV = $('#iconDoExportCSV');
        $butDoExportXLS  = $('#butDoExportXLS');
        $iconDoExportXLS = $('#iconDoExportXLS');
        $selpaSummaryRows                                     = $('#selpasummaryrows');
        $dashboardItemCdeComplianceBucketsSummary             = $('#cdecompliancebucketssummary');
        $clientDetailsToc                                     = $('#clientdetailstoc');
        $clientDetailsRows                                    = $('#clientdetailsrows');

        initDashBoardItemCdeComplianceBucketsSummary();
        
        $($selpaSummaryRows).on('spedmoninputdata', function (e) {
            if (e.target.id == 'selpacode') {
                updateDashBoard(e);
                return true;
            }

            if (e.target.id == PARM_NAME_PAT_ABSENT_MINS_ARE_SATISFIED_MINS) {
                updateDashBoard(e);
                return true;
            }

        });


        $($butDoExportXLS).on('click', function (e) { doExportXLS(); });
        $($butDoExportCSV).on('click', function (e) { doExportCSV(); });

        if ($('#' + PARM_NAME_SELPA_CODE).val()) { updateDashBoard(null); }

    });

</script>