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

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let PARM_NAME_CLIENT_ID                   = null;
let PARM_NAME_PAT_ID                      = null;
let PARM_NAME_PAT_GOAL_ID                 = null;

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnAreGlobalsDefined = function () {
   if (!URL_INDIVIDUAL_GOAL_PROGRESS_SVC_VIEW) return false;
   if (!URL_SESSION_EXPIRED_LINK)              return false;
   if (!PARM_NAME_CLIENT_ID)                   return false;
   if (!PARM_NAME_PAT_ID)                      return false;
   if (!PARM_NAME_PAT_GOAL_ID)                 return false;
   return true;
}

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

 let _fnGenerateDataUriFromPlot = async function (graphdiv) {

   await Plotly.toImage(graphDiv, { format: 'png', width: 800, height: 600 })

       .then(function (dataUri) {

         return dataUri;

       });

};

    
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
  
/**
 * @function    _fnGetIndividualGoalProgressData
 * @private
 * @summary      Gets individual goal progress data.  Returns promise. 
 * @description  Generates a unique identifier
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
 * @function    _fnConvertIndividualGoalProgressDataToPlotlyData
 * @private
 * @summary      Takes response data from svc call and returns data for plotly. 
 * @description  Takes response data from svc call and returns data for plotly.
 */

let _fnConvertIndividualGoalProgressDataToPlotlyData = function (rawData) {
   /* Expects responseData.rawData from ReturnObject */

   let objPlotlyData = {};
    objPlotlyData.hasChartData = true;

   let patName = rawData.header1;
   let goalTitle = rawData.header2;
   let chartTitle = patName + '<br>' + goalTitle;
    objPlotlyData.chartTitle = chartTitle;

   if (rawData.hasRecords === false) {
       objPlotlyData.hasChartData = false;
       return objPlotlyData;
   }

   let numSessions     = rawData.recordsReturned;
   let practiceName    = rawData.header3;
   let dateRange       = rawData.header4;
    
   let objChartOptions = { responsive: true, displayModeBar: false };

   /* Goal progress is entered using attempts/successes score (scale 1 to 100)
    * so we need to chart this
    */
    if (rawData.referenceObject1.inputGoalProgressUsingWhat === 1) {

        let arrChartDataX = [];
        let arrChartDataY = [];
        let arrChartDataText = [];
        let arrChartRangeX = [0.9];     /* Session numbers.  Starting with .9 to help keep markers visible. */
        let arrChartRangeY = [-1, 101];  /* Score values.  Starting with -1 to help keep markers visible */

        let arrChartDataYBaseLine = [];

        arrChartRangeX.push((numSessions + .1)); /* Adding .1 to help keep markers visible */

        $.each(rawData.data, function (idx, progressData) {
            arrChartDataX.push(progressData.sessionNumber);
            arrChartDataY.push(progressData.scoreValue);
            arrChartDataText.push(progressData.notes);
            arrChartDataYBaseLine.push(rawData.referenceObject1.baseLineValue);
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
            title: { text: (chartTitle), xanchor: 'center', yanchor: 'top', font: { size: 18 } }
            , margin: { pad: 1 }
            , autosize: true
            , height: 270
            , showlegend: false
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
                , tick0: 0
                , dtick: 25
                , nticks: 101
                , ticks: 'outside'
                , tickwidth: 1
                , ticklength: 10
            }
        };


        objPlotlyData.data = objChartData;
        objPlotlyData.layout = objChartLayout;
        objPlotlyData.options = objChartOptions;
    }

    else if (rawData.referenceObject1.inputGoalProgressUsingWhat === 2) {

        let arrChartDataX = [];
        let arrChartDataY1 = [];
        let arrChartDataY2 = [];
        let arrChartDataText = [];
        let arrChartRangeX = [0.9];     /* Session numbers.  Starting with .9 to help keep markers visible. */
        let arrChartRangeY = [1, 10];            /* Rating values.  Starting with -1 to help keep markers visible */

        let arrChartDataYBaseLine = [];


        arrChartRangeX.push((numSessions + .1)); /* Adding .1 to help keep markers visible */

        $.each(rawData.data, function (idx, progressData) {
            arrChartDataX.push(progressData.sessionNumber);

            let _y1 = null;
            let _y2 = null;
            if (progressData.measurementValue != 0) _y1 = progressData.measurementValue;
            if (progressData.measurementValue2 != 0) _y2 = progressData.measurementValue2;

            arrChartDataY1.push(_y1);
            arrChartDataY2.push(_y2);
            arrChartDataYBaseLine.push(rawData.referenceObject1.baseLineValue);
            arrChartDataText.push(progressData.notes);
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
            , {
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
            title: { text: (chartTitle), xanchor: 'center', yanchor: 'top', font: { size: 10 } }
            , margin: { pad: 10 }
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

        objPlotlyData.data = objChartData;
        objPlotlyData.layout = objChartLayout;
        objPlotlyData.options = objChartOptions;
    }
    return objPlotlyData;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnGetAndChartInDialogIndivualGoalData
 * @private
 * @summary      Charts goal data in a dialog
 * @description  Charts goal data in a dialog
 */

let _fnGetAndChartInDialogIndivualGoalData = function (clientid, patid, goalid, wpct,hpct,modal) {
  _fnGetIndividualGoalProgressData(clientid, patid, goalid).then(responseData => {
    var objPlotlyData = _fnConvertIndividualGoalProgressDataToPlotlyData(responseData.rawData);
    if (!objPlotlyData.hasChartData) {
        return MBA.ComponentCommon.fnCreateOneTimeAlertDialog('No Progress Data Recorded', 'There is no progress data for this goal recorded within the date range for the goal.');
    }
    let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(wpct);
    let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(hpct);
    var goalChartDivID = MBA.ComponentCommon.fnCreateNewUUID();
    var $goalChartDiaPlotContainerDiv = $('<div class="patient-goal-progress-chart-container patient-goal-progress-chart-container-dialog"></div>');
    var $goalChartDiaPlotDiv = $('<div id="' + goalChartDivID + '"></div>');
    $($goalChartDiaPlotContainerDiv).append($goalChartDiaPlotDiv)
    let objGoalChartDiaOpts = {
        autoOpen: true
      , width: (vw)
      , height: (vh)
      , resizable: false
      , modal: (modal)
      , draggable: false
      , open: function (event, ui) {
          Plotly.newPlot(goalChartDivID, objPlotlyData.data, objPlotlyData.layout, objPlotlyData.options);
      }
    };

    return MBA.ComponentCommon.fnCreateOneTimeDialog('Goal Progress', $goalChartDiaPlotContainerDiv, objGoalChartDiaOpts);

    });
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
    _fnGetIndividualGoalProgressData(clientid, patid, goalid).then(responseData => {
        var objPlotlyData = _fnConvertIndividualGoalProgressDataToPlotlyData(responseData.rawData);
        if (!objPlotlyData.hasChartData) {
           let $chartTitle = $('<div class="text-center">' + objPlotlyData.chartTitle + '</div>');
           let $noDataAvailMsg = $('<div class="text-center text-muted">No data is available within the date range for this goal</div>');
           $('#' + divid).append($chartTitle);
           $('#' + divid).append($noDataAvailMsg);
          return;
        }
        Plotly.newPlot(divid, objPlotlyData.data, objPlotlyData.layout, objPlotlyData.options);
        return;
    });
}

/*#############################################################################################################################################################
  #                                                                   PUBLIC METHODS
  ##############################################################################################################################################################*/

return {  
    fnInit: _fnInit
  , fnGetIndividualGoalProgressData: _fnGetIndividualGoalProgressData
  , fnConvertIndividualGoalProgressDataToPlotlyData: _fnConvertIndividualGoalProgressDataToPlotlyData
  , fnGetAndChartInDialogIndivualGoalData: _fnGetAndChartInDialogIndivualGoalData
  , fnGetAndChartInDivIndivualGoalData: _fnGetAndChartInDivIndivualGoalData
};

})(jQuery);

