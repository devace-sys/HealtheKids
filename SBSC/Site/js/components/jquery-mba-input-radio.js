;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.InputRadioCommon
 * @memberof     MBA
 * @summary      Static methods used by the plugin
 * @description  Static methods used by the plugin
 * @requires     jQuery
 */

MBA.InputRadioCommon = (function ($) {

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _PLUGIN_NAME       = 'MBA Input Radio';
const _PLUGIN_NS         = 'mba-input-radio'
const _JQ_DATA_NAME      = 'jq-'   + _PLUGIN_NS;
const _DATA_ATTR_BASE    = 'data-' + _PLUGIN_NS ;  
const _EVENT_NAME_CHANGE = _PLUGIN_NS + '-change';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _CSS_CLASSES = {
	hiddenInput: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-hidden-input'
  , fieldset:    _PLUGIN_NS + ' ' + _PLUGIN_NS + '-fieldset'
  , legend:      _PLUGIN_NS + ' ' + _PLUGIN_NS + '-legend'
  , radioLabel:  _PLUGIN_NS + ' ' + _PLUGIN_NS + '-radio-label'
  , radioInput:  _PLUGIN_NS + ' ' + _PLUGIN_NS + '-radio-input'
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS = {
     legend : ''
   , selections : []
   , cssClasses: _CSS_CLASSES
   , additionalCssClasses: {
	    fieldset: ''
	   ,legend:''
    }
	, appendTo: ''
    , additionalChangeEventForHiddenInput:''
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
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
			
/**
 * @function     _fnGetValue
 * @private
 * @summary      Gets value
 * @description  Gets value
 * @param  {Object}  elem  Element reference
 */
	
let _fnGetValue = function (elem) { 
  return $(_fnGetMe(elem)).val();
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
			
/**
 * @function     _fnSetValue
 * @private
 * @summary      Sets value
 * @description  Sets value
 * @param  {Object}  elem  Element reference
 * @param  {string}  value 
 */
	
let _fnSetValue = function (elem, value) { 
    let $me = _fnGetMe(elem);
    $($me).val(value);
	let dataObj = _fnGetDataObj($me);
	$.each(dataObj.radioCtrls, function (ctrlIdx, radioCtrl) {
		$(radioCtrl.radioInput).prop('checked', false).removeAttr('checked');
	});
	$.each(dataObj.radioCtrls, function (ctrlIdx, radioCtrl) {
	  let radioVal = $(radioCtrl.radioInput).attr('value');
	  if (radioVal === value) {
	    $(radioCtrl.radioInput).prop('checked', true).attr('checked',true);
		return false;
	  }
  }); 
  return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnClearValue
 * @private
 * @summary      Clears value and puts control in indeterminate state
 * @description  Clears value and puts control in indeterminate state
 * @param  {Object}  elem  Element reference
 */
	
let _fnClearValue = function (elem) { 	
  let $me = _fnGetMe(elem);
  $($me).val('');
  let dataObj = _fnGetDataObj($me);
   $.each(dataObj.radioCtrls, function (ctrlIdx, radioCtrl) {
	  $(radioCtrl.radioInput).prop('checked', false).removeAttr('checked');
   });
  return;  
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
	
let _fnIsElemSupported = function(elem) {
  return  $(elem).is('input[type="hidden"]'); 
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
	  
  dataObj.me  = $me;

  /* Merge default options and options passed in. */
	  
  let opts     = $.extend({}, _DEFAULT_OPTIONS, optsIn);
  dataObj.opts         = opts;

  $($me).addClass(opts.cssClasses.hiddenInput);
  dataObj.initialValue =  $($me).val();
  dataObj.commonName = MBA.ComponentCommon.fnCreateNewUUID();

  let $fieldset = null;
  if (opts.appendTo === '') {
		$me.wrap('<fieldset></fieldset>');
		$fieldset = $($me).parent()[0];
  }
  else {
    $fieldset = $('<fieldset></fieldset>');
	$(opts.appendTo).append($fieldset);
  }

  $($fieldset).addClass(opts.cssClasses.fieldset);
  $($fieldset).addClass(opts.additionalCssClasses.fieldset);

  dataObj.fieldset = $fieldset;
  
  let $legend = $('<legend></legend>');
  $($legend).addClass(opts.cssClasses.legend);
  $($legend).addClass(opts.additionalCssClasses.legend);
  $($legend).html(opts.legend);
  $($fieldset).append($legend);
  dataObj.legend = $legend;
  
  dataObj.radioCtrls = [];
  
  $.each(opts.selections, function (selectionIdx, selectionIn) {
  
	let radioInputID = '' + MBA.ComponentCommon.fnCreateNewUUID();
	let selection  = $.extend({}, {name:'',value:'',cssClasses:{radioLabel:'',radioInput:''},additionalAttributes:[]}, selectionIn);

	let $radioLabel = $('<label></label>');
	$($radioLabel).attr('for',radioInputID);
	$($radioLabel).html(selection.name);
	$($radioLabel).addClass(opts.cssClasses.radioLabel);
	$($radioLabel).addClass(selection.cssClasses.radioLabel);
	
	let $radioInput = $('<input type="radio">');
	$($radioInput).attr('id',radioInputID);
	$($radioInput).attr('name',dataObj.commonName);
	$($radioInput).attr('value',selection.value);
    $($radioInput).addClass(opts.cssClasses.radioInput);
	$($radioInput).addClass(selection.cssClasses.radioInput);
	  $.each(selection.additionalAttributes, function (additionalAttrIdx, additionalAttr) {
		  $($radioInput).attr(additionalAttr.name, additionalAttr.value);
	});
	$($radioInput).prop('checked', false);
	if (dataObj.initialValue === selection.value) {
		$($radioInput).prop('checked',true).attr('checked', true);
	}
	$($fieldset).append($radioInput); /* Input needs to be rendered first so we can use adjacent sibling rules in CSS*/
    $($fieldset).append($radioLabel);
	
	let objRadioCtrls = {};
	
	objRadioCtrls.radioLabel = $radioLabel;
	objRadioCtrls.radioInput = $radioInput;
	
    dataObj.radioCtrls.push(objRadioCtrls);
  });
      
  /* Save our data object.  This will be used for option calls */

  $($me).data(_JQ_DATA_NAME, dataObj );
  
  /* Keep hidden input up to date with user interactions with radio buttons */

  $($fieldset).on('change', 'input[type="radio"]', function (e) {
      let $radioInput = $(e.target);
      let newValue = '' + $radioInput.attr('value');
      if (($radioInput).is(':checked')) {
	    $($me).val(newValue);
	  };	  
  });
  
  /* Keep radio up to date with hidden input actions */
  
  $($me).on(_EVENT_NAME_CHANGE, function (e) {
     let newValue = '' + $(e.target).val();
    _fnSetValue(elem,newValue);
  });
  
  $($me).on('change', function (e) {
		$(e.target).trigger(_EVENT_NAME_CHANGE);
  });

  if (opts.additionalChangeEventForHiddenInput != '') {
		$($me).on(opts.additionalChangeEventForHiddenInput, function (e) {
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
  , fnGetValue: _fnSetValue
  , fnSetValue: _fnGetValue
  , fnClearValue: _fnClearValue
};

})(jQuery);

/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Input radio plugin
 * @description  Input radio plugin
 * @requires     jQuery
 */

;(function($){

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
 
 /* Tie into jQuery namespace */
	
$.fn.MBA_input_radio = function (methodOrOptions, optionsOrValue) { 
      
/* These are the supported methods and properties that can be accessed from outside after an instance is created */	
	
let _methods = {
    getValue   : function (elem)          { return MBA.InputRadioCommon.fnGetValue   (elem); }      		
  , setValue   : function (elem, value)   { return MBA.InputRadioCommon.fnSetValue   (elem, value); } 
  , clearValue : function (elem)          { return MBA.InputRadioCommon.fnClearValue (elem); } 
};
	  	  
let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

/* Method is create */
	  
if ( typeof methodOrOptions === 'object' || !methodOrOptions )
{
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
	let elem = this; /* this in this scope is a reference to one of elements in the set */
	return MBA.InputRadioCommon.fnCreate  (elem, methodOrOptions);
  });
} 
	  
/* Method is destroy */
	  
else if ( methodOrOptions == 'destroy' )
{			
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
    let elem = this; /* this in this scope is a reference to one of elements in the set */
    return MBA.InputRadioCommon.fnDestroy (elem);
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
  else if (numOf > 1) { throw new Error(MBA.InputRadioCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied to a set of elements at once.' );}
  /* No elements found */
  else                { throw new Error(MBA.InputRadioCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied since the element was not found.');}
} 

/* Cant find the method */
	  
else 
{
  throw new Error(MBA.InputRadioCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method' );
}        
	
}; /* MBA_input_radio */

})( jQuery );
