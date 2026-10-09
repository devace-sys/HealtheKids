<%@ Page Language="C#" CodeBehind="user_all_cde_compliance_details_by_service_manage.aspx.cs" Inherits="Spedmon.UserAllCdeComplianceDetailsByServiceManage"%>

<div id="dataManagementRows" class="container-fluid">    
    
<div class="row">
  <div class="col-12">
    <div class="alert alert-light text-center"><%=Messages.SPED_DATA_CACHED_INFO %></div>
  </div> <!-- col -->  
</div>  

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
    <%// PCAL Rating Code                                                            %>
    <%//-----------------------------------------------------------------------------%>
    
    <div class="col-6">
     
        <span>Plan Implementation Compliance - By Student</span>
        <Spedmon:DataEntryBoxSelect id="pcrfp" name="pcrfp" label="" runat="server" />
      
    </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// Show Over Delivery                                                          %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-6">
        <div class="d-flex justify-content-end">
        <Spedmon:SelectYesIsTrueNoIsBlank ID="svcovrdlv" name="svcovrdlv" labelIsSpan="true" title="ONLY SHOW Services That Are Possibly Over Delivered" runat="server" />
        </div>
    </div> <!-- col -->
    </div> <!-- row -->

    
    <div class="row mt-2">

    <%//-----------------------------------------------------------------------------%>
    <%// Site                                                                        %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-4">

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
    <%// CALPADS Service                                                             %>
    <%//-----------------------------------------------------------------------------%>
  
    <div class="col-4">
       <Spedmon:DataEntryRowSelectSpEdServiceCode
           ID                   = "selectSpEdSvcCode"
           entityControlID      = "spedservicecode"
           rowLabel             = "CALPADS Service"
           dataEntryRowRenderAs = "FIELD"
           entryInitiallyHidden = "false"
           showClearSelection   = "true"
           runat                = "server">
       </Spedmon:DataEntryRowSelectSpEdServiceCode>
    </div> <!-- col -->      

   <%//-----------------------------------------------------------------------------%>
   <%// Patient                                                                     %>
   <%//-----------------------------------------------------------------------------%>

   <div class="col-4">
      <Spedmon:DataEntryRowSelectPatient
          ID                   = "selectPatient" 
          entityControlID      = "patid"                
          rowLabel             = "Student"
          dataEntryRowRenderAs = "FIELD"
          entryInitiallyHidden = "false"
          showClearSelection   = "true"
          runat                = "server">
      </Spedmon:DataEntryRowSelectPatient>
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

    /************************************************************************************************************************* */

    let $dataManagementRows  = null;
    let $restViewCtrl        = null;

    const PARM_NAME_CLIENT_ID                = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_SITE_ID                  = '<%=Constants.PARM_SITE_ID%>';
    const PARM_NAME_PATIENT_ID               = '<%=Constants.PARM_PATIENT_ID%>';
    const PARM_NAME_START_DATE               = '<%=Constants.PARM_START_DATE%>';
    const PARM_NAME_END_DATE                 = '<%=Constants.PARM_END_DATE%>';
    const PARM_NAME_SPED_SVC_CODE            = '<%=Constants.PARM_SPED_SERVICE_CODE%>';
    const PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED = '<%=Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED%>';
    const PARM_NAME_SVC_TRACKING_CLASS       = '<%=Constants.PARM_SVC_TRACKING_CLASS%>';
    const PARM_NAME_GRP_SVC_CLS_NME_ID       = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    const PARM_NAME_REF_SCREEN               = '<%=Constants.PARM_REF_SCREEN%>';

    const PARM_NAME_PCAL_COMPLIANCE_RATING_FOR_PAT = '<%=Constants.PARM_PCAL_COMPLIANCE_RATING_FOR_PAT%>';
    const PARM_NAME_OVER_DELIVER                   = '<%=Constants.PARM_SVC_OVER_DELIVERY%>';

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
        let VALUE_PAT_ID           = $('#' + PARM_NAME_PATIENT_ID).val();
        let VALUE_SPED_SVC_CODE    = $('#' + PARM_NAME_SPED_SVC_CODE).val();
        let VALUE_PCAL_RATING_CODE = $('#' + PARM_NAME_PCAL_COMPLIANCE_RATING_FOR_PAT).val();
        let VALUE_OVER_DELIVER     = $('#' + PARM_NAME_OVER_DELIVER).val();

        let NV_CLIENT_ID        = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_SITE_ID          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SITE_ID, VALUE_SITE_ID);
        let NV_PAT_ID           = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PATIENT_ID, VALUE_PAT_ID);
        let NV_SPED_SVC_CODE    = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SPED_SVC_CODE, VALUE_SPED_SVC_CODE);
        let NV_PCAL_RATING_CODE = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PCAL_COMPLIANCE_RATING_FOR_PAT, VALUE_PCAL_RATING_CODE);
        let NV_OVER_DELIVER     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_OVER_DELIVER, VALUE_OVER_DELIVER);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SITE_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SPED_SVC_CODE);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PCAL_RATING_CODE);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_OVER_DELIVER);

        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

    };

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
        opts.baseUrlView               = '<%=Spedmon.CdeComplianceBucketDetailsByService.URL_REST_VIEW()%>';
        opts.baseUrlViewHasParameters  = true;
        opts.defaultPageRowOrder       = '<%=Spedmon.CdeComplianceBucketDetailByService.DEFAULT_PAGING_ORDER%>';
        opts.enableReports             = true;
        opts.enableReportHtml          = true;
        opts.enableReportXls           = true;
        opts.enableReportPdf           = false;

        opts.loadModeReport             = 'mbawebreport';
        opts.baseUrlReport              = '<%=Spedmon.CdeComplianceCommon.URL_WEB_REPORT()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber        = '<%=Spedmon.CdeComplianceViw.REPT_NUM_VIEW_DETAILS_BY_SERVICE%>';

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
            name: 'spEdServiceCodeAndName'
            , label: 'Service'
            , toolTip: 'Service promised in IEP/IFSP'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdServiceCode'
            , additionalCssClassesForCol: 'text-left'
            , additionalCssClassesForColTop: 'text-left'
            , additionalCssClassesForColLabel: 'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue: 'text-left'

        });

        opts.fieldDefinitions.push({
            name: 'startDateStr'
            , label: 'Plan<br>Start<br>Date'
            , toolTip: 'Plan started on'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'startDate'
        });

        opts.fieldDefinitions.push({
            name: 'endDateStr'
            , label: 'Plan<br>End<br>or<br>Current<br>Date'
            , toolTip: 'Plan ended on or current date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'endDate'
        });
        
        opts.fieldDefinitions.push({
            name: 'totMinsExpected'
            , label: 'Minutes<br>Expected<br>To Date'
            , toolTip: 'Minutes expected to date in IEP/IFSP'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'totMinsExpected'
        });

        opts.fieldDefinitions.push({
            name: 'totMinsApplicable'
            , label: 'Minutes<br>Satisfied<br>To Date'
            , toolTip: 'Minutes recorded that can be applied towards service compliance'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'totMinsApplicable'
        });

        opts.fieldDefinitions.push({
            name: 'totMinsDiff'
            , label: 'Minutes<br>Missing<br>To Date'
            , toolTip: 'Remaining minutes that may need to be recorded'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'totMinsDiff'
        });

        opts.fieldDefinitions.push({
              name: 'pctExpectedApplicableStr'
            , label: 'Percentage<br>Satisfied<br>To Date'
            , toolTip: 'Percentage of minutes satisfied'
            , visible: true 
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'pctExpectedApplicable'
        });

        opts.fieldDefinitions.push({
            name: 'numSvcRecs'
            , label: 'Sessions<br>Documented'
            , toolTip: 'Sessions documented in SpEdCare'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'numSvcRecs'
        });

        opts.fieldDefinitions.push({
            name: 'pctAbsencePatStr'
            , label: 'Percent<br>Sessions<br>Documented<br>Student<br>Absent'
            , toolTip: 'Sessions documented in SpEdCare where attendance status indicated patient was absent'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'pctAbsencePat'
        });

        opts.fieldDefinitions.push({
            name: 'pctAbsencePracStr'
            , label: 'Percent<br>Sessions<br>Documented<br>Practitioner<br>Absent'
            , toolTip: 'Sessions documented in SpEdCare where attendance status indicated practitioner was absent'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'pctAbsencePrac'
        });

        opts.fieldDefinitions.push({
            name: 'pctAbsenceStr'
            , label: 'Percent<br>Sessions<br>Documented<br>Absent'
            , toolTip: 'Sessions documented in SpEdCare where attendance status indicated patient or practitioner was absent'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'pctAbsence'
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
            name: 'caseLoadAssignmentsForSpEdSvcSummaryHTML'
            , label: 'Current Caseload Assignment(s) For This Service Plan Itself'
            , toolTip: 'Practitioners that have this student currently assigned to their caseload in SpEdCare and are tracking the service plan itself.'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'string'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'spEdServiceCodeAndName'
            , label: 'Service'
            , toolTip: 'Service promised in IEP/IFSP'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdServiceCode'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'spEdFreqName'
            , label: 'Frequency'
            , toolTip: 'Frequency of Service Delivery'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdFreqName'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'minsPerFreq'
            , label: 'Minutes Per Frequency'
            , toolTip: 'How Many Minutes Promised Per Period of Delivery'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'minsPerFreq'
        });
        
        opts.additionalInfoFieldDefinitions.push({
            name: 'planStartDateStr'
            , label: 'Plan Start Date'
            , toolTip: 'Date Services Start'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'planStartDate'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'planEndDateStr'
            , label: 'Plan End Date'
            , toolTip: 'Date Services End'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'planEndDate'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'spEdExitedSpEdDateStr'
            , label: 'Exited SpEd Date'
            , toolTip: 'The patient exited special education on this date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'spEdExitedSpEdDate'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'patID'
            , label: 'SpEdCare PatID'
            , toolTip: 'SpEdCare Patient ID'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'lastfirst'
            , saveUsing: ''
            , sortUsing: 'patName'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'numSvcRecs'
            , label: 'Sessions Documented'
            , toolTip: 'Sessions documented in SpEdCare'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'numSvcRecs'
        });

        opts.additionalInfoFieldDefinitions.push({
              name: 'numPatAbsentTot'
            , label: 'Sessions Documented - Student Absent'
            , toolTip: 'Sessions documented in SpEdCare where student was marked absent'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'numPatAbsentTot'
        });

        opts.additionalInfoFieldDefinitions.push({
            name: 'numPracAbsentTot'
            , label: 'Sessions Documented - Practitioner Absent'
            , toolTip: 'Sessions documented in SpEdCare where practitioner was marked absent'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'numPracAbsentTot'
        });
        
        opts.additionalInfoFieldDefinitions.push({
            name: 'numAbsentTot'
            , label: 'Sessions Documented - Absent'
            , toolTip: 'Sessions documented in SpEdCare where student or practitioner was marked absent'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'numAbsentTot'
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
                    let $ssidAndDob = $('<br><sub>SSID: ' + rowData.patSSID + '<br>DOB: ' + rowData.patDOBStr + '</sub>');

                    $($newCellValue).attr('title', 'Review missing services');
                    $($newCellValue).wrap('<a href="#" class="mba-rest-view-drill-down"></a>');
                    $($newCellValue).append($('<i class="fas fa-link fa-sm ml-1"></i>'));
                    $($newCellValue).append($ssidAndDob);
                    $($newCellValue).closest('a').on("click", function () {
                        let parms = [];
                        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, rowData.clientID));
                        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PATIENT_ID, rowData.patID));
                        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_START_DATE, rowData.startDateStr));
                        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_END_DATE, rowData.endDateStr));
                        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED, '<%=Constants.SPED_ALL_SPED%>'));
                        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_SVC_TRACKING_CLASS, '100'));
                        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_REF_SCREEN, '<%=Spedmon.MissingServicesTreatmentsForAPatient.REF_PATIENTS_PROMISED_SERVICES_CDE_AUDIT%>'));
                        parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_SPED_SVC_CODE, rowData.spEdServiceCode));

                        let reqUrl = MBA.ComponentCommon.fnBuildUrl('<%=Spedmon.MissingServicesTreatmentsForAPatient.URL_PAGE_MANAGE_BASE()%>', 1, parms);

                        let newWindowName = 'viewmissingtmtsvc-' + rowData.patID;
                        $($restViewCtrl).MBA_RestView("openWindow", {
                            url: reqUrl
                            , windowName: newWindowName
                            , refreshView: false
                        });
                    });

                }
                else if (fieldDefinition.name === 'siteName') {
                    let $caseMgr = $('<br><sub>Case Mgr : ' + rowData.spEdCaseManagerName + '</sub>');
                    $($newCellValue).append($caseMgr);
                }

                else if (fieldDefinition.name === 'spEdServiceCodeAndName') {
                    let $minsPerFreqAndFreq = $('<br><sub>' + rowData.minsPerFreq + ' mins ' + rowData.spEdFreqName + '</sub>');
                    let $caseloadAssigned = $('<br><sub>On Caseload For Service Plan? : ' + rowData.hasCaseloadAssignmentsForSpEdSvcStr +'</sub>')
                    $($newCellValue).append($minsPerFreqAndFreq);
                    $($newCellValue).append($caseloadAssigned);
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