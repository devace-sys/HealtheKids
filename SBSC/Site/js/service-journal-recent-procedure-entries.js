;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ServiceJournalRecentProcedureEntriesCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.ServiceJournalRecentProcedureEntriesCommon = (function ($)
{
    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME = 'Service Journal Recent Procedure Entries Common Methods';
    const _THIS_NS = 'mba-service-journal-recent-procedure-entries';
    const _JQ_DATA_NAME = 'jq-' + _THIS_NS;
    const _DATA_ATTR_BASE = 'data-' + _THIS_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
          PARM_NAME_CLIENT_ID: 'clientid'
        , PARM_PAT_ID: 'patid'
        , PARM_NAME_ACTIVE: 'active'
        , PARM_NAME_DOS: 'dos'
        , containerCtrlID: ''
        , sessionTimeOutUrl: ''
        , baseUrlView: ''
        , defaultPageRowOrder: ''
        , enableRowNumbers: true
        , autoHidePageControls: false
        , enableScrollView: false
        , scrollViewUseCustomHeight: true
        , scrollViewCustomHeight: '' 
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

        opts.enableScrollView = optsIn.enableScrollView;
        opts.scrollViewUseCustomHeight = optsIn.scrollViewUseCustomHeight;
        opts.scrollViewCustomHeight = optsIn.scrollViewCustomHeight;
        opts.showCaption = optsIn.showCaption;
        opts.caption = optsIn.caption;
        opts.autoHidePageControls = optsIn.autoHidePageControls;
        opts.sessionTimeOutUrl = optsIn.sessionTimeOutUrl;
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = false; /* Turn off row numbers */
        opts.enableRowControls = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = optsIn.baseUrlView;
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = optsIn.defaultPageRowOrder;

        /* Setup additional row controls */
        opts.fieldDefinitions = [];
        opts.additionalControlDefinitionsForBodyRows = new Map();        

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: false
            , saveUsing: 'recid'
        });       

        opts.fieldDefinitions.push({
            name: 'dosStr'
            , label: 'Date of Service'
            , toolTip: 'Date of Service'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'string'
            , saveUsing: ''
            , sortUsing: 'dos'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'entryStartTimeStr'
            , label: 'Start Time'
            , toolTip: 'Start Time'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'string'
            , saveUsing: ''
            , sortUsing: 'entryStartTime'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'entryEndTimeStr'
            , label: 'End Time'
            , toolTip: 'End Time'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'string'
            , saveUsing: ''
            , sortUsing: 'entryEndTime'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'pracName'
            , label: 'Practioner'
            , toolTip: 'Practioner Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'string'
            , saveUsing: ''
            , sortUsing: 'pracName'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'pracTitle'
            , label: 'Practioner Title'
            , toolTip: 'Practioner Title'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'string'
            , saveUsing: ''
            , sortUsing: 'pracTitle'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'patName'
            , label: 'Patient'
            , toolTip: 'Patient Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'string'
            , saveUsing: ''
            , sortUsing: 'patName'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'procedureName'
            , label: 'Procedure'
            , toolTip: 'Procedure'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'string'
            , saveUsing: ''
            , sortUsing: 'procedureName'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'procedureNotes'
            , label: 'Notes'
            , toolTip: 'Notes'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'textarea'
            , saveUsing: ''
            , sortUsing: 'procedureNotes'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , styleAttrValueForCellValue: 'width:12em'
        });

        /* Create the rest view */

        $($me).MBA_RestView(opts);
        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me) {

        let dataObj = _fnGetDataObj($me);

        let VALUE_CLIENT_ID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let VALUE_PAT_ID    = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
        let VALUE_DOS       = $('#' + dataObj.opts.PARM_NAME_DOS).val();
        let VALUE_ACTIVE    = '1';

        let NV_CLIENT_ID    = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_PAT_ID       = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PAT_ID, VALUE_PAT_ID);
        let NV_DOS          = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_DOS, VALUE_DOS);
        let NV_ACTIVE       = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE, VALUE_ACTIVE);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DOS);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

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