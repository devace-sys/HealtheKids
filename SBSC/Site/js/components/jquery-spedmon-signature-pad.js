; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.spedmonSignaturePad
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery
 */

MBA.spedmonSignaturePad = (function ($) {

	'use strict';
	const CONST_DATA_NAME = "spedmon-signature-pad-data"
	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const CONST_DEFAULT_OPTIONS = {		  
		  contElement: '<span></span>'
		, includeRenderDialogBtn: true
		, renderDialogBtnText:  'Sign'
		, renderDialogBtnClass: ''
		, inputNameAndID:       'spedmonsignaturepadbase64data' // hidden textarea
		, inputInitialValue:    ''							    // hidden textarea
		, fnSave:   function (signatureBase64Data) { }            // save callback. this function will have the signature data passed to it as a parameter
		, fnCancel: function () { }            // cancel callback. this function gets called if user exits out of the modal without saving
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGetDataObj
	 * @private
	 * @summary      Gets reference to data object
	 * @description  Gets reference to the jQuery data object associated with this element
	 * @param  {Object}  $me  Element reference
	 */

	let _fnGetDataObj = function ($me) {

		let dataObj = $($me).data(CONST_DATA_NAME);
		if (!dataObj) throw new Error('An instance of spedmonSignaturePad is required');
		return dataObj;
	}

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
	 * @function     _fnRenderDialogModal
	 * @private
	 * @summary      render signature in modal
	 * @description  render signature in modal
	 * @param  {Object}  elem  Element reference
	 */

	let _renderSignaturePadDialog = function (elem) {
		let dataObj = _fnGetDataObj(_fnGetMe(elem));
		let $sigDiv = $('<div><canvas class="ui-spedmon-signature-pad-canvas" width="350" height="200"></canvas></div>');
		let canvas = $sigDiv.children('canvas').get(0); // get canvas DOM element

		// initialize signature pad
		let signaturePad = new SignaturePad(canvas);

		// used to determine if user has signed or not
		var signatureSaved = false;

		// attach callback to "sign" button and append
		let $saveBtn = $('<button class="btn btn-info float-right mt-2">Save</button>');
		$saveBtn.on("click", function () {
			if (signaturePad.isEmpty()) {
				$(canvas).fadeOut(100).fadeIn(100).fadeOut(100).fadeIn(100);
				return;
			}
			let signatureBase64Data = signaturePad.toDataURL();
			dataObj.$input.val(signatureBase64Data);
			dataObj.opts.fnSave(signatureBase64Data);
			signatureSaved = true;
			$sigDiv.dialog('close');
		});
		$sigDiv.append($saveBtn);

		// attach callback to "clear" button and append
		let $clearBtn = $('<button class="btn btn-warning float-right mt-2 mr-2">Clear</button>');
		$clearBtn.on("click", function () {
			signaturePad.clear();
		});
		$sigDiv.append($clearBtn);

		$sigDiv.dialog(
			{
				width: 400
				, height: 400
				, title: "Please Sign"
				, show: {
					effect: 'fade',
					complete: function () {
						// preload data if exists               
						if (dataObj.$input.val()) {
							signaturePad.fromDataURL(dataObj.$input.val());
						}
					}
				}
				, hide: {
					  effect: 'fade'
					, direction: 'left'
					, complete: function () {
						// preload data if exists               
						if (!signatureSaved) {
							dataObj.opts.fnCancel();
						}
                    }
				}
				, open: function () {
					// source: https://stackoverflow.com/a/18257205
					$(this).dialog('widget').promise().done(function () {
						// preload data if exists               
						if (dataObj.$input.val()) {
							signaturePad.fromDataURL(dataObj.$input.val());
						}
					});
				}
				, close: function () {
					$(this).dialog('widget').promise().done(function () {
						// preload data if exists               
						if (!signatureSaved) {
							dataObj.opts.fnCancel();
						}
					});
					
                }
			}

		);
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
	
	/**
	 * @function     _fnRenderDialogModalHyQueue
	 * @private
	 * @summary      render signature in modal
	 * @description  render signature in modal
	 * @param  {Object}  elem  Element reference
	 */

	let _renderSignaturePadDialogHyQueue = function (elem) {
		let dataObj = _fnGetDataObj(_fnGetMe(elem));
		let $sigDiv = $('<div class="text-center"><canvas class="ui-spedmon-signature-pad-canvas" width="350" height="200"></canvas></div>');
		let canvas = $sigDiv.children('canvas').get(0); // get canvas DOM element

		// initialize signature pad
		let signaturePad = new SignaturePad(canvas);

		// used to determine if user has signed or not
		var signatureSaved = false;

		// set up dialog vars
		//let diaID = MBA.util.createNewUUID();
		let diaID = MBA.ComponentCommon.fnCreateNewUUID();
		let diaButtons = [
			{
				  text: 'Clear'
				, click: function () {
					signaturePad.clear();
				}
			}
			,
			{
				  text: 'Save'
				, click: function () {
					signatureSaved = true;
					if (signaturePad.isEmpty()) {
						$(canvas).fadeOut(100).fadeIn(100).fadeOut(100).fadeIn(100);
						return;
                    }
					let signatureBase64Data = signaturePad.toDataURL();
					dataObj.$input.val(signatureBase64Data);
					dataObj.opts.fnSave(signatureBase64Data);
					MBA.responsizeDialog.close(diaID);
				}
			}			
		];

		MBA.responsizeDialog.createNew(
			  diaID
			, 'Please Sign'
			, $sigDiv
			, 95
			, 50
			, false
			, false
			, false
			, null
			, function (event, ui) {
				if (dataObj.$input.val()) {
					signaturePad.fromDataURL(dataObj.$input.val());
				}
			}
			, function () { }
			, diaButtons);
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

		/* append hidden textarea which will store input */
		
		dataObj.$input = $('<textarea name="' + dataObj.opts.inputNameAndID + '" id="' + dataObj.opts.inputNameAndID + '" style="display:none;">' + dataObj.opts.inputInitialValue + '</textarea>');
		$me.append(dataObj.$input);

		/* append button to render signaturePad in dialog if needed
		 * Otherwise launch the signature dialog
		*/
		if (dataObj.opts.includeRenderDialogBtn) {
			let $renderBtn = $('<button class="' + dataObj.opts.renderDialogBtnClass + '">' + dataObj.opts.renderDialogBtnText + '</button>');
			$renderBtn.on("click", function () { _renderSignaturePadDialog(elem); });
			dataObj.$renderBtn = $renderBtn;
			$me.append(dataObj.$renderBtn);
			$($me).data(CONST_DATA_NAME, dataObj); /* Save our data object.  This will be used for option calls */
		} else {
			$($me).data(CONST_DATA_NAME, dataObj); /* Save our data object.  This will be used for option calls */
			_renderSignaturePadDialog(elem);
		} 
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnCreateHyQueue
	 * @private
	 * @summary      Create new instance
	 * @description  Create new instance
	 * @param  {Object}  elem    Element reference
	 * @param  {Object}  optsIn  Element reference
	 */

	let _fnCreateHyQueue = function (elem, optsIn) {

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

		/* append hidden textarea which will store input */
		
		dataObj.$input = $('<textarea name="' + dataObj.opts.inputNameAndID + '" id="' + dataObj.opts.inputNameAndID + '" style="display:none;">' + dataObj.opts.inputInitialValue + '</textarea>');
		$me.append(dataObj.$input);

		/* append button to render signaturePad in dialog if needed
		 * Otherwise launch the signature dialog
		*/
		if (dataObj.opts.includeRenderDialogBtn) {
			let $renderBtn = $('<button class="' + dataObj.opts.renderDialogBtnClass + '">' + dataObj.opts.renderDialogBtnText + '</button>');
			$renderBtn.on("click", function () { _renderSignaturePadDialogHyQueue(elem); });
			dataObj.$renderBtn = $renderBtn;
			$me.append(dataObj.$renderBtn);
			$($me).data(CONST_DATA_NAME, dataObj); /* Save our data object.  This will be used for option calls */
		} else {
			$($me).data(CONST_DATA_NAME, dataObj); /* Save our data object.  This will be used for option calls */
			_renderSignaturePadDialogHyQueue(elem);
		} 
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	return {
		  fnCreate: _fnCreate
		, fnCreateHyQueue: _fnCreateHyQueue
	};

})(jQuery);

/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Signature Pad plugin
 * @description  Signature Pad plugin
 * @requires     jQuery
 */

; (function ($) {

	'use strict';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/* Tie into jQuery namespace */

	$.fn.spedmonSignaturePad = function (methodOrOptions, optionsOrValue) {

		/* These are the supported methods and properties that can be accessed from outside after an instance is created */

		let _methods = {
		};

		let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

		/* Method is create */

		if (typeof methodOrOptions === 'object' || !methodOrOptions) {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.spedmonSignaturePad.fnCreate(elem, optionsOrValue);
			});
		}


	}; /* spedmonSignaturePad */

	/* Tie into jQuery namespace */

	$.fn.spedmonSignaturePadHyQueue = function (methodOrOptions, optionsOrValue) {

		/* These are the supported methods and properties that can be accessed from outside after an instance is created */

		let _methods = {
		};

		let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

		/* Method is create */

		if (typeof methodOrOptions === 'object' || !methodOrOptions) {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.spedmonSignaturePad.fnCreateHyQueue(elem, optionsOrValue);
			});
		}


	}; /* spedmonSignaturePad */

})(jQuery);