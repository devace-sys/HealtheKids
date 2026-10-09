;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ActionItemCommon
 * @memberof     MBA
 * @summary      Static methods used by all components
 * @description  Static methods used by all components
 * @requires     jQuery
 */

MBA.ActionItemCommon = (function ($) {

'use strict';


/*##############################################################################################################################################################
  #                                                                 CONSTANTS
  ##############################################################################################################################################################*/

const _PLUGIN_NAME   = 'MBA Action Item Common';
const _PLUGIN_COMMON = 'mba-action-item-common';
const _JQ_DATA_NAME  = 'jq-' + _PLUGIN_COMMON;
const _COMMON_CHART_CONFIG = { responsive: true, displayModeBar: false };

/*##############################################################################################################################################################
  #                                                                UTILITIES
  ##############################################################################################################################################################*/

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
 
let _fnGetDataObj = function ($me)  { 
  let dataObj = $($me).data(_JQ_DATA_NAME);
  if (!dataObj) throw new Error('An instance of ' + _PLUGIN_NAME +' is required');
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

let _fnSetDataObj = function ($me,dataObj) {
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
 * @function     _fnRequestDataParameterSetOrUpdateFromFieldName
 * @private
 * @summary      Sets or updates 
 * @description  Sets or updates
 * @param  {Object}  elem Element reference
 * 
 */

let _fnRequestDataParameterSetOrUpdateFromFieldName = function (elem, name) {
	let nvo = MBA.ComponentCommon.fnCreateNameValueObjByInputName(name);
	return _fnRequestDataParameterSetOrUpdate (elem, nvo);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRequestDataFromServer
 * @private
 * @summary      Requests data from server
 * @description  Requests data from server
 * @param  {Object}  elem  Element reference
 */

let _fnRequestDataFromServer = function (elem) {
	
	return new Promise((resolve, reject) => {
		let $me = _fnGetMe(elem);
		let dataObj = _fnGetDataObj($me);
		let reqDataJSON = MBA.ComponentCommon.fnJSONFromMapKeysValues(dataObj.opts.requestDataParameters);
		$(dataObj.spinner).removeClass(dataObj.opts.cssClasses.hidden);
		resolve(reqDataJSON);
	})
	.then(reqDataJSON => {
		let $me = _fnGetMe(elem);
		let dataObj = _fnGetDataObj($me);
		return MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.requestDataUrlBase, reqDataJSON, dataObj.opts.urlSessionExpiredLink);
	});
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnUpdateRequestParametersFromFieldNames
 * @private
 * @summary      Using array of field names set in options set or update all request parameter name and values
 * @description  Using array of field names set in options set or update all request parameter name and values
 * @param  {Object}  elem  Element reference
 */

let _fnUpdateRequestParametersFromFieldNames = function (elem) {
	return new Promise((resolve, reject) => {
		let $me = _fnGetMe(elem);
		let dataObj = _fnGetDataObj($me);
		if (dataObj.opts.autoSetUpdateRequestDataParametersFromRequestDataFieldNames === true) {
			$.each(dataObj.opts.requestDataFieldNames, function (fldNameIdx, fieldName) {
				_fnRequestDataParameterSetOrUpdateFromFieldName(elem, fieldName);
			});
		}
		resolve(true);
	});
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetData
 * @private
 * @summary      Get initial or refresh data shown
 * @description  Get initial or refresh data shown
 * @param  {Object}  elem  Element reference
 */

let _fnGetData = function (elem, _fnHandleResponseData) {
	_fnUpdateRequestParametersFromFieldNames(elem)
		.then(rs => {
			_fnRequestDataFromServer(elem)
				.then(responseData => {
					return _fnHandleResponseData(elem, responseData);					
				})
			});
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetDataThenDoSomething
 * @private
 * @summary      Get initial or refresh data shown
 * @description  Get initial or refresh data shown
 * @param  {Object}  elem  Element reference
 */

let _fnGetDataThenDoSomething = function (elem, _fnHandleResponseData, _fnDoSomething) {
	_fnUpdateRequestParametersFromFieldNames(elem)
		.then(rs => {
			_fnRequestDataFromServer(elem)
				.then(responseData => {
					_fnHandleResponseData(elem, responseData);
					_fnDoSomething(elem, responseData);
				})
		});
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
	
/**
 * @function     _fnIsElemSupported
 * @private
 * @summary      Is the element we are enhancing supported by the plugin
 * @description  Is the element we are enhancing supported by the plugin
 * @param  {Object}  elem  Element reference
 */

let _fnIsElemSupported = function(elem) {
  return  $(elem).is('div'); 
};

/*#############################################################################################################################################################
  #                                                                   PUBLIC METHODS
  ##############################################################################################################################################################*/

return {
    PLUGIN_NAME: _PLUGIN_NAME
  , PLUGIN_COMMON: _PLUGIN_COMMON
  , JQ_DATA_NAME: _JQ_DATA_NAME
  , COMMON_CHART_CONFIG: _COMMON_CHART_CONFIG
  , fnGetMe: _fnGetMe
  , fnGetDataObj: _fnGetDataObj
  , fnSetDataObj: _fnSetDataObj
  , fnDestroy: _fnDestroy
  , fnRequestDataParameterSetOrUpdate: _fnRequestDataParameterSetOrUpdate
  , fnRequestDataParameterSetOrUpdateFromFieldName: _fnRequestDataParameterSetOrUpdateFromFieldName
  , fnRequestDataFromServer: _fnRequestDataFromServer
  , fnUpdateRequestParametersFromFieldNames: _fnUpdateRequestParametersFromFieldNames
  , fnGetData: _fnGetData
  , fnGetDataThenDoSomething: _fnGetDataThenDoSomething
  , fnIsElemSupported: _fnIsElemSupported
};

})(jQuery);