;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PatientVitalSignsCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.PatientVitalSignsCommon = (function ($)
{

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME = 'Patient Vital Signs Common Methods';
    const _THIS_NS = 'mba-patient-vital-signs';
    const _JQ_DATA_NAME = 'jq-' + _THIS_NS;
    const _DATA_ATTR_BASE = 'data-' + _THIS_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
          PARM_NAME_CLIENT_ID: 'clientid'
        , PARM_NAME_PAT_ID: 'patID'
        , PARM_NAME_ACTIVE: 'active'
        , containerCtrlID: ''
        , sessionTimeOutUrl: ''
        , baseUrlView: ''
        , defaultPageRowOrder: ''
        , baseUrlAddNew: ''
        , baseUrlEdit: ''
        , baseUrlDelete: ''
        , enableRowControlRecAddNew: true
        , enableScrollView:false
        , scrollViewUseCustomHeight:false
        , scrollViewCustomHeight:''
        , showCaption:false
        , caption:''
        , autoHidePageControls:false

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

    let _createRestView = function ($me, optsIn) {

        let opts = {};

        opts.enableScrollView           = optsIn.enableScrollView;
        opts.scrollViewUseCustomHeight  = optsIn.scrollViewUseCustomHeight;
        opts.scrollViewCustomHeight     = optsIn.scrollViewCustomHeight;
        opts.showCaption                = optsIn.showCaption;
        opts.caption                    = optsIn.caption;
        opts.autoHidePageControls       = optsIn.autoHidePageControls;
        opts.sessionTimeOutUrl          = optsIn.sessionTimeOutUrl;
        opts.requestViewOnLoad          = false; /*This is so we can set the initial filters */
        opts.enableSortControls         = true;
        opts.enableRowNumbers           = true; /* Turn off row numbers */
        opts.enableRowControls          = true;
        opts.enableReports              = true;
        opts.enableRowControlRecAddNew  = optsIn.enableRowControlRecAddNew;
        opts.enableRowControlRecEdit    = true;
        opts.enableRowControlRecDelete  = true;

        opts.loadModeView               = 'rest';
        opts.baseUrlView                = optsIn.baseUrlView;
        opts.baseUrlViewHasParameters   = true;
        opts.defaultPageRowOrder        = optsIn.defaultPageRowOrder;

        opts.saveModeAddNew             = 'inline';
        opts.baseUrlAddNew              = optsIn.baseUrlAddNew;
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit               = 'inline';
        opts.baseUrlEdit                = optsIn.baseUrlEdit;
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = optsIn.baseUrlDelete;
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = optsIn.baseUrlReport
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber        = optsIn.defaultReportNumber;
        opts.enableReportXls            = true;

        opts.fieldDefinitions           = [];
        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
              name: 'measurementDateStr'
            , label: 'Date'
            , toolTip: 'Measurement Date'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'string'            
            , sortUsing: 'measurementDate'
            , saveUsing: ''
            , showMore: false 
        });

        opts.fieldDefinitions.push({
            name: 'measurmentTimeStr'
            , label: 'Time'
            , toolTip: 'Measurement Time'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'measurementTime'
            , saveUsing: ''
            , showMore: false
        });


        opts.fieldDefinitions.push({
            name: 'tempStr'
            , label: 'Temperature'
            , toolTip: 'Temperature'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'temp'
            , saveUsing: 'temp'
            , showMore: false            
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:7em'
        });

        opts.fieldDefinitions.push({
            name: 'pulseRateStr'
            , label: 'Pulse<br>Rate'
            , toolTip: 'Pulse Rate'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'pulseRate'
            , saveUsing: 'pulserate'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:5em'
            , 
        });

        opts.fieldDefinitions.push({
            name: 'respiratoryRateStr'
            , label: 'Respirator<br>Rate'
            , toolTip: 'Respiratory Rate'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'respiratoryRate'
            , saveUsing: 'respiratoryrate'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:5em'
        });

        opts.fieldDefinitions.push({
            name: 'bloodPressureSysStr'
            , label: 'Blood<br>Pressure<br> Systolic'
            , toolTip: 'Blood Pressure Systolic'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'bloodPressureSys'
            , saveUsing: 'bloodpressuresys'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:5em'
        });

        opts.fieldDefinitions.push({
            name: 'bloodPressureDiaStr'
            , label: 'Blood<br>Pressure<br>Diastolic'
            , toolTip: 'Blood Pressure Diastolic'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'bloodPressureDia'
            , saveUsing: 'bloodpressuredia'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:5em'
        });

        opts.fieldDefinitions.push({
            name: 'o2SaturationStr'
            , label: 'Oxygen<br>Saturation'
            , toolTip: 'Oxygen Saturation'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'o2Saturation'
            , saveUsing: 'o2saturation'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:5em'
        });

        opts.fieldDefinitions.push({
            name: 'bloodGlucoseStr'
            , label: 'Blood<br>Glucose (mg/dl)'
            , toolTip: 'Blood Glucose (mg/dl)'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'bloodGlucose'
            , saveUsing: 'bloodglucose'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:5em'
        });

        opts.fieldDefinitions.push({
            name: 'heightFtStr'
            , label: 'Height(ft)'
            , toolTip: 'Height(ft)'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'heightFt'
            , saveUsing: 'heightft'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:5em'
        });

        opts.fieldDefinitions.push({
            name: 'heightInchStr'
            , label: 'Height(in)'
            , toolTip: 'Height(in)'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'heightInch'
            , saveUsing: 'heightinch'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:7em'
        });

        opts.fieldDefinitions.push({
            name: 'weightlbStr'
            , label: 'Weight(lb)'
            , toolTip: 'Weight'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'weightlb'
            , saveUsing: 'weightlb'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
            , styleAttrValueForCellValue: 'width:7em'
        });


        /* Create the rest view */

        $($me).MBA_RestView(opts);
        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me) {

        let dataObj = _fnGetDataObj($me);

        let VALUE_CLIENT_ID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let VALUE_PAT_ID = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
        let VALUE_ACTIVE = '1';

        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_PAT_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PAT_ID, VALUE_PAT_ID);
        let NV_ACTIVE = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE, VALUE_ACTIVE);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        /* We need these for the various rec ops */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PAT_ID);

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_PAT_ID);


        $(dataObj.restViewCtrl).MBA_RestView('requestViewFromServer', 1);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnRefreshView = function (elementid) {
        let $me = _fnGetMe(elementid);
        _updateAdditionalViewParameterValuesAndRequestViewFromServer($me);
        return;
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

        /* Create rest view */

        let $restViewCtrl = $me;
        dataObj.restViewCtrl = $restViewCtrl;
        _createRestView($restViewCtrl, opts);

        /* Get reference to container control to listen for events on */

        let $containerCtrl = $('#' + opts.containerCtrlID);
        dataObj.containerCtrl = $containerCtrl;

        /* Save our data object.  This will be used for option calls */

        $($me).data(_JQ_DATA_NAME, dataObj);

        /* Wire up events */

        $($containerCtrl).on('spedmoninputdata', function (e) {
            _updateAdditionalViewParameterValuesAndRequestViewFromServer($me);
        });

        _updateAdditionalViewParameterValuesAndRequestViewFromServer($me);
		
		return opts;

    }; /*_fnSetup */

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
          fnSetup: _fnSetup
        , fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer: _updateAdditionalViewParameterValuesAndRequestViewFromServer
        , fnRefreshView: _fnRefreshView
    };

})(jQuery);