<%@ Page Language="C#" CodeBehind="user_all_approve_service_records_details.aspx.cs" Inherits="Spedmon.UserAllApproveServiceRecordsDetails" %>

<%//##################################################################################################################%>
<%//#                                            Markup  %>
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
<%// Attest statement %>
<%//-----------------------------------------------------------------------------%>

<p class="mb-2 text-center font-weight-bold">
I have reviewed this/these records of service. I hereby attest by approving that the information in this record entry is accurate and complete to the best of my knowledge.
</p>

<%//-----------------------------------------------------------------------------%>
<%// Data Management Rows %>
<%//-----------------------------------------------------------------------------%>

<div id="dataManagementRows" class="container-fluid">
    
    <div class="row">

    <div class="col">

    <%-----------------------------%>
    <%--    Client Selection     --%>
    <%-----------------------------%>

    <Spedmon:DataEntryRowSelectClient 
        ID       = "selectClient"
        rowLabel = "Who is the Client?"     
        dataEntryRowRenderAs = "FIELD"
        runat    = "server">
    </Spedmon:DataEntryRowSelectClient>
    
    <%-----------------------------%>
    <%--    Prac Selection       --%>
    <%-----------------------------%>
    
    <Spedmon:DataEntryRowSelectPractitioner 
        ID       = "selectPractitioner"
        rowLabel = "Who is the Practitioner?"
        dataEntryRowRenderAs = "FIELD"
        runat    = "server">
    </Spedmon:DataEntryRowSelectPractitioner>
    
    <%-----------------------------%>
    <%--    Site Selection       --%>
    <%-----------------------------%>
    
    <Spedmon:DataEntryRowSelectSchoolSite ID="selectSchoolSite" rowLabel="Site?" dataEntryRowRenderAs="FIELD" showClearSelection="true" runat="server" />

    </div> <!-- col -->
    </div> <!-- row -->

    <%-----------------------------%>
    <%--       Rest view         --%>
    <%-----------------------------%>

    <div id="restViewRow" class="row mt-3">
        <div class="col-12">
            <div id="restView">
            </div>
        </div> <!-- col -->
    </div> <!-- row -->
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    let $dataManagementRows = null;
    let $restViewCtrl = null;
    let $diaApproveWithNotes = null;
    let $reviewNotesApprove = null;
    let $sendReviewNotesToRenderingPrac = null;
    let $diaReturnForCorrection = null;
    let $reviewNotesCorrection = null;

    const PARM_NAME_CLIENT_ID           = 'clientid';
    const PARM_NAME_SITE_ID             = '<%=Constants.PARM_SITE_ID%>';
    const PARM_APPROVING_NAME_PRAC_ID   = 'approvingpracid';
    const PARM_NAME_SVC_REC_ID          = 'svcrecid';
    const PARM_NAME_PRAC_ID             = 'pracid';
    const PARM_NAME_PAT_ID              = 'patid';
    const PARM_NAME_ACTIVE              = 'active';
    
    /**************************************************************************************************************************/

    function initDiaApproveWithNotes() {

        $($diaApproveWithNotes).dialog('destroy');
        $($diaApproveWithNotes).hide();
        $($reviewNotesApprove).MBA_DataEntryBox('clearValue');
        MBA.ComponentCommon.fnSetCheckBoxState($sendReviewNotesToRenderingPrac,0);        
    }

    /**************************************************************************************************************************/

    function initDiaReturnForCorrection() {
        $($diaReturnForCorrection).dialog('destroy');
        $($diaReturnForCorrection).hide();
        $($reviewNotesCorrection).MBA_DataEntryBox('clearValue');
    }

    /**************************************************************************************************************************/

    function saveApproveWithNotes(uiActionObj) {

        let reqUrl             = '<%=MBA.HttpApplication.createLink(Spedmon.ServiceRecordsApproval.URL_ASMX_APPROVE_SVCREC_WITH_NOTES, true)%>';
        let reqObj             = {};
        reqObj.recidmulti      = uiActionObj.recordID;
        reqObj.validaterec     = 0;
        reqObj.approvingpracid = $('#pracid').val();
        reqObj.editDelReason   = $($reviewNotesApprove).val();
        reqObj.sendreviewnotestorenderingprac = MBA.ComponentCommon.fnGetCheckBoxState($sendReviewNotesToRenderingPrac);

        let reqJSON = JSON.stringify(reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, null)
            .then(responseData => {
                $($diaApproveWithNotes).dialog('close');
                updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
                initDiaApproveWithNotes();

            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Approve', err.message, {});
            });
    }

    /**************************************************************************************************************************/

    function openApproveWithNotesDialog(uiActionObj) {

        initDiaApproveWithNotes();
        $($diaApproveWithNotes).show();

        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(60);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(60);

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

      }


    /**************************************************************************************************************************/

    function saveReturnForCorrection(uiActionObj) {

        let reqUrl = '<%=MBA.HttpApplication.createLink(Spedmon.ServiceRecordsApproval.URL_ASMX_REJECT_SVCREC, true)%>';
        let reqObj = {};
        reqObj.recidmulti = uiActionObj.recordID;
        reqObj.validaterec = 0;
        //reqObj.approvingpracid = $('#pracid').val();
        reqObj.editDelReason = $($reviewNotesCorrection).val();

        let reqJSON = JSON.stringify(reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, null)
            .then(responseData => {
                $($diaReturnForCorrection).dialog('close');
                $(uiActionObj.whatElement).find('.svcrec-approve-or-hold-in-journal').removeClass('mba-color-grey');
                updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
                initDiaReturnForCorrection();
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Return For Correction', err.message, {});
            });
    }

    /**************************************************************************************************************************/

    function openReturnForCorrectionDialog(uiActionObj) {

        initDiaReturnForCorrection();
        $($diaReturnForCorrection).show();

        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(60);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(60);

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

    }


      /**************************************************************************************************************************/

      function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID              = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_SITE_ID                = $('#' + PARM_NAME_SITE_ID).val();
        let VALUE_APPROVING_NAME_PRAC_ID = $('#' + 'pracid').val();
        let VALUE_SVC_REC_ID             = '<%=svcRecID%>';
        let VALUE_PRAC_ID                = '<%=pracID%>';
        let VALUE_PAT_ID                 = '<%=patID%>';
        let VALUE_ACTIVE                 = '1';

        let NV_CLIENT_ID         = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_SITE_ID           = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SITE_ID, VALUE_SITE_ID);
        let NV_APPROVING_PRAC_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_APPROVING_NAME_PRAC_ID, VALUE_APPROVING_NAME_PRAC_ID);
        let NV_ACTIVE            = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);
        let NV_SVC_REC_ID        = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SVC_REC_ID, VALUE_SVC_REC_ID);
        let NV_PRAC_ID           = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID, VALUE_PRAC_ID);
        let NV_PAT_ID            = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID, VALUE_PAT_ID);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SITE_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_APPROVING_PRAC_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SVC_REC_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);

        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

    };

    /**************************************************************************************************************************/

    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = false;
        opts.enableRowControlRecDelete = false;

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit               = 'inwindow';
        opts.baseUrlEdit                = '';
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.ServiceRecordsApprovalDetails.URL_REST_VIEW_BY_SVC_REC_ID_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.ServiceRecordsApprovalDetail.DEFAULT_PAGING_ORDER%>';

        opts.enableReports    = false;
        opts.enableReportHtml = false;
        opts.enableReportXls  = false;
        opts.enableReportPdf  = false;

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
              name: 'id'
            , isRecID: true
            , saveable: false
            , saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
              name: 'svcRecID'
            , label: 'Svc Rec ID'
            , toolTip: 'Svc Rec ID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'svcRecID'
        });
        

        opts.fieldDefinitions.push({
              name: 'pracName'
            , label: 'Practitioner Name'
            , toolTip: 'Practitioner Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'pracName'
        });
        
        opts.fieldDefinitions.push({
              name: 'dosStr'
            , label: 'Date Of Service'
            , toolTip: 'Date of Service'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'dosStr'
        });
                
        opts.fieldDefinitions.push({
              name: 'patName'
            , label: 'Patient Name'
            , toolTip: 'Patient Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'patName'
        });
                        
        opts.fieldDefinitions.push({
              name: 'svcName'
            , label: 'Service'
            , toolTip: 'Service Rendered'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'svcName'
        });
                                
        opts.fieldDefinitions.push({
            name: 'siteName'
            , label: 'Site'
            , toolTip: 'Current school site'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'siteName'
        });

        opts.fieldDefinitions.push({
              name: 'planTypeSelectionName'
            , label: 'Plan Type'
            , toolTip: 'Plan Type'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'planTypeSelectionName'
        });
                                        
        opts.fieldDefinitions.push({
              name: 'startTimeStr'
            , label: 'Start Time'
            , toolTip: 'Start Time'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'startTimeStr'
        });
                                                
        opts.fieldDefinitions.push({
              name: 'endTimeStr'
            , label: 'End Time'
            , toolTip: 'End Time'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'endTimeStr'
        });
                                                        
        opts.fieldDefinitions.push({
              name: 'numMins'
            , label: 'Minutes'
            , toolTip: 'Minutes'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'numMins'
        });
                                                                
        opts.fieldDefinitions.push({
              name: 'notes'
            , label: 'Notes'
            , toolTip: 'Notes'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'pre'
            , saveUsing: ''
            , sortUsing: 'notes'
        });
                                                                        
        opts.fieldDefinitions.push({
              name: 'privateNotes'
            , label: 'Private Notes'
            , toolTip: 'Private Notes'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'pre'
            , saveUsing: ''
            , sortUsing: 'privateNotes'
        });

        /* Setup additional controls for head */

        opts.additionalControlDefinitionsForHeadRows = new Map();

        opts.additionalControlDefinitionsForHeadRows.set('approveallrecs', {
            defType: 'userprovided'
            , name: 'approveallrecs'
            , toolTip: 'Click Here to Approve all Services listed'
            , cssClass: 'fas fa-thumbs-up svcrec-approve-or-hold-in-journal'
            , handlerFn: function (uiActionObj) {

                $.spedmonWebUI.dialogProceedOrGoBack('Approve Record(s)?',
                    'Please confirm you want to approve all service records?',
                    400, 400,
                    function () {
                        let reqUrl = '<%=approveAllBaseURL%>';

                        let VALUE_SITE_ID = $('#' + PARM_NAME_SITE_ID).val();

                        // different reqData based on entryMode
                        let reqData = '';
                        <%if (entryMode == Spedmon.Constants.PRAC_SUP_DETAILS_ENTRY_MODE_SVC_REC.ToString()) {%>
                        let $rowSvcRecApproval = $(uiActionObj.dataObj.tbody).find('tr.mba-rest-view-row')[0];

                        reqData = JSON.stringify({
                              "recidmulti": $($rowSvcRecApproval).attr('data-mba-rest-view-rec-id')
                            , "validaterec": 0
                            , "approvingpracid": $('#pracid').val()
                            , "editDelReason": ""
                        });
                        
                        <%} else {%>
                        reqData = JSON.stringify({
                              "recid"        : '<%=approveAllRecID%>'
                            , "validaterec"  : 0
                            , "editDelReason": ''
                            , "siteid": VALUE_SITE_ID
                            , "daterange": ''
                        });
                        <%}%>
                
                        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                            .then(responseData => {
                                window.close();
                            })
                            .catch(err => {
                                $('#mba-rmts-moments-rendering-icon').remove();
                                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Approve All', err.message, {});
                            });

                },
                function () { });

                return uiActionObj;
            }
            , initiallyHidden: false  
        });

        /* Approve Record */

        opts.additionalControlDefinitionsForBodyRows.set('approveRec', {
            defType: 'userprovided'
            , name: 'approveRec'
            , toolTip: 'Approve Record Without Notes'
            , cssClass: 'fas fa-thumbs-up svcrec-approve-or-hold-in-journal'
            , handlerFn: function (uiActionObj) {

                // send ajax to approve the service reocrd
               
                var reqUrl = '<%=MBA.HttpApplication.createLink(Spedmon.ServiceRecordsApproval.URL_ASMX_APPROVE_SVCREC, true)%>';
                var reqObj = {};
                reqObj.recidmulti      = uiActionObj.recordID;
                reqObj.validaterec     = 0;
                reqObj.approvingpracid = $('#pracid').val();
                reqObj.editDelReason = "";

                var reqData = JSON.stringify(reqObj);

                // make ajax call

                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                    .then(responseData => {
                        $('#restView').MBA_RestView('requestViewFromServer', '1'); // refresh table
                    })
                    .catch(err => {
                       MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Approve', err.message, {});
                    });
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* Approve record with notes */

        opts.additionalControlDefinitionsForBodyRows.set('approveRecWithNotes', {
            defType: 'userprovided'
            , name: 'approveRecWithNotes'
            , toolTip: 'Approve Record With Notes'
            , cssClass: 'fas fa-thumbs-up text-info svcrec-approve-or-hold-in-journal'
            , handlerFn: function (uiActionObj) {
                openApproveWithNotesDialog(uiActionObj);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* Hold Record */

        opts.additionalControlDefinitionsForBodyRows.set('holdRec', {
            defType: 'userprovided'
            , name: 'holdRec'
            , toolTip: 'Return Record for Correction'
            , cssClass: 'fas fa-thumbs-down svcrec-approve-or-hold-in-journal'
            , handlerFn: function (uiActionObj) {
                openReturnForCorrectionDialog(uiActionObj);                
                return uiActionObj;
              }
            , initiallyHidden: false
        });

        opts.fnCreateNewCellAfter = function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {

          if ((subsection === 103) && (rowtype === 4)) {
              if (fieldDefinition.name === 'pracName') {
                  $($newCell).append('<br>');
                  $($newCell).append('<sup>' + rowData.pracGroup + '</sup>');                  
              }                
            }
            return $newCell;
         };


        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }    
    /**************************************************************************************************************************/

    $(document).ready(function () {

        $dataManagementRows             = $('#dataManagementRows');
        $restViewCtrl                   = $('#restView');
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

</script>
