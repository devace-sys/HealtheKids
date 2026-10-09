<%@ Page Language="C#" CodeBehind="user_all_crcs_completion_report.aspx.cs" Inherits="Spedmon.userAllCRCSCompletionReport"%>

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

     <%//-----------------------------------------------------------------------------%>
     <%// Quarter %>
     <%//-----------------------------------------------------------------------------%>
     <Spedmon:DataEntryRow 
         ID       = "dataEntryRowSelectQuarter" 
         rowLabel = "Select Quarter" 
         runat    = "server">
     
         <Spedmon:RadioBox ID="quarter" name="quarter" title="Quarter" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />
     
     </Spedmon:DataEntryRow>

    <%--------------------------------------%>
    <%--       Salaries Rest view         --%>
    <%--------------------------------------%>

    <div id="salariesRestViewRow" class="row mt-3">
        <div class="col-12 d-flex justify-content-center">
            <h3>Salary and Benefits Data Report</h3>
        </div>
        <div class="col-12 mt-2">
            <div id="salariesTotalsRestView">
            </div>
        </div>
    </div>
    
    <%----------------------------------------%>
    <%--      Other Costs Rest view         --%>
    <%----------------------------------------%>

    <div id="otherCostsRestViewRow" class="row mt-3">
        <div class="col-12 d-flex justify-content-center">
            <h3>Other Costs</h3>
        </div>
        <div class="col-12 mt-2">
            <div id="otherCostsTotalsRestView">
            </div>
        </div>
    </div>
        
    <%----------------------------------------%>
    <%--      Contractor Costs Rest view    --%>
    <%----------------------------------------%>

    <div id="contractorCostsRestViewRow" class="row mt-3">
        <div class="col-12 d-flex justify-content-center">
            <h3>Contractor Costs</h3>
        </div>
        <div class="col-12 mt-2">
            <div id="contractorCostsTotalsRestView">
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
    let $salariesTotalsRestViewCtrl = null;
    let $otherCostsTotalsRestViewCtrl = null;
    let $contractorCostsTotalsRestViewCtrl = null;

    const PARM_NAME_CLIENT_ID      = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_FISCAL_YEAR_ID = '<%=Constants.PARM_FISCAL_YEAR_ID%>';    
    const PARM_NAME_QUARTER_ID     = '<%=Constants.PARM_QUARTER%>';


    // *************************************************************************************************************
    // ********************************* Salary Totals Rest view ***************************************************
    // *************************************************************************************************************
    function salariesTotalsUpdateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
        let VALUE_CLIENT_ID        = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_FISCAL_YEAR_ID   = $('#' + PARM_NAME_FISCAL_YEAR_ID).val();
        let VALUE_QUARTER_ID       = $('#' + PARM_NAME_QUARTER_ID).val();

        let NV_CLIENT_ID      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_FISCAL_YEAR_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FISCAL_YEAR_ID, VALUE_FISCAL_YEAR_ID);
        let NV_QUARTER_ID     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_QUARTER_ID, VALUE_QUARTER_ID);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($salariesTotalsRestViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($salariesTotalsRestViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FISCAL_YEAR_ID);
        $($salariesTotalsRestViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_QUARTER_ID);

        $($salariesTotalsRestViewCtrl).MBA_RestView('requestViewFromServer', 1);
    };

    function salariesInitView() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = false;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = false;
        opts.enableRowControlRecDelete = false;

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit               = 'inline';
        opts.baseUrlEdit                = '';
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.CrcsPracSalariesReport.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.CrcsPracSalaryReport.DEFAULT_PAGING_ORDER%>';

        opts.enableReports    = false;
        opts.enableReportHtml = false;
        opts.enableReportXls  = false;
        opts.enableReportPdf  = false;

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
              name: 'grpSvcClassNameID'
            , isRecID: true
            , saveable: false
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
              name: 'grpSvcClassName'
            , label: 'Practitioner Type'
            , toolTip: 'Practitioner Type'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'grpsvcclassname'
            , sortUsing: 'grpSvcClassName'
        });    
        
        opts.fieldDefinitions.push({
              name: 'salary'
            , label: 'Salary Expenditures'
            , toolTip: 'Salary Expenditures'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'salary'
            , sortUsing: 'salary'
        });    
        
        opts.fieldDefinitions.push({
            name: 'benefits'
            , label: 'Benefit Expenditures'
            , toolTip: 'Benefit Expenditures'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'benefits'
            , sortUsing: 'benefits'
        });
                  
        opts.fieldDefinitions.push({
            name: 'federalRevenues'
            , label: 'Federal Revenues'
            , toolTip: 'Federal Revenues'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'federalrevenues'
            , sortUsing: 'federalRevenues'
        });
                            
        opts.fieldDefinitions.push({
            name: 'federalResourceCodes'
            , label: 'Revenue Account Number(s)'
            , toolTip: 'Revenue Account Number(s)'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'federalresourcecodes'
            , sortUsing: 'federalResourceCodes'
        });
                
        opts.fieldDefinitions.push({
            name: 'displayOrder'
            , label: 'Order'
            , toolTip: 'Order'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'displayorder'
            , sortUsing: 'displayOrder'
        });

        /* Create the rest view */

        $($salariesTotalsRestViewCtrl).MBA_RestView(opts);

    }

    // *************************************************************************************************************
    // ********************************* Other Costs Totals Rest view **********************************************
    // *************************************************************************************************************
    function otherCostsTotalsUpdateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_FISCAL_YEAR_ID = $('#' + PARM_NAME_FISCAL_YEAR_ID).val();

        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_FISCAL_YEAR_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FISCAL_YEAR_ID, VALUE_FISCAL_YEAR_ID);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($otherCostsTotalsRestViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($otherCostsTotalsRestViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FISCAL_YEAR_ID);

        $($otherCostsTotalsRestViewCtrl).MBA_RestView('requestViewFromServer', 1);
    };

    function otherCostsTotalsInitView() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = false;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = false;
        opts.enableRowControlRecDelete = false;

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inline';
        opts.baseUrlEdit = '';
        opts.baseUrlEditHasParameters = true;

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.CrcsOtherCostsReport.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.CrcsOtherCostReport.DEFAULT_PAGING_ORDER%>';

        opts.enableReports = false;
        opts.enableReportHtml = false;
        opts.enableReportXls = false;
        opts.enableReportPdf = false;

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'grpSvcClassNameID'
            , isRecID: true
            , saveable: false
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
            name: 'grpSvcClassName'
            , label: 'Practitioner Type'
            , toolTip: 'Practitioner Type'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'grpsvcclassname'
            , sortUsing: 'grpSvcClassName'
        });        

        opts.fieldDefinitions.push({
            name: 'materialsAndSupplies'
            , label: 'Materials and Supplies'
            , toolTip: 'Materials, Supplies and Reference Materials Exprenditures'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'materialsandsupplies'
            , sortUsing: 'materialsAndSupplies'
        });

        opts.fieldDefinitions.push({
            name: 'nonCapitalizedEquipment'
            , label: 'Equipment'
            , toolTip: 'Non-capitalized Equipment Exprenditures'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'noncapitalizedequipment'
            , sortUsing: 'nonCapitalizedEquipment'
        });

        opts.fieldDefinitions.push({
            name: 'travelAndConference'
            , label: 'Travel'
            , toolTip: 'Travel and Conference Exprenditures'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'travelandconference'
            , sortUsing: 'travelAndConference'
        });

        opts.fieldDefinitions.push({
            name: 'duesAndMembership'
            , label: 'Dues'
            , toolTip: 'Dues and Membership Exprenditures'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'duesandmembership'
            , sortUsing: 'duesAndMembership'
        });

        opts.fieldDefinitions.push({
            name: 'communications'
            , label: 'Communications'
            , toolTip: 'Communications Exprenditures'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'communications'
            , sortUsing: 'communications'
        });
        
        opts.fieldDefinitions.push({
            name: 'otherFederalCosts'
            , label: 'Federal Costs'
            , toolTip: 'Federal Costs'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: ''
            , sortUsing: 'otherFederalCosts'
        });
        
        opts.fieldDefinitions.push({
            name: 'federalResourceCodes'
            , label: 'Federal Resource Codes'
            , toolTip: 'Federal Resource Codes'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'federalResourceCodes'
        });

        opts.fieldDefinitions.push({
            name: 'displayOrder'
            , label: 'Order'
            , toolTip: 'Order'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'displayorder'
            , sortUsing: 'displayOrder'
        });

        /* Create the rest view */

        $($otherCostsTotalsRestViewCtrl).MBA_RestView(opts);
    }
    
    // *************************************************************************************************************
    // ********************************* Contractor Costs Totals Rest view *****************************************
    // *************************************************************************************************************
    function contractorCostsTotalsUpdateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_FISCAL_YEAR_ID = $('#' + PARM_NAME_FISCAL_YEAR_ID).val();

        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_FISCAL_YEAR_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FISCAL_YEAR_ID, VALUE_FISCAL_YEAR_ID);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($contractorCostsTotalsRestViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($contractorCostsTotalsRestViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FISCAL_YEAR_ID);

        $($contractorCostsTotalsRestViewCtrl).MBA_RestView('requestViewFromServer', 1);
    };

    function contractorCostsTotalsInitView() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = false;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = false;
        opts.enableRowControlRecDelete = false;

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inline';
        opts.baseUrlEdit = '';
        opts.baseUrlEditHasParameters = true;

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.CrcsContractorCostsReport.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.CrcsContractorCostReport.DEFAULT_PAGING_ORDER%>';

        opts.enableReports = false;
        opts.enableReportHtml = false;
        opts.enableReportXls = false;
        opts.enableReportPdf = false;

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'grpSvcClassNameID'
            , isRecID: true
            , saveable: false
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
            name: 'grpSvcClassName'
            , label: 'Practitioner Type'
            , toolTip: 'Practitioner Type'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'grpsvcclassname'
            , sortUsing: 'grpSvcClassName'
        });        

        opts.fieldDefinitions.push({
            name: 'contractorCosts5800'
            , label: 'Contractor Costs (5800)'
            , toolTip: 'Contractor Costs (5800)'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'contractorcosts5800'
            , sortUsing: 'contractorCosts5800'
        });
        
        opts.fieldDefinitions.push({
            name: 'contractorCosts5100'
            , label: 'Contractor Costs (5100)'
            , toolTip: 'Contractor Costs (5100)'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'contractorcosts5100'
            , sortUsing: 'contractorCosts5100'
        });
                
        opts.fieldDefinitions.push({
            name: 'federalResourceAmounts'
            , label: 'Federal Contractor Costs'
            , toolTip: 'Federal Contractor Costs'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'federalresourceamounts'
            , sortUsing: 'federalResourceAmounts'
        });

        opts.fieldDefinitions.push({
            name: 'hoursPaid'
            , label: 'Total Hours Paid'
            , toolTip: 'Total Hours Paid'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'hourspaid'
            , sortUsing: 'hoursPaid'
        });                        
                
        opts.fieldDefinitions.push({
            name: 'avgContractRatePerHour'
            , label: 'Avg Contract Rate Per Hour'
            , toolTip: 'Avg Contract Rate Per Hour'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'avgcontractrateperhour'
            , sortUsing: 'avgContractRatePerHour'
        });                        

        opts.fieldDefinitions.push({
            name: 'displayOrder'
            , label: 'Order'
            , toolTip: 'Order'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'displayorder'
            , sortUsing: 'displayOrder'
        });

        /* Create the rest view */

        $($contractorCostsTotalsRestViewCtrl).MBA_RestView(opts);
    }

    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $salariesTotalsRestViewCtrl = $('#salariesTotalsRestView');
        $otherCostsTotalsRestViewCtrl = $('#otherCostsTotalsRestView');
        $contractorCostsTotalsRestViewCtrl = $('#contractorCostsTotalsRestView');

        salariesInitView();
        otherCostsTotalsInitView();
        contractorCostsTotalsInitView();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            salariesTotalsUpdateAdditionalViewParameterValuesAndRequestViewFromServer(e);
            otherCostsTotalsUpdateAdditionalViewParameterValuesAndRequestViewFromServer(e);
            contractorCostsTotalsUpdateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        if ($('#' + PARM_NAME_CLIENT_ID).val() && $('#' + PARM_NAME_FISCAL_YEAR_ID).val()) {
            salariesTotalsUpdateAdditionalViewParameterValuesAndRequestViewFromServer(null);
            otherCostsTotalsUpdateAdditionalViewParameterValuesAndRequestViewFromServer(null);
            contractorCostsTotalsUpdateAdditionalViewParameterValuesAndRequestViewFromServer(null);
        }        
    });

</script>