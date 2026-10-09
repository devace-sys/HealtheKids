;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ComponentCommon
 * @memberof     MBA
 * @summary      Static methods used by all components
 * @description  Static methods used by all components
 * @requires     jQuery
 */

MBA.ComponentCommon = (function ($) {

	'use strict';


	/*##############################################################################################################################################################
	  #                                                                 CONSTANTS
	  ##############################################################################################################################################################*/


	const _REGEX_STATE_PATTERN = /^\[\d{1,}\]/i;

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _REGEX_CODE_PATTERN = /\d{1,}/;

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _RETURN_CODES = {
		SUCCESS: 0
		, INFO: 1
		, WARNING: 2
		, CRITICAL: 3
		, ERROR: 4
		, ABORT_OR_CANCEL: 5
		, SESSION_EXPIRE: 12
		, PASSWORD_LOCK: 14
		, DUP_RECORD: 20
		, REDIRECT: 50
		, FATAL: 99
	};


  /*##############################################################################################################################################################
    #                                                                UTILITIES
    ##############################################################################################################################################################*/

	/**
	 * @function    _fnCreateNewUUID
	 * @private
	 * @summary      Generates a unique identifier
	 * @description  Generates a unique identifier
	 */

	let _fnCreateNewUUID = function () {
		let dt = new Date().getTime();
		let uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
			let r = (dt + Math.random() * 16) % 16 | 0;
			dt = Math.floor(dt / 16);
			return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
		});
		return uuid;
	}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnCopyTextToClipboard
 * @private
 * @summary      Copies value to clipboard
 * @description  Copies value to clipboard.  Calls fnOnComplete when done.
 *               Calls fnOnFail if there is an exception.
 */

let _fnCopyTextToClipboard = async function (value, fnOnComplete, fnOnFail) {
	if (!fnOnComplete) fnOnComplete = function (valuePassed) { return; };
	if (!fnOnFail)     fnOnFail     = function (valuePassed, err) { return; };
    try {
	  await navigator.clipboard.writeText(value);
	  fnOnComplete(value);
    } catch (err) {
      fnOnFail(value, err);
    }
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnResizeIframeToFitContent
 * @private
 * @summary      Resizes iframe matched by id to fit its contents
 * @description  Resizes iframe matched by id to fit its contents
 */

let _fnResizeIframeToFitContent = function (iframeID) {
	/* Based on code shared on https://usefulangle.com/post/65/javascript-automatically-resize-iframe */
	let iframe = document.getElementById(iframeID);
	iframe.style.height = iframe.contentDocument.body.scrollHeight + 'px';
	iframe.style.width = iframe.contentDocument.body.scrollWidth + 'px';
	return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSendMessageToResizeIframeToFitContent
 * @private
 * @summary      Sends a message to the parent window to resize iframeID with the data in message
 * @description  Sends a message to the parent window to resize iframeID with the data in message
 */

let _fnSendMessageToResizeIframeToFitContent = function (channelName, iframeID) {
    /* Based on code shared on https://usefulangle.com/post/65/javascript-automatically-resize-iframe and https://stackoverflow.com/a/47080814 */
	let bc = new BroadcastChannel(channelName);	
	let messageData = { whatChannel:channelName, whatiframe:iframeID};
    bc.postMessage(messageData);	
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnResizeIframeToFitContentFromMessage
 * @private
 * @summary      Resize iframe specified in message
 * @description  Resize iframe specified in message
 */

let _fnResizeIframeToFitContentFromMessage = function (message) {
  /* Based on code shared on https://usefulangle.com/post/65/javascript-automatically-resize-iframe */
  let messageData = message.data;
  _fnResizeIframeToFitContent(messageData.whatiframe);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnCreateResizeIframeToFitContentFromMessageListener
 * @private
 * @summary      Listens for message from child and calls handler.  Handler routes to right iframe
 * @description  Listens for message from child and calls handler.  Handler routes to right iframe
 */

let _fnCreateResizeIframeToFitContentFromMessageListener = function (channelName) {
    /* Based on code shared on https://usefulangle.com/post/65/javascript-automatically-resize-iframe and https://stackoverflow.com/a/47080814 */
	var bc = new BroadcastChannel(channelName);
	bc.onmessage = function (message) {		
	  _fnResizeIframeToFitContentFromMessage(message);
	};
	return bc; /* Must be set as a window level variable*/
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnFullScreenForPageToggle
 * @private
 * @summary      Enters or exits full screen mode for page based on full screen state
 * @description  Enters or exits full screen mode for page based on full screen state
 */

let _fnFullScreenForPageToggle = function () {
	if (document.fullscreenElement) {
		return document.exitFullscreen();
	} else {
		return document.documentElement.requestFullscreen();
	}
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnOpenWindow
 * @private
 * @summary      Opens url in new window
 * @description  Opens url in new window
 */

let _fnOpenWindow = function (url, windowName) {
  /* If no window name is passed we create one */
  if (!windowName) windowName = '' + _fnCreateNewUUID();
  let w = Math.floor((window.innerWidth * .90));
  let h = window.innerHeight; /* Note: Chrome requires this. */
  let wos = 'width=' + w + ',height=' + h + ',scrollbars=1,top=1,left=1,menubar=1,toolbar=0';
  var windowObj = window.open(url, windowName, wos);
  windowObj.focus();
  return windowObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnOpenTab
 * @private
 * @summary      Opens url in new tab
 * @description  Opens url in new tab
 */

let _fnOpenTab = function (url, windowName) {
  /* If no window name is passed we create one */
  if (!windowName) windowName = '' + _fnCreateNewUUID();
  var windowObj = window.open(url, windowName);
  windowObj.focus();
  return windowObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnOpenWindowAndCallFnOnClose
 * @private
 * @summary      Opens url in new window and call fnOnClose
 * @description  Opens url in new window and call fnOnClose
 */

let _fnOpenWindowAndCallFnOnClose = function (url, windowName, dataToPassToFnOnClose, fnOnClose) {

	let windowObj = _fnOpenWindow(url,windowName)

	windowObj.addEventListener('beforeunload', function (e) {
		fnOnClose(dataToPassToFnOnClose);
	}, { once: true });

    return windowObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGotoURL
 * @private
 * @summary      Opens url in current window
 * @description  Opens url in current window
 */

let _fnGotoURL = function (url) {
  window.location.assign(url);	
  return window;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnHasValue
 * @private
 * @summary      Tests if valueIn has a value
 * @description  Tests if valueIn has a value
 */

let _fnHasValue = function (valueIn) {

  let _hasValue = true;
  if ((typeof valueIn === 'undefined') || (valueIn === null)) {
		_hasValue = false;
  }
  return _hasValue;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnFactorToPercent
 * @private
 * @summary      Takes a number between 1 and 100 and converts it to a fractional value
 * @description  Takes a number between 1 and 100 and converts it to a fractional value
 */

let _fnFactorToPercent = function (factor)  {
    const FACTOR_ERROR_MSG = 'Factor must be an integer value between 0 and 100';
    if (!Number.isInteger(factor)) { throw FACTOR_ERROR_MSG; return null; }
    if (factor < 1) { throw FACTOR_ERROR_MSG; return null; }
    if (factor > 100) { throw FACTOR_ERROR_MSG; return null; }
    let pct = (factor * .01);
    return pct;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnGetCurrentViewportWidthInPx
 * @private
 * @summary      Gets current viewport width in px
 * @description  Gets current viewport width in px
 * @author       Courtesey of ryanve <https://stackoverflow.com/a/8876069>               
 */

let _fnGetCurrentViewportWidthInPx = function () {
  return Math.max(document.documentElement.clientWidth || 0, window.innerWidth || 0);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnGetCurrentViewportHeightInPx
 * @private
 * @summary      Gets current viewport height in px
 * @description  Gets current viewport height in px
 * @author       Courtesey of ryanve <https://stackoverflow.com/a/8876069>
 */

let _fnGetCurrentViewportHeightInPx = function () {  
  return Math.max(document.documentElement.clientHeight || 0, window.innerHeight || 0);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnComputePercentOfViewportWidthInPx
 * @private
 * @summary      Computes a percentage (0-100) of current width in px
 * @description  Computes a percentage (0-100) of current width in px
 *               This seeks to mimic what CSS vw does
 */

let _fnComputePercentOfViewportWidthInPx = function (factor) {
  let cvw = _fnGetCurrentViewportWidthInPx();
  let pct = _fnFactorToPercent(factor);
  let pvw = Math.round((cvw * pct));
  return pvw;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnComputePercentOfViewportHeightInPx
 * @private
 * @summary      Computes a percentage (0-100) of current height in px
 * @description  Computes a percentage (0-100) of current height in px
 *               This seeks to mimic what CSS vh does
 */

let _fnComputePercentOfViewportHeightInPx = function (factor) {
    let cvh = _fnGetCurrentViewportHeightInPx();
    let pct = _fnFactorToPercent(factor);
    let pvh = Math.round((cvh * pct));
    return pvh;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnComputeIntPctFromIntAAndIntB
 * @private
 * @summary      Computes a percentage (0 - 100+) using a/b
 * @description  Computes a percentage (0 - 100+) using a/b
 */

let _fnComputeIntPctFromIntAAndIntB = function (a,b) {
	try {
		let _a = Number.parseInt(a);
		let _b = Number.parseInt(b);
		if (Number.isNaN(_a)) return 0;
		if (Number.isNaN(_b)) return 0;
		return Math.round(((_a / _b) * 100));
	} catch {
		return 0;
    }
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnComputeIntProductFromIntValueAndIntPct
 * @private
 * @summary      Computes the product of value times (pct/100)
 * @description  Computes the product of value times (pct/100)
 */

let _fnComputeIntProductFromIntValueAndIntPct = function (value,pct) {
	try {
		let _v = Number.parseInt(value);
		let _pct = Number.parseInt(pct);
		if (Number.isNaN(_v)) return 0;
		if (Number.isNaN(_pct)) return 0;
		let _pFactor = (_pct / 100);
		return Math.round((_v * _pFactor));
	} catch {
		return 0;
    }
};


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnGetDialogTitleMarkupReference
 * @private
 * @summary      Get a reference to a jquery ui dialog widget title markup
 * @description  Get a reference to a jquery ui dialog widget title markup
 */

let _fnGetDialogTitleMarkupReference = function ($dia) {
	return $($dia).dialog("widget").find(".ui-dialog-titlebar");
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnGetDialogButtonsMarkupReference
 * @private
 * @summary      Get a reference to a jquery ui dialog widget buttons markup
 * @description  Get a reference to a jquery ui dialog widget buttons markup
 */

let _fnGetDialogButtonsMarkupReference = function ($dia) {
	return $($dia).dialog("widget").find('.ui-dialog-buttonset').children();	
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateDialogFromElem
 * @private
 * @summary      Generates and opens dialog from existing elem and destroys dialog on close
 * @description  Generates and opens dialog from existing elem and destroys dialog on close.  It does not remove existing content in elem.
 * @param  {Object}  elem     Reference to element to create a dialog from  
 * @param  {Object}  options  jQuery UI dialog options
 */

let _fnCreateDialogFromElem = function (elem, wpct, hpct, options) {

	$(elem).dialog('destroy');
	$(elem).hide();

	if (!_fnHasValue(wpct)) wpct = 50;
	if (!_fnHasValue(hpct)) hpct = 50;

	let vw = _fnComputePercentOfViewportWidthInPx(wpct);
	let vh = _fnComputePercentOfViewportHeightInPx(hpct);
	
	let dfltOptions = {
		  position: { my: 'center', at: 'center', of: window }
		, show: { effect: 'slide', direction: 'left' }
		, closeOnEscape: false
		, width: (vw)
		, height: (vh)
		, modal: true		
		, close: function (event, ui) {
			$(elem).hide();
			$(this).dialog('destroy');
		}
	};
	let opts = $.extend({}, dfltOptions, options);
	return $(elem).dialog(opts);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateDialogFromElemWithProceedAndCancel
 * @private
 * @summary      Generates and opens dialog from existing elem and destroys dialog on close
 * @description  Generates and opens dialog from existing elem and destroys dialog on close.  It does not remove existing content in elem.
 * @param  {Object}  elem     Reference to element to create a dialog from
 * @param  {Object}  options  jQuery UI dialog options
 * @param  {Object}   fnOnProceed      function to run when proceed is clicked.
 * @param  {Object}   fnOnCancel       function to run when cancel is clicked.
 * @param  {boolean}  closeOnProceed   If true dialog closes after fnOnProceed is executed
 * @param  {boolean}  closeOnCancel    If true dialog closes after fnOnCancel is executed
 */

let _fnCreateDialogFromElemWithProceedAndCancelButtons = function (
	  elem
	, wpct
	, hpct
	, options
	, fnOnProceed
	, fnOnCancel
	, closeOnProceed = null
	, closeOnCancel  = null)
{

	if (!_fnHasValue(closeOnProceed)) closeOnProceed = true;
	if (!_fnHasValue(closeOnCancel))  closeOnCancel = true;
	if (!fnOnProceed) fnOnProceed = function () { return; };
	if (!fnOnCancel) fnOnCancel   = function () { return; };

	let _additionalOpts = {		
		buttons: [
		  	  { text: "Cancel",  click: function () { fnOnCancel();  if (closeOnCancel == true) $(this).dialog("close"); } }
			, { text: "Proceed", click: function () { fnOnProceed(); if (closeOnProceed == true) $(this).dialog("close"); }}			
		]		
	}

	let opts = $.extend({}, _additionalOpts, options);

	return _fnCreateDialogFromElem(elem, wpct, hpct, opts);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateOneTimeDialog
 * @private
 * @summary      Generates a one time use dialog
 * @description  Generates a one time use dialog that destroys itself and removes any injected content on close
 * @param  {String}  title  Title of dialog
 * @param  {Object}  content  Dialog content
 * @param  {Object}  options  jQuery UI dialog options
 */

let _fnCreateOneTimeDialog = function (title, content, options) {

	var dialogID = _fnCreateNewUUID();
	var diaSel   = '#' + dialogID;
	var dia      = $('<div></div>');

	dia.attr('id', dialogID);
	dia.attr('title', title);	
	$(dia).append(content);
	$('body').append(dia);

	let vw = _fnComputePercentOfViewportWidthInPx(80);
	let vh = _fnComputePercentOfViewportHeightInPx(80);

	let dfltOptions = {
	    position: { my: 'center', at: 'center', of: window }
	  , show: { effect: 'slide', direction: 'left' }
      , closeOnEscape: false
	  , width: (vw)
	  , height:(vh)
	  , close: function (event, ui) {
		  $(this).dialog('destroy'); $(diaSel).remove();
		}
	}

	let opts = $.extend({}, dfltOptions, options);
	return $(diaSel).dialog(opts);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateOneTimeInfoDialog
 * @private
 * @summary      Generates a one time use info dialog
 * @description  Generates a one time use info dialog that destroys itself and removes any injected content on close
 * @param  {String}  title  Title of dialog
 * @param  {Object}  content  Dialog content
 * @param  {Object}  options  jQuery UI dialog options
 */

let _fnCreateOneTimeInfoDialog = function (title, content, options) {

	let vw = _fnComputePercentOfViewportWidthInPx(80);
	let vh = _fnComputePercentOfViewportHeightInPx(80);

	let dfltOptions = {
		  width: (vw)
		, height: (vh)
		, modal: true
		, resizable: false
		, buttons: [{ text: "OK", click: function () { $(this).dialog("close"); } }]
	};
	let opts = $.extend({}, dfltOptions, options);
	return _fnCreateOneTimeDialog(title, content, opts);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateOneTimeAlertDialog
 * @private
 * @summary      Generates a one time use alert dialog
 * @description  Generates a one time use alert dialog that destroys itself and removes any injected content on close
 * @param  {String}  title  Title of dialog
 * @param  {Object}  content  Dialog content
 * @param  {Object}  options  jQuery UI dialog options
 */

let _fnCreateOneTimeAlertDialog = function (title, content, options) {

	let vw = _fnComputePercentOfViewportWidthInPx(50);
	let vh = _fnComputePercentOfViewportHeightInPx(50);

	let dfltOptions = {
		  width: (vw)
		, height: (vh)
		, modal: true
		, resizable: false
		, buttons: [{ text: "OK", click: function () { $(this).dialog("close"); } }]
	};
	let opts = $.extend({}, dfltOptions, options);
	return _fnCreateOneTimeDialog(title, content, opts);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateOneTimeProceedOrCancelDialog
 * @private
 * @summary      Generates a one time use dialog
 * @description  Generates a one time use dialog that destroys itself and removes any injected content on close
 * @param  {String}   title            Title of dialog
 * @param  {Object}   content          Dialog content
 * @param  {Object}   options          jQuery UI dialog options
 * @param  {Object}   fnOnProceed      function to run when proceed is clicked. 
 * @param  {Object}   fnOnCancel       function to run when cancel is clicked.  
 * @param  {boolean}  closeOnProceed   If true dialog closes after fnOnProceed is executed
 * @param  {boolean}  closeOnCancel    If true dialog closes after fnOnCancel is executed
 */

let _fnCreateOneTimeProceedOrCancelDialog = function (title, content, options, fnOnProceed, fnOnCancel, closeOnProceed = null, closeOnCancel = null) {

	let vw = _fnComputePercentOfViewportWidthInPx(50);
	let vh = _fnComputePercentOfViewportHeightInPx(50);
	if (!_fnHasValue(closeOnProceed)) closeOnProceed = true;
	if (!_fnHasValue(closeOnCancel)) closeOnCancel = true;
	if (!fnOnProceed) fnOnProceed = function () { return;};
	if (!fnOnCancel) fnOnCancel   = function () { return; };

	let dfltOptions = {
		width: (vw)
		, height: (vh)
		, modal: true
		, resizable: false
		, buttons: [
			  { text: "Cancel", click: function ()  { fnOnCancel();  if (closeOnCancel  == true) $(this).dialog("close");} }
			, { text: "Proceed", click: function () { fnOnProceed(); if (closeOnProceed == true) $(this).dialog("close");} }
		]
	};

	let opts = $.extend({}, dfltOptions, options);

	return _fnCreateOneTimeDialog(title, content, opts);

}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetVanillaJSRefFromJQueryRef
 * @private
 * @summary      Gets vanilla JS reference from jQuery reference
 * @description  Gets reference to original elemement
 * @param  {Object}  $field  Element reference
 */

let _fnGetVanillaJSRefFromJQueryRef = function ($field) {
	return $($field).get(0);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnMimeTypeToFaIconClassName
 * @private
 * @summary      Returns font awesome icon class name that represents mime type and a color class
 * @description  Returns font awesome icon class name that represents mime type and a color class
 */

let _fnMimeTypeToFaIconClassName = function (mimeType) {

	/* PDF */

	if (mimeType == 'application/pdf') return 'fa-file-pdf mba-color-file-pdf';

	/* Office documents */

	else if (mimeType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') return 'fa-file-word mba-color-file-word';
	else if (mimeType == 'application/msword')                                                      return 'fa-file-word mba-color-file-word';
	else if (mimeType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')       return 'fa-file-excel mba-color-file-excel';
	else if (mimeType == 'application/vnd.ms-excel')                                                return 'fa-file-excel mba-color-file-excel';

	/* Images*/

	else if (mimeType == 'image/jpeg') return 'fa-file-image mba-color-file-image';
	else if (mimeType == 'image/png')  return 'fa-file-image mba-color-file-image';

	/* Structured data */

	else if (mimeType == 'text/csv')   return 'fa-file-csv mba-color-file-csv';

	/* Generic */

	else return 'fa-file mba-color-file';

};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFlagValueToTrueFalse
 * @private
 * @summary      Returns true if valueIn matches a typical bi-state value
 * @description  Returns true if valueIn matches a typical bi-state value
 */

let _fnFlagValueToTrueFalse = function (valueIn) {

  if (     (valueIn === '1')
		|| (valueIn === 'y')
		|| (valueIn === 'Y')
		|| (valueIn === true)
		|| (valueIn === 'true')
		|| (valueIn === 'on')
		|| (valueIn === 'On')
	    || (valueIn === 'ON')
	    || (valueIn === 'Yes')
		|| (valueIn === 'yes')
   	    || (valueIn === 'YES')
    ) {
	    return true;
	};

	if (
		   (valueIn === '0')
		|| (valueIn === 'n')
		|| (valueIn === 'N')
		|| (valueIn === false)
		|| (valueIn === 'false')
		|| (valueIn === 'off')
		|| (valueIn === 'Off')
		|| (valueIn === 'OFF')
		|| (valueIn === 'No')
		|| (valueIn === 'no')
		|| (valueIn === 'NO')
	) {
		return false;
	};
	return false;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetCheckBoxState
 * @private
 * @summary      Gets state of checkbox
 * @description  Gets state of checkbox
 * @param  {Object}  elem  Element reference
 */

let _fnGetCheckBoxState = function ($input) {
	if (($input).is(':checked')) return true;
	return false;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSetCheckBoxState
 * @private
 * @summary      Sets state of checkbox
 * @description  Sets state of checkbox
 * @param  {Object}  elem  Element reference
 */

let _fnSetCheckBoxState = function ($input, flagValue) {

	/* Convert incoming flag value to a bool */

	let _cbState = _fnFlagValueToTrueFalse(flagValue);

	/* Set state to checked if applicable otherwise remove checked state*/

	if (_cbState === true) {
	  $($input).prop('checked', true).attr('checked', true); 
	}
	else {
	  $($input).prop('checked', false).removeAttr('checked');
	}
	return _cbState;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSelectOptionSetSelectedState
 * @private
 * @summary      Sets selected state for select option
 * @description  ets selected state for select option
 * @param  {Object}  $option  Element reference
 * @param  bool      flagValue true or false or Y or N or 1 or 0
 */

let _fnSelectOptionSetSelectedState = function ($option, flagValue) {

	/* Convert incoming flag value to a bool */

	let _selectedState = _fnFlagValueToTrueFalse(flagValue);

	/* Set state to checked if applicable otherwise remove checked state*/

	if (_selectedState === true) {
	  $($option).prop('selected', true).attr('selected', true); 
	}
	else {
	  $($option).prop('selected', false).removeAttr('selected');
	}
	return _selectedState;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnEnableElement
 * @private
 * @summary      Enable input, textarea, button
 * @description  Enable input, textarea, button by removing disabled attribute.
 * @param  {Object}  elem  Element reference
 */

let _fnEnableElement = function (elem) {
	$(elem).prop('disabled', false).removeAttr('disabled');	
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnDisableElement
 * @private
 * @summary      Disable input, textarea, button
 * @description  Disable input, textarea, button by setting disabled attribute.  Note: Disabled elements are not submitted in a form by default.
 * @param  {Object}  elem  Element reference
 */

let _fnDisableElement = function (elem) {
	$(elem).prop('disabled', true).attr('disabled','disabled');	
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnDisableOrEnableElement
 * @private
 * @summary      Enable or disable elem (input, textarea, button) based on disabled flag
 * @description  Enable or disable elem (input, textarea, button) based on disabled flag.  Note: Disabled elements are not submitted in a form by default.
 * @param  {Object}  elem  Element reference
 * @param  {bool}    disabled  true : Disable, false: Enable
 */

let _fnDisableOrEnableElement = function (elem, disabled) {
	if (disabled === true) return _fnDisableElement(elem); else return _fnEnableElement(elem);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnUnlockElement
 * @private
 * @summary      Unlock input, textarea, select, etc
 * @description  Unlocks field by removing readonly attribute
 * @param  {Object}  elem  Element reference
 */

let _fnUnlockElement = function (elem) {
	$(elem).prop('readonly', false).removeAttr('readonly');
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnLockElement
 * @private
 * @summary      Lock input, textarea, select, etc
 * @description  Locks field by adding readonly attribute
 * @param  {Object}  elem  Element reference
 */

let _fnLockElement = function (elem) {	
	$(elem).prop('readonly', true).attr('readonly', 'readonly');
};
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFlagElementAsInertOrNotInert
 * @private
 * @summary     Flag element as inert or not
 * @description  Sets the elements inert attribute.   
 *               Inert elements and all of their descendants are visible but otherwise ignored by the browser.
 *               Users cannot interact with them.
 *               See https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/inert
 * @param  {Object}  elem  Element reference
 * @param  {bool}    inert true : elem is set to inert, false: inert flag is removed
 */

let _fnFlagElementAsInertOrNotInert = function (elem, inert) {
	if (inert === true) {
		$(elem).prop('inert', true).attr('inert', 'inert');
	}
	else {
		$(elem).prop('inert', false).removeAttr('inert');
    }	
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnScrollElementIntoView
 * @private
 * @summary      Scrolls element into view
 * @description  Scrolls element into view using vanilla JS method
 * @see          <https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollIntoView>
 * @param  {Object}  elem        Element reference
 * @param  {bool}    alignToTop  true or false
 */

let _fnScrollElementIntoView = function (elem, alignToTop) {
	if (!_fnHasValue(alignToTop)) alignToTop = true;
	let jsElemRef = _fnGetVanillaJSRefFromJQueryRef(elem);
	jsElemRef.scrollIntoView(alignToTop);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnGetCurrentDateTimeAsHTML5DateAndTimeStrs
 * @private
 * @summary      Returns object containing current date and time in HTML5DateStr and HTML5TimeHHMMStr 
 * @description  Returns object containing current date and time in HTML5DateStr and HTML5TimeHHMMStr
 */

let _fnGetCurrentDateTimeAsHTML5DateAndTimeStrs = function () {
	let _todayObj = {};
	let _todayUTC   = new Date();                                                                /* Recall that time is UTC */
	var _todayLocal = new Date(_todayUTC.getTime() - _todayUTC.getTimezoneOffset() * 60 * 1000); /* So we have to ajust to get local time */
	let _todayJSONStr          = _todayLocal.toJSON();                                           /*2022-06-17T11:06:50.369Z*/
	_todayObj.HTML5DateStr     = _todayJSONStr.slice(0, 10);                                     /*2022-06-17*/
	_todayObj.HTML5TimeHHMMStr = _todayJSONStr.slice(11, 16);                                    /*11:06 */
	return _todayObj;		
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnFormatDateTimeToRptDate
 * @private
 * @summary      Value is assumed to be a JSON serialized datatime value.  Returns value as mm/dd/yyyy string.
 * @description  Value is assumed to be a JSON serialized datatime value.  Returns value as mm/dd/yyyy string.
 * @author       MDN Docs <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat>
 */

let _fnFormatDateTimeToRptDate = function (value) {
	let _date      = new Date(value);
	//let _formatter = new Intl.DateTimeFormat('en-US').format(_date);
	let _formatter = new Intl.DateTimeFormat('en-US', { day: "2-digit", month: "2-digit", year: "numeric" });
	return _formatter.format(_date);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnFormatDateTimeToRptTime
 * @private
 * @summary      Value is assumed to be a JSON serialized datatime value.  Returns value as hh:mm:ss AM|PM string.
 * @description  Value is assumed to be a JSON serialized datatime value.  Returns value as hh:mm:ss AM|PM string.
 * @author       MDN Docs <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/toLocaleTimeString>
 */

let _fnFormatDateTimeToRptTime = function (value) {
	let _date = new Date(value);
	return _date.toLocaleTimeString('en-US');
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnFormatDateTimeToYYYYMMDDTHHMM
 * @private
 * @summary      Returns value as YYYYMMDDTHHMM string.
 * @description  Value is assumed to be a JSON serialized datatime value or other valid date time string.  Returns value as YYYYMMDDTHHMM string suitable for HTML input value.
 * @author       Based on solution provided by neurino <https://stackoverflow.com/a/61082536>
 */

let _fnFormatDateTimeToYYYYMMDDTHHMM = function (value) {
	let _date = new Date(value);
	return _date.toISOString().slice(0, 16);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnFormatNumbertoUSD
 * @private
 * @summary      Returns a string representation of value formatted as USD
 * @description  Returns a string representation of value formatted as USD
 * @author       MDN Docs <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat>
 */

let _fnFormatNumberToUSD = function (value) {
  let _formatter = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD'});
  return _formatter.format(value);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnChangeNumbertoUSD
 * @private
 * @summary      Returns a string representation of value formatted as USD
 * @description  Returns a string representation of value formatted as USD
 */

let _fnChangeNumberToUSD = function (value) {
	value = '' + value; // for cases where decimal is passed

	let formattedValue = '';
	if (value) {
		let inputValNoComma = value.replace(/,/g, '');
		let p = parseFloat(inputValNoComma).toFixed(2).split(".");
		formattedValue = p[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,") + "." + p[1];
	}
	return formattedValue;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnBuildUrl
 * @private
 * @summary      Builds a uri encoded url
 * @description  Builds a url encoded url
 */

let _fnBuildUrl = function (baseURL, baseHasParameters, parameters) {
  let url = baseURL;
  if (!parameters) parameters = [];
  if (baseHasParameters === false) url = url + '?ts=1';
  $.each(parameters, function (parmIdx, parameter) {	  
	  url = url + '&' + encodeURIComponent(parameter.name) + '=' + encodeURIComponent(parameter.value);
  });
  return url;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnDetailsStrToDetailObj
 * @private
 * @summary      Extracts details from response into an object
 * @description  Extracts details from response into an object
 */

let _fnDetailStrToDetailObj = function (detailStr, defaultCode) {
  let detailObj = { code: (defaultCode), msg: (detailStr) };
  if (_REGEX_STATE_PATTERN.test(detailStr) === true) {
     let stateCodeContainer = _REGEX_STATE_PATTERN.exec(detailStr);    // Extract code container [x]
     detailObj.code = _REGEX_CODE_PATTERN.exec(stateCodeContainer)[0]; // Extract code itself x
	 detailObj.msg = detailStr.replace(_REGEX_STATE_PATTERN, "");      // Remove code container from detail leaving just detail text
  }
  return detailObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateNameValueObj
 * @private
 * @summary      Generic utility function to create object containing name and value
 * @description  Generic utility function to create object containing name and value
 * @param  {Object}  name  
 * @parm   {Object} value;
 */

let _fnCreateNameValueObj = function (name, value) {
  let nvo = {};
  nvo.name = name;
  nvo.value = value;
  return nvo;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateNameValueObjByInputName
 * @private
 * @summary      Generic utility function to create object containing name and value using #name as selector to a jQuery input
 * @description  Generic utility function to create object containing name and value using #name as selector to a jQuery input
 * @param  {Object}  name  
 * @parm   {Object} value;
 */

let _fnCreateNameValueObjByInputName = function (name) {
  let value = $('#' + name).val();
  return _fnCreateNameValueObj(name, value);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnJSONFromArrNameValues
 * @private
 * @summary      Create json request string for use by fnAjaxCallAsmxWebMethod dataToPost from name/value parameters
 * @description  Create json request string for use by fnAjaxCallAsmxWebMethod dataToPost from name/value parameters
 * @param  {Object}  parameters
 */

let _fnJSONFromArrNameValues = function (arrNameValues) {

	let newReqObj = {};
	$.each(arrNameValues, function (parmIdx, parameter) {
		newReqObj[parameter.name] = '' + parameter.value;
	});
	let newReqJSON = JSON.stringify(newReqObj);
	return newReqJSON;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnNameValuesArrFromMapKeysValues
 * @private
 * @summary      Create array of name value objects from map
 * @description  Create array of name value objects from a map of key/values
 * @param  {Object}  parameters
 */

let _fnNameValuesArrFromMapKeysValues = function (mapKeysValues) {
    let arrNameValues = [];
    mapKeysValues.forEach(function (value, key) {
	    arrNameValues.push(_fnCreateNameValueObj(key, value));
	});
	return arrNameValues;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnJSONFromMapKeysValues
 * @private
 * @summary      Create json request string for use by fnAjaxCallAsmxWebMethod dataToPost from a map of key/values
 * @description  Create json request string for use by fnAjaxCallAsmxWebMethod dataToPost from a map of key/values
 * @param  {Object}  parameters
 */

let _fnJSONFromMapKeysValues = function (mapKeysValues) {
	let arrNameValues = _fnNameValuesArrFromMapKeysValues(mapKeysValues);
	return _fnJSONFromArrNameValues(arrNameValues);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _convertFromOneToManyKeyValuesToOneToArray
 * @private
 * @summary       Converts from one to many key (key: value1, key: value2) to one to array (key: [value1, value2])
 * @description  Converts from one to many key (key: value1, key: value2) to one to array (key: [value1, value2])
 * @param  {Object}  frmNameValues
 * @param  {Object}  name
 */

	let _convertFromOneToManyKeyValuesToOneToArray = function (frmNameValues, name) {
		let valArr = []; // value to be returned

		// iterate through the keys and add values
		frmNameValues.forEach(function (value) {
			if (value.name == name) {
				valArr.push(value.value);
			}
		});

		// if single value, no need for array
		if (valArr.length == 1) valArr = valArr[0];

		// if no value, set back to original
		else if (valArr.length < 1) valArr = frmNameValues[name];

		// if multi value, return stringified array
		else valArr = JSON.stringify(valArr);

		return valArr;
	};
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnObjToNameValuesObj
 * @private
 * @summary      Converts obj into array of namevalue objects
 * @description  Converts obj into array of namevalue objects
 * @param  {Object}  obj
 */

let _fnObjToNameValuesObj = function (obj) {

  let arrNameValues = [];
		
  for(const [key, value] of Object.entries(obj)) {
	  arrNameValues.push(_fnCreateNameValueObj(key, value));	  
  }
  return arrNameValues;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSetAllFormElementsAsNonEditable
 * @private
 * @summary      Finds all form fields in element and sets as non editable
 * @description  Finds all form fields in element and sets as non editable
 * @param  {Object}  element
 */

let _fnSetAllFormFieldsAsNonEditable = function (element) {

	/* https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/inert */

	$(element).find('input').each(function () {
		let $inp = this;
		$($inp).attr('inert','inert');
	});

	$(element).find('select').each(function () {
		let $sel = this;
		$($sel).attr('inert', 'inert');
	});

	$(element).find('textarea').each(function () {
		let $ta = this;
		$($ta).attr('inert', 'inert');
	});
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
	
/**
 * @function     _fnFormSerializeIncludingDisabled
 * @private
 * @summary      Version of $(form).serializeArray that includes disabled form elements
 * @description  Version of $(form).serializeArray that includes disabled form elements.  
 *               Generates an object containing form name and value pairs.
 *               Based on https://stackoverflow.com/q/15958671.
 * @param  {Object}  formRef
 */

let _fnFormSerializeIncludingDisabled = function (formRef) {
    var frmArr = [];
	$(formRef).find(':input').each(function () {
		frmArr.push({ name: this.name, value: $(this).val() });		
	});
	return frmArr;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFormToObjIncludingDisabled
 * @private
 * @summary      Generates an object containing form name and value pairs including disabled items
 * @description  Generates an object containing form name and value pairs including disabled items
 * @param  {Object}  formRef
 */

let _fnFormToObjIncludingDisabled = function (formRef) {
   var frmObj = {};
   if (!formRef) return frmObj;
   let frmNameValues = _fnFormSerializeIncludingDisabled(formRef);
   $.each(frmNameValues, function (idx, frmNameValue) {
     frmObj[frmNameValue.name] = _convertFromOneToManyKeyValuesToOneToArray (frmNameValues, frmNameValue.name);
   });
   return frmObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFormToObj
 * @private
 * @summary      Generates an object containing form name and value pairs
 * @description  Generates an object containing form name and value pairs
 * @param  {Object}  formRef
 */

let _fnFormToObj = function (formRef) {
   var frmObj = {};
   if (!formRef) return frmObj;
   let frmNameValues = $(formRef).serializeArray();
   $.each(frmNameValues, function (idx, frmNameValue) {
     frmObj[frmNameValue.name] = _convertFromOneToManyKeyValuesToOneToArray (frmNameValues, frmNameValue.name);
   });
   return frmObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFormToObjExceptForFieldNames
 * @private
 * @summary      Generates an object containing form name and value pairs except for fieldNames in fieldNamesToIgnore
 * @description  Generates an object containing form name and value pairs except for fieldNames in fieldNamesToIgnore
 * @param  {Object}  formRef
 */

let _fnFormToObjExceptForFieldNames = function (formRef, fieldNamesToIgnore) {
   var frmObj = {};
   if (!formRef) return frmObj;
   let frmNameValues = $(formRef).serializeArray();
   $.each(frmNameValues, function (idx, frmNameValue) {
	if (fieldNamesToIgnore.includes(frmNameValue.name) == true) return;
     frmObj[frmNameValue.name] = _convertFromOneToManyKeyValuesToOneToArray (frmNameValues, frmNameValue.name);
   });
   return frmObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAddNameValueToArrNameValues
 * @private
 * @summary      Adds name/value pair to arrNameValues and returns new copy of arrNameValues
 * @description  Adds name/value pair to arrNameValues and returns new copy of arrNameValues
 * @param  {Array}   arrNameValues
 * @param  {string}  name
 * @param  {string}  value
 */

let _fnAddNameValueToArrNameValues = function (arrNameValues, name, value) {
  arrNameValues.push(_fnCreateNameValueObj(name, value));
  return arrNameValues;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFindNameValueObjIdxByNameInArrNameValues
 * @private
 * @summary      Finds nameValueObj by name in arrNameValues and returns the index.
 * @description  Finds nameValueObj by name in arrNameValues and returns the index.
 * @param  {Array}   arrNameValues
 * @param  {string}  name
 */

let _fnFindNameValueObjIdxByNameInArrNameValues = function (arrNameValues, name) {

  let _idxFound = -1;
  
  arrNameValues.forEach(function (arrNameValue, idx) {
    if (arrNameValue.name == name) {
	  _idxFound = idx;
	  return;
	}
  });
  
  return _idxFound;
    
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFormToJSON
 * @private
 * @summary      Generates a JSON list of form field name,value pair data from HTML form
 * @description  Generates a JSON list of form field name,value pair data from HTML form
 * @param  {Object}  formRef
 */

let _fnFormToJSON = function (formRef) {   
  let frmObj = _fnFormToObj(formRef);
  var json = JSON.stringify(frmObj);
  return json;  
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFormToObjAsynch
 * @private
 * @summary      Promisefied version. Generates an object containing form name and value pairs
 * @description  Promisefied version. Generates an object containing form name and value pairs
 * @param  {Object}  formRef
 */

let _fnFormToObjAsynch = function (formRef) {
 return new Promise((resolve, reject) => {
      if (!formRef) reject(new Error('Form reference must be provided'));
      var frmObj = _fnFormToObj(formRef);
      resolve(frmObj);
    });
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFormToJSONAsynch
 * @private
 * @summary      Promisefied version. Generates a JSON list of form field name,value pair data from HTML form
 * @description  Promisefied version. Generates a JSON list of form field name,value pair data from HTML form
 * @param  {Object}  formRef
 */

let _fnFormToJSONAsynch = function (formRef) {   
    return new Promise((resolve, reject) => {    
        _fnFormToObjAsynch(formRef).then(frmObj => {let json = JSON.stringify(frmObj); resolve(json);})
                         .catch(convErr => { reject(new Error(convErr)) });
    });
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFormByIDToJSONAsynch
 * @private
 * @summary      Generates a JSON list of form field name,value pair data from HTML form
 * @description  Generates a JSON list of form field name,value pair data from HTML form.  Replacement for MBA.util.formToJSON().
 * @param  {Object}  formID
 */

let _fnFormByIDToJSONAsynch = function (formID) {      
   let formRef = $('#' + formID);  
   return _fnFormToJSONAsynch(formRef);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnFileDownload
 * @private
 * @summary      Downloads stored file
 * @description  Downloads stored file
 */

let _fnFileDownload = function (downloadHandlerUrl, downloadHandlerUrlHasParms, recIdParmName, recIdParmValue) {

  let parms = [];
  parms.push(_fnCreateNameValueObj(recIdParmName, recIdParmValue));
	let url = _fnBuildUrl(downloadHandlerUrl, downloadHandlerUrlHasParms, parms);
	
   $.fileDownload ( url, {
      preparingMessageHtml : "We are preparing the file download, please wait...",
      failMessageHtml : "There was a problem downloading the file. The file may not be available for download yet. Please wait a moment and then try again."
   });
}; 

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*#############################################################################################################################################################
  #                                                                AJAX ROUTINES
  ##############################################################################################################################################################*/
/**
 * @function     _fnAjaxCallCore
 * @private
 * @summary      Core AJAX routine
 * @description  Core AJAX routine
 */

let _fnAjaxCallCore = function (urlToPostTo, dataToPost, sessionExpiredUrl, contentType, webService) {

  return new Promise((resolve, reject) => {

      let reqOpts = {};
      reqOpts.method      = 'POST';
	  reqOpts.type        = 'POST';
	  reqOpts.data        = dataToPost;
      reqOpts.processData = false;
	  reqOpts.contentType = contentType; /*'application/json; charset=UTF-8';*/

      let responseData = {};
      responseData.type    = null;
      responseData.status  = null;
      responseData.message = null;
      responseData.details = new Array();

	  $.ajax(urlToPostTo, reqOpts)
		  .done(function (data, textStatus, jqXHR) {
			  if (webService === true) {
				  if (data.hasOwnProperty('d')) {
					  /* Provide .NET 3.5 compatibility for web service calls
					   * Courtesy of http://encosia.com/never-worry-about-asp-net-ajaxs-d-again/ */
					  let dataInD = data.d;
					  data = dataInD;
				  }
				  responseData.type = data.__type;
			  }
			  else {
				  responseData.type = '';
              }
			  
			  responseData.status  = data.status;
			  responseData.message = data.message;

			  if (data.details) {
				  $.each(data.details, function (i, detailStr) {
					  let detailObj = _fnDetailStrToDetailObj(detailStr, data.status);
					  responseData.details.push(detailObj);
				  });
			  }

			  responseData.rawData = data;
			  if ((responseData.status === _RETURN_CODES.SESSION_EXPIRE) && (sessionExpiredUrl)) window.location.assign(sessionExpiredUrl);
			  if (responseData.status != _RETURN_CODES.SUCCESS) reject(responseData);
			  resolve(responseData);
		  })
		  .fail(function (jqXHR, textStatus, errorThrown) {
			  responseData.status = _RETURN_CODES.ERROR;
			  responseData.message = textStatus;
			  reject(responseData);
		  })
		  .always(function (dataOrjqXHR, textStatus, jqXHROrerrorThrown) {
		  });
   });
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAjaxCallAsmxWebMethod
 * @private
 * @summary      Call one of our ASMX web methods
 * @description  Call one of our ASMX web methods
 */

let _fnAjaxCallAsmxWebMethod = function (urlToPostTo, dataToPost, sessionExpiredUrl) {
  return _fnAjaxCallCore(urlToPostTo, dataToPost, sessionExpiredUrl, 'application/json; charset=UTF-8', true);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAjaxCallAsmxWebMethodSynch
 * @private
 * @summary      Call one of our ASMX web methods synchronously
 * @description  Call one of our ASMX web methods synchronously
 */

let _fnAjaxCallAsmxWebMethodSynch = async function (urlToPostTo, dataToPost, sessionExpiredUrl) {
    let responseData = await _fnAjaxCallAsmxWebMethod(urlToPostTo, dataToPost, sessionExpiredUrl);
	return responseData;	
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAjaxPostFormDataMultiPart
 * @private
 * @summary      Posts formData to urlToPostTo
 * @description  Posts formData to urlToPostTo.  formData is an instance of FormData.
 *               See: https://developer.mozilla.org/en-US/docs/Web/API/FormData
 */

let _fnAjaxPostFormDataMultiPart = function (urlToPostTo, formData, sessionExpiredUrl) {
  return _fnAjaxCallCore(urlToPostTo, formData, sessionExpiredUrl, false, true);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAjaxCallAsmxWebMethodSynch
 * @private
 * @summary      Posts formData to urlToPostTo synchronously
 * @description  Posts formData to urlToPostTo synchronously
 */

let _fnAjaxPostFormDataMultiPartSynch = async function (urlToPostTo, formData, sessionExpiredUrl) {
	let responseData = await _fnAjaxPostFormDataMultiPart(urlToPostTo, formData, sessionExpiredUrl);		
	return responseData;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
	* @function     _fnRequestDownloadWebReportDocument
	* @private
	* @summary      Downloads a web report
	* @description  Downloads a web report
	*/

	let _fnRequestDownloadWebReportDocument = function (requestUrl, reportFormat = 2, reportNumber = -1, fileName, parameters, fnSuccessCallback, fnFailureCallback) {

		if (!requestUrl) {
			return;
		}

		if (!parameters) {
			parameters = [];
		}

		if (!fnSuccessCallback) {
			fnSuccessCallback = function () { };
		}

		if (!fnFailureCallback) {
			fnFailureCallback = function () { };
		}

		/* Get our stored data */
		try {
			let rptRequestUid = MBA.ComponentCommon.fnCreateNewUUID();

			parameters.push(_fnCreateNameValueObj('reptform', reportFormat));
			parameters.push(_fnCreateNameValueObj('reptnumber', reportNumber));
			parameters.push(_fnCreateNameValueObj('reptpaging', '0'));
			parameters.push(_fnCreateNameValueObj('reptcolsonly', '0'));
			parameters.push(_fnCreateNameValueObj('repteditview', ''));
			parameters.push(_fnCreateNameValueObj('reptreqguid', rptRequestUid));

			let rptRequestUrl = _fnBuildUrl(requestUrl, true, parameters);

			/* Download link method courtesy of https://stackoverflow.com/a/43523297 */
			let dLink = document.createElement('a');
			dLink.href = rptRequestUrl;
			dLink.download = fileName;
			dLink.click();

			/* We sent a uid to the server and a cookie with a name of uid and value of file will be set when the download is ready */

			let dTimer = null;
			let dTimerFn = function () {
				let dCookiesStr = document.cookie;
				if (!dCookiesStr) return;
				let dCookies = dCookiesStr.split('; ');
				if (!dCookies) return;
				let rptResponseCookie = dCookies.find(row => row.startsWith(rptRequestUid + '='));
				if (!rptResponseCookie) return;
				let rptResponseValStr = rptResponseCookie.split('=')[1];
				if (rptResponseValStr) {
					window.clearInterval(dTimer);
					dLink.remove();
					fnSuccessCallback();
				}
			}
			dTimer = window.setInterval(dTimerFn, 1000);
		} catch (err) {
			fnFailureCallback();
		}
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnElemDoRequestDownloadWebReportDocument
	 * @private
	 * @summary      Use as a on click handler for a button or other element that downloads a web report
	 * @description  Use as a on click handler for a button or other element that downloads a web report
	 */

	let _fnElemDoRequestDownloadWebReportDocument = function (elem, requestUrl, reportFormat, reportNumber, fileName, parameters, fnSuccessCallback, fnFailureCallback)
	{
		if (!requestUrl) {
			return;
		}

		if (!fnSuccessCallback) {
			fnSuccessCallback = function () { };
		}

		if (!fnFailureCallback) {
			fnFailureCallback = function () { };
		}

		let $waitingIcon = $('<i class="fa fa-spinner fa-pulse fa-fw m-auto"></i>');
		$(elem).append($waitingIcon);
		_fnDisableElement(elem);

		let _scb = function () { _fnEnableElement(elem); $waitingIcon.remove(); fnSuccessCallback(); };
		let _fcb = function () { _fnEnableElement(elem); $waitingIcon.remove(); fnFailureCallback(); };

		return _fnRequestDownloadWebReportDocument(requestUrl, reportFormat, reportNumber, fileName, parameters, _scb, _fcb);
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnElemDisableAndAddSpinner
	 * @private
	 * @summary      Use to temp disable a element and let user know via spinner
	 * @description  Use to temp disable a element and let user know via spinner
	 */

	let _fnElemDisableAndAddSpinner = function (elem) {
		let $waitingIcon = $('<i class="fa fa-spinner fa-pulse fa-fw m-auto"></i>');
		$(elem).append($waitingIcon);
		_fnDisableElement(elem);
		return $waitingIcon;
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnElemEnableAndRemoveSpinner
	 * @private
	 * @summary      Use to renable a element and remove spinner
	 * @description  Use to renable a element and remove spinner
	 */

	let _fnElemEnableAndRemoveSpinner = function (elem, waitingIcon) {
		$(waitingIcon).remove();
		_fnEnableElement(elem);
	};


/*#############################################################################################################################################################
  #                                                                   PUBLIC METHODS
  # MBA.ComponentCommon.method  
  #
  ##############################################################################################################################################################*/

return {
    RETURN_CODES: _RETURN_CODES
  , REGEX_STATE_PATTERN: _REGEX_STATE_PATTERN
  , REGEX_CODE_PATTERN: _REGEX_CODE_PATTERN
  , fnCreateNewUUID: _fnCreateNewUUID
  , fnCopyTextToClipboard: _fnCopyTextToClipboard
  , fnHasValue: _fnHasValue
  , fnFlagValueToTrueFalse: _fnFlagValueToTrueFalse
  , fnMimeTypeToFaIconClassName: _fnMimeTypeToFaIconClassName
  , fnFormatDateTimeToRptDate: _fnFormatDateTimeToRptDate
  , fnFormatDateTimeToRptTime: _fnFormatDateTimeToRptTime
  , fnFormatDateTimeToYYYYMMDDTHHMM: _fnFormatDateTimeToYYYYMMDDTHHMM
  , fnFormatNumberToUSD: _fnFormatNumberToUSD
  , fnChangeNumberToUSD: _fnChangeNumberToUSD
  , fnGetVanillaJSRefFromJQueryRef: _fnGetVanillaJSRefFromJQueryRef
  , fnBuildUrl:_fnBuildUrl
  , fnDetailStrToDetailObj:_fnDetailStrToDetailObj
  , fnCreateNameValueObject: _fnCreateNameValueObj
  , fnCreateNameValueObjByInputName: _fnCreateNameValueObjByInputName
  , fnFileDownload: _fnFileDownload  
  , fnAjaxCallAsmxWebMethod: _fnAjaxCallAsmxWebMethod
  , fnAjaxCallAsmxWebMethodSynch: _fnAjaxCallAsmxWebMethodSynch
  , fnRequestDownloadWebReportDocument: _fnRequestDownloadWebReportDocument
  , fnFormToObjAsynch: _fnFormToObjAsynch
  , fnFormToJSONAsynch: _fnFormToJSONAsynch
  , fnFormByIDToJSONAsynch : _fnFormByIDToJSONAsynch
  , fnFormToObj: _fnFormToObj
  , fnFormToJSON: _fnFormToJSON
  , fnFactorToPercent: _fnFactorToPercent
  , fnGetCurrentViewportWidthInPx: _fnGetCurrentViewportWidthInPx
  , fnGetCurrentViewportHeightInPx: _fnGetCurrentViewportHeightInPx
  , fnComputePercentOfViewportWidthInPx: _fnComputePercentOfViewportWidthInPx
  , fnComputePercentOfViewportHeightInPx: _fnComputePercentOfViewportHeightInPx
  , fnCreateDialogFromElem: _fnCreateDialogFromElem
  , fnCreateDialogFromElemWithProceedAndCancelButtons: _fnCreateDialogFromElemWithProceedAndCancelButtons
  , fnCreateOneTimeDialog: _fnCreateOneTimeDialog
  , fnCreateOneTimeAlertDialog: _fnCreateOneTimeAlertDialog
  , fnCreateOneTimeInfoDialog: _fnCreateOneTimeInfoDialog
  , fnCreateOneTimeProceedOrCancelDialog: _fnCreateOneTimeProceedOrCancelDialog
  ,	fnGetDialogTitleMarkupReference: _fnGetDialogTitleMarkupReference
  ,	fnGetDialogButtonsMarkupReference: _fnGetDialogButtonsMarkupReference
  , fnJSONFromArrNameValues: _fnJSONFromArrNameValues
  , fnJSONFromMapKeysValues: _fnJSONFromMapKeysValues
  , fnOpenWindow: _fnOpenWindow
  , fnOpenTab: _fnOpenTab
  , fnGotoURL: _fnGotoURL
  , fnFullScreenForPageToggle: _fnFullScreenForPageToggle
  , fnGetCheckBoxState: _fnGetCheckBoxState
  , fnSetCheckBoxState: _fnSetCheckBoxState
  , fnObjToNameValuesObj: _fnObjToNameValuesObj
  , fnResizeIframeToFitContent: _fnResizeIframeToFitContent
  , fnSendMessageToResizeIframeToFitContent: _fnSendMessageToResizeIframeToFitContent
  , fnResizeIframeToFitContentFromMessage: _fnResizeIframeToFitContentFromMessage
  , fnCreateResizeIframeToFitContentFromMessageListener: _fnCreateResizeIframeToFitContentFromMessageListener
  , fnOpenWindowAndCallFnOnClose: _fnOpenWindowAndCallFnOnClose
  , fnEnableElement: _fnEnableElement
  , fnDisableElement: _fnDisableElement
  , fnDisableOrEnableElement: _fnDisableOrEnableElement
  , fnUnlockElement: _fnUnlockElement
  , fnLockElement: _fnLockElement
  , fnFlagElementAsInertOrNotInert: _fnFlagElementAsInertOrNotInert
  , fnElemDoRequestDownloadWebReportDocument: _fnElemDoRequestDownloadWebReportDocument
  , fnComputeIntPctFromIntAAndIntB: _fnComputeIntPctFromIntAAndIntB
  , fnComputeIntProductFromIntValueAndIntPct: _fnComputeIntProductFromIntValueAndIntPct
  , fnNameValuesArrFromMapKeysValues: _fnNameValuesArrFromMapKeysValues
  , fnSetAllFormFieldsAsNonEditable: _fnSetAllFormFieldsAsNonEditable
  , fnFormToObjExceptForFieldNames: _fnFormToObjExceptForFieldNames
  , fnElemDisableAndAddSpinner: _fnElemDisableAndAddSpinner
  , fnElemEnableAndRemoveSpinner: _fnElemEnableAndRemoveSpinner
  , fnGetCurrentDateTimeAsHTML5DateAndTimeStrs: _fnGetCurrentDateTimeAsHTML5DateAndTimeStrs
  , fnScrollElementIntoView: _fnScrollElementIntoView
  , fnFindNameValueObjIdxByNameInArrNameValues: _fnFindNameValueObjIdxByNameInArrNameValues
  , fnAddNameValueToArrNameValues: _fnAddNameValueToArrNameValues
  , fnSelectOptionSetSelectedState: _fnSelectOptionSetSelectedState
  , fnFormSerializeIncludingDisabled: _fnFormSerializeIncludingDisabled
  , fnFormToObjIncludingDisabled: _fnFormToObjIncludingDisabled
  ,	fnAjaxPostFormDataMultiPart: _fnAjaxPostFormDataMultiPart
  , fnAjaxPostFormDataMultiPartSynch: _fnAjaxPostFormDataMultiPartSynch

};

})(jQuery);

