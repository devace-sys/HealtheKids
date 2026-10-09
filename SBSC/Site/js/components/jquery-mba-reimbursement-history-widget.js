; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.reimbursementHistoryWidget
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery
 */

MBA.reimbursementHistoryWidget = (function ($) {

	'use strict';
	const CONST_DATA_NAME              = "mba-reimbursement-history-widget-data";
	const CONST_CURRENT_YEAR_ID        = "mba-current-year-id";
	const CONST_CURRENT_YEAR_CSS_CLASS = "mba-reimbursement-history-content-current-year";
	const CONST_LAST_YEAR_ID           = "mba-last-year-id";
	const CONST_LAST_YEAR_CSS_CLASS    = "mba-reimbursement-history-content-last-year";
	const CONST_ANNUAL_GOAL_ID         = "mba-annual-goal-id";
	const CONST_ANNUAL_GOAL_CSS_CLASS  = "mba-reimbursement-history-content-annual-goal";

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const CONST_DEFAULT_OPTIONS = {
		footerText: ''
	};

	
	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGetMe
	 * @private
	 * @summary      Gets reference to original elemement
	 * @description  Gets reference to original elemement
	 * @param  {Object}  elem  Element reference
	 */

	let _fnGetMe = function (elem) { return $(elem); }

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnDestroy
	 * @private
	 * @summary      Destroy existing instance
	 * @description  Destroy existing instance
	 * @param  {Object}  elem  Element reference
	 */

	let _fnDestroy = function (elem) {
		let $me = _fnGetMe(elem);
		$me.removeData(CONST_DATA_NAME);
		return;
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnSetTooltipData
	 * @private
	 * @summary      sets tipso tooltips for circles
	 * @description  sets tipso tooltips for circles
	 */

	let _fnSetTooltipData = function ($elem, content) {
		$elem.tipso('destroy').tipso({
			speed: 400
			, background: '#ffd60d'
			, titleBackground: '#333333'
			, color: 'black'
			, titleColor: '#ffffff'
			, titleContent: ''
			, showArrow: true
			, position: 'top'
			, width: 250
			, maxWidth: ''
			, delay: 200
			, hideDelay: 0
			, animationIn: ''
			, animationOut: ''
			, offsetX: 0
			, offsetY: 0
			, tooltipHover: true
			, content: content
			, ajaxContentUrl: null
			, contentElementId: null
			, useTitle: false
			, templateEngineFunc: null
			, onBeforeShow: null
			, onShow: null
			, onHide: null
		});
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRenderWidgets
	 * @private
	 * @summary      renders the widget title and circles
	 * @description  renders the widget title and circles
	 */

	let _fnRenderWidgets = function ($me, dataObj) {

		var $colHeaders = $('<div class="col-12 mt-2 mb-auto p-0 text-break border-0 d-flex text-center"></div>');

		// add the column headers if necessary
		if (dataObj.opts.renderHeaders) {
			let colHeadersArr;
			try {
				colHeadersArr = (dataObj.opts.colHeaders) ? JSON.parse(dataObj.opts.colHeaders) : [];
				if (!Array.isArray(colHeadersArr)) { colHeadersArr = []; }
			} catch (e) {
				colHeadersArr = [];
			}

			// append placeholder for spacing
			$colHeaders.append($('<div class="col-3 mt-auto mb-auto p-0 text-break border-0 font-weight-bold"></div>'));

			$.each(colHeadersArr, function (idx, header) {
				var $colHeader = $('<div class="col-3 mt-auto mb-auto p-0 text-break border-0 font-weight-bold">' + header + '</div>');
				$colHeaders.append($colHeader);
			});
        }

		var $contentDiv = $('<div class="col-12 mt-2 mb-auto p-0 text-break border-0 d-flex text-center"></div>');
		var $title = $('<div class="col-3 mt-auto mb-auto p-0 text-break border-0 font-weight-bold">' + dataObj.opts.title + '</div>');

		var $currYrAmt	= $('<div class="col-3 p-0 text-center d-flex justify-content-center align-items-center"><div id="' + CONST_CURRENT_YEAR_ID + '-' + $($me).attr('id') + '" class="d-flex justify-content-center align-items-center ' + CONST_CURRENT_YEAR_CSS_CLASS + '"><span><i class="fa fa-spinner fa-pulse fa-fw"></i></span></div></div>');
		var $lastYrAmt	= $('<div class="col-3 p-0 text-center d-flex justify-content-center align-items-center"><div id="' + CONST_LAST_YEAR_ID    + '-' + $($me).attr('id') + '" class="d-flex justify-content-center align-items-center ' + CONST_LAST_YEAR_CSS_CLASS + '"><span><i class="fa fa-spinner fa-pulse fa-fw"></i></span></div></div>');
		var $annGoalAmt = $('<div class="col-3 p-0 text-center d-flex justify-content-center align-items-center"><div id="' + CONST_ANNUAL_GOAL_ID  + '-' + $($me).attr('id') + '" class="d-flex justify-content-center align-items-center ' + CONST_ANNUAL_GOAL_CSS_CLASS + '"><span><i class="fa fa-spinner fa-pulse fa-fw"></i></span></div></div>');

		$contentDiv.append($title).append($currYrAmt).append($lastYrAmt).append($annGoalAmt);

		var $footer = $('<div class="col-12 d-flex justify-content-end p-0 mt-1">' + dataObj.opts.footerText + '</div>');

		$me.html($colHeaders.add($contentDiv).add($footer));
	};
	
	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGetAjaxData
	 * @private
	 * @summary      sends an ajax request to get data for sum and count
	 * @description  sends an ajax request to get data for sum and count
	 */

	let _fnGetAjaxData = function ($me, dataObj) {
		var reqData = '{}';

		MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.reqUrlThisYear, reqData, null)
			.then(responseData => {
				var $amtSpan = $('<span class="col-12 mt-auto mb-auto p-0 text-center">$' + responseData.rawData.totalNumAmt.totalAmtStr + '</span>');
				$('#' + CONST_CURRENT_YEAR_ID + '-' + $($me).attr('id')).html('').html($amtSpan);
			})
			.catch(responseData => {

			});

		MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.reqUrlLastYear, reqData, null)
			.then(responseData => {
				var $amtSpan = $('<span class="col-12 mt-auto mb-auto p-0 text-center">$' + responseData.rawData.totalNumAmt.totalAmtStr + '</span>');
				$('#' + CONST_LAST_YEAR_ID + '-' + $($me).attr('id')).html('').html($amtSpan);
			})
			.catch(responseData => {

			});

		MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.reqUrlGoalAmt, reqData, null)
			.then(responseData => {
				var $amtSpan = $('<span class="col-12 mt-auto mb-auto p-0 text-center">$' + responseData.rawData.totalNumAmt.totalAmtStr + '</span>');
				$('#' + CONST_ANNUAL_GOAL_ID + '-' + $($me).attr('id')).html('').html($amtSpan);
			})
			.catch(responseData => {

			});
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnCreate
	 * @private
	 * @summary      Create new instance
	 * @description  Create new instance
	 * @param  {Object}  elem    Element reference
	 * @param  {Object}  optsIn  Options reference
	 */

	let _fnCreate = function (elem, optsIn) {

		let $me = _fnGetMe(elem);

		/* See if we have created an instance of this plugin already for this element.  If so get out. */

		if (($me).data(CONST_DATA_NAME)) {
			($me).removeData(CONST_DATA_NAME);
			($me).children().remove();
		}

		/* Define the data object we will save later */

		let dataObj = {};

		/* Store reference to elem */

		dataObj.me = $me;

		/* Merge default options and options passed in. */

		let opts = $.extend({}, CONST_DEFAULT_OPTIONS, optsIn);
		dataObj.opts = opts;		

		$($me).data(CONST_DATA_NAME, dataObj); /* Save our data object.  This will be used for option calls */

		_fnRenderWidgets($me, dataObj);

		_fnGetAjaxData($me, dataObj);

	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	return {
		  fnCreate: _fnCreate
	};

})(jQuery);

/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Reports Widget plugin
 * @description  Reports Widget plugin
 * @requires     jQuery
 */

; (function ($) {

	'use strict';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/* Tie into jQuery namespace */

	$.fn.reimbursementHistoryWidget = function (methodOrOptions, optionsOrValue) {

		/* These are the supported methods and properties that can be accessed from outside after an instance is created */
		let _methods = {
		};

		let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

		/* Method is create */

		if (typeof methodOrOptions === 'object' || !methodOrOptions) {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.reimbursementHistoryWidget.fnCreate(elem, methodOrOptions);
			});
		}


	}; /* reimbursementHistoryWidget */

})(jQuery);