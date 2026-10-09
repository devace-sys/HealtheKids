; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PracticeOfficeVisitsCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.PracticeOfficeVisitsCommon = (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME        = 'Practice Office Visits Common Methods';
    const _THIS_NS          = 'mba-practice-office-visits';
    const _JQ_DATA_NAME     = 'jq-' + _THIS_NS;
    const _DATA_ATTR_BASE   = 'data-' + _THIS_NS;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
          PARM_NAME_CLIENT_ID: ''
        , PARM_NAME_GROUP_SVC_CLASS_NAME_ID: ''
        , PARM_NAME_SITE_ID: ''
        , PARM_NAME_PRAC_ID: ''
        , PARM_NAME_PAT_ID: ''
        , PARM_NAME_COMPLETED: ''
        , PARM_NAME_ACTIVE: ''
        , PARM_DATA_SOURCE: ''
        , PRAC_DATA_SOURCE_VALUE_WITHIN_PRACTICE_FAMILY_ONLY: ''
        , whatPage:1 /* 1 = Manage, 2= Waiting Room, 3=Patient Visit Manage*/
        , dataSourceValueForVisits: '1' /* 1= All/Manage , 2 = waiting room, 3 = patient visit manage */
        , containerCtrlID: ''
        , sessionTimeOutUrl: ''
        , baseUrlView: ''
        , defaultPageRowOrder: ''
        , baseUrlAddNew: ''
        , baseUrlEdit: ''
        , baseUrlDelete: ''
        , baseURLPracticeOfficeVisitReasonIDSel: ''
        , baseURLPatIDSel: ''
        , baseURLPracIDSel: ''
        , baseUrlPracticeOfficeVisitResolutionIDSel: ''
        , showCaption: false
        , caption: ''
        , enableScrollView: false
        , scrollViewUseCustomHeight: true
        , scrollViewCustomHeight: '15em'
        , autoHidePageControls: true
        , completedValue: ''
        , allowFilterByPracID:false
        , fnOnAfterCreate: function (elem, dataObj, $visibleCols) { return; }
        , fnCreateNewRowAfter: function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) { return $newRow; }
        , fnCreateNewCellAfter: function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) { return $newCell; }
        , fnOnResponseViewFromServer: function (elem, responseData, $me, dataObj) { return; }
        , fnOnAfterDrawTableBodyRows: function (elem, $me, dataObj) { return; }
        , fnOnEditInlineStart: function (uiActionObj, butRefsObj) { return; }
        , fnOKToAddNew: function (uiActionObj) { return true; }
        , enableReports:false
        , baseUrlReport:''
        , defaultReportNumber: ''
        , tkn: ''
        , fnEditInlineProceedAfter: function(uiActionObj, responseData, success) { return; }
        , fnOnEditInlineCancel: function(uiActionObj) { return; }

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
        
        /*########################################################################################################################
          #                               Set common options - All Screens
          ########################################################################################################################*/

        opts.enableScrollView           = optsIn.enableScrollView;
        opts.scrollViewUseCustomHeight  = optsIn.scrollViewUseCustomHeight;
        opts.scrollViewCustomHeight     = optsIn.scrollViewCustomHeight;
        opts.showCaption                = optsIn.showCaption;
        opts.caption                    = optsIn.caption;
        opts.autoHidePageControls       = optsIn.autoHidePageControls;
        opts.sessionTimeOutUrl          = optsIn.sessionTimeOutUrl;
        opts.requestViewOnLoad          = false; /*This is so we can set the initial filters */
        opts.enableRowNumbers           = false; /* Turn off row numbers */
        opts.enableReports              = optsIn.enableReports;
        opts.enableReportHtml           = true;
        opts.enableReportXls            = true;
        opts.enableReportPdf            = false;
        
        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = optsIn.baseUrlReport;
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber        = optsIn.defaultReportNumber;

        opts.enableRowControlRecClone   = false;
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

        opts.positionUserDefinedControlsInBodyExisting = 2; /* After built in*/
        opts.refreshViewAfterInlineEditProceed = true;

        opts.additionalControlDefinitionsForBodyRows = new Map();

        /* 1 = Manage, 2 = Waiting Room, 3 = Patient Visit Manage */

        /*########################################################################################################################
          #                            Set control options - Per Screen
          ########################################################################################################################*/

        /*--------------------------------
         * Manage/Review Completed Visits
         *-------------------------------*/

        if (optsIn.whatPage == 1) {
            opts.defaultPageRowOrder = 'visitStartDate desc, visitStartTime desc';
            opts.enableSortControls                 = true;
            opts.enableRowControls                  = true;
            opts.enableRowControlShowAdditionalInfo = true;
            opts.enableRowControlRecEdit            = true;
            opts.enableReports                      = true;
        }

        /*--------------------------------
         * Waiting Room
         *-------------------------------*/
        
        else if (optsIn.whatPage == 2) {

          opts.defaultPageRowOrder = 'checkInComplete asc, visiting asc, id desc';
            
          opts.enableSortControls        = false;
          opts.enableRowControls         = true;
          opts.enableRowControlRecAddNew = true;
          opts.enableRowControlRecEdit   = true;
          opts.enableRowControlRecDelete = true;
          opts.enableReports             = false;

          opts.additionalControlDefinitionsForBodyRows.set('startvisit', {
                  defType: 'userprovided'
                , name: 'startvisit'
                , toolTip: 'Click Here to Start The Visit'
                , cssClass: 'fas fa-plus-circle start-visit'
                , handlerFn: function (uiActionObj) {
                    let _parms = [];
                    let _clientid = uiActionObj.whatFieldCellsInputValues.get('clientID');
                    _parms.push(MBA.RestViewCommon.fnCreateNameValueObject(optsIn.PARM_NAME_CLIENT_ID, _clientid));
                    _parms.push(MBA.RestViewCommon.fnCreateNameValueObject(optsIn.PARM_NAME_REC_ID, uiActionObj.recordID));                   
                    let _url = MBA.RestViewCommon.fnBuildUrl(optsIn.baseUrlPatientVisitManage, true, _parms);
                    let _wn = 'practice-office-visit-' + uiActionObj.recordID;
                    MBA.RestViewCommon.fnOpenTab(uiActionObj.elem, _url, _wn, true);
                    return uiActionObj;
                }
                , initiallyHidden: false
            });
        }

       /*--------------------------------
        * Patient Visit Manage
        *-------------------------------*/

        else if (optsIn.whatPage == 3) {
          opts.defaultPageRowOrder  = 'id desc';
          opts.enableSortControls   = true;
          opts.enableRowControls    = false;
          opts.enableReports        = false;
        }

        /*########################################################################################################################
          #                        Set common field definitions - All Screens
          ########################################################################################################################*/
        
        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

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
              name: 'groupSvcClassNameID'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: 'groupSvcClassNameID'
            , saveUsing: 'groupserviceclassnameid'
            , showMore: false
        });

        /* Site ID */

        opts.fieldDefinitions.push({
            name: 'siteID'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: 'siteID'
            , saveUsing: 'siteid'
            , showMore: false
        });

        /*############################################################
          #  Define common field definition for form builder notes
          #  for resolution (used on some screens)
          #
          #  This includes the additionalCellValue definitions
          #  for the form builder question JSON and answer JSON
          ############################################################*/

        let _fnCreateFBFieldDefintionForResolutionNotes = function () {

            let resolutionNotesAdditionalCellValueFieldDefinitions = [];

            resolutionNotesAdditionalCellValueFieldDefinitions.push({
                name: 'practiceOfficeVisitResolutionFBQuestionsJSON'
                , label: ''
                , toolTip: ''
                , visible: false
                , sortable: false
                , editable: true
                , saveable: true
                , isRecID: false
                , dataType: 'jsondata'
                , sortUsing: ''
                , saveUsing: 'practiceofficevisitresolutionfbquestionsjson'
                , showMore: false
            });

            resolutionNotesAdditionalCellValueFieldDefinitions.push({
                name: 'practiceOfficeVisitResolutionFBAnswersJSON'
                , label: ''
                , toolTip: ''
                , visible: false
                , sortable: false
                , editable: true
                , saveable: true
                , isRecID: false
                , dataType: 'jsondata'
                , sortUsing: ''
                , saveUsing: 'practiceofficevisitresolutionfbanswersjson'
                , showMore: false
            });

            return {
                  name: 'practiceOfficeVisitResolutionNotes'
                , label: 'Notes'
                , toolTip: 'Notes'
                , visible: true
                , sortable: false
                , editable: true
                , saveable: true
                , saveUsing: 'practiceofficevisitresolutionnotes'
                , isRecID: false
                , dataType: 'textarea'
                , sortUsing: ''
                , showMore: false
                , additionalCellValueFieldDefinitions: resolutionNotesAdditionalCellValueFieldDefinitions
            };
        };

     
        /*########################################################################################################################
          #                          Set field definitions - Per Screen
          ########################################################################################################################*/

        /*--------------------------------
         * Manage/Review Completed Visits
         *-------------------------------*/

        if (optsIn.whatPage == 1) {

            /* ------------ Additional info fields  ------------ */

            opts.additionalInfoFieldDefinitions = [];

            /* Waiting time */

            opts.additionalInfoFieldDefinitions.push({
                name: 'waitingTimeStr'
                , label: 'Waiting Time'
                , toolTip: 'How long has the student had to wait'
                , visible: true
                , sortable: false
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: ''
                , saveUsing: ''
                , showMore: false
            });

            opts.additionalInfoFieldDefinitions.push({
                name: 'practiceOfficeVisitReasonNotes'
                , label: 'Reason For Visit Notes'
                , toolTip: 'Addition info the patient provided'
                , visible: true
                , sortable: false
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'pre'
                , sortUsing: ''
                , saveUsing: ''
                , showMore: false
            });

            /* ------------ Regular fields  ------------ */

            /* Prac ID */

            opts.fieldDefinitions.push({
                  name: 'pracID'
                , visible: false
                , sortable: false
                , saveable: true
                , editable: false
                , isRecID: false
                , dataType: 'hidden'
                , sortUsing: 'pracID'
                , saveUsing: 'pracid'
                , showMore: false
            });

            /* Check in date/time */

            opts.fieldDefinitions.push({
                name: 'checkInDateStr'
                , label: 'Check In<br>Date<br>Time'
                , toolTip: 'Check In Date and Time'
                , visible: true
                , sortable: true
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'checkInDateTime'                
                , showMore: false
                , styleAttrValueForCellValue: 'width:5em'
                , additionalCssClassesForCol: 'text-left'
                , additionalCssClassesForColTop: 'text-left'
                , additionalCssClassesForColLabel: 'text-left'
                , additionalCssClassesForCell: 'text-left'
                , additionalCssClassesForCellValue: 'text-left'
            });

            /*  Visit start date */

            opts.fieldDefinitions.push({
                name: 'visitStartDateYYMMDDStr'
                , label: 'Visit<br>Start<br>Date'
                , toolTip: 'Start date of visit with practitioner'
                , visible: true
                , sortable: true
                , saveable: true
                , editable: true
                , isRecID: false
                , dataType: 'date'
                , sortUsing: 'visitStartDate'
                , saveUsing: 'visitstartdate'
                , showMore: false
                , styleAttrValueForCellValue: 'width:9em'
            });

            /* Visit start time */

            opts.fieldDefinitions.push({
                name: 'visitStartTimeHHMMStr'
                , label: 'Visit<br>Start<br>Time'
                , toolTip: 'Start time of visit with practioner'
                , visible: true
                , sortable: true
                , saveable: true
                , editable: true
                , isRecID: false
                , dataType: 'time'
                , sortUsing: 'visitStartTime'
                , saveUsing: 'visitstarttime'
                , showMore: false
                , styleAttrValueForCellValue: 'width:7em'
            });

            /* Patient name */

            opts.fieldDefinitions.push({
                  name: 'patName'
                , label: 'Patient'
                , toolTip: 'Patient'
                , visible: true
                , sortable: true
                , editable: false
                , saveable: false
                , saveUsing: ''
                , isRecID: false
                , dataType: 'text'
                , sortUsing: 'patName'
                , showMore: false
                , additionalCssClassesForCol: 'text-left'
                , additionalCssClassesForColTop: 'text-left'
                , additionalCssClassesForColLabel: 'text-left'
                , additionalCssClassesForCell: 'text-left'
                , additionalCssClassesForCellValue: 'text-left'
            });

            /* Site Name */

            opts.fieldDefinitions.push({
                name: 'siteName'
                , label: 'Site'
                , toolTip: 'School Site'
                , visible: true
                , sortable: true
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'siteName'
                , saveUsing: ''
                , showMore: false
                , additionalCssClassesForCol: 'text-left'
                , additionalCssClassesForColTop: 'text-left'
                , additionalCssClassesForColLabel: 'text-left'
                , additionalCssClassesForCell: 'text-left'
                , additionalCssClassesForCellValue: 'text-left'

            });

            opts.fieldDefinitions.push({
                name: 'practiceOfficeVisitReasonName'
                , label: 'Reason'
                , toolTip: 'Why is the patient visiting'
                , visible: true
                , sortable: true
                , editable: false
                , saveable: false
                , saveUsing: ''
                , isRecID: false
                , dataType: 'string'               
                , sortUsing: 'practiceOfficeVisitReasonName'
                , showMore: false
                , styleAttrValueForCellValue: 'width:5em'
                , additionalCssClassesForCol: 'text-left'
                , additionalCssClassesForColTop: 'text-left'
                , additionalCssClassesForColLabel: 'text-left'
                , additionalCssClassesForCell: 'text-left'
                , additionalCssClassesForCellValue: 'text-left'
            });

            opts.fieldDefinitions.push({
                name: 'pracName'
                , label: 'Practitioner<br>Assigned'
                , toolTip: 'Practitioner Assigned'
                , visible: true
                , sortable: true
                , editable: false
                , saveable: false
                , saveUsing: ''
                , isRecID: false
                , dataType: 'string'                
                , sortUsing: 'pracName'
                , showMore: false
                , additionalCssClassesForCol: 'text-left'
                , additionalCssClassesForColTop: 'text-left'
                , additionalCssClassesForColLabel: 'text-left'
                , additionalCssClassesForCell: 'text-left'
                , additionalCssClassesForCellValue: 'text-left'
            });

            let resolutionsAutoCompleteOptions = {};

            resolutionsAutoCompleteOptions.baseUrl = optsIn.baseUrlPracticeOfficeVisitResolutionIDSel;
            resolutionsAutoCompleteOptions.loadMode = 'mbaviewsel';
            resolutionsAutoCompleteOptions.getInitialSelectedNameFrom = 'practiceOfficeVisitResolutionName';
            resolutionsAutoCompleteOptions.fnOnSelect = function (event, ui) { };
            resolutionsAutoCompleteOptions.fnModifyRequestNvps = function (nvpsIn) { return nvpsIn; };
            resolutionsAutoCompleteOptions.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
            resolutionsAutoCompleteOptions.fnModifyRenderItem = function ($ul, item, $li) { return $li; };
            resolutionsAutoCompleteOptions.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

            opts.fieldDefinitions.push({
                name: 'practiceOfficeVisitResolutionID'
                , label: 'Resolution'
                , toolTip: 'What was done'
                , visible: true
                , sortable: true
                , editable: true
                , saveable: true
                , saveUsing: 'practiceofficevisitresolutionid'
                , isRecID: false
                , dataType: 'autocomplete'
                , dataTypeOptions: resolutionsAutoCompleteOptions
                , sortUsing: 'practiceOfficeVisitResolutionName'
                , showMore: false
                , styleAttrValueForCellValue: 'width:6em'

            });

            /*  Visit start date */

            opts.fieldDefinitions.push({
                name: 'visitEndDateYYMMDDStr'
                , label: 'Visit<br>End<br>Date'
                , toolTip: 'End date of visit with practitioner'
                , visible: true
                , sortable: true
                , saveable: true
                , editable: true
                , isRecID: false
                , dataType: 'date'
                , sortUsing: 'visitEndDate'
                , saveUsing: 'visitenddate'
                , showMore: false
                , styleAttrValueForCellValue: 'width:9em'
            });

            /* Visit end date and time */

            opts.fieldDefinitions.push({
                name: 'visitEndTimeHHMMStr'
                , label: 'Visit<br>End<br>Time'
                , toolTip: 'End time of visit with practioner'
                , visible: true
                , sortable: true
                , saveable: true
                , editable: true
                , isRecID: false
                , dataType: 'time'
                , sortUsing: 'visitEndTime'
                , saveUsing: 'visitendtime'
                , showMore: false
                , styleAttrValueForCellValue: 'width:7em'
            });

            opts.fieldDefinitions.push({
                name: 'visitingTimeStr'
                , label: 'Visting<br>Time'
                , toolTip: 'How long has the student been with the practitioner'
                , visible: true
                , sortable: false
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'visitingTimeStr'
                , saveUsing: ''
                , showMore: false
                , styleAttrValueForCellValue: 'width:5em'
            });


            opts.fieldDefinitions.push(_fnCreateFBFieldDefintionForResolutionNotes());


        } /* Manage/Review Completed Visits */

        /*--------------------------------
         * Waiting Room
         *-------------------------------*/

        else if (optsIn.whatPage == 2) {

            
            /* Patient */

            let patIDOpts = {};
            patIDOpts.baseUrl = optsIn.baseUrlPatIDSel;
            patIDOpts.loadMode = 'mbaviewsel';
            patIDOpts.fnOnOpen = function (event, ui, $acObj) {
                $($acObj).css('width', '40em');
                return;
            };
            patIDOpts.getInitialSelectedNameFrom = 'patName';
            patIDOpts.fnOnSelect = function (event, ui) { };
            patIDOpts.fnModifyRequestNvps = function (nvpsIn) {
                let _siteID =  $('#' + optsIn.PARM_NAME_SITE_ID).val();
                MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'patdatasource', optsIn.PAT_DATA_SOURCE_VALUE_ALL_PATIENTS);
                MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'dos', '');
                MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, optsIn.PARM_NAME_SITE_ID, _siteID);

                /*    let _idxFound = MBA.ComponentCommon.fnFindNameValueObjIdxByNameInArrNameValues(nvpsIn, 'groupserviceclassnameid');
                    nvpsIn[_idxFound].value = '3';*/
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
                , label: 'Patient'
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
            });

            /* Student ID */

            opts.fieldDefinitions.push({
                name: 'studentID'
                , label: 'Student ID'
                , toolTip: 'Student ID'
                , visible: true
                , sortable: false
                , saveable: true
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'studentID'
                , saveUsing: 'studentid'
                , showMore: false
            });

            /* Grade */

            opts.fieldDefinitions.push({
                name: 'grade'
                , label: 'Grade'
                , toolTip: 'Current grade'
                , visible: true
                , sortable: false
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'grade'
                , saveUsing: ''
                , showMore: false
            });

            /* Site Name */

            opts.fieldDefinitions.push({
                name: 'siteName'
                , label: 'Site'
                , toolTip: 'School Site'
                , visible: true
                , sortable: true
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'siteName'
                , saveUsing: ''
                , showMore: false
            });


            /* Reason for visit */

            let visitReasonIDOpts = {};
            visitReasonIDOpts.baseUrl = optsIn.baseUrlPracticeOfficeVisitReasonIDSel;
            visitReasonIDOpts.loadMode = 'mbaviewsel';
            visitReasonIDOpts.getInitialSelectedNameFrom = 'practiceOfficeVisitReasonName';
            visitReasonIDOpts.fnOnSelect = function (event, ui) { };
            visitReasonIDOpts.fnModifyRequestNvps = function (nvpsIn) {return nvpsIn;};
            visitReasonIDOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
            visitReasonIDOpts.fnModifyRenderItem = function ($ul, item, $li) {return $li;};
            visitReasonIDOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

            opts.fieldDefinitions.push({
                name: 'practiceOfficeVisitReasonID'
                , label: 'Reason for Visit'
                , toolTip: 'Why is the patient visiting'
                , visible: true
                , sortable: true
                , editable: true
                , saveable: true
                , saveUsing: 'practiceofficevisitreasonid'
                , isRecID: false
                , dataType: 'autocomplete'
                , dataTypeOptions: visitReasonIDOpts
                , sortUsing: 'practiceOfficeVisitReasonName'
                , showMore: false
            });

            /* Reason for visit notes*/

            opts.fieldDefinitions.push({
                name: 'practiceOfficeVisitReasonNotes'
                , label: 'Reason For Visit Notes'
                , toolTip: 'Additional information on why patient is visiting'
                , visible: true
                , sortable: false
                , saveable: true
                , editable: true
                , isRecID: false
                , dataType: 'textarea'
                , sortUsing: 'practiceOfficeVisitReasonNotes'
                , saveUsing: 'practiceofficevisitreasonnotes'
                , showMore: false
            });
            
            /* Practitioner */

            let pracIDOpts = {};
            pracIDOpts.baseUrl = optsIn.baseUrlPracIDSel;
            pracIDOpts.loadMode = 'mbaviewsel';
            pracIDOpts.getInitialSelectedNameFrom = 'pracName';
            pracIDOpts.fnOnSelect = function (event, ui) { };
            pracIDOpts.fnModifyRequestNvps = function (nvpsIn) {
                MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'pracdatasource', optsIn.PRAC_DATA_SOURCE_VALUE_WITHIN_PRACTICE_FAMILY_ONLY);
                MBA.ComponentCommon.fnAddNameValueToArrNameValues(nvpsIn, 'dos', '');
                /*    let _idxFound = MBA.ComponentCommon.fnFindNameValueObjIdxByNameInArrNameValues(nvpsIn, 'groupserviceclassnameid');
                    nvpsIn[_idxFound].value = '3';*/
                return nvpsIn;
            };

            /*Practitioner assigned */

            pracIDOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
            pracIDOpts.fnModifyRenderItem = function ($ul, item, $li) {
                var ctxt1 = $('<br><sup>' + item.recData2 + '</sup>');
                $($li).children('a').append(ctxt1);
                return $li;
            };

            pracIDOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

            opts.fieldDefinitions.push({
                name: 'pracID'
                , label: 'Practitioner<br>Assigned'
                , toolTip: 'Practitioner Assigned'
                , visible: true
                , sortable: true
                , editable: true
                , saveable: true
                , saveUsing: 'pracid'
                , isRecID: false
                , dataType: 'autocomplete'
                , dataTypeOptions: pracIDOpts
                , sortUsing: 'pracName'
                , showMore: false
            });

            /* Check in date */

            opts.fieldDefinitions.push({
                name: 'checkInDateStr'
                , label: 'Check In<br>Date<br>Time'
                , toolTip: 'The date and time that the student checked in'
                , visible: true
                , sortable: true
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'checkInDate'
                , saveUsing: 'checkindate'
                , showMore: false
            });


            /* Waiting time */

            opts.fieldDefinitions.push({
                name: 'waitingTimeStr'
                , label: 'Waiting<br>Time'
                , toolTip: 'How long has the student had to wait'
                , visible: true
                , sortable: false
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'waitingTimeStr'
                , saveUsing: ''
                , showMore: false
            });

            /* Visit time */

            opts.fieldDefinitions.push({
                name: 'visitingTimeStr'
                , label: 'Visting<br>Time'
                , toolTip: 'How long has the student been with the practitioner'
                , visible: true
                , sortable: false
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'visitingTimeStr'
                , saveUsing: ''
                , showMore: false
            });

        } /* Wating room */

        /*--------------------------------
         * Patient Visit Manage
         *-------------------------------*/

        else if (optsIn.whatPage == 3) {

            /* Note: Patient info is displayed on screen elsewhere*/

            /*  Visit start date */

            opts.fieldDefinitions.push({
                name: 'visitStartDateStr'
                , label: 'Visit<br>Start<br>Date'
                , toolTip: 'Start date of visit with practitioner'
                , visible: true
                , sortable: true
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'visitStartDate'
                , saveUsing: ''
                , showMore: false
            });

            /* Visit start time */

            opts.fieldDefinitions.push({
                name: 'visitStartTimeStr'
                , label: 'Visit<br>Start<br>Time'
                , toolTip: 'Start time of visit with practioner'
                , visible: true
                , sortable: false
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'visitStartTime'
                , saveUsing: ''
                , showMore: false
            });


            /* Visit Reason */

            opts.fieldDefinitions.push({
                  name: 'practiceOfficeVisitReasonName'
                , label: 'Reason for Visit'
                , toolTip: 'Reason for visit'
                , visible: true
                , sortable: false
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'practiceOfficeVisitReasonName'
                , saveUsing: ''
                , showMore: false
            });

            opts.fieldDefinitions.push({
                name: 'practiceOfficeVisitReasonNotes'
                , label: 'Reason For Visit Notes'
                , toolTip: 'Additional notes'
                , visible: true
                , sortable: false
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'pre'
                , sortUsing: ''
                , saveUsing: ''
                , showMore: false
            });

            opts.fieldDefinitions.push({
                  name: 'pracName'
                , label: 'Practitioner<br>Assigned'
                , toolTip: 'Practitioner assigned'
                , visible: true
                , sortable: false
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: ''
                , saveUsing: ''
                , showMore: false
            });
            
           
            /* Visit End Date */

            opts.fieldDefinitions.push({
                name: 'visitEndDateStr'
                , label: 'Visit<br>End<br>Date'
                , toolTip: 'End date of visit with practitioner'
                , visible: true
                , sortable: false
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'visitEndDate'
                , saveUsing: ''
                , showMore: false
            });

            /* Visit End time */

            opts.fieldDefinitions.push({
                name: 'visitEndTimeStr'
                , label: 'Visit<br>End<br>Time'
                , toolTip: 'End time of visit with practioner'
                , visible: true
                , sortable: false
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'visitEndTime'
                , saveUsing: ''
                , showMore: false
            });

            opts.fieldDefinitions.push({
                name: 'practiceOfficeVisitResolutionName'
                , label: 'Resolution'
                , toolTip: 'What was the outcome of the visit'
                , visible: true
                , sortable: false
                , editable: false
                , saveable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'practiceOfficeVisitResolutionName'
                , saveUsing: ''
                , showMore: false
            });


            opts.fieldDefinitions.push(_fnCreateFBFieldDefintionForResolutionNotes());

            /* Grade */

            opts.fieldDefinitions.push({
                name: 'grade'
                , label: 'Grade'
                , toolTip: 'Current or previous grade'
                , visible: true
                , sortable: false
                , saveable: false
                , editable: false
                , isRecID: false
                , dataType: 'string'
                , sortUsing: 'grade'
                , saveUsing: ''
                , showMore: false
            });

          
        } /* Patient visit manage */

        const ATTR_NAME_MBA_NOTE_LIB_REF_DATA = 'mba-note-lib-ref-data';

        /*########################################################################################################################
          #  Define afterCell, afterRow hooks and handlers 
          #  for resolution
          ########################################################################################################################*/

        let _fnCreateNewCellAfterForEditingResolutionNotes = function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {

            /* This is called for cases when whatPage is 1 */

            if (fieldDefinition.name == 'practiceOfficeVisitResolutionNotes') {

                let $formBuilderQuestionsJsonTA = addCellValRefsMap.get('practiceOfficeVisitResolutionFBQuestionsJSON');
                let $formBuilderAnswersJsonTA = addCellValRefsMap.get('practiceOfficeVisitResolutionFBAnswersJSON');
                
                let _fnNoteLibFormBuilder = function ($div) {
                    $($div).html('');
                   
                    renderFormInDiv( $div
                        , '' + $($formBuilderQuestionsJsonTA).val()
                        , '' + $($formBuilderAnswersJsonTA).val()
                        , rowData.clientID
                        , rowData.patID
                        , rowData.groupID
                        , function (fbNoteAnswersJSON) { $($formBuilderAnswersJsonTA).val(fbNoteAnswersJSON); });
                };

                let _fnNoteLibGetPatID = function () {
                    return '' + rowData.patID;
                };
                
                $($newCellValue).wrap('<div class="mba-edit-notes"></div>');
                let notesFs = $($newCellValue).parent();
                $(notesFs).attr(MBA.RestViewCommon.ATTR_NAME_FIELD_EDIT_STATE, MBA.RestViewCommon.ATTR_VALUE_EDIT_STATE_LOCKED);
                $(notesFs).attr('disabled', '');                
                $(notesFs).hide();
                $($newCellValue).notelibrary({
                    displayMode: ""
                    , useMenu: true
                    , useLabelInOpenButton: false
                    , sel_tmp_enabled: false
                    , tkn: optsIn.tkn
                    , noteforpatidfn: (_fnNoteLibGetPatID)
                    , additionalcontentfn: (_fnNoteLibFormBuilder)
                });
            }
            return $newCell;
        };

        /*############################################################
          #  Define common handlers for displaying (not editing) form 
          # builder notes (used on some screens)
          ############################################################*/

        let _fnGeneratePdfFormResolution = async function (elementID, $anchorPDF) {
            let pdfLibObjs    = await MBA.PdfCommon.fnGeneratePdfFromHtmlElement(elementID);
            let base64DataUri = await pdfLibObjs.pdfDoc.saveAsBase64({ dataUri: true });
            $($anchorPDF).attr('href', base64DataUri);
            $($anchorPDF).show();
            return true;
        };

        
        let _fnCreateNewCellAfterForResolutionNotes = function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {            

            if (fieldDefinition.name == 'practiceOfficeVisitResolutionNotes') {                

                let $formBuilderQuestionsJsonTA = addCellValRefsMap.get('practiceOfficeVisitResolutionFBQuestionsJSON');
                let $formBuilderAnswersJsonTA   = addCellValRefsMap.get('practiceOfficeVisitResolutionFBAnswersJSON');
                let butID = MBA.ComponentCommon.fnCreateNewUUID();
                let $butShowFormData = $('<button title="Click here to see notes" type="button" style="border:none;background:none;"><i class="fas fa-clipboard mba-notelibrary text-success"></i></button>');
                $($butShowFormData).attr('id', butID);
                $($butShowFormData).attr('class', "mba-show-notes");
                let $dia = $('<div></div>');
                let diaContentID = MBA.ComponentCommon.fnCreateNewUUID();
                let diaContentTitle = rowData.patName;
                let divID = MBA.ComponentCommon.fnCreateNewUUID();
                $($dia).attr('id', diaContentID);
                $($dia).attr('title', diaContentTitle);
                $($newCell).append($butShowFormData);
                $($newCell).append($dia);
                $($dia).hide();
                $($newCellValue).hide();
                let objMBANoteLibRefData = {};
                objMBANoteLibRefData.exportNotesButID = butID;
                $($newCellValue).data(ATTR_NAME_MBA_NOTE_LIB_REF_DATA, objMBANoteLibRefData);

                $($butShowFormData).on('click', function (e) {

                    $($dia).children().remove();
                    spedmonRenderFormInContainerFromJSON($formBuilderQuestionsJsonTA, $formBuilderAnswersJsonTA, true, false, $dia);

                    let $div = $($dia).children().first();
                    $($div).attr('id', divID)
                    
                    let $anchorPDF = $('<a title="Download">Download PDF <i class="fa fa-file-pdf text-danger"></i></a>');

                    let fname = 'Office Visit'
                        + '-'
                        + rowData.siteName
                        + '-'
                        + rowData.pracLastName
                        + '-'
                        + rowData.visitEndDateYYMMDDStr
                        + '-'
                        + rowData.visitEndTimeHHMMStr
                        + '-'
                        + rowData.patLastName
                        + '.pdf';

                    $($anchorPDF).attr('download', fname);
                    $($anchorPDF).attr('type', 'application/pdf');

                    let $options = $('<div></div>');
                    $($options).append($anchorPDF);

                    let additionalNotesVal = $($newCellValue).val();
                    let $additionalNotesHR = $('<hr></hr>');
                    let $additionalNotesTA = $('<textarea>' + additionalNotesVal + '</textarea>');

                    let $notesHeader = $('<h2 class="office-visit-notes"></h2>');
                    $($notesHeader).append($('<p>' + rowData.siteName + '</p>'));
                    $($notesHeader).append($('<p>' + rowData.pracName + ' - ' + rowData.pracTitle + '</p>'));
                    $($notesHeader).append($('<p>' + rowData.patName + ' was seen on ' + rowData.visitEndDateStr + ' ' + rowData.visitEndTimeStr + '</p>'));
                    $($div).prepend($notesHeader);
                    $($div).append($additionalNotesHR);
                    $($div).append($additionalNotesTA);

                    MBA.PdfCommon.fnConvertToPrintableContent($div);
                    MBA.ComponentCommon.fnSetAllFormFieldsAsNonEditable($div);
                    MBA.PdfCommon.fnApplyPdfFonts($div);

                    $($dia).prepend($options);
                    $($anchorPDF).hide();

                    MBA.ComponentCommon.fnCreateDialogFromElem($dia, 90, 90, {
                          modal:false
                        , open: function (event, ui) {
                            _fnGeneratePdfFormResolution(divID, $anchorPDF);
                        }
                        , buttons: [
                            { text: "Close", click: function () { $(this).dialog("close"); } }
                        ]
                    });

                });

            }
            return $newCell;
        };

        /*############################################################
          # Hook called after new cell is created
          ############################################################*/

        opts.fnCreateNewCellAfter = function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {


            /* Existing row */

            if ((subsection === 103) && (rowtype === 4)) {

                /* Review */

                if (optsIn.whatPage == 1) {

                    if (fieldDefinition.name == 'checkInDateStr') {
                        $($newCellValue).append('<br>');
                        $($newCellValue).append(rowData.checkInTimeStr);
                    }
                    else if (fieldDefinition.name == 'patName') {
                        $($newCellValue).attr('title', 'Student ID : ' + rowData.studentID + ' Grade : ' + rowData.grade);                                       
                    }

                    $newCell = _fnCreateNewCellAfterForResolutionNotes($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap);
                    $newCell = _fnCreateNewCellAfterForEditingResolutionNotes($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap);
                }

                /* Waiting Room */

                else if (optsIn.whatPage == 2) {

                    if (fieldDefinition.name == 'checkInDateStr') {
                        $($newCellValue).append('<br>');
                        $($newCellValue).append(rowData.checkInTimeStr);
                    }
                    if (fieldDefinition.name == 'waitingTimeStr') {
                        if (rowData.visiting == true) {
                            $($newCellValue).html('');
                        }
                    }
                }

                /* Visit manage */

                else if (optsIn.whatPage == 3) {
                    $newCell = _fnCreateNewCellAfterForResolutionNotes($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap);
                }

            }

            /* New rows start */

            if ((subsection === 102) && (rowtype === 2)) {

                if (fieldDefinition.name == 'clientID') {
                    let clientIDVal = $('#' + optsIn.PARM_NAME_CLIENT_ID).val();
                    $($newCellValue).val(clientIDVal);
                }

                else if (fieldDefinition.name == 'groupSvcClassNameID') {
                    let groupSvcClassNameIDVal = $('#' + optsIn.PARM_NAME_GROUP_SVC_CLASS_NAME_ID).val();
                    $($newCellValue).val(groupSvcClassNameIDVal);
                }

                else if (fieldDefinition.name == 'siteID') {
                    let siteIDVal = $('#' + optsIn.PARM_NAME_SITE_ID).val();
                    $($newCellValue).val(siteIDVal);
                }

            } /* New rows end */

            /* Call passed in hook */

            return optsIn.fnCreateNewCellAfter($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap);
            
        };

        /*############################################################
          # Hook for after new row created
          ############################################################*/

        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

            /* Existing row*/
            if ((subsection === 103) && (rowtype === 4)) {

                /* Waiting Room */

                if (optsIn.whatPage == 2) {
                    if (rowData) {
                        /* If visit is happening hide edit and delete */
                        if (rowData.visiting == true) {
                            $(MBA.RestViewCommon.fnFindRowControl($newRow, 'receditinlinestart')).hide();
                            $(MBA.RestViewCommon.fnFindRowControl($newRow, 'recdeleteinlinestart')).hide();
                        }
                        /* If check in is not complete animate edit icon*/
                        else if (rowData.checkInComplete == false) {
                            $(MBA.RestViewCommon.fnFindRowControl($newRow, 'receditinlinestart')).addClass('mba-rest-view-animation-heartbeat-infinite');
                        }                        
                    }
                }
            }

          /* Call passed in hook */
          return optsIn.fnCreateNewRowAfter($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData);
        };

        /*############################################################
          # On response view from server
          ############################################################*/

        opts.fnOnResponseViewFromServer = function (elem, responseData, $me, dataObj) {
            /* Call passed in hook */
            return optsIn.fnOnResponseViewFromServer(elem, responseData, $me, dataObj);
        };

        /*############################################################
          # After creation
          ############################################################*/

        opts.fnOnAfterCreate = function (elem, dataObj, $visibleCols) {

            /* Change icon for add new if add new is enabled */

            if (opts.enableRowControlRecAddNew == true) {          
                let _ctrlAddNew = MBA.RestViewCommon.fnFindHeaderControl(elem, 'recaddnewinlinestart')[0];                
                MBA.RestViewCommon.fnReplaceIconImageInControl(_ctrlAddNew, 'fa-plus fa-2x', 'fa-plus-circle new-visit');
            }

            /* Call passed in hook */

            return optsIn.fnOnAfterCreate(elem, dataObj, $visibleCols);
        };
   
        /*############################################################
          # After draw table body
          ############################################################*/

        opts.fnOnAfterDrawTableBodyRows = function (elem, $me, dataObj) {
            /* Call passed in hook */
            return optsIn.fnOnAfterDrawTableBodyRows(elem, $me, dataObj);
        };

        /*############################################################
          # After edit inline start
          ############################################################*/

        opts.fnOnEditInlineStart = function (uiActionObj, butRefsObj) {
            /* Call passed in hook */
            $(uiActionObj.whatRow.lastChild).children('.mba-show-notes').hide();
            $(uiActionObj.whatRow.lastChild).children('.mba-edit-notes').show();            
            return optsIn.fnOnEditInlineStart(uiActionObj, butRefsObj);            
        };

        /*############################################################
          # After edit inline proceed
          ############################################################*/
        opts.fnEditInlineProceedAfter = function (uiActionObj, responseData, success) {           
            return;
        }

        /*############################################################
          # After edit inline cancel
          ############################################################*/
        opts.fnOnEditInlineCancel = function (uiActionObj) {
            $(uiActionObj.whatRow.lastChild).children('.mba-show-notes').show();
            $(uiActionObj.whatRow.lastChild).children('.mba-edit-notes').hide();
            return;
        }


        /*############################################################
          # OK to add new
          ############################################################*/

        opts.fnOKToAddNew = function (uiActionObj) {
          return optsIn.fnOKToAddNew(uiActionObj);
        };
        
        /* Create the rest view */

        $($me).MBA_RestView(opts);

        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _updateAdditionalViewParameterValuesAndRequestViewFromServer = function ($me) {

        let dataObj = _fnGetDataObj($me);

        let VALUE_CLIENT_ID               = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let VALUE_GROUP_SVC_CLASS_NAME_ID = $('#' + dataObj.opts.PARM_NAME_GROUP_SVC_CLASS_NAME_ID).val();
        let VALUE_SITE_ID                 = $('#' + dataObj.opts.PARM_NAME_SITE_ID).val();
        let VALUE_PRAC_ID                 = '';
        
        if (dataObj.opts.allowFilterByPracID == true) {
            VALUE_PRAC_ID = $('#' + dataObj.opts.PARM_NAME_PRAC_ID).val();
        };

        let VALUE_PAT_ID                  = $('#' + dataObj.opts.PARM_NAME_PAT_ID).val();
        let VALUE_COMPLETED               = dataObj.opts.completedValue;
        let VALUE_ACTIVE                  = '1';
        let VALUE_VISIT_DATA_SOURCE       = dataObj.opts.dataSourceValueForVisits;        
        

        let NV_CLIENT_ID               = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_GROUP_SVC_CLASS_NAME_ID = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_GROUP_SVC_CLASS_NAME_ID, VALUE_GROUP_SVC_CLASS_NAME_ID);

        let NV_SITE_ID   = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_SITE_ID,   VALUE_SITE_ID);
        let NV_PRAC_ID   = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PRAC_ID,   VALUE_PRAC_ID);
        let NV_PAT_ID    = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_PAT_ID,    VALUE_PAT_ID);
        let NV_COMPLETED = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_COMPLETED, VALUE_COMPLETED);
        let NV_ACTIVE    = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_ACTIVE,    VALUE_ACTIVE);        

        let NV_VISIT_DATA_SOURCE = MBA.RestViewCommon.fnCreateNameValueObject(dataObj.opts.PARM_DATA_SOURCE, VALUE_VISIT_DATA_SOURCE);        
        
        /* Note: Don't use a loop here, keep it unrolled for performance reasons */        
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);      
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GROUP_SVC_CLASS_NAME_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SITE_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_COMPLETED);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);
        $(dataObj.restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_VISIT_DATA_SOURCE);                

        $(dataObj.restViewCtrl).MBA_RestView('requestViewFromServer', 1);        
    };
    
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnRefreshView = function (elementid) {
        let $me = _fnGetMe(elementid);        
        _updateAdditionalViewParameterValuesAndRequestViewFromServer($me);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnRefreshViewIfUserIsNotActivelyManagingRows = function (elementid) {
        let $me = _fnGetMe(elementid);
        let dataObj = _fnGetDataObj($me);
        let isUserActive = $(dataObj.restViewCtrl).MBA_RestView('isUserActivelyManagingRows');
        if (isUserActive == false) {
            _updateAdditionalViewParameterValuesAndRequestViewFromServer($me);
        }
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
        , fnRefreshView: _fnRefreshView
        , fnRefreshViewIfUserIsNotActivelyManagingRows: _fnRefreshViewIfUserIsNotActivelyManagingRows
    }

})(jQuery);