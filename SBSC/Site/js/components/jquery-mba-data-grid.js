; var MBA = (MBA || {});


/*************************************************************************************************
 * IMPORTANT NOTE: MBA.DataGridCommon can be considered a subset of MBA.DataGridCommon
 * 
 * It started out life as a copy/paste of MBA.DataGridCommon and has been refactored to use
 * as many methods from MBA.DataGridCommon as possible.  There are some specific methods added.
 * 
 *************************************************************************************************/

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.DataGridCommon
 * @memberof     MBA
 * @summary      Static methods used by data grid
 * @description  Static methods used by data grid
 * @requires     jQuery, jQueryUI, Font Awesome, MBA.RestViewCommon
 */

MBA.DataGridCommon = (function ($) {

	'use strict';

	/*################################################################################################
	  #
	  #                                          Constants
	  #
	  ################################################################################################*/

	const CONST_DATA_NAME          = 'mba-rest-view';
	const CONST_DATA_NAME_ROW_DATA = 'mba-rest-view-row-data';


	const CONST_SAVE_MODE_INLINE                 = 'inline';
	const CONST_SAVE_MODE_INLINE_UNLOCKED_FIELDS = 'inlineunlockedfields';
	const CONST_SAVE_MODE_INWINDOW               = 'inwindow';
	const CONST_SAVE_MODE_CUSTOM                 = 'custom';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const SECTIONS                       = MBA.RestViewCommon.CONST_SECTIONS;
	const SUB_SECTIONS                   = MBA.RestViewCommon.CONST_SUB_SECTIONS;
	const ROW_TYPE                       = MBA.RestViewCommon.CONST_ROW_TYPE
	const CTRL_OP_CLASSES                = MBA.RestViewCommon.CONST_CTRL_OP_CLASSES;
	const POSITION_USER_DEFINED_CONTROLS = MBA.RestViewCommon.CONST_POSITION_USER_DEFINED_CONTROLS;
	const RETURN_CODES                   = MBA.RestViewCommon.CONST_RETURN_CODES;
	const CONST_BUILT_IN_DATA_TYPES      = MBA.RestViewCommon.BUILT_IN_DATA_TYPES;

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/* Data-* attribute names */

	const CONST_ATTR_NAME_FOR_REC_ID = 'data-mba-rest-view-rec-id';
	const CONST_ATTR_NAME_FOR_ACTIVE_FLAG = 'data-mba-rest-view-rec-active';
	const CONST_ATTR_NAME_FOR_CAN_EDIT_FLAG = 'data-mba-rest-view-rec-can-edit';
	const CONST_ATTR_NAME_FOR_CAN_DELETE_FLAG = 'data-mba-rest-view-rec-can-delete';
	const CONST_ATTR_NAME_FOR_CAN_UNDELETE_FLAG = 'data-mba-rest-view-rec-can-undelete';

	const CONST_ATTR_NAME_UI_ELEMENT_TYPE = 'data-mba-rest-view-ui-element-type';
	const CONST_ATTR_NAME_CTRL_DEF_NAME = 'data-mba-rest-view-ctrl-def-name';
	const CONST_ATTR_NAME_CTRL_DEF_TYPE = 'data-mba-rest-view-ctrl-def-type';
	const CONST_ATTR_NAME_CTRL_OP_CLASS = 'data-mba-rest-view-ctrl-op-class';
	const CONST_ATTR_NAME_FIELD_NAME = 'data-mba-rest-view-field-name';
	const CONST_ATTR_NAME_ROW_IDX = 'data-mba-rest-view-row-idx';
	const CONST_ATTR_NAME_COL_IDX = 'data-mba-rest-view-col-idx';
	const CONST_ATTR_NAME_SORT_USING = 'data-mba-rest-view-sort-using';
	const CONST_ATTR_NAME_SORT_DIR = 'data-mba-rest-view-sort-dir';
	const CONST_ATTR_NAME_SAVE_USING = 'data-mba-rest-view-save-using';
	const CONST_ATTR_NAME_ALT_VALUE = 'data-mba-rest-view-alt-value'
	const CONST_ATTR_NAME_FIELD_EDIT_STATE = 'data-mba-rest-view-field-edit-state';
	const CONST_ATTR_NAME_ROW_TYPE = 'data-mba-rest-view-row-type';
	const CONST_ATTR_NAME_ROW_COUNTER = 'data-mba-rest-view-row-counter';
	const CONST_ATTR_NAME_ROW_CONTROLS = 'data-mba-rest-view-row-controls';
	const CONST_ATTR_NAME_ROW_NOTIFICATIONS = 'data-mba-rest-view-row-notifications';
	const CONST_ATTR_NAME_JUMP_TO_PAGE = 'data-mba-rest-view-jump-to-page';
	const CONST_ATTR_NAME_CELL = 'data-mba-rest-view-cell';
	const CONST_ATTR_NAME_PLUGIN_MKUP_FOR_FIELD_NAME = 'data-mba-rest-view-plugin-mkup-for-field-name';
	const CONST_ATTR_NAME_TOOL_TIP = 'title'; /* TODO: This is temporarily the title attribute*/
	const CONST_ATTR_NAME_MAP_KEY = 'data-mba-data-grid-data-map-key';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/* Data-* attribute values */

	const CONST_ATTR_VALUE_BUILT_IN = 'builtin';
	const CONST_ATTR_VALUE_USER_PROVIDED = 'userprovided';
	const CONST_ATTR_VALUE_UI_ELEMENT_TYPE_CTRL = 'control';
	const CONST_ATTR_VALUE_UI_ELEMENT_TYPE_FIELD_VALUE = 'fieldvalue';
	const CONST_ATTR_VALUE_EDIT_STATE_LOCKED = 'locked';
	const CONST_ATTR_VALUE_EDIT_STATE_UNLOCKED = 'unlocked';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/* Event names */


	const CONST_EVENT_NAME_EDIT_CANCEL = 'restvieweditcancel';
	const CONST_EVENT_NAME_EDIT_PROCEED = 'restvieweditproceed';
	
	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/*#################################################################################################
	  #                                  Built In Control Types
	  #################################################################################################*/

	const CONST_BUILT_IN_CONTROL_TYPES = {

		/* Add new inline with unlocked fields */

		recaddnewinlineunlockedfields: {
			defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'recaddnewinlineunlockedfields'
			, cssClass: 'fa fa-plus'
			, handlerFn: function (uiActionObj) { return _fnAddNewInlineUnlockedFields(uiActionObj); }
			, initiallyHidden: false
			, toolTip: 'Click here to add a new row'
			, ctrlOpClass: CTRL_OP_CLASSES.ADD_NEW_START
		}

		/* Clone inline with unlocked fields */

		, reccloneinlineunlockedfields: {
			defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'reccloneinlineunlockedfields'
			, cssClass: 'fa fa-copy'
			, handlerFn: function (uiActionObj) { return _fnCloneInlineUnlockedFields(uiActionObj); }
			, initiallyHidden: false
			, toolTip: 'Click here to clone this row'
			, ctrlOpClass: CTRL_OP_CLASSES.CLONE_START
		}

		/* Delete inline with unlocked fields */

		, recdeleteinlineunlockedfields: {
			defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'recdeleteinlineunlockedfields'
			, cssClass: 'fa fa-trash-alt'
			, handlerFn: function (uiActionObj) { return _fnDeleteInlineUnlockedFields(uiActionObj); }
			, initiallyHidden: false
			, toolTip: 'Click here to remove this row'
			, ctrlOpClass: CTRL_OP_CLASSES.DELETE_START
		}

		/* Delete all rows with unlocked fields */

		, recdeleteallinlineunlockedfields: {
			defType: CONST_ATTR_VALUE_BUILT_IN
			, name: 'recdeleteallinlineunlockedfields'
			, cssClass: 'fa fa-trash-alt'
			, handlerFn: function (uiActionObj) { return _fnDeleteAllInlineUnlockedFields(uiActionObj); }
			, initiallyHidden: false
			, toolTip: 'Click here to remove all rows'
			, ctrlOpClass: CTRL_OP_CLASSES.DELETE_START
		}


	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/*#################################################################################################
	  #                                           CSS Classes
	  #################################################################################################*/

	const CSS_CLASS_VISIBLE_TD_TH = 'mba-rest-view-visible-tbl-td-or-th';  /* Used in specific checks */
	const CSS_CLASS_COL_TOP = 'mba-rest-view-col-top';
	const CSS_CLASSES = MBA.RestViewCommon.CONST_CSS_CLASSES;
	
	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/*################################################################################################
	  #                                 Plugin Option Defaults
	  #################################################################################################*/

	const CONST_DEFAULT_OPTIONS = {

		  fieldDefinitions: []
		, jsonInputHtml: '<textarea style="display:none;"></textarea>'
		, tblDataArr: [] // used to preload data into  the global map
		, fnCreateComplete: function () { }
		, additionalCellValueFieldDefinitions: []
		, additionalControlDefinitionsForHeadRows: null
		, additionalControlDefinitionsForBodyRows: null
		, sessionTimeOutUrl: ''
		, numOfJumpPages: 5
		, enableScrollView: false
		, positionUserDefinedControlsInHead: POSITION_USER_DEFINED_CONTROLS.BEFORE_BUILT_IN
		, positionUserDefinedControlsInBodyExisting: POSITION_USER_DEFINED_CONTROLS.BEFORE_BUILT_IN
		, enableSortControls: true
		, enableRowNumbers: true
		, enableRowControls: false
		, enableRowNotifications: false
		, enableRowControlMarkRow:false
		, enableRowControlRecAddNew: false
		, enableRowControlRecClone: false
		, enableRowControlRecEdit: false
		, enableRowControlRecDelete: false
		, enableRowControlRecUnDelete: false
		, autoShowHideDeleteUnDelete: false
		, enableReports: false
		, enableReportHtml: true
		, enableReportXls: true
		, enableReportPdf: false

		, defaultPageRowOrder: ''
		, pageSize: ''
		, requestViewOnLoad: true
		, fnBeforeDrawTableBodyRows: function (elem, returnData, $me, dataObj) { return returnData; }
		, fnCreateNewRowBefore: function (newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) { return newRow; }
		, fnCreateNewRowAfter: function (newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) { return newRow; }
		, fnNewRowBeforeAppendToBodyExisting: function (newRow, rowData, opts) { return newRow; }
		, fnAddNewSaveRowBeforeCustomValidation: function (saveData, uiActionObj) { return true; }  // if returns true, data will save. Otherwise, data will not be saved
		, fnEditSaveRowBeforeCustomValidation: function (saveData, uiActionObj) { return true; }	 // if returns true, data will save. Otherwise, data will not be saved
		, fnCreateNewColBefore: function (newCol, rowIdxCtr, colIdxCtr, opts, fieldDefinition) { return newCol; }
		, fnCreateNewColAfter: function (newCol, rowIdxCtr, colIdxCtr, opts, fieldDefinition) { return newCol; }
		, fnCreateNewCellBefore: function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData) { return newCell; }
		, fnCreateNewCellAfter: function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs) { return newCell; }
		, fnAddNewRowAndCellsAfter: function (newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) { return newRow; }
		, fnSaveDataAfter: function (dataAsMap, dataAsArr, dataAsJSON, okToWorkWithData) { return;}
	
		, enableRowControlDeleteAll: false
	
		, hasCopyForAll: false

		, fnModifyRowDataBeforeAddNew: function (uiActionObj, rowDataIn) { return rowDataIn; }
		, fnAddRowControlDefBefore: function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefIn, rowCtrlIdx, rowData) { return rowCtrlDefIn; }
		, fnOnRowMarked: function (uiActionObj, markedRows) { return uiActionObj; }
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/*################################################################################################
	  #
	  #                                         Utility
	  #
	  ################################################################################################*/

	let _createNewUUID = MBA.RestViewCommon.fnCreateNewUUID;
	let _fnFlagValueToTrueFalse = MBA.RestViewCommon.fnFlagValueToTrueFalse;
	let _fnBuildUrl = MBA.RestViewCommon.fnBuildUrl;
	let _fnCreateNameValueObj = MBA.RestViewCommon.fnCreateNameValueObject;
	let _fnGetSaveableFields = MBA.RestViewCommon.fnGetSavableFields;
	let _fnPutSaveableFieldsInMap = MBA.RestViewCommon.fnPutSaveableFieldsInMap;
	let _fnOpenWindow = MBA.RestViewCommon.fnOpenWindow;
	let _fnHasValue = MBA.RestViewCommon.fnHasValue;

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/*################################################################################################
	  #
	  #                                 Data Map and TA Ops 
	  #
	  #################################################################################################*/

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function    _dataMapToArray
	 * @private
	 * @summary     converts current data map to array
	 */

	function _dataMapToArray(me) {
		let $me = _fnGetMe(me);
		let dataObj = _fnGetDataObj($me);
		let dataMap = dataObj.dataMap;
		let RecObjs = [];

		dataMap.forEach(function (RecObj, _idx) {
			/* Note: This conversion to json and back to an object is to keep any form builder data intact */
			RecObjs.push(JSON.parse(JSON.stringify(RecObj)));
			
		});
		return RecObjs;
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	* @function    _dataMapToJSONStr
	* @private
	* @summary     converts current data map to json string
	*/

	function _dataMapToJSONStr(me) {
		let RecObjs = _dataMapToArray(me);
		return JSON.stringify(RecObjs);
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	* @function    _dataMapToTA
	* @private
	* @summary     converts current data map to json and puts value in hidden textarea
	*/

	function _dataMapToTA(me) {
		let $me      = _fnGetMe(me);
		let dataObj  = _fnGetDataObj($me);
		/* Get out if ta update is disabled */
		if (dataObj.disableTaUpdate == true) return;
		let RecsJSON = _dataMapToJSONStr(me);		
		dataObj.$jsonDataHiddenInput.val(RecsJSON).change(); // fire change event as .val() does not fire that event
		let okToWorkWithData = dataObj.okToWorkWithData;
		/* Call custom callback */
		dataObj.opts.fnSaveDataAfter(dataObj.dataMap, _dataMapToArray(me), RecsJSON, okToWorkWithData);
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	* @function    _syncUIWithDataMap
	* @private
	* @summary     puts global map values in hidden textarea and redraws columns
	*/

	function _syncUIWithDataMap(me) {
		_dataMapToTA(me);
		_fnDrawTableBodyRows(me);
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _addObjToDataMap
	 * @private
	 * @summary      adds an object to global data map
	 * @description  adds an object to global data map
	 * 
	 * @param		 updateUI whether or not to update the hidden textarea
	 */

	function _addObjToDataMap(me, obj, updateUI) {

		let $me = _fnGetMe(me);
		let dataObj = _fnGetDataObj($me);
		if (!dataObj) throw new Error('An instance of ' + CONST_DATA_NAME + ' is required');
		let key = _createNewUUID();
		if (dataObj.dataMap.has(key)) return null;
		dataObj.dataMap.set(key, obj);
		_fnSaveDataObj(me, dataObj);
		if (updateUI) _dataMapToTA(me);
		return key;
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _deleteObjFromDataMap
	 * @private
	 * @summary      deletes an object from global data map
	 * @description  deletes an object from global data map
	 * 
	 * @param		 updateUI whether or not to update the hidden textarea
	 */

	function _deleteObjFromDataMap(me, key, updateUI) {
		let $me = _fnGetMe(me);
		let dataObj = _fnGetDataObj($me);
		if (!dataObj) throw new Error('An instance of ' + CONST_DATA_NAME + ' is required');
		dataObj.dataMap.delete(key);
		_fnSaveDataObj(me, dataObj);
		if (updateUI) _dataMapToTA(me);
		return key;
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _updateObjInDataMap
	 * @private
	 * @summary      edits an object to global data map
	 * @description  edits an object to global data map
	 * 
	 * @param		 updateUI whether or not to update the hidden textarea
	 */

	function _updateObjInDataMap(me, obj, key, updateUI) {
		let $me = _fnGetMe(me);
		let dataObj = _fnGetDataObj($me);
		if (!dataObj) throw new Error('An instance of ' + CONST_DATA_NAME + ' is required');
		if (!dataObj.dataMap.has(key)) return null;
		dataObj.dataMap.set(key, obj);
		_fnSaveDataObj(me, dataObj);
		if (updateUI) _dataMapToTA(me);
		return key;
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _getObjFromDataMap
	 * @private
	 * @summary      gets an object from global data map
	 * @description  gets an object from global data map
	 *
	 */

	function _getObjFromDataMap(me, key) {
		let $me = _fnGetMe(me);
		let dataObj = _fnGetDataObj($me);
		if (!dataObj) throw new Error('An instance of ' + CONST_DATA_NAME + ' is required');
		if (!dataObj.dataMap.has(key)) return null;
		return dataObj.dataMap.get(key);
    }

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/


	/*################################################################################################
	  #
	  #                                     Additional Parameters
	  #
	  ################################################################################################*/

	let _fnAdditionalParameterDefinitionForViewSet     = MBA.RestViewCommon.fnAdditionalParameterDefinitionForViewSet;
	let _fnAdditionalParameterDefinitionForAddNewSet   = MBA.RestViewCommon.fnAdditionalParameterDefinitionForAddNewSet;
	let _fnAdditionalParameterDefinitionForCloneSet    = MBA.RestViewCommon.fnAdditionalParameterDefinitionForCloneSet;
	let _fnAdditionalParameterDefinitionForEditSet     = MBA.RestViewCommon.fnAdditionalParameterDefinitionForEditSet;
	let _fnAdditionalParameterDefinitionForDeleteSet   = MBA.RestViewCommon.fnAdditionalParameterDefinitionForDeleteSet;
	let _fnAdditionalParameterDefinitionForUnDeleteSet = MBA.RestViewCommon.fnAdditionalParameterDefinitionForUnDeleteSet;

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/*################################################################################################
	  #
	  #                               Find Field Def/Additional Field Def
	  #
	  ################################################################################################*/

	let _fnFindFieldDefinition                    = MBA.RestViewCommon.fnFindFieldDefinition;
	let _fnFindAdditionalCellValueFieldDefinition = MBA.RestViewCommon.fnFindAdditionalCellValueFieldDefinition;

	/*################################################################################################
	  #
	  #                       Saving/Loading State and Getting Instance Data
	  #
	  #################################################################################################*/

	/**
	 * @function     _fnLoadDataObj
	 * @private
	 * @summary      Loads saved data object that has instance data
	 * @description  Loads saved data object that has instance data
	 * @param  {Object}  $me
	 */

	let _fnLoadDataObj = function ($me) {
		return $($me).data(CONST_DATA_NAME);
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnSaveDataObj
	 * @private
	 * @summary      Save data object we are using to store data about instances of this component
	 * @description  Save data object we are using to store data about instances of this component
	 * @param  {Object}  $me
	 * @parm   {Object}  dataObj;
	 */

	let _fnSaveDataObj = function ($me, dataObj) {
		$($me).data(CONST_DATA_NAME, dataObj);
		return _fnLoadDataObj($me);
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

	let _fnGetDataObj = function ($me) {
		let dataObj = $($me).data(CONST_DATA_NAME);
		if (!dataObj) throw new Error('An instance of ' + CONST_DATA_NAME + ' is required');
		return dataObj;
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/*################################################################################################
	  #
	  #                         Event Identification and Delegation
	  #
	  #################################################################################################*/

	let _fnIdentifyUIActionAndCallHandler = MBA.RestViewCommon.fnIdentifyUIActionAndCallHandler;
		
	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/*################################################################################################
	  #
	  #                                         AJAX Routines
	  #
	  #################################################################################################*/


	let _fnAjaxCallAsmxWebMethod = MBA.RestViewCommon.fnAjaxCallAsmxWebMethod;

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
	
	/*################################################################################################
	  #
	  #                         Overlays, Status Messages, and Notifications
	  #
	  #################################################################################################*/
	
	let _fnUpdateStatusContent         = MBA.RestViewCommon.fnUpdateStatusContent;		
	let _fnUpdateMessageOverlayContent = MBA.RestViewCommon.fnUpdateMessageOverlayContent;
	let _fnShowMessageOverlay          = MBA.RestViewCommon.fnShowMessageOverlay;
	let _fnHideMessageOverlay          = MBA.RestViewCommon.fnHideMessageOverlay;
	let _fnClearMessageOverlay         = MBA.RestViewCommon.fnClearMessageOverlay;

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function  _fnSetDisableTaUpdateFlag
	 * @private
	 * @summary    Sets this helper flag
	 * @param  {Object}  elem            Element reference
	 * @param  {boolean} value           Flag value
	   *
	 */

	let _fnSetDisableTaUpdateFlag = function (elem, value) {
		let $me = _fnGetMe(elem);
		let dataObj = _fnGetDataObj($me);
		dataObj.disableTaUpdate = value;
		_fnSaveDataObj($me, dataObj);
		return;
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function  _fnGetDisableTaUpdateFlag
	 * @private
	 * @summary    Gets this helper flag
	 * @param  {Object}  elem            Element reference
	   *
	 */

	let _fnGetDisableTaUpdateFlag = function (elem) {
		let $me     = _fnGetMe(elem);
		let dataObj = _fnGetDataObj($me);
		return dataObj.disableTaUpdate;			
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function  _fnSetOkToWorkWithDataFlag
	 * @private
	 * @summary    Sets this helper flag
	 * @param  {Object}  elem            Element reference
	 * @param  {boolean} value           Flag value
 	 *
	 */

	let _fnSetOkToWorkWithDataFlag = function (elem, value) {
		let $me = _fnGetMe(elem);
		let dataObj = _fnGetDataObj($me);
		dataObj.okToWorkWithData = value;		
		_fnSaveDataObj($me, dataObj);		
		return;
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/*################################################################################################
	  #
	  #                                 Various Factory Routines
	  #
	  #################################################################################################*/


	let _fnCreateNewControlDefinition = MBA.RestViewCommon.fnCreateNewControlDefinition;	
	let _fnCreateNewFieldDefinition = MBA.RestViewCommon.fnCreateNewFieldDefinition;
	
	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/*################################################################################################
	  #
	  #                                 Rendering / Drawing Table Routines
	  #
	  #################################################################################################*/


	/**
	 * @function     _fnCreateNewCol
	 * @private
	 * @summary      Creates new table column
	 * @description  Creates new table column
	 * @param  {Object}  fieldDefinition  Field definition object
	 */

	let _fnCreateNewCol = function (rowIdxCtr, colIdxCtr, opts, fieldDefinition) {

		let $newCol = $('<th></th>');
		$newCol = opts.fnCreateNewColBefore($newCol, rowIdxCtr, colIdxCtr, opts, fieldDefinition);

		$newCol.attr(CONST_ATTR_NAME_ROW_IDX, rowIdxCtr);
		$newCol.attr(CONST_ATTR_NAME_COL_IDX, colIdxCtr);
		$newCol.attr(CONST_ATTR_NAME_FIELD_NAME, fieldDefinition.name);
		$newCol.attr(CONST_ATTR_NAME_SAVE_USING, fieldDefinition.saveUsing);
		$newCol.addClass(CSS_CLASSES.col);
		if (_fnHasValue(fieldDefinition.additionalCssClassesForCol) === true) $newCol.addClass(fieldDefinition.additionalCssClassesForCol);

		if (fieldDefinition.visible === false)
			$newCol.addClass(CSS_CLASSES.hidden);
		else
			$newCol.addClass(CSS_CLASSES.visibleTblTdOrTh);

		let $newColTop = $('<div></div>');
		$newColTop.addClass(CSS_CLASSES.colTop);
		$newColTop.addClass(CSS_CLASSES.dataTypes[fieldDefinition.dataType].cssClass);

		if (rowIdxCtr == 1) {
			let $newColLabel = $('<span></span>');
			$newColLabel.html(fieldDefinition.label);
			$newColLabel.addClass(CSS_CLASSES.colLabel);
			$newColLabel.addClass(CSS_CLASSES.dataTypes[fieldDefinition.dataType].cssClass);
			$newColLabel.attr(CONST_ATTR_NAME_TOOL_TIP, fieldDefinition.toolTip);

			/* Add label to col top */

			$($newColTop).append($newColLabel);
		}
		else if (rowIdxCtr == 2) {
			if (fieldDefinition.editable == true) {
				if (fieldDefinition.hasCustomCopyForAll == true) {
					let $newColField = fieldDefinition.copyForAllOptions.fnRenderField();
					$($newColTop).append($newColField);
				}
				else if (fieldDefinition.dataType != 'autocomplete') { // autocomplete NOT currently supported
					let $newColField = CONST_BUILT_IN_DATA_TYPES[fieldDefinition.dataType].fnRenderFieldIfEditable(fieldDefinition, false, '');
					if (_fnHasValue(fieldDefinition.additionalCssClassesForCellValue) === true) $($newColField).addClass(fieldDefinition.additionalCssClassesForCellValue);
					if (_fnHasValue(fieldDefinition.styleAttrValueForCellValue) === true) $($newColField).attr('style', fieldDefinition.styleAttrValueForCellValue);
					$($newColTop).append($newColField);
				}
			}
		}
		else if (rowIdxCtr == 3) {
			if (fieldDefinition.editable == true) {
				let $newColCopyIcon = $('<i class="fa fa-copy mt-1 mb-1" title="Copy for all rows"></i>');
				$newColCopyIcon.addClass(CONST_DATA_NAME);
				$newColCopyIcon.addClass(CSS_CLASSES.copyForAllIcon);
				$($newColTop).append($newColCopyIcon);
			}
		}

		let $newColCtrls = $('<div></div>')
		$newColCtrls.addClass(CSS_CLASSES.colCtrls);

		$newCol.append($newColTop);
		if (rowIdxCtr == 1) $newCol.append($newColCtrls);

		$newCol = opts.fnCreateNewColAfter($newCol, rowIdxCtr, colIdxCtr, opts, fieldDefinition);

		return $newCol;
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	let _fnForceAutoCompleteSearch = MBA.RestViewCommon.fnForceAutoCompleteSearch;
	let _fnCreateNewCellValue = MBA.RestViewCommon.fnCreateNewCellValue;
	let _fnCreateNewCell = MBA.RestViewCommon.fnCreateNewCell;
	let _fnCreateNewRow = MBA.RestViewCommon.fnCreateNewRow;

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnDrawTableBodyRows
	 * @private
	 * @summary      Draws rows in table body
	 * @description  Draws rows in table body
	 * @param  {object}  dataObj      Data object stored with $me
	 * @param  {object}  returnData   Data to render rows from
	 */

	let _fnDrawTableBodyRows = function (elem) {
		let $me         = _fnGetMe(elem);
		let dataObj     = _fnLoadDataObj($me);
		let rowDataObjs = dataObj.dataMap; // the map holding our row data

		/* Code injection hook */

		rowDataObjs = dataObj.opts.fnBeforeDrawTableBodyRows(elem, rowDataObjs, $me, dataObj);

		/* Remove previous rows */

		$(dataObj.tbody).html('');

		if (!rowDataObjs || rowDataObjs.size == 0) {
			_fnUpdateStatusContent(elem, 'No records found');
			_fnUpdateMessageOverlayContent(elem, 'No records found');
			_fnHideMessageOverlay(elem, 1500);
			_fnClearMessageOverlay(elem, '');
			return;
		}

		let rowNumCtr = dataObj.currentPageRecNumStart;
		let rowIdxCtr = 1;
		let rowCtrls = [];

		/* User provided controls (add before) */

		if (dataObj.opts.positionUserDefinedControlsInBodyExisting === POSITION_USER_DEFINED_CONTROLS.BEFORE_BUILT_IN) {
			dataObj.opts.additionalControlDefinitionsForBodyRows.forEach(function (value, key) {
				rowCtrls.push(value);
			});
		}

		/* Clone controls */

		if (dataObj.opts.enableRowControlRecClone === true) {

			if (dataObj.opts.saveModeClone === CONST_SAVE_MODE_INLINE) {
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.reccloneinlinestart);
			}
			else if (dataObj.opts.saveModeClone === CONST_SAVE_MODE_CUSTOM) {
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recclonecustom);
			}
		}

		/* Edit controls */

		if (dataObj.opts.enableRowControlRecEdit === true) {

			if (dataObj.opts.saveModeEdit === CONST_SAVE_MODE_INLINE) {
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.receditinlinestart);
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.receditinlineproceed);
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.receditinlinecancel);
			}
			else if (dataObj.opts.saveModeEdit === CONST_SAVE_MODE_INWINDOW) {
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.receditinwindow);
			}
			else if (dataObj.opts.saveModeEdit === CONST_SAVE_MODE_CUSTOM) {
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.receditcustom);
			}
		}

		/* Delete controls */

		if (dataObj.opts.enableRowControlRecDelete === true) {

			if (dataObj.opts.saveModeDelete === CONST_SAVE_MODE_INLINE) {
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recdeleteinlinestart);
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recdeleteinlineproceed);
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recdeleteinlinecancel);
			}
			else if (dataObj.opts.saveModeDelete === CONST_SAVE_MODE_CUSTOM) {
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recdeletecustom);
			}
		}

		/* UnDelete controls */

		if (dataObj.opts.enableRowControlRecUnDelete === true) {
			if (dataObj.opts.saveModeUnDelete === CONST_SAVE_MODE_INLINE) {
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recundeleteinlinestart);
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recundeleteinlineproceed);
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recundeleteinlinecancel);
			}
			else if (dataObj.opts.saveModeUnDelete === CONST_SAVE_MODE_CUSTOM) {
				rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recundeletecustom);
			}
		}

		/* User provided controls (add after) */

		if (dataObj.opts.positionUserDefinedControlsInBodyExisting === POSITION_USER_DEFINED_CONTROLS.AFTER_BUILT_IN) {
			dataObj.opts.additionalControlDefinitionsForBodyRows.forEach(function (value, key) {
				rowCtrls.push(value);
			});
		}


		/* Define selectors*/

		let delUnDelCtrlSelectorStart = 'button[' + CONST_ATTR_NAME_CTRL_OP_CLASS + '=';
		let delCtrlStartSelector = delUnDelCtrlSelectorStart + '' + CTRL_OP_CLASSES.DELETE_START + ']';
		let unDelCtrlStartSelector = delUnDelCtrlSelectorStart + '' + CTRL_OP_CLASSES.UNDELETE_START + ']';

		/* For each object returned */

		rowDataObjs.forEach(function (rowData, key) {

			/* Generate new row and any row control cells */

			let $newRow = _fnCreateNewRow(SECTIONS.TABLE, SUB_SECTIONS.TBODY_EXISTING, ROW_TYPE.EXISTING_ROW, dataObj.opts, '<td></td>', rowNumCtr, rowCtrls, rowData, key);

			/* Render the field specific cells and append to new row */

			let colIdxCtr = 1;
			$.each(dataObj.opts.fieldDefinitions, function (fldDefIdx, fieldDefinition) {
				let fldName = fieldDefinition.name;
				let fieldValue = rowData[fldName];

				/* If this is the recID field then we put the rec id in an attribute and we skip rendering this cell */

				if (fieldDefinition.isRecID === true) {
					$($newRow).attr(CONST_ATTR_NAME_FOR_REC_ID, fieldValue);
					return; /* This is the same as a "continue" */
				}

				if (fieldDefinition.isActiveFlag === true) {
					$($newRow).attr(CONST_ATTR_NAME_FOR_ACTIVE_FLAG, fieldValue);
					return; /* This is the same as a "continue" */
				}

				if (fieldDefinition.isCanEditFlag === true) {
					$($newRow).attr(CONST_ATTR_NAME_FOR_CAN_EDIT_FLAG, fieldValue);
					return; /* This is the same as a "continue" */
				}

				if (fieldDefinition.isCanDeleteFlag === true) {
					$($newRow).attr(CONST_ATTR_NAME_FOR_CAN_DELETE_FLAG, fieldValue);
					return; /* This is the same as a "continue" */
				}

				if (fieldDefinition.isCanUnDeleteFlag === true) {
					$($newRow).attr(CONST_ATTR_NAME_FOR_CAN_UNDELETE_FLAG, fieldValue);
					return; /* This is the same as a "continue" */
				}

				/* Otherwise create the cell */

				let $newCell = _fnCreateNewCell(SUB_SECTIONS.TBODY_EXISTING, ROW_TYPE.EXISTING_ROW, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, $newRow, rowData);
				$($newRow).append($newCell);
				
				colIdxCtr++;
			});

			/* Auto show hide delete/undelete options */

			if (dataObj.opts.autoShowHideDeleteUnDelete === true) {
				let isRecActive = _fnFlagValueToTrueFalse($($newRow).attr(CONST_ATTR_NAME_FOR_ACTIVE_FLAG));
				if (isRecActive === true) {
					$($newRow).find(unDelCtrlStartSelector).remove();
				}
				else if (isRecActive === false) {
					$($newRow).find(delCtrlStartSelector).remove();
				}
				else {

				}
			}

			/* Code injection hook */

			$newRow = dataObj.opts.fnNewRowBeforeAppendToBodyExisting($newRow, rowData, dataObj.opts);

			/* Add the row to the body */
			$(dataObj.tbody).append($newRow);
			rowNumCtr++;
			rowIdxCtr++;
		});

		/* Return to the top of the table */

		dataObj.tableContainer.scrollTop(0);

		/* Update status */

		let newStatusContent = 'Displaying ' + dataObj.currentPageRecNumStart + ' to ' + dataObj.currentPageRecNumEnd + ' of ' + dataObj.recordsTotal + ' records available.'
		_fnUpdateStatusContent(elem, newStatusContent);
		_fnHideMessageOverlay(elem);
		_fnClearMessageOverlay(elem);
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRenderTableRows
	 * @private
	 * @summary      Render table rows from the JSON input value
	 * @description  Render table rows from the JSON input value
	 * @param  {Object}  elem        Element reference
	 * @param  {Object}  pageNumber  Page number to retrieve
	 */

	let _fnRenderTableRows = function (elem) {
		_fnShowMessageOverlay(elem);
		_fnUpdateMessageOverlayContent(elem, 'Loading data');
		_fnDrawTableBodyRows(elem);
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
	
	/*################################################################################################
	  #
	  #                                  Common Inline Op Routines
	  #
	  #################################################################################################*/
	
	let _fnCtrlOpInlineUnlockEditableFields                = MBA.RestViewCommon.fnCtrlOpInlineUnlockEditableFields;	
	let _fnCtrlOpInlineGetSaveableFields                   = MBA.RestViewCommon.fnCtrlOpInlineGetSaveableFields;
	let _fnCtrlOpInlineGetNameValuePairsFromSaveableFields = MBA.RestViewCommon.fnCtrlOpInlineGetNameValuePairsFromSaveableFields;
	let _fnCtrlOpInlineRequestDataObjFromNvpObjs           = MBA.RestViewCommon.fnCtrlOpInlineRequestDataObjFromNvpObjs;
			
	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/*#################################################################################################
	  #
	  #                                 Row Add/Remove/Clone Routines
	  #
	  #################################################################################################*/

	
	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnCreateNewInlineUnlockedRowAndCells
	 * @private
	 * @summary      Creates new row and cells for add new and clone
	 * @description  Creates new row and cells for add new and clone
	 */
	
	let _fnCreateNewInlineUnlockedRowAndCells = function (uiActionObj, whatRowType, rowData, updateUI) {
		
		/* add row controls */

		let rowCtrls = [];

		if (uiActionObj.dataObj.opts.enableRowControlRecDelete === true) {
		  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recdeleteinlineunlockedfields);
		}

		if (uiActionObj.dataObj.opts.enableRowControlRecClone === true) {
		  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.reccloneinlineunlockedfields);
		}

		uiActionObj.dataObj.opts.additionalControlDefinitionsForBodyRows.forEach(function (value, key) {
			rowCtrls.push(value);
		});

		
		let $newRow = _fnCreateNewRow(SECTIONS.TABLE, SUB_SECTIONS.TBODY_NEW, whatRowType, uiActionObj.dataObj.opts, '<td></td>', '', rowCtrls, rowData, null);
		let colIdxCtr = 1;

		$.each(uiActionObj.dataObj.opts.fieldDefinitions, function (fldDefIdx, fieldDefinition) {

			/* If this is the recID field then we skip rendering this cell */

			if (fieldDefinition.isRecID === true) {

				return; /* This is the same as a "continue" */
			}

			/* Same with active flag */

			if (fieldDefinition.isActiveFlag === true) return;

			/* Otherwise create the cell */

			let fldName = fieldDefinition.name;
			let fieldValue = rowData[fldName];
			if (!fieldValue) fieldValue = '';
			let $newCell = _fnCreateNewCell(SUB_SECTIONS.TBODY_NEW, whatRowType, uiActionObj.dataObj, '', colIdxCtr, fieldDefinition, fieldValue, $newRow, rowData);			
			$($newRow).append($newCell);
			colIdxCtr++;
		});

		if (whatRowType == ROW_TYPE.PRELOADED_ROW) {

			/* If this is a preloaded row then we append it to the bottom of the table */

			$(uiActionObj.dataObj.tbodyNew).append($newRow);

			/* and setup some references */

			uiActionObj.newRow  = $newRow;
			uiActionObj.whatRow = $newRow;

		}
		else if (whatRowType == ROW_TYPE.NEW_ROW) {

			/* If this is a new row then we prepend it to the top of the table */

			$(uiActionObj.dataObj.tbodyNew).prepend($newRow);

			/* and setup some references */

			uiActionObj.newRow = $newRow;
			uiActionObj.whatRow = $newRow;
		}

		else if (whatRowType == ROW_TYPE.CLONED_ROW) {

			/* If its a cloned row then we append it right below the row being cloned */

			$(uiActionObj.whatRow).after($newRow);

			/* and setup some references */

			uiActionObj.clonedRow = $newRow;
			uiActionObj.whatRow = $newRow;
			uiActionObj.newRow = $newRow;
		}

		_fnCtrlOpInlineUnlockEditableFields(uiActionObj, uiActionObj.newRow, false);

		/* save new row in map */

		let $fields = _fnCtrlOpInlineGetSaveableFields(uiActionObj);
		let nvpObjs = _fnCtrlOpInlineGetNameValuePairsFromSaveableFields($fields);
		
		uiActionObj.dataObj.opts.additionalParameterDefinitionsForAddNew.forEach(function (value, key) {
			nvpObjs.push(_fnCreateNameValueObj(key, value));
		});

		/* Custom validation */

		if (!uiActionObj.dataObj.opts.fnAddNewSaveRowBeforeCustomValidation(nvpObjs, uiActionObj)) {
			return uiActionObj;
		}

		/* Add object to map */

		let _me = uiActionObj.dataObj.me;
		let _newKey = _addObjToDataMap(_me, _fnCtrlOpInlineRequestDataObjFromNvpObjs(nvpObjs), updateUI);
		$(uiActionObj.whatRow).attr(CONST_ATTR_NAME_MAP_KEY, _newKey);
		
		/* update map every time there is a change */

		$(uiActionObj.whatRow).on('change', 'td', function (e) {

			let $fieldsUpdated = _fnCtrlOpInlineGetSaveableFields(uiActionObj);
			let nvpObjsUpdated = _fnCtrlOpInlineGetNameValuePairsFromSaveableFields($fieldsUpdated);

			/* edit object in data map */

			_updateObjInDataMap(_me, _fnCtrlOpInlineRequestDataObjFromNvpObjs(nvpObjsUpdated), $(uiActionObj.whatRow).attr(CONST_ATTR_NAME_MAP_KEY), true);

		});

		$newRow = uiActionObj.dataObj.opts.fnAddNewRowAndCellsAfter($newRow, SECTIONS.TABLE, SUB_SECTIONS.TBODY_NEW, whatRowType, uiActionObj.dataObj.opts, '', '', rowCtrls, rowData);

		return uiActionObj;
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnAddNewInlineUnlockedFields
	 * @private
	 * @summary      Saves new
	 * @description  Saves new
	 */

	let _fnAddNewInlineUnlockedFields = function (uiActionObj) {
		let _rowData = {};
		return _fnCreateNewInlineUnlockedRowAndCells(uiActionObj, ROW_TYPE.NEW_ROW, _rowData, true);
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnDeleteAllInlineUnlockedRowsCore
	 * @private
	 * @summary      Deletes all rows
	 * @description  Deletes all rows
	 */

	let _fnDeleteAllInlineUnlockedRowsCore = function ($me) {
		let dataObj = _fnGetDataObj($me);
		if (!dataObj) throw new Error('An instance of ' + CONST_DATA_NAME + ' is required');
		_fnSetDisableTaUpdateFlag($me,true);
		dataObj.dataMap.clear();
		dataObj.tbodyNew.empty();
		_fnSetDisableTaUpdateFlag($me,false);
		_dataMapToTA(dataObj.me);
		return;
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnDeleteAllInlineUnlockedRows
	 * @private
	 * @summary      Deletes all rows
	 * @description  Deletes all rows
	 */

	let _fnDeleteAllInlineUnlockedRows = function (elem) {
		let $me = _fnGetMe(elem);
		_fnDeleteAllInlineUnlockedRowsCore($me);
		return;
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnDeleteAllInlineUnlockedFields
	 * @private
	 * @summary      Deletes all rows
	 * @description  Deletes all rows
	 */

	let _fnDeleteAllInlineUnlockedFields = function (uiActionObj) {	
		let $me = _fnGetMe(uiActionObj.dataObj.me);
		let fnOnProceed = function () {
          _fnDeleteAllInlineUnlockedRowsCore($me);
		};
		let content = '<p class="text-center">Are you sure you want to remove all rows? This action cannot be undone.</p>';
		let dia = MBA.ComponentCommon.fnCreateOneTimeProceedOrCancelDialog('Are You Sure?', content, {}, fnOnProceed, null, true, true);
		$(dia).dialog('open');
		return uiActionObj;
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnDeleteInlineUnlockedFields
	 * @private
	 * @summary      Deletes row
	 * @description  Deletes row
	 */

	let _fnDeleteInlineUnlockedFields = function (uiActionObj) {		
		let nvpObjs = [];

		uiActionObj.dataObj.opts.additionalParameterDefinitionsForDelete.forEach(function (value, key) {
			nvpObjs.push(_fnCreateNameValueObj(key, value));
		});
		
		/* Delete row from map */

		let _me = uiActionObj.dataObj.me;
		let _key = $(uiActionObj.whatRow).attr(CONST_ATTR_NAME_MAP_KEY);
		_deleteObjFromDataMap(_me, _key, true);
		$(uiActionObj.whatRow).remove();
		/* TODO: Fire row removed event*/
		return uiActionObj;

	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnCloneInlineUnlockedFields
	 * @private
	 * @summary      Clones row
	 * @description  Clones row
	 */
	
	let _fnCloneInlineUnlockedFields = function (uiActionObj) {
		let _me = uiActionObj.dataObj.me;
		let _originalKey  = $(uiActionObj.whatRow).attr(CONST_ATTR_NAME_MAP_KEY);	
		let _rowData = _getObjFromDataMap(_me, _originalKey);		
		return _fnCreateNewInlineUnlockedRowAndCells(uiActionObj, ROW_TYPE.CLONED_ROW, _rowData, true);
	}

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnAddNewInlineUnlockedRow
	 * @private
	 * @summary      Allows for caller to add new row programmably
	 * @description  Allows for caller to add new row programmably
	 */

	let _fnAddNewInlineUnlockedRow = function (elem, rowDataIn) {

		/* Populate a subset of uiActionObj */

		let uiActionObj = {};

		uiActionObj.elem    = elem;
		uiActionObj.me      = _fnGetMe(elem);
		uiActionObj.dataObj = _fnGetDataObj(uiActionObj.me);

		let rowData = uiActionObj.dataObj.opts.fnModifyRowDataBeforeAddNew(uiActionObj, rowDataIn);

		return _fnCreateNewInlineUnlockedRowAndCells(uiActionObj, ROW_TYPE.NEW_ROW, rowData, true);
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnPreloadInlineUnlockedRow
	 * @private
	 * @summary      Allows for caller to preload row programmably.  Rows are appended to end.  This method does not update the ui so caller must do this.
	 * @description  Allows for caller to preload row programmably.  Rows are appended to end.  This method does not update the ui so caller must do this.
	 */

	let _fnPreloadInlineUnlockedRow = function (elem, rowDataIn) {

		/* Populate a subset of uiActionObj */

		let uiActionObj = {};

		uiActionObj.elem    = elem;
		uiActionObj.me      = _fnGetMe(elem);
		uiActionObj.dataObj = _fnGetDataObj(uiActionObj.me);

		let rowData = uiActionObj.dataObj.opts.fnModifyRowDataBeforeAddNew(uiActionObj, rowDataIn);

		return _fnCreateNewInlineUnlockedRowAndCells(uiActionObj, ROW_TYPE.PRELOADED_ROW, rowData, false);

	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnPreloadInlineUnlockedRows
	 * @private
	 * @summary      Allows for caller to preload rows programmably.  Rows are appended to end. The ui is updated at the end.
	 * @description  Allows for caller to preload rows programmably.  Rows are appended to end. The ui is updated at the end.
	 */

	let _fnPreloadInlineUnlockedRows = async function (elem, rowsDataIn) {		
		let me = _fnGetMe(elem);
		_fnUpdateMessageOverlayContent(elem, 'Loading Data');
		_fnShowMessageOverlay(elem);
		rowsDataIn.forEach(function (rowDataIn, idx) {
		  _fnPreloadInlineUnlockedRow(elem, rowDataIn);		  
		});
		_dataMapToTA(me);
		_fnHideMessageOverlay(elem);
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/*################################################################################################
	  #
	  #                                  Construction and Teardown
	  #
	  #################################################################################################*/

	/**
	 * @function     _fnDestroy
	 * @private
	 * @summary      Destroy existing instance
	 * @description  Destroy existing instance
	 * @param  {Object}  elem  Element reference
	 */

	let _fnDestroy = function (elem) {
		let $me = _fnGetMe(elem);
		let _dataObj = _fnGetDataObj($me);
		$me.removeData(CONST_DATA_NAME);
		$me.html('');
		return;
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

		if (_fnLoadDataObj($me)) return;

		/* Give element an id if it does not have one */

		let meID = $me.attr('id');

		if (!meID) {
			meID = _createNewUUID();
			$me.attr('id', meID);
		}

		/* Define the data object we will save later */

		let dataObj = {};

		/* Mark element as container for control and store reference to elem */

		dataObj.meID = meID;
		dataObj.me = $me;

		$me.addClass(CSS_CLASSES.me).addClass(CSS_CLASSES.container);

		/* Merge default options and options passed in and store reference to options. */

		let opts = $.extend({}, CONST_DEFAULT_OPTIONS, optsIn);
		dataObj.opts = opts;

		/* Setup map if not already for additional method parameters */

		if (!dataObj.opts.additionalControlDefinitionsForHeadRows) dataObj.opts.additionalControlDefinitionsForHeadRows = new Map();
		if (!dataObj.opts.additionalControlDefinitionsForBodyRows) dataObj.opts.additionalControlDefinitionsForBodyRows = new Map();
		if (!dataObj.opts.additionalParameterDefinitionsForView) dataObj.opts.additionalParameterDefinitionsForView = new Map();
		if (!dataObj.opts.additionalParameterDefinitionsForAddNew) dataObj.opts.additionalParameterDefinitionsForAddNew = new Map();
		if (!dataObj.opts.additionalParameterDefinitionsForEdit) dataObj.opts.additionalParameterDefinitionsForEdit = new Map();
		if (!dataObj.opts.additionalParameterDefinitionsForDelete) dataObj.opts.additionalParameterDefinitionsForDelete = new Map();
		if (!dataObj.opts.additionalParameterDefinitionsForUnDelete) dataObj.opts.additionalParameterDefinitionsForUnDelete = new Map();
		if (!dataObj.opts.additionalParameterDefinitionsForClone) dataObj.opts.additionalParameterDefinitionsForClone = new Map();
		if (!dataObj.opts.additionalParameterDefinitionsForReport) dataObj.opts.additionalParameterDefinitionsForReport = new Map();

		/* Setup array for registering additonal info field defs*/

		if (!dataObj.opts.additionalInfoFieldDefinitions) {
			dataObj.opts.additionalInfoFieldDefinitions = [];
		};

		/* Setup array for registering and then searching additional field defs*/

		if (!dataObj.opts.additionalCellValueFieldDefinitions) dataObj.opts.additionalCellValueFieldDefinitions = [];

		$.each(dataObj.opts.fieldDefinitions, function (fdIdx, fldDef) {
			if (fldDef.additionalCellValueFieldDefinitions) {
				dataObj.opts.additionalCellValueFieldDefinitions.push(...fldDef.additionalCellValueFieldDefinitions);
			}
		});

		/* Create message overlay */

		let $messageOverlayContent = $('<div></div>');
		$messageOverlayContent.addClass(CSS_CLASSES.messageOverlayContent);

		let $messageOverlayContainer = $('<div></div>');
		$messageOverlayContainer.addClass(CSS_CLASSES.messageOverlayContainer);
		$messageOverlayContainer.addClass(CSS_CLASSES.hidden);
		$messageOverlayContainer.append($messageOverlayContent);

		dataObj.messageOverlayContainer = $messageOverlayContainer;
		dataObj.messageOverlayContent   = $messageOverlayContent;

		/* Create map to store data */

		dataObj.dataMap = new Map();

		/* Create and append hidden input where the JSON value is stored */

		let $jsonDataHiddenInput = $(dataObj.opts.jsonInputHtml);
		dataObj.$jsonDataHiddenInput = $jsonDataHiddenInput;

		$me.append($jsonDataHiddenInput);

		/* Create table container */

		let $tableContainer = $('<section></section>');
		$tableContainer.addClass(CSS_CLASSES.tableContainer);
		if (dataObj.opts.enableScrollView == true) {
			$tableContainer.addClass(CSS_CLASSES.scrollView);
		}

		/* Create table */

		let $table = $('<table></table>');
		$table.addClass(CSS_CLASSES.table);

		/* Create table header */

		let $thead = $('<thead></thead>');
		$thead.addClass(CSS_CLASSES.tableHeader);

		/* Row controls for header */

		let rowCtrls = [];

		/* User defined controls - If specified include before built in  */

		if (dataObj.opts.positionUserDefinedControlsInHead === POSITION_USER_DEFINED_CONTROLS.BEFORE_BUILT_IN) {
			dataObj.opts.additionalControlDefinitionsForHeadRows.forEach(function (value, key) {
				rowCtrls.push(value);
			});
		}

		/* Add new */
		 
		if (opts.enableRowControlRecAddNew === true) {
		  rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recaddnewinlineunlockedfields);
		}

		/* Delete all rows */

		if (opts.enableRowControlDeleteAll === true) {			
			rowCtrls.push(CONST_BUILT_IN_CONTROL_TYPES.recdeleteallinlineunlockedfields);						
		}

		/* User defined controls - If specified include before after in  */

		if (dataObj.opts.positionUserDefinedControlsInHead === POSITION_USER_DEFINED_CONTROLS.AFTER_BUILT_IN) {
			dataObj.opts.additionalControlDefinitionsForHeadRows.forEach(function (value, key) {
				rowCtrls.push(value);
			});
		}

		/* Cols */

		let $columns = _fnCreateNewRow(SECTIONS.TABLE, SUB_SECTIONS.THEAD, ROW_TYPE.HEADER_ROW, opts, '<th></th>', '', rowCtrls, null, null);

		let $copyforallcolumns     = null;
		let $copyforalliconcolumns = null;

		if (opts.hasCopyForAll == true) {
			$copyforallcolumns     = _fnCreateNewRow(SECTIONS.TABLE, SUB_SECTIONS.THEAD, ROW_TYPE.HEADER_ROW, opts, '<th></th>', '', [], null, null);
			$copyforalliconcolumns = _fnCreateNewRow(SECTIONS.TABLE, SUB_SECTIONS.THEAD, ROW_TYPE.HEADER_ROW, opts, '<th></th>', '', [], null, null);
		}

		/* Add the field specific columns  */

		let colIdxCtr = 1;

		$.each(opts.fieldDefinitions, function (fieldDefIdx, fieldDefinition) {

			/* We do not render the following columns */

			if (fieldDefinition.isRecID === true) return;
			if (fieldDefinition.isActiveFlag === true) return;
			if (fieldDefinition.isCanEditFlag === true) return;
			if (fieldDefinition.isCanDeleteFlag === true) return;
			if (fieldDefinition.isCanUnDeleteFlag === true) return;

			let $col = _fnCreateNewCol(1, colIdxCtr, opts, fieldDefinition);
			$($columns).append($col);

			if (opts.hasCopyForAll == true) {
				/* Copy down field */
				let $copyforallcol = _fnCreateNewCol(2, colIdxCtr, opts, fieldDefinition);
				$($copyforallcolumns).append($copyforallcol);

				/* Copy down control */
				let $copyforalliconcol = _fnCreateNewCol(3, colIdxCtr, opts, fieldDefinition);
				$($copyforalliconcolumns).append($copyforalliconcol);
			}

			colIdxCtr++;
		});

		dataObj.columns = $columns;

		if (opts.hasCopyForAll == true) {
			dataObj.copyForAllColumns     = $copyforallcolumns;
			dataObj.copyForAllIconColumns = $copyforalliconcolumns;
		}

		$thead.append($columns);

		if (opts.hasCopyForAll == true) {
			$thead.append($copyforallcolumns);
			$thead.append($copyforalliconcolumns);
		}

		/* Create table body for new or cloned records */

		let $tbodyNew = $('<tbody></tbody>');
		$tbodyNew.addClass(CSS_CLASSES.tableBody);

		/* Create table body for existing records */

		let $tbody = $('<tbody></tbody>');
		$tbody.addClass(CSS_CLASSES.tableBody);

		/* Build table and put it in its container */

		$($table).append($thead);
		$($table).append($tbodyNew);
		$($table).append($tbody);
		$($tableContainer).append($table);

		dataObj.table          = $table;
		dataObj.tableContainer = $tableContainer;
		dataObj.tbodyNew       = $tbodyNew;
		dataObj.tbody          = $tbody;

		/* Add helper flag that is set by caller via fnSetOkToWorkWithDataFlag and passed back to caller in fnSaveDataAfter */

		dataObj.okToWorkWithData = true;

		/* Add helper flag that is set internally and by caller via fnSetDisableTaUpdate to control whether or not to serialize grid into json and update text area */

		dataObj.disableTaUpdate = false;

		/* Add the various sections to our original element*/

		$($me).append($messageOverlayContainer);
		$($me).append($tableContainer);
		
		/* Save our data object.  This will be used for option calls */

		_fnSaveDataObj($me, dataObj);

		/* Wire up events */

		$($thead).on('click', 'tr > th ' + '*[' + CONST_ATTR_NAME_UI_ELEMENT_TYPE + ']', function (e) { return _fnIdentifyUIActionAndCallHandler(e, elem, SECTIONS.TABLE, SUB_SECTIONS.THEAD, 'th', CONST_BUILT_IN_CONTROL_TYPES); });
		$($tbodyNew).on('click change', 'tr > td ' + '*[' + CONST_ATTR_NAME_UI_ELEMENT_TYPE + ']', function (e) { return _fnIdentifyUIActionAndCallHandler(e, elem, SECTIONS.TABLE, SUB_SECTIONS.TBODY_NEW, 'td', CONST_BUILT_IN_CONTROL_TYPES); });
		$($tbody).on('click change', 'tr > td ' + '*[' + CONST_ATTR_NAME_UI_ELEMENT_TYPE + ']', function (e) { return _fnIdentifyUIActionAndCallHandler(e, elem, SECTIONS.TABLE, SUB_SECTIONS.TBODY_EXISTING, 'td', CONST_BUILT_IN_CONTROL_TYPES);});
		
		/* Calculate and assign min sizes for column head */

		/* Estimate number of controls */

		let minRowCtrlCount = 0;
		let headerRowCtrlCount = 0;
		let bodyRowCtrlCount = 0;
		let addOneExtraControl = false;

		if (rowCtrls.length) headerRowCtrlCount = rowCtrls.length;

		if (opts.enableRowControlRecClone) {
			bodyRowCtrlCount++;
			addOneExtraControl = true;
		}
		if (opts.enableRowControlRecDelete) {
			bodyRowCtrlCount++;
			addOneExtraControl = true;
		}

		bodyRowCtrlCount = bodyRowCtrlCount + opts.additionalControlDefinitionsForBodyRows.size;

		if (headerRowCtrlCount >= bodyRowCtrlCount) minRowCtrlCount = headerRowCtrlCount;
		if (bodyRowCtrlCount >= headerRowCtrlCount) minRowCtrlCount = bodyRowCtrlCount;
		if (addOneExtraControl) minRowCtrlCount++;
		if (opts.enableRowNumbers) minRowCtrlCount++;
		let minRowCtrlColWidth = Math.ceil(minRowCtrlCount + (minRowCtrlCount * .25));
		let $cols = $($thead).find('th.' + CSS_CLASS_VISIBLE_TD_TH);

		$.each($cols, function (colIdx, $col) {
			if ($col.hasAttribute(CONST_ATTR_NAME_ROW_CONTROLS)) {
				let styleAttrVal = 'min-width:' + minRowCtrlColWidth + 'em';
				$($col).attr('style', styleAttrVal);
				return;
			}

			if ($col.hasAttribute(CONST_ATTR_NAME_FIELD_NAME)) {
				let $colTop = $($col).children('div.' + CSS_CLASS_COL_TOP)[0];
				let ow = Math.floor($($colTop).innerWidth());
				let styleAttrVal = 'min-width:' + ow + 'px';
				$($col).attr('style', styleAttrVal);
				return;
			}
		});

		/* preload map values if passed */

		
		if (dataObj.opts.tblDataArr && dataObj.opts.tblDataArr.length > 0) {
			if (dataObj.opts.saveModeAddNew === CONST_SAVE_MODE_INLINE_UNLOCKED_FIELDS) {
				$.each(dataObj.opts.tblDataArr, function (idx, obj) {
					_fnAddNewInlineUnlockedRow(elem, obj);
				});				
			}
			else {				
				$.each(dataObj.opts.tblDataArr, function (idx, obj) {
					_addObjToDataMap(elem, obj, false);
				});
				/* draw rows and update hidden textarea */
				_syncUIWithDataMap(elem);
			}
		} else {
			$jsonDataHiddenInput.val('[]');
		}

		/* 'copy for all rows': Execute functions (if passed by user) to run after the table is rendered */
		
		$.each(dataObj.opts.fieldDefinitions, function (fieldDefIdx, fieldDefinition) {
			if (fieldDefinition.hasCustomCopyForAll == true && fieldDefinition.copyForAllOptions.fnAfterRender) {
				let $thElem = $(dataObj.copyForAllColumns).find('th[' + CONST_ATTR_NAME_FIELD_NAME + '=' + fieldDefinition.name + ']');
				let $elem = $($thElem).find('input, select, textarea');
				fieldDefinition.copyForAllOptions.fnAfterRender($elem, dataObj);
			}
		});

		/* click event for 'copy for all rows' */

		$($thead).on('click', 'i.' + CSS_CLASSES.copyForAllIcon, function (e) {


			/* get header column index and field name so that we can match the same field in the body */

			let colIdx = $(e.currentTarget).parents('th').attr(CONST_ATTR_NAME_COL_IDX);
			let fieldName = $(e.currentTarget).parents('th').attr(CONST_ATTR_NAME_FIELD_NAME);

			/* get input value to be copied */

			let $thCopyAll = $(dataObj.copyForAllColumns).find('th[' + CONST_ATTR_NAME_COL_IDX + '=' + colIdx + ']');
			let $inputCopyAll = $($thCopyAll).find('input, select, textarea');
			let inputVal = $($inputCopyAll).val();

			/* Turn off ta updates for now */

			_fnSetDisableTaUpdateFlag(elem, true);

			/* run custom handler and return (if passed in) */

			let elemFieldDefinition = dataObj.opts.fieldDefinitions.find(elem => elem.name == fieldName);
			if (elemFieldDefinition.copyForAllOptions && elemFieldDefinition.copyForAllOptions.fnCustomCopyHandler) {
				elemFieldDefinition.copyForAllOptions.fnCustomCopyHandler($inputCopyAll, colIdx, fieldName, dataObj);

				/* Turn ta updates back on */

				_fnSetDisableTaUpdateFlag(elem, false);

				/* Update ta */

				_dataMapToTA(elem);

				return;
			}


			/* Special case for checboxes */

			let checkboxVal = false;
			if ($($inputCopyAll).attr('type') == 'checkbox') checkboxVal = $($inputCopyAll).prop('checked');

			let tbodyRows = $tbodyNew.find('tr');

			$.each(tbodyRows, function (idx, obj) {
				
				let $tdCol = $(obj).find('td[' + CONST_ATTR_NAME_COL_IDX + '=' + colIdx + ']');
				let $colInput = $($tdCol).find('input[' + CONST_ATTR_NAME_FIELD_NAME + '=' + fieldName + ']'
					+ ', select[' + CONST_ATTR_NAME_FIELD_NAME + '=' + fieldName + ']'
					+ ', textarea[' + CONST_ATTR_NAME_FIELD_NAME + '=' + fieldName + ']');

				/* clear the inputs if copy value is empty */

				if (!inputVal) {
					$colInput.val('').trigger('change');
					return true;
                }

				/* copy value  */

				$colInput.val(inputVal).trigger('change');

				/* Special case for checboxes */

				if ($colInput.attr('type') == 'checkbox') $colInput.prop('checked', checkboxVal).attr('value', inputVal).trigger('change');
			});

			/* Turn ta updates back on */

			_fnSetDisableTaUpdateFlag(elem, false);

			/* Update ta */

			_dataMapToTA(elem);
		});

		/* Call creation complete delegate */
		
		dataObj.opts.fnCreateComplete();

	};

	/*################################################################################################
	  #
	  #                                         Public Methods
	  #
	  ################################################################################################*/

	return {
		  CONST_SECTIONS: SECTIONS
		, CONST_SUB_SECTIONS: SUB_SECTIONS
		, CONST_ROW_TYPE: ROW_TYPE
		, CONST_RETURN_CODES: RETURN_CODES
		, CONST_CSS_CLASSES: CSS_CLASSES
		, EVENT_NAME_EDIT_CANCEL: CONST_EVENT_NAME_EDIT_CANCEL
		, EVENT_NAME_EDIT_PROCEED: CONST_EVENT_NAME_EDIT_PROCEED
		, ATTR_NAME_FIELD_EDIT_STATE: CONST_ATTR_NAME_FIELD_EDIT_STATE
		, ATTR_VALUE_EDIT_STATE_LOCKED: CONST_ATTR_VALUE_EDIT_STATE_LOCKED
		, ATTR_VALUE_EDIT_STATE_UNLOCKED: CONST_ATTR_VALUE_EDIT_STATE_UNLOCKED
		, ATTR_NAME_ALT_VALUE: CONST_ATTR_NAME_ALT_VALUE
		, fnCreate: _fnCreate
		, fnDestroy: _fnDestroy
		, fnGetDataObj: _fnGetDataObj
		, fnAjaxCallAsmxWebMethod: _fnAjaxCallAsmxWebMethod
		, fnCreateNewFieldDefinition: _fnCreateNewFieldDefinition
		, fnCreateNewControlDefinition: _fnCreateNewControlDefinition
		, fnCreateNameValueObject: _fnCreateNameValueObj
		, fnAdditionalParameterDefinitionForViewSet: _fnAdditionalParameterDefinitionForViewSet
		, fnAdditionalParameterDefinitionForAddNewSet: _fnAdditionalParameterDefinitionForAddNewSet
		, fnAdditionalParameterDefinitionForCloneSet: _fnAdditionalParameterDefinitionForCloneSet
		, fnAdditionalParameterDefinitionForEditSet: _fnAdditionalParameterDefinitionForEditSet
		, fnAdditionalParameterDefinitionForDeleteSet: _fnAdditionalParameterDefinitionForDeleteSet
		, fnAdditionalParameterDefinitionForUnDeleteSet: _fnAdditionalParameterDefinitionForUnDeleteSet
		, fnRenderTableRows: _fnRenderTableRows
		, fnOpenWindow: _fnOpenWindow
		, fnCreateNewCellValue: _fnCreateNewCellValue
		, fnGetSavableFields: _fnGetSaveableFields
		, fnPutSaveableFieldsInMap: _fnPutSaveableFieldsInMap
		, fnForceAutoCompleteSearch: _fnForceAutoCompleteSearch
		, fnRefreshCurrentViewFromServer: _fnRenderTableRows
		, fnBuildUrl: _fnBuildUrl
		, fnCreateNewUUID: _createNewUUID
		, fnAddObjToDataMap: _addObjToDataMap
		, fnDeleteObjFromDataMap: _deleteObjFromDataMap
		, fnUpdateObjInDataMap: _updateObjInDataMap
		, fnGetObjFromDataMap: _getObjFromDataMap
		, fnSynchUIWithDataMap: _syncUIWithDataMap
		, fnShowMessageOverlay:	_fnShowMessageOverlay
		, fnUpdateMessageOverlayContent : _fnUpdateMessageOverlayContent
		, fnHideMessageOverlay:	_fnHideMessageOverlay
		, fnClearMessageOverlay: _fnClearMessageOverlay
		, fnAddNewInlineUnlockedRow: _fnAddNewInlineUnlockedRow
		, fnDeleteAllInlineUnlockedRows: _fnDeleteAllInlineUnlockedRows
		, fnPreloadInlineUnlockedRow: _fnPreloadInlineUnlockedRow
		, fnPreloadInlineUnlockedRows: _fnPreloadInlineUnlockedRows
		, fnSetOkToWorkWithDataFlag: _fnSetOkToWorkWithDataFlag
		, fnSetDisableTaUpdateFlag: _fnSetDisableTaUpdateFlag		 
		, dataMapToTA: _dataMapToTA

	};

})(jQuery);

/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      MBA Data Grid
 * @description  MBA Data Grid
 * @requires     jQuery
 */

; (function ($) {

	'use strict';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/* Tie into jQuery namespace */

	$.fn.MBA_DataGrid = function (methodOrOptions, optionsOrValue) {

		/* These are the supported methods and properties that can be accessed from outside 
		 * after an instance is created */
		let _methods = {
			additionalParameterDefinitionForViewSet: function (elem, parameterNameValueObj) {
				return MBA.DataGridCommon.fnAdditionalParameterDefinitionForViewSet(elem, parameterNameValueObj);
			}
			, getDataObj: function (elem) {
				return MBA.DataGridCommon.fnGetDataObj(elem);
			}
			, showOverlayMessage: function (elem, message) {
				MBA.DataGridCommon.fnUpdateMessageOverlayContent(elem, message);
				return MBA.DataGridCommon.fnShowMessageOverlay(elem);
			}
			, hideOverlayMessage: function (elem) {
				return MBA.DataGridCommon.fnHideMessageOverlay(elem,500);
            }
			, syncUIWithDataMap: function (elem) {
				return MBA.DataGridCommon.fnSynchUIWithDataMap(elem);
            }
			, addRowObj: function (elem, rd) {				
				return MBA.DataGridCommon.fnAddObjToDataMap(elem, rd.obj, rd.updateUI);
			}
			, addNewInlineUnlockedRow: function (elem, rowData) {
				return MBA.DataGridCommon.fnAddNewInlineUnlockedRow(elem, rowData);
            }
			, deleteAllInlineUnlockedRows: function (elem) {
				return MBA.DataGridCommon.fnDeleteAllInlineUnlockedRows(elem);
			}
			, preloadInlineUnlockedRow: function (elem, rowData) {
				return MBA.DataGridCommon.fnPreloadInlineUnlockedRow(elem, rowData);
			}
			, preloadInlineUnlockedRows: async function (elem, rowsData) {
				return await MBA.DataGridCommon.fnPreloadInlineUnlockedRows(elem, rowsData);
			}
			, setOkToWorkWithDataFlag: function (elem, value) {
				return MBA.DataGridCommon.fnSetOkToWorkWithDataFlag(elem, value);
            }
		};

		let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

		/* Method is create */

		if (typeof methodOrOptions === 'object' || !methodOrOptions) {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.DataGridCommon.fnCreate(elem, methodOrOptions);
			});
		}

		/* Method is destroy */

		else if (methodOrOptions == 'destroy') {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.DataGridCommon.fnDestroy(elem);
			});
		}

		/* Other methods (these cannot be chained) */

		else if (_methods[methodOrOptions]) {

			if (numOf == 1) {
				let elem = this[0]; /* There is only one element matched so we can proceed */
				return _methods[methodOrOptions](elem, optionsOrValue);
			}

			else if (numOf > 1) {
				/**/
				throw new Error('MBA Data Grid ' + methodOrOptions + ' cannot be applied to a set of elements at once.');
			}

			else {
				throw new Error('MBA Data Grid ' + methodOrOptions + ' cannot be applied since the element was not found.');
			}
		}

		/* Cant find the method */

		else {
			throw new Error('Method ' + methodOrOptions + ' is an unknown MBA Data Grid method');
		}

	}; /* mba_rest_view */

})(jQuery);
