<%@ Page Language="C#" CodeBehind="user_all_patients_current_mcal_benefits_manage.aspx.cs" Inherits="Spedmon.userAllPatientsCurrentMcalBenefitsManage"%>

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
        showClearSelection   = "true"
        runat                = "server">
    </Spedmon:DataEntryRowSelectClient>

    <%//-----------------------------------------------------------------------------%>
    <%// Select Patient %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectPatient
        ID                                 = "selectPatient" 
        rowLabel                           = "Patient?" 
        dataEntryRowRenderAs               = "FIELD"
        preSelectedDataSource              = "ALL_PATIENTS"
        saveDataSourceSelectedAsPreference = "false"
        showClearSelection                 = "true"
        runat                              = "server">
    </Spedmon:DataEntryRowSelectPatient>

</div> <!-- col -->
</div> <!-- row -->

<div class="row">

<%//-----------------------------------------------------------------------------%>
<%// Management category %>
<%//-----------------------------------------------------------------------------%>

<div class="col">
<Spedmon:RadioBox ID="currentbenefitstatuscode" name="currentbenefitstatuscode" title="Eligibility Status" renderLabel="true" additionalCssClassNameForContainer="modern2021" runat="server" />
</div> <!-- col -->

<%//-----------------------------------------------------------------------------%>
<%// Filter On If Patient Has Alt Format %>
<%//-----------------------------------------------------------------------------%>

<div class="col">
<Spedmon:SelectYesOrNoOrAny ID="hasaltformat" name="hasaltformat" title="Has Alt Format" renderLabel="true" additionalCssClassNameForContainer="modern2021"  runat="server" />
</div> <!-- col -->


</div> <!-- row -->
                         
<%//-----------------------------------------------------------------------------%>
<%// Rest View %>
<%//-----------------------------------------------------------------------------%>

<div id="restViewRow" class="row mt-3">
<div class="col-12">
<div id="restView">
</div> <!-- rest view -->
</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

<%/**************************************************************************************************************************/%>
    let $dataManagementRows = null;
    let $restViewCtrl = null;

    const PARM_NAME_CLIENT_ID                   = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_CURRENT_BENEFIT_STATUS_CODE = '<%=Constants.PARM_CURRENT_BENEFIT_STATUS_CODE%>';
    const PARM_NAME_PAT_ID                      = '<%=Constants.PARM_PATIENT_ID%>';
    const PARM_NAME_HAS_ALT_FORMAT              = '<%=Constants.PARM_HAS_ALT_FORMAT%>';

<%/**************************************************************************************************************************/%>

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID                   = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_CURRENT_BENEFIT_STATUS_CODE = $('#' + PARM_NAME_CURRENT_BENEFIT_STATUS_CODE).val();
        let VALUE_PAT_ID                      = $('#' + PARM_NAME_PAT_ID).val();
        let VALUE_HAS_ALT_FORMAT              = $('#' + PARM_NAME_HAS_ALT_FORMAT).val();

        let NV_CLIENT_ID                   = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID,                   VALUE_CLIENT_ID);
        let NV_CURRENT_BENEFIT_STATUS_CODE = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CURRENT_BENEFIT_STATUS_CODE, VALUE_CURRENT_BENEFIT_STATUS_CODE);
        let NV_PAT_ID                      = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID,                      VALUE_PAT_ID);
        let NV_HAS_ALT_FMT                 = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_HAS_ALT_FORMAT,              VALUE_HAS_ALT_FORMAT);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CURRENT_BENEFIT_STATUS_CODE);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_HAS_ALT_FMT);
        
        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);
    };

<%/**************************************************************************************************************************/%>

    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl                  = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad                  = false; /*This is so we can set the initial filters */
        opts.enableSortControls                 = true;
        opts.enableRowNumbers                   = false;
        opts.enableRowControls                  = true;
        opts.enableRowControlRecAddNew          = false;
        opts.enableRowControlRecEdit            = true;
        opts.enableRowControlRecDelete          = false;
        opts.enableRowControlShowAdditionalInfo = false;

        opts.saveModeAddNew             = 'inwindow';
        opts.baseUrlAddNew              = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit               = 'inline';
        opts.baseUrlEdit                = '<%=Spedmon.PatientsCurrentMcalBenefits.URL_SVC_UPDATE_OUTREACH_NOTES_BASE()%>';
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView               = 'rest';
        opts.baseUrlView                = '<%=Spedmon.PatientsCurrentMcalBenefits.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters   = true;
        opts.defaultPageRowOrder        = '<%=Spedmon.PatientCurrentMcalBenefits.DEFAULT_PAGING_ORDER%>';
        
        opts.enableReports              = true;
        opts.enableReportHtml           = true;
        opts.enableReportXls            = true;
        opts.enableReportPdf            = false;

        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = '<%=Spedmon.PatientsCurrentMcalBenefits.URL_WEB_REPORT_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber        = '1';

        opts.fieldDefinitions = [];
        opts.additionalInfoFieldDefinitions = [];

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
            name: 'name'
            , label: 'Student Name'
            , toolTip: 'Student Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'lastfirst'
            , saveUsing: 'name'
            , sortUsing: 'name'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });

        opts.fieldDefinitions.push({
            name: 'dobStr'
            , label: 'Date<br>of Birth'
            , toolTip: 'Date of Birth'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'dob'
            , sortUsing: 'dob'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });

        opts.fieldDefinitions.push({
              name: 'patStudentID'
            , label: 'Student ID'
            , toolTip: 'Student ID'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'patStudentID'
        });

        opts.fieldDefinitions.push({
            name: 'currentSiteName'
            , label: 'School Site'
            , toolTip: 'Current School Site'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'currentSiteName'
            , sortUsing: 'currentSiteName'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });

        opts.fieldDefinitions.push({
            name: 'patSSID'
            , label: 'SSID'
            , toolTip: 'SSID'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , sortUsing: 'patSSID'
            , isRecID: false
            , dataType: 'text'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });

        opts.fieldDefinitions.push({
              name: 'spEdCaseManagerName'
            , label: 'Case Manager'
            , toolTip: 'Case manager name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , sortUsing: 'spEdCaseManagerName'
            , isRecID: false
            , dataType: 'text'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'altFormat'
            , label: 'Alternative Format'
            , toolTip: 'Alternative format'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , sortUsing: 'altFormat'
            , isRecID: false
            , dataType: 'text'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'patBIC'
            , label: 'BIC/Member #'
            , toolTip: 'BIC/Member #'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'patBIC'
            , sortUsing: 'patBIC'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'latestDateMCALEligStrMoYr'
            , label: 'Last Eligible'
            , toolTip: 'Last Eligible'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'latestDateMcalElig'
            , sortUsing: 'latestDateMcalElig'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });
        
        opts.fieldDefinitions.push({
            name: 'pgContacts'
            , label: 'Parent/Guardian Contacts'
            , toolTip: 'Parent Guardian Contacts'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'pre'
            , additionalCssClassesForCellValue: 'mba-rest-view-cell-value-no-overflow'
        });

        opts.fieldDefinitions.push({
              name: 'notes'
            , label: 'Outreach Notes'
            , toolTip: 'Please enter any notes related to outreach'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'notes'
            , sortUsing: 'notes'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });


        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        <%//***** Cell (Column) Creation Hooks ****%>

        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {

            if (fieldDefinition.name === 'notes') {
                $($newCellValue).attr('size', '35');
            }

            else if (fieldDefinition.name === 'name') {
                $($newCellValue).wrap('<a href="#" class="mba-rest-view-drill-down"></a>');
                $($newCellValue).append($('<i class="fas fa-link fa-sm ml-1"></i>'));

                $($newCellValue).closest('a').on("click", function () {
                    let reqUrl = '<%=urlEditPatInfo%>' + rowData.id;

                    let newWindowName = 'editpat-' + rowData.id;
                    $($restViewCtrl).MBA_RestView("openWindow", {
                        url: reqUrl
                        , windowName: newWindowName
                        , refreshView: true
                    });
                });
            }
            else {

            }

            /* Return cell new as required */
            return newCell;
        };

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

<%/**************************************************************************************************************************/%>

    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl       = $('#restView');

        initView();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
    });

</script>