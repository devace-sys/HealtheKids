; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.CarePlansCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.CarePlansCommon = (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME = 'Care Plans Common Methods';
    const _THIS_NS = 'mba-care-plans';
    const _JQ_DATA_NAME = 'jq-' + _THIS_NS;
    const _DATA_ATTR_BASE = 'data-' + _THIS_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
         CONST_ATTR_CLIENT_ID: 'clientID'
        , PARM_NAME_PLAN_TYPE: 'plantypeid'
        , PARM_NAME_CLIENT_ID: 'clientid'
        , PARM_NAME_PAT_ID: 'patid'
        , PARM_NAME_REC_ID: 'recid'
        , PARM_NAME_TERM: 'term'
        , PARM_NAME_PRAC_ID: 'pracid'
        , PARM_NAME_GROUP_SVC_CLASS_NAME_ID: 'groupserviceclassnameid'
        , PARM_NAME_SITE_ID: 'siteid'
        , PARM_NAME_FISCAL_YEAR_ID: 'fiscalyearid'
        , PARM_NAME_IS_CREATED_BY_CALLER: 'iscreatedbycaller'
        , PARM_NAME_IS_EXPIRING: 'isexpiring'
        , PARM_NAME_IS_EXPIRED: 'isexpired'
        , PARM_NAME_ACTIVE: 'active'
        , ROLE_LEA_PROVIDER_ID: ''
        , sessionTimeOutUrl: ''
        , baseUrlClone: ''
        , baseUrlAddNew: ''
        , containerCtrlID: ''
        , baseUrlEdit: ''
        , baseUrlDelete: ''
        , baseUrlView: ''
        , defaultPageRowOrder: ''
        , baseUrlPDF: ''
        , baseUrlPatID: ''
        , baseUrlASMXReqAuth: ''
        , baseUrlChangePlanAuthor: ''
        , baseUrlSelectUser: ''
        , baseURLSaveDiagnoses: ''
        , baseURLDeleteDiagnoses: ''
        , baseURLViewDiagnoses: ''
        , baseURLCoorManage: ''
        , baseURLDeleteOrder: ''
        , baseUrlSelOrpDocs: ''
        , baseUrlSavePatPerson: ''
        , baseUrlViewSelPatPerson: ''
        , userPrevSignature: ''
        , userId: ''
        , lastName: ''
        , firstName: ''
        , email: ''
        , phone: ''
        , roleID: ''
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
        opts.sessionTimeOutUrl = optsIn.sessionTimeOutUrl;
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = true;
        opts.enableRowControlRecEdit = true;
        opts.enableRowControlRecDelete = true;
        opts.enableRowControlRecClone = true;
        opts.enableScrollView = optsIn.enableScrollView;                
        opts.scrollViewUseCustomHeight = optsIn.scrollViewUseCustomHeight;
        opts.scrollViewCustomHeight = optsIn.scrollViewCustomHeight;
        opts.autoHidePageControls = optsIn.autoHidePageControls;


        opts.saveModeClone = 'inline';
        opts.baseUrlClone = optsIn.baseUrlClone;
        opts.baseUrlCloneHasParameters = true;
        opts.additionalParameterDefinitionsForClone = new Map();

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
        opts.baseUrlView = optsIn.baseUrlView;
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = optsIn.defaultPageRowOrder;

        opts.enableReports = false;
        opts.enableReportHtml = false;
        opts.enableReportXls = false;
        opts.enableReportPdf = false;

        opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport = '';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '1';

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        //-----------------------------------------------------------------------------
        // Practitioner Name                                                           
        //-----------------------------------------------------------------------------

        /* Setup autocomplete - Basics */

        let patIDOpts = {};
        patIDOpts.baseUrl = optsIn.baseUrlPatID;
        patIDOpts.loadMode = 'mbaviewsel';
        patIDOpts.getInitialSelectedNameFrom = 'patName';

        /* Setup autocomplete - Handle Changes in Selection */

        patIDOpts.fnOnSelect = function (event, ui) { };

        /* Setup autocomplete - Customization Hooks  */

        patIDOpts.fnModifyRequestNvps = function (nvpsIn) { return nvpsIn; };
        patIDOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
        patIDOpts.fnModifyRenderItem = function ($ul, item, $li) {
            var ctxt1 = $('<br><sup>' + item.context1 + '</sup>');
            $($li).children('a').append(ctxt1);
            return $li;
        };
        patIDOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

        /* Finally add field def  */

        opts.fieldDefinitions.push({
            name: 'patID'
            , label: 'Patient'
            , toolTip: 'Patient Name (Last, First)'
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
        });

        opts.fieldDefinitions.push({
            name: 'diagnosisNameDisplay'
            , label: 'Presenting<br>Concern'
            , toolTip: 'Presenting Concern'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'diagnosisName'
        });

        opts.fieldDefinitions.push({
            name: 'planDateStrYMD'
            , label: 'Start Date'
            , toolTip: 'Start Date'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'plandate'
            , sortUsing: 'planDateStrYMD'
        });

        opts.fieldDefinitions.push({
            name: 'planCreatorSigned'
            , label: 'Signed By Creator'
            , toolTip: 'Signed By Plan Creator'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'checkbox'
            , saveUsing: 'plancreatorsigned'
            , sortUsing: 'planCreatorSigned'
        });

        opts.fieldDefinitions.push({
            name: 'planCreatorSignedDate'
            , label: 'planCreatorSignedDate'
            , toolTip: 'planCreatorSignedDate'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'plancreatorsigneddate'
            , sortUsing: 'planCreatorSignedDate'
        });

        opts.fieldDefinitions.push({
            name: 'planCreatorSignatureImg'
            , label: 'planCreatorSignatureImg'
            , toolTip: 'planCreatorSignatureImg'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'textarea'
            , saveUsing: 'plancreatorsignatureimg'
            , sortUsing: 'planCreatorSignatureImg'
        });

        opts.fieldDefinitions.push({
            name: 'createdBy'
            , label: 'Created By'
            , toolTip: 'Created By'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'createdBy'
            , sortUsing: 'createdBy'
        });

        opts.fieldDefinitions.push({
            name: 'planCreatorLname'
            , label: 'planCreatorLname'
            , toolTip: 'planCreatorLname'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'planCreatorLname'
            , sortUsing: 'planCreatorLname'
        });

        opts.fieldDefinitions.push({
            name: 'planCreatorFname'
            , label: 'planCreatorFname'
            , toolTip: 'planCreatorFname'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'planCreatorFname'
            , sortUsing: 'planCreatorFname'
        });

        opts.fieldDefinitions.push({
            name: 'planCreatorEmail'
            , label: 'planCreatorEmail'
            , toolTip: 'planCreatorEmail'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'planCreatorEmail'
            , sortUsing: 'planCreatorEmail'
        });

        opts.fieldDefinitions.push({
            name: 'planCreatorPhone'
            , label: 'planCreatorPhone'
            , toolTip: 'planCreatorPhone'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'planCreatorPhone'
            , sortUsing: 'planCreatorPhone'
        });

        opts.fieldDefinitions.push({
            name: 'diagnosisID'
            , label: 'Diagnosis ID'
            , toolTip: 'Diagnosis ID'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'diagnosisid'
            , sortUsing: 'diagnosisID'
        });

        opts.fieldDefinitions.push({
            name: 'diagnosisName'
            , label: 'Diagnosis Name'
            , toolTip: 'Diagnosis Name'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'diagnosisname'
            , sortUsing: 'diagnosisName'
        });

        opts.fieldDefinitions.push({
            name: 'diagnosisDesc'
            , label: 'Diagnosis Description'
            , toolTip: 'Diagnosis Description'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'string'
            , saveUsing: 'diagnosisdesc'
            , sortUsing: 'diagnosisDesc'
        });

        opts.fieldDefinitions.push({
            name: 'orpDocSelectionsJSON'
            , label: ''
            , toolTip: ''
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'textarea'
            , saveUsing: 'orpdocselectionsjson'
            , sortUsing: 'orpDocSelectionsJSON'
        });

        opts.fieldDefinitions.push({
            name: 'participantsJSON'
            , label: ''
            , toolTip: ''
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'textarea'
            , saveUsing: 'participantsjson'
            , sortUsing: 'participantsJSON'
        });

        opts.fieldDefinitions.push({
            name: 'authReqRecID'
            , label: ''
            , toolTip: ''
            , visible: false
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'authReqRecID'
            , sortUsing: 'authReqRecID'
        });

        opts.fieldDefinitions.push({
            name: 'diagnosisProcessor'
            , label: 'Presenting<br>Concern'
            , toolTip: 'Select a presenting concern for care plan'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'button'
            , saveUsing: 'diagnosisProcessor'
            , sortUsing: 'diagnosisProcessor'
            , cssClass: 'mba-care-plan-edit-processor'
            , dataTypeOptions: {
                faIconClass: 'fas fa-edit'
                , fnOnClick: function (uiActionObj) {
                    renderDiagnosisDialog(uiActionObj, $me);
                    return uiActionObj;
                }
            }
        });

        opts.fieldDefinitions.push({
            name: 'servicesProcessor'
            , label: 'Services'
            , toolTip: 'Select services for care plan'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'button'
            , saveUsing: 'servicesProcessor'
            , sortUsing: 'servicesProcessor'
            , cssClass: 'mba-care-plan-edit-processor'
            , dataTypeOptions: {
                faIconClass: 'fas fa-edit'
                , fnOnClick: function (uiActionObj) {
                    renderServicesDialog(uiActionObj, $me);
                    return uiActionObj;
                }
            }
        });

        opts.fieldDefinitions.push({
            name: 'participantsProcessor'
            , label: 'Participants'
            , toolTip: 'Select participants for care plan'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'button'
            , saveUsing: 'participantsProcessor'
            , sortUsing: 'participantsProcessor'
            , cssClass: 'mba-care-plan-edit-processor'
            , dataTypeOptions: {
                faIconClass: 'fas fa-edit'
                , fnOnClick: function (uiActionObj) {
                    renderParticipantsDialog(uiActionObj, $me);
                    return uiActionObj;
                }
            }
        });

        //-----------------------------------------------------------------------------
        // Parameters for our pat dropdowns (hidden)
        //-----------------------------------------------------------------------------

        opts.fieldDefinitions.push({
            name: 'clientID'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'clientid'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'dos'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'dos'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'patdatasource'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'patdatasource'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'pracid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'pracid'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'active'
            , isActiveFlag: true
            , saveable: false
            , saveUsing: 'active'
        });

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.additionalControlDefinitionsForBodyRows.set('printPlanPDF', {
            defType: 'userprovided'
            , name: 'printPlanPDF'
            , toolTip: ''
            , cssClass: 'text-danger far fa-file-pdf'
            , handlerFn: function (uiActionObj) {
                let clientID = $('#' + optsIn.PARM_NAME_CLIENT_ID).val();
                let recID = uiActionObj.recordID;
                let diagnosisID = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="diagnosisID"]').val();

                if (!clientID || clientID == 0 ||
                    !recID || recID == 0) {
                    return;
                }

                if (!diagnosisID || diagnosisID == 0) {
                    $.spedmonWebUI.dialogMessage('ERROR', "Please select a presenting concern before printing plan!", null, 400, 200, null, null, null);
                    return;
                }

                var reqUrl = optsIn.baseUrlPDF +"&"+ optsIn.PARM_NAME_CLIENT_ID + '=' + clientID +"&"+ optsIn.PARM_NAME_REC_ID + '=' + recID;
                var win = window.open(reqUrl, '_blank');
                if (win) {
                    //Browser has allowed it to be opened
                    win.focus();
                } else {
                    //Browser has blocked it
                    $.spedmonWebUI.dialogMessage('ERROR', "Please allow popups for SpEdCare", null, 400, 200, null, null, null);
                }

                return uiActionObj;
            }
            , initiallyHidden: false
        });

        opts.additionalControlDefinitionsForBodyRows.set('requestAuthForPlan', {
            defType: 'userprovided'
            , name: 'requestAuthForPlan'
            , toolTip: 'Send Record For E-Authorization'
            , cssClass: 'fas fa-user-md mba-care-plan-user'
            , handlerFn: function (uiActionObj) {
                // get the reqData parameters
                let clientID = $('#' + optsIn.PARM_NAME_CLIENT_ID).val();
                let recID = uiActionObj.recordID;
                let createdBy = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="createdBy"]').val();
                let planCreatorSigned = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="planCreatorSigned"]').is(":checked");
                let patID = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="patID"]').attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE);
                let diagnosisName = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="diagnosisName"]').val();
                let authReqRecID = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="authReqRecID"]').val();
                let participantsJSON = $(uiActionObj.whatRow).find('textarea[data-mba-rest-view-field-name="participantsJSON"]').val();
                let participantsJSONParsed = '';

                try {
                    participantsJSONParsed = JSON.parse(participantsJSON);
                } catch (e) {
                    participantsJSONParsed = [];
                }

                // if record hasn't been saved, warn user
                if (!clientID || clientID == 0 ||
                    !recID || recID == 0 ||
                    !createdBy || createdBy == 0 ||
                    !patID || patID == 0 ||
                    !diagnosisName || diagnosisName == '') {
                    $.spedmonWebUI.dialogMessage('ERROR', "Please save plan before requesting authorization! Not all requirements are met!", null, 400, 200, null, null, null);
                    return;
                }

                // if plan creator hasn't signed, warn user
                if (!planCreatorSigned) {
                    $.spedmonWebUI.dialogMessage('ERROR', "Could not request authorization because plan creator has not signed the plan!", null, 400, 200, null, null, null);
                    return;
                }

                if (!participantsJSON || !participantsJSONParsed || participantsJSONParsed == []) {
                    $.spedmonWebUI.dialogMessage('ERROR', "There are no participants selected for authorization of plan!", null, 400, 200, null, null, null);
                    return;
                }

                // get all participants who need to authorize plan
                let participantsWhoNeedToAuthorizePlan = participantsJSONParsed.filter(x => x.participantAction == 0);

                if (participantsWhoNeedToAuthorizePlan.length != 1 && participantsWhoNeedToAuthorizePlan.length != 2) {
                    if (participantsWhoNeedToAuthorizePlan.length < 1) {
                        $.spedmonWebUI.dialogMessage('ERROR', "There are no participants selected for authorization of plan!", null, 400, 200, null, null, null);
                    }
                    else {
                        $.spedmonWebUI.dialogMessage('ERROR', "There are too many participants selected for authorization! Please select up to 2 participants.", null, 400, 200, null, null, null);
                    }
                    return;
                }

                /****** set up ajax url ***********/
                var reqUrl = optsIn.baseUrlASMXReqAuth;

                var rdObj = {};
                rdObj.clientid = clientID;
                rdObj.districtcontactuserid = createdBy;
                rdObj.patid = patID;
                rdObj.referencedentityid = recID;
                rdObj.svcdescription = 'Careplan for ' + diagnosisName;
                rdObj.prtgrd1personid = participantsWhoNeedToAuthorizePlan[0].participantID;
                rdObj.prtgrd2personid = (participantsWhoNeedToAuthorizePlan.length > 1) ? participantsWhoNeedToAuthorizePlan[1].participantID : '';
                rdObj.recid = (authReqRecID && authReqRecID != 0) ? authReqRecID : '';

                var reqData = JSON.stringify(rdObj);
                
                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                    .then(responseData => {
                        if (responseData.rawData.recordID == 0) {
                            $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                            return;
                        }

                        _updateAdditionalViewParameterValuesAndRequestViewFromServer();
                    })
                    .catch(responseData => {
                        $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                    });

                return uiActionObj;
            }
            , initiallyHidden: false
        });

        opts.additionalControlDefinitionsForBodyRows.set('changeplanauthor', {
            defType: 'userprovided'
            , name: 'changeplanauthor'
            , toolTip: 'Change Plan Author'
            , cssClass: 'fas fa-remove-format text-success'
            , handlerFn: function (uiActionObj) {

                let PARM_NEW_PLAN_AUTHOR_USER_ID = 'newplanauthoruserid';

                let $dia = null;

                let $diaContent = $('<div class="container-fluid"></div>');

                let $diaContentRow0 = $('<div class="row mt-1"></div>');
                $($diaContentRow0).append($('<div class="col-12"><p class="alert alert-info">Changing the plan author will also clear the plan authors signature</p></div>'));

                let $diaContentRow1 = $('<div class="row mt-1"></div>');
                $($diaContentRow1).append($('<div class="col">Current Author</div>'));
                $($diaContentRow1).append($('<div class="col">' + uiActionObj.whatFieldNameValues.planCreatorLname + ', ' + uiActionObj.whatFieldNameValues.planCreatorFname + '</div>'));

                let $diaContentRow2 = $('<div class="row mt-1"></div>');
                $($diaContentRow2).append($('<div class="col">Select New Author</div>'));
                let $diaContentRow2Col2 = $('<div class="col"></div>');
                let $ctrlSelectNewUser = $('<input id="' + PARM_NEW_PLAN_AUTHOR_USER_ID + '" name="' + PARM_NEW_PLAN_AUTHOR_USER_ID + '" title="Select New Author" type="text"></input>');
                $($diaContentRow2Col2).append($ctrlSelectNewUser);
                $($diaContentRow2).append($diaContentRow2Col2);

                $($diaContent).append($diaContentRow0);
                $($diaContent).append($diaContentRow1);
                $($diaContent).append($diaContentRow2);

                let _fnDoChangePlanAuthor = function () {
                    let reqUrl = optsIn.baseUrlChangePlanAuthor;
                    let reqObj = {};
                    reqObj[optsIn.PARM_NAME_CLIENT_ID]              = $('#' + optsIn.PARM_NAME_CLIENT_ID).val();
                    reqObj[optsIn.PARM_NAME_REC_ID]                 = uiActionObj.recordID;
                    reqObj[PARM_NEW_PLAN_AUTHOR_USER_ID]     = $($ctrlSelectNewUser).val();
                    
                    var reqData = JSON.stringify(reqObj);
                    
                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                        .then(responseData => {
                            $($dia).dialog('close');
                            _updateAdditionalViewParameterValuesAndRequestViewFromServer();
                        })
                        .catch(responseData => {
                        });
                    return;
                };

                $dia = MBA.ComponentCommon.fnCreateOneTimeProceedOrCancelDialog(
                    'Change Plan Author?'
                    , $diaContent
                    , {
                        open: function (event, ui) {
                            let _reqUrlSelectUser = optsIn.baseUrlSelectUser;
                            let _reqDataSelectUser = [];
                            let _dataControlIdsSelectUser = [{ id: 'clientid' }];

                            $($ctrlSelectNewUser).spedmonSelectBox({
                                dataParmType: 'DOM'
                                , selectAll: true
                                , delay: 600
                                , showSelectControlLabel: false
                                , selectControlLabel: 'Select : '
                                , selectType: 1
                                , displayInline: false
                                , singleSelectName: ''
                                , singleSelectValue: ''
                                , singleSelectClearAfterSelection: false
                                , multiSelect: false
                                , multiSelectShowOK: true
                                , multiSelectListTitle: ''
                                , multiSelectNames: ''
                                , multiSelectValues: ''
                                , multiSelectLoad: false
                                , multiSelectContextLabels: 'null'
                                , multiSelectDisplayContextLabels: false
                                , multiSelectOnAdd: function (selObj) { }
                                , multiSelectOnRemove: function (selObj) { }

                                , ajaxopts: {
                                    url: (_reqUrlSelectUser)
                                    , data: (_dataControlIdsSelectUser)
                                    , namevalues: (_reqDataSelectUser)
                                }
                            });

                        }
                    }
                    , _fnDoChangePlanAuthor
                    , null
                    , false
                    , true
                );

                return uiActionObj;
            }
            , initiallyHidden: false
        });

        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

            if (!rowData) return $newRow;


            if (rowData.planCreatorSigned == false) {
                let $ctrlEditPlan = $(MBA.RestViewCommon.fnFindRowControl($newRow, 'receditinlinestart'));
                $($ctrlEditPlan).children('i').addClass('text-danger');
            }

            // replace icon for printing plan PDF to a stacked icon format

            let $ctrlPrintPlan = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="printPlanPDF"]');
            $ctrlPrintPlan.html('<span class="fa-stack" title="Download Plan PDF">'
                + '<i class="text-danger far fa-file-pdf mba-care-plan-pdf fa-stack-1x fa-lg"></i>'
                + '<i class="text-danger fas fa-arrow-down mba-care-plan-arrow fa-stack-1x fa-sm"></i>'
                + '</span>');


            return $newRow
        }

        opts.fnCreateNewCellAfter = function ($newCell, subsection, rowType, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {

            if (fieldDefinition.name === optsIn.CONST_ATTR_CLIENT_ID) {
                var clientIDVal = $('#' + optsIn.PARM_NAME_CLIENT_ID).val();
                $($newCellValue).val(clientIDVal);
            }

            // set values when cloning

            if (rowType === MBA.RestViewCommon.CONST_ROW_TYPE.CLONED_ROW) {
                if (fieldDefinition.name === 'id' ||
                    fieldDefinition.name === 'authReqRecID' ||
                    fieldDefinition.name === 'planCreatorSignedDate' ||
                    fieldDefinition.name === 'planCreatorSignatureImg'
                ) {
                    $($newCellValue).val('');
                }
                else if (fieldDefinition.name === 'planCreatorSigned') {
                    $($newCellValue).prop('checked', false).val("0");
                }
                else if (fieldDefinition.name === 'createdBy') {
                    $($newCellValue).val(optsIn.userId);
                }
                else if (fieldDefinition.name === 'planCreatorLname') {
                    $($newCellValue).val(optsIn.lastName);
                }
                else if (fieldDefinition.name === 'planCreatorFname') {
                    $($newCellValue).val(optsIn.firstName);
                }
                else if (fieldDefinition.name === 'planCreatorEmail') {
                    $($newCellValue).val(optsIn.email);
                }
                else if (fieldDefinition.name === 'planCreatorPhone') {
                    $($newCellValue).val(optsIn.phone);
                }
                // lock patient selection
                else if (fieldDefinition.name === 'patID') {
                    $($newCellValue).addClass('pe-none');
                }
            }

            // initial value for diagnosis name column

            if (fieldDefinition.name === 'diagnosisNameDisplay') {
                $($newCellValue).text(rowData.diagnosisName);
            }

            return $newCell;
        };

        // hide prac selection from pracs
        if (optsIn.roleID == optsIn.ROLE_LEA_PROVIDER_ID) {
            $('#' + optsIn.PARM_NAME_PRAC_ID).val('');
        }

        /* Create the rest view */

        $($me).MBA_RestView(opts);

    }

    let $DETS_DIALOG_CONT = $('<div></div>');

    // ********************************************************************************************************************************************************************************************
    // ************************************************************** DIAGNOSIS SELECTION DIALOG CODE AND RELATED HELPER FUNCTIONS ****************************************************************
    // ********************************************************************************************************************************************************************************************

    const _diagnosisNameInputID = 'carePlanDiagnosisNameInputID'; // id for name input dropwdown of diagnosis tab
    const _diagnosisNameDisplayContID = 'carePlanDiagnosisNameDisplayContID'; // id for name input dropwdown of diagnosis tab
    const _diagnosisDescInputID = 'carePlanDiagnosisDescInputID'; // id for description input dropwdown of diagnosis tab
    const _diagnosisDescRowID = 'carePlanDiagnosisDescRowID'; // id for data entry row of diagnosis description
    const _diagnosisDescCharCount = 'carePlanDiagnosisDescCharCount'; // id for description input character counter
    const _diagnosisDescMaxLength = 4000;
    const _diagnosisHiddenIDInputID = 'carePlanDiagnosisHiddenIDInputID'; // id for id input dropwdown of diagnosis tab
    const _diagnosisRadioSelectionsName = 'carePlanDiagnosisRadioSelectionsName'; // name for name radio input dropwdown selection of diagnosis tab
    const _textareaAttrHasMaxCharCounter = 'mba-textarea-has-char-counter'; // attribute for textareas that have character counters

    // ********************************************************************************************************************************************************************************************
    // ************************************************************** SERVICES SELECTION DIALOG CODE AND RELATED HELPER FUNCTIONS *****************************************************************
    // ********************************************************************************************************************************************************************************************
    const _servicesRecIDAttr = 'carePlanServicesRecIDAttr';  // class for services table row attribute for recid
    const _servicesOrpRefDocID = 'carePlanServicesRefDocIDAttr'; // class for services table row attribute for refid
    const _servicesOrpDocTypeAttr = 'carePlanServicesOrpDocTypeAttr';  // class for services table row attribute for ORP document type
    const _servicesSelectedRowAttr = 'carePlanServiceSelectedForPlan';  // class to indicate a row has been selected to be added to the plan
    const _serviceSelectionsTblID = 'carePlanServiceSelectionsTbl';    // id for service selections table
    const _servicesAddRemButClass = 'carePlanServicesAddRemIcon'; // class for plus or x icons on services tab
    const _servicesDeleteButClass = 'carePlanServicesDeleteIcon'; // class for trash icons for deleting orders on services tab
    const _servicesEditOrderButClass = 'carePlanServicesEditRecIcon'; // class for pencil icons on services tab

    // ********************************************************************************************************************************************************************************************
    // ************************************************************** PARTICIPANTS SELECTION DIALOG CODE AND RELATED HELPER FUNCTIONS *************************************************************
    // ********************************************************************************************************************************************************************************************
    const _plusIconCSSClass = 'plus-icon';
    const _participantsSelectedRowAttr = 'carePlanParticipantSelectedForPlan';  // class to indicate a row has been selected to be added to the plan
    const _participantsAddRemButClass = 'carePlanParticipantsRemIcon'; // class for plus or x icons on participants tab
    const _participantsSignatureButClass = 'carePlanParticipantsSignatureIcon'; // class for signature icons on participants tab
    const _participantsRecIDAttr = 'carePlanParticipantsRecIDAttr';  // class for participants table row attribute for recid
    const _planParticipantsTblID = 'carePlanParticipantsTbl';    // id for participants selections table
    const _participantsActionAttr = 'carePlanParticipantsActionAttr'; // class for participants table row attribute for action
    const _participantsHiddenFieldsClass = 'carePlanParticipantsHiddenfieldsClass';
    const _participantsSaveButClass = 'carePlanParticipantsSaveRecIcon'; // class for pencil icons on services tab
    const _carePlanTableColCtrlDataAttr = 'data-careplan-ctrl';
    const _carePlanTableColCtrlDataAttrValParticipantID = 'participantID';
    const _carePlanTableColCtrlDataAttrValParticipantLastName = 'participantLastName';
    const _carePlanTableColCtrlDataAttrValParticipantFirstName = 'participantFirstName';
    const _carePlanTableColCtrlDataAttrValParticipantRole = 'participantRole';
    const _carePlanTableColCtrlDataAttrValParticipantEmail = 'participantEmail';
    const _carePlanTableColCtrlDataAttrValParticipantPhone = 'participantPhone';
    const _carePlanTableColCtrlDataAttrValParticipantAction = 'participantAction';
    const _carePlanTableColCtrlDataAttrValSaveType = 'saveType';
    const _pulsateAnimationClass = 'spedmon-animation-pulsate'; // used for pulsating effect
    const _defaulthiddenparticipantfieldsJSON = {
        address1: ''
        , address2: ''
        , city: ''
        , state: ''
        , zip5: ''
        , zip4: ''
        , fax: ''
        , additionalData1: ''
        , additionalData2: ''
    };
    const _parentRolesArray = ["1000", "1001", "1002"];
    const _practitionersRolesArray = ["5000", "5001", "5002"];
    const _otherSchoolStaffRolesArray = ["3003"];

    /***************************************************************************
    * generateButtonElem */
    /**
    * generic function to produce a button element with an embedded icon
    *
    * TODO: Place this in component common and refactor.
    ***************************************************************************/

    /* NOTE: this is a utility function; ideally should have been placed somewhere in our JS libraries included throughout the project */
    function generateButtonElem(desc, classes, iconClass, callbackFunc) {
        let $btn = $('<button class="' + classes + '" type="button" title="' + desc + '"><i class="' + iconClass + '"></i></button>');
        $btn.on("click", callbackFunc);

        return $btn;
    }

    /***************************************************************************
    * _saveUserDiagnosisTemplate */
    /**
     ***************************************************************************/
    function _saveUserDiagnosisTemplate(templateType, diagnosisName, diagnosisDescription, $me) {

        let dataObj = _fnGetDataObj($me);

        /****** set up ajax url ***********/
        let clientID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        if (!clientID || clientID == 0) {
            return;
        }
        var reqUrl = dataObj.opts.baseURLSaveDiagnoses;
        var reqData = JSON.stringify(
            {
                "clientid": clientID
                , "diagnosisName": diagnosisName
                , "diagnosisDescription": diagnosisDescription
                , "templatetype": templateType
                , "groupserviceclassnameid": ''
                , "editDelReason": ''
                , "validaterec": '0'
                , "savetype": '1'
                , "recid": ''
            }
        );

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                if (responseData.rawData.recordID == 0) {
                    $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                    return;
                }

                $DETS_DIALOG_CONT.mbaHighlight({ color: "#bdffc7", duration: 300 });
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
            });


    }

    /***************************************************************************
    * _deleteDiagnosis */
    /**
     * deletes a diagnosis from database
     ***************************************************************************/
    function _deleteDiagnosis(recID, fnSuccess, $me) {

        let dataObj = _fnGetDataObj($me);

        if (!recID) {
            return;
        }

        /****** set up ajax url ***********/

        var reqUrl = dataObj.opts.baseURLDeleteDiagnoses;

        var rdObj = {};

        rdObj.recid = recID;
        rdObj.validaterec = 0;
        rdObj.editDelReason = '';

        var reqData = JSON.stringify(rdObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                if (responseData.rawData.recordID == 0) {
                    $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                    return;
                }

                if (fnSuccess) fnSuccess();
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
            });
    }


    /***************************************************************************
    * _setUpDiagnosisSelectBox */
    /**
     * set up selectbox for diagnosis based on radio selection
     ***************************************************************************/
    function _setUpDiagnosisSelectBox($me) {

        let dataObj = _fnGetDataObj($me);

        // callabck function to render diagnosis on selection
        function diagnosisSelected(event, ui) {
            _setDiagnosisDescVal(ui.item.recData1);
            $('#' + _diagnosisHiddenIDInputID).val(ui.item.id);
            $('#' + _diagnosisNameDisplayContID).val(ui.item.label);
        }

        var templateType = $('input[name="' + _diagnosisRadioSelectionsName + '"]:checked').val();

        /****** set up ajax url ***********/

        let clientID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let reqUrl = dataObj.opts.baseURLViewDiagnoses;
        let reqData = [{
            name: 'clientid', value: clientID
        }, {
            name: 'recid', value: ''
        }, {
            name: 'templatetype', value: templateType
        }, {
            name: 'groupserviceclassnameid', value: ''
        }];

        $('#' + _diagnosisNameInputID).spedmonSelectBox({
            dataParmType: 'DOM'
            , selectAll: true
            , delay: 600
            , showSelectControlLabel: false
            , selectControlLabel: 'Select Presenting Concern: '
            , selectType: 1
            , displayInline: false
            , singleSelectName: ''
            , singleSelectValue: ''
            , singleSelectClearAfterSelection: false
            , multiSelect: false
            , multiSelectShowOK: true
            , multiSelectListTitle: 'Selected Diagnoses'
            , multiSelectNames: ''
            , multiSelectValues: ''
            , multiSelectLoad: false
            , multiSelectContextLabels: 'null'
            , multiSelectDisplayContextLabels: false
            , multiSelectOnAdd: function (selObj) { }
            , multiSelectOnRemove: function (selObj) { }
            , onSelect: diagnosisSelected
            , ajaxopts: { url: reqUrl, data: '', namevalues: reqData }
        });

        // if selecting from our templates, we don't give the user the option to delete
        if (templateType == 1) return;

        // add X icon to delete a diagnosis
        var diagSelBoxData = $('#' + _diagnosisNameInputID).data('spedmonSelectBox');

        $('#' + diagSelBoxData.inputData.meid).data("autocomplete")._renderItem = function ($ul, item) {
            var diagSelContentParentClass = "planwriter-diagnosis-sel-content-parent-cont";

            var $nli = $('<li class="' + diagSelContentParentClass + '"></li>'); // Note any classes added here are removed
            var liLabel = '<span>' + item.label + '</span>';

            // Detail

            var $nliDetail = $('<a>' + liLabel + '</a>');

            // Remove button

            var $butRem = $('<i class="fa fa-times mba-care-plan-trash-times" type="button"></i>')
                .on('click', function () {
                    _deleteDiagnosis(item.id, function () { $($nli).remove(); }, $me);
                });

            $($nli).append($nliDetail);

            $($nli).append($butRem);

            $($nli).data("item.autocomplete", item);

            return $nli.appendTo($ul);

        };
    }

    /***************************************************************************
    * _generateDiagnosisSrcRadioBox */
    /**
     * creates radio selections for diagnosis dropdown
     ***************************************************************************/
    function _generateDiagnosisSrcRadioBox($me) {
        let $radioCont = $('<div class="ui-spedmon-box-radio-box-container ui-buttonset modern2021 mb-2" id="diagnosisradioelections_radiobox_cont">'
            + '<div id="diagnosisradioelections_radiobox_ctrl" class="ui-spedmon-box-radio-box-options-container">'
            + '<input type="radio" id="diagnosisradioelections_radiobox_opt_0" name="' + _diagnosisRadioSelectionsName + '" value="1" title="Presenting Concerns Library" class="mba-web-ui-field-data-entry-primary mba-web-ui-field-no-submit mba-web-ui-field-no-clear ui-spedmon-box-radio-box-option-input  ui-helper-hidden-accessible" checked>'
            + '<label class="ui-spedmon-box-radio-box-option-label ui-button ui-widget ui-state-default ui-button-text-only ui-corner-left ui-state-active" for="diagnosisradioelections_radiobox_opt_0" aria-pressed="false" role="button" aria-disabled="false">'
            + '<span class="ui-button-text">Presenting Concerns Library</span>'
            + '</label>'
            + '<input type="radio" id="diagnosisradioelections_radiobox_opt_1" name="' + _diagnosisRadioSelectionsName + '" value="2" title="LEA Templates" class="mba-web-ui-field-no-submit mba-web-ui-field-no-clear ui-spedmon-box-radio-box-option-input  ui-helper-hidden-accessible">'
            + '<label class="ui-spedmon-box-radio-box-option-label ui-button ui-widget ui-state-default ui-button-text-only ui-corner-right" for="diagnosisradioelections_radiobox_opt_1" aria-pressed="false" role="button" aria-disabled="false">'
            + '<span class="ui-button-text">LEA Templates</span>'
            + '</label>'
            + '<input type="radio" id="diagnosisradioelections_radiobox_opt_2" name="' + _diagnosisRadioSelectionsName + '" value="3" title="My Favorites" class="mba-web-ui-field-no-submit mba-web-ui-field-no-clear ui-spedmon-box-radio-box-option-input  ui-helper-hidden-accessible">'
            + '<label class="ui-spedmon-box-radio-box-option-label ui-button ui-widget ui-state-default ui-button-text-only ui-corner-right" for="diagnosisradioelections_radiobox_opt_2" aria-pressed="false" role="button" aria-disabled="false">'
            + '<span class="ui-button-text">My Favorites</span>'
            + '</label>'
            + '</div>'
            + '</div>');

        // set up callback to re-render diagnosis selection if source changed
        $radioCont.find('input[name="' + _diagnosisRadioSelectionsName + '"]').on("click", function () {
            // add the active class
            $('#diagnosisradioelections_radiobox_ctrl label').removeClass('ui-state-active');
            $('label[for="' + $(this).attr("id") + '"]').addClass('ui-state-active');

            $('#' + _diagnosisNameInputID + '_all_cont').replaceWith($('<input id="' + _diagnosisNameInputID + '" title="Select a presenting concern" type="text"></input>'));
            _setUpDiagnosisSelectBox($me);
        });

        return $radioCont;
    }

    function _setDiagnosisDescVal(value) {
        $('#' + _diagnosisDescRowID).find('iframe').contents().find('body').html(value).trigger('change');
    }

    function _getDiagnosisDescVal() {
        return $('#' + _diagnosisDescRowID).find('iframe').contents().find('body').html();
    }

    function renderDiagnosisDialog(uiActionObj, $me) {
        
        let readOnlyMode = MBA.RestViewCommon.fnCtrlOpInlineAreEditableFieldsLocked(uiActionObj, uiActionObj.whatRow);

        // callback function to save diagnosis selection
        function saveDiagnosisSelection() {
            $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="diagnosisID"]').val($('#' + _diagnosisHiddenIDInputID).val());
            $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="diagnosisName"]').val($('#' + _diagnosisNameDisplayContID).val());
            $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="diagnosisDesc"]').val(_getDiagnosisDescVal());

            $(uiActionObj.whatRow).find('span[data-mba-rest-view-field-name="diagnosisNameDisplay"]').text($('#' + _diagnosisNameDisplayContID).val());

            $DETS_DIALOG_CONT.html('').dialog('close');
        }

        let diagnosisContID = "carePlanDiagnosisFieldsCont";
        let _diagnosisSelectContID = "carePlanDiagnosisSelectCont";

        let diagnosisID = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="diagnosisID"]').val();
        let diagnosisName = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="diagnosisName"]').val();
        let diagnosisDesc = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="diagnosisDesc"]').val();
        let diagnosisDescID = MBA.ComponentCommon.fnCreateNewUUID(); // generate an id for description textarea. We need to do this because tinymce requires unique ids for each call

        // create content to be appended
        let readOnlyText = (readOnlyMode) ? ' readonly ' : ' ';

        let $diagnosisContent = $(
            '<div id="' + diagnosisContID + '" class="ui-spedmon-data-entry-rows container">'
            + ((!readOnlyMode) ?
                (

                    '<div class="reverse-on-lg">' +

                    '<div id="saveCtrlButtons" class="ui-spedmon-data-entry-row col-xs-12 col-sm-12 col-md-4">' +
                    '<div id="saveCtrlButtonsLeft" class="col-6 ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry">' +
                    '</div>' +
                    '<div id="saveCtrlButtonsRight" class="col-6 ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry">' +
                    '</div>' +
                    '</div>' +
                    '<div class="ui-spedmon-data-entry-row col-xs-12 col-sm-12 col-md-8">' +
                    '<div class= "row" > ' +
                    '<div class="p-0 ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label col-xs-12 col-sm-12 col-md-4">Select Presenting Concern</div>' +
                    '<div id="' + _diagnosisSelectContID + '" class="pl-3 ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry col-xs-12 col-sm-12 col-md-8">' +
                    '<input id="' + _diagnosisNameInputID + '" title="Select a presenting concern" type="text"></input>' +
                    '</div>' +
                    '</div>' +

                    '</div></div>'
                ) : ''
            )


            + '<div class="ui-spedmon-data-entry-row row">'
            + '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label col-xs-12 col-sm-12 col-md-3">Presenting Concern Name</div>'
            + '<div class="p-0 ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry col-xs-12 col-sm-12 col-md-9">'
            + '<input type="text" class="w-50" id="' + _diagnosisNameDisplayContID + '" '
            + 'value="' + diagnosisName + '"' + readOnlyText + '>'
            + '</div>'
            + '</div>'

            + '<div class="ui-spedmon-data-entry-row row">'
            + '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label col-xs-12 col-sm-12 col-md-3">Presenting Concern Overview<br><br><em>Please note that if you copy/paste content from an existing document (ie Word, PDF, etc) you will need to reformat the content.  Also if you embed images you may need to resize the image so it fits.</em></div>'
            + '<div class="p-0 ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry col-xs-12 col-sm-12 col-md-9" id="' + _diagnosisDescRowID + '">'
            + ((!readOnlyMode)
                ?
                ('<textarea id="' + diagnosisDescID + '" class="mba-web-ui-field-data-text-area mba-web-ui-field-simple mba-web-ui-field-data-entry-primary ui-spedmon-box ui-widget-content ui-corner-all ui-spedmon-noteareabox" placeholder="Enter Diagnosis Overview">'
                    + '</textarea>')
                :
                diagnosisDesc
            )
            + '<div id="' + _diagnosisDescCharCount + '" class="text-secondary"></div>'
            + '</div>'
            + '</div>'

            + '<input type="hidden" id="' + _diagnosisHiddenIDInputID + '" value="'
            + diagnosisID
            + '">'

            + '</div>'
        );

        if (!readOnlyMode) {
            $diagnosisContent.find('#' + _diagnosisSelectContID).prepend(_generateDiagnosisSrcRadioBox($me));

            //debugger;

            $diagnosisContent.find('#saveCtrlButtonsLeft').append(generateButtonElem('Add to Templates', 'mt-2 btn btn-link', 'fas fa-book-medical fa-2x mba-care-plan-book-medical',
                function () { _saveUserDiagnosisTemplate(2, $('#' + _diagnosisNameDisplayContID).val(), _getDiagnosisDescVal(), $me); }
            ));

            $diagnosisContent.find('#saveCtrlButtonsLeft').append(generateButtonElem('Add To Favorites', 'mt-2 btn btn-link', 'fas fa-heart fa-2x mba-care-plan-heart',
                function () { _saveUserDiagnosisTemplate(3, $('#' + _diagnosisNameDisplayContID).val(), _getDiagnosisDescVal(), $me); }
            ));

            $diagnosisContent.find('#saveCtrlButtonsRight').append(generateButtonElem('Save', 'mt-2 btn btn-link', 'fas fa-save fa-2x mba-care-plan-save', saveDiagnosisSelection));

            // set up character counter for diagnosis description
            //_setTextareaCharacterCounter($diagnosisContent.find('#' + _diagnosisDescInputID), $diagnosisContent.find('#' + _diagnosisDescCharCount), _diagnosisDescMaxLength);

        }


        $DETS_DIALOG_CONT.html('').append($diagnosisContent).show().dialog(
            {
                width: $(window).width() * 0.90
                , height: $(window).height() * 0.90
                , title: "Presenting Concern"
                , show: {
                    effect: 'slide',
                    complete: function () {
                        if (!readOnlyMode) {
                            _setUpDiagnosisSelectBox($me);

                            // set value for diagnosis description and convert it to a rich textarea
                            if (!readOnlyMode) {
                                $('#' + diagnosisDescID).val(diagnosisDesc)
                                $('#' + _diagnosisDescRowID).find('textarea').spedmonRichTextAreaBox({ 'showControls': false });
                            }
                        }
                    }
                }
                , hide: {
                    effect: 'slide'
                    , direction: 'left'
                }
            }

        );

        return uiActionObj;
    }

    /***************************************************************************
        * _openOrdersOrProfilesEditScreen */
    /**
     * open the orders or profiles edit screens based on document type
     ***************************************************************************/
    function _openOrdersOrProfilesEditScreen(editIcon, uiActionObj, $me) {

        let dataObj = _fnGetDataObj($me);

        // grab the row's id and document type
        let parentRow = $(editIcon).closest('tr');
        let recID = parentRow.attr(_servicesRecIDAttr);
        let clientID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();

        // the following are used for the popupThenResume function
        var fnEntryTest = function () { return true; };
        var fnExitTest = function () { return true; };
        var fnResume = function () { _saveServiceSelectionsToPlan(uiActionObj, true); renderServicesDialog(uiActionObj, $me); return true; };

        let url = dataObj.opts.baseURLCoorManage + "&recid=" + recID + "&patclientid=" + clientID + "&savetype=2&amd=uidbssub";

        $.spedmonWebUI.popupThenResume(fnEntryTest
            , fnExitTest
            , fnResume
            , url
            , 'Popups Not Supported'
            , 'Please allow popups for SpEdCare'
            , 'Waiting'
            , 'Waiting for changes to be saved');

    }

    /***************************************************************************
     * _deletePatientOrderAndRefreshServicesTbl */
    /**
     * delete the patient's order and refresh participants table
     ***************************************************************************/
    function _deletePatientOrderAndRefreshServicesTbl(editIcon, uiActionObj, $me) {

        let dataObj = _fnGetDataObj($me);

        // grab the row's id and document type
        let $parentRow = $(editIcon).closest('tr');
        let recID = $parentRow.attr(_servicesRecIDAttr);

        // function to remove refresh participants table
        var fnRefreshParticipantsTbl =
            function () {
                // remove order from plan and refresh
                $parentRow.remove();
                _saveServiceSelectionsToPlan(uiActionObj, true);
                renderServicesDialog(uiActionObj, $me);
                return true;
            };

        // url for order delete ajax
        let reqURL = dataObj.opts.baseURLDeleteOrder;
        let reqData = JSON.stringify({ "recid": recID });

        // confirm with user that they indeed want to delete the order for patient
        var onYes = function () {
            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqData, null)
                .then(responseData => {
                    fnRefreshParticipantsTbl();
                })
                .catch(responseData => {
                    $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                });
        };

        $.spedmonWebUI.dialogConfirm("Please Confirm", 'Are you sure you want to deactivate this order? This will remove access to this order from SpEdCare. Order will still be available for audit purposes. If you want to remove service from plan, click the "X" next to the service name.'
            , onYes, function () { });
    }

    /***************************************************************************
     * _openOrdersOrProfilesAddNewScreen */
    /**
     * open the orders or profiles add new screen
     ***************************************************************************/
    function _openOrdersOrProfilesAddNewScreen(uiActionObj, $me) {

        let dataObj = _fnGetDataObj($me);

        // grab the row's id and document type
        let clientID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let patID = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="patID"]').attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE);

        // the following are used for the popupThenResume function
        var fnEntryTest = function () { return true; };
        var fnExitTest = function () { return true; };
        var fnResume = function () { _saveServiceSelectionsToPlan(uiActionObj, true); renderServicesDialog(uiActionObj, $me); return true; };

        let url = dataObj.opts.baseURLCoorManage + "&patid=" + patID + "&patclientid=" + clientID + "&savetype=1&amd=uidbssub";

        $.spedmonWebUI.popupThenResume(fnEntryTest
            , fnExitTest
            , fnResume
            , url
            , 'Popups Not Supported'
            , 'Please allow popups for SpEdCare'
            , 'Waiting'
            , 'Waiting for changes to be saved');

    }

    /***************************************************************************
    * _toggleAddServiceToPlan */
    /**
     * toggle plus icon to minus and vice versa based on current class
     ***************************************************************************/
    function _toggleAddServiceToPlan() {
        let selectedAttr = $(this).closest('tr').attr(_servicesSelectedRowAttr); // determines whether row has been selected or not

        // if record selected, unselect it
        if (typeof selectedAttr !== typeof undefined && selectedAttr !== false) {
            $(this).removeClass('fa-times mba-care-plan-trash-times').addClass('fa-plus mba-care-plan-plus');
            $(this).closest('tr').removeAttr(_servicesSelectedRowAttr);
        }
        // if record not selected, select it
        else {
            $(this).addClass('fa-times mba-care-plan-trash-times').removeClass('fa-plus mba-care-plan-plus');
            $(this).closest('tr').attr(_servicesSelectedRowAttr, "true");
        }
    }

    /***************************************************************************
    * _saveServiceSelectionsToPlan */
    /**
     * save the service selections to the map
     ***************************************************************************/
    function _saveServiceSelectionsToPlan(uiActionObj, keepModalOpen) {
        
        let servicesJSONArr = [];

        $('#' + _serviceSelectionsTblID + ' tr[' + _servicesSelectedRowAttr + ']').each(function (idx, thisTd) {
            servicesJSONArr.push(
                {
                    "orpDocRefID": $(thisTd).attr(_servicesOrpRefDocID)
                    , "orpDocType": $(thisTd).attr(_servicesOrpDocTypeAttr)
                }
            );
        });

        let servicesJSONStr = JSON.stringify(servicesJSONArr);
        $(uiActionObj.whatRow).find('textarea[data-mba-rest-view-field-name="orpDocSelectionsJSON"]').val(servicesJSONStr);

        if (!keepModalOpen)
            $DETS_DIALOG_CONT.html('').dialog('close');
    }

    /***************************************************************************
    * _buildServicesHtmlTblContent */
    /**
     * build html for services table
     ***************************************************************************/
    function _buildServicesHtmlTblContent(uiActionObj, orpDocObjs) {
        let readOnlyMode = MBA.RestViewCommon.fnCtrlOpInlineAreEditableFieldsLocked(uiActionObj, uiActionObj.whatRow);

        let tblBodyCont = '';
        let curSelectedServices = $(uiActionObj.whatRow).find('textarea[data-mba-rest-view-field-name="orpDocSelectionsJSON"]').val();

        try {
            curSelectedServices = JSON.parse(curSelectedServices);
        } catch (e) {
            curSelectedServices = [];
        }

        if (!orpDocObjs) return '<div>No Records</div>';

        orpDocObjs.forEach(function (RecObj, _idx) {
            let isSelected = (curSelectedServices.filter(item => item.orpDocRefID == RecObj.recData6).length > 0) ? true : false;

            // set up dynamic add / remove buttons
            let selectedAttr = (isSelected) ? _servicesSelectedRowAttr + '="true"' : "";
            let selectedIcon = (isSelected) ? 'fa-times mba-care-plan-trash-times' : 'fa-plus mba-care-plan-plus';

            // add to or remove from plan x or + icon
            let $addRemIcon = $('<i class="fas ' + selectedIcon + ' ' + _servicesAddRemButClass + '" title="Add/Remove From Plan"></i>');

            tblBodyCont += '<tr ' + _servicesRecIDAttr + '="' + RecObj.id + '" ' + _servicesOrpRefDocID + '="' + RecObj.recData6 + '" ' + _servicesOrpDocTypeAttr + '="' + RecObj.recData5 + '" ' + selectedAttr + '>'
                + ((!readOnlyMode) ?
                ('<td><i class="fas fa-pencil-alt mba-care-plan-pencil-alt ' + _servicesEditOrderButClass + '" title="Edit This Order"></i></td>'
                    + '<td><i class="fas fa-trash-alt mba-care-plan-trash-alt ' + _servicesDeleteButClass + '" title="Deactivate Order"></i></td>'
                    )

                    : ''
                )
                + '<td>' + $addRemIcon.get(0).outerHTML + '</td>'
                + '<td>' + RecObj.label + '</td>'
                + '<td>' + RecObj.context1 + '</td>'
                + '</tr>'
        });

        return '<table id="' + _serviceSelectionsTblID + '" class="ui-spedmon-gradient-data-table col-12">'
            + '<thead><tr>'
            + ((!readOnlyMode) ?
                ('<th>Edit Order</th>'
                    + '<th>Deactivate Order</th>'
                )
                : ''
            )
            + '<th>Add/Remove From Plan</th>'
            + '<th>Service Name</th>'
            + '<th>ORP/Physician</th>'
            + '</tr></thead>'
            + '<tbody>'
            + tblBodyCont
            + '</tbody>'
            + '</table>';
    }

    /***************************************************************************
    * renderServicesDialog */
    /**
     * show details dialog for services
     ***************************************************************************/
    function renderServicesDialog(uiActionObj, $me) {
        let dataObj = _fnGetDataObj($me);
        // get the reqData parameters
        let clientid = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let includeonlyorpdoctypeids = '2,3';
        let patid = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="patID"]').attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE);
        let readOnlyMode = MBA.RestViewCommon.fnCtrlOpInlineAreEditableFieldsLocked(uiActionObj, uiActionObj.whatRow);

        /****** set up ajax url ***********/

        var reqUrl = dataObj.opts.baseUrlSelOrpDocs;
        var reqData = JSON.stringify({
            'clientid': clientid
            , 'pracid': ''
            , 'patid': patid
            , 'includeonlyorpdoctypeids': includeonlyorpdoctypeids
            , 'term': ''
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                let selRecs = responseData.rawData.SelRecs;

                // build html content for dialog
                let ServicesHtmlContent = _buildServicesHtmlTblContent(uiActionObj, selRecs);

                $DETS_DIALOG_CONT.html('').html(ServicesHtmlContent);

                if (!readOnlyMode) {
                    $DETS_DIALOG_CONT.append(generateButtonElem('Save', 'float-right mt-2 btn btn-link', 'fas fa-save fa-2x mba-care-plan-save', function () { _saveServiceSelectionsToPlan(uiActionObj); }));

                    // attach add new icon for adding new orders for patient
                    let $addNewOrderBtn = $('<button class="btn btn-link"><i class="fa fa-plus mba-care-plan-plus"></i></button>');
                    $addNewOrderBtn.on("click", function () { _openOrdersOrProfilesAddNewScreen(uiActionObj, $me); });
                    $DETS_DIALOG_CONT.prepend($addNewOrderBtn);

                    // attach callback for add and remove (plus & minus) icons
                    $('.' + _servicesAddRemButClass).on("click", _toggleAddServiceToPlan);

                    // attach callback for edit icon
                    $('.' + _servicesEditOrderButClass).on(
                        "click"
                        , function () {
                            _openOrdersOrProfilesEditScreen(this, uiActionObj, $me);
                        }
                    );

                    // attach callback for delete order icon
                    $('.' + _servicesDeleteButClass).on(
                        "click"
                        , function () {
                            _deletePatientOrderAndRefreshServicesTbl(this, uiActionObj, $me);
                        }
                    );

                }

                $DETS_DIALOG_CONT.show().dialog(
                    {
                        width: $(window).width() * 0.90
                        , height: $(window).height() * 0.90
                        , title: "Services"
                        , show: {
                            effect: 'slide',
                            complete: function () {

                            }
                        }
                        , hide: {
                            effect: 'slide'
                            , direction: 'left'
                        }
                    }

                );
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
            });
    }

    /***************************************************************************
    * _generateAddRecordPlusIcon */
    /**
     * generates plus icon for dialog
     ***************************************************************************/
    function _generateAddRecordPlusIcon(callbackFunc) {
        let $plusIcon = $('<i id="addNewContact" class="fa fa-plus mba-care-plan-plus ' + _plusIconCSSClass + '" title="Add New Record"></i>');
        $plusIcon.on("click", callbackFunc);

        return $plusIcon;
    }

    /***************************************************************************
    * _setPulsatingStateForParticipants */
    /**
     * pulsate the save icon for participants
     ***************************************************************************/

    function _setPulsatingStateForParticipants($tr) {
        var $saveIcon = $($tr).find('.' + _participantsSaveButClass);
        $($saveIcon).addClass(_pulsateAnimationClass);
    }

    /***************************************************************************
    * _toggleAddParticipantToPlan */
    /**
     * toggle plus icon to minus and vice versa based on current class
     ***************************************************************************/

    function _toggleAddParticipantToPlan() {

        // if record has not been saved yet, display a warning
        if ($(this).closest('tr').attr(_carePlanTableColCtrlDataAttrValSaveType) == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {
            $.spedmonWebUI.dialogMessage('WARNING', "Please make sure your record is saved before proceeding.", null, 400, 200, null, null, null);
            return;
        }

        let selectedAttr = $(this).closest('tr').attr(_participantsSelectedRowAttr); // determines whether row has been selected or not

        // if record selected, unselect it
        if (typeof selectedAttr !== typeof undefined && selectedAttr !== false) {
            $(this).removeClass('fa-times mba-care-plan-trash-times').addClass('fa-plus mba-care-plan-plus');
            $(this).closest('tr').removeAttr(_participantsSelectedRowAttr);
        }
        // if record not selected, select it
        else {
            $(this).addClass('fa-times mba-care-plan-trash-times').removeClass('fa-plus mba-care-plan-plus');
            $(this).closest('tr').attr(_participantsSelectedRowAttr, "true");
        }
    }

    /***************************************************************************
    * _saveParticipantToTheDatabase */
    /**
     * sends ajax request to save a record to the database
     ***************************************************************************/

    function _saveParticipantToTheDatabase(saveIcon, uiActionObj, $me) {
        let dataObj = _fnGetDataObj($me);
        let patientid = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="patID"]').attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE);
        let clientid = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();

        let parentRow = $(saveIcon).closest('tr');
        let recid = parentRow.attr(_participantsRecIDAttr);
        let saveType = parentRow.attr(_carePlanTableColCtrlDataAttrValSaveType);
        let hiddenparticipantfieldsObj = JSON.parse(parentRow.find('.' + _participantsHiddenFieldsClass).val());
        let lastname = parentRow.find('td[' + _carePlanTableColCtrlDataAttr + '="' + _carePlanTableColCtrlDataAttrValParticipantLastName + '"]').find('input').val();
        let firstname = parentRow.find('td[' + _carePlanTableColCtrlDataAttr + '="' + _carePlanTableColCtrlDataAttrValParticipantFirstName + '"]').find('input').val();
        let personrelationshipid = parentRow.find('td[' + _carePlanTableColCtrlDataAttr + '="' + _carePlanTableColCtrlDataAttrValParticipantRole + '"]').find('select').val();
        let email = parentRow.find('td[' + _carePlanTableColCtrlDataAttr + '="' + _carePlanTableColCtrlDataAttrValParticipantEmail + '"]').find('input').val();
        let phone = parentRow.find('td[' + _carePlanTableColCtrlDataAttr + '="' + _carePlanTableColCtrlDataAttrValParticipantPhone + '"]').find('input').val();

        /****** set up ajax url ***********/

        var reqUrl = dataObj.opts.baseUrlSavePatPerson;
        var reqData = JSON.stringify({
            "clientid": clientid
            , "patientid": patientid
            , "personroleid": 1
            , "personrelationshipid": personrelationshipid
            , "lastname": lastname
            , "firstname": firstname
            , "middlename": ''
            , "phone": phone
            , "fax": hiddenparticipantfieldsObj.fax
            , "email": email
            , "address1": hiddenparticipantfieldsObj.address1
            , "address2": hiddenparticipantfieldsObj.address2
            , "city": hiddenparticipantfieldsObj.city
            , "state": hiddenparticipantfieldsObj.state
            , "zip5": hiddenparticipantfieldsObj.zip5
            , "zip4": hiddenparticipantfieldsObj.zip4
            , "additionaldata1": hiddenparticipantfieldsObj.additionalData1
            , "additionaldata2": hiddenparticipantfieldsObj.additionalData2
            , "editDelReason": ''
            , "validaterec": 0
            , "savetype": saveType
            , "recid": recid
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                if (responseData.rawData.recordID == 0) {
                    $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                    return;
                }

                if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {
                    parentRow.attr(_participantsRecIDAttr, responseData.recordID);
                    parentRow.attr(_carePlanTableColCtrlDataAttrValSaveType, $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT);

                    // refresh the dialog to load role specific options
                    _saveParticipantsToPlan(uiActionObj, false, false);
                    renderParticipantsDialog(uiActionObj, $me);
                }
                else {
                    $(saveIcon).removeClass(_pulsateAnimationClass);
                    $DETS_DIALOG_CONT.mbaHighlight({ color: "#bdffc7", duration: 300 });
                }

            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
            });
    }

    /***************************************************************************
    * _createParticipantsHtmlTblPlanCreatorRowContent */
    /**
     * build html for participants table
     ***************************************************************************/
    function _createParticipantsHtmlTblPlanCreatorRowContent(uiActionObj, $me) {
        let dataObj = _fnGetDataObj($me);
        // determine signature icon based on if the user signed the plan or not
        let planCreatorSigned = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="planCreatorSigned"]').is(":checked");
        let planCreatorUserID = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="createdBy"]').val();
        let planCreatorLName = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="planCreatorLname"]').val();
        let planCreatorFName = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="planCreatorFname"]').val();
        let planCreatorEmail = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="planCreatorEmail"]').val();
        let planCreatorPhone = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="planCreatorPhone"]').val();

        if (!planCreatorLName) { planCreatorLName = dataObj.opts.lastName; }
        if (!planCreatorFName) { planCreatorFName = dataObj.opts.firstName; }
        if (!planCreatorEmail) { planCreatorEmail = dataObj.opts.email; }
        if (!planCreatorPhone) { planCreatorPhone = dataObj.opts.phone; }

        let signatureIconClass = (planCreatorSigned) ?
            "fa-check mba-care-plan-check" : "fa-signature " + _participantsSignatureButClass + " mba-care-plan-signature";

        // determine if user should be able to sign as plan creator
        let includeSignatureIcon = (
            planCreatorSigned // plan has been signed by creator
            || (!planCreatorUserID) // new plan
            || (planCreatorUserID == dataObj.opts.userId) // user is the one who created the plan
        );

        return '<tr>'
            + '<td><i class="fas fa-times mba-care-plan-trash-times" title="Cannot add/remove from Plan"></i></td>'
            + '<td>' + (includeSignatureIcon ? ('<i class="fas ' + signatureIconClass + '" title="Sign the plan"></i>') : '<span class="text-danger font-weight-bold">Not Signed</span>') + '</td>'
            + '<td><div>' + planCreatorLName + '</div></td>'
            + '<td><div>' + planCreatorFName + '</div></td>'
            + '<td><div>Plan Creator</div></td>'
            + '<td><div>' + planCreatorEmail + '</div></td>'
            + '<td><div>' + planCreatorPhone + '</div></td>'
            + '<td><div>Not Applicable</div></td>'
            + '</tr>';
    }


    /***************************************************************************
    * _buildParticipantsHtmlTblContent */
    /**
     * build html for participants table
     ***************************************************************************/
    function _buildParticipantsHtmlTblContent(uiActionObj, participantObjs, $me) {
        let tblBodyCont = '';
        let participantsJSON = $(uiActionObj.whatRow).find('textarea[data-mba-rest-view-field-name="participantsJSON"]').val();
        let participantsArr;
        try {
            participantsArr = JSON.parse(participantsJSON);
        } catch (e) {
            participantsArr = [];
        }

        // add the first row for the logged in user
        tblBodyCont += _createParticipantsHtmlTblPlanCreatorRowContent(uiActionObj, $me);

        if (participantObjs) {
            participantObjs.forEach(function (RecObj, _idx) {
                // used for preloading

                let participantObj = participantsArr.filter(item => item[_carePlanTableColCtrlDataAttrValParticipantID] == RecObj.id);

                let selected = (participantObj.length > 0);
                let action = (selected) ? participantObj[0][_carePlanTableColCtrlDataAttrValParticipantAction] : 0;
                let hiddenparticipantfieldsJSON = {
                    address1: ((RecObj.recData7) ? RecObj.recData7 : '')
                    , address2: ((RecObj.recData8) ? RecObj.recData8 : '')
                    , city: ((RecObj.recData9) ? RecObj.recData9 : '')
                    , state: ((RecObj.recData10) ? RecObj.recData10 : '')
                    , zip5: ((RecObj.recData11) ? RecObj.recData11 : '')
                    , zip4: ((RecObj.recData12) ? RecObj.recData12 : '')
                    , fax: ((RecObj.recData13) ? RecObj.recData13 : '')
                    , additionalData1: ((RecObj.recData14) ? RecObj.recData14 : '')
                    , additionalData2: ((RecObj.recData15) ? RecObj.recData15 : '')
                };

                tblBodyCont += _createParticipantsHtmlTblRowContent(RecObj.id, RecObj.recData1, RecObj.recData2, RecObj.recData3, RecObj.recData6, RecObj.recData4, RecObj.recData5, action, selected, JSON.stringify(hiddenparticipantfieldsJSON), 2, uiActionObj);
            });
        }

        // build table to be rendered in the dialog
        return '<table id="' + _planParticipantsTblID + '" class="ui-spedmon-gradient-data-table col-12">'
            + '<thead><tr>'
            + '<th>Add/Remove</th>'
            + '<th>Save/Sign</th>'
            + '<th>Last Name</th>'
            + '<th>First Name</th>'
            + '<th>Role</th>'
            + '<th>Email</th>'
            + '<th>Phone</th>'
            + '<th>Action</th>'
            + '</tr></thead>'
            + '<tbody>'
            + tblBodyCont
            + '</tbody>'
            + '</table>';
    }


    /***************************************************************************
     * _generateRoleOptions */
    /**
     * build html options for role selection
     ***************************************************************************/

    function _generateRoleOptions(role) {
        let selectOptions = '';

        if (_parentRolesArray.includes(role)) {
            selectOptions += '<option value="1000" ' + ((role == 1000) ? 'selected' : '') + '>Mother</option>'
                + '<option value="1001" ' + ((role == 1001) ? 'selected' : '') + '>Father</option>'
                + '<option value="1002" ' + ((role == 1002) ? 'selected' : '') + '>Guardian/Surrogate</option>';
        }

        else if (_practitionersRolesArray.includes(role)) {
            selectOptions += '<option value="5000" ' + ((role == 5000) ? 'selected' : '') + '>School Nurse</option>'
                + '<option value="5001" ' + ((role == 5001) ? 'selected' : '') + '>Mental Health Provider</option>'
                + '<option value="5002" ' + ((role == 5002) ? 'selected' : '') + '>Teacher</option>';
        }

        else if (_otherSchoolStaffRolesArray.includes(role)) {
            selectOptions += '<option value="3003" ' + ((role == 3003) ? 'selected' : '') + '>Other School Staff</option>';
        }

        else {
            selectOptions += '<option value="1000" ' + ((role == 1000) ? 'selected' : '') + '>Mother</option>'
                + '<option value="1001" ' + ((role == 1001) ? 'selected' : '') + '>Father</option>'
                + '<option value="1002" ' + ((role == 1002) ? 'selected' : '') + '>Guardian/Surrogate</option>'
                + '<option value="5000" ' + ((role == 5000) ? 'selected' : '') + '>School Nurse</option>'
                + '<option value="5001" ' + ((role == 5001) ? 'selected' : '') + '>Mental Health Provider</option>'
                + '<option value="5002" ' + ((role == 5002) ? 'selected' : '') + '>Teacher</option>'
                + '<option value="3003" ' + ((role == 3003) ? 'selected' : '') + '>Other School Staff</option>';
        }

        return selectOptions;
    }

    /***************************************************************************
    * _createParticipantsHtmlTblRowContent */
    /**
     * build html for participants table
     ***************************************************************************/
    function _createParticipantsHtmlTblRowContent(participantid, lastname, firstname, role, roleName, email, phone, action, selected, hiddenparticipantfieldsJSON, saveType, uiActionObj) {
        if (!participantid) participantid = '';
        if (!lastname) lastname = '';
        if (!firstname) firstname = '';
        if (!role) role = '';
        if (!roleName) roleName = '';
        if (!email) email = '';
        if (!phone) phone = '';
        if (!action) action = 0;
        if (!hiddenparticipantfieldsJSON) hiddenparticipantfieldsJSON = JSON.stringify(_defaulthiddenparticipantfieldsJSON);

        let readOnlyMode = MBA.RestViewCommon.fnCtrlOpInlineAreEditableFieldsLocked(uiActionObj, uiActionObj.whatRow);
        let readOnlyText = (readOnlyMode) ? ' readonly disabled ' : ' ';


        let selectedAttr = (selected) ? _participantsSelectedRowAttr + '="true"' : "";
        let selectedIcon = (selected) ? 'fa-times mba-care-plan-trash-times' : 'fa-plus mba-care-plan-plus';

        let $addRemIcon = $('<i class="fas ' + selectedIcon + ' ' + _participantsAddRemButClass + '" title="Add/Remove from Plan"></i>');

        let row = '<tr ' + _participantsRecIDAttr + '="' + participantid + '" ' + _carePlanTableColCtrlDataAttrValSaveType + '="' + saveType + '" ' + _participantsActionAttr + ' = "' + ((action) ? action : 0) + '" ' + selectedAttr + '>'
            + '<td>' + $addRemIcon.get(0).outerHTML
            + '<textarea class="d-none ' + _participantsHiddenFieldsClass + '"' + readOnlyText + '>' + hiddenparticipantfieldsJSON + '</textarea>'
            + '</td>'
            + '<td><i class="fas fa-save mba-care-plan-save ' + _participantsSaveButClass + '" title="Save this person"></i></td>'
            + '<td ' + _carePlanTableColCtrlDataAttr + '="' + _carePlanTableColCtrlDataAttrValParticipantLastName + '"><input' + readOnlyText + 'value="' + lastname + '" type="text"></td>'
            + '<td ' + _carePlanTableColCtrlDataAttr + '="' + _carePlanTableColCtrlDataAttrValParticipantFirstName + '"><input' + readOnlyText + 'value="' + firstname + '" type="text"></td>'
            + '<td ' + _carePlanTableColCtrlDataAttr + '="' + _carePlanTableColCtrlDataAttrValParticipantRole + '"><select' + readOnlyText + '>'
            + '<option disabled value > -- select an option --</option>'
            + _generateRoleOptions(role)
            + '</select></td>'
            + '<td ' + _carePlanTableColCtrlDataAttr + '="' + _carePlanTableColCtrlDataAttrValParticipantEmail + '"><input' + readOnlyText + 'value="' + email + '" type="text"></td>'
            + '<td ' + _carePlanTableColCtrlDataAttr + '="' + _carePlanTableColCtrlDataAttrValParticipantPhone + '"><input' + readOnlyText + 'value="' + phone + '" type="text"></td>'
            + '<td ' + _carePlanTableColCtrlDataAttr + '="' + _carePlanTableColCtrlDataAttrValParticipantAction + '"><select' + readOnlyText + 'value="' + action + '">'
            + '<option disabled value > -- select an option -- </option>'
            + '<option value="0" ' + ((action == 0) ? 'selected' : '') + '>E-Authorization</option>'
            + '<option value="1" ' + ((action == 1) ? 'selected' : '') + '>Electronic Notification Only</option>'
            + '<option value="2" ' + ((action == 2) ? 'selected' : '') + '>No Notification</option>'
            + '</select></td>'
            + '</tr>';

        return row;
    }

    /***************************************************************************
    * _saveParticipantsToPlan */
    /**
     * save the service selections to the map
     ***************************************************************************/
    function _saveParticipantsToPlan(uiActionObj, keepModalOpen, checkForUnsavedChanges) {
        
        if (checkForUnsavedChanges) {
            // check if there are unsaved changes
            var numOfUnsavedRows = $('#' + _planParticipantsTblID + ' .' + _pulsateAnimationClass).length;
            if (numOfUnsavedRows != 0) {
                $.spedmonWebUI.dialogMessage('WARNING', "There are unsaved changes.", null, 400, 200, null, null, null);
                return;
            }
        }

        let partsJSONArr = [];

        $('#' + _planParticipantsTblID + ' tr[' + _participantsSelectedRowAttr + ']').each(function (idx, thisTd) {
            let partsObj = {};
            partsObj[_carePlanTableColCtrlDataAttrValParticipantID] = $(thisTd).attr(_participantsRecIDAttr);
            partsObj[_carePlanTableColCtrlDataAttrValParticipantAction] = $(thisTd).find('[' + _carePlanTableColCtrlDataAttr + '="' + _carePlanTableColCtrlDataAttrValParticipantAction + '"]').find('select').val();
            partsJSONArr.push(partsObj);
        });

        let partsJSONStr = JSON.stringify(partsJSONArr);
        $(uiActionObj.whatRow).find('textarea[data-mba-rest-view-field-name="participantsJSON"]').val(partsJSONStr);

        if (!keepModalOpen) {
            $DETS_DIALOG_CONT.html('').dialog('close');
        }
    }

    /***************************************************************************
            * _getUserSignature */
    /**
        * gets the user's signature using signature pad plugin
    ***************************************************************************/

    function _getUserSignature(uiActionObj, $sigIcon, $me) {
        let dataObj = _fnGetDataObj($me);
        let $sigDiv = $('<div></div>');

        // define callback function for saving user signature
        function saveUserSignature(signatureBase64Data) {

            $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="planCreatorSigned"]').prop('checked', true).val("1");

            // source: https://stackoverflow.com/a/28149561
            var tzoffset = (new Date()).getTimezoneOffset() * 60000; //offset in milliseconds

            $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="planCreatorSignedDate"]').val((new Date(Date.now() - tzoffset)).toISOString());
            $(uiActionObj.whatRow).find('textarea[data-mba-rest-view-field-name="planCreatorSignatureImg"]').val(signatureBase64Data);

            // change the signature icon to a check mark
            $sigIcon.removeClass('fa-signature mba-care-plan-signature').addClass('fa-check mba-care-plan-check');

            $sigIcon.off();

            $DETS_DIALOG_CONT.mbaHighlight({ color: "#bdffc7", duration: 300 });
        }

        // set up opts
        let _sigOpts = {
            "inputInitialValue": dataObj.opts.userPrevSignature
            , "fnSave": saveUserSignature
            , "includeRenderDialogBtn": false
        }
        $sigDiv.spedmonSignaturePad(null, _sigOpts);
    }

    /***************************************************************************
            * renderParticipantsDialog */
    /**
        * show participants details for plan
    ***************************************************************************/

    function renderParticipantsDialog(uiActionObj, $me) {
        let dataObj = _fnGetDataObj($me);
        let readOnlyMode = MBA.RestViewCommon.fnCtrlOpInlineAreEditableFieldsLocked(uiActionObj, uiActionObj.whatRow);

        // get the reqData parameters
        let clientid = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let patid = $(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="patID"]').attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE);

        /****** set up ajax url ***********/

        var reqUrl = dataObj.opts.baseUrlViewSelPatPerson;
        var reqData = "{'clientid':'" + clientid + "','patientid':'" + patid + "','term':'" + '' + "'}";

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                let selRecs = responseData.rawData.SelRecs;

                /*###########################################################################
                    #  attach the participants content and render dialog
                    ##########################################################################*/

                if (!readOnlyMode) {
                    $DETS_DIALOG_CONT.html('').append(_generateAddRecordPlusIcon(function () {
                        let $partsTblRowMkUp = $(_createParticipantsHtmlTblRowContent(null, null, null, null, null, null, null, null, null, null, 1, uiActionObj));

                        if (!readOnlyMode) {
                            $partsTblRowMkUp.find('.' + _participantsAddRemButClass).on("click", _toggleAddParticipantToPlan);
                            $partsTblRowMkUp.find('.' + _participantsSaveButClass).on("click", function () { _saveParticipantToTheDatabase(this, uiActionObj, $me); });
                            $('#' + _planParticipantsTblID + ' tbody').append($partsTblRowMkUp);

                            _setPulsatingStateForParticipants($partsTblRowMkUp);
                        }
                    }))
                        .append(_buildParticipantsHtmlTblContent(uiActionObj, selRecs, $me));
                } else {
                    $DETS_DIALOG_CONT.html('').append(_buildParticipantsHtmlTblContent(uiActionObj, selRecs, $me));
                }

                if (!readOnlyMode) {
                    $DETS_DIALOG_CONT.append(generateButtonElem('Add Selected to Plan', 'float-right mt-2 btn btn-link', 'fas fa-save mba-care-plan-save fa-2x', function () { _saveParticipantsToPlan(uiActionObj, false, true); }));


                    // attach callback for add and remove (plus & minus) icons
                    $('.' + _participantsAddRemButClass).on("click", _toggleAddParticipantToPlan);

                    // attach callback for save icon
                    $('.' + _participantsSaveButClass).on("click", function () { _saveParticipantToTheDatabase(this, uiActionObj, $me); });

                    // attach callback for the signature icon
                    $('.' + _participantsSignatureButClass).on("click", function () {
                        _getUserSignature(uiActionObj, $(this), $me);
                    });

                    // attach callback for pulsating the save icon after input change
                    $('#' + _planParticipantsTblID).on("change",
                        'tr td input, tr td select, tr td textarea',
                        function (e) {
                            _setPulsatingStateForParticipants($(e.currentTarget).parents('tr'));
                        });
                }

                $DETS_DIALOG_CONT.show().dialog(
                    {
                        width: $(window).width() * 0.90
                        , height: $(window).height() * 0.90
                        , title: "Participants"
                        , show: {
                            effect: 'slide',
                            complete: function () {
                            }
                        }
                        , hide: {
                            effect: 'slide'
                            , direction: 'left'
                        }
                    }

                );
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
            });
    }    

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me) {

        let dataObj                     = _fnGetDataObj($me);
        let VALUE_CLIENT_ID             = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let VALUE_PAT_ID                = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
        let VALUE_REC_ID                = "";
        let VALUE_TERM                  = "";
        let VALUE_PRAC_ID               = "";
        let VALUE_SITE_ID               = $('#' + dataObj.opts.PARM_NAME_SITE_ID).val();
        let VALUE_FISCAL_YEAR_ID        = $('#' + dataObj.opts.PARM_NAME_FISCAL_YEAR_ID).val();
        let VALUE_IS_CREATED_BY_CALLER  = (($('#' + dataObj.opts.PARM_NAME_IS_CREATED_BY_CALLER).is(":checked")) ? true : null);
        let VALUE_IS_EXPIRING           = (($('#' + dataObj.opts.PARM_NAME_IS_EXPIRING).is(":checked")) ? true : null);
        let VALUE_IS_EXPIRED            = (($('#' + dataObj.opts.PARM_NAME_IS_EXPIRED).is(":checked")) ? true : null);
        let VALUE_ACTIVE                = true;
        let VALUE_PLAN_TYPE             = 1;

        let NV_CLIENT_ID                = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID,              VALUE_CLIENT_ID);
        let NV_PAT_ID                   = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PAT_ID,                 VALUE_PAT_ID);
        let NV_REC_ID                   = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_REC_ID,                 VALUE_REC_ID);
        let NV_TERM                     = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_TERM,                   VALUE_TERM);
        let NV_PRAC_ID                  = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PRAC_ID,                VALUE_PRAC_ID);
        let NV_SITE_ID                  = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_SITE_ID,                VALUE_SITE_ID);
        let NV_FISCAL_YEAR_ID           = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_FISCAL_YEAR_ID,         VALUE_FISCAL_YEAR_ID);
        let NV_IS_CREATED_BY_CALLER     = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_IS_CREATED_BY_CALLER,   VALUE_IS_CREATED_BY_CALLER);
        let NV_IS_EXPIRING              = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_IS_EXPIRING,            VALUE_IS_EXPIRING);
        let NV_IS_EXPIRED               = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_IS_EXPIRED,             VALUE_IS_EXPIRED);
        let NV_ACTIVE                   = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE,                 VALUE_ACTIVE);
        let NV_PLAN_TYPE                = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PLAN_TYPE,              VALUE_PLAN_TYPE);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_REC_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_TERM);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SITE_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FISCAL_YEAR_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_IS_CREATED_BY_CALLER);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_IS_EXPIRING);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_IS_EXPIRED);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PLAN_TYPE);

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_PLAN_TYPE);

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForCloneSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForCloneSet', NV_PLAN_TYPE);

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
        
        // append dialog container to body (where all extra dialogs will be rendered)
        $('main').append($DETS_DIALOG_CONT);

        /* Wire up events */

        $($containerCtrl).on('spedmoninputdata', function (e) {
            _updateAdditionalViewParameterValuesAndRequestViewFromServer($me);
        });        

        let clientID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();

        if (clientID && clientID != 0) {
            _updateAdditionalViewParameterValuesAndRequestViewFromServer;
        }

        _updateAdditionalViewParameterValuesAndRequestViewFromServer($me);

    }; /*_fnSetup */

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        fnSetup: _fnSetup
        , fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer: _updateAdditionalViewParameterValuesAndRequestViewFromServer
    };

})(jQuery);