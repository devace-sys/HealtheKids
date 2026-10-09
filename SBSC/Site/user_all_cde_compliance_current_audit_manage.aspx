<%@ Page Language="C#" CodeBehind="user_all_cde_compliance_current_audit_manage.aspx.cs" Inherits="Spedmon.UserAllCdeComplianceCurrentAuditManage"%>


<%//##################################################################################################################%>
<%//# Dashboard  %>
<%//##################################################################################################################%>

<%/* CDE Implementation SWD Plan Implementation (Reported to CDE)*/%>

<div id="selectParamsForAudit" class="container-fluid">

  <div class="row">

    <%//-----------------------------------------------------------------------------%>
    <%// Select Client %>
    <%// (Practi-Cal staff only) %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-3">

    <Spedmon:DataEntryRowSelectClient
        ID                   = "selectClient"
        entityControlID      = "clientid"
        rowLabel             = "Client"
        dataEntryRowRenderAs = "FIELD"
        runat                = "server">
    </Spedmon:DataEntryRowSelectClient>


    </div> <!-- col -->

    <%//-----------------------------------------------------------------------------%>
    <%// Page Title %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-6">
       <h3 class="text-center"><%=Spedmon.CdeComplianceCommon.SEL_LABEL_CURRENT_AUDIT%></h3>
    </div>

    <%//-----------------------------------------------------------------------------%>
    <%// Goto Manage Overall %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-3">
      <div class="d-flex justify-content-end">
        <Spedmon:LinkInternal
           ID         = "gotomanageoverall"
           title       = "Manage Current Year"
           label       = "Manage Current Year"
           faClass    = "fa fa-link"
           openNew   = "false"
           subWindow = "false"
           runat     = "server" />
      </div>
    </div> <!-- col -->

  </div> <!-- row -->

  <div class="row">

    <%//-----------------------------------------------------------------------------%>
    <%// Data Update Frequency Message %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-9">
        <div class="alert alert-light"><%=Messages.SPED_DATA_REAL_TIME_INFO %> 
        <strong> Data updates and recalculations may take some time depending on the number of students in the audit.</strong>
        </div>        
    </div>

    <%//-----------------------------------------------------------------------------%>
    <%// Recalc data %>
    <%//-----------------------------------------------------------------------------%>

    <div class="col-3">
      <Spedmon:DataEntryButton ID="doRefresh" style="SUCCESS" fireSpedmonInput="false" faIcon="fas fa-sync" label="Update & Recalculate Data Required for Audit" title="Click to recalculate data" onclick="updateAdditionalViewParameterValuesAndRequestPatPromisedSvcsViewFromServer(e)"  runat="server"/>
    </div> 

  </div> <!-- row -->
  

  <div class="row mt-3">

    <div class="col-4">
  
       <div class="mba-action-items-container p-2">
       <h3 class="mba-action-item-common mba-action-item-common-label">CDE Audit Period</h3>
       <br>

        <%//-----------------------------------------------------------------------------%>
        <%// Select Audit Period Start %>
        <%//-----------------------------------------------------------------------------%>

        <Spedmon:DataEntryBoxDate ID="startdate" name="startdate" label="Start Date" title="Start Date of Audit Period" runat="server" />

        <%//-----------------------------------------------------------------------------%>
        <%// Select Audit Period End %>
        <%//-----------------------------------------------------------------------------%>

        <Spedmon:DataEntryBoxDate ID="enddate" name="enddate" label="End Date" title="End Date of Audit Period" runat="server" />

	    <%//-----------------------------------------------------------------------------%>
        <%// Save Period %>
        <%//-----------------------------------------------------------------------------%>

        <button type="button" id="butDoSaveCurrentAuditPeriodData" class="btn btn-primary ml-2">
          <span>Save</span>
          <i class="fas fa-save ml-2"></i>
        </button>

      </div> <!-- action items -->
    
      <div class="mba-action-items-container mt-2 p-2">
        <h3 class="mba-action-item-common mba-action-item-common-label">Service Delivery Deferrals</h3>
        
         <Spedmon:LinkInternal 
            ID         = "gotomanageservicedeliveryexceptions" 
            title      = "Click Here to Review Service Delivery Deferrals" 
            label      = "Review Service Delivery Deferrals"
            faClass    = "fa fa-link"               
            openNew    = "true"  
            subWindow  = "true"
            runat      = "server" />

        </div> <!-- action item -->

    
    </div> <!-- col -->
   
    <div class="col-6">
      
    <div class="mba-action-items-container p-2">

      <%//-----------------------------------------------------------------------------%>
      <%// Bucket Summary %>
      <%//-----------------------------------------------------------------------------%>

      <section id="cdesuccessbuckets"></section>
     
      <%//-----------------------------------------------------------------------------%>
      <%// Select if patient absenses count as minutes satisfied minutes  %>
      <%//-----------------------------------------------------------------------------%>
    
      <div class="text-center">
      
       <Spedmon:SelectYesIsNoOrNoIsYes 
         ID                = "patabsentminsaresatisfiedmins" 
         name              = "patabsentminsaresatisfiedmins"                   
         title             = "Are You Ready to Submit Data To CDE?"
         renderLabel       = "true"
         firedataselected  = "true"           
         runat             = "server" />        

        <sub class="m-0 p-0">
        Clicking on Yes will apply the <a href="<%=Spedmon.CdeComplianceCommon.URL_PDF_CDE_REQUIRMENTS%>" target="_blank">latest reporting requirements</a> from CDE regarding student absences to the buckets shown above.
        These changes regarding student absences WILL NOT be reflected in the details shown below or in any reports.
        </sub>
      
      </div>
        
    </div> <!-- cont -->

    </div> <!-- col- -->

    <%//-----------------------------------------------------------------------------%>
    <%//   // Performance Reports %>
    <%//-----------------------------------------------------------------------------%>
    
    <div class="col-2">


    <div class="mba-action-items-container p-2">
    <h3 class="mba-action-item-common mba-action-item-common-label text-center">Download Reports</h3>
    <Spedmon:DataEntryBoxSelectReportFormat ID="perrptfmt" name="perrptfmt" title="Select File Format" label="Select File Format" includePDF="true" runat="server" />
    <h4 class="mba-action-item-common-sub-label mt-1 mb-1">District Wide Performance By : </h4>
    <Spedmon:DataEntryButton ID="doDownloadPerfReptByBucket"  style="SECONDARY" size="SMALL" cssClass="mr-1" fireSpedmonInput="false" label="Bucket" title="Click to download.  Please note it may take some time to generate the report depending on the number of students in the audit." onclick="downloadPerfReptByBucket(e)" runat="server"/>
    <Spedmon:DataEntryButton ID="doDownloadPerfReptBySvc" style="SECONDARY" size="SMALL" fireSpedmonInput="false"  label="Service" title="Click to download.  Please note it may take some time to generate the report depending on the number of students in the audit." onclick="downloadPerfReptBySvc(e)" runat="server"/>
    <h4 class="mba-action-item-common-sub-label mt-1 mb-1">Site Specific Performance By : </h4>
    <Spedmon:DataEntryButton ID="doDownloadPerfReptBySiteBucket" style="SECONDARY" size="SMALL" cssClass="mr-1" fireSpedmonInput="false"  label="Bucket" title="Click to download.  Please note it may take some time to generate the report depending on the number of students in the audit." onclick="downloadPerfReptBySiteBucket(e)" runat="server"/>    
    <Spedmon:DataEntryButton ID="doDownloadPerfReptBySiteSvc" style="SECONDARY" size="SMALL" fireSpedmonInput="false"  label="Service" title="Click to download.  Please note it may take some time to generate the report depending on the number of students in the audit." onclick="downloadPerfReptBySiteSvc(e)" runat="server"/>
    </div> 
    </div> <!-- col -->

  </div> <!-- row -->

  <div class="row mt-3">

    <div class="col-12">

    <div class="mba-action-items-container p-2">
    <h3 class="mba-action-item-common mba-action-item-common-label text-center">Students</h3>
        
    <%//-----------------------------------------------------------------------------%>
    <%// Import Patients Results %>
    <%//-----------------------------------------------------------------------------%>
     
    <div id="uploadStudentsDetails">
       <details id="uploadStudentDetails" title="Click to show/hide additional information" class="text-danger font-weight-bolder mb-3">
       <summary id="uploadStudentsSummary"></summary>                  
       
       <%//-----------------------------------------%>
       <%// Reprocess Import Button (Only for PCAL) %>
       <%//-----------------------------------------%>
    
       <%if (userIsPcalStaff == true) {%>
       <Spedmon:DataEntryButton ID="butDoReprocessPatientDataImport" style="SECONDARY" size="SMALL" fireSpedmonInput="false" faIcon="fas fa-history" label="Reprocess Last File Imported" title="Click to reprocess and refresh" onclick="doReprocessPatientDataImport(e)" cssClass="mt-3"  runat="server"/>
       <%}%>

       <div id="uploadStudentsContent" class="mt-1">       
       </div>
       <hr />
     </details>
    </div>

    <div class="mt-1">

    <%//-----------------------------------------------------------------------------%>
    <%// Select Patient %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectPatient
        ID                   = "dataEntryRowSelectPatient"
        dataEntryRowRenderAs = "FIELD"
        rowLabel             = "Select A Student To Add to Audit"
        runat                = "server">
    </Spedmon:DataEntryRowSelectPatient>

    
    <%//-----------------------------------------------------------------------------%>
    <%// Import Patients %>
    <%//-----------------------------------------------------------------------------%>

     <button type="button" id="butDoUploadStudents" class="btn btn-secondary ml-2" title="Click here to upload the file of students from the CDE">
       <span>Upload Students From CDE Data File</span>
       <i class="ml-2 fa fa-upload"></i>
     </button>
    
    <%//-----------------------------------------------------------------------------%>
    <%// Import User Entered Stat Data (PCAL Staff Only)                             %>
    <%//-----------------------------------------------------------------------------%>

    <%if(userIsPcalStaff == true) {%>   
      <Spedmon:DataEntryButton ID="butDoImportUserEnteredStats" style="SECONDARY" fireSpedmonInput="false" cssClass="ml-2" faIcon="fa fa-upload" label="Import Promised Service Summaries" title="Click to import data added to user provided total satisfied or percent columns" onclick="doImportUserEnteredStats(e)" runat="server"/>
    <%}%>

    <%//-----------------------------------------------------------------------------%>
    <%// Promised Service Summary for all Patients in Audit %>
    <%//-----------------------------------------------------------------------------%>
     
     <Spedmon:DataEntryButton ID="doExportPromisedServiceSummary"  style="SUCCESS" fireSpedmonInput="false" cssClass="ml-2" faIcon="fa fa-file-excel" label="Export All Promised Service Summaries" title="Click to download.  Please note it may take some time to generate the report depending on the number of students in the audit." onclick="downloadPromisedServiceSummary(e)"  runat="server"/>

   </div>
      
   <%//-----------------------------------------------------------------------------%>
   <%// Rest View  %>
   <%//-----------------------------------------------------------------------------%>

   <div class="mt-3">
   <div id="restViewPatPromisedSvcs"></div>
   </div>

   </div> <!-- Action item -->
    </div> <!-- col -->


  </div> <!-- row -->

 
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    const PARM_NAME_CLIENT_ID                          = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_PATIENT_ID                         = '<%=Constants.PARM_PATIENT_ID%>';
    const PARM_NAME_START_DATE                         = '<%=Constants.PARM_START_DATE%>';
    const PARM_NAME_END_DATE                           = '<%=Constants.PARM_END_DATE%>';
    const PARM_NAME_SPED_SVC_CODE                      = '<%=Constants.PARM_SPED_SERVICE_CODE%>';
    const PARM_NAME_LEA_BOP_ONLY_OR_ALL_SPED           = '<%=Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED%>';
    const PARM_NAME_SVC_TRACKING_CLASS                 = '<%=Constants.PARM_SVC_TRACKING_CLASS%>';
    const PARM_NAME_GRP_SVC_CLS_NME_ID                 = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    const PARM_NAME_REF_SCREEN                         = '<%=Constants.PARM_REF_SCREEN%>';
    const PARM_NAME_PPS_CDE_AUDIT_CUR_PAT_ID           = '<%=Constants.PARM_PPS_CDE_AUDIT_CUR_PAT_ID%>';
    const PARM_NAME_PAT_ABSENT_MINS_ARE_SATISFIED_MINS = '<%=Constants.PARM_PAT_ABSENT_MINS_ARE_SATISFIED_MINS%>';

    const URL_SESSION_EXPIRED_LINK           = '<%=MBA.Credential.generateSessionExpiredLink()%>';
    const URL_WEB_SVC_CURR_AUDIT_PERIOD_GET  = '<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_GET()%>';
    const URL_WEB_SVC_CURR_AUDIT_PERIOD_SAVE = '<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_SAVE()%>';
    const URL_WEB_SVC_CURR_AUDIT_PAT_SAVE    = '<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_PATIENT_SAVE()%>';

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    let $selectParamsForAudit                = null;
    let $butDoSaveCurrAuditPeriod            = null;
    let $restViewPatPromisedSvcs             = null;
    let $butDoUploadStudents                 = null;
    let $dashboardItemCdeSuccessBuckets      = null;
    let $inpStartDate                        = null;
    let $inpEndDate                          = null;
    let $linkGotoManageCurrentYear           = null;
    let $linkManageServiceDeliveryExceptions = null;
    let $uploadStudentsDetails               = null;
    let $uploadStudentsSummary               = null;
    let $uploadStudentsContent               = null;
    let $doExportPromisedServiceSummary      = null;
    let $doRefresh                           = null;
    let $butDoReprocessPatientDataImport     = null;
    let $uploadStudentDetails                = null;
    let $butDoImportUserEnteredStats         = null;
    let $rbPatAbsMinsAreSatMins              = null;
    
    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadPerfRept(e,rptNum) {
        let rptFmt = 3;
        rptFmt = $('#perrptfmt').val();
        let elem = e.target;
        let reqUrl = '<%=Spedmon.CdeComplianceCommon.URL_WEB_REPORT()%>';
        let reqData = [
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_CLIENT_ID%>", $("#<%=Constants.PARM_CLIENT_ID%>").val()),
        ];
        MBA.ComponentCommon.fnElemDoRequestDownloadWebReportDocument(elem, reqUrl, rptFmt, rptNum, 'Perf_Rpt_' + rptNum + '_' + rptFmt, reqData
            , function () { return; }
            , function () { return; });
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadPerfReptBySiteSvc(e) {
        let rptNum = <%=Spedmon.CdeComplianceViw.REPT_NUM_VIEW_PERFORMANCE_BY_SITE_SERVICE_SUMMARY%>;
        downloadPerfRept(e, rptNum);
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadPerfReptBySiteBucket(e) {
        let rptNum = <%=Spedmon.CdeComplianceViw.REPT_NUM_VIEW_PERFORMANCE_BY_SITE_BUCKET_SUMMARY%>;
        downloadPerfRept(e, rptNum);
    };
    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadPerfReptBySvc(e) {
        let rptNum = <%=Spedmon.CdeComplianceViw.REPT_NUM_VIEW_PERFORMANCE_SERVICE_SUMMARY%>;
        downloadPerfRept(e, rptNum);
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadPerfReptByBucket(e) {
        let rptNum = <%=Spedmon.CdeComplianceViw.REPT_NUM_VIEW_PERFORMANCE_BUCKET_SUMMARY%>;
        downloadPerfRept(e, rptNum);
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadPromisedServiceSummary (e) {

        let elem = e.target;
        let rptNum = <%=Spedmon.CdeComplianceViw.REPT_NUM_VIEW_PATIENTS_PROMISED_SERVICES_CDE_AUDIT_CURRENT%>;

        let reqUrl = '<%=Spedmon.CdeComplianceCommon.URL_WEB_REPORT()%>';
        let reqData = [
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_CLIENT_ID%>", $("#<%=Constants.PARM_CLIENT_ID%>").val()),
        ];
        MBA.ComponentCommon.fnElemDoRequestDownloadWebReportDocument(elem, reqUrl, 3, rptNum, 'Promised_Svc_Summary_Rpt_' + rptNum, reqData
            , function () { return; }
            , function () { return; });
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function disableInputFields() {
        $.spedmonWebUI.dialogWaitShow('Please wait while SpEdCare calculates the data required for the audit.  This may take some time depending on the number of students in the audit.  Please note that information regarding issues with CDE file imports (if any) will not be shown until the CDE Success Buckets has completed calculating.');
        $($inpStartDate).MBA_DataEntryBox('disable');
        $($inpEndDate).MBA_DataEntryBox('disable');
        MBA.ComponentCommon.fnDisableElement($butDoSaveCurrAuditPeriod);
        MBA.ComponentCommon.fnDisableElement($butDoUploadStudents);
        MBA.ComponentCommon.fnDisableElement($doExportPromisedServiceSummary);
        $('#dataEntryRowSelectPatient').hide();
        MBA.ComponentCommon.fnDisableElement($doRefresh);
        MBA.ComponentCommon.fnDisableElement($butDoImportUserEnteredStats);
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function enableInputFields() {
        $($inpStartDate).MBA_DataEntryBox('enable');
        $($inpEndDate).MBA_DataEntryBox('enable');
        MBA.ComponentCommon.fnEnableElement($butDoSaveCurrAuditPeriod);
        MBA.ComponentCommon.fnEnableElement($butDoUploadStudents);
        MBA.ComponentCommon.fnEnableElement($doExportPromisedServiceSummary);
        $('#dataEntryRowSelectPatient').show();
        MBA.ComponentCommon.fnEnableElement($doRefresh);
        MBA.ComponentCommon.fnEnableElement($butDoImportUserEnteredStats);
        $.spedmonWebUI.dialogWaitHide();        
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function getNameValueClientID () {
        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        return MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/
    
    function getNameValuePatAbsentMinsAreSatisfiedMins() {
        let VALUE_PAT_ABSENT_MINS_ARE_SATISFIED_MINS = $($rbPatAbsMinsAreSatMins).val();
        return MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PAT_ABSENT_MINS_ARE_SATISFIED_MINS, VALUE_PAT_ABSENT_MINS_ARE_SATISFIED_MINS);
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function initRestViewPatPromisedSvcs() {

        let opts = {};

        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';        
        opts.requestViewOnLoad = false;
        opts.enableSortControls = true;
        opts.enableRowNumbers = false;
        opts.enableRowControls = true;
        opts.enableRowControlShowAdditionalInfo = false;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = false;
        opts.enableRowControlRecDelete = true;
        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.PatientsPromisedServicesCDEAuditsCurrentPatients.URL_REST_VIEW()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.PatientsPromisedServicesCDEAuditsCurrentPatient.DEFAULT_PAGING_ORDER%>';
        opts.enableReports = true;
        opts.enableReportHtml = true;
        opts.enableReportXls = true;
        opts.enableReportPdf = false;
        opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport = '<%=Spedmon.CdeComplianceCommon.URL_WEB_REPORT()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '<%=Spedmon.CdeComplianceViw.REPT_NUM_VIEW_PATIENTS_CDE_AUDIT_CURRENT%>';

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = '<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_PATIENT_DELETE()%>';
        opts.baseUrlDeleteHasParameters = true;
        opts.recIDNameForDelete = 'recid';
        opts.saveTypeNameForDelete = 'savetype';
        opts.saveTypeValueForDelete = '3';

        opts.fnBeforeRequestViewFromServer = function (elem, pageNumber, $me, dataObj) {
            disableInputFields();            
        };

        opts.fnOnResponseViewFromServer = function (elem, responseData, $me, dataObj) {
            enableInputFields();
            updateDashboardItemsCdeSuccessBuckets();
        };

        opts.additionalInfoFieldDefinitions = [];

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
        });

        opts.fieldDefinitions.push({
            name: 'patID'
            , label: 'Patient ID'
            , toolTip: 'Patient ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
        });

        opts.fieldDefinitions.push({
            name: 'name'
            , label: 'Student'
            , toolTip: 'Services Promised For'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'lastfirst'
            , sortUsing: 'name'
            , additionalCssClassesForCol:'text-left'
            , additionalCssClassesForCell: 'text-left'
            , additionalCssClassesForCellValue:'text-left'
        });

        opts.fieldDefinitions.push({
            name: 'ssid'
            , label: 'SSID'
            , toolTip: 'Statewide Student Identifier'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'ssid'
        });

        opts.fieldDefinitions.push({
              name: 'siteName'
            , label: 'Site Name'
            , toolTip: 'School Site'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'siteName'
        });

        opts.fieldDefinitions.push({
              name: 'spEdCaseManagerName'
            , label: 'Case Manager'
            , toolTip: 'Case Managager Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdCaseManagerName'
        });
        
        opts.fieldDefinitions.push({
            name: 'numPlans'
            , label: 'Number<br>of<br>Services'
            , toolTip: 'Number Of Services'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'numPlans'
        });

        opts.fieldDefinitions.push({
            name: 'totMinsExpected'
            , label: 'Total Minutes<br>Expected<br>To Date'
            , toolTip: 'Total Minutes Expected To Date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'totMinsExpected'
        });

        opts.fieldDefinitions.push({
            name: 'totMinsApplicable'
            , label: 'Total Minutes<br>Satisfied<br>To Date<br><sup>(Capped at Total Expected)</sup>'
            , toolTip: 'Total Minutes Satisfied To Date.  To prevent over delivery of any service (satisfying more minutes that expected) from tainting bucket calculations, total minutes satisfied is capped to not exceed minutes expected.'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'totMinsApplicable'
        });

        opts.fieldDefinitions.push({
              name: 'pctExpectedApplicableStr'
            , label: 'Percentage<br>Satisfied<br>To Date'
            , toolTip: 'Percentage Satisfied To Date'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'pctExpectedApplicable'
        });

        /*
        opts.fieldDefinitions.push({
              name: 'totMoreThanExpectedCtr'
            , label: 'Number<br>Of<br>Over<br>Deliveries'
            , toolTip: 'How many services have more minutes satisfied than expected'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'totMoreThanExpectedCtr'
        });
        */
        /*
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
        */
        opts.fieldDefinitions.push({
            name: 'numPatAbsentTot'
            , label: 'Sessions<br>Documented<br>Student<br>Absent'
            , toolTip: 'Sessions documented in SpEdCare where attendance status indicated patient was absent'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'numPatAbsentTot'
        });

        /*
        opts.fieldDefinitions.push({
            name: 'numPracAbsentTot'
            , label: 'Sessions<br>Documented<br>Practitioner<br>Absent'
            , toolTip: 'Sessions documented in SpEdCare where attendance status indicated practitioner was absent'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'numPracAbsentTot'
        });
        */

        opts.fieldDefinitions.push({
            name: 'inCdeBucket'
            , label: 'Current<br>CDE Bucket'
            , toolTip: 'In What Bucket'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'inCdeBucket'
        });

        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
            if ((subsection === 103) && (rowtype === 4)) {

                if (fieldDefinition.name === 'inCdeBucket') {
                    let bucketClass = "";
                    if      (rowData.inCdeBucket === 'A') bucketClass = 'text-white bg-success';
                    else if (rowData.inCdeBucket === 'B') bucketClass = 'text-dark bg-warning';
                    else if (rowData.inCdeBucket === 'C') bucketClass = 'text-white bg-danger';
                    else bucketClass = '';
                    $($newCellValue).wrap('<div class="m-0 p-1 ' + bucketClass + '"></div>');
                }
                else if (fieldDefinition.name === 'name') {
                        $($newCellValue).attr('title', 'Review Promised Services');
                        $($newCellValue).wrap('<a href="#" class="mba-rest-view-drill-down"></a>');
                        $($newCellValue).append($('<i class="fas fa-link fa-sm ml-1"></i>'));
                        $($newCellValue).closest('a').on("click", function () {

                            let VALUE_START_DATE = $($inpStartDate).val();
                            let VALUE_END_DATE   = $($inpEndDate).val();

                            let parms = [];
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID,  rowData.clientID));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PATIENT_ID, rowData.patID));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_START_DATE, VALUE_START_DATE));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_END_DATE, VALUE_END_DATE));
                            parms.push(MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_PPS_CDE_AUDIT_CUR_PAT_ID, rowData.id));

                            let reqUrl = MBA.ComponentCommon.fnBuildUrl('<%=Spedmon.CdeComplianceCommon.URL_MANAGE_CURRENT_AUDIT_DETAILS_BY_PATIENT_BASE()%>', 1, parms);
                            let newWindowName = 'reviewpromisedsvcsforcdecurraudit-' + rowData.patID;
                            $($restViewPatPromisedSvcs).MBA_RestView("openWindow", {
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

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        /* Create the rest view */

        $($restViewPatPromisedSvcs).MBA_RestView(opts);

    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function updateDashboardItemsCdeSuccessBuckets() {
        let NV_CLIENT_ID                          = getNameValueClientID();
        let NV_PAT_ABSENT_MINS_ARE_SATISFIED_MINS = getNameValuePatAbsentMinsAreSatisfiedMins();
        $($dashboardItemCdeSuccessBuckets).MBA_ActionItemCdeComplianceBuckets('requestDataParameterSetOrUpdate', NV_CLIENT_ID);
        $($dashboardItemCdeSuccessBuckets).MBA_ActionItemCdeComplianceBuckets('requestDataParameterSetOrUpdate', NV_PAT_ABSENT_MINS_ARE_SATISFIED_MINS);
        $($dashboardItemCdeSuccessBuckets).MBA_ActionItemCdeComplianceBuckets('getData');
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function initDashboardItemCdeSuccessBuckets() {
        
        $($uploadStudentsDetails).hide();
        $($uploadStudentsSummary).html('');
        $($uploadStudentsContent).html('');

        let opts = {};
        opts.label = '<%=Spedmon.CdeComplianceCommon.LABEL_SUCCESS_BUCKETS%>';

        opts.requestDataUrlCurrYearBase = '<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_YEAR_GET()%>';
        opts.requestDataUrlCurrAuditBase = '<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_GET()%>';
        opts.showCurrYear = false;
        opts.rowLabelCurrAudit = '<%=Spedmon.CdeComplianceCommon.SEL_LABEL_CURRENT_AUDIT%><br>For CDE Audit Period ';
        opts.rowLabelCurrYear = '<%=Spedmon.CdeComplianceCommon.SEL_LABEL_ANNUAL%><br>For All Plans Active Between ';
        opts.colLabelBucketLabelA = '<%=Spedmon.CdeComplianceCommon.LABEL_BUCKET_A_LINES(@"<br>")%>';
        opts.colLabelBucketLabelB = '<%=Spedmon.CdeComplianceCommon.LABEL_BUCKET_B_LINES(@"<br>")%>';
        opts.colLabelBucketLabelC = '<%=Spedmon.CdeComplianceCommon.LABEL_BUCKET_C_LINES(@"<br>")%>';
        opts.colLabelTotPatsLabel = '<%=Spedmon.CdeComplianceCommon.LABEL_BUCKET_TOTAL_STUDENTS_LINES(@"<br>")%>';
        opts.fnBeforeLoadCurrentYearBucketData = function (reqDataJSON) { return; };
        opts.fnAfterLoadCurrentYearBucketData = function (responseData) { return; };

        opts.fnBeforeLoadCurrentAuditBucketData = function (reqDataJSON) {
            $($rbPatAbsMinsAreSatMins).spedmonRadioBox_Disable();
            MBA.ComponentCommon.fnDisableElement($doRefresh);
            $($uploadStudentsDetails).hide();
            $($uploadStudentsSummary).html('');
            $($uploadStudentsContent).html('');
            return;
        };

        opts.fnAfterLoadCurrentAuditBucketData = function (responseData) {

            $($rbPatAbsMinsAreSatMins).spedmonRadioBox_Enable();
            MBA.ComponentCommon.fnEnableElement($doRefresh);
            let patientsPromisedServicesCDEAuditCurrent = responseData.rawData.entity;
            if (MBA.ComponentCommon.fnHasValue(patientsPromisedServicesCDEAuditCurrent)) {
                $($inpStartDate).val(patientsPromisedServicesCDEAuditCurrent.startDateStrYMD);
                $($inpEndDate).val(patientsPromisedServicesCDEAuditCurrent.endDateStrYMD);

                let lastImportIssueCount = patientsPromisedServicesCDEAuditCurrent.lastImportIssueCount;
                if (lastImportIssueCount > 0) {
                    $($uploadStudentsDetails).show();
                    let lastPatientDataImportResultsJSON = patientsPromisedServicesCDEAuditCurrent.lastPatientDataImportResultsJSON;
                    let lastPatientDataImportResultsObj = JSON.parse(lastPatientDataImportResultsJSON);

                    let $importRowRptTable = $('<table class="table table-sm mt-3"></table>');
                    let $thead = $('<thead class="thead-light"></thead>');
                    let $tbody = $('<tbody></tbody>');
                    $($thead).append('<tr><th>Row #</th><th>Last Name</th><th>First Name</th><th>SSID</th><th>Issue</th></tr>');
                    lastPatientDataImportResultsObj.forEach((importRow) => {
                        if (importRow.HAS_IMPORT_ISSUES === true) {
                            let $importRowRptRow = $('<tr></tr>');
                            $($importRowRptRow).append('<td>' + importRow.ROW_NUM + '</td>');                            
                            $($importRowRptRow).append('<td>' + importRow.LAST_NAME + '</td>');
                            $($importRowRptRow).append('<td>' + importRow.FIRST_NAME + '</td>');
                            $($importRowRptRow).append('<td>' + importRow.SSID + '</td>');
                            $($importRowRptRow).append('<td>' + importRow.IMPORT_ISSUES + '</td>');
                            $($tbody).append($importRowRptRow);
                        }
                    });
                    $($importRowRptTable).append($thead);
                    $($importRowRptTable).append($tbody);                    
                    $($uploadStudentsContent).append($importRowRptTable);

                    $($uploadStudentsSummary).html('The last CDE file import had ' + lastImportIssueCount + ' students that could not be added to the audit data because of incomplete SpEd or patient data in SpEdCare.  Please click here to view the issues.');

                }
                else {
                    $($uploadStudentsDetails).hide();
                    $($uploadStudentsSummary).html('');
                    $($uploadStudentsContent).html('');
                }
                $($uploadStudentDetails).removeAttr('open');
            };
            
            return;
        };

        opts.useActionItemClassForCont = false;
        opts.useActionItemClassForLabel = true;

        $($dashboardItemCdeSuccessBuckets).MBA_ActionItemCdeComplianceBuckets(opts);
    };


    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function updateAdditionalViewParameterValuesAndRequestPatPromisedSvcsViewFromServer(e) {

        let VALUE_PATIENT_ID             = '';
        let NV_CLIENT_ID                 = getNameValueClientID();       
        let NV_PATIENT_ID                = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PATIENT_ID, VALUE_PATIENT_ID);

        $($linkGotoManageCurrentYear).MBA_Link('requestDataParameterSetOrUpdate', NV_CLIENT_ID);
        $($linkManageServiceDeliveryExceptions).MBA_Link('requestDataParameterSetOrUpdate', NV_CLIENT_ID);
        $($restViewPatPromisedSvcs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewPatPromisedSvcs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PATIENT_ID);

        $($restViewPatPromisedSvcs).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_CLIENT_ID);
        $($restViewPatPromisedSvcs).MBA_RestView('requestViewFromServer', 1);
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function saveCurrentAuditPeriod(e) {
        let reqDataObj = {};

        reqDataObj[PARM_NAME_CLIENT_ID]  = $('#' + PARM_NAME_CLIENT_ID).val();
        reqDataObj[PARM_NAME_START_DATE] = $($inpStartDate).val();
        reqDataObj[PARM_NAME_END_DATE]   = $($inpEndDate).val();

        if (reqDataObj[PARM_NAME_CLIENT_ID] == '') return;

        let reqDataJSON = JSON.stringify(reqDataObj);
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_SAVE()%>', reqDataJSON, null)
            .then(responseData => {
                updateAdditionalViewParameterValuesAndRequestPatPromisedSvcsViewFromServer(null);
            })
            .catch(responseData => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Audit Period Could Not Be Saved', responseData.message, {});
            });
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function saveCurrentAuditPatient(e) {
        let reqDataObj = {};

        reqDataObj[PARM_NAME_CLIENT_ID]  = $('#' + PARM_NAME_CLIENT_ID).val();
        reqDataObj[PARM_NAME_PATIENT_ID] = $('#' + PARM_NAME_PATIENT_ID).val();

        if (reqDataObj[PARM_NAME_CLIENT_ID]  == '') return;
        if (reqDataObj[PARM_NAME_PATIENT_ID] == '') return;

        let reqDataJSON = JSON.stringify(reqDataObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_PATIENT_SAVE()%>', reqDataJSON, null)
            .then(responseData => {
                $('#' + PARM_NAME_PATIENT_ID + '_selection').val('');
                $('#' + PARM_NAME_PATIENT_ID).val('');
                updateAdditionalViewParameterValuesAndRequestPatPromisedSvcsViewFromServer(null);
            })
            .catch(responseData => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Student Could Not Be Added', responseData.message, null);
            });
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function doReprocessPatientDataImport(e) {

        MBA.ComponentCommon.fnDisableElement($butDoReprocessPatientDataImport);

        let reqUrl            = '<%=Spedmon.CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_REPROCESS_IMPORTED_PATIENT_DATA_BASE()%>';
        let sessionExpiredUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        let reqDataObj        = {};
        reqDataObj[PARM_NAME_CLIENT_ID] = $('#' + PARM_NAME_CLIENT_ID).val();

        let reqDataJSON = JSON.stringify(reqDataObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqDataJSON, null)
            .then(responseData => {
                MBA.ComponentCommon.fnEnableElement($butDoReprocessPatientDataImport);
                updateAdditionalViewParameterValuesAndRequestPatPromisedSvcsViewFromServer(e);
            })
            .catch(responseData => {
                MBA.ComponentCommon.fnEnableElement($butDoReprocessPatientDataImport);                
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('There was an issue with reprocessing', responseData.message, {});
            });
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function doImportUserEnteredStats(e) {

        var url = '<%=Spedmon.PatientsPromisedServicesCDEAuditsCurrentPatients.URL_SAVE_NEW_IMPORT_USER_PROVIDED_DELIVERY_COMPLIANCE_STATS_SUB_PAGE_BASE()%>'
            + '&clientid=' + $('#' + PARM_NAME_CLIENT_ID).val()

        let _fnOnClose = function (dataToPass) {
            updateAdditionalViewParameterValuesAndRequestPatPromisedSvcsViewFromServer(null);
        };

        MBA.ComponentCommon.fnOpenWindowAndCallFnOnClose(url, 'import-user-provided-stats', null, _fnOnClose);

        return;

    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    $(window).on('load', function () {

        $selectParamsForAudit                = $('#selectParamsForAudit');
        $butDoSaveCurrAuditPeriod            = $('#butDoSaveCurrentAuditPeriodData');
        $butDoUploadStudents                 = $('#butDoUploadStudents');
        $dashboardItemCdeSuccessBuckets      = $('#cdesuccessbuckets');
        $restViewPatPromisedSvcs             = $('#restViewPatPromisedSvcs');
        $inpStartDate                        = $('#' + PARM_NAME_START_DATE);
        $inpEndDate                          = $('#' + PARM_NAME_END_DATE);
        $linkGotoManageCurrentYear           = $('#gotomanageoverall');
        $linkManageServiceDeliveryExceptions = $('#gotomanageservicedeliveryexceptions');
        $uploadStudentsDetails               = $('#uploadStudentsDetails');
        $uploadStudentsSummary               = $('#uploadStudentsSummary');
        $uploadStudentsContent               = $('#uploadStudentsContent');
        $doExportPromisedServiceSummary      = $('#doExportPromisedServiceSummary');
        $doRefresh                           = $('#doRefresh');
        $butDoReprocessPatientDataImport     = $('#butDoReprocessPatientDataImport');
        $uploadStudentDetails                = $('#uploadStudentDetails');
        $butDoImportUserEnteredStats         = $('#butDoImportUserEnteredStats');
        $rbPatAbsMinsAreSatMins              = $('#' + PARM_NAME_PAT_ABSENT_MINS_ARE_SATISFIED_MINS);

        initDashboardItemCdeSuccessBuckets();
        initRestViewPatPromisedSvcs();

        $($butDoSaveCurrAuditPeriod).on('click', function (e) {
            saveCurrentAuditPeriod(e);
        });

        $($butDoUploadStudents).on('click', function (e) {

          var url = '<%=Spedmon.PatientsPromisedServicesCDEAuditsCurrentPatients.URL_SAVE_NEW_IMPORT_SUB_PAGE_BASE()%>'
            + '&clientid=' + $('#' + PARM_NAME_CLIENT_ID).val()

          let _fnOnClose = function(dataToPass) {
              updateAdditionalViewParameterValuesAndRequestPatPromisedSvcsViewFromServer(null);
          };

          MBA.ComponentCommon.fnOpenWindowAndCallFnOnClose(url, 'import-patients-file-upload', null, _fnOnClose);
          
          return;

        });

        $($selectParamsForAudit).on('spedmoninputdata', function (e) {

            if (e.target.id == PARM_NAME_CLIENT_ID) {
                updateAdditionalViewParameterValuesAndRequestPatPromisedSvcsViewFromServer(e);
                return true;
            }

            if (e.target.id == PARM_NAME_PAT_ABSENT_MINS_ARE_SATISFIED_MINS) {
                updateDashboardItemsCdeSuccessBuckets();                
                return true;
            }

            if (e.target.id == PARM_NAME_PATIENT_ID) {
                saveCurrentAuditPatient(e);
                return true;
            }
           
            return true;
        });

        if ($('#' + PARM_NAME_CLIENT_ID).val()) { updateAdditionalViewParameterValuesAndRequestPatPromisedSvcsViewFromServer(null); }

    });

</script>
