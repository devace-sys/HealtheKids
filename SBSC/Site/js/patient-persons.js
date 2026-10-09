; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PatientPersonsCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.PatientPersonsCommon = (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME                    = 'Patient Persons Common';
    const _THIS_NS                      = 'mba-patient-persons-common'
    const _JQ_DATA_NAME                 = 'jq-' + _THIS_NS;
    const _DATA_ATTR_BASE               = 'data-' + _THIS_NS;
    const _CONST_PHYSICIAN_DETAILS_REF = 'physician-details-ref';
    const _PAGE_CONTEXT_PATIENT_PROFILE = 1;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
        PARM_NAME_CLIENT_ID: 'clientid'
        , PARM_NAME_PAT_ID: 'patid'
        , PARM_NAME_TERM: 'term'
        , PARM_NAME_ACTIVE: 'active'
        , PARM_PERSON_ROLE_ID: ''
        , PARM_MIDDLE_NAME: ''
        , PARM_PERSON_CLASS_ID_1: 'personclassid1'
        , PARM_PERSON_CLASS_ID_2: 'personclassid2'
        , containerCtrlID: ''
        , sessionTimeOutUrl: ''
        , baseUrlView: ''
        , defaultPageRowOrder: ''
        , baseUrlAddNew: ''
        , baseUrlEdit: ''
        , baseUrlDelete: ''
        , baseUrlReport: ''
        , defaultReportNumber: ''
        , enableRowNumbers: true
        , autoHidePageControls: false
        , enableScrollView: false
        , scrollViewUseCustomHeight: true
        , scrollViewCustomHeight: '15em'
        , isPcalStaff: true
        , fnOnResponseViewFromServer: function (elem, responseData, $me, dataObj) { return; }
        , fnCreateNewCellAfter: function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) { return newCell; }
        , showOnlyParentGuardian: false
        , enableRowControlMarkRow: false
        , viewOnly: false
        , viewOnlyShowClientName: true
        , viewOnlyShowPatientName: true
        , enableReports: false
        , requestViewAfterInit: true
        , useClientIDParameter: true
        , usePatientIDParameter: true
        , useSearchTermParameter: false
        , baseUrlInvitePortal: ''
        , baseUrlInvitePatientPortal: ''
        , currentPage: ''

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

    let _fnClearPhysicianDetails = function (mapReference) {
        $(mapReference.get('hasRoleDetBut')).val('').attr('value', '');
        $(mapReference.get('fax')).val('').attr('value', '');
        $(mapReference.get('additionaldata1')).val('').attr('value', '');
        $(mapReference.get('additionaldata2')).val('').attr('value', '');
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnShowOrHidePhysicianDetails = function (hasRoleDetails, dsDetailsRef, openDetails) {

        if (hasRoleDetails === 'true') {
            $(dsDetailsRef).show();
        }
        else if (hasRoleDetails === 'false') {
            $(dsDetailsRef).hide();
        }
        else {
            $(dsDetailsRef).hide();
        }

        if (openDetails === true) {
            $(dsDetailsRef).attr('open', true).prop('open', true);
        }
        else {
            $(dsDetailsRef).attr('open', false).prop('open', false);
        }
        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _roleSelHandlerFn = function (uiActionObj) {
        if (uiActionObj.e.type === 'change') {
            _fnClearPhysicianDetails(uiActionObj.saveableFieldsMap);

            let $roleSel = uiActionObj.whatElement;
            let roleDetailsRefObj = $($roleSel).data(_CONST_PHYSICIAN_DETAILS_REF);
            let roleID = uiActionObj.whatFieldCellsInputValues.get('classID2');

            if (roleID == "2000") { // physician
                roleDetailsRefObj.hasRoleDetBut = 'true';
                $(roleDetailsRefObj.addCellValRefsMap.get('hasRoleDetBut')).val('true');
            }
            else {
                roleDetailsRefObj.hasRoleDetBut = 'false';
                $(roleDetailsRefObj.addCellValRefsMap.get('hasRoleDetBut')).val('false');
            }
            $($roleSel).data(_CONST_PHYSICIAN_DETAILS_REF, roleDetailsRefObj);
            showOrHidePhysicianDetails(roleDetailsRefObj.hasRoleDetBut, roleDetailsRefObj.dsDetails, true);
        };
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnIsPatientProfilePage = function (currentPage) {
        return parseInt(currentPage || 0, 10) === _PAGE_CONTEXT_PATIENT_PROFILE;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _createRestView = function ($me, optsIn) {

        let isPatientProfilePage = _fnIsPatientProfilePage(optsIn.currentPage);

        let opts = {};

        opts.autoHidePageControls 		= optsIn.autoHidePageControls;
        opts.enableScrollView 			= optsIn.enableScrollView;
        opts.scrollViewUseCustomHeight 	= optsIn.scrollViewUseCustomHeight;
        opts.scrollViewCustomHeight 	= optsIn.scrollViewCustomHeight;
        opts.enableRowControlMarkRow 	= optsIn.enableRowControlMarkRow;
        opts.enableRowNumbers 			= optsIn.enableRowNumbers;
        opts.sessionTimeOutUrl 			= optsIn.sessionTimeOutUrl;
        opts.requestViewOnLoad 			= false; /*This is so we can set the initial filters */
        opts.enableSortControls 		= true;
        opts.enableRowControls = true;        

        if (optsIn.viewOnly === false) {
            opts.enableRowControlRecAddNew = true;
            opts.enableRowControlRecEdit = true;

            if (optsIn.isPcalStaff == true)
                opts.enableRowControlRecDelete = true;
            else
                opts.enableRowControlRecDelete = false;
        }
        else {
            opts.enableRowControlRecAddNew = false;
            opts.enableRowControlRecEdit = false;
            opts.enableRowControlRecDelete = false
        }

        opts.saveModeAddNew = 'inline';
        opts.baseUrlAddNew = optsIn.baseUrlAddNew;
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inline';
        opts.baseUrlEdit = optsIn.baseUrlEdit;
        opts.baseUrlEditHasParameters = true;
        opts.refreshViewAfterInlineEditProceed = true;

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = optsIn.baseUrlDelete;
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = optsIn.baseUrlView
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = optsIn.defaultPageRowOrder;


        opts.enableReports = optsIn.enableReports;
        opts.enableReportHtml = true;
        opts.enableReportXls = true;
        opts.enableReportPdf = false;

        opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport = optsIn.baseUrlReport;
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = optsIn.defaultReportNumber

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        if (isPatientProfilePage) {
            opts.fieldDefinitions.push({
                name: 'portalInviteIndicator',
                label: '',
                toolTip: 'Parent/Guardian Portal Invite',
                visible: true,
                sortable: false,
                saveable: false,
                editable: false,
                isRecID: false,
                dataType: 'text',
                sortUsing: '',
                saveUsing: '',
                showMore: false
                , additionalCssClassesForColTop: 'text-center'
                , additionalCssClassesForColLabel: 'text-center'
                , additionalCssClassesForCell: 'text-center'
                , additionalCssClassesForCellValue: 'text-center'
                , styleAttrValueForCellValue: 'width:7em'
            });
        }

        opts.fieldDefinitions.push({
            name: 'lastName'
            , label: 'Last Name'
            , toolTip: 'Last Name'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'lastName'
            , saveUsing: 'lastname'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'firstName'
            , label: 'First Name'
            , toolTip: 'First Name'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'firstName'
            , saveUsing: 'firstname'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'middleName'
            , label: 'Middle Name'
            , toolTip: 'Middle Name'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: 'middleName'
            , saveUsing: 'middlename'
            , showMore: false
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        let roleIDAdditionalCellValueFieldDefinitions = [];

        roleIDAdditionalCellValueFieldDefinitions.push({
            name: 'hasRoleDetBut'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: ''
            , showMore: false
        });

        roleIDAdditionalCellValueFieldDefinitions.push({
            name: 'fax'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'fax'
            , showMore: false
        });

        roleIDAdditionalCellValueFieldDefinitions.push({
            name: 'additionalData1'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'additionaldata1'
            , showMore: false
        });

        roleIDAdditionalCellValueFieldDefinitions.push({
            name: 'additionalData2'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'additionaldata2'
            , showMore: false
        });

        let roleFieldOptions = {};
        if (optsIn.showOnlyParentGuardian == true) {
            roleFieldOptions.selections = [
                { name: 'Mother', value: '1000' }
                , { name: 'Father', value: '1001' }
                , { name: 'Guardian / Surrogate', value: '1002' }
            ];
        } else {
            roleFieldOptions.selections = [
                { name: 'Mother', value: '1000' }
                , { name: 'Father', value: '1001' }
                , { name: 'Guardian / Surrogate', value: '1002' }
                , { name: 'School Nurse', value: '5000' }
                , { name: 'Mental Health Provider', value: '5001' }
                , { name: 'General Ed Teacher', value: '5002' }
                , { name: 'Physician', value: '2000' }
                , { name: 'Other School Staff', value: '3003' }
                , { name: 'Outside Agency Representative', value: '6000' }
                , { name: 'Outside School Representative', value: '6001' }
                , { name: 'Parent Representative', value: '6002' }
            ];
        };
        opts.fieldDefinitions.push({
            name: 'classID2'
            , label: 'Role'
            , toolTip: 'Role'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: roleFieldOptions
            , sortUsing: 'classID2'
            , saveUsing: 'personrelationshipid'
            , showMore: false
            , handlerFn: function (uiActionObj) {
                _roleSelHandlerFn(uiActionObj);
                return uiActionObj;
            }
            , additionalCellValueFieldDefinitions: roleIDAdditionalCellValueFieldDefinitions
        });

        if (optsIn.viewOnly === true) {
            if (optsIn.viewOnlyShowPatientName === true) {
                opts.fieldDefinitions.push({
                    name: 'patientName'
                    , label: 'Patient Name'
                    , toolTip: 'Related to this patient/student'
                    , visible: true
                    , sortable: true
                    , saveable: false
                    , editable: false
                    , isRecID: false
                    , dataType: 'text'
                    , showMore: false
                    , sortUsing: 'patientName'
                });
            }
            if (optsIn.viewOnlyShowClientName === true) {
                opts.fieldDefinitions.push({
                    name: 'clientName'
                    , label: 'District'
                    , toolTip: 'Patient/student enrolled at'
                    , visible: true
                    , sortable: true
                    , saveable: false
                    , editable: false
                    , isRecID: false
                    , dataType: 'text'
                    , showMore: false
                    , sortUsing: 'clientName'
                });
            }
        } /* View only */

        opts.fieldDefinitions.push({
            name: 'email'
            , label: 'Email'
            , toolTip: 'Email'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'email'
            , saveUsing: 'email'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'phone'
            , label: 'Phone'
            , toolTip: 'Phone'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'phone'
            , saveUsing: 'phone'
            , showMore: false
        });

        let addressAdditionalCellValueFieldDefinitions = [];

        addressAdditionalCellValueFieldDefinitions.push({
            name: 'address1'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'address1'
            , showMore: false
        });

        addressAdditionalCellValueFieldDefinitions.push({
            name: 'address2'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'address2'
            , showMore: false
        });

        addressAdditionalCellValueFieldDefinitions.push({
            name: 'city'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'city'
            , showMore: false
        });

        addressAdditionalCellValueFieldDefinitions.push({
            name: 'state'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'state'
            , showMore: false
        });

        addressAdditionalCellValueFieldDefinitions.push({
            name: 'zip5'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'zip5'
            , showMore: false
        });

        addressAdditionalCellValueFieldDefinitions.push({
            name: 'zip4'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'zip4'
            , showMore: false
        });

        /* Address column */

        opts.fieldDefinitions.push({
            name: 'address'
            , label: 'Address'
            , toolTip: 'Address'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: ''
            , additionalCellValueFieldDefinitions: addressAdditionalCellValueFieldDefinitions
        });


        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) {

            if (fieldDefinition.name === 'classID2') {

                let hasRoleDetButVal = (rowData.classID2 == 2000) ? 'true' : 'false';

                let $rowRef = $(newRow)[0];
                let $dsDetails = $('<details class="physician-details" title="This Role Requires More Information"></details>');
                $dsDetails.append('<summary class="physician-details">Show Details</summary>');
                $(newCell).append($dsDetails);

                /* Setup hasRoleDetBut */

                let hasRoleDetButCellRef = addCellValRefsMap.get('hasRoleDetBut');
                $(hasRoleDetButCellRef).on(MBA.RestViewCommon.EVENT_NAME_EDIT_CANCEL + ' ' + MBA.RestViewCommon.EVENT_NAME_EDIT_PROCEED, function (e) {
                    _fnShowOrHidePhysicianDetails(hasRoleDetButVal, $dsDetails, false);
                });

                /* Setup input for fax */

                let faxCellRef = addCellValRefsMap.get('fax');
                $(faxCellRef).attr('type', 'text');
                if ($(faxCellRef).val() == 'null' || $(faxCellRef).val() == 'undefined') {
                    $(faxCellRef).val('');
                }
                let $faxDiv = $('<div class="mb-2"></div>');
                $($faxDiv).append('<span class="mr-2">Fax</span>').append($(faxCellRef));

                /* Setup input for NPI */

                let npiCellRef = addCellValRefsMap.get('additionalData1');
                $(npiCellRef).attr('type', 'text');
                if ($(npiCellRef).val() == 'null' || $(npiCellRef).val() == 'undefined') {
                    $(npiCellRef).val('');
                }
                let $npiDiv = $('<div class="mb-2"></div>');
                $($npiDiv).append('<span class="mr-2">NPI</span>').append($(npiCellRef));

                /* Setup input for Medi-Cal Provider */

                let mediCalProviderCellRef = addCellValRefsMap.get('additionalData2');
                $(mediCalProviderCellRef).attr('type', 'text');
                if ($(mediCalProviderCellRef).val() == 'null' || $(mediCalProviderCellRef).val() == 'undefined') {
                    $(mediCalProviderCellRef).val('');
                }

                let $mediCalProviderDiv = $('<div class="mb-2"></div>');
                $($mediCalProviderDiv).append('<span class="mr-2">Medi-Cal Provider ID</span>').append($(mediCalProviderCellRef));

                $($dsDetails).append($faxDiv);
                $($dsDetails).append($npiDiv);
                $($dsDetails).append($mediCalProviderDiv);

                /* Create an object we can reference if there are changes made to the nameID (autocomplete) */

                let physicianDetailsRefObj = {};
                physicianDetailsRefObj.rowRef = $rowRef;
                physicianDetailsRefObj.hasRoleDetBut = hasRoleDetButVal;
                physicianDetailsRefObj.dsDetails = $dsDetails;
                physicianDetailsRefObj.addCellValRefs = addCellValRefs;
                physicianDetailsRefObj.addCellValRefsMap = addCellValRefsMap;

                /* Save this object */

                $(newCellValueElem).data(_CONST_PHYSICIAN_DETAILS_REF, physicianDetailsRefObj);

                /* Show or hide details based on initial data loaded from server */

                _fnShowOrHidePhysicianDetails(hasRoleDetButVal, $dsDetails, false);
            }


            else if (fieldDefinition.name === 'address') {
                let $rowRef = $(newRow)[0];
                let $dsDetails = $('<details class="address-details" title="This Column Requires More Information"></details>');
                $dsDetails.append('<summary class="address-details">Show Details</summary>');
                $(newCell).append($dsDetails);

                /* Setup inputs */

                let address1CellRef = addCellValRefsMap.get('address1');
                $(address1CellRef).attr('type', 'text');
                if ($(address1CellRef).val() == 'null' || $(address1CellRef).val() == 'undefined') {
                    $(address1CellRef).val('');
                }
                let $address1Div = $('<div class="mb-2"></div>');
                $($address1Div).append('<span class="mr-2">Street Address 1</span>').append($(address1CellRef));

                let address2CellRef = addCellValRefsMap.get('address2');
                $(address2CellRef).attr('type', 'text');
                if ($(address2CellRef).val() == 'null' || $(address2CellRef).val() == 'undefined') {
                    $(address2CellRef).val('');
                }
                let $address2Div = $('<div class="mb-2"></div>');
                $($address2Div).append('<span class="mr-2">Street Address 2</span>').append($(address2CellRef));

                let cityCellRef = addCellValRefsMap.get('city');
                $(cityCellRef).attr('type', 'text');
                if ($(cityCellRef).val() == 'null' || $(cityCellRef).val() == 'undefined') {
                    $(cityCellRef).val('');
                }
                let $cityDiv = $('<div class="mb-2"></div>');
                $($cityDiv).append('<span class="mr-2">City</span>').append($(cityCellRef));

                let stateCellRef = addCellValRefsMap.get('state');
                $(stateCellRef).attr('type', 'text');
                if ($(stateCellRef).val() == 'null' || $(stateCellRef).val() == 'undefined') {
                    $(stateCellRef).val('');
                }
                let $stateDiv = $('<div class="mb-2"></div>');
                $($stateDiv).append('<span class="mr-2">State</span>').append($(stateCellRef));

                let zip5CellRef = addCellValRefsMap.get('zip5');
                $(zip5CellRef).attr('type', 'text');
                if ($(zip5CellRef).val() == 'null' || $(zip5CellRef).val() == 'undefined') {
                    $(zip5CellRef).val('');
                }
                let $zip5Div = $('<div class="mb-2"></div>');
                $($zip5Div).append('<span class="mr-2">Zip (First 5)</span>').append($(zip5CellRef));

                let zip4CellRef = addCellValRefsMap.get('zip4');
                $(zip4CellRef).attr('type', 'text');
                if ($(zip4CellRef).val() == 'null' || $(zip4CellRef).val() == 'undefined') {
                    $(zip4CellRef).val('');
                }
                let $zip4Div = $('<div class="mb-2"></div>');
                $($zip4Div).append('<span class="mr-2">Zip (Last 4)</span>').append($(zip4CellRef));

                $($dsDetails).append($address1Div);
                $($dsDetails).append($address2Div);
                $($dsDetails).append($cityDiv);
                $($dsDetails).append($stateDiv);
                $($dsDetails).append($zip5Div);
                $($dsDetails).append($zip4Div);
            }

            if (isPatientProfilePage && fieldDefinition.name === 'portalInviteIndicator') {

                $(newCell).addClass('portal-invite-cell').empty();

                let portalStatus = _fnResolvePortalStatus(rowData);
                let cssClass = _fnGetPortalInviteCssClass(portalStatus);
                let canInvite = _fnCanSendPortalInvite(rowData);
                let titleText = _fnGetPortalInviteTitle(rowData);

                let $inviteBtn = $(
                    '<button type="button" class="portal-invite-btn ' + cssClass + '" title="' + titleText + '">' +
                    '<i class="fas fa-envelope-open-text"></i>' +
                    '</button>'
                );

                if (!canInvite) {
                    $inviteBtn.prop('disabled', true).addClass('portal-invite-btn-disabled');
                } else {
                    $inviteBtn.on('click', function (e) {
                        e.preventDefault();
                        e.stopPropagation();

                        let dataObj = _fnGetDataObj($me);
                        let requestObj = {};

                        requestObj['recid'] = rowData.id;
                        requestObj[dataObj.opts.PARM_NAME_PAT_ID] = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
                        requestObj[dataObj.opts.PARM_NAME_CLIENT_ID] = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();

                        _fnInviteParentPortal(JSON.stringify(requestObj), dataObj, rowData, $inviteBtn);
                    });
                }

                $(newCell).append($inviteBtn);
            }

            /* Return cell new as required */

            return optsIn.fnCreateNewCellAfter(newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap);
        };

        opts.fnOnResponseViewFromServer = function (elem, responseData, $me, dataObj) {
            return optsIn.fnOnResponseViewFromServer(elem, responseData, $me, dataObj);
        }

        /* Create the rest view */

        $($me).MBA_RestView(opts);

        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnIsParentGuardianRole = function (classID2) {
        let roleID = parseInt(classID2, 10);
        return roleID === 1000 || roleID === 1001 || roleID === 1002;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnHasPortalAccount = function (rowData) {
        let userIDInt = parseInt(rowData.userIDInt || 0, 10);
        return userIDInt > 0;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnCanSendPortalInvite = function (rowData) {
        if (!_fnIsParentGuardianRole(rowData.classID2)) {
            return false;
        }

        if (_fnHasPortalAccount(rowData)) {
            return false;
        }

        return true;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetPortalInviteCssClass = function (portalStatus) {
        switch (portalStatus) {
            case 'active':
                return 'portal-invite-green';
            case 'disabled':
                return 'portal-invite-disabled';
            default:
                return 'portal-invite-red';
        }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnInviteParentPortal = function (reqData, dataObj, rowData, $inviteBtn) {

        let reqUrl = dataObj.opts.baseUrlInvitePortal;

        if ($inviteBtn) {
            $inviteBtn
                .prop('disabled', true)
                .removeClass('portal-invite-red portal-invite-green portal-invite-disabled')
                .addClass('portal-invite-yellow');
        }

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                let msg = 'Portal invitation processed successfully.';
                let result = null;

                try {
                    let jsonData = responseData.rawData.jsonData;
                    result = JSON.parse(jsonData);
                    if (result) {
                        if (result.message) {
                            msg = result.message;
                        } else if (result.accountAlreadyExists) {
                            msg = 'This parent/guardian already has a portal account.';
                        }
                    }
                } catch (ex) {
                    if ($inviteBtn) {
                        $inviteBtn
                            .prop('disabled', false)
                            .removeClass('portal-invite-yellow')
                            .addClass('portal-invite-red');
                    }
                    $.spedmonWebUI.dialogMessage('ERROR', 'The invitation request completed, but the response could not be processed.', null, 400, 200, null, null, null);
                    return;
                }

                $.spedmonWebUI.dialogMessage('Portal Invitation', msg, null, 420, 220, null, null, null);

                _updateAdditionalViewParameterValuesAndRequestViewFromServer(dataObj.me);
            })
            .catch(responseData => {
                if ($inviteBtn) {
                    $inviteBtn
                        .prop('disabled', false)
                        .removeClass('portal-invite-yellow')
                        .addClass('portal-invite-red');
                }
                let errMsg = (responseData && responseData.message)
                    ? responseData.message
                    : 'An error occurred while processing the portal invitation.';

                $.spedmonWebUI.dialogMessage('ERROR', errMsg, null, 400, 200, null, null, null);
            });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnResolvePortalStatus = function (rowData) {
        if (!_fnIsParentGuardianRole(rowData.classID2)) {
            return 'disabled';
        }

        if (_fnHasPortalAccount(rowData)) {
            return 'active';
        }

        return 'none';
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetPortalInviteTitle = function (rowData) {
        if (!_fnIsParentGuardianRole(rowData.classID2)) {
            return 'Portal invite not available for this role';
        }

        if (_fnHasPortalAccount(rowData)) {
            return 'This parent/guardian already has a portal account';
        }

        return 'Send portal invitation';
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me) {

        let dataObj = _fnGetDataObj($me);

        let VALUE_CLIENT_ID = '';
        let VALUE_PAT_ID = '';
        let VALUE_TERM = '';
        let VALUE_ACTIVE = '1';
        let VALUE_PERSON_ROLE_ID = '1';

        let VALUE_PERSON_CLASS_ID_1 = '';
        let VALUE_PERSON_CLASS_ID_2 = '';

        if (dataObj.opts.showOnlyParentGuardian == true) {
            VALUE_PERSON_CLASS_ID_1 = '1';
        }

        if (dataObj.opts.useClientIDParameter == true) {
            VALUE_CLIENT_ID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        }

        if (dataObj.opts.usePatientIDParameter == true) {
            VALUE_PAT_ID = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
        }

        if (dataObj.opts.useSearchTermParameter == true) {
            VALUE_TERM = $('#' + dataObj.opts.PARM_NAME_TERM).val();
        }

        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_PAT_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PAT_ID, VALUE_PAT_ID);
        let NV_TERM = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_TERM, VALUE_TERM);
        let NV_ACTIVE = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE, VALUE_ACTIVE);
        let NV_PERSON_ROLE_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_PERSON_ROLE_ID, VALUE_PERSON_ROLE_ID);
        let NV_PERSON_CLASS_ID_1 = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PERSON_CLASS_ID_1, VALUE_PERSON_CLASS_ID_1);
        let NV_PERSON_CLASS_ID_2 = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PERSON_CLASS_ID_2, VALUE_PERSON_CLASS_ID_2);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PERSON_CLASS_ID_1);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PERSON_CLASS_ID_2);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_TERM);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PAT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PERSON_ROLE_ID);

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_PAT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_PERSON_ROLE_ID);

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_PAT_ID);

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

        if (opts.requestViewAfterInit === true) {
            _updateAdditionalViewParameterValuesAndRequestViewFromServer($me);
        }

        return $me;

    }; /*_fnSetup */

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        fnSetup: _fnSetup
        , fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer: _updateAdditionalViewParameterValuesAndRequestViewFromServer
    };

})(jQuery);