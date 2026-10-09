<%@ Page Language="C#" CodeBehind="user_all_lea_bop_health_manage.aspx.cs" Inherits="Spedmon.UserAllLeaBopHealthManage"%>


<div id="dashboardrows" class="container-fluid"> 
   


    <Spedmon:HiddenInput id="daterange" title="Date Range" runat="server"/>
    <Spedmon:HiddenInput id="includezeros" title="Include Zeros" value="1" runat="server"/>
    <Spedmon:HiddenInput ID="repid" name="repid" title="repid" value="" runat="server" />



    <%//-----------------------------------------------------------------------------%>
    <%// Select Client %>
    <%// (Practi-Cal staff only) %>
    <%//-----------------------------------------------------------------------------%>

    <div class="row">
    <div class="col-12">

    <Spedmon:DataEntryRowSelectClient
        ID                   = "selectClient" 
        entityControlID      = "clientid"                
        rowLabel             = "Client"
        dataEntryRowRenderAs = "FIELD"        
        runat                = "server">
    </Spedmon:DataEntryRowSelectClient>

     <Spedmon:DataEntryRowSelectFiscalYear
            ID                   = "selectFiscalYear" 
            entityControlID      = "fiscalyearid"                
            rowLabel             = "Year"
            dataEntryRowRenderAs = "FIELD"
            runat                = "server">
     </Spedmon:DataEntryRowSelectFiscalYear>

    </div> <!-- col -->
    </div> <!-- row -->

    <div class="row mt-1 mb-3 py-1">
        
      <div class="col-12 col-md-6 col-xl-4">
          <div id="potlostreimbursements"></div>
       </div> <!-- col -->


        <div class="col-12 col-md-6 col-xl-8">


        <div class="row">
 
        <div class="col-12 mb-3">

        <section class="mba-action-item-common mba-action-item-common-container">

        <h3 class="mba-action-item-common mba-action-item-common-label flex-grow-1">
          Task Management
        </h3>

          
         <div id="dataManagementRows" class="container-fluid">
         
         <div class="row">
         <div class="col-6">

          <Spedmon:LinkInternal 
          ID        = "gotomanageclientcompliancetasks" 
          title     = "Click here to manage all tasks" 
          label     = "Manage All Tasks"
          faClass   = "fas fa-hand-point-right"               
          openNew   = "true"  
          subWindow = "true"
          runat     = "server" />

         </div> <!-- col -->

         <div class="col-6">
         
  
          <input type="hidden" id="<%=Constants.PARM_IS_NOT_COMPLETED%>" value="1"  />
          <input type="hidden" id="<%=Constants.PARM_IS_COMPLETED%>" />
          <input type="hidden" id="<%=Constants.PARM_IS_PENDING%>" />
        
           <Spedmon:RadioBox 
              ID="clientcompliancetasksitemstatus" 
              name="clientcompliancetasksitemstatus" 
              title="Select Status" 
              renderLabel="false"
              additionalCssClassNameForContainer="d-flex justify-content-end modern2021" 
              onSelectValue="function(oldval,newval){MBA.ClientComplianceTasks.resetItemStatusFilterFlags(oldval, newval);}" 
              runat="server" />
        </div> <!-- col compliance tasks filter -->
        </div> <!-- row -->

       <div class="row mt-3">        
       <div class="col-12">
         <div id="restViewComplianceMgmt"></div> <!-- rest view -->
       </div> <!-- col -->        
       </div> <!-- row>
       </div> <!-- container -->

        

       </section> <!-- compliance tasks -->

       </div> <!-- inner cols inner row -->

       <div class="col-12  ">
         <section class="mba-action-item-common mba-action-item-common-container  mba-action-item-iframe-wrap" style="height:190px">
           <iframe id="iframeRmtsDashStats" class="w-100 h-100" >
           </iframe>
         </section>
       </div>

       </div> <!-- inner row -->




       </div> <!-- cols -->

   

    </div> <!-- row -->
    
    <div class="row mt-1 mba-action-item-container">

        <div class="col-12 col-md-6 col-xl-6">
            <div id="potlostamtmissingtmts"></div>
        </div> <!-- col -->

        <div class="col-12 col-md-6 col-xl-6 ">
            <div id="claimspaid"></div>
        </div>

    </div> <!-- row -->

</div> <!-- container -->

<%//##################################################################################################################%>
<%//# Widgets No Longer In Use (TODO: Remove)  %>
<%//##################################################################################################################%>

<div id="reimburseamtsbydowthisyear"></div>
<div id="reimburseamtsbydosthisyear"></div>

<%//##################################################################################################################%>
<%//# Instructions Content  %>
<%//##################################################################################################################%>

<!-- Reimbursement by DOW -->

<div id="reimburseamtsbydowthisyearinstructions" class="mba-action-item-common-instructions-definition">

<article class="mba-action-item-common-instructions">

<h1 class="mba-action-item-common-instructions">Check Date Reimbursement</h1>

<section class="mba-action-item-common-instructions">
<h2 class="mba-action-item-common-instructions">What Is Check Date Reimbursement:</h2>
<ul class="mba-action-item-common-instructions">
<li>Check Date Reimbursement is the reimbursement your LEA has received, regardless of the fiscal year services were provided in.</li>
<li>The Annual Goal is the amount that has been determined for your LEA, based on demographics and/or past performance. (Thin black line on gauge designates current goal)</li>
<li>The large number in the middle of the gauge is the actual reimbursement approved for your LEA, as of last warrant date (weekly). (The thick black line shows progress to goal)</li>
<li>The Green or Red amount above the actual reimbursement shows the amount above or behind goal.</li>
<li>Click the link near the top to download the Check Date Report for the current fiscal year.</li>
</ul>
</section>

<section class="mba-action-item-common-instructions">
<h2 class="mba-action-item-common-instructions">What to do if you are currently behind on Check Date Reimbursement:</h2>
<ul class="mba-action-item-common-instructions">
<li>Ensuring rendering practitioners are recording services timely in SpEdCare, will have the greatest effect on reaching your goal.</li>
<li>Ensure your LEA is billing for all eligible services allowed.</li>
<li>Reviewing your missing assessment report (see Potential Reimbursements).</li>
<li>Potential reimbursement from held claims (see Potential Reimbursements).</li>
<li>Work with Practi-Cal to ensure all employed practitioners are included in RMTS</li>
</ul>
</section>

<aside class="mba-action-item-common-instructions mba-action-item-common-instructions-tip">
TIP: If any employed practitioners are still using paper forms, we recommend switching to recording services directly in SpEdCare. For practitioners, entering services directly in SpEdCare is quicker and easier than completing paper logs and services entered in SpEdCare are reimbursed in 2-3 weeks 
from date of entry. SpEdCare also has immediate compliance checks, which lowers your audit risk and reduces the amount of question forms sent back to an LEA, when using paper forms. 
There are a lot of additional benefits for practitioners and coordinators, so please speak with your consultant, if paper logs are still being used.
</aside>
</article>
</div>

<!-- Reimbursement by DOS -->

<div id="reimburseamtsbydosthisyearinstructions" class="mba-action-item-common-instructions-definition">

<article class="mba-action-item-common-instructions">

<h1 class="mba-action-item-common-instructions">Date of Service Reimbursement</h1>
<section class="mba-action-item-common-instructions">
<h2 class="mba-action-item-common-instructions">What Is Date of Service Reimbursement:</h2>
<ul class="mba-action-item-common-instructions">
<li>Date of service reimbursement includes reimbursement your LEA has received for dates of service within this fiscal year and is a more accurate representation of how your billing program is performing.</li>
<li>Since all services rendered, with dates of service within the same fiscal year, cannot be transmitted and paid before June 30th (DHCS holds the last 3 weeks of June), the Date of Service Goal amount is 80% of your annual check date goal. (Thin black line on gauge designates current goal)</li>
<li>The large number in the middle of the gauge is the actual reimbursement approved for your LEA, as of last warrant date (weekly). (The thick black line shows progress to goal)</li>
<li>The Green or Red amount above the actual reimbursement shows the amount above or behind where your LEA should be as of the current month (not annually).</li>
<li>Click the link near the top to download the Date of Service Report for the current fiscal year.</li>
</ul>
</section>

<section class="mba-action-item-common-instructions">
<h2 class="mba-action-item-common-instructions">What to do if you are currently behind on Date of Service Reimbursement:</h2>
<ul class="mba-action-item-common-instructions">
<li>Ensuring rendering practitioners are recording services timely in SpEdCare, will have the greatest effect on reaching your goal.</li>
<li>Ensure your LEA is billing for all eligible services allowed.</li>
<li>Reviewing your missing assessment report (see Potential Reimbursements).</li>
<li>Potential reimbursement from held claims (see Potential Reimbursements).</li>
<li>Work with Practi-Cal to ensure all employed practitioners are included in RMTS</li>
</ul>
</section>

<aside class="mba-action-item-common-instructions mba-action-item-common-instructions-tip">
TIP: If any employed practitioners are still using paper forms, we recommend switching to recording services directly in SpEdCare. 
For practitioners, entering services directly in SpEdCare is quicker and easier than completing paper logs and services entered in SpEdCare are reimbursed in 2-3 weeks from date of entry. 
SpEdCare also has immediate compliance checks, which lowers your audit risk and reduces the amount of question forms sent back to an LEA, when using paper forms. 
There are a lot of additional benefits for practitioners and coordinators, so please speak with your consultant, if paper logs are still being used. 
</aside>
</article>
</div>

<!-- Missing treatments -->

<div id="potlostamtmissingtmtsinstructions" class="mba-action-item-common-instructions-definition">

</div>

<!-- Pot lost reimbursement -->

<div id="potlostreimbursementsinstructions" class="mba-action-item-common-instructions-definition">
<article class="mba-action-item-common-instructions">
<h1 class="mba-action-item-common-instructions">Potential Reimbursement</h1>
<section class="mba-action-item-common-instructions">
<h2 class="mba-action-item-common-instructions">What Is Potential Reimbursement:</h2>
<p class="mba-action-item-common-instructions">
One of the many areas that set Practi-Cal apart is our compliance algorithms that protect your LEA. 
SpEdCare will automatically hold claims that do not meet minimum transmission requirements and we report these on your interactive Program Health dashboard, for services provided to Medi-Cal eligible students. 
Many of these held claims can be fixed and released for reimbursement. 
Here are the amounts and reasons for claims currently held in our system. 
Once the hold reasons are resolved, the amounts below will decrease, and your program reimbursement will increase.
Zero amounts can be ignored.
</p>
</section>

<section class="mba-action-item-common-instructions">
<h2 class="mba-action-item-common-instructions">What Are The Different Amounts:</h2>
<dl class="mba-action-item-common-instructions">
<dt>Missing Prescriptions or Service Authorizations:</dt>
<dd>This amount represents claims currently being held by SpEdCare, due to missing orders and/or service authorizations. All treatment services require a written recommendation or prescription by a valid Ordering, Referring, and Prescribing (ORP) professional. An example of this would be a physician prescribing 1:1 medical assistance, activities of daily living, or a mental health professional recommending counseling. SpEdCare’s Potential Reimbursement screen shows these services. Additionally, SpEdCare has a feature that allows practitioners to send an order for electronic consent directly to the ORP professional or the parent.</dd>
<dt>NPI / ORP:</dt> 
<dd>This amount represents claims currently being held by SpEdCare, due to an order missing a valid ORP professional. SpEdCare’s Potential Reimbursement screen shows these services, and a message can be sent to practitioner(s) to validate the ORP.</dd>
<dt>Medi-Cal Consent:</dt> 
<dd>This amount represents claims currently being held by SpEdCare, due to not having parent consent to bill Medi-Cal. All IEP/IFSP services require the parent to provide written consent. SpEdCare’s Missing Parent Consent screen shows these services and allows coordinators to send parents a requests and gain consent via our parent portal and electronic signature.</dd>
<dt>Daily Journal Held:</dt> 
<dd>This amount represents claims currently being held by SpEdCare, due to Health Aide and LVN services that are currently being held by the supervising nurse. Sending a request to the rendering aide or LVN to fix any errors will clear this amount up.</dd>
<dt>Practitioner Not in RMTS:</dt>
<dd>This amount represents claims currently being held by SpEdCare, due to not being included on your LEA’s certified RMTS TSP list. Unfortunately, if any participating practitioner is not on your certified RMTS TSP list, this amount will not be recoverable. To receive LEA BOP reimbursement, employed practitioners are required to participate in RMTS.</dd>
<dt>Missing Supervision:</dt>
<dd>This amount represents claims currently being held by SpEdCare, due to a practitioner requiring supervision. This may include rendering SLPA’s, ACSW’s, AMFT’s, COTA’s or PTA’s. SpEdCare’s supervision management screen should be updated to assign supervisors, where appropriate.</dd>
<dt>Missing Assessments:</dt>
<dd>This amount represents Medi-Cal eligible students who have had records recorded in the past 13 months but have not had an assessment recorded in the past 12 months.</dd>
</dl>
</section>

</article>
</div>

<!-- Claims paid -->

<div id="claimspaidinstructions" class="mba-action-item-common-instructions-definition">


</div>


<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">
    
    const PARM_NAME_CLIENT_ID      = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_DATE_RANGE     = '<%=Constants.PARM_DATE_RANGE%>';
    const PARM_NAME_REP_ID         = '<%=Constants.PARM_REP_ID%>';
    const PARM_NAME_INCLUDE_ZEROS  = 'includezeros';
    const URL_SESSION_EXPIRED_LINK = '<%=MBA.Credential.generateSessionExpiredLink()%>';
    const CLAIMS_PAID_REPORTS_CONT_CLASS       = 'claims-paid-reports-cont';
    const CLAIMS_PAID_PRAC_SUBMISSION_RPT_ID   = 'claims-paid-prac-submission-rpt-id';
    const CLAIMS_PAID_CLAIMS_COMPARISON_RPT_ID = 'claims-paid-claims-comparison-rpt-id';
    const ANIMATION_PULSE_CLASS                = 'animation-pulse';

    const PREVIEW_ONLY = <%=MBA.Util.netBoolToJSBool(this.previewOnly)%>;

    let $dashboardRows = null;

    let $dashboardItemReimburseAmtsByDosThisYear              = null;
    let $dashboardItemReimburseAmtsByDosThisYearInstructions  = null;

    let $dashboardItemReimburseAmtsByDowThisYear              = null;
    let $dashboardItemReimburseAmtsByDowThisYearInstructions  = null;

    let $dashboardItemPotentialLostAmtMissingTmts             = null;
    let $dashboardItemPotentialLostAmtMissingTmtsInstructions = null;

    let $dashboardItemPotentialLostReimbursements             = null;
    let $dashboardItemPotentialLostReimbursementsInstructions = null;

    let $dashboardItemClaimsPaid                              = null;
    let $dashboardItemClaimsPaidInstructions                  = null;
    let $linkGotoManageClientComplianceTasks                  = null;
    
    function initDashBoardItemReimburseAmtsByDosThisYear() {
        $dashboardItemReimburseAmtsByDosThisYear             = $('#reimburseamtsbydosthisyear');
        $dashboardItemReimburseAmtsByDosThisYearInstructions = $('#reimburseamtsbydosthisyearinstructions');
        let opts = {};
        opts.label = 'Reimbursement By Date of Service For This Year';
        opts.urlSessionExpiredLink  = URL_SESSION_EXPIRED_LINK;
        opts.requestDataUrlBase = '<%=Spedmon.LeaBopHealthCommon.URL_WEB_SVC_AMTS_BY_DOS_FOR_THIS_YEAR()%>';
        opts.requestDataFieldNames = ['' + PARM_NAME_CLIENT_ID, PARM_NAME_REP_ID];
        opts.autoSetUpdateRequestDataParametersFromRequestDataFieldNames = true;       
        opts.gaugeType = MBA.ActionItemGaugeCommon.GAUGE_TYPE.financialProgress;
        opts.fnGenerateGaugeTitle = function (totalNumAmt) {
            return 'Goal as of Current Month: $' + totalNumAmt.goalAmtStr;
        };
        opts.reportUrlBase = '<%=Spedmon.Reports.Fianancial.URL_REPORT_BASE()%>';
        opts.reportDataFieldNames = ['' + PARM_NAME_CLIENT_ID, PARM_NAME_DATE_RANGE, PARM_NAME_INCLUDE_ZEROS];
        opts.reportNumber = '<%=Spedmon.Constants.REPT_NUM_CLAIMS_PAID_BY_DOS_1P%>';
        opts.reportFormat = 7;
        opts.instructionsEnabled = true;
        opts.instructionsPosition = 'bottom-left';
        opts.instructionsContent = $($dashboardItemReimburseAmtsByDosThisYearInstructions).html();
        $($dashboardItemReimburseAmtsByDosThisYear).MBA_ActionItemGauge(opts);
    }

    function initDashBoardItemReimburseAmtsByDowThisYear() {
        
        $dashboardItemReimburseAmtsByDowThisYear             = $('#reimburseamtsbydowthisyear');
        $dashboardItemReimburseAmtsByDowThisYearInstructions = $('#reimburseamtsbydowthisyearinstructions');

        let opts = {};
        opts.label = 'Reimbursement By Check Date For This Year';
        opts.urlSessionExpiredLink = URL_SESSION_EXPIRED_LINK;
        opts.requestDataUrlBase = '<%=Spedmon.LeaBopHealthCommon.URL_WEB_SVC_AMTS_BY_DOW_FOR_THIS_YEAR()%>';
        opts.requestDataFieldNames = ['' + PARM_NAME_CLIENT_ID, PARM_NAME_REP_ID];
        opts.autoSetUpdateRequestDataParametersFromRequestDataFieldNames = true;
        opts.gaugeType = MBA.ActionItemGaugeCommon.GAUGE_TYPE.financialProgress;
        opts.fnGenerateGaugeTitle = function (totalNumAmt) {            
            return 'Annual Goal is $' + totalNumAmt.goalAmtStr;
        };
        opts.reportUrlBase = '<%=Spedmon.Reports.Fianancial.URL_REPORT_BASE()%>';
        opts.reportDataFieldNames = ['' + PARM_NAME_CLIENT_ID, PARM_NAME_DATE_RANGE, PARM_NAME_INCLUDE_ZEROS];
        opts.reportNumber = '<%=Spedmon.Constants.REPT_NUM_CLAIMS_PAID_BY_DOW_1P%>';
        opts.reportFormat = 7;
        opts.instructionsEnabled = true;
        opts.instructionsPosition = 'bottom-left';
        opts.instructionsContent = $($dashboardItemReimburseAmtsByDowThisYearInstructions).html();

        $($dashboardItemReimburseAmtsByDowThisYear).MBA_ActionItemGauge(opts);
    }

    function initDashBoardItemPotentialLostAmtMissingTmts() {
        $dashboardItemPotentialLostAmtMissingTmts = $('#potlostamtmissingtmts');
        $dashboardItemPotentialLostAmtMissingTmtsInstructions = $('#potlostamtmissingtmtsinstructions');

        let opts = {};
        opts.label = 'Projected Reimbursement for Promised Services';
        opts.urlSessionExpiredLink = URL_SESSION_EXPIRED_LINK;
        opts.requestDataUrlBase = '<%=Spedmon.MissingServicesTreatmentsSummary.URL_WEB_SVC_GET_MISSING_TREATMENTS_SUMMARY()%>';
        opts.requestDataFieldNames = ['' + PARM_NAME_CLIENT_ID];
        opts.autoSetUpdateRequestDataParametersFromRequestDataFieldNames = true;
        opts.barChartMode = 'horizontal';
        opts.actionURL = '<%=Spedmon.MissingServicesTreatmentDetails.URL_PAGE_MANAGE_BASE()%>';
        
        opts.additionalContent = $("<div><sup>Please click on a graph bar below for greater detail. Amounts are updated nightly and are calculated using your LEA's special education plan data and services entered in SpEdCare by providers. Amounts listed are still eligible, as they are within the 12 month claiming window.</sup></div>");
        opts.instructionsEnabled = false;
        opts.instructionsPosition = 'left';
        opts.instructionsContent = $($dashboardItemPotentialLostAmtMissingTmtsInstructions).html();
        $($dashboardItemPotentialLostAmtMissingTmts).MBA_ActionItemBarChart(opts);
    }

    function initDashBoardItemPotentialLostReimbursements() {
        $dashboardItemPotentialLostReimbursements = $('#potlostreimbursements');
        $dashboardItemPotentialLostReimbursementsInstructions = $('#potlostreimbursementsinstructions');
        let opts = {};
        opts.label = 'Potential Reimbursements';
        opts.pieChartType = 1;
        opts.urlSessionExpiredLink = URL_SESSION_EXPIRED_LINK;
        opts.requestDataUrlBase = '<%=Spedmon.LeaBopHealthCommon.WEB_SVC_POT_LOST_REIMBURSEMENT_AMTS()%>';
        opts.requestDataFieldNames = ['' + PARM_NAME_CLIENT_ID, PARM_NAME_REP_ID];
        opts.autoSetUpdateRequestDataParametersFromRequestDataFieldNames = true;
        opts.additionalContent = $('<div><sup>Please click on each slice below for more details.</sup></div>');
        opts.instructionsEnabled = true;
        opts.instructionsPosition = 'bottom-left';
        opts.instructionsContent = $($dashboardItemPotentialLostReimbursementsInstructions).html();
        $($dashboardItemPotentialLostReimbursements).MBA_ActionItemPieChart(opts);


        $dashboardItemPotentialLostReimbursements.parent().addClass('h-100');
    }

    function initDashBoard2AMomentStats(clientid) {
      $('#iframeRmtsDashStats').attr(
       'src',
       '<%= Spedmon.RmtsMomentMissingOrUndocumentedStatsObjs.URL_PAGE_STATSDASH_PRE_BASE() %>' +
         '&clientid=' + clientid
      );
    }



    function initDashBoardItemClaimsPaid() {
        $dashboardItemClaimsPaid = $('#claimspaid');
        $dashboardItemClaimsPaidInstructions = $('#claimspaidinstructions');

        let opts = {};
        opts.label = 'Claims Paid';
        opts.urlSessionExpiredLink = URL_SESSION_EXPIRED_LINK;
        opts.requestDataUrlBase = '<%=Spedmon.LeaBopHealthCommon.WEB_SVC_CLAIMS_PAID_2P()%>';
        opts.requestDataFieldNames = ['' + PARM_NAME_CLIENT_ID, PARM_NAME_REP_ID];
        opts.autoSetUpdateRequestDataParametersFromRequestDataFieldNames = true;
        opts.barChartMode = 'scatter';
        opts.additionalContent = $('<div class="' + CLAIMS_PAID_REPORTS_CONT_CLASS + ' d-flex justify-content-around">'
                                    + '<span id="' + CLAIMS_PAID_PRAC_SUBMISSION_RPT_ID + '" class="text-primary">Practitioner Submission Report</span>'
                                    + '<span id="' + CLAIMS_PAID_CLAIMS_COMPARISON_RPT_ID + '" class="text-primary">Claims Comparison By Reporting Group</span>'
                                    + '</div>');
        opts.instructionsEnabled = false;
        opts.instructionsPosition = 'bottom';
        opts.instructionsContent = $($dashboardItemClaimsPaidInstructions).html();
        $($dashboardItemClaimsPaid).MBA_ActionItemBarChart(opts);
    }


    function initDashBoard() {
      $dashboardRows = $('#dashboardrows');
      $linkGotoManageClientComplianceTasks = $('#gotomanageclientcompliancetasks');
      
      <% // TODO: remove??  %>

      //initDashBoardItemReimburseAmtsByDosThisYear();
      //initDashBoardItemReimburseAmtsByDowThisYear();

      initDashBoardItemPotentialLostReimbursements();
      if (PREVIEW_ONLY) return;
      initDashBoardItemPotentialLostAmtMissingTmts();
      initDashBoardItemClaimsPaid();

      // initDashBoard2AMomentStats();
    }

    function updateDashBoard(e)
    {
      let _vcid           = $('#' + PARM_NAME_CLIENT_ID).val();
      let _nvpClientIDObj = MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, _vcid);
      $($linkGotoManageClientComplianceTasks).MBA_Link('requestDataParameterSetOrUpdate', _nvpClientIDObj);
        //$($dashboardItemReimburseAmtsByDosThisYear).MBA_ActionItemGauge('getData');
      //$($dashboardItemReimburseAmtsByDowThisYear).MBA_ActionItemGauge('getData');      
      $($dashboardItemPotentialLostReimbursements).MBA_ActionItemPieChart('getData');
      if (!PREVIEW_ONLY) {
        $($dashboardItemClaimsPaid).MBA_ActionItemBarChart('getData');
        
          if ($('#' + PARM_NAME_CLIENT_ID).val()) {
              $($dashboardItemPotentialLostAmtMissingTmts).MBA_ActionItemBarChart('getData');
          } else if ($('#' + PARM_NAME_REP_ID).val()) {
              // promised svcs widget not supported for consultant view
              $($dashboardItemPotentialLostAmtMissingTmts).html('');
          }
        MBA.ClientComplianceTasks.fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer() ;

        initDashBoard2AMomentStats( _vcid ) ;
      }
    }

    function generateReqDataForRpt(rptElemID) {
        let reqData = [];

        if (rptElemID == CLAIMS_PAID_PRAC_SUBMISSION_RPT_ID) {
            reqData = [
                MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, $('#' + PARM_NAME_CLIENT_ID).val())
                , MBA.ComponentCommon.fnCreateNameValueObject('as-of-date', '<%=dateToday%>')
            ];
        }

        if (rptElemID == CLAIMS_PAID_CLAIMS_COMPARISON_RPT_ID) {
            reqData = [
                MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, $('#' + PARM_NAME_CLIENT_ID).val())
                , MBA.ComponentCommon.fnCreateNameValueObject('daterange', '<%=dateRangeLastFY%>')
                , MBA.ComponentCommon.fnCreateNameValueObject('daterange2', $('#' + PARM_NAME_DATE_RANGE).val())
                , MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_INCLUDE_ZEROS, $('#' + PARM_NAME_INCLUDE_ZEROS).val())
            ];
        }

        return reqData;
    }

    function addSupportForClaimsPaidRpt(rptElemID, reqUrl, rptFormat, rptNumber, popUpUrl) {
        $('#' + rptElemID).on('click', function () {

            if ($('#' + PARM_NAME_CLIENT_ID).val()) {
                let rptElemText = $('#' + rptElemID).html();
                $('#' + rptElemID).html('<span class="text-dark ' + ANIMATION_PULSE_CLASS + '">Please wait, generating file.</span>');

                /* generate reqData (Not passed in due to the fact that clientid could change) */

                let reqData = generateReqDataForRpt(rptElemID);

                MBA.ComponentCommon.fnRequestDownloadWebReportDocument(reqUrl
                    , rptFormat
                    , rptNumber
                    , 'Report'
                    , reqData
                    , function () {
                        $('#' + rptElemID).html('<span class="text-success">File successfully downloaded.</span>');

                        setTimeout(function () {
                            $('#' + rptElemID).html(rptElemText);
                        }, 3000);
                    }
                    , function () {
                        $('#' + rptElemID).html('<span class="text-danger">Something went wrong.</span>');

                        setTimeout(function () {
                            $('#' + rptElemID).html(rptElemText);
                        }, 3000);
                    });
            }
            else if ($('#' + PARM_NAME_REP_ID).val()) {
                // consultants will see the pop-up screen instead of report download

                // we need the url as a subpage (if not already)
                if (popUpUrl.indexOf('&amd=uidbssub') == -1) {
                    popUpUrl += '&amd=uidbssub';
                }

                $.spedmonWebUI.openURL(popUpUrl, 1);
            }

        });
    }

    function wireUpPracSubmissionsRpt() {
        $('#' + CLAIMS_PAID_PRAC_SUBMISSION_RPT_ID).on('click', function () {            
            let reqUrl = '<%=Spedmon.ServicesByPracRpt.URL_USER_ALL_RPT_BASE()%>'
                + '&<%=Constants.PARM_APP_MODE%>=<%=Constants.AMD_UI_DBS_SUB_PAGE%>';

            $.spedmonWebUI.openNewWindow(reqUrl, 'Services By Prac Report', null);               
        });
    }

    function addRptPopUpLink($elem, reqUrl) {
        // report pop-up links identified by rpt-popup class, downloads identified by rpt-download

        if ($($elem).siblings('.rpt-popup').length < 1) {
            let $rptDownloadCont = $($elem).siblings('.mba-action-item-gauge-reports')[0];
            $($rptDownloadCont).addClass('rpt-download');

            let $rptLinkCont = $('<div class="mba-action-item-gauge mba-action-item-gauge-reports rpt-popup"></div>');
            let $rptLinkSpan = $('<span class="text-primary">Click to Download Report <i class="fa fa-link"></i></span>');

            $($rptLinkCont).append($rptLinkSpan);
            $($rptLinkCont).insertAfter($rptDownloadCont);

            $($rptLinkSpan).on('click', function () {
                // we need the url as a subpage (if not already)
                if (reqUrl.indexOf('&amd=uidbssub') == -1) {
                    reqUrl += '&amd=uidbssub';
                }

                $.spedmonWebUI.openURL(reqUrl, 1);
            });
        }

        return;
    }

    function showAndHideRptLink($elem) {
        let $rptDownload = $($elem).siblings('.rpt-download');
        let $rptPopUp = $($elem).siblings('.rpt-popup');
        
        if ($('#' + PARM_NAME_CLIENT_ID).val()) {
            $($rptDownload).show();
            $($rptPopUp).hide();
        }
        else if ($('#' + PARM_NAME_REP_ID).val()) {
            $($rptDownload).hide();
            $($rptPopUp).show();
        }

        return;
    }

    $(document).ready(function () {

        initDashBoard();

        $($dashboardRows).on('spedmoninputdata', function (e) { 
            updateDashBoard(e);
        });

        if ($('#' + PARM_NAME_CLIENT_ID).val()) {
            updateDashBoard(null);
        }  

        /* different report download functionality for consultants view */

        $($dashboardItemReimburseAmtsByDowThisYear).on('plotly_afterplot', function () {
            addRptPopUpLink($dashboardItemReimburseAmtsByDowThisYear
                           , '<%=Spedmon.Reports.Fianancial.URL_RPT_CLAIMS_PAID_BASE()%>');

            showAndHideRptLink($dashboardItemReimburseAmtsByDowThisYear);
        });

        $($dashboardItemReimburseAmtsByDosThisYear).on('plotly_afterplot', function () {
            addRptPopUpLink($dashboardItemReimburseAmtsByDosThisYear
                , '<%=Spedmon.Reports.Fianancial.URL_RPT_CLAIMS_PAID_BY_DOS_BASE()%>');

            showAndHideRptLink($dashboardItemReimburseAmtsByDosThisYear);
        });

        /* add functionality to Claims Paid reports */

        wireUpPracSubmissionsRpt();

        addSupportForClaimsPaidRpt(CLAIMS_PAID_CLAIMS_COMPARISON_RPT_ID
            , '<%=Spedmon.Reports.Fianancial.URL_REPORT_BASE()%>'
                , 7
            , '<%=Spedmon.Constants.REPT_NUM_CLAIMS_PAID_BY_DOS_2P%>'
            , '<%=Spedmon.Reports.Fianancial.URL_RPT_CLAIMS_PAID_BY_DOS_COMPARED_BASE()%>'
        );
    });


    var complianceRestviewOptsIn = {};

    complianceRestviewOptsIn.dataEntryRowsDivID         = 'dataEntryRows'           ;
    complianceRestviewOptsIn.dataManagementDivID        = 'dataManagementRows'      ;
    complianceRestviewOptsIn.restViewDivID              = 'restViewComplianceMgmt'  ;

    complianceRestviewOptsIn.PARM_NAME_CLIENT_ID        = '<%=Constants.PARM_CLIENT_ID%>';
    complianceRestviewOptsIn.PARM_NAME_TASK_ID          = '<%=Constants.PARM_TASK_ID%>';
    complianceRestviewOptsIn.PARM_NAME_IS_COMPLETE      = '<%=Constants.PARM_IS_COMPLETE%>';
    complianceRestviewOptsIn.PARM_NAME_IS_PENDING       = '<%=Constants.PARM_IS_PENDING%>';
    complianceRestviewOptsIn.PARM_NAME_IS_NOT_COMPLETED = '<%=Constants.PARM_IS_NOT_COMPLETED%>';
    complianceRestviewOptsIn.PARM_NAME_IS_COMPLETED     = '<%=Constants.PARM_IS_COMPLETED%>';
    complianceRestviewOptsIn.PARM_NAME_FY_ID            = '<%=Constants.PARM_FISCAL_YEAR_ID %>';


    complianceRestviewOptsIn.generateSessionExpiredLink   =   '<%=MBA.Credential.generateSessionExpiredLink()%>';
    complianceRestviewOptsIn.sessionTimeOutUrl            =   complianceRestviewOptsIn.generateSessionExpiredLink;

    complianceRestviewOptsIn.URL_SAVE_BASE                =   '<%=Spedmon.ClientComplianceTasks.URL_SAVE_BASE()%>';
    complianceRestviewOptsIn.baseUrlEdit                  =   complianceRestviewOptsIn.URL_SAVE_BASE;

    complianceRestviewOptsIn.URL_REST_VIEW_BASE           =   '<%=Spedmon.ClientComplianceClientItems.URL_REST_VIEW_BASE()%>';
    complianceRestviewOptsIn.baseUrlView                    =   complianceRestviewOptsIn.URL_REST_VIEW_BASE;

    complianceRestviewOptsIn.defaultPageRowOrder          =   '<%=Spedmon.ClientComplianceClientItem.DEFAULT_PAGING_ORDER%>';


    complianceRestviewOptsIn.URL_LOAD_N_BASE              =   '<%=Spedmon.ClientComplianceItems.URL_LOAD_N_BASE()%>';


    complianceRestviewOptsIn.URL_SAVE_FOR_CLIENTS_BASE    =   '<%=Spedmon.ClientComplianceCommon.URL_SAVE_FOR_CLIENTS_BASE()%>';

    complianceRestviewOptsIn.reportBaseUrl                =  '<%= Spedmon.ClientComplianceClientItems.URL_WEB_REPORT_BASE() %>'


    // hardcoding these two for the restview preview
    complianceRestviewOptsIn.isPcalStaff = 0 ;
    complianceRestviewOptsIn.isRestviewPreview = 1 ;

    $(document).ready( function(){ MBA.ClientComplianceTasks.fnSetup(complianceRestviewOptsIn)  } );

</script>