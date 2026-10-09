<%@ Page Language="C#" CodeBehind="user_all_crcs_salary_benefits_before_19_20_fy_manage.aspx.cs" Inherits="Spedmon.userAllCRCSSalaryBenefitsBefore1920FYManage"%>

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

        // invoke parent window's method to refresh the CRCS completion status
        try {
            parent.refreshCompletionStatus();
        } catch(e) { }
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
        opts.baseUrlEdit                = '<%=Spedmon.CrcsPracSalariesBefore1920FY.URL_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.CrcsPracSalariesBefore1920FY.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.CrcsPracSalaryBefore1920FY.DEFAULT_PAGING_ORDER%>';

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
              { name: 'Employee'       , value: '10' }
            , { name: 'Contractor'     , value: '20' }];

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
            name: 'salary'
            , label: 'Gross Salary<br/>(Object Code 1000-2999)'
            , toolTip: 'Gross Salary (Object Code 1000-2999)'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'salary'
            , sortUsing: 'salary'
        });

        opts.fieldDefinitions.push({
            name: 'federalSalary'
            , label: 'Federal Salary<br/>3000-5999 (excluding 5640)'
            , toolTip: 'Federal portion of gross salary'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'federalsalary'
            , sortUsing: 'federalSalary'
        });
        
        opts.fieldDefinitions.push({
            name: 'federalSalaryResourceCode'
            , label: 'Federal<br />Resource Code'
            , toolTip: 'Federal Resource Code'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'federalsalaryresourcecode'
            , sortUsing: 'federalSalaryResourceCode'
        });

        opts.fieldDefinitions.push({
            name: 'benefits'
            , label: 'Gross Benefits<br/>(Object Code 3000-3999)'
            , toolTip: 'Gross Benefits (Object Code 3000-3999)'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'benefits'
            , sortUsing: 'benefits'
        });

        opts.fieldDefinitions.push({
            name: 'federalBenefits'
            , label: 'Federal Benefits<br/>3000-5999 (excluding 5640)'
            , toolTip: 'Federal portion of gross benefits'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'usd'
            , saveUsing: 'federalbenefits'
            , sortUsing: 'federalBenefits'
        });

        opts.fieldDefinitions.push({
            name: 'federalBenefitsResourceCode'
            , label: 'Federal<br />Resource Code'
            , toolTip: 'Fed Resource Code'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'federalbenefitsresourcecode'
            , sortUsing: 'federalBenefitsResourceCode'
        });

        opts.fieldDefinitions.push({
            name: 'clientEmployeeID'
            , label: 'Employee ID / Notes'
            , toolTip: 'Employee ID / Notes'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'clientemployeeid'
            , sortUsing: 'clientEmployeeID'
        });

        opts.fieldDefinitions.push({
            name: 'grossAmount'
            , label: 'Gross Amount'
            , toolTip: 'Gross Amount'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'grossamount'
            , sortUsing: 'grossAmount'
        });

        opts.fieldDefinitions.push({
            name: 'grossFederalAmount'
            , label: 'Gross Fed Amount'
            , toolTip: 'Gross Fed Amount'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'grossfederalamount'
            , sortUsing: 'grossFederalAmount'
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
        instructionsText = `<p>This tab has been pre-populated with the employed staff members for whom your LEA has certified, as LEA Medi-Cal Billing Option Program and RMTS participants. Please complete the information below for ALL names listed. To edit/enter information, click the pencil next to the employed staff members name. Then enter the costs associated with the individual staff member. Please have all salary & benefit information gathered, as once costs are entered, on a row, SpEdCare will validate that data has been entered and not allow an incomplete record to be saved.</p>
                            <p><strong>Important:</strong> Starting with FY2021, Salary and Benefit costs are to be reported quarterly. Do not enter annual amounts, on a quarterly tab.</p>
                            <p>Here are tab validations that will not allow a row to be saved:</p>
                            <ul style="list-style-type: disc;" class="ml-3">
                                <li>Entering salary, but not benefit information</li>
                                <li>Entering benefit, but not salary information</li>
                                <li>Entering federal costs, but not the corresponding SACS resource code.</li>
                            </ul>
                            <p>Employee ID cell is optional.</p>
                            <p>When all costs have been entered the “Salary & Benefits” tab label will turn green, with a green checkmark.</p>
                            <p><strong>Important:</strong></p>
                            <ul style="list-style-type: disc;" class="ml-3">
                                <li>Be sure to enter ALL salary costs in the salary column, including federal amounts. Then enter the portion of federal salary (if any) in the federal salary column. Not entering federal salary in the regular salary column will reduce your eligible cost pool and have a negative affect on your CRCS results</li>
                                <li>Employed staff that are 100% federally-funded cannot participate in the RMTS program. The RMTS program is used to calculate percentages for the LEA Billing Option Program and the SMAA program</li>
                            </ul>
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