<%@ Page Language="C#" CodeBehind="user_all_cde_compliance_manage.aspx.cs" Inherits="Spedmon.UserAllCdeComplianceManage"%>


<%//##################################################################################################################%>
<%//# Dashboard  %>
<%//##################################################################################################################%>


<div id="dashboardrows" class="container-fluid">

    <div class="row">

    <div class="col-4">

    <%//-----------------------------------------------------------------------------%>
    <%// Select Client %>
    <%// (Practi-Cal staff only) %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectClient
        ID                   = "selectClient"
        entityControlID      = "clientid"
        rowLabel             = "Client"
        dataEntryRowRenderAs = "FIELD"
        runat                = "server">
    </Spedmon:DataEntryRowSelectClient>

    </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// Page Title %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-4">
       <h3 class="text-center"><%=Spedmon.CdeComplianceCommon.SEL_LABEL_ANNUAL%></h3>
    </div> <!-- col -->

    <div class="col-4">
      
     <div class="d-flex justify-content-end">

     <%//-----------------------------------------------------------------------------%>
     <%// Goto Manage Current Audit %>
     <%//-----------------------------------------------------------------------------%>
       
       <Spedmon:LinkInternal
         ID         = "gotomanagecurrentaudit"
         title      = "Click Here to Manage Current CDE Audit"
         label      = "Manage Current CDE Audit"
         faClass    = "fa fa-link"
         openNew    = "false"
         subWindow  = "false"
         runat     = "server" />
      </div>
    
    </div> <!-- col -->

    </div> <!-- row -->

    <%//-----------------------------------------------------------------------------%>
    <%// Data Update Message %>
    <%//-----------------------------------------------------------------------------%>

    <div class="row mt-2">
       <div class="col-12">
          <div class="alert alert-light text-center"><%=Messages.SPED_DATA_CACHED_INFO %></div>
       </div> <!-- col -->
    </div> <!-- row -->
     
    <%//-----------------------------------------------------------------------------%>
     <%// Select Site %>
     <%//-----------------------------------------------------------------------------%>

      <div class="row mt-3">
          <div class="col-12">
              <div class="d-flex justify-content-center align-items-center">
                <Spedmon:DataEntryRowSelectSchoolSite
                    ID                             = "selectSite"
                    entityControlID                = "siteid"
                    rowLabel                       = "Site"
                    showClearSelection             = "true"
                    showSaveSelectionAsDefault     = "true"
                    dataEntryRowRenderAs           = "FIELD"
                    runat                          = "server">
                </Spedmon:DataEntryRowSelectSchoolSite>
              </div>

        </div> <!-- col -->
      </div> <!-- row -->

      <div class="row mt-2">

      <%//-----------------------------------------------------------------------------%>
      <%// Overall Plans  %>
      <%//-----------------------------------------------------------------------------%>
          
      <div class="col-3">        
        <div class="mba-action-items-container p-2">
            <h3 class="mba-action-item-common mba-action-item-common-label mb-4">Plan Implementation Success</h3>
            <div class="d-flex justify-content-center align-items-center">
            <div id="cdesuccessgauge" style="min-height:18em;height:18em;max-height:18em;"></div>
            </div>
            
         </div> <!-- action items container -->
      </div> <!-- col -->

       <%//-----------------------------------------------------------------------------%>
       <%// PCAL Compliance Rating Summary %>
       <%//-----------------------------------------------------------------------------%>

      <div class="col-3">
          <div id="pcalcomplianceratingsummary" style="min-height:16em;height:16em;max-height:16em;"></div>          
      </div>


       <%//-----------------------------------------------------------------------------%>
       <%// Review and Reports Col  %>
       <%//-----------------------------------------------------------------------------%>

       <div class="col-6">
      
       <%//-----------------------------------------------------------------------------%>
       <%// Review %>
       <%//-----------------------------------------------------------------------------%>

      <div class="mba-action-items-container p-2">

        <h3 class="mba-action-item-common mba-action-item-common-label">Review</h3>
        
         <div class="d-flex justify-content-center align-items-center">
         
         <%//-----------------------------------------------------------------------------%>
         <%// Open Review Service Delivery Deferals %>
         <%//-----------------------------------------------------------------------------%>

         <span class="mr-2">
         
         <span id="badge-count-deliver-defers" class="mr-1 badge bg-secondary text-light" style="font-size:1em">0</span>

         <Spedmon:LinkInternal
            ID                 = "gotomanageservicedeliveryexceptions"
            title              = "Click Here to Review Service Delivery Deferrals"
            label              = "Service Delivery Deferrals (District Wide)"
            faClass            = ""            
            openNew            = "true"
            subWindow          = "true"
            runat              = "server"/>                          
        
         </span>

         <%//-----------------------------------------------------------------------------%>
         <%// Review Possible Service Over Delivery %>
         <%//-----------------------------------------------------------------------------%>

         <span class="ml-2">
         
         <span id="badge-count-svc-over-delivers" class="mr-1 badge bg-secondary text-light" style="font-size:1em">0</span>
         
         <Spedmon:LinkInternal
            ID                 = "gotoreviewpossibleserviceoverdelivery"
            title              = "Click here to review services that are possibly over delivered"
            label              = "Possible Service Over Deliveries"
            faClass            = ""            
            openNew            = "true"
            subWindow          = "true"
            runat              = "server" />
         </span>

        </div>

        </div> <!-- action item -->

       <%//-----------------------------------------------------------------------------%>
       <%// SELPA Exports %>
       <%//-----------------------------------------------------------------------------%>

        <div class="mba-action-items-container p-2 mt-2">
        <h3 class="mba-action-item-common mba-action-item-common-label">Services Export</h3>
        
         <div class="d-flex justify-content-center align-items-center">

        <span style="display:inline-block">
        <Spedmon:DateBoxRange ID="daterange" name="daterange" title="Export Data for Dates of Service" showOK="false" runat="server" />
        </span>
        
        <button type="button" id="butDoExportXLS" class="btn btn-success mr-1">
          <span id="lblDoExportXLS">Download Excel </span>
          <i id="iconDoExportXLS" class="fa fa-file-excel"></i>
        </button>

        <button type="button" id="butDoExportCSV" class="btn btn-secondary ml-1">
          <span id="lblDoExportCSV">Download CSV </span>
          <i id="iconDoExportCSV" class="fa fa-file-csv"></i>
        </button>
        </div>
        </div> <!-- action item -->

       <%//-----------------------------------------------------------------------------%>
       <%// Reports %>
       <%//-----------------------------------------------------------------------------%>
         		
          <div class="mba-action-items-container p-2 mt-2">
		    <h3 class="mba-action-item-common mba-action-item-common-label text-center">Download Reports</h3>
                
                <div class="d-flex justify-content-center align-items-center">

		        <Spedmon:DataEntryBoxSelectReportFormat
                      ID         = "perrptfmt"
                      name       = "perrptfmt"
                      title      = "Select File Format"
                      label      = "Select File Format"
                      includeCSV = "false"                      
                      includePDF = "true"
                      runat      = "server" />
                  
		        <Spedmon:DataEntryButton ID="doDownloadPerfReptBySvc" cssClass="ml-1" style="SECONDARY"  fireSpedmonInput="false"  label="District Wide" title="Click to download." onclick="downloadPerfReptBySvc(e)" runat="server"/>
		        <Spedmon:DataEntryButton ID="doDownloadPerfReptBySiteSvc" cssClass="ml-1" style="SECONDARY" fireSpedmonInput="false"  label="Site Specific" title="Click to download." onclick="downloadPerfReptBySiteSvc(e)" runat="server"/>

                </div>

		    </div> <!-- action item -->

        </div> <!-- col -->
      </div> <!-- row -->


       <%//-----------------------------------------------------------------------------%>
       <%// Summary by Service %>
       <%//-----------------------------------------------------------------------------%>

      <div class="row mt-3">
        <div class="col-12">
           <section id="sectioncdecompliancebucketssummarybysvc" >
                <div id="cdecompliancebucketssummarybysvc"></div>
           </section>
        </div> <!-- col -->
     </div> <!-- row -->

     <%//-----------------------------------------------------------------------------%>
     <%// Service Thresholds %>
     <%//-----------------------------------------------------------------------------%>

    <%if (showSvcThresholds == true) {%>

     <div class="row mt-3">
     <div class="col-12">
     <div class="mba-action-items-container p-2">
     <h3 class="mba-action-item-common mba-action-item-common-label">Service Thresholds for Current SWD Plan Implementation and CDE Audit of SWD Plan Implementation</h3>

     <div class="alert alert-info">
        <strong>Instructions:</strong> If your Local Education Agency (LEA) offers scheduled and recurring <strong>330 Specialized Academic Instruction</strong> related services that can be
        supported through alternative means aside from direct documentation into SpEdCare, you have the option to enable
        SpEdCare to automatically mark services as satisfied if they meet specific thresholds. However, utilizing this feature does not exempt the
        LEA from the responsibility of maintaining proof of delivery of related services for audit purposes.
        Proof of delivery may encompass attendance records, rosters, physical documentation, or any other means of verifying service provision.
        <br />
        <strong>Changes to the values below will not be reflected until the next day for any Current SWD Plan Implementation based reporting.</strong>
     </div>

     <div class="mt-1">
       <Spedmon:DataEntryBoxNumber ID="minminsperfreqdaily" label="Minimum Daily Minutes" size="12" min="0" runat="server" />
       <Spedmon:DataEntryBoxNumber ID="minminsperfreqweekly" label="Minimum Weekly Minutes" size="12" min="0" runat="server" />
       <Spedmon:DataEntryBoxNumber ID="minminsperfreqmonthly" label="Minimum Monthly Minutes" size="12" min="0" runat="server" />
       <Spedmon:DataEntryBoxTextArea ID="notes" label="Notes" size="20" runat="server" />
     </div>

     <div class="mt-2">
     <em>
     By clicking Save & Certify I hereby consent to SpEdCare automatically satisfying minutes that meet the specified thresholds outlined above.
     I affirm that the aforementioned thresholds can be substantiated with additional documentation to validate the provision of related services.
     </em>
     </div>

     <div class="d-flex justify-content-end">
     <Spedmon:DataEntryButton ID="butDoSaveSvcSetPoints" label="Save & Certify" title="Click" size="REGULAR" faIcon="fas fa-save" runat="server" onclick="fnDoSaveSvcSetPoints();" />
     </div>

     </div> <!-- action item -->
     </div> <!-- col -->

   </div> <!-- row -->
   <%}%>

</div> <!-- container -->

<%//##################################################################################################################%>
<%//# Instructions Content  %>
<%//##################################################################################################################%>

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
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    const PARM_NAME_CLIENT_ID                          = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_SITE_ID                            = '<%=Constants.PARM_SITE_ID%>';
    const PARM_NAME_PAT_ABSENT_MINS_ARE_SATISFIED_MINS = '<%=Constants.PARM_PAT_ABSENT_MINS_ARE_SATISFIED_MINS%>';

    const PARM_NAME_MIN_MINS_PER_FREQ_DAILY   = 'minminsperfreqdaily';
    const PARM_NAME_MIN_MINS_PER_FREQ_WEEKLY  = 'minminsperfreqweekly';
    const PARM_NAME_MIN_MINS_PER_FREQ_MONTHLY = 'minminsperfreqmonthly';
    const PARM_NAME_NOTES                     = 'notes';

    const URL_SESSION_EXPIRED_LINK            = '<%=MBA.Credential.generateSessionExpiredLink()%>';

    let $clientID                                                  = null;
    let $siteID                                                    = null;
    let $dashboardRows                                             = null;    
    let $dashboardItemCdeSuccessGauge                              = null;
    let $dashboardItemPcalComplianceRatingSummary                  = null;
    let $dashboardItemCdeComplianceBucketsSummaryBySvc             = null;
    let $dashboardItemCdeComplianceBucketsSummaryBySvcInstructions = null;

    let $butDoExportXLS                      = null;
    let $iconDoExportXLS                     = null;
    let $butDoExportCSV                      = null;
    let $iconDoExportCSV                     = null;
    let $linkGotoManageCurrentAudit          = null;
    let $linkManageServiceDeliveryExceptions = null;
    let $linkReviewServiceOverDeliver        = null;
    let $badgeCountDeliverDefers             = null;
    let $badgeCountSvcOverDelivers           = null;

    let $minMinsPerFreqDaily                 = null;
    let $minMinsPerFreqWeekly                = null;
    let $minMinsPerFreqMonthly               = null;
    let $notes                               = null;
    let $butDoSaveSvcSetPoints               = null;

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function updateOverallComplianceGauge() {
             
        var url = '<%=Spedmon.CdeComplianceCommon.WEB_SVC_CDE_COMPLIANCE_GET_OVERALL_SUMMARY()%>';
        let reqDataObj = {};
        reqDataObj[PARM_NAME_CLIENT_ID] = $($clientID).val();
        reqDataObj[PARM_NAME_SITE_ID]   = $($siteID).val();
        if (reqDataObj[PARM_NAME_CLIENT_ID] == '') return;
        let reqDataJSON = JSON.stringify(reqDataObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(url, reqDataJSON, null)
            .then(responseData => {
                let overallPct                           = 0;
                let numOfSvcsOverDelivered               = 0;
                let numOfUnreviewedSvcDeliveryExpections = 0;
                if (responseData.rawData.hasRecord == true) {
                    overallPct                           = responseData.rawData.data.pctCompliant;
                    numOfSvcsOverDelivered               = responseData.rawData.data.numOfSvcsOverDelivered;
                    numOfUnreviewedSvcDeliveryExpections = responseData.rawData.data.numOfUnreviewedSvcDeliveryExpections;
                }
                $($dashboardItemCdeSuccessGauge).MBA_ActionItemDialGauge('setValue', overallPct);
                $($badgeCountDeliverDefers).text(numOfUnreviewedSvcDeliveryExpections);
                $($badgeCountSvcOverDelivers).text(numOfSvcsOverDelivered);

            })
            .catch(responseData => {
                $($dashboardItemCdeSuccessGauge).MBA_ActionItemDialGauge('setValue', 0);
                $($badgeCountDeliverDefers).text(0);
                $($badgeCountSvcOverDelivers).text(0);

            });
        return;
    };
    
    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function initDashBoardItemCdeComplianceBucketsSummaryBySvc () {

        let opts = {};

        opts.label = 'Plan Implementation - By Service';
        opts.urlSessionExpiredLink = URL_SESSION_EXPIRED_LINK;
        opts.requestDataUrlBase = '<%=Spedmon.CdeComplianceCommon.WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_BY_SVC()%>';

        opts.requestDataFieldNames = [ PARM_NAME_CLIENT_ID , PARM_NAME_SITE_ID ];
        opts.instructionsEnabled = true;
        opts.instructionsPosition = 'bottom-left';
        opts.instructionsContent = $($dashboardItemCdeComplianceBucketsSummaryBySvcInstructions).html();
        opts.title = 'CALPADS Services';
        opts.subTitleProgressLabel = 'CALPADS Service'
        opts.subTitleProgressBar = 'Percentage';
        opts.progressDataHasActionURL = true;

        opts.createLabelAndContainerWrap = false;

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

        
        $($dashboardItemCdeComplianceBucketsSummaryBySvc).MBA_ActionItemProgressBarChart(opts);
  
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function initDashboardItemPcalComplianceRatingSummary() {

        let opts = {};

        opts.label = 'Plan Implementation - By Student';
        
        opts.urlSessionExpiredLink = URL_SESSION_EXPIRED_LINK;
        opts.requestDataUrlBase    = '<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_BY_PCAL_RATING_BASE()%>';
        opts.requestDataFieldNames = ['' + PARM_NAME_CLIENT_ID, PARM_NAME_SITE_ID];
        opts.autoSetUpdateRequestDataParametersFromRequestDataFieldNames = true;
        
        opts.instructionsEnabled = false;
        $($dashboardItemPcalComplianceRatingSummary).MBA_ActionItemCdeComplianceBucketsPcalRatings(opts);
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function initDashboardItemCdeSuccessGauge() {
        let opts = {};
        opts.label        = 'Plan Implementation Success';
        opts.initialValue = 0;
        $($dashboardItemCdeSuccessGauge).MBA_ActionItemDialGauge(opts);
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnDoLockSvcSetPoints() {
        $($minMinsPerFreqDaily).MBA_DataEntryBox('lock');
        $($minMinsPerFreqWeekly).MBA_DataEntryBox('lock');
        $($minMinsPerFreqMonthly).MBA_DataEntryBox('lock');
        $($notes).MBA_DataEntryBox('lock');
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnDoUnlockSvcSetPoints() {
        $($minMinsPerFreqDaily).MBA_DataEntryBox('unlock');
        $($minMinsPerFreqWeekly).MBA_DataEntryBox('unlock');
        $($minMinsPerFreqMonthly).MBA_DataEntryBox('unlock');
        $($notes).MBA_DataEntryBox('unlock');
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnDoClearSvcSetPoints() {
      $($minMinsPerFreqDaily).MBA_DataEntryBox('clearValue');
      $($minMinsPerFreqWeekly).MBA_DataEntryBox('clearValue');
      $($minMinsPerFreqMonthly).MBA_DataEntryBox('clearValue');
      $($notes).MBA_DataEntryBox('clearValue');
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnDoLoadSvcSetPoints() {

        fnDoClearSvcSetPoints();
        let reqDataObj = {};
        reqDataObj[PARM_NAME_CLIENT_ID] = $($clientID).val();
        if (reqDataObj[PARM_NAME_CLIENT_ID] == '') return;
        let reqDataJSON = JSON.stringify(reqDataObj);
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.PatientsPromisedServicesMinsConsideredSatisfiedSetPoints.URL_SERVICE_GET()%>', reqDataJSON, null)
            .then(responseData => {
                let setPointObj = responseData.rawData.entity;
                $($minMinsPerFreqDaily).MBA_DataEntryBox('setValue', setPointObj.minMinsPerFreqDaily);
                $($minMinsPerFreqWeekly).MBA_DataEntryBox('setValue', setPointObj.minMinsPerFreqWeekly);
                $($minMinsPerFreqMonthly).MBA_DataEntryBox('setValue', setPointObj.minMinsPerFreqMonthly);
                $($notes).MBA_DataEntryBox('setValue', setPointObj.notes);
            })
            .catch(responseData => {
            });
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnDoSaveSvcSetPoints() {

        let reqDataObj = {};

        reqDataObj[PARM_NAME_CLIENT_ID] = $($clientID).val();
        if (reqDataObj[PARM_NAME_CLIENT_ID] == '') return;

        let $waitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner($butDoSaveSvcSetPoints);
        fnDoLockSvcSetPoints();

        reqDataObj[PARM_NAME_MIN_MINS_PER_FREQ_DAILY]   = $($minMinsPerFreqDaily).MBA_DataEntryBox('getValue');
        reqDataObj[PARM_NAME_MIN_MINS_PER_FREQ_WEEKLY]  = $($minMinsPerFreqWeekly).MBA_DataEntryBox('getValue');
        reqDataObj[PARM_NAME_MIN_MINS_PER_FREQ_MONTHLY] = $($minMinsPerFreqMonthly).MBA_DataEntryBox('getValue');
        reqDataObj[PARM_NAME_NOTES]                     = $($notes).MBA_DataEntryBox('getValue');

        let reqDataJSON = JSON.stringify(reqDataObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.PatientsPromisedServicesMinsConsideredSatisfiedSetPoints.URL_SERVICE_SAVE()%>', reqDataJSON, null)
            .then(responseData => {
                fnDoUnlockSvcSetPoints();
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butDoSaveSvcSetPoints, $waitingIcon);
            })
            .catch(responseData => {
                fnDoUnlockSvcSetPoints();
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butDoSaveSvcSetPoints, $waitingIcon);
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Threshold Values Could Not Be Saved', responseData.message, {});
            });
    };
        
    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function updateDashBoard(e)
    {
      let _vcid                    = $('#' + PARM_NAME_CLIENT_ID).val();
      let _nvpClientIDObj          = MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, _vcid);
      let _nvpPatAbsMinsAreSatMins = MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PAT_ABSENT_MINS_ARE_SATISFIED_MINS, '0'); /* TODO: Hardcoded for now to not count pat absent as satisfied.  Change to ctrl refefence if needed later. */
      $($linkGotoManageCurrentAudit).MBA_Link('requestDataParameterSetOrUpdate', _nvpClientIDObj);
      $($linkManageServiceDeliveryExceptions).MBA_Link('requestDataParameterSetOrUpdate', _nvpClientIDObj);
      $($linkReviewServiceOverDeliver).MBA_Link('requestDataParameterSetOrUpdate', _nvpClientIDObj);
      $($dashboardItemCdeComplianceBucketsSummaryBySvc).MBA_ActionItemProgressBarChart('getData');
      $($dashboardItemPcalComplianceRatingSummary).MBA_ActionItemCdeComplianceBucketsPcalRatings('getData');
      updateOverallComplianceGauge();
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function doExport($butDoExport, $iconDoExport, rptFmt, rptCookieName) {

        $($butDoExport).prop('disabled', true);

        let $waitingIcon = $('<i class="fa fa-spinner fa-pulse fa-fw m-auto"></i>');
        $waitingIcon.insertAfter($iconDoExport);

        let reqUrl = '<%=Spedmon.ServiceRecords.URL_WEB_REPORT_BASE()%>';

        let reqData = [
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_CLIENT_ID%>", $("#<%=Constants.PARM_CLIENT_ID%>").val()),
              MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_DATE_RANGE%>" , $("#<%=Constants.PARM_DATE_RANGE%>").val() ),
          ];

          MBA.ComponentCommon.fnRequestDownloadWebReportDocument (
                  reqUrl
                , rptFmt
              , <%=Spedmon.ServiceRecordsRpt.REPT_SELPA_EXPORT%>
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

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function doExportXLS() {
        doExport($butDoExportXLS, $iconDoExportXLS, <%=Constants.REPT_FORMAT_XLS%>, 'Rpt_Selpa_Export_Synch_XLS');
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadPerfRept(e,rptNum) {      

        let rptFmt = 3;
        rptFmt = $('#perrptfmt').val();

        let elem = e.target;

        let reqUrl = '<%=Spedmon.CdeComplianceCommon.URL_WEB_REPORT()%>';
        let reqData = [
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_CLIENT_ID%>", $("#<%=Constants.PARM_CLIENT_ID%>").val()),
        ];
        MBA.ComponentCommon.fnElemDoRequestDownloadWebReportDocument( elem , reqUrl, rptFmt, rptNum, 'Perf_Rpt_' + rptNum + '_' + rptFmt, reqData
            , function () { return; }
            , function () { return; });
    };


    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadPerfReptBySiteSvc(e) {
        let rptNum = <%=Spedmon.CdeComplianceViw.REPT_NUM_VIEW_FY_PERFORMANCE_BY_SITE_SERVICE_SUMMARY%>;
        downloadPerfRept(e, rptNum);
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadPerfReptBySvc(e) {
        let rptNum = <%=Spedmon.CdeComplianceViw.REPT_NUM_VIEW_FY_PERFORMANCE_SERVICE_SUMMARY%>;
        downloadPerfRept(e, rptNum);
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function doExportCSV() {
        doExport($butDoExportCSV, $iconDoExportCSV, <%=Constants.REPT_FORMAT_CSV%>, 'Rpt_Selpa_Export_Synch_CSV');
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/
    
    $(document).ready(function () {
        $clientID                                                  = $('#' + PARM_NAME_CLIENT_ID);
        $siteID                                                    = $('#' + PARM_NAME_SITE_ID);
        $dashboardRows                                             = $('#dashboardrows');
        $dashboardItemCdeSuccessGauge                              = $('#cdesuccessgauge');
        $dashboardItemPcalComplianceRatingSummary                  = $('#pcalcomplianceratingsummary');
        $dashboardItemCdeComplianceBucketsSummaryBySvc             = $('#cdecompliancebucketssummarybysvc');
        $dashboardItemCdeComplianceBucketsSummaryBySvcInstructions = $('#cdecompliancebucketssummarybysvcinstructions');
        $butDoExportXLS                                            = $('#butDoExportXLS');
        $iconDoExportXLS                                           = $('#iconDoExportXLS');
        $butDoExportCSV                                            = $('#butDoExportCSV');
        $iconDoExportCSV                                           = $('#iconDoExportCSV');
        $linkGotoManageCurrentAudit                                = $('#gotomanagecurrentaudit');
        $linkManageServiceDeliveryExceptions                       = $('#gotomanageservicedeliveryexceptions');
        $linkReviewServiceOverDeliver                              = $('#gotoreviewpossibleserviceoverdelivery');
        $badgeCountDeliverDefers                                   = $('#badge-count-deliver-defers');
        $badgeCountSvcOverDelivers                                 = $('#badge-count-svc-over-delivers');
        $butDoSaveSvcSetPoints                                     = $('#butDoSaveSvcSetPoints');
        $minMinsPerFreqDaily                                       = $('#' + PARM_NAME_MIN_MINS_PER_FREQ_DAILY);
        $minMinsPerFreqWeekly                                      = $('#' + PARM_NAME_MIN_MINS_PER_FREQ_WEEKLY);
        $minMinsPerFreqMonthly                                     = $('#' + PARM_NAME_MIN_MINS_PER_FREQ_MONTHLY);
        $notes                                                     = $('#' + PARM_NAME_NOTES);

        $($butDoExportXLS).on('click', function (e) { doExportXLS(); });
        $($butDoExportCSV).on('click', function (e) { doExportCSV(); });
        
        initDashboardItemCdeSuccessGauge();
        initDashboardItemPcalComplianceRatingSummary();
        initDashBoardItemCdeComplianceBucketsSummaryBySvc();
        fnDoClearSvcSetPoints();

        /* Move badges inside links */

        $($badgeCountDeliverDefers).detach().prependTo($linkManageServiceDeliveryExceptions)
        $($badgeCountSvcOverDelivers).detach().prependTo($linkReviewServiceOverDeliver)

        $($dashboardRows).on('spedmoninputdata', function (e) {
            if (e.target.id == PARM_NAME_CLIENT_ID) {
                fnDoLoadSvcSetPoints();
                updateDashBoard(e);
            }
            else if (e.target.id == PARM_NAME_SITE_ID) {
                $($dashboardItemCdeComplianceBucketsSummaryBySvc).MBA_ActionItemProgressBarChart('getData');
                $($dashboardItemPcalComplianceRatingSummary).MBA_ActionItemCdeComplianceBucketsPcalRatings('getData');
                updateOverallComplianceGauge();
                let _vsid = $('#' + PARM_NAME_SITE_ID).val();
                let _nvpSiteIDObj = MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_SITE_ID, _vsid);
                $($linkReviewServiceOverDeliver).MBA_Link('requestDataParameterSetOrUpdate', _nvpSiteIDObj);
            }
        });

        /* If there is a client id preloaded we can load everything */

        if ($($clientID).val()) {
            fnDoLoadSvcSetPoints();
            updateDashBoard(null);
        }

    });

</script>
