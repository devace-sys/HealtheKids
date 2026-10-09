;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.CheckBoxSelectionsJSONCommon
 * @memberof     MBA
 * @summary      Static methods used by the plugin
 * @description  Static methods used by the plugin
 * @requires     jQuery
 */

MBA.CheckBoxSelectionsJSONCommon = (function ($) {

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _PLUGIN_NAME         = 'MBA Check Box Selections JSON';
const _PLUGIN_NS           = 'mba-check-box-selections-json'
const _JQ_DATA_NAME        = 'jq-'   + _PLUGIN_NS;
const _DATA_ATTR_BASE      = 'data-' + _PLUGIN_NS;  
const _EVENT_NAME_CHANGE   = _PLUGIN_NS      + '-change';
const _DATA_ATTR_SEL_NAME  = _DATA_ATTR_BASE + '-name';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _CSS_CLASSES = {
	hiddenTextArea:     _PLUGIN_NS + ' ' + _PLUGIN_NS + '-hidden-text-area'
  , fieldSet:           _PLUGIN_NS + ' ' + _PLUGIN_NS + '-fieldset'
  , legend:             _PLUGIN_NS + ' ' + _PLUGIN_NS + '-legend'
  , selectionContainer: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-selection-container'
  , selectionLabel:     _PLUGIN_NS + ' ' + _PLUGIN_NS + '-selection-label'
  , selectionInput:     _PLUGIN_NS + ' ' + _PLUGIN_NS + '-selection-input'
  , hidden:             _PLUGIN_NS + '-hidden'
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS = {
	 legend: ''
   , showLegend:false
   , selections :[]
   , cssClasses: _CSS_CLASSES
   , additionalChangeEventForHiddenTa:''
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
 * @summary      Sets data object
 * @description  Sets data object
 * @param  {Object}  $me  Element reference
 */
 
let _fnSetDataObj = function ($me, dataObj)  { 
  $($me).data(_JQ_DATA_NAME,dataObj);
  return dataObj;
};
	
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSetCheckBoxValuesFromSelectionValuesObj
 * @private
 * @summary      Internal.  Sets check box values from selection values object
 * @description  Internal.  Sets check box values from selection values object
 * @param  {Object}  elem  Element reference
 */

let _fnSetCheckBoxValuesFromSelectionValuesObj = function (dataObj) {
	$.each(dataObj.opts.selections, function (selectionIdx, selection) {
		let _cbInp    = dataObj.selectionCheckBoxes[selection.name];
		let _cbState = dataObj.selectionValuesObj[selection.name];
		MBA.ComponentCommon.fnSetCheckBoxState(_cbInp, _cbState);
	});
	return dataObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSetSelectionValuesObjFromTa
 * @private
 * @summary      Internal.  Sets selections value object from text area value (JSON)
 * @description  Internal.  Sets selections value object from text area value (JSON)
 * @param  {Object}  elem  Element reference
 */

let _fnSetSelectionValuesObjFromTa = function (dataObj) {
	let _ta = $(dataObj.me).val();
	dataObj.selectionValuesObj = JSON.parse(_ta);
	return dataObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSetTaValueFromSelectionValuesObj
 * @private
 * @summary      Internal.  Sets text area value (JSON) from selections value object
 * @description  Internal.  Sets text area value (JSON) from selections value object
 * @param  {Object}  elem  Element reference
 */

let _fnSetTaValueFromSelectionValuesObj = function (dataObj) {
	$(dataObj.me).val(JSON.stringify(dataObj.selectionValuesObj));
	return dataObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnUpdateDataFromCbChange
 * @private
 * @summary      Internal.  Handler to update data when checkbox state changes.
 * @description  Internal.  Handler to update data when checkbox state changes.
 * @param  {Object}  elem  Element reference
 */

let _fnUpdateDataFromCbChange = function ($me, $cbx) {
  let dataObj = _fnGetDataObj($me);
  let _sVal  = MBA.ComponentCommon.fnGetCheckBoxState($cbx);
  let _sName = $($cbx).attr(_DATA_ATTR_SEL_NAME);
  dataObj.selectionValuesObj[_sName] = _sVal;
  dataObj = _fnSetTaValueFromSelectionValuesObj(dataObj);
  _fnSetDataObj($me, dataObj);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnUpdateDataFromTaChange
 * @private
 * @summary      Internal.  Handler to update data when checkbox state changes.
 * @description  Internal.  Handler to update data when checkbox state changes.
 * @param  {Object}  elem  Element reference
 */

let _fnUpdateDataFromTaChange = function ($me) {
  let dataObj = _fnGetDataObj($me);
  dataObj = _fnSetSelectionValuesObjFromTa(dataObj);
  dataObj = _fnSetCheckBoxValuesFromSelectionValuesObj(dataObj);
  _fnSetDataObj($me, dataObj);
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
 * @function     _fnGetComponentData
 * @private
 * @summary      Gets dataObj
 * @description  Gets dataObj
 * @param  {Object}  elem  Element reference
 */
	
let _fnGetComponentData = function (elem) {  
  let $me = _fnGetMe(elem);
  return _fnGetDataObj($me);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnIsElementSupported
 * @private
 * @summary      Can we build this plugin around element
 * @description  Can we build this plugin around element
 * @param  {Object}  elem  Element reference
*/

let _fnIsElemSupported = function (elem) {
  return  $(elem).is('textarea'); 
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
	
let _fnCreate = function (elem,optsIn) {	  
	  
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

  /* Merge default options and options passed in. */
  	  
  dataObj.opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);

  $($me).addClass(dataObj.opts.cssClasses.hiddenTextArea);

  dataObj.hasInitialValues    = false;
  dataObj.selectionValuesObj  = {};
  dataObj.selectionCheckBoxes = [];
  dataObj.initialTaValue      = $(dataObj.me).val();

  if (MBA.ComponentCommon.fnHasValue(dataObj.initialTaValue) === true) {
    dataObj.hasInitialValues = true;
	try {
	  dataObj = _fnSetSelectionValuesObjFromTa(dataObj);
	}
	catch {
	  dataObj.hasInitialValues   = false;
	  dataObj.selectionValuesObj = {};
	}
  }

  $me.wrap('<fieldset></fieldset>');
  let $container = $($me).parent()[0];
  $($container).addClass(dataObj.opts.cssClasses.fieldSet);

  let $selectionsLegend = $('<legend>' + dataObj.opts.legend + '</legend>');
  $($selectionsLegend).addClass(dataObj.opts.cssClasses.legend);
  if (dataObj.opts.showLegend === false) $($selectionsLegend).addClass(dataObj.opts.cssClasses.hidden);
  $($container).append($selectionsLegend);

  $.each(dataObj.opts.selections, function (selectionIdx, selection) {

    let selectionID = MBA.ComponentCommon.fnCreateNewUUID();

	let $selectionCont = $('<span></span>');
	$($selectionCont).addClass(dataObj.opts.cssClasses.selectionContainer);

	let $selectionLabel = $('<label>' + selection.label + '</legend>');
	$($selectionLabel).attr('for', selectionID);
	$($selectionLabel).addClass(dataObj.opts.cssClasses.selectionLabel);

	let $selectionCheckBox = $('<input type="checkbox"></input>');
    $($selectionCheckBox).attr ('id', selectionID);
	$($selectionCheckBox).attr (_DATA_ATTR_SEL_NAME, selection.name);
	$($selectionCheckBox).addClass(dataObj.opts.cssClasses.selectionInput);

    $($selectionCont).append($selectionLabel);
	$($selectionCont).append($selectionCheckBox);
    $($container).append($selectionCont);

	if (dataObj.hasInitialValues === false) {
       dataObj.selectionValuesObj[selection.name] = selection.value; /* Set default value */
	}
	/* Save reference to the input*/ 
	dataObj.selectionCheckBoxes[selection.name] = $selectionCheckBox;
  });

  /* Save reference to container and legend */

  dataObj.container        = $container;
  dataObj.selectionsLegend = $selectionsLegend;

  /* Init ta and checkboxes state */

  dataObj = _fnSetCheckBoxValuesFromSelectionValuesObj(dataObj);
  dataObj = _fnSetTaValueFromSelectionValuesObj(dataObj);

  /* Save our data object.  This will be used for option calls */

  dataObj = _fnSetDataObj($me, dataObj);
 
  /* Listen for standard events */

  $($container).on('change', 'textarea, input[type="checkbox"]', function (e) {
	  let $whatElem = $(e.target);
	  if ($($whatElem).is('input[type="checkbox"]')) {
	     _fnUpdateDataFromCbChange($me, $whatElem);
	  }
	  else if (($whatElem).is('textarea')) {
	    _fnUpdateDataFromTaChange($me);
	  }
  });

  /* Listen for custom event and if its fired, trigger change on the hidden text area */

  $($me).on(_EVENT_NAME_CHANGE,function(e) {$($me).trigger('change');});

  /* If an external event definition is passed, listen for this and trigger custom event if its fired */

  if (dataObj.opts.additionalChangeEventForHiddenTa != '') {
	  $($me).on(dataObj.opts.additionalChangeEventForHiddenTa, function (e) {
			$(e.target).trigger(_EVENT_NAME_CHANGE);
	  });
  }

};
	
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

return {
	PLUGIN_NAME: _PLUGIN_NAME
  , EVENT_NAME_CHANGE: _EVENT_NAME_CHANGE
  , fnCreate:  _fnCreate
  , fnDestroy: _fnDestroy
  , fnGetComponentData: _fnGetComponentData
};

})(jQuery);

/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Check Box Selections JSON plugin
 * @description  Maintains a JSON representation of user defined checkbox names and values
 * @requires     jQuery
 */

;(function($){

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
 
 /* Tie into jQuery namespace */
	
$.fn.MBA_Check_Box_Selections_JSON = function (methodOrOptions, optionsOrValue) { 
      
/* These are the supported methods and properties that can be accessed from outside after an instance is created */	
	
let _methods = {
	getComponentData: function (elem) { return MBA.CheckBoxSelectionsJSONCommon.fnGetComponentData(elem); }
};
  	  
let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

/* Method is create */
	  
if ( typeof methodOrOptions === 'object' || !methodOrOptions )
{
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
	let elem = this; /* this in this scope is a reference to one of elements in the set */
	  return MBA.CheckBoxSelectionsJSONCommon.fnCreate (elem, methodOrOptions);
  });
} 
	  
/* Method is destroy */
	  
else if ( methodOrOptions == 'destroy' )
{			
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
    let elem = this; /* this in this scope is a reference to one of elements in the set */
	  return MBA.CheckBoxSelectionsJSONCommon.fnDestroy (elem);
  });
} 
	  
/* Other methods (these cannot be chained) */
	  
else if ( _methods [methodOrOptions] ) 
{			      
  if (numOf == 1) {
    let elem = this[0]; /* There is only one element matched so we can proceed */
	return _methods[ methodOrOptions ]( elem, optionsOrValue );
  }
		
  /* More than one element matched.  We cannot apply */
  else if (numOf > 1) { throw new Error(MBA.CheckBoxSelectionsJSONCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied to a set of elements at once.' );}
  /* No elements found */
  else { throw new Error(MBA.CheckBoxSelectionsJSONCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied since the element was not found.');}
} 

/* Cant find the method */
	  
else 
{
  throw new Error(MBA.CheckBoxSelectionsJSONCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method' );
}        
	
}; /* MBA_Check_Box_Options_JSON */

})( jQuery );
