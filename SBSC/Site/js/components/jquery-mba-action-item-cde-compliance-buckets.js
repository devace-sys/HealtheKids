; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ActionItemCdeComplianceBucketsCommon
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery, Bootstrap, MBA.ComponentCommon
 */

MBA.ActionItemCdeComplianceBucketsCommon = (function ($) {

	'use strict';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _PLUGIN_NAME     = 'MBA Action Item CDE Compliance Buckets';
	const _PLUGIN_NS       = 'mba-action-item-cde-compliance-buckets';
	const _JQ_DATA_NAME    = 'jq-' + _PLUGIN_NS;
	const _CONT_SUB_CLASS  = MBA.ActionItemCommon.PLUGIN_COMMON  + '-container';
	const _LABEL_SUB_CLASS = MBA.ActionItemCommon.PLUGIN_COMMON + '-label';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _CSS_CLASSES = {
		  container:  _PLUGIN_NS + ' ' + _CONT_SUB_CLASS
		, label:      _PLUGIN_NS + ' ' + _LABEL_SUB_CLASS
		, table:      _PLUGIN_NS + '-buckets-table' + ' table table-sm'
		, bucketCol:  _PLUGIN_NS + '-bucket-col'
		, bucketCell: _PLUGIN_NS + '-bucket-cell'
		, bucketsRowLabel:     _PLUGIN_NS + '-buckets-row-label align-middle text-right'
		, bucketsRowDateStart: _PLUGIN_NS + '-buckets-row-date-start'
		, bucketsRowDateEnd:   _PLUGIN_NS + '-buckets-row-date-end'
		, bucketA: _PLUGIN_NS  + '-bucket-a text-center'
		, bucketB: _PLUGIN_NS  + '-bucket-b text-center'
		, bucketC: _PLUGIN_NS  + '-bucket-c text-center'
		, totPats: _PLUGIN_NS  + '-tot-pats text-center'
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _DEFAULT_OPTIONS = {
		  cssClasses: _CSS_CLASSES
		, label: 'CDE Success Buckets'
		, showCurrYear:true
		, showCurrAudit:true
		, rowLabelCurrAudit:''
		, rowLabelCurrYear:''
		, colLabelBucketLabelA:''
		, colLabelBucketLabelB:''
		, colLabelBucketLabelC:''
        , colLabelTotPatsLabel:''	
		, requestDataParameters: null
	    , requestDataUrlCurrYearBase:''
		, requestDataUrlCurrAuditBase: ''
		, fnBeforeLoadCurrentYearBucketData: function (reqDataJSON) { }
		, fnAfterLoadCurrentYearBucketData: function (responseData) { }
		, fnBeforeLoadCurrentAuditBucketData: function (reqDataJSON) { }
		, fnAfterLoadCurrentAuditBucketData: function (responseData) { }
		, bucketColors: {
			fillColorA: '#ffffff'
		  , fillColorB: '#ffffff'
		  , fillColorC: '#ffffff'
		  , fillColorTotPats: '#ffffff'
		  , strokeColorA: '#28a745'
		  , strokeColorB: '#ffc107'
		  , strokeColorC: '#dc3545'
		  , strokeColorTotPats: '#6c757d'
		}
		, useActionItemClassForCont: true
		, useActionItemClassForLabel: true

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
	
	/*---------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGenerateBucketContent
	 * @private
	 * @summary      Generates bucket content
	 * @description  Generates bucket content
	 * @param  {String}  fillColor  color in hex to use for fill
	 */

	let _fnGenerateBucketContent = function (bucketTotal, fillColor, strokeColor) {

		let svgMkup = '<svg width="79.737999" height="95.434517" fill="' + fillColor + '" stroke="' + strokeColor + '">'
		    + '<path d="m 2,35.145841 a 37.869,32 0 1 1 75.738,0 l -7.1005,52 a 33.135,10 0 0 1 -61.537,0 z m 0,0 a 37.869,6 0 0 0 75.738,0 37.869,6 0 0 0 -75.738,0" stroke-width="4" />'
			+ '<rect x="31.755079" y="1" width="18.177999" height="6.5818696" stroke-width="2" />'
			+ '<text x="40.755079" y="71.690453" stroke-width="1" text-anchor="middle" alignment-baseline="middle">' + bucketTotal + '</text>'
		    + '</svg>';

		return svgMkup;
				
    }
	/*---------------------------------------------------------------------------------------------------------------------------------*/

    /**
	 * @function     _fnUpdateRow
	 * @private
	 * @summary      Updates content of row cells with row data
	 * @description  Updates content of row cells with row data
	 * @param  {Object}  rowCells  References to row cells
	 * @param  {Object}  rowData   Contains row data
	 */

	let _fnUpdateRow = function (bucketColors, rowCells, rowData) {
        $(rowCells.startDate).html(rowData.startDateStr);
		$(rowCells.endDate).html(rowData.endDateStr);
		$(rowCells.bucketA).html(_fnGenerateBucketContent(rowData.patsInBucketA, bucketColors.fillColorA, bucketColors.strokeColorA));
		$(rowCells.bucketB).html(_fnGenerateBucketContent(rowData.patsInBucketB, bucketColors.fillColorB, bucketColors.strokeColorB) );
		$(rowCells.bucketC).html(_fnGenerateBucketContent(rowData.patsInBucketC, bucketColors.fillColorC, bucketColors.strokeColorC) );
		$(rowCells.totPats).html(_fnGenerateBucketContent(rowData.totalPats, bucketColors.fillColorTotPats, bucketColors.strokeColorTotPats) );
    };
	
	/*---------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGenerateEmptyBucketsObj
	 * @private
	 * @summary      Generates empty bucket object for init or if no bucket data is returned
	 * @description  Generates empty bucket object for init or if no bucket data is returned
	 */

	let _fnGenerateEmptyBucketsObj = function () {
		let emptyBucketsObj = {};
		emptyBucketsObj.startDateStr  = '';
		emptyBucketsObj.endDateStr    = 'No data available';
		emptyBucketsObj.patsInBucketA = 0;
		emptyBucketsObj.patsInBucketB = 0;
		emptyBucketsObj.patsInBucketC = 0;
		emptyBucketsObj.totalPats     = 0;
		return emptyBucketsObj;
	};

	/*---------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnLoadCurrentAuditPeriodBucketData
	 * @private
	 * @summary      Loads bucket data for current audit period
	 * @description  Loads bucket data for current audit period
	 * @param  {Object}  dataObj      Shared data object
	 * @param  {Object}  reqDataJSON  JSON containing additional parms
	 */

    let _fnLoadCurrentAuditPeriodBucketData = function (dataObj,reqDataJSON) {

		dataObj.opts.fnBeforeLoadCurrentAuditBucketData(reqDataJSON);
		$(dataObj.rowCellCurrAuditDataLoading).show();

		MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.requestDataUrlCurrAuditBase, reqDataJSON, null)
            .then(responseData => {
                let patientsPromisedServicesCDEAuditCurrent = responseData.rawData.entity;
				if (MBA.ComponentCommon.fnHasValue(patientsPromisedServicesCDEAuditCurrent)) {
					_fnUpdateRow(dataObj.opts.bucketColors, dataObj.rowCellsCurrAudit, patientsPromisedServicesCDEAuditCurrent);
				}
				else {
					_fnUpdateRow(dataObj.opts.bucketColors, dataObj.rowCellsCurrAudit, _fnGenerateEmptyBucketsObj());
                }
				$(dataObj.rowCellCurrAuditDataLoading).hide();
				dataObj.opts.fnAfterLoadCurrentAuditBucketData(responseData);
			})
            .catch(responseData => {
				$(dataObj.rowCellCurrAuditDataLoading).hide();
				dataObj.opts.fnAfterLoadCurrentAuditBucketData(responseData);
            });
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/
    
	/**
	 * @function     _fnLoadCurrentYearBucketData
	 * @private
	 * @summary      Loads bucket data for current year
	 * @description  Loads bucket data for current year
	 * @param  {Object}  dataObj      Shared data object
	 * @param  {Object}  reqDataJSON  JSON containing additional parms
	 */
    
	let _fnLoadCurrentYearBucketData = function (dataObj,reqDataJSON) {

		dataObj.opts.fnBeforeLoadCurrentYearBucketData(reqDataJSON);
		$(dataObj.rowCellCurrYearDataLoading).show();

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.requestDataUrlCurrYearBase, reqDataJSON, null)
            .then(responseData => {
                let patientsPromisedServicesCDECurrYear = responseData.rawData.entity;
				if (MBA.ComponentCommon.fnHasValue(patientsPromisedServicesCDECurrYear)) {
					_fnUpdateRow(dataObj.opts.bucketColors, dataObj.rowCellsCurrYear, patientsPromisedServicesCDECurrYear);
				}
				else {					
					_fnUpdateRow(dataObj.opts.bucketColors, dataObj.rowCellsCurrYear, _fnGenerateEmptyBucketsObj());
                }
				$(dataObj.rowCellCurrYearDataLoading).hide();
				dataObj.opts.fnAfterLoadCurrentYearBucketData(responseData);
			})
            .catch(responseData => {
				$(dataObj.rowCellCurrYearDataLoading).hide();
				dataObj.opts.fnAfterLoadCurrentYearBucketData(responseData);
            });
    };
    
	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnClearBucketCounts
	 * @private
	 * @summary      Clear bucket counters
	 * @description  Clear bucket counters
	 * @param  {Object}  dataObj  Data object
	 */

	let _fnClearBucketCounts = function (dataObj) {
		if (dataObj.opts.showCurrAudit === true) _fnUpdateRow(dataObj.opts.bucketColors, dataObj.rowCellsCurrAudit, _fnGenerateEmptyBucketsObj());
		if (dataObj.opts.showCurrYear  === true) _fnUpdateRow(dataObj.opts.bucketColors, dataObj.rowCellsCurrYear,  _fnGenerateEmptyBucketsObj());
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGetData
	 * @private
	 * @summary      Get bucket data from server
	 * @description  Get bucket data from server
	 * @param  {Object}  elem  Element reference
	 */

	let _fnGetData = function (elem) {
	
	  let $me      = _fnGetMe(elem);
	  let dataObj  = _fnGetDataObj($me);
	  _fnClearBucketCounts(dataObj);
      let reqDataJSON = MBA.ComponentCommon.fnJSONFromMapKeysValues(dataObj.opts.requestDataParameters);
      if (dataObj.opts.showCurrAudit === true) _fnLoadCurrentAuditPeriodBucketData(dataObj,reqDataJSON);
	  if (dataObj.opts.showCurrYear  === true) _fnLoadCurrentYearBucketData(dataObj,reqDataJSON);

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
		return $(elem).is('section');
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

		/* Init map used for request data parameters */
		
		opts.requestDataParameter = new Map();
		
		/* Me is container */

		$($me).addClass(opts.cssClasses.container);

		/* Create label */

		let $label = $('<h3></h3>');
		$($label).html(opts.label);
		$($label).addClass(opts.cssClasses.label);
        $($me).append($label);

		if (opts.useActionItemClassForCont === false) {
			$($me).removeClass(_CONT_SUB_CLASS);
		}

		if (opts.useActionItemClassForLabel === false) {
			$($me).removeClass(_LABEL_SUB_CLASS);
		}

		
		/* Create table head - Column Labels Row */
		
		let $theadRowColLabels     = $('<tr></tr>');


		let $theadColLabel         = $('<th></th>');

		let $theadColBucketA       = $('<th>' + opts.colLabelBucketLabelA + '</th>');
        let $theadColBucketB       = $('<th>' + opts.colLabelBucketLabelB + '</th>')
        let $theadColBucketC       = $('<th>' + opts.colLabelBucketLabelC + '</th>');
        let $theadColBucketTotPats = $('<th>' + opts.colLabelTotPatsLabel + '</th>');
        
		$($theadRowColLabels).append($theadColLabel);

		$($theadRowColLabels).append($theadColBucketA);
		$($theadRowColLabels).append($theadColBucketB);
		$($theadRowColLabels).append($theadColBucketC);
		$($theadRowColLabels).append($theadColBucketTotPats);
		
		$($theadColBucketA).addClass(opts.cssClasses.bucketCol).addClass(opts.cssClasses.bucketA);
		$($theadColBucketB).addClass(opts.cssClasses.bucketCol).addClass(opts.cssClasses.bucketB);
		$($theadColBucketC).addClass(opts.cssClasses.bucketCol).addClass(opts.cssClasses.bucketC);
		$($theadColBucketTotPats).addClass(opts.cssClasses.bucketCol).addClass(opts.cssClasses.totPats);
		
        /* Create table head */

		let $thead  = $('<thead></thead>');
		$($thead).append($theadRowColLabels);
				
		/* Create table body - Current audit row */
		
		let $tbodyRowCurrAudit           = $('<tr></tr>');
		let rowCellsCurrAudit            = {};
		let $rowCellCurrAuditRowLabel    = $('<th></th>');
		let $rowCellCurrAuditDataLoading = $('<div class="alert alert-success">Calculating Please Wait <i class= "fa fa-spinner fa-spin"></i></div>');

		$($rowCellCurrAuditRowLabel).addClass(opts.cssClasses.bucketsRowLabel);
		rowCellsCurrAudit.startDate = $('<span></span>');
		$(rowCellsCurrAudit.startDate).addClass(opts.cssClasses.bucketsRowDateStart);
		rowCellsCurrAudit.endDate = $('<span></span>');
	    $(rowCellsCurrAudit.endDate).addClass(opts.cssClasses.bucketsRowDateEnd);

		$($rowCellCurrAuditRowLabel).append(opts.rowLabelCurrAudit);
		$($rowCellCurrAuditRowLabel).append(rowCellsCurrAudit.startDate);
		$($rowCellCurrAuditRowLabel).append(' - ');
		$($rowCellCurrAuditRowLabel).append(rowCellsCurrAudit.endDate);
		$($rowCellCurrAuditRowLabel).append($rowCellCurrAuditDataLoading);

		rowCellsCurrAudit.bucketA = $('<td></td>');
		rowCellsCurrAudit.bucketB = $('<td></td>');
		rowCellsCurrAudit.bucketC = $('<td></td>');
		rowCellsCurrAudit.totPats = $('<td></td>');

		$(rowCellsCurrAudit.bucketA).addClass(opts.cssClasses.bucketCell).addClass(opts.cssClasses.bucketA);
		$(rowCellsCurrAudit.bucketB).addClass(opts.cssClasses.bucketCell).addClass(opts.cssClasses.bucketB);
		$(rowCellsCurrAudit.bucketC).addClass(opts.cssClasses.bucketCell).addClass(opts.cssClasses.bucketC);
		$(rowCellsCurrAudit.totPats).addClass(opts.cssClasses.bucketCell).addClass(opts.cssClasses.totPats);

		$($tbodyRowCurrAudit).append($rowCellCurrAuditRowLabel);
        $($tbodyRowCurrAudit).append(rowCellsCurrAudit.bucketA);
		$($tbodyRowCurrAudit).append(rowCellsCurrAudit.bucketB);
		$($tbodyRowCurrAudit).append(rowCellsCurrAudit.bucketC);
		$($tbodyRowCurrAudit).append(rowCellsCurrAudit.totPats);
		
	    /* Create table body - Current year row */
		
		let $tbodyRowCurrYear = $('<tr></tr>');
	    let rowCellsCurrYear = {};
		let $rowCellCurrYearRowLabel = $('<th></th>');
		let $rowCellCurrYearDataLoading = $('<div class="alert alert-success">Calculating Please Wait <i class= "fa fa-spinner fa-spin" ></i></div>');

		$($rowCellCurrYearRowLabel).addClass(opts.cssClasses.bucketsRowLabel);
		rowCellsCurrYear.startDate = $('<span></span>');
		$(rowCellsCurrYear.startDate).addClass(opts.cssClasses.bucketsRowDateStart);
        rowCellsCurrYear.endDate   = $('<span></span>');
		$(rowCellsCurrYear.endDate).addClass(opts.cssClasses.bucketsRowDateEnd);
		$($rowCellCurrYearRowLabel).append(opts.rowLabelCurrYear);
		$($rowCellCurrYearRowLabel).append(rowCellsCurrYear.startDate);
		$($rowCellCurrYearRowLabel).append(' - ');
		$($rowCellCurrYearRowLabel).append(rowCellsCurrYear.endDate);
		$($rowCellCurrYearRowLabel).append($rowCellCurrYearDataLoading);

		rowCellsCurrYear.bucketA = $('<td></td>');
		rowCellsCurrYear.bucketB = $('<td></td>');
		rowCellsCurrYear.bucketC = $('<td></td>');
		rowCellsCurrYear.totPats = $('<td></td>');
		
		$(rowCellsCurrYear.bucketA).addClass(opts.cssClasses.bucketCell).addClass(opts.cssClasses.bucketA);
		$(rowCellsCurrYear.bucketB).addClass(opts.cssClasses.bucketCell).addClass(opts.cssClasses.bucketB);
		$(rowCellsCurrYear.bucketC).addClass(opts.cssClasses.bucketCell).addClass(opts.cssClasses.bucketC);
		$(rowCellsCurrYear.totPats).addClass(opts.cssClasses.bucketCell).addClass(opts.cssClasses.totPats);

		$($tbodyRowCurrYear).append($rowCellCurrYearRowLabel);
        $($tbodyRowCurrYear).append(rowCellsCurrYear.bucketA);
		$($tbodyRowCurrYear).append(rowCellsCurrYear.bucketB);
		$($tbodyRowCurrYear).append(rowCellsCurrYear.bucketC);
		$($tbodyRowCurrYear).append(rowCellsCurrYear.totPats);
 		
		/* Create table body */

		let $tbody = $('<tbody></tbody>');

		if (opts.showCurrAudit === true) $($tbody).append($tbodyRowCurrAudit);
		if (opts.showCurrYear  === true) $($tbody).append($tbodyRowCurrYear);
		
        /* Create table */
		
		let $table = $('<table></table>');
		$($table).addClass(opts.cssClasses.table);		
		$($table).append($thead);
		$($table).append($tbody);
		$($me).append($table);
		
		/* Save references */
		
		dataObj.label                       = $label;
		dataObj.table                       = $table;
		dataObj.thead                       = $thead;
		dataObj.tbody                       = $tbody;
		dataObj.tbodyRowCurrAudit           = $tbodyRowCurrAudit;
		dataObj.tbodyRowCurrYear            = $tbodyRowCurrYear;
		dataObj.rowCellsCurrAudit           = rowCellsCurrAudit;
		dataObj.rowCellsCurrYear            = rowCellsCurrYear;
		dataObj.rowCellCurrAuditDataLoading = $rowCellCurrAuditDataLoading;
		dataObj.rowCellCurrYearDataLoading  = $rowCellCurrYearDataLoading;
		dataObj.opts                        = opts;
        
		$(dataObj.rowCellCurrAuditDataLoading).hide();
		$(dataObj.rowCellCurrYearDataLoading).hide();

		/* Save our data object.  This will be used for option calls */

		$($me).data(_JQ_DATA_NAME, dataObj);

		/* Init */

		_fnClearBucketCounts(dataObj);
		
      }

	
	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	return {
		  PLUGIN_NAME: _PLUGIN_NAME
		, fnCreate: _fnCreate
		, fnDestroy: _fnDestroy
	    , fnRequestDataParameterSetOrUpdate: _fnRequestDataParameterSetOrUpdate 		
		, fnGetData: _fnGetData		
	};

})(jQuery);


/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      CDE Compliance Buckets
 * @description  CDE Compliance Buckets
 * @requires     jQuery
 */

; (function ($) {

	'use strict';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/* Tie into jQuery namespace */

	$.fn.MBA_ActionItemCdeComplianceBuckets = function (methodOrOptions, optionsOrValue) {

		/* These are the supported methods and properties that can be accessed from outside after an instance is created */

		let _methods = {
			
			getData: function (elem) {
			  return MBA.ActionItemCdeComplianceBucketsCommon.fnGetData(elem);
			} 
			, requestDataParameterSetOrUpdate: function (elem, value) {
				return MBA.ActionItemCdeComplianceBucketsCommon.fnRequestDataParameterSetOrUpdate(elem, value);
			} 
		};

		let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

		/* Method is create */

		if (typeof methodOrOptions === 'object' || !methodOrOptions) {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.ActionItemCdeComplianceBucketsCommon.fnCreate(elem, methodOrOptions);
			});
		}

		/* Method is destroy */

		else if (methodOrOptions == 'destroy') {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.ActionItemCdeComplianceBucketsCommon.fnDestroy(elem);
			});
		}

		/* Other methods (these cannot be chained) */

		else if (_methods[methodOrOptions]) {
			if (numOf == 1) {
				let elem = this[0]; /* There is only one element matched so we can proceed */
				return _methods[methodOrOptions](elem, optionsOrValue);
			}

			/* More than one element matched.  We cannot apply */
			else if (numOf > 1) { throw new Error(MBA.ActionItemCdeComplianceBucketsCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' cannot be applied to a set of elements at once.'); }
			/* No elements found */
			else { throw new Error(MBA.ActionItemCdeComplianceBucketsCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' cannot be applied since the element was not found.'); }
		}

		/* Cant find the method */

		else {
			throw new Error(MBA.ActionItemCdeComplianceBucketsCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method');
		}

	}; /* MBA_ActionItemCdeComplianceBuckets */

})(jQuery);
