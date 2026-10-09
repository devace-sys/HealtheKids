; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ActionItemProgressBarChartCommon
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery, Bootstrap, MBA.ComponentCommon
 */

MBA.ActionItemProgressBarChartCommon = (function ($) {

	'use strict';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _PLUGIN_NAME  = 'MBA Action Item Progress Bar Chart';
	const _PLUGIN_NS    = 'mba-action-item-progress-bar-chart';
	const _JQ_DATA_NAME = 'jq-' + _PLUGIN_NS;

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const CONST_ATTR_NAME_FOR_HAS_ACTION_URL = 'data-' + _PLUGIN_NS + '-has-action-url';
	const CONST_ATTR_NAME_FOR_ACTION_URL     = 'data-' + _PLUGIN_NS + '-action-url';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _CSS_CLASS_USING_TIPSO = 'using-tipso';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _CSS_CLASSES = {
		  container: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-container'
		, containerNoPadding: MBA.ActionItemCommon.PLUGIN_COMMON + '-container-no-padding'
		, containerNoBoxShadow: MBA.ActionItemCommon.PLUGIN_COMMON + '-container-no-box-shadow'
		, containerNoBorder: MBA.ActionItemCommon.PLUGIN_COMMON + '-container-no-border'
		, header: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-header' + ' d-flex'
		, label: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-label' + ' flex-grow-1'
		, instructions: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-instructions' + ' fa fa-info-circle'
		, status: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-status'
		, spinner: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-spinner' + ' fa fa-spinner fa-pulse fa-3x fa-fw m-auto'
		, meter: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-meter' + ' ' + _PLUGIN_NS + '-meter'
		, hidden: MBA.ActionItemCommon.PLUGIN_COMMON + '-hidden-fully'
		, chartSmall: _PLUGIN_NS + '-small'
		, chartTable: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-chart-table'
		, chartHead: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-chart-head'
		, chartBody: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-chart-body'
		, chartRow: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-chart-row'
		, chartCol: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-chart-col'
		, chartColText: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-chart-col-text'
		, chartCell: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-chart-cell'
		, chartCellOrColPctWidth: _PLUGIN_NS + '-chart-cell-or-col-pct-width'		
		, chartCellOrColProgressLabel: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-chart-cell-or-col-progress-label'
		, chartCellOrColProgressBar: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-chart-cell-or-col-progress-bar'
		, chartCellOrColProgressPercent: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-chart-cell-or-col-progress-percent'
		, progressLabel: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-progress-label'
		, progressBar: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-progress-bar'
		, progressPercent: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-progress-percent'
		, actionItemCommonContentWrapper:'mba-action-item-content-wrapper'
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _DEFAULT_OPTIONS = {
		  cssClasses: _CSS_CLASSES
		, label: ''
		, requestDataUrlBase: ''
		, requestDataParameters: null
		, requestDataFieldNames: []
		, urlSessionExpiredLink: ''
		, actionURL: ''
		, additionalContent: ''
		, instructionsEnabled: false
		, instructionsContent: ''
		, instructionsPosition: 'bottom'
		, autoSetUpdateRequestDataParametersFromRequestDataFieldNames: true
		, subTitleProgressLabel: 'Item Being Tracked'
		, subTitleProgressBar: 'Current Progress'
		, showHeader: true
		, hideStatusSectionWhenNotInUse:false
		, renderChartHeader: false
		, progressDataHasActionURL: false
		, actionURLOpenWindow:true
		, bootStrapTable: true
		, bootStrapBorderlessTable: false
		, tbodyRowIsActionURLTarget:false
		, containerNoPadding: false
		, containerNoBoxShadow: false
		, containerNoBorder: false
		, useChartCellOrColPctWidth: true
		, useChartSmall:false
		, fnGenerateProgressLabelTitleAttributeText:   function (progressDataObj) { return ''; }
		, fnGenerateProgressBarTitleAttributeText:     function (progressDataObj) { return ''; }
		, fnGenerateProgressPercentTitleAttributeText: function (progressDataObj) { return ''; }
		, fnOnRequestProgressDataFromServerSuccess: function (responseData) { return; }
		, fnOnRequestProgressDataFromServerFail: function (responseData) { return; }
		
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
	 * @function     _fnIsElemSupported
	 * @private
	 * @summary      Is the element we are enhancing supported by the plugin
	 * @description  Is the element we are enhancing supported by the plugin
	 * @param  {Object}  elem  Element reference
	 */

	let _fnIsElemSupported = function (elem) {
		return $(elem).is('div');
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGenerateProgressDataObjsFromTotalNumAmts
	 * @private
	 * @summary      Renders progress bar chart
	 * @param  {Object}  elem  Element reference
	 */

	let _fnGenerateProgressDataObjsFromTotalNumAmts = function (responseData) {
		let progressDataObjs = [];
		$.each(responseData.rawData.totalNumAmts, function (idx, amtObj) {
			let progressDataObj = {};
			progressDataObj.label           = amtObj.label;
			progressDataObj.value           = amtObj.totalNumVal;
			progressDataObj.additionalData1 = amtObj.additionalData1;
			progressDataObj.additionalData2 = amtObj.additionalData2;
			progressDataObj.additionalData3 = amtObj.additionalData3;
			progressDataObj.additionalData4 = amtObj.additionalData4;
			progressDataObj.actionURL       = amtObj.actionURL;
			progressDataObjs.push(progressDataObj);
		});
		return progressDataObjs;
	}

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
		return _fnRequestDataParameterSetOrUpdate(elem, nvo);
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
	 * @function     _fnRequestProgressDataFromServer
	 * @private
	 * @summary      Renders progress bar chart
	 * @param  {Object}  elem  Element reference
	 */

	let _fnRequestProgressDataFromServer = function (elem) {

		return new Promise((resolve, reject) => {

			let $me = _fnGetMe(elem);
			let dataObj = _fnGetDataObj($me);
			if (dataObj.opts.hideStatusSectionWhenNotInUse === true) $(dataObj.status).removeClass(dataObj.opts.cssClasses.hidden);
			$(dataObj.spinner).removeClass(dataObj.opts.cssClasses.hidden);
			_fnUpdateRequestParametersFromFieldNames(elem).then(retState => {

				let reqDataJSON = MBA.ComponentCommon.fnJSONFromMapKeysValues(dataObj.opts.requestDataParameters);
				let progressDataObjs = [];

				MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.requestDataUrlBase, reqDataJSON, dataObj.opts.urlSessionExpiredLink)
					.then(responseData => {
						dataObj.opts.fnOnRequestProgressDataFromServerSuccess(responseData);
						progressDataObjs = _fnGenerateProgressDataObjsFromTotalNumAmts(responseData);
						if (dataObj.opts.hideStatusSectionWhenNotInUse === true) $(dataObj.status).addClass(dataObj.opts.cssClasses.hidden);
						$(dataObj.spinner).addClass(dataObj.opts.cssClasses.hidden);
						resolve(progressDataObjs);
					})
					.catch(responseData => {
						dataObj.opts.fnOnRequestProgressDataFromServerFail(responseData);
						if (dataObj.opts.hideStatusSectionWhenNotInUse === true) $(dataObj.status).addClass(dataObj.opts.cssClasses.hidden);
						$(dataObj.spinner).addClass(dataObj.opts.cssClasses.hidden);
						reject(progressDataObjs);
					}); /* fnAjax */
			}); /* reqParmsFromFieldName*/
		});
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRemoveToolTipArtifactHack
	 * @private
	 * @summary      Removes tipso rendered content.  Does not destroy tooltip.	 
	 */

	let _fnRemoveToolTipArtifactHack = function () {		
		$('body').find('div.tipso_bubble').remove();
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnCreateToolTip
	 * @private
	 * @summary      Generates tool tip hover code
	 * @param  {Object}  chartPart  Chart part reference
	 */

	let _fnCreateToolTip = function (chartPart) {
		$(chartPart).addClass(_CSS_CLASS_USING_TIPSO);

		/*$(chartPart).tipso({
			  useTitle: true
			, background: '#55b555'
			, color: '#ffffff'
		});
		$(chartPart).removeClass('tipso_style');*/
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnPlotChart
	 * @private
	 * @summary      Renders progress bar chart
	 * @param  {Object}  elem  Element reference
	 */

	let _fnPlotChart = function (elem, progressDataObjs) {

		return new Promise((resolve, reject) => {

		  let $me = _fnGetMe(elem);
		  let dataObj = _fnGetDataObj($me);
		  let opts = dataObj.opts;
		  $($me).html('');
		  _fnRemoveToolTipArtifactHack();

		  /* Create chart */

		  let $chart = $('<table></table>');
		  /* Bootstrap table options */
		  if (opts.bootStrapTable === true) {
		     $($chart).addClass('table'); 
			 if (opts.bootStrapBorderlessTable === true) $($chart).addClass('table-borderless');			
		  }
		  $($chart).addClass(opts.cssClasses.chartTable);

		  /* Create chart head */

			if (opts.renderChartHeader === true) {
				let $chartHead = $('<thead></thead>');
				$($chartHead).addClass(opts.cssClasses.chartHead);

				/* Header row */

				let $chartHeadRow = $('<tr></tr>');
				$chartHeadRow.addClass(opts.cssClasses.chartRow);

				/* Label */

				let $colLabel = $('<th></th>');
				$colLabel.addClass(opts.cssClasses.chartCol);
				$colLabel.addClass(opts.cssClasses.chartCellOrColProgressLabel);
				if (opts.useChartCellOrColPctWidth === true) $colLabel.addClass(opts.cssClasses.chartCellOrColPctWidth);
				if (opts.useChartSmall === true) $colLabel.addClass(opts.cssClasses.chartSmall);
				let $colLabelText = $('<span></span>');
				$colLabelText.addClass(opts.cssClasses.chartColText);
				if (opts.useChartSmall === true) $colLabelText.addClass(opts.cssClasses.chartSmall);
				$colLabelText.html(opts.subTitleProgressLabel);
				$($colLabel).append($colLabelText);

				/* Progress */

				let $colProgress = $('<th colspan="2"></th>');
				$colProgress.addClass(opts.cssClasses.chartCol);
				$colProgress.addClass(opts.cssClasses.chartCellOrColProgressBar);				
				if (opts.useChartCellOrColPctWidth === true) $colProgress.addClass(opts.cssClasses.chartCellOrColPctWidth);
				if (opts.useChartSmall === true) $colProgress.addClass(opts.cssClasses.chartSmall);
				let $colProgressText = $('<span></span>');
				$colProgressText.addClass(opts.cssClasses.chartColText);
				if (opts.useChartSmall === true) $colProgressText.addClass(opts.cssClasses.chartSmall);
				$colProgressText.html(opts.subTitleProgressBar);
				$($colProgress).append($colProgressText);

				/* Put together row */

				$($chartHeadRow).append($colLabel);
				$($chartHeadRow).append($colProgress);

				/* Append to head */

				$($chartHead).append($chartHeadRow);
			}

		  /* Create chart body */

		  let $chartBody = $('<tbody></tbody>');
		  $($chartBody).addClass(opts.cssClasses.chartBody);

		  /* Populate body */

			$.each(progressDataObjs, function (idx, progressDataObj) {
				let $chartBodyRow = $('<tr></tr>');
				$($chartBodyRow).addClass(opts.cssClasses.chartRow);
				if ((opts.progressDataHasActionURL === true) && (opts.tbodyRowIsActionURLTarget === true)) {
					$($chartBodyRow).attr(CONST_ATTR_NAME_FOR_HAS_ACTION_URL, '1');
					$($chartBodyRow).attr(CONST_ATTR_NAME_FOR_ACTION_URL, progressDataObj.actionURL);
				}

				/* Generate label */

				let $cellLabel = $('<td></td>');
				$($cellLabel).addClass(opts.cssClasses.chartCell);
				$($cellLabel).addClass(opts.cssClasses.chartCellOrColProgressLabel);
				if (opts.useChartCellOrColPctWidth === true) $cellLabel.addClass(opts.cssClasses.chartCellOrColPctWidth);
				if (opts.useChartSmall === true) $cellLabel.addClass(opts.cssClasses.chartSmall);

				let $label = $('<span></span>');
				$label.html(progressDataObj.label);
				$label.addClass(opts.cssClasses.progressLabel);
				if (opts.useChartSmall === true) $label.addClass(opts.cssClasses.chartSmall);

				if ((opts.progressDataHasActionURL === true) &&  (opts.tbodyRowIsActionURLTarget === false)) {
					$($label).attr(CONST_ATTR_NAME_FOR_HAS_ACTION_URL, '1');
					$($label).attr(CONST_ATTR_NAME_FOR_ACTION_URL, progressDataObj.actionURL);
					$($label).append('<i class="fas fa-link fa-sm ml-1"></i>');
				};

				$label.attr('title', opts.fnGenerateProgressLabelTitleAttributeText(progressDataObj));
				_fnCreateToolTip($label);

				$cellLabel.append($label);

				/* Generate progress bar */

				let $cellProgress = $('<td></td>');
				$cellProgress.addClass(opts.cssClasses.chartCell);
				$cellProgress.addClass(opts.cssClasses.chartCellOrColProgressBar);
				if (opts.useChartCellOrColPctWidth === true) $cellProgress.addClass(opts.cssClasses.chartCellOrColPctWidth);
				if (opts.useChartSmall === true) $cellProgress.addClass(opts.cssClasses.chartSmall);

				let $progressBar = $('<progress></progress');
				$progressBar.attr('max', 100);
				$progressBar.attr('value', progressDataObj.value);
				$progressBar.attr('title', opts.fnGenerateProgressBarTitleAttributeText(progressDataObj));
			  
			    $progressBar.addClass(opts.cssClasses.progressBar);			  
				if (opts.useChartSmall === true) $progressBar.addClass(opts.cssClasses.chartSmall);

				_fnCreateToolTip($progressBar);
			    $cellProgress.append($progressBar);

			  let $cellPercent = $('<td></td>');
			  $cellPercent.addClass(opts.cssClasses.chartCell);
		      $cellPercent.addClass(opts.cssClasses.chartCellOrColProgressPercent);
			  if (opts.useChartCellOrColPctWidth === true) $cellPercent.addClass(opts.cssClasses.chartCellOrColPctWidth);
			  if (opts.useChartSmall === true) $cellPercent.addClass(opts.cssClasses.chartSmall);

			  let $percent = $('<span></span>');
			  $percent.addClass(opts.cssClasses.progressPercent);
			  if (opts.useChartSmall === true) $percent.addClass(opts.cssClasses.chartSmall);
			  $percent.attr('title', opts.fnGenerateProgressPercentTitleAttributeText(progressDataObj));
			  $percent.html(progressDataObj.value + '%');
			  _fnCreateToolTip($percent);
			  $cellPercent.append($percent);

			  $chartBodyRow.append($cellLabel);
			  $chartBodyRow.append($cellProgress);
			  $chartBodyRow.append($cellPercent);

			  $chartBody.append($chartBodyRow);

		  });

		  /* Global handler for drilling down to details */

		  if (opts.progressDataHasActionURL == true) {
			  if ((opts.tbodyRowIsActionURLTarget === false)) {
				  $($chartBody).on('click', 'tr > td > span[' + CONST_ATTR_NAME_FOR_HAS_ACTION_URL + ']', function (e) {
					  let actionurl = $(e.currentTarget).attr(CONST_ATTR_NAME_FOR_ACTION_URL);
					  if (opts.actionURLOpenWindow === true) MBA.ComponentCommon.fnOpenWindow(actionurl);
					  else MBA.ComponentCommon.fnGotoURL(actionurl);
				  });
			  } else if ((opts.tbodyRowIsActionURLTarget === true)) {
				  $($chartBody).on('click', 'tr[' + CONST_ATTR_NAME_FOR_HAS_ACTION_URL + ']', function (e) {					  					  
					  let actionurl = $(e.currentTarget).attr(CONST_ATTR_NAME_FOR_ACTION_URL);
					  if (opts.actionURLOpenWindow === true) MBA.ComponentCommon.fnOpenWindow(actionurl);
					  else MBA.ComponentCommon.fnGotoURL(actionurl);
				  });
			  }
			  else {}
		  };


	      /* Create complete chart markup */
		  if (opts.renderChartHeader === true) $($chart).append($chartHead);
		  $($chart).append($chartBody);
          
		  $($me).append($chart);

		  /* Setup tooltips */

		  $($chart).find('.' + _CSS_CLASS_USING_TIPSO)
			     .tipso({
					  useTitle: true
					, background: '#55b555'
					, color: '#ffffff'
					, delay: 0
				})
				.removeClass('tipso_style');

		  /* Hack to remove any previously left open tooltips*/
		  _fnRemoveToolTipArtifactHack();
		  resolve($chart);

		});

	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGetData
	 * @private
	 * @summary      Requests data from server and then plots chart
	 * @description  Requests data from server and then plots chart
	 * @param  {Object}  elem    Element reference
	 */

	let _fnGetData = function (elem) {

		_fnRemoveToolTipArtifactHack();

		return _fnRequestProgressDataFromServer(elem).then(progressDataObjs => {
			_fnPlotChart(elem, progressDataObjs);			
		});
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

		/* Create container */

		$($me).wrap('<section></section>');
		let $container = $($me).parent();
		$($container).addClass(opts.cssClasses.container);
		if (opts.containerNoPadding   === true) $($container).addClass(opts.cssClasses.containerNoPadding);
		if (opts.containerNoBoxShadow === true) $($container).addClass(opts.cssClasses.containerNoBoxShadow);
		if (opts.containerNoBorder    === true) $($container).addClass(opts.cssClasses.containerNoBorder);

		/* Bar chart */

		$($me).addClass(opts.cssClasses.meter);

		/* Label & Instructions */

		let $label = $('<h3>' + opts.label + '</h3>');
		$($label).addClass(opts.cssClasses.label);

		let $instructions = $('<i></i>');
		$($instructions).addClass(opts.cssClasses.instructions);

		let $headers = $('<div></div>');		
		$($headers).addClass(opts.cssClasses.header);
		$($headers).append($label);
		if (opts.instructionsEnabled === true) {
			$($headers).append($instructions);
		}

		/* Spinner */

		let $spinner = $('<i></i>');
		$($spinner).addClass(opts.cssClasses.spinner);
		
		$($spinner).addClass(opts.cssClasses.hidden); /* Hide initially */

		let $status = $('<div></div>');
		$($status).addClass(opts.cssClasses.status);
		if (opts.hideStatusSectionWhenNotInUse === true) $($status).addClass(opts.cssClasses.hidden);
		$($status).append($spinner);
		$($container).prepend($status);
		
		if (opts.additionalContent) {
			$($container).prepend(opts.additionalContent);
        }
		$($container).prepend($headers);
		if (opts.showHeader === false) $($headers).addClass(opts.cssClasses.hidden); 

		dataObj.container    = $container;
		dataObj.headers      = $headers;
		dataObj.label        = $label;
		dataObj.instructions = $instructions;
		dataObj.status       = $status;
		dataObj.spinner      = $spinner;
		dataObj.opts         = opts;

		/* Save our data object.  This will be used for option calls */

		$($me).data(_JQ_DATA_NAME, dataObj);


		/* Instructions */

		if (opts.instructionsEnabled === true) {

			$($instructions).tipso({
				speed: 400
				, background: '#ffd60d'
				, titleBackground: '#333333'
				, color: 'black'
				, titleColor: '#ffffff'
				, titleContent: ''
				, showArrow: true
				, position: opts.instructionsPosition
				, width: '50vw'
				, maxWidth: '50vw'
				, delay: 200
				, hideDelay: 0
				, animationIn: ''
				, animationOut: ''
				, offsetX: 0
				, offsetY: 0
				, tooltipHover: true
				, content: opts.instructionsContent
				, ajaxContentUrl: null
				, contentElementId: null
				, useTitle: false
				, templateEngineFunc: null
				, onBeforeShow: null
				, onShow: null
				, onHide: null
			});
		}

	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	return {
		  PLUGIN_NAME: _PLUGIN_NAME
		, fnCreate: _fnCreate
		, fnDestroy: _fnDestroy
		, fnRequestProgressDataFromServer: _fnRequestProgressDataFromServer
		, fnPlotChart: _fnPlotChart
		, fnGetData: _fnGetData
		, fnRequestDataParameterSetOrUpdate: _fnRequestDataParameterSetOrUpdate
		, fnRemoveToolTipArtifactHack: _fnRemoveToolTipArtifactHack
	};

})(jQuery);


/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Progress bar chart plugin
 * @description  Progress bar chart plugin
 * @requires     jQuery
 */

; (function ($) {

	'use strict';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/* Tie into jQuery namespace */

	$.fn.MBA_ActionItemProgressBarChart = function (methodOrOptions, optionsOrValue) {

		/* These are the supported methods and properties that can be accessed from outside after an instance is created */

		let _methods = {
			getData: function (elem) {
				return MBA.ActionItemProgressBarChartCommon.fnGetData(elem);
			}
			, requestDataParameterSetOrUpdate: function (elem, value) {
				return MBA.ActionItemProgressBarChartCommon.fnRequestDataParameterSetOrUpdate(elem, value);
			} 
			/*, setContent : function (elem, value)   { return MBA.DisclosureCommon.fnSetContent  (elem, value); } */
		};

		let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

		/* Method is create */

		if (typeof methodOrOptions === 'object' || !methodOrOptions) {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.ActionItemProgressBarChartCommon.fnCreate(elem, methodOrOptions);
			});
		}

		/* Method is destroy */

		else if (methodOrOptions == 'destroy') {
			/* Tie into return chain so this can be chained with other methods */
			return this.each(function () {
				let elem = this; /* this in this scope is a reference to one of elements in the set */
				return MBA.ActionItemProgressBarChartCommon.fnDestroy(elem);
			});
		}

		/* Other methods (these cannot be chained) */

		else if (_methods[methodOrOptions]) {
			if (numOf == 1) {
				let elem = this[0]; /* There is only one element matched so we can proceed */
				return _methods[methodOrOptions](elem, optionsOrValue);
			}

			/* More than one element matched.  We cannot apply */
			else if (numOf > 1) { throw new Error(MBA.ActionItemProgressBarChartCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' cannot be applied to a set of elements at once.'); }
			/* No elements found */
			else { throw new Error(MBA.ActionItemProgressBarChartCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' cannot be applied since the element was not found.'); }
		}

		/* Cant find the method */

		else {
			throw new Error(MBA.ActionItemProgressBarChartCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method');
		}

	}; /* MBA_ActionItemProgressBarChart */

})(jQuery);
