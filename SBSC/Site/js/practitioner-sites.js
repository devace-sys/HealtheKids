var MBA = MBA || {};

/**
 * @namespace    MBA.PractitionerSitesCommon
 * @memberof     MBA
 * @summary      Static methods used for Practitioner Sites tab
 */


MBA.PractitionerSitesCommon = (function ($) {

    'use strict';

    const _THIS_NAME    = 'Practitioner Sites Common Methods';
    const _THIS_NS      = 'mba-practitioner-sites';
    const _JQ_DATA_NAME = 'jq-' + _THIS_NS;

    const _DEFAULT_OPTIONS = {
        PARM_NAME_CLIENT_ID: 'clientid',
        PARM_NAME_PRAC_ID: 'pracid',
        PARM_NAME_ACTIVE: 'active',
        containerCtrlID: '',
        sessionTimeOutUrl: '',
        baseUrlView: 'api/v1/practitionersites',
        baseUrlAddNew: 'practitioner_sites.asmx/saveinline',
        baseUrlEdit: 'practitioner_sites.asmx/saveinline',
        defaultPageRowOrder: 'siteName asc, id desc',
        enableScrollView: true,
        scrollViewUseCustomHeight: false,
        scrollViewCustomHeight: '',
        autoHidePageControls: true
    };

    let _createRestView = function ($me, optsIn) {
        let opts = {
            ...optsIn,
            loadModeView: 'rest',
            baseUrlViewHasParameters: true,
            saveModeAddNew: 'inline',
            baseUrlAddNewHasParameters: true,
            saveModeEdit: 'inline',
            baseUrlEditHasParameters: true,
            enableRowControls: true,
            enableRowControlRecAddNew: true,
            enableRowControlRecEdit: true,
            enableRowControlRecDelete: false,
            enableScrollView: optsIn.enableScrollView,
            scrollViewUseCustomHeight: optsIn.scrollViewUseCustomHeight,
            scrollViewCustomHeight: optsIn.scrollViewCustomHeight,
            autoHidePageControls: optsIn.autoHidePageControls,
            defaultPageRowOrder: optsIn.defaultPageRowOrder,
            fieldDefinitions: [],
            additionalControlDefinitionsForBodyRows: new Map()
        };

        let pracSitesNameOpts = {};

        pracSitesNameOpts.baseUrl  = optsIn.baseUrlPracSiteIDSel;
        pracSitesNameOpts.loadMode = 'mbaviewsel';
        pracSitesNameOpts.getInitialSelectedNameFrom = 'siteName';

        pracSitesNameOpts.fnModifyRequestNvps = function (nvpsIn) {
            let VALUE_CLIENT_ID = $('#' + optsIn.PARM_NAME_CLIENT_ID).val();
            let NV_CLIENT       = MBA.RestViewCommon.fnCreateNameValueObject(optsIn.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
            nvpsIn.push(NV_CLIENT); 
            return nvpsIn;
        };

        pracSitesNameOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
        pracSitesNameOpts.fnModifyRenderItem = function ($ul, item, $li) { return $li; };
        pracSitesNameOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };
        pracSitesNameOpts.fnOnSelect = function (event, ui) { };

        opts.fieldDefinitions.push({
            name: 'siteID'
            , label: 'Site Name'
            , toolTip: 'Name of the Practitioner Site'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: pracSitesNameOpts
            , saveUsing: 'siteid'
            , sortUsing: 'siteName'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'clientID'
            , label: 'ClientID'
            , toolTip: 'ClientID of the Practitioner Site'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'clientid'
            , sortUsing: 'clientID'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'id'
            , label: 'RecID'
            , toolTip: 'ID of the Practitioner Site'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: true
            , dataType: 'text'
            , saveUsing: 'recid'
            , sortUsing: 'ID'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

       /* opts.fieldDefinitions.push({
            name: 'active',
            label: 'Active',
            visible: false,
            editable: true,
            saveable: true,
            dataType: 'checkbox',
            saveUsing: 'active',
            sortUsing: 'active'
        });
        */

        $($me).MBA_RestView(opts);
    };

    const _updateParamsAndView = function ($me) {
        let dataObj = $($me).data(_JQ_DATA_NAME);
        let opts = dataObj.opts;

        let nvps = [
            MBA.RestViewCommon.fnCreateNameValueObject(opts.PARM_NAME_CLIENT_ID, $('#' + opts.PARM_NAME_CLIENT_ID).val()),
            MBA.RestViewCommon.fnCreateNameValueObject(opts.PARM_NAME_PRAC_ID, $('#' + opts.PARM_NAME_PRAC_ID).val()),
            MBA.RestViewCommon.fnCreateNameValueObject(opts.PARM_NAME_ACTIVE, '1')
        ];

        nvps.forEach(nvp => {
            $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', nvp);
            $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', nvp);
            $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', nvp);
        });

        $(dataObj.restViewCtrl).MBA_RestView('requestViewFromServer', 1);
    };

    const _fnSetup = function (elementID, optsIn) {
        const $me = $('#' + elementID);
        if ($me.data(_JQ_DATA_NAME)) return;

        const opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);
        const dataObj = { me: $me, opts: opts, restViewCtrl: $me };
        $me.data(_JQ_DATA_NAME, dataObj);

        _createRestView($me, opts);

        $('#' + opts.containerCtrlID).on('spedmoninputdata', function () {
            _updateParamsAndView($me);
        });

        _updateParamsAndView($me);
    };

    return {
        fnSetup: _fnSetup,
        fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer: _updateParamsAndView
    };

})(jQuery);
