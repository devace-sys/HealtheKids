<%@ Page Language="C#" CodeBehind="user_all_rmts_moment_pcal_review.aspx.cs" Inherits="Spedmon.UserAllRmtsMomentPcalReview" %>

<%//-----------------------------------------------------------------------------%>
<%// Define dialog for review details %>
<%//-----------------------------------------------------------------------------%>

<div id="diaReviewDetails" title="Please Enter Details">
    <div id="suggestedActivityCodeCont" style="padding:1em;">
    <label id="suggestedActivityCodeLbl" for="suggestedactivitycode" style="margin-right:1em;">Select What Activity Code Should Be Assigned</label>

    <select id="suggestedActivityCode" name="suggestedactivitycode" class="spedmon-select">
        <option value="2A">2A</option>
        <option value="2Z">2Z</option>
        <option value="8">8</option>
    </select>
    </div>
    <div>

    <Spedmon:DataEntryBoxText ID="reviewReason" name="reviewReason" size="20" label="Enter The Reason Justifying This Change" runat="server" />

    <Spedmon:DataEntryBoxTextArea ID="reviewNotes"  name="reviewnotes" size="20" label="Additional Notes" runat="server" />

    <%=dataListHtmlForChangeReasonsCode2A%>
    <%=dataListHtmlForChangeReasonsCode2Z%>
    <%=dataListHtmlForChangeReasonsCode8%>

    </div>
</div>

<div id="dataManagementRows" class="container-fluid">

    <div class="row">
        <div class="col-12">

            <%//-----------------------------------------------------------------------------%>
            <%// Select Client %>
            <%// (Practi-Cal staff only) %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryRowSelectClient
                ID                   = "selectClient"
                entityControlID      = "clientid"
                rowLabel             = "Client"
                dataEntryRowRenderAs = "FIELD"
                runat                = "server">
            </Spedmon:DataEntryRowSelectClient>

            <%//-----------------------------------------------------------------------------%>
            <%// Select Quarter %>
            <%//-----------------------------------------------------------------------------%>


            <Spedmon:DataEntryRowSelectFiscalYear
                ID                   = "selectFiscalYear"
                entityControlID      = "fiscalyearid"
                rowLabel             = "Fiscal Year"
                dataEntryRowRenderAs = "FIELD"
                runat                = "server">
            </Spedmon:DataEntryRowSelectFiscalYear>



        </div>
    </div>

    <div class="row">

      <div class="col-4">
        <Spedmon:RadioBox
           ID="fiscalquarterselection"
           name="fiscalquarterselection"
           title="Quarter"
           renderLabel="true"
           additionalCssClassNameForContainer="modern2021"
           runat="server" />
      </div> <!-- col -->

    </div>

    <%-----------------------------%>
    <%--    Matches Required     --%>
    <%--      Status             --%>
    <%-----------------------------%>

    <div class="row">


      <div class="col-4">
        <Spedmon:RadioBox ID="activitycodeselection" name="activitycodeselection" title="Activity Code" renderLabel="true" additionalCssClassNameForContainer="modern2021" runat="server" />
      </div> <!-- col -->


      <div class="col-8">
        <Spedmon:RadioBox ID="reviewstatuscodeselection" name="reviewstatuscodeselection" title="Review Status Code" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />
      </div> <!-- col -->
    </div>


    <%-----------------------------%>
    <%--       Rest view         --%>
    <%--      RMTS Moments       --%>
    <%-----------------------------%>

    <div id="restViewRowRmtsMoments" class="row mt-3 mb-3">
        <div class="col-12">
        <div id="restViewRmtsMoments" class="col-12"></div>
        </div> <!-- col -->
    </div> <!-- row -->


</div>

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">
    /************************************************************************************************************************* */

    let $dataManagementRows        = null;
    let $restViewCtrl              = null;
    let $restViewCtrl_rmtsMoments  = null;
    let $diaReviewDetails          = null;
    let $suggestedActivityCodeCont = null;
    let $suggestedActivityCode     = null
    let $reviewReason              = null;
    let $reviewNotes               = null;

    const PARM_NAME_CLIENT_ID         = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_ACTIVE            = '<%=Constants.PARM_ACTIVE%>';
    const PARM_NAME_SVC_DATE_RANGE    = '<%=Spedmon.Constants.PARM_DATE_RANGE%>';
    const PARM_NAME_FISCAL_QUARTER_ID = '<%=MBA.Constants.PARM_FISCAL_QUARTER_ID%>';
    const PARM_NAME_FY_QUARTER_ID     = '<%=MBA.Constants.PARM_FY_QUARTER_ID%>';
    const PARM_NAME_PRAC_ID           = '<%=MBA.Constants.PARM_PRACTITIONER_ID%>';


    /* Use the recData values returned and
    * build the date range string used to filter by dos range
    * for the service records view and put the range string in the appropriate hidden input */
    function populateDateRangeFromQtrSelectionCallbackData(e) {
        <%
        // DRY principle; was copied into the user_all_rmts_moment_service_records_manage.aspx page.
        // TODO: fix
        %>
        let startDateVal = new Date(e.dataitem.recData1);
        let modifiedStartDate = new Date(startDateVal.setMonth(startDateVal.getMonth() - 3)).toLocaleDateString();

        let endDateVal = new Date(e.dataitem.recData2);
        let modifiedEndDate = new Date(endDateVal.setMonth(endDateVal.getMonth() + 3)).toLocaleDateString();

        $('#' + PARM_NAME_SVC_DATE_RANGE).val(modifiedStartDate + ' - ' + modifiedEndDate);
    }


    /*********************************************************** RMTS MOMENTS REST VIEW **************************************************************************************/
    function updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMoments(e) {

        // debugger;

        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_ACTIVE    = '1';

        // let VALUE_FY_QTR    = $('#fyquarterid').val();
        let VALUE_FY_ID    = $('#fiscalyearid').val();

        //let VALUE_QTR_NUM    = $('#fyquarterid').val();
        let VALUE_QTR_NUM = (
            ($('#fiscalquarterselection_radiobox_ctrl :checked').length > 0)
                ? ($('#fiscalquarterselection_radiobox_ctrl :checked').val())
                : ''
        );

        let VALUE_ACT_CODE  = $('#activitycodeselection').val();
        let VALUE_REV_STATUS = $('#reviewstatuscodeselection').val();

        let NV_CLIENT_ID    = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_ACTIVE       = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);

        // let NV_QUARTER      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FISCAL_QUARTER_ID, VALUE_FY_QTR);
        let NV_FY      = MBA.RestViewCommon.fnCreateNameValueObject(
                           '<%= Constants.PARM_FISCAL_YEAR_ID %>'
                           ,
                           VALUE_FY_ID
                         );

        let NV_QTR_NUM      = MBA.RestViewCommon.fnCreateNameValueObject(
                           '<%= Constants.PARM_QUARTER_NUMBER %>'
                           ,
                           VALUE_QTR_NUM
                         );

        let NV_ACTIVITYCODE = MBA.RestViewCommon.fnCreateNameValueObject('activity_code',VALUE_ACT_CODE );
        let NV_REVIEWSTATUSCODE = MBA.RestViewCommon.fnCreateNameValueObject('review_status_code', VALUE_REV_STATUS);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrlRmtsMoments).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrlRmtsMoments).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        // $($restViewCtrlRmtsMoments).MBA_RestView('additionalParameterDefinitionForViewSet', NV_QUARTER);

        $($restViewCtrlRmtsMoments).MBA_RestView(
              'additionalParameterDefinitionForViewSet',
               NV_FY);

        $($restViewCtrlRmtsMoments).MBA_RestView(
              'additionalParameterDefinitionForViewSet',
              NV_QTR_NUM);


        $($restViewCtrlRmtsMoments).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVITYCODE);
        $($restViewCtrlRmtsMoments).MBA_RestView('additionalParameterDefinitionForViewSet', NV_REVIEWSTATUSCODE);


        $($restViewCtrlRmtsMoments).MBA_RestView('requestViewFromServer', 1);

        //updateCountOfMatchesRequired();

    };

    function setReviewReasonDataListAssignment(dataListID) {
        $($reviewReason).MBA_DataEntryBox('setListAssignment', dataListID);
    };

    function initDiaReviewDetails() {
        $($diaReviewDetails).dialog('destroy');
        $($diaReviewDetails).hide();
        $($suggestedActivityCode).val('');
        $($reviewReason).MBA_DataEntryBox('clearValue');
        setReviewReasonDataListAssignment('');
        $($reviewNotes).MBA_DataEntryBox('clearValue');
    };

    function rmtsReviewSave(uiActionObj, thumbup) {

        // deactivate button until we get a response
        //deactivateIcon(uiActionObj.whatElement);

        //debugger;

        // send ajax to edit hold record
        let reqUrl = '<%=Spedmon.RmtsMoments.URL_SERVICE_REVIEW_BASE() %>';

        let rmtsMomentIDVal = uiActionObj.recordID;
        let pcalReviewStatusVal = (thumbup ? 200 : 300);
        let suggestedActivityCodeVal = $($suggestedActivityCode).val();
        let reviewReasonVal = (thumbup ? "" : $($reviewReason).val());
        let reviewNotesVal = $($reviewNotes).val();

        if (!thumbup) {
            if (!suggestedActivityCodeVal) return;
            if (!reviewReasonVal) return;
        }

        let reqObj = {};
        reqObj.rmtsMomentID          = rmtsMomentIDVal;
        reqObj.pcalReviewSstatus     = pcalReviewStatusVal;
        reqObj.reason                = reviewReasonVal
        reqObj.suggestedActivityCode = suggestedActivityCodeVal;
        reqObj.notes                 = reviewNotesVal

        let reqJSON = JSON.stringify(reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, null)
            .then(responseData => {
                $($restViewCtrlRmtsMoments).MBA_RestView('refreshCurrentViewFromServer');
                activateIcon(uiActionObj.whatElement);
                initDiaReviewDetails();

            })
            .catch(responseData => {
                //activateIcon(uiActionObj.whatElement);
            });
    };

    function openDiaReviewDetails(uiActionObj, thumbup) {

        initDiaReviewDetails();
        $($diaReviewDetails).show();

        if (thumbup === true) {
            $($suggestedActivityCodeCont).hide();

            $($reviewReason).hide();
            $($reviewNotes).show();
        }
        else  {
            $($suggestedActivityCodeCont).show();

            $($reviewReason).show();
            $($reviewNotes).show();
        }

        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(50);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(50);

        let diaOpts = {
              position: { my: 'center', at: 'top', of: window }
            , modal: true
            , closeOnEscape: false
            , width: (vw)
            , height: (vh)
            , close: function (event, ui) {
                initDiaReviewDetails();
            }
            , buttons: [
                { text: "Cancel", click: function () { $($diaReviewDetails).dialog('close'); } }
                , { text: "Proceed", click: function () { rmtsReviewSave(uiActionObj, thumbup); $($diaReviewDetails).dialog('close');}}
            ]
        };

        $($diaReviewDetails).dialog(diaOpts);
    }


    function initViewMomentsReq() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = false;
        opts.enableRowControlRecDelete = false;

        opts.enableRowControlShowAdditionalInfo = true;
        opts.additionalInfoFieldDefinitions = [];

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inwindow';
        opts.baseUrlEdit = '';
        opts.baseUrlEditHasParameters = true;

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.RmtsMoments.URL_REST_VIEW_RMTS_REQS()%>';
	    opts.baseUrlViewHasParameters = true;

	    opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport = '<%=Spedmon.RmtsMoments.URL_WEB_REPORT_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = <%= Spedmon.RmtsMoments.REPT_NUM_REVIEWS %>;
                   // enters the first IF in the ASHX file.
                   // queries by fyID and quarterNUM, not quarterID.

        opts.enableReports = true;
        opts.enableReportHtml = true;
        opts.enableReportXls = true;
        opts.enableReportPdf = false;
        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id',
            isRecID: true,
            saveable: false,
            saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
            name: 'Quarter',
            label: 'Quarter',
            toolTip: 'Quarter',
            visible: true,
            editable: false,
            saveable: false,
            sortable: true,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'Quarter'
        });

        <%if (showClientName) { %>
          opts.fieldDefinitions.push({
              name: 'clientName',
              label: 'LEA',
              toolTip: 'LEA',
              visible: true,
              editable: false,
              saveable: false,
              sortable: true,
              isRecID: false,
              dataType: 'text',
              saveUsing: '',
              sortUsing: 'clientName'
          });
        <%}%>

        opts.fieldDefinitions.push({
            name: 'LastName',
            label: 'Last<br/>Name',
            toolTip: 'Last Name',
            visible: true,
            editable: false,
            saveable: false,
            sortable: true,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'LastName'
        });

        opts.fieldDefinitions.push({
            name: 'FirstName',
            label: 'First<br/>Name',
            toolTip: 'First Name',
            visible: true,
            editable: false,
            saveable: false,
            sortable: true,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'FirstName'
        });

/*
        opts.fieldDefinitions.push({
            name: 'JobTitle',
            label: 'Job<br/>Title',
            toolTip: 'Job Title',
            visible: true,
            editable: false,
            saveable: false,
            sortable: true,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'JobTitle'
        });
*/
        opts.fieldDefinitions.push({
            name: 'JobClassification',
            label: 'Job</br>Classification',
            toolTip: 'Job Classification',
            visible: true,
            editable: false,
            saveable: false,
            sortable: true,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'JobClassification'
        });

        opts.fieldDefinitions.push({
            name: 'momentDatetime',
            label: 'Sampled</br>Moment',
            toolTip: 'Sampled Moment',
            visible: true,
            editable: false,
            saveable: false,
            sortable: true,
            isRecID: false,
            dataType: 'date',
            saveUsing: '',
            sortUsing: 'momentDatetime'
        });

        opts.fieldDefinitions.push({
            name: 'WhoWereYouWith',
            label: 'Who Were</br>You With?',
            toolTip: 'Who Were You With?',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'WhoWereYouWith'
        });

        opts.fieldDefinitions.push({
            name: 'WhatWereYouDoing',
            label: 'What Were</br>You Doing?',
            toolTip: 'What Were You Doing?',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'WhatWereYouDoing'
        });

        opts.fieldDefinitions.push({
            name: 'WhyWereYouPerformingThisActivity',
            label: 'Why Were You</br>Performing This</br>Activity?',
            toolTip: 'Why Were You Performing This Activity?',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'WhyWereYouPerformingThisActivity'
        });

        opts.fieldDefinitions.push({
            name: 'ActivityCode',
            label: 'Activity<br/>Code',
            toolTip: 'Activity Code',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'ActivityCode'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Suggested Activity Code %>
        <%//-----------------------------------------------------------------------------%>

/*
        let suggestedActivityCodeOptions = {};

        suggestedActivityCodeOptions.selections = [
              { name: '2A', value: '2A' }
            , { name: '2Z', value: '2Z' }
            , { name: '8',  value: '8' }
        ];
*/
        opts.fieldDefinitions.push({
              name: 'pcalReviewSuggestedActivityCode'
            , label: 'Suggested<br/>Activity<br/>Code'
            , toolTip: ''
            , visible: true
            , sortable: true
            , editable: false
            , saveable: true
            , isRecID: false
            , dataType: 'text'
            //, dataType: 'selectoption'
            //, dataTypeOptions: suggestedActivityCodeOptions
            , sortUsing: ''
            , saveUsing: 'pcalReviewSuggestedActivityCode'
            , showMore: false
            , handlerFn: function (uiActionObj) {
                //clearServiceSelection(uiActionObj);
                return uiActionObj;
            }
        });

        opts.fieldDefinitions.push({
            name: 'pcalReviewReason'
            , label: 'Reason For<br>Action Taken'
            , toolTip: 'Reason For Action Taken'
            , visible: true
            , sortable: true
            , editable: false
            , saveable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: ''
            , saveUsing: 'pcalReviewReason'
            , showMore: false
            , handlerFn: function (uiActionObj) {
                //clearServiceSelection(uiActionObj);
                return uiActionObj;
            }
        });

        opts.fieldDefinitions.push({
            name: 'pcalReviewNotes'
            , label: 'Additional<br>Review Notes'
            , toolTip: 'Additional Review Notes'
            , visible: true
            , sortable: true
            , editable: false
            , saveable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: ''
            , saveUsing: 'pcalReviewNotes'
            , showMore: false
            , handlerFn: function (uiActionObj) {
                //clearServiceSelection(uiActionObj);
                return uiActionObj;
            }
        });
        opts.fieldDefinitions.push({
            name: 'SMAACode16AuditRequired',
            label: 'SMAA Code16</br>Audit Required?',
            toolTip: 'SMAA Code16 Audi tRequired?',
            visible: false,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',

            //showMore: true,

            sortUsing: 'SMAACode16AuditRequired'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'pcalReviewStatusName',
            label: 'Review Status',
            toolTip: 'Review Status',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'pcalReviewStatusName'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'RelatedToStudentAssessmentIEP_IFSP_CarePlan',
            label: 'Related To<br/>StudentAssessment<br/>IEP IFSP<br/>Care Plan?',
            toolTip: 'Related To StudentAssessment IEP IFSP Care Plan?',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'RelatedToStudentAssessmentIEP_IFSP_CarePlan'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'ClarifyingQuestion1',
            label: 'Clarifying<br/>Question 1',
            toolTip: 'Clarifying Question 1',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'ClarifyingQuestion1'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'ClarifyingQuestionAnswer1',
            label: 'Answer',
            toolTip: 'Clarifying Answer 1',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'ClarifyingQuestionAnswer1'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'ClarifyingQuestion2',
            label: 'Clarifying<br/>Question 2',
            toolTip: 'Clarifying Question 2',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'ClarifyingQuestion2'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'ClarifyingQuestionAnswer2',
            label: 'Answer',
            toolTip: 'Clarifying Answer 2',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'ClarifyingQuestionAnswer2'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'CodingComments',
            label: 'Coding<br/>Comments',
            toolTip: 'Coding Comments',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'CodingComments'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'LEABOPCode2AAuditRequired',
            label: 'LEA BOP</br>Code2A</br>Audit Required?',
            toolTip: 'LEA BOP Code2A Audit Required?',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'LEABOPCode2AAuditRequired'
        });

        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.additionalControlDefinitionsForBodyRows.set('thumbupRec', {
            defType: 'userprovided'
            , name: 'thumbupRec'
            , toolTip: 'This Activity Code is OK'
            , cssClass: 'mba-rest-view fas fa-thumbs-up'
            , handlerFn: function (uiActionObj) {

                //openDiaReviewDetails(uiActionObj, true);
                rmtsReviewSave(uiActionObj, true);
                return uiActionObj;

            }
            , initiallyHidden: false
        });



        opts.additionalControlDefinitionsForBodyRows.set('thumbdownRec', {
            defType: 'userprovided'
            , name: 'thumbdownRec'
            , toolTip: 'Possible Appeal'
            , cssClass: 'mba-rest-view fas fa-thumbs-down'
            , handlerFn: function (uiActionObj) {
                openDiaReviewDetails(uiActionObj, false);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        //opts.additionalControlDefinitionsForBodyRows = new Map();
        //opts.rowCtrlDefs = [];


        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            if (!rowData) return $newRow;
            let ctrlRefThumbUp = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="thumbupRec"]');
            let ctrlRefThumbDown = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="thumbdownRec"]');
            if (rowData.pcalReviewStatusCode === 200) { $(ctrlRefThumbUp).remove(); }
            if (rowData.pcalReviewStatusCode === 300) { $(ctrlRefThumbDown).remove(); }
            return $newRow;
        };

        $($restViewCtrlRmtsMoments).MBA_RestView(opts);

    }


    $(document).ready(function () {
        $dataManagementRows        = $('#dataManagementRows');
        $restViewCtrlRmtsMoments   = $('#restViewRmtsMoments');
        $diaReviewDetails          = $('#diaReviewDetails');
        $suggestedActivityCodeCont = $('#suggestedActivityCodeCont');
        $suggestedActivityCode     = $('#suggestedActivityCode');
        $reviewReason              = $('#reviewReason');
        $reviewNotes               = $('#reviewNotes');
        $restViewCtrlSvcRecs       = $('#restViewServiceRecs');

        initDiaReviewDetails();
        initViewMomentsReq();

        //debugger;

        $($dataManagementRows).on('spedmoninputdata', function (e) {

            //debugger;

            updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMoments(e);

        });

        $($suggestedActivityCode).on('change', function (e) {

            let whatDataListToUse = '';
            let whatActivityCodeSelected = ($suggestedActivityCode).val();

            if      (whatActivityCodeSelected == '2A') { whatDataListToUse = '<%=dataListIDForChangeReasonsCode2A%>'; }
            else if (whatActivityCodeSelected == '2Z') { whatDataListToUse = '<%=dataListIDForChangeReasonsCode2Z%>'; }
            else if (whatActivityCodeSelected == '8')  { whatDataListToUse = '<%=dataListIDForChangeReasonsCode8%>'; }
            else    { whatDataListToUse = ''};

            $($reviewReason).MBA_DataEntryBox('setListAssignment', whatDataListToUse);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMoments(null);


    });
</script>
