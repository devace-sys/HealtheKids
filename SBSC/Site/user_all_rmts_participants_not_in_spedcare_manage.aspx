<%@ Page Language="C#" CodeBehind="user_all_rmts_participants_not_in_spedcare_manage.aspx.cs" Inherits="Spedmon.UserAllRmtsParticipantsNotInSpEdCareManage" %>

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
                onSpedmonInputData   = "onClientSelect();"
                runat                = "server">
            </Spedmon:DataEntryRowSelectClient>

            <%//-----------------------------------------------------------------------------%>
            <%// Select Quarter %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryRowSelectRmtsFiscalQuarter
                ID                   = "selectQuarter" 
                entityControlID      = "fyquarterid"                
                rowLabel             = "Quarter"
                dataEntryRowRenderAs = "FIELD"
                onSpedmonInputData   = ""
                runat                = "server">
            </Spedmon:DataEntryRowSelectRmtsFiscalQuarter>    
            	 
        </div>        
    </div>

    <%-----------------------------%>
    <%--       Rest view         --%>
    <%-----------------------------%>
    <div id="restViewRow" class="row mt-3">
        <div class="col-12">
            <div id="restView">
            </div>
        </div>
    </div>
</div>

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">
    /************************************************************************************************************************* */
    let $dataManagementRows = null;
    let $restViewCtrl = null;

    const PARM_NAME_CLIENT_ID   = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_FY_QTR_ID   = '<%=Constants.PARM_FY_QUARTER_ID%>';

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_FY_QTR_ID = $('#' + PARM_NAME_FY_QTR_ID).val();

        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_FY_QTR_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FY_QTR_ID, VALUE_FY_QTR_ID);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FY_QTR_ID);

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

        opts.saveModeAddNew = 'inline';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inline';
        opts.baseUrlEdit = '<%=Spedmon.StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.URL_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters = true;

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = '<%=Spedmon.StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.URL_DELETE_BASE()%>';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.StructuredDataImportFilesRmtsParticipantNotInSpEdCare.DEFAULT_PAGING_ORDER%>';

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

        opts.fieldDefinitions.push({
            name: 'rosterID'
            , label: 'Roster ID'
            , toolTip: 'Roster ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'rosterid'
            , sortUsing: 'rosterID'
        });

        opts.fieldDefinitions.push({
            name: 'fyQuarterID'
            , label: 'Quarter ID'
            , toolTip: 'Quarter ID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'fyquarterid'
            , sortUsing: 'fyQuarterID'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Practitioner Name                                                           %>
        <%//-----------------------------------------------------------------------------%>

        <%/* Setup autocomplete - Basics */%>

        let pracIdOpts = {};
        pracIdOpts.baseUrl                    = '<%=Spedmon.Practitioners.URL_VIEW_SEL2_BASE()%>';
        pracIdOpts.loadMode                   = 'mbaviewsel';
        pracIdOpts.getInitialSelectedNameFrom = 'pracName';

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        pracIdOpts.fnOnSelect = function (event, ui) { };

        <%/* Setup autocomplete - Customization Hooks  */%>

        pracIdOpts.fnModifyRequestNvps = function (nvpsIn) {
            // change prac source to include inactive pracs
            // info on "find" function: https://stackoverflow.com/a/35397839
            try {
                nvpsIn.find(x => x.name == "pracdatasource").value = <%=(int)PractitionerDataSource.ALL_ACTIVE_AND_INACTIVE%>;
            } catch (e) { }
            return nvpsIn;
        };
        pracIdOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
        pracIdOpts.fnModifyRenderItem = function ($ul, item, $li) {            
            var ctxt1 = $('<br><sup>' + item.recData2 + '</sup>');
            $($li).children('a').append(ctxt1);
            return $li;            
        };
        pracIdOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'clientName'
            , label: 'Client'
            , toolTip: 'Client Name'
            , visible: true
            , sortable: true
            , editable: false
            , saveable: false
            , saveUsing: 'clientName'
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'clientName'
        });

        opts.fieldDefinitions.push({
            name: 'pracID'
            , label: 'Practitioner Name'
            , toolTip: 'Practitioner Name'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , saveUsing: 'pracid'
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: pracIdOpts
            , sortUsing: 'pracName'
            , showMore: false
        });
              
        opts.fieldDefinitions.push({
            name: 'lastName'
            , label: 'Last Name'
            , toolTip: 'Last Name'
            , visible: true
            , sortable: true
            , editable: false
            , saveable: false
            , saveUsing: ''
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'lastName'
        });
                        
        opts.fieldDefinitions.push({
            name: 'firstName'
            , label: 'First Name'
            , toolTip: 'First Name'
            , visible: true
            , sortable: true
            , editable: false
            , saveable: false
            , saveUsing: ''
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'firstName'
        });
                                        
        opts.fieldDefinitions.push({
            name: 'middleName'
            , label: 'Middle Name'
            , toolTip: 'Middle Name'
            , visible: true
            , sortable: true
            , editable: false
            , saveable: false
            , saveUsing: ''
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'middleName'
        });
                                                  
        opts.fieldDefinitions.push({
            name: 'title'
            , label: 'Title'
            , toolTip: 'Practitioner Job Title'
            , visible: true
            , sortable: true
            , editable: false
            , saveable: false
            , saveUsing: ''
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'title'
        });
                                                            
        opts.fieldDefinitions.push({
            name: 'email'
            , label: 'Email'
            , toolTip: 'Email'
            , visible: true
            , sortable: true
            , editable: false
            , saveable: false
            , saveUsing: ''
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'email'
        });
                                                  
        opts.fieldDefinitions.push({
            name: 'startDateStr'
            , label: 'Start Date'
            , toolTip: 'Start Date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: ''
            , sortUsing: 'startDateStr'
        });
            
        opts.fieldDefinitions.push({
            name: 'endDateStr'
            , label: 'End Date'
            , toolTip: 'End Date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: ''
            , sortUsing: 'endDateStr'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Parameters for our prac dropdowns (hidden) %>
        <%//-----------------------------------------------------------------------------%>

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
            name: 'patid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'patid'
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
            name: 'groupserviceclassnameid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'groupserviceclassnameid'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'pracdatasource'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'pracdatasource'
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
        
        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            if (!rowData) return $newRow;
            
            return $newRow
        }

        opts.fnCreateNewCellAfter = function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {            
            return $newCell;
        };

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    function onClientSelect() {
        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
    }

    function addNewPrac() {
        var url = '<%=Spedmon.Practitioners.URL_SAVE_NEW_BASE()%>';
        $.spedmonWebUI.openNewWindow(url, 'Practitioner-new-pracID', null);
        return;
    }

    function $createTSPFileUploadElem() {
        let $uploadBtn = $('<i class="fas fa-user-plus ml-1" title="add new practitioner"></i>');

        $uploadBtn.on("click", addNewPrac);

        return $uploadBtn;
    }

    function appendRestViewTopBtns() {
        $('th.mba-rest-view.mba-rest-view-row-controls').append($createTSPFileUploadElem());
    }

    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restView');
        initView();

        appendRestViewTopBtns();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
    });
</script>
