; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ActionItemDialGaugeCommon
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery, Plotly, MBA.ComponentCommon
 */

MBA.ActionItemDialGaugeCommon = (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _PLUGIN_NAME = 'MBA Action Item Dial Gauge';
    const _PLUGIN_NS = 'mba-action-item-dial-gauge';
    const _JQ_DATA_NAME = 'jq-' + _PLUGIN_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
        label: ''
        , minValue: 0
        , maxValue: 100
        , initialValue: 0
        , badgeThresHoldSVG: 90.1
        , onBadgeRender: null
        , badgeSVG: ''
        , gaugeThickness: 0.6
        , svgBadgeLocationTop: "70%"
        , svgBadgeLocationleft: "50%"
        , colorRanges: [
            {
                from: 0,
                to: 89,
                gradientColors: ['#ff0000', '#ff3333', '#ff6666', '#ff9999', '#ffcccc'],
                bannerTextSuffix: '% Compliant',
                bannerColor: '#ff0000',
                bannerFontColor: '#ffffff'
            },
            {
                from: 89,
                to: 94.9,
                gradientColors: ['#ffff00', '#ffff33', '#ffff66', '#ffff99'],
                bannerTextSuffix: '% Compliant',
                bannerColor: '#ffff00',
                bannerFontColor: '#000000'
            },
            {
                from: 94.9,
                to: 100,
                gradientColors: ['#00ff00', '#33ff33', '#66ff66'],
                bannerTextSuffix: '% Compliant',
                bannerColor: '#00ff00',
                bannerFontColor: '#000000'
            }
        ]
		, showValue:true
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
        let dataObj = $($me).data(_JQ_DATA_NAME);
        if (!dataObj) throw new Error('An instance of ' + _PLUGIN_NAME + ' is required');
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

    let _fnSetDataObj = function ($me, dataObj) {
        $($me).data(_JQ_DATA_NAME, dataObj);
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
        let $field = _fnGetMe(elem);
        $field.removeData(_JQ_DATA_NAME);
        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnCreateColorRangesForRange
     * @private
     * @summary      Creates appropriate color ranges for a given min/max range
     * @description  Creates color ranges that work well for any value range
     * @param  {Number}  minValue  Minimum value
     * @param  {Number}  maxValue  Maximum value
     * @param  {String}  suffix    Text suffix for banner (optional)
     */

    let _fnCreateColorRangesForRange = function (minValue, maxValue, suffix) {
        const range = maxValue - minValue;
        const lowThreshold = minValue + (range * 0.6);   // 60% of range
        const midThreshold = minValue + (range * 0.8);   // 80% of range

        suffix = suffix || '';

        return [
            {
                from: minValue,
                to: lowThreshold,
                color: 'rgba(255, 0, 0, 0.9)',
                bannerTextSuffix: suffix,
                bannerColor: '#ff0000',
                bannerFontColor: '#ffffff'
            },
            {
                from: lowThreshold,
                to: midThreshold,
                color: 'rgba(255, 255, 0, 0.9)',
                bannerTextSuffix: suffix,
                bannerColor: '#ffff00',
                bannerFontColor: '#000000'
            },
            {
                from: midThreshold,
                to: maxValue,
                color: 'rgba(0, 255, 0, 0.9)',
                bannerTextSuffix: suffix,
                bannerColor: '#00ff00',
                bannerFontColor: '#000000'
            }
        ];
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function _fnPlotDialGauge(elem, valueIn) {

        return new Promise((resolve, reject) => {
            let $me = _fnGetMe(elem);
            let dataObj = _fnGetDataObj($me);

            const chartID = dataObj.meID;

            const minVal = dataObj.opts.minValue;
            const maxVal = dataObj.opts.maxValue;
            const normalizedValue = Math.max(minVal, Math.min(maxVal, valueIn));
            const showValue = dataObj.opts.showValue;
			
            const valuePercentage = ((normalizedValue - minVal) / (maxVal - minVal)) * 100;

            /* CHANGED: Use percentage instead of raw value */
            const level = valuePercentage * 1.8;
            const degrees = 180 - level;
            const radians = degrees * Math.PI / 180;
            const domainY = [0.2, 1];
            const centerX = 0.5;
            const centerY = (domainY[0] + domainY[1]) / 2;
            const radius = 0.3;
            const xHead = centerX + radius * Math.cos(radians);
            const yHead = centerY + radius * Math.sin(radians);
            const baseWidth = 0.002;
            const xTailLeft = centerX - baseWidth;
            const yTailLeft = centerY;
            const xTailRight = centerX + baseWidth;
            const yTailRight = centerY;

            const path = `M ${xTailLeft} ${yTailLeft} 
                      L ${xTailRight} ${yTailRight} 
                      L ${xHead} ${yHead} Z`;

            let sectorValues = [];
            let sectorColors = [];
            let sectorText = [];

            const cr = dataObj.opts.colorRanges;

            let totalDeg = 180;
            let rangeSpan = (maxVal - minVal) || 1;

            let currentPosition = minVal;
            $.each(cr, function (i, seg) {
                /* Ensure no gaps - start from current position */
                let segFrom = i === 0 ? minVal : currentPosition;
                let segTo = i === cr.length - 1 ? maxVal : Math.min(seg.to, maxVal);

                /* Calculate degrees for this segment */
                let spanDeg = ((segTo - segFrom) / rangeSpan) * totalDeg;
                if (spanDeg > 0) {
                    /* Support both color and gradientColors properties */
                    if (seg.gradientColors && seg.gradientColors.length > 0) {
                        /* Create gradient effect by adding multiple small segments */
                        const gradientSteps = seg.gradientColors.length;
                        const degStep = spanDeg / gradientSteps;
                        const valueRange = segTo - segFrom;
                        const rangeStep = valueRange / gradientSteps;

                        for (let g = 0; g < gradientSteps; g++) {
                            sectorValues.push(degStep);
                            sectorColors.push(seg.gradientColors[g]);
                            let fromVal = segFrom + (rangeStep * g);
                            let toVal = segFrom + (rangeStep * (g + 1));

                            /* Format text based on value range */
                            if (maxVal <= 100) {
                                fromVal = fromVal % 1 === 0 ? fromVal : fromVal.toFixed(1);
                                toVal = toVal % 1 === 0 ? toVal : toVal.toFixed(1);
                            } else if (maxVal > 1000) {
                                fromVal = Math.round(fromVal);
                                toVal = Math.round(toVal);
                            }
                            sectorText.push(`${fromVal}-${toVal}`);
                        }
                    } else {
                        /* Use solid color */
                        let segColor = seg.color || '#aaaaaa';

                        sectorValues.push(spanDeg);
                        sectorColors.push(segColor);

                        /* Format text based on value range */
                        let fromText = segFrom;
                        let toText = segTo;
                        if (maxVal <= 100) {
                            fromText = segFrom % 1 === 0 ? segFrom : segFrom.toFixed(1);
                            toText = segTo % 1 === 0 ? segTo : segTo.toFixed(1);
                        } else if (maxVal > 1000) {
                            fromText = Math.round(segFrom);
                            toText = Math.round(segTo);
                        }
                        sectorText.push(`${fromText}-${toText}`);
                    }

                    currentPosition = segTo;
                }
            });

            /* ALWAYS add invisible section to complete 180 degrees */
            sectorValues.push(180);
            sectorColors.push('rgba(255,255,255,0)');
            sectorText.push('');

            let bannerText = '';
            let bannerBgColor = '';
            let bannerFontColor = '';

            $.each(cr, function (i, r) {
                if ((normalizedValue >= r.from) && (normalizedValue <= r.to)) {
                    /* FIX ADDED: Format based on range */
                    let displayValue = normalizedValue;
                    if (maxVal <= 100 && minVal >= 0) {
                        displayValue = normalizedValue.toFixed(2);
                    } else if (maxVal > 1000) {
                        displayValue = normalizedValue.toFixed(0);
                    } else {
                        displayValue = normalizedValue.toFixed(1);
                    }
                    bannerText = displayValue + r.bannerTextSuffix;
                    bannerBgColor = r.bannerColor;
                    bannerFontColor = r.bannerFontColor;
                    return false;
                }
            });

            let bannerAnnotation = {
                x: 1.0782,
                y: 1.0782,
                xref: 'paper',
                yref: 'paper',
                text: bannerText,
                showarrow: false,
                font: { family: 'Arial', size: 12, color: bannerFontColor },
                bgcolor: bannerBgColor,
                bordercolor: '#000',
                borderwidth: 0.2,
                opacity: 0.8
            };

            /* FIX CHANGED: Remove section lines for cleaner appearance */
            let sectorLineColors = sectorColors.map(() => 'rgba(255,255,255,0)');

            let data = [
                {
                    type: 'scatter',
                    x: [centerX - 0.5],
                    y: [centerY + 0.085],
                    marker: { size: 14, color: 'black' },
                    showlegend: false,
                    name: dataObj.opts.label,
                    text: valuePercentage.toFixed(2) + '%',
                    hoverinfo: 'none'
                },
                {
                    values: sectorValues,
                    rotation: -90,
                    direction: 'clockwise',
                    sort: false,
                    text: sectorText,
                    textinfo: 'none',
                    textposition: 'inside',
                    marker: {
                        colors: sectorColors,
                        line: {
                            color: sectorLineColors,
                            width: 0
                        }
                    },
                    labels: sectorText,
                    hoverinfo: 'none',
                    hole: dataObj.opts.gaugeThickness,
                    type: 'pie',
                    showlegend: false,
                    domain: { x: [0, 1], y: domainY }
                }
            ];

            let layout = {
                shapes: [{
                    type: 'path',
                    path: path,
                    fillcolor: 'black',
                    line: { color: 'black' },
                    xref: 'paper',
                    yref: 'paper'
                }],
                annotations: [],
                title: {
                    text: valuePercentage.toFixed(2) + '%',
                    font: { size: 1 },
                    y: 0.55
                },
                height: 300,
                width: 300,
                xaxis: { zeroline: false, showticklabels: false, showgrid: false, range: [-1, 1], fixedrange: true },
                yaxis: { zeroline: false, showticklabels: false, showgrid: false, range: [-0.1, 1.2], fixedrange: true },
                margin: { l: 20, r: 20, t: 20, b: 20 },
                paper_bgcolor: 'rgba(255,255,255,0)',
                plot_bgcolor: 'rgba(255,255,255,0)'
            };

            if (showValue === true) {						
			  layout.annotations.push(bannerAnnotation); 
			}
			
			/*  Uses react instead of newPlot to preserve state */
            Plotly.react(chartID, data, layout, MBA.ActionItemCommon.COMMON_CHART_CONFIG);

            /* ADDED: Store current value */
            dataObj.currentValue = normalizedValue;
            _fnSetDataObj($me, dataObj);

            resolve();
        });

    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnSetValue
     * @private
     * @summary      Sets dial value
     * @description  Sets dial value
     * @param  {Object}  elem    Element reference
     * @param  {Object}  value   Value of dial
     */

    let _fnSetValue = function (elem, value) {
        _fnPlotDialGauge(elem, value);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnGetValue
     * @private
     * @summary      Gets current dial value
     * @description  Gets current dial value
     * @param  {Object}  elem    Element reference
     */

    let _fnGetValue = function (elem) {
        let $me = _fnGetMe(elem);
        let dataObj = _fnGetDataObj($me);
        return dataObj.currentValue || dataObj.opts.initialValue;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnUpdateOptions
     * @private
     * @summary      Updates gauge options
     * @description  Updates gauge options and redraws if needed
     * @param  {Object}  elem    Element reference
     * @param  {Object}  newOptions   New options to merge
     */

    let _fnUpdateOptions = function (elem, newOptions) {
        let $me = _fnGetMe(elem);
        let dataObj = _fnGetDataObj($me);

        /* Store old values for comparison */
        const oldMinValue = dataObj.opts.minValue;
        const oldMaxValue = dataObj.opts.maxValue;

        /* Merge new options with existing ones */
        dataObj.opts = $.extend(true, {}, dataObj.opts, newOptions);

        /* If min/max values changed, automatically scale existing colorRanges if no new colorRanges provided */
        if ((newOptions.minValue !== undefined || newOptions.maxValue !== undefined) &&
            !newOptions.colorRanges) {

            const newMinValue = dataObj.opts.minValue;
            const newMaxValue = dataObj.opts.maxValue;
            const oldRange = oldMaxValue - oldMinValue;
            const newRange = newMaxValue - newMinValue;
            const scaleFactor = newRange / oldRange;

            /*ensure NO GAPS */
            let previousEnd = newMinValue;
            dataObj.opts.colorRanges = dataObj.opts.colorRanges.map((range, index) => {
                const newFrom = index === 0 ? newMinValue : previousEnd;
                const newTo = index === dataObj.opts.colorRanges.length - 1 ?
                    newMaxValue :
                    newMinValue + ((range.to - oldMinValue) * scaleFactor);

                previousEnd = newTo;

                return {
                    ...range,
                    from: newFrom,
                    to: newTo
                };
            });
        }

        /* Save updated data object */
        _fnSetDataObj($me, dataObj);

        /* Redraw with current value */
        const currentValue = dataObj.currentValue || dataObj.opts.initialValue;
        _fnPlotDialGauge(elem, currentValue);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnUpdateRange
     * @private
     * @summary      Updates gauge min/max range and creates appropriate color ranges
     * @description  Updates gauge min/max range and creates appropriate color ranges
     * @param  {Object}  elem    Element reference
     * @param  {Number}  minValue   New minimum value
     * @param  {Number}  maxValue   New maximum value
     * @param  {String}  suffix     Banner text suffix (optional)
     */

    let _fnUpdateRange = function (elem, minValue, maxValue, suffix) {
        let $me = _fnGetMe(elem);
        let dataObj = _fnGetDataObj($me);

        /* Update min/max values */
        dataObj.opts.minValue = minValue;
        dataObj.opts.maxValue = maxValue;

        /* Create new color ranges for this range */
        dataObj.opts.colorRanges = _fnCreateColorRangesForRange(minValue, maxValue, suffix);

        /* Save updated data object */
        _fnSetDataObj($me, dataObj);

        /* Redraw with current value */
        const currentValue = dataObj.currentValue || dataObj.opts.initialValue;
        _fnPlotDialGauge(elem, currentValue);
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
     * @function     _fnCreate
     * @private
     * @summary      Create new instance
     * @description  Create new instance
     * @param  {Object}  elem    Element reference
     * @param  {Object}  optsIn  Options passed in
     */

    let _fnCreate = function (elem, optsIn) {

        let $me = _fnGetMe(elem);

        /* Test to see if element is supported (div) */

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

        let opts = $.extend(true, {}, _DEFAULT_OPTIONS, optsIn);
        dataObj.opts = opts;
        dataObj.currentValue = opts.initialValue;

        /* Save our data object.  This will be used for option calls */

        _fnSetDataObj($me, dataObj);

        /* Initial plot*/

        _fnPlotDialGauge(elem, opts.initialValue);

    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        PLUGIN_NAME: _PLUGIN_NAME
        , fnCreate: _fnCreate
        , fnDestroy: _fnDestroy
        , fnSetValue: _fnSetValue
        , fnGetValue: _fnGetValue
        , fnUpdateOptions: _fnUpdateOptions
        , fnUpdateRange: _fnUpdateRange
        , fnCreateColorRangesForRange: _fnCreateColorRangesForRange
    };

})(jQuery);


/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Pie Chart plugin transformed to Gauge Chart
 * @description  Pie Chart plugin transformed to Gauge Chart
 * @requires     jQuery
 */

; (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /* Tie into jQuery namespace */

    $.fn.MBA_ActionItemDialGauge = function (methodOrOptions, optionsOrValue, thirdParam) {

        /* These are the supported methods and properties that can be accessed from outside after an instance is created */

        let _methods = {
            setValue: function (elem, value) { return MBA.ActionItemDialGaugeCommon.fnSetValue(elem, value); },
            getValue: function (elem) { return MBA.ActionItemDialGaugeCommon.fnGetValue(elem); },
            updateOptions: function (elem, options) { return MBA.ActionItemDialGaugeCommon.fnUpdateOptions(elem, options); },
            updateRange: function (elem, minValue, maxValue, suffix) { return MBA.ActionItemDialGaugeCommon.fnUpdateRange(elem, minValue, maxValue, suffix); }
        };

        let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

        /* Method is create */

        if (typeof methodOrOptions === 'object' || !methodOrOptions) {
            /* Tie into return chain so this can be chained with other methods */
            return this.each(function () {
                let elem = this; /* this in this scope is a reference to one of elements in the set */
                return MBA.ActionItemDialGaugeCommon.fnCreate(elem, methodOrOptions);
            });
        }

        /* Method is destroy */

        else if (methodOrOptions == 'destroy') {
            /* Tie into return chain so this can be chained with other methods */
            return this.each(function () {
                let elem = this; /* this in this scope is a reference to one of elements in the set */
                return MBA.ActionItemDialGaugeCommon.fnDestroy(elem);
            });
        }

        /* Other methods (these cannot be chained) */

        else if (_methods[methodOrOptions]) {
            if (numOf == 1) {
                let elem = this[0]; /* There is only one element matched so we can proceed */
                /* ADDED: Handle updateRange with multiple parameters */
                if (methodOrOptions === 'updateRange') {
                    return _methods[methodOrOptions](elem, optionsOrValue, thirdParam, arguments[3]);
                }
                return _methods[methodOrOptions](elem, optionsOrValue);
            }

            /* More than one element matched.  We cannot apply */
            else if (numOf > 1) { throw new Error(MBA.ActionItemDialGaugeCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' cannot be applied to a set of elements at once.'); }
            /* No elements found */
            else { throw new Error(MBA.ActionItemDialGaugeCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' cannot be applied since the element was not found.'); }
        }

        /* Can't find the method */

        else {
            throw new Error(MBA.ActionItemDialGaugeCommon.PLUGIN_NAME + ' ' + methodOrOptions + ' is an unknown method');
        }

    }; /* MBA_ActionItemDialGauge */

})(jQuery);