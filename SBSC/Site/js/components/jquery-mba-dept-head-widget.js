; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.deptHeadWidget
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery
 */

MBA.deptHeadWidget = (function ($) {

	'use strict';
	const CONST_DATA_NAME            = "mba-dept-head-widget-data";
	const CONST_LINK1_ID             = "mba-dept-head-link1-id";
	const CONST_CSS_CLASS_LINK       = "mba-dept-head-link";

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const CONST_DEFAULT_OPTIONS = {
		  title: 'Department Head'
		, footerText: ''
		, link1Title: ''
		, link1Url: ''
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

		let $title = $('<div class="col-12 d-flex mb-2 pt-1 justify-content-between text-break">'
			+ '<span class="col-1"></span>'
			+ '<h4>' + dataObj.opts.title + '</h4>'
			+ '<span class="col-1"></span>'
			+ '</div>');

		/* Create elements */

		let $contentDiv = $('<div></div>');

		let $link1 = $('<span id="' + CONST_LINK1_ID + '">' + dataObj.opts.link1Title + '</span>');
		$($link1).addClass(CONST_CSS_CLASS_LINK + ' ml-2 p-2');
		// for future links, we do $link2, $link3,...

		let $footer = $('<div class="col-12 d-flex justify-content-end p-0 mt-1">' + dataObj.opts.footerText + '</div>');	
		
		/* Build up markup */

		$($contentDiv).append($link1);

		/* Append new markup */

		$($me).append($title);
		$($me).append($contentDiv);
		$($me).append($footer);

		$($me).data(CONST_DATA_NAME, dataObj); /* Save our data object.  This will be used for option calls */

		$($link1).on('click', function () {
			
			if (dataObj.opts.link1Url) {
				let fnEntryTest = function () { return true; };
				let fnExitTest = function () { return true; };
				let fnResume = function () { return true; };

				$.spedmonWebUI.popupThenResume(fnEntryTest
					, fnExitTest
					, fnResume
					, dataObj.opts.link1Url
					, 'Popups Not Supported'
					, 'Please allow popups for SpEdCare'
					, 'Waiting'
					, 'Waiting for you to finish viewing the popup screen');
			}
			
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

	$.fn.deptHeadWidget = function (methodOrOptions, optionsOrValue) {

		/* These are the supported methods and properties that can be accessed from outside after an instance is created */
		let _methods = {
		};

		let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

		/* Method is create */

		if (typeof methodOrOptions === 'object' || !methodOrOptions) {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.deptHeadWidget.fnCreate(elem, methodOrOptions);
			});
		}


	}; /* deptHeadWidget */

})(jQuery);