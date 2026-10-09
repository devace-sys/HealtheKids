; var MBA = (MBA || {});

/* TODO: Migrate server side code that generates label and icon here.  Also create seperate CSS file (move css out of controls.css, etc) */

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.LinkCommon
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery, Bootstrap, MBA.ComponentCommon
 */

MBA.LinkCommon = (function ($) {

	'use strict';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _PLUGIN_NAME  = 'MBA Link';
	const _PLUGIN_NS    = 'mba-link';
	const _JQ_DATA_NAME = 'jq-' + _PLUGIN_NS;

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _DEFAULT_OPTIONS = {
		  baseURL:''
		, openNew:false
		, baseHasParameters: true
		, hidden: false
		, dataToPassToFnOnClose:{}
		, fnOnClose:function(dataToPassToFnOnClose){}
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGetMe
	 * @private
	 * @summary      Gets reference to original elemement
	 * @description  Gets reference to original elemement
	 * @param  {Object}  elem  Element reference
	 */

	let _fnGetMe = function (elem) { return $(elem); };

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGetDataObj
	 * @private
	 * @summary      Gets reference to data object
	 * @description  Gets reference to the jQuery data object associated with this element
	 * @param  {Object}  $me  Element reference
	 */

	let _fnGetDataObj = function ($me) {
		let dataObj = $($me).data(_JQ_DATA_NAME);
		if (!dataObj) throw new Error('An instance of ' + _PLUGIN_NAME + ' is required');
		return dataObj;
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnSetDataObj
	 * @private
	 * @summary      Save data object we are using to store data about instances of this component
	 * @description  Save data object we are using to store data about instances of this component
	 * @param  {Object}  $me
	 * @parm   {Object}  dataObj;
	 */

	let _fnSetDataObj = function ($me, dataObj) {
		$($me).data(_JQ_DATA_NAME, dataObj);
		return _fnGetDataObj($me);
	};

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
		$me.removeData(_JQ_DATA_NAME);
		return;
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnOnClick
	 * @private
	 * @summary      Click handler
	 * @description  Click handler
	 * @param  {Object}  elem Element reference
	 * 
	 */

	let _fnOnClick = function (elem) {
		let $me = _fnGetMe(elem);
		let dataObj = _fnGetDataObj($me);
		let _parameters = MBA.ComponentCommon.fnNameValuesArrFromMapKeysValues(dataObj.opts.requestDataParameters);
		
		let _url = MBA.ComponentCommon.fnBuildUrl(dataObj.opts.baseURL, dataObj.opts.baseHasParameters, _parameters);
		let _wobj = null;
		
		if (dataObj.opts.openNew === true)
		{
		  _wobj =  MBA.ComponentCommon.fnOpenWindowAndCallFnOnClose(_url, null, dataObj.opts.dataToPassToFnOnClose, dataObj.opts.fnOnClose);
		}
		else {
		  _wobj = MBA.ComponentCommon.fnGotoURL (_url);
		}
		
		return _wobj;
	};
	
	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRequestDataParameterSetOrUpdate
	 * @private
	 * @summary      Sets or updates 
	 * @description  Sets or updates
	 * @param  {Object}  elem Element reference
	 * 
	 */

	let _fnRequestDataParameterSetOrUpdate = function (elem, parameterNameValueObj) {
		let $me = _fnGetMe(elem);
		let dataObj = _fnGetDataObj($me);
		dataObj.opts.requestDataParameters.set(parameterNameValueObj.name, parameterNameValueObj.value);
		_fnSetDataObj($me, dataObj);		
		return;
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnShow
	 * @private
	 * @summary      Show control
	 * @description  Show control
	 * @param  {Object}  elem  Element reference
	 */

	let _fnShow = function (elem) {
		let $me = _fnGetMe(elem);
		$($me).show();
		return;
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnHide
	 * @private
	 * @summary      Hide control
	 * @description  Hide control
	 * @param  {Object}  elem  Element reference
	 */

	let _fnHide = function (elem) {
		let $me = _fnGetMe(elem);
		$($me).hide();
		return;
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnIsElemSupported
	 * @private
	 * @summary      Is the element we are enhancing supported by the plugin
	 * @description  Is the element we are enhancing supported by the plugin
	 * @param  {Object}  elem  Element reference
	 */

	let _fnIsElemSupported = function (elem) {
		return $(elem).is('button');
	};
	      
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

		/* Test to see if element is supported */

		if (_fnIsElemSupported(elem) === false) return;

		/* See if we have created an instance of this plugin already for this element.  If so get out. */

		let dataObj = $($me).data(_JQ_DATA_NAME);
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
		opts.requestDataParameters = new Map();
		
		/* Save references */
		
		dataObj.opts = opts;
        
		/* Save our data object.  This will be used for option calls */

		$($me).data(_JQ_DATA_NAME, dataObj);
				
		/* Assign handler */
		
		$($me).on('click', function (e) { _fnOnClick(elem); });

		/* Hide if neccessary */

		if (opts.hidden == true) $($me).hide();

	  }

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	return {
		  PLUGIN_NAME: _PLUGIN_NAME
		, fnCreate: _fnCreate
		, fnDestroy: _fnDestroy
		, fnRequestDataParameterSetOrUpdate: _fnRequestDataParameterSetOrUpdate
		, fnShow: _fnShow
		, fnHide: _fnHide
	};

})(jQuery);


/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Report Download Button
 * @description  Report Download Button
 * @requires     jQuery
 */

; (function ($) {

	'use strict';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/* Tie into jQuery namespace */

	$.fn.MBA_Link = function (methodOrOptions, optionsOrValue) {

		/* These are the supported methods and properties that can be accessed from outside after an instance is created */

		let _methods = {					
			requestDataParameterSetOrUpdate: function (elem, value) {
		      return MBA.LinkCommon.fnRequestDataParameterSetOrUpdate(elem, value);
			}
			, show: function (elem) {
			  return MBA.LinkCommon.fnShow(elem);
			}
			, hide: function (elem) {
			  return MBA.LinkCommon.fnHide(elem);
            }
		};

		let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

		/* Method is create */

		if (typeof methodOrOptions === 'object' || !methodOrOptions) {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.LinkCommon.fnCreate(elem, methodOrOptions);
			});
		}

		/* Method is destroy */

		else if (methodOrOptions == 'destroy') {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.LinkCommon.fnDestroy(elem);
			});
		}

		/* Other methods (these cannot be chained) */

		else if (_methods[methodOrOptions]) {
			if (numOf == 1) {
				let elem = this[0]; /* There is only one element matched so we can proceed */
				return _methods[methodOrOptions](elem, optionsOrValue);
			}

			/* More than one element matched.  We cannot apply */
			else if (numOf > 1) { throw new Error(MBA.LinkCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' cannot be applied to a set of elements at once.'); }
			/* No elements found */
			else { throw new Error(MBA.LinkCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' cannot be applied since the element was not found.'); }
		}

		/* Cant find the method */

		else {
			throw new Error(MBA.LinkCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method');
		}

	}; /* MBA_Link */

})(jQuery);
