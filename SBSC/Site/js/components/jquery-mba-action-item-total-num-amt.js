; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.actionItemTotalNumAmt
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery
 */

MBA.actionItemTotalNumAmt = (function ($) {

	'use strict';
	const CONST_DATA_NAME              = "mba-action-item-total-num-amt-data";
	const CONST_CIRCLE_COUNT_CSS_CLASS = 'mba-action-item-content-circle-number-count';
	const CONST_DIVIDER_CSS_CLASS      = 'mba-action-item-content-circle-number-divider';
	const CONST_CIRCLE_SUM_CSS_CLASS   = 'mba-action-item-content-circle-number-sum';
	const CONST_CIRCLE_CONT_CSS_CLASS  = 'mba-action-item-content-circle-cont d-flex justify-content-center align-items-center rounded-circle';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const CONST_DEFAULT_OPTIONS = {
		  includeCount:        true
		, includeSum:          true
		, footerText:          ''
		, countUnits:          ''
		, detailsLinkOnly: false
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

	let _fnRenderWidgets = function ($me, dataObj, renderLoadingIcon, count, sum) {

		var $title = $('<div class="col-4 mt-auto mb-auto  p-0 text-break border-0">' + dataObj.opts.title + '</div>');

		var $circlesDiv = (renderLoadingIcon) ?
			// loading icon
			$('<div class="d-flex justify-content-end align-items-center col-8 p-0"><i class="fa fa-spinner fa-pulse fa-3x fa-fw"></i></div>') 
			:
			// markup for circles and divider
			$('<div class="d-flex justify-content-end align-items-center col-8 p-0">' 
				+
				( // include count if required
					(dataObj.opts.includeCount)
					?
					'<div class="' + CONST_CIRCLE_COUNT_CSS_CLASS + ' ' + CONST_CIRCLE_CONT_CSS_CLASS + '"><span class="col-12 p-0 text-center">' + count + '</span></div>'
					:
					''
				)
				+
				( // include barrier if both count and sum are required
					(dataObj.opts.includeCount && dataObj.opts.includeSum)
						?
					    '<div class="' + CONST_DIVIDER_CSS_CLASS + '">&nbsp;</div>'
						:
						''
				)
				+
				( // include sum if required
					(dataObj.opts.includeSum)
						?
						'<div class="' + CONST_CIRCLE_SUM_CSS_CLASS   + ' ' + CONST_CIRCLE_CONT_CSS_CLASS + '"><span class="col-12 p-0 text-center">$' + sum + '</span></div>'
						:
						''
				)
			+ '</div>');

		var $footer = $('<div class="col-12 d-flex justify-content-end p-0 mt-1">' + dataObj.opts.footerText + '</div>');

		// set tooltip data
		//_fnSetTooltipData($title, ''); // use later if needed (sets the tooltip for the title)
		_fnSetTooltipData($circlesDiv.find('.' + CONST_CIRCLE_COUNT_CSS_CLASS), count + ' ' + dataObj.opts.countUnits);
		_fnSetTooltipData($circlesDiv.find('.' + CONST_CIRCLE_SUM_CSS_CLASS)  , '$' + sum);

		$me.html($title.add($circlesDiv).add($footer));
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
     * @function     _fnRenderWidgetsDetailsLinkOnly
	 * @private
	 * @summary      renders the widget title and link icon
	 * @description  renders the widget title and link icon
	 */

	let _fnRenderWidgetsDetailsLinkOnly = function ($me, dataObj) {

	  var $title = $('<div class="col-4 mt-auto mb-auto  p-0 text-break border-0">' + dataObj.opts.title + '</div>');
	  var $circlesDiv = $('<div class="d-flex justify-content-end align-items-center col-8 p-0"><i class="fa fa-link fa-3x"></i></div>')
	  var $footer = $('<div class="col-12 d-flex justify-content-end p-0 mt-1">' + dataObj.opts.footerText + '</div>');
	  _fnSetTooltipData($circlesDiv, 'Summary data is not available.  Please click for details.');
	  $me.html($title.add($circlesDiv).add($footer));
	  
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGetAjaxData
	 * @private
	 * @summary      sends an ajax request to get data for sum and count
	 * @description  sends an ajax request to get data for sum and count
	 */

	let _fnGetAjaxData = function ($me, dataObj, reqUrl, reqData) {
		MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
			.then(responseData => {
				// render the widget title and circles
				_fnRenderWidgets($me, dataObj, false, responseData.rawData.totalNumAmt.totalNumStr, responseData.rawData.totalNumAmt.totalAmtStr);
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

		/* send ajax request to get data */

		var reqUrl  = dataObj.opts.urlTotalNumAmt;
		
		var reqData = '{}';

		$($me).data(CONST_DATA_NAME, dataObj); /* Save our data object.  This will be used for option calls */

		
		if (dataObj.opts.detailsLinkOnly === false) {
			_fnRenderWidgets($me, dataObj, true, null, null);
			_fnGetAjaxData($me, dataObj, reqUrl, reqData);
		}
		else {
			_fnRenderWidgetsDetailsLinkOnly($me, dataObj);
        }
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

	$.fn.actionItemTotalNumAmt = function (methodOrOptions, optionsOrValue) {

		/* These are the supported methods and properties that can be accessed from outside after an instance is created */

		let _methods = {
		};

		let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

		/* Method is create */

		if (typeof methodOrOptions === 'object' || !methodOrOptions) {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.actionItemTotalNumAmt.fnCreate(elem, methodOrOptions);
			});
		}


	}; /* actionItemTotalNumAmt */

})(jQuery);