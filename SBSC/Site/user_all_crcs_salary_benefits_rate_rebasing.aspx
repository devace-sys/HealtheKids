<%@ Page Language="C#" CodeBehind="user_all_crcs_salary_benefits_rate_rebasing.aspx.cs" Inherits="Spedmon.userAllCRCSSalaryBenefitsRateRebasing"%>


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
        rowLabel = "" 
        runat    = "server">

      <a class="btn bg-light text-primary" onclick="toggleViewQuarters()">View Quarters</a>

    </Spedmon:DataEntryRow>


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

        opts.refreshViewAfterInlineEditProceed = true;

        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = true;
        opts.enableRowControlRecDelete = false;


        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.CrcsPracSalaries.URL_REST_VIEW_RATEREBASING_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = ''



        opts.saveModeEdit               = 'inline';
        opts.baseUrlEdit                = '<%=Spedmon.CrcsPracSalaries.URL_SAVE_HOURS_FY_BASE() %>';
        opts.baseUrlEditHasParameters   = true;


        opts.enableReports    = true;
        opts.enableReportHtml = false;
        opts.enableReportXls  = true;
        opts.enableReportPdf = false;

        opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport = '<%=Spedmon.CrcsPracSalaries.URL_REST_VIEW_REPORT()%>';
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

              name: 'crcsPracticeFamilyName'

            , label: 'CRCS Practice Family Name'
            , toolTip: 'CRCS Practice Family Name'

            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'crcsPracticeFamilyName'

        });

        /*
        opts.fieldDefinitions.push({
            name: 'pracTitle'
            , label: 'Title'
            , toolTip: 'Title'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'practitle'
            , sortUsing: 'pracTitle'
        });


        
        opts.fieldDefinitions.push({
            name: 'reportingGroup'
            , label: 'Reporting Group'
            , toolTip: 'Reporting Group'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'reportingGroup'
        });
        */

        opts.fieldDefinitions.push({
            name: 'qs_incl'
            , label:   'CRCS Fiscal Quarters'
            , toolTip: 'CRCS Fiscal Quarters'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
        });

        opts.fieldDefinitions.push({
            name: 'SalaryExpenditures_money'
            , label:   'Salary Total<br>Fiscal Year'
            , toolTip: 'Salary Total Fiscal Year'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , sortUsing: 'SalaryExpenditures_money'
            , isRecID: false
            , dataType: 'usd'
        });

        opts.fieldDefinitions.push({
            name: 'BenefitExpenditures_money'
            , label:   'Benefits Total<br>Fiscal Year'
            , toolTip: 'Benefits Total Fiscal Year'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , sortUsing: 'BenefitExpenditures_money'
            , isRecID: false
            , dataType: 'usd'
        });

        opts.fieldDefinitions.push({
            name: 'expenditures'
            , label:   'Payroll Costs Total<br>Fiscal Year'
            , toolTip: 'Payroll Costs Total Fiscal Year'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , sortUsing: 'expenditures'
            , isRecID: false
            , dataType: 'usd'
        });


        opts.fieldDefinitions.push({
            name: 'hoursWorked'
            , label: 'Hours Worked<br>Fiscal Year'
            , toolTip: 'Total Number of Hours Worked This Fiscal Year'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , sortUsing: 'hoursWorked'
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'hoursWorked'
        });

        opts.fieldDefinitions.push({
            name: 'per_hour'
            , label: 'Per Hour Calculation'
            , toolTip: 'Total Payroll Costs Per Hour of Work This Fiscal Year'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , sortUsing: 'per_hour'
            , isRecID: false
            , dataType: 'usd'
        });

        /* Setup additional row controls */

/*
        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.additionalControlDefinitionsForBodyRows.set('participationStatusMsg', {
            defType: 'userprovided'
            , name: 'participationStatusMsg'
            , toolTip: ''
            , cssClass: 'mba-rest-view fas fa-exclamation-circle'
            , handlerFn: function (uiActionObj) {
                return uiActionObj;
            }
            , initiallyHidden: false
        });

*/
        opts.fnCreateNewCellAfter = function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {

            // change tooltip for pracName to pracTitle

            /*
            if ((subsection === 103) && (rowtype === 4)) {
                if (fieldDefinition.name === 'pracName') {
                    $($newCellValue).attr('title', rowData.pracTitle);
                }
            }
            */
            return $newCell;
      
        };

        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

            return $newRow;

       }

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

        appendRestViewHeaderTools();

    });

    function toggleViewQuarters() {
      window.location = '<%= Spedmon.CrcsPracSalaries.URL_SALARYBENEFITS_4QS_BASE() %>' +
                        '&fiscalyearid=' + $('#fiscalyearid').val() +
                        '&clientid='     + $('#clientid').val()     +
                        '&&content_only=1'
    }

</script>