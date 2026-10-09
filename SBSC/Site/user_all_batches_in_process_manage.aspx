<%@ Page Language="C#" CodeBehind="user_all_batches_in_process_manage.aspx.cs" Inherits="Spedmon.userAllBatchesInProcessManage"%>

<Spedmon:HiddenInput id="clientid" title="Client ID" runat="server"></Spedmon:HiddenInput>
<Spedmon:HiddenInput id="batch_status_code" title="Status Code" runat="server"></Spedmon:HiddenInput>
<Spedmon:HiddenInput id="batchid" title="Batch ID" runat="server"></Spedmon:HiddenInput>
<Spedmon:HiddenInput id="worktypeid" title="Work Type ID" runat="server"></Spedmon:HiddenInput>
<Spedmon:HiddenInput id="recuserid" title="Biller (Assigned To)" runat="server"></Spedmon:HiddenInput>

<div id="dataManagementRows" class="container-fluid p-0">  
   
    <%-----------------------------%>
    <%--       Rest view         --%>
    <%-----------------------------%>

    <%-- Bulk Assign Panel --%>
    <div id="bulkAssignPanel" class="row align-items-end mb-2 mt-2">
        <div class="col-auto">
            <Spedmon:ComboBox
                ID          = "bulkAssignUserID"
                name        = "bulkAssignUserID"
                title       = "Assign Selected To"
                dataPrivate = "true"
                dataURL     = "users_pcal.asmx/viewSelInputStaff"
                runat       = "server"
            />
        </div> <!-- col -->
        <div class="col-auto">
            <button type="button" id="bulkAssignBtn" class="btn btn-primary btn-sm">Assign Selected</button>
        </div> <!-- col-->
    </div> <!-- row -->

    <div id="restViewRow" class="row mt-1">
        <div class="col-12">
            <div id="restViewScroll">
                <div id="restView">
                </div>
            </div>
            <div id="restViewStickyScroll">
                <div id="restViewStickyScrollInner"></div>
            </div>
        </div> <!-- col -->
    </div> <!-- row -->

</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    /************************************************************************************************************************* */

    let $dataManagementRows = null;
    let $restViewCtrl = null;

    const PARM_NAME_CLIENT_ID = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_BATCH_STATUS_CODE = '<%=Constants.PARM_BATCH_STATUS_CODE%>';
    const PARM_NAME_REC_USER_ID = 'recuserid';
    const PARM_NAME_BATCH_ID = '<%=Constants.PARM_BATCH_ID%>';
    const PARM_NAME_WORK_TYPE_ID = 'worktypeid';
    const PARM_NAME_BILLER_ID = 'recuserid';

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_BATCH_STATUS_CODE = $('#' + PARM_NAME_BATCH_STATUS_CODE).val();
        let VALUE_BATCH_ID = $('#' + PARM_NAME_BATCH_ID).val();
        let VALUE_WORK_TYPE_ID = $('#' + PARM_NAME_WORK_TYPE_ID).val();

    /* Input staff are always filtered to their own records; all others use the biller filter */
        <% if (uInfo.userRole.ToLower() == Constants.ROLE_INPUT_STAFF) { %>
        let VALUE_REC_USER_ID = '<%=uInfo.userid%>';
        <% } else { %>
        let VALUE_REC_USER_ID = $('#' + PARM_NAME_BILLER_ID).val();
        <% } %>

        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_BATCH_STATUS_CODE = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_BATCH_STATUS_CODE, VALUE_BATCH_STATUS_CODE);
        let NV_REC_USER_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_REC_USER_ID, VALUE_REC_USER_ID);
        let NV_BATCH_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_BATCH_ID, VALUE_BATCH_ID);
        let NV_WORK_TYPE_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_WORK_TYPE_ID, VALUE_WORK_TYPE_ID);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_BATCH_STATUS_CODE);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_REC_USER_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_BATCH_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_WORK_TYPE_ID);

        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);
    };

    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = true;
        opts.enableRowControlRecDelete = true;
        opts.enableRowControlMarkRow = true;

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inline';
        opts.baseUrlEdit = '<%=Spedmon.InputBatchesInProcess.URL_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters = true;

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = '<%=Spedmon.InputBatchesInProcess.URL_DELETE_BASE()%>';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.InputBatchesInProcess.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.InputBatchInProcess.DEFAULT_PAGING_ORDER%>';

        opts.enableReports = true;
        opts.enableReportHtml = true;
        opts.enableReportXls = true;
        opts.enableReportPdf = false;

        opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport = '<%=Spedmon.Clients.URL_WEB_REPORT_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '<%=Spedmon.ClientsRpt.RPT_BATCHES_IN_PROCESS%>';

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
            name: 'clientID'
            , label: 'Client ID'
            , toolTip: 'Client ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'clientid'
            , sortUsing: 'clientID'
        });

        opts.fieldDefinitions.push({
            name: 'clientName'
            , label: 'Client'
            , toolTip: 'Client Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'string'
            , saveUsing: ''
            , sortUsing: 'clientName'
        });

        opts.fieldDefinitions.push({
            name: 'dateSent'
            , label: 'Date Sent'
            , toolTip: 'Date Sent'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'datesent'
            , sortUsing: 'dateSent'
        });

        opts.fieldDefinitions.push({
            name: 'fileLoc'
            , label: 'File Location'
            , toolTip: 'File Location'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'fileloc'
            , sortUsing: 'fileLoc'
        });

        opts.fieldDefinitions.push({
            name: 'partial'
            , label: 'Is Partial'
            , toolTip: 'Is Partial'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'partial'
            , sortUsing: 'partial'
        });

        opts.fieldDefinitions.push({
            name: 'parentID'
            , label: 'Parent ID'
            , toolTip: 'Parent ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'parentid'
            , sortUsing: 'parentID'
        });

        opts.fieldDefinitions.push({
            name: 'userID1'
            , label: 'User ID1'
            , toolTip: 'User ID1'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'userid1'
            , sortUsing: 'userID1'
        });

        opts.fieldDefinitions.push({
            name: 'degOfDiff'
            , label: 'Degree of Difficulity'
            , toolTip: 'Degree of Difficulity'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'degofdiff'
            , sortUsing: 'degOfDiff'
        });

        /*opts.fieldDefinitions.push({
            name: 'id'
            , label: 'Batch ID'
            , toolTip: 'Batch ID'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , saveUsing: ''
            , sortUsing: 'id'
        });
        */

        <%//-----------------------------------------------------------------------------%>
        <%// Current Status Dropdown %>
        <%//-----------------------------------------------------------------------------%>

        <%/* Setup autocomplete - Basics */%>

        let statusOpts = {};
        statusOpts.baseUrl = '<%=Spedmon.InputBatchesStatus.URL_VIEW_SEL_BASE()%>';
        statusOpts.loadMode = 'mbaviewsel';
        statusOpts.getInitialSelectedNameFrom = 'curStatusDescription';

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        statusOpts.fnOnSelect = function (event, ui) { };

        <%/* Setup autocomplete - Customization Hooks  */%>

        statusOpts.fnModifyRequestNvps = function (nvpsIn) { return nvpsIn; };
        statusOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) {
            const hiddenCodes = [80, 90, 130, 200, 250, 290, 300, 310, 320, 330, 340];
            return SelRecs
                .filter(function (r) { return hiddenCodes.indexOf(parseInt(r.id)) === -1; })
                .map(function (r) {
                    if (r.value && r.value.toLowerCase().indexOf('prescreen') !== -1) r.value = 'Pending';
                    if (r.value && r.value.toLowerCase().indexOf('nb filed') !== -1) r.value = 'Not Billable';
                    return r;
                });
        };
        statusOpts.fnModifyRenderItem = function ($ul, item, $li) {
            var ctxt1 = $('<br><sup>' + item.recData2 + '</sup>');
            $($li).children('a').append(ctxt1);
            return $li;
        };
        statusOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'curStatusCode'
            , label: 'Current<br />Status'
            , toolTip: 'Current Status'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , saveUsing: 'statuscode'
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: statusOpts
            , sortUsing: 'curStatusCode'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'dateReceivedStr'
            , label: 'Date<br />Received'
            , toolTip: 'Date Received'
            , visible: true
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'string'
            , saveUsing: 'daterecieved'
            , sortUsing: 'dateReceived'
        });

        opts.fieldDefinitions.push({
            name: 'oldestDOSStr'
            , label: 'Oldest<br />DOS'
            , toolTip: 'Oldest DOS'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'string'
            , saveUsing: 'oldestdos'
            , sortUsing: 'oldestDOS'
        });

        opts.fieldDefinitions.push({
            name: 'name'
            , label: 'File Name'
            , toolTip: 'File Name'
            , visible: true
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'string'
            , saveUsing: 'filename'
            , sortUsing: 'name'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Work Type Dropdown %>
        <%//-----------------------------------------------------------------------------%>

        <%/* Setup autocomplete - Basics */%>

        let wkTypeOpts = {};
        wkTypeOpts.baseUrl                    = '<%=Spedmon.InputBatchesWorkType.URL_VIEW_SEL_BASE()%>';
        wkTypeOpts.loadMode                   = 'mbaviewsel';
        wkTypeOpts.getInitialSelectedNameFrom = 'workTypeName';

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        wkTypeOpts.fnOnSelect = function (event, ui) { };

        <%/* Setup autocomplete - Customization Hooks  */%>

        wkTypeOpts.fnModifyRequestNvps = function (nvpsIn) { return nvpsIn; };
        wkTypeOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs; };
        wkTypeOpts.fnModifyRenderItem = function ($ul, item, $li) {
            var ctxt1 = $('<br><sup>' + item.recData2 + '</sup>');
            $($li).children('a').append(ctxt1);
            return $li;
        };
        wkTypeOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'workTypeID'
            , label: 'Type of<br />Work'
            , toolTip: 'Type of Work'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , saveUsing: 'typeofwork'
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: wkTypeOpts
            , sortUsing: 'workTypeName'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Assigned To Dropdown %>
        <%//-----------------------------------------------------------------------------%>

        <%/* Setup autocomplete - Basics */%>

        let assignedOpts = {};
        assignedOpts.baseUrl                    = '<%=Spedmon.UsersPcal.URL_VIEW_SEL_BASE()%>';
        assignedOpts.loadMode                   = 'mbaviewsel';
        assignedOpts.getInitialSelectedNameFrom = 'lastAssignedTo';

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        assignedOpts.fnOnSelect = function (event, ui) { };

        <%/* Setup autocomplete - Customization Hooks  */%>

        assignedOpts.fnModifyRequestNvps     = function (nvpsIn) {return nvpsIn;};
        assignedOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
        assignedOpts.fnModifyRenderItem = function ($ul, item, $li) {            
            var ctxt1 = $('<br><sup>' + item.recData2 + '</sup>');
            $($li).children('a').append(ctxt1);
            return $li;            
        };
        assignedOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'lastAssignedID'
            , label: 'Assigned To'
            , toolTip: 'Assigned To'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , saveUsing: 'userid2'
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: assignedOpts
            , sortUsing: 'lastAssignedTo'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'estInputHrs'
            , label: 'Estimated<br />Hours'
            , toolTip: 'Estimated Hours'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'estinputhrs'
            , sortUsing: 'estInputHrs'
        });

        opts.fieldDefinitions.push({
            name: 'prtNum'
            , label: 'Priority<br />Number'
            , toolTip: 'Priority Number'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'prtnum'
            , sortUsing: 'prtNum'
        });

        opts.fieldDefinitions.push({
            name: 'statusDateStr'
            , label: 'Status<br />Date'
            , toolTip: 'Status Date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'string'
            , saveUsing: ''
            , sortUsing: 'statusDate'
        });

        opts.fieldDefinitions.push({
            name: 'pcalConsultant'
            , label: 'Practi-Cal<br />Consultant'
            , toolTip: 'Practi-Cal Consultant'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'pcalConsultant'
        });

        opts.fieldDefinitions.push({
            name: 'notes'
            , label: 'Notes'
            , toolTip: 'Notes'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'textarea'
            , saveUsing: 'notes'
            , sortUsing: 'notes'
        });

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

       /*###############################################################################################
         #
         #                                  Column hooks
         #
         ################################################################################################*/

        /* View file */
        opts.additionalControlDefinitionsForBodyRows.set('viewFile', {
            defType: 'userprovided'
            , name: 'viewFile'
            , toolTip: 'View this batch'
            , cssClass: 'fas fa-file-pdf'
            , handlerFn: function (uiActionObj) {                    
                let reqUrl = '<%=Spedmon.ServiceRecords.URL_GET_STORED_FILE_WORK_FLOW()%>';
                let reqObj = {};
                reqObj['<%=Spedmon.Constants.PARM_BATCH_ID%>']             = uiActionObj.recordID;
                reqObj['<%=Spedmon.Constants.PARM_BATCH_FILE_REFERENCE%>'] = '';
                let reqJSON = JSON.stringify(reqObj);
                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, '<%=MBA.Credential.generateSessionExpiredLink()%>')
                    .then(returnDataObj => {
                        let objWinOpts = { url: returnDataObj.rawData.value, windowName: 'viewbatch', refreshView: false };
                        $($restViewCtrl).MBA_RestView('openWindow', objWinOpts);                            
                    });

                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* Messaging */

        opts.additionalControlDefinitionsForBodyRows.set('messaging', {
            defType: 'userprovided'
            , name: 'messaging'
            , toolTip: 'Send a Message'
            , cssClass: 'fas fa-comment mba-messages-widget-class'
            , handlerFn: function (uiActionObj) {
                // no need to do anything here as the messaging constructor will take care of messages
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* Client Notes */

        opts.additionalControlDefinitionsForBodyRows.set('viewClientNotes', {
            defType: 'userprovided'
            , name: 'viewClientNotes'
            , toolTip: 'View Notes for this Client'
            , cssClass: 'fas fa-book'
            , handlerFn: function (uiActionObj) {
                let tkn = $.spedmonWebUI.token;
                let cltid = uiActionObj.whatFieldCellsInputValues.get('clientID');
                let url = "clients.asmx/viewEntity?tkn=" + tkn;
                let $data = "{'clientid':" + cltid + "}";
                let notes = "";
                let name = "";
                $.spedmonWebUI.ajax(null, url, $data, null, null, function (rd) { name = 'Client notes for ' + rd.data.entity.name; notes = rd.data.entity.notes; }, null, null, 0, function () { $.spedmonWebUI.dialogMessage(name, $.spedmonWebUI.formattedTextToHTML(notes, 'ui-spedmon-dialog-mono-txt'), true, 800, 400) });
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        /* Enter service records  */

        opts.additionalControlDefinitionsForBodyRows.set('enterSvcRecs', {
            defType: 'userprovided'
            , name: 'enterSvcRecs'
            , toolTip: 'Enter service records'
            , cssClass: 'fas fa-clipboard'
            , handlerFn: function (uiActionObj) {

                
                let client         = uiActionObj.whatFieldCellsInputValues.get('clientID');
                let inputbatchfile = uiActionObj.whatFieldNameValues['name'];
                let batchid        = uiActionObj.recordID;
                let baseURL        = '<%=Spedmon.ServiceRecords.URL_SBS_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC_BASE()%>';
                let winName        = 'ib-' + batchid;
                let parameters     = [];
                parameters.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_CLIENT_ID%>', client));
                parameters.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_BATCH_FILE_REFERENCE%>', inputbatchfile));
                let url = MBA.ComponentCommon.fnBuildUrl(baseURL, true, parameters);
                MBA.ComponentCommon.fnOpenTab(url, winName);
                return uiActionObj;
            }
            , initiallyHidden: false
        });


        /*###############################################################################################
          #
          #                                  Row hooks
          #
          ################################################################################################*/


        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            if (!rowData) return $newRow;

            /* Call the messaging js constructor on the messaging icon to add messaging functionality */
            let _messageIcon = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="messaging"] > i.fa-comment')[0];
            if (_messageIcon) {
                let _msgOpts = {
                    'clientID': <%=uInfo.userClientID%>
                    , 'sendMessageAjaxURL': '<%=MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_SAVE, true)%>'
                    , 'recipientSrcURL': '<%=MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_VIEW_SEL_CONTACTS, true)%>'
                    , 'replyModeOn': false
                    , 'allowDelete': false
                };

                $(_messageIcon).messagesWidget(_msgOpts);
            }

            return $newRow;
        };

        /* Enable column resize after each data render */

        opts.fnOnAfterDrawTableBodyRows = function (elem, $me, dataObj) {
            enableColumnResize();
        };

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    function syncStickyScrollWidth() {
        let $table = $($restViewCtrl).find('table').first();
        $('#restViewStickyScrollInner').width($table.length ? $table[0].offsetWidth : 0);
    }

    function enableColumnResize() {
        let $table = $($restViewCtrl).find('table').first();
        if (!$table.length) return;

        /* Remove handles and any inline styles left over from previous approaches.
           Scroll/width is now handled entirely by CSS (width:max-content + overflow-x:auto). */
        $table.find('.col-resize-handle').remove();
        $table.css({ 'table-layout': '', 'width': '', 'min-width': '' });
        $table.find('colgroup').remove();

        /* Keep the sticky scrollbar width in sync with the table width */
        syncStickyScrollWidth();

        /* Attach a drag handle to every visible <th>.
           Dragging sets min-width on the <th> directly — no colgroup needed. */
        $table.find('thead tr:first-child th').each(function () {
            let $th = $(this);
            if ($th[0].offsetWidth === 0) return; // hidden column

            $th.css({ position: 'relative', 'user-select': 'none', 'border-right': '1px dotted #000' });

            let $handle = $('<div class="col-resize-handle" style="position:absolute;right:0;top:0;height:100%;width:6px;cursor:col-resize;z-index:2;"></div>');
            $th.append($handle);

            $handle.on('mousedown', function (e) {
                let startX = e.pageX;
                let startW = $th[0].offsetWidth;

                $(document).on('mousemove.colresize', function (e) {
                    let newW = Math.max(40, startW + e.pageX - startX);
                    $th.css({ 'min-width': newW + 'px', 'width': newW + 'px' });
                    syncStickyScrollWidth();
                }).on('mouseup.colresize', function () {
                    $(document).off('.colresize');
                });
                e.preventDefault();
                e.stopPropagation();
            });
        });
    }

    function bulkAssign() {
        let billerID = $('#bulkAssignUserID').val();
        if (!billerID) { MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Assign Selected', 'Please select a person to assign to.', null); return; }

        /* Use the plugin's own API — it uses the correct internal selector (attribute value "1") */
        let $markedRows = $($restViewCtrl).MBA_RestView('getMarkedRows');
        if (!$markedRows || $markedRows.length === 0) { MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Assign Selected', 'Please select at least one record using the mark (✓) button.', null); return; }

        let reqUrl = '<%=Spedmon.InputBatchesInProcess.URL_SAVE_BASE()%>';
        let sessionExpiredLink = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        let promises = [];

        $markedRows.each(function (idx, row) {
            let saveData = {};
            $(row).find('[data-mba-rest-view-save-using]').each(function () {
                let altVal = $(this).attr('data-mba-rest-view-alt-value');
                let val;
                if (altVal !== undefined && altVal !== '') {
                    val = altVal;
                } else if ($(this).is('input') || $(this).is('textarea') || $(this).is('select')) {
                    val = $(this).val();
                } else if ($(this).is('span') || $(this).is('div') || $(this).is('pre')) {
                    val = $(this).text();
                }
                if (val !== undefined) saveData[$(this).attr('data-mba-rest-view-save-using')] = val;
            });
            saveData['userid2'] = billerID;
            saveData['statuscode'] = '60';
            saveData['savetype'] = '2';
            saveData['validaterec'] = '0';
            saveData['recid'] = $(row).attr('data-mba-rest-view-rec-id');
            promises.push(MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, JSON.stringify(saveData), sessionExpiredLink));
        });

        Promise.all(promises).then(function () {
            MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Assign Selected', $markedRows.length + ' record(s) assigned.', null);
            updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
        }).catch(function () {
            MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Assign Selected', 'One or more records could not be saved. Please check and try again.', null);
        });
    }

    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restView');
        initView();

        $('#bulkAssignBtn').on('click', bulkAssign);

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            /* Selecting from "Assign Selected To" should not reload the table */
            if ($(e.target).closest('#bulkAssignPanel').length) return;
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        /* Sync sticky scrollbar ↔ #restViewScroll scroll position */
        let _syncingScroll = false;
        $('#restViewStickyScroll').on('scroll', function () {
            if (_syncingScroll) return;
            _syncingScroll = true;
            $('#restViewScroll').scrollLeft($(this).scrollLeft());
            _syncingScroll = false;
        });
        $('#restViewScroll').on('scroll', function () {
            if (_syncingScroll) return;
            _syncingScroll = true;
            $('#restViewStickyScroll').scrollLeft($(this).scrollLeft());
            _syncingScroll = false;
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

    });

</script>