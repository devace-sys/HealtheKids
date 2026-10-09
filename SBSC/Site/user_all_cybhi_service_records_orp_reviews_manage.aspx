<%@ Page Language="C#" CodeBehind="user_all_cybhi_service_records_orp_reviews_manage.aspx.cs" Inherits="Spedmon.UserAllCybhiServiceRecordsOrpReviewsManage" %>

<%//##################################################################################################################%>
<%//#                                         Markup   %>
<%//##################################################################################################################%>

<%//-----------------------------------------------------------------------------%>
<%// Define dialog for approving with notes %>
<%//-----------------------------------------------------------------------------%>

<div id="diaApproveWithNotes" title="Approve With Notes?">
    <div class="d-flex flex-column">
    <Spedmon:DataEntryBoxTextArea ID="reviewNotesApprove" name="reviewNotesApproval" label="Review Notes" required="true" size="25" runat="server"/>
    <label class="align-middle" for="sendReviewNotesToRenderingPrac">Check Here to Share Notes with Rendering Provider <input class="ml-1 align-middle" id="sendReviewNotesToRenderingPrac" name="sendReviewNotesToRenderingPrac" type="checkbox"/></label>
    </div>
</div>

<%//-----------------------------------------------------------------------------%>
<%// Define dialog for returning for corrections %>
<%//-----------------------------------------------------------------------------%>

<div id="diaReturnForCorrection" title="Return For Corrections?">
    <p>You have opted to return this service record for clarification or questions.  Please explain in the review notes what corrections need to be made. The rendering practitioner will receive a notification that the service record has been returned for correction.</p>
    <Spedmon:DataEntryBoxTextArea ID="reviewNotesCorrection" name="reviewNotesCorrection" label="Review Notes" required="true" size="25" runat="server"/>
</div>

<%//-----------------------------------------------------------------------------%>
<%// Data Management Rows %>
<%//-----------------------------------------------------------------------------%>

<div id="datamanagementrows" class="container-fluid">

<div class="row">

<div class="col-6">

<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectClient
  ID                    = "selectClient"
  rowLabel              = "Client?"
  dataEntryRowRenderAs  = "FIELD"
  showClearSelection    = "true"
  runat                 = "server">
</Spedmon:DataEntryRowSelectClient>

</div> <!-- col -->

<div class="col-6">

<%//-----------------------------------------------------------------------------%>
<%// Select Reviewing Practitioner %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPractitioner
     ID                   = "selectReviewingPrac"
     rowLabel             = "Reviewing Practitioner?"
     dataEntryRowRenderAs = "FIELD"
     entityControlID      = "reviewingpracid"
     entityParamName      = "reviewingpracid"
     showClearSelection   = "true"
     runat                = "server" />

</div> <!-- col -->

</div> <!-- row -->

<div class="row">

<%//-----------------------------------------------------------------------------%>
<%// Site %>
<%//-----------------------------------------------------------------------------%>

<div class="col-4">
  <Spedmon:DataEntryRowSelectSchoolSite ID="selectSite" rowLabel="Site?" dataEntryRowRenderAs="FIELD" showClearSelection="true" runat="server" />
</div>

<%//-----------------------------------------------------------------------------%>
<%// Approval Status %>
<%//-----------------------------------------------------------------------------%>

<div class="col-4">
<div class="d-flex justify-content-start">
<Spedmon:RadioBox ID="approvalstatus" name="approvalstatus" title="Show" renderLabel="true" additionalCssClassNameForContainer="modern2021" runat="server" />
<Spedmon:HiddenInput ID="approved" name="approved" title="Approved" runat="server" />
<Spedmon:HiddenInput ID="reviewed" name="reviewed" title="Reviewed" runat="server" />
</div>
</div> <!-- col -->

<%//-----------------------------------------------------------------------------%>
<%// Entry Date Range %>
<%//-----------------------------------------------------------------------------%>

<div class="col-4">
<div class="d-flex justify-content-start">
  <span class="mr-2">Show Services Recorded Between:</span>
  <Spedmon:DateBoxRange id="daterange" name="daterange" title="Entry Date Range" showOK="false" runat="server" />
</div>
</div> <!-- col -->

</div> <!-- row -->


<div class="row mt-3">

<%//-----------------------------------------------------------------------------%>
<%// Rest View %>
<%//-----------------------------------------------------------------------------%>

<div class="col-12">
<div id="restview">
</div>

<%//-----------------------------------------------------------------------------%>
<%// Hidden filter fields (for details view)%>
<%//-----------------------------------------------------------------------------%>

<Spedmon:HiddenInput ID="renderingpracid" name="renderingpracid" title="renderingpracid" runat="server" />
<Spedmon:HiddenInput ID="patid" name="patid" title="patid" runat="server" />

</div> <!-- col -->
</div> <!--row -->

</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    let $dataManagementRows = null;
    let $restViewCtrl = null;
    let $diaApproveAll = null;
    let $diaApproveWithNotes = null;
    let $reviewNotesApprove = null;
    let $sendReviewNotesToRenderingPrac = null;
    let $diaReturnForCorrection = null;
    let $reviewNotesCorrection = null;
    let $ctrlApproveAllRecs = null;
    let canShowApproveAll = true;

<%/*-----------------------------------------------------------------------------------------*/%>

    const PARM_NAME_CLIENT_ID = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_REVIEWING_PRAC_ID = '<%=Constants.PARM_REVIEWING_PRAC_ID%>';
    const PARM_NAME_RENDERING_PRAC_ID = '<%=Constants.PARM_RENDERING_PRAC_ID%>';
    const PARM_NAME_SITE_ID = '<%=Constants.PARM_SITE_ID%>';
    const PARM_NAME_PAT_ID = '<%=Constants.PARM_PATIENT_ID%>';
    const PARM_NAME_DATE_RANGE = '<%=Constants.PARM_DATE_RANGE%>';
    const PARM_NAME_REVIEW_REC_ID = '<%=Constants.PARM_REVIEW_REC_ID%>';
    const PARM_NAME_REVIEW_REC_IDS = '<%=Constants.PARM_REVIEW_REC_IDS%>';
    const PARM_NAME_REVIEWED = '<%=Constants.PARM_REVIEWED%>';
    const PARM_NAME_APPROVED = '<%=Constants.PARM_APPROVED%>';
const PARM_NAME_APPROVAL_STATUS          = '<%=Constants.PARM_APPROVAL_STATUS%>';

const PARM_NAME_DETAILS_ENTRY_MODE       = '<%=Spedmon.Constants.PARM_PRAC_SUP_DETAILS_ENTRY_MODE%>';

const PARM_VALUE_DETAILS_ENTRY_MODE_PRAC = <%=Spedmon.Constants.PRAC_SUP_DETAILS_ENTRY_MODE_PRAC%>;
const PARM_VALUE_DETAILS_ENTRY_MODE_PAT  = <%=Spedmon.Constants.PRAC_SUP_DETAILS_ENTRY_MODE_PAT%>;

<%/*-----------------------------------------------------------------------------------------*/%>

    function getApprovalStatusVal() {
        return $('#' + PARM_NAME_APPROVAL_STATUS).val();
    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function determineReviewedAndApprovedFlagValues() {
        let approvalStatusVal = getApprovalStatusVal();
        let reviewedVal = '0';
        let approvedVal = '';
        switch (approvalStatusVal) {
            case "1":
                reviewedVal = '0';
                approvedVal = '';
                break;
            case "2":
                reviewedVal = '1';
                approvedVal = '1';
                break;
            case "3":
                reviewedVal = '1';
                approvedVal = '0';
                break;
            default:
                reviewedVal = '0';
                approvedVal = '';
                break;
        }

        $('#' + PARM_NAME_REVIEWED).val(reviewedVal);
        $('#' + PARM_NAME_APPROVED).val(approvedVal);
    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function createCommonReqObjForApproveOrReject () {
        var reqObj = {};
        reqObj[PARM_NAME_CLIENT_ID]         = $('#' + PARM_NAME_CLIENT_ID).val();
        reqObj[PARM_NAME_REVIEWING_PRAC_ID] = $('#' + PARM_NAME_REVIEWING_PRAC_ID).val();
        return reqObj;
    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function createCommonReqObjForApproveOrRejectRows() {
        var reqObj = createCommonReqObjForApproveOrReject();
        reqObj[PARM_NAME_REVIEW_REC_IDS] = $($restViewCtrl).MBA_RestView("getCurrentRenderedRowsRecordIDsAsCsvStr");
        return reqObj;
    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function createCommonReqObjForApproveOrRejectRow(uiActionObj) {
        var reqObj = createCommonReqObjForApproveOrReject();
        reqObj[PARM_NAME_REVIEW_REC_ID]  = '' + uiActionObj.recordID;
        return reqObj;
    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function generateNvpSiteID() {
        let VALUE_SITE_ID = $('#' + PARM_NAME_SITE_ID).val();
        return MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SITE_ID, VALUE_SITE_ID);
    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function generateNvpDateRange() {
        let VALUE_DATE_RANGE = $('#' + PARM_NAME_DATE_RANGE).val();
        return MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_DATE_RANGE, VALUE_DATE_RANGE);
    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function generateNvpApprovalStatus() {
        let VALUE_APPROVAL_STATUS = getApprovalStatusVal();
        return MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_APPROVAL_STATUS, VALUE_APPROVAL_STATUS);
    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        determineReviewedAndApprovedFlagValues();

        let VALUE_CLIENT_ID         = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_REVIEWING_PRAC_ID = $('#' + PARM_NAME_REVIEWING_PRAC_ID).val();
        let VALUE_RENDERING_PRAC_ID = $('#' + PARM_NAME_RENDERING_PRAC_ID).val();
        let VALUE_PAT_ID            = $('#' + PARM_NAME_PAT_ID).val();
        let VALUE_REVIEWED          = $('#' + PARM_NAME_REVIEWED).val();
        let VALUE_APPROVED          = $('#' + PARM_NAME_APPROVED).val();

        let NV_CLIENT_ID         = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID,         VALUE_CLIENT_ID);
        let NV_REVIEWING_PRAC_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_REVIEWING_PRAC_ID, VALUE_REVIEWING_PRAC_ID);
        let NV_RENDERING_PRAC_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_RENDERING_PRAC_ID, VALUE_RENDERING_PRAC_ID);
        let NV_PAT_ID            = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID, VALUE_PAT_ID);
        let NV_REVIEWED          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_REVIEWED,          VALUE_REVIEWED);
        let NV_APPROVED          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_APPROVED,          VALUE_APPROVED);

        let NV_SITE_ID           = generateNvpSiteID();
        let NV_DATE_RANGE        = generateNvpDateRange();

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SITE_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_REVIEWING_PRAC_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_RENDERING_PRAC_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DATE_RANGE);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_REVIEWED);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_APPROVED);

        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function saveApprove(uiActionObj) {

        var reqUrl  = '<%=Spedmon.CybhiServiceRecordsOrpReviews.URL_SVC_ACCEPT()%>';
        var reqObj  = createCommonReqObjForApproveOrRejectRow(uiActionObj);
        let reqJSON = JSON.stringify(reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, '<%=MBA.Credential.generateSessionExpiredLink()%>')
            .then(responseData => {
                updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Approve', err.message, {});
            });
    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function saveApproveAll() {

        var reqUrl = '<%=Spedmon.CybhiServiceRecordsOrpReviews.URL_SVC_ACCEPT_MULTI()%>';
        var reqObj = createCommonReqObjForApproveOrRejectRows();

        let reqJSON = JSON.stringify(reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, '<%=MBA.Credential.generateSessionExpiredLink()%>')
            .then(responseData => {
                $($diaApproveAll).dialog('close');
                updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
            })
            .catch(err => {
                $($diaApproveAll).dialog('close');
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Approve All', err.message, {});
            });
    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function openApproveAllDia() {

        $($diaApproveAll).dialog('destroy');
        $diaApproveAll = null;

        let _fnOnProceed = function () { saveApproveAll(); };

        $diaApproveAll = MBA.ComponentCommon.fnCreateOneTimeProceedOrCancelDialog('Approve All Service Records?'
            , 'Please confirm that you wish to approve all service records currently shown.'
            , null /*options*/
            , _fnOnProceed
            , null /* fnOnCancel */
            , true /* closeOnProceed*/
            , true /* closeOnCancel */);
    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function initDiaApproveWithNotes() {
        $($diaApproveWithNotes).dialog('destroy');
        $($diaApproveWithNotes).hide();
        $($reviewNotesApprove).MBA_DataEntryBox('clearValue');
        MBA.ComponentCommon.fnSetCheckBoxState($sendReviewNotesToRenderingPrac, 0);
};

<%/*-----------------------------------------------------------------------------------------*/%>

    function initDiaReturnForCorrection() {
        $($diaReturnForCorrection).dialog('destroy');
        $($diaReturnForCorrection).hide();
        $($reviewNotesCorrection).MBA_DataEntryBox('clearValue');
};

<%/*-----------------------------------------------------------------------------------------*/%>

    function saveApproveWithNotes(uiActionObj) {

        var reqUrl = '<%=Spedmon.CybhiServiceRecordsOrpReviews.URL_SVC_ACCEPT_WITH_NOTES()%>';
        var reqObj = createCommonReqObjForApproveOrRejectRow(uiActionObj);
        reqObj.notes = $($reviewNotesApprove).val();
        reqObj.sendreviewnotestorenderingprac = MBA.ComponentCommon.fnGetCheckBoxState($sendReviewNotesToRenderingPrac);

        let reqJSON = JSON.stringify(reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, '<%=MBA.Credential.generateSessionExpiredLink()%>')
            .then(responseData => {
                $($diaApproveWithNotes).dialog('close');
                updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
                initDiaApproveWithNotes();
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Approve', err.message, {});
            });

    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function openApproveWithNotesDialog(uiActionObj) {

        initDiaApproveWithNotes();
        $($diaApproveWithNotes).show();

        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(50);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(50);

        let diaOpts = {
            position: { my: 'center', at: 'center', of: window }
            , show: { effect: 'slide', direction: 'left' }
            , modal: true
            , closeOnEscape: false
            , width: (vw)
            , height: (vh)
            , close: function (event, ui) {
                initDiaApproveWithNotes();
            }
            , buttons: [
                { text: "Cancel", click: function () { $($diaApproveWithNotes).dialog('close'); } }
                , {
                    text: "Proceed", click: function () {
                        saveApproveWithNotes(uiActionObj);
                    }
                }
            ]
        };

        $($diaApproveWithNotes).dialog(diaOpts);

    };


<%/*-----------------------------------------------------------------------------------------*/%>

    function saveReturnForCorrection(uiActionObj) {

        var reqUrl = '<%=Spedmon.CybhiServiceRecordsOrpReviews.URL_SVC_REJECT()%>';
        var reqObj = createCommonReqObjForApproveOrRejectRow(uiActionObj);
        reqObj.notes = $($reviewNotesCorrection).val();

        let reqJSON = JSON.stringify(reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, null)
            .then(responseData => {
                $($diaReturnForCorrection).dialog('close');
                updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
                initDiaReturnForCorrection();
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Return For Correction', err.message, {});
            });
    };

<%/*-----------------------------------------------------------------------------------------*/%>

    function openReturnForCorrectionDialog(uiActionObj) {

        initDiaReturnForCorrection();
        $($diaReturnForCorrection).show();

        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(50);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(50);

        let diaOpts = {
            position: { my: 'center', at: 'center', of: window }
            , show: { effect: 'slide', direction: 'left' }
            , modal: true
            , closeOnEscape: false
            , width: (vw)
            , height: (vh)
            , close: function (event, ui) {
                initDiaReturnForCorrection();
            }
            , buttons: [
                { text: "Cancel", click: function () { $($diaReturnForCorrection).dialog('close'); } }
                , {
                    text: "Proceed", click: function () {
                        saveReturnForCorrection(uiActionObj);
                    }
                }
            ]
        };

        $($diaReturnForCorrection).dialog(diaOpts);

    };

<%/*-----------------------------------------------------------------------------------------*/%>


function initView() {

  let opts = {};

  <%if (inDetailsEntryMode == true) {%>
  opts.showCaption = true;
  opts.caption     = '<%=detailsEntryModeLabel%>';
  <%}%>

  opts.sessionTimeOutUrl           = '<%=MBA.Credential.generateSessionExpiredLink()%>';
  opts.requestViewOnLoad           = false; /*This is so we can set the initial filters */
  opts.enableSortControls          = true;
  opts.enableRowNumbers            = true;
  opts.enableRowControls           = true;
  opts.enableRowControlRecAddNew   = false;
  opts.enableRowControlRecEdit     = false;
  opts.enableRowControlRecDelete   = false;
  opts.enableRowControlRecUnDelete = false;
  opts.autoShowHideDeleteUnDelete  = false;

  opts.enableRowControlShowAdditionalInfo = true;

  opts.loadModeView             = 'rest';
  opts.baseUrlView              = '<%=Spedmon.CybhiServiceRecordsOrpReviews.URL_REST_VIEW()%>';
  opts.baseUrlViewHasParameters = true;
  opts.defaultPageRowOrder      = '<%=Spedmon.CybhiServiceRecordsOrpReview.DEFAULT_PAGING_ORDER%>';

  opts.enableReports = false;

  opts.fieldDefinitions = [];

  opts.fieldDefinitions.push({
        name: 'id'
      , isRecID: true
      , saveable: true
      , saveUsing:'recid'
  });

  opts.fieldDefinitions.push({
        name: 'siteName'
        , label: 'School<br>Site'
        , toolTip: 'Site Name'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: 'siteName'
    });

  opts.fieldDefinitions.push({
        name: 'assignedOnStr'
        , label: 'Entered<br>On'
        , toolTip: 'Service record entered on'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: 'assignedOn'
  });

  <%if (showRenderingPracCol == true) { %>
  opts.fieldDefinitions.push({
         name: 'renderingPracName'
        , label: 'Rendering<br>Practitioner'
        , toolTip: 'Service provided by'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: 'renderingPracName'
    });
    <%}%>

    <%if(showPatCol == true) {%>
    opts.fieldDefinitions.push({
        name: 'patName'
        , label: 'Patient<br>Name'
        , toolTip: 'Service provided for'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: 'patName'
    });
    <%}%>

    opts.fieldDefinitions.push({
        name: 'dosStr'
        , label: 'Date Of<br>Service'
        , toolTip: 'Service rendered on'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: 'dos'
    });

    opts.fieldDefinitions.push({
          name: 'svcName'
        , label: 'Service<br>Name'
        , toolTip: 'Service name'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: 'svcName'
    });

    opts.fieldDefinitions.push({
        name: 'numMins'
        , label: 'Minutes'
        , toolTip: 'Number of Minutes'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: 'numMins'
    });

    opts.fieldDefinitions.push({
        name: 'attendanceSelectionName'
        , label: 'Attendance<br>Status'
        , toolTip: 'Attendance status'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: 'attendanceSelectionName'
    });

    opts.fieldDefinitions.push({
        name: 'svcNotes'
        , label: 'Service<br>Notes'
        , toolTip: 'Service Record Notes (Private Notes Are NOT Included)'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'pre'
        , saveUsing: ''
        , sortUsing: ''
    });

    /* Setup additional info controls */

    opts.additionalInfoFieldDefinitions = [];

    opts.additionalInfoFieldDefinitions.push({
        name: 'svcRecID'
        , label: 'Service Record ID'
        , toolTip: 'SpEdCare Service Record ID'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: ''
    });

    

    opts.additionalInfoFieldDefinitions.push({
        name: 'assignedPracName'
        , label: 'Reviewing Practitioner'
        , toolTip: 'Practitioner assigned to review'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: ''
    });

    opts.additionalInfoFieldDefinitions.push({
        name: 'reviewedStr'
        , label: 'Reviewed?'
        , toolTip: 'Reviewed?'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: ''
    });

    opts.additionalInfoFieldDefinitions.push({
        name: 'reviewedOnStr'
        , label: 'Reviewed On'
        , toolTip: 'Reviewed On'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: ''
    });

    opts.additionalInfoFieldDefinitions.push({
        name: 'approvedStr'
        , label: 'Approved'
        , toolTip: 'Approved?'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'string'
        , saveUsing: ''
        , sortUsing: ''
    });

    opts.additionalInfoFieldDefinitions.push({
        name: 'notes'
        , label: 'Review Notes'
        , toolTip: 'Review notes'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: false
        , isRecID: false
        , dataType: 'pre'
        , saveUsing: ''
        , sortUsing: ''
    });

    /* Setup additional controls for head */

    opts.additionalControlDefinitionsForHeadRows = new Map();

    opts.additionalControlDefinitionsForHeadRows.set('approveAllRecs', {
          defType: 'userprovided'
        , name: 'approveAllRecs'
        , toolTip: 'Click Here to Approve all Services Listed'
        , cssClass: 'fas fa-thumbs-up'
        , handlerFn: function (uiActionObj) {
             openApproveAllDia();
             return uiActionObj;
          }
        , initiallyHidden: false
    });


    /* Setup additional row controls */

    opts.additionalControlDefinitionsForBodyRows = new Map();

    /* Approve Record */

    opts.additionalControlDefinitionsForBodyRows.set('approveRec', {
        defType: 'userprovided'
        , name: 'approveRec'
        , toolTip: 'Approve Record Without Notes'
        , cssClass: 'fas fa-thumbs-up'
        , handlerFn: function (uiActionObj) {
            saveApprove(uiActionObj);
            return uiActionObj;
          }
        , initiallyHidden: false
        });

    /* Approve record with notes */

    opts.additionalControlDefinitionsForBodyRows.set('approveRecWithNotes', {
        defType: 'userprovided'
        , name: 'approveRecWithNotes'
        , toolTip: 'Approve Record With Notes'
        , cssClass: 'fas fa-thumbs-up text-info'
        , handlerFn: function (uiActionObj) {
            openApproveWithNotesDialog(uiActionObj);
            return uiActionObj;
        }
        , initiallyHidden: false
    });

    /* Reject  */

    opts.additionalControlDefinitionsForBodyRows.set('rejectRec', {
        defType: 'userprovided'
        , name: 'rejectRec'
        , toolTip: 'Return Record for Correction'
        , cssClass: 'fas fa-thumbs-down'
        , handlerFn: function (uiActionObj) {
            openReturnForCorrectionDialog(uiActionObj);
            return uiActionObj;
        }
        , initiallyHidden: false
    });


    opts.fnCreateNewCellAfter = function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {

      let _fnGenerateFilterDown = function (detailsEntryMode) {

         let newWindowName = 'svc-rec-cybhi-orp-rvw-cid-'
                               + rowData.clientID
                               + '-rvwprc-'
                               + rowData.assignedToPracID;
          let parms = [];

          let NV_SITE_ID         = generateNvpSiteID();
          let NV_DATE_RANGE      = generateNvpDateRange();
          let NV_APPROVAL_STATUS = generateNvpApprovalStatus();

          parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID,          rowData.clientID));
          parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_REVIEWING_PRAC_ID,  rowData.assignedToPracID));
          parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_DETAILS_ENTRY_MODE, detailsEntryMode));
          parms.push(NV_SITE_ID);
          parms.push(NV_DATE_RANGE);
          parms.push(NV_APPROVAL_STATUS);

          if (detailsEntryMode === PARM_VALUE_DETAILS_ENTRY_MODE_PRAC) {
              parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_RENDERING_PRAC_ID, rowData.renderingPracID));
              $($newCellValue).attr('title', 'Click to review services rendered by this practitioner only');
              newWindowName = newWindowName
                            + '-rdrprc-'
                            + rowData.renderingPracID;
          }

          else if (detailsEntryMode === PARM_VALUE_DETAILS_ENTRY_MODE_PAT) {
              parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID, rowData.patID));
              $($newCellValue).attr('title', 'Click to review services provided to this patient only');
              newWindowName = newWindowName
                            + '-pap-'
                            + rowData.patID;
          }
          else {

          }

          $($newCellValue).wrap('<a href="#" class="mba-rest-view-drill-down"></a>');
          $($newCellValue).append($('<i class="fas fa-link fa-sm ml-1"></i>'));
          $($newCellValue).closest('a').on('click', function () {
          let reqUrl = MBA.ComponentCommon.fnBuildUrl('<%=Spedmon.CybhiServiceRecordsOrpReviews.URL_MANAGE(true)%>', true, parms);
          $($restViewCtrl).MBA_RestView("openWindow", { url: reqUrl, windowName: newWindowName, refreshView: true });
        });

      };

        if ((subsection === 103) && (rowtype === 4)) {

            if (fieldDefinition.name === 'renderingPracName') {
                let $groupName = $('<sup>' + rowData.renderingGroupName + '</sup>');
                <%if(inDetailsEntryMode == false) {%>_fnGenerateFilterDown(PARM_VALUE_DETAILS_ENTRY_MODE_PRAC);<%}%>
                $($newCellValue).append($('<br>'));
                $($newCellValue).append($groupName);
            }

            else if (fieldDefinition.name === 'patName') {
               <%if(inDetailsEntryMode == false) {%> _fnGenerateFilterDown(PARM_VALUE_DETAILS_ENTRY_MODE_PAT);<%}%>
                let $ssid = $('<sup title="SSID">' + rowData.ssid + '</sup>');
                $($newCellValue).append($('<br>'));
                $($newCellValue).append($ssid);

            }

        }
        return $newCell;

    };

    opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

        if (!rowData) return $newRow; /* Quickest way to skip header rows*/

        /* If row is reviewed then we want to remove some controls */

        if (rowData.reviewed === true) {

            canShowApproveAll = false;

            $(MBA.RestViewCommon.fnFindRowControl($newRow, 'approveRec')).remove();

            if (rowData.approved === false) {
                $(MBA.RestViewCommon.fnFindRowControl($newRow, 'rejectRec')).remove();
            }
        }
        return $newRow;
    };

    opts.fnBeforeDrawTableBodyRows = function (elem, returnData, $me, dataObj) {

        $ctrlApproveAllRecs = $($restViewCtrl).MBA_RestView('findHeaderControl', 'approveAllRecs');

        canShowApproveAll = true;
        MBA.RestViewCommon.fnShowControl($ctrlApproveAllRecs);

        if (dataObj.hasRecords === false) {
            canShowApproveAll = false;
            MBA.RestViewCommon.fnHideControl($ctrlApproveAllRecs);
        }
        return returnData;
    };

    opts.fnOnAfterDrawTableBodyRows = function (elem, $me, dataObj) {

        if (canShowApproveAll === false) {
            MBA.RestViewCommon.fnHideControl($ctrlApproveAllRecs);
        }
    };


    /* Create the rest view */

    $($restViewCtrl).MBA_RestView(opts);

};

<%/*-----------------------------------------------------------------------------------------*/%>

$(document).ready(function () {

  $dataManagementRows             = $('#datamanagementrows');
  $restViewCtrl                   = $('#restview');
  $diaApproveWithNotes            = $('#diaApproveWithNotes');
  $reviewNotesApprove             = $('#reviewNotesApprove');
  $sendReviewNotesToRenderingPrac = $('#sendReviewNotesToRenderingPrac');
  $diaReturnForCorrection         = $('#diaReturnForCorrection');
  $reviewNotesCorrection          = $('#reviewNotesCorrection');

  initDiaApproveWithNotes();
  initDiaReturnForCorrection();
  initView();

  $($dataManagementRows).on('spedmoninputdata', function (e) {
     updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
  });

  updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

});

<%/*-----------------------------------------------------------------------------------------*/%>

</script>
