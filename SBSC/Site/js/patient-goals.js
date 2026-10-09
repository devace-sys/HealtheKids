;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PatientGoalsCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.PatientGoalsCommon = (function ($)
{

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME = 'Patient Goals Common Methods';
    const _THIS_NS = 'mba-patient-goals';
    const _JQ_DATA_NAME = 'jq-' + _THIS_NS;
    const _DATA_ATTR_BASE = 'data-' + _THIS_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
          PARM_NAME_CLIENT_ID: 'clientid'
        , PARM_NAME_PAT_ID: 'patID'
        , PARM_NAME_PAT_GOAL_ID: 'goalid'
        , PARM_NAME_ACTIVE: 'active'
        , PARM_NAME_GROUP_SVC_CLASS_NAME_ID: 'groupserviceclassnameid'
        , PARAM_ROLE_LEA_PROVIDER_ID: ''
        , roleID: ''
        , containerCtrlID: ''
        , sessionTimeOutUrl: ''
        , baseUrlView: ''
        , defaultPageRowOrder: ''
        , baseUrlAddNew: ''
        , baseUrlEdit: ''
        , baseUrlDelete: ''        
        , baseUrlInsuranceCarrierIDSel: ''
        , groupSvcClassNameIDOpts: ''
        , patientGoalsDefaultDates: ''
        , baseUrlIndividualGoal: ''
        , pracGrpSvcClassNameID: ''
        , baseUrlViewProgress: ''
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

        /* Progress charting - Init  */
        MBA.PatientGoalProgressReporting.fnInit(
            optsIn.baseUrlIndividualGoal
            , optsIn.sessionTimeOutUrl
            , optsIn.PARM_NAME_CLIENT_ID
            , optsIn.PARM_NAME_PAT_ID
            , optsIn.PARM_NAME_PAT_GOAL_ID);

        let opts = {};
        opts.sessionTimeOutUrl = optsIn.sessionTimeOutUrl;
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.positionUserDefinedControlsInHead = 2
        opts.positionUserDefinedControlsInBodyExisting = 2
        opts.enableSortControls          = true;
        opts.enableRowNumbers            = true;
        opts.enableRowControls           = true;
        opts.enableRowControlRecAddNew   = true;
        opts.enableRowControlRecEdit     = true;
        opts.enableRowControlRecDelete   = true;
        opts.enableRowControlRecUnDelete = false;

        /* Enable cloning if user is a prac */

        if (optsIn.roleID == optsIn.PARAM_ROLE_LEA_PROVIDER_ID) {
            opts.enableRowControlRecClone = true;
        } else {
            opts.enableRowControlRecClone = false;
        }

        opts.enableScrollView          = optsIn.enableScrollView;
        opts.scrollViewUseCustomHeight = optsIn.scrollViewUseCustomHeight;
        opts.scrollViewCustomHeight    = optsIn.scrollViewCustomHeight;
        opts.autoHidePageControls      = optsIn.autoHidePageControls

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = optsIn.baseUrlView;
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = optsIn.defaultPageRowOrder;

        opts.saveModeAddNew             = 'inline';
        opts.baseUrlAddNew              = optsIn.baseUrlAddNew;
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeClone              = 'inline';
        opts.baseUrlClone               = optsIn.baseUrlAddNew;
        opts.baseUrlCloneHasParameters  = true;

        opts.saveModeEdit                      = 'inline';
        opts.baseUrlEdit                       = optsIn.baseUrlEdit;
        opts.baseUrlEditHasParameters          = true;
        opts.refreshViewAfterInlineEditProceed = true;

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = optsIn.baseUrlDelete
        opts.baseUrlDeleteHasParameters = true;        

        opts.enableReports = false;
        opts.enableReportHtml = false;
        opts.enableReportXls = false;
        opts.enableReportPdf = false;

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });
        
        //-----------------------------------------------------------------------------
        // Group Svc Class ID %>
        //-----------------------------------------------------------------------------

        if (optsIn.roleID == optsIn.PARAM_ROLE_LEA_PROVIDER_ID) {

            /* Add hidden field since prac cannot select group svc class */

            opts.fieldDefinitions.push({
                name: 'groupSvcClassNameID'
                , visible: false
                , sortable: false
                , saveable: true
                , editable: false
                , isRecID: false
                , dataType: 'hidden'
                , sortUsing: ''
                , saveUsing: 'groupsvcclassnameid'
                , showMore: false
                , additionalCssClassesForColTop: 'text-center'
                , additionalCssClassesForColLabel: 'text-center'
                , additionalCssClassesForCell: 'text-center'
                , additionalCssClassesForCellValue: 'text-center'
            });

            opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) {
                /* Table body, new records */
                if ((subsection === 102) && (rowtype === 2)) {
                    /* Field def after end date */
                    if (fieldDefinition.name === 'goalMet') {
                        /* Get default goal dates */
                        getDefaultPatientGoalDates($me, optsIn.pracGrpSvcClassNameID)
                            .then(objDfltDates => {
                                if (objDfltDates.hasDates === true) {
                                    setPatientGoalDatesFromDflts(newRow, objDfltDates);
                                }
                            });
                    }
                }

                /* For edits - if goal type is the session rating by service */

                if ((subsection === 103) && (rowtype === 4)) {
                    /* Hide goal type selection for this type of goal */
                    if (rowData.goalTypeID === 10000) {
                        if (fieldDefinition.name === 'goalTypeID') {
                            $(newCellValueElem).hide();
                        }
                    }
                }
                return newCell;
            }
        } else {
            /* Setup autocomplete - Basics */
            const CONST_GRP_SVC_CLS_REF = 'grp-svc-cls-ref';
            
            let groupSvcClassNameIDOpts = {};
            groupSvcClassNameIDOpts.baseUrl = optsIn.groupSvcClassNameIDOpts;
            groupSvcClassNameIDOpts.loadMode = 'mbaviewsel';
            groupSvcClassNameIDOpts.getInitialSelectedNameFrom = 'groupSvcClassName';

            /* Setup autocomplete - Handle Changes in Selection */

            groupSvcClassNameIDOpts.fnOnSelect = function (event, ui) {
                /* Get default dates for group family selected */
                getDefaultPatientGoalDates($me, ui.item.id)
                    .then(objDfltDates => {
                        if (objDfltDates.hasDates === true) {
                            let $grpSvcSel = $(event.target)[0];
                            /* Get our row reference we setup in the afterCell delegate*/
                            let grpSvcClsRefObj = $($grpSvcSel).data(CONST_GRP_SVC_CLS_REF);
                            /* Set dates */
                            setPatientGoalDatesFromDflts(grpSvcClsRefObj.rowRef, objDfltDates);
                        }
                    });
            };

            /* Setup autocomplete - Customization Hooks */

            groupSvcClassNameIDOpts.fnModifyRequestNvps = function (nvpsIn) { return nvpsIn; };
            groupSvcClassNameIDOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
            groupSvcClassNameIDOpts.fnModifyRenderItem = function ($ul, item, $li) { return $li; };
            groupSvcClassNameIDOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

            /* Setup bridge between autocomplete and cell for getting default dates */

            opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) {
                /* Table body */
                if (subsection === 102) {
                    /* New, edits, anything involving the group family selection */
                    if (fieldDefinition.name === 'groupSvcClassNameID') {
                        /* Create an object we can reference if there are changes made to the groupSvcClassNameID (autocomplete) */
                        let $rowRef = $(newRow)[0];
                        let $svcSelFldSet = $(newCellValueElem);
                        let $grpSvcSel = $($svcSelFldSet).children('input')[0];
                        let grpSvcClsRefObj = {};
                        grpSvcClsRefObj.rowRef = $rowRef;
                        $($grpSvcSel).data(CONST_GRP_SVC_CLS_REF, grpSvcClsRefObj);
                    }
                }

                /* For edits - if goal type is the session rating by service */
                if ((subsection === 103) && (rowtype === 4)) {
                    /* Hide goal type selection for this type of goal */
                    if (rowData.goalTypeID === 10000) {
                        if (fieldDefinition.name === 'goalTypeID') {
                            $(newCellValueElem).hide();
                        }
                    }
                }

                return newCell;
            }

            /* Finally add field def  */

            opts.fieldDefinitions.push({
                name: 'groupSvcClassNameID'
                , label: 'Practice'
                , toolTip: 'Practice'
                , visible: true
                , sortable: true
                , editable: true
                , saveable: true
                , saveUsing: 'groupsvcclassnameid'
                , isRecID: false
                , dataType: 'autocomplete'
                , dataTypeOptions: groupSvcClassNameIDOpts
                , sortUsing: 'groupSvcClassName'
                , showMore: false
                , additionalCssClassesForColTop: 'text-left'
                , additionalCssClassesForColLabel: 'text-left'
                , additionalCssClassesForCell: 'text-left'
                , additionalCssClassesForCellValue: 'text-left'
            });
        }               

        opts.fieldDefinitions.push({
            name: 'name'
            , label: 'Goal Description'
            , toolTip: 'Goal Description'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'textarea'
            , saveUsing: 'name'
            , sortUsing: 'name'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:20em'
        });

        let goalTypeOptions = {};

        goalTypeOptions.selections = [
              { name: 'Attempt/Success Score', value: '100' }
            , { name: 'Session Rating', value: '200' }
        ];

        opts.fieldDefinitions.push({
            name: 'goalTypeID'
            , label: 'Measure Goal<br>Progress Using'
            , toolTip: 'What fields are used to measure goal progress'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: goalTypeOptions
            , saveUsing: 'goaltypeid'
            , sortUsing: 'goalTypeName'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:12em'
        });

        opts.fieldDefinitions.push({
            name: 'baseLineValue'
            , label: 'Base Line<br>Value<br>(0 for none)'
            , toolTip: 'What is the baseline value'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'baselinevalue'
            , sortUsing: 'baseLineValue'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:5em'
        });

        opts.fieldDefinitions.push({
            name: 'startDateStrYMD'
            , label: 'Start Date'
            , toolTip: 'Start Date'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'startdate'
            , sortUsing: 'startDate'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'endDateStrYMD'
            , label: 'End Date'
            , toolTip: 'End Date'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'enddate'
            , sortUsing: 'endDate'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'goalMet'
            , label: 'Goal<br>Met'
            , toolTip: 'Goal Met'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'checkbox'
            , saveUsing: 'goalmet'
            , sortUsing: 'goalMet'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'goalMetOnStrYMD'
            , label: 'Goal Met<br>Date'
            , toolTip: 'Date Goal Was Met'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'goalmeton'
            , sortUsing: 'goalMetOn'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'backgroundText'
            , label: 'Background'
            , toolTip: 'Goal Background'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'textarea'
            , saveUsing: 'backgroundtext'
            , sortUsing: ''
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:20em'
        });

        opts.fieldDefinitions.push({
            name: 'notes'
            , label: 'Notes'
            , toolTip: 'Goal Notes'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'textarea'
            , saveUsing: 'notes'
            , sortUsing: ''
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:20em'
        });

        opts.fieldDefinitions.push({
            name: 'objective1Text'
            , label: 'Objective 1'
            , toolTip: 'Objective 1'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'textarea'
            , saveUsing: 'objective1text'
            , sortUsing: ''
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:20em'
        });

        opts.fieldDefinitions.push({
            name: 'objective1Met'
            , label: 'Objective 1<br>Met'
            , toolTip: 'Objective 1 Met'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'checkbox'
            , saveUsing: 'objective1met'
            , sortUsing: 'objective1Met'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'objective1MetOnStrYMD'
            , label: 'Objective 1<br>Met Date'
            , toolTip: 'Date Objective 1 Was Met'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'objective1meton'
            , sortUsing: 'objective1MetOn'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'objective2Text'
            , label: 'Objective 2'
            , toolTip: 'Objective 2'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'textarea'
            , saveUsing: 'objective2text'
            , sortUsing: ''
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:20em'
        });

        opts.fieldDefinitions.push({
            name: 'objective2Met'
            , label: 'Objective 2<br>Met'
            , toolTip: 'Objective 2 Met'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'checkbox'
            , saveUsing: 'objective2met'
            , sortUsing: 'objective2Met'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'objective2MetOnStrYMD'
            , label: 'Objective 2<br>Met Date'
            , toolTip: 'Date Objective 2 Was Met'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'objective2meton'
            , sortUsing: 'objective2MetOn'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'objective3Text'
            , label: 'Objective 3'
            , toolTip: 'Objective 3'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'textarea'
            , saveUsing: 'objective3text'
            , sortUsing: ''
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
            , styleAttrValueForCellValue: 'width:20em'
        });

        opts.fieldDefinitions.push({
            name: 'objective3Met'
            , label: 'Objective 3<br>Met'
            , toolTip: 'Objective 3 Met'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'checkbox'
            , saveUsing: 'objective3met'
            , sortUsing: 'objective3Met'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
        });

        opts.fieldDefinitions.push({
            name: 'objective3MetOnStrYMD'
            , label: 'Objective 3<br>Met Date'
            , toolTip: 'Date Objective 3 Was Met'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'objective3meton'
            , sortUsing: 'objective3MetOn'
            , additionalCssClassesForColTop: 'text-center'
            , additionalCssClassesForColLabel: 'text-center'
            , additionalCssClassesForCell: 'text-center'
            , additionalCssClassesForCellValue: 'text-center'
        });

        /* Setup additional controls for head */
        opts.additionalControlDefinitionsForHeadRows = new Map();

        opts.additionalControlDefinitionsForHeadRows.set('viewallgoalsprogress', {
            defType: 'userprovided'
            , name: 'viewallgoalsprogress'
            , toolTip: 'Click Here to View Current Progress For All Goals'
            , cssClass: 'fas fa-chart-line'
            , handlerFn: function (uiActionObj) {
                let objWinOpts = { url: optsIn.baseUrlViewProgress, windowName: 'allgoals', refreshView: false };
                $($me).MBA_RestView('openWindow', objWinOpts);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        /* Progress charting - Add control */
        
        opts.additionalControlDefinitionsForBodyRows.set('viewgoalprogress', {
            defType: 'userprovided'
            , name: 'viewgoalprogress'
            , toolTip: 'Click Here to View Current Progress For This Goal'
            , cssClass: 'fas fa-chart-line'
            , handlerFn: function (uiActionObj) {
                MBA.PatientGoalProgressReporting.fnGetAndChartInDialogIndivualGoalData(
                    $('#' + optsIn.PARM_NAME_CLIENT_ID).val()
                    , $('#' + optsIn.PARM_NAME_PAT_ID).val()
                    , uiActionObj.recordID
                    , 95
                    , 95
                    , true);

                return uiActionObj;
            }
            , initiallyHidden: false
        });

        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            
            if ((subsection === 103) && (rowtype === 4)) {
                /* If this is a service rating goal then remove the clone and delete controls */
                if (rowData.goalTypeID === 10000) {
                    let $butCloneRow = MBA.RestViewCommon.fnFindRowControl($newRow, 'reccloneinlinestart');
                    let $butDelRow = MBA.RestViewCommon.fnFindRowControl($newRow, 'recdeleteinlinestart');
                    $($butCloneRow).remove();
                    $($butDelRow).remove();
                }
            };
            return $newRow;
        };


        
        /* Create the rest view */

        $($me).MBA_RestView(opts);
        return;
    };

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    
    function getDefaultPatientGoalDates($me, groupSvcClassNameID) {

        let dataObj = _fnGetDataObj($me);
        
        return new Promise((resolve, reject) => {
            let patGoalsGetDfltDatesReqObj = {};
            if (!groupSvcClassNameID) reject('Select practice family');
            patGoalsGetDfltDatesReqObj[dataObj.opts.PARM_NAME_CLIENT_ID] = '' + $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
            patGoalsGetDfltDatesReqObj[dataObj.opts.PARM_NAME_PAT_ID] = '' + $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
            patGoalsGetDfltDatesReqObj[dataObj.opts.PARM_NAME_GROUP_SVC_CLASS_NAME_ID] = '' + groupSvcClassNameID;
            let patGoalsGetDfltDatesReqJSON = JSON.stringify(patGoalsGetDfltDatesReqObj);
            resolve(patGoalsGetDfltDatesReqJSON);
        }).then(patGoalsGetDfltDatesReqJSON => {
            return MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.patientGoalsDefaultDates
                , patGoalsGetDfltDatesReqJSON
                , dataObj.opts.sessionTimeOutUrl)
        }).then(responseData => {
            return new Promise((resolve, reject) => {
                let objDfltDates = {};
                objDfltDates.hasDates = false;
                objDfltDates.startDate = '';
                objDfltDates.endDate = '';
                objDfltDates.defaultGoalTypeID = '';
                if (responseData.rawData.hasRecord === true) {
                    objDfltDates.hasDates = true;
                    objDfltDates.startDate = responseData.rawData.data.startDateStrYMD;
                    objDfltDates.endDate = responseData.rawData.data.endDateStrYMD;
                    objDfltDates.defaultGoalTypeID = '' + responseData.rawData.data.defaultGoalTypeID;
                }
                resolve(objDfltDates);
            });
        });
    }

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function setPatientGoalDatesFromDflts(rowRef, objDfltDates) {        
        let sfldsArr = MBA.RestViewCommon.fnGetSavableFields(rowRef);
        let sfldsMap = MBA.RestViewCommon.fnPutSaveableFieldsInMap(sfldsArr);
        $(sfldsMap.get('startdate')).val(objDfltDates.startDate);
        $(sfldsMap.get('enddate')).val(objDfltDates.endDate);        
        $(sfldsMap.get('goaltypeid')).val(objDfltDates.defaultGoalTypeID);
    }

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

        /* We need these for the add new, clone, edit, delete */

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PAT_ID);

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForCloneSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForCloneSet', NV_PAT_ID);

        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_CLIENT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_PAT_ID);

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

        _updateAdditionalViewParameterValuesAndRequestViewFromServer($me);

    }; /*_fnSetup */

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        fnSetup: _fnSetup
        , fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer: _updateAdditionalViewParameterValuesAndRequestViewFromServer
    };

})(jQuery);