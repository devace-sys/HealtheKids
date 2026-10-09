;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.TabsCommon
 * @memberof     MBA
 * @summary      Static methods used by the plugin
 * @description  Static methods used by the plugin.  Designed to work with jQuery UI tabs style markup.  Does not provide same function.
 * @requires     jQuery
 */

MBA.TabsCommon = (function ($) {

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _PLUGIN_NAME       = 'MBA Tabs';
const _PLUGIN_NS         = 'mba-tabs'
const _JQ_DATA_NAME      = 'jq-'   + _PLUGIN_NS;
const _DATA_ATTR_BASE    = 'data-' + _PLUGIN_NS ;  

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _CSS_CLASSES = {
	container: 'mba-tabs-container'
  , links: 'mba-tabs-links'
  , tab: 'mba-tab'
  , tabActive: 'mba-tab-active'
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS = {
      cssClasses: _CSS_CLASSES
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
  return  $(elem).is('div'); 
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
	  
  let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);
  dataObj.opts = opts;

  /* Find ul element */

  let $tabLinksUL = $($me).children('ul');

  /* Find li items */
  
  let $tabLinksLI = $($tabLinksUL).children('li');
  
  /* Find links */
  
  let $tabLinksA = $($tabLinksUL).find('a');

  /* Find divs */
  
  let $tabs = $($me).children('div');
  	  
  /* Add CSS */
  
  $($me).addClass(opts.cssClasses.container);
  $($tabLinksUL).addClass(opts.cssClasses.links);
  $($tabs).addClass(opts.cssClasses.tab);
  
  /* Store references */
	  
  dataObj.tabLinksUL  = $tabLinksUL;
  dataObj.tabLinksLI  = $tabLinksLI;
  dataObj.tabLinksA   = $tabLinksA;
  dataObj.tabs        = $tabs;
  
  /* Save our data object.  This will be used for option calls */

  $($me).data(_JQ_DATA_NAME, dataObj );
  
  /* Wire up tabbing */
  
  $($tabLinksA).click(function (e) {
    e.preventDefault();
    let currentAttrValue = $(this).attr('href'); /* href contains #tabid which happens to also be a css selector for that particular tab */
	/* Unactive all */
	$($tabLinksLI).removeClass(opts.cssClasses.tabActive);
	$($tabs).removeClass(opts.cssClasses.tabActive);
	/* Make this li and tab the active one*/
	$(this).parent().addClass(opts.cssClasses.tabActive);
	$(currentAttrValue).addClass(opts.cssClasses.tabActive);
  });
  
  /* Find first tab */

  let $firstTab = $($tabLinksUL).find('li:first');

  if ($firstTab.length) {
    $firstTab.addClass(opts.cssClasses.tabActive);
	let firstTabHref = $firstTab.find('a').attr('href');
	$(firstTabHref).addClass(opts.cssClasses.tabActive);
  } 

};
	
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

return {
	PLUGIN_NAME: _PLUGIN_NAME
  , fnCreate:  _fnCreate
  , fnDestroy: _fnDestroy
};

})(jQuery);

 	
/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Tabs plugin
 * @description  Tabs plugin
 * @requires     jQuery
 */

;(function($){

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
 
 /* Tie into jQuery namespace */
	
$.fn.MBA_Tabs = function (methodOrOptions, optionsOrValue) { 
      
/* These are the supported methods and properties that can be accessed from outside after an instance is created */	
	
let _methods = {
/*    hideTab   : function (elem, value) { return MBA.TabsCommon.fnHideTab(elem, value); }      		
  , showTab   : function (elem, value) { return MBA.TabsCommon.fnShowTab(elem, value); } */
};
	  	  
let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

/* Method is create */
	  
if ( typeof methodOrOptions === 'object' || !methodOrOptions )
{
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
	let elem = this; /* this in this scope is a reference to one of elements in the set */
	return MBA.TabsCommon.fnCreate  (elem, methodOrOptions);
  });
} 
	  
/* Method is destroy */
	  
else if ( methodOrOptions == 'destroy' )
{			
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
    let elem = this; /* this in this scope is a reference to one of elements in the set */
    return MBA.TabsCommon.fnDestroy (elem);
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
  else if (numOf > 1) { throw new Error(MBA.TabsCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied to a set of elements at once.' );}
  /* No elements found */
  else                { throw new Error(MBA.TabsCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied since the element was not found.');}
} 

/* Cant find the method */
	  
else 
{
  throw new Error(MBA.TabsCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method' );
}        
	
}; /* MBA_Tabs */

})( jQuery );
