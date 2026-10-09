;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.DisclosureCommon
 * @memberof     MBA
 * @summary      Static methods used by the plugin
 * @description  Static methods used by the plugin
 * @requires     jQuery
 */

MBA.DisclosureCommon = (function ($) {

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _PLUGIN_NAME       = 'MBA Disclosure';
const _PLUGIN_NS         = 'mba-disclosure'
const _JQ_DATA_NAME      = 'jq-'   + _PLUGIN_NS;
const _DATA_ATTR_BASE    = 'data-' + _PLUGIN_NS ;  

const _DISPLAY_OPTION_OVERLAY = 'overlay';
const _DISPLAY_OPTION_INLINE  = 'inline';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _CSS_CLASSES = {
	details: _PLUGIN_NS
  , detailsInline: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-inline'
  , detailsOverlay: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-overlay'
  , summary: _PLUGIN_NS
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS = {
      cssClasses: _CSS_CLASSES
    , display:_DISPLAY_OPTION_OVERLAY
	, openOnHoverIn:true
	, closeOnHoverOut:true
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
 * @function     _fnOpen
 * @private
 * @summary      Clears value and puts control in indeterminate state
 * @description  Clears value and puts control in indeterminate state
 * @param  {Object}  elem  Element reference
 */
	
let _fnOpen = function (elem) { 	
  let $me = _fnGetMe(elem);
  $($me).prop('open', true).attr('open','true');
  return;  
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnClose
 * @private
 * @summary      Clears value and puts control in indeterminate state
 * @description  Clears value and puts control in indeterminate state
 * @param  {Object}  elem  Element reference
 */
	
let _fnClose = function (elem) { 	
  let $me = _fnGetMe(elem);
  $($me).prop('open', false).removeAttr('open');
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
  return  $(elem).is('details'); 
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
  
  /* Find summary element */
  let $summary = $($me).children('summary');
  
  /* Define the data object we will save later */
	  
  dataObj = {}; 
	  
  /* Store reference to elem */
	  
  dataObj.me  = $me;

  /* Merge default options and options passed in. */
	  
  let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);
  dataObj.opts = opts;

  $($me).addClass(opts.cssClasses.details);
  $($summary).addClass(opts.cssClasses.summary);
  
  if (opts.display === _DISPLAY_OPTION_OVERLAY) {
    $($me).addClass(opts.cssClasses.detailsOverlay);
  }
  else if (opts.display === _DISPLAY_OPTION_INLINE) {
    $($me).addClass(opts.cssClasses.detailsInline);
  }
  else {
   $($me).addClass(opts.cssClasses.detailsOverlay);
  }
  
  /* Save our data object.  This will be used for option calls */

  $($me).data(_JQ_DATA_NAME, dataObj );
  
  if (opts.openOnHoverIn === true) {
    $($me).on('mouseenter', function (e) {
	  _fnOpen(elem);
	});
  }
  
  if (opts.closeOnHoverOut === true) {
    $($me).on('mouseleave', function (e) {
	  _fnClose(elem);
	});
  }
  
};
	
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

return {
	PLUGIN_NAME: _PLUGIN_NAME
  , fnCreate:  _fnCreate
  , fnDestroy: _fnDestroy
  , fnOpen: _fnOpen
  , fnClose: _fnClose
};

})(jQuery);

/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Disclosure plugin
 * @description  Disclosure plugin
 * @requires     jQuery
 */

;(function($){

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
 
 /* Tie into jQuery namespace */
	
$.fn.MBA_Disclosure = function (methodOrOptions, optionsOrValue) { 
      
/* These are the supported methods and properties that can be accessed from outside after an instance is created */	
	
let _methods = {
    open   : function (elem)    { return MBA.DisclosureCommon.fnOpen   (elem); }      		
  , close   : function (elem)   { return MBA.DisclosureCommon.fnClose  (elem); } 
  /*, setContent : function (elem, value)   { return MBA.DisclosureCommon.fnSetContent  (elem, value); } */

};
	  	  
let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

/* Method is create */
	  
if ( typeof methodOrOptions === 'object' || !methodOrOptions )
{
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
	let elem = this; /* this in this scope is a reference to one of elements in the set */
	return MBA.DisclosureCommon.fnCreate  (elem, methodOrOptions);
  });
} 
	  
/* Method is destroy */
	  
else if ( methodOrOptions == 'destroy' )
{			
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
    let elem = this; /* this in this scope is a reference to one of elements in the set */
    return MBA.DisclosureCommon.fnDestroy (elem);
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
  else if (numOf > 1) { throw new Error(MBA.DisclosureCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied to a set of elements at once.' );}
  /* No elements found */
  else                { throw new Error(MBA.DisclosureCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied since the element was not found.');}
} 

/* Cant find the method */
	  
else 
{
  throw new Error(MBA.DisclosureCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method' );
}        
	
}; /* MBA_disclosure */

})( jQuery );
