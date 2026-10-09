<%@ Page Language="C#" CodeBehind="user_all_input_batches_manage.aspx.cs" Inherits="Spedmon.userAllInputBatchesManage"%>

<div id="dataManagementRows" class="container-fluid">
    
  <div class="row">
      <div class="col-3">
         <div class="d-flex align-items-center justify-content-start">           
            <Spedmon:SelectYesIsTrueNoIsBlank id="showjustbatchesinprocess" name="showjustbatchesinprocess" title="Show In Process Only" runat="server"/>
          </div>
      </div> <!-- col -->
      <div class="col-3">          
          <div class="d-flex align-items-center justify-content-start">
           
            <%//-----------------------------------------------------------------------------%>
            <%// Select Client %>
            <%// (Practi-Cal staff only) %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryRowSelectClient
                ID                   = "selectClient"
                entityControlID      = "clientid"
                rowLabel             = "Client"
                dataEntryRowRenderAs = "FIELD"
                showClearSelection   = "true"
                onSpedmonInputData   = "updateAdditionalViewParameterValuesAndRequestViewFromServer(null)"
                runat                = "server">
            </Spedmon:DataEntryRowSelectClient>
          </div>
        </div> <!-- col -->
        
      <div class="col-3">

            <div class="d-flex align-items-center justify-content-start">
            
            <%//-----------------------------------------------------------------------------%>
            <%// Select Type of Work %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:ComboBox
                ID          = "worktypeid"
                name        = "worktypeid"
                title       = "Type of Work"
                dataPrivate = "true"
                dataURL     = "input_batches_work_type.asmx/viewSel"
                onSelect    = "updateAdditionalViewParameterValuesAndRequestViewFromServer(null)"
                runat       = "server"/>
          
            <Spedmon:DataEntryButton 
              ID                  = "butDoClearTypeOfWorkSel" 
              faIcon              = "fas fa-times-circle text-danger"
              assignBsCssClasses  = "false"
              iconOnly            = "true"
              onclick             = "clearTypeOfWorkSelection()"             
              title               = "Click here to clear current selection"
              runat               = "server" />
          </div>
        
        </div> <!-- col -->
        
      <div class="col-3">            
          <div class="d-flex align-items-center justify-content-start">
            
            <%//-----------------------------------------------------------------------------%>
            <%// Select Batch Status %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:ComboBox
                ID          = "batch_status_code"
	            name        = "batch_status_code"
	            title       = "Batch Status"
	            dataPrivate = "true"
	            dataURL     = "input_batches_status_codes.asmx/viewSelByCode"
                onSelect    = "updateAdditionalViewParameterValuesAndRequestViewFromServer(null)"                
	            runat       = "server"/>

            <Spedmon:DataEntryButton 
              ID                  = "butDoClearBatchStatusSel" 
              faIcon              = "fas fa-times-circle text-danger"
              assignBsCssClasses  = "false"
              iconOnly            = "true"
              onclick             = "clearBatchStatusSelection()"             
              title               = "Click here to clear current selection"
              runat               = "server" />

          </div> 
        </div> <!-- col -->

            
    </div> <!-- row -->

  <div class="row">
      
      <div class="col-4">
              <%//-----------------------------------------------------------------------------%>
            <%// Select Staff (Input Staff / Work Leaders) %>
            <%//-----------------------------------------------------------------------------%>
            <div class="d-flex align-items-center justify-content-start">
            <Spedmon:ComboBox
                ID          = "staffid"
                name        = "staffid"
                title       = "Staff"
                dataPrivate = "true"
                dataURL     = "users_pcal.asmx/viewSelStaff"
                onSelect    = "updateAdditionalViewParameterValuesAndRequestViewFromServer(null)"
                runat       = "server"/>
            
            <Spedmon:DataEntryButton 
              ID                  = "butDoClearAssignedStaffSel" 
              faIcon              = "fas fa-times-circle text-danger"
              assignBsCssClasses  = "false"
              iconOnly            = "true"
              onclick             = "clearAssignedStaffSelection()"             
              title               = "Click here to clear current selection"
              runat               = "server" />

            <input type="hidden" id="batchid" name="batchid" value="" />
             </div>
  
        
      </div> <!-- col -->
        
      <div class="col-4">
          <div id="bulkAssignPanel" class="d-flex align-items-center justify-content-center p-3">
                <Spedmon:ComboBox
                    ID          = "bulkAssignUserID"
                    name        = "bulkAssignUserID"
                    title       = "Assign Selected To"
                    dataPrivate = "true"
                    dataURL     = "users_pcal.asmx/viewSelInputStaff"                   
                    runat       = "server"/>
              <button type="button" id="bulkAssignBtn" class="btn btn-primary btn-sm">Assign Selected</button>
            </div>
        </div> <!-- col -->        

      <div class="col-4">
           <div class="d-flex align-items-center justify-content-end">
            
            <Spedmon:DataEntryBoxText
                ID               = "searchFileName"
                name             = "searchFileName"
                label            = "Search Filename (regardless of filters)"
                title            = "Enter all or part of filename"                
                size             = "20"
                fireSpedmonInput = "false"                                
                runat            = "server"/>
            
            <Spedmon:DataEntryButton ID="butDoSearchByFile" title="Search" onclick="updateAdditionalViewParameterValuesAndRequestViewFromServer(null)" faIcon="fa fa-search" style="info" iconOnly="true"  runat="server" />
            <Spedmon:DataEntryButton ID="butDoClearSearchByFile" title="Clear" onclick="clearSearchByFileName()" faIcon="fa fa-times-circle" style="danger" iconOnly="true"  runat="server" />

          </div>
      </div> <!-- col -->
    </div> <!-- row -->

  <div id="restViewRow" class="row mt-2">
            <div class="col-12">
              <div id="restView"> </div>
            </div> <!-- col -->
        </div> <!-- row -->

</div> <!-- dataManagementRows -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    /************************************************************************************************************************* */

    let $dataManagementRows = null;
    let $restViewCtrl       = null;

    /************************************************************************************************************************* */

    const PARM_NAME_CLIENT_ID                    = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_BATCH_STATUS_CODE            = '<%=Constants.PARM_BATCH_STATUS_CODE%>';
    const PARM_NAME_REC_USER_ID                  = 'recuserid';
    const PARM_NAME_BATCH_ID                     = '<%=Constants.PARM_BATCH_ID%>';
    const PARM_NAME_WORK_TYPE_ID                 = 'worktypeid';
    const PARM_NAME_BILLER_ID                    = 'staffid';
    const PARM_NAME_SEARCH_TERM                  = '<%=Constants.PARM_SEARCH_TERM%>';
    const PARM_NAME_SHOW_JUST_BATCHES_IN_PROCESS = 'showjustbatchesinprocess';

    /************************************************************************************************************************* */

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID                     = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_BATCH_STATUS_CODE             = $('#' + PARM_NAME_BATCH_STATUS_CODE).val();
        let VALUE_BATCH_ID                      = $('#' + PARM_NAME_BATCH_ID).val();
        let VALUE_WORK_TYPE_ID                  = $('#' + PARM_NAME_WORK_TYPE_ID).val();
        let VALUE_SEARCH_TERM                   = $('#searchFileName').val();
        let VALUE_SHOW_JUST_BATCHES_IN_PROGRESS = $('#' + PARM_NAME_SHOW_JUST_BATCHES_IN_PROCESS).val();

        if (VALUE_SEARCH_TERM != '') {

            VALUE_CLIENT_ID         = '';
            VALUE_BATCH_STATUS_CODE = '';
            VALUE_BATCH_ID          = '';
            VALUE_WORK_TYPE_ID      = '';
            VALUE_SHOW_JUST_BATCHES_IN_PROGRESS = '';
        } 

        /* Input staff are always filtered to their own records; all others use the biller filter */

        <% if (uInfo.userRole.ToLower() == Constants.ROLE_INPUT_STAFF) { %>
          let VALUE_REC_USER_ID = '<%=uInfo.userid%>';
        <% } else { %>
          let VALUE_REC_USER_ID = $('#' + PARM_NAME_BILLER_ID).val();
        <% } %>

        let NV_CLIENT_ID                    = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_BATCH_STATUS_CODE            = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_BATCH_STATUS_CODE, VALUE_BATCH_STATUS_CODE);
        let NV_REC_USER_ID                  = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_REC_USER_ID, VALUE_REC_USER_ID);
        let NV_BATCH_ID                     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_BATCH_ID, VALUE_BATCH_ID);
        let NV_WORK_TYPE_ID                 = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_WORK_TYPE_ID, VALUE_WORK_TYPE_ID);
        let NV_SEARCH_TERM                  = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SEARCH_TERM, VALUE_SEARCH_TERM);
        let NV_SHOW_JUST_BATCHES_IN_PROCESS = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SHOW_JUST_BATCHES_IN_PROCESS, VALUE_SHOW_JUST_BATCHES_IN_PROGRESS);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_BATCH_STATUS_CODE);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_REC_USER_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_BATCH_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_WORK_TYPE_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SEARCH_TERM);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SHOW_JUST_BATCHES_IN_PROCESS);
        
        
        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);
    };

    /************************************************************************************************************************* */

    function initView() {

        let opts = {};

        /*opts.autoHidePageControls = false;
        opts.enableScrollView = true;
        opts.scrollViewUseCustomHeight = true;
        opts.scrollViewCustomHeight = '20em';
        */

        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = false;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit   = true;
        opts.enableRowControlRecDelete = true;
        opts.enableRowControlMarkRow   = true;

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inline';
        opts.baseUrlEdit = '<%=Spedmon.InputBatchesInProcess.URL_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters = true;
        opts.refreshViewAfterInlineEditProceed = true;

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = '<%=Spedmon.InputBatchesInProcess.URL_DELETE_BASE()%>';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.InputBatchesInProcess.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.InputBatchInProcess.DEFAULT_PAGING_ORDER%>';

        opts.enableReports    = true;
        opts.enableReportHtml = true;
        opts.enableReportXls  = true;
        opts.enableReportPdf  = false;

        opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport  = '<%=Spedmon.Clients.URL_WEB_REPORT_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '<%=Spedmon.ClientsRpt.RPT_BATCHES_IN_PROCESS%>';

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Priority Number %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'prtNum'
            , label: 'Priority'
            , toolTip: 'Priority Number'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'prtnum'
            , sortUsing: 'prtNum'
            , styleAttrValueForCellValue: 'width:3.5em'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Client Dropdown %>
        <%//-----------------------------------------------------------------------------%>

        let clientOpts = {};
        clientOpts.baseUrl                    = '<%=Spedmon.Clients.URL_SVC_VIEWSEL_BASE()%>';
        clientOpts.loadMode                   = 'mbaviewsel';
        clientOpts.getInitialSelectedNameFrom = 'clientName';
        clientOpts.fnOnSelect                 = function (event, ui) { };
        clientOpts.fnModifyRequestNvps        = function (nvpsIn) { return nvpsIn; };
        clientOpts.fnModifyResponseSelRecs    = function (requestNvps, SelRecs) { return SelRecs; };
        clientOpts.fnModifyRenderItem         = function ($ul, item, $li) { return $li; };
        clientOpts.fnHandleCellValueAction    = function (uiActionObj) { return uiActionObj; };

        opts.fieldDefinitions.push({
            name: 'clientID'
            , label: 'Client'
            , toolTip: 'Client'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: clientOpts
            , saveUsing: 'clientid'
            , sortUsing: 'clientName'
            , styleAttrValueForCellValue: 'width:8em'
        });

        opts.fieldDefinitions.push({
            name: 'name'
            , label: 'File Name'
            , toolTip: 'File Name'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'filename'
            , sortUsing: 'name'
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
            name: 'dateReceivedStr'
            , label: 'Date<br />Received'
            , toolTip: 'Date Received'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'daterecieved'
            , sortUsing: 'dateReceived'
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
            /* Note: intentionally not filtering out any codes here so this list always matches
               the full list returned by the same web service used for the top status filter. */
            return SelRecs
                .map(function (r) {
                    var normalized = (r.value || '').toLowerCase().replace(/\s+/g, ' ').trim();
                    if (normalized.indexOf('pre screen') !== -1) r.value = 'Pre Screen';
                    if (normalized.indexOf('nb filed') !== -1) r.value = 'Not Billable';
                    return r;
                });
        };
        statusOpts.fnModifyRenderItem = function ($ul, item, $li) { return $li; };
        statusOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj; };

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'curStatusCode'
            , label: 'Current<br>Status'
            , toolTip: 'Current Status and last updated date'
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
            , styleAttrValueForCellValue: 'width:7em'
        });

        opts.fieldDefinitions.push({
            name: 'oldestDOSStrYMD'
            , label: 'Oldest<br>DOS'
            , toolTip: 'Oldest DOS'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'oldestdos'
            , sortUsing: 'oldestDOS'
            , styleAttrValueForCellValue: 'width:8em'
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
            , label: 'Type of<br>Work'
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
            , styleAttrValueForCellValue: 'width:7em'
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
            , styleAttrValueForCellValue: 'width:7em'
        });

        opts.fieldDefinitions.push({
            name: 'degOfDiff'
            , label: 'Dgr<br>of<br>Dif'
            , toolTip: 'Degree of Difficulity'
            , visible: false
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'degofdiff'
            , sortUsing: 'degOfDiff'            
        });

        opts.fieldDefinitions.push({
            name: 'estInputHrs'
            , label: 'Est<br>Hrs'
            , toolTip: 'Estimated Hours'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'estinputhrs'
            , sortUsing: 'estInputHrs'
            , styleAttrValueForCellValue: 'width:4.5em'
        });

        opts.fieldDefinitions.push({
            name: 'notes'
            , label: 'Filename/Notes'
            , toolTip: 'Filename and input batch notes'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'textarea'
            , saveUsing: 'notes'
            , sortUsing: 'notes'
            , styleAttrValueForCellValue: 'width:100%'
        });


        /*###############################################################################################
          #
          #                                     Additional Info
          #
          ################################################################################################*/

        opts.enableRowControlShowAdditionalInfo = true;

        opts.additionalInfoFieldDefinitions = [];

        opts.additionalInfoFieldDefinitions.push({
            name: 'name'
            , label: 'File Name'
            , toolTip: 'File Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'string'
            , saveUsing: 'filename'
            , sortUsing: 'name'            
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'dateReceivedStr'
            , label: 'Date Received'
            , toolTip: 'Date Received'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'string'
            , saveUsing: 'daterecieved'
            , sortUsing: 'dateReceived'            
        });


        opts.additionalInfoFieldDefinitions.push({
            name: 'statusDateStr'
            , label: 'Status Date'
            , toolTip: 'Status Date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'string'
            , saveUsing: ''
            , sortUsing: 'statusDate'            
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'pcalConsultant'
            , label: 'Practi-Cal Consultant'
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

        /*###############################################################################################
          #
          #                                        Column hooks
          #
          ################################################################################################*/

        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
            if ((subsection === 103) && (rowtype === 4)) {
                if (fieldDefinition.name === 'curStatusCode') {
                    $(newCell).append($('<div>' + rowData.statusDateStr + '</div>'));
                }
                else if (fieldDefinition.name === 'notes') {

                    $(newCell).prepend($('<div>' + rowData.name + '</div>'));
                }
            }

            /* Return cell new as required */
            return newCell;
        };

        /*###############################################################################################
          # 
          #                                     Additional Row Controls
          #
          ################################################################################################*/

        opts.additionalControlDefinitionsForBodyRows = new Map();

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
                reqObj['<%=Spedmon.Constants.PARM_BATCH_FILE_REFERENCE%>'] = uiActionObj.whatFieldNameValues['name'];
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
            , cssClass: 'fas fa-book text-info'
            , handlerFn: function (uiActionObj) {
                let tkn = $.spedmonWebUI.token;
                let cltid = uiActionObj.whatFieldNameValues['clientID'];
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
            , cssClass: 'fa fa-edit text-secondary'
            , handlerFn: function (uiActionObj) {


                let client         = uiActionObj.whatFieldNameValues['clientID'];
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


        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    };

    /************************************************************************************************************************* */

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
    };

    /************************************************************************************************************************* */

    function clearSearchByFileName() {
        $('#searchFileName').MBA_DataEntryBox('clearValue');
       updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
    };
    /************************************************************************************************************************* */

    function clearTypeOfWorkSelection() {
        $('#' + PARM_NAME_WORK_TYPE_ID).spedmonSelectBox_clear();
        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
    };

    /************************************************************************************************************************* */

    function clearBatchStatusSelection() {
        $('#' + PARM_NAME_BATCH_STATUS_CODE).spedmonSelectBox_clear();
        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
    };

    /************************************************************************************************************************* */

    function clearAssignedStaffSelection() {
        $('#' + PARM_NAME_BILLER_ID).spedmonSelectBox_clear();
        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
    };

    /************************************************************************************************************************* */

    $(document).ready(function () {
        
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl       = $('#restView');
        initView();

        $('#bulkAssignBtn').on('click', bulkAssign);

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            /* Selecting from "Assign Selected To" should not reload the table */
            if ($(e.target).closest('#bulkAssignPanel').length) return;
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        
        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

    });

</script>
