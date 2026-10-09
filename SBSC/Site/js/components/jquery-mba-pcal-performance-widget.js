; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.pcalPerformanceWidget
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery
 */

MBA.pcalPerformanceWidget = (function ($) {

	'use strict';
	const CONST_DATA_NAME           = "mba-pcal-performance-widget-data";
	const CONST_IFRAME_CONT_CLASS   = "mba-pcal-performance-widget-iframe-cont";
	const CONST_IFRAME_CLASS        = "mba-pcal-performance-widget-iframe";

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const CONST_DEFAULT_OPTIONS = {
		  title: 'Program Health'
		, footerText: ''
		, iframeSrcUrl: ''
		, popUpPageUrl: ''
		, openPopUpOnSamePage:false
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

		/* Create title elements */

		var $title = $('<div class="col-12 d-flex mb-2 pt-1 justify-content-between text-break">'
			+ '<span class="col-1"></span>'
			+ '<h4>' + dataObj.opts.title + '</h4>'
			+ '<span class="col-1"></span>'
			+ '</div>');

		/* Create program health elements */

		var $programHealthDiv        = $('<div class="d-flex justify-content-center align-items-center col-12 p-0 row m-0"></div>');
		var $programHealthIFrameCont = $('<button type="button" class="' + CONST_IFRAME_CONT_CLASS + '"></button>');
		var $programHealthIFrame     = $('<iframe scrolling="no" class="' + CONST_IFRAME_CLASS + '" height="500" src="about:blank"></iframe>');
		var $footer                  = $('<div class="col-12 d-flex justify-content-end p-0 mt-1">' + dataObj.opts.footerText + '</div>');

		/* Build up markup */
		$($programHealthIFrameCont).append($programHealthIFrame);
		$($programHealthDiv).append($programHealthIFrameCont);

		/* Append new markup */

		$($me).append($title);
		$($me).append($programHealthDiv);
		$($me).append($footer);

		$($me).data(CONST_DATA_NAME, dataObj); /* Save our data object.  This will be used for option calls */

		$($programHealthIFrameCont).on('click', function () {
			if (dataObj.opts.openPopUpOnSamePage == false) {
				MBA.ComponentCommon.fnOpenTab(dataObj.opts.popUpPageUrl, null);
			}
			else {
				MBA.ComponentCommon.fnGotoURL(dataObj.opts.popUpPageUrl);
            }
		});

	
		// set iframe source

		$(window).on('load', function () {
			$($programHealthIFrame).attr('src', dataObj.opts.iframeSrcUrl);
		});

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

	$.fn.pcalPerformanceWidget = function (methodOrOptions, optionsOrValue) {

		/* These are the supported methods and properties that can be accessed from outside after an instance is created */
		let _methods = {
		};

		let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

		/* Method is create */

		if (typeof methodOrOptions === 'object' || !methodOrOptions) {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.pcalPerformanceWidget.fnCreate(elem, methodOrOptions);
			});
		}


	}; /* pcalPerformanceWidget */

})(jQuery);