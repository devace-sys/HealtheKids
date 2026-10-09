; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ClientSchoolSessionBreaksCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.ClientSchoolSessionBreaksCommon = (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME = 'School Session Breaks Common Methods';
    const _THIS_NS = 'mba-client-school-session-breaks'
    const _JQ_DATA_NAME = 'jq-' + _THIS_NS;
    const _DATA_ATTR_BASE = 'data-' + _THIS_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
        PARM_NAME_CLIENT_ID: 'clientid'
        , PARM_NAME_ACTIVE: 'active'
        , containerCtrlID: ''
        , sessionTimeOutUrl: ''
        , baseUrlView: ''
        , defaultPageRowOrder: ''
        , baseUrlAddNew: ''
        , baseUrlEdit: ''
        , baseUrlDelete: ''
        , baseURLSchoolSessionAcademicYearSel: ''
        , baseURLClientSiteSel: ''
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

        opts.sessionTimeOutUrl = optsIn.sessionTimeOutUrl;
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = false; /* Turn off row numbers */
        opts.enableRowControls = true;
        opts.enableReports = false;
        opts.enableRowControlRecAddNew = true;
        opts.enableRowControlRecEdit = true;
        opts.enableRowControlRecDelete = true;
        opts.enableRowControlRecClone = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = optsIn.baseUrlView;
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = optsIn.defaultPageRowOrder;

        opts.saveModeAddNew = 'inline';
        opts.baseUrlAddNew = optsIn.baseUrlAddNew;
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeClone = 'inline';
        opts.baseUrlClone = optsIn.baseUrlAddNew;
        opts.baseUrlCloneHasParameters = true;

        opts.saveModeEdit = 'inline';
        opts.baseUrlEdit = optsIn.baseUrlEdit;
        opts.baseUrlEditHasParameters = true;

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = optsIn.baseUrlDelete;
        opts.baseUrlDeleteHasParameters = true;

        opts.fieldDefinitions = [];
        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        let schoolSessionAcademicYearAutoCompleteOptions = {};

        schoolSessionAcademicYearAutoCompleteOptions.baseUrl = optsIn.baseURLSchoolSessionAcademicYearSel;
        schoolSessionAcademicYearAutoCompleteOptions.loadMode = 'mbaviewsel';
        schoolSessionAcademicYearAutoCompleteOptions.getInitialSelectedNameFrom = 'academicYearName';
        schoolSessionAcademicYearAutoCompleteOptions.fnOnSelect = function (event, ui) { };
        schoolSessionAcademicYearAutoCompleteOptions.fnModifyRequestNvps = function (nvpsIn) {
            let VALUE_CLIENT_ID = $('#' + optsIn.PARM_NAME_CLIENT_ID).val();
            let NV_CLIENT = MBA.RestViewCommon.fnCreateNameValueObject(optsIn.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
            nvpsIn.push(NV_CLIENT); /* Change to replace once clientid is part of restview cells */
            return nvpsIn;
        };
        schoolSessionAcademicYearAutoCompleteOptions.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
        schoolSessionAcademicYearAutoCompleteOptions.fnModifyRenderItem = function ($ul, item, $li) { return $li; };
        schoolSessionAcademicYearAutoCompleteOptions.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

        opts.fieldDefinitions.push({
            name: 'academicYearID'
            , label: 'What School Year or Track?'
            , toolTip: 'What school year or track does this break or holiday apply to?'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: schoolSessionAcademicYearAutoCompleteOptions
            , sortUsing: 'academicYearName'
            , saveUsing: 'academicyearid'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'clientWideBreakStr'
            , label: 'District Wide Break?'
            , toolTip: 'Is the break for all sites in the district?'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'yesno'
            , sortUsing: 'clientWideBreak'
            , saveUsing: 'clientwidebreak'
            , showMore: false
        });

        let clientSiteAutoCompleteOptions = {};

        clientSiteAutoCompleteOptions.baseUrl = optsIn.baseURLClientSiteSel;
        clientSiteAutoCompleteOptions.loadMode = 'mbaviewsel';
        clientSiteAutoCompleteOptions.getInitialSelectedNameFrom = 'siteName';
        clientSiteAutoCompleteOptions.fnOnSelect = function (event, ui) { };
        clientSiteAutoCompleteOptions.fnModifyRequestNvps = function (nvpsIn) {
            let VALUE_CLIENT_ID = $('#' + optsIn.PARM_NAME_CLIENT_ID).val();
            let NV_CLIENT = MBA.RestViewCommon.fnCreateNameValueObject(optsIn.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
            nvpsIn.push(NV_CLIENT); /* Change to replace once clientid is part of restview cells */
            return nvpsIn;
        };
        clientSiteAutoCompleteOptions.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
        clientSiteAutoCompleteOptions.fnModifyRenderItem = function ($ul, item, $li) { return $li; };
        clientSiteAutoCompleteOptions.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

        opts.fieldDefinitions.push({
            name: 'siteID'
            , label: 'School Site'
            , toolTip: 'What Site?'
            , visible: true
            , sortable: false
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: clientSiteAutoCompleteOptions
            , sortUsing: 'siteName'
            , saveUsing: 'siteid'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'name'
            , label: 'Name of Break'
            , toolTip: 'The name of the break'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'name'
            , saveUsing: 'name'
            , showMore: false
            , dataListID: 'common-break-names'
        });

        opts.fieldDefinitions.push({
            name: 'startDateStrYMD'
            , label: 'Start Date'
            , toolTip: 'The date that the break starts'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'startDate'
            , saveUsing: 'startdate'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'endDateStrYMD'
            , label: 'End Date'
            , toolTip: 'The date that the break ends'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'endDate'
            , saveUsing: 'enddate'
            , showMore: false
        });

        /* Create the rest view */

        $($me).MBA_RestView(opts);
        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me) {
        let dataObj = _fnGetDataObj($me);

        let VALUE_CLIENT_ID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let VALUE_ACTIVE = '1';

        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_ACTIVE = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE, VALUE_ACTIVE);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        /* We need these for the various rec ops */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForCloneSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_CLIENT_ID);


        $(dataObj.restViewCtrl).MBA_RestView('requestViewFromServer', 1);
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

    }; /*_fnSetup */

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        fnSetup: _fnSetup
        , fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer: _updateAdditionalViewParameterValuesAndRequestViewFromServer
    };

})(jQuery);