;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PatientInsuranceCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.PatientInsuranceCommon = (function ($)
{

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME = 'Patient Insurance Common Methods';
    const _THIS_NS = 'mba-patient-insurance-coverage';
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
        , baseUrlInsuranceCarrierIDSel:''
        , enableScrollView: true
        , scrollViewUseCustomHeight: false
        , scrollViewCustomHeight: ''
        , autoHidePageControls: true
        , fnGetPatientLastName: function () {
            return $('#profile-lname').val();
        }
        , fnGetPatientFirstName: function () {
            return $('#profile-fname').val();
        }
        , showPatNameDobAndSSID: false
        , fnOnResponseViewFromServer: function (elem, responseData, $me, dataObj) { return; }
        , enableRowControlDelete: false        
        , baseUrlPatIDSel : ''
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

    let _fnDeleteMulti = function (uiActionObj) {
        
        let dataObj = _fnGetDataObj(uiActionObj.me);
        let _recIDs = '';
        _recIDs = MBA.RestViewCommon.fnGetMarkedRowsRecordIDsAsCsvStr(uiActionObj.me);

        if (_recIDs == '') return;

        let VALUE_CLIENT_ID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();

        let $ctrlDeleteMarked = MBA.RestViewCommon.fnFindHeaderControl(uiActionObj.me, 'deleteMarked');

        let _reqObj = {};
        _reqObj.recids   = _recIDs;
        _reqObj.clientid = VALUE_CLIENT_ID;
        
        let _requestDataJSON = JSON.stringify(_reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlDelete, _requestDataJSON, dataObj.opts.sessionTimeOutUrl)
            .then(responseData => {
                $(uiActionObj.me).MBA_RestView('refreshCurrentViewFromServer', 1);
                MBA.RestViewCommon.fnAnimateRowControlInfinite($ctrlDeleteMarked, 'bounce', true, true);
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Delete Record(s)', err.message, {});
            });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _createRestView = function ($me, optsIn) {

        let opts = {};

        opts.sessionTimeOutUrl           = optsIn.sessionTimeOutUrl;
        opts.requestViewOnLoad           = false; /*This is so we can set the initial filters */
        opts.enableSortControls          = false;
        opts.enableRowNumbers            = false;
        opts.enableRowControls           = true;
        opts.enableRowControlRecAddNew   = true;
        opts.enableRowControlRecEdit     = true;
        opts.enableRowControlRecDelete   = optsIn.enableRowControlRecDelete;
        opts.enableRowControlRecUnDelete = false;
        opts.enableScrollView            = optsIn.enableScrollView;                
        opts.scrollViewUseCustomHeight   = optsIn.scrollViewUseCustomHeight;
        opts.scrollViewCustomHeight      = optsIn.scrollViewCustomHeight;
        opts.autoHidePageControls        = optsIn.autoHidePageControls;
        
        opts.loadModeView                = 'rest';
        opts.baseUrlView                 = optsIn.baseUrlView;
        opts.baseUrlViewHasParameters    = true;
        opts.defaultPageRowOrder         = optsIn.defaultPageRowOrder;

        opts.saveModeAddNew              = 'inline';
        opts.baseUrlAddNew               = optsIn.baseUrlAddNew;
        opts.baseUrlAddNewHasParameters  = true;

        opts.saveModeEdit                = 'inline';
        opts.baseUrlEdit                 = optsIn.baseUrlEdit
        opts.baseUrlEditHasParameters    = true;

        if (optsIn.enableRowControlRecDelete === true) {

            opts.saveModeDelete              = 'custom';
            opts.enableMarkRowWithoutControl = true;
            
            opts.handlerFnDeleteCustom = function (uiActionObj) {
                uiActionObj = MBA.RestViewCommon.fnMarkRow(uiActionObj);
                let rowIsMarked = MBA.RestViewCommon.fnIsRowMarked(uiActionObj.whatRow);
                if (rowIsMarked === true) {
                    MBA.RestViewCommon.fnHighlightRow(uiActionObj.whatRow, false);                    
                } else {                    
                    MBA.RestViewCommon.fnHighlightRow(uiActionObj.whatRow, true);
                }
                return uiActionObj;
            };

            opts.additionalControlDefinitionsForHeadRows = new Map();

            opts.additionalControlDefinitionsForHeadRows.set('deleteMarked', {
                defType: 'userprovided'
                , name: 'deleteMarked'
                , toolTip: 'Click here to delete all highlighted rows.'
                , cssClass: 'fas fa-trash-alt text-danger'
                , handlerFn: function (uiActionObj) {
                    _fnDeleteMulti(uiActionObj);                    
                    return uiActionObj;
                }
                , initiallyHidden: false
            });

            opts.fnOnRowMarked = function (uiActionObj, _markedRows) {                
                let $ctrlDeleteMarked = MBA.RestViewCommon.fnFindHeaderControl(uiActionObj.me, 'deleteMarked');
                if ($(_markedRows).length > 0) {
                    MBA.RestViewCommon.fnAnimateRowControlInfinite($ctrlDeleteMarked, 'bounce', true, false);
                }
                else {
                    MBA.RestViewCommon.fnAnimateRowControlInfinite($ctrlDeleteMarked, 'bounce', true, true);
                }
                return uiActionObj;
            };
        }

        opts.fieldDefinitions = [];
        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
            , visible: false
        });

        if (optsIn.showPatNameDobAndSSID === true) {

            /* Patient */

            let patIDOpts = {};

            patIDOpts.baseUrl  = optsIn.baseUrlPatIDSel;
            patIDOpts.loadMode = 'mbaviewsel';
            patIDOpts.fnOnOpen = function (event, ui, $acObj) {
                $($acObj).css('width', '40em');
                return;
            };

            patIDOpts.getInitialSelectedNameFrom = 'patName';
            patIDOpts.fnOnSelect = function (event, ui) { };

            patIDOpts.fnModifyRequestNvps = function (nvpsIn) {
                
                let _cid = $('#' + optsIn.PARM_NAME_CLIENT_ID).val();

                MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, optsIn.PARM_NAME_CLIENT_ID, _cid);
                MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'pracid', '');
                MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'patdatasource', '1');
                MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'dos', '');
                return nvpsIn;
            };

            patIDOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };

            patIDOpts.fnModifyRenderItem = function ($ul, item, $li) {
                let ctxt1 = $('<br><sup>' + item.context1 + '</sup>')
                $($li).children('a').append(ctxt1);
                return $li;
            };

            patIDOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

            opts.fieldDefinitions.push({
                name: 'patID'
                , label: 'Patient<br>(Last Name, First)'
                , toolTip: 'Patient'
                , visible: true
                , sortable: true
                , editable: true
                , saveable: true
                , saveUsing: 'patid'
                , isRecID: false
                , dataType: 'autocomplete'
                , dataTypeOptions: patIDOpts
                , sortUsing: 'patName'
                , showMore: false
                , additionalCssClassesForColTop: 'text-left'
                , additionalCssClassesForColLabel: 'text-left'
                , additionalCssClassesForCell: 'text-left'
                , additionalCssClassesForCellValue: 'text-left'
            });
           
        }

        let insCarrierIdOpts = {};

        insCarrierIdOpts.baseUrl                    = optsIn.baseUrlInsuranceCarrierIDSel;
        insCarrierIdOpts.loadMode                   = 'mbaviewsel';
        insCarrierIdOpts.getInitialSelectedNameFrom = 'insuranceCarrierName';

        insCarrierIdOpts.fnModifyRequestNvps        = function (nvpsIn) { return nvpsIn; };
        insCarrierIdOpts.fnModifyResponseSelRecs    = function (requestNvps, SelRecs) { return SelRecs; };
        insCarrierIdOpts.fnModifyRenderItem         = function ($ul, item, $li) { return $li; };
        insCarrierIdOpts.fnHandleCellValueAction    = function (uiActionObj) { return uiActionObj; };
        insCarrierIdOpts.fnOnSelect                 = function (event, ui) { };
               
        opts.fieldDefinitions.push({
            name: 'insuranceCarrierID'
            , label: 'Insurer Carrier'
            , toolTip: 'Carrier name'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: insCarrierIdOpts
            , saveUsing: 'insurancecarrierid'
            , sortUsing: 'insuranceCarrierName'
            , showMore: false
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:10em'
        });     

        opts.fieldDefinitions.push({
            name: 'primaryCarrier'
            , label: 'Primary Carrier?'
            , toolTip: 'Is the primary carrier?'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'checkbox'
            , saveUsing: 'primarycarrier'
            , sortUsing: 'primarycarrier'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:5em'
        });

        opts.fieldDefinitions.push({
            name: 'beneficiaryLastName'
            , label: 'Insured<br>Last Name'
            , toolTip: 'Insured Last Name'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'beneficiarylastname'
            , sortUsing: 'beneficiaryLastName'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:5em'
        });
       
        opts.fieldDefinitions.push({
            name: 'beneficiaryFirstName'
            , label: 'Insured<br>First Name'
            , toolTip: 'Insured First Name'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'beneficiaryfirstname'
            , sortUsing: 'beneficiaryFirstName'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:5em'
        });

        opts.fieldDefinitions.push({
            name: 'beneficiaryID'
            , label: 'Insurance ID'
            , toolTip: 'Membership number, policy number, medical record number, etc'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'beneficiaryid'
            , sortUsing: 'beneficiaryID'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:8em'
        });

        opts.fieldDefinitions.push({
            name: 'policyHolderName'
            , label: 'Policyholder<br>Name'
            , toolTip: 'policy holder'

            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'text'

            , sortUsing: 'policyHolderName'
            , saveUsing: 'policyholdername'

            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:10em'
        });

        opts.fieldDefinitions.push({
            name: 'policyGroupID'
            , label: 'Policy<br>Group ID'
            , toolTip: 'policy group id'

            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'text'

            , sortUsing: 'policyGroupID'
            , saveUsing: 'policygroupid'

            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:5em'
        });

        opts.fieldDefinitions.push({
            name: 'expiredOrInvalid'
            , label: 'Expired<br>Or<br>Invalid?'
            , toolTip: 'Expired or Invalid'

            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'checkbox'

            , sortUsing: 'expiredOrInvalid'

            , saveUsing: 'expiredorinvalid'

            , showMore: false
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:5em'
        });        

        opts.fieldDefinitions.push({
            name: 'cybhiRegisteredWithTpa'
            , label: 'CYBHI<br>Registered<br>With<br>TPA?'
            , toolTip: 'Is this the insurance data that is registered with the CYBHI third party administrator?'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'checkbox'
            , sortUsing: 'cybhiRegisteredWithTpa'
            , saveUsing: 'cybhiregisteredwithtpa'
            , showMore: false
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:5em'

        });

        opts.refreshViewAfterInlineEditProceed = true;

    
        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {

            /* For existing rows */

            if ((subsection === 103) && (rowtype === 4)) {
                if (fieldDefinition.name === 'insuranceCarrierID') {
                    if (rowData.planSupportedByCYBI === true) {
                        let $cybhiApprovedBadge = $('<span title="CYBHI Approved Plan" class="badge badge-success ml-2">CYBHI <i class="fa fa-check-circle"></i></span>');
                        $($cybhiApprovedBadge).insertAfter($newCellValue);                        
                    }
                }

                if (fieldDefinition.name === 'patID') {                                                            
                    let $dobSSID = $('<div class="mt-1"><sup>DOB: ' + rowData.dobStr + ' SSID: ' + rowData.ssid + '</sup></div>');
                    $($dobSSID).insertAfter($newCellValue);                    
                }
            }

            /* For new rows */

            if ((subsection === 102) && (rowtype === 2)) {
                if (fieldDefinition.name === 'beneficiaryLastName') {
                    $($newCellValue).val(optsIn.fnGetPatientLastName());
                } else if (fieldDefinition.name === 'beneficiaryFirstName') {
                    $($newCellValue).val(optsIn.fnGetPatientFirstName());
                }
            }

            return newCell;
        };

        opts.fnOnResponseViewFromServer = function (elem, responseData, $me, dataObj) {
            return optsIn.fnOnResponseViewFromServer(elem, responseData, $me, dataObj);
        }

        /* Create the rest view */

        $($me).MBA_RestView(opts);
        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me) {

        let dataObj = _fnGetDataObj($me);

        let VALUE_CLIENT_ID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let VALUE_PAT_ID    = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
        let VALUE_ACTIVE    = '1';

        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_PAT_ID    = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PAT_ID, VALUE_PAT_ID);
        let NV_ACTIVE    = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE, VALUE_ACTIVE);

        /* Pass in required nvps for view */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        /* Pass in required nvps for add new */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);

        if (dataObj.opts.showPatNameDobAndSSID === false) {
          $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PAT_ID);
        };
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_ACTIVE);

        /* Pass in required nvps for edit */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_CLIENT_ID);

        if (dataObj.opts.showPatNameDobAndSSID === false) {
          $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_PAT_ID);
        }
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_ACTIVE);

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