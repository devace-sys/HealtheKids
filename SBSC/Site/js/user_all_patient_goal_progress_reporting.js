;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PatientGoalProgressReporting
 * @memberof     MBA
 * @summary      Static methods used for reporting patient goal progress
 * @description  Static methods used for reporting patient goal progress
 * @requires     jQuery, MBA.ComponentCommon
 */

MBA.PatientGoalProgressReporting = (function ($) {

'use strict';


/*##############################################################################################################################################################
  #                                                                 GLOBALS
  ##############################################################################################################################################################*/
  
let URL_INDIVIDUAL_GOAL_PROGRESS_SVC_VIEW = null;
let URL_SESSION_EXPIRED_LINK              = null;
let PARM_NAME_CLIENT_ID                   = null;
let PARM_NAME_PAT_ID                      = null;
let PARM_NAME_PAT_GOAL_ID                 = null;

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const DATA_URI_IMG_GOAL_MET  = "data:image/png;base64,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";


/*##############################################################################################################################################################
  #                                                          HELPER FUNCTIONS
  ##############################################################################################################################################################*/

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnAreGlobalsDefined = function () {
   if (!URL_INDIVIDUAL_GOAL_PROGRESS_SVC_VIEW) return false;
   if (!URL_SESSION_EXPIRED_LINK)              return false;
   if (!PARM_NAME_CLIENT_ID)                   return false;
   if (!PARM_NAME_PAT_ID)                      return false;
   if (!PARM_NAME_PAT_GOAL_ID)                 return false;
   return true;
}


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

 let _fnGenerateChartTitleDiv = function (chartTitle, goalMet) {
     
     let $chartTitle = $('<div class="patient-goal-progress-chart-title" style="width:100%"></div>');
     let $title = $('<div style="display:inline-block; width:80%;">' + chartTitle + '</div>');

     $($chartTitle).append($title);

     if (goalMet == true) {
         let $goalMet = $('<img style="display:inline-block;width:20%;height:auto;" src="' + DATA_URI_IMG_GOAL_MET + '"></img>');
         $($chartTitle).append($goalMet);
     }
     return $chartTitle;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnGenerateNoDataMsgDiv = function () {
    return $('<div class="text-center text-muted">No data is available within the date range for this goal</div>');
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnSessionDetailsTbl = function (sessionDetailTblHdrRow, sessionDetailTblBodyRows) {
    let $tbl = $('<table class="table table-sm"></table>');
    let $thead = $('<thead class="thead-light"></thead>');
    $($thead).append(sessionDetailTblHdrRow);
    let $tbody = $('<tbody></tbody>');
    $.each(sessionDetailTblBodyRows, function (idx, sessionDetailTblBodyRow) {
        $($tbody).append(sessionDetailTblBodyRow);
    });
    $($tbl).append($thead);
    $($tbl).append($tbody);
    return $tbl;    
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*##############################################################################################################################################################
  #                                                                 METHODS
  ##############################################################################################################################################################*/

let _fnInit = function (
    urlIndividualGoalProgressSvcView
  , urlSessionExpiredLink
  , parmNameClientID
  , parmNamePatID
  , parmNameGoalID)
{
    URL_INDIVIDUAL_GOAL_PROGRESS_SVC_VIEW = urlIndividualGoalProgressSvcView;
    URL_SESSION_EXPIRED_LINK = urlSessionExpiredLink;
    PARM_NAME_CLIENT_ID = parmNameClientID;
    PARM_NAME_PAT_ID = parmNamePatID;
    PARM_NAME_PAT_GOAL_ID = parmNameGoalID;
}
    
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
  
/**
 * @function    _fnGetIndividualGoalProgressData
 * @private
 * @summary      Gets individual goal progress data.  Returns promise. 
 * @description  Gets individual goal progress data.  Returns promise.
 */

let _fnGetIndividualGoalProgressData = function ( clientid, patid, goalid ) {

    return new Promise((resolve, reject) => {
        if (!_fnAreGlobalsDefined()) reject ('init must be run');
        if (!clientid)               reject ('clientid is required');
        if (!patid)                  reject ('patid is required');
        if (!goalid)                 reject ('goalid is required');
        let reqDataObj = {};
        reqDataObj[PARM_NAME_CLIENT_ID]   = '' + clientid;
        reqDataObj[PARM_NAME_PAT_ID]      = '' + patid
        reqDataObj[PARM_NAME_PAT_GOAL_ID] = '' + goalid
        let reqDataJSON = JSON.stringify(reqDataObj)
        resolve(reqDataJSON);
    })
    .then(reqDataJSON => {
        return MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(URL_INDIVIDUAL_GOAL_PROGRESS_SVC_VIEW, reqDataJSON, URL_SESSION_EXPIRED_LINK);
    });
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnConvertIndividualGoalProgressDataToChartData
 * @private
 * @summary      Takes response data from svc call and returns data used to generate chart
 * @description  Takes response data from svc call and returns data used to generate chart
 */

let _fnConvertIndividualGoalProgressDataToChartData = function (rawData) {

   let chartData          = {};
   chartData.hasChartData = true;
   chartData.goalMet      = false;
   chartData.chartTitle   = rawData.header2; /* Goal title */
   chartData.objPlotlyData = {};
   
   if (rawData.hasRecords === false) {
       chartData.hasChartData = false;       
       return chartData;
   }

   chartData.goalMet                  = rawData.referenceObject1.goalMet;
   chartData.objPlotlyData.options    = { responsive: true, displayModeBar: false };
   chartData.objPlotlyData.data       = null;
   chartData.objPlotlyData.layout     = null;
   chartData.sessionDetailTblHdrRow   = null;
   chartData.sessionDetailTblBodyRows = null;

   let numSessions  = rawData.recordsReturned;
   let practiceName = rawData.header3;
   let dateRange    = rawData.header4;
    
    /* Goal progress is entered using attempts/successes score (scale 1 to 100) */

   if (rawData.referenceObject1.inputGoalProgressUsingWhat === 1) {

        let arrChartDataX         = [];
        let arrChartDataY         = [];
        let arrChartDataText      = [];
        let arrChartRangeX        = [0.9];      /* Session numbers.  Starting with .9 to help keep markers visible. */
        let arrChartRangeY        = [-1, 101];  /* Score values.  Starting with -1 to help keep markers visible */
        let arrChartDataYBaseLine = [];
        let sessionDetailTblHdrRow      = $('<tr><th>Session</th><th>Date</th><th>Score</th><th>Attempts</th><th>Successful Attempts</th></tr>');
        let arrSessionDetailTblBodyRows = [];

        arrChartRangeX.push((numSessions + .1)); /* Adding .1 to help keep markers visible */

        $.each(rawData.data, function (idx, progressData) {
            arrChartDataX.push(progressData.sessionNumber);
            arrChartDataY.push(progressData.scoreValue);
            arrChartDataText.push(progressData.notes);
            arrChartDataYBaseLine.push(rawData.referenceObject1.baseLineValue);
            let sessionDetailTblBodyRow = $('<tr>'
                + '<td>' + progressData.sessionNumber  + '</td>'
                + '<td>' + progressData.sessionDateStr + '</td>'                
                + '<td>' + progressData.scoreValue + '</td>'
                + '<td>' + progressData.totalAttemptsStr + '</td>'
                + '<td>' + progressData.successfulAttemptsStr + '</td>'
                + '</tr>');
            arrSessionDetailTblBodyRows.push(sessionDetailTblBodyRow);                        
        });

        let xAxisName = practiceName + ' Sessions (' + dateRange + ')';
        let yAxisName = 'Score Recorded';

        let objChartData = [
        {
                  x: (arrChartDataX)
                , y: (arrChartDataY)
                , text: (arrChartDataText)
                , hovertemplate: 'Session : %{x}'
                    + '<br>Score Recorded : %{y}'
                    + '<br>%{text}'
                    + '<extra></extra>'
                , type: 'scatter'
                , mode: 'lines+markers'
                , name: 'Progress Data Recorded'
                , marker: { color: 'rgb(55, 128, 191)', size: 10 }
                , line: { shape: 'linear', color: 'rgb(55, 128, 191)', width: 4, dash: 'solid' }
          }
        ];
		
		let showLegend = false;
		
	    if (rawData.referenceObject1.baseLineValue != 0) {
	      objChartData.push(
		    {
                    x: (arrChartDataX)
                  , y: (arrChartDataYBaseLine)
                  , text: 'Baseline'
                  , type: 'scatter'
                  , mode: 'lines+markers'
                  , name: 'Baseline'                
                  , line: { shape: 'linear', color: 'rgb(0, 0, 0) ', width: 4, dash: 'dot' }
            }
          );
		  showLegend = true;
		}
		
        let objChartLayout = {              
              margin: { pad: 1 }
            , autosize: true
            , showlegend: (showLegend)
            , automargin: true
            , xaxis: {
                  title: (xAxisName)
                , type: 'linear'
                , range: (arrChartRangeX)
                , rangemode: 'nonnegative'
                , autorange: false
                , fixedrange: true
                , showline: true
                , zeroline: false
                , autotick: false
                , tick0: 1
                , dtick: 1
                , nticks: (numSessions)
                , ticks: 'outside'
                , tickwidth: 1
                , ticklength: 5 /* was 10*/
                , mirror: 'ticks'
            }
            , yaxis: {
                  title: (yAxisName)
                , type: 'linear'
                , range: (arrChartRangeY)
                , rangemode: 'nonnegative'
                , autorange: false
                , fixedrange: true
                , showline: true
                , zeroline: false
                , autotick: false
                , tick0: 0
                , dtick: 5 
                , nticks: 101
                , ticks: 'outside'
                , tickwidth: 1 
                , ticklength: 5 /* Was 10*/
            }
        };

       chartData.objPlotlyData.data       = objChartData;
       chartData.objPlotlyData.layout     = objChartLayout;
       chartData.sessionDetailTblHdrRow   = sessionDetailTblHdrRow;
       chartData.sessionDetailTblBodyRows = arrSessionDetailTblBodyRows;
    }

    else if (rawData.referenceObject1.inputGoalProgressUsingWhat === 2) {

        let arrChartDataX         = [];
        let arrChartDataY1        = [];
        let arrChartDataY2        = [];
        let arrChartDataText      = [];
        let arrChartRangeX        = [0.9];     /* Session numbers.  Starting with .9 to help keep markers visible. */
        let arrChartRangeY        = [1, 10];   /* Rating values.  Starting with -1 to help keep markers visible */		
		let arrChartDataYBaseLine = [];
        let sessionDetailTblHdrRow      = $('<tr><th>Session</th><th>Date</th><th>Practitioner Rating</th><th>Patient Rating</th></tr>');
        let arrSessionDetailTblBodyRows = [];

		arrChartRangeX.push((numSessions + .1)); /* Adding .1 to help keep markers visible */

        $.each(rawData.data, function (idx, progressData) {
            arrChartDataX.push(progressData.sessionNumber);
            let _y1 = null;
            let _y2 = null;
            if (progressData.measurementValue != 0)  _y1 = progressData.measurementValue;
            if (progressData.measurementValue2 != 0) _y2 = progressData.measurementValue2;
            arrChartDataY1.push(_y1);
            arrChartDataY2.push(_y2);
			arrChartDataYBaseLine.push(rawData.referenceObject1.baseLineValue);		  		        
            arrChartDataText.push(progressData.notes);
            let sessionDetailTblBodyRow = $('<tr>'
                + '<td>' + progressData.sessionNumber + '</td>'
                + '<td>' + progressData.sessionDateStr + '</td>'                
                + '<td>' + progressData.sessionRatingPracStr + '</td>'
                + '<td>' + progressData.sessionRatingPatStr + '</td>'                
                + '</tr>');
            arrSessionDetailTblBodyRows.push(sessionDetailTblBodyRow);
        });

        let xAxisName = 'Sessions (' + dateRange + ')';
        let yAxisName = 'Rating Recorded';

        let objChartData = [
            {
                  x: (arrChartDataX)
                , y: (arrChartDataY1)
                , text: (arrChartDataText)
                , hovertemplate: 'Session : %{x}'
                    + '<br>Practitioner Session Rating Recorded : %{y}'
                    + '<br>%{text}'
                    + '<extra></extra>'
                , type: 'scatter'
                , mode: 'lines+markers'
                , name: 'Practitioner Rating'
                , marker: { color: 'rgb(31, 119, 180)', size: 10 }
                , line: { shape: 'linear', color: 'rgb(31, 119, 180) ', width: 2, dash: 'solid' }
            }
            ,{
                  x: (arrChartDataX)
                , y: (arrChartDataY2)
                , text: (arrChartDataText)
                , hovertemplate: 'Session : %{x}'
                    + '<br>Patient Session Rating Recorded : %{y}'
                    + '<br>%{text}'
                    + '<extra></extra>'
                , type: 'scatter'
                , mode: 'lines+markers'
                , name: 'Patient Rating'                
                , line: { shape: 'linear', color: 'rgb(44, 160, 44) ', width: 2, dash: 'solid' }
            }
			
        ];
		
		if (rawData.referenceObject1.baseLineValue != 0) {
	      objChartData.push(
		    {
                    x: (arrChartDataX)
                  , y: (arrChartDataYBaseLine)
                  , text: 'Baseline'
                  , type: 'scatter'
                  , mode: 'lines+markers'
                  , name: 'Baseline'                
                  , line: { shape: 'linear', color: 'rgb(0, 0, 0) ', width: 4, dash: 'dot' }
            }
          );
		}
		
        let objChartLayout = {             
              margin: { pad: 1 }
            , autosize: true
            , showlegend: true
            , automargin: true
            , xaxis: {
                title: (xAxisName)
                , type: 'linear'
                , range: (arrChartRangeX)
                , rangemode: 'nonnegative'
                , autorange: false
                , fixedrange: true
                , showline: true
                , zeroline: false
                , autotick: false
                , tick0: 1
                , dtick: 1
                , nticks: (numSessions)
                , ticks: 'outside'
                , tickwidth: 1
                , ticklength: 10
                , mirror: 'ticks'
            }
            , yaxis: {
                title: (yAxisName)
                , type: 'linear'
                , range: (arrChartRangeY)
                , rangemode: 'nonnegative'
                , autorange: false
                , fixedrange: true
                , showline: true
                , zeroline: false
                , autotick: false
                , tick0: 1
                , dtick: 1
                , nticks: 10
                , ticks: 'outside'
                , tickwidth: 1
                , ticklength: 10
            }
        };
                
       chartData.objPlotlyData.data   = objChartData;
       chartData.objPlotlyData.layout = objChartLayout;
       chartData.sessionDetailTblHdrRow = sessionDetailTblHdrRow;
       chartData.sessionDetailTblBodyRows = arrSessionDetailTblBodyRows;

    }
    
    return chartData;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnGetAndChartInDivIndivualGoalData
 * @private
 * @summary      Charts goal data in a div
 * @description  Charts goal data in a div
 */

let _fnGetAndChartInDivIndivualGoalData = function (clientid, patid, goalid, divid)
{    
    let _$divRef = $('#' + divid); /* This will be the containing element*/

    _fnGetIndividualGoalProgressData(clientid, patid, goalid).then(responseData => {
        var chartData = _fnConvertIndividualGoalProgressDataToChartData(responseData.rawData);
        let $chartTitle = _fnGenerateChartTitleDiv(chartData.chartTitle, chartData.goalMet);
        if (!chartData.hasChartData) {
            let $noDataAvailMsg = _fnGenerateNoDataMsgDiv();
            $(_$divRef).append($chartTitle);
            $(_$divRef).append($noDataAvailMsg);
          return;
        }
        Plotly.newPlot(divid, chartData.objPlotlyData.data, chartData.objPlotlyData.layout, chartData.objPlotlyData.options).then(pd => {
            let $tbl = _fnSessionDetailsTbl(chartData.sessionDetailTblHdrRow, chartData.sessionDetailTblBodyRows);
            $(_$divRef).prepend($chartTitle);
            $(_$divRef).append($tbl);
        });
        return;
    });
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnGetAndChartInDialogIndivualGoalData
 * @private
 * @summary      Charts goal data in a dialog
 * @description  Charts goal data in a dialog
 */

let _fnGetAndChartInDialogIndivualGoalData = function (clientid, patid, goalid, wpct,hpct,modal) {        
    let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(wpct);
    let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(hpct);
    var goalChartDivID = MBA.ComponentCommon.fnCreateNewUUID();
    var $goalChartDiaPlotContainerDiv = $('<div class="patient-goal-progress-chart-container patient-goal-progress-chart-container-dialog"></div>');
    var $goalChartDiaPlotDiv = $('<div id="' + goalChartDivID + '"></div>');
    $($goalChartDiaPlotContainerDiv).append($goalChartDiaPlotDiv);

    let objGoalChartDiaOpts = {
        autoOpen: true
      , width: (vw)
      , height: (vh)
      , resizable: false
      , modal: (modal)
      , draggable: false
      , open: function (event, ui) {
          _fnGetAndChartInDivIndivualGoalData(clientid, patid, goalid, goalChartDivID);          
      }
    };
    return MBA.ComponentCommon.fnCreateOneTimeDialog('Goal Progress', $goalChartDiaPlotContainerDiv, objGoalChartDiaOpts);
 }

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnGetAndChartInImgIndivualGoalData
 * @private
 * @summary      Charts goal data in a div
 * @description  Charts goal data in a div
 */

let _fnGetAndChartInImgIndivualGoalData = function (clientid, patid, goalid, divid, fnOnComplete)
{    
    if (!fnOnComplete) fnOnComplete = function (renderedChart,divRef,chartTitleRef,goalImgRef,tblRef) {
	  return;
	};
	
	let _$divRef = $('#' + divid);
	
	_fnGetIndividualGoalProgressData(clientid, patid, goalid).then(responseData => {        
        var chartData = _fnConvertIndividualGoalProgressDataToChartData(responseData.rawData);
        let $chartTitle = _fnGenerateChartTitleDiv(chartData.chartTitle, chartData.goalMet);
        if (!chartData.hasChartData) {
            let $noDataAvailMsg = _fnGenerateNoDataMsgDiv();
            $(_$divRef).append($chartTitle);
            $(_$divRef).append($noDataAvailMsg);
			fnOnComplete(false,_$divRef,$chartTitle,null,null);
            return;
        }
        let $tbl = _fnSessionDetailsTbl(chartData.sessionDetailTblHdrRow, chartData.sessionDetailTblBodyRows);
        Plotly.toImage(chartData.objPlotlyData).then(dataUri => {
            let $goalImg = $('<img class="patient-goal-progress-chart" style="width:100%;height:auto;"></img>');
            $($goalImg).attr('src', dataUri);       
            $(_$divRef).append($chartTitle);
            $(_$divRef).append($goalImg);
            $(_$divRef).append($tbl);
            fnOnComplete(true, _$divRef, $chartTitle, $goalImg, $tbl);
			return;
        });        
        return;
    });
}

/*#############################################################################################################################################################
  #                                                                   PUBLIC METHODS
  ##############################################################################################################################################################*/

return {  
    fnInit: _fnInit
  /*, fnGetIndividualGoalProgressData: _fnGetIndividualGoalProgressData*/
  /*, fnConvertIndividualGoalProgressDataToPlotlyData: _fnConvertIndividualGoalProgressDataToPlotlyData*/
  , fnGetAndChartInDialogIndivualGoalData: _fnGetAndChartInDialogIndivualGoalData
  , fnGetAndChartInDivIndivualGoalData: _fnGetAndChartInDivIndivualGoalData
  , fnGetAndChartInImgIndivualGoalData: _fnGetAndChartInImgIndivualGoalData
};

})(jQuery);

