/**
 * @namespace    MBA.ActionItemPercentageBannerCommon
 * @memberof     MBA
 * @summary      Static methods for percentage banner
 * @description  Static methods for displaying CDE compliance as a modern percentage banner
 * @requires     jQuery, Bootstrap, MBA.ComponentCommon
 */

MBA.ActionItemPercentageBannerCommon = (function ($) {
	'use strict';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _PLUGIN_NAME = 'MBA Action Item Percentage Banner';
	const _PLUGIN_NS = 'mba-action-item-percentage-banner';
	const _JQ_DATA_NAME = 'jq-' + _PLUGIN_NS;

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const CONST_ATTR_NAME_FOR_HAS_ACTION_URL = 'data-' + _PLUGIN_NS + '-has-action-url';
	const CONST_ATTR_NAME_FOR_ACTION_URL = 'data-' + _PLUGIN_NS + '-action-url';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _CSS_CLASS_USING_TIPSO = 'using-tipso';

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _CSS_CLASSES = {
		container: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-container',
		containerNoPadding: MBA.ActionItemCommon.PLUGIN_COMMON + '-container-no-padding',
		containerNoBoxShadow: MBA.ActionItemCommon.PLUGIN_COMMON + '-container-no-box-shadow',
		containerNoBorder: MBA.ActionItemCommon.PLUGIN_COMMON + '-container-no-border',
		header: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-header' + ' d-flex',
		label: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-label' + ' flex-grow-1',
		instructions: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-instructions' + ' fa fa-info-circle',
		meter: MBA.ActionItemCommon.PLUGIN_COMMON + ' ' + MBA.ActionItemCommon.PLUGIN_COMMON + '-meter' + ' ' + _PLUGIN_NS + '-meter',
		hidden: MBA.ActionItemCommon.PLUGIN_COMMON + '-hidden-fully',
		// Classes for the percentage banner
		percentageSlimBanner: 'percentage-slim-banner',
		percentageBannerContent: 'percentage-banner-content',
		percentageBannerMain: 'percentage-banner-main',
		percentageBannerIconWrapper: 'percentage-banner-icon-wrapper',
		percentageBannerIconBg: 'percentage-banner-icon-bg',
		percentageBannerIcon: 'percentage-banner-icon',
		percentageBannerText: 'percentage-banner-text',
		percentageBannerTitle: 'percentage-banner-title',
		percentageBannerPercentage: 'percentage-banner-percentage',
		percentageBannerSubtitle: 'percentage-banner-subtitle',
		percentageBannerStats: 'percentage-banner-stats',
		percentageBannerStatItem: 'percentage-banner-stat-item',
		percentageBannerStatLabel: 'percentage-banner-stat-label',
		percentageBannerStatValue: 'percentage-banner-stat-value',
		percentageBannerStatDivider: 'percentage-banner-stat-divider'
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	const _DEFAULT_OPTIONS = {
		cssClasses: _CSS_CLASSES,
		label: '',
		requestDataUrlBase: '',
		requestDataParameters: null,
		requestDataFieldNames: [],
		urlSessionExpiredLink: '',
		actionURL: '',
		additionalContent: '',
		instructionsEnabled: false,
		instructionsContent: '',
		instructionsPosition: 'bottom',
		autoSetUpdateRequestDataParametersFromRequestDataFieldNames: true,
		bannerTitle: 'CDE Implementation',
		minutesProvidedLabel: 'Minutes Provided',
		minutesExpectedLabel: 'Minutes Expected',
		showHeader: false,
		hideStatusSectionWhenNotInUse: true,
		progressDataHasActionURL: false,
		actionURLOpenWindow: true,
		containerNoPadding: false,
		containerNoBoxShadow: false,
		containerNoBorder: false,
		fnGenerateTitleAttributeText: function (progressDataObj) { return ''; },
		fnOnRequestProgressDataFromServerSuccess: function (responseData) { return; },
		fnOnRequestProgressDataFromServerFail: function (responseData) { return; }
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGetMe
	 * @private
	 * @summary      Gets reference to original element
	 * @param  {Object}  elem  Element reference
	 */
	const _fnGetMe = function (elem) { return $(elem); };

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGetDataObj
	 * @private
	 * @summary      Gets reference to data object
	 * @param  {Object}  $me  Element reference
	 */
	const _fnGetDataObj = function ($me) {
		let dataObj = $($me).data(_JQ_DATA_NAME);
		if (!dataObj) throw new Error('An instance of ' + _PLUGIN_NAME + ' is required');
		return dataObj;
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnSetDataObj
	 * @private
	 * @summary      Save data object
	 * @param  {Object}  $me      Element reference
	 * @param  {Object}  dataObj  Data object
	 */
	const _fnSetDataObj = function ($me, dataObj) {
		$($me).data(_JQ_DATA_NAME, dataObj);
		return _fnGetDataObj($me);
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnDestroy
	 * @private
	 * @summary      Destroy existing instance
	 * @param  {Object}  elem  Element reference
	 */
	const _fnDestroy = function (elem) {
		let $me = _fnGetMe(elem);
		$me.removeData(_JQ_DATA_NAME);
		return;
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnIsElemSupported
	 * @private
	 * @summary      Is the element supported by the plugin
	 * @param  {Object}  elem  Element reference
	 */
	const _fnIsElemSupported = function (elem) {
		return $(elem).is('div');
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRemoveToolTipArtifactHack
	 * @private
	 * @summary      Removes tipso rendered content
	 */
	const _fnRemoveToolTipArtifactHack = function () {
		$('body').find('div.tipso_bubble').remove();
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnCreateToolTip
	 * @private
	 * @summary      Generates tool tip hover code
	 * @param  {Object}  element  Element reference
	 * @param  {String}  title    Text for tooltip
	 */
	const _fnCreateToolTip = function (element, title) {
		$(element).addClass(_CSS_CLASS_USING_TIPSO);
		$(element).attr('title', title);
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGenerateProgressDataObjsFromTotalNumAmts
	 * @private
	 * @summary      Converts server response to progress data objects
	 * @param  {Object}  responseData  Response data from server
	 */
	const _fnGenerateProgressDataObjsFromTotalNumAmts = function (responseData) {
		let progressDataObjs = [];
		$.each(responseData.rawData.totalNumAmts, function (idx, amtObj) {
			let progressDataObj = {
				label: amtObj.label,
				value: amtObj.totalNumVal,
				additionalData1: amtObj.additionalData1,
				additionalData2: amtObj.additionalData2,
				additionalData3: amtObj.additionalData3,
				additionalData4: amtObj.additionalData4,
				actionURL: amtObj.actionURL
			};
			progressDataObjs.push(progressDataObj);
		});
		return progressDataObjs;
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRequestDataParameterSetOrUpdate
	 * @private
	 * @summary      Sets or updates request parameter
	 * @param  {Object}  elem                  Element reference
	 * @param  {Object}  parameterNameValueObj Parameter name/value object
	 */
	const _fnRequestDataParameterSetOrUpdate = function (elem, parameterNameValueObj) {
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
	 * @summary      Sets parameter from a field name
	 * @param  {Object}  elem  Element reference
	 * @param  {String}  name  Field name
	 */
	const _fnRequestDataParameterSetOrUpdateFromFieldName = function (elem, name) {
		let nvo = MBA.ComponentCommon.fnCreateNameValueObjByInputName(name);
		return _fnRequestDataParameterSetOrUpdate(elem, nvo);
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnUpdateRequestParametersFromFieldNames
	 * @private
	 * @summary      Updates all parameters from field names
	 * @param  {Object}  elem  Element reference
	 */
	const _fnUpdateRequestParametersFromFieldNames = function (elem) {
		return new Promise((resolve) => {
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
	 * @function     _fnShowLoadingStateInBanner
	 * @private
	 * @summary      Shows loading spinner in banner
	 * @param  {Object}  elem  Element reference
	 */
	const _fnShowLoadingStateInBanner = function (elem) {
		let $me = _fnGetMe(elem);
		let $banner = $($me).find('.' + _CSS_CLASSES.percentageSlimBanner);
		if ($banner.length) {
			$banner.find('#cdeCompliancePercentage').html('<i class="fa fa-spinner fa-pulse fa-fw"></i>');
			$banner.find('#cdeComplianceMinutesProvided').html('<i class="fa fa-spinner fa-pulse fa-fw"></i>');
			$banner.find('#cdeComplianceMinutesExpected').html('<i class="fa fa-spinner fa-pulse fa-fw"></i>');
		}
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnResetLoadingStateInBanner
	 * @private
	 * @summary      Resets banner to empty state
	 * @param  {Object}  elem  Element reference
	 */
	const _fnResetLoadingStateInBanner = function (elem) {
		let $me = _fnGetMe(elem);
		let $banner = $($me).find('.' + _CSS_CLASSES.percentageSlimBanner);
		if ($banner.length) {
			$banner.find('#cdeCompliancePercentage').text('--' + '%');
			$banner.find('#cdeComplianceMinutesProvided').text('--');
			$banner.find('#cdeComplianceMinutesExpected').text('--');
		}
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRequestProgressDataFromServer
	 * @private
	 * @summary      Requests progress data from server
	 * @param  {Object}  elem  Element reference
	 */
	const _fnRequestProgressDataFromServer = function (elem) {
		return new Promise((resolve, reject) => {
			let $me = _fnGetMe(elem);
			let dataObj = _fnGetDataObj($me);

			_fnShowLoadingStateInBanner(elem);

			_fnUpdateRequestParametersFromFieldNames(elem).then(() => {
				let reqDataJSON = MBA.ComponentCommon.fnJSONFromMapKeysValues(dataObj.opts.requestDataParameters);
				let progressDataObjs = [];

				MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.requestDataUrlBase, reqDataJSON, dataObj.opts.urlSessionExpiredLink)
					.then(responseData => {
						dataObj.opts.fnOnRequestProgressDataFromServerSuccess(responseData);
						progressDataObjs = _fnGenerateProgressDataObjsFromTotalNumAmts(responseData);
						resolve(progressDataObjs);
					})
					.catch(responseData => {
						dataObj.opts.fnOnRequestProgressDataFromServerFail(responseData);
						_fnResetLoadingStateInBanner(elem);
						reject(progressDataObjs);
					});
			});
		});
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnRenderPercentageBanner
	 * @private
	 * @summary      Renders percentage banner with data
	 * @param  {Object}  elem             Element reference
	 * @param  {Array}   progressDataObjs Progress data objects
	 */
	const _fnRenderPercentageBanner = function (elem, progressDataObjs) {
		return new Promise((resolve) => {
			let $me = _fnGetMe(elem);
			let dataObj = _fnGetDataObj($me);
			let opts = dataObj.opts;
			$($me).html('');
			_fnRemoveToolTipArtifactHack();

			const hasData = (progressDataObjs && progressDataObjs.length > 0);
			const progressData = hasData ? progressDataObjs[0] : {
				value: "--",
				additionalData1: "--",  // min expected
				additionalData2: "--"   // min provided
			};

			// progress percentage
			const percentage = hasData ? progressData.value : "--";

			let $banner = $('<div></div>').addClass(opts.cssClasses.percentageSlimBanner);
			$banner.css({
				'box-sizing': 'border-box',
				'margin-top': '-5px',
			});

			if (opts.progressDataHasActionURL === true && hasData && progressData.actionURL) {
				$banner.attr(CONST_ATTR_NAME_FOR_HAS_ACTION_URL, '1');
				$banner.attr(CONST_ATTR_NAME_FOR_ACTION_URL, progressData.actionURL);
				$banner.css('cursor', 'pointer');
			}

			let $content = $('<div></div>').addClass(opts.cssClasses.percentageBannerContent);
			$content.css({
				'justify-content': 'flex-start',
			});

			let $main = $('<div></div>').addClass(opts.cssClasses.percentageBannerMain);
			$main.css({
				'width': '38%',
			});

			// icon 
			let $iconWrapper = $('<div></div>').addClass(opts.cssClasses.percentageBannerIconWrapper);
			$iconWrapper.css({
				'margin-left': '-3px'
			});

			let $iconBg = $('<div></div>').addClass(opts.cssClasses.percentageBannerIconBg);
			let $icon = $('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 320" width="512" height="640"></svg>')
				.addClass(opts.cssClasses.percentageBannerIcon)
				.html('<path d="M128 16C77.2 16 36 57.2 36 108s41.2 92 92 92 92-41.2 92-92S178.8 16 128 16zm0 165.6c-40.4 0-73.6-32.8-73.6-73.6S87.6 34.4 128 34.4s73.6 32.8 73.6 73.6S168.4 181.6 128 181.6z" fill="#FF8C00"/>' +
					'<path d="M128 64v46l28 28" fill="none" stroke="#FF8C00" stroke-width="12" stroke-linecap="round"/>' +
					'<circle cx="128" cy="108" r="9.2" fill="#FF8C00"/>' +
					'<rect x="16" y="224" width="224" height="72" rx="24" ry="24" fill="#f0f0f0" stroke="#FF8C00" stroke-width="8"/>' +
					'<rect x="28" y="236" width="152" height="48" rx="16" ry="16" fill="#FF8C00"/>');
			$iconWrapper.append($iconBg).append($icon);

			let $text = $('<div></div>').addClass(opts.cssClasses.percentageBannerText);

			// title with two parts
			let $title = $('<div></div>').addClass(opts.cssClasses.percentageBannerTitle);
		
			let bannerTitleParts = ["CDE", "Implementation"];

			if (opts.bannerTitle && opts.bannerTitle.indexOf("Implementation") > -1) {
				const implementationIndex = opts.bannerTitle.indexOf("Implementation");
				if (implementationIndex > 0) {
					bannerTitleParts[0] = opts.bannerTitle.substring(0, implementationIndex).trim();
					bannerTitleParts[1] = opts.bannerTitle.substring(implementationIndex).trim();
				}
			}

			$title.append(
				$('<span></span>')
					.css({
						'color': 'white',
						'font-weight': '600'
					})
					.text(bannerTitleParts[0])
			);

			$title.append(
				$('<span></span>')
					.addClass(opts.cssClasses.percentageBannerPercentage)
					.attr('id', 'cdeCompliancePercentage')
					.css({
					})
					.text(percentage + '%')
			);

			let $subtitle = $('<span></span>')
				.addClass(opts.cssClasses.percentageBannerSubtitle)
				.css({
				})
				.text(bannerTitleParts[1]);

			$text.append($title).append($subtitle);
			$main.append($iconWrapper).append($text);

			let $stats = $('<div></div>').addClass(opts.cssClasses.percentageBannerStats);
			$stats.css({
				'width': '70%',
			
			});

			// minutes provided stat
			let $providedStat = $('<div></div>').addClass(opts.cssClasses.percentageBannerStatItem);
			$providedStat.css('margin-top', '0px');

			$providedStat.append(
				$('<div></div>')
					.addClass(opts.cssClasses.percentageBannerStatLabel)
					.text(opts.minutesProvidedLabel)
			).append(
				$('<div></div>')
					.addClass(opts.cssClasses.percentageBannerStatValue)
					.attr('id', 'cdeComplianceMinutesProvided')
					.text(progressData.additionalData2)
			);

			let $divider = $('<div></div>').addClass(opts.cssClasses.percentageBannerStatDivider);

			// minutes expected stat
			let $expectedStat = $('<div></div>').addClass(opts.cssClasses.percentageBannerStatItem);
			$expectedStat.css('margin-top', '1px',
				'width', '38%'
		);

			$expectedStat.append(
				$('<div></div>')
					.addClass(opts.cssClasses.percentageBannerStatLabel)
					.text(opts.minutesExpectedLabel)
			).append(
				$('<div></div>')
					.addClass(opts.cssClasses.percentageBannerStatValue)
					.attr('id', 'cdeComplianceMinutesExpected')
					.text(progressData.additionalData1)
			);

			// stats section
			$stats.append($providedStat).append($divider).append($expectedStat);

			// banner
			$content.append($main).append($stats);
			$banner.append($content);

			if (hasData) {
				const tooltipText = opts.fnGenerateTitleAttributeText(progressData);
				if (tooltipText) {
					_fnCreateToolTip($banner, tooltipText);
				}

				if (opts.progressDataHasActionURL === true && progressData.actionURL) {
					$banner.on('click', function () {
						if (opts.actionURLOpenWindow === true) {
							MBA.ComponentCommon.fnOpenWindow(progressData.actionURL);
						} else {
							MBA.ComponentCommon.fnGotoURL(progressData.actionURL);
						}
					});
				}
			}

			$($me).append($banner);

			$($me).find('.' + _CSS_CLASS_USING_TIPSO)
				.tipso({
					useTitle: true,
					background: 'black',
					color: '#ffffff',
					delay: 0
				})
				.removeClass('tipso_style');

			_fnRemoveToolTipArtifactHack();
			resolve($banner);
		});
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	/**
	 * @function     _fnGetData
	 * @private
	 * @summary      Requests data and renders banner
	 * @param  {Object}  elem  Element reference
	 */
	const _fnGetData = function (elem) {
		_fnRemoveToolTipArtifactHack();
		return _fnRequestProgressDataFromServer(elem).then(progressDataObjs => {
			return _fnRenderPercentageBanner(elem, progressDataObjs);
		});
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	// Component creation
	/**
	 * @function     _fnCreate
	 * @private
	 * @summary      Create new instance of component
	 * @param  {Object}  elem    Element reference
	 * @param  {Object}  optsIn  Options object
	 */
	const _fnCreate = function (elem, optsIn) {
		let $me = _fnGetMe(elem);

		if (_fnIsElemSupported(elem) === false) return;

		let dataObj = $($me).data(_JQ_DATA_NAME);
		if (dataObj) return;

		dataObj = {};
		dataObj.me = $me;
		dataObj.meID = $($me).attr('id');

		if (!dataObj.meID) {
			dataObj.meID = MBA.ComponentCommon.fnCreateNewUUID();
			$($me).attr('id', dataObj.meID);
		}

		let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);
		if (!opts.requestDataParameters) opts.requestDataParameters = new Map();

		$($me).wrap('<section class="compact-percentage-banner" style="margin:0;padding:0;margin-bottom:0;padding-bottom:0;"></section>');
		let $container = $($me).parent();
		$($container).addClass(opts.cssClasses.container);
		if (opts.containerNoPadding === true) $($container).addClass(opts.cssClasses.containerNoPadding);
		if (opts.containerNoBoxShadow === true) $($container).addClass(opts.cssClasses.containerNoBoxShadow);
		if (opts.containerNoBorder === true) $($container).addClass(opts.cssClasses.containerNoBorder);

		$($me).addClass(opts.cssClasses.meter);

		let $headers = null;
		let $label = null;
		let $instructions = null;

		if (opts.showHeader === true) {
			$label = $('<h3>' + opts.label + '</h3>');
			$($label).addClass(opts.cssClasses.label);

			$instructions = $('<i></i>');
			$($instructions).addClass(opts.cssClasses.instructions);

			$headers = $('<div></div>');
			$($headers).addClass(opts.cssClasses.header);
			$($headers).append($label);
			if (opts.instructionsEnabled === true) {
				$($headers).append($instructions);
			}

			$($container).prepend($headers);
		}

		//  section
		let $spinner = $('<i></i>');
		$($spinner).addClass(opts.cssClasses.spinner);
		$($spinner).addClass(opts.cssClasses.hidden);

		let $status = $('<div></div>');
		$($status).addClass(opts.cssClasses.status);
		$($status).append($spinner);
		$($container).prepend($status);

		if (opts.additionalContent) {
			$($container).prepend(opts.additionalContent);
		}

		dataObj.container = $container;
		dataObj.headers = $headers;
		dataObj.label = $label;
		dataObj.instructions = $instructions;
		dataObj.status = $status;
		dataObj.spinner = $spinner;
		dataObj.opts = opts;

		$($me).data(_JQ_DATA_NAME, dataObj);

		if (opts.instructionsEnabled === true && $instructions) {
			$($instructions).tipso({
				speed: 400,
				background: '#ffd60d',
				titleBackground: '#333333',
				color: 'black',
				titleColor: '#ffffff',
				titleContent: '',
				showArrow: true,
				position: opts.instructionsPosition,
				width: '50vw',
				maxWidth: '50vw',
				delay: 200,
				hideDelay: 0,
				tooltipHover: true,
				content: opts.instructionsContent
			});
		}

		_fnRenderPercentageBanner(elem, null);
	};

	/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	return {
		PLUGIN_NAME: _PLUGIN_NAME,
		fnCreate: _fnCreate,
		fnDestroy: _fnDestroy,
		fnRequestProgressDataFromServer: _fnRequestProgressDataFromServer,
		fnRenderPercentageBanner: _fnRenderPercentageBanner,
		fnGetData: _fnGetData,
		fnRequestDataParameterSetOrUpdate: _fnRequestDataParameterSetOrUpdate,
		fnRemoveToolTipArtifactHack: _fnRemoveToolTipArtifactHack
	};

})(jQuery);

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Percentage banner plugin
 * @description  Percentage banner plugin for displaying CDE compliance
 * @requires     jQuery
 */
(function ($) {
	'use strict';

	$.fn.MBA_ActionItemPercentageBanner = function (methodOrOptions, optionsOrValue) {
		const _methods = {
			getData: function (elem) {
				return MBA.ActionItemPercentageBannerCommon.fnGetData(elem);
			},
			requestDataParameterSetOrUpdate: function (elem, value) {
				return MBA.ActionItemPercentageBannerCommon.fnRequestDataParameterSetOrUpdate(elem, value);
			}
		};

		let numOf = $(this).length;

		// Method is create
		if (typeof methodOrOptions === 'object' || !methodOrOptions) {
			return this.each(function () {
				return MBA.ActionItemPercentageBannerCommon.fnCreate(this, methodOrOptions);
			});
		}
		// Method is destroy
		else if (methodOrOptions == 'destroy') {
			return this.each(function () {
				return MBA.ActionItemPercentageBannerCommon.fnDestroy(this);
			});
		}
		// Other methods (these cannot be chained)
		else if (_methods[methodOrOptions]) {
			if (numOf == 1) {
				return _methods[methodOrOptions](this[0], optionsOrValue);
			}
			else if (numOf > 1) {
				throw new Error(MBA.ActionItemPercentageBannerCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' cannot be applied to a set of elements at once.');
			}
			else {
				throw new Error(MBA.ActionItemPercentageBannerCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' cannot be applied since the element was not found.');
			}
		}
		// Can't find the method
		else {
			throw new Error(MBA.ActionItemPercentageBannerCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method');
		}
	};
})(jQuery);