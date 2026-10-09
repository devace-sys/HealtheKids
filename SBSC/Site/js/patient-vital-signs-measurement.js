;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PatientVitalSignsMeasurementCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common, PatientVitalSignsCommon
 */

MBA.PatientVitalSignsMeasurementCommon = (function ($)
{

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME      = 'Patient Vital Signs Measurement Common Methods';
    const _THIS_NS        = 'mba-patient-vital-signs-measurement';
    const _JQ_DATA_NAME   = 'jq-' + _THIS_NS;
    const _DATA_ATTR_BASE = 'data-' + _THIS_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
          PARM_NAME_CLIENT_ID: 'clientid'
        , PARM_NAME_PAT_ID: 'patID'
        , PARM_NAME_ACTIVE: 'active'
        , PARM_NAME_MEASUREMENT_TEMP:'temp'
        , PARM_NAME_MEASUREMENT_PULSE_RATE: 'pulserate'
        , PARM_NAME_MEASUREMENT_RESPIRATORY_RATE: 'respiratoryrate'
        , PARM_NAME_MEASUREMENT_BLOOD_PRESSURE_SYS: 'bloodpressuresys'
        , PARM_NAME_MEASUREMENT_BLOOD_PRESSURE_DIA: 'bloodpressuredia'
        , PARM_NAME_MEASUREMENT_O2_SATURATION: 'o2saturation'
        , PARM_NAME_MEASUREMENT_BLOOD_GLUCOSE: 'bloodglucose'
        , PARM_NAME_MEASUREMENT_HEIGHT_FT: 'heightft'
        , PARM_NAME_MEASUREMENT_HEIGHT_INCH:'heightinch'
        , PARM_NAME_MEASUREMENT_WEIGHT_LB:'weightlb'
        , containerCtrlID: ''
        , sessionTimeOutUrl: ''
        , baseUrlView: ''
        , defaultPageRowOrder: ''
        , baseUrlAddNew: ''
        , baseUrlEdit: ''
        , baseUrlDelete: ''
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnGetMe
     * @private
     * @summary      Gets reference to original elemementid
     * @description  Gets reference to original elemementid
     * @param  {Object}  elem  Element reference
     */

    let _fnGetMe = function (elementid) {
        return $('#' + elementid);
    };

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
        if (!dataObj) throw new Error('An instance of ' + _THIS_NAME + ' is required');
        return dataObj;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnSetDataObj
     * @private
     * @summary      Sets value of data object
     * @description  Sets value of data object
     * @param  {Object}  $me      Element reference
     * @param  {Object}  dataObj  Data obj for this lib
     */

    let _fnSetDataObj = function ($me, dataObj) {
        $($me).data(_JQ_DATA_NAME, dataObj);
        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _getNewMeasurementData = function ($me) {

        let dataObj = _fnGetDataObj($me);       

        return requestObj;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnClearMeasurmentData = function ($me) {

        let dataObj = _fnGetDataObj($me);
        $(dataObj.opts.ctrlInpTemp).MBA_DataEntryBox('clearValue');
        $(dataObj.opts.ctrlInpPulseRate).MBA_DataEntryBox('clearValue');
        $(dataObj.opts.ctrlInpRespiratoryRate).MBA_DataEntryBox('clearValue');
        $(dataObj.opts.ctrlInpBloodPressureSys).MBA_DataEntryBox('clearValue');
        $(dataObj.opts.ctrlInpBloodPressureDia).MBA_DataEntryBox('clearValue');
        $(dataObj.opts.ctrlInpO2Saturation).MBA_DataEntryBox('clearValue');
        $(dataObj.opts.ctrlInpBloodGlucose).MBA_DataEntryBox('clearValue');
        $(dataObj.opts.ctrlInpHeightFt).MBA_DataEntryBox('clearValue');
        $(dataObj.opts.ctrlInpHeightInch).MBA_DataEntryBox('clearValue');
        $(dataObj.opts.ctrlInpWeightLb).MBA_DataEntryBox('clearValue');
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnLockMeasurmentData = function ($me) {

        let dataObj = _fnGetDataObj($me);
        $(dataObj.opts.ctrlInpTemp).MBA_DataEntryBox('lock');
        $(dataObj.opts.ctrlInpPulseRate).MBA_DataEntryBox('lock');
        $(dataObj.opts.ctrlInpRespiratoryRate).MBA_DataEntryBox('lock');
        $(dataObj.opts.ctrlInpBloodPressureSys).MBA_DataEntryBox('lock');
        $(dataObj.opts.ctrlInpBloodPressureDia).MBA_DataEntryBox('lock');
        $(dataObj.opts.ctrlInpO2Saturation).MBA_DataEntryBox('lock');
        $(dataObj.opts.ctrlInpBloodGlucose).MBA_DataEntryBox('lock');
        $(dataObj.opts.ctrlInpHeightFt).MBA_DataEntryBox('lock');
        $(dataObj.opts.ctrlInpHeightInch).MBA_DataEntryBox('lock');
        $(dataObj.opts.ctrlInpWeightLb).MBA_DataEntryBox('lock');
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnUnLockMeasurmentData = function ($me) {

        let dataObj = _fnGetDataObj($me);
        $(dataObj.opts.ctrlInpTemp).MBA_DataEntryBox('unlock');
        $(dataObj.opts.ctrlInpPulseRate).MBA_DataEntryBox('unlock');
        $(dataObj.opts.ctrlInpRespiratoryRate).MBA_DataEntryBox('unlock');
        $(dataObj.opts.ctrlInpBloodPressureSys).MBA_DataEntryBox('unlock');
        $(dataObj.opts.ctrlInpBloodPressureDia).MBA_DataEntryBox('unlock');
        $(dataObj.opts.ctrlInpO2Saturation).MBA_DataEntryBox('unlock');
        $(dataObj.opts.ctrlInpBloodGlucose).MBA_DataEntryBox('unlock');
        $(dataObj.opts.ctrlInpHeightFt).MBA_DataEntryBox('unlock');
        $(dataObj.opts.ctrlInpHeightInch).MBA_DataEntryBox('unlock');
        $(dataObj.opts.ctrlInpWeightLb).MBA_DataEntryBox('unlock');
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    let _fnShowMeasurmentDataHistory = function ($me) {
        let dataObj = _fnGetDataObj($me);

        const isActive = $(dataObj.restViewCtrl).attr("data-active") === "true";

        if (isActive) {
            $(dataObj.restViewCtrl).attr("data-active", "false");
            $(dataObj.restViewCtrl).hide();
        } else {
            $(dataObj.restViewCtrl).attr("data-active", "true");
            $(dataObj.restViewCtrl).show();
        }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSaveNewMeasurmentData = function ($me) {

        let dataObj = _fnGetDataObj($me);

        let requestObj = {};

        requestObj[dataObj.opts.PARM_NAME_CLIENT_ID]                        = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        requestObj[dataObj.opts.PARM_NAME_PAT_ID]                           = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
        requestObj[dataObj.opts.PARM_NAME_MEASUREMENT_TEMP]                 = $(dataObj.opts.ctrlInpTemp).MBA_DataEntryBox('getValue');
        requestObj[dataObj.opts.PARM_NAME_MEASUREMENT_PULSE_RATE]           = $(dataObj.opts.ctrlInpPulseRate).MBA_DataEntryBox('getValue');
        requestObj[dataObj.opts.PARM_NAME_MEASUREMENT_RESPIRATORY_RATE]     = $(dataObj.opts.ctrlInpRespiratoryRate).MBA_DataEntryBox('getValue');
        requestObj[dataObj.opts.PARM_NAME_MEASUREMENT_BLOOD_PRESSURE_SYS]   = $(dataObj.opts.ctrlInpBloodPressureSys).MBA_DataEntryBox('getValue');
        requestObj[dataObj.opts.PARM_NAME_MEASUREMENT_BLOOD_PRESSURE_DIA]   = $(dataObj.opts.ctrlInpBloodPressureDia).MBA_DataEntryBox('getValue');
        requestObj[dataObj.opts.PARM_NAME_MEASUREMENT_O2_SATURATION]        = $(dataObj.opts.ctrlInpO2Saturation).MBA_DataEntryBox('getValue');
        requestObj[dataObj.opts.PARM_NAME_MEASUREMENT_BLOOD_GLUCOSE]        = $(dataObj.opts.ctrlInpBloodGlucose).MBA_DataEntryBox('getValue');
        requestObj[dataObj.opts.PARM_NAME_MEASUREMENT_HEIGHT_FT]            = $(dataObj.opts.ctrlInpHeightFt).MBA_DataEntryBox('getValue');
        requestObj[dataObj.opts.PARM_NAME_MEASUREMENT_HEIGHT_INCH]          = $(dataObj.opts.ctrlInpHeightInch).MBA_DataEntryBox('getValue');
        requestObj[dataObj.opts.PARM_NAME_MEASUREMENT_WEIGHT_LB]            = $(dataObj.opts.ctrlInpWeightLb).MBA_DataEntryBox('getValue');
        requestObj["savetype"]                                              = "1";
        requestObj["recid"]                                                 = "";
        
        let requestJSON = JSON.stringify(requestObj);

        _fnLockMeasurmentData($me);
        let $waitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner(dataObj.opts.ctrlButSaveNewMeasurment);
        
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlAddNew, requestJSON, dataObj.opts.sessionTimeOutUrl)
            .then(responseData => {
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner(dataObj.opts.ctrlButSaveNewMeasurment, $waitingIcon);
                _fnUnLockMeasurmentData($me);
                _fnClearMeasurmentData($me);
                MBA.RestViewCommon.fnRefreshCurrentViewFromServer(dataObj.restViewCtrl);
            })
            .catch(err => {
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner(dataObj.opts.ctrlButSaveNewMeasurment, $waitingIcon);
                _fnUnLockMeasurmentData($me);
                _fnClearMeasurmentData($me);
            });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetup = function (elementid, optsIn) {

        let $me = _fnGetMe(elementid);

        /* See if we have created an instance of this plugin already for this element.  If so get out. */

        let dataObj = $($me).data(_JQ_DATA_NAME);
        if (dataObj) return;


        /* Define the data object we will save later */

        dataObj = {};

        /* Store reference to elem */

        dataObj.me = $me;

        /* Merge default options and options passed in. */

        let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);

        dataObj.opts = opts;

        /* Create some instance specific ids based on elementid */

        let restViewContainerID = elementid + '-restview-container';
        let restViewID = elementid + '-restview';

        /* Add any new classes we need to the element we are building on */

        $($me).addClass('container-fluid');

        /* Create content */

        /* New measurement*/

        let $row1 = $('<div class="row"></div>');
        let $row1Col1 = $('<div class="col-1"></div>');
        let $row1Col2 = $('<div class="col-11"></div>');

        /* Save button */
        
        let $ctrlButSaveNewMeasurment = $('<button style="display:inline-block;background:none;border:none;" type="button" title="Click here to save these measurments"><i class="fa fa-save fa-2x"/></button>');
        $($row1Col1).append($ctrlButSaveNewMeasurment);
        opts.ctrlButSaveNewMeasurment = $ctrlButSaveNewMeasurment;

        /* Clear button */

        let $ctrlButClearNewMeasurment = $('<button style="display:inline-block;background:none;border:none;" type="button" title="Click here to clear these measurements and start over"><i class="fa fa-trash fa-2x"/></button>');
        $($row1Col1).append($ctrlButClearNewMeasurment);
        opts.ctrlButClearNewMeasurment = $ctrlButClearNewMeasurment;

        /* Temp*/

        let $ctrlInpTemp = $('<input type="number" step="0.1" min="90" max="150" placeholder="Temperature" title="Enter temperature in degrees" size="7" />');
        $($row1Col2).append($ctrlInpTemp);
        opts.ctrlInpTemp = $ctrlInpTemp;

        /* Pulse rate */

        let $ctrlInpPulseRate = $('<input type="number" step="1" min="1" max="360" placeholder="Pulse Rate" title="Enter pulse rate" size="7" />');
        $($row1Col2).append($ctrlInpPulseRate);
        opts.ctrlInpPulseRate = $ctrlInpPulseRate;

        /* Respiratory rate */

        let $ctrlInpRespiratoryRate = $('<input type="number" step="1" min="1" max="360" placeholder="Respiratory Rate" title="Enter respiratory rate" size="10" />');
        $($row1Col2).append($ctrlInpRespiratoryRate);
        opts.ctrlInpRespiratoryRate = $ctrlInpRespiratoryRate;

        /* Blood Pressure Sys */

        let $ctrlInpBloodPressureSys = $('<input type="number" step="1" min="0" max="400" placeholder="Blood Pressure Sys" title="Enter blood pressure systolic" size="10" />');
        $($row1Col2).append($ctrlInpBloodPressureSys);
        opts.ctrlInpBloodPressureSys = $ctrlInpBloodPressureSys;

        /* Blood Pressure Dia */

        let $ctrlInpBloodPressureDia = $('<input type="number" step="1" min="1" max="400" placeholder="Blood Pressure Dia" title="Enter blood pressure diastolic" size="10" />');
        $($row1Col2).append($ctrlInpBloodPressureDia);
        opts.ctrlInpBloodPressureDia = $ctrlInpBloodPressureDia;

        /* O2 Saturation */

        let $ctrlInpO2Saturation = $('<input type="number" step="1" min="1" max="100" placeholder="O2 Saturation" title="Enter o2 saturation percent" size="7" />');
        $($row1Col2).append($ctrlInpO2Saturation);
        opts.ctrlInpO2Saturation = $ctrlInpO2Saturation;

        /* Blood Glucose */

        let $ctrlInpBloodGlucose = $('<input type="number" step="1" min="1" max="300" placeholder="Blood Glucose(mg/dL)" title="Enter blood glucose" size="10" />');
        $($row1Col2).append($ctrlInpBloodGlucose);
        opts.ctrlInpBloodGlucose = $ctrlInpBloodGlucose;

        /* Height Ft */

        let $ctrlInpHeightFt = $('<input type="number" step="1" min="1" max="15" placeholder="Height(ft)" title="Enter height in ft" size="7" />');
        $($row1Col2).append($ctrlInpHeightFt);
        opts.ctrlInpHeightFt = $ctrlInpHeightFt;

        /* Height inch */

        let $ctrlInpHeightInch = $('<input type="number" step="0.01" min="1" max="200" placeholder="Height(in)" title="Enter height in inches" size="7" />');
        $($row1Col2).append($ctrlInpHeightInch);
        opts.ctrlInpHeightInch = $ctrlInpHeightInch;

        /* Weight lb */

        let $ctrlInpWeightLb = $('<input type="number" step="0.1" min="1" max="1000" placeholder="Weight(lb)" title="Enter weight in lbs" size="7" />');
        $($row1Col2).append($ctrlInpWeightLb);
        opts.ctrlInpWeightLb = $ctrlInpWeightLb;


        /* Rest view */

        let $row2 = $('<div class="row mt-2"></div>');
        let $row2Col1 = $('<div class="col-12"></div>');			
        
        let $restViewCtrlContainer = $('<details class="mt-1"></details>');
        $($restViewCtrlContainer).attr('id', restViewContainerID);
        //opts.restViewCtrlContainer = $restViewCtrlContainer;

        let $historyToggle = $('<summary><i class="fas fa-history fa-lg"></i> History </summary>');
        let historyToggleID = elementid + '-summary';
        $($historyToggle).attr('id', historyToggleID);

        let $restViewCtrl = $('<div></div>');
	    $($restViewCtrl).attr('id',restViewID);
		
        $($restViewCtrlContainer).append($historyToggle);
        $($restViewCtrlContainer).append($restViewCtrl);

        $($row1).append($row1Col1);
        $($row1).append($row1Col2);

        $($row2Col1).append($restViewCtrlContainer);
   	    $($row2).append($row2Col1);

        /* Append content */

        $($me).append($row1);
        $($me).append($row2);

        /* Create rest view */

        opts.containerCtrlID           = restViewContainerID;
        opts.enableRowControlRecAddNew = false;
        opts.enableScrollView          = true;
        opts.scrollViewUseCustomHeight = true;
        opts.scrollViewCustomHeight    = '15em';       
        opts.autoHidePageControls      = true;

        dataObj.restViewOpts           = MBA.PatientVitalSignsCommon.fnSetup(restViewID, opts);

        /* Create vital readings */

        $($ctrlInpTemp).MBA_DataEntryBox({});        
        $($ctrlInpPulseRate).MBA_DataEntryBox({});
        $($ctrlInpRespiratoryRate).MBA_DataEntryBox({});
        $($ctrlInpBloodPressureSys).MBA_DataEntryBox({});
        $($ctrlInpBloodPressureDia).MBA_DataEntryBox({});
        $($ctrlInpO2Saturation).MBA_DataEntryBox({});
        $($ctrlInpBloodGlucose).MBA_DataEntryBox({});
        $($ctrlInpHeightFt).MBA_DataEntryBox({});
        $($ctrlInpHeightInch).MBA_DataEntryBox({});
        $($ctrlInpWeightLb).MBA_DataEntryBox({});

        /* Wire up save */

        $($ctrlButSaveNewMeasurment).on('click', function (e) {
            _fnSaveNewMeasurmentData($me);
        });

        /*Wire up history*/

        $($historyToggle).on('click', function (e) {
            _fnShowMeasurmentDataHistory($me);
        });


        /* Wire up clear */

        $($ctrlButClearNewMeasurment).on('click', function (e) {

            let _fnOnClearMeasureProceed = function () {
                _fnClearMeasurmentData($me);
                return;
            };

            MBA.ComponentCommon.fnCreateOneTimeProceedOrCancelDialog('Are You Sure?', 'Do you really wish to clear this entry?', {}, _fnOnClearMeasureProceed, null, true, true);
           
        });

        /* Save reference */

        dataObj.restViewCtrl = $restViewCtrl;
		
        
        /* Save opts */

		dataObj.opts = opts;        

        /* Save our data object.  This will be used for option calls */

        $($me).data(_JQ_DATA_NAME, dataObj);

    }; /*_fnSetup */

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        fnSetup: _fnSetup                
    };

})(jQuery);