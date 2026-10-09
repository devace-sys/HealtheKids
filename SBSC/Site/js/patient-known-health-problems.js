; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PatientKnownHealthProblemsCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.PatientKnownHealthProblemsCommon = (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME      = 'Patient Known Health Problems Common Methods';
    const _THIS_NS        = 'mba-patient-known-health-problems'
    const _JQ_DATA_NAME   = 'jq-' + _THIS_NS;
    const _DATA_ATTR_BASE = 'data-' + _THIS_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
          PARM_NAME_CLIENT_ID: ''
        , PARM_NAME_PAT_ID: ''
        , PARM_NAME_ACTIVE: ''        
        , containerCtrlID: ''
        , sessionTimeOutUrl: ''
        , baseUrlView: ''
        , defaultPageRowOrder: ''
        , baseUrlAddNew: ''
        , baseUrlEdit: ''
        , baseUrlDelete: ''
        , baseUrlKnownHealthProblemIDSel: ''
        , enableScrollView: true
        , scrollViewUseCustomHeight: false
        , scrollViewCustomHeight: ''
        , autoHidePageControls: true
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

        opts.showCaption                = false;
        opts.enableScrollView           = optsIn.enableScrollView;
        opts.scrollViewUseCustomHeight  = optsIn.scrollViewUseCustomHeight
        opts.scrollViewCustomHeight     = optsIn.scrollViewCustomHeight;
        opts.autoHidePageControls       = optsIn.autoHidePageControls;

        opts.sessionTimeOutUrl         = optsIn.sessionTimeOutUrl;
        opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */
        opts.enableSortControls        = false;
        opts.enableRowNumbers          = false; /* Turn off row numbers */
        opts.enableRowControls         = true;
        opts.enableReports             = false;

        opts.enableRowControlRecAddNew = optsIn.showAddNew;
        opts.enableRowControlRecEdit   = optsIn.showEdit;
        opts.enableRowControlRecDelete = optsIn.showDelete;
        opts.enableRowControlRecClone  = false;

        opts.loadModeView               = 'rest';
        opts.baseUrlView                = optsIn.baseUrlView;
        opts.baseUrlViewHasParameters   = true;
        opts.defaultPageRowOrder        = optsIn.defaultPageRowOrder;

        opts.saveModeAddNew             = 'inwindow';
        opts.baseUrlAddNew              = optsIn.baseUrlAddNew;
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit               = 'inwindow';
        opts.baseUrlEdit                = optsIn.baseUrlEdit;
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = optsIn.baseUrlDelete;
        opts.baseUrlDeleteHasParameters = true;

        opts.fieldDefinitions = [];
        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.fieldDefinitions.push({
              name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });
         /*
        let knownHealthProblemIDOpts = {};
		
        knownHealthProblemIDOpts.baseUrl                    = optsIn.baseUrlKnownHealthProblemIDSel;
        knownHealthProblemIDOpts.loadMode                   = 'mbaviewsel';
        knownHealthProblemIDOpts.getInitialSelectedNameFrom = 'knownHealthProblemName';
        knownHealthProblemIDOpts.fnOnSelect                 = function (event, ui) { };
        knownHealthProblemIDOpts.fnModifyRequestNvps        = function (nvpsIn) {return nvpsIn;};
        knownHealthProblemIDOpts.fnModifyResponseSelRecs    = function (requestNvps, SelRecs) { return SelRecs; };
        knownHealthProblemIDOpts.fnModifyRenderItem         = function ($ul, item, $li) {return $li;};
        knownHealthProblemIDOpts.fnHandleCellValueAction    = function (uiActionObj) { return uiActionObj; };
        */
        /* Note: We are using the label for this column as the caption for the rest view essentially */
        /* If we add additional visible columns it will be neccessary to label this different */

        opts.fieldDefinitions.push({
              name: 'knownHealthProblemName'
            , label: 'Known Health Problems'
            , visible: true
            , sortable: false
            , editable: false
            , saveable: false
            , saveUsing: ''
            , isRecID: false
            , dataType: 'string'
            /*  , dataTypeOptions: knownHealthProblemIDOpts  */
            , sortUsing: 'knownHealthProblemName'
            , showMore: false
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel:'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:10em'
        });

        /* Cell hooks */

        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {

            if ((subsection === 103) && (rowtype === 4)) {

                if (fieldDefinition.name === 'knownHealthProblemName') {
                    let $knownHealthProblemContainer = $('<span></span>');

                    if (rowData.isPriority) {
                        $($newCellValue).append('<i class="ml-1 fas fa-exclamation-triangle text-danger cursor:none"></i>');
                    }

                    if (rowData.notes != '') {
                        $($knownHealthProblemContainer).attr('style', 'cursor:pointer');
                        $($knownHealthProblemContainer).attr('title', rowData.notes);
                    }

                    $($newCellValue).wrap($knownHealthProblemContainer);



                } /* knownHealthProblemName */
            }

            /* Return cell new as required */
            return newCell;
        };
       
        /* Create the rest view */

        $($me).MBA_RestView(opts);

        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me) {

        let dataObj = _fnGetDataObj($me);

        let VALUE_CLIENT_ID               = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let VALUE_PAT_ID                  = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
        let VALUE_ACTIVE                  = '1';
        
        let NV_CLIENT_ID  = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_PAT_ID     = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PAT_ID,    VALUE_PAT_ID);
        let NV_ACTIVE     = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE,    VALUE_ACTIVE);
        let NV_REC_ID     = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_REC_ID, "");
        /* Pass in required nvps for view */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);      
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        /* Pass in required nvps for add new */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);      
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PAT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_ACTIVE);

		/* Pass in required nvps for edit */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_CLIENT_ID);      
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_PAT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_ACTIVE);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_REC_ID);



		/* Pass in required nvps for delete */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_CLIENT_ID);      
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_PAT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_ACTIVE);
		
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

        let $restViewCtrl      = $me;
        dataObj.restViewCtrl   = $restViewCtrl;
        _createRestView($restViewCtrl, opts);

        /* Get reference to container control to listen for events on */

        let $containerCtrl    = $('#' + opts.containerCtrlID);
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