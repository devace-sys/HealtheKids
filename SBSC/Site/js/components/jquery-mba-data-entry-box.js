;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.DataEntryBoxCommon
 * @memberof     MBA
 * @summary      Static methods used by the plugin
 * @description  Static methods used by the plugin
 * @requires     jQuery
 */

MBA.DataEntryBoxCommon = (function ($) {

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _PLUGIN_NAME               = 'MBA Data Entry Box';
const _PLUGIN_NS                 = 'mba-data-entry-box'
const _JQ_DATA_NAME              = 'jq-'   + _PLUGIN_NS;

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DATA_ATTR_BASE                  = 'data-' + _PLUGIN_NS ;                        /* data-mba-data-entry-box */ 
const _DATA_ATTR_TYPE                  = _DATA_ATTR_BASE + '-type';                    /* data-mba-data-entry-box-type */
const _DATA_ATTR_DISPLAY_LABEL         = _DATA_ATTR_BASE + '-display-label';
const _DATA_ATTR_HAS_VALUE             = _DATA_ATTR_BASE + '-has-value';               /* data-mba-data-entry-box-has-value */
const _DATA_ATTR_SHOW_CHAR_COUNT_METER = _DATA_ATTR_BASE + '-show-char-count-meter';   /* data-mba-data-entry-box-show-char-count-meter */
const _DATA_ATTR_LOW_LEN               = _DATA_ATTR_BASE + '-low-len';                 /* data-mba-data-entry-box-low-len */
const _DATA_ATTR_HIGH_LEN              = _DATA_ATTR_BASE + '-high-len';                /* data-mba-data-entry-box-high-len */
const _DATA_ATTR_FIRE_SPEDMON_INPUT    = _DATA_ATTR_BASE + '-fire-spedmon-input';      /* data-mba-data-entry-box-fire-spedmon-input */
	
const _CSS_VAR_SIZE_H = '--mba-data-entry-box-size-h';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _SUPPORTED_ELEMENTS                  = ['input','textarea','select'];
const _SUPPORTED_INPUT_TYPES               = ['text','password','search','number','email','url','tel','date','time'];
const _FIELD_TYPES_THAT_USE_MIN_MAX_LENGTH = ['text', 'password', 'search', 'number', 'email', 'url', 'tel', 'date', 'time','textarea'];
const _FIELD_TYPES_THAT_USE_MIN_MAX_VALUE  = ['number','date','time'];

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _CSS_CLASSES = {
	container:              _PLUGIN_NS + ' ' + _PLUGIN_NS + '-container'
  , hidden:                 _PLUGIN_NS + '-hidden'
  , fieldAndLabelContainer: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-field-and-label-container'
  , field:                  _PLUGIN_NS + ' ' + _PLUGIN_NS + '-field'
  , label:                  _PLUGIN_NS + ' ' + _PLUGIN_NS + '-label'
  , labelText:              _PLUGIN_NS + ' ' + _PLUGIN_NS + '-label-text'
  , labelAnnotations:       _PLUGIN_NS + ' ' + _PLUGIN_NS + '-label-annotations'
  , labelAnnotation:        _PLUGIN_NS + ' ' + _PLUGIN_NS + '-label-annotation'
  , labelAnnotationHidden:   _PLUGIN_NS + '-label-annotation-hidden'
  , labelAnnotationAsText:   _PLUGIN_NS + '-label-annotation-as-text'
  , labelAnnotationAsIcon:   _PLUGIN_NS + '-label-annotation-as-icon'
  , labelAnnotationRequired: _PLUGIN_NS + '-label-annotation-required'
  , labelAnnotationInvalid:  _PLUGIN_NS + '-label-annotation-invalid'
  
  , charCountMeter: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-char-count-meter'
  , faIconBase: 'fas'
  , faIconRequiredField: 'fa-star-of-life'
  , faIconInvalidField:  'fa-exclamation-triangle'
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS = { 
	  floatingLabel: true
	, initiallyHidden: false
	, altFieldID:''
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateNewUUID
 * @private
 * @summary      Generates a unique identifier
 * @description  Generates a unique identifier
 */

let _fnCreateNewUUID = function() {
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
 * @function     _fnFireDataInput
 * @private
 * @summary      Fires spedmoninput
 * @description  Fires spedmoninput.  For backwards compat
 * @param  {Object}  elem  Element reference
 */

let _fnFireDataInput = function ($field)
{ 
	let $dataItemObj = {};
	$dataItemObj.id    = $($field).attr('id');
	$dataItemObj.label = $($field).attr('placeholder');
	$dataItemObj.value = $($field).val();
	$dataItemObj.dataStatus = null;
	$($field).trigger({ type: "spedmoninput", dataitem: $dataItemObj });
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetMe
 * @private
 * @summary      Gets reference to original elemement
 * @description  Gets reference to original elemement
 * @param  {Object}  elem  Element reference
 */

let _fnGetMe = function (elem) { 
  return $(elem); 
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetDataObj
 * @private
 * @summary      Gets reference to data object
 * @description  Gets reference to the jQuery data object associated with this element
 * @param  {Object}  $field  Element reference
 */
 
let _fnGetDataObj = function ($field)  { 
  let dataObj = $($field).data(_JQ_DATA_NAME);
  if (!dataObj) throw new Error('An instance of ' + _PLUGIN_NAME +' is required');
  return dataObj;
}

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
 * @function     _fnEvaluateValLen
 * @private
 * @summary      Gets value
 * @description  Gets value
 * @param  {Object}  elem  Element reference
 */
	
let _fnEvaluateValLen = function ($field) {

  let evlObj = {};
  let fvl = 0;

  /* Note: There may be cases where we have selects with no options or other unexpected
   * conditions or states that normally would not come up.  
   * This try catch block is here to guard against that. */
  try {
    fvl = $($field).val().length;
  }
  catch {
    fvl = 0;
  }
  evlObj.length = fvl;
  evlObj.hasValue = false;
  
  if (fvl > 0) 
  { 
    $($field).attr(_DATA_ATTR_HAS_VALUE,'1');
    evlObj.hasValue = true;
  }
  else 
  {
    $($field).attr(_DATA_ATTR_HAS_VALUE,'0');
    evlObj.hasValue = false;
  }
  return evlObj;
};


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAutoGrow
 * @private
 * @summary      Gets value
 * @description  Gets value
 * @param  {Object}  elem  Element reference
 */

let _fnAutoGrow = function ($field) {	
  $($field).css('height','auto');
  let scrollHeight = $($field).get(0).scrollHeight;		
  $($field).css('height', scrollHeight + 'px');        
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnLabelAnnotationItemShow
 * @private
 * @summary      Renders notification item
 * @description  Renders notification item
 */

let _fnLabelAnnotationItemShow = function ($item) {
  $($item).removeClass(_CSS_CLASSES.labelAnnotationHidden);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnLabelAnnotationItemHide
 * @private
 * @summary      Renders notification item
 * @description  Renders notification item
 */

let _fnLabelAnnotationItemHide = function ($item) {

  $($item).addClass(_CSS_CLASSES.labelAnnotationHidden);
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnLabelAnnotationItemUpdateText
 * @private
 * @summary      Renders notification item
 * @description  Renders notification item
 */

let _fnLabelAnnotationItemUpdateText = function ($item, annotationText) {

  if ($($item).hasClass(_CSS_CLASSES.labelAnnotationAsIcon)) {

	  $($item).children().attr('title', annotationText);
  }
  else if ($($item).hasClass(_CSS_CLASSES.labelAnnotationAsText)) {
    $($item).children().text(annotationText);
  }
  else {

  }
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
			
/**
 * @function     _fnEvaluateEntry
 * @private
 * @summary      Gets value
 * @description  Gets value
 * @param  {Object}  elem  Element reference
 */
 
let _fnEvaluateEntry = function ($field, fieldType, eventType) {

  let evlObj = _fnEvaluateValLen($field);

  let dataObj = _fnGetDataObj($field);

 
  if (fieldType === 'textarea') 
  {  
	 _fnAutoGrow($field);
  }
  else {
  }

  /* Now check the following for all field types */

	if (dataObj.supportData.renderCharCountMeter === true) {
	  dataObj.charCountMeter.attr('value', evlObj.length);
	  dataObj.charCountMeter.attr('title', evlObj.length);
	}
	if (eventType === 'blur') {

		let fldNativeRef = _fnGetVanillaJSRefFromJQueryRef($field); //$($field).get(0);
		let validityState = fldNativeRef.validity;

		if (validityState.valid === true) {
			_fnLabelAnnotationItemHide(dataObj.invalidAnnotation);
			_fnLabelAnnotationItemUpdateText(dataObj.invalidAnnotation, '');
			fldNativeRef.setCustomValidity('');
		}
		else {
			_fnLabelAnnotationItemShow(dataObj.invalidAnnotation);
			_fnLabelAnnotationItemUpdateText(dataObj.invalidAnnotation, fldNativeRef.validationMessage);
		}

		/* Set alternate field value if alternate field is specified */

		if (dataObj.supportData.altFieldSpecified === true) {
			let _fv = $($field).val();
			$(dataObj.supportData.altFieldRef).val(_fv);
		}

		/* Fire spedmoninput event if specified */

		if (dataObj.supportData.fireSpedmonInput === true) {
	        _fnFireDataInput($field);
		}

		
	}

  return evlObj;
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
  let $field = _fnGetMe(elem);
  let value  = $($field).val();
  return value;
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
  let $field = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($field);
  $($field).val(value);
  _fnEvaluateEntry($field,dataObj.supportData.fieldType,'input');
  return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
			
/**
 * @function     _fnEvaluateCurrentEntry
 * @private
 * @summary      Evaluates current entry
 * @description  Evaluates curent entry
 * @param  {Object}  elem  Element reference
 * @param  {string}  eventType Can be input, focus, blur 
 */
	
let _fnEvaluateCurrentEntry = function (elem, eventType) { 
  let $field  = _fnGetMe(elem);
  let dataObj = _fnGetDataObj($field);  
  return _fnEvaluateEntry($field, dataObj.supportData.fieldType, eventType);  
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSetListAssignment
 * @private
 * @summary      Sets value of list attribute
 * @description  Sets value of list attribute to the id of the datalist element
 * @param  {Object}  elem  Element reference
 * @param  {string}  value 
 */

let _fnSetListAssignment = function (elem, value) {
	let $field = _fnGetMe(elem);
	let dataObj = _fnGetDataObj($field);
	$($field).attr('list',value);
};


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSetLabel
 * @private
 * @summary      Sets value of label and also changes placeholder
 * @description  Sets value of label and also changes placeholder
 * @param  {Object}  elem  Element reference
 * @param  {string}  value 
 */

let _fnSetLabel = function (elem, value) {
	let $me = _fnGetMe(elem);
	let dataObj = _fnGetDataObj($me);
	$($me).attr('placeholder', value);
	dataObj.supportData.fieldPlaceHolder = value;
	$(dataObj.labelText).text(value);
	_fnSetDataObj($me, dataObj);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSetTitle
 * @private
 * @summary      Sets value of title attribute
 * @description  Sets value of title attribute
 * @param  {Object}  elem  Element reference
 * @param  {string}  value 
 */

let _fnSetTitle = function (elem, value) {
	let $me = _fnGetMe(elem);
	let dataObj = _fnGetDataObj($me);
	$($me).attr('title', value);
	dataObj.supportData.fieldTitle = value;
	_fnSetDataObj($me, dataObj);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnDisable
 * @private
 * @summary      Disables field
 * @description  Disables field by adding disabled attribute
 * @param  {Object}  elem  Element reference
 * @param  {string}  value 
 */

let _fnDisable = function (elem) {
	let $me = _fnGetMe(elem);
	$($me).attr('disabled', 'disabled');
	$($me).prop('disabled', true);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnEnable
 * @private
 * @summary      Enable field
 * @description  Enables field by removing disabled attribute
 * @param  {Object}  elem  Element reference
 * @param  {string}  value 
 */

let _fnEnable = function (elem) {
	let $me = _fnGetMe(elem);
	$($me).removeAttr('disabled');
	$($me).prop('disabled', false);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnUnlock
 * @private
 * @summary      Unlock field
 * @description  Unlocks field by removing readonly attribute
 * @param  {Object}  elem  Element reference
 * @param  {string}  value 
 */

let _fnUnlock = function (elem) {
	let $me = _fnGetMe(elem);
	$($me).removeAttr('readonly');
	$($me).prop('readonly', false);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnLock
 * @private
 * @summary      Locks field
 * @description  Locks field by adding readonly attribute
 * @param  {Object}  elem  Element reference
 * @param  {string}  value 
 */

let _fnLock = function (elem) {
	let $me = _fnGetMe(elem);
	$($me).attr('readonly', 'readonly');
	$($me).prop('readonly', true);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnShow
 * @private
 * @summary      Unhides control
 * @description  Unhides control
 * @param  {Object}  elem  Element reference
 * @param  {string}  value 
 */

let _fnShow = function (elem) {
	let $field = _fnGetMe(elem);
	let dataObj = _fnGetDataObj($field);
	$(dataObj.container).removeClass(_CSS_CLASSES.hidden);		
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnHide
 * @private
 * @summary      Hides control
 * @description  Hides control
 * @param  {Object}  elem  Element reference
 * @param  {string}  value 
 */

let _fnHide = function (elem) {
	let $field = _fnGetMe(elem);
	let dataObj = _fnGetDataObj($field);
	$(dataObj.container).addClass(_CSS_CLASSES.hidden);		
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
  return _fnSetValue(elem,'');
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
  let $field = _fnGetMe(elem);	  
  $field.removeData(_JQ_DATA_NAME);
  return;
};


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderLabelAnnotationItemIcon
 * @private
 * @summary      Renders notification item
 * @description  Renders notification item
 */

let _fnRenderLabelAnnotationItemAsIcon = function (faIconClass, annotationClass, annotationText) {
  let $item    = $('<li></li>');
  let $content = $('<i></i>');
  $($item).addClass(_CSS_CLASSES.labelAnnotation);
  $($item).addClass(_CSS_CLASSES.labelAnnotationAsIcon);
  $($item).addClass(annotationClass);
  _fnLabelAnnotationItemHide($item);
  $($content).attr('title', annotationText);
  $($content).addClass(_CSS_CLASSES.labelAnnotation);
  $($content).addClass(_CSS_CLASSES.faIconBase);
  $($content).addClass(faIconClass);
  $($content).addClass(annotationClass);
  $($item).append($content);
  return $item;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnRenderLabelAnnotationItemAsText
 * @private
 * @summary      Renders notification item
 * @description  Renders notification item
 */

let _fnRenderLabelAnnotationItemAsText = function (annotationClass, annotationText) {
  let $item = $('<li></li>');
  let $content = $('<span></span>');
  $($item).addClass(_CSS_CLASSES.labelAnnotation);
  $($item).addClass(_CSS_CLASSES.labelAnnotationAsText);
  $($item).addClass(annotationClass);
  _fnLabelAnnotationItemHide($item);
  $($content).text(annotationText);
  $($content).addClass(_CSS_CLASSES.labelAnnotation);
  $($content).addClass(annotationClass);
  $($item).append($content);
  return $item;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetSupportData
 * @private
 * @summary      Gets support data for plugin code.
 * @description  Gets support data for plugin code.  
 * @param  {Object}  elem  Element reference
 */
 
let _fnGetAndSetSupportData = function (elem,opts) {

  let supportData = {};

  supportData.field          = _fnGetMe(elem);
  supportData.okToCreate     = true;
  supportData.instanceExists = false;
  
  /* Check for instance */
  
  let dataObj = $(supportData.field).data(_JQ_DATA_NAME);
  
  if (dataObj) {
    supportData.instanceExists = true; 
    supportData.okToCreate     = false;
	return supportData;
  }
    
  supportData.elemName     = $(supportData.field).prop('tagName').toLowerCase().trim();
  supportData.supported    = _SUPPORTED_ELEMENTS.includes(supportData.elemName);
  
  if (supportData.supported === false) {
    supportData.okToCreate = false;
	return supportData;
  }

	supportData.hasSizeH = false;
	supportData.sizeH = undefined;
  if (supportData.elemName === 'input') {
	supportData.fieldType = elem.attributes.type.value.toLowerCase().trim();        /* Get input type */
	supportData.supported = _SUPPORTED_INPUT_TYPES.includes(supportData.fieldType); /* See if input type is supported */
	if (supportData.supported === false) {
	  supportData.okToCreate = false;
	  return supportData;
	}
	supportData.sizeH = $(supportData.field).attr('size');
  }
  else if (supportData.elemName === 'textarea') {
	  supportData.fieldType = 'textarea';
	  supportData.sizeH = $(supportData.field).attr('cols');
  }
  else {
	
  }
  if (supportData.sizeH === undefined) {
	  supportData.hasSizeH = false;
  }
  else {
	  supportData.hasSizeH = true;
  }

 /* Get field name (if any) */

  /* Find out if field is required */
 
  supportData.fieldRequired = false;
  
  if ($(supportData.field).prop('required')) {  
    supportData.fieldRequired = true;  
  }
  
  /* Find out what min/max attributes are supported */
 
  supportData.hasMinMaxLen         = false;
  supportData.hasMinLen            = false;
  supportData.hasMaxLen            = false;
  supportData.hasLowLen            = false;
  supportData.hasHighLen           = false;
  supportData.minLen               = null;
  supportData.maxLen               = null;
  supportData.lowLen               = null;
  supportData.highLen              = null;
  supportData.showCharCountMeter   = false;
  supportData.renderCharCountMeter = false;
  
  supportData.hasMinMaxVal       = false;
  supportData.minVal             = null;
  supportData.maxVal             = null;

  /* Min/max characters? */
  
  if (_FIELD_TYPES_THAT_USE_MIN_MAX_LENGTH.includes(supportData.fieldType)) {
    supportData.minLen  = $(supportData.field).attr('minlength');
	supportData.maxLen  = $(supportData.field).attr('maxlength');
	supportData.lowLen  = $(supportData.field).attr(_DATA_ATTR_LOW_LEN);
	supportData.highLen = $(supportData.field).attr(_DATA_ATTR_HIGH_LEN);

	supportData.showCharCountMeter = _fnFlagValueToTrueFalse($(supportData.field).attr(_DATA_ATTR_SHOW_CHAR_COUNT_METER));
	if (supportData.minLen)  { supportData.hasMinMaxLen = true; supportData.hasMinLen = true; }
	if (supportData.maxLen)  { supportData.hasMinMaxLen = true; supportData.hasMaxLen = true; }
    if (supportData.lowLen)  { supportData.hasLowLen  = true; }
	if (supportData.highLen) { supportData.hasHighLen = true; }
  }

  if ((supportData.hasMaxLen === true) && (supportData.showCharCountMeter === true)) {
	supportData.renderCharCountMeter = true;
  }
  
  /* Min/max values */
  
  if (_FIELD_TYPES_THAT_USE_MIN_MAX_VALUE.includes(supportData.fieldType)) {
	supportData.minVal = $(supportData.field).attr('min');
	supportData.maxVal = $(supportData.field).attr('max');
	if (supportData.minVal) supportData.hasMinMaxVal = true;
    if (supportData.maxVal) supportData.hasMinMaxVal = true;
  }

  supportData.fireSpedmonInput = true;
  supportData.fireSpedmonInput = _fnFlagValueToTrueFalse($(supportData.field).attr(_DATA_ATTR_FIRE_SPEDMON_INPUT));

  /* Get ID if exists and if none exists create one */
  
  let fieldID = $(supportData.field).attr('id');
  
  if (!fieldID) {
    fieldID = _fnCreateNewUUID();
	$(supportData.field).attr('id',fieldID);
  }
  
  supportData.fieldID = fieldID;

  let fieldPlaceHolder = $(supportData.field).attr('placeholder');
  let fieldTitle       = $(supportData.field).attr('title');
  
  supportData.fieldPlaceHolder = fieldPlaceHolder;
  supportData.fieldTitle       = fieldTitle;
  
  if (opts.floatingLabel === true) {
    supportData.renderLabelAfterInput = true;
    supportData.labelType = 'floating';
  }
  else {
    supportData.renderLabelAfterInput = false;
    supportData.labelType = 'inline';
  }

  /* Alternative field support */
  supportData.altFieldSpecified = false;
  
  if (opts.altFieldID != '') {
   supportData.altFieldSpecified = true;
   supportData.altFieldSelector  = '#' + opts.altFieldID;
   supportData.altFieldRef       = $(supportData.altFieldSelector);
 }
  
  
  return supportData;
  
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
	
let _fnCreate = function (elem,optsIn) {	  
	  
  /* Merge default options and options passed in. */
	  
  let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);

  /* Get support data for element */
  
  let supportData = _fnGetAndSetSupportData (elem,opts);
  if (supportData.okToCreate === false) return;
  
  /* Define the data object we will save later */
	  
  let dataObj = {}; 
  dataObj.opts = opts;
  
  /* Create the container for everything */
  
  let $container = $('<span></span>');
  $($container).addClass(_CSS_CLASSES.container);
  $($container).attr(_DATA_ATTR_TYPE,supportData.fieldType);          /* Add field type attribute */
  $($container).attr(_DATA_ATTR_DISPLAY_LABEL,supportData.labelType); /* Add label type */
  
  /* Create the field and label container */
  
  let $fieldAndLabelContainer = $('<span></span>');
  $($fieldAndLabelContainer).addClass(_CSS_CLASSES.fieldAndLabelContainer);
  $($fieldAndLabelContainer).attr(_DATA_ATTR_TYPE,supportData.fieldType);          /* Add field type attribute */
  $($fieldAndLabelContainer).attr(_DATA_ATTR_DISPLAY_LABEL,supportData.labelType); /* Add label type */
  
  /* The original field */
  
  let $field = supportData.field;
  $($field).addClass(_CSS_CLASSES.field);
  $($field).attr(_DATA_ATTR_TYPE,supportData.fieldType);           /* Add field type attribute*/
  $($field).attr(_DATA_ATTR_DISPLAY_LABEL,supportData.labelType);  /* Add label type */
  if (supportData.hasSizeH === true) $($field).get(0).style.setProperty(_CSS_VAR_SIZE_H, supportData.sizeH);

  /* Create the label */
  
  let $label = $('<label></label>');
  $($label).addClass(_CSS_CLASSES.label);
  $($label).attr(_DATA_ATTR_TYPE,supportData.fieldType);          /* Add field type attribute to label */
  $($label).attr(_DATA_ATTR_DISPLAY_LABEL,supportData.labelType); /* Add type of label attribute */
  $($label).attr('for', supportData.fieldID);
  if (supportData.hasSizeH === true) $($label).get(0).style.setProperty(_CSS_VAR_SIZE_H, supportData.sizeH);

  /* For label text */

  let $labelText = $('<span></span>');
  $($labelText).addClass(_CSS_CLASSES.labelText);
  $($labelText).attr(_DATA_ATTR_TYPE, supportData.fieldType);          /* Add field type attribute to label */
  $($labelText).attr(_DATA_ATTR_DISPLAY_LABEL, supportData.labelType); /* Add type of label attribute */
  $($labelText).text(supportData.fieldPlaceHolder)
  
  /* For label annotation */

  let $labelAnnotations = $('<ul></ul>');
  $labelAnnotations.addClass(_CSS_CLASSES.labelAnnotations);
  $($labelAnnotations).attr(_DATA_ATTR_TYPE, supportData.fieldType);          /* Add field type attribute to label */
  $($labelAnnotations).attr(_DATA_ATTR_DISPLAY_LABEL, supportData.labelType); /* Add type of label attribute */

  /* Add required annotation */

  let $requiredAnnotation = _fnRenderLabelAnnotationItemAsIcon(_CSS_CLASSES.faIconRequiredField, _CSS_CLASSES.labelAnnotationRequired, 'This field is required');

  /* Add invalid annotation */

  let $invalidAnnotation = _fnRenderLabelAnnotationItemAsIcon(_CSS_CLASSES.faIconInvalidField, _CSS_CLASSES.labelAnnotationInvalid, 'Invalid value');

  if (supportData.fieldRequired === true)
	_fnLabelAnnotationItemShow($requiredAnnotation);

  $labelAnnotations.append($requiredAnnotation);
  $labelAnnotations.append($invalidAnnotation);
 
  $($label).append($labelText);
  $($label).append($labelAnnotations);

  let $charCountMeter = null;
  if (supportData.renderCharCountMeter === true)
  {
    $charCountMeter = $('<meter></meter>');
	$($charCountMeter).addClass(_CSS_CLASSES.charCountMeter);
	$($charCountMeter).attr(_DATA_ATTR_TYPE, supportData.fieldType);          /* Add field type attribute */
	$($charCountMeter).attr(_DATA_ATTR_DISPLAY_LABEL, supportData.labelType); /* Add label type */
    if (supportData.hasMinLen)  $($charCountMeter).attr('min',  supportData.minLen);
	if (supportData.hasMaxLen)  $($charCountMeter).attr('max',  supportData.maxLen);
	if (supportData.hasLowLen)  $($charCountMeter).attr('low',  supportData.lowLen);
	if (supportData.hasHighLen) $($charCountMeter).attr('high', supportData.highLen);
   }
  
  /* Put markup together */
  
  $($field).wrap($fieldAndLabelContainer);
  $fieldAndLabelContainer = $($field).parent();
  $($fieldAndLabelContainer).wrap($container);
  $container = $($fieldAndLabelContainer).parent();

  if (supportData.renderLabelAfterInput === true) {
    $($label).insertAfter($field);
  } 
  else { 
    $($label).insertBefore($field);
  }

  /* Charater count meter*/

  if (supportData.renderCharCountMeter) $($fieldAndLabelContainer).append($charCountMeter);

  /* Save references */
  
  dataObj.me                     = $field;
  dataObj.container              = $container;
  dataObj.fieldAndLabelContainer = $fieldAndLabelContainer;
  dataObj.field                  = $field;  
  dataObj.label                  = $label;
  dataObj.labelText              = $labelText;
  dataObj.labelAnnotations       = $labelAnnotations;
  dataObj.requiredAnnotation     = $requiredAnnotation;
  dataObj.invalidAnnotation      = $invalidAnnotation;
  dataObj.charCountMeter         = $charCountMeter;
  dataObj.supportData            = supportData;
  
  /* Wire up events */

  $($field).on('input',function(){
    _fnEvaluateEntry($field, supportData.fieldType, 'input');
  });
  
  $($field).on('focus', function () {
	 _fnEvaluateEntry($field,supportData.fieldType,'focus');
  });
  
  $($field).on('blur',function(){
	 _fnEvaluateEntry($field,supportData.fieldType,'blur');
  });
  
  $($container).on('click', function () { $($field).focus(); });

  /* Save our data object.  This will be used for option calls */

  $($field).data(_JQ_DATA_NAME, dataObj);

  /* Evaluate entries */

  _fnEvaluateEntry($field, supportData.fieldType, 'input');

 /* If the field is initially hidden call the hide method */

  if (dataObj.opts.initiallyHidden === true) {
     _fnHide(elem);
  }


};
	
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

return {
    PLUGIN_NAME : _PLUGIN_NAME
  , fnCreate:  _fnCreate
  , fnDestroy: _fnDestroy
  , fnGetValue: _fnGetValue
  , fnSetValue: _fnSetValue
  , fnClearValue: _fnClearValue
  , fnSetListAssignment: _fnSetListAssignment
  , fnShow: _fnShow
  , fnHide: _fnHide
  , fnSetLabel: _fnSetLabel
  , fnSetTitle: _fnSetTitle
  , fnDisable: _fnDisable
  , fnEnable: _fnEnable
  , fnLock: _fnLock
  , fnUnlock: _fnUnlock
  , fnEvaluateCurrentEntry: _fnEvaluateCurrentEntry
};

})(jQuery);

/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      DataEntryBox plugin
 * @description  DataEntryBox plugin
 * @requires     jQuery
 */

;(function($){

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
 
 /* Tie into jQuery namespace */
	
$.fn.MBA_DataEntryBox = function (methodOrOptions, optionsOrValue) { 
      
/* These are the supported methods and properties that can be accessed from outside after an instance is created */	
	
let _methods = {
    getValue: function (elem) { return MBA.DataEntryBoxCommon.fnGetValue   (elem); }      		
  , setValue: function (elem, value) { return MBA.DataEntryBoxCommon.fnSetValue   (elem, value); } 
  , clearValue: function (elem) { return MBA.DataEntryBoxCommon.fnClearValue(elem); }
  , setListAssignment: function (elem, value) { return MBA.DataEntryBoxCommon.fnSetListAssignment(elem, value); }
  , show: function (elem) { return MBA.DataEntryBoxCommon.fnShow(elem); }
  , hide: function (elem) { return MBA.DataEntryBoxCommon.fnHide(elem); }
  , setLabel: function (elem, value) { return MBA.DataEntryBoxCommon.fnSetLabel(elem, value); }
  , setTitle: function (elem, value) { return MBA.DataEntryBoxCommon.fnSetTitle(elem, value); }
  , enable: function (elem) { return MBA.DataEntryBoxCommon.fnEnable(elem); }
  , disable: function (elem) { return MBA.DataEntryBoxCommon.fnDisable(elem); }
  , lock: function (elem) { return MBA.DataEntryBoxCommon.fnLock(elem); }
  , unlock: function (elem) { return MBA.DataEntryBoxCommon.fnUnlock(elem); }
  , evaluateCurrentEntry: function (elem, value) { return MBA.DataEntryBoxCommon.fnEvaluateCurrentEntry(elem, value); }
};
	  	  
let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

/* Method is create */
	  
if ( typeof methodOrOptions === 'object' || !methodOrOptions )
{
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
	let elem = this; /* this in this scope is a reference to one of elements in the set */
	return MBA.DataEntryBoxCommon.fnCreate  (elem, methodOrOptions);
  });
} 
	  
/* Method is destroy */
	  
else if ( methodOrOptions == 'destroy' )
{			
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
    let elem = this; /* this in this scope is a reference to one of elements in the set */
    return MBA.DataEntryBoxCommon.fnDestroy (elem);
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
  else if (numOf > 1) { throw new Error(MBA.DataEntryBoxCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied to a set of elements at once.' );}
  /* No elements found */
  else                { throw new Error(MBA.DataEntryBoxCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied since the element was not found.');}
} 

/* Cant find the method */
	  
else 
{
  throw new Error(MBA.DataEntryBoxCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method' );
}        
	
}; /* plugin */

})( jQuery );
