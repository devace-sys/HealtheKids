; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ActionItemCdeComplianceBucketsPcalRatingsCommon
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery, Bootstrap, MBA.ComponentCommon
 */

MBA.ActionItemCdeComplianceBucketsPcalRatingsCommon = (function ($) {

    'use strict';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _PLUGIN_NS     = 'mba-action-item-cde-compliance-buckets-pcal-ratings';
	const _PLUGIN_NAME   = 'CDE Compliance PCAL Ratings';
    const _JQ_DATA_NAME  = 'jq-' + _PLUGIN_NS;
	
	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _CSS_CLASSES = {
		  container: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + 'mba-action-items-container p-2'
		, label: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-label' + ' text-center'
		, instructions: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-instructions' + ' text-center text-muted mt-4'
		, meter: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-meter' + ' ' + _PLUGIN_NS + '-meter'
		, status: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-status'
		, spinner: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-spinner'
		, hidden: MBA.ActionItemCommon.PLUGIN_COMMON + '-hidden'

	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _DEFAULT_OPTIONS = {
		  cssClasses: _CSS_CLASSES
		, label: 'Plans'
		, requestDataUrlBase: ''
		, requestDataParameters: null
		, requestDataFieldNames: []
		, autoSetUpdateRequestDataParametersFromRequestDataFieldNames: true
		, urlSessionExpiredLink: ''
		, additionalContent:null
		, instructionsEnabled:false
		, instructionsContent: ''
		, instructionsPosition: 'bottom'		
		, hoverTemplate:'%{value:,.0f}<extra></extra>'
	};


	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRenderPieChart
	 * @private
	 * @summary      Renders pie chart 
	 * @param  {Object}  elem  Element reference
	 */

	let _fnRenderPieChart = function (elem, responseData) {
		
		return new Promise((resolve, reject) => {
			let $me     = MBA.ActionItemCommon.fnGetMe(elem);
			let dataObj = MBA.ActionItemCommon.fnGetDataObj($me);
			let chartID = dataObj.meID;

			let valuesArr    = [];
			let labelsArr    = [];
			let textArr      = [];
			let actionURLArr = [];
			let totalAmt     = 0;

			$.each(responseData.rawData.totalNumAmts, function (idx, amtObj) {

			  valuesArr.push(10);  /* We need fixed size */

		      textArr.push(amtObj.totalNumVal);			  
			  labelsArr.push(amtObj.label);

			  actionURLArr.push({
			    'actionURL': amtObj.actionURL						
			  });

			 totalAmt += amtObj.totalNumVal;
				
			});

			let chartData = [
				{
				  type: 'pie'
				, hole: .45
				, values: valuesArr /* In this case the values are all the same size */
				, text: textArr
				, labels: labelsArr
				, hoverinfo: 'label' /* Get the hover info from the label array */
				, textinfo: 'text'   /* Get the slice label from the text array*/
				, sort: false  /* Forces the labels to be in the same order as the incoming data */
				, 'marker': {

					/* Provides space between slices */

					line: {
						 color: "rgb(255,255,255)"
						, width: 5
					}

					/* Color for each slice (in order of labels) */

					, colors: ['rgb(31, 180, 40)', 'rgb(0, 255, 0)', 'rgb(255, 255, 0)', 'rgb(255, 153, 153)', 'rgb(255, 0, 0)']
					
				  }
				, customdata: actionURLArr
			  }
			];

			let chartLayout = {
				  autosize: true
				, margin: { l: 0, r: 0, b: 30, t: 0 }
				, legend: {
					title: {
						text: 'Compliance'
					}
				}

				/* Sets text, etc for "hole" */

				, annotations: [{
					  text: '<b>' + totalAmt.toString() + ' Students</b>'
					, showarrow: false
				}]
			};

			/* We turn off interaction here as we do not want users to show/hide label values */

			let chartConfig = $.extend({}, MBA.ActionItemCommon.COMMON_CHART_CONFIG, { staticPlot: true });
						
			Plotly.newPlot(chartID, chartData, chartLayout, chartConfig);

			/* We wire up drill down for each slice here */

			$('#' + chartID).off().on('plotly_click', function (arg1, arg2) {
				let customdataObj = arg2.points[0].customdata[0];
				if (customdataObj.actionURL) {					
					MBA.ComponentCommon.fnOpenWindow(customdataObj.actionURL);					
				};
			});
			resolve();
		});
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRenderWidget
	 * @private
	 * @summary      Delegate for rendering pie chart.  This is redefined in create.
	 * @description  Delegate for rendering pie chart.  This is redefined in create.
	 * @param  {Object}  elem  Element reference
	 */

	let _fnRenderWidget = function (elem, responseData) {		
		let $me = MBA.ActionItemCommon.fnGetMe(elem);
		let dataObj = MBA.ActionItemCommon.fnGetDataObj($me);
		$(dataObj.spinner).addClass(dataObj.opts.cssClasses.hidden);
		return _fnRenderPieChart(elem, responseData);
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
		
		let $instructions = $('<div>Please click on each slice below for more details.</div>')
		$($instructions).addClass(opts.cssClasses.instructions);

		let $headers = $('<div></div>');
		$($headers).append($label);
		$($headers).append($instructions);

		/* Spinner */

		let $spinner = $('<i></i>');
		$($spinner).addClass(opts.cssClasses.spinner);
		$($spinner).addClass('fa fa-spinner fa-pulse fa-3x fa-fw m-auto');
		$($spinner).addClass(opts.cssClasses.hidden);

		let $status = $('<div></div>');
		$($status).addClass(opts.cssClasses.status);

		$($status).append($spinner);
		$($container).prepend($status);
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


	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	return {
	      PLUGIN_NAME : _PLUGIN_NAME
		, fnCreate: _fnCreate
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
 * @summary      CDE Compliance Buckets
 * @description  CDE Compliance Buckets
 * @requires     jQuery
 */

; (function ($) {

	'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/* Tie into jQuery namespace */

	$.fn.MBA_ActionItemCdeComplianceBucketsPcalRatings = function (methodOrOptions, optionsOrValue) {

		/* These are the supported methods and properties that can be accessed from outside after an instance is created */

		let _methods = {
			 getData: function (elem) { return MBA.ActionItemCdeComplianceBucketsPcalRatingsCommon.fnGetData(elem, MBA.ActionItemCdeComplianceBucketsPcalRatingsCommon.fnRenderWidget); }
		   , requestDataParameterSetOrUpdate: function (elem, parameterNameValueObj) { return MBA.ActionItemCdeComplianceBucketsPcalRatingsCommon.fnRequestDataParameterSetOrUpdate(elem, parameterNameValueObj);}
			/*, setContent : function (elem, value)   { return MBA.DisclosureCommon.fnSetContent  (elem, value); } */
		};

		let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

		/* Method is create */

		if (typeof methodOrOptions === 'object' || !methodOrOptions) {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.ActionItemCdeComplianceBucketsPcalRatingsCommon.fnCreate(elem, methodOrOptions);
			});
		}

		/* Method is destroy */

		else if (methodOrOptions == 'destroy') {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.ActionItemCdeComplianceBucketsPcalRatingsCommon.fnDestroy(elem);
			});
		}

		/* Other methods (these cannot be chained) */

		else if (_methods[methodOrOptions]) {
			if (numOf == 1) {
				let elem = this[0]; /* There is only one element matched so we can proceed */
				return _methods[methodOrOptions](elem, optionsOrValue);
			}

			/* More than one element matched.  We cannot apply */
			else if (numOf > 1) { throw new Error(MBA.ActionItemCdeComplianceBucketsPcalRatingsCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' cannot be applied to a set of elements at once.'); }
			/* No elements found */
			else { throw new Error(MBA.ActionItemCdeComplianceBucketsPcalRatingsCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' cannot be applied since the element was not found.'); }
		}

		/* Cant find the method */

		else {
			throw new Error(MBA.ActionItemCdeComplianceBucketsPcalRatingsCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method');
		}

	}; /* MBA_ActionItemPieChart */


})(jQuery);
