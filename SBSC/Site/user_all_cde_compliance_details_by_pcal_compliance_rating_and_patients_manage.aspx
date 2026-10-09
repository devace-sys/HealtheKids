<%@ Page Language="C#" CodeBehind="user_all_cde_compliance_details_by_pcal_compliance_rating_and_patients_manage.aspx.cs" Inherits="Spedmon.UserAllCdeComplianceDetailsByPcalComplianceRatingAndPatientsManage"%>

<div id="dataManagementRows" class="container-fluid">    

<div class="row">
  <div class="col-12">
    <div class="alert alert-light text-center"><%=Messages.SPED_DATA_CACHED_INFO %></div>
  </div> <!-- col -->    
</div> <!-- row -->

<div class="row">    
   
    <%//-----------------------------------------------------------------------------%>
    <%// Select Client                                                               %>
    <%// (Practi-Cal staff only)                                                     %>
    <%//-----------------------------------------------------------------------------%>
 
    <div class="col-12">
        
      <Spedmon:DataEntryRowSelectClient
          ID                   = "selectClient" 
          entityControlID      = "clientid"                
          rowLabel             = "Client"
          dataEntryRowRenderAs = "FIELD"
          entryInitiallyHidden = "false"
          runat                = "server">
      </Spedmon:DataEntryRowSelectClient>

    </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// Site                                                                        %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-6">

      <Spedmon:DataEntryRowSelectSchoolSite
          ID                             = "selectSite"
          entityControlID                = "siteid"
          rowLabel                       = "Site"      
          dataEntryRowRenderAs           = "FIELD"
          showClearSelection             = "true"
          runat                          = "server">
      </Spedmon:DataEntryRowSelectSchoolSite>
  
    </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// PCAL Rating Code                                                            %>
    <%//-----------------------------------------------------------------------------%>
    
    <div class="col-6">
        <div class="d-flex justify-content-end">
          <div class="text-left">
          <span>Plan Implementation Compliance - By Student</span>
          <Spedmon:DataEntryBoxSelect id="pcrfp" name="pcrfp" label="" runat="server" />
          </div>
        </div>
    </div> <!-- col -->

  </div> <!-- row -->
  
  
  
<div class="row mt-3">

  <%//-----------------------------------------------------------------------------%>
  <%// Rest View  %>  
  <%//-----------------------------------------------------------------------------%>

  <div class="col-12">
      <div id="restview"></div>
  </div> <!-- col -->
</div> <!-- row -->

</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    <%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

    let $dataManagementRows  = null;
    let $restViewCtrl        = null;

    const PARM_NAME_CLIENT_ID                      = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_SITE_ID                        = '<%=Constants.PARM_SITE_ID%>';
    const PARM_NAME_PATIENT_ID                     = '<%=Constants.PARM_PATIENT_ID%>';
    const PARM_NAME_PCAL_COMPLIANCE_RATING_FOR_PAT = '<%=Constants.PARM_PCAL_COMPLIANCE_RATING_FOR_PAT%>';

   <%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

    function openPatientEditScreen(clientid, patid, patScreenTabID) {
        if (!clientid) return;
        if (!patid) return;
        let urlBase = '<%=patEditUrlBase%>' + patid;
            let parms = [];
            parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_CLIENT_ID%>', clientid));
        if (patScreenTabID) parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_TAB_TO_OPEN%>', patScreenTabID));
        let reqUrl = MBA.ComponentCommon.fnBuildUrl(urlBase, true, parms);
        return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
    };

    <%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

        let VALUE_CLIENT_ID        = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_SITE_ID          = $('#' + PARM_NAME_SITE_ID).val();
        let VALUE_PCAL_RATING_CODE = $('#' + PARM_NAME_PCAL_COMPLIANCE_RATING_FOR_PAT).val();

        let NV_CLIENT_ID        = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_SITE_ID          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SITE_ID, VALUE_SITE_ID);
        let NV_PCAL_RATING_CODE = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PCAL_COMPLIANCE_RATING_FOR_PAT, VALUE_PCAL_RATING_CODE);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SITE_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PCAL_RATING_CODE);

        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

    };

    <%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

    function initView() {

        let opts = {};

        opts.sessionTimeOutUrl         = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad         = false; 
        opts.enableSortControls        = true;
        opts.enableRowNumbers          = false;
        opts.enableRowControls         = true;
        opts.enableRowControlShowAdditionalInfo = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit   = false;
        opts.enableRowControlRecDelete = false;
        opts.loadModeView              = 'rest';
        opts.baseUrlView               = '<%=Spedmon.CdeComplianceBucketDetailsByPcalComplianceRatingAndPatients.URL_REST_VIEW()%>';
        opts.baseUrlViewHasParameters  = true;
        opts.defaultPageRowOrder       = '<%=Spedmon.CdeComplianceBucketDetailsByPcalComplianceRatingAndPatient.DEFAULT_PAGING_ORDER%>';
        opts.enableReports             = true;
        opts.enableReportHtml          = true;
        opts.enableReportXls           = true;
        opts.enableReportPdf           = false;

        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = '<%=Spedmon.CdeComplianceCommon.URL_WEB_REPORT()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber        = '<%=Spedmon.CdeComplianceViw.REPT_NUM_VIEW_BY_PCAL_COMP_RATING_AND_PAT_DETAILS%>';

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'clientID'
            , label: 'Client ID'
            , toolTip: 'Client ID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
            name: 'patID'
            , label: 'Patient ID'
            , toolTip: 'Patient ID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
            name: 'patName'
            , label: 'Student'
            , toolTip: 'Services Promised For'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'lastfirst'
            , sortUsing: 'patName'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'pcalComplianceRatingForPatName'
            , label: 'Plan Implementation<br>Compliance Range'
            , toolTip: 'Range that Percentage of Satisfied Over Expected Delivery To Date Falls In'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'pcalComplianceRatingForPatCode'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'siteName'
            , label: 'Site'
            , toolTip: 'Patients current site'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'siteName'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'numSvcs'
            , label: 'Number<br>Of<br>Promised<br>Services'
            , toolTip: 'Number of Promised Services'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'numSvcs'
        });


        opts.fieldDefinitions.push({
            name: 'iepCompliancePctForPat'
            , label: 'Plan Implementation<br>Compliance'
            , toolTip: 'Percentage of Satisfied Over Expected Delivery To Date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'iepCompliancePctForPat'
        });

        opts.fieldDefinitions.push({
            name: 'hasCaseloadAssignmentsStr'
            , label: 'Has<br>Caseload<br>Assignment(s)'
            , toolTip: 'Is this student assigned to one or more practitioners caseload in SpEdCare'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'hasCaseloadAssignments'
        });        

        opts.fieldDefinitions.push({
            name: 'spEdCaseManagerName'
            , label: 'Case Manager'
            , toolTip: 'Case Manager Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'spEdCaseManagerName'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'spEdExitedSpEdDateStr'
            , label: 'Exited SpEd<br>Date'
            , toolTip: 'Date student exited SpEd'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'spEdExitedSpEdDate'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'
        });
       
        opts.additionalInfoFieldDefinitions = [];

        opts.additionalInfoFieldDefinitions.push({
            name: 'patName'
            , label: 'Patient'
            , toolTip: 'Services promised for'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'lastfirst'
            , sortUsing: 'patName'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'patSSID'
            , label: 'SSID'
            , toolTip: 'Statewide Student Identifier'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'patSSID'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'patDOBStr'
            , label: 'DOB'
            , toolTip: 'Date of Birth'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'patDOB'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'spEdCaseManagerName'
            , label: 'Case Manager'
            , toolTip: 'Who is the case manager for this patient?'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdCaseManagerName'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'caseLoadAssignmentsSummaryHTML'
            , label: 'Current Caseload Assignment(s)'
            , toolTip: 'Practitioners that have this student currently assigned to their caseload in SpEdCare'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'string'
        });
        
        opts.additionalControlDefinitionsForBodyRows = new Map();

        /* ******************************************/
        /* ******** Manage Patient Record  **********/
        /* ******************************************/

        opts.additionalControlDefinitionsForBodyRows.set('editPatientProfile', {
            defType: 'userprovided'
            , name: 'editPatientProfile'
            , toolTip: 'Click here to view related services and optionally edit patient (student) profile'
            , cssClass: 'fa fa-user-edit'
            , handlerFn: function (uiActionObj) {
                let cltid = uiActionObj.whatFieldNameValues['clientID'];
                let patid = uiActionObj.whatFieldNameValues['patID'];
                openPatientEditScreen(cltid, patid, 'tab-promised-services');
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
            if ((subsection === 103) && (rowtype === 4)) {

                if (fieldDefinition.name === 'patName') {
                    let $ssidAndDob = $('<br><sub>SSID: ' + rowData.patSSID + ' DOB: ' + rowData.patDOBStr + '</sub>');

                    $($newCellValue).attr('title', 'Review promised services for this student');
                    $($newCellValue).wrap('<a href="#" class="mba-rest-view-drill-down"></a>');
                    $($newCellValue).append($('<i class="fas fa-link fa-sm ml-1"></i>'));
                    $($newCellValue).append($ssidAndDob);
                    $($newCellValue).closest('a').on("click", function () {
                        let parms = [];
                        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, rowData.clientID));
                        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PATIENT_ID, rowData.patID));

                        let reqUrl = MBA.ComponentCommon.fnBuildUrl('<%=Spedmon.CdeComplianceBucketDetailsByService.URL_PAGE_MANAGE(true)%>', 1, parms);

                        let newWindowName = 'viewpromisedsvcdetailsforpat-' + rowData.patID;
                        $($restViewCtrl).MBA_RestView("openWindow", {
                            url: reqUrl
                            , windowName: newWindowName
                            , refreshView: false
                        });
                    });

                }                
            }

            /* Return cell new as required */
            return newCell;
        };


        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    $(document).ready(function () {

        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl       = $('#restview');
        initView();        

        $($dataManagementRows).on('spedmoninputdata', function (e) {        
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        $('#pcrfp').on('change', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

    });

</script>