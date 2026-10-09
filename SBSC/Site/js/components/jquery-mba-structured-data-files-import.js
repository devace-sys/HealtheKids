;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.StructuredDataFilesImportCommon
 * @memberof     MBA
 * @summary      Static methods used by the plugin
 * @description  Static methods used by the plugin
 * @requires     jQuery, jQueryUI, common, sheet.js
 */

MBA.StructuredDataFilesImportCommon = (function ($) {

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _PLUGIN_NAME       = 'MBA Structured Data Filea Import';
const _PLUGIN_NS         = 'mba-structured-data-files-import'
const _JQ_DATA_NAME      = 'jq-'   + _PLUGIN_NS;
const _DATA_ATTR_BASE    = 'data-' + _PLUGIN_NS ;  

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DATA_ATTR_NAME_OUTPUT_COL_MATCH_STATE                     = _DATA_ATTR_BASE + '-output-col-match-state';
const _DATA_ATTR_MAP_TO_INPUT_COL_IDX                            = _DATA_ATTR_BASE + '-map-to-input-col-idx';
const _DATA_ATTR_MAP_TO_OUTPUT_FIELD_NAME                        = _DATA_ATTR_BASE + '-map-to-output-field-name';
const _VAL_NO_INPUT_COLUMN_SELECTED                              = -1;
const _DATA_ATTR_VALUE_OUTPUT_COL_MATCH_STATE_NOT_ATTEMPTED      = 'not-attempted';
const _DATA_ATTR_VALUE_OUTPUT_COL_MATCH_STATE_REQUIRED_NOT_FOUND = 'required-not-found';
const _DATA_ATTR_VALUE_OUTPUT_COL_MATCH_STATE_OPTIONAL_NOT_FOUND = 'optional-not-found';
const _DATA_ATTR_VALUE_OUTPUT_COL_MATCH_STATE_MATCH_FOUND        = "match-found";

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _CSS_CLASSES = {
	  me:                          _PLUGIN_NS + ' ' + _PLUGIN_NS + '-data-to-import-json'
	, layoutContainer:             _PLUGIN_NS + ' ' + _PLUGIN_NS + '-layout-container'
	, layoutRow:                   _PLUGIN_NS + ' ' + _PLUGIN_NS + '-layout-row'
	, layoutCol:                   _PLUGIN_NS + ' ' + _PLUGIN_NS + '-layout-col'
	, fileProfileSelect:           _PLUGIN_NS + ' ' + _PLUGIN_NS + '-file-profile-select'
	, inputDataFileSelect:         _PLUGIN_NS + ' ' + _PLUGIN_NS + '-input-data-file-select'
	, inputDataHeaderRowNumber:    _PLUGIN_NS + ' ' + _PLUGIN_NS + '-input-data-file-header-row-number'
	, selectOutputColumn:          _PLUGIN_NS + ' ' + _PLUGIN_NS + '-select-output-column'
	, inputDataPreviewTitle:       _PLUGIN_NS + ' ' + _PLUGIN_NS + '-input-data-preview-title'
	, outputDataPreviewTitle:      _PLUGIN_NS + ' ' + _PLUGIN_NS + '-output-data-preview-title'
	, previewDataContainer:        _PLUGIN_NS + ' ' + _PLUGIN_NS + '-preview-data-table-container'
	, previewDataTable:            _PLUGIN_NS + ' ' + _PLUGIN_NS + '-preview-data-table'
	, previewDataTableHead:        _PLUGIN_NS + ' ' + _PLUGIN_NS + '-preview-data-table-head'
	, previewDataTableRowColHdrs:  _PLUGIN_NS + ' ' + _PLUGIN_NS + '-preview-data-table-row-col-hdrs'
	, previewDataTableRowColCtrls: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-preview-data-table-row-col-ctrls'
	, previewDataTableBody:        _PLUGIN_NS + ' ' + _PLUGIN_NS + '-preview-data-table-body'
	, inputDataPreviewTable:       _PLUGIN_NS + ' ' + _PLUGIN_NS + '-input-data-preview-table'
	, outputDataPreviewTable:      _PLUGIN_NS + ' ' + _PLUGIN_NS + '-output-data-preview-table'
	, hidden:                      _PLUGIN_NS + '-hidden'
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _DEFAULT_OPTIONS = {
	  cssClasses: _CSS_CLASSES
    , numInputPreviewRows: 10
    , numOutputPreviewRows: 10
	, headerRowNum: 1
	, labelSelectFileProfile:'Please select the type of file'
	, labelSelectFile:'Please select the file itself'
	, labelInputHeaderRowNumber: 'Please select the header row number'
	, manualInputOutputMapping: false
	, defaultFileProfileID: ''
	, showProfileSelection:true
	, fileProfiles: []
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
 * @function     _fnSetDataObj
 * @private
 * @summary      Sets value of data object
 * @description  Sets value of data object
 * @param  {Object}  $me      Element reference
 * @param  {Object}  dataObj  Data obj for this plugin
 */

let _fnSetDataObj = function ($me, dataObj) {
  $($me).data(_JQ_DATA_NAME, dataObj);
  return;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnIsElemSupported
 * @private
 * @summary      Returns false if element plugin is enhancing is not supported
 * @description  Returns false if element plugin is enhancing is not supported
 * @param  {Object}  $me  Element reference
 */

let _fnIsElemSupported = function (elem) {
  return  $(elem).is('textarea'); 
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
 * @function     _fnUpdateInputDataObjHeaderData
 * @private
 * @summary      Updates header data for input data
 * @description  Updates header data for input data
 * @param  {Object}  $me  Element reference
 */

let _fnUpdateInputDataObjHeaderData = function (dataObj) {
	let headerIdx = 0;
	let dataStartIdx = 0;
	let numPreviewRows = 0;
	let hdrArr = [];
	headerIdx = parseInt($(dataObj.ctrlInputFileHeaderRowNum).val()) - 1;
	if (headerIdx < 0) headerIdx = 0;
	dataStartIdx = headerIdx + 1;
	numPreviewRows = dataObj.opts.numInputPreviewRows;
	if (dataObj.inputDataObj.numRows < numPreviewRows) numPreviewRows = dataObj.inputDataObj.numRows;
	if ((dataObj.inputDataObj.hasData == true) && (dataObj.inputDataObj.numRows >= headerIdx))
	{
		hdrArr = dataObj.inputDataObj.sheetData[headerIdx];
	}
	dataObj.inputDataObj.headerIdx    = headerIdx;
	dataObj.inputDataObj.dataStartIdx = dataStartIdx;
	dataObj.inputDataObj.hdrArr       = hdrArr;
	dataObj.inputDataObj.numPreviewRows = numPreviewRows;
	return dataObj;
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnUpdateInputDataObjSheetData
 * @private
 * @summary      Updates sheet data for input file
 * @description  Updates sheet data for input file
 * @param  {Object}  $me  Element reference
 */

let _fnUpdateInputDataObjSheetData = function ($me,sheetData) {
	let dataObj = _fnGetDataObj($me);
	dataObj.inputDataObj = {};
	let hasData = true;
	let numRows = 0;
	if (!sheetData)      hasData = false;
	if (hasData == true) numRows   = sheetData.length;
	dataObj.inputDataObj.hasData   = hasData;
	dataObj.inputDataObj.sheetData = sheetData;
	dataObj.inputDataObj.numRows   = numRows;
	dataObj = _fnUpdateInputDataObjHeaderData(dataObj);
	_fnSetDataObj($me, dataObj);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnInitOutputDataObj
 * @private
 * @summary      Inits output data object
 * @description  Inits output data object
 * @param  {Object}  $me  Element reference
 */

let _fnInitOutputDataObj = function ($me) {
    let dataObj = _fnGetDataObj($me);
	dataObj.outputDataObj = {};
	_fnSetDataObj($me, dataObj);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnInitInputDataObj
 * @private
 * @summary      Inits input data object
 * @description  Inits input data object
 * @param  {Object}  $me  Element reference
 */

let _fnInitInputDataObj = function ($me) {
	_fnUpdateInputDataObjSheetData($me, null);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnParseInputFileIntoInputDataObj
 * @private
 * @summary      Parses input file
 * @description  Parses input file
 * @param  {Object}  $me  Element reference
 */

let _fnParseInputFileIntoInputDataObj = function ($me,rle) {
    /* We have to pass raw: true, because otherwise, datetimes in CSV files would drop the "time" portion. Source: https://github.com/SheetJS/sheetjs/issues/940 */
	let workbook = XLSX.read(rle.target.result, { raw: true});
	let sheetName = workbook.SheetNames[0];
	let sheetToJsonOptsObj = {};
	sheetToJsonOptsObj.raw       = false;
	sheetToJsonOptsObj.defval    = '';
	sheetToJsonOptsObj.blankrows = false;
	sheetToJsonOptsObj.header    = 1; /* Generate array of arrays */
	let sheetData = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], sheetToJsonOptsObj);
	_fnUpdateInputDataObjSheetData($me, sheetData);
	return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetDataProfileToUse
 * @private
 * @summary      Returns reference to data profile in use
 * @description  Returns reference to data profile in use
 * @param  {Object}  $me  Element reference
 */

let _fnGetDataProfileToUse = function (dataObj) {
	let fileProfiletoUse = null;
	$.each(dataObj.opts.fileProfiles, function (idx, fileProfile) {
		if (fileProfile.id == dataObj.fileProfileID) {
			fileProfiletoUse = fileProfile;
			return false;
		}
	});
	return fileProfiletoUse;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateFieldMatch
 * @private
 * @summary      Create a field match object
 * @description  Create a field match object
 */

let _fnCreateFldMatch = function (inputField,outputField,inputFieldIdx,outputFieldIdx) {

	let fldMatch = {};

	fldMatch.inputFieldName = inputField;
	fldMatch.outputFieldName = outputField.name;
	fldMatch.inputFieldIdx = inputFieldIdx;
	fldMatch.outputFieldIdx = outputFieldIdx;
 	fldMatch.outputFieldLabel = outputField.label;
	return fldMatch;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnUserMapInputDataFieldsToOutputDataFields
 * @private
 * @summary      Attempt to match input fields to output fields
 * @description  Attempt to match input fields to output fields
 * @param  {Object}  $me  Element reference
 */

 let _fnUserMapInputDataFieldsToOutputDataFields = function (dataObj, mapWorkingDataObj) {

   /*-----------------------------
    * For each output field
	*----------------------------*/

   $.each(mapWorkingDataObj.outputFields, function (outputFieldIdx, outputField) {

     let matchFound = false;
	 matchFound = false;

	 /* If we already mapped this outputField to an input move on to next.  
	  * Only 1:1 mapping relationships allowed. */

	 if (mapWorkingDataObj.outputFieldNamesUsed.includes(outputField.name) == true) return;
		
	 let inputFieldIdx = dataObj.userSpecifiedInputOutputMap.get(outputField.name);
	 if (inputFieldIdx != _VAL_NO_INPUT_COLUMN_SELECTED) matchFound = true;
			
	 /* If match is found  */

	 if (matchFound === true) {
	  mapWorkingDataObj.outputFieldNamesUsed.push(outputField.name);
	  let inputField = mapWorkingDataObj.inputFields[inputFieldIdx];
	  let fldMatch = _fnCreateFldMatch(inputField, outputField, inputFieldIdx, outputFieldIdx);
	  mapWorkingDataObj.inputOutputFieldMatches.push(fldMatch); 
	 } /* match is found */

  }); /* Output field search*/
  
  return mapWorkingDataObj;

}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAutoMapInputDataFieldsToOutputDataFields
 * @private
 * @summary      Attempt to match input fields to output fields
 * @description  Attempt to match input fields to output fields
 * @param  {Object}  $me  Element reference
 */

let _fnAutoMapInputDataFieldsToOutputDataFields = function (dataObj, mapWorkingDataObj) {

	/*-----------------------------
     * For each input field
     *----------------------------*/

	$.each(mapWorkingDataObj.inputFields, function (inputFieldIdx, inputField) {

	  /*-----------------------------
	   * For each output field
	   *----------------------------*/

	  $.each(mapWorkingDataObj.outputFields, function (outputFieldIdx, outputField) {
			
			let matchFound = false;
			matchFound = false;

			/* If we already mapped this outputField to an input move on.  
			 * Only 1:1 mapping relationships allowed. */

			if (mapWorkingDataObj.outputFieldNamesUsed.includes(outputField.name) == true) return;
			
	
			/* Try to exact match on name first */

			if (matchFound === false) {
				if (inputField == outputField.name) {
					matchFound = true;
				}
			}

			/* Then try exact match on label */

			if (matchFound === false) {
				if (inputField == outputField.label) {
					matchFound = true;
				}
			}

			/* If match not found yet, then try to exact match on a common column name */
			
			if (matchFound === false) {
				if (outputField.commonColumnNames.includes(inputField) == true) {
					matchFound = true;
				}
			}
			
			/* If match not found yet, then try to match on variants of a common column name */
			
			if (matchFound === false) {

				let _fnIsCommonInputField = function (element) {
					if (!element) return false;
					if (!inputField) return false;
					/* Remove all whitespace, underscores, dashes, and periods */
					let fld1 = inputField.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('-', '').replaceAll('.','');
					let fld2 = element.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('-', '').replaceAll('.','');
					return (fld1 === fld2);
				};

				if (outputField.commonColumnNames.find(_fnIsCommonInputField)) {
					matchFound = true;
				}
			} 
			
			/* If match is found  */

			if (matchFound === true) {
				mapWorkingDataObj.outputFieldNamesUsed.push(outputField.name);
				let fldMatch = _fnCreateFldMatch(inputField, outputField, inputFieldIdx, outputFieldIdx);
				mapWorkingDataObj.inputOutputFieldMatches.push(fldMatch);							
				return false; /* Done with inputField */
			} /* match is found */

		}); /* Output field search*/
	}); /* Input field */

   return mapWorkingDataObj;

};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function _fnMapInputDataFieldsToOutputDataFields
 * @private
 * @summary      Applies user and auto mapping
 * @description  Applies user and auto mapping
 * @param  {Object}  $me  Element reference
 */

let _fnMapInputDataFieldsToOutputDataFields = function ($me, e) {

	/*-----------------------------
	 * Get global dataObj
	 *----------------------------*/

	let dataObj = _fnGetDataObj($me);

	/*-----------------------------
	 * Init
	 *----------------------------*/

	let mapWorkingDataObj = {};

	mapWorkingDataObj.inputFields               = [];
	mapWorkingDataObj.outputFields              = [];
	mapWorkingDataObj.outputFieldNamesUsed      = [];
	mapWorkingDataObj.inputOutputFieldMatches   = [];
	mapWorkingDataObj.allOutputFieldMisses      = [];
	mapWorkingDataObj.requiredOutputFieldMisses = [];

	/*-----------------------------
	 * Reset data in global dataObj
	 *----------------------------*/

	dataObj.inputOutputFieldMatches   = [];
	dataObj.allOutputFieldMisses      = [];
	dataObj.requiredOutputFieldMisses = [];

	/*-----------------------------
	 * Save global dataObj
	 *----------------------------*/

	_fnSetDataObj($me, dataObj);

	/*-----------------------------
	 * If no profile selected exit
	 *----------------------------*/

	if (dataObj.fileProfileID === '') return mapWorkingDataObj;

	/*-----------------------------
	 * Get input field names and
	 * remove leading/trailing
	 * whitespace, crlf, and tabs
	 *----------------------------*/

	dataObj.inputDataObj.hdrArr.forEach(function (hdrCell) {
		let inputField = '' + hdrCell.trim().replace(/[\n\r\t]/g, '');
		mapWorkingDataObj.inputFields.push(inputField);
	});
	
	/*-----------------------------
	 * Get profile data
	 *----------------------------*/

	let fileProfileToUse = _fnGetDataProfileToUse(dataObj);

	/*-----------------------------
	 * Get output field names and
	 * associated data
	 *----------------------------*/

	mapWorkingDataObj.outputFields = fileProfileToUse.fields;
	
	/*-----------------------------
	 * Apply user mapping if
	 * enabled
	 *----------------------------*/

	if (dataObj.opts.manualInputOutputMapping === true) {
		mapWorkingDataObj = _fnUserMapInputDataFieldsToOutputDataFields(dataObj, mapWorkingDataObj);
	}

	/*-----------------------------
	 * Apply auto mapping
	 *----------------------------*/

	mapWorkingDataObj = _fnAutoMapInputDataFieldsToOutputDataFields(dataObj,mapWorkingDataObj);
	
	/*-----------------------------
	 * Find output fields that were
	 * not matched up
	 *----------------------------*/

	mapWorkingDataObj.outputFields.forEach(function (outputField) {

		let _fnIsMatchMade = function (element) {
			if (!element) return false;
			if (!outputField) return false;
			return (element.outputFieldName == outputField.name);
		};

		if (!mapWorkingDataObj.inputOutputFieldMatches.find(_fnIsMatchMade)) {
			mapWorkingDataObj.allOutputFieldMisses.push(outputField.label);
			if (outputField.columnRequired == true) {
				mapWorkingDataObj.requiredOutputFieldMisses.push(outputField.label);
			}
		}

	});

	dataObj.inputOutputFieldMatches   = mapWorkingDataObj.inputOutputFieldMatches;
	dataObj.allOutputFieldMisses      = mapWorkingDataObj.allOutputFieldMisses;
	dataObj.requiredOutputFieldMisses = mapWorkingDataObj.requiredOutputFieldMisses;

	/*-----------------------------
     * Save global dataObj
     *----------------------------*/

	_fnSetDataObj($me, dataObj);

	return mapWorkingDataObj;

}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGenerateOutputDataObj
 * @private
 * @summary      Generates the output data object that is part of this plugins output
 * @description  Generates the output data object that is part of this plugins output
 * @param  {Object}  $me  Element reference
 */

let _fnGenerateOutputDataObj = function ($me, rle) {

	/*-----------------------------
	 * Load the global data object
	 *----------------------------*/

	let dataObj = _fnGetDataObj($me);

	/*-----------------------------
	 * Reset output data object
	 * data in the global data 
	 * object
	 *----------------------------*/

	dataObj.outputDataObj = {};
	dataObj.outputDataObj.sheetData      = [];
	dataObj.outputDataObj.numPreviewRows = dataObj.opts.numOutputPreviewRows;
	dataObj.outputDataObj.dataStartIdx   = 0;
	dataObj.outputDataObj.hdrArr         = [];
	dataObj.outputDataObj.numCols        = 0;
	dataObj.outputDataObj.numRows        = 0;

	/*-----------------------------
     * Save the global data object
	 * in case we have to exit 
	 * early
     *----------------------------*/

	_fnSetDataObj($me, dataObj);

	/*-----------------------------
     * No profile selection, exit
     *----------------------------*/

	if (dataObj.fileProfileID === '') return;

	/*-----------------------------
	 * Load profile
	 *----------------------------*/

	let fileProfileToUse = _fnGetDataProfileToUse(dataObj);

	let numCols = 0;
	let numRows = 0;

	/*-----------------------------
     * Generate header array and
	 * count number of columns
	 *----------------------------*/

	$.each(fileProfileToUse.fields, function (colIdx, field) {
		dataObj.outputDataObj.hdrArr.push(field.label);
		numCols++;
	});

	dataObj.outputDataObj.numCols = numCols;

	/*-----------------------------
	 * Generate rows and count 
	 * number of rows
	 *----------------------------*/

	for (let rowIdx = dataObj.inputDataObj.dataStartIdx; rowIdx < dataObj.inputDataObj.numRows; rowIdx++) {

		let outputRowObj = {};
		let inputRowArr = dataObj.inputDataObj.sheetData[rowIdx];

		/* Populate output row cells with placeholders for all of the output fields specified in the profile */

		$.each(fileProfileToUse.fields, function (colIdx, field) {
			outputRowObj[field.name] = '';
		});

		/* Go through the matches and populate all output row cells with whatever was found */

		$.each(dataObj.inputOutputFieldMatches, function (colIdx, fldMatch) {
			outputRowObj[fldMatch.outputFieldName] = inputRowArr[fldMatch.inputFieldIdx];
		});

		dataObj.outputDataObj.sheetData.push(outputRowObj);
		numRows++;
	};

	dataObj.outputDataObj.numRows = numRows;

	/*-----------------------------
     * Save changes to global data 
	 * object data
     *----------------------------*/

	_fnSetDataObj($me, dataObj);

	return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnParseInputDataObjIntoPreviewHtml
 * @private
 * @summary      Returns reference to data profile in use
 * @description  Returns reference to data profile in use
 * @param  {Object}  $me  Element reference
 */

let _fnParseInputDataObjIntoPreviewHtml = function ($me,e) {

  /*-----------------------------
   * Load global data object
   * and reset data
   *----------------------------*/

  let dataObj = _fnGetDataObj($me);
  dataObj = _fnUpdateInputDataObjHeaderData(dataObj);  
  dataObj.userSpecifiedInputOutputMap = new Map();
  dataObj.tblInputFilePreviewThead.html('');
  dataObj.tblInputFilePreviewTbody.html('');

  /*-----------------------------
   * Save changes to global data
   * object in case we have to
   * exit early
   *----------------------------*/

  _fnSetDataObj($me, dataObj);

  /*-----------------------------
   * If no data, no rows, or
   * no profile selected exit
   *----------------------------*/

  if (dataObj.inputDataObj.hasData == false) return;
  if (dataObj.inputDataObj.numRows == 0)     return;
  if (dataObj.fileProfileID === '')          return;

  /*-----------------------------
   * If user mapping is enabled
   *----------------------------*/

   if (dataObj.opts.manualInputOutputMapping === true)
   {
     let fileProfileToUse = _fnGetDataProfileToUse(dataObj);
  
    /*-----------------------------
     * Repopulate,reset io map 
     *----------------------------*/

	 $.each(fileProfileToUse.fields, function (colIdx, field) {		
	   dataObj.userSpecifiedInputOutputMap.set(field.name, _VAL_NO_INPUT_COLUMN_SELECTED);
	 });
	
	/*-----------------------------
	 * Save changes to global data
	 * object
     *----------------------------*/

	_fnSetDataObj($me, dataObj);
  } /* user mapping */

  /*-----------------------------
   * Build header row that
   * contains input column names
   *----------------------------*/

  let $trh1 = $('<tr></tr>');
  $($trh1).addClass(dataObj.opts.cssClasses.previewDataTableRowColHdrs);
  dataObj.inputDataObj.hdrArr.forEach(function (rowCell) {
    let $th = $('<th>' + rowCell + '</th>');
	$trh1.append($th);
  });

  $(dataObj.tblInputFilePreviewThead).append($trh1);

  /*-----------------------------
   * If enabled, build header row 
   * that contains output column 
   * label selection
   *----------------------------*/

  if (dataObj.opts.manualInputOutputMapping === true)
  {		
	  let $trh2 = $('<tr></tr>');
	  $($trh2).addClass(dataObj.opts.cssClasses.previewDataTableRowColCtrls);
	  let inputColIdx = 0;
	  dataObj.inputDataObj.hdrArr.forEach(function (rowCell) {
		let $th = $('<th></th>');
		let $ctrlInpMapToOutputField = $('<select class="' + dataObj.opts.cssClasses.selectOutputColumn + '">' + dataObj.outputColumnSelectionsStr + '</select>');		  
		$ctrlInpMapToOutputField.attr(_DATA_ATTR_MAP_TO_INPUT_COL_IDX, inputColIdx);
		$ctrlInpMapToOutputField.attr(_DATA_ATTR_MAP_TO_OUTPUT_FIELD_NAME, _VAL_NO_INPUT_COLUMN_SELECTED);
		$($th).append($ctrlInpMapToOutputField);

		$($ctrlInpMapToOutputField).on('change', function (e) {
			/* Load data object */
			let dataObj = _fnGetDataObj($me);
			let mapToWhatInputColIdx   = $($ctrlInpMapToOutputField).attr(_DATA_ATTR_MAP_TO_INPUT_COL_IDX);
			let mappedToPrevOutFldName = $($ctrlInpMapToOutputField).attr(_DATA_ATTR_MAP_TO_OUTPUT_FIELD_NAME);
			let mappedToNewOutFldName = $($ctrlInpMapToOutputField).val();
			if (mappedToPrevOutFldName != _VAL_NO_INPUT_COLUMN_SELECTED) dataObj.userSpecifiedInputOutputMap.set(mappedToPrevOutFldName, _VAL_NO_INPUT_COLUMN_SELECTED);
			if (mappedToNewOutFldName != _VAL_NO_INPUT_COLUMN_SELECTED)  dataObj.userSpecifiedInputOutputMap.set(mappedToNewOutFldName, mapToWhatInputColIdx);
			$ctrlInpMapToOutputField.attr(_DATA_ATTR_MAP_TO_OUTPUT_FIELD_NAME, mappedToNewOutFldName);
			_fnSetDataObj($me, dataObj);       /* Save data object */
			_fnMatchAndGenerateOutput($me, e); /* Remap and output */
		});

		inputColIdx++;
		$trh2.append($th);
	});

	$(dataObj.tblInputFilePreviewThead).append($trh2);
	
  } /* user mapping */

  /*-----------------------------
   * Build input row body
   *----------------------------*/
	
  for (let rowIdx = dataObj.inputDataObj.dataStartIdx; rowIdx < dataObj.inputDataObj.numPreviewRows; rowIdx++) {
    let $trb = $('<tr></tr>');
	$.each(dataObj.inputDataObj.sheetData[rowIdx], function (colIdx,cellVal) {
  	    let $td = $('<td>' + cellVal + '</td>');
	    $trb.append($td);
	 });
	 dataObj.tblInputFilePreviewTbody.append($trb);
  };

  return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnParseOutputDataObjIntoPreviewHtml
 * @private
 * @summary      Returns reference to data profile in use
 * @description  Returns reference to data profile in use
 * @param  {Object}  $me  Element reference
 */

let _fnParseOutputDataObjIntoPreviewHtml = function ($me,e) {

	let dataObj = _fnGetDataObj($me);

	dataObj.tblOutputFilePreviewThead.html('');
	dataObj.tblOutputFilePreviewTbody.html('');
	let $trh = $('<tr></tr>');
	$($trh).addClass(dataObj.opts.cssClasses.previewDataTableRowColHdrs);

	dataObj.outputDataObj.hdrArr.forEach(function (rowCell) {
		let $th = $('<th>' + rowCell + '</th>');
		let colMatchState = _DATA_ATTR_VALUE_OUTPUT_COL_MATCH_STATE_NOT_ATTEMPTED;
		if (dataObj.outputDataObj.numRows != 0) {
			if (dataObj.allOutputFieldMisses.includes(rowCell)) {
				if (dataObj.requiredOutputFieldMisses.includes(rowCell)) {
					colMatchState = _DATA_ATTR_VALUE_OUTPUT_COL_MATCH_STATE_REQUIRED_NOT_FOUND;
				}
				else {
					colMatchState = _DATA_ATTR_VALUE_OUTPUT_COL_MATCH_STATE_OPTIONAL_NOT_FOUND;
				}
			}
			else {
				colMatchState = _DATA_ATTR_VALUE_OUTPUT_COL_MATCH_STATE_MATCH_FOUND;
			}
		}
		$($th).attr(_DATA_ATTR_NAME_OUTPUT_COL_MATCH_STATE, colMatchState);
		$trh.append($th);
	});

	$(dataObj.tblOutputFilePreviewThead).append($trh);

	for (let rowIdx = dataObj.outputDataObj.dataStartIdx; rowIdx < dataObj.outputDataObj.numPreviewRows; rowIdx++) {
		let $trb = $('<tr></tr>');

		$.each(dataObj.outputDataObj.sheetData[rowIdx], function (colIdx, cellVal) {			
			let $td = $('<td>' + cellVal + '</td>');
			$trb.append($td);
		});
		dataObj.tblOutputFilePreviewTbody.append($trb);
	};

	/* Update user mapped fields to show what got mapped and whats left (if any) */

	if (dataObj.opts.manualInputOutputMapping === true) {

		dataObj.userSpecifiedInputOutputMap = new Map();
		_fnSetDataObj($me, dataObj);

		let fileProfileToUse = _fnGetDataProfileToUse(dataObj);
		if (!MBA.ComponentCommon.fnHasValue(fileProfileToUse)) return;

		$.each(fileProfileToUse.fields, function (colIdx, field) {
			dataObj.userSpecifiedInputOutputMap.set(field.name, _VAL_NO_INPUT_COLUMN_SELECTED);
		});

		$(dataObj.tblInputFilePreviewThead).find('select[' + _DATA_ATTR_MAP_TO_INPUT_COL_IDX + ']').val(_VAL_NO_INPUT_COLUMN_SELECTED);
		$(dataObj.tblInputFilePreviewThead).find('select[' + _DATA_ATTR_MAP_TO_INPUT_COL_IDX + '] option').removeAttr('selected');
		$(dataObj.tblInputFilePreviewThead).find('select[' + _DATA_ATTR_MAP_TO_INPUT_COL_IDX + ']').attr(_DATA_ATTR_MAP_TO_OUTPUT_FIELD_NAME, _VAL_NO_INPUT_COLUMN_SELECTED);
		$(dataObj.tblInputFilePreviewThead).find('select[' + _DATA_ATTR_MAP_TO_INPUT_COL_IDX + ']').attr(_DATA_ATTR_NAME_OUTPUT_COL_MATCH_STATE, _DATA_ATTR_VALUE_OUTPUT_COL_MATCH_STATE_NOT_ATTEMPTED);

		dataObj.inputOutputFieldMatches.forEach(function (fieldMatch) {
			if (MBA.ComponentCommon.fnHasValue(fieldMatch.inputFieldIdx) === true) {
				let $sel = $(dataObj.tblInputFilePreviewThead).find('select[' + _DATA_ATTR_MAP_TO_INPUT_COL_IDX + '="' + fieldMatch.inputFieldIdx + '"]')[0];
				$($sel).val(fieldMatch.outputFieldName);
				$($sel).attr(_DATA_ATTR_MAP_TO_OUTPUT_FIELD_NAME, fieldMatch.outputFieldName);
				$($sel).find('option [value="' + fieldMatch.outputFieldName + '"]').attr('selected', 'selected');
				$($sel).attr(_DATA_ATTR_NAME_OUTPUT_COL_MATCH_STATE, _DATA_ATTR_VALUE_OUTPUT_COL_MATCH_STATE_MATCH_FOUND);
				dataObj.userSpecifiedInputOutputMap.set(fieldMatch.outputFieldName, fieldMatch.inputFieldIdx);
			}
		});
		_fnSetDataObj($me, dataObj);
	}
  return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGenerateImportFileJSON
 * @private
 * @summary      Returns reference to data profile in use
 * @description  Returns reference to data profile in use
 * @param  {Object}  $me  Element reference
 */

let _fnGenerateImportFileJSON = function ($me, e) {
    let dataObj = _fnGetDataObj($me);
	$(dataObj.me).val('');
	let importFileObj = {};
	importFileObj.fileProfileID           = dataObj.fileProfileID;
	importFileObj.fileInfo                = dataObj.fileInfo;
	importFileObj.inputDataObj            = dataObj.inputDataObj;
	importFileObj.inputOutputFieldMatches = dataObj.inputOutputFieldMatches;
	importFileObj.outputDataObj           = dataObj.outputDataObj;	

	let importFileJSON = JSON.stringify(importFileObj);
	$(dataObj.me).val(importFileJSON);
	return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnMatchAndGenerateOutput
 * @private
 * @summary      Matches and generates output
 * @description  Matches and generates output
 * @param  {Object}  $me  Element reference
 */

let _fnMatchAndGenerateOutput = function ($me, e) {
	_fnMapInputDataFieldsToOutputDataFields($me, e);
	_fnGenerateOutputDataObj($me, e);
	_fnParseOutputDataObjIntoPreviewHtml($me, e);
	_fnGenerateImportFileJSON($me, e); /*dataObj.fileProfileID*/
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnProcessData
 * @private
 * @summary      Returns reference to data profile in use
 * @description  Returns reference to data profile in use
 * @param  {Object}  $me  Element reference
 */

let _fnProcessData = function ($me, e) {
	_fnParseInputDataObjIntoPreviewHtml($me, e);
	_fnMatchAndGenerateOutput($me,e);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnParseSelectedInputFile
 * @private
 * @summary      Returns reference to data profile in use
 * @description  Returns reference to data profile in use
 * @param  {Object}  $me  Element reference
 */

let	_fnParseSelectedInputFile = function ($me,pfe) {
	_fnInitInputDataObj($me);
	_fnInitOutputDataObj($me);
	let dataObj = _fnGetDataObj($me);
	
	let files = pfe.target.files;
	let file = files[0];
	let fileInfo = {};
	fileInfo.name     = file.name;
	fileInfo.mimeType = file.type;
	fileInfo.size     = file.size;
	dataObj.fileInfo  = fileInfo;	
	_fnSetDataObj($me, dataObj);

	let reader = new FileReader();

	reader.onload = function (rle) {
		_fnParseInputFileIntoInputDataObj($me, rle);
		_fnProcessData($me, rle);
	};	
	reader.readAsArrayBuffer(file);
	return;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnSetDataProfileID
 * @private
 * @summary      Sets data profile in use and also creates string that holds column selections
 * @description  Returns reference to data profile in use
 * @param  {Object}  $me  Element reference
 */

let _fnSetDataProfileID = function ($me, spe) {
	let dataObj = _fnGetDataObj($me);
	dataObj.fileProfileID = $(dataObj.ctrlSelectFileProfile).val();

	if (dataObj.opts.manualInputOutputMapping === true) {
		dataObj.outputColumnSelectionsStr = '';
		if (dataObj.fileProfileID != '') {
			let fileProfileToUse = _fnGetDataProfileToUse(dataObj);
			let outputColumnSelectionsStr = '<option label="Not Mapped To Output" value="' + _VAL_NO_INPUT_COLUMN_SELECTED + '">';
			$.each(fileProfileToUse.fields, function (colIdx, field) {
				let outputColumnSelectionStr = '<option ' + 'label="' + field.label + '"' + 'value="' + field.name + '"' + '>';
				outputColumnSelectionsStr = outputColumnSelectionsStr + outputColumnSelectionStr;
			});
			dataObj.outputColumnSelectionsStr = outputColumnSelectionsStr;
		}
	}
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
	  
  let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);

  dataObj.opts                        = opts;
  dataObj.fileInfo                    = null;
  dataObj.fileProfileID               = '';
  dataObj.inputDataObj                = null;
  dataObj.outputDataObj               = null;
  dataObj.outputColumnSelectionsStr   = '';
  dataObj.userSpecifiedInputOutputMap = new Map();

  /* Add class to element to hide it */

  $($me).addClass(opts.cssClasses.me);

  /* Create container for the element.  This will hold not only the element but the controls we add to support it */

  $($me).wrap('<div></div>');
  let $container = $($me).parent();
  $($container).addClass(opts.cssClasses.layoutContainer);

  /* Create unique ids for the main controls.  This is for linking labels to these */

  let selectFileProfileID = MBA.ComponentCommon.fnCreateNewUUID();
  let selectFileID        = MBA.ComponentCommon.fnCreateNewUUID();
  let inputHeaderRowNumID = MBA.ComponentCommon.fnCreateNewUUID();

  /* Setup file profile selection  */

  let hasDefaultFileProfileSelection = false;
  let $labelSelectFileProfile = $('<label>' + opts.labelSelectFileProfile + '</label>');
  let $ctrlSelectFileProfile  = $('<select></select>');
  $($ctrlSelectFileProfile).addClass(opts.cssClasses.fileProfileSelect);
  $($labelSelectFileProfile).attr('for', selectFileProfileID);
  $($ctrlSelectFileProfile).attr('id', selectFileProfileID);

  $ctrlSelectFileProfile.append('<option value="" label="Select One">');   /* Add empty option */

  /* Add selection options */

  $.each(opts.fileProfiles, function (idx, fileProfile) {
	  let $selOpt = $('<option value="' + fileProfile.id + '" label="' + fileProfile.name + '">');
	  if (opts.defaultFileProfileID == fileProfile.id) {
		  dataObj.fileProfileID = fileProfile.id;
		  $($selOpt).attr('selected', 'selected');
		  hasDefaultFileProfileSelection = true;
	  }
	  $ctrlSelectFileProfile.append($selOpt);
  });

  /* Hide profile selection if requested */

  if (opts.showProfileSelection === false) {
	  $labelSelectFileProfile.addClass(opts.cssClasses.hidden).hide();
	  $ctrlSelectFileProfile.addClass(opts.cssClasses.hidden).hide();
  }

  /* Setup file selection */

  let $labelSelectFile = $('<label>' + opts.labelSelectFile + '</label>');
  let $ctrlInputFileSelect = $('<input type="file" multiple="false">');
  $($ctrlInputFileSelect).addClass(opts.cssClasses.inputDataFileSelect);
  $($labelSelectFile).attr('for', selectFileID);
  $($ctrlInputFileSelect).attr('id', selectFileID);

  /* Setup header row number selection */

  let $labelInputHeaderRowNumber = $('<label>' + opts.labelInputHeaderRowNumber + '</label>');
  let $ctrlInputFileHeaderRowNum = $('<input type="number" min="1" step="1" value="1"/>');
  $($ctrlInputFileHeaderRowNum).addClass(opts.cssClasses.inputDataHeaderRowNumber);
  $($labelInputHeaderRowNumber).attr('for', inputHeaderRowNumID);
  $($ctrlInputFileHeaderRowNum).attr('id', inputHeaderRowNumID);

  /* Setup input/output file preview titles */

  let $hxInputFilePreview  = $('<h4>Input</h4>');
  $($hxInputFilePreview).addClass(opts.cssClasses.inputDataPreviewTitle);

  let $hxOutputFilePreview = $('<h4>Output</h4>');
  $($hxOutputFilePreview).addClass(opts.cssClasses.outputDataPreviewTitle);

  /* Setup input file preview table */

  let $contInputFilePreview     = $('<div></div>');
  let $tblInputFilePreview      = $('<table></table>');
  let $tblInputFilePreviewThead = $('<thead></thead>');
  let $tblInputFilePreviewTbody = $('<tbody></tbody>');

  $($contInputFilePreview).addClass(opts.cssClasses.previewDataContainer);
  $($tblInputFilePreview).addClass(opts.cssClasses.previewDataTable).addClass(opts.cssClasses.inputDataPreviewTable);
  $($tblInputFilePreviewThead).addClass(opts.cssClasses.previewDataTableHead);
  $($tblInputFilePreviewTbody).addClass(opts.cssClasses.previewDataTableBody);

  $($tblInputFilePreview).append($tblInputFilePreviewThead);
  $($tblInputFilePreview).append($tblInputFilePreviewTbody);
  $($contInputFilePreview).append($tblInputFilePreview);

  /* Setup output file preview table */

  let $contOuputFilePreview      = $('<div></div>');
  let $tblOuputFilePreview       = $('<table></table>');
  let $tblOutputFilePreviewThead = $('<thead></thead>');
  let $tblOutputFilePreviewTbody = $('<tbody></tbody>');

  $($contOuputFilePreview).addClass(opts.cssClasses.previewDataContainer);
  $($tblOuputFilePreview).addClass(opts.cssClasses.previewDataTable).addClass(opts.cssClasses.outputDataPreviewTable);
  $($tblOutputFilePreviewThead).addClass(opts.cssClasses.previewDataTableHead);
  $($tblOutputFilePreviewTbody).addClass(opts.cssClasses.previewDataTableBody);

  $($tblOuputFilePreview).append($tblOutputFilePreviewThead);
  $($tblOuputFilePreview).append($tblOutputFilePreviewTbody);
  $($contOuputFilePreview).append($tblOuputFilePreview);

  /* Setup inner structure for control */

  /* Row 1 for controls */

  let $row1 = $('<div></div>');
  $($row1).addClass(opts.cssClasses.layoutRow);
  let $row1Col1 = $('<section></section>');
  $($row1Col1).addClass(opts.cssClasses.col);
  let $row1Col2 = $('<section></section>');
  $($row1Col2).addClass(opts.cssClasses.layoutCol);
  let $row1Col3 = $('<section></section>');
  $($row1Col3).addClass(opts.cssClasses.layoutCol);

  /* Row 2 for input data preview and info on input file */
	
  let $row2 = $('<div></div>');
  $($row2).addClass(opts.cssClasses.layoutRow);

  let $row2Col1 = $('<section></section>');
   $($row2Col1).addClass(opts.cssClasses.layoutCol);

  let $row2Col2 = $('<section></section>');
  $($row2Col2).addClass(opts.cssClasses.layoutCol);

  /* Row 3 for output data preview and info on output data and matching */

  let $row3 = $('<div></div>');
  $($row3).addClass(opts.cssClasses.layoutRow);
  let $row3Col1 = $('<section></section>');
  $($row3Col1).addClass(opts.cssClasses.layoutCol);
  let $row3Col2 = $('<section></section>');
  $($row3Col2).addClass(opts.cssClasses.layoutCol);

  /* Add our markup */

  $($row1Col1).append($labelSelectFileProfile);
  $($row1Col1).append($ctrlSelectFileProfile);

  $($row1Col2).append($labelSelectFile);
  $($row1Col2).append($ctrlInputFileSelect);

  $($row1Col3).append($labelInputHeaderRowNumber);
  $($row1Col3).append($ctrlInputFileHeaderRowNum);

  $($row1).append($row1Col1);
  $($row1).append($row1Col2);
  $($row1).append($row1Col3);
	
  $($row2Col1).append($hxInputFilePreview);
  $($row2Col2).append($contInputFilePreview);

  $($row2).append($row2Col1);
  $($row2).append($row2Col2);

  $($row3Col1).append($hxOutputFilePreview);

  $($row3Col2).append($contOuputFilePreview);
  $($row3).append($row3Col1);
  $($row3).append($row3Col2);

  $($container).append($row1);
  $($container).append($row2);
  $($container).append($row3);

  /* Save references to key elements and values */

  dataObj.container                  = $container;
  dataObj.ctrlSelectFileProfile      = $ctrlSelectFileProfile;
  dataObj.ctrlInputFileSelect        = $ctrlInputFileSelect;
  dataObj.ctrlInputFileHeaderRowNum  = $ctrlInputFileHeaderRowNum;
  dataObj.tblInputFilePreviewThead   = $tblInputFilePreviewThead;
  dataObj.tblInputFilePreviewTbody   = $tblInputFilePreviewTbody;
  dataObj.tblOutputFilePreviewThead  = $tblOutputFilePreviewThead;
  dataObj.tblOutputFilePreviewTbody  = $tblOutputFilePreviewTbody;

  /* Save our data object.  This will be used for option calls */

  $($me).data(_JQ_DATA_NAME, dataObj);

  /* Wire up events*/

  $($ctrlSelectFileProfile).on('change', function (e) {
	  _fnSetDataProfileID($me, e);
	  _fnProcessData($me, e);	  
  });

  $($ctrlInputFileSelect).on('change', function (e) {
	_fnParseSelectedInputFile($me, e);
  });

  $($ctrlInputFileHeaderRowNum).on('change', function (e) {
    _fnProcessData($me, e);	
  });

  /* Init */

  _fnInitInputDataObj($me);
  _fnInitOutputDataObj($me);

  /* If a default profile selection has been provided then setup the profile and process data (same functions called if the
   * change event was fired on the selection control itself */

  if (hasDefaultFileProfileSelection === true) {
	  _fnSetDataProfileID($me, null);
	  _fnProcessData($me, null);
  }

 
};
	
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

return {
	PLUGIN_NAME: _PLUGIN_NAME
  , fnCreate:  _fnCreate
  , fnDestroy: _fnDestroy
  , fnGetDataObj: _fnGetDataObj
  , fnSetDataObj: _fnSetDataObj
  
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
	
$.fn.MBA_StructuredDataFilesImport = function (methodOrOptions, optionsOrValue) { 
      
/* These are the supported methods and properties that can be accessed from outside after an instance is created */	
	
let _methods = {
    
	getDataObj: function (elem) { return MBA.StructuredDataFilesImportCommon.fnGetDataObj(elem); }
  , setDataObj: function (elem, value) { return MBA.StructuredDataFilesImportCommon.fnSetDataObj(elem, value); }

};
	  	  
let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

/* Method is create */
	  
if ( typeof methodOrOptions === 'object' || !methodOrOptions )
{
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
	let elem = this; /* this in this scope is a reference to one of elements in the set */
	return MBA.StructuredDataFilesImportCommon.fnCreate  (elem, methodOrOptions);
  });
} 
	  
/* Method is destroy */
	  
else if ( methodOrOptions == 'destroy' )
{			
  /* Tie into return chain so this can be chained with other methods */
  return this.each ( function() {
    let elem = this; /* this in this scope is a reference to one of elements in the set */
    return MBA.StructuredDataFilesImportCommon.fnDestroy (elem);
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
  else if (numOf > 1) { throw new Error(MBA.StructuredDataFilesImportCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied to a set of elements at once.' );}
  /* No elements found */
  else                { throw new Error(MBA.StructuredDataFilesImportCommon.PLUGIN_NAME + ' ' +  methodOrOptions + ' cannot be applied since the element was not found.');}
} 

/* Cant find the method */
	  
else 
{
  throw new Error(MBA.StructuredDataFilesImportCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method' );
}        
	
}; /* MBA_StructuredDataFilesImport */

})( jQuery );
