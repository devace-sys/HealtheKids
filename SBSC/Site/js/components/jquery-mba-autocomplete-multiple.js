;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.AutoCompleteMultipleCommon
 * @memberof     MBA
 * @summary      Static methods used by the plugin
 * @description  Static methods used by the plugin
 * @requires     jQuery
 */

MBA.AutoCompleteMultipleCommon = (function ($) {

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _PLUGIN_NAME         = 'MBA AutoComplete Multiple';
const _PLUGIN_NS           = 'mba-autocomplete-multiple'
const _JQ_DATA_NAME        = 'jq-'   + _PLUGIN_NS;
const _DATA_ATTR_BASE      = 'data-' + _PLUGIN_NS;  
const _EVENT_NAME_CHANGE   = _PLUGIN_NS + '-change';


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _CSS_CLASSES = {	
    container:                         _PLUGIN_NS + ' ' + _PLUGIN_NS + '-container'
  , selectedValuesTextArea:            _PLUGIN_NS + ' ' + _PLUGIN_NS + '-selected-values-text-area'
  , sectionAutoComplete:               _PLUGIN_NS + ' ' + _PLUGIN_NS + '-section-auto-complete'
  , sectionSelectedValues:             _PLUGIN_NS + ' ' + _PLUGIN_NS + '-section-selected-values'
  , selectValueAutoCompleteInput:      _PLUGIN_NS + ' ' + _PLUGIN_NS + '-select-value-autocomplete-input'
  , selectValueAutoCompleteButListAll: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-select-value-autocomplete-but-list-all'
  , selectValueAutoCompleteIcoListAll: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-select-value-autocomplete-ico-list-all fas fa-chevron-down'
  , selectedValuesList:                _PLUGIN_NS + ' ' + _PLUGIN_NS + '-selected-values-list'
  , selectedValuesListItem:            _PLUGIN_NS + ' ' + _PLUGIN_NS + '-selected-values-list-item'
  , selectedValuesListItemLabel:       _PLUGIN_NS + ' ' + _PLUGIN_NS + '-selected-values-list-item-label'
  , selectedValuesListItemButRemove:   _PLUGIN_NS + ' ' + _PLUGIN_NS + '-selected-values-list-item-but-remove'
  , selectedValuesListItemIcoRemove:   _PLUGIN_NS + ' ' + _PLUGIN_NS + '-selected-values-list-item-ico-remove fas fa-times'
  , button: _PLUGIN_NS + '-but'
  , icon:   _PLUGIN_NS + '-ico'
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS = {
	viewSelURL: ''
  , sessionExpiredURL: ''
  , fnGetRequestNvps: function () { let _requestNvps = []; return _requestNvps; }
  , fnGetStaticRequestNvps: function () { let _requestNvps = []; return _requestNvps;}
  , fnOnOpen: function (event, ui) { return; }
  , fnOnSelect: function (event, ui) { return; }
  , fnOnClose: function (event, ui) { return; }
  , fnModifyResponseSelRecs: function (requestNvps, SelRecs) { return SelRecs;}
  , fnModifyRenderItem: function ($ul, item, $li) { return $li;}  
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
  return $(elem).is('textarea'); 
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnUpdateSelectionsMapFromTA = function ($me) {
	let dataObj = _fnGetDataObj($me);
	let selectedValuesJSON = $(dataObj.me).val();
	if (MBA.ComponentCommon.fnHasValue(selectedValuesJSON) === false) {
		selectedValuesJSON = '';
	}
	if (selectedValuesJSON == '') selectedValuesJSON = '[]';
	let selectedValuesArr = JSON.parse(selectedValuesJSON);	
	dataObj.selectedItems.clear();
	selectedValuesArr.forEach(function (selectedValue) {
	  _fnAddItemToSelectionsMap($me, selectedValue.id, selectedValue.label, false);
	});
	_fnSetDataObj($me, dataObj);
	return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnUpdateSelectionsTAFromMap = function ($me) {
	let dataObj = _fnGetDataObj($me);
	let selectedValues = [];
	dataObj.selectedItems.forEach(function (label, id) {
		let selectedValue = {};
		selectedValue.label = label;
		selectedValue.id    = id;
		selectedValues.push(selectedValue);
	});
	let selectedValuesJSON = JSON.stringify(selectedValues);
	$(dataObj.me).val(selectedValuesJSON);
	_fnSetDataObj($me, dataObj);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnAddItemToSelectionsMap = function ($me, itemID, itemLabel,updateSelectionsTA) {
	let dataObj = _fnGetDataObj($me);
	let itemAdded = false;
	if (!dataObj.selectedItems.has(itemID)) {
		dataObj.selectedItems.set(itemID, itemLabel);
		itemAdded = true;
	}
	_fnSetDataObj($me, dataObj);
	if (updateSelectionsTA === true) { _fnUpdateSelectionsTAFromMap($me); }
	return itemAdded;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnRemoveItemFromSelectionsMap = function ($me, itemID, updateSelectionsTA) {
	let dataObj = _fnGetDataObj($me);
	let itemRemoved = false;
	if (dataObj.selectedItems.has(itemID)) {
		dataObj.selectedItems.delete(itemID);
		itemRemoved = true;
	}
	_fnSetDataObj($me, dataObj);
	if (updateSelectionsTA === true) { _fnUpdateSelectionsTAFromMap($me); }
	return itemRemoved;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnAddRequestNvp = function ($me, nvpObj) {
	let dataObj = _fnGetDataObj($me);
	dataObj.requestNvps.set(nvpObj.name, nvpObj.value);
	_fnSetDataObj($me, dataObj);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnRemoveRequestNvp = function ($me, nvpObj) {
	let dataObj = _fnGetDataObj($me);
	if (dataObj.requestNvps.has(nvpObj.name)) {
		dataObj.requestNvps.delete(nvpObj.name);
	}
	_fnSetDataObj($me, dataObj);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnAddItemToSelectedItemsList = function ($me, itemID, itemLabel) {
	let dataObj = _fnGetDataObj($me);
	let $li = $('<li></li>');
	$($li).addClass(_CSS_CLASSES.selectedValuesListItem);
	let $label = $('<span>' + itemLabel + '</span>');
	$($label).addClass(_CSS_CLASSES.selectedValuesListItemLabel);
	let $butRemove = $('<button type="button"></button>');
	let $iconRemove = $('<i class="fas fa-times"></i>');
	
	$($iconRemove).addClass(_CSS_CLASSES.icon);
	$($iconRemove).addClass(_CSS_CLASSES.selectedValuesListItemIcoRemove);
	$($butRemove).append($iconRemove);
	$($butRemove).addClass(_CSS_CLASSES.button);
	$($butRemove).addClass(_CSS_CLASSES.selectedValuesListItemButRemove);
	$($li).append($butRemove);
	$($li).append($label);
	$($butRemove).on('click', function (e) {
		_fnRemoveItemFromSelectionsMap($me, itemID,true);
		$($li).remove();
	});
	$(dataObj.selectedItemsList).append($li);
	_fnSetDataObj($me, dataObj);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let _fnAddItemsToSelectedItemsListFromMap = function ($me) {
	let dataObj = _fnGetDataObj($me);	
	$(dataObj.selectedItemsList).children().remove();
	dataObj.selectedItems.forEach(function (label, id) {
		_fnAddItemToSelectedItemsList($me, id, label);
	});
	_fnSetDataObj($me, dataObj);
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

  /* Add classes to original element and hide it */

  $($me).addClass(_CSS_CLASSES.selectedValuesTextArea);
  $($me).hide();

  /* Create map for selected items */

  dataObj.selectedItems = new Map();

  /* Create a map for request name/values */

  dataObj.requestNvps = new Map();

  /* Create containing element for everything*/

  $me.wrap('<fieldset></fieldset>');
  let $container = $($me).parent()[0];
  $($container).addClass(_CSS_CLASSES.container);

  /* Create containing element for autocomplete and its various controls */

  let $acContainer = $('<section></section>');
  $($acContainer).addClass(_CSS_CLASSES.sectionAutoComplete);

  let $acInput = $('<input type="text"></input>');
  $($acInput).addClass(_CSS_CLASSES.selectValueAutoCompleteInput);

  let $dropDownBut = $('<button type="button"></button>');
  $($dropDownBut).addClass(_CSS_CLASSES.button);
  $($dropDownBut).addClass(_CSS_CLASSES.selectValueAutoCompleteButListAll);

  let $dropDownIcon = $('<i></i>');
  $($dropDownIcon).addClass(_CSS_CLASSES.icon);
  $($dropDownIcon).addClass(_CSS_CLASSES.selectValueAutoCompleteIcoListAll);

  let $loadingIcon  = $('<i class="fa fa-spinner fa-spin"></i>');
  $($loadingIcon).addClass(_CSS_CLASSES.icon);

  $dropDownBut.append($dropDownIcon);
  $($loadingIcon).hide();

  $($acContainer).append($acInput);
  $($acContainer).append($dropDownBut);
  $($acContainer).append($loadingIcon);

  let $selectedItemsContainer = $('<section></section>');
  $($selectedItemsContainer).addClass(_CSS_CLASSES.sectionSelectedValues);

  let $selectedItemsList = $('<ul></ul>');
  $($selectedItemsList).addClass(_CSS_CLASSES.selectedValuesList);

  $($selectedItemsContainer).append($selectedItemsList);
	
  $($container).append($acContainer);
  $($container).append($selectedItemsContainer);

  $($acInput).autocomplete({
		open: function (event, ui) {
			/* Hook for open */
			dataObj.opts.fnOnOpen(event, ui);
		}
		, select: function (event, ui) {
			/* Add item to selected if not already selected */
			if (_fnAddItemToSelectionsMap($me, ui.item.id, ui.item.label, true)) {
				_fnAddItemToSelectedItemsList($me, ui.item.id, ui.item.label);
			}
			/* Hook for selection */
			dataObj.opts.fnOnSelect(event, ui);
		}
		, close: function (event, ui) {
			$($loadingIcon).hide();
			$($acInput).val('');
			/* Hook for close */
			dataObj.opts.fnOnClose(event, ui);
		}
		, source: function (acReqCb, acRspCb) {

			$($loadingIcon).show();

			let dataObjRef = _fnGetDataObj($me);

			/* Get any updates or additions and update the internal NVP map*/

			let _requestNvpsToAddOrUpdate = dataObjRef.opts.fnGetRequestNvps();

			_requestNvpsToAddOrUpdate.forEach(function (_requestNvp) {
				_fnAddRequestNvp($me, _requestNvp);
			});

			/* Refresh ref */

			dataObjRef = _fnGetDataObj($me);

			/* Internal NVP map to array*/

			let _requestNvps = MBA.ComponentCommon.fnNameValuesArrFromMapKeysValues(dataObjRef.requestNvps);

			/* Add the search term from the autocomplete plugin to this arr (Note: only do this here) */

			_requestNvps.push(MBA.ComponentCommon.fnCreateNameValueObject('term', acReqCb.term));
			
			/* Create request data JSON string */

			let _reqJSON = MBA.ComponentCommon.fnJSONFromArrNameValues(_requestNvps);

			MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.viewSelURL, _reqJSON, dataObj.opts.sessionExpiredURL)
				.then(responseData => {

					/* Hook for modifying response */

					let SelRecs = dataObj.opts.fnModifyResponseSelRecs(_requestNvps, responseData.rawData.SelRecs);

					if (!SelRecs) {
						acRspCb([]);
						$($loadingIcon).hide();
						return;
					}
					acRspCb(SelRecs);
					$($loadingIcon).hide();
				})
				.catch(responseData => {
					acRspCb({});
					$($loadingIcon).hide();
				});
		}
	}).data("autocomplete")._renderItem = function ($ul, item) {

		/* Override how jQuery autocomplete plugin renders its selections */

		let $li = $('<li></li>');
		let $liContent = $('<a></a>');
		$($liContent).append(item.label);
		$li.append($liContent);
		$li.data('item.autocomplete', item);
		
		/* Hook to modify rendered selection item */

		let $fli = dataObj.opts.fnModifyRenderItem($ul, item, $li);
		return $fli.appendTo($ul);
	};

	$($dropDownBut).on('click', function (e) {
	  $($acInput).val('');
	  $($acInput).autocomplete('option', 'minLength', 0);
	  $($acInput).autocomplete('close');
	  $($acInput).autocomplete('search');
	  $($acInput).autocomplete('option', 'minLength', 1);		
	});

	/* Save reference to various parts of control */

	dataObj.container         = $container;
	dataObj.acInput           = $acInput;
	dataObj.selectedItemsList = $selectedItemsList;

    /* Save our data object.  This will be used for option calls */

	dataObj = _fnSetDataObj($me, dataObj);

	/* Load nvps*/

	let _requestNvps = dataObj.opts.fnGetStaticRequestNvps();
	_requestNvps.forEach(function (_requestNvp) {
		_fnAddRequestNvp($me, _requestNvp);
	});
	
	/* Load data */
	
	_fnUpdateSelectionsMapFromTA($me);	
	_fnAddItemsToSelectedItemsListFromMap($me);

	/* Listen for standard events */

	$($container).on('change', 'textarea', function (e) {		
		_fnUpdateSelectionsMapFromTA($me);
		_fnAddItemsToSelectedItemsListFromMap($me);
		$($acInput).autocomplete('close');
	});

	/* Listen for custom event and if its fired, trigger change on the hidden text area */

	$($me).on(_EVENT_NAME_CHANGE, function (e) { $($me).trigger('change'); });

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
  , fnAddRequestNvp: _fnAddRequestNvp
  , fnRemoveRequestNvp: _fnRemoveRequestNvp
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
	
$.fn.MBA_Autocomplete_Multiple = function (methodOrOptions, optionsOrValue) { 
      
/* These are the supported methods and properties that can be accessed from outside after an instance is created */	
	
	let _methods = {
 		  getComponentData: function (elem) { return MBA.AutoCompleteMultipleCommon.fnGetComponentData(elem); }
		, addRequestNvp: function (elem, nvpObj) { return MBA.AutoCompleteMultipleCommon.fnAddRequestNvp(elem, nvpObj); }
		, removeRequestNvp: function (elem, nvpObj) { return MBA.AutoCompleteMultipleCommon.fnRemoveRequestNvp(elem,nvpObj); }
	};
  	  
let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

/* Method is create */
	  
if ( typeof methodOrOptions === 'object' || !methodOrOptions )
{
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
	let elem = this; /* this in this scope is a reference to one of elements in the set */
	  return MBA.AutoCompleteMultipleCommon.fnCreate (elem, methodOrOptions);
  });
} 
	  
/* Method is destroy */
	  
else if ( methodOrOptions == 'destroy' )
{			
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
    let elem = this; /* this in this scope is a reference to one of elements in the set */
	  return MBA.AutoCompleteMultipleCommon.fnDestroy (elem);
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
  else if (numOf > 1) { throw new Error(MBA.AutoCompleteMultipleCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied to a set of elements at once.' );}
  /* No elements found */
  else { throw new Error(MBA.AutoCompleteMultipleCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied since the element was not found.');}
} 

/* Cant find the method */
	  
else 
{
	throw new Error(MBA.AutoCompleteMultipleCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method' );
}        
	
}; /* MBA_Autocomplete_Multiple */

})( jQuery );
