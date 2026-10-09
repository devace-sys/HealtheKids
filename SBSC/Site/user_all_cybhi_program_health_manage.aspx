<%@ Page Language="C#" CodeBehind="user_all_cybhi_program_health_manage.aspx.cs" Inherits="Spedmon.UserAllCYBHIProgramHealthManage"%>

<%//######################################################################################################################%>
<%//#                                               Markup %>
<%//######################################################################################################################%>

<%//-----------------------------------------------------------------------------%>
<%// If applicable show client name and if applicable summary view only message  %>
<%//                                                                             %>
<%// Note: Summary only view is determined in middleware and if summary only     %>
<%//       drill down urls will not returned.                                    %>
<%//-----------------------------------------------------------------------------%>

<%if (showClientName == true){%>
<div class="text-center mb-2">
  <%=clientName%>
  <%if(showNoDrillDownMessage == true){%> - <em>Summary View Only</em><%}%>
</div>
<%}%>
    
<div id="dashboardrows" class="container-fluid">    

<%//-----------------------------------------------------------------------------%>
<%// Select Client Row (Practi-Cal staff only) %>
<%//-----------------------------------------------------------------------------%>
  
  <div id="row1" class="row">
        
   <div class="col-12">

      <Spedmon:DataEntryRowSelectClient
          ID                   = "selectClient" 
          entityControlID      = "clientid"                
          rowLabel             = "Client"
          dataEntryRowRenderAs = "FIELD" 
          showClearSelection   = "true"
          runat                = "server">
      </Spedmon:DataEntryRowSelectClient>
      
    </div> <!-- col -->
 
  </div> <!-- row -->

  <%//-----------------------------------------------------------------------------%>
  <%// Row 2  %>
  <%//-----------------------------------------------------------------------------%>

  <div id="row2" class="row">

  <%//-----------------------------------------------------------------------------%>
  <%// Row 2 Left Col  %>
  <%//-----------------------------------------------------------------------------%>
  
  <div id="row2leftcol" class="col-6">

  <%//-----------------------------------------------------------------------------%>
  <%// Row 2 Left Col Content Container %>
  <%//-----------------------------------------------------------------------------%>

  <div class="container-fluid">
 
  <%//-------------------------------------------------------------------------------%>
  <%// Health Counters Row (cols added via script) %>
  <%//-------------------------------------------------------------------------------%>

  <div id="healthcounters" class="row">
  </div> <!-- row -->    

  <div class="row">
  <div class="col-12">

  <%//-----------------------------------------------------------------------------%>
  <%// Amounts Paid By Prac Disp Group Chart %>
  <%//-----------------------------------------------------------------------------%>

    <div class="mba-action-items-container cybhi-program-health-stat-container cybhi-program-health-stat-container-summary-tbl">
      <h5 class="text-center mt-1">Summary By Rendering Discipline</h5>
        <table class="table table-sm table-bordered table-striped">
            <thead>
            <tr>
                <th class="font-weight-bold">Discipline</th>
                <th class="font-weight-bold">Services<br />Documented</th>
                <th class="font-weight-bold">Total<br/>Minutes</th>
                <th class="font-weight-bold">Amount<br />Claimable</th>
                <th class="font-weight-bold">Amount<br />Paid</th>               
            </tr>
            </thead>
            <tbody id="amountPaidByDispTbody">
            </tbody>
        </table>
      
      </div> <!-- action items container -->      

    <%//-----------------------------------------------------------------------------%>
    <%// Amounts Paid By Prac Chart %>
    <%//-----------------------------------------------------------------------------%>

    <div class="mba-action-items-container cybhi-program-health-stat-container cybhi-program-health-stat-container-summary-tbl ">
      <h5 class="text-center mt-1">Summary By Rendering Practitioner</h5>
        <table class="table table-sm table-bordered table-striped">
            <thead>
            <tr>
                <th class="font-weight-bold">Name</th>
                <th class="font-weight-bold">Services<br />Documented</th>
                <th class="font-weight-bold">Total<br/>Minutes</th>
                <th class="font-weight-bold">Amount<br />Claimable</th>
                <th class="font-weight-bold">Amount<br />Paid</th>          
            </tr>
            </thead>
            <tbody id="amountPaidByPracTbody">
            </tbody>
        </table>
      
      </div> <!-- action items container -->


  </div> <!-- col -->
  </div> <!-- row -->
  </div> <!-- container -->
  
  </div> <!-- row2 left col -->

  <%//-----------------------------------------------------------------------------%>
  <%// Row 2 Right Col %>
  <%//-----------------------------------------------------------------------------%>

  <div id="row2rightcol" class="col-6">
  
  <%//-----------------------------------------------------------------------------%>
  <%// Row 2 Right Col Content Container %>
  <%//-----------------------------------------------------------------------------%>

    <div class="container-fluid">
    
    <%//-----------------------------------------------------------------------------%>
    <%// Dials Row %>
    <%//-----------------------------------------------------------------------------%>

   <div class="row"> 
   <div class="col-6">
   <div class="mba-action-items-container cybhi-program-health-stat-container">
   <h5 class="text-center" style="margin-top: 5px;">Average Amount Paid<br />Per Client</h5>
   <div class="d-flex justify-content-center align-items-center">
   <div id="moneyspentgauge" style="height:8em;max-height:8em;"></div>
   </div>
   <h5 id="moneyspentamt" class="text-center mt-1"></h5>
   </div> <!-- action items container -->
   </div> <!-- col -->

   <div class="col-6">   
   <div class="mba-action-items-container cybhi-program-health-stat-container">
   <h5 class="text-center" style="margin-top: 5px;">Average Amount Paid<br />Per Practitioner</h5>
   <div class="d-flex justify-content-center align-items-center">
   <div id="moneyspentpractitionergauge" style="height:8em;max-height:8em;"></div>
   </div>
   <h5 id="moneyspentpractitioneramt" class="text-center mt-1"></h5>
   </div> <!-- action items container -->
   </div> <!-- col -->
    
    </div> <!-- row -->   
    
    <%//-----------------------------------------------------------------------------%>
    <%// Chart Row  %>
    <%//-----------------------------------------------------------------------------%>

    <div class="row mt-3">
    <div class="col-12">
    <div class="mba-action-items-container cybhi-program-health-stat-container">
    <h5 class="text-center" style="margin-top: 5px;">Amounts By Date of Service</h5>
    <div id="svcspaidbydoschart"></div>
    </div> <!-- action items container -->         
    
    <%//-----------------------------------------------------------------------------%>
    <%// Amounts Paid By Service %>
    <%//-----------------------------------------------------------------------------%>

    <div class="mba-action-items-container cybhi-program-health-stat-container cybhi-program-health-stat-container-summary-tbl">
      <h5 class="text-center mt-1">Summary By Service</h5>
        <table class="table table-sm table-bordered table-striped">
            <thead>
            <tr>
                <th class="font-weight-bold">Name</th>
                <th class="font-weight-bold">Total<br/>Documented</th>
                <th class="font-weight-bold">Total<br/>Minutes</th>
                <th class="font-weight-bold">Amount<br />Claimable</th>
                <th class="font-weight-bold">Amount<br />Paid</th>               
            </tr>
            </thead>
            <tbody id="amountPaidBySvcTbody">
            </tbody>
        </table>
      
      </div> <!-- action items container -->


    </div> <!-- col -->
    </div> <!-- row -->

    
    </div> <!-- container -->
    </div> <!-- row 2 right col -->
        
  </div> <!-- row 2 -->

  <div id="row3" class="row">
  <div class="col-12">
    
    <%//-----------------------------------------------------------------------------%>
    <%// Amounts Held %>
    <%//-----------------------------------------------------------------------------%>

    <div id="amountHeldByHoldCodeCont" class="mba-action-items-container cybhi-program-health-stat-container cybhi-program-health-stat-container-summary-tbl">
      <h5 class="text-center mt-1">Claims Processing Summary</h5>
        <table class="table table-sm table-bordered table-striped">
            <thead>
            <tr>
                <th class="font-weight-bold">Processing Remark</th>
                <th class="font-weight-bold">Services</th>
                <th class="font-weight-bold">Minutes</th>
                <th class="font-weight-bold">Amount</th>                                
            </tr>
            </thead>
            <tbody id="amountHeldByHoldCodeTbody">
            </tbody>
        </table>
      
      </div> <!-- action items container -->
  </div> <!-- col -->
  </div> <!-- row -->

</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">
    
    const PARM_NAME_CLIENT_ID       = '<%=Constants.PARM_CLIENT_ID%>';
    const URL_SESSION_EXPIRED_LINK  = '<%=MBA.Credential.generateSessionExpiredLink()%>';
    const SVCS_PAID_BY_DOS_CHART_ID = 'svcspaidbydoschart';

    let $dashboardRows                           = null;
    let $row2leftcol                             = null;
    let $row2rightcol                            = null;
    let $row3                                    = null;
    let $healthCountersRow                       = null;
    let $dashboardItemMoneySpentGauge            = null;
    let $dashboardItemMoneySpentPerPracGauge     = null;
    let $dashboardItemMoneySpentAmt              = null;
    let $dashboardItemMoneySpentPractitionerAmt  = null;
    let $servicesPaidByDosChart                  = null;    
    let $amountPaidByDispTbody                   = null;
    let $amountPaidByPracTbody                   = null;
    let $amountPaidBySvcTbody                    = null; 
    let $amountHeldByHoldCodeTbody               = null; 

    <%/*--------------------------------------------------------------------------------------------------*/%>

    function assignAndStyleDetailsUrl($row, actionURL) {
        if (actionURL == "") return;
        let $anch = $($row).find('a').first();
        $($anch).addClass('cybhi-program-health-details-link');
        $($anch).attr('title', 'Tap or click to view details');
        $($anch).append('<i class="fas fa-link fa-sm ml-1"></i>');
        $($anch).on('click', function () {
            const _detailsURL = $($anch).attr('data-url-open');
            MBA.ComponentCommon.fnOpenTab(_detailsURL);
        });      
    };

    <%/*--------------------------------------------------------------------------------------------------*/%>

    function clearHealthCounters() {
        $($dashboardItemMoneySpentAmt).html('$0');
        $($dashboardItemMoneySpentPractitionerAmt).html('$0');
        $($dashboardItemMoneySpentGauge).MBA_ActionItemDialGauge('setValue', 0);
        $($dashboardItemMoneySpentPerPracGauge).MBA_ActionItemDialGauge('setValue', 0);
        $($servicesPaidByDosChart).html('');
        
        $($healthCountersRow).html('');   //


        $($amountPaidByDispTbody).empty();
        $($amountPaidByPracTbody).empty();
        $($amountPaidBySvcTbody).empty();
        $($amountHeldByHoldCodeTbody).empty();
    };


    <%/*--------------------------------------------------------------------------------------------------*/%>

    async function generateAmountPaidByGroupTbl(totNumAmt) {   //

        // debugger;

        let data = JSON.parse(totNumAmt.valuesJSON);
        $amountPaidByDispTbody.empty();
        data.forEach(item => 
        {
            const actionUrlGrp = totNumAmt.actionURL + 
               '&groupid=' + item.groupID;

            const formattedAmountClaimable = `$${item.totAmtClaimable.toLocaleString('en-US')}`;
            const formattedAmountPaid      = `$${item.totAmtPaid.toLocaleString('en-US')}`;
 
            // NOTE: i've never-before encountered the tilde-mark quote syntax in JS.
            //       apparently is supports dollar-bracket string substitution?  neat i guess.

            ////
            const row = `<tr>
                          <td>
                             <a data-url-open="${actionUrlGrp}">
                               ${item.dispGroup}
                             </a>
                          </td> 
                          <td>${item.numSvcs}</td>
                          <td>${item.totMins}</td>
                          <td>${formattedAmountClaimable}</td>
                          <td>${formattedAmountPaid}</td>                          
                        </tr>`;

            let $row = $(row);
            $amountPaidByDispTbody.append($row);
            assignAndStyleDetailsUrl($row, totNumAmt.actionURL);
        });
    };

    <%/*--------------------------------------------------------------------------------------------------*/%>

    async function generateAmountPaidByPracTbl(totNumAmt) {    // //
        let data = JSON.parse(totNumAmt.valuesJSON);
        $amountPaidByPracTbody.empty();
        data.forEach(item => {

            const actionUrlPrac = totNumAmt.actionURL + 
               '&pracid=' + item.pracID;

            const formattedAmountClaimable = `$${item.totAmtClaimable.toLocaleString('en-US')}`;
            const formattedAmountPaid      = `$${item.totAmtPaid.toLocaleString('en-US')}`;
            
            const row = `<tr>
                          <td>
                              <a data-url-open="${actionUrlPrac}">
                                  ${item.pracName}<br/>${item.groupName}<br>NPI : ${item.npi} - CYBHI TPA ID : ${item.tpaID}
                              </a>
                          </td>
                          <td>${item.numSvcs}</td>
                          <td>${item.totMins}</td>
                          <td>${formattedAmountClaimable}</td>
                          <td>${formattedAmountPaid}</td>                          
                        </tr>`;
            
            let $row = $(row);
            $amountPaidByPracTbody.append($row);
            assignAndStyleDetailsUrl($row, totNumAmt.actionURL);
        });

    };

    <%/*--------------------------------------------------------------------------------------------------*/%>

    async function generateAmountPaidBySvcTbl (totNumAmt) {  //
        let data = JSON.parse(totNumAmt.valuesJSON);        
        $amountPaidBySvcTbody.empty();
        
        data.forEach(item => {

            const actionUrlSvcId = totNumAmt.actionURL + 
               '&nameid=' + item.nameID;

            const formattedAmountClaimable = `$${item.totAmtClaimable.toLocaleString('en-US')}`;
            const formattedAmountPaid = `$${item.totAmtPaid.toLocaleString('en-US')}`;
            const row = `<tr>
                          <td>
                              <a data-url-open="${actionUrlSvcId}">
                                  ${item.svcName}
                              </a>
                          </td>
                          <td>${item.numSvcs}</td>
                          <td>${item.totMins}</td>
                          <td>${formattedAmountClaimable}</td>
                          <td>${formattedAmountPaid}</td>                          
                        </tr>`;
            let $row = $(row);
            $amountPaidBySvcTbody.append($row);
            assignAndStyleDetailsUrl($row,totNumAmt.actionURL);
        });
    };

<%/*--------------------------------------------------------------------------------------------------*/%>

    async function generateProcessingSumary (totNumAmt) {
        let data = JSON.parse(totNumAmt.valuesJSON);
        $amountHeldByHoldCodeTbody.empty();
        data.forEach(item => {

            const formattedAmountClaimable = `$${item.totAmtClaimable.toLocaleString('en-US')}`;            
            
            const row = `<tr>
                          <td>${item.processingRemark}</td>
                          <td>${item.numSvcs}</td>                          
                          <td>${item.totMins}</td>                          
                          <td>${formattedAmountClaimable}</td>
                        </tr>`;

            let $row = $(row);

            $($row).attr('data-processing-remark-code', item.processingRemarkCode);
            $($row).attr('data-hold-code',              item.holdCode);

            $amountHeldByHoldCodeTbody.append($row);
        });
    };

    <%/*--------------------------------------------------------------------------------------------------*/%>

    async function plotServicesPaidByDOS(totNumAmt) {

        let plotVals = JSON.parse(totNumAmt.valuesJSON);

        let trace1 = {
              x:[]
            , y:[]
            , type: 'scatter'
            , name: 'Paid'
        };

        let trace2 = {
              x: []
            , y: []
            , type: 'scatter'
            , name: 'Claimable'
        };

        plotVals.forEach((plotVal) => {
            trace1.y.push(plotVal.totAmountPaidRunning);
            trace1.x.push(plotVal.dos);
            trace2.y.push(plotVal.totAmountClaimableRunning);
            trace2.x.push(plotVal.dos);
        });
       
        var data = [trace1,trace2];

        var layout = {
              paper_bgcolor: 'rgba(0,0,0,0)'
            , plot_bgcolor: 'rgba(0,0,0,0)'
            , height:300
        };

        Plotly.newPlot(SVCS_PAID_BY_DOS_CHART_ID, data, layout, MBA.ActionItemCommon.COMMON_CHART_CONFIG);
    };

    <%/*--------------------------------------------------------------------------------------------------*/%>

    async function plotBigNum(totNumAmt) {    //

        let $healthCounterCol = $('<div class="col-3"></div>'); /* This should only be for bootstrap layout purposes. */

        let healthCounterPlotID = 'health-ctr-' + totNumAmt.additionalData1; /* Generate unique ID based on value returned in additionalData (should be unique numeric code).  PlotlyJS uses this unique id. */
        let healthCounterTooltipText = ''; /* Filled in based on type of drill down*/

        let $healthCounterCont     = $('<div class="mba-action-items-container cybhi-program-health-stat-container cybhi-program-health-counter-big-number-container"></div>');
        let $healthCounterPlotCont = $('<div class="cybhi-program-health-counter-big-number-plot-container"></div>');
        let $healthCounterPlot     = $('<div id="' + healthCounterPlotID + '" class="cybhi-program-health-counter-big-number-plot"></div>');
        let $healthCounterStatus   = $('<div class="cybhi-program-health-counter-big-number-status"></div>');

        /* Set title attribute text based on type of drill down and assign class(if applicable) */
        if (totNumAmt.actionURL != "") {
            if (totNumAmt.additionalData3 === "") {   // implements the clickopen
                if (totNumAmt.isReportDownload === true) {
                    healthCounterTooltipText = 'Click or tap to download details report';
                    $($healthCounterCont).addClass("cybhi-program-health-counter-big-number-report-download");
                }
                else {
                    healthCounterTooltipText = 'Click or tap to open details in a new tab.';
                    $($healthCounterCont).addClass("cybhi-program-health-counter-big-number-details-screen");
                }

                /* Assign title */

                $($healthCounterCont).attr('title', healthCounterTooltipText);

            }
        }

        /* Combine health counter elements  */

        $($healthCounterPlotCont).append($healthCounterPlot);
        $($healthCounterCont).append($healthCounterPlotCont);
        $($healthCounterCont).append($healthCounterStatus);

        /* Append to the column element*/

        $($healthCounterCol).append($healthCounterCont);

        /* Add the column */

        $($healthCountersRow).append($healthCounterCol);

        /* Wire up click event for our drill down details (if applicable) */
        if (totNumAmt.actionURL != "") {
            if (totNumAmt.additionalData3 === "") {
                $($healthCounterCont).off('click').on('click', function (e) {

                    /* Reports get downloaded */

                    if (totNumAmt.isReportDownload === true) {
                        $($healthCounterStatus).html('<div class="text-center">Downloading <i class="fa fa-spinner fa-spin"></i></div>');
                        MBA.ComponentCommon.fnRequestDownloadWebReportDocument(
                            totNumAmt.actionURL
                            , totNumAmt.rptFmt
                            , totNumAmt.rptNum
                            , totNumAmt.label
                            , null
                            , function () { $($healthCounterStatus).html('') }
                            , function () { $($healthCounterStatus).html('') });
                    }
                    /* Everything else gets opened in new tab */

                    else {
                        MBA.ComponentCommon.fnOpenTab(totNumAmt.actionURL);
                    }
                });
            }
        }

        /* Apply dynamic number color (based on value) if applicable */

        let numberColor = '#000000';
        if (totNumAmt.additionalData1 === "6000") {
            if (totNumAmt.totalNumVal > 0)
                numberColor = 'green';
        }
        else if (totNumAmt.additionalData4 === "") {   //
            if (totNumAmt.totalNumVal == 0) {
                numberColor = 'green';
            } else {
                numberColor = 'red';
            }
        }
        var data = [
            {
                type: "indicator"
                , mode: "number"
                , title: {
                    text: totNumAmt.label
                    , font: {
                        size: 12
                        , color: '#000000'
                    }
                }
                , number: {
                    font: {
                        size: 25
                        , color: numberColor
                    }
                }
                , value: totNumAmt.totalNumVal
            }
        ];

        var layout = {
            paper_bgcolor: 'rgba(0,0,0,0)'
            , plot_bgcolor: 'rgba(0,0,0,0)'
            , height: 90
            
            , margin: { t: 1, b: 1, l: 1, r: 1 }
        };

        Plotly.newPlot(healthCounterPlotID, data, layout, MBA.ActionItemCommon.COMMON_CHART_CONFIG);
    };

    <%/*--------------------------------------------------------------------------------------------------*/%>

    async function plotCYBHIProgramHealthCounters(totNumAmts) {

        // debugger;
                
        totNumAmts.forEach((totNumAmt) => {

            if (totNumAmt.additionalData1 == "7010") {
                $($dashboardItemMoneySpentAmt).html('$' + totNumAmt.totalAmtStr);                
                $($dashboardItemMoneySpentGauge).MBA_ActionItemDialGauge('setValue', totNumAmt.totalAmtVal);
            }
            else if (totNumAmt.additionalData1 == "7020") {
                $($dashboardItemMoneySpentPractitionerAmt).html('$' + totNumAmt.totalAmtStr);
                $($dashboardItemMoneySpentPerPracGauge).MBA_ActionItemDialGauge('setValue', totNumAmt.totalAmtVal);
            }
            else if (totNumAmt.additionalData1 == "9000") { plotServicesPaidByDOS(totNumAmt); }

            else if (totNumAmt.additionalData1 == "9010") { generateAmountPaidByGroupTbl(totNumAmt); }   //

            else if (totNumAmt.additionalData1 == "9020") { generateAmountPaidByPracTbl(totNumAmt);  }
            else if (totNumAmt.additionalData1 == "9030") { generateAmountPaidBySvcTbl(totNumAmt); }
            else if (totNumAmt.additionalData1 == "9040") { generateProcessingSumary(totNumAmt); }
            else { plotBigNum(totNumAmt); }
        });
        
        return;
    };

    <%/*--------------------------------------------------------------------------------------------------*/%>

    async function getCYBHIProgramHealthStatsData(vcid) {
        let url = '<%=Spedmon.CYBHIProgramHealthStats.URL_GET_STATS_BASE()%>';
        let reqDataObj = {};
        reqDataObj[PARM_NAME_CLIENT_ID] = vcid;
        let reqDataJSON = JSON.stringify(reqDataObj);
        let responseData = await MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(url, reqDataJSON, null);
        return responseData;
	};

    <%/*--------------------------------------------------------------------------------------------------*/%>

    async function updateCYBHIProgramHealthStats(vcid) {
        let responseData = await getCYBHIProgramHealthStatsData(vcid);    //
        //console.log(responseData);
        if (responseData.status == 0) {
            await plotCYBHIProgramHealthCounters(responseData.rawData.totalNumAmts);
        }
    };

    <%/*--------------------------------------------------------------------------------------------------*/%>

    function initDashboardItemAvgAmountPaidPerClient() {
        let opts = {};
        opts.label        = 'Average Amount Paid Per Client';
        opts.initialValue = 0;
        opts.maxValue     = 1000;
        opts.showValue = false;

        opts.colorRanges = [
            {
                from: 0,
                to: 100,
                gradientColors: ['#FF6C40', '#FF6C40', '#FF6C40', '#FF6C40', '#FF6C40'],                
                bannerTextSuffix: ' dollars',
                bannerColor: 'white',
                bannerFontColor: 'black'
            },
            {
                from: 100,
                to: 500,
                gradientColors: ['#2CD9C5', '#2CD9C5', '#2CD9C5', '#2CD9C5', '#2CD9C5'],
                bannerTextSuffix: ' dollars',
                bannerColor: 'white',
                bannerFontColor: 'black'
            },
            {
                from: 500,
                to: 1000,
                gradientColors: ['#4DB04E', '#4DB04E', '#4DB04E', '#4DB04E', '#4DB04E'],
                bannerTextSuffix: ' dollars',
                bannerColor: 'white',
                bannerFontColor: 'black'
            }
        ];
        $($dashboardItemMoneySpentGauge).MBA_ActionItemDialGauge(opts);
    };

    <%/*--------------------------------------------------------------------------------------------------*/%>

    function initDashboardItemMoneySpentPerPracGauge() {
        let opts = {};
        opts.label = 'Average Amount Paid Per Practitioner';
        opts.initialValue = 0;
        opts.maxValue = 20000;
        opts.showValue = false;

        opts.colorRanges = [
            {
                from: 0,
                to: 6000,
                gradientColors: ['#FF6C40', '#FF6C40', '#FF6C40', '#FF6C40', '#FF6C40'],
                bannerTextSuffix: ' dollars',
                bannerColor: 'white',
                bannerFontColor: 'black'
            },
            {
                from: 6000,
                to: 14000,
                gradientColors: ['#2CD9C5', '#2CD9C5', '#2CD9C5', '#2CD9C5', '#2CD9C5'],
                bannerTextSuffix: ' dollars',
                bannerColor: 'white',
                bannerFontColor: 'black'
            },
            {
                from: 14000,
                to: 20000,
                gradientColors: ['#4DB04E', '#4DB04E', '#4DB04E', '#4DB04E', '#4DB04E'],
                bannerTextSuffix: ' dollars',
                bannerColor: 'white',
                bannerFontColor: 'black'
            }
        ];
        $($dashboardItemMoneySpentPerPracGauge).MBA_ActionItemDialGauge(opts);
    };


    <%/*--------------------------------------------------------------------------------------------------*/%>

    function initDashBoard() {

        $dashboardRows                          = $('#dashboardrows');
        $row2leftcol                            = $('#row2leftcol');
        $row2rightcol                           = $('#row2rightcol');
        $row3                                   = $('#row3');
        $healthCountersRow                      = $('#healthcounters');        
        $dashboardItemMoneySpentGauge           = $('#moneyspentgauge');
        $dashboardItemMoneySpentPerPracGauge    = $('#moneyspentpractitionergauge');
        $dashboardItemMoneySpentAmt             = $('#moneyspentamt');
        $dashboardItemMoneySpentPractitionerAmt = $('#moneyspentpractitioneramt');
        $amountPaidByDispTbody                  = $("#amountPaidByDispTbody");
        $amountPaidByPracTbody                  = $("#amountPaidByPracTbody");
        $amountPaidBySvcTbody                   = $("#amountPaidBySvcTbody");        
        $amountHeldByHoldCodeTbody              = $("#amountHeldByHoldCodeTbody");

        $servicesPaidByDosChart                 = $('#' + SVCS_PAID_BY_DOS_CHART_ID);

        $($row2leftcol).addClass('cybhi-program-health-stat-hidden');
        $($row2rightcol).addClass('cybhi-program-health-stat-hidden');
        $($row3).addClass('cybhi-program-health-stat-hidden');

    };

    <%/*--------------------------------------------------------------------------------------------------*/%>

    async function updateDashBoard(e) {

      $($row2leftcol).addClass('cybhi-program-health-stat-hidden');
      $($row2rightcol).addClass('cybhi-program-health-stat-hidden');
      $($row3).addClass('cybhi-program-health-stat-hidden');
      clearHealthCounters();
      let vcid = $('#' + PARM_NAME_CLIENT_ID).val();
      if (vcid == '') return;
      $.spedmonWebUI.dialogWaitShow('Retrieving and calculating CYBHI Program Health data');
      await updateCYBHIProgramHealthStats(vcid);      
      $.spedmonWebUI.dialogWaitHide();
      $($row2leftcol).removeClass('cybhi-program-health-stat-hidden');
      $($row2rightcol).removeClass('cybhi-program-health-stat-hidden');
      $($row3).removeClass('cybhi-program-health-stat-hidden');
    };

    <%/*--------------------------------------------------------------------------------------------------*/%>


    $(document).ready(function () {

        initDashBoard();
        initDashboardItemAvgAmountPaidPerClient();
        initDashboardItemMoneySpentPerPracGauge();        

        $($dashboardRows).on('spedmoninputdata', function (e) {
            updateDashBoard(e);
        });

        if ($('#' + PARM_NAME_CLIENT_ID).val()) {
            updateDashBoard(null);
        }  
  
    });


</script>