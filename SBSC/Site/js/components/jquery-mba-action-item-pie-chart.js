; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ActionItemPieChartCommon
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery, Plotly, MBA.ComponentCommon
 */

MBA.ActionItemPieChartCommon = (function ($) {

	'use strict';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _PLUGIN_NS = 'mba-action-item-pie-chart';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _CSS_CLASSES = {
		container: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-container'
		, label: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-label'
		, meter: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-meter' + ' ' + _PLUGIN_NS + '-meter'
		, status: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-status'
		, spinner: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-spinner'
		, hidden: MBA.ActionItemCommon.PLUGIN_COMMON + '-hidden'
		, instructions: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-instructions'
		, reports: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-reports'
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
		, additionalContent:null
		, instructionsEnabled:false
		, instructionsContent: ''
		, instructionsPosition: 'bottom'
		, pieChartType: 1
		, hoverTemplate:'%{value:,.0f}<extra></extra>'
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

	let _fnDownloadReport = function (actionURL, dataObj) {
		$(dataObj.spinner).removeClass(dataObj.opts.cssClasses.hidden);
		
		let reqUrl = actionURL;
		let reqData = [
			MBA.ComponentCommon.fnCreateNameValueObject('clientid', dataObj.opts.requestDataParameters.get('clientid'))
		];
		
		MBA.ComponentCommon.fnRequestDownloadWebReportDocument( reqUrl
			, 3
			, 52
			, 'Missing Assessments Report'
			, reqData
			, function () { $(dataObj.spinner).addClass(dataObj.opts.cssClasses.hidden); }
			, function () { $(dataObj.spinner).addClass(dataObj.opts.cssClasses.hidden); } );
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRenderPieChart1
	 * @private
	 * @summary      Renders pie chart 
	 * @param  {Object}  elem  Element reference
	 */

	let _fnRenderPieChart1 = function (elem, responseData) {
		return new Promise((resolve, reject) => {
			let $me = MBA.ActionItemCommon.fnGetMe(elem);
			let dataObj = MBA.ActionItemCommon.fnGetDataObj($me);
			let chartID = dataObj.meID;

			let valuesArr = [];
			let labelsArr = [];
			let actionURLArr = [];
			let totalAmt = 0;

			$.each(responseData.rawData.totalNumAmts, function (idx, amtObj) {
				if (amtObj.totalAmtVal != 0) {
					valuesArr.push(amtObj.totalAmtVal);
					labelsArr.push(amtObj.label);

					actionURLArr.push({
						'actionURL': amtObj.actionURL
						, 'actionTabID': amtObj.actionTabID
						, 'isReportDownload': amtObj.isReportDownload
					});

					totalAmt += amtObj.totalAmtVal;
				}
			});

			let chartData = [{
				type: 'pie'
				, hole: .45
				, values: valuesArr
				, labels: labelsArr
				, marker: {
					line: {
						color: "hsla(0,100%,100%,0.7)",
						width: 6
					}
				}
				, customdata: actionURLArr
				, hovertemplate:'%{value:$,.0f}<extra></extra>'
			}
			];

			let chartLayout = {
				autosize: true
				, margin: { l: 0, r: 0, b: 30, t: 0 }
				, annotations: [{
					  text: '<b>$' + Math.round(totalAmt).toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,") + '</b>'
					, showarrow: false
				}]
			};

			Plotly.newPlot(chartID, chartData, chartLayout, MBA.ActionItemCommon.COMMON_CHART_CONFIG);

			$('#' + chartID).off().on('plotly_click', function (arg1, arg2) {
				let customdataObj = arg2.points[0].customdata[0];
				
				if (customdataObj.isReportDownload == true) {
					_fnDownloadReport(customdataObj.actionURL, dataObj);
				}
				else {
					if (customdataObj.actionURL) {
						let reqUrl = customdataObj.actionURL
							+ '&clientid=' + dataObj.opts.requestDataParameters.get('clientid')
							+ '&tabtoopn=' + customdataObj.actionTabID;

						// we need the url as a subpage (if not already)
						if (reqUrl.indexOf('&amd=uidbssub') == -1) {
							reqUrl += '&amd=uidbssub';
                        }

						$.spedmonWebUI.openURL(reqUrl, 1);
					}
                }

			});
		});
	}


	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRenderPieChart2
	 * @private
	 * @summary      Renders pie chart 
	 * @param  {Object}  elem  Element reference
	 */

	let _fnRenderPieChart2 = function (elem, responseData) {
		return new Promise((resolve, reject) => {
			let $me = MBA.ActionItemCommon.fnGetMe(elem);
			let dataObj = MBA.ActionItemCommon.fnGetDataObj($me);
			let chartID = dataObj.meID;

			let valuesArr = [];
			let labelsArr = [];

			$.each(responseData.rawData.totalNumAmts, function (idx, amtObj) {
				if (amtObj.totalNumVal != 0) {
					valuesArr.push(amtObj.totalNumVal);
					labelsArr.push(amtObj.label);

					
				}
			});

			let chartData = [{
				  type: 'pie'				
				, values: valuesArr
				, labels: labelsArr
				, hovertemplate: (dataObj.opts.hoverTemplate)
				, marker: {
					line: {
						color: "hsla(0,100%,100%,0.7)",
						width: 6
					}
				}
			}
			];

			let chartLayout = {
				  autosize: true
				, margin: { l: 0, r: 0, b: 0, t: 0 }
			};

			Plotly.newPlot(chartID, chartData, chartLayout, MBA.ActionItemCommon.COMMON_CHART_CONFIG);

			$('#' + chartID).off().on('plotly_click', function (arg1, arg2) {
				let customdataObj = arg2.points[0].customdata[0];

				if (customdataObj.isReportDownload == true) {
					_fnDownloadReport(customdataObj.actionURL, dataObj);
				}
				else {
					if (customdataObj.actionURL) {
						let reqUrl = customdataObj.actionURL
							+ '&clientid=' + dataObj.opts.requestDataParameters.get('clientid')
							+ '&tabtoopn=' + customdataObj.actionTabID;

						// we need the url as a subpage (if not already)
						if (reqUrl.indexOf('&amd=uidbssub') == -1) {
							reqUrl += '&amd=uidbssub';
						}

						$.spedmonWebUI.openURL(reqUrl, 1);
					}
				}

			});
		});
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRenderWidget
	 * @private
	 * @summary      Delegate for rendering pie chart.  This is redefined in create.
	 * @description  Delegate for rendering pie chart.  This is redefined in create.
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
			if (chartOpts.pieChartType === 1) return _fnRenderPieChart1(elem, responseData);
			if (chartOpts.pieChartType === 2) return _fnRenderPieChart2(elem, responseData);
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

		/* Pie chart */

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
		let $reports = $('<div></div>');
		$($reports).addClass(opts.cssClasses.reports);

		/* Spinner */

		let $spinner = $('<i></i>');
		$($spinner).addClass(opts.cssClasses.spinner);
		$($spinner).addClass('fa fa-spinner fa-pulse fa-3x fa-fw m-auto');
		$($spinner).addClass(opts.cssClasses.hidden);

		let $status = $('<div></div>');
		$($status).addClass(opts.cssClasses.status);

		$($status).append($spinner);
		$($container).prepend($status);
		$($container).prepend($reports); /* Needed for tipso*/
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
				, width:'50vw'
				, maxWidth:'50vw'
				, delay: 200
				, hideDelay: 0
				, animationIn: ''
				, animationOut: ''
				, offsetX: 0
				, offsetY: 0
				, tooltipHover: true
				, content: opts.instructionsContent
				, ajaxContentUrl: null
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
		, fnGetDataThenDoSomething: MBA.ActionItemCommon.fnGetDataThenDoSomething
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

	$.fn.MBA_ActionItemPieChart = function (methodOrOptions, optionsOrValue) {

		/* These are the supported methods and properties that can be accessed from outside after an instance is created */

		let _methods = {
			 getData: function (elem) { return MBA.ActionItemPieChartCommon.fnGetData(elem, MBA.ActionItemPieChartCommon.fnRenderWidget); }
		   , getDataThenDoSomething: function (elem, fnDoSomething) { return MBA.ActionItemPieChartCommon.fnGetDataThenDoSomething(elem, MBA.ActionItemPieChartCommon.fnRenderWidget, fnDoSomething); }
		   , requestDataParameterSetOrUpdate: function (elem, parameterNameValueObj) { return MBA.ActionItemPieChartCommon.fnRequestDataParameterSetOrUpdate(elem, parameterNameValueObj);}
			/*, setContent : function (elem, value)   { return MBA.DisclosureCommon.fnSetContent  (elem, value); } */
		};

		let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

		/* Method is create */

		if (typeof methodOrOptions === 'object' || !methodOrOptions) {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.ActionItemPieChartCommon.fnCreate(elem, methodOrOptions);
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

	}; /* MBA_ActionItemPieChart */

})(jQuery);
