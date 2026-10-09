; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ClientStudentInformationSystemsCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common 
 */

MBA.ClientStudentInformationSystemsCommon = (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME = 'Client Student Information Systems Common Methods';
    const _THIS_NS = 'mba-client-student-information-systems'
    const _JQ_DATA_NAME = 'jq-' + _THIS_NS;
    const _DATA_ATTR_BASE = 'data-' + _THIS_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
          PARM_NAME_CLIENT_ID: 'clientid'
        , PARM_NAME_ACTIVE: 'active'
        , PARM_NAME_API_URL: 'apiurl'
        , PARM_NAME_API_TOKEN: 'apitoken'
        , containerCtrlID: ''
        , sessionTimeOutUrl: ''
        , baseUrlView: ''
        , defaultPageRowOrder: ''
        , baseUrlAddNew: ''
        , baseUrlEdit: ''
        , baseUrlDelete: ''
        , baseURLStudentInfoSystemsViewSel: ''
        , baseURLAriesTestPage:'user_all_aries_api_test.aspx'
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

        opts.loadModeView = 'rest';
        opts.baseUrlView = optsIn.baseUrlView;
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = optsIn.defaultPageRowOrder;

        opts.saveModeAddNew = 'inline';
        opts.baseUrlAddNew = optsIn.baseUrlAddNew;
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inline';
        opts.baseUrlEdit = optsIn.baseUrlEdit;
        opts.baseUrlEditHasParameters = true;

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = optsIn.baseUrlDelete;
        opts.baseUrlDeleteHasParameters = true;

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        let studentInfoSystemNamesOpts = {};
        studentInfoSystemNamesOpts.baseUrl = optsIn.baseURLStudentInfoSystemsViewSel;
        studentInfoSystemNamesOpts.loadMode = 'mbaviewsel';
        studentInfoSystemNamesOpts.getInitialSelectedNameFrom = 'studentInfoSystemName';

        studentInfoSystemNamesOpts.fnModifyRequestNvps = function (nvpsIn) {
            return nvpsIn;
        };

        studentInfoSystemNamesOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
        studentInfoSystemNamesOpts.fnModifyRenderItem = function ($ul, item, $li) { return $li; };
        studentInfoSystemNamesOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };
        studentInfoSystemNamesOpts.fnOnSelect = function (event, ui) { };

        opts.fieldDefinitions.push({
              name: 'studentInfoSystemID'
            , label: 'Information System'
            , toolTip: 'What information system'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: studentInfoSystemNamesOpts
            , sortUsing: 'studentInfoSystemName'
            , saveUsing: 'studentinfosystemid'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'apiUrl'
            , label: 'API Endpoint URL'
            , toolTip: 'API URL for this information system'
            , visible: true
            , sortable: false
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'apiUrl'
            , saveUsing: 'apiurl'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'apiToken'
            , label: 'Access Token'
            , toolTip: 'API access token for authentication'
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: ''
            , saveUsing: 'apitoken'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'schoolNamesToExclude'
            , label: 'School Names to Exclude<br><sup>Seperate using pipes (|)</br>'
            , toolTip: 'Pipe seperated list of school names to exclude from imports'
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'textarea'
            , sortUsing: ''
            , saveUsing: 'schoolnamestoexclude'
            , showMore: false
        });

        opts.fieldDefinitions.push({
              name: 'enabled'
            , label: 'Enabled'
            , toolTip: 'Enable or disable imports'
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'checkbox'
            , sortUsing: ''
            , saveUsing: 'enabled'
            , showMore: false
        });

        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.additionalControlDefinitionsForBodyRows.set('testAPI', {
            defType: 'userprovided'
            , name: 'testAPI'
            , toolTip: 'Click here to test API connection and test data access'
            , cssClass: 'fa fa-cog'
            , handlerFn: function (uiActionObj) {

                let _baseURL = '';
              
                if (uiActionObj.whatFieldNameValues.studentInfoSystemID === '1') {
                    _baseURL = optsIn.baseURLAriesTestPage;
                }

                if (_baseURL != '') {
                    let _parameters = [];
                    _parameters.push(MBA.ComponentCommon.fnCreateNameValueObject(optsIn.PARM_NAME_API_URL, uiActionObj.whatFieldNameValues.apiUrl));
                    _parameters.push(MBA.ComponentCommon.fnCreateNameValueObject(optsIn.PARM_NAME_API_TOKEN, uiActionObj.whatFieldNameValues.apiToken));
                    let _url = MBA.ComponentCommon.fnBuildUrl(_baseURL, true, _parameters);
                    
                    MBA.ComponentCommon.fnOpenTab(_url);
                }
                return uiActionObj;
            }
            , initiallyHidden: false
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