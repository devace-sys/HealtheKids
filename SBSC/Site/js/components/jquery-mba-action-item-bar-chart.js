; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ActionItemBarChartCommon
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery, Plotly, MBA.ComponentCommon
 */

//   // TODO: investigate where all this is used
//            vis-a-vis the similarly named widget
//            mba-action-item-progress-bar-chart

MBA.ActionItemBarChartCommon = (function ($) {

	'use strict';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _PLUGIN_NS = 'mba-action-item-bar-chart';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _CSS_CLASSES = {
		container: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-container'
		, label: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-label'
		, meter: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-meter' + ' ' + _PLUGIN_NS + '-meter'
		, status: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-status'
		, spinner: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-spinner'
		, hidden: MBA.ActionItemCommon.PLUGIN_COMMON + '-hidden'
		, instructions: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-instructions'
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _DEFAULT_OPTIONS = {
		  cssClasses: _CSS_CLASSES
		, label: ''
		, requestDataUrlBase: ''
		, requestDataParameters: null
		, requestDataFieldNames: []
		, autoSetUpdateRequestDataParametersFromRequestDataFieldNames: true
		, urlSessionExpiredLink: ''
		, barChartMode: 'vertical-grouped' /* vertical-grouped, horizontal, scatter, totnumamts */
		, actionURL: ''
		, additionalContent: ''
		, instructionsEnabled: false
		, instructionsContent: ''
		, instructionsPosition: 'bottom'

	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRenderScatterChart
	 * @private
	 * @summary      Renders scatter chart
	 * @param  {Object}  elem  Element reference
	 */

	let _fnRenderScatterChart = function (elem, responseData) {
		return new Promise((resolve, reject) => {
			let $me = MBA.ActionItemCommon.fnGetMe(elem);
			let dataObj = MBA.ActionItemCommon.fnGetDataObj($me);
			let chartID = dataObj.meID;

			let labelsArr = [];
			let totalAmtsP1 = [];
			let totalAmtsP2 = [];
			let totalAmtsP3 = [];
			let totalAmtsP4 = [];
			let totalAmtsP5 = [];
			let fyLabelsArr = [];

			$.each(responseData.rawData.claimsPaid2P, function (idx, claimObj) {
				if (claimObj.totalP1 != 0 || claimObj.totalP2 != 0) {
					labelsArr.push(claimObj.label);
					totalAmtsP1.push(claimObj.totalP1);
					totalAmtsP2.push(claimObj.totalP2);					
					totalAmtsP3.push(claimObj.totalP3);					
					totalAmtsP4.push(claimObj.totalP4);					
					totalAmtsP5.push(claimObj.totalP5);					
				}

				if (fyLabelsArr.length == 0) {
					fyLabelsArr.push(claimObj.fyLabelP5);
					fyLabelsArr.push(claimObj.fyLabelP4);
					fyLabelsArr.push(claimObj.fyLabelP3);
					fyLabelsArr.push(claimObj.fyLabelP2);
					fyLabelsArr.push(claimObj.fyLabelP1); /* P1 is current fiscal year */
				}
			});

			let chartData = [];

			$.each(labelsArr, function (idx, traceName) {				
				chartData.push({
					x: fyLabelsArr
					, y: [totalAmtsP5[idx], totalAmtsP4[idx], totalAmtsP3[idx], totalAmtsP2[idx], totalAmtsP1[idx]]
					, name: traceName
					, mode: 'lines+markers'
					, type: 'scatter'					
					, hovertemplate: '%{y:$,.0f}<extra></extra>'
				});
			});

			let chartLayout = {
				autosize: true
				, margin: { l: 80, r: 0, b: 20, t: 0 }
				/*, height: 300*/
				, yaxis: { tickformat: '$,.0f' }
			};

			Plotly.newPlot(chartID, chartData, chartLayout, MBA.ActionItemCommon.COMMON_CHART_CONFIG);
		});
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRenderBarChartHorizontal
	 * @private
	 * @summary      Renders bar chart (horizontally)
	 * @param  {Object}  elem  Element reference
	 */

	let _fnRenderBarChartHorizontal = function (elem, responseData) {
		return new Promise((resolve, reject) => {
			let $me = MBA.ActionItemCommon.fnGetMe(elem);
			let dataObj = MBA.ActionItemCommon.fnGetDataObj($me);
			let chartID = dataObj.meID;

			let labelsArr = [];
			let totalAmtsArr = [];
			let tooltipsArr = [];
			let svcDataArr = [];
			
		    let updatedLabelText = dataObj.opts.label + ' (Total Projection $' + responseData.rawData.totEstReimburseStr + ')';
			$(dataObj.label).text(updatedLabelText);


			$.each(responseData.rawData.missingServicesTreatmentsSummary, function (idx, tmtObj) {
				if (tmtObj.totEstReimburse != 0) {
					labelsArr.push(tmtObj.serviceOrOrderName);
					totalAmtsArr.push(tmtObj.totEstReimburse);
					tooltipsArr.push('$' + Math.round(tmtObj.totEstReimburse).toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,"));
			        svcDataArr.push(tmtObj);        
				}
			});

			let chartData = [{
				  x: totalAmtsArr
				, y: labelsArr
				, type: 'bar'
				, text: tooltipsArr
				, hovertemplate: '%{x:$,.0f}<extra></extra>'
				, orientation: 'h'
				, customdata: svcDataArr
				
			}];

			let chartLayout = {
				autosize: true
				, margin: { l: 350, r: 30, b: 25, t: 0 }
				/*, height: 300*/
				, xaxis: { tickformat: '$,.0f'}
			};

			Plotly.newPlot(chartID, chartData, chartLayout, MBA.ActionItemCommon.COMMON_CHART_CONFIG);

			$('#' + chartID).off().on('plotly_click', function (arg1, arg2) {
			
				if (dataObj.opts.actionURL) {
					
					
					let parms = [];
                    parms.push(MBA.ComponentCommon.fnCreateNameValueObject('clientid', dataObj.opts.requestDataParameters.get('clientid')));
                    parms.push(MBA.ComponentCommon.fnCreateNameValueObject('svctrackingclass', arg2.points[0].customdata.svcTrackingClass));

                    if (arg2.points[0].customdata.svcTrackingClass == 100) {
                      parms.push(MBA.ComponentCommon.fnCreateNameValueObject('spedservicecode', arg2.points[0].customdata.spEdServiceCode));
                    }
                    else if (arg2.points[0].customdata.svcTrackingClass == 200) {
                      parms.push(MBA.ComponentCommon.fnCreateNameValueObject('groupserviceclassnameid', arg2.points[0].customdata.groupServiceClassNameID));
                    }
                    else {

                    }

					let reqUrl = MBA.ComponentCommon.fnBuildUrl(dataObj.opts.actionURL, 1, parms);						
					MBA.ComponentCommon.fnOpenWindow(reqUrl,'missingsvc'+arg2.points[0].customdata.id);
				}
			});

		});
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRenderGroupedBarChart
	 * @private
	 * @summary      Renders bar chart (group of 2 ONLY)
	 * @param  {Object}  elem  Element reference
	 */

	let _fnRenderGroupedBarChart = function (elem, responseData) {
		return new Promise((resolve, reject) => {
			let $me = MBA.ActionItemCommon.fnGetMe(elem);
			let dataObj = MBA.ActionItemCommon.fnGetDataObj($me);
			let chartID = dataObj.meID;

			let labelsArr = [];
			let totalAmtsP1 = [];
			let totalAmtsP2 = [];
			let tooltipsP1 = [];
			let tooltipsP2 = [];
			let fyLabelP1 = '';
			let fyLabelP2 = '';

			$.each(responseData.rawData.claimsPaid2P, function (idx, claimObj) {
				if (claimObj.totalP1 != 0 || claimObj.totalP2 != 0) {
					labelsArr.push(claimObj.label);
					totalAmtsP1.push(claimObj.totalP1);
					totalAmtsP2.push(claimObj.totalP2);
					tooltipsP1.push('$' + Math.round(claimObj.totalP1).toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,"));
					tooltipsP2.push('$' + Math.round(claimObj.totalP2).toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,"));					
				}
				
				if (!fyLabelP1) fyLabelP1 = claimObj.fyLabelP1;
				if (!fyLabelP2) fyLabelP2 = claimObj.fyLabelP2;
			});
			
			let trace1 = {
				  x: labelsArr
				, y: totalAmtsP1
				, name: fyLabelP1
				, type: 'bar'
				, text: tooltipsP1
				, hovertemplate: '%{y:$,.0f}<extra></extra>'
			};

			let trace2 = {
				  x: labelsArr
				, y: totalAmtsP2
				, name: fyLabelP2
				, type: 'bar'
				, text: tooltipsP2
				, hovertemplate: '%{y:$,.0f}<extra></extra>'
			};

			let chartData = [trace1, trace2];
			
			let chartLayout = {
				  autosize: true
				, margin: { l: 80, r: 0, b: 90, t: 0 }
				/*, height: 300*/
				, barmode: 'group'
				, yaxis: { tickformat: '$,.0f' }
			};
			
			Plotly.newPlot(chartID, chartData, chartLayout, MBA.ActionItemCommon.COMMON_CHART_CONFIG);
		});
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRenderBarChartFromTotalNumAmts
	 * @private
	 * @summary      Renders bar chart 
	 * @param  {Object}  elem  Element reference
	 */

	let _fnRenderBarChartFromTotalNumAmts = function (elem, responseData, chartOpts) {
		return new Promise((resolve, reject) => {
			let $me = MBA.ActionItemCommon.fnGetMe(elem);
			let dataObj = MBA.ActionItemCommon.fnGetDataObj($me);
			let chartID = dataObj.meID;
			let labelsArr = [];
			let valuesArr = [];

			$.each(responseData.rawData.totalNumAmts, function (idx, amtObj) {
				valuesArr.push(amtObj.totalNumVal);
				labelsArr.push(amtObj.label);
			});

			let chartData = [{
				  x: valuesArr
				, y: labelsArr
				, type: 'bar'
				, orientation: 'h'
			}];

			let chartLayout = {
				  autosize: true
				, margin: { l: 400, r: 10, b: 10, t: 0 }
			};

			Plotly.newPlot(chartID, chartData, chartLayout, MBA.ActionItemCommon.COMMON_CHART_CONFIG);


		});
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRenderWidget
	 * @private
	 * @summary      Delegate for rendering bar chart.  This is redefined in create.
	 * @description  Delegate for rendering bar chart.  This is redefined in create.
	 * @param  {Object}  elem  Element reference
	 */

	let _fnRenderWidget = function (elem, responseData) {
		return new Promise((resolve, reject) => {
			let $me = MBA.ActionItemCommon.fnGetMe(elem);
			let dataObj = MBA.ActionItemCommon.fnGetDataObj($me);
			let chartOpts = dataObj.opts;
			$(dataObj.spinner).addClass(dataObj.opts.cssClasses.hidden);
			resolve(chartOpts);
		}).then(chartOpts => {
			if (chartOpts.barChartMode == 'horizontal') {
				return _fnRenderBarChartHorizontal(elem, responseData);
			}
			else if (chartOpts.barChartMode == 'scatter') {
				return _fnRenderScatterChart(elem, responseData);
            }
			else if (chartOpts.barChartMode == 'totnumamts') {
				return _fnRenderBarChartFromTotalNumAmts(elem, responseData, chartOpts);
			}
			else {
				return _fnRenderGroupedBarChart(elem, responseData);
			}
			
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

	let _fnCreate = function (elem, optsIn) {
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
			$($me).attr('id', dataObj.meID);
		}

		/* Merge default options and options passed in. */

		let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);
		if (!opts.requestDataParameters) opts.requestDataParameters = new Map();

		/* Create container */

		$($me).wrap('<section></section>');
		let $container = $($me).parent();
		$($container).addClass(opts.cssClasses.container);

		/* Bar chart */

		$($me).addClass(opts.cssClasses.meter);

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

		let $status = $('<div></div>');
		$($status).addClass(opts.cssClasses.status);

		$($status).append($spinner);
		$($container).prepend($status);
		
		if (opts.additionalContent) {
			$($container).prepend(opts.additionalContent);
        }

		$($container).prepend($headers);

		dataObj.container    = $container;
		dataObj.headers      = $headers;
		dataObj.label        = $label;
		dataObj.instructions = $instructions;
		dataObj.status       = $status;
		dataObj.spinner      = $spinner;
		dataObj.opts         = opts;

		/* Save our data object.  This will be used for option calls */

		$($me).data(MBA.ActionItemCommon.JQ_DATA_NAME, dataObj);


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
		}

	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	return {
		  fnCreate: _fnCreate
		, fnDestroy: MBA.ActionItemCommon.fnDestroy
		, fnRequestDataParameterSetOrUpdate: MBA.ActionItemCommon.fnRequestDataParameterSetOrUpdate
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

; (function ($) {

	'use strict';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/* Tie into jQuery namespace */

	$.fn.MBA_ActionItemBarChart = function (methodOrOptions, optionsOrValue) {

		/* These are the supported methods and properties that can be accessed from outside after an instance is created */

		let _methods = {
			getData: function (elem) { return MBA.ActionItemBarChartCommon.fnGetData(elem
												, MBA.ActionItemBarChartCommon.fnRenderWidget);
		}
			/*, setContent : function (elem, value)   { return MBA.DisclosureCommon.fnSetContent  (elem, value); } */
		};

		let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

		/* Method is create */

		if (typeof methodOrOptions === 'object' || !methodOrOptions) {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.ActionItemBarChartCommon.fnCreate(elem, methodOrOptions);
			});
		}

		/* Method is destroy */

		else if (methodOrOptions == 'destroy') {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.ActionItemCommon.fnDestroy(elem);
			});
		}

		/* Other methods (these cannot be chained) */

		else if (_methods[methodOrOptions]) {
			if (numOf == 1) {
				let elem = this[0]; /* There is only one element matched so we can proceed */
				return _methods[methodOrOptions](elem, optionsOrValue);
			}

			/* More than one element matched.  We cannot apply */
			else if (numOf > 1) { throw new Error(MBA.ActionItemCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' cannot be applied to a set of elements at once.'); }
			/* No elements found */
			else { throw new Error(MBA.ActionItemCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' cannot be applied since the element was not found.'); }
		}

		/* Cant find the method */

		else {
			throw new Error(MBA.ActionItemCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method');
		}

	}; /* MBA_ActionItemBarChart */

})(jQuery);
