<%@ Page Language="C#" CodeBehind="user_all_crcs_contractor_costs_manage.aspx.cs" Inherits="Spedmon.userAllCRCSContractorCostsManage"%>

<div id="dataManagementRows" class="container-fluid p-0">    
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
    <%// Select Year %>
    <%//-----------------------------------------------------------------------------%>
    <Spedmon:DataEntryRowSelectFiscalYear
        ID                   = "selectFiscalYear" 
        entityControlID      = "fiscalyearid"                
        rowLabel             = "Year"
        dataEntryRowRenderAs = "FIELD"
        runat                = "server">
    </Spedmon:DataEntryRowSelectFiscalYear>

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

    const PARM_NAME_CLIENT_ID                 = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_FISCAL_YEAR_ID            = '<%=Constants.PARM_FISCAL_YEAR_ID%>';

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
        let VALUE_CLIENT_ID      = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_FISCAL_YEAR_ID = $('#' + PARM_NAME_FISCAL_YEAR_ID).val();

        let NV_CLIENT_ID      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_FISCAL_YEAR_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FISCAL_YEAR_ID, VALUE_FISCAL_YEAR_ID);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FISCAL_YEAR_ID);

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
        opts.enableRowControlRecDelete = false;

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit               = 'inline';
        opts.baseUrlEdit                = '<%=Spedmon.CrcsContractorCosts.URL_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.CrcsContractorCosts.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.CrcsContractorCost.DEFAULT_PAGING_ORDER%>';

        opts.enableReports    = false;
        opts.enableReportHtml = false;
        opts.enableReportXls  = false;
        opts.enableReportPdf  = false;

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
              name: 'pracID'
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
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'clientid'
            , sortUsing: 'clientID'
        });

        opts.fieldDefinitions.push({
            name: 'pracID'
            , label: 'Practitioner ID'
            , toolTip: 'Practitioner ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'pracid'
            , sortUsing: 'pracID'
        });

        opts.fieldDefinitions.push({
            name: 'fiscalYearID'
            , label: 'Fiscal Year ID'
            , toolTip: 'Fiscal Year ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'fiscalyearid'
            , sortUsing: 'fiscalYearID'
        });

        opts.fieldDefinitions.push({
            name: 'pracName'
            , label: 'Practitioner'
            , toolTip: 'Practitioner'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'pracname'
            , sortUsing: 'pracName'
        });

        opts.fieldDefinitions.push({
            name: 'pracTitle'
            , label: 'Title'
            , toolTip: 'Title'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'practitle'
            , sortUsing: 'pracTitle'
        });
        
        opts.fieldDefinitions.push({
            name: 'crcsPracticeFamilyName'
            , label: 'CRCS Practice<br/>Family'
            , toolTip: 'CRCS Practice Family'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'crcsPracticeFamilyName'
            , sortUsing: 'crcsPracticeFamilyName'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Employee Status %>
        <%//-----------------------------------------------------------------------------%>

        let employeeStatusFieldOptions = {};

        employeeStatusFieldOptions.selections = [
            { name: 'Employee', value: '10' }
            , { name: 'Contractor', value: '20' }];

        opts.fieldDefinitions.push({
            name: 'employeeRelationshipID'
            , label: 'Employee Status'
            , toolTip: 'Employee Status'
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: employeeStatusFieldOptions
            , sortUsing: 'employeeRelationshipID'
            , saveUsing: 'employeerelationshipid'
            , showMore: false
            , handlerFn: function (uiActionObj) {
                return uiActionObj;
            }
        });

        opts.fieldDefinitions.push({
            name: 'contractorCosts5800'
            , label: 'Contractor Costs<br>(Object Code 5800)'
            , toolTip: 'Contractor Costs 5800'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'contractorcosts5800'
            , sortUsing: 'contractorCosts5800'
        });

        opts.fieldDefinitions.push({
            name: 'contractorCosts5100'
            , label: 'Contractor Costs<br>(Object Code 5100)'
            , toolTip: 'Contractor Costs 5100'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'contractorcosts5100'
            , sortUsing: 'contractorCosts5100'
        });

        opts.fieldDefinitions.push({
            name: 'contractRatePerHour'
            , label: 'Contract Rate<br>Per Hour'
            , toolTip: 'Contract Rate Per Hour'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'contractrateperhour'
            , sortUsing: 'contractRatePerHour'
        });

        opts.fieldDefinitions.push({
            name: 'federalResourceAmounts'
            , label: 'Federal Resource<br>Amounts'
            , toolTip: 'Federal Resource Amounts'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'federalresourceamounts'
            , sortUsing: 'federalResourceAmounts'
        });

        opts.fieldDefinitions.push({
            name: 'federalResourceCodes'
            , label: 'Federal Resource<br>Code(s)'
            , toolTip: 'Federal Resource Code(s)'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'federalresourcecodes'
            , sortUsing: 'federalResourceCodes'
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
            , dataType: 'text'
            , saveUsing: 'notes'
            , sortUsing: 'notes'
        });

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.fnCreateNewCellAfter = function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
            // change tooltip for pracName to pracTitle
            if ((subsection === 103) && (rowtype === 4)) {
                if (fieldDefinition.name === 'pracName') {
                    $($newCellValue).attr('title', rowData.pracTitle);
                }
            }
            return $newCell;
        };

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restView');
        initView();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        if ($('#' + PARM_NAME_CLIENT_ID).val() && $('#' + PARM_NAME_FISCAL_YEAR_ID).val()) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
        }

        // append instructions icon
        $instructionsIcon = $('<i style="font-size: 1.2em;" class="mba-rest-view fas fa-question-circle ml-2"></i>');
        instructionsText = `<p>This tab displays contracted practitioners, for whom your LEA received program reimbursement. Please read these instructions, as there may be different scenarios for how costs will be entered.</p>
                            <p><strong>Scenario #1 - The contracted practitioner is under a single contract with your LEA.</strong></p>
                            <ul style="list-style-type: disc;" class="ml-3">
                                <li>Enter the total annual contract cost in the appropriate column for object code 5800 and/or 5100. Then enter the contract rate per hour for this contractor.</li>
                            </ul>
                            <p>Note: If the hourly rate is not known, you can either ask the contractor, what their standard hourly rate is, divide the number of hours worked into the total cost, or average it with other known (similar) contracts. If you divide or average, please keep all records of how the amount was determined.</p>
                            <p><strong>Scenario #2 – Multiple contractors listed are included under the same contract with your LEA.</strong></p>
                            <ul style="list-style-type: disc;" class="ml-3">
                                <li>Enter the total amount of the single contract on any one of the contracted practitioners, who a part of the contract. Also add the name of the contracting agency in the notes column.</li>
                                <li>Then on the remaining staff, who are part a the contract, edit and add a note, stating “See costs for (contracted staff’s name, who you entered the costs under)
                                    <ul style="list-style-type: circle;" class="ml-3">
                                        <li>For example: John, Sally, and Tammy are contracted SLP’s under one agreement. You can add all costs to John and add a note to Sally and Tammy that says "See costs for John".</li>
                                    </ul>
                                </li>
                            </ul>
                            <p>Note: You can use the note field to identify the contracting agency</p>
                            <p>Here are tab validations that will not allow a row to be saved:</p>
                            <ul style="list-style-type: disc;" class="ml-3">
                                <li>Entering costs in 5800 and/or 5100 and not entering a rate per hour</li>
                                <li>Entering federal costs, but not the corresponding SACS resource code</li>
                            </ul>
                            <p>When all costs have been entered the “Contractor Costs” tab label will turn green, with a green checkmark.</p>
        `
        $instructionsIcon.tipso({
            speed: 400
            , background: '#ffd60d'
            , titleBackground: '#333333'
            , color: 'black'
            , titleColor: '#ffffff'
            , titleContent: ''
            , showArrow: true
            , position: 'top'
            , width: $(window).width() / 2
            , maxWidth: ''
            , delay: 200
            , hideDelay: 0
            , animationIn: ''
            , animationOut: ''
            , offsetX: 0
            , offsetY: 0
            , tooltipHover: true
            , content: instructionsText
            , ajaxContentUrl: null
            , contentElementId: null
            , useTitle: false
            , templateEngineFunc: null
            , onBeforeShow: null
            , onShow: null
            , onHide: null
        });

        $instructionsIcon.on('click', function () { $.spedmonWebUI.dialogMessage('Instructions', instructionsText, null, $(window).width() / 1.5, $(window).height() / 1.5, null, null, null);; });

        $('th.mba-rest-view.mba-rest-view-row-controls').append($instructionsIcon);
    });

</script>