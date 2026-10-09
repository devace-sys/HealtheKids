; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ActionItemGaugeCommon
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery, Plotly, MBA.ComponentCommon
 */

MBA.ActionItemGaugeCommon = (function ($) {

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _PLUGIN_NS           = 'mba-action-item-gauge'

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _GAUGE_TYPE = {
    financialPosition: 100
  , financialProgress: 200
  , financialPerspective: 300
  , financialNumber: 400

}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _CSS_CLASSES = {
	container: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-container'
  , label:     MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-label'
  , meter:     MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-meter' + ' ' + _PLUGIN_NS + '-meter'
  , status:    MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-status'
  , spinner:   MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-spinner'
  , svg: _PLUGIN_NS
  , hidden: MBA.ActionItemCommon.PLUGIN_COMMON + '-hidden'
  , instructions: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-instructions'
  , reports: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-reports'
  , animationPulse: _PLUGIN_NS + '-animation-pulse'
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS = {
	  cssClasses: _CSS_CLASSES
	, gaugeType: _GAUGE_TYPE.financialProgress
    , label:''
	, requestDataUrlBase: ''
	, requestDataParameters: null
	, requestDataFieldNames: []
	, autoSetUpdateRequestDataParametersFromRequestDataFieldNames:true
	, urlSessionExpiredLink: ''
	, urlDetailsLink: ''
	, fnGenerateGaugeTitle: function (totalNumAmt) { return ''; }
	, reportUrlBase: ''
	, reportDataFieldNames: []
	, reportNumber: -1
	, reportFormat: 2
	, instructionsEnabled: false
	, instructionsContent: ''
	, instructionsPosition: 'bottom'
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnDownloadReport
 * @private
 * @summary       
 * @description  
 * @param  {Object}
 * 
 */

let _fnDownloadReport = function (dataObj) {
	$(dataObj.reportText).addClass(dataObj.opts.cssClasses.hidden);
	$(dataObj.downloadingText).removeClass(dataObj.opts.cssClasses.hidden);

	let reqUrl = dataObj.opts.reportUrlBase;
	let reqData = [];

	$.each(dataObj.opts.reportDataFieldNames, function (fldNameIdx, fieldName) {
		reqData.push(MBA.ComponentCommon.fnCreateNameValueObjByInputName(fieldName));
	});
	
	MBA.ComponentCommon.fnRequestDownloadWebReportDocument(reqUrl
		, dataObj.opts.reportFormat
		, dataObj.opts.reportNumber
		, 'Report'
		, reqData
		, function () {
			$(dataObj.downloadingText).addClass(dataObj.opts.cssClasses.hidden);
			$(dataObj.downloadingCompleteText).removeClass(dataObj.opts.cssClasses.hidden);

			setTimeout(function () {
				$(dataObj.reportText).removeClass(dataObj.opts.cssClasses.hidden);
				$(dataObj.downloadingCompleteText).addClass(dataObj.opts.cssClasses.hidden);
			}, 3000);
		}
		, null);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderGaugeFinancialProgress
 * @private
 * @summary      Renders gauge data 
 * @description  How are we doing towards a goal
 * @param  {Object}  elem  Element reference
 */

  let _fnRenderGaugeFinancialProgress = function (elem, responseData, gaugeOpts) {
	return new Promise((resolve, reject) => {

		let $me         = MBA.ActionItemCommon.fnGetMe(elem);
		let dataObj     = MBA.ActionItemCommon.fnGetDataObj($me);
		let totalNumAmt = responseData.rawData.totalNumAmt;
		let chartID     = dataObj.meID;
		let titleText = gaugeOpts.fnGenerateGaugeTitle(totalNumAmt);

		let lowMax  = (Math.floor(totalNumAmt.goalAmtVal * .70));
		let highMax = totalNumAmt.goalAmtVal;

		if (totalNumAmt.totalAmtVal >= totalNumAmt.goalAmtVal) {
			highMax = (totalNumAmt.totalAmtVal + Math.ceil((totalNumAmt.totalAmtVal * .20)));
		}
		else {
			highMax = (totalNumAmt.goalAmtVal + Math.ceil((totalNumAmt.goalAmtVal * .20)));
		}

		let lowRange  = [0, lowMax];
		let midRange  = [(lowMax+1), (totalNumAmt.goalAmtVal-1)];
		let highRange = [totalNumAmt.goalAmtVal, highMax];

		let chartData = [{
			  type: 'indicator'
			, mode: 'gauge+number+delta'
			, number: { valueformat: '$,.0f' }
			, value: (totalNumAmt.totalAmtVal)
			, delta: { reference: (totalNumAmt.goalAmtVal), position: 'top', valueformat: '$,.0f' }
			, gauge: {
				bar: { color: 'black' }
				, threshold: { value: (totalNumAmt.goalAmtVal), line: { color: 'black', width: 1, thickness: 2 } }
				, steps: [
					{ range: (lowRange), color: '#d62728' }
				  , { range: (midRange), color: '#ff7f0e' }
				  , { range: (highRange), color: '#2ca02c' }
				]
				, axis: { range: [null, (highMax)], tickformat: '$,.0f' }
				, borderwidth: 0
			}
		}
		];
		  
		let chartLayout = {
			  autosize:true
			, title: { text: (titleText) }
			, margin: { l: 0, r: 0, b: 50, t: 50 }
		};

		Plotly.newPlot(chartID, chartData, chartLayout, MBA.ActionItemCommon.COMMON_CHART_CONFIG);

	});
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderGaugeFinancialPosition
 * @private
 * @summary      Renders gauge data 
 * @description  Where are we in relation to the goal
 * @param  {Object}  elem  Element reference
 */

	let _fnRenderGaugeFinancialPosition = function (elem, responseData, gaugeOpts) {
	return new Promise((resolve, reject) => {
		let $me         = MBA.ActionItemCommon.fnGetMe(elem);		
		let dataObj = MBA.ActionItemCommon.fnGetDataObj($me);
		
		let totalNumAmt = responseData.rawData.totalNumAmt;
		let titleText    = gaugeOpts.fnGenerateGaugeTitle(totalNumAmt);
		let barColor    = 'black';
		
		let axisRangeUpper = 0;
		if (totalNumAmt.totalAmtVal >= totalNumAmt.goalAmtVal) {
			axisRangeUpper = (totalNumAmt.totalAmtVal + Math.ceil((totalNumAmt.totalAmtVal * .20)));
		}
		else {
		    axisRangeUpper = (totalNumAmt.goalAmtVal + Math.ceil((totalNumAmt.goalAmtVal * .20)));
		}

		let chartID = dataObj.meID;

		let chartData = [{
			  type: 'indicator'
			, mode: 'number+gauge+delta'		
			, domain: { x: [0, 1], y: [0, 1] }
			, number: { valueformat: '$,.0f' }
			, delta: { reference: (totalNumAmt.goalAmtVal), position: 'top', valueformat: '$,.0f' }
			, gauge: {
				shape: 'bullet'
				, bar: { color: (barColor) }
				, axis: { range: [0, (axisRangeUpper)], tickformat: '$,.0f' }
				, threshold: {
					line: { color: 'green', width: 4 }
					, thickness: 1
					, value: (totalNumAmt.goalAmtVal)
				}
				, borderwidth: 0
			}
			, value: (totalNumAmt.totalAmtVal)
		
		}
		];
	
		let chartLayout = {
			autosize: true
			, title: { text: (titleText)}
			, margin: { l: 0, r: 0, b: 25, t: 25 }
			, width: 300
			, height: 150
		};

		Plotly.newPlot(chartID, chartData, chartLayout, MBA.ActionItemCommon.COMMON_CHART_CONFIG);

	});
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderGaugeFinancialPerspective
 * @private
 * @summary      Renders gauge data 
 * @description  Shows total number with compare amount as perpective
 * @param  {Object}  elem  Element reference
 */

let _fnRenderGaugeFinancialPerspective = function (elem, responseData, gaugeOpts) {
	return new Promise((resolve, reject) => {
		let $me     = MBA.ActionItemCommon.fnGetMe(elem);		
		let dataObj = MBA.ActionItemCommon.fnGetDataObj($me);

		let totalNumAmt = responseData.rawData.totalNumAmt;
		
		let chartID = dataObj.meID;
	
		let chartData = [{
			  type: 'indicator'
			, mode: 'number'
			, number: { prefix: '$' }
			, value: (totalNumAmt.totalAmtVal)		
		}
		];


		let chartLayout = {
			  autosize: true
			, margin: { l: 0, r: 0, b: 0, t: 0 }
			, width: 100
			, height: 100
		};

		Plotly.newPlot(chartID, chartData, chartLayout, MBA.ActionItemCommon.COMMON_CHART_CONFIG);

	});
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderGaugeFinancialNumber
 * @private
 * @summary      Renders gauge data 
 * @description  Just a number
 * @param  {Object}  elem  Element reference
 */

  let _fnRenderGaugeFinancialNumber = function (elem, responseData, gaugeOpts) {
	return new Promise((resolve, reject) => {
		let $me     = MBA.ActionItemCommon.fnGetMe(elem);		
		let dataObj = MBA.ActionItemCommon.fnGetDataObj($me);

		let totalNumAmt = responseData.rawData.totalNumAmt;

		let chartID = dataObj.meID;

		let chartData = [{
			  type: 'indicator'
			, mode: 'number'
			, number: { prefix: '$' }
			, value: (totalNumAmt.totalAmtVal)		
		}
		];


		let chartLayout = {
			autosize: true
			, margin: { l: 0, r: 0, b: 0, t: 0 }
			, width: 100
			, height: 100
		};

		Plotly.newPlot(chartID, chartData, chartLayout, MBA.ActionItemCommon.COMMON_CHART_CONFIG);

	});
}


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderWidget
 * @private
 * @summary      Delegate for rendering gauge based on gauge type passed in options.  This is redefined in create.
 * @description  Delegate for rendering gauge based on gauge type passed in options.  This is redefined in create.
 * @param  {Object}  elem  Element reference
 */
	
let _fnRenderWidget = function (elem, responseData) {
	return new Promise((resolve, reject) => {
		let $me = MBA.ActionItemCommon.fnGetMe(elem);
		let dataObj = MBA.ActionItemCommon.fnGetDataObj($me);
		let gaugeOpts = dataObj.opts;			
		$(dataObj.spinner).addClass(dataObj.opts.cssClasses.hidden);
		$(dataObj.reportText).removeClass(dataObj.opts.cssClasses.hidden);
		resolve(gaugeOpts);
	}).then(gaugeOpts => {
		if (gaugeOpts.gaugeType === _GAUGE_TYPE.financialProgress)
			return _fnRenderGaugeFinancialProgress(elem, responseData, gaugeOpts);
		if (gaugeOpts.gaugeType === _GAUGE_TYPE.financialPosition)
			return _fnRenderGaugeFinancialPosition(elem, responseData, gaugeOpts);
		if (gaugeOpts.gaugeType === _GAUGE_TYPE.financialPerspective)
			return _fnRenderGaugeFinancialPerspective(elem, responseData, gaugeOpts);
		if (gaugeOpts.gaugeType === _GAUGE_TYPE.financialNumber)
			return _fnRenderGaugeFinancialNumber(elem, responseData, gaugeOpts);
    });
}
	
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreate
 * @private
 * @summary      Create new instance
 * @description  Create new instance
 * @param  {Object}  elem    Element reference
 * @param  {Object}  optsIn  Element reference
 */
	
let _fnCreate = function (elem,optsIn) {	  
  let $me = MBA.ActionItemCommon.fnGetMe(elem);	  
	    
  /* Test to see if element is supported */
  
  if (MBA.ActionItemCommon.fnIsElemSupported(elem) === false) return;
  
  /* See if we have created an instance of this plugin already for this element.  If so get out. */
 
  let dataObj = $($me).data(MBA.ActionItemCommon.JQ_DATA_NAME);
  if (dataObj) return;
  
  /* Define the data object we will save later */
	  
  dataObj = {}; 
	  
  /* Store reference to elem */
	  
  dataObj.me = $me;
  dataObj.meID = $($me).attr('id');

  if (!dataObj.meID) {
	  dataObj.meID = MBA.ComponentCommon.fnCreateNewUUID();
	  $($me).attr('id',dataObj.meID);
  }

  /* Merge default options and options passed in. */
	  
  let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);
  if (!opts.requestDataParameters) opts.requestDataParameters = new Map();

  /* Gauge */

  $($me).addClass(opts.cssClasses.meter);

  /* Create container */

  $($me).wrap('<section></section>');
  let $container = $($me).parent();
  $($container).addClass(opts.cssClasses.container);

  /* Label & Instructions */

  let $label = $('<h3>' + opts.label + '</h3>');
  $($label).addClass(opts.cssClasses.label);
  $($label).addClass('flex-grow-1');

  let $instructions = $('<i></i>');
  $($instructions).addClass(opts.cssClasses.instructions);
  $($instructions).addClass('fa fa-info-circle');

  let $headers = $('<div class="d-flex"></div>');
  $($headers).append($label);
  if (opts.instructionsEnabled === true) {
    $($headers).append($instructions);
  }
  /* Spinner */

  let $spinner = $('<i></i>');
  $($spinner).addClass(opts.cssClasses.spinner);
  $($spinner).addClass('fa fa-spinner fa-pulse fa-3x fa-fw m-auto');
  $($spinner).addClass(opts.cssClasses.hidden);

  /* Reports */
  
  let $reportText = $('<span class="text-primary">Click to Download Report</span>');
  $($reportText).addClass(opts.cssClasses.hidden);

  let $downloadingText = $('<span>Please wait, generating file.</span>');
  $($downloadingText).addClass(opts.cssClasses.animationPulse);
  $($downloadingText).addClass(opts.cssClasses.hidden);

  let $downloadingCompleteText = $('<span class="text-success">File successfully downloaded.</span>');
  $($downloadingCompleteText).addClass(opts.cssClasses.hidden);

  let $reports = $('<div></div>');
  $($reports).addClass(opts.cssClasses.reports);
  $($reports).append($reportText);
  $($reports).append($downloadingText);
  $($reports).append($downloadingCompleteText);

  let $status = $('<div></div>');
  $($status).addClass(opts.cssClasses.status);

  $($status).append($spinner);
  $($container).prepend($status);
  $($container).prepend($reports);
  $($container).prepend($headers);

  dataObj.container    = $container;
  dataObj.headers      = $headers;
  dataObj.label        = $label;
  dataObj.instructions = $instructions;
  dataObj.status       = $status;
  dataObj.spinner      = $spinner;
  dataObj.opts         = opts;

  dataObj.reports                 = $reports;
  dataObj.reportText              = $reportText;
  dataObj.downloadingText         = $downloadingText;
  dataObj.downloadingCompleteText = $downloadingCompleteText;
 
  /* Save our data object.  This will be used for option calls */

  $($me).data(MBA.ActionItemCommon.JQ_DATA_NAME, dataObj );

	$('#' + dataObj.meID).on('plotly_afterplot', function (ePlot) {
		$(ePlot.target).find('svg').addClass(opts.cssClasses.svg);
	});

  /* Downloading reports */

  $(dataObj.reportText).on('click', function () {
    if (opts.reportUrlBase) {
  	  _fnDownloadReport(dataObj);
    }
  });

  /* Instructions */
  if (opts.instructionsEnabled === true) {

		$($instructions).tipso({
			speed: 400
			, background: '#ffd60d'
			, titleBackground: '#333333'
			, color: 'black'
			, titleColor: '#ffffff'
			, titleContent: ''
			, showArrow: true
			, position: opts.instructionsPosition
			, width: '50vw'
			, maxWidth: '50vw'
			, delay: 200
			, hideDelay: 0
			, animationIn: ''
			, animationOut: ''
			, offsetX: 0
			, offsetY: 0
			, tooltipHover: true
			, content: opts.instructionsContent
			, ajaxContentUrl: null
			, contentElementId: null
			, useTitle: false
			, templateEngineFunc: null
			, onBeforeShow: null
			, onShow: null
			, onHide: null
		});
	};
};
	
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

return {
	GAUGE_TYPE: _GAUGE_TYPE
  , fnCreate: _fnCreate
  , fnDestroy: MBA.ActionItemCommon.fnDestroy
  , fnRequestDataParameterSetOrUpdate : MBA.ActionItemCommon.fnRequestDataParameterSetOrUpdate
  , fnRequestDataParameterSetOrUpdateFromFieldName: MBA.ActionItemCommon.fnRequestDataParameterSetOrUpdateFromFieldName
  , fnGetData: MBA.ActionItemCommon.fnGetData
  , fnRenderWidget: _fnRenderWidget
};

})(jQuery);


/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Disclosure plugin
 * @description  Disclosure plugin
 * @requires     jQuery
 */

;(function($){

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
 
 /* Tie into jQuery namespace */
	
$.fn.MBA_ActionItemGauge = function (methodOrOptions, optionsOrValue) { 
      
/* These are the supported methods and properties that can be accessed from outside after an instance is created */	
	
let _methods = {
    getData   : function (elem)    { return MBA.ActionItemGaugeCommon.fnGetData(elem
												, MBA.ActionItemGaugeCommon.fnRenderWidget);
	}      		
  /*, setContent : function (elem, value)   { return MBA.DisclosureCommon.fnSetContent  (elem, value); } */
};
	  	  
let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

/* Method is create */
	  
if ( typeof methodOrOptions === 'object' || !methodOrOptions )
{
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
	let elem = this; /* this in this scope is a reference to one of elements in the set */
	return MBA.ActionItemGaugeCommon.fnCreate  (elem, methodOrOptions);
  });
} 
	  
/* Method is destroy */
	  
else if ( methodOrOptions == 'destroy' )
{			
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
    let elem = this; /* this in this scope is a reference to one of elements in the set */
    return MBA.ActionItemCommon.fnDestroy (elem);
  });
} 
	  
/* Other methods (these cannot be chained) */
	  
else if ( _methods [methodOrOptions] ) 
{			      
  if (numOf == 1) {
    let elem = this[0]; /* There is only one element matched so we can proceed */
	return _methods[ methodOrOptions ]( elem, optionsOrValue );
  }
		
  /* More than one element matched.  We cannot apply */
  else if (numOf > 1) { throw new Error(MBA.ActionItemCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied to a set of elements at once.' );}
  /* No elements found */
  else                { throw new Error(MBA.ActionItemCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied since the element was not found.');}
} 

/* Cant find the method */
	  
else 
{
  throw new Error(MBA.ActionItemCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method' );
}        
	
}; /* MBA_ActionItemGauge */

})( jQuery );
